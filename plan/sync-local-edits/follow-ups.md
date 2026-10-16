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
