# Workflow — spec

The `glab` workflow: how a session runs a change through plan, analysis,
development, integration, review, commit and push, at the depth a tier
gives it; the rules of `glab:manager`; the agents and commands; the model
each agent runs on and the user's override of it (until `glab` 0.12.0 the
user's choice of model for the developer and reviewer only); and what happens to a
change's plan files, up to the record that moves what stays true into an
area spec. Owned by `plugins/glab/skills/manager/SKILL.md`,
`plugins/glab/skills/plan-first/SKILL.md`,
`plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/audit/SKILL.md`,
the agents under `plugins/glab/agents/`, the commands under
`plugins/glab/commands/`, `plugins/glab/scripts/manager-bootstrap.sh`
(the `SessionStart` hook text), and, since `glab` 0.9.0 (`2a1e919`),
`plugins/glab/scripts/context-size.sh` and `plugins/glab/hooks/hooks.json`
(the context hook). The external agents, removed in `glab`
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
`0.8.0`), and its `flow-cheaper-rounds` lines (the round caps, every round a
new agent, the delta re-checks, explore once, the narrower call-site audit,
the severity line, the context rule and the context hook, the handoff
line's `· context <n>k`) as of `2a1e919` (`glab` `0.9.0`), and its
`flow-planner` lines (`evidence.md`, the plan size budget and in-place
amending, `glab:plan-first`'s `implement.md`, the developer's context
rules, `GLAB_COMPACT_AT`) as of `2912002` (`glab` `0.10.0`), which added
`plugins/glab/skills/plan-first/implement.md` to the owning files, and its
`flow-master-plan` lines (the master plan and sub-plans, the intent check,
the analyzer's plan check, Stage 6b, approval after Stage 1b and in plan
mode, `## Record` in the master, the stage listings) as of `0cbf5b0`
(`glab` `0.11.0`), and its `flow-models-per-role` lines (the model per
role in each agent's frontmatter, Rule 5 reworded, `model <alias>` on every
agent stage's handoff line, `glab:planner` and `/glab:plan` dispatching it,
the two analyzer kinds and `/glab:analyze`'s routing by kind, the dispatch
table for the default) as of `517b7b6` (`glab` `0.12.0`); where this file
and an owning file disagree, the owning file is right.

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
- **The pipeline** (`glab:manager` *The pipeline*): 1 Plan (`/glab:plan`,
  `glab:planner` since `glab` 0.12.0, `09d5664`),
  1b Analyze the plan (`/glab:analyze`, plan only, `glab:plan-analyzer`
  since `09d5664`), 2 Develop
  (`/glab:develop`), 3 Analyze conformance, 4 Integrate (`/glab:integrate`),
  5 Review (`/glab:review`), 6 Commit (`/glab:commit`), 6b Final check
  (`/glab:analyze {slug}` as the final check, since `glab` 0.11.0,
  `0cbf5b0`; *Stage 6b*, below), 7 Push
  (`/glab:push`, no push agent), 8 Record (after the push: `glab:developer`
  on the record, `glab:analyzer` on what it carried, then `/glab:commit`; it
  leaves on the record commit verified, then pushed on the user's go-ahead).
  A change with a plan folder goes on from Stage 7 to Stage 8. Each handoff
  is one line, `slug · stage · round n/max · verdict · effort <level> · context <n>k`
  (Rule 0d; `slug · stage · round n/max · verdict` before `abda43a`; the
  `· context <n>k` field since `glab` 0.9.0, `2a1e919`, with
  `· dispatches <d>` in its place only when no `glab: context` line has
  come in the session — *The context rule*, below), with
  `model <m>` after the stage on every line of a stage that dispatches an
  agent (Rule 5; since `09d5664`, `[flow-models-per-role/plan.md D11]`:
  the definition's alias when no parameter was passed, `model <alias> (user)`
  when the user's override was; until then on a develop or review line
  only, `model default` when the user had named none). `max` is the
  stage's round cap, `2`, or `3` once the round-3 line is written, and a
  develop line counts its fix rounds against the cap of the stage whose
  findings it fixes (`glab:manager` *The pipeline*;
  `[flow-cheaper-rounds/plan.md D24]`). The effort is the
  level passed ("The effort is the level you passed.", *The pipeline*, as
  of `467b7c4`). History, until `glab` 0.8.0 (`467b7c4`, 2026-10-20): the
  sentence went on "for a Codex agent the level sent, after Rule 6's
  mapping; an OpenCode line names no effort, since OpenCode takes none".
  Without subagent dispatch each stage is a fresh
  session, `<slug> record` among them, and `<slug> final` since `0cbf5b0`.
  With sub-plans the handoff line names the sub-plan for the slug,
  `{slug}/02-hooks · analyze · round 1/2 · …`. The stage sequence is one
  fact in three places (`AGENTS.md` *One fact*, since `0cbf5b0`): the
  manager's description reads "→ review → commit → final check → push →
  record", the bootstrap diagram (step 4) "review ⇄  →  commit  →  final
  check  →  push  →  record", and the hook text "plan -> develop -> analyze
  -> integrate -> review -> commit -> final check -> push -> record, as far
  as the tier runs them (`glab:manager` -> *Pick the tier* says which)" —
  no tier runs every stage once a single full-tier plan skips the final
  check (`[flow-master-plan/plan.md D33]`, `D40`). Until `0cbf5b0` the hook
  text read `-> push -> record at full tier`.
- **The tier** (`glab:manager` *Pick the tier*), the first line of `plan.md`
  with its reason; no tier line means full. **Full**: a schema or data
  migration, a stored or wire format, code that decides who may do what,
  handles secrets or moves money — `evidence.md` (`findings.md` until
  `glab` 0.10.0, `2912002`), `plan.md`, `questions.md`
  if a question was raised, the user's explicit approval, 1b at most 2
  rounds, conformance at most 2 rounds, the whole suite at integrate, review
  at most 2 rounds. **Normal**: everything else — a one-page `plan.md`, no
  approval (the tier and decisions are reported), 1b at most 2 rounds, no
  conformance stage, the milestone test at integrate, review at most 2
  rounds. **Since `glab` 0.11.0** (`0cbf5b0`) every tier that plans writes
  `master.md` too (*The master plan and sub-plans*, below); the *Approval*
  row reads "Approval, after 1b": at normal tier yours, reported — the
  user's when the work split — and at full tier the user's, explicit, of
  `master.md` and of every full-tier `plan.md`, a single plan's or a
  sub-plan's; a sub-plan runs Stage 3 at every tier, max 2 rounds; and the
  row "6b Final check" is max 2 rounds at normal tier and at full tier,
  where a single plan uses Stage 3's instead. Until `0cbf5b0` full-tier
  approval came before Stage 1b (`[flow-master-plan/plan.md D26]`).
  **Trivial**: Rule 1's five lines, done directly. Each cap can
  grow by one round under *Round caps*, below (`glab:manager` *Pick the
  tier*, as of `2a1e919`). History, until `glab` 0.9.0 (`2a1e919`): the
  caps were 1b 2 rounds (full) or one pass (normal), conformance 4, review
  3 (full) or one round whose findings were fixed once (normal).
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
    stated; since `09d5664` `glab:plan-first` is "for `glab:planner`, the
    planning agent".
  - Rule 0d — every dispatch, to every subagent, passes the Agent tool's
    `effort` parameter at the session's level (*The session effort*,
    below); since `abda43a`. Since `09d5664` its agent list names
    `glab:planner` and `glab:plan-analyzer` too, and "An agent dispatched
    with no `model` parameter — on its definition's model (Rule 5) — still
    gets `effort`."
  - Rule 1 — the manager does not implement; questions and trivial changes
    are not the pipeline.
  - Rule 2 — the context budget: never read what an agent will read; agents
    write long output to disk and return a short report. Since `glab` 0.9.0
    it also holds *Every round is a new agent* and *Your own context — read
    it, act on it, never clear* (below), because the reason of both is cost.
  - Rule 3 — engineering choices are the manager's, recorded under
    `## Decisions`; the user is asked only when a choice is destructive,
    costs money, exposes real data or changes what the product is — at most
    one question per plan.
  - Rule 4 — one surface per session; seams are settled through the channel
    `docs/constants.md` names, or the user relays.
  - Rule 5 — since `glab` 0.12.0 (`09d5664`), "each agent runs on its
    role's model; the user's words override it" (*The model rule*,
    below): each of the seven agents' definitions sets its model, and the
    user's words, passed as `sonnet`, `opus`, `haiku` or `fable`, override
    it for the role they name. History, from `467b7c4` until `09d5664`: the
    model a `glab:developer` or `glab:reviewer` runs on was the user's call,
    `sonnet`, `opus`, `haiku` or `fable`, and nothing else; every other role
    got no `model` parameter. History, until `glab` 0.8.0 (`467b7c4`,
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
- **Agents** (`plugins/glab/agents/`; seven since `glab` 0.12.0,
  `09d5664`, each with its frontmatter `model`, *The model rule* below):
  `glab:planner` (`model: opus`, new in `09d5664`: plans one task in its
  folder by `glab:plan-first` and stops where that skill says planning
  ends; never writes code, never edits outside the plan folder its dispatch
  names — a new sub-plan's line in the slug's index and a new master when
  the user changed the request only when the dispatch grants it — never
  stages or commits; `tools: Read, Write, Edit, Grep, Glob, Bash, Skill,
  WebFetch, WebSearch`, no `Agent`; restates no `glab:plan-first` value,
  `[flow-models-per-role/plan.md D4]`, `D5`, `D18`), `glab:plan-analyzer`
  (`model: opus`, new in `09d5664`: the plan check and the master check of
  Stage 1b, with the intent question's plan-check part and the plan-check
  re-checks, ending `BUILDABLE`, `NOT BUILDABLE` or
  `BLOCK: target unresolved`; read-only, `tools: Read, Grep, Glob, Bash`;
  a conformance, final or record check dispatched to it ends
  `BLOCK: target unresolved`, naming `glab:analyzer`; `D6`, `D18`, `D20`),
  `glab:developer` (`model: sonnet`; builds the named
  steps, writes `plan/{slug}/result.md` and `follow-ups.md`, never stages;
  at the record it updates the area specs only and writes no `result.md`),
  `glab:analyzer` (`model: sonnet`; since `09d5664` the conformance check,
  the final check and the record check of Stage 8, ending `CONFORMS`,
  `DIVERGES: <n> steps` or `BLOCK: target unresolved`, and a plan check or
  master check dispatched to it ends `BLOCK: target unresolved`, naming
  `glab:plan-analyzer`, `D6`, `D7`; until `09d5664` it also did the
  plan-only analysis of Stage 1b — since `0cbf5b0` the plan check and the
  master check, with `BUILDABLE` and `NOT BUILDABLE` — each check with the
  intent question since `0cbf5b0`), `glab:integrator`
  (`model: sonnet`; the real running system, local only), `glab:reviewer`
  (`model: sonnet`; correctness and
  `AGENTS.md` rules, gets the target and nothing else; its verdict lines are
  one fact with `ship.md` and the manager — and, until `467b7c4`, the
  external-agent validator),
  `glab:committer` (`model: haiku`; explicit paths, never `git add -A`;
  Conventional Commits as `AGENTS.md` says). Until `09d5664` there were
  five agents, none with a `model` line, and no planning agent of its own:
  `/glab:plan` had the invoking session follow `glab:plan-first` itself,
  and the manager dispatched a generic agent for planning, on the main
  conversation's model (`[flow-models-per-role/plan.md E7]`, inferred
  there). **Commands** (`plugins/glab/commands/`):
  `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`,
  `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship`. Since
  `09d5664` `/glab:plan` uses the `glab:planner` agent, "dispatched as
  `glab:manager` Rules 0c, 0d and 5 say; it follows the `glab:plan-first`
  skill", as `/glab:analyze` dispatches its analyzer (`D4`); its three gates
  and its report list are unchanged. `/glab:analyze` keeps its one name and
  its slug argument and **routes by kind** (`D8`, `commands/analyze.md:6`
  as of `517b7b6`): the check is named in the dispatch message or by the
  user, never in `$ARGUMENTS`, which is only the slug; a named check comes
  first, whatever the folder holds — a plan check or a master check
  (Stage 1b) goes to `glab:plan-analyzer`, even when a `result.md` from an
  earlier build is there, as after a plan is amended; a final or record
  check (Stages 6b and 8) to `glab:analyzer`; with no check named, the
  folder settles it — a `result.md` under `plan/$ARGUMENTS/` means the
  conformance check, `glab:analyzer`, none means the plan check,
  `glab:plan-analyzer`; a named check that is none of these is asked about,
  never guessed. The named check is tested before the folder because a
  slug with sub-plans has no `result.md` at its own level, so its final
  check would otherwise reach `glab:plan-analyzer` (review round 1,
  `[flow-models-per-role/result.md R2.4]`, the manager's decision, which
  replaced "otherwise ask which check" for every unnamed check with a
  `result.md`); and a named plan or master check is tested before the
  folder because an amended plan keeps its earlier `result.md` (the PR #7
  review comment, fixed in `517b7b6`, D8 updated in place). A plan or
  master check sent to `glab:analyzer`, or a conformance, final or record
  check sent to `glab:plan-analyzer`, ends `BLOCK: target unresolved`
  (`[flow-models-per-role/result.md blast-radius]`). Since `09d5664`
  `/glab:analyze`, `/glab:integrate` and `/glab:commit` say their agent is
  "dispatched as `glab:manager` Rules 0d and 5 say" (review round 1,
  `[flow-models-per-role/result.md R2.10]`).
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
- **Round caps** (`glab:manager` *Pick the tier*, *Round caps*, as of
  `2a1e919`, `glab` 0.9.0). Stage 1b, Stage 3 and Stage 5 each run at most
  **2 rounds** at every tier where the stage runs (normal tier has no Stage
  3). Since `0cbf5b0` the final check (Stage 6b) has the same cap, and
  every cap counts per sub-plan where there are sub-plans; normal tier runs
  Stage 3 for a sub-plan; a sub-plan's round-3 line and round copies stay
  in its folder, and the master and final checks have theirs in `index.md`
  (`plan.md` with no sub-plans) (`[flow-master-plan/plan.md D29]`). A
  **third** round runs only when round 2 returned a finding rated
  `critical` or `high`, and only after the manager has recorded it under
  `## Decisions` as `- round 3: <stage> — <severity> <the finding, as its
  file:line or step id and its claim>`; with no plan behind the stage — a
  `/glab:review` or `/glab:ship` run on its own — the reason goes in the
  handoff line that announces the round, `round 3/3 (<severity> <finding>)`,
  and in the conversation, and once it can no longer be found there is no
  round 3. Nothing runs past round 3. The reviewer's side
  (`agents/reviewer.md`): round 2 is the last unless the reviewer reports a
  `critical` or `high` finding in it and answers `BLOCK: <n> issues`; round
  3 is the last with no exception; a round-2 `BLOCK` with no `critical` or
  `high` finding is that last round's verdict, there is no round 3, and it
  goes to the user (Rule 5's report check is for a malformed report only).
  What a stage does when its last round has not passed is unchanged: 1b at
  full tier → the user ("needs a design"); 1b at normal tier → after round 2
  a new planner amends once more and the plan goes on, `PLAN WRONG` the
  backstop; after a round 3, at every tier → the user; Stage 3 → the user
  with the three resolutions; Stage 5 → the last-round answer to the user
  (`[flow-cheaper-rounds/plan.md D6]`). At the last round the answer is
  `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>` or `DO NOT PUBLISH: <why>`;
  the verdict strings did not change. The round caps are one fact in
  `reviewer.md`, `analyzer.md`, `ship.md`, the manager and bootstrap
  (`AGENTS.md` *One fact*), and `plan-analyzer.md` since `09d5664`. History, until `glab` 0.9.0: plan analysis 2
  (full) or one pass (normal); conformance 4; review 3 (full) or 1
  (normal), "round 1 of 1" in Rule 5's example line.
- **Every round is a new agent** (`glab:manager` Rule 2, *Every round is a
  new agent*; `commands/develop.md`, `commands/ship.md`,
  `commands/analyze.md`; `[flow-cheaper-rounds/plan.md D7]`). A plan check,
  a planner's amendment, a developer's fix round, a re-dispatch after
  `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a
  Stage 8 record fix are each dispatched to a new agent that works from the
  files on disk and what its dispatch names — never by resuming the agent
  that ran before or sending it a follow-up. The cost reason is the one the
  change measured (*Known limits and not verified*, F1). The one resume is
  Rule 5's report check, for missing fields only. A round's findings travel
  in the next agent's dispatch, copied as the agent returned them — the one
  input not on disk, because the manager writes no findings file and the
  analyzer and reviewer are read-only (`D8`). A fix-round developer adds
  `## Fix round — <stage> round <n>` to `result.md` instead of overwriting
  it (`agents/developer.md` *A fix round*, `D9`); the overwrite rule stays
  for a re-dispatch of the same steps. Rule 5 carries the user's model into
  each fix round too, since a new agent no longer inherits it from a resume
  (`D23`).
- **Re-checks look at the delta** (`glab:manager` Stages 1b and 3,
  `agents/analyzer.md` *Re-checks — round 2 and later*). *Stage 1b.* Before
  the amendment goes to a new planner the manager keeps the version the
  round checked: `cp plan/{slug}/plan.md plan/{slug}/plan.r<n>.md`, and
  `evidence.md` to `evidence.r<n>.md` when there is one — `findings.md` to
  `findings.r<n>.md` in a folder from before `glab` 0.10.0, the only form
  until `2912002` (`[flow-planner/plan.md D38]`). It tests that the
  amendment changed something by exit code alone, `cmp -s` (0 identical,
  1 changed, 2 a file missing), for `plan.md` and for `evidence.md` (or
  `findings.md` in an older folder) — an empty delta is a stop, not a pass — and
  never reads the diff itself; only the analyzer of round `<n+1>` —
  `glab:plan-analyzer` since `09d5664` — runs
  `diff -u`, and checks each previous finding, every changed line and every
  step that rests on one, not the rest of the plan. A copy, not git,
  because the plan folder is untracked while it is planned and a snapshot
  of a gitignored `plan/` would be empty. The copies stay in the folder and
  are committed with it. Since `0cbf5b0` the same holds for `master.md`
  before its approval and for `index.md` (`master.r<n>.md`,
  `index.r<n>.md`, per sub-plan folder for a sub-plan's files; a master
  check has no `plan.md` to copy); after the approval a changed request
  leaves only a version copy `master.v<n>.md` (*The master plan and
  sub-plans*). The `cmp -s` runs as
  `cmp -s plan/{slug}/<name>.r<n>.md plan/{slug}/<name>.md` for each file
  the round checked; exit 1 on any file means the amendment changed the
  plan, exit 0 on every file that it changed nothing. *Stage 3.* Before each analyze round, round 1
  included, the manager snapshots the tree into a tree object through a
  temporary index, seeded from `HEAD` first (`GIT_INDEX_FILE="$idx" git
  read-tree HEAD && … git add -A && … git write-tree`), because a tracked
  file that matches `.gitignore` is otherwise missing; round `<n+1>` gets
  both tree ids and the previous findings and reads `git diff <old> <new>`.
  Ignored files are not in a snapshot, so a path the fix round's `files:`
  line names that the delta does not show is checked whole; a lost tree id
  means the round runs whole; with no commit yet `git read-tree HEAD` fails
  and that round runs whole (`D10`, `D11`, `D12`, `D49`, `D50`).
- **A review round after the first** is a new reviewer given the target,
  the previous round's findings verbatim and the range of the fix — the old
  and new tree ids (taken with Stage 3's snapshot) or two commit ids — and
  never the plan, the slug or the intent. It checks each previous finding
  closed or still open, reviews the fix range in full, and the whole target
  stays in its scope; text a previous round passed is not re-litigated
  (`agents/reviewer.md`, `glab:manager` Stage 5, `commands/ship.md`;
  `D51`, a *One fact* entry). At full tier, Stage 3 after a review fix is
  one delta round per review fix, against the tree id the last `CONFORMS`
  measured, handed also the review findings the fix answered; it neither
  resets nor uses Stage 3's cap, a `DIVERGES` there goes back to Stage 2
  inside the same review round, and that fix goes on to Stage 5 without a
  second Stage 3 round, so the loop stays bounded (`D54`).
- **Severity.** Each finding of `glab:reviewer` and each gap of
  `glab:analyzer` — and of `glab:plan-analyzer` since `09d5664` — carries a `severity:` line, `critical`, `high`, `medium`
  or `low`, on `glab:audit`'s *Severity Levels*, given by the agent that
  reports it and never re-ranked by the manager; it is the value the
  round-3 condition reads (`D4`). Nothing parses it (`F13`): it is a
  prompt-level contract between agents, and the verdict lines
  `/glab:ship` matches whole did not change.
- **Explore once** (`glab:manager` Stage 1, `glab:plan-first` Step 1). Mapping
  — read-only agents that read an area before the plan is written — is the
  manager's call per task. Each mapping agent writes
  `plan/{slug}/map-<area>.md` (every path it read, `file:line`, proven kept
  apart from inferred) and returns a short report; the planner is told the
  files, starts from them and reads code only for the gaps it names;
  without mapping agents the planner explores itself; never both over one
  area. The name is not `findings-<area>.md` because the Write tool refused
  that name for a subagent (*Incidents*). The analyzer reads the map files
  with the plan, the developer the ones the plan cites. Since `glab` 0.10.0
  (`2912002`) the same refusal names the plan's own findings file
  `evidence.md` (*Plan files*, below; `[flow-planner/plan.md D1]`).
- **The planner's call-site audit** (`glab:plan-first` Step 1, Step 4;
  `glab:manager` checklist item 3). The full audit — callers, what each
  relies on, shared or caller-specific contract — covers methods the plan
  **changes**; for a method it only **calls**, the precondition the new call
  site must meet and how the plan meets it; a file it only depends on is
  listed by path and not read in full. This is consistent with
  `glab:security` Rule 7, which binds before changing a function's
  signature, return values, error cases or timing (`D14`).
- **The context rule** (`glab:manager` Rule 2, *Your own context — read it,
  act on it, never clear*). The manager reads the number in the most recent
  `glab: context <n>k` line the hook added and puts it at the end of every
  handoff line (`· context <n>k`), as "the last completed call's context"
  and no more exact; it never reads the transcript. Inside a task, at the
  first handoff line at or past the first step — **300k**, or `<t>k` when
  the line names `compact at <t>k` (since `glab` 0.10.0, `2912002`; a fixed
  300k until then) — and again at the first past each
  further **100k**, it brings the handoff file up to date and suggests
  `/compact`. **A smaller window** (since `2912002`): when the line names no
  `compact at <t>k` and the manager's model has a context window not larger
  than the first step plus 100k — a 200k window under the default — it tells
  the user once that the step is near or past the window and that
  `GLAB_COMPACT_AT`, in thousands, exported in the shell that starts Claude
  Code, moves it; the number is the user's, never the manager's
  (`[flow-planner/plan.md D17]`). At a task boundary — after the push of the Stage 8 record, or
  after Stage 7 when there is no plan folder — it suggests `/clear` and a
  new session whatever the number says (no hook can tell a task boundary).
  Only when no `glab: context` line has come at all in the session (the
  plugin not enabled or older than 0.9.0, hooks off, no `jq`, no readable
  transcript) it says so once and counts instead: `/compact` after every 15
  dispatches and after any stage that took more than one round, the line
  ending `· dispatches <d>`; when lines come with user messages but not with
  Agent results it uses the most recent of either kind. The manager never
  runs `/clear` or `/compact` and never claims more precision (*What you
  never do*). The handoff file is the one `glab:bootstrap` step 5 reads,
  `plan/SESSION-HANDOFF.md` unless the repo keeps it elsewhere; no `glab`
  step commits it. 300k is where a resumed agent's rounds were already
  costing several times a fresh one's (*Known limits*, F1).
- **The context hook** (`plugins/glab/hooks/hooks.json`,
  `plugins/glab/scripts/context-size.sh`, tested by
  `tests/context-size.test.sh`; `[flow-cheaper-rounds/plan.md D29]`). One
  script, three modes, three new `glab` hook events — `UserPromptSubmit` →
  `context-size.sh prompt`, `PostToolUse` with matcher `Agent` →
  `context-size.sh agent`, `Stop` → `context-size.sh stop` — each with
  `timeout` 5, beside the unchanged `SessionStart` hook (`Hooks (4)`). It
  reads only `transcript_path` from the hook's stdin, never `tool_input`,
  `tool_response` or `prompt`. The measure is the last completed model call
  of the main conversation: of the last transcript entry that is an
  assistant entry, not a sidechain, whose usage sums
  `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` to
  more than 0, rounded up to thousands so a real value never prints `0k`;
  read from the last 8 MiB of the file (`tail -c 8388608` into one `jq`
  fold, one line at a time), so the cost does not grow with the file and an
  assistant entry longer than the window is not seen. `prompt` and `agent`
  emit on every event, with no threshold, `additionalContext`
  `glab: context <n>k (last completed call)` (about ten tokens), in the
  hook-specific output of their own event. `stop` speaks to the **user**:
  `{"systemMessage":"glab: context <n>k (last completed call) — a good point
  to /compact, or to /clear between tasks"}`, when the step of the latest
  written call (300k, 400k, 500k, …) is higher than the step at the real
  prompt before the last one. **`GLAB_COMPACT_AT`** (since `glab` 0.10.0,
  `2912002`; `[flow-planner/plan.md D12]` to `D16`): read from the
  environment after the transcript, in thousands. Unset or empty, the first
  step is 300k and the line is as above. A value matching
  `^[1-9][0-9]{0,5}$` makes the first step that many thousand, the steps
  after it stay 100k apart, and the line ends `; compact at <t>k)` in all
  three modes — `glab: context <n>k (last completed call; compact at <t>k)` —
  so the manager reads the step from the line. Any other value prints one
  stderr line, `glab context-size: GLAB_COMPACT_AT is not a whole number of
  thousands from 1 to 999999; using 300`, and the run goes on with the
  default, printing on stdout what it would print with the variable unset:
  a typo must not silence the number, and reading it after the transcript
  keeps each failure path at exactly one stderr line. The default is
  absolute, not a share of the window — the user's working limit, the same
  on every model — and there is no per-model table, because the hook is not
  told the window. Tested by T22 (the suffix in `agent` and `prompt`), T23
  (a moved step, the 100k steps after it and the suffix in `stop`) and T24
  (invalid values, an invalid value in `stop`, empty), with
  `unset GLAB_COMPACT_AT` before T1 so T1–T21 run on the default; `PASS
  24/24`, and `FAIL 3/24` against the `0.9.0` script. Why the user: a hook fires every time but
  cannot make the model act, so the one message that must not depend on the
  model goes to the person who can run `/compact` or `/clear`. `stop` is
  stateless (no file remembers a suggestion) and **never blocks or
  continues a turn**: `systemMessage` is its only key, no exit 2, no
  `decision`, nothing reads `stop_hook_active`. The contract of all three
  modes, like `memory-sync.sh`'s: exit 0 on every path; on stdout one JSON
  object (built by `jq -n --arg`) or nothing; every failure one line on
  stderr, `glab context-size: <reason>`; without `jq` it prints nothing and
  the manager's dispatch-count fallback covers it. It runs in every
  session of every repo where `glab` is enabled, manager or not, and writes
  no file, keeps no state and opens no network connection
  (`AGENTS.md` *Rules* hook contracts, *One fact*).
  *What I1 showed* (the user ran it in their terminal, Claude Code
  `2.1.304`, one host; `[flow-cheaper-rounds/plan.md F23]`): at
  `PostToolUse` on `Agent` the Agent-calling call is already in the
  transcript, so the `agent` line is current; `UserPromptSubmit` and
  `PostToolUse` lines reached the model; `Stop`'s `systemMessage` is shown
  to the user in the terminal and the turn ends there; but at `Stop` the
  turn's own last call is **not yet written** (the entry was there a second
  later). So `stop`'s base is the size at the real prompt before the last
  one, one turn further back than the turn's own prompt, and the line comes
  usually at the end of the turn after the crossing — once, or twice per
  crossing when the crossing call was already written at its own turn's
  `Stop`, never missed and never a third time (`D61`, `D62`). The manager's
  suggestion at a handoff line, read from the current `agent` line, may come
  before the user's line; the two use the same steps (`D47`). A first
  version compared the size with the turn's own prompt and never spoke
  (*Incidents*, IN1).
- **The agents** since `glab` 0.9.0, beside *Agents* above: `glab:reviewer`
  and `glab:analyzer` carry a `severity:` line in their report templates;
  `glab:analyzer` has a *Re-checks — round 2 and later* section (the
  previous findings and the delta, an empty delta reported as `BLOCK: target
  unresolved`) and reads `map-<area>.md` and treats a `<name>.r<n>.md` copy
  as an earlier version of a file the folder still holds, taking the record
  items from the current file; `glab:developer` has an *A fix round* section
  (read `result.md` and the tree first, add `## Fix round — <stage> round
  <n>`), reads the map files its plan cites and never edits a
  `map-<area>.md` or a round copy.
- **The agents since `glab` 0.10.0** (`2912002`): `glab:analyzer` and
  `glab:developer` read `plan/<slug>/evidence.md`, and `findings.md` in a
  folder from before 0.10.0 (`[flow-planner/plan.md D38]`); the analyzer's
  *Re-checks* pairs each `<name>.r<n>.md` the manager kept with its current
  file and, for a plan check, reports an amendment added beside what it
  changes — an amendment section, a "superseded" line, a round marker, an
  old step or decision left standing — as one finding on that id
  (`[flow-planner/plan.md D6]`); since `09d5664` that plan-check part is
  `glab:plan-analyzer`'s *Re-checks*, and `glab:analyzer`'s keeps the
  conformance parts (`[flow-models-per-role/plan.md S2]`, `S3`). `glab:developer` gains *Keep your context
  small*, unnumbered between Step 1 and Step 2, prose only
  (`[flow-planner/plan.md D10]`, `D11`): read the contract once and re-open
  only by `grep -n` and line range; gate and test output go to a log under
  the repo's or host's temp directory —
  `log=$(mktemp "${TMPDIR:?}/gate.XXXXXX"); { <the gate command>; } >"$log" 2>&1; rc=$?; tail -n 30 "$log"; echo "rc=$rc"`,
  the braces sending every command of a compound gate line to the log
  (added in review fix round 1, `[flow-planner/result.md R1]`) — and only its
  tail, its `rc` and its failure lines are read; no re-read after an edit
  (`git diff -- <file>` instead); Edit, not a whole-file Write; search
  before reading. Its reason: one developer in another project peaked past
  500k tokens in one round (`[flow-planner/evidence.md F4]`). It never
  edits `evidence.md` or `findings.md`.
- **`glab:plan-first` since `glab` 0.10.0** (`2912002`). *Size and shape*,
  after Step 3: `plan.md` and `evidence.md` at most **48 KB** each
  (`wc -c`) — since `0cbf5b0` `master.md`, `plan.md`, `index.md` and
  `evidence.md`, the manager's checklist item 6 checking the same four,
  which extends `[flow-planner/plan.md D2]` — because every later agent
  reads them again; a decision is one
  line, choice and reason in at most two sentences, evidence cited by id and
  never restated; a fact is written once; a plan that will not fit is split,
  and one that cannot be carries `- size: <n> KB — <why it is one plan>`
  under `## Decisions` for the manager to decide under Rule 3
  (`[flow-planner/plan.md D2]`–`D4`). The manager's acceptance checklist
  has a sixth item, *Within its size*: `wc -c` on each file against 49152
  bytes and `grep -c '^- size: '`, never reading them (Rule 2;
  `[flow-planner/plan.md D6]`). *Amending after a plan check* (Step 4) and
  Stage 1b: an amendment replaces the text it changes, in place, under the
  same id — no amendment section, "superseded" line or round marker; the
  `.r<n>` copies are the history; a line the manager added to overrule a
  decision stays as written (`[flow-planner/plan.md D5]`). Steps 5–7 and the
  three repo rules that bind only the implementation (service lifecycle,
  nested repositories, commits) moved byte for byte, numbers kept, to
  `plugins/glab/skills/plan-first/implement.md`, a sibling file with no
  frontmatter — not a skill, so `Skills (14)` holds; `SKILL.md` keeps Steps
  0–4, a pointer *Steps 5 to 7 — Implement, E2E tests, unit tests*, and "A
  planning agent stops at Step 4 and does not read it." The waiver
  paragraph says "Then implement, from `implement.md`" (review fix round 1,
  `[flow-planner/result.md R3]`), and since `0cbf5b0` goes on ": the
  waiver stands in for the verified, approved plan it asks for"; the
  pointer reads "Read it once the plan is verified and approved (Step 4),
  or once a waiver is written (*User Override*)", and `implement.md` l. 3
  "Start them only once the plan is verified and approved
  (`glab:plan-first` Step 4), or once `plan/{slug}/waived.md` records a
  waiver (*User Override* in `SKILL.md`), which stands in for both"
  (`[flow-master-plan/plan.md S9]`, `D47`). The manager's checklist has a
  seventh item since `0cbf5b0`, *A master*: `grep -c '^## \(Request\|Goals\|Out of scope\|Final check\|Record\)$' plan/{slug}/master.md`
  prints `5`, and with sub-plans `index.md` has one line per sub-plan
  folder. `/glab:develop`'s "glab:plan-first steps
  5 to 7" still resolves (`[flow-planner/plan.md D7]`, `D8`). Step 1
  writes `plan/{slug}/evidence.md`, "not `findings.md`: Claude Code refuses
  a subagent's Write of a file by that name".
- **The model rule** (`glab:manager` Rule 5, "each agent runs on its
  role's model; the user's words override it", since `glab` 0.12.0,
  `09d5664`; `[flow-models-per-role/plan.md D2]`, `D3`, `D9`–`D13`; the
  user's answer "Default", `[flow-models-per-role/questions.md Q1]`). Each
  agent's definition sets its model in its frontmatter `model`, an alias,
  never a full ID (`D3`): `glab:planner` `opus` (planning, sub-plan
  planning, amendments), `glab:plan-analyzer` `opus` (the plan check, the
  master check), `glab:analyzer` `sonnet` (the conformance check, the final
  check, the record check), `glab:developer` `sonnet` (develop, fix rounds,
  the record), `glab:reviewer` `sonnet` (review, the record's review),
  `glab:integrator` `sonnet`, `glab:committer` `haiku` — the table the user
  approved on 2026-10-20 ("good let's use your suggestions") for cost
  (`flow-models-per-role/master.md` *Request*: in one measured run
  developers were 49% of tokens, planners 21%, plan checks 11%, reviewers
  8%; "A cheaper model lowers the price per token, not the number of
  tokens"). The definitions ship with the plugin, so every installer runs
  on these models and pays their price; the reviewer has no `haiku`
  default, "it is the last gate" (review round 1,
  `[flow-models-per-role/result.md R2.7]`). **No instruction, no
  parameter**: the manager dispatches with no `model` and the definition's
  model runs; it never picks a cheaper or a dearer one, and no file
  switches it, `docs/constants.md` included; an agent with no definition —
  a mapping agent, a read-only question, any ad-hoc or fan-out agent not
  one of the seven — gets no parameter unless the user names a model for
  it, and Claude Code's own order picks (`D9`, `D19`). **The user's words
  override the role they name** — `sonnet`, `opus`, `haiku` or `fable`,
  for any role — passed as the Agent tool's `model` parameter on every
  dispatch of that role: each split slice, fix round, re-dispatch after
  `BLOCKED` or `PLAN WRONG`, analyze round and review round, through a
  `/glab:` command or directly; a name the parameter does not take is said
  and asked about; naming `fable` can spend money and is said once. The
  override is recorded as a `- model:` line quoting the user under
  `## Decisions` in `plan.md` (the example is now
  `- model: glab:reviewer opus, for this task — … "use opus for the reviewer"`,
  since the developer's default is already `sonnet`, R2.7); a `/glab:review`
  or `/glab:ship` with no plan, **and the Stage 8 record's agents**, keep it
  in the conversation only, and once it cannot be found the dispatch goes
  with no parameter and the handoff line names the definition's model
  (`D12`). Its duration is unchanged: "For this task" ends with that task's
  record (Stage 8), or with its push when it has no plan folder; "for the
  session" with the session. **The handoff line** names the model on every
  line of a stage that dispatches an agent —
  `slug · develop · model sonnet · round 1/2 · BUILT · effort <level> · context <n>k`
  — the definition's alias when the user named none, `model haiku (user)`
  when the override was passed (`D11`). **The documented order**
  (`[flow-models-per-role/plan.md E1]`, `E2`): the per-dispatch parameter,
  then the definition's frontmatter `model`, then
  `CLAUDE_CODE_SUBAGENT_MODEL`, then the main conversation's model, in that
  order from Claude Code v2.1.251; so `CLAUDE_CODE_SUBAGENT_MODEL` no longer
  reaches the seven agents, and only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`,
  from v2.1.257, overrides the definitions and the parameter alike — Rule 5
  and `README.md` say so, because an installer who set the variable to save
  money would otherwise lose that without a word (`D13`); a family alias
  runs the main conversation's exact model when it is of that family; the
  parameter holds on resume from v2.1.211; `model` is documented among the
  fields a plugin agent supports, and that a live dispatch honours it is
  not yet shown (I1, *Known limits*). **The dispatch-per-model table**
  applies to the model the agent runs on, its default included (`D10`,
  `[feature-model-switch/plan.md D20]`'s rule kept): rows `opus`, `fable`
  (nothing changes), "default — an agent with no definition, on Claude
  Code's own order" (nothing changes; R2.8), `sonnet` (the role's report
  template pasted in full), `haiku` (shorter, every instruction explicit,
  numbered reference steps, the template pasted); so a `glab:committer`
  dispatch is written for `haiku` and every Sonnet-default dispatch pastes
  the role's *Report* section. The report check is unchanged: every
  report is checked against the role's contract, the agent resumed once for
  missing fields (the one resume the manager allows since `glab` 0.9.0,
  *Every round is a new agent* above). **Without subagent dispatch** a
  stage session runs on the model the user starts it with, and the manager
  names the role's model or the recorded override when it hands off (review
  round 1, `[flow-models-per-role/result.md R1.4]`). Every role gets
  `effort` (Rule 0d: "The model is Rule 5's, the effort is this rule's.");
  no frontmatter has an `effort:` key, and a subagent on a model other than
  the main conversation's does not take the session's level unless `effort`
  is passed — one more reason it always is (`D14`,
  `[flow-models-per-role/plan.md E4]`). The pipeline does not bend: the
  manager still runs the gates, the reviewer still gets only the target,
  push still waits for the user, and a reviewer's `SHIP` on any model is a
  `SHIP`. History, until `glab` 0.12.0 (`09d5664`), as it stood
  (`[feature-model-switch/plan.md D2]`, `D8`, superseded): the user may name the model of the developer
  or the reviewer — `sonnet`, `opus`, `haiku` or `fable` — and nothing else
  changes it. The manager passes it as the Agent tool's per-dispatch `model`
  parameter on every dispatch of that role, records it as a `- model:` line
  quoting the user under `## Decisions` in `plan.md`, names it in every
  develop and review handoff line (`model default` when none), writes the
  dispatch for that model (a three-row table: `opus`/default/`fable`,
  `sonnet`, `haiku`; until `467b7c4` also a row for an external reviewer
  and one for an external developer), and checks every
  report against the role's contract, resuming the agent once for missing
  fields (the one resume the manager allows since `glab` 0.9.0, *Every
  round is a new agent* above). "For this task" ends with that task's record (Stage 8), or with its
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
  `glab:analyzer`, `glab:integrator`, `glab:committer`, and any other;
  `glab:planner` and `glab:plan-analyzer` named too since `09d5664` —
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
  `[subagent-effort/result.md finding-4]`, open); since `09d5664` they cite
  the rule instead — `/glab:plan` "dispatched as `glab:manager` Rules 0c,
  0d and 5 say", the other three "Rules 0d and 5"
  (`[flow-models-per-role/result.md R2.10]`) — and no agent definition
  has an `effort:` key (`[subagent-effort/plan.md D6]`,
  `[flow-models-per-role/plan.md D14]`). The session effort
  is a *One fact* entry of `AGENTS.md` (`docs/specs/marketplace.md`).
- **Plan files** (`glab:plan-first`): `plan/{slug}/` holds `evidence.md`
  (`findings.md` until `glab` 0.10.0, `2912002`: a subagent's Write of that
  name is refused, *Incidents*; every reader still accepts `findings.md` in
  an older folder, `[flow-planner/plan.md D38]`),
  `questions.md`, `plan.md`, the developer's `result.md` and
  `follow-ups.md`, `integration.md`, and `waived.md` when the user waives
  planning; since `glab` 0.9.0 also `map-<area>.md` from mapping agents and
  the round copies `<name>.r<n>.md` the manager keeps at Stage 1b (an
  earlier version of a file the folder still holds: a record takes its
  items from the current file); a waiver's folder is recorded like a plan's.
  Since `glab` 0.11.0 (`0cbf5b0`) also `master.md`, `master.sha256`, a
  version copy `master.v<n>.md` when the request changed after approval,
  and, when the work split, `index.md` and the sub-plan folders
  `<nn>-<name>/`, each a full plan folder (*The master plan and
  sub-plans*, below). The rule is
  "**Plan files are working files; the spec is what stays.**" Step 1 reads
  the spec of each area the change touches first — its decisions still
  bind, its known limits still hold, its open follow-ups may already
  describe the task. Step 3's `plan.md` includes `## Record` — since
  `0cbf5b0` `master.md` does, and `plan.md` only in a folder with no master
  (`[flow-master-plan/plan.md D39]`): the area spec
  or specs the change updates once it is pushed, any audit file under
  `plan/` it acts on, and what the entry will say; `/glab:plan` reports the
  spec it names. A follow-up stays in `follow-ups.md` until the record moves
  it into the area spec. Specs live in `docs/specs/`, one file per area,
  unless the repo's `AGENTS.md` names another place. A plan folder whose
  `plan.md` has no `## Record` was written before the repo followed the rule
  and is not recorded — since `0cbf5b0`, whose `master.md`, or `plan.md` in
  a folder with no master, has none. An audit file stays where `glab:audit` writes it;
  the plan that acts on it names it in `## Record`, and its open items reach
  the spec at that change's record (`glab:audit` *After Writing*, item 4).
- **Stage 8 — Record** (`glab:manager` *Stage 8 — Record*), after Stage 7
  has confirmed the push. `glab:developer` is dispatched for the record
  alone — the slug, the area specs the plan's `## Record` names (since
  `0cbf5b0` `master.md`'s, `plan.md`'s with no master; for a
  waiver, the ones the manager names), any audit file it names — and
  updates each spec from the folder's files, sub-plan folders included
  since `0cbf5b0`: how the area works now, the
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
- **The master plan and sub-plans** (since `glab` 0.11.0, `0cbf5b0`;
  `glab:plan-first` Step 3 *The master plan, and sub-plans when the work
  splits*, `glab:manager` *The master plan and sub-plans*;
  `[flow-master-plan/plan.md D23]`–`D30`). Every plan folder starts with
  `master.md` — what the user asked for, constant once accepted; the plans
  say how. Its sections: `## Request` (the user's words, verbatim and
  dated, never paraphrased), `## Goals` (`G1`, `G2`, …, one line each,
  citing those words), `## Out of scope`, `## Final check`, `## Record`
  and `## Approval`, which only the manager writes. Normal tier writes
  `master.md` and one page, `plan.md`; full tier `master.md`,
  `evidence.md`, `plan.md` and `questions.md` if one was raised. **One plan
  by default**; the work is **split** only into parts with their own goals
  and milestone test, built, reviewed and committed one after another, and
  never across files the repo changes in one commit. Each part is a
  sub-plan folder `plan/{slug}/<nn>-<name>/` — `<nn>` two digits in build
  order, never reused — that is a plan folder under every rule; the split
  is `index.md`, one line per sub-plan (`<nn>-<name> · goals G1, G3 ·
  depends … | none · tier <normal | full>`) and a `## Decisions` section,
  amended like a plan (`index.r<n>.md`). **The master is constant:** after
  its `## Approval` line the manager runs
  `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256` from the
  repo root and never edits it again; every analyzer and `/glab:develop`
  check it with `sha256sum -c`, anything but `OK` an analyzer finding rated
  `high` (`D25`). No round amends an approved master: a changed request is
  a new `master.md`, the old kept as `master.v<n>.md` — a version copy,
  never `.r<n>` — whose approval and hash do not carry over; the manager
  removes `master.sha256` when it dispatches that planner, the new master
  gets its own Stage 1b, approval and hash, and every sub-plan not yet
  committed its Stage 1b again (review fix round 1,
  `[flow-master-plan/result.md R1]`). **Planning in cycles:** the first
  planning agent writes `master.md` and, when the work splits, `index.md`
  and no sub-plan; each sub-plan is planned by its own agent once what it
  depends on is committed, from `master.md`, its own `index.md` line and
  the slug-level `map-<area>.md` files its dispatch names, never from
  another sub-plan's folder (`D27`, `D28`). **Each sub-plan runs its own
  cycle** — Stages 1, 1b, 2, 3, 4, 5 and 6, Stage 3 at every tier — in
  `<nn>` order, development, review and commit one at a time, so each
  review sees only its own change; commands take `{slug}/<nn>-<name>` as
  the slug (`/glab:analyze {slug}/02-hooks`), the master a level up. **One
  commit per sub-plan** — its own folder, the first also `master.md`,
  `master.sha256`, `index.md` and the map files — then one final check,
  one push and one record per slug (`D30`); a single plan commits once.
  The developer reads `master.md` as context, not scope — a step that,
  built as written, cannot serve its goal is `PLAN WRONG` — and never edits
  `master.md`, `master.sha256`, `index.md` or a version copy.
- **The intent check** (since `0cbf5b0`; `glab:analyzer` *The intent
  question*, *The plan check*, *The final check*;
  `[flow-master-plan/plan.md D32]`–`D36`). The analyzer — never the
  reviewer, which stays blind to the plan, `master.md` and `index.md` —
  asks, on top of its check, whether the work serves what the user asked
  for, wherever there is a master: **in a plan check** (Stage 1b), of the
  master whether every request reaches a goal or `## Out of scope`, each
  goal says no more and no less than its words, and every goal reaches a
  line of `index.md` (the coverage question, the *master check* of a split
  folder before any sub-plan is planned); of a plan whether its steps
  deliver its goals as `## Request` words them — for a single plan one
  analyzer asks both of `master.md` and `plan.md` together (`D42`); **in a
  conformance check** (Stage 3), whether the build serves the goals beyond
  matching the steps; **in the final check**, for each goal, delivered and
  where. Each goal is reported as a step, `goal G<n>: <served | partial |
  missing | reshaped>`, quoting the request. A folder with no master — from
  before 0.11.0 — gets no intent question, and the analyzer says so. An
  intent gap after the build is a defect of the plan: a planning agent's
  amendment, then Stage 2, never a developer told to build past its plan
  (`D34`). The analyzer's own file now holds the plan check and its
  verdicts `BUILDABLE` and `NOT BUILDABLE`, beside `CONFORMS`,
  `DIVERGES: <n> steps` and `BLOCK: target unresolved` — the five one fact
  in `AGENTS.md` (`D35`); a master check or a final check has no `plan.md`,
  so its contract is `master.md` and `index.md`, and `BLOCK` only when
  there is no `master.md` either. For a sub-plan, an untracked file in
  another sub-plan's folder is not its implementation. Its description
  names the plan check, the conformance check and the final check
  (`[flow-master-plan/result.md R5]`). `/glab:analyze` asks "did we build
  the thing the plan said, and does it serve what the user asked for?" and
  routes `BUILDABLE` to the approval and `/glab:develop` (or, after a
  master check, the sub-plans' planning), `NOT BUILDABLE` to a new planning
  agent, and `CONFORMS` after the final check to `/glab:push`. Until
  `09d5664` one analyzer agent did every kind of check (`D36`). **Since
  `glab` 0.12.0** the analyzer is two kinds (`[flow-models-per-role/plan.md D6]`,
  `D7`): `glab:plan-analyzer` (`opus`) holds the plan check, the master
  check, the intent question's plan-check part and the verdicts
  `BUILDABLE` and `NOT BUILDABLE`; `glab:analyzer` (`sonnet`) keeps its
  name — so the Stage 3, 6b and 8 citations and `/glab:analyze`'s name
  stay — with the conformance, final and record checks, the conformance and
  final-check parts of the intent question and `CONFORMS` and
  `DIVERGES: <n> steps`; both end `BLOCK: target unresolved` on a check that
  is not theirs. Two files, not one with two modes, because a frontmatter
  default is per file and a per-dispatch model would put the default back
  in the manager's memory (`[flow-models-per-role/plan.md B2]`, rejected), and each file
  loads less: `analyzer.md` was 11269 bytes, its plan-check text read by
  every conformance, final and record dispatch (`[flow-models-per-role/plan.md E10]`).
  Stage 1b's citations moved to `glab:plan-analyzer` (Stage 1b cites
  `glab:plan-analyzer` *The intent question*); the intent check and the
  analyzers' verdict lines are one fact in both files (`AGENTS.md` *One
  fact*, `docs/specs/marketplace.md`). In `analyzer.md` "except in a
  coverage or final check", "except in a master check or a final check"
  and "in a master check or a final check" became "in a final check" (`S3`).
- **Stage 6b — Final check** (since `0cbf5b0`; `glab:manager`
  *Stage 6b — Final check*; `[flow-master-plan/plan.md D33]`). After the
  slug's last commit, before the push, at every tier: `/glab:analyze {slug}`
  as the final check. The analyzer reads `master.md`, `index.md` (the plan,
  with no index) and the range from the `## Approval` base to `HEAD`, does
  not walk the sub-plans' steps, and answers the intent question for every
  goal; the manager runs the gates on that tree. Skipped only for a single
  plan at full tier, whose Stage 3, delta rounds included, asked it.
  `CONFORMS` → Stage 7; `DIVERGES` → the gaps go to a new planning agent —
  a new sub-plan with the next `<nn>`, or an amendment of `plan.md` without
  sub-plans — which runs its cycle to its commit; round 2 gets round 1's
  findings and the two commit ids; at most 2 rounds, a third under the
  round-3 rule, then the user. Nothing is pushed before it, and Stage 7
  shows the `## Decisions` lines of each plan the push carries.
- **Approval after Stage 1b** (since `0cbf5b0`; `glab:manager` Stage 1;
  `[flow-master-plan/plan.md D26]`, `D46`). The user approves a checked
  plan: after Stage 1b has passed — the master check, when the work split —
  explicitly at full tier and whenever the work split; at normal tier with
  no sub-plans the manager reports the tier and the decisions and goes on.
  The manager then writes `master.md`'s last section, one line —
  `- approved by the user, <date>, in chat | in plan mode: "<their words>"; base <git rev-parse --short HEAD>`,
  or `- accepted at normal tier, reported to the user, <date>; base <sha>`
  — and hashes it; the base is where the final check's range starts. At
  full tier the user also approves `plan.md` explicitly — a single plan's
  together with the master, each full-tier sub-plan's after its own Stage
  1b — and that `plan.md` ends with its own `## Approval` line in the same
  form; at normal tier the master's approval covers the sub-plans (`D46`,
  extended to a single full-tier plan by review fix round 1,
  `[flow-master-plan/result.md R2]`). `/glab:develop`'s *Approval*
  precondition: with a `master.md`, its `## Approval` line, `sha256sum -c`
  printing `OK`, and at full tier the `plan.md`'s own line — or stop; with
  none, a plan from before 0.11.0, full tier only, as before. `/glab:plan`
  reports the goals, and the sub-plans when the work split.
- **Approval in Claude Code's plan mode** (since `0cbf5b0`; `glab:manager`
  *Approval in Claude Code's plan mode — only when the user asks for it*;
  `[flow-master-plan/plan.md D37]`, the user's: the flow should "work with
  claude app|cli builtin flow"). Only when the user asked for it, in the
  session or a standing instruction; otherwise the approval is asked in the
  chat. Only the main session can (no subagent has the plan-mode tools,
  UNVERIFIED: L7), after Stage 1b with no agent running (L5); the manager
  first tells the user in one line that the dialog sets the session's
  permission mode from then on (L4) and that changes go through "No, keep
  planning", not Ctrl+G (L3); it calls EnterPlanMode, then ExitPlanMode
  with `master.md` as the plan (L1, L2). It writes no plan file outside the
  repo — `~/.claude/plans` by default — and asks the user to leave plan
  mode and approve in the chat instead; inside the repo, where the user's
  own `plansDirectory` put it, it writes `master.md`'s text there byte for
  byte and never commits it; it never changes `plansDirectory`. Approved →
  the `## Approval` line says `in plan mode`; "No, keep planning" → the
  user leaves plan mode before the amendment, and their words go into
  `## Request`. Every plan-mode claim is read from Claude Code's
  documentation and marked UNVERIFIED in the payload and `README.md`, each
  naming the live test L1–L7 that settles it (*Known limits*, below); a
  step whose claim fails falls back to approval in the chat.

## Decisions that still bind

- [feature-model-switch/plan.md D1] Manual only: the model changes only when the user names it, for one dispatch, a task or the session; never on the manager's own initiative, never because of quota, never from a file. **Amended by `[flow-models-per-role/plan.md D2]` and `D9` since `glab` 0.12.0 (`09d5664`):** each role now has a default, its definition's frontmatter `model`; this decision still governs every change from that default.
- [feature-model-switch/plan.md D2] **Superseded by `[flow-models-per-role/plan.md D9]` since `glab` 0.12.0 (`09d5664`).** It was: developer and reviewer only; analyzer, integrator, committer and planning agents get no `model` parameter. The user's words now override any role, and an agent with no definition gets no parameter unless the user names one.
- [feature-model-switch/plan.md D3] The user does not run commands: the user tells the manager, who carries the choice into every dispatch of the role until the user changes or clears it.
- [feature-model-switch/plan.md D4] The handoff line names the model, so the user sees what was asked for.
- [feature-model-switch/plan.md D5] The pipeline does not bend to the model: gates, the reviewer's target-only brief, the push go-ahead, the tier and the round caps stay.
- [feature-model-switch/plan.md D6] The mechanism is the Agent tool's per-invocation `model` parameter, passed on each dispatch; it tops the documented order and holds across a resume.
- [feature-model-switch/plan.md D7] One home for the rule, `glab:manager` Rule 5; the stages and commands point to it, the commands restating only the minimum.
- [feature-model-switch/plan.md D8] **Superseded by `[flow-models-per-role/plan.md D2]` since `glab` 0.12.0 (`09d5664`).** It was: no change to the agent files: no `model` in their frontmatter, so the documented default applies without an instruction. Each of the seven definitions now sets its role's `model`.
- [feature-model-switch/plan.md D9] The choice is recorded as a `- model:` line under `## Decisions` in the task's `plan.md`; a review or ship with no plan keeps it in conversation only, and a lost one falls back to the default.
- [feature-model-switch/plan.md D10] An unspecified duration means the task in progress (the session when there is no task): a lost choice falls back to the default, never to a cheaper model.
- [feature-model-switch/plan.md D11] Develop and review handoff lines always name the model, `model default` included. **Amended by `[flow-models-per-role/plan.md D11]` since `glab` 0.12.0 (`09d5664`):** every line of a stage that dispatches an agent names it, the definition's alias when none was passed and `model <alias> (user)` for the user's override; `model default` is gone.
- [feature-model-switch/plan.md D12] Rule 5 names its limits: the line states what was passed; a forced subagent model, an allowlist or a mod can run something else, and `/tasks` shows what runs.
- [feature-model-switch/plan.md D13] Without subagent dispatch the stage session runs on the model the user starts it with, and the manager names the recorded model in the handoff.
- [feature-model-switch/plan.md D14] `AGENTS.md` *One fact* carries the manual model rule as a known case. **Amended since `glab` 0.12.0 (`09d5664`; `[flow-models-per-role/plan.md S8]`):** the entry is "the model per role" (`docs/specs/marketplace.md`).
- [feature-model-switch/plan.md D17] Rule 5 states the version floors and that a plugin agent honouring the parameter is inferred, not shown.
- [feature-model-switch/plan.md D18] Naming `fable` is the user's money choice: said once, then used; not a Rule 3 question.
- [feature-model-switch/plan.md D20] The dispatch fits the model: Rule 5's table says what changes in the message per model; the agent files do not change. **Extended by `[flow-models-per-role/plan.md D10]` since `glab` 0.12.0 (`09d5664`):** the table applies to the model the agent runs on, its definition's default included.
- [feature-model-switch/plan.md D21] The report template is the agent's own *Report* section, copied as written; reading it is Rule 2's one exception.
- [feature-model-switch/plan.md D22] A malformed report is not evidence: check the required fields and the verdict line's form, correct once on the same model, then stop and tell the user; not a review round. (The review fix round made the correction a resume of the same agent.)
- [feature-model-switch/plan.md spent] D15, D16, D19 — scoping of that change: the `0.3.0` bump, leaving bootstrap and the hook untouched, and its Stage 1b amendment.
- [feature-model-switch/result.md decisions] The single normal-tier review said to cut Rule 5's per-model table and report check; the manager fixed the findings once instead, because the user had asked for per-model dispatch (Stage 5's normal-tier rule) — that is why the table and the check are in Rule 5.
- [sync-local-edits/result-followups.md D1] Sessions settle a seam through the channel `docs/constants.md` names, and the user relays when it names none; a relayed decision binds only when it arrived that way and is recorded as a `## Decisions` line naming the session.
- [sync-local-edits/result-followups.md D2] A `plan.md` with no tier line is full tier, stated once in *Pick the tier*.
- [sync-local-edits/result-followups.md D3] Rule 3 keeps `glab:security`'s stop list and its *Destructive operations are proven* rule, and states confirmation before every destructive action and every push as the manager's own rule (as corrected after review, #3).
- [sync-local-edits/result-followups.md D4] Bootstrap stays on the review-round-cap list, and the four ask-conditions are a known *One fact* case naming every file that states them.
- [sync-local-edits/result-followups.md D5] `/glab:integrate` runs after `/glab:analyze` at full tier and after `/glab:develop` at normal; normal tier runs the milestone test, full tier the whole suite. **Amended by `[flow-master-plan/plan.md D31]` since `glab` 0.11.0 (`0cbf5b0`), for sub-plans only:** a sub-plan runs Stage 3 at every tier, so `/glab:integrate` follows `/glab:analyze` there; a normal-tier plan with no sub-plans keeps this decision (`commands/develop.md`: "`/glab:analyze` at full tier and for every sub-plan, `/glab:integrate` at normal with no sub-plans").
- [sync-local-edits/result-followups.md D6] After an amendment, the develop handoff re-runs the plan's next stage.
- [sync-local-edits/result-followups.md D8] `/glab:analyze` says "If the plan is amended".
- [sync-local-edits/result-followups.md D9] The planner decides each choice and records it with its reason; the manager reviews those lines and may overrule one, recording the overrule as a new line.
- [sync-local-edits/result-followups.md D10] Only its `glab:plan-first` half stands, reworded by `feature-docs-specs`: no `glab` step removes a plan folder, and whether a recorded one is removed is the repo's own `AGENTS.md` decision (it said: a repo that keeps specs but has no rule for removing plan folders keeps its plans). Its manager half — the Spec row's stage, owner and place — was removed by the review's scope cut; Stage 8 now gives the record a stage, owner and place (`[sync-local-edits/follow-ups.md 10]`, closed).
- [sync-local-edits/result-followups.md D11] **Superseded by `[flow-cheaper-rounds/plan.md D2]` since `glab` 0.9.0 (`2a1e919`).** It was: the 1b row's "Leaves on" reads "`BUILDABLE`, or one amendment at normal tier". It now reads "`BUILDABLE`, or at normal tier the amendment after round 2" (`glab:manager` *The pipeline*).
- [sync-local-edits/result-followups.md D12] Bootstrap points to *Pick the tier* for the full-tier triggers and names the four as Rule 3's ask-conditions; `review.md` says Stage 5 sends findings back; the hook text says "at full tier".
- [sync-local-edits/result-followups.md spent] D7 — the waiver routing it decided was removed by the review's scope cut (`[sync-local-edits/follow-ups.md 7]`, reopened).
- [sync-local-edits/result.md spent] M1, M2, M3, P1 — the port's merge choices (the reviewer's round-cap wording, the develop `questions.md` bullet, `ship.md` already matching, where bootstrap's new paragraph goes), applied in `5f69d65`; nothing in them governs later work.
- [sync-local-edits/result.md decisions] The coordinator, as manager, resolved the contradictions the port reported in favour of the user's newer text (tiers, Rule 3), because the 2026-10-08 edits were the user's latest statement of intent; the older "questions" wording and the repo's own `plan/` rule stayed. The manager's decision, not the user's approval.
- [bug-reviewer-findings/questions.md Q3] **Superseded by `[flow-cheaper-rounds/plan.md D2]` since `glab` 0.9.0 (`2a1e919`).** It was: the review round cap is 3 everywhere, `/glab:ship` stating the same number so the standalone path is capped too (later "at most three — one at normal tier"). What survives is that `/glab:ship` states the same cap as the manager, so the standalone path is capped too — now 2, and a third only on a `critical` or `high` finding.
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
- [feature-docs-specs/plan.md D5] Installer wording: specs in `docs/specs/` unless the repo's `AGENTS.md` names another place, and a folder from before the rule (a `plan.md` with no `## Record`) is not recorded; its removal clauses moved to the repo's own `AGENTS.md` (`[feature-docs-specs/plan.md U10]`), where no untracked file under `plan/` is removed. **Amended by `[flow-master-plan/plan.md D39]` since `glab` 0.11.0 (`0cbf5b0`):** `## Record` is in `master.md`, so a pre-rule folder is one whose `master.md` — or `plan.md`, in a folder with no master — has no `## Record`.
- [feature-docs-specs/plan.md D8] Payload text cites the spec, named with its repository, never a `plan/` path or a commit of this repo: an installer can follow neither.
- [feature-docs-specs/plan.md D10] A spec is not one of the *One fact* files: it states a fact as of its last record and names the file that owns it; `AGENTS.md`'s `plan/` rule says so.
- [feature-docs-specs/plan.md D11] Closed items migrate too, under *Closed follow-ups* with their evidence (`AGENTS.md`: every follow-up, open or closed).
- [feature-docs-specs/plan.md D16] An audit file is a working file too: its still-open items go into the area spec when the change that acts on it is recorded — its removal by that record commit was cut (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md D22] A model choice "for this task" ends with the task's record, not its push; a task with no plan folder ends with its push. Only `manager/SKILL.md` Rule 5 states the duration.
- [feature-docs-specs/plan.md D26] An audit file stays where `glab:audit` puts it, directly under `plan/`; the plan's `## Record` names it and Stage 8 hands it to the developer and the analyzer as a source — its removal by the committer was cut (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md D27] The record check is `glab:analyzer`, at every tier, with the folder's tracked files as its contract (the payload reads every file: `[feature-docs-specs/follow-ups.md 2]`); one fix round, then the analyzer again; still `DIVERGES` → the user. The full-tier reviewer pass stays, on the spec diff alone.
- [feature-docs-specs/plan.md D28] A pre-rule folder is one whose `plan.md` has no `## Record`; a waiver's folder has no `plan.md` and is recorded. **Amended by `[flow-master-plan/plan.md D39]` since `glab` 0.11.0 (`0cbf5b0`):** the `## Record` looked for is `master.md`'s, `plan.md`'s only in a folder with no master.
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
- [flow-cheaper-rounds/plan.md D1] Tier normal for the change — payload text, the `glab` manifest version, `AGENTS.md`, `README.md`, and one read-only hook script with its test; no full-tier trigger. The `severity:` line is a contract between agents that nothing parses (`F13`). Scoping of that change; it governs no later work. Re-checked by D36.
- [flow-cheaper-rounds/plan.md D2] The round caps — **the user's decision**, relayed by the manager: "set 2 and only one more if something critical is behind". Stage 1b, Stage 3 and Stage 5 each run at most 2 rounds at every tier where the stage runs; a third only when round 2 returned a `critical` or `high` finding, recorded first as a `- round 3: <stage> — <severity> <finding>` line under `## Decisions`; nothing past round 3. It supersedes `[bug-reviewer-findings/questions.md Q3]`, `[feature-plugin-marketplace/questions.md S3]` (`docs/specs/marketplace.md`) and `[sync-local-edits/result-followups.md D11]`. **Extended by `[flow-master-plan/plan.md D29]` since `glab` 0.11.0 (`0cbf5b0`):** the final check (Stage 6b) has the same cap, every cap counts per sub-plan where there are sub-plans, and the master and final checks write their round-3 line in `index.md` (`plan.md` with no sub-plans).
- [flow-cheaper-rounds/plan.md D3] "Critical **or high**", not "critical" alone — **the manager's choice, not the user's**: the real case that needed a third round was rated high. The user may overrule it; then only the word list in D2's files changes.
- [flow-cheaper-rounds/plan.md D4] The severity is given by the agent that reports the finding (`glab:reviewer`, `glab:analyzer`), as a `severity:` line on `glab:audit`'s four *Severity Levels*, and never re-ranked by the manager.
- [flow-cheaper-rounds/plan.md D5] Reviewer round 2 is the last round unless it reports a `critical` or `high` finding; then it answers `BLOCK: <n> issues` and round 3 may run, which is the last with no exception. The verdict strings did not change.
- [flow-cheaper-rounds/plan.md D6] What happens when a stage ends its last round without passing is unchanged for that stage and tier (1b full → the user; 1b normal → one more amendment, `PLAN WRONG` the backstop; after round 3 → the user; Stage 3 → the user with three resolutions; Stage 5 → the last-round answer to the user); only the round counts changed.
- [flow-cheaper-rounds/plan.md D7] Every round is a new agent — a plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a Stage 8 record fix; Rule 5's report check (missing fields only) is the one resume (`[feature-model-switch/plan.md D22]` binds). It sits in Rule 2 because its reason is cost.
- [flow-cheaper-rounds/plan.md D8] A round's findings travel in the next agent's dispatch, copied as the agent returned them — the one input not on disk; the manager writes no findings file (Rule 1) and the analyzer and reviewer are read-only.
- [flow-cheaper-rounds/plan.md D9] A fix-round developer adds `## Fix round — <stage> round <n>` to `result.md` and does not overwrite it; the overwrite rule stays for a re-dispatch of the same steps.
- [flow-cheaper-rounds/plan.md D10] The Stage 1b delta is a copy `plan.r<n>.md` (and `findings.r<n>.md`) made before the amendment is dispatched, not git: the plan folder is untracked while it is planned. The copies stay and are committed with the folder. Amended by D49: the manager tests the delta with `cmp -s`, only the analyzer runs `diff -u`. **Amended by `[flow-planner/plan.md D38]` since `glab` 0.10.0 (`2912002`), by the file name only:** the copy is `evidence.r<n>.md` of `evidence.md`, and `findings.r<n>.md` only in a folder from before 0.10.0. **Extended since `glab` 0.11.0 (`0cbf5b0`; `[flow-master-plan/evidence.md F11]`, `[flow-master-plan/result.md R1]`):** also `master.r<n>.md` before the master's approval and `index.r<n>.md`, per sub-plan folder for a sub-plan's files; after approval only a version copy `master.v<n>.md`.
- [flow-cheaper-rounds/plan.md D11] The Stage 3 delta is a tree object snapshotted before each analyze round through a temporary index; round `<n+1>` gets both tree ids. Amended by D50: the index is seeded with `git read-tree HEAD` first. A path the fix round names that the delta does not show is checked whole; a lost tree id means that round runs whole.
- [flow-cheaper-rounds/plan.md D12] An empty delta is a stop, not a pass, because `diff` and `git diff --quiet` exit 0 when nothing changed; an analyzer handed an empty delta reports `BLOCK: target unresolved`. For the plan the manager's check is `cmp -s` (D49).
- [flow-cheaper-rounds/plan.md D13] **Superseded by `D51` in Stage 1b round 1.** It was: review rounds are not changed, on the assumption that the same reviewer asks what changed; D51 gave a later round a new reviewer and the range of the fix.
- [flow-cheaper-rounds/plan.md D14] The planner's full call-site audit covers methods the plan **changes**; for a method it only **calls**, the precondition the new call site must meet and how the plan meets it; a file it only depends on is listed by path and not read in full. Consistent with `glab:security` Rule 7.
- [flow-cheaper-rounds/plan.md D15] Mapping files are `plan/{slug}/map-<area>.md`, not `findings-<area>.md`, because the Write tool refused `findings-probe.md` and `findings.md` for a subagent and accepted `map-probe.md` (`F9`; *Incidents*).
- [flow-cheaper-rounds/plan.md D16] Mapping is the manager's call per task; with mapping agents the planner starts from their files and reads code only for the gaps it names, without them it explores itself, never both over one area; the analyzer reads the map files with the plan and the developer the ones the plan cites.
- [flow-cheaper-rounds/plan.md D17] **Superseded by `D29` in round 2.** It was: the manager measures its context with one inline command in `glab:manager`, not a script. Round 1's command was never shipped; the manager now runs no command for its context and reads the hook's line.
- [flow-cheaper-rounds/plan.md D18] **Superseded by `D30` in round 2.** It was: the inline command finds the transcript by `CLAUDE_CODE_SESSION_ID` under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/*/`. The hook is handed `transcript_path`. What it kept: one number and nothing else from the transcript, never `0`, `0k` or `null`.
- [flow-cheaper-rounds/plan.md D19] The thresholds: inside a task suggest `/compact` at 300k and at each further 100k; at a task boundary suggest `/clear` whatever the size. 300k is where a resumed agent's round already cost several times a fresh one's (`F1`). Its steps became fixed ones by D47.
- [flow-cheaper-rounds/plan.md D20] The fallback when there is no measurement: say so once, then suggest `/compact` after every 15 dispatches since the session started or was last compacted and after any stage that took more than one round. 15 is inferred from the stage list (about 8–12 dispatches per normal-tier task), not measured. Its trigger was changed by D38.
- [flow-cheaper-rounds/plan.md D21] The handoff line gains `· context <n>k` at its end, copied from the most recent `glab: context <n>k` line, or `· dispatches <d>` under the fallback; the manager names it "the last completed call's context" and never claims more precision, and never runs `/clear` or `/compact`.
- [flow-cheaper-rounds/plan.md D22] The handoff file is the one `glab:bootstrap` step 5 reads, `plan/SESSION-HANDOFF.md` unless the repo keeps it elsewhere; no `glab` step commits it. `glab:bootstrap` and `manager-bootstrap.sh` did not change for the context items: the `SessionStart` text carries no handoff, compaction or context text, and the new hook is a separate script.
- [flow-cheaper-rounds/plan.md D23] Rule 5 carries the user's model into each fix round too, because a new agent no longer inherits it from a resume (Rule 5's carry bullet, `commands/develop.md`).
- [flow-cheaper-rounds/plan.md D24] The handoff line's `max` is the stage's cap, `2` or `3` once the round-3 line is written; a develop line counts its fix rounds against the cap of the stage whose findings it fixes; Rule 5's example reads `round 1/2`.
- [flow-cheaper-rounds/plan.md D25] `AGENTS.md` *One fact*: the review-round-cap entry became "the round caps" (all three stages, five files); new entries for the severity levels, every round a new agent, the mapping and round-copy file names, the handoff file, and the context hook (`docs/specs/marketplace.md`). It closed `[sync-local-edits/follow-ups.md 18]`.
- [flow-cheaper-rounds/plan.md D26] `glab` `0.8.0` → `0.9.0`: the change alters the pipeline's contract and adds a feature, and features have raised the minor before 1.0; nothing removed, so no `!`. `memory-sync` untouched, `0.1.0`.
- [flow-cheaper-rounds/plan.md D27] One commit for all seven items with the plan folder, because the *One fact* rule wants each fact's files together and the hook events are one fact across `hooks/hooks.json`, `README.md` and `AGENTS.md`; the manager may split it. Done as one commit, `2a1e919`. A slug with sub-plans commits once per sub-plan since `glab` 0.11.0 (`[flow-master-plan/plan.md D30]`); this decision bound its own change only.
- [flow-cheaper-rounds/plan.md D28] Out of scope, recorded as follow-ups: a dedicated `glab:planner` agent (FU1), splitting the implementation steps out of `glab:plan-first` (FU2), the user-level copies under `~/.claude` (FU3), the "cleanup glob deleted a reviewer report" incident (FU4), and the hooks the user did not choose (FU16). FU1, the `glab:planner` agent, was built by `flow-models-per-role` (`09d5664`, closed below).
- [flow-cheaper-rounds/plan.md D29] The context hook — **the user's decision**, as amended during round 2: "We need a clear rule stating that the agent must check token usage, and we need a definitive hook that triggers whenever an agent finishes its turn or after I send a message. We have to choose an approach that is impossible to bypass." (Its first form, `PostToolUse` on `Agent` alone, was superseded.) Three hook events — `UserPromptSubmit`, `PostToolUse` with matcher `Agent`, `Stop` — all running one script, `plugins/glab/scripts/context-size.sh`, chosen by a mode argument. Not `PostToolBatch`; not `SubagentStop`, whose `additionalContext` goes to the subagent, not the parent. Supersedes D17.
- [flow-cheaper-rounds/plan.md D30] The script takes `transcript_path` from the hook input on stdin and nothing from the environment. Supersedes D18; `[flow-cheaper-rounds/plan.md FU9]`'s question became moot.
- [flow-cheaper-rounds/plan.md D31] The measure is the manager's: the last transcript entry that is an assistant entry, not a sidechain, whose usage sums to more than 0, rounded up to thousands. The figure is the last *completed* call's, and every line says so. After I1: current at `PostToolUse` on `Agent`, lagging at `Stop` (D61–D62).
- [flow-cheaper-rounds/plan.md D32] Bounded read: the last 8 MiB of the transcript through `tail -c`, folded by one `jq` program one line at a time, a partial first line and a truncated last line dropped silently. Why 8 MiB: transcripts reach 28 MB with lines of several MB. Known limit: an assistant entry longer than the window is not seen (FU14).
- [flow-cheaper-rounds/plan.md D33] Modes `prompt` and `agent` emit on every event with no threshold, about ten tokens; a threshold there would need state and would hide the number the handoff line needs. The text says "context", not "manager context", because the hook runs in every session.
- [flow-cheaper-rounds/plan.md D34] The contract of all three modes, like `memory-sync.sh`'s: exit 0 on every path; on stdout exactly one JSON object or nothing; every failure one line on stderr, `glab context-size: <reason>`; JSON built by `jq -n --arg`; an unknown or missing mode is a failure like any other; without `jq` it prints nothing. Hook `timeout` 5 s on each of the three entries.
- [flow-cheaper-rounds/plan.md D35] The hook runs in every session of every repo where `glab` is enabled, and that is harmless: one line of about ten tokens per user message and per Agent call, a user line from `stop` only at a crossing, read-only and bounded, no file, no state, no network, only an integer and fixed words. Amended after I1 by D61: `stop` speaks usually at the end of the turn after the crossing, once, at most twice per crossing, and at every turn end past 300k when the window holds fewer than two real prompts.
- [flow-cheaper-rounds/plan.md D36] The tier is still normal: the script reads a file that can hold secrets but passes on nothing except an integer it computed (test T2 asserts no fixture byte reaches stdout or stderr in any case); the hook JSON is Claude Code's format, consumed, not defined here. Only the user lowers a tier.
- [flow-cheaper-rounds/plan.md D37] A background Agent call fires `PostToolUse` at launch (`tool_response.status` `async_launched`); the script does not read `tool_response` and emits the same line, the launch-time figure.
- [flow-cheaper-rounds/plan.md D38] The fallback trigger (amends D20): **no `glab: context` line anywhere in the session**. When `prompt` lines come but `agent` lines do not — a CLI older than 2.1.63 whose tool is `Task`, which the matcher `Agent` is not shown to match — the handoff line takes the number from the most recent line of either kind; the dispatch count is not used.
- [flow-cheaper-rounds/plan.md D39] Test `tests/context-size.test.sh <path to context-size.sh>` on the pattern of `tests/memory-sync.test.sh`: one work directory from `mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX"` removed by an `EXIT` trap, fixture transcripts written by the test, no background process, one `ok`/`FAIL` line per case; a missing `jq` is faked by a `PATH` that lacks it, not by a stub.
- [flow-cheaper-rounds/plan.md D40] `AGENTS.md` changes: both new files join the shell gates; the hook-contract rule names `context-size.sh` with its modes and its stdout rule; *One fact* gains the context-hook entry (the line text, the `Stop` message, the steps 300k and every 100k, the three modes and events); the `glab` green line becomes `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`.
- [flow-cheaper-rounds/plan.md D41] Integration I1 needs the user's OK, because it calls a model and a throwaway `CLAUDE_CONFIG_DIR` is not logged in; the user runs the command in their own terminal, with `--plugin-dir ./plugins/glab`, never `--no-session-persistence`. Amended by D64: "so no `memory-sync` hook runs" is not borne out in the user's own config.
- [flow-cheaper-rounds/plan.md D42] Version `0.9.0` kept (D26).
- [flow-cheaper-rounds/plan.md D43] Matcher `Agent` alone, not `Agent|Task`: the user named `Agent`, and how the CLI reads `|` for an older tool name is not shown (FU11).
- [flow-cheaper-rounds/plan.md D44] The script reads no field of `tool_input`, `tool_response` or `prompt`; they pass through the hook's stdin and are never printed, logged or stored.
- [flow-cheaper-rounds/plan.md D45] `stop` speaks to the **user**, not the model, with `systemMessage`; stateless; a step is `-1` below 300k, else `floor((x - 300000) / 100000)`; it speaks when the step of the latest written call is above the step at an earlier prompt. Amended after I1 by D61–D62: that earlier prompt is the real prompt before the last one. A real prompt is a user entry that is not a sidechain, not `isMeta` and not a `tool_result`. I1 proved that `Stop` shows `systemMessage` to the user in the terminal and the turn ends there. Whether the model also sees the `Stop` text stays UNVERIFIED. **Amended by `[flow-planner/plan.md D12]` since `glab` 0.10.0 (`2912002`), by the variable only:** the step is counted from the first step — 300k, or `GLAB_COMPACT_AT` thousand when set — not from a fixed 300k.
- [flow-cheaper-rounds/plan.md D46] `stop` never blocks and never continues the conversation: no exit 2, no `decision`, no `reason`, no `continue`, no `hookSpecificOutput`, no `additionalContext`; `systemMessage` is its only key; nothing reads `stop_hook_active`. Test cases assert the key set on every `stop` output.
- [flow-cheaper-rounds/plan.md D47] D19's thresholds became fixed steps — 300k and every 100k after it — for the manager's prose as for the `stop` mode: one rule stated once. The task-boundary `/clear` stays the manager's, because no hook can tell a task boundary. After I1 (D61): the manager reads the current `agent` line, so its suggestion may come before the user's line; the two never disagree on the steps. **Amended by `[flow-planner/plan.md D12]` since `glab` 0.10.0 (`2912002`), by the variable only:** the first step is 300k by default or `GLAB_COMPACT_AT` thousand when set, every 100k after it; the manager reads it from the line's `; compact at <t>k`.
- [flow-cheaper-rounds/plan.md D48] "Impossible to bypass" — what holds: the hooks run in the harness whatever the model does, in every session where `glab` is enabled. What does not: they do not run when the plugin is disabled, under `--bare`, or under `disableAllHooks: true`; managed policy can restrict hook sources (effect on a plugin's hooks UNVERIFIED, FU15); an interrupted turn fires no `Stop`. Each is a setting or an act of the user or organisation, not something the model can do; the dispatch-count fallback covers a session where no line comes. Whether a live model follows the prose rule stays UNVERIFIED.
- [flow-cheaper-rounds/plan.md D49] Manager decision, Stage 1b round 1: the manager tests the plan delta with `cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and `findings.md`), reading the exit code only — 0 identical, 1 changed, 2 a file missing — and never reads the diff itself; only the analyzer of round `<n+1>` runs `diff -u`. Amends D10 and D12. **Amended by `[flow-planner/plan.md D38]` since `glab` 0.10.0 (`2912002`), by the file name only:** the second `cmp` is of `evidence.md`, or `findings.md` in a folder from before 0.10.0. **Extended since `glab` 0.11.0 (`0cbf5b0`; `[flow-master-plan/plan.md S2]`):** one `cmp -s plan/{slug}/<name>.r<n>.md plan/{slug}/<name>.md` per file the round checked — `master.md` and `index.md` too where it checked them; exit 1 on any file is a change, exit 0 on every file none.
- [flow-cheaper-rounds/plan.md D50] Manager decision, Stage 1b round 1: the Stage 3 snapshot seeds its temporary index from `HEAD` first, because a tracked file that matches `.gitignore` is skipped by `git add -A` into an empty index. Limits kept in FU8: with no commit yet `git read-tree HEAD` fails and that round runs whole; a file force-added to the index but not committed that matches `.gitignore` is still missed. Amends D11.
- [flow-cheaper-rounds/plan.md D51] Manager decision, Stage 1b round 1: a review round `<n>` ≥ 2 goes to a new reviewer with the target, the previous round's findings verbatim and the range of the fix, and never the plan, the slug or the intent. A *One fact* entry binds `reviewer.md`, the manager and `ship.md`. Supersedes D13 and closed FU7.
- [flow-cheaper-rounds/plan.md D52] Manager decision, Stage 1b round 1: a round-2 `BLOCK` with no `critical` or `high` finding is that last round's verdict — there is no round 3; the stage ends as D6 says, to the user. Rule 5's report check stays for malformed reports only.
- [flow-cheaper-rounds/plan.md D53] Manager decision, Stage 1b round 1: with no plan behind the stage (`/glab:review` or `/glab:ship` on its own) the round-3 reason goes in the handoff line that announces round 3 (`round 3/3 (<severity> <finding>)`) and in the conversation; once it can no longer be found, there is no round 3.
- [flow-cheaper-rounds/plan.md D54] Manager decision, Stage 1b round 1, **confirmed by the manager at the plan's `## Decisions`** (the planner's reading, open to the user's overrule): at full tier, Stage 3 after a review fix is one delta round per review fix, against the tree id the last `CONFORMS` measured; it neither resets nor uses Stage 3's cap; a `DIVERGES` there goes back to develop and then on to Stage 5 with no second Stage 3 round, so the loop stays bounded; the analyzer is also given the review findings the fix answered.
- [flow-cheaper-rounds/plan.md D55] `glab:analyzer` states the round-3 trigger ("In round 2 it decides whether a round 3 runs"), so `agents/analyzer.md` joins the round-caps *One fact* entry.
- [flow-cheaper-rounds/plan.md D56] The plan's post-conditions match content, not line numbers or line wrapping (joined text, counts per file), so a half-written step prints `0` for its phrase. Scoping of that change's searches; `AGENTS.md` *Tests* and the Markdown gate (`[bug-reviewer-findings/follow-ups.md 20]`) are unchanged.
- [flow-cheaper-rounds/plan.md D57] `AGENTS.md` *Gates* reads "run all four, in order", with the fourth command (`bash tests/context-size.test.sh …`) added; the green line is five `rc=0` lines and, for each test, every line `ok` and a last line `PASS n/n`.
- [flow-cheaper-rounds/plan.md D58] `.claude-plugin/marketplace.json`, the `glab` entry's `description`, became "The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook"; only the description changed; outside `plugins/`, so no version of its own (`docs/specs/marketplace.md`).
- [flow-cheaper-rounds/plan.md D59] The input-parse `jq` of the script sends its stderr to `/dev/null`, so a malformed input prints exactly one line, `glab context-size: hook input is not JSON`.
- [flow-cheaper-rounds/plan.md D60] **Superseded by `D63` after I1.** It was: nineteen test cases, the last line `PASS 19/19`, T2 printed last. It is now twenty-one cases, `PASS 21/21`. What survives: each `T<n>` is one case and prints one line; a case with several inputs is `ok` only when every input passes.
- [flow-cheaper-rounds/plan.md D61] Manager decision, I1: `stop` stays stateless and accepts a one-turn delay. At `Stop` it compares the step of the latest *written* assistant total with the step of the total that precedes the **previous** real user prompt. It speaks once, on the turn after the crossing; when the crossing call is already written at its own turn's `Stop` (a transcript written in time, or a crossing at a call that is not the turn's last) it speaks then and once more — at most two lines per crossing, never a missed one. Rejected: polling in the hook until the turn's reply is written (up to about 1 s on every turn end); a per-session state file under `${CLAUDE_PLUGIN_DATA}`; dropping `stop` (I1b showed the display works). The user may overrule it. Amends D45.
- [flow-cheaper-rounds/plan.md D62] The `stop` base as built: the `reduce` state is `{last: 0, base: 0, cur: null}`; a real prompt does `.base = .last | .last = (.cur // 0)`. A window with fewer than two real prompts has `base` 0 and speaks at or past 300k. Each `Stop` covers the calls written since the prompt before the last, so consecutive `Stop`s overlap and leave no gap as long as the transcript catches up within one turn. Rejected by the planner: a base of "the assistant total before the last one that precedes the latest prompt", which speaks exactly once in every lagging case but misses a crossing if the lag is ever more than one entry; D45 prefers a line too many to a missed one. Known limit: a `/compact` inside the two turns can leave `base` above `cur`, so a crossing after the drop in that range shows only at the next `Stop` whose base is past the drop — a rise of over 250k within two turns, accepted.
- [flow-cheaper-rounds/plan.md D63] Tests after I1 (supersedes D60's count): T18's fixtures rewritten for D62 (each the transcript as it stands when `Stop` runs), T20 (a lagging session speaks once, on the turn after) and T21 (a crossing already written speaks then and once more, never a third time) added; the order is T1, T3–T18, T20, T21, T19, T2; `PASS 21/21`. Against the script as built before the fix, T18, T20 and T21 fail (`FAIL 3/21`): I1b's failure reproduced without a model.
- [flow-cheaper-rounds/plan.md D64] D41 said no `memory-sync` hook runs under `--plugin-dir ./plugins/glab`; I1a's run had a second `Stop` hook that ended `cancelled`, exit 1, so the plugins the user installed appear to load beside `--plugin-dir` in their own config; which plugin's hook it was is UNVERIFIED (inferred: the installed `memory-sync`'s network sync cut off when `-p` exited; FU18). `--plugin-dir` alone loads `glab` only under an empty config. An I1 run in the user's terminal runs the user's installed hooks, as any of their sessions does; switching them off is a `claude plugin` change, the user's alone. Amends D41.
- [flow-cheaper-rounds/plan.md D65] The two built texts that say when the user sees the `Stop` line were changed with D61 to stay true: `glab:manager` Rule 2 ("…tells the user directly, at the end of that turn or, usually, the next.") and `README.md` ("usually the turn after the crossing"). The steps did not change (D47), so the rest of those texts stands.
- [flow-cheaper-rounds/plan.md model] `- model: glab:developer sonnet, glab:reviewer sonnet, for this task` — **the user's instruction**, not a manager choice: "okay", in reply to the manager's recommendation. "For this task" ended with this task's record (Rule 5, `[feature-docs-specs/plan.md D22]`); **it does not bind later tasks.**
- [flow-cheaper-rounds/plan.md effort] `- effort: high`, the user's words for the session (as in `[subagent-effort/plan.md approval]`) — that session's own line, spent.
- [flow-planner/plan.md D1] The plan's findings file is `evidence.md`: a subagent's Write of `findings.md` is refused and `evidence.md` was accepted (`[flow-planner/evidence.md F8]`, `IN1`).
- [flow-planner/plan.md D2] `plan.md` and `evidence.md` are at most 48 KB each (`wc -c`), because every later agent reads them again; `flow-cheaper-rounds`' plan grew from 59 KB to 155 KB over three amendments (`[flow-planner/evidence.md F1]`). **Extended by `[flow-master-plan/plan.md S1]` since `glab` 0.11.0 (`0cbf5b0`):** the 48 KB budget covers `master.md`, `plan.md`, `index.md` and `evidence.md`.
- [flow-planner/plan.md D3] A decision is one line, choice and reason in at most two sentences, evidence cited by id and never restated; a fact is written once.
- [flow-planner/plan.md D4] A plan that cannot be split carries `- size: <n> KB — <why it is one plan>` under `## Decisions`, and the manager decides under Rule 3.
- [flow-planner/plan.md D5] Amendments replace the text they change, in place, under the same id; the `.r<n>` copies are the history (`[flow-cheaper-rounds/plan.md D10]`), and the manager's overrule line stays (`[sync-local-edits/result-followups.md D9]`).
- [flow-planner/plan.md D6] The manager checks the size by `wc -c` alone (Rule 2 forbids reading the plan); the analyzer checks in-place amending on its re-check, as the one reader of the diff.
- [flow-planner/plan.md D7] Steps 5–7 of `glab:plan-first` and the three implementation-only repo rules moved byte for byte, numbers kept, to `plan-first/implement.md`, so no caller breaks (`[flow-planner/evidence.md F2]`). It closed `[flow-cheaper-rounds/plan.md FU2]`.
- [flow-planner/plan.md D8] Rejected homes for Steps 5–7: `glab:developer` (a session implementing without subagents loses them, and "steps 5 to 7" points at nothing) and a new `glab:implement` skill (`Skills (14)` → 15 in four files) (`[flow-planner/evidence.md B1]`, `B2`).
- [flow-planner/plan.md D9] No `glab:planner` agent in that change — **the user's decision**, carried: the agent count changes once, in `flow-models-per-role` (`[flow-planner/evidence.md F3]`; `[flow-planner/plan.md FU1]`). Carried again by `[flow-master-plan/plan.md D36]`: the analyzer's two kinds wait for the same plan. Done there, in `glab` 0.12.0 (`09d5664`): the agent count went from five to seven at once (`[flow-models-per-role/plan.md D4]`, `D6`).
- [flow-planner/plan.md D10] The developer's context rules are prose in `glab:developer` — **the user's decision**, carried; no hook is shown to shorten a tool's output (`[flow-planner/evidence.md F4]`).
- [flow-planner/plan.md D11] No `scripts/gate.sh`: one inline line does it.
- [flow-planner/plan.md D12] The first context step is `GLAB_COMPACT_AT` thousand when set, default 300k, then every 100k — **the user's decision**, carried. It amends `[flow-cheaper-rounds/plan.md D45]` and `D47` by the variable only (`[flow-planner/evidence.md F5]`).
- [flow-planner/plan.md D13] No per-model table and no fraction of the window: the hook is not told the window.
- [flow-planner/plan.md D14] A set, valid value ends the line `; compact at <t>k)` in all three modes, so the manager reads the step from the line.
- [flow-planner/plan.md D15] An invalid value (not `^[1-9][0-9]{0,5}$`) warns once on stderr and uses the default; it is read after the transcript, so each failure path keeps one stderr line.
- [flow-planner/plan.md D16] Empty is unset: no warning.
- [flow-planner/plan.md D17] On a window not larger than the first step plus 100k the manager tells the user once and names the variable; the number is the user's.
- [flow-planner/plan.md D18] `glab` `0.9.0` → `0.10.0`, nothing removed, so no `!`; `memory-sync` untouched, `0.1.0`.
- [flow-planner/plan.md D20] One commit with the plan folder, because *One fact* wants each fact's files together and the plan has no sub-plans. Done as one commit, `2912002`. Since `glab` 0.11.0 a slug with sub-plans commits once per sub-plan (`[flow-master-plan/plan.md D30]`).
- [flow-planner/plan.md D21] `flow-models-per-role` stays a separate plan, after this one — **the user's decision**, carried (`[flow-planner/evidence.md F7]`; `[flow-cheaper-rounds/follow-ups.md FUc]`). That plan ran after `flow-master-plan` and landed as `09d5664` and `517b7b6` (`glab` 0.12.0).
- [flow-planner/plan.md D22] `AGENTS.md` *One fact* changed as its S8 says: the mapping-files entry names `evidence.md`, the context-hook entry the suffix, the first step and the warning, and three entries are new — the plan size budget, in-place amendments, `glab:plan-first`'s step numbers (`docs/specs/marketplace.md`).
- [flow-planner/plan.md D38] `evidence.md` and `evidence.r<n>.md` wherever the payload names the file; readers, and the manager's Stage 1b copy and `cmp`, still accept `findings.md` in a folder from before 0.10.0. It amends `[flow-cheaper-rounds/plan.md D10]` and `D49` by the name only (`[flow-planner/evidence.md F9]`, `F11`).
- [flow-planner/plan.md D19] One `glab:developer` for the change, since most steps shared `manager/SKILL.md` or `AGENTS.md` — scoping of that change, spent.
- [flow-planner/plan.md D41] The change ran under the 0.9.0 rules it changed, with no `master.md` — scoping of that change, spent. Round 3 split round 2's plan in two, on the user's approval: the plan carried D1–D22, D38 and D41 of round 2's ids, and round 2's other decisions, its S3 and S6 and FU7 and FU9 moved to `plan/flow-master-plan/`, not recorded here.
- [flow-planner/plan.md effort] `- effort: high`, the user's words for that session after its compact — that session's own line, spent.
- [flow-master-plan/plan.md D23] **The user's decision:** a constant master plan and isolated sub-plans — "planner must logical isolated plan stages to separated plans … the based high level plan as a constatn / sub plans witch are must be a low level plans / each low level plans must be iterated with isolated planning cycle / and must be good to have low level plan specs constant validation or verification flow also"; its aim: "subagents can read all plan … it can consume more tokens".
- [flow-master-plan/plan.md D24] Every folder gets `master.md`, and beside it one `plan.md` by default or `index.md` and sub-plan folders, each a full plan folder: a small task has two files and no tree (`[flow-master-plan/evidence.md B5]`). The split lives in `index.md`, an engineering choice that amendments change (`B6`).
- [flow-master-plan/plan.md D25] Constant means hashed: `master.sha256` after `## Approval`, checked with `sha256sum -c` by every analyzer and by `/glab:develop`; `chmod a-w` was rejected (`[flow-master-plan/evidence.md B11]`).
- [flow-master-plan/plan.md D26] Approval comes after Stage 1b, so the user approves a checked plan — the user's at full tier and whenever the work split. It amends the manager's earlier order, in which full-tier approval came before Stage 1b (`glab:manager` Stage 1 until `0cbf5b0`; `[flow-master-plan/evidence.md F11]`).
- [flow-master-plan/plan.md D27] Split only into parts with their own goals and milestone, never across a fact the repo changes in one commit (`[flow-master-plan/evidence.md F15]`); each is planned once its dependencies are committed and built one at a time in `<nn>` order, so it cites the tree it is built on and each review sees one change.
- [flow-master-plan/plan.md D28] An agent reads `master.md`, its own folder, its `index.md` line and the slug-level map files its dispatch names — the user's token aim (D23); only the coverage and final checks read all of `index.md`.
- [flow-master-plan/plan.md D29] Round caps per sub-plan and stage; the master and final checks have the same cap, their round-3 line in `index.md` (`plan.md` with no sub-plans). It extends `[flow-cheaper-rounds/plan.md D2]` (marked above).
- [flow-master-plan/plan.md D30] One commit per sub-plan, one push and one record per slug; a single plan commits once (`[flow-master-plan/evidence.md B7]`: with one commit per slug the blind reviewer of sub-plan 2 would see sub-plan 1's uncommitted change). `AGENTS.md`'s version rule then reads per push: the push's first commit that changes the plugin raises it (`[flow-master-plan/evidence.md F15]`; `docs/specs/marketplace.md`).
- [flow-master-plan/plan.md D31] Stage 3 runs for every sub-plan at every tier, as the user listed the cycle "plan → analyzer plan check → develop → analyzer conformance → review"; it amends `[sync-local-edits/result-followups.md D5]` for sub-plans only (marked above); a normal-tier single plan keeps none (`[flow-master-plan/evidence.md B12]`).
- [flow-master-plan/plan.md D32] **The user's decision:** the analyzer checks the intent at Stage 1b, Stage 3 and the final check — "analyzed … on every stage must validate and find gaps between original business plan and implementation"; the reviewer stays blind — "review agent must only check the code itself without any plan" — so no reviewer file and no *One fact* review entry changed (`[flow-master-plan/evidence.md F10]`, `B9`). `[feature-model-switch/plan.md D5]` and `[flow-cheaper-rounds/plan.md D51]` stand.
- [flow-master-plan/plan.md D33] The final check is Stage 6b, after the slug's last commit and before the push; skipped only for a single full-tier plan, whose Stage 3 asked it.
- [flow-master-plan/plan.md D34] An intent gap after the build is a defect of the plan: it goes to a planning agent, and a developer reports it as `PLAN WRONG`.
- [flow-master-plan/plan.md D35] `glab:analyzer` gets the plan check and its verdicts `BUILDABLE` and `NOT BUILDABLE`, until then stated only by the manager (`[flow-master-plan/evidence.md F10]`); a master check or a final check has no `plan.md`, so its contract is `master.md` and `index.md` (`[flow-master-plan/evidence.md F17]`). It closes `[flow-cheaper-rounds/plan.md FU5]`. **Amended by `[flow-models-per-role/plan.md D6]` since `glab` 0.12.0 (`09d5664`):** the plan check, the master check and the two verdicts moved to `glab:plan-analyzer`; `glab:analyzer`'s final check keeps the `master.md` and `index.md` contract.
- [flow-master-plan/plan.md D36] No two analyzer kinds in that change: each check gains the intent question, and the split goes to `flow-models-per-role` with the planner agent (`[flow-master-plan/evidence.md B8]`, `[flow-planner/plan.md FU1]`). Done there (`[flow-models-per-role/plan.md D6]`, `09d5664`).
- [flow-master-plan/plan.md D37] **The user's decision:** the flow should "work with claude app|cli builtin flow". Plan mode carries the master's approval only when the user asks, main session only (`[flow-master-plan/evidence.md F12]`), after Stage 1b with no agent running, no plan file outside the repo, `plansDirectory` untouched. L1–L7 are the user's and no precondition of Stage 2; until they run, the payload and `README.md` mark each plan-mode claim F12 holds inferred or UNVERIFIED as `UNVERIFIED` and name the live test that settles it — the manager's decision after plan check round 1. A `PreToolUse` hook on `ExitPlanMode` to record the approval was rejected (`[flow-master-plan/evidence.md B10]`).
- [flow-master-plan/plan.md D39] `## Record` moves to `master.md`; a folder with no master keeps `plan.md`'s. It amends `[feature-docs-specs/plan.md D5]` and `D28` (marked above).
- [flow-master-plan/plan.md D40] The stage listings gain "final check" (`[flow-master-plan/evidence.md F13]`): the manager's description, `glab:bootstrap` step 4 and the hook text.
- [flow-master-plan/plan.md D42] A single plan's Stage 1b analyzer reads `master.md` and `plan.md` together.
- [flow-master-plan/plan.md D43] (round 3 of `flow-planner`, the split) The plan was built on the tree `flow-planner` left on `origin/main`, `28f7d1d`, and nothing in `flow-planner` depends on it — scoping of that change, spent.
- [flow-master-plan/plan.md D44] (the split) As `[flow-planner/plan.md D18]`, `D19`, `D20` and `D22`, for this change: `glab` 0.10.0 → 0.11.0, nothing removed, so no `!`, `memory-sync` untouched at `0.1.0`; one `glab:developer`, one commit with the plan folder (`0cbf5b0`), and *One fact* changed as its S8 says (`docs/specs/marketplace.md`) — scoping of that change, spent but for the version.
- [flow-master-plan/plan.md D45] (the split) The change ran under the 0.10.0 rules it changed, as `[flow-planner/plan.md D41]` did under 0.9.0: no `master.md`, its findings in `evidence.md`; the user's words are in D23, D32, D37 — scoping of that change, spent. The first plan to run under the master rules is the next one (`[flow-master-plan/plan.md FU9]`).
- [flow-master-plan/plan.md D46] The manager's decision after plan check round 1: at full tier each sub-plan's `plan.md` also gets the user's explicit approval after its own Stage 1b, as an `## Approval` line at its end; at normal tier the master's approval covers the sub-plans — so *Pick the tier*'s explicit approval holds for every full-tier plan. Extended in review fix round 1 to a single full-tier plan's `plan.md`, approved together with the master (`[flow-master-plan/result.md R2]`).
- [flow-master-plan/plan.md D47] The change closed the two follow-ups `flow-planner`'s record left it, `[flow-planner/record.md review-waiver-implement]` (S1, S9) and `[flow-planner/record.md review-t19-comment]` (S10) (`[flow-master-plan/evidence.md F17]`); both under *Closed follow-ups*.
- [flow-master-plan/result.md R1] Review fix round 1, the manager's decision on a blocking finding: no round amends an approved `master.md`; a changed request is a new master, the old kept as `master.v<n>.md`, its approval and hash not carried over, `master.sha256` removed when the planner is dispatched, and a new Stage 1b, approval and hash.
- [flow-master-plan/plan.md effort] `- effort: high`, the user's words for that session after its compact — that session's own line, spent.
- [flow-models-per-role/questions.md Q1] **The user's answer, 2026-11-11: "Default"** — to a Rule 3 ask (it costs money and changes what the product is): the approved table ships as glab's default for every installer, each agent's model set in its definition, the user's words for a task still overriding it, Rule 5 reworded, every installer getting these models and their cost. The option text is as the manager relayed it, not the user's verbatim option (`questions.md`). The plan rests on it in D2 and D7–D10.
- [flow-models-per-role/plan.md D1] One plan, one commit, no sub-plans: the *One fact* entries the change rewrote (the model rule, the agent count, the analyzers' verdict lines, the intent check, the severity levels) each span files of every part, and the plan fit the 48 KB budget. Done as `09d5664`; the PR #7 review fix `517b7b6` landed with it on `origin/main` through PR #7 (merged 2026-11-12).
- [flow-models-per-role/plan.md D2] The table ships as each agent's default, set by the frontmatter `model:` of its definition — the user's answer "Default" (Q1), not a planner choice. Supersedes `[feature-model-switch/plan.md D8]`.
- [flow-models-per-role/plan.md D3] The values are the aliases `opus`, `sonnet`, `haiku`, never full IDs: aliases follow the recommended version per provider and a full name pins one (`E3`); the Agent tool's `model` parameter takes aliases only (`E1`, `E2`), so overrides and defaults speak one vocabulary.
- [flow-models-per-role/plan.md D4] A `glab:planner` agent exists (`model: opus`) and `/glab:plan` dispatches it, as `/glab:analyze` dispatches its analyzer: until then no file named the planning agent's type, so it ran on whatever generic agent the manager picked, on the main conversation's model (`E7`); a default needs a definition to live in. Closes `[flow-planner/plan.md FU1]` and `[flow-cheaper-rounds/plan.md FU1]`.
- [flow-models-per-role/plan.md D5] `glab:planner` has the explicit `tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch` — every tool `glab:plan-first` needs and no `Agent`, so it cannot start nested subagents that would run with no model or effort set under Rules 0d and 5 — **the manager's decision on review finding R2.2**, replacing "no `tools` line, inherit every tool"; its body confines its writes to the plan folder its dispatch names, with the exceptions the dispatch can grant (R2.1).
- [flow-models-per-role/plan.md D6] Two analyzer agents, not one with two modes: `glab:plan-analyzer` (`model: opus`) takes the plan check and the master check of Stage 1b; `glab:analyzer` (`model: sonnet`) keeps the conformance check, the final check and the record check. A frontmatter default is per file, and one file with a per-dispatch model would put the default back in the manager's memory (rejected `B2`); each file also loads less (`E10`). Amends `[flow-master-plan/plan.md D35]`; carries out `[flow-master-plan/plan.md D36]`.
- [flow-models-per-role/plan.md D7] `glab:analyzer` keeps its name for the conformance kind, so the Stage 3, 6b and 8 citations and `/glab:analyze`'s name stay; only Stage 1b's citations move to `glab:plan-analyzer`.
- [flow-models-per-role/plan.md D8] One `/glab:analyze` command, its argument still the slug, routes by the check the dispatch names first: a named plan or master check to `glab:plan-analyzer`, even with a `result.md` present (an amended plan keeps its earlier `result.md`; the PR #7 review comment, fixed in `517b7b6` and D8 updated in place), a named final or record check to `glab:analyzer`; with no check named, the folder settles it — a `result.md`, the conformance check (`glab:analyzer`), none, the plan check (`glab:plan-analyzer`); it asks only when a named check is none of these — **the manager's decision on review finding R2.4**: asking whenever `result.md` exists would stop every Stage 3 for the user, and a sub-plan slug has no slug-level `result.md`, so the folder alone cannot route its final check. Rejected: a new `/glab:plan-check` command (`B4`: `Skills (14)` → 15 for no gain).
- [flow-models-per-role/plan.md D9] Rule 5 reworded: with no instruction, no `model` parameter, and the definition's model runs; the user's words override for any role they name, passed as the `model` parameter on every dispatch of that role; the manager never picks one; an agent with no definition (mapping, read-only, fan-out not one of the seven) gets no parameter unless the user names one for it — Q1's answer. Supersedes `[feature-model-switch/plan.md D2]`, amends `D1`.
- [flow-models-per-role/plan.md D10] Rule 5's dispatch-per-model table applies to the model the agent runs on, its default included: a `glab:committer` dispatch is written for `haiku` and every Sonnet-default dispatch pastes the role's *Report* section — `[feature-model-switch/plan.md D20]`'s rule kept, now met by defaults.
- [flow-models-per-role/plan.md D11] The handoff line names the model on every stage that dispatches an agent, not only develop and review: `model <alias>` after the stage, the table's alias when no parameter was passed, `model <alias> (user)` when the user's override was; `model default` goes, because every role now has one. Amends `[feature-model-switch/plan.md D11]`.
- [flow-models-per-role/plan.md D12] An override for the Stage 8 record's agents, which have no `plan.md` to record it in, lives in the conversation only, as for a `/glab:review` with no plan. Closes `[feature-docs-specs/follow-ups.md 5]`.
- [flow-models-per-role/plan.md D13] Rule 5 and `README.md` say that `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the seven glab agents — a frontmatter `model` outranks it — and that `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` still overrides both the definitions and the parameter, from v2.1.257 (`E1`): an installer who set the variable to save money would otherwise lose that without a word.
- [flow-models-per-role/plan.md D14] No `effort:` in any frontmatter: Rule 0d passes `effort` on every dispatch at the session's level, and its substance did not change (S5 edited only its agent list and its no-`model` sentence); a subagent on a model other than the main conversation's does not take the session's level unless `effort` is passed (`E4`), one more reason the parameter is always passed. Keeps `[subagent-effort/plan.md D6]`.
- [flow-models-per-role/plan.md D15] A new gate in `AGENTS.md` *Gates* prints every agent's `model:` line, because `plugin validate --strict` passes an unknown value such as `model: sonnett` and `plugin details` shows no model (`E6`). Binds `docs/specs/marketplace.md` too.
- [flow-models-per-role/plan.md D16] `Agents (5)` became `Agents (7)` in `AGENTS.md` *Gates*, and `README.md`'s table lists the seven; the `README.md` line naming "five agents under `agents/`" stays: it lists what an old copied install put in `~/.claude/agents/`, which a new agent was never part of (`E8`). Binds `docs/specs/marketplace.md` too.
- [flow-models-per-role/plan.md D17] `glab` `0.11.0` → `0.12.0`: new agents and a changed default, nothing removed, so no `!`; `memory-sync` untouched, `0.1.0`. Binds `docs/specs/marketplace.md` too.
- [flow-models-per-role/plan.md D18] The new agent files restate no *One fact* value they can cite instead — the manager's decision: `glab:planner` cites `glab:plan-first` and restates none of its values (no step numbers, no `implement.md`, no `map-<area>.md`, no master `## Approval`), so `planner.md` joins no *One fact* entry; `glab:plan-analyzer` carries, copied from `glab:analyzer`, only what its check needs — the contract read, the plan check, the intent question's plan-check bullet, the plan-check re-check, the severity scale, the verdicts `BUILDABLE`, `NOT BUILDABLE`, `BLOCK: target unresolved` — and `AGENTS.md`'s entries for those facts gained its path.
- [flow-models-per-role/plan.md D19] Mapping agents keep no model: they are not in the table, so D9's no-definition rule covers them (`FU2`).
- [flow-models-per-role/plan.md D20] `glab:plan-analyzer`'s `tools` is `analyzer.md`'s, `Read, Grep, Glob, Bash`, without `Skill`, though the docs say a `tools` list without `Skill` cannot invoke skills (`E9`): all five agents then had that gap (`E13`), so closing it for one file widens scope; it is `FU1`. Review finding R2.3 raised it again for the new agent; **the manager kept this decision**, and `FU1` covers all six.
- [flow-models-per-role/plan.md effort] `- effort: high (the user's words: "high (Recommended)"), for the session` — that session's own line, spent.
## Known limits and not verified

- [feature-model-switch/plan.md I1] That the Agent tool on the manager's host takes `model` with the values `sonnet`, `opus`, `haiku`, `fable`, ranked above the definition's frontmatter — read from the tool definition given to one session; it depends on the Claude Code version and host. Its documentation citations (F1–F7, F16) were not re-fetched by the developer (`result.md` *Not done*). Re-read by `flow-models-per-role`: the docs fetched 2026-11-11 give the same alias set and rank the parameter above the frontmatter (`[flow-models-per-role/plan.md E1]`); the tool's own accepted values are still read from one tool definition, UNVERIFIED (`[flow-models-per-role/plan.md E12]`).
- [feature-model-switch/plan.md I4] That a plugin agent honours the per-dispatch `model` — inferred from the docs' list of fields a plugin agent ignores; no live dispatch on `haiku` has been seen running on `haiku`. Rule 5 says so in its own text; `/tasks` would show it. **Re-read by `flow-models-per-role` (`09d5664`):** that `model` is supported in a plugin agent is now documented, not only inferred from the ignore list (`plugins/components.md:324`, `[flow-models-per-role/plan.md E2]`); that a live dispatch honours it, frontmatter or parameter, is still not shown — `[flow-models-per-role/plan.md I1]`.
- [subagent-effort/plan.md unverified] UNVERIFIED: that a plugin agent honours the Agent tool's `effort` parameter — no live dispatch has shown it, the same hedge Rule 5 makes for `model`; the tool schema of the planning session showed only that `effort` takes `low|medium|high|xhigh|max` and that an omitted one leaves the agent at its usual effort. Unlike Rule 5's hedge, Rule 0d's payload text does not say so (`[subagent-effort/plan.md D7]`). Also not checked: how a session started without subagent dispatch is put at the recorded effort (`[subagent-effort/plan.md F1]`). `result.md` restates the first item.
- [subagent-effort/result.md blast-radius] Inferred, not tested: an older plan's `- model: … codex, effort <level> (…)` line is still readable prose, while the rule now records the effort in a `- effort:` line instead. Since `glab` 0.8.0 (`467b7c4`) no rule reads a Codex model line at all.
- [remove-external-agents/plan.md inferred] Inferred, not shown: a user who names an external reviewer or developer after 0.8.0 meets Rule 5's "say so, and ask which of the four the user means" (`D11`); no session was run. The user's own auto-memory, outside this repository, still describes Codex as an outside reviewer and developer "via the skill", which no longer exists; it is the user's file and the change did not touch it.
- [remove-external-agents/result.md not-done] UNVERIFIED: that a live session follows the edited prose of `glab:manager` and the commands as intended — no session was run against it, as the plan accepts; the searches C2–C4 show only that nothing naming the removed parts is left outside `docs/specs/` and `plan/`.
- That the user's local edits ported by `sync-local-edits` were exactly their 2026-10-08 change: inferred from the dispatch and the file times, not from a record of the edit (`[sync-local-edits/result.md L219]`).
- No `glab` stage removes a plan folder: Stage 8 writes the spec only, and a repo that wants its folders removed says how in its own `AGENTS.md` (`[feature-docs-specs/plan.md U10]`). A repo with no such rule keeps every recorded folder in its tree. This repo's rule is in `docs/specs/marketplace.md`.
- Stage 8 names no commit and checks no landing: it starts once Stage 7 has confirmed the push, and the record reads the folder from disk, so a squash or rebase merge does not change what it records. Naming the commit that holds a removed folder is the repo's own rule; this repo's names the last commit on `origin/main` that holds it, after `git diff --quiet origin/main -- plan/<slug>/`. In a throwaway repo a squash merge left the branch commit off `origin/main` and the folder on it, and `git log -1 --format=%h origin/main -- plan/<slug>/` gave the squash commit (feature-docs-specs findings, *Amendment — review round 1/3*).
- [feature-docs-specs/plan.md unverified] Not shown, as of the record: that an installed `0.5.0` runs Stage 8 as written (needs a session on an installed copy); that every incident of the seven migrated folders reached a spec and each migrated status is true (the check script proves tags and presence, not truth); that the payload texts read well; and the back-out's inference that an installed `0.5.0` ignores a move back to `0.4.2`. The squash-merge item of that list is answered above.
- [feature-docs-specs/findings.md inferred] The specs, the payload text and `AGENTS.md` are prose: no command judges them correct. An installed copy follows the rule only from `0.5.0`; the agents that built and recorded `feature-docs-specs` ran the installed `0.4.2`, so its folders were removed under `0.4.2` contracts, and its record (X1) was dispatched with Stage 8's steps in the message.
- [flow-cheaper-rounds/plan.md F1] **Measured by the manager in another project, not reproducible here** — the evidence the change rests on: total input over all turns 597M tokens, of which developers 49%, planners 21%, Stage 1b plan checks 11%, reviewers 8%, mapping agents 6%. Fix rounds sent back to the same resumed agent cost 149M, each round restarting at 300–450k context, modelled as fresh agents at about 37–64M. A Stage 1b round 2 that re-read the whole plan cost 9.5M against round 1's 9.0M; targeted re-check rounds cost about 40% of round 1. The planner, handed three mapping files, re-touched 40 of its 157 paths that mapping had already read. Normal-tier plans were run against full-tier caps. The manager session itself: 1,054 turns, a 648k peak, 348M tokens (about 37% of the run), five tasks and one compaction. **Inferred, not shown:** the savings each change brings, and that a live session follows the edited prose (UNVERIFIED, as for every rule of this change).
- [flow-cheaper-rounds/plan.md F8] Untested cases of the two delta mechanisms: a nested repository in the tree (`git add -A` would record a gitlink with a warning) and a large untracked directory that is not ignored (every file is hashed). Shown in a throwaway repo only: the snapshot catches tracked, staged, untracked and deleted files, leaves the real index and `git status` unchanged, skips ignored files, gives the same id for the same tree; `cmp -s` exits 0, 1 or 2 with no output. Limits kept in `[flow-cheaper-rounds/plan.md FU8]`.
- [flow-cheaper-rounds/plan.md F9] The Write-tool probe was partial: only `findings-probe.md`, `findings.md` (refused) and `map-probe.md` (accepted) were tried; which other names the guard refuses is not known. Extended by `[flow-planner/evidence.md F8]` (below): `evidence.md` and five other names accepted, `summary.md` and `report.md` still untried.
- [flow-cheaper-rounds/plan.md F15] Round 1's UNVERIFIED — that `CLAUDE_CODE_SESSION_ID` is set and names the transcript on any host other than the manager's — no longer binds anything: nothing reads the variable since `D30` (`FU9`, closed as moot).
- [flow-cheaper-rounds/plan.md F20] **Documented by Claude Code, not proven here, and UNVERIFIED where marked:** `PostToolUse` and `UserPromptSubmit` take `additionalContext`; `Stop` takes `systemMessage` (common field, "Warning message shown to the user") and, with exit 0 and no `decision`, lets the turn end; `SubagentStop`'s `additionalContext` goes to the subagent; the transcript "is written asynchronously and may lag"; hooks do not run under `disableAllHooks: true` or `--bare`. UNVERIFIED: that the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 (`FU11`); whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks (`FU15`); whether the Agent `tool_input` carries `effort` (`FU13`); which transcript a subagent that itself calls `Agent` is handed, if the hook fires there (changes nothing above). An interrupted turn fires no `Stop` (documented), so shows nothing; the next turn's `prompt` line still carries the number.
- [flow-cheaper-rounds/plan.md F23] What integration I1 showed and did not (the user ran it in their terminal, Claude Code `2.1.304`, one host, one version): shown — `agent` line current at `PostToolUse` (a 36,185-token request printed `37k`), the `prompt` line reached the model, `Stop`'s `systemMessage` shown to the user in the terminal with the turn ending there, and at `Stop` the turn's last call not yet written (there 1 s later). **Not observed:** whether the model also sees the `Stop` text (I1b's quote prompt was not reported); a display other than the terminal, such as the desktop app (`FU17`); how far the lag can grow on another host or under load (D62 relies on the transcript catching up within one turn); which plugin's second `Stop` hook ended `cancelled`, exit 1, in I1a (`FU18`). I1c, the re-run of I1b on the rebuilt `stop` (expected: nothing on turn 1, the line on turn 2, the turn ending there), **passed**: the plan folder holds no I1c output (`F24` holds the fixture run only); what it showed turn by turn, as the manager observed it from the user's screenshot, is in *Incidents* (IN1).
- [flow-cheaper-rounds/plan.md F24] The `stop` base and the new cases were proven on throwaway copies without a model: the rebuilt script `PASS 21/21`, the script as built before the fix `FAIL 3/21` (T18, T20, T21), and mutants of the rebuilt copy fail the test (a `"decision":"block"` in the `stop` JSON → T18, T20, T21, T19; `+ 999` removed → T1, T3, T13; the `isSidechain` filter removed → T15; the old real-prompt branch → T18, T20, T21). Fixtures only: a real transcript's shape on other CLI versions was not read (the brief keeps transcripts out of reach).
- [flow-cheaper-rounds/plan.md D62-limits] Known limits of `stop`'s base: a `/compact` inside the two turns it covers can hide a crossing until the next `Stop` whose base is past the drop; a lag longer than one turn is not covered by any case (it would still speak, later); and a window with fewer than two real prompts speaks at or past 300k.
- [flow-cheaper-rounds/result.md review-fix-1] Review round 1/1 (`SHIP`, low) found the script header claiming `stop` speaks "once per crossing, twice at most", untrue when fewer than two real prompts fall inside the 8 MiB window: then `base` stays 0 and `stop` speaks at **every** turn end while the context is at or past 300k. That needs more than 8 MiB of transcript between two consecutive prompts (one turn of very large tool results) and ends with the next ordinary turn. Accepted — the window bounds the read cost, a line too many is the cheaper error — and fixed by comment only (`plugins/glab/scripts/context-size.sh` header); the behaviour is covered by the T18 cases `no prompt in the window` and `one prompt in the window`, not by a 9 MB fixture.
- [flow-cheaper-rounds/plan.md F17] Not measured: how long `context-size.sh` takes on any host but this one. T9 prints it (0.07 s here on a 36 MB transcript); the hook's 5 s `timeout` is the bound if a host is slower. UNVERIFIED elsewhere.
- [flow-cheaper-rounds/result.md digit-guard] Not covered by any test case: the defensive digit guard in `context-size.sh` (`[[ $v =~ ^[0-9]{1,15}$ ]]`, its `fail` branch) — `jq`'s `floor` cannot fail it for any usage the fixtures can hold except an exponent form (usage above 1e17); it exists so the script can never reach a bash arithmetic error, which would break the exit-0 contract.
- [flow-cheaper-rounds/plan.md F18] The CLI labels every hook "harness-only — no model context cost" in `plugin details`, which is not true of a hook that returns `additionalContext` (`FU12`); the gate's green line for `glab` prints the events in the file's key order, so reordering `hooks.json` changes the line.
- [flow-planner/evidence.md F2] Shown: a sibling file in a skill folder changes neither validation nor the counts (a throwaway copy with `implement.md` added, a fresh `CLAUDE_CONFIG_DIR`: `✔ Validation passed`, `Skills (14)`, `Agents (5)`), and in that session the Skill tool put only `SKILL.md` into context. **Inferred:** that a sibling file costs nothing until read on other Claude Code versions, and that a session following `SKILL.md`'s pointer reads `implement.md` (Markdown has no runtime).
- [flow-planner/evidence.md F4] The developer figures — a 509k peak in one round, about 480k characters of tool output, `plan.md` read three times — are the caller's measurements of another project, inferred here. **UNVERIFIED:** that a `PostToolUse` hook can shorten a built-in tool's output (`[flow-planner/plan.md FU3]`); the context rules are prose, and whether a live developer follows them is not shown.
- [flow-planner/evidence.md F5] `GLAB_COMPACT_AT` was proven on throwaway copies and by T22–T24 only. **Inferred:** that a variable exported in the shell that starts Claude Code reaches its hooks (child processes); **UNVERIFIED:** that a settings file's `env` block does (`[flow-planner/plan.md FU4]`). No live session with the variable set has been run.
- [flow-planner/evidence.md F8] The Write-tool probe of round 2 (one subagent, one session): `findings.md` refused; `evidence.md`, `master.md`, `01-probe/plan.md`, `01-probe/evidence.md`, `index.md` and `evidence.r1.md` accepted. **Inferred:** the refusal keys on the name, not the directory or the agent type. Which other names it refuses (`summary.md`, `report.md`) is not known (`[flow-planner/plan.md FU8]`); this extends `[flow-cheaper-rounds/plan.md F9]`.
- [flow-planner/plan.md S7] One branch of the `GLAB_COMPACT_AT` code is covered by no case: the warning printed together with a failure line. Unreachable by construction — the variable is read after every `fail` path, and `fail` exits (`[flow-planner/result.md S7]`).
- [flow-planner/plan.md S8] The Markdown steps (S1, S2, S4, S5, S8 and the manager's S7 text) have no runtime: their searches, `bash -n`, shellcheck and `plugin validate` show the text is there, not that a live session follows it — UNVERIFIED, as for every prose rule. The plan's `grep -c … → 0` checks print `0` on an untouched tree too, so each is paired with a presence check.
- [flow-master-plan/plan.md L1] UNVERIFIED, the user's live test of approval in plan mode — inline plan. Steps: in a throwaway repo (`d=$(mktemp -d "${TMPDIR:?}/pm.XXXXXX") && cd "$d" && git init -q`, which stops before `git init` when `TMPDIR` is unset or `mktemp` fails; the plan's own `;` form ran `git init` in the current directory then — final review, low, fixed in this record), start `claude` and ask "Call EnterPlanMode, then ExitPlanMode with exactly the plan text `L1 probe`. Write no file."; list `~/.claude/plans` before and after. Settled by: whether ExitPlanMode took the text without a Write, whether a file appeared under `~/.claude/plans` (name, content), what the dialog showed. Each live test ends with `rm -rf "$d"`. The payload claim it settles: the plan-mode dialog can carry the master's approval, and whether ExitPlanMode takes the plan as text (`glab:manager` *Approval in Claude Code's plan mode*, `README.md`; `[flow-master-plan/evidence.md F12]`, `F17`). Not run as of `0cbf5b0`; the manager carries the results into a record (`[flow-master-plan/plan.md FU7]`, open).
- [flow-master-plan/plan.md L2] UNVERIFIED — `plansDirectory`. Steps: write `$d/.claude/settings.local.json` as `{"plansDirectory": "plans-l2"}` by hand, restart `claude`, repeat L1. Settled by: where the plan file landed, and under which name. Settles: where the plan file lands and how `plansDirectory` moves it (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L3] UNVERIFIED — the dialog's three answers. Steps: L1 three times — approve; "No, keep planning" with `change one line`; Ctrl+G, add a line, approve — each time asking the model to quote the ExitPlanMode result. Settled by: whether the result carries the feedback and the edit, and whether Shift+Tab then leaves plan mode. Settles: what "No, keep planning" and a Ctrl+G edit pass on, and leaving plan mode by Shift+Tab (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L4] UNVERIFIED — the permission mode after approval. Steps: approve through each mode the dialog offers. Settled by: the footer's mode afterwards, and whether the session's earlier mode is offered. Settles: that the dialog sets the session's permission mode from then on — the one-line warning the manager gives first (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L5] UNVERIFIED — writes in plan mode. Steps: in plan mode, ask "Write `l5a.txt` here", then "Dispatch a general-purpose subagent to write `l5.txt` here." Settled by: any refusal, and `ls l5*.txt`. Settles: that plan mode blocks the main session's edits and a subagent's — why the manager dispatches no agent in it (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L6] UNVERIFIED — the desktop app. Steps: L1 in the desktop app. Settled by: what the Plan pane shows. Settles: which source the desktop Plan pane shows, UNVERIFIED in `F12`; no payload text rests on it (`FU7`).
- [flow-master-plan/plan.md L7] UNVERIFIED — who has the plan-mode tools. Steps: ask the main session, then a general-purpose subagent, "List your tools whose names contain PlanMode." Settled by: which of the two lists EnterPlanMode and ExitPlanMode. Settles: that no subagent has the plan-mode tools, so only the main session can approve there (`F12`, `F17`; `FU7`).
- [flow-master-plan/evidence.md F12] The plan-mode facts the payload rests on came from a `claude-code-guide` agent reading Claude Code's documentation, relayed by the manager and not re-fetched — inferred; `EnterPlanMode` is in the manager's tool list but not in the docs, and the plan file's name, whether ExitPlanMode takes text, and the desktop Plan pane's source are UNVERIFIED. The planning subagent had neither tool, consistent with L7, not a proof of it. Each point is one of L1–L7 (above).
- [flow-master-plan/evidence.md F16] Inferred from the command text, not run: that `$ARGUMENTS` keeps a `/`, so `/glab:analyze <slug>/<nn>-<name>` reaches the sub-plan's folder through `plan/$ARGUMENTS/` (`commands/analyze.md`, `develop.md`, `integrate.md`); the developer ran no command with a sub-plan slug (`[flow-master-plan/result.md Not done]`).
- [flow-master-plan/evidence.md F11] Inferred from git's pathspec semantics, not run: that this repo's removal checks, `git status --short -uall -- plan/<slug>/` and `git diff --quiet origin/main -- plan/<slug>/`, take the sub-plan folders with them.
- [flow-master-plan/plan.md Milestone] The Markdown has no runtime: the S1–S10 searches, `bash -n`, shellcheck, `PASS 24/24` and `plugin validate` show the text is there, not that a live session follows it — UNVERIFIED, as for every prose rule. The sub-plan cycle, the master hash and Stage 6b have never run; they first run in the next split plan (`[flow-master-plan/plan.md FU9]`). Each `→ 0` search of the plan prints `0` on an untouched tree too, so each is paired with a presence search (`[flow-master-plan/evidence.md F18]`).
- [flow-models-per-role/plan.md I1] UNVERIFIED until the user runs it (it calls models, so it costs; a throwaway `CLAUDE_CONFIG_DIR` is not logged in, `[flow-cheaper-rounds/plan.md D41]`): in the user's own terminal, `claude --plugin-dir ./plugins/glab`, a `glab:committer` dispatch with "run `git status --short`, commit nothing" and no `model` parameter, and a `glab:reviewer` dispatch with `model: haiku` on an empty target; `/tasks` while each runs should name Haiku. Settles: that a live dispatch runs on the frontmatter `model` and that the parameter overrides it — documented (`E1`, `E2`), not shown. Not a precondition of Stage 5; `master.md` *Final check* item 3 and `result.md` *Not done* record it as not run.
- [flow-models-per-role/plan.md E12] UNVERIFIED: that the Agent tool takes `model` ∈ `sonnet|opus|haiku|fable` and `effort` ∈ `low|medium|high|xhigh|max` — read by the planning agent from its own tool definition, which no command prints; the docs give the same alias set (`E1`). The host's `claude --version` was `2.1.310`, above every version floor Rule 5 and Rule 0d name (2.1.211, 2.1.242, 2.1.251, 2.1.257, 2.1.292); `2.1.310` again for this record.
- [flow-models-per-role/plan.md E9] From the docs, not run live: an omitted `tools` inherits every tool available to subagents, and a `tools` list without `Skill` cannot invoke skills (`sub-agents.md:300`, `:629`); `Skill`, `WebFetch` and `WebSearch` are not among the tools subagents lose. The basis of `D5` and `D20`, and of `FU1`.
- [flow-models-per-role/plan.md E6] Proven on a throwaway copy (Claude Code `2.1.310`): `plugin validate --strict` passes `model: sonnett`, and `plugin details` shows no model, so only the model gate catches a typo. Inferred, not verified: that `plugin details` lists agents in an unstable directory read order — the external analyzer's copy listed the two new files last, and the build's run and this record's run both printed `reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer` (`[flow-models-per-role/result.md not-done]`); the gate accepts any order.
- [flow-models-per-role/plan.md E4] From the docs: a subagent on a model other than the main conversation's does not take the session's effort level unless `effort` is passed; levels per model differ, and a model not listed — Haiku 4.5, the `haiku` alias on Bedrock — supports no effort (`model-config.md:620-628`, `:42-50`). Whether Rule 0d's `effort` does anything on a `glab:committer` on such a provider is `FU3`.
- [flow-models-per-role/plan.md Tests] No shell script or test changed; the two suites ran unchanged as gates (`PASS 35/35`, `PASS 24/24`). Coverage as a list: S1–S9 by V1–V9 and the plugin gates; not covered by any case — that a live dispatch runs on the frontmatter model and that the parameter overrides it (I1, the user's), accepted because it calls models; that the prose of each wording adaptation is right is not provable by search (`[flow-models-per-role/result.md unplanned]`). Guards that cannot discriminate: V3 passes on a file that names `CLAUDE.md` for another reason.

## Open follow-ups

- [sync-local-edits/follow-ups.md 7] `commands/develop.md:67`: a `waived.md` has no tier line, so the waiver path has no next stage — reopened: the routing to `/glab:integrate` was removed by the review's scope cut, because a waiver has no plan and no tier, and the integrator, the integrate scope and the review cap need both. A fix has to give a waiver a tier and an integrator input first.
- [sync-local-edits/follow-ups.md 13] `glab:manager` Rule 0c seam note and Stage 1, `glab:plan-first`: "may overrule one" conflicts with Rule 4, where a relayed decision binds and the surface owner has the last word. Suggested: except a line recording another session's decision — open.
- [sync-local-edits/follow-ups.md 14] Stage 1: recording an overrule as a new line leaves steps built on the old choice. Suggested: send the plan back to the planning agent to amend them — open.
- [sync-local-edits/follow-ups.md 15] Rule 3 still reads as "the manager writes the decision line", while Stage 1 says the planner writes it. Suggested: one clause, during planning the planner writes it and the manager reviews it — open.
- [sync-local-edits/follow-ups.md 16] `commands/integrate.md:10`: the integrator agent is never told the normal-tier scope (milestone test only). Suggested: "Say which in the dispatch." — open.
- [sync-local-edits/follow-ups.md 17] `scripts/manager-bootstrap.sh:17`: "-> commit -> push -> record at full tier" (as at `09d2787`; it read "-> push at full tier" when raised) can read as "only at full tier", and Stage 1b is missing. Suggested: "At full tier work moves through plan -> analyze -> develop -> …" — open. Re-read at `0cbf5b0`: the hook text now reads "plan -> develop -> analyze -> integrate -> review -> commit -> final check -> push -> record, as far as the tier runs them" (`[flow-master-plan/plan.md S7]`), so the "only at full tier" reading is gone; Stage 1b is still not named — still open, for that half.
- [bug-reviewer-findings/follow-ups.md 16] `reviewer.md` and `integrator.md` fell back to "the scratchpad" while `CLAUDE.md` and bootstrap said "`$TMPDIR` if set, scratchpad otherwise" — changed since, not shown fixed: both now say "the temp directory the dispatch message names (the scratchpad only if it names none)" (`reviewer.md:73`, `integrator.md:39` at `6838133`); whether that agrees with bootstrap's wording was not re-checked.
- [bug-reviewer-findings/follow-ups.md 18] Cosmetic: `agents/developer.md:15` calls the fallback file "the working agreement" in passing; `commands/commit.md:6` has two dashes in a row — open: re-read at `6838133`, `commit.md:6` still reads `— say so) — the commit format`, and `developer.md:15` still reads `(or CLAUDE.md if the repo has none — say so) — the working agreement`.
- [bug-reviewer-findings/follow-ups.md 19] Bootstrap's grep hazard ("leading alternation returns zero matches") did not reproduce in three attempts and is worded as observed — open: `bootstrap/SKILL.md:156` (at `09d2787`; `:151` at `6838133`) still reads "observed returning **zero matches with no error**".
- [bug-reviewer-findings/result-review1-prose.md L109] Bootstrap's one-line check could name the host file as a fifth item — open, not asked for: at `6838133` it names four (agreement and constants, gates, stage, what the previous session left).
- [bug-reviewer-findings/result-slice2.md L99] `agents/reviewer.md`'s description (`:3`) still speaks of `AGENTS.md` only, beside the `CLAUDE.md` fallback in its body — open, cosmetic.
- [feature-docs-specs/follow-ups.md 2] `agents/analyzer.md:56` and `agents/developer.md:98`: the record reads every file of `plan/<slug>/`, untracked ones included, so a scratch file holding host values could reach a committed spec (`glab:security`). Suggested: read `git ls-files -- plan/<slug>/` and name any untracked file in the report instead — open, for one small payload change of its own.
- [feature-docs-specs/follow-ups.md 4] `skills/bootstrap/SKILL.md:125`: "what a finished change left open is there, not in `plan/`" is wrong in a repo that keeps its plans, which is `glab`'s default. Suggested: "is there; `plan/` may still hold the working files" — open.
- [feature-docs-specs/follow-ups.md 7] Commits rule: `fed95f9` holds two logical changes of the payload, the Stage 8 record and the re-pointed citations, committed as one under `0.5.0` — open, an advisory of review round 3/3; nothing to undo now, a reminder for the next payload change.
- [feature-docs-specs/result-SM.md 3] Facts the specs state as of their record that move with their owners and that no gate ties to the specs (`[feature-docs-specs/plan.md D10]` accepts this): `PASS 35/35` and `PASS 49/49`, the allowlist and DeepSeek's end date, 2026-10-31, the `glab` version — open: each record has to re-read them; re-read by `feature-codex-agent`'s record: `PASS 71/71` at `9108ac7`, `glab` `0.6.0`, the allowlist and its end date unchanged; by `feature-external-developer`'s: `PASS 84/84` at `33a28df`, `glab` `0.7.0`, the allowlist unchanged; by `fix-external-agent-claims`'s: `PASS 86/86` at `3965622`, `glab` `0.7.1`, the allowlist unchanged; by `subagent-effort`'s: `PASS 35/35` and `PASS 86/86` at `abda43a`, `glab` `0.7.2`, the allowlist unchanged (the change touched neither the script nor its tests); by `remove-external-agents`'s: `PASS 35/35` at `467b7c4` (run for this record), `glab` `0.8.0`, and `PASS 86/86`, the allowlist and DeepSeek's end date gone with the script and its test, so what is left to re-read is the `memory-sync` count and the versions.
- [subagent-effort/plan.md F1] `glab:manager` *When subagent dispatch is not available* says how a stage session is started on the recorded model but not at the recorded effort; whether `claude` takes an effort at start was not checked — open.
- [subagent-effort/result.md finding-4] Review round 1's finding 4: `commands/commit.md`, `commands/analyze.md` and `commands/integrate.md` dispatch an agent and do not mention the effort; accepted as-is under `[subagent-effort/plan.md D4]` (commands change only where they list Agent tool parameters), not fixed — open. Re-read at `517b7b6`: since `09d5664` the three say their agent is "dispatched as `glab:manager` Rules 0d and 5 say" (`[flow-models-per-role/result.md R2.10]`), a citation of Rule 0d, not the word effort; `flow-models-per-role`'s `## Record` does not close it — still open.
- [subagent-effort/record.md round-2-ultra] Review round 2 advisory, carried from the manager's Stage 8 dispatch record (no review file is in the folder): `skills/manager/SKILL.md` Rule 0d (`:71` at `abda43a`) has the manager ask which level the user means when they name `ultra` for an Agent tool dispatch, but does not say how far that answer reaches — for that dispatch only, or for the session; Codex still takes `ultra` — open. Re-read at `467b7c4`: Rule 0d (`:71`) still does not say how far the answer reaches; Rule 0d's Codex sentence is gone with Rule 6, so "Codex still takes `ultra`" is history — still open.
- [subagent-effort/record.md round-2-pipeline-default] Review round 2 advisory, from the same dispatch record: *The pipeline*'s handoff sentence (`skills/manager/SKILL.md:189` at `abda43a`) says the effort is "the level you passed" and does not name `effort default`, which Rule 0d (`:67`) has the handoff line carry when the Agent tool rejects or does not offer `effort` — open. Re-read at `467b7c4`: the sentence (`:173`) now ends "The effort is the level you passed." and still does not name `effort default` — still open.
- [flow-cheaper-rounds/plan.md FU3] The user-level copies under `~/.claude` — the user ports them (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU4] The "cleanup glob deleted a reviewer report" incident (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU8] Snapshot limits: a nested repository is recorded as a gitlink with a warning and a large untracked directory that is not ignored is hashed in full (not tested); a repository with no commit yet gets no tree id (`git read-tree HEAD` fails), so its rounds run whole; a file force-added to the index but not committed that matches `.gitignore` is still missed — open.
- [flow-cheaper-rounds/plan.md FU11] Whether the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 — UNVERIFIED, open. An older CLI still gets the `prompt` line, and the handoff line then uses it (`D38`).
- [flow-cheaper-rounds/plan.md FU12] `claude plugin details` labels every hook "harness-only — no model context cost", which is not true of one that returns `additionalContext`: the CLI's wording, to report upstream if anyone wants to — open.
- [flow-cheaper-rounds/plan.md FU13] A `PreToolUse` hook on `Agent` that refuses (`permissionDecision: "deny"`) a dispatch missing `effort` or the `AGENTS.md` instruction — the coordinator's follow-up, not planned; whether the Agent `tool_input` carries `effort` is UNVERIFIED — open. The same item as `[flow-cheaper-rounds/follow-ups.md FUd]`.
- [flow-cheaper-rounds/plan.md FU14] An assistant entry longer than the 8 MiB window is not seen (`D32`): an older call's figure, or silence. Widen the window or read backwards if it is ever seen — open.
- [flow-cheaper-rounds/plan.md FU15] Whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks — UNVERIFIED, open.
- [flow-cheaper-rounds/plan.md FU16] The hooks the user did not choose — `PostToolBatch`, `SubagentStop` — recorded by D28 and D29, not planned — open.
- [flow-cheaper-rounds/plan.md FU17] Whether the desktop app shows a `Stop` hook's `systemMessage` as the terminal does (I1 shows the terminal only) — UNVERIFIED, open.
- [flow-cheaper-rounds/plan.md FU18] Which plugin's `Stop` hook ended `cancelled`, exit 1, in I1a, and whether an installed `memory-sync` sync is cut off whenever a `claude -p` run exits — UNVERIFIED, open; a question for the `memory-sync` plugin, not acted on here (`docs/specs/memory-sync.md`).
- [flow-cheaper-rounds/follow-ups.md FUa] The *One fact* entries "the manual model rule" and "the session effort" in `AGENTS.md` both name the handoff-line format (`plugins/glab/skills/manager/SKILL.md` Rule 5 and *The pipeline*, `commands/develop.md`, `review.md`, `ship.md`). The line now ends `· context <n>k` and Rule 5's example reads `round 1/2`, but those commands do not show the line's full form, so nothing disagrees today, while the two entries do not list the context field. Decide whether the context field joins them — open. Re-read at `517b7b6`: "the manual model rule" is now "the model per role", naming `model <alias>` on every agent stage's handoff line and four more commands (`docs/specs/marketplace.md`); neither it nor "the session effort" lists the context field — still open.
- [flow-cheaper-rounds/follow-ups.md FUb] Payload text cites a plan file: `plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh` and `plugins/glab/skills/manager/SKILL.md` cite `[flow-cheaper-rounds/plan.md F23]` (and the script `[flow-cheaper-rounds review round 1]`). The plan folder is removed after the record and is never part of an installed plugin, so an installer cannot follow the citation; it stays readable only through `git show <sha>:…` (cf. `[feature-docs-specs/plan.md D8]`: payload cites the spec, never a `plan/` path). Decide whether payload cites the area spec instead — open (review round 1, advisory).
- [flow-cheaper-rounds/follow-ups.md FUd] The manager's: a `PreToolUse` hook on `Agent` that refuses a dispatch missing `effort` or the `AGENTS.md` instruction (`[flow-cheaper-rounds/plan.md FU13]`), so Rule 0d and Rule 0c are enforced rather than remembered — open.
- [flow-planner/plan.md FU3] A size warning for a subagent's own context: needs proof that hooks fire inside a subagent, and with which `transcript_path` — open, UNVERIFIED.
- [flow-planner/plan.md FU4] Whether a settings file's `env` block reaches a plugin hook, so `GLAB_COMPACT_AT` could be set there — open, UNVERIFIED.
- [flow-planner/plan.md FU5] The manager's own gate runs could use the developer's log template (*Keep your context small*) — open.
- [flow-planner/plan.md FU8] Which other names the Write rule refuses (`summary.md`, `report.md`) is untested (`[flow-planner/evidence.md F8]`) — open.
- [flow-planner/follow-ups.md FD2] `plugins/glab/scripts/context-size.sh` l. 37: the contract comment's `GLAB_COMPACT_AT` sentence sits as its own unwrapped line between two wrapped ones, so the plan's searched phrase stays on one line; no reflow was done, since no step named one — open, cosmetic.
- [flow-master-plan/plan.md FU7] L1–L7 are unverified until the user runs them; if ExitPlanMode needs a file and `plansDirectory` stays default, plan-mode approval stays unused — open (*Known limits*, L1–L7).
- [flow-master-plan/plan.md FU9] The first split plan first runs the sub-plan cycle, the hash and Stage 6b; its record says what they cost and caught — open.
- [flow-master-plan/follow-ups.md DEV1] `plugins/glab/skills/manager/SKILL.md` Stage 8 dispatch bullet reads "from the folder's files, sub-plan folders included and the audit file" with no comma after "included", unlike `developer.md`'s "sub-plan folders included,"; built as the plan wrote it — open, a one-character wording fix.
- [flow-master-plan/follow-ups.md DEV2] `glab:manager` *Pick the tier* table: the row `Approval, after 1b` sits above the `1b` row, and `6b Final check` after `5 Review` and before `6–7 Commit, push`, as the plan placed them; whether the row order should follow the stage order — open.
- [flow-master-plan/follow-ups.md DEV3] `AGENTS.md` *One fact* round-caps entry names the final check, but of the files it lists only `plugins/glab/skills/manager/SKILL.md` states the final check's cap; `agents/analyzer.md` *The final check* names round 2 but no cap, and the reviewer files stay untouched by decision (D32). The value, 2, agrees wherever it is stated; whether each listed file must state it — open, for a later plan.
- [flow-models-per-role/plan.md FU1] A documented gap: every glab agent with a `tools` list but `glab:planner` — `glab:analyzer`, `glab:committer`, `glab:developer`, `glab:integrator`, `glab:reviewer` and the new `glab:plan-analyzer` (`D20`) — lacks `Skill` (`E13`; `command grep -H '^tools:' plugins/*/agents/*.md` at `517b7b6`, run for this record, prints `Skill` on `planner.md` only), and the docs say such an agent cannot invoke skills (`E9`), yet Rule 0c's dispatches tell them to load `glab:security` and `glab:comments` (`reviewer.md:15`: "if they are available"). Review finding R2.3 raised it again for `glab:plan-analyzer`, `glab:analyzer` and `glab:reviewer`; the manager kept D20 and left it here, one follow-up for a separate change (`[flow-models-per-role/result.md R2.3]`); `glab:planner` left the gap when R2.2 gave it a `tools` line with `Skill`. Fix: add `Skill` to each `tools`, or a `skills:` field (`E9`) — open.
- [flow-models-per-role/plan.md FU2] Mapping agents and other definition-less agents run on the main conversation's model (`D19`); a mapping-agent definition with a table model is the user's call — open.
- [flow-models-per-role/plan.md FU3] A `glab:committer` on `haiku` where the provider's Haiku takes no effort (`E4`): Rule 0d's `effort` then does nothing; not checked live — open.

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
- [flow-cheaper-rounds/plan.md FU7] Stage 5 did not say how a review round after the first learns what changed since the last one (`reviewer.md` had the reviewer ask, `ship.md` had the caller scope it) — closed in Stage 1b round 1 by `D51`: Stage 5, `agents/reviewer.md` and `commands/ship.md` now give the new reviewer the previous findings and the range of the fix.
- [flow-cheaper-rounds/plan.md FU9] Whether `CLAUDE_CODE_SESSION_ID` and the transcript layout hold on other hosts and versions, and whose id a subagent sees — closed as moot in round 2: nothing uses the variable since `D30`; `grep -rl CLAUDE_CODE_SESSION_ID plugins README.md AGENTS.md tests` prints no line (the plan's V10, run by the developer).
- [flow-cheaper-rounds/plan.md FU10] Whether the transcript is flushed before `PostToolUse` and `Stop` run, and how far the figure lags — closed by I1 (`F23`): at `PostToolUse` on `Agent` the calling call is already written; at `Stop` the turn's last call is not, and was there 1 s later; `D61`–`D62` answer it. How far the lag can grow elsewhere is a known limit (above), not a follow-up.
- [sync-local-edits/follow-ups.md 18] `AGENTS.md` *One fact*: the analysis round caps were stated in the manager and bootstrap but not listed — closed by `flow-cheaper-rounds` (`2a1e919`, `D25`): the entry "the round caps" lists all three stages and their five files.
- [sync-local-edits/follow-ups.md 19] After a normal-tier review fix the develop handoff re-ran integrate and review while the manager said the gates were the only check on that fix, and `/glab:ship` had no normal-tier exception — closed by `flow-cheaper-rounds` (`2a1e919`) as the plan's `F11` reads it: the cap is now one at every tier, so a normal-tier review fix gets a round 2, and `/glab:ship` states the same cap with no tier exception. The record did not re-read the line numbers the item cites (`commands/develop.md:67`, `commands/ship.md:32`).

- [flow-cheaper-rounds/plan.md FU2] Splitting the implementation steps (5–7) out of `glab:plan-first` — closed by `flow-planner` (`2912002`, `glab` 0.10.0; `[flow-planner/plan.md FU2]`, S1): Steps 5–7 and the three implementation-only repo rules are in `plugins/glab/skills/plan-first/implement.md`, numbers kept.
- [flow-cheaper-rounds/plan.md FU6] `glab:plan-first` prescribed `findings.md` at full tier, but a subagent planner's Write is refused that name — closed by `flow-planner` (`2912002`; `[flow-planner/plan.md FU6]`, S1, S2, S4, S5): the file is `evidence.md`, which a subagent's Write accepts (`[flow-planner/evidence.md F8]`), and every reader still accepts `findings.md` in an older folder (*Incidents*, the fourth and fifth refusal).
- [flow-planner/plan.md FU2] `[flow-cheaper-rounds/plan.md FU2]`, Steps 5–7 out of `glab:plan-first` — closed by S1 (above).
- [flow-planner/plan.md FU6] `[flow-cheaper-rounds/plan.md FU6]`, a subagent cannot write `findings.md` — closed by `evidence.md` (S1, S2, S4, S5; `[flow-planner/evidence.md F8]`).
- [flow-planner/follow-ups.md FD1] `context-size.sh` l. 37: the contract sentence the plan prescribed, "the run goes on with the default and still prints its JSON", was loose for `stop` below a step, where nothing prints — closed in review fix round 1 on the manager's instruction: it reads "prints on stdout what it would print with the variable unset - one JSON object or nothing"; no other file carried the sentence (`[flow-planner/result.md FD1]`).
- [flow-cheaper-rounds/plan.md FU5] `agents/analyzer.md` has no plan-check mode: `BUILDABLE` / `NOT BUILDABLE` appear only in `skills/manager/SKILL.md`, and its Steps 2–3 are written for an implementation — closed by `flow-master-plan` (`0cbf5b0`, `glab` 0.11.0; `[flow-master-plan/plan.md D35]`, S4): `agents/analyzer.md` has *The plan check — `glab:manager` Stage 1b*, skips Step 2 there, and lists `BUILDABLE` and `NOT BUILDABLE` among its verdicts.
- [flow-planner/record.md review-waiver-implement] Review advisory, carried from the manager's Stage 8 dispatch (no review file is in the folder), for the later plan `flow-master-plan`: `glab:plan-first`'s waiver paragraph (`plugins/glab/skills/plan-first/SKILL.md:122` at `2912002`) says "Then implement, from `implement.md`", but `implement.md` (l. 3) says to start Steps 5–7 "only once the plan is verified (Step 4) and, at full tier, approved" — a condition a waived task, which has no plan, cannot meet — closed by `flow-master-plan` (`0cbf5b0`; `[flow-master-plan/plan.md D47]`, S1, S9): `implement.md` l. 3 now starts Steps 5–7 "once the plan is verified and approved (`glab:plan-first` Step 4), or once `plan/{slug}/waived.md` records a waiver (*User Override* in `SKILL.md`), which stands in for both", and the waiver paragraph says the waiver "stands in for the verified, approved plan it asks for".
- [flow-planner/record.md review-t19-comment] Review advisory, from the same dispatch, for `flow-master-plan`: the T19 comment in `tests/context-size.test.sh` (l. 335 at `2912002`) reads "judged over every stop run above, T20's and T21's included", but T24's `stop` run now feeds `stopouts` too (review fix round 1, `[flow-planner/result.md R4]`), and T23's runs through `stop_case` — closed by `flow-master-plan` (`0cbf5b0`; `[flow-master-plan/plan.md D47]`, S10): the comment (l. 335) reads "judged over every stop run above: T18's, T20's, T21's and T23's through stop_case, and T24's own"; one line out, one in, `PASS 24/24`.
- [flow-cheaper-rounds/plan.md FU1] A dedicated `glab:planner` agent (out of scope by the brief) — open; carried since `glab` 0.10.0 as `[flow-planner/plan.md FU1]`, into `flow-models-per-role`. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0; `[flow-models-per-role/plan.md D4]`):** `plugins/glab/agents/planner.md` exists, `model: opus`, and `/glab:plan` dispatches it.
- [flow-planner/plan.md FU1] A `glab:planner` agent and the analyzer's two kinds — into `flow-models-per-role` (`[flow-planner/plan.md D9]`, `D21`; carries `[flow-cheaper-rounds/plan.md FU1]`) — open. Re-read at `0cbf5b0`: `[flow-master-plan/plan.md D36]` keeps one analyzer with every kind of check and leaves the split to `flow-models-per-role` — still open. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0; `[flow-models-per-role/plan.md D4]`, `D6`):** `glab:planner` and the two analyzer kinds, `glab:plan-analyzer` and `glab:analyzer`; `Agents (7)`.
- [flow-cheaper-rounds/follow-ups.md FUc] **The user's, 2026-10-20:** the next plan `flow-models-per-role` — a model per role (planner and plan check Opus; conformance and record check Sonnet; developer, reviewer, integrator Sonnet; committer Haiku) and two kinds of analyzer; it extends `glab:manager` Rule 5 beyond the developer and reviewer — open, not planned. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0):** the table ships as each agent's frontmatter `model` (`[flow-models-per-role/plan.md D2]`, the user's "Default", `[flow-models-per-role/questions.md Q1]`), the analyzer is two kinds (`D6`), and Rule 5 covers every role (`D9`); the model gate prints the seven lines.
- [feature-docs-specs/follow-ups.md 5] `skills/manager/SKILL.md:127` against Stage 8's "not in `plan.md`": a model the user names for the record's developer has nowhere to be recorded. Suggested: one clause in Rule 5 — for Stage 8 the instruction lives in the conversation only, as for a `/glab:review` with no plan — open. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0; `[flow-models-per-role/plan.md D12]`):** Rule 5's *Record it before the next dispatch* now reads "A `/glab:review` or `/glab:ship` with no plan behind it, and the Stage 8 record's agents, have nowhere to record it: the instruction lives in this conversation only".
- [flow-models-per-role/plan.md FU4] `docs/specs/marketplace.md` and `workflow.md` restated `Agents (5)` and Rule 5 as of their records — closed by this record (`master.md` *Record*): both specs now state `Agents (7)` and the reworded Rule 5 as of `517b7b6`.
- [flow-models-per-role/result.md FUa] `manager/SKILL.md` Rule 5, *Record it*, still gave `"use sonnet for the developer"` as its example `- model:` line, an override that changes nothing once the developer's default is `sonnet` (found while building, out of scope of S5 (f)) — closed in review round 1 by R2.7: the example is now `- model: glab:reviewer opus, … "use opus for the reviewer"`.
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
- **`stop` as built never spoke in a live session** (`flow-cheaper-rounds`, integration I1b, 2026-10-20; IN1, `[flow-cheaper-rounds/plan.md IN1]`): at `Stop` the transcript holds the turn's prompt but not yet its last call, so with one call per turn the latest written figure equalled the size at the turn's prompt and the step could never rise. A debug wrapper at `Stop` and one second later showed it: turn 1 `no usage in the transcript` then `54k`; turns 2 and 3 silent, the transcript still ending with the previous turn's 54k, then `54k`. Every T18 fixture held the turn's last call, so the test passed `19/19` on a script that could not work; the docs' "may lag" had been marked UNVERIFIED and left to I1. Fixed by `D61`–`D62` (the base is the real prompt before the last one); T20 reproduces the lag without a model and fails the earlier script (`FAIL 3/21`). The same I1 run showed the display itself works (a wrapper that always printed a `systemMessage` was shown on both turns), so the fallback (drop `stop`) did not apply. The re-run on the rebuilt script (I1c, the user's interactive Claude Code 2.1.304 session, thresholds lowered to 1000/1000 in a throwaway copy) passed, as observed by the manager from the user's screenshot: turn 1 silent; turn 2 showed `Stop says: glab: context 48k (last completed call) — a good point to /compact, or to /clear between tasks` and the turn ended there; turn 3 silent. Lesson: a hook's fixture is the file as it stands when the hook runs, not as it stands after.
- **The installed plugins load beside `--plugin-dir` in the user's own config** (`flow-cheaper-rounds`, integration I1a; IN2, `[flow-cheaper-rounds/plan.md IN2]`): the plan said no `memory-sync` hook runs under `--plugin-dir ./plugins/glab`; in the user's own config a second `Stop` hook ran and ended `cancelled`, exit 1, when `-p` exited. Which plugin's it was is UNVERIFIED (inferred: the installed `memory-sync`'s network sync cut off when `-p` exited; `context-size.sh` exits 0 in about 0.07 s) — `[flow-cheaper-rounds/plan.md FU18]`. The earlier proof that `--plugin-dir ./plugins/glab` loads `glab` alone was under an empty config only (`docs/specs/marketplace.md`, *Testing without installing*).
- **A file named `findings.md` and `findings-probe.md` were refused for a subagent a third time** (`flow-cheaper-rounds`, the planning session): the Write tool answered "Subagents should return findings as text, not write report files" for both and accepted `map-probe.md`, which was then removed; the plan therefore names mapping files `map-<area>.md` (`D15`) and the plan's findings are its *Findings* section.
- **Review round 1/1 of the built change returned `SHIP` with one low finding** (`flow-cheaper-rounds`, `[flow-cheaper-rounds/result.md review-fix-1]`, under *Known limits*): the script header's "twice at most" was not true with fewer than two prompts in the window; fixed by comment only.
- **A file named `findings.md` was refused a fourth and a fifth time, and the plan's findings file was renamed** (`flow-planner`, 2026-10-22; IN1, `[flow-planner/plan.md IN1]`): the Write tool refused `plan/flow-planner/findings.md` to the planning subagent — "Subagents should return findings as text, not write report files" — in round 1 and again in round 2's probe, which accepted `evidence.md` and five other names (`[flow-planner/evidence.md F8]`). After three refusals worked around by a *Findings* section, `glab` 0.10.0 names the file `evidence.md` in the payload (`[flow-planner/plan.md D1]`, `D38`); this closes `[flow-cheaper-rounds/plan.md FU6]`. The folder holds `evidence.md` and its round copies `evidence.r2.md`, `evidence.r3.md`, and no `findings.md`.
- **A planning agent died mid-amendment on an API 403** (`flow-master-plan`, 2026-10-22; carried from the manager's Stage 8 dispatch — no file in the plan folder records it): the agent amending the plan after plan check round 1 stopped on an API error, HTTP 403 `oauth_org_not_allowed`, with its edits to the plan files written but unverified and two temp files left under the temp directory. Nothing was trusted on the dead agent's word: the round-2 plan check, a new analyzer, verified the edits (the versions round 1 checked are kept as `plan.r1.md` and `evidence.r1.md`); the two temp files, `fmp-checks.<pid>.sh` and `fmp-out.<pid>.txt`, which the developer later found and left as not its own (`result.md` *Not done*), were removed by the manager. Lesson: an agent that dies mid-write leaves a half-amended plan that looks finished; the delta check of the next round, not the agent's report, is what shows what landed.

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
- 2026-10-20 · flow-cheaper-rounds · seven changes to cut the pipeline's token cost: round caps of 2 (+1 on a `critical` or `high` finding) for Stages 1b, 3 and 5, every round a new agent, delta re-checks, a narrower planner search, explore once through `map-<area>.md`, the manager's context rule, and the `context-size.sh` hook on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop`; the `severity:` line, the analyzer's re-check section, the developer's fix-round section; the handoff line's `· context <n>k`; `glab` 0.9.0 · change 2a1e919 · plan: `git ls-tree -r --name-only 2a1e919 -- plan/flow-cheaper-rounds/` (one file: `git show 2a1e919:plan/flow-cheaper-rounds/<file>`; the whole folder: `git archive 2a1e919 plan/flow-cheaper-rounds/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `2a1e919` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-cheaper-rounds/`): one `docs(repo)` commit after this record removes it. The folder holds `plan.md` and its three earlier versions `plan.r1.md`, `plan.r2.md` and `plan.r3.md` (round copies: the record takes its items from `plan.md`), `result.md` and `follow-ups.md`.
  - [flow-cheaper-rounds/plan.md L55] Decisions → `[flow-cheaper-rounds/plan.md D1]` to `D65` and `model` and `effort`, above under *Decisions that still bind*, each in its own line; the user's are D2, D29 and `model`, the manager's choices D3, D49–D54 and D61 (the user may overrule D3, D54 and D61).
  - [flow-cheaper-rounds/plan.md L129] Findings → `F1` (the measured evidence) and `F8`, `F9`, `F15`, `F18`, `F20`, `F23`, `F24` under *Known limits and not verified*; `F2`–`F7`, `F10`–`F14`, `F16`, `F17`, `F19`, `F21`, `F22` were that change's searches, baselines and prototypes, and their conclusions are in the decisions they support (`D4`, `D7`, `D10`–`D12`, `D14`, `D31`, `D32`, `D45`, `D49`–`D50`, `D58`).
  - [flow-cheaper-rounds/plan.md L1023] Follow-ups → `FU1` to `FU18`: `FU1`–`FU6`, `FU8`, `FU11`–`FU18` open, `FU7`, `FU9`, `FU10` closed, above.
  - [flow-cheaper-rounds/plan.md L1044] Incidents → `IN1` and `IN2`, above under *Incidents*; `[flow-cheaper-rounds/plan.md FU18]` open.
  - [flow-cheaper-rounds/plan.md L1049] Record → this record, in this file and `docs/specs/marketplace.md`; `[sync-local-edits/follow-ups.md 18]` and `[sync-local-edits/follow-ups.md 19]` closed; `[bug-reviewer-findings/questions.md Q3]` and `[sync-local-edits/result-followups.md D11]` marked superseded by `D2`.
  - [flow-cheaper-rounds/result.md L5] Stages and Blocked (`L25`) → every step S1–S17 done, nothing blocked. Unplanned changes (`L29`) → implementation choices inside S13, not behaviour changes: the `jq` program reads token fields through `numbers` and emits through `floor`, and the shell accepts only 1 to 15 digits before any bash arithmetic (`[flow-cheaper-rounds/result.md digit-guard]`); two wording choices to satisfy the plan's own searches.
  - [flow-cheaper-rounds/result.md L35] Tests → `tests/context-size.test.sh`, 21 cases at `PASS 21/21` (19 before the fix round, `L178`); `tests/memory-sync.test.sh` unchanged at `PASS 35/35`; the one uncovered branch → `[flow-cheaper-rounds/result.md digit-guard]`, under *Known limits*.
  - [flow-cheaper-rounds/result.md L161] Security blast radius → `D35`, `D36`, `D44`, `D46`: the hook writes no file, keeps no state, opens no network connection, prints only an integer and fixed words, and cannot block or continue a turn; roll back by `git revert`, which raises `glab` to `0.9.1`.
  - [flow-cheaper-rounds/result.md L172] Not done → I1 and I1c, the user's runs, and that a live session follows the new prose → `[flow-cheaper-rounds/plan.md F23]` and `[flow-cheaper-rounds/plan.md F1]` (*Inferred, not shown*), under *Known limits*.
  - [flow-cheaper-rounds/result.md L178] Fix round 1 — I1 stop lag (S13.1, S13.4, S13.5, S14.2, S14.3, one sentence of S1.16, one of S16.3; the `stop_spec` helper in the test is an implementation choice) → `D61`–`D65`; Review fix round 1 (`L288`, comment only) → `[flow-cheaper-rounds/result.md review-fix-1]`.
  - [flow-cheaper-rounds/follow-ups.md L1] Follow-ups → `[flow-cheaper-rounds/follow-ups.md FUa]`, `FUb`, `FUc`, `FUd`, open, above.
- 2026-10-22 · flow-planner · cheaper plans and developers: `evidence.md` in place of `findings.md` (older folders still read), a 48 KB budget for `plan.md` and `evidence.md` with the manager's size check, amendments replaced in place, `glab:plan-first` Steps 5–7 moved to `implement.md`, the developer's *Keep your context small*, and `GLAB_COMPACT_AT` for the context hook's first step with tests T22–T24; `glab` 0.10.0 · change 2912002 · plan: `git ls-tree -r --name-only 2912002 -- plan/flow-planner/` (one file: `git show 2912002:plan/flow-planner/<file>`; the whole folder: `git archive 2912002 plan/flow-planner/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `2912002` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-planner/`): one `docs(repo)` commit after this record removes it. The folder holds `plan.md` and its earlier versions `plan.r1.md`, `plan.r2.md`, `plan.r3.md`, `evidence.md` and its earlier versions `evidence.r2.md`, `evidence.r3.md` (round copies: the record takes its items from `plan.md` and `evidence.md`), `result.md` and `follow-ups.md`.
  - [flow-planner/plan.md D1] Decisions → `D1`–`D22`, `D38`, `D41` and `effort`, above under *Decisions that still bind*, each in its own line; the user's are D9, D10, D12 and D21. Amended in earlier records, marked in place: `[flow-cheaper-rounds/plan.md D10]` and `D49` (by D38), `D45` and `D47` (by D12).
  - [flow-planner/evidence.md F0] Evidence → `F2`, `F4`, `F5`, `F8` under *Known limits and not verified*, `F8` also extending `[flow-cheaper-rounds/plan.md F9]`; `F0`, `F1`, `F3`, `F6`, `F7`, `F9`, `F11`, `F14` were that change's scope, measurements, searches and baselines, and their conclusions are in the decisions they support (`D2`, `D9`, `D21`, `D38`). *Boundary* `B1` and `B2` → `D8`, `B4` → `D13`; `B3`, rejected: a `PreToolUse` hook refusing an oversized `plan.md`, because it fires in every repo with `glab` enabled and stops a planner mid-write.
  - [flow-planner/plan.md FU1] Follow-ups → `FU1`, `FU3`, `FU4`, `FU5`, `FU8` open; `FU2` and `FU6` closed, with `[flow-cheaper-rounds/plan.md FU2]` and `FU6`; `[flow-cheaper-rounds/plan.md FU1]` re-pointed to `FU1`; `FU7` and `FU9` belong to `flow-master-plan`, not recorded here.
  - [flow-planner/plan.md IN1] Incidents → `IN1`, above under *Incidents*.
  - [flow-planner/plan.md S8] Record → this record, in this file and `docs/specs/marketplace.md` (the *One fact* changes, `glab` `0.10.0`, the gates' `PASS 24/24`); no audit file.
  - [flow-planner/result.md B0] Result → every step (B0, S1, S2, S4, S5, S7, S8, *After*) done, nothing blocked, no unplanned change in the build (fix round 1's five, R1–R4 and FD1, are below); tests T22–T24 added, `PASS 24/24`, `FAIL 3/24` against the `cf614ec` script, `tests/memory-sync.test.sh` unchanged at `PASS 35/35`; the one uncovered branch → `[flow-planner/plan.md S7]`, under *Known limits*; the inferred items → `[flow-planner/evidence.md F2]` and `F5`.
  - [flow-planner/result.md R1] Fix round 1 (review round 1 findings 1–4 and the manager's FD1) → `R1` (blocking: the log template's braces) and `R3` (the waiver points at `implement.md`) in *How it works now*, `R2` (the smaller-window bullet only when the line names no `compact at <t>k`) in *The context rule*, `R4` (T24's `stop` run judged by T19) in `[flow-planner/record.md review-t19-comment]`, `FD1` closed.
  - [flow-planner/follow-ups.md FD1] Follow-ups (developer) → `FD1` closed, `FD2` open, above.
  - Review advisories for `flow-master-plan`, from the manager's Stage 8 dispatch (no review file is in the folder) → `[flow-planner/record.md review-waiver-implement]` and `[flow-planner/record.md review-t19-comment]`, open; both closed since by `flow-master-plan` (`0cbf5b0`).
- 2026-10-22 · flow-master-plan · the master plan and sub-plans: every plan folder starts with a constant, hashed `master.md` (the request verbatim, the goals, the final check, the record), one `plan.md` or `index.md` and sub-plan folders that each run their own cycle and commit; the analyzer's intent question at Stage 1b, Stage 3 and the new Stage 6b final check, and its own plan check with `BUILDABLE` and `NOT BUILDABLE`; the user's approval after Stage 1b, in plan mode only when asked, its claims UNVERIFIED until L1–L7; `## Record` in the master; the stage listings with the final check; the two `flow-planner` advisories closed; `glab` 0.11.0 · change 0cbf5b0 · plan: `git ls-tree -r --name-only 0cbf5b0 -- plan/flow-master-plan/` (one file: `git show 0cbf5b0:plan/flow-master-plan/<file>`; the whole folder: `git archive 0cbf5b0 plan/flow-master-plan/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `0cbf5b0` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-master-plan/`): one `docs(repo)` commit after this record removes it. The folder holds `plan.md` and its earlier versions `plan.r1.md`, `plan.r2.md`, `evidence.md` and its earlier versions `evidence.r1.md`, `evidence.r2.md` (round copies: the record takes its items from `plan.md` and `evidence.md`), `result.md` and `follow-ups.md`; no `master.md`, since the change ran under the 0.10.0 rules it changed (`[flow-master-plan/plan.md D45]`).
  - [flow-master-plan/plan.md D23] Decisions → `D23`–`D37`, `D39`, `D40`, `D42`–`D47`, `effort` and fix round 1's `R1`, above under *Decisions that still bind*, each in its own line; the user's are D23, D32 and D37, the manager's D37's UNVERIFIED rule and D46; D43–D45 and `effort` spent. Marked in place: `[sync-local-edits/result-followups.md D5]` amended by D31, `[feature-docs-specs/plan.md D5]` and `D28` by D39; `[flow-cheaper-rounds/plan.md D2]` extended by D29, `D10` and `D49` by the master and index copies, `[flow-planner/plan.md D2]` by S1; `[flow-cheaper-rounds/plan.md D27]` and `[flow-planner/plan.md D20]` noted with D30, `[flow-planner/plan.md D9]` with D36. D26 amends the manager's order of approval before Stage 1b, which no tagged decision held.
  - [flow-master-plan/evidence.md F0] Evidence → `F11`, `F12`, `F16` under *Known limits and not verified*, `F12` with L1–L7; `F0`, `F3`, `F10`, `F13`–`F15`, `F17`, `F18` were that change's scope, readings, baselines and searches, and their conclusions are in the decisions they support (`D30`, `D32`, `D35`, `D36`, `D40`, `D47`), `F18` also in `[flow-master-plan/plan.md Milestone]`. *Boundary* `B5`–`B12`, rejected alternatives → D24 (`B5`, `B6`), D30 (`B7`), D36 (`B8`), D32 (`B9`), D37 (`B10`), D25 (`B11`), D31 (`B12`).
  - [flow-master-plan/plan.md FU7] Follow-ups → `FU7` and `FU9` open; `[flow-master-plan/follow-ups.md DEV1]`, `DEV2`, `DEV3` open; closed: `[flow-planner/record.md review-waiver-implement]`, `[flow-planner/record.md review-t19-comment]` (D47) and `[flow-cheaper-rounds/plan.md FU5]` (D35); re-read, still open: `[sync-local-edits/follow-ups.md 17]` (half answered by S7) and `[flow-planner/plan.md FU1]` (D36).
  - [flow-master-plan/plan.md L1] Live tests → `L1`–`L7`, the user's, not run, under *Known limits* (written there by fix round 1, `[flow-master-plan/result.md R3]`), each linked to the claim it settles and to `FU7`; the setup line now stops when `mktemp` fails (final review, one low finding, fixed in this record; no review file is in the folder).
  - Incidents → the planning agent that died on an API 403, above under *Incidents*, carried from the manager's Stage 8 dispatch; no file in the folder records it.
  - [flow-master-plan/result.md B0] Result → every step (B0, S1–S10) done, nothing blocked; unplanned changes only re-wraps in `plugins/glab/skills/bootstrap/SKILL.md`, `README.md` and `AGENTS.md`, so each searched phrase sits on one line; no test added, `PASS 35/35` and `PASS 24/24`, S10 one comment line; `$ARGUMENTS` with a `/` → `[flow-master-plan/evidence.md F16]`. Fix round 1 (review round 1) → `R1` and `R2` (blocking) in *How it works now* and the decisions, `R3` (blocking) the L1–L7 entries, `R4`–`R6` (low): the final check's "(the plan, with no index)" in `analyzer.md` and Stage 6b, the analyzer's description, `README.md`'s Stage 1b and Stage 3 sentence; two S1 searches of the plan moved to `0` by R1 and R2.
  - [flow-master-plan/plan.md Record] Record → this record, in this file and `docs/specs/marketplace.md` (the *One fact* changes, the version rule per push, `glab` `0.11.0`); no audit file.
- 2026-11-12 · flow-models-per-role · a model per role: each of the seven `glab` agents' definitions sets its role's model in its frontmatter — `glab:planner` and `glab:plan-analyzer` `opus`, `glab:analyzer`, `glab:developer`, `glab:reviewer` and `glab:integrator` `sonnet`, `glab:committer` `haiku` — shipped to every installer on the user's answer "Default"; Rule 5 reworded (the user's words override any role, no parameter otherwise, an agent with no definition none), `model <alias>` on every agent stage's handoff line, the dispatch table for the default; the new `glab:planner`, dispatched by `/glab:plan`; the analyzer split into `glab:plan-analyzer` (Stage 1b) and `glab:analyzer` (conformance, final and record checks), `/glab:analyze` routing by the check named, then by the folder; `glab` 0.12.0 · change 09d5664 517b7b6 · plan: `git ls-tree -r --name-only 517b7b6 -- plan/flow-models-per-role/` (one file: `git show 517b7b6:plan/flow-models-per-role/<file>`; the whole folder: `git archive 517b7b6 plan/flow-models-per-role/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `517b7b6` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-models-per-role/`): the `docs(repo)` commit that carries this record removes it. The folder holds `master.md`, `plan.md` (normal tier, one page, its evidence the section *Evidence*), `questions.md` and `result.md`; no round copy, no `follow-ups.md` (the build's dispatch limited its writes in the folder to `result.md`), and no `master.sha256` — `master.md` has no `## Approval` section (`/usr/bin/grep -c '^## Approval' plan/flow-models-per-role/master.md` prints `0`), so the folder records neither the master's acceptance nor its hash.
  - [flow-models-per-role/plan.md D1] Decisions → `D1`–`D20`, `effort` and `[flow-models-per-role/questions.md Q1]`, above under *Decisions that still bind*, each in its own line; the user's is Q1 ("Default"), on which D2 and D7–D10 rest; the manager's D5 (review finding R2.2), D8 (R2.4 and the PR #7 review comment), D18 and D20 (kept on R2.3); `effort` spent. Marked in place: `[feature-model-switch/plan.md D2]` and `D8` superseded (by D9 and D2); `[feature-model-switch/plan.md D1]` amended by D2 and D9, `D11` by D11, `D14` by S8, `D20` extended by D10; `[flow-master-plan/plan.md D35]` amended by D6; `[flow-planner/plan.md D9]`, `D21`, `[flow-master-plan/plan.md D36]` and `[flow-cheaper-rounds/plan.md D28]` noted as carried out.
  - [flow-models-per-role/plan.md E1] Evidence → `E4`, `E6`, `E9`, `E12` under *Known limits and not verified*, `E1` and `E2` also in the re-read `[feature-model-switch/plan.md I1]` and `I4`; `E1`–`E3`, `E5`, `E7`, `E8`, `E10`, `E11`, `E13` were that change's readings, baselines and searches, and their conclusions are in the decisions they support (`D3`, `D4`, `D6`, `D13`, `D16`, `D20`), `E7` also in *Agents* above. *Boundary*, rejected: `B1` (the table passed per dispatch from Rule 5, no frontmatter — the default would live in the manager's memory) and `B5` (no planner agent, the generic agent dispatched with `model: opus`) → D2 and D4; `B2` → D6; `B3` (full model IDs) → D3; `B4` (a `/glab:plan-check` command) → D8.
  - [flow-models-per-role/plan.md FU1] Follow-ups → `FU1` (the `Skill` gap of every agent with a `tools` list but `glab:planner`, `glab:plan-analyzer`, `glab:analyzer` and `glab:reviewer` among them, D20 and R2.3), `FU2`, `FU3` open; `FU4` closed by this record; `[flow-models-per-role/result.md FUa]` closed by R2.7; closed, as `master.md` *Record* names: `[flow-planner/plan.md FU1]`, `[flow-cheaper-rounds/plan.md FU1]` (D4, D6), `[flow-cheaper-rounds/follow-ups.md FUc]` (D2, D6, D9) and `[feature-docs-specs/follow-ups.md 5]` (D12); re-read, still open: `[flow-cheaper-rounds/follow-ups.md FUa]` and `[subagent-effort/result.md finding-4]`.
  - [flow-models-per-role/plan.md I1] Live test → `I1`, the user's, not run, under *Known limits* (`master.md` *Final check* item 3: `UNVERIFIED` until run).
  - Incidents → none: no file in the folder records one.
  - [flow-models-per-role/result.md B0] Result → every step (B0, S1–S9, A1, A2) done, nothing blocked; A3 (back out: `git revert <commit>`, installed copies follow only past `0.12.0`) not run; I1 the user's. Unplanned changes (`[flow-models-per-role/result.md unplanned]`) → wording adaptations the steps' literal text forced, no file outside the plan's list: `plan-analyzer.md`'s copied *Step 4* headed *Step 2*, its master-check exceptions, its `BLOCK` for "a check that is not yours"; in `analyzer.md` *Re-checks* the plan-check `diff -u` removed with its file pairs; Rule 5 (f) "as the next bullet says" for "as (g) says", and D12's clause in the same sentence; Rule 5 (c)'s carry list with "each analyze round" and "through a `/glab:` command or directly"; dashes and full stops in Stage 2, Stage 5, `develop.md`, `review.md`, `ship.md` and `plan.md`. No test added; the two suites unchanged (`PASS 35/35`, `PASS 24/24`); coverage → `[flow-models-per-role/plan.md Tests]`. Blast radius (`[flow-models-per-role/result.md blast-radius]`) → every installer that updates to `0.12.0` runs and pays for the table's models; `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the agents; `/glab:plan` dispatches an agent instead of planning in the invoking session; no script, hook, schema or stored format changed. *Not done* (`[flow-models-per-role/result.md not-done]`) → I1, `E12`, and the listing order (`E6`), under *Known limits*.
  - [flow-models-per-role/result.md R1.1] Review round 1 (normal tier, the one round; text fixes only, `glab` stays `0.12.0`) → `R1.1` (`planner.md` "for every amendment"), `R1.2`, `R1.3`, `R2.5`, `R2.6` (wording of the two analyzers' report and re-check lines, `unverified` among the plan-analyzer's statuses), `R1.4` (a stage session's model, *The model rule*), `R1.5` (`plan-analyzer.md` on the mapping/evidence/round-copy *One fact* entry "(all but the version copies)", `docs/specs/marketplace.md`), `R2.1` and `R2.2` (`glab:planner`'s writes and `tools`, D5), `R2.3` not fixed (D20, `FU1`), `R2.4` (`/glab:analyze`'s routing, D8), `R2.7` (Rule 5's "chose them for cost" and the example line, `FUa` closed), `R2.8` (the dispatch table's default row), `R2.9` (`README.md` "From Claude Code v2.1.251"), `R2.10` (the Rules 0d and 5 clause in three commands and two *One fact* entries). V1's second check changed by R2.2 (`planner.md` now has a `tools:` line) and V9's meaning by R2.4; the gates after the fixes green as `AGENTS.md` states them. `AGENTS.md` at `09d5664` also lists `plugins/glab/commands/plan.md` in both entries R2.10 extended, which `result.md` R2.10 says it is in neither; no file in the folder records that addition.
  - PR #7 review → a named plan or master check routes to `glab:plan-analyzer` before the folder test, because an amended plan keeps its earlier `result.md`; fixed in `517b7b6` (`plugins/glab/commands/analyze.md:6`) with D8 updated in place in `plan.md` — *Agents* above. PR #7 merged on 2026-11-12 as `09d5664` and `517b7b6` (`gh pr view 7`).
  - [flow-models-per-role/master.md Record] Record → this record, in this file and `docs/specs/marketplace.md` (the gates' `Agents (7)` and the model gate, the *One fact* changes, `glab` `0.12.0`); no audit file.
