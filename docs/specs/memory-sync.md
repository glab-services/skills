# Memory sync — spec

The `memory-sync` plugin: `memory-sync.sh`, which mirrors Claude Code
memories to S3 or an S3-compatible store, the four hooks that run it, the
`memory-sync:sync-memory` skill for running it by hand, and the settings it
reads. Owned by `plugins/memory-sync/scripts/memory-sync.sh` (its header and
comments), `plugins/memory-sync/hooks/hooks.json`,
`plugins/memory-sync/skills/sync-memory/SKILL.md`,
`plugins/memory-sync/settings.example.json`, `tests/memory-sync.test.sh`
and `README.md` *Configuring `memory-sync`*. Stated as of `6838133`
(`memory-sync` `0.1.0`); where this file and an owning file disagree, the
owning file is right.

## How it works now

- **What is synced.** Only files under a `memory/` directory of
  `~/.claude/projects/<project>/` (the config directory is
  `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`), keeping the per-project layout;
  nothing else in `projects/` is read or written (`aws s3 sync` with
  `--exclude "*" --include "*/memory/*"`).
- **Modes** (the script's header): `pull` — S3 to local through a stage copy,
  never overwriting a local file newer than the remote object's upload time,
  and never restoring a file removed from the bucket; `push` — local to S3;
  `push-if-changed` — a push only when a memory file is newer than the last
  successful push, silent otherwise, and skipped while another sync holds the
  lock and for 300 s (the user's 5 minutes) after a failed push; `delete
  <project>/memory/<file>` — removes the bucket object first, then the stage
  and local copies only if that succeeded; the only mode that deletes, run by
  hand. Any other mode prints the usage line and creates nothing.
- **Hooks** (`hooks/hooks.json`): `SessionStart` runs `pull`, `SessionEnd`
  `push`, `PostToolUse` (matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`)
  and `Stop` run `push-if-changed`; each with a `timeout` of 20 s, through
  `"${CLAUDE_PLUGIN_ROOT}"/scripts/memory-sync.sh`.
- **The hook contract** (`AGENTS.md` *Rules*): the mode names, exit 0 on
  every path, nothing on stdout, messages on stderr as `[memory-sync] …`.
  Missing `CLAUDE_MEMORY_S3_URI`, or a missing `aws`, `timeout`, `flock` or
  `rsync`, is logged and skipped. Linux with GNU coreutils, util-linux
  `flock` and `rsync` only.
- **Configuration** comes from the environment, which a plugin cannot set:
  the user merges the `env` block of `settings.example.json` into
  `~/.claude/settings.json` — `CLAUDE_MEMORY_S3_URI` (required; trailing `/`
  stripped), `AWS_PROFILE`, `CLAUDE_MEMORY_S3_ARGS` (split on whitespace, never
  glob-expanded), `CLAUDE_MEMORY_S3_TIMEOUT`, and
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`. No `userConfig`. `AWS_PROFILE` in
  that block applies to every `aws` command of every session (`README.md`).
- **Time limit.** `CLAUDE_MEMORY_S3_TIMEOUT` defaults to 12 s; the largest
  value accepted is 17. One budget covers the whole run: every lock wait and
  every bounded command gets at most what is left of it, a child ignoring TERM
  is killed 2 s later, and a call that would start after the limit is not
  started, so a run lasts at most the limit plus 3 s — 15 s by default, and
  20 s at 17, the hook's own timeout. A malformed value logs `… is not a
  positive integer; using 12`; a well-formed value above 17 (or of three
  digits or more) logs `… is above 17; using 12`. The time is read from
  `date` in milliseconds, not `$SECONDS` (the script's comments give why).
- **The `SessionEnd` budget.** Claude Code gives all `SessionEnd` hooks 1.5 s
  between them, and a plugin hook's own `timeout` does not raise that.
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` (`20000` in the example) is
  documented as the override for that budget; whether it covers a hook that a
  plugin provides is not yet confirmed (smoke test part 3, below), so the
  push at session end is best effort and can be cut off with no log line.
  Edits made during the session have normally been sent already by
  `push-if-changed`.
- **State lives in the config directory**, not in the plugin's data
  directory, so hooks and hand runs share one lock: `.memory-sync-stage`
  (the stage copy, pruned to the remote on each pull; the remote and
  `projects/` are never pruned), `.memory-sync-pushed` (the last push's
  stamp, taken before the transfer, written through `.memory-sync-pushed.next`),
  `.memory-sync-failed` (the failure marker that drives the cool-down), and
  `.memory-sync.lock` (`flock` on fd 9; `pull`, `push` and `delete` wait for
  what is left of the budget, `push-if-changed` does not wait). Children do
  not inherit fd 9. Uninstalling the plugin leaves these files.
- **No `--delete` toward the remote or toward `projects/`**: a half-written
  local tree cannot wipe the remote, and a stale remote cannot delete local
  memories. Deleting across machines (tombstones) is not built: `delete`
  must be run on every machine that still holds the file, and bucket
  versioning, where enabled, is what makes an overwrite or a delete
  recoverable (the skill's *Recovering an earlier version*).
- **The skill** gives the hand-run commands, the three half-completed lines a
  run can print, the status check (configuration, credentials, a push
  `--dryrun`, the hooks, the cool-down), the conflict rules (no merge; no lock
  across machines), deleting, and recovering an earlier version. Its script
  path is `${CLAUDE_PLUGIN_ROOT}/scripts/memory-sync.sh`, with a fallback
  search under the config directory's `plugins/` when the path was not
  filled in.
- **The test**, `tests/memory-sync.test.sh`, fakes `aws` with a stub first on
  `PATH` and never reaches a backend: `PASS 35/35` at `6838133`.

## Decisions that still bind

- [bug-reviewer-findings/questions.md Q2] Deleting a memory is an explicit `delete` mode (remote first, then stage and local), and pull prunes the stage of files absent from the remote listing; tombstones are a follow-up. Bucket versioning is on — the user's statement, not verified by any command.
- [bug-reviewer-findings/questions.md Q6] Linux with GNU tools only, documented, with a start-up probe that logs which tool is missing and exits 0, plus the empty-array guard for `CLAUDE_MEMORY_S3_ARGS`.
- [bug-reviewer-findings/questions.md Q9] After a failed push, a failure stamp and a fixed 5-minute cool-down for `push-if-changed` only, which also takes the lock without waiting; an explicit `push`, the `SessionEnd` one included, always tries; the default time limit is lowered below the hook timeout (12 s) so the script's own log line appears.
- [feature-plugin-marketplace/questions.md Q2] The plugin is `memory-sync` and its skill keeps the name `sync-memory`: `memory-sync:sync-memory`.
- [feature-plugin-marketplace/questions.md Q3] The `env` block of the user's own `settings.json` stays the only source of `CLAUDE_MEMORY_S3_*` and `AWS_PROFILE`: no `userConfig`, script inputs unchanged, so hooks and hand runs see the same configuration and nothing prints the bucket.
- [feature-plugin-marketplace/questions.md Q4] The `SessionEnd` push stays in the plugin, and the README documents `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`; whether the override helps a plugin hook is unverified until smoke test part 3, and dropping the hook is the fallback if it does not.
- [feature-plugin-marketplace/questions.md Q5] The state files stay in the config directory: one lock for every caller, by construction.

## Known limits and not verified

- **No real backend has ever been contacted** by any record of this area: every run used the stub `aws` (`AGENTS.md` *Rules* forbids anything else from this repo).
- [bug-reviewer-findings/follow-ups.md unverified] *Unverified throughout*: how `aws s3 sync --delete` treats `--exclude` / `--include` filters; that `aws s3 rm` of a missing key exits 0; that bucket versioning is on (the user's statement); behaviour on bash 3.2 or macOS (out of scope by decision).
- [bug-reviewer-findings/follow-ups.md before-adopting] *Before adopting this on a machine*: create `~/.claude/host.md` first, or the temp-directory rule lapses; check the configured `CLAUDE_MEMORY_S3_TIMEOUT` (above 17 is rejected and 12 used); check whether the configured `CLAUDE_MEMORY_S3_URI` ends in a slash (the script strips it, which changes the keys); the live `PostToolUse` and `Stop` hook timeouts were 60 s, the plugin ships 20 s. Whether each was done on the user's machine is not recorded.
- [bug-reviewer-findings/plan.md A4] *Things the user must know before adopting this on a live machine*: `~/.claude/host.md` before the new `glab` text (also in `docs/specs/marketplace.md`); a configured time limit at least 5 s below the smallest hook timeout, or none; a trailing `/` in the live URI moves the keys, so check it with a command that prints only true or false and move the objects first; the live skill copy held the real bucket name where the repo has `<bucket>`; the first pull prunes the stage, not `projects/`; `.memory-sync-failed` appears after a failed push and is safe to delete.
- [bug-reviewer-findings/plan.md B4] *What this plan rests on that is UNVERIFIED*: `--delete` with filters removes only filtered files; `aws s3 rm` of a missing key exits 0; bucket versioning is on; Claude Code expands `~` in a hook command string (the plugin's hooks now use `${CLAUDE_PLUGIN_ROOT}` instead); the live URI has no trailing slash; the test's read of `/proc/$PPID/cmdline` is Linux-only and proven on one host; the ugrep leading-alternation hazard did not reproduce.
- **The `SessionEnd` override**, above: documented for the budget, not yet shown to cover a plugin's hook.
- [feature-plugin-marketplace/plan.md smoke-test-2] Smoke test part 2, `memory-sync` with no bucket configured (rows 7–10: the URI unset in the session, the `SessionStart` hook's "not set; skipping" line in the debug log, `${CLAUDE_PLUGIN_ROOT}` filled in the skill, and the skill's fallback when it is not): not run. Its steps, and the clean config directory it needs, are at `git show b853635:plan/feature-plugin-marketplace/plan.md`, *Smoke test*.
- [feature-plugin-marketplace/plan.md smoke-test-3] Smoke test part 3, the `SessionEnd` budget: not run; the hedge stays until it has. Copied below from `git show b853635:plan/feature-plugin-marketplace/plan.md`, with `"${TMPDIR:?}"` for the host's temp path; the user runs it, in the clean config directory of part 2 (`export CLAUDE_CONFIG_DIR="$(mktemp -d "${TMPDIR:?}/smoke-config.XXXXXX")"`, logged in once). D2, S2, S3, S6, S8 and D4 in its reading list are steps of that plan: the README paragraph, the hook entry, the settings key, the skill, the script comment and the gates' hook count.

**Part 3 — the `SessionEnd` budget (Q4).** Same config directory, a stub
`aws` that takes 5 seconds, never a real backend. Three runs; before each,
clear the log and the stamps.

````bash
S="$(mktemp -d "${TMPDIR:?}/smoke-stub.XXXXXX")"; export STUB_LOG="$S/log"
printf '%s\n' '#!/usr/bin/env bash' 'echo "START $(date +%T) $*" >>"$STUB_LOG"' 'sleep 5' 'echo "END $(date +%T)" >>"$STUB_LOG"' >"$S/aws"; chmod +x "$S/aws"
mkdir -p "$CLAUDE_CONFIG_DIR/projects/p1/memory"
echo "second terminal:  echo x >> $CLAUDE_CONFIG_DIR/projects/p1/memory/a.md"
reset_run() { : >"$STUB_LOG"; rm -f "$CLAUDE_CONFIG_DIR"/.memory-sync-pushed "$CLAUDE_CONFIG_DIR"/.memory-sync-pushed.next "$CLAUDE_CONFIG_DIR"/.memory-sync-failed; }
after_run() { tail -n 2 "$STUB_LOG"; ls -l --time-style=+%T "$CLAUDE_CONFIG_DIR"/.memory-sync-pushed* "$CLAUDE_CONFIG_DIR/projects/p1/memory/a.md" 2>&1; }
````

For each run: start the session with the command in the table; paste the
printed `echo x >> …` line into a second terminal (the path is already written
out in it); leave the session with `/exit`; run `after_run`.

| Run | Start with | What `after_run` shows |
|---|---|---|
| A — no override | `reset_run; PATH="$S:$PATH" CLAUDE_MEMORY_S3_URI=s3://stub/mem claude --plugin-dir ./plugins/memory-sync` | **cut**: the last line is a `START` with no `END` after it, `.memory-sync-pushed.next` exists, and `.memory-sync-pushed` is missing or older than `a.md`. **not cut**: `START` then `END` about 5 s later, no `.next`, `.memory-sync-pushed` newer than `a.md` |
| B — override in the shell | the same, with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=20000` in front of `claude` | the same two outcomes |
| C — override where the README puts it | first `printf '%s\n' '{"env":{"CLAUDE_MEMORY_S3_URI":"s3://stub/mem","CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS":"20000"}}' >"$CLAUDE_CONFIG_DIR/settings.json"`, then `reset_run; PATH="$S:$PATH" claude --plugin-dir ./plugins/memory-sync` | the same two outcomes |

A missing `END` alone is not enough to call a run cut — the stub may simply
not have been reached — which is why the stamp files are read as well.

Reading the three:

- A cut, C not cut — the docs hold and the README is right. Remove the
  "not yet confirmed" hedge (D2, S6, S8) in a follow-up.
- A cut, B not cut, C cut — the variable works only from the shell. The
  README's instruction is wrong: rewrite D2's paragraph and S3's key.
- A, B and C all cut — the variable does not help a plugin hook. The Q4
  fallback applies, as a plan of its own because the hook events are a "one
  fact, one value" item. It rewrites: **S2** (drop the `SessionEnd` entry),
  **S3** (drop the `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key), **S6** and
  **S8** (the `SessionEnd` sentences), **D2** (the event table and the
  paragraph), **D4** (`Hooks (4)` becomes `Hooks (3)`), and the script
  header's "run at session end" line.
- A not cut — the 1.5-second budget does not apply as documented; record what
  happened and change nothing.

Afterwards: `echo "$S" "$CLAUDE_CONFIG_DIR"`, check both are under
`$TMPDIR`, then `rm -rf "$S" "$CLAUDE_CONFIG_DIR"`.


## Open follow-ups

Statuses are as recorded in `bug-reviewer-findings` (2026-10-05) unless a
line says it was re-read at `6838133`.

- [bug-reviewer-findings/follow-ups.md 1] **First.** `pull`'s `rsync -a` copies the stage's directory modes and times onto `projects/`, each project directory and, through a kept symlink, a directory outside the tree; a tightened `projects/` is loosened on every pull. Suggested: `rsync -rt --omit-dir-times --update --keep-dirlinks`, plus a mode assertion in T26 — open: re-read at `6838133`, the pull still runs `rsync -a --update --keep-dirlinks`.
- [bug-reviewer-findings/follow-ups.md 2] **First.** The cap of 17 s leaves no margin under the 20 s hook timeout (a TERM-ignoring child ended at 19.0 s; the stated worst case, 20 s, ties with the kill). Suggested: cap 16, changed in the script, T29 and `README.md` together — open: `MAX_TIMEOUT=17` at `6838133`. A configurable cap is a design choice (`result-review1-script.md`).
- [bug-reviewer-findings/follow-ups.md 3] Design: a machine holding an older copy uploads it whenever its size differs, and other machines then pull it; the pull side is stated truthfully, the push side in the skill's *Conflicts* only. Needs compare-before-upload, content timestamps or tombstone-style metadata — a plan of its own. Open; reasoned, not reproduced.
- [bug-reviewer-findings/follow-ups.md 4] A `find` error on an unreadable root reads as "nothing changed" in `push-if-changed`, and nothing says so; the fix is a choice between "push anyway" and "log and skip" — open: `changed()` still sends `find`'s errors to `/dev/null`.
- [bug-reviewer-findings/follow-ups.md 5] The "worst case TIMEOUT + 3 s for any mode" claim does not hold after a backward clock step: the clamp in `left()` bounds each call, not the run. Suggested: say so in the comment, or use a monotonic clock — open: re-read at `6838133`, the comment above `now_ms` still states the bound for any mode, and the comment of `left()` (the lines the findings pointed at) describes only the per-call clamp.
- [bug-reviewer-findings/follow-ups.md 6] `aws s3 rm` killed by a signal while budget remains is reported as "remote copy not removed", though the outcome is as unknown as on a timeout. Suggested: any exit above 128 in `delete` is "not confirmed" — open: `CUT_OFF` is set only for 124, or 137 once the budget is spent.
- [bug-reviewer-findings/follow-ups.md 7] `--keep-dirlinks` applies at every level, so `pull` and `delete` act through any directory symlink under `projects/`, while the comment names only the `memory` case — open.
- [bug-reviewer-findings/follow-ups.md 8] No test for the "limit spent, command never started" branch: removing its `CUT_OFF=1` still passes 35/35 — open, not re-checked.
- [bug-reviewer-findings/follow-ups.md 9] An invalid `delete` path still creates `projects/` before it is rejected — open: re-read at `6838133`, `mkdir -p "$ROOT"` runs before the mode's path check.
- [bug-reviewer-findings/follow-ups.md 10] `.memory-sync-pushed.next` is left behind when the stamp cannot be moved; harmless — open: `push` still writes it.
- [bug-reviewer-findings/follow-ups.md 11] `push-if-changed` may not notice edits under a symlinked `memory` directory, because the change scan does not follow links; documented in the skill as a "may", not reproduced — open.
- [bug-reviewer-findings/follow-ups.md 12] A detached descendant of a killed transfer can outlive the script; it no longer holds the lock (`9>&-` in `bounded`) — open, reasoned.
- [bug-reviewer-findings/follow-ups.md 13] The test harness's stub guard does not fire when the stub exists but is not executable and no real `aws` is on the test `PATH`; the run then fails with exit 126 without reaching a backend — open, reproduced on one host, the real-`aws` half unverified.
- [bug-reviewer-findings/follow-ups.md 14] Tombstones for deletes across machines (Q2's deferred half) — open, a planned follow-up; a plan of its own.
- [bug-reviewer-findings/plan.md memory-index] `delete` does not update a project's `MEMORY.md` index (`plan.md:1325`) — open.
- [bug-reviewer-findings/plan.md pull-race] Two concurrent pulls are now serialised by the lock, but the pull race of findings A6 was never reproduced; T18 proves the lock is taken, not that the race existed (`plan.md:1326-1328`) — open.
- [bug-reviewer-findings/result-slice1.md nested-delete] `delete` accepts nested paths such as `p/memory/sub/x.md`, since `*` in the path pattern spans `/` (`result-slice1.md:247`); built as specified, noted in case it was not meant — open: the pattern `/*/memory/*/` is unchanged at `6838133`.
- [bug-reviewer-findings/result-review1-script.md nested-delete] The same, carried over by the script review round (`result-review1-script.md:240`) — open, one item with the line above.
- [bug-reviewer-findings/result-slice1.md L220] *Known undiscriminated* (a), (b), (c): pull's `rsync` and `delete`'s `aws s3 rm` run inside `bounded`, and no case tells that from a bare call; the "no `$SECONDS`" rule has no deterministic case — open: tests for (a) and (b) were asked for in `result-slice1.md` *Follow-ups* and never got a number.
- [feature-plugin-marketplace/result-slice-D.md 2] The smoke test's two fixes: clear `AWS_PROFILE` and `CLAUDE_MEMORY_S3_ARGS` with `env -u` in the stub parts, and run A, B and C once, in that order — open: part 3 below is copied as recorded, without them.
- [feature-plugin-marketplace/result-slice-D.md 4] When the smoke test settles Q4, the hedge goes from `README.md`, the skill and the script comment, and the gate line and its bullet in `AGENTS.md` go with it — open: part 3 has not run.
- [feature-plugin-marketplace/result-slice-S.md 2] Smoke test row 10's *Pass* text should name the third outcome, several copies found → ask the user — open.
- [feature-plugin-marketplace/result-slice-S.md 3] Once an install exists: confirm the plugin cache layout and the `.orphaned_at` marker, then drop the "may" in the skill's fallback (`SKILL.md:12` then, the first item of the fallback list at `6838133`) — open.

## Closed follow-ups

- [feature-plugin-marketplace/result-slice-D.md 1] Decide the hedge gate for the script, whose phrase was wrapped over two lines — closed: the comment was re-wrapped, and the gate line `command grep -c -F 'not yet confirmed' …` counts the script, the skill and `README.md` (`AGENTS.md` *Gates*).

## Incidents

- **Memory edits lost on 2026-09-23**: a restarted session pulled before the end-of-session push had run, and `aws s3 sync` overwrote newer local edits with the older S3 copy. Told in the script's comment above `STAGE`; it is why pull goes through a stage copy.
- **An unknown mode created `projects/`** on its way to the usage line; the mode is now checked first (the script's comment above the mode `case`).
- **A TERM-ignoring child ended at 19.0 s** under the 17 s cap, a tie with the 20 s hook kill (`[bug-reviewer-findings/follow-ups.md 2]`).
- **A `$SECONDS` prototype failed T20 intermittently**: `$SECONDS` counts wall-clock second boundaries, so the limit handed to `timeout` varied from run to run; the script reads milliseconds from `date` instead (`result-slice1.md` *Known undiscriminated* (c), and the script's comment above `now_ms`).
- **The over-cap message was untrue of its input**: a value above 17 first logged "not a positive integer"; it now has its own line, pinned by T29, with T20 checking the malformed case (`result-review1-script.md` *Follow-up 1*).
- [bug-reviewer-findings/findings.md pkill] **A cleanup by name killed more than its own processes.** Cleaning up an experiment, the planner ran `pkill -u <me> -f 'sleep 30'` to reap the stub's orphans; the pattern also matched its own shell (exit 144) and may have matched other processes of the user whose command line held `sleep 30` — afterwards `pgrep sleep` showed none and the throwaway directory was confirmed removed (`git show 6838133:plan/bug-reviewer-findings/findings.md`, §8, `:371-375`). It is the origin of `AGENTS.md` *Tests clean up by PID*: a test kills only processes it started itself, never by name or pattern.
- **The URI's trailing slash** produced `//` in object keys (findings A4); the script strips every trailing `/`, which moves the keys of a URI configured with one (`[bug-reviewer-findings/plan.md A4]`).

## Records

- 2026-10-05 · bug-reviewer-findings · `memory-sync.sh`: `delete`, stage pruning, one time budget, backoff after a failed push; agents and commands aligned on shared rules; host facts moved to a per-host file, repo scaffolding · change 96b44cf a8f0851 c3911b6 · records 2aeb46d · plan: `git ls-tree -r --name-only 2aeb46d -- plan/bug-reviewer-findings/` (one file: `git show 2aeb46d:plan/bug-reviewer-findings/<file>`) (its `memory-sync.test.sh` is a planning copy of the test, not the tracked one). Its workflow items are in `docs/specs/workflow.md`, its marketplace items in `docs/specs/marketplace.md`.
  - [bug-reviewer-findings/plan.md L120] B4. What this plan rests on that is UNVERIFIED → `[bug-reviewer-findings/plan.md B4]`.
  - [bug-reviewer-findings/plan.md L1319] Follow-ups (not in this plan) → tombstones `[bug-reviewer-findings/follow-ups.md 14]`; `install.sh --check` `[bug-reviewer-findings/follow-ups.md 21]` and `.gitignore` and the Markdown check `[bug-reviewer-findings/follow-ups.md 20]`, in `docs/specs/marketplace.md`; `[bug-reviewer-findings/plan.md memory-index]`; `[bug-reviewer-findings/plan.md pull-race]`.
  - [bug-reviewer-findings/result-review1-prose.md L109] Follow-ups → the bootstrap one-line check could name the host file: open, in `docs/specs/workflow.md` under this tag; the `<profile, or delete this key>` wording `[bug-reviewer-findings/follow-ups.md 17]`; stale plan probes and the pending stale-sentence list: nothing open (the list was done, next line).
  - [bug-reviewer-findings/result-review1-prose.md L122] follow-up 1 — text made stale by the script fixes → all six fixed; the `AGENTS.md` wording `[bug-reviewer-findings/follow-ups.md 17]`; the README describing the over-cap line rather than quoting it: nothing open, the script now prints its own `is above 17` line and the README says it does; the symlink limitation `[bug-reviewer-findings/follow-ups.md 11]`.
  - [bug-reviewer-findings/result-review1-script.md L221] Follow-ups → finding 3 `[bug-reviewer-findings/follow-ups.md 3]`; finding 9b `[bug-reviewer-findings/follow-ups.md 4]`; the cap of 17 `[bug-reviewer-findings/follow-ups.md 2]`; the fallback message: closed by *Follow-up 1* of the same file; symlinked memory and `push-if-changed` `[bug-reviewer-findings/follow-ups.md 11]`; nested `delete` paths `[bug-reviewer-findings/result-review1-script.md nested-delete]`.
  - [bug-reviewer-findings/result-review1-script.md L242] Not done → the stale lines: fixed in the prose round (L122 above); the B3 mutant table not re-run: nothing open.
  - [bug-reviewer-findings/result-review1-script.md L247] Follow-up 1 — the over-cap value gets its own, truthful line → done (T29, T20); its stale README text: fixed; nothing open.
  - [bug-reviewer-findings/result-slice1.md L220] Known undiscriminated → (a), (b), (c) open, under *Open follow-ups* with this tag; (d), a backgrounded child holding the lock: closed, `bounded` runs children with `9>&-`; the uncovered branches of its coverage table: nothing tracked beyond `[bug-reviewer-findings/follow-ups.md 8]`.
  - [bug-reviewer-findings/result-slice1.md L239] Follow-ups → closing fd 9 for children: done (`9>&-`); tests for (a), (b) and the spent-budget branch: L220 above and `[bug-reviewer-findings/follow-ups.md 8]`; nested `delete` paths `[bug-reviewer-findings/result-slice1.md nested-delete]`; `CLAUDE_MEMORY_S3_TIMEOUT` missing from the header: closed, the header lists it; the plan's own follow-ups: L1319 above.
  - [bug-reviewer-findings/result-slice1.md L253] Not done → the four AWS and versioning items `[bug-reviewer-findings/plan.md B4]`; the mutant table not re-run: nothing open.
  - [bug-reviewer-findings/result-slice2.md L99] Follow-ups → the two cosmetic items `[bug-reviewer-findings/follow-ups.md 18]`, in `docs/specs/workflow.md`; `reviewer.md`'s description still speaks of `AGENTS.md` only: open, in `docs/specs/workflow.md` under this tag; the sort locale of a plan probe: nothing open.
  - [bug-reviewer-findings/result-slice2.md L109] Not done → the unchecked claim that manager and bootstrap state three review rounds: closed, `glab:manager` says "Maximum 3 review rounds at full tier" and `AGENTS.md` *One fact* lists the cap.
  - [bug-reviewer-findings/result-slice3-4.md L207] Follow-ups → the plan's own list: L1319 above; `A5` citing folded steps and the missing positive probes for S3.4 and S3.12: nothing open (plan text); the gates depending on a host file: `[bug-reviewer-findings/follow-ups.md before-adopting]`; slice 2's cosmetic items `[bug-reviewer-findings/follow-ups.md 18]`.
  - [bug-reviewer-findings/result-slice3-4.md L220] Not done → A3.3 and A4, the user's steps on the live machine `[bug-reviewer-findings/plan.md A4]`; A6 and `/integrate`: nothing open.
