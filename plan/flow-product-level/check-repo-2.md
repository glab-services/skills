# Plan check, round 2 of 2 (the last) — flow-product-level, against the repo

Checked 2026-11-13 on `main` at `f3cfe85` (`glab` 0.13.0); Claude Code CLI
`2.1.310 (Claude Code)` from `command -v claude`, printed under a new empty
`CLAUDE_CONFIG_DIR`, as was every other `claude` command; `TMPDIR=/data/tmp/claude`;
shellcheck 0.11.0. Read: `AGENTS.md` in full (the working tree's, equal to
HEAD), `master.md`, `plan.md`, `evidence.md`, `questions.md`, the five steps
files, each `*.r1.md` copy and `check-repo.md` (R1–R13). Every simulation ran
in a throwaway `git archive HEAD` export under `$TMPDIR` with this folder
copied in; all of them are removed.

**How the tree was built.** Each script, test and fixture was cut from its
`~~~ file=` text with the plan's own `B` helper (byte-identical to
`plan.md` *The post helper*, `diff` empty). `glab:session-rules` was made by
actually moving HEAD's sections as J2 says (Rules 0–3, 5, the *Round caps*
paragraph, the two handoff paragraphs), with J2.4–J2.7's in-place edits
applied to the moved text. The new skills and agents got the frontmatter their
steps give. J1/J10/J11 prefixed the real `description:` lines; J12 replaced
the real pointers; R1 set the version with `jq`. Every other `P` phrase was
appended, and every `N` phrase removed. So the scripts and the move are real,
and the prose around each phrase is not.

## 1. Round-1 findings

| id | status | evidence |
|---|---|---|
| R1 | fixed | C11, J5's freeze paragraph, J2 *Where a record line goes*, J5.3 and J7 send every post-report record line to `after-verdict.md`, which C4 leaves out. Attack: after `ACCEPTED`, `after-verdict.md` held `- model: developer sonnet` and `- round 3: …`, and `check` printed `ACCEPTED r1 39314cfe…`, rc=0. An extra line in `steps-1.md` gave `REFUSED: the plan changed since verdict r1 accepted it; report again`, rc=1. Restored, it gave `ACCEPTED r1`, rc=0. T23 and L12 are `ok`. |
| R2 | fixed | `list_plan` prunes `plan.r[0-9]*`, then `! -name '*.r[0-9]*.md' ! -name '*.v[0-9]*.md'`. Attack: an edited `plan.r1.md`, `steps-1.r2.md`, `master.v1.md` and `plan.r5/plan.md` → `check` still `ACCEPTED r1 …`, rc=0. A1's third post and T2 are `ok`. |
| R3 | fixed | Attack, a second project: two `REJECTED`, then `ACCEPTED product-manager` → `REFUSED: two REJECTED verdicts since the last ACCEPTED; the next verdict is by user`, rc=1. The same for `REJECTED`. `by user` without `user: "…"` was refused, and so were `user: ""`, `user: "   "` and the words on line 2. `user: "x"` was written, and `check` printed `ACCEPTED r3`. T15, T16, T26 and L15 are `ok`. |
| R4 | fixed | 16 corrupted forms of `verdict.r1.md` were tried. Lowercase, a trailing blank, a missing line, a duplicate or conflicting `verdict:`, a non-hex hash, the wrong `report:`, a blank reason, no `## Reason`, empty, binary, `## ` above the header, a bad `by:` and a bad `date:` each gave `REFUSED: verdict r1 is malformed`, rc=1. A reason that quotes `verdict: REJECTED` and a CRLF file were each read correctly (`ACCEPTED r1`). Ten rounds gave `check` → `ACCEPTED r10 …`, the next report was `report.r11.md`, and a stray `report.r012.md` was ignored. A spoiled `verdict.r9.md` made the next `verdict` refuse `verdict r9 is malformed`. T24, T25 and T27 are `ok`. |
| R5 | fixed | J2.5 puts `glab:product-planner` and `glab:product-analyzer` on `opus` into the moved Rule 5 list and changes `not one of the seven` (1 on HEAD) to `nine`. Both posts are `ok`, and the model gate prints 9 lines. |
| R6 | fixed | The built hook's project text differs from HEAD's only in the level line, point 2 (three skills) and the pointers of point 3 and the last line, which now name `glab:session-rules` Rules 0c, 0d, 1 and 0b (`diff` in §3). Rule 1 moved to `glab:session-rules`. J12.2/J12.3 make `glab:commit`/`glab:push` name either level's stage, and their old texts resolve once each. The commit-on-`main` rule moves into `glab:commit`. |
| R7 | fixed | The rule list has one owner, `glab:session-rules` (J2), and P1 points at it without the numbers. R4 registers `the rules of every level` with its six files. The size-budget entry gains `product-plan.md` and `skills/product-plan/SKILL.md`. |
| R8 | partly fixed | Every round-1 sub-item named in R8 now has its post: `N` for `Agents (7)`, `exactly these seven lines`, ``five `rc=0` lines`` and `run all four`, and `P` for the shellcheck line, the three test lines and each R4 entry. The posts of the new J2 move still leave sub-items unchecked: R2-3. |
| R9 | fixed | B3 now greps `^- \*\*Answer:\*\* the user chose` and prints `2` on the real answers. `plan.md` has no *Open* section any more. |
| R10 | fixed | The line is found first, then its value is checked. B12 is `ok`, and so are a tab after the colon (product) and a leading blank (project, since the line must begin `glab-level:`). |
| R11 | fixed | C8 gives the order, and `cmd_check` follows it (brief, waiting report, no verdict, malformed, older brief → `no verdict for this brief`, `REJECTED`, plan). T19 is `ok`. |
| R12 | fixed in text | The Decision, P1 *The cap*, R5.4 (README *Levels*), FU-P5 and the product spec all state it. No post checks it: R2-3. |
| R13 | fixed | J5.4 has the required text `a changed request, not an amendment`, and it has its post. |

## 2. New and changed steps

The `*.r1.md` copies were diffed against the current files. J was
renumbered: round 1's J9 and J11 (every-level descriptions, the committer)
are gone, replaced by the Decision that every-level components carry no
prefix. J2 (`glab:session-rules`) and J12 (pointers) are new, and
`steps-1b-scripts.md` is all new.

- **Old text exactly once.** Each old text that an `N` post removes or a step replaces was counted on HEAD over the joined text that the post helper reads. Every one is `1`. The exceptions are as the steps intend: ``the seven `plugins/glab/agents/*.md` `` is `2`, and R4.2 replaces both, as `the seven` in the model entry and as `preload (the seven`; `` `glab:manager` Rule 3 `` in `skills/plan/SKILL.md` is `2`, and J12.1 says "twice"; `glab:manager` in `context-size.sh` is `5`, all on `#` lines (10, 20, 23, 31, 73), and J12.4 changes every one. J2's moved headings, the *Round caps* paragraph, `Announce each handoff in one line:` and the following `With sub-plans …` paragraph each exist once. So do J5's `| 1b | Analyze the plan |`, the Stage 1b sentence and `**write the answer into `plan/{slug}/questions.md` yourself**`, J6's two anchors, J7's `→ read it.` and `**Green tree**`, J9's four, J12's commit and push sentences, and Stage 6's `A commit on `main``.
- **The mechanism.** The scripts are real and green (§3). The move is real, and nothing is lost: of HEAD `manager/SKILL.md`'s 259 non-empty lines, 250 appear verbatim in the built `manager` + `session-rules`. The 9 that do not are exactly the deliberate edits: J1's description, J2.4's Rule 1 sentence, J2.5's committer line, J2.5's two Rule 5 bullets, the *Pick the tier* pipeline paragraph cut at J2.7, J2.6's *Round caps*, J8's `seven`, and J5.2's Stage 1b sentence.
- **Contradictions.** No later step undoes an earlier one. P1's list leaves out `glab:product-project-plan-report`, and J3's list includes it, which is consistent. The every-level set of the Decision (session-rules, bootstrap, security, comments, audit, commit, push, committer) matches J10/J11, which prefix only the project stage skills and agents. C9's texts match the built hook. Minor: the steps-2 lead-in tells product skills to ask "as `glab:manager` *The pipeline* says", against its own "no product-level file points into `glab:manager`" (R2-6). The gaps are R2-1 to R2-6.

## 3. The scripts on the built tree

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    plugins/glab/scripts/plan-gate.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    tests/plan-gate.test.sh rc=0
    tests/manager-bootstrap.test.sh rc=0
    tests/product-loop.test.sh rc=0
    rc=0                                   (shellcheck 0.11.0, all nine files)
    PASS 35/35   PASS 24/24   PASS 29/29   PASS 13/13   PASS 16/16
    lines that are neither `ok …` nor `PASS …` across the five tests: 0

Every T1–T29, B1–B13 and L1–L16 line printed `ok`, by name.

The gate was then attacked beyond its tests, with `plan-gate.sh` from A1 on
fresh stores (all in §1 unless noted):

- **An edited step is refused.** So is an added `steps-9-new.md`, and so is a new `01-a/plan.md`: each gave `REFUSED: the plan changed since verdict r1 accepted it; report again`.
- **A bookkeeping line in `after-verdict.md` is accepted** (R1).
- **A round copy is not hashed** (R2).
- **Two runs on the same tree give the same digest.** `39314cfe…c133749` came back each time: twice from the work dir, from `/` with a trailing slash, with a relative `plan`, and with `./plan/.`.
- **A changed brief is refused.** `check` and `report` both gave `REFUSED: the brief changed since the plan was written; plan again`, and the restored brief gave `ACCEPTED r1`.
- **After 2 rejections, a product-manager `ACCEPTED` is refused** (R3).
- **A malformed verdict is handled** (R4).
- **r10 sorts after r9** (R4).

The hook, from A3: with `CLAUDE_PROJECT_DIR=/nonexistent/x` or a file path,
it exits 0 with empty stderr. An `AGENTS.md` that is a directory gives the
project text. The product text names `glab:product-manager` -> *The product
pipeline* and *Your skills — this level only*, which are P1's required
headings.

## 4. The `glab:session-rules` move

- **Exactly once.** On the built tree, every moved rule is in `session-rules` once and in `manager` zero times: Rules 0, 0b, 0c, 0d, 1, 2 with *Your own context*, 3 and 5, *Round caps* and *The handoff line*. `## Rule 4` is only in `manager`. The line-level check in §2 shows nothing is lost.
- **Pointers.** The 23 rule pointers outside `manager` on HEAD were found with `grep -rnoE 'glab:manager.? Rules? …'`. J12, A3 and R4 name every one, and the J12, A3 and R4 posts are all `ok`. On the simulated tree the only pointer left is `AGENTS.md`'s `` `glab:manager` Rule 5 and its handoff-line format ``, which R4.2 replaces and no post checks (R2-3). The other hit, `glab:manager` Rule 4 in `session-rules`, is intended (J2.5). The posts check that no `` `glab:manager` Rule `` is left in `plan`, `develop`, `audit` and `ship`, and that no `glab:manager` is left in `context-size.sh`. Section pointers that now land on a one-line forward instead of the rule remain (R2-2). The bare `Rule <n>` references left inside `manager` resolve through J2.9's `a Rule <n> cited here, but Rule 4, is that skill's`.
- **AGENTS.md *One fact*.** R4.2 moves each entry whose fact moved: the round caps, the ask-conditions, the model per role, the one resume, the handoff file, the context hook and the session effort. Each old text counts 1 on HEAD, and the new texts carry `session-rules`. New entries are added for the level line, the store line, the store layout, the digest, the brief line, the cap, the rule-file budget, the rules of every level and the level boundary. Gaps: R2-5.

## 5. Skip-one, all 32 steps

Each line below comes from a build of every step but one, with all 214 posts
run on it. `own-red` is how many of the skipped step's posts failed. The last
column lists any other step whose post failed.

    A1 own-red 4/4 other-red []
    A2 own-red 3/3 other-red []
    A3 own-red 2/3 other-red []
    A4 own-red 3/3 other-red []
    A5 own-red 4/4 other-red []
    P1 own-red 13/13 other-red []
    P2 own-red 7/7 other-red []
    P3 own-red 3/3 other-red []
    P4 own-red 2/2 other-red []
    P5 own-red 2/2 other-red []
    P6 own-red 4/4 other-red []
    P7 own-red 3/3 other-red []
    P8 own-red 5/5 other-red []
    P9 own-red 7/7 other-red []
    J1 own-red 3/3 other-red []
    J2 own-red 24/25 other-red []
    J3 own-red 2/2 other-red []
    J4 own-red 3/3 other-red []
    J5 own-red 10/10 other-red []
    J6 own-red 4/4 other-red []
    J7 own-red 3/3 other-red []
    J8 own-red 3/3 other-red []
    J9 own-red 9/9 other-red []
    J10 own-red 1/1 other-red []
    J11 own-red 1/1 other-red []
    J12 own-red 12/12 other-red []
    R1 own-red 2/2 other-red []
    R2 own-red 3/3 other-red []
    R3 own-red 20/20 other-red []
    R4 own-red 32/32 other-red []
    R5 own-red 16/16 other-red []
    R6 own-red 2/2 other-red []

All 32 steps: no other step's post went red (`other-red []` for every step). A3's unred post is its `test -x` guard, true on HEAD. J2's is its `## Rule 4` guard, also true on HEAD.

Full build: `214 ok`, which is X3's loop exactly. Unchanged export: 2 `ok`,
the guards A3 `test -x` and J2's `## Rule 4` kept in `manager`, as E13 says.
The lines match E17.

Skipping a whole step is detected. Doing a step only halfway often is not
(R2-3).

## 6. The AGENTS.md gates, as the plan changes them

R3's first block on the built tree is in §3, and it matches R3's *Green is*
line by line: nine `rc=0`, shellcheck `rc=0`, and every test `PASS n/n`. The
plugin block under a new empty `CLAUDE_CONFIG_DIR`, compared with R3.2 and
E18:

    ✔ Validation passed  ×3
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
    …memory-sync.sh:1  …sync-memory/SKILL.md:1  README.md:1  rc=0
    model gate: 9 lines, …/product-analyzer.md:model: opus and …/product-planner.md:model: opus among them, rc=0
    skills gate: 18 lines, none MISSING, the 4 new ones as R3.2 lists them
    name gate: no line, rc=1

Every line matches R3's changed green lines and E18. One part is not shown:
that the developer's prose around each phrase reads as the step says. That
is for Stage 3 and the review.

## Findings

| id | severity | step | evidence | fix |
|---|---|---|---|---|
| R2-1 | medium | J5, J7, master G3 | A plan from a brief that splits into sub-plans has no stated Stage 1c. J5.2 puts `Stage 1c first for a plan from a brief` on the single-plan branch only (`then Stage 2 — … — or, after the master check, the sub-plans`). J5.4 says "after every approval the tier needs", and sub-plans are approved one at a time, each after its predecessor is committed (*The master plan and sub-plans*). J7 checks `plan/<slug>`, sub-plans included. So each later sub-plan changes the digest; proven: a new `01-a/plan.md` after `ACCEPTED` → `REFUSED: the plan changed since verdict r1 accepted it; report again`. Each later sub-plan's first `/glab:develop` is refused and sent back to Stage 1c. The result is one report and one Opus audit per sub-plan, and from the second on the audited copy also holds the sub-plans already built. That contradicts the Q1 consequence told to the user, "a few times per business plan and per report, not per change". The gate fails closed, but the flow is reached only through refusals, and no T or L case has a brief with sub-plans. | Choose and state in J5 (and J5.2's sentence): either a plan from a brief is reported once per sub-plan, after that sub-plan's approval, as the expected path, or the master and every sub-plan are planned before the first report. Add an L case: a brief, master + `01`, accepted, then `02` added → `check` refuses → report r2. |
| R2-2 | low | J2, J12 | Pointers to the moved round caps and handoff line still name the old sections, which now hold a one-line forward. In `session-rules` there are three: Rule 0d `(see *The pipeline*)`, Rule 5 `the round caps stay what *Pick the tier* gives them`, and *The handoff line* `round cap (*Pick the tier*)`. In `manager`, Stages 1b, 3, 5 and 6b say `a third under *Pick the tier*'s round-3 rule` (or `rule`). `skills/ship/SKILL.md:27` says `within *Pick the tier*'s round caps`. The moved Rule 3 names `*What you never do*`, and P1 gives the product manager no such section. | J2/J12: point these at `glab:session-rules` *Round caps* / *The handoff line*. Give Rule 3's push clause `glab:push`, which holds at both levels. |
| R2-3 | low | J2, J12.2, R12 | Posts check a moved section's absence from `manager` only for Rules 0b, 2 and 5, the *Round caps* paragraph and the handoff sentence. Mutant, proven: Rules 0, 0c, 0d, 1 and 3 and Stage 6's full commit-on-`main` sentence copied back into the built `manager` (`grep -c` of three moved headings: `manager:3`, `session-rules:3`). All 214 posts still print `ok`. That is a say-it-once break no post sees. Two R4.2 replacements have only a `P` post. In the simulated build, which appends each `P` phrase and so passes all 214 posts, `AGENTS.md` still counts `1` for `` (`glab:manager` Rule 5 and its handoff-line format in `plugins/glab/skills/manager/SKILL.md`, `` and `1` for `` what the product is (`plugins/glab/skills/manager/SKILL.md`, ``. A real build that adds instead of replaces would leave two *One fact* pointers at the old home. No post checks R12's known-limit sentence (P1 *The cap*, R5.4). No post checks the headings of Rules 0, 0b and 0d in `session-rules`. | Add `N` posts on `manager` for `## Rule 0 — `, `## Rule 0c — `, `## Rule 0d — `, `## Rule 1 — `, `## Rule 3 — ` and `is said in the dispatch to be deliberate`. Add `N` posts on `AGENTS.md` for the two old R4.2 texts. Add `P` posts on `session-rules` for `## Rule 0 — `, `## Rule 0b — ` and `## Rule 0d — `. Add a required text and post for the `by user` limit in P1 and in README. Update X3's `214`. |
| R2-4 | low | P1, P8, R5.5, LP list | The product session writes into the store. `glab:product-planner` Writes the briefs and rules, and `plan-gate.sh verdict` runs through Bash. E19/F8 say that writes outside the working and additional directories need approval. The plan states this caveat for project sessions only (P1 CLI bullet), and nothing says how the product session reaches a store outside its repo: no `--add-dir`, and no LP case. UNVERIFIED that a subagent's Write outside its directories is prompted rather than refused. | P1 *The shared store* and README *Try the product loop*: say the store is added to the product session (`--add-dir <store>` or the settings' additional directories) or kept inside its repo. Add the product-side write to LP4 or a new LP. |
| R2-5 | low | R4.2 | Two *One fact* entries miss files that state their fact. *The plan digest* entry leaves out `README.md`, though R5.4 says the record lines after a report go to `after-verdict.md`, outside the hash. The round-copy entry (`<name>.r<n>.md`) is not extended, though `plan-gate.sh` now depends on that name to exclude copies from the digest, and P3 (`product-plan.r<n>.md`) and J5 Stage 1c state it. | Add `README.md` to the digest entry. Add `plan-gate.sh`, `session-rules`' *Where a record line goes* where it applies, `skills/product-plan-analyze/SKILL.md` and Stage 1c to the round-copy entry. |
| R2-6 | low | steps-2 lead-in, P2–P7 | The lead-in tells each product entry-point skill to ask for a missing argument "as `glab:manager` *The pipeline* says of stage skills". Two lines later it says "no product-level file points into `glab:manager`". Only `product-manager` has an `N 'glab:manager'` post, so a developer who copies the pointer into P2–P4, P6 or P7 is not caught. | State the rule in place ("with none, ask which one; never the most recent"), drop the pointer, and add `N … 'glab:manager'` for P2–P4, P6 and P7. |

Counts: critical 0 · high 0 · medium 1 · low 5.

None is critical or high, so this round gives no third round (*Round caps*).
Every fix is a sentence or a post in a steps file. The scripts, their tests
and every gate are green as the plan states them.

NOT BUILDABLE
