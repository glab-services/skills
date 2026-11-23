---
name: regression
description: Find regressions — run the full test suite on this branch, then rerun only its failures on a base ref (default origin/main), in a tester agent. Reports new failures apart from ones already failing on the base.
argument-hint: "[base ref]"
context: fork
agent: test:tester
background: false
---

Regression check against: `$ARGUMENTS` (`origin/main` when empty)

1. Run the full suite on the current tree: unit, and the integration or e2e target when the repo has one and its dependencies start locally. Collect the failing tests.
2. None failing: `PASS`, stop.
3. Otherwise `git fetch` the base, add a worktree of it under `$TMPDIR`, and run only the failing tests there.
4. Remove the worktree.

Classify each failure:
- `NEW`: passes on the base, fails here — a regression;
- `OLD`: fails on both.

Verdict: `PASS`, `REGRESSED: <n> new`, `OLD FAILURES ONLY`, or `BLOCKED: <why>`.
