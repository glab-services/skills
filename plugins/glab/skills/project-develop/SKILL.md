---
name: project-develop
description: Project level — Implement an accepted plan — the user's approval at full tier — through glab:project-developer agents, then hand off to the plan's next stage
argument-hint: "[plan slug]"
---

Stage 2 of `glab:project-manager` *The pipeline*. The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-develop` — does not write the implementation: it checks the preconditions below, then splits, dispatches, verifies and hands off as below.

`$ARGUMENTS` is the slug, or a sub-plan `<slug>/<nn>-<name>` whose `master.md` is a level up. No slug: `glab:project-manager` *The pipeline*.

## Preconditions, before any dispatch

- **No `plan.md` and no `waived.md`** → stop. That is planning (`glab:project-manager` Stage 1), not this.
- **`plan/{slug}/waived.md` exists** → that is a `glab:project-plan` *User Override* waiver and it is a valid start; say the work runs from a waiver, not a plan, and that the conformance check therefore has nothing to measure against.
- **`plan/{slug}/questions.md` exists** → read it. Read `after-verdict.md` with it when there is one (`glab:project-plan-report`). These files have no single convention, so do not refuse on stale text. A question that meets a `glab:session-rules` Rule 3 ask-condition and is not plainly answered: ask the user, do not assume. Anything else still open in it is yours to decide and record under `## Decisions` — after a report to product, where `glab:project-plan-report` says.
- **Approval** → with a `master.md` (a level up for a sub-plan), its `## Approval` line is there, `sha256sum -c plan/<slug>/master.sha256`, run from the repo root, prints `OK`, and at full tier `plan.md` — a single plan's or a sub-plan's — ends with its own `## Approval` line — or stop and tell the user. With none — a plan from before `glab` 0.11.0 — full tier only; a plan with no tier line is full (`glab:project-plan` Step 0). Nothing records it, so do not pretend to check: ask the user to confirm the plan is approved before any agent writes code, unless they approved it in this conversation. A normal-tier plan starts without it.
- **Product verdict** → when the slug's `master.md` (a level up for a sub-plan) has the brief line (`glab:project-plan` Step 3), or its `waived.md` names a brief, `briefs/<project>/brief.md`, run, from the repo root, `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" check plan/<slug> <store>` — `<slug>` the slug folder, sub-plans included, and `<store>` the path of the first `glab-shared-store:` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`. Anything but a line `ACCEPTED r<n> <digest>` and exit 0 → stop, show the `REFUSED:` line, and go to `glab:project-plan-report`. A waiver from a brief is always refused here, since no plan was reported: a waiver of planning is not a waiver of the product's verdict, so it is planned (`glab:project-manager` Stage 1). Run it on every dispatch of this skill, fix rounds included (`glab:project-plan-report`).
- **Green tree** → run the gate line once before any dispatch. Dispatching onto a red tree means every agent inherits a failure it did not cause and cannot tell apart from its own.

## Splitting

One agent is the default: the steps of most plans build on each other — a later step importing a type an earlier one defines, a deletion waiting on its replacement to pass.

- Split **only** when the slices touch no common file — not the same test file, barrel export or config — **and** have no ordering dependency: neither needs the other's output to compile or to pass its own tests. Two agents editing one file in one working tree clobber each other, and there is no merge step to save you. A wrong split costs a red tree and two reports that each blame the other.
- Which step ids touch which files is the input to that decision: ask a read-only agent (Rule 2); never read the plan yourself to find out.
- Give each agent its step ids and its file boundary — the paths it owns and those it must not touch — and dispatch them in one message. If you cannot state the boundary in one sentence, the work is not splittable: run it as one agent.
- Sequential agents — one per group of steps, each dispatched once the one before returned `BUILT` and your gate run was green — suit a long plan whose steps depend on each other.

## The dispatch

Each `glab:project-developer` dispatch carries what Rule 0c says, and your suggestions, marked as such. **A fix round** — after `DIVERGES`, review findings or integration regressions — is a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps.

Do not paste the plan. The agent reads it; a paraphrase is how a step quietly changes meaning. What comes back is `plan/{slug}/result.md` and the short reply, as `glab:project-developer` Step 5 and *Report* have them, checked as Rule 5 says.

## Verify before moving on

An agent's report is not evidence. Run the gate line you recorded (`glab:bootstrap` step 3) yourself, in the order and under the changed-code-gate rule of `glab:project-developer` Step 3; `glab:security` Rules 3 to 5 hold.

- `PLAN WRONG` → stop the build. Amending the plan is a Rule 3 decision — yours for an engineering choice, the user's on an ask-condition — made through a new planning agent, recorded under `## Decisions`, never by the developer; then this stage again.
- `BLOCKED: <reason>` → can it be unblocked? A missing decision is yours under Rule 3 unless it meets an ask-condition; a dependency on another slice means the split was wrong — re-dispatch rather than patch it yourself.
- `BUILT` and every gate green → the next stage: Stage 3 at full tier and for every sub-plan, Stage 4 at normal tier with no sub-plans.

If you find yourself fixing an agent's work beyond a mechanical consequence, you have taken over the implementation (Rule 1), and the split stopped meaning anything.
