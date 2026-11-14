# Result — flow-project-level / 01-rename

## Stages

- B1 — done: HEAD `0a44facc9a669f7e21b8116f377c0372e817c556`, `git status --short` was `?? plan/`. B2 was not re-run: the dispatch said the shell gates were green at 0a44fac and the budget allowed one gate run, at the end (A5).
- S1 — done: extracted with the plan's `awk` (80 lines) into a temp file under `/data/tmp/claude`, run once with `bash`, removed afterwards. It printed `S1 done`, rc=0. `git status --short`: 14 `RM`, 14 ` M`, `?? plan/`. Nothing changed under `docs/` or another plan folder.
  - S1a: the 8 skill directories and 6 agent files moved, with their `name:` lines (`plugins/glab/skills/project-*/SKILL.md:2`, `plugins/glab/agents/project-*.md:2`).
  - S1b: `README.md` copy-install list (*Coming from the copy install*, step 2), R2's four lines.
  - S1c: `plugins/glab/skills/session-rules/SKILL.md:10` clause removed; `README.md:9` edited per R7; `plugins/glab/skills/product-manager/SKILL.md:22-23` line removed.
  - S1d: prefixed and path forms across `plugins`, `README.md`, `AGENTS.md`, `tests` (including the comments at `plugins/glab/scripts/plan-gate.sh:5-6`, `plugins/glab/scripts/manager-bootstrap.sh`, `tests/manager-bootstrap.test.sh`, `tests/product-loop.test.sh` and `tests/plan-gate.test.sh`).
  - S1e: `AGENTS.md` *Gates* `Skills (21)` / `Agents (9)` lists.
  - S1f: `plugins/glab/.claude-plugin/plugin.json:3` set to `0.15.0`.
  - S1g: `README.md` `## Renamed in 0.15.0`, before `## Coming from the copy install`.
- A1 — done: the first search printed only `rc=1`; the second printed `0`.
- A2 — done: the 14 `name: project-*` lines; `ls` shows no old directory or file.
- A3 — done: `0.15.0`; `14`; `1`.
- A4 — done: `0`; `0`; R2's four lines; R7 `1` and `0`.
- A5 — done: both gate blocks green (see *Gates*).
- A6 — done: with the mutant, `manager-bootstrap` FAIL 5/13 and `product-loop` FAIL 1/17. The reverse `sed` restored the file byte for byte (sha256 matched the pre-mutant file), and its execute bit is still set. The two tests' PASS after the restore comes from A5's run.
- A7, A8 — not run: committing is not the developer's job; back-out not needed.

## Blocked

None.

## Unplanned changes

None. Every change is from S1.

## Tests

No test was added (the plan says so). S1d updated the expected strings in `tests/manager-bootstrap.test.sh`, `tests/product-loop.test.sh` and `tests/plan-gate.test.sh`. All five suites pass. Coverage per step is as the plan's *Tests and coverage* lists it. A6 shows that the hook-text cases see the rename. The Markdown edits (S1b, S1c, S1g) and the `plan-gate.sh` comments are covered by the A1, A3 and A4 searches only, which is accepted under `AGENTS.md` *Tests*.

## Gates

`TMPDIR=/data/tmp/claude`. Both `AGENTS.md` *Gates* blocks, as written after S1, run once:

- syntax and exec: nine `rc=0`. `shellcheck`: `rc=0`, no findings.
- tests: `PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 13/13`, `PASS 17/17`, with no line other than `ok` before each.
- plugin gates (`CLAUDE_CONFIG_DIR` set to a fresh temp dir, removed afterwards): `✔ Validation passed` three times.
  - `Skills (21)`: the list in R3's order.
  - `Agents (9)`: R3's set.
  - Both `Hooks (4)` lines carry the suffix.
  - memory-sync shows `Skills (1)  sync-memory` and `Agents (0)`.
- `glab = glab`, `memory-sync = memory-sync`; `:0 :0 rc=1`; `1 1 1 rc=0`.
- model gate: 9 lines, `rc=0`, the same set as `AGENTS.md`'s list. Skills gate: 18 lines, none `MISSING`, the same set as `AGENTS.md`'s list. Both were checked by `diff`.
- prefixed `name:`: no line, `rc=1`.

## Follow-ups

None.

## Not done

- A7 (the commit) and A8 (the back-out) belong to the committer and the user.
- What the plan's *Dry run* leaves unproven also stays unproven here: whether an installed 0.14.1 copy picks up the renames on update.
- Nothing was staged. The slug-level files stay untracked.
