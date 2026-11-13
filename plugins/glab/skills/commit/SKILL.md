---
name: commit
description: Commit changes with the glab:committer agent using Conventional Commits
argument-hint: "[paths to commit, empty to let it decide from git status]"
---

The entry point of `glab:manager` Stage 6, and of the record's commit (Stage 8). The session that runs it — `glab:manager`, or a person who typed `/glab:commit` — dispatches the **glab:committer** agent, as `glab:manager` Rules 0d and 5 say. Scope: $ARGUMENTS — if that is empty, it decides from `git status`. A commit on `main`: `glab:manager` Stage 6.

Its staging rules, deny-list and message rules are in its own definition; do not restate or override them in the dispatch. If it refuses to stage something, that is the correct outcome — relay the reason, do not work around it.

Report back: commit hash, subject line, and the file list from `git show --stat`.
