---
name: project-record
description: Project level — Record a committed change before its push: the area spec and feature pages written from its plan folder by glab:project-developer, then committed with the change
argument-hint: "[plan slug]"
---

Stage 7 of `glab:project-manager` *The pipeline*: after the commits, before the push, so the record goes out in the same push and lands with the change in the same merge. `$ARGUMENTS` is the slug. With none, ask which; never guess.

What stays true moves into the spec of each area the change touched. The rule is `glab:project-plan` *Plan files are working files*. The place is `docs/specs/`, with feature pages in `docs/features/`, unless the repo's `AGENTS.md` names another.

**The *Records* line** of a spec, or of a roadmap page (`glab:product-plan` *The roadmap*), is:

    - <date> · <slug> · <first> · <last> · <branch> · <PR/MR, or none yet>

- `<first>` and `<last>` are the change's commits by both ends: two short shas, not a range.
- `<branch>` is the branch, named because the plan folder is not kept and a squash or rebase merge can give the commits new shas. The branch and the PR are what to look up.

1. **Dispatch `glab:project-developer` for the record alone.** The dispatch names:
   - the slug and the change's commits;
   - the area specs and feature pages that `master.md`'s `## Record` names (`plan.md`'s when there is no master; for a waiver, the ones you name);
   - any audit file `## Record` names as a source.

   It carries every follow-up still open, every binding decision and every incident, with its source file and number, and it changes nothing inside the folder.
2. **Run `/glab:commit`** with the spec files and feature pages. There is no separate check of the record: Stage 8 shows it with the commits.

The record never removes `plan/{slug}/` or an audit file. The manager removes the folder once the record has landed, and only on the user's word (`glab:session-rules` Rule 2). A plan folder whose `master.md` (or `plan.md`, with no master) has no `## Record` predates the rule and is not recorded.
