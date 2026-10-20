---
description: Check an implementation against its plan with the glab:analyzer agent — conformance, not correctness
argument-hint: "[plan slug]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then use the **glab:analyzer** agent on `plan/$ARGUMENTS/`.

A round 2 or later is a new agent, given the previous round's findings and the delta, as `glab:manager` Stages 1b and 3 say.

If no slug was given, ask which plan; do not guess, and do not pick the most recent. An empty argument makes that path `plan/`, which hands the analyzer every plan in the repo and lets it choose its own contract.

This step asks one question: **did we build the thing the plan said?** Whether the code is correct and follows AGENTS.md is `/glab:review`'s question. Do not answer it here, and do not let the analyzer drift into it — two commands asking one question is how both stop being trusted.

Show its report verbatim — every step line, the plan revision it measured against, and the verdict. Then:

- `CONFORMS` → go to `/glab:integrate`.
- `DIVERGES: <n> steps` → stop and show me what diverged. There are two honest resolutions: change the code, or change the plan because the plan was wrong. **Changing the plan is a `glab:manager` Rule 3 decision** — yours when it is an engineering choice, mine when it meets an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer. Either way it means implementing again and re-running `/glab:analyze`.
- `BLOCK: target unresolved` → say whether the plan or the implementation was the part that could not be resolved.

Never edit `plan.md` to make a divergence go away. That turns the contract into a description of whatever was built, which is the same as having no contract. If the plan is amended, the analyzer's next report names the new revision, so the change is visible rather than silent.
