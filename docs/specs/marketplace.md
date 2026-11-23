# Marketplace — spec

The `glab-services` marketplace as of 2026-11-23: its plugins, the repo's layout, and its gates. The rules for working in this repo are in `AGENTS.md`, and the facts several files state are in `docs/one-fact.md`. This page does not repeat them.

**History.** Until 2026-11-23 this file was a 208 KB log of every change. It is kept in git, not here: `git show dcfb2ff:docs/specs/marketplace.md`. Older records that cite a section of this file mean that version.

## The plugins

| Plugin | Version | Source | What it is |
|---|---|---|---|
| `glab` | 0.21.0 | `plugins/glab/` | the full workflow: the product and project levels, 25 skills, 8 agents, 5 hook events |
| `glab-slim` | 0.2.0 | `plugins/glab-slim/` | the fast project flow: 7 skills, 4 agents, no hooks. Install it instead of `glab`, not beside it |
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
| G21–G23, G46 | `claude plugin validate --strict` on `glab`, the marketplace, `glab-team` and `glab-slim` |
| G24–G26 | `glab`'s skills, agents and hook events |
| G30, G31, G35 | marketplace names, no `user_config` in hooks, no prefixed `name:` |
| G33, G34 | each agent's model and preloaded skills, pinned |
| G40, G41 | `glab-team`'s Node suites |
| G42–G45 | `glab-team`'s components, and that `plugins/glab-team` is the build of `src/glab-team` |

Each check's expected value and its reason are in the script itself.

## Known limits

- G40 and G41 call `pnpm --silent`, not `-s`: pnpm 12 rejects `-s` (seen 2026-11-23 with pnpm 12.5.1).
- The Markdown payload has no gate. A change to it is checked by running what it prescribes, and by searches.
