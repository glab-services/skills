# feature-external-developer: review, round 2/3

Two reviewers looked at the round-1 fixes on 2026-10-18. Each round-1 finding
was confirmed fixed by reproduction or mutation, except T4, which is half
done. Both still return BLOCK, 2 and 6 issues. The tests reviewer warns that
the guard is growing faster than it converges. The user chose **one last
minimal round** ("Last minimal round"), removing logic where possible. Review
round 3 must then end in SHIP, SHIP WITH SCOPE CUT or DO NOT PUBLISH.

## Findings and fixes

- **R2-1 (both reviewers).** The prescribed `git diff --no-ext-diff
  --no-textconv --ignore-submodules=all` runs clean filters and fsmonitor
  too; the reviewers reproduced it. The "Never run git status" reason
  misleads.
  - Fix: drop the `git diff` line in the skill and `develop.md`. The manager
    inspects only after `git: unchanged` and with no nested-repo refusal. It
    compares each path a `changed:` line names with
    `git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u - <path>`
    (cat-file applies no filter), reads untracked files directly, and runs
    neither `git status` nor `git diff` on the tree before that.
  - State plainly that both commands run filters.
- **R2-2.** A `find` without `-files0-from` (findutils < 4.9) fails silently,
  and the report then misses every tracked-file edit.
  - Fix: probe once at a developer `start` and in `check`
    (`printf '.\0' | find -files0-from - -maxdepth 0 -printf x`), and exit 4
    when it fails. Add a test with a stand-in old `find`. Name the
    requirement in the skill's Codex prerequisites.
- **R2-3.** A `.gitignore` the agent writes hides new files: `pkg/zz/.gitignore`
  holding `*` gives `changed: none`.
  - Fix: add the ignored entries to the state with `ls-files -z -o -i
    --exclude-standard --directory` (names only), so a new ignored entry is
    reported. Add a test.
  - The README and skill say the agent can make a path ignored itself.
- **R2-4 (T4 remainder).** Mutants `gone` and `nosymref` pass.
  - Fix: delete the pre-existing untracked file in `dev-edit` and expect
    `changed: -- u.txt`.
  - Fix: make `dev-switch` switch to an existing branch at the same commit.
  - Or name both as uncovered, with reasons.
- **R2-5.** The meaning of `--` is wrong for a tracked symlink or a file over
  16 MiB. Fix: word it exactly, in the header, the skill and README.
- **R2-6.** The AGENTS.md *One fact* refusal entry (2 at start, 4 later) is
  missing `README.md` and `glab:manager` Rule 5. Fix: add them.
- **R2-7.** The comment at test:1167 still says the report runs `git status`.
  Fix: amend it.
- **Advisory, taken.** `dev_refuse` with the top `/`: use `${t%/}`. SKILL:126
  "creates nothing" should say "creates no agent". Name a `.git` in an
  ignored dependency directory as a likely cause of exit 2.

## Assignment

- **Script developer:** R2-2 (probe and test), R2-3 (listing and test),
  R2-4, R2-5 (header), R2-7 and the `/` advisory.
- **Docs developer:**
  - R2-1, in the skill and `develop.md`;
  - R2-2 (the prerequisites);
  - R2-3 (the wording);
  - R2-5 (the skill and README);
  - R2-6;
  - the advisories.
- **Planner:** revision 4 records these fixes.
