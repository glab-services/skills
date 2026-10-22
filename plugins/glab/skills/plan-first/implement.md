# Plan First — implementation

Steps 5 to 7 of `glab:plan-first`, kept apart so that a planning agent does not load them. Start them only once the plan is verified and approved (`glab:plan-first` Step 4), or once `plan/{slug}/waived.md` records a waiver (*User Override* in `SKILL.md`), which stands in for both.

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

## Repo Rules for the implementation

**Service lifecycle.** If services are already running and the user manages them, never start or
stop one yourself. After implementing or fixing, tell the user to restart the affected service
before E2E tests will reflect the changes.

**Nested repositories.** A directory with its own `.git` is separate history. Commit changes
there separately, with their own message, and never stage the pointer from the outer repo.

**Commits.** `AGENTS.md` owns the format — read it. Failing a repo-specific rule, Conventional
Commits: `type(scope): subject`, types `feat`, `fix`, `refactor`, `perf`, `test`, `docs`,
`build`, `ci`, `chore`. Scope short, lowercase, component-oriented. One logical change per
commit, and separate commits per repository when more than one is involved.
