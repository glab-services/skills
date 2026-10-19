---
description: Implement a plan (approved, at full tier) through glab:developer agents, or one external Codex developer when glab:manager Rule 5 recorded one — glab:plan-first steps 5 to 7 — then hand off to /glab:analyze at full tier or /glab:integrate at normal
argument-hint: "[plan slug]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then `plan/$ARGUMENTS/plan.md`. If no slug was given, ask which plan; do not guess, and do not pick the most recent.

You are the orchestrator here. **You do not write the implementation yourself** — the `glab:developer` agent does, or the external developer `glab:manager` Rule 5 recorded, through `glab:external-agents`. Your job is to check the preconditions, decide how the work is split, dispatch, and verify what comes back.

## Before dispatching anything

- **No plan and no `waived.md`** → stop. That is `/glab:plan`, not this.
- **`plan/{slug}/waived.md` exists** → that is `glab:plan-first`'s waiver and it is a valid start; say you are working from a waiver, not a plan, and that `/glab:analyze` therefore has nothing to measure against.
- **`plan/{slug}/questions.md` exists** → read it. These files have no single convention, so do not refuse on stale text. A question that is mine — destructive, costs money, exposes real data, changes what the product is — and is not plainly answered: ask me, do not assume. Anything else still open in it is yours to decide and record under `## Decisions` (`glab:manager` Rule 3).
- **Approval** → full tier only; a plan with no tier line is full (`glab:manager` → *Pick the tier*). Nothing records it, so do not pretend to check: ask me to confirm the plan is approved before any agent writes code, unless I approved it in this conversation. A normal-tier plan starts without it.
- **Green tree** → run the plan's own gate once before touching anything. Dispatching onto a red tree means every agent inherits a failure it did not cause and cannot tell apart from its own.

## Decide the split

Read the plan's stages and decide **one agent or several**. Say which you chose and why before dispatching. An external developer (`glab:manager` Rule 5) is always one agent: never split, and never beside a `glab:developer`, since they would share one working tree.

**One agent is the default.** Use it whenever the stages build on each other, which is most plans: a later stage importing a type an earlier stage defines, a UI step consuming a command step, a deletion step waiting on its replacement to pass.

**Split only when two conditions both hold:**

1. **Disjoint files.** The slices touch no file in common — not the same test file, not the same barrel export, not the same config. Two agents editing one file in one working tree will clobber each other; there is no merge step to save you.
2. **No ordering dependency.** Neither slice needs the other's output to compile or to pass its own tests.

If you cannot prove both from the plan, use one agent. A wrong split is expensive: you get a red tree, two reports that each blame the other, and no way to tell which half is wrong.

When you do split, give every agent an explicit file boundary in its dispatch message — the paths it owns and the paths it must not touch — and name the steps it owns by their plan ids. Dispatch them in a single message so they run concurrently.

Sequential agents are a third option and a good one for a long plan: one agent per stage, each dispatched only after the previous returned `BUILT` and the gate was green. Use it when the stages are dependent but large enough that one agent would lose the thread.

## Dispatch

Give each `glab:developer` agent:

- the slug, and the exact step ids it owns;
- the file boundary, when there is more than one agent;
- anything decided in this conversation that is not written in the plan — an answer I gave you, a constraint I added. The agent cannot see this conversation and will build the plan as written unless you tell it otherwise;
- the model, only when I named one for the developer: pass it as the Agent tool's `model` parameter on every `glab:developer` dispatch, slices and re-dispatches alike. I named none → pass none. Never choose one yourself (`glab:manager` Rule 5).
- the effort, always: the Agent tool's `effort` parameter on every `glab:developer` dispatch, at the level `glab:manager` Rule 0d gives.
- **An external developer**, only when `glab:manager` Rule 5 recorded one: start it through `glab:external-agents` with `--role developer` instead of dispatching `glab:developer`, with the same brief. One agent, never split, never beside a `glab:developer`.

Do not paste the plan into the prompt. The agent reads it; a paraphrase is how a step quietly changes meaning.

## When the agents return

An agent's report is not evidence. Verify it yourself, in this order, and do not skip ahead to `/glab:analyze` on a red tree:

**An external developer first**, before the gates (`glab:external-agents`, *The developer role*):

- the exit and the `git:` line. Any exit but 0, or `git: changed`, stops the pipeline: show me the `changed:` lines, and revert, commit or re-run nothing on that tree — that is my call;
- then, only on 0 with `git: unchanged` and with no nested repository refused, read the whole change yourself, against the plan, as you would a `glab:developer`'s, from the script's `changed:` lines: for each tracked path one names, `git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u -- - <path>` (`cat-file` applies no filter), and each untracked (`??`) and each ignored (`!!`) path it names that is a regular file, read directly. Never open a path that is a link or not a regular file: show a link with `readlink` and anything else with `ls -l`. Run neither `git status` nor `git diff` on that tree before that check: both can run a clean filter or an fsmonitor the agent planted. A nested repository stops the work, as `git: changed` does;
- then write `plan/{slug}/result.md` from its reply, marked as that model's words, with the script's `changed:` and `git:` lines; the gates below go into it as you ran them;
- then the gates, as for any agent.

Use the repo's own targets — `make`, `just`, `npm run`, a script under `scripts/` — rather than hand-rolled commands, so you are running the same thing CI runs.

1. **Build** — whatever the repo builds with. `glab:plan-first` owns the command.
2. **Unit tests** — the repo's test target. Green means green: no failures, no data races, no package you meant to cover silently skipped.
3. **Lint** — the repo's lint target, and it must be clean.

**Never run a lint or format target in fix mode** — `--fix`, `--write`, `-w`, or a target that wraps one. Auto-fixers rewrite the whole tree rather than your diff, they routinely produce code that does not compile (adding a call without its import, removing the last use of one and leaving the import), and they are often not idempotent, so one pass is not a fixed point. Check whether the repo's lint target carries a fix flag before running it; if it does, run the underlying tool without that flag. Fix findings by hand and understand each one — that is the point of the gate.

If the repo separates a changed-code gate from a whole-tree sweep, the gate is what you must pass. A sweep that carries a pre-existing backlog is a burn-down list for its own task, never a pass/fail check on yours.

Then read the diff against the plan yourself. An agent that reports `BUILT` can still have built the wrong thing, and you are the one who saw my answers.

If an agent returns `PLAN WRONG`, stop the build. Amending the plan is a `glab:manager` Rule 3 decision — yours when it is an engineering choice, mine when it meets an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer. An amended plan means implementing again and re-running the plan's next stage.

If an agent returns `BLOCKED`, decide whether it is unblockable — a missing decision is yours under `glab:manager` Rule 3 unless it is one of the four that are mine, a dependency on another slice means you sequenced it wrong and should re-dispatch rather than patch it yourself.

**Build the plan, not your own better idea.** That applies to you as much as to the agents. If you find yourself fixing an agent's work beyond a mechanical consequence, you have taken over the implementation, and the split stopped meaning anything.

When all three gates are green, hand off to the plan's next stage — `/glab:analyze` at full tier, `/glab:integrate` at normal. Do not run `/glab:review` yourself. Do not commit. Do not push.
