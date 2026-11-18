#!/usr/bin/env bash
# Exercises level-guard.sh, the PreToolUse hook, against repos written here under $TMPDIR: mode
# skill, which refuses a Skill call to a glab skill not on the list of the session's level, and
# mode bash, which sends a `plan-gate.sh verdict … user …` command to the permission dialog.
# It judges against the plugin tree beside the script under test ($(dirname "$SCRIPT")/..), so the
# lists are the real ones, read from each manager's *Your skills — this level only*: LG1 and LG2
# fail at the gate when a list stops parsing, a bullet wrapped onto a second line included.
# Every run must keep the hook contract - exit 0, stdout one JSON object whose only key is
# hookSpecificOutput or nothing, and only deny in mode skill, only ask in mode bash.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to level-guard.sh>" >&2; exit 2; }
# Absolute, because the runs below start from other directories.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
SK=$(dirname "$SCRIPT")/../skills
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/level-guard-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap removes the
# work directory.
trap 'rm -rf "$W"' EXIT
cd "$W" || exit 1

pass=0 fail=0 n=0
reason='' # why the current case failed; empty while it holds
OUT='' ERR='' RC=0 MODE=''
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

# The exact lines the hook prints: the deny for glab:project-plan at the product level, and the
# ask. Both are registered in docs/one-fact.md (*The `glab` guard hook*).
DENY_PP='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"glab: glab:project-plan is not a skill of the product level (the glab-level line of the repo'\''s AGENTS.md; no line is the project level). Use only the skills glab:product-manager lists under Your skills. The user can still type /glab:project-plan to run it."}}'
ASK='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"glab: a verdict by user. Approve only if this verdict is your own decision and its reason file opens with your words (glab:product-manager, The cap)."}}'

# repo <name> [AGENTS.md text]: a repo folder, with that AGENTS.md when a text is given.
repo() {
	mkdir -p "$W/$1"
	if [ $# -gt 1 ]; then printf '%s\n' "$2" >"$W/$1/AGENTS.md"; fi
	echo "$W/$1"
}
# skill_in <name> / bash_in <command>: the hook input of a Skill call and of a Bash call.
skill_in() { jq -cn --arg s "$1" '{session_id:"t",hook_event_name:"PreToolUse",tool_name:"Skill",tool_input:{skill:$s},tool_use_id:"toolu_t"}'; }
bash_in() { jq -cn --arg c "$1" '{session_id:"t",hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$c,description:"d"},tool_use_id:"toolu_t"}'; }
# guard <mode> <repo or -> <stdin text> [script]: runs the hook with CLAUDE_PROJECT_DIR set to the
# repo (unset for -) and that text on stdin; sets OUT, ERR and RC, then checks the contract.
# GUARD_PATH, when set, is the PATH of the script under test only: the contract check runs
# afterwards in this shell, with the test's own PATH and jq. GUARD_ENV, when set, is put before
# the command by env (POSIXLY_CORRECT=1).
guard() {
	local -a cmd=(bash "${4:-$SCRIPT}" "$1")
	[ -z "${GUARD_ENV:-}" ] || cmd=(env "$GUARD_ENV" "${cmd[@]}")
	MODE=$1
	if [ "$2" = - ]; then
		OUT=$(printf '%s' "$3" | PATH=${GUARD_PATH:-$PATH} env -u CLAUDE_PROJECT_DIR "${cmd[@]}" 2>"$W/err")
	else
		OUT=$(printf '%s' "$3" | PATH=${GUARD_PATH:-$PATH} CLAUDE_PROJECT_DIR=$2 "${cmd[@]}" 2>"$W/err")
	fi
	RC=$?
	ERR=$(cat "$W/err")
	contract
}
contract() {
	local want=''
	[ "$RC" -eq 0 ] || bad "rc=$RC"
	[ -n "$OUT" ] || return 0
	[ "$(jq -s length <<<"$OUT" 2>/dev/null)" = 1 ] || bad "stdout is not one JSON value: [${OUT:0:120}]"
	jq -e 'keys == ["hookSpecificOutput"] and (.hookSpecificOutput | keys == ["hookEventName","permissionDecision","permissionDecisionReason"]) and .hookSpecificOutput.hookEventName == "PreToolUse"' \
		<<<"$OUT" >/dev/null 2>&1 || bad "stdout is not one PreToolUse object: [${OUT:0:120}]"
	case $MODE in skill) want=deny ;; bash) want=ask ;; esac
	if [ -z "$want" ] || [ "$(decision)" != "$want" ]; then bad "mode [$MODE] printed decision [$(decision)]"; fi
}
# decision: the decision OUT holds, none when it is empty.
decision() {
	if [ -z "$OUT" ]; then echo none; else jq -r '.hookSpecificOutput.permissionDecision // "none"' <<<"$OUT" 2>/dev/null; fi
}
is_dec() { [ "$(decision)" = "$1" ] || bad "[$2]: decision $(decision), not $1"; } # is_dec <decision> <label>
is_out() { [ "$OUT" = "$1" ] || bad "[$2]: stdout [${OUT:0:120}] is not the pinned line"; } # is_out <line> <label>
no_err() { [ -z "$ERR" ] || bad "[$1]: stderr not empty: [$ERR]"; }
# nojq_path: $W/bin, a PATH without jq. Links by type -P, never command -v: in an interactive
# shell grep can be a function. env is there for guard's env forms, which a PATH= prefix makes
# look up in this PATH.
nojq_path() {
	local t p
	mkdir -p "$W/bin"
	for t in bash cat cut git grep sed tr awk env; do
		[ -e "$W/bin/$t" ] && continue
		p=$(type -P "$t") && ln -s "$p" "$W/bin/$t"
	done
	[ -z "$(PATH=$W/bin command -v jq)" ] || bad "jq is still on the test PATH"
}

PROD=$(repo product 'glab-level: product')
PROJ=$(repo project)

# LG1
for d in "$SK"/*/; do
	s=glab:$(basename "$d")
	guard skill "$PROD" "$(skill_in "$s")"
	case $s in glab:project-*) is_dec deny "$s" ;; *) is_dec none "$s" ;; esac
	no_err "$s"
done
done_case LG1 "product level: every product and unprefixed skill passes, every project skill is refused"

# LG2
for d in "$SK"/*/; do
	s=glab:$(basename "$d")
	guard skill "$PROJ" "$(skill_in "$s")"
	case $s in glab:product-*) is_dec deny "$s" ;; *) is_dec none "$s" ;; esac
done
done_case LG2 "project level (no AGENTS.md): every project and unprefixed skill passes, every product skill is refused"

# LG3: each repo, the level it must give.
# The last one puts product first, so a read that took the last line instead of the first fails.
for spec in "project|glab-level: project" "project|glab-level: delivery" "product|glab-level: product"$'\r' \
	"product|glab-level: product"$'\n'"glab-level: project"; do
	want=${spec%%|*}
	r=$(repo "lg3-$RANDOM" "${spec#*|}")
	for s in glab:product-plan glab:project-plan; do
		guard skill "$r" "$(skill_in "$s")"
		if [ "$s" = "glab:$want-plan" ]; then is_dec none "$want: $s"; else is_dec deny "$want: $s"; fi
		no_err "$want: $s"
	done
done
done_case LG3 "the level line: project, delivery, CRLF product, only the first line"

# LG4
r=$(repo lg4 'glab-level: product')
if command -v git >/dev/null 2>&1 && git -C "$r" init -q 2>/dev/null; then
	mkdir -p "$r/sub"
	guard skill "$r/sub" "$(skill_in glab:project-plan)"
	is_out "$DENY_PP" sub
	done_case LG4 "a session started in a subfolder: the level read at the repo's top"
else
	done_case LG4 "a session started in a subfolder: the level read at the repo's top (skipped: no git)"
fi

# LG5
cd "$PROD" || exit 1
guard skill - "$(skill_in glab:project-plan)"
is_out "$DENY_PP" PWD
cd "$W" || exit 1
done_case LG5 "CLAUDE_PROJECT_DIR unset: the level read from \$PWD"

# LG6
guard skill "$PROD" "$(skill_in glab:project-plan)"
is_out "$DENY_PP" glab:project-plan
no_err glab:project-plan
done_case LG6 "the deny object, exactly"

# LG7
for s in code-review anthropic-skills:pdf other-plugin:project-plan apps/web:deploy init \
	glab:no-such-skill glab:product-planner Glab:project-plan; do
	guard skill "$PROD" "$(skill_in "$s")"
	is_dec none "$s"
	no_err "$s"
done
done_case LG7 "names that are not glab's get no decision"

# LG8
# The last three: a leading no-break space, a trailing U+3000 and a leading BOM, which the Skill
# tool's trim() drops (review round 2).
for s in project-plan /glab:project-plan /project-plan ' glab:project-plan ' $'\tproject-plan' \
	$'\u00a0glab:project-plan' $'glab:project-plan\u3000' $'\ufeffglab:project-plan'; do
	guard skill "$PROD" "$(skill_in "$s")"
	is_out "$DENY_PP" "$s"
done
guard skill "$PROD" "$(skill_in audit)"
is_dec none audit
done_case LG8 "a bare, slashed or padded glab name is judged as glab:<name>"

# LG9
guard skill "$PROD" "$(skill_in glab:project-plan | jq -c '. + {agent_id:"a1",agent_type:"general-purpose"}')"
is_out "$DENY_PP" subagent
done_case LG9 "a subagent's call is judged the same"

# LG10
guard skill "$PROD" "$(skill_in glab:project-plan | jq -c --arg c "$PROJ" '. + {cwd:$c}')"
is_out "$DENY_PP" cwd
done_case LG10 "the input's cwd is not the level"

# LG11
for in in '' 'not json' '{}' '{"tool_input":{}}' '{"tool_input":{"skill":7}}' '[]'; do
	guard skill "$PROD" "$in"
	is_dec none "$in"
done
done_case LG11 "input it cannot read gives no decision"

# LG12: under timeout, so a hang fails the case (rc 124) instead of the run.
OUT=$(CLAUDE_PROJECT_DIR=$PROD timeout 10 bash "$SCRIPT" skill <&- 2>"$W/err")
RC=$?
ERR=$(cat "$W/err")
MODE=skill
contract
[ -z "$OUT" ] || bad "stdout not empty: [${OUT:0:120}]"
done_case LG12 "a closed stdin: no decision, no hang"

# LG13
nojq_path
GUARD_PATH=$W/bin
guard skill "$PROD" "$(skill_in glab:project-plan)"
is_out "$DENY_PP" glab:project-plan
guard skill "$PROD" "$(skill_in glab:product-plan)"
is_dec none glab:product-plan
unset GUARD_PATH
done_case LG13 "a PATH without jq: the same decisions from the raw input"

# LG14: a copy of the tree whose product list has lost its heading.
mkdir -p "$W/plug/scripts"
cp "$SCRIPT" "$W/plug/scripts/level-guard.sh"
cp "$(dirname "$SCRIPT")/glab-level.sh" "$W/plug/scripts/glab-level.sh"
cp -R "$SK" "$W/plug/skills"
f=$W/plug/skills/product-manager/SKILL.md
sed 's/^## Your skills — this level only$/## Skills/' "$f" >"$W/pm.md" && mv "$W/pm.md" "$f"
[ "$(grep -c '^## Skills$' "$f")" = 1 ] || bad "the copy's heading was not replaced"
guard skill "$PROD" "$(skill_in glab:project-plan)" "$W/plug/scripts/level-guard.sh"
is_dec none glab:project-plan
[ "$(printf '%s\n' "$ERR" | wc -l)" -eq 1 ] || bad "stderr is not one line: [$ERR]"
case $ERR in 'glab: level-guard: cannot read the skill list of the product level'*) ;; *) bad "stderr [$ERR]" ;; esac
done_case LG14 "a list it cannot parse: no decision, one stderr line"

# LG15: a copy of the tree with the list intact and no glab-level.sh.
mkdir -p "$W/plug15/scripts"
cp "$SCRIPT" "$W/plug15/scripts/level-guard.sh"
cp -R "$SK" "$W/plug15/skills"
for GUARD_ENV in '' 'POSIXLY_CORRECT=1'; do
	guard skill "$PROD" "$(skill_in glab:project-plan)" "$W/plug15/scripts/level-guard.sh"
	is_dec none "${GUARD_ENV:-plain}"
	[ "$(printf '%s\n' "$ERR" | wc -l)" -eq 1 ] || bad "${GUARD_ENV:-plain}: stderr is not one line: [$ERR]"
	case $ERR in *'glab-level.sh is missing or unreadable; glab:project-plan not judged'*) ;; *) bad "${GUARD_ENV:-plain}: stderr [$ERR]" ;; esac
done
unset GUARD_ENV
done_case LG15 "glab-level.sh missing: no decision, one stderr line, exit 0, POSIX mode too"

# LG16
for m in '' foo; do
	guard "$m" "$PROD" "$(skill_in glab:project-plan)"
	[ -z "$OUT" ] || bad "[$m]: stdout not empty: [${OUT:0:120}]"
	[ "$ERR" = 'glab: level-guard: usage: level-guard.sh skill|bash' ] || bad "[$m]: stderr [$ERR]"
done
done_case LG16 "no mode or an unknown mode: usage on stderr, exit 0"

# LG17
V_USER='"/p/plugins/glab/scripts/plan-gate.sh" verdict /s p ACCEPTED user /r.md'
guard bash "$PROD" "$(bash_in "$V_USER")"
is_out "$ASK" "$V_USER"
no_err "$V_USER"
done_case LG17 "a verdict by user asks, exactly"

# LG18
for c in '/p/plan-gate.sh verdict /s p REJECTED user /r' "/p/plan-gate.sh verdict /s p REJECTED 'user' /r" \
	'/p/plan-gate.sh verdict /s p REJECTED "user" /r' $'/p/plan-gate.sh verdict \\\n/s p REJECTED \\\nuser /r' \
	'bash /p/plan-gate.sh verdict /s p ACCEPTED user /r' 'cd /a && /p/plan-gate.sh verdict /s p ACCEPTED user /r'; do
	guard bash "$PROD" "$(bash_in "$c")"
	is_out "$ASK" "$c"
done
done_case LG18 "every spelling of a by-user verdict asks"

# LG19
# V_HOME asks since review round 1 (a slash is a word boundary, plan level-guard D25): LG25 pins it.
V_HOME='/p/plan-gate.sh verdict /home/user/s p ACCEPTED product-manager /t/user-reason.md'
for c in '/p/plan-gate.sh verdict /s p ACCEPTED product-manager /r' '/p/plan-gate.sh verdict /s p ACCEPTED product-manager /t/user-reason.md' \
	'/p/plan-gate.sh report plan/x /s' '/p/plan-gate.sh check plan/x /s' 'echo verdict user' 'ls -la'; do
	guard bash "$PROD" "$(bash_in "$c")"
	is_dec none "$c"
done
done_case LG19 "commands that are not a by-user verdict pass"

# LG20
guard bash "$PROD" "$(jq -cn '{tool_name:"Bash",tool_input:{command:"ls",description:"plan-gate.sh verdict user"}}')"
is_dec none description
guard bash "$PROD" "$(jq -cn '{tool_name:"Bash",tool_input:{command:"echo verdict user",description:"plan-gate.sh"}}')"
is_dec none 'plan-gate.sh in the description only'
done_case LG20 "only the command is read, not the description"

# LG21: the /home/user line asks here - the documented over-match, pinned.
nojq_path
GUARD_PATH=$W/bin
guard bash "$PROD" "$(bash_in "$V_USER")"
is_out "$ASK" "$V_USER"
guard bash "$PROD" "$(bash_in 'ls -la')"
is_dec none 'ls -la'
guard bash "$PROD" "$(bash_in "$V_HOME")"
is_out "$ASK" "$V_HOME"
guard bash "$PROD" "$(bash_in '/p/plan-gate.sh check plan/x /s')"
is_dec none 'check, no jq'
guard bash "$PROD" "$(bash_in '/p/plan-gate.sh verdict /s p ACCEPTED product-manager /r')"
is_dec none 'verdict without user, no jq'
unset GUARD_PATH
done_case LG21 "a PATH without jq: the raw input, words anywhere"

# LG22
guard bash "$PROD" 'not json'
is_dec none 'not json'
guard bash "$PROD" 'x plan-gate.sh verdict s p ACCEPTED user r'
is_out "$ASK" 'raw verdict'
done_case LG22 "input that is not JSON"

# LG23
guard bash "$PROD" "$(bash_in "$V_USER")"
o=$OUT
guard bash "$PROJ" "$(bash_in "$V_USER")"
[ "$o" = "$OUT" ] || bad "the product and project outputs differ"
is_out "$ASK" project
[ "$o" = "$ASK" ] || bad "[product]: stdout is not the pinned line"
done_case LG23 "mode bash does not read the level"

# LG24
GUARD_ENV=POSIXLY_CORRECT=1
guard skill "$PROD" "$(skill_in glab:project-plan)"
is_out "$DENY_PP" glab:project-plan
guard bash "$PROD" "$(bash_in "$V_USER")"
is_out "$ASK" "$V_USER"
unset GUARD_ENV
done_case LG24 "POSIX mode: the same decisions, exit 0"

# LG25: the word boundary of review round 1 (plan level-guard D25): any character but a letter, a
# digit, `_` or `-`. Each of these passed unasked before it, but the quoted ones. `${x:-user}` asks
# since review round 2, a `-` being a left boundary of `user`; the `$` there is the command's own.
# shellcheck disable=SC2016
for c in '/p/plan-gate.sh verdict /s p ACCEPTED user</dev/null /r.md' '/p/plan-gate.sh verdict /s p ACCEPTED user>&2 /r.md' \
	'/p/plan-gate.sh verdict /s p ACCEPTED {user,} /r.md' "/p/plan-gate.sh verdict /s p ACCEPTED 'user' /r.md" \
	'/p/plan-gate.sh verdict /s p ACCEPTED "user" /r.md' '/p/plan-gate.sh verdict /s p ACCEPTED user; true' \
	'/p/plan-gate.sh verdict /s p ACCEPTED user| cat' '/p/plan-gate.sh "verdict" /s p ACCEPTED user /r.md' "$V_HOME" \
	'/p/plan-gate.sh verdict /s p ACCEPTED ${x:-user} /r.md'; do
	guard bash "$PROD" "$(bash_in "$c")"
	is_out "$ASK" "$c"
done
for c in '/p/plan-gate.sh verdict /s p ACCEPTED username /r.md' '/p/plan-gate.sh verdict /s p ACCEPTED by-user-x /r.md' \
	'/p/plan-gate.sh verdict /s p ACCEPTED user_x /r.md' '/p/plan-gate.sh verdicts /s p ACCEPTED user /r.md'; do
	guard bash "$PROD" "$(bash_in "$c")"
	is_dec none "$c"
done
done_case LG25 "the word boundary is any character but a letter, digit, _ or -"

# LG26: the matcher is Bash|PowerShell|Monitor (plan level-guard D25); a PowerShell call carries its
# command in tool_input.command, as a Bash call does.
guard bash "$PROD" "$(jq -cn --arg c "$V_USER" '{session_id:"t",hook_event_name:"PreToolUse",tool_name:"PowerShell",tool_input:{command:$c,description:"d"},tool_use_id:"toolu_t"}')"
is_out "$ASK" PowerShell
done_case LG26 "a PowerShell call is judged as a Bash call"

# LG27: a copy whose product list has lost the bullet of the skills of every level, so it lacks
# glab:session-rules: no decision, one stderr line.
mkdir -p "$W/plug27/scripts"
cp "$SCRIPT" "$W/plug27/scripts/level-guard.sh"
cp "$(dirname "$SCRIPT")/glab-level.sh" "$W/plug27/scripts/glab-level.sh"
cp -R "$SK" "$W/plug27/skills"
f=$W/plug27/skills/product-manager/SKILL.md
grep -v '^- \*\*The skills of every level:\*\*' "$f" >"$W/pm.md" && mv "$W/pm.md" "$f"
[ "$(grep -c '^- \*\*The skills of every level:\*\*' "$f")" = 0 ] || bad "the copy still holds the bullet"
guard skill "$PROD" "$(skill_in glab:project-plan)" "$W/plug27/scripts/level-guard.sh"
is_dec none glab:project-plan
[ "$(printf '%s\n' "$ERR" | wc -l)" -eq 1 ] || bad "stderr is not one line: [$ERR]"
case $ERR in 'glab: level-guard: cannot read the skill list of the product level'*) ;; *) bad "stderr [$ERR]" ;; esac
done_case LG27 "a list without the skills of every level: no decision, one stderr line"

# LG28: a copy whose agents bullet names a skill of the other level. The bullet is not read, so the
# skill stays refused: the skill-folder filter alone would let it through.
mkdir -p "$W/plug28/scripts"
cp "$SCRIPT" "$W/plug28/scripts/level-guard.sh"
cp "$(dirname "$SCRIPT")/glab-level.sh" "$W/plug28/scripts/glab-level.sh"
cp -R "$SK" "$W/plug28/skills"
f=$W/plug28/skills/product-manager/SKILL.md
# The backticks are the list's own Markdown, not a command.
# shellcheck disable=SC2016
sed 's/^\(- \*\*The agents:\*\*.*\)$/\1 `glab:project-plan`/' "$f" >"$W/pm.md" && mv "$W/pm.md" "$f"
# shellcheck disable=SC2016
[ "$(grep -c '^- \*\*The agents:\*\*.*`glab:project-plan`' "$f")" = 1 ] || bad "the copy's agents bullet was not changed"
guard skill "$PROD" "$(skill_in glab:project-plan)" "$W/plug28/scripts/level-guard.sh"
is_out "$DENY_PP" glab:project-plan
done_case LG28 "the agents bullet is not read as a list of skills"

# LG29: hooks.json beside the script runs each mode on its own matcher, so a swap fails here.
HJ=$(dirname "$SCRIPT")/../hooks/hooks.json
got=$(jq -r '.hooks.PreToolUse[] | .matcher + " " + .hooks[0].command' "$HJ" 2>&1)
# The ${CLAUDE_PLUGIN_ROOT} is the hook command's own text, not a variable of this test.
# shellcheck disable=SC2016
want='Skill "${CLAUDE_PLUGIN_ROOT}"/scripts/level-guard.sh skill
Bash|PowerShell|Monitor "${CLAUDE_PLUGIN_ROOT}"/scripts/level-guard.sh bash'
[ "$got" = "$want" ] || bad "PreToolUse matchers and modes [$(printf '%s' "$got" | paste -sd, -)]"
done_case LG29 "hooks.json: Skill runs mode skill, Bash|PowerShell|Monitor runs mode bash"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
