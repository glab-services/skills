---
description: Check an implementation against its plan with the analyzer agent — conformance, not correctness
argument-hint: "[plan slug]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then use the **analyzer** agent on `plan/$ARGUMENTS/`.

If no slug was given, ask which plan; do not guess, and do not pick the most recent. An empty argument makes that path `plan/`, which hands the analyzer every plan in the repo and lets it choose its own contract.

This step asks one question: **did we build the thing the plan said?** Whether the code is correct and follows AGENTS.md is `/review`'s question. Do not answer it here, and do not let the analyzer drift into it — two commands asking one question is how both stop being trusted.

Show its report verbatim — every step line, the plan revision it measured against, and the verdict. Then:

- `CONFORMS` → go to `/review`.
- `DIVERGES: <n> steps` → stop and show me what diverged. There are two honest resolutions: change the code, or change the plan because the plan was wrong. **Changing the plan is my call, never yours.** Either way it means implementing again and re-running `/analyze`.
- `BLOCK: target unresolved` → say whether the plan or the implementation was the part that could not be resolved.

Never edit `plan.md` to make a divergence go away. That turns the contract into a description of whatever was built, which is the same as having no contract. If I do amend it, the analyzer's next report names the new revision, so the change is visible rather than silent.
