# feature-external-developer: questions

The plan has no open questions. Its decisions come from the user's answers
recorded at `9108ac7:plan/feature-codex-agent/questions.md` (A4, Q1, Q3, Q4,
model, effort, login).

## Approval (the user, 2026-10-18)

- The user approved `plan.md` and the offline M5 run ("Approve both"). M5 is a
  real `start` inside `bwrap --unshare-net`, with a fake login in a throwaway
  `CODEX_HOME`/`HOME`, on a throwaway repo under `$TMPDIR`, and no model is
  reached. M1–M4 run under the standing `codex sandbox` allowance, also on a
  throwaway repo.
- Time budget: about an hour, kept small, as the user asked. Push waits for
  the user's go-ahead.
- Revision 2, written after Stage 1b round 1: the user approved the
  developer's new profile section, `## Developer, before the contract` in
  `profiles/default.md`, as quoted to them. They also asked for one more fix
  in this change: correct the README sentence that says no Codex agent has
  run against a real model, since the live probe L1 ran on 2026-10-18
  (`30f2c80`: read-only, Codex's default model).
- Correction to the record. The amendment of `default.md` L3-7 ("Only the
  two sections below are sent", now three) was not a user decision. It was a
  Stage 1b note that the manager passed to the developer as a suggestion,
  because the comment no longer matched its subject (`glab:comments`).

## Review round 1 (the user, 2026-10-18)

- Two reviewers returned BLOCK 6 and BLOCK 6 (`review-r1.md`); five of the
  findings are real security issues in the change report. The time budget
  was already past. The user chose **one fix round now**, for all of them, as
  summarised to them:
  - rewrite the report's snapshot without `git status`;
  - treat a nested `.git` as changed (refuse it at start, `git: changed`
    after a turn);
  - check `core.hooksPath`;
  - refuse a `TMPDIR` inside the repo;
  - put a time limit on hashing;
  - the docs and test fixes.

  Then review round 2. These fixes are approved as plan revision 3.

## Review round 2 (the user, 2026-10-18)

- Round 2 left 8 findings, recorded in `review-r2.md`. The reviewers warned
  that the guard is not converging. The user chose **one last minimal
  round**: remove logic where possible, then review round 3. Round 3 must
  end in SHIP, SHIP WITH SCOPE CUT or DO NOT PUBLISH. The fixes in
  `review-r2.md` are approved as plan revision 4.

## Review round 3 (the user, 2026-10-18)

- Both reviewers returned **SHIP WITH SCOPE CUT**, with the same cut:
  - drop the `need_find` call (and its comment) from `codex_check`, so that
    `check`, and with it every Codex role, does not fail on a `find` without
    `-files0-from`;
  - keep the probe on a developer `start`;
  - drop E83's `check` half;
  - remove "`check` and" in README L51 and SKILL L58.
- The user approved the cut **plus the inspection wording advisory**, in the
  skill and `develop.md`:
  - use `diff -u -- - <path>`;
  - never open a path that is a link or not a regular file; show a link with
    `readlink` and a special file with `ls -l`;
  - include each `!!` path.

  Then commit glab 0.7.0. The push waits for the user.
