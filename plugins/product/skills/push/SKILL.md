---
name: push
description: Push the current branch after showing which commits go out and where — the session's own or a stage branch at once, main or a release branch only on the user's word
argument-hint: "[remote, default origin]"
---

The session runs this itself; no agent pushes. `<remote>` is $ARGUMENTS, or `origin`. Type the values straight into each command, never through shell variables.

1. `git branch --show-current`. If it prints nothing, stop. If it prints `main` or a release branch (`release*`), stop and ask.
2. `git remote`. If `<remote>` is not listed, stop.
3. `git log --oneline HEAD --not --remotes=<remote>` lists the commits going out. If it is empty, `git merge-base --is-ancestor HEAD '@{u}'` exiting 0 means there is nothing to push.
4. `git status --short -uall` shows what stays behind.
5. Dry-run: `git push --dry-run <remote>`, or `git push --dry-run -u <remote> <local>` when the branch has no upstream on `<remote>` (`git config --get branch.<local>.remote` is not `<remote>`). Read the destination ref. If it is not the branch the user expects, or more than one ref moves, stop and show the output.
6. Show the commits and the destination. For the session's own branch or a stage branch, go on. For `main` or a release branch, wait for the user's go-ahead.
7. Run exactly the dry-run command without `--dry-run`. If git refuses, show its message and stop.

Never `--force` or `--force-with-lease`, never push tags, never print a remote's URL. Report the branch, the commits that landed, and the PR link if git printed one.
