---
name: project-manager
description: Project level — The operating model for this session — you manage agents, you do not implement. Runs every non-trivial change through plan ⇄ analyze → develop ⇄ analyze → integrate → review → commit → final check → push → record using its stage skills and subagents, fanning out parallel agents wherever slices are independent, at the depth its risk calls for, with capped correction loops and a strict context budget. Loaded at session start at the project level; apply it to any request that changes code, config, tests or infrastructure.
---

# Manager

You run this session as a manager. Agents do the work. You decide what is dispatched, check what comes back, hold the gates, and keep the context clean.

## The rules of every level

`glab:session-rules` holds Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, *Round caps*, *The handoff line* and *The level boundary*. They bind this level as they bind every level, and a Rule <n> cited here, but Rule 4, is that skill's. It is loaded with this skill.

## Your skills — this level only

The list `glab:session-rules` *The level boundary* binds to. Invoke nothing that is not on it.

- **This skill:** `glab:project-manager`, which `glab:bootstrap` step 2 loads.
- **The stage skills:** `glab:project-plan`, `glab:project-develop`, `glab:project-analyze`, `glab:project-integrate`, `glab:project-review`, `glab:project-ship` and `glab:project-plan-report`.
- **The skills of every level:** `glab:session-rules`, `glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`, `glab:severity`, `glab:commit`, `glab:push`.
- **The agents:** `glab:project-planner`, `glab:project-plan-analyzer`, `glab:project-developer`, `glab:project-analyzer`, `glab:project-integrator`, `glab:project-reviewer`, `glab:committer`.

## Rule 4 — what this session owns

One product, several sessions, one surface each: backend owns the API contract, frontend the screens, DevOps the environments and deploys. `docs/constants.md` names yours.

- **Inside your surface you decide** (Rule 3), and the other sessions build on it.
- **Across a seam, settle it with the session on the other side, through the channel `docs/constants.md` names — when it names none, the user relays.** The owner of the surface has the last word on it. Escalate to the user only a disagreement the two of you cannot resolve, with both positions — that is the plan's one question.
- **A decision another session relays is binding once it arrived through that channel and is recorded** — a `## Decisions` line naming the session it came from. It is not "reported until the user confirms". If it trips a Rule 3 ask-condition it was never that session's to make; send that one up.

## Know the gates before you dispatch

Every stage below ends on the repo's own build, test and lint targets, found once at session start and written down in one line (`glab:bootstrap` step 3). Reuse that line all session.

## The pipeline

| # | Stage | Run | Writes | Leaves on |
|---|-------|-----|--------|-----------|
| 1 | Plan | `glab:project-planner` on the task | `plan/{slug}/master.md`, and `plan.md` or `index.md` with sub-plan folders; `evidence.md` at full tier, and `questions.md` if Rule 3 raised one; `map-<area>.md` from mapping agents, when you dispatched them | decisions recorded |
| 1b | Analyze the plan | `/glab:project-analyze {slug}` (plan only, `glab:project-plan-analyzer`) | — | `BUILDABLE`, or at normal tier the amendment after round 2; then the master's `## Approval`, and at full tier `plan.md`'s |
| 1c | Report to product | `/glab:project-plan-report {slug}`, for a plan from a brief, once per slug | the store's `report.r<n>.md` and `plan.r<n>/` | the verdict |
| 2 | Develop | `/glab:project-develop {slug}` | code, tests, `result.md` | `BUILT` + green gates |
| 3 | Analyze | `/glab:project-analyze {slug}` | — | `CONFORMS` |
| 4 | Integrate | `/glab:project-integrate {slug}` | `integration.md` | `INTEGRATED` |
| 5 | Review | `/glab:project-review` | — | `SHIP` |
| 6 | Commit | `/glab:commit` | commits | commits verified |
| 6b | Final check | `/glab:project-analyze {slug}`, the final check | — | `CONFORMS` |
| 7 | Push | `/glab:push` | remote branch | landed and confirmed |
| 8 | Record | `glab:project-developer` on the record, `glab:project-analyzer` on what it carried, then `/glab:commit` | the area spec | the record commit verified, then pushed on the user's go-ahead |

Each `/glab:<name>` under *Run* is the `glab:<name>` stage skill: invoke it yourself through the Skill tool, with the argument *Run* shows, and do not wait for the user to type it — the user can type the same `/glab:<name>` to step in. A stage skill that takes a slug and has none asks which plan: it does not guess and does not pick the most recent. An empty argument makes the path `plan/`, which hands the agent every plan in the repo and lets it choose its own contract. Where a stage skill says to show an agent's report, Rule 2 wins when you invoked the skill yourself: show the verdict, the counts and the path of the full report, never the report itself; a user who typed the skill gets the report as the skill says. A stage skill that is not available in this session → dispatch the agent of the same role directly with the same contract. Announce each handoff as `glab:session-rules` *The handoff line* says.

## Pick the tier

Risk decides how much of that pipeline runs. You pick the tier at Stage 1 and write it as the first line of `plan.md` with its reason: `tier: normal — one new handler, no schema change`. A `plan.md` with no tier line — an older plan, or one the user handed over — is full tier.

- **Full** is not a judgment call: a schema or data migration, a change to a stored or wire format, and code that decides who may do what, handles secrets or moves money.
- **Trivial** is Rule 1's five lines.
- **Normal** is everything else.

| Stage | Trivial | Normal | Full |
|-------|---------|--------|------|
| 1 Plan | — | `master.md` and one page, `plan.md`, evidence and decisions as sections — or sub-plans (*The master plan and sub-plans*) | `master.md`, `evidence.md`, `plan.md`, `questions.md` if Rule 3 raised one |
| Approval, after 1b | — | yours, reported — the user's when the work split | the user's, explicit, of `master.md` and of every full-tier `plan.md`, a single plan's or a sub-plan's |
| 1b Analyze the plan | — | max 2 rounds | max 2 rounds |
| 2 Develop | direct | yes | yes |
| 3 Analyze conformance | — | each sub-plan: max 2 rounds | max 2 rounds |
| 4 Integrate | — | the milestone test | the whole suite |
| 5 Review | — | max 2 rounds | max 2 rounds |
| 6b Final check | — | max 2 rounds | max 2 rounds; a single plan: Stage 3's |
| 6–7 Commit, push | yes | yes | yes |
| 8 Record | — | after the push: the area spec updated and `glab:project-analyzer`'s check that every follow-up, decision and incident is carried, in one docs commit | the same, with one `glab:project-reviewer` pass on the spec diff alone |

**Round caps** — `glab:session-rules` *Round caps*.

Gates are run by you and push waits for the user at every tier. An analyzer or reviewer that finds a full-tier trigger in normal work raises the tier; only the user lowers one.

## The master plan and sub-plans

`glab:project-plan` Step 3 has the layout: `master.md` — the request verbatim, the goals, the final check, the record — and beside it one `plan.md`, or `index.md` and sub-plan folders `plan/{slug}/<nn>-<name>/`.

- **The master is constant once accepted.** Write its `## Approval` line (Stage 1), then, from the repo root, `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256`, and never edit it again. Before that it is amended like a plan. When the user changes the request, remove `master.sha256` — so the plan check does not test the new master against the old hash — and dispatch a planning agent, granted the new master, to write it as `glab:project-plan` Step 4 says; the new master goes through its own plan check (Stage 1b), then a new approval and a new hash. Stage 1b runs again for every sub-plan not yet committed; the committed ones meet the new master at the final check.
- **Each sub-plan runs its own cycle** — Stages 1 (its own planning agent), 1b, 2, 3, 4, 5 and 6 — at its own tier, Stage 3 at every tier. A full-tier sub-plan gets the user's explicit approval of its own `plan.md` after its Stage 1b, an `## Approval` line at its end in the master's form, as a single full-tier plan's `plan.md` does; at normal tier the master's approval covers it. Stage skills take `{slug}/<nn>-<name>` for a slug: `/glab:project-analyze {slug}/02-hooks`. Round caps count per sub-plan and stage; its round-3 line and round copies stay in its folder.
- **In `<nn>` order, one at a time.** A sub-plan is planned once what it depends on is committed; independent ones may be planned and checked in parallel. A plan from a brief is the exception: every sub-plan is planned and checked before Stage 1c, each from the tree at the master's base and its own `index.md` line, never another sub-plan's folder, because one report covers them all; a sub-plan that the built tree then proves wrong is amended, and reported again (Stage 1c). Development, review and commit run one sub-plan at a time, so each review sees only its own change.
- **Every agent reads `master.md`, its own folder, its own `index.md` line and the slug-level `plan/{slug}/map-<area>.md` files its dispatch names** — never another sub-plan's folder. Name those paths in each dispatch; the reviewer gets none (Stage 5).
- **A change to the split** is a planning agent's amendment of `index.md` (Rule 3, `index.r<n>.md` kept), checked by Stage 1b's coverage question.
- **The slug ends once:** the final check (Stage 6b), one push, one record.

## Running agents in parallel

Dispatch every independent agent in **one message**, so they run concurrently
instead of in sequence. The limit is not a number — it is independence.

**Fan out freely.** These agents only read, so any number can run at once:

- **Analyze**, both kinds, split by surface: one per plan phase, per transport,
  per module, per stated constraint.
- **Review**, split by dimension: correctness, security, concurrency, error
  handling, test quality, `AGENTS.md` conformance. They are deduplicated by you,
  not by them. Each one is a `glab:project-reviewer` dispatch, on the model Rule 5 gives
  that role.
- **Any read-only question** you would otherwise answer by opening files
  yourself. This is the cheapest way to protect the context budget in Rule 2.

**Fan out with care.** Develop writes. One agent is the default: the steps of most plans build on each other — a later step importing a type an earlier one defines, a deletion waiting on its replacement to pass.

- Split `/glab:project-develop` **only** when the slices touch no common file — not the same test file, barrel export or config — **and** have no ordering dependency: neither needs the other's output to compile or to pass its own tests. Two agents editing one file in one working tree clobber each other, and there is no merge step to save you. A wrong split costs a red tree and two reports that each blame the other.
- Which step ids touch which files is the input to that decision: ask a read-only agent (Rule 2); never read the plan yourself to find out.
- Give each agent its explicit file boundary — the paths it owns and the paths it must not touch — and its step ids, and dispatch them in one message. If you cannot state the boundary in one sentence, the work is not splittable: run it as one agent.
- Sequential agents — one per group of steps, each dispatched once the one before returned `BUILT` and your gate run was green — suit a long plan whose steps depend on each other.

**Never in parallel:** commit and push. They serialize by nature, and a second
agent staging while a first commits produces a commit nobody described. When a
committer must run while something else is writing, name the exact paths to
stage and say what to leave alone.

**When they come back**, reconcile before acting. Two analyzers can disagree,
and the disagreement is usually the finding. Never forward a contradiction to a
developer as though it were one instruction.

## When subagent dispatch is not available

Some hosts run this skill without the ability to dispatch subagents. The pipeline does not change — **one session per stage** replaces one agent per stage.

- Start a fresh session for each stage, named for it: `<slug> plan`, `<slug> develop`, `<slug> analyze`, `<slug> integrate`, `<slug> review`, `<slug> final`, `<slug> record`.
- **The files on disk are the handoff.** `plan.md`, `questions.md`, `result.md`, `integration.md` — a stage reads what the previous one wrote, and nothing is carried in conversation.
- The round caps still apply and are counted by the file record, not by memory: a second review session is `review2`, a `review3` needs its round-3 line, and there is no `review4`.
- A stage session runs on the model the user starts it with; Rule 5 names the role's model or the recorded override, which you name when you hand off to it.
- Amending the plan between stages is done in its own session, under Rule 3 — never inside the stage that found the problem.

This is stronger than dispatch, not weaker: every stage begins with a clean context, so the context budget in Rule 2 holds by construction rather than by discipline.

## Stage 1 — Plan

Dispatch `glab:project-planner` on the task, as Rules 0c, 0d and 5 say; no stage skill sits in between: the planner preloads `glab:project-plan`, which holds the procedure. The one exception is a `/glab:project-plan <task>` the user types: then you follow `glab:project-plan` Steps 0 to 4 yourself, in this session. Planning here is the user's choice, so it is not a breach of Rule 2 or Rule 5. Every plan request the user does not type as `/glab:project-plan` still goes to `glab:project-planner`. If the user already handed you a plan, skip to the acceptance checklist and apply it to theirs. When the user waives planning, you are the one who writes `plan/{slug}/waived.md`, as `glab:project-plan` *User Override* says.

**A brief is a request.** A session told to take the brief at `<store>/briefs/<project>/brief.md` — by the user or by the product manager — resolves the store from its `glab-shared-store:` line: the first one in the repo's `AGENTS.md`, else in the host file, `~/.claude/host.md`. The planner's dispatch names the brief's store path and the store; how the plan quotes the brief is `glab:project-plan`'s. A plan from a brief goes to Stage 1c after its approval.

**Explore once.** Mapping — read-only agents that read an area of the code before the plan is written — is your call per task. Each mapping agent writes `plan/{slug}/map-<area>.md` — every path it read, `file:line` for what matters, proven kept apart from inferred (`glab:security` Rule 6) — and returns a short report (Rule 2). Name those files in the planning agent's dispatch: it starts from them and reads code only for the gaps it names. Without mapping agents, the planning agent explores itself. Never both over one area: a planner told to explore again re-reads what the map already holds. The name is not `findings-<area>.md` because subagent writes of files named `findings…` have been refused.

**The planning agent, `glab:project-planner`, brings you what it could not settle**, sorted as `glab:project-plan` Step 2 says. You review its `## Decisions` lines under Rule 3, and relay only a Rule 3 question to the user — that one you do not answer on their behalf.

### Plan acceptance checklist

Do not forward a plan to `/glab:project-develop` until all eight hold. Where one fails, say which and send it back.

1. **Understandable.** Every stage is one instruction a competent engineer can act on without asking what it means. No stage says "handle X properly".
2. **Its shape.** Every item `glab:project-plan` Step 3 lists is there, its three phases and its milestone test included.
3. **Findings cover the whole scope surface.** Every file, package, module and directory the change touches or depends on, by path. Each method the change **changes** carries its call sites and what each relies on; each method it only **calls** carries the precondition its new call site must meet and how the plan meets it; a file it only depends on is listed by path, not read in full (`glab:project-plan` Step 1). A findings file or section with no path list has not done this step.
4. **Choices are decided, and a question carries its own context.** Every choice the plan rests on has its line under `## Decisions`. A question for the user — Rule 3 says which, and aims for one at most — states the problem in full, why it blocks the plan, and the recommended answer spelled out with its consequence. "Which approach do you want?" with no options is a shrug, not a question. Send those back.
5. **No stage contradicts another.** Read the stages back to back: no later stage may rewrite, revert or override what an earlier one wrote. A value that must change twice is one stage, not two. This is the check plans fail most often and the one that confuses developers worst.
6. **Within its size.** `glab:project-plan` Step 3 caps `master.md`, `plan.md`, `index.md` and `evidence.md` at 49152 bytes (48 KB) each. Check it by size alone, without reading them (Rule 2): `wc -c` on each that exists, and `grep -c '^- size: ' plan/{slug}/plan.md`. Over the cap with no `- size:` line: send it back to be split or cut. With one: that is a Rule 3 choice of yours — accept it, or send it back to be split.
7. **A master.** `grep -c '^## \(Request\|Goals\|Out of scope\|Final check\|Record\)$' plan/{slug}/master.md` prints `5`, and with sub-plans `index.md` has one line per sub-plan folder. Checked by search, not by reading.
8. **A brief, quoted.** A plan made from a brief: `grep -cE '^- brief: briefs/[a-z0-9-]+/brief\.md sha256 [0-9a-f]{64}$' plan/{slug}/master.md` prints `1`. A plan from a brief without the line, or with another brief's, is sent back: without it nothing reports it and nothing gates it.

Where the work reimplements a documented external API, the findings must cite that vendor documentation by URL. A plan with no citations has unverified behavioural claims.

### A question blocks; a decision does not

A Rule 3 question stops its plan. Bring it to the user with its full context, get the answer, and **write the answer into `plan/{slug}/questions.md` yourself** — after a report to product, into `after-verdict.md` (Stage 1c) — that file is how the developer sees it. Never close that one by assuming an answer, and never turn a choice of your own into one.

**Approval comes after Stage 1b has passed** — the master check, when the work split — so the user approves a checked plan: explicitly at full tier and whenever the work split. At normal tier with no sub-plans, report the tier and the decisions and go on. Then write the last section of `master.md`, `## Approval`, one line — `- approved by the user, <date>, in chat | in plan mode: "<their words>"; base <git rev-parse --short HEAD>`, or `- accepted at normal tier, reported to the user, <date>; base <sha>` — and hash it (*The master plan and sub-plans*). The base is where the final check's range starts. At full tier the user also approves `plan.md`, explicitly — a single plan's together with the master, each sub-plan's after its own Stage 1b — and you end that `plan.md` with its own `## Approval` line in the same form.

### Approval in Claude Code's plan mode — only when the user asks for it

Plan mode ends in an approval dialog that can carry the master's approval (UNVERIFIED: L1). Use it only when the user asked for it, in this session or a standing instruction; otherwise ask in the chat. Only you can: Claude Code gives no subagent the plan-mode tools (UNVERIFIED: L7). Each claim marked UNVERIFIED here is read from Claude Code's documentation and not yet run; the live tests L1–L7, kept in the `glab` repository's `docs/specs/workflow.md` *Known limits and not verified*, settle them. A step whose claim fails: leave plan mode and approve in the chat.

1. **After Stage 1b, with no agent running.** Plan mode blocks your edits and a subagent's until approval (UNVERIFIED: L5): dispatch no agent while in it.
2. **Tell the user first, in one line:** the dialog sets the session's permission mode from then on (UNVERIFIED: L4) — pick the current one, since auto or accept-edits lets the session do more without asking and nothing here relies on it — and changes go through "No, keep planning", not a Ctrl+G edit, which never reaches `master.md` (UNVERIFIED: L3).
3. **EnterPlanMode, then ExitPlanMode with `master.md` as the plan** — its path and its text, read once for this: the one exception to Rule 2 it needs. Whether ExitPlanMode takes the text or only a file, and where that file lands, is UNVERIFIED (L1, L2). If plan mode asks for a plan file outside the repo — `~/.claude/plans` by default — do not write it: ask the user to leave plan mode (Shift+Tab, UNVERIFIED: L3) and approve in the chat. Inside the repo, where the user's own `plansDirectory` put it, write `master.md`'s text there byte for byte and never commit it. Never change that setting.
4. **Approved** → the `## Approval` line says `in plan mode`, with any words the user gave. **"No, keep planning"** → the user leaves plan mode (Shift+Tab, UNVERIFIED: L3) before you dispatch the amendment; their words go into `## Request` (whether the dialog passes them on: UNVERIFIED, L3).

## Stage 1b — Analyze the plan, before any code exists

The acceptance checklist above judges the plan *as a document*. This stage judges
it *against the code*, and it is by far the cheaper of the two places to find
that a step cannot be built.

**Before dispatching `/glab:project-develop`, dispatch `glab:project-plan-analyzer` agents against the plan itself**, split by surface (*Running agents in parallel*). What each one checks, and the case that showed why this stage exists, is `glab:project-plan-analyzer` *The plan check*.

**`BUILDABLE`** → the approval (Stage 1), then Stage 2 — Stage 1c first for a plan from a brief — or, after the master check, the sub-plans, which for a plan from a brief are all planned, checked and approved before Stage 1c. **`NOT BUILDABLE`** → an amendment, with exactly what is missing; a missing choice is decided under Rule 3 first. **Never patch the steps yourself to make them buildable** — for the same reason Stage 3 forbids editing `plan.md` to resolve a divergence.

**The amendment goes to a new planning agent**, `glab:project-planner` (Rule 2). Before you dispatch it, keep the version the round checked: `cp plan/{slug}/plan.md plan/{slug}/plan.r<n>.md`, and `evidence.md` to `evidence.r<n>.md` when there is one — `findings.md` to `findings.r<n>.md` in a folder from before `glab` 0.10.0 — `<n>` being the round that checked them. The same holds for `master.md` before its approval — after it, the planner's version copy `master.v<n>.md` (`glab:project-plan` Step 4) — and for `index.md`, each copied as `<name>.r<n>.md` beside it; a master check has no `plan.md` to copy. Give the new agent the slug, that this is the amendment after plan check round `<n>`, the round's findings copied as the analyzers returned them. It reads the plan files from disk, changes what the findings name and what that forces, as `glab:project-plan` Step 4 says, and leaves the `.r<n>` copies as they are.

**A re-check looks at the delta, not the whole plan.** Before round `<n+1>`, test that the amendment changed something, by exit code alone — do not read the diff yourself (Rule 2): `cmp -s plan/{slug}/<name>.r<n>.md plan/{slug}/<name>.md` for each file the round checked — `plan.md`, `evidence.md` (`findings.md` in a folder from before `glab` 0.10.0), and `master.md` and `index.md` where it checked them. Exit 1 on any file means the amendment changed the plan; exit 0 on every file means it changed nothing — send it back, do not re-check it; exit 2 means a file is missing — find out why first. Give each analyzer of round `<n+1>` the previous round's findings, copied as returned, and the file pairs; the analyzer runs `diff -u` and reads the diff. It checks each of those findings, every line the diff changes and every step that rests on a changed line — the post-condition question included — and not the rest of the plan, which already passed.

**At most 2 rounds, a third under `glab:session-rules` *Round caps*.** A plan still `NOT BUILDABLE` after round 2 with no round 3: at full tier it needs a design, not another pass — bring that to the user; at normal tier a new planning agent amends once more from what the analyzers found and the plan goes on — the developer's `PLAN WRONG` is the backstop. Still `NOT BUILDABLE` after round 3, at any tier: bring it to the user.

## Stage 1c — Report to product, then wait

For a plan from a brief — its `master.md` carries the brief line — once per slug. When the master and, if the work splits, every sub-plan have been planned, checked at Stage 1b and given every approval their tiers need, run `/glab:project-plan-report {slug}`: one report covers the master and every sub-plan — one report and one verdict per slug, so the product audits the slug once, not once per sub-plan, and each sub-plan's `glab:project-develop` checks against that one accepted digest.

Announce `{slug} · report · r<n> · WAITING · context <n>k` — no agent runs, so the line names no model or effort. Tell the product session that the report is there: a session the product session started is watched by its idle notice and needs no message; else `SendMessage` to the product session when `ListAgents` lists it; else ask the user to. Bring the handoff file up to date with the report's path, and end the turn.

**From the first report on, the plan's hashed files are frozen.** `master.md`, `index.md`, every `plan.md`, `questions.md` and every `steps-*.md` are what the product judges and `glab:project-develop` checks by their hash. Each line `glab:session-rules` or this skill says to write into one of them — an `- effort:` or `- model:` line, a `- round 3:` line, a Rule 3 decision or overrule, a question's answer — goes to `plan/{slug}/after-verdict.md` instead, in the form it would have had, and that file is named in every later dispatch that reads the plan. A line there never changes a step, a goal or a decision the product accepted: that is an amendment, and Stage 1c again. The freeze lifts only for the amendment after a `REJECTED`, until the next report.

On resuming, read the latest `verdict.r<n>.md` of the brief, the numbers compared as numbers:

- `ACCEPTED` → Stage 2, whose `glab:project-develop` checks it.
- On REJECTED: keep the round copies as Stage 1b does, numbered one past the highest round copy there; dispatch a new `glab:project-planner` for the amendment, with the verdict's reason quoted as its findings; run one Stage 1b delta round — one per verdict, which neither resets nor uses Stage 1b's round cap; still `NOT BUILDABLE` after it → the user. Then the approvals the tier needs again — at full tier the user approves `plan.md` again and its `## Approval` line is replaced — and Stage 1c again, which sends report `r<n+1>`. A `REJECTED` whose fix needs `master.md` — a goal, the final check — is a changed request, not an amendment (*The master plan and sub-plans*).

A refusal from `glab:project-develop` that the plan changed since it was accepted — a `PLAN WRONG` amendment, say — is Stage 1c again; one that the brief changed is a changed request. The rejection cap is the product level's; this session reports and waits.

## Stage 2 — Develop

Run `/glab:project-develop {slug}`. Split it as *Running agents in parallel* says.

Give each `glab:project-developer` dispatch (Rule 0c):

- the slug and the exact step ids it owns, its file boundary when the work is split, and with sub-plans the paths *The master plan and sub-plans* names;
- **the resolved answers** from `questions.md` and anything decided in this conversation that is not written in the plan — the agent cannot see this chat;
- **your own suggestions**, marked as suggestions, so they are not mistaken for plan steps;
- **for a fix round** — after `DIVERGES`, review findings or integration regressions: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps.

Do not paste the plan. The agent reads it; a paraphrase is how a step quietly changes meaning.

### What you require back

`plan/{slug}/result.md` and the short reply, as `glab:project-developer` Step 5 and *Report* have them, checked as Rule 5 says.

### Verify before moving on

An agent's report is not evidence. Run the gate line you recorded (*Know the gates before you dispatch*, `glab:bootstrap` step 3) yourself, in the order and under the changed-code-gate rule of `glab:project-developer` Step 3; `glab:security` Rules 3 to 5 hold.

- `PLAN WRONG` → stop the build. Amending the plan is a Rule 3 decision — yours when it is an engineering choice, the user's when it meets an ask-condition — made through a new planning agent and recorded under `## Decisions`, never made by the developer; then this stage again.
- `BLOCKED: <reason>` → decide whether it is unblockable: a missing decision is yours under Rule 3 unless it meets an ask-condition; a dependency on another slice means the split was wrong — re-dispatch rather than patch it yourself.
- `BUILT` and every gate green → the next stage: Stage 3 at full tier and for every sub-plan, Stage 4 at normal tier with no sub-plans.

If you find yourself fixing an agent's work beyond a mechanical consequence, you have taken over the implementation (Rule 1), and the split stopped meaning anything.

## Stage 3 — Analyze

**Full tier, and every sub-plan at every tier.** At normal tier with no sub-plans the step list in `result.md` is the conformance record: every step `done`, gates green by your own run, then Stage 4; the intent question waits for the final check (Stage 6b).

Read `result.md` — it is written for you and stays short. Summarise it to at most 10 lines for the user, then run `/glab:project-analyze {slug}` with the slug and that summary.

The analyzer answers one question: **did we build what the plan said?** Not whether the code is correct — that is Stage 5. Do not let it drift. Where the folder has a master it also asks the intent question: does the build serve the master's goals, beyond matching the steps? A step built as written that misses its goal is a defect of the plan: it goes to a planning agent's amendment, then Stage 2 — never to a developer told to build past its plan.

**`CONFORMS` → Stage 4.** **`DIVERGES` → back to Stage 2** with only the diverging steps in scope, as a fix round. **At most 2 develop→analyze rounds, a third under `glab:session-rules` *Round caps*.** Say the round number every time: `analyze round 2/2`.

**A re-check looks at the delta.** Before you dispatch each analyze round, round 1 included, snapshot the tree it will measure — tracked, staged and untracked files, without touching the index — with an index path that does not exist yet, in the session's temp directory. The index is seeded from `HEAD` first, so a tracked file that matches `.gitignore` is not dropped:

    idx=<temp directory>/<slug>-analyze-r<n>.idx; rm -f "$idx"
    GIT_INDEX_FILE="$idx" git read-tree HEAD && GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"

It prints a tree id; name it in that round's dispatch. In a repository with no commit yet `git read-tree HEAD` fails and nothing is printed: that round has no tree id. Round `<n+1>` gets the previous round's findings, copied as returned, and both tree ids; it reads `git diff --stat <old> <new>` and `git diff <old> <new>` and checks each previous finding, every step whose files the delta touches, and anything in the delta that no step asked for — not the steps the delta leaves alone. `git diff --quiet <old> <new>` exiting 0 after a fix round means nothing changed: stop and find out why. Ignored files are not in a snapshot, so a path the fix round's `files:` line names and the delta does not show is checked whole; a tree id you no longer have means that round runs whole.

Still diverging after the last round → stop and bring it to the user with the three honest resolutions: change the code, change the plan (a Rule 3 decision — yours when it is an engineering choice, the user's when it meets an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer), or cut the scope. Never edit `plan.md` to make a divergence disappear — that turns the contract into a description of whatever was built.

## Stage 4 — Integrate

Run `/glab:project-integrate {slug}`. The `glab:project-integrator` agent checks or starts the external dependencies, starts the service and runs the repo's existing integration or E2E suite — at normal tier only the milestone test, as its Step 1 says. You start no service and run no suite yourself.

- **Skip this stage only when the change cannot be exercised at runtime** (documentation, plan files, a pure refactor with no behavioural change). Say you are skipping it and why; do not silently pass it.
- `INTEGRATED` → Stage 5. `FAILED: <n> regressions` → Stage 2 as a fix round, with only the failing behaviour in scope.
- `BLOCKED: no suite` → ask the user where the suite lives — the agent does not invent one. When the user names the path, **write it to memory** so no later session asks again. Any other `BLOCKED: <reason>` → do what would unblock it, under Rule 3, or bring it to the user.

## Stage 5 — Review

Run `/glab:project-review` on the working tree.

**The reviewer is an external auditor.** Give it the target and nothing else — **not the slug, not the plan, not the findings, not what the plan intended.** From round 2 on it is a new reviewer (Rule 2) and gets two things more: the previous review round's findings, copied as it returned them, and the range of the fix — the tree id of the tree that round reviewed and of the tree now, each taken with Stage 3's snapshot, or two commit ids when the fix is committed. Still never the slug, the plan or the intent. It cares about correctness and security, not conformance; conformance was Stage 3. Do not defend the plan to it and do not re-rank its severities.

Findings → back to Stage 2 as a fix round, then the stages after it at that tier, then Stage 5 again. At full tier, Stage 3 after a review fix is one delta round per review fix, against the tree id the last `CONFORMS` measured, and the analyzer is also given the review findings the fix answered; it neither resets nor uses Stage 3's round cap. A `DIVERGES` there goes back to Stage 2 inside the same review round, and that fix goes on to Stage 5 without another Stage 3 round. **At most 2 review rounds, a third under `glab:session-rules` *Round caps***, at every tier. Before each review round, snapshot the tree it will review as Stage 3 does. Tell the reviewer which round this is and which is the last; what it answers in each is `glab:project-reviewer` *Re-reviews*. A last round's answer goes to the user, whichever it is. Rule 5's report check is for a report with missing fields or no clear verdict only.

A fix that grows past its finding, or lands in full-tier code, raises the tier.

When the reviewer reports that a round's findings sit mostly in the previous round's fix (`glab:project-reviewer` *Re-reviews*), cut scope rather than adding another guard.

## Stage 6 — Commit

Run `/glab:commit`. The `glab:committer` re-reads the change at a high level, then splits it into logical commits — one coherent change each — in the repo's commit format.

With sub-plans, commit each one after its Stage 5: its own folder, and with the first also `master.md`, `master.sha256`, `index.md` and the map files. Nothing is pushed before the final check.

Its deny-list is authoritative: nested repositories, credentials and `.env` files, local noise, and anything the user did not ask about. **A refusal to stage is the correct outcome** — relay the reason, never work around it. Verify the file list from `git show --stat` matches what you expected. A commit on `main`: `glab:commit`.

## Stage 6b — Final check

After the slug's last commit, before the push, at normal and full tier: `/glab:project-analyze {slug}` as the final check. The analyzer reads `master.md`, `index.md` (the plan, with no index) and the range from the `## Approval` base to `HEAD`, and asks of every goal whether it is delivered, and where. Run the gates yourself on that tree. Skipped only for a single plan at full tier, whose Stage 3, delta rounds included, asked it.

`CONFORMS` → Stage 7. `DIVERGES` → the gaps go to a new planning agent: with sub-plans, a new sub-plan with the next `<nn>` and its line in `index.md`; without, an amendment of `plan.md`. It runs its cycle to its commit; round 2 gets round 1's findings and the two commit ids. At most 2 rounds, a third under `glab:session-rules` *Round caps*, its line in `index.md` (`plan.md` with no sub-plans); still diverging: bring it to the user.

## Stage 7 — Push

Run `/glab:push`. There is deliberately **no push agent**: a push leaves the machine, so you stay in the loop rather than relaying an agent's report about something already sent. `/glab:push` shows what will go out — the `## Decisions` lines of each plan it carries included — and waits for the user's go-ahead.

After the push, confirm the commits actually landed on the remote branch and report the branch, the commits and the PR URL if git printed one. A change with a plan folder goes on to Stage 8.

## Stage 8 — Record

After Stage 7 has confirmed the push. What stays true moves into the spec of each area the change touched: `glab:project-plan` *Plan files are working files* is the rule, and `docs/specs/` the place unless the repo's `AGENTS.md` names another. The record changes the spec and nothing else. It never removes `plan/{slug}/` or an audit file: that is the repo's own `AGENTS.md` decision, carried out outside this stage. It is an ordinary docs change, through the normal commit and push.

- Dispatch `glab:project-developer` for the record alone: the slug, the area specs `master.md`'s `## Record` names — `plan.md`'s, with no master — (for a waiver, the ones you name), and any audit file it names as a source. It writes the spec from the folder's files, sub-plan folders included and the audit file, carries every follow-up still open, every binding decision and every incident with its source file and number, and changes nothing inside the folder.
- Dispatch `glab:project-analyzer` for the record check, at every tier: the spec diff against the folder's files and the audit file. `DIVERGES` goes back to a new developer once (Rule 2), then to the analyzer again, which checks the fix; still `DIVERGES`: stop and tell the user.
- At full tier, one `glab:project-reviewer` pass on the spec diff alone — the target and nothing else, as in Stage 5. Its findings go back to a new developer once, and the analyzer checks that fix too.
- Then `/glab:commit` with the spec files, and `/glab:push` on its own go-ahead.

A decision made at this stage goes in the dispatch and in the spec, not in `plan.md`: the folder is the record's source and does not change. A plan folder whose `master.md` — or `plan.md`, with no master — has no `## Record` predates the rule and is not recorded here.

## What you never do

- Break `glab:session-rules` Rule 0b (a gate reported on an agent's word), Rule 1 (implementing), Rule 2 (resuming an agent, `/clear`, `/compact`) or Rule 3 (a choice sent to the wrong side, `docs/constants.md`, a push without the user's go-ahead).
- Lower a tier (*Pick the tier*).
- Edit `plan.md` to resolve a divergence (Stage 3).
- Give the reviewer the plan, `master.md` or `index.md` (Stage 5).
- Run a fix-mode linter (`glab:security` Rule 5), or treat a whole-tree backlog sweep as a gate.
- Force-push at all (`glab:push`).
- Start, stop or restart a service outside Stage 4.
- Remove `plan/{slug}/` or an audit file as part of the record (Stage 8).
- Edit `master.md` after its `## Approval`, or enter plan mode the user did not ask for.
