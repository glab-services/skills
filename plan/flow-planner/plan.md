tier: normal — payload text, one read-only hook script and its test, `AGENTS.md`, `README.md` and the manifest version; no full-tier trigger.

# flow-planner — cheaper plans and developers, the first context step, `evidence.md`

Round 3: the user approved splitting round 2 (`plan.r2.md`) in two, so the low-risk part ships first. This plan, `glab` 0.9.0 → 0.10.0, keeps the developer's context rules, `GLAB_COMPACT_AT`, `implement.md`, the rename to `evidence.md`, the size budget and in-place amending. The master plan, sub-plans, the intent check, Stage 6b and plan-mode approval moved to `plan/flow-master-plan/` (0.10.0 → 0.11.0), which is built on this plan's tree; nothing here depends on it. Decision and step ids are round 2's: this plan carries D1–D22, D38 and D41, and the parts of S1, S2, S4, S5, S7 and S8 listed below (round 2's S3 and S6 are wholly in `flow-master-plan`). Evidence: `evidence.md` (F0–F9, F11, F14, *Boundary* B1–B4). Line numbers are at `cf614ec`; find each place by its quoted anchor.

## Decisions

- effort: high, for the session — the user's words after the 2026-10-22 compact: "Subagent effort high (record the `- effort:` line in each plan)".
- D1 Findings are `evidence.md`: a subagent's Write of `findings.md` is refused and `evidence.md` was accepted (F8, IN1).
- D2 `plan.md` and `evidence.md` at most 48 KB each (`wc -c`), because every later agent reads them again (F1: 155 KB, from 59 KB).
- D3 A decision is one line, choice and reason in at most two sentences, evidence cited by id, never restated; a fact is written once (F1).
- D4 A plan that cannot be split carries `- size: <n> KB — <why it is one plan>` under `## Decisions`, and the manager decides under Rule 3.
- D5 Amendments replace the text they change, in place, under the same id; the `.r<n>` copies are the history (`[flow-cheaper-rounds/plan.md D10]`), and the manager's overrule line stays (`[sync-local-edits/result-followups.md D9]`).
- D6 The manager checks size by `wc -c` alone (Rule 2 forbids reading the plan); the analyzer checks in-place amending on its re-check, the one reader of the diff.
- D7 Steps 5–7 and the three implementation-only repo rules move byte for byte, numbers kept, to `plan-first/implement.md`, so no caller breaks (F2).
- D8 Rejected homes for them: `glab:developer` and a new skill (B1, B2).
- D9 No `glab:planner` agent in this plan — the user's decision, carried: the agent count changes once, in `flow-models-per-role` (F3).
- D10 The developer's context rules (S5) are prose in `glab:developer` — the user's decision, carried; no hook is shown to shorten a tool's output (F4).
- D11 No `scripts/gate.sh`: one inline line does it (F4).
- D12 The first context step is `GLAB_COMPACT_AT` thousand when set, default 300k, then every 100k — the user's decision, carried; amends `[flow-cheaper-rounds/plan.md D45]` and `D47` by the variable only (F5).
- D13 No per-model table and no fraction of the window: the hook is not told the window (F5).
- D14 A set, valid value ends the line `; compact at <t>k)` in all three modes, so the manager reads the step from the line.
- D15 An invalid value (not `^[1-9][0-9]{0,5}$`) warns once on stderr and uses the default; read after the transcript, so each failure path keeps one stderr line (F5).
- D16 Empty is unset: no warning.
- D17 On a window not larger than the first step plus 100k the manager tells the user once and names the variable; the number is the user's (F5).
- D18 `glab` 0.9.0 → 0.10.0, nothing removed, so no `!`; `memory-sync` untouched.
- D19 One `glab:developer`: most steps share `manager/SKILL.md` or `AGENTS.md`.
- D20 One commit with the plan folder: *One fact* wants each fact's files together, and this plan has no sub-plans (D41).
- D21 `flow-models-per-role` stays a separate plan, after this one — the user's decision, carried (F7).
- D22 *One fact* changes as S8 says.
- D38 `evidence.md` and `evidence.r<n>.md` wherever the payload names the file; readers, and the manager's Stage 1b copy and `cmp`, still accept `findings.md` in a folder from before 0.10.0; amends `[flow-cheaper-rounds/plan.md D10]` and `D49` by the name only (F9, F11).
- D41 This plan runs under the 0.9.0 rules it changes: no `master.md`; the user's words are in D9, D10, D12, D21.

## Milestone

`bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh` prints `PASS 24/24`, and `FAIL 3/24` against the `cf614ec` script; every gate in *After* prints its line. The Markdown has no runtime: the searches prove it.

## Steps

### Before

- B0 `git status --short -uall` shows only `plan/` untracked; `export TMPDIR=/data/tmp/claude`; the gates print F14.

### Processing

- **S1 `plugins/glab/skills/plan-first/`.**
  - Create `implement.md`: line 1 `# Plan First — implementation`; then one paragraph: "Steps 5 to 7 of `glab:plan-first`, kept apart so that a planning agent does not load them. Start them only once the plan is verified (Step 4) and, at full tier, approved."; then `SKILL.md` lines 97–147 (`## Step 5 — Implement` … Step 7's last bullet) byte for byte; then `## Repo Rules for the implementation` and lines 151–161 (Service lifecycle, Nested repositories, Commits) byte for byte. No frontmatter.
  - In `SKILL.md`, remove lines 97–148 and 151–162; in place of Steps 5–7:

        ## Steps 5 to 7 — Implement, E2E tests, unit tests

        They are in [`implement.md`](implement.md), beside this file, with the repo rules that bind only the implementation — service lifecycle, nested repositories, commits. Read it once the plan is verified (Step 4) and, at full tier, approved. **A planning agent stops at Step 4 and does not read it.**

  - Step 1 (l. 23): "Write findings to `plan/{slug}/findings.md`. Include:" → "Write findings to `plan/{slug}/evidence.md` — not `findings.md`: Claude Code refuses a subagent's Write of a file by that name. Include:"
  - After Step 3's last paragraph (l. 81) add:

        **Size and shape — every later agent reads the plan again**, round after round, so every line is paid for many times. Keep `plan.md` and `evidence.md` at or under **48 KB** each (`wc -c`). A decision is one line: the choice and its reason, in at most two sentences; its evidence stays in `evidence.md` and is cited by id, never restated. Write a fact once, where it belongs, and cite it elsewhere. A plan that will not fit is usually two plans: split it. When it cannot be split, say why under `## Decisions` as `- size: <n> KB — <why it is one plan>`, and the manager decides (`glab:manager` Rule 3).

  - Replace Step 4's amending paragraph (l. 95) with:

        **Amending after a plan check.** Under `glab:manager` an amendment after `NOT BUILDABLE` is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:manager` Stage 1b). Change what the findings name and what that forces, and **replace the text you change, in place**: the step, the finding or the decision line is rewritten under its own id, a changed choice with its new reason. Never append an amendment section, a "superseded" line or a round marker beside the old text — the `<name>.r<n>.md` copies the manager kept are the history; leave them as they are. A line the manager added to overrule a decision stays as the manager wrote it. Step 1 is not run again, except for a gap a finding opens.

  - Quick Reference: Analyze row → `` `plan/{slug}/evidence.md` ``.
  Verify: `python3 -I -c 'import subprocess as s; a=s.run(["git","show","cf614ec:plugins/glab/skills/plan-first/SKILL.md"],capture_output=True,text=True).stdout.splitlines(); b=open("plugins/glab/skills/plan-first/implement.md").read(); print("\n".join(a[96:147]) in b, "\n".join(a[150:161]) in b)'` → `True True`; in `SKILL.md`: `grep -c '^## Step [567] '` → `0` (in `implement.md` → `3`); `grep -c '^## Step [0-4] '` → `5`; `grep -c 'Service lifecycle\|Nested repositories'` → `0`; `grep -c -F '**48 KB**'` → `1`; `grep -c 'replace the text you change, in place'` → `1`; `grep -c 'records\? each changed choice'` → `0`; `grep -c 'does not read it'` → `1`; `grep -c 'findings\.md'` → `1` (the reason in Step 1); `grep -c 'evidence\.md'` → `≥3`.

- **S2 `plugins/glab/skills/manager/SKILL.md` — names, the acceptance checklist, Stage 1b's amendment.**
  - `findings.md` → `evidence.md` at l. 53, 175, 197; l. 92 and 262 stay. l. 338: "and `findings.md` to `findings.r<n>.md` when there is one," → "and `evidence.md` to `evidence.r<n>.md` when there is one — `findings.md` to `findings.r<n>.md` in a folder from before `glab` 0.10.0 —"; l. 340: "(and the same for `findings.md`)" → "(and the same for `evidence.md`, or `findings.md` in a folder from before `glab` 0.10.0)" (D38).
  - Acceptance checklist (l. 268): "until all five hold" → "until all six hold"; after item 5 (l. 274) add:

        6. **Within its size.** `glab:plan-first` Step 3 caps `plan.md` and `evidence.md` at 49152 bytes (48 KB) each. Check it by size alone, without reading them (Rule 2): `wc -c` on each that exists, and `grep -c '^- size: ' plan/{slug}/plan.md`. Over the cap with no `- size:` line: send it back to be split or cut. With one: that is a Rule 3 choice of yours — accept it, or send it back to be split.

  - Stage 1b, the amendment paragraph (l. 338): "records each changed choice under `## Decisions`, and leaves" → "replacing the changed text in place rather than adding beside it (`glab:plan-first` Step 4), and leaves".
  Verify: `grep -c 'findings\.md'` → `2` (the older-folder clauses at l. 338 and 340; l. 262 names `findings-<area>.md`); `grep -c 'findings\.r<n>'` → `1` (l. 338); `grep -c 'in a folder from before `glab` 0\.10\.0'` → `2`; `grep -c 'evidence\.md'` → `≥5`; `grep -c 'evidence\.r<n>'` → `1`; `grep -c 'until all six hold'` → `1`; `grep -c 'all five hold'` → `0`; `grep -c '^6\. \*\*Within its size\.\*\*'` → `1`; `grep -c '49152 bytes (48 KB)'` → `1`; `grep -c 'replacing the changed text in place'` → `1`; `grep -c 'records each changed choice'` → `0`.

- **S4 `plugins/glab/agents/analyzer.md`.**
  - l. 16: "`plan/<slug>/findings.md` and every" → "`plan/<slug>/evidence.md` (`findings.md` in a folder from before `glab` 0.10.0) and every".
  - *Re-checks* l. 56: "`plan/<slug>/plan.r<n>.md` and `plan/<slug>/plan.md`, and `findings.r<n>.md` with `findings.md` when there are" → "each `<name>.r<n>.md` the manager kept with its current file — `plan.md`, `evidence.md`"; after the bullet ending "the post-condition question included;" (l. 59) add the bullet: "- for a plan check, an amendment that added text beside what it changes — an amendment section, a "superseded" line, a round marker, or an old step or decision left standing next to its new form — rather than replacing it in place (`glab:plan-first` Step 4): one finding, on that step or decision id;".
  Verify: `grep -c 'rather than replacing it in place'` → `1`; `grep -c 'findings\.md'` → `1` (the older-folder clause); `grep -c 'findings\.r<n>'` → `0`; `grep -c 'evidence\.md'` → `≥2`.

- **S5 `plugins/glab/agents/developer.md`.**
  - l. 17: "`plan/<slug>/findings.md`, when there is one" → "`plan/<slug>/evidence.md` — `findings.md` in a folder from before `glab` 0.10.0 — when there is one".
  - l. 107: "**Never edit `plan.md`, `findings.md`, `questions.md`," → "**Never edit `plan.md`, `evidence.md` or `findings.md`, `questions.md`,".
  - Between Step 1 and Step 2 (after l. 22) add, unnumbered so no step number moves:

        ## Keep your context small

        Everything you read stays in your context and is paid for again on every later call. One developer that read whole test runs and its plan three times peaked past 500k tokens in a single round.

        - **Read the contract once.** After Step 1, re-open only the part you need — `grep -n` for the step id, then read by line range — never the whole plan again.
        - **Gate and test output go to a log; read its end and its failures.** In the temp directory the repo or host names, never `/tmp`:

              log=$(mktemp "${TMPDIR:?}/gate.XXXXXX"); <the gate command> >"$log" 2>&1; rc=$?; tail -n 30 "$log"; echo "rc=$rc"

          On a red gate, `grep -n` the log for the runner's failure lines and read around them by range. The tail and the `rc` are the gate output `result.md` records. Remove each log when you are done with it.
        - **Do not re-read a file after editing it.** Edit fails when it does not apply; check the change with `git diff -- <file>`.
        - **Edit, do not rewrite.** Change an existing file with Edit; Write is for a new file. Rewriting a whole file to change part of it puts the whole file through your context again.
        - **Search before you read.** `grep -n` first, then read the lines that matter; read a large file by range.

  Verify: `grep -c '^## Keep your context small'` → `1`; `grep -c -F 'tail -n 30 "$log"'` → `1`; `grep -c '^## Step [1-5] '` → `5`; `grep -c 'evidence\.md'` → `≥2`.

- **S7 The first context step.**
  - `plugins/glab/scripts/context-size.sh`: just before `line=` (l. 113), read `GLAB_COMPACT_AT`: unset or empty → first step 300000, no suffix; matching `^[1-9][0-9]{0,5}$` → that many thousands, suffix `; compact at <v>k`; anything else → one stderr line `glab context-size: GLAB_COMPACT_AT is not a whole number of thousands from 1 to 999999; using 300`, then the default. The line becomes `glab: context ${k}k (last completed call${suffix})`. In `stop`, l. 140–141 compare with and subtract the first step instead of `300000`. Comments (`glab:comments`): the header names the variable, its default and its suffix; why the default is absolute (the user's working limit, the same on every model); why not a per-model table or a fraction (the hook is not told the window); why an invalid value warns instead of failing (a typo must not silence the number) and why it is read after the transcript (each failure path keeps exactly one stderr line); the `stop` comment says "the first step" where it says 300k. Comments that become untrue are rewritten in place: l. 11–12 → "shows the USER one line when the context has crossed the first step - 300k, or GLAB_COMPACT_AT thousand when set - or a further 100k after it"; l. 15 → "The line is `glab: context <n>k (last completed call)`, n in thousands, rounded up; with a valid GLAB_COMPACT_AT it ends `; compact at <t>k)` instead."; l. 23–25, after "and no JSON." add "The one stderr line that is not a failure is the GLAB_COMPACT_AT warning: the run goes on with the default and still prints its JSON."; l. 52 "at or past 300k" → "at or past the first step". Every path still ends `exit 0`.
  - `tests/context-size.test.sh`: `unset GLAB_COMPACT_AT` before T1, so T1–T21 run on the default whatever the caller exported; `stop_case`'s expected text gains `${SUFFIX:-}` before `)`, empty by default. New cases, each exporting the variable and unsetting it after:
    - **T22** `GLAB_COMPACT_AT=150`, T1's fixture: `agent` prints `glab: context 143k (last completed call; compact at 150k)` (PostToolUse), `prompt` the same (UserPromptSubmit); stderr empty.
    - **T23** `GLAB_COMPACT_AT=150`, `SUFFIX='; compact at 150k'`, through `stop_spec`: `'below 150k' '' 'P A100000 P R A140000'`; `'crossed 150k' 160 'A140000 P A145000 P A160000'`; `'same step' '' 'A160000 P A200000 P A240000'`; `'crossed 250k' 251 'A240000 P A245000 P A251000'`.
    - **T24** invalid: for each of `abc`, `0`, `1234567`, `15.5`, `-1`, `agent` on T1's fixture prints the default line with no suffix and stderr is exactly the warning; for `abc`, `stop` on `A250000 P A280000 P A310000` speaks the 310k default message with no suffix, with the warning on stderr — a direct `runt` with its own checks, since `stop_case` wants stderr empty; `GLAB_COMPACT_AT=` (empty) on `agent` prints the default line and nothing on stderr.
    - Order T1, T3–T18, T20–T24, T19, T2; T23's stop runs append to `stopouts` through `stop_case`, so T19 judges them.
  - `manager/SKILL.md` Rule 2: l. 101 — after "it adds one line, `glab: context <n>k (last completed call)`" add ", ending `; compact at <t>k)` when the user set `GLAB_COMPACT_AT`", and "When the context crosses 300k or a further 100k" → "When the context crosses the first step — 300k, or the user's `GLAB_COMPACT_AT` — or a further 100k"; l. 104 — "at the first handoff line at or past **300k**, and again at the first line past each further **100k** — 400k, 500k, … —" → "at the first handoff line at or past the first step — **300k**, or `<t>k` when the line names `compact at <t>k` — and again at the first line past each further **100k** —". After l. 104 add:

        - **A smaller window.** When your model's context window is not larger than the first step plus 100k — a 200k window under the default — tell the user once that the step is near or past the window, and that `GLAB_COMPACT_AT`, in thousands, exported in the shell that starts Claude Code, moves it. The number is the user's; never choose it yourself.

  Verify: the test prints `PASS 24/24`; `git show cf614ec:plugins/glab/scripts/context-size.sh >"$TMPDIR/fp-old.sh"; bash tests/context-size.test.sh "$TMPDIR/fp-old.sh" | tail -n 1; rm -f "$TMPDIR/fp-old.sh"` → `FAIL 3/24` (T22, T23, T24 fail); `grep -c -e '-ge 300000' -e '- 300000)' plugins/glab/scripts/context-size.sh` → `0`; `grep -c GLAB_COMPACT_AT` → `≥1` in the script and the test, `≥2` in `manager/SKILL.md`; in `manager/SKILL.md` (each `0` at `cf614ec`): `grep -c 'crosses the first step'` → `1`, `grep -c 'when the line names'` → `1`, `grep -c 'A smaller window'` → `1`; in the script: `grep -c 'is not a failure is the GLAB_COMPACT_AT warning'` → `1`, `grep -c 'at or past 300k'` → `0`. Keep each searched phrase unbroken by line wrapping.

- **S8 `README.md`, `AGENTS.md` and the version.**
  - `README.md`, after "It never blocks or prolongs a turn." (l. 34): "300k is the default first step. On a model with a smaller context window, export `GLAB_COMPACT_AT` with the first step in thousands — `export GLAB_COMPACT_AT=150` in the shell that starts Claude Code — and the steps become 150k, 250k, …; every line then ends `; compact at 150k)`."
  - `AGENTS.md` *One fact* — three anchors below wrap there, so match them across the line break: "the mapping files `map-<area>.md` and the round copies" at l. 158–159, "the line `glab: context <n>k (last completed call)`" at l. 167–168, "the steps 300k and every 100k after it" at l. 168–169. The context-hook entry: "the line `glab: context <n>k (last completed call)`" → "the line `glab: context <n>k (last completed call)`, with `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set", and "the steps 300k and every 100k after it" → "the first step 300k, or `GLAB_COMPACT_AT` thousand when set, and every 100k after it, and the warning for an invalid value"; the entry "the mapping files `map-<area>.md` and the round copies `<name>.r<n>.md`" → "the mapping files `map-<area>.md`, the evidence file `evidence.md` — a subagent's Write of `findings.md` is refused — and the round copies `<name>.r<n>.md`" (files unchanged). After the session-effort entry (it ends `` `README.md`). ``), turn its `.` into `;` and add the entries below, each path but `README.md` written in full from `plugins/glab/`, as the other entries are: "the plan size budget — 48 KB each for `plan.md` and `evidence.md`, and the `- size:` line (`skills/plan-first/SKILL.md` Step 3, `skills/manager/SKILL.md` acceptance checklist item 6); amendments replace the text they change, in place (`skills/plan-first/SKILL.md` Step 4, `skills/manager/SKILL.md` Stage 1b, `agents/analyzer.md` *Re-checks*); `glab:plan-first`'s step numbers — 0 to 4 in `SKILL.md`, 5 to 7 in `implement.md` (`skills/plan-first/SKILL.md`, `skills/plan-first/implement.md`, `commands/plan.md`, `commands/develop.md`, `skills/manager/SKILL.md`)."
  - The version rule in `AGENTS.md` *Rules* is not changed.
  - `plugins/glab/.claude-plugin/plugin.json`: `"version": "0.10.0"`.
  Verify: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.10.0`; `grep -rlF '48 KB' plugins AGENTS.md README.md | sort` → `AGENTS.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`; in `AGENTS.md`: `grep -c 'GLAB_COMPACT_AT'` → `≥1`, `grep -c 'implement.md'` → `≥1`, `grep -c 'evidence.md'` → `≥2`, and (each `0` at `cf614ec`) `grep -c -F 'with `; compact at <t>k` before the `)`'` → `1`, `grep -c 'the warning for an invalid value'` → `1`, `grep -c 'amendments replace the text they change, in place'` → `1`, `grep -c -F '`README.md`);'` → `6` (`5` at `cf614ec`) and `grep -c -F '`README.md`).'` → `0` (`1` at `cf614ec`, the session-effort entry); `grep -c 'GLAB_COMPACT_AT' README.md` → `≥1`; `git diff cf614ec -- AGENTS.md | grep -c '^[-+].*raises that plugin'` → `0` (the version rule is `flow-master-plan`'s). Keep each searched phrase unbroken by line wrapping.

### After

The gates of `AGENTS.md`, with `TMPDIR` exported, print exactly the lines of F14, with `PASS 24/24` in place of `PASS 21/21`: `Skills (14)` and `Agents (5)` do not change, since `implement.md` is not a skill (F2). Then `grep -rc 'findings\.md' plugins README.md AGENTS.md | grep -v ':0$'` → `analyzer.md:1`, `developer.md:2`, `manager/SKILL.md:2`, `plan-first/SKILL.md:1`, `AGENTS.md:1` (older folders and the reasons); `git diff --stat cf614ec -- plugins/glab/commands plugins/glab/scripts/manager-bootstrap.sh` prints nothing (round 2's S6 and S3 are `flow-master-plan`'s); `wc -c` of `plan.md` and `evidence.md` ≤ 49152; the S1, S2, S4, S5, S7 and S8 searches print their values. Integration at normal tier is the milestone test. Back out: revert the commit; with `GLAB_COMPACT_AT` unset the hook behaves as at `0.9.0`.

Cannot discriminate, by design: each `grep -c … → 0` prints `0` on an untouched tree too, so each is paired with a presence check on its file; the empty diff of the commands guards against a stray edit only.

Tests added: T22, T23, T24 in `tests/context-size.test.sh`. Coverage: S7's script by T22 (suffix, both context modes), T23 (moved step, steps of 100k, suffix in `stop`), T24 (warning, default, empty), T1–T21 (default unchanged), T19 and T2 over every run. S1, S2, S4, S5, S8 and S7's `manager/SKILL.md` text are Markdown and JSON with no test: the searches, `bash -n`, shellcheck and `plugin validate` cover them — accepted, as Markdown has no runtime.

## Follow-ups

- FU1 A `glab:planner` agent and the analyzer's two kinds — into `flow-models-per-role` (carries `[flow-cheaper-rounds/plan.md FU1]`); open.
- FU2 `[flow-cheaper-rounds/plan.md FU2]`, Steps 5–7 out of `glab:plan-first`: closed by S1.
- FU3 A size warning for a subagent's own context: needs proof that hooks fire inside a subagent, and with which `transcript_path`; open, UNVERIFIED.
- FU4 Whether a settings file's `env` block reaches a plugin hook; open, UNVERIFIED.
- FU5 The manager's own gate runs could use the developer's log template; open.
- FU6 `[flow-cheaper-rounds/plan.md FU6]`, a subagent cannot write `findings.md`: closed by `evidence.md` (S1, S2, S4, S5; F8).
- FU8 Which other names the Write rule refuses (`summary.md`, `report.md`) is untested (F8); open.

FU7 and FU9 are `flow-master-plan`'s.

## Incidents

- IN1 The Write tool refused `plan/flow-planner/findings.md` to this planning subagent — "Subagents should return findings as text, not write report files" — in round 1 and in round 2's probe (F8); the findings are `evidence.md` (D1).

## Record

After the push, `glab:manager` Stage 8 updates `docs/specs/workflow.md` — *How it works now*: the size and shape rule, `implement.md`, the developer's context rules, `GLAB_COMPACT_AT`, `evidence.md`; *Decisions that still bind*: D2–D7, D9, D10, D12–D17, D21, D38, naming what D12 amends (`[flow-cheaper-rounds/plan.md D45]`, `D47`) and what D38 amends (`[flow-cheaper-rounds/plan.md D10]`, spec l. 643, `findings.r<n>.md` → `evidence.r<n>.md`; `D49`, l. 682, the `cmp` of `findings.md` → `evidence.md`; both keep `findings.md` for a folder from before 0.10.0); *Open follow-ups*: FU1, FU3–FU5, FU8, `[flow-cheaper-rounds/plan.md FU1]` re-pointed to FU1; *Closed*: `[flow-cheaper-rounds/plan.md FU2]` (FU2) and `FU6` (FU6); *Incidents*: IN1 — and `docs/specs/marketplace.md`: the *One fact* changes of S8, `glab` `0.10.0`. No audit file.
