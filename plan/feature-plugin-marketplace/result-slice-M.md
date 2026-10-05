# Result — feature-plugin-marketplace, Slice M

Scope: steps M1–M7 only (the `git mv` moves). Run 2026-10-05 on `main` at
`2aeb46d`. No content was edited, nothing was committed, nothing was staged
beyond what `git mv` stages. Slices G, S and D were not started.

## Stages

| Step | State | What moved |
|---|---|---|
| M1 | done, rc=0 | `skills/{audit,bootstrap,comments,manager,plan-first,security}/` → `plugins/glab/skills/` (7 files) |
| M2 | done, rc=0 | `agents/` → `plugins/glab/agents/` (5 files) |
| M3 | done, rc=0 | `commands/` → `plugins/glab/commands/` (8 files) |
| M4 | done, rc=0 | `manager-bootstrap.sh` → `plugins/glab/scripts/manager-bootstrap.sh` |
| M5 | done, rc=0 | `skills/sync-memory/` → `plugins/memory-sync/skills/sync-memory/`; `rmdir skills` |
| M6 | done, rc=0 | `memory-sync.sh` → `plugins/memory-sync/scripts/memory-sync.sh` |
| M7 | done, rc=0 | `settings.example.json` → `plugins/memory-sync/settings.example.json` |

Each block was run exactly as written in `plan.md`, in order, under `set -e`.

## Blocked

Nothing.

## Unplanned changes

None. No hunk outside M1–M7.

## Preconditions (`before`)

B1 — `git status --short | /usr/bin/grep -v '^?? plan/' ; git rev-parse --short HEAD`

    2aeb46d

B2 — baseline gates at the old paths, `TMPDIR=/data/tmp/claude`

    memory-sync.sh rc=0
    manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    PASS 35/35

B3 — `claude` is not on `PATH`; `readlink /proc/$PPID/exe` printed
`/home/pvhv/.claude/remote/ccd-cli/2.1.286` (read only, nothing written
there). Run with a throwaway config directory:

    cfg=/data/tmp/claude/plugplan-config.mLEqog
    2.1.286 (Claude Code)
    rc=0
    removed; exists? no

The CLI was run this once (`--version`) and not again. The B3 shell was not
kept: the Bash tool does not keep shell state between calls, so V2 and V3 —
which are not Slice M's — need the prelude run again by whoever runs them.

## After M1–M7 — command output

`git status --short`

    R  agents/analyzer.md -> plugins/glab/agents/analyzer.md
    R  agents/committer.md -> plugins/glab/agents/committer.md
    R  agents/developer.md -> plugins/glab/agents/developer.md
    R  agents/integrator.md -> plugins/glab/agents/integrator.md
    R  agents/reviewer.md -> plugins/glab/agents/reviewer.md
    R  commands/analyze.md -> plugins/glab/commands/analyze.md
    R  commands/commit.md -> plugins/glab/commands/commit.md
    R  commands/develop.md -> plugins/glab/commands/develop.md
    R  commands/integrate.md -> plugins/glab/commands/integrate.md
    R  commands/plan.md -> plugins/glab/commands/plan.md
    R  commands/push.md -> plugins/glab/commands/push.md
    R  commands/review.md -> plugins/glab/commands/review.md
    R  commands/ship.md -> plugins/glab/commands/ship.md
    R  manager-bootstrap.sh -> plugins/glab/scripts/manager-bootstrap.sh
    R  skills/audit/SKILL.md -> plugins/glab/skills/audit/SKILL.md
    R  skills/audit/references/plan-template.md -> plugins/glab/skills/audit/references/plan-template.md
    R  skills/bootstrap/SKILL.md -> plugins/glab/skills/bootstrap/SKILL.md
    R  skills/comments/SKILL.md -> plugins/glab/skills/comments/SKILL.md
    R  skills/manager/SKILL.md -> plugins/glab/skills/manager/SKILL.md
    R  skills/plan-first/SKILL.md -> plugins/glab/skills/plan-first/SKILL.md
    R  skills/security/SKILL.md -> plugins/glab/skills/security/SKILL.md
    R  memory-sync.sh -> plugins/memory-sync/scripts/memory-sync.sh
    R  settings.example.json -> plugins/memory-sync/settings.example.json
    R  skills/sync-memory/SKILL.md -> plugins/memory-sync/skills/sync-memory/SKILL.md
    ?? plan/feature-plugin-marketplace/

24 lines starting `R`; 0 lines that are neither `R  ` nor the `plan/` line.
`git diff --stat | wc -l` (unstaged changes) printed `0`.

`git diff --cached -M --name-status HEAD` — 24 lines, all `R100`:

    R100	agents/analyzer.md	plugins/glab/agents/analyzer.md
    R100	agents/committer.md	plugins/glab/agents/committer.md
    R100	agents/developer.md	plugins/glab/agents/developer.md
    R100	agents/integrator.md	plugins/glab/agents/integrator.md
    R100	agents/reviewer.md	plugins/glab/agents/reviewer.md
    R100	commands/analyze.md	plugins/glab/commands/analyze.md
    R100	commands/commit.md	plugins/glab/commands/commit.md
    R100	commands/develop.md	plugins/glab/commands/develop.md
    R100	commands/integrate.md	plugins/glab/commands/integrate.md
    R100	commands/plan.md	plugins/glab/commands/plan.md
    R100	commands/push.md	plugins/glab/commands/push.md
    R100	commands/review.md	plugins/glab/commands/review.md
    R100	commands/ship.md	plugins/glab/commands/ship.md
    R100	manager-bootstrap.sh	plugins/glab/scripts/manager-bootstrap.sh
    R100	skills/audit/SKILL.md	plugins/glab/skills/audit/SKILL.md
    R100	skills/audit/references/plan-template.md	plugins/glab/skills/audit/references/plan-template.md
    R100	skills/bootstrap/SKILL.md	plugins/glab/skills/bootstrap/SKILL.md
    R100	skills/comments/SKILL.md	plugins/glab/skills/comments/SKILL.md
    R100	skills/manager/SKILL.md	plugins/glab/skills/manager/SKILL.md
    R100	skills/plan-first/SKILL.md	plugins/glab/skills/plan-first/SKILL.md
    R100	skills/security/SKILL.md	plugins/glab/skills/security/SKILL.md
    R100	memory-sync.sh	plugins/memory-sync/scripts/memory-sync.sh
    R100	settings.example.json	plugins/memory-sync/settings.example.json
    R100	skills/sync-memory/SKILL.md	plugins/memory-sync/skills/sync-memory/SKILL.md

Mode bits — `test -x` with `stat -c %a`, then `git ls-files -s`:

    executable plugins/glab/scripts/manager-bootstrap.sh 775
    executable plugins/memory-sync/scripts/memory-sync.sh 755
    executable tests/memory-sync.test.sh 755
    100755 plugins/glab/scripts/manager-bootstrap.sh
    100755 plugins/memory-sync/scripts/memory-sync.sh
    100755 tests/memory-sync.test.sh

The on-disk modes are the ones the files had before the move (775, 755, 755,
read at B3 time).

Old directories — `ls -d skills agents commands 2>/dev/null | wc -l` printed
`0`. Repo root now holds: `.git AGENTS.md CLAUDE.md README.md host.example.md
plan plugins tests`.

Nested repositories — `git status --short -uall | /usr/bin/grep '/$'` printed
nothing (rc=1): none.

## Tests

No test was added or changed (the plan adds none; `tests/` is in no slice).
Coverage as a list, per `AGENTS.md`: M6 is covered by all 35 cases run against
the new path. M1–M5 and M7 move Markdown and JSON, which have no gate; they
are checked by P1 and P2 below.

`export TMPDIR=/data/tmp/claude; bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh`

    test rc=0
    35 lines starting "ok"
    PASS 35/35   (the only line not starting "ok")

## Gates

V1 as the plan writes it, at the new paths:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0            (shellcheck, no findings)
    PASS 35/35

Build ok (`bash -n`), tests ok, lint ok (`shellcheck`). No fix-mode tool ran.

The gate block in `AGENTS.md:15-17` still names the old paths and is red if
run as written until D4 lands — see Blast radius.

## Post-conditions — actual next to expected

Belonging to Slice M and green now:

| Check | Expected (finished) | Actual | State |
|---|---|---|---|
| P1, command 2 (old directories) | `0` | `0` | green |
| P2, all three commands | `24`; three `100755`; three `executable` | `24`; three `100755`; three `executable` | green |
| P12, first line (audit link) | `link-ok` | `link-ok` | green |
| P13, commands 1 and 3 (script code, tests untouched) | `0`, `0` | `0`, `0` | green |
| V1 | three `rc=0`, `rc=0`, `PASS 35/35` | the same | green |

Partly Slice M's, not finished — not green:

| Check | Expected (finished) | Actual now | Waits for |
|---|---|---|---|
| P1, command 1 (tracked files at old paths) | `0` | `1` — the root `CLAUDE.md` | G15 |
| P1, command 3 (path list) | 29 paths | the 24 moved paths; the 5 new files are absent | G1, G2, S1, S2, D1 |
| P13, command 2 (changed comment lines) | `7` | `0` | S8 |

Not Slice M's and not run: P3–P11, P12 second part, P14–P17, V2, V3. They
depend on G, S and D. None of them is claimed green.

## Blast radius

24 files moved; no other file changed. Until G, S and D land, these still name
the old paths (found with `/usr/bin/grep`, not edited):

- `AGENTS.md:15-17` — the three gate commands name `memory-sync.sh` and
  `manager-bootstrap.sh` at the root. Run as written they now fail. Fixed by
  D4. Until then use the V1 form above.
- `AGENTS.md:51-55` — the "one fact, one value" list names
  `agents/reviewer.md`, `commands/ship.md`, `skills/manager/SKILL.md`,
  `skills/bootstrap/SKILL.md`, `settings.example.json`,
  `skills/sync-memory/SKILL.md`. Fixed by D6.
- `README.md:16-17, 29, 39, 50, 58, 63-66` — the file table, the `cp -a`
  install line and the settings instructions. The `cp -a skills agents
  commands … ~/.claude/` at `:50` no longer works. Replaced whole by D2.
- `CLAUDE.md` (root) — still present; deleted by G15.
- Text inside the moved files that names `~/.claude/memory-sync.sh`, and the
  comment in the script that names `settings.example.json` as holding the
  hook timeout — S4–S8.
- `tests/memory-sync.test.sh` takes the script path as its argument and needs
  no change.

Outside the repo: nothing under `/home/pvhv/.claude` was read for content or
written. The installed copies there are separate files and are unaffected.

`git log --follow` on a moved path shows history only once the rename is
committed; `R100` on all 24 is the evidence available before that.

## Rollback

Slice M cannot be backed out on its own once G, S or D sit on top of it (plan,
`## Back-out`). Right now, with only M applied, the plan's "everything" unit
applies with `.claude-plugin` left out, because D1 has not created it:

    git status --short        # read it first
    git restore --source=HEAD --staged --worktree -- . && rm -r plugins

That returns the tree to `2aeb46d` with `plan/` untouched. It was not run
here. `rm -r plugins` is safe only while `plugins/` holds nothing but the
moved files; after G or S it would also remove their new, untracked files.

## Follow-ups

None written. Nothing out of scope was found that the plan does not already
assign to G, S or D.

## Not done

- Slices G (G1–G15), S (S1–S8) and D (D1–D9): another developer's.
- The smoke test: the user's.
- No commit, no push.
