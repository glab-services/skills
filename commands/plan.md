---
description: Size, analyze, question and plan a task with the plan-first skill, before any code is written
argument-hint: "[what to build or fix]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then follow the `plan-first` skill for: $ARGUMENTS

That skill owns the procedure — the findings contract, the call-site audit, the proven-vs-inferred split, the slug naming. Do not restate it here and do not shortcut it.

Three gates it defines that this command exists to hold you to:

1. **Trivial work does not belong here.** `plan-first` step 0 draws the line at roughly five lines with no architectural impact. If the task is under it, say so and stop — tell me to just make the change. A pipeline that runs for every typo gets skipped for everything.
2. **Open questions stop the workflow.** Step 2 is not advisory. Write `plan/{slug}/questions.md` and stop there. Do not write a plan over unresolved questions, and do not close one by assuming an answer.
3. **The plan needs my approval** before a line of code is written. Do not roll on into implementation.

The one exception is `plan-first`'s own waiver: if I explicitly waive planning after you have flagged it, write `plan/{slug}/waived.md` as that skill prescribes and tell me `/develop` can proceed from the waiver instead of a plan. Do not invoke this on my behalf.

Report the slug, any open questions, and where the plan is. Implement nothing.
