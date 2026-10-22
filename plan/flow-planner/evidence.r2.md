# flow-planner — evidence

The findings of this plan. The file is `evidence.md`, not `findings.md`: F8 shows why. F1–F7 are round 1's, carried byte for byte from `plan.r1.md` *Findings*; F0 and *Boundary* are replaced in place for round 2; F8–F16 are new.

### F0 Scope — every path

Base `cf614ec`, only `plan/` untracked (`git status --short -uall` → `?? plan/SESSION-HANDOFF.md`, `?? plan/flow-planner/plan.md`, and `plan.r1.md` once kept).
Changed: `plugins/glab/skills/plan-first/SKILL.md`, new `plugins/glab/skills/plan-first/implement.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/plan.md`, `plugins/glab/commands/analyze.md`, `plugins/glab/commands/develop.md`, `plugins/glab/scripts/context-size.sh`, `plugins/glab/scripts/manager-bootstrap.sh` (one word group in its quoted heredoc), `tests/context-size.test.sh`, `README.md`, `AGENTS.md`, `plugins/glab/.claude-plugin/plugin.json`.
Read, unchanged: `plugins/glab/agents/reviewer.md`, `commands/review.md`, `commands/ship.md` (the reviewer stays blind: F10), `commands/integrate.md` and `agents/integrator.md` (`plan/$ARGUMENTS/` takes a sub-plan path as it is: F16), `agents/committer.md`, `commands/push.md`, `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/bootstrap/SKILL.md` (l. 62–66, 102), `plugins/glab/skills/audit/SKILL.md`, `.claude-plugin/marketplace.json`.
Specs read: `docs/specs/workflow.md` (*Decisions that still bind* by search, *Open follow-ups* FU6, *Incidents*, the I1 description l. 349–364); `docs/specs/marketplace.md` by search.

### F1 Plan length (proven)

    git show 2a1e919:plan/flow-cheaper-rounds/plan.md | wc -l     → 1056
    plan.r1 / r2 / r3 / final, lines/bytes                         → 522/58932, 787/104420, 920/126945, 1056/155371
    its ## Decisions: 68 "- " lines, mean 563 chars, 40 over 400, 11 over 800; 38520 bytes
    "Superseded" → 4; "*(round n …)*" markers → 11; "amend" (any case) → 39

The plan nearly tripled over three amendments, and its one-line decisions were paragraphs restating evidence. The o3 figures (plans of 441–849 lines; F4's developer) are the caller's measurements of another project: inferred here.

Where a rule can sit: `plan-first/SKILL.md` Step 3 (l. 67–81) says what a plan holds, nothing on size; Step 4's amending paragraph (l. 95) and `manager/SKILL.md` Stage 1b (l. 338) say "record(s) each changed choice under `## Decisions`", silent on the old text. The acceptance checklist (l. 266–276) says "until all five hold" (l. 268); `grep -rn "all five\|five hold" plugins README.md AGENTS.md` finds only that line. `agents/analyzer.md` *Re-checks* (l. 54–60) reads the `diff -u` of `plan.r<n>.md` against `plan.md`: the one reader that sees appended text.

### F2 plan-first's structure and callers (proven)

`SKILL.md`, 193 lines, 13291 bytes: Steps 0–4 (l. 14, 21, 57, 67, 83; amending l. 95); **Step 5 (97–128), Step 6 (130–141), Step 7 (143–147)**; *Repo Rules* (149): Service lifecycle (151–153), Nested repositories (155–156), Commits (158–161) — implementation and commit only — then Plan files are working files (163), One slug per task (165); Slug Naming (167), User Override (178), Quick Reference (182). Lines 97–161: 3708 bytes, 28 % of the file.

Callers (`grep -rn plan-first plugins README.md AGENTS.md`, and a search for step numbers):

| caller | relies on |
|---|---|
| `commands/plan.md` l. 6, 12, 13, 16 | loads it; "step 0", "Step 2", the waiver |
| `commands/develop.md` l. 2, 13, 54 | "glab:plan-first steps 5 to 7"; the waiver; "owns the command" (build, Step 5) |
| `manager/SKILL.md` l. 53–60, 272, 338, 439 | Rule 0c seam; "Step 1"; Stage 1b amendment; *Plan files are working files* |
| `bootstrap/SKILL.md` l. 64–66 | per-dispatch, and the seam |
| `agents/developer.md` l. 102 | *Plan files are working files*; does not load the skill |
| `audit/SKILL.md` l. 21, 69 | the workflow that runs on to implementation |
| `README.md` l. 9, 135; `AGENTS.md` *One fact* | the name and the file |

No caller names a step above 4 but `develop.md`'s "steps 5 to 7"; keeping 5–7 on the moved text keeps it true. Their substance is restated where a manager pipeline runs them: `developer.md` Steps 2–4 (l. 24–64), `integrator.md` Step 2. A session that implements without subagents still needs them.

A supporting file changes neither validation nor counts (proven: throwaway copy with `implement.md` added, fresh `CLAUDE_CONFIG_DIR`): `✔ Validation passed` for `plugins/glab` and `.`, `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`, `Agents (5)`. Observed in this session: the Skill tool put only `SKILL.md` and a "Base directory for this skill" line into context; that a sibling file costs nothing until read is inferred for other versions.

### F3 A `glab:planner` agent (inferred unless marked)

- Context: an agent body is its system prompt, the same tokens as the skill; the saving is the tool list (`*` for general-purpose versus five tools). Not measured.
- Content: plan-first stays a skill (`/glab:plan` runs it in the main session); an agent would restate Steps 0–4 or load the skill.
- Model and effort: planning agents take no `model` (`[feature-model-switch/plan.md D2]`), agent files set none (`D8`), no `effort:` key (`[subagent-effort/plan.md D6]`); the Agent tool's parameters work on any dispatch, so a file adds no control. Planner-on-Opus is `[flow-cheaper-rounds/follow-ups.md FUc]`.
- Facts: `Agents (5)` → 6 changes `AGENTS.md` *Gates*, `README.md` l. 9 and the *One fact* "what each plugin holds"; the analyzer split would change them again.
- The `findings.md` refusal (IN1) is not shown to depend on the agent type.

### F4 A developer's context (proven by reading; o3 inferred)

`developer.md` Step 1 (l. 11–22) reads the contract with no "once"; Step 3 (l. 42–56) says nothing of output size; Step 5 (l. 66–94) wants the exact command and outcome. `commands/develop.md` has no such rule; `manager/SKILL.md` Rule 2 (l. 90) is about the reply. o3: one developer peaked at 509k in one round, ~480k chars of tool output, ~305k of its own writes, `plan.md` read 3 times.
Enforceable? Prose only. UNVERIFIED: that a `PostToolUse` hook can shorten a built-in tool's output, and whether hooks fire inside a subagent and with which `transcript_path`. `BASH_MAX_OUTPUT_LENGTH` is a session-wide user setting, not the plugin's (inferred).

### F5 The first context step (proven by run)

`context-size.sh`: header l. 11–15, contract l. 23–29, the line l. 113, `stop` l. 122–145, `300000` at l. 140–141. The test's `run` (l. 24–33) runs `bash "$SCRIPT"`, so exported variables reach it; `stop_case` (l. 211–226) expects `glab: context ${want}k (last completed call)$MSG_TAIL` and appends to `stopouts`, judged by T19 (l. 284–289); T2 last (l. 291–293). Binding: `[flow-cheaper-rounds/plan.md D34]`, `D45`, `D46`, `D47`. The user, 2026-10-20 (session memory): "300k will be our work limit, it will be my hard compact limit for all future models"; on a smaller window, ask the user for the number.

Prototype (throwaway copy; the variable read after the transcript; fixture 140k, 145k, 160k):

    []        agent "glab: context 160k (last completed call)"; stop nothing
    [150]     agent "glab: context 160k (last completed call; compact at 150k)"
              stop {"systemMessage":"glab: context 160k (last completed call; compact at 150k) — a good point to /compact, or to /clear between tasks"}
    [abc] [0] [1234567]  stderr "glab context-size: GLAB_COMPACT_AT is not a whole number of thousands from 1 to 999999; using 300", stdout the default line
    all rc=0; bash -n and shellcheck on the copy rc=0

Inferred: a variable exported in the shell that starts Claude Code reaches its hooks (child processes). UNVERIFIED: that a settings file's `env` block does.

### F6 Baseline gates at `cf614ec` (proven)

Five `rc=0` lines; shellcheck `rc=0`; `PASS 35/35`; `PASS 21/21`; `✔ Validation passed` ×3; glab `Skills (14)`, `Agents (5)`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`; memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`; `glab = glab`, `memory-sync = memory-sync`; `:0` `:0` `rc=1`; `1` `1` `1` `rc=0`; no line `rc=1`.

### F7 `flow-models-per-role`: keep it separate (recommendation)

A model table as a default reverses Rule 5's "no instruction, no override" and `[feature-model-switch/plan.md D1]`, `D2`, `D8` — a question for the user that would stop this plan, which has none. Its analyzer split changes the agent count, and the planner agent belongs with it (F3). Merged, the plan would break the budget it introduces. Run this plan first: its rules hold on any model.

### F8 The findings file name — probe (proven, this subagent, round 2)

Write tool, each a one-line file `probe`, in this order:

    plan/flow-planner/findings.md            → refused: "Subagents should return findings as text, not write report files. Include this content in your final response instead."
    plan/flow-planner/evidence.md            → "File created successfully"
    plan/flow-planner/master.md              → "File created successfully"
    plan/flow-planner/01-probe/plan.md       → "File created successfully"
    plan/flow-planner/01-probe/evidence.md   → "File created successfully"
    plan/flow-planner/index.md               → "File created successfully"
    plan/flow-planner/evidence.r1.md         → "File created successfully"

Each accepted file was shown (`cat` → `probe`) and removed (`rm -f`, `rmdir 01-probe`); `ls -A plan/flow-planner` → `plan.md`, `plan.r1.md`. The refusal is the fifth (`docs/specs/workflow.md` *Incidents*; `[flow-cheaper-rounds/plan.md D15]` names the third). Inferred: the refusal keys on the name, not the directory or the agent type — `map-probe.md` was accepted in `flow-cheaper-rounds`, and every name here but `findings.md` was. Which other names the rule refuses is UNVERIFIED (`summary.md`, `report.md` not tried; none is proposed).

### F9 Who names `findings.md` (proven by search)

`grep -rn 'findings\.md\|findings file' plugins README.md AGENTS.md`:

    plan-first/SKILL.md:23   "Write findings to `plan/{slug}/findings.md`"
    plan-first/SKILL.md:186  Quick Reference row `plan/{slug}/findings.md`
    agents/developer.md:17   reads `plan/<slug>/findings.md`
    agents/developer.md:107  never edits `findings.md`
    agents/analyzer.md:16    reads `plan/<slug>/findings.md`
    agents/analyzer.md:56    re-check pair `findings.r<n>.md` with `findings.md`
    manager/SKILL.md:53, 175, 197, 338, 340   Rule 0c, pipeline row 1, tier table, Stage 1b copy and `cmp`
    manager/SKILL.md:92      "a findings file" — prose, not the name
    manager/SKILL.md:262     why map files are not `findings-<area>.md` — a recorded reason, kept

`AGENTS.md` names no findings file; its mapping/round-copy *One fact* entry lists the same four payload files. Older plan folders hold `findings.md` (F11), so every reader keeps accepting it there.

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

Chosen: the size and shape rules and the master/sub-plan layout in `glab:plan-first` (the planner's owner); the cycle, the approval, plan mode and the final check in `glab:manager`; the intent question and the plan check in `glab:analyzer`'s own file; Steps 5–7 in a sibling file of plan-first; the developer's context rules in the developer's file; the threshold read inside the script from the environment. Rejected:
- B1 Steps 5–7 into `glab:developer`: a session implementing without subagents loses them, and "steps 5 to 7" points at nothing.
- B2 A `glab:implement` skill: `Skills (14)` → 15 in four files for text few sessions read.
- B3 A `PreToolUse` hook refusing an oversized `plan.md`: fires in every repo with `glab` enabled and stops a planner mid-write.
- B4 A per-model table or a fraction of the window for the threshold (D13).
- B5 The master as a section of `plan.md`: `plan.md` is amended in place round after round, so a section of it cannot be hashed, and a sub-plan agent would read the whole plan to reach it.
- B6 The split table inside `master.md`: the split is an engineering choice that amendments change; inside the master it would make the constant file change, or freeze the split.
- B7 One commit per slug with sub-plans: the blind reviewer reviews the working tree, so sub-plan 2's review would see sub-plan 1's uncommitted change, and the next analyzer's delta would mix the two.
- B8 Two analyzer agents now: the agent count should change once, with the planner agent, in `flow-models-per-role` (F3, D9).
- B9 The master to the reviewer: the user's decision — "review agent must only check the code itself without any plan".
- B10 A `PreToolUse` hook on `ExitPlanMode` to record the approval: it runs in every repo with `glab`, cannot tell a glab master from any plan, and the approval is the manager's record.
- B11 `chmod a-w master.md` to keep it constant: how Write and Edit treat a read-only file is unproven, and the hash proves constancy either way.
- B12 Stage 3 at normal tier for a single plan: a second analyzer on every small task, for the question the final check asks once.
