---
name: product-plan
description: Product level — The procedure glab:product-planner follows, and that a user runs by typing /glab:product-plan <path to the business plan>: turn a business plan into a product plan — goals, one project per brief, the product rules to add, decisions — and, after the user's approval, write the briefs and the approved rule files to the shared store. Stops there: checks, approvals and verdicts are the product manager's.
argument-hint: "[path to the business plan]"
---

# Product plan

**The business plan** is what follows `/glab:product-plan` when a person types it — $ARGUMENTS — or, when nothing does, as when `glab:product-planner` preloads this skill, the one its dispatch names. None named → ask which one — never the most recent, never a guess.

## The product plan

One folder `plan/<slug>/` of the product repo, and in it one file, `product-plan.md`, at most 49152 bytes (`wc -c`). Its sections, in this order:

- `## Business plan` — the business plan's path and its `sha256sum`, and the user's words that define it, verbatim.
- `## Goals` — `P1`, `P2`, …, each one line.
- `## Projects` — one subsection `### <project>` per project: its kebab-case name (`[a-z0-9-]+`), the goal it serves, its scope, what is out of its scope, the product-rule files that apply (`docs/product-rules/<name>.md`), and its seams with the other projects. A project is one a brief can state alone.
- `## Rules to add` — the drafts of new rule files, each with its name and its text, or `none`.
- `## Decisions` — each choice the plan rests on, one line with its reason.
- `## Questions` — only what meets a `glab:session-rules` Rule 3 ask-condition, with its context and its recommended answer; or `none`.

## The briefs

Only after the plan's `## Approval`: one `briefs/<project>/brief.md` in the shared store per project of `## Projects`, with the sections:

- `## Goal` — the project's goal, naming the product goal it serves.
- `## Scope` and `## Out of scope`.
- `## Product rules` — the rule files that apply, by their store-relative paths, `docs/product-rules/<name>.md`, each one that exists in the store.
- `## Seams` — what the project shares with the other projects, and how.
- `## Acceptance` — what the audit will hold the plan to.

A brief's `## Acceptance` and the rule files it names are the product's gates for that project: the audit holds the project's plan to them, with the product plan's `## Decisions`. A brief is the project's whole request, so it cites nothing the project cannot read — no path of the product repo, no product plan.

## The product rules

Whose the rules are, and how a rule file may change, is `glab:product-manager`'s. A draft from `## Rules to add` is written to `docs/product-rules/<name>.md` in the store only after the plan's approval: one topic per file, at most 8192 bytes, and `docs/product-rules/index.md` gains its line `- <name>.md — <what it covers>`.

## The roadmap

When the dispatch says this is the roadmap — stage P7 of `glab:product-manager`, once the slug is delivered — write `docs/roadmap/<slug>.md` of the product repo, named by the product slug. It is written from `plan/<slug>/product-plan.md`, its round copies `product-plan.r<n>.md`, and the store's briefs and latest verdicts. Nothing is dropped, and each item carries its source file and id. It holds:

- the business plan: its path, its `sha256sum` and the user's words that define it, verbatim;
- the goals `P1`, `P2`, …;
- per project: its goal, its scope, what is out of its scope, its rule files, its seams, its brief's store path, and its final `verdict.r<n>.md`;
- the rules added;
- every `## Decisions` line, with its reason;
- the answered questions, with the user's words;
- the round history: the `NOT SOUND` rounds, and the `REJECTED` verdicts with their reasons;
- the open items, each tagged `[<slug>/product-plan.md <id>]`;
- its *Records* line, in the form `glab:project-record` states.

## Where it stops

The plan written, or after the approval the briefs and the rule files written, or, when the dispatch says this is the roadmap, `docs/roadmap/<slug>.md` written. The checks, the approvals and the verdicts are the product manager's. The store's layout is `glab:product-manager` *The shared store*'s.
