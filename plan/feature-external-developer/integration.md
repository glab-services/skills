# feature-external-developer — integration (Stage 4)

Run on 2026-10-18, between about 17:05Z and 17:12Z, by the Stage 4
integrator. It covers the offline measurements M1–M5 of `plan.md` revision 2
(*After* §3), with their control runs. Codex was the real CLI
`codex-cli 0.163.0` at `~/.local/bin/codex`, and the script was the
working-tree `plugins/glab/scripts/external-agent.sh`.

Verdict: **INTEGRATED**.

- Every measurement gave the plan's expected result.
- The real header string for a developer turn is exactly
  `sandbox: workspace-write [workdir]`, which is the string `codex_verify`
  accepts (D3).
- One defect in the plan's own measurement command: `WW` as written passes
  `-C "$X/r"`, which `codex sandbox` 0.163.0 takes only together with
  `-P/--permission-profile`. Every `WW` call exited 2 with a usage error.
  - The measurements were re-run with `-C` dropped. The command already
    `cd`s into `$X/r`, and every sandbox flag is unchanged.
  - The script never passes `-C` to Codex, so this is a wrong measurement
    command in the plan, not a fault in the build.

## Suite, and how it was chosen

There is no automated suite for this. The Stage 4 measurements are those
`plan.md` *After* §3 defines; the dispatch named M1–M5. `tests/` holds only
the stub-based gate tests, which ran at the develop stage. Each measurement
was saved as a script under `$TMPDIR` and run. The scripts are at the end of
this file, verbatim, with host values masked.

## Allowances, and how each was kept

From `questions.md` *Approval* (the user, 2026-10-18), and the standing
`codex sandbox` allowance of `feature-codex-agent`:

- **M1–M4** ran as `~/.local/bin/codex sandbox …` on the host, with the
  workspace-write flags of the plan.
- **M5** was one real `external-agent.sh start --backend codex --role
  developer` inside `bwrap --dev-bind / / --unshare-net --die-with-parent`.
  The run printed `netns: lo routes=0` and `connect 1.1.1.1:443 rc=1` before
  the start. The turn failed at the network, and no model was reached.

What every run had:

- A fresh `X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX")`.
- `CODEX_HOME=$X/home` holding only the fake `auth.json`, as the run printed:
  `CODEX_HOME=<X>/home holds: auth.json`. That file is O1's, from
  `9108ac7:plan/feature-codex-agent/integration.md`: unsigned `alg: none`
  JWTs, `dummy@example.invalid`, a zero account id and `dummy-refresh`.
- `HOME=$X/uhome`, and Codex's `TMPDIR=$X/tmp`.
- A throwaway repository `$X/r` with one commit, and never the user's
  repository.
- `CX` set to `<home>/.local/bin/codex` before `HOME` changed.

What no run did:

- read, list or write the real `~/.codex`;
- run `login`;
- run an `exec` with network.

Cleanup:

- Each run ended with `rm -rf "$X"`, and each printed `X removed: yes`.
- Every listener was killed by its pid.
- `export TMPDIR=/data/tmp/claude` held throughout.

Already running and left alone: the four `glab-*` Docker containers, and
the user's two `codex` processes, which started before these runs. Nothing
was started that is still up.

## The copied functions

M3 records the `dev_state` `git` digest with the built functions. `hostgit`
(`:312`), `dev_state` (`:327`) and `dev_git` (`:348`) were copied from the
working tree with
`awk '/^(hostgit|dev_state|dev_git)\(\) \{/{p=1} p{print} p&&/^}/{p=0}'`.

- That is 34 lines. A check that each line occurs whole in the script
  printed no `missing:` line.
- The sha256 of the copied text is
  `c2f702432b42944cec648f30643311b987253f46a3baaee57cf69ed83c2f4b5e`.

## Round 1: the plan's `WW`, as written

The command was:

    REALHOME="$HOME" P0="$PATH" DEVSTATE=<work>/devstate.sh CX="$HOME/.local/bin/codex" timeout 300 bash m1m4.sh

Every `codex sandbox -C "$X/r" …` call printed the same lines and exited 2.
Here are the first of them, M1b and M1a:

    ===== M1b (control first): read-only
      write f: rc=2; stderr: error: the following required arguments were not provided:|  --permission-profile <NAME>||
    ===== M1a: workspace-write
      write f: rc=2; stderr: error: the following required arguments were not provided:|  --permission-profile <NAME>||

The full usage text, from M4's capture:

    error: the following required arguments were not provided:
      --permission-profile <NAME>

    Usage: codex sandbox --permission-profile <NAME> --cd <DIR> --config <key=value> <COMMAND>...

`codex sandbox --help`, run in a throwaway `CODEX_HOME`, says of `-C, --cd
<DIR>`: "Working directory used for profile resolution and command
execution". It lists `-P, --permission-profile <NAME>` beside it. So in
0.163.0, `-C` requires `-P`.

Nothing was written in round 1:

- `f: absent` after M1a.
- The digest and HEAD were the same before and after M3.
- M4's controls outside the sandbox still counted +1 on each listener.

## Round 2: `WW` without `-C`

Each command still runs from `cd "$X/r"`, the same way S1 of
`feature-codex-agent` ran. `WW` became:

    (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -c 'sandbox_workspace_write.exclude_tmpdir_env_var=true' -c 'sandbox_workspace_write.exclude_slash_tmp=true' -- <cmd>)

- `RO`, the M1b control, is the same command with only
  `-c 'sandbox_mode="read-only"'`.
- `WWX`, the M2b control, is `WW` without the two `exclude_*` keys.

The run was `… bash m1m4b.sh`, the script below. Its output:

    CODEX_HOME=<X>/home holds: auth.json ; repo <X>/r HEAD=ba914f2

    ===== M1b (control first): read-only
      write f: rc=2; stderr: sh: 1: cannot create f: Read-only file system|
      edit tracked README: rc=2; stderr: sh: 1: cannot create README: Read-only file system|
      f: absent; git status:

    ===== M1a: workspace-write
      write f: rc=0
      edit tracked README: rc=0
      f holds: x; git status:  M README|?? f|

    ===== M2a: writes outside the workdir, under WW
      write <X>/outside/f: rc=2; stderr: sh: 1: cannot create <X>/outside/f: Read-only file system|
        exists after: no
      write <X>/uhome/f: rc=2; stderr: sh: 1: cannot create <X>/uhome/f: Read-only file system|
        exists after: no
      write <X>/tmp/f: rc=2; stderr: sh: 1: cannot create <X>/tmp/f: Read-only file system|
        exists after: no
      write /tmp/fed-int-2411940-14897: rc=2; stderr: sh: 1: cannot create /tmp/fed-int-2411940-14897: Read-only file system|
        exists after: no

    ===== M2b: control, WW without the two exclude_* keys
      write <X>/tmp/f: rc=0
        exists after: yes
        removed: yes
      write /tmp/fed-int-2411940-14897: rc=0
        exists after: yes
        removed: yes

    ===== M3: .git under WW
      before: dev_state git 7bee673ad6bf34bd01ca76c4ef644e4516a0f925e60f53285d182c7699a0ac91; HEAD=ba914f2be373f2140129479778c0ad7c5c16a12b
      append .git/config: rc=2; stderr: sh: 1: cannot create .git/config: Read-only file system|
      create .git/hooks/pre-commit: rc=2; stderr: sh: 1: cannot create .git/hooks/pre-commit: Read-only file system|
      git commit --allow-empty: rc=128; stderr: fatal: Unable to create '<X>/r/.git/index.lock': Read-only file system|
      git update-ref refs/heads/x HEAD: rc=128; stderr: fatal: update_ref failed for ref 'refs/heads/x': cannot lock ref 'refs/heads/x': Unable to create '<X>/r/.git/refs/heads/x.lock': Read-only file system|
      git add f: rc=128; stderr: fatal: Unable to create '<X>/r/.git/index.lock': Read-only file system|
      after:  dev_state git 7bee673ad6bf34bd01ca76c4ef644e4516a0f925e60f53285d182c7699a0ac91; HEAD=ba914f2be373f2140129479778c0ad7c5c16a12b
      digest same: yes; HEAD same: yes
      .git/config has [m3]: 0; pre-commit exists: no; refs/heads/x: no; f staged:

    ===== M4: network under WW
      listeners: tcp pid=2412707 on 127.0.0.1:35109; unix pid=2412708 on <X>/sock/s
      outside: tcp rc=0 'connect: ok' accepts +1; unix rc=0 'connect: ok' accepts +1
      inside: tcp rc=1 'Traceback (most recent call last):
      ...
    PermissionError: [Errno 1] Operation not permitted' accepts +0; unix rc=1 'connect: failed: [Errno 1] Operation not permitted' accepts +0
      listeners alive after kill:   (blank = none)

    X removed: yes; /tmp/fed-int-2411940-14897 present: no

| id | expected (plan) | got | result |
|---|---|---|---|
| M1a | rc 0; `f` holds `x`; `git status` shows both | rc 0 and rc 0; `f` holds `x`; ` M README` and `?? f` | pass |
| M1b | non-zero; nothing changed | rc 2 and rc 2, `Read-only file system`; `f` absent, status empty | pass |
| M2a | each non-zero; none exists after | all four rc 2, `Read-only file system`, none exists, `$TMPDIR` (`$X/tmp`) and `/tmp` included | pass |
| M2b | rc 0, so 0.163.0 honours the `exclude_*` keys | `$X/tmp/f` and `/tmp/<name>` rc 0 and exist without the keys (then removed) | pass |
| M3 | record each rc, the digest and HEAD | every `.git` write refused: rc 2, 2, 128, 128, 128; digest and HEAD unchanged | recorded: **`.git` is blocked** |
| M4 | both refused; outside +1, inside +0 | TCP refused at `socket()` (EPERM), AF_UNIX at `connect()` (EPERM), +0 inside; +1 each outside | pass |

What M3 shows: under `workspace-write` with the workdir as the only writable
root, `.git` inside that root stays read-only.

- Codex 0.163.0 refuses all five writes: appending to `.git/config`,
  creating a hook, `commit`, `update-ref`, and `add`, which writes the
  index.
- So a developer's commands cannot commit, stage, or plant a hook.
- This matches Codex's documented protection of `<writable_root>/.git`
  (`feature-codex-agent/findings.md` §9.2).
- It is told to the user before Stage 5 as the plan asks. Here `.git` is
  blocked, not writable.
- Inferred: a developer turn's own `git add` would fail too. The
  `glab:developer` contract has the developer not commit, so this does not
  break the role.

## M5 — one offline developer `start`

The command (script `m5.sh` below):

    KEEP=<work>/keep REALHOME="$HOME" CX="$HOME/.local/bin/codex" S=<repo>/plugins/glab/scripts/external-agent.sh \
      timeout 600 bwrap --dev-bind / / --unshare-net --die-with-parent -- bash m5.sh

Inside the wrapper, it ran:

    (cd "$X/r" && TMPDIR=$X/tmp "$S" start --backend codex --role developer --cli "$CX" --brief "$X/brief.md" --repo "$X/r" --timeout 300)

Output:

    netns: lo routes=0
    connect 1.1.1.1:443 rc=1
    CODEX_HOME=<X>/home holds: auth.json ; repo <X>/r HEAD=1e28a9a; status: ''
    --- start rc=7
    stdout:
      agent: ea-7d2a39e3f491bc8d · model: codex:gpt-6.1-sol · turn: 1 · transcript: <X>/tmp/glab-external-agents/ea-7d2a39e3f491bc8d/transcript.txt
      changed: none
      git: unchanged
      end: ea-7d2a39e3f491bc8d
    stderr:
      external-agent: BACKEND ERROR: workspace routing discovery failed
    agent.json: {"backend":"codex","role":"developer","ran":"gpt-6.1-sol","turns":1,"session":"<session-uuid>","ready":true}
    transcript.log header block, raw bytes of the sandbox line shown with cat -A:
      OpenAI Codex v0.163.0
      --------
      workdir: <X>/r
      model: gpt-6.1-sol
      provider: openai
      approval: never
      sandbox: workspace-write [workdir]
      reasoning effort: none
      reasoning summaries: none
      session id: <session-uuid>
      --------
      sandbox: workspace-write [workdir]$
    lines before the version line: 3
    transcript.log last ERROR lines:
      ERROR: Reconnecting... 5/5
      ERROR: workspace routing discovery failed
      ERROR: workspace routing discovery failed
    repo after: HEAD=1e28a9a; status: ''
      stop: stopped: ea-7d2a39e3f491bc8d
    processes carrying GLAB_EXTERNAL_AGENT=ea-7d2a39e3f491bc8d after stop: none
    X removed: yes

| expected (plan) | got | result |
|---|---|---|
| rc 7 at the network | rc 7, `BACKEND ERROR: workspace routing discovery failed` | pass |
| header `sandbox: workspace-write [workdir]` | exactly that; `cat -A` shows no trailing byte | pass |
| header `approval: never` | `approval: never` | pass |
| stdout `changed: none` and `git: unchanged` | both, between the `agent:` line and `end:` | pass |
| (not rc 12) | not rc 12: `codex_verify` accepted the real string | pass |

The real header string matches the script exactly. `codex_verify` wants
`workspace-write [workdir]` for a developer (`:695`), and 0.163.0 printed
`sandbox: workspace-write [workdir]`. The `/tmp` and `$TMPDIR` entries are
absent because the two `exclude_*` keys are set, as F2 inferred. D3 is not
`PLAN WRONG`.

More from the run:

- The first message in `transcript.log` is the developer text ("You are an
  external developer in the glab workflow", "you in its workspace-write
  sandbox: your commands can change files in …"). The developer contract
  follows it.
- `stop` printed `stopped:`.
- Afterwards no process carried the agent's marker, and the repository's
  HEAD and status were unchanged.
- The kept transcript held no `eyJ` and no unmasked home path. It was
  removed with the work dir.

## Failures, classified

| item | classification | detail |
|---|---|---|
| The plan's `WW` with `-C "$X/r"` (round 1) | **plan error in the measurement command**, not a regression | `codex sandbox` 0.163.0 requires `-P` with `-C`; the script does not use `-C`; re-run without it |

There are no regressions, and nothing was found pre-existing.

## What these runs settle

- **D2's flags:**
  - the workdir is writable;
  - `$TMPDIR` and `/tmp` are excluded, and the keys are honoured (M2b);
  - other paths are read-only;
  - the network is off for TCP and for AF_UNIX (M1, M2, M4).
- **U2/D4's question:** `.git` is read-only under this sandbox (M3).
- **D3's string:** `workspace-write [workdir]` is what 0.163.0 prints with
  these flags (M5).
- **D4's report on a real turn with no change:** `changed: none` and
  `git: unchanged` (M5).

## Still UNVERIFIED

- **Whether Codex itself, outside its command sandbox, changes a ref or
  `.git` during a real turn.** That would print `git: changed` every turn,
  and it needs a live run.
- **How a real model does as a developer.** This also needs a live run,
  which only the user starts.
- **The report's lines on exits other than 7 with the real binary**
  (0, 6, 12). Only exit 7 was run; the stub test covers the rest.
- **A developer `send` with the real binary.** It needs a session to
  resume, and the dispatch named `start` only.

## The scripts, verbatim

The user's home directory is masked as `<home>`. The work dir
`/data/tmp/claude/fed-int.HleteI` has been removed.

### `devstate.sh`

```bash
hostgit() {
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_OPTIONAL_LOCKS=0 GIT_TERMINAL_PROMPT=0 \
    git -c core.fsmonitor=false -c core.untrackedCache=false -c core.hooksPath=/dev/null "$@"
}
dev_state() { # dev_state <top>
  local ents=() e p k cdir d
  mapfile -d '' -t ents < <(hostgit -C "$1" status --porcelain=v1 -z --no-renames --untracked-files=all)
  wait "$!" || return 1
  for e in "${ents[@]}"; do
    p=${e:3}
    if [ -L "$1/$p" ]; then k=link:$(printf '%q' "$(readlink -- "$1/$p")")
    elif [ -f "$1/$p" ]; then k=$(hostgit -C "$1" hash-object --no-filters -- "$p") || return 1
    elif [ ! -e "$1/$p" ]; then k=none
    else k=other; fi
    printf '%s\t%s\t%q\n' "${e:0:2}" "$k" "$p"
  done | sort || return 1
  # The common dir, not --git-path hooks: hostgit sets core.hooksPath=/dev/null.
  cdir=$(hostgit -C "$1" rev-parse --path-format=absolute --git-common-dir) || return 1
  d=$(dev_git "$1" "$cdir" | sha256sum) || return 1
  printf 'git\t%s\n' "${d%% *}"
}
dev_git() { # dev_git <top> <common dir>
  local r=0
  hostgit -C "$1" rev-parse -q --verify HEAD || r=$?
  case $r in 0) ;; 1) echo 'head: none' ;; *) return 1 ;; esac
  r=0; hostgit -C "$1" symbolic-ref -q HEAD || r=$?
  case $r in 0) ;; 1) echo 'symref: none' ;; *) return 1 ;; esac
  hostgit -C "$1" for-each-ref --format='%(objectname) %(refname)' || return 1
  if [ -e "$2/config" ]; then cat -- "$2/config" || return 1; else echo 'config: none'; fi
  if [ -d "$2/hooks" ]; then
    { find "$2/hooks" -mindepth 1 ! -type f -printf '%y %P %l\n' \
        && find "$2/hooks" -type f -exec sha256sum -- {} +; } | sort || return 1
  fi
}
```

### `m1m4.sh`

```bash
#!/usr/bin/env bash
# M1-M4 of plan/feature-external-developer/plan.md *After* 3, on the host under
# the user's codex sandbox allowance: a throwaway repo, CODEX_HOME and HOME, a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}; P0=${P0:?}; DEVSTATE=${DEVSTATE:?}
# hostgit, dev_state and dev_git, copied byte for byte from the built script.
# shellcheck source=/dev/null
. "$DEVSTATE"
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" "$X/outside" "$X/sock" || exit 1
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"<session-uuid>","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"<session-uuid>"}, last_refresh:$now}' >"$X/home/auth.json"
chmod 600 "$X/home/auth.json"
G() { git -C "$X/r" -c user.name=t -c user.email=t@t.invalid "$@"; }
G init -q && printf 'tracked\n' >"$X/r/README" && G add README && G commit -qm init
echo "CODEX_HOME=<X>/home holds: $(ls -A "$X/home" | tr '\n' ' '); repo <X>/r HEAD=$(G rev-parse --short HEAD)"
U=fed-int-$$-$RANDOM
# WW, as the plan gives it; RO is the same with read-only for the M1b control;
# WWX is WW without the two exclude_* keys, for M2b.
WW() { (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -C "$X/r" -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -c 'sandbox_workspace_write.exclude_tmpdir_env_var=true' -c 'sandbox_workspace_write.exclude_slash_tmp=true' -- "$@"); }
RO() { (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -C "$X/r" -c 'sandbox_mode="read-only"' -- "$@"); }
WWX() { (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -C "$X/r" -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -- "$@"); }
r() { # r <label> <runner> <cmd...>
  local label=$1 runner=$2; shift 2
  "$runner" "$@" >"$X/o" 2>"$X/e"; local rc=$?
  echo "  $label: rc=$rc$( [ -s "$X/e" ] && printf '; stderr: %s' "$(mask <"$X/e" | head -n 3 | tr '\n' '|')")"
}

echo; echo "===== M1b (control first): read-only"
r "write f" RO sh -c 'echo x >f'
r "edit tracked README" RO sh -c 'echo y >>README'
echo "  f: $( [ -e "$X/r/f" ] && echo exists || echo absent); git status: $(G status --porcelain | tr '\n' '|')"

echo; echo "===== M1a: workspace-write"
r "write f" WW sh -c 'echo x >f'
r "edit tracked README" WW sh -c 'echo y >>README'
echo "  f holds: $(cat "$X/r/f" 2>&1); git status: $(G status --porcelain | tr '\n' '|')"

echo; echo "===== M2a: writes outside the workdir, under WW"
for t in "$X/outside/f" "$X/uhome/f" "$X/tmp/f" "/tmp/$U"; do
  r "write $(printf '%s' "$t" | mask)" WW sh -c 'echo x >"$1"' sh "$t"
  echo "    exists after: $( [ -e "$t" ] && echo yes || echo no)"
done

echo; echo "===== M2b: control, WW without the two exclude_* keys"
for t in "$X/tmp/f" "/tmp/$U"; do
  r "write $(printf '%s' "$t" | mask)" WWX sh -c 'echo x >"$1"' sh "$t"
  echo "    exists after: $( [ -e "$t" ] && echo yes || echo no)"
  rm -f -- "$t"; echo "    removed: $( [ -e "$t" ] && echo no || echo yes)"
done

echo; echo "===== M3: .git under WW"
b=$(dev_state "$X/r" | tail -n 1); hb=$(G rev-parse HEAD)
echo "  before: dev_state $(printf '%s' "$b" | tr '\t' ' '); HEAD=$hb"
r "append .git/config" WW sh -c 'printf "[m3]\n\tx = 1\n" >>.git/config'
r "create .git/hooks/pre-commit" WW sh -c 'printf "#!/bin/sh\nexit 0\n" >.git/hooks/pre-commit'
r "git commit --allow-empty" WW git -c user.name=t -c user.email=t@t.invalid commit --allow-empty -qm t
r "git update-ref refs/heads/x HEAD" WW git update-ref refs/heads/x HEAD
r "git add f" WW git add f
a=$(dev_state "$X/r" | tail -n 1); ha=$(G rev-parse HEAD)
echo "  after:  dev_state $(printf '%s' "$a" | tr '\t' ' '); HEAD=$ha"
echo "  digest same: $( [ "$a" = "$b" ] && echo yes || echo no); HEAD same: $( [ "$ha" = "$hb" ] && echo yes || echo no)"
echo "  .git/config has [m3]: $(command grep -c '^\[m3\]' "$X/r/.git/config"); pre-commit exists: $( [ -e "$X/r/.git/hooks/pre-commit" ] && echo yes || echo no); refs/heads/x: $(G show-ref --verify -q refs/heads/x && echo yes || echo no); f staged: $(G diff --cached --name-only | tr '\n' ' ')"

echo; echo "===== M4: network under WW"
python3 -I -c 'import socket,sys
s=socket.socket(); s.bind(("127.0.0.1",0)); s.listen(8)
open(sys.argv[1],"w").write(str(s.getsockname()[1])); log=open(sys.argv[2],"a",buffering=1)
while True:
  c,_=s.accept(); log.write("a\n"); c.close()' "$X/port" "$X/tcp.log" & tpid=$!
python3 -I -c 'import socket,sys
s=socket.socket(socket.AF_UNIX); s.bind(sys.argv[1]); s.listen(8); log=open(sys.argv[2],"a",buffering=1)
while True:
  c,_=s.accept(); log.write("a\n"); c.close()' "$X/sock/s" "$X/unix.log" & upid=$!
for _ in $(seq 50); do [ -s "$X/port" ] && [ -S "$X/sock/s" ] && break; sleep 0.1; done
touch "$X/tcp.log" "$X/unix.log"; port=$(cat "$X/port")
echo "  listeners: tcp pid=$tpid on 127.0.0.1:$port; unix pid=$upid on <X>/sock/s"
n() { wc -l <"$1"; }
tcp='import socket,sys
s=socket.socket()
try: s.connect(("127.0.0.1",int(sys.argv[1]))); print("connect: ok")
except OSError as e: print("connect: failed: %s" % e); sys.exit(1)'
unix='import socket,sys
s=socket.socket(socket.AF_UNIX)
try: s.connect(sys.argv[1]); print("connect: ok")
except OSError as e: print("connect: failed: %s" % e); sys.exit(1)'
for side in outside inside; do
  t0=$(n "$X/tcp.log") u0=$(n "$X/unix.log")
  if [ $side = outside ]; then
    ot=$(python3 -I -c "$tcp" "$port" 2>&1); rt=$?; ou=$(python3 -I -c "$unix" "$X/sock/s" 2>&1); ru=$?
  else
    ot=$(WW python3 -I -c "$tcp" "$port" 2>&1); rt=$?; ou=$(WW python3 -I -c "$unix" "$X/sock/s" 2>&1); ru=$?
  fi
  sleep 0.3
  echo "  $side: tcp rc=$rt '$ot' accepts +$(( $(n "$X/tcp.log") - t0 )); unix rc=$ru '$ou' accepts +$(( $(n "$X/unix.log") - u0 ))"
done
kill "$tpid" "$upid"; wait "$tpid" "$upid" 2>/dev/null
echo "  listeners alive after kill: $(kill -0 "$tpid" 2>/dev/null && echo tcp) $(kill -0 "$upid" 2>/dev/null && echo unix) (blank = none)"
rm -f -- "/tmp/$U"
rm -rf "$X"; echo; echo "X removed: $( [ -e "$X" ] && echo no || echo yes); /tmp/$U present: $( [ -e "/tmp/$U" ] && echo yes || echo no)"
```

### `m1m4b.sh`

```bash
#!/usr/bin/env bash
# M1-M4 of plan/feature-external-developer/plan.md *After* 3, on the host under
# the user's codex sandbox allowance: a throwaway repo, CODEX_HOME and HOME, a fake auth.json.
set -u
: "${TMPDIR:?}"; CX=${CX:?}; P0=${P0:?}; DEVSTATE=${DEVSTATE:?}
# hostgit, dev_state and dev_git, copied byte for byte from the built script.
# shellcheck source=/dev/null
. "$DEVSTATE"
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" "$X/outside" "$X/sock" || exit 1
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"<session-uuid>","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"<session-uuid>"}, last_refresh:$now}' >"$X/home/auth.json"
chmod 600 "$X/home/auth.json"
G() { git -C "$X/r" -c user.name=t -c user.email=t@t.invalid "$@"; }
G init -q && printf 'tracked\n' >"$X/r/README" && G add README && G commit -qm init
echo "CODEX_HOME=<X>/home holds: $(ls -A "$X/home" | tr '\n' ' '); repo <X>/r HEAD=$(G rev-parse --short HEAD)"
U=fed-int-$$-$RANDOM
# WW, as the plan gives it but without -C "$X/r", which 0.163.0 takes only with -P (round 1); RO is the same with read-only for the M1b control;
# WWX is WW without the two exclude_* keys, for M2b.
WW() { (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -c 'sandbox_workspace_write.exclude_tmpdir_env_var=true' -c 'sandbox_workspace_write.exclude_slash_tmp=true' -- "$@"); }
RO() { (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -c 'sandbox_mode="read-only"' -- "$@"); }
WWX() { (cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -- "$@"); }
r() { # r <label> <runner> <cmd...>
  local label=$1 runner=$2; shift 2
  "$runner" "$@" >"$X/o" 2>"$X/e"; local rc=$?
  echo "  $label: rc=$rc$( [ -s "$X/e" ] && printf '; stderr: %s' "$(mask <"$X/e" | head -n 3 | tr '\n' '|')")"
}

echo; echo "===== M1b (control first): read-only"
r "write f" RO sh -c 'echo x >f'
r "edit tracked README" RO sh -c 'echo y >>README'
echo "  f: $( [ -e "$X/r/f" ] && echo exists || echo absent); git status: $(G status --porcelain | tr '\n' '|')"

echo; echo "===== M1a: workspace-write"
r "write f" WW sh -c 'echo x >f'
r "edit tracked README" WW sh -c 'echo y >>README'
echo "  f holds: $(cat "$X/r/f" 2>&1); git status: $(G status --porcelain | tr '\n' '|')"

echo; echo "===== M2a: writes outside the workdir, under WW"
for t in "$X/outside/f" "$X/uhome/f" "$X/tmp/f" "/tmp/$U"; do
  r "write $(printf '%s' "$t" | mask)" WW sh -c 'echo x >"$1"' sh "$t"
  echo "    exists after: $( [ -e "$t" ] && echo yes || echo no)"
done

echo; echo "===== M2b: control, WW without the two exclude_* keys"
for t in "$X/tmp/f" "/tmp/$U"; do
  r "write $(printf '%s' "$t" | mask)" WWX sh -c 'echo x >"$1"' sh "$t"
  echo "    exists after: $( [ -e "$t" ] && echo yes || echo no)"
  rm -f -- "$t"; echo "    removed: $( [ -e "$t" ] && echo no || echo yes)"
done

echo; echo "===== M3: .git under WW"
b=$(dev_state "$X/r" | tail -n 1); hb=$(G rev-parse HEAD)
echo "  before: dev_state $(printf '%s' "$b" | tr '\t' ' '); HEAD=$hb"
r "append .git/config" WW sh -c 'printf "[m3]\n\tx = 1\n" >>.git/config'
r "create .git/hooks/pre-commit" WW sh -c 'printf "#!/bin/sh\nexit 0\n" >.git/hooks/pre-commit'
r "git commit --allow-empty" WW git -c user.name=t -c user.email=t@t.invalid commit --allow-empty -qm t
r "git update-ref refs/heads/x HEAD" WW git update-ref refs/heads/x HEAD
r "git add f" WW git add f
a=$(dev_state "$X/r" | tail -n 1); ha=$(G rev-parse HEAD)
echo "  after:  dev_state $(printf '%s' "$a" | tr '\t' ' '); HEAD=$ha"
echo "  digest same: $( [ "$a" = "$b" ] && echo yes || echo no); HEAD same: $( [ "$ha" = "$hb" ] && echo yes || echo no)"
echo "  .git/config has [m3]: $(command grep -c '^\[m3\]' "$X/r/.git/config"); pre-commit exists: $( [ -e "$X/r/.git/hooks/pre-commit" ] && echo yes || echo no); refs/heads/x: $(G show-ref --verify -q refs/heads/x && echo yes || echo no); f staged: $(G diff --cached --name-only | tr '\n' ' ')"

echo; echo "===== M4: network under WW"
python3 -I -c 'import socket,sys
s=socket.socket(); s.bind(("127.0.0.1",0)); s.listen(8)
open(sys.argv[1],"w").write(str(s.getsockname()[1])); log=open(sys.argv[2],"a",buffering=1)
while True:
  c,_=s.accept(); log.write("a\n"); c.close()' "$X/port" "$X/tcp.log" & tpid=$!
python3 -I -c 'import socket,sys
s=socket.socket(socket.AF_UNIX); s.bind(sys.argv[1]); s.listen(8); log=open(sys.argv[2],"a",buffering=1)
while True:
  c,_=s.accept(); log.write("a\n"); c.close()' "$X/sock/s" "$X/unix.log" & upid=$!
for _ in $(seq 50); do [ -s "$X/port" ] && [ -S "$X/sock/s" ] && break; sleep 0.1; done
touch "$X/tcp.log" "$X/unix.log"; port=$(cat "$X/port")
echo "  listeners: tcp pid=$tpid on 127.0.0.1:$port; unix pid=$upid on <X>/sock/s"
n() { wc -l <"$1"; }
tcp='import socket,sys
s=socket.socket()
try: s.connect(("127.0.0.1",int(sys.argv[1]))); print("connect: ok")
except OSError as e: print("connect: failed: %s" % e); sys.exit(1)'
unix='import socket,sys
s=socket.socket(socket.AF_UNIX)
try: s.connect(sys.argv[1]); print("connect: ok")
except OSError as e: print("connect: failed: %s" % e); sys.exit(1)'
for side in outside inside; do
  t0=$(n "$X/tcp.log") u0=$(n "$X/unix.log")
  if [ $side = outside ]; then
    ot=$(python3 -I -c "$tcp" "$port" 2>&1); rt=$?; ou=$(python3 -I -c "$unix" "$X/sock/s" 2>&1); ru=$?
  else
    ot=$(WW python3 -I -c "$tcp" "$port" 2>&1); rt=$?; ou=$(WW python3 -I -c "$unix" "$X/sock/s" 2>&1); ru=$?
  fi
  sleep 0.3
  echo "  $side: tcp rc=$rt '$ot' accepts +$(( $(n "$X/tcp.log") - t0 )); unix rc=$ru '$ou' accepts +$(( $(n "$X/unix.log") - u0 ))"
done
kill "$tpid" "$upid"; wait "$tpid" "$upid" 2>/dev/null
echo "  listeners alive after kill: $(kill -0 "$tpid" 2>/dev/null && echo tcp) $(kill -0 "$upid" 2>/dev/null && echo unix) (blank = none)"
rm -f -- "/tmp/$U"
rm -rf "$X"; echo; echo "X removed: $( [ -e "$X" ] && echo no || echo yes); /tmp/$U present: $( [ -e "/tmp/$U" ] && echo yes || echo no)"
```

### `m5.sh`

```bash
#!/usr/bin/env bash
# M5, inside bwrap --dev-bind / / --unshare-net --die-with-parent: one real
# developer start against a throwaway repo with a fake login; no model is reached.
set -u
: "${TMPDIR:?}"; CX=${CX:?}; S=${S:?}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" "$X/uhome" "$X/r" || exit 1
export CODEX_HOME=$X/home HOME=$X/uhome
mask() { sed -e "s#$X#<X>#g" -e "s#${REALHOME:?}#<home>#g"; }
echo "netns: $(ip -o link | awk -F': ' '{print $2}' | tr '\n' ' ')routes=$(ip -o route | wc -l)"
timeout 5 bash -c 'exec 3<>/dev/tcp/1.1.1.1/443' 2>/dev/null; echo "connect 1.1.1.1:443 rc=$?"
b64() { base64 -w0 | tr '+/' '-_' | tr -d '='; }
hdr=$(printf '{"alg":"none","typ":"JWT"}' | b64)
pl=$(printf '{"exp":4102444800,"iat":1760000000,"email":"dummy@example.invalid","https://api.openai.com/auth":{"chatgpt_plan_type":"plus","chatgpt_account_id":"<session-uuid>","chatgpt_user_id":"user-dummy"}}' | b64)
jwt="$hdr.$pl.ZHVtbXk"
jq -n --arg j "$jwt" --arg now "$(date -u +%FT%T.000000Z)" \
  '{auth_mode:"chatgpt", OPENAI_API_KEY:null, tokens:{id_token:$j, access_token:$j, refresh_token:"dummy-refresh", account_id:"<session-uuid>"}, last_refresh:$now}' >"$X/home/auth.json"
chmod 600 "$X/home/auth.json"
G() { git -C "$X/r" -c user.name=t -c user.email=t@t.invalid "$@"; }
G init -q && printf 'tracked\n' >"$X/r/README" && G add README && G commit -qm init
echo "CODEX_HOME=<X>/home holds: $(ls -A "$X/home" | tr '\n' ' '); repo <X>/r HEAD=$(G rev-parse --short HEAD); status: '$(G status --porcelain)'"
printf 'Say hello.\n' >"$X/brief.md"
(cd "$X/r" && TMPDIR=$X/tmp "$S" start --backend codex --role developer --cli "$CX" --brief "$X/brief.md" --repo "$X/r" --timeout 300) >"$X/out" 2>"$X/err"; rc=$?
echo "--- start rc=$rc"
echo "stdout:"; mask <"$X/out" | sed 's/^/  /'
echo "stderr:"; mask <"$X/err" | sed 's/^/  /'
id=$(sed -n 's/^agent: \(ea-[0-9a-f]*\) .*/\1/p' "$X/out" | head -n 1)
adir=$X/tmp/glab-external-agents/$id
echo "agent.json: $(jq -c '{backend,role,ran,turns,session,ready}' "$adir/agent.json" 2>&1)"
echo "transcript.log header block, raw bytes of the sandbox line shown with cat -A:"
awk '/^OpenAI Codex v/{s=1} s{print} s && /^--------$/ {n++; if (n==2) exit}' "$adir/transcript.log" | mask | sed 's/^/  /'
command grep -m1 '^sandbox: ' "$adir/transcript.log" | cat -A | sed 's/^/  /'
echo "lines before the version line: $(awk '/^OpenAI Codex v/{print NR-2; exit}' "$adir/transcript.log")"
echo "transcript.log last ERROR lines:"; command grep '^ERROR' "$adir/transcript.log" | tail -n 3 | mask | sed 's/^/  /'
echo "repo after: HEAD=$(G rev-parse --short HEAD); status: '$(G status --porcelain)'"
mask <"$adir/transcript.log" >"$KEEP/m5.transcript.log" 2>/dev/null
(TMPDIR=$X/tmp "$S" stop "$id") 2>&1 | sed 's/^/  stop: /'
left=''
for d in /proc/[0-9]*; do
  [ -O "$d" ] || continue
  { tr '\0' '\n' <"$d/environ"; } 2>/dev/null | command grep -qxF "GLAB_EXTERNAL_AGENT=$id" && left+="${d#/proc/} "
done
echo "processes carrying GLAB_EXTERNAL_AGENT=$id after stop: ${left:-none}"
rm -rf "$X"; echo "X removed: $( [ -e "$X" ] && echo no || echo yes)"
```
