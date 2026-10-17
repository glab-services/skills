# Findings — feature-opencode-worker

Written 2026-10-16 against `main` at `889b804`. The sibling model-switch change
has landed (`1f12a37`, glab `0.3.0`): `glab:manager` now has Rule 5, the user's
manual choice of model for `glab:developer` and `glab:reviewer`. This feature
extends that rule with a third kind of choice — an external worker — rather
than adding a parallel one.

**Status: one Rule 3 question is open (`questions.md`, Q1), so there is no
`plan.md` yet.** Everything else the plan needs is settled below, and a
working prototype of the script, its test, the skill and the profiles is in
`prototype/` with real results.

## The task

The user: *"For developer and review agents: ability to switch to OpenCode
mode. It must not be automated — I will tell the agent which one to use."*
Goal: move bulk work off the Claude Max subscription onto cheaper models
through the OpenCode CLI and an OpenCode Go key, while the manager keeps
planning, gating and deciding. The user also wants to see that the manager can
actually talk to an external model.

### What the user has decided (binding, not re-asked)

- U1 — **Manual only.** An external worker is used for a role only when the
  user says so, naming the model. No file turns it on. The manager never
  switches on its own and never falls back silently either way: external
  unavailable or over its limit → stop and report; re-running on Claude is the
  user's call.
- U2 — **Developer and reviewer only.** Analyzer, integrator, committer, push
  and planning never run external.
- U3 — **The user talks to the manager, not to commands.** "Run the developer
  on opencode-go/<model>" is said in conversation; the manager carries it into
  every dispatch of that role, through whichever command or stage it runs,
  until the user changes or clears it. It must survive a compaction or a new
  stage session, recorded where the manager reads it.
- U4 — **Codex comes later.** Not planned now, but the contract must be
  backend-neutral so Codex is a new adapter, not a rework; backend-neutral
  names (`glab:workers`, `external-worker.sh`).
- U5 — **Each model gets the framing it needs.** A per-model profile, separate
  from the per-backend adapter; a `default` profile; the profile is chosen by
  the model the user named. The returned report is validated against the
  role's contract; malformed → one re-dispatch naming the gaps, then stop.
  No invented quirks: per-model claims are UNVERIFIED until a probe shows them.
  One concept with Rule 5's per-model dispatch table, referenced from one place.
- U6 — **Model scope.** Only the Kimi, Grok, DeepSeek (Pro and Flash) and GLM
  families; profiles for those five plus `default`; the allowlist is those
  families' `opencode-go/<id>`s, a model outside it refused with a named exit
  code; if any of them trains on or retains submitted data, that is the one
  Rule 3 question.

## Scope surface

Every path the change touches or depends on, at `889b804`:

| path | role in this change |
|---|---|
| `plugins/glab/skills/manager/SKILL.md:116-142` | Rule 5 — gains the external choice, its record line, its handoff token and its table row (edit) |
| `plugins/glab/skills/manager/SKILL.md:163` | handoff-line format, `model <m>` (edit: token form for an external choice) |
| `plugins/glab/skills/manager/SKILL.md:198`, `:229` | fan-out reviewers and stage sessions point to Rule 5 (read; no edit needed) |
| `plugins/glab/skills/manager/SKILL.md:329`, `:384` | Stage 2 and Stage 5 dispatch lines naming the `model` parameter (edit) |
| `plugins/glab/skills/manager/SKILL.md:404-413` | *What you never do* (edit: never re-run an external dispatch on another model unasked) |
| `plugins/glab/commands/develop.md:42`, `review.md:8`, `ship.md:16` | the three dispatch points of the two roles (edit: "or through `glab:workers`") |
| `plugins/glab/agents/developer.md`, `reviewer.md` | read by the script as the role contract and its *Report* section (`:104`, `:77`); verdict sets restated by the script's validator; **not edited** |
| `plugins/glab/skills/security/SKILL.md`, `comments/SKILL.md` | bodies carried into the prompt by the script; **not edited** |
| `plugins/glab/skills/workers/SKILL.md` | new skill `glab:workers` |
| `plugins/glab/skills/workers/profiles/*.md` | new: `default`, `kimi`, `glm`, `deepseek-pro`, `deepseek-flash`, `grok` |
| `plugins/glab/scripts/external-worker.sh` | new script |
| `tests/external-worker.test.sh` | new test |
| `plugins/glab/.claude-plugin/plugin.json:3` | `0.3.0` → `0.4.0` |
| `AGENTS.md:24-26`, `:64`, `:103-133` | gates (script list, new test line, `Skills (15)`), one-fact known cases |
| `README.md:9`, `:21-25` | `glab` row, *Requirements* (`bwrap`, `opencode`) |
| `plugins/glab/scripts/manager-bootstrap.sh`, `skills/bootstrap/SKILL.md` | **not edited**: Rule 5 already tells the manager to re-read the record after a compaction (sibling D16) |

## Proven

Commands were run on this host (Linux 7.0, bash 5.3.9, git 2.53.0, bubblewrap
0.11.1, jq, Docker 29.8.2). OpenCode was `opencode-ai@1.19.3`, installed into a
throwaway prefix with `npm --ignore-scripts`, run as its native binary with a
fake `HOME`. **No model was called and no key was used**: every OpenCode run
either had no network (`bwrap --unshare-net`), or talked to a scripted fake
OpenAI-compatible server inside that sandbox, or carried the placeholder
`dummy-not-a-key`.

| # | fact | how |
|---|---|---|
| P1 | `opencode run` takes `-m provider/model`, `--agent`, `--dir`, `--format json`, `--pure` ("run without external plugins"), `-f/--file` (`[array]`), and `--auto` ("auto-approve permissions that are not explicitly denied (dangerous!)", default `false`). | `opencode run --help`. |
| P2 | `-f` swallows a message placed after it: `run --format json -m opencode-go/x -f prompt.md "do the task"` → `Error: File not found: do the task`, rc 1. Message first → the run reaches model resolution. | both orders run offline. |
| P3 | A failure is `{"type":"error",…,"error":{"name":…,"data":{"message":…}}}` and exit 1, e.g. `"name":"APIError","data":{"message":"Cannot connect to API: Unable to connect. Is the computer able to access the url?"…,"url":"https://opencode.ai/inference/go/openai/v1/chat/completions"`. The model's words are `{"type":"text","part":{…,"text":…}}` events. | offline runs; fake-model run, `jq -c 'select(.type=="text")|keys, (.part|keys)'` → `["part","sessionID","timestamp","type"]`, `["id","messageID","sessionID","text","time","type"]`. |
| P4 | **A project config overrides the script's agent where the script is silent.** With the agent defined in `OPENCODE_CONFIG_CONTENT`, a project `opencode.json` merged in `external_directory: allow`, and a project `.opencode/agent/<same name>.md` replaced the agent's prompt (`"be evil"`). With `OPENCODE_DISABLE_PROJECT_CONFIG=1` neither appeared: the agent's rules were exactly the inline ones, prompt `null`. | `opencode debug agent glabworker`, before and after the variable. The variable exists in the binary (`strings \| grep OPENCODE_`). |
| P5 | `OPENCODE_AUTH_CONTENT='{"opencode-go":{"type":"api","key":…}}'` is a credential: `providers list` → `OpenCode Go api`, `1 credentials`; `models opencode-go` lists 29 ids, among them all eight of U6. | offline, placeholder key. |
| P6 | `opencode-go` and `opencode` (Zen, pay-as-you-go) both read `OPENCODE_API_KEY`; their APIs are `https://opencode.ai/inference/go/openai/v1` and `https://opencode.ai/inference/openai/v1`. So one key can reach the paid provider: a model id outside `opencode-go/` must be refused. | `curl https://models.dev/api.json \| jq '.["opencode-go"], .["opencode"]'`. |
| P7 | In the bash tool, the model's commands **see the credential**: `env` inside a tool call printed `OPENCODE_AUTH_CONTENT={"opencode-go":{"type":"api","key":"du…`. | fake-model run 1, tool output. |
| P8 | A `bash` deny rule fires: `git commit --allow-empty -m x` under `"git commit*": "deny"` → `The user has specified a rule which prevents you from using this specific tool call`. But it is a pattern: `git -c user.name=a -c user.email=a@a commit …` inside a compound command was **not** denied (the call completed) and failed only on the read-only `.git`. | fake-model runs 1 and 4. |
| P9 | `external_directory: deny` rejects a bash command that names a path outside the project (`ls /home`, `cat /proc/1/cmdline`, `P=$(printf '/ho%s' me)`) and a `read` of `/home/<user>/.bashrc`. It is a parse of the command, not a boundary. `webfetch: deny` removes the tool (`Model tried to call unavailable tool 'invalid'. Available tools: bash, edit, glob, grep, read, todowrite, write.`). | fake-model runs 1 and 4. |
| P10 | **The bubblewrap sandbox is the boundary.** With the copy's `.git` bound read-only: `.git/hooks/pre-commit: Read-only file system`, `could not lock config file .git/config: Read-only file system`, `Unable to create '/work/.git/index.lock': Read-only file system`, `cannot lock ref 'refs/heads/evil'`. Inside, `/home` and `/data` do not exist. A read-only work tree still serves `git status --short -uall`, `git diff`, `git diff --staged` (rc 0). | fake-model run 4; `bwrap … --ro-bind work /work … git status/diff`. |
| P11 | The credential must not be a file in the sandbox home: with `auth.json` there, start-up blocked about 70 s on `background dependency install failed … @opencode-ai/plugin … ECONNREFUSED` and then hung (2 of 2 runs, killed by `timeout`). With `OPENCODE_AUTH_CONTENT` the same run finished in 2 s, with 0 `dependency install` lines in its log (2 of 2). | `probe.sh run2 … file` vs `… env`; log grep with a known positive. |
| P12 | bubblewrap cannot nest here: `bwrap` inside `bwrap` → `No permissions to create a new namespace`. The prototype's preflight turns that into exit 4 `bwrap cannot start a sandbox on this host`. | three nested variants, all rc 1. |
| P13 | The prototype, with the **real** opencode binary, its exact argv, environment, config and sandbox (network removed in a throwaway copy of the script, a one-line diff), reached the API call for `opencode-go/kimi-k3` and returned exit 7 `BACKEND ERROR: APIError: Cannot connect to API…` after 66 s; the placeholder key appeared 0 times in its out dir. | `external-worker.nonet.sh` run, since deleted. |
| P14 | The OpenCode Go page (https://opencode.ai/docs/go/, fetched raw 2026-10-16): Go `$10/month`, Go Plus `$40/month`; "Each model has the following usage limits: 5-hour — 20% of the monthly limit; weekly — 50%; and monthly — 100%"; "If you also have credits in your Console balance, you can enable the Use balance option in the console. When enabled, Go will fall back to your pay-as-you-go balance after you've reached your usage limits instead of blocking requests"; the training/retention and limit rows in *Data exposure and money*; "DeepSeek: ZDR agreement is renewed monthly. The current agreement is valid through October 31, 2026"; "Grok 4.7: ZDR disables important API features that depend on stored data, including the stateful Responses API…". | `curl -sSL`, tags stripped, `grep`. |
| P15 | Loading a skill prints its directory: this session's tool result began `Base directory for this skill: /home/pvhv/.claude/remote/plugins/…/skills/plan-first`, and that plugin directory holds `agents commands scripts skills`. So `<base>/../../scripts/external-worker.sh` names the script without relying on `${CLAUDE_PLUGIN_ROOT}` substitution in skill text. | the Skill tool output; `ls` of the installed plugin. |
| P16 | A `profiles/` directory inside a skill is not counted as a skill: with `skills/workers/SKILL.md` and `skills/workers/profiles/*.md` added, the three validations print `✔ Validation passed` and `plugin details glab` prints `Skills (15)` … `workers`, `Agents (5)`, `Hooks (1)  SessionStart`; no prefixed `name:` (`rc=1`). | the *Gates* block's plugin half on the prototype tree, `CLAUDE_CONFIG_DIR` throwaway, CLI 2.1.299. |
| P17 | The prototype test: `PASS 34/34`, `shellcheck` rc 0 on script and test, no orphan process after it (`ps … \| grep '[s]leep 30$\|[o]pt/worker'` → rc 1), no leftover directory under `TMPDIR`. Mutation run: **41 mutants, 41 killed**, each by the case it targets (*Prototype* below). | `bash tests/external-worker.test.sh …`; `python3 -I mutants.py`. |
| P18 | `docker` 29.8.2 answers and the user is in group `docker`; `bwrap` 0.11.1 works for this user although `kernel.apparmor_restrict_unprivileged_userns = 1`. | `docker version`, `bwrap … /bin/true` rc 0, `/proc/sys/kernel/…`. |

## Inferred

- I1. `opencode auth login` stores the Go key in `~/.local/share/opencode/auth.json`
  under the key `opencode-go` in the shape P5 accepted. The path is proven
  (`providers list` prints `Credentials ~/.local/share/opencode/auth.json`,
  `debug paths` → data dir); the entry name is inferred from the provider id.
  `UNVERIFIED: the real entry name — needs the user's own login; the live probe's first step checks it with jq keys`.
- I2. `--pure` does not stop the `opencode-go` provider from working: P13
  reached the API call with it, but a real answer was not seen.
  `UNVERIFIED — live probe`. Grok is served through `@ai-sdk/openai` and the
  `/responses` endpoint (Go page, endpoints table), the other seven through
  `@ai-sdk/openai-compatible`; whether either SDK is fetched at run time is
  `UNVERIFIED — live probe`.
- I3. A Go limit arrives as a `type:"error"` event (P3's shape). Its text is
  unknown. The design does not depend on it: every error is exit 7 and the
  message is shown. `UNVERIFIED: the limit text — captured by the live probe only if a limit is hit; it is never provoked on purpose`.
- I4. A manager whose own Bash tool runs inside a bubblewrap sandbox cannot
  start the worker (P12). Whether Claude Code's sandbox mode is that case is
  `UNVERIFIED — not enabled in this session`; the script then exits 4 with the
  reason, which is the right outcome.
- I5. Each model's reading style (U5). No source was found, so no profile
  claims one; each family profile is empty with a note saying so.

## The prior plan (444032d, `origin/plan/external-workers`) — what holds

It was rejected by the user for its automatic switch in `docs/constants.md`
(U1) and analysed as not buildable. Each analyzer claim was re-checked:

| # | analyzer claim | here |
|---|---|---|
| 1 | `-f` swallows the instruction | **proven** P2; the prototype puts the message first, and W11 pins it |
| 2 | inline rules are overridden by a project config; `git commit*` misses variants | **proven** P4, P8; answered by `OPENCODE_DISABLE_PROJECT_CONFIG=1` and by not relying on patterns at all (the sandbox) |
| 3 | `--auto` approves `external_directory`; without it, asks are rejected; `webfetch` allowed by default; Claude files read | `--auto` is not used; every rule is allow or deny; `webfetch`/`websearch` deny (P9); `OPENCODE_DISABLE_CLAUDE_CODE=1`; and the sandbox has no `~/.claude` to read |
| 4 | the worker inherits the caller's environment | answered: the environment is rebuilt from an allowlist; W09 proves no caller variable arrives |
| 5 | a HEAD/index check misses push, refs, stash, config, hooks | answered structurally: the real repo is not mounted, and the copy's `.git` is read-only (P10, W08, W34) |
| 6 | error/text event shapes | **proven** P3 |
| 7 | Use balance invisible, per-model limits, training models | **proven** P14; the allowlist (U6) and Q1 |
| 8 | lock, temp dir, transcript path, markers, reviewer target only, `/glab:ship`, `/glab:develop` anchor, `${CLAUDE_PLUGIN_ROOT}`, weak tests | no lock needed (one copy per run); `TMPDIR` required; out dir outside the removed copy; markers owned by the script; brief = target only; `ship.md:16` in scope; `develop.md:42` is the anchor; P15 instead of substitution; a mutant for every case |

## Isolation — the options

| | (a) host-local hardened OpenCode | (b) disposable copy, diff back | (c) sandbox around (b) |
|---|---|---|---|
| what the model can do | anything the user can, through `bash`: P8 and P9 show the rules are patterns and a parse; denying all of `bash` leaves a developer unable to run anything | write only to the copy; but `bash` still reads `~/.ssh`, `~/.claude`, other repos, and can run `git` against them | write only to the copy; no `/home`, no real repo, read-only `.git` in the copy; network open (the API needs it) |
| real repo integrity | needs a full ref/stash/config/hook fingerprint, racy against concurrent work (claim 5) | real `.git` not handed over, but reachable by path | not mounted at all (P10, W34) |
| cost to build | config only, but it cannot be proven safe | copy + patch | copy + patch + one `bwrap` call (0.11.1 here); `docker` is also here (P18) but needs an image with OpenCode in it and a root-equivalent daemon, and is not on every host |
| what it proves | nothing an adversarial repo cannot defeat | the delivery path | the boundary, by test (W08, W09, W12) and by mutants that remove each bind |

**Chosen: (c) on top of (b) — a bubblewrap sandbox around a disposable copy,
with the OpenCode permission set kept as a second layer.** `bwrap` is
unprivileged, needs no daemon or image, starts in milliseconds, and its
failure is a clear exit 4. Docker was rejected: it needs an image to build and
trust, the `docker` group is root-equivalent, and it adds nothing the bind
list does not already give.

What it does not contain, said plainly: the network is shared, so the worker
can reach any host the machine can reach without a credential, and it holds
the Go key (P7). The key is redacted from every output, and a patch that
carries it is refused (W24, W25). A leaked key could be used against the Go
subscription and, where the account has any, the Zen balance (P6).

## The contract (backend-neutral)

### How the user's choice is expressed and recorded

Rule 5 already gives the shape; the external choice slots into it:

- The user says it in conversation: "run the developer on OpenCode,
  opencode-go/kimi-k3", "review this with opencode glm-5.3". The manager
  recognizes a backend name and a model id; anything ambiguous is asked back,
  as Rule 5 already does for an unknown Claude alias.
- Recorded as Rule 5's line, unchanged in form: `- model: glab:developer
  opencode opencode-go/kimi-k3, for this task — the user's instruction, not a
  manager choice: "<the user's words>"`. Rule 5's rules on duration, on
  compaction, and on ignoring a line that does not quote the user, all apply.
- Handoff token: `model opencode:opencode-go/kimi-k3` — one token, so Rule 5's
  line format does not change; later `model codex:<model>`.
- No setting anywhere turns it on (U1). The script has no default backend and
  no default model.

### The script

`plugins/glab/scripts/external-worker.sh --role developer|reviewer --backend
<name> --model <id> --brief <file> [--repo <dir>] [--timeout <s>]` — full text
in `prototype/external-worker.sh`.

| exit | code | meaning | the manager |
|---|---|---|---|
| 0 | OK | report validated; stdout = report block, then `out: <dir>` | treat as the internal agent's report; developer: inspect and apply the patch |
| 2 | USAGE | the call was wrong (role, timeout, `TMPDIR`, repo) | fix the call; not the user's |
| 3 | UNKNOWN BACKEND | no adapter for that name | stop, tell the user |
| 4 | UNAVAILABLE | CLI, `bwrap`, sandbox or credential missing | stop, tell the user |
| 5 | MODEL REFUSED | outside the allowlist, or past its end date | stop, tell the user; the line lists what is allowed |
| 6 | TIMEOUT | past `--timeout` (default 3600 s) | stop, report |
| 7 | BACKEND ERROR | an error event or a non-zero exit — a Go limit lands here | stop, report the line verbatim |
| 8 | MALFORMED REPORT | markers, field, verdict or `result.md` missing; gaps on stderr | one re-dispatch, same model, brief naming the gaps; second 8 → stop |
| 9 | SECRET IN OUTPUT | the worker's changes contain the credential; patch deleted | stop, tell the user |

On 3–7 and 9 the manager never re-runs the role on Claude or on another
external model by itself (U1).

What it does, in order: validate arguments and `TMPDIR` → pick the adapter →
model against the allowlist and its end date → locate the CLI, `bwrap`, the
credential → build the copy (every branch, tag and remote-tracking ref, no
remote configured; the real tree's staged and unstaged diffs applied;
untracked-not-ignored files copied; nested repos skipped) → baseline tree in
an index file outside the copy → preflight the sandbox → assemble the prompt →
run the CLI in the sandbox under `timeout`, environment rebuilt from an
allowlist with no value on any command line → redact the key from transcript
and stderr → classify (timeout, error) → extract the last block between the
markers → validate it against the role → for the developer, diff the copy
against the baseline into `changes.patch` and refuse it if it holds the key →
print.

### The adapter (one per backend)

All backend-specific code is one function set: `<b>_models` (allowlist:
`<model id> <profile> <end date or ->`), `<b>_locate`, `<b>_credential`,
`<b>_secret`, `<b>_env`, `<b>_argv`, `<b>_text`, `<b>_error`, plus one line in
the backend `case`. For `opencode`: the credential is the `opencode-go` entry
of `auth.json` alone, passed as `OPENCODE_AUTH_CONTENT` (P5, P11); the config
is an inline agent `glab-worker` with `"*": deny` and explicit allow/deny for
every tool, `edit: deny` for the reviewer, `external_directory` deny except
`/tmp/*`, `webfetch`/`websearch`/`task`/`skill`/`question`/`doom_loop` deny,
`share: disabled`, `autoupdate: false`; plus `OPENCODE_DISABLE_PROJECT_CONFIG`,
`OPENCODE_DISABLE_CLAUDE_CODE`, `OPENCODE_DISABLE_AUTOUPDATE`,
`OPENCODE_DISABLE_LSP_DOWNLOAD`; argv `run "<message>" --pure --format json -m
<model> --agent glab-worker --dir /work -f /home/worker/prompt.md`.

### The profile (one per model family) — and Rule 5's table

- `profiles/default.md` frames every dispatch; `profiles/<family>.md` adds to
  it. Each has `## Before the contract` and `## After the contract`, sent in
  that order around the contract; `## Notes` is never sent (W05).
- The allowlist line names the profile, so the choice follows the model the
  user named, never an inference (W06, W07).
- The report template is not copied into any profile: the script appends the
  role's own *Report* section from its agent file (sibling D21's one-source
  rule), and the markers live in the script beside the parser.
- The five family profiles carry no claim yet (I5). The live probe captures
  one report per model the user tries; tuning a profile from it is a later
  one-file change.
- **One concept, one place:** Rule 5's table *"what changes in the dispatch"*
  stays the one list of how each choice is framed. Its new row for an
  external choice reads, in substance, "the profile its allowlist line names,
  applied by `external-worker.sh` (`glab:workers`)". A cheaper Claude model
  stays framed by the manager's own message, as today; a Codex model later
  gets its own allowlist line and profile.

### Read-back validation

Mechanical, in the script (W13–W20): developer — `steps:`, `files:`, `tests:`,
`gates:`, `detail:` present, `detail:` names a file the worker wrote, last
line `BUILT` | `BLOCKED: …` | `PLAN WRONG: …`; reviewer — exactly one verdict
line of `SHIP` | `SHIP WITH SCOPE CUT: …` | `BLOCK: <n> issues` | `BLOCK: target
unresolved` | `DO NOT PUBLISH: …`, and `BLOCK: <n> issues` with exactly `n`
`rule:` lines. Lines after the reviewer's verdict are kept (W13). The verdict
sets restate the agent files; W33 fails when either file changes a verdict
the script does not know — and the plan adds this to *One fact, one value*.

Rule 5's own check (fields present, verdict in form) still runs in the
manager on exit 0. Its one retry is a **resume** for an internal agent; an
external worker cannot be resumed, so its one retry is a fresh run on a fresh
copy, which redoes the work. `glab:workers` says so.

### Developer write path, reviewer read-only

- Developer: edits the copy; the script returns `changes.patch` (binary-safe,
  no renames), and the manager reads `git apply --stat`, checks the plan's file
  boundary, then `git apply --check` and `git apply` in the repo root. Applying
  the delivered patch unchanged is taking delivery, not implementing (Rule 1);
  editing it is implementing. `result.md` arrives inside the patch, so the
  developer contract is unchanged. W02 applies a real patch with an edit, a new
  file, a delete and `result.md`.
- Reviewer: the copy is bound read-only (W12); its scratch `/tmp` is writable
  for the throwaway repos its Step 4 asks for; it gets the target only, never
  the slug — the brief is written by the manager under Stage 5's rule.
- Parallel external developers: each run has its own copy, so no lock is
  needed; the develop split rule (disjoint files, no ordering dependency)
  still decides whether the patches are independent.

## Data exposure and money

From the Go page (P14), for the eight `opencode-go` ids of U6. "Monthly limit"
is the page's included usage per model per month, in dollars of list price,
on Go / Go Plus; the 5-hour and weekly limits are 20 % and 50 % of it.
Request estimates are the page's own, per 5 h on Go.

| model id | training | retention | monthly limit Go / Plus | ~requests / 5 h on Go |
|---|---|---|---|---|
| `opencode-go/kimi-k3` | Not used | 0 days | $15 / $60 | 110 |
| `opencode-go/kimi-k2.7-code` | Not used | 0 days | $60 / $180 | 1,350 |
| `opencode-go/glm-5.3` | Not used | 0 days | $15 / $120 | 220 |
| `opencode-go/glm-5.3-flash` | Not used | 0 days | $60 / $180 | 6,320 |
| `opencode-go/glm-5.2` | Not used | 0 days | $60 / $180 | 880 |
| `opencode-go/deepseek-v4-pro` | Not used | 0 days\* | $15 / $60 | 1,050 |
| `opencode-go/deepseek-v4.1-flash` | Not used | 0 days\* | $80 / $160 | 34,670 |
| `opencode-go/grok-4.7` | Not used | **30 days** | $15 / $60 | 169 |

\* "ZDR agreement is renewed monthly. The current agreement is valid through
October 31, 2026" — fifteen days after this was written.

None of the eight trains on submitted data. **Two retain or may retain it:**
Grok 4.7 keeps prompts 30 days (ZDR would break its Responses API), and
DeepSeek's zero retention is promised only to 2026-10-31. Whatever the copy
holds may reach the provider — tracked files and untracked-not-ignored ones.
That is Q1.

Money: the script spends nothing itself, and Zen ids are refused (P6, W27).
Two money paths stay outside it: **Use balance** (a console switch the script
cannot see; the skill tells the user once per session that it must be off),
and a leaked key (above). An agentic run is many requests: on Go, Kimi K3's
110 per 5 h may not last one developer slice. A limit is exit 7 and a stop.

## Call-site audit

- **Rule 5** (`manager/SKILL.md:116-142`) is read by: `develop.md:42`,
  `review.md:8`, `ship.md:16`, manager `:163` (handoff format), `:198`
  (fan-out reviewers), `:229` (stage sessions), `:329` (Stage 2), `:384`
  (Stage 5). Each of `develop.md:42`, `review.md:8`, `ship.md:16`, `:329` and
  `:384` says "pass it as the Agent tool's `model` parameter"; each must learn
  that an external choice goes through `glab:workers` instead. `:198` and
  `:229` say only "the model Rule 5 gives", so they hold unchanged.
- **The agent files** gain a new reader, the script: it reads the body after
  the frontmatter and the `## Report` section (`developer.md:104`,
  `reviewer.md:77`). A heading rename there breaks W05 — that is the guard.
- **`security/SKILL.md`, `comments/SKILL.md`** gain the same reader for their
  bodies; W05 checks their first lines arrive and the frontmatter does not.
- No existing function or script changes behaviour; `manager-bootstrap.sh`
  and `memory-sync.sh` are untouched.

## State transitions and lifecycle

- Real repo: before = whatever the user has; during the run = untouched (not
  mounted); after exit 0 = untouched until the manager runs `git apply`; on
  any failure = untouched. W34 fingerprints status, refs, stash, config, hooks
  and both diffs across all 34 cases.
- Out dir `$TMPDIR/external-worker.XXXXXX`: created by the script after the
  model check; removed by the script on exits 2–5 (W26, W27, W30–W32 find
  nothing left); kept on 0 and 6–9 for the manager, who removes it. Inside it,
  `.run/` (the copy, sandbox home, scratch) is always removed by the script's
  `EXIT` trap, after `chmod -R u+rwX` in case the worker locked files (W03).
- Processes: `timeout --kill-after=10` owns `bwrap`; `--die-with-parent` takes
  the sandbox down with it (W23 ends within the limit plus the grace, and no
  stub process was left).

## Prototype

`prototype/` holds what was run: `external-worker.sh`, `external-worker.test.sh`
(placed at `plugins/glab/scripts/` and `tests/` in a copy of the tree),
`workers-SKILL.md`, `profiles/`, `mutants.py`, and `probe/` (the fake model
server and the two scenarios behind P7–P11). `mutants.py` expects that copy at
`/data/tmp/claude/ocw-proto/tree`, which was removed after the run; recreate it
to re-run. The test's stub stands in for `opencode` first on `PATH` and runs
**inside the real sandbox**, so the isolation cases test the sandbox, not a
fake of it. Its scenario comes from a `STUB:` line in the brief, because no
variable of the test reaches the sandbox.

    PASS 34/34          bash tests/external-worker.test.sh plugins/glab/scripts/external-worker.sh
    sc rc=0             shellcheck on both
    mutants: 41, not killed or skipped: 0

Every case W01–W33 was failed by at least one mutant aimed at its reason (e.g.
M01 drops the read-only `.git` bind → only W08 fails; M07 puts the message
after `-f` → only W11; M29 removes the end-date check → only W28). W34 is a
guard across all cases; M41 binds the real repo instead of the copy and fails
it, with six others.

## The live probe (user-run, later in the plan)

It needs the user's key, so no agent runs it and the test suite never calls
the network. It will: check the stored credential's entry name (I1); run the
reviewer once on a throwaway repo against a model the user picks, capturing
one real report (U5, I2) and the transcript; run a developer whose brief asks
it to `git commit` and to read `~/.ssh` — expected: no commit, no read, a
report saying so; and have the user confirm the console's Use balance is off.
Until it runs: `UNVERIFIED: a real Go model answers through the sandbox, fills
the report, and is denied as the fake model was`.

## Later: Codex

What a `codex` adapter must provide, every Codex fact `UNVERIFIED — not
researched beyond the interface`: an allowlist of its model ids with profiles;
how to locate its CLI; where its credential lives and how to pass only that
into the sandbox (and not as a file in the sandbox home, should it misbehave
as P11 did); a non-interactive invocation with JSON output and the prompt
passed as a file; how its own sandbox or approval mode behaves inside
bubblewrap (P12: a nested user namespace fails here); how its output separates
the model's text from errors. The script's copy, sandbox, markers, validation,
exit codes, redaction and patch are reused unchanged; the test gains a `codex`
stub beside the `opencode` one.

## Decisions (to carry into `plan.md`)

- D1 — **Isolation: bubblewrap around a disposable copy**, OpenCode's
  permission set as the second layer. Why above; (a) and Docker rejected.
- D2 — **The external choice is a form of Rule 5's choice**, recorded in the
  same `- model:` line and shown as `model <backend>:<model>`. No second rule.
- D3 — **One skill, `glab:workers`, one script, `external-worker.sh`**, both
  backend-neutral (U4). Commands and Rule 5 point to the skill in one sentence
  each.
- D4 — **Adapters are function sets in the one script**, not separate files:
  one file to lint and gate, and the backend `case` is the one place to add
  one. Rejected: `scripts/backends/*.sh` sourced at run time — more gate
  entries and a `source` path shellcheck cannot follow.
- D5 — **Profiles live in `skills/workers/profiles/`**, named by family, chosen
  by the allowlist line. P16 shows they are not counted as skills.
- D6 — **The allowlist and its end dates live in the script only**; the skill
  says the script prints it on exit 5. A new model is one line, a profile
  optional (U6).
- D7 — **Every error is exit 7**, the message shown. No limit-text matching:
  its text is unknown (I3), and matching on a guess would turn a limit into
  something else.
- D8 — **The credential travels in the environment, never on a command line
  and never as a file in the sandbox** (P11). It is redacted from transcript,
  stderr and report; a patch holding it is refused (exit 9).
- D9 — **`TMPDIR` is required.** The script refuses to default to `/tmp`; the
  skill tells the manager to export the host file's directory.
- D10 — **No lock.** One copy per run makes concurrent runs independent; the
  develop split rule decides whether their patches are.
- D11 — **Timeout 3600 s by default**, `--timeout` to change it.
- D12 — **The manager applies the patch; the worker never touches the real
  tree.** Applying unchanged is delivery, editing is implementing.
- D13 — **A malformed external report gets one fresh re-dispatch**, not a
  resume — an external run cannot be resumed — then a stop (U5, Rule 5).
- D14 — **New one-fact cases in `AGENTS.md`:** the exit codes (script, test,
  `glab:workers`); the verdict sets (agent files, script, W33); the external
  choice's record and token (Rule 5, `glab:workers`, the three commands); the
  allowlist (script and test only — the plan keeps model names out of the
  skill and `README.md`).
- D15 — **Version `0.3.0` → `0.4.0`**, the sibling having taken `0.3.0`.
- D16 — **The live probe is the plan's last step, run by the user**, and its
  output is what tunes a profile.

### Rejected

- An automatic or file-based switch (the prior plan): U1.
- `--auto`: it approves every rule not denied, `external_directory` included.
- `git worktree` as the copy: its `.git` file points into the real repo's
  `.git`, so hooks and config stay writable.
- A before/after fingerprint of the real repo as the guard: racy against
  concurrent work, and unnecessary when the repo is not mounted (kept only as
  the test's W34).
- Routing the external worker through a Claude subagent that shells out:
  spends the Claude quota the feature exists to save, and doubles the report
  path.

## UNVERIFIED, in one place

- I1 the stored credential's entry name; I2 a real Go answer through `--pure`
  and the sandbox, and whether the SDK is fetched at run time; I3 the limit
  text; I4 Claude Code's own sandbox mode and nested `bwrap`; I5 every
  per-model reading style.
- That a model, rather than the stub, honours the markers and the template
  often enough to be useful — the probe shows one report per model.
