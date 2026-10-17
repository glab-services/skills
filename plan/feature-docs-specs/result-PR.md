# Result — feature-docs-specs, Slices P and R

Developer, 2026-10-17. Scope: P1–P14 (`plugins/glab/**`) and R1–R2 (`README.md`,
`AGENTS.md`). Slices S and M, and `plan/feature-docs-specs/` other than this
file, are another developer's. `AGENTS.md` read from disk (its C7 line greps
`Not yet shown: any reply from a DeepSeek model`). No old `plan/<slug>/` record
was read; one `git grep` over `6838133` looked for the D7 "before" wording and
found none (it is the user's chat wording, as the dispatch says).

## Stages

All done. Line numbers are the new file's.

- P1 `plugins/glab/skills/plan-first/SKILL.md` — done: description `:3`; Step 1 spec bullet `:26`; Step 3 `## Record` bullet `:74`; follow-ups sentence `:111`; *Plan files are working files; the spec is what stays.* `:156` (old `:154` replaced); *User Override* sentence `:173` (put on the end of that paragraph); *Quick Reference* `Record` row `:186`.
- P2 `plugins/glab/skills/manager/SKILL.md` — done: description `:3` (`→ commit → push → record`); `:81` (except for the record); `:126` Rule 5 (record, or push when there is no plan folder); pipeline row 8 `:176`; old `| Spec |` row deleted (old `:196`); `| 8 Record |` tier row `:198`; `<slug> record` `:244`; Stage 7 sentence `:420`; `## Stage 8 — Record` `:422-431`; *What you never do* last bullet `:445`.
- P3 `plugins/glab/commands/plan.md:18` — done.
- P4 `plugins/glab/commands/commit.md:12` — done, a paragraph of its own before "Do not push." (now `:14`).
- P5 `plugins/glab/commands/push.md:91` — done, a paragraph after the old last line.
- P6 `plugins/glab/agents/committer.md:42` — done, after Step 3's last paragraph.
- P7 `plugins/glab/agents/developer.md` — done: Step 2 sentence `:26` (on the end of the closed-list paragraph); `:38`; `## The record — glab:manager Stage 8` `:96-98`, between Step 5 and *Rules*; `:103` ("and during the record, none").
- P8 `plugins/glab/agents/analyzer.md:42` — done, after the five-state list.
- P9 `plugins/glab/skills/bootstrap/SKILL.md` — done: diagram `:91` (`→  record`, two spaces each side); `record` bullet `:110-112`, which **does carry** "unless the repo's `AGENTS.md` keeps its plans" (check.sh section 10 finds it); Step 5 area-specs bullet `:124-125`.
- P10 `plugins/glab/scripts/manager-bootstrap.sh:17` — done (`commit -> push -> record at full tier`).
- P11 `plugins/glab/skills/audit/SKILL.md:70` — done, item 4.
- P12 `plugins/glab/scripts/external-agent.sh` — done, comments only: `:35-36` (two lines); `(spec, *Measurements*)` at `:56,97,210,227,541`; `:194` *Allowlist*; `:688` *Live runs*, finding 1; `:236` P4. The incident comment "(found in the prototype: three processes stayed after a SIGKILL)" is kept, now `:618-619`.
- P13 the four profiles, `## Notes` only — done (Q1 = A): *Source* and *UNVERIFIED* bullets in `kimi.md:29-31,50-52`, `glm.md:28-30,46-48`, `deepseek-pro.md:28-36,46-48`, `deepseek-flash.md:29-36,46-48`, rewrapped at 78 columns within each bullet only. check.sh section 8: all five prompt hashes unchanged.
- P14 `plugins/glab/.claude-plugin/plugin.json:3` — done, `0.4.2` → `0.5.0`.
- R1 `README.md` — done: a) paragraph `:17-22`; b) `:61`; c) `plan/` row and new `docs/specs/` row `:226-227`.
- R2 `AGENTS.md` — done: a) *Layout* `:16-20`; b) C7 green text `:81`; c) the live-run rule `:109-121`, the D7/R2c text word for word, with the two citations changed and the first sentence's citation → *Offline run*; d) *One fact* `:184-202` (", and this file's live-run exception" and the plan-lifecycle entry); e) the `plan/` rule `:207-222`, replacing "`plan/` is tracked and permanent."

## Blocked

Nothing.

## Unplanned changes

- R2d: the insertions fall inside a wrapped paragraph, so its lines from "`~/.opencode/bin/opencode` (the skill" to "pinned by its gate line above)." (`AGENTS.md:183-202`) were rewrapped at 78 columns. The words are unchanged apart from the two insertions.
- R1a, R2a and P9 were wrapped to the file's own column width (README, AGENTS.md, bootstrap). The words are as quoted. check.sh reads each file with its lines joined, so it is not affected.
- Placement: the plan gives only "after `:N`" for P1 *User Override*, P2 Stage 7 and P7 Step 2. Each sentence went on the end of that paragraph, not into a paragraph of its own.

## Tests

No test was added or changed. This is prose, plus comments and hook text. Coverage, as a list (`AGENTS.md` *Tests*):

- P12 (script comments): `tests/external-agent.test.sh` `PASS 49/49`, `bash -n` and shellcheck show that the script still parses and runs. They would pass either way, so they guard against regressions and do not discriminate. `grep -c '(findings-r3)'` → `0`; `grep -cF '(spec, *Measurements*'` → `6`.
- P10 (hook text): no test case covers the hook. This is accepted because the hook has no test file. A4 ran it: `bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext | command grep -c -F -- '-> push -> record'` → `1`, `rc=0`. check.sh section 10 also finds it.
- P13 (profiles): check.sh section 8 shows that the `Before`/`After the contract` hashes are unchanged for all five profiles.
- P14: check.sh section 9 → `ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0`.
- P1–P11, R1, R2 (prose): check.sh section 10 → `insertions 73/73 present`; rules line → `ok   rules permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6`; section 2 → `ok   no stale plan/ citation`, `ok   short record names: AGENTS.md:1 `. These find each insertion. Whether the prose reads well is for review to judge.
- memory-sync is unchanged: `PASS 35/35`. It guards against regressions and passes either way.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root. Both blocks were taken from `AGENTS.md` on disk. The plugin block was extracted with `sed` into `/data/tmp/claude/fds-PR-gate2.sh`, run with `bash`, then removed.

Block 1:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    ok T01 … ok T35 (35 lines, all ok)
    PASS 35/35
    bash tests/external-agent.test.sh … </dev/null → exit=0; 49 lines `ok`, 1 other line: PASS 49/49

`tests/external-agent.test.sh` passed on its first run, so it was not re-run.

Block 2 (`CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`, throwaway `CLAUDE_CONFIG_DIR` made and removed by the block):

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
    1
    rc=0
    rc=1

Green, and the same as at base.

An earlier run of block 2 used the older copy of AGENTS.md injected into the session (the `not yet run against a real model` line) and printed `0`/`rc=1` on that line. It is void: that line is no longer in `AGENTS.md`, and the run above, taken from disk, is the gate.

`Q1=A STAGE=build bash plan/feature-docs-specs/check.sh` (output kept while I worked under `/data/tmp/claude/`, then removed):

- My sections are green. Section 2: `ok   no stale plan/ citation`, `ok   short record names: AGENTS.md:1 `. Section 8: five `ok   prompt`. Section 9: `ok   versions …`. Section 10: `insertions 73/73 present` and the `ok   rules …` line above. Section 12: `ok   no listed leak pattern (absence check)` (no specs exist yet, so this proves nothing). Section 13's first line: `ok   Q1=A no notes in the tree`.
- 231 `FAIL` lines, all in sections that wait on Slice S or M. Section 1: 7 `removed` (M). Section 3: 7 `record` (S). Section 4: 186 `tag` (S). Section 5: 9 `decisions` (S). Section 6: 4 `missing docs/specs/*.md` (S). Section 7: offline, L1a and two runner lines (S). Section 11: 7 *Measurements* and 2 *Allowlist* (S). Section 13: 5 `Q1=A note … not cited under *Profiles*` (S).

A5 `git diff --name-only 6838133 -- . ':!plan' ':!docs'` printed exactly the plan's 19 paths, in its order. `git status --short -uall` shows those 19 as ` M`, plus untracked files under `plan/` only.

## Security — blast radius

- Writes: the 19 files above, and this file. Temp files were `/data/tmp/claude/fds-PR-*` and the gate block's own `claude-config.*`, all removed. Nothing was written under `/tmp` or `~/.claude`.
- Commands: `bash -n`, shellcheck, the two stub tests (the external-agent test starts its own local listeners and sandbox and tears them down), `claude plugin validate` / `plugin details` under a throwaway `CLAUDE_CONFIG_DIR`, `jq`, `grep`, `git diff/status/grep/log` (read-only), and `check.sh` (read-only, `GIT_OPTIONAL_LOCKS=0`).
- Nothing was run against a real model or backend. No network use beyond the test's own host-local listeners. No install, no `git add`, commit or push, no service touched. Nothing was deleted from the repo.
- Secrets: none read or written. `~/.env`, OpenCode data/auth and `~/.claude/settings.json` were not opened. No host value went into any changed file: the paths added are repo-relative or `$TMPDIR`.
- Reversible: `git checkout -- <the 19 paths>` restores the base.

## Follow-ups

None written. Nothing out of scope came up. No `follow-ups.md` was created.

## Not done

- Slice S (`docs/specs/**`) and Slice M (removing the seven folders) belong to the other developer, as do the check.sh sections that wait on them, listed under *Gates*.
- Commits C1–C4, B2 and the record X0–X5 are the manager's and the committer's.
- UNVERIFIED: that the payload prose reads well and that an installed 0.5.0 runs Stage 8 as written. check.sh only finds each insertion. That needs review and a session on an installed copy.

## Review round 1 fixes

Developer, 2026-10-18. Scope: P1, P2, P4–P9, P11, P14, R1a, R2c, R2d, R2e, and the new P15, as stated in plan.md *Amendments — review round 1/3* (U7, U8, U9). I did not touch P3, P10, P12, P13, R1b, R1c, R2a or R2b. The version stays `0.5.0`. AGENTS.md was read from disk.

### How it was applied

- I first ran `fixes-r1.py` on a copy of `AGENTS.md`, `README.md` and `plugins/glab/` under `$TMPDIR`. It printed `applied` and changed 13 files. None of them belongs to P3, P10, P12 or P13.
- I then checked the copy against plan.md itself, without trusting the script. A throwaway checker under `$TMPDIR` pulled each quoted text out of plan.md: the step quotes, the Stage 8, committer, record and record-check blocks, and the R2c and R2e blocks. It counted each one in its target file, read as one line. Result: `bad 0 of 38`, so every text occurs exactly once. The check also found that the old texts are gone ("push has landed", "once it is pushed", "does, and its", the old `git show …:plan/<slug>/` recovery).
- Finally I ran `python3 -I plan/feature-docs-specs/fixes-r1.py` from the repo root. It printed `applied`, `rc=0`, and the result was byte-identical to the dry run. Re-checked after the rewrap below: `bad 0 of 38`.

### Steps (all done; new line numbers)

- P1 `plugins/glab/skills/plan-first/SKILL.md`:
  - description `:3` ("once the change has landed");
  - Step 3 `:73-74` (`rejected;` and the `## Record` bullet naming an audit file);
  - *Plan files are working files* `:156` (Stage 6 records commit; landed on the default branch; `git restore --source=…`; stop when no commit holds it; the pre-rule test is "`plan.md` has no `## Record`");
  - Quick Reference row `:186`.
- P2 `plugins/glab/skills/manager/SKILL.md`:
  - Stage 6 `:412` (name `plan/{slug}/` in scope);
  - pipeline row 8 `:176`, now with `glab:analyzer`;
  - tier row 8 `:198`;
  - Stage 7 `:420`;
  - `## Stage 8 — Record` `:422-440`: its three start conditions, the developer, then the record check by `glab:analyzer`, the reviewer, commit and push;
  - *never* bullet `:454`.
- P4 `plugins/glab/commands/commit.md:12`.
- P5 `plugins/glab/commands/push.md:91`.
- P6 `plugins/glab/agents/committer.md:42`: slug guard, audit-file guard, `git rm` for the audit file, and the `git diff --staged --name-status` check.
- P7 `plugins/glab/agents/developer.md:98`: tracked files only, untracked ones named in the report, the commit from the dispatch, and `git restore --source=…`.
- P8 `plugins/glab/agents/analyzer.md`: the sentence `:42`, and `## The record check — glab:manager Stage 8` `:54-56`, before `## Report`.
- P9 `plugins/glab/skills/bootstrap/SKILL.md:110-113` ("once the change has landed on the default branch"; it still carries "unless the repo's `AGENTS.md` keeps its plans").
- P11 `plugins/glab/skills/audit/SKILL.md:70`.
- P14 `plugins/glab/.claude-plugin/plugin.json:4`: the description now reads "review, commit, push and record through dedicated agents". The version is still `0.5.0`.
- P15 `plugins/glab/commands/ship.md:38`: the plan-folder exception sentence.
- R1a `README.md:17-24`.
- R2c `AGENTS.md:120`: "does" → "did" (U8), that word only.
- R2d `AGENTS.md:193-195`: `plugins/glab/commands/ship.md` added after `push.md`.
- R2e `AGENTS.md:208-224`: the amended `plan/` rule.

### Unplanned changes

These are wrapping only; the words are unchanged and check.sh reads each file as one line.

- The script left two lines long. I rewrapped them to the file's column:
  - `bootstrap/SKILL.md:111-113`, the `record` bullet;
  - `AGENTS.md:195-196`, where `developer.md` moved to its own line after the `ship.md` insertion.

### Gates (TMPDIR=/data/tmp/claude; both blocks taken from AGENTS.md on disk, run as scripts)

Block 1:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    (84 lines `ok`)
    PASS 35/35
    PASS 49/49

The external-agent test passed on its first run, so I did not re-run it.

Block 2 (`CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`, with a throwaway `CLAUDE_CONFIG_DIR` that the block makes and removes):

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
    1
    rc=0
    rc=1

Green.

A4 hook text: `-> push -> record` count `1`, `rc=0`.

`Q1=A STAGE=build bash plan/feature-docs-specs/check.sh`: **0 `FAIL` lines.** The tree already held the other developer's spec fixes when I ran it, so no section was waiting on them. Key lines:

- seven `ok   removed` and seven `ok   record`;
- `tags 187/187 in place`;
- nine `ok   decisions`;
- headings in order and no empty section, for all four specs;
- offline, L1a and runner blocks `ok`;
- five `ok   prompt`;
- `ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0`;
- `insertions 103/103 present`;
- 17 `ok   gone from …`;
- `ok   rules permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6`;
- the *Measurements*, *Allowlist* and *Incidents* checks `ok`;
- `ok   no listed leak pattern (absence check)`;
- Q1=A: no notes in the tree, and all five cited;
- `info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: ''`.

A5: `git diff --name-only 6838133 -- . ':!plan' ':!docs'` printed 20 paths, the 19 from before plus `plugins/glab/commands/ship.md`.

### Coverage, as a list

- Every step in this round is prose or JSON text. They are covered by check.sh section 10 (103/103 insertions), its `gone from` lines, my 38-string check against plan.md's own quotes, and plugin validation of `plugin.json`.
- No test case exercises them, and that is accepted: no Markdown gate exists, as `AGENTS.md` says. The two stub tests and shellcheck pass either way; they guard against regressions and do not discriminate.

### Security — blast radius

- Writes: the 13 files above, all inside the boundary (`plugins/glab/**`, `README.md`, `AGENTS.md`), and this appended section. I made no edit under `docs/specs/`, nothing else under `plan/`, and nothing in `~/.claude`.
- Temp files: `/data/tmp/claude/fds-PR-r1copy/` and `/data/tmp/claude/fds-PR-scripts/`, both removed after the gates. The plugin block removed its own config directory.
- Commands:
  - `fixes-r1.py`, on the copy and then on the tree;
  - my read-only checker;
  - `bash -n`, shellcheck and the two stub tests;
  - `claude plugin validate` and `details` under the throwaway config;
  - check.sh, read-only with `GIT_OPTIONAL_LOCKS=0`;
  - `git diff`.
- Nothing ran against a real model or a real backend. There was no install and no `git add`, commit or push, and no service was touched. No secrets were read or written.
- Reversible: `git checkout -- <path>` puts back the base text. The round-1 text before this round is described in the sections above.

### Follow-ups

None.

## Conformance round 2/4 fix

Developer, 2026-10-18. Scope: fix 1 only (step R2d), from plan.md *Amendments — conformance round 2/4*.

### Step

- R2d `AGENTS.md:191-193` — done. "the record after the push, the folder removed and the commit that holds it named" now reads "the record once the change has landed on the default branch, the folder removed and the commit on the default branch that holds it named".
- I rewrapped only the two lines the old text sat on; they are now three lines, all inside that bullet.
- `grep -c 'record after the' AGENTS.md` → `0`. Read as one line, the file holds the new phrase once.
- Nothing else changed.

### Gates

`TMPDIR=/data/tmp/claude`. Both blocks were taken from AGENTS.md on disk and run as scripts.

Block 1:
- five `rc=0`, then shellcheck `rc=0`;
- 84 lines `ok`;
- `PASS 35/35` and `PASS 49/49`. The external-agent test passed on its first run.

Block 2 (`CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`, throwaway `CLAUDE_CONFIG_DIR`):
- three `✔ Validation passed`;
- `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`;
- `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
- `glab = glab`, `memory-sync = memory-sync`;
- `:0` `:0` `rc=1`;
- `:1` `:1` `:1` `rc=0`;
- `1` `rc=0`;
- `rc=1`.

All green.

`Q1=A STAGE=build bash plan/feature-docs-specs/check.sh` printed 0 `FAIL` lines:
- `tags 187/187 in place`;
- `insertions 104/104 present`;
- `ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0`;
- `ok   rules permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6`;
- `info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: ''`.

### Coverage

The change is prose. check.sh section 10 now holds R2d's new string (104 insertions), and no test case covers it. That is accepted because there is no Markdown gate (`AGENTS.md`).

### Security — blast radius

- Writes: one hunk of `AGENTS.md`, plus this section.
- Temp files went in one `mktemp -d` directory under `/data/tmp/claude`, which I removed.
- Nothing ran against a real model or backend. No install, no `git add`, commit or push, and no secrets.
- `git checkout -- AGENTS.md` reverts it to base. The round-1 text is described above.

### Follow-ups

None.

## Scope cut (review round 2)

Developer, 2026-10-18. Scope: plan.md *Amendments — review round 2/3 (scope cut)* (U10, U11), payload/README/AGENTS boundary.

### How it was applied

- **Checks before the run.** `HEAD` is `6838133`. `git diff --cached` was empty. The four files to revert are the same at `HEAD` and at `6838133`. The script's `git checkout 6838133 -- <4 paths>` therefore writes the index entries those files already had, so nothing is staged. After the run, `git diff --cached --name-only | wc -l` → `0`.
- **Dry run first.** I ran `fixes-r2.py` on a copy under `$TMPDIR`, with its `git checkout` replaced by `git show 6838133:<path>`. It printed `applied (dry)`.
- **Checked against plan.md, not the script.**
  - A throwaway checker took each quoted text from the current *Slice P*/*Slice R*: the P1, P2, P7, P8, P9, P11, P14, R1a, R2c, R2d and R2e quotes, plus the Stage 8, record and record-check blocks. Result: 33 of 34 found exactly once.
  - The 34th was a fault in my own check. It looked for the Stage 7 sentence and the next heading as adjacent text. Checked directly, `A change with a plan folder goes on to Stage 8.$` → `1`, and `once it has landed` in `manager/SKILL.md` → `0`.
- **Applied for real.** `python3 -I plan/feature-docs-specs/fixes-r2.py` from the repo root printed `applied`, `rc=0`. The result was byte-identical to the dry run.

### Confirmations asked for

- `git diff --quiet 6838133 -- <path>` printed `rc=0` for all four: `plugins/glab/agents/committer.md`, `plugins/glab/commands/commit.md`, `plugins/glab/commands/push.md` and `plugins/glab/commands/ship.md`.
- None of the cut texts is left in `plugins/glab/**` or `README.md`. Each count below matches the count at `6838133`:

  | text | at `6838133` | now |
  |---|---|---|
  | `git rm` | 0 | 0 |
  | `git restore` | 0 | 0 |
  | `default branch` | 0 | 0 |
  | `<remote>/<default>` | 0 | 0 |
  | `symbolic-ref` | 2 | 2 |
  | `merge-base --is-ancestor` | 1 | 1 |
  | `landed` | 4 | 4 |

  The `symbolic-ref`, `merge-base --is-ancestor` and `landed` hits were already in the payload before this change.
- `git diff 6838133 -- plugins/glab | grep '^+' | grep -c 'git rm\|symbolic-ref\|merge-base --is-ancestor\|git restore'` → `0`.
- The AGENTS.md live-run sentence is unchanged from the last round. The script made no hunk there, and `*Live runs*) did, and its transcripts` appears once (U8).
- The version is still `0.5.0`. `plugin.json`, the hook, `commands/plan.md`, the script and the profiles were not touched.

### Steps (new line numbers)

- P1 `plan-first/SKILL.md`:
  - `:3` "once the change is pushed";
  - `:73-74`, the `## Record` bullet, "once it is pushed";
  - `:156`, *Plan files are working files*: the record never removes the folder, and removing it is the repo's own `AGENTS.md` decision;
  - `:173`, "recorded like a plan's";
  - `:186`, `| Record | Spec entry | the area spec, after the push … |`.
- P2 `manager/SKILL.md`:
  - Stage 6 back to its base sentence (`:412`);
  - row 8 `:176` ("the area spec");
  - tier row `:198` ("after the push: …");
  - Stage 7 `:420`;
  - Stage 8 `:422-432`: spec only, analyzer check at every tier, an ordinary docs commit and push, and decisions go in the dispatch and the spec;
  - *never* `:445`, "Remove `plan/{slug}/` or an audit file as part of the record (Stage 8)."
- P4, P5, P6, P15: back to `6838133`.
- P7 `developer.md:98`: the record section, "Change nothing inside `plan/<slug>/`, and remove nothing."
- P8 `analyzer.md`: the sentence `:42` ("after the push"), and the record check `:54-56` (verdicts from *Report*: `CONFORMS` / `DIVERGES: <n> steps`).
- P9 `bootstrap/SKILL.md:110-112`: the `record` bullet, "the plan folder stays unless the repo's `AGENTS.md` says otherwise".
- P11 `audit/SKILL.md:70`: item 4.
- R1a `README.md:17-22`.
- R2d `AGENTS.md:190-199`: the lifecycle entry, now "the record after the push, and that the record never removes the plan folder". `commit.md`, `push.md`, `ship.md` and `committer.md` are no longer in its file list.
- R2e `AGENTS.md:206-227`: the `plan/` rule. The manager session removes the folder after landing on `origin/main`, by exact path, once it is tracked, clean and identical there. Retrieval is read-only: `git show`, `git ls-tree -r --name-only`, `git archive … | tar -x -C "$(mktemp -d …)"`.

### Unplanned changes

- The script put R2d's new lifecycle entry in as one long line. I rewrapped it at 78 columns, within that bullet only (`AGENTS.md:190-199`). The words are unchanged and the check.sh insertion is still found.

### Gates

`TMPDIR=/data/tmp/claude`. Both blocks were taken from AGENTS.md on disk and run as scripts.

Block 1:
- five `rc=0`, then shellcheck `rc=0`;
- 84 `ok`;
- `PASS 35/35` and `PASS 49/49`. The external-agent test passed on its first run.

Block 2 (`CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`, throwaway `CLAUDE_CONFIG_DIR`):
- three `✔ Validation passed`;
- `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`;
- `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
- `glab = glab`, `memory-sync = memory-sync`;
- `:0` `:0` `rc=1`;
- `:1` `:1` `:1` `rc=0`;
- `1` `rc=0`;
- `rc=1`.

All green.

A4 hook text: `-> push -> record` → `1`.

`Q1=A STAGE=build bash plan/feature-docs-specs/check.sh` printed 0 `FAIL` lines and 101 `ok` lines:
- `tags 187/187 in place`;
- `insertions 85/85 present`;
- `ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0`;
- `ok   rules permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6`;
- `info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: ''`.

The other developer's `docs/specs/` sed was already in the tree when this ran, and no section failed.

A5: `git diff --name-only 6838133 -- . ':!plan' ':!docs'` printed 16 paths. These are the earlier 20 without `committer.md`, `commit.md`, `push.md` and `ship.md`.

### Coverage, as a list

- Every step in this round is prose. The coverage is check.sh section 10 (85/85), its `gone from` lines, my check against plan.md's quotes, and the four `git diff --quiet` checks.
- No test case covers prose. That is accepted because there is no Markdown gate (`AGENTS.md`).
- The stub tests and shellcheck guard against regressions and pass either way.

### Security — blast radius

- **Files written:** the 12 files changed this round, all inside the boundary. Four of them went back to base. I also appended this section.
- **The index:** the script's `git checkout 6838133 -- <4 paths>` wrote it, but the entries were already equal to `HEAD`, and nothing is staged (`0`).
- **Temp files:** one `mktemp -d` directory under `/data/tmp/claude`, removed. Nothing was written under `/tmp` or `~/.claude`.
- **Not done:** no run against a real model or backend, no install, no `git add`, commit or push, no service touched, no secrets.
- **Reverting:** `git checkout -- <path>` restores the base. The earlier rounds' texts are described in the sections above.

### Follow-ups

None.
