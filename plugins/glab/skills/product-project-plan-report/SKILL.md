---
name: product-project-plan-report
description: Project level — Report an approved project plan made from a brief to the product level, through the shared store, before any development. The product chain's contract, which the project manager runs at glab:manager Stage 1c; the session then waits for the verdict.
argument-hint: "[plan slug]"
---

The product chain sets this contract, and the project manager runs it: `glab:manager` Stage 1c. `$ARGUMENTS` is the project plan's slug. None → ask which one — never the most recent, never a guess.

## Preconditions

- `plan/<slug>/master.md` has the brief line (`glab:plan` Step 3; `glab:manager` acceptance checklist item 8) under `## Request`, and its `## Approval` line; at full tier `plan.md` — and with sub-plans each sub-plan's full-tier `plan.md` — has its own. None → stop: the plan is not ready to report.
- The store, from the first `glab-shared-store:` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`. None → stop and ask the user for it.

## Run

The manager writes the note — at most 10 lines from the planner's report and any question for product — to a file in the session's temp directory, then runs, from the repo root:

    "${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" report plan/<slug> <store> [<note file>]

It writes `briefs/<project>/report.r<n>.md` and beside it `plan.r<n>/`, the byte copy of the files it hashed, and prints the report's path. Show that path, or the `REFUSED:` line it printed, and stop: the session waits for the verdict (`glab:manager` Stage 1c).
