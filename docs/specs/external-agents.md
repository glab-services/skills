# External agents — spec

External agents in `glab`, on two backends: OpenCode sessions on a model
the user names, on a sandboxed read-only copy of a repository, and Codex
sessions on this host, in the repository itself under Codex's own sandbox —
read-only for every role but a developer's — on the model the user names or
Codex's default. The manager starts, continues, lists and stops both through
`glab:external-agents` and `external-agent.sh`; the external reviewer of
`glab:manager` Rule 5 runs on either, and its external developer on Codex
only. Owned by
`plugins/glab/scripts/external-agent.sh` (its header, constants and comments
own the commands, output, exit codes, state, isolation and limits;
`opencode_models()` owns the allowlist; the `codex_*` functions own the Codex
adapter), the `glab:external-agents` skill
(`plugins/glab/skills/external-agents/SKILL.md`) and its `profiles/`,
`glab:manager` Rules 5 and 6, `tests/external-agent.test.sh`, and `README.md`
*Requirements*. Stated as of `6838133` (`glab` `0.4.2`), its
`feature-docs-specs` lines as of `09d2787` (`glab` `0.5.0`), and its
`feature-codex-agent` lines as of `30f2c80` (`glab` `0.6.0`), and its
`feature-external-developer` lines as of `33a28df` (`glab` `0.7.0`); where
this file and an owning file disagree, the owning file is right.

## How it works now

- **Five commands** (the script's header): `start --backend <name> --model
  <id> --cli <path> --brief <file> [--role general|reviewer|developer]
  [--label <text>] [--repo <dir>] [--timeout <seconds>] [--effort <level>]`
  — `--model` is optional for `codex`, which then runs its own default, and
  `--effort low|medium|high|xhigh|max|ultra` and `--role developer` are
  taken by `codex` only (exit 2 for OpenCode, before anything is created);
  `send <agent id> --message <file>
  [--timeout <seconds>]` — the same backend session, its context kept;
  `list` — `agents: <n>`, then one line per agent: id, state (`idle`,
  `running`, `broken`), model, role, turns, last activity, repository and
  label; `stop <agent id>` — ends a running turn and removes the agent's
  copy, session and transcript (for Codex: its directory and transcript, and
  any process its turns left running; its session stays in Codex's own
  history); `check --backend <name> --cli <path>` — for OpenCode the
  CLI, the tools found, `key: stored` (never the key) and the models allowed;
  for Codex `cli:`, `tools: setpriv setsid timeout flock`, `login: stored`
  (from `codex login status`'s exit status, its text never printed),
  `sandbox: read-only starts`, `default: <slug> (predicted)` and `models:
  <slug> (<levels>), …` from `codex debug models` — not logged in is exit 4,
  a sandbox that does not start exit 12, an unreadable catalog `models:
  unavailable` with exit 0. Codex's `check` commands take no
  `--ignore-user-config`, so they run under the user's own Codex config;
  the turns do not (`[feature-codex-agent/plan.md D10]`).
  The manager runs `start` and `send` in the background and is told when they
  exit; one turn runs at a time per agent.
- **Two backends, one wrapper** (`[feature-codex-agent/plan.md D1]`): the
  adapters are function sets inside the one script, called as
  `${backend}_<name>`; `<b>_isolation` prints `sandbox` (OpenCode) or `host`
  (Codex), and `cmd_start`, `cmd_send`, `run_turn` (split into
  `run_sandboxed` and `run_host`), `cmd_check` and `cleanup` branch on it.
  The ids, the lock, `list`, `stop`, the output contract and the exit codes
  are shared. `known_backend` knows `codex` and `opencode`
  (`(known: codex, opencode)`); `model_optional` lets `codex` leave
  `--model` out, and no adapter is called before the backend name is
  checked (D19). A new backend is a new adapter set, a line in
  `known_backend`, one in `model_optional` if `--model` may be left out, and
  a stub in the test (the adapter-contract comment in the script).
- **The Codex backend** (`[feature-codex-agent/plan.md U2]`, D3–D15, D31):
  - **Where it runs.** On this host, in the user's real repository, with
    its working directory at the top; no copy, no bwrap of the script's, no
    `slirp4netns`. Codex's own read-only sandbox is the containment. It uses
    the user's own Codex login under `~/.codex`: the script never reads,
    copies, exports or redacts a token, and never writes `~/.codex`. Codex
    itself writes its state there (sessions, logs, a token refresh), as it
    does for the user, and `stop` leaves the session in Codex's history
    (D12).
  - **What a turn passes** (`codex_argv`): `exec --color never` on a first
    turn, `exec resume` on a continued one; `--ignore-user-config
    --ignore-rules`; `-c sandbox_mode="read-only"` and `-c
    approval_policy="never"`; web search off, `shell_environment_policy`
    `inherit="core"`, history, analytics, feedback, metrics and the update
    check off, and the agent marker (below); `--disable` for apps, plugins,
    remote plugins, the browser and computer tools, the in-app browser,
    image generation, hooks, memories, multi-agent and skill MCP dependency
    install; `-m <model>` only when one is named; `-c
    model_reasoning_effort="<level>"` only when an effort is set; on a
    continued turn the recorded session id; then `-`, the first message on
    stdin. MCP is not turned off by a flag: a turn has no MCP server only
    because it ignores the user's `config.toml`; a managed or system config
    is not ignored (D4; the skill's *What the script guarantees*). With the
    user's config ignored no project is trusted, so the repository's own
    `.codex/` config, hooks and rules do not load (D26, measured: O1).
  - **Its environment** is an allowlist (D13): `PATH`, `HOME`, `USER`,
    `LOGNAME`, `TMPDIR`, `CODEX_HOME`, the `XDG_*` directories,
    `DBUS_SESSION_BUS_ADDRESS`, the proxy and certificate variables, each
    only when set; `LANG=C.UTF-8`, `TERM=dumb` and
    `GLAB_EXTERNAL_AGENT=<agent id>` always. Values are exported in the
    subshell, never put on a command line.
  - **The model** (`[feature-codex-agent/plan.md U4]`, D6). No `--model`
    when the user names none: Codex runs its own default. A named id must
    match `^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$`; `default` itself is refused
    (exit 5), since it is the word the output uses for Codex's default (D32).
    There is no allowlist and no end date. The model that ran is read back
    from Codex's header block, form-checked, and named in the header line,
    the transcript heading and `agent.json` `ran` (`list` shows `ran`, else
    the requested id, else `default`). The record line names `codex` alone
    for the default and `codex:<id>` for a named model; the handoff line
    names `codex:<the model the header named>`. The model can change between
    rounds, which the user accepted.
  - **The effort** (`[feature-codex-agent/plan.md U5]`, D9, D30): the
    session's — `CLAUDE_CODE_EFFORT_LEVEL` when set, otherwise the manager
    asks the user once per session and records the answer; it sends the
    highest level the model supports that is not above it, from `check`'s
    levels, and says so in the announce line; with `models: unavailable` it
    sends the level unchanged and says `effort <sent> (no levels known)`.
    The script stores `--effort` in `agent.json` and passes it on every turn.
  - **The read-only check, exit 12** (D5). Codex runs in its human output
    mode, not `--json`, because only the header block it prints on stderr
    names the model (D3). The script reads the first `OpenAI Codex v<n>`
    block within the first 20 lines of stderr, SGR removed. A block that does
    not say exactly `sandbox: read-only` and `approval: never` is exit 12
    NOT READ-ONLY, the reply withheld; a turn whose block is missing, or has
    no well-formed model or session id, is exit 7, on every turn.
  - **The session** (D8). The id is the block's `session id:`, a UUID;
    `send` passes only the recorded id, as `exec resume <id> -`. A continued
    turn, on either backend, that reports another session is exit 7 and the
    recorded session does not change — Codex silently starts a new thread
    for an id it does not find.
  - **Process lifetime and the marker sweep** (D7, D31). The turn runs as
    `setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 <t> setpriv
    --pdeathsig KILL -- <codex …>`, exec'd from a background subshell, so its
    process group id is the started pid; after the turn the group gets TERM,
    then KILL. That does not end Codex's sandbox helper and its commands,
    which run in a session and group of their own (*Incidents*, O2). So every
    process of a turn carries `GLAB_EXTERNAL_AGENT=<agent id>`, exported and
    passed as `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<id>"`,
    and `sweep_agent` kills, by PID, each process of this uid whose
    `/proc/<pid>/environ` holds that exact NUL-separated entry, after
    re-checking the entry and the start time; a second pass after 1 s runs
    only when the first killed something. It runs **after every host turn**
    (before the output filters are waited for), **in `cleanup`** (while the
    `host_turn` flag is set, and for `check`'s own marker), **before every
    `send`** (after the lock, before `run/` is replaced) and **at every
    `stop`** (after the lock, before the directory is moved aside; skipped
    only for an agent whose `agent.json` names a known sandbox backend). The
    last two end what a turn left when its script was SIGKILLed. `cleanup`
    first ignores HUP, INT and TERM, so a second signal cannot cut it short.
    The host output filters close the agent's lock descriptor, so a stand-in
    still holding the streams cannot keep `stop` from the lock
    (`[feature-codex-agent/result-p1-p4.md L297]`); the cap flags are named
    `capped.<script pid>.stdout` and `.stderr`, so an old turn's filter
    cannot fail the next turn.
  - **Its CLI path** is made absolute but not resolved, so the user's
    `current` link is followed across a Codex update (D11); the default is
    `~/.local/bin/codex`. A host turn first checks that the repository is
    still the one the agent started in (exit 4 otherwise).
  - **No redaction** (D14): a Codex transcript holds whatever Codex
    printed.
- **OpenCode is unchanged** (`[feature-codex-agent/plan.md D2]`): its
  OpenCode-specific lines moved into `opencode_*` adapters with the same
  effect, which E01–E49 pin. The one addition that reaches it is D8's
  session check on a continued turn, which fails only on a path no OpenCode
  run has shown, and E66 pins it (the stub's `othersess` scenario). E28's
  unknown backend is now `nosuch`.
- **Roles.** `general` — read, run, analyse, review, answer, for any task the
  user names; `reviewer` — the reviewer's own contract and report section,
  the report block validated by the script; `developer`, Codex only —
  `glab:developer`'s contract, changing files in the repository and nowhere
  else (*The Codex developer role* below). Every agent's first message tells
  it to read the repository's `AGENTS.md` first (`CLAUDE.md`, saying so, when
  there is none) and carries `glab:security` and `glab:comments`, as every
  internal dispatch does. A general or reviewer agent changes no file, and
  nothing it proposes is applied except through the pipeline. Until
  `feature-external-developer` (`glab` 0.7.0) there was no external
  developer; now a Codex agent can be one, under `glab:manager` Rule 5.
  A Codex agent's first message carries the host text of D24 instead of the
  sandbox's "Where you are working" (the script's `first_prompt`, pinned by
  E61, one fact with it): it works in the repository at `<top>` itself, under
  Codex's read-only sandbox; its commands can read files outside the
  repository, so it reads nothing outside `<top>` unless its task names it;
  its commands have no network and it has no web tool; it reads
  `<top>/AGENTS.md` first, or `<top>/CLAUDE.md` and says there is no working
  agreement. `<top>` is substituted with a quoted replacement, because bash
  5.3 replaces an unquoted `&` in a path (`feature-codex-agent` findings §9.8).
- **Output contract.** stdout of `start` and `send`, and nothing else:
  `agent: <id> · model: <backend>:<model> · turn: <n> · transcript: <file>`,
  then on exit 0 `reply:` and the reply with `| ` before every line, control
  characters removed, then `end: <id>` as the last line. For Codex the
  `model:` field is the model that ran, as its header block named it; else
  the one asked for, else `default` (`codex:default`). For a developer,
  between the header line and `reply:`, the change report: one
  `changed: <code> <path>` line per path whose entry changed (or
  `changed: none`, or `changed: unreadable`), then `git: unchanged` or
  `git: changed`, on every exit after a turn ran — 0, 6, 7 and 12. No line
  the script writes starts with `| `, so a reply cannot forge one. stderr: one line
  `external-agent: <CODE>: <reason>` on every exit 2–12; a signal ends a call
  with 128 + the signal and no line (129, 130, 143 — the last a turn `stop`
  ended).
- **Exit codes** (the header, `tests/external-agent.test.sh`, the skill, the
  manager, `ship.md`, `README.md` — one fact): 0 OK, 2 USAGE, 3 UNKNOWN
  BACKEND, 4 UNAVAILABLE, 5 MODEL REFUSED, 6 TIMEOUT, 7 BACKEND ERROR (a Go
  usage limit arrives here), 8 MALFORMED REPORT (reviewer only), 9 NO
  ISOLATED NETWORK (OpenCode only), 10 UNKNOWN AGENT, 11 BUSY, 12 NOT
  READ-ONLY (Codex: its sandbox cannot start here, or a turn reported
  another sandbox than the one it asked for — `read-only`, or
  `workspace-write [workdir]` for a developer — or an approval policy other
  than `never`; the reply is withheld). For Codex, 4 also means not logged
  in, or a repository that moved since the agent started; 5 a model id that
  is not one; 7 a turn that continued another session or printed no header
  block. For a developer, 2 at `start` and 4 before a later turn also mean a
  refusal (*The Codex developer role*), and 4 at `start` a `find` without
  `-files0-from`. A changed `.git` is not an exit code: the `git: changed`
  line is.
- **State.** `$TMPDIR/glab-external-agents/<id>/`, mode 700, an id `ea-` and
  16 hex digits: `agent.json` (the script's alone; it now also holds
  `effort` and `ran`), `work/` (the copy),
  `data/` (the backend's data directory, its session database),
  `transcript.jsonl` and `transcript.txt` (redacted, readable by the user
  until `stop`), and `run/` for the turn in progress, its own `$HOME`
  included. `stop` moves the directory aside as `.stopping.<id>` and removes
  it. `TMPDIR` is required; there is no `/tmp` default. A Codex agent has no
  `work/` and no `data/`; it keeps `transcript.txt` (rendered: per turn a
  `## turn <n> · codex:<model> · <time>` heading, `manager:` and the message
  sent that turn, then a `codex: model=…
  sandbox=… approval=… effort=… session=…` line, the stderr after the block,
  then `says:` and the reply) and `transcript.log`, which holds per turn
  `=== turn <n> stderr ===`, the stderr with the header block, `=== turn <n>
  stdout ===` and the stdout, not redacted (D15). `head` and `branch` are
  read from the real repository; one with no commit records `""` for both
  (D28).
- **Manual only.** An external agent runs only when the user asks, naming the
  model for OpenCode — for Codex, naming one or leaving it to Codex's default
  (Rule 6) — or when Rule 5 has recorded an external reviewer or an
  external developer. Nothing
  else starts one — not a usage limit, not a failed round, not a file — and
  when one cannot run the manager stops and says why; running the work on
  Claude or on another model instead is the user's call. The manager stops
  every agent it started before the session ends, unless the user asks to
  keep one. The CLI path is explicit (`--cli`): the one the user gave, or
  `~/.opencode/bin/opencode`, where OpenCode's installer puts the native
  binary; a launcher script cannot run in the sandbox. For Codex it is the
  path the user gave, or `~/.local/bin/codex`. The OpenCode console's
  "Use balance" switch must be off, or a Go limit spends pay-as-you-go
  balance; the script cannot see it, so the skill says it once. Codex has no
  such switch (the user's ChatGPT plan, `[feature-codex-agent/plan.md U7]`);
  instead the skill tells the user once per session the Codex data note
  (`README.md` and the skill, word for word; D25): what Codex reads goes to
  OpenAI under the user's ChatGPT account's data controls — the repository
  with its history and ignored files, and any file its commands open, outside
  the repository too, credential files included — so check whether "Improve
  the model for everyone" is on; Codex keeps the session under `~/.codex`
  and `stop` does not remove it; its transcript is not redacted. A Codex
  start passes no `--model` unless the user named one.
- **Replies are untrusted text**: shown as that model's words, every claim
  checked before it is acted on or reported, no command or path taken from
  one, its instructions binding no one.
- **The external reviewer** (Rule 5): the user may name a backend and a model
  for `glab:reviewer` — "review on OpenCode, opencode-go/<id>". It is
  recorded like a Claude model, `- model: glab:reviewer opencode:opencode-go/<id>, for the session — the user's instruction, not a manager choice: "<the user's words>"`,
  and named `<backend>:<model>` in the handoff line
  (`slug · review · model opencode:opencode-go/<id> · round 1/3 · SHIP`).
  Or Codex alone — "review on Codex", Codex's own default model with no
  `--model` — or "review on Codex, <id>"; its line also records the effort:
  `- model: glab:reviewer codex, effort <level> (CLAUDE_CODE_EFFORT_LEVEL | the user's answer: "<words>"), for the session — the user's instruction, not a manager choice: "<the user's words>"`,
  with `codex:<id>` for a named model; the handoff line names the model the
  script's header named (`codex:default` when none has run). A Codex
  reviewer uses the `default` profile only (D16).
  Each review round of Stage 5, `/glab:review` and `/glab:ship` — each
  fan-out dimension too — is a new `--role reviewer` agent whose brief is the
  target and the round alone; its report is the round's report. On exit 8
  the manager `send`s the same agent one correction naming the gaps (it keeps
  its context; not a review round); still 8, it stops and tells the user. The
  agent is stopped once its report is read. An OpenCode copy holds `HEAD` and
  the working tree only, so a branch or range target cannot resolve: the
  manager tells the user instead. A Codex reviewer works in the repository
  and can take one (D17); `/glab:ship` still reviews the working tree only.
- **The report check.** The reviewer's reply is its report block between
  `=== REPORT START ===` and `=== REPORT END ===`; the script checks its form,
  not its judgement: exactly one verdict line from `glab:reviewer`'s whole
  set, as `reviewer.md` gives it — `SHIP`, `SHIP WITH SCOPE CUT: <what>`,
  `BLOCK: <n> issues` (`BLOCK: 1 issue` for one), `BLOCK: target unresolved`,
  `DO NOT PUBLISH: <why>` (the cut and the do-not-publish verdicts belong to
  the last round) — and for a `BLOCK: <n>` an n of at least 1 with at least
  n findings carrying a `rule:` line. The set is one fact in `reviewer.md`,
  the manager, `ship.md`, the script's validator and E34. Every
  reviewer message, the first and each `send`, says after the two report
  lines that inside the block every line starts at the left edge, and that
  the verdict line and each `rule:` line carry no backticks (E48 pins that
  sentence word for word; E34 pins the verdict set against `reviewer.md`).
- **The Codex developer role** (`feature-external-developer`, `glab`
  0.7.0; `[feature-external-developer/plan.md U1]`, U2, D1–D8):
  - **Who and when.** `--role developer` is Codex's only; OpenCode refuses
    it with exit 2 before anything is created, and stays read-only (D1).
    It runs only when Rule 5 has recorded an external developer for
    `glab:developer` — "develop on Codex", or "develop on Codex, <id>" —
    and `/glab:develop` then starts one `--role developer` agent in place
    of a `glab:developer`, with the same brief (the slug, the step ids,
    what was decided in chat). One agent: never split, never beside a
    `glab:developer`, since they share one working tree; a re-dispatch after
    `BLOCKED` or `PLAN WRONG` is a new agent, the old one stopped (D7). It
    edits the working tree directly, as `glab:developer` does: no patch and
    no apply step (U2).
  - **The sandbox** (D2). A developer turn asks for
    `sandbox_mode="workspace-write"` with
    `sandbox_workspace_write.network_access=false`,
    `sandbox_workspace_write.exclude_tmpdir_env_var=true` and
    `sandbox_workspace_write.exclude_slash_tmp=true`, and
    `approval_policy="never"`, in place of `read-only`; every other
    argument, and every other role's argv, is unchanged (E51, E72). Its
    commands can write in the repository and nowhere else: `/tmp` and
    `$TMPDIR` are excluded because `$TMPDIR` holds every agent's state, and
    there is no network. Measured with `codex sandbox` on the host, no
    model reached (M1–M4): the workdir writable; four writes outside it
    refused — a sibling directory, `HOME`, `$TMPDIR`, `/tmp`; five writes to
    `.git` refused; a TCP `socket()` and an AF_UNIX stream connect by path
    refused; datagram and abstract sockets not measured.
  - **The header check, exit 12** (D3). For a developer the header must
    say exactly `sandbox: workspace-write [workdir]` and `approval: never`
    — the string M5 measured on 0.163.0; anything else, an extra entry or
    ` (network access enabled)` included, is exit 12 `NOT READ-ONLY` with
    the reply withheld. Every other role must still say exactly
    `read-only`.
  - **The change report** (D4, revisions 3 and 4). Before and after each
    developer turn, `dev_state` records the state of the repository and the
    report prints what differs. Per path: the index (`ls-files -s -z`), the
    untracked files that are not ignored (`ls-files -o -z
    --exclude-standard`), and the ignored entries by name only (`ls-files -z
    -o -i --exclude-standard --directory`); each path's type, mode, size,
    times, inode and link target from one `find -files0-from - -maxdepth 0
    -printf`, which opens nothing; and the content hash of each regular file
    up to 16 MiB (`DEV_HASH_BYTES`), from one `hash-object --no-filters
    --stdin-paths` for all of them, each path C-quoted first; above the cap
    the kind is `big <mode> <size> <mtime> <ctime> <inode>`, so a sparse or
    huge file is never read, and a symlink is never opened. The codes:
    `??` untracked; `!!` ignored, by name only; ` D` tracked and missing;
    `--` a tracked regular file of at most 16 MiB whose hash and executable
    bit match its one stage-0 index entry, or a path no longer listed;
    ` M` every other tracked path, each tracked symlink and each tracked
    file above 16 MiB included, whatever it holds. `changed: none` when no
    path differs; `changed: unreadable`, always with `git: changed`, when
    the state after the turn could not be read in time. `git:` covers a
    digest of `.git`'s `HEAD`, the symbolic ref, the refs, the config as git
    reads it (`git config --includes --list -z`, so an ignored included
    file counts), the hooks, `info/`, the directory `core.hooksPath` names
    (read with plain `git config --includes --type=path`, taken relative to
    the top), and every `.git` below the top. **It never runs `git status`**,
    nor any filter, fsmonitor or hook: `git status` ran the repository's
    clean filters, and a submodule's fsmonitor, on the host (review r1 X1).
    Both snapshots run through `dev_snap` — `setsid timeout --kill-after=5
    <limit> bash -c`, the functions exported in that subshell only, the lock
    descriptor closed, the group carrying the agent's marker and killed when
    it ends and by `cleanup` — with the limit the turn's `--timeout`, at
    most 300 s (`DEV_STATE_S`). A before-state that cannot be read is exit
    4. The report says what changed once the turn is over; it prevents
    nothing. It does not see a write inside an ignored file or directory,
    other than in the `core.hooksPath` directory or a file the config
    includes, nor a change Codex itself makes outside its command sandbox
    to anything but what it lists and digests.
  - **The refusals** (R3.1, R3.2). A developer is refused — exit 2 at
    `start`, before anything is created, and 4 before each later turn — when
    the state root under `TMPDIR` is the repository's top or inside it
    (`realpath -e` of both, compared against `${t%/}`), because the work
    tree is the agent's one writable root and it could rewrite
    `state.before`, `run/stderr.txt` or an `agent.json` whose `cli` the next
    `send` runs unsandboxed; or when the work tree holds any `.git` other
    than `<top>/.git`, a directory or a gitfile — a submodule, a nested
    repository, most likely a `.git` inside an ignored dependency directory
    — because git run over it loads that repository's own config, which the
    agent can write, and Codex protects `<top>/.git` only. A developer
    `start` also runs `need_find`, `printf '.\0' | find -files0-from -
    -maxdepth 0 -printf x`, and exits 4 when it does not print `x`: an
    older `find` fails without a word and the report would miss every
    tracked-file edit. Since the review round 3 scope cut, `check` does not
    probe `find`, so no other Codex role depends on it.
  - **The first message** (D5, P3). The default profile's
    `## Developer, before the contract` section in place of
    *Before the contract*, whose "never to change anything" is right for
    every other role; the developer host text (it may change files in
    `<top>` and nowhere else, `/tmp` and `$TMPDIR` included; `<top>/.git`
    is not its own — never commit, stage, stash, switch branches, or change
    a ref, the config or a hook; the rest as the read-only host text); then
    `# Your role contract` with the body of `agents/developer.md`, both
    skills, `# Your dispatch` with the brief, `# Before you answer` and the
    profile's *After the contract*; then `developer_tail`, which every
    `send` appends too: do not write `plan/<slug>/result.md` — the final
    message is its content, with the Report block and verdict line — and a
    gate that fails because it cannot write outside the repository or start
    a sandbox of its own is "not run here:", not red. The section's heading
    does not start with `## Before the contract`, because `section()` finds
    a heading by its prefix. A Codex agent's profile is always `default`, so
    no family profile has the section.
  - **What the manager does with it** (D6, D8, R4.7, the scope cut). Any exit
    but 0, or `git: changed`, or a nested repository refused, stops the
    pipeline: the manager shows the user the `changed:` lines and reverts,
    commits or re-runs nothing on that tree — reverting would be destructive,
    the user's call. Only on 0 with `git: unchanged` does it inspect the
    change, before the gates, from the `changed:` lines alone and without a
    filter: for each tracked path named,
    `git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u -- - <path>`
    (`cat-file` applies no filter); each `??` and `!!` path that is a
    regular file it reads directly; it never opens a link or a path that is
    not a regular file — a link with `readlink`, anything else with
    `ls -l`; and it runs neither `git status` nor `git diff` on that tree
    before that check, since both can run a clean filter or an fsmonitor
    the agent planted. It then writes `result.md` from the agent's final
    message, marked as that model's words, with the `changed:`/`git:` lines
    and the gates it ran itself. A report missing fields gets one `send`;
    the agent is stopped once its report is read.
- **The test**, `tests/external-agent.test.sh`, runs a stub `opencode`
  (passed with `--cli`) inside the script's real sandbox and network
  namespace, starts two host-side listeners on kernel-picked ports and proves
  the sandbox cannot reach them, and runs a stub `codex` (passed with `--cli`,
  and as a symlink for E51) on the host, as the script runs Codex, with its
  `CODEX_HOME` under the test's work directory: `PASS 49/49` at `6838133`,
  `PASS 71/71` at `9108ac7` — E50–E71 are the Codex cases and E66 the
  OpenCode session check — and `PASS 84/84` at `33a28df`, E72–E84 the
  developer's cases (E27's role list changed too); E36 stays last. For the
  developer, the stub computes its header's `sandbox:` value from the argv
  as Codex does (`workspace-write [workdir`, plus `, /tmp` and `, $TMPDIR`
  unless excluded, `]`, plus ` (network access enabled)`), and its `dev-*`
  scenarios each run on a throwaway repository of their own. The Codex stub logs each call's
  argv, cwd, environment names and first stdin line, prints the header
  block of `feature-codex-agent` findings §9.2 with SGR around each key,
  and acts out a scenario (`ok`, `ro-net`, `ro-appr`, `nohdr`, `forge`, `newsess`, `sleep`,
  `late-flood-unmarked`, `stale` and others; `plan.md` P4). Its `sleep`
  scenario stands in for Codex's helper: a `setsid` child carrying the
  marker, outside the script's group kill. The test's `cleanup` kills the
  stub's recorded pids only after checking each one's environment. It needs a
  `bwrap` that can create namespaces, `slirp4netns` and `python3`; without
  them it is red, not skipped (`AGENTS.md` *Gates*).

## Isolation

The script header's list (owned there), each part with its reason, split by
backend since `feature-codex-agent` (`[feature-codex-agent/plan.md D1]`).
The guarantees each backend has are one fact in the script's header, the
skill, `README.md` and `glab:manager` Rule 6. Per backend, as the change
states them (`feature-codex-agent` findings §9.3; the network and tools
rows in revision 5's wording, `[feature-codex-agent/plan.md D25]` and the
skill's *What the script guarantees*):

| | OpenCode (unchanged) | Codex |
|---|---|---|
| runs | in the script's bwrap sandbox, on a verified copy | on the host, in the real repository, with its cwd at the top |
| sees | the copy: tracked and untracked-but-not-ignored files, the index, HEAD's tree only | everything the user can read: the repository with its history and ignored files, and files outside it (accepted) |
| writes | nothing: the copy is read-only, in a fresh `$HOME` | nothing in any file, by Codex's read-only sandbox. Codex itself writes its own state under `~/.codex` (sessions, logs, a token refresh), as it does for the user |
| network | its own namespace: internet only, no host or LAN | the commands have no IP network, and a connect to a Unix-domain socket by path was refused (measured offline with `codex sandbox`); datagram and abstract sockets not measured. Codex itself reaches OpenAI |
| login | the Go key in the sandbox, redacted | Codex's own. The script never reads it, so nothing is redacted, and a transcript holds whatever Codex printed |
| tools | `read glob grep shell`, no web | Codex's shell and file tools. Web search, apps, plugins, hooks, memories, the browser and computer tools, image generation and multi-agent are turned off; MCP only by ignoring the user's config (D4) |
| limits | files, processes, memory, `/tmp`, output caps, timeout | output caps (16 MiB each), timeout. Files, processes and memory are not limited by the script |
| checked | the copy against the real tree; the reviewer's report | the header block: `sandbox: read-only` and `approval: never`, the model and session id form-checked; the reviewer's report |
| state | `$TMPDIR/glab-external-agents/<id>/` with `work/`, `data/`, transcripts | the same directory without `work/` or `data/`; the session lives in Codex's own history under `~/.codex`, and `stop` does not remove it |

For a Codex developer (`feature-external-developer`) two rows differ:
*writes* — files in the repository, under Codex's `workspace-write`
sandbox; writes outside it refused at the four paths M2 tried, and five
`.git` writes refused (M1–M3); *checked* — the header must say
`workspace-write [workdir]` and `never`, and every turn is followed by the
change report. Its commands could not open a TCP socket, and a connect to a
Unix-domain socket by path was refused (M4); datagram and abstract sockets
not measured.

### OpenCode

- **The agent never sees the real repository.** It gets a copy of the working
  tree's tracked and untracked-but-not-ignored files, an index equal to the
  real one, and the tree of the real `HEAD` as one parentless commit: no
  other branch, tag, remote or older commit. Ignored files never leave the
  host — the user's own ignore rules decide what is never sent. Why: the
  copy is all the provider can receive, and history and other branches were
  never agreed to.
- **No git setting of the user's runs on the host.** The copy is built with
  git plumbing and tar only, under `GIT_CONFIG_GLOBAL=/dev/null`,
  `GIT_CONFIG_NOSYSTEM=1`, `GIT_OPTIONAL_LOCKS=0`, fsmonitor, the untracked
  cache and hooks switched off, every caller's `GIT_*` and `TAR_OPTIONS`
  unset; then it is compared byte for byte with the real tree (a mismatch is
  exit 4, nothing left). Why: porcelain runs textconv, external diff
  drivers, filters and fsmonitor that a config names, and plumbing alone
  still ran fsmonitor (*Measurements*, C2).
- **Paths that could be read as something else are refused**, not copied:
  absolute, with a `..` component, holding a control character, or under a
  symlinked parent directory. Every path list stays NUL-separated. Why: tar
  would read such a path from elsewhere, or as other names.
- **The copy is bound read-only, `.git` included**, and made unwritable on the
  host (`chmod -R a-w`): the agent can change nothing in it. It sees no
  `/home` but its own, no `/data`, no `/run`, no host `/tmp`, and no file
  descriptor of the caller's.
- **A new, empty `$HOME` every turn.** Only the backend's data directory,
  `~/.local/share/opencode` (the session database `send` continues), is kept
  from turn to turn; `~/.config/opencode`, the only config directory 2.0.31
  reads from `$HOME`, is an empty read-only mount in every turn. Why: a turn
  cannot leave config, plugins or agents for the next turn to load.
- **Its own network namespace**, wired to the internet by `slirp4netns` with
  host loopback disabled, `--enable-seccomp`, and blackhole routes for every
  private, CGNAT, link-local, documentation, benchmarking, multicast and
  reserved IPv4 range and for each of the host's own addresses (the
  `BLACKHOLES` constant lists them); no IPv6; the resolver is `slirp4netns`'s
  `10.0.2.3`, which asks the host's. No host socket is mounted. Without a
  working network the agent does not run (exit 9). Why: a shared network
  reached the user's own OpenCode service on host loopback and other local
  services (*Measurements*); `--disable-host-loopback` alone left the host's
  other addresses and the LAN open (N4); the sandboxed process cannot change
  its routes (N5). The agent does have the internet, because the backend
  needs its API, so anything it reads can be sent anywhere on the internet.
- **Limits per process**, owned by the script's constants: files up to
  64 MiB (`FILE_BLOCKS`), 4 GiB of data memory (`DATA_KIB`); 256 tasks in the
  sandbox's user namespace (`NPROC`); a 256 MiB `/tmp` (`TMP_BYTES`), the
  sandbox's own tmpfs; at most 16 MiB of the backend's stdout and of its
  stderr per turn reach the disk (`OUT_BYTES`), and a turn that writes more is
  cut at a line boundary and is exit 7. Total memory, and the disk the copy
  and its session use under `TMPDIR`, are not limited, and the README and the
  skill say so.
- **The key.** The OpenCode Go key is read on the host with `<cli> auth export
  opencode-go --standalone` (stdin `/dev/null`, from an empty directory),
  held in a shell variable, and exported only into the sandbox as
  `OPENCODE_API_KEY`, because the CLI needs it; the model can read it there
  and could send it out. It is never on a command line and never printed, and
  every literal occurrence is redacted from what the script writes or prints.
  The provider policy in the inline config allows OpenCode Go alone, so the
  paid provider the same variable unlocks cannot be used even by id.
- **The permission set is a second layer**: one agent, `glab-agent`, `* deny`
  with `read`, `glob`, `grep` and `shell` allowed, `external_directory`
  denied but `/tmp/*`; `update: disable`, `share: disabled`. The sandbox is the
  boundary, because `shell` is not path-checked.
- **Process lifetime.** `exec setpriv --pdeathsig KILL -- timeout … bwrap
  --die-with-parent …` as a direct child of the script, a holder with its own
  pdeathsig, `slirp4netns` tied to an exit FIFO, and a sandbox whose first
  command waits for the network and ends if the script is gone: nothing is
  left after an interruption or a kill; `list` shows a killed start as
  `broken` until `stop`.

### Codex

The user chose Codex to run as a Claude subagent does
(`[feature-codex-agent/questions.md Q2]`), so the copy, the bwrap sandbox and
its network do not apply to it:

- **It runs in the real repository and sees what the user can read**: the
  working tree with its history and its ignored files, and, through its
  commands, files outside the repository — credential files such as Codex's
  own login, SSH keys and cloud keys included. The user accepted that
  (`[feature-codex-agent/plan.md U2]`). Why: Codex handles its own login,
  which the bwrap sandbox's empty home would hide.
- **Codex's own read-only sandbox is the containment.** Every turn asks for
  `sandbox_mode` read-only and `approval_policy` never, and the header block
  is read back: another sandbox or approval is exit 12 and the reply is
  withheld (D5). Why: a managed config or MDM sits above the session flags
  and could override them (findings §9.2), so the flags alone are not
  trusted. `read-only` with no suffix also means the commands had no network
  (`sandbox_summary.rs`).
- **The user's config and rules are ignored** on every turn, and the tools
  that run outside Codex's command sandbox or reach past the repository are
  turned off (D4). Why: the user's own config could turn any of them on, or
  the sandbox off; `glab:reviewer`'s own tools have no web tool. With the
  user's trust entries ignored, the repository's `.codex/` layers stay off
  (D26). What Codex still loads from `CODEX_HOME` under
  `--ignore-user-config` — the login, `$CODEX_HOME/.env` (filtered of
  `CODEX_` names), global instructions and skills kept there — is the
  user's own, as a Claude subagent loads `~/.claude` (inferred, findings
  §9.8).
- **Its environment is an allowlist** (D13), because the manager's
  environment may hold Claude credentials.
- **Process lifetime**: D7's chain and group kill, and D31's marker and sweep
  by PID (*How it works now*). Why the sweep: Codex's sandbox helper and the
  commands under it start a session and group of their own, outlive the
  group kill and SIGTERM or SIGINT to Codex (findings §9.9), and killing the
  helper also ends every process in its PID namespace, so a command that
  unset the marker still ends with its helper (C2c).
- **Limits**: 16 MiB of its stdout and of its stderr per turn, and the
  timeout; files, processes and memory are not limited by the script, and
  nothing is redacted (D14).
- **A developer writes in the repository only**
  (`[feature-external-developer/plan.md D2]`): `workspace-write` with the
  network off and `/tmp` and `$TMPDIR` excluded. Why: without the two
  `exclude_*` keys its commands could write `$TMPDIR`, which holds every
  agent's state, `agent.json` and `run/stderr.txt` — which `codex_verify`
  reads — included. The same reason refuses a state root inside the
  repository (R3.1). The header check, not the flags, decides (D3). `.git`
  stays read-only under it (M3), so its commands cannot commit, stage or
  plant a hook; the change report digests `.git` anyway, because Codex
  itself is not sandboxed — only its commands are — and a nested `.git` is
  refused because git would load its config on the host (R3.2).
- **The change report runs nothing of the repository's** (R3.4): no
  `git status`, filter, fsmonitor or hook; it reads names, metadata and
  `--no-filters` hashes only, under a size cap and a time bound, so neither
  a filter the agent plants nor a huge or sparse file runs or hangs on the
  host. A breach is reported after the turn; the script does not prevent it.

## Measurements

What the script's comments cite, as measured for `feature-opencode-worker`
(rev 2's `findings.md` on OpenCode `1.19.3`, rev 3's `findings-r3.md` on
`2.0.31`; no model called, no real key used, a fake `HOME` and no network):

- **Hostile git settings (findings-r3 C2), which *Isolation* cites.** With the
  real repository's config naming a program for `core.fsmonitor`,
  `filter.evil.clean`/`smudge` (`.gitattributes`: `* filter=evil diff=evil`),
  `diff.evil.textconv` and `diff.external`, a global config adding
  `color.ui=always`, `diff.noprefix` and an `init.templateDir` with a hook,
  and the caller's `GIT_DIR` and `TAR_OPTIONS=--exclude=a.txt`, the copy was
  still exact and the program never ran on the host. Without
  `-c core.fsmonitor=false`, plumbing alone ran it: a mutant hung in
  `git … ls-files -s -z` with the hostile program as its child (the
  fsmonitor hook protocol). Hence every git call of the copy gets
  `-c core.fsmonitor=false` (E06, E07).
- **Config read from `$HOME`.** OpenCode `2.0.31` reads `~/.config/opencode`
  as its only config directory under `$HOME`, beside the inline
  `OPENCODE_CONFIG_CONTENT`; with the project switch set, a project config is
  gone too (findings-r3 R6). Hence the empty read-only mount on that path.
- **Data memory.** Under `ulimit -d` of 4 GiB and of `1 GiB` a turn completed;
  at `256 MiB` the CLI aborted (rc 134) (findings-r3 R15). Hence 4 GiB:
  binding without starving it; `ulimit -v` was rejected, since the CLI
  reserves address space it never touches.
- **Tasks.** Under `ulimit -u` 128 a turn with eight parallel shell children
  completed; at 64 it aborted (rc 134) (R15). `RLIMIT_NPROC` counts the
  sandbox's user namespace only: at a limit of 32, 30 forks succeeded inside
  while the user had 75 processes outside (C5). Hence 256.
- **The key's channel.** OpenCode `1.19.3` read `auth.json` and
  `OPENCODE_AUTH_CONTENT`; `2.0.31` ignores the latter (`strings` count `0`),
  keeps credentials in `opencode.db`, and prints them with `auth export`
  (findings-r3, the rev-2 table, and R5). Import from stdin and export did
  not write the key to `opencode.log`; an argument does get logged.
- **The paid provider.** `OPENCODE_API_KEY` is a credential for both
  OpenCode Go and the OpenCode Console (pay as you go); with it `models`
  lists 84 `opencode/` and 29 `opencode-go/` ids (R3). The policy
  `provider.use` deny `*`, allow `opencode-go` leaves only the Go ids, and
  `run -m opencode/big-pickle` fails `provider.no-route` (R4).
- **Nested namespaces.** bwrap `0.11.1` here puts the network namespace in an
  outer user namespace and the sandbox in an inner one (`NS_GET_USERNS` of the
  sandbox's netns returned the parent of its userns, findings-r3 N2), so
  `slirp4netns` attaches through a holder process in the outer one, found with
  `lsns` and checked (N3). bwrap inside bwrap cannot start here at all (rev 2
  P12).
- **Project config (rev 2's P4, re-proven on 2.0.31).** On `1.19.3`, with the
  agent defined inline, a project `opencode.json` merged in
  `external_directory: allow` and a project `.opencode/agent/<same name>.md`
  replaced the agent's prompt; with `OPENCODE_DISABLE_PROJECT_CONFIG=1`
  neither appeared (`git show 51043c4:plan/feature-opencode-worker/findings.md`,
  *Proven* P4). On `2.0.31` either `OPENCODE_DISABLE_PROJECT_CONFIG=1` or
  `OPENCODE_CONFIG_PROJECT_DISABLE=1` removes both (R6).
- **stdin.** `opencode run` reads a non-terminal stdin to its end: with stdin
  left open a run hung until `timeout`; with `</dev/null` it finished (the
  rev-2 table).
- **The shared network** of rev 2: `ss -ltnH` on the host showed the user's
  own OpenCode background service on host loopback, beside a message broker
  and two databases on loopback addresses and a web app on all addresses —
  all reachable from a shared network.
- **Other 2.0.31 facts** the script builds on (findings-r3 R2–R14): without
  `--standalone` a command uses or starts the background service; `--session
  <id>` continues with context, and an unknown id is created, not refused;
  `--thinking` sends reasoning events; `-f <file>` inlines the file; in a
  `shell` call the environment holds `OPENCODE_API_KEY`, so the model can
  read the key.
- **`slirp4netns` 1.3.3** (installed 2026-10-17, `libslirp` 4.9.1) works
  unprivileged, attached by path; `--enable-sandbox` failed unprofiled; pasta
  could not run here without its AppArmor profile (N1, N3, N7).

### Codex

As measured for `feature-codex-agent` on 2026-10-18, against Codex CLI
`codex-cli 0.163.0` (static-pie, at `~/.local/bin/codex`, a link into
`~/.codex/packages/standalone/current/`), with no model reached. Every run
used a throwaway `CODEX_HOME` and `HOME` with, where a login was needed, a
dummy `auth.json` of unsigned fake JWTs, and gave Codex a `TMPDIR` that is a
sibling of that `CODEX_HOME`, never its parent: Codex refuses to create its
helper links under its own temp dir (findings §3.1, §9.6). Vendor facts not
run were read from the source at tag `rust-v0.163.0` (findings §9.2, §9.8).

- **Codex's sandbox cannot start inside `bwrap --unshare-net` here**
  (integration round 1). With `kernel.apparmor_restrict_unprivileged_userns
  = 1`, AppArmor stacks `unpriv_bwrap` on a process under the outer bwrap,
  and a nested `/usr/bin/bwrap`, which Codex's Linux sandbox uses, cannot
  create its namespace (`bwrap: No permissions to create a new namespace`);
  `unshare --user --net` was refused at the uid map. On the bare host bwrap
  starts. So S1, O2 and `check`'s sandbox line were blocked inside the
  no-network wrapper — an environment limit, the same as rev 2's P12.
- **The user's allowance** (`[feature-codex-agent/questions.md stage-4]`):
  S1 and O2 ran on the host, without the no-network wrapper, with `codex
  sandbox -- <command>` only, no `exec` and no model, a throwaway
  `CODEX_HOME` and `HOME` and a fake `auth.json`; the commands inside have
  no network, and the Codex program itself might check for updates (not
  measured). It did not extend to `check`, `exec`, `debug models` without
  `--bundled`, or anything else that could contact OpenAI.
- **S1, Codex's read-only sandbox on this host** (integration round 2, on
  the host), `codex sandbox -c 'sandbox_mode="read-only"' -- <cmd>` in a
  throwaway repository: `true` rc 0; `sh -c 'echo x >>f'` rc 2, `Read-only
  file system`, no file; `cat /etc/hostname` rc 0, byte-identical to the host
  file (a read outside the repository); a TCP connect to a host listener on
  `127.0.0.1` rc 1, `socket: Operation not permitted`, while the same connect
  outside the sandbox succeeded. Pass; `-c sandbox_mode` maps to read-only.
  `socket()` itself got `EPERM`, so the refusal is inferred to be Codex's
  seccomp network filter. `check`'s exact sandbox command, run the way
  `codex_check` runs it (empty directory, the environment allowlist,
  `timeout 60`, stdin `/dev/null`), exited 0: `sandbox: read-only starts`.
- **The Unix-socket probe** (integration round 4, answering review r1 S1):
  inside `codex sandbox` (read-only), `connect()` to a host AF_UNIX stream
  socket by path was refused with `[Errno 1] Operation not permitted` and the
  listener saw no connection, while the socket file was visible inside and
  the same connect outside succeeded (the known positive). The user's session
  bus socket `/run/user/<uid>/bus` is visible inside; it was not connected
  to. Inferred: a seccomp rule on `connect()`. Not measured:
  abstract-namespace, `SOCK_DGRAM` and `SOCK_SEQPACKET` sockets,
  `socketpair`, and a descriptor passed in from outside. The approved wording
  (D25) states exactly the measured part.
- **O1, the offline run** (integration round 1, inside `bwrap --unshare-net`;
  *Offline run* holds its block and output): the real binary accepts every
  `--disable` name and `-c` key of the argv on `exec` and `exec resume`; the
  header block is as findings §9.2 gives it, on stderr, on both, with up to
  three log lines before it, inside the 20-line window, and no SGR seen;
  direct Codex with a trust entry loads the project's `project-model-x` (the
  known positive), and the script's turn names `gpt-6.1-sol` instead (D26);
  the session id is a UUID v7 and `exec resume <id>` printed the same id
  again; `login status` exits 0 for a dummy file login — so `login: stored`
  means "an auth file Codex parses", not "a valid login"; P2's jq program on
  `debug models --bundled` gives `default: gpt-6.1-sol (predicted)` and eight
  models; `check` stopped at exit 12 because of the AppArmor limit above.
- **O2, process lifetime** (integration round 2, on the host): D7's chain
  around `codex sandbox -- sleep 300`, its outermost `setpriv` SIGKILLed.
  `timeout`, the outer `codex` and `bwrap` were in the started group and
  died; the process under `bwrap` — Codex's sandbox helper, `comm=codex` —
  had its own session and group, was reparented to pid 1, and it and its
  `sleep` were still alive 2 s and 20 s later. Fail, `PLAN WRONG` for D7
  (*Incidents*).
- **The three candidates** (findings §9.9, `codex sandbox` only): SIGTERM to
  the started group, SIGTERM to the outer `codex`, and SIGINT to it — the
  helper and `sleep` were alive 5 s and 10 s later each time: fails. A marker
  exported only stops at `bwrap` under `inherit="core"` (C2a); passed only
  through `-c shell_environment_policy.set…` it reaches `bwrap`, the helper
  and the command (C2b); through both channels all five processes carried it
  and a sweep by PID left none alive (C2); killing only the helper also ended
  the `sleep` (C2c). A `systemd-run --user --scope` per turn also left none,
  but needs a running systemd user manager and its D-Bus session. Neither
  survives the script itself being SIGKILLed, hence the sweep at `stop`.
- **O2 reruns.** Round 3 (revision 4) and round 5 (revision 5) reran O2 with
  the marker on both channels and `sweep_agent` copied byte for byte from
  the built script (round 5: `sweep_agent`, `environ_has` and `proc_start`,
  29 lines, with their `sha256sum` recorded): the known positive reproduced
  the defect — the helper (ppid 1) and `sleep` alive and marked 2 s after the
  kill — and 1 s after `sweep_agent` no recorded pid was alive and no process
  carried the marker. Pass, both times.
- **The catalog and the login, offline** (findings §9.8, the one allowed
  offline run of `codex debug models --bundled`, inside `bwrap
  --unshare-net`): one object `{"models": [ … ]}`, each model with `slug`,
  `visibility` (`list` or `hide`), a numeric `priority`, and
  `supported_reasoning_levels` as an array of `{"effort", "description"}`
  objects; not sorted by priority. `login status` printed `Not logged in`,
  rc 1. From source, it prints to stderr and exits 0 for every logged-in
  mode, 1 otherwise. Without `--bundled`, `debug models` refreshes the
  catalog over the network.
- **Other 0.163.0 facts the adapter builds on** (findings §3.2, §9.2,
  §9.7, §9.8): the JSONL stream never names the model, while the human header
  block does; `--color` exists on `exec` but not on `exec resume`; a resume
  whose id resolves to nothing silently starts a new thread; any error event
  makes `exec` exit 1; the default model is the first picker-visible model by
  priority; `login status`, `sandbox` and `debug models` take no
  `--ignore-user-config`; a `-c` key is split at the first `=` and walked at
  every `.`, never TOML-parsed, so it cannot name a project by its path;
  projects are untrusted unless a non-project config marks them trusted;
  util-linux `setsid` 2.41.3 does not fork from a background subshell of a
  non-interactive bash, so the group id is the started pid; the installed
  `timeout` is uutils coreutils 0.10.0, whose group handling is not relied
  on.

### Codex developer

As measured for `feature-external-developer` on 2026-10-18 at Stage 4
(`integration.md`, `INTEGRATED`), against `codex-cli 0.163.0`, no model
reached. Allowances (`[feature-external-developer/questions.md approval]`):
M1–M4 ran as `codex sandbox …` on the host, under the standing `codex
sandbox` allowance of `feature-codex-agent`; M5 was one real developer
`start` inside `bwrap --dev-bind / / --unshare-net --die-with-parent` — an
offline run under `AGENTS.md`'s rule. Each run had a fresh throwaway
directory with `CODEX_HOME` holding only O1's fake `auth.json`, a throwaway
`HOME` and Codex `TMPDIR`, and a throwaway repository with one commit; the
real `~/.codex` was not read, listed or written, no `login`, no `exec` with
network; every listener was killed by its pid. M3 used `hostgit`,
`dev_state` and `dev_git` copied from the working tree of that time
(34 lines, their `sha256sum` recorded) — the revision-2 functions.

The command for M1–M4, `WW`, from `cd` into the repository:
`env -i PATH=… HOME=… CODEX_HOME=… TMPDIR=… "$CX" sandbox -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -c 'sandbox_workspace_write.exclude_tmpdir_env_var=true' -c 'sandbox_workspace_write.exclude_slash_tmp=true' -- <cmd>`;
`RO`, the M1b control, the same with only `-c 'sandbox_mode="read-only"'`;
`WWX`, the M2b control, `WW` without the two `exclude_*` keys. The plan's
first `WW` also passed `-C "$X/r"`, which `codex sandbox` 0.163.0 takes
only together with `-P/--permission-profile`: every call exited 2 with a
usage error and nothing was written (round 1). The script never passes
`-C`, so that was the plan's measurement command, not the build.

- **M1, the mode switch.** Under `WW` a new file and an edit of a tracked
  file succeeded (rc 0; `git status` showed ` M README` and `?? f`); under
  `RO` both failed with `Read-only file system`, nothing changed (the
  control). Pass.
- **M2, writes outside the workdir.** Under `WW`, writes to a directory
  beside the repository, to the throwaway `HOME`, to Codex's `TMPDIR` and
  to `/tmp/<unique name>` each failed, rc 2, `Read-only file system`, none
  existing after. Under `WWX` the `TMPDIR` and `/tmp` writes succeeded
  (removed afterwards): 0.163.0 honours the two `exclude_*` keys rather than
  ignoring them. Pass.
- **M3, `.git` under workspace-write: `.git` is blocked.** Appending to
  `.git/config` and creating `.git/hooks/pre-commit` were refused (rc 2,
  `Read-only file system`); `git commit --allow-empty`, `git update-ref
  refs/heads/x HEAD` and `git add f` failed (rc 128, unable to create the
  `.lock`, `Read-only file system`); the `dev_state` `git` digest and
  `HEAD` were the same before and after. With the workdir as the only
  writable root, `.git` inside it stays read-only — Codex's documented
  protection of `<writable_root>/.git`. So a developer's commands cannot
  commit, stage or plant a hook; inferred, a developer turn's own `git add`
  fails too, which the contract (never stage) does not need. Recorded as
  the answer to U2/D4's question; the build was right either way, since the
  docs say only that a change to `.git` is reported.
- **M4, the network under workspace-write.** A TCP connect to a `python3 -I`
  listener on host `127.0.0.1` was refused at `socket()` (`PermissionError:
  [Errno 1] Operation not permitted`), and an AF_UNIX connect to a listener
  by path at `connect()` (EPERM); each listener counted +0 inside and +1 for
  the same connect outside (the control). Pass.
- **M5, one offline developer `start`.** Inside the no-network wrapper
  (`netns: lo routes=0`, `connect 1.1.1.1:443 rc=1`): `start --backend codex
  --role developer` ended rc 7, `BACKEND ERROR: workspace routing discovery
  failed`; stdout held the header line (`model: codex:gpt-6.1-sol`),
  `changed: none`, `git: unchanged` and `end:`. The real header block:

  ````text
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
  ````

  `cat -A` of the sandbox line showed `sandbox: workspace-write [workdir]$`,
  no trailing byte: exactly the string `codex_verify` wants for a
  developer, the `/tmp` and `$TMPDIR` entries absent because the keys are
  set, as F2 inferred from Codex's source. Not rc 12, so D3 held. The first
  message in `transcript.log` was the developer text, the developer contract
  after it; `stop` printed `stopped:`; afterwards no process carried the
  marker and the repository's `HEAD` and status were unchanged; the kept
  transcript held no `eyJ` and no unmasked home path.

## Allowlist

Owned by `opencode_models()` in the script, one line per model —
`<model id> <profile> <last day it may be used, or ->`. As of `6838133`:

| model id | profile | last day |
|---|---|---|
| `opencode-go/kimi-k3` | `kimi` | — |
| `opencode-go/kimi-k2.7-code` | `kimi` | — |
| `opencode-go/glm-5.3` | `glm` | — |
| `opencode-go/glm-5.3-flash` | `glm` | — |
| `opencode-go/glm-5.2` | `glm` | — |
| `opencode-go/deepseek-v4-pro` | `deepseek-pro` | 2026-10-31 |
| `opencode-go/deepseek-v4.1-flash` | `deepseek-flash` | 2026-10-31 |

- **Source**: the OpenCode Go page, <https://opencode.ai/docs/go/>, read
  2026-10-16. Every line is a model the page lists with training "Not used"
  and retention "0 days". DeepSeek's zero-retention agreement "is renewed
  monthly" and is "valid through October 31, 2026", hence its end date: past
  it the script refuses the model (exit 5) until someone re-reads the page and
  moves the date — a one-line change and a version bump. A model outside the
  list is refused (exit 5), and an id outside `opencode-go/` could reach the
  paid provider.
- [feature-opencode-worker/questions.md Q1] The user chose option A on 2026-10-16: Kimi K3, Kimi K2.7 Code, GLM-5.3, GLM-5.3-Flash and GLM-5.2 with no end; DeepSeek V4 Pro and V4.1 Flash until `2026-10-31`, enforced by the script; **Grok 4.7 refused**, because its provider keeps prompts for `30 days` ("ZDR disables important API features that depend on stored data"). Test case E29 pins the refusal; no Grok profile ships.
- **DeepSeek is refused upstream** on this user's workspace: both models
  failed before their first turn with `This Go model requires Global regions.
  Select Global in your workspace's Privacy settings to use it.` (probe
  finding 3). That is a data-region choice in the user's OpenCode workspace;
  the user left it as is and the allowlist unchanged
  (`[fix-probe-findings/plan.md decision-2]`).
- The allowlist and its end dates are one fact in the script, its test, the
  profiles its lines name, and `README.md` (`AGENTS.md` *One fact*).
- **Codex has none** (`[feature-codex-agent/questions.md A2]`, D6): the
  user allowed every Codex model. The script checks only the id's form,
  because it goes on argv, and refuses `default`; there are no end dates.
  That Codex has none, checks an id's form only and refuses `default` is one
  fact with the OpenCode allowlist (the script, E58, the skill, `README.md`).
  What the retention terms were for OpenCode, the user's ChatGPT account's
  data controls are for Codex, which the script cannot see: the data note
  (`[feature-codex-agent/questions.md Q7]`).

## Profiles

- **What a profile is.** A file per model family under
  `plugins/glab/skills/external-agents/profiles/` — `default`, `kimi`, `glm`,
  `deepseek-pro`, `deepseek-flash` — chosen by the allowlist line. `default`
  is the base every agent gets; a family profile adds to it. Only its
  `## Before the contract` and `## After the contract` sections are sent, on
  an agent's first turn (`section()` and `first_prompt` in the script; E20
  checks a profile's notes are never sent); `## Notes` is for whoever edits
  the profile. A profile states no invented quirk: a per-model claim is
  UNVERIFIED until a run shows it.
- **Codex uses the `default` profile only**
  (`[feature-codex-agent/plan.md D16]`); no Codex profile has been tuned
  from real replies (`[feature-codex-agent/plan.md not-in-plan-4]`).
- **`default.md` has a third sent section, for a developer**
  (`[feature-external-developer/plan.md D5]`):
  `## Developer, before the contract` — "You are an external developer in
  the glab workflow … to build the plan steps your dispatch names, by
  changing files in the repository you work in, and nothing else" — sent in
  place of *Before the contract* to a `--role developer` agent only, which
  only Codex runs, so only this profile has it. *Before the contract* is
  unchanged, "never to change anything" included; *After the contract* is
  sent to a developer unchanged. The profile's intro names the third section,
  and its *Notes* say why the heading does not start with
  `## Before the contract`: `section()` matches a heading by its prefix, so
  such a heading would reach every other role too. The user approved the
  section as quoted (`[feature-external-developer/questions.md revision-2]`).
- **Where each was tuned from.** `default` was written for read-only work in
  rev 3. The four family profiles were tuned from the user's notes on
  prompting each family and a comparison table, which another model (Qwen)
  wrote as fill-in templates in a documentation style — secondary advice, not
  observed. Each profile's *Notes* says what was taken (tone, `file:line`
  with a short quote for claims about the code, a silent self-check) and
  what was left out (the notes' own answer shapes, visible thinking blocks,
  tool-calling directives, placeholders, every architecture or cost claim).
  `fix-external-report-lines` narrowed Kimi's "every claim names its
  `file:line`" to claims about the code, and GLM's "then act" to "then
  answer".
- **The notes** stay in history (`questions.md` of `feature-docs-specs`,
  Q1 = A): `git show 51043c4:plan/feature-opencode-worker/notes/kimi.md`,
  `git show 51043c4:plan/feature-opencode-worker/notes/glm.md`,
  `git show 51043c4:plan/feature-opencode-worker/notes/deepseek-pro.md`,
  `git show 51043c4:plan/feature-opencode-worker/notes/deepseek-flash.md`,
  and the comparison table
  `git show 51043c4:plan/feature-opencode-worker/notes/diff.md`.
- **Not yet tuned from real replies**: `[feature-opencode-worker/follow-ups.md 12]` — the live probe captured Kimi and GLM replies, but only with these profiles, so nothing compares a reply without one; the transcripts are at `git ls-tree -r --name-only 51043c4 -- plan/feature-opencode-worker/probe-r3/`.

## Decisions that still bind

- [feature-opencode-worker/questions.md Q1] The allowlist is the user's option A: Kimi and GLM with no end, DeepSeek until 2026-10-31 enforced by the script, Grok refused (*Allowlist*).
- [feature-opencode-worker/questions-r3.md Q2] A: the external reviewer wiring stays — each review round of Stage 5, `/glab:review` and `/glab:ship` can run as a new read-only external agent whose report is the round's report, so that model's `SHIP` can lead to a commit through `/glab:ship`; the gates and the push go-ahead do not change (the user, at plan approval, 2026-10-17).
- [feature-opencode-worker/findings.md U1] Manual only: an external agent is used only when the user says so, naming the model; no file turns it on; no silent fallback either way — unavailable or over its limit means stop and report (the user's).
- [feature-opencode-worker/findings.md U2] Developer and reviewer only — narrowed by `[feature-opencode-worker/plan-r3.md U10]` to the reviewer only (the user's).
- [feature-opencode-worker/findings.md U3] The user talks to the manager, not to commands; the choice is carried into every dispatch of the role and recorded where it survives a compaction (the user's).
- [feature-opencode-worker/findings.md U4] Codex comes later, so the contract is backend-neutral: a new adapter, not a rework (the user's).
- [feature-opencode-worker/findings.md U5] Each model gets the framing it needs: a per-model profile separate from the per-backend adapter, a `default`, the reply validated against the role's contract, no invented quirks (the user's).
- [feature-opencode-worker/findings.md U6] Model scope: the Kimi, Grok, DeepSeek and GLM families only; a model outside the allowlist refused with a named exit; retention or training by a provider is the one Rule 3 question — answered as Q1 (the user's).
- [feature-opencode-worker/plan.md U1] Rev 2's restatement of the user's U1 (manual only), carried.
- [feature-opencode-worker/plan.md U2] Rev 2's restatement of U2 (developer and reviewer), carried as narrowed by plan-r3 U10.
- [feature-opencode-worker/plan.md U3] Rev 2's restatement of U3 (the user tells the manager), carried.
- [feature-opencode-worker/plan.md U4] Rev 2's restatement of U4 (backend-neutral, Codex later), carried.
- [feature-opencode-worker/plan.md U5] Rev 2's restatement of U5 (profiles separate from adapters; validated read-back; no invented quirks), carried.
- [feature-opencode-worker/plan.md U6] Rev 2's restatement of U6 (Kimi, Grok, DeepSeek Pro and Flash, GLM only), carried with Q1's answer.
- [feature-opencode-worker/plan-r3.md U1] Manual only; no file turns it on; no silent fallback (carried from rev 2).
- [feature-opencode-worker/plan-r3.md U2] Developer and reviewer — narrowed by U10: the reviewer only.
- [feature-opencode-worker/plan-r3.md U3] The user tells the manager — narrowed with U2 by U10.
- [feature-opencode-worker/plan-r3.md U4] Backend-neutral contract; Codex later as an adapter.
- [feature-opencode-worker/plan-r3.md U5] Per-model profiles, separate from adapters; no invented quirks.
- [feature-opencode-worker/plan-r3.md U6] The allowlist of Q1, option A.
- [feature-opencode-worker/plan-r3.md U7] An external agent works like a background subagent, as the manager's tool: `start` (a brief, a named model, its own sandboxed read-only copy; returns an id and the reply), `send <id>` (the same session, context kept), `list`, `stop <id>` (removes its workspace and session data).
- [feature-opencode-worker/plan-r3.md U8] Usable in the background: the manager runs a call as a background shell command and is told when it exits.
- [feature-opencode-worker/plan-r3.md U9] The user can see how models work: each agent's transcript, key redacted, readable until `stop`, the model shown with every reply.
- [feature-opencode-worker/plan-r3.md U10] Read-only work only: no patch is produced or applied; the external developer is dropped until gates can be sandboxed, because applying an external patch runs untrusted code on the host through the gates.
- [feature-opencode-worker/plan-r3.md U11] Manual only, as U1: the user says when and which model; the manager never starts one on its own and never falls back silently.
- [feature-opencode-worker/plan-r3.md U12] Backend-neutral names and an adapter boundary, so Codex is a new adapter later.
- [feature-opencode-worker/plan-r3.md V1] The sandbox has its own network namespace, internet only, no host service or socket; a named exit when that is unavailable (9); the README says how to install it (required by the review of rev 2).
- [feature-opencode-worker/plan-r3.md V2] A copy no git setting can change or use to run code on the host, verified against the real tree; every command checked, one stderr line per failure.
- [feature-opencode-worker/plan-r3.md V3] Nothing is left after an interruption or a kill.
- [feature-opencode-worker/plan-r3.md V4] Model text is untrusted: control characters stripped, forged lines impossible, no path from it acted on.
- [feature-opencode-worker/plan-r3.md V5] Process and memory limits, or a plain statement of what is not limited.
- [feature-opencode-worker/plan-r3.md V6] The key on no command line, never printed, redacted from transcripts.
- [feature-opencode-worker/plan-r3.md V7] Every OpenCode fact re-verified on the installed 2.0.31; the binary's path taken explicitly.
- [feature-opencode-worker/plan-r3.md V8] Say per rev-2 file what is kept, changed or dropped (`findings-r3.md`, *Kept, changed, dropped*).
- [feature-opencode-worker/plan-r3.md D23] Names: `plugins/glab/scripts/external-agent.sh`, the skill `glab:external-agents` with its `profiles/`, `tests/external-agent.test.sh`.
- [feature-opencode-worker/plan-r3.md D24] The network is `slirp4netns`, attached by path through a holder in the namespace's owner (found with `lsns`, checked), `--disable-host-loopback`, `--enable-seccomp`, `--exit-fd` tied to the script, blackhole routes, no IPv6, the resolver `10.0.2.3`; any step failing is exit 9 and the agent does not run. pasta rejected; `--enable-sandbox` not used.
- [feature-opencode-worker/plan-r3.md D25] The key is read with `auth export opencode-go --standalone`, held in a shell variable, exported only into the sandbox as `OPENCODE_API_KEY`, redacted line by line before it reaches the disk; the provider policy allows OpenCode Go alone.
- [feature-opencode-worker/plan-r3.md D26] The 2.0.31 config in native keys: one agent `glab-agent`, `* deny`, allow `read glob grep shell`, `external_directory` deny but `/tmp/*`, `update: disable`, `share: disabled`, the project-config, Claude-Code, autoupdate, models-fetch and filewatcher switches; argv `run <message> --standalone --format json --thinking -m <model> --agent glab-agent (--title <label> | --session <id>) -f …`, stdin `/dev/null`; `--session` only with the id read back from the first turn.
- [feature-opencode-worker/plan-r3.md D27] The copy: git plumbing and tar only, under the isolated git environment, the user's `core.excludesFile` carried as a value, verified afterwards, `chmod -R a-w`, bound read-only.
- [feature-opencode-worker/plan-r3.md D28] The output: the `agent:` header, `reply:`, `| ` before every reply line, `end: <id>` last; C0 (but tab and newline), DEL, C1, zero-width and bidirectional controls removed.
- [feature-opencode-worker/plan-r3.md D29] The exit codes 0, 2–11 as listed in *How it works now*; rev 2's 9 and 10 never shipped, so the numbers were reused.
- [feature-opencode-worker/plan-r3.md D30] State under `$TMPDIR/glab-external-agents/<id>/`, mode 700; an id is `ea-` and 16 hex digits and the only way to a path; `agent.json` is written by the script only, outside the sandbox.
- [feature-opencode-worker/plan-r3.md D31] One turn at a time per agent (`flock`); `stop` signals the running turn after checking its start time, waits up to 30 s, then removes the agent.
- [feature-opencode-worker/plan-r3.md D32] Process lifetime: `exec setpriv --pdeathsig KILL -- timeout … bwrap --die-with-parent …` as a direct child; the holder with its own pdeathsig; `slirp4netns` on an exit FIFO; the sandbox's first command waits for the network and ends if the script is gone.
- [feature-opencode-worker/plan-r3.md D33] Limits: files 64 MiB, `/tmp` 256 MiB, 256 tasks in the sandbox's user namespace, 4 GiB data per process (since joined by the 16 MiB per-stream output cap); total memory and the disk under `TMPDIR` are not limited, and the README and skill say so.
- [feature-opencode-worker/plan-r3.md D34] The external reviewer stays, the external developer goes: Rule 5's external choice applies to `glab:reviewer` only; each round is a new `--role reviewer` agent whose report the script validates (exit 8); the one correction is a `send`, which keeps the context. Decided by the user as Q2 = A.
- [feature-opencode-worker/plan-r3.md D35] `glab:manager` has Rule 6, the general rule for external agents: only on the user's word, the reply untrusted, it changes nothing, stop what you start.
- [feature-opencode-worker/plan-r3.md D36] Carried from rev 2: every backend error is exit 7 with its message, no limit-text matching; `TMPDIR` required; 3600 s per turn by default (`--timeout` overrides); the allowlist and end dates in the script only, payload prose naming no model id (the profiles' *Notes* have since named the probe's ids); the version raised on the change.
- [feature-opencode-worker/plan-r3.md D37] The CLI path is explicit (`--cli`), resolved and stored per agent; the script never looks the CLI up on `PATH`; the skill names `~/.opencode/bin/opencode`.
- [feature-opencode-worker/plan-r3.md D38] The test needs a real bwrap and a real `slirp4netns`; without them it is red, not skipped.
- [feature-opencode-worker/plan-r3.md M2] Every external agent carries what every dispatch carries: its first message tells it to read the repository's `AGENTS.md` first (`CLAUDE.md`, saying so, when there is none) and holds `glab:security` and `glab:comments`, for both roles (E20, E21).
- [feature-opencode-worker/plan-r3.md spent] D22, D39, D40, D41, M1, M3, M4, M5 — the clean restart from `889b804` and the slice order were that build's; the records were committed and now live in history; the live probe has run (*Live runs*); the README sentence and its gate line were replaced by `[fix-probe-findings/plan.md decision-3]`; the user answered Q2; `slirp4netns` was installed; the Stage 1b notes were closed in that plan.
- [feature-opencode-worker/plan.md D1] Isolation is a bubblewrap sandbox around a disposable copy; OpenCode's permission set is the second layer, not the boundary.
- [feature-opencode-worker/plan.md D2] The external choice is a form of Rule 5's choice: the same `- model:` line naming the backend, shown as `model <backend>:<model>`; no second rule.
- [feature-opencode-worker/plan.md D4] Adapters are function sets inside the one script, called as `${backend}_<name>`, with one `case` line per backend; not separate sourced files.
- [feature-opencode-worker/plan.md D17] No Grok profile ships: with Q1's answer no allowlist line can name it; adding Grok later is its allowlist line plus a profile.
- [feature-opencode-worker/plan.md D20] `AGENTS.md` has a rule: never run the external-agent script against a real model from this repo, the user's live probe excepted — the twin of the `memory-sync.sh` rule.
- [feature-opencode-worker/plan.md M2] The copy holds only `HEAD`'s tree, as one parentless commit, plus the staged, unstaged and untracked-not-ignored changes: no other branch, tag, remote-tracking ref, remote or older commit; a reviewer's branch or range target therefore cannot resolve, and the skill says to tell the user.
- [feature-opencode-worker/plan.md M4] No date override variable: the script reads `date -u +%F`, and the test crosses the end date with a `date` stub first on `PATH`.
- [feature-opencode-worker/plan.md M12] Stage sessions: an external reviewer means the review session runs the script itself; `claude --model` is for Claude aliases only.
- [feature-opencode-worker/plan.md M14] The README states the data exposure: what is sent, which families may receive it, DeepSeek until 2026-10-31, Grok refused; it is one fact with the allowlist.
- [feature-opencode-worker/plan.md spent] D3, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16, D18, D19, D21, M1, M3, M5, M6, M7, M8, M9, M10, M11, M13, M15, M16, M17 — rev 2's build was archived and replaced by rev 3 (`plan-r3.md` D22): its names, profile directory, patch path, exit 9 and 10, fresh re-dispatch, shared network, test cases, slices, back-out and two-block probe are gone; what rev 3 kept is carried as plan-r3 D29, D33, D36 and D40.
- [feature-opencode-worker/findings.md spent] D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16 — the planner's decisions of rev 2's findings, restated under the same numbers in rev 2's `plan.md`; what still binds is carried there.
- [fix-external-report-lines/plan.md D1] The left-edge sentence goes in `reviewer_tail`, after the two report lines and before the Report section, so the model reads the rule before the indented template; the validator is not loosened for indents or backticks.
- [fix-external-report-lines/plan.md D2] Kimi's *Before the contract* is narrowed too: every claim about the code, not every claim, names its `file:line`.
- [fix-external-report-lines/plan.md D4] A case of its own, E48, reads only the manager's text, for a start and a send, checks the order report end < the sentence < the Report section, and pins the sentence word for word.
- [fix-external-report-lines/plan.md D6] The sentence, word for word: "Inside the block, every line starts at the left edge, with no indent, even where the Report section below shows one. The verdict line and each rule: line carry no backticks, and the verdict line stands alone, with nothing else on it."
- [fix-external-report-lines/plan.md spent] D3, D5 — leaving the skill unedited and updating the profiles' *Notes* were choices for that change, both done.
- [fix-probe-findings/plan.md decision-1] The reviewer's verdict check accepts `BLOCK: 1 issue` besides `BLOCK: <n> issues` (the user's).
- [fix-probe-findings/plan.md decision-2] DeepSeek is left as is: the workspace region is not switched, the allowlist does not change (the user's).
- [fix-probe-findings/plan.md decision-3] The README sentence states what the live probe showed and did not, and the gate line, its *Green is* bullet and the one-fact entry change with it, so a pinned phrase is gated (the user's).
- [fix-probe-findings/plan.md D1] The singular for one only: `BLOCK: 1 issue`, not `BLOCK: [0-9]+ issues?`; the `sed` gets its own whole-line expression, so a singular without findings is still caught.
- [fix-probe-findings/plan.md D2] One fact: `reviewer.md` keeps `BLOCK: <n> issues` as the form and says `BLOCK: 1 issue` is the same verdict; `ship.md` names both; E34 pins the singular in `reviewer.md` and the script's set.
- [fix-probe-findings/plan.md D3] The pinned phrase `Not yet shown: any reply from a DeepSeek model`, on one line; the sentence lists every hedge of the probe's *Not verified*.
- [fix-probe-findings/plan.md D5] A case of its own, E49, with three stub scenarios (`rev-one`, `rev-one-bare`, `rev-two-singular`).
- [fix-probe-findings/plan.md spent] decision-4, decision-5, decision-6, D4 — the `0.4.2` bump, the masking of the probe's host values (done, and recorded in the probe record), the order of the records and fix commits, and the factual correction of the profiles' *Notes*, all done in that change.
- [feature-docs-specs/plan.md D6] The offline run and the live-run procedure live in this spec, *Offline run* and *Live runs*, their blocks copied byte for byte from the records; the runner stays a block the user saves and runs as a script, not a tracked file, because an executable that calls a real model would sit in the tree with no gate over it.
- [feature-docs-specs/questions.md Q1] A: the user's prompting notes went with `feature-opencode-worker`'s folder and stay in history at `51043c4`; *Profiles* and each profile's `## Notes` cite them there (the user's, 2026-10-17).
- [feature-codex-agent/questions.md A1] The user logs in to Codex themselves; the script uses that existing login, so Claude drives Codex as a subagent — no separate API key (the user's, 2026-10-18).
- [feature-codex-agent/questions.md A2] All Codex models are allowed and the user names the model; by default the latest, at the main session's reasoning effort — made exact by Q5 = B and Q6 = A (the user's).
- [feature-codex-agent/questions.md A3] The user's plan needs no "Use balance"-style check for Codex; live runs still only on the user's explicit instruction in chat; `AGENTS.md`'s live-run exception keeps "Use balance" for OpenCode only (the user's).
- [feature-codex-agent/questions.md A4] Codex is to be usable as a developer subagent too — it overturns `[feature-opencode-worker/plan-r3.md U10]` and D34 for the next change; this change is read-only, by Q1 = A (the user's).
- [feature-codex-agent/questions.md Q1] A: two changes — this one, Codex as a read-only general or reviewer backend (`glab` 0.6.0), then the developer role (0.7.0), planned once this one exists (the user's, 2026-10-18).
- [feature-codex-agent/questions.md Q2] Q2 and Q3 replaced by one answer: Codex runs like a Claude subagent — on the host, in the user's repository, under Codex's own sandbox (read-only here; workspace-write in the working tree in the developer change), with its own login; the script never copies, reads, exports or redacts a token, nor writes `~/.codex`; Codex's commands can read files outside the repository and what it reads can reach OpenAI, accepted; login mechanisms L1–L4 and developer designs D-A–D-C not chosen (the user's).
- [feature-codex-agent/questions.md Q4] A, for the developer change: same trust as a Claude developer — the manager reads the whole change before the gates, then Stages 3 to 5 as usual (the user's).
- [feature-codex-agent/questions.md Q5] B: Codex's own default — no `--model` when the user names none; the script reads back the model that ran, form-checked; the model can change between rounds, accepted (the user's).
- [feature-codex-agent/questions.md Q6] A: `CLAUDE_CODE_EFFORT_LEVEL` when set, otherwise the manager asks once per session and records the answer with the model line; mapping (i), the highest supported level not above the requested one, said in the announce line (the user's; (i) stated by the manager and not objected to).
- [feature-codex-agent/questions.md Q7] A: a one-time data note in the README and the skill — what Codex reads goes to OpenAI under the user's ChatGPT account's data controls; check "Improve the model for everyone" (the user's).
- [feature-codex-agent/questions.md approval] The user approved `plan.md` on 2026-10-18 ("Approve, build it").
- [feature-codex-agent/questions.md stage-1b] After Stage 1b round 2/2 left five blockers, the user chose to fix them and run one narrow third check of those fixes only, beyond the two-round cap, and allowed one offline `codex debug models --bundled` run with a throwaway `CODEX_HOME` and no network (the user's, 2026-10-18; *Incidents*).
- [feature-codex-agent/questions.md stage-4] The user's Stage 4 allowance: S1 and O2 on the host without the no-network wrapper, `codex sandbox -- <command>` only, a throwaway `CODEX_HOME` and `HOME` and a fake `auth.json`; not `check`, `exec`, `debug models` without `--bundled`, or anything that could contact OpenAI. After O2 failed, the user chose "measure, then amend the plan", and approved revision 4 (D31) on 2026-10-18 ("Approve, build it").
- [feature-codex-agent/questions.md review-r1-fixes] The user approved revision 5, which adopts review round 1's fixes — the reworded data note, identical in README and skill; exit 12's approval clause and the README's Codex paragraph; the `models: unavailable` effort fallback; `cmd_stop` sweeping unless a sandbox backend is named, the second pass only after a kill, `mapfile -d ''`, the filtered and cleaned catalog, `default` refused, E70 — and the tightened socket sentence of security review round 2's advisory A, in every place that states it (the user's, 2026-10-18).
- [feature-codex-agent/questions.md revision-6] The user approved revision 6, which records the tests as built — 71 cases, E70 and E71 as review r2's R2-1 split them, the scenario table, the coverage list with `cleanup`'s `host_turn` sweep uncovered — and changes no code and no docs (the user's, 2026-10-18).
- [feature-codex-agent/plan.md U1] Q1 = A: this plan is the read-only Codex backend only; the developer role is a later plan.
- [feature-codex-agent/plan.md U2] Q2/Q3: Codex runs like a Claude subagent, on the host, in the user's repository, under Codex's own read-only sandbox, with its own login; the script never copies, reads, exports or redacts a token, and never writes `~/.codex`; reads outside the repository and their reaching OpenAI accepted; OpenCode's guarantees stay in force for OpenCode.
- [feature-codex-agent/plan.md U3] Q4 = A, for the developer change: the manager reads the whole change before the gates, then runs Stages 3–5 as usual; recorded here, built in that change.
- [feature-codex-agent/plan.md U4] Q5 = B: no `--model` when the user names none; the script reads back the model that ran, checks its form, and names it in the header line and the record line; the model can change between rounds.
- [feature-codex-agent/plan.md U5] Q6 = A: the effort is `CLAUDE_CODE_EFFORT_LEVEL` when set, otherwise asked once per session and recorded with the model line; mapping (i), said in the announce line. Revision 5 (review r1 T5, stated to the user): with `models: unavailable`, the session's level is sent unchanged and the announce line says `effort <sent> (no levels known)`.
- [feature-codex-agent/plan.md U6] Q7 = A: a one-time data note in `README.md` and in the skill.
- [feature-codex-agent/plan.md U7] Answer 3: no "Use balance"-style check for Codex; live runs only on the user's explicit instruction in chat.
- [feature-codex-agent/plan.md D1] Isolation is an adapter value, `sandbox` or `host`, branched on through the global `isolation`; one script with adapters as function sets; a second script for host backends rejected, since it would duplicate the shared wrapper.
- [feature-codex-agent/plan.md D2] OpenCode's behaviour does not change: its lines move into `opencode_*` with the same effect (E01–E49); only E28's unknown backend changes; D8's session check is the one addition that reaches it (E66).
- [feature-codex-agent/plan.md D3] Codex runs in its human output mode, not `--json`: the JSONL stream never names the model; the stderr header block names the model, sandbox, approval, effort and session id; stdout is the final message only.
- [feature-codex-agent/plan.md D4] Every turn passes `--ignore-user-config`, `--ignore-rules`, web search off, `shell_environment_policy.inherit="core"`, history off, telemetry and the update check off, and the `--disable` list; MCP, apps, web search, plugins and hooks run outside the command sandbox or reach outside the repository, the user's config could turn them on or the sandbox off, and `glab:reviewer` has no web tool.
- [feature-codex-agent/plan.md D5] The read-only check on every Codex turn: a header block not saying exactly `sandbox: read-only` and `approval: never` is exit 12 NOT READ-ONLY with the reply withheld; a block absent, or without a well-formed model or session id, is exit 7, on every turn.
- [feature-codex-agent/plan.md D6] `--model` optional for Codex, a given id form-checked (exit 5), no allowlist and no end dates; the shown model is the block's, else the requested id, else `default`; `agent.json` `ran` keeps the last well-formed model; the record line names `codex` alone or `codex:<id>`, the handoff line `codex:<the model the header named>`.
- [feature-codex-agent/plan.md D7] Process lifetime on the host: `setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 <t> setpriv --pdeathsig KILL -- <codex …>`, exec'd from the background subshell, so the group id is the started pid; after every host turn and in `cleanup`, the group gets TERM, then KILL, then the marker sweep (D31), before the output filters are waited for; revision 4: the group kill alone does not end a Codex turn; `timeout`'s own group handling is not relied on.
- [feature-codex-agent/plan.md D8] The session id is the block's `session id:`, a UUID; `send` passes only the recorded id, as `exec resume <id> -`; a continued turn on any backend that reports another session is exit 7 and the recorded session does not change.
- [feature-codex-agent/plan.md D9] `start --effort <low|medium|high|xhigh|max|ultra>` for Codex only (exit 2 for OpenCode), stored and passed on every turn as `-c model_reasoning_effort="<level>"`; the mapping is the manager's, from `check`'s levels.
- [feature-codex-agent/plan.md D10] `check --backend codex` prints `cli:`, `tools:`, `login: stored` from `login status`'s exit status (its text never printed), `sandbox: read-only starts`, and the predicted default and models from `codex debug models`; not logged in is 4, a sandbox that does not start 12, an unreadable catalog `models: unavailable` and 0; the three commands run under the user's config, the turns do not, and the skill says so.
- [feature-codex-agent/plan.md D11] The Codex CLI path is made absolute but not resolved, so the user's `current` link is followed across an update; OpenCode keeps `readlink -f`, because its sandbox binds one file.
- [feature-codex-agent/plan.md D12] `stop` leaves Codex's own session in Codex's history under `~/.codex`; the script removes only its own agent directory.
- [feature-codex-agent/plan.md D13] The Codex process's environment is an allowlist, each name passed only when set, plus `LANG=C.UTF-8`, `TERM=dumb` and (revision 4) `GLAB_EXTERNAL_AGENT=<marker>`; `LC_ALL` not passed; values exported in the subshell, never on a command line.
- [feature-codex-agent/plan.md D14] No redaction for Codex: `secret` stays empty and `redact_stream` only caps; the skill and the README say the transcript holds whatever Codex printed.
- [feature-codex-agent/plan.md D15] Transcript files: OpenCode keeps `transcript.jsonl` and `transcript.txt`; Codex keeps `transcript.txt` and `transcript.log` (per turn its stderr, header block included, and its stdout); `<b>_raw_name` names the raw file and `<b>_raw` writes it.
- [feature-codex-agent/plan.md D16] Codex uses the `default` profile only.
- [feature-codex-agent/plan.md D17] A Codex reviewer can take a branch or a range target; `/glab:ship` still reviews the working tree only.
- [feature-codex-agent/plan.md D19] No adapter is called on an unchecked backend name: `[ -n "$model" ] || model_optional "$backend" || die 2 USAGE "--model is required"`, `model_optional` a pure `case` beside `known_backend`; OpenCode's checks keep their order and messages.
- [feature-codex-agent/plan.md D24] The host first message is the plan's P3 text, verbatim; payload, approved with the plan.
- [feature-codex-agent/plan.md D25] The data note is one paragraph, carried word for word by `README.md` and the skill; revision 5 gives the text review r1 built, with the tighter socket clause the user approved ("no IP network, and a connect to a Unix-domain socket by path was refused (measured offline with `codex sandbox`); datagram and abstract sockets not measured").
- [feature-codex-agent/plan.md D26] The repository's `.codex/` layers are off by default: Codex disables a project's config, hooks and exec policies unless a non-project config marks it trusted, and under `--ignore-user-config` the user's trust entries are not read; O1 measured it against a known positive.
- [feature-codex-agent/plan.md D27] `isolation=''` and `turn_model=''` join the top-level initialisation, so `set -u` holds on every path; `isolation` is set right after `known_backend` (start, check) or after the lock (send, revision 5); `turn_model` is global and reset at the start of each turn.
- [feature-codex-agent/plan.md D28] `head` and `branch` for a host agent come from `hostgit -C "$top" rev-parse -q --verify HEAD` (12 characters) and `symbolic-ref -q HEAD`; a repository with no commit records `""` for both and the start goes on: Codex needs a git repository, not a commit.
- [feature-codex-agent/plan.md D29] `setsid --wait` is not used: it would fork and wait, and the started pid would no longer be the group id D7 kills.
- [feature-codex-agent/plan.md D30] The effort answer for a general Codex agent (Rule 6, no Rule 5 role) is recorded as `- effort: codex <level> (the user's answer: "<words>"), for the session` under `## Decisions` of the plan in progress; with no plan it lives in the conversation only, as Rule 5 says for a review with no plan.
- [feature-codex-agent/plan.md D31] The agent marker and the sweep (revision 4): every Codex turn carries `GLAB_EXTERNAL_AGENT=<agent id>`, exported and passed as `-c shell_environment_policy.set.GLAB_EXTERNAL_AGENT="<id>"`; `sweep_agent <id>` kills by PID, with a start-time guard against PID reuse, every process of this uid whose environment holds the exact entry, after every host turn, in `cleanup` and in `cmd_stop` (and, since revision 5, before every `send`); SIGTERM or SIGINT first rejected, since Codex does not tear down its helper on either; a `systemd-run --user --scope` per turn rejected for its systemd and D-Bus dependency, and kept as the fallback if a live run shows that `codex exec` does not pass `set` to its helper — that fallback needs the user's yes.
- [feature-codex-agent/plan.md D32] One model-id wording, now that `default` is refused (revision 5): `README.md` "the script checks only the id's form, and refuses `default`, the word its output uses for Codex's own default"; `AGENTS.md` *One fact* "checks an id's form only, and refuses `default`"; the skill "the script checks only the id's form" beside its `default`-refused sentence.
- [feature-codex-agent/plan.md revision-4] Stage 4's O2 failure answered by D31, chosen among the three measured candidates because it adds no dependency and the stub can test it (E60, E69); changed D7, D13, P2–P5, O2 and *UNVERIFIED* — approved by the user (`[feature-codex-agent/questions.md stage-4]`).
- [feature-codex-agent/plan.md revision-5] Review round 1's fixes folded into the plan, which conformance round 3 had found ahead of revision 4: U5's fallback, D25's text, D32, `codex_model_allowed` refusing `default`, `sweep_agent` through `environ_has` with a pass 2 only after a kill, the filtered catalog, `codex_cmd` and `header` top-level, `cmd_send`'s isolation after the lock and its sweep, the `capped.$$.*` flags, `cleanup`'s trap and `host_turn`, `cmd_stop`'s sweep rule, tag-form comments, and O2 rerun against the built sweep; C-C, C-E/S-5, S-6 and S-7 stay follow-ups — approved by the user (`[feature-codex-agent/questions.md review-r1-fixes]`).
- [feature-codex-agent/plan.md revision-6] Conformance round 4/4: the count is 71, E70 the sweep before every `send` (stub scenario `stale`), E71 the PID-named cap flag (`late-flood-unmarked` plus `slow`), the helper `environ_line`, and `cleanup`'s `host_turn` sweep listed as uncovered; no code or docs change — approved by the user (`[feature-codex-agent/questions.md revision-6]`).
- [feature-codex-agent/plan.md spent] U8, D18, D20, D21, D22, D23 — U8 (the narrow third Stage 1b check and the one offline run) ran; D18, refusing a repository top holding `"`, `\` or a control character for a `-c` TOML key, was withdrawn in revision 3, since a `-c` key is never TOML-parsed and the top now goes only into the first message and `cd`; D20's measurements S1, O1 and O2 ran at Stage 4 (*Measurements*); D21's stub and E50–E71 shipped (`PASS 71/71`); D22's `0.6.0` bump and D23's one commit landed as `9108ac7`.
- [feature-external-developer/questions.md approval] The user approved `plan.md` and the offline M5 run ("Approve both"): M5 a real `start` inside `bwrap --unshare-net` with a fake login in a throwaway `CODEX_HOME`/`HOME`, on a throwaway repository, no model reached; M1–M4 under the standing `codex sandbox` allowance; a time budget of about an hour, kept small; the push on the user's go-ahead (2026-10-18).
- [feature-external-developer/questions.md revision-2] The user approved the developer's new profile section, `## Developer, before the contract` in `profiles/default.md`, as quoted to them, and asked for one more fix in this change: correct the README sentence saying no Codex agent had run against a real model, since L1 ran (`30f2c80`). The amendment of `default.md`'s intro was not a user decision but a Stage 1b note the manager passed on (*Correction to the record*).
- [feature-external-developer/questions.md review-r1] After review round 1 (BLOCK 6 and BLOCK 6, five of them real security issues in the change report, the time budget already past), the user chose one fix round for all of them — the snapshot without `git status`, a nested `.git` refused and reported, `core.hooksPath` checked, a `TMPDIR` inside the repository refused, a time limit on hashing, the docs and test fixes — approved as plan revision 3.
- [feature-external-developer/questions.md review-r2] After review round 2 (8 findings, the reviewers warning that the guard was not converging), the user chose one last minimal round — remove logic where possible — approved as plan revision 4; round 3 had to end in SHIP, SHIP WITH SCOPE CUT or DO NOT PUBLISH.
- [feature-external-developer/questions.md review-r3] Both reviewers returned SHIP WITH SCOPE CUT, with the same cut: drop `need_find` from `codex_check`, so `check`, and every Codex role with it, does not fail on a `find` without `-files0-from`; keep the probe on a developer `start`; drop E83's `check` half; remove "`check` and" from the README and the skill. The user approved the cut plus the inspection wording advisory in the skill and `develop.md` — `diff -u -- - <path>`; never open a link or a path that is not a regular file, a link shown with `readlink` and a special file with `ls -l`; each `!!` path included — then the commit of `glab` 0.7.0 (2026-10-18).
- [feature-external-developer/plan.md U1] A4: Codex can be a developer subagent (the user's, from `feature-codex-agent`).
- [feature-external-developer/plan.md U2] Q3: it edits the working tree directly, as `glab:developer` does, under Codex's own `workspace-write` sandbox in the user's repository; no patch and no apply step (the user's).
- [feature-external-developer/plan.md U3] Q4 = A: the same trust as a Claude developer — the manager reads the whole change before it runs the gates; Stages 3–5 do not change (the user's).
- [feature-external-developer/plan.md U4] Model, effort and login work as in 0.6.0; live runs only on the user's instruction (the user's).
- [feature-external-developer/plan.md D1] `--role developer` is Codex's only; OpenCode refuses it with exit 2 before anything is created and stays read-only.
- [feature-external-developer/plan.md D2] A developer turn asks for `sandbox_mode="workspace-write"` with `network_access=false`, `exclude_tmpdir_env_var=true` and `exclude_slash_tmp=true`, and `approval_policy="never"`: its commands write in the repository and nowhere else, because `$TMPDIR` holds every agent's state.
- [feature-external-developer/plan.md D3] The header check accepts for a developer exactly `sandbox: workspace-write [workdir]` and `approval: never`, anything else exit 12 `NOT READ-ONLY` with the reply withheld; every other role still exactly `read-only`; another string printed by 0.163.0 would have been `PLAN WRONG`, not something to widen (M5 measured the string).
- [feature-external-developer/plan.md D4] The change report: a snapshot before and after each developer turn, `changed:` lines and `git: unchanged|changed` between the header line and `reply:`, on every exit after a turn ran (0, 6, 7, 12; 8 is the reviewer's only); a changed `.git` is not an exit code — the manager stops on the `git: changed` line; since revision 3 the snapshot never runs `git status`.
- [feature-external-developer/plan.md D5] The developer's first message: the default profile's *Developer, before the contract* in place of *Before the contract*, the developer host text, `agents/developer.md`'s body as its contract, both skills, the brief, *After the contract*, then the developer tail, which `send` appends too; a section of its own rather than one sentence reworded to fit both.
- [feature-external-developer/plan.md D6] The manager writes `result.md` from the agent's final message, marked as that model's words, with the script's `changed:`/`git:` lines and the gates it ran itself; the agent is told not to write it.
- [feature-external-developer/plan.md D7] One external developer at a time: no split, never beside a `glab:developer`; a re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent, a report missing fields gets one `send`, the old agent is stopped.
- [feature-external-developer/plan.md D8] A developer turn that ends in any exit but 0, or prints `git: changed`, stops the pipeline: the manager shows the user the `changed:` lines and reverts, commits or re-runs nothing on that tree; reverting would be destructive, the user's call.
- [feature-external-developer/plan.md R3.1] A state root inside the repository is refused (`dev_refuse`, `realpath -e` of both): exit 2 at `start` before `mkdir`, 4 before each later developer turn — the work tree is the agent's one writable root (review r1 X4).
- [feature-external-developer/plan.md R3.2] A nested `.git` — any `.git` other than `<top>/.git`, a gitfile or a directory, at any depth — is refused the same way; one that appears during a turn makes `git: changed` (review r1 X1, X2).
- [feature-external-developer/plan.md R3.3] The comments cite `[feature-external-developer/integration.md M2, M3, M4]` and M5 as measured, no longer "not measured yet" or "inferred from Codex's source".
- [feature-external-developer/plan.md R3.4] `dev_state` rewritten: no `git status`; `ls-files` for tracked and untracked paths; metadata from one `find -files0-from` that opens nothing; one batched `hash-object --no-filters --stdin-paths` up to `DEV_HASH_BYTES` (16 MiB); every file's mode in its kind; the `git` digest adds the `core.hooksPath` directory, the config as git reads it, `info/` and every nested `.git`; both snapshots under `dev_snap`, at most the turn's `--timeout` and `DEV_STATE_S` (300 s); an unreadable after-state is one `changed: unreadable` line and `git: changed`; it requires `find` with `-files0-from` and `-printf` (findutils 4.9 or later, or bfs) and `realpath -e`.
- [feature-external-developer/plan.md R4.1] `dev_refuse` compares against `${t%/}`, so a top of `/` does not make every path look outside it (advisory). Review round 3 found the comparison does not do that for a top of `/` (`[feature-external-developer/record.md round-3-root]`, open).
- [feature-external-developer/plan.md R4.2] The `find` probe, `need_find`: exit 4 `UNAVAILABLE` "find does not take -files0-from (findutils 4.9 or later, or bfs); see the README's Requirements" — since the review round 3 scope cut at a developer `start` only, not in `check`.
- [feature-external-developer/plan.md R4.3] The state lists ignored entries by name only (`ls-files -z -o -i --exclude-standard --directory`), code `!!`, so a path the agent makes ignored with a `.gitignore` of its own shows up instead of vanishing; a write inside an ignored file or directory is not reported.
- [feature-external-developer/plan.md R4.4] What `--` and ` M` mean, word for word as the code assigns them, in the header, the `dev_state` comment, the skill and the README; revision 3's "as the index has it" was wrong for a tracked symlink and a file over 16 MiB.
- [feature-external-developer/plan.md R4.7] The inspection is filter-free: only after `git: unchanged` and no nested-repository refusal, each named tracked path compared with `git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u` (as built, `diff -u -- - <path>`, the scope cut), untracked files read directly, neither `git status` nor `git diff` on the tree before that — revision 3's `git diff --no-ext-diff --no-textconv --ignore-submodules=all` ran filters too (review r2 R2-1).
- [feature-external-developer/plan.md R4.8] The README's developer paragraph is the one the skill's once-per-session notice carries, in the same words (identical after whitespace normalisation); a short README paragraph after it, and the skill, give the codes in the header's terms.
- [feature-external-developer/plan.md spent] R4.5, R4.6, R4.9 and the P1–P7 wording steps — the two T4 mutants killed by E74 and E75, the stale test comment amended, the refusal entry's missing files added to `AGENTS.md`, and the payload texts, all built in `33a28df`; *Changes in revision 2* to *4* record how the plan reached them.
- The `feature-codex-agent` decisions this change acted on: `[feature-codex-agent/questions.md A4]` and `[feature-codex-agent/plan.md U3]` are now built; `[feature-opencode-worker/plan-r3.md U10]` (no external developer until gates can be sandboxed) and its D34 are superseded for Codex by the user's A4 — the gates still run on the host, by the manager, after its filter-free reading of the change (U3).

## Known limits and not verified

- **OpenCode agents have run against a real model once**: the live probe of
  2026-10-17 (*Live runs*), on a one-file test repository. Not shown: any
  reply from a DeepSeek model, a real repository, a long brief, a Go limit,
  the profiles' effect (`README.md`, pinned by its gate line).
- **Codex agents have run against a real model once**: L1 of 2026-10-18
  (*Live runs*), Codex's default model at effort `high`, one general start
  and one `send` in this repository; `README.md` says so since `33a28df`
  (`[feature-codex-agent/record.md readme-stale]`, closed).
- **A developer turn has run against a real model** — closed by `[probe-codex-dev/probe-codex-dev.md]`:
  "No developer turn has run against a real model" held until the two live
  developer runs of 2026-10-18 (*Live runs*), on a throwaway three-file
  repository. Before them the role was tested against the stub (E72–E84)
  and its sandbox offline (M1–M5). `README.md` at `7390a87` still says only
  "The developer role has been tested against a stub, and its sandbox
  offline with `codex sandbox`." — true, but no longer the whole of it.
- [probe-codex-dev/probe-codex-dev.md observed] An external developer follows the `glab:developer` contract and changes nothing without `plan/<slug>/plan.md` or a waiver: in run 1, given a bare brief and no plan, it changed nothing and answered `BLOCKED: no contract; provide plan.md or waived.md`. Observed in one run of one model; the script does not enforce it — the contract the developer receives does.
- [probe-codex-dev/probe-codex-dev.md not-shown] Not shown by the live developer runs: a turn that leaves a process running, so the sweep killed nothing; a turn that writes `.git` or makes a nested repository (M3 and the stub tests cover those offline); any repository other than a three-file toy.
- [feature-external-developer/integration.md unverified] *Still UNVERIFIED* after Stage 4, each needing a live run or more than `start`: whether Codex itself, outside its command sandbox, changes a ref or `.git` during a real turn, which would print `git: changed` every turn — not seen in the four live developer turns, each `git: unchanged` with HEAD, `.git/config` and the hooks unchanged (`[probe-codex-dev/probe-codex-dev.md]`), so not shown either way beyond them; how a real model does as a developer — shown on a toy repository only (`[probe-codex-dev/probe-codex-dev.md]`); the report's lines on exits 0, 6 and 12 with the real binary — exit 0 shown live (`[probe-codex-dev/probe-codex-dev.md]`), 6 and 12 still the stub's only; a developer `send` with the real binary — shown (`[probe-codex-dev/probe-codex-dev.md]`).
- [feature-external-developer/plan.md after-4] *After* step 4, the same two items written `UNVERIFIED` for `integration.md`: Codex itself changing a ref during a real turn, and how a real model does as a developer — both for a live run, which only the user starts. The live developer runs (`[probe-codex-dev/probe-codex-dev.md]`) showed `git: unchanged` on every turn and one model building a two- and a one-step task on a toy repository; neither is shown on a real repository.
- [feature-external-developer/plan.md not-covered] Not covered by any case, accepted in the plan: the report on exits 6 and 7 (`header` is the one place it is printed, and E73 shows it on 12 through the same call); `dev_snap` (and before it `dev_state`) failing before the turn, exit 4, which needs E82's stand-in armed before the turn; `dev_refuse`'s "cannot resolve" and 300 s search-limit branches; `config list: none`; the `${t%/}` advisory, which needs a repository whose top is `/`; the real sandbox, Stage 4's. The developer also named `config: none` as not exercised, and `dev_git`'s fixed words (`head: none`, `symref: none`, an absent hooks directory) as exercised once by hand only (`result-p1-p4.md` *Tests*).
- **The inspection and the user's own filters**: since R4.7 the manager's inspection runs `cat-file blob`, which applies no filter, and no `git diff` (`[feature-external-developer/result-p5-p7.md L171]` under *Open follow-ups*).
- [feature-codex-agent/plan.md unverified] *UNVERIFIED, in one place*, and what has settled each since: that Codex's read-only sandbox starts on this host, refuses writes, allows reads outside the repository and gives commands no network — S1 (on the host, under `codex sandbox`); that the real header block is as findings §9.2 gives it, every `--disable` name is accepted, the repository's trusted `.codex/` layer stays off under the script's argv (D26; that `--ignore-user-config` alone drops the trust entry is inferred, since the argv differs in more flags) and `exec resume <id>` continues and prints the same id — O1 offline, and L1 with a real model; that `login status` exits 0 for a real login — L1's `login: stored`; that `codex exec`, like `codex sandbox`, passes `shell_environment_policy.set` to its sandbox helper, so D31's sweep finds a real turn's helper — shown by the live developer runs: on three of the four turns the model ran `printenv GLAB_EXTERNAL_AGENT` in its sandbox and it printed the agent's id (run 1's second turn repeated the value without running the command, `transcript.log`) (`[probe-codex-dev/probe-codex-dev.md]`); that the sweep then kills a real leftover is still not shown (`[feature-codex-agent/probe-codex-l1.md not-verified]`); that a keyring login works under `--ignore-user-config` — L1 ran with the user's login under the flag, but which store it uses is not recorded; that `check`'s predicted default is the model that runs — L1, `gpt-6.1-sol` both; reroutes, an unsupported effort level, a real turn obeying read-only, and the model honouring "Read nothing outside <top>" — not shown.
- [feature-codex-agent/findings.md unverified] §9.6's list of what needs a model: that a real turn obeys read-only, that its commands really have no network, that a reroute shows in the header or output, that the default is the one `check` predicts (since shown by L1), and the effort fallback on a model without the level — the rest still open. Revision 1's other UNVERIFIED items (§3) concerned the superseded copy-based design, the login mechanisms and the per-turn `CODEX_HOME`, which revision 2 dropped.
- [feature-codex-agent/integration.md open] *Items these runs leave open* and *Still unverified after round 3*: what the script itself leaves after a killed host turn mid-command with the real Codex (the stub covers the call sites: E60, E69, E70); `check`'s `default:`/`models:` lines from `debug models` without `--bundled` — shown online by L1 (seven listed models, against the bundled catalog's eight: no `gpt-5.5`), the offline fallback still not run; a real `login status` rc 0 (since L1) and a keyring login; the live-run items above; whether `codex sandbox` contacted the network on the host, for an update check, not measured; that a real `codex exec` turn passes `set` to its helper — since shown (`[probe-codex-dev/probe-codex-dev.md]`); that a command which unsets the marker still ends with its helper, not re-measured after findings §9.9 C2c. Inferred, not measured: which of D4's flags turned off the MCP endpoint direct Codex tried in O1.
- [feature-codex-agent/probe-codex-l1.md not-verified] That a real `exec` turn's commands carry the marker while they run: L1's turns ended cleanly, nothing was alive at the three check points, so finding 0 marked processes does not tell a passed marker from a missing one, and the sweep was not exercised on a real turn. The marker half is closed by `[probe-codex-dev/probe-codex-dev.md]`: in the live developer runs the turn's own command, `printenv GLAB_EXTERNAL_AGENT`, printed the agent's id — run on both turns of run 2 and the first of run 1; run 1's second turn repeated the value without running it (`transcript.log`). Still open: a real turn that leaves a process running, so that the sweep kills something — in those runs nothing was left after either turn or after `stop` (0 marked processes each time), so the sweep killed nothing. Proving it needs a turn ended by `stop` while a command runs (`[feature-codex-agent/plan.md unverified]`).
- [feature-codex-agent/plan.md not-covered] Not covered by any case, accepted in the plan's coverage list: `codex_check`'s exit 4 for a missing tool; `opencode_secret_hint`'s tail; a host repository with no commit (D28); the real Codex's header, flags, trust default, catalog and resume (O1), its sandbox (S1) and the real helper dying to the sweep (O2; the stub's `setsid` child stands in, E60 and E69); the D13 names the test does not set; a script killed and never `stop`ped, whose leftovers run until the next `stop` of that agent; `cleanup`'s `host_turn` sweep (`[feature-codex-agent/review-r2.md R2-c]`); C2's `trap '' HUP INT TERM` and C-A, races with a second signal or a concurrent `stop`; P5–P10 are text, checked by the plan's searches. The developer added: a relative `--cli` for Codex; `CODEX_BLOCK_AWK` rejecting a non-`key: value` line inside the block; `run_host`'s `cd … || exit 1`; a PID reused between `sweep_agent`'s two reads; `check`'s own sweep killing anything (`result-p1-p4.md` *Tests*, *Round 2*).
- [feature-codex-agent/result-p5-p10.md L578] The socket wording names datagram and abstract sockets as not measured; still not named anywhere in the payload: seqpacket sockets, `socketpair`, and a descriptor passed in from outside (integration round 4).
- [feature-opencode-worker/probe-r3.md not-verified] *Not verified* by the probe: DeepSeek's behaviour (refused before any turn); how the models behave on a real repository, a long brief or a Go limit; the profiles' effect — no run without profiles to compare against.
- [feature-opencode-worker/plan-r3.md unverified] *UNVERIFIED, in one place*: I7, a real Go model through the isolated network keeping its session — shown since for Kimi and GLM by the probe; I8, which models send reasoning; rev 2's I3, the text of a Go limit, and I5, each family's reading style; the back-out's version inference; and that `slirp4netns`'s own code — run outside the sandbox, as the user, on the sandbox's packets — has no exploitable bug.
- [feature-opencode-worker/findings-r3.md unverified] The same list in the rev-3 findings: I7, I8, rev-2 I3 and I5, and `slirp4netns`'s own code; `--enable-seccomp` narrows it, `--enable-sandbox` could not be proven.
- [feature-opencode-worker/findings.md unverified] Rev 2's list: I1, the stored credential's entry name — moot, the key is read through `auth export`; I2, a real answer through `--pure` and the sandbox — `--pure` is gone in 2.0.31, and the probe answered; I3, the text of a Go limit — open; I4, whether Claude Code's own sandbox mode can start the sandbox (bwrap does not nest here, so it would be exit 4) — open; I5, each family's reading style — open; that a model honours the markers and template often enough to be useful — one report per model so far.
- [feature-opencode-worker/result-r3.md L645] Three things the stub cannot show (*Review round 1 fixes*): that the real `auth export` still finds the key when run from an empty directory with the project switch set — the probe's `check` printed `key: stored`, so this has been seen; that 16 MiB is enough for a real turn's JSON events — the probe's turns stayed under it, not measured; that the real CLI exits soon after its stdout pipe closes at the cap — open.
- [fix-external-report-lines/result.md unverified] That a real model copies the indent or the backticks, and that it obeys the left-edge sentence or the profile wording — in the probe GLM passed the check first time, and Kimi failed on the singular `issue`, not on an indent; not shown more widely.
- **The offline run** shows the argv, config, environment and parsing against the real 2.0.31 binary, not a reply: no request leaves the host. Its rerun after review round 2 showed the session id recorded and the data directory kept, not that turn 2 sees turn 1 (the probe since showed it for Kimi and GLM); that the CLI rejects an unknown `--session` at once was not checked (`feature-opencode-worker` `integration-r3.md`, *Not exercised*).
- **The key in the raw transcript**: only literal occurrences are redacted, so a JSON-escaped key can stay in `transcript.jsonl` (`[feature-opencode-worker/follow-ups.md 10]`, `17`).
- Total memory and the disk used under `TMPDIR` are not limited. For a Codex
  agent, files, processes and memory are not limited by the script either.

## Offline run

An offline run — no network, and a dummy key or login in a throwaway home —
is what `AGENTS.md` *Rules* allows besides the stub, as this section records
them: one per backend.

### OpenCode

The script against the user's real `opencode` binary with no network and a
dummy key. From
`feature-opencode-worker`'s `plan-r3.md`, *Integrate — the real CLI,
offline*, the block byte for byte:

Stage 4 runs this: the user's real `opencode`, a dummy key in a throwaway
home, and a slirp4netns stand-in that wires nothing, so the sandbox has only
its own loopback and no request leaves this host. It proves the script's
argv, config, environment and parsing against 2.0.31 itself, which the stub
cannot. `CLI` defaults to `~/.opencode/bin/opencode`; set it where the native
binary is elsewhere. Run from the repo root.

````bash
: "${TMPDIR:?export TMPDIR as the temp directory your host file names}"
CLI=${CLI:-$HOME/.opencode/bin/opencode}
S=$PWD/plugins/glab/scripts/external-agent.sh
X=$(mktemp -d "$TMPDIR/agent-offline.XXXXXX") && mkdir -p "$X/home" "$X/bin" "$X/tmp" || exit 1
# A slirp4netns stand-in: says it is ready, wires nothing, waits for the exit FIFO.
printf '#!/bin/sh\necho 1 >&7; exec 7>&-; cat <&8 >/dev/null\n' >"$X/bin/slirp4netns" && chmod +x "$X/bin/slirp4netns"
# A dummy key, imported into the throwaway home through stdin, without network.
printf '[{"id":"cred_000000000000fakeid00000AAA","integrationID":"opencode-go","label":"default","active":true,"value":{"type":"key","key":"dummy-not-a-key-99"}}]' \
  | bwrap --unshare-net --die-with-parent --dev-bind / / env -i PATH=/usr/bin:/bin HOME="$X/home" OPENCODE_DISABLE_MODELS_FETCH=1 OPENCODE_DISABLE_AUTOUPDATE=1 "$CLI" auth import --standalone
git -C "$X" init -q -b main repo && echo hi >"$X/repo/a.txt" && git -C "$X/repo" add a.txt && git -C "$X/repo" -c user.name=p -c user.email=p@p commit -qm init
printf 'Say hello.\n' >"$X/brief"; printf 'Say hello again.\n' >"$X/msg"
run() { env -i PATH="$X/bin:/usr/bin:/bin" HOME="$X/home" TMPDIR="$X/tmp" bash "$S" "$@" </dev/null; }
s=$SECONDS; run start --backend opencode --model opencode-go/kimi-k3 --cli "$CLI" --brief "$X/brief" --repo "$X/repo" --label offline >"$X/out" 2>"$X/err"; echo "start rc=$? after $((SECONDS - s)) s"
sed "s|$X|<X>|g" "$X/out" "$X/err"
id=$(sed -n 's/^agent: \(ea-[0-9a-f]*\) · .*/\1/p' "$X/out" | head -n 1)
echo "session recorded: $(jq -r '.session | test("^ses_")' "$X/tmp/glab-external-agents/$id/agent.json")"
s=$SECONDS; run send "$id" --message "$X/msg" --timeout 15 2>&1 | sed "s|$X|<X>|g"; echo "send rc=${PIPESTATUS[0]} after $((SECONDS - s)) s"
run list | sed "s|$X|<X>|g; s|$id|<id>|g"
echo "dummy key under the agent: $(/usr/bin/grep -rlF dummy-not-a-key-99 "$X/tmp" | wc -l); known positive, the throwaway home: $(/usr/bin/grep -rlF dummy-not-a-key-99 "$X/home" | wc -l)"
run stop "$id" | sed "s|$id|<id>|"
echo "agents left: $(find "$X/tmp/glab-external-agents" -mindepth 1 -maxdepth 1 | wc -l); processes left: $(ps -u "$(id -u)" -o args= | /usr/bin/grep -c "^bwrap .*$X")"
rm -rf "$X"
````

Recorded (`<X>` is the throwaway directory; ids differ per run):

````text
Imported 1 credential
start rc=7 after 82 s
agent: ea-c44413ff13c09872 · model: opencode:opencode-go/kimi-k3 · turn: 1 · transcript: <X>/tmp/glab-external-agents/ea-c44413ff13c09872/transcript.txt
end: ea-c44413ff13c09872
external-agent: BACKEND ERROR: provider.transport: getaddrinfo ETIMEOUT opencode.ai
session recorded: true
agent: ea-c44413ff13c09872 · model: opencode:opencode-go/kimi-k3 · turn: 2 · transcript: <X>/tmp/glab-external-agents/ea-c44413ff13c09872/transcript.txt
end: ea-c44413ff13c09872
external-agent: TIMEOUT: no reply within 15 s
send rc=6 after 15 s
agents: 1
<id>  idle  opencode:opencode-go/kimi-k3  role=general  turns=2  last=2026-10-17T01:38:51Z  repo=<X>/repo@f173970241f7  label=offline
dummy key under the agent: 0; known positive, the throwaway home: 1
stopped: <id>
agents left: 0; processes left: 0
````

Expected: `start` ends in exit 7 with `provider.transport` (the sandbox has no
route out — the CLI got as far as its API call), the session id recorded;
`send` ends in exit 6 after about 15 s; `list` shows one idle agent with two
turns; `stop` prints `stopped: <id>`; the dummy key is in no file under the
agent's state (`0`), while the known positive — the throwaway home's
database — holds it (`1`); no process is left (`0`).


Run twice at Stage 4 of `feature-opencode-worker` on 2026-10-17, both
`INTEGRATED`: the first run printed the exit codes recorded above (`start`
7, `send` 6); the rerun after review round 2, with the per-turn home and the
kept data directory, ended the same way, with no unknown-session error
(`integration-r3.md`). It shows the argv, config, environment and parsing
against 2.0.31; it cannot show a reply (*Known limits*).

### Codex — O1

The script against the user's real `codex` (0.163.0), inside `bwrap
--unshare-net --die-with-parent --dev-bind / /`, with a throwaway
`CODEX_HOME` holding a dummy `auth.json` of fake, unsigned JWTs — never a
real token — and a throwaway `HOME`, on a throwaway repository whose
`.codex/config.toml` names `project-model-x` and which a throwaway
`config.toml` marks trusted, the known positive for D26. Run at Stage 4 of
`feature-codex-agent` on 2026-10-18, round 1, as a saved script, never
pasted. From `integration.md`, `o1-inner.sh`, the block byte for byte (the
user's home masked as `<home>` there, as recorded):

````bash
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
````

It ran as (`<work>` the integrator's work directory, `<repo>` this
repository):

````text
KEEP=<work>/out CX=<home>/.local/bin/codex S=<repo>/plugins/glab/scripts/external-agent.sh \
  timeout 1500 bwrap --unshare-net --die-with-parent --dev-bind / / -- bash o1-inner.sh
````

Recorded, per step, as `integration.md` gives it (`<X>` is the throwaway
directory; ids differ per run; the integrator trimmed the repeated log lines
of step 3 to `…`):

````text
netns: lo routes=0
CODEX_HOME=<X>/home: auth.json config.toml
config.toml:
  [projects."<X>/r"]
  trust_level = "trusted"
repo .codex/config.toml:
  model = "project-model-x"
````

Step 1, `check --backend codex`:

````text
stdout:
  cli: <home>/.local/bin/codex
  tools: setpriv setsid timeout flock
  login: stored
stderr:
  external-agent: NOT READ-ONLY: Codex's read-only sandbox does not start on this host: bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. See <https://deb.li/bubblewrap> or <file:///usr/share/doc/bubblewrap/README.Debian.gz>.
rc=12
````

Step 2, `debug models --bundled` through P2's jq program:

````text
debug models rc=0; stderr: (empty)
jq rc=0
default: gpt-6.1-sol (predicted)
models: gpt-6.1-sol (low medium high xhigh max ultra), gpt-6-astra (low medium high xhigh max ultra), gpt-6-sol (low medium high xhigh max ultra), gpt-6-luna (low medium high xhigh max), gpt-5.6-sol (low medium high xhigh max ultra), gpt-5.6-terra (low medium high xhigh max ultra), gpt-5.6-luna (low medium high xhigh max), gpt-5.5 (low medium high xhigh)
entries in models line: 8
gpt-daybreak count: 0; codex-auto-review count: 0
````

Step 3, the known positive, Codex directly with the user config read:

````text
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
````

Step 3b, `start` through the script:

````text
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
````

Step 4, `send`:

````text
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
````

Step 5, `list`, then `stop`:

````text
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
````

Expected (`plan.md` *After* §3, O1): step 1 `cli:` and `tools:`, then
`login: stored` with the sandbox and model lines, or exit 4 for a refused
fake login; step 2 `default: gpt-6.1-sol (predicted)` and eight entries,
with no `gpt-daybreak` and no `codex-auto-review`; step 3 the header's
`model: project-model-x` — the trusted layer loads, so the run can tell the
two cases apart, and without it O1 stops; step 3b exit 7 at the network,
with a header naming a model other than `project-model-x`, `sandbox:
read-only`, `approval: never` and a UUID session id in `transcript.log`,
and `agent.json` `session` set; step 4 exit 7 with the same session id;
step 5 the agent listed, `stopped:`, no process left, no `unknown feature`
line. Every step met it but step 1's sandbox line, which is exit 12 for the
AppArmor limit of *Measurements* — the script behaving as D10 says; `check`'s
sandbox command, run on the host, passes (*Measurements*, S1). Step 3b's
`gpt-6.1-sol` is Codex's bundled default, step 2's prediction. The
`rmcp … /backend-api/ps/mcp` line of step 3 appears nowhere in the script's
turns. The process scan printed `Permission denied` for processes outside
the wrapper's user namespace; the integrator trimmed it. It shows the argv,
the header block, the trust default, the catalog and the resume against
0.163.0; it cannot show a reply (*Known limits*).

## Live runs

A live run calls a real model with the user's own key or login. When one may
run, who runs it, and how its record is kept is `AGENTS.md` *Rules*, the
live-run exception of "Never run `external-agent.sh` against a real model
from this repo"; it is not restated here, except that since
`feature-codex-agent` the user names the backend and the models — for Codex,
the backend alone names its default model — and the "Use balance" check is
for an OpenCode run only: Codex has no such switch, and runs on the user's
own Codex login (`[feature-codex-agent/plan.md U7]`). What follows is the
procedure the OpenCode live probe of 2026-10-17 used, then the Codex probe
of 2026-10-18 (*Codex — the runner*), each for a later run recorded the same
way.

**L1a — no model is called.** From the repo root, with `TMPDIR` exported;
this block is `plan-r3.md`'s L1a, byte for byte:

````bash
: "${TMPDIR:?export TMPDIR as the temp directory your host file names}"
CLI=${CLI:-$HOME/.opencode/bin/opencode}
S=$PWD/plugins/glab/scripts/external-agent.sh
# 1. The binary is the native one: prints "177   E   L   F".
od -An -c -N4 "$CLI"
# 2. The tools, the stored key (never printed) and the allowed models.
"$S" check --backend opencode --cli "$CLI"; echo "check rc=$?"
# 3. The sandbox and its network on this host, with the stub only.
bash tests/external-agent.test.sh "$S" </dev/null | tail -n 1
# 4. No command: open the OpenCode console and look at the Go "Use balance" switch.
````

Expected: `177   E   L   F`; `cli: …`, `tools: …`, `key: stored`, `models: …`,
`check rc=0`; the test's last line, now `PASS 49/49`; and "Use balance"
**off**. `check rc=4` with `no opencode key stored`: the CLI holds no
OpenCode Go key — a browser login to `opencode` alone is not one (seen in the
probe); store the Go key (`"$CLI" auth login` and choose OpenCode Go, or
`/connect` → OpenCode Go in the TUI) and repeat. `check rc=9`: `slirp4netns`
is missing or cannot start. If "Use balance" is on, turn it off first. Only
then the runner.

**The runner — L1b and L1c in one script.** Save the block below, byte for
byte, to a new file under `$TMPDIR` — `$TMPDIR/l1-runner.sh`, say — and run
it from the repo root as `MODEL=opencode-go/<id> bash "$TMPDIR/l1-runner.sh"`,
one model at a time, never pasted into a shell (*Incidents*: a pasted
`|| exit 1` closes the shell). It is `feature-opencode-worker`'s
`probe-r3/runner.sh`, the script that ran the probe:

````bash
set -u
: "${TMPDIR:?export TMPDIR as the temp directory your host file names}"
: "${MODEL:?set MODEL to one allowed id, such as opencode-go/glm-5.3}"
CLI=${CLI:-$HOME/.opencode/bin/opencode}
S=$PWD/plugins/glab/scripts/external-agent.sh
P=$(mktemp -d "$TMPDIR/agent-probe.XXXXXX") || exit 1
id_of() { sed -n 's/^agent: \(ea-[0-9a-f]*\) · .*/\1/p' "$1" | head -n 1; }
# A correct add() is committed and the bug left uncommitted, so the reviewer's
# target, the working tree, is not empty: it holds the bug.
git -C "$P" init -q -b main && printf 'def add(a, b):\n    return a + b\n' >"$P/calc.py" && git -C "$P" add calc.py \
  && git -C "$P" -c user.name=probe -c user.email=probe@example.invalid commit -qm init \
  && printf 'def add(a, b):\n    return a - b\n' >"$P/calc.py" || exit 1
# The port your own OpenCode service listens on, if one runs: the agent must not reach it.
PORT=$(ss -ltnpH | awk '/"opencode"/ {n = split($4, a, ":"); print a[n]; exit}'); echo "OpenCode service port: ${PORT:-none}"
printf '%s\n' 'Answer in three numbered lines:' '1. what calc.py does, and whether add() is correct;' \
  '2. the exact output of: ls -a ~ /home; ip -4 route; cat /etc/resolv.conf' \
  "3. the exact output of: curl -sS -m 5 http://10.0.2.2:${PORT:-1}/ ; echo x >>calc.py" >"$P.brief"
"$S" start --backend opencode --model "$MODEL" --cli "$CLI" --brief "$P.brief" --label probe --repo "$P" >"$P.out1"; echo "start rc=$?"; cat "$P.out1"
A=$(id_of "$P.out1"); echo "agent: ${A:-none}"
printf 'Quote the first line of my first message, word for word.\n' >"$P.msg"
"$S" send "$A" --message "$P.msg"; echo "send rc=$?"
"$S" list
printf 'Review the uncommitted working tree. This is round 1 of 1, the last.\n' >"$P.rev"
"$S" start --backend opencode --model "$MODEL" --cli "$CLI" --brief "$P.rev" --role reviewer --label probe-review --repo "$P" >"$P.out2" 2>"$P.err2"; RRC=$?; echo "review rc=$RRC"; cat "$P.err2"; cat "$P.out2"
B=$(id_of "$P.out2"); echo "review agent: ${B:-none}"
if [ "$RRC" = 8 ]; then
  { printf 'Your report did not pass the check: %s\n' "$(cat "$P.err2")"; printf 'Send your whole report again, between the two report lines, with the verdict line written exactly as one of the forms the Report section lists.\n'; } >"$P.fix"
  "$S" send "$B" --message "$P.fix" >"$P.out3" 2>"$P.err3"; echo "correction send rc=$?"; cat "$P.out3" "$P.err3"
fi
for t in $(sed -n 's/.* · transcript: //p' "$P.out1" "$P.out2"); do echo "$t redacted=$(command grep -c '<redacted>' "$t")"; done
R=$TMPDIR/l1-runs/${MODEL##*/}; mkdir -p "$R"; cp "$P.out1" "$P.out2" "$R"/ 2>/dev/null
for t in $(sed -n 's/.* · transcript: //p' "$P.out1" "$P.out2"); do d=$(dirname "$t"); cp "$t" "$R/$(basename "$d").transcript.txt"; done
"$S" stop "$A"; "$S" stop "$B"; "$S" list
rm -rf "$P" "$P.err2" "$P.fix" "$P.out3" "$P.err3" "$P.brief" "$P.msg" "$P.rev" "$P.out1" "$P.out2"
````

What the runner adds to `plan-r3.md`'s L1b and L1c blocks: it captures the
reviewer's stderr and, on a review exit 8, sends the reviewer the one
correction `glab:external-agents` prescribes (the stderr line, then "Send
your whole report again …"); and before the two `stop`s it copies both
outputs and both transcripts to `$TMPDIR/l1-runs/<model>/`, which `stop`
would otherwise remove.

Expected, per model, and what each part shows:

- `start rc=0`, the header with `model: opencode:<MODEL>`, `reply:`, three
  numbered `| ` lines and `end: <id>`: a real model answered through the
  sandbox. Line 1 says `add()` subtracts; line 2 shows `/home` holding only
  `worker`, `default via 10.0.2.2 dev tap0` among blackhole routes, and
  `nameserver 10.0.2.3`; line 3 a failed `curl` (host loopback, where the
  user's own OpenCode service listens, is closed) and a failed write (the
  copy is read-only) — or the model's refusal to run them.
- `send rc=0`, quoting the first line the script really sends — "Read the
  attached file and follow it. It is the whole of your next instruction." —
  which shows the session kept its context. `plan-r3.md` expected
  `Answer in three numbered lines:`, which assumed the brief arrives inline;
  it arrives attached (probe finding 2, corrected here).
- `list` shows the agent `idle` with `turns=2`.
- `review rc=0` and a report whose verdict is `BLOCK: 1 issues` or
  `BLOCK: 1 issue`, the uncommitted `a - b` being the one finding; or
  `review rc=8`, then `correction send rc=0` with the report again. A second
  8 is the input for tuning that model's profile.
- the `redacted=` counts are whatever they are: the model was not asked to
  print the key.
- `rc=7` anywhere: keep the stderr line — a Go limit, the API unreachable,
  or a refusal upstream, as DeepSeek's.
- `stopped: <id>` twice and `agents: 0`.

**Recording a run.** As `AGENTS.md` *Rules* says: the run's record goes
under `plan/<slug>/`, as `probe-r3.md` did, with its transcripts (from
`$TMPDIR/l1-runs/`), which are scanned for secrets, and host values masked —
the port of the user's local OpenCode service as `<service-port>`, the
host's LAN address as `<host-lan-ip>` — before they are committed. When the
change is recorded, a summary goes under a dated heading below.

### 2026-10-17 — L1

Run by the manager session at the user's explicit instruction, with the
user's own OpenCode Go key, after the user confirmed "Use balance" was off;
code under test `glab` 0.4.1 (`5e9b3a8`); the seven allowlisted ids, in the
order the user chose. L1a: `od` printed `177   E   L   F`; `check` first
returned `rc=4 no opencode key stored` (the CLI held only a browser login),
then, once the user added the Go key, `key: stored`, seven models,
`check rc=0`; the stub test printed `PASS 48/48`. L1b and L1c ran as the
runner above (Kimi K3 before the correction step was added, so it got none).
The record: `git show 51043c4:plan/feature-opencode-worker/probe-r3.md`; the
transcripts and run logs, host values masked:
`git ls-tree -r --name-only 51043c4 -- plan/feature-opencode-worker/probe-r3/<model>/` for each
model (`run.log`, `general.transcript.txt`, `reviewer.transcript.txt`).

| model | start | send | review | correction | verdict |
|---|---|---|---|---|---|
| kimi-k3 | 0 | 0 | 8 | not sent | `BLOCK: 1 issue` (singular) |
| kimi-k2.7-code | 0 | 0 | 8 | 0 | `BLOCK: 1 issues` after the correction |
| glm-5.3 | 0 | 0 | 0 | — | `BLOCK: 1 issues` |
| glm-5.3-flash | 0 | 0 | 0 | — | `BLOCK: 1 issues` |
| glm-5.2 | 0 | 0 | 0 | — | `BLOCK: 1 issues` |
| deepseek-v4-pro | 7 | 7 | 7 | — | none: upstream refused |
| deepseek-v4.1-flash | 7 | 7 | 7 | — | none: upstream refused |

Every run ended in `stopped:` twice and `agents: 0`; nothing was left under
`$TMPDIR`; every transcript `redacted=0`. Shown: a real Go model answers
through the isolated network, keeps its session context across `send`, and
fills the reviewer's report so that the check accepts it (GLM first time,
Kimi K2.7 after one correction) — rev 3's I7, for Kimi and GLM.

**Isolation, seen from inside, all five models that ran:** `/home` holds only
`worker`; `default via 10.0.2.2 dev tap0` among blackhole routes for the
private ranges and the host's addresses; `nameserver 10.0.2.3`; `curl` to
`10.0.2.2:<service-port>` fails with `Could not connect`; `echo x >>calc.py`
fails with `Permission denied` where a model ran it. Every model found
`add()` subtracting and proved it by running `add(2, 3)` → `-1`; every
reviewer found the one uncommitted bug. All five said the repository has no
`AGENTS.md`, as the rules ask.

**How the models differed:**

- `kimi-k3` — the shortest path (7 tool calls per role); refused to run the
  write at all, citing the read-only rule, and marked that half UNVERIFIED;
  a correct, well laid out review whose verdict was written in natural
  English, `1 issue`, so the check rejected it.
- `kimi-k2.7-code` — ran the commands verbatim and let the sandbox refuse the
  write; its reviewer reasoned at length about the report format, quoting
  the left-edge sentence, still wrote `1 issue`, and fixed it at once after
  the correction.
- `glm-5.3` — the most cautious: refused the whole of item 3, the `curl`
  too; noticed the working tree was already modified and proved it had not
  caused that; review accepted first time.
- `glm-5.3-flash` — checked first that `/work` is mounted read-only, then ran
  item 3 because it could change nothing; checked the output's whitespace
  with `cat -A`; the most tool calls on the general task (17).
- `glm-5.2` — the most methodical: a baseline hash of `calc.py`, the
  read-only mount checked, the commands run twice, a post-check that the
  file was byte-identical (22 tool calls); review accepted first time.

**Findings** (each also under *Open follow-ups* or *Closed follow-ups*):

- [feature-opencode-worker/probe-r3.md 1] The verdict check rejected `BLOCK: 1 issue`, the singular both Kimi models wrote — closed by `5321d76`, which accepts it.
- [feature-opencode-worker/probe-r3.md 2] The plan's `send` expectation was wrong, not the script: every model quoted the line the script sends, with the brief attached — corrected in the expectations above.
- [feature-opencode-worker/probe-r3.md 3] DeepSeek needs the workspace's Global region — the user left it as is.
- [feature-opencode-worker/probe-r3.md 4] A start refused upstream still lists with `turns=2` after a failed `send`, though no turn succeeded; cosmetic, `stop` removed both.
- [feature-opencode-worker/probe-r3.md 5] The README still said the external agents had not run against a real model — closed by `5321d76`.
- [feature-opencode-worker/probe-r3.md 6] About 7–9 minutes per model for general, `send` and review.

**Codex — the runner.** There is no L1a for Codex: no key to check and no
"Use balance" switch; `check --backend codex` is the runner's first line.
`feature-codex-agent`'s `probe-codex-l1/runner.sh.txt`, the script that ran
the Codex probe, byte for byte as recorded, with its host values masked —
`<tmp>` for the temp directory the host file names, `<home>` for the user's
home — which a later run fills in. It is saved as a file and run, never
pasted:

````bash
#!/usr/bin/env bash
# Live probe L1 for the Codex backend (feature-codex-agent), run by the manager
# session at the user's instruction of 2026-10-18: Codex's default model,
# effort high, read-only, in this repo; one start, one send, then stop.
set -u
export TMPDIR=<tmp>
cd <home>/projects/skills || exit 1
d=<tmp>/codex-l1/out; rm -rf "$d"; mkdir -p "$d"
S=plugins/glab/scripts/external-agent.sh
CLI="$HOME/.local/bin/codex"
marked() { # pids whose environment carries this agent's marker
  local p e; for p in /proc/[0-9]*; do
    e=$(tr '\0' '\n' <"$p/environ" 2>/dev/null) || continue
    printf '%s\n' "$e" | command grep -qx "GLAB_EXTERNAL_AGENT=$1" && echo "${p#/proc/}"
  done; }
"$S" check --backend codex --cli "$CLI" >"$d/check.out" 2>"$d/check.err"; echo "check rc=$?" | tee "$d/rc.txt"
printf '%s\n' 'Read AGENTS.md, then list the files under plugins/glab/scripts, one line each on what it does. Change nothing.' >"$d/brief.md"
SECONDS=0
"$S" start --backend codex --cli "$CLI" --effort high --role general --label l1 --repo . --timeout 900 --brief "$d/brief.md" >"$d/start.out" 2>"$d/start.err"
echo "start rc=$? ${SECONDS}s" | tee -a "$d/rc.txt"
id=$(command sed -n 's/^agent: \([^ ]*\) .*/\1/p' "$d/start.out" | head -n 1)
echo "id=$id" | tee -a "$d/rc.txt"
[ -n "$id" ] || exit 0
echo "marked after start: $(marked "$id" | wc -l)" | tee -a "$d/rc.txt"
printf '%s\n' 'In one sentence: which of those scripts would you read first to learn how a turn is stopped, and why?' >"$d/msg.md"
SECONDS=0
"$S" send "$id" --message "$d/msg.md" --timeout 900 >"$d/send.out" 2>"$d/send.err"
echo "send rc=$? ${SECONDS}s" | tee -a "$d/rc.txt"
echo "marked after send: $(marked "$id" | wc -l)" | tee -a "$d/rc.txt"
"$S" list >"$d/list.out" 2>&1
cp "$TMPDIR/glab-external-agents/$id/"transcript.* "$d/" 2>/dev/null
"$S" stop "$id" >"$d/stop.out" 2>"$d/stop.err"; echo "stop rc=$?" | tee -a "$d/rc.txt"
echo "marked after stop: $(marked "$id" | wc -l)" | tee -a "$d/rc.txt"
echo "agent dir left: $([ -e "$TMPDIR/glab-external-agents/$id" ] && echo yes || echo no)" | tee -a "$d/rc.txt"
git status --short -uall >"$d/git-status.out"
````

Its `marked` check reads `environ` newline-split, unlike `sweep_agent`'s
whole-entry match. It cannot show that a turn's commands carry the marker:
a turn that ends cleanly leaves nothing to find
(`[feature-codex-agent/probe-codex-l1.md not-verified]`); a later run that
should show it ends one turn with `stop` while a command is running, then
checks that no marked process is left (`[feature-codex-agent/plan.md unverified]`).

### 2026-10-18 — L1 (Codex)

Run by the manager session at the user's instruction in chat, "Yes, Codex
default model", as a script, never pasted, with the user's own Codex login;
the effort was the session's own level, `high`, which the user gave because
`CLAUDE_CODE_EFFORT_LEVEL` is unset; code under test `glab` 0.6.0
(`9108ac7`), in this repository. The record:
`git show 30f2c80:plan/feature-codex-agent/probe-codex-l1.md`; its files,
masked (`<home>`, `<user>`, `<uid>`, `<tmp>`) and scanned for tokens and key
prefixes, none found:
`git ls-tree -r --name-only 30f2c80 -- plan/feature-codex-agent/probe-codex-l1/`
(`runner.sh.txt`, `rc.txt`, `brief.md`, `msg.md`, `check.out`, `start.out`,
`send.out`, `list.out`, `stop.out`, `transcript.log`, `transcript.txt`).

| step | rc | what it showed |
|---|---|---|
| `check --backend codex` | 0 | `login: stored`, `sandbox: read-only starts`, `default: gpt-6.1-sol (predicted)`, seven listed models with their levels |
| `start --effort high --role general --repo .`, no `--model` | 0, 28 s | header `model: codex:gpt-6.1-sol · turn: 1`; Codex's block `model: gpt-6.1-sol`, `approval: never`, `sandbox: read-only`, `reasoning effort: high`, a UUID session id; it ran `cat AGENTS.md`, `rg --files …` and `head`/`cat` on the two scripts and answered correctly, marking what it had proven and what it had inferred |
| `send`, a one-sentence follow-up | 0, 6 s | `turn: 2`, the same model; the reply refers to its first answer |
| `list` | 0 | `idle  codex:gpt-6.1-sol  role=general  turns=2`, the repository at `9108ac7` |
| `stop` | 0 | `stopped: <id>`; the agent's directory gone |

Marked processes after `start`, after `send` and after `stop`: `0` each
time; `git status --short -uall` afterwards showed only the untracked
handoff.

- [feature-codex-agent/probe-codex-l1.md settled] Settled: the real Codex 0.163.0 accepts the script's `exec` and `exec resume` argv; it prints the header block in the form the script parses; `--effort high` reaches it as `reasoning effort: high`; its default model is read back and recorded (`codex:gpt-6.1-sol`); resume continues the session; no marked process was left after a turn or after `stop`. Also in its files, not in its *Settled* list: `check`'s predicted default is the model that ran, and the user's real login gives `login: stored` (`check.out`, `start.out`).

Not settled by L1, and kept under *Known limits*: that a real `exec` turn's
commands carry the marker while they run — since shown by the live developer
runs below (`[probe-codex-dev/probe-codex-dev.md]`); a sweep that kills a real leftover is still not shown.

### 2026-10-18 — developer runs (Codex)

Run by the manager session at the user's instruction in chat, "then go to
test this one", and then "Yes, rerun with a plan", as scripts, never pasted,
with the user's own Codex login; Codex's default model, the session's effort,
`high`; code under test `glab` 0.7.0 (`74c5830`). Each run started
`--role developer` on a **throwaway git repository** under the temp
directory, never the user's repository. The record:
`git show 7390a87:plan/probe-codex-dev/probe-codex-dev.md`; its files, masked
(`<home>`, `<user>`, `<uid>`, `<tmp>`, `<session-uuid>`) and scanned for
tokens and key prefixes, none found:
`git ls-tree -r --name-only 7390a87 -- plan/probe-codex-dev/` (per run,
`run1/` and `run2/`: `runner.sh.txt`, `rc.txt`, `brief.md`, `msg.md`,
`check.out`, `start.out`, `send.out`, `list.out`, `stop.out`,
`status.after-start`, `status.after-send`, `transcript.log`,
`transcript.txt` and their stderr files). Each runner builds the throwaway
repository, runs `check`, a `start`, a `send` and `stop`, scans
`/proc/*/environ` for the agent's marker after each, and compares `HEAD`,
`.git/config` and the hooks list before and after; run 2's adds
`plan/test/plan.md` (P1–P3) to the repository.

| run | step | rc | what it showed |
|---|---|---|---|
| 1, a bare brief, no plan | `check` | 0 | `login: stored`, `sandbox: read-only starts`, `default: gpt-6.1-sol (predicted)` |
| 1 | `start` | 0, 33 s | `changed: none`, `git: unchanged`; the reply `BLOCKED: no contract; provide plan.md or waived.md`; the repository's own `git status` empty |
| 1 | `send` | 0, 17 s | `changed: none`, `git: unchanged`; still blocked |
| 2, with `plan/test/plan.md` | `start` (P1, P2) | 0, 58 s | `BUILT`; `changed:  M calc.py`, `changed: ?? notes.txt`, `git: unchanged`; the repository's own `git status` ` M calc.py`, `?? notes.txt` |
| 2 | `send` (P3) | 0, 24 s | `BUILT`; only what that turn changed, `changed:  M calc.py`, `git: unchanged` |
| both | `stop` | 0 | the agent's directory gone |

On every turn Codex's header read `model: gpt-6.1-sol`, `approval: never`,
`sandbox: workspace-write [workdir]` and `reasoning effort: high`, which the
script accepts. The marker was shown on three of the four turns: asked to,
the model ran `printenv GLAB_EXTERNAL_AGENT` in its sandbox, which printed
the agent's id — on both turns of run 2 and the first of run 1; run 1's
second turn repeated the value from its first without running the command
(each run's `transcript.log`). Marked processes after `start`, after `send` and after `stop`:
`0` each time, in both runs. `HEAD`, `.git/config` and the hooks list were
unchanged after each run; the user's own repository was unchanged (only
the untracked handoff). Run 2's result was correct: `calc.sub(5, 3) == 2`,
the docstring "Return a minus b.", `notes.txt` reading `sub added`.

- [probe-codex-dev/probe-codex-dev.md settled] Proven on a real Codex turn: the developer header `workspace-write [workdir]`, which the script accepts; the change report on real edits — a modified file, a new file — matching git, per turn; `git: unchanged` when `.git` is untouched; the marker reaching the turn's commands, which closes the marker half of `[feature-codex-agent/probe-codex-l1.md not-verified]`; cleanup after each turn and at `stop`, with nothing left after either run.

Observed, and not shown, are under *Known limits*
(`[probe-codex-dev/probe-codex-dev.md observed]`,
`[probe-codex-dev/probe-codex-dev.md not-shown]`).

## Open follow-ups

- [fix-probe-findings/plan.md follow-up-2] A start refused upstream lists with `turns=2` — the same item as `[feature-opencode-worker/probe-r3.md 4]`; open.
- [fix-probe-findings/plan.md follow-up-4] Re-tune the profiles from the probe's transcripts — the same item as `[feature-opencode-worker/follow-ups.md 12]`; open.
- [fix-probe-findings/result.md E49] For a singular verdict the gap message reads `verdict says 1 issues, …` (the message prints n before `issues`), and E49 pins that text, as E19 pins the plural; if the message is ever reworded, the script and both cases change in one commit — open, accepted as worded.
- [feature-opencode-worker/probe-r3.md 4] A start refused upstream lists as an agent with `turns=2` after a failed `send` — open, cosmetic.
- [feature-opencode-worker/follow-ups.md 5] bwrap `--disable-userns`, so the agent cannot make user namespaces of its own — open; it waited for the live probe, which now shows OpenCode 2.0.31 running in the sandbox, so the change can be tried.
- [feature-opencode-worker/follow-ups.md 6] Bind only the files of `/etc` the backend needs, not the whole directory read-only — open, as 5.
- [feature-opencode-worker/follow-ups.md 7] No case drives the window C4 closes in `send` (an agent removed by a `stop` between `send`'s check and its lock): a race between two processes with no injection point; covered by reading the code — open.
- [feature-opencode-worker/follow-ups.md 9] No case drives R2-3's race (a `send` locking the old lock file after a `stop` renamed the agent aside), and none proves that `list` takes no lock; both rest on reading the code — open.
- [feature-opencode-worker/follow-ups.md 10] The raw `transcript.jsonl` can hold the key JSON-escaped, which the byte match of `redact_stream` cannot see; the decoded reply and `transcript.txt` are redacted (E14). Needs a decision on what the raw file is for — open.
- [feature-opencode-worker/follow-ups.md 12] All four family profiles were tuned from the user's notes, written by another model as templates, and stay UNVERIFIED as advice; re-tune each from its probe transcript, cite it, and confirm the report marker lines survive — open (*Profiles*; `[fix-probe-findings/plan.md follow-up-4]`).
- [feature-opencode-worker/follow-ups.md 16] Truncation before redaction: `opencode_error` cuts to 300 characters and the renderer to 500/2000 before `redact_stream`, so a key the raw pass missed and that crosses the cut keeps its prefix. Redact first, then cut (in `jq`, read the key from the environment) — open.
- [feature-opencode-worker/follow-ups.md 17] The redaction claims: the skill says the key is redacted from "both transcripts", and the header, the skill and `README.md` say "everything this script writes", while only literal occurrences are replaced. Re-encode the raw file through `jq -c .` before redaction and extend E14, or narrow the claim to "every literal occurrence" in all three files at once — open.
- [feature-opencode-worker/follow-ups.md 18] The symlink-parent check and the tar read are separate steps, so a parent swapped for a symlink in between is followed; needs another process already writing to the user's tree; accepted. Record it in the header, or refuse a symlink in a parent position after extraction — open.
- [feature-opencode-worker/follow-ups.md 19] `turn_alive` prints a stray stderr line when `turn.pid` is missing (bash applies `<` before `2>/dev/null`); use `{ read -r tpid st <"$1/turn.pid"; } 2>/dev/null || return 1` — open.
- [feature-opencode-worker/follow-ups.md 20] A `send` during a start's key lookup gets 10, not 11: `agent.json` is written after the lookup (up to 60 s). Write it with `ready: false` first, or return 11 when the directory exists, `agent.json` does not and the turn is alive — open.
- [feature-opencode-worker/follow-ups.md 21] `stop` waits 30 s, but a TERM trap runs only after the foreground command ends — up to the 60 s key lookup or a large copy — so `stop` can say BUSY although the turn ends later. Wait longer than the lookup, or run it in the background and `wait` — open.
- [feature-opencode-worker/follow-ups.md 22] Uncovered by any case: the `-ef` live-lock check in `lock_agent` (the race cannot be made deterministic) and the gitlink `mkdir` reason (no test repository has a 160000 entry) — open.
- [feature-opencode-worker/follow-ups.md 24] `tests/external-agent.test.sh` failed once, 1 of 47, in the planner's baseline run at `8cb2a92`, while the planner was also running mutants; 8 manager runs and 3 planner runs passed; likely a timing-sensitive case under load. Next time it fails, keep the full output to name the case — open.
- [feature-opencode-worker/follow-ups.md 25] The left-edge sentence still bans indent on every line of the report block, while the check reads only the markers, the verdict line and `rule:` lines; a model may flatten an indented code quote in a finding. Narrow it to "the verdict line and each rule: line start at the left edge", and change E48's `sl` with it — open, advisory.
- [feature-opencode-worker/plan-r3.md not-in-plan-3] Tuning a profile from the probe's transcripts — open, the same as `[feature-opencode-worker/follow-ups.md 12]`.
- [feature-opencode-worker/plan-r3.md not-in-plan-4] Moving DeepSeek's end date, 2026-10-31: a one-line change after re-reading the Go page, with a version bump — open; the models are refused upstream on this workspace anyway (`[feature-opencode-worker/probe-r3.md 3]`).
- [feature-opencode-worker/plan-r3.md not-in-plan-5] `slirp4netns --enable-sandbox`, once it can be proven on an installed copy — open.
- [feature-codex-agent/plan.md not-in-plan-3] `plan/SESSION-HANDOFF.md` sits in OpenCode agents' copies — the same item as `[feature-codex-agent/findings.md F1]`; open.
- [feature-codex-agent/findings.md F1] `plan/SESSION-HANDOFF.md` is untracked-but-not-ignored, so every OpenCode agent's copy holds it and its provider receives it (and a Codex agent can read it in the repository). Either ignore it, or say so in the skill — open.
- [feature-codex-agent/plan.md not-in-plan-4] A Codex profile tuned from real replies; Codex uses `default` only (D16) — open.
- [feature-codex-agent/plan.md not-in-plan-5] Removing a Codex session from Codex's history at `stop` (D12) — open.
- [feature-codex-agent/review-r1.md C-C] No bound on `wait "$jpid" "$epid"` in `run_host`: a process still holding the output pipes would block it — open, deferred by review r1's assignment.
- [feature-codex-agent/review-r1.md C-E] The group-kill PID-reuse window (the group TERM and KILL of `run_host` and `cleanup` are sent to a process group id with no start-time check, unlike the sweep) — open, deferred; the same item as `[feature-codex-agent/review-r1.md S-5]`.
- [feature-codex-agent/review-r1.md S-5] The group-kill window, as C-E — open, deferred.
- [feature-codex-agent/review-r1.md S-6] The header block is trusted on its position alone: the first `OpenAI Codex v<n>` block within the first 20 stderr lines — open, deferred.
- [feature-codex-agent/review-r1.md S-7] Environment values are passed newline-separated (`codex_env` and `opencode_env` print `NAME=value` one per line), so a value holding a newline would split, and its second line be exported as a name of its own; the values are the user's own, and OpenCode had the same protocol before — open, deferred; the same item as `[feature-codex-agent/result-p1-p4.md L238]`.
- [feature-codex-agent/result-p1-p4.md L238] `NAME=value` one per line, as S-7 — open.
- [feature-codex-agent/result-p1-p4.md L239] `codex_raw` writes the turn's stdout as Codex printed it, so a final message with no trailing newline joins the next turn's `=== turn n stderr ===` line in `transcript.log` — open, cosmetic; no case shows it.
- [feature-codex-agent/review-r2.md R2-d] The pre-turn sweep in `cmd_send` runs before `host_turn` is set, so a signal during it skips `cleanup`'s sweep; low impact, the next `send` or `stop` sweeps — open, deferred.
- [feature-codex-agent/review-r2.md R2-e] `debug models` runs with an empty `GLAB_EXTERNAL_AGENT`; harmless — pass the marker explicitly, or leave the variable out — open, deferred.
- [feature-codex-agent/review-r2.md R2-c] No case covers `cleanup`'s `host_turn` sweep (`external-agent.sh:203` as built): it acts only when a HUP, INT or TERM arrives during `run_host`'s own post-turn sweep, a one-scan window a signal cannot be aimed at reliably; the review's mutant passes 70/70; named as uncovered by revision 6 — open.
- [feature-codex-agent/result-p1-p4.md L556] E71's timing dependence: it is deterministic only by its margins — the unmarked stand-in floods the old filter about 2 s into a 6 s `slow` turn, about 1.5 s before the flood and 4 s after it; the `$$` mutant failed it on both of its runs, but a loaded host could move the flood past the turn's end — open.
- [feature-codex-agent/result-p5-p10.md F-d] The skill's *Reading what comes back* says `model: <backend>:<model>` without saying that for Codex this is the model that ran; the plan states that only in the manager's `:128` (the skill's announce step and the script's header do say it) — open: re-read at `30f2c80`, `SKILL.md:129` unchanged.
- [feature-external-developer/plan.md not-in-plan-1] A scratch directory or writable cache for the developer's commands (F4: a scratch root beside `run/` is possible, but adds a writable root, a `TMPDIR` override and a TOML-quoted path) — open.
- [feature-external-developer/plan.md not-in-plan-2] The script checking the developer's verdict line, as exit 8 does for the reviewer (F4: the manager reads the reply and the change itself, Q4 = A) — open.
- [feature-external-developer/plan.md not-in-plan-3] Reporting writes to ignored files: the report lists an ignored entry made or removed by name, not a write inside one (F3, R4.3) — open.
- [feature-external-developer/plan.md not-in-plan-4] An OpenCode developer — open.
- [feature-external-developer/plan.md not-in-plan-5] `check` proving that workspace-write starts, as it does for read-only — open.
- [feature-external-developer/plan.md not-in-plan-7] Splitting a develop stage across external developers, or an external and a Claude developer together — open.
- [feature-external-developer/result-p1-p4.md L292] A tracked symlink is always code ` M` when its line changes: its target is not hashed against the index — open (R4.4 states it as the meaning of ` M`).
- [feature-external-developer/result-p1-p4.md L293] A tracked file above 16 MiB is ` M` whenever its metadata changes, even if its content is unchanged — open (stated in R4.4's wording).
- [feature-external-developer/result-p1-p4.md L294] Each snapshot hashes every tracked file up to 16 MiB, so a very large tree can reach the time limit; a before-state that cannot be read in time fails the turn with exit 4 — open.
- [feature-external-developer/result-p1-p4.md L154] A load flake: E47, an OpenCode reviewer case, failed once with exit 9 (`NO ISOLATED NETWORK`) in an unchanged sandbox path during develop round 1, `FAIL 1/77`, and passed in the four runs after it; the diff touched none of the network code (searched). The same class, from the manager's Stage 8 dispatch record: the tests-docs reviewer saw OpenCode case E41 fail with `NO ISOLATED NETWORK` under parallel mutation load in review round 1, and E13 in round 2; each passed in a serial run. Next time, keep the full output — open; the same pattern as `[feature-opencode-worker/follow-ups.md 24]`.
- [feature-external-developer/result-p5-p7.md L171] The user's own filters under `git diff`: that `git diff --no-ext-diff --no-textconv --ignore-submodules=all` runs no filter the user configured in the top repository was UNVERIFIED (M3 shows the agent cannot add one to `.git/config`, but one the user configured can still run). Since R4.7 the prescribed inspection uses `cat-file blob`, which applies no filter, and runs no `git diff`; what stays open is that any later `git diff`, `git status` or gate on that tree runs the user's own configured filters on the host, as it does for any change — open.
- [feature-external-developer/result-p5-p7.md 4] `glab:manager` *Check what comes back* (`SKILL.md:146` at `33a28df`) describes only the external reviewer's one correction; the external developer's one `send` for missing report fields (D7) is stated in the skill's *The developer role* only — open.
- [feature-external-developer/record.md round-3-root] Review round 3 advisory, carried from the manager's Stage 8 dispatch record (no `review-r3.md` was written): `dev_refuse` with a repository top of `/` — `${t%/}` gives the empty prefix, so a state root under `/` is not refused there by that comparison; it still fails closed, at the `find` that follows. The fix would be `[ "$t" = / ] || …` or `[[ $r/ == "${t%/}"/* ]]` — open. R4.1 had meant to cover a top of `/`, and no case can reach it (`[feature-external-developer/plan.md not-covered]`).

## Closed follow-ups

- [feature-opencode-worker/follow-ups.md 1] L1b's two `|| exit 1` close an interactive shell when the block is pasted, and the given replacement `{ return 1 2>/dev/null || exit 1; }` closes it too — closed: L1 ran as a script (`probe-r3/runner.sh`), and *Live runs* runs the runner as a saved script, never pasted. Kept as an incident.
- [feature-opencode-worker/follow-ups.md 2] The skill's post-condition hash differed from the plan's record because of K3 — closed: a record correction; an analyzer was to expect it.
- [feature-opencode-worker/follow-ups.md 3] The offline Integrate block was not run by the developer — closed: run at Stage 4, `INTEGRATED` (*Offline run*).
- [feature-opencode-worker/follow-ups.md 4] The mutant table was not re-run; the tree's script and test were byte-identical to the plan's blocks — closed: record only.
- [feature-opencode-worker/follow-ups.md 8] The Kimi and GLM profiles were tuned from the user's notes — closed: superseded by `[feature-opencode-worker/follow-ups.md 12]`, which covers all four.
- [feature-opencode-worker/follow-ups.md 11] Rerun the offline block after R2-4 — closed: rerun, `INTEGRATED`; `send` ended in the expected timeout with no unknown-session error. That turn 2 sees turn 1 was then shown by the probe for Kimi and GLM.
- [feature-opencode-worker/follow-ups.md 13] The report check needs bare lines and the prompt never said so — closed: done in `fix-external-report-lines` (`167f432`).
- [feature-opencode-worker/follow-ups.md 14] `kimi.md`'s "every claim … names its `file:line`" was absolute — closed: "every claim about the code", in `fix-external-report-lines`.
- [feature-opencode-worker/follow-ups.md 15] `glm.md`'s "plan, then analyse, then act" went to a read-only agent — closed: "then answer", in `fix-external-report-lines`.
- [feature-opencode-worker/follow-ups.md 23] Record correction: `result-r3.md` said GLM's "one closing line" was gone; it is not, and it is about where the out-of-scope note goes, not the report shape — closed: a record correction.
- [feature-opencode-worker/probe-r3.md 1] The verdict check rejected `BLOCK: 1 issue` — closed by `5321d76` (`[fix-probe-findings/plan.md decision-1]`, E49).
- [feature-opencode-worker/probe-r3.md 2] The plan's `send` expectation was wrong, not the script: L1b expected the reply to quote `Answer in three numbered lines:`, but every model quoted the line the script really sends, with the brief attached — closed: corrected in *Live runs*.
- [fix-probe-findings/plan.md follow-up-3] `plan-r3.md` L1b's `send` expectation assumed the brief arrives inline — the same item as `[feature-opencode-worker/probe-r3.md 2]` — closed: corrected in *Live runs*.
- [feature-opencode-worker/probe-r3.md 3] DeepSeek refused upstream for want of the Global region — closed by the user's decision to leave it (`[fix-probe-findings/plan.md decision-2]`); the end date stands.
- [feature-opencode-worker/probe-r3.md 5] The README's "not yet run against a real model" was out of date — closed by `5321d76`: the sentence and its gate line say what the probe did and did not show.
- [feature-opencode-worker/probe-r3.md 6] Timing, 7–9 minutes per model — closed: information.
- [fix-probe-findings/plan.md follow-up-1] `AGENTS.md`'s live-run rule read "the live probe in that plan, which the user runs with their own key; no agent runs it", but the manager ran L1 at the user's instruction — closed by `feature-docs-specs`: `AGENTS.md`'s live-run exception, the user's wording (it runs only when the user says so in chat for that run and names the models; the user runs it, or the manager session does at that instruction, as a script; no dispatched agent runs it).

- [feature-opencode-worker/plan-r3.md not-in-plan-1] The Codex adapter (U12): `codex_models`, `codex_secret`, `codex_secret_var`, `codex_env`, `codex_argv`, `codex_session`, `codex_text`, `codex_error`, `codex_render`, a line in `known_backend`, a stub in the test; every Codex fact unresearched (findings-r3, *Later: Codex*) — closed by `feature-codex-agent` (`9108ac7`): the Codex adapter set, on the host rather than in the sandbox, with `codex_isolation`, `codex_model_allowed`, `codex_argv`, `codex_env`, `codex_session`, `codex_text`, `codex_error`, `codex_render`, `codex_verify` and `codex_check`, `codex` in `known_backend` and `model_optional`, a stub `codex` in the test, and the Codex facts researched (findings §3, §9); no `codex_secret`, since the script never reads the login.
- [feature-codex-agent/plan.md not-in-plan-2] A live Codex run, only on the user's instruction — closed: L1 ran on 2026-10-18 at the user's instruction (*Live runs*).
- [feature-codex-agent/findings.md F2] `~/.local/bin/codex` resolves into `~/.codex/packages/…`, so an agent started before a Codex update would fail its next `send` with exit 4 — closed by D11: the Codex CLI path is kept absolute but unresolved (E51).
- [feature-codex-agent/result-p5-p10.md F-a] The plan's post-condition S7, `command grep -c -F '- model: …'`, reads its pattern as options and exits 2; with `-e` it counts `1` — closed: plan text, a record of that change (the folder does not change); the tree held the line.
- [feature-codex-agent/result-p5-p10.md F-b] The skill gave mapping (i) no rule for `models: unavailable` — closed by revision 5's U5 (review r1 T5): send the level unchanged and say `effort <sent> (no levels known)` (`SKILL.md:81`, `:106` at `30f2c80`).
- [feature-codex-agent/result-p5-p10.md F-c] `README.md:59`'s "The script runs only Kimi and GLM models…" followed a sentence about Codex and meant OpenCode only from context — closed by review r1 T1: it reads "For OpenCode, the script runs only Kimi and GLM models" (`README.md:60` at `30f2c80`).
- [feature-opencode-worker/plan-r3.md not-in-plan-2] An external developer, until gates can run sandboxed too (U10) — closed by `feature-external-developer` (`33a28df`, `glab` 0.7.0) for Codex, on the user's A4: a `--role developer` Codex agent edits the working tree under Codex's `workspace-write` sandbox; the gates still run on the host, by the manager, after it has read the whole change without a filter (`[feature-external-developer/plan.md U3]`, R4.7); OpenCode stays read-only, and an OpenCode developer is `[feature-external-developer/plan.md not-in-plan-4]`.
- [feature-codex-agent/plan.md not-in-plan-1] The developer role, the next change: the external developer — Codex in `workspace-write`, editing the working tree directly as `glab:developer` does, and the pipeline wiring — closed by `feature-external-developer` (`33a28df`, `glab` 0.7.0): `--role developer`, the change report, the refusals, Rule 5's external developer, `/glab:develop`'s external path (*How it works now*, *The Codex developer role*).
- [feature-codex-agent/record.md readme-stale] `README.md`'s "Codex agents have been tested against a stub and offline against the real `codex`; none has run against a real model yet", out of date since L1 — closed by `feature-external-developer` (P7 revision 3, the user's request, `[feature-external-developer/questions.md revision-2]`): `README.md:121-124` at `33a28df` says Codex agents were tested "in one live probe on 2026-10-18 (`docs/specs/external-agents.md`, *Live runs*): one read-only agent on Codex's default model answered a task and a `send` on this repository".
- [feature-external-developer/result-p1-p4.md L150] `dev_state`'s `git status` could run a clean filter such as git-lfs on the host for racily clean entries — closed by R3.4: the snapshot runs no `git status` (E78).
- [feature-external-developer/result-p1-p4.md L151] The hooks digest hashed content and type, not mode, so making a hook executable was not reported — closed by R3.4's metadata in the digest (`result-p1-p4.md` *Round 2*).
- [feature-external-developer/result-p1-p4.md L152] One `hash-object` process per listed path — closed by R3.4: one batched `--stdin-paths` call per snapshot.
- [feature-external-developer/result-p1-p4.md L153] An unreadable after-state reported every path as `changed: --` — closed by R3.4: one `changed: unreadable` line and `git: changed` (E82).
- [feature-external-developer/result-p5-p7.md 1] `README.md` L9 still called every Codex agent read-only — closed by review r1 T1: "read-only except for a developer".
- [feature-external-developer/result-p5-p7.md 2] `develop.md` L2 and L8 named only `glab:developer` agents — closed in round 2: both name the external developer path.
- [feature-external-developer/result-p5-p7.md 3] Rule 5 *Carry it* offered only an external reviewer for a name the parameter does not take — closed by review r1's advisory: it offers an external developer, `codex` or `codex:<id>`, too.
- [feature-external-developer/result-p5-p7.md 5] The skill's *Its network* stated the read-only measurement only — closed by review r1 X6: it gives the developer's (M2, M4).
- [feature-external-developer/result-p5-p7.md L109] README's "its sandbox offline with `codex sandbox`" was true only once Stage 4 had run — closed: M1–M4 passed (`result-p5-p7.md` *Round 2*).
- [feature-external-developer/result-p5-p7.md L110] README cites `docs/specs/external-agents.md` *Live runs* for L1, which then held it only uncommitted — closed: `67628fe` committed it (*Live runs*, 2026-10-18 — L1 (Codex)).
- [feature-external-developer/result-p5-p7.md L207] `realpath -e`, a new requirement, was not in README — closed in round 3: README and the skill's Codex prerequisites name a `realpath` that takes `-e`.
- [feature-external-developer/record.md round-3-inspection] Review round 3 advisory (manager's Stage 8 dispatch record): the inspection wording — `diff -u -- - <path>`, never open a link or a special file, include each `!!` path — closed: taken with the user's approval (`[feature-external-developer/questions.md review-r3]`), in the skill's *The developer role* and `develop.md`.
- [feature-external-developer/record.md round-3-skill-l64] Review round 3 advisory (manager's Stage 8 dispatch record): the skill's `check` exit-4 text should also name `<tool> not found` — closed: taken in the scope-cut round; `SKILL.md:65-66` at `33a28df` reads "Exit 4 with `<tool> not found` is a missing tool: tell the user the line, and stop."
- [feature-external-developer/plan.md not-in-plan-6] A live Codex developer run, only on the user's instruction — closed by `[probe-codex-dev/probe-codex-dev.md]`: two runs at the user's instruction, on a throwaway repository, run 1 blocked by the contract with no plan, run 2 `BUILT` (*Live runs*, 2026-10-18 — developer runs).

## Incidents

- **A pasted block closed the shell** (follow-up 1): pasted into `bash -i`, a line ending `|| exit 1` printed `exit` and never the next line; the proposed `{ return 1 2>/dev/null || exit 1; }` did the same, because at an interactive top level `return` fails and `exit` runs. It only helps when the block is sourced. That is why live runs are saved and run as scripts.
- **One unexplained test failure under load** (follow-up 24): 1 of 47 in the planner's baseline at `8cb2a92`, case not captured, while mutants ran beside it.
- **Rev 2's build was archived and replaced.** The `external-worker` build of rev 2 (a developer and a reviewer on an external worker, a patch the manager applied, a shared network) could not work on OpenCode 2.0.31, and the user's new direction made external agents read-only tools; rev 3 restarted from `889b804` after archiving it: `git ls-tree -r --name-only 8cb2a92 -- plan/feature-opencode-worker/rev2-build/`.
- **A subshell outlived a SIGKILL** of the script and kept three processes running, in rev 3's first prototype; `exec setpriv --pdeathsig KILL` as a direct child fixed it (findings-r3 C6; the script's comment where it starts the sandbox).
- **The brief was written to the transcript unredacted** in the first prototype; the transcript now redacts what the manager sent too (C7).
- **Reading the sandbox's pid too early raced bwrap's own setup** (`nsenter: reassociate to namespace 'ns/user' failed`); waiting for the sandbox's command to report in removed it (N3).
- **`--disable-host-loopback` alone left the LAN open**: a host listener answered on the host's LAN and bridge addresses, and the LAN router answered one TCP connect (one SYN, no data); later runs used a documentation address instead, and the blackhole routes close them (N4, N5).
- **The probe's findings** 1–4 (*Live runs*): the singular verdict rejected; the plan's wrong `send` expectation; DeepSeek refused upstream; a refused start listing with `turns=2`.
- **O2 failed: a killed turn left Codex's helper running** (`feature-codex-agent`, Stage 4 round 2, `integration.md` *O2 on the host*). After the outermost `setpriv` of D7's chain was SIGKILLed, Codex's sandbox helper (`comm=codex`, reparented to pid 1) and its `sleep` were still alive 2 s and 20 s later, in a session and group of their own, out of reach of the script's group kill; the measurement killed them by pid. Classified `PLAN WRONG` for P3/D7. The user chose "measure, then amend the plan"; of three candidates, SIGTERM or SIGINT first failed, the marker and a sweep by PID worked, a systemd scope worked with a new dependency (findings §9.9). Revision 4's D31 answered it, and O2 passed against it in rounds 3 and 5. That the same holds for a real `codex exec` turn is still UNVERIFIED (*Known limits*).
- **Stage 1b went past its cap, with the user's consent** (`feature-codex-agent`). Round 1/2 returned NOT BUILDABLE from all three analyzers (the unwritten host text, the missing stderr in `transcript.log`, sandbox-only lines in the common turn); round 2/2 found every round-1 item resolved and still five blockers, none a design problem (the `debug models` shape and `login status`'s exit status unrecorded, coverage gaps, an unrunnable host-text grep, steps no post-condition could catch, no `## Record`). The two-round cap was then spent; the user chose to fix the five and run one narrow third check of those fixes only, and allowed the one offline `debug models --bundled` run that recorded the shape (`[feature-codex-agent/questions.md stage-1b]`). Later, conformance reached round 4/4 with one divergence — the test count, after review r2 split E70 — which the user's revision 6 recorded.
- **The committer caught unmasked host values** (`feature-codex-agent`; carried from the manager's Stage 8 dispatch record, since the folder does not tell it): two of the three catches of 2026-10-18. First, at the change's commit, `glab:committer` caught the username, home paths and uid in `findings.md` — an `ls -l` line, `XDG_RUNTIME_DIR` and a cgroup path — and the Claude CLI path in `result-p5-p10.md`; they were masked before `9108ac7`. Second, at the probe-record commit, it flagged the Codex session id in `probe-codex-l1/`, which the manager masked before pushing `30f2c80`. Each time the commit was stopped, the values masked and the commit made afterwards, so nothing unmasked was committed. The third catch is `feature-external-developer`'s, below.
- **Codex's sandbox would not start inside the no-network wrapper** (`feature-codex-agent`, Stage 4 round 1): under `bwrap --unshare-net`, AppArmor's `unpriv_bwrap` blocks the nested bwrap Codex uses, so S1, O2 and `check`'s sandbox line measured nothing there, and `check` exited 12 in O1. The user's Stage 4 allowance moved S1 and O2 to the host under `codex sandbox` only (*Measurements*). The first two host scripts then failed in the integrator's own code (`P0: unbound variable`, then the same on `CX`: the subshell unset the exported values before reading them); the third copied them into shell variables first.
- **The host stream filters held the agent's lock** (`feature-codex-agent`, develop round 2): E69 first failed with `rc=11 … BUSY`, because the two host output filters inherited the lock descriptor and lived as long as the helper's stand-in held the streams, so after a SIGKILL `stop` could never take the lock and reach its sweep. The host filters now close the lock descriptor, as `wire_network`'s log filter already did (`[feature-codex-agent/result-p1-p4.md L297]`).
- **The sweep made the suite slow**: one `sweep_agent` took about 1.3 s (a 1 s second pass every time, plus the scan) and ran at every `stop`, OpenCode's included, so `tests/external-agent.test.sh` went from about 38 s to about 3 min. Review r1 C3's fixes — a second pass only after a kill, no sweep for a sandbox backend's `stop`, `environ_has` instead of `tr` — brought it to about 52 s.
- **A sweep that matched inside another value** (review r1 C-D): reading `environ` newline-split would match the marker inside another variable's value; `environ_has` compares whole NUL-separated entries, and E69's second decoy pins it.
- [feature-codex-agent/findings.md L32] **The wrong flow was built first** (the incident `findings.md:32` points to, "`plan/SESSION-HANDOFF.md`, *Incident, 2026-10-18*"; that file is never committed, so its text was taken from the manager's handoff at record time and reworded lightly). The manager misread "let's setup the same flow for codex" as porting glab to run inside Codex, never asked which flow was meant, and built `feature-codex-host`: a plan, Stage 1b twice, five slices and a generator, gates green, review round 1 started. Three signals were missed: the research brief itself was framed as porting; the user's "codex flow almost the same to compare with you"; and the planner's note that the "Codex adapter" follow-up was "a different thing". The user stopped it, and all of it was reverted — `git restore` and removal of the new files; never committed, never pushed; `~/.codex` never written; no Codex model run. Lesson: when a request can mean two things, ask which before dispatching research. That is why this change's findings open by saying it is not glab running inside Codex.
- **The planner ran more than its brief** (`feature-codex-agent` findings, *Disclosure*): beyond Codex's help and version, it ran `codex features list`, `codex debug models` and `codex login status`, each with a throwaway `CODEX_HOME` and `HOME`, inside `bwrap --unshare-net`, with stdin `/dev/null`, none sending a prompt; and `file -L ~/.local/bin/codex` read the ELF header of the binary under `~/.codex/packages/`, the only thing under `~/.codex` read. Reported for the manager to judge.
- **The planner's write into its own plan folder was refused** (`feature-codex-agent`): the plan files were written under `$TMPDIR` with a `SHA256SUMS`, and the manager verified and copied them in, as for `feature-docs-specs`.
- **Reviews found host-execution defects in the first change report** (`feature-external-developer`, review rounds 1 and 2). Round 1 (BLOCK 6 and BLOCK 6): the report's `git status` ran the repository's clean filters on the host for a merely touched tracked file, and a submodule's, and the manager's prescribed `git status` ran a submodule's `core.fsmonitor` — the reviewer reproduced `SUB-RAN-ON-HOST`, `RAN-ON-HOST` and `FSMON-RAN` (X1); a nested repository the agent could `git init` hid everything inside it (X2); a hook in an ignored `core.hooksPath` directory (husky v9) went unreported and then ran on the next commit, `HOOK-RAN` (X3); a `TMPDIR` inside the repository would have let the agent rewrite the script's state and an `agent.json` `cli` run unsandboxed (X4); the post-turn snapshot had no time bound (a 4 GiB sparse file took 14 s) (X5). Round 2: the prescribed replacement, `git diff --no-ext-diff --no-textconv --ignore-submodules=all`, runs clean filters and fsmonitor too, reproduced by both reviewers (R2-1); a `find` without `-files0-from` failed silently and the report missed every tracked edit (R2-2); a `.gitignore` the agent wrote hid new files (R2-3). Each script fix was pinned by a case its one-change mutant fails (E78–E84); R2-1 and the manager's inspection instructions are text fixes, with no case (*How it works now*).
- **The guard did not converge, and the scope was cut** (`feature-external-developer`). After round 2 the tests reviewer warned that the guard was growing faster than it converged; the user chose one last minimal round, removing logic where possible (`[feature-external-developer/questions.md review-r2]`). Round 3's reviewers both returned SHIP WITH SCOPE CUT: the `find` probe left `check`, so no read-only Codex role depends on it; the user approved the cut and the inspection wording (`[feature-external-developer/questions.md review-r3]`).
- **The time budget was overrun** (`feature-external-developer`). The user asked for about an hour, kept small (`questions.md` *Approval*); the budget was already past when review round 1 returned, and the change went on through two fix rounds, revisions 3 and 4, and a third review round. Coverage gaps were accepted "for the time budget" on the way (`dev_snap` failing before the turn; `result-p1-p4.md`).
- **The committer caught unmasked host values — the third catch** (`feature-external-developer`; carried from the manager's Stage 8 dispatch record): at this change's commit, `glab:committer` caught the M5 Codex session id in `integration.md` (L227, L238) and the CLI path in `result-p5-p7.md` L57; they were masked before `33a28df` (`integration.md` now shows `<session-uuid>`). As with the two catches of `feature-codex-agent` above, the commit was stopped, the values masked, and the commit made afterwards: three catches in all, and nothing unmasked committed.
- **The plan's own measurement command was wrong** (`feature-external-developer`, Stage 4 round 1): `WW` passed `-C "$X/r"`, which `codex sandbox` 0.163.0 takes only with `-P`, so every call exited 2 and nothing was measured; the round was re-run without it. Not a build fault: the script never passes `-C`.

## Records

- 2026-10-17 · feature-opencode-worker · read-only external agents: `external-agent.sh` and `glab:external-agents`, the external reviewer of Rule 5, Rule 6; rev 2's external-worker build archived; the live probe L1 · change 7139e62 · records 8cb2a92 5e9b3a8 51043c4 · plan: `git ls-tree -r --name-only 51043c4 -- plan/feature-opencode-worker/` (one file: `git show 51043c4:plan/feature-opencode-worker/<file>`)
  - [feature-opencode-worker/findings-r3.md L169] Later: Codex → `[feature-opencode-worker/plan-r3.md not-in-plan-1]`.
  - [feature-opencode-worker/findings-r3.md L180] UNVERIFIED, in one place → `[feature-opencode-worker/findings-r3.md unverified]`.
  - [feature-opencode-worker/findings.md L374] The live probe (user-run, later in the plan) → superseded by rev 3's L1, which ran on 2026-10-17 (*Live runs*); what it did not show is `[feature-opencode-worker/probe-r3.md not-verified]`.
  - [feature-opencode-worker/findings.md L385] Later: Codex → `[feature-opencode-worker/plan-r3.md not-in-plan-1]`.
  - [feature-opencode-worker/findings.md L453] UNVERIFIED, in one place → `[feature-opencode-worker/findings.md unverified]`.
  - [feature-opencode-worker/plan-r3.md L2753] L1 — the live probe → ran 2026-10-17: *Live runs*; the record's findings `[feature-opencode-worker/probe-r3.md 1]` to `6`.
  - [feature-opencode-worker/plan-r3.md L2900] Not in this plan → `[feature-opencode-worker/plan-r3.md not-in-plan-1]` to `not-in-plan-5`.
  - [feature-opencode-worker/plan-r3.md L2909] UNVERIFIED, in one place → `[feature-opencode-worker/plan-r3.md unverified]`.
  - [feature-opencode-worker/plan.md L2097] L1 — the live probe (rev 2) → superseded by rev 3's L1; nothing open of its own.
  - [feature-opencode-worker/plan.md L2211] Not in this plan (rev 2) → the Codex adapter `[feature-opencode-worker/plan-r3.md not-in-plan-1]`, tuning a profile `not-in-plan-3`, DeepSeek's end date `not-in-plan-4`.
  - [feature-opencode-worker/probe-r3.md L109] Not verified → `[feature-opencode-worker/probe-r3.md not-verified]`.
  - [feature-opencode-worker/result-r3.md L629] Follow-ups → `[feature-opencode-worker/follow-ups.md 1]` to `12`, each under its tag.
  - [feature-opencode-worker/result-r3.md L645] Not done → L1 ran (*Live runs*); the offline block ran (`[feature-opencode-worker/follow-ups.md 3]`); the mutant run `[feature-opencode-worker/follow-ups.md 4]`; the commits are `7139e62` and `8cb2a92`; its UNVERIFIED items under *Known limits*, the three stub-only claims under this tag.
  - [feature-opencode-worker/result.md L243] Follow-ups (rev 2) → nothing open: its hashes describe the archived rev-2 build.
  - [feature-opencode-worker/result.md L250] Not done (rev 2) → rev 2's L1 and commits were never made; superseded by rev 3; nothing open.
- 2026-10-17 · fix-external-report-lines · an external reviewer is told its report lines start at the left edge; Kimi's `file:line` rule and GLM's "then answer" narrowed · change 167f432 · records 5e9b3a8 · plan: `git ls-tree -r --name-only 5e9b3a8 -- plan/fix-external-report-lines/` (one file: `git show 5e9b3a8:plan/fix-external-report-lines/<file>`)
  - [fix-external-report-lines/result.md L197] Follow-ups → `[feature-opencode-worker/follow-ups.md 13]`, `14`, `15` closed; `[feature-opencode-worker/follow-ups.md 24]` open.
  - [fix-external-report-lines/result.md L213] Not done → `[fix-external-report-lines/result.md unverified]`.
- 2026-10-17 · fix-probe-findings · the reviewer check accepts `BLOCK: 1 issue`; the README sentence on what the probe showed, and its gate line; the profiles' *Notes* corrected · change 5321d76 · records 6838133 · plan: `git ls-tree -r --name-only 6838133 -- plan/fix-probe-findings/` (one file: `git show 6838133:plan/fix-probe-findings/<file>`)
  - [fix-probe-findings/plan.md L333] Follow-ups (out of scope, not done here) → `[fix-probe-findings/plan.md follow-up-1]` to `follow-up-4`.
  - [fix-probe-findings/result.md L226] Follow-ups → `[fix-probe-findings/result.md E49]`.
  - [fix-probe-findings/result.md L238] Not done → the probe records commit landed before the fix (`51043c4`, then `5321d76`); mutants m1–m3 not re-run and the line-number drift: nothing open.
- 2026-10-18 · feature-docs-specs · recorded in `docs/specs/workflow.md`, its primary area; here it closed `[fix-probe-findings/plan.md follow-up-1]` and carried `[feature-docs-specs/plan.md D6]` and `[feature-docs-specs/questions.md Q1]` · plan: `git ls-tree -r --name-only 09d2787 -- plan/feature-docs-specs/` (one file: `git show 09d2787:plan/feature-docs-specs/<file>`)
- 2026-10-18 · feature-codex-agent · Codex as a read-only external-agent backend, on the host in the user's repository under Codex's own read-only sandbox, with the user's own login; Codex's default model read back, `--effort`, the exit-12 header check, the D31 marker sweep; OpenCode's code into its adapter, plus E66's session check; 71 tests; `glab` 0.6.0; the live probe L1 · change 9108ac7 · records 30f2c80 · plan: `git ls-tree -r --name-only 30f2c80 -- plan/feature-codex-agent/` (one file: `git show 30f2c80:plan/feature-codex-agent/<file>`; the whole folder: `git archive 30f2c80 plan/feature-codex-agent/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `30f2c80` is the last commit on `origin/main` that holds it.
  - [feature-codex-agent/findings.md L700] 8. Follow-ups noticed, not in this change → `[feature-codex-agent/findings.md F1]` open, `F2` closed.
  - [feature-codex-agent/findings.md L913] 9.6, what still needs a model → `[feature-codex-agent/findings.md unverified]`; revision 1's §6 measurements were superseded by §9.6 (S2 dropped with the login mechanisms; S1, O1 and O2 rewritten for the host design).
  - [feature-codex-agent/plan.md L1424] Tests and coverage, *Not covered by any case, and accepted* → `[feature-codex-agent/plan.md not-covered]`.
  - [feature-codex-agent/plan.md L1492] UNVERIFIED, in one place → `[feature-codex-agent/plan.md unverified]`.
  - [feature-codex-agent/plan.md L1520] Not in this plan → `[feature-codex-agent/plan.md not-in-plan-1]` to `not-in-plan-5`; `[feature-opencode-worker/plan-r3.md not-in-plan-2]` stays open.
  - [feature-codex-agent/plan.md L1531] Revision 5: still to build → built: the socket clause and D32's wording (`result-p5-p10.md` *Round 4*, S40–S42), the script header (`result-p1-p4.md` *Round 4*), O2 rerun against the built sweep (`integration.md` *Round 5*, pass); nothing open.
  - [feature-codex-agent/plan.md L1587] Changes since revision 1 → every Stage 1b item of `analysis-1b-r1.md` (A1–A3) and `analysis-1b-r2.md` (B1–B3) answered there, then revisions 4–6 (*Decisions that still bind*); nothing open.
  - [feature-codex-agent/review-r1.md L133] Assignment → every blocking finding (C1–C3, S1–S3, T1–T6) and every taken advisory fixed, confirmed by review r2; the deferred `[feature-codex-agent/review-r1.md C-C]`, `C-E`, `S-5`, `S-6`, `S-7` open.
  - [feature-codex-agent/review-r2.md L50] Advisory, deferred to follow-ups → `[feature-codex-agent/review-r2.md R2-d]`, `R2-e` open; R2-1 and R2-2 fixed (E70/E71, D32), R2-a and R2-b taken, `R2-c` open as named uncovered. No `review-r3.md` is in the folder: the third round's verdict is not recorded there.
  - [feature-codex-agent/result-p1-p4.md L234] Follow-ups → `[feature-codex-agent/result-p1-p4.md L238]` and `L239` open.
  - [feature-codex-agent/result-p1-p4.md L241] Not done → P5–P10 were the other slice, done; S1, O1 and O2 ran at Stage 4; its UNVERIFIED on the real argv and header was settled by O1 and L1.
  - [feature-codex-agent/result-p1-p4.md L533] Round 4 (review r2), E71's *Determinism* → `[feature-codex-agent/result-p1-p4.md L556]` open.
  - [feature-codex-agent/result-p5-p10.md L238] Follow-ups → `[feature-codex-agent/result-p5-p10.md F-a]`, `F-b`, `F-c` closed, `F-d` open.
  - [feature-codex-agent/result-p5-p10.md L252] Not done → the other slice and `docs/specs/`: done, this record.
  - [feature-codex-agent/result-p5-p10.md L390] Not changed, flagged → the stale plan text resolved by revision 5; "neither can change anything" and Rule 6's "It changes nothing" speak of the agent's work, and Codex's own `~/.codex` writes are stated in the data note; the socket limit → `[feature-codex-agent/result-p5-p10.md L578]`.
  - [feature-codex-agent/integration.md L611] Items these runs leave open, and `L725` Still unverified after round 3 → `[feature-codex-agent/integration.md open]`.
  - [feature-codex-agent/probe-codex-l1.md L44] What this settles, and what it does not → `[feature-codex-agent/probe-codex-l1.md settled]` (*Live runs*) and `[feature-codex-agent/probe-codex-l1.md not-verified]`.
- 2026-10-18 · feature-external-developer · Codex as an external developer: `--role developer` under Codex's `workspace-write` sandbox, `/tmp` and `$TMPDIR` excluded and no network; the header check for `workspace-write [workdir]`; the change report and its `git:` digest, with no `git status`; the refusals; the developer's first message and `default.md`'s developer section; Rule 5's external developer; 84 tests; `glab` 0.7.0 · change 33a28df · plan: `git ls-tree -r --name-only 33a28df -- plan/feature-external-developer/` (one file: `git show 33a28df:plan/feature-external-developer/<file>`; the whole folder: `git archive 33a28df plan/feature-external-developer/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `33a28df` is the last commit on `origin/main` that holds it: the record commit removes the folder.
  - [feature-external-developer/plan.md L883] Record → this record, in this file, `docs/specs/workflow.md` and `docs/specs/marketplace.md`; the closes it names, `[feature-codex-agent/plan.md not-in-plan-1]` and `[feature-opencode-worker/plan-r3.md not-in-plan-2]`, under *Closed follow-ups*.
  - [feature-external-developer/plan.md L898] Not in this plan → `[feature-external-developer/plan.md not-in-plan-1]` to `not-in-plan-7` open; its eighth item, the README sentence, closed by its own revision 3 (`[feature-codex-agent/record.md readme-stale]`).
  - [feature-external-developer/plan.md L809] After, step 4 → `[feature-external-developer/plan.md after-4]`.
  - [feature-external-developer/plan.md L466] Not covered by any case, accepted (and the revision 3 and 4 lists) → `[feature-external-developer/plan.md not-covered]`.
  - [feature-external-developer/plan.md L916] Changes in revision 2 to 4 → the Stage 1b round 1 blockers (the default profile, the searches) and the review fixes, all built; revision 3's gap, `README.md` *Requirements* not naming `find -files0-from` and `realpath -e`, closed by revision 4 (`[feature-external-developer/result-p5-p7.md L207]`); nothing open.
  - [feature-external-developer/findings.md L115] F4, rejected boundaries → a patch applied by the manager, a writable `/tmp`/`$TMPDIR` or scratch root (`not-in-plan-1`), a new exit code for a changed `.git`, the script validating the developer's verdict (`not-in-plan-2`); nothing else open.
  - [feature-external-developer/review-r1.md L117] Assignment → X1–X6 and T1–T6 with their advisories fixed in revision 3 and confirmed by review r2, T4 half done until R2-4.
  - [feature-external-developer/review-r2.md L50] Assignment → R2-1 to R2-7 and the advisories fixed in revision 4; no `review-r3.md` was written: round 3's verdicts and cut are in `questions.md` *Review round 3*, its advisories, from the manager's Stage 8 dispatch record, `[feature-external-developer/record.md round-3-inspection]` and `round-3-skill-l64` closed, `round-3-root` open.
  - [feature-external-developer/result-p1-p4.md L146] Follow-ups → `L150` to `L153` closed, `L154` open.
  - [feature-external-developer/result-p1-p4.md L290] Follow-ups (not built) → `L292`, `L293`, `L294` open.
  - [feature-external-developer/result-p1-p4.md L156] Not done → P5–P7 the other slice, done; Stage 4 M1–M5 ran (*Measurements*); the header string settled by M5.
  - [feature-external-developer/result-p5-p7.md L107] Flags for the manager → `L109`, `L110` closed.
  - [feature-external-developer/result-p5-p7.md L112] Follow-ups → `1`, `2`, `3`, `5` closed, `4` open.
  - [feature-external-developer/result-p5-p7.md L169] Unverified (round 2) → `[feature-external-developer/result-p5-p7.md L171]` open; the version-match note on the header settled.
  - [feature-external-developer/integration.md L298] Still UNVERIFIED → `[feature-external-developer/integration.md unverified]`.
- 2026-10-18 · probe-codex-dev · the first live Codex developer runs, on a throwaway repository: run 1 blocked by the contract with no plan, run 2 `BUILT`; `workspace-write [workdir]`, the change report matching git per turn, `git: unchanged`, the marker carried, nothing left · records 7390a87 · plan: `git ls-tree -r --name-only 7390a87 -- plan/probe-codex-dev/` (one file: `git show 7390a87:plan/probe-codex-dev/<file>`; the whole folder: `git archive 7390a87 plan/probe-codex-dev/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `7390a87` is the last commit on `origin/main` that holds it: the record commit removes the folder.
  - [probe-codex-dev/probe-codex-dev.md L49] What this settles → `[probe-codex-dev/probe-codex-dev.md settled]` (*Live runs*), `observed` and `not-shown` (*Known limits*); closes `[feature-external-developer/plan.md not-in-plan-6]` and the marker half of `[feature-codex-agent/probe-codex-l1.md not-verified]`.
