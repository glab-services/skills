tier: full — it adds a second containment model for external agents (Codex on the host under its own read-only sandbox) and changes what an external model may read on this machine

# feature-codex-agent — plan (revision 6)

Codex becomes a read-only external-agent backend of
`plugins/glab/scripts/external-agent.sh`, beside OpenCode. The manager
starts, sends to, lists and stops a Codex agent with the same commands, the
same header line, the same exit codes and the same record line as an
OpenCode agent. Unlike OpenCode, Codex runs **on the host, in the real
repository, under Codex's own read-only sandbox**, with Codex's own login.
OpenCode and its bwrap sandbox do not change. `glab` goes from 0.5.0 to 0.6.0.

Where the inputs are:

- The evidence: `findings.md`. Its §9 is revision 2 and binds, §9.7 and §9.8
  hold the corrections and the facts added since, and §1–§8 are revision 1,
  superseded where the opening of §9 says so.
- The user's answers: `questions.md` *Answers* and its later sections.
- The Stage 1b reports: `analysis-1b-r1.md` and `analysis-1b-r2.md`. Every
  item in them is answered in *Changes since revision 1* at the end of this
  file.

This is not glab running inside Codex. Nothing is installed into Codex, no
Codex plugin manifest is written, and the script never writes `~/.codex`.

## Decisions

### The user's (binding; `questions.md`)

- U1 — Q1 = A: two changes. This plan covers the read-only Codex backend
  only; the developer role is a later plan (*Not in this plan*).
- U2 — Q2/Q3: Codex runs like a Claude subagent.
  - It runs on the host, in the user's repository, under Codex's own
    read-only sandbox, and Codex handles its own login.
  - The script never copies, reads, exports or redacts a token, and never
    writes `~/.codex`.
  - Accepted by the user: Codex's commands can read files outside the
    repository, and what Codex reads can reach OpenAI.
  - OpenCode's guarantees stay in force for OpenCode.
- U3 — Q4 = A, for the developer change: the manager reads the whole change
  before the gates, then runs Stages 3–5 as usual. It is recorded here and
  built in that change.
- U4 — Q5 = B: Codex's own default model.
  - When the user names none, no `--model` is passed.
  - The script reads back the model that ran, checks its form, and names it
    in the header line and the record line.
  - Accepted by the user: the model can change between rounds.
- U5 — Q6 = A: the effort is `CLAUDE_CODE_EFFORT_LEVEL` when it is set.
  Otherwise the manager asks the user once per session and records the
  answer with the model line. Mapping (i): send the highest level the model
  supports that is not above the requested one, and say so in the announce
  line.
  - Revision 5, review r1 T5, which the manager stated to the user: when
    `check` printed `models: unavailable`, send the session's level unchanged,
    and say `effort <sent> (no levels known)` in the announce line.
- U6 — Q7 = A: a one-time data note in `README.md` and in the skill.
- U7 — answer 3 of 2026-10-18: no "Use balance"-style check for Codex. Live
  runs happen only on the user's explicit instruction in chat.
- U8 — after Stage 1b round 2: fix the five blockers, then one narrow third
  check of those fixes. One offline `codex debug models --bundled` run is
  allowed, and it has run (`findings.md` §9.8).

### The planner's (Rule 3; evidence in `findings.md` §9)

- **D1 — Isolation is an adapter value.**
  - `<b>_isolation` prints `sandbox` (OpenCode) or `host` (Codex).
  - `cmd_start`, `cmd_send`, `run_turn`, `cmd_check` and `cleanup` branch on
    it, through the global `isolation` (D27).
  - It stays one script, with adapters as function sets (spec D4).
  - Rejected: a second script for host backends. It would duplicate the
    wrapper (ids, lock, list, stop, output contract, exit codes), which the
    user asked to keep shared.
- **D2 — OpenCode's behaviour does not change.**
  - Its OpenCode-specific lines outside the adapter section move into
    `opencode_*` functions with the same effect. E01–E49 are the proof.
  - Only the backend name that E28 uses as the unknown backend changes
    (D21).
  - The one addition that reaches OpenCode is D8's session check. It fails
    only on a path no OpenCode run has shown, and E66 pins it.
- **D3 — Codex runs in its human output mode, not `--json`.**
  - The JSONL stream never names the model (`findings.md` §9.2).
  - The human header block on stderr names the model, the sandbox, the
    approval policy, the effort and the session id, before the turn starts.
  - stdout carries the final agent message only.
- **D4 — What Codex is given, and what is turned off.** Every turn passes:
  - `--ignore-user-config` and `--ignore-rules`;
  - `web_search="disabled"`, `shell_environment_policy.inherit="core"` and
    `history.persistence="none"`;
  - telemetry off and the update check off;
  - `--disable` for `apps plugins remote_plugin browser_use browser_use_external
    computer_use in_app_browser image_generation hooks memories multi_agent
    skill_mcp_dependency_install`. Every name is in 0.163.0's `codex features
    list` (`findings.md` §9.7).

  Why:

  - MCP, apps, web search, plugins and hooks run outside Codex's command
    sandbox, or reach outside the repository.
  - The user's own config could turn any of them on, or turn the sandbox off.
  - `glab:reviewer`'s own tools are Read, Grep, Glob and Bash, with no web
    tool.

  The repository's `.codex/` layers stay off without any `-c` (D26). The
  process gets an environment allowlist (D13), not the manager's
  environment, which may hold Claude credentials.
- **D5 — The read-only check, on every Codex turn.**
  - The script reads Codex's header block: the first `OpenAI Codex
    v<digits>` line within the first 20 lines of stderr, then `--------`,
    the `key: value` lines, and `--------`, with ANSI SGR removed.
  - A block that exists but does not say exactly `sandbox: read-only` and
    `approval: never` makes the turn **exit 12 NOT READ-ONLY**, and the
    reply is withheld. `read-only` without a suffix also means the commands
    had no network (`sandbox_summary.rs`).
  - On a turn with no other fault, a block that is absent, or lacks a
    well-formed model or session id, is exit 7, on every turn, the first
    included.
- **D6 — The model.**
  - `--model` is optional for Codex. A given id must match
    `^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$`, or the start is exit 5. There is no
    allowlist and there are no end dates.
  - A turn's shown model is its block's model when that is well-formed, else
    the requested id, else `default`. The header line and the transcript
    heading name it.
  - `agent.json` `ran` keeps the last well-formed model, for `list`.
  - The record line names `codex` alone for the default and `codex:<id>` for
    a named model. The handoff line names `codex:<the model the header
    named>`.
- **D7 — Process lifetime on the host.**
  - The turn runs as `setpriv --pdeathsig KILL -- setsid timeout
    --kill-after=10 <t> setpriv --pdeathsig KILL -- <codex …>`, exec'd from
    the background subshell, as `:620` does.
  - The group id therefore equals the started pid (`findings.md` §9.7).
  - After every host turn the group gets TERM, then KILL, and then the
    agent's marker sweep (D31) runs, all before the script waits for its two
    output filters. `cleanup` does the same when `isolation` is `host`.
  - **Revision 4.** The group kill alone does not end a Codex turn. Codex's
    sandbox helper, and the command under it, run in a session and process
    group of their own. Both outlived D7's chain at Stage 4 (O2), and they
    outlive SIGTERM and SIGINT too (`findings.md` §9.9, C1). D31's sweep is
    what ends them.
  - The installed `timeout` is uutils coreutils 0.10.0, so its own group
    handling is not relied on.
  - `setsid --wait` is not used (D29).
- **D8 — The session.**
  - The id is the block's `session id:`, which must match
    `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`.
  - `send` passes only the recorded id, as `exec resume <id> -`.
  - A continued turn, on any backend, that reports another session is exit
    7, and the recorded session does not change. Codex silently starts a new
    thread for an id it does not find (`findings.md` §3.2). OpenCode's events
    carry the id it was given; E66 drives the mismatch.
- **D9 — Effort.**
  - `start --effort <low|medium|high|xhigh|max|ultra>` is for Codex only;
    for OpenCode it is exit 2.
  - It is stored and passed on every turn as
    `-c model_reasoning_effort="<level>"`.
  - The mapping (i) is the manager's, from the levels `check` lists. The
    script passes what it is given.
- **D10 — `check --backend codex`.** It prints:
  - `cli:` and `tools:`;
  - `login: stored`, from `codex login status`'s exit status, which is 0
    for every logged-in mode and 1 otherwise. Its stderr text is never
    printed (`findings.md` §9.8);
  - `sandbox: read-only starts`, from
    `codex sandbox -c 'sandbox_mode="read-only"' -- /bin/true`;
  - `default: <slug> (predicted)` and `models: <slug> (<levels>), …`, from
    `codex debug models`, read with the jq program in P2. That command
    refreshes the catalog with Codex's login; offline it falls back to the
    bundled catalog (`findings.md` §3.9, §9.8).

  On failure: not logged in is exit 4; a sandbox that does not start is exit
  12; a catalog that cannot be read prints `models: unavailable` and exits 0.
  These three commands take no `--ignore-user-config`, so they run under the
  user's config, and only the turns ignore it. The skill says so.
- **D11 — The Codex CLI path** is made absolute but not resolved, so the
  user's `current` link is followed across a Codex update. OpenCode keeps
  `readlink -f`, because its sandbox binds one file.
- **D12 — `stop` leaves Codex's own session** in Codex's history under
  `~/.codex`. The script removes only its own agent directory.
- **D13 — The environment of the Codex process.**
  - Passed only when set: `PATH`, `HOME`, `USER`, `LOGNAME`, `TMPDIR`,
    `CODEX_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`,
    `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`,
    `HTTPS_PROXY`, `HTTP_PROXY`, `NO_PROXY` and `ALL_PROXY` in both cases,
    `SSL_CERT_FILE` and `SSL_CERT_DIR`.
  - Always set: `LANG=C.UTF-8`, `TERM=dumb` and, since revision 4,
    `GLAB_EXTERNAL_AGENT=<marker>` (D31). `LC_ALL` is not passed.
  - The values are exported in the subshell, never put on a command line.
- **D14 — No redaction for Codex.** `secret` stays empty, and
  `redact_stream` only caps. The transcript holds whatever Codex printed;
  the skill and the README say so.
- **D15 — Transcript files.**
  - OpenCode keeps `transcript.jsonl` and `transcript.txt`.
  - Codex keeps `transcript.txt` (rendered) and `transcript.log`, which holds
    per turn `=== turn <n> stderr ===`, the stderr (header block included),
    `=== turn <n> stdout ===` and the stdout.
  - `<b>_raw_name` names the raw file, and `<b>_raw` writes it.
- **D16 — Codex uses the `default` profile only.**
- **D17 — A Codex reviewer can take a branch or a range target.**
  `/glab:ship` still reviews the working tree only.
- **D18 — withdrawn in revision 3.** Revision 2 refused a repository top
  holding `"`, `\` or a control character, because the top went into a `-c`
  TOML key. A `-c` key is split at every `.` and never TOML-parsed
  (`findings.md` §9.8), so that key never worked, and it is gone (D26). The
  top now goes only into the first message, through a quoted substitution
  (P3), and into `cd`.
- **D19 — No adapter is called on an unchecked backend name.**
  - The `--model is required` check stays at `:768`, as `[ -n "$model" ] ||
    model_optional "$backend" || die 2 USAGE "--model is required"`.
  - `model_optional` is a pure `case`, written next to `known_backend`.
  - OpenCode's checks keep their order and their messages, and every
    `${backend}_…` call comes after `known_backend`.
- **D20 — Measurements S1, O1 and O2 run at Stage 4.** The integrator runs
  them, with no model and a throwaway `CODEX_HOME`. A result other than the
  expected one is `PLAN WRONG` for the step it names.
- **D21 — Tests.**
  - A stub `codex`, and two new scenarios in the OpenCode stub.
  - New cases E50–E71; E28's unknown backend becomes `nosuch`.
  - The count goes from 49 to 71.
- **D22 — Version**: `0.5.0` → `0.6.0` in
  `plugins/glab/.claude-plugin/plugin.json`.
- **D23 — One commit** for the change, with the plan folder:
  `feat(agents): add Codex as a read-only external-agent backend`. Every *One
  fact* file in the table below changes in it.
- **D24 — The host first message** is the text in P3, verbatim. It is
  payload, and the user approves it with this plan.
- **D25 — The data note** is one paragraph, verbatim in P8, carried word for
  word by `README.md` and the skill.
  - Revision 5: P8 now gives the text review r1 built (S1, S3). It is in
    `README.md:70-81` and the skill's `:61-73`, and the two are identical.
  - The text carries the tighter socket clause the user approved (security
    review round 2, advisory A).
  - The working tree still has the older clause, "no network, neither IP
    nor Unix-domain sockets (measured offline with `codex sandbox`, not in a
    real turn)". That is a docs change still to build (*Revision 5: still to
    build*).
- **D32 — The Codex model-id wording (revision 5).** Since review r1 T4, the
  script refuses `default` (exit 5), so "checks only the id's form" is no
  longer the whole fact. The one wording, for every file that states it:
  - in `README.md`: "the script checks only the id's form, and refuses
    `default`, the word its output uses for Codex's own default";
  - in the `AGENTS.md` *One fact* entry: "checks an id's form only, and
    refuses `default`";
  - in the skill, next to its `default`-refused sentence: "the script checks
    only the id's form".

  S14 keeps its phrase. S42 searches for the new tail.
- **D26 — The repository's `.codex/` layers are off by default.**
  - Codex disables a project's config, hooks and exec policies unless a
    non-project config marks it trusted (`findings.md` §9.8).
  - Under `--ignore-user-config`, the user's trust entries are not read, so
    a project the user's `config.toml` marks trusted is still untrusted for
    an agent's turn.
  - O1 measures this against a known positive. A throwaway `config.toml`
    marks the repository trusted. Without the flag, `project-model-x`
    loads; through the script, which passes the flag, it does not.
- **D27 — Globals.** `isolation=''` and `turn_model=''` join the top-level
  initialisation line (`:912`), so `set -u` holds on every path.
  - `isolation` is set right after `known_backend` (start, check), or
    right after `agent_dir` (send).
  - `turn_model` is global, not local: `run_turn`'s tail sets it,
    `header()` and `finish_turn` read it, and it is reset to `''` at the
    start of each turn.
- **D28 — `head` and `branch` for a host agent** are recorded with
  `hostgit -C "$top" rev-parse -q --verify HEAD` (cut to 12 characters) and
  `hostgit -C "$top" symbolic-ref -q HEAD`. A repository with no commit
  records `""` for both, and the start goes on: Codex needs a git
  repository, not a commit.
- **D29 — `setsid --wait` is not used.** With `--wait`, setsid forks and
  waits, so the started pid would no longer be the group id that D7 kills.
- **D30 — The effort answer for a general Codex agent** (Rule 6, no Rule 5
  role) is recorded the same way: as `- effort: codex <level> (the user's
  answer: "<words>"), for the session` under `## Decisions` of the plan in
  progress. With no plan, it lives in this conversation only, as Rule 5 says
  for a review with no plan.
- **D31 — The agent marker, and the sweep (revision 4, `findings.md` §9.9).**
  - **Where the marker goes.** Every Codex turn carries
    `GLAB_EXTERNAL_AGENT=<agent id>` through two channels:
    - exported in the turn's environment (`codex_env`), which marks the
      outer chain;
    - passed as `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<agent
      id>"`, which is how Codex builds the environment of its sandbox helper
      and its commands.

    With both channels, all five processes of the measured tree carried the
    marker. An export alone stops at `bwrap` under `inherit="core"` (C2a).
  - **`sweep_agent <id>`.** It visits every process of this uid whose
    `/proc/<pid>/environ` holds the exact line `GLAB_EXTERNAL_AGENT=<id>`. It
    reads that process's start time, checks the line and the start time
    again, then sends `kill -KILL <pid>`. It repeats once after 1 s. This is
    kill by PID, with a guard against PID reuse.

    Killing the helper also ends every process in its PID namespace (C2c).
    So a command that unset the marker still ends with its helper.
  - **Where it runs:**
    - after every host turn (D7);
    - in `cleanup`;
    - in `cmd_stop`, always, once the turn's lock is taken and before the
      directory is moved aside. A script killed by SIGKILL runs no
      `cleanup`, and its leftovers end at `stop`. OpenCode agents carry no
      marker, so for them the sweep finds nothing.
  - **The agent id** is `ea-` and 16 random hex digits (`:778`), so no other
    agent's or user's process carries the same line.
  - **Rejected: SIGTERM or SIGINT to Codex first.** Codex does not tear down
    its helper on either signal (C1a–C1c).
  - **Rejected: a `systemd-run --user --scope` per turn.** It works on this
    host (C3), but it adds a dependency on a running systemd user manager
    and its D-Bus session, which containers, `ssh` sessions without
    lingering and non-systemd hosts lack. It would also still need a sweep at
    `stop` after a SIGKILL. Kept as the fallback if a live run shows that
    `codex exec` does not pass `set` to its helper.

## Before

1. `export TMPDIR=/data/tmp/claude`. The tree is `main` at `067b719`, or a
   descendant that has not touched the files below. `git status --short`
   shows only `?? plan/`.
2. Run both gate blocks of `AGENTS.md` *Gates* as written, with
   `CLAUDE_BIN` as the host file names it. They must be green, and
   `tests/external-agent.test.sh` must end `PASS 49/49`. A red gate stops the
   build.
3. The developer reads `AGENTS.md`, this plan, `findings.md` §9 and
   `questions.md`, and carries `glab:security` and `glab:comments`. Every
   existing comment and marker is kept, and a comment whose subject changes
   is updated in the same hunk.
4. Nobody runs a Codex model or `codex login`, and nobody reads, lists or
   writes anything under `~/.codex`. The test's Codex is the stub, and its
   `CODEX_HOME` is under `$W`.
5. **One-line rule.** Every phrase that *After* searches for is written on
   one line of its target file. When Markdown prose is wrapped, the wrap
   falls outside those phrases.

## Processing

One developer runs the steps in order.

### P1 — the script: OpenCode's lines into its adapter (no behaviour change)

File: `plugins/glab/scripts/external-agent.sh`.

- **The adapter-contract comment** (`:180-184`) lists the full set:
  - for every backend: `<b>_isolation`, `<b>_model_allowed`, `<b>_effort_ok`,
    `<b>_session_ok`, `<b>_raw_name`, `<b>_raw`, `<b>_ran`, `<b>_check`,
    `<b>_argv`, `<b>_env`, `<b>_session`, `<b>_text`, `<b>_error` and
    `<b>_render`;
  - for `sandbox` backends: `<b>_models`, `<b>_secret`, `<b>_secret_var`,
    `<b>_secret_hint` and `<b>_mounts`;
  - for `host` backends: `<b>_verify`.

  It ends: "A new backend is a new set plus one line in known_backend, one in
  model_optional if `--model` may be left out, and a stub in the test."
- **New OpenCode adapters.**
  - `opencode_isolation` prints `sandbox`.
  - `opencode_raw_name` prints `transcript.jsonl`.
  - `opencode_raw` prints `cat "$run/turn.out"`.
  - `opencode_ran` prints nothing.
  - `opencode_session_ok` holds the `^ses_[A-Za-z0-9]{1,64}$` test from
    `:828`.
  - `opencode_effort_ok` returns 1.
  - `opencode_secret_hint <cli>` prints the text now in `read_secret`'s
    message at `:334`: run \`<cli> auth login\` for OpenCode Go.
- **`opencode_mounts`** prints, NUL-separated, exactly these two binds from
  `:515-516`:

  ```
  --bind "$adir/data" "/home/worker/$DATA_IN_HOME"
  --ro-bind "$run/empty" /home/worker/.config/opencode
  ```

  `--bind "$run/home" /home/worker` stays in `sandbox_args`, in its place
  before them. `DATA_IN_HOME` (`:111`) and its comment move to just above
  `opencode_mounts`.
- **`opencode_model_allowed <model>`** holds `model_allowed`'s body
  (`:315-326`), with its arguments shifted by one:
  - the model is `$1`, not `$2`;
  - `"${1}_models"` becomes `opencode_models`, at both of its uses;
  - it sets `profile` as before.

  E29, E30 and E31 pin it.
- **The common functions change as follows.**
  - `model_allowed <backend> <model>` becomes `"${1}_model_allowed" "$2"`.
  - `sandbox_args` calls `"${backend}_mounts"` where the two binds were.
  - `read_secret`'s message ends with `$("${1}_secret_hint" "$2")`.
- **`opencode_check <cli>`** prints what `cmd_check` prints today after
  `cli:` (`:901-907`): the `net_tools` check, `tools:`, `read_secret`,
  `key: stored` and `models:`, in that order.
- **`$run/turn.jsonl` is renamed `$run/turn.out`** at `:598`, `:644`, `:649`,
  `:671`, `:680` and `:800`. `:644` becomes
  `"${backend}_raw" >>"$adir/$("${backend}_raw_name")"`.
- **`known_backend`** becomes `case $1 in codex|opencode) return 0 ;;`.
  `known_list` prints `codex, opencode`, and both "(known: …)" messages
  (`:773`, `:898`) use it.
- **Verify:** `bash -n`, shellcheck, and E01–E49 (E28 as changed in P4).

### P2 — the script: the Codex adapter set

All of these go in the adapter section, after the OpenCode set. Each one has
a comment that says why (`findings.md` §9.2, §9.8).

- **Fixed values.**
  - `codex_isolation` prints `host`.
  - `codex_raw_name` prints `transcript.log`.
  - `codex_raw` writes D15's per-turn layout.
  - `codex_effort_ok <level>` succeeds for `low medium high xhigh max ultra`.
  - `codex_session_ok <id>` checks D8's form.
  - Next to `known_backend`: `model_optional() { case $1 in codex) return
    0 ;; *) return 1 ;; esac; }`.
- **`codex_model_allowed <model>`.** An empty model passes. Otherwise it
  must have D6's form, or it runs `die 5 'MODEL REFUSED' "<the model, %q,
  cut to 80 characters> is not a Codex model id"`. It sets `profile=default`.
  - Revision 5, review r1 T4: `default` itself is refused first, with `die 5
    'MODEL REFUSED' "default is not a Codex model id; leave --model out for
    Codex's default"`. `default` is the word the header and `list` print,
    not an id; as `--model` it would be sent as `-m default`. E58 pins it.
- **`codex_argv <cli> <model or empty> <session or ->`** prints these,
  NUL-separated, in order:
  1. `<cli> exec --color never` on a first turn, or `<cli> exec resume` on a
     continued one.
  2. `--ignore-user-config --ignore-rules`.
  3. `-c sandbox_mode="read-only"` and `-c approval_policy="never"`.
  4. `-c web_search="disabled"`, `-c shell_environment_policy.inherit="core"`,
     `-c history.persistence="none"`, `-c analytics.enabled=false`,
     `-c feedback.enabled=false`, `-c otel.metrics_exporter="none"`,
     `-c check_for_update_on_startup=false` and
     `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<agent id>"`
     (D31; the key has no `.` in its last segment, so the `-c` split of
     `findings.md` §9.8 reaches it).
  5. D4's `--disable <feature>` list, in that order.
  6. `-m <model>`, only when a model is named.
  7. `-c model_reasoning_effort="<effort>"`, only when `agent.json` `effort`
     is set.
  8. On a continued turn, the session id.
  9. `-`.
- **`codex_env <marker>`** prints `NAME=value` lines for D13's names, each
  only when it is set, then `LANG=C.UTF-8`, `TERM=dumb` and
  `GLAB_EXTERNAL_AGENT=<marker>`. A turn passes the agent id as the marker,
  and `codex_check` passes its own (step 2 below).
- **`sweep_agent <marker>`** is a common function, beside `cleanup`, not an
  adapter. It is D31's sweep:
  - It visits each `/proc/[0-9]*` owned by this uid (`[ -O ]`).
  - It reads each environment with `environ_has </proc/pid> <entry>`. That
    helper reads `environ` with `mapfile -d '' -t`, so a process it cannot
    read is skipped silently, and it compares **whole NUL-separated
    entries**. A newline-split reading would match the marker inside another
    value (review r1 C-D, revision 5).
  - A process holding the exact entry `GLAB_EXTERNAL_AGENT=<marker>` has its
    start time (field 22 of `stat`) read. The entry and the start time are
    then checked again, and only then does it get `kill -KILL`.
  - It keeps a `hit` flag, and makes its second pass, after `sleep 1`, only
    when the first pass killed something (review r1 C3, revision 5).

  It prints nothing, and it never kills a process that lacks the entry.
- **Reading the header block.**
  - `codex_block` prints the `key: value` lines of D5's block from
    `$run/stderr.txt`, with SGR removed (`sed 's/\x1b\[[0-9;]*m//g'`), or
    prints nothing.
  - `codex_field <key>` prints the value of the first line whose key is
    exactly `<key>`.
  - `codex_ran` prints `codex_field model` when it has D6's form.
  - `codex_session` prints `codex_field 'session id'` when it passes
    `codex_session_ok`.
- **Reading the rest of the turn.**
  - `codex_text <stdout file>` prints the file.
  - `codex_error <stdout file>` prints nothing when `rc` is 0. Otherwise it
    prints the last line of stderr after the block that starts `ERROR: `,
    with SGR removed and the prefix dropped, cut to 300 characters and
    cleaned.
  - `codex_render <stdout file>` prints `codex: model=<…> sandbox=<…>
    approval=<…> effort=<…> session=<…>` from the block, then the stderr
    after the block, then `says:` and the stdout, all cleaned.
- **`codex_verify`.** When the block exists and `sandbox` is not exactly
  `read-only`, or `approval` is not exactly `never`, it prints the header
  and `end:`, then `die 12 'NOT READ-ONLY' "codex reported sandbox '<v>' and
  approval '<v>'; its reply is withheld"`, each value cut to 80 characters
  and cleaned.
- **`codex_check <cli>`** does the following, in order:
  1. It checks the tools `setpriv setsid timeout flock`, and dies 4 if one is
     missing: `"<tool> not found; see the README's Requirements"`. Then it
     prints `tools: setpriv setsid timeout flock`.
  2. It sets `authd=$root/check.$$`, so that `cleanup` removes it, and
     creates it empty. It sets the marker `cmark=check-<16 random hex>` and
     keeps it in a global, so that `cleanup` can sweep it too. Every Codex
     command below runs from there, under `codex_env "$cmark"`, with
     `timeout 60`, stdin `/dev/null` and stderr kept in a variable.
  3. It runs `"$1" login status`. A non-zero exit is `die 4 UNAVAILABLE
     "Codex is not logged in; log in with \`codex login\` yourself"`; zero
     prints `login: stored`.
  4. It runs `"$1" sandbox -c 'sandbox_mode="read-only"' -c
     "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$cmark\"" --
     /bin/true`, then `sweep_agent "$cmark"`. A non-zero exit is
     `die 12 'NOT READ-ONLY' "Codex's read-only sandbox does not start on this
     host: <the first stderr line that does not start \`WARNING:\`, cleaned,
     cut to 300>"`; zero prints `sandbox: read-only starts`.
  5. It runs `"$1" debug models` with stdout piped into exactly this
     program, for the shape recorded in `findings.md` §9.8:

     ```bash
     jq -r '[.models[] | select(.visibility == "list")] | sort_by(.priority)
       | if length == 0 then error("no listed model") else
         "default: \(.[0].slug) (predicted)",
         "models: " + (map(.slug + " (" + ([.supported_reasoning_levels[]?.effort] | join(" ")) + ")") | join(", "))
       end'
     ```

     If the command or the program fails, it prints `models: unavailable`.
     - Revision 5, review r1 S-4: the catalog comes from outside, so the jq
       program also keeps only slugs that match D6's id form and levels in
       `codex_effort_ok`'s set, and its output goes through `clean`.
     - The check's sandbox marker has been swept, and `cmark` is set to `''`
       (C3). `debug models` then runs with an empty marker,
       `codex_cmd "$authd" ''`, because it starts no sandbox helper.
  6. It removes `authd` and sets it to `''`.

  Revision 5, review r1 C-B: the Codex commands of steps 3–5 run through a
  top-level `codex_cmd <dir> <marker> <command…>`. It builds its environment
  from `codex_env "<marker>"` in its own subshell, and it is a helper of
  `codex_check`, not an adapter.

### P3 — the script: the host runner, the common flow, the first message

- **`cmd_start`.**
  - It takes `--effort <level>`. After `known_backend` it sets `isolation`,
    then: `[ -z "$effort" ] || "${backend}_effort_ok" "$effort" || die 2 USAGE
    "--effort is not taken by the $backend backend, or $effort is not a
    level"`.
  - `:768` becomes D19's line.
  - For `host`:
    - there is no `net_tools`, `read_secret`, `copy_repo` or `chmod`, and no
      `work/` or `data/`;
    - `head` and `branch` are recorded as D28 says;
    - the `cli` is made absolute without resolving symlinks, then passed
      through `cli_ok`.
  - `agent.json` gains `effort` and `ran`, both `""`.
  - For `sandbox`, everything is unchanged.
- **`cmd_send`.** The session check becomes `"${backend}_session_ok"
  "$session"`. `net_tools` and `read_secret` run for `sandbox` only.
  - Revision 5, review r1 C-A: `isolation` is set **after `lock_agent`**, so
    a concurrent `stop` keeps the one-line stderr contract.
  - Revision 5, review r1 C1: for `host`, `sweep_agent "$id"` runs after
    `lock_agent` and before `rm -rf "$run"`. That ends a SIGKILLed earlier
    turn's leftovers, so their filters cannot write into the new `run/`.
- **`run_turn`**, split into three parts:
  - **The common start**: `:584-586`, `turn=` (`:594`) and `turn_model=''`.
  - **`run_sandboxed`** holds the sandbox lines unchanged: `:587-593` and
    `:595-643`.
  - **`run_host <session or ->`** does the following:
    1. It checks that `hostgit -C "$repo" rev-parse --show-toplevel` still
       prints `agent.json` `repo`. Otherwise it is `die 4 UNAVAILABLE "<repo>
       is no longer the repository the agent started in"`.
    2. `mapfile -d '' argv < <("${backend}_argv" "$cli" "$model" "$1")`,
       with the real `$cli`.
    3. `mapfile -t benv < <("${backend}_env" "$(meta id)")`.
    4. It starts the two stream filters, as at `:598-599`.
    5. It starts a background subshell. The subshell closes every descriptor
       but the two streams (the loop of `:611-614`), unsets the environment,
       exports `benv`, `cd`s to `repo`, and runs `exec` on D7's chain, with
       stdin `$run/message.md`.
    6. `sandbox_pid=$! turn_start=$SECONDS`; it closes the streams, then
       `wait "$sandbox_pid"; rc=$?`.
    7. It sends `kill -TERM -- -"$sandbox_pid"`, polls up to 2 s, then sends
       `kill -KILL -- -"$sandbox_pid"` and sets `sandbox_pid=''`.
    8. `sweep_agent "$(meta id)"` (D31). This ends Codex's sandbox helper and
       its commands, which the group kill does not reach.
    9. Only then does it run `wait "$jpid" "$epid"`: a helper still holding
       a pipe would otherwise block it.
  - **The common tail**, from `:644`:
    - the raw transcript;
    - `turn_model=$("${backend}_ran")`, with `set_meta '.ran = $r'` when it
      is not empty;
    - the heading `## turn <n> · <backend>:${turn_model:-${model:-default}} ·
      <time>`;
    - the rest, unchanged.
- **`cleanup`.** When `isolation` is `host` and `sandbox_pid` is set, it does
  the group TERM and KILL of `run_host` step 7, in place of `:137`, and then
  `sweep_agent` for the agent id when `adir` names an agent. When `cmark` is
  set, it also runs `sweep_agent "$cmark"`.
  - Revision 5, review r1 C2:
    - `cleanup`'s first line is `trap '' HUP INT TERM`, so a second signal
      during the 1–3 s host cleanup cannot cut it short.
    - A `host_turn` flag holds the agent id from the start of `run_host`
      until its post-turn `sweep_agent` returns, and `cleanup` sweeps
      whenever it is set. This replaces the `adir`-based sweep above, so a
      signal that arrives during the post-turn sweep still gets one.
  - Revision 5, review r1 C1: the cap flags are named `capped.$$.stdout`
    and `capped.$$.stderr` in `run_sandboxed`, `run_host` and
    `finish_turn`. An old turn's filter therefore cannot set this turn's
    flag.
- **`cmd_stop`.** After the lock is taken (`:868-874`) and before `mv -T`
  (`:882`), it runs `sweep_agent "$1"`. `$1` is the agent id it was given,
  already checked against `^ea-[0-9a-f]{16}$` at `:864`.
  - Revision 5, review r1 C3: it skips the sweep only when `agent.json`
    names a backend that `known_backend` accepts and whose isolation is
    `sandbox`. It sweeps for a host backend, a missing `agent.json`, and one
    that names no known backend, because such an agent cannot be shown to be
    an OpenCode one. This departs from the reviewer's "host or missing" on
    purpose, and is the safer reading.
  - This ends what a host turn left behind when the script itself was
    SIGKILLed, and so ran no `cleanup`.
  - For OpenCode it finds nothing: no OpenCode process carries the marker,
    and the bwrap sandbox ends with `--die-with-parent`.
  - `stop`'s output and exit codes do not change.
- **`finish_turn`**, in this order:
  1. The caps.
  2. The timeout.
  3. For `host`, `"${backend}_verify"` (12).
  4. The signal and error checks.
  5. For `host`: if `turn_model` or `"${backend}_session"` is empty, the
     header, `end:`, and `die 7 'BACKEND ERROR' "codex printed no header
     block naming its model and session"`.
  6. For `turn > 1`: if the reported session is not the recorded one, the
     header, `end:`, and `die 7 'BACKEND ERROR' "<backend> continued another
     session (<id, or none>) instead of <recorded>"`.
  7. The reviewer check and the reply.
- **`header()`** prints `model: <backend>:${turn_model:-${model:-default}}`.
  Revision 5, review r1 C-B: it is a top-level function, `header <agent id>
  <backend> <model asked for, or empty>`, called with those arguments by
  every `finish_turn` path, by the reply, and by `codex_verify <agent id>
  <model>`. It no longer relies on a nested definition or on a
  dynamic-scope `id`.
- **Comments cite tags, not plan ids** (review r1 T-7): for example
  `[feature-codex-agent/plan.md D31]` and
  `[feature-codex-agent/findings.md §9.9]`. A bare "(D31)" would dangle once
  the plan folder is removed.
- **`cmd_list`**: the model column is `.backend:` followed by `.ran`, else
  `.model`, else `default`.
- **`cmd_check`**: `need_tmpdir`, `known_backend`, `isolation`, the CLI
  (resolved for `sandbox`, absolute for `host`), `echo "cli: $cli"`, then
  `"${backend}_check" "$cli"`.
- **`first_prompt`.** For `sandbox` it prints the heredoc of `:463-478`,
  unchanged. For `host` it prints the text below.
  - The script holds the text in a quoted heredoc (`<<'EOF'`), with the
    `<top>` placeholders written as `@TOP@`.
  - Each line is printed as `printf '%s\n' "${line//@TOP@/"$top"}"`. The
    replacement is quoted, because bash 5.3 replaces an unquoted `&` in a
    path (`findings.md` §9.8).
  - The heredoc lines carry no indent: they are the lines below with the
    two-space Markdown indent removed.

  <!-- host-first-message: begin -->

  ```text

  # Where you are working

  - You are working in the repository at <top> itself: the user's real
    working tree, its history and its ignored files, not a copy. Codex runs
    you in its read-only sandbox: you can read files and run commands, and
    you cannot change any file. You are not asked to.
  - Your commands can also read files outside the repository. Read nothing
    outside <top> unless your task names it: what you read is sent to the
    model's provider.
  - Your commands have no network. You have no web tool: do not try to fetch
    pages.
  - Read <top>/AGENTS.md before anything else: it is the repository's
    working agreement. If there is none, read <top>/CLAUDE.md and say in
    your answer that the repository has no working agreement.

  ```

  <!-- host-first-message: end -->

  The last bullet is the sandbox text's missing-`AGENTS.md` bullet, with
  `/work` replaced by `<top>`.
- **The header comment (`:1-69`)** is rewritten, and every existing reason is
  kept:
  - lines 2–5 name the two backends and where each works;
  - the usage: `--model` is optional for codex; `--effort <level>` is added
    (codex);
  - stdout: for codex, the `model:` field is the model that ran;
  - stderr: `:22` "on every exit 2-11" becomes "on every exit 2-12";
  - the exit list adds `12 NOT READ-ONLY` on the line that holds `11 BUSY`;
  - the state: Codex agents have no `work/` or `data/`, and keep
    `transcript.log`; their session stays in Codex's history;
  - *Isolation*: the existing list goes under "OpenCode", word for word, and a
    "Codex" list follows, stating `findings.md` §9.3's Codex column, D4, D5,
    D7, D13, D26 and D31 (the marker, the sweep, and why the group kill is
    not enough: `findings.md` §9.9).
- **Verify:** `bash -n`, shellcheck, and P4's cases.

### P4 — `tests/external-agent.test.sh`: the stub `codex` and E50–E71

**The harness.**

- The header comment names the second stub, and says that it runs on the
  host, as the script runs Codex.
- `CXH=$W/codex-home` is defined before `trap cleanup EXIT`.
- `cleanup()` begins, before the `KEEP_W` return, with: for each pid in
  `${CXH:-}/pids`, kill it only if `/proc/<pid>/environ` holds
  `TMPDIR=$W/tmp`. The kill goes by PID, and the environment check guards
  against a reused PID.
- `CLI_CX=$W/bin/codex-stub`, plus `ln -s codex-stub "$W/bin/codex-link"`.
- The OpenCode stub gets two scenarios:
  - `othersess`: on a `--session X` turn, it prints events with session id
    `ses_other`.
  - `fds` stays as it is.
- E40's fd-marker setup is reused by E68.

**The stub, `$W/bin/codex-stub`.** It is bash. For every call, it appends to
`$CXH/calls.log` the argv, `cwd=$PWD`, the environment names except `PWD`,
`SHLVL` and `_`, and the first non-blank line of stdin. By argv:

- **`login status`**: if `$CXH/logged-in` exists, it writes `Logged in using
  ChatGPT` to stderr and exits 0. Otherwise it writes `Not logged in` and
  exits 1 (`findings.md` §9.8).
- **`sandbox …`**: if `$CXH/sandbox-broken` exists, it writes a `WARNING:
  stub` line and then `bwrap: setting up uid map: Permission denied` to
  stderr, and exits 1. Otherwise it exits 0.
- **`debug models`**: if `$CXH/models-broken` exists, it exits 1. Otherwise
  it prints this, in the recorded shape (unsorted on purpose):

  ```json
  {"models":[
   {"slug":"stub-b","visibility":"list","priority":2,"supported_reasoning_levels":[{"effort":"low","description":"d"},{"effort":"medium","description":"d"},{"effort":"high","description":"d"}]},
   {"slug":"stub-a","visibility":"list","priority":1,"supported_reasoning_levels":[{"effort":"low","description":"d"},{"effort":"medium","description":"d"},{"effort":"high","description":"d"},{"effort":"xhigh","description":"d"},{"effort":"max","description":"d"}]},
   {"slug":"stub-h","visibility":"hide","priority":0,"supported_reasoning_levels":[{"effort":"low","description":"d"}]}]}
  ```

- **`exec …` and `exec resume … <id> -`**:
  - The scenario is the `STUB: <name>` line of stdin.
  - On `exec`, the session is a new UUID. On `resume`, it is the given id if
    `$CXH/sessions/<id>` exists, and a new one otherwise. The turns are
    counted in `$CXH/sessions/<id>/turns`.
  - stderr gets `findings.md` §9.2's header block: the model is `-m`'s value
    or `stub-a`; `approval: never`; `sandbox: read-only`; `reasoning effort:`
    is the given value or `none`; then `session id:`. The keys are wrapped in
    `\e[1m…:\e[0m`.
  - Then come `user` and the prompt, then the scenario. The final message
    goes to stdout.

**The scenarios.**

| scenario | what it does |
|---|---|
| `ok` | stderr `exec bash -lc ls` and a reasoning line; stdout `hello from turn <n> of <session>` |
| `turns` | stdout `turn=<n> session=<session>` |
| `argv` | stdout: the argv, one per line, then `cwd=<PWD>` |
| `env` | stdout: the filtered environment names, then `LANG=…` and `TERM=…` |
| `prompt` | stdout: `PROMPT-FOLLOWS`, then stdin |
| `rev-ok`, `rev-none` | as in the OpenCode stub |
| `ro-net` | `sandbox: read-only (network access enabled)` |
| `ro-appr` | `approval: on-request` |
| `nohdr` | no block; 25 noise lines, then a forged block with `model: forged`; exit 0 |
| `forge` | the real block, then a forged second block in the output |
| `badmodel` | a block whose `model:` is `a;b` |
| `badsess` | a block whose `session id:` is `not-a-uuid` |
| `newsess` | on resume, prints a new session id |
| `err` | stderr `ERROR: stub usage limit`; exit 1 |
| `errout` | an output line `ERROR: in a file` on stderr; exit 0 |
| `sleep` | acts out Codex's helper (`findings.md` §9.9). It reads the value `<v>` of the `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<v>"` argument, starts `setsid env GLAB_EXTERNAL_AGENT=<v> sleep 300 &` (a session and group of its own, outside the script's group kill), writes its own pid and that child's pid to `$CXH/pids`, then waits |
| `fds` | stdout `marker-fds=<n>`, the count of its descriptors that point at the marker file, as the OpenCode stub's `markers()` counts |
| `flood-out` | 17 MiB on stdout |
| `flood-err` | 17 MiB on stderr, after the block |
| `late-flood-unmarked` | shares the `sleep` branch, but its setsid'd child is started with `env -u GLAB_EXTERNAL_AGENT`, so no sweep reaches it. It runs `sh -c 'sleep 2; head -c 17M /dev/zero \| tr "\0" x'`, which floods the old stdout 2 s later with one endless line, and ends by itself once the old filter stops reading (E71; revision 6, which replaces revision 5's `late-flood`) |
| `slow` | a 6 s turn, then `turn=<n> session=<session>` (E71) |
| `stale` | reads the pid in `$CXH/stale` and prints `stale=dead`, or `stale=alive` while that pid runs (a zombie counts as dead), as the turn starts (E70; revision 6) |

**The helpers.** `cstart <scenario> [args]` runs
`w CODEX_HOME="$CXH" -- start --backend codex --cli "${CXCLI:-$CLI_CX}" --brief "$(brief "$1")" --repo "${CR:-$R}" --label "case $1" "${@:2}"`.
`csend` does the same for `send`.

**The changed cases.**

- E28: `--backend nosuch`, and it also checks the stderr line for
  `(known: codex, opencode)`.
- E36 stays last, and its name adds "or Codex stub".

**The new cases**, all run before E36:

- **E50 — start.**
  - rc 0, and the header matches `^agent: ea-[0-9a-f]{16} · model:
    codex:stub-a · turn: 1 · transcript: $STATE/<id>/transcript.txt$`; then
    `reply:`, `hello from turn 1 of <uuid>` and `end: <id>`.
  - The agent directory has no `work/` and no `data/`.
  - `calls.log`'s first non-blank stdin line is `You are an external agent
    in the glab workflow. A manager has started you to`.
  - `transcript.log` holds `=== turn 1 stderr ===`, a line ending in
    `sandbox:\e[0m read-only`, and `hello from turn 1`.
  - `transcript.txt` holds a line that starts `## turn 1 · codex:stub-a · `,
    the line `codex: model=stub-a sandbox=read-only approval=never
    effort=none session=<uuid>`, and `says:` followed by the reply.
- **E51 — argv.**
  - It runs with `CXCLI=$W/bin/codex-link`.
  - The argv is exactly P2's list for `exec`, with no `-m` and no effort.
  - `agent.json` `.cli` is the link's own path.
  - With `--model stub-b --effort high`, it holds `-m stub-b` and
    `-c model_reasoning_effort="high"`, and the header names `codex:stub-b`.
  - The stub's `cwd=` is the repository top.
- **E52 — send.** rc 0, turn 2 of the same session, `exec resume` with P2's
  list plus the id and `-`, and the model and effort carried over.
- **E53 — `newsess`.** rc 7 `continued another session`. `agent.json`
  `session` is unchanged, and `list` still shows the agent.
- **E54 — `ro-net` and `ro-appr`.** rc 12 `NOT READ-ONLY`, no `reply:` line,
  the header and `end:` printed, and the agent stays.
- **E55 — `nohdr` and `forge`.**
  - `nohdr`: rc 7 `printed no header block`. The header names
    `codex:default`, the `transcript.txt` heading names `codex:default`, and
    `list` shows `codex:default`.
  - `nohdr` with `--model stub-b`: the header names `codex:stub-b`, and
    `list` shows `codex:stub-b` (the `.model` fallback).
  - `forge`: rc 0, and the header names `codex:stub-a`.
- **E56 — environment.** It starts with `HTTPS_PROXY=x USER=t` set, so that
  it tests the pass-through side of the allowlist (review r1 T-8, revision
  5). The `env` scenario's names are exactly `CODEX_HOME GLAB_EXTERNAL_AGENT
  HOME HTTPS_PROXY LANG PATH TERM TMPDIR USER`, with `LANG=C.UTF-8`,
  `TERM=dumb` and `GLAB_EXTERNAL_AGENT=<the agent id>`. No `CALLER_TOKEN`,
  `GIT_DIR`, `TAR_OPTIONS` or `OPENCODE_*` name appears.
- **E57 — errors.** `err`: rc 7 with `stub usage limit`. `errout`: rc 0.
- **E58 — refusals, before anything is created.**
  - `--model 'a;b'` → 5.
  - `--model default` → 5, `default is not a Codex model id` (review r1 T4,
    revision 5).
  - `--effort turbo` → 2.
  - `--backend opencode --effort high` → 2.
  - `--backend opencode` without `--model` → 2 `--model is required`.
  - `--backend nosuch` without `--model` → 2 `--model is required`.
- **E59 — check.**
  - With `logged-in`: rc 0, `cli:`, `tools: setpriv setsid timeout flock`,
    `login: stored`, `sandbox: read-only starts`, `default: stub-a
    (predicted)`, and `models: stub-a (low medium high xhigh max), stub-b
    (low medium high)`. There is no `stub-h`, and `Logged in using` appears
    nowhere in the output.
  - Without `logged-in`: rc 4.
  - With `sandbox-broken`: rc 12, and the line holds `bwrap: setting up uid
    map`, not `WARNING:`.
  - With `models-broken`: rc 0 and `models: unavailable`.
  - After each, no `check.*` directory is left.
  - Revision 5, review r1 S-4: the stub's catalog also holds a listed slug
    `bad;\u001b[31mslug` with the highest priority, and a level
    `turbo\u001b[0m` on `stub-b`. The expected output above does not change,
    so the filters and `clean` are what keep the case green.
- **E60 — `sleep`.**
  - A send during the turn is 11.
  - `stop` gives 143 and `stopped: <id>`.
  - Both pids are gone, checked by pid. The child is in its own session, so
    only the sweep (D31) reaches it: without `sweep_agent` this case fails.
  - With `--timeout 2`: rc 6, and both pids are gone.
  - `argv` holds `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<id>"`.
- **E61 — the first message.** The `prompt` output holds the default
  profile's two sections, and each line of P3's host text with `<top>`
  replaced by the repository top, in order. It also holds both skills. It
  holds neither `/work is a read-only copy` nor any family profile's text.
- **E62 — reviewer.**
  - `rev-ok` → rc 0, and the report block alone.
  - `rev-none` → rc 8; then a `csend` of a `rev-ok` correction → rc 0.
- **E63 — list and stop.**
  - `list` shows `<id>  idle  codex:stub-a  role=general  turns=1`, and
    `repo=$R@<12 hex>` (D28).
  - `stop` removes the agent and leaves `$CXH/sessions/` unchanged.
- **E64 — caps.** `flood-out` → rc 7 `on its stdout`; `flood-err` → rc 7 `on
  its stderr`.
- **E65 — a malformed header block.** `badmodel` and `badsess` → rc 7
  `printed no header block naming its model and session`.
- **E66 — OpenCode, D8.** `send` with `othersess` → rc 7 `continued another
  session (ses_other)`, and `session` is unchanged.
- **E67 — the repository moved.** `CR=$W/repo4`; start; `mv` it; `csend` →
  rc 4 `is no longer the repository`; `stop` → `stopped:`.
- **E68 — descriptors.** The test holds the marker file open, as E40 does.
  The `fds` scenario prints `marker-fds=0`, while the test's own count is
  `1` or more (the known positive).
- **E69 — the script SIGKILLed mid-turn, then `stop` (D31).**
  1. The test starts a decoy, `env GLAB_EXTERNAL_AGENT=ea-0000000000000000
     sleep 300 &`, with its own pid recorded.
  2. It starts `cstart sleep` in the background and waits for `$CXH/pids`.
  3. It sends `kill -KILL` to the script's own pid.
  4. Known positive: 2 s later, the stub's setsid'd child is still alive.
     That is the Stage 4 defect.
  5. `w -- stop <id>` → `stopped: <id>`, and both stub pids are gone.
  6. The decoy is still alive, so the sweep matched only the exact line. The
     test then kills the decoy by its pid.
  7. Revision 5, review r1 C-D: a second decoy's environment holds this
     agent's marker only inside another value, after a newline. It must
     survive the sweep, and the test kills it by its pid. Both decoys sit in
     `LISTENERS` while they run.
- **E70 — the sweep before every `send`** (review r1 C1, its first half;
  revision 6 records the build, which review r2's R2-1 split out of revision
  5's single E70).
  1. A `send` of `sleep` runs in the background, its stand-in's pid is read
     from `$CXH/pids`, and its script is SIGKILLed.
  2. Known positive: the stand-in outlived its script.
  3. The stand-in's pid goes to `$CXH/stale`.
  4. A `csend` of `stale` follows.

  It asserts rc 0, `stale=dead` and turn 2. Every other sweep runs after a
  turn or at `stop`, so only the sweep before the send can have ended the
  stand-in by the time the new turn starts. The no-sweep mutant fails this
  case.
- **E71 — the PID-named cap flags** (review r1 C1, its second half; revision
  6).
  1. A `send` of `late-flood-unmarked` runs in the background, and its
     script is SIGKILLed.
  2. Known positive: the stand-in is alive and has no `GLAB_EXTERNAL_AGENT`
     entry. The new test helper `environ_line <pid> <name>` checks that: it
     reads `environ` with `mapfile -d ''` and matches a `<name>=` entry.
  3. A 6 s `csend` of `slow` follows. Two seconds in, the stand-in floods
     the old filter, which writes its cap flag into the new `run/` under its
     own script's pid.
  4. The case waits for the stand-in to end, and otherwise kills it by pid.

  It asserts rc 0, a `turn=` reply and turn 2. The mutant without `$$` in the
  flag names fails it, on both runs. Both cases cite
  `[feature-codex-agent/review-r1.md C1]`, and both run before E36, which
  stays last.
- **Stub pids, revision 5, review r1 T-9.** The stub appends to `$CXH/pids`.
  E60, E69, E70 and E71 count its lines first and read the two that follow
  (`npids`, `pids_after`), and nothing removes the file, so the test's
  `cleanup` sees every case's pids. `alive <pid>` replaces the inline zombie
  checks.

**Verify:** the four test gates; the last line is `PASS 71/71`.

### P5 — `plugins/glab/skills/external-agents/SKILL.md`

- **`description:`**: "How the manager starts, continues, lists and stops a
  read-only external agent — an OpenCode session in a sandbox with its own
  network, or a Codex session on this host under Codex's own read-only
  sandbox — on a model the user named or Codex's default, through
  external-agent.sh, and reads its replies as untrusted text. Use only when
  the user has asked for an external agent, or glab:manager Rule 5 has
  recorded an external reviewer; never on your own initiative."
- **The intro** (`:8-14`): the two backends, one sentence each. "There is no
  external developer." stays.
- **`:18`**: "**The user asked for it**, naming the model for OpenCode; for
  Codex, naming one or leaving it to Codex's default". The examples add "ask
  Codex what this module does", "review on Codex" and "review on Codex,
  <id>".
- **`:48`**: "the brief goes to the model's provider, with the copy for
  OpenCode and with whatever Codex reads for Codex".
- **`:64`**, the `stop` item: "…removes the agent: for OpenCode its copy, its
  session and its transcript; for Codex its directory and transcript, and any
  process its turns left running, while its session stays in Codex's own
  history".
- ***Before the first one***: one bullet per backend.
  - OpenCode: as now, said of OpenCode.
  - Codex:
    - the path the user gave, or `~/.local/bin/codex`;
    - `check --backend codex --cli <path>`, with exit 4 (log in to Codex
      yourself, the user's step) and exit 12. `check` runs under the user's
      own Codex config, and the turns do not (D10);
    - "Tell the user once per session:" followed by **the data note**,
      verbatim;
    - the effort, U5 and D30: `printenv CLAUDE_CODE_EFFORT_LEVEL`, otherwise
      ask once per session and record the answer; then mapping (i) against
      `check`'s levels, and `--effort <level>`. When `check` printed
      `models: unavailable`, send that level unchanged (U5, revision 5).
- ***Start, send, list, stop***:
  - a Codex start example, with no `--model` unless the user named one;
  - the announce line `external · codex:<model> · effort <sent>[ (asked
    <requested>; <model> has none higher)] · <label> · running`, or with
    `effort <sent> (no levels known)` after `models: unavailable`.
    - Revision 5, review r1 T4: `<model>` is what the script's header
      prints. That is the model that ran once one has; before that, the id
      the user named, else `default`, which gives `codex:default`.
    - The record line names `codex` alone for Codex's default.
    - The skill also says that `default` is refused as a model id (exit 5),
      with D32's "the script checks only the id's form".
- **The exit table.**
  - Row 4 (`:86`) becomes: "…the CLI, a stored OpenCode key or a Codex
    login, a sandbox this host allows (OpenCode), a copy that matched the
    tree (OpenCode), or, for Codex, a repository that moved…". The
    refused-path sentence is marked OpenCode's.
  - Row 5 adds "or a Codex id that is not one".
  - Row 7 adds "a turn that continued another session, or a Codex turn that
    printed no header block".
  - Row 9 becomes "(OpenCode only)".
  - A new row:

    ```text
    | 12 | NOT READ-ONLY | Stop. Codex did not run read-only without network, or ran with an approval policy other than `never`, or its sandbox cannot start here; the reply is withheld. Tell the user the line. |
    ```

- **The transcript paragraph** says that a Codex transcript is not redacted.
- ***The reviewer role***: the branch-or-range sentence is said of OpenCode;
  a Codex reviewer can take one.
- ***What the script guarantees***: **OpenCode** (the existing bullets, word
  for word), then **Codex** (§9.3's column), with revision 5's review r1
  wording:
  - **What it cannot do**: its commands change no file, while Codex itself
    keeps the session under `~/.codex`, with everything the model read, its
    logs and a token refresh, as it does for the user.
  - **Its network**: the approved socket clause of D25, "no IP network, and
    a connect to a Unix-domain socket by path was refused (measured offline
    with `codex sandbox`); datagram and abstract sockets not measured". Codex
    itself reaches OpenAI.
  - **Its tools** (S2, T2): the script header's list — web search, apps,
    plugins, hooks, memories, the browser and computer tools, image
    generation and multi-agent. MCP is not turned off by a flag. A turn has
    no MCP server only because it ignores the user's `config.toml`. A
    managed or system config is not ignored, and the script checks only the
    sandbox and approval policy that the header reports.
- **Verify:** *After* §2, lines S1–S6 and S40–S42.

### P6 — `plugins/glab/skills/manager/SKILL.md`

- **`:120`**: "…a backend and a model, such as "review on OpenCode,
  opencode-go/<id>", or Codex alone — "review on Codex" — which runs Codex's
  own default model…". Revision 5, review r1 T6: it adds "with no
  `--model`", so that Rule 5 states the Codex `--model` fact its *One fact*
  entry lists it for.
- **`:123`**: "…or whether they meant an external reviewer —
  `opencode:opencode-go/<id>`, `codex`, or `codex:<id>`". The stop list adds
  "or reports that it did not run read-only (12)".
- **`:127`**: after the OpenCode line, the Codex record line, on one line:

  ```text
  - model: glab:reviewer codex, effort <level> (CLAUDE_CODE_EFFORT_LEVEL | the user's answer: "<words>"), for the session — the user's instruction, not a manager choice: "<the user's words>"
  ```

  With `codex:<id>` in place of `codex` when the user named a model.
- **`:128`**: "…and names the model the script's header named, which for
  Codex is the model that ran" and, since revision 5 (review r1 T4),
  "(`codex:default` when none has run)".
- **`:139`**: "the script frames it with the profile its backend gives it
  (its allowlist line for OpenCode, `default` for Codex)…".
- **`:149`**: "An external agent — an OpenCode or a Codex session the user
  asks for, run by `glab:external-agents` —".
- **`:151`**: "**Only when the user asks**, naming the model for OpenCode —
  for Codex, naming one or leaving it to Codex's default — and for the work
  they name."
- **`:154`**: "**It changes nothing.** An OpenCode agent works on a read-only
  copy in the script's sandbox; a Codex agent works in the repository itself
  under Codex's own read-only sandbox, and its commands can read any file you
  can, outside the repository too. A reply that proposes a change is input
  for the pipeline, which builds it through `glab:developer` like any
  other."
- **A new bullet after `:154`**: "**Codex's effort** is the session's:
  `CLAUDE_CODE_EFFORT_LEVEL` when set, otherwise ask the user once per session
  and record the answer — in the model line for the reviewer (Rule 5), and
  as `- effort: codex <level> (the user's answer: "<words>"), for the session`
  for any other Codex agent. Send the highest level the model supports that is
  not above it, and say so in the announce line." Revision 5 (U5, review r1
  T5) adds: "When `check` printed `models: unavailable`, send the level
  unchanged and say that no levels were known."
- **Verify:** *After* §2, lines S7–S10.

### P7 — `plugins/glab/commands/review.md:8`

Its last two sentences become: "If I named an external reviewer instead — a
backend, and for OpenCode a model — run it through the `glab:external-agents`
skill, with the same target. An OpenCode reviewer's copy holds only `HEAD`
and the working tree, so a branch or a range cannot be its target: tell me
that instead of starting one; a Codex reviewer works in the repository and
can take one."

**Verify:** *After* §2, line S11.

### P8 — `README.md`

**`:9`**, in the `glab` row: "…that runs read-only external agents on a model
you name (OpenCode Go)" becomes "…that runs read-only external agents —
OpenCode Go in a sandbox of its own, or Codex in its own read-only sandbox —
on a model you name, or Codex's default".

**`:34-43`** become these two paragraphs. Each searched phrase stays on one
line:

> External agents in `glab` (`glab:external-agents`) run only when you ask the
> manager for one, naming the model — or, for Codex, leaving it to Codex's default.
> An OpenCode agent also needs: bubblewrap (`bwrap`) able to create namespaces
> on your host, `slirp4netns` for the sandbox's own network, util-linux
> (`nsenter`, `setpriv`, `lsns`, `flock`), iproute2 (`ip`), `git`, `jq`, GNU
> `tar` and `timeout`, and OpenCode's native binary (the installer puts it at
> `~/.opencode/bin/opencode`; a launcher script does not run in the sandbox)
> with an OpenCode Go key stored by `opencode auth login`. On Debian or Ubuntu:
> `sudo apt install bubblewrap slirp4netns`. Without a working `slirp4netns` the
> script refuses to start an OpenCode agent (exit 9). Keep the OpenCode
> console's "Use balance" switch off, or a Go limit spends paid balance.
>
> A Codex agent needs the Codex CLI, logged in by you (`~/.local/bin/codex`,
> or the path you give the manager), bubblewrap able to create user
> namespaces for Codex's own sandbox, util-linux (`setpriv`, `setsid`,
> `flock`), `timeout`, `git` and `jq`; it needs no `slirp4netns` and no key.
> Codex runs any model id you name, or Codex's own default when you name none —
> the script checks only the id's form, and refuses `default`, the word its output uses for Codex's own default.
> If Codex's read-only sandbox cannot start on your host, or a turn reports
> any other sandbox or an approval policy other than `never`, the script stops
> with exit 12 (NOT READ-ONLY).

Revision 5 (review r1, T1, T3, T4). The model-id sentence sits in the Codex
paragraph, the exit-12 sentence names the approval policy, and the `default`
clause is D32's wording.

***What an external agent can send*** (`:56-68`):

- The paragraph stays, said of "An OpenCode agent". Its allowlist sentence
  begins "For OpenCode, the script runs only Kimi…" (`README.md:60`). The
  revision-4 lead-in "OpenCode runs only the models named below;" is dropped,
  because the "For OpenCode" sentence says the same.
- Then **the data note** (D25), verbatim in `README.md` and in the skill.
  This is revision 5's text, with the approved socket clause:

  > A Codex agent runs on this machine, in your repository, under Codex's
  > own read-only sandbox, with your own Codex login, which the script never
  > reads. What it reads goes to OpenAI under your ChatGPT account's data controls:
  > the repository, with its history and its ignored files, and any file its
  > commands open, outside the repository too —
  > credential files such as Codex's own login, SSH keys and cloud keys included.
  > Check whether "Improve the model for everyone" is on. Its commands
  > change no file, while Codex itself keeps the session under `~/.codex`, with
  > everything the model read, and `stop` does not remove it. Its commands have
  > no IP network, and a connect to a Unix-domain socket by path was refused
  > (measured offline with `codex sandbox`); datagram and abstract sockets not measured.
  > Its transcript is not redacted.

  The line breaks keep every searched phrase on one line (*Before* 5).

**After the probe paragraph** (`:59-67`, unchanged, with its gate line
intact): "Codex agents have been tested against a stub and offline against
the real `codex`; none has run against a real model yet." This is true once
O1 has passed at Stage 4, which comes before the commit. If O1 fails, the
plan goes back as `PLAN WRONG` and the sentence goes with it.

**Verify:** *After* §2, lines S12–S16.

### P9 — `AGENTS.md`

- ***Gates*, `:34-35`**: "runs its stub inside the script's real sandbox,
  with a real network namespace" becomes "runs its stub `opencode` inside the
  script's real sandbox, with a real network namespace, and its stub `codex`
  on the host, as the script runs Codex".
- ***Tests*, `:94-97`**: "…which passes its stub `opencode` and its stub
  `codex` to the script with `--cli`…".
- ***Rules*, `:109-121`**:
  - The offline run: "or an offline run — no network, and a dummy key or
    login in a throwaway home — as `docs/specs/external-agents.md` *Offline
    run* records them". The rule binds by those properties. O1 meets them at
    Stage 4, and the record adds its block at Stage 8, which is the order
    every change here has followed.
  - "…own key or login".
  - "It runs only when the user says so in chat for that run and names the
    backend and the models — for Codex, the backend alone names its default
    model — and, for an OpenCode run, after confirming that the console's
    "Use balance" is off; Codex has no such switch (the user's ChatGPT plan,
    2026-10-18)."
- ***One fact* (`:130-201`)**, each entry rewritten in place, every quoted
  phrase on one line:
  - **the manual model rule** keeps its original file list. Revision 5,
    review r1 T6: the Codex clauses are **entries of their own**, each
    listing only the files that state it:
    - "for Codex, no `--model` unless the user named one" (`glab:manager`
      Rule 5, whose `:120` says "with no `--model`", and the skill's start
      example). `review.md` is not listed, because it never states that no
      `--model` is passed;
    - "`codex` alone in the record line for Codex's default" (`glab:manager`
      Rule 5, and the skill's announce step);
  - **the record line and its token**: E50 and E55 join E01;
  - **the allowlist** becomes "the OpenCode model allowlist and its end dates
    (…), and that Codex has none and checks an id's form only, and refuses
    `default` (the script, its test's E58, the skill, `README.md`)", in D32's
    wording;
  - **the sandbox limits** become "OpenCode's sandbox limits and its network
    helper";
  - **the CLI's default path** gains `~/.local/bin/codex`;
  - **"Use balance"** becomes `OpenCode's "Use balance" warning`;
  - **the copy** becomes "what OpenCode's copy holds and may send — …; and
    what a Codex agent may read and send — …";
  - **new entries**:
    - `the guarantees each backend has` (the script's header, the skill,
      `README.md`, `glab:manager` Rule 6);
    - `the Codex read-only check` (the script, E54, the skill, `README.md`);
    - `the Codex effort rule` (`glab:manager` Rules 5 and 6, the skill);
    - `the Codex data note` (`README.md`, the skill);
    - `the host first message` (the script's `first_prompt`, E61).
- **Verify:** *After* §2, lines S17–S27.

### P10 — `plugins/glab/.claude-plugin/plugin.json`

`"version": "0.5.0"` becomes `"0.6.0"`.

**Verify:** *After* §2, line S0.

## One fact — the files this change touches, all in the one commit

| fact | files and steps |
|---|---|
| manual model rule | Rule 5 and the handoff format (P6), `review.md` (P7), the skill (P5); `develop.md` and `ship.md` were checked and are unchanged |
| record line, `<backend>:<model>` | Rule 5 (P6), the skill (P5), the header `model:` field (P3), E01 (unchanged), E50 |
| exit codes (+12) | header (P3), test (P4), skill (P5), the manager's `:123` (P6), README (P8); `ship.md` stays true |
| allowlist | OpenCode's is unchanged; README sentence (P8); E58 |
| sandbox limits, network helper | header (P3), skill (P5), README (P8), *Gates* (P9), all as OpenCode's |
| where agents live | unchanged |
| CLI default path | skill (P5), README (P8), AGENTS.md (P9) |
| "Use balance" | skill (P5), README (P8), live-run exception (P9), each OpenCode-only |
| what the copy holds / what Codex reads | header (P3), skill (P5), README (P8) |
| missing-`AGENTS.md` fallback | P3's host text, E61 |
| reviewer verdicts, exit-8 correction | unchanged; E62 |
| version | P10 |
| new: backend guarantees, read-only check, effort rule, data note, host first message | P3–P6, P8, entries in P9 |

## After

### 1. Gates

Both blocks of `AGENTS.md` *Gates* must be green:

- five `rc=0`, and shellcheck clean;
- `PASS 35/35` and `PASS 71/71`;
- three `✔ Validation passed`;
- `Skills (15)`, `Agents (5)` and `Hooks (1)  SessionStart`;
- the grep lines as *Green is* states them.

### 2. Post-conditions

Save the test output first:
`bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null >"$TMPDIR/fca-test.out"`.

Each line is marked **D** (it discriminates: today's tree prints something
else) or **G** (a regression guard, already true today). Every phrase sits on
one line of its target (*Before* 5).

| id | kind | command | expected |
|---|---|---|---|
| S0 | D | `jq -r .version plugins/glab/.claude-plugin/plugin.json` | `0.6.0` |
| S1 | D | `command grep -c -F 'or a Codex session on this host under Codex' plugins/glab/skills/external-agents/SKILL.md` | `1` (description) |
| S2 | D | `command grep -c -F "for Codex, naming one or leaving it to Codex's default" plugins/glab/skills/external-agents/SKILL.md` | `1` (`:18`) |
| S3 | D | `command grep -c -F 'with whatever Codex reads for Codex' plugins/glab/skills/external-agents/SKILL.md` | `1` (`:48`) |
| S4 | D | `command grep -c -F '12 \| NOT READ-ONLY' plugins/glab/skills/external-agents/SKILL.md` | `1` (the exit row) |
| S5 | D | `command grep -c -F "under your ChatGPT account's data controls" README.md plugins/glab/skills/external-agents/SKILL.md` | `1` each |
| S6 | D | `command grep -c -F 'Improve the model for everyone' README.md plugins/glab/skills/external-agents/SKILL.md` | `1` each |
| S7 | D | `command grep -c -F '- model: glab:reviewer codex, effort <level>' plugins/glab/skills/manager/SKILL.md` | `1` |
| S8 | D | `command grep -c -F 'an OpenCode or a Codex session the user asks for' plugins/glab/skills/manager/SKILL.md` | `1`; and `an OpenCode session on a model the user names` → `0` |
| S9 | D | `command grep -c -F 'naming the model for OpenCode — for Codex, naming one or leaving it' plugins/glab/skills/manager/SKILL.md` | `1` (`:151`) |
| S10 | D | `command grep -c -F "**Codex's effort** is the session's" plugins/glab/skills/manager/SKILL.md` | `1` |
| S11 | D | `command grep -c -F 'a Codex reviewer works in the repository and can take one' plugins/glab/commands/review.md` | `1` |
| S12 | D | `command grep -c -F 'or Codex in its own read-only sandbox' README.md` | `1` (`:9`) |
| S13 | D | `command grep -c -F "naming the model — or, for Codex, leaving it to Codex's default." README.md` | `1` (`:34-35`) |
| S14 | D | `command grep -c -F "the script checks only the id's form" README.md` | `1` |
| S15 | D | `command grep -c -F 'exit 12 (NOT READ-ONLY)' README.md` | `1` |
| S16 | D | `command grep -c -F 'none has run against a real model yet' README.md` | `1` |
| S17 | D | `command grep -c -F 'and its stub `codex` on the host' AGENTS.md` | `1` (*Gates*) |
| S18 | D | `command grep -c -F 'its stub `opencode` and its stub `codex` to the script' AGENTS.md` | `1` (*Tests*) |
| S19 | D | `command grep -c -F 'for an OpenCode run, after confirming that the console' AGENTS.md` | `1`; and `names the models, after confirming` → `0` |
| S20 | D | `command grep -c -F 'a dummy key or login in a throwaway home' AGENTS.md` | `1` |
| S21 | D | `command grep -c -F 'the guarantees each backend has' AGENTS.md` | `1` |
| S22 | D | `command grep -c -F 'the Codex read-only check' AGENTS.md` | `1` |
| S23 | D | `command grep -c -F 'the Codex effort rule' AGENTS.md` | `1` |
| S24 | D | `command grep -c -F 'the Codex data note' AGENTS.md` | `1` |
| S25 | D | `command grep -c -F 'the host first message' AGENTS.md` | `1` |
| S26 | D | `command grep -c -F '~/.local/bin/codex' AGENTS.md` | `1` |
| S27 | D | `command grep -c -F "OpenCode's sandbox limits" AGENTS.md`, `command grep -c -F "OpenCode's \"Use balance\" warning" AGENTS.md`, `command grep -c -F 'what a Codex agent may read and send' AGENTS.md`, `command grep -c -F "checks an id's form only" AGENTS.md`, `command grep -c -F 'for Codex, no `--model` unless the user' AGENTS.md`, `command grep -c -F "in the record line for Codex's default" AGENTS.md` | `1` each |
| S28 | D | `command grep -c -F '12 NOT READ-ONLY' plugins/glab/scripts/external-agent.sh` | `1` (the header's exit list; each `die` writes `12 'NOT…`) |
| S29 | D | `command grep -c -F 'on every exit 2-12' plugins/glab/scripts/external-agent.sh` | `1` |
| S30 | D | `command grep -c -F "die 12 'NOT READ-ONLY'" plugins/glab/scripts/external-agent.sh` | `2` (`codex_verify`, `codex_check`) |
| S31 | D | the host-text check below | prints nothing |
| S32 | D | for each of `E50 … E71`: `command grep -q "^ok $e " "$TMPDIR/fca-test.out" \|\| echo "missing $e"` | prints nothing |
| S33 | G | `command grep -c '^NOT OK' "$TMPDIR/fca-test.out"` | `0` (already true on any green tree) |
| S34 | D | `command grep -B2 '^t E28 ' tests/external-agent.test.sh \| command grep -c -- '--backend nosuch'` | `1` |
| S35 | D | `command grep -c -F 'known: opencode)' plugins/glab/scripts/external-agent.sh` | `0` |
| S37 | D | `command grep -c -F "run with the user's own key or login" AGENTS.md` | `1` (P9's "…own key or login"; today's line reads `run with the user's own key:`) |
| S38 | D | `command grep -c -F 'shell_environment_policy.set.GLAB_EXTERNAL_AGENT' plugins/glab/scripts/external-agent.sh` | `2` or more (`codex_argv` and `codex_check`) |
| S39 | D | `command grep -c -E '^sweep_agent\(\) \{' plugins/glab/scripts/external-agent.sh`; `command grep -n 'sweep_agent "\$1"' plugins/glab/scripts/external-agent.sh` | `1`; a line inside `cmd_stop` |
| S40 | D | `command grep -c -F 'a connect to a Unix-domain socket by path was refused' README.md plugins/glab/skills/external-agents/SKILL.md plugins/glab/scripts/external-agent.sh` | `1`, `2`, `1` (the data note ×2, the skill's guarantees, the script header) |
| S41 | D | `command grep -c -F 'neither IP nor Unix-domain sockets' README.md plugins/glab/skills/external-agents/SKILL.md plugins/glab/scripts/external-agent.sh` | `0` each (it prints `1`, `2`, `1` on the tree as left by review r1) |
| S42 | D | `command grep -c -F 'and refuses `default`' README.md AGENTS.md`; `command grep -c -F "the script checks only the id's form" plugins/glab/skills/external-agents/SKILL.md` | `1` each (D32) |
| S36 | D | `git status --short` | ` M` for the script, the test, the skill, the manager skill, `review.md`, `README.md`, `AGENTS.md` and `plugin.json`, and `?? plan/` |
| G1 | G | `command grep -q '^ok E28 ' "$TMPDIR/fca-test.out"` | it passes today too |
| G2 | G | `command grep -c -F 'There is no external developer' plugins/glab/skills/manager/SKILL.md plugins/glab/skills/external-agents/SKILL.md` | `1` each |
| G3 | G | `command grep -n -F '.codex' plugins/glab/scripts/external-agent.sh \| command grep -v -E '^[0-9]+:\s*#'` | nothing |
| G4 | G | the `^codex_…() {` existence greps | they show only that the functions exist; E50–E71 show what they do |

The host-text check (S31) uses fragments: each line of the block between
the markers, with the two-space indent removed and `<top>` written as
`@TOP@`, must appear whole in the script. E61 then checks the assembled
message with the real path.

```bash
awk '/host-first-message: begin/ {on = 1; next} /host-first-message: end/ {on = 0} on' plan/feature-codex-agent/plan.md \
  | sed -n '/^  ```text$/,/^  ```$/p' | sed '1d;$d; s/^  //; s/<top>/@TOP@/g' \
  | while IFS= read -r l; do [ -n "$l" ] || continue; command grep -qxF -- "$l" plugins/glab/scripts/external-agent.sh || echo "missing: $l"; done
```

### 3. Integrate (Stage 4)

The integrator runs S1, O1 and O2 (D20). Each one is saved under `$TMPDIR`
as a script and run, never pasted. They share this setup:

```bash
: "${TMPDIR:?}"; CX=${CX:-$HOME/.local/bin/codex}
X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX") && mkdir -p "$X/home" "$X/tmp" || exit 1
# A throwaway Codex home and a sibling temp dir, never one inside the other
# (findings §9.6).
export CODEX_HOME=$X/home TMPDIR_CX=$X/tmp
```

- **S1.** In a throwaway git repo `$X/r`, with a listener on `127.0.0.1`, run
  `(cd "$X/r" && TMPDIR=$TMPDIR_CX "$CX" sandbox -c 'sandbox_mode="read-only"'
  -- <cmd>)` for:
  - `true` → rc 0;
  - `sh -c 'echo x >>f'` → non-zero;
  - `cat /etc/hostname` → rc 0;
  - `bash -c 'exec 3<>/dev/tcp/127.0.0.1/<port>'` → non-zero.

  Anything else is `PLAN WRONG` for P2 and D4/D5.

  Revision 5 records `integration.md` *Round 4*, the answer to review r1 S1.
  It probed an AF_UNIX stream socket by path:

  | check | result |
  |---|---|
  | the connect outside the sandbox | `ok`, the known positive |
  | the connect inside | `[Errno 1] Operation not permitted`, with the listener seeing no connection |
  | the socket file inside | visible |

  Not measured: abstract-namespace, datagram and seqpacket sockets,
  `socketpair`, and a descriptor passed in from outside. The approved
  wording in D25 states exactly that much.
- **O1.** The setup:
  - a dummy `$CODEX_HOME/auth.json` with fake JWTs, never a real token;
  - a repo `<repo>` whose `.codex/config.toml` sets
    `model = "project-model-x"`;
  - `$CODEX_HOME/config.toml` with `[projects."<repo>"]` and
    `trust_level = "trusted"`, the repository's absolute path in place of
    `<repo>`. A real TOML file, unlike a `-c` key, can name a project by its
    path;
  - everything run inside `bwrap --unshare-net --die-with-parent --dev-bind /
    /`, with `TMPDIR=$X/tmp`.

  The steps:
  1. `check --backend codex --cli "$CX"`, with its stdout, stderr and rc
     recorded.
     - Expected: `cli:` and `tools:`.
     - Then either `login: stored`, `sandbox: …` and `default:`/`models:`
       lines, or rc 4 with the not-logged-in line if Codex rejects the fake
       login. Both are recorded.
     - A `models:` line, when one is printed, must not be `unavailable`:
       offline, `debug models` falls back to the bundled catalog
       (`findings.md` §3.9).
  2. Run `"$CX" debug models --bundled` through P2's jq program on its own.
     Expected: `default: gpt-6.1-sol (predicted)`, and a `models:` line of 8
     entries that starts `gpt-6.1-sol (low medium high xhigh max ultra),
     gpt-6-astra (low medium high xhigh max ultra)` and ends `gpt-5.5 (low
     medium high xhigh)`, with no `gpt-daybreak` and no `codex-auto-review`.
     This shows the jq program on the real shape.
  3. **The known positive**, first:
     ```bash
     cd <repo> && printf 'Say hello.\n' | "$CX" exec --color never -c 'sandbox_mode="read-only"' -
     ```
     This is Codex directly, without `--ignore-user-config`; with no
     network, no model is reached.

     Expected: the stderr header block's `model:` is `project-model-x`. The
     trusted project's layer loads, so the measurement can tell the two
     cases apart.

     If it is not `project-model-x`, the known positive failed. Record it
     and stop O1 here: step 3b proves nothing without it.

     **3b.** `start --backend codex --cli "$CX" --brief <"Say hello."> --repo
     <repo>`, through the script, which passes `--ignore-user-config`.

     Expected:
     - rc 7 at the network, with a header that names a model other than
       `project-model-x` (D26);
     - `transcript.log` shows `sandbox: read-only`, `approval: never` and a
       UUID session id;
     - `agent.json` `session` is set.

     `project-model-x` here is `PLAN WRONG` for D4/D26.
  4. `send`. Expected: rc 7 with the same session id, not `continued another
     session`.
  5. `list`, then `stop`. Expected: the agent listed, `stopped:`, no process
     left, and no `unknown feature` line anywhere.

  A rejected flag, a different session id, or a jq result unlike step 2's is
  `PLAN WRONG` for P2/D8/D10.
- **O2** (revision 4; it runs on the host under the user's Stage 4
  allowance, `codex sandbox` only).
  1. Run D7's chain around `"$CX" sandbox -c 'sandbox_mode="read-only"' -c
     'shell_environment_policy.inherit="core"' -c
     "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$M\"" -- sleep 300`,
     with `GLAB_EXTERNAL_AGENT=$M` also exported, where `M=ea-<16 random
     hex>`. Record the pid tree with start times.
  2. SIGKILL the outermost `setpriv`.
  3. **Known positive**: after 2 s, the helper and its `sleep` are still
     alive. That is the defect.
  4. Run `sweep_agent "$M"`, copied byte for byte from the built script.
  5. After 1 s, no recorded pid may be alive (checked by pid and start
     time), and no process may carry `GLAB_EXTERNAL_AGENT=$M`.

  Any survivor is `PLAN WRONG` for P3/D31. Anything that is still alive at
  the end is killed by its recorded pid.
- Each one ends with `rm -rf "$X"`.

### 4. Review, commit, push, back-out

- **Review (Stage 5)**: full tier, up to three rounds, on the working tree.
- **Commit** (D23), then **push** on the user's go-ahead.
- **Back-out**:
  1. `stop` every Codex agent with the new script.
  2. `git revert <commit>`.
  3. Bump the version to 0.6.1.

  Codex's own sessions stay in Codex's history either way.

## Record

Stage 8, after the push. Each spec changes in one `docs(repo)` commit with
`glab:analyzer`'s carry check and, at full tier, one `glab:reviewer` pass on
the spec diff.

- **`docs/specs/external-agents.md`**:
  - *How it works now*: two backends, `--effort`, exit 12, the Codex state and
    transcripts, D17's targets.
  - *Isolation*: split by backend, with §9.3's table.
  - *Measurements*: S1, O1 and O2 as recorded.
  - *Allowlist*: Codex has none.
  - *Known limits*: *UNVERIFIED* below.
  - *Offline run*: O1's block and its output, byte for byte.
  - *Live runs*: Codex has no "Use balance", and uses the user's login.
  - *Decisions that still bind*: U1–U8 and D1–D30, each tagged.
  - *Open follow-ups*: *Not in this plan*.
  - *Closed follow-ups*: `[feature-opencode-worker/plan-r3.md not-in-plan-1]`
    (the Codex adapter).
  - *Records*: this change.
- **`docs/specs/workflow.md`**: Rule 5's Codex record line and effort; Rule 6
  covering two backends, no longer "read-only on a copy" for every agent;
  D30's effort line.
- **`docs/specs/marketplace.md`**:
  - `AGENTS.md`'s changed *Gates* sentence and *Tests* bullet;
  - the external-agent rule's offline and live-run wording;
  - the new and rewritten *One fact* entries;
  - `glab` 0.6.0;
  - the test count, `PASS 71/71`.

## Tests and coverage, as a list (`AGENTS.md` *Tests*)

- **P1**: E01–E49; E28 (the renamed backend, and `known_list`); E33
  (`opencode_check`); E09, E12 and E41 (`opencode_mounts`); E04 and E14
  (`opencode_raw`); E15 (the start of `read_secret`'s message); E29–E31
  (`opencode_model_allowed`); E58's last two lines (D19).
- **P2**:
  - E50 (`codex_raw`, `codex_ran`, `codex_session`, `codex_text`,
    `codex_render`);
  - E51 and E52 (`codex_argv`);
  - E54 (`codex_verify`);
  - E55 and E65 (`codex_block`, `codex_field`, forgery, malformed fields);
  - E56 (`codex_env`);
  - E57 (`codex_error`);
  - E58 (`codex_model_allowed`, `codex_effort_ok`);
  - E59 (`codex_check` and its jq program, on the recorded shape);
  - E61 and E62.
- **P3**:
  - E50 (a host start, the transcript heading);
  - E52, E53 and E66 (D8 on both backends);
  - E54, E55 and E65 (`finish_turn`'s order; the `default` and `.model`
    fallbacks);
  - E60 (the group, the D31 sweep of a setsid'd child, `stop`, the
    timeout); E69 (the script SIGKILLed, then `stop`'s sweep, and a decoy
    with another id left alone);
  - E70 (the sweep before every `send`, in `cmd_send`, review r1 C1);
  - E71 (the `capped.$$.*` flag names, review r1 C1);
  - E61 (the host text);
  - E63 (`list`, D28);
  - E64 (both caps);
  - E67 (`run_host`'s exit 4);
  - E68 (descriptors closed);
  - E51 (D11);
  - E36.
- **P4**: E36 last, and `cleanup` killing `$CXH/pids` behind the guard.

Not covered by any case, and accepted:

- `codex_check`'s exit 4 for a missing tool. The tools live in `/usr/bin`
  beside `bash`, `git` and `jq`, so they cannot be taken away alone. The check
  is one loop, like `net_tools`.
- `opencode_secret_hint`'s tail. E15 matches the start of the message, and
  the tail is moved text, not changed text.
- A host repository with no commit (D28). No case builds one. The record is
  two `hostgit` calls whose failure is tolerated.
- The real Codex's header, flags, trust default, catalog and resume: O1.
  Codex's sandbox on this host: S1. That the real helper carries the marker
  and dies to the sweep: O2 (revision 4). The stub's setsid child stands in
  for it in E60 and E69.
- The D13 names the test does not set (`USER`, `LOGNAME`, `XDG_*`, `DBUS_*`,
  the proxy and `SSL_CERT_*` variables). E56 shows that no other name passes.
- The script itself SIGKILLed is now covered: E69, through `stop`'s sweep.
  Not covered: a script killed and never `stop`ped. Its leftovers run until
  the next `stop` of that agent, and the manager stops every agent it started
  (Rule 6).
- **`cleanup`'s `host_turn` sweep** (`external-agent.sh:203`; review r1 C2,
  revision 6). It acts only when a HUP, INT or TERM arrives during
  `run_host`'s own post-turn sweep. That window is one `/proc` scan,
  milliseconds long and with nothing to kill, and a signal cannot be aimed at
  it reliably. A signal at any other time lands before `host_turn` is set or
  after it is cleared, and the other sweeps cover it. The review's mutant
  passes for the same reason. The code is one line, read in place
  (`result-p1-p4.md`, *Round 4*).
- **C2's `trap '' HUP INT TERM` and C-A** (`isolation` after `lock_agent`).
  Both are races with a second signal or a concurrent `stop`, as
  `result-p1-p4.md` *Round 3* gives.
- P5–P10 are text: *After* §2, S1–S27, and review.

## UNVERIFIED, in one place

- That Codex's read-only sandbox starts on this host, refuses writes, allows
  reads outside the repository and gives commands no network: S1.
- That the real header block is as `findings.md` §9.2 gives it, that every
  `--disable` name is accepted, that `--ignore-user-config` drops a trust
  entry the user's `config.toml` holds (D26: without the flag a trusted
  project's `project-model-x` loads, with it it does not), and
  that `exec resume <id>` continues and prints the same id: O1.
- That `login status` exits 0 for a real login. That comes from the source
  read (`findings.md` §9.8); the rc 1 path was run.
- That `codex exec`, like `codex sandbox`, passes
  `shell_environment_policy.set` to its sandbox helper, so that D31's sweep
  finds a real turn's helper. Measured for `codex sandbox` only
  (`findings.md` §9.9); `exec` is outside every allowance so far. The first
  live run that the user orders should end one turn with `stop` while a
  command is running, then check that no process carrying the marker is
  left. If it fails, D31's rejected scope (C3) is the fallback, and that
  needs the user's yes for the systemd dependency.
- That a keyring login works under `--ignore-user-config` (D10). The user's
  first real turn shows it.
- Only a live run, ordered by the user, can show these:
  - that `check`'s predicted default is the model that runs;
  - reroutes;
  - an unsupported effort level;
  - a real turn obeying read-only;
  - the model honouring "Read nothing outside <top>".

## Not in this plan

- **The external developer** (Codex `workspace-write`, the pipeline wiring,
  U3): the second change of Q1. `[feature-opencode-worker/plan-r3.md
  not-in-plan-2]` stays open.
- **A live Codex run**: only on the user's instruction.
- **`findings.md` F1**: `plan/SESSION-HANDOFF.md` sits in OpenCode agents'
  copies.
- **A Codex profile tuned from real replies.**
- **Removing a Codex session from Codex's history at `stop`** (D12).

## Revision 5: still to build

Review r1's fixes are built in the working tree (`result-p1-p4.md` and
`result-p5-p10.md`, *Round 3*, `PASS 70/70`; `PASS 71/71` since review r2 split E70, revision 6), except the following.

**The docs developer**:

1. Replace the socket clause with the approved wording of D25 in each place
   that states it, keeping each searched phrase on one line:
   - `README.md:78-80` (the data note);
   - the skill's `:70-72` (the data note), so that it stays identical to the
     README's;
   - the skill's `:252-254` (*Its network*: "Its commands have no IP
     network, and a connect to a Unix-domain socket by path was refused
     (measured offline with `codex sandbox`); datagram and abstract sockets
     not measured. Codex itself reaches OpenAI.").
2. Apply D32's model-id wording:
   - `README.md:50-51` gets ", and refuses `default`, the word its output
     uses for Codex's own default";
   - `AGENTS.md:189-190` gets ", and refuses `default`";
   - the skill gets "the script checks only the id's form" beside its
     `default`-refused sentence (`:245-247`).
3. Verify: S5, S6, S40, S41 and S42 print what *After* §2 says, and the two
   copies of the data note still compare equal.

**The script developer**:

1. `external-agent.sh:90-93`, the header comment: "its commands change no
   file, and have no IP network, and a connect to a Unix-domain socket by path
   was refused (measured offline with `codex sandbox`); datagram and abstract
   sockets not measured".
2. Nothing else. The host first message (`:839`, "Your commands have no
   network.") stays as it is: it is D24's verbatim prompt to the model, which
   S31 and E61 pin. It is an instruction, not a guarantee to the user, and
   Round 4 found no network for the commands. The script comment at `:476`
   already says why `default` is refused.
3. Verify: S40 and S41 for the script, then the four test gates (`PASS
   71/71`).

**O2 needs a rerun.** O2 (revision 4) measured `sweep_agent` as it was then:
a newline-split reading and two passes every time. The built function reads
NUL entries through `environ_has` and makes its second pass only after a
kill. O2 step 4 requires the built function byte for byte, so its record no
longer covers the code that ships.

- The integrator reruns O2 as *After* §3 gives it, with `sweep_agent` and
  `environ_has` copied from the built script.
- It runs under the user's `codex sandbox` allowance only: a throwaway
  `CODEX_HOME` and `HOME` with a fake `auth.json`, `sleep` as the command, and
  kills by pid.
- The expected result is unchanged: the known positive, then nothing left.

No other Stage 4 measurement depends on the changed code. S1 and Round 4
used no part of `sweep_agent`. O1's `check` called the old one, but none of
O1's expected results depends on it.

## Changes since revision 1

### Revision 2 (`analysis-1b-r1.md`)

- **A1.1, A2.1, A3.1**: the host text is written out verbatim (P3).
- **A1.2**: stderr goes into `transcript.log` (D15), and E50 checks it.
- **A1.3**: `run_turn` is split three ways, and `run_host` uses the real
  `$cli`.
- **A1.a**: every host turn needs a well-formed model and session id.
- **A1.b**: `authd` is used for `check`'s directory; the global `isolation`
  is added; the group is killed before the filters are waited for.
- **A1.c**: no change.
- **A1.d**: D19 keeps the check in place.
- **A1.e**: D10, and `findings.md` §9.7.
- **A2.2**: E56's set is fixed.
- **The coverage gaps**: E66, E55, E67 and E51.
- **The post-conditions** are marked D or G.
- **A3.2, A3.3**: the README sentence, and the rewrites of manager `:151`,
  skill `:18` and `:48`, and README `:9` and `:34-35`.
- **The citations** are corrected.
- **The effort rule** sits in one entry.
- **The README's exit 12**, the Codex tools and the data-note wording.
- **`AGENTS.md` *Gates***, and the offline-run wording.

### Revision 3 (`analysis-1b-r2.md`)

- **B1.1**: the `debug models` shape and the `login status` exit codes are
  recorded (`findings.md` §9.8; the one allowed offline run, rc 0 and rc 1).
  P2 gives the jq program verbatim, the stub's fixture uses the recorded
  shape, and O1 runs `check --backend codex` and the jq program on real
  output.
- **B2.1**:
  - `codex_render` and the heading: E50;
  - a malformed model or session id: E65 (new scenarios `badmodel`,
    `badsess`);
  - `run_host` closing descriptors: E68;
  - the stderr cap: E64;
  - the `.model` fallback: E55;
  - `known_list`: E28;
  - head and branch: E63.

  `opencode_secret_hint`'s tail and a host repository with no commit are
  named as accepted.
- **B2.2, B1.e, B3.b**: S31 uses fragments, with `<top>` written as
  `@TOP@`. The script holds the text as `@TOP@` lines in a quoted heredoc,
  and E61 checks the assembled message.
- **B2.3, B3.d**:
  - S28/S29 for the header comment;
  - S11 for P7;
  - S7–S10 for P6;
  - S12–S13 for P8 `:9` and `:34-35`;
  - S17–S27 for each P9 entry;
  - S2, S3, S8, S9 and S13 for the A3.3 rewrites.

  Each step from P5 to P10 has a *Verify* line, and *Before* 5 is the
  one-line rule.
- **B3.1**: a `## Record` section, naming `external-agents.md`, `workflow.md`
  and `marketplace.md`.
- **The non-blocking items**:
  - B1.a: the shifted arguments are written out.
  - B1.b: D27.
  - B1.c: D28.
  - B1.d: `-c` keys are split at `.` and never TOML-parsed (`findings.md`
    §9.8). The untrusted override is dropped, and D18 is withdrawn; D26
    relies on Codex's default untrust instead, and O1 measures it.
  - B1.f: the two binds are listed, and `setsid --wait` is rejected (D29).
  - B2: the cleanup guard is placed and described; `turns` is defined; E28's
    `ok` line is G1; the data-note and every other searched phrase stay on one
    line.
  - B3.a: *Before* 5.
  - B3.c: D30.
  - B3.e: the combined README wording is in P8.
  - B3.f: skill `:64` and `:86` are qualified; the README sentence's
    dependence on O1 is stated.

**Round 3 notes**, still revision 3:

- D26 and O1 now have a known positive. A throwaway `config.toml` marks the
  repo trusted. Codex run directly, without `--ignore-user-config`, loads
  `project-model-x` (step 3). The script, which passes the flag, must not
  load it (step 3b). Without the known positive, step 3 could not tell the
  two cases apart.
- S33 is relabelled G.
- S37 is new. It searches for P9's "own key or login", and it prints `0`
  today.

### Revision 4 (Stage 4, `integration.md` O2; `findings.md` §9.9)

- **The defect.** Codex's sandbox helper and its command run in their own
  session, so they outlived D7's chain and its group kill.
- **The three candidates, measured** with `codex sandbox` on the host:
  - **SIGTERM or SIGINT first**: fails, because nothing tears the helper
    down.
  - **A marker through `shell_environment_policy.set`, swept by PID**:
    works.
  - **A user scope per turn**: works, but it adds a systemd dependency.
- **Chosen: the marker** (D31). It adds no dependency, and E60, E69 and the
  stub can test it.
- **What changed:**
  - D7 and D13;
  - P2: `codex_argv` item 4, `codex_env <marker>`, the new `sweep_agent`,
    and `codex_check`'s steps 2 and 4;
  - P3: `run_host` steps 3, 8 and 9, `cleanup`, the new `cmd_stop` sweep,
    and the header list;
  - P4: the stub's `sleep` scenario, E56, E60 and the new E69 (69 cases);
  - P5: `:64`;
  - O2, which now has a known positive and the sweep;
  - S38 and S39, the coverage list, and *UNVERIFIED* (`exec`'s helper, to
    be checked in the first live run).

### Revision 5 (review round 1, `review-r1.md`; `questions.md` *Review round 1 fixes folded into the plan*)

The user approved it. Conformance round 3 found the built tree ahead of
revision 4, and this revision makes the plan say what was built and
approved.

- **U5**: with `models: unavailable`, the session's level is sent unchanged
  and the announce line says so (T5); P5 and P6 say the same.
- **D25 and P8**: the data note is the built text (S1, S3), carrying the
  tighter socket clause the user approved. P8's Codex requirements paragraph
  carries the model-id sentence (T1) and the exit-12 approval clause (T3).
  The "OpenCode runs only the models named below;" lead-in is dropped. P5's
  exit-12 row adds the approval clause.
- **D32 (new)**: one model-id wording, now that `default` is refused.
- **P2**:
  - `codex_model_allowed` refuses `default` (T4);
  - `sweep_agent` reads through `environ_has` with `mapfile -d ''` (C-D),
    and makes its second pass only after a kill (C3);
  - the catalog is filtered and cleaned (S-4), `cmark` is cleared, and
    `debug models` runs with an empty marker;
  - `codex_cmd` is top-level (C-B).
- **P3**:
  - `cmd_send`: `isolation` after `lock_agent` (C-A), and the host sweep
    before `run/` is replaced (C1);
  - the `capped.$$.*` flags (C1);
  - `cleanup`'s signal trap and the `host_turn` flag (C2);
  - `cmd_stop`'s sweep rule (C3);
  - `header` top-level (C-B);
  - tag-form comments (T-7).
- **P4**:
  - E56 passes `HTTPS_PROXY` and `USER` (T-8);
  - E58 adds `default` (T4), and E59 has out-of-form catalog entries (S-4);
  - E69 has a second decoy (C-D), and E70 is new (C1);
  - stub pids are appended (T-9);
  - the `late-flood` and `slow` scenarios are added;
  - the count is 70 (71 since revision 6).
- **P5, P6 and P9**:
  - the announce token (T4), the tools and MCP wording (S2, T2), and the
    guarantees;
  - manager `:120`, `:128` and Rule 6;
  - the Codex clauses as *One fact* entries of their own (T6).
- **After**:
  - S1 records *Round 4*'s Unix-socket probe;
  - S40–S42 are new;
  - *Revision 5: still to build* lists the socket and model-id wording that
    is still to change;
  - O2 needs a rerun against the built sweep.
- **Not taken here**: review r1's follow-ups C-C, C-E/S-5, S-6 and S-7,
  which stay follow-ups by assignment.

### Revision 6 (conformance round 4/4; `questions.md` *Revision 6*)

The user approved it. It records the tests as built, and changes no code and
no docs.

- **The count.** Review r2's R2-1 split revision 5's E70 in two, so the
  count is 71, not 70: D21, the P4 heading and *Verify*, *After* §1, S32, G4,
  *Record*, and *Revision 5: still to build*.
- **E70** is now the sweep before every `send`, with the stub's new `stale`
  scenario. **E71** is the PID-named cap flag, with `late-flood-unmarked`
  (which replaces `late-flood`) plus `slow`. The test helper `environ_line`
  is new.
- **The scenario table** names `late-flood-unmarked`, `slow` and `stale`
  with their cases.
- **The coverage list** names E70 and E71. It also lists `cleanup`'s
  `host_turn` sweep (`external-agent.sh:203`) as uncovered, with its reason:
  the signal window is too narrow to hit reliably. C2's trap and C-A stay
  listed as uncovered races.
