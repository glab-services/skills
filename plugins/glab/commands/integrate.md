---
description: Run the change against a running system with the glab:integrator agent — dependencies, service, E2E suite
argument-hint: "[plan slug]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then use the **glab:integrator** agent on `plan/$ARGUMENTS/`.

If no slug was given, ask which plan; do not guess and do not pick the most recent.

This runs after `/glab:analyze` at full tier or `/glab:develop` at normal, and before `/glab:review`. It asks one question: **does the change work against a real running system?** Not whether it matches the plan, and not whether the code is good. At normal tier it runs the test that proves the plan's milestone; the whole suite is for full tier.

Do not run the suite yourself and do not start services yourself — the agent owns that, and it reports exactly what it left running.

Show its report verbatim and point at `plan/$ARGUMENTS/integration.md` for the detail. Then:

- `INTEGRATED` → go to `/glab:review`.
- `FAILED: <n> regressions` → back to `/glab:develop` with only the failing behaviour in scope.
- `BLOCKED: no suite` → the agent could not find an E2E suite. Ask me where it is. **When I tell you, save it to memory** so no later session has to ask again.

Skip this command only when the change cannot be exercised at runtime — documentation, plan files, a refactor with no behavioural change. Say you are skipping it and why. Do not report it green.

Nothing here commits, stages or pushes.
