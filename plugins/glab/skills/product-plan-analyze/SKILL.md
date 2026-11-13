---
name: product-plan-analyze
description: Product level — Check a product plan with the glab:product-analyzer agent before the user approves it — does every goal reach a project, can each brief stand alone, do the rules and seams agree. Ends in SOUND or NOT SOUND.
argument-hint: "[product plan slug]"
---

The entry point of the product plan check, stage P1b of `glab:product-manager` *The product pipeline*. The session that runs it — the product manager, or a person who typed `/glab:product-plan-analyze` — dispatches **glab:product-analyzer** for **the product plan check** on `plan/$ARGUMENTS/product-plan.md`, as `glab:session-rules` Rules 0d and 5 say.

`$ARGUMENTS` is the product plan's slug. None → ask which one — never the most recent, never a guess.

**Then** go on by its verdict:

- `SOUND` → the user's approval (`glab:product-manager` *The product pipeline*).
- `NOT SOUND: <n> findings` → keep the round copy first, `cp plan/<slug>/product-plan.md plan/<slug>/product-plan.r<n>.md`, `<n>` the round that checked it; then a new `glab:product-planner` amends from the findings, copied as the analyzer returned them, and the next round checks the delta. Its rounds are counted under `glab:session-rules` *Round caps*; still `NOT SOUND` after the last one → the user.
- `BLOCK: target unresolved` → say which file could not be found.
