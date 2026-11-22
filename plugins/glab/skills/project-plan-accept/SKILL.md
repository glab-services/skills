---
name: project-plan-accept
description: Project level — Accept a project plan: its tier, the acceptance checklist, a question's answer, then after the plan check the approval and the master's hash
argument-hint: "[plan slug]"
---

`$ARGUMENTS` is the slug, or a sub-plan `<slug>/<nn>-<name>`. None → ask which plan — never the most recent, never a guess. The project manager runs this when the planner returns, and again for the approval once the plan check has passed. A plan the user handed over: run it on theirs.

**The tier.** The planner writes the tier line, the first line of `plan.md` (`glab:project-plan` Step 0). Accept it, or send the plan back to be raised; a raise after acceptance is a `## Decisions` overrule line. Only the user lowers a tier.

### Plan acceptance checklist

Do not forward a plan to `/glab:project-develop` until all eight hold. Where one fails, say which and send it back.

1. **Understandable.** Every stage is one instruction a competent engineer can act on without asking what it means. No stage says "handle X properly".
2. **Its shape.** Every item `glab:project-plan` Step 3 lists is there, its three phases and its milestone test included.
3. **Findings cover the whole scope surface.** Every file, package, module and directory the change touches or depends on, by path. Each method the change **changes** carries its call sites and what each relies on; each method it only **calls** carries the precondition its new call site must meet and how the plan meets it; a file it only depends on is listed by path, not read in full (`glab:project-plan` Step 1). A findings file or section with no path list has not done this step.
4. **Choices are decided, and a question carries its own context.** Every choice the plan rests on has its line under `## Decisions`. A question for the user — Rule 3 says which, and aims for one at most — states the problem in full, why it blocks the plan, and the recommended answer spelled out with its consequence. "Which approach do you want?" with no options is a shrug, not a question. Send those back.
5. **No stage contradicts another.** Read the stages back to back: no later stage may rewrite, revert or override what an earlier one wrote. A value that must change twice is one stage, not two. This is the check plans fail most often and the one that confuses developers worst.
6. **Within its size.** `glab:project-plan` Step 3 caps `master.md`, `plan.md`, `index.md` and `evidence.md` at 49152 bytes (48 KB) each. Check it by size alone, without reading them (Rule 2): `wc -c` on each that exists, and `grep -c '^- size: ' plan/{slug}/plan.md`. Over the cap with no `- size:` line: send it back to be split or cut. With one: that is a Rule 3 choice of yours — accept it, or send it back to be split.
7. **A master.** `grep -c '^## \(Request\|Goals\|Out of scope\|Final check\|Record\)$' plan/{slug}/master.md` prints `5`, and with sub-plans `index.md` has one line per sub-plan folder. Checked by search, not by reading.
8. **A brief or an issue, quoted.** A plan made from a brief: `grep -cE '^- brief: briefs/[a-z0-9-]+/brief\.md sha256 [0-9a-f]{64}$' plan/{slug}/master.md` prints `1`. A plan from a brief without the line, or with another brief's, is sent back: without it nothing reports it and nothing gates it. A plan made from an issue (`glab:project-issue`): `grep -cE '^- issue: [^ /]+/[^ #]+#[0-9]+ sha256 [0-9a-f]{64}$' plan/{slug}/master.md` prints `1`; ``grep -E '^- issue: ' plan/{slug}/master.md | grep -cF " sha256 $(sha256sum plan/{slug}/issue.md | cut -c1-64)"`` prints `1`; `LC_ALL=C awk 'f && !/^> /{exit} f{print substr($0,3)} /^- issue: /{f=1}' plan/{slug}/master.md | cmp - plan/{slug}/issue.md` prints nothing; the brief grep prints `0`; any other result is sent back, since the master must quote exactly the issue fetched.

Where the work reimplements a documented external API, the findings must cite that vendor documentation by URL. A plan with no citations has unverified behavioural claims.

### A question blocks; a decision does not

A Rule 3 question stops its plan. Bring it to the user with its full context, get the answer, and **write the answer into `plan/{slug}/questions.md` yourself** — after a report to product, into `after-verdict.md` (`glab:project-plan-report`) — that file is how the developer sees it. Never close that one by assuming an answer, and never turn a choice of your own into one.

### The approval

**Approval comes after Stage 1b has passed** — the master check, when the work split — so the user approves a checked plan: explicitly at full tier and whenever the work split. At normal tier with no sub-plans, report the tier and the decisions and go on. Then write the last section of `master.md`, `## Approval`, one line — `- approved by the user, <date>, in chat | in plan mode: "<their words>"; base <git rev-parse --short HEAD>`, or `- accepted at normal tier, reported to the user, <date>; base <sha>` — and hash it, from the repo root: `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256`. The base is where the final check's range starts.

At full tier the user also approves `plan.md`, explicitly — a single plan's together with the master, each full-tier sub-plan's after its own Stage 1b — and you end that `plan.md` with its own `## Approval` line in the master's form. At normal tier the master's approval covers a sub-plan.

**The master is constant once accepted:** never edit it after its hash. Before that it is amended like a plan. When the user changes the request, remove `master.sha256` — so the plan check does not test the new master against the old hash — and dispatch a planning agent, granted the new master, to write it as `glab:project-plan` Step 4 says; the new master goes through its own plan check (Stage 1b), then a new `## Approval` line and a new hash. Stage 1b runs again for every sub-plan not yet committed; the committed ones meet the new master at the final check.

Approval in plan mode, only when the user asks: read `references/plan-mode.md`.
