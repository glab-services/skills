# flow-commands-to-skills — steps for the seven agents

Part of `plan.md` *processing*, run after P1. File boundary: `plugins/glab/agents/*.md` only. Old texts are as of `5a72155`. The blocks follow `plan.md` *Block formats*; each edit's check is its line in the posts block at the end of this file. A recorded case named here stays word for word.

## AG0 — the preload channel (A1, B12, C2, C3, C17; decision FU1-2)

In each file, a `skills:` list goes on the line after `tools:`, two-space `- ` entries, in the order shown. `tools:` lines do not change: no `Skill` is added, and the planner keeps its own.

~~~ AG0.1 old plugins/glab/agents/analyzer.md
tools: Read, Grep, Glob, Bash
~~~
~~~ AG0.1 new
tools: Read, Grep, Glob, Bash
skills:
  - glab:security
  - glab:audit
~~~

~~~ AG0.2 old plugins/glab/agents/committer.md
tools: Read, Grep, Glob, Bash
~~~
~~~ AG0.2 new
tools: Read, Grep, Glob, Bash
skills:
  - glab:security
~~~

~~~ AG0.3 old plugins/glab/agents/developer.md
tools: Read, Write, Edit, Grep, Glob, Bash
~~~
~~~ AG0.3 new
tools: Read, Write, Edit, Grep, Glob, Bash
skills:
  - glab:security
  - glab:comments
~~~

~~~ AG0.4 old plugins/glab/agents/integrator.md
tools: Read, Write, Grep, Glob, Bash
~~~
~~~ AG0.4 new
tools: Read, Write, Grep, Glob, Bash
skills:
  - glab:security
  - glab:comments
~~~

~~~ AG0.5 old plugins/glab/agents/plan-analyzer.md
tools: Read, Grep, Glob, Bash
~~~
~~~ AG0.5 new
tools: Read, Grep, Glob, Bash
skills:
  - glab:security
  - glab:audit
~~~

~~~ AG0.6 old plugins/glab/agents/planner.md
tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch
~~~
~~~ AG0.6 new
tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch
skills:
  - glab:plan
  - glab:security
~~~

~~~ AG0.7 old plugins/glab/agents/reviewer.md
tools: Read, Grep, Glob, Bash
~~~
~~~ AG0.7 new
tools: Read, Grep, Glob, Bash
skills:
  - glab:security
  - glab:comments
  - glab:audit
~~~

## planner.md

### PL0 — the description names the merged skill and the stage that dispatches it (A16; decision *glab:plan*)

~~~ PL0 old plugins/glab/agents/planner.md
description: Plans one task in its folder under plan/ by the glab:plan-first skill, and stops where that skill says planning ends. Never writes code, never edits outside the plan folder its dispatch names, never stages or commits. Use from /glab:plan, for a sub-plan's planning, and for every amendment.
~~~
~~~ PL0 new
description: Plans one task in its folder under plan/ by the glab:plan skill, and stops where that skill says planning ends. Never writes code, never edits outside the plan folder its dispatch names, never stages or commits. Use from glab:manager Stage 1, for a sub-plan's planning, and for every amendment.
~~~

### PL1 — the planner follows the preloaded skill (A1, A16)

~~~ PL1 old plugins/glab/agents/planner.md
- **Load the `glab:plan-first` skill and follow its planning steps**, stopping where it says a planning agent stops. Read none of its later files: what comes after the plan is not yours.
~~~
~~~ PL1 new
- **Follow the preloaded `glab:plan`, Steps 0 to 4**, stopping where it says a planning agent stops. What comes after the plan is not yours.
~~~

### PL2 — the four other references are renamed

~~~ PL2 run
sed -i 's/plan-first/plan/g' plugins/glab/agents/planner.md
~~~

## developer.md

### D1 — the record's exception, and the verdict word of *Report* (B1, B2)

~~~ D1 old plugins/glab/agents/developer.md
No `plan.md` and no `waived.md` → stop and report `BLOCK: no contract`.
~~~
~~~ D1 new
No `plan.md` and no `waived.md` → stop and report `BLOCKED: no contract` — except for the record, whose contract is the folder (*The record*).
~~~

### D2 — the temp directory comes from the dispatch (B10)

~~~ D2 old plugins/glab/agents/developer.md
In the temp directory the repo or host names, never `/tmp`:
~~~
~~~ D2 new
In the temp directory the dispatch names, never `/tmp`:
~~~

### D3 — Step 2 points at `glab:security` instead of restating it (C18, A1)

D3.1 replaces the paragraph and its five bullets; D3.2 the call-site paragraph.

~~~ D3.1 old plugins/glab/agents/developer.md
This binds hardest on things that look like improvements:

- a bug you spotted in passing — including one the findings themselves called out as pre-existing and out of scope;
- a better file layout than the plan's. If the plan says two files, write two files;
- a richer API than the step described. "Move it as-is" means as-is: no new exported type, no new option, no extra result field;
- errors, constants, helpers or config for machinery a later plan will build;
- renames, import regrouping, formatting sweeps, blank lines left where deleted code was.
~~~
~~~ D3.1 new
This binds hardest on what looks like an improvement: everything `glab:security` Rule 8 lists, a bug the plan's own findings called out as pre-existing and out of scope, and errors, constants, helpers or config for machinery a later plan will build.
~~~

~~~ D3.2 old plugins/glab/agents/developer.md
Before changing an existing function, grep its callers and check each one still holds. The plan's call-site audit tells you what was true when it was written, not what is true now.
~~~
~~~ D3.2 new
The plan's call-site audit tells you what was true when it was written: before changing an existing function, apply `glab:security` Rule 7 to the tree as it is now.
~~~

### D4 — Step 3 drops what `glab:security` Rules 3 to 5 hold (C7, C11, C12, A24)

~~~ D4.1 old plugins/glab/agents/developer.md
2. **Unit tests** — its test target. Green means green: no failures, no data races, no package you meant to cover silently skipped.
~~~
~~~ D4.1 new
2. **Unit tests** — its test target.
~~~

The fix-mode paragraph and the blank line after it go:

~~~ D4.2 delete plugins/glab/agents/developer.md
**Never run a fix-mode formatter or linter** — `--fix`, `--write`, `-w`, or a target that wraps one. Auto-fixers rewrite the whole tree rather than your diff, they routinely produce code that does not compile (a call added without its import, an import left behind when its last use goes), and they are often not idempotent, so one pass is not a fixed point. Check whether the repo's lint target carries a fix flag before running it; if it does, run the underlying tool without it. Fix findings by hand and understand each one — that is the point of the gate.

~~~

~~~ D4.3 old plugins/glab/agents/developer.md
never pass/fail on yours.
~~~
~~~ D4.3 new
never pass/fail on yours; a backlog is pre-existing only once `glab:security` Rule 4 proves it.
~~~

The hand-rolled paragraph and the blank line before it go:

~~~ D4.4 delete plugins/glab/agents/developer.md

Use the repo's own targets rather than hand-rolled commands, so you run what CI runs.
~~~

### D4b — the one rule of `implement.md` the developer lacked (Q1 = A)

~~~ D4b old plugins/glab/agents/developer.md
3. **Lint** — its lint target, and it must be clean. A format check may cover documentation as well as code.
~~~
~~~ D4b new
3. **Lint** — its lint target, and it must be clean. A format check may cover documentation as well as code.

After every material change, build the affected package and run the single test closest to what you just touched — not the whole suite, which is slow enough that you will stop running it.
~~~

### D5 — `result.md` carries the claims and the blast radius of `glab:security` *The report* (A6, B3, C4)

The two sections go between `## Gates` and `## Follow-ups`, at the template's 4-space indent:

~~~ D5.1 old plugins/glab/agents/developer.md
    <the exact command and outcome for build, tests and lint>
~~~
~~~ D5.1 new
    <the exact command and outcome for build, tests and lint>

    ## Claims
    <the claims table of `glab:security` *The report*: each claim, proven or inferred, and how>

    ## Blast radius
    <the blast-radius block of `glab:security` *The report*: changed, callers, data, rollback>
~~~

~~~ D5.2 old plugins/glab/agents/developer.md
    <steps outside your slice, and any plan claim you could not verify>
~~~
~~~ D5.2 new
    <steps outside your slice, any plan claim you could not verify, and the rest of `glab:security` *The report*'s *Not done*>
~~~

### D6 — a named deletion follows `glab:security` (A1)

~~~ D6 old plugins/glab/agents/developer.md
- **Never delete anything the plan did not name**, and when it does name a deletion, check `git status` first — if the file is untracked, its removal is unrecoverable, so stop and ask instead.
~~~
~~~ D6 new
- **Never delete anything the plan did not name.** A deletion it names follows `glab:security` *Destructive operations are proven*.
~~~

### D7 — the record's rule is `glab:plan`'s

~~~ D7 old plugins/glab/agents/developer.md
as `glab:plan-first` *Plan files are working files* says
~~~
~~~ D7 new
as `glab:plan` *Plan files are working files* says
~~~

Kept as they are: Step 4's test rules (A14, owner), *A fix round* (B27, agent side), *Report* and its verdicts (B4), the 500k incident (`:28`).

## analyzer.md

### AN1 — the record check's contract (B1)

~~~ AN1 old plugins/glab/agents/analyzer.md
No `plan.md` → stop and report `BLOCK: target unresolved` — except in a final check (below), whose contract is `master.md` and `index.md`; with no `master.md` there either, `BLOCK`.
~~~
~~~ AN1 new
No `plan.md` → stop and report `BLOCK: target unresolved` — except in a final check (below), whose contract is `master.md` and `index.md`, with no `master.md` there either `BLOCK`; and except in the record check (below), whose contract is the folder.
~~~

### AN2 — the `unverified` status (A20, B11)

~~~ AN2 old plugins/glab/agents/analyzer.md
    step <n>: <done | partial | missing | changed>
~~~
~~~ AN2 new
    step <n>: <done | unverified | partial | missing | changed>
~~~

### AN3 — severity by pointer (A13, C17)

~~~ AN3 old plugins/glab/agents/analyzer.md
Rate each gap by what it costs if the tree ships as it stands, on `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. In round 2 it decides whether a round 3 runs.
~~~
~~~ AN3 new
Rate each gap by what it costs if the tree ships as it stands, on `glab:audit` *Severity Levels* — the one part of the preloaded `glab:audit` you use: you write no audit document.
~~~

Kept: Step 4's `make lint` / 85 mockgen case (B31, the one copy), the lane (B28).

## plan-analyzer.md

### PA1 — the plan check moves here from `glab:manager` Stage 1b (A2)

The new body is the Stage 1b text that `steps-manager.md` M14.1 cuts, with "It exists" → "The check exists" and "missing above" → "missing in that case"; the recorded cases are word for word.

~~~ PA1 old plugins/glab/agents/plan-analyzer.md
There is no implementation yet: check each step against the code it cites as `glab:manager` Stage 1b says — its mechanism, its constraints side by side, whether its post-condition tells a finished tree from a half-finished one — and ask the intent question. A master check — the plan check of a folder split into sub-plans, before any is planned — reads `master.md` and `index.md` and asks the coverage question. End with `BUILDABLE`, or `NOT BUILDABLE` with each finding under its step or goal id and its severity.
~~~
~~~ PA1 new
There is no implementation yet. One question: *can this be built exactly as written?* Answered by reading the code the plan names — never by judging the prose.

The check exists because of a real case. A plan step said two methods would "each call
`Apply`" and never said how the subject reached them — no channel existed, on
either transport, and one of the two carried no identity at all. A developer
agent spent a full run establishing that and wrote no code. Read-only analyzers
would have found it for a fraction of the cost, and the plan's own heading
already carried `[BLOCKED]`.

For your assigned surface:

- **Resolve every `file:line` the plan cites.** A drifted line number is noise. A
  cited function whose signature cannot do what the plan asks is a blocker.
- **Name the mechanism behind each step and confirm it exists.** "X calls Y" is
  buildable only if X can obtain Y's arguments. This is the check that was
  missing in that case, and the one that pays for the stage.
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

Ask the intent question too (*The intent question*): for a single plan, of `master.md` and `plan.md` together. A master check — the plan check of a folder split into sub-plans, before any is planned — reads `master.md` and `index.md` and asks the coverage question. End with `BUILDABLE`, or `NOT BUILDABLE` with each finding under its step or goal id and its severity.
~~~

### PA2 — the step status `buildable` (B16)

~~~ PA2.1 old plugins/glab/agents/plan-analyzer.md
A step whose verification you cannot judge by reading is `unverified`, not `done`. Say so. A step with no verification criterion at all is a defect in the plan, not in the implementation.
~~~
~~~ PA2.1 new
A step whose post-condition you cannot judge by reading the plan and the code it cites is `unverified`, not `buildable`. Say so. A step with no verification criterion at all is a finding.
~~~

~~~ PA2.2 old plugins/glab/agents/plan-analyzer.md
    step <n>: <done | unverified | partial | missing | changed>
~~~
~~~ PA2.2 new
    step <n>: <buildable | unverified | partial | missing | changed>
~~~

~~~ PA2.3 old plugins/glab/agents/plan-analyzer.md
    gap:       <only when not done>
    severity:  <only when not done: critical | high | medium | low>
~~~
~~~ PA2.3 new
    gap:       <only when not buildable>
    severity:  <only when not buildable: critical | high | medium | low>
~~~

### PA3 — severity by pointer (A13, C17)

~~~ PA3 old plugins/glab/agents/plan-analyzer.md
Rate each gap by what it costs if the plan is built as it stands, on `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. In round 2 it decides whether a round 3 runs.
~~~
~~~ PA3 new
Rate each gap by what it costs if the plan is built as it stands, on `glab:audit` *Severity Levels* — the one part of the preloaded `glab:audit` you use: you write no audit document.
~~~

### PA4 — the mockgen case is kept once, in `glab:analyzer` (B31)

~~~ PA4 old plugins/glab/agents/plan-analyzer.md
 — in one repo `make lint` is `lint: mock` → `go generate ./...` across 85 mockgen directives, which would write generated files into the tree you are measuring.
~~~
~~~ PA4 new
 — the case is recorded in `glab:analyzer` Step 4.
~~~

### PA5 — the amendment rule is `glab:plan`'s

~~~ PA5 old plugins/glab/agents/plan-analyzer.md
rather than replacing it in place (`glab:plan-first` Step 4)
~~~
~~~ PA5 new
rather than replacing it in place (`glab:plan` Step 4)
~~~

## reviewer.md

### RV1 — the conditional load goes: the reviewer preloads both (C5, A1)

~~~ RV1 delete plugins/glab/agents/reviewer.md
Load the `glab:security` and `glab:comments` skills if they are available. Either way both rules hold: calibrate severity to consequence, and never propose deleting a TODO/FIXME/HACK/NOTE/XXX comment.

~~~

### RV2 — the targets sentence is `glab:security` Rule 3 (A1)

~~~ RV2 old plugins/glab/agents/reviewer.md
 Prefer the repo's own `make`/script targets over hand-rolled commands. Paste the real output. Never write "should pass".
~~~
~~~ RV2 new
~~~

### RV3 — the fix-mode paragraph is `glab:security` Rule 5 (C11, A24, B25)

The paragraph and the blank line after it go:

~~~ RV3 delete plugins/glab/agents/reviewer.md
**Never run a linter or formatter in fix mode** — `--fix`, `--write`, `-w`, or a `make` target that wraps one. You are read-only, and auto-fixers rewrite files across the whole tree, not just the diff you were asked about. Check whether the repo's lint target carries a fix flag before running it; if it does, run the underlying tool without that flag instead.

~~~

### RV4 — severity by pointer (A13, B20, C17)

~~~ RV4 old plugins/glab/agents/reviewer.md
The severity is one of `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. Rate by consequence. The caller does not re-rank it, and in round 2 it decides whether a round 3 runs.
~~~
~~~ RV4 new
Rate each finding by its consequence on `glab:audit` *Severity Levels* — the one part of the preloaded `glab:audit` you use: you write no audit document. The caller does not re-rank it.
~~~

### RV5 — the temp directory comes from the dispatch (B10)

~~~ RV5 old plugins/glab/agents/reviewer.md
under the temp directory the dispatch message names (the scratchpad only if it names none)
~~~
~~~ RV5 new
under the temp directory the dispatch names, never `/tmp`
~~~

### RV6 — *Re-reviews*: the reviewer's own round rule, and what a round after the first is given (A13, B7, B19)

~~~ RV6.1 old plugins/glab/agents/reviewer.md
A change gets **at most two rounds**, and a third only when round 2 reports a `critical` or `high` finding — at every tier, counted across the whole change rather than per file. The caller tells you which round this is and which is the last. Round 2 is the last unless you report a `critical` or `high` finding in it: then answer `BLOCK: <n> issues`, and the caller may run round 3. Round 3 is the last with no exception. In the last round the answer must be publish or do not publish; there is no round after it.
~~~
~~~ RV6.1 new
The dispatch says which round this is and which is the last. Round 2 is the last unless you report a `critical` or `high` finding in it — then answer `BLOCK: <n> issues`, and a round 3 may follow; round 3 is the last with no exception. In the last round the answer must be publish or do not publish; there is no round after it.
~~~

~~~ RV6.2 old plugins/glab/agents/reviewer.md
The caller gives you the target, the previous round's findings as they were returned, and the range of the fix — two tree ids or two commit ids; you get no plan, no slug and no intent.
~~~
~~~ RV6.2 new
From round 2 the dispatch adds the previous round's findings, as they were returned, and the range of the fix — two tree ids or two commit ids.
~~~

## integrator.md

### IN1 — the description names the stages, not the commands' tiers (B15)

~~~ IN1 old plugins/glab/agents/integrator.md
after /glab:analyze at full tier or /glab:develop at normal, and before /glab:review.
~~~
~~~ IN1 new
after the develop or analyze stage and before /glab:review.
~~~

### IN2 — the tier decides what runs (B8, B15)

~~~ IN2 old plugins/glab/agents/integrator.md
Then `plan/<slug>/plan.md` — only far enough to know **what behaviour must be exercised**. You are not checking conformance; that was the analyzer's pass.
~~~
~~~ IN2 new
Then `plan/<slug>/plan.md` — only its tier line and far enough to know **what behaviour must be exercised**; you are not checking conformance. At normal tier run the test that proves the plan's milestone; the whole suite is for full tier, and a plan with no tier line is full tier.
~~~

### IN3 — vendored suites by pointer (A1)

~~~ IN3 old plugins/glab/agents/integrator.md
A vendored third-party conformance suite counts. A failing case in one is a prompt to read the vendor specification, not a bug report to fix against — and a passing one proves nothing about behaviour it does not exercise.
~~~
~~~ IN3 new
A vendored third-party conformance suite counts; read its results as `glab:security` *Never infer a rule by mirroring a neighbour* says.
~~~

### IN4 — the paste rule is `glab:security` Rule 2 (A1)

~~~ IN4 old plugins/glab/agents/integrator.md
Run the suite. Paste the real output — counts, failures, the first failure's message. Never write "should pass" and never summarise a result you did not see.
~~~
~~~ IN4 new
Run the suite. Paste the counts, the failures and the first failure's message.
~~~

### IN5 — the temp directory comes from the dispatch (B10)

~~~ IN5 old plugins/glab/agents/integrator.md
redirect its log to the temp directory the dispatch message names (the scratchpad only if it names none)
~~~
~~~ IN5 new
redirect its log to the temp directory the dispatch names, never `/tmp`
~~~

### IN6 — pre-existing by `glab:security` Rule 4, and the secrets sentence goes (C7, A1)

~~~ IN6.1 old plugins/glab/agents/integrator.md
**pre-existing** — prove it by checking out the merge base or citing a prior run. An unproven "pre-existing" is a guess.
~~~
~~~ IN6.1 new
**pre-existing** — proven as `glab:security` Rule 4 says: the same command on the merge-base tree, its output pasted.
~~~

~~~ IN6.2 old plugins/glab/agents/integrator.md
 Print a credential, a token or a remote URL.
~~~
~~~ IN6.2 new
~~~

## committer.md

### CM1 — a deliberate commit on `main` (B14)

~~~ CM1 old plugins/glab/agents/committer.md
If the working tree is on `main`, stop and say so before committing. Branch first is the caller's decision.
~~~
~~~ CM1 new
If the working tree is on `main`, stop and say so before committing, unless the dispatch says the commit on `main` is deliberate. Branch first is the caller's decision.
~~~

## Posts

~~~ posts
AG0.1 | glab:security,glab:audit | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/analyzer.md | paste -sd, -
AG0.2 | glab:security | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/committer.md | paste -sd, -
AG0.3 | glab:security,glab:comments | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/developer.md | paste -sd, -
AG0.4 | glab:security,glab:comments | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/integrator.md | paste -sd, -
AG0.5 | glab:security,glab:audit | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/plan-analyzer.md | paste -sd, -
AG0.6 | glab:plan,glab:security | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/planner.md | paste -sd, -
AG0.7 | glab:security,glab:comments,glab:audit | awk '/^skills:$/{s=1;next} s && /^  - /{print $2; next} {s=0}' plugins/glab/agents/reviewer.md | paste -sd, -
PL0 | 1 | /usr/bin/grep -c -F 'Use from glab:manager Stage 1, for a sub-plan' plugins/glab/agents/planner.md
PL1 | 1 | /usr/bin/grep -c -F 'Follow the preloaded `glab:plan`, Steps 0 to 4' plugins/glab/agents/planner.md
PL2 | 0 | /usr/bin/grep -c -F 'plan-first' plugins/glab/agents/planner.md
D1 | 1 | /usr/bin/grep -c -F 'BLOCKED: no contract` — except for the record' plugins/glab/agents/developer.md
D2 | 1 | /usr/bin/grep -c -F 'In the temp directory the dispatch names, never `/tmp`:' plugins/glab/agents/developer.md
D3.1 | 1 | /usr/bin/grep -c -F 'everything `glab:security` Rule 8 lists' plugins/glab/agents/developer.md
D3.2 | 1 | /usr/bin/grep -c -F 'apply `glab:security` Rule 7 to the tree as it is now' plugins/glab/agents/developer.md
D4.1 | 0 | /usr/bin/grep -c -F 'Green means green' plugins/glab/agents/developer.md
D4.2 | 0 | /usr/bin/grep -c -F 'Never run a fix-mode formatter or linter' plugins/glab/agents/developer.md
D4.3 | 1 | /usr/bin/grep -c -F 'Rule 4 proves it' plugins/glab/agents/developer.md
D4.4 | 0 | /usr/bin/grep -c -F 'hand-rolled' plugins/glab/agents/developer.md
D4b | 1 | /usr/bin/grep -c -F 'run the single test closest to what you just touched' plugins/glab/agents/developer.md
D5.1 | 2 | /usr/bin/grep -c -E '^    ## (Claims|Blast radius)$' plugins/glab/agents/developer.md
D5.2 | 1 | /usr/bin/grep -c -F "the rest of \`glab:security\` *The report*'s *Not done*" plugins/glab/agents/developer.md
D6 | 1 | /usr/bin/grep -c -F 'A deletion it names follows `glab:security` *Destructive operations are proven*.' plugins/glab/agents/developer.md
D7 | 0 | /usr/bin/grep -c -F 'plan-first' plugins/glab/agents/developer.md
AN1 | 1 | /usr/bin/grep -c -F 'except in the record check (below), whose contract is the folder' plugins/glab/agents/analyzer.md
AN2 | 1 | /usr/bin/grep -c -F 'done | unverified | partial' plugins/glab/agents/analyzer.md
AN3 | 0 | /usr/bin/grep -c -E 'unbounded memory|round 3' plugins/glab/agents/analyzer.md
PA1 | 1 | /usr/bin/grep -c -F 'never said how the subject reached them' plugins/glab/agents/plan-analyzer.md
PA1 | 1 | /usr/bin/grep -c -F '120 call sites' plugins/glab/agents/plan-analyzer.md
PA1 | 1 | /usr/bin/grep -c -F 'found **six** defects' plugins/glab/agents/plan-analyzer.md
PA1 | 1 | /usr/bin/grep -c -F '40 registered patterns' plugins/glab/agents/plan-analyzer.md
PA1 | 1 | /usr/bin/grep -c -F 'same 15 lines' plugins/glab/agents/plan-analyzer.md
PA1 | 1 | /usr/bin/grep -c -F 'An absence invariant' plugins/glab/agents/plan-analyzer.md
PA1 | 0 | /usr/bin/grep -c -F 'as `glab:manager` Stage 1b says' plugins/glab/agents/plan-analyzer.md
PA2.1 | 1 | /usr/bin/grep -c -F 'is `unverified`, not `buildable`' plugins/glab/agents/plan-analyzer.md
PA2.2 | 1 | /usr/bin/grep -c -F 'step <n>: <buildable | unverified' plugins/glab/agents/plan-analyzer.md
PA2.3 | 2 | /usr/bin/grep -c -F '<only when not buildable' plugins/glab/agents/plan-analyzer.md
PA3 | 0 | /usr/bin/grep -c -E 'unbounded memory|round 3' plugins/glab/agents/plan-analyzer.md
PA4 | 0 | /usr/bin/grep -c -F '85 mockgen' plugins/glab/agents/plan-analyzer.md
PA5 | 0 | /usr/bin/grep -c -F 'plan-first' plugins/glab/agents/plan-analyzer.md
RV1 | 0 | /usr/bin/grep -c -F 'if they are available' plugins/glab/agents/reviewer.md
RV2 | 0 | /usr/bin/grep -c -F 'hand-rolled' plugins/glab/agents/reviewer.md
RV3 | 0 | /usr/bin/grep -c -F 'Never run a linter or formatter in fix mode' plugins/glab/agents/reviewer.md
RV4 | 0 | /usr/bin/grep -c -F 'unbounded memory' plugins/glab/agents/reviewer.md
RV5 | 0 | /usr/bin/grep -c -F 'scratchpad' plugins/glab/agents/reviewer.md
RV6.1 | 0 | /usr/bin/grep -c -F 'across the whole change' plugins/glab/agents/reviewer.md
RV6.2 | 1 | /usr/bin/grep -c -F 'From round 2 the dispatch adds' plugins/glab/agents/reviewer.md
IN1 | 1 | /usr/bin/grep -c -F 'after the develop or analyze stage and before /glab:review.' plugins/glab/agents/integrator.md
IN2 | 1 | /usr/bin/grep -c -F 'At normal tier run the test that proves the plan' plugins/glab/agents/integrator.md
IN3 | 1 | /usr/bin/grep -c -F '*Never infer a rule by mirroring a neighbour*' plugins/glab/agents/integrator.md
IN4 | 0 | /usr/bin/grep -c -F 'should pass' plugins/glab/agents/integrator.md
IN5 | 0 | /usr/bin/grep -c -F 'scratchpad' plugins/glab/agents/integrator.md
IN6.1 | 1 | /usr/bin/grep -c -F 'the same command on the merge-base tree' plugins/glab/agents/integrator.md
IN6.2 | 0 | /usr/bin/grep -c -F 'Print a credential' plugins/glab/agents/integrator.md
CM1 | 1 | /usr/bin/grep -c -F 'unless the dispatch says the commit on `main` is deliberate' plugins/glab/agents/committer.md
~~~
