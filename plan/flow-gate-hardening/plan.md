tier: full — the claim, the takeover and the publish decide whether two sessions can both write one report or verdict; a mistake deletes a published copy or lets development start on a plan the product did not accept, and every proof here is a race or a signal.

# Plan — flow-gate-hardening

Built on `main` at `f6fcb14` (`glab` 0.14.0). Request and goals: `master.md`. Facts: `evidence.md`, cited as E1–E13. The new files in full: `steps-1-script.md` (S1), `steps-2-test.md` (S2); the posts' helper files: `steps-3-posts.md`.

## Decisions

- **effort** — `- effort: high (the user's words: "high (Recommended)"), for the session`
- **one-plan** — One plan, no sub-plans: the four follow-ups change `claim` and `publish_file` of one script and one test file, which land in one commit; the code sits in steps files for size only.
- **claim-line** — Each claim holds one line, `<host> <boot id> <pid namespace> <pid> <start>` (`whoami`), written inside the claim's own `O_EXCL` create; read from `/proc`, Linux only, and empty where `/proc` is missing or another pid namespace's, so those claims are refused as today (E2, E8).
- **owner-gone** — A claim's run is gone only when host, boot id and pid namespace match this run's and `kill -0` says `No such process`, or `/proc/<pid>/stat` shows another start time (pid reused) or state `Z`/`X`; anything else is "cannot tell" and keeps the refusal (E5; `kill -0` alone rejected, `evidence.md` *Rejected boundaries*).
- **takeover** — Exclusive by the lock `.plan-gate.takeover.<kind>.r<n>`, made as a claim is, under which the claim is read again and removed only if it still holds the stale line: T46 proves the lock, T47 the re-read, T48 the plain race (M1, M2: E11).
- **lock-left** — A SIGKILL inside the takeover, a few commands, leaves the lock and every later takeover of that number is refused naming it; accepted, against a whole run's window before — a lock for the lock only moves the window.
- **refusals** — A claim whose run is alive keeps today's text byte for byte (T33, T37, T40); one that cannot be proven stale keeps it and names the tmp too when there is one (FR2-2); a held lock gives `<refusal>; when no run is writing, remove <lock> by hand`.
- **copy-left** — A takeover leaves a dead report run's `plan.r<n>/` in place: the existing refusal under the claim keeps it for a person, as "detect and surface" decided (T43).
- **contract** — A refusal still writes nothing but the takeover before it, which removes only a dead run's claim and tmp; said in the header and in `AGENTS.md` *Rules*; exit codes and stdout unchanged.
- **t38** — T38 keeps its id and is rewritten: what it asserted, a refusal after a SIGKILL, is the behaviour FR1-2 replaces; that refusal lives on in T44 and in T38's branch for a host without `/proc`.
- **hold** — TERM, HUP and INT are held — noted by a trap, not ignored — from before `ln` until `TMP_DIR` is cleared, then re-sent so the run still ends by them (E6; M3–M5).
- **hold-claim** — The same hold spans each create in `claim` and `take_over` and the assignment after it, which closes the window between the claim's subshell and `CLAIM=$1`; proven for each of the two on instrumented builds, with and without its hold (E7, A5), no permanent case, since that needs an instrumented copy of the script.
- **ef** — After `ln` fails, a final name that is the tmp itself (`-ef`) means `ln` linked and was then killed, as a Ctrl-C to the process group does: the file is published (T50, M6).
- **no-hardlinks** — FR1-1 by a clear exit-2 message, no fallback: `plan-gate.sh: writing <path> failed: <ln's message>; plan-gate.sh publishes with a hard link, so the store must be on a filesystem that has them - the header of plan-gate.sh names them`; no fallback can be proven on this host, FAT fails `chmod` first, and `mv` would leave exclusivity to the claim alone (E3, E4).
- **no-parse** — The message is printed for any `ln` failure but a name already there, not matched against errno texts: one EPERM reads `Permission denied` from uutils and `Operation not permitted` from GNU (E3).
- **readers** — `check` and `verdict` are unchanged: `ln` publishes a finished file, so no reader can see half of one.
- **exit-2** — The missing hard links are a failed write, exit 2 as today, and the message keeps today's start `plan-gate.sh: writing <path> failed`; not a `REFUSED:` line, which is for a state of the store.
- **filesystems** — Named in the header; `docs/specs/product.md`'s owner pointer gets the same list at the record (`master.md` *Record*), because the repo's `plan/` rule puts spec edits there; `README.md` and `host.example.md` gain nothing (say it once).
- **head** — `take_over` reads the claim with `head -n 1`, a claim being one line; it is also where T47 holds a run between its first read and the lock.
- **umask** — Claims and locks are made under `umask 022`, so a run of the other level's account can read the line (E8).
- **version** — `glab` 0.14.1, once, in `plugins/glab/.claude-plugin/plugin.json`.
- **gates** — `AGENTS.md` *Gates* is unchanged: it names no case count, and its nine files and seven test lines stay; the *Rules* sentence on `plan-gate.sh`'s contract is the one `AGENTS.md` change.
- **limits** — What stays open, for the record's *Known limits*: the takeover is Linux-only; a claim is empty for the instant between its create and its write, and one killed there stays refused; the lock left by a SIGKILL (**lock-left**); a claim from before a reboot stays refused, since the boot id differs and `owner_gone` cannot tell (safe, a person removes it); a signal held when the run exits refused or failed is dropped, the exit keeping its status; network, FUSE and synced stores UNVERIFIED; bash 3.2 UNVERIFIED, now also for `trap -` with a re-sent signal and `${e//$'\n'/ }`; the re-tests under the claim and the other exit-2 branches still covered by no case.
- **size** — `plan.md`, `master.md` and `evidence.md` are each under 48 KB; `steps-1-script.md` (28 KB) and `steps-2-test.md` (45 KB) hold whole files so the plan check can run them.
- **a6-a7-run** — The manager ran A6 on the built tree: ten runs in a row, each `PASS 51/51`. M1 (no lock) fails T46 on every run and also T48 in 2 of 5 runs, because without the lock the race in T48 goes either way. Accepted: T46 is the deterministic bar E11 names, and the extra T48 failure only makes M1 easier to catch (2026-11-14).
- **review-fixes** — Review round 1 (`review-1.md`) found three lows, fixed by a new developer (`result.md` *Review round 1 fixes*); the built script and test therefore no longer match the S1 and S2 text: the shipped sha256 are `plan-gate.sh` f545c4ddc9b4da2a025b469b1efa1d2d8f0483863284d88c6d3cddcd9610fa90 and `plan-gate.test.sh` 72bf26da108baa6e69445fee64ac26e08a75e5ed706310601f9424bd537f881e. Review round 2: SHIP (2026-11-14).
- **final-check** — The final check returned CONFORMS. The manager then ran A4 and A8 on the shipped script, because the review fixes came after their first runs: A4 printed `FAIL T38 FAIL T43 FAIL T44 FAIL T45 FAIL T46 FAIL T47 FAIL T48 FAIL T49 FAIL T50 FAIL T51 FAIL T22 FAIL 11/51`, and A8 printed `trace byte-identical`, `434`. A5 and A7 apply to the pre-fix build only: their helpers in `steps-3-posts.md` match the old subshell creates, so on the shipped script they stop at their assertions. The shipped window is proven by the developer's stand-ins (`result.md` *Review round 1 fixes*) and by review round 2. M1 against the shipped lock code is UNVERIFIED. `result.md` A6 "NOT RUN" is superseded by `a6-a7-run` (2026-11-14).

## Milestone

A run killed by SIGKILL no longer blocks its number: the next run on the host takes the claim over and writes the report or verdict, and two runs cannot both take it; a signal inside `ln` keeps the linked report's copy; a store without hard links is told why it fails. Proven by `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh` → `PASS 51/51`, with T38 and T43–T51 failing on `f6fcb14`'s script (A4).

## Before

- **B1** — On `main` at `f6fcb14` or a descendant whose four target files are as at `f6fcb14`: `git diff --quiet f6fcb14 -- plugins/glab/scripts/plan-gate.sh tests/plan-gate.test.sh plugins/glab/.claude-plugin/plugin.json AGENTS.md; echo rc=$?` → `rc=0`. `export TMPDIR=/data/tmp/claude` (the host file's temp directory) before every command below.
- **B2** — Both gate blocks of `AGENTS.md` *Gates* green on the untouched tree, as on 2026-11-14 (E1 and this plan's run): nine `rc=0`, shellcheck `rc=0`, `PASS 35/35`, `PASS 24/24`, `PASS 42/42`, `PASS 13/13`, `PASS 17/17`; three `✔ Validation passed`, `Skills (21)`, `Agents (9)`, both `Hooks (4)` lines, the rest as *Gates* says.

## Processing

- **S1 — `plugins/glab/scripts/plan-gate.sh`.** Replace the file with the text of `steps-1-script.md` (its command extracts it; sha256 `e6cb9bfb5dc3d5b97ae9ab528365d0fb98ebe08a82544a91bd6ac9a793239bcd`, 520 lines), mode `100755` kept. Against `f6fcb14`:
  - the header: a refusal writes nothing but a takeover before it; the new paragraph *Where a store may live* — hard links, `O_EXCL`, permission bits; ext4 tested, xfs, btrfs, zfs, tmpfs, APFS, HFS+ by their documentation; not FAT, vfat, exFAT; exit 2 without hard links, no fallback; network, FUSE, synced UNVERIFIED; the takeover Linux-only;
  - the trap: `LOCK` beside `TMP_DIR`, `TMP_FILE`, `CLAIM`, removed last; its comment says four scalars;
  - new `hold_signals`, `release_signals` (**hold**), `proc_stat`, `whoami` (**claim-line**), `owner_gone` (**owner-gone**), `take_over` (**takeover**, **refusals**, **head**);
  - `claim`: the line `ME` written in the create, under `umask 022`, the create and `CLAIM=$1` inside one hold; an existing claim goes to `take_over`; its comment keeps the uutils `mkdir` measurement and says what a SIGKILL now leaves and who takes it over;
  - `claimed_tmp`: one comment sentence, `take_over` also removes that name;
  - `publish_file`: the hold around `ln`; `ln`'s stderr read; the `-ef` case; the exit-2 message (**no-hardlinks**); the release after `TMP_DIR=''`; its comment says why and that there is no fallback.
  - Nothing else changes: `diff <(git show f6fcb14:plugins/glab/scripts/plan-gate.sh) plugins/glab/scripts/plan-gate.sh` touches only the header, the trap block, `claim` and the functions after it up to `claimed_tmp`'s body (unchanged), and `publish_file`.
  - *Verify*: `sha256sum` as above; `bash -n` and `shellcheck` rc 0; A2–A8.
- **S2 — `tests/plan-gate.test.sh`.** Replace the file with the text of `steps-2-test.md` (sha256 `e405b9f1ed7a2084e88e30d26281c75da794e575da25b5fae53769628a665d1d`, 939 lines), mode `100755` kept. Against `f6fcb14`:
  - two comments: the trap's (background runs of T33, T37, T45, T47, T48) and the one above `$W/launch` (which cases use the launcher);
  - after `launched`: `PROC` (set where `/proc` is this test's pid namespace's, the script's own condition), `owner <pid> <start>` (a claim line made with `uname -n`, the boot id and `readlink /proc/self/ns/pid`, independently of the script), `started <pid>`, `dead_pid`;
  - **T38** rewritten (**t38**): the run killed in `date` leaves the claim and the tmp, the claim naming its pid; the next verdict takes it over, rc 0, nothing left; without `/proc`, the refusal naming both files;
  - **T43** a report run killed in `date`: claim, tmp and `plan.r1/` left; the next report takes the claim over, removes the claim and tmp, and is refused `plan.r1/ is there without report r1; look at it and remove it by hand` with `plan.r1/` kept; removed by hand, the next report is written;
  - **T44** four claims no run can prove stale — empty (as 0.14.0 wrote them), another host, another pid namespace, this test's live bash — each refused by `refused` (rc 1, the exact line, nothing written), naming the tmp for the middle two;
  - **T45** a claim whose pid is this test's bash with start `1` (reused) and one whose run is a zombie (`sleep 0` under a parent that became `sleep 5`) are both taken over;
  - **T46** an `rm` stub that, while the lock is there, runs a second verdict: it is refused naming the lock, the first run writes `ACCEPTED`;
  - **T47** a `head` stub that hands the stale line to the first run only after a second run, in the background with a `date` that waits for `$C/go`, holds the new claim and has released the lock: the first is refused naming the claim, the second writes `ACCEPTED`; should `$C/r2` never come, the second run is killed by its PID before `BG` is cleared;
  - **T48** two verdicts at once on one stale claim with a `head` that waits 1 s on the claim: one 0 and one 1, the loser's line naming the lock or the claim, the verdict the winner's;
  - **T49** for TERM, HUP and INT an `ln` stub that links, signals the run, sleeps 1 s and exits: rc 143, 129, 130; `report.r1.md` and `plan.r1/` with the report's digest stay; nothing left; the verdict is written;
  - **T50** an `ln` stub that links and is killed: rc 0, the path printed, `plan.r1/` kept;
  - **T51** an `ln` stub that prints GNU's real EPERM line (E3) for the final name in `$C/final` and links nothing: report, then verdict, exit 2 with the exact message, stdout empty, nothing written or left;
  - T1–T37, T39–T42 and T22 byte-identical.
  - *Verify*: `sha256sum`; `bash -n`, `shellcheck` rc 0; A2, A4.
- **S3 — `plugins/glab/.claude-plugin/plugin.json`.** `"version": "0.14.0"` → `"version": "0.14.1"`, nothing else. *Verify*: A9.
- **S4 — `AGENTS.md` *Rules*.** In the hook-contracts bullet replace

      usage or a failed write; every refusal one `REFUSED:` line on stderr, and no
      write.

  with

      usage or a failed write; every refusal one `REFUSED:` line on stderr, and no
      write but the takeover before it of a claim, and its temporary file, whose
      run provably no longer runs.

  Nothing else in `AGENTS.md` (**gates**). *Verify*: A9.

## After

Each from the repo root, `TMPDIR` exported. A post's "skipped" result was produced on the throwaway build of `evidence.md` with that step left out.

- **A1 — both gate blocks of `AGENTS.md` *Gates***, as B2, except `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh` → 51 `ok` lines and `PASS 51/51`. S2 skipped: `FAIL 1/42` (T38, E10); S1 skipped: `FAIL 11/51` (E9).
- **A2 — the milestone**: as in A1, its last line `PASS 51/51`; every line `ok`.
- **A3 — the takeover's creates are exclusive**: a stale planted claim (a dead pid), then a report under `strace`:

      T=$(mktemp -d "$TMPDIR/fgh-excl.XXXXXX") && S=$T/store P=$T/plan && mkdir -p "$S/briefs/notes-api" "$P" &&
        printf '# Brief\n' >"$S/briefs/notes-api/brief.md" &&
        printf -- '- brief: briefs/notes-api/brief.md sha256 %s\n' "$(sha256sum <"$S/briefs/notes-api/brief.md" | cut -c1-64)" >"$P/master.md" &&
        printf 'plan\n' >"$P/plan.md" &&
        printf '%s %s %s %s 1\n' "$(uname -n)" "$(cat /proc/sys/kernel/random/boot_id)" "$(readlink /proc/self/ns/pid)" "$(bash -c 'echo $$')" >"$S/briefs/notes-api/.plan-gate.claim.report.r1" &&
        strace -f -e trace=openat -o "$T/st" bash plugins/glab/scripts/plan-gate.sh report "$P" "$S" >/dev/null &&
        command grep -E "plan-gate\.(claim|takeover)" "$T/st" | sed "s|$T|<T>|"; rm -rf "$T"

  → four `openat` lines in this order: the claim `O_RDONLY` (`head`), `.plan-gate.takeover.report.r1` `O_WRONLY|O_CREAT|O_EXCL`, the claim `O_RDONLY` again, the claim `O_WRONLY|O_CREAT|O_EXCL`; the first, failed create opens nothing, bash's noclobber refusing an existing regular file before any `open` (E8). S1 skipped: `strace` shows no takeover line and the report is refused.
- **A4 — the new cases fail on today's script**:

      old=$(mktemp "$TMPDIR/plan-gate-f6fcb14.XXXXXX") && git show f6fcb14:plugins/glab/scripts/plan-gate.sh >"$old" &&
        bash tests/plan-gate.test.sh "$old" | command grep -oE '^FAIL T[0-9]+|^(PASS|FAIL) [0-9]+/[0-9]+' | tr '\n' ' '; rm -f "$old"

  → `FAIL T38 FAIL T43 FAIL T44 FAIL T45 FAIL T46 FAIL T47 FAIL T48 FAIL T49 FAIL T50 FAIL T51 FAIL T22 FAIL 11/51` (E9). With S2 skipped the old test passes `PASS 42/42` on the old script, so this post also needs S2.
- **A5 — the claim window** (G5), on instrumented copies, in `claim` and in `take_over` (the second on a planted stale claim, `window.sh`'s `stale`):

      T=$(mktemp -d "$TMPDIR/fgh-window.XXXXXX") && git show f6fcb14:plugins/glab/scripts/plan-gate.sh >"$T/old.sh" &&
        for n in window.sh window-builds.py; do awk -v n="$n" '$0 == "~~~~ " n { f = 1; next } /^~~~~$/ { f = 0 } f' plan/flow-gate-hardening/steps-3-posts.md >"$T/$n"; done &&
        python3 "$T/window-builds.py" "$T/old.sh" plugins/glab/scripts/plan-gate.sh "$T" &&
        for s in old new nohold; do echo "window-$s: $(bash "$T/window.sh" "$T/window-$s.sh")"; done &&
        for s in takeover takeover-nohold; do echo "window-$s: $(bash "$T/window.sh" "$T/window-$s.sh" stale)"; done; rm -rf "$T"

  → five lines, no trailing space: `window-old: rc=143 left: .plan-gate.claim.report.r1 brief.md`, `window-new: rc=143 left: brief.md`, `window-nohold: rc=143 left: .plan-gate.claim.report.r1 brief.md`, `window-takeover: rc=143 left: brief.md`, `window-takeover-nohold: rc=143 left: .plan-gate.claim.report.r1 brief.md` (E7). S1 skipped: `window-builds.py` stops on its assertion, the new create not being there.
- **A6 — no flake**: `for i in 1 2 3 4 5 6 7 8 9 10; do bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh | tail -n 1; done` → ten `PASS 51/51` (E13).
- **A7 — every new branch is tested**, by thirteen mutants of the new script, each one change (about 5 minutes):

      T=$(mktemp -d "$TMPDIR/fgh-mut.XXXXXX") &&
        awk -v n=mutants.py '$0 == "~~~~ " n { f = 1; next } /^~~~~$/ { f = 0 } f' plan/flow-gate-hardening/steps-3-posts.md >"$T/mutants.py" &&
        python3 "$T/mutants.py" plugins/glab/scripts/plan-gate.sh "$T" >/dev/null &&
        for f in "$T"/M*.sh; do n=${f##*/}; echo "${n%.sh}: $(bash tests/plan-gate.test.sh "$f" | command grep -oE '^FAIL T[0-9]+|^(PASS|FAIL) [0-9]+/[0-9]+' | tr '\n' ' ')"; done; rm -rf "$T"

  → each line as E11 lists it, none `PASS`. S1 skipped: `mutants.py` stops on its first assertion.
- **A8 — the walkthrough trace is byte-identical** (G6):

      T=$(mktemp -d "$TMPDIR/fgh-trace.XXXXXX") && git show f6fcb14:plugins/glab/scripts/plan-gate.sh >"$T/old.sh" &&
        PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh "$T/old.sh" plugins/glab/scripts/manager-bootstrap.sh 2>"$T/old" >/dev/null &&
        PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>"$T/new" >/dev/null &&
        cmp "$T/old" "$T/new" && echo 'trace byte-identical'; wc -l <"$T/new"; rm -rf "$T"

  → `trace byte-identical`, `434` (E10). Run both on one day: the trace holds the date. This post holds whether S1 ran or not; S1's own posts are A1, A4, A5, A7.
- **A9 — version and contract**: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.14.1` (skipped: `0.14.0`); `command grep -c 'provably no longer runs' AGENTS.md` → `1` (skipped: `0`); `git diff --stat f6fcb14 -- AGENTS.md` → `1 file changed, 2 insertions(+), 1 deletion(-)`.
- **A10 — nothing else moved**: `git status --short -uall` prints exactly these lines, in this order: ` M AGENTS.md`, ` M plugins/glab/.claude-plugin/plugin.json`, ` M plugins/glab/scripts/plan-gate.sh`, ` M tests/plan-gate.test.sh`, `?? plan/SESSION-HANDOFF.md`, `?? plan/flow-gate-hardening/evidence.md`, `?? plan/flow-gate-hardening/master.md`, `?? plan/flow-gate-hardening/plan.md`, `?? plan/flow-gate-hardening/steps-1-script.md`, `?? plan/flow-gate-hardening/steps-2-test.md`, `?? plan/flow-gate-hardening/steps-3-posts.md`, `?? plan/flow-project-level/audit.md`, `?? plan/manager-flow-notes.md` — plus any file the manager adds to the plan folder after this plan (`master.sha256`, round copies). `plan/SESSION-HANDOFF.md` and the last two are untracked files this change does not touch.
- **Documentation**: the specs at the record (`master.md` *Record*); no payload file changes (E-scope).
- **Back out**: `git revert <the commit>`; or before commit `git checkout f6fcb14 -- plugins/glab/scripts/plan-gate.sh tests/plan-gate.test.sh plugins/glab/.claude-plugin/plugin.json AGENTS.md`. A store keeps working either way: a 0.14.0 run reads a 0.14.1 claim as a file that exists and refuses as before, and a 0.14.1 run reads a 0.14.0 empty claim as one it cannot prove stale (T44).

## Tests

- **Updated**: T38 (`tests/plan-gate.test.sh`). **Added**: T43, T44, T45, T46, T47, T48, T49, T50, T51. **Unchanged and passing**: T1–T37, T39–T42, T22; `tests/product-loop.test.sh` L1–L17.
- **Coverage, per step**:
  - S1 `whoami`/claim line: T38 (the pid in the line), T44 case 4 and T45 (lines made by the test, matched by the script), E8 (`strace`, mode). `owner_gone`: gone by `kill -0` — T38, T43, T46–T48; by start time — T45; by zombie — T45; alive — T33, T37, T40, T44 case 4; cannot tell — T44 cases 1–3. `take_over`: lock — T46; re-read — T47; race — T48; tmp removed — T38, T43; copy folder kept — T43; refusal texts — T44, T46, T47, T33, T37, T40. Hold in `publish_file` — T49; `-ef` — T50; the exit-2 message — T51; the holds in `claim` and in `take_over` — A5 only.
  - S2: A1, A4. S3, S4: A9.
  - **Not covered by a case, accepted**: the hold in `claim` and `take_over` at the exact instant after a create (A5 shows it on instrumented builds; a case would need one); the lock left by a SIGKILL inside `take_over` (no external runs while it is held but `rm`, and killing there tests only that a file stays); `take_over`'s `io` branches and a create that fails with no file there (a failing filesystem); the `X` state (a dead task, gone before a test can read it); a store on another account (one account here); `whoami` on a host without `/proc` and the `PROC`-unset branches of T38 and T43 (no such host here) — UNVERIFIED.

## Boundary

The change stays inside `plan-gate.sh`'s claim and publish code and its test: the claim file, the tmp name and the copy folder keep their names, the report and verdict formats and every refusal of a live state keep their bytes, and no caller changes (E12). The new name `.plan-gate.takeover.<kind>.r<n>` starts `.plan-gate.` like the others, so T22 and the walkthrough's leftover check see it.

## Rejected

`evidence.md` *Rejected boundaries*: `kill -0` alone; `flock`; a takeover by `mv`; a fallback to `mv`; a fallback by `O_EXCL` on the final name with an end marker; parsing `ln`'s message; a permanent case for the claim window.

## Questions

None: nothing here is destructive, costs money, exposes real data or changes what the product is — FR1-1's answer decides which stores work, and the request left that choice to the plan ("Decide").
