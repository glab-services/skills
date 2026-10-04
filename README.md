# skills

Our global Claude Code setup: the skills, agents and slash commands that run
every session, plus the global instructions and the two hook scripts they rely on.

The layout mirrors `~/.claude`, so each path here installs to the same path there.

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

## Install

```bash
cp -a skills agents commands CLAUDE.md manager-bootstrap.sh memory-sync.sh ~/.claude/
```

This overwrites files of the same name in `~/.claude`. `settings.json` is not
shipped: the hooks that call the two scripts, and the `CLAUDE_MEMORY_S3_*`
environment for `memory-sync.sh`, are wired per machine.

Some of the text is specific to the machine it was written on — the
`/data/tmp/claude` temp directory and the `grep`-is-ugrep hazard in `bootstrap`
in particular. Adjust those for your own host.
