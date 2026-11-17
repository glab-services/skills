---
name: project-analyze
description: Project level — Check an implementation with the glab:project-analyzer agent — conformance and the final check, intent, not correctness
argument-hint: "[plan slug]"
---

Stages 3 and 6b of `glab:project-manager` *The pipeline*: the conformance check and the final check. The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-analyze` — dispatches **glab:project-analyzer** on `plan/$ARGUMENTS/`, as `glab:session-rules` Rules 0d and 5 say. `$ARGUMENTS` is only the slug, or a sub-plan `<slug>/<nn>-<name>`. None → ask which plan — never the most recent, never a guess.

**Which check.** It is named in the dispatch or by the user, never in `$ARGUMENTS`. With none named, a `result.md` under `plan/$ARGUMENTS/` → the conformance check. No `result.md` and no check named: Nothing is built: that is the plan check, `/glab:project-plan-analyze {slug}`. A check named that is neither: ask which, and do not guess.

**The dispatch carries** the slug, the check's name, round 1's tree id or the final check's range, and from round 2 on the round's inputs below. Read `result.md` — it is written for you and stays short — and summarise it to at most 10 lines for the user.

**Then** show the report as `glab:project-manager` *The pipeline* says — to a user who typed the skill, verbatim: every step line, the plan revision it measured against, and the verdict. `BLOCK: target unresolved` → say whether the plan or the implementation was the part that could not be resolved.

## The conformance check — Stage 3

**Full tier, and every sub-plan at every tier.** At normal tier with no sub-plans the step list in `result.md` is the conformance record: every step `done`, gates green by your own run, then Stage 4; the intent question waits for the final check (Stage 6b).

The analyzer answers one question: **did we build what the plan said?** Not whether the code is correct — that is Stage 5. Do not let it drift. Where the folder has a master it also asks the intent question: does the build serve the master's goals, beyond matching the steps? A step built as written that misses its goal is a defect of the plan: it goes to a planning agent's amendment, then Stage 2 — never to a developer told to build past its plan.

**`CONFORMS` → Stage 4.** **`DIVERGES: <n> steps` → a `glab:project-develop` fix round**, with only the diverging steps in scope. Rounds are capped as `glab:session-rules` *Round caps*. Say the round number every time: `analyze round <n>/<cap>`.

**A re-check looks at the delta.** Before you dispatch each analyze round, round 1 included, snapshot the tree it will measure — tracked, staged and untracked files, without touching the index — with an index path that does not exist yet, in the session's temp directory. The index is seeded from `HEAD` first, so a tracked file that matches `.gitignore` is not dropped:

    idx=<temp directory>/<slug>-analyze-r<n>.idx; rm -f "$idx"
    GIT_INDEX_FILE="$idx" git read-tree HEAD && GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"

It prints a tree id; name it in that round's dispatch. In a repository with no commit yet `git read-tree HEAD` fails and nothing is printed: that round has no tree id. Round `<n+1>` gets the previous round's findings, copied as returned, and both tree ids; it reads `git diff --stat <old> <new>` and `git diff <old> <new>` and checks each previous finding, every step whose files the delta touches, and anything in the delta that no step asked for — not the steps the delta leaves alone. `git diff --quiet <old> <new>` exiting 0 after a fix round means nothing changed: stop and find out why. Ignored files are not in a snapshot, so a path the fix round's `files:` line names and the delta does not show is checked whole; a tree id you no longer have means that round runs whole.

Still diverging after the last round → stop and bring it to the user with the three honest resolutions: change the code, change the plan (a Rule 3 decision — yours for an engineering choice, the user's on an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer), or cut the scope. Never edit `plan.md` to make a divergence disappear — that turns the contract into a description of whatever was built.

## The final check — Stage 6b

After the slug's last commit, before the push, at normal and full tier. The analyzer reads `master.md`, `index.md` (the plan, with no index) and the range from the `## Approval` base to `HEAD`, and asks of every goal whether it is delivered, and where. Run the gates yourself on that tree. Skipped only for a single plan at full tier, whose Stage 3, delta rounds included, asked it.

`CONFORMS` → Stage 7. `DIVERGES` → the gaps go to a new planning agent: with sub-plans, a new sub-plan with the next `<nn>` and its line in `index.md`; without, an amendment of `plan.md`. It runs its cycle to its commit; round 2 gets round 1's findings and the two commit ids. Rounds are capped as `glab:session-rules` *Round caps*, a third's line in `index.md` (`plan.md` with no sub-plans); still diverging: bring it to the user.
