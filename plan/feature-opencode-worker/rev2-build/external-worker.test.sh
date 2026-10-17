#!/usr/bin/env bash
# Exercises external-worker.sh against a stub backend CLI placed first on PATH;
# never calls a model, never touches the network. Needs bwrap, git, jq, tar.
#
# The stub runs inside the script's real sandbox, so the isolation cases test
# the sandbox itself, not a fake of it. The stub learns its scenario from a
# `STUB: <name>` line in the brief, because the script hands the sandbox a
# clean environment and no variable of ours reaches it.
#
# A second backend gets its own stub under "$W/bin/<its CLI name>" and its own
# scenarios; the harness below does not change.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to external-worker.sh>" >&2; exit 2; }
SRC_PLUGIN=$(cd "$(dirname "$1")/.." && pwd)
W=$(mktemp -d "${TMPDIR:-/tmp}/external-worker-test.XXXXXX") || exit 1
cleanup() { [ -n "${KEEP_W:-}" ] && { echo "kept $W" >&2; return; }; chmod -R u+rwX "$W" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT
# The script finds its agents, skills and profiles beside itself; a copy lets
# a case change a profile without touching the tree under test.
cp -R "$SRC_PLUGIN" "$W/plugin"
SCRIPT=$W/plugin/scripts/$(basename "$1")
KEY='KEY-test-0123456789abcdef'
mkdir -p "$W/bin" "$W/home/.local/share/opencode" "$W/tmp"
printf '{"opencode-go":{"type":"api","key":"%s"},"anthropic":{"type":"api","key":"OTHER-provider-key"}}' "$KEY" \
	>"$W/home/.local/share/opencode/auth.json"

cat >"$W/bin/opencode" <<'STUB'
#!/usr/bin/env bash
# Stub OpenCode CLI. Records its argv, then acts out the scenario named in the
# attached prompt file, printing --format json events like opencode run does.
prompt='' prev=''
for a in "$@"; do [ "$prev" = -f ] && prompt=$a; prev=$a; done
scen=$(sed -n 's/^STUB: //p' "$prompt" | head -n 1)
real=$(sed -n 's/^REAL: //p' "$prompt" | head -n 1)
text() { jq -cn --arg t "$1" '{type: "text", part: {type: "text", text: $t}}'; }
probe() { if "$@" >/dev/null 2>&1; then echo ok; else echo denied; fi; }
dev_report() { printf '=== REPORT START ===\nsteps:    1 done, 0 blocked\nfiles:    a.txt n.txt d.txt\ntests:    0 added\ngates:    build ok · tests ok · lint ok\ndetail:   plan/s/result.md\n%s\n=== REPORT END ===\n' "${1:-BUILT}"; }
case $scen in
	dev-ok)
		mkdir -p plan/s && echo result >plan/s/result.md
		echo changed >a.txt; echo new >n.txt; rm -f d.txt
		text "working"; text "$(dev_report)" ;;
	dev-twice) text "$(dev_report 'BLOCKED: first')"; mkdir -p plan/s && echo r >plan/s/result.md; text "$(dev_report)" ;;
	dev-no-tests) mkdir -p plan/s && echo r >plan/s/result.md; text "$(dev_report | sed '/^tests:/d')" ;;
	dev-no-detail) text "$(dev_report)" ;;
	dev-bad-verdict) mkdir -p plan/s && echo r >plan/s/result.md; text "$(dev_report 'DONE')" ;;
	no-markers) text "steps: 1 done" ;;
	rev-ship) text "$(printf '=== REPORT START ===\nSHIP\nnot checked: nothing\n=== REPORT END ===')" ;;
	rev-block2) text "$(printf '=== REPORT START ===\na.txt:1 — x\nrule: correctness\nbreaks when: y\nfix: z\nb.txt:2 — x\nrule: correctness\nbreaks when: y\nfix: z\nBLOCK: 2 issues\n=== REPORT END ===')" ;;
	rev-block-short) text "$(printf '=== REPORT START ===\na.txt:1 — x\nrule: correctness\nbreaks when: y\nfix: z\nBLOCK: 2 issues\n=== REPORT END ===')" ;;
	error-event) echo '{"type":"error","error":{"name":"APIError","data":{"message":"stub limit reached"}}}'; exit 1 ;;
	exit-silent) exit 3 ;;
	sleep) sleep 30 ;;
	escape)
		h=$(probe sh -c 'echo x >.git/hooks/pre-commit'); c=$(probe git config core.fsmonitor evil)
		k=$(probe git -c user.name=a -c user.email=a@a commit -q --allow-empty -m x)
		r=$(probe git update-ref refs/heads/evil HEAD); s=$(probe git stash)
		home=$(ls -A /home | paste -sd' ' -); repo=$(probe ls "$real"); data=$(probe ls /data)
		mkdir -p plan/s && echo r >plan/s/result.md
		text "$(printf 'hooks=%s config=%s commit=%s ref=%s stash=%s home=%s repo=%s data=%s\nenv=%s\nauth=%s\nconfig-edit=%s\nproject-config=%s\nargv=%s\n' \
			"$h" "$c" "$k" "$r" "$s" "$home" "$repo" "$data" "$(env | cut -d= -f1 | sort | paste -sd' ' -)" \
			"$(jq -r 'keys | join(" ")' <<<"$OPENCODE_AUTH_CONTENT")" \
			"$(jq -r '.agent["glab-worker"].permission | .edit + " ext=" + .external_directory["*"] + " web=" + .webfetch' <<<"$OPENCODE_CONFIG_CONTENT")" \
			"${OPENCODE_DISABLE_PROJECT_CONFIG:-unset}" "$*")"
		text "$(dev_report)" ;;
	rev-write)
		w=$(probe sh -c 'echo x >>a.txt'); t=$(probe sh -c 'echo x >/tmp/scratch')
		text "$(printf 'write=%s tmp=%s\nconfig-edit=%s\n' "$w" "$t" "$(jq -r '.agent["glab-worker"].permission.edit' <<<"$OPENCODE_CONFIG_CONTENT")")"
		text "$(printf '=== REPORT START ===\nSHIP\n=== REPORT END ===')" ;;
	copy)
		st=$(git status --short -uall | paste -sd'|' -)
		mkdir -p plan/s && echo r >plan/s/result.md
		text "$(printf 'status=%s\nenv-file=%s nested=%s branch=%s tree=%s\n' "$st" "$(probe test -e .env)" "$(probe test -e nested)" \
			"$(git symbolic-ref -q --short HEAD)" "$(git rev-parse 'HEAD^{tree}')")"
		text "PROMPT-FOLLOWS"; text "$(cat "$prompt")"
		text "$(dev_report)" ;;
	leak-text) mkdir -p plan/s && echo r >plan/s/result.md; text "key is $(jq -r '.["opencode-go"].key' <<<"$OPENCODE_AUTH_CONTENT")"; text "$(dev_report)" ;;
	history)
		old=$(sed -n 's/^OLD: //p' "$prompt" | head -n 1)
		mkdir -p plan/s && echo r >plan/s/result.md
		text "$(printf 'refs=%s commits=%s all=%s old=%s remote=%s remotes=%s\n' "$(git for-each-ref --format='%(refname)' | paste -sd' ' -)" \
			"$(git rev-list --count HEAD)" "$(git rev-list --all | wc -l)" "$(probe git cat-file -e "$old")" \
			"$(probe git rev-parse -q --verify origin/main)" "$(git remote | wc -l)")"
		text "$(dev_report)" ;;
	forged-out) mkdir -p plan/s && echo r >plan/s/result.md; text "$(dev_report | sed 's|^BUILT$|out: /tmp/elsewhere\nBUILT|')" ;;
	binary) mkdir -p plan/s && echo r >plan/s/result.md; printf '\000\001\002' >bin.dat; text "$(dev_report)" ;;
	limits)
		big=$(probe sh -c 'head -c 70M /dev/zero >big.dat'); rm -f big.dat
		small=$(probe sh -c 'head -c 1M /dev/zero >/tmp/small')
		fill=$(probe sh -c 'for i in 1 2 3 4 5; do head -c 60M /dev/zero >/tmp/f$i || exit 1; done'); rm -f /tmp/f* /tmp/small
		mkdir -p plan/s && echo r >plan/s/result.md
		text "$(printf 'big=%s small=%s fill=%s\n' "$big" "$small" "$fill")"; text "$(dev_report)" ;;
	leak-patch) mkdir -p plan/s && echo r >plan/s/result.md; jq -r '.["opencode-go"].key' <<<"$OPENCODE_AUTH_CONTENT" >leaked.txt; text "$(dev_report)" ;;
esac
STUB
chmod +x "$W/bin/opencode"
# Stub date: the script asks the clock once, as `date -u +%F`; a case that
# needs another day writes it to $W/today, and every other call is the real one.
cat >"$W/bin/date" <<STUB
#!/bin/sh
if [ "\$*" = "-u +%F" ] && [ -s "$W/today" ]; then cat "$W/today"; else exec /usr/bin/date "\$@"; fi
STUB
chmod +x "$W/bin/date"
# Every run below must reach this stub: a real opencode further down PATH
# would call a real model with whatever key it finds.
if [ "$(PATH="$W/bin:/usr/bin:/bin" command -v opencode)" != "$W/bin/opencode" ] || ! /usr/bin/grep -q '^# Stub OpenCode CLI' "$W/bin/opencode"; then
	echo "opencode does not resolve to the stub; refusing to run" >&2
	exit 1
fi

# The real repository the worker must never touch.
R=$W/repo
git init -q -b main "$R"
g() { git -C "$R" -c user.name=t -c user.email=t@t "$@"; }
printf 'a\n' >"$R/a.txt"; printf 'd\n' >"$R/d.txt"; printf 's\n' >"$R/s.txt"; printf '.env\n' >"$R/.gitignore"
g add -A; g commit -qm init; g tag v1; g update-ref refs/remotes/origin/main HEAD
# History and refs the copy must not carry (W39): a second commit, a branch.
g commit -q --allow-empty -m second; g branch side v1
printf 'staged\n' >>"$R/s.txt"; g add s.txt
printf 'unstaged\n' >>"$R/d.txt"
printf 'u\n' >"$R/u.txt"; printf 'SECRET=1\n' >"$R/.env"
git init -q "$R/nested"
fingerprint() { (cd "$R" && git status --porcelain -uall; git for-each-ref; git stash list; cat .git/config; ls .git/hooks; git diff; git diff --staged) | sha256sum; }
FP=$(fingerprint)

pass=0 fail=0 n=0
# w [VAR=val ...] -- <script args>; sets RC, OUT (stdout), ERR (stderr), DIR (the out: dir)
w() {
	local envs=()
	# A case that runs the script more than once keeps only the last out dir.
	tidy
	while [ "$1" != -- ]; do envs+=("$1"); shift; done; shift
	OUT=$(env -i PATH="$W/bin:/usr/bin:/bin" HOME="$W/home" TMPDIR="$W/tmp" CALLER_TOKEN=caller-secret ${envs[@]+"${envs[@]}"} \
		bash "$SCRIPT" --repo "$R" "$@" 2>"$W/err"); RC=$?
	ERR=$(cat "$W/err")
	DIR=$(sed -n 's/^out: //p' <<<"$OUT")
}
brief() { printf 'STUB: %s\nREAL: %s\nOLD: %s\nslug s, all steps\n' "$1" "$R" "$(g rev-parse v1)" >"$W/brief"; echo "$W/brief"; }
dev() { w -- --role developer --backend opencode --model opencode-go/kimi-k3 --brief "$(brief "$S")"; }
rev() { w -- --role reviewer --backend opencode --model opencode-go/glm-5.3 --brief "$(brief "$S")"; }
said() { command grep -qF -- "$1" <<<"$ERR"; }
leftover() { find "$W/tmp" -mindepth 1 -maxdepth 1 | wc -l; }
tidy() { [ -n "${DIR:-}" ] && rm -rf "$DIR"; DIR=''; }
t() { # t <id> <name> ; the case sets OK=1 on success
	n=$((n + 1))
	if [ "${OK:-0}" = 1 ]; then pass=$((pass + 1)); echo "ok $1 $2"; else fail=$((fail + 1)); echo "NOT OK $1 $2"; echo "   rc=$RC stderr=[$ERR]"; echo "   stdout=[$OUT]" | head -n 20; fi
	OK=0; tidy
}
OK=0 RC='' OUT='' ERR='' DIR=''

S=dev-ok; dev
[ "$RC" = 0 ] && [ "$(head -n 1 <<<"$OUT")" = "steps:    1 done, 0 blocked" ] && [ "$(tail -n 2 <<<"$OUT" | head -n 1)" = BUILT ] \
	&& [ "$(tail -n 1 <<<"$OUT")" = "out: $DIR" ] && [ "$(wc -l <<<"$OUT")" = 7 ] && OK=1
t W01 "developer success: stdout is the report block, then out:, nothing else"

S=dev-ok; dev
cp -R "$R" "$W/apply"; git -C "$W/apply" apply --check "$DIR/changes.patch" && git -C "$W/apply" apply "$DIR/changes.patch"
[ "$RC" = 0 ] && [ "$(cat "$W/apply/a.txt")" = changed ] && [ "$(cat "$W/apply/n.txt")" = new ] && [ ! -e "$W/apply/d.txt" ] \
	&& [ "$(cat "$W/apply/plan/s/result.md")" = result ] && [ "$(cat "$W/apply/u.txt")" = u ] && [ "$FP" = "$(fingerprint)" ] && OK=1
rm -rf "$W/apply"
t W02 "the patch applies to the real tree and holds edit, new file, delete and result.md; the real repo is untouched"

S=dev-ok; dev
[ "$RC" = 0 ] && [ -f "$DIR/report.txt" ] && [ -f "$DIR/transcript.jsonl" ] && [ -f "$DIR/changes.patch" ] && [ ! -e "$DIR/.run" ] && [ "$(leftover)" = 1 ] && OK=1
t W03 "the out dir keeps report, transcript and patch; the copy and sandbox home are removed"

S=copy; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && command grep -qxF 'status= M d.txt|M  s.txt|?? u.txt' <<<"$txt" \
	&& command grep -qxF "env-file=denied nested=denied branch=main tree=$(g rev-parse 'HEAD^{tree}')" <<<"$txt" && OK=1
t W04 "the copy holds HEAD's tree on the same branch with the staged, unstaged and untracked changes; never .env or a nested repo"

has() { command grep -qF -- "$1" <<<"$txt"; }
S=copy; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
ok=1
for m in 'You are a worker in the glab workflow' 'Before you finish, check your work' '# Where you are working' '# Your role contract' 'You build what a plan says' \
	'Two halves. The first is how you prove a claim' 'Two halves. Write the comments that carry knowledge' 'STUB: copy' \
	'between these two lines exactly' "Your contract's Report section, again" '## Report — short'; do has "$m" || ok=0; done
for m in 'name: developer' 'You review changes' 'PROFILE-MARK' 'The report template is not copied here'; do has "$m" && ok=0; done
[ "$RC" = 0 ] && [ "$ok" = 1 ] && OK=1
t W05 "the prompt holds both profile sections, the environment, the contract without frontmatter, both skills, the brief and the report section; never a profile's notes"

cp "$W/plugin/skills/workers/profiles/kimi.md" "$W/kimi.orig"
awk '/^## Before the contract/ {print; print ""; print "PROFILE-MARK"; next} 1' "$W/kimi.orig" >"$W/plugin/skills/workers/profiles/kimi.md"
S=copy; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && has PROFILE-MARK && has 'You are a worker in the glab workflow' \
	&& [ "$(command grep -n -m1 -F 'You are a worker' <<<"$txt" | cut -d: -f1)" -lt "$(command grep -n -m1 -F PROFILE-MARK <<<"$txt" | cut -d: -f1)" ] && OK=1
t W06 "the model's own profile is sent after the default one"
S=copy; rev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 8 ] && ! has PROFILE-MARK && has 'You review changes' && ! has 'You build what a plan says' && OK=1
cp "$W/kimi.orig" "$W/plugin/skills/workers/profiles/kimi.md"
t W07 "a model mapped to another profile does not get it; the reviewer gets the reviewer contract"

S=escape; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && command grep -qF 'hooks=denied config=denied commit=denied ref=denied stash=denied home=worker repo=denied data=denied' <<<"$txt" && [ "$FP" = "$(fingerprint)" ] && OK=1
t W08 "inside the sandbox .git is read-only, /home holds only the throwaway home, and /data and the real repo do not exist"

S=escape; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
envl=$(sed -n 's/^env=//p' <<<"$txt")
[ "$RC" = 0 ] && ! command grep -qw CALLER_TOKEN <<<"$envl" && command grep -qw OPENCODE_AUTH_CONTENT <<<"$envl" \
	&& command grep -qxF 'auth=opencode-go' <<<"$txt" && ! command grep -qF OTHER-provider-key "$DIR/transcript.jsonl" && OK=1
t W09 "the sandbox environment is the allowlist: no caller variable, and only the OpenCode Go credential"

S=escape; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && command grep -qxF 'config-edit=allow ext=deny web=deny' <<<"$txt" && command grep -qxF 'project-config=1' <<<"$txt" && OK=1
t W10 "the developer's agent may edit; external directories and webfetch are denied; project config is off"

S=escape; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
a=$(sed -n 's/^argv=//p' <<<"$txt")
[ "$RC" = 0 ] && [[ $a == "run Read the attached file and follow it exactly. It is your whole task. --pure --format json -m opencode-go/kimi-k3 --agent glab-worker --dir /work -f /home/worker/prompt.md" ]] && OK=1
t W11 "the CLI gets the message before -f, the named model, the script's agent, and no --auto"

S=rev-write; rev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && command grep -qF 'write=denied tmp=ok' <<<"$txt" && command grep -qxF 'config-edit=deny' <<<"$txt" && [ ! -e "$DIR/changes.patch" ] && OK=1
t W12 "the reviewer's tree is read-only, its scratch /tmp is writable, its agent may not edit, and it leaves no patch"

S=rev-ship; rev
[ "$RC" = 0 ] && [ "$(printf 'SHIP\nnot checked: nothing\nout: %s' "$DIR")" = "$OUT" ] && OK=1
t W13 "reviewer success keeps the lines after the verdict"

S=rev-block2; rev
[ "$RC" = 0 ] && [ "$(sed -n '$!p' <<<"$OUT" | tail -n 1)" = 'BLOCK: 2 issues' ] && OK=1
t W14 "a BLOCK with as many findings as it counts is accepted"

S=rev-block-short; rev
[ "$RC" = 8 ] && said 'MALFORMED REPORT' && said 'verdict says 2 issues, the report has 1' && [ "$OUT" = "out: $DIR" ] && OK=1
t W15 "a BLOCK that counts more findings than it has is malformed (8)"

S=no-markers; dev
[ "$RC" = 8 ] && said "no block between" && [ "$OUT" = "out: $DIR" ] && OK=1
t W16 "no report markers is malformed (8), with only out: on stdout"

S=dev-no-tests; dev
[ "$RC" = 8 ] && said "no 'tests:' line" && OK=1
t W17 "a developer report missing a field is malformed (8) and names the field"

S=dev-no-detail; dev
[ "$RC" = 8 ] && said 'detail: plan/s/result.md was not written' && OK=1
t W18 "a developer report whose result.md was not written is malformed (8)"

S=dev-bad-verdict; dev
[ "$RC" = 8 ] && said 'last line is not BUILT' && OK=1
t W19 "a developer verdict outside the contract is malformed (8)"

S=dev-twice; dev
[ "$RC" = 0 ] && [ "$(tail -n 2 <<<"$OUT" | head -n 1)" = BUILT ] && OK=1
t W20 "the last report block is the one read"

S=error-event; dev
[ "$RC" = 7 ] && said 'BACKEND ERROR: APIError: stub limit reached' && [ "$OUT" = "out: $DIR" ] && OK=1
t W21 "an error event is a backend error (7), with its name and message"

S=exit-silent; dev
[ "$RC" = 7 ] && said 'opencode exited 3 with no error event' && OK=1
t W22 "a non-zero exit with no error event is a backend error (7)"

s=$SECONDS; w -- --role developer --backend opencode --model opencode-go/kimi-k3 --brief "$(brief sleep)" --timeout 2; e=$((SECONDS - s))
[ "$RC" = 6 ] && said TIMEOUT && [ "$e" -lt 15 ] && [ "$OUT" = "out: $DIR" ] && OK=1
t W23 "a run past --timeout is killed and reported (6) within the limit plus the kill grace"

S=leak-text; dev
[ "$RC" = 0 ] && ! command grep -qF "$KEY" "$DIR/transcript.jsonl" && command grep -qF 'key is <redacted>' "$DIR/transcript.jsonl" && OK=1
t W24 "the credential is redacted from the transcript"

S=leak-patch; dev
[ "$RC" = 9 ] && said 'SECRET IN OUTPUT' && [ ! -e "$DIR/changes.patch" ] && ! command grep -rqF "$KEY" "$DIR" && OK=1
t W25 "a patch carrying the credential is deleted and refused (9)"

w -- --role developer --backend codex --model x --brief "$(brief dev-ok)"
[ "$RC" = 3 ] && said 'UNKNOWN BACKEND' && [ -z "$OUT" ] && [ "$(leftover)" = 0 ] && OK=1
t W26 "an unknown backend is refused (3) before anything is created"

ok=1
for m in opencode-go/grok-4.7 opencode/claude-haiku-5-5 opencode-go/gemini-4-argon-contributor kimi-k3; do
	w -- --role developer --backend opencode --model "$m" --brief "$(brief dev-ok)"
	{ [ "$RC" = 5 ] && said 'MODEL REFUSED' && [ "$(leftover)" = 0 ]; } || ok=0
done
[ "$ok" = 1 ] && said 'allowed: opencode-go/kimi-k3 ' && OK=1
t W27 "a model outside the allowlist is refused (5), Zen ids included, and the list is printed"

echo 2026-11-01 >"$W/today"; w -- --role reviewer --backend opencode --model opencode-go/deepseek-v4-pro --brief "$(brief rev-ship)"; r1=$RC
echo 2026-10-31 >"$W/today"; w -- --role reviewer --backend opencode --model opencode-go/deepseek-v4-pro --brief "$(brief rev-ship)"; r2=$RC
rm -f "$W/today"
[ "$r1" = 5 ] && [ "$r2" = 0 ] && OK=1
t W28 "a model with an end date is allowed on that day and refused after it (5)"

ok=1; echo 2026-10-16 >"$W/today"
for m in opencode-go/kimi-k3 opencode-go/kimi-k2.7-code opencode-go/glm-5.3 opencode-go/glm-5.3-flash opencode-go/glm-5.2 opencode-go/deepseek-v4-pro opencode-go/deepseek-v4.1-flash; do
	w -- --role reviewer --backend opencode --model "$m" --brief "$(brief rev-ship)"; [ "$RC" = 0 ] || ok=0; tidy
done; rm -f "$W/today"
[ "$ok" = 1 ] && OK=1
t W29 "every allowed model is accepted"

mv "$W/bin/opencode" "$W/bin/opencode.off"; w -- --role developer --backend opencode --model opencode-go/kimi-k3 --brief "$(brief dev-ok)"; mv "$W/bin/opencode.off" "$W/bin/opencode"
[ "$RC" = 4 ] && said 'opencode CLI not found' && [ "$(leftover)" = 0 ] && OK=1
t W30 "no backend CLI on PATH is unavailable (4)"

mv "$W/home/.local/share/opencode/auth.json" "$W/auth.off"; S=dev-ok; dev; mv "$W/auth.off" "$W/home/.local/share/opencode/auth.json"
[ "$RC" = 4 ] && said 'no opencode credential' && OK=1
t W31 "no OpenCode Go credential is unavailable (4)"

ok=1
w -- --role analyzer --backend opencode --model opencode-go/kimi-k3 --brief "$(brief dev-ok)"; { [ "$RC" = 2 ] && said '--role must be developer or reviewer'; } || ok=0
w -- --role developer --backend opencode --model opencode-go/kimi-k3 --brief "$(brief dev-ok)" --timeout 0; { [ "$RC" = 2 ] && said '--timeout'; } || ok=0
w TMPDIR= -- --role developer --backend opencode --model opencode-go/kimi-k3 --brief "$(brief dev-ok)"; { [ "$RC" = 2 ] && said 'TMPDIR'; } || ok=0
[ "$ok" = 1 ] && [ "$(leftover)" = 0 ] && OK=1
t W32 "usage errors (2): a role that is never external, a bad timeout, no TMPDIR"

# The script restates the verdict sets of the two agent files; this case fails
# the moment one of those files changes a verdict and the script does not.
ok=1
for v in 'BUILT' 'BLOCKED: <reason>' 'PLAN WRONG: <what>'; do command grep -qF -- "\`$v" "$W/plugin/agents/developer.md" || ok=0; done
# The backticks are part of the text searched for: each verdict is quoted
# that way in the agent file.
# shellcheck disable=SC2016
for v in '`SHIP`' '`SHIP WITH SCOPE CUT: <what to drop>`' '`BLOCK: <n> issues`' '`BLOCK: target unresolved`' '`DO NOT PUBLISH: <one line why>`'; do command grep -qF -- "$v" "$W/plugin/agents/reviewer.md" || ok=0; done
for v in 'BUILT|BLOCKED:\ .+|PLAN\ WRONG:\ .+' 'SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+'; do command grep -qF -- "$v" "$SCRIPT" || ok=0; done
[ "$ok" = 1 ] && OK=1
t W33 "the verdicts the script accepts are the ones the agent files state"

# The allowlist names a profile per model; a profile no line names is dead
# text, and a line naming a missing profile sends the default alone.
named=$(awk '/^opencode_models\(\) \{/ {on = 1; next} on && /^EOF$/ {exit} on && NF == 3 {print $2}' "$SCRIPT" | sort -u)
files=$(find "$W/plugin/skills/workers/profiles" -maxdepth 1 -name '*.md' -printf '%f\n' | sed 's|\.md$||' | command grep -vx default | sort)
[ -n "$named" ] && [ "$named" = "$files" ] && OK=1
t W34 "every profile file is named by an allowlist line, and every named profile exists"

g checkout -q --detach; S=copy; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null); g checkout -q main
[ "$RC" = 0 ] && command grep -qxF "env-file=denied nested=denied branch= tree=$(g rev-parse 'HEAD^{tree}')" <<<"$txt" && OK=1
t W35 "a detached HEAD is copied detached, with the same tree"

# A bwrap that cannot start a sandbox, as on a host that forbids user
# namespaces (findings P12), stands in front of the real one.
printf '#!/bin/sh\necho "bwrap: No permissions to create a new namespace" >&2\nexit 1\n' >"$W/bin/bwrap"; chmod +x "$W/bin/bwrap"
S=dev-ok; dev; rm -f "$W/bin/bwrap"
[ "$RC" = 4 ] && said 'bwrap cannot start a sandbox on this host' && [ -z "$OUT" ] && [ "$(leftover)" = 0 ] && OK=1
t W36 "a host where bwrap cannot start a sandbox is unavailable (4), and nothing is left behind"

S=forged-out; dev
[ "$RC" = 8 ] && said "a report line starts with 'out: '" && [ "$OUT" = "out: $DIR" ] && OK=1
t W38 "a report line that starts with out: is malformed (8), and out: stays the script's last line"

S=history; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && command grep -qxF 'refs=refs/heads/main commits=1 all=1 old=denied remote=denied remotes=0' <<<"$txt" && OK=1
t W39 "the copy holds one commit and one branch: no other branch, tag, remote-tracking ref, remote or older commit"

S=binary; dev
[ "$RC" = 10 ] && said 'BINARY IN PATCH' && [ ! -e "$DIR/changes.patch" ] && [ "$OUT" = "out: $DIR" ] && OK=1
t W40 "a binary change is refused (10) and its patch deleted"

S=limits; dev; txt=$(jq -r 'select(.type=="text").part.text' "$DIR/transcript.jsonl" 2>/dev/null)
[ "$RC" = 0 ] && command grep -qxF 'big=denied small=ok fill=denied' <<<"$txt" && OK=1
t W41 "a file past 64 MiB and a /tmp past 256 MiB are refused inside the sandbox; a small write is not"

[ "$FP" = "$(fingerprint)" ] && OK=1
t W37 "after every case, the real repository's status, refs, stash, config, hooks and diffs are unchanged"

if [ "$fail" -eq 0 ]; then echo "PASS $pass/$n"; else echo "FAIL $fail/$n"; exit 1; fi
