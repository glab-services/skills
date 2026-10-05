---
description: Implement an approved plan through developer agents — plan-first steps 5 to 7 — then hand off to /analyze
argument-hint: "[plan slug]"
---

Read `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so), then `plan/$ARGUMENTS/plan.md`. If no slug was given, ask which plan; do not guess, and do not pick the most recent.

You are the orchestrator here. **You do not write the implementation yourself** — the `developer` agent does. Your job is to check the preconditions, decide how the work is split, dispatch, and verify what comes back.

## Before dispatching anything

- **No plan and no `waived.md`** → stop. That is `/plan`, not this.
- **`plan/{slug}/waived.md` exists** → that is `plan-first`'s waiver and it is a valid start; say you are working from a waiver, not a plan, and that `/analyze` therefore has nothing to measure against.
- **`plan/{slug}/questions.md` exists** → read it. These files have no single convention, so do not try to decide mechanically whether every question is answered. If it is not obvious that all of them are, ask me. Do not refuse on stale text and do not assume an answer.
- **Approval** → nothing records it, so do not pretend to check. Ask me to confirm the plan is approved before any agent writes code, unless I approved it in this conversation.
- **Green tree** → run the plan's own gate once before touching anything. Dispatching onto a red tree means every agent inherits a failure it did not cause and cannot tell apart from its own.

## Decide the split

Read the plan's stages and decide **one agent or several**. Say which you chose and why before dispatching.

**One agent is the default.** Use it whenever the stages build on each other, which is most plans: a later stage importing a type an earlier stage defines, a UI step consuming a command step, a deletion step waiting on its replacement to pass.

**Split only when two conditions both hold:**

1. **Disjoint files.** The slices touch no file in common — not the same test file, not the same barrel export, not the same config. Two agents editing one file in one working tree will clobber each other; there is no merge step to save you.
2. **No ordering dependency.** Neither slice needs the other's output to compile or to pass its own tests.

If you cannot prove both from the plan, use one agent. A wrong split is expensive: you get a red tree, two reports that each blame the other, and no way to tell which half is wrong.

When you do split, give every agent an explicit file boundary in its dispatch message — the paths it owns and the paths it must not touch — and name the steps it owns by their plan ids. Dispatch them in a single message so they run concurrently.

Sequential agents are a third option and a good one for a long plan: one agent per stage, each dispatched only after the previous returned `BUILT` and the gate was green. Use it when the stages are dependent but large enough that one agent would lose the thread.

## Dispatch

Give each `developer` agent:

- the slug, and the exact step ids it owns;
- the file boundary, when there is more than one agent;
- anything decided in this conversation that is not written in the plan — an answer I gave you, a constraint I added. The agent cannot see this conversation and will build the plan as written unless you tell it otherwise.

Do not paste the plan into the prompt. The agent reads it; a paraphrase is how a step quietly changes meaning.

## When the agents return

An agent's report is not evidence. Verify it yourself, in this order, and do not skip ahead to `/analyze` on a red tree:

Use the repo's own targets — `make`, `just`, `npm run`, a script under `scripts/` — rather than hand-rolled commands, so you are running the same thing CI runs.

1. **Build** — whatever the repo builds with. `plan-first` owns the command.
2. **Unit tests** — the repo's test target. Green means green: no failures, no data races, no package you meant to cover silently skipped.
3. **Lint** — the repo's lint target, and it must be clean.

**Never run a lint or format target in fix mode** — `--fix`, `--write`, `-w`, or a target that wraps one. Auto-fixers rewrite the whole tree rather than your diff, they routinely produce code that does not compile (adding a call without its import, removing the last use of one and leaving the import), and they are often not idempotent, so one pass is not a fixed point. Check whether the repo's lint target carries a fix flag before running it; if it does, run the underlying tool without that flag. Fix findings by hand and understand each one — that is the point of the gate.

If the repo separates a changed-code gate from a whole-tree sweep, the gate is what you must pass. A sweep that carries a pre-existing backlog is a burn-down list for its own task, never a pass/fail check on yours.

Then read the diff against the plan yourself. An agent that reports `BUILT` can still have built the wrong thing, and you are the one who saw my answers.

If an agent returns `PLAN WRONG`, stop and bring it to me. Amending the plan is my call, and an amended plan means implementing again and re-running `/analyze`.

If an agent returns `BLOCKED`, decide whether it is unblockable — a missing decision comes to me, a dependency on another slice means you sequenced it wrong and should re-dispatch rather than patch it yourself.

**Build the plan, not your own better idea.** That applies to you as much as to the agents. If you find yourself fixing an agent's work beyond a mechanical consequence, you have taken over the implementation, and the split stopped meaning anything.

When all three gates are green, hand off to `/analyze`. Do not run `/review` yourself. Do not commit. Do not push.
