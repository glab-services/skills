#!/usr/bin/env bash
#
# The glab context hook: tells a session how large its context is, and tells the user when a turn
# crosses a size worth a /compact. One script, three events, chosen by the mode argument as
# memory-sync.sh chooses by its modes (plugins/glab/hooks/hooks.json wires them):
#
#   context-size.sh prompt   # UserPromptSubmit: adds one line to the model's context with every
#                            # message the user sends
#   context-size.sh agent    # PostToolUse, matcher Agent: adds the same line after every subagent
#                            # dispatch, so glab:manager has a fresh number for its handoff line
#   context-size.sh stop     # Stop: shows the USER one line when the context has crossed 300k or a
#                            # further 100k (400k, 500k, ...) - usually at the end of the turn
#                            # after the crossing, see the `stop` comment; says nothing otherwise
#
# The line is `glab: context <n>k (last completed call)`, n in thousands, rounded up.
#
# Why three events and why `stop` speaks to the user: a hook fires every time, whatever the model
# does, but it cannot make the model act - `additionalContext` is text the model may ignore. So the
# one message that must not depend on the model (go and /compact) goes to the person who can run
# /compact or /clear, and `glab:manager` Rule 2 ("Your own context") makes the model act on the
# number the other two modes give it. Neither /compact nor /clear can be run by the model.
#
# Contract, like memory-sync.sh's (AGENTS.md *Rules*): exit 0 on every path; on stdout either
# exactly one JSON object or nothing; every failure is one line on stderr, `glab context-size:
# <reason>`, and no JSON. An unknown or missing mode is a failure like any other. The JSON is built
# by `jq -n --arg`, never by printf, so no text can break out of it. In mode `stop` the only key is
# `systemMessage`: it never blocks a turn and never asks for another one - no exit 2, no
# `decision`, no `reason`, no `continue`, no `hookSpecificOutput`, and nothing reads
# `stop_hook_active`, because nothing here ever asks for a further turn.
#
# The measure: the size of the last completed model call of the MAIN conversation, as
# input + cache-read + cache-creation tokens - that is what the next call has to carry. An entry
# whose usage sums to 0 is no model call and is skipped, and so is a subagent's entry
# (isSidechain) in case the transcript holds them. "Last completed" because the transcript is
# written asynchronously and may lag (documented for Stop), so the call in flight may not be in the
# file yet; the number trails by at most one call, and the line says so. Seen in a live session
# [flow-cheaper-rounds/plan.md F23]: at PostToolUse on Agent the calling call is already written; at
# Stop the turn's last call is not yet.
#
# It reads only the transcript Claude Code names on stdin (`transcript_path`), read-only, and only
# the last 8 MiB of it: `tail` seeks, so the cost does not grow with the file, and jq folds the
# window one line at a time, so memory holds one line. A transcript line can run to several MB, so
# 8 MiB holds more than the largest line seen; an assistant entry longer than the window is not
# seen, and then an older call's figure prints, or nothing. It writes no file, keeps no state,
# opens no network connection, and prints only an integer and fixed words: no byte of the
# transcript, of `tool_input`, of `tool_response` or of `prompt` reaches stdout or stderr.
#
# It runs in every session of every repo where glab is enabled, manager or not. That is harmless:
# `prompt` and `agent` add one line of about ten tokens, `stop` prints a line to the user once per
# crossing of a 100k step, twice at most (see the `stop` comment), and every failure is silent on
# stdout. One case keeps that bound from holding: with fewer than two real prompts inside the 8 MiB
# window `stop` has no base (0) and speaks at every turn end while the context is at or past 300k.
# That needs more than 8 MiB of transcript between two consecutive prompts - one turn of very large
# tool results - and it stops with the next ordinary turn, which puts two prompts back in the
# window. Accepted: the window is what bounds the read cost, and a line too many is the cheaper
# error [flow-cheaper-rounds review round 1].
#
# `jq` is required. Without it the script cannot read the input or the transcript, so it prints
# nothing (unlike manager-bootstrap.sh, which can fall back to plain text), and glab:manager counts
# dispatches instead.
set -uo pipefail
# No -e: every path must reach `exit 0`, and a failed read is a message, not a crash.

MODE=${1:-}

fail() { printf 'glab context-size: %s\n' "$1" >&2; exit 0; }

case "$MODE" in
	prompt | agent | stop) ;;
	*) fail "unknown mode: $MODE" ;;
esac

command -v jq >/dev/null 2>&1 || fail 'jq not found'

# stderr to /dev/null so a malformed input prints only our own line below, never jq's parse error.
tp=$(jq -r '.transcript_path // empty | strings' 2>/dev/null) || fail 'hook input is not JSON'
{ [ -n "$tp" ] && [ -f "$tp" ] && [ -r "$tp" ]; } || fail 'no readable transcript'

# Prints `<k> <cur> <base>`: k the last real call's size in thousands rounded up, cur that size, and
# base the size when the real user prompt before the last one arrived (a real prompt: a user entry,
# not a sidechain, not isMeta, not a tool_result; `last` holds the size at the latest one). `stop`
# compares with base, one turn further back than the turn's own prompt - see the `stop` comment.
# Nothing when there is no real call in the window.
# 8388608 is 8 MiB, see above. `fromjson?` drops the window's partial first line and a truncated
# last line silently. `numbers` keeps a non-numeric usage field from aborting the whole program.
# +999 before the integer division by 1000 rounds up, so a real value never prints `0k`.
# jq's stderr goes to /dev/null so no line of the transcript can reach ours.
res=$(tail -c 8388608 -- "$tp" 2>/dev/null | jq -n -R -r '
	def n(f): (f | numbers) // 0;
	def total: n(.input_tokens) + n(.cache_read_input_tokens) + n(.cache_creation_input_tokens);
	reduce (inputs | fromjson? | objects | select(.isSidechain != true)) as $e ({last: 0, base: 0, cur: null};
		($e | (.message | objects | .usage | objects) // null) as $u
		| ($e | (.message | objects | .content) // null) as $c
		| if $e.type == "assistant" and $u != null and ($u | total) > 0 then
			.cur = ($u | total)
		elif $e.type == "user" and $e.isMeta != true
			and (($c | type) == "string"
				or (($c | type) == "array" and ([$c[] | select(type == "object" and .type == "tool_result")] | length) == 0)) then
			.base = .last | .last = (.cur // 0)
		else . end)
	| if .cur == null then empty
	  else "\(((.cur + 999) / 1000) | floor) \(.cur | floor) \(.base | floor)" end
' 2>/dev/null)
[ -n "$res" ] || fail 'no usage in the transcript'

read -r k cur base <<<"$res"
# At most 15 digits: bash integer arithmetic must never see a float, an exponent or an overflow,
# or the script would die with a non-zero status instead of reaching `exit 0`.
for v in "$k" "$cur" "$base"; do
	[[ $v =~ ^[0-9]{1,15}$ ]] || fail 'no usage in the transcript'
done

line="glab: context ${k}k (last completed call)"

case "$MODE" in
	prompt)
		jq -n -c --arg c "$line" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $c}}'
		;;
	agent)
		jq -n -c --arg c "$line" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $c}}'
		;;
	stop)
		# step(x): -1 below 300000, else how many whole 100000s lie past 300000 - 300k is the size at
		# which the rounds of an agent that carries its whole history already cost several times a
		# fresh agent's, and 100k keeps a declined suggestion from repeating on every turn. Speaks
		# when the latest written call is in a higher step than the size at the real prompt before the
		# last one; stateless, so no file remembers a suggestion.
		# Why one turn further back than the turn's own prompt: when Stop runs, the transcript does
		# not yet hold the turn's last call. Seen in a live session
		# [flow-cheaper-rounds/plan.md F23]: at Stop the transcript still ended with the previous
		# turn's figure, the same as at the turn's prompt, and one second later it held the turn's
		# own; compared with the turn's own prompt, a turn of one call compared a number with itself
		# and never spoke. So a crossing usually shows at the end of the turn after it. When the
		# crossing call is already written at its own turn's Stop - written in time, or not the
		# turn's last call - it shows then and once more on the next turn: accepted, a line too many
		# rather than a missed one. Rejected: waiting in the hook for the write (up to a second at
		# every turn end) and a state file per session.
		step_cur=-1
		step_base=-1
		[ "$cur" -ge 300000 ] && step_cur=$(((cur - 300000) / 100000))
		[ "$base" -ge 300000 ] && step_base=$(((base - 300000) / 100000))
		if [ "$step_cur" -gt "$step_base" ]; then
			jq -n -c --arg c "$line — a good point to /compact, or to /clear between tasks" '{systemMessage: $c}'
		fi
		;;
esac

exit 0
