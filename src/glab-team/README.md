# glab-team source

Team agent messaging for Claude Code: a broker that routes messages between
agent sessions, a channel MCP server with hooks and a CLI, and the
`glab-team` Claude Code plugin that bundles the channel. This folder is the
source of the plugin; its messaging skills are `/glab-team:messaging-*`.

- [broker/README.md](broker/README.md): the broker, its HTTP API, storage,
  retention and operations.
- [channel/README.md](channel/README.md): the channel MCP server, hooks, CLI and
  the plugin.
- [docs/setup.md](docs/setup.md): step-by-step setup: the first identity,
  workspaces, topics, invites, joining and switching a bound plugin.

## Install the plugin

The plugin installs from this repository's marketplace:

```sh
claude plugin marketplace add glab-services/skills
claude plugin install glab-team@glab-services --scope local
```

See the M12 section of [channel/README.md](channel/README.md) for joining and
binding. If an earlier plugin under another name is installed, read the
section on moving from the earlier plugin in [docs/setup.md](docs/setup.md) first.

## Development

Node.js 24+ and pnpm:

```sh
pnpm install --frozen-lockfile
pnpm broker:test
pnpm channel:test
```

[AGENTS.md](AGENTS.md) lists the gates for each area.

The plugin in the repository's `plugins/glab-team/` is this folder's build; `AGENTS.md` says how to rebuild it.

## Provenance

This source was brought into this repository from
glab-services/claude-plugins at `441887c` and is maintained here, with no upstream.

This code was imported from a private source repo at afb35c6, without its
history. Commit SHAs and "decision N" references in code comments and READMEs
refer to that private source repo's history and plan; they are kept verbatim
because they record why the code is the way it is.
