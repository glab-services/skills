---
name: audit
description: Produce a structured audit findings document in plan/ after examining a service, module, or subsystem — with architecture summary, working flow, a severity-classified issues table, and prioritized recommendations. Use after completing a service audit, codebase examination, architecture review, or deep-dive analysis. Triggers on "audit this service", "examine this project", "learn this codebase", "review this module". For analysis that leads directly into implementation, use glab:plan-first instead.
---

# Audit

After examining a service, module, or subsystem, produce a structured findings document and save it to `plan/`.

## When to Use

Use for a substantive examination whose deliverable is the report itself:

- full service audits (architecture, issues, recommendations);
- codebase walkthroughs and learning sessions;
- deep-dives into a specific subsystem;
- comparisons of multiple services.

Skip for trivial one-line checks ("what does this file do?", "is this variable used?").

If the analysis is the first step toward changing the code, use [glab:plan-first](../plan-first/SKILL.md) instead — that workflow carries analysis through questions, plan, implementation, and tests.

## File Naming

```
plan/<date>-<service-name>-<type>.md
```

Examples:

- `plan/2026-07-16-sync-cache-pipeline-audit.md`
- `plan/2026-07-16-s3-multipart-examination.md`
- `plan/2026-07-16-iam-policy-review.md`

Use the date the analysis was performed.

## Required Sections

Fill in `references/plan-template.md`, which carries the full skeleton. Every document must have these sections in order:

1. **Header** — service name, audit type, date, scope, status (`draft` | `final`).
2. **Architecture Summary** — purpose, tech stack, and place in the larger system. ASCII diagram if the architecture warrants one.
3. **Working Flow** — the main execution path(s) as numbered phases, with key function calls, goroutines, and data flow.
4. **Key Findings** — what works well, what is unusual or noteworthy, configuration issues, duplication concerns.
5. **Issues Table** — every issue, classified by severity.
6. **Recommendations** — prioritized actionable fixes, grouped by severity, each referencing its issue number.
7. **Next Steps** — further investigation, pending decisions, ready-to-implement items.

## Severity Levels

| Level | Meaning |
|-------|---------|
| **Critical** | Data loss risk, crash risk, security issue, unbounded memory growth |
| **High** | Correctness bug, significant performance issue, missing essential functionality |
| **Medium** | Code quality, maintainability, minor bugs |
| **Low** | Style, naming, documentation, non-critical config |

## Format Rules

- Every code reference includes a file path and line number: `src/handler/object.go:234`.
- Issues must be specific and actionable — no vague observations.
- Separate what you **proved** from the code and what you **inferred**. Never present inferred runtime behavior as proven.
- Keep the document self-contained: a reader months later should get the full picture without re-examining the code.

## After Writing

1. Confirm the file is saved under `plan/` (create the directory if needed).
2. Tell the user the path and a one-line summary of what it contains.
3. Ask whether they want to act on any finding now — if so, that work goes through [glab:plan-first](../plan-first/SKILL.md).
