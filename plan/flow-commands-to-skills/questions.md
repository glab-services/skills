# flow-commands-to-skills — questions for the user

## Q1 — does `glab:plan-first` still implement when a person runs it outside the manager?

**Status:** answered 2026-11-13 — the user chose "A: plan only". The plan carries the `A` form only: P1 removes `implement.md` (the former IM1), PF0, PF1, PF9 and PF10 make the skill stop at Step 4, and D4b moves its one rule into `developer.md`. The same day the user merged `glab:plan-first` into `glab:plan` (`plan.md` request 4), so the skill this question names is `glab:plan` in the build.

**Context.** `glab:plan-first` today is two things. Its `SKILL.md` (Steps 0–4) is the planning procedure the planner agent follows. Its `implement.md` (Steps 5–7: implement, E2E tests, unit tests, plus service, nested-repo and commit rules) is read only by a session that implements a plan itself. Under `glab:manager` nobody reads `implement.md` (audit A15, P: no agent or stage file references it): the developer has its own copy of the same rules (`agents/developer.md` Steps 2–4), E2E is the integrator's (Stage 4) and commits are the committer's. So the plugin carries the implementation rules twice, and the two copies already disagree (`implement.md:24` "Say so in the commit body" vs `developer.md:52` "Name each one in your report", `:122` "Never commit"). The skill's description still says "Mandatory analyze-then-plan-then-implement workflow … only then implements, builds, and tests" (A8, A19).

What changes for a user of the plugin: a person who loads `glab:plan-first` on its own, or types `/glab:plan-first`, in a session that is not running `glab:manager` would no longer get implementation steps from it. The plugin's SessionStart hook loads `glab:manager` in every session, so that case is a session where the user has set the manager aside.

**Options.**

- **A (recommended).** `glab:plan-first` plans only and stops at Step 4. `implement.md` is removed with `git rm` (its history stays in git). Implementation is `glab:developer`'s, through `/glab:develop`, which a person can also type. The one rule `implement.md` holds that `developer.md` lacks — build the affected package and run the single closest test after every material change — moves into `developer.md` Step 3. Consequence: one copy of the implementation rules, no conflict; a person outside the manager runs `/glab:develop` to build.
- **B.** Keep `implement.md` as the procedure for a session that implements by itself, and keep the description's "then implement". Only the stale seam text goes (A8). Consequence: two copies of the implementation rules for two readers, and the `implement.md:24` / `developer.md:52` difference stays (each reader sees one).

**Recommended answer: A**, because the user asked that a rule live once, in the file of the role that acts on it, and the role that implements is `glab:developer`.

## Answer

Q1 — the user's words: "A: plan only" (2026-11-13). `glab:plan-first` plans only and stops at Step 4; `implement.md` is removed; its unique rule moves into `developer.md` Step 3.
