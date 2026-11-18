#!/usr/bin/env bash
# level-guard.sh - the PreToolUse hook of the glab plugin: the hard edge of two rules that until
# glab 0.17.0 held only as far as a session kept to its skill text.
#
#   skill  (matcher Skill) refuses a Skill call to a glab skill that is not on the list of the
#          session's level, glab:<level>-manager *Your skills — this level only*.
#   bash   (matcher Bash|PowerShell|Monitor) sends a `plan-gate.sh verdict … user …` command to
#          Claude Code's permission dialog, so only the user passes a verdict written by user
#          (glab:product-manager *The cap*). Each of the three tools carries its command in
#          tool_input.command: documented for Bash and PowerShell, inferred for Monitor (the CLI
#          2.1.327 binary maps ["Monitor","command"] beside Bash and PowerShell; not seen live).
#
# The contract (AGENTS.md *Rules*): exit 0 on every path; on stdout one JSON object whose only key
# is hookSpecificOutput, or nothing; messages on stderr only. Mode skill only ever says deny, mode
# bash only ask. Nothing here says allow, so the hook never skips a prompt or a rule that applies
# without it; and nothing exits 2, which would refuse every call on a fault of this script.
# Docs: https://code.claude.com/docs/en/hooks (PreToolUse decision control).
#
# Where it fails open, and why. Mode skill: anything it cannot read - no input, input with no
# skill name, a list it cannot parse, no glab-level.sh - gives no decision, and the call goes on
# as before 0.17.0; a list or a glab-level.sh it cannot read also gives one stderr line. Failing closed would refuse the session's own manager on any
# fault, and the text rule still holds behind the hook; tests/level-guard.test.sh fails the gates
# when a list stops parsing. Claude Code too lets a call through when a hook crashes or times out.
# Mode bash: input jq cannot read is scanned raw, for the three words anywhere - an over-match costs
# one dialog, never a refusal.
#
# Who is judged. Every Skill call Claude makes, in the main session and in subagents alike: the
# input's agent_id and agent_type are not read, because the level is the repo's, not the agent's.
# A skill the user types, /glab:<name>, does not go through the Skill tool and never reaches this
# hook (UserPromptExpansion fires instead, and glab does not hook it): the user may step in at any
# level. Agents are not judged here (the level boundary's other half stays text).
set -u
# Byte semantics for every match: the names and words below are ASCII.
export LC_ALL=C

mode=${1:-}
# The plugin root is the parent of this script's folder: skills/ sits beside scripts/. Read from
# the script's own path, not $CLAUDE_PLUGIN_ROOT, so the test runs it on any copy of the tree.
here=${BASH_SOURCE[0]%/*}
[ "$here" != "${BASH_SOURCE[0]}" ] || here=.
root=$here/..

say() { printf 'glab: level-guard: %s\n' "$*" >&2; }

# The input, read once. A terminal is never read: a person running this by hand would wait on it.
# A closed stdin is replaced by /dev/null first, as in manager-bootstrap.sh and for its reason.
{ true 3<&0; } 2>/dev/null || exec </dev/null # `true`, not `:`: a special builtin's redirection error exits a POSIX-mode shell
input=''
[ -t 0 ] || input=$(cat)

# field <jq path>: the string at that path of the input, or nothing. Exit 0 when jq read the input
# (the field may still be missing), non-zero when jq is missing or the input is not JSON.
field() { printf '%s' "$input" | jq -r "$1 // empty | strings" 2>/dev/null; }

# level_list <level>: the glab skills glab:<level>-manager *Your skills — this level only* names,
# one line, space-separated. That section is the list's one copy (docs/one-fact.md *The level
# boundary*): its bullets that begin `- **`, but for `- **The agents:**`, and on them every
# `glab:<name>` in backticks whose skills/<name>/SKILL.md exists - a bullet's prose names an agent
# too (glab:product-planner). Each bullet is one line: a bullet wrapped onto a second line loses the
# names on that line, the list comes out short, and the level's own skill can be refused - so the
# lists are kept one bullet per line, and tests/level-guard.test.sh (LG1, LG2) fails on a wrap.
# Exit 1 when the file is unreadable or the list lacks the level's own manager or
# glab:session-rules: a renamed heading or bullet form.
# The awk output is read by a command substitution, not < <(...): bash before 5.1 has no process
# substitution in POSIX mode, and this hook must exit 0 there too. The names hold [a-z0-9:-] only,
# so the unquoted expansion splits them on blanks and globs nothing.
level_list() {
	local f=$root/skills/$1-manager/SKILL.md out='' n names
	[ -r "$f" ] || return 1
	names=$(awk '
		/^## / { ins = ($0 == "## Your skills — this level only"); next }
		ins && /^- \*\*/ && !/^- \*\*The agents:\*\*/ {
			s = $0
			while (match(s, /`glab:[a-z0-9-]+`/)) { print substr(s, RSTART + 1, RLENGTH - 2); s = substr(s, RSTART + RLENGTH) }
		}' "$f")
	for n in $names; do
		[ -f "$root/skills/${n#glab:}/SKILL.md" ] && out="$out $n"
	done
	case " $out " in *" glab:$1-manager "*) ;; *) return 1 ;; esac
	case " $out " in *" glab:session-rules "*) ;; *) return 1 ;; esac
	printf '%s\n' "${out# }"
}

skill_mode() {
	# The raw match takes only a plain string value: an escaped quote fails it, and no glab name has one.
	local s='' name list re='"skill"[[:space:]]*:[[:space:]]*"([^"\\]*)"'
	if ! { command -v jq >/dev/null 2>&1 && s=$(field '.tool_input.skill'); }; then
		if [[ $input =~ $re ]]; then s=${BASH_REMATCH[1]}; else s=''; fi
	fi
	# Every byte around the name that cannot be part of one dropped - not only blanks: the Skill
	# tool trims the name with JS trim() before it resolves it (read from the CLI, not documented),
	# which also drops Unicode spaces such as a no-break space, U+3000 and a BOM. Until review round
	# 2 only ASCII blanks were dropped here, so such a pad got past the deny. Trimming to the name's
	# own bytes drops at least what trim() drops. Then one leading slash, as a typed name has it;
	# then glab:<name> or a bare <name>, which a plugin skill with a frontmatter name: also answers
	# to (https://code.claude.com/docs/en/skills).
	s=${s#"${s%%[[:alnum:]:/_-]*}"}
	s=${s%"${s##*[[:alnum:]:/_-]}"}
	s=${s#/}
	case $s in
	glab:*) name=${s#glab:} ;;
	*:* | */*) return 0 ;; # another plugin's skill, or a nested one: not glab's to judge
	*) name=$s ;;
	esac
	# Only a skill this plugin ships is judged; that also keeps the reason free of quotes and
	# backslashes, which printf below does not escape.
	[[ $name =~ ^[a-z0-9-]+$ ]] || return 0
	[ -f "$root/skills/$name/SKILL.md" ] || return 0
	# shellcheck source-path=SCRIPTDIR source=glab-level.sh
	# The -r test first: in POSIX mode a `.` of a missing file exits the shell, and the contract is exit 0.
	{ [ -r "$here/glab-level.sh" ] && . "$here/glab-level.sh" 2>/dev/null; } || { say "$here/glab-level.sh is missing or unreadable; glab:$name not judged"; return 0; }
	level=project
	glab_level
	list=$(level_list "$level") || { say "cannot read the skill list of the $level level from $root/skills/$level-manager/SKILL.md; glab:$name not judged"; return 0; }
	case " $list " in *" glab:$name "*) return 0 ;; esac
	printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' \
		"glab: glab:$name is not a skill of the $level level (the glab-level line of the repo's AGENTS.md; no line is the project level). Use only the skills glab:$level-manager lists under Your skills. The user can still type /glab:$name to run it."
}

bash_mode() {
	# A word: on each side, any character but a letter, a digit, `_` or `-`, or the start or end of
	# the command. So `user</dev/null`, `user>&2`, `{user,}`, 'user' and `user;` are the word, and
	# user-reason.md and username are not. Until review round 1 the boundary was a blank or a quote
	# only, and `user<`, `user>` and `{user,}` passed unasked (plan level-guard D25). A slash is a
	# boundary too, so `/home/user/store` asks: an over-match costs one dialog, never a refusal.
	# Left of `user` a `-` is a boundary as well (review round 2), so `${x:-user}` asks, while
	# by-user-x still does not: its right side is `-`.
	# This is a match on the command's text, not on what the shell runs: quoting and expansion -
	# us''er, ver""dict, $'\x75ser', a variable - give the words to the shell without spelling them
	# here, and such a command passes unasked (product-manager *The cap* says so).
	local c q='[^[:alnum:]_-]' re_v re_u
	# The fast path: every Bash, PowerShell and Monitor call of every session comes here, and nearly
	# none names the gate.
	case $input in *plan-gate.sh*) ;; *) return 0 ;; esac
	re_v="(^|$q)verdict($q|\$)"
	re_u="(^|[^[:alnum:]_])user($q|\$)"
	if command -v jq >/dev/null 2>&1 && c=$(field '.tool_input.command'); then
		[[ $c == *plan-gate.sh* && $c =~ $re_v && $c =~ $re_u ]] || return 0
	else
		# jq cannot read it: quotes and newlines arrive escaped, so the words count anywhere.
		[[ $input == *verdict* && $input == *user* ]] || return 0
	fi
	printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' \
		'glab: a verdict by user. Approve only if this verdict is your own decision and its reason file opens with your words (glab:product-manager, The cap).'
}

case $mode in
skill) skill_mode ;;
bash) bash_mode ;;
*) say 'usage: level-guard.sh skill|bash' ;;
esac
exit 0
