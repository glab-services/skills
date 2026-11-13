# Plan check, round 1 of 2 — flow-product-level, against the repo

Checked 2026-11-13 on `main` at `f3cfe85` (`glab` 0.13.0), Claude Code CLI
2.1.321 (from `command -v claude`), every `claude` command under a new empty
`CLAUDE_CONFIG_DIR` in `$TMPDIR=/data/tmp/claude`. Simulations ran in a
throwaway `git archive HEAD` export, which is now removed. Read: `master.md`,
`plan.md`, `evidence.md`, `questions.md` (Q1 "Opus for both", Q2 "Keep
names"), `steps-1-scripts.md` … `steps-4-repo.md`, and `AGENTS.md` in full.

## 1. Old texts and mechanisms

Every anchor or old text that a step replaces resolves on HEAD (proven with `/usr/bin/grep -n` and with the post helper's joined-text count):

| step | anchor / old text | where | count |
|---|---|---|---|
| J1 | `Autoloaded at session start;` | `skills/manager/SKILL.md:3` | 1 |
| J2 | `## Rule 0d — …` (insert after) | `skills/manager/SKILL.md:26` | 1 |
| J4.1 | the row `\| 1b \| Analyze the plan \|` (5 columns; the new 1c row has 5) | `skills/manager/SKILL.md:135` | 1 |
| J4.2 | `then Stage 2 — or, after the master check, the sub-plans` | `skills/manager/SKILL.md:274` | 1 |
| J4.3 | `## Stage 1b` (insert after) | `skills/manager/SKILL.md:266` | 1 |
| J5.1 | `The spec of each area the change touches, read first` | `skills/plan/SKILL.md:29` | 1 |
| J5.2 | the `## Request` bullet | `skills/plan/SKILL.md:92` | 1 |
| J5.3 | `**Amending after a plan check.**` | `skills/plan/SKILL.md:116` | 1 |
| J6 | `**Green tree**` in *Preconditions* | `skills/develop/SKILL.md:17` (section at :11) | 1 |
| J7.1 | `loads the glab:manager and glab:security skills` | `skills/bootstrap/SKILL.md:3` | 1 |
| J7.2 | ``reads it first from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh` `` | `skills/bootstrap/SKILL.md:17` | 1 |
| J7.3 | ``## 2. Load `glab:manager` and `glab:security` `` | `skills/bootstrap/SKILL.md:23` | 1 |
| J7.4 | ``Name the stage you are at in `glab:manager` → *The pipeline*`` | `skills/bootstrap/SKILL.md:45` | 1 |
| R2 | `` `scripts/manager-bootstrap.sh` and `scripts/context-size.sh` `` | `AGENTS.md:11-12` | 1 |
| R3 | `Skills (13)`, `Agents (7)`, `exactly these seven lines`, `fourteen lines`, `run all four`, ``five `rc=0` lines`` | `AGENTS.md` *Gates* | 1 each |
| R4.2 | ``the seven `plugins/glab/agents/*.md` `` | `AGENTS.md` (the model and skills entries) | 2, as the step says |
| R4.2 | `in all seven and` | `AGENTS.md` | 1 |
| R5.2 | ``` `glab:security` in all seven, `glab:plan` in the planner ```; `the planner and the plan check on Opus` | `README.md:15-16`, `:19-20` | 1 each |
| R5.5 | the `tests/` row | `README.md` *Working on this repo* | 1 |
| R1 | `"version": "0.13.0"` | `plugins/glab/.claude-plugin/plugin.json:3` | 1, the only `0.13.0` in `plugins`, `README.md`, `AGENTS.md`, `host.example.md` |

The mechanisms, proven where a command could run:

- **Names and counts** (P1–P9, R3). I built a tree whose frontmatter is faithful to the steps: the seven new skills with a bare `name:` and their level `description:`, the two agents with `model: opus`, their `tools:` and `skills:` lists, J1/J7–J11's description prefixes, and version 0.14.0. On it: three `✔ Validation passed`; `Skills (20)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-report, product-project-plan-verdict, push, review, security, ship`; `Agents (9)  reviewer, product-planner, integrator, developer, analyzer, product-analyzer, committer, planner, plan-analyzer`; the two `Hooks (4)` lines unchanged; the model gate printed 9 lines, including `plugins/glab/agents/product-analyzer.md:model: opus` and `plugins/glab/agents/product-planner.md:model: opus`, then `rc=0`; the skills gate printed 18 lines, none `MISSING`, the four new ones being `product-analyzer.md:glab:security`, `product-analyzer.md:glab:audit`, `product-planner.md:glab:product-plan` and `product-planner.md:glab:security`; the prefixed-name gate printed nothing, then `rc=1`. These match R3's green lines exactly.
- **Baseline (B2)** on the unchanged export: five `rc=0`; shellcheck `rc=0`; `PASS 35/35`; `PASS 24/24`; `Skills (13)`, `Agents (7)`; the model gate 7 lines; the skills gate 14 lines. This matches B2.
- **The digest (C4).** It is deterministic: `LC_ALL=C sort` over `./<path>`, then `sha256sum` of the lines (E8, re-proven below). The file set has a hole: R2.
- **Hook level read (C1, A3).** The hook runs with no argument (`hooks/hooks.json:6`, `timeout 5`). `CLAUDE_PROJECT_DIR` falls back to `$PWD`. The fixed `CTX` heredoc (`manager-bootstrap.sh:11-25`, about 2.9 KB) leaves room for two texts under 10,000 characters. Inferred: no command ran the new hook.
- **New scripts and repo rules.** A1–A6 say `#!/usr/bin/env bash`, mode 0755, shellcheck clean, `mktemp -d "${TMPDIR:?}/…"` with an `EXIT` trap, and no background process, so the PID-cleanup rule has nothing to act on. R3 puts `plan-gate.sh` and the three tests in the `bash -n`/`test -x` loop and in the shellcheck line, and adds three test lines. R4 adds `manager-bootstrap.sh`'s hook contract and `plan-gate.sh`'s script contract. `UNVERIFIED: bash -n, shellcheck and the 22/11/15 cases of plan-gate.sh and the three tests — the plan gives contracts, not script text, so there was nothing to run`.

## 2. Steps side by side

No later step undoes an earlier one. No two steps edit the same text differently: J5/J8 and J6/J8 touch different lines of `plan`/`develop`, and J7 owns `bootstrap`'s description, which J9 leaves out. The answers Q1 "Opus for both" and Q2 "Keep names" match every `[Q1]`/`[N3]` form as written. The contradictions are R4 (G4) and R6 (P1 against itself).

## 3. Skip-one simulation (all 32 steps)

All 114 posts were extracted with their step ids (`awk` over `### <id>` and `- post:`, 17+34+31+32 lines, the same count as X3's `sed`). Each post was evaluated once with `P`, `N` and `test -x/-f` replaced by recorders, which gave 9 `F`, 8 `N`, 114 `P` and 4 `X` actions. A build then applied every action, set the version, and put R1's phrase into the JSON `description`.

- Unchanged export: `114 FAIL`.
- Full simulated build: `111 ok`, `3 FAIL`. The three are A1, A3 and A6's test-run posts, which need the real scripts. This matches E13.
- Skipping each of the 32 steps (A1–A6, P1–P9, J1–J11, R1–R6), one at a time: every skipped step had all of its own posts red (`own-red n/n` for each). No other step's post went red, apart from the three always-red test-run posts. Example lines: `J4 own-red 6/6 other-red []`, `J6 own-red 2/2 other-red []`, `A3 own-red 4/4 other-red []`, `R3 own-red 9/9 other-red []`.

Skipping a whole step is detected. Skipping a sub-item is often not: R8.

## 4. The gate design (C4–C8, read as contracts; no script text exists)

- **Plan edited after acceptance.** Any edit to `master.md`, `index.md`, `plan.md`, `questions.md` or `steps-*.md`, and any such file added in a sub-plan, changes the digest, so `check` refuses. That holds, and it is too strict for the normal flow: R1.
- **Changed brief.** `report` and `check` both compare the brief's current `sha256sum`, so a changed brief is refused. Which refusal line `check` gives when two conditions hold is left open: R11.
- **Third rejection.** A third `REJECTED` by `product-manager` is refused. An `ACCEPTED` by `product-manager` after two rejections is not: R3.
- **Ordering and locale.** Fixed by `LC_ALL=C sort`. `sha256sum` and `shasum -a 256` print the same `<hash>  <path>` form (T21).
- **Missing store or file.** Exit 2, and J6 treats anything but `ACCEPTED r<n> <digest>` with exit 0 as a stop, so it fails closed.
- **Malformed verdict or report, and the numbering of `r<n>`.** Neither is specified: R4.

Probe in a temp tree (the C4 `find` exactly):

    ./01-a/plan.md
    ./master.md
    ./plan.md
    ./questions.md
    ./steps-1-scripts.md
    ./steps-1-scripts.r1.md        <- a round copy, hashed
    round-copy edit changes digest: yes
    plain sort, highest of verdict.r9.md verdict.r10.md: verdict.r9.md

## 5. One fact

- Version: R1 raises it once, to 0.14.0. That is the only `0.13.0` in shipped or repo files (proven).
- The gates' green lines carry the new counts (20/9/9/18) and the new script and test lines (R3). This was checked against the simulated build in §1.
- New entries R4 adds: the level line, the store line, the store layout, the digest and the report/verdict lines and refusals, the brief line, the rejection cap, the 8192-byte budget, and the description level prefix. Gaps: R5 and R7.

## 6. Gates on the built tree

The plugin gates, model gate, skills gate and name gate: green exactly as the changed R3 says (§1). The script gates and the three new tests: UNVERIFIED (§1).

## Findings

| id | severity | step | evidence | fix |
|---|---|---|---|---|
| R1 | high | J6, J4, C4 | J6 runs `check` "on every dispatch of this skill, fix rounds included". After acceptance, the project manager still writes into `plan.md`, which is in the digest. The round-3 line `- round 3: <stage> — …` goes under `## Decisions` before a Stage 3/5 fix round (`skills/manager/SKILL.md:170`). A user's model override line goes there "before the next dispatch" (`:117`). Rule 3 decision lines (`:74`, and a `PLAN WRONG` decision `:303`) and the `- effort:` line (`:30`) go there too. Each one changes the digest, so `check` refuses with `the plan changed since verdict r<n> accepted it; report again`. That sends routine bookkeeping back to Stage 1c and a new product audit. No step says which writes are allowed after `ACCEPTED`, and no T or L case covers a fix round. This breaks G3 ("must work with current flow"). | Decide and state it in C4, J4 and J6. One option: run `check` before the first Stage 2 dispatch only, and in Stage 1c send a step-changing amendment (`PLAN WRONG`) back as a new report. Another: keep post-acceptance record lines in a file outside the digest set, and change the rules that name `plan.md` for them. Add a T or L case: an accepted plan with a `- round 3:` line, then the develop gate. |
| R2 | medium | C4, A1, A2 (T2) | The `steps-*.md` pattern also matches the round copies `steps-<x>.r<n>.md`. The probe above shows `./steps-1-scripts.r1.md` listed, and an edit to it changes the digest. J4's REJECTED path creates exactly such copies. They are then hashed, copied into `plan.r<n>/`, counted in `files:`, and read by `glab:product-analyzer` as part of the plan. This contradicts C4 ("round copies … are not the contract"). T2 names `*.r1.md` and would pass with `plan.r1.md` alone. | In C4 add `! -name '*.r[0-9]*.md' ! -name '*.v[0-9]*.md'`. T2 should use `steps-1.r1.md`. |
| R3 | medium | C8, Decisions, P7, T15, L14 | The decision and C8 refuse only "a third `REJECTED` unless `by` is `user`". An `ACCEPTED` by `product-manager` after two rejections is written, and `check` then passes: development starts without the user. This contradicts G4 ("two rejections, then the user decides") and the refusal text "the next verdict is by user". | Refuse any verdict by `product-manager` once two `REJECTED` carry the current brief's hash. Extend T15 and L14 with an `ACCEPTED` by `product-manager` at the cap. |
| R4 | medium | C6–C8, A1 | Parsing is unspecified. Nothing says what `check`, `verdict` and the cap count do with a malformed verdict or report (a missing or duplicate `verdict:` line, a non-hex `plan-sha256`, a `report: r<n>` that differs from the file name), or with a reason text containing `ACCEPTED`/`REJECTED`. Nor does anything say how the "highest-numbered" verdict and report are found: a plain sort picks `verdict.r9.md` over `verdict.r10.md` (probe above). There is no refusal line and no T case for any of these. | C8: read each field only from its exact line, e.g. `^verdict: (ACCEPTED\|REJECTED)$`. Treat a missing or malformed field as a refusal, e.g. `REFUSED: verdict r<n> is malformed` with exit 1. Compare `<n>` numerically. Add T cases for a malformed verdict and for r10 after r9. |
| R5 | medium | J2, R4.2, Rule 5 | `glab:manager` Rule 5 owns the model per role (the `AGENTS.md` *One fact* entry names it). Its list (`skills/manager/SKILL.md:101-109`) has seven roles, and no step adds `glab:product-planner` or `glab:product-analyzer` on `opus` (no step mentions Rule 5). `:113` still says "not one of the seven", and `:121` says "name the role's model from the list above". `glab:product-manager` borrows Rule 5 and would find neither product role there. | Add a step: put the two roles with `opus` in Rule 5's list and change "one of the seven" to "nine", with P/N posts. |
| R6 | medium | P1, J9, A3 (C9), J7 | P1 says the product session "never runs `glab:manager`'s pipeline or its stage skills", but P1 and P6 use `glab:commit` and `glab:push`. Their bodies say they are "the entry point of `glab:manager` Stage 6" (`skills/commit/SKILL.md:7`) and Stage 7 (`skills/push/SKILL.md:7`), and J9 changes only their descriptions. C9 changes only point 2's name in the product text. That leaves "Each stage of its pipeline (`glab:manager` -> *The pipeline* …)" (`manager-bootstrap.sh:17`) and "What skips the pipeline …: `glab:manager` Rule 1" (`:24`). Rule 1 is not among the borrowed rules, and `bootstrap` step 2 repeats it (`skills/bootstrap/SKILL.md:25`). | C9: give the product text's whole point 2 and its last line. P1: name `glab:commit`/`glab:push` as the borrowed stage skills, or have J9 make their first sentence level-neutral. Either add Rule 1 to the borrowed list or say what skips the product pipeline. |
| R7 | medium | P1, J2, R4.2, P2 | The list "Rules 0b, 0c, 0d, 2, 3 and 5 hold at every level" is written in both `glab:manager` (J2) and `glab:product-manager` (P1). It is not an R4 *One fact* entry, and it breaks the say-it-once rule. `product-plan.md`'s 49152-byte budget (P2) is a new instance of the plan size budget entry, and R4 does not extend that entry. | Give the rule list one owner (`glab:manager`); P1 points without restating it, or R4 registers both files. Add `plugins/glab/skills/product-plan/SKILL.md` to the size-budget entry. |
| R8 | low | R3, R4, P2, J4 | Posts check one phrase per sub-item, and several sub-items have none. Left unchanged, each of these stays undetected while all 114 posts print `ok`: `Agents (7)`, `exactly these seven lines`, ``five `rc=0` lines``, `run all four` (each 1 on HEAD, no N post); the new scripts in the shellcheck line; the `plan-gate.test.sh` and `manager-bootstrap.test.sh` gate lines; and R4's store-layout, digest, brief-line, 8192 and description-level entries. | Add N posts for the four old phrases and P posts for `run all seven`, the shellcheck line, the two test lines and each R4 entry. Update X3's `114`. |
| R9 | low | B3, plan.md *Open* | `command grep -c '^- \*\*Answer' questions.md` prints `2` while both `**Answer:**` lines still hold `_(the manager writes the user's answer here)_` (proven), so B3 is green unanswered. `plan.md` *Open* still lists Q1 and N3 as waiting, though `questions.md` *Answers* records both. | B3 post: count the `## Answers` lines, or replace the placeholders. Amend *Open* in place. |
| R10 | low | C1, A3, A4 | The Decision says a typo runs as project "with a warning", but C1's regex only matches `[a-z][a-z-]*`. A value like `Product`, `product2` or `product # note` matches nothing and runs as project silently. | Match `^glab-level:` first, then check the value; any value that is not built gets the warning. Add a B case. |
| R11 | low | C8 `check` | When the highest verdict carries an older brief's hash, both `no verdict for this brief` and `the brief changed since verdict r<n>; plan again` fit. When several conditions hold, no order is given. T19 tests each condition alone. | Give the order of `check`'s refusals and which line covers the older-brief verdict. |
| R12 | low | C8, P7, `evidence.md` *Not verified* | `by user` is an argument the calling session chooses, and both sessions can write the store, so the cap and the verdict hold only as far as the sessions follow the skill text. This is not stated as a known limit. | Say it in the product spec's known limits and in README *Levels*, next to the main-session boundary (E11). |
| R13 | low | J4 *On REJECTED* | The amendment path assumes `plan.md` changes. When a conflict is in `master.md`'s goals, an approved master cannot be amended ("No round amends a `master.md` that has an `## Approval` line", `skills/plan/SKILL.md:116`), and J4 does not send that case to a changed request. | Add one clause: a `REJECTED` whose fix needs the master is a changed request (*The master plan and sub-plans*). |

Counts: critical 0 · high 1 · medium 6 · low 6.

NOT BUILDABLE
