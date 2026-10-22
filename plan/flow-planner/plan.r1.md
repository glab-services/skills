tier: normal — payload text, one read-only hook script and its test, `AGENTS.md`, `README.md` and the manifest version; no full-tier trigger.

# flow-planner — cheaper plans, planners and developers

## Decisions

- effort: high, for the session — the user's words after the 2026-10-22 compact: "Subagent effort high (record the `- effort:` line in each plan)".
- D1 Findings are the *Findings* section of this file: the Write tool refused `plan/flow-planner/findings.md` for this subagent ("Subagents should return findings as text"), the fourth such refusal (IN1).
- D2 Size rule: `plan.md`, and `findings.md` when there is one, at most 48 KB each (`wc -c`); the final flow-cheaper-rounds plan was 155 KB and its first version 59 KB (F1).
- D3 Shape rule: a decision is one line, the choice and its reason in at most two sentences, evidence cited by finding id, never restated; a fact is written once (F1: decision lines averaged 563 chars).
- D4 Escape: a plan that cannot be split carries `- size: <n> KB — <why it is one plan>` under `## Decisions`, and the manager decides it under Rule 3; without one, an oversized plan goes back.
- D5 Amendments replace the text they change, in place, under the same id; no amendment section, "superseded" line or round marker. The `.r<n>` copies are the history (`[flow-cheaper-rounds/plan.md D10]` binds); the manager's overrule line stays (`[sync-local-edits/result-followups.md D9]` binds).
- D6 The rule lives in `glab:plan-first` Step 3 (size, shape) and Step 4 (amending); the manager checks size by `wc -c` alone at acceptance (item 6), because Rule 2 forbids reading the plan; the analyzer checks in-place amending on its re-check, the one reader of the diff.
- D7 Steps 5–7 and the three implementation-only repo rules move, byte for byte and with their numbers, to `plugins/glab/skills/plan-first/implement.md`; Steps 0–4 keep theirs, so no caller breaks (F2).
- D8 Not into `glab:developer` and not a new skill: rejected boundaries B1, B2.
- D9 No `glab:planner` agent in this plan: it buys no model or effort control a dispatch lacks (D2/D8 of feature-model-switch, D6 of subagent-effort bind), and the agent count should change once, with the analyzer split, in `flow-models-per-role` (F3).
- D10 Developer context rules are prose in `glab:developer` — read the contract once, gate output to a log with only its tail read, no re-read after Edit, Edit over Write, search before read — because no hook is shown to shorten a tool's output (F4).
- D11 No `scripts/gate.sh`: one inline line does the same, and a script brings a test and gate lines (F4).
- D12 The first context step becomes `GLAB_COMPACT_AT` thousand when set, default 300k, steps still every 100k; amends `[flow-cheaper-rounds/plan.md D45]` and `D47` by the variable only — the default is the user's absolute 300k limit (F5).
- D13 Rejected for the threshold: a per-model table and a fraction of the window — the hook cannot know the window, and the user set an absolute limit (F5).
- D14 When `GLAB_COMPACT_AT` is set and valid, the line reads `glab: context <n>k (last completed call; compact at <t>k)` in all three modes, so the manager learns the step from the line without reading the environment.
- D15 An invalid value (not `^[1-9][0-9]{0,5}$`) is a warning, not a failure: one stderr line, then the default; it is checked after the transcript is read, so every failure path still prints exactly one stderr line (F5).
- D16 An empty `GLAB_COMPACT_AT` is the same as unset, with no warning.
- D17 The manager, on a model whose window is not larger than the first step plus 100k, tells the user once and names `GLAB_COMPACT_AT`; the number is the user's, never the manager's (the user's 2026-10-20 instruction, F5).
- D18 `glab` `0.9.0` → `0.10.0`: features, nothing removed, so no `!`; `memory-sync` untouched.
- D19 One `glab:developer`: `manager/SKILL.md` is touched by S2 and S5 and `AGENTS.md` by S6 for every step's facts, so no split has disjoint files.
- D20 One commit with the plan folder, as `[flow-cheaper-rounds/plan.md D27]`: *One fact* wants each fact's files together.
- D21 `flow-models-per-role` stays a separate plan, after this one (F7); recommendation only, not a step.
- D22 New *One fact* entries: the plan size budget, the in-place amendment rule, and plan-first's step numbers per file; the context-hook entry gains the variable and the line's suffix.

## Findings

Base `cf614ec`, only `plan/` untracked. Throwaway copies lived under `$TMPDIR` and were removed (`ls "$TMPDIR" | grep -c flow-planner` → `0`).

### F0 Scope — every path

Changed: `plugins/glab/skills/plan-first/SKILL.md`, new `plugins/glab/skills/plan-first/implement.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`, `plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh`, `README.md`, `AGENTS.md`, `plugins/glab/.claude-plugin/plugin.json`.
Read, unchanged: `plugins/glab/commands/plan.md`, `commands/develop.md`, `commands/analyze.md`, `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/bootstrap/SKILL.md` (l. 62–66), `plugins/glab/skills/audit/SKILL.md` (l. 21, 69), `.claude-plugin/marketplace.json`.
Specs read: `docs/specs/workflow.md` (*Decisions that still bind*, *Open follow-ups*, *Incidents*); `docs/specs/marketplace.md` by search.

### F1 Plan length (proven)

    git show 2a1e919:plan/flow-cheaper-rounds/plan.md | wc -l     → 1056
    plan.r1 / r2 / r3 / final, lines/bytes                         → 522/58932, 787/104420, 920/126945, 1056/155371
    its ## Decisions: 68 "- " lines, mean 563 chars, 40 over 400, 11 over 800; 38520 bytes
    "Superseded" → 4; "*(round n …)*" markers → 11; "amend" (any case) → 39

The plan nearly tripled over three amendments, and its one-line decisions were paragraphs restating evidence. The o3 figures (plans of 441–849 lines; F4's developer) are the caller's measurements of another project: inferred here.

Where a rule can sit: `plan-first/SKILL.md` Step 3 (l. 67–81) says what a plan holds, nothing on size; Step 4's amending paragraph (l. 95) and `manager/SKILL.md` Stage 1b (l. 338) say "record(s) each changed choice under `## Decisions`", silent on the old text. The acceptance checklist (l. 266–276) says "until all five hold" (l. 268); `grep -rn "all five\|five hold" plugins README.md AGENTS.md` finds only that line. `agents/analyzer.md` *Re-checks* (l. 54–60) reads the `diff -u` of `plan.r<n>.md` against `plan.md`: the one reader that sees appended text.

### F2 plan-first's structure and callers (proven)

`SKILL.md`, 193 lines, 13291 bytes: Steps 0–4 (l. 14, 21, 57, 67, 83; amending l. 95); **Step 5 (97–128), Step 6 (130–141), Step 7 (143–147)**; *Repo Rules* (149): Service lifecycle (151–153), Nested repositories (155–156), Commits (158–161) — implementation and commit only — then Plan files are working files (163), One slug per task (165); Slug Naming (167), User Override (178), Quick Reference (182). Lines 97–161: 3708 bytes, 28 % of the file.

Callers (`grep -rn plan-first plugins README.md AGENTS.md`, and a search for step numbers):

| caller | relies on |
|---|---|
| `commands/plan.md` l. 6, 12, 13, 16 | loads it; "step 0", "Step 2", the waiver |
| `commands/develop.md` l. 2, 13, 54 | "glab:plan-first steps 5 to 7"; the waiver; "owns the command" (build, Step 5) |
| `manager/SKILL.md` l. 53–60, 272, 338, 439 | Rule 0c seam; "Step 1"; Stage 1b amendment; *Plan files are working files* |
| `bootstrap/SKILL.md` l. 64–66 | per-dispatch, and the seam |
| `agents/developer.md` l. 102 | *Plan files are working files*; does not load the skill |
| `audit/SKILL.md` l. 21, 69 | the workflow that runs on to implementation |
| `README.md` l. 9, 135; `AGENTS.md` *One fact* | the name and the file |

No caller names a step above 4 but `develop.md`'s "steps 5 to 7"; keeping 5–7 on the moved text keeps it true. Their substance is restated where a manager pipeline runs them: `developer.md` Steps 2–4 (l. 24–64), `integrator.md` Step 2. A session that implements without subagents still needs them.

A supporting file changes neither validation nor counts (proven: throwaway copy with `implement.md` added, fresh `CLAUDE_CONFIG_DIR`): `✔ Validation passed` for `plugins/glab` and `.`, `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`, `Agents (5)`. Observed in this session: the Skill tool put only `SKILL.md` and a "Base directory for this skill" line into context; that a sibling file costs nothing until read is inferred for other versions.

### F3 A `glab:planner` agent (inferred unless marked)

- Context: an agent body is its system prompt, the same tokens as the skill; the saving is the tool list (`*` for general-purpose versus five tools). Not measured.
- Content: plan-first stays a skill (`/glab:plan` runs it in the main session); an agent would restate Steps 0–4 or load the skill.
- Model and effort: planning agents take no `model` (`[feature-model-switch/plan.md D2]`), agent files set none (`D8`), no `effort:` key (`[subagent-effort/plan.md D6]`); the Agent tool's parameters work on any dispatch, so a file adds no control. Planner-on-Opus is `[flow-cheaper-rounds/follow-ups.md FUc]`.
- Facts: `Agents (5)` → 6 changes `AGENTS.md` *Gates*, `README.md` l. 9 and the *One fact* "what each plugin holds"; the analyzer split would change them again.
- The `findings.md` refusal (IN1) is not shown to depend on the agent type.

### F4 A developer's context (proven by reading; o3 inferred)

`developer.md` Step 1 (l. 11–22) reads the contract with no "once"; Step 3 (l. 42–56) says nothing of output size; Step 5 (l. 66–94) wants the exact command and outcome. `commands/develop.md` has no such rule; `manager/SKILL.md` Rule 2 (l. 90) is about the reply. o3: one developer peaked at 509k in one round, ~480k chars of tool output, ~305k of its own writes, `plan.md` read 3 times.
Enforceable? Prose only. UNVERIFIED: that a `PostToolUse` hook can shorten a built-in tool's output, and whether hooks fire inside a subagent and with which `transcript_path`. `BASH_MAX_OUTPUT_LENGTH` is a session-wide user setting, not the plugin's (inferred).

### F5 The first context step (proven by run)

`context-size.sh`: header l. 11–15, contract l. 23–29, the line l. 113, `stop` l. 122–145, `300000` at l. 140–141. The test's `run` (l. 24–33) runs `bash "$SCRIPT"`, so exported variables reach it; `stop_case` (l. 211–226) expects `glab: context ${want}k (last completed call)$MSG_TAIL` and appends to `stopouts`, judged by T19 (l. 284–289); T2 last (l. 291–293). Binding: `[flow-cheaper-rounds/plan.md D34]`, `D45`, `D46`, `D47`. The user, 2026-10-20 (session memory): "300k will be our work limit, it will be my hard compact limit for all future models"; on a smaller window, ask the user for the number.

Prototype (throwaway copy; the variable read after the transcript; fixture 140k, 145k, 160k):

    []        agent "glab: context 160k (last completed call)"; stop nothing
    [150]     agent "glab: context 160k (last completed call; compact at 150k)"
              stop {"systemMessage":"glab: context 160k (last completed call; compact at 150k) — a good point to /compact, or to /clear between tasks"}
    [abc] [0] [1234567]  stderr "glab context-size: GLAB_COMPACT_AT is not a whole number of thousands from 1 to 999999; using 300", stdout the default line
    all rc=0; bash -n and shellcheck on the copy rc=0

Inferred: a variable exported in the shell that starts Claude Code reaches its hooks (child processes). UNVERIFIED: that a settings file's `env` block does.

### F6 Baseline gates at `cf614ec` (proven)

Five `rc=0` lines; shellcheck `rc=0`; `PASS 35/35`; `PASS 21/21`; `✔ Validation passed` ×3; glab `Skills (14)`, `Agents (5)`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`; memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`; `glab = glab`, `memory-sync = memory-sync`; `:0` `:0` `rc=1`; `1` `1` `1` `rc=0`; no line `rc=1`.

### F7 `flow-models-per-role`: keep it separate (recommendation)

A model table as a default reverses Rule 5's "no instruction, no override" and `[feature-model-switch/plan.md D1]`, `D2`, `D8` — a question for the user that would stop this plan, which has none. Its analyzer split changes the agent count, and the planner agent belongs with it (F3). Merged, the plan would break the budget it introduces. Run this plan first: its rules hold on any model.

### Boundary

Chosen: the size and shape rules in plan-first (owner) with one mechanical check by the manager and one diff check by the analyzer; Steps 5–7 in a sibling file of the same skill; developer rules in the developer's own file; the threshold read inside the script from the environment. Rejected:
- B1 Steps 5–7 into `glab:developer`: a session implementing without subagents loses them, and "steps 5 to 7" points at nothing.
- B2 A `glab:implement` skill: `Skills (14)` → 15 in four files for text few sessions read.
- B3 A `PreToolUse` hook refusing an oversized `plan.md`: fires in every repo with `glab` enabled and stops a planner mid-write.
- B4 A per-model table or a fraction of the window for the threshold (D13).

## Milestone

`bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh` prints `PASS 24/24`, the same test run against the `cf614ec` script prints `FAIL 3/24`, and every gate in *After* prints its expected line. The Markdown rules have no runtime; their proof is the searches below.

## Steps

### Before

- B0 `git status --short -uall` shows only `plan/` untracked; `export TMPDIR=/data/tmp/claude`; the gates print F6.

### Processing

- **S1 `plugins/glab/skills/plan-first/`.**
  - Create `implement.md`: line 1 `# Plan First — implementation`; then one paragraph: "Steps 5 to 7 of `glab:plan-first`, kept apart so that a planning agent does not load them. Start them only once the plan is verified (Step 4) and, at full tier, approved."; then `SKILL.md` lines 97–147 (`## Step 5 — Implement` … Step 7's last bullet) byte for byte; then `## Repo Rules for the implementation` and lines 151–161 (Service lifecycle, Nested repositories, Commits) byte for byte. No frontmatter.
  - In `SKILL.md`, remove lines 97–148 and 151–162, and put in place of Steps 5–7:

        ## Steps 5 to 7 — Implement, E2E tests, unit tests

        They are in [`implement.md`](implement.md), beside this file, with the repo rules that bind only the implementation — service lifecycle, nested repositories, commits. Read it once the plan is verified (Step 4) and, at full tier, approved. **A planning agent stops at Step 4 and does not read it.**

  - After Step 3's last paragraph (l. 81), add:

        **Size and shape — every later agent reads the plan again.** The plan check, the developer, the conformance and the record check each read `plan.md` in full, round after round, so every line is paid for many times. Keep `plan.md`, and `findings.md` when there is one, at or under **48 KB** each (`wc -c`). A decision is one line: the choice and its reason, in at most two sentences; its evidence stays in the findings and is cited by id, never restated. Write a fact once, where it belongs, and cite it elsewhere. A plan that will not fit is usually two plans: split it. When it cannot be split, say why under `## Decisions` as `- size: <n> KB — <why it is one plan>`, and the manager decides (`glab:manager` Rule 3).

  - Replace Step 4's amending paragraph (l. 95) with:

        **Amending after a plan check.** Under `glab:manager` an amendment after `NOT BUILDABLE` is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:manager` Stage 1b). Change what the findings name and what that forces, and **replace the text you change, in place**: the step, the finding or the decision line is rewritten under its own id, a changed choice with its new reason. Never append an amendment section, a "superseded" line or a round marker beside the old text — the `plan.r<n>.md` copies the manager kept are the history; leave them as they are. A line the manager added to overrule a decision stays as the manager wrote it. Step 1 is not run again, except for a gap a finding opens.

  Verify: `python3 -I -c 'import subprocess as s; a=s.run(["git","show","cf614ec:plugins/glab/skills/plan-first/SKILL.md"],capture_output=True,text=True).stdout.splitlines(); b=open("plugins/glab/skills/plan-first/implement.md").read(); print("\n".join(a[96:147]) in b, "\n".join(a[150:161]) in b)'` → `True True`; `grep -c '^## Step [567] ' plugins/glab/skills/plan-first/SKILL.md` → `0`, in `implement.md` → `3`; `grep -c '^## Step [0-4] ' …/SKILL.md` → `5`; `grep -c 'Service lifecycle\|Nested repositories' …/SKILL.md` → `0`; `grep -c -F '**48 KB**' …/SKILL.md` → `1`; `grep -c 'replace the text you change, in place' …/SKILL.md` → `1`; `grep -c 'records\? each changed choice' …/SKILL.md` → `0`; `grep -c 'does not read it' …/SKILL.md` → `1`.

- **S2 `plugins/glab/skills/manager/SKILL.md`, the plan check.**
  - l. 268: "until all five hold" → "until all six hold".
  - After item 5 (l. 274), add:

        6. **Within its size.** `glab:plan-first` Step 3 caps `plan.md`, and `findings.md` when there is one, at 48 KB each. Check it by size alone, without reading them (Rule 2): `wc -c plan/{slug}/plan.md plan/{slug}/findings.md` and `grep -c '^- size: ' plan/{slug}/plan.md`. Over the cap with no `- size:` line: send it back to be split or cut. With one: that is a Rule 3 choice of yours — accept it, or send it back to be split.

  - l. 338: "changes what the findings name and what that forces, records each changed choice under `## Decisions`, and leaves" → "changes what the findings name and what that forces, replacing the changed text in place rather than adding beside it (`glab:plan-first` Step 4), and leaves".
  Verify: `grep -c 'until all six hold'` → `1`; `grep -c 'all five hold'` → `0`; `grep -c '^6\. \*\*Within its size\.\*\*'` → `1`; `grep -c 'replacing the changed text in place'` → `1`; `grep -c 'records each changed choice'` → `0`.

- **S3 `plugins/glab/agents/analyzer.md`.** In *Re-checks*, after the bullet that ends "the post-condition question included;" (l. 59), add:

        - for a plan check, an amendment that added text beside what it changes — an amendment section, a "superseded" line, a round marker, or an old step or decision left standing next to its new form — rather than replacing it in place (`glab:plan-first` Step 4): one finding, on that step or decision id;

  Verify: `grep -c 'rather than replacing it in place' plugins/glab/agents/analyzer.md` → `1`.

- **S4 `plugins/glab/agents/developer.md`.** Between Step 1 and Step 2 (after l. 22), add an unnumbered section, so no step number moves:

        ## Keep your context small

        Everything you read stays in your context and is paid for again on every later call. One developer that read whole test runs and its plan three times peaked past 500k tokens in a single round.

        - **Read the contract once.** After Step 1, re-open only the part you need — `grep -n` for the step id, then read by line range — never the whole plan again.
        - **Gate and test output go to a log; read its end and its failures.** In the temp directory the repo or host names, never `/tmp`:

              log=$(mktemp "${TMPDIR:?}/gate.XXXXXX"); <the gate command> >"$log" 2>&1; rc=$?; tail -n 30 "$log"; echo "rc=$rc"

          On a red gate, `grep -n` the log for the runner's failure lines and read around them by range. The tail and the `rc` are the gate output `result.md` records. Remove each log when you are done with it.
        - **Do not re-read a file after editing it.** Edit fails when it does not apply; check the change with `git diff -- <file>`.
        - **Edit, do not rewrite.** Change an existing file with Edit; Write is for a new file. Rewriting a whole file to change part of it puts the whole file through your context again.
        - **Search before you read.** `grep -n` first, then read the lines that matter; read a large file by range.

  Verify: `grep -c '^## Keep your context small' …/developer.md` → `1`; `grep -c -F 'tail -n 30 "$log"' …` → `1`; `grep -c '^## Step [1-5] ' …` → `5`.

- **S5 The first context step.**
  - `plugins/glab/scripts/context-size.sh`: just before `line=` (l. 113), read `GLAB_COMPACT_AT`: unset or empty → first step 300000, no suffix; matching `^[1-9][0-9]{0,5}$` → first step that many thousands, suffix `; compact at <v>k`; anything else → one stderr line `glab context-size: GLAB_COMPACT_AT is not a whole number of thousands from 1 to 999999; using 300`, then the default. The line becomes `glab: context ${k}k (last completed call${suffix})`. In `stop`, l. 140–141 compare with and subtract the first step instead of `300000`. Comments (`glab:comments`): the header names the variable, its default and its line suffix; why the default is absolute (the user's working limit, the same on every model); why not a per-model table or a fraction (the hook is not told the window); why an invalid value warns instead of failing (a typo must not silence the number) and why it is read after the transcript (each failure path keeps exactly one stderr line); the `stop` comment says "the first step" where it says 300k. Every path still ends `exit 0`.
  - `tests/context-size.test.sh`: `unset GLAB_COMPACT_AT` before T1, so T1–T21 run on the default whatever the caller exported; `stop_case`'s expected text gains `${SUFFIX:-}` before `)`, empty by default. New cases, each exporting the variable and unsetting it after:
    - **T22** `GLAB_COMPACT_AT=150`, T1's fixture: `agent` prints `glab: context 143k (last completed call; compact at 150k)` (PostToolUse), `prompt` the same (UserPromptSubmit); stderr empty.
    - **T23** `GLAB_COMPACT_AT=150`, `SUFFIX='; compact at 150k'`, through `stop_spec`: `'below 150k' '' 'P A100000 P R A140000'`; `'crossed 150k' 160 'A140000 P A145000 P A160000'`; `'same step' '' 'A160000 P A200000 P A240000'`; `'crossed 250k' 251 'A240000 P A245000 P A251000'`.
    - **T24** invalid: for each of `abc`, `0`, `1234567`, `15.5`, `-1`, `agent` on T1's fixture prints the default line with no suffix and stderr is exactly the warning; for `abc`, `stop` on `A250000 P A280000 P A310000` speaks the 310k default message with no suffix, with the warning on stderr — a direct `runt` with its own checks, since `stop_case` wants stderr empty; `GLAB_COMPACT_AT=` (empty) on `agent` prints the default line and nothing on stderr.
    - Order T1, T3–T18, T20–T24, T19, T2; T23's stop runs append to `stopouts` through `stop_case`, so T19 judges them.
  - `plugins/glab/skills/manager/SKILL.md` Rule 2: l. 101 — after "it adds one line, `glab: context <n>k (last completed call)`" add ", ending `; compact at <t>k)` when the user set `GLAB_COMPACT_AT`", and "When the context crosses 300k or a further 100k" → "When the context crosses the first step — 300k, or the user's `GLAB_COMPACT_AT` — or a further 100k"; l. 104 — "at the first handoff line at or past **300k**, and again at the first line past each further **100k** — 400k, 500k, … —" → "at the first handoff line at or past the first step — **300k**, or `<t>k` when the line names `compact at <t>k` — and again at the first line past each further **100k** —". After l. 104 add:

        - **A smaller window.** When your model's context window is not larger than the first step plus 100k — a 200k window under the default — tell the user once that the step is near or past the window, and that `GLAB_COMPACT_AT`, in thousands, exported in the shell that starts Claude Code, moves it. The number is the user's; never choose it yourself.

  - `README.md`, after "It never blocks or prolongs a turn." (l. 34): "300k is the default first step. On a model with a smaller context window, export `GLAB_COMPACT_AT` with the first step in thousands — `export GLAB_COMPACT_AT=150` in the shell that starts Claude Code — and the steps become 150k, 250k, …; every line then ends `; compact at 150k)`."
  Verify: the test prints `PASS 24/24`; `git show cf614ec:plugins/glab/scripts/context-size.sh >"$TMPDIR/fp-old.sh"; bash tests/context-size.test.sh "$TMPDIR/fp-old.sh" | tail -n 1; rm -f "$TMPDIR/fp-old.sh"` → `FAIL 3/24` (T22, T23, T24 fail); `grep -c -e '-ge 300000' -e '- 300000)' plugins/glab/scripts/context-size.sh` → `0` (no comparison or subtraction left on the literal); `grep -c GLAB_COMPACT_AT` → `≥1` in the script, the test, `manager/SKILL.md` (`≥2`) and `README.md`.

- **S6 `AGENTS.md` and the version.**
  - The context-hook *One fact* entry (l. 165–171): "the line `glab: context <n>k (last completed call)`" → "the line `glab: context <n>k (last completed call)`, with `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set"; "the steps 300k and every 100k after it" → "the first step 300k, or `GLAB_COMPACT_AT` thousand when set, and every 100k after it, and the warning for an invalid value". Files unchanged.
  - After the session-effort entry (it ends `` `README.md`). ``), turn its `.` into `;` and add: "the plan size budget — 48 KB each for `plan.md` and `findings.md`, and the `- size:` line (`plugins/glab/skills/plan-first/SKILL.md` Step 3, `plugins/glab/skills/manager/SKILL.md` acceptance checklist item 6); amendments replace the text they change, in place (`plugins/glab/skills/plan-first/SKILL.md` Step 4, `plugins/glab/skills/manager/SKILL.md` Stage 1b, `plugins/glab/agents/analyzer.md` *Re-checks*); `glab:plan-first`'s step numbers — 0 to 4 in `SKILL.md`, 5 to 7 in `implement.md` (`plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/plan-first/implement.md`, `plugins/glab/commands/plan.md`, `plugins/glab/commands/develop.md`, `plugins/glab/skills/manager/SKILL.md`)."
  - `plugins/glab/.claude-plugin/plugin.json`: `"version": "0.10.0"`.
  Verify: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.10.0`; `grep -rlF '48 KB' plugins AGENTS.md README.md | sort` → `AGENTS.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`; `grep -c 'GLAB_COMPACT_AT' AGENTS.md` → `≥1`; `grep -c 'implement.md' AGENTS.md` → `≥1`. Keep `48 KB` and `GLAB_COMPACT_AT` unbroken by line wrapping, so these searches find them.

### After

The gates of `AGENTS.md`, with `TMPDIR` exported, print exactly F6 except `PASS 24/24` for the context-size test: five `rc=0` lines; shellcheck `rc=0`; `PASS 35/35`; `PASS 24/24`; `✔ Validation passed` ×3; `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`, `Agents (5)  reviewer, integrator, developer, analyzer, committer`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`; memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`; `glab = glab`, `memory-sync = memory-sync`; `:0` `:0` `rc=1`; `1` `1` `1` `rc=0`; no line `rc=1`. `wc -c plan/flow-planner/plan.md` ≤ 49152. The S1–S6 searches print their values. Integration at normal tier is the milestone test; a live run with `GLAB_COMPACT_AT` set calls a model and is the user's option, not a step. Back out: revert the commit; with `GLAB_COMPACT_AT` unset, the hook behaves as at `0.9.0`.

Cannot discriminate, by design: the `grep -c … → 0` absence checks print `0` on an untouched tree too; each is paired with a presence check on the same file.

Tests added: T22, T23, T24 in `tests/context-size.test.sh`. Coverage, as a list: S5 by T22 (suffix, both context modes), T23 (moved step, step every 100k, suffix in `stop`), T24 (warning, default, empty value), T1–T21 (default unchanged); T19 and T2 over every run. S1–S4 and S6 are Markdown and JSON: no test; the searches above and the `plugin validate` gate cover them.

## Follow-ups

- FU1 A `glab:planner` agent — into `flow-models-per-role`, with the analyzer split (carries `[flow-cheaper-rounds/plan.md FU1]`); open.
- FU2 `[flow-cheaper-rounds/plan.md FU2]`, splitting Steps 5–7 out of `glab:plan-first`, is closed by S1.
- FU3 A size warning for a subagent's own context: needs proof that hooks fire inside a subagent and which `transcript_path` they get; open, UNVERIFIED.
- FU4 Whether a settings file's `env` block reaches a plugin hook; `README.md` names only the shell export; open, UNVERIFIED.
- FU5 The manager's own gate runs could use the developer's log template; not planned; open.
- FU6 A subagent's Write of `findings.md` is refused (IN1); plan-first still prescribes it at full tier (`[flow-cheaper-rounds/plan.md FU6]`); open.

## Incidents

- IN1 The Write tool refused `plan/flow-planner/findings.md` for this planning subagent with "Subagents should return findings as text, not write report files" — the fourth time (`docs/specs/workflow.md` *Incidents*); the findings are the *Findings* section above (D1).

## Record

After the push, `glab:manager` Stage 8 updates `docs/specs/workflow.md` — *How it works now*: the plan size and shape rule and where it is checked, `implement.md`, the developer's context rules, `GLAB_COMPACT_AT`; *Decisions that still bind*: D2–D7, D9, D10, D12–D17, noting D12 amends `[flow-cheaper-rounds/plan.md D45]` and `D47`; *Open follow-ups*: FU1, FU3–FU6, and `[flow-cheaper-rounds/plan.md FU1]` re-pointed to FU1; *Closed follow-ups*: `[flow-cheaper-rounds/plan.md FU2]` by FU2; *Incidents*: IN1 — and `docs/specs/marketplace.md`: the three new *One fact* entries, the context-hook entry's change, and `glab` `0.10.0`. No audit file.
