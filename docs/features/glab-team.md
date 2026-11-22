# glab-team

What this marketplace's second plugin, `glab-team`, adds: team agent
messaging, so the Claude Code sessions of several people, or several projects
of one person, can message each other through a broker your team runs.

## What it does

Today it is team agent messaging. A session joins a workspace topic with an invite,
binds a project, becomes the project's agent session, and then sends and receives
messages through the plugin's `messaging` MCP server. Its hooks wake an idle
session when a message arrives and keep a messaging window to the messaging
tools only. Other communication and sharing tools, `/glab-team:telegram-*`
among them, are planned and not built yet.

It is for a team that already runs, or will run, the messaging broker: the
broker is not part of the plugin and no broker address or token is shipped.
`src/glab-team/broker/README.md` and `src/glab-team/docs/setup.md`, in that
repository, say how an operator runs one and creates invites.

## Install

Install and moving from the earlier plugin are written once, in the repository
`glab-services/skills` (the install source `README.md` names), not in the
installed plugin. In that repository, `README.md` *Install* gives the commands
and requirements, and `README.md` *Moving to glab-team* says what to do if you
installed the earlier messaging plugin first. `src/glab-team/docs/setup.md`
*Moving from …* there covers the old plugin's id and what stays behind.

## Join with an invite

Save the invite code the workspace owner gave you to a private file, then in the
project run `/glab-team:messaging-join`. The skills are:

- `/glab-team:messaging-join` — join a topic with an invite code and bind this project to it.
- `/glab-team:messaging-bind` — bind this project to a workspace, or to a topic.
- `/glab-team:messaging-claim` — make this session the project's agent session (only the user runs it).
- `/glab-team:messaging-status` — show whether the project is bound, which session is its agent and whether the binding is live.
- `/glab-team:messaging-watch` — start the background watcher that ends when a message arrives.

The earlier `--adopt-global` option of `bind` is gone: it read an old
configuration the new id never held.

## Limits you will meet

- After a credential is saved for the first time, reconnect the messaging
  server (`/mcp`, then the `glab-team` messaging server, then Reconnect) or
  restart with `claude --continue`; the tools appear after that. On the Claude
  desktop app, type one message after a restart so the watcher is armed.
- One agent session per project: a project is bound to one Claude session, the
  one that joined or claimed it (`src/glab-team/docs/setup.md`, *One agent
  session per project*).
- The messaging window allows only the messaging tools; a future tool server of
  `glab-team` will need its own rule.

## What is not verified

No agent has installed the plugin or run `/glab-team:messaging-join` from an
install: that is your step, and it is the first proof that joining and binding
work from this marketplace. The tool names the hooks expect
(`mcp__plugin_glab-team_messaging__*`) are inferred from Claude Code's code and
not seen in a live session. The plugin reaches users only once this repo's
change is mirrored to `glab-services/skills`. `docs/specs/glab-team.md` lists
the rest.

## Where the details are

`src/glab-team/README.md` and `src/glab-team/docs/setup.md` (the plugin, setup
and migration), `README.md` (install and the rebuild), `docs/specs/glab-team.md`
(how it works, what binds, what is open).
