# Questions — subagent-effort

## Q1 — one session effort for Claude subagents and Codex, or two rules?

**Context.** The new Rule 0d takes the session's effort in this order: the
level the user named for the session in the main session, else
`CLAUDE_CODE_EFFORT_LEVEL`, else ask once per session; it records it as
`- effort: <level> (the user's words: "<words>" | CLAUDE_CODE_EFFORT_LEVEL), for the session`.
Codex's effort today (`glab:manager` Rule 6, `glab:external-agents`) is
`CLAUDE_CODE_EFFORT_LEVEL`, else ask once, recorded inside the Codex model
line (`- model: glab:reviewer codex, effort <level> (…)`) or as
`- effort: codex <level> (…)`. That order is your answer to
feature-codex-agent Q6, so changing it is yours to decide.

**Why it blocks.** Kept apart, one session can run Claude agents at the level
you named in chat and Codex at a different `CLAUDE_CODE_EFFORT_LEVEL`, with
the level recorded in two lines that disagree — one fact, two values. Steps
S3, S4 and S9 of `plan.md` differ by the answer.

**A (recommended) — one session effort, one record line, one source order.**
Codex takes the Rule 0d level (or the level you named for that agent or role)
and still sends the highest level the model supports that is not above it.
The Codex model lines lose their `effort <level> (…)` clause, and the
`- effort: codex …` line goes; Rule 0d's `- effort:` line is the only record.
Consequence: when you have named a session level in chat, Codex now follows
it instead of `CLAUDE_CODE_EFFORT_LEVEL`; Rules 5 and 6 and the
`glab:external-agents` effort bullet change; the *Codex effort rule* entry in
AGENTS.md becomes "the session effort, mapped down".

**B — keep Codex's rule as it is.** Rule 0d covers Claude subagents only;
Codex keeps `CLAUDE_CODE_EFFORT_LEVEL`, else ask, and its own record lines.
Consequence: no Codex text changes beyond the handoff example; a session can
hold two effort records and two levels, and Rule 0d must say Codex is
excluded.

Answer (the user, 2026-10-19): **A** — "One shared effort (Recommended)". One session effort, one record line and one source order for Claude subagents and Codex. Codex still maps the level down to the highest its model supports.
