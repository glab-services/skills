# Workflow — spec

The `glab` workflow: how a session runs a change through plan, analysis,
development, integration, review, commit and push, at the depth a tier
gives it; the rules of `glab:manager`; the agents and commands; the user's
choice of model for the developer and reviewer; and what happens to a
change's plan files, up to the record that moves what stays true into an
area spec. Owned by `plugins/glab/skills/manager/SKILL.md`,
`plugins/glab/skills/plan-first/SKILL.md`,
`plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/audit/SKILL.md`,
the agents under `plugins/glab/agents/`, the commands under
`plugins/glab/commands/`, and `plugins/glab/scripts/manager-bootstrap.sh`
(the `SessionStart` hook text). The external agents, removed in `glab`
0.8.0 (`467b7c4`, 2026-10-20), are recorded in
`docs/specs/external-agents.md`, now a record only. Stated as of `09d2787` (`glab` `0.5.0`), the
record of `feature-docs-specs`, and its `feature-codex-agent` lines (Rules 5
and 6 for Codex, `/glab:review`) as of `30f2c80` (`glab` `0.6.0`), and its
`feature-external-developer` lines (Rule 5's external developer, Rule 6's
exceptions, `/glab:develop`'s external path) as of `33a28df` (`glab`
`0.7.0`), and its `subagent-effort` lines (Rule 0d, the effort in the
handoff line and in Rules 5 and 6, the dispatch text of Stages 2 and 5, of
`/glab:develop`, `/glab:review`, `/glab:ship`, `glab:bootstrap` and the hook)
as of `abda43a` (`glab` `0.7.2`), and its `remove-external-agents` lines
(Rule 6 gone, Rules 0d and 5 and *The pipeline* without their Codex and
OpenCode sentences, the commands without their external paths, every
statement of an external agent marked as history) as of `467b7c4` (`glab`
`0.8.0`); where this file and an owning file disagree, the owning file is
right.

## How it works now

- **Session start.** The `SessionStart` hook injects the irreducible rules
  (load `glab:bootstrap`, `glab:manager`, `glab:security`; read `AGENTS.md`,
  or `CLAUDE.md` and say there is no agreement; agents carry `glab:security`
  and `glab:comments`, and every dispatch passes the Agent tool's `effort`
  at the session's level, Rule 0d, since `abda43a`; the host file's temp
  directory); `glab:bootstrap` runs
  the full sequence — agreement and `docs/constants.md`, skills, the repo's
  real gates, the handoff, the host's hazards — and ends on the one-line
  check. The hook text and the skill are one fact (`AGENTS.md` *One fact*).
- **The pipeline** (`glab:manager` *The pipeline*): 1 Plan (`/glab:plan`),
  1b Analyze the plan (`/glab:analyze`, plan only), 2 Develop
  (`/glab:develop`), 3 Analyze conformance, 4 Integrate (`/glab:integrate`),
  5 Review (`/glab:review`), 6 Commit (`/glab:commit`), 7 Push
  (`/glab:push`, no push agent), 8 Record (after the push: `glab:developer`
  on the record, `glab:analyzer` on what it carried, then `/glab:commit`; it
  leaves on the record commit verified, then pushed on the user's go-ahead).
  A change with a plan folder goes on from Stage 7 to Stage 8. Each handoff
  is one line, `slug · stage · round n/max · verdict · effort <level>`
  (Rule 0d; `slug · stage · round n/max · verdict` before `abda43a`), with
  `model <m>` after the stage on a develop or review line. The effort is the
  level passed ("The effort is the level you passed.", *The pipeline*, as
  of `467b7c4`). History, until `glab` 0.8.0 (`467b7c4`, 2026-10-20): the
  sentence went on "for a Codex agent the level sent, after Rule 6's
  mapping; an OpenCode line names no effort, since OpenCode takes none".
  Without subagent dispatch each stage is a fresh
  session, `<slug> record` among them. The bootstrap diagram ends on `record`,
  and the hook text reads `-> push -> record at full tier`.
- **The tier** (`glab:manager` *Pick the tier*), the first line of `plan.md`
  with its reason; no tier line means full. **Full**: a schema or data
  migration, a stored or wire format, code that decides who may do what,
  handles secrets or moves money — `findings.md`, `plan.md`, `questions.md`
  if a question was raised, the user's explicit approval, 1b at most 2
  rounds, conformance at most 4 rounds, the whole suite at integrate, review
  at most 3 rounds. **Normal**: everything else — a one-page `plan.md`, no
  approval (the tier and decisions are reported), one 1b pass, no
  conformance stage, the milestone test at integrate, one review round whose
  findings are fixed once. **Trivial**: Rule 1's five lines, done directly.
  An analyzer or reviewer that finds a full-tier trigger raises the tier;
  only the user lowers one. The tier table's **8 Record** row: none at
  trivial; at normal, "after the push: the area spec updated and
  `glab:analyzer`'s check that every follow-up, decision and incident is
  carried, in one docs commit"; at full, "the same, with one `glab:reviewer`
  pass on the spec diff alone". It replaced the **Spec** row of `6838133`
  ("a short entry", "checked by independent readers"), which had no stage,
  owner or place (`[sync-local-edits/follow-ups.md 10]`, now closed).
- **The rules of `glab:manager`**, one line each:
  - Rule 0 — read `AGENTS.md` first (or `CLAUDE.md`, saying there is no
    agreement), and make every dispatched agent read it, with
    `docs/constants.md` where there is one.
  - Rule 0b — `glab:security` runs alongside: paste the command and its
    output or write `UNVERIFIED`; no stage is green on an agent's word.
  - Rule 0c — every dispatch names `glab:security` and `glab:comments`;
    `glab:audit` and `glab:plan-first` per dispatch, with the plan-first seam
    stated.
  - Rule 0d — every dispatch, to every subagent, passes the Agent tool's
    `effort` parameter at the session's level (*The session effort*,
    below); since `abda43a`.
  - Rule 1 — the manager does not implement; questions and trivial changes
    are not the pipeline.
  - Rule 2 — the context budget: never read what an agent will read; agents
    write long output to disk and return a short report.
  - Rule 3 — engineering choices are the manager's, recorded under
    `## Decisions`; the user is asked only when a choice is destructive,
    costs money, exposes real data or changes what the product is — at most
    one question per plan.
  - Rule 4 — one surface per session; seams are settled through the channel
    `docs/constants.md` names, or the user relays.
  - Rule 5 — the model a `glab:developer` or `glab:reviewer` runs on is the
    user's call (below): `sonnet`, `opus`, `haiku` or `fable`, and nothing
    else (as of `467b7c4`). History, until `glab` 0.8.0 (`467b7c4`,
    2026-10-20): an external reviewer on OpenCode or Codex, and an external
    developer on Codex only, were included. "Only the reviewer, on either
    backend, and the developer, on Codex, can be external; no other role
    ever is." That paragraph and sentence are gone; a name the parameter
    does not take is said and asked about ("ask which of the four the user
    means").
  - Rule 6 — **gone since `glab` 0.8.0 (`467b7c4`, 2026-10-20)**: it was the
    last numbered rule, so nothing was renumbered
    (`[remove-external-agents/plan.md D14]`); *Know the gates before you
    dispatch* follows Rule 5. History, as it read until then: an external agent, an OpenCode or a Codex session, is the
    user's call, its reply untrusted (`docs/specs/external-agents.md`), for
    read-only work, **except a Codex developer under Rule 5**: an OpenCode
    agent works on a read-only copy in the script's sandbox; a Codex agent
    works in the repository itself under Codex's own sandbox — read-only, or
    workspace-write for a developer — and its commands can read any file the
    user can, outside the repository too. Its two exceptions since
    `feature-external-developer`: *It changes nothing*, "except a Codex
    developer under Rule 5, which changes files in the repository and
    nowhere else"; and *It takes no stage's role*, "except the developer and
    the reviewer under Rule 5". Only when the user asks, naming the model
    for OpenCode — for Codex, naming one or leaving it to Codex's default.
    **Codex's effort** is the session's (Rule 0d), or the level the user
    named for that agent or role (below).
- **Agents** (`plugins/glab/agents/`): `glab:developer` (builds the named
  steps, writes `plan/{slug}/result.md` and `follow-ups.md`, never stages;
  at the record it updates the area specs only and writes no `result.md`),
  `glab:analyzer` (plan-only and conformance analysis, and the record check
  of Stage 8), `glab:integrator`
  (the real running system, local only), `glab:reviewer` (correctness and
  `AGENTS.md` rules, gets the target and nothing else; its verdict lines are
  one fact with `ship.md` and the manager — and, until `467b7c4`, the
  external-agent validator),
  `glab:committer` (explicit paths, never `git add -A`; Conventional
  Commits as `AGENTS.md` says). **Commands** (`plugins/glab/commands/`):
  `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`,
  `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship`.
  Since `glab` 0.8.0 (`467b7c4`) no command has an external path:
  `/glab:develop` dispatches `glab:developer` only, and `/glab:review` and
  `/glab:ship` the `glab:reviewer` only; `/glab:ship` keeps
  `BLOCK: 1 issue` among its verdicts (`[remove-external-agents/plan.md D9]`).
  History, until then (2026-10-20): `/glab:develop` had an external path: when Rule 5 recorded an external
  developer, *Dispatch* starts it through `glab:external-agents` with
  `--role developer` instead of dispatching `glab:developer`, with the same
  brief — one agent, never split and never beside a `glab:developer`
  (*Decide the split*); *When the agents return* handles it first, before
  the gates: the exit and the `git:` line (any exit but 0, or
  `git: changed`, stops the pipeline: the user is shown the `changed:` lines
  and nothing is reverted, committed or re-run); then, only on 0 with
  `git: unchanged` and no nested repository refused, the manager reads the
  whole change against the plan without a filter
  (`git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u -- - <path>`
  per tracked path, untracked and ignored regular
  files read directly, links and special files never opened, neither
  `git status` nor `git diff` before that); then writes `result.md` from its
  reply, marked as that model's words, with the `changed:`/`git:` lines and
  the gates as it ran them; then the gates (`commands/develop.md` at
  `33a28df`). `/glab:review`
  named Codex: an external reviewer the user named was "a backend, and for
  OpenCode a model", run through `glab:external-agents` with the same
  target; an OpenCode reviewer's copy held only `HEAD` and the working
  tree, so a branch or a range could not be its target, while "a Codex reviewer
  works in the repository and can take one" (`commands/review.md:8` at
  `6b2a024`); both external paths ended at `467b7c4`. `/glab:ship` reviews
  the working tree only, then as now. Every agent
  and command falls back to `CLAUDE.md` when `AGENTS.md` is missing, and the
  reviewer then puts `agreement: no AGENTS.md — correctness only` on its own
  line above an unchanged verdict line.
- **Round caps**: plan analysis 2 (full) or one pass (normal); conformance
  4; review 3 (full) or 1 (normal), and at the last full-tier round the
  answer is `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>` or
  `DO NOT PUBLISH: <why>`. The review cap is one fact in `reviewer.md`,
  `ship.md`, the manager and bootstrap (`AGENTS.md` *One fact*).
- **The model rule** (Rule 5): the user may name the model of the developer
  or the reviewer — `sonnet`, `opus`, `haiku` or `fable` — and nothing else
  changes it. The manager passes it as the Agent tool's per-dispatch `model`
  parameter on every dispatch of that role, records it as a `- model:` line
  quoting the user under `## Decisions` in `plan.md`, names it in every
  develop and review handoff line (`model default` when none), writes the
  dispatch for that model (a three-row table: `opus`/default/`fable`,
  `sonnet`, `haiku`; until `467b7c4` also a row for an external reviewer
  and one for an external developer), and checks every
  report against the role's contract, resuming the agent once for missing
  fields. "For this task" ends with that task's record (Stage 8), or with its
  push when it has no plan folder; "for the session" with the session. Every other role gets no `model` parameter; every role, these two
  included, gets `effort` (Rule 0d: "The model is Rule 5's, the effort is
  this rule's."). The pipeline does
  not bend: the manager still runs the gates, the reviewer still gets only
  the target, push still waits for the user.
- **The external developer** — history: removed in `glab` 0.8.0
  (`467b7c4`, 2026-10-20), with Rule 5's paragraph, its table row and
  `/glab:develop`'s external path; as it stood until then
  (`glab:manager` Rule 5, as of `33a28df`; the
  decisions are in `docs/specs/external-agents.md`). The user may name an
  external developer, Codex only — "develop on Codex", or "develop on Codex,
  <id>" — which `glab:external-agents` runs as a `--role developer` agent
  with the developer's contract, in the repository itself; "An external
  developer is Codex only: OpenCode cannot change files." It is recorded,
  lasts and is shown the way a Claude model is. Its record line is the Codex
  reviewer's with `glab:developer`:
  `- model: glab:developer codex, for <scope> — the user's instruction, not a manager choice: "<the user's words>"`,
  with `codex:<id>` when the user named a model; its handoff line
  `slug · develop · model codex:<model> · round 1/1 · BUILT · effort <sent>`
  (as of `abda43a`; from `33a28df` to `3965622` the line carried
  `effort <level> (CLAUDE_CODE_EFFORT_LEVEL | the user's answer: "<words>")`
  after `codex`, and the handoff line ended at `BUILT`). A name the
  `model` parameter does not take may have meant an external developer too:
  `codex` or `codex:<id>`. It is not a `model` parameter: on the
  developer's occasions `/glab:develop`'s dispatch runs through
  `glab:external-agents` with `--role developer` — one agent, never split,
  never beside a `glab:developer`; a re-dispatch after `BLOCKED` or
  `PLAN WRONG` is a new agent, the old one stopped. When the backend is
  unavailable, times out, fails, or reports a sandbox other than the one it
  asked for (12), or the developer is refused, the manager stops and tells
  the user and reverts, commits or re-runs nothing. Rule 5's dispatch table
  has its row: "nothing you write: the script frames it with the default
  profile's developer section, the developer's contract and its tail
  (`glab:external-agents`); your brief is the slug and the step ids, as for
  `opus`". Codex's effort is not in this model line: "The effort is not in
  the model line: Rule 0d's `- effort:` line records it, for Codex too"
  (Rule 5, as of `abda43a`; until then it went "in the model line for the
  reviewer or the developer (Rule 5)"). The pipeline does not bend:
  the manager reads the whole change and runs every gate itself before
  Stages 3–5, which do not change (`[feature-external-developer/plan.md U3]`).
- **The model rule for Codex** — history: removed in `glab` 0.8.0
  (`467b7c4`, 2026-10-20), with Rule 6 and Rule 5's external reviewer; as
  it stood until then (`glab:manager` Rules 5 and 6, as of
  `30f2c80`; the decisions are in `docs/specs/external-agents.md`). The user
  may name an external reviewer as Codex alone — "review on Codex" — which
  runs Codex's own default model, with **no `--model` unless the user named
  one**, or "review on Codex, <id>". A name the Agent tool's `model`
  parameter does not take may have meant an external reviewer:
  `opencode:opencode-go/<id>`, `codex`, or `codex:<id>`. The record line
  names `codex` alone for Codex's default:
  `- model: glab:reviewer codex, for the session — the user's instruction, not a manager choice: "<the user's words>"`,
  with `codex:<id>` in place of `codex` when the user named a model; since
  `abda43a` it carries no effort ("The effort is not in the model line:
  Rule 0d's `- effort:` line records it, for Codex too."). The
  handoff line names the model the script's header named, which for Codex is
  the model that ran (`codex:default` when none has run). **The effort** is
  the session's, as Rule 0d gives it — the level the user named for the
  session, otherwise `CLAUDE_CODE_EFFORT_LEVEL`, otherwise asked once per
  session — or the level the user named for that agent or role, recorded as
  Rule 0d's `- effort:` line (Rule 6, `glab:external-agents`; *The session
  effort*, below). From `30f2c80` to `3965622` it was
  `CLAUDE_CODE_EFFORT_LEVEL` when set, otherwise asked once per session and
  recorded in the model line for the reviewer or the developer (Rule 5), and
  as `- effort: codex <level> (the user's answer: "<words>"), for the session`
  for any other Codex agent (Rule 6), placed by
  `[feature-codex-agent/plan.md D30]`; `subagent-effort` replaced both
  record forms with Rule 0d's line, whose placement Rule 0d states
  (`[feature-codex-agent/record.md effort-line]`, closed). It sends the highest
  level the model supports that is not above it and says so in the announce
  line; when `check` printed `models: unavailable`, it sends the level
  unchanged and says no levels were known. When an external reviewer's
  backend is unavailable, refuses the model, times out or fails, or reports
  that it did not run read-only (12), the manager stops and tells the user.
  The Codex record token, the `--model` clause and the
  effort rule were each a *One fact* entry of their own in `AGENTS.md`
  until `467b7c4`
  (`docs/specs/marketplace.md`).
- **The session effort** (`glab:manager` Rule 0d, as of `abda43a`). Every
  dispatch, to every subagent — `glab:developer`, `glab:reviewer`,
  `glab:analyzer`, `glab:integrator`, `glab:committer`, and any other —
  passes the Agent tool's `effort` parameter: omitted, the agent runs at its
  own usual effort, which is not necessarily the session's, and nothing in
  its report says which. The level, in order: the one the user named for
  the session in the main session; else `CLAUDE_CODE_EFFORT_LEVEL` when it
  is set; else the manager asks once per session and reuses the answer —
  never guessed. It is recorded as
  `- effort: <level> (the user's words: "<words>" | CLAUDE_CODE_EFFORT_LEVEL), for the session`
  under `## Decisions` in the current task's `plan.md` (a session-wide level
  in the plan of every task it covers), or in the conversation when there
  is no plan; a level that can no longer be found is asked again, not
  reconstructed. The user may name another level for one agent, one role
  or one task, which overrides the default for that and nothing else,
  recorded the same way with its scope. The parameter takes `low`,
  `medium`, `high`, `xhigh` or `max`; for an Agent tool dispatch, a level it
  does not take — `ultra`, for one — is said and asked about; Rule 0d is
  otherwise unchanged for Claude subagents by `467b7c4`, and keeps "for an
  Agent tool dispatch" (`[remove-external-agents/plan.md D7]`). History,
  until `glab` 0.8.0 (`467b7c4`, 2026-10-20): "A Codex agent
  runs at the same level through Rule 6's mapping, and Codex takes `ultra`;
  an OpenCode agent takes none." If the Agent tool rejects `effort` or does
  not offer it, the manager tells the user, dispatches without it and writes
  `effort default` in the handoff line. The dispatch text carries it where
  it lists Agent tool parameters: Stage 2's "**the effort, always**",
  Stage 5's "at the effort Rule 0d gives", `/glab:develop`'s bullet for
  every `glab:developer` dispatch, `/glab:review`'s and `/glab:ship`'s
  reviewer sentence and `/glab:ship`'s committer dispatch; `glab:bootstrap`
  and the hook's item 3 say every dispatch passes it; `README.md` says every
  agent "runs at the session's effort level, which the manager passes on
  every dispatch". `/glab:plan`, `/glab:analyze`, `/glab:integrate` and
  `/glab:commit` do not mention it (`[subagent-effort/plan.md D4]`;
  `[subagent-effort/result.md finding-4]`, open), and no agent definition
  has an `effort:` key (`[subagent-effort/plan.md D6]`). The session effort
  is a *One fact* entry of `AGENTS.md` (`docs/specs/marketplace.md`).
- **Plan files** (`glab:plan-first`): `plan/{slug}/` holds `findings.md`,
  `questions.md`, `plan.md`, the developer's `result.md` and
  `follow-ups.md`, `integration.md`, and `waived.md` when the user waives
  planning; a waiver's folder is recorded like a plan's. The rule is
  "**Plan files are working files; the spec is what stays.**" Step 1 reads
  the spec of each area the change touches first — its decisions still
  bind, its known limits still hold, its open follow-ups may already
  describe the task. Step 3's `plan.md` includes `## Record`: the area spec
  or specs the change updates once it is pushed, any audit file under
  `plan/` it acts on, and what the entry will say; `/glab:plan` reports the
  spec it names. A follow-up stays in `follow-ups.md` until the record moves
  it into the area spec. Specs live in `docs/specs/`, one file per area,
  unless the repo's `AGENTS.md` names another place. A plan folder whose
  `plan.md` has no `## Record` was written before the repo followed the rule
  and is not recorded. An audit file stays where `glab:audit` writes it;
  the plan that acts on it names it in `## Record`, and its open items reach
  the spec at that change's record (`glab:audit` *After Writing*, item 4).
- **Stage 8 — Record** (`glab:manager` *Stage 8 — Record*), after Stage 7
  has confirmed the push. `glab:developer` is dispatched for the record
  alone — the slug, the area specs the plan's `## Record` names (for a
  waiver, the ones the manager names), any audit file it names — and
  updates each spec from the folder's files: how the area works now, the
  decisions that still bind, what is not verified, every follow-up still
  open, every binding decision and every incident with its source file and
  number. It changes nothing inside the folder, removes nothing and writes
  no `result.md`; its report is the reply, and Step 3's gates run as for any
  change (`agents/developer.md` *The record — `glab:manager` Stage 8*). `glab:analyzer` then runs the
  record check at every tier: its contract is the folder and the audit file,
  each item `carried` (with the spec's `file:line`) or `missing`, ending
  `CONFORMS` or `DIVERGES: <n> steps`; `DIVERGES` goes back to the developer
  once and to the analyzer again, then to the user (`agents/analyzer.md`
  *The record check — `glab:manager` Stage 8*). At full tier one `glab:reviewer` pass on the spec diff
  alone follows, its findings fixed once and checked by the analyzer. Then
  `/glab:commit` with the spec files and `/glab:push` on its own go-ahead:
  an ordinary docs change. A decision made at this stage goes in the
  dispatch and the spec, not in `plan.md`. **The record never removes
  `plan/{slug}/` or an audit file**; whether a recorded folder is then
  removed, and how, is the repo's own `AGENTS.md` decision, carried out
  outside the stage, and the manager's *What you never do* says so. The
  bootstrap's `record` bullet: "the plan folder stays unless the repo's
  `AGENTS.md` says otherwise"; its handoff step looks in the area specs for
  what a finished change left open. This repo's own rule — the manager
  session removes a landed folder — is in `docs/specs/marketplace.md`.

## Decisions that still bind

- [feature-model-switch/plan.md D1] Manual only: the model changes only when the user names it, for one dispatch, a task or the session; never on the manager's own initiative, never because of quota, never from a file.
- [feature-model-switch/plan.md D2] Developer and reviewer only; analyzer, integrator, committer and planning agents get no `model` parameter.
- [feature-model-switch/plan.md D3] The user does not run commands: the user tells the manager, who carries the choice into every dispatch of the role until the user changes or clears it.
- [feature-model-switch/plan.md D4] The handoff line names the model, so the user sees what was asked for.
- [feature-model-switch/plan.md D5] The pipeline does not bend to the model: gates, the reviewer's target-only brief, the push go-ahead, the tier and the round caps stay.
- [feature-model-switch/plan.md D6] The mechanism is the Agent tool's per-invocation `model` parameter, passed on each dispatch; it tops the documented order and holds across a resume.
- [feature-model-switch/plan.md D7] One home for the rule, `glab:manager` Rule 5; the stages and commands point to it, the commands restating only the minimum.
- [feature-model-switch/plan.md D8] No change to the agent files: no `model` in their frontmatter, so the documented default applies without an instruction.
- [feature-model-switch/plan.md D9] The choice is recorded as a `- model:` line under `## Decisions` in the task's `plan.md`; a review or ship with no plan keeps it in conversation only, and a lost one falls back to the default.
- [feature-model-switch/plan.md D10] An unspecified duration means the task in progress (the session when there is no task): a lost choice falls back to the default, never to a cheaper model.
- [feature-model-switch/plan.md D11] Develop and review handoff lines always name the model, `model default` included.
- [feature-model-switch/plan.md D12] Rule 5 names its limits: the line states what was passed; a forced subagent model, an allowlist or a mod can run something else, and `/tasks` shows what runs.
- [feature-model-switch/plan.md D13] Without subagent dispatch the stage session runs on the model the user starts it with, and the manager names the recorded model in the handoff.
- [feature-model-switch/plan.md D14] `AGENTS.md` *One fact* carries the manual model rule as a known case.
- [feature-model-switch/plan.md D17] Rule 5 states the version floors and that a plugin agent honouring the parameter is inferred, not shown.
- [feature-model-switch/plan.md D18] Naming `fable` is the user's money choice: said once, then used; not a Rule 3 question.
- [feature-model-switch/plan.md D20] The dispatch fits the model: Rule 5's table says what changes in the message per model; the agent files do not change.
- [feature-model-switch/plan.md D21] The report template is the agent's own *Report* section, copied as written; reading it is Rule 2's one exception.
- [feature-model-switch/plan.md D22] A malformed report is not evidence: check the required fields and the verdict line's form, correct once on the same model, then stop and tell the user; not a review round. (The review fix round made the correction a resume of the same agent.)
- [feature-model-switch/plan.md spent] D15, D16, D19 — scoping of that change: the `0.3.0` bump, leaving bootstrap and the hook untouched, and its Stage 1b amendment.
- [feature-model-switch/result.md decisions] The single normal-tier review said to cut Rule 5's per-model table and report check; the manager fixed the findings once instead, because the user had asked for per-model dispatch (Stage 5's normal-tier rule) — that is why the table and the check are in Rule 5.
- [sync-local-edits/result-followups.md D1] Sessions settle a seam through the channel `docs/constants.md` names, and the user relays when it names none; a relayed decision binds only when it arrived that way and is recorded as a `## Decisions` line naming the session.
- [sync-local-edits/result-followups.md D2] A `plan.md` with no tier line is full tier, stated once in *Pick the tier*.
- [sync-local-edits/result-followups.md D3] Rule 3 keeps `glab:security`'s stop list and its *Destructive operations are proven* rule, and states confirmation before every destructive action and every push as the manager's own rule (as corrected after review, #3).
- [sync-local-edits/result-followups.md D4] Bootstrap stays on the review-round-cap list, and the four ask-conditions are a known *One fact* case naming every file that states them.
- [sync-local-edits/result-followups.md D5] `/glab:integrate` runs after `/glab:analyze` at full tier and after `/glab:develop` at normal; normal tier runs the milestone test, full tier the whole suite.
- [sync-local-edits/result-followups.md D6] After an amendment, the develop handoff re-runs the plan's next stage.
- [sync-local-edits/result-followups.md D8] `/glab:analyze` says "If the plan is amended".
- [sync-local-edits/result-followups.md D9] The planner decides each choice and records it with its reason; the manager reviews those lines and may overrule one, recording the overrule as a new line.
- [sync-local-edits/result-followups.md D10] Only its `glab:plan-first` half stands, reworded by `feature-docs-specs`: no `glab` step removes a plan folder, and whether a recorded one is removed is the repo's own `AGENTS.md` decision (it said: a repo that keeps specs but has no rule for removing plan folders keeps its plans). Its manager half — the Spec row's stage, owner and place — was removed by the review's scope cut; Stage 8 now gives the record a stage, owner and place (`[sync-local-edits/follow-ups.md 10]`, closed).
- [sync-local-edits/result-followups.md D11] The 1b row's "Leaves on" reads "`BUILDABLE`, or one amendment at normal tier".
- [sync-local-edits/result-followups.md D12] Bootstrap points to *Pick the tier* for the full-tier triggers and names the four as Rule 3's ask-conditions; `review.md` says Stage 5 sends findings back; the hook text says "at full tier".
- [sync-local-edits/result-followups.md spent] D7 — the waiver routing it decided was removed by the review's scope cut (`[sync-local-edits/follow-ups.md 7]`, reopened).
- [sync-local-edits/result.md spent] M1, M2, M3, P1 — the port's merge choices (the reviewer's round-cap wording, the develop `questions.md` bullet, `ship.md` already matching, where bootstrap's new paragraph goes), applied in `5f69d65`; nothing in them governs later work.
- [sync-local-edits/result.md decisions] The coordinator, as manager, resolved the contradictions the port reported in favour of the user's newer text (tiers, Rule 3), because the 2026-10-08 edits were the user's latest statement of intent; the older "questions" wording and the repo's own `plan/` rule stayed. The manager's decision, not the user's approval.
- [bug-reviewer-findings/questions.md Q3] The review round cap is 3 everywhere, `/glab:ship` stating the same number so the standalone path is capped too (later "at most three — one at normal tier").
- [bug-reviewer-findings/questions.md Q7] With no `AGENTS.md`, every agent and command falls back to `CLAUDE.md` and says so; the reviewer reviews correctness only and puts `agreement: no AGENTS.md — correctness only` on its own line above an unchanged verdict line, because `/glab:ship` matches the verdict line whole.
- [bug-reviewer-findings/questions.md Q10] `manager-bootstrap.sh`'s text matches the bootstrap rules (load `glab:bootstrap`; agents carry `glab:security` and `glab:comments`); the two stay one fact.
- [feature-docs-specs/plan.md U1] Specs live in `docs/specs/`, one per area, living: how the area works now, why (the decisions that still bind), known limits and what is not verified, and its open follow-ups (the user's).
- [feature-docs-specs/plan.md U2] `plan/<slug>/` is committed during the work and removed after the change has landed, with the spec naming the commit that holds it; `plan/SESSION-HANDOFF.md` stays untracked (the user's) — the removal is this repo's rule, done by the manager session, not by `glab` (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md U4] The rule goes into the payload wherever it describes the plan lifecycle; the default for installers is `docs/specs/`, and a repo's own `AGENTS.md` may name another place (the user's) — its "removal after the push" default was cut by `[feature-docs-specs/plan.md U10]`.
- [feature-docs-specs/plan.md U9] The default for installers is the user's decision (U4), not the planner's.
- [feature-docs-specs/plan.md U10] Scope cut (the user's, 2026-10-18): in the payload, Stage 8 "Record" is the spec only — the developer writes the spec from `plan/<slug>/`, `glab:analyzer` checks at every tier that nothing was dropped, and it is committed as a docs change; `glab` never removes `plan/<slug>/` or an audit file, and whether a folder is removed is the repo's own `AGENTS.md` decision; this repo's `AGENTS.md` keeps a short rule under which the manager session removes a landed folder (`docs/specs/marketplace.md`).
- [feature-docs-specs/plan.md U11] Retrieval is read-only everywhere: one file `git show <sha>:plan/<slug>/<file>`, the list `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole folder `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`; no `git restore` into the repo (the user's).
- [feature-docs-specs/plan.md D1] Four areas — `marketplace.md`, `workflow.md`, `memory-sync.md`, `external-agents.md` — following the plugin boundary; `AGENTS.md`'s `plan/` rule names them.
- [feature-docs-specs/plan.md D2] Fixed headings and greppable tags: every follow-up, question and open list keeps its source as `[<slug>/<file> <id>]`, so "none lost" is a search, not a judgment.
- [feature-docs-specs/plan.md D3] A spec names the last commit that holds the folder, not the removal commit, because a commit cannot carry its own hash; in this repo that is the last commit on `origin/main` that holds it (`AGENTS.md`, the `plan/` rule).
- [feature-docs-specs/plan.md D4] Stage 8 — Record, after Stage 7: `glab:developer` writes the spec from the folder and changes nothing inside it, so it writes no `result.md`; at full tier one `glab:reviewer` pass on the spec diff alone is what "checked by independent readers" now means; the commit goes out on its own go-ahead — its removal by `glab:committer` was cut (`[feature-docs-specs/plan.md U10]`, D34).
- [feature-docs-specs/plan.md D5] Installer wording: specs in `docs/specs/` unless the repo's `AGENTS.md` names another place, and a folder from before the rule (a `plan.md` with no `## Record`) is not recorded; its removal clauses moved to the repo's own `AGENTS.md` (`[feature-docs-specs/plan.md U10]`), where no untracked file under `plan/` is removed.
- [feature-docs-specs/plan.md D8] Payload text cites the spec, named with its repository, never a `plan/` path or a commit of this repo: an installer can follow neither.
- [feature-docs-specs/plan.md D10] A spec is not one of the *One fact* files: it states a fact as of its last record and names the file that owns it; `AGENTS.md`'s `plan/` rule says so.
- [feature-docs-specs/plan.md D11] Closed items migrate too, under *Closed follow-ups* with their evidence (`AGENTS.md`: every follow-up, open or closed).
- [feature-docs-specs/plan.md D16] An audit file is a working file too: its still-open items go into the area spec when the change that acts on it is recorded — its removal by that record commit was cut (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md D22] A model choice "for this task" ends with the task's record, not its push; a task with no plan folder ends with its push. Only `manager/SKILL.md` Rule 5 states the duration.
- [feature-docs-specs/plan.md D26] An audit file stays where `glab:audit` puts it, directly under `plan/`; the plan's `## Record` names it and Stage 8 hands it to the developer and the analyzer as a source — its removal by the committer was cut (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md D27] The record check is `glab:analyzer`, at every tier, with the folder's tracked files as its contract (the payload reads every file: `[feature-docs-specs/follow-ups.md 2]`); one fix round, then the analyzer again; still `DIVERGES` → the user. The full-tier reviewer pass stays, on the spec diff alone.
- [feature-docs-specs/plan.md D28] A pre-rule folder is one whose `plan.md` has no `## Record`; a waiver's folder has no `plan.md` and is recorded.
- [feature-docs-specs/plan.md D32] Tags are matched as items: only a line that starts with `- [tag]` counts, a tag inside another item is a cross-reference, and no tag sits under both *Open* and *Closed follow-ups*.
- [feature-docs-specs/plan.md D33] Stage 6 does not commit `plan/{slug}/`: nothing in the payload needs plan files in git, since the record reads the folder from disk; whether plan files are committed is the repo's convention (this repo's `AGENTS.md`: they are).
- [feature-docs-specs/plan.md D34] `committer.md`, `commit.md`, `push.md` and `ship.md` carry no record text: the record commit is an ordinary docs commit.
- [feature-docs-specs/plan.md D35] The record check ends in the analyzer's existing verdicts: `CONFORMS`, or `DIVERGES: <n> steps`, each missing item one step.
- [feature-docs-specs/plan.md D36] The record is an ordinary docs change, through the normal commit and push stages; a decision made at Stage 8 goes in the dispatch and the spec, not in `plan.md`.
- The decisions behind Rule 5's external developer, Rule 6's exceptions and `/glab:develop`'s external path — `[feature-external-developer/plan.md U1]` to `U4`, `D1`, `D6`, `D7`, `D8`, `R4.7` and the user's approvals of revisions 3 and 4 and of the round 3 scope cut — are carried in `docs/specs/external-agents.md`, the change's primary area, and bind here too. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): they no longer bind, since what they governed was removed; kept in that spec as a record.
- The decisions behind Rules 5 and 6 for Codex — `[feature-codex-agent/plan.md U4]`, `U5`, `D6`, `D17`, `D30` and the user's Q5 and Q6 — are carried in `docs/specs/external-agents.md`, the change's primary area, and bind here too. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): they no longer bind, since Rule 6 and Rule 5's Codex reviewer were removed; kept in that spec as a record.
- [subagent-effort/questions.md Q1] A — "One shared effort (Recommended)": one session effort, one record line and one source order for Claude subagents and Codex; Codex still maps the level down to the highest its model supports. It supersedes the record-line half and the source order of `[feature-codex-agent/questions.md Q6]` (carried in `docs/specs/external-agents.md`): when the user has named a session level in chat, Codex follows it instead of `CLAUDE_CODE_EFFORT_LEVEL` (the user's, 2026-10-19). History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): its Codex half lapsed with Codex; the one session effort still binds for Claude subagents.
- [subagent-effort/plan.md D1] Rule 0d sits in `glab:manager` between Rule 0c and Rule 1, as the user's approved text with `glab:`-prefixed role names.
- [subagent-effort/plan.md D2] The handoff line is `slug · stage · round n/max · verdict · effort <level>`, `model <m>` still after the stage on develop and review lines; it names the level passed — for Codex the level sent; an OpenCode line names none, because OpenCode takes no effort. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): the Codex and OpenCode clauses lapsed; the line names the level passed (`[remove-external-agents/plan.md D6]`).
- [subagent-effort/plan.md D3] Rule 0d's bullet "The model is Rule 5's, the effort is this rule's": an agent dispatched with no `model` still gets `effort`, and a level the parameter does not take (`ultra`) is asked about, as Rule 5 does for a model name.
- [subagent-effort/plan.md D4] Commands change only where they list Agent tool parameters — `develop.md`, `review.md`, `ship.md`; `plan.md`, `analyze.md`, `integrate.md` and `commit.md` stay, as they stay for Rule 0c.
- [subagent-effort/plan.md D5] `glab:bootstrap`, `manager-bootstrap.sh` and `README.md` each gain one clause, because each states the dispatch contract as complete.
- [subagent-effort/plan.md D6] No agent definition changes: the parent passes the level per dispatch; an `effort:` key would fix one level per role in the plugin instead of the session's, and the user asked for the parent to pass it.
- [subagent-effort/plan.md D7] The UNVERIFIED that a plugin agent honours `effort` goes into this record's *not verified*, not into the payload — the user's approved wording has no such sentence (`[subagent-effort/plan.md unverified]`, below).
- [subagent-effort/plan.md D8] Rule 0d's level and record line are Codex's too, mapped down to the highest level the model supports — Q1 = A, the user's answer, not a planner choice. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): lapsed with Codex.
- [subagent-effort/plan.md stage-1b] Stage 1b ended at round 2/2 `NOT BUILDABLE` on two missing checks; the user chose "Add checks, then build" (2026-10-19), with no third round.
- [subagent-effort/plan.md approval] Approved by the user, 2026-10-19: "go a head". Its session line, `- effort: high (the user's words: "let's for now set the effort for your subagent you current session high level"), for the session`, was that change's own and is spent.
- [feature-docs-specs/plan.md spent] U3, U5, U6, U7, U8, D7, D9, D12, D13, D14, D15, D17, D18, D19, D20, D21, D23, D24, D25, D29, D30, D31 — scoping and sequencing of that change: the migration of the seven folders, the live-run wording (applied in `AGENTS.md`; `docs/specs/external-agents.md`), the 0.5.0 bump and the `plugin.json` description, the commit split, the check script and its modes, the record's result file; U7 and D25 were superseded by U10 and U11 (the payload names no commit and checks no landing). D6 and `[feature-docs-specs/questions.md Q1]` bind in `docs/specs/external-agents.md`.
- [remove-external-agents/plan.md D4] The target of every edited passage was its text before `7139e62`, plus the later changes that are not about external agents (`fed95f9`'s Stage 8, the `BLOCK: 1 issue` of `5321d76`, `abda43a`'s session effort); the removal is not a `git revert`, which would have taken Stage 8 and the session effort with it.
- [remove-external-agents/plan.md D5] Rule 5's *Record it before the next dispatch* lost "The effort is not in the model line: Rule 0d's `- effort:` line records it, for Codex too." in full: it was added only because Codex model lines had carried an effort, and no Claude model line ever did.
- [remove-external-agents/plan.md D6] *The pipeline* keeps "The effort is the level you passed.", which still holds for every Claude dispatch, and lost only its Codex and OpenCode clause.
- [remove-external-agents/plan.md D7] Rule 0d keeps "for an Agent tool dispatch" before "a level it does not take": a smaller edit, and still true.
- [remove-external-agents/plan.md D9] `BLOCK: 1 issue` stays in `/glab:ship`, and the reviewer's verdict-lines entry of `AGENTS.md` *One fact* still lists `plugins/glab/commands/ship.md`: `5321d76` added it for the script's validator, but `glab:reviewer` emits it (`agents/reviewer.md:86` at `6b2a024`).
- [remove-external-agents/plan.md D11] No new text for a user who names an external reviewer or developer after 0.8.0: Rule 5's "A name the parameter does not take: say so, and ask which of the four the user means" covers it (inferred, `[remove-external-agents/plan.md inferred]`).
- [remove-external-agents/plan.md D14] Removing Rule 6 renumbered nothing: it was the last numbered rule of `glab:manager`.
- [remove-external-agents/plan.md approval] Approved by the user, 2026-10-20: "go ahead". Its session line, `- effort: high (the user's words: "let's for now set the effort for your subagent you current session high level"), for the session`, was that change's own and is spent.
- [remove-external-agents/plan.md spent] D1 (tier full), D13 (one `glab:developer`), D15 (`edits.py` as the exact edit list), D16 (nothing into `docs/specs/` in the change itself) — scoping of that change; `D2`, `D8`, `D10` and `D12` are in `docs/specs/marketplace.md`, `D3` in `docs/specs/external-agents.md`.

## Known limits and not verified

- [feature-model-switch/plan.md I1] That the Agent tool on the manager's host takes `model` with the values `sonnet`, `opus`, `haiku`, `fable`, ranked above the definition's frontmatter — read from the tool definition given to one session; it depends on the Claude Code version and host. Its documentation citations (F1–F7, F16) were not re-fetched by the developer (`result.md` *Not done*).
- [feature-model-switch/plan.md I4] That a plugin agent honours the per-dispatch `model` — inferred from the docs' list of fields a plugin agent ignores; no live dispatch on `haiku` has been seen running on `haiku`. Rule 5 says so in its own text; `/tasks` would show it.
- [subagent-effort/plan.md unverified] UNVERIFIED: that a plugin agent honours the Agent tool's `effort` parameter — no live dispatch has shown it, the same hedge Rule 5 makes for `model`; the tool schema of the planning session showed only that `effort` takes `low|medium|high|xhigh|max` and that an omitted one leaves the agent at its usual effort. Unlike Rule 5's hedge, Rule 0d's payload text does not say so (`[subagent-effort/plan.md D7]`). Also not checked: how a session started without subagent dispatch is put at the recorded effort (`[subagent-effort/plan.md F1]`). `result.md` restates the first item.
- [subagent-effort/result.md blast-radius] Inferred, not tested: an older plan's `- model: … codex, effort <level> (…)` line is still readable prose, while the rule now records the effort in a `- effort:` line instead. Since `glab` 0.8.0 (`467b7c4`) no rule reads a Codex model line at all.
- [remove-external-agents/plan.md inferred] Inferred, not shown: a user who names an external reviewer or developer after 0.8.0 meets Rule 5's "say so, and ask which of the four the user means" (`D11`); no session was run. The user's own auto-memory, outside this repository, still describes Codex as an outside reviewer and developer "via the skill", which no longer exists; it is the user's file and the change did not touch it.
- [remove-external-agents/result.md not-done] UNVERIFIED: that a live session follows the edited prose of `glab:manager` and the commands as intended — no session was run against it, as the plan accepts; the searches C2–C4 show only that nothing naming the removed parts is left outside `docs/specs/` and `plan/`.
- That the user's local edits ported by `sync-local-edits` were exactly their 2026-10-08 change: inferred from the dispatch and the file times, not from a record of the edit (`[sync-local-edits/result.md L219]`).
- No `glab` stage removes a plan folder: Stage 8 writes the spec only, and a repo that wants its folders removed says how in its own `AGENTS.md` (`[feature-docs-specs/plan.md U10]`). A repo with no such rule keeps every recorded folder in its tree. This repo's rule is in `docs/specs/marketplace.md`.
- Stage 8 names no commit and checks no landing: it starts once Stage 7 has confirmed the push, and the record reads the folder from disk, so a squash or rebase merge does not change what it records. Naming the commit that holds a removed folder is the repo's own rule; this repo's names the last commit on `origin/main` that holds it, after `git diff --quiet origin/main -- plan/<slug>/`. In a throwaway repo a squash merge left the branch commit off `origin/main` and the folder on it, and `git log -1 --format=%h origin/main -- plan/<slug>/` gave the squash commit (feature-docs-specs findings, *Amendment — review round 1/3*).
- [feature-docs-specs/plan.md unverified] Not shown, as of the record: that an installed `0.5.0` runs Stage 8 as written (needs a session on an installed copy); that every incident of the seven migrated folders reached a spec and each migrated status is true (the check script proves tags and presence, not truth); that the payload texts read well; and the back-out's inference that an installed `0.5.0` ignores a move back to `0.4.2`. The squash-merge item of that list is answered above.
- [feature-docs-specs/findings.md inferred] The specs, the payload text and `AGENTS.md` are prose: no command judges them correct. An installed copy follows the rule only from `0.5.0`; the agents that built and recorded `feature-docs-specs` ran the installed `0.4.2`, so its folders were removed under `0.4.2` contracts, and its record (X1) was dispatched with Stage 8's steps in the message.

## Open follow-ups

- [sync-local-edits/follow-ups.md 7] `commands/develop.md:67`: a `waived.md` has no tier line, so the waiver path has no next stage — reopened: the routing to `/glab:integrate` was removed by the review's scope cut, because a waiver has no plan and no tier, and the integrator, the integrate scope and the review cap need both. A fix has to give a waiver a tier and an integrator input first.
- [sync-local-edits/follow-ups.md 13] `glab:manager` Rule 0c seam note and Stage 1, `glab:plan-first`: "may overrule one" conflicts with Rule 4, where a relayed decision binds and the surface owner has the last word. Suggested: except a line recording another session's decision — open.
- [sync-local-edits/follow-ups.md 14] Stage 1: recording an overrule as a new line leaves steps built on the old choice. Suggested: send the plan back to the planning agent to amend them — open.
- [sync-local-edits/follow-ups.md 15] Rule 3 still reads as "the manager writes the decision line", while Stage 1 says the planner writes it. Suggested: one clause, during planning the planner writes it and the manager reviews it — open.
- [sync-local-edits/follow-ups.md 16] `commands/integrate.md:10`: the integrator agent is never told the normal-tier scope (milestone test only). Suggested: "Say which in the dispatch." — open.
- [sync-local-edits/follow-ups.md 17] `scripts/manager-bootstrap.sh:17`: "-> commit -> push -> record at full tier" (as at `09d2787`; it read "-> push at full tier" when raised) can read as "only at full tier", and Stage 1b is missing. Suggested: "At full tier work moves through plan -> analyze -> develop -> …" — open.
- [sync-local-edits/follow-ups.md 18] `AGENTS.md` *One fact*: the analysis round caps are stated in the manager and bootstrap but not listed. Suggested: add them as a known case — open.
- [sync-local-edits/follow-ups.md 19] `commands/develop.md:67`, `commands/ship.md:32`: after a normal-tier review fix the develop handoff re-runs integrate and review, while the manager says the gates are the only check on that fix; `/glab:ship` has no normal-tier exception. Suggested: align with Stage 5 — open.
- [bug-reviewer-findings/follow-ups.md 16] `reviewer.md` and `integrator.md` fell back to "the scratchpad" while `CLAUDE.md` and bootstrap said "`$TMPDIR` if set, scratchpad otherwise" — changed since, not shown fixed: both now say "the temp directory the dispatch message names (the scratchpad only if it names none)" (`reviewer.md:73`, `integrator.md:39` at `6838133`); whether that agrees with bootstrap's wording was not re-checked.
- [bug-reviewer-findings/follow-ups.md 18] Cosmetic: `agents/developer.md:15` calls the fallback file "the working agreement" in passing; `commands/commit.md:6` has two dashes in a row — open: re-read at `6838133`, `commit.md:6` still reads `— say so) — the commit format`, and `developer.md:15` still reads `(or CLAUDE.md if the repo has none — say so) — the working agreement`.
- [bug-reviewer-findings/follow-ups.md 19] Bootstrap's grep hazard ("leading alternation returns zero matches") did not reproduce in three attempts and is worded as observed — open: `bootstrap/SKILL.md:156` (at `09d2787`; `:151` at `6838133`) still reads "observed returning **zero matches with no error**".
- [bug-reviewer-findings/result-review1-prose.md L109] Bootstrap's one-line check could name the host file as a fifth item — open, not asked for: at `6838133` it names four (agreement and constants, gates, stage, what the previous session left).
- [bug-reviewer-findings/result-slice2.md L99] `agents/reviewer.md`'s description (`:3`) still speaks of `AGENTS.md` only, beside the `CLAUDE.md` fallback in its body — open, cosmetic.
- [feature-docs-specs/follow-ups.md 2] `agents/analyzer.md:56` and `agents/developer.md:98`: the record reads every file of `plan/<slug>/`, untracked ones included, so a scratch file holding host values could reach a committed spec (`glab:security`). Suggested: read `git ls-files -- plan/<slug>/` and name any untracked file in the report instead — open, for one small payload change of its own.
- [feature-docs-specs/follow-ups.md 4] `skills/bootstrap/SKILL.md:125`: "what a finished change left open is there, not in `plan/`" is wrong in a repo that keeps its plans, which is `glab`'s default. Suggested: "is there; `plan/` may still hold the working files" — open.
- [feature-docs-specs/follow-ups.md 5] `skills/manager/SKILL.md:127` against Stage 8's "not in `plan.md`": a model the user names for the record's developer has nowhere to be recorded. Suggested: one clause in Rule 5 — for Stage 8 the instruction lives in the conversation only, as for a `/glab:review` with no plan — open.
- [feature-docs-specs/follow-ups.md 7] Commits rule: `fed95f9` holds two logical changes of the payload, the Stage 8 record and the re-pointed citations, committed as one under `0.5.0` — open, an advisory of review round 3/3; nothing to undo now, a reminder for the next payload change.
- [feature-docs-specs/result-SM.md 3] Facts the specs state as of their record that move with their owners and that no gate ties to the specs (`[feature-docs-specs/plan.md D10]` accepts this): `PASS 35/35` and `PASS 49/49`, the allowlist and DeepSeek's end date, 2026-10-31, the `glab` version — open: each record has to re-read them; re-read by `feature-codex-agent`'s record: `PASS 71/71` at `9108ac7`, `glab` `0.6.0`, the allowlist and its end date unchanged; by `feature-external-developer`'s: `PASS 84/84` at `33a28df`, `glab` `0.7.0`, the allowlist unchanged; by `fix-external-agent-claims`'s: `PASS 86/86` at `3965622`, `glab` `0.7.1`, the allowlist unchanged; by `subagent-effort`'s: `PASS 35/35` and `PASS 86/86` at `abda43a`, `glab` `0.7.2`, the allowlist unchanged (the change touched neither the script nor its tests); by `remove-external-agents`'s: `PASS 35/35` at `467b7c4` (run for this record), `glab` `0.8.0`, and `PASS 86/86`, the allowlist and DeepSeek's end date gone with the script and its test, so what is left to re-read is the `memory-sync` count and the versions.
- [subagent-effort/plan.md F1] `glab:manager` *When subagent dispatch is not available* says how a stage session is started on the recorded model but not at the recorded effort; whether `claude` takes an effort at start was not checked — open.
- [subagent-effort/result.md finding-4] Review round 1's finding 4: `commands/commit.md`, `commands/analyze.md` and `commands/integrate.md` dispatch an agent and do not mention the effort; accepted as-is under `[subagent-effort/plan.md D4]` (commands change only where they list Agent tool parameters), not fixed — open.
- [subagent-effort/record.md round-2-ultra] Review round 2 advisory, carried from the manager's Stage 8 dispatch record (no review file is in the folder): `skills/manager/SKILL.md` Rule 0d (`:71` at `abda43a`) has the manager ask which level the user means when they name `ultra` for an Agent tool dispatch, but does not say how far that answer reaches — for that dispatch only, or for the session; Codex still takes `ultra` — open. Re-read at `467b7c4`: Rule 0d (`:71`) still does not say how far the answer reaches; Rule 0d's Codex sentence is gone with Rule 6, so "Codex still takes `ultra`" is history — still open.
- [subagent-effort/record.md round-2-pipeline-default] Review round 2 advisory, from the same dispatch record: *The pipeline*'s handoff sentence (`skills/manager/SKILL.md:189` at `abda43a`) says the effort is "the level you passed" and does not name `effort default`, which Rule 0d (`:67`) has the handoff line carry when the Agent tool rejects or does not offer `effort` — open. Re-read at `467b7c4`: the sentence (`:173`) now ends "The effort is the level you passed." and still does not name `effort default` — still open.

## Closed follow-ups

- [sync-local-edits/follow-ups.md 1] Rule 4 named no channel for settling a seam, and a relayed decision bound with no stated source — fixed (D1; `manager/SKILL.md` Rule 4).
- [sync-local-edits/follow-ups.md 2] Nothing said what a `plan.md` with no tier line is — fixed (D2): full tier.
- [sync-local-edits/follow-ups.md 3] Rule 3 credited `glab:security` with confirmations it does not state — fixed, then corrected after review (D3): the stop list and *Destructive operations are proven* stay `glab:security`'s, confirmation before every destructive action and push is the manager's own rule.
- [sync-local-edits/follow-ups.md 4] *One fact*: bootstrap had been dropped from the round-cap list; the ask-conditions were not a known case — fixed (D4; `AGENTS.md` *One fact*).
- [sync-local-edits/follow-ups.md 5] `commands/integrate.md:10` was not updated for normal tier — fixed (D5).
- [sync-local-edits/follow-ups.md 6] `develop.md:61` re-ran `/glab:analyze` after an amendment at normal tier — fixed (D6).
- [sync-local-edits/follow-ups.md 8] `analyze.md:18` "If I do amend it" contradicted its line 15 — fixed (D8).
- [sync-local-edits/follow-ups.md 9] Manager and plan-first disagreed on who decides a planning choice — fixed (D9).
- [sync-local-edits/follow-ups.md 11] The 1b row's "Leaves on" ignored normal tier's one amendment — fixed (D11).
- [sync-local-edits/follow-ups.md 12] Wording in bootstrap, `review.md` and the hook was narrower than the manager's — fixed (D12).
- [sync-local-edits/follow-ups.md 10] The spec entry had no stage, owner or location; "checked by independent readers" was undefined; plan-folder removal depended on a repo rule that may not exist (reopened by the scope cut of 2026-10-16) — closed by `feature-docs-specs`: Stage 8 names its stage, owner, place and readers (`glab:developer` writes the area spec under `docs/specs/`, `glab:analyzer` checks it at every tier, one `glab:reviewer` pass at full tier), and removal is the repo's own `AGENTS.md` decision.
- [feature-docs-specs/follow-ups.md 9] The specs described the lifecycle as of `6838133`; the record had also to update the pipeline bullet and the Rule 5 duration sentence of this file, besides what `plan.md` X1 listed — closed: done in this record (*How it works now*, the pipeline and the model rule).
- [feature-docs-specs/follow-ups.md 10] A stray `__pycache__/fixes-r2.cpython-314.pyc` in the plan folder — closed: removed by the manager before commit; `git ls-tree -r --name-only 09d2787 -- plan/feature-docs-specs/` lists no `__pycache__`.
- [feature-docs-specs/result-SM.md 1] The record had to move every mention of `[sync-local-edits/follow-ups.md 10]`, not one bullet — closed: *How it works now*, the D10 line and *Known limits* now state Stage 8; its *Records* section line keeps the history of the reopening.
- [feature-docs-specs/result-SM.md 2] `[bug-reviewer-findings/follow-ups.md 18]`'s status differed from that change's `findings.md` — closed: re-read at `09d2787`, `agents/developer.md:15` and `commands/commit.md:6` still read as the item quotes, so the spec's status (open) is the tree's.
- [feature-codex-agent/record.md effort-line] Raised by this record (Stage 8, review of the record): `glab:manager` Rule 6 gives the `- effort: codex <level> …, for the session` line for a general Codex agent but not where it goes; D30's placement — under `## Decisions` of the plan in progress, or the conversation only with no plan — is in `plan.md` alone at `30f2c80`. Suggested: one clause in Rule 6 — closed by `subagent-effort` (`abda43a`): the `- effort: codex` line is gone (`command grep -c -F -- '- effort: codex'` → `0` in `skills/manager/SKILL.md` and `skills/external-agents/SKILL.md`, S3 and S4 of its `result.md`); Rule 6 (`skills/manager/SKILL.md:165`) records Codex's effort "as Rule 0d says", and Rule 0d (`:69`) places its `- effort:` line "under `## Decisions` in the current task's `plan/{slug}/plan.md`, or in this conversation when there is no plan".

## Incidents

- **#7 and #10 were reopened by the review's scope cut** (2026-10-16): one normal-tier review of the follow-up fixes returned `SHIP WITH SCOPE CUT`. The waiver routing was removed, since a waiver has no plan and no tier; the manager's spec-entry paragraph was removed, since it dispatched the developer outside any plan step and a re-dispatch overwrites `result.md`. The earlier sync review had already cut "— one at normal tier —" from `ship.md:32`, because `/glab:ship` takes only a path and cannot know a plan's tier.
- **Why Stage 1b exists, and the 40-of-45 post-condition**: told in `glab:manager` *Stage 1b — Analyze the plan* (a step that could not be built found only by a developer's whole run; a check expecting 40 patterns, exactly what a tree with one step skipped produces). Pointed at, not copied.
- **A regex prefixed a path**: porting the user's edits, the substitution that put `glab:` back turned `plan/{slug}/plan.md` into `plan/{slug}/glab:plan.md` in two manager lines; it was caught by checking that every `/glab:` has a backtick before it, and fixed before the change was installed (`sync-local-edits` `result.md`, *Stages*).
- **One review verdict set, stated four times**: the model-switch review fix named the three last-round verdicts in Rule 5 against its own D22, so the set was then stated in Rule 5, Stage 5, `ship.md` and `reviewer.md` with no *One fact* case (`feature-model-switch` `result.md`, *Tension with the plan*). `AGENTS.md` now lists the reviewer's verdict lines as a known case.
- **Review round 1 fixes added the machinery round 2 blocked** (`feature-docs-specs`, 2026-10-18): round 1 asked for a guarded removal, so its fixes gave the payload a committer `git rm` with a guard, default-branch and `merge-base --is-ancestor` preconditions and a `git restore` instruction; round 2 returned `BLOCK 4` and `BLOCK 1`, every finding in that fix code. The user cut the scope (`[feature-docs-specs/plan.md U10]`, `U11`): Stage 8 records the spec only, retrieval is read-only, and round 3 removed logic and added no guard. The four files the cut returned to the base were checked equal to `6838133`.
- **The planner's write into its own plan folder was refused** (`feature-docs-specs`): it wrote the plan files under `$TMPDIR` with a `SHA256SUMS` file, and the manager verified and copied them in.
- **A file named `findings.md` was refused** (`subagent-effort`): the session's Write tool refused a file of that name, so the findings were written as a `## Findings` section of `plan.md`, which `glab:plan-first` allows at normal tier (`plan.md` *Findings*). The folder holds no `findings.md`.
- **Stage 1b ended on missing checks** (`subagent-effort`): round 2/2 returned `NOT BUILDABLE` on two missing checks; the user chose "Add checks, then build", and the plan was built with no third round (`[subagent-effort/plan.md stage-1b]`).
- **A file named `findings.md` was refused again** (`remove-external-agents`, 2026-10-20): the Write tool refused that file name for the planning agent, so the findings are the *Findings* section at the end of `plan.md`, as in `subagent-effort`; the folder holds no `findings.md` and no `questions.md`.

## Records

- 2026-10-16 · sync-local-edits · the user's local edits of 2026-10-08 ported into `glab` (risk tiers, Rule 3 decisions, Rule 4 surfaces), then twelve consistency fixes; two reopened, seven new found · change 5f69d65 70166f4 · records 0dec5e2 9700bcb · plan: `git ls-tree -r --name-only 9700bcb -- plan/sync-local-edits/` (one file: `git show 9700bcb:plan/sync-local-edits/<file>`)
  - [sync-local-edits/follow-ups.md L58] After the review of the follow-up fixes (2026-10-16) → `[sync-local-edits/follow-ups.md 7]` and `[sync-local-edits/follow-ups.md 10]` reopened, `[sync-local-edits/follow-ups.md 3]` corrected, new `13`–`19`, all under their tags above.
  - [sync-local-edits/result.md L215] Follow-ups → none written; the contradictions it reported were decided in its second set, `[sync-local-edits/result.md decisions]`; nothing open.
  - [sync-local-edits/result.md L219] Not done → the UNVERIFIED that the local edits are exactly the 2026-10-08 change, under *Known limits*; no commit was its step.
- 2026-10-16 · feature-model-switch · `glab:manager` Rule 5: the user names the model of the developer or the reviewer, passed per dispatch, recorded, shown in each handoff, the dispatch written for it · change 1f12a37 · records 889b804 · plan: `git ls-tree -r --name-only 889b804 -- plan/feature-model-switch/` (one file: `git show 889b804:plan/feature-model-switch/<file>`)
  - [feature-model-switch/result.md L96] Follow-ups → nothing open ("None").
  - [feature-model-switch/result.md L100] Not done → the commit split: done (`1f12a37`, `889b804`); `[feature-model-switch/plan.md I1]` and `[feature-model-switch/plan.md I4]`, with the unchecked doc citations, under *Known limits*.
- 2026-10-05 · bug-reviewer-findings · recorded in `docs/specs/memory-sync.md`; its workflow items (questions Q3, Q7, Q10; follow-ups 16, 18, 19; two open items from its result files) are tagged above · plan: `git ls-tree -r --name-only 2aeb46d -- plan/bug-reviewer-findings/` (one file: `git show 2aeb46d:plan/bug-reviewer-findings/<file>`)
- 2026-10-18 · feature-docs-specs · one spec per area in `docs/specs/`, the seven plan folders migrated into them and removed; `glab` `0.5.0` gains Stage 8, the record, which writes the area spec and never removes a plan folder; this repo's `AGENTS.md` keeps the removal for the manager session · change e3e0d69 fed95f9 196ff22 · records 09d2787 · plan: `git ls-tree -r --name-only 09d2787 -- plan/feature-docs-specs/` (one file: `git show 09d2787:plan/feature-docs-specs/<file>`)
  - [feature-docs-specs/follow-ups.md L1] Follow-ups (review round 3/3 advisories) → `2`, `4`, `5`, `7` open and `9`, `10` closed, here; `1`, `3`, `6`, `8` open in `docs/specs/marketplace.md`.
  - [feature-docs-specs/plan.md L504] Not in this plan → the migrated follow-ups it did not fix stay under their own tags; the Markdown gate is `[bug-reviewer-findings/follow-ups.md 20]` (`docs/specs/marketplace.md`); the profile re-tune `[feature-opencode-worker/follow-ups.md 12]`, DeepSeek's end date `[feature-opencode-worker/plan-r3.md not-in-plan-4]` (`docs/specs/external-agents.md`); the smoke test `[feature-plugin-marketplace/plan.md smoke-test-1]`; a `docs/constants.md` and a spec index were not asked for; `plan/SESSION-HANDOFF.md` stays untracked — nothing new open.
  - [feature-docs-specs/plan.md L511] UNVERIFIED, in one place → `[feature-docs-specs/plan.md unverified]`; its squash-merge item answered under *Known limits*.
  - [feature-docs-specs/findings.md L443] Inferred behaviour → `[feature-docs-specs/findings.md inferred]`; its squash-merge item answered under *Known limits*.
  - [feature-docs-specs/result-PR.md L31] Blocked → nothing.
  - [feature-docs-specs/result-PR.md L113] Follow-ups → none written; so too its round sections at `L251`, `L305` and `L418` ("None.").
  - [feature-docs-specs/result-PR.md L117] Not done → the other slice and the commits: done (`e3e0d69`, `fed95f9`, `196ff22`, `09d2787`); B2: checked; the record: this record; its UNVERIFIED → `[feature-docs-specs/plan.md unverified]`.
  - [feature-docs-specs/result-SM.md L59] Blocked → none.
  - [feature-docs-specs/result-SM.md L254] Follow-ups → `[feature-docs-specs/result-SM.md 1]` and `2` closed, `3` open, here.
  - [feature-docs-specs/result-SM.md L273] Not done → the other slice, the commits and the record: done; B2 checked without `git fetch`: history; its UNVERIFIED → `[feature-docs-specs/plan.md unverified]`.
  - [feature-docs-specs/result-SM.md L368] Follow-ups (review round 1 fixes) → none new.
- 2026-10-18 · feature-codex-agent · recorded in `docs/specs/external-agents.md`, its primary area; here: Rule 5's Codex record line, its `--model` rule and the effort, Rule 6 covering two backends, D30's effort line, `/glab:review` naming Codex · change 9108ac7 · records 30f2c80 · plan: `git ls-tree -r --name-only 30f2c80 -- plan/feature-codex-agent/` (one file: `git show 30f2c80:plan/feature-codex-agent/<file>`)
- 2026-10-18 · feature-external-developer · recorded in `docs/specs/external-agents.md`, its primary area; here: Rule 5's external developer (Codex only) with its record and handoff lines and its table row, Rule 6's two exceptions, `/glab:develop`'s external path · change 33a28df · plan: `git ls-tree -r --name-only 33a28df -- plan/feature-external-developer/` (one file: `git show 33a28df:plan/feature-external-developer/<file>`)
- 2026-10-19 · fix-external-agent-claims · recorded in `docs/specs/external-agents.md`, its primary area; here only the re-read note of `[feature-docs-specs/result-SM.md 3]` · change 3965622 · plan: `git ls-tree -r --name-only abda43a -- plan/fix-external-agent-claims/` (one file: `git show abda43a:plan/fix-external-agent-claims/<file>`). `abda43a` is the last commit on `origin/main` that holds it; the folder is the same there as at `3965622`
- 2026-10-19 · subagent-effort · `glab:manager` Rule 0d: every subagent dispatch passes the Agent tool's `effort` at the session's level, recorded in one `- effort:` line and named in the handoff line; Codex shares that one level through Rule 6's mapping, and its model lines lose their effort clause; the dispatch text of Stages 2 and 5, `/glab:develop`, `/glab:review`, `/glab:ship`, `glab:bootstrap`, the hook and `README.md`; a new *One fact* entry; `glab` 0.7.2 · change abda43a · plan: `git ls-tree -r --name-only abda43a -- plan/subagent-effort/` (one file: `git show abda43a:plan/subagent-effort/<file>`; the whole folder: `git archive abda43a plan/subagent-effort/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `abda43a` is the last commit on `origin/main` that holds it: one `docs(repo)` commit after this record removes it and `plan/fix-external-agent-claims/`
  - [subagent-effort/plan.md L15] Findings (a section of `plan.md`, not a file: *Incidents*) → its *Inferred, not shown* (`L92`) is `[subagent-effort/plan.md unverified]`; its scope table, searches and call sites were that change's.
  - [subagent-effort/plan.md L99] Decisions → `[subagent-effort/plan.md D1]` to `D8`, `stage-1b` and `approval`, above.
  - [subagent-effort/plan.md L265] Record → this record, in this file, `docs/specs/external-agents.md` and `docs/specs/marketplace.md`; `[feature-codex-agent/record.md effort-line]` closed. Order: the plan (`plan.md` L267) expected this record after the `fix-external-agent-claims` record had been committed; both records instead land in one `docs(repo)` commit, and the folder removal follows in another.
  - [subagent-effort/plan.md L276] Follow-ups → `[subagent-effort/plan.md F1]` open.
  - [subagent-effort/questions.md L3] Q1 → `[subagent-effort/questions.md Q1]`, A.
  - [subagent-effort/result.md L41] Blocked → none.
  - [subagent-effort/result.md L45] Unplanned changes → none; line wraps only.
  - [subagent-effort/result.md L209] Blast radius → `[subagent-effort/result.md blast-radius]`; its UNVERIFIED (`L228`) → `[subagent-effort/plan.md unverified]`.
  - [subagent-effort/result.md L231] Follow-ups → none added; F1 stays in `plan.md`, carried here.
  - [subagent-effort/result.md L236] Not done → the commit (`abda43a`); `docs/specs/` and `plan/SESSION-HANDOFF.md` left as they were; no real model or external agent run — nothing open.
  - [subagent-effort/result.md L244] Review round 1 fixes → fixes 1–3 built in Rule 0d (the `effort default` fallback, `ultra` scoped to an Agent tool dispatch, the session-wide line in every plan); finding 4 → `[subagent-effort/result.md finding-4]` open.
  - Review round 2 → no review file is in the folder; its two advisories, from the manager's Stage 8 dispatch record, → `[subagent-effort/record.md round-2-ultra]` and `[subagent-effort/record.md round-2-pipeline-default]` open.
- 2026-10-20 · remove-external-agents · recorded in `docs/specs/external-agents.md`, its primary area; here: `glab:manager` has no external reviewer or developer — Rule 6 gone, Rules 0d and 5 and *The pipeline* without their Codex and OpenCode sentences, Rule 5's dispatch table without its two external rows, Stage 5, the parallel review and *What you never do* without their external text; `/glab:develop`, `/glab:review` and `/glab:ship` without their external paths; Rule 0d unchanged for Claude subagents; every statement of the external agents in this file marked as history; `glab` 0.8.0 · change 467b7c4 · plan: `git ls-tree -r --name-only 467b7c4 -- plan/remove-external-agents/` (one file: `git show 467b7c4:plan/remove-external-agents/<file>`). `467b7c4` is the last commit on `origin/main` that holds it: one `docs(repo)` commit after this record removes it.
  - [remove-external-agents/plan.md L17] Decisions → `D4`, `D5`, `D6`, `D7`, `D9`, `D11`, `D14`, `approval` and `spent`, above.
  - [remove-external-agents/plan.md L567] Inferred → `[remove-external-agents/plan.md inferred]`.
  - [remove-external-agents/plan.md L247] Record → the follow-ups it names re-read: `[feature-docs-specs/result-SM.md 3]`, `[subagent-effort/record.md round-2-ultra]` and `[subagent-effort/record.md round-2-pipeline-default]` still open, each with its re-read.
  - [remove-external-agents/result.md L1] Result → every step done, no unplanned change, no follow-up written; its UNVERIFIED → `[remove-external-agents/result.md not-done]`.
