#!/usr/bin/env bash
# SessionStart hook — makes the manager and security skills a requirement of every
# session, in every project, including ones with no CLAUDE.md of their own.
# Always exits 0: a bootstrap that can fail a session start is worse than none.

read -r -d '' CTX <<'CTX_EOF'
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement.

2. Load two skills now and run the session under both:
   - `manager` — the operating model. Work moves through plan -> develop -> analyze -> integrate -> review -> commit -> push, each stage dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Every agent you dispatch reads `AGENTS.md` first AND carries the `security` discipline. Say both in the dispatch message.

`manager` governs HOW work is done, not whether: questions are answered directly, and trivial changes (~5 lines, no architectural impact) are made directly — the skill says so itself. `security` does not have that exemption. A trivial change still gets its claim verified, and a gate is never reported green on an agent's word.
CTX_EOF

jq -n --arg c "$CTX" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}' 2>/dev/null \
  || printf '%s\n' "$CTX"

exit 0
