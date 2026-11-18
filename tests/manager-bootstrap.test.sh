#!/usr/bin/env bash
# Exercises manager-bootstrap.sh, the SessionStart hook, against repos written here under $TMPDIR.
# Every run must keep the hook contract - exit 0, stdout one JSON object whose only key is
# hookSpecificOutput (or the plain text when jq is missing) - and each case checks which level's
# text it printed, and, from its stdin, whether it named the session's handoff file.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to manager-bootstrap.sh>" >&2; exit 2; }
# Absolute, because the runs below start from other directories.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/manager-bootstrap-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap removes the
# work directory, after giving back the read bit B11 takes away.
trap 'chmod -R u+rwx "$W" 2>/dev/null; rm -rf "$W"' EXIT
cd "$W" || exit 1

pass=0 fail=0 n=0
reason='' # why the current case failed; empty while it holds
OUT='' ERR='' RC=0 TEXT=''
bad() { reason="${reason:+$reason; }$*"; }
done_case() { # done_case <id> <name>
	n=$((n + 1))
	if [ -z "$reason" ]; then
		pass=$((pass + 1))
		echo "ok $1 $2"
	else
		fail=$((fail + 1))
		echo "FAIL $1 $2: $reason"
	fi
	reason=''
}

PROJECT_LINE='Level: project — no other glab-level line in AGENTS.md says otherwise.'
PRODUCT_LINE='Level: product — glab-level: product in AGENTS.md.'
WARN_DELIVERY='glab: level "delivery" is not built in this version of glab; this session runs at the project level'
# The manager each text loads. The backticks are the text's own Markdown, not a command.
# shellcheck disable=SC2016
PROJECT_MGR='`glab:project-manager` — the operating model of the project level'
# shellcheck disable=SC2016
PRODUCT_MGR='`glab:product-manager` — the operating model of the product level'
# The handoff line's two forms: the path the id names, and the fixed words of the no-id line.
# shellcheck disable=SC2016
ID_PATH='`plan/handoff/abc-123.md`'
NO_ID='no session id'

# repo <name> [AGENTS.md text]: a repo folder, with that AGENTS.md when a text is given.
repo() {
	mkdir -p "$W/$1"
	if [ $# -gt 1 ]; then printf '%s\n' "$2" >"$W/$1/AGENTS.md"; fi
	echo "$W/$1"
}
# hook <repo> [stdin]: runs the hook with CLAUDE_PROJECT_DIR set to the repo and that text as its
# hook input - none, /dev/null, when it is not given, so no run inherits the test's own stdin; sets
# OUT, ERR, RC and TEXT, the additionalContext. Asserts the contract on every run.
hook() {
	if [ $# -gt 1 ]; then
		OUT=$(printf '%s' "$2" | CLAUDE_PROJECT_DIR=$1 bash "$SCRIPT" 2>"$W/err")
	else
		OUT=$(CLAUDE_PROJECT_DIR=$1 bash "$SCRIPT" </dev/null 2>"$W/err")
	fi
	RC=$?
	ERR=$(cat "$W/err")
	contract
}
contract() {
	[ "$RC" -eq 0 ] || bad "rc=$RC"
	[ "$(jq -s length <<<"$OUT" 2>/dev/null)" = 1 ] || bad "stdout is not one JSON value"
	jq -e 'keys == ["hookSpecificOutput"] and .hookSpecificOutput.hookEventName == "SessionStart" and (.hookSpecificOutput | keys == ["additionalContext", "hookEventName"])' \
		<<<"$OUT" >/dev/null 2>&1 || bad "stdout is not one SessionStart object: [${OUT:0:120}]"
	TEXT=$(jq -r .hookSpecificOutput.additionalContext <<<"$OUT" 2>/dev/null)
}
# is_project / is_product: the text is that level's, by its first line and the manager it names.
is_project() {
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$PROJECT_LINE" ] || bad "first line [$(printf '%s\n' "$TEXT" | head -n 1)] is not the project line"
	has "$PROJECT_MGR"
	hasnt "$PRODUCT_MGR"
}
is_product() {
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$PRODUCT_LINE" ] || bad "first line is not the product line"
	has "$PRODUCT_MGR"
	hasnt "$PROJECT_MGR"
}
has() { case $TEXT in *"$1"*) ;; *) bad "the text lacks [$1]" ;; esac; }
hasnt() { case $TEXT in *"$1"*) bad "the text holds [$1]" ;; esac; }
no_err() { [ -z "$ERR" ] || bad "stderr not empty: [$ERR]"; }

# B1
hook "$(repo b1)"
is_project
no_err
B1_TEXT=$TEXT
done_case B1 "no AGENTS.md: exit 0, one SessionStart object, the project text"

# B2
hook "$(repo b2 $'# Working agreement\n\nglab-level: product\nglab-shared-store: <store>')"
is_product
has 'glab:session-rules'
no_err
B2_TEXT=$TEXT
done_case B2 "glab-level: product: the product text"

# B3
hook "$(repo b3 $'# Working agreement\nglab-level: project')"
[ "$TEXT" = "$B1_TEXT" ] || bad "the text differs from B1's"
no_err
done_case B3 "glab-level: project: the same text as with no AGENTS.md"

# B4
hook "$(repo b4 'glab-level: delivery')"
[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$WARN_DELIVERY" ] || bad "the warning is not the first line"
[ "$(printf '%s\n' "$TEXT" | sed -n 3p)" = "$PROJECT_LINE" ] || bad "the project line does not follow the warning"
has "$PROJECT_MGR"
[ "$ERR" = "$WARN_DELIVERY" ] || bad "stderr [$ERR] is not the warning"
done_case B4 "glab-level: delivery: the project text with the warning first, and on stderr"

# B5
mkdir -p "$W/bin"
for t in bash cat cut git grep sed tr; do
	p=$(command -v "$t") && ln -s "$p" "$W/bin/$t"
done
r=$(repo b5 'glab-level: product')
# The input carries an id; without jq it cannot be read, so the plain text has the no-id line, as
# B2's run without input does.
OUT=$(printf '%s' '{"session_id":"abc-123"}' | CLAUDE_PROJECT_DIR=$r PATH=$W/bin bash "$SCRIPT" 2>"$W/err")
RC=$?
[ "$RC" -eq 0 ] || bad "rc=$RC"
[ "$OUT" = "$B2_TEXT" ] || bad "stdout is not the plain product text"
[ -z "$(PATH=$W/bin command -v jq)" ] || bad "jq is still on the test PATH"
case $OUT in *"$NO_ID"*) ;; *) bad "the plain text lacks the no-id line" ;; esac
done_case B5 "a PATH without jq: the plain text with the no-id line, exit 0"

# B6
r=$(repo b6 'glab-level: product')
OUT=$(cd "$r" && env -u CLAUDE_PROJECT_DIR bash "$SCRIPT" </dev/null 2>"$W/err")
RC=$?
ERR=$(cat "$W/err")
contract
is_product
done_case B6 "CLAUDE_PROJECT_DIR unset: the level read from \$PWD/AGENTS.md"

# B7
hook "$(repo b7 $'# Working agreement\r\nglab-level: product\r')"
is_product
done_case B7 "a CRLF AGENTS.md: the level still read"

# B8
for t in "$B1_TEXT" "$B2_TEXT"; do
	[ "${#t}" -lt 10000 ] || bad "a text is ${#t} characters"
done
hook "$(repo b8 'glab-level: support')"
[ "${#TEXT}" -lt 10000 ] || bad "the text with a warning is ${#TEXT} characters"
done_case B8 "every text, the warning included, is under 10,000 characters"

# B9
hook "$(repo b9 $'glab-level: project\nglab-level: product')"
is_project
done_case B9 "only the first level line counts"

# B10 is judged by no_err in B1-B3 above; it repeats them so its own line says so.
for a in '' 'glab-level: project' 'glab-level: product'; do
	if [ -n "$a" ]; then r=$(repo "b10-$RANDOM" "$a"); else r=$(repo "b10-none"); fi
	hook "$r"
	no_err
done
done_case B10 "stderr is empty for the built levels and for no level"

# B11
r=$(repo b11 'glab-level: product')
if [ "$(id -u)" -eq 0 ]; then
	done_case B11 "an unreadable AGENTS.md: the project text, exit 0 (skipped: running as root)"
else
	chmod 000 "$r/AGENTS.md"
	hook "$r"
	is_project
	done_case B11 "an unreadable AGENTS.md: the project text, exit 0"
fi

# B12
for v in 'Product' 'product2' 'product # note'; do
	hook "$(repo "b12-$RANDOM" "glab-level: $v")"
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "glab: level \"$v\" is not built in this version of glab; this session runs at the project level" ] ||
		bad "[$v]: no warning first"
	has "$PROJECT_MGR"
done
done_case B12 "a value that is not built - case, digits, a comment - warns and runs as project"

# B13
r=$(repo b13 'glab-level: product')
if command -v git >/dev/null 2>&1 && git -C "$r" init -q 2>/dev/null; then
	mkdir -p "$r/sub/dir"
	hook "$r/sub/dir"
	is_product
	done_case B13 "a session started in a subfolder of its repo: the level read at the repo's top"
else
	done_case B13 "a session started in a subfolder of its repo: the level read at the repo's top (skipped: no git)"
fi

# B14
for a in '' 'glab-level: product'; do
	if [ -n "$a" ]; then r=$(repo "b14-$RANDOM" "$a"); else r=$(repo "b14-none"); fi
	hook "$r" '{"session_id":"abc-123","source":"startup"}'
	has "$ID_PATH"
	hasnt "$NO_ID"
	no_err
done
done_case B14 "a session id: both levels' texts name plan/handoff/<id>.md"

# B15
hook "$(repo b15)"
has "$NO_ID"
hasnt 'plan/handoff/abc'
[ "$TEXT" = "$B1_TEXT" ] || bad "the text differs from B1's"
done_case B15 "no hook input: the no-id line"

# B16: each input that must not give a path - not JSON, no session_id, a number, an empty id, a
# path, a dot first, a newline inside, 129 characters, two JSON values.
long=$(printf 'a%.0s' $(seq 129))
for in in 'not json' '{}' '{"session_id":123}' '{"session_id":""}' '{"session_id":"../x"}' \
	'{"session_id":".x"}' '{"session_id":"a\nb"}' "{\"session_id\":\"$long\"}" '{"session_id":"a"}{"session_id":"b"}'; do
	hook "$(repo "b16-$RANDOM")" "$in"
	has "$NO_ID"
	hasnt 'plan/handoff/.'
	hasnt 'plan/handoff/a'
	no_err
done
done_case B16 "an input with no usable id: the no-id line, no path, exit 0"

# B17
hook "$(repo b17-none)" '{"session_id":"abc-123","source":"compact"}'
r=$(repo b17-start)
[ "$TEXT" = "$(cd "$W" && printf '%s' '{"session_id":"abc-123","source":"startup"}' | CLAUDE_PROJECT_DIR=$r bash "$SCRIPT" 2>/dev/null | jq -r .hookSpecificOutput.additionalContext)" ] ||
	bad "the text after /compact differs from the startup text"
has "$ID_PATH"
done_case B17 "source compact: the same text, and path, as at startup"

# B18: a closed stdin, under timeout so a hang fails the case (rc 124) instead of the run.
r=$(repo b18)
OUT=$(CLAUDE_PROJECT_DIR=$r timeout 10 bash "$SCRIPT" <&- 2>"$W/err")
RC=$?
ERR=$(cat "$W/err")
contract
has "$NO_ID"
no_err
done_case B18 "a closed stdin: exit 0, the no-id line, no hang"

# B19: an id whose only fault is a trailing newline, which $(...) alone would strip.
hook "$(repo b19)" '{"session_id":"abc-123\n"}'
has "$NO_ID"
hasnt 'plan/handoff/abc'
no_err
done_case B19 "an id with a trailing newline: the no-id line, no path"

# B20: the script copied alone, without the glab-level.sh it sources, in a product repo. It must
# still keep the contract and give the project text with the warning; and the same in POSIX mode,
# where a `.` of a missing file would exit the shell with rc 1 (plan level-guard D20).
WARN_LONE='glab: glab-level.sh is missing or unreadable beside manager-bootstrap.sh; this session runs at the project level'
mkdir -p "$W/lone"
cp "$SCRIPT" "$W/lone/manager-bootstrap.sh"
r=$(repo b20 'glab-level: product')
for e in '' 'POSIXLY_CORRECT=1'; do
	if [ -n "$e" ]; then
		OUT=$(CLAUDE_PROJECT_DIR=$r env "$e" bash "$W/lone/manager-bootstrap.sh" </dev/null 2>"$W/err")
	else
		OUT=$(CLAUDE_PROJECT_DIR=$r bash "$W/lone/manager-bootstrap.sh" </dev/null 2>"$W/err")
	fi
	RC=$?
	ERR=$(cat "$W/err")
	contract
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$WARN_LONE" ] || bad "${e:-plain}: the warning is not the first line"
	[ "$(printf '%s\n' "$TEXT" | sed -n 3p)" = "$PROJECT_LINE" ] || bad "${e:-plain}: the project line does not follow the warning"
	has "$PROJECT_MGR"
	[ "$ERR" = "$WARN_LONE" ] || bad "${e:-plain}: stderr [$ERR] is not the warning"
done
done_case B20 "glab-level.sh missing: the project text with the warning, exit 0, POSIX mode too"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
