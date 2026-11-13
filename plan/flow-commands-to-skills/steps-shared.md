# flow-commands-to-skills — steps for the shared skills and `glab:plan`

Part of `plan.md` *processing*, run after P1. File boundary: `plugins/glab/skills/{security,comments,audit}/` (`audit/references/plan-template.md` included) and `plugins/glab/skills/plan/SKILL.md` — the former `plugins/glab/skills/plan-first/SKILL.md`, which P1 moved there unchanged. Old texts are as of `5a72155`. The blocks follow `plan.md` *Block formats*; each edit's check is its line in the posts block at the end of this file.

## glab:security — `plugins/glab/skills/security/SKILL.md`

### SE1 — a reference to a named open test (C8)

~~~ SE1 old plugins/glab/skills/security/SKILL.md
`UNVERIFIED` is not a failure. Reporting it as verified is.
~~~
~~~ SE1 new
`UNVERIFIED` is not a failure. Reporting it as verified is.

A reference to a named open test — `UNVERIFIED: L5` — is that form when the paragraph citing it states the why once.
~~~

### SE2 — what the test cache hides (C6)

~~~ SE2 old plugins/glab/skills/security/SKILL.md
No `-count=1` hiding a test that only fails on the second run.
~~~
~~~ SE2 new
A cached result is not a run: `-count=1` defeats Go's test cache, and a test that fails only on its second run shows only under `-count=2`.
~~~

### SE3 — a lint target that carries a fix flag (C11, A24, B25)

~~~ SE3 old plugins/glab/skills/security/SKILL.md
Check whether the repo's lint target carries a fix flag before running it.
~~~
~~~ SE3 new
Check whether the repo's lint target carries a fix flag before running it; if it does, run the underlying tool without that flag.
~~~

### SE4 — the DSN case moves here from `glab:bootstrap` step 6 (C16)

~~~ SE4 old plugins/glab/skills/security/SKILL.md
A remote URL can carry credentials in its userinfo. Name the remote instead of printing it.
~~~
~~~ SE4 new
A remote URL can carry credentials in its userinfo. Name the remote instead of printing it.

Do not print config values at all; test them instead. A brief that left this out is how one credential leaked a third time: an agent enumerating config for an unrelated reason redacted by key name and printed a DSN's embedded password. A DSN carries a password in the middle of a value, not only after an `@` — two different redaction attempts leaked one.
~~~

## glab:comments — `plugins/glab/skills/comments/SKILL.md`

### CO1 — the marker search runs the system grep (C9)

~~~ CO1 old plugins/glab/skills/comments/SKILL.md
1. `grep -n "TODO\|FIXME\|HACK\|NOTE\|XXX" <file>` on the original.
~~~
~~~ CO1 new
1. `command grep -n -E 'TODO|FIXME|HACK|NOTE|XXX' <file>` on the original — `command` bypasses a shell function named `grep` (`glab:bootstrap` step 6).
~~~

## glab:audit — `plugins/glab/skills/audit/`

### AU1 — proven and inferred by `glab:security` Rule 6 (C1)

~~~ AU1 old plugins/glab/skills/audit/SKILL.md
Separate what you **proved** from the code and what you **inferred**. Never present inferred runtime behavior as proven.
~~~
~~~ AU1 new
Separate proven from inferred, as `glab:security` Rule 6 defines them. Never present inferred runtime behavior as proven.
~~~

### AU2 — the template's two definitions (C1)

~~~ AU2.1 old plugins/glab/skills/audit/references/plan-template.md
- **Proven**: <behavior confirmed by reading the code or running it>
~~~
~~~ AU2.1 new
- **Proven** (`glab:security` Rule 6): <behavior shown by a command you ran, and the command>
~~~

~~~ AU2.2 old plugins/glab/skills/audit/references/plan-template.md
- **Inferred**: <behavior assumed but not verified — flag anything load-bearing>
~~~
~~~ AU2.2 new
- **Inferred**: <behavior reasoned from the code, the types or a name — flag anything load-bearing>
~~~

### AU3 — the three references to `glab:plan-first` (decisions *glab:plan*, Q1 = A)

The description (`:3`):

~~~ AU3.1 old plugins/glab/skills/audit/SKILL.md
For analysis that leads directly into implementation, use glab:plan-first instead.
~~~
~~~ AU3.1 new
For analysis that leads into a change, use glab:plan instead.
~~~

`:21`:

~~~ AU3.2 old plugins/glab/skills/audit/SKILL.md
If the analysis is the first step toward changing the code, use [glab:plan-first](../plan-first/SKILL.md) instead — that workflow carries analysis through questions, plan, implementation, and tests.
~~~
~~~ AU3.2 new
If the analysis is the first step toward changing the code, use [glab:plan](../plan/SKILL.md) instead — that workflow carries analysis through questions to an approved plan, which `/glab:develop` then builds.
~~~

`:69`:

~~~ AU3.3 old plugins/glab/skills/audit/SKILL.md
that work goes through [glab:plan-first](../plan-first/SKILL.md).
~~~
~~~ AU3.3 new
that work goes through [glab:plan](../plan/SKILL.md).
~~~

## glab:plan — `plugins/glab/skills/plan/SKILL.md`

The planning procedure of `glab:plan-first`, Steps 0 to 4, under the stage name the user types (`/glab:plan <task>`) and the name `glab:planner` preloads. The `/glab:plan` command's wrapper text is not carried over: Stage 1 dispatches the planner directly (`steps-manager.md` M0.6), the trivial-work line and its reason are `glab:manager` Rule 1's, which Step 0 points at (PF2), and the user-only waiver rule is *User Override*'s (PF9.2) — each once.

### PF0 — the frontmatter: the name, the description, and the command's `argument-hint` (A8, A19; Q1 = A)

~~~ PF0 old plugins/glab/skills/plan/SKILL.md
name: plan-first
description: Mandatory analyze-then-plan-then-implement workflow. Use for every non-trivial task — feature, bug fix, refactor, flow change, or integration — before touching code. Writes findings, decisions, and a plan to plan/{slug}/, only then implements, builds, and tests, and once the change is pushed records it in the area spec under docs/specs/. Triggers whenever the user asks to build, fix, refactor, integrate, or investigate something in the codebase. Skip only for trivial one-line changes.
~~~
~~~ PF0 new
name: plan
description: Mandatory analyze-then-plan workflow — size, analyze, decide and plan a task before any code is written. Use for every non-trivial task — feature, bug fix, refactor, flow change, or integration. Writes findings, decisions, and a plan to plan/{slug}/ and stops there: the build is glab:developer's, through /glab:develop, and once the change is pushed it is recorded in the area spec under docs/specs/. Triggers whenever the user asks to build, fix, refactor, integrate, or investigate something in the codebase. Skip only for trivial changes (glab:manager Rule 1).
argument-hint: "[what to build or fix]"
~~~

### PF1 — the heading, the task from `$ARGUMENTS`, and the diagram stop at verify (A8, A19; Q1 = A)

~~~ PF1 old plugins/glab/skills/plan/SKILL.md
# Plan First

Analyze, plan, then execute. No implementation without a plan.

```
size → analyze → decide → plan → verify → implement → E2E tests → unit tests
```
~~~
~~~ PF1 new
# Plan

Analyze, then plan. No implementation without a plan.

**The task** is what follows `/glab:plan` when a person types it — $ARGUMENTS — or, when nothing does, as when `glab:planner` preloads this skill, the task its dispatch or the user names.

```
size → analyze → decide → plan → verify
```
~~~

### PF2 — Step 0's trivial line is `glab:manager` Rule 1's, and it stops here (A19)

~~~ PF2 old plugins/glab/skills/plan/SKILL.md
- **Trivial** (skip this workflow): single-line changes, typo fixes, config one-liners, obvious renames, adding a known import — anything under ~5 lines with no architectural impact. Do it directly.
~~~
~~~ PF2 new
- **Trivial** (skip this workflow): under `glab:manager` Rule 1's line. Say so and stop.
~~~

### PF3 — Step 1: where the evidence goes at each tier, and proven by `glab:security` Rule 6 (A18, C1)

~~~ PF3.1 old plugins/glab/skills/plan/SKILL.md
Write findings to `plan/{slug}/evidence.md` — not `findings.md`: Claude Code refuses a subagent's Write of a file by that name.
~~~
~~~ PF3.1 new
Write findings to `plan/{slug}/evidence.md` at full tier and as the evidence section of `plan.md` at normal tier — never to `findings.md`: Claude Code refuses a subagent's Write of a file by that name.
~~~

~~~ PF3.2 old plugins/glab/skills/plan/SKILL.md
- Separate **Proven behavior** from **Inferred behavior**. Never present inferred runtime behavior as proven.
~~~
~~~ PF3.2 new
- Separate proven from inferred, as `glab:security` Rule 6 defines them. Never present inferred runtime behavior as proven.
~~~

*Quick Reference*'s Analyze row says the same as PF3.1 (R2-3):

~~~ PF3.3 old plugins/glab/skills/plan/SKILL.md
| Analyze | Findings | `plan/{slug}/evidence.md` |
~~~
~~~ PF3.3 new
| Analyze | Findings | `plan/{slug}/evidence.md` at full tier, the evidence section of `plan.md` at normal |
~~~

### PF4 — Step 2: a fact is proven with a command (C1)

Step 2's ask-conditions sentence and "The manager reviews those lines and may overrule one, recording the overrule as a new line." stay (A26, A28: the planner's copy).

~~~ PF4 old plugins/glab/skills/plan/SKILL.md
Prove it from the code: read the callers, run it.
~~~
~~~ PF4 new
Prove it with a command — grep the callers, run it (`glab:security` Rule 6).
~~~

### PF5 — Step 3: the three phases (A5)

~~~ PF5 old plugins/glab/skills/plan/SKILL.md
- ordered steps with exact files and expected changes;
~~~
~~~ PF5 new
- ordered steps with exact files and expected changes, in three phases: `before` — preconditions, the gate run green, flags, what must be true to start; `processing` — the ordered change steps; `after` — verification, the milestone test, documentation, and how to back the change out;
~~~

### PF6 — a sub-plan's evidence as Step 1 says (A18)

~~~ PF6 old plugins/glab/skills/plan/SKILL.md
its own `plan.md`, tier line, `evidence.md`, `questions.md` and round copies
~~~
~~~ PF6 new
its own `plan.md`, tier line, evidence as Step 1 says, `questions.md` and round copies
~~~

### PF7 — Step 4: the boundary is proven by a command (C1)

~~~ PF7 old plugins/glab/skills/plan/SKILL.md
- the chosen boundary is proven by the semantics of the existing implementation — not by naming or file placement;
~~~
~~~ PF7 new
- the chosen boundary is proven against the existing implementation by a command you ran (`glab:security` Rule 6) — not by naming or file placement;
~~~

### PF8 — a changed request: the planner's part (A27)

~~~ PF8 old plugins/glab/skills/plan/SKILL.md
When the user changes the request, the manager has a planning agent keep the old master as `master.v<n>.md` — a version copy, never `.r<n>` — and write a new `master.md`; the old `## Approval` line and `master.sha256` do not carry over, and the new master goes through its own plan check (Stage 1b), then a new approval and a new hash.
~~~
~~~ PF8 new
When the user changes the request and your dispatch grants it, copy the old master to `master.v<n>.md` — a version copy, never `.r<n>` — and write a new `master.md` with no `## Approval` line; its hash, its approval and its plan check are the manager's (`glab:manager` *The master plan and sub-plans*).
~~~

### PF9 — planning stops at Step 4, and the waiver is the user's alone (A15, B33, C18, B30; Q1 = A)

Steps 5 to 7 (heading and body, `:116-118`) give way to a pointer; *Repo Rules* stays as it is:

~~~ PF9.1 old plugins/glab/skills/plan/SKILL.md
## Steps 5 to 7 — Implement, E2E tests, unit tests

They are in [`implement.md`](implement.md), beside this file, with the repo rules that bind only the implementation — service lifecycle, nested repositories, commits. Read it once the plan is verified and approved (Step 4), or once a waiver is written (*User Override*). **A planning agent stops at Step 4 and does not read it.**
~~~
~~~ PF9.1 new
## After Step 4

The build is `glab:developer`'s, through `/glab:develop` (`glab:manager` Stage 2); the E2E run is `glab:integrator`'s (Stage 4). A planning agent stops at Step 4.
~~~

In *User Override*, the rule the `/glab:plan` command held — only the user's own words make a waiver — joins the one already there:

~~~ PF9.2 old plugins/glab/skills/plan/SKILL.md
Then implement, from [`implement.md`](implement.md): the waiver stands in for the verified, approved plan it asks for.
~~~
~~~ PF9.2 new
Only the user's own words make a waiver: never write one on the user's behalf — not to save a stage, and not because a task looks simple. Then `/glab:develop` builds from it: the waiver stands in for the verified, approved plan.
~~~

### PF10 — *Quick Reference*: one build row (Q1 = A)

~~~ PF10 old plugins/glab/skills/plan/SKILL.md
| Implement | Code changes | the repo |
| E2E tests | the repo's canonical runner | wherever the suite lives |
| Unit tests | the repo's test target | the repo |
~~~
~~~ PF10 new
| Build | Code, tests, `result.md` | `/glab:develop`, then the stages after it (`glab:manager`) |
~~~

### PF11 — Step 4 is what the planner confirms before the plan check; the check and the approval are the manager's (R2-6)

The planner returns before Stage 1b and before any approval, so it cannot confirm them; `/glab:develop`'s *Approval* precondition (`steps-stages.md` S3) is where they are checked:

~~~ PF11 old plugins/glab/skills/plan/SKILL.md
Before implementing, confirm:

- every gap is proven, decided, or answered by the user;
- the plan covers every finding, with no gaps left;
- the plan check has passed and `master.md` has its `## Approval` line — the user's at full tier and whenever the work split — and a full-tier `plan.md`, a single plan's or a sub-plan's, ends with its own;
~~~
~~~ PF11 new
Before the plan goes to the plan check, confirm what follows; the check and the approval after it are `glab:manager`'s (Stages 1b and 1), and `/glab:develop` checks both before any code is written:

- every gap is proven, decided, or answered by the user;
- the plan covers every finding, with no gaps left;
~~~

## Posts

~~~ posts
SE1 | 1 | /usr/bin/grep -c -F 'is that form when the paragraph citing it states the why once' plugins/glab/skills/security/SKILL.md
SE2 | 1 | /usr/bin/grep -c -F 'shows only under `-count=2`' plugins/glab/skills/security/SKILL.md
SE3 | 1 | /usr/bin/grep -c -F 'run the underlying tool without that flag' plugins/glab/skills/security/SKILL.md
SE4 | 1 | /usr/bin/grep -c -F 'embedded password' plugins/glab/skills/security/SKILL.md
CO1 | 1 | /usr/bin/grep -c -F "command grep -n -E 'TODO|FIXME|HACK|NOTE|XXX'" plugins/glab/skills/comments/SKILL.md
AU1 | 1 | /usr/bin/grep -c -F 'as `glab:security` Rule 6 defines them' plugins/glab/skills/audit/SKILL.md
AU2.1 | 1 | /usr/bin/grep -c -F '**Proven** (`glab:security` Rule 6)' plugins/glab/skills/audit/references/plan-template.md
AU2.2 | 1 | /usr/bin/grep -c -F 'reasoned from the code, the types or a name' plugins/glab/skills/audit/references/plan-template.md
AU3.1 | 1 | /usr/bin/grep -c -F 'For analysis that leads into a change, use glab:plan instead.' plugins/glab/skills/audit/SKILL.md
AU3.2 | 1 | /usr/bin/grep -c -F 'which `/glab:develop` then builds' plugins/glab/skills/audit/SKILL.md
AU3.3 | 1 | /usr/bin/grep -c -F 'that work goes through [glab:plan](../plan/SKILL.md).' plugins/glab/skills/audit/SKILL.md
PF0 | 1 | /usr/bin/grep -c -x -F 'name: plan' plugins/glab/skills/plan/SKILL.md
PF0 | 1 | /usr/bin/grep -c -x -F 'argument-hint: "[what to build or fix]"' plugins/glab/skills/plan/SKILL.md
PF1 | 1 | /usr/bin/grep -c -F '$ARGUMENTS' plugins/glab/skills/plan/SKILL.md
PF1 | 0 | /usr/bin/grep -c -F 'verify → implement' plugins/glab/skills/plan/SKILL.md
PF2 | 1 | /usr/bin/grep -c -E "Rule 1's line\. Say so and stop\.$" plugins/glab/skills/plan/SKILL.md
PF3.1 | 1 | /usr/bin/grep -c -F 'as the evidence section of `plan.md` at normal tier' plugins/glab/skills/plan/SKILL.md
PF3.2 | 0 | /usr/bin/grep -c -F 'Separate **Proven behavior**' plugins/glab/skills/plan/SKILL.md
PF3.3 | 1 | /usr/bin/grep -c -F 'evidence.md` at full tier, the evidence section of `plan.md` at normal |' plugins/glab/skills/plan/SKILL.md
PF4 | 1 | /usr/bin/grep -c -F 'Prove it with a command — grep the callers' plugins/glab/skills/plan/SKILL.md
PF5 | 1 | /usr/bin/grep -c -F '`before` — preconditions' plugins/glab/skills/plan/SKILL.md
PF6 | 1 | /usr/bin/grep -c -F 'tier line, evidence as Step 1 says' plugins/glab/skills/plan/SKILL.md
PF7 | 1 | /usr/bin/grep -c -F 'by a command you ran (`glab:security` Rule 6)' plugins/glab/skills/plan/SKILL.md
PF8 | 0 | /usr/bin/grep -c -F 'the manager has a planning agent keep' plugins/glab/skills/plan/SKILL.md
PF9.1 | 1 | /usr/bin/grep -c -x -F '## After Step 4' plugins/glab/skills/plan/SKILL.md
PF9.2 | 1 | /usr/bin/grep -c -F "Only the user's own words make a waiver" plugins/glab/skills/plan/SKILL.md
PF10 | 1 | /usr/bin/grep -c -F '| Build | Code, tests, `result.md` |' plugins/glab/skills/plan/SKILL.md
PF11 | 1 | /usr/bin/grep -c -x -F 'Before the plan goes to the plan check, confirm what follows; the check and the approval after it are `glab:manager`'"'"'s (Stages 1b and 1), and `/glab:develop` checks both before any code is written:' plugins/glab/skills/plan/SKILL.md
PF11 | 0 | /usr/bin/grep -c -F 'the plan check has passed and `master.md` has its' plugins/glab/skills/plan/SKILL.md
~~~
