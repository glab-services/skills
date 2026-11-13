# flow-commands-to-skills — steps for `glab:manager`

Part of `plan.md` *processing*, run after P1. File boundary: `plugins/glab/skills/manager/SKILL.md` only. Old texts are as of `5a72155`; line numbers in the headings are for orientation only. The blocks follow `plan.md` *Block formats*, in the order written; M25 runs last because the old texts above it still say `plan-first`. Each edit's check is its line in the posts block at the end of this file. Recorded cases stay word for word wherever they move. Ids with no step here (M4, M10, M16, M22) are sections that stay as they are.

## glab:manager — `plugins/glab/skills/manager/SKILL.md`

### M0 — the commands become stage skills, and Stage 1 dispatches the planner directly (F8; decisions *stage skills* and *glab:plan*)

`:3`, the description:

~~~ M0.1 old plugins/glab/skills/manager/SKILL.md
using slash commands and subagents
~~~
~~~ M0.1 new
using its stage skills and subagents
~~~

`:153`, Rule 5:

~~~ M0.2 old plugins/glab/skills/manager/SKILL.md
whether the dispatch runs through a `/glab:` command or directly
~~~
~~~ M0.2 new
whether the dispatch runs through a `/glab:` stage skill or directly
~~~

`:197`, the line after the pipeline table — its first sentence; the rest of the line stays:

~~~ M0.3 old plugins/glab/skills/manager/SKILL.md
A command that does not exist in this repo → dispatch the agent of the same role directly with the same contract.
~~~
~~~ M0.3 new
Each `/glab:<name>` under *Run* is the `glab:<name>` stage skill: invoke it yourself through the Skill tool, with the argument *Run* shows, and do not wait for the user to type it — the user can type the same `/glab:<name>` to step in. A stage skill that is not available in this session → dispatch the agent of the same role directly with the same contract.
~~~

`:231`, *The master plan and sub-plans*:

~~~ M0.4 old plugins/glab/skills/manager/SKILL.md
Commands take `{slug}/<nn>-<name>` for a slug
~~~
~~~ M0.4 new
Stage skills take `{slug}/<nn>-<name>` for a slug
~~~

`:186`, the pipeline table's Stage 1 row (M9 edits another cell of the same row):

~~~ M0.5 old plugins/glab/skills/manager/SKILL.md
| 1 | Plan | `/glab:plan <task>` (`glab:planner`) |
~~~
~~~ M0.5 new
| 1 | Plan | `glab:planner` on the task |
~~~

`:286`, Stage 1's first paragraph:

~~~ M0.6 old plugins/glab/skills/manager/SKILL.md
Run `/glab:plan <task>`. If the user already handed you a plan, skip to the acceptance checklist and apply it to theirs.
~~~
~~~ M0.6 new
Dispatch `glab:planner` on the task, as Rules 0c, 0d and 5 say; no stage skill sits in between: the planner preloads `glab:plan`, which holds the procedure. If the user already handed you a plan, skip to the acceptance checklist and apply it to theirs. When the user waives planning, `glab:plan` *User Override* is the rule: you write `plan/{slug}/waived.md` from the user's own words, and never on their behalf.
~~~

### M1 — Rule 0 (A10, A11; R11) — `:12-18`

~~~ M1 old plugins/glab/skills/manager/SKILL.md
*(The `glab:bootstrap` skill runs the full session-start sequence — agreement, skills,
gates, handoff, hazards. This rule is its first step, restated here because it is
the one that cannot be skipped.)*

Read **`AGENTS.md` at the repo root** before anything else in this session. No `AGENTS.md`? Read `CLAUDE.md`, and say plainly that the repo has no working agreement — then the conventions you enforce are the ones you can read off the existing code, not ones you invented.

Make every agent you dispatch read it first too, and `docs/constants.md` with it where the repo has one. Say so in the dispatch message, even when the agent definition already requires it. An agent that skipped it produces work the repo rejects, and you pay for that in a correction round.
~~~
~~~ M1 new
The session-start text of the `glab` hook and `glab:bootstrap` step 1 say what this session reads first, and what to do when there is no `AGENTS.md`. This rule is that step, named here because it is the one that cannot be skipped. Each `glab` agent reads `AGENTS.md` in its own first step, and `glab:planner` reads `docs/constants.md` too; a dispatch repeats neither (Rule 0c).
~~~

### M2 — Rule 0b (A11, C13, C14) — `:22-28`

~~~ M2 old plugins/glab/skills/manager/SKILL.md
It is loaded with this skill and it is not optional. It governs every claim you or an agent makes about the work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Its durability rules bind every stage.

Three places it changes what you do here:

- **Every dispatch message says the agent carries it.** Rule 0c has the full list of what each agent loads and what is your call per dispatch.
- **No stage is reported green on an agent's word.** You run the gate; what you report is what it printed.
- **The trivial-change exemption in Rule 1 does not extend to it.** A five-line change still gets its claim verified.
~~~
~~~ M2 new
It is loaded with this skill and it is not optional: every claim you or an agent makes about the work is held to it, and its durability rules bind every stage. **No stage is reported green on an agent's word** — you run the gate; what you report is what it printed.
~~~

### M3 — Rule 0c, heading and body (A1, A8, A10, A16, A26, B10, C2, C13; decisions FU1-2, FU1-3) — `:30-63`

~~~ M3 old plugins/glab/skills/manager/SKILL.md
## Rule 0c — which skills every agent you dispatch carries

Name them in the dispatch message. An agent definition that already requires one
is not enough — say it anyway, because the dispatch that omits it is the one that
comes back with an unproven claim.

**Always, in every dispatch, no exceptions:**

- **`glab:security`** — the agent proves its own claims or writes `UNVERIFIED`. An
  agent reporting a green gate without pasting the output has not finished, and
  you cannot tell the difference after the fact.
- **`glab:comments`** — the agent records *why* a thing is the way it is, and never
  deletes or rewrites a `TODO`, `FIXME`, `HACK`, `NOTE` or `XXX` marker without
  approval. This is the easiest one to forget, because it is not about the change
  being made — and its cost is silent. The knowledge is gone and nothing in the
  diff shows it was ever there.

**Your call, per dispatch — name it when it fits the agent's job, leave it out
when it does not:**

- **`glab:audit`** — for an agent examining a service, module or subsystem to produce
  *findings* rather than a change. It gives the document its shape: architecture
  summary, working flow, severity-classified issues, prioritized recommendations.
- **`glab:plan-first`** — for `glab:planner`, the planning agent, for the `evidence.md` / `questions.md`
  / `plan.md` structure it enforces. **Mind the seam:** `glab:plan-first` describes a
  workflow that runs through to implementation, and under this skill a planner
  stops at the plan and hands it to Stage 1b. Say which applies, or you have
  given the agent two contradictory instructions — the exact defect the plan
  acceptance checklist rejects in plans. On choices both say one thing: the
  planner decides each and records it under `## Decisions` with its reason, and
  you review those lines and may overrule one, recording the overrule as a new line.

Do not attach a skill an agent has no use for. Each one is context spent before
the agent starts, and an irrelevant one dilutes the ones that matter.
~~~
~~~ M3 new
## Rule 0c — what reaches an agent, and once

Each rule reaches an agent through one channel, never two:

- **The agent's own file** holds every rule only its role acts on.
- **A shared rule lives once, in its skill** — `glab:security`, `glab:comments`, `glab:audit` — and the planner's procedure lives once, in `glab:plan`. Each `glab` agent's frontmatter `skills:` list preloads the ones its role uses. An agent with no definition — a mapping agent, a read-only question, any ad-hoc agent — has no such list: its dispatch names `glab:security`, and `glab:audit` when it produces findings, and that is its one channel.
- **The dispatch carries only the facts of its task:** the slug and the step ids; the file boundary when the work is split; the paths *The master plan and sub-plans* names; the answers and decisions not written in the plan; the round, and what that round is given (Stages 1b, 2, 3, 5, 6b and 8); the temp directory (`glab:bootstrap` step 6); and the `effort` and `model` parameters (Rules 0d and 5). Never a standing rule — not "read `AGENTS.md`", not a skill the agent preloads, not a rule its own file holds. A rule repeated in a dispatch is a second copy the agent has to reconcile with the first.
~~~

### M5 — Rule 1's trivial bullet (A11, C14) — `:81`

~~~ M5 old plugins/glab/skills/manager/SKILL.md
A pipeline that runs for every typo is a pipeline that gets skipped for everything.
~~~
~~~ M5 new
A pipeline that runs for every typo is a pipeline that gets skipped for everything. `glab:security` has no such exemption: a five-line change still gets its claim verified.
~~~

### M6 — Rule 2's report bullet (B4, decision FU1-3) — `:90`

~~~ M6 old plugins/glab/skills/manager/SKILL.md
- **Every agent writes long output to disk and returns a short report.** The developer writes `plan/{slug}/result.md`, except for the record (Stage 8); the reviewer and analyzer return their verdict block. Say this in the dispatch message.
~~~
~~~ M6 new
- **Every agent writes long output to disk and returns a short report**, as its own file's *Report* says.
~~~

### M7 — Rule 5 (A17, A30, B23; R10)

The version bullet (`:154`) becomes *Precedence*:

~~~ M7.1 old plugins/glab/skills/manager/SKILL.md
- **What the documentation promises, and from which version.** The parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main conversation's model — in that order from Claude Code v2.1.251; before it the variable came first. So `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the seven `glab` agents: their definitions set a model. Only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, from v2.1.257, overrides the definitions and the parameter alike. A family alias runs the main conversation's exact model when that model is of the same family. The parameter still holds when the agent is resumed or sent a follow-up only from v2.1.211 — before that, a resumed agent falls back to its definition's model. That a plugin agent's frontmatter `model` and the parameter are honoured is documented — `model` is among the fields a plugin agent supports — and not yet shown by a live dispatch.
~~~
~~~ M7.1 new
- **Precedence.** The parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main conversation's model; only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` overrides the definitions and the parameter alike. From which Claude Code version each of these holds, and what is not yet shown by a live dispatch, is in the `glab` repository's `docs/specs/workflow.md`.
~~~

In *Name it in the handoff line* (`:157`), two version remarks go:

~~~ M7.2 old plugins/glab/skills/manager/SKILL.md
; under `availableModels` it warns when it substitutes, in interactive sessions.
~~~
~~~ M7.2 new
.
~~~

~~~ M7.3 old plugins/glab/skills/manager/SKILL.md
 `/tasks` shows the model a running subagent is on, from v2.1.242.
~~~
~~~ M7.3 new
~~~

In *The pipeline does not bend to the model* (`:158`):

~~~ M7.4 old plugins/glab/skills/manager/SKILL.md
the reviewer still gets the target and nothing else
~~~
~~~ M7.4 new
the reviewer still gets only what Stage 5 gives it
~~~

*Write the dispatch for the model it goes to*, the table and the two paragraphs after it (`:161-172`), become one paragraph:

~~~ M7.5 old plugins/glab/skills/manager/SKILL.md
**Write the dispatch for the model it goes to.** Each model reads instructions in its own way. For the model the role runs on — its definition's or the user's — write that dispatch for it. The agent's file stays as it is; only your dispatch message changes:

| model | what changes in the dispatch |
|---|---|
| `opus`, `fable` | nothing — write it as Rule 0c and the stage say |
| default — an agent with no definition, on Claude Code's own order | nothing — write it as Rule 0c and the stage say |
| `sonnet` | as for `opus`, plus the role's report template pasted in full, to be filled in |
| `haiku` | shorter; every instruction explicit, none left to inference; the work as numbered steps that are references, never content; the role's report template pasted in full, to be filled in |

The numbered steps point at what the agent reads; they never carry it. For the developer: `1 read AGENTS.md; 2 read plan/{slug}/plan.md, steps <ids>; 3 build them; 4 write result.md; 5 fill this template`. You do not restate a plan step, and you do not read the plan to write the steps (Rule 2; Stage 2, "Do not paste the plan"). For the reviewer the steps are only `1 review the target; 2 fill this template` — nothing about the change.

The report template is the *Report* section of the agent's own file, copied as written and never paraphrased. For the reviewer's last round it is the *Report* section plus the last-round verdicts from its *Re-reviews* section — `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>`, `DO NOT PUBLISH: <why>`. Reading those sections is the exception to Rule 2 this needs.
~~~
~~~ M7.5 new
**Write the dispatch for the model it goes to.** For `opus`, `fable`, `sonnet` and an agent with no definition, write it as Rule 0c and the stage say. For `haiku`, shorter: every instruction explicit, none left to inference, the work as numbered steps that are references, never content — for the committer, `1 commit the paths <list>; 2 report as your file says`. The steps point at what the agent reads; they never carry it, and you do not read the plan to write them (Rule 2). The agent's own *Report* section is its template; it is not pasted into the dispatch.
~~~

In *Check what comes back*:

~~~ M7.6 old plugins/glab/skills/manager/SKILL.md
Resume the same agent once — the model holds on a resume from the version named above — and ask only for the missing fields.
~~~
~~~ M7.6 new
Resume the same agent once — the model holds on a resume (see *Precedence*) — and ask only for the missing fields.
~~~

**Moved text, for the record** (Stage 8 carries it into `docs/specs/workflow.md`, where the version history already sits under *How it works now*): the removed `:154` bullet read, verbatim: "**What the documentation promises, and from which version.** The parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main conversation's model — in that order from Claude Code v2.1.251; before it the variable came first. So `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the seven `glab` agents: their definitions set a model. Only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, from v2.1.257, overrides the definitions and the parameter alike. A family alias runs the main conversation's exact model when that model is of the same family. The parameter still holds when the agent is resumed or sent a follow-up only from v2.1.211 — before that, a resumed agent falls back to its definition's model. That a plugin agent's frontmatter `model` and the parameter are honoured is documented — `model` is among the fields a plugin agent supports — and not yet shown by a live dispatch." The removed `:157` text read: "under `availableModels` it warns when it substitutes, in interactive sessions" and "`/tasks` shows the model a running subagent is on, from v2.1.242."

### M8 — *Know the gates before you dispatch* (C15, A9) — `:178-180`

~~~ M8 old plugins/glab/skills/manager/SKILL.md
Every stage below ends on the repo's own build, test and lint targets. **Find them once, at the start of the session** — `Makefile`, `package.json` scripts, `justfile`, CI config — and use those, never a command you composed yourself. Running something CI does not run proves nothing.

Record what you found in one line and reuse it all session. If a repo has no lint or no test target, say so rather than skipping the gate silently.
~~~
~~~ M8 new
Every stage below ends on the repo's own build, test and lint targets, found once at session start and written down in one line (`glab:bootstrap` step 3). Reuse that line all session.
~~~

### M9 — the Stage 1 row's evidence cell (A18) — `:186`

~~~ M9 old plugins/glab/skills/manager/SKILL.md
`evidence.md`, and `questions.md`
~~~
~~~ M9 new
`evidence.md` at full tier, and `questions.md`
~~~

### M11 — a changed request: the manager's part (A27) — `:230`

~~~ M11 old plugins/glab/skills/manager/SKILL.md
No round amends a `master.md` that has an `## Approval` line. When the user changes the request, the manager has a planning agent keep the old master as `master.v<n>.md` — a version copy, never `.r<n>` — and write a new `master.md`; the old `## Approval` line and `master.sha256` do not carry over, and the new master goes through its own plan check (Stage 1b), then a new approval and a new hash. Remove `master.sha256` when you dispatch that agent, so the plan check does not test the new master against the old hash.
~~~
~~~ M11 new
When the user changes the request, remove `master.sha256` — so the plan check does not test the new master against the old hash — and dispatch a planning agent, granted the new master, to write it as `glab:plan` Step 4 says; the new master goes through its own plan check (Stage 1b), then a new approval and a new hash.
~~~

### M12 — *Fan out with care* (A25, A3, B24) — `:253-261`

~~~ M12 old plugins/glab/skills/manager/SKILL.md
**Fan out with care.** Develop writes:

- Split `/glab:develop` **only** when the slices touch no common file **and** have no
  ordering dependency. Two agents editing one file in one working tree clobber
  each other, and there is no merge step to save you.
- Give each agent its explicit file boundary and its step ids in the dispatch
  message.
- If you cannot state the boundary in one sentence, the work is not splittable.
  Run it as one agent.
~~~
~~~ M12 new
**Fan out with care.** Develop writes. One agent is the default: the steps of most plans build on each other — a later step importing a type an earlier one defines, a deletion waiting on its replacement to pass.

- Split `/glab:develop` **only** when the slices touch no common file — not the same test file, barrel export or config — **and** have no ordering dependency: neither needs the other's output to compile or to pass its own tests. Two agents editing one file in one working tree clobber each other, and there is no merge step to save you. A wrong split costs a red tree and two reports that each blame the other.
- Which step ids touch which files is the input to that decision: ask a read-only agent (Rule 2); never read the plan yourself to find out.
- Give each agent its explicit file boundary — the paths it owns and the paths it must not touch — and its step ids, and dispatch them in one message. If you cannot state the boundary in one sentence, the work is not splittable: run it as one agent.
- Sequential agents — one per group of steps, each dispatched once the one before returned `BUILT` and your gate run was green — suit a long plan whose steps depend on each other.
~~~

### M13 — Stage 1 points at `glab:plan` and `glab:security` (A5, A26, C1)

In *Explore once* (`:288`):

~~~ M13.1 old plugins/glab/skills/manager/SKILL.md
proven kept apart from inferred
~~~
~~~ M13.1 new
proven kept apart from inferred (`glab:security` Rule 6)
~~~

The planning-agent paragraph (`:290`):

~~~ M13.2 old plugins/glab/skills/manager/SKILL.md
**The planning agent, `glab:planner`, brings you what it could not settle.** A fact — an endpoint, a vendor behaviour, an existing convention — it proves from the code, the vendor documentation or `docs/constants.md` rather than inferring it. A choice it decides and records under `## Decisions` with its reason; you review those lines under Rule 3 and may overrule one, recording the overrule as a new line. Only a Rule 3 question is relayed to the user, and that one you do not answer on their behalf.
~~~
~~~ M13.2 new
**The planning agent, `glab:planner`, brings you what it could not settle**, sorted as `glab:plan` Step 2 says. You review its `## Decisions` lines under Rule 3, and relay only a Rule 3 question to the user — that one you do not answer on their behalf.
~~~

Checklist item 2 (`:297`):

~~~ M13.3 old plugins/glab/skills/manager/SKILL.md
2. **Three phases, explicitly.** `before` — preconditions, the gate run green, flags, what must be true to start. `processing` — the ordered change steps. `after` — verification, the test that proves the milestone runs end to end, documentation, and how to back it out. A feature plan that ends with nothing new running is a slice of another plan's milestone; merge them. A refactor, config or test-only plan names the existing test that proves nothing broke as its milestone.
~~~
~~~ M13.3 new
2. **Its shape.** Every item `glab:plan` Step 3 lists is there, its three phases and its milestone test included.
~~~

### M14 — Stage 1b keeps the dispatch; the check goes to `glab:plan-analyzer` (A2; R8)

`:327-373`, from "It exists because of a real case." through the end of the paragraph "**Ask the intent question too** …a finding like any other." — `steps-agents.md` PA1 carries that text — becomes one paragraph:

~~~ M14.1 old plugins/glab/skills/manager/SKILL.md
It exists because of a real case. A plan step said two methods would "each call
`Apply`" and never said how the subject reached them — no channel existed, on
either transport, and one of the two carried no identity at all. A developer
agent spent a full run establishing that and wrote no code. Read-only analyzers
would have found it for a fraction of the cost, and the plan's own heading
already carried `[BLOCKED]`.

So **before dispatching `/glab:develop`, dispatch `glab:plan-analyzer` agents against the plan itself.**
One question: *can this be built exactly as written?* Answered by reading the
code the plan names — never by judging the prose.

Each `glab:plan-analyzer`, for its assigned surface:

- **Resolve every `file:line` the plan cites.** A drifted line number is noise. A
  cited function whose signature cannot do what the plan asks is a blocker.
- **Name the mechanism behind each step and confirm it exists.** "X calls Y" is
  buildable only if X can obtain Y's arguments. This is the check that was
  missing above, and the one that pays for the stage.
- **Read the plan's own constraints against each other.** One plan required a
  predicate inside a method *and* "no call-site change" at 120 call sites — a
  signature change satisfies one and breaks the other. Contradictions are found
  by reading constraints side by side, and only before the build.
- **Verify preconditions are met, not merely stated.** A `before` block saying
  "grants must exist" is worth nothing until someone runs the count.

**Ask of every post-condition: can this tell a finished tree from a
half-finished one?** This is the strongest question in the stage and it is not the
same as checking for contradictions. Measured on one plan: the discriminating
question found **six** defects; reading the stages against each other found
**none** of them.

A wrong *edit* fails loudly the first time someone runs the tests. A wrong
*post-condition* passes — and the dangerous ones pass on incomplete work. One
plan expected 40 registered patterns where a correct tree has 45; **40 is exactly
what a tree with one step skipped produces**, so the check was green on the broken
state and red on the fixed one. Its author had caught that identical trap in
another check of the same plan and rebuilt it here.

Two corollaries worth stating, both learned the same way:

- **A total is weaker than a list.** Two different partial states summed to the
  same 15 lines; only naming the three expected files separated them.
- **Some checks cannot discriminate, and should say so.** An absence invariant
  returns empty before and after; a cross-slice regression guard is meant to pass
  either way. Mark those explicitly so nobody mistakes their silence for proof.

**Ask the intent question too** — `glab:plan-analyzer` *The intent question*: of the master, whether every request reaches a goal and every goal a line of `index.md` (the coverage question); of each plan, whether it delivers its goals as `## Request` words them. For a single plan one analyzer asks both, of `master.md` and `plan.md` together. A gap is a finding like any other.
~~~
~~~ M14.1 new
**Before dispatching `/glab:develop`, dispatch `glab:plan-analyzer` agents against the plan itself**, split by surface (*Running agents in parallel*). What each one checks, and the case that showed why this stage exists, is `glab:plan-analyzer` *The plan check*.
~~~

In *The amendment* paragraph (`:377`), three edits:

~~~ M14.2 old plugins/glab/skills/manager/SKILL.md
, and `glab:plan-first` with the seam stated.
~~~
~~~ M14.2 new
.
~~~

~~~ M14.3 old plugins/glab/skills/manager/SKILL.md
replacing the changed text in place rather than adding beside it (`glab:plan-first` Step 4)
~~~
~~~ M14.3 new
as `glab:plan` Step 4 says
~~~

~~~ M14.4 old plugins/glab/skills/manager/SKILL.md
after it, only a version copy `master.v<n>.md` (*The master plan and sub-plans*)
~~~
~~~ M14.4 new
after it, the planner's version copy `master.v<n>.md` (`glab:plan` Step 4)
~~~

### M15 — Stage 2, through the end of *Verify before moving on* (A3, A6, A14, A25, A29, B4, B21, B26, B27, C11, C12) — `:385-420`

~~~ M15 old plugins/glab/skills/manager/SKILL.md
Run `/glab:develop {slug}`. One agent is the default. Split only when the slices touch no common file **and** have no ordering dependency — two agents editing one file in one working tree clobber each other, and there is no merge step to save you.

Give the `glab:developer` agent, in the dispatch message:

- the slug and the exact step ids it owns, and its file boundary when the work is split;
- **the resolved answers** from `questions.md` and anything decided in this conversation that is not written in the plan — the agent cannot see this chat;
- **your own suggestions**, marked as suggestions, so they are not mistaken for plan steps;
- **the model, only when the user named one for the developer** — passed with the dispatch as the Agent tool's `model` parameter (Rule 5) — otherwise none: the definition's `sonnet` runs. None named, none passed.
- **the effort, always** — the Agent tool's `effort` parameter at the level Rule 0d gives.
- **for a fix round** — after `DIVERGES` or review findings: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. It reads `plan.md`, `result.md` and the tree itself, fixes only what the findings name, and adds a fix-round section to `result.md` instead of overwriting it. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps.

Do not paste the plan. The agent reads it; a paraphrase is how a step quietly changes meaning.

### What you require back

**`plan/{slug}/result.md`**, written by the developer, containing:

- stages of development, in order, each `done` or `blocked` with `file:line`;
- what was blocked and exactly what would unblock it;
- unplanned changes, each with the step that mechanically forced it;
- tests added or changed, and the coverage number for the touched code;
- gate output: build, tests, lint, each with the exact command;
- the `glab:security` skill's blast-radius block: what behaviour or format changed, who calls it, what existing data it can affect, and how to roll it back;
- follow-ups deferred, and why each was out of scope.

**Test rules, stated in every dispatch:**

- **No hand-written mocks or stub structs.** Mocks are generated by the repo's own generator and its checked-in directives. A test that defines its own fake implementation of a repo interface is rejected.
- **Any struct exposing behaviour outside its package gets an interface plus the generator directive**, following the repo's existing pattern.
- **Coverage of the touched code ≥95%, 100% preferred.** Measure the changed code, not the whole legacy package. Every uncovered branch is named in `result.md` with why it is structurally unreachable.

**Chat discipline:** the developer returns its verdict line and a pointer to `result.md`. Nothing else. Say this in the dispatch.

### Verify before moving on

An agent's report is not evidence. Run the gates yourself, in order — build, then tests, then lint — and do not run a later one while an earlier one is red. **Never run a fix-mode linter or formatter** (`--fix`, `--write`, `-w`): rewriting linters produce code that does not compile and changes are then indistinguishable from the agent's. Fix findings by hand.
~~~
~~~ M15 new
Run `/glab:develop {slug}`. Split it as *Running agents in parallel* says.

Give each `glab:developer` dispatch (Rule 0c):

- the slug and the exact step ids it owns, its file boundary when the work is split, and with sub-plans the paths *The master plan and sub-plans* names;
- **the resolved answers** from `questions.md` and anything decided in this conversation that is not written in the plan — the agent cannot see this chat;
- **your own suggestions**, marked as suggestions, so they are not mistaken for plan steps;
- **for a fix round** — after `DIVERGES`, review findings or integration regressions: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps.

Do not paste the plan. The agent reads it; a paraphrase is how a step quietly changes meaning.

### What you require back

`plan/{slug}/result.md` and the short reply, as `glab:developer` Step 5 and *Report* have them, checked as Rule 5 says.

### Verify before moving on

An agent's report is not evidence. Run the gate line you recorded (*Know the gates before you dispatch*) yourself, in order — build, then tests, then lint — and do not run a later one while an earlier one is red; `glab:security` Rules 3 to 5 hold. Where the repo separates a changed-code gate from a whole-tree sweep, the gate is what must pass: a sweep's pre-existing backlog is a burn-down list for its own task, never pass/fail on this one.

- `PLAN WRONG` → stop the build. Amending the plan is a Rule 3 decision — yours when it is an engineering choice, the user's when it meets an ask-condition — made through a new planning agent and recorded under `## Decisions`, never made by the developer; then this stage again.
- `BLOCKED: <reason>` → decide whether it is unblockable: a missing decision is yours under Rule 3 unless it meets an ask-condition; a dependency on another slice means the split was wrong — re-dispatch rather than patch it yourself.
- `BUILT` and every gate green → the next stage: Stage 3 at full tier and for every sub-plan, Stage 4 at normal tier with no sub-plans.

If you find yourself fixing an agent's work beyond a mechanical consequence, you have taken over the implementation (Rule 1), and the split stopped meaning anything.
~~~

### M17 — Stage 4's body (B8, B9, B29) — `:443-448`

~~~ M17 old plugins/glab/skills/manager/SKILL.md
Run `/glab:integrate {slug}`. The `glab:integrator` agent checks or starts the external dependencies (database, queue, cache), starts the service, and runs the repo's existing integration or E2E suite.

- At normal tier it runs the test that proves the plan's milestone; the whole suite is for full tier.
- If it cannot find an E2E suite, it asks — it does not invent one. When the user names the path, **write it to memory** so no later session asks again.
- **Never against a live or production endpoint.** Local only.
- Skip this stage only when the change cannot be exercised at runtime (documentation, plan files, a pure refactor with no behavioural change). Say you are skipping it and why; do not silently pass it.
~~~
~~~ M17 new
Run `/glab:integrate {slug}`. The `glab:integrator` agent checks or starts the external dependencies, starts the service and runs the repo's existing integration or E2E suite — at normal tier only the milestone test, as its Step 1 says. You start no service and run no suite yourself.

- **Skip this stage only when the change cannot be exercised at runtime** (documentation, plan files, a pure refactor with no behavioural change). Say you are skipping it and why; do not silently pass it.
- `INTEGRATED` → Stage 5. `FAILED: <n> regressions` → Stage 2 as a fix round, with only the failing behaviour in scope.
- `BLOCKED: no suite` → ask the user where the suite lives — the agent does not invent one. When the user names the path, **write it to memory** so no later session asks again. Any other `BLOCKED: <reason>` → do what would unblock it, under Rule 3, or bring it to the user.
~~~

### M18 — Stage 5 drops the template paste and the model paragraph (A29, B19, B23)

The last sentence of `:454` goes; the rest of `:454`, the round-2 contents, stays (B19):

~~~ M18.1 old plugins/glab/skills/manager/SKILL.md
 The report template Rule 5 has you paste is allowed in this dispatch and is not content: it describes the form of the answer, not the change.
~~~
~~~ M18.1 new
~~~

The paragraph `:456` and the blank line after it go:

~~~ M18.2 delete plugins/glab/skills/manager/SKILL.md
Dispatch it on the model Rule 5 gives the reviewer: the one the user named, as the Agent tool's `model` parameter, or none — the definition's `sonnet` — at the effort Rule 0d gives. A reviewer on another model does not change this stage's round cap or what its verdict means.

~~~

### M19 — Stage 6: a deliberate commit on `main` (B14)

~~~ M19 old plugins/glab/skills/manager/SKILL.md
Verify the file list from `git show --stat` matches what you expected.
~~~
~~~ M19 new
Verify the file list from `git show --stat` matches what you expected. A commit on `main` — allowed by the user's words or the repo's `AGENTS.md` — is said in the dispatch to be deliberate, or `glab:committer` stops.
~~~

### M20 — Stage 6b's tiers (A21)

~~~ M20 old plugins/glab/skills/manager/SKILL.md
After the slug's last commit, before the push, at every tier:
~~~
~~~ M20 new
After the slug's last commit, before the push, at normal and full tier:
~~~

### M21 — Stage 7 points at the push skill's own step (A23)

~~~ M21 old plugins/glab/skills/manager/SKILL.md
`/glab:push` shows exactly which commits will go out and waits for the user's go-ahead. Show the `## Decisions` lines of each plan the push carries — at normal tier this is where the user reads what you decided.
~~~
~~~ M21 new
`/glab:push` shows what will go out — the `## Decisions` lines of each plan it carries included — and waits for the user's go-ahead.
~~~

### M23 — *What you never do* points at `glab:security` Rule 5 (C11)

~~~ M23 old plugins/glab/skills/manager/SKILL.md
- Run a fix-mode linter, or treat a whole-tree backlog sweep as a gate.
~~~
~~~ M23 new
- Run a fix-mode linter (`glab:security` Rule 5), or treat a whole-tree backlog sweep as a gate.
~~~

### M24 — Rule 3: how a planner's decision is overruled (A26)

~~~ M24 old plugins/glab/skills/manager/SKILL.md
A recommendation sent to the user for confirmation is a decision you made and did not write down.
~~~
~~~ M24 new
A recommendation sent to the user for confirmation is a decision you made and did not write down. A planner's `## Decisions` line is reviewed the same way: overrule one by adding a new line with your reason, never by editing the planner's.
~~~

### M25 — the remaining `glab:plan-first` references become `glab:plan` (decision *glab:plan*)

Last in this file. It renames `:228`, `:298`, `:301` and `:486`, the four left after M3, M13 and M14:

~~~ M25 run
sed -i 's/plan-first/plan/g' plugins/glab/skills/manager/SKILL.md
~~~

## Posts

~~~ posts
M0.1 | 1 | /usr/bin/grep -c -F 'using its stage skills and subagents' plugins/glab/skills/manager/SKILL.md
M0.2 | 1 | /usr/bin/grep -c -F 'runs through a `/glab:` stage skill or directly' plugins/glab/skills/manager/SKILL.md
M0.3 | 1 | /usr/bin/grep -c -F 'invoke it yourself through the Skill tool' plugins/glab/skills/manager/SKILL.md
M0.4 | 1 | /usr/bin/grep -c -F 'Stage skills take `{slug}/<nn>-<name>` for a slug' plugins/glab/skills/manager/SKILL.md
M0.5 | 1 | /usr/bin/grep -c -F '| 1 | Plan | `glab:planner` on the task |' plugins/glab/skills/manager/SKILL.md
M0.6 | 1 | /usr/bin/grep -c -F 'no stage skill sits in between' plugins/glab/skills/manager/SKILL.md
M1 | 1 | /usr/bin/grep -c -F 'This rule is that step, named here because it is the one that cannot be skipped.' plugins/glab/skills/manager/SKILL.md
M2 | 0 | /usr/bin/grep -c -F 'Three places it changes what you do here' plugins/glab/skills/manager/SKILL.md
M3 | 1 | /usr/bin/grep -c -x -F '## Rule 0c — what reaches an agent, and once' plugins/glab/skills/manager/SKILL.md
M3 | 0 | /usr/bin/grep -c -F 'Mind the seam' plugins/glab/skills/manager/SKILL.md
M5 | 1 | /usr/bin/grep -c -F '`glab:security` has no such exemption: a five-line change' plugins/glab/skills/manager/SKILL.md
M6 | 1 | /usr/bin/grep -c -F "as its own file's *Report* says." plugins/glab/skills/manager/SKILL.md
M7.1 | 1 | /usr/bin/grep -c -F -- '- **Precedence.**' plugins/glab/skills/manager/SKILL.md
M7.1 | 0 | /usr/bin/grep -c -E 'v2\.1\.(251|257|211)' plugins/glab/skills/manager/SKILL.md
M7.2 | 0 | /usr/bin/grep -c -F 'it warns when it substitutes' plugins/glab/skills/manager/SKILL.md
M7.3 | 0 | /usr/bin/grep -c -F 'shows the model a running subagent is on' plugins/glab/skills/manager/SKILL.md
M7.4 | 1 | /usr/bin/grep -c -F 'the reviewer still gets only what Stage 5 gives it' plugins/glab/skills/manager/SKILL.md
M7.5 | 0 | /usr/bin/grep -c -F 'copied as written and never paraphrased' plugins/glab/skills/manager/SKILL.md
M7.5 | 1 | /usr/bin/grep -c -F 'is its template; it is not pasted into the dispatch' plugins/glab/skills/manager/SKILL.md
M7.6 | 1 | /usr/bin/grep -c -F 'the model holds on a resume (see *Precedence*)' plugins/glab/skills/manager/SKILL.md
M8 | 1 | /usr/bin/grep -c -F 'Reuse that line all session.' plugins/glab/skills/manager/SKILL.md
M9 | 1 | /usr/bin/grep -c -F '`evidence.md` at full tier, and `questions.md`' plugins/glab/skills/manager/SKILL.md
M11 | 0 | /usr/bin/grep -c -F 'the manager has a planning agent keep' plugins/glab/skills/manager/SKILL.md
M12 | 1 | /usr/bin/grep -c -F 'Sequential agents — one per group of steps' plugins/glab/skills/manager/SKILL.md
M13.1 | 1 | /usr/bin/grep -c -F 'proven kept apart from inferred (`glab:security` Rule 6)' plugins/glab/skills/manager/SKILL.md
M13.2 | 1 | /usr/bin/grep -c -F 'sorted as `glab:plan` Step 2 says' plugins/glab/skills/manager/SKILL.md
M13.3 | 0 | /usr/bin/grep -c -F 'Three phases, explicitly' plugins/glab/skills/manager/SKILL.md
M14.1 | 0 | /usr/bin/grep -c -F 'never said how the subject reached them' plugins/glab/skills/manager/SKILL.md
M14.1 | 0 | /usr/bin/grep -c -F '120 call sites' plugins/glab/skills/manager/SKILL.md
M14.1 | 0 | /usr/bin/grep -c -F 'found **six** defects' plugins/glab/skills/manager/SKILL.md
M14.1 | 0 | /usr/bin/grep -c -F '40 registered patterns' plugins/glab/skills/manager/SKILL.md
M14.1 | 0 | /usr/bin/grep -c -F 'same 15 lines' plugins/glab/skills/manager/SKILL.md
M14.1 | 0 | /usr/bin/grep -c -F 'An absence invariant' plugins/glab/skills/manager/SKILL.md
M14.1 | 1 | /usr/bin/grep -c -F 'is `glab:plan-analyzer` *The plan check*.' plugins/glab/skills/manager/SKILL.md
M14.2 | 0 | /usr/bin/grep -c -F 'with the seam stated' plugins/glab/skills/manager/SKILL.md
M14.3 | 0 | /usr/bin/grep -c -F 'replacing the changed text in place rather than adding beside it' plugins/glab/skills/manager/SKILL.md
M14.4 | 1 | /usr/bin/grep -c -F "after it, the planner's version copy" plugins/glab/skills/manager/SKILL.md
M15 | 0 | /usr/bin/grep -c -E 'hand-written mocks|≥95%|Chat discipline|Never run a fix-mode linter or formatter|blast-radius block' plugins/glab/skills/manager/SKILL.md
M15 | 1 | /usr/bin/grep -c -F 'Split it as *Running agents in parallel* says.' plugins/glab/skills/manager/SKILL.md
M17 | 1 | /usr/bin/grep -c -F 'at normal tier only the milestone test, as its Step 1 says' plugins/glab/skills/manager/SKILL.md
M18.1 | 0 | /usr/bin/grep -c -F 'has you paste' plugins/glab/skills/manager/SKILL.md
M18.2 | 0 | /usr/bin/grep -c -F 'Dispatch it on the model Rule 5 gives the reviewer' plugins/glab/skills/manager/SKILL.md
M19 | 1 | /usr/bin/grep -c -F 'is said in the dispatch to be deliberate, or `glab:committer` stops' plugins/glab/skills/manager/SKILL.md
M20 | 1 | /usr/bin/grep -c -F 'before the push, at normal and full tier:' plugins/glab/skills/manager/SKILL.md
M21 | 1 | /usr/bin/grep -c -F 'the `## Decisions` lines of each plan it carries included' plugins/glab/skills/manager/SKILL.md
M23 | 1 | /usr/bin/grep -c -F 'fix-mode linter (`glab:security` Rule 5)' plugins/glab/skills/manager/SKILL.md
M24 | 1 | /usr/bin/grep -c -F 'overrule one by adding a new line with your reason' plugins/glab/skills/manager/SKILL.md
M25 | 0 | /usr/bin/grep -c -F 'plan-first' plugins/glab/skills/manager/SKILL.md
~~~
