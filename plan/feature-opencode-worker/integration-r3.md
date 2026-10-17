# Stage 4 — integration, round 3 · `feature-opencode-worker`

Run on 2026-10-17 by the integration agent. `AGENTS.md` read first.

## Suite

The suite is the block under `### Integrate — the real CLI, offline` in
`plan/feature-opencode-worker/plan-r3.md` (fence at line 2579, 22 lines). The
dispatch message named it. It runs the user's real OpenCode binary
(`~/.opencode/bin/opencode`, 2.0.31 per the plan) against
`plugins/glab/scripts/external-agent.sh`. It uses a dummy key imported into a
throwaway HOME under `$TMPDIR`, and a slirp4netns stand-in that wires nothing,
so no request leaves the host and no model is called. The stub test
`tests/external-agent.test.sh` belongs to the develop gates and was not run
here.

Inputs at run time:

```text
e2c94aeb63b7861308176ca907fc3b13de7ee0ac46f2a10fc2d02f22463116d8  plan/feature-opencode-worker/plan-r3.md
f627bd611ec81085142ef45194cfce1b035a7c7b4c7accf23437b2438d4fda0b  plugins/glab/scripts/external-agent.sh
```

## Dependencies

- Found running: three docker containers (`glab-pg-replica`, `glab-pg-primary`,
  `glab-rabbit`). The block does not use them, and they were not touched.
- Started: nothing outside the block. The block starts its own bwrap
  sandboxes and stops them again.
- Tools present: `/usr/bin/bwrap`, `/usr/bin/jq`, `/usr/bin/git`, and
  `/home/pvhv/.opencode/bin/opencode` (executable). Nothing else was run
  against the CLI.
- No `agent-offline.*` existed under `/data/tmp/claude` before the run.

## Commands

The block was extracted to `/data/tmp/claude/fow-r3-integration/block.sh`.
The extract was checked byte for byte against the plan, and it passes
`bash -n`:

```text
fence at 2579
identical
bash -n rc=0
```

It was run once, unchanged, from the repo root:

```bash
export TMPDIR=/data/tmp/claude; cd /home/pvhv/projects/skills && bash /data/tmp/claude/fow-r3-integration/block.sh > /data/tmp/claude/fow-r3-integration/run.out 2>&1; echo "block rc=$?"; cat /data/tmp/claude/fow-r3-integration/run.out
```

There is no build step and no separate service. The block is the whole run.

## Output (pasted)

```text
block rc=0
Imported 1 credential
start rc=7 after 83 s
agent: ea-1922606feb2cb127 · model: opencode:opencode-go/kimi-k3 · turn: 1 · transcript: <X>/tmp/glab-external-agents/ea-1922606feb2cb127/transcript.txt
end: ea-1922606feb2cb127
external-agent: BACKEND ERROR: provider.transport: getaddrinfo ETIMEOUT opencode.ai
session recorded: true
agent: ea-1922606feb2cb127 · model: opencode:opencode-go/kimi-k3 · turn: 2 · transcript: <X>/tmp/glab-external-agents/ea-1922606feb2cb127/transcript.txt
end: ea-1922606feb2cb127
external-agent: TIMEOUT: no reply within 15 s
send rc=6 after 16 s
agents: 1
<id>  idle  opencode:opencode-go/kimi-k3  role=general  turns=2  last=2026-10-17T10:53:41Z  repo=<X>/repo@f81906cb1003  label=offline
dummy key under the agent: 0; known positive, the throwaway home: 1
stopped: <id>
agents left: 0; processes left: 0
```

## Comparison with `Recorded`

First a mechanical diff. The `Recorded` block was extracted from the plan, and
both sides were passed through the same normalisation: agent id → `ea-ID`,
`after N s`, `last=TS`, `@HASH`. Nothing else was changed:

```text
no difference after normalising ids, seconds, timestamp, hash
```

Line by line:

| # | Recorded | This run | Match |
|---|---|---|---|
| 1 | `Imported 1 credential` | same | yes |
| 2 | `start rc=7 after 82 s` | `start rc=7 after 83 s` | yes (seconds differ) |
| 3 | `agent: ea-… · model: opencode:opencode-go/kimi-k3 · turn: 1 · transcript: <X>/tmp/glab-external-agents/ea-…/transcript.txt` | same, new id | yes (id) |
| 4 | `end: ea-…` | same, new id | yes (id) |
| 5 | `external-agent: BACKEND ERROR: provider.transport: getaddrinfo ETIMEOUT opencode.ai` | same | yes |
| 6 | `session recorded: true` | same | yes |
| 7 | `agent: … · turn: 2 · …` | same, new id | yes (id) |
| 8 | `end: ea-…` | same, new id | yes (id) |
| 9 | `external-agent: TIMEOUT: no reply within 15 s` | same | yes |
| 10 | `send rc=6 after 15 s` | `send rc=6 after 16 s` | yes (seconds differ) |
| 11 | `agents: 1` | same | yes |
| 12 | `<id>  idle  opencode:opencode-go/kimi-k3  role=general  turns=2  last=…  repo=<X>/repo@…  label=offline` | same, new timestamp and hash | yes (timestamp, hash) |
| 13 | `dummy key under the agent: 0; known positive, the throwaway home: 1` | same | yes |
| 14 | `stopped: <id>` | same | yes |
| 15 | `agents left: 0; processes left: 0` | same | yes |

Each item of `Expected:`:

- `start` exits 7 with `provider.transport`, and the session id is recorded:
  `start rc=7`, the `BACKEND ERROR: provider.transport` line, and
  `session recorded: true`. Yes.
- `send` exits 6 after about 15 s: `send rc=6 after 16 s`. Yes.
- `list` shows one idle agent with two turns: `agents: 1`, `idle`,
  `turns=2`. Yes.
- `stop` prints `stopped: <id>`. Yes.
- The dummy key is in no file under the agent's state (`0`), and the throwaway
  home holds it (`1`). Yes.
- No process is left: `processes left: 0`. Yes.

## Cleanup

The block removed its own directory. Nothing matching `agent-offline.*`
remains, and no process mentions it:

```text
ls: cannot access '/data/tmp/claude/agent-offline.*': No such file or directory
```

```text
$ ps -u "$(id -u)" -o pid=,args= | command grep 'agent-offline' | command grep -v grep; echo "rc=$?"
rc=1
```

The first process count, before `grep -v grep` was added, printed `2`. Those
two were the `grep` itself and its parent shell, whose command line contained
the pattern. The rerun above, which excludes them, found none.

Still present, and created by this agent rather than the block:
`/data/tmp/claude/fow-r3-integration/`. It holds `block.sh` (the verbatim
extract), `run.out` and `recorded.txt`, kept as evidence for this report. The
three docker containers that were running before are still running and were
not touched.

## Failures

None.

## Not exercised

- A real model reply. No model is called, by design: the network namespace
  has no route out. A real reply is covered by L1, the live probe, which the
  user runs with their own key. It is UNVERIFIED until then.
- The CLI version (2.0.31) was not checked. The dispatch allowed nothing to
  be run against the CLI except the block, so that version is the plan's
  statement, not one measured here.

## Verdict

INTEGRATED

## Rerun after review round 2

Run on 2026-10-17 by the integration agent, after
`plugins/glab/scripts/external-agent.sh` changed in review round 2. One change
matters most here: each turn now gets a fresh home inside the sandbox, and
only OpenCode's data directory (`~/.local/share/opencode`, which holds the
session database) is kept between turns. The question for this rerun is
whether a `send` still continues the same session with the real CLI.
`AGENTS.md` was read first.

### Inputs

```text
e2c94aeb63b7861308176ca907fc3b13de7ee0ac46f2a10fc2d02f22463116d8  plan/feature-opencode-worker/plan-r3.md
81324a3374166bf832a586b457fe88176a70611f10fb8f97cd90fb3c5040a104  plugins/glab/scripts/external-agent.sh
1bbc126a1f33ba8c7e612120e6cf08dfcfdebaf32dfcce6180ebbf26c777032a  tests/external-agent.test.sh
```

The plan's hash is the same as in the first run, so the block and its
`Recorded` text did not change. The script's hash is new (first run:
`f627bd61…`).

### Dependencies

- Found running: `glab-pg-replica`, `glab-pg-primary`, `glab-rabbit` (all
  `Up 11 days (healthy)`). The block does not use them. They were not
  touched, and they are still running.
- Started: nothing outside the block.
- Tools: `/usr/bin/bwrap`, `/usr/bin/jq`, `/usr/bin/git`,
  `/usr/bin/slirp4netns`, `/usr/bin/python3`, and
  `~/.opencode/bin/opencode` (`-rwxr-xr-x`).
- No `agent-offline.*` existed under `/data/tmp/claude` before the run.

### Commands

The block (the fence at line 2579, 22 lines) was extracted to
`/data/tmp/claude/fow-r3-integration2/block.sh`. The `Recorded` block was
extracted to `recorded.txt` in the same directory. Checks on the extract:

```text
fence at 2579
22 /data/tmp/claude/fow-r3-integration2/block.sh
15 /data/tmp/claude/fow-r3-integration2/recorded.txt
bash -n rc=0
identical          # diff against sed -n '2580,2601p' of the plan
```

It was run once, unchanged, from the repo root:

```bash
export TMPDIR=/data/tmp/claude; cd /home/pvhv/projects/skills && bash /data/tmp/claude/fow-r3-integration2/block.sh > /data/tmp/claude/fow-r3-integration2/run.out 2>&1; echo "block rc=$?"; cat /data/tmp/claude/fow-r3-integration2/run.out
```

### Output (pasted)

```text
block rc=0
Imported 1 credential
start rc=7 after 87 s
agent: ea-d6cb11180a5abd72 · model: opencode:opencode-go/kimi-k3 · turn: 1 · transcript: <X>/tmp/glab-external-agents/ea-d6cb11180a5abd72/transcript.txt
end: ea-d6cb11180a5abd72
external-agent: BACKEND ERROR: provider.transport: getaddrinfo ETIMEOUT opencode.ai
session recorded: true
agent: ea-d6cb11180a5abd72 · model: opencode:opencode-go/kimi-k3 · turn: 2 · transcript: <X>/tmp/glab-external-agents/ea-d6cb11180a5abd72/transcript.txt
end: ea-d6cb11180a5abd72
external-agent: TIMEOUT: no reply within 15 s
send rc=6 after 15 s
agents: 1
<id>  idle  opencode:opencode-go/kimi-k3  role=general  turns=2  last=2026-10-17T11:52:56Z  repo=<X>/repo@268adeed1d12  label=offline
dummy key under the agent: 0; known positive, the throwaway home: 1
stopped: <id>
agents left: 0; processes left: 0
```

### Comparison with `Recorded`

The same mechanical diff as in the first run. Both sides went through the
same normalisation (agent id → `ea-ID`, `after N s`, `last=TS`, `@HASH`):

```text
no difference after normalising ids, seconds, timestamp, hash
```

All 15 lines match. The only differences are the id, `start` taking 87 s
(recorded 82), the timestamp and the commit hash. `send` took 15 s, the same
as recorded.

The points the dispatch asked about:

- `session recorded: true`. Yes.
- `send` ends in exit 6 (`TIMEOUT: no reply within 15 s`, `send rc=6 after
  15 s`). It does not end in an error saying the session is unknown or
  missing, so the fresh per-turn home did not break the second turn. Yes.
- `list` shows one idle agent with `turns=2`. Yes.
- The dummy key is in `0` files under the agent's state, and the known
  positive (the throwaway home) holds it in `1`. Yes.
- Nothing is left behind: `agents left: 0; processes left: 0`. Yes.

Each item of `Expected:` holds as well: `start` exit 7 with
`provider.transport`; `stop` prints `stopped: <id>`.

### Stub suite, run once

```text
$ bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null | tail -n 1; echo "pipe rc=${PIPESTATUS[0]}"
PASS 47/47
pipe rc=0
```

The plan's *Milestone* still says `PASS 36/36`. The test file grew in review
round 2: its hash is new, and the dispatch said only the tail line was
wanted. This is not a failure. It does mean the plan's count is now stale.

### Cleanup

```text
ls: cannot access '/data/tmp/claude/agent-offline.*': No such file or directory
$ ps -u "$(id -u)" -o pid=,args= | command grep 'agent-offline' | command grep -v grep; echo "rc=$?"
rc=1
ls: cannot access '/data/tmp/claude/glab-external-agents': No such file or directory
```

`git status --short` matched the snapshot taken at the start, and nothing in
the repo changed except this file. `/data/tmp/claude/fow-r3-integration2/`
was created by this agent as scratch evidence. It was removed after this
section was written. All of its content is pasted above. The first run's
`/data/tmp/claude/fow-r3-integration/` was not created by this agent and was
left alone.

### Failures

None.

### Not exercised

- How far "continues the same session" is proved. The run shows three
  things: the session id is recorded after `start`; the second turn runs
  with the new per-turn home and the kept data directory; and the CLI does
  not reject the session within 15 s. It then times out waiting for the
  network. The run does not show that the CLI loaded turn 1's messages into
  turn 2's request, because no request completes. UNVERIFIED: the CLI
  rejects an unknown `--session` id at once rather than also hanging — no
  negative control was run, because the dispatch allowed nothing against the
  CLI except the block. Only L1, the live probe the user runs, settles this.
- A real model reply. This is not done by design, and it is UNVERIFIED until
  L1.
- The CLI version (2.0.31) was not measured, for the same reason as in the
  first run.

### Verdict

INTEGRATED
