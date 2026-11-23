# Marketplace — spec

The `glab-services` marketplace as of 2026-11-23: its plugins, the repo's layout, and its gates. The rules for working in this repo are in `AGENTS.md`, and the facts several files state are in `docs/one-fact.md`. This page does not repeat them.

**History.** Until 2026-11-23 this file was a 208 KB log of every change. It is kept in git, not here: `git show dcfb2ff:docs/specs/marketplace.md`. Older records that cite a section of this file mean that version.

## The plugins

| Plugin | Version | Source | What it is |
|---|---|---|---|
| `project` | 0.3.1 | `plugins/project/` | the project workflow: 7 skills, 4 agents, no hooks, a copy of `plan-gate.sh` |
| `product` | 0.1.0 | `plugins/product/` | the product level: its skills, 3 agents, no hooks, a copy of `plan-gate.sh` |
| `glab` | 0.21.0 | `plugins/glab/` | archived: the earlier full workflow, 25 skills, 8 agents, 5 hook events, kept as it is |
| `glab-team` | see its `plugin.json` | `plugins/glab-team/`, built from `src/glab-team/` | team agent messaging: 5 skills, an MCP server, 4 hook events |

`.claude-plugin/marketplace.json` lists them. G30 checks that each entry's name matches its `plugin.json`.

## The gates

`bash tests/gates.sh` runs every check and ends with `PASS n/n` when all pass. It needs:
- `TMPDIR` set to the host's temp directory;
- `claude` on `PATH`, or `CLAUDE_BIN`;
- Node.js 24 or newer;
- pnpm 10 or newer;
- `src/glab-team` installed from its lockfile.

| Checks | What |
|---|---|
| G1–G11, G36–G37 | each script and test parses and is executable |
| G14, G38 | `shellcheck` |
| G15–G19, G39 | the script tests: context-size, plan-gate, manager-bootstrap, product-loop, level-guard, docs-mirror |
| G21–G23, G46, G47 | `claude plugin validate --strict` on `glab`, the marketplace, `glab-team`, `project` and `product` |
| G48 | the copies of `plan-gate.sh` and the security skill are byte-identical to their source |
| G24–G26 | `glab`'s skills, agents and hook events |
| G30, G31, G35 | marketplace names, no `user_config` in hooks, no prefixed `name:` |
| G33, G34 | each agent's model and preloaded skills, pinned |
| G40, G41 | `glab-team`'s Node suites |
| G42–G45 | `glab-team`'s components, and that `plugins/glab-team` is the build of `src/glab-team` |

Each check's expected value and its reason are in the script itself.

## Known limits

- G40 and G41 call `pnpm --silent`, not `-s`: pnpm 12 rejects `-s` (seen 2026-11-23 with pnpm 12.5.1).
- The Markdown payload has no gate. A change to it is checked by running what it prescribes, and by searches.

## Working on `src/glab-team`

`src/glab-team/` is a pnpm workspace of its own. `tests/gates.sh` runs its two Node.js suites, `pnpm --silent broker:test` and `pnpm --silent channel:test`. Before any check the script needs Node.js 24 or newer as the `node` first on `PATH`, pnpm 10 or newer on `PATH`, and the workspace installed from its lockfile. Without any of them it stops with one line on stderr and exit 2. A host whose default `node` is older puts Node.js 24's `bin` first on `PATH`, as its host file says. Run `pnpm install --frozen-lockfile` in `src/glab-team` once, and again after `src/glab-team/pnpm-lock.yaml` changes; the install needs the npm registry, the gates do not, and `src/glab-team/.gitignore` ignores `node_modules/`. The suites take about one and two minutes and run with umask `0002`, because some tests make a group-writable directory and expect it to stay so. Each is `ok` when every failed or cancelled test is in its host list in `tests/gates.sh` — the tests that fail on the reference host, which has no IPv6 and runs as root, each with its reason — and its `ok` line names the known ones it saw; a failure outside the list is a `FAIL` that names it. The suites run with an empty home and Claude Code config directory of their own under the gates' work directory, never yours. With `TMPDIR` under `/tmp` the tests keep their temp files in `src/glab-team/.tmp/`, ignored too, and leave it empty.

`plugins/glab-team/` is what `src/glab-team/scripts/build-plugin.mjs` writes from the source, `node_modules/` included, because an install copies the directory and runs no install. To change the plugin, change the source, raise its version as `src/glab-team/AGENTS.md` says, remove `plugins/glab-team/` and run `pnpm --silent plugin:build` in `src/glab-team`, with the npm registry reachable and `claude` on `PATH` under a new empty `CLAUDE_CONFIG_DIR`; the build refuses a directory that is not empty. `tests/gates.sh` checks the result: G23 validates it, G42–G44 compare its `plugin details` lines, and G45 builds the source again offline (`--no-install`) into a new directory under `src/glab-team/dist/`, removed after, and fails on any difference outside `node_modules/` — a byte, a file missing or added, an execute bit — and on a `node_modules/` whose packages differ from `src/glab-team/plugin/package-lock.json` by path, name or version. G45 does not read the files inside a package: a file edited in a package of the right version passes. A fresh build compared byte for byte, `node_modules/` included, needs the registry and is not a gate.
