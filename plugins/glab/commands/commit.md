---
description: Commit changes with the glab:committer agent using Conventional Commits
argument-hint: "[paths to commit, empty to let it decide from git status]"
---

Read `AGENTS.md` at the repo root first (or `CLAUDE.md` if the repo has none — say so) — the commit format and the rules it enforces live there.

Then use the **glab:committer** agent, dispatched as `glab:manager` Rules 0d and 5 say. Scope: $ARGUMENTS — if that is empty, it decides from `git status`.

Its staging rules, deny-list and message rules are in its own definition; do not restate or override them here. If it refuses to stage something, that is the correct outcome — relay the reason, do not work around it.

Do not push. `/glab:push` is a separate, deliberate step.

Report back: commit hash, subject line, and the file list from `git show --stat`.
