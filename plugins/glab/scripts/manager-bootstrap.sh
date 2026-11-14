#!/usr/bin/env bash
# SessionStart hook of the glab plugin — makes the glab:bootstrap skill, the manager of the
# session's level, glab:session-rules and glab:security a requirement of every session, in every
# project, including ones with no CLAUDE.md of their own.
# The text below is the irreducible minimum: the rules that must hold even in a session where
# glab:bootstrap never got loaded. A plugin cannot ship global instructions — a CLAUDE.md at a
# plugin root is not loaded — so the copy that used to sit in the global CLAUDE.md lives only
# here. Keep it short: Claude Code caps a hook's additionalContext at 10,000 characters, and each
# of the two texts must stay under that (tests/manager-bootstrap.test.sh B8).
#
# The level. The first line of the repo's AGENTS.md that begins `glab-level:` names it; the value
# is the rest of the line, blanks around it dropped, a trailing CR too. `product` gives the product
# text, `project` or no such line the project text — every repo that predates levels keeps the
# session start it had. Any other value, `delivery` and `support` (reserved for levels not built
# yet) included, gives the project text with a warning above it: the project level never touches a
# live system, so it is the safe fallback. The repo is $CLAUDE_PROJECT_DIR — the folder the session
# started in — or $PWD when that is unset; when that folder has no AGENTS.md, the top of its git
# work tree is tried, so a session started in a subfolder of its repo still finds the line.
#
# The contract: always exits 0 — a bootstrap that can fail a session start is worse than none; on
# stdout one JSON object whose only key is hookSpecificOutput, or the plain text when jq fails;
# messages only on stderr. The warning goes to stderr as well as into the text, for debugging only:
# Claude Code shows no stderr of a hook that exits 0 to the session.

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

if [ "$level" = product ]; then
	HEAD=$(cat <<'CTX_EOF'
Level: product — glab-level: product in AGENTS.md.
CTX_EOF
)
	MANAGER=$(cat <<'CTX_EOF'
   - `glab:product-manager` — the operating model of the product level. Each stage of its pipeline (`glab:product-manager` -> *The product pipeline*) is dispatched to its own agent. You manage; you do not implement. Use only the skills its *Your skills — this level only* names: never another level's manager or stage skill.
CTX_EOF
)
else
	HEAD=$(cat <<'CTX_EOF'
Level: project — no other glab-level line in AGENTS.md says otherwise.
CTX_EOF
)
	MANAGER=$(cat <<'CTX_EOF'
   - `glab:project-manager` — the operating model of the project level. Each stage of its pipeline (`glab:project-manager` -> *The pipeline*, as far as *Pick the tier* runs it) is dispatched to its own agent. You manage; you do not implement. Use only the skills its *Your skills — this level only* names: never another level's manager or stage skill.
CTX_EOF
)
fi

BEFORE=$(cat <<'CTX_EOF'
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement. Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.

2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load three skills and run the session under all three:
CTX_EOF
)

AFTER=$(cat <<'CTX_EOF'
   - `glab:session-rules` — the rules every level's manager runs under: the context budget, decisions and questions, the effort and the model of every dispatch, the round caps.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Each `glab` agent loads its own rules: `AGENTS.md` in its own first step, and the `glab` skills its role uses from its definition. A dispatch carries only the facts of its task (`glab:session-rules` Rule 0c) and passes the Agent tool's `effort` parameter at the session's level (`glab:session-rules` Rule 0d).

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, name its temp directory in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 6 explains why this matters.

What skips the pipeline, and what still holds when it does: `glab:session-rules` Rule 1. Who runs a gate before it is reported green: `glab:session-rules` Rule 0b.
CTX_EOF
)

CTX="$HEAD

$BEFORE
$MANAGER
$AFTER"
if [ -n "$warn" ]; then
	CTX="$warn

$CTX"
	printf '%s\n' "$warn" >&2
fi

jq -n --arg c "$CTX" \
	'{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}' 2>/dev/null ||
	printf '%s\n' "$CTX"

exit 0
