# master — flow-models-per-role

## Request

Relayed by the manager in the planning dispatch, 2026-11-11, quoted as relayed (the manager's words, carrying the user's table and answers; the user's own words are the quoted parts):

> Give each glab pipeline role a default model, per the table the user approved on 2026-10-20, and split the analyzer into two kinds: a plan-check kind (Stage 1b) and a conformance/record kind (Stage 3 and the final check). Decide whether a `glab:planner` agent should exist (today the planner role has no agent of its own — establish how the planner is dispatched now).

> | role | model |
> |---|---|
> | planner | Opus |
> | analyzer, plan check (Stage 1b) | Opus |
> | analyzer, conformance + record/final check | Sonnet |
> | developer | Sonnet |
> | reviewer | Sonnet (not Haiku: it is the last gate) |
> | integrator | Sonnet |
> | committer | Haiku |

> Reason the user gave: cost. In one measured run developers were 49% of tokens, planners 21%, plan checks 11%, reviewers 8%. A cheaper model lowers the price per token, not the number of tokens.

The user, 2026-10-20, approving the table (as recorded in the user's auto-memory "Models per role"): "good let's use your suggestions".

The user, 2026-11-11, answering the Rule 3 question (`questions.md` Q1): "Default". The option picked, as the manager relayed it: each agent's model comes from the table (e.g. set in its definition), the user's words for a task still override it, Rule 5 is reworded, and every installer gets these models and their cost.

The user, 2026-11-11, on the session effort: "high (Recommended)".

## Goals

- G1 — Each pipeline role runs by default on the model the table gives it: planner Opus, plan check Opus, conformance and record/final check Sonnet, developer Sonnet, reviewer Sonnet, integrator Sonnet, committer Haiku ("Give each glab pipeline role a default model, per the table").
- G2 — The analyzer is two kinds: a plan-check kind for Stage 1b and a conformance/record kind for Stage 3, the final check and the record check ("split the analyzer into two kinds").
- G3 — Whether a `glab:planner` agent exists is decided, from how the planner is dispatched now, and carried out ("Decide whether a `glab:planner` agent should exist").
- G4 — The table ships as glab's default for every installer; the user's words for a task still override it; `glab:manager` Rule 5 is reworded to say so ("Default" — "the user's words for a task still override it, Rule 5 is reworded, and every installer gets these models and their cost").

## Out of scope

none — the user excluded nothing. (The reason given, "A cheaper model lowers the price per token, not the number of tokens", sets no goal to cut tokens.)

## Final check

On the committed tree, from the repo root, under the *Gates* rules of `AGENTS.md`:

1. Every gate of `AGENTS.md` *Gates* green as that section states it after this change — `Agents (7)` naming `analyzer, committer, developer, integrator, plan-analyzer, planner, reviewer` in any order, and the new model gate printing exactly these seven lines and `rc=0`:
   `plugins/glab/agents/analyzer.md:model: sonnet`, `committer.md:model: haiku`, `developer.md:model: sonnet`, `integrator.md:model: sonnet`, `plan-analyzer.md:model: opus`, `planner.md:model: opus`, `reviewer.md:model: sonnet` (each with the `plugins/glab/agents/` prefix).
2. `/usr/bin/grep -n 'These two roles only\|the developer and reviewer only' plugins AGENTS.md README.md -r` prints nothing (rc=1), and `/usr/bin/grep -c 'glab:plan-analyzer' plugins/glab/skills/manager/SKILL.md plugins/glab/commands/analyze.md` prints a count of 1 or more for each.
3. Live, the user's step (calls models, so it costs): plan step I1 — `/tasks` shows `glab:committer` on Haiku with no `model` parameter passed, and `glab:reviewer` on Haiku when the dispatch passes `model: haiku`. Until run: `UNVERIFIED`, recorded under the spec's *Known limits*.

## Record

After the push (`glab:manager` Stage 8):

- `docs/specs/workflow.md` — how it works now: the model per role in each agent's frontmatter, Rule 5 reworded (the user's words override any role; no parameter otherwise; agents without a definition get none), the handoff line's `model <alias>` on every agent stage, `glab:planner` and `/glab:plan` dispatching it, the two analyzer kinds and `/glab:analyze` routing by kind, the dispatch-per-model table applying to the default; every `## Decisions` line of `plan.md` under *Decisions that still bind*; I1 and the other UNVERIFIED items under *Known limits*; follow-ups FU1–FU4 of `plan.md`; closed: `[flow-planner/plan.md FU1]`, `[flow-cheaper-rounds/plan.md FU1]`, `[flow-cheaper-rounds/follow-ups.md FUc]`, `[feature-docs-specs/follow-ups.md 5]`; superseded: `[feature-model-switch/plan.md D2]` and `D8`; one *Records* line.
- `docs/specs/marketplace.md` — the gates now: `Agents (7)` and the new model gate with its reason; one *Records* line.

Then, outside Stage 8, the manager session removes `plan/flow-models-per-role/` under `AGENTS.md`'s `plan/` rule.
