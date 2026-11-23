---
name: project-analyze
description: Project level — Check an implementation against its plan with the glab:project-analyzer agent — conformance and intent, not correctness
argument-hint: "[plan slug]"
---

Stage 3 of `glab:project-manager` *The pipeline*: the conformance check. The session that runs it dispatches **glab:project-analyzer** on `plan/$ARGUMENTS/`: either `glab:project-manager`, or a person who typed `/glab:project-analyze`. `$ARGUMENTS` is the slug, or a sub-plan `<slug>/<nn>-<name>`. With none, ask which plan; never guess.

**When it runs.**
- At full tier, and for every sub-plan, it always runs.
- At normal tier with no sub-plans, the step list in `result.md` is the conformance record. When every step is `done` and your own gate run is green, go to Stage 4.

**The dispatch carries:** the slug, round 1's tree id, and, from round 2, the previous round's findings and both tree ids. Show the report as *The pipeline* says. To a user who typed the skill, show it verbatim.

The analyzer answers one question: **did we build what the plan said, and does it serve the master's goals?** Correctness is Stage 5's. A step built as written that misses its goal is a defect of the plan. It goes to a planning agent's amendment, never to a developer told to build past the plan.

- **`CONFORMS`** → Stage 4.
- **`DIVERGES: <n> steps`** → a `glab:project-develop` fix round, with only the diverging steps in scope. Rounds are capped at 2 (`glab:session-rules` *Round caps*). Say the round every time: `analyze round <n>/2`.

**The tree id.** Before each round, snapshot the tree it will measure: tracked, staged and untracked files, without touching the index.

    idx=<temp directory>/<slug>-analyze-r<n>.idx; rm -f "$idx"
    GIT_INDEX_FILE="$idx" git read-tree HEAD && GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"

The analyzer of round 2 checks only the delta, `git diff <old> <new>`. If `git diff --quiet <old> <new>` exits 0, nothing changed: stop and find out why.

**Still diverging after round 2:** stop and bring it to the user with three resolutions:
- change the code;
- change the plan, through a planning agent, recorded under `## Decisions`;
- cut the scope.

Never edit `plan.md` to make a divergence disappear.
