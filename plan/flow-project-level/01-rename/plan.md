Tier: normal — a mechanical rename of names and paths in one commit; no schema, stored or wire format, secret, money or authorization code (`index.md` D3).

# 01-rename — the project level becomes `glab:project-*`

Sub-plan of `flow-project-level` (`../master.md`, approved, base `0a44fac`). Its `index.md` line: `01-rename · goals G2, G3 · depends none · tier normal`. It resolves F13 and F24 (`../audit.md` §4) and the renames of `../audit.md` §5; it moves no text between files (D2). Every other finding is 02's or 03's.

## Evidence

Built on `../evidence.md` E3 (the 25 files and 179 lines naming an old component), E4 (`plan-gate.sh` parses no component name), E5 (the dry-run method and its gates) and E6 (the false sentences). Taken on `0a44fac`, 2026-11-14. Only what those leave open:

- **P1 — E5's path substitution renames text that is not a plugin path.** `README.md:272-276` (*Coming from the copy install*, step 2) tells a user to delete `~/.claude/skills/manager/` and `~/.claude/agents/developer.md`, `analyzer.md`, `integrator.md`, `reviewer.md`: the names of the old hand copy, which do not change. E5's perl rewrote them to `skills/project-manager/` and `agents/project-*.md`, which would tell the user to delete paths that do not exist and leave the copy in place. *Final check* step 2 searches `README.md` for exactly those path forms, so they cannot stay as they are either.
  ```
  $ /usr/bin/grep -rnE 'skills/(manager|plan|develop|analyze|integrate|review|ship|product-project-plan-report)/|agents/(planner|plan-analyzer|analyzer|developer|integrator|reviewer)\.md' README.md tests/*.sh plugins
  README.md:273:     `skills/manager/`, `skills/security/`, `skills/comments/`,
  README.md:275:   - five agents under `agents/`: `agents/developer.md`, `agents/analyzer.md`,
  README.md:276:     `agents/integrator.md`, `agents/reviewer.md`, `agents/committer.md`;
  ```
- **P2 — No other form escapes E5's patterns.** Over `plugins README.md AGENTS.md tests host.example.md .claude-plugin`: `skills/<old>` not followed by `/` — no line; `<old>/SKILL.md` or `<old agent>.md` without the directory — no line; a slash command without the prefix (`/plan`, `/develop`, …) — no line; a backticked bare old name — only `AGENTS.md:76`; frontmatter `name: <old>` — exactly the 14 files renamed, each at line 2. No tracked file name in that set holds a space (`git ls-files … | grep -c ' '` → 0).
- **P3 — The F13 texts, verbatim on `0a44fac`.** `session-rules/SKILL.md:10` ends `…to fit its budget, and a name's prefix does not always say the level — `glab:product-project-plan-report` is the project level's.`; `product-manager/SKILL.md:22-23` is a blank line and `` `glab:product-project-plan-report` is not on it: `glab:session-rules` *The level boundary* says why. ``, followed by a blank line and `## The shared store`. After the rename every project skill's prefix says its level, so both go (F13).
- **P4 — Version and gate list.** `plugins/glab/.claude-plugin/plugin.json:3` is `  "version": "0.14.1",`; `marketplace.json` holds no version. `AGENTS.md:76` lists the skills alphabetically, matching the CLI's `Skills (21)` order (E5's output is alphabetical), and the agents "in any order".
- **P5 — `plan-gate.sh:5-6`** name `glab:product-project-plan-report` and `glab:develop` in comments only (E4); the perl updates them, as *Comments and recorded incidents are kept* asks (F24).

## Decisions

- R1 — E5's script is used as written for the moves, the `name:` lines and the prefixed and path substitutions, run over `git ls-files -z … | xargs -0` instead of `$(…)` so a file name never splits (P2).
- R2 — `README.md`'s copy-install list names its skill directories and agent files bare under `skills/` and `agents/`, rewritten before the general substitution so that substitution finds nothing there; the hand copy's real names stay correct and step 2's search stays a plain absence check (P1). Its `commands/…` paths name no component and stay.
- R3 — `AGENTS.md:76`'s two lists are replaced by exact strings, the skills sorted as the CLI prints them; the model and skills gate lines keep their order, since the gate compares them as a set ("exactly these nine lines") (P4).
- R4 — F13: the clause `, and a name's prefix … project level's` and the product manager's `is not on it` line are removed, both before the general substitution so each edit matches today's text (P3).
- R7 — `README.md:9` lists `glab:product-project-plan-report` in the product level's group with "which the project level runs", the README form of F13's exception: it moves to the row's stage skills, after `/glab:ship`, and the clause goes, edited before S1d so S1d renames it (coordinator's decision, plan check round 1).
- R5 — The migration note is a new `README.md` section `## Renamed in 0.15.0`, before `## Coming from the copy install`: the D17 table of 14 rows and the D17 line on `- model:` lines.
- R6 — Every edit that must match fails the script when it does not: each `perl` by `END { exit 1 }`, never by `die` inside `perl -i`, so a missing match changes no file and stops the run; each `name:` `sed` by a `grep -qx` of the new line after it.
- R8 — Review round 1 (manager, 2026-11-14): two medium findings fixed by the manager as trivial edits. `audit/SKILL.md:21,69` linked `../plan/SKILL.md`, a path that no longer exists, now `../project-plan/SKILL.md`; every relative `SKILL.md` link under `plugins/` now resolves. The README migration note now says that in a plan already reported to the product level the renamed `- model:` line goes into `after-verdict.md`, because `plan.md` is hashed (`glab:project-manager` Stage 1c). The low finding, to restore the old copy-install wording in `README.md` and leave that section out of the old-name search, is rejected: master *Final check* step 2 is constant after `## Approval` and would match the old `skills/<name>/` paths, and R2's bare names say the same thing.

## Rename map

Skills (`plugins/glab/skills/<old>/` → `<new>/`, `name:` bare): `manager`, `plan`, `develop`, `analyze`, `integrate`, `review`, `ship` → `project-<same>`; `product-project-plan-report` → `project-plan-report`. Agents (`plugins/glab/agents/<old>.md` → `<new>.md`, `name:` bare): `planner`, `plan-analyzer`, `analyzer`, `developer`, `integrator`, `reviewer` → `project-<same>`. Kept: `session-rules`, `bootstrap`, `security`, `comments`, `audit`, `commit`, `push`, every `product-*` skill, `committer`, `product-planner`, `product-analyzer`. Payload text: `glab:<old>` → `glab:<new>`, `/glab:<old>` → `/glab:<new>`; role words in prose ("the reviewer") unchanged.

## Boundary

The tree of `plugins/`, `README.md`, `AGENTS.md`, `tests/` (and `host.example.md`, `.claude-plugin/`, which name none, E3). Not `docs/specs/` (D15) and no other plan folder. One commit (D2).

Rejected: renaming by hand file by file — 179 lines in 25 files plus 83 path forms (E3), where a missed one passes every gate but step 2; a compatibility alias under the old names — Claude Code has no alias for a skill or agent, and a second copy would double the listing that G5 caps; leaving `README.md:272-276` to the general substitution — wrong instructions (P1).

## Milestone

The gates of `AGENTS.md` *Gates* green on the renamed tree, with the new names in its lists, plus *Final check* step 2's two searches (`index.md`, 01-rename). Proven once in a throwaway clone (*Dry run*).

## Before

- B1 — On `flow-project-level` at `0a44fac` with only `plan/` untracked: `git rev-parse HEAD` prints `0a44facc9a669f7e21b8116f377c0372e817c556`, `git status --short` prints `?? plan/`.
- B2 — `export TMPDIR=/data/tmp/claude`. Run both gate blocks of `AGENTS.md` *Gates* as written on `0a44fac`; green as written there.

## Processing

- S1 — From the repo root, run this script once with `bash` (one block; extract it as *Dry run* does or paste it into a file under `$TMPDIR`). It stops at the first failed match.

```bash
set -euo pipefail
S=plugins/glab/skills; A=plugins/glab/agents

# S1a - directories and frontmatter name: lines (E5)
for s in manager plan develop analyze integrate review ship; do
  git mv "$S/$s" "$S/project-$s"
  sed -i "s/^name: $s\$/name: project-$s/" "$S/project-$s/SKILL.md"
  /usr/bin/grep -qx "name: project-$s" "$S/project-$s/SKILL.md" || exit 1
done
git mv "$S/product-project-plan-report" "$S/project-plan-report"
sed -i 's/^name: product-project-plan-report$/name: project-plan-report/' "$S/project-plan-report/SKILL.md"
/usr/bin/grep -qx "name: project-plan-report" "$S/project-plan-report/SKILL.md" || exit 1
for a in planner plan-analyzer analyzer developer integrator reviewer; do
  git mv "$A/$a.md" "$A/project-$a.md"
  sed -i "s/^name: $a\$/name: project-$a/" "$A/project-$a.md"
  /usr/bin/grep -qx "name: project-$a" "$A/project-$a.md" || exit 1
done

# S1b - README copy-install list: the old hand copy's names, bare (R2, P1)
perl -0pi -e 's{\Q   - seven skill directories under `skills/`: `skills/bootstrap/`,
     `skills/manager/`, `skills/security/`, `skills/comments/`,
     `skills/plan-first/`, `skills/audit/`, `skills/sync-memory/`;
   - five agents under `agents/`: `agents/developer.md`, `agents/analyzer.md`,
     `agents/integrator.md`, `agents/reviewer.md`, `agents/committer.md`;\E}{   - seven skill directories under `skills/`: `bootstrap`, `manager`,
     `security`, `comments`, `plan-first`, `audit`, `sync-memory`;
   - five agents under `agents/`: `developer.md`, `analyzer.md`,
     `integrator.md`, `reviewer.md`, `committer.md`;} or $bad=1; END { exit 1 if $bad }' README.md

# S1c - F13: the exception sentences go, and README.md:9 lists the report skill with the project's stage skills (R4, R7, P3)
perl -pi -e 's/, and a name\x27s prefix does not always say the level — `glab:product-project-plan-report` is the project level\x27s\././ and $n++; END { exit 1 unless $n == 1 }' "$S/session-rules/SKILL.md"
perl -pi -e 's{\Q`/glab:ship`, which `glab:manager` runs itself\E}{`/glab:ship`, `/glab:product-project-plan-report`, which `glab:manager` runs itself} and $n++; s{\Q`glab:product-project-plan-verdict`, and `glab:product-project-plan-report`, which the project level runs ·\E}{`glab:product-project-plan-verdict` ·} and $n++; END { exit 1 unless $n == 2 }' README.md
perl -0pi -e 's/\n\n`glab:product-project-plan-report` is not on it: `glab:session-rules` \*The level boundary\* says why\.\n/\n/ or $bad=1; END { exit 1 if $bad }' "$S/product-manager/SKILL.md"

# S1d - every prefixed mention and path form (E5, R1)
git ls-files -z plugins README.md AGENTS.md tests host.example.md | xargs -0 perl -pi -e 's/glab:(manager|plan|develop|analyze|integrate|review|ship|planner|plan-analyzer|analyzer|developer|integrator|reviewer)(?![-a-z])/glab:project-$1/g; s/glab:product-project-plan-report(?![-a-z])/glab:project-plan-report/g; s{skills/(manager|plan|develop|analyze|integrate|review|ship)/}{skills/project-$1/}g; s{skills/product-project-plan-report/}{skills/project-plan-report/}g; s{agents/(planner|plan-analyzer|analyzer|developer|integrator|reviewer)\.md}{agents/project-$1.md}g'

# S1e - AGENTS.md Gates lists (R3, P4)
perl -pi -e 'if (/^- for `glab`: `Skills \(21\)` naming /) {
  s{\Q`analyze`, `audit`, `bootstrap`, `comments`, `commit`, `develop`, `integrate`, `manager`, `plan`, `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-analyze`, `product-project-plan-report`, `product-project-plan-verdict`, `push`, `review`, `security`, `session-rules` and `ship`\E}{`audit`, `bootstrap`, `comments`, `commit`, `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-analyze`, `product-project-plan-verdict`, `project-analyze`, `project-develop`, `project-integrate`, `project-manager`, `project-plan`, `project-plan-report`, `project-review`, `project-ship`, `push`, `security` and `session-rules`} and $n++;
  s{\Q`analyzer`, `committer`, `developer`, `integrator`, `plan-analyzer`, `planner`, `product-analyzer`, `product-planner` and `reviewer`\E}{`committer`, `product-analyzer`, `product-planner`, `project-analyzer`, `project-developer`, `project-integrator`, `project-plan-analyzer`, `project-planner` and `project-reviewer`} and $n++;
} END { exit 1 unless $n == 2 }' AGENTS.md

# S1f - version (D19, P4)
perl -pi -e 's/^  "version": "0\.14\.1",$/  "version": "0.15.0",/ and $n++; END { exit 1 unless $n == 1 }' plugins/glab/.claude-plugin/plugin.json

# S1g - the migration note (D17, R5)
NOTE=$(cat <<'EOF'
## Renamed in 0.15.0

`glab` 0.15.0 moves the project level's skills and agents to `glab:project-*`.
An old name, typed after `/glab:` or dispatched, finds nothing. Each old name
and what it became:

| was `glab:` | now |
|---|---|
| `manager` | `glab:project-manager` |
| `plan` | `glab:project-plan` |
| `develop` | `glab:project-develop` |
| `analyze` | `glab:project-analyze` |
| `integrate` | `glab:project-integrate` |
| `review` | `glab:project-review` |
| `ship` | `glab:project-ship` |
| `product-project-plan-report` | `glab:project-plan-report` |
| `planner` | `glab:project-planner` |
| `plan-analyzer` | `glab:project-plan-analyzer` |
| `analyzer` | `glab:project-analyzer` |
| `developer` | `glab:project-developer` |
| `integrator` | `glab:project-integrator` |
| `reviewer` | `glab:project-reviewer` |

The skills of every level, `glab:committer` and the product level keep their
names. A plan folder begun before 0.15.0 may hold `- model: glab:<old agent> …`
lines under `## Decisions` (`glab:session-rules` Rule 5): they name agents that
no longer exist, so rewrite each to its new name before the folder's next
dispatch.
EOF
)
export NOTE
perl -0pi -e 's/^(?=## Coming from the copy install\n)/$ENV{NOTE}\n\n/m or $bad=1; END { exit 1 if $bad }' README.md
echo "S1 done"
```

Verification of S1: it prints `S1 done`; `git status --short` shows 14 `R` lines for the moved files and `M` for the rest; nothing under `docs/` or another plan folder changes.

S1c's em dash is matched as its UTF-8 bytes: neither the script nor the file is decoded, so both sides are the same three bytes.

## After

- A1 — *Final check* step 2, both searches, from a fenced block (`../master.md`): the first prints only `rc=1`; the second prints `0`.
- A2 — Presence: `/usr/bin/grep -rhE '^name: project-' plugins/glab | sort | tr '\n' ' '` prints the 14 new names; `ls plugins/glab/skills plugins/glab/agents` shows no old directory or file.
- A3 — *Final check* step 3: `jq -r .version plugins/glab/.claude-plugin/plugin.json` prints `0.15.0`; `sed -n '/^## Renamed in 0\.15\.0$/,/^## Coming from the copy install$/p' README.md | /usr/bin/grep -cE '^\| `[a-z-]+` \| `glab:project-[a-z-]+` \|$'` prints `14`; `/usr/bin/grep -c 'glab:<old agent>' README.md` prints `1`.
- A4 — F13: `/usr/bin/grep -c 'prefix does not always say the level' plugins/glab/skills/session-rules/SKILL.md` and `/usr/bin/grep -c 'plan-report' plugins/glab/skills/product-manager/SKILL.md` each print `0`. P1: `/usr/bin/grep -A3 'seven skill directories' README.md` shows R2's four lines. R7: `sed -n 9p README.md | /usr/bin/grep -c '`/glab:project-ship`, `/glab:project-plan-report`, which'` prints `1` and `sed -n 9p README.md | /usr/bin/grep -c 'which the project level runs'` prints `0`.
- A5 — Both gate blocks of `AGENTS.md` *Gates* as written after S1: green as `AGENTS.md` then states — nine `rc=0`, shellcheck `rc=0`, `PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 13/13`, `PASS 17/17`; three `✔ Validation passed`; `Skills (21)` and `Agents (9)` naming exactly R3's lists; the hooks lines; `glab = glab`, `memory-sync = memory-sync`; `:0 :0 rc=1`; `1 1 1 rc=0`; the nine model lines and eighteen skills lines exactly as `AGENTS.md` lists them (as sets), none `MISSING`; no prefixed `name:`, `rc=1`.
- A6 — Mutant (D18): `sed -i 's/glab:project-manager/glab:manager/' plugins/glab/scripts/manager-bootstrap.sh`, then `tests/manager-bootstrap.test.sh` and `tests/product-loop.test.sh` each end in something other than `PASS n/n`; then restore with the reverse `sed -i 's/glab:manager/glab:project-manager/' plugins/glab/scripts/manager-bootstrap.sh` — not `git checkout`, which would also undo S1d there, the file's S1d change being unstaged — and re-run both tests to `PASS`.
- A7 — Commit: one Conventional Commit, e.g. `refactor(skills): rename the project level to glab:project-* (glab 0.15.0)`, holding S1's changes and the slug-level files `../master.md`, `../master.sha256`, `../index.md`, `../evidence.md`, `../audit.md` with this folder (`../master.md` *Final check* step 7). `plan/SESSION-HANDOFF.md` is never committed.
- A8 — Back-out: before the commit, `git restore --source=0a44fac --staged --worktree -- plugins README.md AGENTS.md tests`; after it, `git revert <sha>`.

## Tests and coverage

No test is added. Updated by S1d, as expected strings: `tests/manager-bootstrap.test.sh:37`, `tests/product-loop.test.sh` (15 lines), `tests/plan-gate.test.sh:305` (test data, E4). Coverage, per step (`AGENTS.md` *Tests*):

- S1a — the plugin gates (skills, agents, model and skills gates name every moved file, and a `name:` that does not match fails the skills gate);
- S1d — `manager-bootstrap` and `product-loop` cases on the hook text (A6 proves they see it), the skills gate on `skills:` entries; the Markdown text by A1 only (no gate, `AGENTS.md`);
- S1b, S1c, S1g — A1, A3, A4 searches only (R7 by A4's last check): Markdown has no gate;
- S1e — A5's comparison with the CLI output;
- S1f — A3;
- P5's comment lines in `plan-gate.sh` — A1 only; no test reads a comment, accepted.

## Dry run

A clone of `0a44fac` under `$TMPDIR` (`git clone --no-hardlinks`), S1 extracted from this file with `awk '/^```bash$/{f=1; next} /^```$/{f=0} f' plan.md` (76 lines) and run with `bash`, then After's checks; the clone was removed afterwards. Output, 2026-11-14:

```
S1: "S1 done", rc=0; git status: 14 RM, 14 M (28 files, 274+ 248-); nothing outside plugins README.md AGENTS.md tests
A1: first search rc=1, no line; second search 0
A2: the 14 name: project-* lines; skills/ and agents/ hold no old name
A3: 0.15.0 ; 14 ; 1
A4: 0 ; 0 ; session-rules:10 ends "…to fit its budget." ; README "- seven skill directories under `skills/`: `bootstrap`, `manager`," and R2's three lines after it
A5: nine "<script> rc=0"; shellcheck rc=0
    PASS 35/35  PASS 24/24  PASS 51/51  PASS 13/13  PASS 17/17   (0 lines neither ok nor the last)
    ✔ Validation passed ×3
    Skills (21)  audit, bootstrap, comments, commit, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-verdict, project-analyze, project-develop, project-integrate, project-manager, project-plan, project-plan-report, project-review, project-ship, push, security, session-rules
    Agents (9)  project-planner, product-planner, project-developer, project-integrator, product-analyzer, committer, project-analyzer, project-reviewer, project-plan-analyzer
    Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
    Skills (1)  sync-memory / Agents (0) / Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab ; memory-sync = memory-sync ; hooks.json:0 :0 rc=1 ; 'not yet confirmed' 1 1 1 rc=0
    model gate: 9 lines, rc=0, as a set equal to AGENTS.md's nine (diff: same)
    skills gate: 18 lines, none MISSING, as a set equal to AGENTS.md's eighteen (diff: same)
    prefixed name: no line, rc=1
    AGENTS.md:76 skills list = the CLI's Skills (21) list, in order; agents list sorted = the CLI's Agents (9) sorted
A6: mutant (hook back to glab:manager): manager-bootstrap FAIL 5/13, product-loop FAIL 1/17; restored by the reverse sed: PASS 13/13, PASS 17/17
A8: git restore --source=0a44fac --staged --worktree -- plugins README.md AGENTS.md tests → rc=0, git status empty
```

Round 2 (after the plan check's two lows, R6's `grep -qx` lines and R7), S1 re-run once in a new clone of `0a44fac` (80 lines), then step 2 and A2 only; the clone was removed:

```
S1: "S1 done", rc=0; 14 RM, 14 M
A1: first search rc=1, no line; second search 0
A2: 14 name: project-* lines; 0 old names in skills/ or agents/
R7: README.md:9 "`/glab:project-ship`, `/glab:project-plan-report`, which" 1; "which the project level runs" 0
```

What the run does not prove: that a user's installed 0.14.1 copy picks up the renames on update (the version string is the mechanism, `AGENTS.md` *Rules*; not run here, since no agent installs a plugin).
