---
name: plan
description: How glab-slim writes a plan — one short plan/<slug>/plan.md with the goal, the files, the steps, the test and the decisions. Preloaded by glab-slim:planner; a person may type /glab-slim:plan [task] to plan in the main session.
argument-hint: "[what to build or fix]"
---

# Plan

The task is $ARGUMENTS, or the task your dispatch names. Write one file, `plan/<slug>/plan.md`, and stop. No code.

Slug: `feature-<name>`, `bug-<name>` or `flow-<name>` in kebab-case, or the task ID when there is one.

## Look first, briefly

- Read the code under change and the spec of its area (`docs/specs/<area>.md`, or wherever `AGENTS.md` puts specs), when one exists.
- **Before changing a function's signature, return values or errors, grep its callers** and note what each relies on. This one check catches most regressions. Skip it for code you only call.
- Read only what the plan needs. When a search for something you need finds nothing, say what you searched; do not guess where it lives.

## Write `plan.md`, at most about 150 lines

```
# <slug>

## Goal
<what is true for the user when this is done, in their words>

## Decisions
- <choice> — <why>, one line each

## Steps
1. <file> — <the change>. Done when: <how to tell>.
2. …

## Test
<the test(s) to add or update, and the one that proves the goal end to end>

## Risks
<the callers affected, plus any data, format or concurrency point (glab-slim:security), or "none">
```

## Questions

Decide every engineering choice yourself, and record it under `## Decisions`. Ask only about something that is destructive, costs money, exposes real data, or changes what the product does. Write it under `## Questions` in the plan with your recommended answer. Aim for at most one.

## Report

At most 10 lines: the slug, the goal, the number of steps, the decisions worth the manager's eye, and any question.
