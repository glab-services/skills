# Result — feature-opencode-worker

Built on `main` at `889b804` (`= origin/main`). Contract read: `AGENTS.md`,
`plan.md`, `findings.md`, `questions.md` (Q1 answer: option A). Nothing staged,
committed or pushed. `plan.md`, `findings.md`, `questions.md` and `prototype/`
not edited (mtimes 19:36, 17:59, 18:49 unchanged; no file under `prototype/`
newer than `plan.md`).

Method: every block was copied out of `plan.md` by a script
(`/data/tmp/claude/ocw-dev.hlr8RF/build.py`, removed after the run) rather
than retyped. The script wrote A1–A8 with the plan's modes, and for each of
the 29 edits checked that the *before* text occurs once and starts at the
cited line before it replaced anything. All 29 printed `before-count=1` with
`starts-at-line` equal to the cited line, then `new=8 edits=29 apply rc=0`.
It ran on a `git archive 889b804` copy first; the post-conditions there were
identical to the plan's recorded output. Then it ran on the real tree, which
was also identical before K1–K3. K2 and K3 were then edited in by hand.

## Stages

Line numbers are in the built tree.

| step | status | where |
|---|---|---|
| A1 | done | `plugins/glab/scripts/external-worker.sh:1-403`, mode 755 (+K3 at `:34-38`) |
| A2 | done | `tests/external-worker.test.sh:1-357`, mode 755 |
| A3 | done | `plugins/glab/skills/workers/SKILL.md:1-121`, mode 644 (+K3 at `:107-110`) |
| A4 | done | `plugins/glab/skills/workers/profiles/default.md:1-36`, 644 |
| A5 | done | `plugins/glab/skills/workers/profiles/kimi.md:1-16`, 644 |
| A6 | done | `plugins/glab/skills/workers/profiles/glm.md:1-16`, 644 |
| A7 | done | `plugins/glab/skills/workers/profiles/deepseek-pro.md:1-16`, 644 |
| A8 | done | `plugins/glab/skills/workers/profiles/deepseek-flash.md:1-16`, 644 |
| B1 | done | `plugins/glab/skills/manager/SKILL.md:118-120` |
| B2 | done | `plugins/glab/skills/manager/SKILL.md:123` |
| B3 | done | `plugins/glab/skills/manager/SKILL.md:125` |
| B4 | done | `plugins/glab/skills/manager/SKILL.md:127` |
| B5 | done | `plugins/glab/skills/manager/SKILL.md:128` |
| B6 | done | `plugins/glab/skills/manager/SKILL.md:129` |
| B7 | done | `plugins/glab/skills/manager/SKILL.md:139` |
| B8 | done | `plugins/glab/skills/manager/SKILL.md:143` |
| B9 | done | `plugins/glab/skills/manager/SKILL.md:145` |
| B10 | done | `plugins/glab/skills/manager/SKILL.md:333` |
| B11 | done | `plugins/glab/skills/manager/SKILL.md:388` |
| B12 | done | `plugins/glab/skills/manager/SKILL.md:419` |
| B13 | done | `plugins/glab/commands/develop.md:42` |
| B14 | done | `plugins/glab/commands/review.md:8` |
| B15 | done | `plugins/glab/commands/ship.md:16` |
| B16 | done | `plugins/glab/skills/manager/SKILL.md:67` |
| B17 | done, with K2 | `plugins/glab/commands/ship.md:28` |
| B18 | done | `plugins/glab/skills/manager/SKILL.md:232` |
| B19 | done | `plugins/glab/skills/manager/SKILL.md:130` |
| C1 | done | `AGENTS.md:11-13` |
| C2 | done | `AGENTS.md:21-34` |
| C3 | done | `AGENTS.md:69` |
| C4 | done | `AGENTS.md:87-88` |
| C5 | done | `AGENTS.md:98-103` |
| C6 | done | `AGENTS.md:142-157` |
| R1 | done | `README.md:9` |
| R2 | done | `README.md:23-45` |
| R3 | done | `README.md:203` |
| V1 | done | `plugins/glab/.claude-plugin/plugin.json:3`, `0.3.0` → `0.4.0` |

No step returned PLAN WRONG or was blocked.

## Deviations from the plan literal — K1–K3

All three come from the final plan analysis (round 2 of 2), as the dispatch
directed. Each goes into the step that owns the text.

- **K1 — the back-out check of slice A.** The text sits in `plan.md` *Back-out*,
  which I may not edit, so it is applied in *Rollback* below. "check
  `git status --short -uall` shows exactly them" becomes "shows the eight
  `??` lines under plugins/ and tests/". Status also lists the seven modified
  files and the plan folder. No file, hash or post-condition is affected.
- **K2 — B17, `plugins/glab/commands/ship.md:28`.** "any other non-zero exit is
  the reviewer erroring, reported and not retried" becomes "any other non-zero
  exit except 2 (USAGE, fixed and re-run as `glab:workers` says) is the
  reviewer erroring, reported and not retried". It now matches the exit-2 row
  of the workers skill.
- **K3 — A1 header, `external-worker.sh:34-38`, and A3,
  `workers/SKILL.md:107-110`.** Each gains one sentence saying that the 64 MiB
  and 256 MiB caps cover single files and the sandbox `/tmp` only, not every
  writable mount: the copy and `$HOME` sit on disk under `TMPDIR`, limited per
  file and not in total. In A1 the sentence was inserted after "capped at 64
  MiB." and the next sentence was re-wrapped. No code line changed.

**Recorded post-condition values the K-fixes change.** Exactly three hash
lines, and nothing else (diff of the plan's recorded output against this tree):

    < 885b74b1cb6cd8e4 plugins/glab/scripts/external-worker.sh
    > 8706b8e96358d730 plugins/glab/scripts/external-worker.sh
    < c899badb8c8685b0 plugins/glab/skills/workers/SKILL.md
    > 7c9ba98ca737d9bd plugins/glab/skills/workers/SKILL.md
    < e4ffa465f81bb05b plugins/glab/commands/ship.md
    > bd7c2e83da9e9068 plugins/glab/commands/ship.md

Before K2 and K3, the real tree matched the recorded output with no
differences at all.

## Unplanned changes

None. The only changes beyond the plan's text are K1–K3, which the dispatch
directed. `chmod 755` on the two scripts is done inside A1/A2, as the plan
says.

## Tests

- Added: `tests/external-worker.test.sh` (A2, the plan's block byte for
  byte). Result `PASS 41/41`, with 41 `ok` lines in the gate run.
- Unchanged: `tests/memory-sync.test.sh`, `PASS 35/35`.
- Coverage, as a list (`AGENTS.md` *Tests*). This is the plan's list, checked
  against the built test.
  - A1: arguments and role W32; backend `case` W26; allowlist W27, W29; end
    date W28 (`date` stub); CLI missing W30; credential W31, W09; sandbox
    preflight W36; the copy W04, W35, W39; baseline and patch W02, W03;
    prompt and profiles W05–W07; sandbox binds W08, W12; size limits W41;
    environment W09; agent config W10, W12; argv W11; timeout W23; error
    classes W21, W22; markers and last block W16, W20; forged `out:` W38;
    developer validation W17–W19; reviewer validation W13–W15; redaction W24;
    secret in patch W25; binary in patch W40; stdout contract W01, W13, W16,
    W38; out-dir lifecycle W03, W26, W27, W30–W32, W36; real repo untouched
    W37.
  - A1, not covered (accepted in the plan): the `die` lines for
    `--<flag> needs a value`, an unknown argument, `--brief` not a file,
    `--repo` not a work tree, a repo with no commit, a failing `mktemp`, a
    failing `copy_repo`, and `bwrap` missing from `PATH`; and the `137` arm
    of the timeout check, since only `124` occurs. Each is one condition and
    one `die` through the path W26–W32 and W36 exercise. No case drives the
    CLI past the file limit; such a write would surface as exit 7 (W22).
  - K3 in A1: a comment, with no behaviour, so no case covers it. Accepted.
  - A2: the test itself; its strength is the mutant tally below.
  - A3–A8, B1–B19, C1–C6, R1–R3: prose, checked by the post-conditions; W05–W07
    and W34 check the profiles. K2 and K3 in A3 are prose: their only check is
    the hash lines above. Accepted, since `AGENTS.md` gives Markdown no other
    gate.
  - V1: post-condition `version 0.4.0`.

## Gates

`export TMPDIR=/data/tmp/claude`. `CLAUDE_BIN` is the binary from
`readlink /proc/$PPID/exe` up the process tree (a path under the CLI's
install directory, version 2.1.299). The block was taken from `AGENTS.md`
after C2 and C3 and diffed against the plan's *Gates* block: identical. It
ran from the repo root, and its own `mktemp -d` gave each `claude` call a
throwaway `CLAUDE_CONFIG_DIR`. Output, with the 76 `ok` lines (35 + 41) left
out:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-worker.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-worker.test.sh rc=0
    rc=0
    PASS 35/35
    PASS 41/41
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship, workers
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    plugins/memory-sync/scripts/memory-sync.sh:1
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    README.md:1
    rc=0
    rc=1

`diff` against the plan's recorded gate output: no difference. No `NOT OK`
line, and no `claude-config.*` or `external-worker*` left under `TMPDIR`. In
this non-interactive shell `command grep` resolves to `/usr/bin/grep`.

Before-checks: `git rev-parse --short HEAD` printed `889b804`; the tree check
printed `rc=1`; the bwrap probe printed `bwrap rc=0`.

## Post-condition diff

The plan's post-condition block (plan lines 1742–1762) was run verbatim:

- on a `git archive 889b804` copy: identical to the recorded "On `889b804`"
  output;
- on the plan-literal built copy: identical to the recorded finished output;
- on the real tree before K2 and K3: identical;
- on the real tree as delivered: three lines differ, the hashes of
  `external-worker.sh`, `workers/SKILL.md` and `ship.md` (values above).
  Every other line, the census and guard lines included, is identical.

## Mutant tally

I copied `prototype/mutants-plan.py` and changed only its `T`/`M` line, to
point at a throwaway copy of the delivered tree with K2 and K3 included. It
ran with `TMPDIR=/data/tmp/claude`. Result: `mutants: 48, not killed or
skipped: 0`. All 48 lines (M01–M48, each target case and the set of failed
cases) are identical to the plan's recorded table. Afterwards, no `sleep 30`,
`opt/worker` or `bwrap` process of this user was left (`ps` → rc 1).

## Blast radius (`glab:security`)

    changed: new script plugins/glab/scripts/external-worker.sh (no existing
             function changed); new skill glab:workers and five profiles;
             glab:manager Rule 1, Rule 5, *When subagent dispatch is not
             available*, Stage 2, Stage 5, *What you never do*; the dispatch
             lines of /glab:develop, /glab:review, /glab:ship; AGENTS.md
             gates, layout, tests rule, rules, one-fact cases; README rows
             and requirements; glab version 0.3.0 -> 0.4.0.
    callers: the new script is named only by glab:workers, glab:manager and
             its own test (grep -rl external-worker plugins tests). The
             agent files and security/comments skills gain the script as a
             reader, unedited; W05 and W33 pin what it relies on. No other
             agent or command names glab:workers (guard G4 = 0).
    data:    none in this repo. At run time the script writes only under
             $TMPDIR/external-worker.*; the real repo is not mounted (W37).
             It sends the copy's contents to the named provider — the
             data exposure README R2 states.
    rollback: see below.

Claims marked UNVERIFIED (L1, never run by me): `UNVERIFIED: a real Go model
answers through the sandbox, fills the report, and is held by the boundary as
the stub and the fake model were — needs the user's key and live probe L1`.
Also I1–I5 of `findings.md`, carried as open.

## Rollback

- Before commit 1, per slice:
  - A — `rm -f plugins/glab/scripts/external-worker.sh tests/external-worker.test.sh && rm -rf plugins/glab/skills/workers`.
    All eight files are new and untracked: first check that
    `git status --short -uall` shows the eight `??` lines under plugins/ and
    tests/ (K1).
  - B — `git restore plugins/glab/skills/manager/SKILL.md plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md`.
  - C — `git restore AGENTS.md README.md plugins/glab/.claude-plugin/plugin.json`.
  - Back out A only together with B and C.
- After commit 1: the plan's M16 block (`git revert --no-commit`, version
  `0.4.1`, `git add`, `fix(skills): withdraw the external worker`).
- No state outside the tree.

## Follow-ups

None written to `follow-ups.md`; nothing out of scope came up. For whoever
reviews the plan: its recorded hashes for `external-worker.sh`,
`workers/SKILL.md` and `ship.md` describe the tree before K2 and K3. The
values above are the shipped ones.

## Not done

- L1 (L1a, L1b): the user's live probe. No agent runs it (D20, C5).
- Commits 1 and 2: the committer's, not mine.
