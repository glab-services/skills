# skills

A Claude Code plugin marketplace, `glab-services`.

| Plugin | What it is |
|---|---|
| `project` | The project workflow. A manager session dispatches four agents through plan → develop → review → commit → push, and each plan opens its GitHub issue. Sensitive work (data, formats, auth, secrets, money) adds your approval of the plan and a second, blind reviewer. It takes briefs from `product`. No hooks. |
| `product` | The product level. A product plan becomes product rules and one brief per project in a shared store, and each project's plan gets a verdict before it is built. No hooks. |
| `glab-team` | Team agent messaging: skills `/glab-team:messaging-*`, an MCP server and hooks that wake an idle agent session when messages arrive. Needs Node.js 24 or newer. |
| `glab` | **Archived:** the earlier full workflow, 0.21.0, kept as it is. Use `project` and `product` instead, not beside it. |

What each plugin holds is in `docs/specs/marketplace.md`.

## The workflows in short

- **Choosing a level.** Install `project` in a code repo and `product` in a product repo. Installing one is choosing its level.
- **Plan files.** A change's working files live in `plan/<slug>/`, which is ignored by git:
  - `plan.md`, plus `master.md` only for a plan made from a brief;
  - the developer's `result.md`.
- **Agent names.** Every agent dispatch is named `<agent>: <area>: <what>`.
- **Rounds.** Review gets one fix round; after that you decide.
- **The manager's gate.** The manager runs the repo's gates itself, once, on the final tree.
- **Pushes.** The session's own branches and a stage branch it pushes and merges itself. Nothing reaches `main` or a release branch without your word.
- **Specs.** `docs/specs/<area>.md` says how an area works now, in at most about 10 KB, and never collects history.
- **The product ⇄ project loop.** The levels share plain files in a store folder or a git clone, named by a `glab-shared-store:` line.
  - How it works: `docs/specs/product.md`.
  - Setting up a store clone: `docs/features/remote-store.md`.
  - Trying it: `docs/features/product-loop.md`.
- **Docs mirror.** The archived `glab` ships CI templates that publish a code repo's `docs/` to a read-only `<repo>-docs` repository: `docs/features/docs-mirror.md`.

## Requirements

Linux with bash. `jq` is optional: without it the hooks fall back to plain text, or say nothing. A store clone needs `git`. macOS is not supported.

## Install

This marketplace is private. Claude Code runs `git` with your machine's own credentials and never prompts, so first you need:
- read access to `glab-services/skills`;
- an SSH key loaded in `ssh-agent`, or `gh auth login` followed by `gh auth setup-git`.

1. Create `~/.claude/host.md` from `host.example.md` and edit it for the machine: the temp directory and tool paths.
2. Add the marketplace and install what you use:

   ```bash
   claude plugin marketplace add glab-services/skills
   claude plugin install project@glab-services   # in a code repo
   claude plugin install product@glab-services   # in a product repo
   claude plugin install glab-team@glab-services --scope local
   ```

   For `glab-team`, joining a broker and binding a project are in `src/glab-team/docs/setup.md`.

`claude plugin update project@glab-services` fetches a newer version. A change that did not raise the version is not delivered.

**For a team,** set `extraKnownMarketplaces` (`"glab-services": {"source": {"source": "github", "repo": "glab-services/skills"}}`) and `enabledPlugins` (`"project@glab-services": true`) in managed settings or a repo's `.claude/settings.json`. Each person still needs the access above.

Coming from `glab`, or an older setup (`team-messaging`, names before 0.15.0, `memory-sync`, the copy install)? See `docs/upgrading.md`.

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

To try a change without installing, run `claude --plugin-dir ./plugins/project` (or `./plugins/product`, or `./plugins/glab-team`). Pass the plugin's folder, not the repo root.
