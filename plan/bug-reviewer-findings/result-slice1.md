# Result — bug-reviewer-findings, slice 1 (S1.1–S1.25)

Contract note: this repo has **no `AGENTS.md`** (Slice 4 creates it). The root
`CLAUDE.md` is published payload, not a working agreement; it was not treated as
one. The contract used was `plan.md` revision 2 plus the two answers tables in
`questions.md`.

Preconditions B1.2–B1.5 held (`bc2e399`; five tool paths; `0400cfb193a51c72` /
`24`; `5`). B1.1 did **not** read as written: twelve `M` entries under
`agents/`, `commands/` and `manager-bootstrap.sh` were already present — the
parallel Slice 2 work announced in the dispatch. None of those files was
touched here.

## Stages

All line numbers are in the tree as it now stands.

| step | state | where |
|---|---|---|
| S1.1 | done | `memory-sync.sh:35-38` (default 12 + why), `:61-68` (validation, after `log()` at `:59`, before the URI check at `:106`) |
| S1.2 | done | `memory-sync.sh:70-104` (`now_ms`, `START_MS`, `left`, `bounded`, mechanism comment) |
| S1.3 | done | `memory-sync.sh:111-112`; used at `:181`, `:195`, `:238` |
| S1.4 | done | `memory-sync.sh:114-119` (probe loop), `:26` (header line) |
| S1.5 | done | `memory-sync.sh:127-130`; guarded expansion at `:138`, `:238` |
| S1.6 | done | `memory-sync.sh:132-139` |
| S1.7 | done | `memory-sync.sh:192-203`; stage comment `:40-46` |
| S1.8 | done | `memory-sync.sh:50-54` (`FAILED`, `COOLDOWN`), `:147-153` (`cooling`), `:183`, `:187` (in `push()`) |
| S1.9 | done | `memory-sync.sh:155-174` (`lock`), comment `:55-57` |
| S1.10 | done | `memory-sync.sh:204-218` |
| S1.11 | done | `memory-sync.sh:219-244` |
| S1.12 | done | `memory-sync.sh:5-14` (header), `:245` (usage) |
| S1.13 | done | `tests/memory-sync.test.sh` (new, mode 755, identical to the `plan/` copy) |
| S1.14 | done | `skills/sync-memory/SKILL.md:3-4` |
| S1.15 | done | `SKILL.md:12` |
| S1.16 | done | `SKILL.md:20-22` |
| S1.17 | done | `SKILL.md:26` |
| S1.18 | done | `SKILL.md:32` |
| S1.19 | done | `SKILL.md:41` |
| S1.20 | done | `SKILL.md:43-52` |
| S1.21 | done | `SKILL.md:53-54` |
| S1.22 | done | `SKILL.md:64-72` |
| S1.23 | done | `SKILL.md:74-89` |
| S1.24 | done | `SKILL.md:93` |
| S1.25 | done | `SKILL.md:99-104`, `:110-112`, `:119`, `:121` |

## Blocked

Nothing.

## Unplanned changes

No file outside the boundary was touched. Inside it, these go beyond the
literal step text and should be read in review:

- `memory-sync.sh:151` — `cooling()` reads the stamp's mtime with
  `stat … 2>/dev/null || return 1` before the subtraction. Forced by S1.8 plus
  the hook contract: if the stamp vanishes between the `-f` test and `stat`
  (a concurrent successful push removes it), the bare arithmetic would print an
  unprefixed bash error on stderr.
- `memory-sync.sh:171` — the non-blocking message is built from `$MODE`, not the
  literal `push-if-changed`. The printed line is identical, because only
  `push-if-changed` calls `lock nowait`.
- `memory-sync.sh:245` — usage still uses `$(basename "$0")`, as at baseline;
  the plan's coverage note for S1.12 assumes this.
- One-line descriptive comments added above `left`, `bounded`, `cooling`, `lock`
  and at `:205`, `:211` — comments for new code, no step names them.
- `SKILL.md:51` — the baseline sentence `This is the honest answer to "are my
  memories backed up".` was kept inside the rewritten item 3. S1.20 says the
  item "becomes" the new text without naming that sentence for deletion; the
  conventions say nothing is deleted unless named.
- `SKILL.md:12`, `:26` — the replaced sentences sit on one long line each rather
  than being re-wrapped, so the verbatim text is unbroken.

Comment sweep (`TODO|FIXME|HACK|NOTE|XXX`) on `memory-sync.sh` and `SKILL.md`:
rc=1 before and after, with a positive control returning 1 match. No marker
existed, none was removed. Every baseline explanatory comment in the script is
still present, updated where its code changed.

## Tests

`tests/memory-sync.test.sh` added (24 cases), unmodified. Result: `PASS 24/24`
on five runs. The fake `aws` is the stub executable on `PATH` that the harness
creates (allowed here per Q11). No percentage exists for bash; coverage is this
list:

| step | covered by (all ok) | not discriminated, and why |
|---|---|---|
| S1.1 | T19, T20 | position of the validation: indirectly, via T20's log line and shellcheck |
| S1.2 | T16, T19, T21, T22 | the "budget already spent, command not started" branch (`:91-94`) — needs more than `TIMEOUT` s of local work first; never executed by any case |
| S1.3 | T13 | — |
| S1.4 | T14 | the header sentence — prose |
| S1.5 | T12 | the `${extra[@]+…}` guard — indistinguishable from its absence on this bash (5.3) |
| S1.6 | T05, T01 | the rewritten comment |
| S1.7 | T05, T15, T18 | that rsync runs *inside* `bounded` (see below) |
| S1.8 | T07, T08, T09 | the `stat` failure guard at `:151` — a race, not reproducible in a test |
| S1.9 | T10, T11, T18, T21, T24 | the "raise `t` to 1" line (`:165`) — needs the budget spent before the lock |
| S1.10 | T07, T09, T10, T21, T23 | — |
| S1.11 | T02, T03, T04, T24 | remote-first ordering only in the failure direction (T03); that `aws s3 rm` runs inside `bounded` (see below) |
| S1.12 | T17 | header text — prose |
| S1.13 | P1.5 | — |
| S1.14–S1.25 | P1.6–P1.11 (no test; Markdown has no gate) | S1.15, S1.20, S1.21, S1.23 have no positive phrase probe: S1.15/S1.21 are held by the P1.6 counts, S1.20 by P1.7, S1.23 only by its heading (P1.8) — its body is read in review |
| all | every `run` asserts rc 0 and empty stdout | every comment edit |

## Gates

Run from the repo root with `export TMPDIR=/data/tmp/claude`.

```
$ bash -n memory-sync.sh; echo "bash -n rc=$?"
bash -n rc=0

$ shellcheck memory-sync.sh tests/memory-sync.test.sh; echo "shellcheck rc=$?"
shellcheck rc=0

$ bash tests/memory-sync.test.sh memory-sync.sh      (three consecutive runs, each:)
ok T01 push then pull round-trips a memory
ok T02 delete removes remote, stage and local copy and it stays gone after push+pull
ok T03 delete leaves local and stage untouched when the remote delete fails
ok T04 delete rejects anything that is not <project>/memory/<file> without calling aws
ok T05 pull prunes the stage, so a file gone from the remote is not restored
ok T06 pull does not overwrite a newer local file
ok T07 a failed push starts a cool-down: the next push-if-changed makes no aws call and prints nothing
ok T08 the cool-down holds at 4 minutes and ends by 6; success clears the failure stamp
ok T09 push ignores the cool-down
ok T10 push-if-changed does not wait for a held lock
ok T11 an unopenable lock file is reported as such, not as busy
ok T12 CLAUDE_MEMORY_S3_ARGS is split on spaces but not glob-expanded
ok T13 trailing slashes on the URI do not produce // in keys
ok T14 each required tool (aws, timeout, flock, rsync) is probed; a missing one is named and the run skipped
ok T15 an rsync failure during pull is logged
ok T16 a hung transfer is cut off at the timeout and counted as a failure
ok T17 an unknown mode prints usage
ok T18 pull takes the lock and gives up at the timeout while another sync holds it
ok T19 the default time limit is 12 s and transfers run under timeout -k 2
ok T20 a time limit that is not a positive integer (abc, 0, 08, -3) falls back to 12 and says so
ok T21 push waits for the lock, and the transfer only gets what the lock wait left of the time limit
ok T22 a transfer that ignores TERM is killed: the run ends within the limit plus 3 s
ok T23 push-if-changed checks again after taking the lock and sends nothing if another push just did
ok T24 delete takes the lock and removes nothing while another sync holds it
PASS 24/24
rc=0
```

Build ok · tests ok · lint ok. No `shellcheck disable` directive exists in the
script (the baseline one went with S1.5). No fix-mode tool was run. The three
full runs were made before the `SKILL.md` edits; the script did not change
afterwards, and two further runs after those edits gave 24 `ok` lines and
`PASS 24/24`.

## Post-conditions

| check | expected | actual |
|---|---|---|
| P1.1 | `memory-sync.sh rc=0` / `tests/memory-sync.test.sh rc=0` | `memory-sync.sh rc=0` / `tests/memory-sync.test.sh rc=0` |
| P1.2 | `rc=0`, no other line | `rc=0`, no other line |
| P1.3 | `0` | `0` |
| P1.4 | `ok T01`…`ok T24` in order, `PASS 24/24` | `ok T01`…`ok T24` in order, `PASS 24/24` |
| P1.5 | `rc=0` / `755` | `rc=0` / `755` |
| P1.6 | 2 each of `PostToolUse`, `SessionEnd`, `SessionStart`, `Stop` | `2 PostToolUse` / `2 SessionEnd` / `2 SessionStart` / `2 Stop` |
| P1.7 | `5` | `5` |
| P1.8 | `1` | `1` |
| P1.9 | `rc=1`, no other line | `rc=1`, no other line (same pattern on `HEAD`'s copy: 8 lines — the pattern does match) |
| P1.10 | `2` | `2` |
| P1.11 | 13 lines each ending `: 1` | 13 lines, each ending `: 1` |

Also: `ls /data/tmp/claude | /usr/bin/grep -c memory-sync-test` → `0` (the
harness removed its work directory). `s3://` strings in the three files:
`s3://my-bucket`, `s3://stub`; `endpoint-url=...` only — placeholders, as at
baseline plus the test's stub.

## Blast radius

**What changed in behaviour or format**

- Default time limit 25 s → 12 s; an invalid `CLAUDE_MEMORY_S3_TIMEOUT` now
  falls back to 12 with a log line instead of reaching `timeout` as given.
- The limit is one budget for the whole run, lock wait included; children get
  `timeout -k 2`.
- `pull` now takes the lock (blocking), passes `--delete` toward the **stage
  only**, and logs an rsync failure.
- `push-if-changed` no longer waits for the lock, and is silent and inert for
  300 s after a failed push.
- New mode `delete`; new usage string; `aws cli not found` is now
  `aws not found`; `timeout`, `flock`, `rsync` are probed too.
- Trailing slashes on the URI are stripped before use.
- `CLAUDE_MEMORY_S3_ARGS` is no longer glob-expanded.
- Lock-busy messages changed wording (`lock busy after <n>s`, `another sync is
  running`).
- Unchanged: mode names, exit 0 on every path, nothing on stdout, the
  `[memory-sync] ` prefix, `push ok` / `pull ok`.

**Who calls it**

- `SessionStart` → `pull`; `SessionEnd` → `push`; `PostToolUse` and `Stop` →
  `push-if-changed`. This is per the plan and the skill text;
  `UNVERIFIED: the live hook wiring — ~/.claude/settings.json was deliberately not read.`
- The `sync-memory` skill, by hand, including `delete`.
- Nothing in this repo invokes the script except the new test.

**Existing data and state it can affect** (only once installed — nothing was
installed, Q1)

- Stage directory `.memory-sync-stage`: the first pull prunes it to match the
  bucket. It is a cache; `projects/` is never pruned.
- `.memory-sync-pushed`, `.memory-sync.lock`: same meaning as before.
- `.memory-sync-failed`: new; appears after a failed push, safe to delete.
- Remote objects: only `delete` removes one, and only the single key named.
  Recoverable only if bucket versioning is on —
  `UNVERIFIED: bucket versioning is enabled — the user's statement, no command run.`
- A live URI ending in `/` would move reads and writes from `…//…` keys to
  `…/…` (plan A4).
- A live `CLAUDE_MEMORY_S3_TIMEOUT` above 15 would defeat the 20 s hook margin
  (plan A4).

**Roll back** (uncommitted): `git restore -- memory-sync.sh skills/sync-memory/SKILL.md`,
`rm tests/memory-sync.test.sh`, `rmdir tests` — plan A6 unit 3. Not run here.
Runtime: nothing to undo; no real backend was contacted and `~/.claude` was not
written.

## Known undiscriminated

Built as the plan says; no test tells them from their absence.

- (a) Pull's rsync runs inside `bounded` (`:199`). T15 checks the failure log
  line only; a bare `rsync` with its own logging would pass.
- (b) `delete`'s `aws s3 rm` runs inside `bounded` (`:238`). No case hangs or
  times the `rm`; T19/T20 match the `timeout` parent only for `sync`.
- (c) The "no `$SECONDS`" rule (`:77-81`). The plan reports a `$SECONDS`
  prototype failing T20 intermittently; nothing fails deterministically.
- (d) A backgrounded child of a killed `aws` can outlive the script. It also
  inherits fd 9, so it would keep the lock held until it exits — later `pull`,
  `push` and `delete` runs would report `lock busy`, and `push-if-changed`
  would skip. `PROVEN` only as far as: the script never closes fd 9 for its
  children (read from the code; baseline behaved the same). `INFERRED`: the
  lock-holding consequence — not reproduced.
- Plus the branches listed in the coverage table: `:91-94`, `:151`, `:165`, and
  the empty-array guard.

## Follow-ups

Not written to a file — the dispatch allows only this result file under
`plan/`. For whoever owns `follow-ups.md`:

- Close fd 9 for children (`9>&-`) or kill the child's process group, to settle
  (d). Out of scope: no step names it.
- Tests for (a), (b) and the spent-budget branch.
- `delete` accepts nested paths such as `p/memory/sub/x.md`, since `*` in the
  plan's pattern spans `/`. Built as specified; noted in case it was not meant.
- `CLAUDE_MEMORY_S3_TIMEOUT` is not listed in the script header's
  configuration block. No step asked for it.
- The plan's own follow-ups (tombstones, `MEMORY.md` index, pull race) stand.

## Not done

- Slices 2, 3, 4 — outside this scope.
- Plan claims not verified here: the four `UNVERIFIED` AWS CLI / versioning
  items in plan B4 (`--delete` with filters, `s3 rm` of a missing key exits 0,
  versioning on, no trailing slash on the live URI) — verifying any of them
  needs a real backend, which is forbidden.
- The B3 mutant table was not re-run against this build.
- Nothing was committed, staged, pushed or copied into `~/.claude`.
