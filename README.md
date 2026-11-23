# skills

A Claude Code plugin marketplace, `glab-services`, with three plugins.

| Plugin | What it is |
|---|---|
| `glab` | The full workflow. A manager session dispatches agents through plan → develop → analyze → integrate → review → commit → record → push. It has a product level above the project level, and hooks for the session start, the context size and each level's skills. |
| `glab-slim` | The fast project flow: plan → develop → review → commit → push through four agents, with each plan opening its GitHub issue. No hooks. Install it **instead of** `glab`, not beside it. |
| `glab-team` | Team agent messaging: skills `/glab-team:messaging-*`, an MCP server and hooks that wake an idle agent session when messages arrive. Needs Node.js 24 or newer. |

What each plugin holds, by name, is in `docs/specs/marketplace.md`.

## glab in short

- **Agents and models.** The planner, the product planner and the product analyzer run on Opus. The analyzer, developer, reviewer and integrator run on Sonnet, and the committer on Haiku. Tell the manager another model for a role and it passes that one instead.
- **Plan files.** Each change's working files are in `plan/<slug>/`, which is ignored by git:
  - `master.md`: your request in your words and its goals, constant once approved;
  - one `plan.md`, or sub-plans.
- **Record.** Before the push, what stays true is recorded in `docs/specs/<area>.md` and `docs/features/<feature>.md`.
- **Rounds.** Every check stage runs at most two rounds; after that you decide.
- **Context.** The context hook adds about ten tokens per message and tells you when the context passes 300k, then every further 100k. Set `GLAB_COMPACT_AT=<thousands>` before starting Claude Code to move the first step.
- **Levels.** `glab-level: product` in a repo's `AGENTS.md` makes its sessions product sessions; no line keeps the project level. The levels share plain files in a store folder or a git clone, named by `glab-shared-store:`.
  - How the loop works: `docs/specs/product.md`.
  - Setting up a store clone: `docs/features/remote-store.md`.
  - Trying the loop: `docs/features/product-loop.md`.
- **Docs mirror.** CI templates publish a code repo's `docs/` to a read-only `<repo>-docs` repository: `docs/features/docs-mirror.md`.
- **Level guard and its known limits:** `docs/features/level-guard.md`.

## Requirements

Linux with bash. `jq` is optional: without it the hooks fall back to plain text, or say nothing. A store clone needs `git`. macOS is not supported.

## Install

This marketplace is private. Claude Code runs `git` with your machine's own credentials and never prompts, so first you need:
- read access to `glab-services/skills`;
- an SSH key loaded in `ssh-agent`, or `gh auth login` followed by `gh auth setup-git`.

1. For `glab`, create `~/.claude/host.md` from `host.example.md` and edit it for the machine: the temp directory and tool paths.
2. Add the marketplace and install what you use:

   ```bash
   claude plugin marketplace add glab-services/skills
   claude plugin install glab@glab-services
   claude plugin install glab-team@glab-services --scope local
   ```

   For `glab-team`, joining a broker and binding a project are in `src/glab-team/docs/setup.md`.

`claude plugin update glab@glab-services` fetches a newer version. A change that did not raise the version is not delivered.

**For a team,** set `extraKnownMarketplaces` (`"glab-services": {"source": {"source": "github", "repo": "glab-services/skills"}}`) and `enabledPlugins` (`"glab@glab-services": true`) in managed settings or a repo's `.claude/settings.json`. Each person still needs the access above.

Coming from an older setup (`team-messaging`, names before 0.15.0, `memory-sync`, the copy install)? See `docs/upgrading.md`.

## Working on this repo

`AGENTS.md` is the working agreement, and it names the gates: `bash tests/gates.sh`, green at `PASS n/n`. The layout:

| Path | What it is |
|---|---|
| `.claude-plugin/marketplace.json` | lists the plugins |
| `plugins/` | the plugins. `plugins/glab-team/` is built from `src/glab-team/`, never edited by hand |
| `src/glab-team/` | the team messaging source and its Node tests (`docs/specs/marketplace.md` *Working on `src/glab-team`*) |
| `tests/` | the scripts' tests and `tests/gates.sh` |
| `docs/specs/`, `docs/features/` | one spec per area, one page per feature |
| `docs/one-fact.md` | each fact more than one file states, and those files |
| `host.example.md` | the template for `~/.claude/host.md` |

To try a change without installing, run `claude --plugin-dir ./plugins/glab` (or `./plugins/glab-slim`, or `./plugins/glab-team`). Pass the plugin's folder, not the repo root.
