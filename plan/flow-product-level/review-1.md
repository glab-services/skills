# flow-product-level — review round 1

Two reviewers, each read-only, given only the diff against HEAD. Their findings are copied verbatim below, followed by the manager's decisions. The fix round builds from this file.

## Reviewer A — correctness and gate safety (FIX: 7 findings)

1. plugins/glab/scripts/plan-gate.sh:73 — **medium** — `check` can be made to pass on a plan that differs from the accepted one. `find -type f` skips symlinks and does not descend into symlinked folders. After ACCEPTED r1 I added `02-evil/plan.md` as a symlink to other text, and `check` still printed `ACCEPTED r1 6ceb…` with rc=0. Fix: refuse any symlink in the plan tree (`find . -type l` prints anything → REFUSED), or hash with `find -L`. Add a test for it.
2. plan-gate.sh:205/228–234 and :172/187 — **medium** — the check for an existing file and the final `mv` are separate steps, so two runs at once both succeed. Two verdicts on r1: with a 1s `mktemp` stub, REJECTED and ACCEPTED both exited 0. `verdict.r1.md` ended up ACCEPTED and the REJECTED was lost silently, along with its count towards the cap. Two reports: both printed `report.r2.md` with rc=0. The second `mv` put its folder inside the first, as `plan.r2/.plan-gate.mZBx8y/`. After that `plan.r2/` hashes to `4f6f…` but the report says `4bc3…`, so the copy no longer matches the report. Fix: create each final name without overwriting — `ln "$TMP_FILE" final` then remove the temp, or `mv -n` followed by a check that it landed — and claim `plan.r$n/` with `mkdir` before copying into it.
3. plan-gate.sh:174–187 — **medium** — the copies are not readable by another account. The comment at :143 says files must be readable by the other level's user, but only the folder and the report get chmod'ed. Under `umask 077`, `plan.r1/master.md` and `plan.r1/plan.md` were `-rw-------` and `01-api/` was `drwx------`. A product session running as another user cannot audit the copy, and `verdict` refuses it as "copies do not match". Fix: `chmod -R a+rX "$TMP_DIR"` before the `mv`.
4. plugins/glab/skills/develop/SKILL.md:15 — **low** — this line says to record a decision under `## Decisions`, with no exception for after a report. Stage 1c (manager/SKILL.md:194) moves only lines that session-rules or the manager prescribe to `after-verdict.md`. A manager that follows develop literally edits a hashed file, its own next `check` refuses, and the plan goes back to product for no reason. Fix: add "after a report, into `after-verdict.md` (`glab:manager` Stage 1c)".
5. plugins/glab/skills/manager/SKILL.md:18–20 and product-manager/SKILL.md:18–20 — **low** — neither list names the level's own manager skill. session-rules says "invoke nothing that is not on it", but bootstrap step 2 reloads the manager after a compaction, so the two texts contradict each other. Fix: add `glab:manager` and `glab:product-manager` to their own lists.
6. plan-gate.sh:198 — **low** — `grep -qxE` matches line by line, so a project name `$'web\n../x'` passes validation. It is then refused only by accident ("no report to decide"). Fix: reject on `case $project in *[!a-z0-9-]*|'') usage`.
7. manager/SKILL.md:159 — **low** — a typo, "(Stage 1c) — — that file". Remove the duplicated dash.

The reviewer could not verify one case: a `waived.md` slug made from a brief skips the product check, because develop only runs `check` when `master.md` has a brief line. It is UNVERIFIED whether that is intended.

## Reviewer B — AGENTS.md conformance and repeated text (FIX: 12 findings)

1. `plugins/glab/skills/product-manager/SKILL.md:35` and `README.md:98` — *One fact, one value*: both state the 8192-byte rule-file limit, but AGENTS.md:312-313 names only `product-plan` and the test for it. Fix: add both files to that entry, or drop the number from the layout lines. **medium**
2. `plugins/glab/skills/develop/SKILL.md:17` and `plugins/glab/skills/product-project-plan-report/SKILL.md:11` — *One fact*: both restate the brief line, and AGENTS.md:301-305 names neither. Fix: point at `glab:plan` and manager checklist item 8, or add both files to the entry. **medium**
3. `plugins/glab/skills/product-manager/SKILL.md:49,53` — *One fact*: it states `SOUND`, `NO CONFLICT` and `CONFLICTS: <n>`, but is missing from the verdict-lines list at AGENTS.md:263-273. Fix: add it to the list. **low**
4. `plugins/glab/skills/product-project-plan-verdict/SKILL.md:20` — say it once: it repeats product-manager *The cap* (:95), from "both reasons" to the `user: "<words>"` reason line. Fix: keep the refusal text and the pointer only. **medium**
5. `README.md:148-154` — *One fact*: the start prompt and the worktree caveat are product-manager:69,71,82 word for word, and AGENTS.md has no entry for them. Fix: point at `glab:product-manager` *Starting project sessions*, or add an entry. **medium**
6. `plugins/glab/skills/session-rules/SKILL.md:132` says "what a stage does when its last round has not passed is in that stage", but the P1b row at product-manager:49 and product-plan-analyze:14 never say what follows `NOT SOUND` in the last round. Fix: add "→ the user". **medium**
7. `plugins/glab/skills/product-project-brief/SKILL.md:9` — say it once: it restates the approval-line form from product-manager:59. Fix: a pointer. **low**
8. `plugins/glab/skills/product-plan/SKILL.md:36` — say it once: "never changed outside an approved product plan" duplicates product-manager:61. Fix: keep it in one place. **low**
9. `plugins/glab/skills/product-manager/SKILL.md:22` restates the report-skill caveat of session-rules:10, and `session-rules/SKILL.md:18` and `develop/SKILL.md:17` restate the `after-verdict.md` redirect owned by manager Stage 1c. Fix: pointers only. **low**
10. `plugins/glab/skills/session-rules/SKILL.md:38` — Rule 0d lists seven agents while Rule 5 lists nine. Fix: add `glab:product-planner` and `glab:product-analyzer`. **low**
11. `plugins/glab/skills/manager/SKILL.md:159` — a doubled em dash, "(Stage 1c) — — that file". Fix: drop one. **low**
12. `README.md:135` — the walkthrough's `2>trace.txt` leaves a stray file in the repo root. Fix: write to `"$TMPDIR/trace.txt"`. **low**

The reviewer's advisory points, not counted:
- manager *What you never do* (:300-313) now restates `session-rules` Rules 0b, 1, 2 and 3. This is HEAD text, but it now sits two files away from those rules.
- `README.md:142` writes the version 0.14.0 out by hand, and no One-fact entry ties it to `plugin.json`.
- Commit hygiene: the only unrelated edit is the jq line in `plugins/glab/scripts/manager-bootstrap.sh:97-99`, reindented from spaces to tabs.

## Manager decisions (round 1)

- **A7 and B11 are one finding.**
- **A1.** `plan-gate.sh` refuses any symlink anywhere in the plan tree, with REFUSED and a reason, in `report`, `check` and `digest` alike. Do not follow links. Add a test that a symlinked file and a symlinked folder are each refused.
- **A2.**
  - Every final file is created without overwriting: a temp file, then `ln` to the final name. If that fails, refuse and remove the temp.
  - `plan.r<n>/` is claimed with `mkdir` before anything is copied into it. If that fails, refuse.
  - Add tests: two verdicts on one report → exactly one succeeds and the other is refused; two reports at once → one succeeds, the other is refused, and the winner's copy still hashes to its report.
- **A3.** `chmod -R a+rX` on the copy before it is moved into place. Add a test under `umask 077`.
- **A4.** Apply as its Fix says, as a pointer to `glab:manager` Stage 1c. It is merged with B9's redirect, so the redirect is stated once, in Stage 1c, with pointers elsewhere.
- **A5.** Each manager's list names its own manager skill.
- **A6.** Apply as its Fix says, with a test for a newline in the project name.
- **The waiver case (A's open point).** A slug made from a brief always needs the product check: develop runs `check` whenever `master.md` *or* `waived.md` names a brief. A user's waiver of planning is not a waiver of the product's verdict. Add a test.
- **B1–B10, B12.** Apply as each Fix says. Where a fix offers "add to the entry" or "a pointer", choose the pointer, per say-it-once, unless the fact must be read where it stands. Then add the entry.
- **The advisory points are fixed too:**
  - manager *What you never do* shrinks to pointers to `glab:session-rules`;
  - README stops stating the version by hand and points at `plugins/glab/.claude-plugin/plugin.json`;
  - the jq line reindent is reverted to HEAD's spaces.
### After part 1 of the fix round stopped on two PLAN WRONGs

- **A2, two reports at once.** `mkdir` is not exclusive on this host (uutils coreutils), so it cannot be the claim.
  - Every claim in `plan-gate.sh` (report number, verdict number, `plan.r<n>/`) is taken by an exclusive create done by bash itself: a claim file opened with `set -C` (noclobber, an `O_EXCL` open), whatever the coreutils.
  - Only the winner of the claim creates `plan.r<n>/` and the final files. A loser refuses and touches nothing the winner made.
  - The claim files are named so `digest` never hashes them, and the walkthrough's store listing still shows only the agreed files.
  - Add the two-reports test. It must pass 10 runs out of 10 on this host.
- **Advisory 3, the jq tabs, is rejected.** The tabs are the plan's own text (step A3), so it is not an unrelated edit. No change.
- **The byte-compare posts.** The posts that compare `plan-gate.sh` and `tests/plan-gate.test.sh` with the full text in `steps-1-scripts.md` no longer match. That is expected: this review round supersedes those two texts. The record and the final check read `review-1.md` and `result.md` for the scripts as they now stand. Do not edit the steps files.
- **The whole fix round:**
  - each rule ends with one owner and pointers elsewhere;
  - AGENTS.md *One fact* matches the tree;
  - no incident is lost;
  - `glab` stays 0.14.0;
  - `master.md` is never edited, and `sha256sum -c plan/flow-product-level/master.sha256` must still print OK;
  - every new test follows AGENTS.md *Tests*.
