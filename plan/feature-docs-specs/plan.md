tier: full — removes 124 tracked files (recoverable from history), changes what the installed `glab` workflow does with every finished plan, and rewrites the working-agreement rule on live runs with the user's own key

# Plan — feature-docs-specs

Specifications move to `docs/specs/`, one living spec per area. A change's
`plan/<slug>/` stays the working area and is committed as the work goes; once
the change's push has landed, one docs commit updates the area spec and
removes the folder, and the spec names the commit that still holds it. The
seven existing plan folders are migrated and removed in this change; the
payload (`glab`) gains the rule as its default for installers.

Read with `findings.md` (path list, every occurrence by `file:line`, the
inventory of what must survive) and `questions.md` (Q1, answered A). Base:
`main` = `origin/main` = `6838133` (pushed on the user's go-ahead). The
post-condition checker is `check.sh` beside this file.

The planner's Write into `plan/feature-docs-specs/` was refused; these files
were written to `/data/tmp/claude/feature-docs-specs-plan/` with a
`SHA256SUMS`, for the manager to verify and copy here.

## Amendments — Stage 1b round 1/2 (`NOT BUILDABLE` from both analyzers)

| finding | what changed |
|---|---|
| R1 | X1's developer writes its result to a `$TMPDIR` file the dispatch names (D21); X3's guard then finds the folder clean. |
| R2 | P2 changes Rule 5's "for this task" to end with the task's record (D22); only `manager/SKILL.md:126` states that duration (`findings.md`). |
| R3 | D7 and R2c keep the user's words; only the two citations change. The exact before and after are in D7. |
| R4 | P4, P5 and P11 carry the "keeps its plans" exception. |
| R5 | P7 tells the Stage 2 developer `## Record` is not its step, waives Step 5 for the record, and says the gates run. |
| R6 | R2d's one-fact entry names `plugins/glab/scripts/manager-bootstrap.sh`. |
| R7, M7 | `check.sh` section 10 has one fixed string for each quoted insertion (72; 73 after round 2), read with wrapped lines joined. |
| R8 | R2e says incidents are moved into the spec's *Incidents*. |
| M1 | `check.sh` section 1 reads the working tree: a folder passes when it is gone and every index entry left is an unstaged deletion. Tested on a finished tree with nothing staged. |
| M2 | X5 runs `check.sh` from history with `STAGE=record LAST=<sha>`. |
| M3 | Five more tags in S3 and the heredoc; and every open-items section of every record file (49) is tagged under its folder's *Records* (D23). |
| M4, M5 | Decision lists are fixed per source in `check.sh` section 5, U-lists and the numbered `fix-probe-findings` lists included; `feature-plugin-marketplace/plan.md`'s **D1–D9, **M1–M7 are slice steps, not decisions (D23, `findings.md`). |
| M6 | P12 repoints `external-agent.sh:235` "(findings P4 …)"; *Measurements* carries P4; section 2 and section 11 see it. |
| M8 | Section 2 matches each path, not the line; sections 9 and 13 count untracked files. |
| M9 | Every tag is checked under the heading its kind allows; the D15 tags are open at `STAGE=build` and closed at `STAGE=record`; no section may be empty, and the `## ` headings must be exactly the list. |
| M10 | `check.sh` exports `GIT_OPTIONAL_LOCKS=0`. |
| M11 | D12 and `findings.md` state the pushed state. |

### Round 2/2 — rule-changes analyzer `BUILDABLE`; migration analyzer `NOT BUILDABLE` on four inventory gaps

The user decided (chat, 2026-10-17): add the four, then build — no third Stage 1b round; Stage 3 conformance runs `check.sh` against the built tree (U6).

| finding | what changed |
|---|---|
| 1 | `plan-r3.md:60-73` "Required by the review of rev 2 (binding)" V1–V8: in `check.sh` section 5's `plan-r3.md` list and in S4 *Decisions*. |
| 2 | `feature-plugin-marketplace/questions.md:7-19`, the user's binding D1–D4 and S1–S5: a new section-5 line `marketplace.md feature-plugin-marketplace/questions.md D1 D2 D3 D4 S1 S2 S3 S4 S5`, named in S1 *Decisions*; D23 and `findings.md` *Decision lists* corrected. |
| 3 | `sync-local-edits/result.md:66` P1 joins `M1 M2 M3`; its second `## Decisions` (`:230-232`) is the tag `[sync-local-edits/result.md decisions]` (kind D); the same in S2. |
| 4 | Three more open-items sections — `bug-reviewer-findings/result-slice1.md` L220 *Known undiscriminated*, `feature-plugin-marketplace/questions.md` L202 *Not questions*, `feature-plugin-marketplace/findings.md` L614 *…risks* — are R tags; D23's heading match now also takes "known", "not questions" and "risk" (52 sections). |
| leftovers | P9's `record` bullet carries the "keeps its plans" exception (one more fixed string: 73); X3 says what the manager does when its guard prints `STOP`. |

## Amendments — review round 1/3 (both reviewers `BLOCK`)

The user decided U7 and U8 (chat, 2026-10-18; *Decisions*). Precondition, as the manager reports it from its `git status --short` before Stage 2: the tree was clean but for the untracked `plan/SESSION-HANDOFF.md` and this folder, so no removed file had uncommitted edits (`UNVERIFIED` by the planner: not re-run, the tree now holds the build).

| finding | where it is fixed | slice |
|---|---|---|
| B1 squash/rebase loses the named commit | U7, D25; P1 (`:154`), P2 (Stage 7, Stage 8, *never*), P7, R1a, R2e | payload, repo |
| B2 nothing commits `plan/<slug>/` | P2 Stage 6, P4, P15 (`ship.md`); Stage 8 condition 2 | payload |
| B3 unguarded `git rm` (empty slug removes `plan/`) | P6 | payload |
| B4 audit file removed without its findings | D26; P1 Step 3, P2 Stage 8, P6, P7, P11 | payload |
| B5 `git show <sha>:plan/<slug>/` only lists names | U7; P1, P7, R1a, R2e; *Spec rules* Records and Citations; SR1 | payload, specs |
| B6 nothing checks what is carried | D27; P2 rows 8 and Stage 8; P8 (record check) | payload |
| B7 "nothing untracked … committed" contradicts committing | R2e | repo |
| A8 testable "before the rule"; the default is the user's | D28; P1, P2 Stage 8; U9 | payload |
| A9 tracked files only | P7 | payload |
| A10 "does" → "did" | U8; D7, R2c | repo |
| A11 list item ends "rejected." | P1 Step 3 | payload |
| A12 one commit | D31 (no change) | — |
| S-B1 the `pkill` incident | S3, SR2; tag kind I | specs |
| S-A2 `EDQUOT`, ugrep pointers | S1, SR3 | specs |
| S-A3 C2 dangles | S4, SR4 | specs |
| S-A4 probe finding 2 both open and closed | S4, SR5; tag kind C; D32 | specs |
| S-A5 verdict set | S4, SR6 | specs |
| S-A6 stale once landed | X1 | record stage |
| Stage 3: L1a *Expected* edited | D30 (allowed, no change) | — |
| `plugin.json` description | P14, D29 | payload |

### What the developer redoes, by file boundary

- **Payload, `README.md`, `AGENTS.md`** (one developer; `plugins/glab/`, `README.md`, `AGENTS.md`): bring the built text of P1, P2, P4, P5, P6, P7, P8, P9, P11, P14, R1a, R2c, R2d and R2e to the step texts above, and add P15 (`commands/ship.md`). `fixes-r1.py`, beside this plan, makes exactly those edits on the built tree — `python3 -I plan/feature-docs-specs/fixes-r1.py` from the repo root — and asserts that each built text occurs once, stopping otherwise. On a `cp -a` copy of the built tree it printed `applied`, and `git diff --stat` then showed the 20 paths of A5 plus the 124 deletions. Already right, not touched: P3, P10, P12, P13, R1b, R1c, R2a, R2b. The version stays `0.5.0`.
- **Specs** (one developer; `docs/specs/` only):
  - SR1 — every *Records* line's recovery to the restore form (in the copy: nine lines, 3 + 2 + 1 + 3 per spec):

    ```bash
    sed -i -E 's#plan: `git show ([0-9a-f]{7}):plan/([a-z-]+)/`#plan: `git restore --source=\1 -- plan/\2/` (one file: `git show \1:plan/\2/<file>`)#' docs/specs/*.md
    ```
  - SR2 — `memory-sync.md` *Incidents*: the item `- [bug-reviewer-findings/findings.md pkill] …` (S3).
  - SR3 — `marketplace.md` *Incidents*: the pointed-at line naming `EDQUOT` and the `leading alternation` (S1).
  - SR4 — `external-agents.md` *Measurements*: the C2 bullet with `core.fsmonitor` (S4).
  - SR5 — `external-agents.md`: `[feature-opencode-worker/probe-r3.md 2]` and `[fix-probe-findings/plan.md follow-up-3]` move from *Open* to *Closed follow-ups*, "closed: corrected in *Live runs*"; neither stays under *Open*.
  - SR6 — `external-agents.md` *How it works now*: the whole verdict set (S4).
- Slice M is done and is not redone. Then A1, A2 and A3 with the amended `check.sh`: on the built tree it now prints 77 `FAIL`, each one an item of this list (`findings.md`); on the copy with both lists applied it printed none.

## Amendments — conformance round 2/4 (`CONFORMS`, two inconsistencies inside the plan)

1. **R2d still said "the record after the push"**, against U7. R2d's quoted text now reads "the record once the change has landed on the default branch, the folder removed and the commit on the default branch that holds it named". For the developer, `AGENTS.md:191-192` as built — before: "`docs/specs/` unless `AGENTS.md` names another place, the record after the push, the folder removed and the commit that holds it named" → after: "`docs/specs/` unless `AGENTS.md` names another place, the record once the change has landed on the default branch, the folder removed and the commit on the default branch that holds it named" (rewrap within the bullet only).
2. **S4 prescribed `git show` for removed folders**, against the amended *Citations* rule. S4 now cites them with `git restore --source=<sha> -- <path>/`. For the developer, in `docs/specs/external-agents.md` as built:
   - `:304` — before: "the transcripts are at `git show 51043c4:plan/feature-opencode-worker/probe-r3/`." → after: "the transcripts are at `git restore --source=51043c4 -- plan/feature-opencode-worker/probe-r3/`."
   - `:603` — before: "`git show 51043c4:plan/feature-opencode-worker/probe-r3/<model>/` for each" → after: "`git restore --source=51043c4 -- plan/feature-opencode-worker/probe-r3/<model>/` for each"
   - `:711` — before: "rev 3 restarted from `889b804` after archiving it: `git show 8cb2a92:plan/feature-opencode-worker/rev2-build/`." → after: "rev 3 restarted from `889b804` after archiving it: `git restore --source=8cb2a92 -- plan/feature-opencode-worker/rev2-build/`."

`check.sh` gains one insertion string and one *gone* string for item 1, and a check that no spec cites a folder with `git show` (`git show <sha>:<path>/` followed by a backtick) for item 2.

## Amendments — review round 2/3 (scope cut)

Payload reviewer `BLOCK 4`, specs reviewer `BLOCK 1`, every finding in round-1 fix code. The user cut the scope (U10, U11); round 3 is the last review, so this round removes logic and adds no guard.

| what | where now |
|---|---|
| removal of `plan/<slug>/` and of the audit file by `glab` | gone from P1, P2, P6, P7, P11, R1a; this repo's own rule in R2e, done by the manager session (X0, X3) |
| `git rm` and its guard in `committer.md` | gone: `committer.md`, `commit.md`, `push.md`, `ship.md` back to `6838133` (D34) |
| default branch, `<remote>/<default>`, `symbolic-ref`, `merge-base --is-ancestor` | gone from the payload (P1, P2, P9, R1a); `origin/main` stays only in this repo's rule (R2e) |
| Stage 6 commits `plan/<slug>/` (round-1 B2) | cut (D33) |
| restore instructions | read-only forms only (U11): R2e names all three; the specs use `git ls-tree` and `git show` (SR7) |
| analyzer record check | kept; verdicts from the existing list (D35) |
| advisories 6, 7 | P2 Stage 8 says ordinary docs change; decisions in the dispatch and the spec (D36) |

### What the developer redoes, by file boundary

- **Payload, `README.md`, `AGENTS.md`** (one developer): run `python3 -I plan/feature-docs-specs/fixes-r2.py` from the repo root on the built tree. It puts `plugins/glab/agents/committer.md`, `plugins/glab/commands/commit.md`, `plugins/glab/commands/push.md` and `plugins/glab/commands/ship.md` back to `6838133` (`git checkout 6838133 -- …`), then rewrites, each built text asserted to occur once: `plugins/glab/skills/plan-first/SKILL.md` (description, Step 3's `## Record` bullet, *Plan files are working files*, *User Override*, *Quick Reference*); `plugins/glab/skills/manager/SKILL.md` (Stage 6 back to its base sentence, rows 8, Stage 7, Stage 8, *What you never do*); `plugins/glab/agents/developer.md` (the record section); `plugins/glab/agents/analyzer.md` (the Step 3 sentence, the record check); `plugins/glab/skills/bootstrap/SKILL.md` (the `record` bullet); `plugins/glab/skills/audit/SKILL.md` (item 4); `README.md` (the paragraph); `AGENTS.md` (the `plan/` rule and the lifecycle *One fact* entry). The texts are those of P1–P15, R1a, R2d and R2e above. Untouched: `plugin.json` (0.5.0, description with "record"), the hook, `commands/plan.md`, the script, the profiles.
- **Specs** (one developer, `docs/specs/` only) — SR7, the read-only citations (U11), one command:

    ```bash
    sed -i -E 's#`git restore --source=([0-9a-f]{7}) -- (plan/[^` ]*/)`#`git ls-tree -r --name-only \1 -- \2`#g' docs/specs/*.md
    ```

  It turns every *Records* line and `external-agents.md:304`, `:603` and `:711` into `git ls-tree -r --name-only <sha> -- plan/…/`; the *Records* lines keep their "(one file: `git show <sha>:plan/<slug>/<file>`)". In the copy: `git restore` 0 lines left, `git ls-tree -r --name-only` 6 + 2 + 1 + 3 lines.
- Then A1, A2 and A3. On the built tree today the amended `check.sh` prints 60 `FAIL`, each a cut item; on a `cp -a` copy with both applied it printed none.

## Decisions

From the user, in chat, 2026-10-17 — binding:

- U1 — Specs live in `docs/specs/`, **one per area**, living: how the area works now, why (the decisions that still bind), known limits and what is not verified, and its open follow-ups.
- U2 — Commit, then remove: `plan/<slug>/` is committed during the work; after the change's push lands, one docs commit updates the area spec and `git rm -r plan/<slug>/`, and the spec names the commit so the plan stays recoverable. `plan/` stays the working area; `plan/SESSION-HANDOFF.md` stays there, untracked.
- U3 — Migrate the seven folders in this change: first specs from them, every still-open follow-up moved (none lost), recorded incidents kept, every citation repointed, the folders removed, the commit cited for each.
- U4 — The rule goes into the payload wherever it describes the plan lifecycle. Default for installers: `docs/specs/` and removal after the push; a repo's own `AGENTS.md` may name another place or keep its plans.
- U5 — `AGENTS.md:106-111` is replaced by the user's approved wording, with only its citations adjusted (D7 gives the text).
- U7 — After review round 1/3 (chat, 2026-10-18): **amend Stage 8, do not cut it.** It runs only after the change has landed on the default branch and names a commit verified reachable from `<remote>/<default>` (`git merge-base --is-ancestor`), so squash and rebase merges are safe; Stage 6 commits `plan/<slug>/`; the removal is guarded; an analyzer checks that every follow-up and incident is carried before removal; the restore instruction is `git restore --source=<sha> -- plan/<slug>/` (one file: `git show <sha>:plan/<slug>/<file>`).
- U8 — (chat, 2026-10-18) in the user's live-run sentence, "does" becomes "did" — that word only, besides the two citations D7 changes.
- U9 — The default for installers (`docs/specs/`, and removal once the change has landed) is the user's decision (U4), not the planner's; A8's advisory asked that it be recorded as such.
- U10 — After review round 2/3 (chat, 2026-10-18): **scope cut.** In the payload, Stage 8 "Record" is the spec only: the developer writes or updates `docs/specs/<area>.md` from `plan/<slug>/`, `glab:analyzer` checks at every tier that no follow-up, decision or incident was dropped, and it is committed as a docs change. `glab` never removes `plan/<slug>/` or an audit file; `glab:plan-first` says the plan's lasting content goes into `docs/specs/`, and whether the folder is then removed is the repo's own `AGENTS.md` decision. Stripped from the payload: the committer's `git rm` and its guard, the default-branch, `<remote>/<default>`, `symbolic-ref` and `merge-base --is-ancestor` preconditions, the audit-file removal, the named-commit machinery, and the restore instruction. In this repo, `AGENTS.md` keeps a short rule: the manager session removes a finished folder after its change has landed on `origin/main`, by its exact path, after checking it is tracked, clean and identical on `origin/main`, and the spec names the last commit on `origin/main` that holds it. This change's own record (X steps, C5) follows that rule. The version stays `0.5.0`. U10 replaces U7 wherever they differ.
- U11 — (chat, 2026-10-18) **retrieval is read-only everywhere**: one file `git show <sha>:plan/<slug>/<file>`; the list `git ls-tree -r --name-only <sha> -- plan/<slug>/`; the whole folder `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`. No `git restore` into the repo. U11 replaces U7's restore instruction and the restore forms of round 1's SR1 and conformance round 2/4 item 2.
- U6 — After Stage 1b round 2/2 (chat, 2026-10-17): the four inventory gaps the migration analyzer found are added (*Amendments*, round 2), then the plan is built. No third Stage 1b round; Stage 3 conformance runs `check.sh` against the built tree.

The planner's, under `glab:manager` Rule 3 (the manager reviews these and may overrule one):

- D1 — **Four areas:** `marketplace.md` (the marketplace, this repo's layout, gates, rules, host file, and the records of changes to them), `workflow.md` (the `glab` pipeline, tiers, rules, agents and commands, model choice, the plan lifecycle), `memory-sync.md`, `external-agents.md`. They follow the plugin boundary and the one place the user named a fourth: each existing folder lands in one primary spec (`findings.md` table), and none needs two halves of the same fact.
- D2 — **Fixed headings and greppable tags** (*Spec rules* below): every follow-up, question and open list keeps its source as `[<slug>/<file> <id>]`. That makes "none lost" a command (`check.sh` section 4), not a judgment.
- D3 — **The spec names the last commit that holds the folder**, not the removal commit: a commit cannot carry its own hash. `git log -1 --format=%h -- plan/<slug>/` gives it before the removal; after it, `git show <that>:plan/<slug>/` still works, and so does `<removal>^`.
- D4 — **Stage 8 — Record**, after Stage 7: `glab:developer` writes the spec from the folder and changes nothing inside it (so it writes no `result.md`); at full tier one `glab:reviewer` pass on the spec diff alone — that is what "checked by independent readers" now means; `glab:committer` removes the folder with `git rm -r` in the same docs commit; the commit goes out through `/glab:push` on its own go-ahead. This gives `sync-local-edits/follow-ups.md` #10 its stage, owner and place, and avoids both reasons it was cut (the record is in the developer's own contract; it never overwrites `result.md`).
- D5 — **Installer wording** (P1): specs in `docs/specs/` unless the repo's `AGENTS.md` names another place; a repo whose `AGENTS.md` keeps its plans records the spec and removes nothing; never remove an untracked plan file, nor a folder that was never committed; a folder from before the repo followed the rule stays until a change of its own migrates it.
- D6 — **The offline run and the live-run procedure live in `external-agents.md`**, sections *Offline run* and *Live runs*, their blocks copied byte for byte from `plan-r3.md` and `probe-r3/runner.sh` (`check.sh` section 7). The runner stays a block the user saves and runs as a script, not a tracked file: an executable that calls a real model would sit in the tree with no gate over it.
- D7 — **The live-run exception keeps the user's words; only two citations change** (R2c). "that plan" pointed at `plan-r3.md`, which is removed, so it becomes the spec section; `probe-r3.md` gains the place it can now be read. Every other word, and the tense, is the user's.
  - Before (the user's approved text): "The one exception is a live run with the user's own key: the live probe in that plan, or a later one recorded the same way. … Each run's record goes under `plan/`, as `probe-r3.md` does, and its transcripts are scanned for secrets, and host values masked, before they are committed."
  - After: "The one exception is a live run with the user's own key: the live probe in `docs/specs/external-agents.md` *Live runs*, or a later one recorded the same way. … Each run's record goes under `plan/`, as `probe-r3.md` (`docs/specs/external-agents.md` *Live runs*) did, and its transcripts are scanned for secrets, and host values masked, before they are committed." ("does" → "did" is the user's own change, U8.)
  - The rule's first sentence, which is not the user's new text, changes its own citation: "the offline run in `plan/feature-opencode-worker/plan-r3.md` *After*" → "the offline run in `docs/specs/external-agents.md` *Offline run*".
- D8 — **Payload cites the spec, named with its repository**, never a `plan/` path or a commit of this repo: an installer can follow neither, and the spec is one place that stays current.
- D9 — **`glab` 0.4.2 → 0.5.0**: a new pipeline stage, and an installed workflow now removes finished plan folders by default — a feature, not a fix. **`memory-sync` stays 0.1.0**: nothing under `plugins/memory-sync/` changes (`check.sh` section 9 prints `memory-sync-changes=0`).
- D10 — **A spec is not one of the *One fact* files.** It states a fact as of its last record and names the file that owns it; the record brings it up to date after the push, which the same-commit rule could never allow. `AGENTS.md` says so in the new `plan/` rule.
- D11 — **Closed items migrate too**, under `## Closed follow-ups` with their evidence: "none lost" then holds for every item the records list, and the reader sees why each closed.
- D12 — **The seven folders are removed only after `6838133` is on `origin`** (B2), because the rule this change adds removes a folder only after its push has landed. That now holds: the user approved the push, and `origin/main` = `6838133` (the manager's report; B2 re-checks it).
- D13 — **This change removes folders with the 0.4.2 contracts** the session's agents run: the developer deletes only tracked files after a guard, and the committer stages `git add plan/<slug>` by explicit path (proven, `findings.md`). The 0.5.0 committer paragraph is for later changes.
- D14 — **Commit split** (*Commits*): `AGENTS.md`, `README.md` and the payload go in one commit, because the lifecycle rule is stated in all three (*One fact*) and the committer cannot split one file's hunks without interactive staging.
- D15 — **The specs written in C1 describe the areas as of `6838133`**, before this change's own payload edits, and list `[sync-local-edits/follow-ups.md 10]` and `[fix-probe-findings/plan.md follow-up-1]` under *Open follow-ups* "→ `feature-docs-specs`". X1, after the push, brings `workflow.md`, `marketplace.md` and `external-agents.md` current and closes those two — the rule applied to the change that introduces it.
- D16 — **An audit file is a working file** too (P11): its still-open items go into the area spec when the change that acts on it is recorded, and that record commit removes it.
- D17 — **Stage 4 (Integrate) is skipped:** prose, comments and hook text only. The one runtime surface, the hook's output, is run in A4. The offline run of the external agents is not needed: `external-agent.sh` changes in comments only.
- D18 — **Development split:** S (specs, `docs/`), P (payload, `plugins/glab/`) and R (`README.md`, `AGENTS.md`) touch disjoint files and depend only on the fixed heading names, so they may run in parallel; M runs after S has finished, because S reads the folders M removes.
- D19 — **The migration takes two commits, C1 (specs) and C3 (removal),** where the rule's own record is one: the seven are the "change of its own" P1 names for folders from before the rule, C1 does not wait on B2 while C3 does, and reverting C3 alone brings the folders back without losing the specs.
- D20 — **Q1 = C** (keep the notes in place) is not built by this plan: it needs an amendment that exempts `plan/feature-opencode-worker/notes/` from M1 and from `check.sh` section 1. The user answered A.
- D21 — **X1's developer result goes to `$TMPDIR/feature-docs-specs-record-result.md`**, named in its dispatch, which overrides `developer.md` Step 5 for that run: this session's agents are 0.4.2, whose Step 5 always writes `plan/<slug>/result.md`, and a file written there would leave the folder dirty (X3's guard stops) or be removed unread. The manager reads it, cites it in the chat handoff, and deletes it after C5. In the payload, the record writes no `result.md` at all (P7): its output is the spec diff, and its report is the reply.
- D22 — **A model choice "for this task" ends with the task's record**, not its push (P2, `manager/SKILL.md:126`): Stage 8 dispatches the developer and, at full tier, the reviewer after the push, and the user's choice should cover them. A task with no plan folder still ends with its push. Only `:126` states the duration: `develop.md`, `review.md`, `ship.md` and the `glab:external-agents` skill do not (`findings.md`), so the *One fact* rule for the manual model rule needs no other file.
- D23 — **What counts as an open item and as a decision is a fixed list**, taken from the records at `6838133` and written into `check.sh`: 134 item tags; one tag per open-items section of every record file (heading matching follow-up, not done, unverified, not verified, open, not in this plan, later, deferred, out of scope, known, not questions or risk — 52 sections), placed under the folder's *Records* with where each of its items went; and the decision ids of nine sources, U-, V- and S-lists and numbered lists included. `feature-plugin-marketplace/plan.md`'s **D1–D9 and **M1–M7 are its slice steps ("## Slice M — moves", "**D1** — the marketplace. New file (Q1)."); that change's decisions are its `questions.md`: the user's binding D1–D4 and S1–S5 in its *Answered* table (`:7-19`), and Q1–Q7, all tagged. `fix-probe-findings/plan.md` numbers its user and manager decisions 1–6 and its follow-ups 1–4, so they are tagged `decision-<n>` and `follow-up-<n>`.
- D25 — **Landing is checked by content, not ancestry** (U7, B1): Stage 8 starts when `<remote>/<default>` holds the folder and `git diff --quiet <remote>/<default> -- plan/<slug>/` exits 0, and it names `git log -1 --format=%h <remote>/<default> -- plan/<slug>/`, verified with `git merge-base --is-ancestor`. A squash leaves the branch commits off the default branch but the folder on it; the named commit is then the squash commit. Proven in a throwaway repo (`findings.md`, *Amendment — review round 1/3*). The default branch is what `git symbolic-ref --short refs/remotes/<remote>/HEAD` prints; nothing printed → ask.
- D26 — **An audit file stays where `glab:audit` puts it** (B4), directly under `plan/`: moving audits into slug folders would change `glab:audit`'s naming for every installer. Instead the plan's `## Record` names it, Stage 8 hands it to the developer and the analyzer as a source, and the committer removes it under its guards.
- D27 — **The record check is `glab:analyzer`, at every tier, before any removal** (B6), with the folder's tracked files as its contract; one fix round, then the analyzer again (that is what checks the fix); still `DIVERGES` → the user. The full-tier reviewer pass stays, on the spec diff alone.
- D28 — **A pre-rule folder is one whose `plan.md` has no `## Record`** (A8): testable with `grep`, and every plan written under the new `glab:plan-first` Step 3 has one. A waiver's folder has no `plan.md` and is recorded.
- D29 — **`plugin.json`'s `description` gains "record"**: it lists the pipeline's stages, and installers read it in `/plugin`; no version change beyond 0.5.0, which this change already raises.
- D30 — **The L1a *Expected* edits in `external-agents.md` are allowed** (the Stage 3 finding): each drops a citation of a removed file ("(*Before* step 2)"), renames a step the spec merged ("Only then L1b" → "Only then the runner"), or carries a fact `probe-r3.md` *How it was run* records (a browser login is not a Go key; `/connect`). The two blocks stay byte for byte (`check.sh` section 7).
- D31 — **One commit for C2 stays** (A12): the lifecycle rule is one fact across the payload, `README.md` and `AGENTS.md`.
- D32 — **Tags are matched as items** (`check.sh`): only a line that starts with `- [tag]`, indented or not, counts, so "the same item as `[tag]`" inside another item is a cross-reference; and no tag may be both under *Open* and *Closed follow-ups* (S-A4). Two new kinds: **C** (closed only) and **I** (*Incidents*).
- D33 — **The Stage 6 "commit `plan/{slug}/`" change of round 1 (B2) is cut**, with `ship.md`'s exception: nothing in the payload needs plan files in git once `glab` removes nothing — the record reads the folder from disk. Whether plan files are committed is the repo's convention; this repo's `AGENTS.md` says they are, and the manager names them at Stage 6 as it did before this change.
- D34 — **`committer.md`, `commit.md`, `push.md` and `ship.md` go back to `6838133`**: after the cut no text in them is about the record, and the record commit is an ordinary docs commit. `AGENTS.md`'s lifecycle *One fact* entry drops them.
- D35 — **The record check ends in the analyzer's existing verdicts** (advisory 5): `CONFORMS`, or `DIVERGES: <n> steps` with each missing item counted as one step, so `analyzer.md`'s verdict list stays one list.
- D36 — **The record is an ordinary docs change**, through the normal commit and push stages, and a decision made at Stage 8 goes in the dispatch and the spec, not in `plan.md` (advisories 6 and 7): the folder is the record's source and does not change.
- D25, D26 (removal of the audit file) and the removal, restore and default-branch parts of D27–D28 are superseded by U10 and U11; the record check (D27) and the pre-rule test (D28) stay.
- D24 — **`check.sh` has two modes:** `STAGE=build` (After A3: the D15 tags open) and `STAGE=record` with `LAST=<sha>` (X5: they are closed, `plan/feature-docs-specs/` is gone and `workflow.md` records it). In the record mode it runs from history, because X3 removes it from the tree.

## Spec rules — for S1–S4

Every spec carries these second-level headings, exactly, once each, in this
order (`check.sh` section 6):

```
# <Area> — spec
<one paragraph: what the area covers, which files own it>
## How it works now
## Decisions that still bind
## Known limits and not verified
## Open follow-ups
## Closed follow-ups
## Incidents
## Records
```

`external-agents.md` adds, after *How it works now*: `## Isolation`,
`## Measurements`, `## Allowlist`, `## Profiles`; and after *Known limits and
not verified*: `## Offline run`, `## Live runs`.

- **Tags.** Each item from a record starts with its tag: `- [<slug>/<file> <id>] <what> — <status, evidence or next step>`. The ids are those of `findings.md`; the full list is the heredoc of `check.sh` section 4 (186 lines: spec, kind, tag). The kind says the heading the tagged line must sit under: **F** *Open follow-ups* or *Closed follow-ups*; **K** *Known limits and not verified*; **D** *Decisions that still bind*; **R** *Records*; **X** *Open follow-ups* now, *Closed follow-ups* after X1 (D15). A tag may appear again elsewhere; one occurrence must be under its heading. Where one item is the same as another (`fix-probe-findings/plan.md follow-up-3` = `feature-opencode-worker/probe-r3.md 2`, `follow-up-2` = `probe-r3.md 4`), each keeps its tag and says so.
- **Open-items sections** (kind R, `L<line>` ids, D23): under the folder's *Records* entry, one line per section — `- [<slug>/<file> L<n>] <heading> → <where each of its items went: their tags, or "nothing open">`.
- **Decisions.** Each binding decision is a bullet `- [<slug>/<file> <id>] <the decision, one line>` under *Decisions that still bind*. Each id of the nine lists in `check.sh` section 5 that no longer binds goes on that source's one line, in the same section: `- [<slug>/<file> spent] D3, D7, M1, … — <why>`. Ids are written singly, never as ranges. Unnumbered decision sections carry the tag `[<slug>/<file> decisions]`.
- **Records.** One bullet per migrated folder, under *Records*: `- <date> · <slug> · <one-line summary> · change <shas> · records <shas> · plan: \`git ls-tree -r --name-only <last> -- plan/<slug>/\` (one file: \`git show <last>:plan/<slug>/<file>\`)`, with the shas of `findings.md`'s table. `<last>` is the "last commit holding it" column. Its section lines follow it.
- **Incidents** go under *Incidents*, moved from the records, not summarised away (`AGENTS.md` *Comments and recorded incidents are kept*).
- **Citations.** A removed file is cited only as `git show <sha>:plan/<slug>/<file>`, a removed folder as `git ls-tree -r --name-only <sha> -- plan/<slug>/` (read-only, U11; never `git restore`); no bare `plan/<seven slugs>/…` path (`check.sh` section 2).
- **No host values** (`AGENTS.md` *No secrets*): `$TMPDIR`, never the host's temp path, outside the copied blocks; `<service-port>`, `<host-lan-ip>` as the probe record masked them. The copied blocks stay byte for byte, `/usr/bin/grep` in the offline block included.
- **Blocks.** Four-backtick fences: a ````` ````bash ````` line, the block, a ````` ```` ````` line. Each block comes before any `###` heading of its section.
- **Facts owned elsewhere** (the allowlist and its end dates, exit codes, limits): stated as of the record, with the owning file named (D10).

### S1 — `docs/specs/marketplace.md`

Sources: `feature-plugin-marketplace/` (all eight files), `bug-reviewer-findings/questions.md` Q1, Q4, Q5, Q8 and `follow-ups.md` 15, 17, 20, 21, `plan.md` A4's host-file bullet; `AGENTS.md`, `README.md`, `host.example.md` as they are at `6838133`.

- *How it works now* — `glab-services` and its two plugins; `source` paths; versions and the bump rule; install is the user's step; `--plugin-dir ./plugins`, never the root; every `claude` command under a throwaway `CLAUDE_CONFIG_DIR`; the two gate blocks and what each line guards (pointing at `AGENTS.md`, not restating the blocks); prefixed names in payload text, bare frontmatter `name:`; `host.example.md` → `~/.claude/host.md`; `plan/` as the repo's records, as of `6838133`.
- *Decisions* — the questions above, tagged; the user's binding *Answered* table of `feature-plugin-marketplace/questions.md` (`:7-19`), D1–D4 and S1–S5, each as `[feature-plugin-marketplace/questions.md <id>]` or on its spent line (`check.sh` section 5). The marketplace plan's own "D" and "M" ids are slice steps (D23).
- *Known limits* — `[feature-plugin-marketplace/plan.md unverified]`, `[feature-plugin-marketplace/result-slice-G.md unverified]`, `[feature-plugin-marketplace/plan.md smoke-test-1]` (part 1, prefixed names and the hook in a live session, not run).
- *Open / Closed follow-ups* — the marketplace tags of the `check.sh` heredoc, statuses from `findings.md`.
- *Incidents* — pointed at, not copied (S-A2): the `/tmp` tmpfs under a per-user quota whose exhaustion (`EDQUOT`) killed a session (`host.example.md`), and the ugrep function that returned nothing for a pattern with a leading alternation (`glab:bootstrap` step 6) — the line names both, with those words; `--plugin-dir .` loads no plugin; a `:` in an agent's `name:` stops it loading; validation passes a wrong marketplace name.
- *Records* — `bug-reviewer-findings` is recorded in `memory-sync.md` (its primary), and named here in one line pointing there; `feature-plugin-marketplace` here.

### S2 — `docs/specs/workflow.md`

Sources: `sync-local-edits/` (all three), `feature-model-switch/` (both), `bug-reviewer-findings/questions.md` Q3, Q7, Q10 and `follow-ups.md` 16, 18, 19, `result-review1-prose.md`, `result-slice3-4.md`; the payload under `plugins/glab/` at `6838133`.

- *How it works now* — the pipeline and the tier table (*Pick the tier*), Rules 0–6 in one line each, the agents and commands, the round caps, the model rule (`feature-model-switch/plan.md` *Spec entry*), the plan files and the "Spec" row as they are at `6838133`.
- *Decisions* — `[feature-model-switch/plan.md D<n>]`, `[sync-local-edits/result-followups.md D<n>]`, `[sync-local-edits/result.md M<n>]` and `[sync-local-edits/result.md P1]` (the port's merge decisions, `:51-66`; or their spent line), `[sync-local-edits/result.md decisions]` (its second `## Decisions`, `:230-232`), `[feature-model-switch/result.md decisions]`, the three questions.
- *Known limits* — `[feature-model-switch/plan.md I1]`, `[feature-model-switch/plan.md I4]`; that a squash-merging repo may lose the commit a spec names (`findings.md` *Inferred*), stated as unverified.
- *Open / Closed* — `sync-local-edits/follow-ups.md` 1–19 (10 under *Open*, "→ `feature-docs-specs`", D15), `bug-reviewer-findings/follow-ups.md` 16, 18, 19.
- *Incidents* — why #7 and #10 were reopened (the review's scope cut); the Stage 1b case and the 40-of-45 post-condition already told in `glab:manager` (pointed at, not copied).
- *Records* — `sync-local-edits`, `feature-model-switch`.

### S3 — `docs/specs/memory-sync.md`

Sources: `bug-reviewer-findings/` (all ten; `memory-sync.test.sh` there is a planning copy — cite it, do not copy it), `feature-plugin-marketplace/questions.md` Q2–Q5, `result-slice-D.md` 1, 2, 4, `result-slice-S.md` 2, 3, `plan.md` *Smoke test* parts 2–3; `plugins/memory-sync/` and `tests/memory-sync.test.sh` at `6838133`.

- *How it works now* — modes, hook events and timeouts, the 12 s default and 17 s cap and why, stage and stamps in the config dir, the `SessionEnd` 1.5 s budget and its hedged override, delete and tombstones not done; each with its owning file.
- *Decisions* — the questions, tagged.
- *Known limits* — `[bug-reviewer-findings/plan.md A4]`, `[bug-reviewer-findings/plan.md B4]` (its UNVERIFIED list, `~` expanded in a hook command among them), *Before adopting* and *Unverified throughout*; no real backend ever contacted; the hedge; smoke test parts 2 and 3 not run (`smoke-test-2`, `smoke-test-3`): copy part 3's three runs and its reading table from `git show b853635:plan/feature-plugin-marketplace/plan.md`, with `"${TMPDIR:?}"` in place of the host's temp path.
- *Open / Closed* — `bug-reviewer-findings/follow-ups.md` 1–14, the slice items, and four items no `follow-ups.md` carried: `[bug-reviewer-findings/plan.md memory-index]` (`delete` does not update a project's `MEMORY.md` index, `plan.md:1325`), `[bug-reviewer-findings/plan.md pull-race]` (the pull race of findings A6 never reproduced; T18 proves only the lock, `:1326-1328`), `[bug-reviewer-findings/result-slice1.md nested-delete]` and `[bug-reviewer-findings/result-review1-script.md nested-delete]` (`delete` accepts nested paths under `memory/`, `result-slice1.md:247`, `result-review1-script.md:240`).
- *Incidents* — those the script's own comments carry are pointed at, not copied; and `[bug-reviewer-findings/findings.md pkill]` (S-B1): cleaning up an experiment, the planner ran `pkill -u <me> -f 'sleep 30'`, which matched its own shell (exit 144) and may have matched other processes of the user — the origin of `AGENTS.md` *Tests clean up by PID* (`findings.md` §8, `:371-375` at `6838133`).
- *Records* — `bug-reviewer-findings`.

### S4 — `docs/specs/external-agents.md`

Sources: `feature-opencode-worker/` (`findings-r3.md`, `plan-r3.md`, `questions.md`, `questions-r3.md`, `follow-ups.md`, `probe-r3.md`, `integration-r3.md`, `result-r3.md`; rev 2's `findings.md` and `plan.md` for their decisions), `fix-external-report-lines/`, `fix-probe-findings/`; the script, skill, profiles and test at `6838133`.

- *How it works now* — the reviewer's whole verdict set, as `glab:reviewer` gives it — `SHIP`, `SHIP WITH SCOPE CUT: <what>`, `BLOCK: <n> issues` (`BLOCK: 1 issue` for one), `BLOCK: target unresolved`, `DO NOT PUBLISH: <why>` (S-A5); the five commands, the roles, the output contract, exit codes and state directory (named in the script header, which owns them); the manual-only rule; read-only; the external reviewer of Rule 5. From `plan-r3.md` *Spec entry*.
- *Isolation* — the copy, read-only binds, `$HOME`, network, limits, the key — the script header's list, each with its reason.
- *Measurements* — what the script comments cite (`findings.md`, `findings-r3.md`), and a bullet for findings-r3's C2, which *Isolation* cites (S-A3): with the real repository's config naming a program for `core.fsmonitor`, plumbing alone ran it on the host until every git call got `-c core.fsmonitor=false`; `2.0.31` reads only `~/.config/opencode` from `$HOME`; a turn ran at `1 GiB` and aborted at `256 MiB`; 128 tasks ran, 64 aborted; `1.19.3` read `auth.json` and `OPENCODE_AUTH_CONTENT`; `OPENCODE_API_KEY` also unlocks the paid provider; bwrap `0.11.1` nests the sandbox's user namespace; and rev 2's P4 (`git show 51043c4:plan/feature-opencode-worker/findings.md`, *Proven* P4), re-proven on 2.0.31: a project `opencode.json` or `.opencode/` merges into the agent unless `OPENCODE_DISABLE_PROJECT_CONFIG` is set (`check.sh` section 11 looks for each value under *Measurements*).
- *Allowlist* — the seven ids and their profiles and end dates as of the record, owned by `opencode_models()`; the source page and the date read; `[feature-opencode-worker/questions.md Q1]` — `Grok` refused for its `30 days` of retention; DeepSeek's region refusal (probe finding 3).
- *Profiles* — what a profile is, that only *Before* and *After the contract* are sent, where each was tuned from; the notes per Q1 (A: `git show 51043c4:plan/feature-opencode-worker/notes/<file>` for each of the five; B: their new path); follow-up 12.
- *Decisions* — `[feature-opencode-worker/questions.md Q1]`, `[feature-opencode-worker/questions-r3.md Q2]` (A); the user's binding U-lists — `findings.md` U1–U6 (`:25-46`), `plan.md` U1–U6 (`:22-31`), `plan-r3.md` U1–U12 (`:28-58`) — each U carried, since they are the user's own; `plan-r3.md` V1–V8, "Required by the review of rev 2 (binding)" (`:60-73`), each carried; `findings.md` D1–D16, `plan.md` D1–D21, M1–M17, `plan-r3.md` D22–D41, M1–M5, `fix-external-report-lines/plan.md` D1–D6, `fix-probe-findings/plan.md` decision-1 to decision-6 and D1–D5 — each carried or on its source's spent line (`check.sh` section 5).
- *Known limits* — `[feature-opencode-worker/plan-r3.md unverified]`, `[feature-opencode-worker/findings-r3.md unverified]`, `[feature-opencode-worker/findings.md unverified]`, `[feature-opencode-worker/probe-r3.md not-verified]`, `[fix-external-report-lines/result.md unverified]`.
- *Offline run* — the paragraph before the block in `plan-r3.md` *Integrate — the real CLI, offline*, then its ````bash block byte for byte, then its *Recorded* output and *Expected* text (exit codes as recorded on 2026-10-17).
- *Live runs* — the rule (`AGENTS.md` *Rules*, cited, not restated); the L1a block byte for byte (first ````bash block of the section) with its *Expected* text, the test line now ending `PASS 49/49`, and the edits D30 allows; the runner, `probe-r3/runner.sh` byte for byte (second ````bash block), saved to a file under `$TMPDIR` and run with `MODEL=… bash <file>` from the repo root, one model at a time; what the runner adds to L1b and L1c (transcript copy, the one exit-8 correction); the expectations corrected by probe finding 2 (the `send` quotes the line the script sends, not the brief); how a run is recorded (`AGENTS.md`'s wording: under `plan/<slug>/`, transcripts scanned, host values masked). Then `### 2026-10-17 — L1`: the results table, isolation as seen, the differences between models, findings 1–6 tagged, the transcripts at `git ls-tree -r --name-only 51043c4 -- plan/feature-opencode-worker/probe-r3/<model>/`.
- *Open / Closed* — `[feature-opencode-worker/probe-r3.md 2]` and `[fix-probe-findings/plan.md follow-up-3]` under *Closed* only, "closed: corrected in *Live runs*" (S-A4, kind C); `feature-opencode-worker/follow-ups.md` 1–25, `plan-r3.md` *Not in this plan* 1–5, `probe-r3.md` 1–6, `fix-probe-findings/plan.md` follow-up-1 to follow-up-4 (follow-up-1 under *Open*, "→ `feature-docs-specs`", D15), `fix-probe-findings/result.md` E49.
- *Incidents* — follow-up 1 (a pasted block closes the shell; why runs are scripts), follow-up 24 (one unexplained 1-of-47 failure under load), rev 2's `external-worker` build archived and replaced by rev 3 (`git ls-tree -r --name-only 8cb2a92 -- plan/feature-opencode-worker/rev2-build/`), the probe findings.
- *Records* — `feature-opencode-worker`, `fix-external-report-lines`, `fix-probe-findings`.

## Milestone

Not a feature: nothing new runs. The milestone is that nothing broke and
everything moved — both *Gates* blocks green as in *After* A1–A2, and
`check.sh` (A3) printing no `FAIL` line.

## Before

- B1 — `git rev-parse --short HEAD` prints `6838133` (or a descendant made only of this change's commits), and `git status --short -uall` prints only `?? plan/SESSION-HANDOFF.md` and this folder.
- B2 — **Before C3 is committed**: `git fetch origin && git merge-base --is-ancestor 6838133 origin/main; echo "rc=$?"` prints `rc=0`. Expected to hold already: the user approved the push of `51043c4..6838133`, and the manager reports `origin/main` = `6838133`. `rc=1` → C3 waits (D12).
- B3 — `export TMPDIR=/data/tmp/claude` (the host's temp directory) and `export CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`; both *Gates* blocks green at base, as `findings.md` records.
- B4 — Q1 answered in `questions.md`.
- B5 — `glab` is `0.4.2`: `jq -r .version plugins/glab/.claude-plugin/plugin.json`.

## Processing

### Slice S — the specs (`docs/specs/` only)

S1–S4 as *Spec rules* gives them. Verification: `check.sh` sections 3–7
and 12 print `ok` for the four files; no other path changes.

### Slice P — the payload (`plugins/glab/` only)

Text in quotes is inserted as written.

- **P1 — `skills/plan-first/SKILL.md`.**
  - `:3` description: "Writes findings, decisions, and a plan to plan/{slug}/ and only then implements, builds, and tests." → "Writes findings, decisions, and a plan to plan/{slug}/, only then implements, builds, and tests, and once the change is pushed records it in the area spec under docs/specs/."
  - Step 1, after the *Scope* bullet (`:25`): "- The spec of each area the change touches, read first — `docs/specs/<area>.md`, or where the repo's `AGENTS.md` puts specs. Its decisions still bind, its known limits still hold, and its open follow-ups may already describe this task."
  - Step 3: the last bullet (`:72`) "- why the other candidate boundaries were rejected." ends in ";" instead of "." (A11), and after it: "- `## Record` — the area spec or specs this change updates once it is pushed, any audit file under `plan/` it acts on, and what the entry will say. `glab:manager` Stage 8 runs it (*Plan files are working files*)."
  - `:109`: "… and stays there." → "… and stays there until the change is recorded, when each one still open moves into the area spec."
  - `:154` replaced by: "**Plan files are working files; the spec is what stays.** Once the change is pushed, `glab:manager` Stage 8 records it: a docs change updates the spec of each area the change touched — how the area works now, the decisions that still bind, what is not verified, and every follow-up still open and every incident, each under its source file and number. Specs live in `docs/specs/`, one file per area, unless the repo's `AGENTS.md` names another place. The record never removes `plan/{slug}/` or an audit file: whether a recorded plan folder is then removed, and how, is the repo's own `AGENTS.md` decision. A plan folder whose `plan.md` has no `## Record` was written before the repo followed this rule, and Stage 8 does not record it."
  - *User Override*, after `:171`: "Its folder is recorded like a plan's (*Plan files are working files*)."
  - *Quick Reference*, a last row: "| Record | Spec entry | the area spec, after the push (`glab:manager` Stage 8) |".
- **P2 — `skills/manager/SKILL.md`.**
  - `:3` description: "→ commit → push" → "→ commit → push → record".
  - `:81`: "The developer writes `plan/{slug}/result.md`;" → "The developer writes `plan/{slug}/result.md`, except for the record (Stage 8);".
  - `:126` (Rule 5, D22): "\"For this task\" ends with that task's push;" → "\"For this task\" ends with that task's record (Stage 8), or with its push when it has no plan folder;".
  - Stage 6 (`:411`) is not changed (U10, D33).
  - Pipeline table, after `:175`: "| 8 | Record | `glab:developer` on the record, `glab:analyzer` on what it carried, then `/glab:commit` | the area spec | the record commit verified, then pushed on the user's go-ahead |".
  - Tier table: delete `:196` (`| Spec | …`); after `:197` (`| 6–7 Commit, push | …`): "| 8 Record | — | after the push: the area spec updated and `glab:analyzer`'s check that every follow-up, decision and incident is carried, in one docs commit | the same, with one `glab:reviewer` pass on the spec diff alone |".
  - *When subagent dispatch is not available*, `:243`: "`<slug> review`." → "`<slug> review`, `<slug> record`."
  - Stage 7, after `:419`: "A change with a plan folder goes on to Stage 8."
  - A new section between Stage 7 and *What you never do*:

    ```
    ## Stage 8 — Record

    After Stage 7 has confirmed the push. What stays true moves into the spec of each area the change touched: `glab:plan-first` *Plan files are working files* is the rule, and `docs/specs/` the place unless the repo's `AGENTS.md` names another. The record changes the spec and nothing else. It never removes `plan/{slug}/` or an audit file: that is the repo's own `AGENTS.md` decision, carried out outside this stage. It is an ordinary docs change, through the normal commit and push.

    - Dispatch `glab:developer` for the record alone: the slug, the area specs the plan's `## Record` names (for a waiver, the ones you name), and any audit file it names as a source. It writes the spec from the folder's files and the audit file, carries every follow-up still open, every binding decision and every incident with its source file and number, and changes nothing inside the folder.
    - Dispatch `glab:analyzer` for the record check, at every tier: the spec diff against the folder's files and the audit file. `DIVERGES` goes back to the developer once, then to the analyzer again, which checks the fix; still `DIVERGES`: stop and tell the user.
    - At full tier, one `glab:reviewer` pass on the spec diff alone — the target and nothing else, as in Stage 5. Its findings go back to the developer once, and the analyzer checks that fix too.
    - Then `/glab:commit` with the spec files, and `/glab:push` on its own go-ahead.

    A decision made at this stage goes in the dispatch and in the spec, not in `plan.md`: the folder is the record's source and does not change. A plan folder whose `plan.md` has no `## Record` predates the rule and is not recorded here.
    ```

  - *What you never do*, a last bullet: "- Remove `plan/{slug}/` or an audit file as part of the record (Stage 8)."
- **P3 — `commands/plan.md:18`:** "Report the slug, the tier, the decisions made, any question for me, and where the plan is." → "Report the slug, the tier, the decisions made, any question for me, the area spec its `## Record` names (`glab:manager` Stage 8), and where the plan is."
- **P4 — `commands/commit.md`:** no change — as at `6838133` (U10, D34).
- **P5 — `commands/push.md`:** no change — as at `6838133` (U10, D34).
- **P6 — `agents/committer.md`:** no change — as at `6838133` (U10, D34): the record commit has no removal to guard.

- **P7 — `agents/developer.md`.**
  - `:38`: "… and stays there." → "… and stays there until the record moves it into the area spec."
  - `:99`: "`result.md` and `follow-ups.md` are the two files in that folder you do write." → "`result.md` and `follow-ups.md` are the two files in that folder you do write — and during the record, none."
  - Step 2, after `:26` ("**The plan is a closed list.** Every hunk you write maps to a named step. If it does not, it does not go in."): "A plan's `## Record` is not one of these steps: it is built only at Stage 8, when the dispatch says this is the record."
  - A new section after Step 5 (before *Rules you do not get to weigh*):

    ```
    ## The record — `glab:manager` Stage 8

    When the dispatch says this is the record, that is your whole scope. Update the area specs the dispatch names — those the plan's `## Record` names — as `glab:plan-first` *Plan files are working files* says, from the files of `plan/<slug>/` and any audit file the dispatch names: how the area works now, the decisions that still bind, what is not verified, and every follow-up still open, every binding decision and every incident, each with its source file and number. None is dropped. Change nothing inside `plan/<slug>/`, and remove nothing. Step 5 does not apply: write no `result.md`; your report is the reply alone, and `detail:` names the spec files. Step 3's gates run as for any change; where none reaches the spec files, say so in the report.
    ```

- **P8 — `agents/analyzer.md`,** Step 3, after the five-state list (`:40`): "A plan's `## Record` is not a step you measure: it runs after the push (`glab:manager` Stage 8), so its absence from the tree is not `missing`; the record check below is a separate dispatch." And a new section before `## Report` (B6):

    ```
    ## The record check — `glab:manager` Stage 8

    When the dispatch says this is the record check, your contract is not a plan's steps but the folder: every file of `plan/<slug>/` and any audit file the dispatch names. Against the spec diff, report each follow-up, open item, binding decision and incident they record as `carried` (cite the spec's `file:line`) or `missing`. A follow-up the records closed may be carried as closed. End with the verdicts of *Report*: `CONFORMS` when every item is carried, `DIVERGES: <n> steps` otherwise, each missing item counted as one step.
    ```
- **P9 — `skills/bootstrap/SKILL.md`.**
  - `:91` → "plan ⇄ analyze  →  develop ⇄ analyze  →  integrate  →  review ⇄  →  commit  →  push  →  record" (two spaces each side of every arrow, as now).
  - After the `commit`/`push` bullet (`:108-109`): "- **`record`** — after the push, what stays true goes into the area spec, in a docs commit of its own (`glab:manager` Stage 8); the plan folder stays unless the repo's `AGENTS.md` says otherwise."
  - Step 5, after the `plan/SESSION-HANDOFF.md` bullet (`:120`): "- the area specs — `docs/specs/`, or where `AGENTS.md` puts them: what a finished change left open is there, not in `plan/`".
- **P10 — `scripts/manager-bootstrap.sh:17`** (hook text): "commit -> push at full tier" → "commit -> push -> record at full tier". One fact with P9 (*session-start rules*).
- **P11 — `skills/audit/SKILL.md`,** *After Writing*, a fourth item (U10: the audit file is a source of the record, never removed by it): "4. When a change acts on the file, its plan's `## Record` names it, and that change's record (`glab:manager` Stage 8) carries what is still open into the area spec and `glab:analyzer` checks it was carried. The record never removes the file; whether it is removed afterwards is the repo's own `AGENTS.md` decision."
- **P12 — `scripts/external-agent.sh`,** comments only:
  - `:35` → two lines: "# Isolation, and why each part is there (docs/specs/external-agents.md in the" / "# glab-services/skills repository, *Isolation* and *Measurements*):".
  - The five `(findings-r3)` (`:55,96,209,226,540`) → `(spec, *Measurements*)`.
  - `:193`: "(plan/feature-opencode-worker/questions.md, Q1)" → "(docs/specs/external-agents.md, *Allowlist*)".
  - `:687`: "(plan/feature-opencode-worker/probe-r3.md, finding 1)" → "(docs/specs/external-agents.md, *Live runs*, finding 1)".
  - `:235`: "(findings P4, re-proven on 2.0.31)" → "(spec, *Measurements*, P4, re-proven on 2.0.31)" — rev 2's `findings.md` P4, which *Measurements* now carries (M6).
  - `:618` ("found in the prototype") unchanged.
  Verification: `grep -c '(findings-r3)'` → `0`; `grep -cF '(spec, *Measurements*'` → `6`; the first *Gates* block green.
- **P13 — the four family profiles, `## Notes` only.** In `kimi.md`, `glm.md`, `deepseek-pro.md`, `deepseek-flash.md`:
  - The *Source* bullet's two paths — Q1 = A: "the user's notes on prompting this family and their comparison table, kept in the history of the glab-services/skills repository (`docs/specs/external-agents.md`, *Profiles*)"; Q1 = B: `docs/notes/external-agents/<family>.md` and `docs/notes/external-agents/diff.md`.
  - The *UNVERIFIED* bullet's `(`plan/feature-opencode-worker/probe-r3/`)` → `(`docs/specs/external-agents.md`, *Live runs*)`.
  - Rewrap within the bullet only. Verification: `check.sh` section 8 — the prompt hashes unchanged.
- **P14 — `.claude-plugin/plugin.json`:** `"version": "0.4.2"` → `"version": "0.5.0"`; and in `description`, "review, commit and push through dedicated agents" → "review, commit, push and record through dedicated agents" (D29).
- **P15 — `commands/ship.md`:** no change — as at `6838133` (U10, D33).

### Slice R — `README.md` and `AGENTS.md`

- **R1 — `README.md`.**
  - a) After the paragraph ending `:15` ("… install either alone."): "Each change's working files — findings, plan, results — live in `plan/<slug>/`. Once the change has been pushed, the workflow records what stays true — how the area works, the decisions that still bind, what is open — in `docs/specs/<area>.md`, as a docs commit of its own. It never removes the plan folder: whether a repo does is that repo's `AGENTS.md` decision. A repo's `AGENTS.md` can also put specs elsewhere."
  - b) `:54`: "(`plan/feature-opencode-worker/probe-r3.md`)" → "(`docs/specs/external-agents.md`, *Live runs*)".
  - c) `:219`: "| `plan/` | Planning records |" → "| `plan/` | Working area: the files of changes in progress, removed once each change is recorded |", and after it "| `docs/specs/` | One spec per area: how it works now, why, what is not verified, what is open |".
- **R2 — `AGENTS.md`.**
  - a) *Layout*, `:16-17` → "- `docs/specs/` — one spec per area: how it works now, why, what is not verified, what is open (*Rules*, the `plan/` rule)." and "- `tests/`, `plan/` (the working area of changes in progress), `docs/`, `host.example.md`, `README.md` and this file belong to the repo and to neither plugin."
  - b) `:78`: "(`plan/feature-opencode-worker/probe-r3.md`)" → "(`docs/specs/external-agents.md` *Live runs*)".
  - c) `:106-111` replaced by (D7):

    ```
    - **Never run `external-agent.sh` against a real model from this repo.** Use
      the stub in `tests/external-agent.test.sh`, or the offline run in
      `docs/specs/external-agents.md` *Offline run*, whose sandbox has no network
      and whose key is a dummy in a throwaway home. The one exception is a live
      run with the user's own key: the live probe in
      `docs/specs/external-agents.md` *Live runs*, or a later one recorded the
      same way. It runs only when the user says so in chat for that run and
      names the models, after confirming that the console's "Use balance" is
      off. The user runs it, or the manager session does at that instruction,
      as a script, never pasted; no dispatched agent runs it. Each run's record
      goes under `plan/`, as `probe-r3.md` (`docs/specs/external-agents.md`
      *Live runs*) did, and its transcripts are scanned for secrets, and host
      values masked, before they are committed.
    ```

  - d) *One fact*: after "the "Use balance" warning (the skill, `README.md`" add ", and this file's live-run exception"; and before "the missing-`AGENTS.md` fallback, which the first message …" add: "the plan lifecycle — specs in `docs/specs/` unless `AGENTS.md` names another place, the record after the push, and that the record never removes the plan folder (`plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/commands/plan.md`, `plugins/glab/agents/developer.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/audit/SKILL.md`, `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`, and this file's `plan/` rule);".
  - e) `:187` ("`plan/` is tracked and permanent.") replaced by:

    ```
    - **`plan/` is the working area; `docs/specs/` is what stays.** A change's
      `plan/<slug>/` is committed with the change. After its push, the record
      (`glab:manager` Stage 8) updates the spec of each area it touched —
      `marketplace.md` (the marketplace, this repo's layout, gates and rules),
      `workflow.md` (the `glab` workflow), `memory-sync.md`,
      `external-agents.md`: how the area works now, the decisions that still
      bind, what is not verified, every follow-up — open or closed, each tagged
      `[<slug>/<file> <id>]` — and its incidents, moved into *Incidents* rather
      than dropped (*Comments and recorded incidents are kept*). A spec states a
      fact as of its last record and names the file that owns it, so it is not
      one of the *One fact* files. Once the change has landed on `origin/main`,
      the manager session — not a `glab` step — removes the folder by its exact
      path in a `docs(repo)` commit, after checking that it is tracked, clean
      (`git status --short -uall -- plan/<slug>/` prints nothing) and identical
      on `origin/main` (`git diff --quiet origin/main -- plan/<slug>/`); the
      spec's *Records* line names the last commit on `origin/main` that holds
      it. Read it back without touching the tree: one file
      `git show <sha>:plan/<slug>/<file>`, the list
      `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole folder
      `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`.
      No untracked file under `plan/` is removed; `plan/SESSION-HANDOFF.md` is
      never committed.
    ```

### Slice M — the migration (after S has finished)

- **M1 — remove the seven folders' tracked files** (D13), after B2 holds, one folder at a time:

  ```bash
  for d in bug-reviewer-findings feature-model-switch feature-opencode-worker feature-plugin-marketplace fix-external-report-lines fix-probe-findings sync-local-edits; do
    s=$(git status --short -uall -- "plan/$d"); n=$(git ls-files "plan/$d" | wc -l)
    if [ -n "$s" ]; then echo "STOP $d: $s"; break; fi
    git ls-files -z -- "plan/$d" | xargs -0 rm -f -- && find "plan/$d" -depth -type d -empty -delete
    echo "$d removed=$n left=$(find "plan/$d" 2>/dev/null | wc -l)"
  done
  ```

  Expected: seven lines, `removed=` 10, 2, 96, 8, 2, 3, 3, each `left=0` (the loop printed exactly this in the prototype copy, and `git add plan/<slug>` ×7 then staged `124 D`). A `STOP` line means a file there is untracked or modified: stop and report it. Under Q1 = B, before this loop: `mkdir -p docs/notes/external-agents && cp -p plan/feature-opencode-worker/notes/*.md docs/notes/external-agents/`.
  Verification: `check.sh` section 1.

## After

- **A1 — the first *Gates* block**, exactly as `AGENTS.md` gives it, with `TMPDIR` exported; paste everything. Green: five `rc=0`, shellcheck `rc=0`, every test line `ok`, `PASS 35/35`, `PASS 49/49`. (These cannot fail on prose; they guard the script comments and the hook text, and pass either way otherwise.)
- **A2 — the plugin *Gates* block**, exactly as `AGENTS.md` gives it, with `CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014` and its own throwaway `CLAUDE_CONFIG_DIR`. Green: as `findings.md` *Proven* lists — unchanged from base (no component added or removed).
- **A3 — `Q1=A STAGE=build bash plan/feature-docs-specs/check.sh`** from the repo root, `TMPDIR` exported, after M1 and before any commit — the deletions need not be staged: section 1 reads the working tree and accepts an index entry only as an unstaged deletion (D24). Green: no line starts with `FAIL`; seven `ok   removed <slug> (unstaged deletions: <n>)`; `tags 187/187 in place`; nine `ok   decisions` lines; `insertions 85/85 present`; every `ok   gone from …` line (34 at `STAGE=build`, 37 at `STAGE=record`); `ok   no folder cited with git show`; `ok   no git restore --source anywhere (U11)`; `ok   committer, commit, push, ship as at 6838133`; the marketplace *Incidents* lines for `EDQUOT` and `leading alternation`; *Measurements* has `core.fsmonitor`; *How it works now* has `` `BLOCK: target unresolved` ``; `ok   rules permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6`; `ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0`; the last line `info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: '…'`, where `…` is empty until this folder is committed and `feature-docs-specs ` after (an unstaged deletion is not counted). What each section can and cannot tell:
  - 1–5, 7–11 and 13 discriminate: each prints a `FAIL` naming the one folder, citation, tag (and the heading it was found under), decision id, heading, block, prompt, version, insertion, measurement or note that is missing or misplaced. Single faults of each kind were run on a finished prototype (`findings.md` *Proven*).
  - 6 discriminates a missing, doubled, extra, misordered or empty `## ` section; it cannot tell a thin section from a good one.
  - 10 finds each quoted insertion, not whether the prose around it is right.
  - 12's leak search is an **absence check**: silence does not prove that no other host value is in a spec.
  - Nothing here checks that `## Incidents` holds every incident, or that a migrated status is true: the reviewer and the reader judge that.
- **A4 — the hook's text:** `bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext | command grep -c -F -- '-> push -> record'` → `1` (`0` before P10).
- **A5 — nothing else changed:** `git diff --name-only 6838133 -- . ':!plan' ':!docs'` prints exactly, in this order: `AGENTS.md`, `README.md`, `plugins/glab/.claude-plugin/plugin.json`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/plan.md`, `plugins/glab/scripts/external-agent.sh`, `plugins/glab/scripts/manager-bootstrap.sh`, `plugins/glab/skills/audit/SKILL.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/external-agents/profiles/deepseek-flash.md`, `plugins/glab/skills/external-agents/profiles/deepseek-pro.md`, `plugins/glab/skills/external-agents/profiles/glm.md`, `plugins/glab/skills/external-agents/profiles/kimi.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md` — 16 paths (after the scope cut, `committer.md`, `commit.md`, `push.md` and `ship.md` are as at `6838133`). And `git ls-files -co --exclude-standard -- docs` prints exactly the four specs (plus the five notes under Q1 = B) — `git diff` would miss them while they are untracked. Both commands were run in the prototype copy and printed what they were given.
- **A6 — Stage 4 is skipped** (D17); say so at the handoff.
- **A7 — review** (Stage 5) gets the working tree as its target, as always.

### Commits

1. **C1** `docs(repo): add one spec per area, written from the plan records` — `docs/specs/*.md` (and `docs/notes/external-agents/*` under Q1 = B).
2. **C2** `feat(skills): record a finished change in its area spec and remove its plan folder after the push` — every `plugins/glab/` path of A5, `README.md`, `AGENTS.md`. Body: the Stage 8 rule and its payload files; payload record citations now point at the specs; `AGENTS.md` adopts the rule, rewrites the live-run exception in the user's wording, and repoints the C7 bullet; glab 0.5.0.
3. **C3** `docs(repo): remove the plan folders the specs now record` — the 124 deletions under the seven folders, staged with `git add plan/<slug>` per folder. Only after B2.
4. **C4** `docs(repo): add records for the docs specs` — `plan/feature-docs-specs/`.

Then `/glab:push` on the user's go-ahead.

## Record — this change's own, after the push (D15)

- **X0** — the repo rule's checks (`AGENTS.md`, the `plan/` rule; U10), run by the manager session: after `git fetch origin`, `git status --short -uall -- plan/feature-docs-specs/` prints nothing, `git diff --quiet origin/main -- plan/feature-docs-specs/` exits 0, and `LAST=$(git log -1 --format=%h origin/main -- plan/feature-docs-specs/)` is non-empty. Any one fails: stop and say which. `LAST` goes in the chat handoff; X1's *Records* line names it.
- **X1** — after X0: the developer, dispatched with these steps (this session's 0.4.2 agents do not yet carry Stage 8), and told to write its result to `$TMPDIR/feature-docs-specs-record-result.md` instead of `plan/feature-docs-specs/result.md` (D21), updates:
  - `workflow.md` — *How it works now*: Stage 8 and the lifecycle as P1–P11 left them; `[sync-local-edits/follow-ups.md 10]` moves to *Closed* ("closed by `feature-docs-specs`: Stage 8 names its stage, owner, place and readers"); *Decisions*: D3, D4, D5, D10, D16 as `[feature-docs-specs/plan.md D<n>]`; the rest of this plan's decisions on a spent line; *Records*: `feature-docs-specs`. And the two *Known limits* lines that go stale once this change lands (S-A6): the one saying plan-folder removal "no stage carries out" and the UNVERIFIED squash-merge line ("on a squash it may live only on the branch") — both replaced by what Stage 8 now does (D25).
  - `marketplace.md` — *How it works now*: `docs/specs/` and `plan/` as R2a and R2e left them, replacing the `plan/` bullet that ends "`feature-docs-specs` changes this rule" (S-A6); *Records*: `feature-docs-specs` (pointing at `workflow.md`).
  - `external-agents.md` — `[fix-probe-findings/plan.md follow-up-1]` moves to *Closed* ("closed by `feature-docs-specs`: `AGENTS.md`'s live-run exception, the user's wording").
  - every item of `plan/feature-docs-specs/follow-ups.md`, if one was written, tagged `[feature-docs-specs/follow-ups.md <n>]` in its spec.
  - The *Records* line, under `workflow.md` *Records*, names `$LAST` as `git ls-tree -r --name-only $LAST -- plan/feature-docs-specs/` (U11).
  - Nothing inside `plan/feature-docs-specs/` changes; the manager reads the result file, then deletes it after C5.
- **X1b** — `glab:analyzer`, the record check (D27): the spec diff against every file of `plan/feature-docs-specs/`. `DIVERGES` → X1 once more, then X1b again; still `DIVERGES` → the user. Nothing is removed before `CONFORMS`.
- **X2** — at full tier, one `glab:reviewer` pass on the diff of the three specs alone.
- **X3** — the removal, by the manager session under the repo rule (U10), not by a `glab` step: re-run X0's three checks, then `git rm -r -q -- plan/feature-docs-specs/`, then `git diff --staged --name-status` lists only `D` lines under `plan/feature-docs-specs/`; anything else, `git restore --staged` it and stop. If X0's clean check fails because a 0.4.2 developer wrote `plan/feature-docs-specs/result.md` after all, the manager appends that file's content to `$TMPDIR/feature-docs-specs-record-result.md`, puts the file back with `git checkout -- plan/feature-docs-specs/result.md`, and re-runs X0; any other dirty file: stop and bring it to the user. Then `/glab:commit` stages the three specs with the removal.
- **X4** — **C5** `docs(repo): record the docs specs change and remove its plan folder`. Then `/glab:push`, on its own go-ahead.
- **X5 — verification**, after X3 and again after C5. `check.sh` is no longer in the tree, so it runs from history: `Q1=A STAGE=record LAST=$LAST bash <(git show "$LAST:plan/feature-docs-specs/check.sh")` (`DEFAULT_REF` defaults to `origin/main`). Green: no `FAIL`, the record-stage *gone* lines (S-A6) included; eight `ok   removed` lines (`feature-docs-specs` included); `ok   record feature-docs-specs $LAST in workflow.md`; the two X tags now under *Closed follow-ups* (`tags 187/187 in place`); section 14 prints `in the tree and the index under plan/: ''`. Also `git status --short -- plan/SESSION-HANDOFF.md` → `?? plan/SESSION-HANDOFF.md`.

## Back-out

Git only; nothing outside the repo changes (no `~/.claude`, no install, no state).

- **Before the push:** `git revert --no-commit <C3> <C2> <C1>` (C4 kept or reverted with them), check `jq -r .version plugins/glab/.claude-plugin/plugin.json` prints `0.4.2` and `git ls-files plan | wc -l` prints `124` (plus this folder's files if C4 stays), then `git commit -m "fix(repo): withdraw the area specs"`. 0.4.2 is right here: no installed copy has seen 0.5.0. Dropping the local commits instead (`git reset`) is the user's call, not a step of this plan.
- **After the push:** the same revert, then `sed -i 's/^  "version": "0.4.2",$/  "version": "0.5.1",/' plugins/glab/.claude-plugin/plugin.json`, check it prints `0.5.1`, `git add` it, and commit `fix(skills): withdraw the record stage and restore the plan records` — an installed copy moves only on a new version string. `UNVERIFIED: that an installed 0.5.0 ignores a move back to 0.4.2 — inferred from the AGENTS.md version rule, as plan-r3 inferred it`.
- **After C5:** `git revert <C5>` brings back `plan/feature-docs-specs/` and the three spec edits.
- `revert` is not a commit type in `AGENTS.md`, hence `fix`.

## Coverage, as a list (`AGENTS.md` *Tests*)

- P12 (script comments): `tests/external-agent.test.sh` `PASS 49/49`, `bash -n`, shellcheck — they prove the script still parses and behaves; a comment cannot change behaviour, so they pass either way (regression guard, not discriminating).
- P10 (hook text): no test case covers the hook; A4 runs it and counts the new text, and `check.sh` section 10 finds it. Accepted: the hook has no test file, and its contract (exit 0, JSON on stdout) is checked by `bash -n` and shellcheck only.
- `memory-sync` unchanged: `PASS 35/35` is a regression guard that passes either way.
- Every other step is prose: A3 sections 1–13 as listed, and the review.

## Not in this plan

- Fixing any migrated follow-up other than `sync-local-edits/follow-ups.md` 10 and `fix-probe-findings/plan.md` 1, which this change closes by design.
- A Markdown gate (`bug-reviewer-findings/follow-ups.md` 20), a `docs/constants.md` for this repo, a spec index file.
- Re-tuning the profiles (FOW 12), DeepSeek's end date (2026-10-31), the smoke test.
- Migrating `plan/SESSION-HANDOFF.md`: it stays untracked.

## UNVERIFIED, in one place

- That an installed 0.5.0 runs Stage 8 as written — needs a session on an installed copy.
- That a squash-merging repo keeps the commit a spec names (`findings.md` *Inferred*).
- That every incident of the seven folders reached a spec, and that each migrated status is true: A3 checks tags and presence, not truth.
- That the payload texts read well: `check.sh` finds each insertion, nothing more.
- The back-out's version inference above.
