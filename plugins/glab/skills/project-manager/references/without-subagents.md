# Without subagent dispatch

Some hosts run this skill without the ability to dispatch subagents. The pipeline does not change — **one session per stage** replaces one agent per stage.

- Start a fresh session for each stage, named for it: `<slug> plan`, `<slug> plan-accept`, `<slug> plan-analyze`, `<slug> report`, `<slug> develop`, `<slug> analyze`, `<slug> integrate`, `<slug> review`, `<slug> final`, `<slug> record`.
- **The files on disk are the handoff.** `plan.md`, `questions.md`, `result.md`, `integration.md` — a stage reads what the previous one wrote, and nothing is carried in conversation.
- The round caps still apply and are counted by the file record, not by memory: a second review session is `review2`, a `review3` needs its round-3 line, and there is no `review4`.
- A stage session runs on the model the user starts it with — `claude --model <alias>` or `/model <alias>`. When you hand off to one, name the role's model from `glab:session-rules` Rule 5, or the recorded override, so the user starts it on that one.
- Amending the plan between stages is done in its own session, under Rule 3 — never inside the stage that found the problem.

This is stronger than dispatch, not weaker: every stage begins with a clean context, so the context budget in Rule 2 holds by construction rather than by discipline.
