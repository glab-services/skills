# flow-commands-to-skills — steps for the eight stage skills (S1–S8)

Part of `plan.md` *processing*, run after P1–P3. File boundary: `plugins/glab/skills/{analyze,commit,develop,integrate,plan,push,review,ship}/SKILL.md` only.

Each step replaces the whole file with the block below it, byte for byte. A block runs from the line after `~~~ S<n> <path>` to the line before the next `~~~` on its own; nothing outside the block goes in the file. Post-condition of every step (`n` the step, `p` its path):

    awk -v id="S$n" '$1=="~~~" && $2==id {f=1; next} f && $0=="~~~" {f=0} f' plan/flow-commands-to-skills/steps-stages.md | diff - "$p"; echo "rc=$?"

prints only `rc=0`. Then, once S1–S8 are done:

- `/usr/bin/grep -c -w -E 'me|my|mine|I' plugins/glab/skills/{analyze,commit,develop,integrate,plan,push,review,ship}/SKILL.md` prints `:0` for all eight (before: 54 matches in the commands, F15);
- `/usr/bin/grep -l -E "Read \`AGENTS.md\`" plugins/glab/skills/{analyze,commit,develop,integrate,plan,push,review,ship}/SKILL.md; echo "rc=$?"` prints only `rc=1` (A10);
- `/usr/bin/grep -c -E 'go-ahead|force-push|main|Approval|ask-condition|waived' plugins/glab/skills/{push,commit,develop,plan}/SKILL.md` prints a count of 1 or more for each of the four — the user's waits are still there.

What each block keeps, drops and points at is the disposition table in `plan.md`; the blocks are the result.

## S1 — `analyze` (A10, A22→B5, A29, B5, B13, B28)

~~~ S1 plugins/glab/skills/analyze/SKILL.md
---
name: analyze
description: Check a plan or an implementation with the glab:plan-analyzer or glab:analyzer agent — conformance and intent, not correctness
argument-hint: "[plan slug]"
---

The entry point of the plan check (`glab:manager` Stage 1b), the conformance check (Stage 3), the final check (Stage 6b) and the record check (Stage 8). The session that runs it — `glab:manager`, or a person who typed `/glab:analyze` — dispatches one agent on `plan/$ARGUMENTS/`, as `glab:manager` Rules 0d and 5 say.

`$ARGUMENTS` is only the slug, or a sub-plan `<slug>/<nn>-<name>`. No slug → ask which plan; do not guess, and do not pick the most recent. An empty argument makes that path `plan/`, which hands the analyzer every plan in the repo and lets it choose its own contract.

**Which agent.** A named check comes first, whatever the folder holds: the plan check or the master check uses **glab:plan-analyzer**, even when a `result.md` from an earlier build is there, as after a plan is amended; the conformance check, the final check and the record check use **glab:analyzer**. The check is named in the dispatch or by the user, never in `$ARGUMENTS`. With no check named, the folder settles it: a `result.md` under `plan/$ARGUMENTS/` → the conformance check, with **glab:analyzer**; none → nothing is built, so the plan check, with **glab:plan-analyzer**. A check named that is none of these: ask which check, and do not guess.

**What the dispatch carries** — the round, and from round 2 the previous findings and the delta — is the stage's.

**Then** show the report verbatim — every step line, the plan revision it measured against, and the verdict — and go on as the stage that ran the check says: `BUILDABLE` and `NOT BUILDABLE` in Stage 1b; `CONFORMS` and `DIVERGES: <n> steps` in Stages 3, 6b and 8. `BLOCK: target unresolved` → say whether the plan or the implementation was the part that could not be resolved.
~~~

## S2 — `commit` (A10, A29, B14, B32)

~~~ S2 plugins/glab/skills/commit/SKILL.md
---
name: commit
description: Commit changes with the glab:committer agent using Conventional Commits
argument-hint: "[paths to commit, empty to let it decide from git status]"
---

The entry point of `glab:manager` Stage 6, and of the record's commit (Stage 8). The session that runs it — `glab:manager`, or a person who typed `/glab:commit` — dispatches the **glab:committer** agent, as `glab:manager` Rules 0d and 5 say. Scope: $ARGUMENTS — if that is empty, it decides from `git status`. A commit on `main` is said in the dispatch to be deliberate, or the committer stops (`glab:manager` Stage 6).

Its staging rules, deny-list and message rules are in its own definition; do not restate or override them in the dispatch. If it refuses to stage something, that is the correct outcome — relay the reason, do not work around it.

Report back: commit hash, subject line, and the file list from `git show --stat`.
~~~

## S3 — `develop` (A3, A4, A9→C12, A10, A25, A28, A29, B21, B26, B27, C7, C11, C12)

~~~ S3 plugins/glab/skills/develop/SKILL.md
---
name: develop
description: Implement a plan (approved, at full tier) through glab:developer agents, then hand off to the plan's next stage
argument-hint: "[plan slug]"
---

The entry point of `glab:manager` Stage 2. The session that runs it — `glab:manager`, or a person who typed `/glab:develop` — does not write the implementation: it checks the preconditions below, then splits, dispatches, verifies and hands off as Stage 2 says.

`$ARGUMENTS` is the slug, or a sub-plan `<slug>/<nn>-<name>` whose `master.md` is a level up. No slug → ask which plan; do not guess, and do not pick the most recent.

## Preconditions, before any dispatch

- **No `plan.md` and no `waived.md`** → stop. That is `/glab:plan`, not this.
- **`plan/{slug}/waived.md` exists** → that is `glab:plan-first`'s waiver and it is a valid start; say the work runs from a waiver, not a plan, and that the conformance check therefore has nothing to measure against.
- **`plan/{slug}/questions.md` exists** → read it. These files have no single convention, so do not refuse on stale text. A question that meets a `glab:manager` Rule 3 ask-condition and is not plainly answered: ask the user, do not assume. Anything else still open in it is yours to decide and record under `## Decisions`.
- **Approval** → with a `master.md` (a level up for a sub-plan), its `## Approval` line is there, `sha256sum -c plan/<slug>/master.sha256`, run from the repo root, prints `OK`, and at full tier `plan.md` — a single plan's or a sub-plan's — ends with its own `## Approval` line — or stop and tell the user. With none — a plan from before `glab` 0.11.0 — full tier only; a plan with no tier line is full (`glab:manager` → *Pick the tier*). Nothing records it, so do not pretend to check: ask the user to confirm the plan is approved before any agent writes code, unless they approved it in this conversation. A normal-tier plan starts without it.
- **Green tree** → run the gate line once before any dispatch. Dispatching onto a red tree means every agent inherits a failure it did not cause and cannot tell apart from its own.
~~~

## S4 — `integrate` (A10, A29, B8, B9, B15, B29)

~~~ S4 plugins/glab/skills/integrate/SKILL.md
---
name: integrate
description: Run the change against a running system with the glab:integrator agent — dependencies, service, E2E suite
argument-hint: "[plan slug]"
---

The entry point of `glab:manager` Stage 4. The session that runs it — `glab:manager`, or a person who typed `/glab:integrate` — dispatches the **glab:integrator** agent on `plan/$ARGUMENTS/`, as `glab:manager` Rules 0d and 5 say. No slug → ask which plan; do not guess and do not pick the most recent.

It asks one question: **does the change work against a real running system?** Not whether it matches the plan, and not whether the code is good. The agent runs the suite and any service it needs; the session that dispatched it runs neither.

Show its report verbatim and point at `plan/$ARGUMENTS/integration.md` for the detail. What each verdict leads to, and when the stage is skipped, is Stage 4's.
~~~

## S5 — `plan` (A10, A28, A29, B13, B30)

~~~ S5 plugins/glab/skills/plan/SKILL.md
---
name: plan
description: Size, analyze, question and plan a task with the glab:plan-first skill, before any code is written
argument-hint: "[what to build or fix]"
---

The entry point of `glab:manager` Stage 1. The session that runs it — `glab:manager`, or a person who typed `/glab:plan` — dispatches the **glab:planner** agent for: $ARGUMENTS, as `glab:manager` Rules 0d and 5 say. The planner follows `glab:plan-first`, which owns the procedure; nothing here restates or shortcuts it.

**Before the dispatch:** a task under `glab:manager` Rule 1's trivial line does not belong here. Say so and stop; the change is made directly.

**After it returns:** its decisions, any Rule 3 question and the approval are Stage 1's, after the plan check of Stage 1b. Nothing is implemented from here.

**The waiver** is `glab:plan-first` *User Override*, and only the user's own words make one: when the user explicitly waives planning after it was flagged, write `plan/{slug}/waived.md` as that skill prescribes and say `/glab:develop` can proceed from the waiver instead of a plan. Never write one on the user's behalf — not to save a stage, and not because a task looks simple.
~~~

## S6 — `push` (A23, first-person voice; the procedure is this skill's own)

~~~ S6 plugins/glab/skills/push/SKILL.md
---
name: push
description: Push the current branch after showing exactly which commits will go out
argument-hint: "[remote, default origin]"
---

Push the current branch. The entry point of `glab:manager` Stage 7, and of the record's push (Stage 8).

The session that runs it — `glab:manager`, or a person who typed `/glab:push` — does this itself. There is no push agent on purpose: a push leaves the machine, so the session stays in the loop rather than relaying an agent's report about something already sent.

**No git command goes into this file until it has been run once and its output pasted.** Every defect this file has had was a command written from memory. And when git already knows something, ask git — do not re-derive it here. The worst bug this file ever had came from computing the remote branch name by hand.

Two placeholders. Substitute both directly into every command — never carry either in a shell variable, because each command runs in a fresh shell, and an unset `$REMOTE` collapses `--remotes="$REMOTE"` to `--remotes=`, which excludes *every* remote and reports a false "nothing to push".

- `<remote>` — $ARGUMENTS, or `origin` when that is empty.
- `<local>` — the checked-out branch, from step 1.

## Before pushing

1. `git branch --show-current` — if it is `main`, stop and ask the user; do not assume. If it prints nothing you are on a detached HEAD; stop.

2. `git remote` — if `<remote>` is not in that list, stop. Do this before substituting `<remote>` into anything else.

3. Decide whether step 4's preview can be trusted:

       git for-each-ref --count=1 refs/remotes/<remote>/

   Prints a ref → trustworthy, go on. Prints nothing → the tracking refs are missing and step 4 would silently list the entire history instead. Run `git ls-remote --heads <remote>` and read its **exit code**, not just its output:

   - non-zero exit → the remote is unreachable. Show the error and stop. Stdout is empty here too, which is exactly why the exit code is the signal.
   - exit 0, no heads → the remote is empty. This is its first push. Step 4 still runs and is still correct: what it lists is the whole history, which is exactly what lands. Run it, then skip step 5 — there is no remote branch to compare against.
   - exit 0, heads present → say "fetch `<remote>` first" and stop.

   Never tell the user to fetch when the remote is empty: fetching an empty remote succeeds and changes nothing, so that advice loops forever.

   A tracking ref that exists can still be stale. This preview is only ever as fresh as the last fetch — say so if it matters.

4. Show the user exactly what will land:

       git log --oneline HEAD --not --remotes=<remote>

   Every commit reachable from `HEAD` that `<remote>` does not already have, correct whether or not the branch has an upstream. Never compute it against `main`: on a branch cut from another branch that reports hundreds of already-pushed commits and destroys the only signal this step exists to give.

   With them, show the `## Decisions` lines of each plan folder those commits carry — at normal tier this is where the user reads what the manager decided.

5. If that list is empty, no new *commits* go out — but the branch ref may still need to move. Ask git where this branch points first:

       git config --get branch.<local>.remote

   - It equals `<remote>` → an upstream exists here. Ask the containment question: `git merge-base --is-ancestor HEAD '@{u}'`. Exit 0 → the remote branch already contains HEAD, stop, nothing to do. Exit 1 → the ref lags, the push still moves it, say so and continue.
   - It is `.`, another remote's name, or the command exits 1 with no output → there is no upstream on `<remote>`. This is a new branch there; say so and continue.

   Never work out the remote branch name yourself. `branch.<local>.merge` read on its own names a branch that may be purely local (`remote = .`, which `git branch --track feat trunk` sets) or live on a different remote — and pushing to it puts a feature branch on the remote's trunk with every guard in this file reporting green.

6. `git status --short -uall` — show the user anything still uncommitted, so they can see what is *not* going out. `-uall` is required: without it an untracked directory collapses to a single line and hides the files inside. This does not block the push; it just has to be visible.

7. Show the user what the push will actually do. Do not predict it:

       git push --dry-run <remote>

   or `git push --dry-run -u <remote> <local>` for a branch with no upstream. This contacts the remote, prints the real `src -> dst` for every ref that would move, and changes nothing — verified: it reported `feat -> trunk` under `push.default=upstream`, and `git ls-remote` showed the remote byte-identical before and after.

   Read the **destination**, not just the source. Stop and show the user the output if the destination is not the branch they expect, or if more than one ref would move — under `push.default=matching` one bare push moves several. Predicting the destination from config is how this file put a feature branch on trunk with every guard green; `--dry-run` asks git instead.

   Then wait for the user's go-ahead.

Name the remote, never print its URL (`glab:security` *Secrets never enter output*). `git remote -v` and `git remote get-url` print any credential embedded in it. `git push` prints `To <url>` but git redacts userinfo there itself — a push to `https://alice:s3cr3t@host/repo.git` reports `https://host/repo.git`. Bare `git remote` and `git ls-remote --heads` are safe; the first is what step 2 uses.

## The push

Upstream already on `<remote>` (step 5, first case):

    git push <remote>

No upstream on `<remote>` (step 5, second case):

    git push -u <remote> <local>

Run exactly what you dry-ran in step 7, minus `--dry-run`. If git refuses — most often because the branch's upstream has a different name — **stop and show the user its message.** It prints the two possible commands, and choosing between them is the difference between moving the upstream branch and creating a new one. That is the user's call. Observed:

    fatal: The upstream branch of your current branch does not match
    the name of your current branch.  To push to the upstream branch
    on the remote, use
        git push full HEAD:trunk
    To push to the branch of the same name on the remote, use
        git push full HEAD

Never `--force` or `--force-with-lease`. Never push tags. Never push a branch other than the one checked out. If a force-push seems genuinely needed, stop and tell the user why — that is the user's call to make in the moment, and approval on one push never carries to the next.

## After

Report the remote branch, the commits that landed, and the PR URL if the remote printed one.
~~~

## S7 — `review` (A10, A29, B13, B17)

~~~ S7 plugins/glab/skills/review/SKILL.md
---
name: review
description: Review changes with the glab:reviewer agent against AGENTS.md
argument-hint: "[path or branch, empty for the working tree]"
---

The entry point of `glab:manager` Stage 5, and of the record's review (Stage 8). The session that runs it — `glab:manager`, or a person who typed `/glab:review` — dispatches the **glab:reviewer** agent, as `glab:manager` Rules 0d and 5 say, with what Stage 5 gives a reviewer. Target: $ARGUMENTS — if that is empty, the uncommitted working tree.

Show its report verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

Then stop. Do not fix anything, do not stage anything, do not commit. Inside the `glab:manager` pipeline, Stage 5 says where the findings go; run on its own, wait for the user to say what to do with them.
~~~

## S8 — `ship` (A10, A13, A29, B6→A13, B19, B32)

~~~ S8 plugins/glab/skills/ship/SKILL.md
---
name: ship
description: Review the working tree with the glab:reviewer agent, then commit with the glab:committer agent if it passes
argument-hint: "[path to narrow the review, empty for the whole working tree]"
---

Ship the current changes: review, gate, commit — three steps, in order, no shortcuts. The session that runs it — `glab:manager`, or a person who typed `/glab:ship` — dispatches both agents as `glab:manager` Rules 0d and 5 say, and holds the gate between them.

## 1. Review

`/glab:ship` only ever reviews the working tree. $ARGUMENTS narrows it to a path. If it looks like a branch name or a revision range, stop and tell the user to use `/glab:review` instead — reviewing committed history and then committing the dirty tree are not the same scope, and pairing them lets unreviewed work through under a passing verdict.

Dispatch the **glab:reviewer** agent on the uncommitted working tree, narrowed to $ARGUMENTS when that is set. Narrowed means the whole working-tree view restricted to that path — worktree, index and untracked files alike. The agent owns that procedure; do not restate it in the dispatch.

Show the user its report verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

## 2. Gate

Match the verdict **whole**, never by prefix — `SHIP WITH SCOPE CUT` starts with `SHIP`, and a prefix match would commit the very part the reviewer told you to drop.

- Exactly `SHIP` → go to step 3.
- `SHIP WITH SCOPE CUT: <what to drop>` → go to step 3 with the named part removed from the scope, and tell the user what was dropped. Never commit the named part.
- `BLOCK: <n> issues`, `BLOCK: 1 issue` or `BLOCK: target unresolved` → stop here. Show the findings and ask the user what to fix. Do not commit. Do not start fixing anything unless the user says so.
- `DO NOT PUBLISH: <why>` → stop. Do not commit, and do not offer a fix round; the reviewer is saying the design is wrong.
- No clear verdict, or the reviewer errored → first the report check of `glab:manager` Rule 5. Still no clear verdict → treat it as BLOCK and say which it was.

When the user asks for a fix, it is made as `glab:manager` Stage 5 sends findings back, and the amended tree returns to step 1: a new reviewer, given what Stage 5 gives a round after the first, within *Pick the tier*'s round caps. A commit only ever follows a `SHIP` verdict on the exact tree being committed — a fix that was never reviewed is the case this skill exists to catch.

## 3. Commit

Dispatch the **glab:committer** agent, and tell it exactly which paths the reviewer looked at.

That scope is an upper bound on what may be committed, not a mandate. The committer still splits by logical change and still refuses anything the user did not ask about. Anything the reviewer did not see does not get committed, however tempting.

Report back: commit hash, subject line, and the file list from `git show --stat`. If the committer refused to stage something, say what and why.
~~~
