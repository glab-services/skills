# Manual QA — the `test` plugin

Three commands you type in any session. Each runs in its own `test:tester` agent (sonnet), so test output stays out of your session; you get back a verdict of at most 15 lines. The tester edits only test files and never commits.

| Command | No argument | With an argument | Verdicts |
|---|---|---|---|
| `/test:unit` | runs the unit tests of the files changed since `origin/main` | a path or symbol: writes its missing tests (normal, edge, error) and runs them; a bug description: writes a failing reproduction | `PASS`, `FAIL`, `REPRODUCED`, `NOT REPRODUCED`, `BLOCKED` |
| `/test:e2e` | starts local dependencies the repo's way, runs the e2e or integration suite, stops what it started | a flow: runs only it; `#<n>` or a description: writes an e2e test that reproduces the issue | same |
| `/test:regression` | runs the full suite here, reruns only its failures on `origin/main` in a temporary worktree | a base ref instead of `origin/main` | `PASS`, `REGRESSED: <n> new`, `OLD FAILURES ONLY`, `BLOCKED` |

It uses the repo's own test commands (`AGENTS.md`, `Makefile`, `package.json`, …) and never adds a framework. Without an e2e suite, `/test:e2e` says `BLOCKED: no e2e suite`.

Install: `claude plugin install test@glab-services`. Try without installing: `claude --plugin-dir ./plugins/test`.
