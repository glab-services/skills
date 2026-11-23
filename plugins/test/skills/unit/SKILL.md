---
name: unit
description: Run or write unit tests in a tester agent. No argument runs the tests of the changed files; a path or symbol writes its missing tests; a bug description writes a failing reproduction.
argument-hint: "[path | symbol | bug description]"
context: fork
agent: test:tester
background: false
---

Unit tests for: $ARGUMENTS

1. **Nothing named:** find the files changed against the merge base with `origin/main` (`git diff --name-only $(git merge-base HEAD origin/main)` plus the working tree). Run the unit tests that cover them; if the runner cannot narrow, run the unit suite.
2. **A path or symbol:** read it, list its normal, edge (empty, zero, limit) and error cases, write the missing tests through its public interface in the repo's test style, and run them.
3. **A bug description:** write the smallest test that reproduces it, run it, and leave it failing.

Verdict: `PASS`, `FAIL` (code is wrong), `REPRODUCED` / `NOT REPRODUCED` for a bug, or `BLOCKED: <why>`.
