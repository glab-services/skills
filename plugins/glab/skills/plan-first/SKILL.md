---
name: plan-first
description: Mandatory analyze-then-plan-then-implement workflow. Use for every non-trivial task — feature, bug fix, refactor, flow change, or integration — before touching code. Writes findings, decisions, and a plan to plan/{slug}/, only then implements, builds, and tests, and once the change is pushed records it in the area spec under docs/specs/. Triggers whenever the user asks to build, fix, refactor, integrate, or investigate something in the codebase. Skip only for trivial one-line changes.
---

# Plan First

Analyze, plan, then execute. No implementation without a plan.

```
size → analyze → decide → plan → verify → implement → E2E tests → unit tests
```

## Step 0 — Size the Task

- **Trivial** (skip this workflow): single-line changes, typo fixes, config one-liners, obvious renames, adding a known import — anything under ~5 lines with no architectural impact. Do it directly.
- **Non-trivial** (follow the workflow): anything that touches logic, spans multiple files, changes behavior, introduces new concepts, or requires understanding existing code first.

When in doubt, treat it as non-trivial. Non-trivial work is **normal** or **full** tier — `glab:manager` → *Pick the tier* says which. Normal tier writes one page: `plan.md` alone, with findings and decisions as sections of it. Map files the manager's mapping agents wrote, `map-<area>.md`, sit beside it (Step 1). Full tier writes the separate files below.

## Step 1 — Analyze

Write findings to `plan/{slug}/evidence.md` — not `findings.md`: Claude Code refuses a subagent's Write of a file by that name. Include:

- Scope: what exists, what's missing, dependencies, risks.
- The spec of each area the change touches, read first — `docs/specs/<area>.md`, or where the repo's `AGENTS.md` puts specs. Its decisions still bind, its known limits still hold, and its open follow-ups may already describe this task.
- Exact file paths and line numbers for the code under change.
- Separate **Proven behavior** from **Inferred behavior**. Never present inferred runtime behavior as proven.
- Candidate implementation boundaries, and at least one rejected approach with a short reason.

**Start from the map when there is one.** When `plan/{slug}/map-<area>.md` files exist — written by mapping agents the manager dispatched (`glab:manager` Stage 1, *Explore once*) — they are the analysis of their area. Start from them, write down the gaps they leave that the plan needs, and read code only for those gaps, naming each in your findings. Do not re-read a path a map already read unless a gap names it. With no map, you explore yourself.

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

- **A fact** — an existing method's runtime semantics; whether an intended call can express the required behavior correctly; rollback, delete, or cleanup semantics; versioning, object-lock, or state-transition behavior; ownership/lifecycle on streamed, file, or network paths. Prove it from the code: read the callers, run it. A behavior-critical point you cannot prove stays **Inferred**, and the step that proves it goes before the step that depends on it. Do not assume, and do not ask the user what the code can answer.
- **A choice** — decide it, and write one line under `## Decisions` in `plan.md`: the choice and why. The manager reviews those lines and may overrule one, recording the overrule as a new line. `glab:manager` Rule 3 is the rule.
- **The user's** — destructive, costs money, exposes real data, or changes what the product is. Write it to `plan/{slug}/questions.md` with its context and your recommended answer, and stop until it is answered. At most one per plan is the target.

**If you cannot find it, say so.** When you search for a method, function, binary, or code path and cannot locate it, do not conclude it does not exist, guess its location, or silently skip it. Show the search that would have found it; if the plan depends on it, report that as a blocker.

## Step 3 — Write the Plan

Write to `plan/{slug}/plan.md`. Must include:

- the tier and its one-line reason, as the first line;
- `## Decisions` — every choice made in Step 2, one line each;
- the milestone: what runs end to end when this plan is done, and the test that proves it. A feature plan that leaves nothing new running is a slice — fold it into the plan that finishes the milestone. A refactor, config or test-only plan has no new behaviour to run: its milestone is the existing test that proves nothing broke;
- ordered steps with exact files and expected changes;
- verification criteria per step;
- test names to be added or updated;
- the chosen implementation boundary;
- why the other candidate boundaries were rejected;
- `## Record` — the area spec or specs this change updates once it is pushed, any audit file under `plan/` it acts on, and what the entry will say. `glab:manager` Stage 8 runs it (*Plan files are working files*).

Do not prescribe a concrete implementation shape until the boundary is proven by findings and recorded decisions. The plan must be complete enough that another agent could execute it without follow-ups.

**Size and shape — every later agent reads the plan again**, round after round, so every line is paid for many times. Keep `plan.md` and `evidence.md` at or under **48 KB** each (`wc -c`). A decision is one line: the choice and its reason, in at most two sentences; its evidence stays in `evidence.md` and is cited by id, never restated. Write a fact once, where it belongs, and cite it elsewhere. A plan that will not fit is usually two plans: split it. When it cannot be split, say why under `## Decisions` as `- size: <n> KB — <why it is one plan>`, and the manager decides (`glab:manager` Rule 3).

## Step 4 — Verify the Plan

Before implementing, confirm:

- every gap is proven, decided, or answered by the user;
- the plan covers every finding, with no gaps left;
- at full tier, the user has approved the plan;
- the call-site review is complete for any changed existing method, and every method the plan only calls has its precondition recorded;
- the chosen boundary is proven by the semantics of the existing implementation — not by naming or file placement;
- rollback/delete/state semantics are proven where relevant;
- ownership/lifecycle risks are reviewed on resource-sensitive paths.

**Amending after a plan check.** Under `glab:manager` an amendment after `NOT BUILDABLE` is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:manager` Stage 1b). Change what the findings name and what that forces, and **replace the text you change, in place**: the step, the finding or the decision line is rewritten under its own id, a changed choice with its new reason. Never append an amendment section, a "superseded" line or a round marker beside the old text — the `<name>.r<n>.md` copies the manager kept are the history; leave them as they are. A line the manager added to overrule a decision stays as the manager wrote it. Step 1 is not run again, except for a gap a finding opens.

## Steps 5 to 7 — Implement, E2E tests, unit tests

They are in [`implement.md`](implement.md), beside this file, with the repo rules that bind only the implementation — service lifecycle, nested repositories, commits. Read it once the plan is verified (Step 4) and, at full tier, approved. **A planning agent stops at Step 4 and does not read it.**

## Repo Rules

**Plan files are working files; the spec is what stays.** Once the change is pushed, `glab:manager` Stage 8 records it: a docs change updates the spec of each area the change touched — how the area works now, the decisions that still bind, what is not verified, and every follow-up still open and every incident, each under its source file and number. Specs live in `docs/specs/`, one file per area, unless the repo's `AGENTS.md` names another place. The record never removes `plan/{slug}/` or an audit file: whether a recorded plan folder is then removed, and how, is the repo's own `AGENTS.md` decision. A plan folder whose `plan.md` has no `## Record` was written before the repo followed this rule, and Stage 8 does not record it.

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

If the user explicitly waives planning after you flag it ("I already know what I want, just do it"), accept it and write `plan/{slug}/waived.md` with the date, what was waived, and their reason. Then implement, from [`implement.md`](implement.md). This keeps the paper trail without blocking work. Its folder is recorded like a plan's (*Plan files are working files*).

## Quick Reference

| Phase | Output | Location |
|-------|--------|----------|
| Analyze | Findings | `plan/{slug}/evidence.md` |
| Decide | Decisions; one question at most | `## Decisions` in `plan.md`; `plan/{slug}/questions.md` |
| Plan | Implementation steps | `plan/{slug}/plan.md` |
| Verify | Plan review | with the user, at full tier |
| Implement | Code changes | the repo |
| E2E tests | the repo's canonical runner | wherever the suite lives |
| Unit tests | the repo's test target | the repo |
| Record | Spec entry | the area spec, after the push (`glab:manager` Stage 8) |
