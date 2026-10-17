# Workflow — spec

The `glab` workflow: how a session runs a change through plan, analysis,
development, integration, review, commit and push, at the depth a tier
gives it; the rules of `glab:manager`; the agents and commands; the user's
choice of model for the developer and reviewer; and what happens to a
change's plan files. Owned by `plugins/glab/skills/manager/SKILL.md`,
`plugins/glab/skills/plan-first/SKILL.md`,
`plugins/glab/skills/bootstrap/SKILL.md`, the agents under
`plugins/glab/agents/`, the commands under `plugins/glab/commands/`, and
`plugins/glab/scripts/manager-bootstrap.sh` (the `SessionStart` hook text).
The external agents are in `docs/specs/external-agents.md`. Stated as of
`6838133` (`glab` `0.4.2`), before `feature-docs-specs`; where this file and
an owning file disagree, the owning file is right.

## How it works now

- **Session start.** The `SessionStart` hook injects the irreducible rules
  (load `glab:bootstrap`, `glab:manager`, `glab:security`; read `AGENTS.md`,
  or `CLAUDE.md` and say there is no agreement; agents carry `glab:security`
  and `glab:comments`; the host file's temp directory); `glab:bootstrap` runs
  the full sequence — agreement and `docs/constants.md`, skills, the repo's
  real gates, the handoff, the host's hazards — and ends on the one-line
  check. The hook text and the skill are one fact (`AGENTS.md` *One fact*).
- **The pipeline** (`glab:manager` *The pipeline*): 1 Plan (`/glab:plan`),
  1b Analyze the plan (`/glab:analyze`, plan only), 2 Develop
  (`/glab:develop`), 3 Analyze conformance, 4 Integrate (`/glab:integrate`),
  5 Review (`/glab:review`), 6 Commit (`/glab:commit`), 7 Push
  (`/glab:push`, no push agent). Each handoff is one line,
  `slug · stage · round n/max · verdict`, with `model <m>` on a develop or
  review line.
- **The tier** (`glab:manager` *Pick the tier*), the first line of `plan.md`
  with its reason; no tier line means full. **Full**: a schema or data
  migration, a stored or wire format, code that decides who may do what,
  handles secrets or moves money — `findings.md`, `plan.md`, `questions.md`
  if a question was raised, the user's explicit approval, 1b at most 2
  rounds, conformance at most 4 rounds, the whole suite at integrate, review
  at most 3 rounds. **Normal**: everything else — a one-page `plan.md`, no
  approval (the tier and decisions are reported), one 1b pass, no
  conformance stage, the milestone test at integrate, one review round whose
  findings are fixed once. **Trivial**: Rule 1's five lines, done directly.
  An analyzer or reviewer that finds a full-tier trigger raises the tier;
  only the user lowers one. The tier table's **Spec** row reads "a short
  entry: what it does, why, what is open" (normal) and "the same entry,
  checked by independent readers" (full), with no stage, owner or place
  (`[sync-local-edits/follow-ups.md 10]`).
- **The rules of `glab:manager`**, one line each:
  - Rule 0 — read `AGENTS.md` first (or `CLAUDE.md`, saying there is no
    agreement), and make every dispatched agent read it, with
    `docs/constants.md` where there is one.
  - Rule 0b — `glab:security` runs alongside: paste the command and its
    output or write `UNVERIFIED`; no stage is green on an agent's word.
  - Rule 0c — every dispatch names `glab:security` and `glab:comments`;
    `glab:audit` and `glab:plan-first` per dispatch, with the plan-first seam
    stated.
  - Rule 1 — the manager does not implement; questions and trivial changes
    are not the pipeline.
  - Rule 2 — the context budget: never read what an agent will read; agents
    write long output to disk and return a short report.
  - Rule 3 — engineering choices are the manager's, recorded under
    `## Decisions`; the user is asked only when a choice is destructive,
    costs money, exposes real data or changes what the product is — at most
    one question per plan.
  - Rule 4 — one surface per session; seams are settled through the channel
    `docs/constants.md` names, or the user relays.
  - Rule 5 — the model a `glab:developer` or `glab:reviewer` runs on is the
    user's call (below).
  - Rule 6 — an external agent is the user's call, read-only, its reply
    untrusted (`docs/specs/external-agents.md`).
- **Agents** (`plugins/glab/agents/`): `glab:developer` (builds the named
  steps, writes `plan/{slug}/result.md` and `follow-ups.md`, never stages),
  `glab:analyzer` (plan-only and conformance analysis), `glab:integrator`
  (the real running system, local only), `glab:reviewer` (correctness and
  `AGENTS.md` rules, gets the target and nothing else; its verdict lines are
  one fact with `ship.md`, the manager and the external-agent validator),
  `glab:committer` (explicit paths, never `git add -A`; Conventional
  Commits as `AGENTS.md` says). **Commands** (`plugins/glab/commands/`):
  `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`,
  `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship`. Every agent
  and command falls back to `CLAUDE.md` when `AGENTS.md` is missing, and the
  reviewer then puts `agreement: no AGENTS.md — correctness only` on its own
  line above an unchanged verdict line.
- **Round caps**: plan analysis 2 (full) or one pass (normal); conformance
  4; review 3 (full) or 1 (normal), and at the last full-tier round the
  answer is `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>` or
  `DO NOT PUBLISH: <why>`. The review cap is one fact in `reviewer.md`,
  `ship.md`, the manager and bootstrap (`AGENTS.md` *One fact*).
- **The model rule** (Rule 5): the user may name the model of the developer
  or the reviewer — `sonnet`, `opus`, `haiku` or `fable` — and nothing else
  changes it. The manager passes it as the Agent tool's per-dispatch `model`
  parameter on every dispatch of that role, records it as a `- model:` line
  quoting the user under `## Decisions` in `plan.md`, names it in every
  develop and review handoff line (`model default` when none), writes the
  dispatch for that model (a three-row table: `opus`/default/`fable`,
  `sonnet`, `haiku`, plus a row for an external reviewer), and checks every
  report against the role's contract, resuming the agent once for missing
  fields. "For this task" ends with that task's push; "for the session" with
  the session. Every other role gets no `model` parameter. The pipeline does
  not bend: the manager still runs the gates, the reviewer still gets only
  the target, push still waits for the user.
- **Plan files** (`glab:plan-first`): `plan/{slug}/` holds `findings.md`,
  `questions.md`, `plan.md`, the developer's `result.md` and
  `follow-ups.md`, `integration.md`, and `waived.md` when the user waives
  planning. Its rule at `6838133`: "Plan files are working files. When the
  task ships, what stays true goes into the repo's spec as a short entry —
  what it does, why, what is open — and the plan folder is then removed under
  the repo's own rule for that. A repo that keeps no specs, or keeps specs but
  has no rule for removing plan folders, keeps its plans. Never remove an
  untracked plan file." No stage writes that entry (`[sync-local-edits/follow-ups.md 10]`).

## Decisions that still bind

- [feature-model-switch/plan.md D1] Manual only: the model changes only when the user names it, for one dispatch, a task or the session; never on the manager's own initiative, never because of quota, never from a file.
- [feature-model-switch/plan.md D2] Developer and reviewer only; analyzer, integrator, committer and planning agents get no `model` parameter.
- [feature-model-switch/plan.md D3] The user does not run commands: the user tells the manager, who carries the choice into every dispatch of the role until the user changes or clears it.
- [feature-model-switch/plan.md D4] The handoff line names the model, so the user sees what was asked for.
- [feature-model-switch/plan.md D5] The pipeline does not bend to the model: gates, the reviewer's target-only brief, the push go-ahead, the tier and the round caps stay.
- [feature-model-switch/plan.md D6] The mechanism is the Agent tool's per-invocation `model` parameter, passed on each dispatch; it tops the documented order and holds across a resume.
- [feature-model-switch/plan.md D7] One home for the rule, `glab:manager` Rule 5; the stages and commands point to it, the commands restating only the minimum.
- [feature-model-switch/plan.md D8] No change to the agent files: no `model` in their frontmatter, so the documented default applies without an instruction.
- [feature-model-switch/plan.md D9] The choice is recorded as a `- model:` line under `## Decisions` in the task's `plan.md`; a review or ship with no plan keeps it in conversation only, and a lost one falls back to the default.
- [feature-model-switch/plan.md D10] An unspecified duration means the task in progress (the session when there is no task): a lost choice falls back to the default, never to a cheaper model.
- [feature-model-switch/plan.md D11] Develop and review handoff lines always name the model, `model default` included.
- [feature-model-switch/plan.md D12] Rule 5 names its limits: the line states what was passed; a forced subagent model, an allowlist or a mod can run something else, and `/tasks` shows what runs.
- [feature-model-switch/plan.md D13] Without subagent dispatch the stage session runs on the model the user starts it with, and the manager names the recorded model in the handoff.
- [feature-model-switch/plan.md D14] `AGENTS.md` *One fact* carries the manual model rule as a known case.
- [feature-model-switch/plan.md D17] Rule 5 states the version floors and that a plugin agent honouring the parameter is inferred, not shown.
- [feature-model-switch/plan.md D18] Naming `fable` is the user's money choice: said once, then used; not a Rule 3 question.
- [feature-model-switch/plan.md D20] The dispatch fits the model: Rule 5's table says what changes in the message per model; the agent files do not change.
- [feature-model-switch/plan.md D21] The report template is the agent's own *Report* section, copied as written; reading it is Rule 2's one exception.
- [feature-model-switch/plan.md D22] A malformed report is not evidence: check the required fields and the verdict line's form, correct once on the same model, then stop and tell the user; not a review round. (The review fix round made the correction a resume of the same agent.)
- [feature-model-switch/plan.md spent] D15, D16, D19 — scoping of that change: the `0.3.0` bump, leaving bootstrap and the hook untouched, and its Stage 1b amendment.
- [feature-model-switch/result.md decisions] The single normal-tier review said to cut Rule 5's per-model table and report check; the manager fixed the findings once instead, because the user had asked for per-model dispatch (Stage 5's normal-tier rule) — that is why the table and the check are in Rule 5.
- [sync-local-edits/result-followups.md D1] Sessions settle a seam through the channel `docs/constants.md` names, and the user relays when it names none; a relayed decision binds only when it arrived that way and is recorded as a `## Decisions` line naming the session.
- [sync-local-edits/result-followups.md D2] A `plan.md` with no tier line is full tier, stated once in *Pick the tier*.
- [sync-local-edits/result-followups.md D3] Rule 3 keeps `glab:security`'s stop list and its *Destructive operations are proven* rule, and states confirmation before every destructive action and every push as the manager's own rule (as corrected after review, #3).
- [sync-local-edits/result-followups.md D4] Bootstrap stays on the review-round-cap list, and the four ask-conditions are a known *One fact* case naming every file that states them.
- [sync-local-edits/result-followups.md D5] `/glab:integrate` runs after `/glab:analyze` at full tier and after `/glab:develop` at normal; normal tier runs the milestone test, full tier the whole suite.
- [sync-local-edits/result-followups.md D6] After an amendment, the develop handoff re-runs the plan's next stage.
- [sync-local-edits/result-followups.md D8] `/glab:analyze` says "If the plan is amended".
- [sync-local-edits/result-followups.md D9] The planner decides each choice and records it with its reason; the manager reviews those lines and may overrule one, recording the overrule as a new line.
- [sync-local-edits/result-followups.md D10] Only its `glab:plan-first` half stands: a repo that keeps specs but has no rule for removing plan folders keeps its plans. Its manager half — the Spec row's stage, owner and place — was removed by the review's scope cut (`[sync-local-edits/follow-ups.md 10]`).
- [sync-local-edits/result-followups.md D11] The 1b row's "Leaves on" reads "`BUILDABLE`, or one amendment at normal tier".
- [sync-local-edits/result-followups.md D12] Bootstrap points to *Pick the tier* for the full-tier triggers and names the four as Rule 3's ask-conditions; `review.md` says Stage 5 sends findings back; the hook text says "at full tier".
- [sync-local-edits/result-followups.md spent] D7 — the waiver routing it decided was removed by the review's scope cut (`[sync-local-edits/follow-ups.md 7]`, reopened).
- [sync-local-edits/result.md spent] M1, M2, M3, P1 — the port's merge choices (the reviewer's round-cap wording, the develop `questions.md` bullet, `ship.md` already matching, where bootstrap's new paragraph goes), applied in `5f69d65`; nothing in them governs later work.
- [sync-local-edits/result.md decisions] The coordinator, as manager, resolved the contradictions the port reported in favour of the user's newer text (tiers, Rule 3), because the 2026-10-08 edits were the user's latest statement of intent; the older "questions" wording and the repo's own `plan/` rule stayed. The manager's decision, not the user's approval.
- [bug-reviewer-findings/questions.md Q3] The review round cap is 3 everywhere, `/glab:ship` stating the same number so the standalone path is capped too (later "at most three — one at normal tier").
- [bug-reviewer-findings/questions.md Q7] With no `AGENTS.md`, every agent and command falls back to `CLAUDE.md` and says so; the reviewer reviews correctness only and puts `agreement: no AGENTS.md — correctness only` on its own line above an unchanged verdict line, because `/glab:ship` matches the verdict line whole.
- [bug-reviewer-findings/questions.md Q10] `manager-bootstrap.sh`'s text matches the bootstrap rules (load `glab:bootstrap`; agents carry `glab:security` and `glab:comments`); the two stay one fact.

## Known limits and not verified

- [feature-model-switch/plan.md I1] That the Agent tool on the manager's host takes `model` with the values `sonnet`, `opus`, `haiku`, `fable`, ranked above the definition's frontmatter — read from the tool definition given to one session; it depends on the Claude Code version and host. Its documentation citations (F1–F7, F16) were not re-fetched by the developer (`result.md` *Not done*).
- [feature-model-switch/plan.md I4] That a plugin agent honours the per-dispatch `model` — inferred from the docs' list of fields a plugin agent ignores; no live dispatch on `haiku` has been seen running on `haiku`. Rule 5 says so in its own text; `/tasks` would show it.
- That the user's local edits ported by `sync-local-edits` were exactly their 2026-10-08 change: inferred from the dispatch and the file times, not from a record of the edit (`[sync-local-edits/result.md L219]`).
- The removal of plan folders depends on a repo rule that, at `6838133`, no stage carries out (`[sync-local-edits/follow-ups.md 10]`).
- UNVERIFIED: that a repo which squash-merges keeps the commit a spec names as "the last commit that holds the folder" — on a squash it may live only on the branch or inside the squash commit; reasoned (`feature-docs-specs` findings, *Inferred*), not tested.

## Open follow-ups

- [sync-local-edits/follow-ups.md 7] `commands/develop.md:67`: a `waived.md` has no tier line, so the waiver path has no next stage — reopened: the routing to `/glab:integrate` was removed by the review's scope cut, because a waiver has no plan and no tier, and the integrator, the integrate scope and the review cap need both. A fix has to give a waiver a tier and an integrator input first.
- [sync-local-edits/follow-ups.md 10] The spec entry has no stage, owner or location; "checked by independent readers" is undefined; plan-folder removal depends on a repo rule that may not exist — reopened by the scope cut (the manager's spec-entry paragraph dispatched the developer outside any plan step, and a re-dispatch overwrites `result.md`); the plan-first half stayed → `feature-docs-specs`.
- [sync-local-edits/follow-ups.md 13] `glab:manager` Rule 0c seam note and Stage 1, `glab:plan-first`: "may overrule one" conflicts with Rule 4, where a relayed decision binds and the surface owner has the last word. Suggested: except a line recording another session's decision — open.
- [sync-local-edits/follow-ups.md 14] Stage 1: recording an overrule as a new line leaves steps built on the old choice. Suggested: send the plan back to the planning agent to amend them — open.
- [sync-local-edits/follow-ups.md 15] Rule 3 still reads as "the manager writes the decision line", while Stage 1 says the planner writes it. Suggested: one clause, during planning the planner writes it and the manager reviews it — open.
- [sync-local-edits/follow-ups.md 16] `commands/integrate.md:10`: the integrator agent is never told the normal-tier scope (milestone test only). Suggested: "Say which in the dispatch." — open.
- [sync-local-edits/follow-ups.md 17] `scripts/manager-bootstrap.sh:17`: "-> push at full tier" can read as "push only at full tier", and Stage 1b is missing. Suggested: "At full tier work moves through plan -> analyze -> develop -> …" — open.
- [sync-local-edits/follow-ups.md 18] `AGENTS.md` *One fact*: the analysis round caps are stated in the manager and bootstrap but not listed. Suggested: add them as a known case — open.
- [sync-local-edits/follow-ups.md 19] `commands/develop.md:67`, `commands/ship.md:32`: after a normal-tier review fix the develop handoff re-runs integrate and review, while the manager says the gates are the only check on that fix; `/glab:ship` has no normal-tier exception. Suggested: align with Stage 5 — open.
- [bug-reviewer-findings/follow-ups.md 16] `reviewer.md` and `integrator.md` fell back to "the scratchpad" while `CLAUDE.md` and bootstrap said "`$TMPDIR` if set, scratchpad otherwise" — changed since, not shown fixed: both now say "the temp directory the dispatch message names (the scratchpad only if it names none)" (`reviewer.md:73`, `integrator.md:39` at `6838133`); whether that agrees with bootstrap's wording was not re-checked.
- [bug-reviewer-findings/follow-ups.md 18] Cosmetic: `agents/developer.md:15` calls the fallback file "the working agreement" in passing; `commands/commit.md:6` has two dashes in a row — open: re-read at `6838133`, `commit.md:6` still reads `— say so) — the commit format`, and `developer.md:15` still reads `(or CLAUDE.md if the repo has none — say so) — the working agreement`.
- [bug-reviewer-findings/follow-ups.md 19] Bootstrap's grep hazard ("leading alternation returns zero matches") did not reproduce in three attempts and is worded as observed — open: `bootstrap/SKILL.md:151` still reads "observed returning **zero matches with no error**".
- [bug-reviewer-findings/result-review1-prose.md L109] Bootstrap's one-line check could name the host file as a fifth item — open, not asked for: at `6838133` it names four (agreement and constants, gates, stage, what the previous session left).
- [bug-reviewer-findings/result-slice2.md L99] `agents/reviewer.md`'s description (`:3`) still speaks of `AGENTS.md` only, beside the `CLAUDE.md` fallback in its body — open, cosmetic.

## Closed follow-ups

- [sync-local-edits/follow-ups.md 1] Rule 4 named no channel for settling a seam, and a relayed decision bound with no stated source — fixed (D1; `manager/SKILL.md` Rule 4).
- [sync-local-edits/follow-ups.md 2] Nothing said what a `plan.md` with no tier line is — fixed (D2): full tier.
- [sync-local-edits/follow-ups.md 3] Rule 3 credited `glab:security` with confirmations it does not state — fixed, then corrected after review (D3): the stop list and *Destructive operations are proven* stay `glab:security`'s, confirmation before every destructive action and push is the manager's own rule.
- [sync-local-edits/follow-ups.md 4] *One fact*: bootstrap had been dropped from the round-cap list; the ask-conditions were not a known case — fixed (D4; `AGENTS.md` *One fact*).
- [sync-local-edits/follow-ups.md 5] `commands/integrate.md:10` was not updated for normal tier — fixed (D5).
- [sync-local-edits/follow-ups.md 6] `develop.md:61` re-ran `/glab:analyze` after an amendment at normal tier — fixed (D6).
- [sync-local-edits/follow-ups.md 8] `analyze.md:18` "If I do amend it" contradicted its line 15 — fixed (D8).
- [sync-local-edits/follow-ups.md 9] Manager and plan-first disagreed on who decides a planning choice — fixed (D9).
- [sync-local-edits/follow-ups.md 11] The 1b row's "Leaves on" ignored normal tier's one amendment — fixed (D11).
- [sync-local-edits/follow-ups.md 12] Wording in bootstrap, `review.md` and the hook was narrower than the manager's — fixed (D12).

## Incidents

- **#7 and #10 were reopened by the review's scope cut** (2026-10-16): one normal-tier review of the follow-up fixes returned `SHIP WITH SCOPE CUT`. The waiver routing was removed, since a waiver has no plan and no tier; the manager's spec-entry paragraph was removed, since it dispatched the developer outside any plan step and a re-dispatch overwrites `result.md`. The earlier sync review had already cut "— one at normal tier —" from `ship.md:32`, because `/glab:ship` takes only a path and cannot know a plan's tier.
- **Why Stage 1b exists, and the 40-of-45 post-condition**: told in `glab:manager` *Stage 1b — Analyze the plan* (a step that could not be built found only by a developer's whole run; a check expecting 40 patterns, exactly what a tree with one step skipped produces). Pointed at, not copied.
- **A regex prefixed a path**: porting the user's edits, the substitution that put `glab:` back turned `plan/{slug}/plan.md` into `plan/{slug}/glab:plan.md` in two manager lines; it was caught by checking that every `/glab:` has a backtick before it, and fixed before the change was installed (`sync-local-edits` `result.md`, *Stages*).
- **One review verdict set, stated four times**: the model-switch review fix named the three last-round verdicts in Rule 5 against its own D22, so the set was then stated in Rule 5, Stage 5, `ship.md` and `reviewer.md` with no *One fact* case (`feature-model-switch` `result.md`, *Tension with the plan*). `AGENTS.md` now lists the reviewer's verdict lines as a known case.

## Records

- 2026-10-16 · sync-local-edits · the user's local edits of 2026-10-08 ported into `glab` (risk tiers, Rule 3 decisions, Rule 4 surfaces), then twelve consistency fixes; two reopened, seven new found · change 5f69d65 70166f4 · records 0dec5e2 9700bcb · plan: `git ls-tree -r --name-only 9700bcb -- plan/sync-local-edits/` (one file: `git show 9700bcb:plan/sync-local-edits/<file>`)
  - [sync-local-edits/follow-ups.md L58] After the review of the follow-up fixes (2026-10-16) → `[sync-local-edits/follow-ups.md 7]` and `[sync-local-edits/follow-ups.md 10]` reopened, `[sync-local-edits/follow-ups.md 3]` corrected, new `13`–`19`, all under their tags above.
  - [sync-local-edits/result.md L215] Follow-ups → none written; the contradictions it reported were decided in its second set, `[sync-local-edits/result.md decisions]`; nothing open.
  - [sync-local-edits/result.md L219] Not done → the UNVERIFIED that the local edits are exactly the 2026-10-08 change, under *Known limits*; no commit was its step.
- 2026-10-16 · feature-model-switch · `glab:manager` Rule 5: the user names the model of the developer or the reviewer, passed per dispatch, recorded, shown in each handoff, the dispatch written for it · change 1f12a37 · records 889b804 · plan: `git ls-tree -r --name-only 889b804 -- plan/feature-model-switch/` (one file: `git show 889b804:plan/feature-model-switch/<file>`)
  - [feature-model-switch/result.md L96] Follow-ups → nothing open ("None").
  - [feature-model-switch/result.md L100] Not done → the commit split: done (`1f12a37`, `889b804`); `[feature-model-switch/plan.md I1]` and `[feature-model-switch/plan.md I4]`, with the unchecked doc citations, under *Known limits*.
- 2026-10-05 · bug-reviewer-findings · recorded in `docs/specs/memory-sync.md`; its workflow items (questions Q3, Q7, Q10; follow-ups 16, 18, 19; two open items from its result files) are tagged above · plan: `git ls-tree -r --name-only 2aeb46d -- plan/bug-reviewer-findings/` (one file: `git show 2aeb46d:plan/bug-reviewer-findings/<file>`)
