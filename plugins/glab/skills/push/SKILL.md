---
name: push
description: Push the current branch after showing exactly which commits will go out
argument-hint: "[remote, default origin]"
---

Push the current branch. This is the push stage of your level's manager: `glab:project-manager` Stage 8, or `glab:product-manager` stages P6 and P7. The session runs it itself; there is no push agent, because a push leaves the machine.

Ask git rather than working anything out by hand, above all the remote branch name. Two placeholders, typed straight into every command, never carried in a shell variable: an unset `$REMOTE` turns `--remotes="$REMOTE"` into `--remotes=`, which excludes every remote.

- `<remote>`: $ARGUMENTS, or `origin`.
- `<local>`: the checked-out branch, from step 1.

## Before pushing

1. `git branch --show-current`. If it prints `main`, stop and ask the user. If it prints nothing (a detached HEAD), stop.
2. `git remote`. If `<remote>` is not listed, stop.
3. `git for-each-ref --count=1 refs/remotes/<remote>/`. If it prints a ref, go on. If it prints nothing, run `git ls-remote --heads <remote>` and read its exit code:
   - non-zero: the remote is unreachable. Show the error and stop.
   - 0 and no heads: the remote is empty and this is its first push. Run step 4, then skip step 5. Never tell the user to fetch an empty remote; that loops.
   - 0 with heads: say "fetch `<remote>` first" and stop.
4. List what will land: `git log --oneline HEAD --not --remotes=<remote>`. Never compute it against `main`. With it, show the `## Decisions` lines of the slug's plan folder from disk: `plan/<slug>/plan.md`, or `master.md` and each sub-plan's `plan.md`.
5. If that list is empty, the ref may still need to move. Run `git config --get branch.<local>.remote`:
   - it prints `<remote>`: run `git merge-base --is-ancestor HEAD '@{u}'`. Exit 0 means nothing to do, so stop. Exit 1 means the ref lags; say so and go on.
   - anything else, or no output: there is no upstream on `<remote>`. Say this is a new branch and go on.
6. `git status --short -uall`: show what is not going out. This does not block the push.
7. Dry-run: `git push --dry-run <remote>`, or `git push --dry-run -u <remote> <local>` with no upstream. Read the **destination** of every ref. Stop and show the output if the destination is not the branch the user expects, or if more than one ref moves.

Then wait for the user's go-ahead.

Name the remote, never print its URL: `git remote -v` and `git remote get-url` print any credential in it (`glab:security`).

## The push

Run exactly the dry-run of step 7 without `--dry-run`. If git refuses, most often because the upstream has another name, stop and show its message. Choosing between the commands it prints is the user's call.

Never `--force` or `--force-with-lease`, never push tags, never push a branch other than the checked-out one. If a force-push seems needed, stop and tell the user why. Approval of one push never carries to the next.

## After

Report the remote branch, the commits that landed, and the PR URL if the remote printed one.
