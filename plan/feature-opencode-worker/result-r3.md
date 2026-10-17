# Result — feature-opencode-worker, revision 3

Built from `plan-r3.md`, full tier, by one developer: *Before*, then R0, A1–A8,
B1–B16, C1–C8, R1–R3, V1 and *After*. L1 (L1a, L1b, L1c) was not run; it is
the user's step. No real model was called, no API key was used, and the
user's `opencode` was not run. Nothing was staged or committed.

Contract read: `AGENTS.md` (the repo has one), `plan-r3.md`,
`findings-r3.md`, `questions-r3.md` (Q2 answered A, D34 decided on A).
`cd plan/feature-opencode-worker && sha256sum -c SHA256SUMS-r3` → 35 `OK`,
plus `./questions-r3.md: FAILED`. The manager said to expect that one failure,
because it wrote the answer into the file.
UNVERIFIED: that the `bootstrap`, `glab:security` and `glab:comments` skills
were loaded. This agent has no Skill tool, so they were followed as rules (the
evidence below, and no markers or incidents removed) but not loaded.

## Stages

**Before.**
- 1 — done, with K1. `889b804`, then the fifteen rev-2 lines exactly, with
  `/usr/bin/grep -v '^?? plan/'`. The filter as written also prints
  `?? plan/SESSION-HANDOFF.md`.
- 2 — done: `slirp4netns version 1.3.3`, `/usr/bin/slirp4netns`.
- 3 — done: `bwrap rc=0`.
- 4 — done. It ran on a `git archive 889b804` copy, under `TMPDIR=/data/tmp/claude`
  and `CLAUDE_BIN`, using the 889b804 *Gates* block. Its output is identical to the
  plan's record: three `rc=0` lines, `rc=0`, `PASS 35/35`, three `✔ Validation passed`, `Skills (14)`,
  `Agents (5)`, `Hooks (1)`, the memory-sync lines, `glab = glab`,
  `memory-sync = memory-sync`, `:0` `:0` `rc=1`, `1` `1` `1` `rc=0`, `rc=1`.
- 5 — the manager relayed that the user approved the plan, R0 included, on 2026-10-17.

**R0.**
- R0.1 — done. I looked at the rev-2 files first: the seven tracked `M` files and the ten
  untracked files, and `rev2-build/` did not exist yet. Output: `R0.1 rc=0`.
- R0.2 — done. The nine hashes equal the plan's. This was checked
  mechanically: `diff` of the hash listing against plan-r3.md:337-347 → `R0.2 diff rc=0`.
- R0.3 — done, with K1. Output: `R0.3 rc=0`; the status check with `-v '^?? plan/'` → `rc=1`.
  The filter as written prints only `?? plan/SESSION-HANDOFF.md`, then `rc=0`.
  The archive is `plan/feature-opencode-worker/rev2-build/` (9 files).
  `plan/SESSION-HANDOFF.md` was not touched.

**Slice A.** The plan's extractor ran as written. Its eight `wrote` lines are the plan's.
- A1 `plugins/glab/scripts/external-agent.sh:1-753` (755) — done
- A2 `tests/external-agent.test.sh:1-476` (755) — done
- A3 `plugins/glab/skills/external-agents/SKILL.md:1-163` (644) — done, plus K3 at :118-120
- A4 `.../profiles/default.md:1-36`, A5 `kimi.md:1-16`, A6 `glm.md:1-16`,
  A7 `deepseek-pro.md:1-16`, A8 `deepseek-flash.md:1-16` (644) — done

**Slices B and C.** The plan's applier ran as written. All 28 lines read
`before-count=1 starts-at-line=<cited line>`, then `edits=28 apply rc=0`, the
same as the plan's record. Where each edit sits in the final files:
- `plugins/glab/skills/manager/SKILL.md`: B1 :118-120, B2 :123, B3 :125, B4 :127,
  B5 :128, B6 :130, B7 :138-139, B8 :145, B9 :147-157, B16 :211-215, B10 :245,
  B11 :400, B12 :430-431
- `plugins/glab/commands/review.md`: B13 :8
- `plugins/glab/commands/ship.md`: B14 :16, B15 :28
- `AGENTS.md`: C1 :11-13, C2 :21-36, C7 :57-58, C3 :72, C8 :76-77, C4 :90-93,
  C5 :103-110, C6 :146-181
- `README.md`: R1 :9, R2 :25-56, R3 :214
- `plugins/glab/.claude-plugin/plugin.json`: V1 :3 (`0.4.0`)

**After.**
- Post-conditions — done. The output is identical to the plan's record except one line, which K3 causes:
  `34f0a824596a2760 644 plugins/glab/skills/external-agents/SKILL.md` (record:
  `a2e6651ce7d43418`). Before K3 the full output was byte-identical to the
  record (`diff` rc=0). After K3, `diff` shows that line only.
- Gates — done, green (below).
- Integrate (offline, the real CLI) — not run. It runs the user's
  `~/.opencode/bin/opencode`, which this dispatch forbids. It belongs to Stage 4.
- Mutants — not re-run. This is the planner's record; the script and test are
  byte-identical to the plan's blocks (hashes `f627bd611ec81085` and `dd3dadc3c0637447`).
- L1 — not run (the user's).

## Blocked

Nothing in the build. K2 is not applied; see *Deviations*.

## Unplanned changes / deviations

- **K1 (*Before* 1, R0.3)** — the status checks filter `'^?? plan/'` instead
  of `'^?? plan/feature-opencode-worker/'`, so the untracked manager file
  `plan/SESSION-HANDOFF.md` does not add a line. I ran both forms; the outputs are in *Stages*.
- **K3 (A3; agrees with B16)** — `SKILL.md:118-120` now reads "the target, the round and which round is
  the last, and for a fan-out reviewer its dimension, nothing else." Before it said
  "the target, the round and which round is the last, nothing else." Only the
  skill's post-condition hash changes.
- **K2 (L1b) — not applied.** L1b's text exists only in `plan-r3.md`, which I may
  not edit, and in the hashed planning record `prototype-r3/l1b.sh`. No file
  this build owns contains it. The replacement as given also fails its own aim. I pasted
  `false || { return 1 2>/dev/null || exit 1; }` then `echo STILL-ALIVE` into
  `bash -i`: it printed `exit`, never `STILL-ALIVE`, with `interactive bash rc=1`. At an
  interactive top level `return` fails, so `exit 1` still runs and closes the shell. It
  only helps when the block is sourced: `sourced returned rc=1`. Recorded in `follow-ups.md` 1.
- No other change. `plugins/glab/commands/develop.md` is unedited (its hash matches the plan's
  `1ec2bf5ff7c5ddcc`).

## Review round 1 fixes

These are the review findings the manager decided, not plan steps. Each one changes text that
`plan-r3.md` pins byte for byte, so the post-condition hashes of the script, the test,
the skill, `manager/SKILL.md`, `review.md` and `AGENTS.md` no longer match
the plan's record. That is expected. One line per fix: `file:line`, then the case that covers it.
Script is `plugins/glab/scripts/external-agent.sh` (S), test is `tests/external-agent.test.sh` (T).

- C1 — `stop` reports a start stopped in its first turn as `stopped: <id>`, exit 0, when the directory is gone after the wait — S:821. Case E37 (T:502).
- C2 — 137 is TIMEOUT only once `SECONDS - turn_start` has reached the timeout (S:630, turn_start set at S:592); otherwise exit 7 naming the signal, `killed by signal 9 (KILL)`. Case E38 (T:506), stub `selfkill`.
- C3 — `--timeout` refuses `0`, `00` and `000` — S:687. Case E27 (T:434).
- C4 — `stop` takes the lock on a descriptor and holds it through the removal, with `flock -w 30` — S:808. `lock_agent` answers 10 when the directory is gone — S:678. `send` re-checks `agent.json` after the lock — S:766. Case E37 covers stop's held lock. No case drives send's re-check: it is a race between two processes with no injection point (`follow-ups.md` 7).
- C5 — `send` takes the lock before the `ready` check, so a first turn in progress is 11 BUSY, and only an unlocked, not-ready agent is 10 — S:762. Case E37.
- C6 — a failed `mkdir -p` for a gitlink sets `why` — S:401. No case: the copy's work tree is new and holds only directories at that point, so the `mkdir` cannot be made to fail from a test.
- C7 — `w()` writes stderr to `${ERRF:-$W/err}` — T:206. E25's background `send` sets `ERRF=$W/err.bg` (T:399), and so does E37's background `start`.
- C8 — E27 checks each sub-case's message with `said "USAGE: <reason>"`, ten sub-cases in all — T:434.
- S1 — the key lookup runs from a new, empty directory: `$adir/auth` for start and send (S:725), `$root/check.$$` for check (S:844). It is created and removed by `read_secret` (S:327) and by cleanup. It runs with `opencode_switches` (S:253), the list the turn environment uses too (S:215). Case E39 (T:516): the stub records cwd, its entry count and the `OPENCODE_DISABLE_*` it saw.
- S2 — in the turn subshell, every descriptor except 0, 1, 2 and the two stream fds is closed before `exec setpriv`, and stdin is `/dev/null` — S:575. Header S:46. Case E40 (T:525). Its known positive: the host-side stub, started by the same script, sees the caller's marker fd (`marker-fds` ≥ 1).
- S3 — before every turn, `.config` and `.config/opencode` under the agent's home must be real directories when they exist, or exit 4 (`HOME_MOUNTS` S:110, check S:548). The header (S:47) and the skill (`SKILL.md:151`) now say that the home persists between turns and why. Case E41 (T:538): a symlink, then a regular file, each refused; then a real directory runs.
- S4 — `OUT_BYTES` is 16 MiB (S:106; header S:63; skill `SKILL.md:169`). `redact_stream <flag>` puts `head -c OUT_BYTES+1` before the awk, which passes whole lines only and creates the flag at the cap (S:162). `finish_turn` checks the flags first and exits 7 (S:625). Case E42 (T:550): 17 MiB of lines on stdout, kept ≤ 16777216 bytes and ending in a newline, then one endless line on stderr. Both are exit 7.
- S5 — `link_parent` refuses a tracked, gitlink or untracked path whose parent directory is a symlink, as exit 4 (S:347; used in both copy loops; header S:42; skill `SKILL.md:151` and the exit-4 row, `SKILL.md:85`). Case E43 (T:560): the repository copies with a real directory, and is refused once that directory is a symlink.
- T1 — `BLOCK: <n> issues` needs n ≥ 1 and at least n `rule:` lines (S:656). The skill says so at `SKILL.md:130`. `reviewer.md` is unchanged. Case E44 (T:567): an advisory finding beyond n is accepted, and `BLOCK: 0 issues` is exit 8. E19 still passes.
- T2 — `manager/SKILL.md:155`, Rule 6: an external agent takes no stage's role except the reviewer under Rule 5, and Stage 3 still runs `glab:analyzer`. No case: prose.
- T3 — `manager/SKILL.md:127`: the record line is `glab:reviewer opencode:opencode-go/<id>`. No case: prose.
- T4 — `commands/review.md:8`: a branch or range target cannot run on an external reviewer, so the manager tells the user. No case: prose.
- T5 — `manager/SKILL.md:123`: a name the parameter does not take also gets the question whether an external reviewer was meant. No case: prose.
- T6 — the test comments now say E10 (T:5, T:182). `AGENTS.md:34` adds `python3` to the test's needs ("without any of them"). No case: prose.

Consequences that keep the one-fact list true:
- `AGENTS.md:168` names E42 among the cases that state the sandbox's limits.
- The skill's 143 row says `start` or `send` (`SKILL.md:93`).
- E15's title is now "and nothing is left" (T:334). The key lookup now runs after the agent directory exists, and a failed start still leaves nothing.
- E37–E44 run before E36 (T:570), because E36 checks what every case left behind. A comment says so.
- No exit code, verdict line or allowlist changed. The case count is now 44. No file outside the plan states it; `plan-r3.md`'s `36` is the planner's record.

Mutants. I wrote one mutant per fix by hand and ran each in a scratch copy under
`/data/tmp/claude` (removed afterwards). Each reverts the fix, and each is killed by its target case:

````text
C1/C4 stop: old polling wait target E37: killed — failed: E37 — FAIL 1/44
C5 send: ready check before the lock target E37: killed — failed: E37 — FAIL 1/44
C2 137 always timeout target E38: killed — failed: E38 — FAIL 1/44
C3 00 accepted target E27: killed — failed: E27 E28 E29 — FAIL 3/44
S1 no cd target E39: killed — failed: E39 — FAIL 1/44
S1 no switches target E39: killed — failed: E39 — FAIL 1/44
S2 no fd closing target E40: killed — failed: E40 — FAIL 1/44
S3 no home check target E41: killed — failed: E41 — FAIL 1/44
S4 no cap on stdout target E42: killed — failed: E42 — FAIL 1/44
S4 no cap on stderr target E42: killed — failed: E42 — FAIL 1/44
S5 no symlink check, tracked target E43: killed — failed: E43 — FAIL 1/44
T1 exact count target E44: killed — failed: E44 — FAIL 1/44
T1 zero accepted target E44: killed — failed: E44 — FAIL 1/44
````

The C3 mutant also fails E28 and E29: the start with `--timeout 00` runs and leaves an agent, so those cases' `agents = 0` checks fail.
UNVERIFIED: three things the stub cannot show, and the live probe has to.
- that the real `opencode auth export` still finds the key when it runs from an empty directory with `OPENCODE_DISABLE_PROJECT_CONFIG=1`;
- that 16 MiB is enough for a real turn's JSON events;
- that the real CLI exits soon after its stdout pipe closes at the cap. If it ignores SIGPIPE, the turn runs on, its output discarded, until it ends or times out, and it is reported as exit 7 either way.

## Tests

This section is as of round 1. *Review round 2 fixes* below gives the case count and coverage after round 2.

- Added: `tests/external-agent.test.sh`. It was A2 at E01–E36, byte for byte, and now has E37–E44 plus the E27 and E15 changes above.
  After round 1 it ran three times: in the gate block, then `PASS 44/44` after 20 s, and `PASS 44/44` after 20 s.
  No `slirp4netns`, `bwrap`, `external-agent` or `stub-sleep` process was left
  (`ps … | grep` rc=1), and no test or agent directory was left under `/data/tmp/claude` (rc=1).
  `tests/memory-sync.test.sh` is unchanged: `PASS 35/35`.
- Coverage, as a list (`AGENTS.md` *Tests*). These are the plan's cases, with round 1's added:
  - A1: arguments and roles E27; backend E28; allowlist E29, E31; end date E30; CLI path E32;
    key lookup E15, E33, E39; the copy E06, E07, E08, E43; read-only copy E06; prompt and profiles
    E20, E21; environment and config E09; descriptors E40; home mount points E41; network E10, E11;
    argv and stdin E12; limits E13, E42; redaction E14; control characters and forged lines E16;
    reviewer validation E17–E19, E44; backend errors E22, E23, E38; timeout E24; busy and
    stop-while-running E25, E37; SIGKILL E26; output E01; send E02; list E03; transcript E04;
    stop E05, E37; check E33, E39; verdict set E34; profile census E35; the real repository untouched,
    nothing left E36.
  - Not covered by any case, which the plan accepts: the `die` lines for a flag with no value, an unknown
    argument, a brief or message that is not a file, `--repo` outside a work tree, a repository
    with no commit, failures to write with `mkdir`, `mkfifo` or `jq`, a tool missing in `net_tools`, `lsns`
    finding no owner, a holder that cannot join, a blackhole route `ip` refuses, bwrap not
    reporting a pid, `stop` timing out after 30 s, an unreadable `core.excludesFile`, and a `git config`
    error.
  - Added to that list in round 1: C6's `why` for the gitlink `mkdir`, and C4's re-check in `send`
    (reasons above); the `mkdir` failure of `read_secret`'s directory, which is a single `die`;
    and `lock_agent`'s 10 when the agent directory vanishes before the open, a race like C4's.
    The `137` arm of the timeout check is no longer uncovered for its non-timeout side (E38).
    Its timeout side, timeout's own SIGKILL after the grace, still has no case.
  - A3–A8, B1–B16, C1–C8, R1–R3, K3, T2–T6 are prose, checked by the post-conditions and their guards.
    E20, E21 and E35 check the profiles.
  - V1: post-condition `version 0.4.0`.

## Gates

After round 1, I set
`export TMPDIR=/data/tmp/claude CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`.
Then, from the repo root, I ran the indented command lines of `AGENTS.md` *Gates* as they now stand, as one
bash script. Every `claude` call ran under the block's own throwaway `CLAUDE_CONFIG_DIR`.
Commands run:

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
    claude=$(command -v "${CLAUDE_BIN:-claude}"); : "${claude:?no Claude Code CLI found - set CLAUDE_BIN to the path your host file names}"
    cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX") && [ -d "$cfg" ] && (
      export CLAUDE_CONFIG_DIR="$cfg"
      for p in plugins/glab plugins/memory-sync .; do "$claude" plugin validate --strict "$p" | tail -n 1; done
      "$claude" --plugin-dir ./plugins plugin details glab | command grep -E '^  (Skills|Agents|Hooks) '
      "$claude" --plugin-dir ./plugins plugin details memory-sync | command grep -E '^  (Skills|Agents|Hooks) '
    ); rm -rf "${cfg:?}"
    jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r n s; do echo "$n = $(jq -r .name "$s/.claude-plugin/plugin.json")"; done
    command grep -c user_config plugins/*/hooks/hooks.json; echo "rc=$?"
    command grep -c -F 'not yet confirmed' plugins/memory-sync/scripts/memory-sync.sh plugins/memory-sync/skills/sync-memory/SKILL.md README.md; echo "rc=$?"
    command grep -c -F 'not yet run against a real model' README.md; echo "rc=$?"
    command grep -rH --include='*.md' '^name: .*:' plugins; echo "rc=$?"

Output, leaving out the 79 `ok` lines (35 + 44; E01–E44 all read `ok`):

````text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
rc=0
PASS 35/35
PASS 44/44
✔ Validation passed
✔ Validation passed
✔ Validation passed
  Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
1
rc=0
rc=1
````

Green: five `rc=0`, shellcheck `rc=0`, `PASS 35/35`, `PASS 44/44`, three
validations, `Skills (15)` with `external-agents`, `Agents (5)`,
`Hooks (1)  SessionStart`, the memory-sync lines, both names, `:0 :0 rc=1`,
`1 1 1 rc=0`, `1 rc=0`, `rc=1`. The plan's own guards, run again after round 1, print
`model ids in payload prose 0`, `grok in allowlist 0`, `rev-2 names 0`,
`invisible characters 0`, with the known positive at `1`.

## Security — blast radius

- **Files written in the tree:** the eight A files and six edited tracked files (`AGENTS.md`,
  `README.md`, `plugin.json`, `manager/SKILL.md`, `commands/review.md`, `commands/ship.md`).
  Round 1 changed the script, the test, the skill, `manager/SKILL.md`, `review.md` and `AGENTS.md` again.
  R0.3 had first restored seven tracked files to `889b804`; their rev-2 content is in `rev2-build/tracked.diff`.
- **Files written in the plan folder:** `rev2-build/` (9 files), `result-r3.md`, `follow-ups.md`. The user's two
  notes were moved into `notes/` unchanged; their hashes are above.
- **Files deleted:** the ten untracked rev-2 files R0.3 names, each archived first, with hashes matching
  the plan. Nothing else was deleted. `plan/SESSION-HANDOFF.md`, `plan-r3.md` and every hashed
  planning record are untouched: `sha256sum -c SHA256SUMS-r3` fails only `questions-r3.md`,
  the manager's expected edit.
- **Processes started:** `bwrap`, `slirp4netns`, `nsenter`/`setpriv` holders and the stub CLI,
  from the test and from the 13 mutant runs; two host listeners per run. The test cleans up by
  PID, and none was left. The real `opencode` was not run. No model was called and no real key was read:
  the test's key is a literal dummy in its own throwaway HOME.
- **What the new cases do:** E40–E43 only show that a guard refuses, using benign stubs. E41
  makes a symlink to a path that does not exist, inside the test's own agent home. E43 makes a
  symlink between two directories of the test's own work directory. E42 writes zeros and a fixed JSON line.
- **Network:** the test's sandbox has slirp4netns internet egress. Its cases connect only to host
  loopback, the host's own address and the blackholed documentation address `198.51.100.1`, and all of them are
  `denied` (E10). UNVERIFIED: that the stub sends no packet off the host. This was read from its targets,
  not captured on the wire.
- **`claude`:** `plugin validate` and `plugin details` only, under a fresh `CLAUDE_CONFIG_DIR` in
  `/data/tmp/claude` that was then removed. Nothing was installed, enabled or configured. Nothing in
  `~/.claude` was read or written, and no value of `~/.claude/settings.json` was read.
- **Temp files:** `/data/tmp/claude/fow-r3-base.*`, `fow-r3-tools/` and `fow-mut/`. All three were removed at the end.
- **Secrets:** none in any file or output.

## Files in the tree this developer did not write

`plugins/glab/skills/external-agents/notes/glm.md` and `notes/kimi.md` were untracked. This build did not make
them; their mtimes are 2026-10-17 15:12:36 and 15:12:38 +0400, during round 1. The manager then
identified them as the user's notes and had them moved to the plan folder. That move is recorded under
*Profile tuning (user notes)*.

## Profile tuning (user notes)

The manager decided this step. It is not a plan step.

1. **The move: done, unchanged byte for byte.** It was a plain `mkdir` + `mv` + `rmdir` of the then-empty
   `notes/` directory. Both files had been untracked (`git status` `??`).

   ````text
   before  b8982455c3af3b29f68cdb2bd463c2a0f2c706cc2324043f510fb11721108e22  plugins/glab/skills/external-agents/notes/kimi.md
   before  24145ae0173b3e64ea32e8151077889da541eac21e181e57724755d5a9711fa4  plugins/glab/skills/external-agents/notes/glm.md
   after   b8982455c3af3b29f68cdb2bd463c2a0f2c706cc2324043f510fb11721108e22  plan/feature-opencode-worker/notes/kimi.md
   after   24145ae0173b3e64ea32e8151077889da541eac21e181e57724755d5a9711fa4  plan/feature-opencode-worker/notes/glm.md
   ````

   `ls plugins/glab/skills/external-agents` → `SKILL.md profiles`. No `notes/` is left under `plugins/`.
2. **The two sections: done.** In `plugins/glab/skills/external-agents/profiles/kimi.md`, `## Before the contract` is
   at :8-18 and `## After the contract` at :19-28. In `profiles/glm.md`, they are at :8-18 and :19-31.
   The text is addressed to the model, as `default.md` is. It is taken only from points that apply to an
   OpenCode agent filling a fixed report:
   - Before: the parts of the message — where it works, the rules, the task, the template — are kept apart.
   - Before: two passes, facts first, then the template.
   - After: every finding has a `file:line` and a short word-for-word quote, in the template's own claim
     field, with no new field. That keeps `glab:reviewer`'s finding format.
   - After: the answer is the template filled in, nothing before or after it.
   - After, GLM only: state what was out of scope. It goes where the template asks what was not checked
     (the reviewer's "say what you did not check"), or in one closing line when there is no template.

   It does not repeat `default.md`'s "read all of it", "do only what the task asks", "every claim backed or
   UNVERIFIED" or "every field".
   Left out: web-UI loading checks, OCR, `response_format`/JSON schema/JSON mode, prompt-cache pricing,
   Pydantic, parallel batching, and every context-size or price figure. No model id is named: the
   payload-prose guard prints `0`.
3. **Notes and intro: done.** In each profile, the intro sentence (:3-6) now names the user's notes as the source,
   documentation-derived and not observed. `## Notes` names `plan/feature-opencode-worker/notes/<family>.md` as
   the source, with what was taken and what was left out. The `UNVERIFIED` marker is kept, reworded: it holds
   until L1 captures a real reply; then the profile is tuned from that transcript, which is cited there.
4. **Nothing pinned the profiles' contents.** `command grep -rn -i -E 'empty section|no quirk|unsourced|profiles? (are|is) empty|tune'`
   over the skill, README, AGENTS.md, the script, the test and `default.md` matched nothing (rc=1). The test
   pins no hash or line count of a profile. E35 checks only file names, which did not change.
   The cases that cover the new text:
   - E21 shows that kimi's `## Before the contract` is sent after the default one, and not to a GLM agent.
   - E20 shows that a GLM reviewer's first message holds the profiles and never a profile's notes.
   - No case checks the wording itself; it is prose.

   `deepseek-pro.md` and `deepseek-flash.md` are unchanged and still say that no quirk is known.
   SKILL.md and README make no claim about the profiles' contents.

Gate block after the tuning: `export TMPDIR=/data/tmp/claude CLAUDE_BIN=<as above>`, then the indented command
lines of `AGENTS.md` *Gates*, run from the repo root as one bash script, with the throwaway `CLAUDE_CONFIG_DIR` the block makes.
Commands:

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
    claude=$(command -v "${CLAUDE_BIN:-claude}"); : "${claude:?no Claude Code CLI found - set CLAUDE_BIN to the path your host file names}"
    cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX") && [ -d "$cfg" ] && (
      export CLAUDE_CONFIG_DIR="$cfg"
      for p in plugins/glab plugins/memory-sync .; do "$claude" plugin validate --strict "$p" | tail -n 1; done
      "$claude" --plugin-dir ./plugins plugin details glab | command grep -E '^  (Skills|Agents|Hooks) '
      "$claude" --plugin-dir ./plugins plugin details memory-sync | command grep -E '^  (Skills|Agents|Hooks) '
    ); rm -rf "${cfg:?}"
    jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r n s; do echo "$n = $(jq -r .name "$s/.claude-plugin/plugin.json")"; done
    command grep -c user_config plugins/*/hooks/hooks.json; echo "rc=$?"
    command grep -c -F 'not yet confirmed' plugins/memory-sync/scripts/memory-sync.sh plugins/memory-sync/skills/sync-memory/SKILL.md README.md; echo "rc=$?"
    command grep -c -F 'not yet run against a real model' README.md; echo "rc=$?"
    command grep -rH --include='*.md' '^name: .*:' plugins; echo "rc=$?"

Output, leaving out the 79 `ok` lines (35 + 44; E20 and E21 among them):

````text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
rc=0
PASS 35/35
PASS 44/44
✔ Validation passed
✔ Validation passed
✔ Validation passed
  Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
1
rc=0
rc=1
````

## Review round 2 fixes

These fixes touch the script, the test and the skill's text only. `profiles/kimi.md`, `profiles/glm.md` and
`plan/feature-opencode-worker/notes/` were not touched this round. Where round 1 had grown a guard,
I put a simpler mechanism in its place, as the round's rule asks.
Script is `plugins/glab/scripts/external-agent.sh` (S), test is `tests/external-agent.test.sh` (T),
skill is `plugins/glab/skills/external-agents/SKILL.md` (K). Each test line number is the case's `t` line.

- R2-1 — the copy is NUL-safe end to end. The index is read record by record
  (`while IFS= read -r -d ''`), and mode, object and path come from parameter expansion (S:392).
  Untracked files are read the same way (S:403). The files list is `sort -z -u`. Objects come from
  `rev-list --objects --no-object-names` (S:413). No `tr '\0' '\n'` is left (`grep` rc=1).
  `safe_path` (S:362) refuses, with exit 4 and a `why`, a path that is empty or absolute, has a `..`
  component, holds a control character, or has a symlinked parent (S5, kept). The path is shown with
  `printf %q`, so the reason stays one line. Header S:42.
  Cases: E45 (T:602), an untracked file whose name holds a newline; E46 (T:608), a tracked path
  holding a newline and a tab. Both are exit 4 with nothing left, and E45 first shows that the same
  repository copies cleanly. No case drives the absolute or `..` paths: git does not put such paths in an
  index or in `ls-files -o`, so a test cannot build one. E43 still covers the symlinked parent.
- R2-2 — `list` checks a live turn before `ready` (S:835): running, then broken (not ready), then idle.
  E37 (T:531) now asserts `running` while a start's first turn runs.
- R2-3 — `stop` works under the lock:
  - it signals the turn if one is running, through `turn_alive` (S:731), the same pid and start-time check as before;
  - then `mv -T` moves the agent to `$root/.stopping.<id>` and removes that (S:869);
  - when the locked file is no longer the live `lock`, a start stopped in its first turn has removed itself, and stop prints `stopped:` (S:864).

  Round 1's hold-the-lock-through-`rm` and `send`'s `agent.json` re-check are gone. After `flock`,
  `lock_agent` checks `[ /proc/$$/fd/$lk -ef "$adir/lock" ]` and otherwise exits 10 (S:711). `list` takes
  no lock and creates no file: it reads `turn.pid` with `turn_alive`. It globs `ea-*` only, so it ignores
  `.stopping.*`. Cases E05, E25, E26 and E37 stay green. No case drives the two-process race that the
  rename and the `-ef` check close, and none observes that `list` opens no lock: there is no injection
  point. Both rest on reading the code (`follow-ups.md` 9).
- R2-4 — every turn binds a new, empty `run/home` at `/home/worker` (S:509, made at S:581, removed
  with `run/`). Only `data/` (S:768) is bound back in, at `~/.local/share/opencode`
  (`DATA_IN_HOME`, S:110). The S3 per-path refusal and `HOME_MOUNTS` are removed. The read-only empty
  config mount stays, and E09 checks it. The header (S:30, S:50) and the skill (K:156) say exactly this. The
  stub keeps its sessions and its `started` marker in that data directory (T:60).
  Case E41 (T:563), rewritten: a file in `$HOME` and in `~/.config/x` is gone at the next turn, the data
  file is kept, and no `home/` is left in the agent's state. E02 shows the session continues. Its
  mutant (no data bind) fails E02 and eight more cases.
  UNVERIFIED: that opencode 2.0.31 keeps its database in `~/.local/share/opencode` with `HOME=/home/worker`
  and no `XDG_DATA_HOME`. That is its XDG default, and `findings-r3` R2/R12 show XDG-style paths, but this
  build did not run the real CLI. The offline Integrate block has to be rerun to prove that `send`
  continues the session. That block runs the user's `opencode`, which this dispatch forbids me to run.
- R2-5 — 124 and 137 are TIMEOUT only once the elapsed time has reached the timeout; an early one is
  exit 7 (S:659). `--timeout` refuses more than 7 digits with USAGE (S:725).
  Cases: E38 (T:537), with stub `exit124` → `opencode exited 124 with no error event`, exit 7; E27 (T:462),
  where `12345678` → `--timeout must have at most 7 digits`, one stderr line.
- R2-6 — the decoded, cleaned reply (S:673), the rendered transcript text (S:641) and the error line
  (S:665) go through `redact_stream` too. `slirp.log` goes through `head -c OUT_BYTES` (S:552); the
  filter is opened before the exit FIFO and closes the go FIFO and the lock. On failure, slirp4netns is ended first so
  that its log is complete, and the reason is cut to 300 bytes (S:569).
  Cases:
  - E14 (T:351) adds stub `leak-escaped`: the key with its first character JSON-escaped. The reply and `transcript.txt` show `<redacted>` and never the key.
  - E11 (T:326) adds a slirp4netns that writes one endless 17 MiB line and fails: still exit 9, and the reason is one line under 400 bytes.
  - No case can observe the log cap itself: `run/` is removed when the call ends.

  Raw `transcript.jsonl` can still hold the key in JSON-escaped form. The raw redaction cannot see it,
  and this round asked for the decoded text only (`follow-ups.md` 10).
- R2-7 — `first_prompt` prints `# Before you answer` between the task and the After-the-contract
  profile text (S:491). E20 (T:392) checks that it comes after the brief and before the default
  profile's check; E21 (T:406) checks it for a general agent. The profiles are unchanged, so the
  default and the Kimi/GLM After sections still begin with their own "Before you answer". Smoothing that wording waits for the later profile step.
- R2-8 — the skill's exit-4 row (K:86) is rewritten: the home/config refusal is gone, and the copy's
  refusals are named. The `list` item says a start in its first turn is `running` (K:61). C6's
  gitlink-`mkdir` `why` (S:431) is still reached by no case: the copy's work tree is new and holds only
  directories when it runs, so no test can make that `mkdir` fail. It is listed as uncovered below.

Coverage after round 2, added to the round-1 list:
- copy E45, E46;
- home and data directory E41, E02;
- list E37;
- early 124 and 137 E38;
- timeout digits E27;
- redaction after decoding E14;
- slirp4netns failure reason E11;
- prompt heading E20, E21.

Not covered: the absolute and `..` refusals (git cannot produce such paths), the stop/send rename race and
`list`'s lock-free probe (no injection point), the `slirp.log` cap (removed with `run/`), C6's gitlink
`mkdir` (unreachable from a test), and the uncovered items listed under round 1.

Mutants. I wrote one mutant per fix by hand and ran each in a scratch copy (removed after). Each one reverts its fix:

````text
R2-1 no control-character refusal target E45 E46: killed — failed: E45 E46 E36 — FAIL 3/46
R2-2 list: broken before running target E37: killed — failed: E37 — FAIL 1/46
R2-4 home persists (old layout) target E41: killed — failed: E41 — FAIL 1/46
R2-4 no data bind target E02: killed — failed: E02 E04 E12 E18 E25 E26 E30 E37 E41 — FAIL 9/46
R2-5 124 always a timeout target E38: killed — failed: E38 — FAIL 1/46
R2-5 8 digits accepted target E27: killed — failed: E27 E28 E29 — FAIL 3/46
R2-6 reply not redacted after decoding target E14: killed — failed: E14 — FAIL 1/46
R2-6 rendered transcript not redacted target E14: killed — failed: E14 — FAIL 1/46
R2-7 no heading target E20 E21: killed — failed: E20 E21 — FAIL 2/46
slirp message not bounded target E11: killed — failed: E11 — FAIL 1/46
````

All ten ran after E11's flood stub became one endless line.

The test now has 46 cases, run three times: `PASS 46/46` in the gate block, then after 22 s and after 23 s.
No `slirp4netns`, `bwrap`, `external-agent` or `stub-sleep` process was left (rc=1), and no test,
agent, `.stopping.*` or config directory was left under `/data/tmp/claude` (rc=1). The guards print
model ids `0` and invisible characters `0`. No file outside the plan states a case count.

Gate block after round 2, with `TMPDIR` and `CLAUDE_BIN` as above: the indented command lines of
`AGENTS.md` *Gates*, run from the repo root as one bash script, with the commands as pasted under *Gates*.
Output, leaving out the 81 `ok` lines (35 + 46):

````text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
rc=0
PASS 35/35
PASS 46/46
✔ Validation passed
✔ Validation passed
✔ Validation passed
  Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
1
rc=0
rc=1
````

## Profile pass (round 2)

I touched four files: `plugins/glab/skills/external-agents/profiles/{kimi,glm,deepseek-pro,deepseek-flash}.md`
(mode 644 kept), plus E47 in `tests/external-agent.test.sh`. `default.md` is unchanged (hash
`2fef943d62b3235d`, the plan's). Nothing under `plan/feature-opencode-worker/notes/` was written; I only read
`kimi.md`, `glm.md`, `deepseek-flash.md`, `deepseek-pro.md` and `diff.md` there, fresh, as secondary advice.

- **P1, the report shape.** No profile tells the model to drop or replace the script's report shape. All four
  After sections end with: "Your answer is the template filled in, inside the two report lines when your
  message gives them, and nothing else around it. With no template, answer the task directly." Round 1's
  "nothing before it and nothing after it" is gone. *(Manager correction, analyze round 3: GLM's "in one
  closing line" is still in `glm.md`, as where the out-of-scope note goes when there is no template; it
  does not touch the report shape. See `follow-ups.md` 23.)*
  Case E47 (T:626). For a reviewer on each of `kimi-k3`, `glm-5.3`, `deepseek-v4-pro` and `deepseek-v4.1-flash`,
  it reads only the message the manager sent, the part of `transcript.txt` between `manager:` and the
  stub's `says:`. In that message the profile's first Before line comes before its last After line, and
  then `=== REPORT START ===` and `=== REPORT END ===` follow as whole lines. Exit 8 is expected (the
  `prompt` stub returns no report). Two mutants, written by hand in a scratch copy, show it fails for its reason:

  ````text
  report lines before the profile text (tail moved ahead): killed — failed: E47 — FAIL 1/47
  deepseek-pro Before section emptied: killed — failed: E47 — FAIL 1/47
  ````

  My first E47 read the whole transcript and did not kill the first mutant, because the stub's reply echoes
  the prompt after it. Restricting the case to the sent message fixed that.
  UNVERIFIED: that a real model keeps the marker lines. Only L1 can show that.
- **P2, the part names.** No profile names a heading. They say "the task", "the rules", "the template",
  "the two report lines" — words that hold for both roles. The After sections carry no "Before you answer:"
  lead of their own: they read on from the script's `# Before you answer` and default.md's list. The default's
  own "Before you answer, check your work …" still follows the heading; `default.md` was left alone, as instructed.
- **Kimi** (`kimi.md`, Before :8, After :15). A strict professional tone, with no filler, pleasantries or
  meta-commentary. Every claim is tied to its source, a `file:line` and a short word-for-word quote, in the
  template's own claim field, and no new field. The After section checks the citation.
- **GLM** (`glm.md`, Before :8, After :14). Plan, then analyse, then act. The plan, for the model itself,
  settles the hard constraints and what is out of scope before it starts. In the answer, out of scope goes
  where the template asks what was not checked.
- **DeepSeek Pro** (`deepseek-pro.md`, Before :8, After :15). First principles, failure modes and edge
  cases. When the task's premise looks wrong it says so, as a finding or a line inside the template,
  never as a section of its own.
- **DeepSeek Flash** (`deepseek-flash.md`, Before :9, After :16). The task as one verb-led instruction,
  every explicit "do not" binding, and no filler.
- **All four** have the silent self-check (draft, critique "as a hostile critic would", fix), with the
  critique kept out of the answer, and then the P1 sentence. None repeats `default.md`'s points (read
  everything, only the task, claims backed or `UNVERIFIED`, every field).
- **Notes and intro, per profile.**
  - The intro now says that the sections are tuned from the user's notes, which another model wrote: secondary, not yet checked against a reply.
  - The *Notes* source is `notes/<family>.md` plus `notes/diff.md`, documentation-style and not observed.
  - What was taken is listed.
  - The "Left out" line lists the notes' answer shapes, visible `<thinking>` blocks, "INSUFFICIENT DATA" (the repo's rule is `UNVERIFIED: <claim> — <why>`), tool-calling JSON directives, `[INSERT …]` placeholders, and every architecture, parameter, context-size, cost or training claim. Some of those are wrong; a persona does not select experts.
  - The `UNVERIFIED` marker is kept: tune from L1's transcript and cite it.
- **Pins.** No test, skill or README line pinned these files' text. `command grep -c -i profile` gives 0 in the skill, and
  README's only hit is `AWS_PROFILE`. E35 checks only file names, unchanged. E21's `PROFILE-MARK`
  insertion still works. The guards print model ids `0` and invisible characters `0`.
- Hashes now: kimi `7ad1561d7b5113ef`, glm `504c330908c8e309`, deepseek-pro `12b572dbe068552b`,
  deepseek-flash `0b5a1d7991ff07cc`.

Gate block after the pass, with `TMPDIR` and `CLAUDE_BIN` as above: the indented command lines of `AGENTS.md`
*Gates*, run from the repo root as one bash script, with the commands as pasted under *Gates*. Output, leaving out the 82
`ok` lines (35 + 47):

````text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
rc=0
PASS 35/35
PASS 47/47
✔ Validation passed
✔ Validation passed
✔ Validation passed
  Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
1
rc=0
rc=1
````

No `slirp4netns` or `bwrap` process was left (`0`), and no test or agent directory was left under `/data/tmp/claude` (`0`).

## Follow-ups

In `follow-ups.md`:
1. K2 is not applied, and its replacement still closes an interactive shell.
2. The skill's post-condition hash moved. After round 1, so did the hashes of the files listed above.
3. The offline Integrate block is for Stage 4.
4. The plan's mutant table was not re-run.
5. bwrap `--disable-userns` (not now; it needs the live probe).
6. Binding only the needed files of `/etc` (not now; it needs the live probe).
7. No case drives C4's re-check in `send`.
8. The Kimi and GLM profiles stay UNVERIFIED against a real reply until L1. Tune them from its transcripts.
9. No case drives R2-3's stop/send rename race or proves that `list` opens no lock.
10. Raw `transcript.jsonl` can hold a JSON-escaped key, which raw redaction cannot see.
11. Rerun the offline Integrate block after R2-4 to prove the data directory's path and session continuity on the real CLI.
12. All four family profiles stay UNVERIFIED against a real reply until L1; tune each from its transcript.

## Not done

- L1a, L1b, L1c (the user's), the offline Integrate block (Stage 4), the plan's mutant run (record).
- Commits 1 and 2 (not this developer's).
- UNVERIFIED, carried from the plan: I7, I8, rev-2 I3 and I5, the back-out version inference, and that
  slirp4netns itself has no exploitable bug. UNVERIFIED, from round 1: the three stub-only claims at the
  end of *Review round 1 fixes*.
