# Result — bug-reviewer-findings, slices 3 and 4

Plan revision 2, HEAD `bc2e399`, branch `main`. Nothing committed, staged or pushed
(`git diff --cached --stat | wc -l` -> `0`).

**Contract read.** The repo had no `AGENTS.md` when this run started — S4.1 creates
it. The root `CLAUDE.md` is published payload, not a working agreement for this repo,
so this run had no working agreement; the contract was `plan.md`, the two answers
sections of `questions.md`, and the dispatch message. Starting state was 14 modified
files plus untracked `plan/` and `tests/` (slices 1 and 2), as announced; B1.1 was
not expected to read clean and was not "fixed".

## Stages

Line numbers are post-edit.

| step | state | where |
|---|---|---|
| S3.1 | done | `host.example.md:1-23` (new; identical to the plan literal — `diff` against plan lines 699-723 differs only by the two fence lines) |
| S3.2 | done | `CLAUDE.md:4` |
| S3.3 | done | `CLAUDE.md:19-26` |
| S3.4 | done | `skills/bootstrap/SKILL.md:3` (both replacements) |
| S3.5 | done | `skills/bootstrap/SKILL.md:65` |
| S3.6 | done | `skills/bootstrap/SKILL.md:108` |
| S3.7 | done | `skills/bootstrap/SKILL.md:114` |
| S3.8 | done | `skills/bootstrap/SKILL.md:117-126` |
| S3.9 | done | `skills/bootstrap/SKILL.md:128-136` |
| S3.10 | done | `skills/bootstrap/SKILL.md:138` |
| S3.11 | done | `skills/bootstrap/SKILL.md:163` |
| S3.12 | done | `skills/bootstrap/SKILL.md:179` |
| S3.13 | done | `agents/analyzer.md:48`, `agents/reviewer.md:73` |
| S3.14 | done | `commands/develop.md:14` |
| S4.1 | done | `AGENTS.md:1-67` (new) |
| S4.2 | done | `settings.example.json:1-39` (new) |
| S4.3 | done | `README.md:1-73` (whole file replaced) |
| S4.4 | folded into S4.3 | — |
| S4.5 | folded into S4.3 | — |

17 done, 2 folded, 0 blocked.

`AGENTS.md`, `settings.example.json` and `README.md` were extracted mechanically
from the plan's fenced blocks (plan lines 863-929, 937-975, 990-1062, two-space list
indent stripped), not retyped, so they are the plan literal byte for byte.

## Blocked

Nothing.

## Unplanned changes

None. Every hunk maps to a named step.

In the three files slice 2 also edited, the only lines this run changed are
`agents/analyzer.md:48`, `agents/reviewer.md:73`, `commands/develop.md:14`
(word-diff against HEAD shows slice 2's hunks at analyzer `:18`, reviewer
`:13,15,55,57,86,90,92,98`, develop `:6` still present).

Files outside the boundary, checksummed before and after this run — all `OK`:
`skills/manager/SKILL.md`, `memory-sync.sh`, `tests/memory-sync.test.sh`,
`skills/sync-memory/SKILL.md`.

## Moved lessons — where each was, where it is now

Marker sweep (`/usr/bin/grep -n -E 'TODO|FIXME|HACK|NOTE|XXX'`) before editing:
no markers in `CLAUDE.md`, `README.md`, `agents/analyzer.md`, `commands/develop.md`;
only the two sentences that mention the words (`skills/bootstrap/SKILL.md:41`,
`agents/reviewer.md:15`), both untouched.

| lesson | was | now |
|---|---|---|
| `/tmp` is a tmpfs under a per-user quota shared by every agent; `EDQUOT` kills the Bash tool; cannot be repaired from inside; growing the tmpfs does not help (`size=` vs `usrquota`); `export TMPDIR=…` before `go`; say it in every dispatch | `skills/bootstrap/SKILL.md:117-125` (baseline) | in full, verbatim, `host.example.md:11-19`; one correction per plan: `/tmp/claude-1000/` -> `/tmp/claude-<uid>/`. Summary plus pointer kept at `skills/bootstrap/SKILL.md:123-126` |
| Same lesson, short form, and "bootstrap explains why remounting does not help" | `CLAUDE.md:19-25` (baseline) | `CLAUDE.md:19-26` now points at `~/.claude/host.md` and at `bootstrap` step 6, which points at `host.example.md` where the remounting explanation lives |
| "dispatch messages must repeat the temp rule, unique filenames, clean up" | bootstrap `:123-125`, `CLAUDE.md:20-21` | kept in both replacements (`bootstrap:119-120`, `CLAUDE.md:21-22`) and in `host.example.md:17-19` |
| `grep` is ugrep; zero matches with no error for a leading alternation group | `skills/bootstrap/SKILL.md:127-129` | `skills/bootstrap/SKILL.md:128,131-133`, re-attributed to the Bash-tool shell function and worded as an observation ("has also been observed returning") |
| `\s` inside a bracket expression means literal `\` and `s` | bootstrap `:128-129` | bootstrap `:129-131`, now with the concrete `foo[\s]bar` case |
| `golang.org/x/tools` silently excluded from a dependency audit | bootstrap `:129-130` | bootstrap `:133-134` |
| Use the system grep for anything load-bearing; prove a pattern on a known positive | bootstrap `:130-132` | rule at bootstrap `:134-136` as `command grep`; the host path `/usr/bin/grep` at `host.example.md:23` |
| Four Go/PostgreSQL hazards (receiver name, truncated query, cached test, capped linter) | bootstrap `:134-160` | same place, text unchanged except `Measured here:` -> `Measured in one repo:`; new attribution sentence at `:138` |
| DSN password leak | bootstrap `:168-174` | same place; `leaked one here.` -> `leaked one.` |
| `make ci` / `make ci-all` false green; stale handoff | bootstrap `:65`, `:108` | same place, re-attributed (`In one backend`, `in one repo`) |
| `make lint` -> `go generate` across 85 mockgen directives | `agents/analyzer.md:48` | same line, `in one repo` |
| README note that some text is machine-specific (`:30-32`) | `README.md:30-32` | replaced, as the plan states, by install step 1 (`README.md:32-35`) and the `host.example.md` row (`:19`) |

Nothing was deleted without a destination.

## Tests

No behaviour-changing code in these slices: prose, one JSON example, no script
edited. No test added or changed. Per `AGENTS.md` `## Tests` (Q11) coverage is a
per-step list, not a number:

| step | covered by | not covered, and why accepted |
|---|---|---|
| S3.1 | P3.4 (5), `diff` vs plan literal | — |
| S3.2, S3.3 | P3.1 (absence), P3.3 (`CLAUDE.md: 2`) | wording beyond the probes — read in review |
| S3.4-S3.7, S3.11, S3.12 | P3.1, P3.2 probes 1-3 and 6 | S3.4 and S3.12 have no positive probe in the plan; P3.1 absence only |
| S3.8 | P3.2 `per-user quota`, P3.3 | — |
| S3.9 | P3.2 `command grep`, `observed returning`, `golang.org/x/tools` | — |
| S3.10 | P3.2 `one Go and PostgreSQL project` | — |
| S3.13, S3.14 | P3.5 | — |
| S4.1 | P4.4, P4.5, P4.9 (last two) | — |
| S4.2 | P4.1, P4.2, P4.3, `jq .` | `~` expansion in a hook command — UNVERIFIED in the plan (B4), not run here |
| S4.3 | P4.6-P4.10 | — |

## Gates

No markdown lint exists in this repo; the prose gates are the P-blocks below.
All run from the repo root with `export TMPDIR=/data/tmp/claude`.

```
bash -n memory-sync.sh && bash -n manager-bootstrap.sh; echo "rc=$?"
rc=0
shellcheck memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
rc=0                                  (no finding lines)
bash tests/memory-sync.test.sh memory-sync.sh; echo "rc=$?"
ok T01 … ok T24 (24 lines, in order)
PASS 24/24
rc=0
jq . settings.example.json >/dev/null; echo "rc=$?"
rc=0
```

### Slice 3 post-conditions

| check | expected | actual |
|---|---|---|
| P3.1 | `rc=1`, no other line | `rc=1`, no other line. Positive control: same pattern on `git show HEAD:skills/bootstrap/SKILL.md` -> `10` |
| P3.2 | 9 lines each `: 1` | `In one backend: 1`, `a handoff in one repo: 1`, `in a real session: 1`, `command grep: 1`, `one Go and PostgreSQL project: 1`, `Measured in one repo: 1`, `observed returning: 1`, `golang.org/x/tools: 1`, `per-user quota: 1` |
| P3.3 | `CLAUDE.md: 2` / `skills/bootstrap/SKILL.md: 2` | `CLAUDE.md: 2` / `skills/bootstrap/SKILL.md: 2` |
| P3.4 | `5` | `5` |
| P3.5 | `1` `1` `1` | `1` `1` `1` |
| P3.6 | no output | no output |

### Slice 4 post-conditions

| check | expected | actual |
|---|---|---|
| P4.1 | five lines | `SessionStart ~/.claude/memory-sync.sh pull 20` / `SessionStart ~/.claude/manager-bootstrap.sh 5` / `SessionEnd ~/.claude/memory-sync.sh push 20` / `PostToolUse ~/.claude/memory-sync.sh push-if-changed 20` / `Stop ~/.claude/memory-sync.sh push-if-changed 20` |
| P4.2 | `AWS_PROFILE` `CLAUDE_MEMORY_S3_ARGS` `CLAUDE_MEMORY_S3_URI` | same three, same order |
| P4.3 | `rc=0`, no key | `rc=0`, no key |
| P4.4 | Gates, Tests, Rules, Commits | `## Gates` `## Tests` `## Rules` `## Commits` |
| P4.5 | three `rc=0`; `rc=0`; T01-T24 ok; `PASS 24/24` | the three commands extracted from `AGENTS.md` by `awk` and run unedited: `memory-sync.sh rc=0`, `manager-bootstrap.sh rc=0`, `tests/memory-sync.test.sh rc=0`, `rc=0`, `ok T01` … `ok T24`, `PASS 24/24` |
| P4.6 | five headings | ``## Installed to `~/.claude` `` `## Repo only` `## Requirements` `## Install` `## Wiring` |
| P4.7 | `AGENTS.md` `host.example.md` `plan/` `settings.example.json` `tests/` | identical, in that order, both in the default locale and under `LC_ALL=C` (no locale difference) |
| P4.8 | `rc=1`, no other line | `rc=1`, no other line. Positive control on `git show HEAD:README.md` -> `1` |
| P4.9 | first eight `README.md:1 AGENTS.md:0`, last two `README.md:0 AGENTS.md:1` | exactly that, all ten lines |
| P4.10 | `1` `2` `1` | `1` `2` `1` |

### After phase

| check | expected | actual |
|---|---|---|
| A1 | three `rc=0`; shellcheck `rc=0`; `PASS 24/24` | as P4.5 and the gates above |
| A2 | the named list | 17 ` M` lines exactly as listed; `??` `AGENTS.md`, `host.example.md`, `settings.example.json`, `tests/memory-sync.test.sh`, and under `plan/bug-reviewer-findings/`: `findings.md`, `memory-sync.test.sh`, `plan.md`, `questions.md`, `result-slice1.md`, `result-slice2.md` (this file is added after the check). Nothing else |
| A3.1 | `s3://<bucket>` `s3://my-bucket` `s3://stub` | same three |
| A3.2 | `endpoint-url=...` | `endpoint-url=...` |
| A3.4 | `0` | `0` (before the run also `0`) |

A3.3 is manager-run and optional; not run — it needs the live env values, which
this run was told not to read.

Shared temp directory: 52 entries before this run, 52 after (peak 53: one checksum
file and one extracted-gates file of mine, both `s34-*`, both removed;
`ls | grep -c '^s34-'` -> `0`). No process was started that needed killing.

## Blast radius (`security`)

- **A session loading the new `CLAUDE.md` / `bootstrap` with no `~/.claude/host.md`**
  no longer has `/data/tmp/claude` written into its instructions. It must say the
  machine has no host file, then use `$TMPDIR` if set, else its scratchpad — which
  on the author's host is under the quota-limited `/tmp`. So on this machine the
  temp-directory mandate lapses unless `host.md` is created before the payload is
  installed (README install step 1, plan A4). It also loses the literal
  `/usr/bin/grep` path; `command grep` in `bootstrap` covers that without a host file.
- **Not in effect yet.** Q1 repo-only: nothing was copied, symlinked or installed.
  `ls ~/.claude/host.md` -> `No such file or directory` before and after; the live
  `~/.claude/CLAUDE.md` is still the old text. Proven: no command in this run wrote
  under `~/.claude`. `~/.claude/settings.json` was not read.
- **Who reads `AGENTS.md`.** From now on every agent and command run in this repo
  (developer, analyzer, reviewer, committer, integrator, the eight commands,
  `bootstrap` step 1) reads it instead of falling back to `CLAUDE.md`. Effects: the
  reviewer runs its compliance pass against it rather than "correctness only"; the
  committer takes the commit format from `## Commits`; the stub-on-`PATH` and
  list-coverage exception applies to shell scripts here. It is repo-only and is not
  installed, so no other repo is affected.
- **`AGENTS.md` `## Gates` says "the temp directory your host file names"** — with
  no `host.md` on this machine a reader has to take `TMPDIR` from elsewhere.
  INFERRED consequence, not a defect in the build; see follow-ups.
- **Rollback (before commit), plan A6:** slice 4 first —
  `git restore -- README.md` and `rm AGENTS.md settings.example.json`; then slices
  2 + 3 together (shared files) per A6 unit 2, including `rm host.example.md`.
  The three slice-4/3 new files are untracked: their removal is unrecoverable
  except from the plan literals, which hold all four in full. Runtime: nothing to undo.
- UNVERIFIED: Claude Code expands `~` in a hook command string — plan B4, not run.
- UNVERIFIED: the new skill text behaves as intended in a live session — no session
  was started with it (repo only).

## Manager suggestions

- (a) A5 cites "S4.3-S4.5": treated as S4.3. `plan.md` not edited; stale reference
  remains at plan `:1252`.
- (b) A3.4: reported as before/after (`0` / `0` for `memory-sync-test`; directory
  52 -> 52).
- (c) `agents/developer.md:15` wording and `commands/commit.md:6` double dash: left
  untouched; neither file was opened for editing.

## Follow-ups

`follow-ups.md` was not written: the dispatch limits writes under `plan/` to this
file. To carry over:

- The plan's own list (`plan.md:1319-1328`): tombstones, `install.sh --check`,
  `.gitignore`, a Markdown check, `delete` vs `MEMORY.md`, the unreproduced pull race.
- Plan `A5` still cites the folded steps S4.4-S4.5.
- `AGENTS.md` `## Gates` depends on a host file that does not exist on the author's
  machine until the user creates it (A4, first bullet).
- Slice 2's two cosmetic items (`agents/developer.md:15`, `commands/commit.md:6`).
- S3.4 and S3.12 have no positive probe in the plan's post-conditions.

## Not done

- Slices 1 and 2 — not in scope, not touched.
- A3.3, A4 (user actions on the live machine), A6 (no back-out performed).
- `/integrate`: nothing to run, per the plan.
