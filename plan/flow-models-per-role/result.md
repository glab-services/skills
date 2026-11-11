# Result — flow-models-per-role

Base `main` = `f7cdc57`. Nothing staged, committed or pushed. `plan/SESSION-HANDOFF.md` untouched.

## Stages

- B0 — done. On the clean tree: five `rc=0`, shellcheck `rc=0`, `PASS 35/35`, `PASS 24/24`, three `✔ Validation passed`, `Agents (5)  reviewer, integrator, developer, analyzer, committer`.
- S1 — done. New `plugins/glab/agents/planner.md`: frontmatter `:2-4` (`name`, `description`, `model: opus`, no `tools`), *Read first* `:9`, *What you do* `:14`, *Where you write* `:21`, *Report* `:27`.
- S2 — done. New `plugins/glab/agents/plan-analyzer.md`: frontmatter `:2-5` (`model: opus` `:4`, `tools: Read, Grep, Glob, Bash` `:5`), the one question `:7-9`, hand-off to `glab:analyzer` `:12`, *Step 1* `:14-24`, *Step 2 — do not run the plan's commands* `:26`, *The intent question* (plan-check bullet only) `:32`, *The plan check* `:40`, *Re-checks* `:44`, *Report* `:54` (verdicts `BUILDABLE`, `NOT BUILDABLE`, `BLOCK: target unresolved` only).
- S3 — done. `plugins/glab/agents/analyzer.md`: description `:3`, `model: sonnet` `:4`, hand-off line `:12`, `:18` "except in a final check", `:24` "except in a final check (below)", plan-check intent bullet, *The plan check* section, plan-check parts of *Re-checks* (`:77-80` now) and `BUILDABLE`/`NOT BUILDABLE` removed, revision line `:107` "in a final check".
- S4 — done. `model:` at `:4` of `developer.md` (`sonnet`), `reviewer.md` (`sonnet`), `integrator.md` (`sonnet`), `committer.md` (`haiku`); nothing else changed.
- S5 — done. `plugins/glab/skills/manager/SKILL.md`: Rule 0c `:53`; Rule 0d `:67`, `:71`; Rule 5 `:138-173` — heading `:138`, (a) table `:140-150`, (b) `:152`, (c) `:153`, (d) `:154`, (e) `:155` unchanged, (f) `:156`, (g) `:157`, (h) `:158`, (i) `:159`, (j) `:161`, `:165`, (k) unchanged; pipeline `:185`, `:186`, `:196`; Stage 1 `:289`; Stage 1b `:333`, `:337`, `:372`, `:376`; Stage 2 `:391`; Stage 5 `:455`.
- S6 — done. `commands/plan.md:6`; `commands/analyze.md:2`, `:6`, `:10` (no line added); `commands/develop.md:43`; `commands/review.md:8`; `commands/ship.md:16`.
- S7 — done. `README.md:9` (seven agents), new paragraph `:18-26`, `:30-33` (plan check `glab:plan-analyzer`, build and final check `glab:analyzer`); `:155` (now `:165`) unchanged.
- S8 — done. `AGENTS.md` *Gates*: model gate command `:57`, `Agents (7)` `:71`, new green bullet `:76`; *One fact*: round caps `:123`, model per role `:148-155`, severity `:161`, mapping/round copies `:172`, amendments `:217`, master `:232`, intent check `:235-238`, verdict lines `:241-244`.
- S9 — done. `plugins/glab/.claude-plugin/plugin.json` `"version": "0.12.0"`.
- A1, A2 — done (below). A3 — back-out is `git revert <commit>`, not run. I1 — the user's live step; UNVERIFIED, not run (calls models).

## Blocked

None.

## Unplanned changes

Wording adaptations the steps' literal text forced; no file outside the plan's list touched.

- S2: the copied *Step 4 — do not run the plan's commands* is headed *Step 2* in `plan-analyzer.md`, because Steps 2 and 3 (get the implementation, walk the plan) are not copied. In the copied *Step 1*, "except in a coverage or final check" became "except in a master check" and "except in a master check or a final check" became "except in a master check": in this file the master check is the only check that reads all of `index.md`. *The plan check* drops "skip Step 2" (there is no such step here). The intent bullet's report line keeps `planned:` only. *Report* drops "unplanned changes" (no implementation) and its last sentence says "A finding is reported" for "A divergence is reported". `BLOCK` reads "no plan, an empty delta, or a check that is not yours".
- S3: in *Re-checks* `:77`, removing the plan check's file pairs also removed the `diff -u <old> <new>` that reads them, and the now-redundant "for a conformance check," before "two tree ids". `:86` (`diff` and `git diff --quiet`, "the file pair or the two tree ids") is not named by S3 and is left as it was.
- S5 (f): the plan's replacement text says "as (g) says"; SKILL.md has no lettered bullets, so it reads "as the next bullet says". The D12 clause went into the same sentence: "A `/glab:review` or `/glab:ship` with no plan behind it, and the Stage 8 record's agents, have nowhere to record it".
- S5 (c): the carry list gained "each analyze round", and "through `/glab:develop`, `/glab:review`, `/glab:ship` or directly" became "through a `/glab:` command or directly", so the rule covers any role, as the step says.
- S5 Stage 2 `:391`: the clause sits after "(Rule 5)", ahead of the existing "None named, none passed.", which stays.
- S5 Stage 5 `:455` and S6 `review.md:8`, `ship.md:16`: the comma after the inserted "— … —" aside was dropped (`— and never choose`, `— at the effort`). `develop.md:43`: the aside ends the sentence, so it reads "pass none — the agent's definition sets its model. Never choose one yourself"; V9's string is matched in all three files.
- S6 `plan.md:6`: a full stop added after "skill", which ends the sentence now.

## Tests

No shell script or test changed. The script tests ran unchanged as gates: `tests/memory-sync.test.sh` `PASS 35/35`, `tests/context-size.test.sh` `PASS 24/24`, every other line `ok`.

Coverage (AGENTS.md *Tests*, as a list):

- S1 — V1 (no `tools:` line, `model: opus`), V2 (`plan.md:6`, `README.md:9`), V3, V7; plugin gate `Agents (7)` lists `planner`.
- S2 — V1, V2, V3, V4; plugin gate lists `plan-analyzer`.
- S3 — V1, V4.
- S4 — V1 and the model gate (seven named lines).
- S5 — V2 (awk per heading), V5, V6, V8.
- S6 — V2, V5, V9.
- S7 — V2, V3 (README), V6.
- S8 — V5 and the plugin gate block as S8 leaves it (model gate line, `Agents (7)`).
- S9 — `jq` check below.
- Not covered by any case: that a live dispatch runs on the frontmatter model and that the parameter overrides it (I1, the user's) — accepted because it calls models and costs money. That the prose of each adaptation above is right is not provable by search; it is Stage 5's.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root, after S1–S9.

Script gates (the four AGENTS.md commands; the two test runs went to logs under `$TMPDIR`, read by count and tail, then removed):

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh tests/memory-sync.test.sh tests/context-size.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh tests/memory-sync.test.sh tests/context-size.test.sh; echo "rc=$?"
    rc=0
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh   → exit=0; lines not "ok ": 1 (the last); PASS 35/35
    bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh       → exit=0; lines not "ok ": 1 (the last); PASS 24/24

Plugin gates (the AGENTS.md block as S8 leaves it, run verbatim; `claude` 2.1.310 on `PATH`, fresh `CLAUDE_CONFIG_DIR` under `$TMPDIR`, removed after — a later `ls "$TMPDIR" | grep -c claude-config` printed `0`):

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (7)  reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
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
    plugins/glab/agents/analyzer.md:model: sonnet
    plugins/glab/agents/committer.md:model: haiku
    plugins/glab/agents/developer.md:model: sonnet
    plugins/glab/agents/integrator.md:model: sonnet
    plugins/glab/agents/plan-analyzer.md:model: opus
    plugins/glab/agents/planner.md:model: opus
    plugins/glab/agents/reviewer.md:model: sonnet
    rc=0
    rc=1

Green as AGENTS.md states it.

S9:

    jq -r .version plugins/glab/.claude-plugin/plugin.json plugins/memory-sync/.claude-plugin/plugin.json
    0.12.0
    0.1.0

Plan checks (`/usr/bin/grep`, from the repo root):

- V1 — the model gate above: seven lines, `rc=0`. `sed -n '2,/^---$/p' plugins/glab/agents/planner.md` → `name: planner`, `description: …`, `model: opus`, `---` — no `tools:` line.
- V2 — awk on `SKILL.md`: `glab:plan-analyzer` → Rule 0d 1, Rule 5 1, *The pipeline* 1, Stage 1b 3; `glab:planner` → Rule 0c 1, Rule 0d 1, Rule 5 1, *The pipeline* 1, Stage 1 1, Stage 1b 1. `grep -n 'glab:plan-analyzer' commands/analyze.md` → `2:`, `6:`, `10:`. `grep -n 'glab:planner' commands/plan.md README.md` → `plan.md:6:`, `README.md:9:`.
- V3 — `grep -c 'CLAUDE.md'` → `planner.md:1`, `plan-analyzer.md:1`.
- V4 — `grep -c 'NOT BUILDABLE' plan-analyzer.md` → `3`; `grep -n 'NOT BUILDABLE\|## The plan check' analyzer.md` → nothing, `rc=1`; `grep -n 'in a plan check\|for a plan check\|master check\|coverage' analyzer.md` → one line, `12:` (the hand-off naming `glab:plan-analyzer`); `grep -c 'DIVERGES\|record check' analyzer.md` → `6`; `grep -n 'DIVERGES' plan-analyzer.md` → nothing, `rc=1`.
- V5 — `grep -rn 'These two roles only\|the developer and reviewer only\|model default\|neither agent definition sets' plugins AGENTS.md README.md` → nothing, `rc=1`; `git grep` of the same at `f7cdc57` → `AGENTS.md:145`, `SKILL.md:142`, `:145`, `:147`, `:148`.
- V6 — `grep -c 'CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches'` → `SKILL.md:1`, `README.md:1`; `grep -c 'CLAUDE_CODE_SUBAGENT_MODEL_FORCE' README.md` → `1`; at `f7cdc57` `git grep -c` of both prints nothing, `rc=1` (zero matches).
- V7 — the pattern on `planner.md` → nothing, `rc=1`; on `plan-first/SKILL.md` at `f7cdc57` → `22`.
- V8 — the three `-F` patterns on `SKILL.md` → nothing, `rc=1`; at `f7cdc57` → `:152`, `:156`, `:363`.
- V9 — `grep -c "pass none — the agent's definition sets its model"` → `develop.md:1`, `review.md:1`, `ship.md:1`; `grep -n 'ask which check' analyze.md` → `6:` only; at `f7cdc57` nothing, `rc=1`.
- Master *Final check* 2 — `grep -n 'These two roles only\|the developer and reviewer only' plugins AGENTS.md README.md -r` → nothing, `rc=1`; `grep -c 'glab:plan-analyzer'` → `SKILL.md:6`, `analyze.md:3`.

Size: `plan.md` 37180 bytes, under the 48 KB budget; `manager/SKILL.md` 61738 bytes (payload, no budget).

## Blast radius

- What changed: every installer that updates `glab` to `0.12.0` runs `glab:planner` and `glab:plan-analyzer` on `opus`; `glab:analyzer`, `glab:developer`, `glab:reviewer` and `glab:integrator` on `sonnet`; and `glab:committer` on `haiku`, set in each definition, so cost and model change for all of them. `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches these agents (documented, E1); `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` from v2.1.257 still overrides. `/glab:plan` now dispatches an agent instead of planning in the session that runs it. `/glab:analyze` now routes by check, and a plan or master check sent to `glab:analyzer` (or the reverse) ends `BLOCK: target unresolved`.
- Who relies on it: `glab:manager` (Rules 0c, 0d, 5, the pipeline, Stages 1, 1b, 2, 5), the commands `/glab:plan`, `/glab:analyze`, `/glab:develop`, `/glab:review`, `/glab:ship`, and this repo's `AGENTS.md` gates.
- Existing data: none. No script, hook, schema or stored format changed. Plan folders from before 0.12.0 are read as before.
- Roll back: `git revert <commit>`. Installed copies follow only when the user updates past `0.12.0`.
- UNVERIFIED: that a live dispatch honours the frontmatter `model` and that the parameter overrides it (I1, the user's step). Inferred from the docs (E1, E2) and the plugin gates; `plugin details` shows no model.

## Follow-ups

None written to `follow-ups.md`: the dispatch scope limits writes in the folder to this file. The plan's FU1–FU4 stand as written. FU1 also carries review finding R2.3 (`glab:plan-analyzer`, `glab:analyzer` and `glab:reviewer` have no `Skill` in `tools`): kept as one follow-up for a separate change, per D20 and the manager's decision in review round 1; `glab:planner` is no longer part of that gap, since R2.2 gave it a `tools` line with `Skill`. Found while building, out of scope:

- FUa — `manager/SKILL.md:156` (Rule 5, *Record it*) still gives `"use sonnet for the developer"` as its example `- model:` line. S5 (f) names only the edits it makes to that bullet. The developer's default is now `sonnet`, so the example records an override that changes nothing. Fix: an example that names a different model. Closed in review round 1 by R2.7 (`SKILL.md:156` now `glab:reviewer opus`).

## Not done

- I1 (live `/tasks` check) — the user's step; UNVERIFIED until run.
- Not verified here: E12's claim that the Agent tool accepts `model` ∈ `sonnet|opus|haiku|fable` (the plan already marks it UNVERIFIED); that the CLI's agent listing order is unstable (the plan's E6) — this run printed `planner, plan-analyzer` last.

## Review round 1

Normal tier, the one review round. Fixes are text only; glab stays `0.12.0`. Nothing staged or committed; `plan.md`, `master.md` and `plan/SESSION-HANDOFF.md` untouched — the decisions below that differ from the plan are the manager's to record.

Findings:

- R1.1 — fixed. `plugins/glab/agents/planner.md:3`: "for every amendment" (no "after a plan check or a final check").
- R1.2 — fixed. `plugins/glab/agents/analyzer.md:67` `built:` only; `:83` "the two tree ids"; `:97` "if the tree ships as it stands".
- R1.3 — fixed with R2.5. `plugins/glab/agents/plan-analyzer.md:58` `planned:`.
- R1.4 — fixed. `plugins/glab/skills/manager/SKILL.md:279`: "A stage session runs on the model the user starts it with; Rule 5 names the role's model or the recorded override, which you name when you hand off to it."
- R1.5 — fixed. `AGENTS.md:174-175`: `plan-analyzer.md` stays on the mapping/evidence/round-copy entry, marked "(all but the version copies)" — it states `map-<area>.md`, `evidence.md` and `<name>.r<n>.md` but not `master.v<n>.md`; taking it off would drop the three it does state.
- R2.1 — fixed. `planner.md:24` (a new sub-plan's line in the slug's index, when the dispatch grants it) and `:25` (a new master when the user changed the request, when the dispatch grants it, as `glab:plan-first` says). No file name or step number added (D18; V7 still silent).
- R2.2 — fixed. `planner.md:5` `tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch` (no `Agent`). No text outside `plan/` said the planner has no `tools` line or inherits every tool (a case-insensitive `/usr/bin/grep -rn` over every `*.md` outside `plan/` for "inherits every", "no `tools`" and "sets no `tools`" → nothing, `rc=1`). This reverses plan D5 and S1's "no `tools` line", and changes V1's second check (below).
- R2.3 — not fixed, by the manager's decision: D20 keeps the `Skill` gap of the agents with a `tools` list as one follow-up (FU1) for a separate change; no `Skill` added to `plan-analyzer.md`, `analyzer.md` or `reviewer.md`. FU1 records it (*Follow-ups* above).
- R2.4 — fixed. `plugins/glab/commands/analyze.md:6`: the check is named in the dispatch message or by the user, never in `$ARGUMENTS` (only the slug); a named final or record check → `glab:analyzer`; otherwise a `result.md` under `plan/$ARGUMENTS/` → the conformance check, `glab:analyzer`; none → the plan check, or the named master check, `glab:plan-analyzer`; a named check that is none of these there → ask. The final and record checks are routed by name before the `result.md` test because a slug with sub-plans has no `result.md` at its own level, so a `result.md`-first rule would send its final check to `glab:plan-analyzer`. This replaces plan D8 / S6's "otherwise ask which check".
- R2.5 — fixed. `plan-analyzer.md:56` statuses gain `unverified`; `:58` `planned:`.
- R2.6 — fixed. `analyzer.md:83` drops "the file pair"; `:105` `BLOCK` adds "or a check that is not yours".
- R2.7 — fixed. `SKILL.md:150`: "The plugin's author chose them for cost, and gave the reviewer no `haiku` default: it is the last gate. The user's own words still override any role, the reviewer included."; `:156` example now `- model: glab:reviewer opus, … "use opus for the reviewer"`. Closes FUa.
- R2.8 — fixed. `SKILL.md:166`: row "default — an agent with no definition, on Claude Code's own order | nothing — write it as Rule 0c and the stage say". V8's `` `opus`, default, `fable` `` stays absent.
- R2.9 — fixed. `README.md:22-23`: "From Claude Code v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches these agents"; V6's string stays on one line.
- R2.10 — fixed. "dispatched as `glab:manager` Rules 0d and 5 say" in `commands/analyze.md:6`, `commands/integrate.md:6`, `commands/commit.md:8`. `AGENTS.md`: the three files added to the model-per-role entry (`:155-156`) and, since the clause cites Rule 0d too and that entry is where `Rules 0d and 5` is listed, to the session-effort entry (`:210-211`). `commands/plan.md:6`, which already carried the clause from S6, is in neither entry; not changed here (no finding names it).

V checks whose expectation a fix changes:

- V1 — the second half (`sed -n '2,/^---$/p' planner.md` shows no `tools:` line) now shows `tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch` — deliberate, R2.2. The model-gate half is unchanged.
- V9 — still `6:` only for `ask which check`, but that line now asks only for a named check that does not fit the folder (R2.4), not for every unnamed check with a `result.md`.

Gates, after the fixes (`export TMPDIR=/data/tmp/claude`, repo root):

    for s in …; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    shellcheck …; echo "rc=$?"
    rc=0
    bash tests/memory-sync.test.sh …   → exit=0; lines not "ok ": 1 (the last); PASS 35/35
    bash tests/context-size.test.sh …  → exit=0; lines not "ok ": 1 (the last); PASS 24/24

Plugin gate block, as in `AGENTS.md` *Gates*, fresh `CLAUDE_CONFIG_DIR` under `$TMPDIR`, removed after (`ls "$TMPDIR" | grep -c claude-config` → `0`):

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (7)  reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
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
    plugins/glab/agents/analyzer.md:model: sonnet
    plugins/glab/agents/committer.md:model: haiku
    plugins/glab/agents/developer.md:model: sonnet
    plugins/glab/agents/integrator.md:model: sonnet
    plugins/glab/agents/plan-analyzer.md:model: opus
    plugins/glab/agents/planner.md:model: opus
    plugins/glab/agents/reviewer.md:model: sonnet
    rc=0
    rc=1

Green as `AGENTS.md` states it, model gate included.

Plan checks (`/usr/bin/grep`, repo root):

- V1 — model gate above: seven lines, `rc=0`; `planner.md` frontmatter: `name`, `description`, `model: opus`, `tools: …` (R2.2, above).
- V2 — awk on `SKILL.md`: `glab:plan-analyzer` → Rule 0d 1, Rule 5 1, *The pipeline* 1, Stage 1b 3; `glab:planner` → Rule 0c 1, Rule 0d 1, Rule 5 1, *The pipeline* 1, Stage 1 1, Stage 1b 1. `analyze.md` → `2:`, `6:`, `10:`. `plan.md:6:`, `README.md:9:`.
- V3 — `planner.md:1`, `plan-analyzer.md:1`.
- V4 — `NOT BUILDABLE` in `plan-analyzer.md` `3`; on `analyzer.md` nothing, `rc=1`; the plan-check pattern on `analyzer.md` → `12:` only; `DIVERGES\|record check` `6`; `DIVERGES` in `plan-analyzer.md` nothing, `rc=1`.
- V5 — nothing, `rc=1`.
- V6 — `SKILL.md:1`, `README.md:1`; `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` in `README.md` `1`.
- V7 — nothing, `rc=1`.
- V8 — nothing, `rc=1`.
- V9 — `develop.md:1`, `review.md:1`, `ship.md:1`; `ask which check` → `6:` only.
- S9 — `0.12.0`, `0.1.0`.
