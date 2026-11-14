---
name: project-integrate
description: Project level — Run the change against a running system with the glab:project-integrator agent — dependencies, service, E2E suite
argument-hint: "[plan slug]"
---

The entry point of `glab:project-manager` Stage 4. The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-integrate` — dispatches the **glab:project-integrator** agent on `plan/$ARGUMENTS/`, as `glab:session-rules` Rules 0d and 5 say. No slug: `glab:project-manager` *The pipeline*.

It asks one question: **does the change work against a real running system?** Not whether it matches the plan, and not whether the code is good. The agent runs the suite and any service it needs; the session that dispatched it runs neither.

Show its report as `glab:project-manager` *The pipeline* says — to a user who typed the skill, verbatim — and point at `plan/$ARGUMENTS/integration.md` for the detail. What each verdict leads to, and when the stage is skipped, is Stage 4's.
