# Questions — feature-plugin-marketplace

Seven are open (Q1–Q7). `plan.md` is not written until they are answered.
Evidence for every statement here is in `findings.md`; section numbers refer
to it.

## Answered — decisions already made by the user (binding)

| # | Decision |
|---|---|
| D1 | Plugin-first. Plugins live in subdirectories of this repo; "layout mirrors `~/.claude`" is given up. |
| D2 | Two plugins. `glab`: the skills bootstrap, manager, security, comments, plan-first, audit; the five agents; the eight commands; the SessionStart bootstrap hook. A separate memory-sync plugin: the sync-memory skill, `memory-sync.sh`, its hooks, its S3 configuration. |
| D3 | Plugin only. The `cp` install is dropped; README documents only the plugin install. Text uses the prefixed names. |
| D4 | Repo only. Nothing is installed, enabled or changed in this machine's live Claude config. Testing is `claude --plugin-dir <path>` and `claude plugin validate <path>`. |
| S1 | The manager test rules (no hand-written mocks, generator directive, coverage ≥ 95 %) are universal and stay as written. |
| S2 | In this repo a stub executable on `PATH` is the allowed way to fake a CLI for shell scripts (`AGENTS.md` `## Tests`). |
| S3 | Review cap is 3. |
| S4 | `~/.claude/host.md` stays a per-machine file each person creates by hand. |
| S5 | No real bucket name, endpoint, profile or env value anywhere. |

How D3 is applied (not a question — recorded so the plan can be checked
against it): every *identifier* reference is prefixed (backticked skill or
agent name, slash command, "use the **X** agent"); every frontmatter `name:`
stays bare because the docs require it; role nouns in running prose ("the
analyzer drifts") stay as they are. Section 5.

---

## Q1 — What is the marketplace called?

**Problem.** `marketplace.json` needs a `name`. Users type it after `@` on
every install (`glab@<name>`), it is the key under `extraKnownMarketplaces`
and `enabledPlugins`, and it names the data directory
(`~/.claude/plugins/data/glab-<name>/`). "Each user registers one marketplace
per `name`." Renaming later means every user removes and re-adds it, which
"uninstalls its plugins".

**Why it blocks.** The name is written into `marketplace.json`, the README
install commands and the smoke-test commands.

| | Candidate | Consequence |
|---|---|---|
| a | `glab-services` | `glab@glab-services`, `memory-sync@glab-services`. Matches the GitHub owner; room for more plugins from the same org. |
| b | `glab` | `glab@glab`. Shortest, but plugin and marketplace share a name, which reads as a typo and makes messages ambiguous. |
| c | `glab-skills` | `glab@glab-skills`. Matches the repo's purpose today; wrong the day it holds something that is not a skill. |

Not available: `skills`-like generic names collide easily; `gh`, `github`,
`agent-skills` and anything starting `claude-`/`anthropic-` are reserved.

**Recommendation: (a) `glab-services`.**

## Q2 — What is the memory-sync plugin called, and does its skill keep its name?

**Problem.** The plugin name prefixes its one skill. The skill is `sync-memory`
today.

**Why it blocks.** It fixes the directory `plugins/<name>/`, the manifest, the
marketplace entry, and every prefixed reference in the README and the skill.

| | Candidate | Consequence |
|---|---|---|
| a | plugin `memory-sync`, skill stays `sync-memory` | `/memory-sync:sync-memory`. Repetitive to read; no rename, history follows with a plain `git mv`. Bare `/sync-memory` keeps working per the docs because the skill sets `name:` (unverified in a session). |
| b | plugin `memory-sync`, skill renamed `sync` | `/memory-sync:sync`. Reads best; costs a skill rename (directory, `name:`, description triggers) and bare `/sync` is a much more collision-prone word. |
| c | plugin `glab-memory`, skill stays `sync-memory` | `/glab-memory:sync-memory`. Groups visually with `glab`; but nothing in it depends on `glab`, and the script, hooks and log prefix all say `memory-sync`. |

**Recommendation: (a).** Smallest change, and the plugin is named after the
script everyone already greps for.

## Q3 — How does the memory-sync plugin get its S3 settings?

**Problem.** D2 puts "its S3 configuration" with the memory-sync plugin. The
script reads `CLAUDE_MEMORY_S3_URI`, `CLAUDE_MEMORY_S3_ARGS`,
`CLAUDE_MEMORY_S3_TIMEOUT` from the environment and `aws` reads `AWS_PROFILE`.
A plugin cannot set `env` (only `agent` and `subagentStatusLine` are honoured
in a plugin `settings.json`). The plugin mechanism is `userConfig`, whose
values reach **hook processes only**, as `CLAUDE_PLUGIN_OPTION_<KEY>`. A
command Claude runs by hand through the Bash tool does not get them — and the
`sync-memory` skill is exactly that: `push`, `pull`, `delete` and the status
check are run by hand. The only documented way to pass a `userConfig` value to
a hand-run command is to substitute it into the skill text, which puts the
bucket URI into the model's context and the transcript (or, for a `sensitive`
option, substitutes a placeholder so it cannot be used at all). Section 7.1,
7.2.

**Why it blocks.** It decides whether `memory-sync.sh` changes at all (its
inputs are part of the contract `AGENTS.md` protects), whether the manifest
has a `userConfig`, what `settings.example.json` becomes, and what the skill's
status check says.

| | Candidate | Consequence |
|---|---|---|
| a | **Environment stays the source.** No `userConfig`. `settings.example.json` shrinks to the `env` block only and moves beside the plugin; the README says to merge it. | Script unchanged, test unchanged, hooks and hand runs both work, the URI is never printed. Cost: installing the plugin is not enough — one `env` block is still merged by hand, and `AWS_PROFILE` in that block still applies to every `aws` command in every session (the caveat at `README.md:76-78`). |
| b | **`userConfig` only.** Script reads `CLAUDE_PLUGIN_OPTION_S3_URI` etc. | Configuration by dialog, and the profile can be scoped to the sync hooks. Cost: every hand run from the skill reports "not set; skipping" unless the skill substitutes the values into its own text — which prints the bucket URI into context, against the skill's own rule (`SKILL.md:50`). Script inputs change; new test cases; `--plugin-dir` and shell `claude plugin install` never show the dialog. |
| c | **Both: environment wins, `userConfig` is the fallback.** | Hooks work from the dialog alone; hand runs work only where the `env` block is also set, and the skill has to explain the difference. Largest change: script, test, skill, manifest, README. Two places a value can come from. |

**Recommendation: (a) now.** It is the only candidate where hooks and hand
runs see the same configuration and nothing prints the URI, and it leaves the
script and its 35 cases untouched in a change that is already moving every
file. `userConfig` (c) is worth a plan of its own once the plugin is in use.

## Q4 — What happens to the `SessionEnd` push, given the 1.5-second budget?

**Problem.** The docs say: "SessionEnd hooks have a default timeout of 1.5
seconds. … The overall budget rises automatically to match the highest
per-hook `timeout` in your settings files, up to 60 seconds. … **Timeouts set
on plugin-provided hooks don't raise the budget.**" Today the `SessionEnd`
hook lives in `settings.json` with `"timeout": 20`, so it gets 20 s. Moved
into the plugin's `hooks.json`, the same line no longer raises anything, and
the final `push` gets 1.5 s unless the user sets
`CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`. A push cut at 1.5 s is killed by
the harness: it cannot log, it leaves `.memory-sync-pushed.next` behind, and
it does not write the cool-down marker. Edits made during the session have
normally already been sent by `push-if-changed` on `PostToolUse` and `Stop`.
Section 7.4. Not verified in a live session.

**Why it blocks.** It decides whether the plugin ships three hook events or
four (a "one fact, one value" item in `AGENTS.md:53`), what the README tells
the user to set, and whether the "exit 0, logs why" property still holds at
session end.

| | Candidate | Consequence |
|---|---|---|
| a | Keep `SessionEnd` in the plugin; README and the example `env` block add `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` (20000). | Same four events, same behaviour as today once the variable is set. Without it the final push is cut silently at 1.5 s. The variable raises the budget for *every* SessionEnd hook on the machine, and exit can take up to 20 s. Fits Q3(a): one more line in a block the user merges anyway. |
| b | Drop the `SessionEnd` hook; rely on `Stop` and `PostToolUse`. | Nothing to set, no silent cut. Loses the one push that ignores the 5-minute cool-down and the "another sync is running" skip (`memory-sync.sh:259`), so an edit made right after a failed push can stay local until the next session. Three events instead of four, in four files. |
| c | Keep the `SessionEnd` hook in the user's `settings.json`, pointing at the installed script. | Keeps the 20 s. But the installed path contains the version and changes on every update ("`${CLAUDE_PLUGIN_ROOT}` changes when the plugin updates"), so the entry breaks on the first update. Contradicts D3's "plugin only". |

**Recommendation: (a)**, with the smoke test checking what a session actually
does at exit with and without the variable. If the test shows the variable
does not help a plugin hook, fall back to (b).

## Q5 — Do the sync state files move to `${CLAUDE_PLUGIN_DATA}` now, or stay in the config directory?

**Problem.** The stage, the push stamp, the failure marker and the lock live
in `~/.claude/` (`memory-sync.sh:54-64`). The plugin convention is
`${CLAUDE_PLUGIN_DATA}` (`~/.claude/plugins/data/<id>/`). That variable exists
in hook processes but not in hand-run commands, and the directory is deleted
on uninstall. Section 7.5 has the state table.

**Why it blocks.** Moving them changes the script, the test, the skill's
status check (`SKILL.md:60`, `:69`) and the adoption steps; and if hook runs
and hand runs end up with different locks, a hook `push` and a hand `delete`
can run at the same time.

| | Candidate | Consequence |
|---|---|---|
| a | **Stay in the config directory.** | No script change. One lock for hooks, hand runs, and an old copy still wired during adoption — they serialise. Four dot-files remain in `~/.claude` that the plugin system does not know about; uninstalling leaves them behind (harmless: a cache, a timestamp, a marker, a lock). |
| b | **Move now**, falling back to the config directory when the variable is absent. | Tidy and uninstall-clean. First run re-downloads the stage and does one full push; the old four files are orphaned and must be removed by hand. Hook runs and hand runs use different locks unless the skill passes the substituted path on every hand run — a rule that is easy to break silently. New test cases. |
| c | **Move later**, as its own plan, after adoption. | Same end state as (b) without stacking a state migration on top of a relocation of every file. |

**Recommendation: (a) now, (c) if it is ever wanted.** The lock is the one
piece of state that must be shared by every caller, and (a) is the only
candidate where that holds by construction.

## Q6 — Versioning: a `version` in each manifest, or none?

**Problem.** Claude Code decides whether an installed plugin needs updating
from its computed version. "A manifest that pins `"version": "1.0.0"` keeps
every user on the cached copy until its author changes the string, however
many commits they push. To let users track commits instead, leave `version`
out." Without it, a relative-path plugin in a git-hosted marketplace is
versioned by commit SHA. `claude plugin validate` warns when `version` is
missing, and `--strict` fails on that warning (proven, section 3).

**Why it blocks.** It decides the manifest contents, whether the validate gate
can be `--strict`, and whether `AGENTS.md` gains a release rule.

| | Candidate | Consequence |
|---|---|---|
| a | **Explicit `version`**, starting `0.1.0`, bumped in the commit that changes a plugin; optional `claude plugin tag` (`{name}--v{version}`). | Releases are deliberate: a push does not change what teammates run until the number moves. `validate --strict` is clean, so the gate is one exact line. Cost: a forgotten bump means nobody receives the change, silently — so `AGENTS.md` needs a rule ("a change under `plugins/<name>/` bumps that plugin's `version` in the same commit"). |
| b | **No `version`.** | Every commit is a new version; nothing to remember. Any pushed commit reaches a user on their next update, including a half-finished one on `main`. The gate must accept "passed with warnings" and name the exact two warnings, and `--strict` cannot be used. |
| c | `version` in the marketplace entries only. | Same pinning as (a) with one file to edit; but if a manifest ever gains a version the manifest wins and validate warns. Splits the fact across two places. |

**Recommendation: (a).** These plugins set the operating model for every
session of everyone who installs them; a change should arrive when someone
decided to release it, not when someone pushed.

## Q7 — What happens to the root `CLAUDE.md`?

**Problem.** It is the global-instructions payload. A plugin cannot ship
global instructions, and a `CLAUDE.md` at a plugin root "is not loaded" and
draws a validate warning. Section 8 maps its rules: all but two are already in
the `SessionStart` hook text; the two missing ones (the `manager` Rule 0c
pointer and the `~/.claude/host.md` temp-file rule) would be added to the
hook. After that the file carries nothing unique. Left at the repo root it has
a side effect: it is loaded as *project* instructions by any session working
in this repo, where `AGENTS.md` says it is not the rule set.

**Why it blocks.** It decides one file's fate, four references to it
(`AGENTS.md:6`, `README.md:15`, `:34`, `:50`), and what the README tells a
user to do with the `~/.claude/CLAUDE.md` they already have.

| | Candidate | Consequence |
|---|---|---|
| a | **Delete it** (`git rm`) after the two missing rules are in the hook text; the "irreducible minimum" sentence becomes the hook script's header comment. | One mechanism, no duplicate text to keep in step, nothing in the repo that looks like a rule set but is not. The rules then arrive once per session instead of twice, and only when `glab` is enabled. History keeps the file. |
| b | **Keep it as an optional example** (`CLAUDE.example.md`, repo-only) for people who want the belt as well as the braces. | Preserves today's redundancy for those who copy it. Reintroduces a hand-copied file, against D3, and a second copy of the rules that must change with the hook ("one fact, one value"). |
| c | **Replace it with a short repo-local `CLAUDE.md`** that says "read `AGENTS.md`". | Helps tools that only read `CLAUDE.md`. But every agent and command here already falls back to `CLAUDE.md` only when `AGENTS.md` is missing, and it is not; it would be a file with no reader. |

**Recommendation: (a).**

---

## Not questions — verification steps the plan will carry

These are not the user's to decide; the docs leave them open and only a live
session settles them. They go into the user-run smoke test, marked UNVERIFIED
until run:

1. `/glab:plan` is listed; bare `/plan` is or is not (commands set no `name`).
2. The Skill tool loads `glab:manager`; whether bare `manager` also resolves.
3. The Agent tool dispatches `glab:developer`; whether bare `developer` also
   resolves.
4. The bootstrap hook text appears once at session start.
5. `${CLAUDE_PLUGIN_ROOT}` in the `sync-memory` skill body is replaced by a
   real path.
6. What happens to the `SessionEnd` push at exit, with and without
   `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` (Q4).

---

## Answers — recorded by the manager from the user, 2026-10-05

All seven questions are resolved. Each answer is the planner's recommended
candidate in the question above, chosen by the user.

| Q | Answer |
|---|---|
| Q1 | Marketplace name: **`glab-services`** (`glab@glab-services`, `memory-sync@glab-services`). |
| Q2 | Plugin **`memory-sync`**; its skill keeps the name `sync-memory` (`memory-sync:sync-memory`). |
| Q3 | **Keep the `env` block** of the user's own `settings.json` as the only source of `CLAUDE_MEMORY_S3_*` and `AWS_PROFILE`. No `userConfig`. Script inputs unchanged. |
| Q4 | **Keep the `SessionEnd` push hook in the plugin and document `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`** in the README. Whether the override helps a plugin hook is UNVERIFIED until the user's smoke test; dropping the hook is the fallback if it does not. |
| Q5 | State files **stay in the config directory**. No script change for state location. |
| Q6 | Explicit **`"version": "0.1.0"`** in both manifests, plus an `AGENTS.md` bump rule; `validate --strict` must be clean. |
| Q7 | **Delete the root `CLAUDE.md`** after its two missing rules (the `manager` Rule 0c pointer and the `host.md` temp-file rule) are added to the SessionStart hook text. |

Also recorded: `findings.md` was written by the manager from the planner's
returned text, verbatim, because the planner's own write was refused by the
harness. The docs agent's earlier claim that a `SessionEnd` per-hook timeout is
honoured is true for settings-file hooks only; for plugin hooks it is
contradicted (findings section 2, C12).
