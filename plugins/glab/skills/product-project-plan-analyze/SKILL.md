---
name: product-project-plan-analyze
description: Product level — Audit a project's reported plan against the product's gates — its brief, the product rules the brief names and the product plan's decisions — with the glab:product-analyzer agent. Ends in NO CONFLICT or CONFLICTS.
argument-hint: "[project]"
---

The entry point of stage P4 of `glab:product-manager` *The product pipeline*. `$ARGUMENTS` is `<project>`. None → ask which one — never the most recent, never a guess.

**Find what the audit reads**, in the store (`glab:product-manager` *The shared store*), synced first by `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" sync <store>` — anything but exit 0 → stop and show its stderr line; a latest report that already has its `verdict.r<n>.md` stops too: it is decided, and there is no new report to audit:

- the latest `report.r<n>.md` in `briefs/<project>/`, the numbers compared as numbers, and its copy `plan.r<n>/`;
- the brief, `briefs/<project>/brief.md`;
- `docs/product-rules/index.md` and the rule files the brief names;

and in the product repo the product plan the brief came from — the one `plan/*/product-plan.md` whose `## Projects` has `### <project>`. None, or more than one → ask the user which.

**Dispatch** **glab:product-analyzer** for **the project plan audit**, as `glab:session-rules` Rules 0d and 5 say, naming the brief, the report, `plan.r<n>/`, the product plan's `## Decisions`, and the rules index with the rule files the brief names — the product's gates.

**Then** go on by its verdict: `NO CONFLICT` or `CONFLICTS: <n>` → stage P5, `/glab:product-project-plan-verdict <project>`, with the findings. `BLOCK: target unresolved` → say which file could not be found.
