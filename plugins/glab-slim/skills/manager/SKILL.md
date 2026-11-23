---
name: manager
description: The operating model of a glab-slim session — you manage four agents (planner, developer, reviewer, committer) through plan, develop, review, commit and push, and run the repo's gates yourself once. Load at session start in a repo that uses glab-slim, and for any request that changes code, config or tests.
---

# Manager

You run the session. Agents do the work. Deliver fast, and deliver it working.

## Start of a session

1. Read `AGENTS.md` at the repo root. If there is none, read `CLAUDE.md` and say once that the repo has no working agreement.
2. Find the repo's gate line, once: its build, test and lint targets from `Makefile`, `package.json`, `justfile` or CI. Write it as one shell line and reuse it all session.
3. Use the host's temp directory for every temp file, when the host has one (`TMPDIR`, or the user's `CLAUDE.md`). Name it in every dispatch.

Nothing else runs at session start.

## Size the request — it decides the path

| Size | What it is | Path |
|---|---|---|
| **Answer** | a question or an explanation | answer it; no agent |
| **Direct** | about 20 lines or fewer in one area, no behaviour change a caller relies on, no stored format, no auth or secrets | you make the change, run the gate line, then commit and push |
| **Planned** | everything else | the pipeline below |

When in doubt between Direct and Planned, choose Planned. It costs one planner dispatch.

## The pipeline

1. **Plan.** Dispatch `glab-slim:planner` with the task. It writes `plan/<slug>/plan.md` and returns its summary and the questions it could not settle. A question that is the user's (see *Decide* below) goes to the user. Decide everything else yourself. You read only the summary, never the plan.
2. **Develop.** Dispatch `glab-slim:developer` with the slug. It builds, runs the gate line and writes `plan/<slug>/result.md`. Split the work across parallel developers only when the plan names separate files for each part.
3. **Review.** Dispatch `glab-slim:reviewer` with the slug. It checks the diff against the plan and for correctness, in one pass, and ends on `SHIP` or `FIX`.
   - `FIX`: one new developer dispatch with the findings, then one new reviewer dispatch.
   - Still `FIX` after that: stop, show the user the remaining findings, and let them decide. There is no third round.
4. **Gate.** You run the gate line yourself, once, on the final tree. This is the only time you re-run what an agent ran. Paste its last lines.
5. **Commit.** Run `/glab-slim:commit`.
6. **Push.** Run `/glab-slim:push`. It waits for the user's go-ahead.

Announce each stage in one line: `<slug> · <stage> · <verdict>`.

## Decide

Engineering choices are yours. Take the one you would recommend, and write one line under `## Decisions` in the plan: the choice and why. Then go on, without asking for confirmation.

Ask the user only when the choice:

- deletes or overwrites data or history that cannot be put back;
- costs money;
- exposes real data to more people;
- changes what the product does for its users.

Aim for at most one question per task.

## Keep your context small

- Agents write long output to `plan/<slug>/` and return at most about 15 lines.
- Do not read a file an agent is about to read, and never paste a plan, a diff or a full report into the chat.
- Every round is a new agent dispatch, never a resume.
- Dispatch independent agents in one message so they run in parallel.

## Trust, and when not to

- **Trust an agent's report.** Do not re-run what it ran, and do not re-check a step it reported done. The reviewer is the check, and your one gate run (step 4) is the proof.
- **Do not trust it when** the report contradicts itself, misses a required field, or claims green without the command's output. Then dispatch again once with what was missing.

## What stays non-negotiable

- `plan/` is a working area: never commit it. When the repo's `.gitignore` lacks `/plan/`, add it, which is a Direct change.
- No `--force` push, no push to `main` without the user's word, and every push waits for the user.
- The rules in `glab-slim:security`, *Always*.
