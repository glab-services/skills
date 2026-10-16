# Result — feature-model-switch

Built against HEAD `9700bcb` on `main`. Contract read: `AGENTS.md`, then `plan/feature-model-switch/plan.md`. There is no `findings.md` or `questions.md` in this folder; the plan carries its findings and decisions inline (normal tier).

## Stages

Each edit was applied by a script that parsed the eleven E-blocks out of `plan.md`, checked each *before* text against the unedited file, then replaced it with the *after* text exactly, bottom-up within each file. Check output, all eleven: `before-count=1`, `starts-at-line` equal to `cited`; `edits found: 11 E1 … E11`; script `rc=0`.

| edit | step | status | where it is now |
|---|---|---|---|
| E1 | S1 | done | `plugins/glab/skills/manager/SKILL.md:116-140` (new `## Rule 5` section, ahead of `## Know the gates before you dispatch` at :141) |
| E2 | S1 | done | `plugins/glab/skills/manager/SKILL.md:161` (end of the line, after `· verdict\``) |
| E10 | S1 | done | `plugins/glab/skills/manager/SKILL.md:195-197` |
| E11 | S1 | done | `plugins/glab/skills/manager/SKILL.md:227` |
| E3 | S1 | done | `plugins/glab/skills/manager/SKILL.md:326-327` |
| E4 | S1 | done | `plugins/glab/skills/manager/SKILL.md:380-382` |
| E5 | S2 | done | `plugins/glab/commands/develop.md:41-42` |
| E6 | S2 | done | `plugins/glab/commands/review.md:8` |
| E7 | S2 | done | `plugins/glab/commands/ship.md:16` |
| E8 | S3 | done | `AGENTS.md:128-133` |
| E9 | S4 | done | `plugins/glab/.claude-plugin/plugin.json:3`, `0.2.1` → `0.3.0` |

The sibling plan (`plan/feature-opencode-worker/`) had not landed (its folder does not exist in the tree, and HEAD is `9700bcb`), so `0.3.0` is the version, as D15 says.

`git diff --stat`: 6 files, 44 insertions, 8 deletions. `git diff --quiet -- plugins/glab/agents README.md plugins/memory-sync` → `rc=0`, so the agent files are unchanged (D8).

## Blocked

None.

## Unplanned changes

None. Every hunk maps to E1–E11.

## Tests

No shell script changed, so `tests/memory-sync.test.sh` gets no new case (plan *Tests*). Its `PASS 35/35` is a regression guard only.

Coverage, listed per step as `AGENTS.md` *Tests* requires (prose change, so the post-conditions are the cases):
- S1: the `manager '…'` lines (Rule 5, Stage 2, Stage 5, the parallel fan-out, the no-subagent section), every `rule5 '…'` line, `handoff-format`, and the guards `rule5 stage-session-phrase` and `stage2 message-text-phrase`.
- S2: the three command lines and the three-file list.
- S3: `agents-known-case`.
- S4: `version`.
- D2/D8 guards: `frontmatter-model rc=1` and every `others` count `0`.

Not covered: whether a plugin agent dispatched with `model` really runs on that model. `UNVERIFIED: a live dispatch with model haiku runs on haiku — that takes a logged-in session and spends the user's quota, which no agent here may do` (plan *Milestone*, I4).

## Gates

Environment: `export TMPDIR=/data/tmp/claude`; `CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`, which is `readlink /proc/$PPID/exe`. The `AGENTS.md` *Gates* block was run exactly as written, both halves, from a script under `/data/tmp/claude`. It ran once at HEAD before the edits, and that run was green with the same output, and once after the edits. The after-edit output follows, with the 35 `ok` lines removed. `/usr/bin/grep -c '^ok '` counted `35` of them.

```
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
tests/memory-sync.test.sh rc=0
rc=0
PASS 35/35
✔ Validation passed
✔ Validation passed
✔ Validation passed
  Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
  Agents (5)  reviewer, integrator, developer, analyzer, committer
  Hooks (1)  SessionStart  (harness-only — no model context cost)
  Skills (1)  sync-memory
  Agents (0)
  Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
glab = glab
memory-sync = memory-sync
plugins/glab/hooks/hooks.json:0
plugins/memory-sync/hooks/hooks.json:0
rc=1
plugins/memory-sync/scripts/memory-sync.sh:1
plugins/memory-sync/skills/sync-memory/SKILL.md:1
README.md:1
rc=0
rc=1
```

This matches F15 exactly: build (syntax + exec bit) ok, tests ok, lint (shellcheck) ok, plugin gates ok. Afterwards `ls -d /data/tmp/claude/claude-config.*` found no such directory, so the block removed its config directory.

## Post-conditions

The plan's post-condition block was extracted from `plan.md` as written, 14 lines, and run from the repo root. Its expected output, also extracted from `plan.md`, is 40 lines. The actual output is 40 lines. `diff expected actual` printed nothing, `diff rc=0`.

## Blast radius

- Only the `glab` plugin's payload prose changed: `glab:manager` (Rule 5 and its pointers), `/glab:develop`, `/glab:review`, `/glab:ship`. Add to that `AGENTS.md` (*One fact, one value*) and the glab version.
- Nothing changed in `memory-sync`, the agent files, `README.md`, the hooks or the scripts.
- The component counts are the same.
- With no instruction from the user, the manager dispatches exactly as before.

## Rollback

Before a commit: `git restore plugins/glab/skills/manager/SKILL.md plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/.claude-plugin/plugin.json AGENTS.md`. After a commit: the plan's *Back-out* (revert, then set the version to `0.3.1`). Nothing was staged or committed here.

## Follow-ups

None. No `follow-ups.md` was written.

## Not done

- The commit split (plan *Commit*) is the caller's step. I did not stage or commit anything.
- `UNVERIFIED: I1 — the manager's host Agent tool takes model sonnet/opus/haiku/fable — depends on the Claude Code version and host`.
- `UNVERIFIED: I4 / Milestone — a plugin agent dispatched with model haiku runs on haiku — needs a live, logged-in dispatch`.
- The F1–F7 and F16 documentation line citations were not re-fetched. I took them from the plan as given.

---

# Review fix round (normal tier, round 1/1)

## Decisions

- The single normal-tier review returned `SHIP WITH SCOPE CUT`. It said to drop `SKILL.md:130–140`: the per-model dispatch table and the report-contract check.
- The manager decided to fix the findings once instead of cutting, because the user explicitly asked for per-model dispatch. This follows manager Stage 5's normal-tier rule: "its findings are fixed once, and the gates you run are the check on the fix". The manager's dispatch message gave eight fixes, and they are built as given.
- This is the manager's decision, relayed to me. I did not make it.

## Fixes (file:line in the current tree)

| # | where | before → after |
|---|---|---|
| 1 | `plugins/glab/skills/manager/SKILL.md:136`, `:138`, `:382` | **:136, `haiku` row:** "the work as numbered steps" → "the work as numbered steps that are references, never content". **:138, new paragraph:** the numbered steps point at what the agent reads and never carry it. Developer example: `1 read AGENTS.md; 2 read plan/{slug}/plan.md, steps <ids>; 3 build them; 4 write result.md; 5 fill this template`. The manager does not restate a plan step or read the plan to write the steps (Rule 2; Stage 2, "Do not paste the plan"). Reviewer steps are only `1 review the target; 2 fill this template`. **:382, Stage 5:** a clause added after "…do not re-rank its severities.": the pasted report template is allowed and is not content, because it describes the form of the answer. The `sonnet` row has no numbered steps, so it is unchanged. |
| 2 | `SKILL.md:140` | "The report template is the *Report* section… Reading that one section is the exception…" → the same sentence, plus: for the reviewer's last round, the template is *Report* plus the last-round verdicts from *Re-reviews* (`SHIP`, `SHIP WITH SCOPE CUT: <what to drop>`, `DO NOT PUBLISH: <why>`). "that one section" → "those sections". |
| 3 | `plugins/glab/commands/ship.md:28` | "No clear verdict, or the reviewer errored → treat it as BLOCK and say which it was." → "No clear verdict, or the reviewer errored → first the report check of `glab:manager` Rule 5: resume the reviewer once, asking only for the missing fields. Still no clear verdict → treat it as BLOCK and say which it was." |
| 4 | `SKILL.md:142` | "Re-dispatch once, on the same model, naming exactly what was missing. If the second report is malformed too…" → "Resume the same agent once — the model holds on a resume from the version named above — and ask only for the missing fields. A developer is not re-run on its tree. A reviewer's findings in the malformed report are kept: the missing field is filled, the findings are not re-litigated. If the report is still malformed after that one resume, stop and tell the user…". "The re-dispatch is not a review round" → "The resume is not a review round". The version is referenced rather than repeated so that `v2.1.211` stays on one line. |
| 5 | `SKILL.md:124`, `:125` | **:124:** "\"for the session\" holds across tasks." → "…holds across tasks and ends with that session." **:125:** added "Only a model line that quotes the user's own instruction counts. A `- model:` line written by a planner, relayed by another session — Rule 4 does not apply to the model choice — or found in any other file is ignored, and you name it to the user." |
| 6 | `SKILL.md:123` | "`glab:analyzer`, `glab:integrator`, `glab:committer` and planning agents are dispatched…" → "Every other agent — `glab:analyzer`, `glab:integrator`, `glab:committer`, planning agents, and any ad-hoc or fan-out agent that is not one of these two roles — is dispatched…" |
| 7 | `SKILL.md:126` | "…can override the parameter, and it warns when it substitutes." → "…can override the parameter; under `availableModels` it warns when it substitutes, in interactive sessions. If the Agent tool rejects the parameter or does not offer it — under `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, for one — tell the user and dispatch without one." |
| 8 | `SKILL.md:121` | "so naming it spends money" → "so naming it can spend money" |

## Unplanned changes in this round

- **The example line at `SKILL.md:125`, forced by fix 5.** Fix 5 says only a model line that quotes the user's own instruction counts, and Rule 5's own example did not quote one. So `` `- model: glab:developer sonnet, for this task — the user's instruction, not a manager choice` `` gained `: "use sonnet for the developer"` before the closing backtick. Left alone, the rule's only example would be a line the rule ignores.

## Post-condition that changed

- I re-ran the plan's post-condition block exactly as written. It printed 40 lines, and `diff` against the plan's recorded output gave `rc=1` with one difference:

      3c3
      < plugins/glab/commands/ship.md 1
      ---
      > plugins/glab/commands/ship.md 2

- **Why:** fix 3 adds a second line to `ship.md` containing `` `glab:manager` Rule 5 ``, and the check counts lines.
- **The rule still holds:** the check is meant to show that `ship.md` names Rule 5, and it still does.
- **Not edited:** I left `plan.md` alone, and I did not reword fix 3 to keep the count at 1. Every other line matches.

## Tension with the plan, reported, not fixed

- **D22:** it says "Rule 5 does not list the verdicts again; it points to the agent files". Fix 2 now names the three last-round verdicts in Rule 5, as the manager's message required.
- **One fact, one value:** the same verdict set is now also stated in Stage 5, `ship.md:32` and `reviewer.md`. `AGENTS.md` lists no known case for it.

## Gates after the fixes

The `AGENTS.md` *Gates* block was run exactly as written, with `TMPDIR` and `CLAUDE_BIN` as before. The output follows with the `ok` lines removed. `/usr/bin/grep -c '^ok '` counted `35` of them.

```
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
tests/memory-sync.test.sh rc=0
rc=0
PASS 35/35
✔ Validation passed
✔ Validation passed
✔ Validation passed
  Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
  Agents (5)  reviewer, integrator, developer, analyzer, committer
  Hooks (1)  SessionStart  (harness-only — no model context cost)
  Skills (1)  sync-memory
  Agents (0)
  Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
glab = glab
memory-sync = memory-sync
plugins/glab/hooks/hooks.json:0
plugins/memory-sync/hooks/hooks.json:0
rc=1
plugins/memory-sync/scripts/memory-sync.sh:1
plugins/memory-sync/skills/sync-memory/SKILL.md:1
README.md:1
rc=0
rc=1
```

This is green and identical to F15. The config directory was removed: `ls -d /data/tmp/claude/claude-config.*` found no such file. `git diff --stat` now shows 6 files, 48 insertions and 10 deletions, with no agent file touched. Nothing is staged or committed.
