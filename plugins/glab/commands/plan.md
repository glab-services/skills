---
description: Size, analyze, question and plan a task with the glab:plan-first skill, before any code is written
argument-hint: "[what to build or fix]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then follow the `glab:plan-first` skill for: $ARGUMENTS

That skill owns the procedure — the findings contract, the call-site audit, the proven-vs-inferred split, the slug naming. Do not restate it here and do not shortcut it.

Three gates it defines that this command exists to hold you to:

1. **Trivial work does not belong here.** `glab:plan-first` step 0 draws the line at roughly five lines with no architectural impact. If the task is under it, say so and stop — tell me to just make the change. A pipeline that runs for every typo gets skipped for everything.
2. **Decide; ask only what is mine.** Step 2 is not advisory. It sorts every gap into a fact to prove, a choice to record under `## Decisions`, or a question for me — destructive, costs money, exposes real data, changes what the product is. Only that last kind goes to `plan/{slug}/questions.md` and stops the plan. Do not close one of those by assuming an answer, and do not send me one of the others.
3. **A full-tier plan needs my approval** before a line of code is written. A normal-tier plan does not — `glab:manager` → *Pick the tier*. Either way, do not roll on into implementation here.

The one exception is `glab:plan-first`'s own waiver: if I explicitly waive planning after you have flagged it, write `plan/{slug}/waived.md` as that skill prescribes and tell me `/glab:develop` can proceed from the waiver instead of a plan. Do not invoke this on my behalf.

Report the slug, the tier, the decisions made, any question for me, the area spec its `## Record` names (`glab:manager` Stage 8), and where the plan is. Implement nothing.
