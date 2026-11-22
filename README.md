# skills

A Claude Code plugin marketplace, `glab-services`, with two plugins: `glab`, the
workflow we run in every session, and `glab-team`, team agent messaging.

| Plugin | What it adds |
|---|---|
| `glab` | Skills `glab:bootstrap`, `glab:project-manager`, `glab:session-rules`, `glab:security`, `glab:comments`, `glab:audit`, `glab:severity` · agents `glab:project-planner`, `glab:project-plan-analyzer`, `glab:project-analyzer`, `glab:project-developer`, `glab:project-integrator`, `glab:project-reviewer`, `glab:committer` · stage skills `/glab:project-plan-accept`, `/glab:project-plan-analyze`, `/glab:project-develop`, `/glab:project-analyze`, `/glab:project-integrate`, `/glab:project-review`, `/glab:commit`, `/glab:push`, `/glab:project-ship`, `/glab:project-plan-report`, `/glab:project-record`, which `glab:project-manager` runs itself and you can type to step in · `/glab:project-plan <task>`, the planning procedure `glab:project-planner` follows, which you can type to plan in your own session · `/glab:project-issue <owner>/<repo>#<n>`, which takes a GitHub issue as the task: it reads the issue with `gh api` into the plan folder, and the planner quotes it in the master · a `SessionStart` hook that injects the session bootstrap rules · a context hook on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop` that tells the session its context size and tells you when a turn crosses 300k or a further 100k · a `PreToolUse` hook on `Skill` and on `Bash`, `PowerShell` and `Monitor` that refuses another level's skill and asks you before a verdict by `user` · the product level (*Levels*): skills `glab:product-manager`, `glab:product-plan`, `glab:product-plan-analyze`, `glab:product-project-brief`, `glab:product-project-plan-analyze`, `glab:product-project-plan-verdict` · agents `glab:product-planner`, `glab:product-analyzer` · templates under `templates/docs-mirror/` for a CI job that mirrors a code repo's `docs/` to a read-only `{repo}-docs` repository (*The docs mirror*) |
| `glab-team` | Team agent messaging, built from `src/glab-team/`: skills `/glab-team:messaging-join`, `/glab-team:messaging-bind`, `/glab-team:messaging-claim`, `/glab-team:messaging-status`, `/glab-team:messaging-watch` · the MCP server `messaging` · hooks on `SessionStart`, `PreToolUse`, `Stop` and `StopFailure` that wake an idle agent session when messages arrive and keep a team-message window to the messaging tools · needs Node.js 24 or newer as `node` on `PATH` |

In `glab` the skills and agents are one set: `glab:project-manager` runs each stage
through its stage skill, which dispatches the agents, and dispatches
`glab:project-planner` itself for the plan. Each agent preloads, through the `skills:`
list in its definition, the `glab` skills its role uses — `glab:security` in
all nine, `glab:project-plan` in the planner and `glab:product-plan` in the product
planner — and runs at the session's effort level,
which the manager passes on every dispatch.

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
— in `docs/specs/<area>.md`, and what a user can do with it in
`docs/features/<feature>.md`, as a docs commit of its own. `plan/` is ignored
by git and never committed; once the record has landed, the manager asks
at a session start whether to remove the plan folder, and removes it only on
your word. A repo's `AGENTS.md` can also put specs
and feature pages elsewhere. The product level records each delivered
business plan in `docs/roadmap/<slug>.md`.

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

**The shared store.** The levels exchange plain files in one shared folder or a clone of the product's store repository,
named by a line `glab-shared-store: <path to the store folder or clone>` in the
repo's `AGENTS.md`, or else in `~/.claude/host.md`, where a machine's paths
belong. The filesystems it may sit on are named in the header of
`plugins/glab/scripts/plan-gate.sh`. Its layout:

    <store>/docs/product-rules/index.md       one line per rule file
    <store>/docs/product-rules/<name>.md      one topic, its size as glab:product-plan says
    <store>/briefs/<project>/brief.md         the project's request
    <store>/briefs/<project>/report.r<n>.md   the project's plan report
    <store>/briefs/<project>/plan.r<n>/       the plan files the report hashed
    <store>/briefs/<project>/verdict.r<n>.md  the product's verdict
    <store>/releases/                         reserved for the delivery level

**A store clone.** Each machine can hold, in place of the folder, a clone of
the product's store repository. The user creates that repository once,
empty, on its git host — its new-project page, or on a server of its own:

    git init --bare <path to the store repository>

then sets each clone up once, in one command:

    git clone -c core.autocrlf=false -c glab.store=true <store repo URL> <path to the clone>

The repository needs a first commit, made once, from the first clone, on a
machine where git already has your name and email; until then
`plan-gate.sh` refuses the clone:

    cd <path to the clone> && git commit --allow-empty -m 'store: first commit' && git push

The store line names the clone's path,
best in `~/.claude/host.md`, since it differs per machine. `plan-gate.sh`
commits and pushes the store itself, and its `sync` mode brings a clone up
to date. Without `glab.store` a clone is a plain folder.

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
`Project level — ` prefix is a hint. No `glab` agent has the `Skill` tool,
and a `PreToolUse` hook refuses every other Skill call to a `glab:` skill not
on the session's list — except when it cannot read the call, the list or the
level rule, and then it lets the call through.

**Known limits.** The hook judges the skills Claude calls, in subagents too;
it judges no agent. A skill you type yourself as `/glab:<name>` is never
refused, but a skill it calls in turn through the Skill tool is judged
(inferred: no live run made such a call). A verdict `by user` opens the
permission dialog, so only you pass it, as far as the command's text shows
`plan-gate.sh`, `verdict` and `user`; it reads the command of a Bash or
PowerShell call, and by inference of a Monitor call, whose input is not
verified; where no dialog can open — a -p run, dontAsk mode included, and by
inference dontAsk outside -p — the call is refused; with an allow rule that
covers the command, the dialog still opens — seen in auto mode, while a -p run
refused it, and other interactive modes are UNVERIFIED; under
bypassPermissions, a -p run still refused it; an interactive session was not
tried. Seen live on Linux, 2026-11-19: the refusals, the typed skill, and a
by-user verdict refused in -p runs under an allow rule, in dontAsk mode and
under bypassPermissions, of Claude Code 2.1.325; and the dialog in an
interactive session of Claude Code 2.1.327 in auto mode with an allow rule,
where Yes ran the command and No left it unrun. Both levels can write the
store, so beyond that the cap holds as far as the sessions keep to the skill
text. Skill names are matched case-sensitively; whether the CLI resolves a
skill name case-insensitively is UNVERIFIED. A skill of your own with the same
bare name as a `glab` skill of the other level is refused too.

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

1. Make a store folder, or a clone, as above. Give a product repo an `AGENTS.md` with
   `glab-level: product` and `glab-shared-store: <path to the store folder or clone>`,
   and a project repo an `AGENTS.md` with the same store line.
2. Start the product session with the store among its directories:
   `claude --add-dir <store>`. Give it a business plan; approve the product
   plan it brings you; it writes the briefs and the rules to the store.
3. Start a project session in the project repo, with the start prompt, as
   `glab:product-manager` *Starting project sessions* says: the desktop
   app's session tool, `claude --bg` from the project repo, or by hand. That
   the prompt keeps a background session from pushing its repo is UNVERIFIED until
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
  hand. The start prompt keeps a background session from pushing its repo.
- **LP5** — the product agents preload their `skills:`.
- **LP6** — with the store added by `--add-dir`, the product session writes a
  brief through `glab:product-planner` and a verdict through `plan-gate.sh`
  without a permission prompt for each write.
- **LP7** — two machines, one store repository: a report from one, the
  verdict from the other, and the develop gate passing on the first.

## The docs mirror

`glab` ships, under `plugins/glab/templates/docs-mirror/`, a script and two
CI files that publish a code repo's `docs/` to a read-only `<repo>-docs`
repository on each merge to its default branch. The docs stay in the code
repo and change in the same PR as the code; the mirror lets them be read
without the code. It is a repository of its own, not a submodule, which
would need a pointer bump after every docs change and show only that
pointer in a PR. Each code repo has its own mirror.

Each run makes the mirror's tree exactly the code repo's `docs/` at the
merged commit, at the mirror's root, with nothing added: modes, symlinks,
line endings, deletions and renames carry, and no file outside `docs/`
reaches it. A run whose tree differs adds one commit on the mirror's tip,
never a force-push, by `glab docs-mirror <docs-mirror@glab.invalid>`, with
the subject `docs: mirror <first 12 hex of the source commit>` and the last
line `Source-Commit: <full sha of the source commit>`; a run whose tree is
equal adds nothing, unless it adopts a rewritten source (below), which
always adds one. The run reads the code repo's checkout and changes none of
its refs, config, index or files; it writes only `FETCH_HEAD`, the
fetched mirror objects and the mirror commit into its `.git`.

**Set it up once per code repo:**

1. Create `<repo>-docs` on the git host, empty, with no README, and private
   unless the docs may be public: every file under `docs/` becomes readable
   by whoever can read the mirror.
2. Make its key:
   `ssh-keygen -t ed25519 -N '' -C '<repo>-docs mirror' -f <a path outside every repo>`.
3. Add the public key to the mirror as a deploy key with write access —
   GitHub: *Allow write access*; GitLab: *Grant write permissions to this
   key*.
4. Protect the mirror's branch: `main` on GitHub (the branch the template's
   `run:` line passes), the code repo's default branch on GitLab. GitHub: a
   ruleset on `main` with *Restrict deletions* and *Block force pushes*,
   and not *Restrict updates*, which lets only bypass actors push — on
   github.com a deploy key cannot be one, so every run's push would be
   refused. Read-only then rests on who holds write access to the mirror
   and on the next run overwriting a hand edit. A ruleset on a private
   mirror needs a paid plan (inferred from GitHub's plans page). GitLab:
   not yet — the first merge creates that branch, so this is step 7.
5. Set three values in the code repo's CI settings. GitHub: *Settings →
   Secrets and variables → Actions*, the **Variables** tab for
   `DOCS_MIRROR_URL` and `DOCS_MIRROR_KNOWN_HOSTS` — the job reads `vars.`
   and is skipped while `DOCS_MIRROR_URL` is empty, so a URL saved as a
   secret never runs — and the **Secrets** tab for `DOCS_MIRROR_SSH_KEY`.
   GitLab: *Settings → CI/CD → Variables*, all three, the key Protected,
   type Variable, not masked — a multi-line value cannot be — and with
   *Environments* set to `docs-mirror`, the template job's environment,
   so that no other job of the pipeline gets it. Leave the other two at
   *All (default)*: the job's `rules:` reads `DOCS_MIRROR_URL` when the
   pipeline is created, and GitLab warns that an environment-scoped
   variable may not be defined then. The values:
   - `DOCS_MIRROR_URL` = `git@<host>:<owner>/<repo>-docs.git`;
   - `DOCS_MIRROR_KNOWN_HOSTS` = the host's published `known_hosts`
     line(s) (GitHub publishes them; a self-hosted server's come from its
     admin);
   - `DOCS_MIRROR_SSH_KEY` = the private key's text.

   Then delete the local private key file.
6. From a checkout of this marketplace repository at the commit of the
   installed `glab` version (`plugins/glab/.claude-plugin/plugin.json`
   `version`) — the newest commit on `main` with that `version`, since one
   version can span several commits — copy
   `plugins/glab/templates/docs-mirror/docs-mirror.sh` to
   `.glab/docs-mirror.sh` (`chmod 755`) and the one CI file of the code
   repo's host: `github-docs-mirror.yml` to
   `.github/workflows/docs-mirror.yml` — when the code repo's default
   branch is not `main`, replace `main` on its `branches:` line, and leave
   the `run:` line's `main`, the mirror's branch — or
   `gitlab-docs-mirror.yml` to `.gitlab/docs-mirror.yml`, plus this entry
   in `.gitlab-ci.yml`'s `include:` list, or the key with it if the file
   has none:

       include:
         - local: .gitlab/docs-mirror.yml

   Merge them through the repo's own review. That merge makes the mirror's
   first commit.
7. GitLab only: protect that branch now. It became the mirror's default
   branch, protected by default but without the deploy key: put the deploy
   key, alone, in its *Allowed to push and merge* and turn *Allowed to
   force push* off. Until then the next run is refused.

**What happens when:**

- `docs/` did not change: no commit (`nothing to mirror`).
- A stale run — an earlier merge's run that finishes after a later one's:
  skipped, no commit.
- Someone edited the mirror by hand: the next run's commit stacks on the
  hand commits, puts back the tree of `docs/`, names them in its body
  (`Replaces <n> commit(s) not made by the mirror: …`) and warns; the
  history keeps them.
- A wrong target — the URL names a repository whose branch has commits but
  none made by the mirror: refused, nothing written.
- A shallow checkout: refused, naming `fetch-depth: 0` and `GIT_DEPTH: "0"`,
  which the templates already set.
- On GitLab, a merge whose pipeline has a failed job, or no job but this
  one (it runs in `stage: .post`), is not mirrored; the next merge's run
  is.
- The mirror cannot be reached or refuses the push: the run fails and
  prints up to four of git's first error lines, each starting
  `docs-mirror: git:`, with the remote shown as `<remote>`; the next run
  retries.
- A rewritten source — the default branch's history rewritten, so it no
  longer holds the commit the mirror last published: the run is refused
  and names the mirror's last source commit; set `DOCS_MIRROR_ADOPT` (a
  variable on GitHub, on the **Variables** tab, not a secret; a CI/CD
  variable on GitLab) to that full sha, merge the next change to the
  default branch, and delete the variable once that run has mirrored — a
  run that finds it non-empty and unused warns.

**Updating a copy:** `cmp` each copy with the same file of a checkout at
the newer version; a difference is the update.

**Not verified:** no hosted run yet, on either host — UNVERIFIED until your
first run; whether a re-run of a refused job sees a variable set after the
first attempt; on GitLab, that the first push into an empty project is
accepted under its default-branch protection, and that the job, whose
environment has `action: access`, creates the `docs-mirror` environment
on its first run and gets the key scoped to it (GitLab's docs say such a
job gets environment-scoped variables).

## Requirements

Linux with bash. `jq` is optional: without it the `glab` `SessionStart` hook
falls back to plain text, the level guard reads its input as plain text, and
the context hook says nothing — the session's manager then counts dispatches
instead (`glab:session-rules` Rule 2). A store clone (*The shared store*) needs `git`.
The docs mirror's CI job needs bash 4.4 or newer, git 2.28 or newer and an ssh
client on its runner. macOS is not supported.

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
   be a small `/tmp`.
2. Add the marketplace and install the plugins you use:

   ```bash
   claude plugin marketplace add glab-services/skills
   claude plugin install glab@glab-services
   claude plugin install glab-team@glab-services --scope local
   ```

   `glab-team` needs Node.js 24 or newer. Joining a broker and binding a project are in `src/glab-team/docs/setup.md`.

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

To register the marketplace and enable the plugin from settings instead of
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
    "glab@glab-services": true
  }
}
```

Every person still needs the access and the credential described above. In a
repository's settings the marketplace entry applies only once that person has
trusted the folder.

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

## Working on this repo

| Path | What it is |
|---|---|
| `AGENTS.md` | Working agreement for changes to this repo, and the gates |
| `.claude-plugin/marketplace.json` | The marketplace: lists the plugins |
| `plugins/` | The plugins. Payload: written for the sessions of whoever installs them. `plugins/glab-team/` is the build of `src/glab-team/`, committed with its `node_modules/`, and is rebuilt, never edited |
| `src/glab-team/` | The team messaging source — plugin, channel, broker, shared code, `scripts/build-plugin.mjs` and their Node.js tests — brought from glab-services/claude-plugins at `441887c` and maintained here, with no upstream. Its `AGENTS.md` holds the area's notes; this repo's `AGENTS.md` wins where they differ |
| `host.example.md` | Template for the per-machine `~/.claude/host.md` |
| `tests/` | The scripts' tests — the hooks, `plan-gate.sh`, `docs-mirror.sh` — and the product-loop walkthrough with its fixtures, `tests/fixtures/product-loop/`, and `tests/gates.sh`, every gate with its expected result |
| `plan/` | Working area: the files of changes in progress, removed on your word once each change is recorded |
| `docs/specs/` | One spec per area: how it works now, why, what is not verified, what is open |
| `docs/features/` | One page per feature: what it does and how to use it |
| `docs/one-fact.md` | The *One fact, one value* registry: each fact more than one file states, and the files that state it |

To try a change without installing anything, load the plugin for one session:
`claude --plugin-dir ./plugins/glab`, or `./plugins/glab-team`. Do not pass the repo root: the CLI does not read `marketplace.json` from a
`--plugin-dir`, so the plugin does not load — at most an empty plugin named after
the directory.

### The team messaging source

`src/glab-team/` is a pnpm workspace of its own. `tests/gates.sh` runs its two Node.js suites, `pnpm -s broker:test` and `pnpm -s channel:test`. Before any check the script needs Node.js 24 or newer as the `node` first on `PATH`, pnpm 10 or newer on `PATH`, and the workspace installed from its lockfile. Without any of them it stops with one line on stderr and exit 2. A host whose default `node` is older puts Node.js 24's `bin` first on `PATH`, as its host file says. Run `pnpm install --frozen-lockfile` in `src/glab-team` once, and again after `src/glab-team/pnpm-lock.yaml` changes; the install needs the npm registry, the gates do not, and `src/glab-team/.gitignore` ignores `node_modules/`. The suites take about one and two minutes and run with umask `0002`, because some tests make a group-writable directory and expect it to stay so. Each is `ok` when every failed or cancelled test is in its host list in `tests/gates.sh` — the tests that fail on the reference host, which has no IPv6 and runs as root, each with its reason — and its `ok` line names the known ones it saw; a failure outside the list is a `FAIL` that names it. The suites run with an empty home and Claude Code config directory of their own under the gates' work directory, never yours. With `TMPDIR` under `/tmp` the tests keep their temp files in `src/glab-team/.tmp/`, ignored too, and leave it empty.

`plugins/glab-team/` is what `src/glab-team/scripts/build-plugin.mjs` writes from the source, `node_modules/` included, because an install copies the directory and runs no install. To change the plugin, change the source, raise its version as `src/glab-team/AGENTS.md` says, remove `plugins/glab-team/` and run `pnpm -s plugin:build` in `src/glab-team`, with the npm registry reachable and `claude` on `PATH` under a new empty `CLAUDE_CONFIG_DIR`; the build refuses a directory that is not empty. `tests/gates.sh` checks the result: G23 validates it, G42–G44 compare its `plugin details` lines, and G45 builds the source again offline (`--no-install`) into a new directory under `src/glab-team/dist/`, removed after, and fails on any difference outside `node_modules/` — a byte, a file missing or added, an execute bit — and on a `node_modules/` whose packages differ from `src/glab-team/plugin/package-lock.json` by path, name or version. G45 does not read the files inside a package: a file edited in a package of the right version passes. A fresh build compared byte for byte, `node_modules/` included, needs the registry and is not a gate.
