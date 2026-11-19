---
name: product-project-brief
description: Product level — Write one brief per project of an approved product plan, and the approved product rules, to the shared store with the glab:product-planner agent.
argument-hint: "[product plan slug]"
---

The entry point of stage P2 of `glab:product-manager` *The product pipeline*. `$ARGUMENTS` is the product plan's slug. None → ask which one — never the most recent, never a guess.

**Precondition:** `plan/<slug>/product-plan.md` has its `## Approval` line, and no `## Delivered` after the last `## Approval` (`glab:product-manager` *The product pipeline*). Otherwise → stop: a brief is written only from a plan the user approved, and a delivered plan takes none until the user approves it again.

The session that runs it — the product manager, or a person who typed `/glab:product-project-brief` — dispatches **glab:product-planner**, as `glab:session-rules` Rules 0d and 5 say, to write the briefs and the approved rule drafts as `glab:product-plan` says; the dispatch names the slug and the store, and grants the writes in the store's `briefs/` and `docs/product-rules/`.

**Then** run `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" sync <store> product-manager`, which in a store clone commits and pushes them — anything but exit 0 → stop and show its stderr line — and list the briefs written by their store paths, `briefs/<project>/brief.md`, and the rule files with them. The store and its layout are `glab:product-manager` *The shared store*'s.
