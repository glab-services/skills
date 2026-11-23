---
name: plan
description: The procedure glab-product:planner follows — turn a business plan into a product plan (goals, one project per brief, rules to add, decisions); after the user's approval write the briefs and rule files to the shared store; at P7 write the roadmap page. Run by hand as /glab-product:plan [business plan path].
argument-hint: "[path to the business plan]"
---

# Product plan

The business plan is $ARGUMENTS, or the one the dispatch names. None → ask; never guess.

## The product plan

`plan/<slug>/product-plan.md`, at most 49152 bytes. Sections, in order:

- `## Business plan` — its path, its `sha256sum`, and the user's words that define it, verbatim.
- `## Goals` — `P1`, `P2`, …, one line each.
- `## Projects` — one `### <project>` (`[a-z0-9-]+`) each: the goal it serves, scope, out of scope, the rule files that apply (`docs/product-rules/<name>.md`), its seams with other projects. A project is one a brief can state alone.
- `## Rules to add` — drafts of new rule files, name and text; or `none`.
- `## Decisions` — each choice, one line with its reason.
- `## Questions` — only what the user must decide, with context and your recommended answer; or `none`.

## The briefs

Only after `## Approval`: one `briefs/<project>/brief.md` in the store per project, with:

- `## Goal` — naming the product goal it serves.
- `## Scope`, `## Out of scope`.
- `## Product rules` — the rule files that apply, by store path.
- `## Seams` — what it shares with other projects, and how.
- `## Acceptance` — what the audit will hold the project's plan to.

A brief is the project's whole request: it cites nothing the project cannot read — no product-repo path, no product plan.

Each approved draft from `## Rules to add` goes to `docs/product-rules/<name>.md` (one topic, at most 8192 bytes), and `docs/product-rules/index.md` gains `- <name>.md — <what it covers>`.

## The roadmap

When the dispatch says roadmap: overwrite `docs/roadmap/<slug>.md` in the product repo, at most ~10 KB. It describes what the product now delivers — goals, each project with its scope and brief path, the rules in force, the decisions that still bind, open items — from `product-plan.md` and the store's briefs and latest verdicts. Current state only; history is in git.

## Where it stops

The plan written; or the briefs and rule files written; or the roadmap written. Checks, approvals and verdicts are the manager's.
