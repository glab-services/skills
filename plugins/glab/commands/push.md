---
description: Push the current branch after showing exactly which commits will go out
argument-hint: "[remote, default origin]"
---

Push the current branch.

Do this yourself. There is no push agent on purpose: a push leaves the machine, so I want you in the loop rather than relaying an agent's report about something already sent.

**No git command goes into this file until it has been run once and its output pasted.** Every defect this file has had was a command written from memory. And when git already knows something, ask git — do not re-derive it here. The worst bug this file ever had came from computing the remote branch name myself.

Two placeholders. Substitute both directly into every command — never carry either in a shell variable, because each command runs in a fresh shell, and an unset `$REMOTE` collapses `--remotes="$REMOTE"` to `--remotes=`, which excludes *every* remote and reports a false "nothing to push".

- `<remote>` — $ARGUMENTS, or `origin` when that is empty.
- `<local>` — the checked-out branch, from step 1.

## Before pushing

1. `git branch --show-current` — if it is `main`, stop and ask; do not assume. If it prints nothing you are on a detached HEAD; stop.

2. `git remote` — if `<remote>` is not in that list, stop. Do this before substituting `<remote>` into anything else.

3. Decide whether step 4's preview can be trusted:

       git for-each-ref --count=1 refs/remotes/<remote>/

   Prints a ref → trustworthy, go on. Prints nothing → the tracking refs are missing and step 4 would silently list the entire history instead. Run `git ls-remote --heads <remote>` and read its **exit code**, not just its output:

   - non-zero exit → the remote is unreachable. Show the error and stop. Stdout is empty here too, which is exactly why the exit code is the signal.
   - exit 0, no heads → the remote is empty. This is its first push. Step 4 still runs and is still correct: what it lists is the whole history, which is exactly what lands. Run it, then skip step 5 — there is no remote branch to compare against.
   - exit 0, heads present → say "fetch `<remote>` first" and stop.

   Never tell me to fetch when the remote is empty: fetching an empty remote succeeds and changes nothing, so that advice loops forever.

   A tracking ref that exists can still be stale. This preview is only ever as fresh as the last fetch — say so if it matters.

4. Show me exactly what will land:

       git log --oneline HEAD --not --remotes=<remote>

   Every commit reachable from `HEAD` that `<remote>` does not already have, correct whether or not the branch has an upstream. Never compute it against `main`: on a branch cut from another branch that reports hundreds of already-pushed commits and destroys the only signal this step exists to give.

5. If that list is empty, no new *commits* go out — but the branch ref may still need to move. Ask git where this branch points first:

       git config --get branch.<local>.remote

   - It equals `<remote>` → an upstream exists here. Ask the containment question: `git merge-base --is-ancestor HEAD '@{u}'`. Exit 0 → the remote branch already contains HEAD, stop, nothing to do. Exit 1 → the ref lags, the push still moves it, say so and continue.
   - It is `.`, another remote's name, or the command exits 1 with no output → there is no upstream on `<remote>`. This is a new branch there; say so and continue.

   Never work out the remote branch name yourself. `branch.<local>.merge` read on its own names a branch that may be purely local (`remote = .`, which `git branch --track feat trunk` sets) or live on a different remote — and pushing to it puts a feature branch on the remote's trunk with every guard in this file reporting green.

6. `git status --short -uall` — show me anything still uncommitted, so I can see what is *not* going out. `-uall` is required: without it an untracked directory collapses to a single line and hides the files inside. This does not block the push; it just has to be visible.

7. Show me what the push will actually do. Do not predict it:

       git push --dry-run <remote>

   or `git push --dry-run -u <remote> <local>` for a branch with no upstream. This contacts the remote, prints the real `src -> dst` for every ref that would move, and changes nothing — verified: it reported `feat -> trunk` under `push.default=upstream`, and `git ls-remote` showed the remote byte-identical before and after.

   Read the **destination**, not just the source. Stop and show me the output if the destination is not the branch I expect, or if more than one ref would move — under `push.default=matching` one bare push moves several. Predicting the destination from config is how this file put a feature branch on trunk with every guard green; `--dry-run` asks git instead.

   Then wait for my go-ahead.

Name the remote, never print its URL. `git remote -v` and `git remote get-url` print any credential embedded in it. `git push` prints `To <url>` but git redacts userinfo there itself — a push to `https://alice:s3cr3t@host/repo.git` reports `https://host/repo.git`. Bare `git remote` and `git ls-remote --heads` are safe; the first is what step 2 uses.

## The push

Upstream already on `<remote>` (step 5, first case):

    git push <remote>

No upstream on `<remote>` (step 5, second case):

    git push -u <remote> <local>

Run exactly what you dry-ran in step 7, minus `--dry-run`. If git refuses — most often because the branch's upstream has a different name — **stop and show me its message.** It prints the two possible commands, and choosing between them is the difference between moving the upstream branch and creating a new one. That is my call, not yours. Observed:

    fatal: The upstream branch of your current branch does not match
    the name of your current branch.  To push to the upstream branch
    on the remote, use
        git push full HEAD:trunk
    To push to the branch of the same name on the remote, use
        git push full HEAD

Never `--force` or `--force-with-lease`. Never push tags. Never push a branch other than the one checked out. If you believe a force-push is genuinely needed, stop and tell me why — that is my call to make in the moment, and approval on one push never carries to the next.

## After

Report the remote branch, the commits that landed, and the PR URL if the remote printed one.
