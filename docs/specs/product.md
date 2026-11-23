# Product — spec

The product level of `glab` and the product ⇄ project loop, as of `glab` 0.21.0 (2026-11-23). The project side is in `docs/specs/workflow.md`. Each rule lives in the payload file named for it below.

**History.** Until 2026-11-23 this file was a 183 KB log of every change. It is kept in git, not here: `git show dcfb2ff:docs/specs/product.md`. Older records that cite a section of this file mean that version.

## The parts

| Part | File |
|---|---|
| The product manager and its pipeline | `plugins/glab/skills/product-manager/SKILL.md` |
| Product plan, briefs, audit, verdict | `plugins/glab/skills/product-{plan,plan-analyze,project-brief,project-plan-analyze,project-plan-verdict}/SKILL.md` |
| Agents | `plugins/glab/agents/product-planner.md` (opus), `product-analyzer.md` (opus) |
| The hash gate and the store | `plugins/glab/scripts/plan-gate.sh` (modes `digest`, `report`, `verdict`, `check`, `sync`; its header comment is the contract) |
| The project side of the loop | `plugins/glab/skills/project-plan-report/SKILL.md` (Stage 1c), and `project-develop`'s verdict check |
| The level | the first `glab-level:` line of a repo's `AGENTS.md` (`product` or `project`), read by `plugins/glab/scripts/glab-level.sh` |
| Tests | `tests/plan-gate.test.sh`, `tests/product-loop.test.sh` with `tests/fixtures/product-loop/` |

## The pipeline

| # | Stage | Leaves on |
|---|---|---|
| P1 | `glab:product-planner` writes `plan/<slug>/product-plan.md` | the plan |
| P1b | `glab:product-analyzer` checks it, at most 2 rounds | `SOUND` |
| — | the user approves, always explicitly | `## Approval` |
| P2 | briefs and rule files go to the store | the briefs |
| P3 | one project session per brief, on the user's go-ahead | sessions started |
| P4 | the analyzer audits each project's report | `NO CONFLICT` or `CONFLICTS: <n>` |
| P5 | the verdict is written to the store | `ACCEPTED` or `REJECTED` |
| P6 | commit and push the product repo | landed |
| — | the user marks the slug delivered | `## Delivered` |
| P7 | the roadmap page `docs/roadmap/<slug>.md` | committed and pushed |

## The loop

- **The store.** It is shared between the levels, named by the first `glab-shared-store:` line of the repo's `AGENTS.md`, else of the host file. It holds:
  - `docs/product-rules/`;
  - `briefs/<project>/brief.md`, with `report.r<n>.md`, `plan.r<n>/` and `verdict.r<n>.md` beside each brief.

  A git store is fetched before each read. `plan-gate.sh` commits and pushes what it writes, at most 5 pushes per run.
- **The hash gate.**
  - The project's Stage 1c (`plan-gate.sh report`) hashes the plan files into a digest, and the product's verdict names that digest.
  - `project-develop` builds only when the latest verdict is `ACCEPTED` for the plan's current digest.
  - From the first report on, the hashed plan files are frozen, and later lines go to `after-verdict.md`.
- **The rejection cap.** After two `REJECTED` verdicts on one project since its last `ACCEPTED`, only a verdict by `user` counts. Its reason opens with the user's words, and `level-guard.sh` sends that command to the permission dialog.

## Not verified

- That a live product session can start project sessions in the background and reach them with `SendMessage`. The user can always start them by hand.
- That a live session follows the 0.21.0 text.
