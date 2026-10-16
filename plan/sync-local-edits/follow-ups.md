# Follow-ups — sync-local-edits

Recorded by the manager on 2026-10-16 from the single normal-tier review of the
sync (verdict `SHIP WITH SCOPE CUT`). Both cuts were applied:

- `plugins/glab/commands/ship.md:32` — "— one at normal tier —" removed. `/glab:ship`
  takes only a path and cannot know a plan's tier.
- `plugins/glab/skills/plan-first/SKILL.md:67` and `plugins/glab/skills/manager/SKILL.md:213` —
  the "nothing new running is a slice; merge it" rule, by the user's choice, now
  applies to feature plans. A refactor, config or test-only plan names the existing
  test that proves nothing broke as its milestone. Before this, such a plan failed
  the acceptance checklist with nothing to merge into.

The user chose to record the remaining minor findings here rather than fix them
in this change. None weakens a guard: push confirmation, gates run by the
manager, the reviewer receiving the target only and local-only integration hold
at every tier.

| # | Where | Finding | Suggested fix |
|---|---|---|---|
| 1 | `skills/manager/SKILL.md:111-112` (Rule 4) | No channel is named for settling a seam "with the session on the other side, directly", and a relayed decision binds with no stated source. | Name the channel (the user, or a named shared file) and require relays to arrive through it. |
| 2 | `commands/develop.md:15`, `skills/manager/SKILL.md:137` | Nothing says what to do when `plan.md` has no tier line (an older plan, or one the user handed over); "approval → full tier only" then has no answer. | Add "No tier line → full." |
| 3 | `skills/manager/SKILL.md:104` (Rule 3) | Credits `glab:security` with confirmation before every push and every destructive action; that skill has neither rule as stated. The push guard does hold, through manager and `/glab:push`. | Point to `/glab:push` and "What you never do" for the push guard. |
| 4 | `AGENTS.md:104-105` | One fact, one value: `bootstrap/SKILL.md:94` still states the normal-tier caps, yet bootstrap was dropped from the round-cap list. The four ask-conditions now appear in four files and are not a listed case. | Keep bootstrap on the list; add the ask-conditions as a known case. |
| 5 | `commands/integrate.md:10` | Still says it runs after `/glab:analyze`; not updated for normal tier, and does not say normal tier runs only the milestone test. | Match the integrator agent's description; add the milestone-test scope. |
| 6 | `commands/develop.md:61` | "re-running `/glab:analyze`" after an amendment is wrong at normal tier. | "re-running the plan's next stage". |
| 7 | `commands/develop.md:67` | A `waived.md` has no tier line, so the waiver path has no next stage. | Say where a waiver goes. |
| 8 | `commands/analyze.md:18` | "If I do amend it" contradicts line 15, which now makes an amendment the manager's call for an engineering choice. | "If the plan is amended". |
| 9 | `skills/manager/SKILL.md:206` vs `skills/plan-first/SKILL.md:56` | Manager says the planner brings a choice back for the manager to decide; plan-first says the planner decides and records it. | State which in Rule 0c's seam note. |
| 10 | `skills/manager/SKILL.md:152`, `skills/plan-first/SKILL.md:154` | The spec entry has no stage, owner or location, and "checked by independent readers" is undefined; plan-folder removal depends on a repo rule that may not exist. | Name stage and owner, or drop the row. |
| 11 | `skills/manager/SKILL.md:125` | Stage 1b "Leaves on" says `BUILDABLE`, but at normal tier it leaves after one amendment without that verdict. | Add "or one amendment at normal tier". |
| 12 | `skills/bootstrap/SKILL.md:93`, `:46-47`; `commands/review.md:12`; `scripts/manager-bootstrap.sh:17` | Wording: "migrations and security-sensitive changes" is narrower than manager's full-tier list; "the four cases that go to the user" omits other escalations; "(Stage 5)" reads as if develop were Stage 5; the hook lists analyze unconditionally (errs safe). | Align wording with manager. |

The user's local copies under `~/.claude` were not touched and still carry the
pre-alignment text.

## Status

All 12 were fixed in the follow-up change on top of 0dec5e2. glab is now 0.2.1, and the
manager's decisions D1-D12 are recorded in `result-followups.md`. Line numbers refer to the
working tree after the fix.

| # | Status | Fix now at |
|---|---|---|
| 1 | fixed | `skills/manager/SKILL.md:113-114` |
| 2 | fixed | `skills/manager/SKILL.md:139`, `commands/develop.md:15` |
| 3 | fixed, then corrected after review | `skills/manager/SKILL.md:106` |
| 4 | fixed | `AGENTS.md:103-111` |
| 5 | fixed | `commands/integrate.md:10` |
| 6 | fixed | `commands/develop.md:61` |
| 7 | reopened — removed by the review's scope cut, see below | — |
| 8 | fixed | `commands/analyze.md:18` |
| 9 | fixed | `skills/manager/SKILL.md:58-60`, `:210`; `skills/plan-first/SKILL.md:56` |
| 10 | partly — manager half removed by the scope cut; plan-first half fixed | `skills/plan-first/SKILL.md:154` |
| 11 | fixed | `skills/manager/SKILL.md:127` |
| 12 | fixed | `skills/bootstrap/SKILL.md:46-48`, `:94-95`; `commands/review.md:12`; `scripts/manager-bootstrap.sh:17` |

## After the review of the follow-up fixes (2026-10-16)

One normal-tier review round returned `SHIP WITH SCOPE CUT`. Applied by the manager:

- **#7 reopened.** The waiver routing (`commands/develop.md:67`, "and from a waiver" in
  `commands/integrate.md:10`) was removed: a waiver has no plan and no tier, and the
  integrator, the integrate scope and the review cap all depend on both. A fix has to
  give a waiver a tier and an integrator input first.
- **#10 reopened.** The spec-entry paragraph in `skills/manager/SKILL.md` was removed: it
  dispatched the developer outside any plan step (its definition refuses that), and a
  re-dispatch overwrites `result.md`. The `plan-first` half of #10 (a repo that keeps
  specs but has no removal rule keeps its plans) stays.
- **#3 corrected.** The fix had narrowed "confirmation before every destructive action"
  to unrecoverable targets only. The line now keeps `glab:security`'s stop list and its
  *Destructive operations are proven* rule, and states confirmation before every
  destructive action and every push as the manager's own rule.

New minor findings from that review, not fixed:

| # | Where | Finding | Suggested fix |
|---|---|---|---|
| 13 | `skills/manager/SKILL.md` Rule 0c seam note, Stage 1; `skills/plan-first/SKILL.md:56` | "may overrule one" conflicts with Rule 4, where a relayed decision binds and the surface owner has the last word. | Except a line recording another session's decision. |
| 14 | `skills/manager/SKILL.md` Stage 1 | Recording an overrule as a new line leaves steps built on the old choice. | Send the plan back to the planning agent to amend those steps. |
| 15 | `skills/manager/SKILL.md` Rule 3 | Still reads as "the manager writes the decision line", while Stage 1 now says the planner writes it. | One clause: during planning the planner writes the line and the manager reviews it. |
| 16 | `commands/integrate.md:10` | The integrator agent is never told the normal-tier scope (milestone test only). | "Say which in the dispatch." |
| 17 | `scripts/manager-bootstrap.sh:17` | "-> push at full tier" can read as "push only at full tier"; Stage 1b is missing (already so before). | "At full tier work moves through plan -> analyze -> develop -> …". |
| 18 | `AGENTS.md` one-fact list | The analysis round caps are stated in manager and bootstrap but not listed. | Add them as a known case. |
| 19 | `commands/develop.md:67`, `commands/ship.md:32` (advisory, older text) | After a normal-tier review fix the develop handoff re-runs integrate and review, while manager says the gates are the only check on that fix; `/glab:ship` has no normal-tier exception. | Align with manager Stage 5. |
