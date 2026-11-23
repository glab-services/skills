---
name: plan-analyze
description: Check a product plan with product:analyzer before the user approves it — every goal reaches a project, each brief can stand alone, rules and seams agree. Ends in SOUND or NOT SOUND.
argument-hint: "[product plan slug]"
---

Stage P1b. `$ARGUMENTS` is the slug; none → ask, never guess. Dispatch `product:analyzer` for the product plan check on `plan/<slug>/product-plan.md`.

- `SOUND` → the user's approval (`product:manager`).
- `NOT SOUND: <n> findings` → `cp plan/<slug>/product-plan.md plan/<slug>/product-plan.r<n>.md`, then a new `product:planner` amends from the findings as returned, and a new analyzer checks again. Still `NOT SOUND` after round 2 → the user.
- `BLOCK: target unresolved` → say which file is missing.
