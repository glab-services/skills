# Findings — feature-plugin-marketplace

Planning record for turning this repo into a Claude Code plugin marketplace
with two plugins. Written 2026-10-05 against `main` at `2aeb46d`, clean tree.
Nothing outside `plan/` was changed. Nothing under `~/.claude` was read for
values or written.

Every claim below is labelled. **Proven** = a command ran in this session and
its output is pasted. **Doc** = an exact sentence from the official docs,
fetched today as Markdown (`curl https://code.claude.com/docs/en/<page>.md`);
a doc sentence proves what the docs say, not what the binary does.
**Inferred** = reasoned, with what would prove it. `UNVERIFIED:` = could not
be checked here.

## 0. Status

Seven questions are open in `questions.md` (Q1–Q7). Per the task rule,
`plan.md` is not written until they are answered. Sections 6, 9 and 10 hold
the material the plan will be built from, so it is quick to write afterwards.

## 1. Can `claude` be run on this machine

**Proven.** No `claude` on `PATH`, but the CLI binary that runs this session
exists and works:

    $ command -v claude; type claude
    /bin/bash: line 1: type: claude: not found
    $ readlink /proc/<parent pid>/exe
    /home/pvhv/.claude/remote/ccd-cli/2.1.286
    $ CLAUDE_CONFIG_DIR=/data/tmp/claude/<throwaway> /home/pvhv/.claude/remote/ccd-cli/2.1.286 --version
    2.1.286 (Claude Code)

`plugin validate`, `plugin list`, `plugin details`, `plugin tag` are present
(`plugin --help` output read).

**Proven — the CLI writes to its config directory even for `plugin validate`.**
After three `plugin validate` runs with `CLAUDE_CONFIG_DIR` pointed at an empty
throwaway directory:

    $ ls -la $CLAUDE_CONFIG_DIR
    -rw-------  1 pvhv pvhv  612 Oct  5 17:03 .claude.json
    drwxrwxr-x  2 pvhv pvhv 4096 Oct  5 17:03 backups

Consequence for the plan: **every `claude` gate command must run with
`CLAUDE_CONFIG_DIR` set to a throwaway directory**, or it writes into the live
`~/.claude` that three sessions share. All runs in this session did so.

Consequence for `AGENTS.md`: the binary path is versioned
(`…/ccd-cli/2.1.286`) and is a fact of one host. The gate should say
"the Claude Code CLI — `claude` on `PATH`, or the path the host file names",
and `host.example.md` `## Tool paths` gains one line. The path changes when
the desktop app updates.

`UNVERIFIED: a model session started with --plugin-dir shows /glab:plan, fires
the bootstrap hook and can dispatch glab:developer — starting a session here
would run every installed hook, including memory-sync against the real backend
(three CLAUDE_MEMORY_S3_* names are set in this shell's environment; values not
read), and would need credentials in the throwaway config dir.` This stays a
user-run smoke test (section 10).

## 2. Doc claims — verified one by one

Pages: `plugins/manifest-reference` (served at `/plugins-reference.md`),
`plugins/components`, `plugins/create`, `plugins/create-marketplace` (served at
`/plugin-marketplaces.md`), `plugins/marketplace-reference`, `plugins/loading`,
`plugins/host-marketplace`, `plugins/org`, `hooks`, `skills`, `sub-agents`,
`env-vars`. URL prefix for all: `https://code.claude.com/docs/en/`.

| # | Claim | Verdict | Evidence |
|---|---|---|---|
| C1 | Manifest at `.claude-plugin/plugin.json`, only `name` required | **Confirmed, and weaker than claimed** | manifest-reference: "`name` is the only required key." Also: "The manifest is optional. Without it, Claude Code loads the components it finds in the standard layout." |
| C2 | `skills/`, `commands/`, `agents/`, `hooks/hooks.json` auto-discovered at the plugin root | **Confirmed** (doc + experiment) | manifest-reference "Standard layout" table. Proven: section 3, `plugin details` lists 14 skills, 5 agents, 1 hook with no component key in the manifest. |
| C3 | `marketplace.json` lists several plugins by relative `source` `./plugins/<name>` | **Confirmed** (doc + experiment) | marketplace-reference: "A directory inside the marketplace, resolved from the marketplace root. Must start with `./`". Proven: section 3. |
| C4 | Root as both plugin and marketplace "not documented" | **Contradicted — it is documented** | marketplace-reference, Relative path row: "`\".\"` on its own means the root itself". A `./` source with a root `plugin.json` also validated (section 3, experiment D). Not used: D1 chose subdirectories. |
| C5 | Every component namespaced under the plugin name | **Confirmed** | manifest-reference: "Claude Code namespaces every component under it, so an agent `reviewer` in plugin `deploy-tools` appears as `deploy-tools:reviewer`." |
| C6 | "no bare invocation" | **Contradicted for skills with a frontmatter `name`** | skills: "In a plugin skill, the frontmatter `name` replaces the directory name in the last segment of the command … The bare `/fancy` also invokes the skill unless another command already uses that name." All 7 skills here set `name:`. See section 5. |
| C7 | Plugin-root `CLAUDE.md` not loaded; validate warns | **Confirmed** (doc + experiment) | components: "Claude Code doesn't load a `CLAUDE.md` at the plugin root, and `claude plugin validate` warns `CLAUDE.md at the plugin root is not loaded as project context`." Proven: section 3, experiment 1. |
| C8 | Plugin `settings.json` honours only `agent` and `subagentStatusLine`; a plugin cannot set `env` | **Confirmed** | components: "Two keys take effect, `agent` and `subagentStatusLine`, and every other key is dropped." |
| C9 | `hooks/hooks.json` or inline; `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}` | **Confirmed** | manifest-reference "Environment variables" table; quoted in section 7. |
| C10 | `userConfig` "declares values Claude Code prompts the user for when the plugin is enabled" | **Confirmed, with two limits the claim omits** | Exact sentence present. Limits: "The `claude plugin install` shell command never prompts for `userConfig` values" and "Loading with `--plugin-dir` doesn't show it" (components, create). |
| C11 | All matching hooks for one event run in parallel | **Confirmed** | hooks: "All matching hooks run in parallel. If you define the same handler in more than one settings file, it runs once. A plugin's or skill's copy of the same handler stays separate." |
| C12 | SessionEnd hooks share 1.5 s unless a longer per-hook timeout is set (up to 60 s) | **Contradicted for plugin hooks — this changes the design** | hooks, SessionEnd: "The overall budget rises automatically to match the highest per-hook `timeout` in your settings files, up to 60 seconds. … **Timeouts set on plugin-provided hooks don't raise the budget.**" See section 7.4 and Q4. |
| C13 | Team rollout via `extraKnownMarketplaces` + `enabledPlugins` | **Confirmed** | org: "`extraKnownMarketplaces` registers a marketplace on each machine, and `enabledPlugins` names the plugins to install and enable from it." |
| C14 | Private GitHub repos clone with the machine's git credentials | **Confirmed** | host-marketplace: "Claude Code runs `git` on their machine with interactive prompts turned off and relies on whatever credentials that machine already holds." For `owner/repo` it tries SSH first, then HTTPS. |
| C15 | Local testing: `claude --plugin-dir ./path`, `claude plugin validate ./path` | **Confirmed** (doc + experiment) | create; section 3. One trap: `--plugin-dir` at the marketplace root loads nothing (experiment E); the working form here is `--plugin-dir ./plugins`. |

## 3. Experiments on a throwaway prototype

Prototype built under `/data/tmp/claude/plugplan-proto-<pid>/mkt` by copying
(not moving) the repo's files into the layout of section 6. Binary:
`/home/pvhv/.claude/remote/ccd-cli/2.1.286`, `CLAUDE_CONFIG_DIR` throwaway.
No `install`, no `marketplace add`. The prototype is deleted at the end of the
planning session.

**Both plugins and the marketplace validate** (no `version` in the manifests):

    ##### validate plugins/glab
      ❯ version: No version specified. Consider adding a version following semver (e.g., "1.0.0")
    ✔ Validation passed with warnings
    ##### validate plugins/memory-sync
      ❯ version: No version specified. …
    ✔ Validation passed with warnings
    ##### validate .
    Validating marketplace manifest: …/mkt/.claude-plugin/marketplace.json
      ❯ plugins[0] plugin.json → version: No version specified. …
      ❯ plugins[1] plugin.json → version: No version specified. …
    ✔ Validation passed with warnings

**With `"version": "0.1.0"` in both manifests, `--strict` is clean** for all
three paths: last line `✔ Validation passed` each.

**Exit codes** (run without a pipe, so the code is the validator's):

    pass rc=0          # valid plugin
    fail rc=1          # unknown key inside a userConfig option
    strict-warn rc=1   # --strict on a manifest with warnings

**Experiment 1 — `CLAUDE.md` at the plugin root:**

      ❯ root: CLAUDE.md at the plugin root is not loaded as project context. To ship context with your plugin, use a skill (skills/<name>/SKILL.md) instead.
    ✔ Validation passed with warnings

**Experiment 3 — the components load and are counted** (`--plugin-dir ./plugins plugin list`, then `plugin details`):

    ❯ glab@inline          Status: ✔ loaded
    ❯ memory-sync@inline   Status: ✔ loaded

    glab — Component inventory
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart
    memory-sync — Component inventory
      Skills (1)  sync-memory
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop

"Skills (14)" is 6 skills + 8 commands: the CLI counts command files as
skills. This is the discriminating check for the plan: a half-moved tree shows
a shorter named list.

**Experiment B — a `${user_config.KEY}` in a shell-form hook command is NOT
caught by `validate`** (`✔ Validation passed`). The docs say it fails at run
time. So validate cannot be the gate for that mistake; a `grep` for
`user_config` in `hooks.json` must be.

**Experiment D — repo root as plugin and marketplace** (`"source": "./"`):
`✔ Validation passed`.

**Experiment E — `--plugin-dir <marketplace root>`:**
`No plugins installed.` Matches the docs ("`--plugin-dir` at a marketplace
root doesn't load the plugins under `plugins/`").

**The moved script still passes its test, unchanged:**

    $ bash tests/memory-sync.test.sh <proto>/plugins/memory-sync/scripts/memory-sync.sh
    PASS 35/35

**The bootstrap hook runs from a plugin path** (shell-form command as it would
be in `hooks.json`, `CLAUDE_PLUGIN_ROOT` set by hand): prints the
`hookSpecificOutput` JSON, `rc=0`.

What these experiments do not prove: anything about a live session — name
resolution in the Skill and Agent tools, hook firing, the `userConfig` dialog,
the SessionEnd budget.

## 4. Baseline gates on today's tree

**Proven**, with `TMPDIR=/data/tmp/claude`:

    memory-sync.sh rc=0
    manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0                       # shellcheck, no findings
    PASS 35/35                 # 35 `ok` lines, 0 `NOT OK`

Mode bits are tracked and must survive the move (`git mv` keeps them):

    100755 manager-bootstrap.sh
    100755 memory-sync.sh
    100755 tests/memory-sync.test.sh

## 5. How names resolve after namespacing

| Thing | Rule | Source | Status |
|---|---|---|---|
| Skill, user-typed | `/glab:manager`. Bare `/manager` also works **because the frontmatter sets `name`**, "unless another command already uses that name" | skills, "How a skill gets its command name" | Doc |
| Skill frontmatter `name:` | Stays bare. The prefix is added by Claude Code. A `name` that already carries the prefix is tolerated only on v2.1.246+, and was doubled on v2.1.216–2.1.245 | same section | Doc — **do not write `name: glab:manager`** |
| Skill, model-invoked (Skill tool) | Listed and invoked as `plugin:skill` | Observed in this session's own skill list: installed plugin skills appear as `engineering:code-review`, `product-management:brainstorm`; user-level ones appear bare (`plan`, `manager`) | Proven for the listing; `UNVERIFIED: the Skill tool accepts a bare name for a plugin skill — not documented, not testable without a session` |
| Command file | `/glab:plan` ("Save a command at `commands/<file>.md` and it becomes `/<plugin>:<file>`") | components, Commands | Doc |
| Command, bare | The 8 command files set no `name` (frontmatter read: only `description`, `argument-hint`). The bare-name sentence is written about a frontmatter `name`. `UNVERIFIED: bare /plan resolves to the plugin command` | — | Not documented |
| Bare `/review` in particular | Already taken: "`Skill(review)` — The bundled `/code-review`, through its `/review` alias" | skills, permission table | Doc — a bare `/review` in plugin text points at the wrong thing |
| Agent | `glab:developer` — "The name form is `<plugin>:<name>`, where `<name>` comes from the frontmatter, or from the file name when there is none" | components, Agents | Doc |
| Agent frontmatter `name:` | Stays bare, and must: "Names can't contain `:` … Claude Code doesn't load a file whose name contains one" | sub-agents, frontmatter table | Doc |
| Agent, bare, in the Agent tool | Bare works for the CLI flag only: "For a plugin-provided subagent, you can pass only the agent name and Claude Code finds it: `claude --agent security-reviewer`". `UNVERIFIED: subagent_type "developer" resolves to glab:developer in the Agent tool` | sub-agents | Not documented for the tool |
| Hook matchers on agent type | Use the scoped name, anchored: `^my-plugin:db-agent$` | sub-agents | Doc; not used by this repo |

**What must be prefixed, and what need not be.** D3 says text uses the
prefixed names, so the rule the plan applies is mechanical:

- **Prefix** every *identifier* reference: a backticked skill or agent name, a
  slash command, a bold or "the X agent" dispatch instruction. These are what a
  model copies into a tool call or a user types. (Lists R1, R3, R4, R6, R7.)
- **Leave bare** every frontmatter `name:` (R2, R5) — required by the docs.
- **Leave bare** role nouns in running prose that are not identifiers: "the
  analyzer drifts", "dispatch analyzers", "the reviewer looked at". Prefixing
  those reads worse and names nothing callable. This is the one judgment call;
  the regexes in section 9 deliberately do not match them.
- The three `UNVERIFIED` rows above are covered by prefixing everything, and
  become a verification step in the smoke test, not an assumption.

## 6. Target layout

Chosen boundary (D1, D2): marketplace at the repo root, plugins in
`plugins/<name>/`.

    .claude-plugin/marketplace.json          new
    plugins/glab/.claude-plugin/plugin.json  new
    plugins/glab/skills/{bootstrap,manager,security,comments,plan-first,audit}/   git mv from skills/
    plugins/glab/agents/*.md                 git mv from agents/      (5)
    plugins/glab/commands/*.md               git mv from commands/    (8)
    plugins/glab/hooks/hooks.json            new (1 SessionStart hook)
    plugins/glab/scripts/manager-bootstrap.sh    git mv from manager-bootstrap.sh
    plugins/memory-sync/.claude-plugin/plugin.json   new
    plugins/memory-sync/skills/sync-memory/SKILL.md  git mv from skills/sync-memory/
    plugins/memory-sync/hooks/hooks.json     new (4 events)
    plugins/memory-sync/scripts/memory-sync.sh   git mv from memory-sync.sh
    tests/memory-sync.test.sh                stays (repo-only; not shipped in a plugin)
    AGENTS.md  README.md  host.example.md  plan/   stay at the root
    settings.example.json                    depends on Q3 and Q4
    CLAUDE.md                                depends on Q7

Disposition of all 29 tracked files outside `plan/`
(`git ls-files | /usr/bin/grep -v '^plan/' | wc -l` → 29):

| Count | Files | Disposition |
|---|---|---|
| 7 | `skills/{bootstrap,manager,security,comments,plan-first}/SKILL.md`, `skills/audit/SKILL.md`, `skills/audit/references/plan-template.md` | `git mv` to `plugins/glab/skills/…`, then edit references |
| 1 | `skills/sync-memory/SKILL.md` | `git mv` to `plugins/memory-sync/skills/sync-memory/`, then edit |
| 5 | `agents/*.md` | `git mv` to `plugins/glab/agents/`, then edit |
| 8 | `commands/*.md` | `git mv` to `plugins/glab/commands/`, then edit |
| 1 | `manager-bootstrap.sh` | `git mv` to `plugins/glab/scripts/`, then edit the injected text |
| 1 | `memory-sync.sh` | `git mv` to `plugins/memory-sync/scripts/`; edits depend on Q3, Q5 |
| 1 | `tests/memory-sync.test.sh` | stays; only its invocation argument changes |
| 3 | `AGENTS.md`, `README.md`, `host.example.md` | stay; edited (README rewritten) |
| 1 | `settings.example.json` | Q3/Q4 |
| 1 | `CLAUDE.md` | Q7 |
| **29** | | 7+1+5+8+1+1+1+3+1+1 = 29 |

Notes that the plan must carry:

- `skills/audit/SKILL.md:21` and `:69` link `../plan-first/SKILL.md`. Both
  skills land in the same plugin as siblings, so the relative link survives.
- `--plugin-dir` for local testing is `./plugins` (loads both) or one plugin
  directory — never the repo root (experiment E).
- `marketplace.json` requires `name`, `owner`, `plugins`; validate "warns when
  [`description` is] missing". Entry `name` must equal the manifest `name`
  ("Keep the two names the same").
- Hook commands are shell-form with the variable quoted:
  `"\"${CLAUDE_PLUGIN_ROOT}\"/scripts/memory-sync.sh pull"` — validate warns
  on an unquoted one.

**Rejected boundaries.**

- *One plugin holding everything.* Rejected by D2; also it would force the S3
  hooks on anyone who wants only the workflow.
- *Repo root as the `glab` plugin (`"source": "./"`), memory-sync in a
  subdirectory.* It validates (experiment D), and it would keep `skills/`,
  `agents/`, `commands/` where they are — no moves. Rejected: the root plugin
  would ship `tests/`, `plan/` and the other plugin's directory into every
  user's cache, and a root `CLAUDE.md` would draw the validate warning. D1 also
  says subdirectories.
- *`bin/memory-sync.sh`* so the script is a bare command. Rejected: "Files
  here are on the Bash tool's `PATH` while the plugin is enabled", which puts
  the one mode that deletes (`delete`) one bare word away from every agent in
  every session; and "claude.ai and Cowork don't install a plugin that has
  this directory".
- *Tests inside `plugins/memory-sync/tests/`.* Rejected: they would be copied
  to every installing machine and they are a repo gate, not a product.

## 7. memory-sync plugin — design facts

### 7.1 What a hook process receives

Doc, manifest-reference "Where each variable resolves", row *Hook commands*:
`${...}` resolves "Anywhere in `command` and `args`", and "Exported to the
process: `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`, `CLAUDE_PROJECT_DIR`, and
`CLAUDE_PLUGIN_OPTION_<KEY>`". So both: substitution and environment.

`userConfig` values reach a hook two ways (manifest-reference, "Reference a
saved value"):

- "`${user_config.KEY}`: substituted in MCP server config, LSP server config,
  exec-form hook `args`, and skill and agent content. In skill and agent
  content, only non-sensitive values are substituted, and a sensitive value
  there becomes a placeholder"
- "`CLAUDE_PLUGIN_OPTION_<KEY>`: exported to hook processes for every option,
  with `<KEY>` uppercased."
- "Shell-form hook commands … reject `${user_config.*}`."

Storage: "Non-sensitive values are saved under `pluginConfigs` in the user's
`settings.json`. Sensitive values go to the platform's secure credential store
instead."

### 7.2 What a hand-run command receives — the fact that splits the design

Doc, same section: "The variables aren't present in the environment of
commands Claude runs through the Bash tool, in the main session or in a
subagent. In skill, command, and agent content, write the `${...}` reference
in the Markdown body instead, and Claude Code substitutes the path inline when
it loads the content."

The `sync-memory` skill runs the script by hand (`SKILL.md:30`, `:101`) and
its status check tests `$CLAUDE_MEMORY_S3_URI` in the Bash tool (`:49-57`).
Therefore:

- The **script path** is solvable: the skill body writes
  `"${CLAUDE_PLUGIN_ROOT}/scripts/memory-sync.sh"` and Claude Code substitutes
  it. (Doc; `UNVERIFIED` in a live session.)
- The **S3 settings are not**: `CLAUDE_PLUGIN_OPTION_*` exists only in hook
  processes. With `userConfig` as the only source, hooks sync and every hand
  run prints `CLAUDE_MEMORY_S3_URI is not set; skipping`. The only doc-supported
  way to hand a `userConfig` value to a hand-run command is to substitute it
  into the skill text — which puts the bucket URI into model context and the
  transcript (non-sensitive option), or yields a placeholder (sensitive
  option). The skill today is written to avoid exactly that ("Test it without
  printing its value", `:50`).

The `env` block of `settings.json` has neither problem: it reaches hooks and
the Bash tool alike, which is how it works today. This is Q3.

### 7.3 The script's inputs, today (call-site audit)

`memory-sync.sh` is called from: `settings.example.json:11,19,27,34` (4 hook
commands), the `sync-memory` skill (`:30`, `:101`, by hand),
`tests/memory-sync.test.sh:63` (as `bash "$SCRIPT"`), and `README.md:80`
(`delete`, by hand). No other caller in tracked files outside `plan/`
(R8, section 9).

| Input | Read at | Callers rely on |
|---|---|---|
| `$1` mode, `$2` path | `:35`, `:276` | hooks pass `pull` / `push` / `push-if-changed`; test passes all four + `bogus` |
| `CLAUDE_CONFIG_DIR`, else `$HOME/.claude` | `:36` | the test isolates every run with `CLAUDE_CONFIG_DIR="$W/conf"` (`test:61`) |
| `CLAUDE_MEMORY_S3_URI` | `:148`, `:154` | test sets `s3://stub/mem`; skill tests it for emptiness |
| `CLAUDE_MEMORY_S3_ARGS` | `:172` | test T12 |
| `CLAUDE_MEMORY_S3_TIMEOUT` | `:41`, `:83-94` | test T-cases for 12 / 17 / rejects |
| `AWS_PROFILE` | not read by the script; inherited by `aws` | test unsets it (`test:60`) |
| `basename "$0"` | `:73` | test T33 compares the usage line against `basename "$SCRIPT"` — unchanged by a move, the file keeps its name |

The contract that must not change without a plan (`AGENTS.md:47-48`): mode
names, exit 0 on every path, nothing on stdout, messages on stderr. The move
itself changes none of it — proven by `PASS 35/35` on the moved copy
(section 3).

### 7.4 Timeouts in a plugin

- `SessionStart`, `PostToolUse`, `Stop`: the per-hook `"timeout": 20` in
  `hooks.json` carries over (doc: `timeout` is a common command-hook field,
  "Seconds before canceling"). The `TIMEOUT + 3 ≤ 20` bound
  (`memory-sync.sh:38-45`, `:96-101`) holds as written.
- **`SessionEnd`: it does not carry over.** Doc: "SessionEnd hooks have a
  default timeout of 1.5 seconds. … The overall budget rises automatically to
  match the highest per-hook `timeout` in your settings files, up to 60
  seconds. … Timeouts set on plugin-provided hooks don't raise the budget."
  The other lever: "`CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`: set this
  environment variable in milliseconds to override the budget explicitly. The
  value you set also becomes the timeout for each hook without its own
  `timeout`." (env-vars lists it; settings `env` values "take effect no matter
  how `claude` was launched".)
- Inferred consequence: a `push` from the plugin's `SessionEnd` hook gets
  1.5 s unless the user sets that variable or has some other settings-file
  `SessionEnd` hook with a longer timeout. When it is cut, the harness kills
  the script, so it cannot log; `.memory-sync-pushed.next` is left behind
  (`:224-226`, follow-up 10 of the previous plan); `FAILED` is not written;
  the kernel releases the `flock`. Edits made during the session have normally
  already gone out through `push-if-changed` on `PostToolUse` and `Stop`.
  `UNVERIFIED: what the harness does to the process at 1.5 s, and that the
  variable set in the settings env block raises the budget for a plugin hook —
  both need a live session.` This is Q4.
- `README.md:72-74` states the old rule ("Keep the explicit `timeout` on the
  `SessionEnd` hook…") and becomes wrong for a plugin; it must be rewritten
  whatever Q4 decides.

### 7.5 State files — where they live and what moving them means

Today, all under `CONF` (`memory-sync.sh:36`):

| File | Line | Role |
|---|---|---|
| `$CONF/projects` | `:37` | the memories themselves — Claude Code's own location, cannot move |
| `$CONF/.memory-sync-stage` | `:54` | pull cache, pruned to the remote on each pull |
| `$CONF/.memory-sync-pushed` (+ `.next`) | `:56`, `:224` | time of last successful push |
| `$CONF/.memory-sync-failed` | `:60` | 300 s cool-down marker |
| `$CONF/.memory-sync.lock` | `:64` | one lock for pull, push, delete |

`${CLAUDE_PLUGIN_DATA}` (doc): "`~/.claude/plugins/data/<id>/`, created on
first reference and kept across plugin updates", and "By default, Claude Code
deletes the `${CLAUDE_PLUGIN_DATA}` directory when you uninstall the plugin
from the last place it's installed."

State transitions if the four state files moved there:

| | Before | After success | After a partial adoption |
|---|---|---|---|
| Lock | one lock shared by hooks and hand runs | hooks use the data-dir lock; a hand run does not have `CLAUDE_PLUGIN_DATA` in its environment (7.2) and would fall back to `$CONF` unless the skill passes the substituted path every time | two locks → a hook push and a hand `delete` can run at once, which is the race the lock exists to stop (`:62-63`) |
| Stamp | `$CONF/.memory-sync-pushed` | new location has no stamp → `changed` returns true (`:185`) → one full `push-if-changed`; harmless | old stamp orphaned in `$CONF` |
| Stage | `$CONF/.memory-sync-stage` | re-downloaded on first pull; the old stage is orphaned and is never pruned again | — |
| Cool-down | `$CONF/.memory-sync-failed` | fresh | an old marker orphaned |
| Old hooks still wired in `settings.json` during adoption | — | — | old copy and plugin copy hold **different** locks and sync concurrently |
| Uninstall | nothing removed | data dir deleted: stamp and stage lost, both rebuildable | — |

Staying in `$CONF`: no script change, one lock for every caller, and an old
copy and a plugin copy running side by side are serialised by the same lock
(`push-if-changed` logs `another sync is running; skipping`). This is Q5.

### 7.6 What changes in the test and the gates

Whatever Q3–Q5 decide, because paths move:

- `AGENTS.md:15-17` — the three gate commands name
  `memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh` and
  `bash tests/memory-sync.test.sh memory-sync.sh`. They become the new paths;
  the test file itself needs no edit for the move (it takes the script path as
  `$1`, `test:4-6`). Expected output is unchanged: three `rc=0`, `rc=0`,
  `PASS 35/35`.
- New gates: `claude plugin validate` × 3 (each plugin, the marketplace) with
  a throwaway `CLAUDE_CONFIG_DIR`; `plugin details` × 2 for the named
  component lists; JSON well-formedness is covered by validate
  ("`json: Invalid JSON syntax`").
- If Q3 adds a `CLAUDE_PLUGIN_OPTION_*` fallback or Q5 adds
  `CLAUDE_PLUGIN_DATA`, the test's `run` (`test:57-65`) must `env -u` those
  names so a developer's own session cannot leak into a run, and new cases are
  needed for precedence. No case exists for either today (0 hits for `PLUGIN`
  in the test).
- `AGENTS.md:47` "hook contract" stays word for word.

## 8. What replaces the root `CLAUDE.md`

A plugin cannot ship global instructions (C7, C8). The `SessionStart` hook is
the only always-on text a plugin has: "Claude Code adds plain-text stdout as
context" for `SessionStart`, and `additionalContext` is "capped at 10,000
characters" (hooks). `manager-bootstrap.sh` emits about 1.6 KB.

Rule-by-rule map of `CLAUDE.md` (26 lines) against what the hook already says
(`manager-bootstrap.sh:7-17`):

| `CLAUDE.md` | Rule | Already in the hook? | Lands |
|---|---|---|---|
| `:1-4` | Load `bootstrap` first | yes, `:11` | hook, prefixed `glab:bootstrap` |
| `:6-8` | "irreducible minimum: the rules that must hold even in a session where `bootstrap` never got loaded" | no — it is the reason, not a rule | header comment of the hook script, which is now the only place that minimum lives |
| `:10-13` | `manager` and `security` every session; a gate is never green on an agent's word | yes, `:12-13`, `:17` | hook, prefixed |
| `:14-15` | Read `AGENTS.md`; none → `CLAUDE.md`, say so | yes, `:9` | hook, unchanged (this `CLAUDE.md` is the target repo's, not the payload) |
| `:16-18` | Every dispatched agent reads `AGENTS.md`, carries `security` and `comments`; "See `manager` Rule 0c" | first half yes, `:15`; **the Rule 0c pointer is missing** | add the pointer to hook item 3 |
| `:19-26` | Temp files go where `~/.claude/host.md` says; no host file → say so, `$TMPDIR`, else scratchpad, few and small; repeat in every dispatch | **no** | **new hook item 4**; also already in `bootstrap` step 1 (`SKILL.md:28-33`) and step 6 (`:124-132`) |

So two additions to the hook text keep every rule: the Rule 0c pointer and the
host-file item. Nothing else in `CLAUDE.md` is unique to it. What happens to
the file is Q7.

One loss that no text can repair, stated plainly: today the rules arrive twice
(global `CLAUDE.md` and the hook). After the change they arrive once, and only
when the `glab` plugin is enabled and its hook fires.

No `TODO` / `FIXME` / `HACK` / `NOTE` / `XXX` marker exists in any tracked file
outside `plan/`. The search hit 11 lines, all of them prose *about* markers
(`skills/comments/SKILL.md:3,88,92-96,109`, `skills/manager/SKILL.md:42`,
`skills/bootstrap/SKILL.md:48`, `agents/reviewer.md:15`); positive control: the
same pattern finds those 11. So no marker can be lost in the move. Recorded
incidents that must travel with their files: the 2026-09-23 lost-edit note
(`memory-sync.sh:47-53`), the host `/tmp` quota case (`host.example.md:11-19`),
the hazards in `bootstrap` step 6.

## 9. The cross-reference surface

Scope: the 29 tracked files outside `plan/`. `/usr/bin/grep -n -o -E`, one
count per occurrence (not per line). Positive control run first:
`` `bootstrap` `` in `CLAUDE.md` → lines 1, 6, 8, 26, as expected. `N×k` means
k occurrences on line N. Categories overlap by design (`~/.claude/memory-sync.sh`
is in R8 and R10), so each category sums on its own.

**R1 — skill identifier in backticks** — `` `(bootstrap|manager|security|comments|plan-first|audit|sync-memory)` ``

- CLAUDE.md (11): 1, 6, 8, 10×3, 11, 16, 17×2, 26
- README.md (12): 12×7, 15, 19, 20×2, 81
- agents/reviewer.md (2): 15×2
- commands/develop.md (2): 13, 51
- commands/plan.md (3): 6, 12, 16
- host.example.md (1): 4
- manager-bootstrap.sh (7): 11, 12, 13, 15×2, 17×2
- skills/bootstrap/SKILL.md (16): 35×2, 39, 41, 45, 46, 47, 51, 52, 53, 54×2, 57, 59, 87, 100
- skills/manager/SKILL.md (8): 12, 20, 38, 41, 50, 53, 54, 258
- **Total 62** in 9 files (11+12+2+2+3+1+7+16+8). → prefix; `sync-memory` (README only, 2 of the 62) becomes the memory-sync plugin's name.

**R2 — skill frontmatter `name:`** — line 2 of each of the 7 `SKILL.md`. **Total 7.** → unchanged.

**R3 — skill named without backticks** — bare `plan-first` / `sync-memory`, `[plan-first]` link text, "… skill(s)" phrases

- commands/develop.md (1): 2 — description, "plan-first steps 5 to 7"
- commands/plan.md (1): 2 — description, "the plan-first skill"
- manager-bootstrap.sh (1): 2 — comment
- skills/audit/SKILL.md (3): 3 (description), 21, 69 (link text)
- skills/bootstrap/SKILL.md (1): 3 — description, "the manager and security skills"
- skills/plan-first/SKILL.md (1): 2 — the `name:` line, same line as R2
- skills/sync-memory/SKILL.md (1): 2 — the `name:` line, same line as R2
- **Total 9** in 7 files; 2 are R2 lines and stay, **7 change**.

**R4 — agent identifier in backticks**

- README.md (5): 13×5
- commands/develop.md (2): 8, 37
- skills/manager/SKILL.md (3): 241, 285, 303
- **Total 10** in 3 files. → prefix.

**R5 — agent frontmatter `name:`** — line 2 of each of the 5 agent files. **Total 5.** → unchanged.

**R6 — agent named as a dispatch instruction** — `**X** agent`, `X agent(s)`

- commands/analyze.md (2): 2, 6
- commands/commit.md (2): 2, 8
- commands/develop.md (1): 2
- commands/integrate.md (2): 2, 6
- commands/review.md (2): 2, 8
- commands/ship.md (4): 2×2, 16, 36
- **Total 13** in 6 files. → prefix. Line 2 of each is the command's `description`.

**R7 — slash command** — `(^|[ `(*"])/(plan|develop|analyze|integrate|review|commit|push|ship)($|[^A-Za-z0-9_/-])`

- README.md (8): 14×8
- agents/analyzer.md (3): 3×2, 69
- agents/developer.md (2): 3, 9
- agents/integrator.md (3): 3×3
- commands/analyze.md (3): 10, 14, 15
- commands/commit.md (1): 12
- commands/develop.md (7): 2, 12, 13, 47, 61, 67×2
- commands/integrate.md (4): 10×2, 16, 17
- commands/plan.md (1): 16
- commands/ship.md (3): 14×2, 40
- skills/manager/SKILL.md (19): 97, 98, 99, 100, 101, 102, 103, 104, 125, 155, 161, 190, 239, 275, 285, 293, 303, 309×2
- **Total 54** in 11 files (8+3+2+3+3+1+7+4+1+3+19). → `/glab:<cmd>`.
  Control: the pattern finds `skills/manager/SKILL.md:97` and does not match
  `plan/<slug>/plan.md` paths (`agents/analyzer.md:15` is absent). A first,
  looser pattern counted 60 by matching `}/plan.md`; a stricter one counted 51
  by missing `/develop.` at a sentence end. 54 is the reconciled figure.

**R8 — `memory-sync.sh`**

- AGENTS.md (7): 15, 16, 17, 43, 47, 54, 55
- README.md (9): 17, 31, 50, 63, 64, 65, 66, 77, 80
- memory-sync.sh (4): 5, 10, 11, 14 — usage lines in its own header, unchanged
- settings.example.json (4): 11, 19, 27, 34
- skills/sync-memory/SKILL.md (3): 12, 30, 101
- tests/memory-sync.test.sh (2): 2, 4 — comment and usage text, unchanged
- **Total 29** in 6 files.

**R9 — `manager-bootstrap.sh`** — AGENTS.md (2): 15, 16 · README.md (4): 16, 39, 50, 63 · settings.example.json (1): 12 · **Total 7** in 3 files.

**R10 — `~/.claude`**

- AGENTS.md (3): 4, 5, 45
- CLAUDE.md (1): 19 — `~/.claude/host.md`
- README.md (8): 6, 8, 29, 30, 43, 50, 53, 59
- host.example.md (1): 3
- memory-sync.sh (1): 19 — the memory directory, unchanged
- settings.example.json (5): 11, 12, 19, 27, 34
- skills/bootstrap/SKILL.md (2): 28 (`host.md`), 109 (memory index) — both unchanged
- skills/sync-memory/SKILL.md (13): 11, 12×2, 30, 52, 57, 60, 65, 69, 75, 101, 104, 135
- **Total 34** in 8 files. Of the 13 in `sync-memory`: 5 are the memory
  directory (11, 57, 75, 104, 135) and stay; 3 are the script path (12, 30,
  101); 3 are `settings.json` (12, 52, 65); 2 are state files (60, 69, Q5).
  5+3+3+2 = 13.

**R11 — `CLAUDE.md`** — **Total 22** in 18 files: AGENTS.md 6 · CLAUDE.md 15 ·
README.md 15, 34, 50 · agents/analyzer.md 18 · committer.md 13 · developer.md
15 · integrator.md 11 · reviewer.md 13×2 · commands/analyze.md 6 · commit.md
6 · develop.md 6 · integrate.md 6 · plan.md 6 · review.md 6 · ship.md 10 ·
manager-bootstrap.sh 3, 9 · skills/bootstrap/SKILL.md 20 ·
skills/manager/SKILL.md 16. **Only 4 name the payload file** (AGENTS.md:6,
README.md:15, 34, 50) and change. The other 18 are the "no `AGENTS.md` → read
`CLAUDE.md`" fallback about the *target* repo and stay word for word
(`AGENTS.md:52` lists that fallback as a one-fact-one-value case).

**R12 — `settings.json` / `settings.example.json`** — AGENTS.md (1): 53 ·
README.md (5): 29×2, 58×2, 59 · memory-sync.sh (1): 39 (comment: "the hook
timeout in settings.example.json is 20 s" — must be updated to name
`hooks/hooks.json`) · skills/sync-memory/SKILL.md (3): 12, 52, 65 ·
**Total 10** in 4 files.

**R13 — `host.md` / `host.example.md`** — CLAUDE.md (2): 19, 23 · README.md
(4): 30×2, 43×2 · host.example.md (1): 3 · skills/bootstrap/SKILL.md (3): 28,
30, 131 · **Total 10** in 4 files. `~/.claude/host.md` stays a hand-made
per-machine file (standing answer), so the bootstrap lines stay.

**R14 — repo-relative paths that move** — AGENTS.md (10): 15, 16, 17, 33, 44,
51×3, 52, 54 · README.md (4): 12, 13, 14, 31 · agents/integrator.md (2): 17,
70 (a generic `tests/` in another repo — not ours, unchanged) · **Total 16**
in 3 files; 14 change.

**R15 — `subagent_type`** — **0** hits. Positive control for the method: the
same loop finds 54 for R7. No file names a literal subagent type; dispatch is
always prose (R4, R6).

**Sum of the fifteen category totals:** 62+7+9+10+5+13+54+29+7+34+22+10+10+16+0
= **288** occurrences, overlaps included.

**`plan/` (10 tracked files)** holds historical records: 149 `memory-sync.sh`,
82 `~/.claude`, 86 `CLAUDE.md`, 41 settings, 373 repo paths. They describe the
tree as it was and are **not** edited (`AGENTS.md:60`, "`plan/` is tracked and
permanent"). Every "no bare reference remains" check in the plan must
therefore exclude `plan/`.

**Files with nothing to change beyond the move:** `skills/security/SKILL.md`,
`skills/comments/SKILL.md`, `skills/audit/references/plan-template.md`,
`commands/push.md` (0 hits in R1, R3, R4, R6, R7 — it names no skill, agent or
command).

## 10. Interaction between the two plugins, and risks

**Independence — proven both ways** (control: the same pattern finds 11 lines
in `README.md`):

    glab-bound files naming memory-sync / sync-memory / CLAUDE_MEMORY:   rc=1 (no match)
    memory-sync-bound files naming a glab skill, agent, command,
      manager-bootstrap, AGENTS.md or host.md:                            rc=1 (no match)

Neither plugin needs a `dependencies` entry. The only file naming both is
`README.md`. Both add a `SessionStart` hook; they "run in parallel" (C11), as
the two commands in one group do today (`settings.example.json:11-12`).

**Nothing in this change touches `~/.claude`** (D4). The plan's gates use a
throwaway `CLAUDE_CONFIG_DIR` (section 1). `AGENTS.md:45` ("Nothing is copied
into `~/.claude` by an agent") gains the plugin equivalent: no agent runs
`claude plugin install`, `marketplace add`, `enable` or `configure`.

**Risk in the user-run smoke test.** `claude --plugin-dir ./plugins` in a
normal session loads the plugins *on top of* the live `~/.claude`:

- every skill, agent and command exists twice (bare from `~/.claude`, prefixed
  from the plugin) — harmless, and useful for comparing;
- the bootstrap text is injected twice ("A plugin's … copy of the same handler
  stays separate", C11);
- **the memory-sync hooks fire twice against the real backend**, since the
  live `env` block is present. With state in `$CONF` (Q5) the two share one
  lock and the second skips or waits; it is the same traffic as today, doubled.
  To keep the smoke test off the backend, load only `./plugins/glab`, and test
  memory-sync separately with `CLAUDE_MEMORY_S3_URI` unset.

**Adoption on the user's own machine — later, by the user, not plan steps.**
While old copies and plugins coexist: duplicate skills/agents/commands; double
bootstrap injection; double sync. To switch: (1) with no session mid-work,
`claude plugin marketplace add glab-services/skills` and install both;
(2) remove the 4 hook entries and the bootstrap entry from
`~/.claude/settings.json`, keeping or removing the `env` block per Q3;
(3) delete `~/.claude/skills/{the 7}`, `~/.claude/agents/{the 5}`,
`~/.claude/commands/{the 8}`, `~/.claude/manager-bootstrap.sh`,
`~/.claude/memory-sync.sh`; (4) deal with `~/.claude/CLAUDE.md` per Q7;
(5) keep `~/.claude/host.md`; (6) state files per Q5; (7) the live
`PostToolUse`/`Stop` timeouts were 60 s against the example's 20 s (previous
plan's adoption note) — the plugin ships 20. Sessions already running keep
what they loaded until restarted.

`UNVERIFIED: the private repo glab-services/skills installs with
"claude plugin marketplace add glab-services/skills" on a teammate's machine —
needs that machine's git credentials; D4 forbids trying it here.` The remote
is `https://github.com/glab-services/skills.git` (proven, userinfo stripped).

## 11. Proven / inferred summary

| Claim | Status | How |
|---|---|---|
| A CLI binary exists and `plugin validate` runs here | proven | section 1 |
| The CLI writes to its config dir on `validate` | proven | `ls` of the throwaway dir |
| The section 6 layout validates and loads 14+5+1 and 1+4 components | proven | section 3 |
| The script passes 35/35 from its new path, unedited | proven | section 3 |
| Today's gates are green | proven | section 4 |
| The two plugins do not reference each other | proven | section 10, with control |
| No marker comment exists outside `plan/` | proven | section 8, with control |
| Reference counts R1–R15 | proven | section 9; R7 reconciled across three patterns |
| Frontmatter `name:` must stay bare | doc | section 5 |
| Plugin `SessionEnd` timeouts do not raise the 1.5 s budget | doc | section 7.4 |
| Hand-run commands do not see plugin variables or options | doc | section 7.2 |
| Prefixed names resolve in a live session; bare ones do not | UNVERIFIED | user smoke test |
| Behaviour at the SessionEnd budget; the override variable | UNVERIFIED | user smoke test |
| `userConfig` dialog and `pluginConfigs` storage | UNVERIFIED | needs an install; D4 |
| Install from the private GitHub repo | UNVERIFIED | needs another machine |
