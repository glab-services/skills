# flow-master-plan — evidence

The findings of this plan, split out of `plan/flow-planner/evidence.r2.md` in round 3. F3 and F11 are round 1's and round 2's text, F10, F12–F16 round 2's, each byte for byte; F0 and *Boundary* are rewritten for this plan's part, B5–B12 byte for byte but B8's "D9", now `[flow-planner/plan.md D9]`. F3 and F14 are cited by both plans and are in both files; F11 is here whole, byte for byte, and `plan/flow-planner/evidence.md` keeps only its own part of it. F1, F2 and F4–F9, and the F6 that F14 compares with, are in `plan/flow-planner/evidence.md`. Line numbers are at `cf614ec`, before `flow-planner`; `plan.md` says how they are re-resolved.

### F0 Scope — every path

Base: the tree `flow-planner` leaves on `origin/main` (`glab` 0.10.0); written at `cf614ec`, with only `plan/` untracked.
Changed: `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/plan.md`, `plugins/glab/commands/analyze.md`, `plugins/glab/commands/develop.md`, `plugins/glab/scripts/manager-bootstrap.sh` (one word group in its quoted heredoc), `README.md`, `AGENTS.md`, `plugins/glab/.claude-plugin/plugin.json`.
Read, unchanged: `plugins/glab/agents/reviewer.md`, `commands/review.md`, `commands/ship.md` (the reviewer stays blind: F10), `commands/integrate.md` and `agents/integrator.md` (`plan/$ARGUMENTS/` takes a sub-plan path as it is: F16), `agents/committer.md`, `commands/push.md`, `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/bootstrap/SKILL.md` (l. 62–66, 102), `plugins/glab/skills/audit/SKILL.md`, `.claude-plugin/marketplace.json`; `flow-planner`'s `skills/plan-first/implement.md`, `scripts/context-size.sh` and `tests/context-size.test.sh`.
Specs read: `docs/specs/workflow.md` (*Decisions that still bind* by search, *Incidents*, the I1 description l. 349–364); `docs/specs/marketplace.md` by search.

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
