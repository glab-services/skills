---
name: project-plan
description: Project level — The analyze-then-plan procedure (size, analyze, decide, plan) before any code exists, that glab:project-planner follows and a user runs by typing /glab:project-plan <task>. Any other build, fix or investigation goes to glab:project-planner. Writes findings, decisions and a plan to plan/{slug}/ and stops. Skip only for trivial changes (glab:session-rules Rule 1).
argument-hint: "[what to build or fix]"
---

# Plan

Analyze, then plan. No implementation without a plan.

**The task** is what follows `/glab:project-plan` when a person types it — $ARGUMENTS — or, when nothing does, as when `glab:project-planner` preloads this skill, the task its dispatch or the user names.

```
size → analyze → decide → plan → verify
```

## Step 0 — Size the Task

- **Trivial** (skip this workflow): under `glab:session-rules` Rule 1's line. Say so and stop.
- **Non-trivial** (follow the workflow): anything that touches logic, spans multiple files, changes behavior, introduces new concepts, or requires understanding existing code first.

When in doubt, treat it as non-trivial. Non-trivial work is **normal** or **full** tier. **Full** is not a judgment call: a schema or data migration, a change to a stored or wire format, and code that decides who may do what, handles secrets or moves money. **Trivial** is Rule 1's line; **normal** is everything else. A `plan.md` with no tier line is full tier. Normal tier writes `master.md` and one page, `plan.md`, with evidence and decisions as sections of it. Map files the manager's mapping agents wrote, `map-<area>.md`, sit beside it (Step 1). Full tier writes the separate files below.

## Step 1 — Analyze

Write findings to `plan/{slug}/evidence.md` at full tier and as the evidence section of `plan.md` at normal tier — never to `findings.md`: Claude Code refuses a subagent's Write of a file by that name. Include:

- Scope: what exists, what's missing, dependencies, risks.
- The spec of each area the change touches, read first — `docs/specs/<area>.md`, or where the repo's `AGENTS.md` puts specs. Its decisions still bind, its known limits still hold, and its open follow-ups may already describe this task.
- When the task is a brief, the product-rule files the brief names bind like `docs/constants.md`: read each from the store, and the plan conforms to them.
- Exact file paths and line numbers for the code under change.
- Separate proven from inferred, as `glab:security` Rule 6 defines them. Never present inferred runtime behavior as proven.
- Candidate implementation boundaries, and at least one rejected approach with a short reason.

**Start from the map when there is one.** When `plan/{slug}/map-<area>.md` files exist — written by mapping agents the manager dispatched — they are the analysis of their area. Start from them, write down the gaps they leave that the plan needs, and read code only for those gaps, naming each in your findings. Do not re-read a path a map already read unless a gap names it. With no map, you explore yourself.

**Call-site audit.** For every existing method or function the plan **changes** — its signature, return values, error cases, timing or behaviour — grep its real usage across the codebase first and record:

- the caller list;
- what each caller appears to rely on;
- whether the contract is shared or caller-specific.

For every method the plan calls from a new call site, record the precondition that call site must meet and how the plan meets it. For a method it only **calls**, that is all: its other callers are not audited, because nothing they rely on changes.

Do not assume how a method behaves from its name or signature alone: read the precondition from its body or its documented contract.

A file the change only depends on — imported, configured, read — is listed by path and not read in full; read only the part a precondition or a finding needs.

**State transitions** — required for rollback, delete, overwrite, versioning, and object-lock-sensitive flows:

- state before the operation;
- state after success;
- state after failure;
- the exact object/version/revision/resource affected.

**Ownership and lifecycle** — required for streamed, file, network, and resource-sensitive paths:

- who opens, who reads/writes, who closes/finalizes;
- whether the proposed direction risks double-read, double-close, FD leak, or hidden buffering.

## Step 2 — Decide

Sort every gap Step 1 left open. Each is one of three things:

- **A fact** — an existing method's runtime semantics; whether an intended call can express the required behavior correctly; rollback, delete, or cleanup semantics; versioning, object-lock, or state-transition behavior; ownership/lifecycle on streamed, file, or network paths. Prove it with a command — grep the callers, run it (`glab:security` Rule 6). A behavior-critical point you cannot prove stays **Inferred**, and the step that proves it goes before the step that depends on it. Do not assume, and do not ask the user what the code can answer.
- **A choice** — decide it, and write one line under `## Decisions` in `plan.md`: the choice and why. The manager reviews those lines and may overrule one, recording the overrule as a new line. `glab:session-rules` Rule 3 is the rule.
- **The user's** — destructive, costs money, exposes real data, or changes what the product is. Write it to `plan/{slug}/questions.md` with its context and your recommended answer, and stop until it is answered. At most one per plan is the target.

**If you cannot find it, say so.** When you search for a method, function, binary, or code path and cannot locate it, do not conclude it does not exist, guess its location, or silently skip it. Show the search that would have found it; if the plan depends on it, report that as a blocker.

## Step 3 — Write the Plan

Write to `plan/{slug}/plan.md`. Must include:

- the tier and its one-line reason (Step 0), as the first line;
- `## Decisions` — every choice made in Step 2, one line each;
- the milestone: what runs end to end when this plan is done, and the test that proves it. A feature plan that leaves nothing new running is a slice — fold it into the plan that finishes the milestone. A refactor, config or test-only plan has no new behaviour to run: its milestone is the existing test that proves nothing broke;
- ordered steps with exact files and expected changes, in three phases: `before` — preconditions, the gate run green, flags, what must be true to start; `processing` — the ordered change steps; `after` — verification, the milestone test, documentation, and how to back the change out;
- verification criteria per step;
- test names to be added or updated;
- the chosen implementation boundary;
- why the other candidate boundaries were rejected;
- `## Record`, in `master.md` (below) — the area spec or specs and the feature pages it writes, or `feature pages: none`, that this change updates once it is pushed, any audit file under `plan/` it acts on, and what the entry will say. `glab:project-record` runs it (*Plan files are working files*).

Do not prescribe a concrete implementation shape until the boundary is proven by findings and recorded decisions. The plan must be complete enough that another agent could execute it without follow-ups.

**Size and shape — every later agent reads the plan again**, round after round, so every line is paid for many times. Keep `master.md`, `plan.md`, `index.md` and `evidence.md` at or under **48 KB** each (`wc -c`). A decision is one line: the choice and its reason, in at most two sentences; its evidence stays in `evidence.md` and is cited by id, never restated. Write a fact once, where it belongs, and cite it elsewhere. A plan that will not fit is usually two plans: split it (below). When it cannot be split, say why under `## Decisions` as `- size: <n> KB — <why it is one plan>`, and the manager decides (`glab:session-rules` Rule 3).

### The master plan, and sub-plans when the work splits

Every plan folder starts with `plan/{slug}/master.md` — what the user asked for, constant once accepted; the plans say how. It holds:

- `## Request` — the user's words that define the task, verbatim and dated, later words added the same way until approval. Never paraphrase them: every intent check reads them.
  When the task is a brief, `## Request` holds the brief verbatim, dated, under its brief line `- brief: briefs/<project>/brief.md sha256 <hash>`, the hash being `sha256sum` of the brief as it was read. The brief is the request's words, and its `## Acceptance` reaches the goals like any other request.
- `## Goals` — `G1`, `G2`, …: one line each, what must be true for the user when done, citing its words, saying no more and no less.
- `## Out of scope` — what the user excluded, in their words, or `none`.
- `## Final check` — the test that shows the whole request done, end to end.
- `## Record` — the record, as Step 3 says.
- `## Approval` — the manager writes it (`glab:project-plan-accept`); you never do. After it the master is never edited.

**One plan by default** — one `plan.md` beside the master — when the work has one milestone and fits the size budget. **Split it** only into parts that each serve their own goals, carry their own milestone test and can be built, reviewed and committed one after another. Each part is a sub-plan: a folder `plan/{slug}/<nn>-<name>/` that is a plan folder under every rule of this skill — its own `plan.md`, tier line, evidence as Step 1 says, `questions.md` and round copies. `<nn>` is two digits in build order, never reused or renumbered; `<name>` is kebab-case. Files the repo requires to change in one commit belong to one sub-plan.

The split goes into `plan/{slug}/index.md`, one line per sub-plan — `<nn>-<name> · goals G1, G3 · depends <nn>-<name>, … | none · tier <normal | full>` — and a `## Decisions` section for choices about the split. Every goal is on at least one line.

**Planning in cycles.** The first planning agent writes `master.md` and, when the work splits, `index.md` — no sub-plan yet. Each sub-plan is then planned by its own agent from `master.md`, its own `index.md` line and the map files it needs — `plan/{slug}/map-<area>.md`, at the slug's level — never from another sub-plan, once what it depends on is committed, so it cites the tree it will be built on. When the task is a brief, every sub-plan is planned before any is built — from the tree the slug starts on and its own `index.md` line, never another sub-plan's folder, because one report to product covers the master and every sub-plan (`glab:project-plan-report`). A sub-plan that needs another goal or another sub-plan's files says so and does not reach into them: the split is the manager's.

## Step 4 — Verify the Plan

Before the plan goes to the plan check, confirm what follows; the check and the approval after it are `glab:project-plan-analyze`'s and `glab:project-plan-accept`'s, and `/glab:project-develop` checks both before any code is written:

- every gap is proven, decided, or answered by the user;
- the plan covers every finding, with no gaps left;
- the call-site review is complete for any changed existing method, and every method the plan only calls has its precondition recorded;
- the chosen boundary is proven against the existing implementation by a command you ran (`glab:security` Rule 6) — not by naming or file placement;
- rollback/delete/state semantics are proven where relevant;
- ownership/lifecycle risks are reviewed on resource-sensitive paths.

**Amending after a plan check.** Under the project manager, an amendment after `NOT BUILDABLE`, or after a REJECTED verdict, is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:project-plan-analyze`) — after a verdict, its reason is the round's findings (`glab:project-plan-report`). Change what the findings name and what that forces, and **replace the text you change, in place**: the step, the finding or the decision line is rewritten under its own id, a changed choice with its new reason. Never append an amendment section, a "superseded" line or a round marker beside the old text — the `<name>.r<n>.md` copies the manager kept are the history; leave them as they are. A line the manager added to overrule a decision stays as the manager wrote it. No round amends a `master.md` that has an `## Approval` line. When the user changes the request and your dispatch grants it, copy the old master to `master.v<n>.md` — a version copy, never `.r<n>` — and write a new `master.md` with no `## Approval` line; its hash, its approval and its plan check are the manager's (`glab:project-plan-accept`). Step 1 is not run again, except for a gap a finding opens.

## After Step 4

The build is `glab:project-developer`'s, through `/glab:project-develop`; the E2E run is `glab:project-integrator`'s (Stage 4). A planning agent stops at Step 4.

## Repo Rules

**Plan files are working files; the docs are what stay.** `/plan/` is ignored by git and never committed; a repo without the line adds `/plan/` to `.gitignore` (`glab:bootstrap` step 5). After the push, `glab:project-record` writes from `plan/<slug>/` on disk: a docs change updates the spec of each area the change touched in `docs/specs/`, one file per area — how the area works now, the decisions that still bind, what is not verified, and every follow-up still open and every incident, each under its source file and number — and each feature page `docs/features/<feature>.md` whose user-visible behaviour changed. A feature page (kebab-case; the area's name when the area is one feature) says what the feature does, who it is for and how to use it: commands, inputs, outputs, and the limits a user meets; it never holds decisions, incidents, follow-ups or records, which stay in the spec. Both go where the repo's `AGENTS.md` names other places, if it does. The record never removes `plan/{slug}/` or an audit file. Once the record has landed on the default branch, the manager lists the folder at a session start (`glab:bootstrap` step 5) and removes it only on the user's word (`glab:session-rules` Rule 2); the docs are then the only copy. A plan folder whose `master.md` — or `plan.md`, in a folder with no master — has no `## Record` was written before the repo followed this rule, and Stage 8 does not record it.

**One slug per task.** Reuse the same folder for findings, questions, and plan.

## Slug Naming

| Prefix | Use |
|--------|-----|
| `bug-{name}` | bug fixes (e.g. `bug-create-bucket-gaps`) |
| `feature-{name}` | new features |
| `flow-{name}` | workflow changes |
| `audit-{name}` | audits and analysis |

Use the task ID instead if the user provides one.

## User Override

If the user explicitly waives planning after you flag it ("I already know what I want, just do it"), accept it and write `plan/{slug}/waived.md` with the date, what was waived, and their reason. Only the user's own words make a waiver: never write one on the user's behalf — not to save a stage, and not because a task looks simple. Then `/glab:project-develop` builds from it: the waiver stands in for the verified, approved plan. This keeps the paper trail without blocking work. Its folder is recorded like a plan's (*Plan files are working files*).
