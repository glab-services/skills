# Questions — flow-product-level

## Q1 — the model of the two new agents

**Context.** The model per role is the user's table (`glab:manager` Rule 5;
memory "Models per role"): planner and plan analyzer on `opus`; analyzer,
developer, reviewer, integrator on `sonnet`; committer on `haiku`. Every
installer runs these models and pays their price, so a new role's model is
the user's choice. This plan adds two roles:

- `glab:product-planner` — turns a business plan into a product plan, project briefs and rule drafts;
- `glab:product-analyzer` — checks the product plan, and audits each project's plan against the product rules (its finding decides `ACCEPTED` or `REJECTED`).

**Why it blocks.** Steps P8 and P9 write the `model:` line, R3 the model
gate's green lines and R5 the README's model sentence; the build cannot pick
the value.

**Recommended answer: `opus` for both**, by analogy — they do the work of
the planner and the plan analyzer, one level up, and their output gates every
project below them. Consequence: two more roles on the dearest model; the
product level runs them a few times per business plan and per report, not
per change.

- **Answer:** _(the manager writes the user's answer here)_

## Q2 — today's project skills: keep their names, or move under a project prefix (N3)

**Context.** Being asked by the manager now; recorded here so the developer
sees the answer. The product skills are `glab:product-*` (N1). Today's
project skills are `glab:manager`, `glab:plan`, `glab:develop`,
`glab:analyze`, `glab:integrate`, `glab:review`, `glab:ship`, and the agents
`glab:planner`, `glab:plan-analyzer`, `glab:developer`, `glab:analyzer`,
`glab:integrator`, `glab:reviewer`. It changes what people type.

**Why it blocks.** Not the steps written: every step is written for *keep*.
On *move*, an amendment adds a rename group after R6 — `git mv` of each
folder and file, its `name:` line, every `glab:<old>` reference in
`plugins/`, `README.md` and `AGENTS.md`, the gates' green lines — and
rewrites each phrase marked `[N3]`.

**Recommended answer: keep the names.** The level is already said in every
description and chosen per repo; renaming changes every name people type
and every pointer between the files (dozens per file in `glab:manager`), for
no change in behaviour. Consequence: the project level's names carry no
prefix while the product level's do; delivery and support, when built, take
`glab:delivery-*` and `glab:support-*`.

- **Answer:** _(the manager writes the user's answer here)_

## Answers

- Q2 (N3) — the user chose "Keep names (Recommended)" (2026-11-13). Today's project skills keep their names; the steps marked `[N3]` take their keep form only.
- Q1 — the user chose "Opus for both" (2026-11-13). `glab:product-planner` and `glab:product-analyzer` get `model: opus`.
