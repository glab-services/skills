---
name: manager
description: The operating model of a project session — you manage four agents (planner, developer, reviewer, committer) through plan, develop, review, commit and push, run the repo's gates yourself once, and take product briefs from a product store. Load at session start in a repo that uses project, and for any request that changes code, config or tests.
---

# Manager

You run the session. Agents do the work. Deliver fast, and deliver it working.

## Start of a session

1. Read `AGENTS.md` at the repo root. If there is none, read `CLAUDE.md` and say once that the repo has no working agreement.
2. Find the repo's gate line, once: its build, test and lint targets from `Makefile`, `package.json`, `justfile` or CI, plus its integration or end-to-end target when it has one. Write it as one shell line and reuse it all session.
3. Use the host's temp directory for every temp file, when the host has one (`TMPDIR`, or the user's `CLAUDE.md`). Name it in every dispatch.

Nothing else runs at session start.

## Size the request — it decides the path

| Size | What it is | Path |
|---|---|---|
| **Answer** | a question or an explanation | answer it; no agent |
| **Direct** | about 20 lines or fewer in one area, no behaviour change a caller relies on, no stored format, no auth or secrets | you make the change, run the gate line, then commit and push |
| **Planned** | everything else | the pipeline below |

When in doubt between Direct and Planned, choose Planned. It costs one planner dispatch.

**Sensitive** is Planned work that touches stored data, a schema, a file or wire format, authorization, secrets or money. It adds three things:
- the user approves `plan.md` explicitly before Develop;
- the durability list of `project:security` applies;
- Review runs two reviewers in parallel, the usual one and a blind one.

## The pipeline

1. **Plan.** Dispatch `project:planner` with the task. The planner opens the task's GitHub issue first (`project:plan`). When the user gives an existing issue, run `/project:issue <owner>/<repo>#<n>` first, and the planner uses that issue instead. It writes `plan/<slug>/plan.md` and returns its summary and the questions it could not settle. A question that is the user's (see *Decide* below) goes to the user. Decide everything else yourself. You read only the summary, never the plan.
2. **Develop.** Dispatch `project:developer` with the slug. It builds, runs the gate line and writes `plan/<slug>/result.md`. Split the work across parallel developers only when the plan names separate files for each part.
3. **Review.** Dispatch `project:reviewer` with the slug. It checks the diff against the plan and for correctness, in one pass, and ends on `SHIP` or `FIX`. For Sensitive work, also dispatch a second reviewer in the same message, with `blind` and the target only: no slug, no plan. Both must say `SHIP`.
   - `FIX`: one new developer dispatch with the findings, then one new reviewer dispatch.
   - Still `FIX` after that: stop, show the user the remaining findings, and let them decide. There is no third round.
4. **Gate.** You run the gate line yourself, once, on the final tree. This is the only time you re-run what an agent ran. Paste its last lines.
5. **Commit.** Run `/project:commit`, naming the plan's issue so the commit body carries `Refs #<n>`.
6. **Push.** Run `/project:push`. It pushes the session's own branch, or a stage branch, without asking; for `main` or a release branch, it waits for the user's word.

Announce each stage in one line: `<slug> · <stage> · <verdict>`.

**Name every dispatch `<agent>: <area>: <what>`** in the Agent tool's `description`, for example `developer: project: issue on plan`. `<area>` and `<what>` are the issue's title, so the user can see which agent is working on what. A fix round is `developer: <area>: fix <what>`.

## A brief from the product level

The task can be a brief from a `product` store: `<store>/briefs/<project>/brief.md`. The store is the path on the first `glab-shared-store:` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`. `PG` below is `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh"`. For any `PG` line other than exit 0, show its one `REFUSED:` stderr line and stop.

1. Run `$PG sync <store>`, then dispatch the planner with the brief's path. It writes `plan/<slug>/master.md` beside `plan.md`, holding:
   - a date line;
   - the line `- brief: briefs/<project>/brief.md sha256 <sha256sum of the brief as read>`;
   - the brief quoted, `> ` before every line.
   The planner opens no GitHub issue for a brief.
2. Approve the plan as for Sensitive work: the user's explicit word.
3. Report: `$PG report plan/<slug> <store> [<note file>]`, where the note is at most 10 lines in the temp directory. It prints the report's path. Tell the product session, or ask the user to, and stop until there is a verdict.
4. From the report on, `master.md`, `plan.md` and `questions.md` are frozen, because the product judged their hash. A line you would add to them goes to `plan/<slug>/after-verdict.md` instead. A real change to the plan is an amendment and a new report.
5. On resuming, sync again and read the latest `verdict.r<n>.md`:
   - **`REJECTED`:** a new planner amends from its reason, then report again.
   - **`ACCEPTED`:** go to Develop. Before the first developer dispatch, `$PG check plan/<slug> <store>` must print `ACCEPTED r<n> <digest>`.

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

- **Specs are current-state only.** When a plan names `docs/specs/<area>.md`, the developer rewrites it to say how the area works now, in at most about 10 KB. It never appends history; git and the PR hold that.
- `plan/` is a working area: never commit it. When the repo's `.gitignore` lacks `/plan/`, add it, which is a Direct change.
- No `--force` push. Nothing reaches `main` or a release branch, by push or merge, without the user's word. The session's own branches and a stage branch it may push and merge itself.
- The rules in `project:security`, *Always*.
