#!/usr/bin/env bash
# Exercises context-size.sh against fixture transcripts written here; never reads a real transcript.
# Every fixture's user lines hold SECRET=abc, and T2 asserts that no byte of it reaches stdout or
# stderr in any run (the script reads a file that can hold secrets and must pass on only an integer).
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to context-size.sh>" >&2; exit 2; }
# Absolute, because every run below starts from the scratch directory.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap only removes
# the work directory.
trap 'rm -rf "$W"' EXIT
cd "$W" || exit 1

pass=0 fail=0 n=0
reason=''    # why the current case failed; empty while it holds
runs=0 leaks=0
OUT='' ERR='' RC=0

bad() { reason="${reason:+$reason; }$*"; }

# run <stdin> [args...]: runs the script with the given stdin and arguments. Asserts the hook
# contract on every run - rc 0 - and counts any run whose stdout or stderr holds the SECRET marker.
run() {
	local in=$1
	shift
	OUT=$(printf '%s' "$in" | bash "$SCRIPT" "$@" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
	runs=$((runs + 1))
	[ "$RC" -eq 0 ] || bad "rc=$RC for [$*]"
	case "$OUT$ERR" in *SECRET*) leaks=$((leaks + 1)); bad "SECRET reached the output of [$*]" ;; esac
}
# runt <transcript> <mode>: the hook input names the transcript path.
runt() { run "$(jq -n -c --arg p "$1" '{transcript_path: $p}')" "$2"; }

done_case() { # done_case <id> <name> [extra text for the ok line]
	n=$((n + 1))
	if [ -z "$reason" ]; then
		pass=$((pass + 1))
		echo "ok $1 $2${3:+ $3}"
	else
		fail=$((fail + 1))
		echo "FAIL $1 $2: $reason"
	fi
	reason=''
}

expect_no_out() { [ -z "$OUT" ] || bad "stdout not empty: [$OUT]"; }
expect_no_err() { [ -z "$ERR" ] || bad "stderr not empty: [$ERR]"; }
expect_err() { [ "$ERR" = "glab context-size: $1" ] || bad "stderr [$ERR] is not [glab context-size: $1]"; }
# expect_ctx <event> <text>: stdout is one line, one JSON object of the hookSpecificOutput form.
expect_ctx() {
	[ "$(printf '%s\n' "$OUT" | wc -l)" -eq 1 ] || bad "stdout is not one line: [$OUT]"
	jq -e --arg e "$1" --arg t "$2" \
		'keys == ["hookSpecificOutput"] and .hookSpecificOutput.hookEventName == $e and .hookSpecificOutput.additionalContext == $t' \
		<<<"$OUT" >/dev/null 2>&1 || bad "stdout [$OUT] is not the $1 line [$2]"
}

# Fixture lines. A user prompt, a tool result (a user entry that is no prompt), an isMeta user entry,
# an assistant call with a given usage.
P() { printf '{"type":"user","message":{"role":"user","content":"SECRET=abc %s"}}\n' "${1:-hello}"; }
R() { printf '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t","content":"SECRET=abc"}]}}\n'; }
M() { printf '{"type":"user","isMeta":true,"message":{"role":"user","content":"SECRET=abc meta"}}\n'; }
A() { printf '{"type":"assistant","message":{"usage":{"input_tokens":%s,"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}\n' "$1"; }
# fx <name> <line>...: writes the fixture $W/<name>.jsonl and prints its path.
fx() { local f="$W/$1.jsonl"; shift; printf '%s' "$(printf '%s\n' "$@")" >"$f"; printf '\n' >>"$f"; echo "$f"; }
# pad <bytes>: that many 'x' characters, for lines larger than the script's window.
pad() { head -c "$1" /dev/zero | tr '\0' x; }

MSG_TAIL=' — a good point to /compact, or to /clear between tasks'
: >"$W/stopouts"
# T1-T21 test the default first step, 300k, whatever the caller exported; T22-T24 set it themselves.
unset GLAB_COMPACT_AT

# T1 agent, normal transcript
f=$(fx t1 "$(P)" "$(printf '{"type":"assistant","message":{"usage":{"input_tokens":5,"cache_read_input_tokens":142000,"cache_creation_input_tokens":300}}}')" "$(P again)")
runt "$f" agent
expect_ctx PostToolUse 'glab: context 143k (last completed call)'
expect_no_err
done_case T1 "agent: the last call's total, rounded up, in a PostToolUse line"

# T3 prompt, same transcript
runt "$f" prompt
expect_ctx UserPromptSubmit 'glab: context 143k (last completed call)'
expect_no_err
done_case T3 "prompt: the same line with the UserPromptSubmit event"

# T4 missing file
runt "$W/does-not-exist.jsonl" agent
expect_no_out
expect_err 'no readable transcript'
done_case T4 "a missing transcript: no stdout, one stderr line"

# T5 a directory
runt "$W" agent
expect_no_out
expect_err 'no readable transcript'
done_case T5 "a transcript path that is a directory: as a missing one"

# T6 user lines only
f=$(fx t6 "$(P)" "$(P two)")
runt "$f" agent
expect_no_out
expect_err 'no usage in the transcript'
done_case T6 "no assistant usage: no stdout, one stderr line"

# T7 empty file
: >"$W/t7.jsonl"
runt "$W/t7.jsonl" agent
expect_no_out
expect_err 'no usage in the transcript'
done_case T7 "an empty transcript: as no usage"

# T8 truncated last line after a complete assistant entry
f="$W/t8.jsonl"
{ P; A 200000; printf '{"type":"assistant","mess'; } >"$f"
runt "$f" agent
expect_ctx PostToolUse 'glab: context 200k (last completed call)'
expect_no_err
done_case T8 "a truncated last line is dropped; the complete entry's number is used"

# T9 huge: 30 x 1 MB user lines, a 6 MB assistant entry, a user line - past the 8 MiB window
f="$W/t9.jsonl"
{
	for _ in $(seq 30); do printf '{"type":"user","message":{"role":"user","content":"SECRET=abc %s"}}\n' "$(pad 1000000)"; done
	printf '{"type":"assistant","message":{"usage":{"input_tokens":251000,"cache_read_input_tokens":0,"cache_creation_input_tokens":0},"pad":"%s"}}\n' "$(pad 6000000)"
	P last
} >"$f"
size=$(stat -c %s "$f")
t0=$EPOCHREALTIME
runt "$f" agent
t1=$EPOCHREALTIME
expect_ctx PostToolUse 'glab: context 251k (last completed call)'
expect_no_err
[ "$size" -gt 36000000 ] || bad "fixture is only $size bytes"
done_case T9 "a file past the window, with a 6 MB assistant line" "($size bytes, $(awk -v a="$t0" -v b="$t1" 'BEGIN { printf "%.2f", b - a }')s, not asserted)"
rm -f "$f"

# T10 an assistant entry longer than the window, every other assistant entry outside it
f="$W/t10.jsonl"
{
	P
	A 150000
	printf '{"type":"assistant","message":{"usage":{"input_tokens":251000,"cache_read_input_tokens":0,"cache_creation_input_tokens":0},"pad":"%s"}}\n' "$(pad 9000000)"
} >"$f"
runt "$f" agent
expect_no_out
expect_err 'no usage in the transcript'
done_case T10 "an assistant entry longer than the window: silence, not a wrong number"
rm -f "$f"

# T11 malformed stdin
run 'not json{' agent
expect_no_out
expect_err 'hook input is not JSON'
[ "$(printf '%s\n' "$ERR" | wc -l)" -eq 1 ] || bad "stderr is not one line: [$ERR]"
done_case T11 "malformed stdin: exactly one stderr line, jq's own error not printed"

# T12 empty stdin, {}, and a non-string transcript_path
for in in '' '{}' '{"transcript_path": 7}'; do
	run "$in" agent
	[ -z "$OUT" ] || bad "input [$in]: stdout [$OUT]"
	[ "$ERR" = 'glab context-size: no readable transcript' ] || bad "input [$in]: stderr [$ERR]"
done
done_case T12 "empty stdin, {} and a numeric transcript_path: no readable transcript"

# T13 7 tokens
f=$(fx t13 "$(P)" "$(A 7)")
runt "$f" agent
expect_ctx PostToolUse 'glab: context 1k (last completed call)'
done_case T13 "7 tokens print 1k, never 0k"

# T14 the last assistant entry has zero usage
f=$(fx t14 "$(P)" "$(A 200000)" "$(P two)" "$(A 0)")
runt "$f" agent
expect_ctx PostToolUse 'glab: context 200k (last completed call)'
done_case T14 "a zero-usage entry does not hide the last real call"

# T15 the last assistant entry is a sidechain
f=$(fx t15 "$(P)" "$(A 200000)" "$(P two)" '{"type":"assistant","isSidechain":true,"message":{"usage":{"input_tokens":900000,"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}')
runt "$f" agent
expect_ctx PostToolUse 'glab: context 200k (last completed call)'
done_case T15 "a subagent's entry is not the main conversation's size"

# T16 unknown mode, and no mode
run '{}' foo
expect_no_out
[ "$ERR" = 'glab context-size: unknown mode: foo' ] || bad "mode foo: stderr [$ERR]"
run '{}'
[ -z "$OUT" ] || bad "no mode: stdout [$OUT]"
[ "$ERR" = 'glab context-size: unknown mode: ' ] || bad "no mode: stderr [$ERR]"
done_case T16 "an unknown mode and no mode are failures like any other"

# T17 no jq: a PATH of links to bash, env and tail and nothing else
mkdir -p "$W/nojq"
for tool in bash env tail; do ln -s "$(command -v "$tool")" "$W/nojq/$tool"; done
f=$(fx t17 "$(P)" "$(A 1000)")
OUT=$(printf '%s' "{\"transcript_path\":\"$f\"}" | PATH="$W/nojq" "$W/nojq/bash" "$SCRIPT" agent 2>"$W/err")
RC=$?
ERR=$(cat "$W/err")
runs=$((runs + 1))
[ "$RC" -eq 0 ] || bad "rc=$RC"
case "$OUT$ERR" in *SECRET*) leaks=$((leaks + 1)); bad "SECRET reached the output" ;; esac
expect_no_out
expect_err 'jq not found'
done_case T17 "no jq: no stdout, one stderr line"

# T18 stop cases. Each fixture is the transcript as it stands when Stop runs, not as it stands after:
# the turn's own prompt is written, the turn's last call is not yet (I1b, flow-cheaper-rounds/plan.md
# F23). So the base is the size at the real prompt before the last one, one turn further back than
# the turn's own prompt. Each: name, expected ('' for nothing, else the number printed), fixture.
# stop_case <name> <expected k or ''> <line>...
# SUFFIX, empty unless a case sets it, is what a valid GLAB_COMPACT_AT adds before the line's `)`.
stop_case() {
	local name=$1 want=$2 file
	shift 2
	file=$(fx "stop-$n-$RANDOM" "$@")
	runt "$file" stop
	printf '%s\n' "$OUT" >>"$W/stopouts"
	if [ -z "$want" ]; then
		[ -z "$OUT" ] || bad "$name: expected nothing, got [$OUT]"
	else
		jq -e --arg t "glab: context ${want}k (last completed call${SUFFIX:-})$MSG_TAIL" \
			'keys == ["systemMessage"] and .systemMessage == $t' <<<"$OUT" >/dev/null 2>&1 \
			|| bad "$name: expected the ${want}k message with only systemMessage, got [$OUT]"
	fi
	[ -z "$ERR" ] || bad "$name: stderr [$ERR]"
}
# stop_spec <name> <expected k or ''> <spec>: the spec is words, P a prompt, R a tool_result,
# M an isMeta entry, A<n> an assistant call of n input tokens.
stop_spec() {
	local name=$1 want=$2 t
	local -a lines=()
	for t in $3; do
		case $t in
			P) lines+=("$(P)") ;;
			R) lines+=("$(R)") ;;
			M) lines+=("$(M)") ;;
			A*) lines+=("$(A "${t#A}")") ;;
		esac
	done
	stop_case "$name" "$want" "${lines[@]}"
}
stop_spec 'below 300k' '' 'P A100000 P R A200000'
stop_spec 'the turn before crossed 300k, its last call written after its Stop' 310 'A250000 P A280000 R A310000 P'
stop_spec 'this turn crossed 300k at a call before its last' 310 'A250000 P A260000 P A280000 R A310000 R'
stop_spec 'already past 300k in the same step' '' 'A310000 P A350000 P A360000'
stop_spec 'crossed 400k' 401 'A390000 P A395000 P A401000'
stop_spec 'dropped after a compact' '' 'A500000 P A40000 P A45000'
stop_spec 'no prompt in the window, 420k' 420 'A420000'
# One prompt in the window: fewer than two, so the base is 0 and it speaks at or past 300k.
stop_spec 'one prompt in the window, 430k' 430 'A420000 P A430000'
# The crossing lies two prompts back: the earlier Stop showed it, it is not shown again.
stop_spec 'a crossing two prompts back is not shown again' '' 'A250000 P A310000 P A320000 P'
# A tool_result is no prompt: counted as one it would move the base past the crossing (then '').
stop_spec 'a tool_result after the crossing' 330 'P A250000 P A310000 R A320000 P A330000'
# An isMeta entry is no prompt either, the same with M.
stop_spec 'an isMeta entry after the crossing' 330 'P A250000 P A310000 M A320000 P A330000'
done_case T18 "stop: speaks when the step rose since the prompt before the last, only with systemMessage, and not otherwise"

# T20 a lagging session, as I1b saw it: at each Stop the turn's last call is missing. A prefix turn
# (so that no snapshot is empty of usage), then one call per turn - 250000, 280000, 310000 (the
# crossing, turn 3), 320000, 330000. The snapshot at Stop of turn t is the prefix, the turns before t
# whole, and t's prompt alone.
pre='P A200000'
stop_spec 'T20 stop 1' '' "$pre P"
stop_spec 'T20 stop 2' '' "$pre P A250000 P"
stop_spec 'T20 stop 3, the crossing turn, its 310000 not written yet' '' "$pre P A250000 P A280000 P"
stop_spec 'T20 stop 4, the turn after' 310 "$pre P A250000 P A280000 P A310000 P"
stop_spec 'T20 stop 5' '' "$pre P A250000 P A280000 P A310000 P A320000 P"
done_case T20 "stop, lagging transcript: speaks once, on the turn after the crossing"

# T21 a crossing already written at its own turn's Stop speaks then and once more, never a third
# time. Same prefix and sizes. In time: each snapshot ends with the turn's own call.
stop_spec 'T21 in time, stop 2' '' "$pre P A250000 P A280000"
stop_spec 'T21 in time, stop 3' 310 "$pre P A250000 P A280000 P A310000"
stop_spec 'T21 in time, stop 4 (the accepted repeat)' 320 "$pre P A250000 P A280000 P A310000 P A320000"
stop_spec 'T21 in time, stop 5' '' "$pre P A250000 P A280000 P A310000 P A320000 P A330000"
# Not the turn's last call, lagging: turn 3 makes three calls, A290000 R A310000 R A315000, and its
# 315000 is missing at its own Stop.
stop_spec 'T21 not last, stop 3' 310 "$pre P A250000 P A280000 P A290000 R A310000 R"
stop_spec 'T21 not last, stop 4' 315 "$pre P A250000 P A280000 P A290000 R A310000 R A315000 P"
stop_spec 'T21 not last, stop 5' '' "$pre P A250000 P A280000 P A290000 R A310000 R A315000 P A320000 P"
done_case T21 "stop, a crossing already written at its own Stop: speaks then and once more, never a third time"

# T22 GLAB_COMPACT_AT set: the line names the first step, in both context modes. T1's fixture.
export GLAB_COMPACT_AT=150
runt "$W/t1.jsonl" agent
expect_ctx PostToolUse 'glab: context 143k (last completed call; compact at 150k)'
expect_no_err
runt "$W/t1.jsonl" prompt
expect_ctx UserPromptSubmit 'glab: context 143k (last completed call; compact at 150k)'
expect_no_err
unset GLAB_COMPACT_AT
done_case T22 "GLAB_COMPACT_AT=150: agent and prompt lines end '; compact at 150k)'"

# T23 GLAB_COMPACT_AT moves the first step of stop; the steps after it stay 100k apart.
export GLAB_COMPACT_AT=150
SUFFIX='; compact at 150k'
stop_spec 'below 150k' '' 'P A100000 P R A140000'
stop_spec 'crossed 150k' 160 'A140000 P A145000 P A160000'
stop_spec 'same step' '' 'A160000 P A200000 P A240000'
stop_spec 'crossed 250k' 251 'A240000 P A245000 P A251000'
SUFFIX=''
unset GLAB_COMPACT_AT
done_case T23 "stop with GLAB_COMPACT_AT=150: speaks at 150k and 250k, with the suffix, and not between"

# T24 an invalid GLAB_COMPACT_AT warns once on stderr and the run goes on with the default; empty is
# unset, with no warning.
WARN='GLAB_COMPACT_AT is not a whole number of thousands from 1 to 999999; using 300'
for v in abc 0 1234567 15.5 -1; do
	export GLAB_COMPACT_AT="$v"
	runt "$W/t1.jsonl" agent
	jq -e --arg t 'glab: context 143k (last completed call)' \
		'keys == ["hookSpecificOutput"] and .hookSpecificOutput.additionalContext == $t' \
		<<<"$OUT" >/dev/null 2>&1 || bad "[$v]: stdout [$OUT] is not the default line"
	[ "$ERR" = "glab context-size: $WARN" ] || bad "[$v]: stderr [$ERR] is not the warning"
done
# stop speaks on the default step, so not through stop_case, which wants stderr empty.
export GLAB_COMPACT_AT=abc
runt "$(fx t24-stop "$(A 250000)" "$(P)" "$(A 280000)" "$(P)" "$(A 310000)")" stop
printf '%s\n' "$OUT" >>"$W/stopouts"
jq -e --arg t "glab: context 310k (last completed call)$MSG_TAIL" \
	'keys == ["systemMessage"] and .systemMessage == $t' <<<"$OUT" >/dev/null 2>&1 \
	|| bad "[abc] stop: expected the 310k default message, got [$OUT]"
[ "$ERR" = "glab context-size: $WARN" ] || bad "[abc] stop: stderr [$ERR] is not the warning"
export GLAB_COMPACT_AT=
runt "$W/t1.jsonl" agent
expect_ctx PostToolUse 'glab: context 143k (last completed call)'
expect_no_err
unset GLAB_COMPACT_AT
done_case T24 "an invalid GLAB_COMPACT_AT: one warning, the default line; empty: no warning"

# T19 stop never blocks or continues - judged over every stop run above: T18's, T20's, T21's and T23's through stop_case, and T24's own
if /usr/bin/grep -q -E 'decision|continue|reason|hookSpecificOutput|additionalContext' "$W/stopouts"; then
	bad "a stop output holds a blocking or context key: $(/usr/bin/grep -E 'decision|continue|reason|hookSpecificOutput|additionalContext' "$W/stopouts" | head -n 1)"
fi
[ "$(/usr/bin/grep -c '^{' "$W/stopouts")" -ge 5 ] || bad "fewer than five stop messages were produced, so this case proved little"
done_case T19 "stop never blocks or continues: no decision, continue, reason or context key in any output"

# T2 last: it is judged over every run above
[ "$leaks" -eq 0 ] || bad "$leaks runs let the SECRET marker through"
done_case T2 "no byte of a fixture's user lines reached stdout or stderr" "($runs runs)"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
