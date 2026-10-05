#!/usr/bin/env bash
# Exercises memory-sync.sh against a stub `aws`; never contacts a real backend.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to memory-sync.sh>" >&2; exit 2; }
# Absolute, because every run below starts from a scratch working directory.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:-/tmp}/memory-sync-test.XXXXXX") || exit 1
PIDS=()
cleanup() {
	local p
	for p in ${PIDS[@]+"${PIDS[@]}"}; do kill "$p" 2>/dev/null; done
	rm -rf "$W"
}
trap cleanup EXIT
mkdir -p "$W/bin" "$W/cwd"
cat >"$W/bin/aws" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "CALL $*" >>"$STUB_LOG"
# The parent is the `timeout` the script wrapped us in; its argv shows the time limit we were given.
printf 'PARENT %s\n' "$(tr '\0' ' ' <"/proc/$PPID/cmdline")" >>"$STUB_LOG"
[ -n "${STUB_IGNORE_TERM:-}" ] && trap '' TERM
# The sleep must not inherit our stdout/stderr: it can outlive us, and the test would wait on the open pipe.
if [ -n "${STUB_SLEEP:-}" ]; then sleep "$STUB_SLEEP" >/dev/null 2>&1 & echo $! >>"$STUB_PIDS"; wait $!; fi
map() { case "$1" in s3://stub/mem/*) echo "$FAKE_REMOTE/${1#s3://stub/mem/}" ;; *) echo "$1" ;; esac; }
case "$2" in
	sync)
		[ -n "${STUB_FAIL_SYNC:-}" ] && exit "$STUB_FAIL_SYNC"
		del=()
		for a in "$@"; do [ "$a" = --delete ] && del=(--delete); done
		/usr/bin/rsync -a ${del[@]+"${del[@]}"} --include '*/' --include '*/memory/*' --exclude '*' "$(map "$3")" "$(map "$4")"
		;;
	rm)
		[ -n "${STUB_FAIL_RM:-}" ] && exit "$STUB_FAIL_RM"
		rm -f -- "$(map "$3")"
		;;
esac
STUB
chmod +x "$W/bin/aws"

pass=0 fail=0 n=0
reset() {
	rm -rf "$W/conf" "$W/remote"; mkdir -p "$W/conf/projects/p1/memory" "$W/remote"
	: >"$W/log"; : >"$W/pids"; : >"$W/err"
	M="$W/conf/projects/p1/memory"
}
# run [VAR=val ...] -- mode [args]; stderr -> $W/err, asserts rc 0 and empty stdout
run() {
	local envs=() out rc
	while [ "$1" != -- ]; do envs+=("$1"); shift; done; shift
	out=$(cd "$W/cwd" && env -u CLAUDE_MEMORY_S3_ARGS -u AWS_PROFILE PATH="$W/bin:/usr/bin:/bin" \
		CLAUDE_CONFIG_DIR="$W/conf" CLAUDE_MEMORY_S3_URI=s3://stub/mem CLAUDE_MEMORY_S3_TIMEOUT=5 \
		STUB_LOG="$W/log" STUB_PIDS="$W/pids" FAKE_REMOTE="$W/remote" ${envs[@]+"${envs[@]}"} \
		bash "$SCRIPT" "$@" 2>"$W/err"); rc=$?
	[ "$rc" -eq 0 ] && [ -z "$out" ] || { echo "   contract broken: rc=$rc stdout=[$out]"; CONTRACT=1; }
}
calls() { /usr/bin/grep -c '^CALL' "$W/log" || true; }
said() { /usr/bin/grep -q -F -- "$1" "$W/err"; }
t() { # t <id> <name> ; body sets OK=1 on success
	n=$((n + 1))
	if [ "${OK:-0}" = 1 ] && [ "${CONTRACT:-0}" = 0 ]; then pass=$((pass + 1)); echo "ok $1 $2"; else fail=$((fail + 1)); echo "NOT OK $1 $2"; sed 's/^/   stderr: /' "$W/err"; fi
	OK=0; CONTRACT=0
}
OK=0 CONTRACT=0

reset; echo a >"$M/a.md"; run -- push; p=$(cat "$W/err"); rm "$M/a.md"; run -- pull
[ "$p" = "[memory-sync] push ok" ] && said "pull ok" && [ -f "$M/a.md" ] && OK=1
t T01 "push then pull round-trips a memory"

reset; echo a >"$M/a.md"; echo b >"$M/b.md"; run -- push; run -- pull; run -- delete p1/memory/b.md; d=$(cat "$W/err"); run -- push; run -- pull
[ "$d" = "[memory-sync] delete ok: p1/memory/b.md" ] && [ ! -e "$M/b.md" ] && [ ! -e "$W/conf/.memory-sync-stage/p1/memory/b.md" ] && [ ! -e "$W/remote/p1/memory/b.md" ] && [ -f "$M/a.md" ] && [ -f "$W/remote/p1/memory/a.md" ] && OK=1
t T02 "delete removes remote, stage and local copy and it stays gone after push+pull"

reset; echo b >"$M/b.md"; run -- push; run -- pull; : >"$W/log"; run STUB_FAIL_RM=1 -- delete p1/memory/b.md
said "delete: remote copy not removed; local copy left in place" && [ -f "$M/b.md" ] && [ -f "$W/conf/.memory-sync-stage/p1/memory/b.md" ] && [ -f "$W/remote/p1/memory/b.md" ] && OK=1
t T03 "delete leaves local and stage untouched when the remote delete fails"

reset; echo b >"$M/b.md"; mkdir -p "$W/conf/projects/p1/other"; echo x >"$W/conf/projects/p1/other/x"; OK=1
mkdir "$M/sub"; echo y >"$M/sub/y.md"
for bad in "" "../p1/memory/b.md" "p1/memory/../memory/b.md" "p1/./memory/b.md" "/p1/memory/b.md" "p1/other/x" "p1/memory/" "memory/b.md" "p1/memory/sub"; do
	run -- delete "$bad"; said "nothing removed" || OK=0
done
[ "$(calls)" = 0 ] && [ -f "$M/b.md" ] && [ -f "$M/sub/y.md" ] && [ -f "$W/conf/projects/p1/other/x" ] || OK=0
t T04 "delete rejects anything that is not <project>/memory/<file> without calling aws"

reset; echo a >"$M/a.md"; echo b >"$M/b.md"; run -- push; run -- pull; rm "$M/b.md" "$W/remote/p1/memory/b.md"; run -- pull
[ ! -e "$M/b.md" ] && [ ! -e "$W/conf/.memory-sync-stage/p1/memory/b.md" ] && [ -f "$M/a.md" ] && OK=1
t T05 "pull prunes the stage, so a file gone from the remote is not restored"

reset; echo old >"$M/a.md"; touch -d '1 hour ago' "$M/a.md"; run -- push; echo newer-local >"$M/a.md"; run -- pull
[ "$(cat "$M/a.md")" = newer-local ] && OK=1
t T06 "pull does not overwrite a newer local file"

reset; echo a >"$M/a.md"; run STUB_FAIL_SYNC=1 -- push-if-changed; f=$(cat "$W/err"); : >"$W/log"; s=$SECONDS; run -- push-if-changed
[ "$f" = "[memory-sync] push-if-changed failed (exit 1)" ] && [ -f "$W/conf/.memory-sync-failed" ] && [ "$(calls)" = 0 ] && [ ! -s "$W/err" ] && [ $((SECONDS - s)) -le 1 ] && OK=1
t T07 "a failed push starts a cool-down: the next push-if-changed makes no aws call and prints nothing"

reset; echo a >"$M/a.md"; touch -d '4 minutes ago' "$W/conf/.memory-sync-failed"; run -- push-if-changed; early=$(calls)
touch -d '6 minutes ago' "$W/conf/.memory-sync-failed"; run -- push-if-changed
[ "$early" = 0 ] && [ "$(calls)" = 1 ] && said "push-if-changed ok" && [ ! -e "$W/conf/.memory-sync-failed" ] && OK=1
t T08 "the cool-down holds at 4 minutes and ends by 6; success clears the failure stamp"

reset; echo a >"$M/a.md"; touch "$W/conf/.memory-sync-failed"; run -- push
[ "$(calls)" = 1 ] && said "push ok" && [ ! -e "$W/conf/.memory-sync-failed" ] && OK=1
t T09 "push ignores the cool-down"

reset; echo a >"$M/a.md"
( exec 9>"$W/conf/.memory-sync.lock"; flock 9; exec sleep 20 ) & holder=$!; PIDS+=("$holder"); sleep 0.5
s=$SECONDS; run -- push-if-changed; e=$((SECONDS - s)); kill "$holder" 2>/dev/null; wait "$holder" 2>/dev/null
[ "$(calls)" = 0 ] && said "push-if-changed: another sync is running; skipping" && [ "$e" -le 1 ] && OK=1
t T10 "push-if-changed does not wait for a held lock"

reset; echo a >"$M/a.md"; mkdir "$W/conf/.memory-sync.lock"; run -- push
[ "$(calls)" = 0 ] && said "push: cannot open lock file" && ! said "busy" && OK=1
t T11 "an unopenable lock file is reported as such, not as busy"

reset; echo a >"$M/a.md"; touch "$W/cwd/fileA"; run "CLAUDE_MEMORY_S3_ARGS=--no-verify-ssl *" -- push
/usr/bin/grep -q -- '--no-verify-ssl \* --only-show-errors' "$W/log" && ! /usr/bin/grep -q fileA "$W/log" && OK=1
rm -f "$W/cwd/fileA"
t T12 "CLAUDE_MEMORY_S3_ARGS is split on spaces but not glob-expanded"

reset; echo a >"$M/a.md"; run CLAUDE_MEMORY_S3_URI=s3://stub/mem// -- push
/usr/bin/grep -q ' s3://stub/mem/ ' "$W/log" && ! /usr/bin/grep -q 'mem//' "$W/log" && OK=1
t T13 "trailing slashes on the URI do not produce // in keys"

reset
OK=1
for gone in aws timeout flock rsync; do
	rm -rf "$W/nb"; mkdir -p "$W/nb"
	for x in bash env mkdir touch mv rm find basename date stat tr aws timeout flock rsync; do
		[ "$x" = "$gone" ] && continue
		if [ "$x" = aws ]; then cp "$W/bin/aws" "$W/nb/aws"; else ln -s "$(command -v "$x")" "$W/nb/$x"; fi
	done
	: >"$W/log"; run PATH="$W/nb" -- pull
	[ "$(cat "$W/err")" = "[memory-sync] $gone not found; skipping" ] && [ "$(calls)" = 0 ] || OK=0
done
t T14 "each required tool (aws, timeout, flock, rsync) is probed; a missing one is named and the run skipped"

reset; echo a >"$M/a.md"; run -- push; mkdir -p "$W/rb"; printf '#!/bin/sh\nexit 23\n' >"$W/rb/rsync"; chmod +x "$W/rb/rsync"
run PATH="$W/rb:$W/bin:/usr/bin:/bin" -- pull
[ "$(cat "$W/err")" = "[memory-sync] pull failed (exit 23)" ] && OK=1
t T15 "an rsync failure during pull is logged"

reset; echo a >"$M/a.md"; s=$SECONDS; run STUB_SLEEP=30 CLAUDE_MEMORY_S3_TIMEOUT=2 -- push; e=$((SECONDS - s))
while read -r p; do PIDS+=("$p"); kill "$p" 2>/dev/null; done <"$W/pids"
said "push timed out after 2s" && [ "$e" -le 5 ] && [ -f "$W/conf/.memory-sync-failed" ] && OK=1
t T16 "a hung transfer is cut off at the timeout and counted as a failure"

reset; run -- bogus
said "usage: memory-sync.sh pull|push|push-if-changed|delete <project>/memory/<file>" && OK=1
t T17 "an unknown mode prints usage"

reset; echo a >"$M/a.md"
( exec 9>"$W/conf/.memory-sync.lock"; flock 9; exec sleep 20 ) & holder=$!; PIDS+=("$holder"); sleep 0.5
run CLAUDE_MEMORY_S3_TIMEOUT=2 -- pull; kill "$holder" 2>/dev/null; wait "$holder" 2>/dev/null
[ "$(calls)" = 0 ] && [ "$(cat "$W/err")" = "[memory-sync] pull: lock busy after 2s; skipping" ] && OK=1
t T18 "pull takes the lock and gives up at the timeout while another sync holds it"

reset; echo a >"$M/a.md"; run CLAUDE_MEMORY_S3_TIMEOUT= -- push
/usr/bin/grep -q '^PARENT timeout -k 2 12 aws s3 sync ' "$W/log" && said "push ok" && OK=1
t T19 "the default time limit is 12 s and transfers run under timeout -k 2"

reset; echo a >"$M/a.md"; OK=1
for v in abc 0 08 -3; do
	: >"$W/log"; run "CLAUDE_MEMORY_S3_TIMEOUT=$v" -- push
	said "CLAUDE_MEMORY_S3_TIMEOUT is not a positive integer; using 12" && /usr/bin/grep -q '^PARENT timeout -k 2 12 aws ' "$W/log" || OK=0
done
t T20 "a time limit that is not a positive integer (abc, 0, 08, -3) falls back to 12 and says so"

reset; echo a >"$M/a.md"
( exec 9>"$W/conf/.memory-sync.lock"; flock 9; exec sleep 2 ) & holder=$!; PIDS+=("$holder"); sleep 0.5
run CLAUDE_MEMORY_S3_TIMEOUT=6 -- push; wait "$holder" 2>/dev/null
given=$(sed -n 's/^PARENT timeout -k 2 \([0-9]*\) aws .*/\1/p' "$W/log")
said "push ok" && [ -n "$given" ] && [ "$given" -ge 3 ] && [ "$given" -le 5 ] && OK=1
t T21 "push waits for the lock, and the transfer only gets what the lock wait left of the time limit"

reset; echo a >"$M/a.md"; s=$SECONDS; run STUB_SLEEP=30 STUB_IGNORE_TERM=1 CLAUDE_MEMORY_S3_TIMEOUT=2 -- push; e=$((SECONDS - s))
while read -r p; do PIDS+=("$p"); kill -9 "$p" 2>/dev/null; done <"$W/pids"
said "push timed out after 2s" && [ "$e" -le 6 ] && OK=1
t T22 "a transfer that ignores TERM is killed: the run ends within the limit plus 3 s"

reset; echo a >"$M/a.md"; touch -d '1 minute ago' "$M/a.md"; touch -d '2 minutes ago' "$W/conf/.memory-sync-pushed"
# A flock that marks a push as just finished, then behaves normally: the state push-if-changed must notice.
mkdir -p "$W/fb"
cat >"$W/fb/flock" <<'FLOCK'
#!/bin/sh
touch "$CLAUDE_CONFIG_DIR/.memory-sync-pushed"
exec /usr/bin/flock "$@"
FLOCK
chmod +x "$W/fb/flock"
run PATH="$W/fb:$W/bin:/usr/bin:/bin" -- push-if-changed
[ "$(calls)" = 0 ] && [ ! -s "$W/err" ] && OK=1
t T23 "push-if-changed checks again after taking the lock and sends nothing if another push just did"

reset; echo b >"$M/b.md"; run -- push; : >"$W/log"
( exec 9>"$W/conf/.memory-sync.lock"; flock 9; exec sleep 20 ) & holder=$!; PIDS+=("$holder"); sleep 0.5
run CLAUDE_MEMORY_S3_TIMEOUT=2 -- delete p1/memory/b.md; kill "$holder" 2>/dev/null; wait "$holder" 2>/dev/null
[ "$(calls)" = 0 ] && [ "$(cat "$W/err")" = "[memory-sync] delete: lock busy after 2s; skipping" ] && [ -f "$M/b.md" ] && [ -f "$W/remote/p1/memory/b.md" ] && OK=1
t T24 "delete takes the lock and removes nothing while another sync holds it"

if [ "$fail" -eq 0 ]; then echo "PASS $pass/$n"; else echo "FAIL $fail/$n"; exit 1; fi
