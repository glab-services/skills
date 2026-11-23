---
name: audit
description: Audit a project's reported plan against the product's gates — its brief, the rule files it names, the product plan's decisions — with product:analyzer. Ends in NO CONFLICT or CONFLICTS.
argument-hint: "[project]"
---

Stage P4. `$ARGUMENTS` is `<project>`; none → ask, never guess.

Run `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" sync <store>` first; anything but exit 0 → stop and show its stderr line. Then find:

- the latest `briefs/<project>/report.r<n>.md` and its copy `plan.r<n>/`. If `verdict.r<n>.md` already exists for it → stop: it is decided;
- `briefs/<project>/brief.md`, `docs/product-rules/index.md` and the rule files the brief names;
- in the product repo, the one `plan/*/product-plan.md` whose `## Projects` has `### <project>`. None or several → ask the user.

Dispatch `product:analyzer` for the project plan audit, naming those files.

`NO CONFLICT` or `CONFLICTS: <n>` → `/product:verdict <project>` with the findings. `BLOCK: target unresolved` → say which file is missing.
