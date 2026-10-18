# Result — feature-codex-agent, steps P1–P4

Developer, 2026-10-18. Scope was P1–P4 only, in two files:
`plugins/glab/scripts/external-agent.sh` and `tests/external-agent.test.sh`.
The working agreement is `AGENTS.md`, read from disk. Its *Tests* section
replaces any generic rule about coverage or fakes for these scripts. Nothing
was staged, committed or pushed. No Codex or OpenCode CLI ran, and nothing
under `~/.codex` was read, listed or written.

## Stages

Line numbers are in the tree as left (script sha256 `39a194d9…dae33`, test `ff66c0f9…e2574`).

- **P1 — done.** OpenCode's code moved into its adapter, with no change in behaviour.
  - Adapter-contract comment: `external-agent.sh:226-239`.
  - New OpenCode adapters: `opencode_isolation` :346, `opencode_raw_name` :348, `opencode_raw` :349, `opencode_ran` :351, `opencode_session_ok` :353, `opencode_effort_ok` :355, `opencode_secret_hint` :357.
  - `DATA_IN_HOME` and its comment moved to :360-362, just above `opencode_mounts` :365.
  - `opencode_model_allowed` :369 (the body of the old `model_allowed`, model taken as `$1`); `opencode_check` :381.
  - `model_allowed` is now the dispatcher :591. `read_secret`'s message ends with the hint :601. `sandbox_args` calls `"${backend}_mounts"` :807.
  - `turn.jsonl` renamed `turn.out` at every use (:907, :890, :1021, :1041, :1183). The raw line is now `"${backend}_raw" >>"$adir/$("${backend}_raw_name")"` :880.
  - `known_backend` :564 and `known_list` :565, used in both "(known: …)" messages (:1135, :1284).
- **P2 — done.** The Codex adapter set, :392-562:
  - `codex_isolation`, `codex_raw_name`, `codex_raw`, `codex_effort_ok`, `codex_session_ok`, `codex_model_allowed`;
  - `codex_argv` :430, `codex_env` :451;
  - `CODEX_BLOCK_AWK` :471, `codex_block` :486, `codex_field` :487, `codex_ran` :492, `codex_session` :493;
  - `codex_text`, `codex_error` :499, `codex_render` :504, `codex_verify` :514;
  - `codex_check` :528, which uses the plan's jq program word for word (:552-556);
  - `model_optional` :567, next to `known_backend`.
- **P3 — done.**
  - Header comment: :1-111. Its Codex list starts at :82.
  - `cleanup` group kill: :176-183.
  - `first_prompt` host text: :730-769.
  - `run_turn`, split into the common start and tail :874, `run_sandboxed` :895 and `run_host` :957.
  - `finish_turn`:
    - `header()` :1006;
    - verify :1020;
    - the host header-block check :1029-1034;
    - the session check on continued turns :1035-1039.
  - `cmd_start`:
    - `--effort` :1118 and :1123;
    - D19's `--model` line :1130;
    - `isolation` and the effort check :1136-1137;
    - the host CLI path, absolute but not resolved :1143-1148;
    - no `data/` dir :1152-1156;
    - no `read_secret` :1161;
    - `effort` and `ran` in agent.json :1162-1166;
    - D28 head and branch :1171-1177.
  - `cmd_send`:
    - `isolation` :1204;
    - `"${backend}_session_ok"` :1212;
    - `net_tools` and `read_secret` for sandbox backends only :1214-1217.
  - `cmd_list` model column: :1240.
  - `cmd_check`: :1274-1296, with `"${backend}_check"` at :1295.
  - Globals `isolation=''` and `turn_model=''`: :1300.
- **P4 — done** (`tests/external-agent.test.sh`).
  - Header comment: :1-23.
  - `CXH` is set before the trap :31.
  - `cleanup` kills the pids in `$CXH/pids`, each only after an environ check :33-44.
  - OpenCode stub scenario `othersess`: :154.
  - Stub codex: :176-268. `CLI_CX` and `codex-link`: :270-272.
  - `cstart` and `csend`: :346-347.
  - E28 now uses `--backend nosuch` and checks `(known: codex, opencode)`: :590-592.
  - E50–E68: :788-1003.
  - E36 is still last, with "or Codex stub" in its name: :1006.

## Blocked

Nothing.

## Unplanned changes

These are implementation choices inside the named steps. Each one is listed so the analyzer can judge it.

- **P2 `CODEX_BLOCK_AWK`** (`external-agent.sh:471`). One awk program, run with `part=block` by `codex_block` and with `part=rest` ("the stderr after the block") by `codex_error` and `codex_render`.
  - The plan names those three functions but not the shared program. The alternative was two copies of the parser.
  - The 20-line window and the first-block rule are enforced twice: once by the early exit and again in END.
- **P2 `cx`**, a function nested in `codex_check` (:540). It runs each of the three check commands in a subshell: environment unset, `codex_env` exported, `cd "$authd"`, `timeout 60`, stdin `/dev/null`.
- **P2 `debug models` stderr** goes to `/dev/null` (:552). The plan's "stderr kept in a variable" is met for `login status` and `sandbox`. For this command only stdout is read, so the variable would be dead, and shellcheck would flag it.
- **P3 `cd -- "$repo" || exit 1`** in `run_host`'s subshell (:978). `cd` can only fail there after the toplevel check has just passed, in a race. The guard stops Codex from running from the script's own working directory. The turn then fails as exit 7 ("codex exited 1 with no error event").
- **P3 agent.json `effort`** stores the given level, or `""` when none was given (:1164). The plan says "gains `effort` and `ran`, both `""`". I read that as their default, because D9 says the effort "is stored and passed on every turn".
- **P3 step-5 message.** It is `"$backend printed no header block naming its model and session"`, which prints exactly the plan's text for codex. The literal "codex" sits in a host-generic step of `finish_turn`.
- **P3 header usage.** `--model <id>` keeps its place in the usage line, and the next lines say it is optional for codex.
- **P1** moved `cmd_check`'s "No agent exists here…" comment into `opencode_check` with the lines it describes (*comments*: kept, not dropped).
- **P4, the plan text against what I built.**
  - The plan says the OpenCode stub "gets two scenarios" but names only one new one, `othersess`, and says `fds` "stays as it is". I added `othersess` only.
  - The stub's `argv` scenario also prints `$0`, so E51 can check the plan's item 1, `<cli>`, as the link path.
- **P4 test helpers:** `pids_gone` (E60; a zombie not yet reaped counts as gone), `checks` (E59), `v` (E58), `uuid_re` and `xc` (the shared argv list).
- **P4 redirection order.** E60's wait loop has `2>/dev/null` before `<"$CXH/pids"`, so a missing file prints nothing. The first run printed one stray stderr line before this fix.

## Tests

19 cases added (E50–E68); E28 and E36 changed; one OpenCode scenario and the stub codex added. Result: **`PASS 68/68`**, every line `ok` (gate below).

Coverage, as a list (`AGENTS.md` *Tests*):

- **P1:** E01–E49, all green.
  - The renamed backend and `known_list`: E28.
  - `opencode_check`: E33 and E39.
  - `opencode_mounts`: E09, E12 and E41.
  - `opencode_raw` and the `turn.out` rename: E04 and E14.
  - The start of `read_secret`'s message: E15.
  - `opencode_model_allowed`: E29, E30 and E31.
  - D19: E58, last two lines.
  - The session check, now behind `opencode_session_ok`: E05 and E18 (send paths).
- **P2:**
  - E50: `codex_raw`, `codex_ran`, `codex_session`, `codex_text`, `codex_render`.
  - E51 and E52: `codex_argv`, exact lists for `exec` and `exec resume`.
  - E54: `codex_verify`, for both a networked sandbox and an approval policy.
  - E55 and E65: `codex_block` and `codex_field` — the 20-line window, the forged second block, malformed model and session.
  - E56: `codex_env`.
  - E57: `codex_error`.
  - E58: `codex_model_allowed` and `codex_effort_ok`.
  - E59: `codex_check` and its jq program, on the recorded shape; plus login 4, sandbox 12, models unavailable, and no `check.*` left.
  - E61 and E62.
- **P3:**
  - E50: a host start, no `work/` or `data/`, the transcript heading.
  - E52, E53 and E66: D8 on both backends.
  - E54, E55 and E65: `finish_turn`'s order; the `default` and `.model` fallbacks.
  - E60: the group kill after a turn, `cleanup`'s group kill at `stop`, the timeout.
  - E61: the host text, in order, with the real top.
  - E63: `list` and D28.
  - E64: both caps.
  - E67: `run_host`'s exit 4.
  - E68: descriptors closed.
  - E51: D11, the link not resolved.
  - E36.
- **P4:** E36 last. `cleanup` kills `$CXH/pids` behind its environ guard; no case drives that path directly. A run killed mid-E60 does reach it. On a green run E60's processes are already gone (E60 checks this).

Mutation check. Each mutant ran against a copy of the plugin under `$TMPDIR`, never the tree:

| mutant | result |
|---|---|
| verify always passes | E54 red |
| no session check on continued turns | E53 and E66 red |
| no descriptor close in `run_host` | E68 red |
| no environment unset in `run_host` | E56 red |
| no host header-block check | E55 and E65 red |
| no moved-repository check | E67 red |
| no effort check | E58 red |
| CLI path resolved for host | E51 and E52 red |
| model form not checked in `codex_ran` | E65 red |
| no group kill in `cleanup` | no PASS line within 300 s: the surviving `sleep 300` holds the stream filters, so the stopped send never returns |
| window removed in all three places | E55 red |
| window removed in one place only | `PASS 68/68` (the window is enforced twice; see *Unplanned changes*) |
| first-block rule removed in END only | `PASS 68/68` (the early exit at the block's closing line enforces it again) |

The run killed at 300 s left its own `$W`, `/data/tmp/claude/external-agent-test.Mp9zf1`. I checked that its two recorded pids were gone, then removed the directory.

Not covered by any case, and accepted:

- `codex_check`'s exit 4 for a missing tool (the plan's reason: the tools live in `/usr/bin` beside bash, git and jq).
- `opencode_secret_hint`'s tail (E15 matches the start of the message; the tail is moved text).
- A host repository with no commit (D28).
- A relative `--cli` for codex, made absolute in `cmd_start` and `cmd_check`. Every case passes an absolute path. It is one line, and E51 shows the path is not resolved.
- `CODEX_BLOCK_AWK` rejecting a non-`key: value` line inside the block. No scenario prints one.
- `run_host`'s `cd … || exit 1` (unreachable without a race).
- The D13 names the test does not set. E56 shows that no other name passes.
- `cleanup`'s group kill when the script itself is SIGKILLed, which O2 measures.
- The real Codex: S1, O1 and O2, at Stage 4 (D20).

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root, in the order `AGENTS.md` *Gates* gives:

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0

    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
    rc=0

    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    ok T01 … ok T35 (35 lines, all ok)
    PASS 35/35

    bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null >"$out"
    external-agent.test rc=0
    ok E01 … ok E35, ok E37 … ok E68, ok E36 (68 lines, all ok)
    PASS 68/68

Baseline, before any edit, at `067b719`: the same block printed five `rc=0`, `rc=0`, `PASS 35/35` and `PASS 49/49`. After P1 alone, E28 failed (codex was now known) and E29 failed because E28 had left an agent behind. That is the expected change, and P4's E28 fixes it.

Post-conditions for my files (*After* §2), run on the tree as left:

    S28 12 NOT READ-ONLY        -> 1
    S29 on every exit 2-12      -> 1
    S30 die 12 'NOT READ-ONLY'  -> 2
    S31 host-text fragments     -> prints nothing
    S32 E50 … E68 each ok       -> prints nothing
    S33 ^NOT OK                 -> 0
    S34 --backend nosuch by E28 -> 1
    S35 known: opencode)        -> 0
    G1  ok E28                  -> present
    G3  .codex outside comments -> nothing
    G4  ^codex_…() {            -> 17 functions, codex_isolation … codex_check

S36's `git status --short` shows ` M` for both of my files. The six other ` M` files are the parallel P5–P10 developer's, and `?? plan/` is listed too. The plugin gates (`claude plugin validate`, `plugin details`) belong to the whole change. I did not run them.

## glab:security report

    ## Claims
    | claim | proven / inferred | how |
    |---|---|---|
    | OpenCode behaviour is unchanged by P1 | proven | E01–E49 green after P1, apart from the planned E28 change; all green after P4 |
    | each new check has a case that fails without it | proven | mutation runs above, each against a copy |
    | no `.codex` path in the script's code | proven | G3 printed nothing |
    | the script never runs a real Codex or OpenCode here | proven | every case passes a stub via --cli; no CLI was run by hand |
    | the real Codex accepts this argv, prints this header, resumes this id | inferred | from findings §9.2 and §9.8; S1, O1 and O2 at Stage 4 prove it |
    | the turn's process group id is the started pid | proven | E60's both pids gone after stop and after timeout; probe: `ps` showed pid = pgid = sid for the chain |

    ## Gates
    build: bash -n && test -x (five scripts) -> ok
    test:  bash tests/memory-sync.test.sh … -> ok (35/35); bash tests/external-agent.test.sh … -> ok (68/68)
    lint:  shellcheck (five scripts) -> ok

    ## Blast radius
    changed:  external-agent.sh start (--effort, optional --model for codex, host path), send (session check by adapter,
              isolation), list (model column: ran, else model, else default), check (per-backend), finish_turn (exit 12,
              header-block check, continued-session check on both backends), header() (model field), run/turn.jsonl
              renamed run/turn.out (internal, removed after each turn), agent.json gains effort and ran
    callers:  the glab:external-agents skill and glab:manager (P5/P6, the other developer); the test. OpenCode's stdout
              contract, exit codes 2–11, transcript.jsonl and transcript.txt names are unchanged (E01–E49).
              A 0.5.0 agent.json lacks effort and ran: meta prints "" and list falls back to .model, so it still works.
    data:     $TMPDIR/glab-external-agents/<id>/ only; the user's repository is read, never written (E36 fingerprint);
              ~/.codex is never touched by the script (Codex itself writes there on real runs)
    rollback: revert both files; no persisted format other than agent.json's two added keys, which 0.5.0 ignores

    ## Not done
    S1, O1, O2 (Stage 4, D20); the plugin gates; P5–P10.

## Follow-ups

I wrote nothing to `follow-ups.md`. These were noticed and left alone:

- `codex_env` and `opencode_env` pass `NAME=value` one per line. A value that holds a newline would split into two lines, and the second would be exported as a name of its own. The values are the user's own environment, and OpenCode had the same protocol before this change. Out of scope.
- `codex_raw` writes the turn's stdout as Codex printed it. A final message with no trailing newline would join the next turn's `=== turn n stderr ===` line in `transcript.log`. This is cosmetic, and no case shows it.

## Not done

- P5–P10 belong to the other developer, and I did not touch their files.
- S1, O1 and O2 belong to Stage 4, by D20.
- `UNVERIFIED: the real codex 0.163.0 accepts every flag of codex_argv after "exec resume", and prints the header block as the stub does — O1 at Stage 4.`

---

# Round 2 (revision 4)

Developer, 2026-10-18, building D31 and the revision-4 changes to D7, D13, P2, P3 and P4. The file boundary is the same: the script and its test. No Codex command ran, and nothing under `~/.codex` was read. Nothing was staged or committed. The line numbers above, from round 1, have shifted; the ones below are for the tree as left (script sha256 `9fec6332…0631c`, test `9e117295…222ec`).

## Stages

- **P2 — done.**
  - `codex_argv` item 4 adds `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<agent id>"`, with the id from `meta id` (`external-agent.sh:487`). The why is in a comment at :473-476.
  - `codex_env <marker>` (:501) ends with `GLAB_EXTERNAL_AGENT=<marker>` (:508).
  - `sweep_agent <marker>` (:212), a common function beside `cleanup`, with its why at :202-211.
    - It reads environ with `{ tr '\0' '\n' <"$d/environ"; } 2>/dev/null` and matches the exact line.
    - It reads the start time, re-checks the line and the start time, then sends `kill -KILL`.
    - It makes a second pass after 1 s, and prints nothing.
  - `codex_check`:
    - step 2: `cmark=check-<16 hex>` (:588) in a global (:175), and `codex_env "$cmark"` (:589);
    - step 4: `sandbox … -c "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$cmark\""` (:601), then `sweep_agent "$cmark"` (:603), then the exit-12 check.
- **P3 — done.**
  - `run_host`:
    - step 3: `"${backend}_env" "$(meta id)"` (:1019);
    - step 8: `sweep_agent "$(meta id)"` (:1059), after the group KILL;
    - step 9: then `wait "$jpid" "$epid"`.
  - `cleanup`: after the host group kill, `sweep_agent` for the agent when `adir` names an agent (:189), and `sweep_agent "$cmark"` when it is set (:193).
  - `cmd_stop`: `sweep_agent "$1"` (:1325). It sits after the `flock` block and before both the moved-aside check and `mv -T`, so the path where a start stopped itself is swept too. `stop`'s output and exit codes are unchanged.
  - The header's Codex list states D31 and why the group kill is not enough (:106-118).
- **P4 — done.**
  - The stub's `sleep` scenario (`tests/external-agent.test.sh:261-272`):
    - it reads `<v>` from `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<v>"`;
    - it starts `setsid env GLAB_EXTERNAL_AGENT=<v> sleep 300 &`;
    - it writes its own pid and that child's to `$CXH/pids`, then waits.
  - The stub's `env` scenario also prints `GLAB_EXTERNAL_AGENT=` (:252).
  - E51 and E52: the expected argv carries each agent's marker, through `xm <id>` (:815-829).
  - E56: the names are exactly `CODEX_HOME GLAB_EXTERNAL_AGENT HOME LANG PATH TERM TMPDIR`, and the marker's value is the agent id (:869-873).
  - E60: also checks that the turn's argv carries the marker (:925). Its name now says that only the sweep reaches the child (:933).
  - E69, new (:1019-1038), before E36:
    1. a decoy with `ea-0000000000000000`;
    2. `start sleep` in the background;
    3. SIGKILL to the script's own pid;
    4. the known positive: the child is still alive after 2 s;
    5. `stop` prints `stopped:`, and both stub pids are gone;
    6. the decoy is still alive, and the test then kills it by its pid.
  - The "E37-E69 run before E36" comment is updated (:654).

## Blocked

Nothing.

## Unplanned changes

- **The host stream filters no longer hold the agent's lock** (`external-agent.sh:1020-1025`: `>(exec {lk}>&-; redact_stream …)`). E69 and D31's `cmd_stop` sweep forced this.
  - **Evidence.** E69 first ran as the plan wrote it and failed: `rc=11 … BUSY: agent … did not end its turn within 30 s`. A probe then started a Codex stub turn, SIGKILLed the script, and listed the lock file's holders:

        holders of …/ea-c714cf25d635d3ec/lock:
          pid=3461772 bash plugins/glab/scripts/external-agent.sh start …   (×4: the two process-substitution subshells and their pipelines)
          pid=3461777 awk -v cap=16777216 …                                  (×2)
          pid=3461779 head -c 16777217                                       (×2)

  - **Why that blocks the sweep.** The filters inherit the lock descriptor, and they live as long as the helper's stand-in holds the streams. So after a SIGKILL `stop` can never take the lock, and D31's sweep "once the turn's lock is taken" is never reached.
  - **The fix** closes the lock in the two host filters only, as `wire_network`'s log filter already does. OpenCode's filters are unchanged. With it, E69 passes. The probe killed only its own recorded pids and removed its directory.
  - **What it changes.** A live turn is still guarded: the script itself holds the lock until it exits. The plan's text does not name this change. If the planner would rather fix it another way, for example by sweeping before the lock, the hunk is these two lines and their comment.
- **`proc_start <pid>`** (:231). A helper for field 22 of `stat`, which `sweep_agent` reads twice per process. It counts fields after the closing `)`, as `lock_agent` and `turn_alive` do inline.
- **`cmark` is not cleared after `check`.** `cleanup` sweeps it once more at exit, which costs about 1.3 s per `check`. The plan says to keep it global for `cleanup` and does not say to reset it.
- **Test:** E69's decoy is added to `LISTENERS` while it runs, so that `cleanup` kills it by PID if the test dies in between. It is removed again (`unset 'LISTENERS[-1]'`) once E69 has killed it, so `cleanup` never kills a reused PID. The comment at :44 says so.
- **Cost, as the plan designed it.** One `sweep_agent` takes about 1.3 s here (82 processes of this uid: the 1 s second pass plus the scan, measured with `time`). It runs after every Codex turn and at every `stop`, OpenCode's included. The suite went from about 38 s to about 3 min.

## Docs, skill or README changes revision 4 may need (not made: outside my boundary)

- `plugins/glab/skills/external-agents/SKILL.md`, *What the script guarantees*, Codex: it should say that a turn's processes carry `GLAB_EXTERNAL_AGENT=<agent id>`, and that `stop` ends whatever a killed turn left. The plan's P5 `:64` change is the coordinator's to check.
- `README.md` and the skill, if either states the environment allowlist: it now includes `GLAB_EXTERNAL_AGENT`.
- `stop` now takes about a second longer, for OpenCode too. Worth one line in the skill if it times `stop`.

## Tests and coverage (list)

- **D31 marker, argv channel:** E51, E52 and E60.
- **D31 marker, env channel:** E56.
- **`sweep_agent` after a turn:** E60's timeout half. The setsid'd child dies only through the sweep: the group kill misses it, and `stop` does not run in that half.
- **`sweep_agent` in `cleanup`:** E60's stop half. The `stop` sweep also runs there, so the two overlap.
- **`sweep_agent` in `cmd_stop`:** E69, with its known positive (the child is alive before `stop`).
- **Exact-line matching:** E69's decoy.
- **`codex_check`'s marker and sweep:** E59, which shows rc and output unchanged. The stub's `sandbox` starts no child, so no case shows `check`'s sweep killing anything. That is accepted: it is the same function on the same path, and E60 and E69 cover it.
- **The lock-free host filters:** E69. Without the change, E69 is exit 11.

Mutants, each run against a copy under `$TMPDIR`:

| mutant | result |
|---|---|
| no sweep in `cmd_stop` | E69 and E36 red |
| marker matched by name only, not by the exact line | E69 red (the decoy was killed) |
| no `-c …set…` in `codex_argv` | E51 and E52 red, then no PASS line within 500 s: the stub child has an empty marker, so no sweep finds it, and it holds the streams |

Not covered, and accepted:

- A PID reused between the two reads of `sweep_agent`. It cannot be staged without racing the kernel.
- The real `codex exec` passing `set` to its helper: `UNVERIFIED`, the plan's own item, for the first live run.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root:

    for s in …five scripts…; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    shellcheck …five scripts…; echo "rc=$?"
    rc=0
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    PASS 35/35          (every other line ok)
    bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null >"$out"
    external-agent.test rc=0
    PASS 69/69          (70 lines; every other line ok, E69 before E36)

Post-conditions:

    S28 1 · S29 1 · S30 2 · S31 prints nothing · S32 (E50…E69) prints nothing · S33 0 · S34 1 · S35 0
    S38 shell_environment_policy.set.GLAB_EXTERNAL_AGENT -> 2 (codex_argv :487, codex_check :601)
    S39 ^sweep_agent() { -> 1;  sweep_agent "$1" -> 1325, inside cmd_stop (1309-1338)
    G1 ok E28 present · G3 nothing

`git status --short` shows ` M` for both of my files, and the other developer's six files are unchanged by me. Nothing of mine is left under `$TMPDIR`.

## glab:security report

    ## Claims
    | claim | proven / inferred | how |
    |---|---|---|
    | a setsid'd child of a host turn ends at the end of the turn, at stop, and after a SIGKILL of the script | proven | E60, E69 (with E69's known positive) |
    | the sweep kills only the exact marker | proven | E69's decoy alive; loose-match mutant turns E69 red |
    | stop could not reach its sweep without the lock-free filters | proven | E69 rc=11 run, and the lock-holder probe output above |
    | the real codex exec passes set to its helper | inferred | findings §9.9 (codex sandbox only); first live run |

    ## Gates
    build: bash -n && test -x -> ok · test: 35/35, 69/69 -> ok · lint: shellcheck -> ok

    ## Blast radius
    changed:  codex_argv (one more -c), codex_env (marker arg and line), codex_check (marker, sweep), run_host (env arg,
              sweep, filters without the lock fd), cleanup (sweeps), cmd_stop (sweep for every backend, +~1.3 s);
              new sweep_agent and proc_start
    callers:  sweep_agent is called only by this script; cmd_stop's output and exit codes are unchanged (E05, E25,
              E37, E63, E69); codex_env/codex_argv have one caller each (run_host, codex_check)
    data:     none persisted; the sweep sends SIGKILL only to this uid's processes holding the exact
              GLAB_EXTERNAL_AGENT=<id> line, re-checked with the start time
    rollback: revert the two files

    ## Not done
    The O2 rerun (Stage 4); the docs listed above (another slice).

---

# Round 3 (review r1)

Developer, 2026-10-18. The items in my slice of `review-r1.md`: C1, C2, C3, C-A, C-B, C-D, S-4, T4 (the script side), T-7, T-8 and T-9, plus the S1 header wording the coordinator sent after the Unix-socket probe. The file boundary is the same: the script and its test. No Codex command ran, nothing under `~/.codex` was read, and nothing was staged. Lines are for the tree as left (script sha256 `352e3eeb…a5158`, test `be94fb1e…77ff4`).

## Items

- **C1 — done**, both of the reviewer's fixes plus the new case.
  - `cmd_send` sweeps the agent before `rm -rf "$run"` when isolation is host (`external-agent.sh:1330-1333`).
  - The cap flags are `capped.$$.stdout` and `capped.$$.stderr` in `run_sandboxed` (:1001-1002), `run_host` (:1065-1066) and `finish_turn` (:1117).
  - **E70**, new, after E69 (`tests/external-agent.test.sh:1067-1083`):
    1. a `send` of `late-flood` runs, and its script is SIGKILLed;
    2. the known positive: the stand-in is still alive;
    3. a 6 s `send` of `slow` follows. It must give rc 0, show turn 2, and leave both of the old pids gone.
  - `late-flood`'s child floods the old stdout 2 s later, which lands during the slow turn.
- **C2 — done.**
  - `cleanup`'s first line is `trap '' HUP INT TERM` (:183).
  - `host_turn` (:178) is set to the agent id in `run_host` (:1067) and cleared only after the post-turn sweep returns (:1102). `cleanup` sweeps whenever it is set (:201). This replaces the old `adir`-based sweep inside the `sandbox_pid` branch.
- **C3 — done**, all four parts.
  - `sweep_agent` keeps a `hit` flag, and runs pass 2 (after `sleep 1`) only when pass 1 killed something (:228).
  - `cmd_stop` skips the sweep only when `agent.json` names a known backend whose isolation is `sandbox` (:1381-1384).
    - **Departure from the reviewer's wording**, which was "sweep only when agent.json names a host backend or is missing". Mine also sweeps when `agent.json` exists but names no backend this script knows (an unreadable or corrupt file). Such an agent cannot be shown to be an OpenCode one, so skipping its sweep would be the unsafe reading.
  - `cmark=''` right after `check`'s sweep (:636).
  - `environ` is read with `mapfile -d ''` (C-D).
  - **Wall time: 52 s** for `tests/external-agent.test.sh`. It was 3m02s in round 2 and 38 s in round 1.
- **C-A — done.** `cmd_send` computes `isolation` after `lock_agent` (:1319), with the reason in the comment above it.
- **C-B — done.**
  - `header` is top-level, as `header <agent id> <backend> <model asked for, or empty>` (:1108). All seven `finish_turn` calls and the reply path pass the arguments.
  - `codex_verify <agent id> <model>` (:589) calls `header "$1" codex "$2"`.
  - The nested `cx` is now top-level `codex_cmd <dir> <marker> <command...>` (:606). It builds its environment from `codex_env "<marker>"` inside its own subshell. It is a helper of `codex_check`, not an adapter.
  - Once `cmark` has been swept and cleared, `debug models` runs under `codex_cmd "$authd" ''`, so its `GLAB_EXTERNAL_AGENT` is empty. That command starts no sandbox helper.
- **C-D — done.** `environ_has </proc/<pid>> <entry>` (:244) reads environ with `mapfile -d '' -t` and compares whole entries. `sweep_agent` uses it for the first match and for the re-check. This replaces both `tr` forks, which is most of C3's speed-up.
- **S-4 — done.** `check`'s jq keeps only slugs that match the model-id regex and levels in `codex_effort_ok`'s set, and its output goes through `clean` (:640-651). The comment says why: the catalog comes from outside.
- **T4 (script side) — done.**
  - `codex_model_allowed` refuses `default` with exit 5: "default is not a Codex model id; leave --model out for Codex's default" (:483). The comment says `default` is the word the header prints, not an id.
  - E58 gains `--model default` → 5 (test :901).
- **T-7 — done.** The comments that cited plan ids now cite the tag form:
  - `[feature-codex-agent/plan.md D31]` (:200, :1062, :1099, :1332, :1377);
  - `[feature-codex-agent/findings.md §9.9]` (:214);
  - `[feature-codex-agent/findings.md §9.2]` and `§9.8` (:458-459);
  - `[feature-codex-agent/questions.md Q5]` (:478).
  - `(spec, *Measurements*, P4 …)` at :357 is pre-existing OpenCode spec text, not a plan id of this change. I left it alone.
- **T-8 — done.** E56 starts with `HTTPS_PROXY=x USER=t` and expects exactly `CODEX_HOME GLAB_EXTERNAL_AGENT HOME HTTPS_PROXY LANG PATH TERM TMPDIR USER` (test :883-890).
- **T-9 — done.**
  - The stub appends to `$CXH/pids` (test :284).
  - E60, E69 and E70 count its lines first and read the two that follow, through `npids` and `pids_after` (:937-941). Nothing removes the file, so `cleanup` sees every case's pids.
  - `alive <pid>` (:942) replaces the two inline zombie checks.
- **S1 header wording — done** (:90-94).
  - The commands change no file and have no network, neither IP nor Unix-domain sockets, as measured offline with `codex sandbox` and not in a real turn.
  - Codex itself reaches OpenAI, and keeps the session, what the model read included, under `~/.codex`.
  - The host first message at :801 ("Your commands have no network.") is **unchanged**. It is the plan's verbatim host text (D24), which S31 and E61 pin, and the probe shows it is true. Putting "measured offline" in the model's own prompt would be wrong. The header comment is where the hedge goes.

## Unplanned changes

- **E69 has a second decoy** (test :1053-1055). Its environment holds this agent's marker only inside another value, after a newline. It must survive the sweep. This is the case that covers C-D. Both decoys sit in `LISTENERS` while they run, and both are taken out once killed (`unset 'LISTENERS[-1]'` twice; `[-2]` after `[-1]` would have hit a listener).
- **The stub's catalog for S-4 coverage** (test :191-200) adds:
  - a listed slug `bad;\u001b[31mslug` with the highest priority;
  - a level `turbo\u001b[0m` on `stub-b`.

  E59's expected output does not change, so the two filters are what keep it green.
- **New stub scenarios** `late-flood` (shares the `sleep` branch) and `slow`, both for E70.

## Tests and coverage (list)

- **C1:** E70, against the reviewer's reproduction.
- **C2:** no case. The window is a second signal during a 1–3 s cleanup, and staging it reliably would mean racing that window. The fix is two lines, read in place.
- **C3:** wall time 3m02s → 52 s. E60, E69 and E70 still pass with the hit flag. OpenCode's `stop` paths (E05, E25, E37 and every `stop_all`) pass without a sweep.
- **C-A:** no case. It is a race with a concurrent `stop`.
- **C-B:** every header line the suite checks (E01, E50, E54, E55 and others).
- **C-D:** E69's second decoy.
- **S-4:** E59, with the new catalog entries.
- **T4:** E58.
- **T-8:** E56.
- **T-9:** E60, E69 and E70, through `pids_after`.

Mutants, each against a copy under `$TMPDIR`:

| mutant | result |
|---|---|
| no sweep in `cmd_send` | PASS 70/70 — the `$$` flag names alone protect E70 |
| flag names without `$$` | PASS 70/70 — the sweep alone protects E70 |
| both removed (the reviewer's repro) | E70 red |
| environ split at newlines (the old reading) | E69 red (the second decoy was killed) |
| `default` accepted | E58 red |
| catalog not filtered | E59 red |

The first run of the newline mutant hung to its 500 s cap: my shell quoting broke the mutated line, so it showed nothing. I reran it from a Python file, with the line printed first, and that is the result above. After every batch I checked for leftover processes and directories, and none were left.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root:

    five × bash -n && test -x   -> all rc=0
    shellcheck (five scripts)   -> rc=0
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    PASS 35/35   (every other line ok)
    bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
    external-agent.test rc=0 wall=52.2 s
    ok E70 …
    ok E36 …
    PASS 70/70   (71 lines; every other line ok)

Post-conditions:

    S28 1 · S29 1 · S30 2 · S31 prints nothing · S32 (E50…E70) prints nothing · S33 0 · S34 1 · S35 0
    S38 2 · S39 1, and sweep_agent "$1" at :1383 inside cmd_stop (:1362-1397) · G1 present · G3 nothing

`git status --short` shows ` M` for both of my files. The other six files are untouched by me.

## glab:security report

    ## Claims
    | claim | proven / inferred | how |
    |---|---|---|
    | a SIGKILLed send no longer fails the next one | proven | E70; "both removed" mutant red |
    | the sweep compares whole environ entries | proven | E69 second decoy; newline mutant red |
    | the suite is back to about 1 min | proven | wall=52.2 s in the gate run |
    | a second signal during cleanup is ignored | inferred | `trap '' HUP INT TERM` first in cleanup; no case |
    | the catalog cannot print out-of-form text | proven | E59 with the bad slug and level; no-filter mutant red |

    ## Blast radius
    changed:  cleanup (signals ignored inside, host_turn sweep), sweep_agent (hit flag, environ_has),
              cmd_send (isolation after the lock; host sweep before run/ is replaced), cmd_stop (no sweep for a
              sandbox backend), run_host/run_sandboxed/finish_turn (cap flag names), header and codex_verify
              (explicit arguments), codex_cmd (was cx), codex_check (cmark cleared, catalog filtered and cleaned),
              codex_model_allowed (refuses default), header comment (S1 wording)
    callers:  all internal to the script; stdout, stderr and exit codes are unchanged except `--model default`
              for codex, now 5, and check's models line, which drops out-of-form slugs and levels
    data:     none persisted; run/capped.<pid>.* are per-turn files removed with run/
    rollback: revert the two files

    ## Not done
    C-C, C-E, S-5, S-6 and S-7 (follow-ups, by assignment); the docs items (the docs developer's).

---

# Round 4 (review r2)

Developer, 2026-10-18. Items: R2-1, R2-a, R2-b, R2-c, and revision 5's script item. The boundary is the same two files. No Codex command ran, nothing under `~/.codex` was read, and nothing was staged. `sweep_agent` and `environ_has` are not touched (O2 is re-measuring them). I made no edit to either body this round; my only script edits were the two header-comment hunks, so their line numbers moved by two. This is inferred from the edit list: no round-3 copy was kept to diff against. Lines are for the tree as left (script sha256 `32bbec92…61716`, test `960ac142…078e0`).

## Items

- **R2-1 — done: E70 is split into E70 and E71, and each one discriminates.**
  - **E70, the sweep before every send** (`tests/external-agent.test.sh:1077-1094`):
    1. a `send` of `sleep` runs, and its script is SIGKILLed;
    2. the known positive: the stand-in is alive;
    3. its pid goes to `$CXH/stale`;
    4. a `send` of the new stub scenario `stale` (:290-295) reports `stale=dead` or `stale=alive` for that pid as the new turn starts.

    The case asserts `stale=dead`. Every other sweep runs after a turn or at `stop`, so only the sweep before the send (`external-agent.sh:1335`) can have ended the stand-in by then.
  - **E71, the `$$` cap-flag names** (:1096-1114):
    1. a `send` of `late-flood-unmarked` runs, and its script is SIGKILLed. Its stand-in is `setsid env -u GLAB_EXTERNAL_AGENT sh -c 'sleep 2; head -c 17M /dev/zero | tr "\0" x'` (:281), so no sweep reaches it;
    2. the known positive: the stand-in is alive and has no `GLAB_EXTERNAL_AGENT` entry (`environ_line`, :952);
    3. a 6 s `send` of `slow` follows;
    4. 2 s in, the stand-in floods the old filter. The old filter writes its cap flag into the new `run/`, under its own script's pid.

    The case asserts rc 0 and turn 2.
  - The stub already appends the stand-in's pid to `$CXH/pids`, so `cleanup` kills it by pid. The case also waits for it to end, which the flood does once the old filter stops reading, and otherwise kills it by pid.
  - **The flood is one endless line**, not `yes` lines. The old awk then sets its flag on the first record instead of after millions of `fflush` calls. That keeps the flag well inside the 6 s turn: it lands about 2 s in, and the turn ends at about 6.5 s.
  - **Determinism.** The `$$` mutant failed E71 on both of its runs (below). The margins are about 1.5 s before the flood and about 4 s after it.
  - E36 is still last (:1117). The "E37-E71 run before E36" comment is updated.
- **R2-a — done.** Both E70 and E71 cite `[feature-codex-agent/review-r1.md C1]` (:1077, :1096). That replaces the old "(C1 of the … review, round 1)".
- **R2-b — done.** The header's list of where `sweep_agent` runs now reads: "after every turn, in cleanup, before every send, and at every stop. The last two end what a turn left when its script was SIGKILLed" (`external-agent.sh:118-120`).
- **R2-c — done.** See *Coverage* below.
- **Revision 5, the header's socket wording — done** (`external-agent.sh:90-95`): "its commands change no file, and have no IP network, and a connect to a Unix-domain socket by path was refused (measured offline with `codex sandbox`); datagram and abstract sockets not measured".
  - The S40 phrase is on one line (:92).
  - The first message's "Your commands have no network." is unchanged.

## Unplanned changes

- **Stub scenario `stale`** (:290-295), for E70.
- **`late-flood` renamed `late-flood-unmarked`** and changed to an unmarked stand-in that floods one endless line, for E71. E70 now uses the plain `sleep` stand-in.
- **Test helper `environ_line <pid> <name>`** (:952), for E71's known positive.

## Coverage (list)

- E70: the sweep before every send.
- E71: the `$$` cap-flag names.
- **Uncovered (R2-c): `cleanup`'s `host_turn` sweep (`external-agent.sh:203`).** It acts only when a HUP, INT or TERM arrives during `run_host`'s own post-turn sweep, a window of one `/proc` scan (milliseconds, with no kill to do). A signal cannot be aimed at that window reliably. A signal at any other time lands before `host_turn` is set, or after it is cleared, and the other sweeps cover it. The review's mutant gives PASS 70/70 for the same reason. The code is one line, read in place.
- Still uncovered from round 3: C2's `trap '' HUP INT TERM` and C-A, for the reasons given there.

Mutants, on copies under `$TMPDIR` that were removed afterwards, with no process or directory left (checked):

    == mutant a (no sweep before send): NOT OK E70 a FAIL 1/71
    == mutant b (cap flags without $$): NOT OK E71 a FAIL 1/71
    == mutant b (cap flags without $$): NOT OK E71 a FAIL 1/71

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root:

    five × bash -n && test -x   -> all rc=0
    shellcheck (five scripts)   -> rc=0
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    PASS 35/35   (every other line ok)
    bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
    external-agent.test rc=0 wall=52.7 s
    ok E70 …
    ok E71 …
    ok E36 …
    PASS 71/71   (72 lines; every other line ok)

Post-conditions:

    S40  'a connect to a Unix-domain socket by path was refused'  README.md:1  SKILL.md:2  external-agent.sh:1
    S41  'neither IP nor Unix-domain sockets'                      README.md:0  SKILL.md:0  external-agent.sh:0
    S28 1 · S29 1 · S30 2 · S31 prints nothing · S32 (E50…E71) prints nothing · S33 0 · S34 1 · S35 0
    S38 2 · S39 1, and sweep_agent "$1" at :1385 inside cmd_stop (:1364-1399) · G1 present · G3 nothing

S40 and S41 also read the README and the skill, which are the docs developer's files. Both counts match *After* §2 on the tree as it stands.

## glab:security report

    ## Claims
    | claim | proven / inferred | how |
    |---|---|---|
    | E70 fails without the sweep before every send | proven | mutant a: NOT OK E70 |
    | E71 fails without the $$ cap-flag names, repeatably | proven | mutant b, twice: NOT OK E71 |
    | the header states the socket result as revision 5 words it | proven | S40 = 1, S41 = 0 for the script |
    | sweep_agent and environ_has are as O2 measures them | inferred | not edited this round; only their line numbers moved |

    ## Blast radius
    changed:  the script's header comment only (socket wording, sweep list); the test (E70 rewritten, E71 new,
              stub scenarios stale and late-flood-unmarked, helper environ_line)
    callers:  none: no code of the script changed this round
    data:     none
    rollback: revert the two files

    ## Not done
    R2-2 and revision 5's docs items (the docs developer's); R2-d, R2-e and the earlier follow-ups (deferred).
