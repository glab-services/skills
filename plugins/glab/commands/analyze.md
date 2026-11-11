---
description: Check a plan or an implementation with the glab:plan-analyzer or glab:analyzer agent — conformance and intent, not correctness
argument-hint: "[plan slug]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then pick the agent by the check and use it on `plan/$ARGUMENTS/`, dispatched as `glab:manager` Rules 0d and 5 say. The check is named in the dispatch message or by me, never in `$ARGUMENTS`, which is only the slug. A final or record check (`glab:manager` Stages 6b and 8) uses **glab:analyzer**. Otherwise the folder settles it: with a `result.md` under `plan/$ARGUMENTS/` it is the conformance check, with **glab:analyzer**; with none, nothing is built, so it is the plan check, or the master check when that is named (`glab:manager` Stage 1b), with **glab:plan-analyzer**. A check named that is none of these there: ask which check, and do not guess.

A round 2 or later is a new agent, given the previous round's findings and the delta, as `glab:manager` Stages 1b and 3 say.

The slug may name a sub-plan, `<slug>/<nn>-<name>`. With a `master.md` the analyzer also asks the intent question (`glab:plan-analyzer` or `glab:analyzer` *The intent question*); after the slug's last commit, `/glab:analyze <slug>` named as the final check asks it of the whole slug (`glab:manager` Stage 6b).

If no slug was given, ask which plan; do not guess, and do not pick the most recent. An empty argument makes that path `plan/`, which hands the analyzer every plan in the repo and lets it choose its own contract.

This step asks: **did we build the thing the plan said, and does it serve what the user asked for?** Whether the code is correct and follows AGENTS.md is `/glab:review`'s question. Do not answer it here, and do not let the analyzer drift into it — two commands asking one question is how both stop being trusted.

Show its report verbatim — every step line, the plan revision it measured against, and the verdict. Then:

- `BUILDABLE` → a plan check passed: the approval (`glab:manager` Stage 1), then `/glab:develop` — or, after a master check, the sub-plans' planning.
- `NOT BUILDABLE` → stop and show me the findings; the amendment goes to a new planning agent (`glab:manager` Stage 1b), never to a developer.
- `CONFORMS` → go to `/glab:integrate`; after the final check, to `/glab:push` (`glab:manager` Stage 7).
- `DIVERGES: <n> steps` → stop and show me what diverged. There are two honest resolutions: change the code, or change the plan because the plan was wrong. **Changing the plan is a `glab:manager` Rule 3 decision** — yours when it is an engineering choice, mine when it meets an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer. Either way it means implementing again and re-running `/glab:analyze`.
- `BLOCK: target unresolved` → say whether the plan or the implementation was the part that could not be resolved.

Never edit `plan.md` to make a divergence go away. That turns the contract into a description of whatever was built, which is the same as having no contract. If the plan is amended, the analyzer's next report names the new revision, so the change is visible rather than silent.
