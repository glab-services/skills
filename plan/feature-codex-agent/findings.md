# feature-codex-agent — findings

Planner's findings, 2026-10-18, at `067b719` (`glab` 0.5.0). Stage 1 only:
nothing is implemented, no repo file is edited, nothing is committed.

**Revision 2 (2026-10-18, after the user's answers in `questions.md`
*Answers*).** Sections 1 to 8 are revision 1, kept as written. The answers
change what binds:

- Q1 = A: this slug is the read-only Codex backend only.
- Q2/Q3: Codex runs on the host, in the real repository, under Codex's own
  read-only sandbox. That supersedes revision 1's design for Codex: §3.4's
  mechanisms L1–L4, §3.5's per-turn `CODEX_HOME`, §3.6's bypass of Codex's
  sandbox, §3.7's copy-based reasoning, §4 entirely (it moves to the
  developer change), and §6's S2.

Section 9 holds what is new and what binds now. The facts quoted in §3 are
still proven, and §9 cites them.

Where these files are: the Write tool refused `plan/feature-codex-agent/`
("Subagents should return findings as text"), so they were written to
`/data/tmp/claude/feature-codex-agent-plan/` with a `SHA256SUMS`, as the brief
says. The manager verifies and copies them into `plan/feature-codex-agent/`.

**What this change is.** A second backend, Codex, for
`plugins/glab/scripts/external-agent.sh`: the manager starts, sends to, lists
and stops a Codex agent the way it does an OpenCode (Kimi/GLM) agent today,
and, new, a Codex agent can also be a write-capable **developer**. It is
**not** glab running inside Codex: nothing is installed into Codex, no Codex
plugin manifest is written, and the plugin never writes `~/.codex` unless the
user picks a login mechanism that does (Q2, L1/L2).
(`plan/SESSION-HANDOFF.md`, *Incident, 2026-10-18*.)

Risk tier proposed: **full**. The change handles a secret (the user's
ChatGPT login), and the developer half writes into the user's real working
tree (`glab:manager` *Pick the tier*: "code that … handles secrets").

## Evidence rules used here

- **Proven**: a command ran and its output is quoted, or a vendor source line
  at tag `rust-v0.163.0` (commit `129b8ec7ee6f4511557a4856279f529025c25af4`,
  the installed version) or a vendor doc page is quoted, with its URL.
- **Inferred**: reasoned from code or docs; what would prove it is named.
- `UNVERIFIED: <claim> — <why>`: not shown, with the measurement that would
  show it.

Source files were fetched read-only with
`gh api "repos/openai/codex/contents/<path>?ref=rust-v0.163.0"` into
`/data/tmp/claude/fca-src/` (removed at the end of this session). Source URLs below
have the form `https://github.com/openai/codex/blob/rust-v0.163.0/<path>#L<n>`.

**Disclosure: what this planner ran beyond the brief.** The brief allowed only
Codex's help and version, with a throwaway home. I also ran these three, each
with a throwaway `CODEX_HOME`/`HOME` under `/data/tmp/claude`, inside
`bwrap --unshare-net` (no network), with stdin `/dev/null`: `codex features list`,
`codex debug models` (the bundled catalog) and `codex login status` (`Not logged
in`). None of them sends a prompt, and none touched `~/.codex`'s auth, config or
sessions. `file -L ~/.local/bin/codex` read the ELF header of the binary the
symlink points to, which lives under `~/.codex/packages/`. That binary is the
only thing under `~/.codex` that was read; nothing there was listed. I report
it so the manager can judge it.

## Baseline

    $ export TMPDIR=/data/tmp/claude; git rev-parse --short HEAD; bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null | tail -n 2
    067b719
    ok E36 after every case: the real repository is unchanged byte for byte, no agent is left, and no sandbox, slirp4netns or stub process runs
    PASS 49/49

(49 `ok` lines counted, `rc=0`.)

## 1. The current script: what is OpenCode-specific

`plugins/glab/scripts/external-agent.sh` has 920 lines. The adapter contract
is the comment at `:180-184`: `<b>_models, <b>_secret, <b>_secret_var, <b>_env,
<b>_argv, <b>_session, <b>_text, <b>_error, <b>_render`, "plus one line in
known_backend and a stub in the test". Outside the adapter section, the lines
below are OpenCode-specific or read-only-specific (proven by reading the file
at `067b719`):

| where | what | why it blocks Codex or a developer |
|---|---|---|
| `:2-5`, `:51-56`, `:67-69` | header prose: "an OpenCode session (today)", `~/.local/share/opencode`, `~/.config/opencode`, "The backend's key" | the header is one-fact text (exit codes, isolation) |
| `:111` | `readonly DATA_IN_HOME=.local/share/opencode` | Codex's state is under `$CODEX_HOME` (§3.5) |
| `:515-516` | `sandbox_args`: `--bind "$adir/data" "/home/worker/$DATA_IN_HOME"`, `--ro-bind "$run/empty" /home/worker/.config/opencode` | the mounts depend on the backend |
| `:526-532` | `INNER`: `exec "$@" </dev/null` | Codex takes its prompt on stdin (`codex exec -`, §3.2) |
| `:163-169` | `redact_stream`: one secret, `K=$secret` | a Codex login is several strings (§3.4) |
| `:328-335` | `read_secret`: one string, `^[[:graph:]]{8,}$`, message "run \`$2 auth login\` for OpenCode Go" | the message depends on the backend; Codex's login is a file |
| `:607` | `export "$("${backend}_secret_var")=$secret"` | Codex reads no environment variable for a ChatGPT login (§3.4) |
| `:291`, `:773`, `:898` | the `known_backend` case, and "(known: opencode)" twice | the list of known backends |
| `:315-326` | `model_allowed`: an allowlist of exact ids with end dates | "all Codex models are allowed" (user answer 2) |
| `:459-496` | `first_prompt`: "/work is a read-only copy … You have no web tool" | the text depends on the role and the backend |
| `:767` | `--role must be general or reviewer` | there is no developer role |
| `:794` | `chmod -R a-w "$adir/work"`, and at `:519` `--ro-bind "$adir/work" /work` | a developer needs a writable copy |
| `:828` | send: `[[ $session =~ ^ses_[A-Za-z0-9]{1,64}$ ]]` | Codex ids are UUIDs (§3.3) |
| `:681-711` | `finish_turn`: a validator for the reviewer only | a developer's report has its own verdicts |
| `:900-907` | `check`: `key: stored`, `models: …` from the allowlist | the output depends on the backend |

Call sites of each function this change would touch (`command grep -n` on the
script, comment lines excluded): `redact_stream` 598, 599, 646, 649, 671, 680;
`read_secret` 786 (start), 831 (send), 905 (check); `sandbox_args` 591
(`run_turn`); `model_allowed` 774 (start), 829 (send); `known_backend` 773,
898; `first_prompt` 797; `reviewer_tail` 495, 834; `finish_turn` 802, 837;
`run_turn` 798, 836; `copy_repo` 792; `cli_ok` 586, 776, 899;
`<b>_secret_var` 607; `<b>_session` 800; `<b>_models` 317, 318, 907. Every
call site is inside the script. Outside it, two things call the script:
`tests/external-agent.test.sh` (all 49 cases), and the manager through
`glab:external-agents`. Both rely on three things: one turn's output contract
(header, `reply:`, `| ` lines, `end:`), the exit-code table, and the
`agent.json` fields `backend model profile role cli session ready turns`.
Both roles and every backend share this contract.

## 2. The pipeline as it stands

- **External agents are read-only by a binding decision.**
  `docs/specs/external-agents.md` *Decisions that still bind* lists two:
  `[feature-opencode-worker/plan-r3.md U10]`, "Read-only work only: no patch
  is produced or applied; the external developer is dropped until gates can
  be sandboxed, because applying an external patch runs untrusted code on the
  host through the gates", and D34, "The external reviewer stays, the external
  developer goes". The user's new instruction (2026-10-18, answer 4)
  overturns them. U10's stated reason is still true, so it is put to the user
  (Q4).
- **Rev 2 once built an external developer.** It is archived at
  `git ls-tree -r --name-only 8cb2a92 -- plan/feature-opencode-worker/rev2-build/`.
  The worker wrote in a copy, and the script produced `changes.patch` with
  `git diff-tree -p --binary`. A patch holding the key was refused (exit 9
  SECRET IN OUTPUT), and so was a binary change (exit 10 BINARY IN PATCH). The
  manager applied the patch unchanged after `git apply --stat`/`--summary`,
  and refused a symlink or a mode change unless a plan step named it
  (`git show 51043c4:plan/feature-opencode-worker/plan.md`, D8, D12, M3, M8,
  M9). Rev 3 dropped all of it and reused exits 9 and 10 for other meanings
  (D29), so a developer now needs new exit codes.
- **`glab:manager` Rule 5** (`plugins/glab/skills/manager/SKILL.md:116-145`)
  says "There is no external developer" (`:120`) and "Only the reviewer can be
  external; no other role ever is" (`:125`). It holds the record line
  `- model: glab:reviewer opencode:opencode-go/<id>, …` (`:127`), the handoff
  form `model <backend>:<model>` (`:128`) and the dispatch-table row "an
  external reviewer" (`:139`). **Rule 6** (`:147-156`) says "for read-only
  work", "It changes nothing" (`:154`) and "It takes no stage's role, except
  the reviewer under Rule 5" (`:155`). Stage 2 (`:338-373`) says what goes in
  `result.md`, and that the manager runs the gates after the developer
  returns.
- **`/glab:develop`** (`plugins/glab/commands/develop.md:35-44`) dispatches
  `glab:developer` only; it has no external path. **`/glab:review`** (`:76`)
  and **`/glab:ship`** (`:96`, `:108`) run an external reviewer through the
  skill.
- **`glab:developer`'s report** (`plugins/glab/agents/developer.md:108-124`)
  is the `steps / files / tests / gates / detail` lines, then one verdict:
  `BUILT`, `BLOCKED: <reason>` or `PLAN WRONG: <what>`. The developer writes
  `plan/<slug>/result.md` and never commits or stages (`:102`).
- **`glab:external-agents`** (`plugins/glab/skills/external-agents/SKILL.md`)
  says "There is no external developer" (`:14`). It names the CLI path
  `~/.opencode/bin/opencode` (`:32`), `check` (`:35-38`) and "Use balance"
  (`:39-41`). Its start example names `--backend opencode` (`:52-54`), and its
  guarantees section (`:143-175`) is worded for OpenCode.
- **`README.md:34-61`** holds the requirements (OpenCode only); what is sent,
  and to whom (Kimi, GLM and DeepSeek, Grok refused); the key in the sandbox;
  and the gated sentence "Not yet shown: any reply from a DeepSeek model"
  (`:58`).
- **The copy already holds `plan/SESSION-HANDOFF.md`.** `git check-ignore -v
  plan/SESSION-HANDOFF.md` printed nothing (rc=1), and `git ls-files -o
  --exclude-standard` lists the file. Every external agent today therefore
  sends it to its provider. This is pre-existing: a follow-up (F1), not this
  change.

## 3. Codex CLI 0.163.0: vendor facts

### 3.1 The binary

Proven on this host:

    $ ls -la ~/.local/bin/codex
    lrwxrwxrwx 1 <user> <user> 55 Oct 18 02:24 <home>/.local/bin/codex -> <home>/.codex/packages/standalone/current/bin/codex
    $ file -L ~/.local/bin/codex
    ... ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), static-pie linked, stripped
    $ CODEX_HOME=<throwaway> ~/.local/bin/codex --version
    codex-cli 0.163.0

- The binary is static-pie, so it needs no shared library. A single
  `--ro-bind` of the file can therefore run in the sandbox, as OpenCode's
  native binary does (inferred; the offline run O1 below shows it).
- `--cli` is resolved with `readlink -f` (`:776`), so the stored path lies
  under `~/.codex/packages/standalone/<version>/bin/codex`. If a Codex
  self-update removes the old version directory, a later `send` exits 4 with
  "the backend CLI … is gone" (`:586`). That is inferred from `:586`; the
  installer's directory layout is UNVERIFIED, because the planner may not list
  `~/.codex`.
- `UNVERIFIED: the standalone binary needs no sibling file (a bundled
  codex-resources/bwrap or rg, for example) for the features this change uses
  — an agent may not list ~/.codex/packages; the offline run O1 shows whether a
  turn reaches the network with the file alone.`
- At start it creates helper links under `$CODEX_HOME/tmp/arg0-linux/`. This
  is proven: after `codex exec --help` with a throwaway home, the home held
  `tmp/arg0-linux/codex-arg0hvkru9/{apply_patch,applypatch,codex-linux-sandbox,.lock}`.
  It refuses to create them when `CODEX_HOME` is under the temp dir (stderr:
  "Refusing to create helper binaries under temporary dir"; source
  `codex-rs/arg0/src/lib.rs#L312-L327`). So `CODEX_HOME` in the sandbox must be
  writable and not under `$TMPDIR`, which is `/tmp` inside the sandbox.
- It loads `$CODEX_HOME/.env` into its environment, **dropping every
  variable whose name starts with `CODEX_`**
  (`codex-rs/arg0/src/lib.rs#L268-L294`). Other names, such as `HTTPS_PROXY`
  or `SSL_CERT_FILE`, pass. A `.env` that persisted from one turn to the next
  could therefore redirect the next turn's traffic. Hence `$CODEX_HOME` must
  be new every turn, as `$HOME` is today, with only the session store kept
  (§3.5).

### 3.2 Non-interactive mode: `codex exec`

Proven from `codex exec --help` and `codex exec resume --help` (throwaway
home, no network; the full text was saved under `/data/tmp/claude/fca-help/` for this session and removed after):

- `codex exec [OPTIONS] [PROMPT]`: "If not provided as an argument (or if
  `-` is used), instructions are read from stdin." `exec resume [SESSION_ID]
  [PROMPT]`: "Conversation/session id (UUID) or thread name. UUIDs take
  precedence if it parses", and "If `-` is used, read from stdin".
- Both take `--json` ("Print events to stdout as JSONL"), `-m/--model`,
  `-c key=value`, `--enable/--disable <FEATURE>`, `--ignore-user-config`
  ("Do not load `$CODEX_HOME/config.toml`; auth still uses `CODEX_HOME`"),
  `--ignore-rules`, `--skip-git-repo-check`, `--ephemeral`,
  `--dangerously-bypass-approvals-and-sandbox` ("Intended solely for running
  in environments that are externally sandboxed") and `-o`.
- **`-s/--sandbox` exists on `exec` but not on `exec resume`**, and neither
  do `-C` and `--add-dir`. A resumed turn sets its sandbox with
  `-c sandbox_mode=…` or the bypass flag (inferred: `-c` is generic).
- The docs, at <https://learn.chatgpt.com/docs/non-interactive-mode>
  (redirected from `developers.openai.com/codex/noninteractive`, read
  2026-10-18), say: "By default, `codex exec` runs in a read-only sandbox";
  "`codex exec` reuses saved CLI authentication"; "Use `codex exec -` to force
  stdin to be the full prompt"; "Codex streams progress to `stderr` and prints
  only the final agent message to `stdout`" (without `--json`); and "Codex
  requires commands to run inside a Git repository".
- The source, `codex-rs/exec/src/lib.rs`, shows four things:
  - approvals default to never in headless mode (`#L589-L591`,
    `approval_policy: Some(AskForApproval::Never)`);
  - the git check is skipped when the bypass flag is set (`#L1011-L1018`);
  - **a resume whose id is not found starts a new thread silently**
    (`#L1030-L1064`: `if let Some(thread_id) = resolve_resume_thread_id(…) {
    …thread/resume… } else { start_thread(…) }`). This is the same hazard as
    OpenCode's `--session` (spec D26): only the id read back from the first
    turn may be passed, and the script must check that the resumed turn
    reports that same id;
  - any error event makes it exit 1: `if error_seen {
    std::process::exit(1); }` (`#L1403-L1404`).
- `exec` runs its app server in-process (`InProcessAppServerClient::start`,
  `#L1021`), so `exec` uses no background daemon. That is inferred:
  `daemon_auto_start` is `stable true` in `features list`, and the top-level
  `--no-daemon` is not an `exec` flag.

### 3.3 The JSONL stream

From the source, `codex-rs/exec/src/exec_events.rs` (rust-v0.163.0), and the
docs sample above:

- Events: `thread.started {thread_id}`, `turn.started`, `turn.completed
  {usage}`, `turn.failed {error: {message}}`, `item.started|updated|completed
  {item}` and `error {message}` (`#L10-L26`, `#L30-L75`).
- Items are tagged by `type` (snake_case, flattened into `item`):
  `agent_message {text}`, `reasoning {text}`, `command_execution {command,
  aggregated_output, exit_code, status}`, `file_change {changes: [{path,
  kind: add|delete|update}], status}`, `mcp_tool_call`, `collab_tool_call`,
  `web_search {query}`, `todo_list` and `error {message}` (`#L79-L258`).
- The docs sample is
  `{"type":"thread.started","thread_id":"0199a213-81c0-7800-8aa1-bbab2a035a53"}`,
  a UUID. The session check therefore becomes
  `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`.
- The adapter mapping is inferred from the schema; the offline run O1 shows
  the real stream up to the network failure.
  - `codex_session`: the first `thread.started` `.thread_id`, form-checked.
  - `codex_text`: `.item.text` of every `item.completed` with
    `item.type == "agent_message"`, in order, as `opencode_text` takes every
    text part.
  - `codex_error`: the first `turn.failed` `.error.message`; else an `error`
    `.message`; else an `item.type == "error"` `.item.message`. It is cut to
    300 characters.
  - `codex_render`: reasoning, agent messages, command executions (command,
    status, exit code, output cut as today), file changes (path and kind),
    and any web searches or MCP calls.
- `UNVERIFIED: a resumed turn emits thread.started with the resumed id — no
  model may be run; the offline run O1 (turn 2 = exec resume, no network)
  shows it.`

### 3.4 The login: what the sandbox needs and what it exposes

User answer 1: the user logs in to Codex themselves, and the script uses that
login. The vendor facts:

- **Where it is stored.** `cli_auth_credentials_store` is `file | keyring |
  auto | ephemeral`, and the default is `File`: `#[default] /// Persist
  credentials in CODEX_HOME/auth.json.` (`codex-rs/config/src/types.rs#L133-L146`).
  The docs: "Cached logins are stored in a plaintext file at
  `~/.codex/auth.json` or in your OS-specific credential store"
  (<https://learn.chatgpt.com/docs/auth>). `UNVERIFIED: the user's login is in
  ~/.codex/auth.json, not the keyring — the planner may not look; check (Q2)
  would report it.`
- **What it holds.** `AuthDotJson {auth_mode, OPENAI_API_KEY, tokens,
  last_refresh, agent_identity, personal_access_token, bedrock_*}`
  (`codex-rs/login/src/auth/storage.rs#L47-L73`). `TokenData` holds `id_token`,
  `access_token`, `refresh_token` and `account_id`; the id token carries the
  `email`, plan type, and user and account ids
  (`codex-rs/login/src/token_data.rs#L11-L41`). The docs: "Treat
  `~/.codex/auth.json` like a password: it contains access tokens."
- **When Codex refreshes.** It refreshes when the access token's JWT `exp` is
  within 5 minutes, or else when `last_refresh` is older than 8 days
  (`codex-rs/login/src/auth/manager.rs#L203-L204`, `#L3010-L3023`). It also
  refreshes on a 401, reloading from disk first and then refreshing
  (`#L1850-L1866`). The refresh goes to `https://auth.openai.com/oauth/token`
  (`#L212`).
- **Refresh tokens rotate, and a used one is refused.** The failure reasons
  include `refresh_token_reused`, whose message is "Your access token could not
  be refreshed because your refresh token was already used. Please log out and
  sign in again." (`#L206-L208`, `#L1680-L1689`). After a refresh, Codex writes
  the new tokens back (`persist_tokens`, `#L1599-L1622`). The CI/CD auth docs
  (<https://learn.chatgpt.com/docs/auth/ci-cd-auth>) say: "Use one `auth.json`
  per runner or per serialized workflow stream. Do not share the same file
  across concurrent jobs or multiple machines". They also say to reseed when
  "another machine or concurrent job rotated the token first".
- **Two processes on one file cooperate.** `refresh_token()` takes a lock,
  reloads from disk, and refreshes only if the on-disk auth is unchanged
  (`#L2841-L2871`: "Skipping token refresh because auth changed after guarded
  reload"). The lock is a `Semaphore` inside the process (`#L2057`). Across
  processes, then, it is the reload that avoids a double refresh, not a file
  lock (inferred). A narrow window remains between the reload and the write.
- **The file is written in place.** `save` opens the path with
  `truncate(true).write(true).create(true)`, mode 0600, and does not rename
  (`codex-rs/login/src/auth/storage.rs#L214-L231`). A single-file bind mount
  of the real `auth.json` therefore sees the write. A rename would replace the
  mount point's inode and fail.
- **What this means for a copy.** Inferred from the two points above: when a
  *copy* of `auth.json` in the sandbox refreshes, it rotates the refresh token,
  and the user's host file is left holding a used one. The next refresh on the
  host then fails with `refresh_token_reused`, and the user must log in again.
  Writing the refreshed copy back after the turn narrows this, but only if the
  host did not refresh in the meantime. Whether OpenAI then revokes the whole
  token family is `UNVERIFIED — no doc states it; no live test may be run`.
- **Access-token login exists but does not fit.** `codex login
  --with-access-token` and `CODEX_ACCESS_TOKEN` (`manager.rs#L955`,
  `#L968-L970`) are the enterprise access-token method: "Admins must grant
  permission in ChatGPT Enterprise workspaces"
  (<https://learn.chatgpt.com/docs/auth>). The user has a personal plan (user
  answer 3). `CODEX_API_KEY` is an API key, billed by usage, which the user did
  not ask for (answer 1).
- **What the model can read.** In the script's sandbox, the model's shell runs
  as the same user as Codex. Any file Codex can read, `$CODEX_HOME/auth.json`
  included, the model can read too, and it can send it anywhere over the
  sandbox's internet. That is today's exposure of the OpenCode key, in another
  form. Codex's own sandbox could hide the file from the model's commands, but
  only if it runs nested inside ours (§3.6) and a permissions profile denies
  the file (`permissions.<name>.filesystem` entries set to `"deny"`, config
  reference). `UNVERIFIED: both; measurement S1`.
- **Redaction.** Today one string is redacted (`:163-169`). A Codex login
  given to the sandbox is two or three strings: the access token, the id token,
  and the refresh token if it is given. Each is a JWT or an opaque token of
  `[A-Za-z0-9._-]` (inferred for the JWTs; the refresh token's form is
  UNVERIFIED). Under a bind mount, a refresh mid-turn creates new strings that
  the script does not know. They reach the transcript unredacted until the
  script re-reads the file, which is one more way the mechanisms differ (Q2).

The mechanisms, put to the user as Q2 with their consequences:

- **L1: bind the real `auth.json` read-write** into the turn's
  `$CODEX_HOME`.
  - Refresh works as it does for two local Codex processes, and nothing is
    copied.
  - Exposure: the whole file, refresh token included, which is a long-lived
    credential for the user's ChatGPT account. The model can read it and can
    also **write** it: a model or a bug can truncate it and log the user out
    on the host.
  - New tokens from a mid-turn refresh are not redacted until the file is
    re-read.
- **L2: a per-turn copy, written back after the turn** only if the host file
  is still byte-identical to what was copied.
  - Exposure is the same as L1, but the model can only read the copy, not
    write the host file.
  - If the host and the sandbox both refresh during the turn, one side is
    left with a used refresh token, which can log the user out on the host.
  - The script writes into `~/.codex`.
- **L3: the access token only.** The script copies `tokens.access_token`,
  `tokens.id_token`, `account_id` and `auth_mode` into a new `auth.json` in the
  turn's home, with an empty `refresh_token`.
  - It refuses the turn (exit 4) when the host's access token expires before
    the turn could end: `exp <= now + timeout + 300 s`, where 300 s is Codex's
    own 5-minute window.
  - Exposure: an access token, usable until its `exp`, plus the id token's
    email and ids. The sandbox cannot break the host login.
  - `UNVERIFIED: Codex accepts a ChatGPT auth.json with an empty refresh_token
    and makes no refresh while exp is more than 5 minutes away — offline
    measurement S2 (a fake JWT, no network, codex login status and an offline
    exec turn)`.
  - `UNVERIFIED: the lifetime of a ChatGPT access token — if it is short, L3
    refuses most turns; only the user's own check, reading exp on the host and
    never printing the token, shows it`.
  - When the host token is near expiry, the user refreshes it by using Codex
    on the host. Whether `codex login status` refreshes it is `UNVERIFIED`.
- **L4: Codex's own sandbox denies the model's commands read access to
  `auth.json`**, combined with L1 or L3. It is possible only if S1 shows that
  Codex's bwrap starts nested inside ours. `docs/specs/external-agents.md`
  *Measurements* records that "bwrap inside bwrap cannot start here at all
  (rev 2 P12)", which makes that unlikely.

### 3.5 Session state and `CODEX_HOME`

- `CODEX_HOME` defaults to `~/.codex` (<https://learn.chatgpt.com/docs/auth>).
  Codex keeps its rollouts there, and a SQLite state DB in `sqlite_home`
  ("Directory where Codex stores the SQLite-backed state DB used by agent jobs
  and other resumable runtime state", config reference). Resume resolves an id
  through the state DB or the rollout list
  (`codex-rs/exec/src/lib.rs#L1852-L1882`).
- Proposed: `CODEX_HOME=/home/worker/.codex`, new every turn, so that no
  `config.toml`, `.env`, `AGENTS.md`, skill, rule or hook survives a turn. The
  session store (`sessions/` and the state DB) is bound from `$adir/data`, the
  counterpart of `DATA_IN_HOME`. `UNVERIFIED: which paths under CODEX_HOME
  resume needs — offline run O1, turn 2 with only those paths kept, must report
  the same thread id`.

### 3.6 Codex's own sandbox inside ours

- The help text above lists `--sandbox read-only|workspace-write|danger-full-access`,
  and says the bypass flag is "Intended solely for running in environments
  that are externally sandboxed".
- The source README, `codex-rs/linux-sandbox/README.md` (rust-v0.163.0), says:
  "Bubblewrap is the default filesystem sandbox"; it prefers "the first `bwrap`
  found on `PATH`"; "When bubblewrap is active, the helper explicitly isolates
  the user namespace via `--unshare-user`"; and "If bubblewrap cannot create
  user namespaces, Codex surfaces a startup warning". The legacy Landlock path
  "is rejected" for filesystem-restricted policies.
- The script's sandbox makes `/usr/bin/bwrap` visible (`--ro-bind /usr /usr`),
  and this host could not start bwrap inside bwrap (spec *Measurements*, rev 2
  P12). Inferred: Codex's own sandbox fails when nested here, so every command
  of a `read-only` or `workspace-write` Codex would fail. The adapter must then
  pass `--dangerously-bypass-approvals-and-sandbox` for both roles, which
  leaves our bwrap as the only boundary, much as OpenCode's permission set is
  only a second layer today. `UNVERIFIED — measurement S1: inside a bwrap with
  the script's arguments and CODEX_HOME=<throwaway>, run codex sandbox --
  /bin/true and codex sandbox -c sandbox_mode=read-only -- cat /etc/hostname; no
  model is involved`.

### 3.7 Config, project files and tools inside the copy

- Config layers, from the highest precedence down: managed files, **CLI `-c`
  (session flags)**, **project `.codex/config.toml`**, user profile, user
  `config.toml`, cloud-managed, and system `/etc/codex/config.toml`
  (`codex-rs/config/src/loader/README.md#L24-L35`).
  - A `-c` therefore wins over a project file for the keys it sets. A project
    file in the copy could still add keys the adapter does not set, such as
    `mcp_servers`, `hooks`, `model_providers` or `notify`.
  - "Untrusted projects skip project-scoped `.codex/` layers, including
    project-local config, hooks, and rules" (config reference). Proposed:
    `-c 'projects."/work".trust_level="untrusted"'` plus `--ignore-rules`.
  - `UNVERIFIED: that quoting reaches the key, and the copy's
    .codex/config.toml is then ignored — measurement S3: a copy with a
    .codex/config.toml that turns a feature on, codex features list run from
    /work with the adapter's -c set, offline`.
  - `/etc/codex` does not exist on this host (`ls: cannot access
    '/etc/codex'`). The sandbox binds `/etc` read-only, so on a host that has
    one, it applies.
- Codex loads `AGENTS.md` in `/work` as project instructions
  (`project_doc_max_bytes`: "Maximum bytes read from AGENTS.md when building
  project instructions", config reference). It is inferred to be loaded at any
  trust level, since it is not under `.codex/`. The first message still says
  to read it, as it does for OpenCode.
- Several tools reach past the copy and are on by default (`codex features
  list`, throwaway home, offline): `apps stable true`, `plugins stable true`,
  `remote_plugin stable true`, `browser_use stable true`,
  `computer_use stable true`, `in_app_browser stable true`,
  `image_generation stable true`, `multi_agent stable true`,
  `hooks stable true` and `skill_mcp_dependency_install stable true`
  (`memories` is `stable false`). `web_search` defaults to `cached` (config
  reference).
  - With a ChatGPT login, `apps` are ChatGPT connectors. They are inferred to
    be able to reach the user's connected accounts, which is real data outside
    the copy.
  - Proposed:
    - each of these tools off with `--disable` or `-c`;
    - `web_search="disabled"`, as OpenCode agents "have no web tool";
    - `check_for_update_on_startup=false`, `analytics.enabled=false`,
      `feedback.enabled=false`, `otel.metrics_exporter="none"` and
      `history.persistence="none"`.
  - `UNVERIFIED: the effective state — S3's features list with the same flags
    shows it`.

### 3.8 Network

- The hosts Codex needs are inferred: `auth.openai.com` for the refresh
  (`manager.rs#L212`), and the ChatGPT backend, `chatgpt.com`, for the
  Responses calls (the source file `codex-rs/cli/src/doctor/network.rs`
  references it; it was not read line by line). The sandbox reaches the whole
  internet (spec *Isolation*), so no per-host rule is needed, and the blackhole
  routes keep the host and the LAN closed.

### 3.9 Models and reasoning effort

- The bundled catalog, offline, with an empty home (`codex debug models`, 11
  entries):

      gpt-6-astra   list  priority 2  default low     low,medium,high,xhigh,max,ultra
      gpt-6.1-sol   list  priority 1  default low     low,medium,high,xhigh,max,ultra
      gpt-6-sol     list  priority 3  default medium  low,medium,high,xhigh,max,ultra
      gpt-6-luna    list  priority 4  default medium  low,medium,high,xhigh,max
      gpt-5.6-sol   list  priority 5  …  (upgrade → gpt-6-sol)
      gpt-5.6-terra list  priority 8  …  (upgrade → gpt-6-sol)
      gpt-5.6-luna  list  priority 9  …  (upgrade → gpt-6-luna)
      gpt-daybreak-blue-latest  hide  11
      gpt-daybreak-red-latest   hide  12
      gpt-5.5       list  priority 13 default medium  low,medium,high,xhigh
      codex-auto-review         hide  43

- The CLI's default model is the catalog preset marked default, or else the
  first by priority (`codex-rs/models-manager/src/manager.rs#L845-L852`). The
  catalog is fetched remotely with the login and cached for 300 s
  (`#L34-L35`). So "latest" is not a field: the bundled catalog's first by
  priority is `gpt-6.1-sol`, `gpt-6-astra` is the one described as "Frontier
  intelligence", and the server can change both. See Q5.
- `model_reasoning_effort` is the "Reasoning effort advertised by the selected
  model, such as `low`, `medium`, `high`, `xhigh`, `max`, or `ultra`" (config
  reference). The levels differ per model (table above).
- Claude Code's effort (<https://code.claude.com/docs/en/model-config>):
  - The levels are `low`, `medium`, `high`, `xhigh` and `max`.
  - The session's level comes from `CLAUDE_CODE_EFFORT_LEVEL`, `--effort` or
    `/effort`; then from settings; then from the model default ("Opus 5.5,
    Sonnet 5.5, and Haiku 5.5 default to `medium`").
  - The user sees it in the session header and with `/effort status`. The
    status line JSON has `effort.level`, "the live session value"
    (<https://code.claude.com/docs/en/statusline>).
  - Inferred: the manager, being a model, can read only
    `CLAUDE_CODE_EFFORT_LEVEL` from its own environment, and only when the user
    set it there. It cannot run `/effort status`, and it may not read
    `~/.claude/settings.json`. See Q6.
- Mapping: Claude's five level names exist in Codex with the same spelling,
  and Codex adds `ultra`. `gpt-5.5` has no `max`, and `gpt-6-luna` has no
  `ultra`. `UNVERIFIED: what Codex does with a level the model does not support,
  an error or a fallback — it cannot be shown offline, since the check is
  server-side or happens at the request`.

## 4. The developer role: the design space

The facts the design rests on (each from §1-§3 or the spec):

- The script's invariants (spec *Isolation*; decisions V2, M2, D27): the agent
  never sees the real repository; ignored files never leave the host; it gets
  no history; and the copy is built and verified without running any git
  setting of the user's.
- `git apply` is atomic by default: "For atomicity, git apply by default fails
  the whole patch and does not touch the working tree when some of the hunks
  do not apply" (<https://git-scm.com/docs/git-apply>, `--reject`).
- `glab:developer` writes in the real tree, and the manager runs the gates on
  the host (`manager/SKILL.md` Stage 2 *Verify before moving on*). A Claude
  developer's code already runs on the host through the gates.

The candidate boundaries (Q3):

- **D-A: write in the copy and hand back a patch.**
  - The copy is bound read-write except `.git`
    (`--ro-bind work/.git /work/.git`), so the agent can edit files but cannot
    change refs, the index, hooks or config.
  - After each turn, the script builds the patch on the host with `hostgit` on
    the copy: a temporary index read from the base tree, then `add -A`, then
    `diff --cached --binary` against the base. No filter or driver is defined,
    because the copy's own `.git/config` is the one the script made with
    `git init --template=`, and it is read-only to the agent.
  - A new exit code refuses: a binary change, a symlink, a mode change, a
    gitlink, a path that `safe_path` refuses, a patch over a size cap, and a
    patch that holds any login string.
  - The patch and its `--stat` are reported. Applying is one of two things. A
    new `apply <id>` subcommand checks again that the real tree still equals
    the copy's base, from hashes recorded at start, then runs
    `git apply --check` and `git apply`, leaving the change unstaged. Or the
    manager runs `git apply` itself after reading the patch (rev 2's
    D12/M8/M9).
  - State transitions:

    | state | real tree |
    |---|---|
    | before apply | equals the base |
    | after success | base + patch, unstaged |
    | after failure | unchanged: the apply is atomic, and a changed real tree is refused before it |

  - D-A keeps every invariant. What is new is that the script writes the
    user's tree, in `apply`.
- **D-B: a writable bind of the real working tree.** The model would see every
  ignored file (`.env` and the like) and could send it out. A writable `.git`
  lets it plant hooks that run on the next host `git` command, and the history
  is visible. D-B overturns V2, M2 and "ignored files never leave the host".
  Rejected unless the user overrides those decisions.
- **D-C: a `git worktree` of the real repository.** A linked worktree's
  `.git` file points into the real `.git` (objects, refs, config, hooks). The
  sandbox would need that directory, so the history is visible, and it must be
  writable for commits. The objections to D-B's `.git` apply here too.
  Rejected; a worktree of the copy is D-A by another name.

How it would fit the pipeline (inferred, for the plan once Q1-Q4 are
answered):

- Rule 5 records `- model: glab:developer codex:<model>, …`.
- At Stage 2 the manager starts `--role developer`, with the developer's
  dispatch as the brief: slug, step ids and resolved answers. The copy holds
  the plan, since `plan/<slug>/` is either tracked or untracked-but-not-ignored.
- The script frames the agent with `agents/developer.md`, as it frames the
  reviewer with `reviewer.md`, and validates the report's verdict line:
  `BUILT`, `BLOCKED: …` or `PLAN WRONG: …`. This is a new one-fact entry.
- `result.md` comes back inside the patch. The manager reads the patch,
  applies it and runs the gates itself; Stages 3-5 run unchanged.
- A `BLOCKED` or `PLAN WRONG` re-dispatch is either a `send` to the same agent
  (context kept) or a new agent. That is a plan decision.
- In this repo the developer cannot run the gates inside the sandbox: the test
  needs bwrap and slirp4netns, which do not nest. So its `gates:` line is red
  or unverified here. As now, the manager's own gate run on the host is what
  counts.

## 5. One-fact entries this change touches (`AGENTS.md` *One fact*)

Each entry changes in every file it lists, in the same commit:

- **The manual model rule**, "the developer and reviewer only, and no `model`
  parameter without the user's instruction" (`AGENTS.md:157`): in
  `manager/SKILL.md` Rule 5 and the handoff format, `commands/develop.md`,
  `commands/review.md`, `commands/ship.md` and `external-agents/SKILL.md`. It
  changes in two ways: an external **developer**, and a Codex model chosen by
  **default** when the user names only the backend (answer 2).
- **The external reviewer's record line and `<backend>:<model>`**
  (`AGENTS.md:162`): Rule 5, the skill, the script header's `model:` field and
  E01. A record line for the developer joins it.
- **The exit codes** (`AGENTS.md:167`): the header, the test, the skill, the
  manager, `ship.md` and `README.md`. If D-A is chosen, there are new codes
  for a refused patch and for a changed real tree.
- **The reviewer's verdict lines** do not change. A validator for **the
  developer's verdict lines** is a new entry (`developer.md`, the script, and a
  test case).
- **The allowlist and its end dates** (`AGENTS.md:175`): the script, the test,
  the profiles and the README. Codex has no allowlist ("all models allowed"),
  and the README's sentence "The script runs only Kimi and GLM models …"
  changes.
- **The sandbox's limits and its network helper** (`AGENTS.md:177`): the
  values do not change; the header text gains Codex's mounts.
- **Where agents live** does not change.
- **The CLI's default path** (`AGENTS.md:182-183`): `~/.opencode/bin/opencode`
  gains Codex's `~/.local/bin/codex` (the skill, the README).
- **The "Use balance" warning** (`AGENTS.md:183`) stays for OpenCode. In the
  live-run exception (`AGENTS.md:109-121`), "after confirming that the
  console's 'Use balance' is off" becomes OpenCode-only, since Codex has no
  such switch (answer 3).
- **What the copy holds and may send** (`AGENTS.md:185-187`) does not change
  for read-only work; a developer's patch needs new prose.
- **The missing-`AGENTS.md` fallback**, which the script's first message
  states, is carried into the Codex first message.
- **What each plugin holds**: the counts do not change, since there is no new
  skill, agent or command, unless the split adds a profile only.
- **The sentence on what the live probe did not show** (`README.md:58`,
  gated): its text does not change. A new sentence says Codex has not run
  against a real model.
- The test's `PASS n/n` is not a one-fact value in `AGENTS.md`, which says only
  `PASS n/n`. `docs/specs/external-agents.md` states `PASS 49/49` as of its
  record, and that changes at Stage 8.
- **Version**: `plugins/glab/.claude-plugin/plugin.json` goes from `0.5.0` to
  `0.6.0` (a feature), and to `0.7.0` for a second change if Q1 splits it.
- **Tests** (`AGENTS.md` *Tests*): `tests/external-agent.test.sh` gains a stub
  `codex` passed with `--cli`, and the sentence at `AGENTS.md:96` ("passes its
  stub `opencode`") changes.

## 6. Offline measurements that would settle the UNVERIFIED items

None of these calls a model. All run with no network and a throwaway
`CODEX_HOME`, as `docs/specs/external-agents.md` *Offline run* does for
OpenCode. They belong to the build's Stage 4, or to a planner revision if the
user wants them before the plan. The brief did not allow this planner to run
them.

- **S1**: Codex's own sandbox, nested in the script's bwrap (§3.6, L4).
- **S2**: an `auth.json` with an empty `refresh_token` and a fake JWT whose
  `exp` is hours away. `codex login status` reports logged in, and an offline
  `exec` turn fails at the network, not at auth (§3.4, L3).
- **S3**: the copy's `.codex/config.toml` is ignored under the untrusted
  override, and the effective feature list matches the adapter's flags (§3.7).
- **O1**: the offline run, `start` then `send`, with the real binary, a dummy
  `auth.json` and a slirp4netns stand-in. It shows the argv, the stdin prompt,
  the JSONL parse, the `thread.started` id being recorded, the resumed turn
  reporting the same id with only the session store kept, and no login string
  under the agent's state (§3.1, §3.3, §3.5).

## 7. Candidate split and rejected approaches

- **Split (Q1).** (1) Codex as a read-only backend. This includes moving every
  OpenCode-specific line outside the adapter section into the adapter (§1),
  the login (Q2), and the default model and effort (Q5, Q6). (2) The external
  developer role (Q3, Q4), backend-neutral in the script but allowed for Codex
  only. Part (1) is the open follow-up
  `[feature-opencode-worker/plan-r3.md not-in-plan-1]`, and part (2) is
  `[feature-opencode-worker/plan-r3.md not-in-plan-2]`.
- **Rejected: separate sourced adapter files.** Spec D4 binds the adapters as
  function sets inside the one script.
- **Rejected: `CODEX_API_KEY`.** An API key is billed by usage, and it is not
  the login the user named (answer 1).
- **Rejected: passing the first message as the prompt argument.** It would sit
  on a command line, and the first message (contract, two skills, brief) could
  pass the 128 KiB single-argument limit (`MAX_ARG_STRLEN`, inferred from Linux
  `execve(2)`). Stdin (`codex exec -`) carries it whole.
- **Rejected: a Codex allowlist.** The user allowed every Codex model (answer
  2). The id is checked for form only, since it goes on argv.

## 8. Follow-ups noticed, not in this change

- **F1**: `plan/SESSION-HANDOFF.md` is untracked-but-not-ignored, so every
  external agent's copy holds it, and its provider receives it (§2). Either
  ignore it, or say so in the skill.
- **F2**: `~/.local/bin/codex` resolves into `~/.codex/packages/…`, so an agent
  started before a Codex update fails its next `send` with exit 4 (§3.1).
  Revision 2 closes this for Codex: the host backend keeps the `--cli` path
  as given, unresolved (§9.5).

## 9. Revision 2: Codex on the host, under its own read-only sandbox

Source files were fetched again, read-only, at `rust-v0.163.0` into
`/data/tmp/claude/fca-src2/`, which is removed at the end of the session. No
Codex command was run in revision 2.

### 9.1 What binds now

From `questions.md` *Answers*:

- The script runs the Codex CLI on the host, with its working directory at
  the repository's top. There is no copy, no bwrap and no slirp4netns.
- Codex's own read-only sandbox is the containment.
- Codex uses its own login. The script never copies, reads, exports or
  redacts a token, and never writes `~/.codex`.
- The user accepts that Codex's commands can read files outside the
  repository.
- OpenCode and its guarantees stay unchanged.
- Q5 = B: Codex picks its default model when none is named, and the script
  reads back the model that ran.
- Q6 = A, with mapping (i).
- Q7 = A.
- Q4 = A is for the developer change.

### 9.2 New vendor facts

- **What read-only allows.** "Codex can read files and run commands within
  the read-only sandbox", and "By default, the agent runs with network access
  turned off" (<https://learn.chatgpt.com/docs/agent-approvals-security>, read
  2026-10-18).
  - The same page says that the command-network controls "do not, by
    themselves, disable hosted web search, apps, or MCP".
  - It also says that `<writable_root>/.git` and `<writable_root>/.codex` are
    protected as read-only. That concerns writable roots, so it does not
    apply to read-only mode.
  - <https://learn.chatgpt.com/docs/sandboxing>: "The sandbox applies to
    spawned commands, not just to built-in file operations"; "Web search,
    plugins, and the remote browser have separate controls"; on Linux,
    install bubblewrap, and "Codex surfaces a startup warning when `bwrap` is
    missing or when the helper can't create the needed user namespace". On
    restrictive distributions it says to "prefer loading the `bwrap` AppArmor
    profile".
- **The bwrap Codex uses.** Codex prefers "the first `bwrap` found on `PATH`
  outside the current working directory" (`codex-rs/linux-sandbox/README.md`).
  On this host `/usr/bin/bwrap` creates namespaces: the baseline test's E10
  ran the script's real bwrap sandbox, `PASS 49/49`. It is inferred that
  Codex's own bwrap starts here. Measurement S1 (§9.6) shows it.
- **How the sandbox reports itself.** `summarize_permission_profile` returns
  exactly `read-only` for a read-only profile without network. It appends
  ` (network access enabled)` when network is on, and returns
  `danger-full-access`, `external-sandbox` or `workspace-write [...]` for the
  other modes (`codex-rs/utils/sandbox-summary/src/sandbox_summary.rs#L10-L57`,
  `#L60-L146`; tests at `#L174` and `#L182`).
- **The `--json` stream does not name the model.** The JSONL processor's
  config summary emits only `thread.started {thread_id}`
  (`codex-rs/exec/src/event_processor_with_jsonl_output.rs#L606-L612`,
  `#L403-L407`), and no other event carries the model
  (`codex-rs/exec/src/exec_events.rs#L10-L75`). The only exception is an
  `error` item `model rerouted: <from> -> <to> (<reason>)` (`#L494-L506`).
  In the same stream, warnings are also `error` items (`#L409-L416`), so an
  `error` item is not a failure.
- **The human output names the model.** It prints a header block to stderr
  before the turn (`codex-rs/exec/src/event_processor_with_human_output.rs#L214-L227`):

      OpenAI Codex v<version>
      --------
      workdir: <cwd>
      model: <model>
      provider: <provider id>
      approval: <policy>
      sandbox: <summary>
      reasoning effort: <effort or none>
      reasoning summaries: <summary or none>
      session id: <id>
      --------
      user
      <the prompt>

  The keys and their order are `config_summary_entries`
  (`#L436-L482`); the two effort lines appear for Responses-API providers
  only (`#L461`). Each key is styled bold, so an ANSI SGR sequence wraps it
  when colour is on (`#L223`). stdout holds only the final agent message
  (non-interactive docs, §3.2). The header block and `-` on stdin together
  replace `--json` for this backend (plan D3).
- **Colour.** `--color always|never|auto` exists on `exec` but not on
  `exec resume` (help, §3.2). The parser strips SGR sequences whatever the
  mode.
- **The session id.** The human header prints
  `session_configured_event.session_id` (`#L478-L481`); the JSONL prints
  `.thread_id`. Resume takes a "Conversation/session id (UUID) or thread
  name" (help). `UNVERIFIED: the header's session id, passed to exec resume,
  continues the same conversation and is printed again by the resumed turn —
  offline run O1 (§9.6) shows it with no model`.
- **Silent new sessions.** A resume whose id resolves to nothing starts a new
  thread silently (§3.2, `lib.rs#L1030-L1064`). The script therefore compares
  the resumed turn's header session id with the recorded one.
- **The default model.** It is the first picker-visible model by priority:
  "default is the highest priority available model"
  (`codex-rs/protocol/src/openai_models.rs#L972`). `mark_default_by_picker_visibility`:
  "The first picker-visible model wins" (`#L1034-L1044`). The list is sorted
  by priority (`models-manager/src/manager.rs#L172`) and filtered by auth mode
  and visibility (`#L123`). `codex debug models` prints the raw catalog with
  `slug`, `visibility`, `priority` and `supported_reasoning_levels` (proven
  offline in revision 1, §3.9). `check` can therefore predict the default as
  the lowest `priority` among `visibility == "list"`. That predicts it; it
  does not prove it. The header read-back is what the record line names.
- **User config.** `--ignore-user-config`: "Do not load
  `$CODEX_HOME/config.toml`; auth still uses `CODEX_HOME`" (help, on `exec`
  and on `exec resume`). Whether a `cli_auth_credentials_store = "keyring"`
  set in that file still applies when it is ignored is `UNVERIFIED — the
  planner may not read the user's config; if the login is in the keyring and
  the flag drops the setting, the turn fails with an auth error (exit 7),
  which the user's first check run shows, since check runs codex login
  status (§9.5)`.
- **Config layers.** Session flags (`-c`, `--disable`) sit above project and
  user config, but below `managed_config.toml` and MDM
  (`codex-rs/config/src/loader/README.md#L24-L35`, §3.7). A managed config can
  therefore override the read-only flag. The header check (plan D5) is what
  catches that.
- **Trust.** "Untrusted projects skip project-scoped `.codex/` layers,
  including project-local config, hooks, and rules" (config reference, §3.7).
- **Process lifetime.** `PR_SET_PDEATHSIG` is cleared in a child on `fork`
  (Linux `prctl(2)`; inferred from the man page, not run). So `setpriv
  --pdeathsig KILL -- timeout … codex` would leave `codex` running if
  `timeout` were killed. Plan D7 sets the pdeathsig again on `codex` and puts
  the turn in its own process group. `UNVERIFIED: Codex's sandboxed commands
  die with Codex — they may run in their own session (bwrap --new-session) —
  measurement O2`.

### 9.3 Guarantees per backend, as the change states them

| | OpenCode (unchanged) | Codex (new) |
|---|---|---|
| runs | in the script's bwrap sandbox, on a verified copy | on the host, in the real repository, with its cwd at the top |
| sees | the copy: tracked and untracked-but-not-ignored files, the index, HEAD's tree only | everything the user can read: the repository with its history and ignored files, and files outside it (accepted) |
| writes | nothing: the copy is read-only, in a fresh `$HOME` | nothing in any file, by Codex's read-only sandbox. Codex itself writes its own state under `~/.codex` (sessions, logs, a token refresh), as it does for the user |
| network | its own namespace: internet only, no host or LAN | the commands have none (Codex's default). Codex itself reaches OpenAI |
| login | the Go key in the sandbox, redacted | Codex's own. The script never reads it, so nothing is redacted, and a transcript holds whatever Codex printed |
| tools | `read glob grep shell`, no web | Codex's shell and file tools. Web search, apps, plugins, MCP and hooks are turned off (D4) |
| limits | files, processes, memory, `/tmp`, output caps, timeout | output caps (16 MiB each), timeout. Files, processes and memory are not limited by the script |
| checked | the copy against the real tree; the reviewer's report | the header block: `sandbox: read-only` and `approval: never`, the model and session id form-checked; the reviewer's report |
| state | `$TMPDIR/glab-external-agents/<id>/` with `work/`, `data/`, transcripts | the same directory without `work/` or `data/`; the session lives in Codex's own history under `~/.codex`, and `stop` does not remove it |

### 9.4 Every text that claims the bwrap guarantees for every external agent

Proven by `command grep -n` at `067b719`. Each line is rewritten per backend
in the plan:

- **The script**: header `:2-5`, `:35-69` (the *Isolation* list, "The agent
  never sees the real repository") and `:29-33` (state).
- **`plugins/glab/skills/external-agents/SKILL.md`**:
  - `:3` description ("a read-only external agent — an OpenCode session … in
    a sandbox with its own network");
  - `:8-14`, `:32-41` (the CLI path, check, Use balance), `:45-54` (the brief
    "goes to the model's provider with the copy", the start example);
  - `:56` (announce), `:86` (4), `:91` (9), `:110-114` (the key redacted from
    the transcript), `:121-123` (a branch or range cannot resolve);
  - `:143-175` (*What the script guarantees*).
- **`plugins/glab/skills/manager/SKILL.md`**:
  - `:120` ("as a read-only agent"), `:123` (the backend and model form);
  - `:127` (the record line), `:128` (the handoff), `:139` (the profile row);
  - `:149` ("An external agent — an OpenCode session"), `:154` ("Its copy is
    read-only").
- **`plugins/glab/commands/review.md:76`**: "its copy holds only `HEAD` and the
  working tree".
- **`README.md:34-61`**: the requirements, what is sent and to whom, "The agent
  works on a read-only copy, in a sandbox whose network …", and the key.
- **`AGENTS.md`**:
  - `:96` (the stub `opencode`), `:109-121` (the offline and live-run wording);
  - the *One fact* entries `:177-187` (the sandbox's limits, the CLI path, Use
    balance, what the copy holds).
- **`docs/specs/external-agents.md`**: *How it works now*, *Isolation*, *Known
  limits*, *Offline run* and *Live runs*. These are Stage 8 record text, not
  this change's commit (`AGENTS.md` *Rules*, the `plan/` rule).
- **`docs/specs/workflow.md:78-79`**: Rule 6 "read-only". This is Stage 8.
- **Checked, and nothing to change**:
  - `plugins/glab/commands/develop.md` names no external agent (`:35-44`);
  - `plugins/glab/commands/ship.md:16` and `:28` stay true for Codex: the
    working tree only, and the exit-8 correction;
  - the profiles: `default.md` is backend-neutral; the family profiles are
    OpenCode models only.
- **`tests/external-agent.test.sh:466`**: E28 uses `--backend codex` as *the
  unknown backend*. Once Codex is known, that case must name another
  backend.

### 9.5 Script call sites in the new design

These are added to §1's census:

- `cmd_start` (`:752-803`): the Codex path skips `net_tools` (`:777`),
  `read_secret` (`:786`), `copy_repo` and `chmod` (`:792-796`).
- `cmd_send` (`:805-838`): it skips the `^ses_` check (`:828`; the backend
  checks the form), `net_tools` (`:830`) and `read_secret` (`:831`).
- `run_turn` (`:583-653`): sandboxed or on the host.
- `finish_turn` (`:655-717`): the header's model and the read-only check.
- `cmd_list` (`:840-859`): the model that ran.
- `cmd_check` (`:888-908`).

`cli_ok` (`:327`) and `readlink -f` (`:776`, `:899`): for Codex the path is
made absolute but not resolved, so a Codex update behind the `current` link
is followed (F2). Every other caller in §1 keeps its behaviour for OpenCode,
which E01–E49 pin.

### 9.6 Measurements for Stage 4 (no model is called)

The integrator runs them. None sends a prompt to a model, and none uses the
user's `~/.codex`: each sets `CODEX_HOME` to a throwaway directory under
`$TMPDIR`.

Codex refuses to create its helper links (`codex-linux-sandbox`,
`apply_patch`) when `CODEX_HOME` is under its process's temp dir (§3.1,
`arg0/src/lib.rs#L312-L327`). Each measurement therefore gives the Codex
process a `TMPDIR` that is a sibling of the throwaway `CODEX_HOME`, never its
parent: both under `/data/tmp/claude`, with neither containing the other.
Otherwise the sandbox helper could be missing for a reason unrelated to the
host.

- **S1, Codex's read-only sandbox on this host.** Run
  `codex sandbox -c sandbox_mode='"read-only"' -- <cmd>` in a throwaway git
  repository, where `<cmd>` is `true`, a write into the repository, a read of
  a file outside it, and a TCP connect to a host-side listener.
  - Expected: `true` rc 0; the write refused; the read allowed; the connect
    refused.
  - It shows the sandbox starts, is read-only, can read outside the
    repository, and that its commands have no network.
  - `UNVERIFIED until run: how codex sandbox maps -c sandbox_mode — its
    help names --sandbox-state-json and -P profiles too`.
- **O1, the offline run.**
  - The setup: the script run inside `bwrap --unshare-net --dev-bind / /`
    (no network), with `CODEX_HOME=<throwaway>` holding a dummy `auth.json`
    (a fake JWT; never a real token), on a throwaway repository whose
    `.codex/config.toml` sets `model = "project-model-x"`. Then `start`,
    `send` and `stop`.
  - It shows:
    - the argv accepted by 0.163.0, with every `--disable` known;
    - the header block parsed: `sandbox: read-only`, `approval: never`, a
      model other than `project-model-x` (the project layer is ignored
      under the untrusted override), and a UUID session id;
    - the resumed turn printing the same session id;
    - exit 7 at the network.
- **O2, process lifetime.** The script's turn chain around
  `codex sandbox -- sleep 300`, killed with SIGKILL, must leave no `sleep`.
  The PID is recorded and checked by PID.

What still needs a model, and stays `UNVERIFIED` until a live run the user
orders:

- that a real turn obeys read-only;
- that its commands really have no network;
- that a reroute shows in the human header or output;
- that the default model is the one `check` predicts;
- the effort fallback on a model without the level.

### 9.7 Corrections and added facts (after Stage 1b round 1, `analysis-1b-r1.md`)

**Wrong citations in revision 1 and in §9.4.** The earlier `cat -n` of
three command files numbered them as one stream, so their line numbers were
off. The correct ones, from `command grep -n` at `067b719`:

| cited as | is really |
|---|---|
| `review.md:76` | `plugins/glab/commands/review.md:8` (the external-reviewer sentence and the branch/range sentence) |
| `ship.md:96`, `:108` | `plugins/glab/commands/ship.md:16`, `:28`; §9.4 already gives these |
| `README.md:58`, "the probe paragraph `:58-61`" | `README.md:59-67`; the gated sentence is `:64` |
| AGENTS.md *One fact* `:155-190` | `:130-201` |
| manager Rule 6 "Only when the user asks" (not cited) | `plugins/glab/skills/manager/SKILL.md:151` |

**Text that §9.4 missed, which contradicts U4** ("no model named means
Codex's default"):

- manager `:151`, "naming the model";
- the external-agents skill `:18`, "naming the model";
- the skill `:48`, "the brief goes to the model's provider with the copy";
- `README.md:35`, "naming the model";
- `README.md:9`, "a script, `external-agent.sh`, that runs read-only external
  agents on a model you name (OpenCode Go)". This is a *what each plugin
  holds* file.

Revision 2 of the plan rewrites each of them.

**Also missed:**

- `AGENTS.md:34-35` (*Gates*): "`tests/external-agent.test.sh` runs its stub
  inside the script's real sandbox". This is not true of a Codex stub, which
  runs on the host.
- `tests/external-agent.test.sh` E28 passes `--backend codex` as the unknown
  backend (§9.4 has this).

**Added facts, each proven:**

- **`codex debug models --help`** (throwaway `CODEX_HOME`, under `bwrap
  --unshare-net`, 2026-10-18) shows the options `--bundled` ("Skip refresh and
  dump only the bundled catalog shipped with this binary"), `-c`, `--enable`
  and `--disable`, and no `--ignore-user-config`. Without `--bundled` it
  refreshes the catalog over the network. Revision 1's offline run printed
  the bundled catalog only because the refresh failed.
- **`login status`, `sandbox` and `debug models` take no
  `--ignore-user-config`.** This is from their help, captured in revision 1
  (§3.2 and the `login --help`, `sandbox --help` and `debug --help` outputs):
  only `exec` and `exec resume` take it. So `check` runs under the user's own
  config, and the turns do not.
- **`browser_use_external`** is in 0.163.0's feature list. Revision 1's
  `codex features list` (throwaway home, offline) printed
  `browser_use_external stable true` beside `browser_use stable true`; §3.7
  quoted the second only.
- **`default.md`'s `## Before the contract` section** starts with a blank
  line. The first non-blank line a first message carries is `You are an
  external agent in the glab workflow. A manager has started you to`
  (`plugins/glab/skills/external-agents/profiles/default.md`).
- **`env -i PATH=… LANG=… TERM=… bash -c env`** prints `LANG PATH PWD SHLVL TERM
  _` (`analysis-1b-r1.md` A2.2). Bash adds `PWD`, `SHLVL` and `_` itself, so a
  bash stub's view of the environment has to drop them.
- **The `setsid` group id.** util-linux `setsid` 2.41.3 does not fork when it
  is called from a background subshell of a non-interactive bash, so the
  group id equals the started pid (`analysis-1b-r1.md` A1.c).

### 9.8 After Stage 1b round 2 (`analysis-1b-r2.md`): the one allowed offline run, and source facts

**The offline run the user allowed** (2026-10-18, `questions.md` *Stage 1b,
after round 2*). It ran exactly as the manager gave it: a throwaway
`CODEX_HOME` under `$TMPDIR`, `bwrap --dev-bind / / --unshare-net`, stdout
to a temp file. Both the home and the file were removed afterwards
(`ls "$TMPDIR" | command grep -c -E 'codex-home|codex-models'` printed `0`).
Only the structure was printed, with `jq`; no account data exists in a
bundled catalog.

    $ … codex debug models --bundled > "$TMPDIR/codex-models.$$.json"; echo rc=$?
    WARNING: proceeding, even though we could not create PATH aliases: Refusing to create helper binaries under temporary dir "/data/tmp/claude" (…)
    rc=0
    $ jq -r 'type, (keys|join(",")), (.models|type), (.models|length)' …
    object
    models
    array
    11
    $ jq -r '.models[0].supported_reasoning_levels|type' …; jq -c '.models[0].supported_reasoning_levels[0]' …
    array
    {"effort":"low","description":"Fast responses with lighter reasoning"}
    $ jq -c '.models[0]|{slug,visibility,priority,default_reasoning_level}' …
    {"slug":"gpt-6-astra","visibility":"list","priority":2,"default_reasoning_level":"low"}
    $ jq -r '[.models[].visibility]|unique|join(",")' …; jq -r '[.models[]|.priority|type]|unique|join(",")' …
    hide,list
    number

The shape is therefore: one object, `{"models": [ … ]}`, where each model
has `slug` (a string), `visibility` (`"list"` or `"hide"`), `priority` (a
number), `default_reasoning_level` (a string), and `supported_reasoning_levels`,
an **array of objects** `{"effort": <string>, "description": <string>}`,
among the 41 keys listed in §3.9. The catalog is not sorted by priority: the
first entry has priority 2.

    $ … codex login status; echo rc=$?
    WARNING: proceeding, … (the same line)
    Not logged in
    rc=1

**`login status`'s exit codes, from source.** `run_login_status`
(`codex-rs/cli/src/login.rs#L447-L510`) prints to **stderr** with
`eprintln!`. It exits 0 for every logged-in mode, printing for example
`Logged in using ChatGPT` with no email, and exits 1 for `Not logged in` and
for an error. So `check` reads the status, and its text holds no account
data either way. The offline run above shows the rc 1 path. The rc 0 path
is source-read, not run.

**A `-c` key is not TOML.** `parse_overrides` splits `-c` once, at the
first `=`, and trims; the key is not parsed
(`codex-rs/utils/cli/src/config_override.rs#L49-L81`).
`apply_toml_override` walks the key with `path.split('.')`
(`codex-rs/config/src/overrides.rs#L18-L22`). A key such as
`projects."/home/x/repo".trust_level` therefore becomes the segments
`projects`, `"/home/x/repo"` (with the quote characters in it, and split
again at every `.` in the path) and `trust_level`. It cannot name a project
by its path. So revision 2's untrusted override (plan P2 item 4, D18) could
never have worked, and it is dropped.

**Projects are untrusted unless a config says otherwise.**
`ProjectTrustDecision::is_trusted` is `matches!(self.trust_level,
Some(TrustLevel::Trusted))` (`codex-rs/config/src/loader/mod.rs#L1061-L1065`).
`disabled_reason_for_decision` disables a project's layers for every
decision that is not `Trusted`, including one with no trust entry at all:
"To load project-local config, hooks, and exec policies, add <key> as a
trusted project in <user config file>" (`#L1113-L1131`). The trust entries
come from the non-project layers (`#L1323`), and the user's `config.toml`
is where Codex writes them. Inferred: under `--ignore-user-config` no entry
is left, so the repository's `.codex/` layers are disabled. O1's
`project-model-x` check measures exactly that.

**Bash replaces `&` in a pattern substitution.** Bash 5.3.9 has
`patsub_replacement` on, so an unquoted replacement corrupts a path that
contains `&`, while a quoted one does not:

    $ bash -c 'shopt patsub_replacement; t="/a&b"; l="at @TOP@ x"; echo "${l//@TOP@/$t}"; echo "${l//@TOP@/"$t"}"'
    patsub_replacement  	on
    at /a@TOP@b x
    at /a&b x

The host first message therefore substitutes the top with a quoted
replacement (plan P3).

**What Codex still loads from the user's `CODEX_HOME` under
`--ignore-user-config`** (inferred from the help text "auth still uses
`CODEX_HOME`" and from §3.1): the login; `$CODEX_HOME/.env` (filtered of
`CODEX_` names); and, as for the user's own Codex, any global instructions
and skills kept there. These are the user's own, as a Claude subagent loads
`~/.claude`. Hooks are off through `--disable hooks` whatever file holds
them (D4).

### 9.9 After Stage 4: three candidate fixes for O2's survivors, measured

**The defect** (`integration.md`, *O2 on the host*). Under `codex sandbox`,
the process below `bwrap` — Codex's sandbox helper, `comm=codex` — starts a
session and process group of its own, and the sandboxed `sleep` runs under
it. Both outlive the SIGKILL of D7's chain, and D7's group kill does not
reach them.

**How the measurements ran** (2026-10-18, the user's Stage 4 allowance). The
only Codex command was `~/.local/bin/codex sandbox … -- sleep 300`, run on
the host with no outer wrapper. Each script made a fresh
`X=$(mktemp -d "$TMPDIR/codex-meas.XXXXXX")`, with `CODEX_HOME=$X/home`
holding only a fake `auth.json` (unsigned JWTs, as `integration.md`'s
`host2.sh` builds them), `HOME=$X/uhome`, Codex's `TMPDIR=$X/tmp` and a
throwaway git repository `$X/r`.

Each script recorded every pid it started with that pid's start time, killed
only those pids, and checked them by pid and start time. Each one ended with
`killed at cleanup: …; alive now: none` and `X removed: yes`. The real
`~/.codex` was not touched. The scripts were `/data/tmp/claude/fca-meas/m1.sh`
and `m2.sh`, removed afterwards. They were run as
`REALHOME="$HOME" CX="$HOME/.local/bin/codex" timeout 300 bash m<n>.sh`.

All candidates launch the same chain, from a background subshell in `$X/r`:

    exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 600 \
      setpriv --pdeathsig KILL -- "$CX" sandbox -c 'sandbox_mode="read-only"' \
        -c 'shell_environment_policy.inherit="core"' [marker -c, per case] -- sleep 300

**The tree after 3 s**, the same in every case (pids from C1a):

    pid=3351847 ppid=3351824 pgid=3351847 sid=3351847 comm=timeout
    pid=3351849 ppid=3351847 pgid=3351847 sid=3351847 comm=codex
    pid=3351873 ppid=3351849 pgid=3351847 sid=3351847 comm=bwrap
    pid=3351877 ppid=3351873 pgid=3351877 sid=3351877 comm=codex
    pid=3351878 ppid=3351877 pgid=3351877 sid=3351877 comm=sleep

**Candidate 1: signal Codex first, with a grace period.**

- **C1a**, SIGTERM to the started group, then 5 s of grace:

      kill -TERM -- -3351847: rc=0
      alive 5 s after TERM: 3351877(codex) 3351878(sleep)
      wait P: rc=124
      alive 10 s after TERM: 3351877(codex) 3351878(sleep)

- **C1b**, SIGTERM to the outer `codex` only:

      kill -TERM 3355068: rc=0
      alive 5 s after TERM: 3355095(codex) 3355096(sleep)
      alive 10 s after TERM: 3355095(codex) 3355096(sleep)

- **C1c**, SIGINT to the outer `codex` only. Nothing exited:

      kill -INT 3358395: rc=0
      alive 10 s after INT: 3358393(timeout) 3358395(codex) 3358420(bwrap) 3358424(codex) 3358425(sleep)

**Result: candidate 1 fails.** Codex does not tear down its sandbox helper
on SIGTERM or SIGINT.

**Candidate 2: a marker in the environment, and a sweep by PID.**

- **C2a**, the marker exported only, with `inherit="core"`. It stops at
  `bwrap`:

      pid=3366127 comm=timeout marker=yes
      pid=3366129 comm=codex   marker=yes
      pid=3366153 comm=bwrap   marker=no
      pid=3366157 comm=codex   marker=no
      pid=3366158 comm=sleep   marker=no
      alive after the group TERM+KILL: 3366157(codex) 3366158(sleep)
      sweep killed: 0

- **C2b**, the marker passed only as
  `-c "shell_environment_policy.set.GLAB_TURN_MARK=\"<m>\""`. It reaches
  `bwrap`, the helper and the command:

      pid=3369478 comm=timeout marker=no
      pid=3369480 comm=codex   marker=no
      pid=3369517 comm=bwrap   marker=yes
      pid=3369531 comm=codex   marker=yes
      pid=3369544 comm=sleep   marker=yes
      alive after the group TERM+KILL: 3369531(codex) 3369544(sleep)
      sweep killed: 1
      alive after the sweep: none

- **C2, both channels** (`m1.sh`: export and `set`): all five processes
  carried it.

      marker=yes ×5
      alive 2 s after SIGKILL of P: 3361702(codex) 3361703(sleep)
      found by marker: 2: 3361702(codex) 3361703(sleep)
      alive after the marker sweep: none

- **C2c**, killing only the surviving helper:

      surviving helper: 3372975; sleep alive: yes
      after KILL of the helper only: sleep alive: no

**What the sweep does.** It visits every process of this uid whose
`/proc/<pid>/environ` holds the exact line. For each, it re-reads the start
time, checks the line again, and only then sends the kill.

**Result: candidate 2 works.** The marker must go through
`shell_environment_policy.set`, which is how Codex builds the environment of
its sandbox helper. An exported variable alone does not reach the helper
under `inherit="core"`.

Killing the helper also ends the sandboxed command (C2c). This is inferred
to be because the helper is the init of the sandbox's PID namespace: "By
default it also creates a PID namespace via `--unshare-pid`"
(`codex-rs/linux-sandbox/README.md`). So even a process that unset the
marker inside the sandbox ends with its helper.

Not measured, because the allowance excludes `exec`: that `codex exec`'s
command spawning applies `shell_environment_policy.set` to the helper as
`codex sandbox` does. That is inferred from the shared helper and config,
and is `UNVERIFIED` until a live run.

**Candidate 3: a transient user scope per turn.**

- The setup was available:

      XDG_RUNTIME_DIR=/run/user/<uid> DBUS=set
      /usr/bin/systemd-run  /usr/bin/systemctl
      systemctl --user is-system-running → degraded
      systemd 259 (259.5-0ubuntu3.4); systemd-run --user --scope --quiet -- true → rc=0

- The chain ran under `systemd-run --user --scope --quiet --unit=<u>`:

      unit: ActiveState=active ControlGroup=/user.slice/user-<uid>.slice/user@<uid>.service/app.slice/glab-meas-….scope
      pids in the scope's cgroup: 4
      systemctl --user stop: rc=0
      wait P: rc=143
      alive 1 s after stop: none
      unit after stop: inactive

**Result: candidate 3 works**, because a cgroup holds every process whatever
its session. It needs a running systemd user manager, which means
`XDG_RUNTIME_DIR` and a D-Bus session bus in the script's environment. That
is a new dependency, absent in containers, under `ssh` without lingering, and
on non-systemd hosts.

**Neither candidate survives the script itself being SIGKILLed**, because
nothing then runs the sweep or stops the scope. Both need a second sweep at
`stop`, keyed by the agent's id. The plan's choice is revision 4's D7 and
D31.
