---
description: Review the working tree with the glab:reviewer agent, then commit with the glab:committer agent if it passes
argument-hint: "[path to narrow the review, empty for the whole working tree]"
---

Ship the current changes. Four steps, in order, no shortcuts.

## 0. Read the rules

Read `AGENTS.md` at the repo root (or `CLAUDE.md` if the repo has none — say so) before anything else. Both agents read it too, but you sit between them — you judge the verdict and may end up editing code here, so you need the rules in hand, not a memory of them.

## 1. Review

`/glab:ship` only ever reviews the working tree. $ARGUMENTS narrows it to a path. If it looks like a branch name or a revision range, stop and tell me to use `/glab:review` instead — reviewing committed history and then committing the dirty tree are not the same scope, and pairing them lets unreviewed work through under a passing verdict.

Use the **glab:reviewer** agent on the uncommitted working tree, narrowed to $ARGUMENTS when that is set. Narrowed means the whole working-tree view restricted to that path — worktree, index and untracked files alike. The agent owns that procedure; do not restate it here. If I named a model for the reviewer, pass it as the Agent tool's `model` parameter in every round; if I named none, pass none, and never choose one yourself (`glab:manager` Rule 5). If I named an external reviewer instead, run every round through the `glab:external-agents` skill, with the same target.

Show me its report verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

## 2. Gate

Match the verdict **whole**, never by prefix — `SHIP WITH SCOPE CUT` starts with `SHIP`, and a prefix match would commit the very part the reviewer told you to drop.

- Exactly `SHIP` → go to step 3.
- `SHIP WITH SCOPE CUT: <what to drop>` → go to step 3 with the named part removed from the scope, and tell me what you dropped. Never commit the named part.
- `BLOCK: <n> issues` or `BLOCK: target unresolved` → stop here. Show the findings and ask what I want fixed. Do not commit. Do not start fixing anything unless I say so.
- `DO NOT PUBLISH: <why>` → stop. Do not commit, and do not offer a fix round; the reviewer is saying the design is wrong.
- No clear verdict, or the reviewer errored → first the report check of `glab:manager` Rule 5: resume the reviewer once, asking only for the missing fields. Still no clear verdict → treat it as BLOCK and say which it was. An external reviewer's report check is the script's: on its exit 8 `send` the same agent the gaps once, as `glab:external-agents` says — not a round; any other non-zero exit except 2 (USAGE, fixed and run again) is the reviewer erroring, reported and not retried.

If I ask you to fix anything, return to step 1 and re-run the reviewer on the amended tree. A commit only ever follows a `SHIP` verdict on the exact tree being committed — a fix that was never reviewed is the case this command exists to catch.

**At most three rounds, then a decision.** Tell the reviewer which round this is and which is the last, and scope each round after the first to what changed since the last one. In the last round it must answer `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>`, or `DO NOT PUBLISH: <why>` — there is no round after it. If the findings in round N are mostly in text written to fix round N-1, stop adding guards and remove logic instead; that is the change failing to converge, not the reviewer being thorough.

## 3. Commit

Use the **glab:committer** agent, and tell it exactly which paths the reviewer looked at.

That scope is an upper bound on what may be committed, not a mandate. The committer still splits by logical change and still refuses anything I did not ask about. Anything the reviewer did not see does not get committed, however tempting.

Do not push. `/glab:push` is a separate, deliberate step.

Report back: commit hash, subject line, and the file list from `git show --stat`. If the committer refused to stage something, say what and why.
