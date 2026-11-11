# questions — flow-models-per-role

## Q1 — answered 2026-11-11

**Question (a Rule 3 ask: it costs money and changes what the product is).** Should the approved table ship as glab's default for every installer, or still apply only when the user names a model per task?

Context: `glab:manager` Rule 5 today lets a `model` be passed only for `glab:developer` and `glab:reviewer`, and only on the user's own words ("No instruction, no override", `plugins/glab/skills/manager/SKILL.md:142`); no agent definition sets a `model` (`plan.md` E5). A default in the definitions changes what every installed copy runs on, and what it costs.

**Answer — the user's words: "Default".** The option picked, as the manager relayed it in the planning dispatch (not the user's verbatim option text, which this folder does not hold): each agent's model comes from the table (e.g. set in its definition), the user's words for a task still override it, Rule 5 is reworded, and every installer gets these models and their cost.

Consequence the plan rests on: `plan.md` D2, D7–D10; it rewrites the *One fact* entry "the manual model rule" in `AGENTS.md` and every file that entry names, in one commit (D1).
