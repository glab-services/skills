# skills

A Claude Code plugin marketplace, `glab-services`, with two plugins: the
workflow we run in every session, and the hooks that sync Claude Code memories
to S3.

| Plugin | What it adds |
|---|---|
| `glab` | Skills `glab:bootstrap`, `glab:project-manager`, `glab:session-rules`, `glab:security`, `glab:comments`, `glab:audit`, `glab:severity` · agents `glab:project-planner`, `glab:project-plan-analyzer`, `glab:project-analyzer`, `glab:project-developer`, `glab:project-integrator`, `glab:project-reviewer`, `glab:committer` · stage skills `/glab:project-plan-accept`, `/glab:project-plan-analyze`, `/glab:project-develop`, `/glab:project-analyze`, `/glab:project-integrate`, `/glab:project-review`, `/glab:commit`, `/glab:push`, `/glab:project-ship`, `/glab:project-plan-report`, `/glab:project-record`, which `glab:project-manager` runs itself and you can type to step in · `/glab:project-plan <task>`, the planning procedure `glab:project-planner` follows, which you can type to plan in your own session · a `SessionStart` hook that injects the session bootstrap rules · a context hook on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop` that tells the session its context size and tells you when a turn crosses 300k or a further 100k · the product level (*Levels*): skills `glab:product-manager`, `glab:product-plan`, `glab:product-plan-analyze`, `glab:product-project-brief`, `glab:product-project-plan-analyze`, `glab:product-project-plan-verdict` · agents `glab:product-planner`, `glab:product-analyzer` |
| `memory-sync` | Skill `memory-sync:sync-memory` · hooks on four events that run `memory-sync.sh` |

In `glab` the skills and agents are one set: `glab:project-manager` runs each stage
through its stage skill, which dispatches the agents, and dispatches
`glab:project-planner` itself for the plan. Each agent preloads, through the `skills:`
list in its definition, the `glab` skills its role uses — `glab:security` in
all nine, `glab:project-plan` in the planner and `glab:product-plan` in the product
planner — and runs at the session's effort level,
which the manager passes on every dispatch. The two plugins do not depend on
each other; install either alone.

Each `glab` agent runs on the model its definition names: the planner, the
plan check, the product planner and the product analyzer on Opus; the analyzer, developer, reviewer and integrator on
Sonnet; the committer on Haiku. They were chosen for cost, and every
installer pays these models' prices. Tell the manager to use another model
for a role and it passes that one instead. From Claude Code v2.1.251,
`CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches these agents, because a
definition's model outranks it; `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` with it
does, from Claude Code v2.1.257, and overrides the definitions and the model
you named alike.

Each change's working files live in `plan/<slug>/`: `master.md` —
your request in your words, its goals and the final check, constant once
accepted — and one `plan.md`, or sub-plans `<nn>-<name>/` that each run
their own cycle. `glab:project-plan-analyzer` checks the plan against `master.md`
before the build (Stage 1b), `glab:project-analyzer` the build after it (Stage 3),
the reviewer sees only the code, and `glab:project-analyzer`'s final check before
the push compares the master with everything built.
Once the change has been pushed, the workflow records what
stays true — how the area works, the decisions that still bind, what is open
— in `docs/specs/<area>.md`, as a docs commit of its own. It never removes the
plan folder: whether a repo does is that repo's `AGENTS.md` decision. A
repo's `AGENTS.md` can also put specs elsewhere.

A plugin cannot ship global instructions. The session rules reach a session
through the `glab` `SessionStart` hook, so they hold only while `glab` is
enabled.

`glab`'s context hook adds one line of about ten tokens to the model's context
on each message you send and after each subagent dispatch, and once the context
has crossed 300k, 400k, … it shows you `glab: context <n>k … a good point to
/compact, or to /clear between tasks` at the end of a turn — usually the turn
after the crossing, because a turn's last model call is not yet in the
transcript when the turn ends. It never blocks or prolongs a turn.
300k is the default first step. On a model with a smaller context window,
export `GLAB_COMPACT_AT` with the first step in thousands —
`export GLAB_COMPACT_AT=150` in the shell that starts Claude Code — and the
steps become 150k, 250k, …; every line then ends `; compact at 150k)`.
The number is the last completed model call's, and can trail the turn a
little. It runs in every session where `glab` is enabled, and not at all when
hooks are turned off (`disableAllHooks`, `--bare`).

Ask for it, and the manager has you
approve `master.md` in Claude Code's plan mode instead of the chat.
UNVERIFIED: how the dialog takes the plan and that it sets the session's
permission mode from then on are read from Claude Code's documentation, not
yet run — the live tests L1–L7 in `docs/specs/workflow.md` settle them;
until then pick the mode you were in. The plugin
never changes `plansDirectory`, and the manager writes no plan file under
`~/.claude/plans`.

## Levels

`glab` runs a session at one level. The project level is today's workflow:
`glab:project-manager` plans, builds, reviews and ships one repo's changes. The
product level sits above it: `glab:product-manager` turns a business plan
into a product plan, product rules and one brief per project, and judges
each project's plan before that project develops. Each level has its own
manager, its own skills and its own agents.

**Which level.** A line `glab-level: product` in a repo's `AGENTS.md` makes
its sessions product sessions; `glab-level: project`, or no such line, keeps
the project level, so every existing repo starts as before. Any other value
runs as project, with a warning above the session-start text; `delivery` and
`support` are reserved for levels not built yet. The `SessionStart` hook reads
the first such line from the `AGENTS.md` of the folder the session starts in,
or of the top of its git work tree when that folder has none.

**What the session start loads.** The manager of the level —
`glab:project-manager` or `glab:product-manager` — then `glab:session-rules`, the
rules every level's manager runs under, and `glab:security`.

**The shared store.** The levels exchange plain files in one shared folder,
named by a line `glab-shared-store: <path to the shared folder>` in the
repo's `AGENTS.md`, or else in `~/.claude/host.md`, where a machine's paths
belong. Its layout:

    <store>/docs/product-rules/index.md       one line per rule file
    <store>/docs/product-rules/<name>.md      one topic, its size as glab:product-plan says
    <store>/briefs/<project>/brief.md         the project's request
    <store>/briefs/<project>/report.r<n>.md   the project's plan report
    <store>/briefs/<project>/plan.r<n>/       the plan files the report hashed
    <store>/briefs/<project>/verdict.r<n>.md  the product's verdict
    <store>/releases/                         reserved for the delivery level

**The loop.** A project session takes a brief as its request, plans it as
usual, and after the approvals reports the plan — its digest, a sha256 over
the plan files — to the store; the product session audits that copy against
the brief and the product rules and writes `ACCEPTED` or `REJECTED` with a
reason. `glab:project-develop` refuses to start while the latest verdict is not an
`ACCEPTED` of exactly the plan and the brief as they are now, so an edited
plan or brief is reported again; the project manager's own record lines
after a report go to `after-verdict.md`, outside the hash. One script,
`plugins/glab/scripts/plan-gate.sh`, writes the report and the verdict and
checks them.

**The rejection cap.** Two `REJECTED` verdicts on one project since the last
`ACCEPTED` — over every brief that project has had — and the next verdict is
the user's.

**The boundary.** Each manager's *Your skills — this level only* list is the
rule a session keeps to; a description's `Product level — ` or
`Project level — ` prefix is a hint. Only the product agents, which have no
`Skill` tool, are held to it by Claude Code itself.

**Known limits.** The main session's boundary is text, which a session keeps
to as far as it follows its skills. `by user` is an argument the calling
session chooses, and both levels can write the store, so the cap holds as far
as the sessions keep to the skill text.

## Try the product loop

Without installing anything and without a model, from the repo root in a
shell where `TMPDIR` is set:

    PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>"$TMPDIR/trace.txt"

It plays a made-up product with two projects through the whole loop under
`$TMPDIR` and prints one `ok` line per step; `$TMPDIR/trace.txt` holds the
trace — each scene, the role that acts in it, every `plan-gate.sh` command,
each refusal and the text of every brief, report, verdict and rule written.

Live, after installing `glab` at the version in
`plugins/glab/.claude-plugin/plugin.json`:

1. Make a store folder. Give a product repo an `AGENTS.md` with
   `glab-level: product` and `glab-shared-store: <path to the shared folder>`,
   and a project repo an `AGENTS.md` with the same store line.
2. Start the product session with the store among its directories:
   `claude --add-dir <store>`. Give it a business plan; approve the product
   plan it brings you; it writes the briefs and the rules to the store.
3. Start a project session in the project repo, with the start prompt, as
   `glab:product-manager` *Starting project sessions* says: the desktop
   app's session tool, `claude --bg` from the project repo, or by hand. That
   the prompt keeps a background session from pushing is UNVERIFIED until
   LP4 has run.
4. The project session plans, has you approve, reports and waits; the product
   session audits the report and writes the verdict; on `ACCEPTED` the project
   session develops.

The live checks, each UNVERIFIED until run:

- **LP1** — in the product repo, and in a subfolder of it, the session-start
  text names `glab:product-manager`, and the session loads
  `glab:session-rules` with it.
- **LP2** — the product session uses only its manager's skills, also when
  many plugins crowd the skill listing.
- **LP3** — `${CLAUDE_PLUGIN_ROOT}` is replaced by the plugin's path in the
  product skills' commands.
- **LP4** — a project session starts and is reached on each host: the
  desktop app's session tool; `claude --bg` from the product session's Bash
  tool, reached by `SendMessage` and waited on with `notify_when_idle`; and by
  hand. The start prompt keeps a background session from pushing.
- **LP5** — the product agents preload their `skills:`.
- **LP6** — with the store added by `--add-dir`, the product session writes a
  brief through `glab:product-planner` and a verdict through `plan-gate.sh`
  without a permission prompt for each write.

## Requirements

Linux with bash. `jq` is optional: without it the `glab` `SessionStart` hook
falls back to plain text, and the context hook says nothing — the session's
manager then counts dispatches instead (`glab:session-rules` Rule 2). `memory-sync` also needs GNU coreutils (`timeout`, `stat`,
`date`), util-linux `flock`, `rsync` and the AWS CLI. macOS is not supported.

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
| `plan-analyzer` | `glab:project-plan-analyzer` |
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
   - seven skill directories under `skills/`: `bootstrap`, `manager`,
     `security`, `comments`, `plan-first`, `audit`, `sync-memory`;
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
| `tests/` | The scripts' tests — `memory-sync.sh` against a stub, the hooks, `plan-gate.sh` — and the product-loop walkthrough with its fixtures, `tests/fixtures/product-loop/`, and `tests/gates.sh`, every gate with its expected result |
| `plan/` | Working area: the files of changes in progress, removed once each change is recorded |
| `docs/specs/` | One spec per area: how it works now, why, what is not verified, what is open |
| `docs/one-fact.md` | The *One fact, one value* registry: each fact more than one file states, and the files that state it |

To try a change without installing anything, load the plugins for one session:
`claude --plugin-dir ./plugins` loads both, `claude --plugin-dir ./plugins/glab`
loads one. Do not pass the repo root: the CLI does not read `marketplace.json` from a
`--plugin-dir`, so neither plugin loads — at most an empty plugin named after
the directory. Loading
`memory-sync` this way runs its hooks against whatever `CLAUDE_MEMORY_S3_URI`
that session has.
