# Steps 2 — the product level (P1–P9)

Each new skill is `plugins/glab/skills/<name>/SKILL.md` with frontmatter
`name: <name>` (bare, equal to its directory) and a `description:` that
begins with its level; no `disable-model-invocation`, `user-invocable`,
`allowed-tools` or `model` key (`evidence.md` *Scope*, the binding
decisions). An entry-point skill takes `$ARGUMENTS` as its one argument and,
with none, asks which one — never the most recent — as `glab:manager` *The
pipeline* says of stage skills. Payload names components by their prefixed
name (`AGENTS.md` *Rules*). Each rule is written once, in the file of the
role that acts on it; the others point at it. The contracts C1–C10 are in
`plan.md`; a skill cites them by what they say, never by `C<n>`, because the
plan folder is not shipped.

### P1 — `glab:product-manager`, the product level's operating model

Create `plugins/glab/skills/product-manager/SKILL.md`. It holds, as its own
sections:

- **Rule 0** — the working agreement first, as the session-start text says; then resolve the shared store from its line (C2) and say which path it is; none → stop and ask the user for it.
- **The rules it borrows** — the required text `` `glab:manager` Rules 0b, 0c, 0d, 2, 3 and 5 hold at every level `` and that this session reads those rules from `glab:manager`, follows them, and never runs `glab:manager`'s pipeline or its stage skills.
- **Your skills — this level only** — the product skills `glab:product-plan` (the procedure `glab:product-planner` preloads), `glab:product-plan-analyze`, `glab:product-project-brief`, `glab:product-project-plan-analyze`, `glab:product-project-plan-verdict`; the every-level skills `glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`, `glab:commit`, `glab:push`; the agents `glab:product-planner`, `glab:product-analyzer`, `glab:committer`. Required text: `Never invoke a skill whose description begins Project level`. `[N3]`
- **The shared store** — C3's layout, the store-relative paths every committed file uses, and the reserved `releases/` folder for the delivery level.
- **The product pipeline** — a table of the stages P1 product plan (`glab:product-planner` on the business plan the user names), P1b product plan check (`glab:product-plan-analyze`, its rounds capped as `glab:manager` *Pick the tier* caps Stage 1b — a pointer, the cap not restated), approval (the user, always, explicit: an `## Approval` line at the end of `product-plan.md`), P2 briefs and rules (`glab:product-project-brief`), P3 project sessions, P4 the audit of each report (`glab:product-project-plan-analyze`), P5 the verdict (`glab:product-project-plan-verdict`), P6 commit and push of the product repo (`glab:commit`, `glab:push`). Required text: `## The product pipeline`.
- **Starting project sessions** — on the user's go-ahead, once per batch of briefs: the host's own session-start tool when the session has one, else `claude --bg` run in the project repo with the prompt that names the brief's store path; or the user starts each one. Either way the project session is told `take the brief at <store>/briefs/<project>/brief.md`. Required text: `claude --bg`. UNVERIFIED in a live session (LP4), and the skill says so.
- **Waiting for reports** — a report arrives as `report.r<n>.md` in the brief's folder; this session ends its turn with the briefs it waits on in the handoff file, and is resumed by a message.
- **The cap** — required text: `two REJECTED verdicts on one brief, then the user decides`; at the cap, the next report goes to the user with both reasons, and the user's words are the reason of the verdict written `by user`.

- post: `` P plugins/glab/skills/product-manager/SKILL.md 'name: product-manager' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '`glab:manager` Rules 0b, 0c, 0d, 2, 3 and 5 hold at every level' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'Never invoke a skill whose description begins Project level' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '## The product pipeline' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'claude --bg' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'two REJECTED verdicts on one brief, then the user decides' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'glab-shared-store:' ``

### P2 — `glab:product-plan`, the product planner's procedure

Create `plugins/glab/skills/product-plan/SKILL.md`, the procedure
`glab:product-planner` preloads and a user can run by typing
`/glab:product-plan <path to the business plan>`. It defines:

- **The product plan** — the folder `plan/<slug>/` of the product repo and one file `product-plan.md`, at most 49152 bytes, with the sections `## Business plan` (its path and `sha256sum`, and the user's words that define it, verbatim), `## Goals` (`P1`, `P2`, …), `## Projects` (one subsection per project: its kebab-case name, goal, scope, out of scope, the product-rule files that apply, its seams with the other projects), `## Rules to add` (drafts of new rule files, or `none`), `## Decisions`, and `## Questions` (only what meets a `glab:manager` Rule 3 ask-condition). Required text: `## Projects`.
- **The briefs** — after the plan's `## Approval`, one `<store>/briefs/<project>/brief.md` per project, with the sections `## Goal`, `## Scope`, `## Out of scope`, `## Product rules` (store-relative paths, `docs/product-rules/<name>.md`, each existing), `## Seams` and `## Acceptance` (what the audit will hold the plan to); a brief is the project's whole request, so it cites nothing the project cannot read. Required text: `## Acceptance`.
- **The product rules** — the user's; a draft from `## Rules to add` is written to `<store>/docs/product-rules/<name>.md` only after the plan's approval, one topic per file, at most 8192 bytes, and `index.md` gains its line `- <name>.md — <what it covers>`. Required text: `at most 8192 bytes`.
- Where it stops: the plan or the briefs written; checks, approvals and verdicts are the product manager's.

- post: `` P plugins/glab/skills/product-plan/SKILL.md 'name: product-plan' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md '## Projects' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md '## Acceptance' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md 'at most 8192 bytes' ``

### P3 — `glab:product-plan-analyze`, the product plan check

Create `plugins/glab/skills/product-plan-analyze/SKILL.md`: the entry point
of stage P1b. `$ARGUMENTS` is the product plan's slug. It dispatches
`glab:product-analyzer` for **the product plan check** on
`plan/<slug>/product-plan.md`, and goes on by its verdict: `SOUND` → the
user's approval; `NOT SOUND: <n> findings` → a new `glab:product-planner`
amends from the findings, round copy `product-plan.r<n>.md` kept first.

- post: `` P plugins/glab/skills/product-plan-analyze/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-plan-analyze/SKILL.md 'NOT SOUND: <n> findings' ``

### P4 — `glab:product-project-brief`, the briefs

Create `plugins/glab/skills/product-project-brief/SKILL.md`: the entry point
of stage P2. `$ARGUMENTS` is the product plan's slug. Precondition:
`product-plan.md` ends with an `## Approval` line; none → stop. It dispatches
`glab:product-planner` to write the briefs and the approved rule drafts, as
`glab:product-plan` says, then lists the briefs written by their store paths.
Required text: `ends with an ## Approval line`.

- post: `` P plugins/glab/skills/product-project-brief/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-project-brief/SKILL.md 'ends with an ## Approval line' ``

### P5 — `glab:product-project-plan-report`, the project's report (project level)

Create `plugins/glab/skills/product-project-plan-report/SKILL.md`, with a
description that begins `Project level — ` and says it is the product
chain's contract that the project manager runs. `$ARGUMENTS` is the project
plan's slug. Preconditions: `master.md` has the brief line (C5) and its
`## Approval`, and at full tier `plan.md` has its own; the store resolved
(C2). It runs
`"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" report plan/<slug> <store> [<note file>]`
— the note, at most 10 lines from the planner's report and any question for
product, written by the manager in the session's temp directory — shows the
path it printed or the refusal, and stops: the session waits for the verdict
(`glab:manager` Stage 1c). Required text: `plan-gate.sh" report`.

- post: `` P plugins/glab/skills/product-project-plan-report/SKILL.md 'description: Project level — ' ``
- post: `` P plugins/glab/skills/product-project-plan-report/SKILL.md 'plan-gate.sh" report' ``

### P6 — `glab:product-project-plan-analyze`, the audit of a project plan

Create `plugins/glab/skills/product-project-plan-analyze/SKILL.md`: the
entry point of stage P4. `$ARGUMENTS` is `<project>`. It finds the latest
`report.r<n>.md` in `<store>/briefs/<project>/`, and dispatches
`glab:product-analyzer` for **the project plan audit**, naming the brief, the
report, `plan.r<n>/` and the rules index. It goes on by the verdict:
`NO CONFLICT` or `CONFLICTS: <n>` → stage P5.

- post: `` P plugins/glab/skills/product-project-plan-analyze/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-project-plan-analyze/SKILL.md 'the project plan audit' ``

### P7 — `glab:product-project-plan-verdict`, the verdict

Create `plugins/glab/skills/product-project-plan-verdict/SKILL.md`: the
entry point of stage P5. `$ARGUMENTS` is `<project>`. On the audit's
`NO CONFLICT`: `ACCEPTED`, the reason one line naming the rules checked; on
`CONFLICTS: <n>`: `REJECTED`, each conflict one line of the reason with the
rule file it breaks. The session writes the reason to a file in its temp
directory and runs
`"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" verdict <store> <project> ACCEPTED|REJECTED product-manager <reason file>`;
the script's refusal at the cap is the point where the user decides
(`glab:product-manager` *The cap*), and the verdict is then written
`by user` with the user's words. It then tells the project session, or the
user, that the verdict is there. Required text: `plan-gate.sh" verdict`.

- post: `` P plugins/glab/skills/product-project-plan-verdict/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-project-plan-verdict/SKILL.md 'plan-gate.sh" verdict' ``

### P8 — the agent `glab:product-planner`

Create `plugins/glab/agents/product-planner.md` with the frontmatter
`name: product-planner`, a `description:` beginning `Product level — `,
`model: opus` `[Q1]`, `tools: Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch`
(no `Skill`, no `Agent`), and `skills:` `glab:product-plan` and
`glab:security`. Its body: read `AGENTS.md` first (no `AGENTS.md` → read
`CLAUDE.md` and say plainly the repo has none); follow the preloaded
`glab:product-plan`; write only the product plan folder its dispatch names,
and in the store only the briefs and rule files that dispatch grants; never
stage, commit or push; *Report* at most 12 lines (the slug, the projects, the
decisions, any question with its recommended answer, the files written,
anything UNVERIFIED).

- post: `` P plugins/glab/agents/product-planner.md 'name: product-planner' ``
- post: `` P plugins/glab/agents/product-planner.md 'description: Product level — ' ``
- post: `` P plugins/glab/agents/product-planner.md 'model: opus' ``
- post: `` P plugins/glab/agents/product-planner.md 'tools: Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch' ``
- post: `` P plugins/glab/agents/product-planner.md '- glab:product-plan' ``

### P9 — the agent `glab:product-analyzer`

Create `plugins/glab/agents/product-analyzer.md` with the frontmatter
`name: product-analyzer`, a `description:` beginning `Product level — `,
`model: opus` `[Q1]`, `tools: Read, Grep, Glob, Bash`, and `skills:`
`glab:security` and `glab:audit`. Its body: read `AGENTS.md` first (the same
fallback); read-only, writes nothing, returns its findings as text; two
checks, named in its dispatch —

- **the product plan check**: each goal reaches a project, each project is one a brief can state alone, the rule files it cites exist, the seams between projects agree; ends `SOUND` or `NOT SOUND: <n> findings`;
- **the project plan audit**: reads the brief, the report, the copies in `plan.r<n>/`, then `docs/product-rules/index.md` and only the rule files the brief names or the plan touches; each finding cites the rule file and the plan step; ends `NO CONFLICT` or `CONFLICTS: <n>`;

both end `BLOCK: target unresolved` when a file they need is missing, and
rate each finding by `glab:audit`'s severity levels. *Report*: the verdict
line, then each finding in one line.

- post: `` P plugins/glab/agents/product-analyzer.md 'name: product-analyzer' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'description: Product level — ' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'tools: Read, Grep, Glob, Bash' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'CONFLICTS: <n>' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'NOT SOUND: <n> findings' ``
- post: `` P plugins/glab/agents/product-analyzer.md '- glab:audit' ``
