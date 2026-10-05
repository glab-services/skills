# Result — bug-reviewer-findings, review round 1, script findings 1–14

Scope: `memory-sync.sh` and `tests/memory-sync.test.sh` only. `AGENTS.md` (now
present) was read first. These are review-forced changes outside `plan.md`;
nothing under `plan/` was edited except this file. Nothing committed, staged,
pushed, or copied into `~/.claude`; only the stub `aws` was ever run.

## Findings

Line numbers are in the tree as it now stands.

| # | state | where | covered by |
|---|---|---|---|
| 1 | fixed | `memory-sync.sh:288-298` — each copy removed and checked on its own; `delete ok` only when both are gone, otherwise one line naming the copy that stayed | T25 |
| 2 | fixed | `memory-sync.sh:247-249` — `--keep-dirlinks` on the pull rsync | T26 |
| 3 | fixed (wording only) + follow-up | `memory-sync.sh:5-7` header, `:243-246` comment — the guarantee is now "newer than the remote object's upload time". Design gap listed under Follow-ups | no test, as instructed |
| 4 | fixed | `memory-sync.sh:129-131` — `9>&-` on the child in `bounded` | T27 (deterministic: stub leaves a `setsid` child, the next `pull` must get the lock) |
| 5 | fixed | `memory-sync.sh:105-113` — `left` clamped to `TIMEOUT` | T28 (optional test, added: a `date` stub whose first answer is 100 s ahead) |
| 6 | fixed | `memory-sync.sh:42-45` (`MAX_TIMEOUT=17` and why), `:77-90` (`timeout_ok`), header `:27` | T29 |
| 7 | fixed | `memory-sync.sh:185-194` — negative age is not a cool-down | T30 |
| 8 | fixed | `memory-sync.sh:116-119`, `:125`, `:136` (`CUT_OFF`), `:299-301` — `delete: remote delete not confirmed; run delete again` | T31 |
| 9a | fixed | `memory-sync.sh:221-231` — `mv -fT` checked; on failure `<mode>: sent, but the push stamp was not updated: <path>` instead of `ok` | T32 |
| 9b | follow-up, not fixed | `memory-sync.sh:182` — `find` errors still hidden. Reason: the obvious fix (treat a `find` error as "changed") turns one unreadable directory anywhere under `projects/` into a transfer after every tool call; choosing between that and a logged skip is a behaviour decision, not a bug fix | — |
| 9c | fixed | `memory-sync.sh:133-135` — exit 137 is a timeout only when the budget is spent; otherwise `failed (exit 137)` | T35; T22 still covers the real kill-after-TERM path |
| 10 | fixed | `memory-sync.sh:68-76` — mode checked directly after `log()`, before the timeout check, the URI check, the tool probe and `mkdir`; the old `*)` arm is gone from the main `case` | T33 (also T17) |
| 11 | fixed | `tests/memory-sync.test.sh:79-82` — stage copy checked straight after `delete`, before the pull that would prune it | T02 itself; mutant m11 |
| 12 | fixed | stub hook `tests/…:26-27` (`STUB_EDIT`), case at `:272-274` | T34; mutant m12 |
| 13 | fixed | `tests/memory-sync.test.sh:43-48` — the harness exits 1 unless `aws` resolves to the stub file and that file has the stub's content | guard demo below |
| 14 | fixed | `tests/memory-sync.test.sh:161` (and `:269`) — name derived from the script path | T17, T33 |

## Unplanned changes

Everything in this round is outside the plan by definition. Beyond the literal
findings:

- **Finding 6, message wording — please decide.** As instructed, an over-long
  value gets the same line as a malformed one:
  `CLAUDE_MEMORY_S3_TIMEOUT is not a positive integer; using 12`. For `18` that
  sentence is not true — it is a positive integer, just above the cap. I did
  not change the string because T20 and the plan's log table pin it. A truthful
  wording would need a one-line change in the script and in T20/T29.
- **Finding 6, the cap is 17, with zero margin.** 17 + 3 = 20 s, exactly the
  hook timeout. It is the largest value for which the documented bound still
  fits; it also means a machine whose hooks allow 60 s can no longer raise the
  limit above 17.
- Header configuration block gained a `CLAUDE_MEMORY_S3_TIMEOUT` line (`:27`),
  so the cap is documented where the other variables are.
- Finding 10: an unknown mode now prints usage even when
  `CLAUDE_MEMORY_S3_URI` is unset (it used to print the "not set" line) and
  even when the time limit is malformed (no second line).
- Finding 9a: `touch "$next"` has its own error silenced; the failure is
  reported once, after the transfer, by the checked `mv`.
- Finding 1: `rm`'s own error text is silenced; the script's line names the path.
- Harness: two new stub switches (`STUB_DETACH`, `STUB_EDIT`); T29 reads the
  limit with the same `sed` T21 uses rather than a literal, so the count the
  plan's P4.10 expects (`timeout -k 2 12 aws` → 2) is unchanged — checked: `2`.
- The harness is no longer byte-identical to `plan/…/memory-sync.test.sh`
  (expected); plan post-condition P1.5 will now report a difference.

Comment sweep (`TODO|FIXME|HACK|NOTE|XXX`): script rc=1 before and after; the
harness's only match is the `XXXXXX` of `mktemp`, unchanged. Every comment over
changed code was updated in the same edit; none was removed.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root.

```
$ for s in memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
memory-sync.sh rc=0
manager-bootstrap.sh rc=0
tests/memory-sync.test.sh rc=0

$ shellcheck memory-sync.sh tests/memory-sync.test.sh; echo "shellcheck rc=$?"
shellcheck rc=0

$ /usr/bin/grep -c 'shellcheck disable' memory-sync.sh tests/memory-sync.test.sh
memory-sync.sh:0
tests/memory-sync.test.sh:0

$ bash tests/memory-sync.test.sh memory-sync.sh      (three consecutive runs)
run 1 rc=0 ok-lines=35 last=PASS 35/35 secs=19
run 2 rc=0 ok-lines=35 last=PASS 35/35 secs=20
run 3 rc=0 ok-lines=35 last=PASS 35/35 secs=19
```

Case count: **35** (24 + 11 new, T25–T35). Leftover work directories under
`$TMPDIR`: 0. `manager-bootstrap.sh` was syntax-checked only, not edited.

An earlier run of the full suite printed all 35 `ok` lines in order
(T01…T35); the three runs above were summarised by count and last line.

## New harness against the old script

`git show HEAD:memory-sync.sh` saved to a temp directory as `memory-sync.sh`:

```
head rc=1 FAIL 29/35 | NOT OK: T02 T03 T04 T05 T07 T08 T09 T10 T11 T12 T13 T14 T15 T16 T17 T18 T19 T20 T21 T22 T24 T25 T26 T28 T29 T30 T31 T32 T33
```

Passing on the old script, so regression guards against it: T01, T06, T23, and
of the new ones T27, T34, T35 (the old script's `pull` took no lock; it stamped
before the sync; it never mapped 137). Each of those three is discriminated by
a mutant of the new script below.

## Mutation table

Each mutant is the current script with exactly one fix reverted, in a temp copy.

| mutant | reverted | result | fails |
|---|---|---|---|
| m01 | fix 1 — unchecked `rm`, unconditional `delete ok` | FAIL 1/35 | T25 |
| m02 | fix 2 — no `--keep-dirlinks` | FAIL 1/35 | T26 |
| m04 | fix 4 — no `9>&-` | FAIL 1/35 | T27 |
| m05 | fix 5 — no clamp in `left` | FAIL 1/35 | T28 |
| m06 | fix 6 — no length check, no cap | FAIL 1/35 | T29 |
| m07 | fix 7 — no `age >= 0` test | FAIL 1/35 | T30 |
| m08 | fix 8 — `CUT_OFF` branch never taken | FAIL 1/35 | T31 |
| m09a | fix 9a — `mv -f` instead of `mv -fT` | FAIL 1/35 | T32 |
| m09c | fix 9c — any 137 is a timeout | FAIL 1/35 | T35 |
| m10 | fix 10 — mode checked last again | FAIL 1/35 | T33 |
| m11 | fix 11 — stage path dropped from the delete | FAIL 2/35 | T02, T25 |
| m12 | fix 12 — stamp taken after the sync | FAIL 1/35 | T34 |

Fix 13, shown on a copy of the harness cut off right after the guard:

```
(stub removed before the guard)   aws does not resolve to the stub; refusing to run   rc=1
(unmodified, control)             REACHED-RUNS                                        rc=0
```

## Coverage by change

| change | cases | not discriminated, and why |
|---|---|---|
| 1 delete truthfulness | T25 (local copy stays); T02, T03 unchanged | a failure to remove the *stage* copy: same loop, same line, only the local path is exercised |
| 2 symlinked memory dir | T26 | — |
| 3 comment/header | — | prose; read in review |
| 4 lock not inherited | T27 | — |
| 5 clamp | T28 | — |
| 6 cap | T29 (18, 100, 20 digits rejected; 17 accepted), T20 | — |
| 7 future stamp | T30; T07, T08 still hold the normal path | — |
| 8 cut-off delete | T31 | the "budget spent before the request started" path also sets `CUT_OFF`; unreachable in a test, as in slice 1 |
| 9a stamp not updated | T32 (stamp path is a non-empty directory) | a failing `touch` of the `.next` file on its own — reported through the same `mv` check |
| 9c 137 | T35, T22 | — |
| 10 mode first | T33, T17 | — |
| 11, 12, 14 | T02, T34, T17/T33 | — |
| 13 | guard demo | not a case inside the suite: it runs before any case can |
| all | every `run` asserts rc 0 and empty stdout | every comment edit |

Still uncovered from slice 1 and unchanged: the spent-budget branch of
`bounded`, the "raise `t` to 1" line in `lock`, the `stat` guard in `cooling`,
the empty-array guard, and that the pull rsync and `aws s3 rm` run inside
`bounded` (T31 now does cut an `aws s3 rm` off at the limit, which covers the
`rm` half of that).

## Blast radius

**Log lines — new**

- `delete: remote copy removed, but this copy was NOT removed: <path>` (one per
  copy that stayed; no `delete ok` in that run)
- `delete: remote delete not confirmed; run delete again` (after a cut-off;
  preceded by `delete timed out after <n>s`)
- `<mode>: sent, but the push stamp was not updated: <path>`

**Log lines — same text, new triggers**

- `CLAUDE_MEMORY_S3_TIMEOUT is not a positive integer; using 12` now also for
  any value above 17 or of three or more digits.
- `<mode> failed (exit 137)` where a child was killed before the limit
  (formerly `timed out`).
- The usage line now wins over `CLAUDE_MEMORY_S3_URI is not set; skipping` for
  an unknown mode.

**Behaviour**

- Time limit capped at 17 s. A live `CLAUDE_MEMORY_S3_TIMEOUT` above 17 will
  silently-but-logged become 12 on install.
  `UNVERIFIED: the live value — ~/.claude/settings.json was deliberately not read.`
- `pull` writes through a symlinked `memory` directory instead of replacing it.
- Children no longer hold the lock file open.
- A future-dated failure stamp no longer blocks `push-if-changed`.
- An unknown mode creates nothing and probes nothing.
- A push whose stamp cannot be written leaves the failure stamp cleared and the
  push stamp as it was, so `push-if-changed` sends again next time.
- Unchanged: mode names, exit 0 on every path, empty stdout, stderr prefix, the
  `TIMEOUT + 3` s bound, the default of 12, every string in the plan's log table.

**Callers**: the four hook events and the `sync-memory` skill, as before; no new
caller. **State**: no new file, no format change; the stage, both stamps and the
lock keep their meaning. **Remote objects**: `delete` still removes exactly one
key; nothing else gained a delete path.

**Roll back** (uncommitted): `git restore -- memory-sync.sh` returns the script
to `HEAD` (losing slice 1 too); the harness is untracked, so its slice 1 state is
`cp plan/bug-reviewer-findings/memory-sync.test.sh tests/memory-sync.test.sh`.
Neither was run.

**Text in other files that is now stale** (not edited — outside my boundary)

- `skills/sync-memory/SKILL.md:72` — "A pull never overwrites a local file that
  is newer than the remote copy." Should say: newer than the remote object's
  upload time (finding 3).
- `skills/sync-memory/SKILL.md:32-33` — lists `delete ok: <path>` and says
  "anything else is the reason it did not". Still true, but two new outcomes
  need naming for a reader: the remote copy removed with a local copy left
  (remove it by hand or the next push restores it), and "not confirmed; run
  delete again". Also `<mode>: sent, but the push stamp was not updated`.
- `skills/sync-memory/SKILL.md:87-89` (Deleting a memory) — "when the remote
  delete fails nothing local is touched" is still true; missing are the two
  cases above.
- `README.md:68-70` — "defaults to 12 seconds … keep every hook timeout at
  least 5 seconds above it" does not say that values above 17 are rejected and
  replaced by 12.
- `settings.example.json` — nothing stale (it does not set the variable; 20 s
  hook timeouts are what the cap assumes).
- `AGENTS.md` — nothing stale; its gate commands were the ones run above.
- `plan.md` P1.5 expects the harness to equal the `plan/` copy; it no longer does.

## Follow-ups

Not written to a file (only this result file is mine under `plan/`).

- **Finding 3, the design gap.** A push uploads whatever differs in size or
  time, and a pull compares against the upload time. A machine with an old copy
  that pushes after a newer edit was uploaded elsewhere overwrites it, and its
  upload then looks newest to everyone. Recoverable only through bucket
  versioning. Needs a design (content timestamps or tombstone-style metadata).
- **Finding 9b**, `find` errors hidden in `changed` — needs a decision between
  "push anyway" and "log and skip".
- **The cap of 17** ties the script to a 20 s hook timeout; if hooks with longer
  timeouts should be able to use longer limits, the cap needs to become
  configurable — a design choice.
- **The fallback message** for over-long values (see Unplanned changes).
- **Symlinked memory directories and `push-if-changed`**: `changed` uses `find`
  without following links, so edits under a symlinked `memory` directory are
  never seen as changes. `INFERRED` from the `find` call; not reproduced, not
  in the findings.
- `delete` accepts nested paths under `memory/` (carried over from slice 1).

## Not done

- No file outside the two in scope was edited, including the stale lines above.
- The plan's B3 mutant table was not re-run; the table above is this round's.

## Follow-up 1 — the over-cap value gets its own, truthful line

Supersedes, above: the first bullet under "Unplanned changes", the T29 row
wording, the "same text, new triggers" bullet about the time limit, and the
`timeout_ok` reference in finding 6 (that function is gone). Line numbers
elsewhere in this file below `memory-sync.sh:77` are now off by a few.

- `memory-sync.sh:77-94` — one `case`: a malformed value (empty, non-digit,
  leading zero) keeps `CLAUDE_MEMORY_S3_TIMEOUT is not a positive integer; using 12`;
  a well-formed value of three digits or more, or above the cap, logs
  **`[memory-sync] CLAUDE_MEMORY_S3_TIMEOUT is above 17; using 12`**. The digit
  count is tested before the numeric comparison, so a 20-digit value is never
  compared as a number. The cap stays 17 and its comment (`:42-45`, 17 + 3 =
  20 s hook timeout) is unchanged.
- `memory-sync.sh:27` — header now reads "optional, whole seconds; default 12,
  maximum 17".
- `tests/memory-sync.test.sh` — T29 asserts the new line and the absence of
  "not a positive integer" for 18, 100 and a 20-digit value; T20 additionally
  asserts the absence of "is above" for `abc`, `0`, `08`, `-3`. No case added:
  the count stays **35**.

Gates (`export TMPDIR=/data/tmp/claude`, repo root):

```
memory-sync.sh rc=0                  (bash -n)
tests/memory-sync.test.sh rc=0       (bash -n)
shellcheck rc=0                      (0 disable directives in either file)
run 1 rc=0 ok-lines=35 last=PASS 35/35
run 2 rc=0 ok-lines=35 last=PASS 35/35
run 3 rc=0 ok-lines=35 last=PASS 35/35
```

Mutants that reuse one message for both inputs:

| mutant | change | result | fails |
|---|---|---|---|
| a | over-cap branch logs the "not a positive integer" line | FAIL 1/35 | T29 |
| b | malformed branch logs the "is above 17" line | FAIL 1/35 | T20 |

The plan's P4.10 count (`timeout -k 2 12 aws` in the harness) is still `2`.

Stale text for the prose developer, replacing the README entry above:
`README.md:68-70` should say the limit has a maximum of 17 and that a larger
value is replaced by 12 with the line quoted here. If the skill lists log
lines, this is one more.
