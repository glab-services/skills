# Result — subagent-effort

Contract read: `AGENTS.md`, `plan/subagent-effort/plan.md` (its *Findings*
section stands in for `findings.md`, as the plan says), `questions.md`
(Q1 = A). S1's source wording read from the user's own manager skill, Rule 0d
(its lines 63-82) and the handoff sentence (154); nothing under the user's
config directory was edited, copied into or removed.

## Stages

- B1 done — gates green on the untouched tree: five `rc=0`, shellcheck
  `rc=0`, `PASS 35/35`, `PASS 86/86`, three `✔ Validation passed`, `glab`
  `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`, every grep line as
  *Gates* defines green (same output as *Gates* below, which is the A1 run).
- B2 done by the manager (Q1 answered A in `questions.md`).
- B3 done — `git status --short -- docs/specs plan/SESSION-HANDOFF.md`
  printed ` M` for the three specs and `??` for the handoff file before and
  after; none of them touched.
- S1 done — `plugins/glab/skills/manager/SKILL.md:65-72` (Rule 0d heading,
  opening paragraph, four one-line bullets incl. the D3 bullet at :71).
- S2 done — same file :189 (*The pipeline* handoff sentence plus the
  Codex/OpenCode sentence); :137 (Rule 5 examples: `· effort <level>` on the
  sonnet example, `· effort <sent>` on the Codex developer example; the
  OpenCode example unchanged).
- S3 done — same file :136 (Codex reviewer and developer model lines without
  the effort clause; "The effort is not in the model line: …"); :165 (Rule 6
  *Codex's effort*; rest of the bullet unchanged).
- S4 done — `plugins/glab/skills/external-agents/SKILL.md:107-111`; the
  mapping lines (now :112-115) unchanged.
- S5 done — manager `SKILL.md:359` (Stage 2 bullet), :414 (Stage 5).
- S6 done — `plugins/glab/commands/develop.md:43`,
  `plugins/glab/commands/review.md:8`, `plugins/glab/commands/ship.md:16`,
  `:36`.
- S7 done — `plugins/glab/skills/bootstrap/SKILL.md:59-61`,
  `plugins/glab/scripts/manager-bootstrap.sh:20`, `README.md:14-16`.
- S8 done — `plugins/glab/.claude-plugin/plugin.json:3` → `0.7.2`.
- S9 done — `AGENTS.md:227-240` (Codex entry rewritten at :227-229, new
  session-effort entry :230-240).
- A1-A6 done — outputs below.

## Blocked

None.

## Unplanned changes

None. Line wraps: S4's bullet, S7's bootstrap paragraph and README sentence,
and S9's two entries were wrapped to their files' width, as S4/S9 direct; the
README sentence's tail ("The two plugins do not depend on each other; install
either alone.") was re-wrapped, not reworded (S7).

## Tests

No shell behaviour changed; no test added or changed. Coverage list
(AGENTS.md *Tests*):

- S7 hook line (`manager-bootstrap.sh:20`): `bash -n`/`test -x` and
  `shellcheck` gates; S7/A2 output search (`hook-text: 1`, hook text
  2285 → 2394 bytes, cap 10,000). No test case asserts the hook text —
  accepted, as before this change.
- S1-S6, S8, S9 (Markdown/JSON): each step's *Verify* search below, and
  `claude plugin validate --strict` (three passes). No test case covers
  Markdown — accepted per AGENTS.md (*The Markdown files have no gate*).
- Untouched: `tests/`, `external-agent.sh` (A5: `git diff --name-only`
  printed nothing); both suites still `PASS 35/35` and `PASS 86/86`.

## Gates

`export TMPDIR` to the host temp directory and `CLAUDE_BIN` to the path the
dispatch named; the *Gates* block run as one script, `CLAUDE_CONFIG_DIR` a
fresh `mktemp -d` under `$TMPDIR`, removed by the block. Output on the
finished tree (A1), with the 121 `ok` lines of the two suites elided — the
run printed no line other than these and `ok …` lines (counted: 121 `ok`,
0 other lines unaccounted for):

```
--- shell syntax/exec
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
--- shellcheck
rc=0
--- memory-sync test
PASS 35/35
--- external-agent test
PASS 86/86
--- plugin gates
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
```

## Verify and *after* checks (A2-A6, every step's Verify)

Run on the finished tree. Before S1 the same script printed every plan
"today" value (e.g. S1 all `0`, A2 all eight files, A3 all `MISSING`,
S3 `old-effort-clause: 1`, S8 `0.7.1`) — the positive control.

```
=== S1
model-is-rule5: 1
`glab:developer`: 1
`glab:reviewer`: 1
`glab:analyzer`: 1
`glab:integrator`: 1
`glab:committer`: 1
bare-roles: 0
may-name: 1
say-effort: 1
heading: 1
record-line: 1
30:## Rule 0c — which skills every agent you dispatch carries
65:## Rule 0d — every agent you dispatch runs at an effort you pass
74:## Rule 1 — you are not the implementer
=== S2
verdict-effort: 1
codex-sent-sentence: 1
built-effort -o: 2
ship-example: 1
=== S3
old-effort-clause: 0
effort-codex-line: 0
rule6-new: 1
also-records: 0
not-in-model-line: 1
ext-dev-sentence: 1
in-model-line-M: 0
=== S4
rule0d-X: 2
effort-codex-X: 0
printenv-X: 1
in-model-line-X: 0
agent-or-role-X: 1
=== S5
effort-always: 1
stage5: 1
=== S6
grep -L (expect nothing):
ship-count: 2
=== S7
plugins/glab/skills/bootstrap/SKILL.md:1
plugins/glab/scripts/manager-bootstrap.sh:1
hook-text: 1
hook-size: 2394
readme: 1
=== S8
0.7.2
=== S9
codex-rule-new: 1
codex-rule-old: 0
=== A2 (expect nothing)
=== A3
ok plugins/glab/skills/manager/SKILL.md
ok plugins/glab/skills/external-agents/SKILL.md
ok plugins/glab/commands/develop.md
ok plugins/glab/commands/review.md
ok plugins/glab/commands/ship.md
ok plugins/glab/skills/bootstrap/SKILL.md
ok plugins/glab/scripts/manager-bootstrap.sh
ok README.md
=== A5
rc=1
 M docs/specs/external-agents.md
 M docs/specs/marketplace.md
 M docs/specs/workflow.md
?? plan/SESSION-HANDOFF.md
diff tests/script:
=== A6
 AGENTS.md                                    |  15 +-
 README.md                                    |   5 +-
 docs/specs/external-agents.md                | 213 +++++++++++++++++++++++----
 docs/specs/marketplace.md                    |  14 +-
 docs/specs/workflow.md                       |   3 +-
 plugins/glab/.claude-plugin/plugin.json      |   2 +-
 plugins/glab/commands/develop.md             |   1 +
 plugins/glab/commands/review.md              |   2 +-
 plugins/glab/commands/ship.md                |   4 +-
 plugins/glab/scripts/manager-bootstrap.sh    |   2 +-
 plugins/glab/skills/bootstrap/SKILL.md       |   4 +
 plugins/glab/skills/external-agents/SKILL.md |  10 +-
 plugins/glab/skills/manager/SKILL.md         |  20 ++-
 13 files changed, 242 insertions(+), 53 deletions(-)
```

A6: the stat lists exactly the ten planned paths plus the three pending
`docs/specs/` files, whose line counts (213, 14, 3) are what they were
before this change.

## Blast radius

    changed: glab:manager Rule 0d (new), Rule 5 Codex record lines and
             handoff examples, Rule 6 Codex's effort, Stage 2, Stage 5,
             *The pipeline* handoff format; glab:external-agents effort
             bullet; develop/review/ship dispatch text; glab:bootstrap and
             the SessionStart hook text; README sentence; AGENTS.md One fact
             entries; glab version 0.7.2
    callers: Rule 5 record lines are read by the manager after a compaction,
             by Rule 6 and the external-agents skill (all updated); the
             script does not read them (its `model:` header field carries
             no effort — E01/E50/E55 unchanged, suite PASS 86/86). Handoff
             lines are read by the user only. Hook text is emitted as
             additionalContext; no test asserts it.
    data:    none — an older plan's `- model: … codex, effort <level> (…)`
             line is still readable prose; the new rule records the effort
             in a `- effort:` line instead. inferred, not tested.
    rollback: git revert of the commit; nothing else holds state.

UNVERIFIED: that a plugin agent honours the Agent tool's `effort`
parameter — no live dispatch run here (plan D7: goes to the Stage 8 record).

## Follow-ups

None added. The plan's F1 (starting a stage session at the recorded effort
without subagent dispatch) stays in plan.md; `follow-ups.md` not written.

## Not done

- No commit, no stage, no push (manager's Stage 6).
- `docs/specs/` and `plan/SESSION-HANDOFF.md` left as they were (B3, A5).
- No real model or external agent run; no process left (`ps` search for
  `slirp4netns|bwrap|external-agent|memory-sync|glab-external-agents`
  printed nothing, `rc=1`).

## Review round 1 fixes

Re-dispatch by the manager for review round 1/3. All three fixes are in
`plugins/glab/skills/manager/SKILL.md` Rule 0d, each one a new sentence on an
existing line; no other file changed. Finding 4 (`commit.md`, `analyze.md`,
`integrate.md`) was accepted as-is under plan D4 and was not touched.

- Fix 1 (medium), `:67`: the opening paragraph now ends with Rule 5's
  `model` fallback, for `effort`: "If the Agent tool rejects the `effort`
  parameter or does not offer it, tell the user, dispatch without it, and
  write `effort default` in the handoff line."
- Fix 2 (low), `:71`: the `ultra` ask is now "for an Agent tool dispatch"
  only. The Codex sentence now reads "A Codex agent runs at this same level
  through Rule 6's mapping, and Codex takes `ultra`; an OpenCode agent takes
  none." Source: `external-agent.sh:787`, where `codex_effort_ok` accepts
  `low|medium|high|xhigh|max|ultra`.
- Fix 3 (low), `:69`: after "…or in this conversation when there is no
  plan." it adds "A session-wide level gets that line in the plan of every
  task it covers.", which is the sentence Rule 5 uses at `:136`.

Unplanned changes: none beyond the three fixes the review asked for. The
heading count is unchanged: Rule 0d is still lines 65-72, with `## Rule 1`
at 74.

Coverage: these are Markdown changes, so no test case covers them (accepted,
AGENTS.md *Tests*). They are covered by the searches below.

S1 and S3 Verify checks, the round-1 searches, and the diff scope (the
`git diff --stat` is the same ten paths plus the three pending specs):

```
=== S1
model-is-rule5: 1
`glab:developer`: 1
`glab:reviewer`: 1
`glab:analyzer`: 1
`glab:integrator`: 1
`glab:committer`: 1
bare-roles: 0
may-name: 1
say-effort: 1
heading: 1
record-line: 1
30:## Rule 0c — which skills every agent you dispatch carries
65:## Rule 0d — every agent you dispatch runs at an effort you pass
74:## Rule 1 — you are not the implementer
=== S3
old-effort-clause: 0
effort-codex-line: 0
rule6-new: 1
also-records: 0
not-in-model-line: 1
ext-dev-sentence: 1
in-model-line-M: 0
=== round-1 fixes
fallback: 1
session-wide: 1
ultra-scoped: 1
codex-ultra: 1
rule0d-lines: 10
=== diff scope
 AGENTS.md                                    |  15 +-
 README.md                                    |   5 +-
 docs/specs/external-agents.md                | 213 +++++++++++++++++++++++----
 docs/specs/marketplace.md                    |  14 +-
 docs/specs/workflow.md                       |   3 +-
 plugins/glab/.claude-plugin/plugin.json      |   2 +-
 plugins/glab/commands/develop.md             |   1 +
 plugins/glab/commands/review.md              |   2 +-
 plugins/glab/commands/ship.md                |   4 +-
 plugins/glab/scripts/manager-bootstrap.sh    |   2 +-
 plugins/glab/skills/bootstrap/SKILL.md       |   4 +
 plugins/glab/skills/external-agents/SKILL.md |  10 +-
 plugins/glab/skills/manager/SKILL.md         |  20 ++-
 13 files changed, 242 insertions(+), 53 deletions(-)
```

The gates were rerun as one script, the same as in *Gates* (`TMPDIR` set,
`CLAUDE_BIN` set, `CLAUDE_CONFIG_DIR` pointed at a new empty `mktemp -d`
directory and removed afterwards). The run printed 121 `ok` lines, which are
left out below, and nothing else besides these:

```
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
rc=0
PASS 35/35
PASS 86/86
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
```

No process was left running: the `ps` search for
`slirp4netns|bwrap|external-agent|memory-sync` printed nothing (`rc=1`).
Not committed and not staged.
