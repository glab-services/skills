# Result — flow-project-level / 03-project-manager

Built on `d6797e0`, branch `flow-project-level`. Nothing was staged or committed. `TMPDIR=/data/tmp/claude`; each temp file sat in one `mktemp -d` work dir, and that dir is removed at the end. The version is still `0.15.0`. Per W18, `plan/manager-flow-notes.md` was not touched.

## Stages

Each step is done. Every post-condition below is the real output of `/usr/bin/grep` or `wc -c`. Format: `[string] count`.

- **B1 — done.** `git rev-parse --short HEAD` printed `d6797e0`. `git status --short` printed `?? plan/flow-project-level/03-project-manager/` and `?? plan/manager-flow-notes.md`. Final check step 4 before:
  `cat: …project-plan-accept/SKILL.md: No such file or directory` (×3, for plan-accept, plan-analyze and record, as expected)
  `proj=75302 prod=45222 task=91199 list=9663 files=31 onel=31`, `40845 project-manager`, `13310 session-rules`, `5212 bootstrap`.
  Agent sets: `project-analyzer 23437`, `project-plan-analyzer 23129`, `project-reviewer 27750`, `product-analyzer 16508`, `project-planner 31557`.
  Step 5 before: `project-plan [schema or data migration] 0`. Each new skill printed `missing`. The existing stage skills printed 0 for `after-verdict.md`, `PLAN WRONG`, `BLOCKED`, `-analyze-r`, `INTEGRATED` and `SHIP`. `project-manager` printed `11` / `1` / `1`.
  Step 2 before: `rc=1`, `0`. Description bytes: PM 576, `project-plan` 673. The P16 search on HEAD printed 29 lines and `rc=0`. Markers: `project-developer.md 1`, `AGENTS.md 2`, every other file 0.
- **P1 — done.** New file `plugins/glab/skills/project-plan-accept/SKILL.md`: 5369 bytes, description 172.
  `[name: project-plan-accept] 1`, `[sha256sum plan/] 1`, `[Plan acceptance checklist] 1`, `[references/plan-mode.md] 1`, `[- size: ] 1`. `grep -c '## Approval'` → `3`.
- **P2 — done.** New file `…/project-plan-accept/references/plan-mode.md`: HEAD:PM `:165-172` under a heading, 2058 bytes. `grep -o UNVERIFIED | wc -l` → `10`; `plansDirectory` → `1`.
- **P3 — done.** New file `…/project-plan-analyze/SKILL.md`: 3454 bytes, description 162.
  `[NOT BUILDABLE] 2`, `[cmp -s] 1`, `[0.10.0] 0`, `[*Round caps*] 1`, `[The plan check] 1`. `At most 2|max 2` → `0`.
- **P4 — done.** `…/project-plan-report/SKILL.md`: 4296 bytes, description 276.
  `[after-verdict.md] 1`, `[master plan and sub-plans] 0`, `[WAITING] 1`. `glab:project-manager` → `0`.
- **P5 — done.** `…/project-develop/SKILL.md`: 6099 bytes, description 177.
  `[PLAN WRONG] 2`, `[BLOCKED] 2`, `[two reports that each blame the other] 1`, `[approved, at full tier] 0`. `glab:project-manager.? Stage (1c|2)` → `0`.
- **P6 — done.** `…/project-analyze/SKILL.md`: 5179 bytes, description 153.
  `[-analyze-r] 1`, `[/glab:project-plan-analyze] 1`, `[Stage 1b] 0`, `[Stage 8] 0`, `[that summary] 0`, `[git write-tree] 1`.
- **P7 — done.** `…/project-integrate/SKILL.md`: 1632 bytes. `INTEGRATED` → `1`; `is Stage 4` → `0`.
- **P8 — done.** `…/project-review/SKILL.md`: 3177 bytes. `[SHIP] 1`, `[Stage 8] 0`, `[*Re-reviews*] 2`, `[max 2] 0`.
- **P9 — done.** New file `…/project-record/SKILL.md`: 2098 bytes, description 148. `[docs/specs] 1`, `[glab:project-reviewer] 1`, `[name: project-record] 1`.
- **P10 — done.** `…/commit/SKILL.md`: 1747 bytes. `in parallel` → `1`.
- **P11 — done.** New file `…/project-manager/references/without-subagents.md`: 1338 bytes. `review4` → `1`; `--model <alias>` → `1`.
- **P12 — done.** `…/project-manager/SKILL.md`: **9998 bytes**, description 234. `^description: .\{40,\}` → `1`.
  `[## Stage ] 0`, `[sha256sum] 0`, `[Plan acceptance checklist] 0`, `[references/without-subagents.md] 1`, `[Rule 4] 0`, `[schema or data migration] 0`, `[findings-] 1`, `[/glab:project-plan-accept] 2`, `[/glab:project-plan-analyze] 1`, `[/glab:project-record] 1`.
  Each of the eight headings → `1` with `grep -cxF`.
  Section bytes (awk) against budget:

  | Section | Bytes | Budget |
  |---|---:|---:|
  | rules | 272 | 250 |
  | skills | 808 | 830 |
  | owns | 785 | 750 |
  | pipeline | 2193 | 2200 |
  | tier | 1228 | 1200 |
  | master | 1586 | 1350 |
  | parallel | 508 | 450 |
  | planner | 1699 | 1600 |
  | after | 221 | 300 |
  | without | 71 | 120 |
  | never | 197 | 400 |

  Measured with `LC_ALL=C awk` over the headings; the frontmatter and intro make up the remaining 430 (9998 − 9568). Per W23, the row budgets bind only through the total.
- **P13 — done.** `…/project-plan/SKILL.md`: 14722 bytes, description 396. `glab:project-manager` → `0`, `[schema or data migration] 1`, `[## Quick Reference] 0`, `^## Step [0-4] ` → `5`.
- **P14 — done.** `agents/project-planner.md`: 2458 bytes. `glab:project-manager` → `1`, `^tools: .*Skill` → `0`, `through the Skill tool` → `0`.
- **P15 — done.** `…/session-rules/SKILL.md`: 13012 bytes. `glab:project-manager` → `1` (`:53`); `Without subagent dispatch` → `0`.
- **P16 — done.** The search printed only `rc=1`. `approved, at full tier` in `project-developer.md` → `0`.
  Sizes: `project-analyzer.md` 9477 (HEAD 9517), `project-plan-analyzer.md` 9201 (HEAD 9209), `project-developer.md` 12146 (cap 12170), `project-ship` 3079 (cap 3088), `audit` 3587 (HEAD 3596). `README.md:280` was retargeted.
- **P17 — done.** `AGENTS.md`: Gates `Skills (25)` with the three names in sorted order, plus all 15 *One fact* retargets.
  `project-manager/SKILL\.md`? (Stage|acceptance|checklist|\*Pick)` → `0`, `project-plan-accept/SKILL.md` → `3`, `references/plan-mode.md` → `1`, `Skills (25)` → `1`, `Skills (22)` → `0`.
- **P18 — done.** README row 9 gained `/glab:project-plan-accept`, `/glab:project-plan-analyze` and `/glab:project-record`. `grep -c`: `glab:project-plan-accept 1`, `glab:project-plan-analyze 3` (two of the matches are `…-analyzer`), `glab:project-record 1`. `jq` → `0.15.0`.
- **A1 — done.** Markers: `AGENTS.md 2`, `project-developer.md 1`, and 0 in each of the other 15 changed files and the 5 new files.
  UNVERIFIED marks: HEAD PM had 10. Now the new PM has 1 (W12's) and `plan-mode.md` has 10. No other changed file's count moved.
- **A2 — done.** See *Gates* and *Milestone* below.

## Milestone (A2): after against before

| Measure | Before (B1) | After | Cap / target |
|---|---:|---:|---|
| `proj` | 75302 | **44157** | ≤ 47104 / 44247 |
| `prod` | 45222 | **44924** | ≤ 47104 / ≈ 45012 |
| `task` | 91199 (3 files missing) | **79909** | ≤ 81920 / 80694 |
| `list` | 9663 | **9539** | ≤ 10240 / ≈ 9834 |
| `files` / `onel` | 31 / 31 | **34 / 34** | equal, 34 |
| PM | 40845 | **9998** | ≤ 10240 / 10000 |
| `session-rules` | 13310 | 13012 | ≤ 13312 |
| `bootstrap` | 5212 | 5212 | ≤ 6144 |
| `project-analyzer` set | 23437 | 23397 | ≤ 23580 |
| `project-plan-analyzer` set | 23129 | 23121 | ≤ 23288 |
| `project-reviewer` set | 27750 | 27750 | ≤ 27973 |
| `product-analyzer` set | 16508 | 16508 | ≤ 16657 |
| `project-planner` set | 31557 | **30484** | ≤ 31168 / 30944 |

The step 4 output, verbatim: `proj=44157 prod=44924 task=79909 list=9539 files=34 onel=34`.

Step 5 after, verbatim counts:

| Skill | String | Count |
|---|---|---:|
| `project-plan` | `schema or data migration` | 1 |
| `project-plan-accept` | `sha256sum plan/` | 1 |
| `project-plan-accept` | `## Approval` | 3 |
| `project-plan-accept` | `- size: ` | 1 |
| `project-plan-analyze` | `NOT BUILDABLE` | 2 |
| `project-plan-report` | `after-verdict.md` | 1 |
| `project-develop` | `PLAN WRONG` | 2 |
| `project-develop` | `BLOCKED` | 2 |
| `project-analyze` | `-analyze-r` | 1 |
| `project-integrate` | `INTEGRATED` | 1 |
| `project-review` | `SHIP` | 1 |
| `project-record` | `docs/specs` | 1 |
| `project-manager` | `## Stage ` | 0 |
| `project-manager` | `sha256sum` | 0 |
| `project-manager` | `Plan acceptance checklist` | 0 |

No line printed `missing`.

Step 2 after printed `rc=1`, then `0`.

## Blocked

None.

## Unplanned changes and deviations (W16)

No file is over its byte target. Every description is within its cap. These are the wording consequences:

- P4 `:7`: "runs it: `glab:project-manager` Stage 1c." became "runs it as below."
- P4, the moved freeze text:
  - "this skill says" became "a stage skill says", since PM may not be named (P4's post-condition).
  - "Stage 1c again" became "a new report" or "this report again".
- P5:
  - "hands off as Stage 2 says" became "as below", because Stage 2's text is now in this file.
  - The *Know the gates before you dispatch* pointer was dropped. That section is gone (W9/F15), and `glab:bootstrap` step 3 stays.
  - *The dispatch* keeps "your suggestions, marked as such" (HEAD `:212`), because no other file holds it.
- P6: the self-reference "`/glab:project-analyze {slug}` as the final check" was dropped from `:280`. "At most 2 rounds, a third under …" became "Rounds are capped as *Round caps*, a third's line in `index.md`".
- P7: `:252`'s "at normal tier only the milestone test, as its Step 1 says" is carried into the existing sentence. "Stage 2 as a fix round" became "a `glab:project-develop` fix round".
- P8:
  - "with what Stage 5 gives a reviewer" became "with the input below".
  - "Stage 5 says where the findings go" became "*After the verdict* below says".
  - The dimensions are one paragraph. "in one message" was not added there (W7).
- P1: the changed-request text reads "a new `## Approval` line and a new hash". That gives `## Approval` its third line.
- P3: I wrote `argument-hint:` and then removed it, since P3 names no such line (follow-ups FU1).
- P11: "the role's model from the list above" became "from `glab:session-rules` Rule 5", because the list is not in that file.
- P13:
  - At `:122`, "(`glab:project-manager` Stage 2)" was dropped, not retargeted. The new target, `/glab:project-develop`, is already named in the sentence.
  - The description was condensed to 396 description bytes. It no longer names the developer or `docs/specs/`. The body still holds both.
- P12: the master/sub-plans section dropped the example `/glab:project-analyze {slug}/02-hooks` and its "(Stage 5)" cite. Each rule stays. *What you never do* keeps three bullets (four facts).

## Tests

- No script or test changed, so no case was added (plan *Tests and coverage*).
- Coverage, as a list (AGENTS.md *Tests*):
  - P1–P11 and P13–P18: each step's post-condition greps above, plus Milestone 4/5.
  - P12: Milestone 4, P12's heading counts, and the hook suites. `manager-bootstrap` and `product-loop` assert `PROJECT_MGR`, and both are `PASS` below.
  - Not covered by any case: whether a manager acting on the new PM behaves as before (it needs a live run), and W12's re-injection.

## Gates

The first AGENTS.md *Gates* block, run as written:
- Nine lines `… rc=0`, one per script.
- Shellcheck: `rc=0`, no findings.
- `PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 19/19`, `PASS 17/17`. In each output, the only line that is not `ok` is that `PASS` line.

The plugin gates block, run as written (it makes its own `CLAUDE_CONFIG_DIR` under `$TMPDIR` and removes it; `ls $TMPDIR/claude-config.*` found none afterwards):
- `✔ Validation passed` ×3.
- `Skills (25)  audit, bootstrap, comments, commit, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-verdict, project-analyze, project-develop, project-integrate, project-manager, project-plan, project-plan-accept, project-plan-analyze, project-plan-report, project-record, project-review, project-ship, push, security, session-rules, severity`.
- `Agents (9)` with the nine names.
- `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`.
- memory-sync: `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only …)`.
- `glab = glab`, `memory-sync = memory-sync`.
- `hooks.json:0` ×2, then `rc=1`.
- `:1` ×3, then `rc=0`.
- The nine model lines, then `rc=0`.
- The eighteen skills lines, none `MISSING`.
- The last command printed no line, then `rc=1`.

After P3's frontmatter fix, the validate lines and `Skills (25)` were run again: they printed the same.

`git diff --check` → rc 0. A trailing-space grep over the 5 new files → rc 1 (no match).

## Claims

| Claim | Evidence |
|---|---|
| PM 9998 bytes, under 10000 and 10240 | `wc -c` in step 4: `9998 plugins/glab/skills/project-manager/SKILL.md` |
| No *Keeps* fact dropped from PM | inferred — I checked each P12 *Keeps* cell by reading, and no grep proves meaning. The analyzer's conformance check is the test |
| Every old-stage pointer is retargeted | P16 search → `rc=1` |
| The hook text is unchanged | inferred from `proj − core − PM = 44157 − 31528 − 9998 = 2631`, equal to *Evidence*'s `h`. Both hook suites `PASS` |
| Markers and UNVERIFIED marks are kept | A1 counts above |
| All gates green | *Gates* above |
| W12 re-injection | UNVERIFIED: whether a repeated `Skill` call re-injects the body — needs a live session |
| The milestone caps encode master step 4's "3000 below *Before*" | inferred, not checked against G5's table |

## Follow-ups

`follow-ups.md` lists FU1–FU4, none of them named by a step:
- FU1: `argument-hint` for `project-plan-analyze`.
- FU2: README `:281` "Stage 1c".
- FU3: `commit:7` "the record's commit (Stage 8)".
- FU4: README stage-name mentions, measured.

## Not done

- The record additions (plan *Record*) are Stage 8's (D15). `docs/specs/` is untouched.
- Final check steps 3 and 6–8 are not part of this milestone and were not run.
- UNVERIFIED: whether a manager running the new PM drives the pipeline as before — no live session was run.

## Fix round for review round 1

Scope: review.r1.md, per W24. Base HEAD d6797e0; reviewed tree f7ed3a6; tree after this round 10bf16643dcc (temp-index snapshot, `plan/` not in either).

**Disk incident.** The first fix agent stopped when the disk filled, and two files it had emptied were restored from the reviewed snapshot f7ed3a6. The dispatch says each restore was checked with `git hash-object`. It did not name the two files, so I could not re-check them myself. Before this round, `df -B1 /` showed 242611838976 B free. The three files I edited, as blobs (f7ed3a6 → now): AGENTS.md 15779ff9575d → ff6d4f099a3e; project-analyze/SKILL.md 4d72ef4ce16c → 3cfe1adc9f4f; project-plan-analyze/SKILL.md 122e1fb53f80 → a49d818b074b. Every write succeeded. After the round, 242178793472 B free.

**Already done in the first fix agent's part, left as is:** findings 2 (`agents/project-plan-analyzer.md:3`), 3 (`agents/project-analyzer.md:3`), 5 (`skills/project-plan-accept/SKILL.md:17-18`); the HEAD:PM 276 sentence at `skills/commit/SKILL.md:15`; HEAD 175-177 left as a pointer. Finding 4 is not fixed, by W24 (D11/W6).

- **Finding 1**, `skills/project-analyze/SKILL.md:11`: now "The dispatch carries the slug, the check's name, round 1's tree id or the final check's range, and from round 2 on the round's inputs below". The ≤10-line summary is "for the user" only. It is no longer called analyzer input. Line 7 ("named in the dispatch") and line 28 ("name it in that round's dispatch") agree with it. The check is `grep -n 'dispatch carries'` → line 11, as quoted.
- **Advisory, *Round caps* skill name**, `skills/project-analyze/SKILL.md:36`: now "Rounds are capped as `glab:session-rules` *Round caps*,".
- **Advisory, argument-hint (FU1)**, `skills/project-plan-analyze/SKILL.md:4`: `argument-hint: "[plan slug]"`, the same as `project-analyze:4`, `project-plan-accept:4` and `project-record:4`.
- **Finding 6, round caps → pointers.** `skills/project-analyze/SKILL.md:21`: "`analyze round <n>/<cap>`". `skills/project-plan-analyze/SKILL.md:17`: "after the last round, with no extra one allowed: …" and "Still `NOT BUILDABLE` after the extra round `glab:session-rules` *Round caps* allows, or once it stops the rounds, at any tier". `grep -rnE 'round 2/2|after round [23]|round 3/3' plugins README.md` now finds only `session-rules:127` (the owner) and `project-manager/SKILL.md:36` ("the amendment after round 2"). Finding 6 did not name that one, so it was not changed. It is left for the caller.
- **Finding 6, *One fact* entries**, AGENTS.md:
  - step numbers: AGENTS.md:259-261, adds `project-plan-accept` and `project-plan-analyze`;
  - verdict lines: AGENTS.md:288-291, adds `project-develop`, `project-plan-report`, `project-review` and `project-record`;
  - plan mode: AGENTS.md:300-302, adds `project-manager` and `project-plan-accept/SKILL.md`.

  Each search was re-run as files hit, minus files listed in the entry:
  - `BUILDABLE|CONFORMS|DIVERGES`: 11 hits. One is unlisted: `agents/project-developer.md:115` ("after an analyzer's `DIVERGES`"). It has the same count, 1, at HEAD, so the gap predates this change, and finding 6 did not name it.
  - Step numbers, `project-plan`? Steps? [0-4]|project-plan` \*?Step`: 6 hits. Two are unlisted, `project-develop:17` and `project-plan-report:11` (both cite `glab:project-plan` Step 3). Each has the same count, 1, at HEAD. Finding 6 did not name them.
  - Plan mode, `only when the user asks|plan mode`: 4 hits (README, project-manager, project-plan-accept, plan-mode.md), all listed.

  So every file finding 6 named is now listed. Three files that predate this change state a fact without being listed, and are reported here rather than added. follow-ups.md was not edited, because this dispatch limits `plan/` writes to result.md.

**Master *Final check* step 4** (run as written, TMPDIR=/data/tmp/claude): `proj=44157 prod=44924 task=80302 list=9541 files=34 onel=34`; project-manager 9998, session-rules 13012, bootstrap 5212; project-analyzer 23423, project-plan-analyzer 23097, project-reviewer 27750, product-analyzer 16508, project-planner 30484. Every cap in the dispatch holds: proj ≤ 47104, task ≤ 81920, list ≤ 10240, files = onel, PM ≤ 10240, session-rules ≤ 13312, project-analyzer ≤ 23580, project-plan-analyzer ≤ 23288.

**Gates** (AGENTS.md *Gates*, TMPDIR=/data/tmp/claude, a new empty CLAUDE_CONFIG_DIR removed afterwards):
- Block 1: nine `rc=0`; shellcheck `rc=0` with no findings; every test line `ok`; memory-sync PASS 35/35, context-size PASS 24/24, plan-gate PASS 51/51, manager-bootstrap PASS 19/19, product-loop PASS 17/17.
- Block 2:
  - three `✔ Validation passed`;
  - glab `Skills (25)` with the 25 names, `Agents (9)` with the 9 names, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`;
  - memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only …)`;
  - `glab = glab`, `memory-sync = memory-sync`;
  - hooks.json `:0`, `:0`, `rc=1`;
  - `not yet confirmed` counts 1/1/1, `rc=0`;
  - the nine expected `model:` lines, `rc=0`;
  - 18 skills lines with 0 `MISSING`;
  - the last command printed no line, `rc=1`.
- All green.

## Scope cut for review round 2

Per `review.r2.md` finding 1 and decision W25.

- `plugins/glab/skills/project-plan-analyze/SKILL.md:17`: after the kept lead-in "**Rounds are capped as `glab:session-rules` *Round caps*.**", the passage is now HEAD's rule from `git show HEAD:plugins/glab/skills/project-manager/SKILL.md | sed -n 187p`, verbatim from "A plan still `NOT BUILDABLE` after round 2 with no round 3" to the end of the line. It had no Stage or `glab:project-manager` pointer, so nothing needed retargeting. "or once it stops the rounds" is gone.
  - Before: "A plan still `NOT BUILDABLE` after the last round, with no extra one allowed: … Still `NOT BUILDABLE` after the extra round `glab:session-rules` *Round caps* allows, or once it stops the rounds, at any tier: bring it to the user."
  - After: "A plan still `NOT BUILDABLE` after round 2 with no round 3: … Still `NOT BUILDABLE` after round 3, at any tier: bring it to the user."
- `AGENTS.md:146-147`: the *One fact* round-caps entry's file list now includes `plugins/glab/skills/project-plan-analyze/SKILL.md`, listed after `session-rules/SKILL.md` *Round caps*.

Verify:
- `/usr/bin/grep -cF 'after round 3' …/project-plan-analyze/SKILL.md` → `1`; `/usr/bin/grep -cF 'once it stops the rounds'` → `0`.
- Master *Final check* step 4 printed `proj=44157 prod=44924 task=80206 list=9541 files=34 onel=34`; `project-manager` 9998, `session-rules` 13012, `bootstrap` 5212; agents: project-analyzer 23423, project-plan-analyzer 23097, project-reviewer 27750, product-analyzer 16508, project-planner 30484. `task` ≤ 81920 and `list` ≤ 10240 both hold.
- AGENTS.md *Gates*, first block (`TMPDIR=/data/tmp/claude`): nine `rc=0` lines, shellcheck `rc=0`, then PASS 35/35, 24/24, 51/51, 19/19, 17/17.
- Plugin gates block: three `✔ Validation passed`; glab Skills (25), Agents (9), Hooks (4); memory-sync Skills (1), Agents (0), Hooks (4); `glab = glab`, `memory-sync = memory-sync`; `user_config` 0/0 with `rc=1`; `not yet confirmed` 1/1/1 with `rc=0`; nine `model:` lines with `rc=0`; every agent skill resolves, none `MISSING`; the last line (`grep -rH --include='*.md' '^name: .*:' plugins`) printed no matches and `rc=1`.
