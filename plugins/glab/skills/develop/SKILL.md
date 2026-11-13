---
name: develop
description: Project level — Implement a plan (approved, at full tier) through glab:developer agents, then hand off to the plan's next stage
argument-hint: "[plan slug]"
---

The entry point of `glab:manager` Stage 2. The session that runs it — `glab:manager`, or a person who typed `/glab:develop` — does not write the implementation: it checks the preconditions below, then splits, dispatches, verifies and hands off as Stage 2 says.

`$ARGUMENTS` is the slug, or a sub-plan `<slug>/<nn>-<name>` whose `master.md` is a level up. No slug: `glab:manager` *The pipeline*.

## Preconditions, before any dispatch

- **No `plan.md` and no `waived.md`** → stop. That is planning (`glab:manager` Stage 1), not this.
- **`plan/{slug}/waived.md` exists** → that is a `glab:plan` *User Override* waiver and it is a valid start; say the work runs from a waiver, not a plan, and that the conformance check therefore has nothing to measure against.
- **`plan/{slug}/questions.md` exists** → read it. Read `after-verdict.md` with it when there is one (`glab:manager` Stage 1c). These files have no single convention, so do not refuse on stale text. A question that meets a `glab:session-rules` Rule 3 ask-condition and is not plainly answered: ask the user, do not assume. Anything else still open in it is yours to decide and record under `## Decisions` — after a report to product, where `glab:manager` Stage 1c says.
- **Approval** → with a `master.md` (a level up for a sub-plan), its `## Approval` line is there, `sha256sum -c plan/<slug>/master.sha256`, run from the repo root, prints `OK`, and at full tier `plan.md` — a single plan's or a sub-plan's — ends with its own `## Approval` line — or stop and tell the user. With none — a plan from before `glab` 0.11.0 — full tier only; a plan with no tier line is full (`glab:manager` → *Pick the tier*). Nothing records it, so do not pretend to check: ask the user to confirm the plan is approved before any agent writes code, unless they approved it in this conversation. A normal-tier plan starts without it.
- **Product verdict** → when the slug's `master.md` (a level up for a sub-plan) has the brief line (`glab:plan` Step 3), or its `waived.md` names a brief, `briefs/<project>/brief.md`, run, from the repo root, `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" check plan/<slug> <store>` — `<slug>` the slug folder, sub-plans included, and `<store>` the path of the first `glab-shared-store:` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`. Anything but a line `ACCEPTED r<n> <digest>` and exit 0 → stop, show the `REFUSED:` line, and go to `glab:manager` Stage 1c. A waiver from a brief is always refused here, since no plan was reported: a waiver of planning is not a waiver of the product's verdict, so it is planned (`glab:manager` Stage 1). Run it on every dispatch of this skill, fix rounds included (`glab:manager` Stage 1c).
- **Green tree** → run the gate line once before any dispatch. Dispatching onto a red tree means every agent inherits a failure it did not cause and cannot tell apart from its own.
