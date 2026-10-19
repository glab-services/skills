# Marketplace — spec

The repository as a Claude Code plugin marketplace: `glab-services` and the
two plugins it lists, how they are versioned and installed, how a change to
this repo is tested without installing anything, the gates, the rules of
`AGENTS.md`, the per-machine host file, and the records of changes to these.
Owned by `.claude-plugin/marketplace.json`, both
`plugins/<name>/.claude-plugin/plugin.json`, `AGENTS.md`, `README.md` and
`host.example.md`. Stated as of `6838133`, its versions and its
`docs/specs/` and `plan/` bullet as of `09d2787`, and its
`feature-codex-agent` lines (the `glab` version, the gates' test count, the
external-agent rule, the *One fact* entries) as of `30f2c80`, and its
`feature-external-developer` lines (the version, the test count, the *One
fact* entries) as of `33a28df`, and its `fix-external-agent-claims` lines
(the version, the test count) as of `3965622`, and its `subagent-effort`
lines (the version, the test count, the *One fact* entries) as of
`abda43a`; where this file and an owning file disagree, the
owning file is right and this spec is out of date.

## How it works now

- **One marketplace, two plugins.** `.claude-plugin/marketplace.json` names
  the marketplace `glab-services` and lists `glab` (`source`
  `./plugins/glab`) and `memory-sync` (`source` `./plugins/memory-sync`).
  The two plugins do not reference each other and install alone
  (`README.md`). `glab` holds the workflow (`docs/specs/workflow.md`) and the
  external agents (`docs/specs/external-agents.md`); `memory-sync` holds the
  memory sync (`docs/specs/memory-sync.md`).
- **What each plugin holds** (`AGENTS.md` *Gates*, `README.md`): `glab` —
  seven skills and eight commands, which the CLI counts together as
  `Skills (15)`, five agents, one `SessionStart` hook; `memory-sync` — one
  skill, `sync-memory`, no agent, hooks on `SessionStart`, `SessionEnd`,
  `PostToolUse` and `Stop`.
- **Versions.** Each `plugin.json` carries an explicit `version` — `glab`
  `0.7.2` (raised by `abda43a`, `subagent-effort`; `0.7.1` by `3965622`,
  `0.7.0` by `33a28df`, `0.6.0` by `9108ac7`, `0.5.0` by `fed95f9` before
  it), `memory-sync` `0.1.0`, at `abda43a`. A change under
  `plugins/<name>/` raises that plugin's version in the same commit, because
  an installed copy is pinned to the version string and nothing else
  delivers a change (`AGENTS.md` *Rules*). `claude plugin validate --strict`
  is clean only with a version present.
- **Install is the user's step.** The README documents
  `claude plugin marketplace add glab-services/skills` and
  `claude plugin install <plugin>@glab-services`, for a private repository
  the machine's own git credentials can read. No agent installs, enables or
  configures a plugin, adds a marketplace, or copies anything into or out of
  `~/.claude` (`AGENTS.md` *Rules*).
- **Testing without installing.** `claude --plugin-dir ./plugins` loads both
  plugins for one session, `--plugin-dir ./plugins/glab` one; never the repo
  root, which loads no plugin (*Incidents*). Every `claude` command run in
  this repo has `CLAUDE_CONFIG_DIR` set to a new, empty directory under the
  host's temp directory, because the CLI writes into its config directory
  even for `plugin validate`.
- **The gates** are the two blocks of `AGENTS.md` *Gates*: the script block
  (`bash -n` joined to `test -x` for the five scripts, `shellcheck`, the two
  stub tests) and the plugin block (three `validate --strict`, the component
  counts of `plugin details`, the marketplace-to-manifest name check, the
  `user_config` search, the two pinned hedge phrases, the prefixed `name:`
  search). Each line's reason is written beside it there; this spec does not
  restate the blocks. Green at `abda43a`, as at `3965622`, ends the two stub tests with
  `PASS 35/35` and `PASS 86/86` (84 at `33a28df`, 71 at `9108ac7`, 49 before
  `feature-codex-agent`); the plugin counts are unchanged, `glab`
  `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`.
  `tests/external-agent.test.sh` runs its stub `opencode` inside the
  script's real sandbox, with a real network namespace, and its stub `codex`
  on the host, as the script runs Codex (`AGENTS.md` *Gates*); `AGENTS.md`
  *Tests* names both stubs as passed to the script with `--cli`. The Markdown files have no gate: a change to one is
  checked by running what it prescribes in a throwaway directory and by its
  plan's searches.
- **Names.** Payload text names a component by its prefixed name —
  `glab:manager`, `glab:developer`, `/glab:plan`; a frontmatter `name:` stays
  bare, because Claude Code adds the prefix and an agent whose name contains
  `:` does not load; a role named in running prose stays as it is
  (`AGENTS.md` *Rules*).
- **The host file.** `host.example.md` at the root is a template for
  `~/.claude/host.md`, which each person creates by hand for their machine:
  the temp directory, tool paths, the CLI's path for `CLAUDE_BIN`.
  `glab:bootstrap` step 1 reads it; `memory-sync` does not. Nothing in the
  plugins names one machine's facts.
- **The repo's own rules** are `AGENTS.md`: the gates, the scoped test
  exception for shell scripts (a stub on `PATH`, coverage as a list), no
  secrets (`<bucket>`, `<prefix>`, `<profile, or delete this key>`), never
  running `memory-sync.sh` against a real backend or `external-agent.sh`
  against a real model, the hook contract of `memory-sync.sh`, the *One fact,
  one value* list, comments and incidents kept, tests that clean up by PID,
  the version rule, Conventional Commits.
- **The external-agent rule** (`AGENTS.md` *Rules*, as of `30f2c80`):
  `external-agent.sh` runs against the stub in
  `tests/external-agent.test.sh`, or an offline run — no network, and a
  dummy key or login in a throwaway home — as `docs/specs/external-agents.md`
  *Offline run* records them (OpenCode's, and Codex's O1). The one exception
  is a live run with the user's own key or login, the live probe or a later
  one recorded the same way. It runs only when the user says so in chat for
  that run and names the backend and the models — for Codex, the backend
  alone names its default model — and, for an OpenCode run, after confirming
  that the console's "Use balance" is off; Codex has no such switch (the
  user's ChatGPT plan, 2026-10-18;
  `[feature-codex-agent/plan.md U7]`, carried in
  `docs/specs/external-agents.md`). The user runs it, or the manager session
  does at that instruction, as a script, never pasted; no dispatched agent
  runs it; its record goes under `plan/`, transcripts scanned for secrets and
  host values masked. Codex's first live run, L1, went that way
  (`docs/specs/external-agents.md` *Live runs*).
- ***One fact* entries `feature-codex-agent` added or rewrote** (`AGENTS.md`
  *Rules*; P9): the manual model rule keeps its file list, and two Codex
  clauses are entries of their own — "for Codex, no `--model` unless the
  user named one" (`glab:manager` Rule 5 and the skill's start example) and
  "`codex` alone in the record line for Codex's default" (Rule 5 and the
  skill's announce step); the record line and its `<backend>:<model>` token
  gains E50 and E55 beside E01; the allowlist entry becomes the OpenCode
  model allowlist and its end dates, "and that Codex has none and checks an
  id's form only, and refuses `default`" (the script, E58, the skill,
  `README.md`); "OpenCode's sandbox limits and its network helper"; the CLI's
  default path gains `~/.local/bin/codex`; "OpenCode's "Use balance"
  warning"; what OpenCode's copy holds and may send, "and what a Codex agent
  may read and send" — the repository with its history and its ignored
  files, and any file its commands open, outside the repository too; and
  five new entries: the guarantees each backend has (the script's header,
  the skill, `README.md`, `glab:manager` Rule 6), the Codex read-only check
  (the script, E54, the skill, `README.md`), the Codex effort rule
  (`glab:manager` Rules 5 and 6, the skill), the Codex data note
  (`README.md`, the skill), and the host first message (the script's
  `first_prompt`, E61).
- ***One fact* entries `feature-external-developer` added or rewrote**
  (`AGENTS.md` *Rules*, as of `33a28df`; P7): the manual model rule gains
  "(an external one: the reviewer on either backend, the developer on Codex
  only)"; "the Codex read-only check" becomes "the Codex sandbox check —
  `read-only`, or `workspace-write [workdir]` for a developer, with
  `approval: never` (the script, E54, E73, the skill, `README.md`)"; the
  host first message gains "the developer's first message — its host text,
  its tail and the default profile's *Developer, before the contract*
  section, which replaces *Before the contract* for a developer (the
  script's `first_prompt` and `developer_tail`,
  `plugins/glab/skills/external-agents/profiles/default.md`, E77)"; and
  three new entries: "the external developer — Codex only, `--role
  developer`, its sandbox keys" (the script's header and `codex_argv`, E72,
  E76, the skill, `glab:manager` Rules 5 and 6,
  `plugins/glab/commands/develop.md`, `README.md`); "the developer's change
  report — the `changed:` and `git:` lines" (the script's header, E74, E75,
  E78–E84, the skill, `plugins/glab/commands/develop.md`, `README.md`); and
  "a developer refused where the state root is inside the repository or the
  work tree holds another `.git`, 2 at start and 4 before a later turn"
  (the script's header, E79, E81, the skill, `README.md`, `glab:manager`
  Rule 5). The exit codes keep their numbers and names; 12's widened
  meaning changed where the exit-code entry's files describe it. The
  README's Codex requirements now also name, for a developer, a `find` that
  takes `-files0-from` (GNU findutils 4.9 or later, or bfs) and a
  `realpath` that takes `-e`.
- ***One fact* entries `subagent-effort` added or rewrote** (`AGENTS.md`
  *Rules*, as of `abda43a`; S9): "the Codex effort rule (`glab:manager`
  Rules 5 and 6, the skill)" became "the Codex effort rule — the session
  effort, sent as the highest level the model supports that is not above it
  (`glab:manager` Rules 0d, 5 and 6, the skill)"; and one new entry, "the
  session effort — the Agent tool's `effort` on every subagent dispatch, its
  order (the level the user named for the session, then
  `CLAUDE_CODE_EFFORT_LEVEL`, then ask once per session), its `- effort:`
  record line, the override for one agent, role or task, and
  `· effort <level>` in the handoff line" (`glab:manager` Rule 0d, Rules 5
  and 6, Stages 2 and 5 and *The pipeline* in
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/external-agents/SKILL.md`,
  `plugins/glab/commands/develop.md`, `plugins/glab/commands/review.md`,
  `plugins/glab/commands/ship.md`, `plugins/glab/skills/bootstrap/SKILL.md`,
  `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`). The workflow
  rule is in `docs/specs/workflow.md`, *The session effort*. The plugin
  counts did not change: `Skills (15)`, `Agents (5)`,
  `Hooks (1)  SessionStart`.
- **`docs/specs/` and `plan/`** (`AGENTS.md` *Layout* and *Rules*, the
  `plan/` rule; `README.md` *Working on this repo*), as of `09d2787`. `docs/specs/` holds
  one spec per area — this file (the marketplace, this repo's layout, gates
  and rules), `workflow.md`, `memory-sync.md`, `external-agents.md` — with
  how the area works now, the decisions that still bind, what is not
  verified, every follow-up open or closed, each tagged
  `[<slug>/<file> <id>]`, and its incidents. A spec states a fact as of its
  last record and names the file that owns it, so it is not one of the
  *One fact* files. `plan/` is the working area: a change's `plan/<slug>/`
  is committed with the change, and after its push the record
  (`glab:manager` Stage 8, `docs/specs/workflow.md`) updates the spec of
  each area it touched. `glab` never removes the folder; this repo's
  `AGENTS.md` does, by its own rule: once the change has landed on
  `origin/main`, the manager session — not a `glab` step — removes the
  folder by its exact path in a `docs(repo)` commit, after checking that it
  is tracked, clean (`git status --short -uall -- plan/<slug>/` prints
  nothing) and identical on `origin/main`
  (`git diff --quiet origin/main -- plan/<slug>/`), and the spec's *Records*
  line names the last commit on `origin/main` that holds it. It is read
  back without touching the tree: one file `git show <sha>:plan/<slug>/<file>`,
  the list `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole
  folder through `git archive` into a new directory under `$TMPDIR`. No
  untracked file under `plan/` is removed; `plan/SESSION-HANDOFF.md` is
  never committed. Until `feature-docs-specs` the rule was "`plan/` is
  tracked and permanent".

## Decisions that still bind

- [feature-plugin-marketplace/questions.md D1] Plugin-first: the plugins live in subdirectories of this repo; "layout mirrors `~/.claude`" is given up (the user's).
- [feature-plugin-marketplace/questions.md D2] Two plugins: `glab` (the workflow skills, the agents, the commands, the bootstrap hook — since joined by `glab:external-agents`) and `memory-sync` (the skill, the script, its hooks, its S3 configuration).
- [feature-plugin-marketplace/questions.md D3] Plugin install only: the copy install is dropped, the README documents only the plugin install, and text uses the prefixed names.
- [feature-plugin-marketplace/questions.md D4] Repo only: nothing is installed, enabled or changed in a machine's live Claude config by the work; testing is `--plugin-dir` and `plugin validate`.
- [feature-plugin-marketplace/questions.md S1] The manager's test rules (no hand-written mocks, a generator directive, coverage of 95 % or more) are universal and stay as written; this repo's shell scripts have a scoped exception in `AGENTS.md` *Tests*.
- [feature-plugin-marketplace/questions.md S2] In this repo a stub executable on `PATH` is the allowed way to fake a CLI for shell scripts.
- [feature-plugin-marketplace/questions.md S3] The review round cap is 3 (stated in the files `AGENTS.md` *One fact* lists).
- [feature-plugin-marketplace/questions.md S4] `~/.claude/host.md` stays a per-machine file each person creates by hand.
- [feature-plugin-marketplace/questions.md S5] No real bucket name, endpoint, profile or environment value anywhere.
- [feature-plugin-marketplace/questions.md Q1] The marketplace is `glab-services`: `glab@glab-services`, `memory-sync@glab-services`. Renaming it later makes every user remove and re-add it.
- [feature-plugin-marketplace/questions.md Q6] An explicit `version` in each manifest, raised by the commit that changes the plugin, with the `AGENTS.md` bump rule; `validate --strict` must be clean.
- [feature-plugin-marketplace/questions.md Q7] The root `CLAUDE.md` is deleted; its two rules missing from the hook (the Rule 0c pointer and the host-file temp rule) went into the `SessionStart` hook text, which is the only copy of the session rules a plugin can ship.
- [bug-reviewer-findings/questions.md Q1] Repo only: nothing is copied, symlinked or installed into `~/.claude` by the work, and there is no install script; the live copies were the user's to deal with, and the plugin install later replaced the copy install.
- [bug-reviewer-findings/questions.md Q4] Machine-specific text is split out: generic text in the repo, host facts in the unshipped `~/.claude/host.md` that `glab:bootstrap` reads, with `host.example.md` shipped as the template; the manager's test rules are universal.
- [bug-reviewer-findings/questions.md Q5] The repo has its own `AGENTS.md` (gates, commit format, rules) and `settings.example.json` holds placeholders only. Its first half, keeping the root `CLAUDE.md`, was superseded by `[feature-plugin-marketplace/questions.md Q7]`.
- [bug-reviewer-findings/questions.md Q8] One plan, four ordered slices, separate commits — spent: it scoped that change only.

## Known limits and not verified

- [feature-plugin-marketplace/plan.md unverified] Not shown in a live session, as of the record: prefixed names resolve (`/glab:plan`, the Skill tool with `glab:manager`, the Agent tool with `glab:developer`); the bootstrap hook fires from a plugin and its text reaches the model; `${CLAUDE_PLUGIN_ROOT}` is substituted in the `sync-memory` skill body, and the skill's fallback for when it is not; everything the README says about credentials, SSH then HTTPS, `CLAUDE_CODE_PLUGIN_PREFER_HTTPS`, background auto-update and the `extraKnownMarketplaces` / `enabledPlugins` keys (it restates the Claude Code docs); `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` for a plugin's `SessionEnd` hook; `claude plugin marketplace add glab-services/skills` on a teammate's machine; `claude plugin update glab@glab-services` delivering a raised version.
- [feature-plugin-marketplace/result-slice-G.md unverified] That the hook fires from the plugin in a live session and that the prefixed names resolve — needs a session; smoke test part 1.
- [feature-plugin-marketplace/plan.md smoke-test-1] Smoke test part 1, `glab` alone under `--plugin-dir ./plugins/glab` (the `/glab:` listing, `/plugin` errors, item 4 of the bootstrap text, loading `glab:security`, dispatching `glab:developer`, `/glab:plan`), and the bare-name questions in a clean config directory: not run, as recorded. Its steps: `git show b853635:plan/feature-plugin-marketplace/plan.md`, *Smoke test*. Parts 2 and 3 are in `docs/specs/memory-sync.md`.
- Validation does not compare a marketplace entry with the plugin it points at: it passes a wrong name and a directory that does not exist. The `jq` line of the plugin gates is what catches it (`AGENTS.md` *Gates*).

## Open follow-ups

- [bug-reviewer-findings/follow-ups.md 17] `AGENTS.md` *No secrets* names the placeholder as `<profile, or delete this key>`, which reads oddly outside the JSON example — open: `AGENTS.md` at `6838133` still reads so; a cleaner wording is the user's call.
- [bug-reviewer-findings/follow-ups.md 20] No `.gitignore`, and no Markdown lint, so the prose files have no gate — open: `git show 6838133:.gitignore` finds no such file; a Markdown gate is out of scope for `feature-docs-specs` too.
- [feature-docs-specs/follow-ups.md 1] `AGENTS.md:225`: the `git archive` read-back extracts into a directory it never prints. Suggested: `t=$(mktemp -d "${TMPDIR:?}/plan.XXXXXX") && git archive <sha> plan/<slug>/ | tar -x -C "$t" && echo "$t"` — open.
- [feature-docs-specs/follow-ups.md 3] `README.md:226`: the `plan/` row says "removed once each change is recorded", while `AGENTS.md` removes a folder only once it has landed on `origin/main`. Suggested: "removed after each change has landed, under this repo's `AGENTS.md`" — open; the conformance round 3/4 hand-off named the same line.
- [feature-docs-specs/follow-ups.md 6] `AGENTS.md:220-224`: the repo's removal rule should name the forms that are never valid — never `plan/`, `plan/.`, or a slug outside `[A-Za-z0-9._-]`; review round 2 measured that `plan/./` removes every folder under `plan/` (*Incidents*) — open.
- [feature-docs-specs/follow-ups.md 8] The *Records* lines of every spec, the transcript citations of `docs/specs/external-agents.md` *Profiles* and *Live runs* and its rev2-build line under *Incidents*, and the list form of `AGENTS.md`'s `plan/` rule: `git ls-tree -r --name-only <sha> -- plan/<slug>/` prints nothing, with exit 0, when run from a subdirectory. Suggested: add `--full-tree`, in the specs and `AGENTS.md` in the same commit — open.

## Closed follow-ups

- [bug-reviewer-findings/follow-ups.md 15] *One fact, one value* listed the default time limit but not the coupled maximum (17) and hook timeout (20) — closed: `AGENTS.md` *One fact* lists both, the 20-second hook timeout and "the largest time limit the script accepts, 17".
- [bug-reviewer-findings/follow-ups.md 21] `install.sh --check` to compare the repo with `~/.claude` (Q1's deferred half) — closed, superseded: no install script is tracked, and the plugin install replaced the copy install (`f19f7f0`, `README.md` *Coming from the copy install*).
- [feature-plugin-marketplace/result-review1.md 1] The plan recorded values that no longer held (P3, P9, P15, P17) — closed: the plan is a record of that change, not a check anyone re-runs.
- [feature-plugin-marketplace/result-review1.md 2] `follow-ups.md` did not exist and slice D's four items were open — closed as a pointer: each of the four is carried under its own tag, `[feature-plugin-marketplace/result-slice-D.md 3]` here and `1`, `2`, `4` in `docs/specs/memory-sync.md`.
- [feature-plugin-marketplace/result-review1.md 3] The `:?` guards stop a script, not an interactive shell — closed: `AGENTS.md` *Gates* says so beside the block.
- [feature-plugin-marketplace/result-slice-D.md 3] Stale step ranges in the plan ("P1–P13", "P1–P9, P12") — closed: plan text, history.
- [feature-plugin-marketplace/result-slice-S.md 1] A gate for the hedged sentences — closed: the `not yet confirmed` line of the plugin gates (`AGENTS.md` *Gates*).
- [feature-plugin-marketplace/result-slice-S.md 4] The plan's UNVERIFIED list described the old fallback wording of the skill — closed: plan text; its substance stands in `[feature-plugin-marketplace/plan.md unverified]`.
- [feature-plugin-marketplace/result-slice-S.md 5] `0.1.0` is the first version, so no bump was due — closed: information.

## Incidents

- **Host and tool hazards, pointed at, not copied:** the `/tmp` tmpfs under a per-user quota whose exhaustion (`EDQUOT`) killed a session from the inside, so temp files go where the host file says (`host.example.md`, *Temp files*); and the ugrep shell function that stands in for `grep` in Claude Code's Bash tool, observed returning nothing, with no error, for an `-E` pattern with a leading alternation, so this repo's commands use `command grep` (`glab:bootstrap` step 6).
- **`--plugin-dir .` loads no plugin.** Pointed at the marketplace root, the CLI printed `No plugins installed.`: it does not read `marketplace.json` from a `--plugin-dir`, and loads only subfolders with a manifest (feature-plugin-marketplace findings, *Experiment E*). The README says to pass `./plugins` or `./plugins/<name>`, never the root.
- **A `:` in an agent's `name:` stops it loading.** "Names can't contain `:` … Claude Code doesn't load a file whose name contains one" (the sub-agents docs, read for feature-plugin-marketplace). A prefixed `name:` passes `validate` and `plugin details`, so the last line of the plugin gates searches for one.
- **Validation passes a wrong marketplace name**, and a `source` directory that does not exist: it never compares the entry with the plugin's own `plugin.json`. The `jq` line of the plugin gates prints `<entry> = <manifest name>` for each.
- **A `${user_config.KEY}` in a hook command passes `validate`** (`✔ Validation passed`) and fails only when the hook runs (feature-plugin-marketplace findings, *Experiment B*); the `user_config` search of the plugin gates is the check.
- **The CLI writes into its config directory even for `plugin validate`** (proven in a throwaway directory, feature-plugin-marketplace findings §1), so a `claude` command without `CLAUDE_CONFIG_DIR` writes into the live `~/.claude`.
- **A wrapped phrase defeats a per-line gate.** The hedge gate first counted `0` in the script: the plan's comment wrapped `not yet confirmed` over two lines, and `grep -F` reads one line at a time (feature-plugin-marketplace `result-slice-D.md`, *Blocked*). The comment was re-wrapped so the phrase sits on one line.
- **`;` instead of `&&` hid a syntax error.** The first gate line printed `rc=0` for a script that failed `bash -n`, because the `rc` was `test -x`'s; it is now `bash -n "$s" && test -x "$s"` (`AGENTS.md` *Gates*).
- **A removal path that is not exact removes all of `plan/`** (`feature-docs-specs`, review rounds 1 and 2, measured in throwaway repos): with an empty slug, `git rm -r -n -- "plan/$slug/"` listed every file under `plan/`, `rc=0`, and so did `plan/../` and `plan/./`. The `plan/` rule removes a folder by its exact path, after checking it is tracked, clean and identical on `origin/main`; the forms that are never valid are not yet named (`[feature-docs-specs/follow-ups.md 6]`).

## Records

- 2026-10-05 · feature-plugin-marketplace · the repo becomes the marketplace `glab-services` with the plugins `glab` and `memory-sync`; the copy install and the root `CLAUDE.md` go · change 97d0d50 93deb5b 2e34cbe f19f7f0 · records b853635 · plan: `git ls-tree -r --name-only b853635 -- plan/feature-plugin-marketplace/` (one file: `git show b853635:plan/feature-plugin-marketplace/<file>`)
  - [feature-plugin-marketplace/findings.md L614] 10. Interaction between the two plugins, and risks → nothing open beyond `[feature-plugin-marketplace/plan.md unverified]` (the private-repo install); the double-run risk of the smoke test is written into the smoke test itself, and the adoption note became `README.md` *Coming from the copy install*.
  - [feature-plugin-marketplace/questions.md L202] Not questions — verification steps the plan will carry → items 1–4 `[feature-plugin-marketplace/plan.md smoke-test-1]`; 5 `[feature-plugin-marketplace/plan.md smoke-test-2]` and 6 `[feature-plugin-marketplace/plan.md smoke-test-3]`, in `docs/specs/memory-sync.md`.
  - [feature-plugin-marketplace/plan.md L1730] Smoke test — RUN BY THE USER, UNVERIFIED until then → `[feature-plugin-marketplace/plan.md smoke-test-1]` here; parts 2 and 3 in `docs/specs/memory-sync.md`.
  - [feature-plugin-marketplace/plan.md L1895] UNVERIFIED — what this plan rests on without proof → `[feature-plugin-marketplace/plan.md unverified]`.
  - [feature-plugin-marketplace/result-review1.md L179] Follow-ups → `[feature-plugin-marketplace/result-review1.md 1]`, `2`, `3`, all closed.
  - [feature-plugin-marketplace/result-slice-D.md L201] Follow-ups → `[feature-plugin-marketplace/result-slice-D.md 3]` here; `1`, `2`, `4` in `docs/specs/memory-sync.md`.
  - [feature-plugin-marketplace/result-slice-D.md L213] Not done → `[feature-plugin-marketplace/plan.md unverified]` (the README's credential and update statements); nothing else open.
  - [feature-plugin-marketplace/result-slice-G.md L159] Follow-ups → `[feature-plugin-marketplace/result-slice-G.md unverified]`; the note that some checks could run only after slice S is closed (S landed in `2e34cbe`).
  - [feature-plugin-marketplace/result-slice-G.md L167] Not done → nothing open: the slices it names were other developers', and all landed.
  - [feature-plugin-marketplace/result-slice-M.md L227] Follow-ups → nothing open ("None written").
  - [feature-plugin-marketplace/result-slice-M.md L232] Not done → the smoke test: `[feature-plugin-marketplace/plan.md smoke-test-1]`, and `smoke-test-2`, `smoke-test-3` in `docs/specs/memory-sync.md`.
  - [feature-plugin-marketplace/result-slice-S.md L199] Follow-ups → `[feature-plugin-marketplace/result-slice-S.md 1]`, `4`, `5` here; `2`, `3` in `docs/specs/memory-sync.md`.
  - [feature-plugin-marketplace/result-slice-S.md L212] Not done → `[feature-plugin-marketplace/plan.md smoke-test-2]` and `smoke-test-3` (substitution, hooks firing, the `SessionEnd` cut-off), in `docs/specs/memory-sync.md`.
- 2026-10-05 · bug-reviewer-findings · recorded in `docs/specs/memory-sync.md`, its primary area; its marketplace items (follow-ups 15, 17, 20, 21; questions Q1, Q4, Q5, Q8) are tagged above · plan: `git ls-tree -r --name-only 2aeb46d -- plan/bug-reviewer-findings/` (one file: `git show 2aeb46d:plan/bug-reviewer-findings/<file>`)
- 2026-10-18 · feature-docs-specs · recorded in `docs/specs/workflow.md`, its primary area; it added `docs/specs/` and rewrote the `plan/` rule (*How it works now*), and its repo items (follow-ups 1, 3, 6, 8) are tagged above · plan: `git ls-tree -r --name-only 09d2787 -- plan/feature-docs-specs/` (one file: `git show 09d2787:plan/feature-docs-specs/<file>`)
- 2026-10-18 · feature-codex-agent · recorded in `docs/specs/external-agents.md`, its primary area; here: `glab` 0.6.0, the gates' `PASS 71/71` and `AGENTS.md`'s changed *Gates* sentence and *Tests* bullet, the external-agent rule's offline and live-run wording (Codex, no "Use balance" switch), the added and rewritten *One fact* entries · change 9108ac7 · records 30f2c80 · plan: `git ls-tree -r --name-only 30f2c80 -- plan/feature-codex-agent/` (one file: `git show 30f2c80:plan/feature-codex-agent/<file>`)
- 2026-10-18 · feature-external-developer · recorded in `docs/specs/external-agents.md`, its primary area; here: `glab` 0.7.0, the gates' `PASS 84/84`, the added and rewritten *One fact* entries · change 33a28df · plan: `git ls-tree -r --name-only 33a28df -- plan/feature-external-developer/` (one file: `git show 33a28df:plan/feature-external-developer/<file>`)
- 2026-10-19 · fix-external-agent-claims · recorded in `docs/specs/external-agents.md`, its primary area; here: `glab` 0.7.1 and the gates' `PASS 86/86`; no *One fact* entry changed (F3 and F9 leave that to the user) · change 3965622 · plan: `git ls-tree -r --name-only abda43a -- plan/fix-external-agent-claims/` (one file: `git show abda43a:plan/fix-external-agent-claims/<file>`). `abda43a` is the last commit on `origin/main` that holds it; the folder is the same there as at `3965622`
- 2026-10-19 · subagent-effort · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.7.2, the gates still `PASS 35/35` and `PASS 86/86`, the rewritten Codex effort entry and the new session-effort entry of *One fact* · change abda43a · plan: `git ls-tree -r --name-only abda43a -- plan/subagent-effort/` (one file: `git show abda43a:plan/subagent-effort/<file>`). `abda43a` is the last commit on `origin/main` that holds it: one `docs(repo)` commit after this record removes it and `plan/fix-external-agent-claims/`
  - [subagent-effort/plan.md L265] Record → order: the plan (`plan.md` L267) expected this record after the `fix-external-agent-claims` record had been committed; both records instead land in one `docs(repo)` commit, and the folder removal follows in another.
