---
name: commit
description: Commit finished project work with the project:committer agent, using Conventional Commits
argument-hint: "[paths to commit, empty to let it decide from git status]"
---

Dispatch `project:committer` to commit $ARGUMENTS, or, when that is empty, what `git status` shows for this task. Name the paths to stage when other work is in the tree. Say in the dispatch when a commit on `main` is deliberate. When the plan has an issue, tell the committer to end the body with `Refs #<n>`. Name the dispatch `committer: <area>: <what>`.

Write the dispatch as numbered steps, for example `1 commit the paths <list>; 2 report as your file says`. Its staging and message rules are in its own file; do not restate them. When it refuses a file, relay the reason; do not work around it.

Never run two commits, or a commit and a push, at the same time.

Report the hash, the subject line, and the file list from `git show --stat`.
