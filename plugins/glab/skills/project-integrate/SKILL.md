---
name: project-integrate
description: Project level — Run the change against a running system with the glab:project-integrator agent — dependencies, service, E2E suite
argument-hint: "[plan slug]"
---

Stage 4 of `glab:project-manager` *The pipeline*. The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-integrate` — dispatches the **glab:project-integrator** agent on `plan/$ARGUMENTS/`, as `glab:session-rules` Rules 0d and 5 say. No slug: `glab:project-manager` *The pipeline*.

It asks one question: **does the change work against a real running system?** Not whether it matches the plan, and not whether the code is good. The agent runs the suite — at normal tier only the milestone test, as its Step 1 says — and any service it needs; the session that dispatched it runs neither.

Show its report as `glab:project-manager` *The pipeline* says — to a user who typed the skill, verbatim — and point at `plan/$ARGUMENTS/integration.md` for the detail.

- **Skip this stage only when the change cannot be exercised at runtime** (documentation, plan files, a pure refactor with no behavioural change). Say you are skipping it and why; do not silently pass it.
- `INTEGRATED` → Stage 5. `FAILED: <n> regressions` → a `glab:project-develop` fix round, with only the failing behaviour in scope.
- `BLOCKED: no suite` → ask the user where the suite lives — the agent does not invent one. When the user names the path, **write it to memory** so no later session asks again. Any other `BLOCKED: <reason>` → do what would unblock it, under Rule 3, or bring it to the user.
