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

When in doubt, treat it as non-trivial. Non-trivial work is **normal** or **full** tier — `glab:manager` → *Pick the tier* says which. Normal tier writes one page: `plan.md` alone, with findings and decisions as sections of it. Full tier writes the separate files below.

## Step 1 — Analyze

Write findings to `plan/{slug}/findings.md`. Include:

- Scope: what exists, what's missing, dependencies, risks.
- The spec of each area the change touches, read first — `docs/specs/<area>.md`, or where the repo's `AGENTS.md` puts specs. Its decisions still bind, its known limits still hold, and its open follow-ups may already describe this task.
- Exact file paths and line numbers for the code under change.
- Separate **Proven behavior** from **Inferred behavior**. Never present inferred runtime behavior as proven.
- Candidate implementation boundaries, and at least one rejected approach with a short reason.

**Call-site audit.** For every existing method or function you plan to change or call, grep its real usage across the codebase first and record:

- the caller list;
- what each caller appears to rely on;
- whether the contract is shared or caller-specific;
- whether the call site you are designing can satisfy its preconditions.

Do not assume how a method behaves from its name or signature alone.

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

## Step 4 — Verify the Plan

Before implementing, confirm:

- every gap is proven, decided, or answered by the user;
- the plan covers every finding, with no gaps left;
- at full tier, the user has approved the plan;
- the call-site review is complete for any changed existing method;
- the chosen boundary is proven by the semantics of the existing implementation — not by naming or file placement;
- rollback/delete/state semantics are proven where relevant;
- ownership/lifecycle risks are reviewed on resource-sensitive paths.

## Step 5 — Implement

**Strict scope. The plan is a closed list.** Implement the steps it names and nothing else.
Every hunk you write must map to a named step. If it does not, it does not go in this change.

This binds hardest on things that look like improvements:

- A bug you spotted in passing — even one the plan's own findings called out as
  *"pre-existing, unrelated, out of scope."* Out of scope means out of scope.
- A better file layout than the plan's target tree. If the plan says two files, write two files.
- A richer API than the step described. "Move it as-is" means move it as-is — no new exported
  interface, no new option family, no new result types.
- Errors, constants, helpers or config defaults for machinery a later plan will build.
  A plan that forbids a registry also forbids the registry's vocabulary.
- Renames, import regrouping, formatting sweeps, and stray blank lines left where deleted
  code used to be.

The only changes allowed beyond the plan's text are the **unavoidable mechanical consequences**
of a step: a call site forced to change by a signature the plan changed, a test deleted with the
function it covered. Say so in the commit body when you rely on this.

Everything else that wants doing gets written to `plan/{slug}/follow-ups.md` and stays there until the change is recorded, when each one still open moves into the area spec.
Scope creep is not free: it is unreviewed behaviour riding in under an approved plan, and it
makes the plan stop being a contract anyone can check the work against.

Execute the plan. After every material change, build the affected package and run the single
test closest to what you just touched — not the whole suite, which is slow enough that you will
stop doing it. Use the repo's own targets (`make`, `just`, `npm run`, `scripts/`) rather than
hand-rolled commands, so you run what CI runs.

A clean build is the minimum bar before running tests. If the repo has no build step, its
typecheck or lint stands in for one.

## Step 6 — E2E / Integration Tests

If the repo has an E2E or integration suite, use its canonical runner — the script or target the
repo provides, never the underlying test tool directly. The runner usually loads environment,
endpoints and credentials that a raw invocation will not, and a suite run without them fails in
ways that look like product bugs.

Find it before you need it: a `scripts/` entry, a `make` target, or a section in the repo's
README. If the suite talks to a running service, that service must be reachable first — check,
do not assume.

If there is no such suite, say so rather than skipping the step silently.

## Step 7 — Unit Tests

- Put tests in the file the repo's convention pairs with the implementation file.
- Push toward 100% coverage for touched code paths unless a branch is structurally unreachable.
- Run the repo's test target for the affected package.

## Repo Rules

**Service lifecycle.** If services are already running and the user manages them, never start or
stop one yourself. After implementing or fixing, tell the user to restart the affected service
before E2E tests will reflect the changes.

**Nested repositories.** A directory with its own `.git` is separate history. Commit changes
there separately, with their own message, and never stage the pointer from the outer repo.

**Commits.** `AGENTS.md` owns the format — read it. Failing a repo-specific rule, Conventional
Commits: `type(scope): subject`, types `feat`, `fix`, `refactor`, `perf`, `test`, `docs`,
`build`, `ci`, `chore`. Scope short, lowercase, component-oriented. One logical change per
commit, and separate commits per repository when more than one is involved.

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

If the user explicitly waives planning after you flag it ("I already know what I want, just do it"), accept it and write `plan/{slug}/waived.md` with the date, what was waived, and their reason. Then implement. This keeps the paper trail without blocking work. Its folder is recorded like a plan's (*Plan files are working files*).

## Quick Reference

| Phase | Output | Location |
|-------|--------|----------|
| Analyze | Findings | `plan/{slug}/findings.md` |
| Decide | Decisions; one question at most | `## Decisions` in `plan.md`; `plan/{slug}/questions.md` |
| Plan | Implementation steps | `plan/{slug}/plan.md` |
| Verify | Plan review | with the user, at full tier |
| Implement | Code changes | the repo |
| E2E tests | the repo's canonical runner | wherever the suite lives |
| Unit tests | the repo's test target | the repo |
| Record | Spec entry | the area spec, after the push (`glab:manager` Stage 8) |
