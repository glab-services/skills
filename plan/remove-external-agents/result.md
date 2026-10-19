# Result — remove-external-agents

Stage 2, develop. `HEAD` = `origin/main` = `6b2a024`. Built by one
`glab:developer` (D13) at effort high. `TMPDIR=/data/tmp/claude` for every
command. Nothing committed or pushed; `plan.md` not edited; `docs/specs/` and
`plan/SESSION-HANDOFF.md` not touched.

## Stages

- **Before** — done. Baseline green, output under *Gates*.
- **S1** — done. Precheck
  `git status --short --ignored -uall -- plugins/glab/skills/external-agents`
  printed nothing (rc=0). Then the plan's `git rm -- <the eight paths>`: rc=0,
  eight `rm '<path>'` lines. Git removed the empty
  `plugins/glab/skills/external-agents/` directory as well.
- **S2** — done. `plugins/glab/.claude-plugin/plugin.json:3` `"version": "0.8.0"`; `jq -r .version` printed `0.8.0`. It is the only hunk in that file.
- **S3–S8** — done in one run: `python3 -I plan/remove-external-agents/edits.py .`,
  with no edit made by hand before or after it. It printed `ok` for all 39 edits
  (S3a…S8d, then S2) and `script rc=0`. Where each change lands (line numbers in the new file):
  - S3 `plugins/glab/commands/develop.md`: :2 (S3a), :8 (S3b), :20 (S3c), the bullet deleted after :43 (S3d), the block deleted after :50 (S3e).
  - S4 `plugins/glab/commands/review.md:8`.
  - S5 `plugins/glab/commands/ship.md:16` (S5a), `:28` (S5b).
  - S6 `plugins/glab/skills/manager/SKILL.md`: :71 (S6b), the paragraph deleted after :128 (S6c), :130 (S6d, S6e), :132 (S6f), :134–135 (S6g, S6h), :137 (S6i), the table rows deleted after :145 (S6j), :151 (S6k, then S6a: Rule 6 is gone and `## Know the gates before you dispatch` follows), :173 (S6l), :209 (S6m), :239 (S6n), :395 (S6o), the bullet deleted after :436 (S6p).
  - S7 `AGENTS.md`: :12 (S7a), :23–53 and :67–85 (S7b, *Gates*/*Tests*), the bullet deleted after :96 (S7c), :132–133 (S7d), :136–137 (S7e), :139 (S7f), :148 (S7g), :153–155 (S7h, S7i), :158 (S7j).
  - S8 `README.md`: :9 (S8a, S8b), the 106 lines deleted after :34 (S8c), :191 (S8d).
- **S9** — done: this file.
- **After** — done. Gates and C1–C6 are green (below).

## Blocked

Nothing.

## Unplanned changes

None. Every hunk comes from S1 or `edits.py`. C5 matches all seven hashes, and
C6 lists only the fifteen planned paths.

Worth noting: S1's `git rm` stages the eight deletions in the index (`D ` in
column 1 of C6). The plan's step names that command, and C1's
`git ls-files … | wc -l` → `0` needs it. Nothing else is staged: the seven
edits are unstaged (` M`). `git restore --staged -- <path>` undoes the staging.

## Tests

No test was added. `tests/external-agent.test.sh` (86 cases) is removed with the
script it tested (S1), which is the plan's stated mechanical consequence.
Coverage list (`AGENTS.md` *Tests*):

- S1: C1 (three `gone rc=0`, then `0`); the plugin block's `Skills (14)` line without `external-agents`; the three-script shell gates.
- S2: `jq -r .version` → `0.8.0`; C5 hash OK.
- S3–S8 (Markdown, which has no gate): C2, C3, C4, C5 and C6, and the per-step diffs against `7139e62^` (below). No case runs a session against the edited prose. That is accepted per plan: the searches show that nothing naming the removed parts is left.
- `memory-sync` was not touched. Its suite `PASS 35/35` shows the shared gates still run.

Per-step diffs against `7139e62^` (proven, run on the edited tree):
- `develop.md`: only `> - the effort, always: …` (`abda43a`).
- `review.md`: only line 8's added `Pass the Agent tool's effort parameter …` sentence.
- `ship.md`: only the effort sentence at :16, `BLOCK: 1 issue` at :26 (D9), and the committer's effort at :36. The round cap text is unchanged.
- `manager/SKILL.md`: hunks 3, 64a65–73 (Rule 0d), 81, 124, 126, 161a171, 163, 182–183, 226, 329a340, 384, 402–424 (Stage 8), 414a437. All of them are Stage 8, record or effort text.
- `README.md`: only the effort sentence with the `plan/`/`docs/specs/` paragraph (14–23), and the `plan/` and `docs/specs/` rows (192–193).
- `AGENTS.md` *Gates* through *Rules*: `diff <(git show 7139e62^:AGENTS.md | sed -n '/^## Gates/,/^## Rules/p') <(sed -n '/^## Gates/,/^## Rules/p' AGENTS.md)` printed nothing, `rc=0`.
- `git diff --check` printed nothing, rc=0. That proves only that there are no whitespace errors.

## Gates

### Before (untouched tree, `AGENTS.md` *Gates* as at `6b2a024`)

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0                                    (shellcheck, no findings)
    memory-sync suite: exit=0, 35 `ok ` lines, only other line PASS 35/35
    external-agent suite: exit=0, 86 `ok ` lines, only other line PASS 86/86

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

Baseline C1–C4: three `gone rc=1` and `8`; C2 709 lines; C3 692 lines; C4 eight
lines (`AGENTS.md` 223, 228, 235, 250; the removed skill's :26; manager 71, 157,
189), rc=0.

### After (the blocks as the edited `AGENTS.md` *Gates* holds them, extracted from the file and run as scripts)

`CLAUDE_BIN=<the CLI path the host file names>`. The block
sets `CLAUDE_CONFIG_DIR` to a new `mktemp -d` under `$TMPDIR` and removes it at
the end; afterwards `ls /data/tmp/claude | grep -c claude-config` printed `0`.

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    PASS 35/35                 (exit=0, 35 `ok ` lines, no other line)

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
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
    rc=1

Every line matches the plan's *After* green. `Skills (14)` names exactly the 14, with no `external-agents`.

### Discriminating checks

    C1  plugins/glab/scripts/external-agent.sh gone rc=0
        tests/external-agent.test.sh gone rc=0
        plugins/glab/skills/external-agents gone rc=0
        0
    C2  AGENTS.md:168:  `external-agents.md`: how the area works now, the decisions that still
        (exactly one line, the D8 line)
    C3  AGENTS.md:  external CLI** such as `aws`. `tests/memory-sync
        AGENTS.md:  `external-agents.md`: how the area works now, th
        plugins/glab/agents/integrator.md:description: Runs a change
        plugins/glab/skills/bootstrap/SKILL.md:- **`review ⇄`** — an
        plugins/glab/skills/manager/SKILL.md:Where the work reimplem
        plugins/glab/skills/manager/SKILL.md:Run `/glab:integrate {s
        plugins/glab/skills/manager/SKILL.md:**The reviewer is an ex
        count: 7
    C4  (no line) rc=1
    C5  sha256sum -c against the plan's seven hashes: all seven `OK`, rc=0
    C6   M AGENTS.md
         M README.md
         M plugins/glab/.claude-plugin/plugin.json
         M plugins/glab/commands/develop.md
         M plugins/glab/commands/review.md
         M plugins/glab/commands/ship.md
        D  plugins/glab/scripts/external-agent.sh
        D  plugins/glab/skills/external-agents/SKILL.md
        D  plugins/glab/skills/external-agents/profiles/deepseek-flash.md
        D  plugins/glab/skills/external-agents/profiles/deepseek-pro.md
        D  plugins/glab/skills/external-agents/profiles/default.md
        D  plugins/glab/skills/external-agents/profiles/glm.md
        D  plugins/glab/skills/external-agents/profiles/kimi.md
         M plugins/glab/skills/manager/SKILL.md
        D  tests/external-agent.test.sh
        lines: 15
        `git status --short -uall -- docs/specs/` printed nothing.

## Claims (`glab:security`)

| claim | proven / inferred | how |
|---|---|---|
| The baseline was green before any edit | proven | *Before* output above |
| The edited files equal the plan's dry run | proven | C5 `sha256sum -c`, seven `OK` |
| Nothing outside `docs/specs/` and `plan/` names the removed parts, except the D8 line | proven | C2 printed only `AGENTS.md:168` |
| No reference to the manager's Rule 6 is left | proven | C4 printed nothing, rc=1 |
| Only the planned paths changed | proven | C6, fifteen lines |
| `plan/SESSION-HANDOFF.md` is unchanged | proven (mtime only) | `stat` mtime `2026-10-19 01:31`, before this run; no command of this run wrote to it |
| A session that names an external reviewer after 0.8.0 is covered by Rule 5's "ask which of the four" | inferred | from the text (plan *Inferred*); no session was run |

## Blast radius

    changed:  glab plugin: the external-agents skill, its profiles and external-agent.sh are removed;
              glab:manager Rules 0d and 5 and the pipeline text, /glab:develop, /glab:review and
              /glab:ship lose their external paths; glab version 0.7.2 -> 0.8.0. In the repo:
              AGENTS.md Gates, Tests, Rules and One fact entries; README.md; the external-agent
              gate suite.
    callers:  nothing executed or sourced the script at runtime. plugins/glab/hooks/hooks.json runs
              only manager-bootstrap.sh (plan *Call sites*). Every text caller (manager, the three
              commands, AGENTS.md, README.md) is edited, and C2 and C4 show none is left outside
              docs/specs/ and plan/.
    data:     none in the repo. An installed 0.7.x host can still hold
              $TMPDIR/glab-external-agents/ and Codex's own sessions (D10, for Stage 8). This host
              has /data/tmp/claude/glab-external-agents/, an empty directory with mtime
              2026-10-19 01:18, older than this run. It was left untouched.
    rollback: before the commit: `git restore --staged --worktree --source=HEAD -- <the 15 paths>`.
              After it: revert the commit. Every removed file is readable at 6b2a024.

## Follow-ups

None written, and `follow-ups.md` was not created: no gap outside the plan
turned up on the way. The host leftover above is D10's, and Stage 8 records it.

## Not done

- Stage 8 (`docs/specs/*`) and the folder's removal belong to the record and the manager session, not to this step (D3, D16).
- No commit or push (D2 is the committer's).
- UNVERIFIED: that a live session follows the edited prose as intended. No session was run against it, as the plan accepts.
