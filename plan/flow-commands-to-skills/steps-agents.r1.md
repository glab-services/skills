# flow-commands-to-skills — steps for the seven agents

Part of `plan.md` *processing*. File boundary: `plugins/glab/agents/*.md` only. Quotes are as of `5a72155`; line numbers are for orientation, the quoted text is what to find. "Replace A with B" means the quoted text A, exactly once in the file, becomes B; nothing else in the line changes unless the step says so. A recorded case named here stays word for word.

## AG0 — the preload channel (A1, B12, C2, C3, C17; decision FU1-2)

In each file, insert a `skills:` block as the line after `tools:`, two-space `- ` entries, in this order:

| file | entries |
|---|---|
| `analyzer.md` | `glab:security`, `glab:audit` |
| `committer.md` | `glab:security` |
| `developer.md` | `glab:security`, `glab:comments` |
| `integrator.md` | `glab:security`, `glab:comments` |
| `plan-analyzer.md` | `glab:security`, `glab:audit` |
| `planner.md` | `glab:plan-first`, `glab:security` |
| `reviewer.md` | `glab:security`, `glab:comments`, `glab:audit` |

`tools:` lines do not change (no `Skill` added; the planner keeps its own).

Post: the skills gate of `steps-repo.md` R2 prints exactly its fourteen expected lines and no `MISSING`; `/usr/bin/grep -c '^skills:$' plugins/glab/agents/*.md` prints `:1` for all seven; the AGENTS.md model gate and name gate are unchanged (A1).

## planner.md

- **PL1 (A1, A16).** Replace "**Load the `glab:plan-first` skill and follow its planning steps**, stopping where it says a planning agent stops. Read none of its later files: what comes after the plan is not yours." with "**Follow the preloaded `glab:plan-first`'s planning steps**, stopping where it says a planning agent stops. What comes after the plan is not yours."
  Post: `/usr/bin/grep -c 'Load the `glab:plan-first`' plugins/glab/agents/planner.md` prints `0`; `/usr/bin/grep -c 'preloaded `glab:plan-first`' …` prints `1`.

## developer.md

- **D1 (B1, B2).** Replace "No `plan.md` and no `waived.md` → stop and report `BLOCK: no contract`." with "No `plan.md` and no `waived.md` → stop and report `BLOCKED: no contract` — except for the record, whose contract is the folder (*The record*)."
  Post: `/usr/bin/grep -c 'BLOCK: no contract' plugins/glab/agents/developer.md` prints `0`; `/usr/bin/grep -c 'BLOCKED: no contract' …` prints `1`; `/usr/bin/grep -rn 'no contract' plugins` lists only that line.
- **D2 (B10).** Replace "In the temp directory the repo or host names, never `/tmp`:" with "In the temp directory the dispatch names, never `/tmp`:".
- **D3 (C18, A1).** In Step 2, replace the paragraph "This binds hardest on things that look like improvements:" and its five bullets (`:44-50`) with one paragraph: "This binds hardest on what looks like an improvement: everything `glab:security` Rule 8 lists, a bug the plan's own findings called out as pre-existing and out of scope, and errors, constants, helpers or config for machinery a later plan will build." Then replace "Before changing an existing function, grep its callers and check each one still holds. The plan's call-site audit tells you what was true when it was written, not what is true now." with "The plan's call-site audit tells you what was true when it was written: before changing an existing function, apply `glab:security` Rule 7 to the tree as it is now."
  Post: `/usr/bin/grep -c -E 'richer API|better file layout' plugins/glab/agents/developer.md` prints `0`; `/usr/bin/grep -c 'unavoidable mechanical consequence' …` prints `1` (kept).
- **D4 (C7, C11, C12, A24).** In Step 3: delete the sentence "Green means green: no failures, no data races, no package you meant to cover silently skipped." from item 2; delete the whole paragraph that begins "**Never run a fix-mode formatter or linter**"; in the sweep paragraph replace "never pass/fail on yours." with "never pass/fail on yours; a backlog is pre-existing only once `glab:security` Rule 4 proves it."; delete the paragraph "Use the repo's own targets rather than hand-rolled commands, so you run what CI runs."
  Post: `/usr/bin/grep -c -E -- '--fix|Green means green|hand-rolled' plugins/glab/agents/developer.md` prints `0`; `/usr/bin/grep -c 'Rule 4 proves it' …` prints `1`.
- **D4b (Q1).** **Q1 = A:** after item 3 of Step 3 add the paragraph "After every material change, build the affected package and run the single test closest to what you just touched — not the whole suite, which is slow enough that you will stop running it." **Q1 = B:** no change.
  Post (A): `/usr/bin/grep -c 'single test closest' plugins/glab/agents/developer.md` prints `1`. (B): prints `0`.
- **D5 (A6, B3, C4).** In the Step 5 template, between the `## Gates` block and `## Follow-ups`, insert:

      ## Claims
      <the claims table of `glab:security` *The report*: each claim, proven or inferred, and how>

      ## Blast radius
      <the blast-radius block of `glab:security` *The report*: changed, callers, data, rollback>

  and change the line under `## Not done` to "<steps outside your slice, any plan claim you could not verify, and the rest of `glab:security` *The report*'s *Not done*>".
  Post: `/usr/bin/grep -c -E '^    ## (Claims|Blast radius)$' plugins/glab/agents/developer.md` prints `2`.
- **D6 (A1).** Replace "**Never delete anything the plan did not name**, and when it does name a deletion, check `git status` first — if the file is untracked, its removal is unrecoverable, so stop and ask instead." with "**Never delete anything the plan did not name.** A deletion it names follows `glab:security` *Destructive operations are proven*."
  Post: `/usr/bin/grep -c 'Destructive operations are proven' plugins/glab/agents/developer.md` prints `1`.
- Kept as they are: Step 4's test rules (A14, owner), *A fix round* (B27, agent side), *Report* and its verdicts (B4), the 500k incident (`:28`).

## analyzer.md

- **AN1 (B1).** Replace "No `plan.md` → stop and report `BLOCK: target unresolved` — except in a final check (below), whose contract is `master.md` and `index.md`; with no `master.md` there either, `BLOCK`." with "No `plan.md` → stop and report `BLOCK: target unresolved` — except in a final check (below), whose contract is `master.md` and `index.md`, with no `master.md` there either `BLOCK`; and except in the record check (below), whose contract is the folder."
  Post: `/usr/bin/grep -c 'except in the record check' plugins/glab/agents/analyzer.md` prints `1`.
- **AN2 (A20, B11).** In *Report*, replace "step <n>: <done | partial | missing | changed>" with "step <n>: <done | unverified | partial | missing | changed>".
  Post: `/usr/bin/grep -c 'done | unverified | partial' plugins/glab/agents/analyzer.md` prints `1`.
- **AN3 (A13, C17).** Replace the paragraph beginning "Rate each gap by what it costs if the tree ships as it stands" (`:97`) with "Rate each gap by what it costs if the tree ships as it stands, on `glab:audit` *Severity Levels* — the one part of the preloaded `glab:audit` you use: you write no audit document."
  Post: `/usr/bin/grep -c -E 'unbounded memory|round 3' plugins/glab/agents/analyzer.md` prints `0`.
- Kept: Step 4's `make lint` / 85 mockgen case (B31, the one copy), the lane (B28).

## plan-analyzer.md

- **PA1 (A2).** Replace the body of *The plan check — `glab:manager` Stage 1b* with the Stage 1b text that `steps-manager.md` M14 cuts from `glab:manager`, taken from `git show HEAD:plugins/glab/skills/manager/SKILL.md` so the order of PA1 and M14 does not matter — in this order and otherwise verbatim:
  1. "There is no implementation yet. One question: *can this be built exactly as written?* Answered by reading the code the plan names — never by judging the prose."
  2. manager `:327-332` ("It exists because of a real case. …`[BLOCKED]`."), with "It exists" → "The check exists".
  3. "For your assigned surface:" then manager `:340-350` (the four bullets), with "This is the check that was missing above" → "This is the check that was missing in that case".
  4. manager `:352-371` (the post-condition question, the 40-of-45 case, the two corollaries).
  5. "Ask the intent question too (*The intent question*): for a single plan, of `master.md` and `plan.md` together. A master check — the plan check of a folder split into sub-plans, before any is planned — reads `master.md` and `index.md` and asks the coverage question. End with `BUILDABLE`, or `NOT BUILDABLE` with each finding under its step or goal id and its severity."
  Post: each of `each call \`Apply\``, `120 call sites`, `found **six** defects`, `40 registered patterns`, `same 15 lines`, `An absence invariant` counts `1` in `plugins/glab/agents/plan-analyzer.md` and `0` in `plugins/glab/skills/manager/SKILL.md` (`/usr/bin/grep -c -F`); `/usr/bin/grep -c 'as `glab:manager` Stage 1b says' plugins/glab/agents/plan-analyzer.md` prints `0`.
- **PA2 (B16).** Replace "A step whose verification you cannot judge by reading is `unverified`, not `done`. Say so. A step with no verification criterion at all is a defect in the plan, not in the implementation." with "A step whose post-condition you cannot judge by reading the plan and the code it cites is `unverified`, not `buildable`. Say so. A step with no verification criterion at all is a finding." In *Report*, replace "step <n>: <done | unverified | partial | missing | changed>" with "step <n>: <buildable | unverified | partial | missing | changed>" and "gap:       <only when not done>" and "severity:  <only when not done: critical | high | medium | low>" with the same lines reading "not buildable".
  Post: `/usr/bin/grep -c -w 'done' plugins/glab/agents/plan-analyzer.md` prints `0`; `/usr/bin/grep -c 'buildable |' …` prints `1`.
- **PA3 (A13, C17).** Replace the paragraph beginning "Rate each gap by what it costs if the plan is built as it stands" with "Rate each gap by what it costs if the plan is built as it stands, on `glab:audit` *Severity Levels* — the one part of the preloaded `glab:audit` you use: you write no audit document."
  Post: `/usr/bin/grep -c -E 'unbounded memory|round 3' plugins/glab/agents/plan-analyzer.md` prints `0`.
- **PA4 (B31).** In Step 2, replace "— in one repo `make lint` is `lint: mock` → `go generate ./...` across 85 mockgen directives, which would write generated files into the tree you are measuring." with "— the case is recorded in `glab:analyzer` Step 4."
  Post: `/usr/bin/grep -rc '85 mockgen' plugins/glab/agents/` prints `analyzer.md:1` and `plan-analyzer.md:0` among its lines.

## reviewer.md

- **RV1 (C5, A1).** Delete the line "Load the `glab:security` and `glab:comments` skills if they are available. Either way both rules hold: calibrate severity to consequence, and never propose deleting a TODO/FIXME/HACK/NOTE/XXX comment." and the blank line after it.
- **RV2 (A1).** In Step 4 replace "Prefer the repo's own `make`/script targets over hand-rolled commands. Paste the real output. Never write \"should pass\"." with nothing (keep the sentence before it).
- **RV3 (C11, A24, B25).** Delete the paragraph that begins "**Never run a linter or formatter in fix mode**".
- **RV4 (A13, B20, C17).** Replace "The severity is one of `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. Rate by consequence. The caller does not re-rank it, and in round 2 it decides whether a round 3 runs." with "Rate each finding by its consequence on `glab:audit` *Severity Levels* — the one part of the preloaded `glab:audit` you use: you write no audit document. The caller does not re-rank it."
- **RV5 (B10).** Replace "under the temp directory the dispatch message names (the scratchpad only if it names none)" with "under the temp directory the dispatch names, never `/tmp`".
- **RV6 (A13, B7, B19).** In *Re-reviews*, replace the first paragraph ("A change gets **at most two rounds** … there is no round after it.") with "The dispatch says which round this is and which is the last. Round 2 is the last unless you report a `critical` or `high` finding in it — then answer `BLOCK: <n> issues`, and a round 3 may follow; round 3 is the last with no exception. In the last round the answer must be publish or do not publish; there is no round after it." In the second paragraph replace "The caller gives you the target, the previous round's findings as they were returned, and the range of the fix — two tree ids or two commit ids; you get no plan, no slug and no intent." with "From round 2 the dispatch adds the previous round's findings, as they were returned, and the range of the fix — two tree ids or two commit ids."
  Post (RV1–RV6): `/usr/bin/grep -c -E -- 'if they are available|--fix|hand-rolled|unbounded memory|across the whole change|scratchpad|no slug' plugins/glab/agents/reviewer.md` prints `0`; `/usr/bin/grep -c -F '?? .claude/commands/' …` prints `1` (kept, F9); the last-round verdicts `SHIP WITH SCOPE CUT` and `DO NOT PUBLISH` each count `1`.

## integrator.md

- **IN1 (B15).** In `description:` replace "after /glab:analyze at full tier or /glab:develop at normal, and before /glab:review." with "after the develop or analyze stage and before /glab:review."
- **IN2 (B8, B15).** Replace "Then `plan/<slug>/plan.md` — only far enough to know **what behaviour must be exercised**. You are not checking conformance; that was the analyzer's pass." with "Then `plan/<slug>/plan.md` — only its tier line and far enough to know **what behaviour must be exercised**; you are not checking conformance. At normal tier run the test that proves the plan's milestone; the whole suite is for full tier, and a plan with no tier line is full tier."
- **IN3 (A1).** Replace "A vendored third-party conformance suite counts. A failing case in one is a prompt to read the vendor specification, not a bug report to fix against — and a passing one proves nothing about behaviour it does not exercise." with "A vendored third-party conformance suite counts; read its results as `glab:security` *Never infer a rule by mirroring a neighbour* says."
- **IN4 (A1).** Replace "Run the suite. Paste the real output — counts, failures, the first failure's message. Never write \"should pass\" and never summarise a result you did not see." with "Run the suite. Paste the counts, the failures and the first failure's message."
- **IN5 (B10).** Replace "redirect its log to the temp directory the dispatch message names (the scratchpad only if it names none)" with "redirect its log to the temp directory the dispatch names, never `/tmp`".
- **IN6 (C7, A1).** Replace "**pre-existing** — prove it by checking out the merge base or citing a prior run. An unproven \"pre-existing\" is a guess." with "**pre-existing** — proven as `glab:security` Rule 4 says: the same command on the merge-base tree, its output pasted." In *Never*, delete the sentence "Print a credential, a token or a remote URL."
  Post (IN1–IN6): `/usr/bin/grep -c -E "analyzer's pass|at full tier or|should pass|scratchpad|citing a prior run|Print a credential" plugins/glab/agents/integrator.md` prints `0`; `/usr/bin/grep -c 'milestone' …` prints `1` (Step 1).

## committer.md

- **CM1 (B14).** Replace "If the working tree is on `main`, stop and say so before committing. Branch first is the caller's decision." with "If the working tree is on `main`, stop and say so before committing, unless the dispatch says the commit on `main` is deliberate. Branch first is the caller's decision."
  Post: `/usr/bin/grep -c 'commit on `main` is deliberate' plugins/glab/agents/committer.md` prints `1`.

## After all agent steps

`/usr/bin/grep -c -F 'Severity Levels*: `critical`' plugins/glab/agents/*.md` prints `:0` for all seven (before: `1` in analyzer, plan-analyzer and reviewer) (the meanings live in `glab:audit` only); `/usr/bin/grep -c -E 'critical \| high \| medium \| low' plugins/glab/agents/{analyzer,plan-analyzer,reviewer}.md` prints `1` each (the level names stay in each *Report*).
