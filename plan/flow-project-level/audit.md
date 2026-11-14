# Audit — the project level of `glab`: what a session carries, and a slim target

- **Scope:** `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/session-rules/SKILL.md`, `plugins/glab/skills/bootstrap/SKILL.md`, the hook `plugins/glab/scripts/manager-bootstrap.sh`, the project stage skills (`plan`, `develop`, `analyze`, `integrate`, `review`, `ship`, `commit`, `push`, `product-project-plan-report`), the seven project agents; `product-manager` for comparison.
- **Type:** read-only audit for the slug `flow-project-level`.
- **Date:** 2026-11-13. **Tree:** `main` at `f6fcb14`, `glab` 0.14.0.
- **Status:** final.
- **Not read:** `plan/flow-gate-hardening/` (another planner's) and the body of `plugins/glab/scripts/plan-gate.sh` (only its header lines 5-6 came up in a search).

**The request, in the user's words:** "these skills are still let's revalidate and move to product:project:* group, also project manager skills is extremely big about 40k characters, it's a lot, let's fix this make it light weight like a product manager skill. It's simply not financially viable to use 40k lines." The user picked the names `glab:project-*`. The standing rule is "say it once".

## How the numbers were taken

| What | How | Proven or inferred |
|---|---|---|
| File sizes | `wc -c` on `main` at `f6fcb14` | proven |
| Section sizes | `LC_ALL=C awk` over the lines of each `#`, `##` or `###` section, in bytes. The section sums come to 40283 of 40284 and 22434 of 22435 bytes; the missing byte is the blank line after the frontmatter. | proven |
| Hook text | the script run with `CLAUDE_PROJECT_DIR` set to a scratch folder, then `jq -r .hookSpecificOutput.additionalContext \| wc -c`: **2425** bytes at the project level, **2394** at the product level | proven |
| Name references | `/usr/bin/grep -rcE "glab:<name>([^-a-z]\|$)"` over `plugins`, `README.md`, `AGENTS.md`, `tests`, `host.example.md`. The count is of lines, not of occurrences. | proven |
| Tokens | about bytes ÷ 3.7 for this English-plus-Markdown text | **inferred**: no tokenizer was run |
| A `Skill` call injects the whole `SKILL.md`, and a second call of the same skill injects it again | — | **UNVERIFIED**: no transcript was measured |
| A preloaded `skills:` entry puts the whole skill body into the agent's context | — | **UNVERIFIED**: taken from the plugin's own text (`session-rules` Rule 0c), not measured |
| A loaded skill survives `/compact`, or is reloaded after it (`glab:bootstrap` runs again "after a context compaction") | — | **UNVERIFIED** |

---

## 1. What a session carries

### At session start

Every session also carries the skill and agent listing: the `description:` lines of the 21 `glab` skills and 9 agents add up to **9584 bytes**, at both levels (proven by a sum over the `description:` lines). The repo's own `AGENTS.md`, `docs/constants.md` and `~/.claude/host.md` vary by repo and are not counted below; this repo's `AGENTS.md` is 27389 bytes.

| Loaded | How | Project session | Product session |
|---|---|---:|---:|
| SessionStart hook text | the hook | 2425 | 2394 |
| `glab:bootstrap` | hook point 2 | 8234 | 8234 |
| the level's manager | `bootstrap` step 2 | **40284** (`manager`) | 10897 (`product-manager`) |
| `glab:session-rules` | `bootstrap` step 2 | 22435 | 22435 |
| `glab:security` | `bootstrap` step 2 | 13243 | 13243 |
| **Total at start** | | **86621** (≈ 23k tokens, inferred) | **57203** (≈ 15k tokens, inferred) |

The project session starts 29418 bytes heavier than the product session, and all of that difference is the manager. Of the manager's 40284 bytes, **26210 (65 %) are the stage sections, Stage 1 to Stage 8** (`manager/SKILL.md:133-300`); each is acted on at one stage only. Another 3659 bytes (`:89-132`) cover parallel dispatch and hosts without subagents, which are also stage-bound or rare.

### At each stage (the manager's side)

| Stage | Skill the manager invokes | Bytes added | Notes |
|---|---|---:|---|
| 1 Plan | none: `glab:planner` is dispatched directly (`manager:135`) | 0 | 15422 more when the user types `/glab:plan` and the manager plans in the session |
| 1b Plan check | `glab:analyze` | 1963 | per round, if a second call injects again |
| 1c Report | `glab:product-project-plan-report` | 1572 | only for a plan made from a brief |
| 2 Develop | `glab:develop` | 3127 | per fix round, if a second call injects again |
| 3 Analyze | `glab:analyze` | 1963 | full tier and sub-plans only |
| 4 Integrate | `glab:integrate` | 953 | |
| 5 Review | `glab:review` | 966 | per round |
| 6 Commit | `glab:commit` | 1107 | |
| 6b Final check | `glab:analyze` | 1963 | |
| 7 Push | `glab:push` | **6989** | the largest stage skill |
| 8 Record | `glab:developer` and `glab:analyzer` directly, then `glab:commit` and `glab:push` | 1107 + 6989 | |
| (no plan) | `glab:ship` | 3000 | `ship` itself points the session at `review` and `commit` |

**One normal-tier task with a single plan and one round per stage**, Stage 3 skipped as `Pick the tier` says:

- with each skill invoked once: 86621 + 1963 + 3127 + 953 + 966 + 1107 + 6989 = **101725 bytes**;
- with every invocation injecting again (`analyze` twice, `commit` and `push` twice each): **111784 bytes** (UNVERIFIED, see above).

**Product session, for comparison:** P1b `product-plan-analyze` 1371, P2 `product-project-brief` 1208, P4 `product-project-plan-analyze` 1483, P5 `product-project-plan-verdict` 1409, P6 `commit` 1107 + `push` 6989. Each product step skill holds its own stage detail. Each project stage skill points back into the manager instead (F2).

### Each dispatch (for context; not the manager's cost)

These are the agent file plus its preloaded skills, before the dispatch and `AGENTS.md`. All sizes are proven; that they load in full is UNVERIFIED.

| Agent | Bytes | Made of |
|---|---:|---|
| `planner` | 31168 | 2503 + `plan` 15422 + `security` 13243 |
| `developer` | 30955 | 12069 + `security` + `comments` 5643 |
| `reviewer` | 30973 | 8275 + `security` + `comments` + `audit` 3812 |
| `analyzer` | 26580 | 9525 + `security` + `audit` |
| `plan-analyzer` | 26288 | 9233 + `security` + `audit` |
| `integrator` | 23865 | 4979 + `security` + `comments` |
| `committer` | 17708 | 4465 + `security` |

`glab:security` (13243 bytes) is the largest fixed cost of every dispatch. Its Part 2, *Durability* (`security:88-157`, 5097 bytes), binds code-writing agents. Shrinking it is outside this request and is recorded as a lever only (*Next steps*).

---

## 2. Section by section: who acts on it, and where it goes

Legend for **Who**: `M*` the manager at every stage · `M@n` the manager at stage n only · `A` an agent · `—` nobody now.
Legend for **Goes to**: `stays`, `→ <skill>` (moves to a skill loaded when its stage runs), `→ ref` (a reference file read only when the case comes up), `dup` (already said elsewhere; cut to a pointer or cut), `dead`.

### `plugins/glab/skills/manager/SKILL.md` (40284 bytes)

| Lines | Section | Bytes | Who | Goes to | Target bytes |
|---|---|---:|---|---|---:|
| 1-4 | frontmatter | 598 | listing | stays; the description repeats the stage list, cut it | 300 |
| 6-9 | `# Manager` | 165 | M* | stays | 165 |
| 10-13 | The rules of every level | 285 | M* | stays as one line; "but Rule 4" goes away with F17 | 150 |
| 14-22 | Your skills — this level only | 652 | M* (boundary) | stays, with the new names | 750 |
| 23-30 | Rule 4 — what this session owns | 927 | M* (a relayed decision can come at any stage) | stays as a named section (F17) | 700 |
| 31-34 | Know the gates before you dispatch | 224 | — | dup of `bootstrap` step 3 (`bootstrap:29-41`); one clause in the pipeline paragraph | 0 |
| 35-52 | The pipeline | 2359 | M* | stays: the table, and how a stage skill is invoked and shown (`:51`). "No slug" moves into each stage skill, as the product skills do. | 2200 |
| 53-77 | Pick the tier | 1889 | M@1 picks, M* raises | stays. The criteria (`:57-59`) move to `project-plan` Step 0 (F4). The round-cap cells (`:65-70`) become "capped" (F7). | 1300 |
| 78-88 | The master plan and sub-plans | 2544 | `:82` M@1 (hash, changed request); `:83-87` M* | `:82` → `project-plan-accept`; `:84`'s brief exception → `project-plan-report`; the orchestration (`:83`, `:85-87`) and the commit order from `:274` stay | 1000 |
| 89-120 | Running agents in parallel | 2463 | M@1b/3/5 fan out; M@2 split | `:105-110` (develop split, about 1250) → `project-develop`; `:96-101` review dimensions → `project-review`; `:112-115` never commit or push in parallel → `commit`; stays: the independence rule and reconciling (`:91-92`, `:117-119`) | 400 |
| 121-132 | When subagent dispatch is not available | 1196 | M, on such a host only | → ref `project-manager/references/without-subagents.md`, with `session-rules:124` merged in; a one-line pointer stays | 150 |
| 133-142 | Stage 1 — Plan | 2118 | M@1 | stays, condensed: dispatch the planner, the typed `/glab:project-plan` exception, a brief is a request, *Explore once* (its `findings-` incident, `:139`, stays with its rule), decisions reviewed | 1100 |
| 143-157 | Plan acceptance checklist | 2674 | M@1, when the planner returns | → `project-plan-accept` | 0 |
| 158-163 | A question blocks; a decision does not, and the approval | 1246 | M@1, after 1b | → `project-plan-accept` | 0 |
| 164-172 | Approval in plan mode | 2060 | M, only when the user asks | → ref `project-plan-accept/references/plan-mode.md`; the L1–L7 UNVERIFIED marks go with it | 0 |
| 173-188 | Stage 1b | 3312 | M@1b | → `project-plan-analyze`. Its rationale (`:175-177`) points at `glab:plan-analyzer` *The plan check*, which keeps the real case. | 0 |
| 189-203 | Stage 1c | 2819 | M@1c, and on resume | → `project-plan-report`. The freeze (`:195`) binds every later stage, so one line stays. | 250 |
| 204-216 | Stage 2 — Develop | 956 | M@2 | → `project-develop`; the dispatch list `:210-212` is dup of Rule 0c (F16) | 0 |
| 217-220 | What you require back | 148 | M@2 | dup of `glab:developer` *Report*; pointer in `project-develop` | 0 |
| 221-230 | Verify before moving on | 1112 | M@2 | → `project-develop` | 0 |
| 231-249 | Stage 3 — Analyze | 3016 | M@3 | → `project-analyze`, with the snapshot recipe | 0 |
| 250-257 | Stage 4 — Integrate | 924 | M@4 | → `project-integrate` | 0 |
| 258-269 | Stage 5 — Review | 1886 | M@5 | → `project-review` | 0 |
| 270-277 | Stage 6 — Commit | 728 | M@6 | `:274` (sub-plan commit order) stays in the sub-plan block; `:272`, `:276` dup of `commit:7-11` | 0 |
| 278-283 | Stage 6b — Final check | 898 | M@6b | → `project-analyze` | 0 |
| 284-289 | Stage 7 — Push | 530 | M@7 | dup of `push:9` and `push` *After*; "then Stage 8" is already in the table | 0 |
| 290-300 | Stage 8 — Record | 1783 | M@8 | → `project-record` (new) | 0 |
| 301-311 | What you never do | 771 | M* | each item points at its owner, so the list is a dup. Keep the cross-stage items: never lower a tier, never edit `master.md` after approval, never start a service outside Stage 4, never plan mode unasked. | 350 |
| | **Total** | **40284** | | | **≈ 8800-10000** |

Recorded incidents in the manager move with their rules:

- `:139`, a subagent's Write of `findings-…` refused: stays in the manager with *Explore once*;
- `:107`, "a red tree and two reports that each blame the other": goes with the split rule to `project-develop`;
- `:175-177`: already held in full by `plan-analyzer:47-52`, so the pointer suffices.

None is dropped.

### `plugins/glab/skills/session-rules/SKILL.md` (22435 bytes), as each manager uses it

| Lines | Section | Bytes | Project manager | Product manager | Goes to | Target |
|---|---|---:|---|---|---|---:|
| 1-4 | frontmatter | 454 | listing | listing | shorten | 250 |
| 8-13 | The level boundary | 776 | start | start | stays; the `product-project-plan-report` exception (`:10`) goes with the rename (F13) | 600 |
| 14-17 | How to read these rules | 794 incl. `:18` | not used | start | stays, short, once the shared rules stop naming project stages (F25) | 250 |
| 18 | Where a record line goes | (in the row above) | @1c onward | — | → `project-plan-report`; the manager's freeze line points at it | 0 |
| 20-22 | Rule 0 | 430 | — | — | dup: it says itself that it is hook point 1 and `bootstrap` step 1; its agent half is Rule 0c's | 80 |
| 24-26 | Rule 0b | 335 | every stage | every stage | stays | 250 |
| 28-34 | Rule 0c | 1234 | every dispatch | every dispatch | stays; its stage list made neutral ("what the stage skill says that round is given") | 1000 |
| 36-43 | Rule 0d — effort | 1938 | start (find the level), every dispatch | same | stays; drop the 9-name list (`:38`, about 230 bytes) and compress | 1200 |
| 45-54 | Rule 1 | 1112 | every request | every request | stays | 950 |
| 56-68 | Rule 2 | 1668 | every stage | every stage | stays; `:66` is dup (`bootstrap:45`, `manager:91`); stage list neutral | 1350 |
| 70-80 | Your own context | 3267 | every handoff line; `:76` and `:78` once per session | same | stays, compressed. The 648k incident (`:75`) stays. | 2000 |
| 82-99 | Rule 3 | 1632 | every decision | every decision | stays | 1500 |
| 101-113 | Rule 5: head and model table | 684 | every handoff line | same | stays, one compact line per role | 400 |
| 115 | why these models | 273 | — | — | rationale → `docs/specs/workflow.md`, one-line pointer | 0 |
| 117 | No instruction, no parameter | 566 | every dispatch | same | stays | 400 |
| 118, 120, 121 | the user's override: naming, how long, recording | 2285 | only when the user names a model | same | compress to about 900, or → ref read when the user names a model | 900 |
| 119 | Precedence | 470 | — | — | dup of `docs/specs/workflow.md` (it says so); pointer | 80 |
| 122 | naming the model in the handoff line | 708 | every handoff | same | merge into *The handoff line* | 0 |
| 123 | the pipeline does not bend | 356 | every stage | same | stays | 250 |
| 124 | without subagent dispatch | 271 | rare | — | → the project ref `without-subagents.md` | 0 |
| 126 | Write the dispatch for the model | 568 | @6 (the committer is the one `haiku` role) | @P6 | → `glab:commit`, which both levels load | 0 |
| 128 | the report check | 747 | every agent return | same | stays | 600 |
| 130-132 | Round caps | 1013 | @1b, @3, @5, @6b | @P1b | stays; said once, the stage skills point at it | 850 |
| 134-138 | The handoff line | 749 | every stage | every stage | stays, with the model clause from `:122` | 750 |
| | **Total** | **22435** | | | | **≈ 13000** |

**Answer to audit question 6.** `session-rules` can shrink to about **13 KB** at no loss of rules: −9.4 KB from duplicates, rationale and rare cases. What every manager needs at session start: the level boundary, Rule 0b, Rule 0d's "find the level once", Rule 1, Rule 2 and its context part, Rule 3, Rule 5's no-parameter rule and table, the report check, and the handoff line. What is needed only at one stage:

- *Round caps* (1b, 3, 5, 6b, P1b): keep it here anyway, once, since both levels use it;
- the `haiku` dispatch rule (commit): moves to `glab:commit`;
- the record-line routing (`:18`, project Stage 1c onward): moves to `project-plan-report`;
- the user-override bookkeeping (only when the user names a model): compress, or move to a reference file.

A further 2 KB (to about 11 KB) is possible by moving all of Rule 5's override text to a reference file. That trades a Read when the user names a model against every session's start. The manager's call.

### `plugins/glab/skills/bootstrap/SKILL.md` (8234 bytes), loaded by every manager

- Steps 1-2 (`:15-27`) restate the hook text, and say so.
- Step 4 (`:43-45`) restates the manager.
- Step 6's four Go and PostgreSQL hazards (`:89-117`, 1797 bytes) are incidents acted on by agents that count things (planners, analyzers, mapping agents), not by the manager. They are kept: they move to `host.example.md` or a spec's *Incidents*, with a one-line pointer.

The target is about **5.5 KB** (F22). This is optional and outside the user's words. It is listed because the file is part of the session's fixed cost.

---

## 3. Revalidation of the project skills and agents

| Item | Bytes | Conflicts | Stale text or repeats | Left over from 0.14.0 |
|---|---:|---|---|---|
| `plan` | 15422 | F4: who picks the tier | 12 lines cite `glab:manager` sections the planner cannot see (F3); *Quick Reference* `:145-155` (727 bytes) repeats Steps 0-4 | — |
| `develop` | 3127 | — | a list of preconditions only; the work "as Stage 2 says" (`:7`) (F2); legacy `0.11.0` clause `:16` (F11); "(approved, at full tier)" `:3` (F18) | `:17` names `plan-gate.sh check`, which `flow-gate-hardening` is changing (F24) |
| `analyze` | 1963 | F5: "only the slug" against `manager:235` | claims the record check (`:7`), which Stage 8 dispatches directly (F12); "no slug" and "show the report" point back at the manager | — |
| `integrate` | 953 | — | the outcomes are all "Stage 4's" (`:11`) (F2) | — |
| `review` | 966 | — | claims the record review (`:7`) (F12) | — |
| `ship` | 3000 | — | sound; self-contained | — |
| `commit` | 1107 | — | sound; would gain the `haiku` dispatch rule | — |
| `push` | 6989 | — | sound; heavy rationale, but every story is a recorded defect of this file and stays (F21) | — |
| `product-project-plan-report` | 1572 | — | the name says product, the level is project (F13) | — |
| `planner` | 2503 | — | `:20` sends it to the Skill tool for `glab:manager` sections (F3) | — |
| `plan-analyzer` | 9233 | — | legacy clauses `:23`, `:41` (F11). It repeats the analyzer's Step 1, intent and report blocks, but each agent receives only its own file, so the agent still gets each rule once. Not a finding. | — |
| `developer` | 12069 | — | legacy `:22`, `:126` (F11); "(approved, at full tier)" `:3`, `:11` (F18); Go-specific mock rules `:73-75` (F27) | — |
| `analyzer` | 9525 | — | legacy `:23`, `:70` (F11); preloads all of `audit` for one table (F10) | — |
| `integrator` | 4979 | — | sound | — |
| `reviewer` | 8275 | — | preloads all of `audit` for one table (F10) | — |
| `committer` | 4465 | — | sound; no level prefix, which is right (it serves both levels) | — |

## 4. Findings

| id | severity | file:line | finding | recommendation |
|---|---|---|---|---|
| F1 | high | `plugins/glab/skills/manager/SKILL.md:133-300` | 26210 of the manager's 40284 bytes (65 %) are stage sections, each acted on at one stage only, yet loaded at every project session start, and again after each compaction (UNVERIFIED). This makes the project start 86621 bytes against the product's 57203. | Move each stage section into the skill that runs that stage (§5); keep the stage map, the tier table, the level boundary and the sub-plan orchestration in a manager of at most about 10 KB. |
| F2 | high | `develop/SKILL.md:7`, `analyze/SKILL.md:13,15`, `integrate/SKILL.md:11`, `review/SKILL.md:7,11`, `product-project-plan-report/SKILL.md:20` | The ownership is inverted. Each project stage skill is a thin entry that sends the session back to "Stage n says" in the manager, so the manager must carry every stage's detail. The product step skills hold their own (`product-plan-analyze:11-15`, `product-project-plan-verdict:24-37`). | Invert it: each `project-*` stage skill holds its stage (dispatch contents, verdict routing, rounds, delta); the manager holds only *which* skill and the outcome that leaves the stage. |
| F3 | high | `plugins/glab/agents/planner.md:5,20`; `plugins/glab/skills/plan/SKILL.md:22` (+ 11 more `glab:manager` cites) | The planner preloads `glab:plan`, which points into `glab:manager` 12 times. `planner.md:20` tells it the Skill tool "is for the `glab:manager` sections it points at", and the planner has the `Skill` tool (`:5`). A planner following that loads 40 KB that opens "You run this session as a manager" (`manager:8`). The tier criteria it needs for Step 0 (`plan:22`) exist only in `manager:57-59`. Whether planners do load it: UNVERIFIED, no transcript read. | Put the tier criteria in `project-plan` Step 0. Retarget its pointers so that nothing the planner acts on lives in the manager. Drop the Skill-tool sentence at `planner.md:20`, and the `Skill` tool if nothing else needs it. |
| F4 | medium | `manager/SKILL.md:55`; `plan/SKILL.md:75`; `session-rules/SKILL.md:47` | Two owners for one line. The manager "pick[s] the tier … and write[s] it as the first line of `plan.md`", while `glab:plan` Step 3 has the planner write that same first line, and Rule 1 says the manager authors only dispatches, decision lines and status lines. | The planner proposes the tier by the criteria (F3). The manager accepts it or raises it at the acceptance checklist, recording a raise as a `## Decisions` line. Say this once, in `project-plan-accept`. |
| F5 | medium | `manager/SKILL.md:235`; `analyze/SKILL.md:9`; `session-rules/SKILL.md:34` | Stage 3 says to run `/glab:analyze {slug}` "with the slug and that summary", while `analyze` says `$ARGUMENTS` "is only the slug", and Rule 0c's list of what a dispatch carries has no result summary. | Decide one way. Either the analyzer gets no summary (it reads the tree and the plan), or the summary is named in Rule 0c. Write it once, in `project-analyze`. |
| F6 | medium | `session-rules/SKILL.md:101-128` | Rule 5 is 7015 bytes (31 % of the file). It holds: precedence internals the file itself says live in `docs/specs/workflow.md` (`:119`, 470); a `haiku` dispatch rule for the one `haiku` role (`:126`, 568); the user-override bookkeeping, used only when the user names a model (`:118,120,121`, 2285); a no-subagent bullet that repeats `manager:128` (`:124`). | Cut it to about 3 KB: precedence becomes a pointer; the `haiku` rule moves to `glab:commit`; the override text is compressed; `:124` goes to the no-subagent reference file. |
| F7 | medium | `manager/SKILL.md:65,67,69,70,187,239,264,282` | The round cap is restated in four stage paragraphs on top of the tier-table cells. `AGENTS.md:140-143` registers only *Round caps*, the tier table and `reviewer.md` *Re-reviews*. | The stage skills say "capped as `glab:session-rules` *Round caps*" and then what happens after the last round; the table cells say "capped". |
| F8 | medium | `session-rules/SKILL.md:20-26`; `manager-bootstrap.sh:67-75`; `bootstrap/SKILL.md:17-27`; `manager/SKILL.md:12` | "Read `AGENTS.md` first" and "`session-rules` and `security` are loaded with this skill" are each said three or four times across the hook, `bootstrap`, `session-rules` and the manager. Rule 0 says itself that it "is that step". | The hook owns it (it must hold without `bootstrap`). Rule 0 becomes a pointer or goes; drop the "loaded with this skill" sentences. |
| F9 | medium | `manager/SKILL.md:89-119`; `bootstrap/SKILL.md:45`; `session-rules/SKILL.md:66` | "Dispatch independent agents in a single message" is said three times. The develop split rules (about 1250 bytes) are acted on at Stage 2 only. | Say it once, in Rule 2. The split rules go to `project-develop`, the review dimensions to `project-review`, never-in-parallel to `glab:commit`. |
| F10 | medium | `agents/analyzer.md:7-8,100`; `agents/plan-analyzer.md:7-8,109`; `agents/reviewer.md:9,88` | Three agents preload all of `glab:audit` (3812 bytes) and say themselves that they use only *Severity Levels* (366 bytes). That is about 3.4 KB unused on every analyzer, plan-analyzer and reviewer dispatch, 3-8 per task. | Move the four-row table into a small shared skill, for example `glab:severity` (about 500 bytes), preloaded by those three and cited by `audit`. Update the one-fact entry `AGENTS.md:178-183` and the skills gate `AGENTS.md:83`. |
| F11 | low | `manager:183,185`; `develop:16`; `developer:22,126`; `analyzer:23,70`; `plan-analyzer:23,41` | Compatibility clauses for plan folders from before `glab` 0.10.0 (`findings.md`) and before 0.11.0 (no master, no approval) are repeated in 8 places and paid for in every dispatch. This repo removes landed plan folders (`AGENTS.md:335-358`); other installers may still have old ones. | Say it once: a short *Older folders* section in `project-plan`, which the agents point at. Or drop the clauses on the next minor version, which is the user's call (F11 is in *Next steps*). |
| F12 | low | `analyze/SKILL.md:7`; `review/SKILL.md:7`; `manager/SKILL.md:49,295-296` | `analyze` and `review` each call themselves the entry point of the Stage 8 record check and review. Stage 8 dispatches `glab:analyzer` and `glab:reviewer` directly. | `project-record` dispatches them directly; drop the Stage 8 claims from both stage skills. |
| F13 | low | `session-rules/SKILL.md:10`; `product-manager/SKILL.md:23` | The level boundary needs an exception sentence, in two files, because a project-level skill is named `product-project-plan-report`. | Rename it `glab:project-plan-report`; both sentences go. |
| F14 | low | `manager/SKILL.md:276,286` | Stage 6 restates `commit:9` ("a refusal … is the correct outcome"); Stage 7 restates `push:9` (no push agent, and why). | Cut both; the stage skills own them. |
| F15 | low | `manager/SKILL.md:31-33` | *Know the gates* restates `bootstrap` step 3. | One clause in the pipeline paragraph. |
| F16 | low | `manager/SKILL.md:210-212` | The Stage 2 dispatch list restates Rule 0c's list (`session-rules:34`). | `project-develop` adds only what is particular to Stage 2: how a fix round is named, and `BLOCKED` and `PLAN WRONG` re-dispatches. |
| F17 | low | `manager/SKILL.md:12,23`; `session-rules/SKILL.md:121` | Rule 4 lives in the manager while Rules 0-3 and 5 live in `session-rules`. The shared skill cites "`glab:manager` Rule 4", which a product session may not load (the level boundary). | Make it a named manager section ("What this session owns"); `session-rules:121` drops the cite or says "the project manager's *What this session owns*". |
| F18 | low | `develop/SKILL.md:3`; `agents/developer.md:3,11` | "(approved, at full tier)" reads as though a normal-tier plan is not approved; at normal tier it is accepted and reported (`manager:162`). | "an accepted plan — the user's approval at full tier". |
| F19 | medium | `manager/SKILL.md:121-131`; `session-rules/SKILL.md:124` | The no-subagent host case (1467 bytes in all) is loaded into every session and is split over two files. | Move it to `project-manager/references/without-subagents.md`; the manager keeps a one-line pointer. |
| F20 | medium | `manager/SKILL.md:164-171` | Plan-mode approval (2060 bytes, with seven UNVERIFIED marks) runs only when the user asks for it. `AGENTS.md:274-278` registers it in `manager/SKILL.md` and `README.md`. | Move it to `project-plan-accept/references/plan-mode.md`, read when the user asks; update the registry entry. |
| F21 | low | `manager/SKILL.md:51`; `push/SKILL.md` (6989 bytes) | Stage skills are invoked by the Skill tool at every stage and round: `analyze` up to 4 times per task, `commit` and `push` twice each (Stages 6-7 and 8). Whether a second call injects the body again is UNVERIFIED. If it does, `push` alone costs about 14 KB per task. | Tell the manager to invoke a stage skill once per context and follow the loaded text for later rounds, invoking it again only after a compaction. Measure re-injection on the punching-bag repo before relying on either reading. |
| F22 | low | `bootstrap/SKILL.md:15-27,43-45,89-117` | Steps 1-2 restate the hook. Step 4 restates the manager. Four Go and PostgreSQL hazards (1797 bytes) are agents' incidents carried into every manager session. | Steps 1-2 and 4 become pointers. The four hazards move to `host.example.md` or a spec's *Incidents* with a pointer (*Comments and recorded incidents are kept*). The target is about 5.5 KB. |
| F23 | medium | `AGENTS.md:130-330` (*One fact*), `:76`, `:82-83` (*Gates*) | About 25 one-fact entries name manager sections by path ("`manager/SKILL.md` Stage 1c", "acceptance checklist item 6", "*Pick the tier*"). The skills gate (`:76`) lists all 21 names, and the model and skills gates (`:82-83`) list the agent file names. Every one moves in the restructure. | The plan carries an explicit retarget list for each entry, checked by search. The gates' expected lines are rewritten in the same commit. |
| F24 | medium | `plugins/glab/scripts/plan-gate.sh:5-6`; `develop/SKILL.md:17` | The rename touches `plan-gate.sh` (it names `glab:product-project-plan-report` and `glab:develop`), which `flow-gate-hardening` is changing now. | Plan `flow-project-level` after `flow-gate-hardening` lands, as the handoff already says. Rebase the rename of those two comment lines onto it. |
| F25 | low | `session-rules/SKILL.md:14-17,34,54,62,123` | The shared rules are written in project-stage terms (Stages 1b, 2, 3, 5, 6b, 8; *Pick the tier*; Stage 5), so a 794-byte mapping section exists to translate them for the product level. | Write the shared rules stage-neutral ("the round, and what that stage's skill says it is given"); the mapping section shrinks to about 250. |
| F26 | low | `manager/SKILL.md:3`; `session-rules/SKILL.md:3` | The descriptions (575 and 425 bytes) sit in every session's skill listing, at both levels, and the manager's repeats the whole stage sequence. | About 250 bytes each. |
| F27 | low | `agents/developer.md:73-75` | Go-specific test policy (generated mocks, `go:generate`-style directives, 95 % coverage) in a plugin-wide agent. `AGENTS.md:90-102` has to carve an exception for this repo. | Leave it for now; it is the user's policy. Flag it for the per-role review of the optimization plan. |

## 5. The rename map

The frontmatter `name:` stays bare and matches its directory (`AGENTS.md:365-369`, skills gate `:83`). Every row below changes the directory, the `name:`, every prefixed mention and the gate lists.

### Skills

| Now | After | Why | Files that name it (lines matching, from the search) |
|---|---|---|---|
| `glab:manager` | `glab:project-manager` | the user's choice | `manager-bootstrap.sh` 1, `bootstrap` 2, `push` 1, `commit` 1, `manager` 1, `review` 3, `plan` 12, `ship` 2, `session-rules` 6, `analyze` 3, `product-project-plan-report` 4, `integrate` 2, `audit` 1, `develop` 6, agents `developer` 1, `analyzer` 5, `planner` 3, `plan-analyzer` 2, `README.md` 4, `AGENTS.md` 2, `tests/product-loop.test.sh` 5 (`:125,132,135,138,139`), `tests/manager-bootstrap.test.sh` 1 (`:37`) |
| `glab:plan` | `glab:project-plan` | the planner's procedure, and `/glab:project-plan <task>` | `manager` 11, `plan` 2, `session-rules` 1, `product-project-plan-report` 1, `audit` 3, `develop` 2, agents `developer` 1, `planner` 7 (incl. `skills:` `:7`), `plan-analyzer` 1, `README.md` 2, `AGENTS.md` 4 (incl. skills gate `:83`) |
| `glab:develop` | `glab:project-develop` | | `plan-gate.sh` 1 (F24), `manager` 10, `plan` 5, `audit` 1, `develop` 1, `developer` 1, `analyzer` 1, `README.md` 2, `tests/product-loop.test.sh` 6 (scene text) |
| `glab:analyze` | `glab:project-analyze` (Stages 3, 6b) | Stage 1b moves out to `project-plan-analyze` | `manager` 7, `analyze` 1, `developer` 1, `analyzer` 1, `plan-analyzer` 1, `README.md` 1 |
| — | `glab:project-plan-analyze` (new) | Stage 1b; the counterpart of `product-plan-analyze` | new |
| — | `glab:project-plan-accept` (new) | Stage 1's manager side: acceptance checklist, questions, approval, hash, changed request; plan mode as a reference file | new |
| `glab:integrate` | `glab:project-integrate` | | `manager` 3, `integrate` 1, `integrator` 1, `README.md` 1 |
| `glab:review` | `glab:project-review` | | `manager` 3, `review` 1, `ship` 2, `session-rules` 3, `integrator` 1, `analyzer` 1, `plan-analyzer` 1, `README.md` 1 |
| `glab:ship` | `glab:project-ship` | on the project list only (`manager:19`), not the product's | `manager` 1, `ship` 2, `session-rules` 2, `README.md` 1 |
| `glab:product-project-plan-report` | `glab:project-plan-report` | it is the project level's (F13) | `plan-gate.sh` 1 (F24), `manager` 3, `product-manager` 1, `session-rules` 1, `README.md` 1, `tests/product-loop.test.sh` 1 (`:174`) |
| — | `glab:project-record` (new) | Stage 8 | new |

### Shared skills: stay unprefixed

They serve every level, and both managers list them (`manager:20`, `product-manager:20`):

- `glab:session-rules` and `glab:bootstrap`: loaded by every manager;
- `glab:security`, `glab:comments` and `glab:audit`: preloaded by agents of both levels;
- `glab:commit` and `glab:push`: Stage 6/7 and P6.

The product skills keep their names.

### Agents: recommended renamed, but the user's call

- `planner` → `project-planner`
- `plan-analyzer` → `project-plan-analyzer`
- `analyzer` → `project-analyzer`
- `developer` → `project-developer`
- `integrator` → `project-integrator`
- `reviewer` → `project-reviewer`
- `committer` stays shared.

**For:**

- it matches `product-planner` and `product-analyzer`;
- the level shows in the Agent tool's listing, so the "Project level —" description prefix stops being the only hint;
- the model and skills gates enumerate every agent file, so a missed rename fails a gate.

**Against:**

- it saves no bytes;
- it touches the Rule 5 table, the model gate (9 lines), the skills gate (18 lines), `README.md` and the tests (`product-loop` 4 lines on `glab:planner`, `plan-gate.test.sh:301` and `product-loop.test.sh:220` on `glab:developer` inside a recorded `- model:` line);
- a future delivery level may want a shared developer or reviewer.

Role words in prose ("the reviewer") do not change, so the user's spoken model overrides keep working.

**Files that name each agent** (lines matching):

- `glab:planner`: `manager` 6, `plan` 2, `session-rules` 3, `README.md` 2, `tests/product-loop.test.sh` 4;
- `glab:plan-analyzer`: `manager` 3, `session-rules` 2, `analyze` 2, `analyzer` 1, `README.md` 2, `AGENTS.md` 2;
- `glab:developer`: `manager` 6, `plan` 2, `ship` 1, `session-rules` 2, `develop` 1, `README.md` 1, `AGENTS.md` 1, `tests/product-loop.test.sh` 1, `tests/plan-gate.test.sh` 1;
- `glab:analyzer`: `manager` 4, `session-rules` 2, `analyze` 2, `audit` 1, `plan-analyzer` 2, `README.md` 3, `AGENTS.md` 2;
- `glab:integrator`: `manager` 2, `plan` 1, `session-rules` 2, `integrate` 2, `README.md` 1;
- `glab:reviewer`: `manager` 6, `review` 2, `ship` 2, `session-rules` 3, `README.md` 1;
- every agent file name also appears in the `AGENTS.md` gates (`:76`, `:82`, `:83`).

**Also:**

- the plugin version rises (0.15.0; a rename is breaking for anyone who types `/glab:plan`);
- `README.md` says what each old name became;
- `docs/specs/workflow.md` takes the record.

## 6. The target structure

### `glab:project-manager`: at most about 10 KB, modelled on `glab:product-manager`

| Section | Bytes (estimate) | Holds |
|---|---:|---|
| frontmatter | 300 | a short description, with the level prefix |
| intro, the rules of every level | 315 | as `product-manager:6-12` |
| Your skills — this level only | 750 | the new names; the boundary list |
| What this session owns (ex-Rule 4) | 700 | surfaces, seams, relayed decisions |
| The pipeline | 2200 | the table: stage · skill or agent · writes · leaves on; how a stage skill is invoked, shown and invoked once per context (F21); the gate line from `bootstrap` step 3 |
| Pick the tier | 1300 | what runs per tier; only the user lowers a tier; anyone may raise one |
| Stage 1 — dispatching the planner | 1100 | the planner, a typed `/glab:project-plan`, a brief is a request, *Explore once* |
| Sub-plans | 1000 | each runs its own cycle, in `<nn>` order; what each agent reads; one commit per sub-plan; the slug ends once |
| Parallel | 400 | independence; reconcile before acting |
| After a report to product | 250 | plan files frozen; record lines go to `after-verdict.md` (`project-plan-report`) |
| pointers | 150 | `references/without-subagents.md` |
| What you never do | 350 | the cross-stage items only |
| **Total** | **≈ 8800-10000** | |

### Stage skills: loaded when their stage runs

| Skill | Now | Target (estimate) | Takes in |
|---|---:|---:|---|
| `project-plan` (planner's procedure, preloaded) | 15422 | ≈ 14000 | the tier criteria (F3, F4), *Older folders* (F11); loses *Quick Reference* and its `manager` pointers |
| `project-plan-accept` (new) | — | ≈ 4500 | `manager:82,143-163`, the tier acceptance (F4); `references/plan-mode.md` ≈ 1900, read on ask |
| `project-plan-analyze` (new) | — | ≈ 3000 | `manager:173-188` |
| `project-plan-report` | 1572 | ≈ 4000 | `manager:189-203`, `session-rules:18`, `manager:84`'s brief exception |
| `project-develop` | 3127 | ≈ 5500 | `manager:204-230`, `:105-110` |
| `project-analyze` | 1963 | ≈ 4000 | `manager:231-249,278-283`; loses Stage 1b and Stage 8 |
| `project-integrate` | 953 | ≈ 1600 | `manager:250-257` |
| `project-review` | 966 | ≈ 2600 | `manager:258-269`, `:96-101` |
| `project-ship` | 3000 | ≈ 3000 | unchanged |
| `project-record` (new) | — | ≈ 1900 | `manager:290-300` |
| `commit` (shared) | 1107 | ≈ 1700 | `session-rules:126`, `manager:112-115` |
| `push` (shared) | 6989 | 6989 (≈ 5000 optional) | unchanged; optionally rationale → spec, keeping every incident (F21) |
| `references/without-subagents.md` | — | ≈ 1300 | `manager:121-131`, `session-rules:124` |

### Bytes a session carries afterwards

| Moment | Now, project | Target, project | Now, product | Target, product |
|---|---:|---:|---:|---:|
| Start: hook + `bootstrap` + manager + `session-rules` + `security` | **86621** | **≈ 46900** (2425 + 8234 + 10000 + 13000 + 13243); **≈ 44100** with `bootstrap` at 5.5 KB | 57203 | ≈ 47800 (≈ 45000 with `bootstrap` at 5.5 KB) |
| Stage 1 (after the planner returns) | 0 | 4500 | — | — |
| Stage 1b, per stage, invoked once | 1963 | 3000 | P1b 1371 | 1371 |
| Stage 1c | 1572 | 4000 | — | — |
| Stage 2 | 3127 | 5500 | — | — |
| Stage 3 | 1963 (0 when loaded at 1b) | 4000 | — | — |
| Stage 4 | 953 | 1600 | — | — |
| Stage 5 | 966 | 2600 | — | — |
| Stage 6 | 1107 | 1700 | P6 1107 | 1700 |
| Stage 6b | 0 when `analyze` is loaded | 0 when loaded at 3, else 4000 | — | — |
| Stage 7 | 6989 | 6989 (≈ 5000) | P6 6989 | 6989 (≈ 5000) |
| Stage 8 | 0 (in the manager) | 1900 | — | — |
| **One normal-tier task, single plan, one round each, each skill invoked once** | **101725** | **≈ 79000** (≈ 74200 with both optional trims) | | |

**Reading the totals.** This is inferred, not measured.

- The start set is what every turn of the session re-reads, from the first turn to the last, and what is re-established after each compaction. It falls by about **46 %** (86.6 KB to about 46.9 KB).
- Stage text loaded late is paid only on the turns after it loads, and not at all by a session that stops early, a `/glab:project-ship` session, or a session resumed mid-pipeline.
- The whole-task total falls by about 22-27 %. The per-turn saving is larger than that, because most turns of a long manager session come after the start set loads and before the late stages run.
- The product start falls by about 16 %, from `session-rules` alone.

## 7. Recommendations, by priority

1. **F1, F2, F3 (high).**
   - Invert ownership: the stage detail goes into the `project-*` stage skills, and the manager drops to at most about 10 KB.
   - The planner stops depending on the manager (tier criteria into `project-plan`; drop `planner.md:20`'s Skill-tool sentence).
2. **F4, F5 (medium, conflicts).** Settle who writes the tier line and what Stage 3's analyze dispatch carries, each once.
3. **F6, F7, F8, F9, F19, F20, F25 (medium and low, repeats).**
   - `session-rules` to about 13 KB.
   - The round cap is said once.
   - The rare cases (no subagents, plan mode) go to reference files.
4. **F23, F24 (medium, process).**
   - The plan lists every `AGENTS.md` one-fact entry and every gate line it retargets.
   - It runs after `flow-gate-hardening` lands.
5. **F10 (medium, per-dispatch).** Introduce a small severity skill instead of preloading `audit`.
6. **F11-F18, F21, F22, F26, F27 (low).** Cleanups in the same change where they touch moved text; the rest later.

## 8. Next steps

- **The user's decisions** (Rule 3: what users see and type changes):
  - whether the six project agents are renamed `project-*` (§5; recommended);
  - the names of the three new skills (`project-plan-accept`, `project-plan-analyze`, `project-record`, all proposals);
  - whether the pre-0.10.0 and pre-0.11.0 legacy clauses are dropped (F11).
- **To measure before the plan relies on it** (UNVERIFIED above):
  - whether a repeated `Skill` call injects the body again;
  - whether preloaded skills load in full;
  - what a compaction keeps.

  Measure each with `get_usage` before and after on the punching-bag repo, as the handoff's optimization plan says.
- **Outside this request, recorded as levers:**
  - `glab:security` Part 2 (5097 bytes) is in every dispatch and every manager start;
  - the shared `push` (6989 bytes) is loaded twice per task;
  - `bootstrap` can drop to about 5.5 KB.
- **Ready to plan once `flow-gate-hardening` lands:** the restructure in §6 as one master with sub-plans:
  1. `session-rules` and `bootstrap`;
  2. the stage skills take their stages;
  3. the slim `project-manager` and the rename, with the gates and `AGENTS.md` retargeted;
  4. optionally, the agent rename.
