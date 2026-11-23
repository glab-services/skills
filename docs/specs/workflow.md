# Workflow — spec

The `glab` project workflow as of `glab` 0.21.0 (2026-11-23): how a session runs a change from plan to push.

The product level above it is in `docs/specs/product.md`, the repo's layout and gates in `docs/specs/marketplace.md`, and the archived plugin this page describes is replaced by `plugins/glab-project/` and `plugins/glab-product/`. Each rule lives in the payload file named for it below. This page says what the parts are and where to look, not the rules themselves.

**History.** Until 0.21.0 this file was a 435 KB log of every change since 0.5.0: decisions, follow-ups, incidents and records. It is kept in git, not here. Read it with `git show 5b357df:docs/specs/workflow.md`. Older records in the other specs that cite a section of this file, such as *The session effort* or *Incidents*, mean that version.

## The parts

| Part | File |
|---|---|
| Session start: the working agreement, skills, gate line, handoff | `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/scripts/manager-bootstrap.sh` (the `SessionStart` hook) |
| The rules of every level: evidence, dispatch contents, effort, model, context budget, handoff file, decisions, round caps | `plugins/glab/skills/session-rules/SKILL.md` |
| The project manager: the pipeline, tiers, sub-plans, the planner's dispatch | `plugins/glab/skills/project-manager/SKILL.md` |
| Planning procedure (Steps 0–3, the master, sub-plans, amending) | `plugins/glab/skills/project-plan/SKILL.md` |
| Evidence and safety | `plugins/glab/skills/security/SKILL.md`, with `references/durability.md` for data, format and concurrency paths |
| Comments and markers | `plugins/glab/skills/comments/SKILL.md` |
| The stage skills | `plugins/glab/skills/project-{plan-accept,plan-report,develop,analyze,integrate,review,ship,record,issue}/SKILL.md`, `commit`, `push` |
| The agents | `plugins/glab/agents/*.md` |
| The hooks | `plugins/glab/hooks/hooks.json`: `context-size.sh` (context line, compact hint), `level-guard.sh` (each level's skills) |

## The pipeline

| # | Stage | Who | Leaves on |
|---|---|---|---|
| 1 | Plan, then accept | `glab:project-planner` (opus), then `/glab:project-plan-accept` (the manager: three search checks, the approval, `master.sha256`) | approval |
| 1c | Report to product | `/glab:project-plan-report`, only for a plan from a brief | the verdict |
| 2 | Develop | `glab:project-developer` (sonnet) | `BUILT`, green gates |
| 3 | Analyze | `glab:project-analyzer` (sonnet): conformance and the master's goals | `CONFORMS` |
| 4 | Integrate | `glab:project-integrator` (sonnet) | `INTEGRATED` |
| 5 | Review | `glab:project-reviewer` (sonnet): code only, no plan | `SHIP` |
| 6 | Commit | `glab:committer` (haiku) | commits verified |
| 7 | Record | `glab:project-developer`: spec and feature pages, committed before the push | record commit verified |
| 8 | Push | the manager, after the user's go-ahead | landed |

**Tiers.** Risk decides how much runs (`glab:project-manager` *Pick the tier*):
- **Trivial** (about 5 lines): the manager edits it directly, then commits and pushes.
- **Normal:** the stages above, where Stage 3 runs only per sub-plan.
- **Full:** everything, with the user's explicit approval of `master.md` and of every `plan.md`. Full tier is a schema or data migration, a stored or wire format, or authz, secrets or money.

**Round caps.** Stages 3 and 5 run at most 2 rounds, with no third. After that the user decides.

**Gates.** The manager runs the repo's gate line itself. No stage is green on an agent's word.

## Plan files

- **`plan/<slug>/` is a working area**, ignored by git. It holds:
  - `master.md`: the request verbatim, the goals, out of scope, the final test, the record targets, and the approval;
  - one `plan.md`, or `index.md` with sub-plan folders `<nn>-<name>/`;
  - `result.md` and `integration.md`.
- **The master never changes after its hash.** A changed request makes a new master.
- **The record** (Stage 7) writes what stays true into `docs/specs/<area>.md` and `docs/features/<feature>.md`. The spec gets a *Records* line naming the date, the slug, the commits, the branch and the PR.
- **Removing a plan folder.** The manager asks at a session start which landed folders to remove, and removes only the folders the user names (`glab:session-rules` Rule 2).

## What changed in 0.21.0

- **Removed:**
  - the plan check stage (`glab:project-plan-analyzer`, `/glab:project-plan-analyze`) and its plan-mode approval;
  - the final check after commit (Stage 6b) and the analyzer's record check;
  - third rounds.
- **The record** now runs before the push, in the same push.
- **`security`** loads its durability rules only on data, format or concurrency paths. The claims table is required only in a code stage's final report.
- **`session-rules`, `project-plan` and `push`** are condensed.
- **Per-run load** (bytes, `wc -c`), before → after:
  - manager session 53,416 → 41,774;
  - planner 32,642 → 27,766;
  - developer 31,490 → 27,714;
  - reviewer 27,134 → 23,027;
  - analyzer 24,143 → 17,752.

## Not verified

- That a live session follows the 0.21.0 text, and that it is faster. No task has run on it yet.
- That `${CLAUDE_PLUGIN_ROOT}` expands in a skill preloaded by an agent. `security` Part 2 relies on it to name `references/durability.md`; `project-plan` already relied on it for `plan-gate.sh`.
