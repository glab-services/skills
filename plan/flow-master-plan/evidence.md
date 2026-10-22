# flow-master-plan — evidence

The findings of this plan, split out of `plan/flow-planner/evidence.r2.md` in round 3. F3 and F11 are round 1's and round 2's text, F10, F12 and F14–F16 round 2's, each byte for byte; F0 and F13 were amended after this plan's check round 1, which F17 and F18 record; F0 and *Boundary* are rewritten for this plan's part, B5–B12 byte for byte but B8's "D9", now `[flow-planner/plan.md D9]`. F3 and F14 are cited by both plans and are in both files; F11 is here whole, byte for byte, and `plan/flow-planner/evidence.md` keeps only its own part of it. F1, F2 and F4–F9, and the F6 that F14 compares with, are in `plan/flow-planner/evidence.md`. Line numbers are at `cf614ec`, before `flow-planner`, except in F0, F13, F17 and F18, which are at `28f7d1d`.

### F0 Scope — every path

Base: the tree `flow-planner` left on `origin/main`, `28f7d1d` (`glab` 0.10.0); written at `cf614ec`, amended at `28f7d1d`, with only `plan/` untracked.
Changed: `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/plan.md`, `plugins/glab/commands/analyze.md`, `plugins/glab/commands/develop.md`, `plugins/glab/scripts/manager-bootstrap.sh` (one sentence in its quoted heredoc), `plugins/glab/skills/bootstrap/SKILL.md` (step 4), `plugins/glab/skills/audit/SKILL.md` (l. 70), `plugins/glab/skills/plan-first/implement.md` (l. 3), `tests/context-size.test.sh` (the T19 comment, l. 335), `README.md`, `AGENTS.md`, `plugins/glab/.claude-plugin/plugin.json`.
Read, unchanged: `plugins/glab/agents/reviewer.md`, `commands/review.md`, `commands/ship.md` (the reviewer stays blind: F10), `commands/integrate.md` and `agents/integrator.md` (`plan/$ARGUMENTS/` takes a sub-plan path as it is: F16), `agents/committer.md`, `commands/push.md`, `plugins/glab/hooks/hooks.json`, `.claude-plugin/marketplace.json`; `flow-planner`'s `scripts/context-size.sh`.
Specs read: `docs/specs/workflow.md` (*Decisions that still bind* by search, *Incidents*, the I1 description l. 349–364, *Open follow-ups* l. 889–890 at `28f7d1d`); `docs/specs/marketplace.md` by search.

### F3 A `glab:planner` agent (inferred unless marked)

- Context: an agent body is its system prompt, the same tokens as the skill; the saving is the tool list (`*` for general-purpose versus five tools). Not measured.
- Content: plan-first stays a skill (`/glab:plan` runs it in the main session); an agent would restate Steps 0–4 or load the skill.
- Model and effort: planning agents take no `model` (`[feature-model-switch/plan.md D2]`), agent files set none (`D8`), no `effort:` key (`[subagent-effort/plan.md D6]`); the Agent tool's parameters work on any dispatch, so a file adds no control. Planner-on-Opus is `[flow-cheaper-rounds/follow-ups.md FUc]`.
- Facts: `Agents (5)` → 6 changes `AGENTS.md` *Gates*, `README.md` l. 9 and the *One fact* "what each plugin holds"; the analyzer split would change them again.
- The `findings.md` refusal (IN1) is not shown to depend on the agent type.

### F10 The analyzer's and the reviewer's contracts (proven by reading)

- `agents/analyzer.md` (94 lines) defines the conformance check (Steps 1–4), *Re-checks* and the record check; its verdicts are `CONFORMS`, `DIVERGES: <n> steps`, `BLOCK: target unresolved` (l. 82–86). It has **no plan-check section**: `grep -rn BUILDABLE plugins` finds only `manager/SKILL.md` l. 176, 336, 342 and `plan-first/SKILL.md` l. 95. The plan check's questions live in `manager/SKILL.md` Stage 1b (l. 297–334).
- `commands/analyze.md` l. 12: "This step asks one question: **did we build the thing the plan said?**"
- Stage 3 runs at full tier only (`manager/SKILL.md` l. 201, 385); at normal tier `result.md` is the conformance record.
- The reviewer: `grep -n 'plan\|slug\|intent' agents/reviewer.md commands/review.md commands/ship.md` finds only the round lines (`reviewer.md` l. 97, `ship.md` l. 32), which name the target, the previous findings and the range. Stage 5 (l. 415) gives it "not the slug, not the plan, not the findings, not what the plan intended". Nothing to change for a blind reviewer.

### F11 Binding decisions this plan meets (`docs/specs/workflow.md` *Decisions that still bind*)

- Kept as they are: `[feature-model-switch/plan.md D5]` (the reviewer's target-only brief), `[flow-cheaper-rounds/plan.md D51]` (a later review round: a new reviewer, the findings and the range), `D8` (no findings file by the manager, analyzer or reviewer), `D7` (every round a new agent), `D15` (map files are `map-<area>.md` because `findings…` is refused — the same refusal now renames the plan's own file), `[feature-docs-specs/plan.md U2]`, `D3` and `[sync-local-edits/result-followups.md D10]` (no `glab` step removes a plan folder; the repo's rule removes it after landing — `git status -- plan/<slug>/` and `git diff --quiet origin/main -- plan/<slug>/` take the sub-plan folders with it, inferred from git's pathspec semantics).
- Extended, not changed: `[flow-cheaper-rounds/plan.md D10]` (round copies `<name>.r<n>.md` beside their file: now also `master.r<n>.md`, `index.r<n>.md`, and per sub-plan folder) and `D2` (the round caps: now per sub-plan, and for the final check).
- Amended, named: `[sync-local-edits/result-followups.md D5]` ("`/glab:integrate` runs after `/glab:analyze` at full tier and after `/glab:develop` at normal") — a sub-plan runs Stage 3 at every tier, so Stage 4 follows Stage 3 there; a normal-tier plan with no sub-plans keeps D5. Full-tier approval moves from before Stage 1b to after it (`manager/SKILL.md` l. 282 → after the first `BUILDABLE`), so the user approves a checked plan.
- `[flow-cheaper-rounds/plan.md D27]` (one commit with the plan folder) bound that change; a slug with sub-plans now commits once per sub-plan (`plan.md` D30).

### F12 Claude Code's plan mode (research relayed by the manager; nothing run here)

From a `claude-code-guide` agent reading code.claude.com/docs (permission-modes, settings-reference, hooks, sub-agents, desktop), relayed in this dispatch — **inferred** here, not re-fetched:

- entered by Shift+Tab, `--permission-mode plan`, `/plan`, or `permissions.defaultMode`; an `EnterPlanMode` tool exists for the main session (in the manager's tool list; not in the docs: UNVERIFIED);
- left through `ExitPlanMode`, which "presents a plan and asks the user to approve it"; the user approves into auto, acceptEdits or manual, chooses "No, keep planning", or presses Ctrl+G to edit the plan;
- the plan is a file, `~/.claude/plans` by default, moved by `plansDirectory` (relative to the project root); its file name is UNVERIFIED; whether `ExitPlanMode` takes the plan as text or only from that file is UNVERIFIED;
- edits are blocked in plan mode until approval;
- `EnterPlanMode` is removed from every subagent, `ExitPlanMode` too unless the subagent's `permissionMode` is `plan`; `permissionMode` frontmatter is ignored for plugin agents — so only the main session can use plan mode;
- a `PreToolUse` matcher can name `ExitPlanMode`; hook input `permission_mode` can be `plan`;
- which source the desktop Plan pane shows: UNVERIFIED.

This subagent has neither tool (its tool list was read at start): consistent with the relayed claim, not a proof of it. Whether a subagent dispatched while the main session is in plan mode is blocked from writing is UNVERIFIED (L5). Every UNVERIFIED point is a live test in `plan.md` *Live tests*.

### F13 Where the stage sequence is listed (proven by search)

`grep -rn 'review -> commit\|review → commit\|commit → push\|integrate → review' plugins README.md AGENTS.md` → `manager/SKILL.md` l. 3 (description: "… → review → commit → push → record") and `scripts/manager-bootstrap.sh` l. 17 ("… -> review -> commit -> push -> record at full tier"). The script's text is a quoted heredoc (`read -r -d '' CTX <<'CTX_EOF'`, l. 11) of 2372 characters (`awk` between the markers `| wc -m`), against the 10,000-character cap its header names.

At `28f7d1d` that search misses a third listing: `plugins/glab/skills/bootstrap/SKILL.md` step 4, l. 95, `plan ⇄ analyze  →  develop ⇄ analyze  →  integrate  →  review ⇄  →  commit  →  push  →  record`, with two spaces each side of each arrow (`cat -A`), and its bullets l. 105–118, none of which names a final check. `AGENTS.md` l. 133–134 ties the script to that skill: "the session-start rules (the text in `plugins/glab/scripts/manager-bootstrap.sh` and the `glab:bootstrap` skill)". The script's "at full tier" (l. 17) would be untrue beside a final check, which a single full-tier plan skips (D33).

### F14 Baseline gates, round 2 (proven, `cf614ec`, `TMPDIR` exported, output to a log under it)

    five "<path> rc=0" lines; shellcheck rc=0; PASS 35/35; PASS 21/21
    ✔ Validation passed ×3
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab; memory-sync = memory-sync
    hooks.json :0 :0 rc=1; 'not yet confirmed' 1 1 1 rc=0; prefixed name: no line rc=1

As F6, plus the CLI's own `(harness-only — no model context cost)` after each `Hooks` line, which `AGENTS.md`'s green list does not mention and its `grep -E '^  (Skills|Agents|Hooks) '` keeps. Log and config directory removed (`ls "$TMPDIR" | grep -c 'fp2-\|claude-config'` → `0`).

### F15 Commits and the version rule (proven by reading `AGENTS.md`)

*Rules*: "A change under `plugins/<name>/` raises that plugin's `version` … in the same commit. An installed copy is pinned to the version string: without a new one nobody receives the change." Read literally, several commits of one slug that each touch `plugins/glab/` would each raise it. The reason given is what an installer receives, which is a push, not a commit (inferred). *One fact*: "A number or name stated in more than one file changes in all of them in the same commit" — so a sub-plan boundary must not cut through such a fact.

### F16 A sub-plan path through the commands (inferred from the command text)

`commands/analyze.md` l. 6, `develop.md` l. 6, `integrate.md` l. 6 put `$ARGUMENTS` into `plan/$ARGUMENTS/`; with `<slug>/<nn>-<name>` that is the sub-plan's folder, and every `plan/<slug>/plan.md` in the agents' text reads as that folder's `plan.md`. That the argument substitution keeps a `/` unchanged is inferred (no command was run here). The master is then one level up, which each reader is told explicitly.

### F17 Plan check round 1, resolved at `28f7d1d` (proven by reading)

- `agents/analyzer.md` l. 20: "No `plan.md` → stop and report `BLOCK: target unresolved`." l. 89: "Name the plan revision you measured against — `git log -1 --format=%h -- plan/<slug>/plan.md`, or "untracked"". l. 16 reads "every `plan/<slug>/map-<area>.md`" and l. 24 runs `git status --short -uall`, which lists untracked files in sibling sub-plan folders. A master check or a final check has no `plan.md` (D35).
- `skills/manager/SKILL.md` l. 340 copies `plan.md` and `evidence.md` only; l. 342: "`cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and the same for `evidence.md`, or `findings.md` in a folder from before `glab` 0.10.0)", where "exit 2 means a file is missing". `grep -c 'findings\.md\|findings\.r<n>'` → `2` (l. 340, 342). l. 276: "`glab:plan-first` Step 3 caps `plan.md` and `evidence.md` at 49152 bytes (48 KB) each." l. 199: `| Approval | — | none — report the tier and the decisions, then go | the user's, explicit |`.
- `skills/plan-first/SKILL.md` l. 97 states `NOT BUILDABLE`; l. 101: "Read it once the plan is verified (Step 4) and, at full tier, approved."; l. 122: "Then implement, from [`implement.md`](implement.md)." `skills/plan-first/implement.md` l. 3: "Start them only once the plan is verified (Step 4) and, at full tier, approved." — the follow-up `[flow-planner/record.md review-waiver-implement]` (`docs/specs/workflow.md` l. 889).
- `tests/context-size.test.sh` l. 335: "# T19 stop never blocks or continues - judged over every stop run above, T20's and T21's included". `stopouts` is fed by `stop_case` (l. 220), which T18, T20, T21 and T23 reach through `stop_spec`, and by T24 directly (l. 323) — the follow-up `[flow-planner/record.md review-t19-comment]` (l. 890).
- `commands/analyze.md` l. 16: "- `CONFORMS` → go to `/glab:integrate`."; no `BUILDABLE` line. `commands/develop.md` l. 39, "the slug, and the exact step ids it owns;", is under *Dispatch* (l. 35). `skills/audit/SKILL.md` l. 70: "its plan's `## Record` names it".
- The plan-mode claims of S2 and S8 that F12 holds inferred or UNVERIFIED, with the live test that settles each: the dialog carries the approval and takes the plan as text (L1); where the plan file lands, and `plansDirectory` (L2); "No, keep planning" and Ctrl+G (L3); the permission mode after approval (L4); edits blocked in plan mode, a subagent's too (L5); leaving it by Shift+Tab (L3); no plan-mode tools in a subagent (L7).

### F18 The presence searches at `28f7d1d` (proven, run)

Each S1–S10 search as `git show 28f7d1d:<file> | grep -c <search>`, by a throwaway script under `$TMPDIR`, removed after. Count, file under `plugins/glab/` (or from the root), search. Every presence search prints `0`; the non-zero lines are the paired `→ 0` searches, at `1`, and the kept invariants.

    3	skills/plan-first/SKILL.md	evidence\.md
    1	skills/plan-first/SKILL.md	findings\.md
    0	skills/plan-first/SKILL.md	Normal tier writes `master.md` and one page
    0	skills/plan-first/SKILL.md	`## Record`, in `master.md` (below)
    0	skills/plan-first/SKILL.md	^### The master plan, and sub-plans
    0	skills/plan-first/SKILL.md	`master.md`, `plan.md`, `index.md` and `evidence.md` at or under **48 KB**
    0	skills/plan-first/SKILL.md	split it (below)
    0	skills/plan-first/SKILL.md	is never amended: a change to the request goes back to the user
    0	skills/plan-first/SKILL.md	the plan check has passed and `master.md` has its
    1	skills/plan-first/SKILL.md	the user has approved the plan
    0	skills/plan-first/SKILL.md	verified and approved (Step 4), or once a waiver is written
    1	skills/plan-first/SKILL.md	and, at full tier, approved
    0	skills/plan-first/SKILL.md	whose `master.md` — or `plan.md`, in a folder with no master — has no
    0	skills/plan-first/SKILL.md	the waiver stands in for the verified, approved plan
    0	skills/plan-first/SKILL.md	^| Intent | Request, goals, final check, record |
    0	skills/plan-first/SKILL.md	^| Verify | Plan review | the plan check, then the master's approval |
    1	skills/plan-first/SKILL.md	with the user, at full tier
    5	skills/plan-first/SKILL.md	^## Step [0-4] 
    2	skills/manager/SKILL.md	findings\.md\|findings\.r<n>
    0	skills/manager/SKILL.md	final check → push
    0	skills/manager/SKILL.md	Stages 1b, 2, 3, 5, 6b and 8
    0	skills/manager/SKILL.md	plan/{slug}/master.md`, and `plan.md` or `index.md` with sub-plan folders
    1	skills/manager/SKILL.md	user approval at full tier
    0	skills/manager/SKILL.md	; then the master's `## Approval`
    0	skills/manager/SKILL.md	^| 6b | Final check |
    0	skills/manager/SKILL.md	{slug}/02-hooks · analyze
    0	skills/manager/SKILL.md	— or sub-plans (*The master plan and sub-plans*)
    0	skills/manager/SKILL.md	^| Approval, after 1b | — | yours, reported — the user's when the work split |
    0	skills/manager/SKILL.md	| each sub-plan: max 2 rounds |
    0	skills/manager/SKILL.md	| `master.md`, `evidence.md`, `plan.md`
    0	skills/manager/SKILL.md	^| 6b Final check |
    0	skills/manager/SKILL.md	and the final check (Stage 6b) run at most
    0	skills/manager/SKILL.md	^## The master plan and sub-plans
    0	skills/manager/SKILL.md	sha256sum plan/{slug}/master.md
    0	skills/manager/SKILL.md	the slug-level `plan/{slug}/map-<area>.md` files its dispatch names
    0	skills/manager/SKILL.md	until all seven hold
    1	skills/manager/SKILL.md	until all six hold
    0	skills/manager/SKILL.md	^7\. \*\*A master\.\*\*
    0	skills/manager/SKILL.md	caps `master.md`, `plan.md`, `index.md` and `evidence.md` at 49152 bytes
    0	skills/manager/SKILL.md	Approval comes after Stage 1b has passed
    1	skills/manager/SKILL.md	At full tier, then get explicit approval
    0	skills/manager/SKILL.md	^### Approval in Claude Code.s plan mode
    2	skills/manager/SKILL.md	UNVERIFIED
    0	skills/manager/SKILL.md	then Stage 2 — or, after the master check, the sub-plans
    0	skills/manager/SKILL.md	Ask the intent question too
    0	skills/manager/SKILL.md	each copied as `<name>.r<n>.md` beside it
    0	skills/manager/SKILL.md	cmp -s plan/{slug}/<name>.r<n>.md plan/{slug}/<name>
    1	skills/manager/SKILL.md	cmp -s plan/{slug}/plan.r<n>.md
    0	skills/manager/SKILL.md	Exit 1 on any file
    0	skills/manager/SKILL.md	Full tier, and every sub-plan at every tier
    0	skills/manager/SKILL.md	the intent question waits for the final check
    0	skills/manager/SKILL.md	build past its plan
    0	skills/manager/SKILL.md	Nothing is pushed before the final check
    0	skills/manager/SKILL.md	^## Stage 6b — Final check
    0	skills/manager/SKILL.md	Show the `## Decisions` lines of each plan the push carries
    1	skills/manager/SKILL.md	the plan's `## Decisions` lines
    0	skills/manager/SKILL.md	`master.md`'s `## Record` names — `plan.md`'s, with no master —
    0	skills/manager/SKILL.md	from the folder's files, sub-plan folders included
    0	skills/manager/SKILL.md	whose `master.md` — or `plan.md`, with no master — has no
    0	skills/manager/SKILL.md	`<slug> final`
    0	skills/manager/SKILL.md	Give the reviewer the plan, `master.md` or `index.md`\.
    0	skills/manager/SKILL.md	or enter plan mode the user did not ask for
    0	agents/analyzer.md	ending in BUILDABLE, NOT BUILDABLE, CONFORMS or DIVERGES
    0	agents/analyzer.md	whether it serves what the user asked for
    0	agents/analyzer.md	anything but `OK` is a finding rated `high`
    0	agents/analyzer.md	at the slug's level, a level up for a sub-plan
    0	agents/analyzer.md	except in a master check or a final check (below)
    0	agents/analyzer.md	is not your implementation
    0	agents/analyzer.md	^## The intent question
    0	agents/analyzer.md	a folder from before `glab` 0.11.0
    0	agents/analyzer.md	^## The plan check
    0	agents/analyzer.md	^## The final check
    0	agents/analyzer.md	NOT BUILDABLE
    0	agents/analyzer.md	sha256sum -c
    0	agents/analyzer.md	`plan.md`, `evidence.md`, `master.md`, `index.md`
    0	agents/analyzer.md	its sub-plan folders included
    0	agents/analyzer.md	^- `BUILDABLE` — a plan check
    0	agents/analyzer.md	of `master.md` and `index.md` in a master check or a final check
    1	agents/analyzer.md	rather than replacing it in place
    1	agents/analyzer.md	findings\.md
    0	agents/developer.md	Context, not scope
    0	agents/developer.md	where the slug.s map files are
    0	agents/developer.md	master\.sha256
    0	agents/developer.md	those `master.md`'s `## Record` names
    0	agents/developer.md	sub-plan folders included
    1	agents/developer.md	^## Keep your context small
    5	agents/developer.md	^## Step [1-5] 
    2	agents/developer.md	findings\.md
    0	commands/plan.md	a split into sub-plans, need my approval
    0	commands/plan.md	the goals, the sub-plans when the work split
    0	commands/analyze.md	The slug may name a sub-plan
    0	commands/analyze.md	intent question
    1	commands/analyze.md	asks one question
    0	commands/analyze.md	^- `BUILDABLE` → a plan check passed
    0	commands/analyze.md	^- `NOT BUILDABLE` → stop and show me the findings
    0	commands/analyze.md	after the final check, to `/glab:push`
    0	commands/develop.md	its `master.md` is a level up
    0	commands/develop.md	sha256sum -c
    0	commands/develop.md	With none
    0	commands/develop.md	^- the paths of `master.md` and of the plan folder
    0	scripts/manager-bootstrap.sh	commit -> final check -> push -> record, as far as the tier runs them
    1	scripts/manager-bootstrap.sh	record at full tier
    0	skills/bootstrap/SKILL.md	commit  →  final check  →  push  →  record
    0	skills/bootstrap/SKILL.md	skips the final check, which its conformance check asked
    0	skills/bootstrap/SKILL.md	no conformance stage unless it splits into sub-plans
    0	skills/bootstrap/SKILL.md	Full tier, and every sub-plan at every tier
    0	skills/bootstrap/SKILL.md	\*\*`final check`\*\*, then \*\*`push`\*\*
    1	README.md	findings, plan, results
    0	README.md	your request in your words
    0	README.md	approve `master.md` in Claude Code's plan mode
    0	README.md	the live tests L1–L7 in `docs/specs/workflow.md`
    0	README.md	never changes `plansDirectory`
    0	skills/audit/SKILL.md	`master.md`'s, where there is one
    0	AGENTS.md	raises it, once
    0	AGENTS.md	final check (Stage 6b)
    0	AGENTS.md	48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`
    0	AGENTS.md	master.sha256
    0	AGENTS.md	the intent check — the analyzer at Stage 1b
    0	AGENTS.md	the analyzer's verdict lines
    0	AGENTS.md	its claims UNVERIFIED until L1–L7
    0	AGENTS.md	the stage sequence with the final check
    0	skills/plan-first/implement.md	verified and approved (`glab:plan-first` Step 4), or once
    1	skills/plan-first/implement.md	at full tier, approved
    0	tests/context-size.test.sh	T23's through stop_case, and T24's own
    1	tests/context-size.test.sh	T20's and T21's included
    version 0.10.0
    48KB files: AGENTS.md plugins/glab/skills/manager/SKILL.md plugins/glab/skills/plan-first/SKILL.md 
    findings.md counts: AGENTS.md:1 plugins/glab/agents/analyzer.md:1 plugins/glab/agents/developer.md:2 plugins/glab/skills/manager/SKILL.md:2 plugins/glab/skills/plan-first/SKILL.md:1 

### Boundary

Chosen: the master/sub-plan layout in `glab:plan-first` (the planner's owner); the cycle, the approval, plan mode and the final check in `glab:manager`; the intent question and the plan check in `glab:analyzer`'s own file. B1–B4 are `flow-planner`'s. Rejected:
- B5 The master as a section of `plan.md`: `plan.md` is amended in place round after round, so a section of it cannot be hashed, and a sub-plan agent would read the whole plan to reach it.
- B6 The split table inside `master.md`: the split is an engineering choice that amendments change; inside the master it would make the constant file change, or freeze the split.
- B7 One commit per slug with sub-plans: the blind reviewer reviews the working tree, so sub-plan 2's review would see sub-plan 1's uncommitted change, and the next analyzer's delta would mix the two.
- B8 Two analyzer agents now: the agent count should change once, with the planner agent, in `flow-models-per-role` (F3, `[flow-planner/plan.md D9]`).
- B9 The master to the reviewer: the user's decision — "review agent must only check the code itself without any plan".
- B10 A `PreToolUse` hook on `ExitPlanMode` to record the approval: it runs in every repo with `glab`, cannot tell a glab master from any plan, and the approval is the manager's record.
- B11 `chmod a-w master.md` to keep it constant: how Write and Edit treat a read-only file is unproven, and the hash proves constancy either way.
- B12 Stage 3 at normal tier for a single plan: a second analyzer on every small task, for the question the final check asks once.
