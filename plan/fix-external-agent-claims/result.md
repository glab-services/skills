# fix-external-agent-claims: result

Built by the **Codex external developer** (`glab:manager` Rule 5, recorded in `questions.md`):
`codex:gpt-6.1-sol`, effort high, agent `ea-3f8f28a793b36fcf`, three turns (one `start`, two `send`s), on
2026-10-18/19. It was started through the `glab:external-agents` skill's own commands, and stopped after
its report was read. The manager wrote this file from the agent's final messages, as the skill says: the
model's words are quoted below, marked as such. The change reports and every gate are the manager's own runs.

## Per turn (the script's report, and the manager's checks)

| turn | steps | exit | change report | the manager's inspection and gates |
|---|---|---|---|---|
| 1 (start) | S1, S2.1–S2.22 | 0 | ` M` README.md, plugin.json, external-agent.sh, SKILL.md; `git: unchanged` | plugin.json 0.7.0→0.7.1; script changes comment-only; all 22 turn-1 searches match; PASS 35/35, PASS 84/84, shellcheck rc=0, 3× Validation passed |
| 2 (send) | S3.1–S3.8 | 0 | ` M` external-agent.sh, SKILL.md, the test; `git: unchanged` | the only code change: `_verify` moved to line 13 of `finish_turn`, before the cap (15) and the timeout (23); turn-2 searches match; PASS 85/85 with E85; E85 NOT OK against HEAD's script (FAIL 1/85) |
| 3 (send) | S4.1–S4.8 | 0 | ` M` external-agent.sh, SKILL.md, the test; `git: unchanged` | code change: `JQ_HOLDS_KEY`, and `opencode_raw` rewritten (jq decodes each line; a line that holds the key becomes `{"type":"redacted"}`); turn-3 searches match; PASS 86/86 with E85 and E86; both NOT OK against HEAD's script (FAIL 2/86) |

Final gates (the manager, after turn 3): five `rc=0`; shellcheck `rc=0`; `PASS 35/35`; `PASS 86/86`, every
line `ok`; three `✔ Validation passed`; glab Skills (15) / Agents (5) / Hooks (1) SessionStart; the
`user_config` gate `:0 :0`; `not yet confirmed` 1/1/1; the DeepSeek sentence 1; the `name:` prefix gate no
line (`rc=1`). `git diff --name-only` shows the five planned files and nothing under `plan/`.

Each turn the agent ended `BLOCKED` only because its sandbox refuses temp-folder writes, so it could not
run the suites or the plugin gates ("not run here"). The skill says that is not red; the manager ran every
gate itself, above.

## The agent's final messages (codex:gpt-6.1-sol's words, unverified except where the table above checks them)

### turn 1

```text
# Result — fix-external-agent-claims

## Stages

All 23 scoped steps are done. Locations below use:

- V: `plugins/glab/.claude-plugin/plugin.json`
- S: `plugins/glab/skills/external-agents/SKILL.md`
- E: `plugins/glab/scripts/external-agent.sh`
- R: `README.md`

| Step | Location |
|---|---|
| S1 | V:3 |
| S2.1 | S:42 |
| S2.2 | R:39 |
| S2.3 | S:95 |
| S2.4 | R:102 |
| S2.5 | S:198 |
| S2.6 | S:385 |
| S2.7 | E:142 |
| S2.8 | E:453 |
| S2.9 | S:171 |
| S2.10 | E:47 |
| S2.11 | S:176 |
| S2.12 | E:22 |
| S2.13 | S:234 |
| S2.14 | S:249 |
| S2.15 | S:263 |
| S2.16 | S:323 |
| S2.17 | R:66 |
| S2.18 | E:71 |
| S2.19 | S:351 |
| S2.20 | E:101 |
| S2.21 | E:182 |
| S2.22 | E:221 |

## Blocked

Implementation: none. Test execution and CLI plugin validation require the manager’s host environment.

## Unplanned changes

None. No mechanical consequences.

## Tests

Zero added or changed. Coverage is a list under AGENTS.md:

- S1: version search returned `0.7.1`.
- S2.1–S2.22: documentation and comments; no test cases required by the plan. All turn-1 search counts matched.
- No executable branches changed.

## Claims

| Claim | Proven / inferred | How |
|---|---|---|
| Changes exactly reproduce the 23 prescribed replacements | Proven | Python replay of Old/New blocks against `git show HEAD:<path>` printed `Exact conformance: 23/23 edits; 4/4 files byte-identical to planned replacements on HEAD` |
| Script changes affect comments only | Proven | Byte comparison printed `external-agent.sh: non-comment bytes unchanged` |
| Tracked changes stay within this turn’s four files | Proven | Path comparison printed `Changed tracked paths: exactly the 4 authorized files; no plan/ paths` |
| Documentation accurately describes runtime behavior | Inferred | Supplied plan and findings; runtime suites could not execute here |

## Gates

Syntax and execute bits:

```bash
for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
```

```text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
```

Lint:

```bash
shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
```

```text
rc=0
```

Tests — **not run here:** both commands stopped before executing cases. Host paths masked:

```bash
bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/memory-sync-test.RySEKF"
```

```bash
bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/external-agent-test.78FPW3"
```

CLI plugin gates — **not run here:** the prescribed config-directory creation failed before any `claude` invocation:

```bash
cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX")
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/claude-config.hMJ2Am"
```

Remaining AGENTS.md plugin searches printed:

```text
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

`git -c core.fsmonitor=false diff --no-ext-diff --check` printed nothing.

## Blast radius

changed: Version metadata, prose and shell comments only.  
callers: No function behavior or signatures changed; caller audit not applicable.  
data: No stored state changed.  
rollback: Manager can reverse the exact replacements; no rollback performed.

## Follow-ups

None added. F1–F4 remain in the approved plan.

## Not done

S3, S4 and the record remain outside this dispatch. No `result.md` written, per dispatch.

UNVERIFIED: runtime suites and CLI plugin validation on this tree — sandbox temp-directory writes were refused.

steps:    23 done, 0 blocked  
files:    plugins/glab/.claude-plugin/plugin.json, plugins/glab/skills/external-agents/SKILL.md, README.md, plugins/glab/scripts/external-agent.sh  
tests:    0 added/changed; coverage by step list above  
gates:    build not run here (syntax ok) · tests not run here · lint ok  
detail:   plan/fix-external-agent-claims/result.md (manager writes)

BLOCKED: Final gate completion requires the manager to run both test suites and CLI plugin gates with writable host temp storage.
```

### turn 2

```text
# Result — fix-external-agent-claims

## Stages

All eight scoped steps are done.

| Step | File:line |
|---|---|
| S3.1 | `plugins/glab/scripts/external-agent.sh:1473` |
| S3.2 | `plugins/glab/scripts/external-agent.sh:1494` |
| S3.3 | `plugins/glab/scripts/external-agent.sh:133` |
| S3.4 | `plugins/glab/skills/external-agents/SKILL.md:422` |
| S3.5 | `tests/external-agent.test.sh:253` |
| S3.6 | `tests/external-agent.test.sh:351` |
| S3.7 | `tests/external-agent.test.sh:1433` |
| S3.8 | `tests/external-agent.test.sh:733` |

Applied each exact Old/New replacement in order.

## Blocked

Implementation: none. Runtime and CLI plugin gates need writable host temp storage.

## Unplanned changes

None. No mechanical consequences.

## Tests

One case added: E85, covering a wrong sandbox header followed by a stdout flood or timeout.

Coverage list, per AGENTS.md:

- S3.1–S3.2: E85; regression cases E54, E73, E60 and E64.
- S3.3–S3.4: prose; turn-2 searches.
- S3.5–S3.8: stub scenarios and E85; manager’s mutation run remains outstanding.

UNVERIFIED: case outcomes and runtime branch coverage — both suites stopped before executing cases.

## Claims

| Claim | Proven / inferred | How |
|---|---|---|
| This turn exactly applies its eight replacements | Proven | Python preflight/application comparison printed `Exact turn conformance: 8/8 edits; 3/3 files byte-identical to prescribed replacements` |
| Cumulative changes contain S1–S3 only | Proven | Python replay against HEAD printed `Cumulative conformance: exactly 31/31 planned S1-S3 edits across 5/5 authorized tracked files; no S4 edits` |
| Verification precedes cap and timeout checks | Proven | Plan’s `awk`/`grep` search printed verification at relative line 13, cap check at 15, timeout exit at 23 |
| Wrong-header floods and timeouts return 12 | Inferred | Control flow now calls `codex_verify` first; E85 execution remains outstanding |

## Gates

Syntax and execute-bit command:

```bash
for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
```

```text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
```

Lint command:

```bash
shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
```

```text
rc=0
```

Tests — **not run here:** commands stopped at temp-directory creation. Host paths masked:

```bash
bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/memory-sync-test.oCiDrJ"
```

```bash
bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/external-agent-test.AxUpMW"
```

CLI plugin gates — **not run here:** config-directory creation stopped before any `claude` invocation:

```bash
cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX")
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/claude-config.D6iAFG"
```

Remaining AGENTS.md plugin searches printed:

```text
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

Turn-2 search results matched the plan: claim references `1/1`, verification call `1`, ordering `13 < 15 < 23`, wording `1`, flood references `3`, cases `85`, historical comment `1`.

`git -c core.fsmonitor=false diff --no-ext-diff --check` printed nothing.

## Blast radius

changed: `finish_turn` checks the host sandbox before cap and timeout outcomes; related prose and stub scenarios updated.  
callers: `cmd_start` and `cmd_send` both call it last and rely on it printing the outcome and exiting. `codex_verify` retains one caller inside `finish_turn`.  
data: Turn exit precedence changes; no stored format changes.  
rollback: Manager can reverse these eight replacements while retaining turn 1.

## Follow-ups

None added.

## Not done

S4 and the record remain outside this turn. No `result.md` written, per dispatch.

UNVERIFIED: E85, regression cases, mutation run and CLI plugin validation — sandbox temp-directory writes were refused.

steps:    8 done, 0 blocked  
files:    plugins/glab/scripts/external-agent.sh, plugins/glab/skills/external-agents/SKILL.md, tests/external-agent.test.sh  
tests:    1 added; coverage by case list above, execution not run here  
gates:    build not run here (syntax ok) · tests not run here · lint ok  
detail:   plan/fix-external-agent-claims/result.md (manager writes)

BLOCKED: Final gate completion requires the manager’s test, mutation and CLI plugin runs with writable host temp storage.
```

### turn 3

```text
# Result — fix-external-agent-claims

## Stages

All eight scoped steps are done, applied as exact Old/New replacements in order.

| Step | File:line |
|---|---|
| S4.1 | `plugins/glab/scripts/external-agent.sh:693` |
| S4.2 | `plugins/glab/scripts/external-agent.sh:352` |
| S4.3 | `plugins/glab/scripts/external-agent.sh:106` |
| S4.4 | `plugins/glab/scripts/external-agent.sh:231` |
| S4.5 | `plugins/glab/skills/external-agents/SKILL.md:238` |
| S4.6 | `plugins/glab/skills/external-agents/SKILL.md:349` |
| S4.7 | `tests/external-agent.test.sh:1442` |
| S4.8 | `tests/external-agent.test.sh:733` |

## Blocked

Implementation: none. Runtime and CLI plugin gates require writable host temp storage.

## Unplanned changes

None. No mechanical consequences.

## Tests

One case added: E86, covering a JSON-escaped key and a key containing quote and backslash characters.

Coverage list, per AGENTS.md:

- S4.1: E86; E14 covers literal-key redaction, E42 covers unchanged events and size limits.
- S4.2–S4.6: comments and prose; turn-3 searches.
- S4.7–S4.8: E86 and the historical case-range comment.
- No suite case covers `jq` failure, an object key containing the key, or non-JSON input. The approved plan accepts planner standalone evidence for these; none was executed here.

UNVERIFIED: runtime case outcomes — both suites stopped before executing cases.

## Claims

| Claim | Proven / inferred | How |
|---|---|---|
| This turn exactly applies its eight replacements | Proven | Python comparison printed `Exact turn conformance: 8/8 edits; 3/3 files byte-identical to prescribed replacements` |
| Cumulative changes exactly match S1–S4 | Proven | Python replay against HEAD printed `Cumulative conformance: exactly 39/39 planned S1-S4 edits across 5/5 authorized tracked files` |
| Turn-3 search counts match the plan | Proven | Prescribed searches printed `0`, `2`, `1`, `2`, references `1/1`, `86`, `1` |
| Decoded-key events become redacted objects | Inferred | `opencode_raw` now uses the prescribed jq verdicts and awk replacement; E86 execution remains outstanding |

## Gates

Syntax and execute bits:

```bash
for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
```

```text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
```

Lint:

```bash
shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
```

```text
rc=0
```

Tests — **not run here:** both commands stopped at temp-directory creation. Host paths masked:

```bash
bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/memory-sync-test.7OCnNu"
```

```bash
bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/external-agent-test.ENnxtd"
```

CLI plugin gates — **not run here:** config-directory creation stopped before any `claude` invocation:

```bash
cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX")
```

```text
mktemp: Read-only file system (os error 30) at path "<temp>/claude-config.o5FIKX"
```

Remaining AGENTS.md plugin searches printed:

```text
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

`git -c core.fsmonitor=false diff --no-ext-diff --check` printed nothing.

## Blast radius

changed: `opencode_raw` replaces events containing the decoded key; related comments and prose describe the retained limits.  
callers: `run_turn` is the sole adapter caller. It appends stdout after backend completion, with the key loaded; that interface remains intact.  
data: Future OpenCode raw-transcript events may become `{"type":"redacted"}`. Existing lines remain untouched.  
rollback: Manager can reverse these eight replacements while retaining earlier turns; already-redacted events cannot be reconstructed.

## Follow-ups

None added. Approved F1–F4 remain unchanged.

## Not done

The record remains outside this dispatch. No `result.md` written.

UNVERIFIED: E86, regression cases, mutation run and CLI plugin validation — sandbox temp-directory writes were refused.

steps:    8 done, 0 blocked  
files:    plugins/glab/scripts/external-agent.sh, plugins/glab/skills/external-agents/SKILL.md, tests/external-agent.test.sh  
tests:    1 added; coverage by case list above, execution not run here  
gates:    build not run here (syntax ok) · tests not run here · lint ok  
detail:   plan/fix-external-agent-claims/result.md (manager writes)

BLOCKED: Final gate completion requires the manager’s test, mutation and CLI plugin runs with writable host temp storage.
```

## Turn 4 (review round 1 fixes): a new Codex developer agent `ea-64e4723e9807499a`, S5.1–S5.9

- The report: exit 0; ` M` README.md, external-agent.sh, the test; `git: unchanged`.
- The manager: the only code change is the fail-closed catch (`explode | any(. == 92)`); all 11 turn-4 searches match; PASS 86/86, PASS 35/35, shellcheck rc=0, 3x Validation passed. Mutants: `[.. | strings]` gives NOT OK E86, FAIL 1/86; the catch back to `catch "-"` gives NOT OK E86, FAIL 1/86; `!= "k"` survives, as the coverage list records.

### turn 4, codex:gpt-6.1-sol's words

```text
# Result — fix-external-agent-claims

## Stages

All nine steps done as exact Old/New replacements:

| Step | File:line |
|---|---|
| S5.1 | `plugins/glab/scripts/external-agent.sh:720` |
| S5.2 | `plugins/glab/scripts/external-agent.sh:696` |
| S5.3 | `plugins/glab/scripts/external-agent.sh:703` |
| S5.4 | `README.md:76` |
| S5.5 | `tests/external-agent.test.sh:795` |
| S5.6 | `plugins/glab/scripts/external-agent.sh:1501` |
| S5.7 | `tests/external-agent.test.sh:159` |
| S5.8 | `tests/external-agent.test.sh:1463` |
| S5.9 | `tests/external-agent.test.sh:1479` |

## Blocked

Full verification needs the manager’s writable temp directory and sandbox capabilities. The prerequisite probe:

```text
$ mktemp -d /data/tmp/claude/eac-gate.XXXXXX
mktemp: Read-only file system (os error 30) at path "/data/tmp/claude/eac-gate.t1RDPC"
```

## Unplanned changes

None.

## Tests

Two existing cases changed: E42’s title and E86’s scenarios/assertions. No new numbered case.

Coverage follows AGENTS.md’s list requirement:

- S5.1: E86 exercises split events, two events on one line and escaped object keys; E14/E42 provide existing regression coverage.
- S5.2–S5.6: comments, prose and a test title; checked by the plan’s searches.
- S5.7–S5.9: E86 scenarios and assertions.
- The jq-failure branch remains uncovered, as the plan explicitly accepts.

UNVERIFIED: runtime results and mutation results — the plan reserves these runs for the manager outside this sandbox.

## Gates

Build-equivalent syntax/execute-bit command:

```bash
for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
```

Output:

```text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
```

Lint command:

```bash
shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
```

Output:

```text
rc=0
```

Tests and plugin gates: **not run here:** temp-directory creation failed as quoted above.

## Follow-ups

None added. Existing plan follow-ups remain outside this slice.

## Not done

S1–S4.8 and Stage 8 were outside scope. No `result.md` was written, per dispatch.

## Claims

| Claim | Proven / inferred | How |
|---|---|---|
| All nine replacements match the plan exactly | Proven | Mechanical replacement and reverse comparison printed `PASS 9/9 exact edits; only the three turn-4 files written` |
| All turn-4 search counts match the plan | Proven | Executed the eleven specified searches: `PASS 11/11 turn-4 searches` |
| The cumulative tracked diff has no whitespace errors | Proven | `git -c core.fsmonitor=false diff --check` printed `rc=0` |
| The changed redaction handles the added scenarios | Inferred | From the planned jq catch and E86 assertions; runtime confirmation requires the manager’s suite |

## Blast radius

changed: `opencode_raw`’s handling of lines that fail JSON decoding.

callers: one dynamic call in `run_turn`, appending stdout to the raw transcript; the output contract remains unchanged.

data: future OpenCode transcript lines; existing transcript contents are untouched by this function.

rollback: reverse S5.1–S5.9; no rollback performed.

```text
steps:    9 done, 0 blocked
files:    plugins/glab/scripts/external-agent.sh, README.md, tests/external-agent.test.sh
tests:    0 added, 2 changed; coverage listed above
gates:    build ok · tests not run here · lint ok
detail:   plan/fix-external-agent-claims/result.md
```

BLOCKED: full verification requires the manager to run the test, plugin and mutation gates outside this sandbox.
```

## Turn 5 (review round 2 fixes): a new Codex developer agent `ea-6304e0a0fb1ce58c`, S6.1–S6.7

- The report: exit 0; ` M` external-agent.sh, SKILL.md, the test; `git: unchanged`.
- The manager: no script code changed in this turn (comments and the test only; 9 non-comment lines against HEAD, the same as after turn 4); all 12 turn-5 searches match; PASS 86/86, PASS 35/35, shellcheck rc=0, the plugin block green. All three mutants now fail E86: `[.. | strings]`, `catch "-"` and `!= "k"`, each FAIL 1/86.

### turn 5, codex:gpt-6.1-sol's words

```text
# Result — fix-external-agent-claims

## Stages

- S6.1 done — `plugins/glab/scripts/external-agent.sh:103`
- S6.2 done — `plugins/glab/scripts/external-agent.sh:233`
- S6.3 done — `plugins/glab/skills/external-agents/SKILL.md:358`
- S6.4 done — `plugins/glab/scripts/external-agent.sh:710`
- S6.5 done — `tests/external-agent.test.sh:1474`
- S6.6 done — `tests/external-agent.test.sh:1481`
- S6.7 done — `tests/external-agent.test.sh:1497`

Applied all seven exact Old/New replacements in order.

## Blocked

Implementation complete. Host test, plugin and mutation gates remain for the manager.

## Unplanned changes

None. No `result.md` written.

## Tests

One case changed: E86 gains the split-event guard and selective `jq` failure wrapper. Case count remains 86.

Coverage follows AGENTS.md’s list exception:

- S6.1–S6.4: comments and prose; turn-5 searches.
- S6.5–S6.7: E86; execution and three mutation checks not run here.

## Gates

Build/syntax command:

```bash
for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
```

Output:

```text
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
plugins/glab/scripts/external-agent.sh rc=0
tests/memory-sync.test.sh rc=0
tests/external-agent.test.sh rc=0
```

Lint command:

```bash
shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/external-agent.sh tests/memory-sync.test.sh tests/external-agent.test.sh; echo "rc=$?"
```

Output:

```text
rc=0
```

Test commands, with `TMPDIR` set as host.example.md prescribes:

```bash
bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null
```

Not run here:

```text
mktemp: Read-only file system (os error 30) at path "/data/tmp/claude/memory-sync-test.9feVXl"
mktemp: Read-only file system (os error 30) at path "/data/tmp/claude/external-agent-test.Z9Jf8l"
```

Plugin validation/details not run here: isolated configuration preparation, `mktemp -d "${TMPDIR:?}/claude-config.XXXXXX"`, returned:

```text
mktemp: Read-only file system (os error 30) at path "/data/tmp/claude/claude-config.vAK2xw"
```

Remaining AGENTS.md static plugin commands printed:

```text
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

Turn-5 searches printed, in plan order:

```text
plugins/glab/skills/external-agents/SKILL.md:0
plugins/glab/scripts/external-agent.sh:0
0
1
1
1
1
1
1
1
1
1
86
```

## Follow-ups

None added. Existing plan follow-ups remain untouched.

## Not done

S1–S5.9 and the record were outside this turn’s scope.

UNVERIFIED: E86 execution, mutation rejection and full plugin gates on this tree — sandbox prevents the required temporary directories.

## Claims

| claim | proven / inferred | how |
|---|---|---|
| Changes exactly match S6.1–S6.7 | proven | Python checked exact New blocks and reversed them in memory: `S6.1-S6.7: exact New blocks present; reversing only those edits reproduces all three pre-turn SHA-256 values` |
| Documented bounds follow the implementation | inferred | Code and plan reasoning; no standalone measurement run here |

## Blast radius

changed: script comments, skill prose and E86 assertions/setup only; production functions and formats unchanged.  
callers: no function behavior or signature changed.  
data: no production state affected.  
rollback: reverse this turn’s seven exact replacements, preserving earlier turns.

steps:    7 done, 0 blocked  
files:    plugins/glab/scripts/external-agent.sh, plugins/glab/skills/external-agents/SKILL.md, tests/external-agent.test.sh  
tests:    1 changed; coverage listed above  
gates:    build ok · tests not run here · lint ok  
detail:   this reply; manager writes plan/fix-external-agent-claims/result.md

BLOCKED: Manager must run the host test, plugin and mutation gates.
```
