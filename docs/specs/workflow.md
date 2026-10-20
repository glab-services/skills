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
line's `· context <n>k`) as of `2a1e919` (`glab` `0.9.0`); where this file
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
- **The pipeline** (`glab:manager` *The pipeline*): 1 Plan (`/glab:plan`),
  1b Analyze the plan (`/glab:analyze`, plan only), 2 Develop
  (`/glab:develop`), 3 Analyze conformance, 4 Integrate (`/glab:integrate`),
  5 Review (`/glab:review`), 6 Commit (`/glab:commit`), 7 Push
  (`/glab:push`, no push agent), 8 Record (after the push: `glab:developer`
  on the record, `glab:analyzer` on what it carried, then `/glab:commit`; it
  leaves on the record commit verified, then pushed on the user's go-ahead).
  A change with a plan folder goes on from Stage 7 to Stage 8. Each handoff
  is one line, `slug · stage · round n/max · verdict · effort <level> · context <n>k`
  (Rule 0d; `slug · stage · round n/max · verdict` before `abda43a`; the
  `· context <n>k` field since `glab` 0.9.0, `2a1e919`, with
  `· dispatches <d>` in its place only when no `glab: context` line has
  come in the session — *The context rule*, below), with
  `model <m>` after the stage on a develop or review line. `max` is the
  stage's round cap, `2`, or `3` once the round-3 line is written, and a
  develop line counts its fix rounds against the cap of the stage whose
  findings it fixes (`glab:manager` *The pipeline*;
  `[flow-cheaper-rounds/plan.md D24]`). The effort is the
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
  rounds, conformance at most 2 rounds, the whole suite at integrate, review
  at most 2 rounds. **Normal**: everything else — a one-page `plan.md`, no
  approval (the tier and decisions are reported), 1b at most 2 rounds, no
  conformance stage, the milestone test at integrate, review at most 2
  rounds. **Trivial**: Rule 1's five lines, done directly. Each cap can
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
    stated.
  - Rule 0d — every dispatch, to every subagent, passes the Agent tool's
    `effort` parameter at the session's level (*The session effort*,
    below); since `abda43a`.
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
- **Round caps** (`glab:manager` *Pick the tier*, *Round caps*, as of
  `2a1e919`, `glab` 0.9.0). Stage 1b, Stage 3 and Stage 5 each run at most
  **2 rounds** at every tier where the stage runs (normal tier has no Stage
  3). A **third** round runs only when round 2 returned a finding rated
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
  (`AGENTS.md` *One fact*). History, until `glab` 0.9.0: plan analysis 2
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
  `findings.md` to `findings.r<n>.md` when there is one. It tests that the
  amendment changed something by exit code alone, `cmp -s` (0 identical,
  1 changed, 2 a file missing) — an empty delta is a stop, not a pass — and
  never reads the diff itself; only the analyzer of round `<n+1>` runs
  `diff -u`, and checks each previous finding, every changed line and every
  step that rests on one, not the rest of the plan. A copy, not git,
  because the plan folder is untracked while it is planned and a snapshot
  of a gitignored `plan/` would be empty. The copies stay in the folder and
  are committed with it. *Stage 3.* Before each analyze round, round 1
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
  `glab:analyzer` carries a `severity:` line, `critical`, `high`, `medium`
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
  with the plan, the developer the ones the plan cites.
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
  first handoff line at or past **300k**, and again at the first past each
  further **100k**, it brings the handoff file up to date and suggests
  `/compact`; at a task boundary — after the push of the Stage 8 record, or
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
  prompt before the last one. Why the user: a hook fires every time but
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
  planning; since `glab` 0.9.0 also `map-<area>.md` from mapping agents and
  the round copies `<name>.r<n>.md` the manager keeps at Stage 1b (an
  earlier version of a file the folder still holds: a record takes its
  items from the current file); a waiver's folder is recorded like a plan's. The rule is
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
- [flow-cheaper-rounds/plan.md D1] Tier normal for the change — payload text, the `glab` manifest version, `AGENTS.md`, `README.md`, and one read-only hook script with its test; no full-tier trigger. The `severity:` line is a contract between agents that nothing parses (`F13`). Scoping of that change; it governs no later work. Re-checked by D36.
- [flow-cheaper-rounds/plan.md D2] The round caps — **the user's decision**, relayed by the manager: "set 2 and only one more if something critical is behind". Stage 1b, Stage 3 and Stage 5 each run at most 2 rounds at every tier where the stage runs; a third only when round 2 returned a `critical` or `high` finding, recorded first as a `- round 3: <stage> — <severity> <finding>` line under `## Decisions`; nothing past round 3. It supersedes `[bug-reviewer-findings/questions.md Q3]`, `[feature-plugin-marketplace/questions.md S3]` (`docs/specs/marketplace.md`) and `[sync-local-edits/result-followups.md D11]`.
- [flow-cheaper-rounds/plan.md D3] "Critical **or high**", not "critical" alone — **the manager's choice, not the user's**: the real case that needed a third round was rated high. The user may overrule it; then only the word list in D2's files changes.
- [flow-cheaper-rounds/plan.md D4] The severity is given by the agent that reports the finding (`glab:reviewer`, `glab:analyzer`), as a `severity:` line on `glab:audit`'s four *Severity Levels*, and never re-ranked by the manager.
- [flow-cheaper-rounds/plan.md D5] Reviewer round 2 is the last round unless it reports a `critical` or `high` finding; then it answers `BLOCK: <n> issues` and round 3 may run, which is the last with no exception. The verdict strings did not change.
- [flow-cheaper-rounds/plan.md D6] What happens when a stage ends its last round without passing is unchanged for that stage and tier (1b full → the user; 1b normal → one more amendment, `PLAN WRONG` the backstop; after round 3 → the user; Stage 3 → the user with three resolutions; Stage 5 → the last-round answer to the user); only the round counts changed.
- [flow-cheaper-rounds/plan.md D7] Every round is a new agent — a plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a Stage 8 record fix; Rule 5's report check (missing fields only) is the one resume (`[feature-model-switch/plan.md D22]` binds). It sits in Rule 2 because its reason is cost.
- [flow-cheaper-rounds/plan.md D8] A round's findings travel in the next agent's dispatch, copied as the agent returned them — the one input not on disk; the manager writes no findings file (Rule 1) and the analyzer and reviewer are read-only.
- [flow-cheaper-rounds/plan.md D9] A fix-round developer adds `## Fix round — <stage> round <n>` to `result.md` and does not overwrite it; the overwrite rule stays for a re-dispatch of the same steps.
- [flow-cheaper-rounds/plan.md D10] The Stage 1b delta is a copy `plan.r<n>.md` (and `findings.r<n>.md`) made before the amendment is dispatched, not git: the plan folder is untracked while it is planned. The copies stay and are committed with the folder. Amended by D49: the manager tests the delta with `cmp -s`, only the analyzer runs `diff -u`.
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
- [flow-cheaper-rounds/plan.md D27] One commit for all seven items with the plan folder, because the *One fact* rule wants each fact's files together and the hook events are one fact across `hooks/hooks.json`, `README.md` and `AGENTS.md`; the manager may split it. Done as one commit, `2a1e919`.
- [flow-cheaper-rounds/plan.md D28] Out of scope, recorded as follow-ups: a dedicated `glab:planner` agent (FU1), splitting the implementation steps out of `glab:plan-first` (FU2), the user-level copies under `~/.claude` (FU3), the "cleanup glob deleted a reviewer report" incident (FU4), and the hooks the user did not choose (FU16).
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
- [flow-cheaper-rounds/plan.md D45] `stop` speaks to the **user**, not the model, with `systemMessage`; stateless; a step is `-1` below 300k, else `floor((x - 300000) / 100000)`; it speaks when the step of the latest written call is above the step at an earlier prompt. Amended after I1 by D61–D62: that earlier prompt is the real prompt before the last one. A real prompt is a user entry that is not a sidechain, not `isMeta` and not a `tool_result`. I1 proved that `Stop` shows `systemMessage` to the user in the terminal and the turn ends there. Whether the model also sees the `Stop` text stays UNVERIFIED.
- [flow-cheaper-rounds/plan.md D46] `stop` never blocks and never continues the conversation: no exit 2, no `decision`, no `reason`, no `continue`, no `hookSpecificOutput`, no `additionalContext`; `systemMessage` is its only key; nothing reads `stop_hook_active`. Test cases assert the key set on every `stop` output.
- [flow-cheaper-rounds/plan.md D47] D19's thresholds became fixed steps — 300k and every 100k after it — for the manager's prose as for the `stop` mode: one rule stated once. The task-boundary `/clear` stays the manager's, because no hook can tell a task boundary. After I1 (D61): the manager reads the current `agent` line, so its suggestion may come before the user's line; the two never disagree on the steps.
- [flow-cheaper-rounds/plan.md D48] "Impossible to bypass" — what holds: the hooks run in the harness whatever the model does, in every session where `glab` is enabled. What does not: they do not run when the plugin is disabled, under `--bare`, or under `disableAllHooks: true`; managed policy can restrict hook sources (effect on a plugin's hooks UNVERIFIED, FU15); an interrupted turn fires no `Stop`. Each is a setting or an act of the user or organisation, not something the model can do; the dispatch-count fallback covers a session where no line comes. Whether a live model follows the prose rule stays UNVERIFIED.
- [flow-cheaper-rounds/plan.md D49] Manager decision, Stage 1b round 1: the manager tests the plan delta with `cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and `findings.md`), reading the exit code only — 0 identical, 1 changed, 2 a file missing — and never reads the diff itself; only the analyzer of round `<n+1>` runs `diff -u`. Amends D10 and D12.
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
- [flow-cheaper-rounds/plan.md F1] **Measured by the manager in another project, not reproducible here** — the evidence the change rests on: total input over all turns 597M tokens, of which developers 49%, planners 21%, Stage 1b plan checks 11%, reviewers 8%, mapping agents 6%. Fix rounds sent back to the same resumed agent cost 149M, each round restarting at 300–450k context, modelled as fresh agents at about 37–64M. A Stage 1b round 2 that re-read the whole plan cost 9.5M against round 1's 9.0M; targeted re-check rounds cost about 40% of round 1. The planner, handed three mapping files, re-touched 40 of its 157 paths that mapping had already read. Normal-tier plans were run against full-tier caps. The manager session itself: 1,054 turns, a 648k peak, 348M tokens (about 37% of the run), five tasks and one compaction. **Inferred, not shown:** the savings each change brings, and that a live session follows the edited prose (UNVERIFIED, as for every rule of this change).
- [flow-cheaper-rounds/plan.md F8] Untested cases of the two delta mechanisms: a nested repository in the tree (`git add -A` would record a gitlink with a warning) and a large untracked directory that is not ignored (every file is hashed). Shown in a throwaway repo only: the snapshot catches tracked, staged, untracked and deleted files, leaves the real index and `git status` unchanged, skips ignored files, gives the same id for the same tree; `cmp -s` exits 0, 1 or 2 with no output. Limits kept in `[flow-cheaper-rounds/plan.md FU8]`.
- [flow-cheaper-rounds/plan.md F9] The Write-tool probe was partial: only `findings-probe.md`, `findings.md` (refused) and `map-probe.md` (accepted) were tried; which other names the guard refuses is not known.
- [flow-cheaper-rounds/plan.md F15] Round 1's UNVERIFIED — that `CLAUDE_CODE_SESSION_ID` is set and names the transcript on any host other than the manager's — no longer binds anything: nothing reads the variable since `D30` (`FU9`, closed as moot).
- [flow-cheaper-rounds/plan.md F20] **Documented by Claude Code, not proven here, and UNVERIFIED where marked:** `PostToolUse` and `UserPromptSubmit` take `additionalContext`; `Stop` takes `systemMessage` (common field, "Warning message shown to the user") and, with exit 0 and no `decision`, lets the turn end; `SubagentStop`'s `additionalContext` goes to the subagent; the transcript "is written asynchronously and may lag"; hooks do not run under `disableAllHooks: true` or `--bare`. UNVERIFIED: that the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 (`FU11`); whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks (`FU15`); whether the Agent `tool_input` carries `effort` (`FU13`); which transcript a subagent that itself calls `Agent` is handed, if the hook fires there (changes nothing above). An interrupted turn fires no `Stop` (documented), so shows nothing; the next turn's `prompt` line still carries the number.
- [flow-cheaper-rounds/plan.md F23] What integration I1 showed and did not (the user ran it in their terminal, Claude Code `2.1.304`, one host, one version): shown — `agent` line current at `PostToolUse` (a 36,185-token request printed `37k`), the `prompt` line reached the model, `Stop`'s `systemMessage` shown to the user in the terminal with the turn ending there, and at `Stop` the turn's last call not yet written (there 1 s later). **Not observed:** whether the model also sees the `Stop` text (I1b's quote prompt was not reported); a display other than the terminal, such as the desktop app (`FU17`); how far the lag can grow on another host or under load (D62 relies on the transcript catching up within one turn); which plugin's second `Stop` hook ended `cancelled`, exit 1, in I1a (`FU18`). I1c, the re-run of I1b on the rebuilt `stop` (expected: nothing on turn 1, the line on turn 2, the turn ending there), **passed**: the plan folder holds no I1c output (`F24` holds the fixture run only); what it showed turn by turn, as the manager observed it from the user's screenshot, is in *Incidents* (IN1).
- [flow-cheaper-rounds/plan.md F24] The `stop` base and the new cases were proven on throwaway copies without a model: the rebuilt script `PASS 21/21`, the script as built before the fix `FAIL 3/21` (T18, T20, T21), and mutants of the rebuilt copy fail the test (a `"decision":"block"` in the `stop` JSON → T18, T20, T21, T19; `+ 999` removed → T1, T3, T13; the `isSidechain` filter removed → T15; the old real-prompt branch → T18, T20, T21). Fixtures only: a real transcript's shape on other CLI versions was not read (the brief keeps transcripts out of reach).
- [flow-cheaper-rounds/plan.md D62-limits] Known limits of `stop`'s base: a `/compact` inside the two turns it covers can hide a crossing until the next `Stop` whose base is past the drop; a lag longer than one turn is not covered by any case (it would still speak, later); and a window with fewer than two real prompts speaks at or past 300k.
- [flow-cheaper-rounds/result.md review-fix-1] Review round 1/1 (`SHIP`, low) found the script header claiming `stop` speaks "once per crossing, twice at most", untrue when fewer than two real prompts fall inside the 8 MiB window: then `base` stays 0 and `stop` speaks at **every** turn end while the context is at or past 300k. That needs more than 8 MiB of transcript between two consecutive prompts (one turn of very large tool results) and ends with the next ordinary turn. Accepted — the window bounds the read cost, a line too many is the cheaper error — and fixed by comment only (`plugins/glab/scripts/context-size.sh` header); the behaviour is covered by the T18 cases `no prompt in the window` and `one prompt in the window`, not by a 9 MB fixture.
- [flow-cheaper-rounds/plan.md F17] Not measured: how long `context-size.sh` takes on any host but this one. T9 prints it (0.07 s here on a 36 MB transcript); the hook's 5 s `timeout` is the bound if a host is slower. UNVERIFIED elsewhere.
- [flow-cheaper-rounds/result.md digit-guard] Not covered by any test case: the defensive digit guard in `context-size.sh` (`[[ $v =~ ^[0-9]{1,15}$ ]]`, its `fail` branch) — `jq`'s `floor` cannot fail it for any usage the fixtures can hold except an exponent form (usage above 1e17); it exists so the script can never reach a bash arithmetic error, which would break the exit-0 contract.
- [flow-cheaper-rounds/plan.md F18] The CLI labels every hook "harness-only — no model context cost" in `plugin details`, which is not true of a hook that returns `additionalContext` (`FU12`); the gate's green line for `glab` prints the events in the file's key order, so reordering `hooks.json` changes the line.

## Open follow-ups

- [sync-local-edits/follow-ups.md 7] `commands/develop.md:67`: a `waived.md` has no tier line, so the waiver path has no next stage — reopened: the routing to `/glab:integrate` was removed by the review's scope cut, because a waiver has no plan and no tier, and the integrator, the integrate scope and the review cap need both. A fix has to give a waiver a tier and an integrator input first.
- [sync-local-edits/follow-ups.md 13] `glab:manager` Rule 0c seam note and Stage 1, `glab:plan-first`: "may overrule one" conflicts with Rule 4, where a relayed decision binds and the surface owner has the last word. Suggested: except a line recording another session's decision — open.
- [sync-local-edits/follow-ups.md 14] Stage 1: recording an overrule as a new line leaves steps built on the old choice. Suggested: send the plan back to the planning agent to amend them — open.
- [sync-local-edits/follow-ups.md 15] Rule 3 still reads as "the manager writes the decision line", while Stage 1 says the planner writes it. Suggested: one clause, during planning the planner writes it and the manager reviews it — open.
- [sync-local-edits/follow-ups.md 16] `commands/integrate.md:10`: the integrator agent is never told the normal-tier scope (milestone test only). Suggested: "Say which in the dispatch." — open.
- [sync-local-edits/follow-ups.md 17] `scripts/manager-bootstrap.sh:17`: "-> commit -> push -> record at full tier" (as at `09d2787`; it read "-> push at full tier" when raised) can read as "only at full tier", and Stage 1b is missing. Suggested: "At full tier work moves through plan -> analyze -> develop -> …" — open.
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
- [flow-cheaper-rounds/plan.md FU1] A dedicated `glab:planner` agent (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU2] Splitting the implementation steps (5–7) out of `glab:plan-first` (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU3] The user-level copies under `~/.claude` — the user ports them (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU4] The "cleanup glob deleted a reviewer report" incident (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU5] `agents/analyzer.md` has no plan-check mode: `BUILDABLE` / `NOT BUILDABLE` appear only in `skills/manager/SKILL.md`, and its Steps 2–3 are written for an implementation — open.
- [flow-cheaper-rounds/plan.md FU6] `glab:plan-first` prescribes `findings.md` at full tier, but a subagent planner's Write is refused that name; a full-tier planner subagent cannot write its findings file as the skill says — open (see *Incidents*).
- [flow-cheaper-rounds/plan.md FU8] Snapshot limits: a nested repository is recorded as a gitlink with a warning and a large untracked directory that is not ignored is hashed in full (not tested); a repository with no commit yet gets no tree id (`git read-tree HEAD` fails), so its rounds run whole; a file force-added to the index but not committed that matches `.gitignore` is still missed — open.
- [flow-cheaper-rounds/plan.md FU11] Whether the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 — UNVERIFIED, open. An older CLI still gets the `prompt` line, and the handoff line then uses it (`D38`).
- [flow-cheaper-rounds/plan.md FU12] `claude plugin details` labels every hook "harness-only — no model context cost", which is not true of one that returns `additionalContext`: the CLI's wording, to report upstream if anyone wants to — open.
- [flow-cheaper-rounds/plan.md FU13] A `PreToolUse` hook on `Agent` that refuses (`permissionDecision: "deny"`) a dispatch missing `effort` or the `AGENTS.md` instruction — the coordinator's follow-up, not planned; whether the Agent `tool_input` carries `effort` is UNVERIFIED — open. The same item as `[flow-cheaper-rounds/follow-ups.md FUd]`.
- [flow-cheaper-rounds/plan.md FU14] An assistant entry longer than the 8 MiB window is not seen (`D32`): an older call's figure, or silence. Widen the window or read backwards if it is ever seen — open.
- [flow-cheaper-rounds/plan.md FU15] Whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks — UNVERIFIED, open.
- [flow-cheaper-rounds/plan.md FU16] The hooks the user did not choose — `PostToolBatch`, `SubagentStop` — recorded by D28 and D29, not planned — open.
- [flow-cheaper-rounds/plan.md FU17] Whether the desktop app shows a `Stop` hook's `systemMessage` as the terminal does (I1 shows the terminal only) — UNVERIFIED, open.
- [flow-cheaper-rounds/plan.md FU18] Which plugin's `Stop` hook ended `cancelled`, exit 1, in I1a, and whether an installed `memory-sync` sync is cut off whenever a `claude -p` run exits — UNVERIFIED, open; a question for the `memory-sync` plugin, not acted on here (`docs/specs/memory-sync.md`).
- [flow-cheaper-rounds/follow-ups.md FUa] The *One fact* entries "the manual model rule" and "the session effort" in `AGENTS.md` both name the handoff-line format (`plugins/glab/skills/manager/SKILL.md` Rule 5 and *The pipeline*, `commands/develop.md`, `review.md`, `ship.md`). The line now ends `· context <n>k` and Rule 5's example reads `round 1/2`, but those commands do not show the line's full form, so nothing disagrees today, while the two entries do not list the context field. Decide whether the context field joins them — open.
- [flow-cheaper-rounds/follow-ups.md FUb] Payload text cites a plan file: `plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh` and `plugins/glab/skills/manager/SKILL.md` cite `[flow-cheaper-rounds/plan.md F23]` (and the script `[flow-cheaper-rounds review round 1]`). The plan folder is removed after the record and is never part of an installed plugin, so an installer cannot follow the citation; it stays readable only through `git show <sha>:…` (cf. `[feature-docs-specs/plan.md D8]`: payload cites the spec, never a `plan/` path). Decide whether payload cites the area spec instead — open (review round 1, advisory).
- [flow-cheaper-rounds/follow-ups.md FUc] **The user's, 2026-10-20:** the next plan `flow-models-per-role` — a model per role (planner and plan check Opus; conformance and record check Sonnet; developer, reviewer, integrator Sonnet; committer Haiku) and two kinds of analyzer; it extends `glab:manager` Rule 5 beyond the developer and reviewer — open, not planned.
- [flow-cheaper-rounds/follow-ups.md FUd] The manager's: a `PreToolUse` hook on `Agent` that refuses a dispatch missing `effort` or the `AGENTS.md` instruction (`[flow-cheaper-rounds/plan.md FU13]`), so Rule 0d and Rule 0c are enforced rather than remembered — open.

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
