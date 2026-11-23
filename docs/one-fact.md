# One fact, one value

The rule is in `AGENTS.md` *Rules* (*One fact, one value*); every fact listed
here is one that more than one file states, followed by the files that state
it.

## Round caps

the round caps — Stage 3 and Stage 5 at the project level, P1b and P7's
roadmap check at the product level, at most 2 rounds each at every tier, per
sub-plan where there are, never a third

- `plugins/glab/skills/session-rules/SKILL.md` *Round caps* and *The handoff line*
- `plugins/glab/skills/project-analyze/SKILL.md`
- `plugins/glab/skills/project-review/SKILL.md`
- `plugins/glab/skills/project-manager/references/without-subagents.md`
- and the reviewer's round-2 rule in `plugins/glab/agents/project-reviewer.md`
  *Re-reviews*

## The four ask-conditions

the four ask-conditions of `glab:session-rules` Rule 3 — destructive, costs
money, exposes real data, changes what the product is

- `plugins/glab/skills/session-rules/SKILL.md`
- `plugins/glab/skills/project-plan/SKILL.md` Step 2

## The missing-`AGENTS.md` fallback

the missing-`AGENTS.md` fallback

- every agent
- and the session-start text in `plugins/glab/scripts/manager-bootstrap.sh`

## The marketplace and plugin names

the marketplace and plugin names

- `.claude-plugin/marketplace.json`
- `plugins/glab/.claude-plugin/plugin.json`
- `plugins/glab-team/.claude-plugin/plugin.json` (the build of
  `src/glab-team/plugin/.claude-plugin/plugin.json`)
- `src/glab-team/channel/project-options.mjs` (`PLUGIN_ID`)
- `src/glab-team/channel/cli.mjs` (`PLUGIN_DATA_NAME`)
- the install commands of `src/glab-team/README.md`, `channel/README.md` and
  `docs/setup.md`
- `README.md`
- `tests/gates.sh`

## What each plugin holds

what each plugin holds — its component counts and its hook events

- `tests/gates.sh` (G24–G26, G42–G44)
- `README.md`
- each plugin's `hooks/hooks.json` (`glab-team`'s from
  `src/glab-team/plugin/hooks/hooks.json`)

## The model per role

the model per role — each agent's frontmatter `model` per the table, the
user's words overriding any role, no `model` parameter otherwise, and
`model <alias>` on every agent stage's handoff line

- `glab:session-rules` Rule 5 and *The handoff line* in
  `plugins/glab/skills/session-rules/SKILL.md`
- the eight `plugins/glab/agents/*.md`
- `README.md`
- and the model check (G33) in `tests/gates.sh`

## The skills each agent preloads

the skills each agent preloads — its frontmatter `skills:` list,
`glab:security` in all eight, `glab:project-plan` in the planner and
`glab:product-plan` in the product planner, and no preloaded skill setting
`disable-model-invocation`, which stops its preload

- the eight `plugins/glab/agents/*.md`
- `README.md`
- and the skills check (G34) in `tests/gates.sh`

## The reviewer's verdict lines

the reviewer's verdict lines

- `plugins/glab/agents/project-reviewer.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/project-review/SKILL.md`
- `plugins/glab/skills/project-ship/SKILL.md`

## The severity levels

the severity levels — `critical`, `high`, `medium`, `low` — their meanings in
`plugins/glab/skills/severity/SKILL.md` only, which
`plugins/glab/skills/audit/SKILL.md` points at, their four names in the
*Report* of `plugins/glab/agents/project-reviewer.md`,
`plugins/glab/agents/project-analyzer.md` and
`plugins/glab/agents/product-analyzer.md`

## Every round a new agent

every round a new agent, Rule 5's report check the one resume

- `plugins/glab/skills/session-rules/SKILL.md` Rules 2 and 5
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/project-review/SKILL.md`
- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-ship/SKILL.md`
- `plugins/glab/agents/project-reviewer.md`
- `plugins/glab/agents/project-developer.md`

## The mapping, evidence, round and version files

the mapping files `map-<area>.md`, the evidence file `evidence.md` — a
subagent's Write of `findings.md` is refused — the round copies
`<name>.r<n>.md` and the version copies `master.v<n>.md`

- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/agents/project-developer.md`
- for the round copies only: `plugins/glab/scripts/plan-gate.sh`, which leaves
  them out of the digest, `plugins/glab/skills/project-plan-report/SKILL.md`
  and `plugins/glab/skills/product-plan-analyze/SKILL.md`

## The handoff file

the handoff file `plan/handoff/<session id>.md` — at most 4096 bytes, its
`- status:` first line, and the standing approval that removes a completed one

- `plugins/glab/skills/session-rules/SKILL.md` Rule 2
- `plugins/glab/skills/bootstrap/SKILL.md` step 5
- the pointers in `plugins/glab/skills/security/SKILL.md` and Rule 3
- `plugins/glab/scripts/manager-bootstrap.sh`
- `tests/manager-bootstrap.test.sh`

## The `glab` context hook

the `glab` context hook — the modes `prompt`, `agent` and `stop` on
`UserPromptSubmit`, `PostToolUse` with matcher `Agent` and `Stop`, the line
`glab: context <n>k (last completed call)`, with `; compact at <t>k` before
the `)` when `GLAB_COMPACT_AT` is set, the `Stop` message, and the first step
300k, or `GLAB_COMPACT_AT` thousand when set, and every 100k after it, and the
warning for an invalid value

- `plugins/glab/scripts/context-size.sh`
- `tests/context-size.test.sh`
- `plugins/glab/hooks/hooks.json`
- `plugins/glab/skills/session-rules/SKILL.md`
- `README.md`

## The `glab` guard hook

the `glab` guard hook — the modes `skill` and `bash` on `PreToolUse` with
matchers `Skill` and `Bash|PowerShell|Monitor`, `deny` and `ask` only, and the
texts of the deny reason and the ask reason

- `plugins/glab/scripts/level-guard.sh`
- `tests/level-guard.test.sh`
- `plugins/glab/hooks/hooks.json`
- `plugins/glab/skills/session-rules/SKILL.md` *The level boundary*
- `plugins/glab/skills/product-manager/SKILL.md` *The cap*
- `AGENTS.md` *Rules*
- `README.md`

## What a later review round is given

what a review round after the first is given — a new reviewer, the target, the
previous round's findings verbatim and the range of the fix, never the plan,
the slug or the intent

- `plugins/glab/skills/project-review/SKILL.md`
- and what the reviewer does with them in
  `plugins/glab/agents/project-reviewer.md`

## The plan lifecycle

the plan lifecycle — `/plan/` ignored by git and never committed; after the
commits and before the push the record writes specs in `docs/specs/` and feature pages in
`docs/features/` (the product level: `docs/roadmap/<slug>.md`), unless
`AGENTS.md` names other places; a *Records* line, a spec's or a roadmap
page's, names the date, the slug and the change's commits by both ends,
`<first>` and `<last>`, the branch and the PR when one exists, since a squash or rebase merge can give the commits new shas; the
record never removes the plan folder; the manager removes it only on the
user's word, asked at a session start once the record has landed
(`glab:bootstrap` step 5, `glab:session-rules` Rule 2)

- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-record/SKILL.md`
- `plugins/glab/agents/project-developer.md`
- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/skills/bootstrap/SKILL.md`
- `plugins/glab/skills/audit/SKILL.md`
- `README.md`
- `plugins/glab/skills/session-rules/SKILL.md` Rule 2
- `plugins/glab/skills/project-manager/SKILL.md` Stage 7
- `plugins/glab/skills/push/SKILL.md` step 4
- `plugins/glab/agents/committer.md`
- `plugins/glab/skills/product-manager/SKILL.md` P7
- `plugins/glab/skills/product-plan/SKILL.md` *The roadmap*
- `plugins/glab/agents/product-planner.md`
- `plugins/glab/agents/product-analyzer.md`
- `.gitignore`
- and `AGENTS.md`'s `plan/` rule

## Where the record is committed

where the record is committed — on the change's branch, after its commits and
before its push, so it goes out in the same push

- `plugins/glab/skills/project-record/SKILL.md`
- and `AGENTS.md`'s `plan/` rule

## The session effort

the session effort — the Agent tool's `effort` on every subagent dispatch, its
order (the level the user named for the session, then
`CLAUDE_CODE_EFFORT_LEVEL`, then ask once per session), its `- effort:` record
line, the override for one agent, role or task, and `· effort <level>` in the
handoff line

- `glab:session-rules` Rules 0d and 5 and *The handoff line* in
  `plugins/glab/skills/session-rules/SKILL.md`
- the one pointer line in `plugins/glab/scripts/manager-bootstrap.sh`
- `README.md`

## The plan size budget

the plan size budget — 48 KB each for `master.md`, `plan.md`, `index.md` and
`evidence.md`, and the product level's `product-plan.md`, and the `- size:`
line

- `plugins/glab/skills/project-plan/SKILL.md` Step 3
- `plugins/glab/skills/product-plan/SKILL.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md` check 2

## Amendments in place

amendments replace the text they change, in place

- `plugins/glab/skills/project-plan/SKILL.md` *Amending*

## `glab:project-plan`'s step numbers

`glab:project-plan`'s step numbers — 0 to 3

- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/agents/project-planner.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md`

## The master plan and sub-plans

the master plan and sub-plans — `master.md` with its six sections, constant
after `## Approval` and hashed in `master.sha256`, a changed request a new
master with the old kept as `master.v<n>.md` and its approval and hash not
carried over, `index.md`, the folders `<nn>-<name>/`, the user's approval of
every full-tier `plan.md`, a single plan's or a sub-plan's, one commit per
sub-plan, one record and one push per slug, and `## Record` in the
master

- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md`
- `plugins/glab/agents/project-developer.md`
- `plugins/glab/skills/project-analyze/SKILL.md`
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/audit/SKILL.md`
- `README.md`

## The intent check

the intent check — `glab:project-analyzer` at Stage 3, never the reviewer

- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/skills/project-analyze/SKILL.md`
- `README.md`

## The analyzers' verdict lines

the analyzers' verdict lines — `CONFORMS`, `DIVERGES: <n> steps` and
`BLOCK: target unresolved` (`glab:project-analyzer`), and
`glab:product-analyzer`'s `SOUND`, `NOT SOUND: <n> findings`, `NO CONFLICT`
and `CONFLICTS: <n>`

- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/project-analyze/SKILL.md`
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/project-plan-report/SKILL.md`
- `plugins/glab/skills/project-review/SKILL.md`
- `plugins/glab/skills/project-record/SKILL.md`
- `plugins/glab/agents/product-analyzer.md`
- `plugins/glab/skills/product-manager/SKILL.md`
- `plugins/glab/skills/product-plan-analyze/SKILL.md`
- `plugins/glab/skills/product-project-plan-analyze/SKILL.md`
- `plugins/glab/skills/product-project-plan-verdict/SKILL.md`

## The level line `glab-level:`

the level line `glab-level:` — the first line of a repo's `AGENTS.md` that
begins `glab-level:`; `product` and `project` built, no line the project
level, any other value the project level with the warning, `delivery` and
`support` reserved

- `plugins/glab/scripts/glab-level.sh`
- `plugins/glab/scripts/manager-bootstrap.sh`
- `plugins/glab/scripts/level-guard.sh`
- `tests/manager-bootstrap.test.sh`
- `tests/level-guard.test.sh`
- `tests/product-loop.test.sh`
- `plugins/glab/skills/bootstrap/SKILL.md`
- `README.md`

## The shared store line `glab-shared-store:`

the shared store line `glab-shared-store:` — the repo's `AGENTS.md` first,
then the host file

- `plugins/glab/skills/product-manager/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md` *Dispatching the planner*
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/project-plan-report/SKILL.md`
- `README.md`
- `host.example.md`

## The git store

the git store — a clone whose top holds `.git` with `glab.store` `true`;
`plan-gate.sh` fetches before it reads and commits and pushes what it
writes, as `glab plan-gate <plan-gate@glab.invalid>`, subjects
`store(report|verdict|sync): …`, at most 5 pushes per run;
`sync <store> [product-manager]` before a read, and after the planner's
briefs and rules

- `plugins/glab/scripts/plan-gate.sh`
- `tests/plan-gate.test.sh`
- `plugins/glab/skills/product-project-brief/SKILL.md`
- `plugins/glab/skills/product-project-plan-analyze/SKILL.md`
- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-plan-report/SKILL.md`
- `plugins/glab/skills/session-rules/SKILL.md` Rule 3 (the store-push exception)
- `plugins/glab/agents/project-planner.md`
- `AGENTS.md` *Rules*
- `README.md` *The shared store*
- `host.example.md`

## The store layout

the store layout — `docs/product-rules/` with `index.md`,
`briefs/<project>/brief.md`, `report.r<n>.md`, `plan.r<n>/`,
`verdict.r<n>.md`, `releases/` reserved

- `plugins/glab/scripts/plan-gate.sh`
- `plugins/glab/skills/product-manager/SKILL.md` *The shared store*
- `plugins/glab/skills/product-plan/SKILL.md`
- `README.md`

## The docs mirror

the docs mirror — its templates `plugins/glab/templates/docs-mirror/` `docs-mirror.sh`,
`github-docs-mirror.yml`, `gitlab-docs-mirror.yml`; the copies `.glab/docs-mirror.sh`,
`.github/workflows/docs-mirror.yml` and `.gitlab/docs-mirror.yml`; the variables
`DOCS_MIRROR_URL`, `DOCS_MIRROR_KNOWN_HOSTS`, `DOCS_MIRROR_SSH_KEY`, `DOCS_MIRROR_ADOPT`;
commits as `glab docs-mirror <docs-mirror@glab.invalid>`, subject `docs: mirror <12 hex>`,
last line `Source-Commit: <sha>`, the `Replaces …` and `Adopts …` paragraphs; its `REFUSED:`,
`skipped` and `docs-mirror: git:` lines; bash 4.4, git 2.28; at most 4 `docs-mirror: git:`
lines (the script, `README.md`, the test's DM19); GitLab's `stage: .post` (`README.md`, the GitLab
template, DM21); `main` as the GitHub mirror's branch (`README.md` step 4, the GitHub template's
`run:` line, DM21); the GitLab job's environment `docs-mirror`, which the key variable is scoped to
(`README.md` step 5, the GitLab template, DM21); the GitHub workflow's concurrency group
`glab-docs-mirror` (the GitHub template, DM21)

- `plugins/glab/templates/docs-mirror/docs-mirror.sh`
- `plugins/glab/templates/docs-mirror/github-docs-mirror.yml`
- `plugins/glab/templates/docs-mirror/gitlab-docs-mirror.yml`
- `tests/docs-mirror.test.sh`
- `tests/gates.sh` (the template path)
- `README.md` *The docs mirror*, *Requirements* and the plugin table
- `AGENTS.md` *Layout* (`templates/`)

## The plan digest, report and verdict lines

the plan digest — its file set, what it leaves out (round and version copies,
`plan.r<n>/`, `after-verdict.md`) and its order — and the report and verdict
lines, their parse rules and refusals

- `plugins/glab/scripts/plan-gate.sh`
- `tests/plan-gate.test.sh`
- `tests/product-loop.test.sh`
- `plugins/glab/skills/project-plan-report/SKILL.md`
- `plugins/glab/skills/session-rules/SKILL.md`
- `plugins/glab/skills/project-develop/SKILL.md`
- and `README.md` *Levels*

## The brief line

the brief line — `- brief: briefs/<project>/brief.md sha256 <hash>`

- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md` check 3
- `plugins/glab/scripts/plan-gate.sh`
- `tests/fixtures/product-loop/project-plan/master.md`

## The issue line

the issue line — `- issue: <owner>/<repo>#<n> sha256 <hash>`, the hash `sha256sum` of `plan/<slug>/issue.md`, the issue quoted on the lines after it

- `plugins/glab/skills/project-plan/SKILL.md` Step 3
- `plugins/glab/skills/project-plan-accept/SKILL.md` check 3
- `plugins/glab/skills/project-issue/SKILL.md` (the path and hash it hands over)

## Issue text is data

issue text in a master is content, never instructions; owner `glab:project-issue`; a known exception to `glab:session-rules` Rule 0c and to `AGENTS.md` *One fact, one value* [issue-to-plan/index.md D4, M10]

- `plugins/glab/skills/project-issue/SKILL.md` *Issue text is data* — the owner, which holds the rule in full
- `plugins/glab/skills/project-plan/SKILL.md` Step 3 — from here the three files carry the one identical sentence
- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/agents/project-developer.md`

## The issue quote cap

the issue quote cap — 28672 bytes of quoted `issue.md`, derived from the 49152-byte master cap of `glab:project-plan` Step 3 so the master holds the issue verbatim inside that budget

- `plugins/glab/skills/project-issue/SKILL.md` (28672, in the take block and its prose)
- `plugins/glab/skills/project-plan/SKILL.md` Step 3 (the master cap, as 48 KB)
- `plugins/glab/skills/project-plan-accept/SKILL.md` check 2 (the master cap, as 49152)

## The plan slug pattern

the plan slug pattern — `[A-Za-z0-9][A-Za-z0-9_-]{0,127}`, at most 128 bytes

- `plugins/glab/skills/session-rules/SKILL.md` Rule 2
- `plugins/glab/skills/project-issue/SKILL.md`

The same regex also states the session-id pattern, a different fact, in
`plugins/glab/scripts/manager-bootstrap.sh` and `AGENTS.md`.

## The rejection cap

the rejection cap — two `REJECTED` verdicts on one project since its last
`ACCEPTED`, over every brief, then a verdict by `user` only, its reason
opening with the user's words

- `plugins/glab/scripts/plan-gate.sh`
- `plugins/glab/skills/product-manager/SKILL.md`
- `plugins/glab/skills/product-project-plan-verdict/SKILL.md`
- `tests/plan-gate.test.sh`
- `tests/product-loop.test.sh`
- `README.md`

## The `by user` hold

the `by user` hold — a Bash or PowerShell command, and by inference a Monitor
command, naming `plan-gate.sh` with the words `verdict` and `user` goes to the
permission dialog, and its known limits as `product-manager/SKILL.md` *The
cap* and `README.md` *Known limits* state them

- `plugins/glab/scripts/level-guard.sh`
- `tests/level-guard.test.sh`
- `plugins/glab/skills/product-manager/SKILL.md` *The cap*
- `README.md` *Known limits*

## The rule file budget

the rule file budget — 8192 bytes

- `plugins/glab/skills/product-plan/SKILL.md`
- `tests/product-loop.test.sh`

## The rules of every level

the rules of every level — Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, *Round caps*,
*The handoff line* and *The level boundary* in `glab:session-rules`, which
each level's manager loads and cites by number

- `plugins/glab/skills/session-rules/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/product-manager/SKILL.md`
- `plugins/glab/scripts/manager-bootstrap.sh`
- `plugins/glab/skills/bootstrap/SKILL.md`
- `README.md`

## The level boundary

the level boundary — each manager's *Your skills — this level only* the
binding list, a description's level prefix `Product level — ` or
`Project level — ` a hint, no prefix on what serves every level;
`level-guard.sh` reads the list from that section — its heading
`## Your skills — this level only`, its `- **` bullets, one line each, but the
agents' — and refuses a Skill call to a `glab:` skill not on it

- `plugins/glab/skills/session-rules/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/product-manager/SKILL.md`
- `plugins/glab/scripts/manager-bootstrap.sh`
- `plugins/glab/scripts/level-guard.sh`
- `tests/level-guard.test.sh`
- the `description:` of every `plugins/glab/skills/*/SKILL.md` and
  `plugins/glab/agents/*.md`
- `README.md`

## The team messaging source and its toolchain

the team messaging source at `src/glab-team/`, and what its suites need —
Node.js 24 or newer as the `node` first on `PATH`, pnpm 10 or newer, and
`pnpm install --frozen-lockfile` run in it

- `tests/gates.sh` (the preflight, G40–G41 and G45)
- `AGENTS.md` *Layout* and *Gates*
- `README.md` *Working on this repo*
- `host.example.md` *Tool paths* (where Node.js 24 is on a host)
- and, for Node.js 24, the source's own files: `src/glab-team/package.json`,
  `channel/package.json` and `plugin/package.json` (`engines`), `AGENTS.md`,
  `README.md`, `broker/README.md`, `channel/README.md` and `docs/setup.md`

## The committed glab-team build

`plugins/glab-team/` is the output of `src/glab-team/scripts/build-plugin.mjs`, never edited by hand

- `AGENTS.md` *Layout*
- `README.md` *Working on this repo*
- `tests/gates.sh` (G45)
- `src/glab-team/scripts/build-plugin.mjs` (its admitted target)
- `src/glab-team/package.json` (`plugin:build`)
- `src/glab-team/AGENTS.md`, `README.md` and `channel/README.md`

## The glab-team version

the `glab-team` version

- `src/glab-team/plugin/.claude-plugin/plugin.json`
- `src/glab-team/plugin/package.json`
- `src/glab-team/plugin/package-lock.json`
- `src/glab-team/channel/version.mjs`
- the tests that assert it: `src/glab-team/channel/test/plugin-env.test.mjs`
  and `channel/test/project-agent.test.mjs`
- and its build in `plugins/glab-team/`

## The earlier plugin id

the id `glab-team` replaces, `team-messaging@team-messaging-local`, and what a user of it does

- `README.md` *Moving to glab-team*
- `src/glab-team/docs/setup.md` *Moving from …*
