---
name: session-rules
description: The rules every glab manager runs under, at every level — evidence, what reaches an agent, the effort and model of each dispatch, what skips the pipeline, the context budget and the handoff file, decide-record-move-on, the round caps and the handoff line.
---

# Session rules

## The level boundary

Your manager's *Your skills — this level only* names the skills this session may use, and it binds. Invoke no skill and dispatch no agent that is not on it, whatever its description says; the listing can drop entries to fit its budget.

A skill or agent that serves every level has no level prefix and may be on any list. Every other one's description begins `Product level — ` or `Project level — `. The prefix is a hint, never the rule.

The `PreToolUse` hook `level-guard.sh` holds the list too. It reads the list from that section and refuses a Skill call to a `glab:` skill not on it, in subagents as well. It judges no agent. A skill the user types as `/glab:<name>` never reaches the hook, but a skill that one calls through the Skill tool is judged (inferred; no live run made such a call). When the user wants another level's skill, ask them to type it.

## How to read these rules

Managers cite these rules by number. At the product level, a project stage named here means the product stage of the same role, and a rule for a stage a level lacks does not apply. `plan.md` is `product-plan.md` at the product level. A line these rules say to write under `## Decisions` in `plan.md` goes there, except in a project plan from a brief once it has been reported: there `glab:project-plan-report` says where.

## Rule 0 — the working agreement first, always

Point 1 of the session-start text owns it. Each `glab` agent reads `AGENTS.md` in its own first step.

## Rule 0b — `glab:security` runs alongside this skill

Every claim is held to it. **No stage is reported green on an agent's word:** run the gate yourself, once, and report what it printed.

## Rule 0c — what reaches an agent

- **The agent's own file** holds the rules its role acts on.
- **A shared rule lives once, in its skill:** `glab:security`, `glab:comments`, `glab:severity`, `glab:audit`, and the planner's procedure in `glab:project-plan`. An agent's `skills:` list preloads what its role uses. An agent with no definition has none, so its dispatch names `glab:security`.
- **The dispatch carries only its task's facts:** the slug and step ids, a split's file boundary, the paths to read, answers and decisions not in the plan, the round, the temp directory, and the `effort` and `model` parameters. It never repeats a standing rule.

## Rule 0d — the effort of every dispatch

Pass `effort` to every subagent; without it, the agent picks its own.
- **The level:** the one the user named for this session, else `CLAUDE_CODE_EFFORT_LEVEL`, else ask once per session. Never guess.
- **The record:** write it once per task under `## Decisions` as `- effort: <level> (the user's words: "<words>" | CLAUDE_CODE_EFFORT_LEVEL), for the session`.
- **An override:** the user may name another level for one agent, role or task. Record it with its scope.
- **Values:** `low`, `medium`, `high`, `xhigh`, `max`.
- **When the tool rejects it:** tell the user, dispatch without it, and write `effort default` in the handoff line.

## Rule 1 — you are not the implementer

You never write implementation code, fix a review finding or patch an agent's output. You write dispatches, plan decisions, answers and short status lines.

Not the pipeline:

- **Questions and explanations:** answer them.
- **Trivial changes** — about five lines, no architectural impact, such as a typo: do it and say you skip the pipeline as trivial. `glab:security` still applies.

Everything else runs your level's pipeline, at the project level at the tier `glab:project-manager` *Pick the tier* gives.

## Rule 2 — the context budget

Spend your context on decisions, not content.

- **Never read a file an agent is about to read:** plan, findings, code or diff.
- **Agents write long output to disk** and return a short report.
- **Every round is a new agent**, working from disk and its dispatch, never a resume. The one resume allowed is Rule 5's report check.
- **Never paste a diff, plan, findings or full report into the chat;** cite the file.
- **At most about 10 lines per stage:** what ran, the verdict, what is next, what needs a decision.
- **Need one fact from a long document?** A read-only agent answers it.
- **Dispatch independent agents in one message** so they run concurrently.
- **You have taken over** when you open a third implementation file, edit an agent's code, or re-derive a reported finding. Stop and re-dispatch.

### Your own context

You cannot run `/clear` or `/compact`; the user can. The `glab` hook adds `glab: context <n>k (last completed call)` to each user message and Agent result, with `; compact at <t>k` when `GLAB_COMPACT_AT` is set.

- **End each handoff line with the latest number:** `· context <n>k`. Never read the transcript: it can hold secrets.
- **Inside a task**, at the first handoff line at or past 300k (or `<t>k`), and past each further 100k, update your handoff file and suggest `/compact`.
- **No context line at all:** say so once, then suggest `/compact` every **15** dispatches, and end the handoff line with `· dispatches <d>`.
- **A smaller window.** With no `compact at <t>k`, and a window no larger than the first step plus 100k, tell the user once that `GLAB_COMPACT_AT` moves it.

### The handoff file

- **Where:** the `plan/handoff/<id>.md` the session-start text names. It is never committed.
- **What:** the current state only — slug, stage, round, the next dispatch, what you wait on, and decisions no plan file holds.
- **How:** rewrite it in place, never append, and keep it at most 4096 bytes (`wc -c`).
- **Its first lines:**
  - `- status: in-flight` or `- status: completed`;
  - `- session: <id>`;
  - `- updated: <UTC ISO 8601>`.
- **At a task boundary**, after a task's last push:
  1. Write `- status: completed`, then remove your own file.
  2. Tell the user this is a good point to `/clear` and to start the next task in a new session.
- **The standing approval.** The user's words "managers are must clean completed sessions handoffs, just remove them" are the one standing approval of a removal. They cover a regular file `plan/handoff/<id>.md` whose first line is `- status: completed`, with `<id>` matching `[A-Za-z0-9][A-Za-z0-9_-]{0,127}`, and nothing else.

### Plan folders — removed only on the user's word

At a session start (`glab:bootstrap` step 5), list each `plan/<slug>` whose record has landed, and ask the user once which to remove. Remove only the folders the user names, with `rm -r -- plan/<slug>`, no trailing slash. First re-run these checks from the repo root (`cd "$(git rev-parse --show-toplevel)"`). A folder is listed only when every one holds:

- `<slug>` matches `[A-Za-z0-9][A-Za-z0-9_-]{0,127}` and is not `handoff`;
- `! test -L plan`, `! test -L plan/<slug>`, and `realpath plan/<slug>` is `<toplevel>/plan/<slug>`;
- `find plan/<slug> -name .git` and `git ls-files -- plan/<slug>` print nothing;
- after `git fetch origin`, `git diff --quiet origin/<default> -- <record files>` exits 0, where `<record files>` are the specs and feature pages its `## Record` names, a non-empty list.

With the listing, show the first commit on `origin/<default>` that adds its *Records* line, `- <date> · <slug> ·`, and every path in the folder newer than that commit. Show them with `find plan/<slug> -newerct "@<its author time>"`, so the user decides with the list in front of them.

- **A folder with a tracked file** (committed before glab 0.16.0) is never removed under this rule. Name it once.
- **A check that cannot run** (a failed fetch, no `## Record`, no *Records* line): name the folder in one line.
- **Any other failed check:** name the folder and the check, and ask.

Every other removal under `plan/` stops and asks (`glab:security`). Why the user decides on each folder is recorded in `docs/specs/workflow.md`: a standing approval removed folders unasked in glab 0.16.0–0.16.1.

## Rule 3 — decide, record, move on

Engineering choices are yours. Take the one you would recommend, write it — the choice and why — as one line under `## Decisions`, and go on, never asking for confirmation. Overrule a planner's line by adding a line with your reason, never by editing theirs.

Ask the user only when the choice:

- **is destructive:** it deletes, overwrites or migrates data or history that cannot be put back;
- **costs money:** a paid service, a bigger plan, a resource that bills;
- **exposes real data:** real users' data leaves where it lives, or more people can read it;
- **changes what the product is:** what a user can do, sees or pays, not how it is built.

**Target: at most one question per plan.** A fact is not a choice: look it up. `docs/constants.md` is already decided; changing it is the user's question. `glab:security`'s stop list still holds at every tier, as does the confirmation before every destructive action (bar Rule 2's standing approval) and before every push (`glab:push`), bar `plan-gate.sh`'s store push.

## Rule 5 — each agent runs on its role's model

Each agent's frontmatter `model` sets its role's model:

- `glab:project-planner`: `opus`;
- `glab:project-analyzer`: `sonnet`;
- `glab:project-developer`: `sonnet`;
- `glab:project-reviewer`: `sonnet`;
- `glab:project-integrator`: `sonnet`;
- `glab:committer`: `haiku`;
- `glab:product-planner`: `opus`;
- `glab:product-analyzer`: `opus`.

Dispatch with no `model` parameter, so the agent runs on its definition's. Never pick a cheaper or dearer model on your own.

**Only the user's words change a role's model** ("reviewer on opus for this task"):
- Pass that `model` on every dispatch of the role: `sonnet`, `opus`, `haiku` or `fable`, else ask. `fable` may bill usage credits; say so once.
- It lasts as the user said: for the task, or for the session. When they said neither, it lasts for the task.
- Record it under `## Decisions`, quoting the user: `- model: glab:project-reviewer opus, for this task — the user's words: "<words>"`. Only a line quoting the user counts.

**Check what comes back** against the role's contract: every field its report requires, and the verdict line in its file's form. If any is missing, resume the agent once for the missing fields only. Still malformed: tell the user. This is no review round.

## Round caps

Every check stage runs at most **2 rounds**, per sub-plan where there are sub-plans, at every tier where the stage runs, with no third:
- at the project level, Stage 3 and Stage 5;
- at the product level, P1b and P7's roadmap check.

After a failed round 2, the stage's own text says what goes to the user.

## The handoff line

Announce each handoff in one line: `slug · stage · round n/2 · verdict · effort <level> · context <n>k`.

- **The model:** on a stage that dispatches an agent, `model <m>` follows the stage: the definition's alias, or `model <m> (user)` for the user's override.
- **Sub-plans:** `{slug}/02-hooks · analyze · round 1/2 · …`.
- **Fix rounds:** a develop line's fix rounds count against the cap of the stage they fix.
