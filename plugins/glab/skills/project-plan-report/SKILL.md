---
name: project-plan-report
description: Project level — Report an approved project plan made from a brief to the product level, through the shared store, before any development. The product chain's contract, which the project manager runs after the plan check; the session then waits for the verdict.
argument-hint: "[plan slug]"
---

The product chain sets this contract, and the project manager runs it as below. `$ARGUMENTS` is the project plan's slug. None → ask which one — never the most recent, never a guess.

## Preconditions

- `plan/<slug>/master.md` has the brief line (`glab:project-plan` Step 3; `glab:project-plan-accept` item 8) under `## Request`, and its `## Approval` line; at full tier `plan.md` — and with sub-plans each sub-plan's full-tier `plan.md` — has its own. None → stop: the plan is not ready to report.
- The store, from the first `glab-shared-store:` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`. None → stop and ask the user for it.

## Run

The manager writes the note — at most 10 lines from the planner's report and any question for product — to a file in the session's temp directory, then runs, from the repo root:

    "${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" report plan/<slug> <store> [<note file>]

It writes `briefs/<project>/report.r<n>.md` and beside it `plan.r<n>/`, the byte copy of the files it hashed, and prints the report's path. Show that path, or the `REFUSED:` line it printed, and stop: the session waits for the verdict (below).

## Before the report

For a plan from a brief (its `master.md` has the brief line), once per slug. Run this once the master and every sub-plan have been planned — each sub-plan from the tree at the master's base and its own `index.md` line, never another sub-plan's folder — checked by `glab:project-plan-analyze` and given every approval their tiers need: one report and one verdict cover the slug, so the product audits it once and every sub-plan's `glab:project-develop` checks one accepted digest. A sub-plan the built tree then proves wrong is amended, and reported again.

## Waiting

Announce `{slug} · report · r<n> · WAITING · context <n>k` — no agent runs, so it names no model or effort. Tell the product session the report is there: one that started this session watches its idle notice; else `SendMessage` to it when `ListAgents` lists it; else ask the user to. Put the report's path in the handoff file and end the turn.

## The freeze

From the first report on, the plan's hashed files — `master.md`, `index.md`, every `plan.md`, `questions.md` and every `steps-*.md` — are frozen: the product judges them and `glab:project-develop` checks their hash. Each line `glab:session-rules` or a stage skill says to write into one of them — an `- effort:` or `- model:` line, a `- round 3:` line, a Rule 3 decision or overrule, a question's answer — goes to `plan/{slug}/after-verdict.md` instead, in the form it would have had; name that file in every later dispatch that reads the plan. A line there never changes a step, a goal or a decision the product accepted; that is an amendment and a new report. The freeze lifts only for the amendment after a `REJECTED`, until the next report.

## On resuming

Read the latest `verdict.r<n>.md` of the brief, the numbers compared as numbers:

- `ACCEPTED` → Stage 2, whose `glab:project-develop` checks it.
- On REJECTED: keep round copies as `glab:project-plan-analyze` does, numbered past the highest one there; a new `glab:project-planner` amends, with the verdict's reason quoted as its findings; run one `glab:project-plan-analyze` delta round — one per verdict, which neither resets nor uses its round cap; still `NOT BUILDABLE` after it → the user. Then the tier's approvals again — at full tier the user's, with `plan.md`'s `## Approval` line replaced — and this report again, as `r<n+1>`. A `REJECTED` whose fix needs `master.md` — a goal, the final check — is a changed request, not an amendment (`glab:project-plan-accept`).

A refusal from `glab:project-develop` that the plan changed since it was accepted (a `PLAN WRONG` amendment) is a new report; one that the brief changed is a changed request. The rejection cap is the product level's; this session reports and waits.
