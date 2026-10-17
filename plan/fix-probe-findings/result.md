# Result — fix-probe-findings

Contract: `AGENTS.md` (read from disk), `plan/fix-probe-findings/plan.md`.
There is no `findings.md` or `questions.md`. The plan carries its findings in
*Findings*, and the dispatch message gave the user's resolved decisions, which
are the same as plan decisions 1-4. How the edits were applied:
`python3 -I plan/fix-probe-findings/edits.py .` from the repo root. It printed
`before-text found 1 time(s)` for all 17 step ids and exited `rc=0`. I read the
whole diff against the plan's step text, then checked all 11 After hashes
myself: `diff` against the plan's list returned `rc=0`.

## Stages

Before: all 11 hashes matched the plan's `5e9b3a8` values. The diff of the
plan paths between `5e9b3a8` and HEAD was empty.

| step | status | where |
|---|---|---|
| S1a | done | `plugins/glab/scripts/external-agent.sh:685-690` (comment :685-689, set :690) |
| S1b | done | `plugins/glab/scripts/external-agent.sh:694-696` (comment :694-695, sed :696) |
| S2 | done | `plugins/glab/agents/reviewer.md:86` |
| S3 | done | `plugins/glab/commands/ship.md:26` |
| S4a | done | `tests/external-agent.test.sh:127-130` |
| S4b | done | `tests/external-agent.test.sh:510-511` (E34) |
| S4c | done | `tests/external-agent.test.sh:522` |
| S4d | done | `tests/external-agent.test.sh:651-664` (blank line, comment :652-654, E49 :655-664) |
| S5a | done | `plugins/glab/skills/external-agents/profiles/kimi.md:48-52` |
| S5b | done | `plugins/glab/skills/external-agents/profiles/glm.md:44-48` |
| S5c | done | `plugins/glab/skills/external-agents/profiles/deepseek-pro.md:44-48` |
| S5d | done | `plugins/glab/skills/external-agents/profiles/deepseek-flash.md:44-48` |
| S6 | done | `README.md:52-60` |
| S7a | done | `AGENTS.md:59` |
| S7b | done | `AGENTS.md:78` |
| S7c | done | `AGENTS.md:181-182` |
| S8 | done | `plugins/glab/.claude-plugin/plugin.json:3` (`0.4.2`) |

## Blocked

None.

## Unplanned changes

- **R1, from review advisory 1** (the review verdict was SHIP; the
  coordinator directed this fix). It is not a plan step.
  - Where: `plugins/glab/skills/external-agents/SKILL.md:132-135`.
  - Before, the text said only "for `BLOCK: <n> issues` an n of at least 1
    and at least n findings". It now reads "for `BLOCK: <n> issues` (or
    `BLOCK: 1 issue`) an n of at least 1 …".
  - Why: S1a and S1b made the script accept the singular and check its count
    (`external-agent.sh:690-696`, E49), so the old text no longer covered
    everything the check does.
  - Scope: wording only. Lines 132-134 were rewrapped, and the end of the old
    :134 moved to a new :135. Nothing else in the file changed.
  - Effects: this is the 12th changed path, and it is under `plugins/glab/`,
    which the S8 `0.4.2` bump already covers. The plan said this file would
    not be edited (F1 table, D2); that is superseded by the advisory, and I
    did not edit the plan. The file's sha256 after the change is
    `4881d1f40b6f592d1e65545325c6a1c82b8212679c93e6131da15757c072df4a`.
  - Tests: no case and no gate reads this text (`grep` of `tests/*.sh` for
    `an n of`, `at least n` or `exactly one verdict` finds only the script's
    own error text). Markdown has no gate.

Apart from R1, the only paths that changed are the plan's 11.

## Tests

Changed: `tests/external-agent.test.sh`. It gained three stub scenarios
(`rev-one`, `rev-one-bare`, `rev-two-singular`) and one new case, E49. E34 was
extended, and the E36 comment range now runs to E49. Result: `PASS 49/49`,
which was 48/48 before. `tests/memory-sync.test.sh` is unchanged: `PASS 35/35`.

Coverage, listed per AGENTS.md *Tests* (no tool measures bash coverage):

- S1a: E49, where `rev-one` must exit 0 and `rev-two-singular` must exit 8.
  E34 checks the string. E17, E18, E19, E44, E47 and E48 still pass, so the
  other verdict forms are unchanged.
- S1b: E49, where `rev-one-bare` must exit 8 with
  `verdict says 1 issues, the report has 0 findings`. Not covered: the
  comment's "line out of form beside a SHIP" has no case. It follows from both
  sed expressions being whole-line. This is accepted in the plan's *Coverage*.
- S2: E34 checks that `` `BLOCK: 1 issue` `` is present in reviewer.md. Not
  covered: whether a model now writes either form. Only a live run shows that,
  and agents do not make live runs.
- S3: no case, because it is prose. The `BLOCK: 1 issue` search covers it
  (ship.md: 1).
- S4a-d: these are the test itself. The plan's mutants m1-m3 are its failure
  modes. I did not re-run the mutants; the plan records them as proven by the
  planner.
- S5a-d: no case. *Notes* are never sent to the model (E20). The searches
  cover them.
- S6, S7a-c: the C7 gate line (`1`, `rc=0`) and the searches cover them.
  Markdown has no gate.
- S8: no case. The `jq` line covers it.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root.

Block 1, exactly as AGENTS.md gives it:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0                                   # shellcheck, no findings
    bash tests/memory-sync.test.sh ...     # rc=0, 36 lines: 35 `ok`, last `PASS 35/35`
    bash tests/external-agent.test.sh ...  # rc=0, 50 lines: 49 `ok`, last `PASS 49/49`
    ok E34 the verdicts the script accepts are the ones the reviewer's file states
    ok E49 BLOCK: 1 issue is accepted with its count checked, as BLOCK: 1 issues is; BLOCK: 2 issue is malformed (8)
    ok E36 after every case: the real repository is unchanged byte for byte, no agent is left, and no sandbox, slirp4netns or stub process runs

Block 2, exactly as AGENTS.md gives it after S7, with
`CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014` and a
throwaway `CLAUDE_CONFIG_DIR` from the block's own `mktemp`, removed at the
end (afterwards, 0 `claude-config.*` directories remain):

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart  (harness-only — no model context cost)
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
    1
    rc=0
    rc=1

Every line matches the AGENTS.md *Green is* list.

The plan's After searches: every output matches the plan.

    0.4.2
    README.md:0  AGENTS.md:0                      # 'not yet run against a real model'
    README.md:1  AGENTS.md:1                      # 'Not yet shown: any reply from a DeepSeek model'
    1                                             # 'probe-r3.md' in AGENTS.md
    1                                             # 'the sentence on what the live probe did'
    deepseek-flash 0, deepseek-pro 0, default 0, glm 0, kimi 0; rc=1   # "The user's live probe (L1"
    kimi 1, glm 1, deepseek-pro 1, deepseek-flash 1                    # 'probe-r3/'
    kimi 1, glm 1, deepseek-pro 0, deepseek-flash 0                    # 'Replies from this'
    reviewer.md 1, ship.md 1, external-agent.sh 2, external-agent.test.sh 8   # 'BLOCK: 1 issue'
    1                                             # the S1b sed expression
    1                                             # 'E37-E49'
    git status --short: the 11 paths ` M`, plus ?? plan/SESSION-HANDOFF.md,
      ?? plan/feature-opencode-worker/probe-r3.md, ?? plan/feature-opencode-worker/probe-r3/,
      ?? plan/fix-probe-findings/

## Gates after R1

I re-ran both blocks exactly as AGENTS.md gives them (same `TMPDIR`, same
`CLAUDE_BIN`, and a throwaway config directory, removed afterwards):

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    ms rc=0 lines=36 ok=35
    PASS 35/35
    ea rc=0 lines=50 ok=49
    PASS 49/49
    ok E34 the verdicts the script accepts are the ones the reviewer's file states
    ok E49 BLOCK: 1 issue is accepted with its count checked, as BLOCK: 1 issues is; BLOCK: 2 issue is malformed (8)
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart  (harness-only — no model context cost)
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
    1
    rc=0
    rc=1
    leftover cfg: 0 fpf: 0

`git status --short`: the plan's 11 paths and
`plugins/glab/skills/external-agents/SKILL.md` show ` M`, plus the same four
`??` entries as before.

## Blast radius (glab:security)

- **Files written:** the plan's 11 paths,
  `plugins/glab/skills/external-agents/SKILL.md` (R1), and this file. No other file in the
  repo changed. Nothing under `plan/feature-opencode-worker/` and nothing in
  `plan/SESSION-HANDOFF.md` changed. I edited no plan file.
- **Commands run:** `edits.py` (it imports only `sys` and `pathlib` and writes
  the 11 paths), `sha256sum`, `git diff`, `git status`, `git log`, `grep`,
  `jq`, both gate blocks, and the stub tests.
- **Not run:** `external-agent.sh` against a real model, `git add`, `commit`
  and `push`, any plugin install, `enable`, `configure` or marketplace
  command, and any service start, stop or restart.
- **Not read:** `~/.env`, OpenCode data or auth files, and
  `~/.claude/settings.json`.
- **`claude` CLI:** run only with a throwaway `CLAUDE_CONFIG_DIR` under
  `/data/tmp/claude`. That directory was removed afterwards.
- **Processes:** the external-agent test started its own sandboxes, stubs and
  local listeners. E36 shows none are left.
- **Temporary files:** `/data/tmp/claude/fpf-dev-*` (two hash lists and two
  test logs), all removed. Nothing was written to `/tmp`.
- **Secrets:** none written to any file or output. The new text names models,
  dates and repo paths only.

## Follow-ups

The plan's four follow-ups (`plan.md` *Follow-ups*) are not done here. One
more, recorded at the coordinator's request:

- **Error wording pinned by E49.** For a singular verdict, the gap message
  reads `verdict says 1 issues, …` (`external-agent.sh:696` reads n, and the
  message at `external-agent.sh:703` prints it before `issues`). E49 pins that
  text (`tests/external-agent.test.sh:662`); E19's plural form is at :381. If the message is ever reworded, for
  example to the singular, change both in the same commit. This build leaves
  the wording as it is, as the plan's F1 table accepts.

## Not done

- **Probe records commit:** plan *Before* expects `git log` to show it on top
  of `5e9b3a8`. It is not there yet: HEAD is still `5e9b3a8`, and `probe-r3*`
  is still `??`. Per the dispatch, the manager commits it before this fix.
  S5 and S6 cite those paths, so the order of the two commits matters.
- **Mutants m1-m3:** I did not re-run them. They are the planner's proven
  claim, and are not checked by me.
- **Plan line numbers:** the plan cites `glab:manager` `:143` and `:145`. In
  the current tree, a search for `BLOCK` in `manager/SKILL.md` and
  `external-agents/SKILL.md` finds no list of BLOCK forms that would need the
  singular. :132 of the external-agents skill stays true, so the plan's claim
  holds.
