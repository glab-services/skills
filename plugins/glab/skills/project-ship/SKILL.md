---
name: project-ship
description: Project level — Review the working tree with the glab:project-reviewer agent, then commit with the glab:committer agent if it passes
argument-hint: "[path to narrow the review, empty for the whole working tree]"
---

Ship the current changes: review, gate, commit — three steps, in order, no shortcuts. The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-ship` — dispatches both agents as `glab:session-rules` Rules 0d and 5 say, and holds the gate between them.

## 1. Review

`/glab:project-ship` only ever reviews the working tree. $ARGUMENTS narrows it to a path. If it looks like a branch name or a revision range, stop and tell the user to use `/glab:project-review` instead — reviewing committed history and then committing the dirty tree are not the same scope, and pairing them lets unreviewed work through under a passing verdict.

Dispatch the **glab:project-reviewer** agent on the uncommitted working tree, narrowed to $ARGUMENTS when that is set. Narrowed means the whole working-tree view restricted to that path — worktree, index and untracked files alike. The agent owns that procedure; do not restate it in the dispatch.

Show its report as `/glab:project-review` says.

## 2. Gate

Match the verdict **whole**, never by prefix — `SHIP WITH SCOPE CUT` starts with `SHIP`, and a prefix match would commit the very part the reviewer told you to drop.

- Exactly `SHIP` → go to step 3.
- `SHIP WITH SCOPE CUT: <what to drop>` → go to step 3 with the named part removed from the scope, and tell the user what was dropped. Never commit the named part.
- `BLOCK: <n> issues`, `BLOCK: 1 issue` or `BLOCK: target unresolved` → stop here. Show the findings and ask the user what to fix. Do not commit. Do not start fixing anything unless the user says so.
- `DO NOT PUBLISH: <why>` → stop. Do not commit, and do not offer a fix round; the reviewer is saying the design is wrong.
- No clear verdict, or the reviewer errored → first the report check of `glab:session-rules` Rule 5. Still no clear verdict → treat it as BLOCK and say which it was.

When the user asks for a fix, it is made as `glab:project-manager` Stage 5 sends findings back — or, with no plan behind the change, as a **glab:project-developer** fix round dispatched directly, whose contract is the review findings, quoted verbatim in the dispatch (`glab:project-developer` *A fix round*). Either way the amended tree returns to step 1: a new reviewer, given what Stage 5 gives a round after the first, within `glab:session-rules` *Round caps*. A commit only ever follows a `SHIP` verdict on the exact tree being committed — a fix that was never reviewed is the case this skill exists to catch.

## 3. Commit

Dispatch the **glab:committer** agent as `/glab:commit` says, and tell it exactly which paths the reviewer looked at.

That scope is an upper bound on what may be committed, not a mandate. Anything the reviewer did not see does not get committed, however tempting.

Report back as `/glab:commit` says.
