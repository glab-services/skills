# Master — flow-product-level

## Request

The user, 2026-11-13, relayed by the manager:

> finish product skills and wiring with project first, I want to see how these skills will work

The user's words this request builds on, from `plan/manager-flow-notes.md` (untracked), 2026-11-12 and 2026-11-13:

> product manager > project manager > developers flow
>
> product manager: must receive business plan > run planing to get high level plan(s) for manager(s)
>
> manager(s): must work with current flow what we have

> all these based skills are must have sub skills and only must related to the base
>
> mean: example: planing skill of product manager must not work for project manager(s)

> Product:
> product:plan > product:plan:analyze > product:project:brief > product:project:plan:report (must force managers to send back report of planing before go to development phase) > product:project:plan:analyze (audit of project manager plan specify to make sure if project manager's plan is not conflicting with production gates rules decisions)
> product:project:plan:accept|reject (skill(s) witch must send accepted and rejected plan and small context or reason)

> not one file, each file must be not big so would be better to have docs/product-rules/{named roules}.md maybe?

> Files in a shared folder

> plain folder but I'm planing to connect here notion page

> okay two is good

> product manager and or also me

> these skills are must communicate with each other glab:product:* glab:product:project:* glab:product:delivery:* glab:product:support:* … I think yes this is fit for one plugin for all

## Goals

- **G1** — the product level exists as skills of `glab`: a product manager and the chain plan → plan-analyze → project-brief → project-plan-report → project-plan-analyze → project-plan-verdict ("Product: product:plan > …"), each a skill, with its agents ("one plugin for all").
- **G2** — a session runs one level only: it knows its level, the session start loads that level's manager, and each manager uses only its own level's skills ("planing skill of product manager must not work for project manager(s)").
- **G3** — the project level runs today's flow and changes only at its edges: it takes a brief as its request, sends its plan report before development and waits for the verdict ("manager(s): must work with current flow what we have"; "must force managers to send back report of planing before go to development phase").
- **G4** — the verdict is `ACCEPTED` or `REJECTED`, always with a reason, gated by the hash of the accepted plan; development does not start without a matching `ACCEPTED`; two rejections, then the user decides ("accepted and rejected plan and small context or reason"; "okay two is good").
- **G5** — the product rules are small files with an index, and the levels talk through a plain shared folder ("docs/product-rules/{named roules}.md"; "Files in a shared folder"; "plain folder").
- **G6** — project sessions are started by the product manager or by the user, and both lead to the same brief ("product manager and or also me").
- **G7** — the user can see the loop work: a walkthrough that runs without a model, and a guide to try it live after install ("I want to see how these skills will work").

## Out of scope

- The delivery and support levels — the user: "I'm still thinking about delivery skills structure I will let you knew when I will ready". Named only where a seam is needed: the reserved level values and the store's reserved folder.
- A Notion sync — the user: "plain folder but I'm planing to connect here notion page" (later, optional, never the gate).

## Final check

1. `bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh` ends `PASS n/n` with every line `ok`: the product and project session-start texts, a brief, a rejected report, an accepted one, the manager's record lines after acceptance accepted, development refused after an edit to the accepted plan and after an edit to the brief, and the rejection cap — G2–G7.
2. Every gate in `AGENTS.md` *Gates* green as the changed *Gates* section states it: `Skills (21)` and `Agents (9)` with the names it lists, the model and skills gates — G1.
3. Every post line of the plan's steps prints `ok` on the built tree.
4. The walkthrough's trace (`PRODUCT_LOOP_SHOW=1`) shown to the user, and the live tests LP1–LP5 listed in `README.md` and recorded as not run — G7.

## Record

- `docs/specs/product.md` (new): the product level, the shared store, the file contracts and the hash gate, LP1–LP5, the follow-ups FU-P1…, the decisions that bind.
- `docs/specs/workflow.md`: the project edges (Stage 1 brief input, Stage 1c, the develop gate), the level in descriptions, the session-start text by level.
- `docs/specs/marketplace.md`: the new gates and test files, the counts, the version 0.14.0, the hook contract of `manager-bootstrap.sh`, the spec list.
- No audit file is acted on.
