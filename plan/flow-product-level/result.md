# Result — flow-product-level

Built on branch `flow-product-level` from `main` at `f3cfe85`. Nothing staged, committed or pushed.
`TMPDIR=/data/tmp/claude` for every command; every `claude` command ran inside the AGENTS.md *Gates* block, under a new empty `CLAUDE_CONFIG_DIR` that the block removed (`ls -d "$TMPDIR"/claude-config.* | wc -l` → `0` afterwards).

## Stages

All 32 steps done; each step's own posts run right after it, then all 261 together (X3).

| Step | Status | Posts | Where |
|---|---|---|---|
| B1 | done | `ok` | branch `flow-product-level`, no tracked change |
| B2 | done | baseline gates green | five `rc=0`, `rc=0`, `PASS 35/35`, `PASS 24/24`, `Skills (13)`, `Agents (7)` |
| B3 | done | `2` | `questions.md` |
| A1 | done | 4/4 | `plugins/glab/scripts/plan-gate.sh` (new, 0755), written from the steps text by the plan's `B` helper |
| A2 | done | 3/3 | `tests/plan-gate.test.sh` (new, 0755) |
| A3 | done | 3/3 | `plugins/glab/scripts/manager-bootstrap.sh` (replaced whole) |
| A4 | done | 3/3 | `tests/manager-bootstrap.test.sh` (new, 0755) |
| A5 | done | 4/4 | `tests/product-loop.test.sh` (new, 0755), twelve fixtures under `tests/fixtures/product-loop/` |
| P1 | done | 21/21 | `plugins/glab/skills/product-manager/SKILL.md` |
| P2 | done | 8/8 | `plugins/glab/skills/product-plan/SKILL.md` |
| P3 | done | 4/4 | `plugins/glab/skills/product-plan-analyze/SKILL.md` |
| P4 | done | 3/3 | `plugins/glab/skills/product-project-brief/SKILL.md` |
| P5 | done | 2/2 | `plugins/glab/skills/product-project-plan-report/SKILL.md` |
| P6 | done | 5/5 | `plugins/glab/skills/product-project-plan-analyze/SKILL.md` |
| P7 | done | 4/4 | `plugins/glab/skills/product-project-plan-verdict/SKILL.md` |
| P8 | done | 5/5 | `plugins/glab/agents/product-planner.md` |
| P9 | done | 7/7 | `plugins/glab/agents/product-analyzer.md` |
| J1 | done | 3/3 | `skills/manager/SKILL.md:3` |
| J2 | done | 42/42 | new `skills/session-rules/SKILL.md` (whole); `skills/manager/SKILL.md:10` *The rules of every level*, `:50` handoff pointer, `:73` round-caps pointer |
| J3 | done | 2/2 | `skills/manager/SKILL.md:14` |
| J4 | done | 3/3 | `skills/manager/SKILL.md` *Stage 1*, `**A brief is a request.**` |
| J5 | done | 13/13 | `skills/manager/SKILL.md` table row 1c, *Stage 1b*, *A question blocks*, new *Stage 1c*, *The master plan and sub-plans* |
| J6 | done | 5/5 | `skills/plan/SKILL.md` Steps 1, 3, 4 |
| J7 | done | 3/3 | `skills/develop/SKILL.md` *Preconditions* |
| J8 | done | 3/3 | `skills/manager/SKILL.md:153` item 8 |
| J9 | done | 9/9 | `skills/bootstrap/SKILL.md:3`, steps 1, 2, 4 |
| J10 | done | 1/1 | description line of six project stage skills |
| J11 | done | 1/1 | description line of six project agents |
| J12 | done | 18/18 | `skills/{analyze,integrate,review,ship,plan,develop,audit,commit,push,manager}/SKILL.md`, comments of `scripts/context-size.sh:10,20,23,31,73` |
| R1 | done | 2/2 | `plugins/glab/.claude-plugin/plugin.json:3-4` (0.14.0) |
| R2 | done | 3/3 | `AGENTS.md` *Layout* |
| R3 | done | 20/20 | `AGENTS.md` *Gates* |
| R4 | done | 37/37 | `AGENTS.md` *Rules* |
| R5 | done | 18/18 | `README.md` table, intro, *Levels*, *Try the product loop*, *Requirements*, *Working on this repo* |
| R6 | done | 2/2 | `host.example.md` *glab shared store* |

Build order: J2 was applied before J1. `plan.md` *Phases* says J2 runs before any other step that edits `skills/manager/SKILL.md`, and J1 edits it too (the description line only, which J2 does not touch). The result is the same either way.

## Blocked

None.

## Unplanned changes

- J2.5: in the moved Rule 5 list, the `glab:committer` — `haiku` line now ends in `;` instead of `.`, because the two new lines follow it.
- J2: blank lines put back before the headings where whole sections were cut and joined.
- R4: the *Rules* lines this step lengthened were rewrapped locally to about 78 columns, with two short leftover lines joined to the next. No other line of `AGENTS.md` was reflowed.
- R6: the `glab-shared-store:` line is a plain line, not an indented block. C2 reads "the first such line", so a `host.md` copied from the example has to start the line with `glab-shared-store:`.
- P2–P7: each entry-point skill carries an `argument-hint:` frontmatter key, as the existing stage skills do. It is not one of the keys the steps forbid.

## Tests

Added: `tests/plan-gate.test.sh` (T1–T29), `tests/manager-bootstrap.test.sh` (B1–B13), `tests/product-loop.test.sh` (L1–L17), with their fixtures. They are byte-identical to the plan's texts (`X` posts `ok`). Results: `PASS 29/29`, `PASS 13/13`, `PASS 17/17`, and every case line is `ok`.

Coverage, listed as AGENTS.md *Tests* requires:

- A1 → T1–T29 and L5–L17, plus its third post (round copies are left out of the digest);
- A2 → its run against A1's text;
- A3 → B1–B13, L1, L2;
- A4 → its run against A3's text;
- A5 → L1–L17;
- J12.4 changes comments only → `tests/context-size.test.sh` `PASS 24/24`;
- P1–P9, J1–J12 and R1–R6 → their posts and the gates only, since Markdown has no runtime.

Not covered by any case: LP1–LP6. Each needs a live, logged-in session after install, which the plan accepts.

## Gates

Commands extracted from the edited `AGENTS.md` lines 29–35 and 51–63, run as written.

Script gates (seven commands):

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    plugins/glab/scripts/plan-gate.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    tests/plan-gate.test.sh rc=0
    tests/manager-bootstrap.test.sh rc=0
    tests/product-loop.test.sh rc=0
    rc=0
    PASS 35/35
    PASS 24/24
    PASS 29/29
    PASS 13/13
    PASS 17/17

All the other 118 lines are `ok …`, and no line is anything else (`grep -v '^ok '` printed only the lines above).

Plugin gates:

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (21)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-report, product-project-plan-verdict, push, review, security, session-rules, ship
      Agents (9)  reviewer, product-planner, integrator, developer, analyzer, product-analyzer, committer, planner, plan-analyzer
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
    plugins/glab/agents/product-analyzer.md:model: opus
    plugins/glab/agents/product-planner.md:model: opus
    plugins/glab/agents/reviewer.md:model: sonnet
    rc=0
    (eighteen skills-gate lines, as AGENTS.md lists them, none MISSING)
    rc=1

After phase:

- **X1** — green, exactly as the changed *Green is* says (above).
- **X2** — the milestone command prints `PASS 17/17` and exits 0. Then `PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>"$TMPDIR/product-loop-trace.txt"` wrote a 434-line trace, with no `/home/` or `/data/` in it (grep count `0`).
- **X3** — the plan's helper plus its loop, verbatim: `    261 ok`.
- **X4** — the command as `plan.md` writes it prints `xargs: command: No such file or directory`: `command` is a shell builtin, which `xargs` cannot run. `git diff --name-only main` also lists no untracked new file. Equivalent run: the changed tracked files plus the untracked files under `plugins` and `tests` (49 files), through `xargs /usr/bin/grep -n -E '/home/|/data/|/Users/|/tmp/'`. It printed only `host.example.md:11,14,17`, the author's temp-dir lines, which are identical on `main`.
- **X5** — `wc -c`: master 5851, plan 34562, evidence 25617, steps-1 33143, steps-1b 40807, steps-2 22927, steps-3 31470, steps-4 21328. Each is at most 49152.
- **X6** — back-out by `git revert` of the commit; nothing run.
- `sha256sum -c plan/flow-product-level/master.sha256` → `plan/flow-product-level/master.md: OK`, both before the build and after.

## Claims

- The three new tests pass, and every script is shellcheck clean: proven by the gate output above.
- Every file the steps give in full is byte-identical to its text: proven by the `X` posts `ok` inside X3.
- The plugin loads 21 skills and 9 agents, with the model and skills gates exactly as AGENTS.md now lists them: proven above.
- The prose of P1–P9 and J2–J9 says what each step asks: shown by the posts' required phrases only. That the prose around them is right is for the analyzer and the reviewer.
- UNVERIFIED: LP1–LP6. They need a live session after install, and none was started.
- UNVERIFIED: that `plan/flow-product-level/walkthrough.txt` is where the trace should go. See *Not done*.

## Blast radius

- **Every project-level session:**
  - its session start now has a level line;
  - point 2 now loads three skills, `glab:session-rules` added;
  - Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, the round caps and the handoff line now live in `glab:session-rules`, with the words kept; `glab:manager` keeps Rule 4 and points at the rest.
- **`glab:develop`:** refuses a plan whose `master.md` has a brief line until `plan-gate.sh check` passes. Plans without the line are unchanged.
- **`glab:commit` and `glab:push`:** their first paragraph names the stage of either level's manager. The commit-on-`main` rule moved into `glab:commit`.
- **Twelve description lines** (six skills, six agents) now begin `Project level — `. No `name:` changed.
- **The hook comment pointers:** `context-size.sh` changed comments only, and its test still passes.
- **Installed copies:** stay on 0.13.0 until they update, because the version was raised to 0.14.0.

## Follow-ups

None added: `plan.md` *Follow-ups* already holds FU-P1–FU-P5, and nothing out of scope came up.

## Not done

- **The trace location.** The dispatch asked for the trace in `plan/flow-product-level/walkthrough.txt`. `plan.md` X2 says the trace is written to `$TMPDIR/product-loop-trace.txt` and "never goes into the plan folder or a commit"; the plan folder is committed with the change. The plan was followed: the trace is at `/data/tmp/claude/product-loop-trace.txt` (434 lines), left in place for the manager to show and then remove, as X2 says.
- **An index incident during X4.** While preparing X4 I ran `git add -N plugins tests` (intent-to-add), which touches the index. I reverted it at once with `git reset -q -- plugins tests`. `git diff --cached --name-status | wc -l` → `0` afterwards, so no file is staged.
- **Not read**, as the dispatch said: the `*.r1.md` / `*.r2.md` copies and the `check-*.md` files.

## Fix round — review round 1

Contract: `review-1.md`. Before-proofs ran against a copy of the pre-fix `plan-gate.sh` and after-proofs against the tree, from one script under `$TMPDIR`, each attack in its own store. Both are pasted below, with the work dir shown as `<w>`.

### Per finding

- **A1, symlinks: fixed.** `plan-gate.sh:91-99` has `first_link` and `no_links`. `no_links` runs in `digest` (:177), in `report` before the brief line (:187), and in `check` at "the plan" step of its fixed order (:293). The refusal is `REFUSED: the plan folder holds a symlink, <./path>; links are not followed - replace it with the file`. **Unplanned:** `verdict` (:242) also refuses a link in `plan.r<n>/`, with the existing `the copies in plan.r<n>/ do not match report r<n>`. It is the same hole on the copy the product audits, and it surfaced through the verdict's digest of that copy.
  - Before: `A1 file: check rc=0 [ACCEPTED r1 b9b3…]`, `A1 file: digest rc=0`, `A1 folder: check rc=0 [ACCEPTED r1 b9b3…]`, `A1 report: rc=0 […/report.r1.md]`.
  - After: `check rc=1 [REFUSED: the plan folder holds a symlink, ./02-evil/plan.md; …]`, `digest rc=1` (same line), `A1 folder: check rc=1 [REFUSED: … ./03-evil; …]`, `A1 report: rc=1 [REFUSED: … ./steps-9.md; …]`.
- **A2, races: verdict half fixed; report half built as decided but `PLAN WRONG` on this host.**
  - `publish_file` (:160-170) chmods the temp file, then runs `ln` to the final name and removes the temp. If the name already exists it refuses: the verdict says `report r<n> already has a verdict` (:270), the report says `another run wrote report r<n> first` (:222). Any other `ln` failure is exit 2. In every case the trap removes the temp.
  - `report` claims `plan.r<n>/` with `mkdir --` before copying (:203-207). If the folder exists it refuses `another run is writing report r<n>`. It then copies into the claimed folder. The trap removes the folder unless the report was linked.
  - Before:
    - two verdicts: `REJECTED rc=0`, `ACCEPTED rc=0`;
    - two reports: `rc=0` and `rc=0`, with `plan.r1/` holding `./.plan-gate.ujC9Eh/{master,plan}.md`. The report says `b9b3…` but `plan.r1/` hashes to `25c3…`.
  - After, verdicts: `REJECTED rc=0`, `ACCEPTED rc=1 [REFUSED: report r1 already has a verdict]`.
  - After, reports — **the decision's `mkdir` claim is not exclusive on this host.** `/usr/bin/mkdir` is uutils coreutils 0.10.0. Two `mkdir` calls racing on one name both returned 0 in 23 of 40 tries, and in 14 of 30 on a second run. `/usr/bin/gnumkdir` (GNU) did so in 0 of 30, and uutils `ln` in 0 of 40. With the fixed script and a `mkdir` delayed 1 s:
    - through `/usr/bin/mkdir`, two reports ended "one written, one refused, the copy hashes to its report" in 4 of 10 runs. In the others both runs wrote into one folder and failed (`rc=2`, `cp: … File exists`), and the trap removed it. In one run the loser's trap deleted the winner's `plan.r1/` after the winner's report was linked, leaving a report with no copy.
    - through GNU `mkdir`: 10 of 10 correct.
  - The two-reports test the decision names is **not added**: on this host it would fail about 6 runs in 10.
  - What would unblock it: a claim primitive that is exclusive on every host, chosen by the manager. Candidates, none approved: an `ln` of a claim token, bash `set -C` (`O_EXCL`), or a `mv -T` of a filled temp folder (not on macOS).
- **A3, readable copies: fixed.** `chmod -R a+rX` on the claimed copy before its report is linked (:213-214). The copy is now filled in place, so "before it is moved into place" reads "before its report is linked". The header comment (:21-29) says so.
  - Before, under `umask 077`: `plan.r1/master.md` and `plan.r1/plan.md` were `-rw-------`.
  - After: nothing is unreadable by others (`find … ! -perm -004` / `! -perm -005` prints nothing), and both copies are `-rw-r--r--`.
- **A4 + B9, the `after-verdict.md` redirect: fixed.** Stage 1c stays its one owner.
  - `develop/SKILL.md:15` ends "— after a report to product, where `glab:manager` Stage 1c says". `:17` ends "(`glab:manager` Stage 1c)", with the restated reason removed.
  - `session-rules/SKILL.md:18` now points at Stage 1c and no longer names the file.
  - `product-manager/SKILL.md:23` (the report-skill caveat) points at `glab:session-rules` *The level boundary*.
- **A5, own manager on its list: fixed.** `manager/SKILL.md:18` and `product-manager/SKILL.md:18` each add `- **This skill:** glab:<manager>, which glab:bootstrap step 2 loads.`
- **A6, project name: fixed.** `plan-gate.sh:232-233` now uses `case $project in '' | *[!a-z0-9-]*) usage`.
  - Before: `rc=1 [REFUSED: no report to decide]`.
  - After: `rc=2`, the usage line.
- **A7 = B11, the doubled dash: fixed.** `manager/SKILL.md:160`.
- **The waiver case: fixed.** `develop/SKILL.md:17` runs `check` when `master.md` has the brief line or `waived.md` names a brief. A waiver from a brief is always refused there, "so it is planned (`glab:manager` Stage 1)". The script is unchanged: `check` on a folder with no `master.md` already refuses `no brief line in master.md`, and T36 pins that.
- **B1, the 8192-byte limit: fixed by pointer.** `product-manager/SKILL.md:36` and `README.md:98` now read "one topic, its size as glab:product-plan says". The AGENTS.md entry (product-plan and the test) now matches the tree.
- **B2, the brief line: fixed by pointer.**
  - `develop/SKILL.md:17` points at "the brief line (`glab:plan` Step 3)".
  - `product-project-plan-report/SKILL.md:11` points at "(`glab:plan` Step 3; `glab:manager` acceptance checklist item 8)".
- **B3, verdict lines: fixed by an entry.** The product manager's pipeline table must show the verdicts where they stand, so `AGENTS.md:271` adds `plugins/glab/skills/product-manager/SKILL.md` to the analyzers' verdict-lines list.
- **B4, the cap: fixed.** `product-project-plan-verdict/SKILL.md:20` keeps the refusal text and `→ glab:product-manager *The cap*`.
- **B5, the start prompt: fixed by pointer.** `README.md:150-154` drops the prompt, the `claude --bg` line and the worktree caveat, and points at `glab:product-manager` *Starting project sessions*. It keeps the LP4 UNVERIFIED note.
- **B6, the last round of P1b: fixed.**
  - `product-plan-analyze/SKILL.md:14` adds "still `NOT SOUND` after the last one → the user".
  - The P1b row (`product-manager/SKILL.md:50`) points there.
- **B7, the approval line: fixed by pointer.** `product-project-brief/SKILL.md:9` points at `glab:product-manager` *The product pipeline*.
- **B8, rule files: fixed.** `product-plan/SKILL.md:36` drops "A rule file is never changed outside an approved product plan.". `product-manager/SKILL.md:62` owns it.
- **B10, Rule 0d: fixed.** `session-rules/SKILL.md:38` adds `glab:product-planner` and `glab:product-analyzer`.
- **B12, the stray trace file: fixed.** `README.md:135-140` writes `2>"$TMPDIR/trace.txt"`.
- **Advisory 1: fixed.** The *What you never do* section (`manager/SKILL.md:301-311`) now opens with one pointer to `glab:session-rules` Rules 0b, 1, 2 and 3. The bullets that restated them are gone. The manager-owned bullets stay, each now naming its stage.
- **Advisory 2: fixed.** `README.md:142-143` reads "at the version in `plugins/glab/.claude-plugin/plugin.json`".
- **Advisory 3, the jq indentation: not applied, `PLAN WRONG`.**
  - Its premise is that the tab indentation of `manager-bootstrap.sh:97-99` is an unrelated edit. It is not: the tabs are the plan's own text, `steps-1b-scripts.md:140-142`, A3. That file gives `manager-bootstrap.sh` in full, and the plan's Decisions require it written byte for byte and checked by the `X` post.
  - Reverting to HEAD's spaces would put the build out of step with the plan for no change in behaviour.
  - Unblock: the manager confirms the revert, knowing that this file's A3 `X` post then fails.

### Files touched

`plugins/glab/scripts/plan-gate.sh`, `tests/plan-gate.test.sh`, and these skills under `plugins/glab/skills/`: `develop`, `manager`, `product-manager`, `session-rules`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-report` and `product-project-plan-verdict`, each its `SKILL.md`. Also `README.md`, `AGENTS.md`, and `plan/flow-product-level/follow-ups.md` (new). `master.md` is untouched, and `plugin.json` stays at 0.14.0.

### Tests

These were added to `tests/plan-gate.test.sh`:

| Case | What it checks | Covers |
|------|----------------|--------|
| T30 | a symlinked file is refused by `check`, `digest` and `report` | A1 |
| T31 | a symlinked folder is refused by the same three | A1 |
| T32 | a symlink in `plan.r1/` is refused by `verdict` | A1, unplanned part |
| T33 | two verdicts at once: one written, one refused `report r1 already has a verdict`, and the file is the winner's | A2 |
| T34 | under `umask 077` the copy, its sub-folder, the report and the verdict are readable by every account | A3 |
| T35 | a project name with a newline exits 2 with the usage line | A6 |
| T36 | a `waived.md` from a brief with no `master.md` is refused by `check` | waiver |

- **T33's background runs.** It starts its two runs in the background and waits on their PIDs; the trap kills only those PIDs. The test header comment says so.
- **Against the pre-fix script**, T30–T35 FAIL (`FAIL 6/36`). T36 passes there, as it should: it pins behaviour that already existed.
- **Against the tree:** `PASS 36/36`, ten runs out of ten.
- **Not covered by any case:**
  - the report race, for the reason given under A2;
  - `publish_file`'s exit-2 branch, when `ln` fails with no name in the way;
  - the exit-2 branches of `mkdir` and `chmod -R`. These need a failing filesystem; the earlier write failures are untested in the same way.
- **The `X` posts.** `plan-gate.sh` and `tests/plan-gate.test.sh` are given in full in `steps-1-scripts.md`, so those `X` posts no longer match byte for byte. That follows from the decided fixes.

### Gates

All run as AGENTS.md prints them, with `TMPDIR=/data/tmp/claude`.

- **The script checks.** Nine `rc=0` lines, and `shellcheck` `rc=0` with no findings.
- **The tests:**
  - `memory-sync` `PASS 35/35`
  - `context-size` `PASS 24/24`
  - `plan-gate` `PASS 36/36`
  - `manager-bootstrap` `PASS 13/13`
  - `product-loop` `PASS 17/17`

  Every other line is `ok`.
- **The plugin block**, run with `CLAUDE_CONFIG_DIR` set to a new directory under `$TMPDIR`, which was removed afterwards:
  - three `✔ Validation passed`;
  - for `glab`: `Skills (21)`, `Agents (9)`, and `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`;
  - for `memory-sync`: `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only …)`;
  - `glab = glab` and `memory-sync = memory-sync`;
  - `:0`/`:0` then `rc=1`;
  - `1`/`1`/`1` then `rc=0`;
  - the nine model lines as listed, then `rc=0`;
  - the eighteen skills lines, none `MISSING`;
  - no line, then `rc=1`.

  All green.
- **The master hash.** `sha256sum -c plan/flow-product-level/master.sha256` printed `plan/flow-product-level/master.md: OK`.
- **The walkthrough.** `PRODUCT_LOOP_SHOW=1 … 2>"$TMPDIR/fr1-trace.txt"` printed `PASS 17/17` and wrote a 434-line trace. That trace is byte-identical to the build's `$TMPDIR/product-loop-trace.txt` (`diff` printed nothing), so every scene reads as before. It contains no `/home/` or `/data/`. `fr1-trace.txt` has since been removed; the build's trace is left in place.

## Fix round — review round 1, part 2

Contract: `review-1.md`, *After part 1 of the fix round stopped on two PLAN WRONGs*, A2. Advisory 3 is rejected there, so nothing was changed for it. Part 1's fixes stand. `master.md` and the steps files are untouched. `TMPDIR=/data/tmp/claude` throughout.

### Stages

- **A2, every claim is a bash `set -C` create: done.** `plugins/glab/scripts/plan-gate.sh`:
  - `claim <file> <refusal>` (:78-97). It runs `(set -C && : >"$1")`, and if that fails it refuses when the name exists and exits 2 otherwise. On success it records the file in `CLAIM`. The comment says why this is not `mkdir` and records the measured uutils numbers.
  - The trap removes `CLAIM` last (:66-75), after the copy folder and the temp file.
  - **report** (:226-235) claims `.plan-gate.claim.report.r<n>` after the digest and before anything is made. That one claim covers both `report.r<n>.md` and `plan.r<n>/`. Under the claim it tests again for `report.r<n>.md` and `plan.r<n>/`, and only then runs `mkdir -- plan.r<n>`, which is no longer the claim. The loser refuses `another run is writing report r<n>`.
  - **verdict** (:293-296) claims `.plan-gate.claim.verdict.r<n>` after every check and before `mktemp`, then tests again for `verdict.r<n>.md`. The loser refuses `another run is writing verdict r<n>`.
  - Comments were updated: the header (:21-28) and `publish_file` (:185-189). The `ln` publish stays, as part 1 built it.
- **Only the winner creates; the loser touches nothing: done.** A loser exits at `claim` with `CLAIM`, `TMP_DIR` and `TMP_FILE` all empty, so its trap removes nothing.
- **Claims are never hashed and never listed: done.** A claim lives in `briefs/<project>/`, never in a plan or copy folder. It does not match a hashed name, and the trap removes it. Its `.plan-gate.` prefix puts it under T22's and L17's check for leftover files.
- **The two-reports test: done.** See T37 below.

### Proof

The harness is `$TMPDIR/pg2-proof.*/race.sh` (removed afterwards). Each run uses a fresh store, starts two runs in the background, and waits on their PIDs. A run is `ok` when all of these hold:
- exactly one run exits 0 and the other exits 1;
- the loser prints nothing on stdout;
- `report.r1.md` carries the plan's digest;
- `plan.r1/` hashes to it and holds exactly `master.md` and `plan.md`;
- for verdicts, `verdict.r1.md` is the winner's;
- no `.plan-gate.*` is left.

The delays are part 1's: for reports, 1 s before the copy folder's `mkdir` (not `mkdir -p`); for verdicts, 1 s before `mktemp`. "Before" is a copy of the script as part 1 left it (sha256 `48109b4c295d9305…`).

    bash race.sh plan-gate.before.sh report 20
    report plan-gate.before.sh: 10/20 runs with exactly one winner, its copy hashing to its report, nothing of it removed

The 10 bad runs were of two kinds:
- 6 of the form `BAD plan.r1/ hashes plan-gat, report c11b26ac; plan.r1/ holds [] [e2: REFUSED: another run wrote report r1 first]`: the loser's trap removed the winner's copy after the winner's report was linked;
- 4 of the form `BAD rc 2 2; no report.r1.md [… copying the plan (the copy has another digest) failed] [cp: cannot create regular file …]`.

    bash race.sh plan-gate.sh report 20          # after
    report plan-gate.sh: 20/20 runs with exactly one winner, its copy hashing to its report, nothing of it removed
    (every loser: REFUSED: another run is writing report r1)

    bash race.sh plan-gate.before.sh verdict 20
    verdict plan-gate.before.sh: 20/20 runs …     (loser: REFUSED: report r1 already has a verdict — part 1's ln held)
    bash race.sh plan-gate.sh verdict 20          # after
    verdict plan-gate.sh: 20/20 runs …            (every loser: REFUSED: another run is writing verdict r1)

A tighter race used a 1 s delay in `sort` instead, so both runs reach the claim within milliseconds of each other. That exercises the `O_EXCL` path itself rather than an existing file:
- reports after the fix: `20/20`;
- a second batch of 20: all 20 losers `another run is writing report r1`.

The primitive, measured on its own, 40 races each on one name, counting the races where both calls exited 0:
- uutils `mkdir`: `11/40`;
- GNU `mkdir`: `0/40`;
- `(set -C; : >f)`: `0/40`.

`strace` of `set -C; : >claim` shows `openat(AT_FDCWD, "claim", O_WRONLY|O_CREAT|O_EXCL, 0666) = 3`, and the second open fails with `cannot overwrite existing file`. Host: bash 5.3.9, `mkdir (uutils coreutils) 0.10.0`.

### Unplanned changes

- **The test again under the claim** (report :229-232, verdict :296). The claim file must be removed, so that it never shows in the store listing. A removed claim can be taken again by a run that read the store before the winner published. Without the second test, that run would `mkdir` into the winner's folder. This follows from claims that are removed.
- **T33's expected loser line** (`tests/plan-gate.test.sh:435`) changed to `REFUSED: another run is writing verdict r1`, with its comment (:414-415). The loser is now refused at the claim, while the winner waits in `mktemp`. This follows from the verdict claim.
- **A `shellcheck disable=SC2016` line** (:474), with its reason, on T37's stub. shellcheck flagged the stub's own `$1`.
- **The test header comment** (:10-11) now names T37 beside T33.

### Tests

- **T37** (`tests/plan-gate.test.sh:467-504`) — two reports at once, with a 1 s `mkdir` stub:
  - exactly one run exits 0 and one exits 1;
  - the loser's line is `REFUSED: another run is writing report r1`, and it prints nothing on stdout;
  - the winner prints the report's path;
  - `report.r1.md` carries the plan's digest, and `plan.r1/` hashes to it;
  - the project folder holds exactly `brief.md`, `plan.r1/{master,plan}.md` and `report.r1.md`, so no claim is left.
  - It follows AGENTS.md *Tests*: the stub is first on `PATH`, and the background runs are killed only by their recorded PIDs.
- **Against the pre-fix script:**
  - three runs, each `FAIL 2/37`;
  - T37: `the two runs exited 2 and 2`;
  - T33: `the losing run said [REFUSED: report r1 already has a verdict]`, its changed expectation.
- **Against the tree, ten in a row, after the last edit:** `PASS 37/37` ×10.
- **Coverage by plan point:**
  - the report claim: T37, plus T7/T28 for the refusals before it;
  - the verdict claim: T33;
  - the claim removed on every path: T22 and T37's listing;
  - the refusal under the claim writing nothing: T13 and T28 through `refused`.
- **Not covered by any case:**
  - the re-test branches under the claim (report :231-232, verdict :296). They need a run to read the store, lose the CPU until another run has published and released, and then take the claim. No delay stub can place that without editing the script. The reasoning is inferred, not run.
  - `claim`'s exit-2 branch, when the create fails with the name absent. It needs an unwritable store, the same as part 1's untested write failures.

### Gates

All run exactly as AGENTS.md prints them.

- **The script checks.** The nine `rc=0` lines, then `shellcheck` `rc=0` with no findings. The first run was `rc=1`, an SC2016 (info) at T37's stub; it was fixed by the directive above and run again.
- **The tests:**
  - `memory-sync` `PASS 35/35`
  - `context-size` `PASS 24/24`
  - `plan-gate` `PASS 37/37`
  - `manager-bootstrap` `PASS 13/13`
  - `product-loop` `PASS 17/17`

  No line other than `ok` and `PASS`.
- **The plugin block** (with `CLAUDE_CONFIG_DIR` a new directory under `$TMPDIR`, removed afterwards):
  - three `✔ Validation passed`;
  - `Skills (21)`, `Agents (9)`, and `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`;
  - `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only …)`;
  - `glab = glab` and `memory-sync = memory-sync`;
  - `:0`/`:0`, then `rc=1`;
  - `1`/`1`/`1`, then `rc=0`;
  - the nine model lines, then `rc=0`;
  - the eighteen skills lines, none `MISSING`;
  - no line, then `rc=1`.
- **The master hash.** `sha256sum -c plan/flow-product-level/master.sha256` → `plan/flow-product-level/master.md: OK`.
- **The walkthrough.** `PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh … 2>"$TMPDIR/pg2-trace.txt"` printed `PASS 17/17` and wrote a 434-line trace.
  - It is byte-identical to the build's `$TMPDIR/product-loop-trace.txt` (`diff` rc=0), so the L17 store listing (trace line 434) is unchanged.
  - `grep -c -E '/home/|/data/|plan-gate\.claim'` → `0`.
  - The trace file was removed afterwards.

### Follow-ups

FR1-2 was added to `follow-ups.md`: a claim left by a killed run blocks that number until it is removed by hand. This was proven with a planted claim. It is out of scope because the decision fixes the claim, not how a stale one is recovered.

### Not done / UNVERIFIED

- UNVERIFIED: that bash 3.2 (macOS) opens a noclobber `>` with `O_EXCL` as bash 5.3 does here. No macOS host was available.
- UNVERIFIED: that `O_EXCL` is exclusive on a store on a network filesystem. Only a local filesystem was tested.
- The `X` posts for `plan-gate.sh` and `tests/plan-gate.test.sh` still differ from `steps-1-scripts.md`, as `review-1.md` expects.

## Fix round — review round 2

Contract: `review-2.md`, its five findings and the manager's decisions, plus the B8 leftover. `master.md`, the steps files and `glab` 0.14.0 are untouched. Each attack was run under a work folder in `$TMPDIR` (removed afterwards), against a copy of the script as round 1 part 2 left it (sha256 `7427645b6b2d9be9…`, "before").

### Per finding

- **1 (medium), a claim left by SIGKILL: fixed.** `plan-gate.sh:97`: the claim refusal now ends `; when no run is writing, remove <path of the claim> by hand`, for report and verdict claims alike. The comment at :87-94 no longer says "never left in the store": it names SIGKILL, and a signal between the claim's subshell and `CLAIM=$1`, as leaving it.
  - Before (2 s `mktemp` stub, `kill -KILL`): `killed run rc=137`; the folder holds `.plan-gate.claim.verdict.r1`; `REFUSED: another run is writing verdict r1` (rc=1); `REFUSED: report r1 has no verdict yet` (rc=1).
  - After (2 s `date` stub, since verdict no longer calls `mktemp`): `killed run rc=137`; `REFUSED: another run is writing verdict r1; when no run is writing, remove <store>/briefs/notes-api/.plan-gate.claim.verdict.r1 by hand` (rc=1). With the claim removed, the verdict is written (rc=0) and no `.plan-gate.*` is left.
- **2 (low), TERM after `ln`: fixed as the Fix says.** `publish_file` clears `TMP_DIR` right after `ln` succeeds, before the `rm` (:213-216). The `TMP_DIR=''` after the report's `publish_file` call is gone.
  - Before (2 s `rm` stub, TERM once `report.r1.md` was there): rc=143; the folder holds `brief.md report.r1.md`; `REFUSED: the copies in plan.r1/ do not match report r1`, and the next report `REFUSED: report r1 has no verdict yet`.
  - After: rc=143; the folder holds `brief.md plan.r1 report.r1.md`; the verdict is written (rc=0).
  - Left open: a TERM while `ln` itself runs. Proven with an `ln` stub that links, then waits 2 s: rc=143 and `brief.md report.r1.md`. This is FR2-1.
- **3 (low), the copy-folder refusal before the claim: fixed by taking the claim first.** The pre-claim `plan.r<n>` test is gone. That test now runs only under the claim (:250-254), and its comment says why.
  - Before (2 s `date` stub holding the first run's claim): `REFUSED: plan.r1/ is there without report r1; look at it and remove it by hand`.
  - After: `REFUSED: another run is writing report r1; when no run is writing, remove …/.plan-gate.claim.report.r1 by hand`. The first run still writes r1 (rc=0).
- **4 (low), extra files in the copy: fixed.** `verdict` now also refuses unless `all_files plan.r<n>` (:134-135, every non-folder entry, sorted) equals `list_plan plan.r<n>` (:291-296). The refusal line is the same, `the copies in plan.r<n>/ do not match report r<n>`.
  - Before (`steps-1.r1.md` and `evidence.md` added): `verdict.r1.md` written, rc=0.
  - After: `REFUSED: the copies in plan.r1/ do not match report r1`, rc=1.
- **5 (low), SIGINT while `mktemp` ran: fixed.** `claimed_tmp` (:102-111) sets `TMP_FILE` to the fixed name `.plan-gate.tmp.<kind>.r<n>`, taken from the claim, before the file is made. It then removes any file of that name a killed run left, and creates the file with bash's noclobber `O_EXCL` open. The report (:266) and the verdict (:321) call it in place of `mktemp`.
  - Before (2 s `mktemp` stub, INT to bash only): rc=130, and `.plan-gate.a0DSA4` is left.
  - After: the same stub is never called (the verdict is written, rc=0). With a 2 s `date` stub, the call after the file is made: rc=130, and nothing is left beside `brief.md plan.r1 report.r1.md`.
- **B8 leftover: done.** `product-plan/SKILL.md:36` now opens with a pointer, "Whose the rules are, and how a rule file may change, is `glab:product-manager`'s." "The rules are the user's" stays once, in `product-manager/SKILL.md:62`. A repo-wide `grep` finds that one line.

### Unplanned changes

- **T33** (`tests/plan-gate.test.sh:411-439`): its delay stub moved from `mktemp` to `date`, because verdict no longer calls `mktemp` (finding 5). Its expected loser line now carries the claim path (finding 1).
- **T37's expected loser line** (:494) now carries the claim path (finding 1).
- **`publish_file`'s comment** says "the umask can leave it readable by this account alone" in place of "mktemp makes it 0600" (finding 5).
- **shellcheck SC2015** flagged `claimed_tmp`'s first form, `A && B || io`. It was rewritten as `if ! { A && B; }; then io; fi`, with the same meaning.

### Tests

- **New cases** (`tests/plan-gate.test.sh:507-601`). They use a launcher `$W/launch` that writes its PID, then `exec`s the run in the foreground. A stub signals that PID only: no background job, and nothing killed by name.
  - **T38:** a `date` stub sends SIGKILL under the verdict claim. The refusal names the claim; removed by hand, the verdict is written and no `.plan-gate.*` is left.
  - **T39:** an `rm` stub sends TERM on its first call after `report.r1.md` is linked. Then rc=143, `plan.r1/` hashes to the report, and the verdict is written.
  - **T40:** a `date` stub in the first report runs a second report synchronously. The second gets the claim refusal, rc=1, nothing on stdout, and the first writes r1.
  - **T41:** `steps-1.r1.md`, `evidence.md`, `01-a/notes.md` and `plan.r2/plan.md` are added to the copy, each in turn. Each is refused and writes nothing; the bare copy is accepted.
  - **T42:** `mktemp` and `date` stubs send INT under the claim, whichever is called first. Then rc=130, no verdict, and no `.plan-gate.*`.
- **Against "before":** `FAIL 8/42`. T38 to T42 fail on the findings; T33 and T37 fail only on the loser line, which changed; T22 fails on the files T38 and T42 leave.
- **Against the tree, after the last edit:** `PASS 42/42` ten times in a row, every line `ok`.
- **Not covered by any case:**
  - `claimed_tmp`'s `io` branch. It needs a store where the create fails, like the untested write failures of part 1.
  - A signal between the claim's subshell and `CLAIM=$1`. No stub can stop bash between two builtins; the comment states it from the review's reasoning.

### Gates

All run exactly as AGENTS.md prints them, after the last edit.

- **The script checks.** Nine `rc=0` lines. `shellcheck` gave `rc=0` with no findings; its first run was `rc=1`, the SC2015 above, fixed and run again.
- **The tests:**
  - `memory-sync` `PASS 35/35`
  - `context-size` `PASS 24/24`
  - `plan-gate` `PASS 42/42`
  - `manager-bootstrap` `PASS 13/13`
  - `product-loop` `PASS 17/17`

  No line other than `ok` and `PASS`.
- **The plugin block** (`CLAUDE_CONFIG_DIR` a new directory under `$TMPDIR`, removed afterwards):
  - three `✔ Validation passed`;
  - `Skills (21)`, `Agents (9)`, and `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`;
  - `Skills (1)  sync-memory`, `Agents (0)`, and `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)`;
  - `glab = glab`, `memory-sync = memory-sync`;
  - `:0`/`:0`, then `rc=1`;
  - `1`/`1`/`1`, then `rc=0`;
  - the nine model lines, then `rc=0`;
  - the eighteen skills lines, none `MISSING`;
  - no line, then `rc=1`.
- **The master hash.** `sha256sum -c plan/flow-product-level/master.sha256` → `plan/flow-product-level/master.md: OK`.
- **The walkthrough.** `PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh … 2>"$TMPDIR/…/trace.txt"` printed `PASS 17/17` and wrote 434 lines. `cmp` with the earlier `$TMPDIR/product-loop-trace.txt` (434 lines) gives rc=0: byte-identical, sha256 `f363b97e91088350…` for both. `grep -c -E '/home/|/data/|plan-gate\.claim|plan-gate\.tmp'` → `0`.

### Follow-ups

- **FR1-2** gained a line: the refusal now names the claim. Nothing yet tells a stale claim from a live one.
- **FR2-1 (new):** a TERM while `ln` runs still removes the copy of a linked report. The Fix's order narrows the window but does not close it.
- **FR2-2 (new):** SIGKILL leaves `.plan-gate.tmp.<kind>.r<n>` beside the claim. The next run under that claim removes it.

### Not done / UNVERIFIED

- UNVERIFIED: bash 3.2 (macOS). The noclobber `O_EXCL` create, now also used by `claimed_tmp`, and the trap's timing on TERM and INT were seen on bash 5.3.9 only.
- UNVERIFIED: that "a signal between the claim's subshell and `CLAIM=$1`" leaves the claim. This is the review's reasoning, not reproduced here.

## Final check record (manager, 2026-11-13)

The final check (an analyzer, read-only) found every step done or changed as recorded, every intent item held, and every gate green. It gave `DIVERGES: 1`, on one missing record, which this section supplies.

- **X3 now prints `253 ok` and 8 FAIL lines, not `261 ok`.** The `261 ok` above is from the build, before the two review rounds. All 8 failing posts check text that a review decision superseded:
  - A1: one byte-compare post, superseded by review-1 (A1, A2, A3, A6) and review-2;
  - A2: two byte-compare posts, and the partner post that runs the built test against the plan's script text (`FAIL 13/42` against the superseded script), superseded by the same rounds;
  - P4: one post, superseded by review-1 B7 (a pointer to `glab:product-manager` *The product pipeline*);
  - P7: one post, superseded by review-1 B4 (a pointer to *The cap*);
  - J2: one post, superseded by review-1 A4 and B9 (a pointer to Stage 1c);
  - R5: two posts, superseded by review-1 B5 (a pointer to *Starting project sessions*).
- **The current tests:** the script and test file as they now stand pass `PASS 42/42` (five runs by the manager, and the analyzer's own run).
- **The master's Final check 3** ("every post prints ok") holds with these eight recorded exceptions. Each is a review decision that replaced the plan's text. The plan files are not edited, by rule.
- **X2 is done.** The manager sent the walkthrough trace (434 lines, L1–L17) to the user in chat on 2026-11-13, then removed it from `$TMPDIR`.
- **`plan.md` *Tests* and C8** still say `PASS 29/29`, writing via `mv`, and a closed list of refusals. They are superseded by `review-1.md` and `review-2.md`, and the record stage names those two files as the current contract for `plan-gate.sh`.
