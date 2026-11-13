# Steps 2 — the product level (P1–P9)

Each new skill is `plugins/glab/skills/<name>/SKILL.md` with frontmatter
`name: <name>` (bare, equal to its directory) and a `description:` that
begins `Product level — `, or `Project level — ` for P5; no
`disable-model-invocation`, `user-invocable`, `allowed-tools` or `model` key
(`evidence.md` *Scope*, the binding decisions). An entry-point skill takes
`$ARGUMENTS` as its one argument and, with none, asks which one — never the
most recent, never a guess — said in each skill in those words, because no
product-level file points into the project level's manager (the boundary,
*Decisions*; R2-6); P5, which the project level runs, may, and the last post of P1–P4, P6 and P7 checks that its file names no
`glab:manager`. Payload
names components by their prefixed name (`AGENTS.md` *Rules*). Each rule is
written once, in the file of the role that acts on it; the others point at
it.
The contracts C1–C11 are in `plan.md`; a skill states what they say and never
cites `C<n>`, because the plan folder is not shipped.

### P1 — `glab:product-manager`, the product level's operating model

Create `plugins/glab/skills/product-manager/SKILL.md`, its description
beginning `Product level — The operating model of the product level`. It
holds, as its own sections:

- **The rules of every level** — the required text `` `glab:session-rules` holds the rules every level runs under `` and that this skill is loaded with it; a Rule `<n>` cited here is that skill's, and its *Round caps*, *The handoff line* and *The level boundary* bind this level (J2). The file never names the project level's manager: nothing of it is read or run here, and the last post checks that.
- **Your skills — this level only** — the list the level boundary binds to (`glab:session-rules` *The level boundary*): the product skills `glab:product-plan` (the procedure `glab:product-planner` preloads), `glab:product-plan-analyze`, `glab:product-project-brief`, `glab:product-project-plan-analyze`, `glab:product-project-plan-verdict`; the skills of every level `glab:session-rules`, `glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`, `glab:commit`, `glab:push`; the agents `glab:product-planner`, `glab:product-analyzer`, `glab:committer`. Required text: `## Your skills — this level only`. `glab:product-project-plan-report` is not on it: the project level runs it.
- **The shared store** — where it is: the first `glab-shared-store: <path>` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`, `~/` the home directory; none → stop and ask the user for it, and say which path is in use. Before anything writes it, the store is one of this session's directories — `claude --add-dir <store>` when the session starts, or `/add-dir <store>` in it — or it sits inside the product repo; otherwise every write into it, the product planner's briefs and the verdict's Bash call alike, waits on a permission prompt (R2-4; whether a subagent's Write there is prompted or refused is UNVERIFIED, LP6). Required text: `the store is one of this session's directories`. Then C3's layout, written here once: the other product skills name a file by its store-relative path and point here (I6); every committed file names store paths relative to the store; `releases/` is reserved for the delivery level. Required text: `## The shared store`.
- **The product pipeline** — a table of the stages P1 product plan (`glab:product-planner` on the business plan the user names), P1b product plan check (`glab:product-plan-analyze`, its rounds under `glab:session-rules` *Round caps*), approval (the user, always, explicit: it decides what the product is, `glab:session-rules` Rule 3 — an `## Approval` line at the end of `product-plan.md`, `- approved by the user, <date>, in chat: "<their words>"`), P2 briefs and rules (`glab:product-project-brief`), P3 project sessions, P4 the audit of each report (`glab:product-project-plan-analyze`), P5 the verdict (`glab:product-project-plan-verdict`), P6 commit and push of the product repo (`glab:commit`, `glab:push`). The table has a column for the project stage of the same role — P1 ↔ 1, P1b ↔ 1b, the approval ↔ the approval, P6 ↔ 6 and 7 — which is how `glab:session-rules` *How to read these rules* maps a stage its rules name; P2 to P5 have none, so a rule about another stage does not apply to them (I17). Required text: `the project stage of the same role`. Each handoff is announced as `glab:session-rules` *The handoff line* says, the stage named `product-plan`, `plan-check`, `brief`, `audit` or `verdict`. A product rule file changes only through an approved product plan's `## Rules to add`, never as a `glab:session-rules` Rule 1 trivial change: the rules are the user's. Required text: `## The product pipeline`.
- **Starting project sessions** — on the user's go-ahead, once per batch of briefs (each session costs money, `glab:session-rules` Rule 3); the go-ahead names each project's repo folder, since a session tool starts a session in another folder only where the user named it (F20). One session per brief, in the project's repo, named `<project>`, given the start prompt — required text `take the brief at <store>/briefs/<project>/brief.md. Commit only through /glab:commit, and push only after the user's explicit go-ahead.` The second sentence is there because a background session that moved into a worktree commits and pushes its branch without asking, unless its task says git is handled otherwise, and the task's words take precedence over that default (F19). Record each session's name and id in the handoff file. By host (F8, F9, F17, F18, F20, LP4):
  - **the desktop app** — its session tool starts the session with the project repo as its folder, `<project>` as its name and that prompt, and with `wake_when_done`, which continues this session when the project session ends its turn; a message goes through `SendMessage` to the session's id.
  - **the CLI** — required text `cd <project repo> && claude --bg --name <project> --add-dir <store> "<the start prompt>"`. It prints a short id, which `claude attach`, `logs` and `stop` take. A message to the running session is the CLI's cross-session `SendMessage` to its name, which `ListAgents` lists; the wait is a `SendMessage` with `notify_when_idle` and no message — one notice when that session next goes idle, for a session on this machine, sent from the main conversation only; a session in another permission mode holds a cross-session message for its user's approval. Required text `claude --resume <full session id> --bg "<message>"`, the full id from `claude agents --json`, is for a session that has stopped, and never to message a running session: on a running one it starts a copy. Its caveats, stated with it: the repo must already be trusted, or the start fails with `Workspace not trusted.`; the session may move into a git worktree under `.claude/worktrees/` before it edits, where it commits and pushes without asking unless its task says otherwise — hence the prompt's second sentence; and any prompt the session's permission mode raises, such as the Bash call that writes the report, stops it until the user attaches (`claude attach <id>`) and answers (F21). If a live run shows a background session pushing all the same, this session starts no project session with `--bg` again: the user starts them by hand.
  - **the user starts it by hand** — required text `the user starts it by hand`: always valid, on every host; the user opens a session in the project repo and gives it the same prompt — an interactive session, to which no background git default applies.

  The skill says that what no live run has shown is UNVERIFIED (LP4): that a session's Bash tool can run `claude --bg`; that `SendMessage` and `notify_when_idle` reach a background session this session started; that the start prompt keeps a background session from committing and pushing on its own; and that the desktop tool reaches a session it started, which its own text, "It cannot deliver into a session an orchestrator dispatched", leaves open.
- **Waiting for reports** — a report arrives as `report.r<n>.md` in the brief's folder. A project session this session started is watched — `notify_when_idle` in the CLI, `wake_when_done` in the desktop app — and each notice is the cue to look in the store: one-shot, so a notice with no new report is followed by a new subscription. This session ends its turn with the briefs it waits on in the handoff file; a report from a session it did not start arrives with a message, from the user or from that session's `SendMessage`. Required text: `notify_when_idle`.
- **The cap** — required text: `two REJECTED verdicts on one project since its last ACCEPTED, then the user decides`, over every brief the project has had, so a new brief does not reset it (I8). At the cap `plan-gate.sh` refuses every verdict by `product-manager`, `ACCEPTED` as well as `REJECTED` (R3): bring the report to the user with both reasons, and write the user's decision `by user`, the reason's first line `user: "<their words>"`. Known limit, said here (R12), required text: `` `by user` is an argument the calling session chooses `` — so the cap holds as far as the sessions keep to this text.

- post: `` P plugins/glab/skills/product-manager/SKILL.md 'name: product-manager' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'description: Product level — The operating model of the product level' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '`glab:session-rules` holds the rules every level runs under' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '## Your skills — this level only' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '## The shared store' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'glab-shared-store:' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '## The product pipeline' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'the store is one of this session'"'"'s directories' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'the project stage of the same role' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'take the brief at <store>/briefs/<project>/brief.md. Commit only through /glab:commit, and push only after the user'"'"'s explicit go-ahead.' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'cd <project repo> && claude --bg --name <project> --add-dir <store> "<the start prompt>"' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'claude --resume <full session id> --bg "<message>"' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'claude agents --json' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'never to message a running session' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'notify_when_idle' ``
- post: `` N plugins/glab/skills/product-manager/SKILL.md 'claude --resume <id> --bg' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'Workspace not trusted.' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'the user starts it by hand' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md 'two REJECTED verdicts on one project since its last ACCEPTED, then the user decides' ``
- post: `` P plugins/glab/skills/product-manager/SKILL.md '`by user` is an argument the calling session chooses' ``
- post: `` N plugins/glab/skills/product-manager/SKILL.md 'glab:manager' ``

### P2 — `glab:product-plan`, the product planner's procedure

Create `plugins/glab/skills/product-plan/SKILL.md`, the procedure
`glab:product-planner` preloads and a user can run by typing
`/glab:product-plan <path to the business plan>`. It defines:

- **The product plan** — the folder `plan/<slug>/` of the product repo and one file `product-plan.md`, at most 49152 bytes (`wc -c`; R7), with the sections `## Business plan` (its path and `sha256sum`, and the user's words that define it, verbatim), `## Goals` (`P1`, `P2`, …), `## Projects` (one subsection `### <project>` per project: its kebab-case name, goal, scope, out of scope, the product-rule files that apply, its seams with the other projects), `## Rules to add` (drafts of new rule files, or `none`), `## Decisions`, and `## Questions` (only what meets a `glab:session-rules` Rule 3 ask-condition). Required text: `## Projects`.
- **The briefs** — after the plan's `## Approval`, one `briefs/<project>/brief.md` in the shared store per project, with the sections `## Goal`, `## Scope`, `## Out of scope`, `## Product rules` (store-relative paths, `docs/product-rules/<name>.md`, each existing), `## Seams` and `## Acceptance` (what the audit will hold the plan to). Required text: `the product's gates` — a brief's `## Acceptance` and the rule files it names are the product's gates for that project, which the audit holds the plan to with the product plan's `## Decisions` (I3). A brief is the project's whole request, so it cites nothing the project cannot read. Required text: `## Acceptance`.
- **The product rules** — the user's; a draft from `## Rules to add` is written to `docs/product-rules/<name>.md` in the store only after the plan's approval, one topic per file, at most 8192 bytes, and `index.md` gains its line `- <name>.md — <what it covers>`. Required text: `at most 8192 bytes`.
- Where it stops: the plan or the briefs written; checks, approvals and verdicts are the product manager's. The store's layout is `glab:product-manager` *The shared store*'s.

- post: `` P plugins/glab/skills/product-plan/SKILL.md 'name: product-plan' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md '## Projects' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md '## Acceptance' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md 'the product'"'"'s gates' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md 'at most 8192 bytes' ``
- post: `` P plugins/glab/skills/product-plan/SKILL.md 'at most 49152 bytes' ``
- post: `` N plugins/glab/skills/product-plan/SKILL.md 'glab:manager' ``

### P3 — `glab:product-plan-analyze`, the product plan check

Create `plugins/glab/skills/product-plan-analyze/SKILL.md`: the entry point
of stage P1b. `$ARGUMENTS` is the product plan's slug. It dispatches
`glab:product-analyzer` for **the product plan check** on
`plan/<slug>/product-plan.md`, and goes on by its verdict: `SOUND` → the
user's approval; `NOT SOUND: <n> findings` → a new `glab:product-planner`
amends from the findings, the round copy `product-plan.r<n>.md` kept first;
its rounds are counted under `glab:session-rules` *Round caps*.

- post: `` P plugins/glab/skills/product-plan-analyze/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-plan-analyze/SKILL.md 'NOT SOUND: <n> findings' ``
- post: `` P plugins/glab/skills/product-plan-analyze/SKILL.md 'product-plan.r<n>.md' ``
- post: `` N plugins/glab/skills/product-plan-analyze/SKILL.md 'glab:manager' ``

### P4 — `glab:product-project-brief`, the briefs

Create `plugins/glab/skills/product-project-brief/SKILL.md`: the entry point
of stage P2. `$ARGUMENTS` is the product plan's slug. Precondition:
`product-plan.md` ends with an `## Approval` line; none → stop. It dispatches
`glab:product-planner` to write the briefs and the approved rule drafts, as
`glab:product-plan` says, then lists the briefs written by their store paths.
Required text: `ends with an ## Approval line`.

- post: `` P plugins/glab/skills/product-project-brief/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-project-brief/SKILL.md 'ends with an ## Approval line' ``
- post: `` N plugins/glab/skills/product-project-brief/SKILL.md 'glab:manager' ``

### P5 — `glab:product-project-plan-report`, the project's report (project level)

Create `plugins/glab/skills/product-project-plan-report/SKILL.md`, with a
description that begins `Project level — ` and says it is the product
chain's contract that the project manager runs. `$ARGUMENTS` is the project
plan's slug. Preconditions: `master.md` has the brief line (C5) and its
`## Approval`, and at full tier `plan.md` has its own; the store resolved from
its `glab-shared-store:` line (the repo's `AGENTS.md`, else the host file). It
runs
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
`report.r<n>.md` in the brief's folder of the store, numbers compared as
numbers, and the product plan the brief came from — the one
`plan/*/product-plan.md` whose `## Projects` has `### <project>`; none or more
than one → ask the user. It dispatches `glab:product-analyzer` for **the
project plan audit**, naming the brief, the report, `plan.r<n>/`, the product
plan's `## Decisions`, and the rules index with the rule files the brief
names — the product's gates (I3). It goes on by the verdict: `NO CONFLICT` or
`CONFLICTS: <n>` → stage P5.

- post: `` P plugins/glab/skills/product-project-plan-analyze/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-project-plan-analyze/SKILL.md 'the project plan audit' ``
- post: `` P plugins/glab/skills/product-project-plan-analyze/SKILL.md 'whose `## Projects` has `### <project>`' ``
- post: `` P plugins/glab/skills/product-project-plan-analyze/SKILL.md 'the product plan'"'"'s `## Decisions`' ``
- post: `` N plugins/glab/skills/product-project-plan-analyze/SKILL.md 'glab:manager' ``

### P7 — `glab:product-project-plan-verdict`, the verdict

Create `plugins/glab/skills/product-project-plan-verdict/SKILL.md`: the
entry point of stage P5. `$ARGUMENTS` is `<project>`. On the audit's
`NO CONFLICT`: `ACCEPTED`, the reason one line naming the rules checked; on
`CONFLICTS: <n>`: `REJECTED`, each conflict one line of the reason with the
rule file it breaks. The session writes the reason to a file in its temp
directory and runs
`"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" verdict <store> <project> ACCEPTED|REJECTED product-manager <reason file>`.
The script's refusal `two REJECTED verdicts since the last ACCEPTED; the next
verdict is by user` is the point where the user decides
(`glab:product-manager` *The cap*): the verdict is then written `by user`, the
reason's first line `user: "<their words>"`. It then tells the project
session that the verdict is there — `SendMessage` to the name it was
started under, or, for a CLI session that has stopped, a resume by its full
session id (`glab:product-manager` *Starting project sessions*) — or tells
the user. Required text: `plan-gate.sh" verdict`.

- post: `` P plugins/glab/skills/product-project-plan-verdict/SKILL.md 'description: Product level — ' ``
- post: `` P plugins/glab/skills/product-project-plan-verdict/SKILL.md 'plan-gate.sh" verdict' ``
- post: `` P plugins/glab/skills/product-project-plan-verdict/SKILL.md 'user: "<their words>"' ``
- post: `` N plugins/glab/skills/product-project-plan-verdict/SKILL.md 'glab:manager' ``

### P8 — the agent `glab:product-planner`

Create `plugins/glab/agents/product-planner.md` with the frontmatter
`name: product-planner`, a `description:` beginning `Product level — `,
`model: opus` (Q1), `tools: Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch`
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
`model: opus` (Q1), `tools: Read, Grep, Glob, Bash`, and `skills:`
`glab:security` and `glab:audit`. Its body: read `AGENTS.md` first (the same
fallback); read-only, writes nothing, returns its findings as text; two
checks, named in its dispatch —

- **the product plan check**: each goal reaches a project, each project is one a brief can state alone, the rule files it cites exist, the seams between projects agree; ends `SOUND` or `NOT SOUND: <n> findings`;
- **the project plan audit**: reads the brief, the report, the copies in `plan.r<n>/`, the product plan's `## Decisions`, then `docs/product-rules/index.md` and only the rule files the brief names or the plan touches — the product's gates; each finding cites the rule file or decision and the plan step; ends `NO CONFLICT` or `CONFLICTS: <n>`;

both end `BLOCK: target unresolved` when a file they need is missing, and
rate each finding by `glab:audit`'s severity levels, naming the four in its
*Report*: the verdict line, then each finding in one line.

- post: `` P plugins/glab/agents/product-analyzer.md 'name: product-analyzer' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'description: Product level — ' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'tools: Read, Grep, Glob, Bash' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'CONFLICTS: <n>' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'NOT SOUND: <n> findings' ``
- post: `` P plugins/glab/agents/product-analyzer.md 'the product plan'"'"'s `## Decisions`' ``
- post: `` P plugins/glab/agents/product-analyzer.md '- glab:audit' ``
