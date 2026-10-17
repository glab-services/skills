# skills

A Claude Code plugin marketplace, `glab-services`, with two plugins: the
workflow we run in every session, and the hooks that sync Claude Code memories
to S3.

| Plugin | What it adds |
|---|---|
| `glab` | Skills `glab:bootstrap`, `glab:manager`, `glab:security`, `glab:comments`, `glab:plan-first`, `glab:audit`, `glab:external-agents` · agents `glab:developer`, `glab:analyzer`, `glab:integrator`, `glab:reviewer`, `glab:committer` · commands `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`, `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship` · a script, `external-agent.sh`, that runs read-only external agents on a model you name (OpenCode Go) · a `SessionStart` hook that injects the session bootstrap rules |
| `memory-sync` | Skill `memory-sync:sync-memory` · hooks on four events that run `memory-sync.sh` |

In `glab` the skills, agents and commands are one set: `glab:manager`
dispatches the agents through the commands, and every agent carries
`glab:security` and `glab:comments`. The two plugins do not depend on each
other; install either alone.

A plugin cannot ship global instructions. The session rules reach a session
through the `glab` `SessionStart` hook, so they hold only while `glab` is
enabled.

## Requirements

Linux with bash. `jq` is optional: the `glab` hook falls back to plain text
without it. `memory-sync` also needs GNU coreutils (`timeout`, `stat`,
`date`), util-linux `flock`, `rsync` and the AWS CLI. macOS is not supported.

External agents in `glab` (`glab:external-agents`) run only when you ask the
manager for one, naming the model, and then also need: bubblewrap (`bwrap`)
able to create namespaces on your host, `slirp4netns` for the sandbox's own
network, util-linux (`nsenter`, `setpriv`, `lsns`, `flock`), iproute2 (`ip`),
`git`, `jq`, GNU `tar` and `timeout`, and OpenCode's native binary (the
installer puts it at `~/.opencode/bin/opencode`; a launcher script does not run
in the sandbox) with an OpenCode Go key stored by `opencode auth login`. On
Debian or Ubuntu: `sudo apt install bubblewrap slirp4netns`. Without a working
`slirp4netns` the script refuses to start an agent (exit 9). Keep the OpenCode
console's "Use balance" switch off, or a Go limit spends paid balance.

What an external agent can send, and to whom: your working tree's tracked and
untracked-but-not-ignored files, the index and the tree of your current
commit — no other branch, tag or history, and never an ignored file — and
every message the manager sends it, may reach the provider of the model you
named. The script runs only Kimi and GLM models, and DeepSeek models until
2026-10-31, after which it refuses them until their data policy has been
checked again; Grok is refused, because its provider keeps prompts for 30
days. The agent works on a read-only copy, in a sandbox whose network reaches
the internet and nothing on your host or local network. The OpenCode Go key
is inside that sandbox, where the model can read it and could send it out; it
is never printed and is redacted from what the agent returns. Each agent's
transcript stays readable under `$TMPDIR/glab-external-agents/` until the
manager stops it.

External agents have been tested against a stub and against the real
`opencode` with no network, and have not yet run against a real model: that
is the live probe in `plan/feature-opencode-worker/plan-r3.md` (L1), which you
run with your own key. Until it has, treat the first real session as the
test it is.

## Install

This marketplace is a private repository, for people in the organization
only. Claude Code has no token of its own: it runs `git` on your machine with
the credentials the machine already holds, and with prompts turned off.
Before you add the marketplace you need both of these:

- read access to `glab-services/skills` on GitHub;
- a credential git can use without asking: either an SSH key for GitHub that
  is loaded in `ssh-agent`, with `github.com` already in `known_hosts`, or a
  stored HTTPS credential — run `gh auth login`, then `gh auth setup-git`.

Adding by `owner/repo`, as below, tries SSH first and falls back to HTTPS.
Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` to skip the SSH attempt.

1. **If you install `glab`, create `~/.claude/host.md` from `host.example.md`
   first**, and edit it for the machine. `host.example.md` is at the root of
   this repository. Facts about one machine — the temp directory, tool paths —
   live there and nowhere in these files. Without it a `glab` session has no
   temp-directory rule and falls back to `$TMPDIR` or its scratchpad, which may
   be a small `/tmp`. `memory-sync` does not read it.
2. Add the marketplace and install the plugins you want:

   ```bash
   claude plugin marketplace add glab-services/skills
   claude plugin install glab@glab-services
   claude plugin install memory-sync@glab-services
   ```
3. For `memory-sync`, set its environment, below.

Each plugin carries a `version`. `claude plugin update glab@glab-services`
fetches a newer one; a change that did not raise the version is not delivered.

Background auto-update is off for this marketplace until you turn it on
(`/plugin`, Marketplaces, Enable auto-update). When it is on it uses the same
stored credentials and never prompts. A `GITHUB_TOKEN` in the environment
does not authenticate it by itself: a token takes effect through a credential
helper, such as the one `gh auth setup-git` installs. Both statements are
from the Claude Code docs, "Host and maintain a marketplace"
(<https://code.claude.com/docs/en/plugins/host-marketplace.md>), read on
2026-10-05; neither was tried here.

### Rolling out to a team

To register the marketplace and enable both plugins from settings instead of
by hand, set these two keys — in managed settings for every machine, or in one
repository's `.claude/settings.json` for the people who work in it:

```json
{
  "extraKnownMarketplaces": {
    "glab-services": {
      "source": { "source": "github", "repo": "glab-services/skills" }
    }
  },
  "enabledPlugins": {
    "glab@glab-services": true,
    "memory-sync@glab-services": true
  }
}
```

Every person still needs the access and the credential described above. In a
repository's settings the marketplace entry applies only once that person has
trusted the folder.

## Coming from the copy install

Before the plugins, this setup was copied into `~/.claude` by hand. On a
machine that still has that copy, installing the plugins on top of it runs
everything twice: each skill, agent and command exists under two names, the
session rules are injected twice, and every memory sync runs twice — once from
a script copy that no plugin update ever reaches. Remove the old copy by hand.

The steps below assume you install both plugins. If you install only
`memory-sync`, remove only the four `memory-sync.sh` hook entries,
`~/.claude/memory-sync.sh` and `~/.claude/skills/sync-memory/`, and keep the rest.
Do it when no session is in the middle of work; a session that is already
running keeps what it loaded until it is restarted.

1. In `~/.claude/settings.json`, remove the `hooks` entries that call
   `memory-sync.sh` (four: `SessionStart`, `SessionEnd`, `PostToolUse`, `Stop`)
   and the `SessionStart` entry that calls `manager-bootstrap.sh`. Keep the
   `env` block, and add `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` to it — see
   the next section.
2. In `~/.claude`, delete what was copied:
   - the two scripts, `memory-sync.sh` and `manager-bootstrap.sh`;
   - seven skill directories under `skills/`: `skills/bootstrap/`,
     `skills/manager/`, `skills/security/`, `skills/comments/`,
     `skills/plan-first/`, `skills/audit/`, `skills/sync-memory/`;
   - five agents under `agents/`: `agents/developer.md`, `agents/analyzer.md`,
     `agents/integrator.md`, `agents/reviewer.md`, `agents/committer.md`;
   - eight commands under `commands/`: `commands/plan.md`,
     `commands/develop.md`, `commands/analyze.md`, `commands/integrate.md`,
     `commands/review.md`, `commands/commit.md`, `commands/push.md`,
     `commands/ship.md`.

   Delete only these names. Anything else in those three directories is yours.
3. In `~/.claude/CLAUDE.md`, remove the rules that came from this repo: the
   `glab` hook now delivers them, and the old text names the skills without
   their prefix. Keep whatever you wrote there yourself.
4. Leave `~/.claude/host.md` and the `~/.claude/.memory-sync-*` files alone.
   The plugin's script uses the same state files and the same lock.

Until step 1 is done the two copies of the sync share that lock, so they
queue or skip rather than run at once — but each sync is still attempted
twice.

## Configuring `memory-sync`

The hooks ship in the plugin. Its settings do not, because a plugin cannot set
environment variables: merge the `env` block of
`plugins/memory-sync/settings.example.json` into `~/.claude/settings.json` and
replace every `<…>` placeholder.

| Event | Runs |
|---|---|
| `SessionStart` | `memory-sync.sh pull` |
| `SessionEnd` | `memory-sync.sh push` |
| `PostToolUse` | `memory-sync.sh push-if-changed` |
| `Stop` | `memory-sync.sh push-if-changed` |

`CLAUDE_MEMORY_S3_TIMEOUT` is optional and defaults to 12 seconds. A run can
last up to 3 seconds longer than that, and the plugin gives each hook 20
seconds. The largest value accepted is 17, because 17 + 3 seconds is that
20-second hook timeout; a larger value is rejected — the script says so on
stderr and uses 12.

Keep `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` in the `env` block. All
`SessionEnd` hooks share a 1.5-second budget, and the timeout a plugin sets on
its own hook does not raise it. Claude Code documents this variable as the
override for that budget; whether it also covers a hook that a plugin provides
is not yet confirmed. Until it is, treat the push at session end as best
effort: it can be cut off with no log line. Edits made during the session are
not affected: `push-if-changed` has already sent them.

`AWS_PROFILE` is optional. In the `env` block it sets the profile for every
`aws` command any agent runs in every session, not only for `memory-sync.sh` —
delete the key if you do not want that.

`memory-sync.sh delete <project>/memory/<file>` is run by hand, never from a
hook. It is the only way to remove a memory for good — see the
`memory-sync:sync-memory` skill, which also gives the script's installed path.

The script keeps its stage copy, its stamps and its lock in `~/.claude`
(`.memory-sync-*`), not in the plugin's data directory, so hooks and hand runs
share one lock. Uninstalling the plugin leaves those files in place.

## Working on this repo

| Path | What it is |
|---|---|
| `AGENTS.md` | Working agreement for changes to this repo, and the gates |
| `.claude-plugin/marketplace.json` | The marketplace: lists both plugins |
| `plugins/` | The two plugins. Payload: written for the sessions of whoever installs them |
| `host.example.md` | Template for the per-machine `~/.claude/host.md` |
| `tests/` | Stub-based tests for `memory-sync.sh` and `external-agent.sh` |
| `plan/` | Planning records |

To try a change without installing anything, load the plugins for one session:
`claude --plugin-dir ./plugins` loads both, `claude --plugin-dir ./plugins/glab`
loads one. Do not pass the repo root: the CLI does not read `marketplace.json` from a
`--plugin-dir`, so neither plugin loads — at most an empty plugin named after
the directory. Loading
`memory-sync` this way runs its hooks against whatever `CLAUDE_MEMORY_S3_URI`
that session has.
