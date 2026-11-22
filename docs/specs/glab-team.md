# glab-team — spec

The `glab-team` plugin of this marketplace (`glab-team@glab-services`): team
agent messaging for Claude Code sessions, today the `/glab-team:messaging-*`
skills, a `messaging` MCP server, four hooks and two CLI commands. This spec
covers the plugin, its source `src/glab-team/` (channel, broker, shared code,
tests, the build script) and the committed build `plugins/glab-team/`. The
marketplace, the gates and `AGENTS.md` are in `docs/specs/marketplace.md`.
Owned by `src/glab-team/` (its `AGENTS.md`, `README.md`, `docs/setup.md`),
`plugins/glab-team/.claude-plugin/plugin.json` (built from
`src/glab-team/plugin/.claude-plugin/plugin.json`) and
`src/glab-team/scripts/build-plugin.mjs`. Stated as of `c100700` (version
`0.12.0`, 2026-11-22), written by the record of `add-team-messaging`; where an
owning file and this spec disagree, the owning file is right and this spec is
out of date. Tags `[add-team-messaging/<file> <id>]` name the plan file under
`plan/add-team-messaging/` that owns the item; its sub-plans are
`01-import-source/`, `02-rename-glab-team/` and `03-publish-plugin/`.

## How it works now

- **Where it came from, and that it is maintained here.** The source is the
  whole tracked tree (161 files) of glab-services/claude-plugins `441887c`,
  tree `e4e5d1b`, copied byte for byte into `src/glab-team/` by sub-plan 01
  (`git write-tree --prefix=src/glab-team/` printed
  `e4e5d1b36c1e9979a56c135bff8a8ce762f6db1e`, commit `5dee913`;
  `[add-team-messaging/index.md D2]`, `[add-team-messaging/01-import-source/result.md P2]`).
  A build of that tree reproduced the release-candidate `plugin-dist-rc`
  `8a4fd60` byte for byte (`git write-tree` of the plugin directory
  `22f10fb16f777318caf554aa0364477444813628`, 3693 files;
  `[add-team-messaging/evidence.md E4]`), so what moved is the source of the
  build the user chose ("0.11.1 rc build"). **There is no upstream:** the user,
  2026-11-21: "I'm not planing support upstream, so let's forget about
  upstream, after move we will support it in current repo". Nothing is pushed
  to, or kept in step with, glab-services/claude-plugins
  (`[add-team-messaging/master.md Request]`, *Out of scope*).
- **Layout.** `src/glab-team/` is a pnpm workspace of its own (`plugin/`,
  `channel/`, `broker/`, `shared/`, `scripts/`, `test-support/`, `docs/`,
  `LICENSE`, `AGENTS.md`, `README.md`; D2). A later tool, `telegram/`, is a
  sibling of `channel/` in the same workspace with its own runtime folder and
  `skills/telegram-*`; none exists yet (G4: the user's "I'm planing also
  implement `/glab-team:telegram-*` tools and rest other communication or
  sharing tools in future", out of scope here). The broker is source with
  tests but is not in the plugin: the build copies only `plugin/`,
  `channel/*.mjs` and `shared/address.mjs`; running a broker is its
  operator's job and no broker URL or token is in any file
  (`[add-team-messaging/index.md D8]`). `plugins/glab-team/` is the build,
  `node_modules/` included (3693 files, 29 MB, git tree
  `3695ea81cefdbbdd9322edf9bcf76de6720d5c43`): an install copies the
  directory and nothing runs an install there (D4).
- **How a change is made and rebuilt.** Change `src/glab-team/`, then, in
  `src/glab-team` with the registry once, `rm -rf plugins/glab-team` and
  `pnpm -s plugin:build` (`node scripts/build-plugin.mjs --publish`), then
  stage with `git -c core.excludesFile=/dev/null add plugins/glab-team` (a
  global ignore must not drop `node_modules/`; `[add-team-messaging/03-publish-plugin/plan.md 03-D8]`).
  The build script: `--out <dir>` (under `$TMPDIR` or `src/glab-team/dist/`;
  `/tmp` refused; a non-empty directory refused; `--out` must be a directory
  below a real admitted root, symlinks resolved) or `--publish` (the one path
  `plugins/glab-team`, only through that flag; `--publish` with `--out`, no
  target, an unknown or repeated argument is a usage error, one line, exit
  2), and `--no-install` (skips `npm ci` and `claude plugin validate`, keeps
  the `bin/*` chmod). It writes no marketplace file (the repo's
  `.claude-plugin/marketplace.json` is the marketplace), copies `LICENSE`
  once into the plugin, and builds into a sibling `<out>.build-<pid>`
  directory that is renamed onto `out` only after install and validate pass,
  so a failed build leaves a committed plugin intact
  (`[add-team-messaging/index.md D11, D22]`,
  `[add-team-messaging/03-publish-plugin/plan.md 03-D1, 03-D2, 03-D3, 03-D4, 03-D5, M-m]`).
  The rebuild rule and the version files are in `src/glab-team/AGENTS.md`
  (not shipped), not in the repo's `AGENTS.md` (D13's fallback, 03-D12).
- **How the gate proves the build (G45).** `tests/gates.sh` builds with
  `--no-install` into a new directory under `src/glab-team/dist/` (ignored;
  the guard refuses `/tmp`, which is this host's `TMPDIR`), removed by an
  `EXIT` trap, and fails on any `diff -r --exclude=node_modules` output, on
  differing execute-bit lists outside `node_modules/`, and on a
  `node_modules/` whose `<path> <name>@<version>` set differs from
  `src/glab-team/plugin/package-lock.json`'s. **What it does not guarantee:**
  `node_modules/` is checked by package name and version only, so a file
  edited inside a right-versioned package passes; a full byte check against a
  fresh `npm ci` build is a record-time command (a build into a new
  `src/glab-team/dist/` directory compared with `diff -r --no-dereference`:
  no output, 03's A5), not a gate (`[add-team-messaging/index.md M5, D4]`;
  its execute-bit branch and the `INT`/`TERM`/`HUP` trap are untested,
  `[add-team-messaging/03-publish-plugin/plan.md Tests and coverage]`).
  G23 validates the committed copy (`claude plugin validate --strict
  plugins/glab-team`); G42–G44 compare the three `plugin details glab-team`
  lines exactly: `Skills (5)  messaging-bind, messaging-claim, messaging-join,
  messaging-status, messaging-watch`, `Hooks (4)  SessionStart, PreToolUse,
  Stop, StopFailure  (harness-only — no model context cost)`, `MCP servers (1)
  messaging  (tool schemas resolved at runtime; not counted)`.
- **The Node suites.** G40 runs `pnpm -s broker:test` and G41 `pnpm -s
  channel:test` in `src/glab-team`, `umask 0002` (three `join.test.mjs` cases
  make a `0770` directory), Node.js 24 first on `PATH`, with an empty `HOME`
  and `CLAUDE_CONFIG_DIR` of their own under the gate's work directory and
  `RUN_CLAUDE_ACCEPTANCE` removed. A reporter the script writes reads each
  failed or cancelled test as `<file>: <name>` and compares with the host
  list array in `tests/gates.sh`: `ok` when every failure is listed, zero
  failures included, its line naming the known ones it saw; `FAIL` on any
  failure outside the list and when the suite fails with no failure line to
  check. The user's rule, 2026-11-21, at step 01's review: "Pass if only
  known (Recommended)". The broker's list is empty (362 tests, 0 failures).
  The channel list is 9 tests that fail on the reference host (root, no IPv6):
  seven root-caused (they pass as uid 65534) and two `::1` ones (no
  `/proc/net/if_inet6`); 375 tests, 365 pass, 1 skipped
  (`[add-team-messaging/index.md D16, D20, M3, M7]`,
  `[add-team-messaging/01-import-source/plan.md 01-D2, 01-D3, 01-D8, M14]`).
  The preflight stops the script, exit 2 and one line on stderr, without
  Node.js 24 or newer as the `node` first on `PATH`, pnpm 10 or newer, or
  `src/glab-team` installed from its lockfile (`cmp -s
  src/glab-team/node_modules/.pnpm/lock.yaml src/glab-team/pnpm-lock.yaml`);
  never a skip (`[add-team-messaging/index.md D6]`, `01-D4`, `01-D5`).
  `pnpm -s plugin:test` (the build's test, needs the registry and `claude`;
  9 tests) and the acceptance suites are not gates (M4, D14).
- **The naming map** (`[add-team-messaging/index.md D3]` as `M1` overrules it,
  `D18`, `M11`; exact strings are 02's, `[add-team-messaging/02-rename-glab-team/plan.md D-N]`).
  Plugin `glab-team`; marketplace `glab-services`; `PLUGIN_ID`
  `glab-team@glab-services` (`channel/project-options.mjs`); data directory
  name `glab-team-glab-services` (`PLUGIN_DATA_NAME`, derived from
  `PLUGIN_ID` in `channel/cli.mjs`, pinned by `plugin-env.test.mjs`); the
  plugin's data under `<data>/messaging` (`messagingDataDir`; the manifests
  pass `${CLAUDE_PLUGIN_DATA}/messaging` as `--data-dir`); skills
  `messaging-join`, `-bind`, `-claim`, `-status`, `-watch` and their
  `/glab-team:messaging-<x>` commands; MCP server key `messaging`,
  `OUR_PREFIX` `mcp__plugin_glab-team_messaging__`, `OUR_SERVER`
  `plugin:glab-team:messaging`; CLI commands `glab-team-messaging` and
  `glab-team-messaging-watch`; plugin options `messaging_broker_url`,
  `messaging_token_file`, `messaging_mode`, `messaging_arm`; the binding
  entry's keys `messaging_version`, `messaging_claude_session_id`,
  `messaging_bindings`, `messaging_mac` (`MAC_LABEL` renamed); hook, Stop and
  SessionStart lines start `glab-team messaging:`. `workspace` left
  `userConfig` with `--adopt-global`, and so did `topic` and `session_id`
  (no reader). **Names kept** because they are stored or wire data, or the
  server's own environment: the credential directory
  `~/.config/team-messaging/credentials` and its outbound-scope pattern; the
  broker's default database name, its schema `GUARD` text and the
  `team-messaging-t-` prefix of `channel/register.mjs`; the `TM_*`
  variables (naming the messaging system, not the plugin; no collision with a
  telegram server's); history comments (`channel/agent-live.mjs`, the
  2.1.303 observation in `channel/README.md`, kept as recorded incidents).
  The closed list of files that still hold the old name is
  `[add-team-messaging/index.md D15, M2, M16]` (30 files at 03's commit, the
  allow-list pinned by 03's A7; 0 under `AGENTS.md`).
- **The scope hook confines a messaging window to the messaging tools
  only.** `OUR_PREFIX` and `OUR_SERVER` admit only the `messaging` server's
  tools, so a window refuses a tool of any other server, `glab-team`'s own
  future `telegram` one included (a test proves a `plugin:glab-team:telegram`
  tool is denied). **A future `glab-team` tool server must revise those two
  constants** (stated in `src/glab-team/AGENTS.md` and `channel/README.md`;
  `[add-team-messaging/index.md M1]`, `[add-team-messaging/02-rename-glab-team/plan.md D-S]`).
- **`--adopt-global` is gone.** It read 0.9 `userConfig` a new id never
  held (`M10`): `adopt`, its flag and hint, the adopt marker, the session-start
  hint, `hookOptions`' `WORKSPACE`, the bind skill's section and the
  `workspace` option were removed whole; the flag is refused
  `INVALID_BIND_ARGS` like any unknown one (`--bogus` in
  `plugin-join.test.mjs`); `git grep -c -i adopt -- src/glab-team` prints
  nothing (`[add-team-messaging/02-rename-glab-team/plan.md D-X, M-f]`).
  `hookArgs` treats a `--data-dir` value starting with an unsubstituted
  `${…}/` as unset (`D-U`); `watch.mjs` takes `--data-dir` with no such check
  (follow-up below).
- **What the rename does to an install of the earlier plugin.** Nothing is
  migrated and nothing of its data is touched (`[add-team-messaging/index.md D5]`):
  an install of `team-messaging@team-messaging-local` keeps its data
  directory and its `pluginConfigs` entries until its user uninstalls it. The
  kept credential directory lets that user run `/glab-team:messaging-bind`
  without a new invite (inferred, `evidence.md E10`; not run). `README.md`
  *Moving to glab-team*, which the feature page points to, tells the user to
  uninstall the old plugin first, since two installs run two sets of hooks; the migration
  text itself is in `src/glab-team/docs/setup.md`.
- **Contracts.** The plugin's hooks (`SessionStart`, `PreToolUse`, `Stop`,
  `StopFailure`), its MCP server and its CLI are this repo's contracts and
  change only with a plan; the source's Node suites are their gate — the
  repo's `AGENTS.md` says so in one line rather than restating them beside
  the shell hooks' contracts (`[add-team-messaging/index.md D12]`). Version
  `0.12.0` is in `plugin/.claude-plugin/plugin.json`, `plugin/package.json`,
  `plugin/package-lock.json` and `channel/version.mjs` (`channel/package.json`'s
  `0.8.1` is the channel package's own, unchanged; `D7`, `D-V`); a change
  under `plugins/glab-team/` raises it (`AGENTS.md` *Rules*). The
  SessionStart context line for the scope is capped at 125 characters (was
  120): the `glab-team messaging: ` prefix made it 123, the safety sentence
  was kept word for word, and the whole-context bound of 9500 is unchanged
  (`[add-team-messaging/02-rename-glab-team/plan.md M-d]`,
  `[add-team-messaging/02-rename-glab-team/follow-ups.md FU-2]`).
- **License and secrets.** `src/glab-team/LICENSE` (Apache-2.0) is copied
  into the plugin by the build; dependencies keep their own; no repo-wide
  `LICENSE` exists (`D9`; follow-up below). The secrets searches of `D21`
  were run at 01 on `src/glab-team` and at 03 on that and `plugins/glab-team`
  (01's (a), (b1), (b2), (b3), re-pinned for the final tree: (a) the
  fixture `channel/test/outbound-scope-rules.test.mjs:89` and the `-----BEGIN
  PRIVATE KEY-----` string of the lockfile's `jose`
  `plugins/glab-team/node_modules/jose/dist/webapi/key/import.js:18`; (b) the
  `broker.example(.com)` placeholders, seven pinned token placeholder lines
  and `broker/tokens.example.json`; `[add-team-messaging/03-publish-plugin/plan.md 03-D11, M-i]`).

## Decisions that still bind

From the user (`[add-team-messaging/master.md Request]`, `questions.md`), 2026-11-21:

- Build source: "0.11.1 rc build (Recommended)", `plugin-dist-rc` `8a4fd60`
  — superseded by "Source + build script (Recommended)": the source and
  `scripts/build-plugin.mjs` with its tests move, changes are made in source
  and rebuilt.
- Q1 (the build wired to `team-messaging@team-messaging-local`) was answered
  "Wait for upstream fix (Recommended)", then superseded by "forget about
  upstream" (above). Placement "Own plugin at plugins/team-messaging" became
  `plugins/glab-team`, "Name and id: `glab-team@glab-services`", "but specify
  messaging tools must be called `/glab-team:messaging-*`" (read as the
  skills, the only reading `/plugin:` syntax allows, `M1`).
- At step 01's review the G41 rule: "Pass if only known (Recommended)"
  (`master.md` version 3; `master.v2.md` is the version before it).
- Approvals: `master.md` v3 "Approve", base `6e2c867`; 01 "Approve" twice
  (base `5bd3648`, then `6e2c867` after the review round); 02's and 03's
  plans each approved in chat (03 twice, 2026-11-22, the second after `M-m`).

From the plan (`[add-team-messaging/index.md <id>]` unless another file is named):

- `D1` three sub-plans, built and committed in order: a verbatim import whose
  identity with the shipped build is provable, the rename as its own diff,
  then the published plugin. One plan would have mixed a 161-file copy, a
  rename through about 60 files and the new plugin's gates in one review.
- `D2` source at `src/glab-team/` (rejected: the workspace at the repo root;
  the source inside `plugins/glab-team/`). `D3` naming map as `M1`/`M11`.
  `D4` the build is committed, `node_modules/` included (rejected: building
  at install time; a gate that runs the full build — it needs the registry).
  `D5` no migration of an old install. `D6` Node.js 24 or newer and pnpm 10
  or newer; a missing one is exit 2. `D7` version `0.12.0`; `glab` keeps its
  version (0.19.1). `D8` the broker is source, not plugin. `D9` license.
  `D10` `src/glab-team/AGENTS.md` and `README.md` imported verbatim at 01,
  rewritten at 02 for a plugin that lives here; the repo's `AGENTS.md`
  governs and overrides the source's notes where they differ. `D11` the
  build writes the plugin and no marketplace file. `D12` contracts, above.
  `D13` `AGENTS.md` stays within 8800 bytes: 8461 at `5bd3648`, 8572 after 01
  (first build), 8667 after its review round, 8798 after 03, 8796 after this
  record; the cap is not raised and, but for the rewording named under
  *Records*, no existing text is cut. `D14` the Claude acceptance suites
  (`messaging:claude-hook`, `messaging:plugin-wake`) need a real session and
  an installed plugin; no gate runs them.
- `M1` (overrules `D3`'s kept list) only truly stored or wire names are kept.
  `M2` the old-name search is a closed allow-list with per-file counts.
  `M3` the suite checks read failure names, not a count. `M4` `plugin:test`
  is run once as a milestone, not gated. `M5` the committed-plugin gate is
  honest about its guarantee. `M6` G23 is written like G21, so on this host
  it is a pinned host red. `M7` the host list comes from a non-root run
  (D20), not an inference. `M8` 03 owns every change to `build-plugin.mjs`.
  `M9` a named secrets scan with pinned lines. `M10` `--adopt-global` removed.
  `M11` `D18` accepted. `M16` D15's rows allowed only at 02's milestone also
  include `channel/acceptance/plugin-wake.test.mjs:51`, 0 at 03.
  (`M12`–`M15` are in the sub-plans below.)
- `D15` the old-name search `git grep -c -P '(?<!glab-)team-messaging'` and
  its closed allow-list. `D16` G40/G41 as above. `D17` check ids and totals:
  01 adds G40, G41 (33 checks); 03 adds `plugins/glab-team` to the validate
  loop as G23 (unused since `remove-memory-sync`), G42–G44 and G45: 38
  checks; on this host `FAIL 6/38`. `D18` the `TM_*` variables are kept;
  `MAC_LABEL`, the binding keys and the options are prefixed `messaging_`;
  every entry point resolves `<data>/messaging`. `D19`
  `channel/plugin-test/package.test.mjs` is split by what it tests (`:17`,
  `:40` assert the build script and changed with it at 03). `D20` the
  non-root run: a copy of the installed workspace owned by uid 65534 under
  the plan folder (not `/tmp`), run through `setpriv --reuid=65534
  --regid=65534 --clear-groups`, compared with the root run; a failure in
  both runs that is not `::1` stops the import. `D21` the secrets searches.
  `D22` G45's offline build.
- 01 (`[add-team-messaging/01-import-source/plan.md <id>]`): `01-D1`/`M12` the
  branch stays `claude/bold-tesla-11sx3v` and is moved to `origin/main` by a
  fast-forward (the earlier PR #2 had merged; a new PR for this slug); `01-D2`
  the reporter; `01-D3` umask `0002`; `01-D4`/`01-D5` the preflight; `01-D6`
  `TMPDIR` is left as the caller set it, the tests keep their files in
  `src/glab-team/.tmp/` when it is `/tmp` and leave it empty; `01-D7` no
  `timeout` around the suites (it would orphan the runner's children; a hang
  is ended by its PID tree and is a known limit); `01-D8` the result text
  rule; `01-D9` `AGENTS.md` two pointer clauses; `01-D10` `host.example.md`
  gains a generic Node.js 24 line; `01-D12` one commit, no version raise;
  `01-D13` no repo file outside `src/glab-team/` gains an old-name hit.
  `M13` two disclosed deviations accepted as plan corrections (the non-root
  run's pre-made `.tmp` at `0755`; gate comments that do not name the slug).
  `M14` the review round's additions: suites isolated from the person's home
  and config, `AGENTS.md`'s *Gates* sentence, the host line, the reporter's two
  changes (skip/todo not listed; `\r\n` in a name become a space), the header's
  `TERM` sentence; no new harness for `tests/gates.sh` beyond a coverage list.
- 02 (`[add-team-messaging/02-rename-glab-team/plan.md <id>]`): `D-A` the
  rename is made where each name enters the code, internal identifiers stay;
  `D-D`, `D-O`, `D-B`, `D-X`, `D-M`, `D-K`, `D-V`, `D-S`, `D-U`, `D-E` as
  stated above and in the source; `D-T` four test titles changed, none
  pinned; `D-P` the five prose files rewritten, their old-name lines pinned;
  `D-R` `plugin-wake.test.mjs:61, 73` renamed; `D-L` the old-name check is a
  script in the plan folder (`oldname-check.sh`, expected-lines file).
  `M-a` a pinned G41 test whose file or title changes has its host-list entry
  renamed in the same commit (none did). `M-b` `plugin-wake.test.mjs:51`'s
  marketplace teardown name stayed at 02, renamed at 03. `M-c` the root-pinned
  tests whose bodies 02 edits were run once as uid 65534 (7/7). `M-d` the
  125-character cap. `M-e` after review round 1: the build script and install
  docs not matching the new id were answered by 03; dropping the 0.9 migration
  is the user's decision, not reopened; a fix round made the `--adopt-global`
  cases generic, reworded stale comments, re-pointed `docs/setup.md`'s line
  cites to function names, asserted the default data directory ends
  `/messaging`, and derived `PLUGIN_DATA_NAME` from `PLUGIN_ID` (exported).
  `M-f` the old-name check's D-X lines became: `git grep -c -i adopt --
  src/glab-team` prints nothing; the bad-args loop holds the generic cases.
  `M-g` only the cites review round 1 named were re-pointed; the rest are a
  follow-up.
- 03 (`[add-team-messaging/03-publish-plugin/plan.md <id>]`): `03-D1`…`03-D5`
  the build script; `03-D6` G45; `03-D7` G23, G42–G44, `MARKET` gains
  `glab-team = glab-team`; `03-D8` staging by count (3693) and tree; `03-D9`
  the `marketplace.json` entry `{"name": "glab-team", "source":
  "./plugins/glab-team", "description": "Team agent messaging: the
  /glab-team:messaging-* skills, the messaging MCP server and its hooks"}` and
  the top description "The glab workflow and the glab-team tools for Claude
  Code"; `03-D10` the source's docs name `glab-services/skills` as the install
  source, as the repo `README.md` does (one fact); `03-D11` the searches;
  `03-D12` `AGENTS.md` changes by five edits, 131 bytes (8798); `03-D13`
  `README.md` section *Moving to glab-team*; `03-D14` the `docs/one-fact.md`
  entries (the names, the holdings, the toolchain, the committed build, the
  `glab-team` version, the earlier plugin id); `03-D16` allow-list of 30 files;
  `03-D17` one commit `feat(repo): publish the glab-team plugin`; `03-D18`
  `plugin-wake.test.mjs` is not run (it parses and skips); agents never set
  `RUN_CLAUDE_ACCEPTANCE=1`. `M-h` `03-D10` accepted, and the record words the
  `AGENTS.md` entry for this file within the 8800-byte cap. `M-i` the
  secrets bullet is run as 01 defined it. `M-j` the new refusal test never
  writes into the tracked plugin. `M-k` the `.tmp/` post-condition names the
  two leftovers `claude-0/` and `node-compile-cache/`. `M-l` G45 runs both its
  diff and its package walk. `M-m` `--publish` (see *Incidents*). `M-n` the
  extra token search's two more lines are `plugins/glab-team/runtime/channel/config.mjs:27`
  and `session-start.mjs:18`, code reading `env.BROKER_TOKEN`, no literal value.
  `M-o` the review round supersedes two pinned values (`plugin:test` 9 tests;
  the README provenance line says "this repository"). `M-p` open (below).

## Known limits and not verified

- **UNVERIFIED, the user's step:** installing `glab-team@glab-services` and
  running `/glab-team:messaging-join` (and `-bind`) in a scratch project.
  `AGENTS.md` forbids an agent to install a plugin. This is the only proof of
  the MCP tool prefix `mcp__plugin_glab-team_messaging__` and of the hook
  option env names `CLAUDE_PLUGIN_OPTION_MESSAGING_*`, which are inferred from
  a reading of Claude Code 2.1.330's code (`[add-team-messaging/02-rename-glab-team/result.md Claims]`);
  if the real prefix differs, the scope hook's `OUR_PREFIX` would deny the
  messaging tools. The integrator's `claude --plugin-dir plugins/glab-team
  plugin details glab-team` loaded the plugin (`glab-team 0.12.0`, Skills 5,
  Hooks 4, MCP 1), which proves its inventory and no model session.
- **UNVERIFIED:** the acceptance suites `messaging:claude-hook` and
  `messaging:plugin-wake` (a logged-in `claude` session and an installed
  plugin; `plugin-wake.test.mjs` parses and skips under the gates; D14).
- **UNVERIFIED:** that `glab-services/skills`, the public install source the
  `README.md` and the source's docs name, serves `glab-team` — only once the
  user mirrors this change there (`03-D10`; same fact as
  `[docs-mirror/record FU-DM-R5]` in `docs/specs/marketplace.md`).
- **Inferred:** that the credential directory kept for the old plugin lets
  its user bind under the new id without a new invite (`evidence.md E10`).
- **Inferred, `watch.test.mjs`:** the orphan-claim test ("an orphan whose host
  dies right after its claim undoes the claim, and the resumed watcher wakes
  for it") failed once in the full non-root run and passed in two single-file
  reruns and both gate runs, so it is read as load-flaky, not as a host red
  (`01-import-source/result.md P6`).
- **Host facts** (this host, `c100700`): the gates need Node.js 24 first on
  `PATH` (`PATH=/opt/node24/bin:$PATH`; the default `node` is 22). `bash
  tests/gates.sh` there prints `FAIL 6/38`: G14, G19, G21, G22, G38 (the five
  baseline reds, `plan/remove-memory-sync/gates-final.log`, shellcheck 0.9.0,
  the `√` validate glyph and an empty `LANG`) and G23 (`plugin validate
  --strict plugins/glab-team`: last line `[√ Validation passed]`, no `; rc=`,
  the same glyph cause as G21/G22, `M6`); G40–G45 `ok` (G40 `known host reds
  0`, G41 the nine, G45 `packages 95`). The manager's final check, round 1
  (6b) on `c100700`: CONFORMS, all five goals served, those six reds. On a
  host where the baseline is green it prints `PASS 38/38`. UNVERIFIED that the
  six are pre-existing on the merge base `abee3ee`: the integrator matched
  the set and G23's cause against the expected list but did not run
  `gates.sh` there (`03-publish-plugin/integration.md`).
- A non-root run with a fresh `src/glab-team/.tmp` under umask `0002` gets
  `INSECURE_CREDENTIAL_DIR` failures (the tests create `.tmp` `0775` and the
  credential check refuses a group-writable ancestor); the host list is for
  the root reference host. The suites were proven on Node.js 24.22.3, pnpm
  10.28.0 only; the reporter's `test:summary` on 24.22.3 only. G40/G41 have no
  timeout (`01-D7`): a hang is ended by its PID tree.
- `G40`/`G41` `ok` does not check the `fail` plus `cancelled` counts against
  the number of failure lines (follow-up below); a failing `todo` test is
  unreported by design (reporter).
- The `src/glab-team/.tmp/` leftovers `claude-0/` and `node-compile-cache/`
  pre-date 03 and are left (`M-k`).

## Open follow-ups

- [add-team-messaging/01-import-source/plan.md M15 a] G40/G41 `ok` does not
  check the `fail`+`cancelled` counts against the number of failure lines (a
  dropped nameless failure would still read `ok`; `tests/gates.sh` near
  `:512` at 01) — open.
- [add-team-messaging/01-import-source/plan.md M15 b] `tests/gates.sh` comments
  cite plan files (`:111`, `:118` at 01; M14 (6)): cite the spec instead now
  that it exists — open.
- [add-team-messaging/01-import-source/plan.md M15 e] one-run load flake in
  `channel/test/watch.test.mjs` as non-root (see above) — open.
- [add-team-messaging/01-import-source/result.md Follow-ups 1] a non-root host
  with a fresh `src/glab-team/.tmp` under umask `0002` gets
  `INSECURE_CREDENTIAL_DIR` reds; not changed in the gate — open.
- [add-team-messaging/01-import-source/plan.md M14 G38] G38's shellcheck red
  (shellcheck 0.9.0) is a host red the unchanged tree has — open as a host
  fact, not this change's.
- [add-team-messaging/02-rename-glab-team/follow-ups.md FU-1] `channel/plugin-config.mjs`
  (`pluginAdapter` header comment) and `docs/setup.md` (join section) still say
  "a 0.9 global workspace never blocks"; under the new id no 0.9 global binding
  can exist, both sentences are history — open (left as is).
- [add-team-messaging/02-rename-glab-team/plan.md F-02a] `watch.mjs` takes
  `--data-dir` with no unset check, so an unsubstituted value, with or without
  `/messaging`, is used as a relative path (`D-U` covers `hookArgs` only) — open.
- [add-team-messaging/02-rename-glab-team/plan.md M-g] the other
  `channel/*.mjs:<n>` cites in `src/glab-team/docs/setup.md` (lines 21, 23, 36,
  169, 176, 192, 223, 300, 348, 374, 420–423, 464, 477, 579, 804, 807,
  812–825 at 02) should be re-pointed to function names — open.
- [add-team-messaging/03-publish-plugin/plan.md M-p] `build-plugin.mjs` removes
  its `<out>.build-<pid>` staging directory only through `fail()`; an uncaught
  throw after staging or a `SIGINT` leaves it behind (under `--publish`,
  inside `plugins/`); fix with `try/finally` or an exit handler. No test
  covers the rename onto an existing empty `plugins/glab-team` (inferred from
  POSIX rename semantics, not run) — open.
- [add-team-messaging/index.md D9] no repo-wide `LICENSE` file (the plugin
  and the source carry Apache-2.0; the repo has none) — open, outside the request.
- [add-team-messaging/03-publish-plugin/plan.md 03-D10] the install source in
  the docs and `README.md` is `glab-services/skills`; the plugin reaches users
  only once mirrored there — open (the user's call; `FU-DM-R5` in
  `docs/specs/marketplace.md`).
- [add-team-messaging/02-rename-glab-team/plan.md F-03b]
  `channel/README.md` *M12: plugin* was to name the build's output path and
  `--no-install` if documented: 03's P11 edited `channel/README.md`; that
  it does so is not re-checked here — open until read.
- [add-team-messaging/03-publish-plugin/result.md B0 round] the `plugin-wake`
  acceptance test cannot be run by an agent; its real run is the user's — open.
- [add-team-messaging/03-publish-plugin/integration.md] the `G16` `T49` signal
  test (`plan-gate`, `HUP`) failed once in one full run and not in the rerun
  (`nohup` makes `HUP` ignored: two early 01 runs under `nohup` showed the
  same) — open as a known flake of an untouched script.

## Closed follow-ups

- [add-team-messaging/02-rename-glab-team/plan.md F-03a] `plugin-wake.test.mjs:45-46, 51` installed from and
  removed the build's old marketplace: closed by 03 (P4, `plugin-wake.test.mjs:44-51`
  now writes its own scratch marketplace `glab-services` with `glab-team` at
  `./plugins/glab-team`); the old-name count there is 0.
- [add-team-messaging/02-rename-glab-team/plan.md F-rec] this spec states
  `D-D`, `D-O`, `D-B`, `D-X`, `D-S`, the names and the unverified tool prefix —
  closed by this record.
- [add-team-messaging/02-rename-glab-team/follow-ups.md FU-2] the 125-character
  scope-line cap — closed by this record (stated above, `M-d`).
- [add-team-messaging/01-import-source/plan.md M15 c] the coverage list lives
  in `result.md` only — closed: it is carried under *Records*.
- [add-team-messaging/01-import-source/plan.md M15 d] the gates need Node.js
  24 first on `PATH` on this host — closed by this record (above, host facts;
  `host.example.md` carries the Node.js 24 line).
- [add-team-messaging/03-publish-plugin/plan.md 03-D12] the bytes `AGENTS.md`
  had left for this spec's entry — closed by this record: 8796 bytes, the entry
  fitted by rewording the `memory-sync.md`/`external-agents.md` clause (`M-h`).
- [add-team-messaging/03-publish-plugin/plan.md M-n] `x2`'s two extra lines —
  accepted as a correction of its expected set, not a secret.

## Incidents

- **01, the never-green review finding (`G41`).** At step 01's review the
  pinned-count rule made G41 red when the failures equalled the pinned 9 and
  red on a clean host because 0 differs from 9, so it could never pass. The
  user chose "Pass if only known (Recommended)": `ok` when every failure is in
  the host list, zero included, `FAIL` on any failure outside it
  (`[add-team-messaging/01-import-source/plan.md 01-D8]`, `questions.md`
  of the master). The same review found the suites could read and write the
  person's home and `~/.claude` (the CLI's data directory falls back to
  `$HOME/.claude`, `channel/cli.mjs`) and that `AGENTS.md`'s *Gates* sentence
  said the opposite of the script: both fixed (`M14`).
- **01, the non-root run.** As written, P1's run failed 19 channel tests with
  `INSECURE_CREDENTIAL_DIR`: the tests created `$N/ws/.tmp` `0775` under umask
  `0002` and the credential check refuses a group-writable ancestor. The
  builder pre-created it `0755` and re-ran (`M13`).
- **01, the slug in comments.** The plan asked gate comments to name the plan
  folder, which put `team-messaging` into `tests/gates.sh` against `01-D13`;
  they were reworded without the slug (`M13`).
- **01, the signal-test flake under `nohup`.** Two early A1 runs started with
  `nohup` showed an extra `FAIL G16` (T49): `nohup` makes `HUP` ignored; the
  rerun without it was clean.
- **02, PLAN WRONG: the old-name check against `M-e`.** After review round 1
  the fix round made the `--adopt-global` cases generic and removed the extra
  one, as `M-e (3)` required; `oldname-check.sh` still pinned lines 79–80 (the
  `--adopt-global` list and one `adopt` hit) in `plugin-join.test.mjs`, so it
  printed `OLDNAME FAIL`. The builder stopped; `M-f` amended the check (no
  `adopt` text under `src/glab-team`; the generic cases present). Conformance
  stood as CONFORMS.
- **02, a plan gap, FA-16.** `scope-hook.test.mjs` "the largest SessionStart
  context stays 500 characters under the host limit (FA-16)" capped the SCOPE
  line at 120; the `glab-team messaging: ` prefix made it 123. The cap went
  to 125 (`M-d`).
- **03, PLAN WRONG: `../../` in `package.json`.** P2 set `plugin:build` to a
  line carrying `../../plugins/glab-team`. The channel test `accepts project
  content` (`outbound-scope-rules.test.mjs`) sends `package.json` through the
  outbound-scope rule `parent_escape` (`channel/outbound-scope.mjs`), which
  refuses `..` paths: G41 gained a red outside the host list (`FAIL 7/38`
  against the planned 6). The developer stopped. `M-m` added `--publish`, which
  resolves the output itself, so `package.json` holds no `..` and the fixture
  stayed unchanged (inferred cause, not re-run with P2 reverted; the fix was
  proven by "accepts project content" `pass 1 fail 0`).
- **03, a stalled G41.** An earlier gate attempt hung in G41 for 24 minutes on
  a `scope-hook.mjs` child; the developer ended that run's processes by PID and
  removed `src/glab-team/.tmp/plugin-Z38sCM`. It did not reproduce on the rerun
  (cause not found; `01-D7` says a hang is ended by its PID tree).
- **03, review round 1 (fix round).** A half-built output could replace a
  committed plugin; `--out` could be a file or a symlink out of the admitted
  roots; the README provenance line named the old repo; `docs/one-fact.md`
  carried an extra bullet. Fixed: staging directory then rename, a directory
  check, `realpathSync` on the roots, the line reworded, the bullet folded
  (`plugin:test` 9 tests). Round 2 SHIP; `M-p` is what it left.
- **03, G45 negative proof.** With one byte changed in
  `runtime/channel/version.mjs` and `zod` 4.6.8 for 4.6.7 the gate printed
  `FAIL 7/38` with its reason `differs from the build [diff -r …version.mjs …];
  node_modules [missing node_modules/zod zod@4.6.7,unexpected
  node_modules/zod zod@4.6.8]`, then restored (`git diff --quiet --
  plugins/glab-team` rc 0).

## Records

- 2026-11-22 · add-team-messaging · 5dee913 · c100700 · claude/bold-tesla-11sx3v · https://github.com/glab-services/skills-marketplace/pull/4 (the PR field is edited when it exists)
  - Commits → `5dee913` `feat(repo): import the team messaging source into src/glab-team` (01), `abee3ee` `feat(repo): rename the team messaging source to glab-team` (02), `c100700` `feat(repo): publish the glab-team plugin` (03); the push `5bd3648..c100700  claude/bold-tesla-11sx3v -> claude/bold-tesla-11sx3v`; the branch continues `6e2c867`, the merge of PR #2. A squash or rebase merge can give the commits new shas: look up the branch and the PR.
  - [add-team-messaging/master.md Goals] G1–G5 → served: the manager's final check (6b) round 1, CONFORMS. Sub-plan records: 01 CONFORMS then review round 2 SHIP; 02 CONFORMS after a delta (`M-g`); 03 CONFORMS after a delta, review round 2 SHIP.
  - Decisions → `D1`–`D22`, `M1`–`M16` of `index.md`, 01's `01-D1`–`01-D13`, `M12`–`M15`, 02's `D-A`…`D-E`, `M-a`…`M-g`, 03's `03-D1`…`03-D18`, `M-h`…`M-p`, above.
  - Gates → the manager's run on `c100700`'s tree, `PATH=/opt/node24/bin:$PATH`, `TMPDIR=/tmp`, `CLAUDE_CONFIG_DIR` a new empty directory: `FAIL 6/38`, host reds G14, G19, G21, G22, G23, G38; `ok` G40–G45. Per sub-plan: 01 `FAIL 6/33` (first build, G41 as pinned), then `FAIL 5/33` after the review fix; 02 `FAIL 5/33` identical to its `gates-before.log`, `plugin:test` 7/7, the uid-65534 run 7/7; 03 `FAIL 6/38`, `plugin:test` 9/9, `jq -r '.plugins[].name'` prints `glab`, `glab-team`, `claude plugin validate --strict plugins/glab-team` `√ Validation passed`. This record ran no gate that reads Markdown: it changed `docs/specs/*.md`, `docs/features/glab-team.md` and `AGENTS.md`'s `plan/` rule line; `AGENTS.md` is 8796 bytes (`wc -c`).
  - Coverage (shell: a list, `AGENTS.md` *Tests*) → 01: G40 ok path, G41 ok-with-known path, outside-list path (a copied script with one made-up entry), the reporter on a four-test file, a caller's reporter in `NODE_OPTIONS`, the three preflight refusals, `shellcheck`; not covered and accepted: the `no summary line` and `no failure lines` branches, a failed `mkdir`, a host with no channel red, a blank in a caller's `--test-reporter` value. 02: the tests listed under S1–S10 in its `result.md`, run as the gates' G41 and as uid 65534; not covered: prose, the real tool prefix, `plugin-wake`. 03: `package.test.mjs` (two updated tests, one new, one for the review round), G42–G44 positive, G45 positive and negative (a byte, a package version); not covered: G45's execute-bit branch and the trap on `INT`/`TERM`/`HUP`.
  - Not verified → the user's install step, the MCP tool prefix and hook env names, the acceptance suites, that `glab-services/skills` serves the plugin, the six host reds on the merge base, above under *Known limits and not verified*.
  - Follow-ups → open: the items above under *Open follow-ups*; closed here: `F-03a`, `F-rec`, `FU-2`, `M15 c`, `M15 d`, `03-D12`.
  - Incidents → above under *Incidents*; the others in `docs/specs/marketplace.md`.
  - Security → no secret, bucket, endpoint or profile in any file; the secrets searches of 01 and 03 printed only their pinned lines (the fixture, the `jose` PEM string, the `broker.example` placeholders); no hook contract of the shell scripts changed; `AGENTS.md` *Rules* gained one line saying the plugin's hooks, MCP and CLI change only with a plan and that its Node suites gate them.
  - Old-name hits → this record counts its own: see *Records* in `docs/specs/marketplace.md`.
  - Feature page → `docs/features/glab-team.md`.
  - Record → this record, in this file, `docs/specs/marketplace.md` and `docs/features/glab-team.md`, plus the `plan/` rule line of `AGENTS.md`; no audit file. The plan folder holds `master.md` (version 3) with `master.v1.md`, `master.v2.md`, `master.r1.md`, `master.r2.md`, `index.md` with `index.r1.md`–`index.r3.md`, `evidence.md` with `evidence.r1.md`, `evidence.r2.md`, `evidence.v1.md`, `plan.v1.md` (the first version of the slug), `questions.md`, and the three sub-plan folders, each with its `plan.md`, round copies, `evidence.md`, `result.md`, `integration.md`, gate logs, and for 01 and 02 the probes and the old-name check (history; the items are taken from the current files).
