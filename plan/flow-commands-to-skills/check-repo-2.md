# flow-commands-to-skills — plan check (repo), round 2 of 2

Checked against HEAD `5a72155` and the plan files as they are on disk now: `plan.md`, the six `steps-*.md`, `questions.md` (Q1 answered A). The round-1 copies are the `*.r1.md` files; round 1's report is `check-repo.md`.

## How it was checked

- **The export.** A throwaway `git archive HEAD` export under `$TMPDIR=/data/tmp/claude` (`chk2.*`, removed afterwards), with `git init` and one base commit, and the plan folder copied in.
- **The block runner.** A runner applied every block exactly as *Block formats* defines it. `old` must occur exactly once, with no trailing line break. `delete` must be whole consecutive lines, matched once at a line start. `file` writes the file. `run` runs under `bash -e`. Anything else prints `PLAN WRONG`.
- **The posts function.** `posts` is byte-identical to `plan.md`'s (`diff` `rc=0`).
- **The order.** Blocks were applied in P9's order: P1, then P6.1–P8, then stages, agents, manager, bootstrap, shared, repo.

### Proven, with output

- **B1** (real repo): `git status --short -uall -- plugins AGENTS.md README.md .claude-plugin` printed nothing. `git ls-files --error-unmatch …` printed `rc=0`.
- **B2** (export, HEAD gates verbatim): every gate was green, with the F10 values:
  - five `rc=0` lines; shellcheck `rc=0`;
  - `PASS 35/35`, `PASS 24/24`;
  - three `✔ Validation passed`;
  - `Skills (14)  … plan, plan-first, …`;
  - hooks `:0 :0 rc=1`; `1 1 1 rc=0`; seven model lines `rc=0`; name gate `rc=1`.
- **B3** (export, unchanged):
  - `git grep -c plan-first` matched 12 files and 42 lines, exactly F18's list.
  - `posts plan.md` printed 9 `RED` lines and 0 `ok`.
- **After P1 alone.** The six steps files' posts printed 0 `ok` and 154 `RED` (7 + 54 + 48 + 12 + 26 + 7).
- **Full build.**
  - Every block applied, with no `PLAN WRONG`: 7 + 47 + 37 + 9 + 24 + 6 applied, plus the run blocks PL2 and M25, `rc=0` each.
  - Each file's posts printed only `ok`.
  - At the end, all seven posts blocks gave `RED` count `0`: 163 lines, 138 distinct edit ids.
- **Each file alone on P1.** Each of the six steps files, built on P1 alone, built without error, and its posts printed 0 `RED` (R2).
- **Every edit skipped in turn (all 138, not a sample).** For each edit, the tree was built with only that edit left out and every post was run.
  - For 137 of the 138, that edit's own post lines were all `RED`, no other post line went `RED`, and there was no `PLAN WRONG`.
  - Skipping P1 turned P1's 4 lines `RED`. It also turned PF0–PF10, R1 and S1–S8 `RED`, because their files and directories do not exist without P1.
  - The merge steps were covered: P1, PF0–PF10, AG0.6, PL0, PL1, PL2, M0.5, M0.6, M25 and R1.
- **Edits in order.** After each edit, in file order, with the later edits not yet made: no post line printed `ok` before its own edit, and none was `RED` after it. So the *Posts* "stop if ok early" rule never fires.
- **A1 on the built tree** (the new *Gates*, verbatim):
  - five `rc=0`; shellcheck `rc=0`; `PASS 35/35`, `PASS 24/24`; three `✔ Validation passed`;
  - `Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship`;
  - `Agents (7)  reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer`;
  - `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only …)`;
  - `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop …`;
  - `glab = glab`, `memory-sync = memory-sync`;
  - hooks `:0 :0 rc=1`; `1 1 1 rc=0`; the seven model lines `rc=0`;
  - the skills gate printed exactly the fourteen lines of R2b and of the new *Gates* green list, in that order, with no `MISSING`;
  - name gate: no line, `rc=1`;
  - `plugin details glab | head -n 1` → `glab 0.13.0`;
  - `claude-config` directories in `$TMPDIR`: `0` before, `0` after.
- **A2.** Exactly these lines: `reviewer.md:36`, `committer.md:25` and `README.md:169`–`:172`.
- **A3.**
  - posts `RED` count `0`.
  - `git grep -n plan-first` printed only `README.md:166:`. A full-tree `grep -rn -i plan-first`, outside `.git`, `plan/` and `docs/specs/`, printed the same single line.
  - `implement\.md` → `rc=1`; the FU1-3 strings → `rc=1`.
  - `never said how the subject reached them` → only `plan-analyzer.md`.
  - `unbounded memory growth`, `--fix` and `Proven\*\* —` each → the single file A3 names.
  - `no contract` → only `developer.md:27`.
  - voice `:0` ×7; waits push 4, commit 1, develop 2.
  - hook context `2103` bytes.
- **A4.** Eight `RM` renames and `D` for both `commands/plan.md` and `plan-first/implement.md`. ` M` for exactly the files A4 lists. Nothing under `docs/specs/`, `memory-sync/` or `tests/`.
- **Section pointers.** All 19 `` `glab:<x>` *Section* `` pointers in the built `plugins/glab` resolve to a heading or bold lead in the named file. Positive control: the pattern matched 19 pointers.
  - Every `Rule n` and `Step n` pointer named exists. Examples: `glab:analyzer` Step 4 holds the mockgen case; `glab:bootstrap` step 6 holds the `grep` function hazard; `glab:security` Rule 4 now holds the `-count` text BS6.2 points at.
- **M25's sed** (the manager before M25 against after it) changed exactly four `` `glab:plan-first` `` references, at `:176`, `:243`, `:246` and `:370`, and nothing else.

## Round-1 status

| id | status | evidence |
|---|---|---|
| R1 | fixed | PA1, M14.1 and A3 search `never said how the subject reached them`, a one-line string. In the built tree: plan-analyzer `1`, manager `0`. A3 prints only `plan-analyzer.md`. B3 no longer stops the build. |
| R2 | fixed | Each steps file's posts are green on P1 plus that file alone (0 `RED` ×6). PA1's post reads only `plan-analyzer.md`. D1's tree-wide search lives in A3. |
| R3 | fixed | Every M edit has its own post. With each M edit skipped alone, its lines went `RED` and nothing else did. |
| R4 | fixed | All 138 edits have post lines, and all 138 skip builds discriminate. The edits R4 named are now separate ids with posts: D2, D3.2, D5.2, IN3, M5, M7.1–M7.6, M13.2, M14.3, BS3.2, BS6.1, BS6.2, PF3.1 and PF6. |
| R5 | fixed | R1's first post `diff`s the built *One fact* bullet against the `R1 new` block (`rc=0`, and `RED` with R1 skipped). Its second post checks the paths of the built bullet: `paths checked`, and `RED` with R1 skipped. Q1 = B no longer exists. |
| R6 | fixed | BS6.1, BS6.2, PA1 and M14.1 carry the line break inside the block. Each matched exactly once. |
| R7 | fixed | Built *One fact*: *every round a new agent* names `ship/SKILL.md` and `reviewer.md`. *the intent check* names `analyze/SKILL.md`. *step numbers* names `planner.md` and `plan-analyzer.md`. |
| R8 | fixed | Built manager `:276`: "after it, the planner's version copy `master.v<n>.md` (`glab:plan` Step 4)". `:178` dispatches the planner "to write it as `glab:plan` Step 4 says". `glab:plan` Step 4 makes the copy. Only one role makes it. |
| R9 | fixed | P6.3 and D5 are blocks. The posts search one-line strings and are green. |
| R10 | fixed | Built manager `:115` names `docs/specs/workflow.md` with no section. |
| R11 | fixed | `plan.md` Decision: "`docs/constants.md` is read by the planner alone (M1, R11)". |

## New findings

| id | severity | step | evidence | fix |
|---|---|---|---|---|
| R2-1 | low | M0.6 vs PF9.2 (request 4, "each once") | The user-only waiver rule is stated twice in the built tree. Manager `:231`: "you write `plan/{slug}/waived.md` from the user's own words, and never on their behalf". `glab:plan` `:142`: "Only the user's own words make a waiver: never write one on the user's behalf". Request 4 and the Decision say "the user-only waiver rule once, in *User Override*". The same Decision line also prescribes the manager's copy, so the plan contradicts itself. | Make the manager line a pointer only: "`glab:plan` *User Override* is the rule, and under this skill you are the one who writes `waived.md`". Or reword the Decision to accept two actors. |
| R2-2 | low | PF2 vs manager Rule 1 | The reason for the trivial stop is in two files. Manager `:42`: "A pipeline that runs for every typo is a pipeline that gets skipped for everything". `glab:plan` `:19` (PF2): "because a pipeline that runs for every typo gets skipped for everything". Manager Rule 1 also still says "Do it directly". The Decision "The trivial-work stop lives once, in `glab:plan` Step 0" is therefore not what the built tree does. | Cut PF2 to "under `glab:manager` Rule 1's line: say so and stop". Or name Rule 1 as the owner in the Decision. |
| R2-3 | low | PF3.1 | PF3.1 makes `evidence.md` full-tier only, written as a section of `plan.md` at normal tier (`plan/SKILL.md:26`). But the unchanged *Quick Reference* row `:149` still says `\| Analyze \| Findings \| \`plan/{slug}/evidence.md\` \|` for every tier. The skill contradicts itself after the merge. | Add an edit to that row: "`plan/{slug}/evidence.md` at full tier, the evidence section of `plan.md` at normal". |
| R2-4 | low | S1 (unchanged since r1) | Built `analyze/SKILL.md:7`: "dispatches one agent on `plan/$ARGUMENTS/`". Manager `:192` says "**Analyze**, both kinds, split by surface", and `:272` says "dispatch `glab:plan-analyzer` agents … split by surface". The manager runs Stage 1b through this skill (`:135`, `:145`), so the skill's "one agent" contradicts the stage it serves. FU1-4 says the stage wins, but neither file says so. | In S1, say "dispatches the agent — or the agents the stage splits by surface — on `plan/$ARGUMENTS/`". Or drop "one". |
| R2-5 | low | R1 (*One fact* preamble) | The new preamble (`AGENTS.md:120`) says "each fact below is one that more than one file states". At least two entries name a single file. *the stage sequence* names only "`plugins/glab/skills/manager/SKILL.md` description and *The pipeline*" (`:253`). *the session-start rules* names only `manager-bootstrap.sh`, which `glab:bootstrap` points at. | Drop those two entries, since one file owns each, or soften the preamble. |
| R2-6 | low | PF6 / Step 4 (pre-existing, unchanged by the plan) | Built `plan/SKILL.md:107` says "Before implementing, confirm: … the plan check has passed and `master.md` has its `## Approval` line". The preloaded planner follows Steps 0–4 and returns before Stage 1b and before the approval. The wording comes from HEAD `plan-first` and is not new. The merge makes `glab:plan` plan-only, which makes the mismatch visible. | Follow-up, outside this plan: word Step 4 for a planner — "the plan is ready for the plan check" — and leave the approval to the manager. |

Counts: critical 0, high 0, medium 0, low 6. None stops the build.

## The merge

- **References.** Nothing outside `docs/specs/` and `plan/` points at `skills/plan-first/` or `glab:plan-first`, except `README.md:166`, the recorded migration line (proven above).
- **AGENTS.md.** The *Gates* green lines (`Skills (13)` with its thirteen names, and the fourteen-line skills gate), the gate output, and README's component list all agree on 13 skills: 5 shared, 7 stage and `glab:plan`. The *One fact* entries name only files that exist (R1's path post).
- **Rules the merge collapsed.** `argument-hint`, the `$ARGUMENTS` hook and Stage 1's direct planner dispatch are each stated once. The waiver rule and the trivial-stop reason are each stated twice (R2-1, R2-2).

## Not checked

- Whether the edits serve the request. That is the intent question's job, not this repo check's.
- The runtime behaviour of the moved skills and of the `skills:` preload. U1–U8 stay UNVERIFIED: checking them needs an interactive session or a paid run.

BUILDABLE
