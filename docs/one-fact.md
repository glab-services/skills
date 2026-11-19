# One fact, one value

The rule is in `AGENTS.md` *Rules* (*One fact, one value*); every fact listed
here is one that more than one file states, followed by the files that state
it.

## Round caps

the round caps — Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b),
and P1b at the product level, P7's roadmap check at most 2 rounds and never a
third, at most 2 rounds at every tier, per sub-plan
where there are, a third only on a `critical` or `high` finding of round 2,
recorded first as a `## Decisions` line, or in the handoff line and this
conversation when there is no plan, none past 3

- `plugins/glab/skills/session-rules/SKILL.md` *Round caps*
- `plugins/glab/skills/project-plan-analyze/SKILL.md`
- `plugins/glab/skills/product-manager/SKILL.md` P7
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

## The `memory-sync` hook events

the hook events

- `plugins/memory-sync/hooks/hooks.json`
- `README.md`
- `plugins/memory-sync/skills/sync-memory/SKILL.md`
- the header of `plugins/memory-sync/scripts/memory-sync.sh`

## The default time limit of `memory-sync.sh`

the default time limit of `memory-sync.sh`

- the script
- its test
- `README.md`

## The marketplace and plugin names

the marketplace and plugin names

- `.claude-plugin/marketplace.json`
- both `plugin.json`
- `README.md`
- `tests/gates.sh`

## What each plugin holds

what each plugin holds — its component counts and its hook events

- `tests/gates.sh`
- `README.md`
- each plugin's `hooks/hooks.json`

## The 20-second hook timeout of `memory-sync`

the 20-second hook timeout of `memory-sync`

- every `timeout` in `plugins/memory-sync/hooks/hooks.json`
- the comments in the script that reason from it
- `README.md`

## The largest time limit, 17

the largest time limit the script accepts, 17

- the script
- its test
- `README.md`

## The `SessionEnd` budget and its hedge

the 1.5-second `SessionEnd` budget and the hedged sentence about its override

- the script comment
- the `memory-sync:sync-memory` skill
- `README.md`
- `tests/gates.sh`
- and the `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key in the plugin's
  settings example

## The model per role

the model per role — each agent's frontmatter `model` per the table, the
user's words overriding any role, no `model` parameter otherwise, and
`model <alias>` on every agent stage's handoff line

- `glab:session-rules` Rule 5 and *The handoff line* in
  `plugins/glab/skills/session-rules/SKILL.md`
- the nine `plugins/glab/agents/*.md`
- `README.md`
- and the model check (G33) in `tests/gates.sh`

## The skills each agent preloads

the skills each agent preloads — its frontmatter `skills:` list,
`glab:security` in all nine, `glab:project-plan` in the planner and
`glab:product-plan` in the product planner, and no preloaded skill setting
`disable-model-invocation`, which stops its preload

- the nine `plugins/glab/agents/*.md`
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
`plugins/glab/agents/project-analyzer.md`,
`plugins/glab/agents/project-plan-analyzer.md` and
`plugins/glab/agents/product-analyzer.md`

## Every round a new agent

every round a new agent, Rule 5's report check the one resume

- `plugins/glab/skills/session-rules/SKILL.md` Rules 2 and 5
- `plugins/glab/skills/project-plan-analyze/SKILL.md`
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/project-review/SKILL.md`
- `plugins/glab/skills/project-record/SKILL.md`
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
- `plugins/glab/skills/project-plan-analyze/SKILL.md`
- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/agents/project-plan-analyzer.md` (all but the version copies)
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
push the record writes specs in `docs/specs/` and feature pages in
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
- `plugins/glab/skills/project-manager/SKILL.md` Stage 8
- `plugins/glab/skills/push/SKILL.md` step 4
- `plugins/glab/agents/committer.md`
- `plugins/glab/agents/project-plan-analyzer.md`
- `plugins/glab/skills/product-manager/SKILL.md` P7
- `plugins/glab/skills/product-plan/SKILL.md` *The roadmap*
- `plugins/glab/agents/product-planner.md`
- `plugins/glab/agents/product-analyzer.md`
- `.gitignore`
- and `AGENTS.md`'s `plan/` rule

## Where the record is committed

where the record is committed — on the change's branch, after its push and
before its merge

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
- `plugins/glab/skills/project-plan-accept/SKILL.md` checklist item 6

## Amendments in place

amendments replace the text they change, in place

- `plugins/glab/skills/project-plan/SKILL.md` Step 4
- `plugins/glab/agents/project-plan-analyzer.md` *Re-checks*

## `glab:project-plan`'s step numbers

`glab:project-plan`'s step numbers — 0 to 4

- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/agents/project-planner.md`
- `plugins/glab/agents/project-plan-analyzer.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md`
- `plugins/glab/skills/project-plan-analyze/SKILL.md`

## The master plan and sub-plans

the master plan and sub-plans — `master.md` with its six sections, constant
after `## Approval` and hashed in `master.sha256`, a changed request a new
master with the old kept as `master.v<n>.md` and its approval and hash not
carried over, `index.md`, the folders `<nn>-<name>/`, the user's approval of
every full-tier `plan.md`, a single plan's or a sub-plan's, one commit per
sub-plan, one final check, push and record per slug, and `## Record` in the
master

- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md`
- `plugins/glab/agents/project-plan-analyzer.md`
- `plugins/glab/agents/project-developer.md`
- `plugins/glab/skills/project-analyze/SKILL.md`
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/audit/SKILL.md`
- `README.md`

## The intent check

the intent check — the analyzers at Stage 1b (`glab:project-plan-analyzer`),
Stage 3 and the final check (`glab:project-analyzer`), never the reviewer

- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/agents/project-plan-analyzer.md`
- `plugins/glab/skills/project-analyze/SKILL.md`
- `README.md`

## The analyzers' verdict lines

the analyzers' verdict lines — `BUILDABLE`, `NOT BUILDABLE`
(`glab:project-plan-analyzer`), `CONFORMS`, `DIVERGES: <n> steps`
(`glab:project-analyzer`), `BLOCK: target unresolved` (all three), and
`glab:product-analyzer`'s `SOUND`, `NOT SOUND: <n> findings`, `NO CONFLICT`
and `CONFLICTS: <n>`

- `plugins/glab/agents/project-analyzer.md`
- `plugins/glab/agents/project-plan-analyzer.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/project-analyze/SKILL.md`
- `plugins/glab/skills/project-plan/SKILL.md`
- `plugins/glab/skills/project-plan-analyze/SKILL.md`
- `plugins/glab/skills/project-develop/SKILL.md`
- `plugins/glab/skills/project-plan-report/SKILL.md`
- `plugins/glab/skills/project-review/SKILL.md`
- `plugins/glab/skills/project-record/SKILL.md`
- `plugins/glab/agents/product-analyzer.md`
- `plugins/glab/skills/product-manager/SKILL.md`
- `plugins/glab/skills/product-plan-analyze/SKILL.md`
- `plugins/glab/skills/product-project-plan-analyze/SKILL.md`
- `plugins/glab/skills/product-project-plan-verdict/SKILL.md`

## Approval in plan mode

approval in plan mode — only when the user asks, no plan file outside the
repo, `plansDirectory` never changed, its claims UNVERIFIED until L1–L7

- `plugins/glab/skills/project-plan-accept/references/plan-mode.md`
- `plugins/glab/skills/project-manager/SKILL.md`
- `plugins/glab/skills/project-plan-accept/SKILL.md`
- `README.md`

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
- `plugins/glab/skills/project-plan-accept/SKILL.md` checklist item 8
- `plugins/glab/scripts/plan-gate.sh`
- `tests/fixtures/product-loop/project-plan/master.md`

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
