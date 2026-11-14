---
name: project-analyze
description: Project level — Check a plan or an implementation with the glab:project-plan-analyzer or glab:project-analyzer agent — conformance and intent, not correctness
argument-hint: "[plan slug]"
---

The entry point of the plan check (`glab:project-manager` Stage 1b), the conformance check (Stage 3), the final check (Stage 6b) and the record check (Stage 8). The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-analyze` — dispatches on `plan/$ARGUMENTS/` the agents the stage that runs the check names — how many, and split how, is that stage's — as `glab:session-rules` Rules 0d and 5 say.

`$ARGUMENTS` is only the slug, or a sub-plan `<slug>/<nn>-<name>`. No slug: `glab:project-manager` *The pipeline*.

**Which agent.** A named check comes first, whatever the folder holds: the plan check or the master check uses **glab:project-plan-analyzer**, even when a `result.md` from an earlier build is there, as after a plan is amended; the conformance check, the final check and the record check use **glab:project-analyzer**. The check is named in the dispatch or by the user, never in `$ARGUMENTS`. With no check named, the folder settles it: a `result.md` under `plan/$ARGUMENTS/` → the conformance check, with **glab:project-analyzer**; none → nothing is built, so the plan check, with **glab:project-plan-analyzer**. A check named that is none of these: ask which check, and do not guess.

**What the dispatch carries** — the round, and from round 2 the previous findings and the delta — is the stage's.

**Then** show the report as `glab:project-manager` *The pipeline* says — to a user who typed the skill, verbatim: every step line, the plan revision it measured against, and the verdict — and go on as the stage that ran the check says: `BUILDABLE` and `NOT BUILDABLE` in Stage 1b; `CONFORMS` and `DIVERGES: <n> steps` in Stages 3, 6b and 8. `BLOCK: target unresolved` → say whether the plan or the implementation was the part that could not be resolved.
