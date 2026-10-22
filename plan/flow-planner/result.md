# Result — flow-planner

Base `cf614ec`, `glab` 0.9.0 → 0.10.0. Built from `plan.md` and `evidence.md` as they stand after the Stage 1b round-1 fixes; `plan.r*.md`, `evidence.r*.md` and `plan/flow-master-plan/` not read. Nothing staged or committed.

## Stages

- **B0** done. `git status --short -uall` → only `?? plan/...` entries; `TMPDIR=/data/tmp/claude`; baseline gates printed F14 (`PASS 35/35`, `PASS 21/21`, the same plugin lines as *Gates* below).
- **S1** done.
  - new `plugins/glab/skills/plan-first/implement.md` (69 lines): l. 1 heading, l. 3 the paragraph, l. 5–55 = `cf614ec` `SKILL.md` l. 97–147, l. 57 `## Repo Rules for the implementation`, l. 59–69 = `cf614ec` l. 151–161. Built by `sed -n` from `git show cf614ec:…`, not retyped.
  - `plugins/glab/skills/plan-first/SKILL.md`: l. 23 Step 1 → `evidence.md` and the reason; l. 83 *Size and shape* paragraph after Step 3; l. 97 Step 4 amending paragraph replaced; l. 99–101 `## Steps 5 to 7 — …` pointer in place of `cf614ec` l. 97–148; `cf614ec` l. 151–162 removed (`## Repo Rules` keeps *Plan files are working files* and *One slug per task*); l. 128 Quick Reference Analyze row → `evidence.md`.
  - Verify (run): `True True`; `^## Step [567] ` SKILL `0`, implement `3`; `^## Step [0-4] ` `5`; Service lifecycle/Nested repositories `0`; `**48 KB**` `1`; `replace the text you change, in place` `1`; `records\? each changed choice` `0`; `does not read it` `1`; `findings\.md` `1`; `evidence\.md` `3`.
- **S2** done. `plugins/glab/skills/manager/SKILL.md`: l. 53, 176, 198 `findings.md` → `evidence.md`; l. 269 "until all six hold"; l. 276 item 6 *Within its size*; l. 340 Stage 1b copy (`evidence.r<n>.md`, older-folder clause) and "replacing the changed text in place …"; l. 342 `cmp` clause with the older-folder `findings.md`. (Line numbers are +1 from the plan's after S7's added bullet.)
  - Verify (run): `findings\.md` `2` (l. 340, 342); `findings\.r<n>` `1`; older-folder phrase `2`; `evidence\.md` `6`; `evidence\.r<n>` `1`; `until all six hold` `1`; `all five hold` `0`; item 6 `1`; `49152 bytes (48 KB)` `1`; `replacing the changed text in place` `1`; `records each changed choice` `0`.
- **S4** done. `plugins/glab/agents/analyzer.md`: l. 16 `evidence.md` with the older-folder clause; l. 56 the file pairs → "each `<name>.r<n>.md` the manager kept with its current file — `plan.md`, `evidence.md`"; l. 60 new bullet on amendments added beside the old text.
  - Verify (run): `rather than replacing it in place` `1`; `findings\.md` `1`; `findings\.r<n>` `0`; `evidence\.md` `2`.
- **S5** done. `plugins/glab/agents/developer.md`: l. 17 `evidence.md` with the older-folder clause; l. 24–36 `## Keep your context small` between Step 1 and Step 2; l. 121 "Never edit `plan.md`, `evidence.md` or `findings.md`, …".
  - Verify (run): `^## Keep your context small` `1`; `tail -n 30 "$log"` `1`; `^## Step [1-5] ` `5`; `evidence\.md` `2`.
- **S7** done.
  - `plugins/glab/scripts/context-size.sh`: header l. 11–14 (the first step), l. 16 (the suffix), l. 18–26 new paragraph (variable, default, suffix; why absolute; why no per-model table or fraction; why warn not fail; why read after the transcript); l. 37 contract sentence on the warning; l. 65 "at or past the first step"; l. 126–139 the read (`first`, `suffix`, the warning) just before `line=` at l. 141; l. 151–153 `stop` comment; l. 168–169 compare with and subtract `$first`. Every path still ends `exit 0`.
  - `tests/context-size.test.sh`: l. 74 `unset GLAB_COMPACT_AT` before T1; l. 213 comment and l. 224 `${SUFFIX:-}` in `stop_case`; l. 287–296 T22, l. 298–307 T23, l. 309–332 T24, all before T19 and T2.
  - `plugins/glab/skills/manager/SKILL.md` Rule 2: l. 101 the suffix clause and "crosses the first step — …"; l. 104 the first-step wording; l. 105 new bullet *A smaller window*.
  - Verify (run): `PASS 24/24`; against `git show cf614ec:…context-size.sh` → `FAIL 3/24` (T22, T23, T24 the only FAIL lines); `-ge 300000`/`- 300000)` `0`; `GLAB_COMPACT_AT` script `11`, test `17`, `manager/SKILL.md` `2`; `crosses the first step` `1`; `when the line names` `1`; `A smaller window` `1`; `is not a failure is the GLAB_COMPACT_AT warning` `1`; `at or past 300k` `0`. Also run with `GLAB_COMPACT_AT=150` exported by the caller → `PASS 24/24` (the `unset` holds).
- **S8** done. `README.md` l. 35–38 the `GLAB_COMPACT_AT` sentences after "It never blocks or prolongs a turn."; `AGENTS.md` l. 158–161 the evidence-file *One fact* entry, l. 169–174 the context-hook entry, l. 200–212 the session-effort entry's `.` → `;` and the three new entries; `plugins/glab/.claude-plugin/plugin.json` l. 3 `0.10.0`. The version rule not touched.
  - Verify (run): `0.10.0`; `grep -rlF '48 KB'` → `AGENTS.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`; in `AGENTS.md` `GLAB_COMPACT_AT` `2`, `implement.md` `2`, `evidence.md` `2`, `with \`; compact at <t>k\` before the \`)\`` `1`, `the warning for an invalid value` `1`, `amendments replace the text they change, in place` `1`, `` `README.md`); `` `6`, `` `README.md`). `` `0`; `README.md` `GLAB_COMPACT_AT` `2`; `git diff cf614ec -- AGENTS.md | grep -c '^[-+].*raises that plugin'` `0`.
- **After** done. `grep -rc 'findings\.md' plugins README.md AGENTS.md | grep -v ':0$'` → `plan-first/SKILL.md:1`, `AGENTS.md:1`, `developer.md:2`, `manager/SKILL.md:2`, `analyzer.md:1`; `git diff --stat cf614ec -- plugins/glab/commands plugins/glab/scripts/manager-bootstrap.sh` → nothing; `wc -c` `plan.md` 24597, `evidence.md` 14328 (≤ 49152); `git diff --check` rc=0.

## Blocked

None.

## Unplanned changes

None. No call site needed changing: `commands/develop.md` l. 2 "glab:plan-first steps 5 to 7" still names steps that exist, now in `implement.md` behind the `SKILL.md` pointer (searched `plan-first … step [5-7] | service lifecycle | nested repo | repo rules` across `plugins`, `README.md`, `AGENTS.md`: only that line). `manager/SKILL.md` l. 92 "a findings file" and l. 273 "Findings cover…" are prose and stay, as F9 says.

## Tests

Added T22, T23, T24 in `tests/context-size.test.sh`; T1–T21 unchanged but for the `unset` before T1 and `${SUFFIX:-}` in `stop_case` (empty by default, so their expected text is byte-identical). Result `PASS 24/24`; `FAIL 3/24` against the `cf614ec` script. `tests/memory-sync.test.sh` unchanged, `PASS 35/35`.

Coverage, per step (AGENTS.md *Tests*: a list, not a number):
- S7 script, valid value → suffix in `agent` and `prompt`: T22. First step moved, 100k steps after it, suffix in `stop`, silence below and within a step: T23 (4 runs). Invalid values `abc`, `0`, `1234567`, `15.5`, `-1` → one warning, default line: T24; invalid in `stop` → default 310k message plus the warning: T24; empty → no warning: T24. Unset → default unchanged: T1–T21. `stop` output keys over T23's runs: T19. No secret leak over all runs: T2. Rc 0 on every run: `run`, every case.
- S7 script, not covered by a case: the warning printed together with a failure line. Unreachable by construction — the variable is read after every `fail` path, and `fail` exits. Accepted.
- S1, S2, S4, S5, S8 and S7's `manager/SKILL.md`, `README.md`, `AGENTS.md` text: Markdown and JSON, no runtime. Covered by the per-step searches above, `plugin validate --strict` and `plugin details` (counts unchanged: `implement.md` is not a skill). Accepted, as the plan says.

## Gates

`export TMPDIR=/data/tmp/claude`; the two AGENTS.md *Gates* blocks run verbatim from a script, output to a log under `TMPDIR`; the `claude` commands ran under a fresh `CLAUDE_CONFIG_DIR` made by the block's `mktemp -d` and removed by it. Output, the 59 `ok …` test lines elided (every test line was `ok`; context-size order T1, T3–T18, T20–T24, T19, T2):

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    rc=0
    PASS 35/35
    PASS 24/24
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
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
    rc=1

All green against AGENTS.md *Gates*: five `rc=0`; shellcheck `rc=0` with no findings; both tests every line `ok`, `PASS 35/35`, `PASS 24/24`; three `✔ Validation passed`; the counts and hook lines as listed; `glab = glab`, `memory-sync = memory-sync`; `:0 :0 rc=1`; `1 1 1 rc=0`; no line `rc=1`. Equal to F14 but `PASS 24/24` for `PASS 21/21`, as *After* expects.

## Blast radius

    changed:  context-size.sh — the line gains `; compact at <t>k` before `)` and the stop step moves, only when GLAB_COMPACT_AT is set and valid; an invalid value adds one stderr line. Unset or empty: output identical to 0.9.0 (T1–T21 unchanged and green).
              plan-first/SKILL.md — Steps 5–7 and three repo rules moved to implement.md; the findings file is now evidence.md.
              manager/SKILL.md, analyzer.md, developer.md — read evidence.md, still accept findings.md in older folders; checklist item 6; amend-in-place rules; developer context rules.
    callers:  context-size.sh — plugins/glab/hooks/hooks.json (UserPromptSubmit, PostToolUse matcher Agent, Stop), unchanged; glab:manager Rule 2 reads the line and now names the suffix.
              plan-first Steps 5–7 — commands/develop.md l. 2 "steps 5 to 7": still valid (numbers kept in implement.md). No other caller names a step above 4 (search above).
              findings.md readers — every payload reader still accepts it for a folder from before 0.10.0 (S2, S4, S5).
    data:     none. The hook reads the transcript read-only and writes nothing; existing plan folders keep findings.md and are still read.
    rollback: revert the commit; with GLAB_COMPACT_AT unset the hook already behaves as at 0.9.0.

Proven vs inferred: the hook behaviour and every search count above are proven by the runs quoted. Inferred, not run: that `implement.md` is read by a session that follows the pointer (Markdown has no runtime); that a variable exported in the shell that starts Claude Code reaches the hook (F5, inferred there too).

## Follow-ups

Written to `plan/flow-planner/follow-ups.md`:
- FD1 the S7 contract sentence "still prints its JSON" is loose for `stop` below a step, where nothing prints; the wording is the plan's, so changing it needs an amendment.
- FD2 the S7 contract sentence sits as one unwrapped line so the searched phrase stays whole; no reflow done (no step names one).

The plan's own FU1, FU3–FU5, FU8 stay open as the plan lists them; FU2 and FU6 are closed by S1 and S1/S2/S4/S5.

## Not done

Nothing in scope. Out of scope by the plan: the `## Record` (Stage 8, after the push), the commit, and everything in `plan/flow-master-plan/`.

## Fix round 1

Every change below is an unplanned change forced by review round 1 (findings 1–4) or by the manager (FD1).

- **R1 (blocking)** `plugins/glab/agents/developer.md:31` — the log template groups the gate command, `{ <the gate command>; } >"$log" 2>&1; rc=$?`; l. 33 adds that the braces send every command of a compound line to the log and that `rc` is the status of the last command in the group (for a line ending `echo "rc=$?"`, the gate's own `rc` is the line in the log). Throwaway test in `$TMPDIR`, command `echo findings; false; echo "rc=$?"`:

      == before: log=$(mktemp ...); echo findings; false; echo "rc=$?" >"$log" 2>&1; rc=$?
      findings
      -- log:
      rc=1
      -- template: rc=0
      == after: log=$(mktemp ...); { echo findings; false; echo "rc=$?"; } >"$log" 2>&1; rc=$?
      -- log:
      findings
      rc=1
      -- template: rc=0

  Before, `findings` reached the context and not the log; after, both lines are in the log. The template's `rc=0` after is the last command's (`echo`), as the new sentence says.
- **R2 (low)** `plugins/glab/skills/manager/SKILL.md:105` — the smaller-window prompt now applies only "when the line names no `compact at <t>k`".
- **R3 (low)** `plugins/glab/skills/plan-first/SKILL.md:122` — "Then implement, from [`implement.md`](implement.md)."
- **R4 (low)** `tests/context-size.test.sh:323` — T24's stop run is appended to `$W/stopouts`, so T19 judges it too.
- **FD1 (manager)** `plugins/glab/scripts/context-size.sh:37–38` — "the run goes on with the default and prints on stdout what it would print with the variable unset - one JSON object or nothing." True in every mode, `stop` below a step included. `grep -rn 'still prints its JSON'` outside `plan/` found the sentence only in the script; `AGENTS.md`, the manager skill and `README.md` never carried it (AGENTS.md l. 173 says only "the warning for an invalid value"), so no other file changed. `follow-ups.md` FD1 marked closed.

Coverage: R4 is a test change; T19 and T24 cover it. R1–R3 and FD1 are Markdown or a comment, with no gate; R1 is verified by the throwaway test above.

### Gates, fix round 1 (`TMPDIR=/data/tmp/claude`)

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    rc=0                       (shellcheck, no findings)
    PASS 35/35                 (memory-sync test, every line ok)
    PASS 24/24                 (context-size test, every line ok)

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
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
    rc=1

All green. The shell-gate log held 59 `ok` lines and no other line but the eight above. Logs and the config directory were removed.
