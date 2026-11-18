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
`abda43a`, and its `remove-external-agents` lines (the version, the
component counts, the gates, the rules, the *One fact* entries) as of
`467b7c4`, and its `flow-cheaper-rounds` lines (the version, the hook
events and component counts, the gates, the hook-contract rule, the *One
fact* entries, the marketplace description, *Testing without installing*)
as of `2a1e919`, and its `flow-planner` lines (the version, the gates' test
count, the *One fact* entries) as of `2912002`, and its `flow-master-plan`
lines (the version, the version rule per push, the *One fact* entries, the
`README.md` paragraphs) as of `0cbf5b0`, and its `flow-models-per-role`
lines (the version, the agent count, the model gate, the *One fact*
entries, the `README.md` table and paragraph) as of `517b7b6`, and its
`flow-commands-to-skills` lines (the version, the layout, the component
counts, the skills gate, the green list's hook suffix, the *One fact*
preamble and entries, the commit-scope list, the `README.md` row and
paragraph, the marketplace description) as of `6f8b948`, and its
`flow-product-level` lines (the version, the layout, the component counts,
the script gates and the three new tests, the model and skills gates' lines,
the hook contracts of `manager-bootstrap.sh` and `plan-gate.sh`, the host
file's store line, the *One fact* entries, the `README.md` sections, the
`glab` description in its `plugin.json`) as of `ce1a933`, and its
`flow-gate-hardening` lines (the version, the `plan-gate.sh` contract, the
stubs and count of `tests/plan-gate.test.sh`) as of `2724086`, and its
`slim-agents-md` lines (the gates as `tests/gates.sh`, the *One fact*
registry as `docs/one-fact.md`, the size of `AGENTS.md`) as of `113870b`, and its
`docs-lifecycle` lines (the version, the `.gitignore`, `docs/features/` in
the layout, the `plan/` rule, the *One fact* entries, `README.md`'s record
paragraph and layout row, the size of `AGENTS.md`) as of `3ed6746` (`glab`
`0.16.0`, rebase-merged as `d2ca05b`), and its `lifecycle-hardening` lines
(the version, `AGENTS.md`'s `plan/` rule and size, the *One fact* entry
*Where the record is committed*, `README.md`'s record paragraph and
`plan/` row) as of `bf9c73f` (`glab` `0.16.2`, PR #22, not merged at this
record), and its `script-hardening` lines (the version, `tests/gates.sh`'s
bash line and `PATH` rewrite, the store pointers in `README.md` and
`host.example.md`) as of `64b4e57` (`glab` `0.16.3`, PR #23, not merged at
this record); where this file and an owning file disagree, the
owning file is right and this spec is out of date.

## How it works now

- **One marketplace, two plugins.** `.claude-plugin/marketplace.json` names
  the marketplace `glab-services` and lists `glab` (`source`
  `./plugins/glab`) and `memory-sync` (`source` `./plugins/memory-sync`).
  The two plugins do not reference each other and install alone
  (`README.md`). `glab` holds the workflow (`docs/specs/workflow.md`);
  `memory-sync` holds the memory sync (`docs/specs/memory-sync.md`). Until
  `glab` 0.8.0 (`467b7c4`, 2026-10-20) `glab` also held the external agents,
  which `docs/specs/external-agents.md` keeps as a record.
- **What each plugin holds** (`tests/gates.sh` as of `113870b`, `AGENTS.md`
  *Gates* until then, `README.md`): `glab` —
  since `glab` 0.15.0 (`db5feae`, `flow-project-level`)
  `Skills (25)  audit, bootstrap, comments, commit, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-verdict, project-analyze, project-develop, project-integrate, project-manager, project-plan, project-plan-accept, project-plan-analyze, project-plan-report, project-record, project-review, project-ship, push, security, session-rules, severity`
  and `Agents (9)` naming `committer`, `product-analyzer`,
  `product-planner`, `project-analyzer`, `project-developer`,
  `project-integrator`, `project-plan-analyzer`, `project-planner` and
  `project-reviewer`, in any order. Every project-level skill and agent
  carries the `project-` prefix (`0c49626`, its sub-plan 01; old → new,
  `plan/flow-project-level/evidence.md` E5, and the migration note in
  `README.md`): the skills `glab:manager`, `glab:plan`, `glab:develop`,
  `glab:analyze`, `glab:integrate`, `glab:review` and `glab:ship` →
  `glab:project-<the same>`, `glab:product-project-plan-report` →
  `glab:project-plan-report`, the agents `planner`, `plan-analyzer`,
  `analyzer`, `developer`, `integrator` and `reviewer` → `project-<the
  same>` (`skills/<name>/` and `agents/<name>.md` the same). New:
  `glab:severity` (`0cfe335`, sub-plan 02) and `glab:project-plan-accept`,
  `glab:project-plan-analyze` and `glab:project-record` (`db5feae`, sub-plan
  03, the stage skills split out of the manager); the hook events and the
  three scripts unchanged in number. From `glab` 0.14.0 (`ce1a933`,
  `flow-product-level`) until `0c49626`: two levels, the
  user's "one plugin for all" (`docs/specs/product.md`, *Two levels in one
  plugin*):
  `Skills (21)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-report, product-project-plan-verdict, push, review, security, session-rules, ship`
  — the thirteen below, the seven `product-*` skills and
  `glab:session-rules` — and `Agents (9)`, the seven below with
  `product-planner` and `product-analyzer`; the hook events unchanged; and
  a third script, `plugins/glab/scripts/plan-gate.sh`, which no hook runs
  (`glab:develop` and the product skills run it by
  `${CLAUDE_PLUGIN_ROOT}`). Until then:
  thirteen skills and no commands since `glab` 0.13.0 (`6f8b948`),
  `Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship`:
  the seven stage skills that were commands, `glab:plan` (the merged
  `glab:plan-first` and `/glab:plan`), and `audit`, `bootstrap`,
  `comments`, `manager`, `security` (`docs/specs/workflow.md`, *The
  commands are gone*; until then six skills and eight commands, which the
  CLI counted together as `Skills (14)`, with `plan-first`); seven agents — `analyzer`, `committer`, `developer`,
  `integrator`, `plan-analyzer`, `planner`, `reviewer`, each with its
  frontmatter `model` and, since `6f8b948`, its frontmatter `skills:` list
  (`Agents (7)` since `glab` 0.12.0, `09d5664`; five,
  with no `planner` and no `plan-analyzer`, until then;
  `docs/specs/workflow.md` *Agents*) — four hook events — `SessionStart`,
  `UserPromptSubmit`, `PostToolUse` (matcher `Agent`) and `Stop`, the last
  three running `plugins/glab/scripts/context-size.sh` (`Hooks (4)`, since
  `2a1e919`; one `SessionStart` hook until then; seven skills and
  `Skills (15)`, with `glab:external-agents`, until `467b7c4`); `memory-sync` — one
  skill, `sync-memory`, no agent, hooks on `SessionStart`, `SessionEnd`,
  `PostToolUse` and `Stop`.
- **Versions.** Each `plugin.json` carries an explicit `version` — `glab`
  `0.16.3` (raised once by `64b4e57`, `script-hardening`'s one change
  commit, `fix(skills): remove a claim the run failed to write, and harden the gates (glab 0.16.3)`,
  in PR #23, not merged at this record; a patch step, `plan-gate.sh`'s
  failed-write path and the gates' preflight; `[script-hardening/plan.md D5]`;
  `memory-sync` unchanged at `0.1.0`); `0.16.2` (raised once by `bf9c73f`, `lifecycle-hardening`'s one commit,
  `fix(skills): ask before removing a plan folder, and harden the record lifecycle (glab 0.16.2)`,
  in PR #22, not merged at this record; `[lifecycle-hardening/plan.md D5]`;
  `memory-sync` unchanged at `0.1.0`); `0.16.1` (raised once by `afda097`,
  `p7-delivery-gate`, rebase-merged through PR #21 as `ecbff30`, the same
  tree; recorded in `docs/specs/product.md` only); `0.16.0` (raised once by `3ed6746`, `docs-lifecycle`'s one commit,
  `feat(skills): stop committing plan folders and record into docs/features (glab 0.16.0)`,
  merged with rebase through PR #19 as `d2ca05b`; `memory-sync` unchanged
  at `0.1.0`, no file under it changed, `[docs-lifecycle/plan.md M4]`);
  `0.15.0` (raised once by `0c49626`, the first of `flow-project-level`'s
  three commits, `0cfe335` and `db5feae` keeping it; merged with rebase
  through PR glab-services/skills#15 from `cf909b5`; 01's subject a
  `refactor`, 02's and 03's a `feat`, each ending `(glab 0.15.0)`,
  `[flow-project-level/master.md]` *Final check* step 7); `0.14.1` (raised once by `2724086`, `flow-gate-hardening`, the change's
  one commit — `bdee40a` on its branch, the same tree, merged with rebase
  through PR #13; its review fix round kept it; a patch step, the four
  `plan-gate.sh` follow-ups closed; exit codes, stdout and the store layout kept, the contract gaining the takeover clause,
  `fix(skills): harden plan-gate claims, takeover and publish (glab 0.14.1)`,
  `[flow-gate-hardening/plan.md version]`); `0.14.0` (raised once by `ce1a933`, `flow-product-level`, the change's
  one commit — `e4b8157` on its branch, the same tree, merged with rebase
  through PR #11; its two review fix rounds kept it; a minor step, nothing
  removed, so no `!`, `feat(skills): add the product manager level and wire it to the project level (glab 0.14.0)`,
  `[flow-product-level/plan.md version]`; the same commit rewrote the `description` of
  `plugins/glab/.claude-plugin/plugin.json` to name the product level and
  the project level, while `.claude-plugin/marketplace.json` is unchanged;
  `README.md` points at `plugin.json` for the version instead of writing it,
  review round 1 advisory 2); `0.13.0` by `6f8b948`, `flow-commands-to-skills`, the
  change's one commit; its review fix round kept it, the rule being per
  push, `[flow-commands-to-skills/review-1.md]`; a minor step, as the plan
  decided — "`glab` goes 0.12.0 → 0.13.0, once, in this change's one
  commit" — though the commands and `glab:plan-first` were removed, and the
  commit carries no `!`, `feat(skills): move the commands into skills and
  say each rule once (glab 0.13.0)`; `0.12.0` by `09d5664`, `flow-models-per-role`: a minor step, new
  agents and a changed default, nothing removed, so no `!`,
  `[flow-models-per-role/plan.md D17]`; `517b7b6`, its PR #7 review fix,
  changed `plugins/glab/commands/analyze.md` and raised nothing, since both
  commits reached `origin/main` together through PR #7 and the rule is per
  push; `0.11.0` by `0cbf5b0`, `flow-master-plan`: a minor step, nothing
  removed, so no `!`, `[flow-master-plan/plan.md D44]`; `0.10.0` by
  `2912002`, `flow-planner`, as a minor step, `[flow-planner/plan.md D18]`;
  `0.9.0` by `2a1e919`,
  `flow-cheaper-rounds`: a minor step, since
  the change alters the pipeline's contract and adds a feature, and
  features have raised the minor before 1.0; nothing removed, so no `!`;
  `0.8.0` by `467b7c4`, `remove-external-agents`; `0.7.2` by
  `abda43a`, `0.7.1` by `3965622`,
  `0.7.0` by `33a28df`, `0.6.0` by `9108ac7`, `0.5.0` by `fed95f9` before
  it), `memory-sync` `0.1.0`, at `2724086`. A change under
  `plugins/<name>/` raises that plugin's version in the same commit, because
  an installed copy is pinned to the version string and nothing else
  delivers a change (`AGENTS.md` *Rules*). Since `0cbf5b0` the rule reads
  per push: "When one push carries several commits of one change — one per
  sub-plan — the first that changes `plugins/<name>/` raises it, once."
  The reason given is what an installer receives, which is a push, not a
  commit (`[flow-master-plan/plan.md D30]`,
  `[flow-master-plan/evidence.md F15]`, inferred there). `claude plugin validate --strict`
  is clean only with a version present.
- **Install is the user's step.** The README documents
  `claude plugin marketplace add glab-services/skills` and
  `claude plugin install <plugin>@glab-services`, for a private repository
  the machine's own git credentials can read. No agent installs, enables or
  configures a plugin, adds a marketplace, or copies anything into or out of
  `~/.claude` (`AGENTS.md` *Rules*).
- **Testing without installing.** `claude --plugin-dir ./plugins` loads both
  plugins for one session, `--plugin-dir ./plugins/glab` one; never the repo
  root, which loads no plugin (*Incidents*). Under an empty
  `CLAUDE_CONFIG_DIR`, `--plugin-dir ./plugins/glab` loads `glab` alone
  (`Hooks (1)  SessionStart` on the tree before `2a1e919`, and
  `plugin details memory-sync` prints `Plugin "memory-sync" not found`); in
  the user's **own** config the plugins they installed appear to load
  beside it, as integration I1a showed when a second `Stop` hook ran and
  ended `cancelled`, exit 1 — which plugin's it was is UNVERIFIED
  (`[flow-cheaper-rounds/plan.md D64]`, `[flow-cheaper-rounds/plan.md FU18]`
  in `docs/specs/workflow.md`; *Incidents*). Every `claude` command run in
  this repo has `CLAUDE_CONFIG_DIR` set to a new, empty directory under the
  host's temp directory, because the CLI writes into its config directory
  even for `plugin validate`.
- **The gates** are, as of `113870b` (`slim-agents-md`), one script,
  `tests/gates.sh`; `AGENTS.md` *Gates* says to export `TMPDIR`, run
  `bash tests/gates.sh` and paste what it prints. It runs 31 checks
  (`[slim-agents-md/plan.md D1]`): G1–G10 `bash -n` and `test -x` on ten
  scripts (the nine below and itself), G11 `shellcheck` on the ten, G12–G16
  the five tests, G17–G19 `plugin validate --strict` (`glab`,
  `memory-sync`, `.`), G20–G25 the Skills, Agents and Hooks lines of each
  plugin, G26 the marketplace names, G27 `user_config`, G28
  `not yet confirmed`, G29 the model lines, G30 the skills lines, G31 the
  prefixed `name:` search. It prints `ok G<n> <name>` or
  `FAIL G<n> <name>: <reason>` per check, then `PASS 31/31` or
  `FAIL <f>/31`, and exits 0 when all pass, 1 on any `FAIL`, 2 when a
  preflight fails. The preflight runs first (`D3`, `tests/gates.sh:27-34`
  at `113870b`; `:35-62` since 0.16.3, below):
  no `TMPDIR`, a `TMPDIR` that is not an absolute path (fix round 1,
  `[slim-agents-md/review.r1.md 4]`), no CLI (`claude` on `PATH` or
  `CLAUDE_BIN`, made absolute before the `cd`), no `jq` or no `shellcheck`
  each print one stderr line and exit 2, with no `ok`, `FAIL` or `PASS`
  line; it does not use `:?`, which exits 1. **Since `glab` 0.16.3**
  (`64b4e57`, `script-hardening`; the comments of `tests/gates.sh:12-15`
  and `:25-44` the owners): the first preflight line refuses a bash older
  than 4.4 — exit 2, `gates.sh: bash 4.4 or newer is required, this is
  bash <BASH_VERSION>` (`[script-hardening/plan.md D4]`) — because before
  4.4 an empty array under `set -u` is an error, which the
  `${MS_AGENTS[@]+…}` guard at G24 still avoids, its comment updated; only
  the bash running `gates.sh` is checked, while the tests it runs use the
  `bash` on `PATH` (`[script-hardening/plan.md FU-SH2]`). Shown by copies
  with `BASH_VERSINFO` replaced, run with `env -u TMPDIR` (`D12`): 3 2 and
  4 3 give that line, rc 2; 4 4 and 5 0 pass it and stop at the `TMPDIR`
  line, rc 2, before any check (`plan.md` PC5). Then, after the `TMPDIR`
  lines and before `command -v`, `PATH` is rewritten (`D3`, `D10`): a loop
  over `"$PATH:"` keeps each entry that starts `/` or `~` (bash expands
  `~` against `$HOME` when it searches `PATH`), makes an empty entry —
  leading, middle or trailing — `$PWD`, and any other `$PWD/<entry>`, so
  `jq`, `shellcheck` and the tests use, after the `cd`, the tool the
  preflight found (`[slim-agents-md/follow-ups.md FU1]`, closed). An
  all-absolute `PATH` is unchanged and `command -v claude` finds the same
  CLI; shown with logging wrappers in a relative `relbin/` and
  `PATH="~/.local/bin:relbin:.:$PATH:"` (`D13`; `plan.md` PC4, PC4b):
  `PASS 31/31`, both wrappers ran. The 31 checks and exit codes are
  otherwise unchanged; green `PASS 31/31`, exit 0, G14 `PASS 56/56`. Every `claude` command runs in
  one subshell with `CLAUDE_CONFIG_DIR` a new directory inside the work
  directory `mktemp -d "$TMPDIR/gates.XXXXXX"`, which an EXIT trap removes;
  INT, TERM and HUP exit 130, 143 and 129 through it (`D4`,
  `[slim-agents-md/review.r1.md 1]`); it starts no background process.
  Skills and Agents are compared as sets — the count and the sorted names
  (`D5`) —, Hooks lines as exact strings, the model and skills lines after
  `LC_ALL=C sort`; the five tests' own counts are not pinned (`D6`): rc 0,
  every line but the last `ok `, a last line `PASS k/k`. The expected
  values are the arrays at its top and each reason a `#` comment above its
  check (`D7`, `D8`; `AGENTS.md` *Gates*: "the values in its arrays, the
  reasons in its comments"); it checks itself through G10 and G11 and never
  runs itself (`D2`). Green at `113870b` (`[slim-agents-md/result.md]`
  *Fix round 1*): G1–G31 `ok`, `PASS 31/31`, `rc=0`, no `gates.*`
  directory left under `$TMPDIR`. Until `113870b` the gates were the
  script block and the plugin block of `AGENTS.md` *Gates*, which G1–G31
  carry over; what follows records those blocks. **Since `glab`
  0.14.0** (`ce1a933`; `[flow-product-level/plan.md]` R3, X1) the script
  block takes nine files — `plugins/glab/scripts/plan-gate.sh`,
  `tests/plan-gate.test.sh`, `tests/manager-bootstrap.test.sh` and
  `tests/product-loop.test.sh` beside the five below — through `bash -n`
  joined to `test -x` and through `shellcheck`, and "run all seven, in
  order" adds three test lines:
  `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh`,
  `bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh`,
  `bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh`;
  green is nine `rc=0` lines, `rc=0` with no findings, and each test's
  every line `ok` and last line `PASS n/n`. One test per contract
  (`docs/specs/product.md`, *The walkthrough and the three tests*); each
  follows `AGENTS.md` *Tests* — a stub first on `PATH` (`mkdir`, `date`,
  `rm` and `mktemp` stubs in `tests/plan-gate.test.sh`, which delay a run
  or signal it, and since `2724086` `ln` and `head` stubs, which delay,
  signal or fail a run's `ln` or hold its read of a claim), a `PATH` without `jq` (`tests/manager-bootstrap.test.sh`
  B5) or without `sha256sum` (T21), background runs killed only by their
  recorded PIDs (T33, T37, and since `2724086` T45, T47, T48) and signals
  sent only to the PID a launcher recorded (T38–T43, T49, T50; T46, T47 and
  T51 use the same launcher); coverage as a list, in `plan.md` *Tests* and
  `result.md`. The walkthrough's fixtures are under
  `tests/fixtures/product-loop/`, named in *Layout*. In the plugin block
  the `glab` lines are green, since `glab` 0.15.0, as `AGENTS.md` *Gates*
  listed them until `113870b` and the arrays of `tests/gates.sh` hold them
  since: `Skills (25)` and `Agents (9)` naming them (*What each plugin
  holds*), the model gate as nine lines —
  `project-analyzer.md:model: sonnet`, `committer.md:model: haiku`,
  `project-developer.md:model: sonnet`, `project-integrator.md:model: sonnet`,
  `project-plan-analyzer.md:model: opus`, `project-planner.md:model: opus`,
  `product-analyzer.md:model: opus`, `product-planner.md:model: opus`,
  `project-reviewer.md:model: sonnet` — and the skills gate as eighteen —
  `project-analyzer.md:glab:security`, `project-analyzer.md:glab:severity`,
  `committer.md:glab:security`, `project-developer.md:glab:security`,
  `project-developer.md:glab:comments`, `project-integrator.md:glab:security`,
  `project-integrator.md:glab:comments`,
  `project-plan-analyzer.md:glab:security`,
  `project-plan-analyzer.md:glab:severity`,
  `project-planner.md:glab:project-plan`, `project-planner.md:glab:security`,
  `product-analyzer.md:glab:security`, `product-analyzer.md:glab:severity`,
  `product-planner.md:glab:product-plan`, `product-planner.md:glab:security`,
  `project-reviewer.md:glab:security`, `project-reviewer.md:glab:comments`,
  `project-reviewer.md:glab:severity` — each with its `plugins/glab/agents/`
  prefix. **Green at `db5feae`, both blocks run for this record**
  (2026-11-18, `TMPDIR` set, `CLAUDE_CONFIG_DIR` a new empty directory):
  nine `rc=0` lines, `shellcheck` `rc=0`, `PASS 35/35` (memory-sync),
  `PASS 24/24` (context-size), `PASS 51/51` (plan-gate), `PASS 19/19`
  (manager-bootstrap; 13 at `2724086`),
  `PASS 17/17` (product-loop), no line but `ok` before each; three
  `✔ Validation passed`, the `Skills (25)` line above,
  `Agents (9)  project-planner, product-planner, project-developer, project-integrator, product-analyzer, committer, project-analyzer, project-reviewer, project-plan-analyzer`
  (the build's order), both `Hooks (4)` lines with the `harness-only`
  suffix, `glab = glab` and `memory-sync = memory-sync`, `:0` `:0` then
  `rc=1`, `1` `1` `1` then `rc=0`, the nine model lines then `rc=0`, the
  eighteen skills lines with no `MISSING`, and no line then `rc=1`. **The
  old-name search** (`[flow-project-level/master.md]` *Final check* step 2,
  run for this record): the first search, over `plugins README.md
  AGENTS.md tests host.example.md .claude-plugin`, prints only `rc=1`; the
  second, the old names in the `glab` *Gates* line of `AGENTS.md`, prints
  `0` (`1` before `0c49626`). The `docs/specs/` files are outside it: they
  are records, and their dated lines keep the old names. Until `0c49626`
  the `glab` lines were green as `Skills (21)` and `Agents (9)` naming them
  (*What each plugin holds*), the model gate as nine lines — with
  `product-analyzer.md:model: opus` and `product-planner.md:model: opus` —
  and the skills gate as eighteen, with `product-analyzer.md:glab:security`,
  `product-analyzer.md:glab:audit`, `product-planner.md:glab:product-plan`
  and `product-planner.md:glab:security`, each with its
  `plugins/glab/agents/` prefix. **Green at `2724086`** (`glab` 0.14.1,
  `flow-gate-hardening`; neither block run for its record, a docs edit
  whose dispatch allowed no `claude` command): the developer's run after
  review round 1's fixes on the tree that became `2724086`
  (`[flow-gate-hardening/result.md]` *Review round 1 fixes*, *Gates*; the
  sha256 of `plan-gate.sh` and its test at `2724086` are those of
  `[flow-gate-hardening/plan.md review-fixes]`) — the script block nine
  `rc=0` lines, `shellcheck` `rc=0`, `PASS 35/35`, `PASS 24/24`,
  `PASS 51/51`, `PASS 13/13`, `PASS 17/17`, no line but `ok` before each,
  and the plugin block with the lines below — and the manager's ten runs of
  `tests/plan-gate.test.sh`, each `PASS 51/51`, on the build before the
  review fixes (`[flow-gate-hardening/plan.md a6-a7-run]`), and three in a
  row after them on the shipped files; that these hold on `2724086` is
  inferred from its identical tree, not run. **At `ce1a933`, the script
  block run for that record** (`TMPDIR` set, the seven commands as
  `AGENTS.md` prints them): nine `rc=0` lines, `shellcheck` `rc=0`,
  `PASS 35/35`, `PASS 24/24`, `PASS 42/42`, `PASS 13/13`, `PASS 17/17`, no
  line but `ok` before each. **The plugin block was not run for that
  record**: its dispatch allowed no `claude` command. Its green is the
  manager's run after review round 2 on the branch's tree before the commit
  (`[flow-product-level/result.md]` *Fix round — review round 2*,
  *Gates*): three `✔ Validation passed`, the `Skills (21)` line above,
  `Agents (9)  reviewer, product-planner, integrator, developer, analyzer, product-analyzer, committer, planner, plan-analyzer`
  (the build's order), both `Hooks (4)` lines with the `harness-only`
  suffix, `glab = glab` and `memory-sync = memory-sync`, `:0` `:0` then
  `rc=1`, `1` `1` `1` then `rc=0`, the nine model lines then `rc=0`, the
  eighteen skills lines with no `MISSING`, and no line then `rc=1`; that it
  holds on `ce1a933` is inferred from the same tree, not run. Until
  `ce1a933`, as of
  `2a1e919`: the script block (`bash -n` joined to `test -x` for the five
  scripts — `memory-sync.sh`, `manager-bootstrap.sh`, `context-size.sh`,
  `tests/memory-sync.test.sh`, `tests/context-size.test.sh` — `shellcheck`
  over the same five, and the two tests: the `memory-sync` stub test and
  `tests/context-size.test.sh`, which writes fixture transcripts under
  `$TMPDIR` and fakes a missing `jq` with a `PATH` that lacks it; the
  `AGENTS.md` says "run all four, in order" for the four commands, and green is
  five `rc=0` lines, `rc=0` with no findings, and for each test every line
  `ok` and a last line `PASS n/n`) and the plugin block (three `validate --strict`, the component
  counts of `plugin details`, the marketplace-to-manifest name check, the
  `user_config` search, the one pinned hedge phrase, `not yet confirmed`,
  since `09d5664` the **model gate**, since `6f8b948` the **skills gate**,
  and the prefixed `name:` search). Each line's reason is written beside it
  there; this spec does not restate the blocks. **The model gate**
  (`[flow-models-per-role/plan.md D15]`), before the prefixed-`name:`
  search: `command grep -H '^model: ' plugins/*/agents/*.md; echo "rc=$?"`,
  green as exactly seven lines — `analyzer.md:model: sonnet`,
  `committer.md:model: haiku`, `developer.md:model: sonnet`,
  `integrator.md:model: sonnet`, `plan-analyzer.md:model: opus`,
  `planner.md:model: opus`, `reviewer.md:model: sonnet`, each with the
  `plugins/glab/agents/` prefix — then `rc=0`. Its reason: `plugin validate
  --strict` passes an unknown model value such as `model: sonnett` and
  `plugin details` shows no model, so nothing else catches a typo
  (`[flow-models-per-role/plan.md E6]`, proven on a throwaway copy); seven
  named lines, not a count, so a missing definition shows as a missing
  line. **The skills gate** (since `6f8b948`, `glab` 0.13.0;
  `[flow-commands-to-skills/plan.md]` R2a, R2b, `F13`, `F14`), after the
  model gate: for each agent file, an `awk` reads the frontmatter `skills:`
  list and the loop prints `<file>:<plugin>:<skill>` for each entry, with
  ` MISSING` when the entry names no `skills/<name>/SKILL.md` in that
  plugin, when that file has no line `name: <name>`, or when its prefix is
  another plugin's. Green is the fourteen lines `AGENTS.md` *Gates* listed then,
  none `MISSING`. Its reason, in *Gates*: `plugin validate --strict` passes
  an entry that names no skill and `plugin details` does not show the lists
  (proven on a throwaway copy, `F13`), so nothing else catches a typo; it
  was shown to print `analyzer.md:glab:no-such MISSING` and
  `committer.md:other:security MISSING` on a broken copy (`F14`). It checks
  the names only: that a preload loads is
  `[flow-commands-to-skills/plan.md U4]` (`docs/specs/workflow.md`). Since
  `6f8b948` the green list also says that each `Hooks` line ends
  `  (harness-only — no model context cost)`, which the CLI prints and is
  expected (review round 1 B9), and the `glab` skills line names the
  thirteen, `Skills (13)`. Since `09d5664` the `glab` agents line is green as `Agents (7)`
  naming the seven in any order, because the CLI lists them in directory
  read order (`[flow-models-per-role/plan.md D16]`; that the order is
  unstable is inferred, `docs/specs/workflow.md` *Known limits*,
  `[flow-models-per-role/plan.md E6]`). Green at `6f8b948`, run for the
  `flow-commands-to-skills` record (the gate block extracted from `AGENTS.md`
  *Gates* and run with `TMPDIR` set; its own `CLAUDE_CONFIG_DIR`, removed
  after): five `rc=0` lines, `shellcheck` `rc=0`, `PASS 35/35`,
  `PASS 24/24`, three `✔ Validation passed`,
  `Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship`,
  `Agents (7)  reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer`,
  `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`,
  `memory-sync` unchanged with the same suffix, the name check, the
  `user_config` counts `:0` then `rc=1`, the `not yet confirmed` counts `1`
  `1` `1` then `rc=0`, the seven model lines then `rc=0`, the fourteen
  skills-gate lines with no `MISSING`, and the prefixed-`name:` search with
  no line and `rc=1`; the CLI version was not read under the block. Green at `517b7b6`, run for that
  record (Claude Code `2.1.310`, a fresh `CLAUDE_CONFIG_DIR` under
  `$TMPDIR`, removed after): five `rc=0` lines, `shellcheck` `rc=0`,
  `PASS 35/35`, `PASS 24/24`, three `✔ Validation passed`, `glab`
  the same `Skills (14)` as at `2912002`,
  `Agents (7)  reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer`,
  `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`,
  `memory-sync` unchanged, the name check, the `user_config` counts `:0`
  then `rc=1`, the `not yet confirmed` counts `1` `1` `1` then `rc=0`, the
  model gate's seven lines then `rc=0`, and the prefixed-`name:` search with
  no line and `rc=1`. Green at `2912002`, run for
  that record: five `rc=0` lines, `shellcheck` `rc=0`, the `memory-sync`
  suite `PASS 35/35`, the context-size suite `PASS 24/24` (`PASS 21/21`
  from `2a1e919` until `2912002` added T22–T24), three
  `✔ Validation passed`, `glab`
  `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`,
  `Agents (5)`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`,
  and `memory-sync` unchanged (`Skills (1)  sync-memory`, `Agents (0)`,
  `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`); the `jq` name
  check, the `user_config` counts `:0` then `rc=1`, the `not yet confirmed`
  counts `1` `1` `1` then `rc=0` and the prefixed-`name:` search with no line
  and `rc=1` as before. The events print in the key order of `hooks.json`,
  so the green line depends on that order (`[flow-cheaper-rounds/plan.md F18]`).
  History, until `2a1e919`: the script block covered three scripts and the
  one stub test, green was three `rc=0` lines, and `glab` printed
  `Hooks (1)  SessionStart` (green at `467b7c4`: `PASS 35/35`, the same
  `Skills (14)` and `Agents (5)`). No
  external-agent suite runs, and the gates need no `bwrap`, `slirp4netns` or
  `python3`; the `Not yet shown: any reply from a DeepSeek model` gate line
  and its green bullet are gone. History, until `glab` 0.8.0 (`467b7c4`,
  2026-10-20): the script block covered five scripts, with
  `external-agent.sh` and `tests/external-agent.test.sh`, and two stub
  tests, and the plugin block pinned two hedge phrases, the second the
  DeepSeek sentence. Green at `abda43a`, as at `3965622`, ended the two stub tests with
  `PASS 35/35` and `PASS 86/86` (84 at `33a28df`, 71 at `9108ac7`, 49 before
  `feature-codex-agent`); the plugin counts were then `glab`
  `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`.
  `tests/external-agent.test.sh` ran its stub `opencode` inside the
  script's real sandbox, with a real network namespace, and its stub `codex`
  on the host, as the script ran Codex, which needed `bwrap`, `slirp4netns`
  and `python3` (`AGENTS.md` *Gates* until `467b7c4`); `AGENTS.md`
  *Tests* named both stubs as passed to the script with `--cli`, and now
  names `tests/memory-sync.test.sh` alone. The Markdown files have no gate: a change to one is
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
  plugins names one machine's facts. Since `ce1a933` its section *glab
  shared store* holds the line `glab-shared-store: <path to the shared
  folder>`, a plain line, not an indented block, since the managers read
  the first line that begins `glab-shared-store:` (R6;
  `[flow-product-level/result.md]` *Unplanned changes*); a repo's own
  `AGENTS.md` line wins over it (`docs/specs/product.md`, *The shared
  store*). Since `64b4e57` (`glab` 0.16.3, `script-hardening`,
  `[script-hardening/plan.md D2]`) *glab shared store* ends with one
  sentence, "The filesystems it may sit on are named in the header of
  `plugins/glab/scripts/plan-gate.sh`" (`host.example.md:39-41`), and
  `README.md` *The shared store* says the same (`README.md:99-100`); both
  point at the header and restate none of it, and `docs/one-fact.md` is
  unchanged (`[flow-gate-hardening/follow-ups.md FG-2]`, closed, in
  `docs/specs/product.md`).
- **The repo's own rules** are `AGENTS.md` (8313 bytes as of `bf9c73f`,
  its `plan/` rule gaining where the record is committed and the removal
  on the user's word; 8212 bytes as of `3ed6746`,
  under the 8800 cap, its `plan/` rule rewritten by `docs-lifecycle`; 8225 bytes as of `113870b`,
  29824 before; `[slim-agents-md/plan.md D13]`, `D17`): the gates (since
  `113870b` the instruction to run `tests/gates.sh`), the scoped test
  exception for shell scripts (a stub on `PATH`, coverage as a list), no
  secrets (`<bucket>`, `<prefix>`, `<profile, or delete this key>`), never
  running `memory-sync.sh` against a real backend (and, until `467b7c4`,
  `external-agent.sh` against a real model), the hook contracts — `memory-sync.sh`'s (mode names, exit 0 on every path,
  nothing on stdout, messages on stderr) and, since `2a1e919`,
  `context-size.sh`'s (mode names, exit 0 on every path, on stdout one JSON
  object or nothing, messages on stderr, and in mode `stop` no key but
  `systemMessage`: it never blocks or continues a turn) and, since
  `ce1a933`, `manager-bootstrap.sh`'s (exit 0 on every path, on stdout one
  JSON object whose only key is `hookSpecificOutput`, or the plain text
  when `jq` fails, messages on stderr, the level from the first
  `glab-level:` line of the repo's `AGENTS.md`, the project level when
  there is none) and `plan-gate.sh`'s, a script no hook runs whose contract
  holds the same way (the modes `digest`, `report`, `verdict` and `check`;
  exit 0 done, 1 refused, 2 usage or a failed write; every refusal one
  `REFUSED:` line on stderr, and no write but the takeover before it of a
  claim, and its temporary file, whose run provably no longer runs — since
  `2724086`, `[flow-gate-hardening/plan.md contract]`; "and no write" until
  then) — the *One fact,
  one value* rule (since `113870b` three sentences in `AGENTS.md`, its
  known cases — 37 entries, one `##` section each — in `docs/one-fact.md`;
  `[slim-agents-md/plan.md D9]`–`D11`; the list was in `AGENTS.md` until
  then), comments and incidents kept, tests that clean up by PID,
  the version rule (per push since `0cbf5b0`, *Versions* above),
  Conventional Commits.
- **The external-agent rule** — history: removed from `AGENTS.md` *Rules*
  in `glab` 0.8.0 (`467b7c4`, 2026-10-20), with the script; as it stood
  until then (`AGENTS.md` *Rules*, as of `30f2c80`):
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
- ***One fact* entries `remove-external-agents` removed or changed**
  (`AGENTS.md` *Rules*, as of `467b7c4`; S7d–S7j). The first two bullets
  above, and the Codex effort half of the third, are history from that
  commit on. **Removed**: for Codex, no `--model` unless the user named
  one; the external reviewer's record line and its `<backend>:<model>`
  token; `codex` alone in the record line for Codex's default; the exit
  codes of `external-agent.sh`; the OpenCode model allowlist and its end
  dates, and that Codex has none; OpenCode's sandbox limits and its network
  helper; where agents live, `$TMPDIR/glab-external-agents/`; the CLI's
  default paths; OpenCode's "Use balance" warning; what OpenCode's copy
  holds and may send, and what a Codex agent may read and send; Grok refused
  for its retention; the one exit-8 `send` correction; the second statement
  of the missing-`AGENTS.md` fallback, in the script's first message; the
  sentence on what the live probe did not show; the guarantees each backend
  has; the Codex sandbox check; the Codex effort rule; the Codex data note;
  the host and developer first messages; the external developer; the
  developer's change report; a developer refused. **Changed**: the manual
  model rule is back to "the developer and reviewer only, and no `model`
  parameter without the user's instruction (`glab:manager` Rule 5 and its
  handoff-line format in `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/commands/develop.md`, `plugins/glab/commands/review.md`,
  `plugins/glab/commands/ship.md`)"; the reviewer's verdict lines keep
  `reviewer.md`, the manager and `ship.md` and lose the validator and E34;
  the session effort names "`glab:manager` Rules 0d and 5" and no longer the
  `glab:external-agents` skill. **Unchanged as entries**: the round cap,
  the ask-conditions, the fallback ("every agent and command"), the hook
  events, the time limits, the names, the session-start rules, the plan
  lifecycle, and what each plugin holds, whose values changed in the same
  commit where its files state them (`Skills (14)` in `AGENTS.md` *Gates*,
  the six skills named in the `README.md` table; the hooks files did not
  change). Outside *One fact*: *Layout* lost
  `scripts/external-agent.sh`, *Rules* lost the bullet "**Never run
  `external-agent.sh` against a real model from this repo.**" with its
  live-run exception, and *Tests* lost the `opencode`/`codex` stub sentence.
- ***One fact* entries `flow-cheaper-rounds` rewrote or added** (`AGENTS.md`
  *Rules*, as of `2a1e919`; S10.1–S10.4, `[flow-cheaper-rounds/plan.md D25]`,
  `D40`, `D55`). **Rewritten**: "the review round cap" became "the round caps
  — Stage 1b, Stage 3 and Stage 5 at most 2 rounds at every tier, a third
  only on a `critical` or `high` finding of round 2, recorded first as a
  `## Decisions` line, or in the handoff line and this conversation when
  there is no plan, none past 3", over five files — `reviewer.md`,
  `analyzer.md` (added by `D55`, because it states the round-3 trigger),
  `ship.md`, the manager and `glab:bootstrap`. **Added**: the severity
  levels — `critical`, `high`, `medium`, `low` and their meanings
  (`audit/SKILL.md`, `reviewer.md`, `analyzer.md`); every round a new agent,
  Rule 5's report check the one resume (the manager, `plan-first`,
  `developer.md`, `develop.md`, `ship.md`, `analyze.md`); the mapping files
  `map-<area>.md` and the round copies `<name>.r<n>.md` (the manager,
  `plan-first`, `analyzer.md`, `developer.md`); the handoff file
  per-session file `plan/handoff/<session id>.md` as of 0.15.0
  (`glab:session-rules` Rule 2, its owner — at most 4096 bytes, first line
  `- status: in-flight` or `- status: completed`, removed once completed
  under Rule 2's standing approval; `glab:bootstrap` step 5 points at it;
  `.gitignore` holds `plan/handoff/`; one shared file
  `plan/SESSION-HANDOFF.md` until `0cfe335`);
  the `glab` context hook — the modes `prompt`, `agent` and `stop` on
  `UserPromptSubmit`, `PostToolUse` with matcher `Agent` and `Stop`, the
  line `glab: context <n>k (last completed call)`, the `Stop` message, and
  the steps 300k and every 100k after it (`context-size.sh`,
  `tests/context-size.test.sh`, `hooks.json`, the manager, `README.md`); and
  what a review round after the first is given — a new reviewer, the
  target, the previous round's findings verbatim and the range of the fix,
  never the plan, the slug or the intent (`reviewer.md`, the manager,
  `ship.md`). **Unchanged as entries, values changed in the same commit**:
  what each plugin holds (`Hooks (4)  SessionStart, UserPromptSubmit,
  PostToolUse, Stop` in *Gates*, `README.md` and `glab`'s `hooks.json`).
  **Not extended**: "the manual model rule" and "the session effort" name
  the handoff-line format but not its new `· context <n>k` field
  (`[flow-cheaper-rounds/follow-ups.md FUa]`, open in
  `docs/specs/workflow.md`). Outside *One fact*: *Layout* gained
  `scripts/context-size.sh`; *Gates* gained the two new files, the fourth
  command and the `Hooks (4)` line; *Tests* gained "`tests/context-size.test.sh`
  fakes a missing `jq` the other way round, with a `PATH` that lacks it";
  *Rules* changed the one hook-contract bullet into "The hook contracts do
  not change without a plan"; `README.md` gained the `glab` row's context
  hook, a `jq` sentence ("without it the `glab` `SessionStart` hook falls
  back to plain text, and the context hook says nothing") and one paragraph on
  the hook (`D40`, S16.1–S16.3); `.claude-plugin/marketplace.json` changed
  the `glab` entry's `description` to "The glab workflow: skills, agents,
  commands, the session bootstrap hook and the context hook" and nothing else
  (`D58`; outside `plugins/`, so no version of its own).
- ***One fact* entries `flow-planner` rewrote or added** (`AGENTS.md`
  *Rules*, as of `2912002`; its S8, `[flow-planner/plan.md D22]`).
  **Rewritten**: the mapping-files entry became "the mapping files
  `map-<area>.md`, the evidence file `evidence.md` — a subagent's Write of
  `findings.md` is refused — and the round copies `<name>.r<n>.md`", its
  four files unchanged; the context-hook entry names the line "with
  `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set" and "the
  first step 300k, or `GLAB_COMPACT_AT` thousand when set, and every 100k
  after it, and the warning for an invalid value", its five files unchanged.
  **Added**, after the session-effort entry, whose closing `.` became `;`:
  the plan size budget — 48 KB each for `plan.md` and `evidence.md`, and
  the `- size:` line (`plan-first/SKILL.md` Step 3, the manager's acceptance
  checklist item 6); amendments replace the text they change, in place
  (`plan-first/SKILL.md` Step 4, the manager's Stage 1b, `analyzer.md`
  *Re-checks*); `glab:plan-first`'s step numbers — 0 to 4 in `SKILL.md`, 5
  to 7 in `implement.md` (`plan-first/SKILL.md`, `plan-first/implement.md`,
  `commands/plan.md`, `commands/develop.md`, the manager). **Unchanged**:
  the version rule in *Rules* (its change belongs to the later plan
  `flow-master-plan`), *Gates*, *Layout* and *Tests* — `implement.md` is not
  a skill, so `Skills (14)` and `Agents (5)` hold (`docs/specs/workflow.md`,
  `[flow-planner/evidence.md F2]`). Outside *One fact*: `README.md` gained
  four lines after "It never blocks or prolongs a turn.": 300k is the
  default first step, and on a model with a smaller window
  `export GLAB_COMPACT_AT=150` in the shell that starts Claude Code makes the
  steps 150k, 250k, …, every line then ending `; compact at 150k)`.
- ***One fact* entries `flow-master-plan` rewrote or added** (`AGENTS.md`
  *Rules*, as of `0cbf5b0`; its S8 and review fix round 1,
  `[flow-master-plan/plan.md D44]`, `[flow-master-plan/result.md R1]`).
  **Rewritten**: the round caps — "Stage 1b, Stage 3, Stage 5 and the final
  check (Stage 6b) at most 2 rounds at every tier, per sub-plan where there
  are", its five files unchanged (`[flow-master-plan/follow-ups.md DEV3]`:
  of them only `glab:manager` states the final check's cap); the mapping
  files entry adds "the version copies `master.v<n>.md`" beside the round
  copies; the plan size budget is "48 KB each for `master.md`, `plan.md`,
  `index.md` and `evidence.md`". **Added**, after the step-numbers entry,
  whose closing `.` became `;`: the master plan and sub-plans — `master.md`
  with its six sections, constant after `## Approval` and hashed in
  `master.sha256`, a changed request a new master with the old kept as
  `master.v<n>.md` and its approval and hash not carried over, `index.md`,
  the folders `<nn>-<name>/`, the user's approval of every full-tier
  `plan.md`, one commit per sub-plan, one final check, push and record per
  slug, and `## Record` in the master (nine files); the intent check — the
  analyzer at Stage 1b, Stage 3 and the final check, never the reviewer
  (four files); the analyzer's verdict lines — `BUILDABLE`,
  `NOT BUILDABLE`, `CONFORMS`, `DIVERGES: <n> steps`,
  `BLOCK: target unresolved` (four files); approval in plan mode — only
  when the user asks, no plan file outside the repo, `plansDirectory` never
  changed, its claims UNVERIFIED until L1–L7 (the manager, `README.md`);
  the stage sequence with the final check (the manager's description,
  `glab:bootstrap` step 4, `scripts/manager-bootstrap.sh`). The full file
  lists are in `AGENTS.md`. **Rewritten outside *One fact***: the version
  rule (*Versions*, above). **Unchanged**: *Gates*, *Layout* and *Tests* —
  no skill, agent or hook was added, so `Skills (14)`, `Agents (5)` and the
  hook events hold, and the gates print `PASS 35/35` and `PASS 24/24`
  (`[flow-master-plan/result.md B0]`). `README.md` gained the master and
  sub-plan paragraph (`master.md`, the analyzer before and after the build,
  the blind reviewer, the final check before the push; its wording from
  `[flow-master-plan/result.md R6]`) and one paragraph on approval in plan
  mode, its UNVERIFIED pointing at the live tests L1–L7 in
  `docs/specs/workflow.md`; `.claude-plugin/marketplace.json` unchanged.
- ***One fact* entries `flow-models-per-role` rewrote or extended**
  (`AGENTS.md` *Rules*, as of `517b7b6`; its S8 and review round 1,
  `[flow-models-per-role/plan.md D1]`, `D18`,
  `[flow-models-per-role/result.md R1.5]`, `R2.10`). **Rewritten**: "the
  manual model rule — the developer and reviewer only, and no `model`
  parameter without the user's instruction" became "the model per role —
  each agent's frontmatter `model` per the table, the user's words
  overriding any role, no `model` parameter otherwise, and `model <alias>`
  on every agent stage's handoff line", its files now `glab:manager` Rule 5
  and its handoff-line format, the seven `plugins/glab/agents/*.md`,
  `commands/develop.md`, `review.md`, `ship.md`, `analyze.md`,
  `integrate.md`, `commit.md`, `plan.md`, `README.md` and the model gate in
  *Gates* (until `09d5664`: the manager, `develop.md`, `review.md`,
  `ship.md`); the intent check — "the analyzers at Stage 1b
  (`glab:plan-analyzer`), Stage 3 and the final check (`glab:analyzer`),
  never the reviewer"; the analyzers' verdict lines — "`BUILDABLE`,
  `NOT BUILDABLE` (`glab:plan-analyzer`), `CONFORMS`, `DIVERGES: <n> steps`
  (`glab:analyzer`), `BLOCK: target unresolved` (both)"; the in-place
  amendments entry cites `plan-analyzer.md` *Re-checks* in place of
  `analyzer.md`'s, which lost that clause. **Extended** with
  `plugins/glab/agents/plan-analyzer.md`: the round caps, the severity
  levels, the master plan and sub-plans, the intent check, the verdict
  lines, and the mapping/evidence/round-copy entry "(all but the version
  copies)" — it states `map-<area>.md`, `evidence.md` and `<name>.r<n>.md`
  but not `master.v<n>.md` (R1.5). The session-effort entry gained
  `commands/analyze.md`, `integrate.md`, `commit.md` and `plan.md` (R2.10;
  `result.md` R2.10 says `plan.md` joined neither entry, while `AGENTS.md`
  at `09d5664` lists it in both — no file in the folder records that
  addition). `planner.md` joins no entry, since it restates no value it can
  cite (`D18`). **Rewritten outside *One fact***: *Gates* — the model gate
  and `Agents (7)` (*The gates*, above). **Unchanged**: *Layout*, *Tests*,
  `Skills (14)`, the hook events, the test counts (`PASS 35/35`,
  `PASS 24/24`) and `.claude-plugin/marketplace.json`. `README.md` lists
  the seven agents in its table, says the plan check before the build is
  `glab:plan-analyzer`'s and the build check and final check
  `glab:analyzer`'s, and gained a paragraph: each agent runs on the model
  its definition names, chosen for cost, so every installer pays these
  models' prices; the manager passes another model for a role when told;
  "From Claude Code v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` no longer
  reaches these agents", and `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` with it
  does, from v2.1.257 (`[flow-models-per-role/plan.md D13]`,
  `[flow-models-per-role/result.md R2.9]`). Its line naming "five agents
  under `agents/`" stays: it lists what an old copied install put in
  `~/.claude/agents/` (`D16`).
- ***One fact* and the rest of `AGENTS.md` after `flow-commands-to-skills`**
  (`AGENTS.md`, as of `6f8b948`; `[flow-commands-to-skills/plan.md]` R0–R2,
  review round 1 B5 and B9). **The preamble** gained the "say it once" rule
  — "A rule lives in the file of the role that acts on it; every other file
  points at it without restating it, so each fact below is one that more
  than one file states" — and every entry shrank to the files that still
  state its fact (the user's request 2, `docs/specs/workflow.md` *Each rule
  has one owner*). **Removed**: "the session-start rules" and "the stage
  sequence with the final check", each now held by one file
  (`[flow-commands-to-skills/plan.md R2-5]`). **Added**: the entry for the
  skills each agent preloads (`AGENTS.md` *One fact*). **Rewritten**: every
  `commands/<n>.md` path became its stage skill's or left the entry, and
  every `plan-first` path
  `skills/plan/SKILL.md`; `implement.md` left every entry; the step-numbers
  entry is "`glab:plan`'s step numbers — 0 to 4" (with `planner.md` and
  `plan-analyzer.md`); the round caps name `glab:manager` *Pick the tier* and
  the reviewer's round-2 rule only; the ask-conditions the manager and
  `glab:plan` Step 2; the fallback "every agent, and the session-start text";
  the severity levels' meanings `glab:audit` only, their four names in the
  three *Report* sections; the review-after-the-first entry Stage 5 and the
  reviewer; the session effort Rules 0d and 5, *The pipeline*, the hook's
  one pointer line and `README.md`; the intent check without
  `analyze/SKILL.md` (B5). The full lists are in `AGENTS.md`; this spec does
  not restate them. **Outside *One fact***: *Layout* reads "its skills and
  agents"; *Gates* gained the skills gate, the `Skills (13)` line naming the
  thirteen and the `harness-only` suffix bullet (*The gates*, above);
  *Commits* dropped `commands` from the scope list — "`sync`, `agents`,
  `skills`, `repo`" — while past `fix(commands)` commits stay.
  **`README.md`**: the `glab` row lists `glab:comments`, `glab:audit` without
  `glab:plan-first`, and "stage skills `/glab:develop`, … `/glab:ship`,
  which `glab:manager` runs itself and you can type to step in ·
  `/glab:plan <task>`, the planning procedure `glab:planner` follows, which
  you can type to plan in your own session"; the paragraph after the table
  says the manager runs each stage through its stage skill and dispatches
  `glab:planner` itself, and each agent preloads the skills its role uses
  through `skills:`. **The `README.md:164` exception**: `README.md:166` (`:164`
  before the new paragraph) keeps `skills/plan-first/`, the only
  `plan-first` left outside `docs/specs/` and `plan/`: it is the migration
  step that deletes an old copy install's `~/.claude/skills/plan-first/`,
  which keeps that name on a machine that installed that way; renamed, the
  step would leave it behind. The copy install's `commands/*.md` lines
  (`README.md:169`–`:172`) stay for the same reason (`F9`).
  **`.claude-plugin/marketplace.json`**: the `glab` description is "The glab
  workflow: skills, agents, the session bootstrap hook and the context
  hook" — "commands" dropped, nothing else (P7; outside `plugins/`, so no
  version of its own).
- ***One fact* and the rest of `AGENTS.md` after `flow-product-level`**
  (`AGENTS.md`, as of `ce1a933`; `[flow-product-level/plan.md]` R2–R6,
  review round 1 B1–B5 and fix round 1's "*One fact* matches the tree",
  check round 2's R2-5). **Rewritten**, the rule's file moving from
  `glab:manager` to `glab:session-rules` with the rules it names: the round
  caps (now `glab:session-rules` *Round caps*, the table of *Pick the tier*
  and the reviewer's round-2 rule, with P1b at the product level), the four
  ask-conditions (`glab:session-rules` Rule 3 and `glab:plan` Step 2), the
  model per role (Rule 5 and *The handoff line*, the nine agents), the
  skills each agent preloads (`glab:security` in all nine,
  `glab:product-plan` in the product planner), the severity names (with
  `agents/product-analyzer.md`), every round a new agent (Rules 2 and 5),
  the round copies (with `plan-gate.sh`, which leaves them out of the
  digest, Stage 1c and `glab:product-plan-analyze`), the handoff file
  (Rule 2), the context hook, the session effort (Rules 0d and 5 and *The
  handoff line*), the plan size budget (with the product level's
  `product-plan.md` and `glab:product-plan`), and the analyzers' verdict
  lines (with `glab:product-analyzer`'s four and the five product files that
  state them, `product-manager` by review round 1 B3). **Added**: the level
  line `glab-level:`, the shared store line `glab-shared-store:`, the store
  layout, the plan digest with the report and verdict lines and their
  refusals, the brief line, the rejection cap, the rule file budget — 8192
  bytes — the rules of every level, and the level boundary; the full lists
  are in `AGENTS.md`, and this spec does not restate them. Where review
  round 1 found a fact stated in a file its entry did not list, the fix
  chose a pointer under "say it once" and added the file only where the
  fact must be read where it stands (B1, B2, B5 by pointer, B3 by an entry).
  **Outside *One fact***: *Layout* names `scripts/plan-gate.sh` and
  `tests/fixtures/product-loop/`, the walkthrough's sample product;
  *Gates* gained the three tests, nine `rc=0` lines, "run all seven",
  `Skills (21)`, `Agents (9)`, nine model lines and eighteen skills lines
  (`Skills (25)` and the renamed agents since 0.15.0, *The gates*, above); *Rules* gained the hook contract of
  `manager-bootstrap.sh` and the contract of `plan-gate.sh`, a script no hook
  runs (*The repo's own rules*, above); the `plan/` rule's list of area
  specs gained `product.md` (the product level and the product ⇄ project
  loop), first written by this record (*`docs/specs/` and `plan/`*,
  below). **`README.md`**: the `glab` row names `glab:session-rules`, the
  product skills and agents; new sections *Levels* (which level, what the
  session start loads, the shared store and its layout, the loop, the
  `by user` known limit) and *Try the product loop* (the walkthrough with
  `PRODUCT_LOOP_SHOW=1`, its trace to `"$TMPDIR/trace.txt"` — review round 1
  B12 — the live steps, which point at `glab:product-manager` *Starting
  project sessions* rather than restating the start prompt — B5 — and
  LP1–LP6, each UNVERIFIED until run); the version is "the version in
  `plugins/glab/.claude-plugin/plugin.json`", not written by hand (advisory
  2); the `tests/` row names the scripts' tests and the fixtures.
  As of `113870b` (`[slim-agents-md/plan.md D14]`): the `README.md` `tests/` row also names `tests/gates.sh` (`README.md:373`), a new row names `docs/one-fact.md` (`README.md:376`), and `AGENTS.md` *Layout* names both paths (`AGENTS.md:18-21`).
  As of `3ed6746` (`docs-lifecycle`, P19, P21): `README.md`'s record paragraph (`README.md:36-45`) names `docs/features/<feature>.md`, `plan/` ignored and never committed, the manager's removal once the record has landed, and `docs/roadmap/<slug>.md` at the product level; a `docs/features/` row follows the `docs/specs/` row (`README.md:379`), the `plan/` row kept (`:377`); `AGENTS.md` *Layout* gains the `docs/features/` bullet (`:18`) and the `.gitignore` parenthesis "(it holds `/plan/`, the working area, handoff files included)" (`:23`).
  **`host.example.md`**: the section *glab shared store* (*The host file*,
  above).
- **`docs/specs/`, `docs/features/` and `plan/` as of 0.16.2** (`AGENTS.md`
  *Rules*, the `plan/` rule, `AGENTS.md:114`–`118`; `docs/one-fact.md`;
  `README.md`; `[lifecycle-hardening/plan.md D3]`, `D26`), as of `bf9c73f`.
  This bullet supersedes the next one where they disagree. The `plan/`
  rule says the record "is committed on the change's branch, after its
  push and before its merge (`glab:project-record`)", the phrase on one
  line, and "Once the record has landed on `origin/main`, the manager lists
  `plan/<slug>` at a session start and removes it only on the user's word
  (`glab:session-rules` Rule 2)" — no plan-folder approval, and no "by its
  command there"; nothing else under `plan/` is removed but a completed
  handoff file under the same Rule (`docs/specs/workflow.md`, *The docs
  lifecycle as of 0.16.2*). `docs/one-fact.md` holds 38 entries: *Where
  the record is committed* is new, after *The plan lifecycle* — its fact
  "where the record is committed — on the change's branch, after its push
  and before its merge", then `` - `plugins/glab/skills/project-record/SKILL.md` ``
  and ``- and `AGENTS.md`'s `plan/` rule`` — and *The plan lifecycle*'s
  fact now ends "the manager removes it only on the user's word, asked at
  a session start once the record has landed (`glab:bootstrap` step 5,
  `glab:session-rules` Rule 2)", its 18 files unchanged. `README.md`'s
  record paragraph says the manager "asks at a session start whether to
  remove the plan folder, and removes it only on your word"
  (`README.md:42`–`44`), and its `plan/` row "removed on your word once
  each change is recorded" (`:378`). `docs/features/docs-lifecycle.md`
  *When a plan folder is removed* and *Where the rules live* were
  rewritten in `bf9c73f` itself (the `D26` rework, `result.md` *Unplanned
  changes*), then shortened by this record to 2047 bytes, within `D19`'s
  2048, its meaning kept (*Closed follow-ups*). `tests/gates.sh` is unchanged; `PASS 31/31`.
- **`docs/specs/`, `docs/features/` and `plan/` as of 0.16.0** (`AGENTS.md`
  *Layout* and *Rules*, the `plan/` rule; `.gitignore`; `docs/one-fact.md`
  *The plan lifecycle*; `[docs-lifecycle/plan.md]` P19–P22, `D19`–`D21`),
  as of `3ed6746`. `plan/` is ignored by git and never committed:
  `.gitignore` is three lines, two comments — the handoff comment kept and
  moved — then `/plan/`, in place of `plan/handoff/` and its comment.
  After a change's push the record (`glab:project-record`) writes, from
  `plan/<slug>/` on disk, the spec of each area it touched — the area list
  and the spec's content as before, incidents moved into *Incidents* rather
  than dropped — and a page in `docs/features/` when what a user sees
  changed. Its *Records* line names the date, the slug, the change's
  commits on the pushed branch by both ends, `<first>` and `<last>`, the
  branch, and the PR when one exists (form: `glab:project-record`). Once
  the record has landed on `origin/main`, the manager removes `plan/<slug>`
  at a session start under `glab:session-rules` Rule 2's plan-folder
  approval, by its command there (`docs/specs/workflow.md`, *The docs
  lifecycle as of 0.16.0*; **since 0.16.2** it lists the folder and
  removes it only on the user's word, the bullet above); nothing else under `plan/` is removed but a
  completed handoff file under the same Rule. A folder committed before
  `glab` 0.16.0 is read back from the commit its *Records* line names:
  `git show <sha>:plan/<slug>/<file>`. The dropped mechanics — the
  `docs(repo)` removal commit, the tracked, clean and identical checks, the
  `ls-tree` and `git archive` read-backs — are in the bullet below, kept
  as superseded. `docs/features/` holds one page per feature;
  `docs/features/docs-lifecycle.md` is its first, at most 2048 bytes,
  written by this record (`D19`); `README.md` stays the overview and
  points at `docs/features/`, and no page per plugin restates it.
  `docs/one-fact.md` keeps 37 entries (`D20`): *The plan lifecycle* is
  rewritten — `/plan/`, the record's specs and feature pages and the
  product level's `docs/roadmap/<slug>.md`, the *Records* line's fields
  (`D39`), the record never removing, the manager's removal — and lists 18
  files, ten new ones before its last line, ``- and `AGENTS.md`'s `plan/`
  rule``, which stays last, the `.gitignore` line exactly ``- `.gitignore` ``
  (`D41`); *Round caps* gains P7's roadmap check and
  `plugins/glab/skills/product-manager/SKILL.md` P7 (`D43`). `tests/gates.sh`
  is unchanged (`D21`): no skill or agent was added and no gate reads plan
  files from git; `PASS 31/31`.
- **`docs/specs/` and `plan/`** (`AGENTS.md` *Layout* and *Rules*, the
  `plan/` rule; `README.md` *Working on this repo*), as of `09d2787`. **Superseded by `docs-lifecycle` (`glab`
  0.16.0, 2026-11-18)** by the bullet above; kept as the rule from
  `09d2787` to `ae769ec`. `docs/specs/` holds
  one spec per area — this file (the marketplace, this repo's layout, gates
  and rules), `workflow.md`, `memory-sync.md`, `external-agents.md` (a
  record only since `glab` 0.8.0, `467b7c4`, its area removed), and, named
  in the `plan/` rule since `ce1a933`, `product.md` (the product level and
  the product ⇄ project loop), first written by the `flow-product-level`
  record — with
  how the area works now, the decisions that still bind, what is not
  verified, every follow-up open or closed, each tagged
  `[<slug>/<file> <id>]`, and its incidents. A spec states a fact as of its
  last record and names the file that owns it, so it is not one of the
  *One fact* files. `plan/` is the working area: a change's `plan/<slug>/`
  is committed with the change, and after its push the record
  (`glab:project-record`, `docs/specs/workflow.md`) updates the spec of
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
  untracked file under `plan/` is removed but a manager's own completed
  handoff file `plan/handoff/<session id>.md` (`glab:session-rules` Rule 2's
  standing approval, since 0.15.0); `plan/handoff/` is never committed
  (`.gitignore`; the one shared `plan/SESSION-HANDOFF.md` it replaced in
  `0cfe335` was never committed either). Until `feature-docs-specs` the rule was "`plan/` is
  tracked and permanent".

## Decisions that still bind

- [feature-plugin-marketplace/questions.md D1] Plugin-first: the plugins live in subdirectories of this repo; "layout mirrors `~/.claude`" is given up (the user's).
- [feature-plugin-marketplace/questions.md D2] Two plugins: `glab` (the workflow skills, the agents, the commands, the bootstrap hook — since joined by `glab:external-agents`, which left again in 0.8.0, `467b7c4`) and `memory-sync` (the skill, the script, its hooks, its S3 configuration).
- [feature-plugin-marketplace/questions.md D3] Plugin install only: the copy install is dropped, the README documents only the plugin install, and text uses the prefixed names.
- [feature-plugin-marketplace/questions.md D4] Repo only: nothing is installed, enabled or changed in a machine's live Claude config by the work; testing is `--plugin-dir` and `plugin validate`.
- [feature-plugin-marketplace/questions.md S1] The manager's test rules (no hand-written mocks, a generator directive, coverage of 95 % or more) are universal and stay as written; this repo's shell scripts have a scoped exception in `AGENTS.md` *Tests*.
- [feature-plugin-marketplace/questions.md S2] In this repo a stub executable on `PATH` is the allowed way to fake a CLI for shell scripts.
- [feature-plugin-marketplace/questions.md S3] **Superseded by `[flow-cheaper-rounds/plan.md D2]` since `glab` 0.9.0 (`2a1e919`).** It was: the review round cap is 3 (stated in the files `AGENTS.md` *One fact* lists). The cap is now "the round caps" — 2 rounds for Stage 1b, Stage 3 and Stage 5 at every tier, a third only on a `critical` or `high` finding of round 2 — still one fact over the files that entry lists (`docs/specs/workflow.md`, *Round caps*).
- [feature-plugin-marketplace/questions.md S4] `~/.claude/host.md` stays a per-machine file each person creates by hand.
- [feature-plugin-marketplace/questions.md S5] No real bucket name, endpoint, profile or environment value anywhere.
- [feature-plugin-marketplace/questions.md Q1] The marketplace is `glab-services`: `glab@glab-services`, `memory-sync@glab-services`. Renaming it later makes every user remove and re-add it.
- [feature-plugin-marketplace/questions.md Q6] An explicit `version` in each manifest, raised by the commit that changes the plugin, with the `AGENTS.md` bump rule; `validate --strict` must be clean. **Amended by `[flow-master-plan/plan.md D30]` since `glab` 0.11.0 (`0cbf5b0`):** when one push carries several commits of one change — one per sub-plan — the first that changes the plugin raises it, once.
- [feature-plugin-marketplace/questions.md Q7] The root `CLAUDE.md` is deleted; its two rules missing from the hook (the Rule 0c pointer and the host-file temp rule) went into the `SessionStart` hook text, which is the only copy of the session rules a plugin can ship.
- [bug-reviewer-findings/questions.md Q1] Repo only: nothing is copied, symlinked or installed into `~/.claude` by the work, and there is no install script; the live copies were the user's to deal with, and the plugin install later replaced the copy install.
- [bug-reviewer-findings/questions.md Q4] Machine-specific text is split out: generic text in the repo, host facts in the unshipped `~/.claude/host.md` that `glab:bootstrap` reads, with `host.example.md` shipped as the template; the manager's test rules are universal.
- [bug-reviewer-findings/questions.md Q5] The repo has its own `AGENTS.md` (gates, commit format, rules) and `settings.example.json` holds placeholders only. Its first half, keeping the root `CLAUDE.md`, was superseded by `[feature-plugin-marketplace/questions.md Q7]`.
- [bug-reviewer-findings/questions.md Q8] One plan, four ordered slices, separate commits — spent: it scoped that change only.
- [remove-external-agents/plan.md D2] One commit for the removal — the deletions, the edits, the version and the plan folder — because the *One fact* rule wants the component counts of `AGENTS.md` *Gates* and `README.md` changed with the skill's removal, and the version rule wants `plugin.json` in it; its body names `6b2a024` as the last commit with the code. `feat`, because the feature set changes and the version takes a minor step. The plan said no breaking-change marker would be added, since `AGENTS.md` *Commits* names none; the commit was made as `feat(agents)!: remove the external agents and their script` (`467b7c4`), with one.
- [remove-external-agents/plan.md D8] `AGENTS.md`'s `plan/` rule kept `external-agents.md` in its list of area specs, since the spec stays and the removal's own record updates it; whether to reword that item once the record has run was left to Stage 8 — answered by `[remove-external-agents/record.md review-r1-advisory]`, open below, since a change to `AGENTS.md` goes back through the pipeline.
- [remove-external-agents/plan.md D10] No "removed" note in `README.md` or the payload: the user said remove all of it, and the narrow search had to come back empty. The record of the removal, with what a 0.7.x host can still hold, is the top note of `docs/specs/external-agents.md` and the commit body.
- [remove-external-agents/plan.md D12] `glab` `0.7.2` → `0.8.0`, the user's choice; `memory-sync` was not touched and keeps `0.1.0`.
- The decisions of `flow-cheaper-rounds` that bind this area — `[flow-cheaper-rounds/plan.md D25]` (the *One fact* entries), `D26` and `D42` (`glab` `0.9.0`, a minor step, `memory-sync` untouched at `0.1.0`), `D27` (one commit, `2a1e919`), `D40` (the `AGENTS.md` changes: the shell gates, the hook-contract rule, the context-hook entry, the green line), `D55`, `D57` ("run all four, in order") and `D58` (the marketplace description) — are carried in `docs/specs/workflow.md`, the change's primary area, each as a line of its own, and bind here too.
- The decisions of `flow-planner` that bind this area — `[flow-planner/plan.md D18]` (`glab` `0.10.0`, a minor step, `memory-sync` untouched at `0.1.0`), `D20` (one commit with the plan folder, `2912002`) and `D22` (the *One fact* changes) — are carried in `docs/specs/workflow.md`, the change's primary area, each as a line of its own, and bind here too.
- The decisions of `flow-master-plan` that bind this area — `[flow-master-plan/plan.md D30]` (one commit per sub-plan, one push and one record per slug; the version rule per push, amending `[feature-plugin-marketplace/questions.md Q6]`), `D44` (`glab` `0.11.0`, a minor step, nothing removed, `memory-sync` untouched at `0.1.0`; one commit with the plan folder, `0cbf5b0`; the *One fact* changes of its S8) and `D27` (no sub-plan boundary through a fact the repo changes in one commit, `[flow-master-plan/evidence.md F15]`) — are carried in `docs/specs/workflow.md`, the change's primary area, each as a line of its own, and bind here too.
- The decisions of `flow-models-per-role` that bind this area — `[flow-models-per-role/plan.md D1]` (one plan, one commit with the plan folder, `09d5664`, its PR #7 review fix `517b7b6` in the same merge), `D15` (the model gate in `AGENTS.md` *Gates*), `D16` (`Agents (7)` in *Gates* and the seven agents in `README.md`'s table; the copied-install line kept) and `D17` (`glab` `0.12.0`, a minor step, nothing removed, `memory-sync` untouched at `0.1.0`), with `D18` (which *One fact* entries the new agents join) — are carried in `docs/specs/workflow.md`, the change's primary area, each as a line of its own, and bind here too.
- [flow-commands-to-skills/plan.md version] `glab` goes 0.12.0 → 0.13.0, once, in the change's one commit (`6f8b948`); `memory-sync` untouched at `0.1.0`. The review fix round kept `0.13.0`.
- [flow-commands-to-skills/plan.md readme-164] `README.md:164` (`:166` after the new paragraph) keeps `skills/plan-first/`: it is the migration step that deletes the old copy install's `~/.claude/skills/plan-first/`, a directory that keeps that name on a machine that installed that way; renamed, the step would leave it behind. The rename search therefore prints that one line and nothing else.
- [flow-commands-to-skills/plan.md one-fact] *One fact* entries shrink to the files that still state the fact, and a new entry and gate cover the `skills:` lists, because validation passes a wrong name and `plugin details` shows none (R1, R2, `F13`); the session-start rules and the stage sequence leave the list, one file each (R2-5). The rule behind it is the user's "say it once" (`[flow-commands-to-skills/plan.md request-2]`, carried in `docs/specs/workflow.md`).
- [flow-commands-to-skills/plan.md commit-scope] `commands` leaves the `AGENTS.md` commit-scope list; past `fix(commands)` commits stay.
- [flow-commands-to-skills/plan.md wording] Wording outside the stage skills changes where it names the component (`F8`); generic "command" — `hooks.json`'s `"type": "command"`, the `?? .claude/commands/` examples in `reviewer.md` and `committer.md`, the copy install's migration steps in `README.md` — and every stage skill's `/glab:<name>` stay (`F9`).
- [flow-commands-to-skills/plan.md one-commit] One commit with the plan folder, `6f8b948`, merged through PR #9; its other decisions — the stage skills, `glab:plan`, the preload lists, Rule 0c, the user's Q1, "Yes, merge them", "Plan in my session" — are carried in `docs/specs/workflow.md`, the change's primary area, each as a line of its own, and bind here too.
- [flow-product-level/master.md Request] The user's words on one plugin for every level, quoted in `docs/specs/product.md` *Decisions that still bind* — the product level ships inside `glab`; the marketplace still lists two plugins, and `.claude-plugin/marketplace.json` is unchanged.
- [flow-product-level/plan.md version] `glab` goes 0.13.0 → 0.14.0, once, in the commit that changes `plugins/glab/` (`ce1a933`); the two review fix rounds kept `0.14.0`; `memory-sync` untouched at `0.1.0`.
- [flow-product-level/plan.md one-commit] One plan, one commit with the plan folder, `ce1a933` (`e4b8157` on the branch), merged with rebase through PR #11 on the user's go, "yes merge" (the user, in chat, 2026-11-13); its other decisions — the user's approval ("we need to develop, go with your recommendations"), "Opus for both", "Keep names (Recommended)", "okay two is good", "product manager and or also me", "Files in a shared folder" and "plain folder" — are carried in `docs/specs/product.md`, the change's primary area, each as a line of its own, and bind here too.
- [flow-product-level/plan.md gates] Three new test files, one per contract, each a line of the script gates and of `shellcheck`; `Skills (21)`, `Agents (9)`, the nine model lines and the eighteen skills lines in *Gates*' green list (R3).
- [flow-product-level/plan.md contracts] `manager-bootstrap.sh`'s hook contract and `plan-gate.sh`'s contract stand in `AGENTS.md` *Rules* beside the other two hook contracts, and change only with a plan.
- [flow-product-level/plan.md one-fact] The *One fact* entries move with the rules into `glab:session-rules` and gain the product level's facts (R4); where a fact was stated in a file its entry did not list, the review fix took a pointer, and an entry only where the fact must be read in place (review round 1 B1–B5).
- [flow-product-level/plan.md store-line] The store's path is a fact of one machine: `host.example.md` carries the `glab-shared-store:` line as a template, and a repo's `AGENTS.md` line wins (C2, R6); no machine path is committed (X4).
- [flow-gate-hardening/plan.md version] `glab` goes 0.14.0 → 0.14.1, once, in `plugins/glab/.claude-plugin/plugin.json`, in the change's one commit (`2724086`, `bdee40a` on the branch), merged with rebase through PR #13; its review fix round kept `0.14.1`; `memory-sync` untouched at `0.1.0`.
- [flow-gate-hardening/plan.md contract] `plan-gate.sh`'s contract in `AGENTS.md` *Rules* gains one clause: a refusal writes nothing "but the takeover before it of a claim, and its temporary file, whose run provably no longer runs" — the change's one `AGENTS.md` edit (*The repo's own rules*, above); exit codes and stdout unchanged.
- [flow-gate-hardening/plan.md gates] `AGENTS.md` *Gates* unchanged: it names no case count, and its nine files and seven commands stay; the plan-gate test's green moves to `PASS 51/51`. Its other decisions, with the user's words ("let's work on these gates", "Yes, develop"), are carried in `docs/specs/product.md`, the change's primary area, each as a line of its own.
- [slim-agents-md/plan.md D2] `tests/gates.sh` checks itself without running itself: it is in its own file list (G10 `bash -n` and `test -x`, G11 `shellcheck`) and never runs `bash tests/gates.sh`.
- [slim-agents-md/plan.md D3] The preflight comes before any check and does not use `:?`: a failed one prints exactly one stderr line, exits 2 and prints no `ok`, `FAIL` or `PASS` line — never `FAIL` lines or a skip, which could be pasted as green; since fix round 1 a `TMPDIR` that does not start with `/` is refused the same way (`D19` 4).
- [slim-agents-md/plan.md D4] Every `claude` command runs in one subshell with `CLAUDE_CONFIG_DIR` a new directory inside the work directory, never exported empty; the EXIT trap removes the directory, and INT, TERM and HUP exit 130, 143 and 129 so that it runs (`D19` 1).
- [slim-agents-md/plan.md D5] Skills and Agents are compared as sets (the count and the sorted names), because the CLI lists them in directory read order; Hooks lines as exact strings, suffix included; model and skills lines after `LC_ALL=C sort` on both sides.
- [slim-agents-md/plan.md D6] `tests/gates.sh` does not pin the five tests' own case counts: rc 0, every line but the last `ok `, a last line `PASS k/k` — no new copy of those counts.
- [slim-agents-md/plan.md D7] The expected values live in the arrays at the top of `tests/gates.sh` (with `README.md` and the `hooks.json` files, the files `docs/one-fact.md` #7 names); `AGENTS.md` states no count and says only that green is `PASS n/n`. `D8`: each reason is a `#` comment above the check it explains.
- [slim-agents-md/plan.md D9] The *One fact* registry is `docs/one-fact.md`: a title, one intro line pointing at `AGENTS.md` *Rules*, and the 37 entries in order, each a `##` heading, its text and one bullet per file; `D10` rewrote #6, #7, #10, #11, #12 and #20 to name `tests/gates.sh` or `AGENTS.md`'s `plan/` rule.
- [slim-agents-md/plan.md D11] The *One fact* rule in `AGENTS.md` is three sentences — one value in every file in the same commit, a rule in the file of the role that acts on it, the known cases in `docs/one-fact.md` — with its meaning unchanged.
- [slim-agents-md/plan.md D12] The hook-contract paragraph stays in `AGENTS.md` *Rules*, verbatim: an agent in this repo acts on it, and `plugins/glab/scripts/context-size.sh:34` cites "AGENTS.md *Rules*" for it, so moving it would leave that pointer dangling or force a payload edit and a version bump. The `~/.claude` rule keeps citing the `CLAUDE_CONFIG_DIR` rule in *Gates*, which stays there.
- [slim-agents-md/plan.md D15] No file under `plugins/` or `.claude-plugin/` changed, so no plugin version was raised.
- [slim-agents-md/plan.md D17] (manager) The size target of `AGENTS.md` is ≤ 8800 bytes, not about 6 KB (`D13`; 8225 at `113870b`): the hook contracts stay (`D12`) and the `plan/` rule shrinks only in the queued docs-lifecycle slug. **Done by `docs-lifecycle` (`3ed6746`):** `AGENTS.md` is 8212 bytes, its `plan/` rule rewritten (P21).
- [docs-lifecycle/plan.md M1] (manager) `plan/` is ignored by git, and the payload tells an installing repo to add the line; before 0.16.0 no payload text told a repo to ignore `plan/handoff/` and only this repo's `.gitignore` held it, so the instruction is new text, written once, in `glab:bootstrap` step 5 (`docs/specs/workflow.md`).
- [docs-lifecycle/plan.md M4] `glab` goes 0.15.0 → 0.16.0 once; `memory-sync` stays 0.1.0, since no file under it changes.
- [docs-lifecycle/plan.md D1] One plan, no split: about 22 files of text edits and one milestone.
- [docs-lifecycle/plan.md D19] (2315 bytes at `bf9c73f`, over the limit; 2047 after this record: *Closed follow-ups*) This repo gets one feature page, `docs/features/docs-lifecycle.md`, at most 2048 bytes: what happens to plan files, where each kind of doc goes, and how a user finds them. The record writes it, not the build, because the rule says the record writes features. `README.md` stays this repo's overview and only points at `docs/features/`; a page per plugin would restate `README.md` (*One fact*).
- [docs-lifecycle/plan.md D20] `docs/one-fact.md` keeps 37 entries: the plan-lifecycle entry is rewritten, and plan-folder removal, `/plan/` and `docs/roadmap/` fold into it; the handoff entry is unchanged. **Amended by `[lifecycle-hardening/plan.md D3]` (`glab` 0.16.2):** 38 entries, *Where the record is committed* added.
- [docs-lifecycle/plan.md D21] `tests/gates.sh` is unchanged: no skill or agent is added (`GLAB_SKILLS`/`GLAB_AGENTS`), and no gate reads plan files from git.
- [docs-lifecycle/plan.md D39] The *Records* line format (`<first>`, `<last>`, branch, PR, the squash note) joins the fact of `docs/one-fact.md` *The plan lifecycle*; the entry count stays 37.
- [docs-lifecycle/plan.md D41] The new files of *The plan lifecycle* go before its last line, ``- and `AGENTS.md`'s `plan/` rule``, which stays last; every post-condition string sits on one line of its file, with no hard wrap inside it.
- [docs-lifecycle/plan.md D44] (manager, 2026-11-18) Round 2 was the plan-check cap; N1–N9 were fixed as the checker specified and verified by the manager's greps, not by a third round (`docs/specs/workflow.md` *Incidents*).
- [lifecycle-hardening/plan.md D3] (the repo's half) `AGENTS.md`'s `plan/` rule says, in one sentence, that the record is committed on the change's branch, after its push and before its merge, "on the change's branch" on one line; `docs/one-fact.md` gains *Where the record is committed*, its fact, then the bullets `` - `plugins/glab/skills/project-record/SKILL.md` `` and ``- and `AGENTS.md`'s `plan/` rule`` (`docs/specs/workflow.md` for the rule).
- [lifecycle-hardening/plan.md D5] `glab` 0.16.1 → 0.16.2, once; the version is stated only in `plugins/glab/.claude-plugin/plugin.json` (`F7`); `memory-sync` unchanged.
- [script-hardening/plan.md D3] (FU1) Before the preflight's `command -v`, `tests/gates.sh` rewrites `PATH` as `D10` says.
- [script-hardening/plan.md D4] (FU2) The first preflight line refuses a bash older than 4.4: exit 2, `gates.sh: bash 4.4 or newer is required, this is bash <BASH_VERSION>`. Support for an older bash cannot be proven on the build host (`plan.md` F9: only bash 5.3.9, no image to pull); the `+` guard at G24 stays, its comment updated.
- [script-hardening/plan.md D5] `glab` 0.16.2 → 0.16.3, once, in `plugins/glab/.claude-plugin/plugin.json`, which alone states it (`plan.md` F10); `memory-sync` unchanged.
- [script-hardening/plan.md D6] One `fix(skills)` commit for the change (`64b4e57`), then the `docs(repo)` record, in one PR (#23), to be rebase-merged. The plan's text says the commit goes "with this folder"; `plan/` is ignored, and `64b4e57` holds no file under it (`git show --stat 64b4e57`).
- [script-hardening/plan.md D10] (`check.r1.md` F-c) The `PATH` loop runs over `"$PATH:"`, `e=${rest%%:*} rest=${rest#*:}`, so empty entries are kept, a trailing one included; entries starting `/` or `~` are kept (bash expands `~` against `$HOME`), an empty one becomes `$PWD`, any other `$PWD/<entry>`; the block runs `rest=$PATH: p=''` … `PATH=$p`.
- [script-hardening/plan.md D12] (`check.r1.md` F-d) The version-substituted copies run with `env -u TMPDIR`, so a copy that passes the bash line stops at the `TMPDIR` line before any check.
- [script-hardening/plan.md D13] (`check.r1.md` F-g) The `PATH` post-condition's wrappers log to and exec by absolute paths, since `gates.sh` changes into the repo.

## Known limits and not verified

- [feature-plugin-marketplace/plan.md unverified] Not shown in a live session, as of the record: prefixed names resolve (`/glab:plan`, the Skill tool with `glab:manager`, the Agent tool with `glab:developer`); the bootstrap hook fires from a plugin and its text reaches the model; `${CLAUDE_PLUGIN_ROOT}` is substituted in the `sync-memory` skill body, and the skill's fallback for when it is not; everything the README says about credentials, SSH then HTTPS, `CLAUDE_CODE_PLUGIN_PREFER_HTTPS`, background auto-update and the `extraKnownMarketplaces` / `enabledPlugins` keys (it restates the Claude Code docs); `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` for a plugin's `SessionEnd` hook; `claude plugin marketplace add glab-services/skills` on a teammate's machine; `claude plugin update glab@glab-services` delivering a raised version.
- [feature-plugin-marketplace/result-slice-G.md unverified] That the hook fires from the plugin in a live session and that the prefixed names resolve — needs a session; smoke test part 1.
- [feature-plugin-marketplace/plan.md smoke-test-1] Smoke test part 1, `glab` alone under `--plugin-dir ./plugins/glab` (the `/glab:` listing, `/plugin` errors, item 4 of the bootstrap text, loading `glab:security`, dispatching `glab:developer`, `/glab:plan`), and the bare-name questions in a clean config directory: not run, as recorded. Its steps: `git show b853635:plan/feature-plugin-marketplace/plan.md`, *Smoke test*. Parts 2 and 3 are in `docs/specs/memory-sync.md`.
- Validation does not compare a marketplace entry with the plugin it points at: it passes a wrong name and a directory that does not exist. The `jq` line of the plugin gates is what catches it (G26 in `tests/gates.sh` as of `113870b`; `AGENTS.md` *Gates* before).
- [remove-external-agents/plan.md validate-prose] Validation and the component count do not see dangling prose: a throwaway copy of `plugins/` with only the `external-agents` skill and the script removed, every `glab:external-agents` mention still in place, printed `✔ Validation passed` and `Skills (14)` (*Findings*, *Other facts*, proven). Only the plan's searches told the finished tree from a half-finished one.

- The `glab` hook events and their commands are counted by `plugin details` and checked for `user_config` by the gates, but **no gate shows what a hook does when it runs**: the context hook's test passed `19/19` on a script that could never speak in a live session, because every fixture held a transcript entry that is not yet written when `Stop` runs (`docs/specs/workflow.md`, *Incidents*, `[flow-cheaper-rounds/plan.md IN1]`). Only a model run by the user (integration I1) shows the live behaviour; `plugin details` also labels every hook "harness-only — no model context cost", which is not true of one that returns `additionalContext` (`[flow-cheaper-rounds/plan.md FU12]`, open in `docs/specs/workflow.md`).

- Validation and `plugin details` do not see an agent's `skills:` list (`[flow-commands-to-skills/plan.md F13]`, proven on a throwaway copy): `✔ Validation passed` with `glab:no-such-skill` in the list, and the same on-invoke sizes as without the lists. The skills gate checks only that each entry names a skill of its own plugin; that a live dispatch preloads it, and that an installed copy updated to `0.13.0` drops the commands and `glab:plan-first` with no duplicate listing, are UNVERIFIED (`[flow-commands-to-skills/plan.md U4]`, `U3`, in `docs/specs/workflow.md` *Known limits*). The `name: <name>` line the gate requires is how Claude Code names a plugin skill, not its directory (`AGENTS.md` *Gates*).

- The plugin block of the gates was not run on `ce1a933` for the `flow-product-level` record: its dispatch allowed no `claude` command, so its green is the manager's run on the branch's tree before the commit (`[flow-product-level/result.md]` *Fix round — review round 2*, *Gates*), the same tree as `ce1a933` (`e4b8157^{tree}` equals `ce1a933^{tree}`); the script block was run for the record (*The gates*).
- The new tests show the scripts, not a session: `tests/manager-bootstrap.test.sh` runs the hook script with a made-up `AGENTS.md` and `tests/product-loop.test.sh` plays every agent from fixtures; that the hook picks the product text in a live session, and every other runtime claim of the product level, is LP1–LP6, UNVERIFIED (`docs/specs/product.md` *Known limits*).
- `[flow-product-level/plan.md]` X4 cannot run as written: `docs/specs/product.md` *Known limits*, `[flow-product-level/result.md X4]`.
- [slim-agents-md/plan.md Not done] UNVERIFIED: that the CLI's Hooks order is stable — taken as stable because the old gate compared that line exactly; G22 and G25 compare it exactly and passed at `113870b` (`[slim-agents-md/result.md]` *Not done*).
- [slim-agents-md/follow-ups.md FU2] UNVERIFIED: `tests/gates.sh` on bash older than 4.4, the `${MS_AGENTS[@]+…}` expansion included — only bash 5.3.9 was available (`[slim-agents-md/result.md]` *Fix round 1*). **Answered in part by `script-hardening` (`64b4e57`, 0.16.3):** such a bash is now refused by the first preflight line, exit 2 (`[script-hardening/plan.md D4]`); that a real one reaches that line and is refused is still UNVERIFIED, since only copies with `BASH_VERSINFO` replaced ran it (`plan.md` PC5); the `+` guard stays for that reason. The FU2 follow-up is closed (*Closed follow-ups*).
- [slim-agents-md/result.md fix-round-1] UNVERIFIED: a full gate run with a relative `CLAUDE_BIN` pointing at the real CLI — only the two resolution lines (`tests/gates.sh:31-32`) were run, not a whole run.
- [slim-agents-md/result.md M1] `claude plugin validate --strict` accepts an agent with no `model:` line: with `model: haiku` removed from a copy of `committer.md`, only G29 failed (`FAIL G29 agent models (9 lines): missing [plugins/glab/agents/committer.md:model: haiku]`, `FAIL 1/31`), so the model check is the only gate that catches it (the plan's UNVERIFIED, resolved by M1).
- [docs-lifecycle/plan.md Evidence] The plan's UNVERIFIED gates baseline, `PASS 31/31` before the build — answered: the manager's B1 run printed `PASS 31/31`, rc 0, and so did the build, both review rounds (`[docs-lifecycle/review.r1.md]`, `review.r2.md`, *Claims*) and this record's run at `d2ca05b`.
- [lifecycle-hardening/result.md Tests] The Markdown has no runtime: Steps 1–7 are shown by the post-condition greps and, after `D26`, by `result.md` *D26 rework*'s searches and listing run in a throwaway repo; no script or test changed (`/usr/bin/grep` over `tests/` printed nothing); gates `PASS 31/31`, exit 0, at every run and at review rounds 1–3. That a live session follows the text is UNVERIFIED (`docs/specs/workflow.md` *Known limits*).
- [docs-lifecycle/result.md Tests] The Markdown has no runtime: P1–P22 are shown by the post-conditions PC1–PC28 (each at its expected value but PC12, which waits for this record and the folder's removal) and the gates, the text there, not a live session following it — UNVERIFIED, as for every prose rule. No script or test changed (PC11 printed nothing).
- [script-hardening/plan.md Coverage] UNVERIFIED, as of `64b4e57`: a real bash older than 4.4 running `tests/gates.sh` — none was at hand (`plan.md` F9), and only the version-substituted copies ran the refusal; bash 5.3.9 ran the gates, and bash 5.2.37 and 5.1.16 ran the plan-gate suite and passed (the manager, this record's dispatch; `docs/specs/product.md` *Incidents*); bash 4.4 and 5.0 were not run; macOS was not checked (`[script-hardening/review.r1.md]`, `review.r2.md` *Not checked*). The `plan-gate.sh` items — real ENOSPC or EDQUOT, the code 1 after a failed open in a real race, the re-create under the lock — are in `docs/specs/product.md` *Known limits*.

## Open follow-ups

- [bug-reviewer-findings/follow-ups.md 17] `AGENTS.md` *No secrets* names the placeholder as `<profile, or delete this key>`, which reads oddly outside the JSON example — open: `AGENTS.md` at `6838133` still reads so; a cleaner wording is the user's call.
- [bug-reviewer-findings/follow-ups.md 20] No `.gitignore`, and no Markdown lint, so the prose files have no gate — open: `git show 6838133:.gitignore` finds no such file; a Markdown gate is out of scope for `feature-docs-specs` too. Re-read at `3ed6746`: a `.gitignore` exists (since `0cfe335` with `plan/handoff/`, since `3ed6746` `/plan/`); the Markdown gate half is still open — `AGENTS.md` *Gates*: "The Markdown files have no gate."
- [feature-docs-specs/follow-ups.md 3] `README.md:226`: the `plan/` row says "removed once each change is recorded", while `AGENTS.md` removes a folder only once it has landed on `origin/main`. Suggested: "removed after each change has landed, under this repo's `AGENTS.md`" — open; the conformance round 3/4 hand-off named the same line. Re-read at `3ed6746`: `README.md:377` still reads "removed once each change is recorded"; under `docs-lifecycle` the manager removes a folder once its record has landed on `origin/main` (`AGENTS.md`'s `plan/` rule), and the plan took the row as already true (`[docs-lifecycle/plan.md E5]`, P19 "Line 374 stays") — still open, the wording the item suggests being closer to the rule. Re-read at `bf9c73f` (`lifecycle-hardening`): `README.md:378` reads "removed on your word once each change is recorded" — the removal is now on the user's word, but the row still says "recorded" where the rule says the record has landed on `origin/main` — still open.
- [feature-docs-specs/follow-ups.md 8] The *Records* lines of every spec, the transcript citations of `docs/specs/external-agents.md` *Profiles* and *Live runs* and its rev2-build line under *Incidents*, and the list form of `AGENTS.md`'s `plan/` rule: `git ls-tree -r --name-only <sha> -- plan/<slug>/` prints nothing, with exit 0, when run from a subdirectory. Suggested: add `--full-tree`, in the specs and `AGENTS.md` in the same commit — open. Re-read at `467b7c4`: `AGENTS.md`'s list form still has no `--full-tree`, and the `docs/specs/external-agents.md` citations stay, that spec being kept as a record — still open. Re-read at `3ed6746`: `AGENTS.md`'s list form is gone (`ls-tree` → `0` there), so only the older *Records* lines of the specs and the `docs/specs/external-agents.md` citations hold it, all kept as records — still open, for those.
- [script-hardening/plan.md FU-SH2] `tests/gates.sh` checks only its own bash: the tests it runs use the `bash` on `PATH`, which may be another, older one (`plan.md` F9; `tests/gates.sh:28-29`). Opened by `script-hardening` (0.16.3) — open.

## Closed follow-ups

- [slim-agents-md/follow-ups.md FU1] `tests/gates.sh:33-35` (review round 2, low): only `claude` is made absolute before the `cd`; a `jq` or `shellcheck` found through a relative `PATH` entry passes the preflight and then gives `FAIL` lines instead of exit 2. Suggested: resolve both the way `:32` resolves `claude`, or say in the `:24-26` comment that only `claude` gets it — open → **closed by `64b4e57`** (`glab` 0.16.3, `script-hardening`, PR #23), `[script-hardening/plan.md D3]`, `D10`: every relative `PATH` entry, an empty one included, is made absolute against the calling directory before the preflight's `command -v`, so the checks after the `cd` use the tool the preflight found; shown by logging wrappers on a relative `PATH` entry, both run, `PASS 31/31` (`plan.md` PC4, PC4b; *The gates*, above).
- [slim-agents-md/follow-ups.md FU2] `tests/gates.sh` untested on bash older than 4.4 (*Known limits*) — open: needs an older bash → **closed by `64b4e57`** (`glab` 0.16.3, `script-hardening`, PR #23), `[script-hardening/plan.md D4]`: support cannot be proven on the build host (`plan.md` F9), so the first preflight line refuses a bash older than 4.4 with exit 2 and one line; the refusal on a real bash older than 4.4 is UNVERIFIED (*Known limits*, where the FU2 line is amended too).
- [feature-docs-specs/follow-ups.md 1] `AGENTS.md:225`: the `git archive` read-back extracts into a directory it never prints. Suggested: `t=$(mktemp -d "${TMPDIR:?}/plan.XXXXXX") && git archive <sha> plan/<slug>/ | tar -x -C "$t" && echo "$t"` — open. **Closed by `docs-lifecycle` (`3ed6746`, P21):** `AGENTS.md` holds no `git archive` read-back any more (`/usr/bin/grep -c 'git archive' AGENTS.md` → `0`); its one read-back is `git show <sha>:plan/<slug>/<file>`. The form stays in older *Records* lines, kept as records.
- [feature-docs-specs/follow-ups.md 6] `AGENTS.md:220-224`: the repo's removal rule should name the forms that are never valid — never `plan/`, `plan/.`, or a slug outside `[A-Za-z0-9._-]`; review round 2 measured that `plan/./` removes every folder under `plan/` (*Incidents*) — open. **Closed by `docs-lifecycle` (`3ed6746`; `[docs-lifecycle/plan.md D23]`):** `AGENTS.md` holds no removal rule of its own; the removal is `glab:session-rules` Rule 2's plan-folder approval, whose slug must match `[A-Za-z0-9][A-Za-z0-9_-]{0,127}` as a whole name and not be `handoff` — no empty slug, no `.`, no `/`, no `..` — and whose command is `rm -r -- plan/<slug>`, run only after the symlink, `realpath` and `.git` checks.
- [remove-external-agents/record.md review-r1-advisory] Review round 1 advisory, carried from the manager's Stage 8 dispatch (no review file is in the folder): `AGENTS.md:168`, the `plan/` rule, still lists `external-agents.md` among the area specs a record updates, although the area is gone (`[remove-external-agents/plan.md D8]`). Suggested reword of that list item: "`external-agents.md` (removed in 0.8.0, a record only)". It is an `AGENTS.md` change, not a spec change, so the record does not make it → closed 2026-10-20: `AGENTS.md`'s `plan/` rule now reads "`external-agents.md` (removed in 0.8.0, a record only)".
- [bug-reviewer-findings/follow-ups.md 15] *One fact, one value* listed the default time limit but not the coupled maximum (17) and hook timeout (20) — closed: `AGENTS.md` *One fact* lists both, the 20-second hook timeout and "the largest time limit the script accepts, 17".
- [bug-reviewer-findings/follow-ups.md 21] `install.sh --check` to compare the repo with `~/.claude` (Q1's deferred half) — closed, superseded: no install script is tracked, and the plugin install replaced the copy install (`f19f7f0`, `README.md` *Coming from the copy install*).
- [feature-plugin-marketplace/result-review1.md 1] The plan recorded values that no longer held (P3, P9, P15, P17) — closed: the plan is a record of that change, not a check anyone re-runs.
- [feature-plugin-marketplace/result-review1.md 2] `follow-ups.md` did not exist and slice D's four items were open — closed as a pointer: each of the four is carried under its own tag, `[feature-plugin-marketplace/result-slice-D.md 3]` here and `1`, `2`, `4` in `docs/specs/memory-sync.md`.
- [feature-plugin-marketplace/result-review1.md 3] The `:?` guards stop a script, not an interactive shell — closed: `AGENTS.md` *Gates* says so beside the block; since `113870b`: the history comment at `tests/gates.sh:20-23`.
- [feature-plugin-marketplace/result-slice-D.md 3] Stale step ranges in the plan ("P1–P13", "P1–P9, P12") — closed: plan text, history.
- [feature-plugin-marketplace/result-slice-S.md 1] A gate for the hedged sentences — closed: the `not yet confirmed` line of the plugin gates (`AGENTS.md` *Gates*); since `113870b`: G28 (`tests/gates.sh:288-301`).
- [feature-plugin-marketplace/result-slice-S.md 4] The plan's UNVERIFIED list described the old fallback wording of the skill — closed: plan text; its substance stands in `[feature-plugin-marketplace/plan.md unverified]`.
- [feature-plugin-marketplace/result-slice-S.md 5] `0.1.0` is the first version, so no bump was due — closed: information.
- [slim-agents-md/follow-ups.md FU3] `docs/specs/marketplace.md` still described the old *Gates* blocks and the registry in `AGENTS.md` — closed by this record (`D16`): *The gates*, *What each plugin holds* and *The repo's own rules* name `tests/gates.sh` and `docs/one-fact.md` as of `113870b`.
- [lifecycle-hardening/plan.md Record] `docs/features/docs-lifecycle.md` is 2315 bytes at `bf9c73f`, over `[docs-lifecycle/plan.md D19]`'s 2048 (`wc -c`): the `D26` rework rewrote *When a plan folder is removed* in the change's own commit (`result.md` *D26 rework*, *Unplanned changes*). The plan's `## Record` had the record add that a record committed off the change's branch, or whose branch is gone, makes the manager ask, and that a copied or restored folder counts as newer; under `D26` the page already says nothing removes a plan folder without asking, and the record left the page as built rather than lengthen it further, so the copied-or-restored clause is not on it. Shortening the page to 2048 bytes, and whether that clause belongs there — open, the record's decision (2026-11-18), for the user. **Closed by this record (`lifecycle-hardening`, the manager's decision, 2026-11-18):** the record may change feature pages, so the page was shortened in the wording only, keeping its meaning and the ask-once design (`D26`, `D27`), to 2047 bytes (`wc -c`); *When a plan folder is removed* now reads that the record never removes a folder and nothing does without asking you, the checks, the record's commit and the newer files shown, one question, only the named folders removed after a re-check, a kept one not raised again that session, and the not-landed, cannot-run, other-failure and pre-0.16.0 cases. The optional copied-or-restored clause did not fit and is not on the page; Rule 2 states it (`session-rules/SKILL.md:87`).

## Incidents

- **Host and tool hazards, pointed at, not copied:** the `/tmp` tmpfs under a per-user quota whose exhaustion (`EDQUOT`) killed a session from the inside, so temp files go where the host file says (`host.example.md`, *Temp files*); and the ugrep shell function that stands in for `grep` in Claude Code's Bash tool, observed returning nothing, with no error, for an `-E` pattern with a leading alternation, so this repo's commands use `command grep` (`glab:bootstrap` step 6).
- **`--plugin-dir .` loads no plugin.** Pointed at the marketplace root, the CLI printed `No plugins installed.`: it does not read `marketplace.json` from a `--plugin-dir`, and loads only subfolders with a manifest (feature-plugin-marketplace findings, *Experiment E*). The README says to pass `./plugins` or `./plugins/<name>`, never the root.
- **A `:` in an agent's `name:` stops it loading.** "Names can't contain `:` … Claude Code doesn't load a file whose name contains one" (the sub-agents docs, read for feature-plugin-marketplace). A prefixed `name:` passes `validate` and `plugin details`, so the last line of the plugin gates searches for one.
- **Validation passes a wrong marketplace name**, and a `source` directory that does not exist: it never compares the entry with the plugin's own `plugin.json`. The `jq` line of the plugin gates prints `<entry> = <manifest name>` for each.
- **A `${user_config.KEY}` in a hook command passes `validate`** (`✔ Validation passed`) and fails only when the hook runs (feature-plugin-marketplace findings, *Experiment B*); the `user_config` search of the plugin gates is the check.
- **The CLI writes into its config directory even for `plugin validate`** (proven in a throwaway directory, feature-plugin-marketplace findings §1), so a `claude` command without `CLAUDE_CONFIG_DIR` writes into the live `~/.claude`.
- **A wrapped phrase defeats a per-line gate.** The hedge gate first counted `0` in the script: the plan's comment wrapped `not yet confirmed` over two lines, and `grep -F` reads one line at a time (feature-plugin-marketplace `result-slice-D.md`, *Blocked*). The comment was re-wrapped so the phrase sits on one line.
- **`;` instead of `&&` hid a syntax error.** The first gate line printed `rc=0` for a script that failed `bash -n`, because the `rc` was `test -x`'s; it is now `bash -n "$s" && test -x "$s"` (`AGENTS.md` *Gates*); since `113870b`: `tests/gates.sh:179`.
- **A removal path that is not exact removes all of `plan/`** (`feature-docs-specs`, review rounds 1 and 2, measured in throwaway repos): with an empty slug, `git rm -r -n -- "plan/$slug/"` listed every file under `plan/`, `rc=0`, and so did `plan/../` and `plan/./`. The `plan/` rule removes a folder by its exact path, after checking it is tracked, clean and identical on `origin/main`; the forms that are never valid are not yet named (`[feature-docs-specs/follow-ups.md 6]`).
- **The installed plugins load beside `--plugin-dir` in the user's own config** (`flow-cheaper-rounds`, integration I1a, 2026-10-20; `[flow-cheaper-rounds/plan.md IN2]`, told in full in `docs/specs/workflow.md` *Incidents*): the earlier proof that `--plugin-dir ./plugins/glab` loads `glab` alone was under an empty `CLAUDE_CONFIG_DIR`; in the user's own config a second `Stop` hook ran and ended `cancelled`, exit 1. Which plugin's it was is UNVERIFIED. An agent still tests only under a new empty `CLAUDE_CONFIG_DIR` (*Testing without installing*).
- **`mkdir` was not exclusive on the build host** (`flow-product-level`, review fix round 1; told in full in `docs/specs/product.md` *Incidents*): the host's `/usr/bin/mkdir`, uutils coreutils 0.10.0, let two racing calls on one name both succeed; `plan-gate.sh` therefore takes every claim with bash's own `set -C` (`O_EXCL`) create. A host tool hazard beside the ugrep one above: a command's atomicity is the host's.
- **A wildcard `rm` in the shared temp directory** (`slim-agents-md`, fix round 1, 2026-11-18; `[slim-agents-md/follow-ups.md IN1]`): the fix developer cleaned up with `rm -f "$TMPDIR"/fr1-*.out "$TMPDIR"/fr1-*.err` in the shared temp directory, where other sessions keep `fr1-*` files; whether another session's `.out` or `.err` file was removed is unknown. Briefs now say: remove temp files by exact path only.
- **Plan check round 1: NOT BUILDABLE** (`slim-agents-md`; `[slim-agents-md/check.r1.md]`), two high findings: P5 matched `tests/gates.sh` itself, so the search printed `rc=0` instead of `rc=1` on a correctly built tree; and D3's `: "${TMPDIR:?…}"` exits 1 with a bash-formatted `…: line 3: TMPDIR: …` message, not 2 with a `gates.sh:` line. Round 2 was BUILDABLE with one medium (`D18`).
- **The planner overran its budget** (`slim-agents-md`): about 122k tokens against a 60k cap. UNVERIFIED in the repo — the figure is the manager's (record dispatch); no file under `plan/slim-agents-md/` states it.
- **The removal command emptied a symlink's target, twice, in plan check** (`docs-lifecycle`, plan check rounds 1 and 2; `[docs-lifecycle/check.r1.md F1]`, `[docs-lifecycle/check.r2.md N2]`; told in full in `docs/specs/workflow.md` *Incidents*): `rm -r -- plan/<slug>/` on a symlinked slug folder, then `rm -r -- plan/s` through a symlinked `plan`, emptied a target outside `plan/` in throwaway repos while every planned condition passed — the same lesson as *A removal path that is not exact removes all of `plan/`*, above. The approval now checks both symlinks and the `realpath` from the repo root, and its command has no trailing slash.
- **Review round 3's helper wrote outside the temp root** (`lifecycle-hardening`, 2026-11-18; `[lifecycle-hardening/review.r3.md]`, process note): the reviewer's check helper wrote one file to `/tmp/.x`, outside the allowed temp root `/data/tmp/claude` (the host file's temp directory, *Host and tool hazards* above); the reviewer removed it by its exact path, and `/data/tmp/claude/rv-rule2-c5uvw6` too, and the repo kept the same 16 modified files and no new one. Nothing else is known to have been written there. The rule it broke is the same as *A wildcard `rm` in the shared temp directory*'s: temp files only in the host file's temp directory, removed by exact path.
- **`script-hardening`'s incidents, pointed at, told in full in `docs/specs/product.md` *Incidents*** (2026-11-18): review round 1 found that a failed `exec 9>` redirection ends bash silently in posix mode, hence `command exec` (`[script-hardening/review.r1.md]`); review round 2 found that T56 failed on bash 4.4–5.2, the function name `[` being rejected in posix mode (`[script-hardening/review.r2.md]`); the planner's background run of the FU-SH1 hang had to be stopped (the manager, this record's dispatch); and plan check round 2, the plan-check cap (`[script-hardening/plan.md D20]`), and review round 2 were the caps, their fixes verified by the manager, review round 2's verified on bash 5.2 (`D23`); the suite ran on bash 5.2.37 and 5.1.16 in local container images with `--network none` and the repo mounted read-only (the manager, this record's dispatch).

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
- 2026-10-20 · remove-external-agents · recorded in `docs/specs/external-agents.md`, its primary area; here: `glab` 0.8.0, `Skills (14)` (six skills and eight commands), the gates with three scripts, the one `memory-sync` suite at `PASS 35/35`, no external-agent suite, no `bwrap`, `slirp4netns` or `python3` need and no DeepSeek gate line; the external-agent rule, its *Layout* and *Tests* text and the removed and changed *One fact* entries; the review's advisory on `AGENTS.md:168` → `[remove-external-agents/record.md review-r1-advisory]`, open · change 467b7c4 · plan: `git ls-tree -r --name-only 467b7c4 -- plan/remove-external-agents/` (one file: `git show 467b7c4:plan/remove-external-agents/<file>`). `467b7c4` is the last commit on `origin/main` that holds it: one `docs(repo)` commit after this record removes it.
  - [remove-external-agents/plan.md L17] Decisions → `D2`, `D8`, `D10`, `D12`, above.
  - [remove-external-agents/plan.md L224] Tests and coverage → no test added; the 86 cases of `tests/external-agent.test.sh` removed with the script they tested; the Markdown steps covered by the searches C2–C6, as `AGENTS.md` *Tests* allows; nothing open.
  - [remove-external-agents/plan.md L536] Other facts → `[remove-external-agents/plan.md validate-prose]`, under *Known limits*; the rest (rule numbering, nothing untracked under the removed paths, no marker in the removed files, the version stated only in `plugin.json`) were that change's checks; nothing open.
  - [remove-external-agents/plan.md L247] Record → the open follow-up `[feature-docs-specs/follow-ups.md 8]` re-read, still open.
- 2026-10-20 · flow-cheaper-rounds · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.9.0, the `glab` hook events (`Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`), the gates with five scripts and two tests (`PASS 35/35`, `PASS 21/21`), the hook-contract rule for `context-size.sh`, the rewritten and added *One fact* entries, the `glab` description in `.claude-plugin/marketplace.json`, *Testing without installing* (the installed plugins load beside `--plugin-dir` in the user's config); `[feature-plugin-marketplace/questions.md S3]` superseded by `D2` · change 2a1e919 · plan: `git ls-tree -r --name-only 2a1e919 -- plan/flow-cheaper-rounds/` (one file: `git show 2a1e919:plan/flow-cheaper-rounds/<file>`). `2a1e919` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-cheaper-rounds/`): one `docs(repo)` commit after this record removes it.
  - [flow-cheaper-rounds/plan.md L1049] Record → the entries above; the decisions in `docs/specs/workflow.md`; the follow-ups `FU1`–`FU18` and `FUa`–`FUd` open or closed there, with `FUa` (the *One fact* entries "the manual model rule" and "the session effort" and the handoff line's context field) the one that concerns `AGENTS.md`.
  - [flow-cheaper-rounds/plan.md L1044] Incidents → `IN2` here, `IN1` and `IN2` in `docs/specs/workflow.md`.
- 2026-10-22 · flow-planner · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.10.0, the gates' context-size suite at `PASS 24/24` (`PASS 35/35` unchanged, the component counts unchanged), the two rewritten and three added *One fact* entries, the `GLAB_COMPACT_AT` lines of `README.md` · change 2912002 · plan: `git ls-tree -r --name-only 2912002 -- plan/flow-planner/` (one file: `git show 2912002:plan/flow-planner/<file>`). `2912002` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-planner/`): one `docs(repo)` commit after this record removes it.
  - [flow-planner/plan.md S8] Record → the entries above; the decisions, follow-ups and incident in `docs/specs/workflow.md`; none of its follow-ups concerns `AGENTS.md`.
- 2026-10-22 · flow-master-plan · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.11.0, the version rule per push (`[feature-plugin-marketplace/questions.md Q6]` amended by D30), the three rewritten and five added *One fact* entries, the two `README.md` paragraphs; the gates unchanged at `PASS 35/35` and `PASS 24/24`, the component counts and `.claude-plugin/marketplace.json` unchanged · change 0cbf5b0 · plan: `git ls-tree -r --name-only 0cbf5b0 -- plan/flow-master-plan/` (one file: `git show 0cbf5b0:plan/flow-master-plan/<file>`). `0cbf5b0` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-master-plan/`): one `docs(repo)` commit after this record removes it.
  - [flow-master-plan/plan.md Record] Record → the entries above; the decisions, follow-ups and incident in `docs/specs/workflow.md`; of its follow-ups `[flow-master-plan/follow-ups.md DEV3]` (the round-caps entry and the final check's cap) concerns `AGENTS.md`, open in `docs/specs/workflow.md`.
- 2026-11-12 · flow-models-per-role · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.12.0, seven agents (`Agents (7)` in any order), the new model gate with its reason, the rewritten and extended *One fact* entries, the `README.md` table and model paragraph; the gates otherwise unchanged at `PASS 35/35` and `PASS 24/24`, `Skills (14)`, the hook events and `.claude-plugin/marketplace.json` unchanged · change 09d5664 517b7b6 · plan: `git ls-tree -r --name-only 517b7b6 -- plan/flow-models-per-role/` (one file: `git show 517b7b6:plan/flow-models-per-role/<file>`). `517b7b6` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-models-per-role/`): the `docs(repo)` commit that carries this record removes it.
  - [flow-models-per-role/master.md Record] Record → the entries above; the decisions, follow-ups and known limits in `docs/specs/workflow.md`; of its follow-ups `[flow-models-per-role/plan.md FU4]` (these two specs restating `Agents (5)` and Rule 5) concerned this file and is closed by this record; none is open against `AGENTS.md`.
- 2026-11-13 · flow-commands-to-skills · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.13.0, `Skills (13)` with no commands (`commands/` and `skills/plan-first/` removed, the seven stage skills and `glab:plan` in their place), each agent's `skills:` list and the new skills gate with its reason, the `harness-only` suffix in the green list, the *One fact* preamble ("say it once") and the shrunk, removed and added entries, *Layout* and the commit-scope list without `commands`, the `README.md` row and paragraph and its `:164` exception, the `glab` description in `.claude-plugin/marketplace.json`; the gates otherwise unchanged at `PASS 35/35` and `PASS 24/24`, `Agents (7)` and the hook events unchanged · change 6f8b948 · plan: `git ls-tree -r --name-only 6f8b948 -- plan/flow-commands-to-skills/` (one file: `git show 6f8b948:plan/flow-commands-to-skills/<file>`). `6f8b948` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-commands-to-skills/`): the folder is removed in the record commit.
  - [flow-commands-to-skills/plan.md Record] Record → the entries above; the decisions, follow-ups, known limits and incidents in `docs/specs/workflow.md`; of its follow-ups none is open against `AGENTS.md`, and `[flow-master-plan/follow-ups.md DEV3]` (the round-caps entry) is closed there by the entry's new file list.
- 2026-11-13 · flow-product-level · recorded in `docs/specs/product.md`, its primary area, new with this record, and its project edges in `docs/specs/workflow.md`; here: `glab` 0.14.0 and the `plugin.json` description, `Skills (21)` and `Agents (9)` with the product level and `glab:session-rules`, `plan-gate.sh` and `tests/fixtures/product-loop/` in *Layout*, the script gates over nine files with three new tests (`PASS 42/42`, `PASS 13/13`, `PASS 17/17`, run for this record beside `PASS 35/35` and `PASS 24/24`), the model gate's nine lines and the skills gate's eighteen, the hook contracts of `manager-bootstrap.sh` and `plan-gate.sh`, the store line in `host.example.md`, the rewritten and added *One fact* entries, `product.md` in the `plan/` rule, the `README.md` row, *Levels* and *Try the product loop*; `.claude-plugin/marketplace.json` and the hook events unchanged · change ce1a933 · plan: `git ls-tree -r --name-only ce1a933 -- plan/flow-product-level/` (one file: `git show ce1a933:plan/flow-product-level/<file>`). `ce1a933` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-product-level/`; PR #11, merged with rebase): the folder is removed in the record commit.
  - [flow-product-level/master.md Record] Record → the entries above; the decisions, follow-ups, known limits and incidents in `docs/specs/product.md`, and the project edges' in `docs/specs/workflow.md`; of its follow-ups none is open against `AGENTS.md` or the gates — `FR1-1` (hard links) and the UNVERIFIED network filesystem concern the store, open in `docs/specs/product.md`; the `mkdir` hazard → *Incidents* here and there.
- 2026-11-14 · flow-gate-hardening · recorded in `docs/specs/product.md`, its primary area; here: `glab` 0.14.1, `plan-gate.sh`'s contract with the takeover clause as `AGENTS.md` *Rules* states it, the `ln` and `head` stubs and the new background and launcher cases of `tests/plan-gate.test.sh`, its green at `PASS 51/51` (not run for this record; the developer's and the manager's runs on the same files); the component counts, the hook events, `AGENTS.md` *Gates*, `README.md`, `host.example.md` and `.claude-plugin/marketplace.json` unchanged · change 2724086 · plan: `git ls-tree -r --name-only 2724086 -- plan/flow-gate-hardening/` (one file: `git show 2724086:plan/flow-gate-hardening/<file>`). `2724086` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-gate-hardening/`; PR #13, merged with rebase from `bdee40a`): the folder is removed in the same PR as this record.
  - [flow-gate-hardening/master.md Record] Record → the entries above; the decisions, follow-ups and known limits in `docs/specs/product.md`; of its follow-ups `[flow-gate-hardening/follow-ups.md FG-1]` (a failed claim write exits 1, not the contract's 2) concerns the contract in `AGENTS.md` *Rules* and `FG-2` (the store's filesystems in `README.md`) the store, both open in `docs/specs/product.md`; no incident.
- 2026-11-18 · flow-project-level · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.15.0, `Skills (25)` and the nine agents as `AGENTS.md` *Gates* lists them, the project level's old → new names (`glab:<name>`, `skills/<name>/`, `agents/<name>.md`) through *How it works now*, the nine model gate lines and the eighteen skills gate lines, the old-name search of `[flow-project-level/master.md]` *Final check* step 2, the per-session handoff file `plan/handoff/<session id>.md` in place of `plan/SESSION-HANDOFF.md` (G6), both *Gates* blocks run for this record (`PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 19/19`, `PASS 17/17`); final check CONFORMS (G1–G6) · change db5feae (01 `0c49626`, 02 `0cfe335`, 03 `db5feae`) · plan: `git ls-tree -r --name-only db5feae -- plan/flow-project-level/` (one file: `git show db5feae:plan/flow-project-level/<file>`). `db5feae` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-project-level/`; PR glab-services/skills#15, merged with rebase from `cf909b5`).
  - [flow-project-level/master.md Record] Record → the entries above; the project level, its decisions, follow-ups and known limits in `docs/specs/workflow.md`, the product level's side in `docs/specs/product.md`; its incidents, if any, with the primary area's record (none recorded here).
- 2026-11-18 · slim-agents-md · repo only: the gates as `tests/gates.sh` (31 checks, `PASS 31/31`, exit 0/1/2, preflight, config-dir subshell and traps, set comparisons), the *One fact* registry as `docs/one-fact.md` (37 entries), the rule in `AGENTS.md` in three sentences, `AGENTS.md` at 8225 bytes (29824 before), through *How it works now*; no file under `plugins/` or `.claude-plugin/`, no plugin version change · change 113870b · PR glab-services/skills#17, rebase-merged 2026-11-18 · plan: `git ls-tree -r --name-only 113870b -- plan/slim-agents-md/` (one file: `git show 113870b:plan/slim-agents-md/<file>`). `113870b` is the last commit on `origin/main` that holds it.
  - Decisions → `[slim-agents-md/plan.md D2]`–`D7`, `D9`, `D11`, `D12`, `D15`, `D17` under *Decisions that still bind*; the rest (`D1`, `D8`, `D10`, `D13`, `D14`, `D16`, `D18`, `D19`) through *How it works now* or the plan folder.
  - Follow-ups → `FU1`, `FU2` under *Open follow-ups*; `FU3` under *Closed follow-ups*, closed by this record.
  - Incidents → `IN1`, plan check round 1 `NOT BUILDABLE` and the planner's overrun under *Incidents*.
  - Record → this record, in this file only; no audit file.
- 2026-11-18 · docs-lifecycle · 3ed6746 · 3ed6746 · docs-lifecycle · #19
  - PR #19 (glab-services/skills), rebase-merged onto `main` as `d2ca05b` on 2026-11-18; recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.16.0 (`memory-sync` 0.1.0), `.gitignore` as `/plan/` with its two comments, `docs/features/` in `AGENTS.md` *Layout* and `README.md`, `AGENTS.md`'s `plan/` rule rewritten (8212 bytes), the *One fact* entries *The plan lifecycle* and *Round caps*, the old rule kept as superseded; `tests/gates.sh` unchanged, `PASS 31/31`. The plan folder was not kept in git.
  - [docs-lifecycle/plan.md Decisions] Decisions → M1, M4, D1, D19–D21, D39, D41, D44 under *Decisions that still bind*; `[slim-agents-md/plan.md D17]` marked done; the others in `docs/specs/workflow.md` and `docs/specs/product.md`.
  - Not verified → the gates baseline (answered) and the Markdown's lack of a runtime, under *Known limits*.
  - Follow-ups → closed: `[feature-docs-specs/follow-ups.md 1]`, `6`; re-read, still open: `[feature-docs-specs/follow-ups.md 3]`, `8`, `[bug-reviewer-findings/follow-ups.md 20]`. The change's own follow-ups are in `docs/specs/workflow.md` and `docs/specs/product.md`.
  - Incidents → the symlink incidents of plan check rounds 1 and 2, under *Incidents*, told in full in `docs/specs/workflow.md`.
  - Record → this record, in this file, `docs/specs/workflow.md`, `docs/specs/product.md` and `docs/features/docs-lifecycle.md` (`D19`); no audit file.
- 2026-11-18 · lifecycle-hardening · bf9c73f · bf9c73f · lifecycle-hardening · #22
  - PR #22 (glab-services/skills), not merged at this record; recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.16.2 (`memory-sync` 0.1.0), `AGENTS.md`'s `plan/` rule (the record on the change's branch, the removal on the user's word; 8313 bytes), the new *One fact* entry *Where the record is committed* (38 entries), `README.md`'s record paragraph and `plan/` row; `tests/gates.sh` unchanged, `PASS 31/31`. The plan folder was not kept in git.
  - [lifecycle-hardening/plan.md Decisions] Decisions → `D3`'s repo half and `D5` above under *Decisions that still bind*; `[docs-lifecycle/plan.md D20]` amended, `D19` marked over its limit; the others in `docs/specs/workflow.md` and `docs/specs/product.md`.
  - Not verified → the Markdown's lack of a runtime, under *Known limits*; the live-session, BSD `find`, shallow-clone and forge-date items in `docs/specs/workflow.md`.
  - Follow-ups → closed by this record: `[lifecycle-hardening/plan.md Record]` (the feature page's size); re-read, still open: `[feature-docs-specs/follow-ups.md 3]`. The change's other follow-ups are in `docs/specs/workflow.md` and `docs/specs/product.md`.
  - Incidents → review round 3's `/tmp/.x`, under *Incidents*; the automatic-removal failures in `docs/specs/workflow.md` *Incidents*.
  - Feature page → `docs/features/docs-lifecycle.md`: its `## Record` change was the date-guard design, superseded by `D26`, and the page was rewritten for `D26` in `bf9c73f` itself; this record shortened it from 2315 to 2047 bytes, its meaning kept, on the manager's decision (*Closed follow-ups*).
  - Record → this record, in this file, `docs/specs/workflow.md`, `docs/specs/product.md` and `docs/features/docs-lifecycle.md`; no audit file.
- 2026-11-18 · script-hardening · 64b4e57 · 64b4e57 · script-hardening · #23
  - PR #23 (glab-services/skills), not merged at this record; recorded in `docs/specs/product.md`, its primary area (`plan-gate.sh`'s failed-write path and exit codes, the pre-open guard, `command exec`, the store-filesystem pointer, T52–T56 and `PASS 56/56`); here: `glab` 0.16.3 (`memory-sync` 0.1.0), `tests/gates.sh`'s bash 4.4 refusal and `PATH` rewrite (31 checks, `PASS 31/31`), the pointers in `README.md` and `host.example.md`; `AGENTS.md` and `docs/one-fact.md` unchanged. The plan folder was not kept in git.
  - [script-hardening/plan.md Decisions] Decisions → `D3`–`D6`, `D10`, `D12`, `D13` above under *Decisions that still bind*; the others in `docs/specs/product.md`.
  - Not verified → a real bash older than 4.4 and macOS, above under *Known limits*, the FU2 line amended; the `plan-gate.sh` items in `docs/specs/product.md`.
  - Follow-ups → closed: `[slim-agents-md/follow-ups.md FU1]`, `FU2`, moved to *Closed follow-ups* (the slim-agents-md record's line above still lists them as open, as of its record); open: `[script-hardening/plan.md FU-SH2]`; FU-SH1, FU-SH3, FU-SH4 and the closed FG-1 and FG-2 in `docs/specs/product.md`.
  - Security → no secrets; no hook contract changed, and `plan-gate.sh`'s contract in `AGENTS.md` *Rules* holds unchanged (`[script-hardening/plan.md D1]`, `plan.md` F6, PC7).
  - Incidents → pointed at under *Incidents*, told in full in `docs/specs/product.md`.
  - Record → this record, in this file and `docs/specs/product.md`; no feature page, no audit file.
