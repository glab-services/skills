# Result — feature-docs-specs, Slices S and M

Developer for Slice S (`docs/specs/` only) and then Slice M (the migration),
2026-10-17. Working agreement: `AGENTS.md`, read from disk (its gate line
greps `Not yet shown: any reply from a DeepSeek model`). Every source record
was read from the tree or from `git show 6838133:` before M removed it; the
payload was read at `6838133` because Slice P was editing it at the same
time. Nothing staged, committed or pushed.

## Stages

| step | status | where |
|---|---|---|
| S1 `docs/specs/marketplace.md` | done | new, 144 lines: *How it works now* :12, *Decisions* :75, *Known limits* :94, *Open* :101, *Closed* :106, *Incidents* :118, *Records* :128 |
| S2 `docs/specs/workflow.md` | done | new, 206 lines: :16, :111, :152, :160, :177, :190, :197 (same order) |
| S3 `docs/specs/memory-sync.md` | done | new, 213 lines: :14, :88, :98 (smoke test part 3 copied at :106-152, block :113-120), :155, :184, :188, :197 |
| S4 `docs/specs/external-agents.md` | done | new, 727 lines: *How it works now* :15, *Isolation* :98, *Measurements* :169, *Allowlist* :227, *Profiles* :260, *Decisions* :291, *Known limits* :370, *Offline run* :386 (block :400-423, recorded :427-443), *Live runs* :460 (L1a block :471-482, runner block :500-535, `### 2026-10-17 — L1` :576), *Open* :645, *Closed* :675, *Incidents* :692, *Records* :703 |
| M1 remove the seven folders' tracked files | done | worktree deletions only, 124 files, after B2 |

How the byte-for-byte blocks were made (copied, never retyped): the offline
section (`plan-r3.md:2572-2630`) and the L1a block (`:2762-2773`) were cut
with `awk` from `git show 6838133:plan/feature-opencode-worker/plan-r3.md`;
the runner block is `git show 6838133:…/probe-r3/runner.sh` between two
four-backtick fences; smoke test part 3 was cut with `sed` from
`git show b853635:plan/feature-plugin-marketplace/plan.md` with three
substitutions, shown by `diff`: the two fences widened to four backticks,
`mktemp -d /data/tmp/claude/smoke-stub.XXXXXX` → `mktemp -d "${TMPDIR:?}/smoke-stub.XXXXXX"`,
and the closing "`/data/tmp/claude`, then" → "`$TMPDIR`, then". The L1a
block was once typed by hand in a draft; that copy was cut out and replaced
by the extracted lines before assembly. `check.sh` section 7 then printed
`ok` for all three blocks.

B2, before M1:

    $ git rev-parse HEAD origin/main
    6838133e0a5c1d402fa2198f95d736f2e59d6932
    6838133e0a5c1d402fa2198f95d736f2e59d6932
    $ git merge-base --is-ancestor 6838133 origin/main; echo "merge-base rc=$?"
    merge-base rc=0
    $ GIT_TERMINAL_PROMPT=0 timeout 30 git ls-remote origin refs/heads/main
    6838133e0a5c1d402fa2198f95d736f2e59d6932	refs/heads/main

(`git fetch` was not run, as the dispatch said; `ls-remote`, which only reads,
shows the remote's `main` is `6838133`.) The seven folders were clean
(`git status --short -uall -- plan/<seven>` printed nothing, rc 0) and held
124 tracked files. M1's loop, exactly as `plan.md` gives it:

    bug-reviewer-findings removed=10 left=0
    feature-model-switch removed=2 left=0
    feature-opencode-worker removed=96 left=0
    feature-plugin-marketplace removed=8 left=0
    fix-external-report-lines removed=2 left=0
    fix-probe-findings removed=3 left=0
    sync-local-edits removed=3 left=0

No `STOP` line. `git diff --cached --stat` printed nothing; `git status`
shows 124 ` D plan/…` lines.

## Blocked

None.

## Unplanned changes

None. Paths written: the four `docs/specs/*.md` (new, untracked) and this
file; paths removed: the 124 tracked files of the seven folders (unstaged).
No file under `plugins/`, `README.md`, `AGENTS.md` or the rest of
`plan/feature-docs-specs/` was touched.

Two judgement calls inside the *Spec rules*, reported so a reader can check
them:

- Three open items that no follow-ups list numbered sat only in open-items
  sections. Each is under *Open follow-ups* with its section's `L<n>` tag,
  as well as on its *Records* line: `[bug-reviewer-findings/result-slice1.md L220]`
  (memory-sync.md: no case tells pull's `rsync` and `delete`'s `rm` inside
  `bounded` from bare calls, and no deterministic `$SECONDS` case),
  `[bug-reviewer-findings/result-review1-prose.md L109]` and
  `[bug-reviewer-findings/result-slice2.md L99]` (workflow.md: the
  bootstrap one-line check could name the host file; `reviewer.md`'s
  description still names `AGENTS.md` only).
- `[bug-reviewer-findings/follow-ups.md 18]`: `findings.md` says the
  `developer.md:15` half is gone. At `6838133` that line still reads
  `` `AGENTS.md` (or `CLAUDE.md` if the repo has none — say so) — the working agreement. ``
  (`git show 6838133:plugins/glab/agents/developer.md | sed -n 15p`). The
  spec records both halves as open and quotes the line, rather than the
  findings' status.

## Tests

No test file changes: S is prose and M is removals. Coverage as a list
(`AGENTS.md` *Tests*):

- S1–S4 — `check.sh` sections 2 (no stale citation), 3 (each folder's
  *Records* line and its recovery commit), 4 (`tags 186/186 in place`, each
  under the heading its kind allows), 5 (nine `ok   decisions` lines), 6
  (headings exactly, none empty), 7 (offline, L1a and runner blocks byte for
  byte; the runner parses), 11 (*Measurements* and *Allowlist* values), 12
  (no listed leak pattern — an absence check), 13 (`Q1=A`: no notes in the
  tree, the five cited under *Profiles*). Not covered by any check: that
  each migrated status is true, that *Incidents* holds every incident, and
  that the prose reads well — the reviewer and the reader judge those.
- M1 — `check.sh` section 1 (seven `ok   removed <slug> (unstaged deletions: <n>)`)
  and section 14 (nothing left in the tree or the index under `plan/` but
  untracked files).
- Statuses re-read at `6838133` rather than taken from `findings.md`
  (each says so in the spec): bug-reviewer-findings follow-ups 1, 2, 4, 5, 6,
  9, 10, 17, 18, 19, 20, the nested-`delete` pattern, and the bootstrap
  one-line check. Follow-up 5, which `findings.md` asked the developer to
  decide: open — the comment above `now_ms` still states the TIMEOUT + 3 s
  bound for any mode, and `left()`'s comment covers only the per-call clamp.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root, after M1, on the tree
as it stands with Slice P/R's edits in it.

`Q1=A STAGE=build bash plan/feature-docs-specs/check.sh` — 0 `FAIL` lines:

    ok   removed bug-reviewer-findings (unstaged deletions: 10)
    ok   removed feature-model-switch (unstaged deletions: 2)
    ok   removed feature-opencode-worker (unstaged deletions: 96)
    ok   removed feature-plugin-marketplace (unstaged deletions: 8)
    ok   removed fix-external-report-lines (unstaged deletions: 2)
    ok   removed fix-probe-findings (unstaged deletions: 3)
    ok   removed sync-local-edits (unstaged deletions: 3)
    ok   no stale plan/ citation
    ok   short record names: AGENTS.md:1
    ok   record bug-reviewer-findings 2aeb46d in memory-sync.md
    ok   record feature-plugin-marketplace b853635 in marketplace.md
    ok   record sync-local-edits 9700bcb in workflow.md
    ok   record feature-model-switch 889b804 in workflow.md
    ok   record feature-opencode-worker 51043c4 in external-agents.md
    ok   record fix-external-report-lines 5e9b3a8 in external-agents.md
    ok   record fix-probe-findings 6838133 in external-agents.md
    tags 186/186 in place
    ok   decisions feature-model-switch/plan.md (22)
    ok   decisions sync-local-edits/result-followups.md (12)
    ok   decisions sync-local-edits/result.md (4)
    ok   decisions feature-opencode-worker/findings.md (22)
    ok   decisions feature-opencode-worker/plan.md (44)
    ok   decisions feature-opencode-worker/plan-r3.md (45)
    ok   decisions fix-external-report-lines/plan.md (6)
    ok   decisions feature-plugin-marketplace/questions.md (9)
    ok   decisions fix-probe-findings/plan.md (11)
    ok   headings in order / no empty section: marketplace.md, workflow.md, memory-sync.md, external-agents.md (8 lines)
    ok   offline block
    ok   L1a block
    ok   runner block
    ok   runner block parses
    ok   prompt default / kimi / glm / deepseek-pro / deepseek-flash (5 lines)
    ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0
    insertions 73/73 present
    ok   rules permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6
    ok   Measurements has '2.0.31' / '1 GiB' / '256 MiB' / '1.19.3' / 'OPENCODE_API_KEY' / '0.11.1' / 'OPENCODE_DISABLE_PROJECT_CONFIG' (7 lines)
    ok   Allowlist has 'Grok'
    ok   Allowlist has '30 days'
    ok   no listed leak pattern (absence check)
    ok   Q1=A no notes in the tree
    ok   Q1=A note deepseek-flash / deepseek-pro / diff / glm / kimi cited (5 lines)
    info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: ''

(The grouped lines are one `ok` line each in the real output, folded here;
nothing else is shortened.) Before M1 the same run printed exactly seven
`FAIL removed <slug> present=yes …` lines and no other `FAIL`, which is
the half-finished state section 1 is meant to catch. The sections that
depend on Slice P/R (2b, 8, 9, 10, the `rules` line) were already `ok` when
I ran it: the other developer had finished.

First *Gates* block, exactly as `AGENTS.md` gives it:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    ms rc=0 ok=35 notok=0 last=PASS 35/35
    ea rc=0 ok=49 notok=0 last=PASS 49/49

(The two test lines are a summary of the full output, which I counted from
a file: 35 and 49 `ok` lines, no other line but `PASS`. No flake this run.)

Plugin *Gates* block, exactly as `AGENTS.md` gives it, with
`CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014` and its
own throwaway `CLAUDE_CONFIG_DIR`, removed by the block:

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

Green as `AGENTS.md` defines it. Also run: A4
`bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext | command grep -c -F -- '-> push -> record'`
→ `1`; A5 `git diff --name-only 6838133 -- . ':!plan' ':!docs' | wc -l` →
`19`, and `git ls-files -co --exclude-standard -- docs` → the four specs and
nothing else.

## Blast radius (`glab:security`)

- **Files written:** `docs/specs/marketplace.md`, `docs/specs/workflow.md`,
  `docs/specs/memory-sync.md`, `docs/specs/external-agents.md` (new,
  untracked), and this file.
- **Files removed:** the 124 tracked files under `plan/bug-reviewer-findings/`,
  `plan/feature-model-switch/`, `plan/feature-opencode-worker/`,
  `plan/feature-plugin-marketplace/`, `plan/fix-external-report-lines/`,
  `plan/fix-probe-findings/`, `plan/sync-local-edits/`, by M1's loop after its
  guard; every one is in `6838133`, which is on `origin`, so
  `git show <last>:plan/<slug>/` brings each back. Nothing untracked was
  removed. Not staged.
- **Commands run:** `git show`, `git log`, `git status`, `git ls-files`,
  `git diff`, `git rev-parse`, `git merge-base`, `git ls-remote` (read only),
  `git cat-file`; `sed`, `awk`, `cat`, `diff`, `sha256sum`, `command grep`;
  `check.sh`; both gate blocks; the two stub tests; `manager-bootstrap.sh`
  piped to `jq`.
- **Not run:** `external-agent.sh` against a real model or the real CLI (the
  offline block was copied, not run); `memory-sync.sh` against a backend;
  `git add`, `commit`, `push`, `fetch`, `rm --cached`; any plugin install,
  enable, configure or marketplace command; any service start or stop.
- **Not read:** `~/.env`, OpenCode data or auth files,
  `~/.claude/settings.json`. The probe transcripts were not opened; only the
  first lines of one `run.log` at `6838133`, already masked.
- **`claude` CLI:** only inside the gate block, under a throwaway
  `CLAUDE_CONFIG_DIR` the block removed (`ls -d /data/tmp/claude/claude-config.*`
  afterwards: `0`).
- **Processes:** the external-agent test started and cleaned up its own
  sandboxes and listeners by PID; I started nothing else in the background.
- **Temporary files:** one directory, `/data/tmp/claude/fds-SM.*` (the
  extracted blocks, the spec drafts, check and test logs), removed at the end.
  Nothing written to `/tmp`.
- **Secrets and host values:** none in the specs. `check.sh` section 12 found
  none of its patterns, and a wider search of the specs for a home path, a
  temp path, a port and `s3://` found only `s3://stub/mem` in the copied
  smoke test. The private ranges are named in words, not as addresses; the
  probe's host values stay masked as `<service-port>` and `<host-lan-ip>`.

## Follow-ups

Not written to `plan/feature-docs-specs/follow-ups.md`: the dispatch keeps
that folder off limits except for this file. For the manager:

1. **X1 must move every mention, not one bullet.** `[sync-local-edits/follow-ups.md 10]`
   appears in `workflow.md` under *How it works now* (the Spec row and the
   plan-files rule), *Decisions* (`[sync-local-edits/result-followups.md D10]`),
   *Known limits* and *Records* as well as *Open follow-ups*;
   `[fix-probe-findings/plan.md follow-up-1]` only under *Open* in
   `external-agents.md`. `check.sh` at `STAGE=record` needs only one
   occurrence under *Closed*, so it would pass with the stale mentions left.
2. **`[bug-reviewer-findings/follow-ups.md 18]`'s status** differs from
   `findings.md` (see *Unplanned changes*); worth a look by the reviewer.
3. **Facts the specs state as of `6838133`** that move with their owners and
   that no gate ties to the specs (D10 accepts this): `PASS 35/35` and
   `PASS 49/49`, the allowlist table and DeepSeek's end date, `glab 0.4.2`.
   DeepSeek's date, 2026-10-31, is two weeks out.

## Not done

- Slices P and R (`plugins/glab/**`, `README.md`, `AGENTS.md`): the other
  developer's; not touched.
- Commits C1–C4, the push, and the record X0–X5: not this dispatch's.
- B2 was checked with `rev-parse`, `merge-base` and a read-only `ls-remote`,
  not with `git fetch`, as the dispatch said.
- UNVERIFIED: that every incident of the seven folders reached a spec, and
  that every migrated status is true — `check.sh` proves tags, headings,
  blocks and presence, not truth (`plan.md` *UNVERIFIED*). Statuses not
  re-read are marked "as recorded" or "not re-checked" in the specs.

---

# Review round 1 fixes

Dispatch: review round 1/3 was `BLOCK`; `plan.md` *Amendments — review round
1/3* names SR1–SR6 for `docs/specs/` only. 2026-10-18. Slice M was not redone,
nothing under `plan/` was restored, and no file outside `docs/specs/` and this
file was touched. Nothing staged.

## Stages

| step | status | where |
|---|---|---|
| SR1 every *Records* line → the restore form | done | the plan's `sed`, run as given on `docs/specs/*.md`: before, `plan: \`git show` counted 3/2/1/3 (external-agents/marketplace/memory-sync/workflow); after, `plan: \`git restore` counts the same nine and `git show`-form lines are 0. Lines: external-agents.md:720, :736, :739; marketplace.md:131, :145; memory-sync.md:200; workflow.md:199, :203, :206 |
| SR2 the `pkill` incident | done | memory-sync.md:195, *Incidents*, `- [bug-reviewer-findings/findings.md pkill] …`, from `git show 6838133:plan/bug-reviewer-findings/findings.md` §8 (`:371-375`, read before writing) |
| SR3 `EDQUOT` and leading-alternation pointer | done | marketplace.md:120, *Incidents*, pointing at `host.example.md` *Temp files* and `glab:bootstrap` step 6 (both read at `6838133`) |
| SR4 the C2 bullet | done | external-agents.md:179, *Measurements*, with `core.fsmonitor`, from findings-r3 C2 |
| SR5 `probe-r3.md 2` and `follow-up-3` to *Closed* only | done | their two items removed from *Open follow-ups*; added at external-agents.md:701-702 under *Closed follow-ups*, "closed: corrected in *Live runs*". The item for `probe-r3.md 2` in *Live runs*' findings list (:654) stays, outside both follow-up sections |
| SR6 the whole verdict set | done | external-agents.md:84-90, *How it works now*: `SHIP`, `SHIP WITH SCOPE CUT: <what>`, `BLOCK: <n> issues` (`BLOCK: 1 issue` for one), `BLOCK: target unresolved`, `DO NOT PUBLISH: <why>` — checked against `reviewer.md:86`, `:100-102` and the validator's regex at `6838133` |

## Unplanned changes

None. In SR6 I added one clause naming the files the verdict set is one fact
in (`reviewer.md`, the manager, `ship.md`, the validator, E34), taken from
`AGENTS.md` *One fact*.

## Gates

`export TMPDIR=/data/tmp/claude`. `Q1=A STAGE=build bash plan/feature-docs-specs/check.sh`
before the fixes: 77 `FAIL` (seven `record … under-Records=0`, the three tag
lines for `pkill`, `probe-r3.md 2`, `follow-up-3`, four section-11 lines, and
the payload/repo insertion and removal lines of the other slice). After the
fixes, with the other developer's edits in the tree: **0 `FAIL`**, among them

    ok   record bug-reviewer-findings 2aeb46d in memory-sync.md
    … (all seven `ok   record` lines)
    tags 187/187 in place
    ok   headings in order: … (all four specs)
    ok   offline block
    ok   L1a block
    ok   runner block
    ok   runner block parses
    insertions 103/103 present
    ok   Measurements has 'core.fsmonitor'
    ok   How it works now has '`BLOCK: target unresolved`'
    ok   marketplace.md *Incidents* has 'EDQUOT'
    ok   marketplace.md *Incidents* has 'leading alternation'
    ok   no listed leak pattern (absence check)
    info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: ''

No section was left red waiting for the payload slice: the other developer
had finished when I ran it.

Both `AGENTS.md` gate blocks, re-run as written (`CLAUDE_BIN` as before, a
throwaway `CLAUDE_CONFIG_DIR` the block removed): five `rc=0`; shellcheck
`rc=0`; `PASS 35/35` (35 `ok`, no other line); `PASS 49/49` (49 `ok`, no
other line); three `✔ Validation passed`; `Skills (15)` with the fifteen
names, `Agents (5)`, `Hooks (1)  SessionStart`; `Skills (1)  sync-memory`,
`Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
`glab = glab`, `memory-sync = memory-sync`; `:0`, `:0`, `rc=1`; `:1` ×3,
`rc=0`; `1`, `rc=0`; `rc=1`. Green. These do not read the specs: they
guard that the tree around them still holds.

## Coverage, as a list

SR1 — `check.sh` section 3 (seven `ok   record`, each needing the restore
form under *Records* and the commit on `origin/main`) and section 2 (the
restore form is an allowed citation). SR2, SR5 — section 4 (kinds I and C;
no tag both open and closed). SR3, SR4, SR6 — section 11's new lines. Not
checked by any command: that the incident and pointer texts are complete and
the C2 bullet is accurate beyond its key string — the reviewer's.

## Blast radius

Files written: `docs/specs/{external-agents,marketplace,memory-sync,workflow}.md`
(still untracked) and this file. Read only: `git show 6838133:` of
`plan/bug-reviewer-findings/findings.md`, `host.example.md`,
`plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/agents/reviewer.md`,
`plugins/glab/scripts/external-agent.sh`. No real model, backend, `git add`,
commit, push, fetch, install or service command. Temp files: two check logs
and one test-log directory under `/data/tmp/claude`, removed; nothing in
`/tmp`. No secret or host value added (section 12 clean).

## Follow-ups

None new. The earlier list stands; its item 1 (X1 must move every mention of
`[sync-local-edits/follow-ups.md 10]`) matters more now that section 4 fails a
tag that is both under *Open* and *Closed*.

---

# Conformance round 2/4 fix

`plan.md` *Amendments — conformance round 2/4*, item 2 (step S4), in
`docs/specs/external-agents.md` only, 2026-10-18. Nothing else was touched;
nothing staged.

| line | before → after | status |
|---|---|---|
| `:304` (*Profiles*) | `git show 51043c4:plan/feature-opencode-worker/probe-r3/` → `git restore --source=51043c4 -- plan/feature-opencode-worker/probe-r3/` | done |
| `:603` (*Live runs*, `### 2026-10-17 — L1`) | `git show 51043c4:plan/feature-opencode-worker/probe-r3/<model>/` → `git restore --source=51043c4 -- plan/feature-opencode-worker/probe-r3/<model>/` | done |
| `:711` (*Incidents*) | `git show 8cb2a92:plan/feature-opencode-worker/rev2-build/` → `git restore --source=8cb2a92 -- plan/feature-opencode-worker/rev2-build/` | done |

Each *before* text was counted first (`command grep -c -F` → `1` each), then
replaced by a `sed` addressed to its line. After: no spec cites a folder with
`git show` (`command grep -n -E 'git show [0-9a-f]{7,}:[^ `]*/`' docs/specs/*.md`
→ no line, `rc=1`). Single-file `git show <sha>:<path>/<file>` citations are
unchanged, as the *Citations* rule allows.

Gate: `export TMPDIR=/data/tmp/claude`;
`Q1=A STAGE=build bash plan/feature-docs-specs/check.sh` → **0 `FAIL`**,
`tags 187/187 in place`, `insertions 104/104 present`,
`ok   no folder cited with git show`, the seven `ok   record` lines, and
`info handoff: '?? plan/SESSION-HANDOFF.md' | in the tree and the index under plan/: ''`.
The other developer's `AGENTS.md` change (item 1) was already present when
it ran (`ok   gone from AGENTS.md: …`). The `AGENTS.md` gate blocks were not
re-run: this fix changes three citations in one Markdown file that no gate
reads. Unplanned changes: none. Temp file: one check log under
`/data/tmp/claude`, removed.

---

# SR7 — read-only citations (review round 2/3, U11)

`docs/specs/` only, 2026-10-18. Nothing else was touched; nothing staged.

The plan's one command, run as given from the repo root:

    sed -i -E 's#`git restore --source=([0-9a-f]{7}) -- (plan/[^` ]*/)`#`git ls-tree -r --name-only \1 -- \2`#g' docs/specs/*.md

- Before: `git restore` lines 6 (external-agents.md), 2 (marketplace.md),
  1 (memory-sync.md), 3 (workflow.md).
- After: `command grep -rn 'git restore' docs/specs/` → no line, `rc=1`;
  `git ls-tree -r --name-only` lines 6 + 2 + 1 + 3, as the plan expects. In
  external-agents.md they are at :304, :603, :711 and the *Records* lines :720,
  :736, :739. The *Records* lines keep "(one file:
  `git show <sha>:plan/<slug>/<file>`)".

`export TMPDIR=/data/tmp/claude`; `Q1=A STAGE=build bash plan/feature-docs-specs/check.sh`
→ 52 `FAIL`, **every one of them in the other developer's slice**: the
`git restore --source cited` hits are `AGENTS.md`, `README.md`,
`plugins/glab/agents/developer.md` and `plugins/glab/skills/plan-first/SKILL.md`;
the rest are `… lacks:`, `… still has:` and `committer, commit, push or ship
differ from 6838133` lines for `plugins/glab/**`, `README.md` and `AGENTS.md`
(`insertions 55/85 present`), which `fixes-r2.py` has not yet been run on.
Spec-side lines are all `ok`: the seven `ok   record …` lines,
`tags 187/187 in place`, `ok   no folder cited with git show`, the
*Measurements*, *Allowlist* and marketplace *Incidents* lines, the
no-leak line. Re-run it once the payload slice is done to see 0.

Gate blocks not re-run: no gate reads `docs/specs/`. Unplanned changes:
none. Temp file: one check log under `/data/tmp/claude`, removed.
