#!/usr/bin/env bash
# SessionStart hook of the glab plugin — makes the glab:bootstrap, glab:manager and glab:security
# skills a requirement of every session, in every project, including ones with no CLAUDE.md of
# their own.
# The text below is the irreducible minimum: the rules that must hold even in a session where
# glab:bootstrap never got loaded. A plugin cannot ship global instructions — a CLAUDE.md at a
# plugin root is not loaded — so the copy that used to sit in the global CLAUDE.md lives only
# here. Keep it short: Claude Code caps a hook's additionalContext at 10,000 characters.
# Always exits 0: a bootstrap that can fail a session start is worse than none.

read -r -d '' CTX <<'CTX_EOF'
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement. Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.

2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:
   - `glab:manager` — the operating model. Each stage of its pipeline (`glab:manager` -> *The pipeline*, as far as *Pick the tier* runs it) is dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Each `glab` agent loads its own rules: `AGENTS.md` in its own first step, and the `glab` skills its role uses from its definition. A dispatch carries only the facts of its task (`glab:manager` Rule 0c) and passes the Agent tool's `effort` parameter at the session's level (`glab:manager` Rule 0d).

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, name its temp directory in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 6 explains why this matters.

What skips the pipeline, and what still holds when it does: `glab:manager` Rule 1. Who runs a gate before it is reported green: `glab:manager` Rule 0b.
CTX_EOF

jq -n --arg c "$CTX" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}' 2>/dev/null \
  || printf '%s\n' "$CTX"

exit 0
