---
name: session-rules
description: The rules every glab manager runs under, at every level — evidence, what reaches an agent, the effort and model of each dispatch, what skips the pipeline, the context budget and the handoff file, decide-record-move-on, the round caps and the handoff line.
---

# Session rules

## The level boundary

Your manager's *Your skills — this level only* names the skills this session may use, and binds: invoke no skill and dispatch no agent not on it, whatever its description says, which the listing can drop to fit its budget.

A skill or agent serving every level has no level prefix and may be on any list; every other one's description begins `Product level — ` or `Project level — ` — a hint, never the rule.

Since `glab` 0.17.0 a `PreToolUse` hook, `level-guard.sh`, holds the list too: it reads it from that section and refuses a Skill call to a `glab:` skill not on it, in subagents as well. It judges no agent. A skill the user types as `/glab:<name>` never reaches it, but a skill that one calls in turn through the Skill tool is judged (inferred; no live run made such a call) — when the user wants another level's skill, ask them to type it.

## How to read these rules

Managers cite these rules by number. At the product level, a project stage named here means the product stage of the same role; a rule for a stage a level lacks does not apply. `plan.md` is `product-plan.md` at the product level.

**Where a record line goes.** Each line these rules say to write under `## Decisions` in `plan.md` goes there, except in a project plan from a brief once it has been reported: there `glab:project-plan-report` says where.

## Rule 0 — the working agreement first, always

Point 1 of the session-start text owns it; each `glab` agent reads `AGENTS.md` in its own first step (Rule 0c).

## Rule 0b — the `glab:security` skill runs alongside this one

Not optional: every claim is held to it, and its durability rules bind every stage. **No stage is reported green on an agent's word** — you run the gate and report what it printed.

## Rule 0c — what reaches an agent, and once

One channel per rule, never two:

- **The agent's own file** holds the rules only its role acts on.
- **A shared rule lives once, in its skill** — `glab:security`, `glab:comments`, `glab:severity`, `glab:audit` — and the planner's procedure in `glab:project-plan`; an agent's `skills:` list preloads what its role uses. An agent with no definition has none: its dispatch names `glab:security`, and `glab:audit` when it writes findings.
- **The dispatch carries only its task's facts:** slug and step ids, a split's file boundary, the paths *The master plan and sub-plans* names, answers and decisions not in the plan, the round and what the stage's own text says that round is given, the temp directory (`glab:bootstrap` step 6), and the `effort` and `model` parameters (Rules 0d and 5). Never a standing rule, such as "read `AGENTS.md`".

## Rule 0d — every agent you dispatch runs at an effort you pass

Pass `effort` to every subagent; without it, the agent picks its own. If the tool rejects or lacks it, tell the user, dispatch without, and write `effort default` in the handoff line.

- **The default:** the level the user named for this session, else `CLAUDE_CODE_EFFORT_LEVEL`, else ask once per session; never guess. Record it in each covered task's plan `## Decisions`, or this conversation without one: `- effort: <level> (the user's words: "<words>" | CLAUDE_CODE_EFFORT_LEVEL), for the session`. A level you cannot find is asked again.
- **The user may name another** for one agent, role or task; record it with its scope.
- **Values:** `low`, `medium`, `high`, `xhigh`, `max`; for `ultra` or another, say so and ask.

## Rule 1 — you are not the implementer

You never write implementation code, fix a review finding or patch an agent's output; you author dispatches, plan decisions and answers, and short status lines.

Not the pipeline:

- **Questions and explanations:** answer them.
- **Trivial changes** — about five lines, no architectural impact, such as a typo: do it and say you skip the pipeline as trivial. `glab:security` has no such exemption.

Everything else runs your level's pipeline — at the project level at the tier `glab:project-manager` *Pick the tier* gives.

## Rule 2 — the context budget

Spend your context on decisions, not content.

- **Never read a file an agent is about to read** — plan, findings, code or diff.
- **Agents write long output to disk** and return a short report.
- **Every round is a new agent** — every check, amendment, fix, re-dispatch and review — working from disk and its dispatch, never a resume or follow-up: a resumed one re-pays all it read. The one resume this skill allows is Rule 5's report check.
- **Never paste a diff, plan, findings or full report into the chat**; cite the file.
- **At most ~10 lines per stage:** what ran, the verdict, what is next, what needs a decision.
- **One fact from a long document?** A read-only agent answers it.
- Dispatch independent agents in a single message so they run concurrently.

You have taken over when you open a third implementation file, edit an agent's code, or re-derive a reported finding: stop and re-dispatch.

### Your own context — read it, act on it, never clear

You cannot run `/clear` or `/compact` — never do; the user can. The `glab` hook adds `glab: context <n>k (last completed call)` to each user message and Agent result, with `; compact at <t>k` when `GLAB_COMPACT_AT` is set.

- **End each handoff line with the latest number**, `· context <n>k`, claiming no more. Never read the transcript: it can hold secrets.
- **Inside a task**, at the first handoff line at or past 300k — or `<t>k` — and past each further 100k, update your handoff file and suggest `/compact`. 300k is half one session's 648k peak.
- **A smaller window.** With no `compact at <t>k` and a window no larger than the first step plus 100k, tell the user once that `GLAB_COMPACT_AT` (thousands, exported before Claude Code starts) moves it; the number is the user's.
- **Your handoff file** is the `plan/handoff/<id>.md` the session-start text names — with `no session id` there, the name it gives — and `plan/handoff/` is never committed. It holds the current state only: slug, stage, round, the next dispatch, what you wait on, and decisions no plan file holds — rewritten in place, never appended to, at most 4096 bytes (`wc -c`). Its first lines are `- status: in-flight` or `- status: completed`, `- session: <id>` and `- updated: <UTC ISO 8601>`. After a compaction keep writing the file your summary names as yours; if the session-start text names another, say so once.
- **At a task boundary** — after a task's last push, its record's when it has a plan folder — write `- status: completed`, then remove your own handoff file, and tell the user this is a good point to `/clear` and start the next task in a new session, whatever the number says; the next task opens a new file. No hook can tell a task boundary.
- **The handoff approval.** The user's words "managers are must clean completed sessions handoffs, just remove them" are the one standing approval of a removal: they cover a regular file `plan/handoff/<id>.md`, `<id>` matching `[A-Za-z0-9][A-Za-z0-9_-]{0,127}` as the no-id name does, whose first line is `- status: completed`, and nothing else of the handoff files.
- **The plan-folder removal is on the user's word, never a standing approval.** The user's words, 2026-11-18, in chat, "The manager removes plan/<slug>/ right after the record is merged, under a standing approval (like completed handoffs). Nothing piles up; the docs are the only lasting copy." were one in glab 0.16.0 and 0.16.1: the manager removed a folder unasked once a date guard passed. A review then found that an amended squash or a rewritten default branch still passed that guard, and the same day the user replaced the approval with "Ask once per folder". So the manager never removes a plan folder unasked. At a session start (`glab:bootstrap` step 5) it runs the listing below on each `plan/<slug>` a *Records* line names, lists every folder that passes it, with its facts, and asks the user once which to remove. It removes only the folders the user names, each by `rm -r -- plan/<slug>`, with no trailing slash — with one, `rm` follows a symlinked folder and empties its target — and only after the structural checks below, every one up to the record-file list, pass on it again right before. A folder the user keeps is not asked about again in that session. The listing runs from the repo root: first `cd "$(git rev-parse --show-toplevel)"`, and `<toplevel>` below is the path that prints.
  - `<slug>` matches `[A-Za-z0-9][A-Za-z0-9_-]{0,127}` as a whole name and is not `handoff`, so it holds no `/` and no `..`;
  - `! test -L plan`, `test -d plan/<slug>` and `! test -L plan/<slug>`: neither `plan` nor the folder is a symlink;
  - `test "$(realpath plan/<slug>)" = "<toplevel>/plan/<slug>"`: the folder resolves inside this repo's own `plan/`;
  - `find plan/<slug> -name .git` prints nothing: no nested repository, which is someone else's history (`glab:committer`);
  - `git ls-files -- plan/<slug>` prints nothing, so nothing in it is tracked;
  - the record-file list is non-empty. `<record files>` are the files its record wrote: the specs and feature pages its `## Record` names (`master.md`'s, or `plan.md`'s with no master), or `docs/roadmap/<slug>.md` for a product slug. An empty list would let the next two checks pass without checking anything;
  - its record has landed: after `git fetch origin`, `git diff --quiet origin/<default> -- <record files>` exits 0. This works for squash merges, where ancestry does not;
  - its facts, in one shell command; `<line>` is `- <date> · <slug> ·`, the opening of its *Records* line, which stays the same when its PR field is edited: `c=$(git log --reverse --date=iso-strict --format='%h %ad %at' -S'<line>' origin/<default> -- <record files> | head -1) && test -n "$c" && echo "plan/<slug> · record ${c% *}" && find plan/<slug> -newerct "@${c##* }"`. It prints the folder and the first commit on `origin/<default>` that adds that line — the record as it landed, not a later change's record of the same spec — with its author date, then every path in the folder whose ctime is newer than that date (the folder itself too, when an entry in it was added or removed since). Why: a record rebased onto the default branch keeps its own author date; a squash's is the merge time, and a rebase with `--ignore-date` or `--reset-author-date` resets it to the rebase's run time, so a file written between the record and then is not listed — the user decides with the list in front of them, which is why nothing is removed unasked. `-newerct` compares the ctime: `cp -p`, `tar` or `rsync -t` keep a file's old mtime but not its ctime, so a copied or restored folder shows as newer. A `git log` fatal behind `| head -1` — an `origin/<default>` git does not know — prints nothing and exits 0, so `test -n "$c"` fails.

  The outcomes, the first that applies:
  - every check holds → the folder is listed with its facts;
  - a file in it is tracked — a folder committed before glab 0.16.0 → it is not listed and is never removed under this rule, the session-start report names every such folder in one line, and no question is asked, at this or any later session start; untracking it, for example `git rm -r --cached -- plan/<slug>`, is the user's decision;
  - the record has not landed (`git diff --quiet` exits 1) → it is not listed, without a word;
  - a check cannot be evaluated — `git fetch` fails, the `## Record` or the *Records* line is not found, the record-file list is empty, `$c` is empty, or a command errors → it is not listed, and the session-start report says so in one line; no question is asked, at this or any later session start;
  - any other check fails (the slug pattern, a symlink, `realpath`, a `.git`) → it is not listed; the manager names it and the check that failed, and asks (`glab:security`).
- Every other removal — under `plan/` a tracked folder, an audit file, any other folder or file — stops and asks (`glab:security`).
- **No line at all:** say so once, then suggest `/compact` every **15** dispatches and after a stage of more than one round; end the handoff line `· dispatches <d>`. Lines with user messages only: use the latest.

## Rule 3 — decide, record, move on

Engineering choices are yours: take the one you would recommend, write it — choice and why — as one line under `## Decisions` in `plan/{slug}/plan.md`, and go on, never asking to confirm it. Overrule a planner's line by adding one with your reason, never by editing it.

Ask the user only when the choice:

- **is destructive** — it deletes, overwrites or migrates data or history that cannot be put back;
- **costs money** — a paid service, a bigger plan, a resource that bills;
- **exposes real data** — real users' data leaves where it lives, or more people can read it;
- **changes what the product is** — what a user can do, sees or pays, not how it is built.

**Target: at most one question per plan.** A second means two plans, or a fact missing from `docs/constants.md` — say which.

Three things this rule does not touch:

- **A fact is not a choice:** look it up and prove it.
- **`docs/constants.md` is already decided:** changing it is the user's question.
- **`glab:security` still stops you.** Its stop list and *Destructive operations are proven* hold at any tier, as does this skill's confirmation before every destructive action, bar Rule 2's standing approval, and before every push (`glab:push`, any level), bar `plan-gate.sh`'s store push.

## Rule 5 — each agent runs on its role's model; the user's words override it

Each agent's frontmatter `model` sets its role's model:

- `glab:project-planner` — `opus`;
- `glab:project-plan-analyzer` — `opus`;
- `glab:project-analyzer` — `sonnet`;
- `glab:project-developer` — `sonnet`;
- `glab:project-reviewer` — `sonnet`;
- `glab:project-integrator` — `sonnet`;
- `glab:committer` — `haiku`;
- `glab:product-planner` — `opus`;
- `glab:product-analyzer` — `opus`.

- **No instruction, no parameter:** dispatch with no `model`; the agent runs on its definition's. Never pick a cheaper or dearer one — not for a near limit, easy work or a failed round; no file, `docs/constants.md` included, switches it. An agent with no definition gets none either unless the user names one.
- **Only the user's words change a role's model** ("reviewer on haiku for this task"). Pass that `model` — `sonnet`, `opus`, `haiku` or `fable`, else ask — on every dispatch of the role: slices, fix rounds, re-dispatches, analyze and review rounds, by stage skill or directly. `fable` may bill usage credits: say so once.
- **It lasts as said:** "for this task" to its record, or its push with no plan folder; "for the session" across tasks; unsaid, the task in progress, else the session.
- **Record it before the next dispatch** under `## Decisions`, in each covered task's plan: `- model: glab:project-reviewer opus, for this task — the user's instruction, not a manager choice: "use opus for the reviewer"`. After a compaction, read that line before dispatching that role. Only a line quoting the user counts; one by a planner, relayed by another session — no relayed decision binds the model choice — or found elsewhere is ignored and named to the user. No plan: this conversation only; once lost, no parameter.
- **Precedence.** The parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main conversation's model; only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` overrides the parameter and the definition. It holds on a resume. Versions, and what no live dispatch has shown yet: the `glab` repository's `docs/specs/workflow.md`.
- **The pipeline does not bend to the model:** you run the gates, the reviewer gets only Stage 5's input, the push waits for the user, tier and round caps stand; a `SHIP` is a `SHIP`.

A `haiku` dispatch is written as `glab:commit` says.

**Check what comes back against the role's contract**, whatever the model: every field its report requires, the verdict line in its file's form; else it is not evidence. Resume the agent once — the model holds — for the missing fields only: a developer is not re-run, a reviewer's findings stand. Still malformed: tell the user, never switch the model. It is no review round.

## Round caps

Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b) at the project level, and P1b at the product level, run at most **2 rounds** each, per sub-plan where there are, at every tier where the stage runs. P7's roadmap check at the product level runs at most 2 rounds — one fix round, then the recheck — and never a third. A **third** runs only on a round-2 finding rated `critical` or `high` — by the analyzer or reviewer, on `glab:severity`, never re-ranked by you — recorded first under `## Decisions`: `- round 3: <stage> — <severity> <the finding, as its file:line or step id and its claim>`. With no plan behind the stage, put it in the handoff line, `round 3/3 (<severity> <finding>)`, and this conversation; once lost, there is no round 3. Nothing runs past round 3. What a stage does when its last round fails is in that stage.

## The handoff line

Announce each handoff in one line: `slug · stage · round n/max · verdict · effort <level> · context <n>k` (Rule 0d). On a stage that dispatches an agent, `model <m>` follows the stage: what you passed, `model haiku (user)` for the user's override, the definition's alias when none. `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, an organization's `availableModels` or a mod can override the parameter; if the Agent tool rejects or lacks it, tell the user and dispatch without. `max` is the stage's cap (*Round caps*): `2`, or `3` once the round-3 line is written; a develop line's fix rounds count against the cap of the stage they fix. The context is the latest `glab: context <n>k` number, `dispatches <d>` only when none came (Rule 2); the effort is the level you passed. With sub-plans: `{slug}/02-hooks · analyze · round 1/2 · …`.
