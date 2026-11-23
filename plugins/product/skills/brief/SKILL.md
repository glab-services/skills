---
name: brief
description: Write one brief per project of an approved product plan, and the approved product rules, to the shared store with product:planner.
argument-hint: "[product plan slug]"
---

Stage P2. `$ARGUMENTS` is the slug; none → ask, never guess.

**Precondition:** `plan/<slug>/product-plan.md` has an `## Approval` line and no `## Delivered` after the last one. Otherwise stop.

Dispatch `product:planner` to write the briefs and approved rule drafts as `product:plan` says, naming the slug and the store, and granting writes in the store's `briefs/` and `docs/product-rules/`.

Then run `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" sync <store> product-manager` — anything but exit 0 → stop and show its stderr line — and list the briefs and rule files written, by store path.
