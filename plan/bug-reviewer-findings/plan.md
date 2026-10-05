# Plan — bug-reviewer-findings

Built on `findings.md` and the **Answers** and **Further answers** tables at the
end of `questions.md` (Q1–Q11 resolved, 2026-10-04). **Revision 2** — amended
after plan analysis round 1; step ids are unchanged, two are withdrawn (S2.7,
S2.12) and two folded (S4.4, S4.5), each marked where it stood. Planning document only; nothing below has been
applied to the repo.

## Conventions used in this plan

- **Line numbers are baseline** — commit `bc2e399`. Steps in one file shift
  later lines, so every step also quotes an **anchor**: find the anchor text,
  do not trust the number after the first edit to a file.
- "Replace with" text in a quote block is **verbatim**, including backticks and
  the em dash `—`. Phrases the post-conditions grep for must stay **on one
  line** (do not re-wrap them).
- **Commands are given in fenced blocks and are copy-ready.** Inside Markdown
  tables only, `\|` is the table's escape for `|`.
- Every `grep` in this plan is `/usr/bin/grep`. Temp files:
  `export TMPDIR=/data/tmp/claude`.
- **Comments (`comments` skill).** Before editing any file, run
  `/usr/bin/grep -n -E 'TODO|FIXME|HACK|NOTE|XXX' <file>` and carry every match
  through unchanged. Planner's baseline sweep of the files this plan edits found
  **no markers** (only two sentences that mention the words:
  `skills/bootstrap/SKILL.md:41`, `agents/reviewer.md:15`); re-run it anyway.
  Every explanatory comment in `memory-sync.sh` (`:2-22`, `:30-35`, `:37`,
  `:39`, `:56-57`, `:63-64`, `:74`, `:81-82`, `:97-99`, `:111`) records a
  decision: keep it, and update it **in the same edit** that changes the code
  under it. Nothing is deleted except where a step names the exact text and
  says so. Every recorded incident in the prose files is kept; only its
  attribution or location changes.
- **Secrets.** No bucket name, endpoint, profile name or env value in any file,
  commit message, log or report. Placeholders only: `<bucket>`, `<prefix>`,
  `<profile>`.
- **Never run `memory-sync.sh` against a real backend.** All runtime
  verification goes through `tests/memory-sync.test.sh`, which puts a stub
  `aws` first on `PATH`, uses a throwaway `CLAUDE_CONFIG_DIR` under `$TMPDIR`,
  and kills only PIDs it started itself. No pattern-based `pkill`/`killall`
  anywhere, in tests or in cleanup.
- **Repo only (Q1).** Nothing is copied, symlinked or installed into
  `~/.claude`. No install script.

---

# Phase 1 — before

## B1. Preconditions (all must hold; stop and report if one does not)

```sh
# B1.1
git -C /home/pvhv/projects/skills status --short -uall
#   expect: only "?? plan/bug-reviewer-findings/…" entries
#           (findings.md, questions.md, plan.md, memory-sync.test.sh)

# B1.2
git log -1 --format=%h
#   expect: bc2e399

# B1.3
command -v shellcheck jq flock timeout rsync
#   expect: five paths, none missing

# B1.4
sha256sum plan/bug-reviewer-findings/memory-sync.test.sh | cut -c1-16; /usr/bin/grep -c '^t T' plan/bug-reviewer-findings/memory-sync.test.sh
#   expect: 0400cfb193a51c72
#           24

# B1.5
ls -d AGENTS.md tests settings.example.json host.example.md .gitignore 2>&1 | /usr/bin/grep -c 'No such file'
#   expect: 5        (none exists yet; on a retry after a back-out this must be 5 again — see A6)
```

## B2. Baseline gate output (planner-run from the repo root, 2026-10-04, revision 2)

```
bash -n memory-sync.sh        -> rc=0
bash -n manager-bootstrap.sh  -> rc=0
shellcheck memory-sync.sh manager-bootstrap.sh -> rc=1
  In memory-sync.sh line 70: SC2015 (info): Note that A && B || C is not if-then-else.
TMPDIR=/data/tmp/claude bash plan/bug-reviewer-findings/memory-sync.test.sh memory-sync.sh
  ok T01 …, ok T06 …, ok T23 …, NOT OK for the other twenty-one, last line: FAIL 21/24
```

The harness resolves the script path to an absolute one itself, so the relative
`memory-sync.sh` above is correct from the repo root (revision 1 could not).

T01, T06 and T23 pass on the unfixed script: they are regression guards and
**cannot discriminate** fixed from unfixed. (T23 does discriminate a fixed
script that dropped the second `changed` — see the mutant list in B3.) The other
twenty-one fail at baseline.

## B3. Buildability evidence

The planner built a throwaway prototype of slice 1 outside the repo following
steps S1.1–S1.12 and ran the harness against it with the same relative-path
form: `shellcheck` rc=0 on script and harness, `PASS 24/24` on four consecutive
runs. Fourteen single-change mutants of the prototype were then run; each was
caught, by the case shown:

| mutant | caught by |
|---|---|
| default limit 25 instead of 12 | T19 |
| `timeout` without `-k 2` | T19, T20, T21, T22 |
| transfer given the full limit, not what the lock wait left | T21 |
| probe only `aws` and `rsync` | T14 |
| `COOLDOWN=60` / `COOLDOWN=600` | T08 / T08 |
| second `changed` dropped | T23 |
| `delete` without the lock | T24 |
| `*/./*` not rejected | T04 |
| directory argument not rejected | T04 |
| limit validation removed | T20 |
| `08` accepted as a limit | T20 |
| `push` takes the lock non-blocking | T21 |
| status 137 not reported as a timeout | T22 |

The prototype was deleted; only the harness was kept (in `plan/`). This proves
the steps are mutually consistent and the cases bite — not that the developer's
version is correct. The developer's gates are in Phase 3.

## B4. What this plan rests on that is UNVERIFIED

- `UNVERIFIED: aws s3 sync --delete, combined with --exclude/--include, only removes destination files that pass the filters` — from the AWS CLI's documented behaviour; never run against a real CLI here. Risk is confined to the stage cache (S1.7).
- `UNVERIFIED: aws s3 rm of a key that does not exist exits 0` — S3 delete is idempotent by specification; not run.
- `UNVERIFIED: bucket versioning is enabled` — the user's statement (Q2). The `delete` mode is recoverable only if it is true.
- `UNVERIFIED: Claude Code expands ~ in a hook command string` — used in `settings.example.json`; the live file uses absolute paths.
- `UNVERIFIED: the live URI has no trailing slash` — see A4 in Phase 3.
- `UNVERIFIED: git revert of the slice commits applies cleanly` — no commits exist yet (A6).
- The harness reads `/proc/$PPID/cmdline` to see the limit the script handed to `timeout`; that is Linux-only, consistent with Q6, and proven on this host only.
- `UNVERIFIED: ugrep returns zero matches for a leading alternation group` — did not reproduce; S3.9 keeps the lesson worded as an observation.

---

# Phase 2 — processing

Four slices, in this order. **Dependencies:** slice 1 shares no file with
slices 2 and 3 and may run in parallel with slice 2. Slice 3 edits three files
slice 2 also edits (`agents/reviewer.md`, `agents/analyzer.md`,
`commands/develop.md`) and must start only after slice 2 is finished. Slice 4
names things slices 1–3 create (the `delete` mode, the test file,
`host.example.md`) and runs last.

## Slice 1 — memory sync (13 + 12 steps)

**File boundary:** `memory-sync.sh`, `skills/sync-memory/SKILL.md`, and the new
`tests/memory-sync.test.sh` — nothing else.

**Hook contract, preserved by every step:** the mode names `pull`, `push`,
`push-if-changed` keep their meaning; every path exits 0; nothing is written to
stdout; all messages go to stderr prefixed `[memory-sync] `. The harness
asserts rc 0 and empty stdout on every single run. `delete` is a new, manual
mode — no hook calls it.

**Exact log strings** (the harness matches them; do not paraphrase):

| situation | stderr line |
|---|---|
| required tool absent (including `aws`, which used to say `aws cli not found`) | `[memory-sync] <tool> not found; skipping` |
| bad time limit | `[memory-sync] CLAUDE_MEMORY_S3_TIMEOUT is not a positive integer; using 12` |
| transfer or rsync non-zero | `[memory-sync] <mode> failed (exit <rc>)` |
| transfer cut off | `[memory-sync] <mode> timed out after <TIMEOUT>s` |
| lock file cannot be opened | `[memory-sync] <mode>: cannot open lock file <path>; skipping` |
| blocking lock not obtained | `[memory-sync] <mode>: lock busy after <TIMEOUT>s; skipping` |
| non-blocking lock not obtained | `[memory-sync] push-if-changed: another sync is running; skipping` |
| delete, bad argument | `[memory-sync] delete: expected <project>/memory/<file>, relative to <ROOT>; nothing removed` |
| delete, remote failed | `[memory-sync] delete: remote copy not removed; local copy left in place` |
| delete done | `[memory-sync] delete ok: <rel>` |
| usage | `[memory-sync] usage: memory-sync.sh pull\|push\|push-if-changed\|delete <project>/memory/<file>` |
| unchanged | `<mode> ok`, `pull ok`, `CLAUDE_MEMORY_S3_URI is not set; skipping` |

(In the usage row `\|` is this table's escape for `|`; the string printed is
`usage: memory-sync.sh pull|push|push-if-changed|delete <project>/memory/<file>`.)

### `memory-sync.sh`

**S1.1 — timeout default and validation.** Two edits. (a) `:28`, anchor
`TIMEOUT=${CLAUDE_MEMORY_S3_TIMEOUT:-25}`: change the default `25` → `12`, and
add a comment recording why 12: a run can last up to the limit plus 3 s (S1.2),
and the hook timeout in `settings.example.json` is 20 s, so 12 leaves 5 s for
the script to log its own timeout before the harness kills it. (b) The
validation goes **immediately after the `log()` definition at `:42` and before
the `CLAUDE_MEMORY_S3_URI` check at `:44`** — never above `log()`, which it
calls. It is a `case "$TIMEOUT"` whose pattern `'' | *[!0-9]* | 0*` (empty,
any non-digit, or a leading zero — so `0`, `08` and `-3` are all rejected and no
value can reach arithmetic as octal) logs the "not a positive integer; using 12"
line and sets `TIMEOUT=12`.

**S1.2 — one time budget for the whole run.** Directly after the validation
from S1.1(b), add: `now_ms` (prints `$(date +%s%N) / 1000000`); `START_MS`
set once from it; `left`, which prints the whole seconds of `TIMEOUT` still
unspent, **rounded up**:
`(TIMEOUT*1000 - (now_ms - START_MS) + 999) / 1000`; and
`bounded <cmd…>`, which reads `t=$(left)`, and if `t` is below 1 logs the
"timed out" line and returns 1 **without running the command**; otherwise runs
`timeout -k 2 "$t" "$@"`, returns 0 on success, logs the "timed out" line for
status 124 or 137 and the "failed (exit N)" line for anything else, and
returns 1. Do **not** use `$SECONDS`: it counts wall-clock second boundaries,
so it can read 1 a few milliseconds after start and makes the limit handed to
`timeout` vary from run to run (the planner's first prototype failed T20 this
way). The log branch is written as `if … then … else … fi` — **this is what
turns shellcheck green** (it replaces the `A && B || C` at `:70`, SC2015).

*The bound, stated exactly.* Every lock wait and every bounded command is given
at most the rounded-up remainder of one shared limit, so each ends no later
than `TIMEOUT + 1` s after start; a child that ignores `TERM` is killed 2 s
later. Worst case for any mode is therefore **`TIMEOUT + 3` s — 15 s by
default, 5 s under the 20 s hook timeout** — however many bounded calls the
mode makes, because a call that would start after the limit is not started.
Outside the bound, and accepted: the local `find` in `changed`, and `mkdir`,
`touch`, `mv`, `rm` on local files. Comment this mechanism in the script.

**S1.3 — normalise the URI.** After the `CLAUDE_MEMORY_S3_URI` check
(`:44-47`), add
`URI="${CLAUDE_MEMORY_S3_URI%"${CLAUDE_MEMORY_S3_URI##*[!/]}"}"` (strips every
trailing `/`) with a comment saying why. Use `"$URI/"` at the two call sites
(`:85`, `:96`) and in `delete`. Nothing else about the URI is altered.

**S1.4 — probe every required tool.** `:49-52`, anchor
`if ! command -v aws`. Replace the single `aws` probe with a loop over
`aws timeout flock rsync` that logs `<tool> not found; skipping` and exits 0
for the first one missing. Extend the header comment (`:15-22`) with one line:
Linux with GNU coreutils, util-linux `flock` and `rsync` is required.

**S1.5 — split `CLAUDE_MEMORY_S3_ARGS` without globbing.** `:60-61`, anchor
`extra=(${CLAUDE_MEMORY_S3_ARGS:-})`. Replace both lines (the
`# shellcheck disable=SC2206` directive goes with the code it excused) with
`extra=()` and `read -r -a extra <<<"${CLAUDE_MEMORY_S3_ARGS:-}"`. Add a
comment: split on whitespace only, never glob-expanded against the hook's cwd;
an argument containing a space is not supported. Wherever the array is
expanded, write `${extra[@]+"${extra[@]}"}` (safe when empty under `set -u` on
any bash).

**S1.6 — `sync()` takes extra arguments.** `:65-72`. Body becomes: take `src`
and `dst`, `shift 2`, and call
`bounded aws s3 sync "$src" "$dst" "${scope[@]}" ${extra[@]+"${extra[@]}"} "$@" --only-show-errors`.
The `local rc` / `:69-71` logic is gone (it lives in `bounded`, S1.2). Rewrite
the comment at `:63-64` to say: no `--delete` toward the remote and none toward
`$ROOT` — a half-written local state must not wipe the remote and a stale
remote must not delete local memories; the only `--delete` is on the stage,
which is a cache (S1.7); removing a memory is the `delete` mode's job.

**S1.7 — pull: lock, prune the stage, log rsync failure.** `:94-101`. New
body, in order: take the lock **blocking** (S1.9); `mkdir -p "$STAGE"`;
`sync "$URI/" "$STAGE/" --delete`; on success
`bounded rsync -a --update "$STAGE/" "$ROOT/"` and log `pull ok` only if it
returns 0. Keep the comment at `:97-99`; extend the stage comment at `:30-35`
with: the stage is pruned to match the remote on every pull, so a file removed
from the bucket can no longer be copied back out of the stage. `$ROOT` is never
pruned.

**S1.8 — failure stamp and cool-down.** Add `FAILED="$CONF/.memory-sync-failed"`
and `COOLDOWN=300` next to `STAMP` (`:38`) with a comment: written when a push
fails, removed when a push succeeds, read only by `push-if-changed`; 300 s is
the user's chosen cool-down. Add `cooling()`: true when `$FAILED` exists and
`$(date +%s) - $(stat -c %Y "$FAILED")` is below `COOLDOWN`. In `push()`
(`:80-91`): after a successful sync also `rm -f "$FAILED"`; in the failure
branch also `touch "$FAILED"`. Writers: `push()` only (so both `push` and
`push-if-changed`). Reader: `push-if-changed` only.

**S1.9 — one lock helper for every mode.** Replace the two inline
`exec 9>"$LOCK"` / `flock` pairs (`:104-105`, `:110-112`) with a function
`lock <wait|nowait>`: open with `if ! { exec 9>"$LOCK"; } 2>/dev/null` → log
the "cannot open lock file" line and `exit 0`; then `flock -w "$t" 9` (with
`t=$(left)`, raised to 1 if lower) for `wait` (failure → "lock busy after …" line, `exit 0`) or `flock -n 9` for
`nowait` (failure → "another sync is running" line, `exit 0`). Update the
comment at `:39` to say the lock serialises pull, push and delete, not only
pushes. Lock use per mode:

| mode | lock | blocking |
|---|---|---|
| `pull` | exclusive | yes, up to the remaining budget |
| `push` | exclusive | yes, up to the remaining budget |
| `push-if-changed` | exclusive | **no** (`flock -n`) |
| `delete` | exclusive | yes, up to the remaining budget |

**S1.10 — `push` and `push-if-changed` bodies.** `:103-115`. `push`:
`lock wait`, then `push` — it never consults `$FAILED`, so the `SessionEnd`
push always tries. `push-if-changed`, in this order: `changed || exit 0`;
`cooling && exit 0` (silent — it fires after every tool call);
`lock nowait`; `changed || exit 0`; `push`. Rewrite the comment at `:111`: it
no longer waits for a push in flight; the second `changed` covers the case
where the lock was free because another push had just finished and already
sent this edit.

**S1.11 — `delete` mode.** New `case` arm before `*)` (`:116`). Mechanism:

1. `rel=${2:-}` — a path relative to `$ROOT`, which is also the key suffix
   under `$URI`. Used byte for byte; never trimmed or rewritten.
2. Validate, calling nothing: `"/$rel/"` must match `/*/memory/*/` and must not
   match `*/../*`, `*/./*` or `*//*`; `$ROOT/$rel` must not be a directory.
   Otherwise log the "expected …; nothing removed" line and `exit 0`.
3. `lock wait`.
4. **Remote first:**
   `bounded aws s3 rm "$URI/$rel" ${extra[@]+"${extra[@]}"} --only-show-errors`.
5. Only if step 4 returned 0: `rm -f -- "$STAGE/$rel" "$ROOT/$rel"`, then log
   `delete ok: <rel>`.
6. If step 4 failed: log the "remote copy not removed; local copy left in
   place" line. Nothing local is touched.

Comment the ordering: a local-first delete whose remote half fails is exactly
the resurrection this mode exists to stop. `delete` does not read or write
`$STAMP` or `$FAILED`.

State transitions for `delete p/memory/x.md`:

| | remote | stage | local | 
|---|---|---|---|
| before | present (or absent) | present (or absent) | present (or absent) |
| after success | absent (a delete marker, if versioning is on) | absent | absent |
| after remote failure | unchanged | unchanged | unchanged |
| bad argument | unchanged, `aws` never called | unchanged | unchanged |

**S1.12 — header and usage.** `:5-9`: add
`memory-sync.sh delete <project>/memory/<file>` with a two-line description
(removes the bucket object, then the stage and local copies; the only mode that
deletes; run by hand). `:116`: usage string per the table above. Correct the
`pull` line (`:5`) to mention it is staged and never restores a file removed
from the bucket.

**S1.13 — add the test.** `mkdir tests`, then
`cp plan/bug-reviewer-findings/memory-sync.test.sh tests/memory-sync.test.sh`
and `chmod 755 tests/memory-sync.test.sh` — **byte for byte**. The copy in `plan/`
stays. If a case fails, fix `memory-sync.sh`, not the test; if the developer
believes a case is wrong, stop and report — do not edit it.

### `skills/sync-memory/SKILL.md`

The `<bucket>` placeholders at `:77` and `:86` stay placeholders; the one at
`:43` disappears with the command S1.20 replaces. **Hook event names
(`SessionStart`, `SessionEnd`, `PostToolUse`, `Stop`) are written only in the
text of S1.15 and S1.21** — nowhere else in this file; P1.6 counts them.

**S1.14** — `:3-4` (the description is one folded YAML value across both
lines). On `:3`, anchor `to or from S3 (RustFS)`: → `to or from S3 or an
S3-compatible store`. On `:4`, anchor `from bucket versioning`: insert
`, delete a memory everywhere` directly after those words.

**S1.15** — `:12-13`, anchor `Two hooks in`. Replace the sentence with:

> Four hook events in `~/.claude/settings.json` run it automatically: `SessionStart` pulls, `SessionEnd` pushes, and `PostToolUse` and `Stop` run `push-if-changed`, so an edited memory reaches S3 within seconds.

**S1.16** — `:18-21`, the Arguments list. Insert these two bullets after the
`pull` bullet, verbatim:

> - `push-if-changed` — what the hooks run: pushes only when a memory file is newer than the last successful push. It skips while another sync holds the lock, and for 5 minutes after a failed push.
> - `delete <project>/memory/<file>` — removes one memory from the bucket, the stage and this machine. See *Deleting a memory*.

and append to the last bullet (anchor `report configuration and drift, change nothing.`)
the sentence: `This is a procedure in this skill, not a mode of the script.`

**S1.17** — `:25-26`, anchor `it never deletes on`. Replace the sentence with:

> It is safe to run at any time: `pull` and `push` never delete a memory on either side, only `delete` does, and it exits 0 even on failure so it can never break a session.

**S1.18** — `:32`, anchor `` `push ok` / `pull ok` means the transfer completed; ``: replace
those words with
`` `push ok`, `push-if-changed ok`, `pull ok` or `delete ok: <path>` means it completed; ``.

**S1.19** — `:40-42`, anchor `skips silently by design`. Replace "the script
skips silently by design" with: "the script logs `CLAUDE_MEMORY_S3_URI is not
set; skipping` and exits 0".

**S1.20** — `:43-49`, status items 2 and 3. Item 2 command becomes
`aws s3 ls "$CLAUDE_MEMORY_S3_URI/" $CLAUDE_MEMORY_S3_ARGS`; reword the STS
sentence (`:45-46`) to: "Do not reach for `aws sts get-caller-identity` — some
S3-compatible stores, RustFS among them, do not implement STS, so it fails even
when the credentials are perfect." Item 3 becomes: the push direction is
`aws s3 sync ~/.claude/projects/ "$CLAUDE_MEMORY_S3_URI/" --exclude '*' --include '*/memory/*' $CLAUDE_MEMORY_S3_ARGS --dryrun`;
for the pull direction say that pull downloads into `~/.claude/.memory-sync-stage`
and then copies only files that are missing locally or newer in S3, so a direct
S3-to-local dry run overstates what a pull would change. Add one sentence:
without `$CLAUDE_MEMORY_S3_ARGS` these commands talk to AWS itself, not to the
configured endpoint.

**S1.21** — `:50-51`, anchor `` should show ``: list all four events —
`SessionStart`, `SessionEnd`, `PostToolUse`, `Stop`.

**S1.22** — `:59-67`, the Conflicts section. Replace the first paragraph
(`:61-64`) with text stating, in this order: a push overwrites the remote
object when the local file differs — no merge; a pull never overwrites a local
file that is newer than the remote copy; syncs on one machine are serialised by
a lock file; **there is no lock across machines**, so two machines editing the
same memory between syncs means the later push wins in the bucket. Keep the
last sentence of `:63-64` ("If the user works from several machines at once,
say this plainly…") unchanged. In the paragraph at `:66-67` replace
`What makes that survivable is versioning, below:` with
`What makes that survivable is bucket versioning, when it is enabled (below):`
so that this file states versioning one way only (see S1.24).

**S1.23** — new section `## Deleting a memory`, inserted before
`## Recovering an earlier version` (`:69`). It must state: the command
`~/.claude/memory-sync.sh delete <project>/memory/<file>`; that it removes the
bucket object first and the stage and local copies only if that succeeded;
that plain `rm` is not enough — the next pull brings the file back; **confirm
the exact path with the user before running it**; that another machine which
still has the file will upload it again on its next push, so run `delete`
there too; and that with versioning enabled the content stays recoverable as an
earlier version (next section).

**S1.24** — `:71`. Replace the **whole first sentence** of the line
(`The bucket has versioning enabled, so every overwrite keeps the previous content.`)
with: `When the bucket has versioning enabled, every overwrite and every delete keeps the previous content. Check that it is before relying on this.`
The second sentence of `:71-72` ("A memory that was clobbered…") is unchanged.

**S1.25** — `:77-79` and `:86-88`. Append ` $CLAUDE_MEMORY_S3_ARGS` to both
`aws s3api` commands and change both key paths from
`projects/<project-dir>/memory/<file>.md` to
`<prefix>/<project-dir>/memory/<file>.md`; add one line under the first block:
"`<prefix>` is the path part of `CLAUDE_MEMORY_S3_URI`; the key is that prefix
plus the file's path under `~/.claude/projects/`." Then `:95`, anchor
`Two RustFS quirks to expect:` → `Two quirks seen on RustFS — other stores may differ:`
and `:97` `returns an empty response here` → `returns an empty response on RustFS`.
Both bullets otherwise unchanged.

### Slice 1 post-conditions

Run from the repo root. The block is copy-ready: every `|` is a real pipe or a
real alternation. Each check is tagged with whether it can tell a finished tree
from an unfinished one.

```sh
# P1.1  [weak — syntax only; the script already passes at baseline]
for s in memory-sync.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
#   expect: memory-sync.sh rc=0
#           tests/memory-sync.test.sh rc=0

# P1.2  [discriminates — baseline rc=1, SC2015 at memory-sync.sh:70]
shellcheck memory-sync.sh tests/memory-sync.test.sh; echo "rc=$?"
#   expect: rc=0        (and no other line)

# P1.3  [discriminates — baseline 1]
/usr/bin/grep -c 'shellcheck disable' memory-sync.sh
#   expect: 0

# P1.4  [discriminates for 21 cases; T01, T06, T23 pass at baseline — regression guards]
TMPDIR=/data/tmp/claude bash tests/memory-sync.test.sh memory-sync.sh
#   expect: 24 lines "ok T01 …" to "ok T24 …" in order, then: PASS 24/24

# P1.5  [discriminates]
cmp tests/memory-sync.test.sh plan/bug-reviewer-findings/memory-sync.test.sh; echo "rc=$?"; stat -c %a tests/memory-sync.test.sh
#   expect: rc=0
#           755

# P1.6  [discriminates — baseline has only SessionEnd 2, SessionStart 2]
/usr/bin/grep -o -E 'SessionStart|SessionEnd|PostToolUse|Stop' skills/sync-memory/SKILL.md | sort | uniq -c
#   expect:       2 PostToolUse
#                 2 SessionEnd
#                 2 SessionStart
#                 2 Stop

# P1.7  [discriminates — baseline 0]
/usr/bin/grep -o -F '$CLAUDE_MEMORY_S3_ARGS' skills/sync-memory/SKILL.md | wc -l
#   expect: 5       (S1.20: two commands and one sentence; S1.25: two commands)

# P1.8  [discriminates — baseline 0]
/usr/bin/grep -c -x '## Deleting a memory' skills/sync-memory/SKILL.md
#   expect: 1

# P1.9  [ABSENCE CHECK — also passes if the sentences were simply deleted; read with P1.6-P1.8, P1.11. Baseline: 8 lines]
/usr/bin/grep -n -E 'skips silently|Two hooks|There is no locking|\(RustFS\)|projects/<project-dir>|The bucket has versioning enabled|Two RustFS quirks' skills/sync-memory/SKILL.md; echo "rc=$?"
#   expect: rc=1        (and no other line)

# P1.10 [discriminates — baseline 3]
/usr/bin/grep -c -F '<bucket>' skills/sync-memory/SKILL.md
#   expect: 2

# P1.11 [discriminates — every count is 0 at baseline; one positive probe per skill step]
while IFS= read -r p; do printf '%s: ' "$p"; /usr/bin/grep -c -F -e "$p" skills/sync-memory/SKILL.md; done <<'PROBES'
S3 or an S3-compatible store
delete a memory everywhere
- `push-if-changed` — what the hooks run
- `delete <project>/memory/<file>` — removes one memory
a procedure in this skill, not a mode of the script
only `delete` does
or `delete ok: <path>` means it completed
is not set; skipping` and exits 0
no lock across machines
bucket versioning, when it is enabled
When the bucket has versioning enabled, every overwrite and every delete
Two quirks seen on RustFS
empty response on RustFS
PROBES
#   expect: 13 lines, each ending ": 1"
#   covers: S1.14 (2), S1.16 (3), S1.17, S1.18, S1.19, S1.22 (2), S1.24, S1.25 (2)
```

S1.22 must contain the literal words `no lock across machines`; all probe
phrases stay on one line.

### Slice 1 coverage — which case covers which step (Q11)

No tool measures coverage for bash, so it is reported as this list. The
developer's `result.md` reproduces it with the actual results.

| step | covered by | not discriminated, and why it is accepted |
|---|---|---|
| S1.1 | T19 (default 12), T20 (`abc`, `0`, `08`, `-3`) | the *position* of the validation relative to `log()` is covered indirectly: misplaced, T20's log line is missing and P1.2 reports SC2218 |
| S1.2 | T16 (cut-off, status 124), T19 (`-k 2`), T21 (shared limit), T22 (TERM ignored → status 137, ends within limit + 3 s) | the "limit already spent, command not started" branch: reaching it needs more than `TIMEOUT` seconds of local work before a transfer; accepted, the branch is three lines |
| S1.3 | T13 | — |
| S1.4 | T14 (each of the four tools removed in turn) | the header sentence about Linux — prose, read in review |
| S1.5 | T12 | the `${extra[@]+…}` guard: an empty array under `set -u` cannot fail on bash ≥ 4.4, so nothing run here can tell the guard from its absence; accepted (Q6) |
| S1.6 | T05 (`--delete` is passed through), T01 | the rewritten comment — read in review |
| S1.7 | T05, T15, T18 | — |
| S1.8 | T07, T08 (4 min holds, 6 min retries), T09 | — |
| S1.9 | T10 (non-blocking), T11 (open failure), T18, T21, T24 (blocking) | — |
| S1.10 | T07, T09, T10, T21, T23 | — |
| S1.11 | T02, T03, T04 (nine bad arguments, incl. `./` and a directory), T24 | "remote first" ordering is covered by T03 only in the failure direction — sufficient: a local-first delete fails T03 |
| S1.12 | T17 | the header text — read in review. T17 matches the literal name `memory-sync.sh` in the usage line, so the script must be invoked under that name, as every command in this plan does |
| S1.13 | P1.5 | — |
| all | every `run` asserts rc 0 and empty stdout | every comment edit named in "Conventions" — no command can tell a kept comment from a dropped one; the reviewer reads the diff |

## Slice 2 — cross-file consistency (15 steps; S2.7 and S2.12 withdrawn)

**File boundary:** `agents/reviewer.md`, `agents/committer.md`,
`agents/developer.md`, `agents/analyzer.md`, `commands/{analyze,commit,develop,integrate,plan,review,ship}.md`
and `manager-bootstrap.sh` — nothing else. `skills/manager/SKILL.md` and
`skills/bootstrap/SKILL.md` already say three review rounds (`manager:102`,
`:148`, `:297`; `bootstrap:87`) and are **not edited** in this slice.

**Review cap = 3**

- **S2.1** — `agents/reviewer.md:90`: `four rounds` → `three rounds`.
- **S2.2** — `agents/reviewer.md:92`: `**four rounds**` → `**three rounds**`;
  `By round four` → `By round three`; `there is no round five` →
  `there is no round four`.
- **S2.3** — `agents/reviewer.md:98`: `At round four` → `At round three`.
- **S2.4** — `commands/ship.md:32`: `**Four rounds, then a decision.**` →
  `**Three rounds, then a decision.**`; `By round four` → `By round three`;
  `there is no round five` → `there is no round four`. (`ship.md:6`
  "Four steps, in order" is about steps, not rounds — leave it.)

**Skill names and the duplicate**

- **S2.5** — `agents/reviewer.md:15`: `` `guardrails` and `preserve-comments` ``
  → `` `security` and `comments` ``. Rest of the line unchanged.
- **S2.6** — `agents/committer.md:37`, the plain bullet
  `- files the caller did not ask about, even when they are dirty`: delete this
  one line. The bold bullet at `:36` stays.

**Missing `AGENTS.md` → fall back (Q7)**

One rule, both halves, everywhere: *read `CLAUDE.md` instead* **and** *say
there is no working agreement*. Files that only name `AGENTS.md` get the same
literal, `` (or `CLAUDE.md` if the repo has none — say so) ``. The two agents
whose step 1 calls `AGENTS.md` "the source of truth" get the rule in their own
"No `AGENTS.md`" paragraph instead, so that `CLAUDE.md` is never described as a
rule set.

- **S2.7** — *withdrawn in revision 2.* `agents/reviewer.md:11` is **not
  edited**; the fallback lives wholly in S2.8.
- **S2.8** — `agents/reviewer.md:13`, anchor ``**No `AGENTS.md` → `BLOCK: target unresolved`.**``.
  Replace the whole paragraph with:

  > **No `AGENTS.md` → read `CLAUDE.md` instead, say plainly that the repo has no working agreement, and review for correctness only.** `CLAUDE.md` is context, not a rule set to review against. Do not invent rules and do not import another project's: skip the compliance pass in step 3, give every finding `rule: correctness`, and put the line `agreement: no AGENTS.md — correctness only` directly above the verdict line.

- **S2.9** — `agents/reviewer.md:55`: `— AGENTS.md requires this explicitly.` →
  `— whether or not the working agreement says so.`
- **S2.10** — `agents/reviewer.md:57`: after `**Then AGENTS.md compliance.**`
  insert the sentence `` Skip this pass when the repo has no `AGENTS.md`. ``
- **S2.11** — `agents/reviewer.md:86`, anchor `End with one verdict line:`.
  Append to that paragraph:

  > When the repo has no `AGENTS.md`, the line directly above the verdict is `agreement: no AGENTS.md — correctness only`. The verdict line itself never changes, so a caller that matches it whole still works.

  Mechanism (accepted by the user, Q7 clarified): the statement is a separate
  line, not a suffix, because `commands/ship.md:22` matches the verdict whole
  and a suffixed `SHIP` would be treated as a block.
- **S2.12** — *withdrawn in revision 2.* `agents/committer.md:11` is **not
  edited**; the fallback lives wholly in S2.13.
- **S2.13** — `agents/committer.md:13`, anchor ``**No `AGENTS.md` → stop and say so.**``.
  Replace the whole paragraph with:

  > **No `AGENTS.md` → read `CLAUDE.md` instead, say plainly that the repo has no working agreement, and use Conventional Commits.** `type(scope): subject`, types `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`; take the scope vocabulary and body style from the `git log` in step 2. A missing agreement is a fact to put in the report, not a reason to refuse.

- **S2.14** — `agents/committer.md:45`: `come from AGENTS.md.` →
  `come from AGENTS.md, or from the step 1 fallback when there is none.`
- **S2.15** — the nine files that name `AGENTS.md` without the full rule. In
  each, the result must contain the literal
  `` (or `CLAUDE.md` if the repo has none — say so) ``:

  | file:line | before | after |
  |---|---|---|
  | `agents/developer.md:15` | `` - `AGENTS.md` — the working `` | `` - `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so) — the working `` |
  | `agents/analyzer.md:18` | `` - `AGENTS.md` — only enough `` | `` - `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so) — only enough `` |
  | `commands/analyze.md:6` | ``Read `AGENTS.md`, then use`` | ``Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then use`` |
  | `commands/commit.md:6` | `repo root first — the` | ``repo root first (or `CLAUDE.md` if the repo has none — say so) — the`` |
  | `commands/develop.md:6` | ``Read `AGENTS.md`, then `plan/`` | ``Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then `plan/`` |
  | `commands/integrate.md:6` | ``(or `CLAUDE.md` if the repo has none)`` | ``(or `CLAUDE.md` if the repo has none — say so)`` |
  | `commands/plan.md:6` | ``Read `AGENTS.md`, then follow`` | ``Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then follow`` |
  | `commands/review.md:6` | `repo root first. The reviewer` | ``repo root first (or `CLAUDE.md` if the repo has none — say so). The reviewer`` |
  | `commands/ship.md:10` | `repo root before anything else. Both` | ``repo root (or `CLAUDE.md` if the repo has none — say so) before anything else. Both`` |

  Left as they are, already stating both halves in their own words:
  `agents/integrator.md:11`, `CLAUDE.md:14-15`, `manager-bootstrap.sh:9`,
  `skills/bootstrap/SKILL.md:20-22`, `skills/manager/SKILL.md:16`.

**`manager-bootstrap.sh` (Q10)**

- **S2.16** — two edits in one step. `:11`, anchor `2. Load two skills now`: →
  ``2. Load the `bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:``
  And the header comment at `:2`, anchor `makes the manager and security skills a requirement of every`:
  → `makes the bootstrap, manager and security skills a requirement of every`
  (the comment must stay true of the text it describes).
- **S2.17** — `:15`, anchor `AND carries the`: →
  ``3. Every agent you dispatch reads `AGENTS.md` first AND carries the `security` and `comments` disciplines. Say all of it in the dispatch message.``

### Slice 2 post-conditions

Run from the repo root. The block is copy-ready: every `|` is a real pipe or a
real alternation. Each check is tagged with whether it can tell a finished tree
from an unfinished one.

```sh
# P2.1  [ABSENCE CHECK — read with P2.2. Baseline: agents/reviewer.md:3, commands/ship.md:1]
/usr/bin/grep -c -i -E 'four rounds|round five|By round four|At round four' agents/reviewer.md commands/ship.md
#   expect: agents/reviewer.md:0
#           commands/ship.md:0

# P2.2  [discriminates — baseline prints nothing]
/usr/bin/grep -o -i -E 'three rounds|round three|no round four' agents/reviewer.md commands/ship.md | sort | uniq -c
#   expect:       1 agents/reviewer.md:no round four
#                 2 agents/reviewer.md:round three
#                 2 agents/reviewer.md:three rounds
#                 1 commands/ship.md:Three rounds
#                 1 commands/ship.md:no round four
#                 1 commands/ship.md:round three

# P2.3  [ABSENCE CHECK — read with P2.4. Baseline: agents/reviewer.md:15]
/usr/bin/grep -rn -E 'guardrails|preserve-comments' agents commands skills CLAUDE.md README.md manager-bootstrap.sh; echo "rc=$?"
#   expect: rc=1        (and no other line)

# P2.4  [discriminates — baseline 0]
/usr/bin/grep -c -F 'ships `security` and `comments` skills' agents/reviewer.md
#   expect: 1

# P2.5  [discriminates — baseline 2; 0 would mean both bullets were deleted]
/usr/bin/grep -c -i 'files the caller did not ask about' agents/committer.md
#   expect: 1

# P2.6  [discriminates — baseline prints nothing]
/usr/bin/grep -l -F '`CLAUDE.md` if the repo has none — say so' agents/*.md commands/*.md
#   expect: agents/analyzer.md
#           agents/developer.md
#           commands/analyze.md
#           commands/commit.md
#           commands/develop.md
#           commands/integrate.md
#           commands/plan.md
#           commands/review.md
#           commands/ship.md

# P2.7  [discriminates — baseline 0]
/usr/bin/grep -c -F 'agreement: no AGENTS.md — correctness only' agents/reviewer.md
#   expect: 2

# P2.8  [ABSENCE CHECK — read with P2.12. Baseline: reviewer.md:13, reviewer.md:55, committer.md:13]
/usr/bin/grep -n -E 'Every repo here|problem to report, not a gap|requires this explicitly' agents/reviewer.md agents/committer.md; echo "rc=$?"
#   expect: rc=1        (and no other line)

# P2.9  [discriminates — baseline 0]
/usr/bin/grep -c -F -e '`bootstrap` skill first' -e '`security` and `comments` disciplines' -e 'makes the bootstrap, manager and security skills' manager-bootstrap.sh
#   expect: 3

# P2.10 [weak — the file is clean at baseline]
bash -n manager-bootstrap.sh; echo "rc=$?"; shellcheck manager-bootstrap.sh; echo "rc=$?"
#   expect: rc=0
#           rc=0

# P2.11 [NOT DISCRIMINATING — passes at baseline; regression guard that the heredoc edit left valid hook output]
bash manager-bootstrap.sh | jq -r '.hookSpecificOutput.hookEventName'
#   expect: SessionStart

# P2.12 [discriminates — every count is 0 at baseline; positive probes for S2.8, S2.9, S2.10, S2.13, S2.14]
while IFS= read -r p; do printf '%s: ' "$p"; /usr/bin/grep -c -F -e "$p" agents/reviewer.md agents/committer.md | tr '\n' ' '; echo; done <<'PROBES'
say plainly that the repo has no working agreement, and review for correctness only
whether or not the working agreement says so
Skip this pass when the repo has no `AGENTS.md`
say plainly that the repo has no working agreement, and use Conventional Commits
types `feat`, `fix`, `refactor`
or from the step 1 fallback when there is none
PROBES
#   expect: first three lines end "agents/reviewer.md:1 agents/committer.md:0"
#           last three lines end  "agents/reviewer.md:0 agents/committer.md:1"
```

## Slice 3 — machine- and project-specific text (14 steps)

**File boundary:** `CLAUDE.md`, `skills/bootstrap/SKILL.md`, the new
`host.example.md`, and one line each in `agents/analyzer.md`,
`agents/reviewer.md`, `commands/develop.md` — nothing else. Starts after slice 2.

**Mechanism (Q4):** facts true of one machine move to a per-host file,
`~/.claude/host.md`, which is never shipped. The repo ships `host.example.md`
holding the author's host in full, so no recorded lesson is lost. `bootstrap`
step 6 and the root `CLAUDE.md` tell a session to read `~/.claude/host.md` and
what to do when it does not exist.

- **S3.1** — create `host.example.md` at the repo root with exactly:

  ```markdown
  # Host file — example

  Copy this to `~/.claude/host.md` and edit it. It is never shipped: it holds
  facts that are true of one machine only. `bootstrap` step 6 reads it at
  session start.

  What follows is the author's host, kept in full because each line is a lesson.

  ## Temp files

  **Temp files go in `/data/tmp/claude`, never `/tmp`** — `/data` is a dedicated disk. `/tmp` here is a tmpfs
  under a **per-user quota shared by every agent**. Exhausting it returns `EDQUOT`
  on every write and takes the Bash tool down with it — the harness writes its own
  task output under `/tmp/claude-<uid>/`, so a full `/tmp` is not a slow session,
  it is a dead one, and it cannot be repaired from inside that session. Growing
  the tmpfs does not help: `size=` is the filesystem, `usrquota` is the per-user
  cut of it. `export TMPDIR=/data/tmp/claude` before any `go` command, use unique
  filenames, clean up what you create, **and say all of this in every dispatch
  message** so subagents do the same.

  ## Tool paths

  The system grep is `/usr/bin/grep`.
  ```

  The temp paragraph is `skills/bootstrap/SKILL.md:117-125` moved verbatim, with
  one correction: `/tmp/claude-1000/` → `/tmp/claude-<uid>/` (the uid on the
  author's host is 1001, findings §5).

- **S3.2** — `CLAUDE.md:4`: `the tooling hazards on this machine that return`
  → `the tooling hazards that return`.
- **S3.3** — `CLAUDE.md:19-25`, the bullet beginning
  ``- **Temporary files go in `/data/tmp/claude` ``. Replace the whole bullet with:

  > - **Temporary files go where `~/.claude/host.md` says.** That file belongs to
  >   the machine — temp directory, tool paths, anything true of one host only.
  >   Read it before the first command, repeat its temp-file rule in every
  >   dispatch message, use unique filenames, and clean up what you create. No
  >   `host.md` → say the machine has no host file, then use `$TMPDIR` if it is
  >   set and the session's scratchpad directory otherwise — and keep temp files
  >   few and small, because that fallback may itself sit on a small `/tmp`.
  >   `bootstrap` step 6 explains why this matters.

- **S3.4** — `skills/bootstrap/SKILL.md:3` (description): `in any session on this machine`
  → `in any session`; `wrong answers here.` → `wrong answers.`
- **S3.5** — `bootstrap:65`: `In this backend,` → `In one backend,`.
- **S3.6** — `bootstrap:108`: `a handoff in this repo asserted` →
  `a handoff in one repo asserted`.
- **S3.7** — `bootstrap:114`: `on this machine.` → `in a real session.`
- **S3.8** — `bootstrap:117-125`, the paragraph beginning
  ``**Temp files go in `/data/tmp/claude` ``. Replace the whole paragraph with:

  > **Read `~/.claude/host.md` before the first command.** Facts true of one
  > machine — where temp files go, which path is the system `grep` — live there,
  > not in this skill. Say its temp-file rule in every dispatch message so
  > subagents follow it too, use unique filenames, and clean up what you create.
  > No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is
  > set and the session's scratchpad directory otherwise — and keep temp files few
  > and small, because that fallback may itself sit on a small `/tmp`. Why this is
  > a hazard at all: on one host `/tmp` was a tmpfs under a per-user quota shared
  > by every agent, and filling it killed the session from the inside. The file
  > `host.example.md` in the skills repo keeps that case in full.

  The fallback cannot be made safe from inside the skill — without a host file
  nothing knows where a safe directory is. The ordering that prevents it
  ("create `host.md` before installing") is in the README, S4.3.

- **S3.9** — `bootstrap:127-132`, the paragraph beginning
  ``**`grep` is ugrep, not GNU grep.**``. Replace the whole paragraph with:

  > **In Claude Code's Bash tool, `grep` can be a shell function that runs a bundled ugrep, not the system grep** —
  > `type grep` shows which. The two do not agree. `-E 'foo[\s]bar'` matched
  > `foo bar` under the function and nothing under GNU grep, where `\s` inside a
  > bracket expression means the literal `\` and `s`. The function has also been
  > observed returning **zero matches with no error** for an `-E` pattern
  > beginning with an alternation group. One of these differences silently
  > excluded `golang.org/x/tools` from a dependency audit. Use **`command grep`**,
  > which bypasses the function, for anything load-bearing, and confirm a pattern
  > matches something you *know* exists before trusting it to prove an absence.

  (Planner-run: `command grep -c -E 'foo[\s]bar'` on `foo bar` → `0`; the
  function → `1`. The alternation sentence is kept as an observation because it
  did not reproduce — findings §5.)
- **S3.10** — `bootstrap:134`: insert a new paragraph immediately **before**
  ``**A receiver name in a Go grep silently undercounts.**``:

  > *The next four come from one Go and PostgreSQL project. The trap in each is general; the commands are that project's.*

  The four paragraphs themselves (`:134-160`) are otherwise unchanged except S3.11.
- **S3.11** — `bootstrap:157`: `Measured here:` → `Measured in one repo:`.
- **S3.12** — `bootstrap:173`: `leaked one here.` → `leaked one.`
- **S3.13** — `agents/analyzer.md:48`: `` `make lint` in this repo is `lint: mock` ``
  → `` in one repo `make lint` is `lint: mock` ``; and
  `agents/reviewer.md:73`: `` and `go build` proves nothing about it `` →
  `and a compiler proves nothing about it`.
- **S3.14** — `commands/develop.md:14`:
  `These files have no single convention in this repo, so` →
  `These files have no single convention, so`.

**Explicitly not changed, with the reason** (so the analyzer does not report
them missing): `bootstrap:9` ("this environment" — means the working setup, not
a host); `bootstrap:61-63` and `skills/security/SKILL.md:45` (`go test` as an
illustration of a general rule); `bootstrap:145-156` beyond S3.10;
`skills/manager/SKILL.md:106` ("this repo" = the repo being worked in),
`:183-219` (anecdotes already worded as "a real case" / "one plan"), `:263-265`
(test rules — universal, per the Q4 answer); every `here` that means "in this
file" (`commands/*.md`, `agents/developer.md:94`, `agents/analyzer.md:69`).

### Slice 3 post-conditions

Run from the repo root. The block is copy-ready: every `|` is a real pipe or a
real alternation. Each check is tagged with whether it can tell a finished tree
from an unfinished one.

```sh
# P3.1  [ABSENCE CHECK — also passes if the paragraphs were simply deleted; read with P3.2-P3.4. Baseline: 15 lines]
/usr/bin/grep -n -E 'this machine|this backend|in this repo|/data/|claude-1000|/usr/bin/grep|Measured here|one here' skills/bootstrap/SKILL.md CLAUDE.md agents/analyzer.md commands/develop.md; echo "rc=$?"
#   expect: rc=1        (and no other line)

# P3.2  [discriminates for the first seven probes (0 at baseline).
#        The last two are 1 at baseline too: SURVIVAL GUARDS — they fail only if S3.8/S3.9 deleted the lesson]
while IFS= read -r p; do printf '%s: ' "$p"; /usr/bin/grep -c -F -e "$p" skills/bootstrap/SKILL.md; done <<'PROBES'
In one backend
a handoff in one repo
in a real session
command grep
one Go and PostgreSQL project
Measured in one repo
observed returning
golang.org/x/tools
per-user quota
PROBES
#   expect: 9 lines, each ending ": 1"

# P3.3  [discriminates — baseline 0 and 0]
for f in CLAUDE.md skills/bootstrap/SKILL.md; do printf '%s: ' "$f"; /usr/bin/grep -o -F 'host.md' "$f" | wc -l; done
#   expect: CLAUDE.md: 2
#           skills/bootstrap/SKILL.md: 2

# P3.4  [discriminates — the file does not exist at baseline]
/usr/bin/grep -c -F -e '/data/tmp/claude' -e 'claude-<uid>' -e '/usr/bin/grep' -e 'EDQUOT' host.example.md
#   expect: 5

# P3.5  [discriminates — each 0 at baseline]
/usr/bin/grep -c -F 'in one repo `make lint` is' agents/analyzer.md; /usr/bin/grep -c -F 'a compiler proves nothing' agents/reviewer.md; /usr/bin/grep -c -F 'no single convention, so' commands/develop.md
#   expect: 1
#           1
#           1

# P3.6  [NOT DISCRIMINATING — empty at baseline too; an invariant that fails only if an out-of-scope skill
#        was edited, and blind to untracked files (A2 covers those)]
git diff --stat -- skills/manager skills/security skills/plan-first skills/comments skills/audit
#   expect: no output
```

## Slice 4 — repo scaffolding (3 steps; S4.4 and S4.5 folded into S4.3)

**File boundary:** new `AGENTS.md`, new `settings.example.json`, and
`README.md` — nothing else. Runs last.

- **S4.1** — create `AGENTS.md` at the repo root with exactly:

  ```markdown
  # Working agreement

  This repo is the source for a global Claude Code setup. Everything the README
  lists under **Installed to `~/.claude`** is **payload**: it is written for
  `~/.claude` on some machine, not for this repo. That includes the root
  `CLAUDE.md` — when it and this file disagree about how to work *in this
  repo*, this file wins.

  ## Gates

  The test creates its work directory under `$TMPDIR`. Export `TMPDIR` to the
  temp directory your host file names first, then run all three, in order, and
  paste what they print:

      for s in memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
      shellcheck memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
      bash tests/memory-sync.test.sh memory-sync.sh

  Green is: three `rc=0` lines; `rc=0` with no findings; every line `ok`, last
  line `PASS n/n`.

  The Markdown files have no gate. A change to one is verified by running the
  commands it prescribes in a throwaway directory and by the searches its plan
  names.

  ## Tests

  This section is a scoped exception to any general rule against hand-written
  fakes and to any coverage percentage. It applies to the shell scripts in this
  repo and to nothing else.

  - **A stub executable placed first on `PATH` is the allowed way to fake an
    external CLI** such as `aws`. `tests/memory-sync.test.sh` does this.
  - **Coverage is reported as a list, not a number.** No tool measures it for
    bash. For each plan step, name the test cases that cover it; name each
    change no case covers, and why that is accepted.

  ## Rules

  - **No secrets.** No bucket name, endpoint, profile name or environment value
    in any file, commit message or report. Use `<bucket>`, `<prefix>`,
    `<profile>`.
  - **Never run `memory-sync.sh` against a real backend from this repo.** Use
    the stub in `tests/memory-sync.test.sh`.
  - **Nothing is copied into `~/.claude` by an agent.** Installing is the
    user's step.
  - **The hook contract of `memory-sync.sh` does not change without a plan:**
    the mode names, exit 0 on every path, nothing on stdout, messages on stderr.
  - **One fact, one value.** A number or name stated in more than one file
    changes in all of them in the same commit. Known cases: the review round cap
    (`agents/reviewer.md`, `commands/ship.md`, `skills/manager/SKILL.md`,
    `skills/bootstrap/SKILL.md`); the missing-`AGENTS.md` fallback (every agent
    and command); the hook events (`settings.example.json`, `README.md`,
    `skills/sync-memory/SKILL.md`, the header of `memory-sync.sh`); the default
    time limit of `memory-sync.sh` (the script, its test, `README.md`).
  - **Comments and recorded incidents are kept.** Update them when the thing
    they describe changes; do not delete them.
  - **Tests clean up by PID.** A test kills only processes it started itself,
    never by name or pattern.
  - `plan/` is tracked and permanent.

  ## Commits

  Conventional Commits: `type(scope): subject`, imperative subject, optional
  body of short bullets. Types `feat`, `fix`, `refactor`, `perf`, `test`,
  `docs`, `build`, `ci`, `chore`. Scope is optional; when used it is the area —
  `sync`, `agents`, `commands`, `skills`, `repo`. One logical change per commit.
  ```

  `skills/manager/SKILL.md` is not edited (Q11): the exception lives here only.

- **S4.2** — create `settings.example.json` at the repo root with exactly:

  ```json
  {
    "env": {
      "CLAUDE_MEMORY_S3_URI": "s3://<bucket>/<prefix>",
      "AWS_PROFILE": "<profile>",
      "CLAUDE_MEMORY_S3_ARGS": "<extra aws arguments, or delete this key>"
    },
    "hooks": {
      "SessionStart": [
        {
          "hooks": [
            { "type": "command", "command": "~/.claude/memory-sync.sh pull", "timeout": 20 },
            { "type": "command", "command": "~/.claude/manager-bootstrap.sh", "timeout": 5 }
          ]
        }
      ],
      "SessionEnd": [
        {
          "hooks": [
            { "type": "command", "command": "~/.claude/memory-sync.sh push", "timeout": 20 }
          ]
        }
      ],
      "PostToolUse": [
        {
          "matcher": "Write|Edit|MultiEdit|NotebookEdit|Bash",
          "hooks": [
            { "type": "command", "command": "~/.claude/memory-sync.sh push-if-changed", "timeout": 20 }
          ]
        }
      ],
      "Stop": [
        {
          "hooks": [
            { "type": "command", "command": "~/.claude/memory-sync.sh push-if-changed", "timeout": 20 }
          ]
        }
      ]
    }
  }
  ```

  `CLAUDE_MEMORY_S3_TIMEOUT` is deliberately absent: the script default (12 s,
  worst-case run 15 s) is the value that fits the 20 s hook timeouts. `delete` has no hook — it is
  run by hand — so it adds no wiring.

- **S4.3** — replace the whole of `README.md` with exactly the text below. The
  title, the opening paragraph, the six rows of the first table, the paragraph
  under it and the `cp` line are carried over unchanged from the baseline
  (`:1-4`, `:10-15`, `:17-18`, `:23`); everything else is new. The paragraph at
  baseline `:30-32` (machine-specific text) is replaced by install step 1 and
  the `host.example.md` row.

  ````markdown
  # skills

  Our global Claude Code setup: the skills, agents and slash commands that run
  every session, plus the global instructions and the two hook scripts they rely on.

  ## Installed to `~/.claude`

  Each path here installs to the same path under `~/.claude`.

  | Path | What it is |
  |---|---|
  | `skills/` | `bootstrap`, `manager`, `security`, `comments`, `plan-first`, `audit`, `sync-memory` |
  | `agents/` | `developer`, `analyzer`, `integrator`, `reviewer`, `committer` |
  | `commands/` | `/plan`, `/develop`, `/analyze`, `/integrate`, `/review`, `/commit`, `/push`, `/ship` |
  | `CLAUDE.md` | Global instructions — loads `bootstrap` first in every session |
  | `manager-bootstrap.sh` | `SessionStart` hook that injects the session bootstrap reminder |
  | `memory-sync.sh` | Hook script that syncs Claude Code memories to and from S3 |

  The skills, agents and commands are one set: `manager` dispatches the agents
  through the commands, and every agent carries `security` and `comments`.

  ## Repo only

  Not installed. These are for working on this repo and for setting up a machine.

  | Path | What it is |
  |---|---|
  | `AGENTS.md` | Working agreement for changes to this repo |
  | `settings.example.json` | Hook and environment wiring to merge into `~/.claude/settings.json` |
  | `host.example.md` | Template for the per-machine `~/.claude/host.md` |
  | `tests/` | Stub-based test for `memory-sync.sh` |
  | `plan/` | Planning records |

  The root `CLAUDE.md` is payload. Working on this repo itself is governed by `AGENTS.md`.

  ## Requirements

  Linux with bash, GNU coreutils (`timeout`, `stat`, `date`), util-linux `flock`, `rsync` and the AWS CLI.
  `jq` is optional: `manager-bootstrap.sh` falls back to plain text without it. macOS is not supported.

  ## Install

  1. **Create `~/.claude/host.md` from `host.example.md` first**, and edit it for
     the machine. Facts about one machine — the temp directory, tool paths — live
     there and nowhere in these files. Without it a session has no temp-directory
     rule and falls back to `$TMPDIR` or its scratchpad, which may be a small `/tmp`.
  2. Copy the payload:

     ```bash
     cp -a skills agents commands CLAUDE.md manager-bootstrap.sh memory-sync.sh ~/.claude/
     ```

     This overwrites files of the same name in `~/.claude`.
  3. Wire the hooks, below.

  ## Wiring

  `settings.json` is not shipped. Merge `settings.example.json` into
  `~/.claude/settings.json` and replace every `<…>` placeholder.

  | Event | Runs |
  |---|---|
  | `SessionStart` | `memory-sync.sh pull`, then `manager-bootstrap.sh` |
  | `SessionEnd` | `memory-sync.sh push` |
  | `PostToolUse` | `memory-sync.sh push-if-changed` |
  | `Stop` | `memory-sync.sh push-if-changed` |

  `CLAUDE_MEMORY_S3_TIMEOUT` is optional and defaults to 12 seconds. A run can
  last up to 3 seconds longer than that, so keep every hook timeout at least
  5 seconds above it.

  `memory-sync.sh delete <project>/memory/<file>` is run by hand, never from a
  hook. It is the only way to remove a memory for good — see the `sync-memory` skill.
  ````

- **S4.4** — *folded into S4.3 in revision 2* (the `## Requirements`,
  `## Install` and `## Wiring` sections above).
- **S4.5** — *folded into S4.3 in revision 2* (install step 1, the
  `host.example.md` row and the "root `CLAUDE.md` is payload" sentence).

**No `.gitignore` is added.** Reason: with a repo-only change and no symlink
install (Q1), nothing the repo's files do creates an untracked file inside the
clone — the test writes under `$TMPDIR` and removes it, and the script's state
files live under `~/.claude`. Recorded in follow-ups.

### Slice 4 post-conditions

Run from the repo root. The block is copy-ready: every `|` is a real pipe or a
real alternation. Each check is tagged with whether it can tell a finished tree
from an unfinished one.

```sh
# P4.1  [discriminates — the file does not exist at baseline]
jq -r '.hooks | to_entries[] | .key as $e | .value[] | .hooks[] | "\($e) \(.command) \(.timeout)"' settings.example.json
#   expect: SessionStart ~/.claude/memory-sync.sh pull 20
#           SessionStart ~/.claude/manager-bootstrap.sh 5
#           SessionEnd ~/.claude/memory-sync.sh push 20
#           PostToolUse ~/.claude/memory-sync.sh push-if-changed 20
#           Stop ~/.claude/memory-sync.sh push-if-changed 20

# P4.2  [discriminates]
jq -r '.env | keys[]' settings.example.json
#   expect: AWS_PROFILE
#           CLAUDE_MEMORY_S3_ARGS
#           CLAUDE_MEMORY_S3_URI

# P4.3  [ABSENCE CHECK — read with P4.2: every env value is a <placeholder>]
jq -r '.env | to_entries[] | select(.value | test("<") | not) | .key' settings.example.json; echo "rc=$?"
#   expect: rc=0        (and no key printed)

# P4.4  [discriminates]
/usr/bin/grep -E '^## ' AGENTS.md
#   expect: ## Gates
#           ## Tests
#           ## Rules
#           ## Commits

# P4.5  [discriminates — proves the agreement's own gates run as written]
#   export TMPDIR=/data/tmp/claude, then run the three commands under "## Gates" copied from AGENTS.md itself
#   expect: three "rc=0" lines; "rc=0"; "ok T01 …" to "ok T24 …", PASS 24/24

# P4.6  [discriminates — baseline: "## Install" only]
/usr/bin/grep -E '^## ' README.md
#   expect: ## Installed to `~/.claude`
#           ## Repo only
#           ## Requirements
#           ## Install
#           ## Wiring

# P4.7  [discriminates — baseline prints nothing]
/usr/bin/grep -o -E 'AGENTS\.md|settings\.example\.json|host\.example\.md|tests/|plan/' README.md | sort -u
#   expect: AGENTS.md
#           host.example.md
#           plan/
#           settings.example.json
#           tests/

# P4.8  [ABSENCE CHECK — read with P4.7, P4.9. Baseline: README.md:31]
/usr/bin/grep -n -E '/data/tmp|ugrep' README.md; echo "rc=$?"
#   expect: rc=1        (and no other line)

# P4.9  [discriminates — every count is 0 at baseline: the section TEXT is present, not only its heading]
while IFS= read -r p; do printf '%s: ' "$p"; /usr/bin/grep -c -F -e "$p" README.md AGENTS.md | tr '\n' ' '; echo; done <<'PROBES'
| `SessionStart` | `memory-sync.sh pull`, then `manager-bootstrap.sh` |
| `SessionEnd` | `memory-sync.sh push` |
| `PostToolUse` | `memory-sync.sh push-if-changed` |
| `Stop` | `memory-sync.sh push-if-changed` |
defaults to 12 seconds
`memory-sync.sh delete <project>/memory/<file>` is run by hand
util-linux `flock`, `rsync` and the AWS CLI
host.md` from `host.example.md` first
stub executable placed first on `PATH`
Coverage is reported as a list
PROBES
#   expect: first eight lines end "README.md:1 AGENTS.md:0"
#           last two lines end    "README.md:0 AGENTS.md:1"

# P4.10 [weak — the three places that state the default limit agree; T19/T20 are the real check]
/usr/bin/grep -c -F ':-12}' memory-sync.sh; /usr/bin/grep -c -F 'timeout -k 2 12 aws' tests/memory-sync.test.sh; /usr/bin/grep -c -F 'defaults to 12 seconds' README.md
#   expect: 1
#           2
#           1
```

---

# Phase 3 — after

## A1. Whole-tree gates (the manager runs these; an agent's word is not a gate)

```
for s in memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
  -> memory-sync.sh rc=0 / manager-bootstrap.sh rc=0 / tests/memory-sync.test.sh rc=0
shellcheck memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
  -> rc=0            (no finding lines; baseline was rc=1 on memory-sync.sh:70)
TMPDIR=/data/tmp/claude bash tests/memory-sync.test.sh memory-sync.sh
  -> ok T01 … ok T24, PASS 24/24
```

There is no lint or test for the Markdown files; their gates are the P-tables
above. Say so in the report rather than implying a prose gate exists.

## A2. Tree shape — named list, not a count

`git status --short -uall` must show exactly these and nothing else:

```
 M CLAUDE.md
 M README.md
 M agents/analyzer.md
 M agents/committer.md
 M agents/developer.md
 M agents/reviewer.md
 M commands/analyze.md
 M commands/commit.md
 M commands/develop.md
 M commands/integrate.md
 M commands/plan.md
 M commands/review.md
 M commands/ship.md
 M manager-bootstrap.sh
 M memory-sync.sh
 M skills/bootstrap/SKILL.md
 M skills/sync-memory/SKILL.md
?? AGENTS.md
?? host.example.md
?? settings.example.json
?? tests/memory-sync.test.sh
?? plan/bug-reviewer-findings/…   (planning files, plus result.md from /develop)
```

Not in the list and therefore untouched: `agents/integrator.md`,
`commands/push.md`, and the `audit`, `comments`,
`manager`, `plan-first`, `security` skills.

## A3. Secrets and leftovers

```sh
# A3.1 [named list — any other bucket shows up as an extra line. Baseline: the first two; s3://stub arrives with the test]
/usr/bin/grep -rhoE 's3://[^ "`/]*' --exclude-dir=.git --exclude-dir=plan . | sort -u
#   expect: s3://<bucket>
#           s3://my-bucket
#           s3://stub

# A3.2 [named list — same at baseline: the literal dots in the script header]
/usr/bin/grep -rhoE 'endpoint-url=[^ )]*' --exclude-dir=.git --exclude-dir=plan . | sort -u
#   expect: endpoint-url=...

# A3.4 [NOT DISCRIMINATING — 0 at baseline too; it only shows the test removed its work directory]
ls "${TMPDIR:-/tmp}" | /usr/bin/grep -c memory-sync-test
#   expect: 0        (run with the same TMPDIR the gates ran with)
```

- A3.1 and A3.2 cannot see a profile name. A3.3, manager-run and optional,
  prints file names only and never a value: for each of the three env keys read
  the live value into a shell variable, skip it if empty, and
  `/usr/bin/grep -rlF -- "$v" --exclude-dir=.git .` → expected: no file listed.
  Do not `echo` the variable and do not run this under `set -x`.
- The test kills, by PID, only the lock holders and stub sleeps it started.
  Nothing in this plan uses `pkill` or `killall`.

## A4. Things the user must know before adopting this on a live machine

Out of scope here (Q1), listed so they are not lost:

- Create `~/.claude/host.md` from `host.example.md` **before** installing the
  new `CLAUDE.md` and `bootstrap`, or the temp-directory mandate lapses.
- The live hook timeouts are 20/20/60/60 s and the live
  `CLAUDE_MEMORY_S3_TIMEOUT` is set; it must be at least 5 s below the smallest
  hook timeout (so 15 or less) or be removed, which gives the default 12.
- If the live `CLAUDE_MEMORY_S3_URI` ends in `/`, existing objects sit under a
  `…//…` key and the fixed script will read and write `…/…` instead. Check with
  a command that prints only true/false, and move the objects first if true.
- The live `skills/sync-memory/SKILL.md` holds the real bucket name on two
  lines the repo copy replaces with `<bucket>`.
- First pull with the new script prunes the stage to match the bucket. It does
  not touch `projects/`.
- New state file `~/.claude/.memory-sync-failed` appears after a failed push
  and is safe to delete by hand.

## A5. Docs

`README.md` (S4.3–S4.5), `skills/sync-memory/SKILL.md` (S1.14–S1.25), the
header of `memory-sync.sh` (S1.4, S1.12) and `AGENTS.md` are the documentation
for this change. Nothing else needs a doc update.

## A6. Backing it out

Slices 2 and 3 edit the same three files (`agents/reviewer.md`,
`agents/analyzer.md`, `commands/develop.md`), so **before commit they can only
be backed out together**. Slice 4 names things slices 1 and 3 create, so it
goes first whenever either of those goes. Look at `git status --short -uall`
before any of this; never `git clean`, never `git restore .`.

**Before commit — three units, in this order when more than one is removed:**

1. *Slice 4* (required first if unit 2 or unit 3 is removed):
   `git restore -- README.md` and `rm AGENTS.md settings.example.json`.
2. *Slices 2 + 3 together:*
   `git restore -- CLAUDE.md manager-bootstrap.sh skills/bootstrap/SKILL.md agents/analyzer.md agents/committer.md agents/developer.md agents/reviewer.md commands/analyze.md commands/commit.md commands/develop.md commands/integrate.md commands/plan.md commands/review.md commands/ship.md`
   and `rm host.example.md`.
3. *Slice 1:* `git restore -- memory-sync.sh skills/sync-memory/SKILL.md`,
   `rm tests/memory-sync.test.sh`, `rmdir tests`.

After removing all three, B1.1 and B1.5 must read as they did at the start
(`5` for B1.5 — which is why `tests/` is removed with `rmdir`, not left empty).

**After commit** — one commit per slice is the intended shape (the committer
decides). Revert newest first, and never revert a slice while a later one that
depends on it stays: slice 3 depends on slice 2 (shared files), slice 4 depends
on slices 1 and 3 (it names `tests/memory-sync.test.sh`, the `delete` mode and
`host.example.md`). So: to remove slice 1 revert 4 then 1; to remove slice 3
revert 4 then 3; to remove slice 2 revert 4, 3, then 2.
`UNVERIFIED: that git revert of these commits applies without conflict — no commits exist yet.`

**Runtime:** nothing to undo. The live `~/.claude` is not touched, no real
bucket is contacted, and no data format changes: `.memory-sync-pushed` and the
lock file keep their meaning, the stage is a cache.

## Tests added

`tests/memory-sync.test.sh` — cases T01–T24 (S1.13); the step-to-case map is
under *Slice 1 coverage*. No test existed before.
No E2E or integration suite exists in this repo and none is added: stage 4
(`/integrate`) has nothing to run and should be skipped with that reason
stated, since exercising the real backend is forbidden.

## Chosen boundary, and the ones rejected

**Chosen: B1 from findings §7** — one plan, four slices cut by file set, in the
order 1 ∥ 2 → 3 → 4 (Q8).

Rejected:

- **Script only, prose later** — leaves `sync-memory` documenting a script that
  no longer behaves as described, and leaves the pipeline deadlocked in any
  repo without `AGENTS.md`, including this one.
- **Rewrite `memory-sync.sh` on `aws s3api` or in another language** — changes
  the hook contract and discards a script whose comments each record an
  incident; far beyond the findings.
- **`--delete` on push** — would let a half-written or freshly installed local
  tree wipe the bucket, and is proven insufficient on its own (the stage
  restores the file). `--delete` is used only toward the stage.
- **Tombstones** — the correct multi-machine answer, deferred by the user (Q2);
  needs a new on-disk format and something to create the marker.
- **Review verdict suffix** (`SHIP (no AGENTS.md…)`) — breaks `/ship`'s
  whole-line verdict match; a separate `agreement:` line is used instead.
- **macOS support** — cannot be verified on this host (Q6).

## Follow-ups (not in this plan — write to `follow-ups.md`, do not build)

- Tombstones for multi-machine deletes.
- An `install.sh --check` to show drift between the repo and `~/.claude`.
- `.gitignore`, if a symlink install is ever adopted.
- A check for the Markdown files (link/anchor lint).
- `delete` does not update a project's `MEMORY.md` index.
- Two concurrent pulls are now serialised by the lock but the pull race itself
  (findings A6) was never reproduced; T18 proves the lock is taken, not that
  the race existed.
