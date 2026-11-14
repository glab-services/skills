---
name: commit
description: Commit changes with the glab:committer agent using Conventional Commits
argument-hint: "[paths to commit, empty to let it decide from git status]"
---

The entry point of the commit stage of the manager of your level — `glab:project-manager` Stage 6 and the record's commit (Stage 8) at the project level, `glab:product-manager` stage P6 at the product level. The session that runs it — that manager, or a person who typed `/glab:commit` — dispatches the **glab:committer** agent, as `glab:session-rules` Rules 0d and 5 say. Scope: $ARGUMENTS — if that is empty, it decides from `git status`. A commit on `main` — allowed by the user's words or the repo's `AGENTS.md` — is said in the dispatch to be deliberate; without that, `glab:committer` Step 3 applies.

Its staging rules, deny-list and message rules are in its own definition; do not restate or override them in the dispatch. If it refuses to stage something, that is the correct outcome — relay the reason, do not work around it.

**Write the dispatch for `haiku`**, the committer's model: every instruction explicit, none left to inference, the work as numbered steps that are references, never content — `1 commit the paths <list>; 2 report as your file says`. The steps point at what it reads and never carry it; you do not read the plan to write them (`glab:session-rules` Rule 2). Its own *Report* section is its template, never pasted into the dispatch.

Report back: commit hash, subject line, and the file list from `git show --stat`.
