# Upgrading

Notes for machines that ran an older setup. New installs need none of this.

## Moving to glab-team

`glab-team` was published before as `team-messaging@team-messaging-local`.
Its id, skills, options and data directory are new, so nothing carries over.
If that plugin is installed, uninstall it before you install
`glab-team@glab-services`: two installs run two sets of hooks in every
session. The command, what stays behind and how to bind your projects again
are in `src/glab-team/docs/setup.md`, *Moving from team-messaging@team-messaging-local*.

## Renamed in 0.15.0

`glab` 0.15.0 moves the project level's skills and agents to `glab:project-*`.
An old name, typed after `/glab:` or dispatched, finds nothing. Each old name
and what it became:

| was `glab:` | now |
|---|---|
| `manager` | `glab:project-manager` |
| `plan` | `glab:project-plan` |
| `develop` | `glab:project-develop` |
| `analyze` | `glab:project-analyze` |
| `integrate` | `glab:project-integrate` |
| `review` | `glab:project-review` |
| `ship` | `glab:project-ship` |
| `product-project-plan-report` | `glab:project-plan-report` |
| `planner` | `glab:project-planner` |
| `plan-analyzer` | `glab:project-plan-analyzer`, removed in 0.21.0 |
| `analyzer` | `glab:project-analyzer` |
| `developer` | `glab:project-developer` |
| `integrator` | `glab:project-integrator` |
| `reviewer` | `glab:project-reviewer` |

The skills of every level, `glab:committer` and the product level keep their
names. A plan folder begun before 0.15.0 may hold `- model: glab:<old agent> …`
lines under `## Decisions` (`glab:session-rules` Rule 5): they name agents that
no longer exist, so rewrite each to its new name before the folder's next
dispatch — in `plan.md` itself while the plan has not been reported to the
product level. Once it has, the hashed files are frozen
(`glab:project-plan-report`): leave `plan.md` as it is and write the
renamed line into `after-verdict.md`, where Stage 1c puts every record line
after a report.

## Removed: `memory-sync`

The `memory-sync` plugin is no longer in this marketplace. If you installed it,
these steps are yours:

- run `claude plugin uninstall memory-sync@glab-services`, and remove
  `memory-sync@glab-services` from any `enabledPlugins`;
- remove from your `env` block the keys you merged for it:
  `CLAUDE_MEMORY_S3_URI`, `CLAUDE_MEMORY_S3_TIMEOUT`, `CLAUDE_MEMORY_S3_ARGS`,
  `AWS_PROFILE` (if you set it only for this) and
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`;
- the `~/.claude/.memory-sync-*` files and the objects in your bucket are left
  as they are.

Its last version is readable from this repository's history at `346d286`:
`git show 346d286:plugins/memory-sync/scripts/memory-sync.sh`.

Uninstalling a plugin that its marketplace no longer lists was not tried here:
the command above was not run, and what an installed copy does once the
marketplace drops it — stays and keeps firing, or goes on the next update — is
unverified. If the command does not remove it, remove it through `/plugin`, or
delete its key from `enabledPlugins` and the marketplace's cached entry by hand.

## Coming from the copy install

Before the plugin, this setup was copied into `~/.claude` by hand. On a
machine that still has that copy, installing the plugin on top of it runs
everything twice: each skill, agent and command exists under two names and the
session rules are injected twice. Remove the old copy by hand.

The copy's memory sync — the four `memory-sync.sh` hook entries,
`~/.claude/memory-sync.sh`, `~/.claude/skills/sync-memory/` and the
`~/.claude/.memory-sync-*` files — is no longer part of this marketplace, so
these steps leave it alone; keep or remove it as you choose. Do it when no session is in the middle of work; a session that is already
running keeps what it loaded until it is restarted.

1. In `~/.claude/settings.json`, remove the `SessionStart` entry that calls
   `manager-bootstrap.sh`. Keep the `env` block.
2. In `~/.claude`, delete what was copied:
   - the script, `manager-bootstrap.sh`;
   - six skill directories under `skills/`: `bootstrap`, `manager`,
     `security`, `comments`, `plan-first`, `audit`;
   - five agents under `agents/`: `developer.md`, `analyzer.md`,
     `integrator.md`, `reviewer.md`, `committer.md`;
   - eight commands under `commands/`: `commands/plan.md`,
     `commands/develop.md`, `commands/analyze.md`, `commands/integrate.md`,
     `commands/review.md`, `commands/commit.md`, `commands/push.md`,
     `commands/ship.md`.

   Delete only these names. Anything else in those three directories is yours.
3. In `~/.claude/CLAUDE.md`, remove the rules that came from this repo: the
   `glab` hook now delivers them, and the old text names the skills without
   their prefix. Keep whatever you wrote there yourself.
4. Leave `~/.claude/host.md` alone.
