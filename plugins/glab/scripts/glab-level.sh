#!/usr/bin/env bash
# shellcheck shell=bash
# glab-level.sh - the one copy of the rule that names a session's glab level. Sourced, never run:
# by manager-bootstrap.sh, the SessionStart hook that tells the session its level, and by
# level-guard.sh, the PreToolUse hook that holds the session to it - so the level a session is
# told and the level it is held to cannot drift apart. It defines one function and runs nothing.
#
# The level. The first line of the repo's AGENTS.md that begins `glab-level:` names it; the value
# is the rest of the line, blanks around it dropped, a trailing CR too. `product` gives the product
# text, `project` or no such line the project text — every repo that predates levels keeps the
# session start it had. Any other value, `delivery` and `support` (reserved for levels not built
# yet) included, gives the project text with a warning above it: the project level never touches a
# live system, so it is the safe fallback. The repo is $CLAUDE_PROJECT_DIR — the folder the session
# started in — or $PWD when that is unset; when that folder has no AGENTS.md, the top of its git
# work tree is tried, so a session started in a subfolder of its repo still finds the line.
# (Moved here word for word from the header of manager-bootstrap.sh in glab 0.17.0.)
#
# glab_level sets three globals for the script that sources this file: level (product or
# project), value (the line's value as a warning shows it back) and warn (that warning, or empty).
# It writes nothing, prints nothing and never exits: a missing or unreadable AGENTS.md, or no git,
# gives the project level, as a file with no such line does.
# shellcheck disable=SC2034 # level, value and warn are read by the script that sources this file
glab_level() {
	local dir top line
	dir=${CLAUDE_PROJECT_DIR:-$PWD}
	if [ ! -e "$dir/AGENTS.md" ] && top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) && [ -n "$top" ]; then
		dir=$top
	fi
	# An unreadable or missing file gives no line, which is the project level.
	line=$({ tr -d '\r' <"$dir/AGENTS.md" | grep -m 1 '^glab-level:'; } 2>/dev/null)
	# The value as it is shown back in the warning: printable characters only, at most 40.
	value=$(printf '%s' "${line#glab-level:}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -cd '[:print:]' | cut -c1-40)
	level=project warn=''
	case $line in
	'') ;;
	*)
		case $value in
		product | project) level=$value ;;
		*) warn="glab: level \"$value\" is not built in this version of glab; this session runs at the project level" ;;
		esac
		;;
	esac
}
