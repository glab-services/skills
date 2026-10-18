# feature-codex-agent — integration (Stage 4)

Run on 2026-10-18, between 02:47Z and 03:00Z, by the Stage 4 integrator. It
ran the offline measurements S1, O1 and O2 of `plan.md` revision 3, *After*
§3, with its round-3 notes, against the real Codex CLI `codex-cli 0.163.0` at
`~/.local/bin/codex`, through the working-tree
`plugins/glab/scripts/external-agent.sh`. No model was reached, and no live
run was made.

Verdict: **INTEGRATED**, after round 3.

- Round 3 (revision 4): **O2 passes** against D31. The known positive
  reproduced the leftover, and `sweep_agent` left nothing. See *Round 3
  (revision 4)* below.
- With it, S1, O1 and O2 all meet their expected results.
- *Round 3 (revision 4)* lists what is still unverified.

Round 2's verdict, kept as it was: **FAILED: 1** — O2 is `PLAN WRONG` for P3/D7.

- **O2:** after the outermost `setpriv` of D7's chain is SIGKILLed, Codex's
  sandboxed `sleep` and the sandbox helper process above it are still alive
  2 s later, and 20 s later. They are in a session and process group of
  their own.
- **S1:** pass on all four cases.
- **O1 step 1's sandbox line:** passes. `codex_check`'s exact command,
  run directly, exits 0.
- **O1 steps 2, 3, 3b, 4 and 5:** passed.

The first round ran everything inside `bwrap --unshare-net`. There, Codex's
own bwrap could not start (see *Why Codex's sandbox cannot start inside the
wrapper*), and S1, O2 and the sandbox line were BLOCKED. The user then
allowed S1 and O2 to run on the host, with `codex sandbox` only
(`questions.md` *Stage 4*). Those runs are in *Host runs (round 2)* below.
They replace the round-1 S1 and O2 results, which are kept as they were.

## Suite, and how it was chosen

There is no automated suite for this. The plan's *After* §3 defines the
Stage 4 measurements (D20), and the dispatch named S1, O1 and O2. `tests/`
holds only the two stub-based gate tests, which ran at the develop stage.
Each measurement was saved as a script under `$TMPDIR` and run, as the plan
requires; the scripts are reproduced verbatim at the end of this file.

## Environment and isolation

- `export TMPDIR=/data/tmp/claude`. Work dir: `/data/tmp/claude/fca-int.nNZYLP`
  (scripts and masked output), removed at the end.
- Each measurement made its own `X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX")`
  with `CODEX_HOME=$X/home`, `HOME=$X/uhome` and Codex's `TMPDIR=$X/tmp`, all
  siblings (findings §9.6). Each one ends with `rm -rf "$X"` and printed
  `X removed: yes`.
- `CX=/home/<user>/.local/bin/codex`, set before `HOME` was changed. It is a
  link into the real `~/.codex/packages/…`, which was executed and nothing
  else. Nothing under the real `~/.codex` was read, listed or written.
  `codex login` was never run, and the real `opencode` was never used.
- The only `auth.json` was O1's dummy: unsigned fake JWTs (`alg: none`,
  email `dummy@example.invalid`, zero account id), and refresh token
  `dummy-refresh`.
- Every Codex process, and every `external-agent.sh` run that started one, ran
  under `bwrap --dev-bind / / --unshare-net --die-with-parent`.
- Docker: `glab-mailpit`, `glab-pg-replica`, `glab-pg-primary` and
  `glab-rabbit` were already up. None is needed here; all were left alone.
- No service or container was started.

### The namespace has no network (before the first run)

    $ bwrap --dev-bind / / --unshare-net --die-with-parent -- bash -c 'ip -o link; ip -o route; echo "routes=$(ip -o route | wc -l)"; timeout 5 bash -c "exec 3<>/dev/tcp/1.1.1.1/443"; echo "connect 1.1.1.1:443 rc=$?"; timeout 5 bash -c "exec 3<>/dev/tcp/api.openai.com/443"; echo "connect api.openai.com:443 rc=$?"'
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000\    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    routes=0
    bash: connect: Network is unreachable
    connect 1.1.1.1:443 rc=1
    bash: line 1: api.openai.com: Temporary failure in name resolution
    connect api.openai.com:443 rc=1

Each measurement printed `netns: lo routes=0` again from inside its own wrapper.

### Why Codex's sandbox cannot start inside the wrapper (environment)

    $ sysctl kernel.apparmor_restrict_unprivileged_userns
    kernel.apparmor_restrict_unprivileged_userns = 1
    $ bwrap --dev-bind / / --unshare-net --die-with-parent -- bash -c 'echo "outer label: $(cat /proc/self/attr/current)"; bwrap --dev-bind / / -- true; echo "nested bwrap rc=$?"; bwrap --dev-bind / / --unshare-net -- true; echo "nested bwrap unshare-net rc=$?"; unshare -U true; echo "unshare -U rc=$?"'
    outer label: bwrap//&unpriv_bwrap (enforce)
    bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. See <https://deb.li/bubblewrap> or <file:///usr/share/doc/bubblewrap/README.Debian.gz>.
    nested bwrap rc=1
    bwrap: No permissions to create a new namespace, ...
    nested bwrap unshare-net rc=1
    unshare -U rc=0
    $ bwrap --dev-bind / / -- true; echo "host bwrap rc=$?"
    host bwrap rc=0
    $ unshare --user --net --map-current-user -- bash -c '...'
    unshare: write failed /proc/self/uid_map: Operation not permitted

Under the outer bwrap, AppArmor stacks `unpriv_bwrap` on the process, and a
nested `/usr/bin/bwrap`, which Codex's Linux sandbox uses, cannot create its
namespace. On the bare host, bwrap starts. The one alternative tried,
`unshare --user --net`, is refused at the uid map. So on this host no
no-network wrapper was found inside which `codex sandbox` can start. This is
the docs spec's earlier finding again: "bwrap inside bwrap cannot start here
at all (rev 2 P12)". It is an environment limit, not a code failure.

## S1 — Codex's read-only sandbox on this host (round 1, inside the wrapper)

Command (script `s1-inner.sh` below):

    CX=<home>/.local/bin/codex bwrap --dev-bind / / --unshare-net --die-with-parent -- bash s1-inner.sh

Inside it ran `(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- <cmd>)`,
with a Python listener on `127.0.0.1` in the same namespace, on a port the
kernel picked. As a control, a connect from outside Codex's sandbox reached
that listener.

    netns: lo routes=0
    repo: <X>/r (true)
    listener pid=2625470 port=53179
    control connect (no codex sandbox): rc=0
    --- true: rc=1
        stderr: bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. ...
    --- write: rc=1
        stderr: bwrap: No permissions to create a new namespace, ...
        f in repo after write: absent
    --- read: rc=1
        stdout: 0 bytes
        stderr: bwrap: No permissions to create a new namespace, ...
    --- connect: rc=1
        stderr: bwrap: No permissions to create a new namespace, ...
    listener 2625470 alive after kill: no
    X removed: yes

| case | expected (plan) | got | result |
|---|---|---|---|
| `true` | rc 0 | rc 1, bwrap namespace refused | **fail: environment** |
| `sh -c 'echo x >>f'` | non-zero | rc 1, but from the same bwrap failure; no write was attempted | not measured |
| `cat /etc/hostname` | rc 0 | rc 1, bwrap namespace refused | **fail: environment** |
| `bash -c 'exec 3<>/dev/tcp/127.0.0.1/<port>'` | non-zero | rc 1, but from the same bwrap failure | not measured |

None of the four results comes from the sandbox's own policy, so S1 measures
nothing about it. This is not `PLAN WRONG` for P2 or D4/D5. It is BLOCKED by
the environment.

## O1 — the offline run

Command (script `o1-inner.sh` below):

    KEEP=<work>/out CX=<home>/.local/bin/codex S=<repo>/plugins/glab/scripts/external-agent.sh \
      timeout 1500 bwrap --unshare-net --die-with-parent --dev-bind / / -- bash o1-inner.sh

Setup, as printed:

    netns: lo routes=0
    CODEX_HOME=<X>/home: auth.json config.toml
    config.toml:
      [projects."<X>/r"]
      trust_level = "trusted"
    repo .codex/config.toml:
      model = "project-model-x"

`<X>/r` is `git rev-parse --show-toplevel` of the throwaway repository, which
has one commit.

### Step 1 — `check --backend codex`

    (cd "$X/r" && TMPDIR=$X/tmp "$S" check --backend codex --cli "$CX")

    stdout:
      cli: <home>/.local/bin/codex
      tools: setpriv setsid timeout flock
      login: stored
    stderr:
      external-agent: NOT READ-ONLY: Codex's read-only sandbox does not start on this host: bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. See <https://deb.li/bubblewrap> or <file:///usr/share/doc/bubblewrap/README.Debian.gz>.
    rc=12

The plan expected `cli:`, `tools:`, and then either `login: stored`, a
`sandbox:` line and the `default:`/`models:` lines, or rc 4 if the fake login
were refused.

- `cli:` and `tools:`: **pass**.
- `login: stored`: **pass**. Codex 0.163.0's `login status` exits 0 for this
  dummy `auth.json`. The fake JWTs are not validated offline.
- The sandbox line: rc 12, which is neither of the plan's two outcomes. The
  cause is the same environment limit as in S1. The script behaved as D10
  says (a sandbox that does not start is exit 12), and its message carries
  the first non-`WARNING:` stderr line, as P2 item 4 specifies. Result:
  **environment**, not a regression.
- `default:`/`models:` through `check` (that is, `debug models` without
  `--bundled`, falling back offline): **not reached**, because check stops at
  the sandbox line. Step 2 measures the jq program on the real catalog.

### Step 2 — `debug models --bundled` through P2's jq program

    (cd "$X/r" && TMPDIR=$X/tmp "$CX" debug models --bundled) >2.json; jq -r '<P2 program, verbatim>' <2.json

    debug models rc=0; stderr: (empty)
    jq rc=0
    default: gpt-6.1-sol (predicted)
    models: gpt-6.1-sol (low medium high xhigh max ultra), gpt-6-astra (low medium high xhigh max ultra), gpt-6-sol (low medium high xhigh max ultra), gpt-6-luna (low medium high xhigh max), gpt-5.6-sol (low medium high xhigh max ultra), gpt-5.6-terra (low medium high xhigh max ultra), gpt-5.6-luna (low medium high xhigh max), gpt-5.5 (low medium high xhigh)
    entries in models line: 8
    gpt-daybreak count: 0; codex-auto-review count: 0

The plan expected `default: gpt-6.1-sol (predicted)`, and 8 entries starting
`gpt-6.1-sol (…ultra), gpt-6-astra (…ultra)` and ending `gpt-5.5 (low medium
high xhigh)`, with no `gpt-daybreak` and no `codex-auto-review`. **pass**.

The `WARNING: … PATH aliases` line of findings §9.8 did not appear: the
sibling `CODEX_HOME`/`TMPDIR` layout avoids it, as §9.6 says.

### Step 3 — the known positive (Codex directly, user config read)

    cd "$X/r" && printf 'Say hello.\n' | TMPDIR=$X/tmp timeout --kill-after=10 240 "$CX" exec --color never -c 'sandbox_mode="read-only"' -

    rc=1; stdout bytes=0
    2026-10-18T02:49:46.742504Z ERROR codex_models_manager::manager: failed to refresh available models: request timed out
    2026-10-18T02:49:46.755500Z ERROR codex_models_manager::manager: failed to refresh available models: request timed out
    OpenAI Codex v0.163.0
    --------
    workdir: <X>/r
    model: project-model-x
    provider: openai
    approval: never
    sandbox: read-only
    reasoning effort: none
    reasoning summaries: none
    session id: 01a14cea-3c78-7a51-8cc3-91fe62e83f9f
    --------
    user
    Say hello.

    warning: Codex's Linux sandbox uses bubblewrap and needs access to create user namespaces.
    2026-10-18T02:49:51.785663Z ERROR rmcp::transport::worker: worker quit with fatal: Transport channel closed, when Client(HttpRequest(HttpRequest("http/request failed: error sending request for url (https://chatgpt.com/backend-api/ps/mcp)")))
    warning: Model metadata for `project-model-x` not found. Defaulting to fallback metadata; this can degrade performance and cause issues.
    … (the rmcp line five more times, then)
    ERROR: Reconnecting... 2/5
    …
    ERROR: Reconnecting... 5/5
    warning: Falling back from WebSockets to HTTPS transport. workspace routing discovery failed
    ERROR: Reconnecting... 1/5
    …
    ERROR: workspace routing discovery failed
    ERROR: workspace routing discovery failed
    header model: project-model-x

The plan expected the header's `model:` to be `project-model-x`. **pass**:
the trusted project's layer loads, so the control can tell the two cases
apart. The turn failed at the network, as it had to.

### Step 3b — `start` through the script

    printf 'Say hello.\n' >"$X/brief.md"
    (cd "$X/r" && TMPDIR=$X/tmp "$S" start --backend codex --cli "$CX" --brief "$X/brief.md" --repo "$X/r" --timeout 300)

    stdout:
      agent: ea-1dc2df1a1101b9fe · model: codex:gpt-6.1-sol · turn: 1 · transcript: <X>/tmp/glab-external-agents/ea-1dc2df1a1101b9fe/transcript.txt
      end: ea-1dc2df1a1101b9fe
    stderr:
      external-agent: BACKEND ERROR: workspace routing discovery failed
    rc=7
    agent dir: agent.json lock transcript.log transcript.txt turn.pid
    agent.json:
      {"backend":"codex","model":"","effort":"","ran":"gpt-6.1-sol","profile":"default","role":"general","turns":1,"session":"01a14cec-ddf0-7b31-b789-889a7038a861","ready":true,"head":12,"branch":"refs/heads/master"}
    transcript.log header block (turn 1):
      OpenAI Codex v0.163.0
      --------
      workdir: <X>/r
      model: gpt-6.1-sol
      provider: openai
      approval: never
      sandbox: read-only
      reasoning effort: none
      reasoning summaries: none
      session id: 01a14cec-ddf0-7b31-b789-889a7038a861
      --------

(`head` above is the length of the recorded head, 12 characters.)

| expected (plan) | got | result |
|---|---|---|
| rc 7 at the network | rc 7, `BACKEND ERROR: workspace routing discovery failed` | pass |
| header model is not `project-model-x` (D26) | `gpt-6.1-sol`, Codex's bundled default, which is step 2's predicted default | pass |
| `transcript.log` shows `sandbox: read-only`, `approval: never` and a UUID session id | yes; the id is a UUID v7 and matches D8's form | pass |
| `agent.json` `session` is set | `01a14cec-ddf0-7b31-b789-889a7038a861`, `ready: true` | pass |

More from the turn-1 `transcript.log`, as kept:

- Three `codex_models_manager` ERROR lines come before the version line,
  which sits at line 4. That is inside D5's 20-line window.
- The `rmcp … https://chatgpt.com/backend-api/ps/mcp` line of step 3 appears
  nowhere in the script's turns. Direct Codex tried that MCP endpoint, and
  the script's argv did not.
  - Inferred: one of D4's `--disable` names or `--ignore-user-config` turned
    it off. Which one is not measured.
- The first message is the host text of P3, with `<X>/r` substituted in,
  followed by the default profile's rules and `# Your task` / `Say hello.`.
- The same `warning: Codex's Linux sandbox uses bubblewrap …` line appears.
  It is the environment limit above; no command ran, so nothing depended on
  it.

### Step 4 — `send`

    printf 'Say hello again.\n' >"$X/msg.md"
    (cd "$X/r" && TMPDIR=$X/tmp "$S" send "$id" --message "$X/msg.md" --timeout 300)

    stdout:
      agent: ea-1dc2df1a1101b9fe · model: codex:gpt-6.1-sol · turn: 2 · transcript: <X>/tmp/glab-external-agents/ea-1dc2df1a1101b9fe/transcript.txt
      end: ea-1dc2df1a1101b9fe
    stderr:
      external-agent: BACKEND ERROR: workspace routing discovery failed
    rc=7
    transcript.log turn 2 header block:
      OpenAI Codex v0.163.0
      --------
      workdir: <X>/r
      model: gpt-6.1-sol
      provider: openai
      approval: never
      sandbox: read-only
      reasoning effort: none
      reasoning summaries: none
      session id: 01a14cec-ddf0-7b31-b789-889a7038a861
      --------
    session turn 1 (agent.json): 01a14cec-ddf0-7b31-b789-889a7038a861
    session turn 2 (header):      01a14cec-ddf0-7b31-b789-889a7038a861
    same session: yes
    agent.json after send:
      {"ran":"gpt-6.1-sol","turns":2,"session":"01a14cec-ddf0-7b31-b789-889a7038a861"}

The plan expected rc 7 with the same session id, and no `continued another
session`. **pass**. `exec resume <id>`, with no `--color`, was accepted, and
the resumed turn printed the recorded id again.

### Step 5 — `list`, then `stop`

    (TMPDIR=$X/tmp "$S" list); (TMPDIR=$X/tmp "$S" stop "$id")

    list stdout:
      agents: 1
      ea-1dc2df1a1101b9fe  idle  codex:gpt-6.1-sol  role=general  turns=2  last=2026-10-18T02:58:00Z  repo=<X>/r@bf444eebe774  label=
    list rc=0
    stop stdout:
      stopped: ea-1dc2df1a1101b9fe
    stop rc=0
    agent dir after stop: absent
    processes with this CODEX_HOME other than this shell: none
    'unknown feature' lines anywhere: 0
    'unexpected argument' or 'unknown' flag lines: 0
    repo .codex/config.toml unchanged: yes
    repo status: 0 changed paths
    X removed: yes

The plan expected the agent to be listed, `stopped:`, no process left, and no
`unknown feature` line anywhere. **pass**.

- The process scan read `/proc/*/environ` from inside the wrapper. It printed
  `Permission denied` for 79 pids outside the wrapper's user namespace, each
  owned by this user. That noise is trimmed from the output above.
- A host-side check made after the run found two `codex` processes of this
  user. They started at 02:24:56 and 05:51:09 local time (+04), before these
  runs began at 06:47 local, and their ppid is 1. They are not from these
  runs, and they were not touched.
- `$TMPDIR/glab-external-agents` and `$TMPDIR/codex-offline.*` do not exist
  after the runs.

`CODEX_HOME` after the run held Codex's own state: `sessions`, `*.sqlite`,
`shell_snapshots`, `skills`, `installation_id` and others. It went with `X`.
This is the state D12 says `stop` leaves in a real `~/.codex`.

O1 summary:

- No flag was rejected.
- The session id was the same across `start` and `send`.
- The jq result equals step 2's expectation.
- No `PLAN WRONG` for P2, D8 or D10.
- The only miss is step 1's sandbox line, which is the environment.

## O2 — process lifetime (round 1, inside the wrapper)

Command (script `o2-inner.sh` below):

    CX=<home>/.local/bin/codex timeout 120 bwrap --unshare-net --die-with-parent --dev-bind / / -- bash o2-inner.sh

Inside, from a background subshell, it ran:

    exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
      setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -- sleep 300

Then it recorded the pid tree after 3 s, sent SIGKILL to the started pid,
waited 2 s, and checked each recorded pid by pid and start time.

    started pid (outermost setpriv) P=2639795
    P alive after 3 s: no
    recorded pids:
    SIGKILL P: rc=1
    wait P: rc=1
    recorded pids alive 2 s after the kill: none
    codex sandbox stderr:
      bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. ...
    codex sandbox stdout bytes: 0
    X removed: yes

The plan expected no recorded pid and no child alive 2 s after the SIGKILL.
**Not measured: environment.** Codex's sandbox never started, so there was no
`sleep`, no grandchild, and no live chain to kill. "None alive" here proves
nothing about P3/D7.

## Host runs (round 2, the user's Stage 4 allowance)

The user allowed S1 and O2 to run on the host without the no-network wrapper
(`questions.md` *Stage 4*). The allowance covers `codex sandbox … --
<command>` only, plus the exact `codex sandbox` command that `codex_check`
uses for its sandbox line. It does not cover `exec`, `exec resume`,
`check`/`start`/`send` with the real Codex, `debug models` without
`--bundled`, or `login`.

The setup:

- Every run made a fresh `X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX")`,
  with `CODEX_HOME=$X/home` holding only O1's fake `auth.json`, `HOME=$X/uhome`
  and Codex's `TMPDIR=$X/tmp`. Each run printed `CODEX_HOME=<X>/home holds:
  auth.json`.
- The real `~/.codex` was not read, listed or written.
- Run on 2026-10-18 between 10:07Z and 10:10Z, as
  `P0="$PATH" REALHOME="$HOME" CX="$HOME/.local/bin/codex" timeout 300 bash <script>`.
  The scripts (`host.sh`, `host2.sh` and `host3.sh`) are at the end of this
  file.

### S1 on the host (`host.sh`)

For each case, the run was
`(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- <cmd>)`,
in a throwaway git repository `$X/r`. A Python listener on host `127.0.0.1`,
on a port the kernel picked, was the connect target.

    host listener pid=3338626 on 127.0.0.1:60315
    control connect, outside Codex's sandbox: rc=0
    --- true: rc=0; stdout 0 bytes; stderr:
    --- write: rc=2; stdout 0 bytes; stderr:
          sh: 1: cannot create f: Read-only file system
        f in repo after the write: absent
    --- read: rc=0; stdout 17 bytes; stderr:
        stdout equals the host's /etc/hostname: yes (content masked)
    --- connect: rc=1; stdout 0 bytes; stderr:
          bash: socket: Operation not permitted
          bash: line 1: /dev/tcp/127.0.0.1/60315: Operation not permitted
    listener 3338626 alive after kill: no

| case | expected (plan) | got | result |
|---|---|---|---|
| `true` | rc 0 | rc 0 | pass |
| `sh -c 'echo x >>f'` | non-zero | rc 2, `Read-only file system`; `f` absent | pass |
| `cat /etc/hostname` (outside the repository) | rc 0 | rc 0; the output is byte-identical to the host file | pass |
| `bash -c 'exec 3<>/dev/tcp/127.0.0.1/<port>'` | non-zero | rc 1, `socket: Operation not permitted`. The same connect outside the sandbox gave rc 0 | pass |

The network is blocked inside Codex's sandbox. The listener was reachable
from the host (control rc 0), and from inside the sandbox even creating the
socket was refused. Inferred: the refusal comes from Codex's seccomp network
filter rather than from an unreachable route, since `socket()` itself got
`EPERM`. The run printed no `WARNING` line and no bwrap error. **S1: pass.**
It is not `PLAN WRONG` for P2 or D4/D5.

### O1 step 1's sandbox line: `codex_check`'s command, run directly (`host3.sh`)

This is `codex_check` item 4's command as the script runs it:

- from an empty directory;
- with every exported variable unset, then only `PATH`, `HOME`, `TMPDIR`,
  `CODEX_HOME`, `LANG=C.UTF-8` and `TERM=dumb` exported;
- under `timeout 60`, with stdin at `/dev/null`;
- `"$cx" sandbox -c 'sandbox_mode="read-only"' -- /bin/true`.

    rc=0; stdout 0 bytes; stderr:
          env names: CODEX_HOME HOME LANG PATH TERM TMPDIR
    codex_check would print: sandbox: read-only starts

Expected (D10): rc 0, so that `check` prints `sandbox: read-only starts`.
**pass.**

- The first try, in `host.sh`, failed in my script, not in Codex: `P0:
  unbound variable`. The subshell had unset the exported `P0` before reading
  it.
- `host2.sh` then failed the same way on `CX`.
- `host3.sh` copies both into shell variables first. Its result is the one
  above.
- The rest of `check` (`login status`, `debug models` without `--bundled`)
  was not run on the host: it is outside the allowance. Round 1 recorded
  `login: stored` for the fake login.

### O2 on the host (`host.sh`, then `host2.sh` with a longer watch)

From a background subshell, the run was:

    exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
      setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -- sleep 300

After 3 s it recorded the pid tree (by ppid, with each start time), sent
SIGKILL to the started pid, which is the outermost `setpriv` exec'd into
`setsid` and then `timeout`, and checked each recorded pid by pid and start
time.

`host.sh`:

    started pid P=3338786 (the outermost setpriv; it execs into setsid, then timeout)
    P alive after 3 s: yes
      pid=3338786 ppid=3338602 pgid=3338786 sid=3338786 comm=timeout
      pid=3338788 ppid=3338786 pgid=3338786 sid=3338786 comm=codex
      pid=3338811 ppid=3338788 pgid=3338786 sid=3338786 comm=bwrap
      pid=3338815 ppid=3338811 pgid=3338815 sid=3338815 comm=codex
      pid=3338816 ppid=3338815 pgid=3338815 sid=3338815 comm=sleep
    recorded: 5 pids; a sleep among them: 1
    SIGKILL P: rc=0
    wait P: rc=137
    recorded pids alive 2 s after the kill: 3338815(codex) 3338816(sleep)

`host2.sh`, the same chain, watched for 20 s:

      pid=3342559 ppid=3342525 pgid=3342559 sid=3342559 comm=timeout
      pid=3342561 ppid=3342559 pgid=3342559 sid=3342559 comm=codex
      pid=3342586 ppid=3342561 pgid=3342559 sid=3342559 comm=bwrap
      pid=3342590 ppid=3342586 pgid=3342590 sid=3342590 comm=codex
      pid=3342591 ppid=3342590 pgid=3342590 sid=3342590 comm=sleep
    SIGKILL P=3342559: rc=0
    wait P: rc=137
    alive 2 s after the kill: 3342591(sleep,ppid=3342590,state=S) 3342590(codex,ppid=1,state=S)
    alive 20 s after the kill: 3342591(sleep,ppid=3342590,state=S) 3342590(codex,ppid=1,state=S)
    killed survivor 3342591 by pid
    killed survivor 3342590 by pid
    alive after the cleanup kill: none

The plan expected that, 2 s after the SIGKILL, no recorded pid and no child
of one is alive. Got: two survivors, twice. They are the `codex` process
under bwrap (Codex's sandbox helper), reparented to pid 1, and the
sandboxed `sleep` under it. **O2: fail, `PLAN WRONG` for P3 (D7).**

What the trees show:

- `timeout`, the outer `codex` and `bwrap` are in the started group (pgid =
  sid = P), as D7 says. All three died on the kill: `timeout` from the
  SIGKILL, the outer `codex` by its pdeathsig, and `bwrap` with it.
- The process under `bwrap` starts a **new session and group of its own**
  (pgid = sid = its own pid), so it is outside the group that D7, and the
  script's `kill -TERM/-KILL -- -"$sandbox_pid"`, signal. It outlives
  `bwrap`, and nothing in the chain kills it.
- Inferred, not run, since the allowance excludes `start` with the real
  Codex: a host turn that ends by timeout, `stop`, or the script being
  killed, while Codex is running a sandboxed command, leaves that command
  and its helper running. The script's own group kill after the turn does
  not reach them either, because they are in another group. Findings §9.2
  had flagged this as `UNVERIFIED: … they may run in their own session
  (bwrap --new-session) — measurement O2`. O2 now shows that they do.
- Both survivors were killed by pid by the measurement itself, and
  confirmed gone afterwards (`3338815 gone`, `3338816 gone`, and `alive
  after the cleanup kill: none`).

## Failures, classified

| item | classification | detail |
|---|---|---|
| O2 (host) | **regression: `PLAN WRONG` for P3/D7** | Codex's sandboxed command and its helper run in their own session; they survive the SIGKILL of D7's chain for at least 20 s, and the group kill does not reach them |
| S1, round 1 | environment, superseded | nested bwrap refused under AppArmor `unpriv_bwrap` inside `bwrap --unshare-net`; the host run passes |
| O1 step 1, `sandbox:` line, round 1 | environment, superseded | same cause; `codex_check`'s command passes on the host |
| O2, round 1 | environment, superseded | same cause; the host run is the measurement |

Nothing was found pre-existing: these code paths are new in this change.

## UNVERIFIED items from the plan that these runs settle

From *UNVERIFIED, in one place*, and findings §9.2 and §9.6:

- **Codex's read-only sandbox, on this host** (S1, host). Proven: it starts,
  refuses writes, allows reads outside the repository, and its commands have
  no network.
- **`codex sandbox` maps `-c sandbox_mode="read-only"` to read-only**
  (findings §9.6 `UNVERIFIED until run`). Proven by the write refusal.
- **That no process of a killed Codex turn survives** (O2, host). Settled
  **negatively**: the processes do survive.
- **`check`'s sandbox line**: `sandbox: read-only starts`, for its exact
  command. Proven on the host.
- **The real header block is as findings §9.2 gives it.** Proven in round 1:
  - It is `OpenAI Codex v0.163.0`, `--------`, then `workdir`, `model`,
    `provider`, `approval`, `sandbox`, `reasoning effort`,
    `reasoning summaries` and `session id`, then `--------`, on stderr.
  - It is printed on `exec` and on `exec resume`.
  - No SGR sequence was seen.
  - Offline, up to three ERROR log lines come before it, within the 20-line
    window.
- **Every `--disable` name, and every `-c` key of P2's argv, is accepted by
  0.163.0**, on `exec` and on `exec resume`. Proven in round 1: no `unknown
  feature`, `unexpected argument` or `invalid value` line.
- **D26: the repository's `.codex/` layers stay off under the script's
  argv.** Proven in round 1 against the known positive: direct Codex with
  the trust entry loads `project-model-x`, and the script's turn names
  `gpt-6.1-sol`.
  - That `--ignore-user-config` alone drops the trust entry is inferred.
    The argv differs in more flags, though that one is the only flag that
    governs loading `config.toml`.
- **`exec resume <id>` continues and prints the same id.** Proven offline in
  round 1. It does not show that a conversation's content carries over.
- **D10's jq program works on the real catalog shape.** Proven: round 1,
  step 2.
- **`login status` exits 0 for a stored file login.** Proven for a dummy
  file login with fake JWTs only: `login: stored` means "an auth file Codex
  parses", not "a valid login". It is not proven for a real login or a
  keyring login.
- **D5/D8's forms match the real values.** Proven in round 1: the session id
  is a UUID v7 and passes D8's regex, and `gpt-6.1-sol` passes D6's form.
- **The host path of `start`, `send`, `list` and `stop`** on the real binary.
  Proven in round 1:
  - exit 7 at the network, with its error from the last `ERROR:` line;
  - `agent.json` `ran`, `session`, `head` and `branch`;
  - D15's transcript layout;
  - the list line;
  - stop removing the agent directory.

## Items these runs leave open

- **What the script itself leaves after a killed host turn, mid-command.**
  Inferred from O2, and not run: it needs `start` with the real Codex,
  which the allowance excludes.
- **`check`'s `default:`/`models:` lines from `debug models` without
  `--bundled`**, offline fallback included. Not run: outside both rounds'
  limits. Inferred from step 2 and findings §3.9.
- **Still open, as the plan says:**
  - a real `login status` rc 0;
  - a keyring login under `--ignore-user-config`;
  - everything reserved for a live run: the predicted default being the
    model that runs, reroutes, an unsupported effort, a real turn obeying
    read-only, and the model honouring "Read nothing outside <top>".
- **Whether `codex sandbox` contacted the network on the host**, for
  example for an update check. Not measured. The user accepted that
  possibility in the allowance.

## Cleanup

- The removed directories:
  - every `$X` (each run printed `X removed: yes`, and
    `ls -d /data/tmp/claude/codex-offline.*` finds nothing), the throwaway
    homes inside them included;
  - the round-1 work dir `/data/tmp/claude/fca-int.nNZYLP`;
  - the round-2 work dir `/data/tmp/claude/fca-int2.SO3Nby`.
- Killed by pid and confirmed gone:
  - the listeners (2625470, 3338626);
  - the O2 survivors (3338815, 3338816, 3342590, 3342591).
- Nothing these runs started is still up.
- Still up and untouched:
  - the four `glab-*` containers;
  - the user's two `codex` processes (started at 02:24:56 and 05:51:09
    local time, before these runs).
- Nothing in the repository changed apart from this file.

## Round 3 (revision 4)

This round reruns O2 as `plan.md` revision 4 defines it (*After* §3, O2,
`:1181-1196`), against D31: the marker `GLAB_EXTERNAL_AGENT` and
`sweep_agent`.

- It ran on the host, under the user's unchanged Stage 4 allowance
  (`questions.md` *Stage 4*): `codex sandbox` only, and no `exec`, `start`,
  `send` or `check` with the real Codex.
- `CODEX_HOME` and `HOME` were fresh throwaway directories under `$TMPDIR`.
  `CODEX_HOME` held only the fake `auth.json`, as the run printed:
  `CODEX_HOME=<X>/home holds: auth.json`.
- The probe was `sleep 300`.
- Run on 2026-10-18 at about 10:50Z.

`sweep_agent` and `proc_start` came out of the working-tree
`plugins/glab/scripts/external-agent.sh` with
`sed -n '/^sweep_agent() {/,/^}/p'` and `sed -n '/^proc_start() {/,/^}/p'`.
The run sourced them. A check that each of the 23 extracted lines occurs
whole in the script printed no `missing:` line.

The marker exists only in the chain's subshell. This test shell does not
carry it, so the sweep cannot hit the test itself: the run printed `this
shell carries the marker: 0`.

Command (script `o2r4.sh` below):

    REALHOME="$HOME" SWEEP=<work>/sweep.sh CX="$HOME/.local/bin/codex" timeout 120 bash o2r4.sh

The chain, from a background subshell with
`export TMPDIR=$TMPDIR_CX GLAB_EXTERNAL_AGENT=$M`, where
`M=ea-<16 random hex>`:

    exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
      setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -c 'shell_environment_policy.inherit="core"' \
      -c "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$M\"" -- sleep 300

Output, trimmed only of blank lines:

    marker M=ea-6b72f209a6cd551b
    this shell carries the marker: 0
    --- step 1: D7's chain, the marker exported and passed through shell_environment_policy.set
      pid=3864805 ppid=3864777 pgid=3864805 sid=3864805 comm=timeout start=130562999 marker=1
      pid=3864807 ppid=3864805 pgid=3864805 sid=3864805 comm=codex start=130562999 marker=1
      pid=3864830 ppid=3864807 pgid=3864805 sid=3864805 comm=bwrap start=130563000 marker=1
      pid=3864834 ppid=3864830 pgid=3864834 sid=3864834 comm=codex start=130563001 marker=1
      pid=3864835 ppid=3864834 pgid=3864834 sid=3864834 comm=sleep start=130563002 marker=1
    recorded: 5 pids; marked now: 3864805(timeout) 3864807(codex) 3864830(bwrap) 3864834(codex) 3864835(sleep)
    --- step 2: SIGKILL the outermost setpriv (P=3864805)
    kill rc=0
    wait P rc=137
    --- step 3: known positive, 2 s later
    recorded pids alive: 3864835(sleep,ppid=3864834) 3864834(codex,ppid=1)
    marked processes: 3864834(codex) 3864835(sleep)
    --- step 4: sweep_agent "$M"
    sweep_agent rc=0
    --- step 5: 1 s later
    recorded pids alive: none
    marked processes: none
    codex sandbox stderr:
    X removed: yes

| step | expected (plan revision 4) | got | result |
|---|---|---|---|
| 1 | the pid tree with start times recorded | 5 pids: `timeout`, `codex`, `bwrap`, the helper `codex` (own session) and `sleep`. All five carry the marker | pass |
| 2 | SIGKILL the outermost `setpriv` | `kill rc=0`, `wait rc=137` | pass |
| 3 | **known positive**: 2 s later, the helper and its `sleep` are still alive | `3864834(codex, ppid=1)` and `3864835(sleep)` alive, both marked: the round-2 defect reproduced | pass |
| 4 | `sweep_agent "$M"`, byte for byte from the built script | `rc=0` | pass |
| 5 | 1 s later, no recorded pid alive (by pid and start time), and no process carries the marker | `none` and `none` | pass |

**O2 (revision 4): pass.** Nothing was alive at the end, so the cleanup
loop killed nothing. Round 2's O2 fail is kept above as it was. Revision 4
answers it with D31, and this round measures that answer.

The `marked` check in this run, like `sweep_agent`, reads
`/proc/<pid>/environ` for this uid. It was able to read the Codex
processes' environments: it listed all five in step 1.

### Still unverified after round 3

- **That a real `codex exec` turn passes `shell_environment_policy.set` to
  its helper**, as `codex sandbox` does here. D31 names this as the
  fallback trigger for `systemd-run`. It needs an `exec` turn, which the
  allowance excludes.
- **That the script's own call sites run the sweep** for a real Codex turn:
  after the turn (`:1059`), in `cleanup`, and in `stop` (`:1325`). This is
  not run against the real binary: it needs `start`. Only the function
  itself was measured here. The stub test's cases are what cover the call
  sites.
- **That a sandboxed command which unsets the marker still ends with its
  helper** (D31, from findings §9.9 C2c). Not re-measured in this round.
- **The items listed under *Items these runs leave open*** above, other
  than O2's.

### Cleanup, round 3

- The work dir `/data/tmp/claude/fca-int3.udRfCr` and its `$X`
  (`X removed: yes`) were removed.
- No process of this run is left: step 5 showed `none`.
- The four `glab-*` containers and the user's two pre-existing `codex`
  processes were not touched.
- Nothing in the repository changed apart from this file.

## Round 4 (Unix socket)

This round answers finding S1 of `review-r1.md`: inside `codex sandbox`
(read-only), can a command connect to an AF_UNIX socket on the host?

- It ran on the host, under the user's unchanged Stage 4 allowance:
  `codex sandbox` only, and no `exec`, login, `start`, `send` or `check`.
- `CODEX_HOME` and `HOME` were fresh throwaway directories under `$TMPDIR`.
  `CODEX_HOME` held only the fake `auth.json`: the run printed
  `CODEX_HOME=<X>/home holds: auth.json`.
- The sandbox flags are those of S1 and `codex_check`:
  `-c 'sandbox_mode="read-only"'`.
- Run on 2026-10-18 at about 11:10Z.
- In the record, the uid is masked as `<uid>`.

Command (script `unix.sh` below):

    REALHOME="$HOME" CX="$HOME/.local/bin/codex" timeout 120 bash unix.sh

The steps:

1. A host listener: `python3 -I`, `socket.AF_UNIX`, bound at `$X/sock/s` in a
   fresh directory. It writes one line per accepted connection, and its pid
   is recorded.
2. The probe, the same text inside and outside, run as
   `python3 -I -c "$probe" "$SOCK"`:
   `s=socket.socket(socket.AF_UNIX); s.connect(sys.argv[1])`, which prints
   `connect: ok` or `connect: failed: <error>`. The socket is created
   outside the `try`, so a failure printed by the `except` comes from
   `connect()`, not from `socket()`.
   - Inside the sandbox, it ran as
     `(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- python3 -I -c "$probe" "$SOCK")`.
3. The known positive: the same probe outside the sandbox.
4. Inside the sandbox, only `test -S "/run/user/$(id -u)/bus"; echo $?`, with
   no connect to the bus. A second `test -S` on the listener's socket file
   shows the file itself is visible.
5. The listener is killed by its pid, and `$X` is removed.

Output, as printed (`socat` is not installed, so it was not used):

    CODEX_HOME=<X>/home holds: auth.json
    listener pid=537284 on <X>/sock/s (socket)
    connect: ok
    outside the sandbox: rc=0; listener accepts +1
    inside codex sandbox: rc=1; listener accepts +0
      stdout:
        connect: failed: [Errno 1] Operation not permitted
      stderr:
    socket file is a socket inside: test -S rc=0
    bus path test -S rc=0
    bus path on the host, outside the sandbox: test -S rc=0
    listener 537284 alive after kill: no
    X removed: yes

| check | expected | got | result |
|---|---|---|---|
| known positive: connect outside the sandbox | succeeds, and the listener sees it | `connect: ok`, accepts +1 | pass |
| connect inside the sandbox | the question | `connect: failed: [Errno 1] Operation not permitted`, accepts +0 | **refused** |
| the socket file is visible inside | — | `test -S` rc 0 | visible |
| `/run/user/<uid>/bus` is visible inside (no connect) | the question | `test -S` rc 0 | **visible** |

**Result.** Inside Codex's read-only sandbox, a command cannot connect to a
host AF_UNIX socket.

- Creating the AF_UNIX socket succeeded, and `connect()` was refused with
  `EPERM`, while the socket file was visible and the same connect outside
  succeeded.
  - Inferred: the refusal is a seccomp rule on `connect()`, not a filesystem
    or path restriction. EPERM rather than EACCES or ENOENT points that way,
    and the file is reachable as a path.
- The user's session bus socket `/run/user/<uid>/bus` is visible inside the
  sandbox. It was not connected to.
  - Inferred from the listener result, not measured on the bus itself: a
    connect to the bus would get the same `connect()` EPERM.
- Measured: one AF_UNIX stream socket, by path.
- Not measured:
  - an abstract-namespace socket;
  - a `SOCK_DGRAM` or `SOCK_SEQPACKET` socket;
  - `socketpair`;
  - a descriptor passed in from outside.

Cleanup, round 4:

- The listener (pid 537284) was killed by pid and confirmed gone.
- `$X` and the work dir `/data/tmp/claude/fca-int4.pOwLnF` were removed.
- Nothing else was touched.

## Round 5 (revision 5)

This round reruns O2 against `plan.md` revision 5. The O2 steps are those of
*Round 3*. What changed is the sweep:

- `sweep_agent` reads `environ` as NUL-separated entries, through
  `environ_has`.
- It makes its second pass only after a kill.

The setup:

- It ran on the host, under the unchanged Stage 4 allowance: `codex sandbox`
  only.
- `CODEX_HOME` and `HOME` were fresh throwaway directories under `$TMPDIR`,
  and `CODEX_HOME` held only the fake `auth.json`.
- The probe was `sleep 300`.
- There was no `exec`, no login, and no access to the real `~/.codex`.
- Run on 2026-10-18 at about 11:45Z.

The copied functions came from the working-tree
`plugins/glab/scripts/external-agent.sh`:

- They are lines `225-241` (`sweep_agent`), `244-249` (`environ_has`) and
  `252-257` (`proc_start`), the only helpers `sweep_agent` calls. They were
  copied with `sed -n`: 29 lines, which the run sourced.
- `sha256sum` of the copied text:
  `2b9cfec3a14254092afad8386caa1b5269f1ded4a4ee19df02d9646711f1bfa1`.
- `sha256sum` of the whole script at that moment:
  `352e3eeb3e5cf9f33bf63a3eaf54fa80bf344fd74d10a070c1bee8812f3a5158`.

The copied text:

```bash
sweep_agent() { # sweep_agent <marker>
  local pass d pid st hit
  for pass in 1 2; do
    if [ "$pass" = 2 ]; then [ -n "$hit" ] || break; sleep 1; fi
    hit=''
    for d in /proc/[0-9]*; do
      [ -O "$d" ] || continue
      environ_has "$d" "GLAB_EXTERNAL_AGENT=$1" || continue
      pid=${d#/proc/}
      st=$(proc_start "$pid") || continue
      if environ_has "$d" "GLAB_EXTERNAL_AGENT=$1" && [ "$(proc_start "$pid")" = "$st" ]; then
        kill -KILL "$pid" 2>/dev/null && hit=1
      fi
    done
  done
  return 0
}
environ_has() { # environ_has </proc/<pid>> <entry>
  local x e=()
  mapfile -d '' -t e 2>/dev/null <"$1/environ" || return 1
  for x in "${e[@]}"; do [ "$x" = "$2" ] && return 0; done
  return 1
}
proc_start() { # proc_start <pid>
  local s f
  s=$(cat "/proc/$1/stat" 2>/dev/null) || return 1
  s=${s##*) }; read -r -a f <<<"$s"
  [ -n "${f[19]:-}" ] && printf '%s\n' "${f[19]}"
}
```

The test script is *Round 3*'s `o2r4.sh`, recovered from this file and
changed only in its two header comments. It is reproduced at the end as
`o2r5.sh`. Its own `marked` check reads `environ` with `tr`, independently
of `environ_has`.

Command:

    REALHOME="$HOME" SWEEP=<work>/sweep.sh CX="$HOME/.local/bin/codex" timeout 120 bash o2r5.sh

Output, trimmed only of blank lines:

    CODEX_HOME=<X>/home holds: auth.json 
    marker M=ea-2d4dd706af04f89a
    this shell carries the marker: 0
    --- step 1: D7's chain, the marker exported and passed through shell_environment_policy.set
      pid=1259903 ppid=1259875 pgid=1259903 sid=1259903 comm=timeout start=130887176 marker=1
      pid=1259905 ppid=1259903 pgid=1259903 sid=1259903 comm=codex start=130887176 marker=1
      pid=1259928 ppid=1259905 pgid=1259903 sid=1259903 comm=bwrap start=130887177 marker=1
      pid=1259932 ppid=1259928 pgid=1259932 sid=1259932 comm=codex start=130887178 marker=1
      pid=1259933 ppid=1259932 pgid=1259932 sid=1259932 comm=sleep start=130887178 marker=1
    recorded: 5 pids; marked now: 1259903(timeout) 1259905(codex) 1259928(bwrap) 1259932(codex) 1259933(sleep) 
    --- step 2: SIGKILL the outermost setpriv (P=1259903)
    kill rc=0
    wait P rc=137
    --- step 3: known positive, 2 s later
    recorded pids alive: 1259932(codex,ppid=1) 1259933(sleep,ppid=1259932) 
    marked processes: 1259932(codex) 1259933(sleep) 
    --- step 4: sweep_agent "$M"
    sweep_agent rc=0
    --- step 5: 1 s later
    recorded pids alive: none
    marked processes: none
    codex sandbox stderr:
    X removed: yes

| step | expected (plan) | got | result |
|---|---|---|---|
| 1 | the pid tree with start times recorded | 5 pids, all carrying the marker; the helper `codex` and `sleep` in a session of their own | pass |
| 2 | SIGKILL the outermost `setpriv` | `kill rc=0`, `wait rc=137` | pass |
| 3 | **known positive**: 2 s later, the helper and its `sleep` are still alive | `1259932(codex, ppid=1)` and `1259933(sleep)` alive and marked | pass |
| 4 | `sweep_agent "$M"`, byte for byte from the built script | `rc=0` | pass |
| 5 | 1 s later, no recorded pid alive and no process carries the marker | `none` and `none` | pass |

**O2 (revision 5): pass.**

- Nothing was alive at the end, so the cleanup loop killed nothing.
- Still unverified, as after *Round 3*:
  - that a real `codex exec` turn passes `shell_environment_policy.set` to
    its helper;
  - that the script's own sweep call sites work with the real binary.
- The work dir `/data/tmp/claude/fca-int5.PYFGKg` and its `$X` were removed.

## The scripts, verbatim

The user's home directory is masked as `<home>` throughout, including inside `mask()`, where the script that ran named the real path. The work directories those scripts ran from have been removed.

### `s1-inner.sh`

```bash
#!/usr/bin/env bash
# S1, run inside bwrap --unshare-net: Codex's read-only sandbox on this host.
set -u
: "${TMPDIR:?}"; CX=${CX:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
echo "X=<X> (a fresh mktemp dir under \$TMPDIR); CODEX_HOME=<X>/home HOME=<X>/uhome TMPDIR_CX=<X>/tmp"
echo "netns: $(ip -o link | awk -F': ' '{print $2}' | tr '\n' ' ')routes=$(ip -o route | wc -l)"
mkdir "$X/r" && git -C "$X/r" init -q && echo "repo: <X>/r ($(git -C "$X/r" rev-parse --is-inside-work-tree))"
# A listener on 127.0.0.1 in this namespace, on a port the kernel picks.
python3 -I -c 'import socket,sys
s=socket.socket(); s.bind(("127.0.0.1",0)); s.listen(8)
open(sys.argv[1],"w").write(str(s.getsockname()[1])); 
while True:
  c,_=s.accept(); c.close()' "$X/port" & lpid=$!
for _ in $(seq 50); do [ -s "$X/port" ] && break; sleep 0.1; done
port=$(cat "$X/port"); echo "listener pid=$lpid port=$port"
# Control: outside Codex's sandbox, the connect succeeds.
bash -c "exec 3<>/dev/tcp/127.0.0.1/$port" 2>&1; echo "control connect (no codex sandbox): rc=$?"
run() { # run <label> <cmd...>
  local label=$1; shift
  (cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- "$@") >"$X/o.$label" 2>"$X/e.$label"; local rc=$?
  echo "--- $label: rc=$rc"
  echo "    stdout: $(wc -c <"$X/o.$label") bytes"
  echo "    stderr:"; sed 's/^/      /' "$X/e.$label" | sed "s#$X#<X>#g" | head -n 15
}
run true true
run write sh -c 'echo x >>f'
echo "    f in repo after write: $( [ -e "$X/r/f" ] && echo exists || echo absent)"
run read cat /etc/hostname
echo "    (stdout content is the host name, masked; byte count above)"
run connect bash -c "exec 3<>/dev/tcp/127.0.0.1/$port"
kill "$lpid"; wait "$lpid" 2>/dev/null
echo "listener $lpid alive after kill: $(kill -0 "$lpid" 2>/dev/null && echo yes || echo no)"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `o1-inner.sh`

```bash
#!/usr/bin/env bash
# O1, run inside bwrap --unshare-net --die-with-parent --dev-bind / /: the offline run.
set -u
: "${TMPDIR:?}"; CX=${CX:?}; S=${S:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#<home>#<home>#g"; }
echo "netns: $(ip -o link | awk -F': ' '{print $2}' | tr '\n' ' ')routes=$(ip -o route | wc -l)"
# A dummy login: fake, unsigned JWTs with a far exp; never a real token.
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
# The repository, with a project layer that names project-model-x.
mkdir -p "$X/r/.codex" && printf 'model = "project-model-x"\n' >"$X/r/.codex/config.toml"
git -C "$X/r" init -q && printf 'hello\n' >"$X/r/README" \
  && git -C "$X/r" -c user.name=t -c user.email=t@example.invalid add -A \
  && git -C "$X/r" -c user.name=t -c user.email=t@example.invalid commit -q -m init
R=$(git -C "$X/r" rev-parse --show-toplevel)
# The trust control: a real config.toml marks the repository trusted.
printf '[projects."%s"]\ntrust_level = "trusted"\n' "$R" >"$CODEX_HOME/config.toml"
echo "--- setup"
echo "CODEX_HOME=<X>/home: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
echo "config.toml:"; mask <"$CODEX_HOME/config.toml" | sed 's/^/  /'
echo "repo .codex/config.toml:"; sed 's/^/  /' "$X/r/.codex/config.toml"
cp "$X/r/.codex/config.toml" "$X/pre-config.toml"

echo; echo "=== step 1: check --backend codex"
(cd "$X/r" && TMPDIR=$X/tmp "$S" check --backend codex --cli "$CX") >"$X/1.out" 2>"$X/1.err"; rc=$?
echo "stdout:"; mask <"$X/1.out" | sed 's/^/  /'
echo "stderr:"; mask <"$X/1.err" | sed 's/^/  /'
echo "rc=$rc"

echo; echo "=== step 2: debug models --bundled | P2 jq program"
(cd "$X/r" && TMPDIR=$X/tmp "$CX" debug models --bundled) >"$X/2.json" 2>"$X/2.err"; rc=$?
echo "debug models rc=$rc; stderr:"; mask <"$X/2.err" | sed 's/^/  /'
jq -r '[.models[] | select(.visibility == "list")] | sort_by(.priority)
       | if length == 0 then error("no listed model") else
         "default: \(.[0].slug) (predicted)",
         "models: " + (map(.slug + " (" + ([.supported_reasoning_levels[]?.effort] | join(" ")) + ")") | join(", "))
       end' <"$X/2.json" >"$X/2.out"; echo "jq rc=$?"
cat "$X/2.out"
echo "entries in models line: $(sed -n 's/^models: //p' "$X/2.out" | awk -F', ' '{print NF}')"
echo "gpt-daybreak count: $(command grep -c gpt-daybreak "$X/2.out"); codex-auto-review count: $(command grep -c codex-auto-review "$X/2.out")"

echo; echo "=== step 3: the known positive (codex exec directly, user config read)"
(cd "$X/r" && printf 'Say hello.\n' | TMPDIR=$X/tmp timeout --kill-after=10 240 "$CX" exec --color never -c 'sandbox_mode="read-only"' -) >"$X/3.out" 2>"$X/3.err"; rc=$?
echo "rc=$rc; stdout bytes=$(wc -c <"$X/3.out")"
echo "stderr (first 20 lines):"; mask <"$X/3.err" | head -n 20 | sed 's/^/  /'
echo "stderr (last 6 lines of $(wc -l <"$X/3.err")):"; mask <"$X/3.err" | tail -n 6 | sed 's/^/  /'
m3=$(sed 's/\x1b\[[0-9;]*m//g' "$X/3.err" | awk '/^OpenAI Codex v/{s=1} s && /^model: /{print substr($0,8); exit}')
echo "header model: $m3"
if [ "$m3" != project-model-x ]; then
  echo "KNOWN POSITIVE FAILED: header model is not project-model-x; O1 stops here."
  rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"; exit 0
fi

echo; echo "=== step 3b: start through the script"
printf 'Say hello.\n' >"$X/brief.md"
(cd "$X/r" && TMPDIR=$X/tmp "$S" start --backend codex --cli "$CX" --brief "$X/brief.md" --repo "$X/r" --timeout 300) >"$X/3b.out" 2>"$X/3b.err"; rc=$?
echo "stdout:"; mask <"$X/3b.out" | sed 's/^/  /'
echo "stderr:"; mask <"$X/3b.err" | sed 's/^/  /'
echo "rc=$rc"
root=$X/tmp/glab-external-agents
id=$(sed -n 's/^agent: \(ea-[0-9a-f]*\) .*/\1/p' "$X/3b.out" | head -n 1)
echo "agent id: $id"
adir=$root/$id
echo "agent dir: $(ls -A "$adir" 2>&1 | tr '\n' ' ')"
echo "agent.json:"; jq -c '{backend,model,effort,ran,profile,role,turns,session,ready,head:(.head|length),branch}' "$adir/agent.json" 2>&1 | mask | sed 's/^/  /'
echo "transcript.log header block (turn 1):"
sed 's/\x1b\[[0-9;]*m//g' "$adir/transcript.log" | awk '/^OpenAI Codex v/{s=1} s{print} s && /^--------$/ {n++; if (n==2) exit}' | mask | sed 's/^/  /'
echo "transcript.log, lines after the block that start ERROR/WARN (turn 1, last 6):"
sed 's/\x1b\[[0-9;]*m//g' "$adir/transcript.log" | command grep -E '^(ERROR|WARN|error|warning)' | tail -n 6 | mask | sed 's/^/  /'
cp "$adir/transcript.log" "$X/t1.log" 2>/dev/null
s1=$(jq -r .session "$adir/agent.json" 2>/dev/null)

echo; echo "=== step 4: send"
printf 'Say hello again.\n' >"$X/msg.md"
(cd "$X/r" && TMPDIR=$X/tmp "$S" send "$id" --message "$X/msg.md" --timeout 300) >"$X/4.out" 2>"$X/4.err"; rc=$?
echo "stdout:"; mask <"$X/4.out" | sed 's/^/  /'
echo "stderr:"; mask <"$X/4.err" | sed 's/^/  /'
echo "rc=$rc"
echo "transcript.log turn 2 header block:"
sed 's/\x1b\[[0-9;]*m//g' "$adir/transcript.log" | awk '/^=== turn 2 stderr ===$/{t=1} t && /^OpenAI Codex v/{s=1} s{print} s && /^--------$/ {n++; if (n==2) exit}' | mask | sed 's/^/  /'
s2=$(sed 's/\x1b\[[0-9;]*m//g' "$adir/transcript.log" | awk '/^=== turn 2 stderr ===$/{t=1} t && /^session id: /{print substr($0,13); exit}')
echo "session turn 1 (agent.json): ${s1:-none}"
echo "session turn 2 (header):      ${s2:-none}"
echo "same session: $( [ -n "$s1" ] && [ "$s1" = "$s2" ] && echo yes || echo no)"
echo "agent.json after send:"; jq -c '{ran,turns,session}' "$adir/agent.json" 2>&1 | sed 's/^/  /'
cp "$adir/transcript.log" "$X/t2.log" 2>/dev/null

echo; echo "=== step 5: list, then stop"
(TMPDIR=$X/tmp "$S" list) >"$X/5l.out" 2>"$X/5l.err"; rc=$?
echo "list stdout:"; mask <"$X/5l.out" | sed 's/^/  /'; echo "list stderr:"; mask <"$X/5l.err" | sed 's/^/  /'; echo "list rc=$rc"
(TMPDIR=$X/tmp "$S" stop "$id") >"$X/5s.out" 2>"$X/5s.err"; rc=$?
echo "stop stdout:"; mask <"$X/5s.out" | sed 's/^/  /'; echo "stop stderr:"; mask <"$X/5s.err" | sed 's/^/  /'; echo "stop rc=$rc"
echo "agent dir after stop: $( [ -e "$adir" ] && echo present || echo absent)"
# Processes left: any process whose environment names this run's CODEX_HOME,
# and any descendant of this shell other than the ps pipeline itself.
left=''
for p in /proc/[0-9]*; do
  [ -r "$p/environ" ] || continue
  if tr '\0' '\n' <"$p/environ" 2>/dev/null | command grep -qxF "CODEX_HOME=$X/home"; then
    pid=${p#/proc/}; [ "$pid" = "$$" ] || [ "$pid" = "$BASHPID" ] && continue
    left+="$pid:$(tr '\0' ' ' <"$p/cmdline" | cut -c1-60) "
  fi
done
echo "processes with this CODEX_HOME other than this shell: ${left:-none}"
echo "'unknown feature' lines anywhere: $(cat "$X"/*.out "$X"/*.err "$X"/t*.log 2>/dev/null | command grep -ci 'unknown feature')"
echo "'unexpected argument' or 'unknown' flag lines: $(cat "$X"/*.err "$X"/t*.log 2>/dev/null | command grep -ciE 'unexpected argument|unrecognized|invalid value')"
echo "repo .codex/config.toml unchanged: $(cmp -s "$X/pre-config.toml" "$X/r/.codex/config.toml" && echo yes || echo no)"
echo "repo status: $(git -C "$X/r" status --short | wc -l) changed paths"
echo "CODEX_HOME after: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
# Keep the raw logs for the record, masked, outside X.
for f in 3.err t2.log; do [ -f "$X/$f" ] && mask <"$X/$f" >"$KEEP/o1.$f"; done
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `o2-inner.sh`

```bash
#!/usr/bin/env bash
# O2, inside bwrap --unshare-net: D7's chain around codex sandbox -- sleep 300.
set -u
: "${TMPDIR:?}"; CX=${CX:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
git -C "$X/r" init -q
mask() { sed -e "s#$X#<X>#g" -e "s#<home>#<home>#g"; }
desc() { # desc <pid> — pid and every descendant, by ppid, with start time
  local q=("$1") out=() p c
  while [ ${#q[@]} -gt 0 ]; do
    p=${q[0]}; q=("${q[@]:1}"); out+=("$p")
    for c in /proc/[0-9]*/stat; do
      c=${c#/proc/}; c=${c%/stat}
      [ "$(awk '{print $4}' "/proc/$c/stat" 2>/dev/null)" = "$p" ] && q+=("$c")
    done
  done
  printf '%s\n' "${out[@]}"
}
(
  cd "$X/r" || exit 1
  export TMPDIR=$TMPDIR_CX
  exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
    setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -- sleep 300 >"$X/o2.out" 2>"$X/o2.err"
) &
P=$!
echo "started pid (outermost setpriv) P=$P"
sleep 3
echo "P alive after 3 s: $(kill -0 "$P" 2>/dev/null && echo yes || echo no)"
mapfile -t pids < <(desc "$P")
declare -A st
for p in "${pids[@]}"; do
  [ -r "/proc/$p/stat" ] || continue
  st[$p]=$(awk '{print $22}' "/proc/$p/stat")
  printf '  pid=%s pgid=%s sid=%s comm=%s\n' "$p" "$(awk '{print $5}' /proc/$p/stat)" "$(awk '{print $6}' /proc/$p/stat)" "$(cat /proc/$p/comm)"
done
echo "recorded pids: ${!st[*]}"
kill -KILL "$P" 2>/dev/null; echo "SIGKILL P: rc=$?"
wait "$P" 2>/dev/null; echo "wait P: rc=$?"
sleep 2
alive=''
for p in "${!st[@]}"; do
  [ -r "/proc/$p/stat" ] && [ "$(awk '{print $22}' "/proc/$p/stat")" = "${st[$p]}" ] && alive+="$p "
done
echo "recorded pids alive 2 s after the kill: ${alive:-none}"
echo "codex sandbox stderr:"; mask <"$X/o2.err" | sed 's/^/  /'
echo "codex sandbox stdout bytes: $(wc -c <"$X/o2.out")"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `host.sh` (round 2)

```bash
#!/usr/bin/env bash
# S1, O1 step 1's sandbox line, and O2, on the host (the user's Stage 4
# allowance): codex sandbox only, throwaway CODEX_HOME and HOME, a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
echo "CODEX_HOME=<X>/home holds: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
mkdir "$X/r" && git -C "$X/r" init -q && echo "repo: <X>/r ($(git -C "$X/r" rev-parse --is-inside-work-tree))"

echo; echo "===== S1"
python3 -I -c 'import socket,sys
s=socket.socket(); s.bind(("127.0.0.1",0)); s.listen(8)
open(sys.argv[1],"w").write(str(s.getsockname()[1]))
while True:
  c,_=s.accept(); c.close()' "$X/port" & lpid=$!
for _ in $(seq 50); do [ -s "$X/port" ] && break; sleep 0.1; done
port=$(cat "$X/port"); echo "host listener pid=$lpid on 127.0.0.1:$port"
bash -c "exec 3<>/dev/tcp/127.0.0.1/$port" 2>&1; echo "control connect, outside Codex's sandbox: rc=$?"
run() { # run <label> <cmd...>
  local label=$1; shift
  (cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- "$@") >"$X/o.$label" 2>"$X/e.$label"; local rc=$?
  echo "--- $label: rc=$rc; stdout $(wc -c <"$X/o.$label") bytes; stderr:"
  mask <"$X/e.$label" | head -n 8 | sed 's/^/      /'
}
run true true
run write sh -c 'echo x >>f'
echo "    f in repo after the write: $( [ -e "$X/r/f" ] && echo exists || echo absent)"
run read cat /etc/hostname
echo "    stdout equals the host's /etc/hostname: $(cmp -s "$X/o.read" /etc/hostname && echo yes || echo no) (content masked)"
run connect bash -c "exec 3<>/dev/tcp/127.0.0.1/$port"
kill "$lpid"; wait "$lpid" 2>/dev/null
echo "listener $lpid alive after kill: $(kill -0 "$lpid" 2>/dev/null && echo yes || echo no)"

echo; echo "===== O1 step 1's sandbox line: codex_check's command, run directly"
# As codex_check runs it: an empty directory, the codex_env allowlist, timeout 60, stdin /dev/null.
mkdir -m 700 "$X/authd"
( while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
  export PATH="$P0" HOME="$X/uhome" TMPDIR="$X/tmp" CODEX_HOME="$X/home" LANG=C.UTF-8 TERM=dumb
  cd "$X/authd" && exec timeout 60 "$CX" sandbox -c 'sandbox_mode="read-only"' -- /bin/true </dev/null
) >"$X/c.out" 2>"$X/c.err"; rc=$?
echo "rc=$rc; stdout $(wc -c <"$X/c.out") bytes; stderr:"; mask <"$X/c.err" | sed 's/^/      /'
echo "codex_check would print: $( [ "$rc" -eq 0 ] && echo 'sandbox: read-only starts' || echo 'exit 12 NOT READ-ONLY')"

echo; echo "===== O2"
desc() { # desc <pid> — the pid and its descendants, by ppid
  local q=("$1") p c
  while [ ${#q[@]} -gt 0 ]; do
    p=${q[0]}; q=("${q[@]:1}"); echo "$p"
    for c in /proc/[0-9]*/stat; do
      c=${c#/proc/}; c=${c%/stat}
      [ "$(awk '{print $4}' "/proc/$c/stat" 2>/dev/null)" = "$p" ] && q+=("$c")
    done
  done
}
(
  cd "$X/r" || exit 1
  export TMPDIR=$TMPDIR_CX
  exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
    setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -- sleep 300 >"$X/o2.out" 2>"$X/o2.err"
) &
P=$!
echo "started pid P=$P (the outermost setpriv; it execs into setsid, then timeout)"
sleep 3
echo "P alive after 3 s: $(kill -0 "$P" 2>/dev/null && echo yes || echo no)"
mapfile -t pids < <(desc "$P")
declare -A st
for p in "${pids[@]}"; do
  [ -r "/proc/$p/stat" ] || continue
  st[$p]=$(awk '{print $22}' "/proc/$p/stat")
  printf '  pid=%s ppid=%s pgid=%s sid=%s comm=%s\n' "$p" "$(awk '{print $4}' /proc/$p/stat)" "$(awk '{print $5}' /proc/$p/stat)" "$(awk '{print $6}' /proc/$p/stat)" "$(cat /proc/$p/comm)"
done
echo "recorded: ${#st[@]} pids; a sleep among them: $(for p in "${!st[@]}"; do cat /proc/$p/comm 2>/dev/null; done | command grep -cx sleep)"
kill -KILL "$P"; echo "SIGKILL P: rc=$?"
wait "$P" 2>/dev/null; echo "wait P: rc=$?"
sleep 2
alive=''
for p in "${!st[@]}"; do
  [ -r "/proc/$p/stat" ] && [ "$(awk '{print $22}' "/proc/$p/stat")" = "${st[$p]}" ] && alive+="$p($(cat /proc/$p/comm)) "
done
echo "recorded pids alive 2 s after the kill: ${alive:-none}"
# A survivor this run started is killed by its pid, and reported above.
for p in $alive; do kill -KILL "${p%%(*}" 2>/dev/null; done
echo "codex sandbox stderr:"; mask <"$X/o2.err" | head -n 8 | sed 's/^/  /'
echo "CODEX_HOME after: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `host2.sh` (round 2)

```bash
#!/usr/bin/env bash
# S1, O1 step 1's sandbox line, and O2, on the host (the user's Stage 4
# allowance): codex sandbox only, throwaway CODEX_HOME and HOME, a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
echo "CODEX_HOME=<X>/home holds: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
mkdir "$X/r" && git -C "$X/r" init -q && echo "repo: <X>/r ($(git -C "$X/r" rev-parse --is-inside-work-tree))"
echo; echo "===== O1 step 1's sandbox line: codex_check's command, run directly"
# As codex_check runs it: an empty directory, the codex_env allowlist, timeout 60, stdin /dev/null.
mkdir -m 700 "$X/authd"
p0=${P0:?}  # a shell variable: the subshell unsets every exported one first
( while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
  export PATH="$p0" HOME="$X/uhome" TMPDIR="$X/tmp" CODEX_HOME="$X/home" LANG=C.UTF-8 TERM=dumb
  cd "$X/authd" && exec timeout 60 "$CX" sandbox -c 'sandbox_mode="read-only"' -- /bin/true </dev/null
) >"$X/c.out" 2>"$X/c.err"; rc=$?
echo "rc=$rc; stdout $(wc -c <"$X/c.out") bytes; stderr:"; mask <"$X/c.err" | sed 's/^/      /'
echo "codex_check would print: $( [ "$rc" -eq 0 ] && echo 'sandbox: read-only starts' || echo 'exit 12 NOT READ-ONLY')"

echo; echo "===== O2, rerun with a longer watch"
mkdir "$X/r" && git -C "$X/r" init -q
desc() { local q=("$1") p c; while [ ${#q[@]} -gt 0 ]; do p=${q[0]}; q=("${q[@]:1}"); echo "$p"
  for c in /proc/[0-9]*/stat; do c=${c#/proc/}; c=${c%/stat}; [ "$(awk '{print $4}' "/proc/$c/stat" 2>/dev/null)" = "$p" ] && q+=("$c"); done; done; }
(
  cd "$X/r" || exit 1
  export TMPDIR=$TMPDIR_CX
  exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
    setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -- sleep 300 >"$X/o2.out" 2>"$X/o2.err"
) &
P=$!
sleep 3
mapfile -t pids < <(desc "$P")
declare -A st
for p in "${pids[@]}"; do [ -r "/proc/$p/stat" ] || continue; st[$p]=$(awk '{print $22}' "/proc/$p/stat")
  printf '  pid=%s ppid=%s pgid=%s sid=%s comm=%s\n' "$p" $(awk '{print $4, $5, $6}' /proc/$p/stat) "$(cat /proc/$p/comm)"; done
kill -KILL "$P"; echo "SIGKILL P=$P: rc=$?"; wait "$P" 2>/dev/null; echo "wait P: rc=$?"
show() { local p out=''; for p in "${!st[@]}"; do
  [ -r "/proc/$p/stat" ] && [ "$(awk '{print $22}' "/proc/$p/stat")" = "${st[$p]}" ] && out+="$p($(cat /proc/$p/comm),ppid=$(awk '{print $4}' /proc/$p/stat),state=$(awk '{print $3}' /proc/$p/stat)) "; done; echo "${out:-none}"; }
sleep 2; echo "alive 2 s after the kill: $(show)"
sleep 18; echo "alive 20 s after the kill: $(show)"
for p in "${!st[@]}"; do [ -r "/proc/$p/stat" ] && [ "$(awk '{print $22}' "/proc/$p/stat")" = "${st[$p]}" ] && kill -KILL "$p" && echo "killed survivor $p by pid"; done
sleep 1; echo "alive after the cleanup kill: $(show)"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `host3.sh` (round 2)

```bash
#!/usr/bin/env bash
# S1, O1 step 1's sandbox line, and O2, on the host (the user's Stage 4
# allowance): codex sandbox only, throwaway CODEX_HOME and HOME, a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
echo "CODEX_HOME=<X>/home holds: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
mkdir "$X/r" && git -C "$X/r" init -q && echo "repo: <X>/r ($(git -C "$X/r" rev-parse --is-inside-work-tree))"
echo; echo "===== O1 step 1's sandbox line: codex_check's command, run directly"
# As codex_check runs it: an empty directory, the codex_env allowlist, timeout 60, stdin /dev/null.
mkdir -m 700 "$X/authd"
p0=${P0:?} cx=$CX  # shell variables: the subshell unsets every exported one first
( while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
  export PATH="$p0" HOME="$X/uhome" TMPDIR="$X/tmp" CODEX_HOME="$X/home" LANG=C.UTF-8 TERM=dumb
  echo "env names: $(compgen -e | tr '\n' ' ')" >&2
  cd "$X/authd" && exec timeout 60 "$cx" sandbox -c 'sandbox_mode="read-only"' -- /bin/true </dev/null
) >"$X/c.out" 2>"$X/c.err"; rc=$?
echo "rc=$rc; stdout $(wc -c <"$X/c.out") bytes; stderr:"; mask <"$X/c.err" | sed 's/^/      /'
echo "codex_check would print: $( [ "$rc" -eq 0 ] && echo 'sandbox: read-only starts' || echo 'exit 12 NOT READ-ONLY')"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `o2r4.sh` (round 3)

```bash
#!/usr/bin/env bash
# O2, plan revision 4, on the host under the user's Stage 4 allowance:
# codex sandbox only, a throwaway CODEX_HOME and HOME with a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}; SWEEP=${SWEEP:?}
# sweep_agent and proc_start, copied byte for byte from the built script.
# shellcheck source=/dev/null
. "$SWEEP"
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
git -C "$X/r" init -q
echo "CODEX_HOME=<X>/home holds: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
M=ea-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')
echo "marker M=$M"
echo "this shell carries the marker: $(tr '\0' '\n' </proc/$$/environ | command grep -cxF "GLAB_EXTERNAL_AGENT=$M")"
marked() { # pids of this uid whose environ holds the exact marker line, other than this shell
  local d e out=''
  for d in /proc/[0-9]*; do
    [ -O "$d" ] || continue
    e=$({ tr '\0' '\n' <"$d/environ"; } 2>/dev/null)
    [[ $'\n'$e$'\n' == *$'\n'"GLAB_EXTERNAL_AGENT=$M"$'\n'* ]] && out+="${d#/proc/}($(cat "$d/comm" 2>/dev/null)) "
  done
  echo "${out:-none}"
}
desc() { local q=("$1") p c; while [ ${#q[@]} -gt 0 ]; do p=${q[0]}; q=("${q[@]:1}"); echo "$p"
  for c in /proc/[0-9]*/stat; do c=${c#/proc/}; c=${c%/stat}; [ "$(awk '{print $4}' "/proc/$c/stat" 2>/dev/null)" = "$p" ] && q+=("$c"); done; done; }
declare -A st
alive() { local p out=''; for p in "${!st[@]}"; do
  [ "$(proc_start "$p" 2>/dev/null)" = "${st[$p]}" ] && out+="$p($(cat /proc/$p/comm 2>/dev/null),ppid=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)) "; done; echo "${out:-none}"; }

echo; echo "--- step 1: D7's chain, the marker exported and passed through shell_environment_policy.set"
(
  cd "$X/r" || exit 1
  export TMPDIR=$TMPDIR_CX GLAB_EXTERNAL_AGENT=$M
  exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
    setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -c 'shell_environment_policy.inherit="core"' \
    -c "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$M\"" -- sleep 300 >"$X/o2.out" 2>"$X/o2.err"
) &
P=$!
sleep 3
mapfile -t pids < <(desc "$P")
for p in "${pids[@]}"; do
  s=$(proc_start "$p") || continue; st[$p]=$s
  printf '  pid=%s ppid=%s pgid=%s sid=%s comm=%s start=%s marker=%s\n' "$p" $(awk '{print $4, $5, $6}' /proc/$p/stat) "$(cat /proc/$p/comm)" "$s" \
    "$({ tr '\0' '\n' </proc/$p/environ; } 2>/dev/null | command grep -cxF "GLAB_EXTERNAL_AGENT=$M")"
done
echo "recorded: ${#st[@]} pids; marked now: $(marked)"

echo; echo "--- step 2: SIGKILL the outermost setpriv (P=$P)"
kill -KILL "$P"; echo "kill rc=$?"; wait "$P" 2>/dev/null; echo "wait P rc=$?"

echo; echo "--- step 3: known positive, 2 s later"
sleep 2
echo "recorded pids alive: $(alive)"
echo "marked processes: $(marked)"

echo; echo "--- step 4: sweep_agent \"\$M\""
sweep_agent "$M"; echo "sweep_agent rc=$?"

echo; echo "--- step 5: 1 s later"
sleep 1
echo "recorded pids alive: $(alive)"
echo "marked processes: $(marked)"

# Anything still alive is killed by its recorded pid.
for p in "${!st[@]}"; do [ "$(proc_start "$p" 2>/dev/null)" = "${st[$p]}" ] && kill -KILL "$p" && echo "cleanup killed $p"; done
echo "codex sandbox stderr:"; mask <"$X/o2.err" | head -n 8 | sed 's/^/  /'
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `unix.sh` (round 4)

```bash
#!/usr/bin/env bash
# Round 4: can a command inside codex sandbox (read-only) connect to a host AF_UNIX socket?
set -u
: "${TMPDIR:?}"; CX=${CX:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" "$X/sock" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
U=$(id -u)
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g" -e "s#/run/user/$U/#/run/user/<uid>/#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
git -C "$X/r" init -q
echo "CODEX_HOME=<X>/home holds: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
SOCK=$X/sock/s
# 1. A host AF_UNIX listener that logs one line per accepted connection.
python3 -I -c 'import socket,sys
s=socket.socket(socket.AF_UNIX); s.bind(sys.argv[1]); s.listen(8)
open(sys.argv[2],"w").close(); log=open(sys.argv[2],"a",buffering=1)
while True:
  c,_=s.accept(); log.write("accepted\n"); c.close()' "$SOCK" "$X/accepts" & lpid=$!
for _ in $(seq 50); do [ -S "$SOCK" ] && [ -e "$X/accepts" ] && break; sleep 0.1; done
echo "listener pid=$lpid on <X>/sock/s ($( [ -S "$SOCK" ] && echo socket || echo missing))"
probe='import socket,sys
s=socket.socket(socket.AF_UNIX)
try:
  s.connect(sys.argv[1]); print("connect: ok")
except OSError as e:
  print("connect: failed: %s" % e); sys.exit(1)'
acc() { wc -l <"$X/accepts"; }
# 3. Known positive: the same connect outside the sandbox.
n0=$(acc)
python3 -I -c "$probe" "$SOCK" 2>&1 | mask; echo "outside the sandbox: rc=${PIPESTATUS[0]}; listener accepts +$(( $(acc) - n0 ))"
# 2. The same connect inside codex sandbox, with the flags codex_check and S1 use.
sleep 0.3; n0=$(acc)
(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- python3 -I -c "$probe" "$SOCK") >"$X/o" 2>"$X/e"; rc=$?
sleep 0.3
echo "inside codex sandbox: rc=$rc; listener accepts +$(( $(acc) - n0 ))"
echo "  stdout:"; mask <"$X/o" | sed 's/^/    /'; echo "  stderr:"; mask <"$X/e" | head -n 8 | sed 's/^/    /'
# Is the socket file visible inside at all?
(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- sh -c 'test -S "$1"; echo "socket file is a socket inside: test -S rc=$?"' sh "$SOCK") 2>&1 | mask
# 4. Only whether the session bus path is visible inside; no connect to it.
(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"' -- sh -c 'test -S "/run/user/$(id -u)/bus"; echo "bus path test -S rc=$?"') 2>&1 | mask
test -S "/run/user/$U/bus"; echo "bus path on the host, outside the sandbox: test -S rc=$?"
# 5. Cleanup by pid.
kill "$lpid"; wait "$lpid" 2>/dev/null
echo "listener $lpid alive after kill: $(kill -0 "$lpid" 2>/dev/null && echo yes || echo no)"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```

### `o2r5.sh` (round 5)

```bash
#!/usr/bin/env bash
# O2, plan revision 5, on the host under the user's Stage 4 allowance:
# codex sandbox only, a throwaway CODEX_HOME and HOME with a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}; SWEEP=${SWEEP:?}
# sweep_agent, environ_has and proc_start, copied byte for byte from the built script.
# shellcheck source=/dev/null
. "$SWEEP"
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" || exit 1
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"00000000-0000-4000-8000-000000000000","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"00000000-0000-4000-8000-000000000000"}, last_refresh:$now}' >"$CODEX_HOME/auth.json"
chmod 600 "$CODEX_HOME/auth.json"
git -C "$X/r" init -q
echo "CODEX_HOME=<X>/home holds: $(ls -A "$CODEX_HOME" | tr '\n' ' ')"
M=ea-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')
echo "marker M=$M"
echo "this shell carries the marker: $(tr '\0' '\n' </proc/$$/environ | command grep -cxF "GLAB_EXTERNAL_AGENT=$M")"
marked() { # pids of this uid whose environ holds the exact marker line, other than this shell
  local d e out=''
  for d in /proc/[0-9]*; do
    [ -O "$d" ] || continue
    e=$({ tr '\0' '\n' <"$d/environ"; } 2>/dev/null)
    [[ $'\n'$e$'\n' == *$'\n'"GLAB_EXTERNAL_AGENT=$M"$'\n'* ]] && out+="${d#/proc/}($(cat "$d/comm" 2>/dev/null)) "
  done
  echo "${out:-none}"
}
desc() { local q=("$1") p c; while [ ${#q[@]} -gt 0 ]; do p=${q[0]}; q=("${q[@]:1}"); echo "$p"
  for c in /proc/[0-9]*/stat; do c=${c#/proc/}; c=${c%/stat}; [ "$(awk '{print $4}' "/proc/$c/stat" 2>/dev/null)" = "$p" ] && q+=("$c"); done; done; }
declare -A st
alive() { local p out=''; for p in "${!st[@]}"; do
  [ "$(proc_start "$p" 2>/dev/null)" = "${st[$p]}" ] && out+="$p($(cat /proc/$p/comm 2>/dev/null),ppid=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)) "; done; echo "${out:-none}"; }

echo; echo "--- step 1: D7's chain, the marker exported and passed through shell_environment_policy.set"
(
  cd "$X/r" || exit 1
  export TMPDIR=$TMPDIR_CX GLAB_EXTERNAL_AGENT=$M
  exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
    setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' -c 'shell_environment_policy.inherit="core"' \
    -c "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$M\"" -- sleep 300 >"$X/o2.out" 2>"$X/o2.err"
) &
P=$!
sleep 3
mapfile -t pids < <(desc "$P")
for p in "${pids[@]}"; do
  s=$(proc_start "$p") || continue; st[$p]=$s
  printf '  pid=%s ppid=%s pgid=%s sid=%s comm=%s start=%s marker=%s\n' "$p" $(awk '{print $4, $5, $6}' /proc/$p/stat) "$(cat /proc/$p/comm)" "$s" \
    "$({ tr '\0' '\n' </proc/$p/environ; } 2>/dev/null | command grep -cxF "GLAB_EXTERNAL_AGENT=$M")"
done
echo "recorded: ${#st[@]} pids; marked now: $(marked)"

echo; echo "--- step 2: SIGKILL the outermost setpriv (P=$P)"
kill -KILL "$P"; echo "kill rc=$?"; wait "$P" 2>/dev/null; echo "wait P rc=$?"

echo; echo "--- step 3: known positive, 2 s later"
sleep 2
echo "recorded pids alive: $(alive)"
echo "marked processes: $(marked)"

echo; echo "--- step 4: sweep_agent \"\$M\""
sweep_agent "$M"; echo "sweep_agent rc=$?"

echo; echo "--- step 5: 1 s later"
sleep 1
echo "recorded pids alive: $(alive)"
echo "marked processes: $(marked)"

# Anything still alive is killed by its recorded pid.
for p in "${!st[@]}"; do [ "$(proc_start "$p" 2>/dev/null)" = "${st[$p]}" ] && kill -KILL "$p" && echo "cleanup killed $p"; done
echo "codex sandbox stderr:"; mask <"$X/o2.err" | head -n 8 | sed 's/^/  /'
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```
