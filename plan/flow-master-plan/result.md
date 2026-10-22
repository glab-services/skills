# Result — flow-master-plan

`glab` 0.10.0 → 0.11.0, built on HEAD `28f7d1d` (= `origin/main`). Nothing committed, staged or pushed.

## Stages

Line numbers are in the edited tree (`git diff -U0` hunk starts, `+line,count`).

- B0 — done. `origin/main` version `0.10.0`; `implement.md` line 1 `# Plan First — implementation`; only `plan/` untracked; baseline gates as F14 with `PASS 35/35`, `PASS 24/24`.
- S1 `plugins/glab/skills/plan-first/SKILL.md` — done: :19 (Step 0), :79 (`## Record` bullet), :83 (size paragraph), :84–100 (new section *The master plan, and sub-plans when the work splits*), :108 (Step 4 list item), :114 (amending paragraph), :118 (*Steps 5 to 7*), :122 (*Plan files are working files*), :139 (*User Override*), :145 (Intent row), :149 (Verify row).
- S2 `plugins/glab/skills/manager/SKILL.md` — done: :3 (description), :91 (Rule 2), :176–177 and :183 (pipeline table rows 1, 1b, 6b), :189–190 (sub-plan handoff line), :201–202, :205, :208 (tier table: row 1, Approval, row 3, row 6b), :212 (*Round caps*), :216–226 (*The master plan and sub-plans*), :284 (all seven), :291–292 (item 6 and item 7), :300–309 (approval paragraph and *Approval in Claude Code's plan mode*), :363–365 (intent paragraph and `BUILDABLE` routing), :367 (amendment copies), :369 (`cmp -s` per file, exit codes).
- S3 `plugins/glab/skills/manager/SKILL.md` — done: :266 (`<slug> final`), :414 (Stage 3 tier and intent wait), :418 (intent question), :458–459 (Stage 6 sub-plan commits), :462–467 (*Stage 6b — Final check*), :470 (Stage 7 decisions), :478 and :483 (Stage 8 `## Record`), :491 (reviewer bullet), :499 (new never-do bullet).
- S4 `plugins/glab/agents/analyzer.md` — done: :3, :7, :15 (master bullet), :17 (map files), :21 (`BLOCK` exception), :31–32 (sibling sub-plan paragraph), :57–74 (*The intent question*, *The plan check*, *The final check*), :77 (*Re-checks* pairs), :90 (record check), :106–107 (`BUILDABLE`, `NOT BUILDABLE`), :112 (plan revision).
- S5 `plugins/glab/agents/developer.md` — done: :16 (master bullet), :19 (map files), :117 (record), :122 (never edit).
- S6 — done. `plugins/glab/commands/plan.md` :14, :18; `plugins/glab/commands/analyze.md` :10–11, :14, :18–20; `plugins/glab/commands/develop.md` :2, :6, :15, :40, :71.
- S7 — done. `plugins/glab/scripts/manager-bootstrap.sh` :17 (heredoc text only); `plugins/glab/skills/bootstrap/SKILL.md` :95, :99–103, :109–110, :116–119.
- S8 — done. `README.md` :18–24, :48–55; `plugins/glab/skills/audit/SKILL.md` :70; `AGENTS.md` :115–117 (round caps), :202–204 (size budget), :214–241 (new *One fact* entries), :270–272 (version rule); `plugins/glab/.claude-plugin/plugin.json` :3 `0.11.0`.
- S9 `plugins/glab/skills/plan-first/implement.md` — done: :3.
- S10 `tests/context-size.test.sh` — done: :335, comment only.

## Blocked

None. Every quoted HEAD text was found exactly once (each replacement was applied by a script that aborted unless its anchor occurred once).

## Unplanned changes

Mechanical consequences of hard-wrapped files, so each searched phrase sits on one line as *Processing* requires:

- `plugins/glab/skills/bootstrap/SKILL.md` :99–103, :109–110, :116–119 (S7): the replaced sentences were re-wrapped; lines outside them unchanged.
- `README.md` :18–24, :48–55 (S8): the new text wrapped at 76 columns; "Once the change has been pushed, the workflow records what" now starts its own line; the rest of that paragraph unchanged.
- `AGENTS.md` :115–117, :202–204, :214–241, :270–272 (S8): the replaced or added text wrapped at 76 columns with the list's two-space indent; `budget —` on :202 is a short line so that `48 KB each for … evidence.md` stays on one line.

No other hunk.

## Tests

Tests added: none, as the plan says. `tests/context-size.test.sh` changed in one comment line (S10); `PASS 24/24` before and after.

Coverage, per step (AGENTS.md *Tests*: a list, not a number):

- S1–S6, S8 (Markdown), S8's `plugin.json`: the step's own Verify searches, all at their values (run after each step; S2's re-run after S3 on the final tree: all 31 values as listed); `plugin validate --strict` ×3 and `plugin details` counts unchanged. No runtime: no test can run the sub-plan cycle, the hash or Stage 6b before FU9 — accepted by the plan.
- S7 `manager-bootstrap.sh`: `bash -n` + `test -x` rc=0, shellcheck rc=0, its two searches; the text changed sits inside the quoted heredoc only.
- S9: its searches; `head -n 1` unchanged.
- S10: its searches, `git diff -U0 origin/main -- tests/context-size.test.sh | grep -c '^[-+][^-+]'` → `2`, `bash -n`/`test -x` rc=0, shellcheck rc=0, `PASS 24/24`.

Uncovered: the plan-mode behaviour (L1–L7), the user's live tests, not run here by instruction; marked UNVERIFIED in the payload (`grep -c UNVERIFIED` manager → 7, README and AGENTS.md as searched).

## Gates

`export TMPDIR=/data/tmp/claude`; the AGENTS.md *Gates* blocks verbatim (the `claude` block under a new `CLAUDE_CONFIG_DIR` from `mktemp -d "$TMPDIR/claude-config.XXXXXX"`, removed by the block), output to a log under `$TMPDIR`, `ok` lines counted (59 = 35 + 24) and the rest printed:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    rc=0
    PASS 35/35
    PASS 24/24
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    plugins/memory-sync/scripts/memory-sync.sh:1
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    README.md:1
    rc=0
    rc=1

Green as F14, with `PASS 24/24`. No `claude-config.*` left under `$TMPDIR` (`ls | grep -c claude-config` → `0`).

*After* checks:

- `grep -rc 'findings\.md' plugins README.md AGENTS.md | grep -v ':0$'` → `plan-first/SKILL.md:1`, `analyzer.md:1`, `AGENTS.md:1`, `manager/SKILL.md:2`, `developer.md:2` — as at `28f7d1d`.
- `git diff --stat cf614ec -- plugins/glab/agents/reviewer.md plugins/glab/commands/review.md plugins/glab/commands/ship.md` → nothing.
- `git diff --stat origin/main -- plugins/glab/scripts/context-size.sh tests/memory-sync.test.sh plugins/glab/hooks/hooks.json` → nothing.
- `wc -c` → `plan.md` 49101, `evidence.md` 23801 (both ≤ 49152).
- `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.11.0`; `grep -rlF '48 KB' plugins AGENTS.md README.md | sort` → `AGENTS.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`.
- S1–S10 searches: every value as the plan lists it.

## Blast radius

15 tracked files, 201 insertions, 69 deletions: `AGENTS.md`, `README.md`, and under `plugins/glab/`: `.claude-plugin/plugin.json`, `agents/analyzer.md`, `agents/developer.md`, `commands/analyze.md`, `commands/develop.md`, `commands/plan.md`, `scripts/manager-bootstrap.sh` (heredoc text), `skills/audit/SKILL.md`, `skills/bootstrap/SKILL.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`, `skills/plan-first/implement.md`; and `tests/context-size.test.sh` (one comment). `plugins/memory-sync/`, the hooks, `context-size.sh`, the reviewer files and `docs/specs/` untouched. Behaviour for an installed copy: every `glab` session receives the new stage text (final check, master plan, intent check) once 0.11.0 is installed; a plan folder with no `master.md` keeps the 0.10.0 rules. Back out: revert the commit.

## Follow-ups

Written to `plan/flow-master-plan/follow-ups.md`, not built (outside the plan's closed list):

- DEV1 S3's Stage 8 replacement leaves "sub-plan folders included and the audit file" without a comma.
- DEV2 the *Pick the tier* table row order the plan prescribes (Approval above 1b, 6b before 6–7).
- DEV3 the *One fact* round-caps entry now names the final check, which only `manager/SKILL.md` among its listed files states a cap for.

The plan's own FU7 and FU9 stay open.

## Not done

- L1–L7: the user's, not run (instruction and D37).
- Not verified here: F16's inference that `$ARGUMENTS` keeps a `/` (no command was run with a sub-plan slug).
- Two files under `$TMPDIR` named `fmp-checks.<pid>.sh` and `fmp-out.<pid>.txt` are not this run's (this run's temp files were removed) and were left in place.

## Fix round 1

Each fix below is an unplanned change forced by review round 1, made as the manager decided. Nothing committed, staged or pushed; `plan.md` untouched.

- **R1 (blocking) amending an approved master.** One rule, in the same words: no round amends a `master.md` with an `## Approval` line; on a changed request a planning agent keeps the old master as `master.v<n>.md` (a version copy, never `.r<n>`) and writes a new `master.md`; the old `## Approval` line and `master.sha256` do not carry over; the new master gets its own Stage 1b, then a new approval and hash. `plugins/glab/skills/plan-first/SKILL.md` Step 4 *Amending* paragraph; `plugins/glab/skills/manager/SKILL.md` *The master plan and sub-plans* first bullet (plus: the manager removes `master.sha256` when it dispatches that agent, so the 1b `sha256sum -c` does not test the new master against the old hash — the mechanical consequence of "does not carry over") and Stage 1b's amendment-copy sentence (after approval, only a version copy). The new file name is added where round copies are listed: `plugins/glab/agents/developer.md` record paragraph and never-edit bullet, `plugins/glab/agents/analyzer.md` record check, and the AGENTS.md *One fact* entries for the round copies and for the master plan.
- **R2 (blocking) full-tier single plan approval.** At full tier every `plan.md`, a single plan's or a sub-plan's, gets the user's explicit approval after 1b and ends with its own `## Approval` line. `manager/SKILL.md`: pipeline row 1b, tier table *Approval* row (Full column), sub-plan cycle bullet, *Approval comes after Stage 1b* paragraph; `plan-first/SKILL.md` Step 4 checklist item and *Verify* row; `plugins/glab/commands/plan.md` gate 3; `plugins/glab/commands/develop.md` *Approval* precondition (checks the line); AGENTS.md master-plan *One fact* entry.
- **R3 (blocking) L1–L7 in the spec.** `docs/specs/workflow.md` *Known limits and not verified*: seven entries `[flow-master-plan/plan.md L1]`…`L7]`, each what it tests, its steps, what settles it, from the plan's live-test section. Nothing else in the spec changed (`git diff --stat -- docs/specs/` → `workflow.md | 7 +++++++`).
- **R4 (low)** `plugins/glab/agents/analyzer.md` *The final check*: "`master.md` and `index.md` (the plan, with no index)". Same fact in `manager/SKILL.md` Stage 6b ("The analyzer reads `master.md`, `index.md` (the plan, with no index)"), changed with it under *One fact*.
- **R5 (low)** `analyzer.md` frontmatter `description`: names the plan check, the conformance check and the final check, used from `/glab:analyze`.
- **R6 (low)** `README.md` :20–23: the analyzer checks the plan against `master.md` before the build (Stage 1b) and the build after it (Stage 3); the analyzer's final check before the push compares the master with everything built.

Plan searches these fixes move, by the review decisions: S1 `'is never amended: a change to the request goes back to the user'` → `0` (was `1`; R1 replaced it); S1 `"^| Verify | Plan review | the plan check, then the master's approval |"` → `0` (was `1`; R2 extended the row). Every other S1–S10 search re-run that touches edited text keeps its value (`the plan check has passed and \`master.md\` has its` 1, `^| Approval, after 1b | — | yours, reported — the user's when the work split |` 1, `; then the master's \`## Approval\`` 1, `each copied as \`<name>.r<n>.md\` beside it` 1, manager `UNVERIFIED` 7, `ending in BUILDABLE, NOT BUILDABLE, CONFORMS or DIVERGES` 1, `a split into sub-plans, need my approval` 1, develop `sha256sum -c` 1, README `the live tests L1–L7 in \`docs/specs/workflow.md\`` 1).

*After* checks: `findings\.md` counts as at `28f7d1d` (manager 2, plan-first 1, analyzer 1, developer 2, AGENTS.md 1); reviewer-file diff vs `cf614ec` empty; script/hook diff vs `origin/main` empty; `plan.md` unchanged. `git diff --shortstat` → 16 files, 213 insertions, 71 deletions (15 before plus `docs/specs/workflow.md`).

Tests: none added; Markdown only, no runtime — covered by the searches above and the gates. Not verified: that a live session follows the new text (UNVERIFIED, as for every prose rule).

Gates, `export TMPDIR=/data/tmp/claude`, the AGENTS.md blocks verbatim (the `claude` block under a fresh `CLAUDE_CONFIG_DIR`, removed by the block) into one log under `$TMPDIR`; `ok` lines counted (59 = 35 + 24), the rest printed; log removed, `ls $TMPDIR | grep -c claude-config` → `0`:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    rc=0
    PASS 35/35
    PASS 24/24
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    plugins/memory-sync/scripts/memory-sync.sh:1
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    README.md:1
    rc=0
    rc=1

All green.
