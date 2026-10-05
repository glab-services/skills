# skills

Our global Claude Code setup: the skills, agents and slash commands that run
every session, plus the global instructions and the two hook scripts they rely on.

## Installed to `~/.claude`

Each path here installs to the same path under `~/.claude`.

| Path | What it is |
|---|---|
| `skills/` | `bootstrap`, `manager`, `security`, `comments`, `plan-first`, `audit`, `sync-memory` |
| `agents/` | `developer`, `analyzer`, `integrator`, `reviewer`, `committer` |
| `commands/` | `/plan`, `/develop`, `/analyze`, `/integrate`, `/review`, `/commit`, `/push`, `/ship` |
| `CLAUDE.md` | Global instructions — loads `bootstrap` first in every session |
| `manager-bootstrap.sh` | `SessionStart` hook that injects the session bootstrap reminder |
| `memory-sync.sh` | Hook script that syncs Claude Code memories to and from S3 |

The skills, agents and commands are one set: `manager` dispatches the agents
through the commands, and every agent carries `security` and `comments`.

## Repo only

Not installed. These are for working on this repo and for setting up a machine.

| Path | What it is |
|---|---|
| `AGENTS.md` | Working agreement for changes to this repo |
| `settings.example.json` | Hook and environment wiring to merge into `~/.claude/settings.json` |
| `host.example.md` | Template for the per-machine `~/.claude/host.md` |
| `tests/` | Stub-based test for `memory-sync.sh` |
| `plan/` | Planning records |

The root `CLAUDE.md` is payload. Working on this repo itself is governed by `AGENTS.md`.

## Requirements

Linux with bash, GNU coreutils (`timeout`, `stat`, `date`), util-linux `flock`, `rsync` and the AWS CLI.
`jq` is optional: `manager-bootstrap.sh` falls back to plain text without it. macOS is not supported.

## Install

1. **Create `~/.claude/host.md` from `host.example.md` first**, and edit it for
   the machine. Facts about one machine — the temp directory, tool paths — live
   there and nowhere in these files. Without it a session has no temp-directory
   rule and falls back to `$TMPDIR` or its scratchpad, which may be a small `/tmp`.
2. Copy the payload:

   ```bash
   cp -a skills agents commands CLAUDE.md manager-bootstrap.sh memory-sync.sh ~/.claude/
   ```

   This overwrites files of the same name in `~/.claude`.
3. Wire the hooks, below.

## Wiring

`settings.json` is not shipped. Merge `settings.example.json` into
`~/.claude/settings.json` and replace every `<…>` placeholder.

| Event | Runs |
|---|---|
| `SessionStart` | `memory-sync.sh pull` and `manager-bootstrap.sh` |
| `SessionEnd` | `memory-sync.sh push` |
| `PostToolUse` | `memory-sync.sh push-if-changed` |
| `Stop` | `memory-sync.sh push-if-changed` |

`CLAUDE_MEMORY_S3_TIMEOUT` is optional and defaults to 12 seconds. A run can
last up to 3 seconds longer than that, so keep every hook timeout at least
3 seconds above it. The largest value accepted is 17, because 17 + 3 seconds
is the 20-second hook timeout; a larger value is rejected — the script says so
on stderr and uses 12. Keep the explicit `timeout` on the `SessionEnd` hook:
`SessionEnd` hooks share a 1.5-second budget unless a longer per-hook timeout
is set, which Claude Code honours up to 60 seconds.

`AWS_PROFILE` is optional. In the `env` block it sets the profile for every
`aws` command any agent runs in every session, not only for `memory-sync.sh` —
delete the key if you do not want that.

`memory-sync.sh delete <project>/memory/<file>` is run by hand, never from a
hook. It is the only way to remove a memory for good — see the `sync-memory` skill.
