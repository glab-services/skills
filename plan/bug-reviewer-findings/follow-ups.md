# Follow-ups — bug-reviewer-findings

Recorded by the manager on 2026-10-05, after review round 2 returned `SHIP` from
both reviewers. Everything here was found during this change and deliberately
left out of it. None is a blocker; the two marked **first** are the ones the
script reviewer said are worth doing before the script is relied on.

## `memory-sync.sh`

| # | What | Status |
|---|---|---|
| 1 | **first** — `pull`'s `rsync -a` copies the stage's directory modes and times onto `projects/`, each project directory and, through a kept symlink, a directory outside the tree. A tightened `projects/` is loosened on every pull. Suggested: `rsync -rt --omit-dir-times --update --keep-dirlinks`, plus a mode assertion in T26. | reproduced with the stub; real CLI modes unverified |
| 2 | **first** — the cap of 17 s leaves no margin under the 20 s hook timeout (a TERM-ignoring child ended at 19.0 s; stated worst case is 20 s, a tie with the kill). Suggested: cap 16, changed together in the script header and comment, T29 and `README.md`. | reproduced |
| 3 | Design: a machine holding an older copy uploads it whenever its size differs, and other machines then pull it. The pull-side guarantee is stated truthfully; the push side is stated nowhere in the script. Needs a compare-before-upload step or tombstones — a plan of its own. | reasoned, not reproduced; real CLI rule unverified |
| 4 | A `find` error on an unreadable root reads as "nothing changed", and nothing in the script says so. | left: the fix is a behaviour choice |
| 5 | The "worst case TIMEOUT + 3 s for any mode" claim does not hold after a backward clock step: the clamp bounds each call, not the run. Suggested: say so in the comment, or use a monotonic clock. | reasoned |
| 6 | `aws s3 rm` killed by a signal while budget remains is reported as "remote copy not removed"; the outcome is as unknown as on a timeout. Suggested: treat any exit above 128 in `delete` as "not confirmed". | reproduced |
| 7 | `--keep-dirlinks` applies at every level, not only to a symlinked `memory` directory: `pull` and `delete` act through any directory symlink already under `projects/`. The comment names only the `memory` case. | reproduced |
| 8 | No test for the "limit spent, command never started" branch: removing its `CUT_OFF=1` passes 35/35. | reproduced |
| 9 | An invalid `delete` path still creates `projects/` before it is rejected. | reproduced |
| 10 | `.memory-sync-pushed.next` is left behind when the stamp cannot be moved. Harmless. | reproduced |
| 11 | `push-if-changed` may not notice edits under a symlinked memory directory, because the change scan does not follow links. Documented in the skill as a "may". | not reproduced |
| 12 | A detached descendant of a killed transfer can outlive the script. It no longer holds the lock. | reasoned |
| 13 | The harness's stub guard does not fire when the stub exists but is not executable and no real `aws` is on the test `PATH`; the run then fails with exit 126 without reaching a backend. | reproduced on this host; the real-`aws` half unverified |
| 14 | Tombstones for deletes across machines (Q2's deferred half). | planned follow-up |

## Text

| # | What |
|---|---|
| 15 | `AGENTS.md` "One fact, one value" lists the default time limit but not the coupled maximum (17) and hook timeout (20). |
| 16 | `agents/reviewer.md:73` and `agents/integrator.md:39` fall back to "the scratchpad"; `CLAUDE.md` and `bootstrap` say "`$TMPDIR` if set, scratchpad otherwise". Same place in most sessions. |
| 17 | `AGENTS.md:42` names the placeholder as `<profile, or delete this key>`, which reads oddly outside the JSON example. |
| 18 | `agents/developer.md:15` still calls `CLAUDE.md` "the working agreement" in passing; `commands/commit.md:6` has two dashes in a row. Cosmetic. |
| 19 | `bootstrap`'s "leading alternation returns zero matches" grep hazard did not reproduce in three separate attempts. It is worded "has been observed". |
| 20 | No `.gitignore`; no markdown lint, so the 23 prose files have no gate. |
| 21 | `install.sh --check` to compare the repo against `~/.claude` (Q1's deferred half). |

## Before adopting this on a machine

Nothing in this change touched `~/.claude`. Before the live copies are replaced:

- Create `~/.claude/host.md` first. Without it the `/data/tmp/claude` rule lapses
  and sessions fall back to `$TMPDIR` or the scratchpad, which on the authoring
  host is the quota-limited `/tmp`.
- Check the configured `CLAUDE_MEMORY_S3_TIMEOUT`: values above 17 are now
  rejected and 12 is used. It was never read during this change.
- Check whether the configured `CLAUDE_MEMORY_S3_URI` ends in a slash: the script
  now strips it, which changes the keys read and written if it does.
- The live `PostToolUse` and `Stop` hook timeouts are 60 s; the example uses 20 s.

## Unverified throughout

No command in this change contacted a real S3 backend. Unverified: how
`aws s3 sync --delete` treats `--exclude`/`--include` filters; that `aws s3 rm`
of a missing key exits 0; that bucket versioning is on (the user's statement);
behaviour on bash 3.2 or macOS (out of scope by decision).
