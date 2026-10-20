# Result — flow-cheaper-rounds

Scope: every step S1–S17 (one agent). Host file `~/.claude/host.md` does not exist on this machine, so `TMPDIR=/data/tmp/claude` (the user's global instruction) and `claude` on `PATH` (Claude Code 2.1.304) were used; `CLAUDE_BIN` was not needed. Working agreement read: `AGENTS.md`.

## Stages

- S1 `plugins/glab/skills/manager/SKILL.md` done — S1.1 `:91`; S1.2/S1.16 `:99-108`; S1.3 `:142`; S1.4 `:147`; S1.5 `:163`; S1.6 `:175-176`; S1.7 `:185`; S1.8 `:199,201,203` and *Round caps* `:207`; S1.9 `:252`; S1.10 `:262`; S1.11 `:272`; S1.12 `:336-342`; S1.13 `:355`; S1.14 `:391-400` (snapshot lines `:395-396`); S1.15 `:415` and `:419-421`; S1.17 `:442-443`; S1.18 `:459-460`.
- S2 `plugins/glab/skills/plan-first/SKILL.md` done — S2.1 `:19`; S2.2 `:31`; S2.3 `:33-45`; S2.4 Step 4 bullet; S2.5 `:95`.
- S3 `plugins/glab/agents/reviewer.md` done — S3.1 `:83`, `:87`; S3.2 `:95`, `:97`.
- S4 `plugins/glab/agents/analyzer.md` done — S4.1 `:16`; S4.2 `:76` and the paragraph after it; S4.3 `:54`; S4.4 `:68`.
- S5 `plugins/glab/agents/developer.md` done — S5.1 `:18`; S5.2 `:68`; S5.3 `:96`; S5.4 `:102`; S5.5 `:107`.
- S6 `plugins/glab/commands/ship.md` done — S6.1 `:30`; S6.2 `:32`.
- S7 `plugins/glab/commands/develop.md` done — S7.1 `:42`; S7.2 `:44`.
- S8 `plugins/glab/commands/analyze.md` done — S8.1 `:8`.
- S9 `plugins/glab/skills/bootstrap/SKILL.md` done — S9.1 `:100-103`.
- S10 `AGENTS.md` *One fact* done — S10.1–S10.4 (the round caps entry in place of the review round cap; four S10.2 entries, S10.3, S10.4 after the reviewer's-verdict-lines entry).
- S11 `plugins/glab/.claude-plugin/plugin.json` done — `0.8.0` -> `0.9.0`.
- S12 `plugins/glab/hooks/hooks.json` done — four events in the plan's key order, all timeouts 5.
- S13 `plugins/glab/scripts/context-size.sh` (new, mode 755) done — S13.1 header; S13.2 modes and `fail`; S13.3 input and path; S13.4 the one `jq` program; S13.5 output per mode; S13.6 `exit 0`.
- S14 `tests/context-size.test.sh` (new, mode 755) done — T1, T3–T19, T2 last; `PASS 19/19`.
- S15 `AGENTS.md` done — S15.1 *Layout*; S15.2 *Gates* wording ("The tests create their work directories", "run all four"); S15.3 the block and the green line (five `rc=0` lines); S15.4 `Hooks (4)` line; S15.5 *Tests* sentence; S15.6 hook-contracts rule.
- S16 `README.md` done — S16.1 `glab` row; S16.2 *Requirements* sentence; S16.3 context-hook paragraph.
- S17 `.claude-plugin/marketplace.json` done — `glab` entry description only.

## Blocked

Nothing. Integration I1 (a model run, plan D41) is the user's, in their own terminal; not attempted.

## Unplanned changes

None forced by a step. Implementation choices inside S13 (not behaviour changes): the jq program reads token fields through `numbers` (a non-numeric usage field gives 0 instead of aborting the program), emits `cur` and `base` through `floor`, and the shell accepts only 1 to 15 digits before any bash arithmetic (a float or exponent would otherwise make bash exit non-zero, which D34 forbids). Two wording choices to satisfy the plan's own post-conditions: S9.1 is wrapped so "at most two rounds" stays on one line (V2's line search), and the script's step comment avoids the word "resumed" (V6 counts that word in every file under `plugins/glab`).

The dispatch message said the shell block covers four scripts; the plan (S15.3, D40) and the edited `AGENTS.md` cover five (`memory-sync.sh`, `manager-bootstrap.sh`, `context-size.sh`, `memory-sync.test.sh`, `context-size.test.sh`). The plan was followed.

## Tests

Added: `tests/context-size.test.sh`, 19 cases (T1, T3–T19, T2 last), `PASS 19/19`, 27 script runs. Existing `tests/memory-sync.test.sh` unchanged, `PASS 35/35`.

Mutants (V17), each against a throwaway copy of the script under `$TMPDIR`, removed after; all fail the test as required:

    (a) stop JSON with "decision":"block" added      -> FAIL T18, FAIL T19   (FAIL 2/19)
    (b) "+ 999" removed from the rounding            -> FAIL T1, T3, T13     (FAIL 3/19)  [T13: "glab: context 0k"]
    (c) the isSidechain filter removed               -> FAIL T15             (FAIL 1/19)  [900k instead of 200k]

Two more mutants beyond V17, to show T18's isMeta and tool_result cases discriminate: `isMeta` condition removed -> FAIL T18, T19; the tool_result condition removed -> FAIL T18, T19. Against a missing script path the test prints the usage line and exits 2.

Coverage as a list (AGENTS.md *Tests*; no number for bash):

- S13.2 modes and `fail`: T16. S13.3 input and path: T4, T5, T11, T12, T17 (no `jq`). S13.4 the read: T1, T3, T6–T10, T13–T15, and T18's base cases (a tool_result and an isMeta entry after a crossing). S13.5 output per mode: T1 (`agent`), T3 (`prompt`), T18 (`stop`, five crossings and three quiet cases). S13.6 exit 0: asserted in the helper on all 27 runs. D36 no leak: T2 over every run. D46 never blocks: T18 key check and T19.
- S12 (`hooks.json`): V15 (`plugin details`), V16 (`jq` over the file), the `user_config` gate. S14: the five mutants above, `shellcheck`, `bash -n`, `test -x`. S1–S11, S15–S17 (Markdown, manifests): V1–V12, V14, V16, V18–V20 below, and their prescribed commands by V13.
- Not covered by any case, accepted: the defensive digit guard in S13 (the `[[ $v =~ ^[0-9]{1,15}$ ]]` `fail` branch) — jq's own `floor` output cannot fail it for any usage the fixtures can hold except an exponent form (usage above 1e17), which no fixture here builds; it exists so the script can never reach a bash arithmetic error. The hook's line reaching the model, `Stop`'s `systemMessage` reaching the user, the transcript-flush lag: I1, the user's. A real transcript's shape, the `Task` alias on CLIs older than 2.1.63, managed-policy settings, timing on other hosts (T9 printed 0.07 s on this host), and that a live session follows the prose: UNVERIFIED, as the plan says.

## Gates

`export TMPDIR=/data/tmp/claude`, from the repo root, `AGENTS.md` *Gates* exactly as edited.

Shell block, then shellcheck:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    rc=0

`tests/memory-sync.test.sh` (35 `ok` lines, none other):

    PASS 35/35
    rc=0

`tests/context-size.test.sh`:

    ok T1 agent: the last call's total, rounded up, in a PostToolUse line
    ok T3 prompt: the same line with the UserPromptSubmit event
    ok T4 a missing transcript: no stdout, one stderr line
    ok T5 a transcript path that is a directory: as a missing one
    ok T6 no assistant usage: no stdout, one stderr line
    ok T7 an empty transcript: as no usage
    ok T8 a truncated last line is dropped; the complete entry's number is used
    ok T9 a file past the window, with a 6 MB assistant line (36002184 bytes, 0.07s, not asserted)
    ok T10 an assistant entry longer than the window: silence, not a wrong number
    ok T11 malformed stdin: exactly one stderr line, jq's own error not printed
    ok T12 empty stdin, {} and a numeric transcript_path: no readable transcript
    ok T13 7 tokens print 1k, never 0k
    ok T14 a zero-usage entry does not hide the last real call
    ok T15 a subagent's entry is not the main conversation's size
    ok T16 an unknown mode and no mode are failures like any other
    ok T17 no jq: no stdout, one stderr line
    ok T18 stop: speaks once on a crossing, only with systemMessage, and not otherwise
    ok T19 stop never blocks or continues: no decision, continue, reason or context key in any output
    ok T2 no byte of a fixture's user lines reached stdout or stderr (27 runs)
    PASS 19/19
    rc=0

Plugin block (the last three commands print the counts below; the shell exit code 1 of the whole block is the last command's expected `rc=1`):

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

Config directories created under `$TMPDIR` by the block: 0 left. No `claude` command ran outside the block's `CLAUDE_CONFIG_DIR`; none called a model.

### V-checks (`/usr/bin/grep`, from the repo root)

    V1  caps gone                      no line, rc=1
    V2  new cap                        AGENTS.md, plugins/glab/agents/reviewer.md, plugins/glab/commands/ship.md, plugins/glab/skills/bootstrap/SKILL.md, plugins/glab/skills/manager/SKILL.md
    V3  tier rows                      199/201/203 (three lines, tier table only); exact-row count 3; '- round 3: <stage>' count 1
    V4  severity                       reviewer.md:83 and analyzer.md:76; 'unbounded memory growth': analyzer.md, reviewer.md, audit/SKILL.md
    V5  new agent                      commands/analyze.md, develop.md, ship.md, skills/manager/SKILL.md; 'new planning agent': manager, plan-first; '## A fix round' 1
    V6  resum per file                 1 develop.md, 2 ship.md, 1 bootstrap/SKILL.md, 13 manager/SKILL.md
    V7  map files                      AGENTS.md, analyzer.md, developer.md, manager, plan-first; 'findings-<area>' only the S1.10 sentence (manager :262)
    V8  round copies                   AGENTS.md, analyzer.md, developer.md, manager, plan-first
    V9  only **calls**                 one line each in plan-first and manager; 'you plan to change or call' 0
    V10 context phrases                1 1 1 1 1 1 1 1 3 2 3 (all as listed); CLAUDE_CODE_SESSION_ID: no line, rc=1; 'glab: context': AGENTS.md, README.md, context-size.sh, manager/SKILL.md, context-size.test.sh; SESSION-HANDOFF in manager-bootstrap.sh 0
    V11 One fact entries               1 1 1 1 1 1 1 (the S10.1 text, the four S10.2 entries, S10.3, S10.4); 'the review round cap' 0
    V12 versions                       glab 0.9.0, memory-sync 0.1.0
    V14 prefixed names                 no line, rc=1 (0 at 7df69a8)
    V16 hooks                          keys SessionStart,UserPromptSubmit,PostToolUse,Stop; four command lines, the PostToolUse one with matcher Agent, modes prompt/agent/stop, every timeout 5;
                                       glab green line -x -F 1, memory-sync line 1; UserPromptSubmit: README.md 1, AGENTS.md 2;
                                       README: old 'falls back' phrase 0, S16.2 sentence 1, S16.1 phrase 1, S16.3 opening 1;
                                       AGENTS: new contracts opener 1, old 0; 'run all four, in order' 1, 'run all three' 0
    V17 see Tests (19 ok lines, PASS 19/19, three mutants FAIL, missing path usage + exit 2)
    V18 grep decision|"continue"|exit 2|additionalContext: context-size.sh :17, :26, :27 (comments), :106, :109 (modes prompt and agent); stat -c %a: 755 and 755
    V19 'the range of the fix' 1 in reviewer.md, manager, ship.md; 'there is no round 3' 2; CONFORMS tree-id phrase 1; read-tree line 1; cmp -s line 1; 'Ask what changed and confirm it yourself' 0; 'scope each round after the first to what changed since the last one' 0
    V20 description 'The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook'; git diff 7df69a8 changed lines 2; plugin gates as above

V13 (a), the two lines copied out of the edited `SKILL.md` (with the `<temp directory>`, `<slug>` and `<n>` placeholders filled), in a new repo whose base commit holds `.gitignore` (`*.log`), `a.txt`, `c.txt` and a force-added `keep.log`; then a tracked change, a staged `s.txt`, untracked `new.txt`, ignored `x.log`, `keep.log` modified:

    t1=16818b2df6ca2bcfe3e3e3edfbb0215758e05cad
    status-same
    staged-same
    index-same
    tree t1: .gitignore a.txt c.txt keep.log new.txt s.txt
    -- fix round: keep.log changed again
    t2=ac75e44ae6e8cfe28b11a84cd9050b413912018a
     keep.log | 2 +-
     1 file changed, 1 insertion(+), 1 deletion(-)
    git diff --quiet rc=1
    same tree again -> same sha
    leftover .idx files: 0
    unborn HEAD: no tree id printed, "fatal: Not a valid object name HEAD"

(b) `cmp -s` on a copy and an amended copy: identical rc=0, changed rc=1, missing rc=2, output bytes 0. Throwaway repo and files removed (leftover count 0).

## Security blast radius (`glab:security`)

- What changed: payload text of the `glab` plugin (manager, plan-first, bootstrap, three commands, three agents) — round caps 2 (+1), every round a new agent, delta re-checks, a narrower planner search, a context rule; two report templates gain a `severity:` line (nothing parses it); `plugins/glab/hooks/hooks.json` gains three events running one new read-only script; `AGENTS.md`, `README.md`, one marketplace description, `glab` `0.9.0`.
- Who relies on it: every session where `glab` is enabled — the manager's behaviour, the hook runs in each of them (per message, per Agent call, per turn end). No script parses an agent report; `manager-bootstrap.sh` and the `memory-sync` plugin are untouched.
- What data it can affect: none written. `context-size.sh` reads the transcript Claude Code names (last 8 MiB, read-only), keeps no state, writes no file, opens no network connection, and prints only an integer and fixed words; T2 asserts no `SECRET=` fixture byte reaches stdout or stderr in 27 runs. It cannot block or continue a turn (T18, T19, V18); a failure is one stderr line and exit 0.
- Roll back: `git revert` of the change commit, raising `glab` to `0.9.1` in the same commit (`AGENTS.md`: a change under `plugins/<name>/` raises the version). The hooks stop once an installed copy updates; the script keeps no state, so nothing is left behind. Round copies and map files written in other repos' plan folders are inert text.

## Follow-ups

`plan/flow-cheaper-rounds/follow-ups.md`: FUa — two *One fact* entries (manual model rule, session effort) name the handoff-line format but not the new `· context <n>k` field; outside the plan's closed list.

## Not done

- I1 (the model run, `claude -p` and the interactive `Stop` check) — the user's, needs their OK (D41). Unproven until then: that the hook's line reaches the model, that `Stop`'s `systemMessage` is shown to the user and ends the turn, and the transcript-flush lag (D45, F20). If I1b shows `Stop` unusable, the plan's *Fallback plan* applies; the developer does not drop it.
- That a live session follows the new prose: UNVERIFIED, as the plan says for every rule of it.
- Nothing staged, committed or pushed.

## Fix round 1 — I1 stop lag

A new developer, scope S13.1, S13.4, S13.5, S14.2, S14.3, the one S1.16 sentence and the S16.3 sentence, with D61–D65 and the amended D31, D35, D45, D47. `plan.md`, `findings.md`, `questions.md` and the `plan.r*.md` copies were not touched. Nothing staged, committed or pushed.

### Stages

- S13.1 done — `plugins/glab/scripts/context-size.sh:11-13` (`stop` line of the mode list), `:35-38` (measure paragraph: the documented lag kept, the F23 sentence added), `:49-51` (harmless-reach paragraph). No comment holds `resum`; V18's words stay only in the comments that say `stop` never does them.
- S13.4 done — `context-size.sh:74-78` (the comment above the program), `:86` (state `{last: 0, base: 0, cur: null}`), `:94` (`.base = .last | .last = (.cur // 0)`). Output line, `read -r k cur base`, digit guard and names unchanged.
- S13.5 done — `context-size.sh:118-132`: the `stop` branch comment rewritten as the plan quotes it (300k and 100k reasons kept; why one turn back; the accepted second line; the two rejected options). The code of the branch is unchanged.
- S14.2 done — `tests/context-size.test.sh:207-257` T18 (eleven fixtures, rewritten for D62, the comment saying why the base is one turn back; `done_case` text as the plan gives it), `:259-269` T20, `:271-282` T21, `:284` T19's comment (now says it is judged over T18, T20 and T21), order T1, T3–T18, T20, T21, T19, T2. T19's code is unchanged: it already reads `$W/stopouts`, to which `stop_case` appends every `stop` run, T20's and T21's included.
- S14.3 done — the last line is `PASS 21/21` (the count comes from `done_case`; no literal to change).
- S1.16 sentence done — `plugins/glab/skills/manager/SKILL.md:101`: "When a turn crosses 300k or a further 100k, the same hook also tells the user directly at the end of the turn." → "When the context crosses 300k or a further 100k, the same hook also tells the user directly, at the end of that turn or, usually, the next." Nothing else of S1.
- S16.3 sentence done — `README.md:29-36`: the first sentence now reads "…and once the context has crossed 300k, 400k, … it shows you `glab: context <n>k … a good point to /compact, or to /clear between tasks` at the end of a turn — usually the turn after the crossing, because a turn's last model call is not yet in the transcript when the turn ends." The rest of the paragraph is as it was; it is re-wrapped only where that sentence moved the line breaks.

### Blocked

Nothing.

### Unplanned changes

- `tests/context-size.test.sh` gains a helper `stop_spec` (`:227-241`), which turns a spec such as `'P A100000 P R A200000'` into the fixture lines and calls `stop_case`. The plan writes every fixture in that notation; the helper is the way to write twenty-odd fixtures in it without repeating `"$(P)" "$(A …)"`. It adds no case and no assertion. `stop_case` and the `done_case` plumbing are unchanged except for its comment.
- T18's `stop_case` comment block is rewritten (the line above it, `# stop_case <name> …`, is kept) because the old one described the old base.

### Tests

Changed T18 (fixtures replaced); added T20, T21. Result: `PASS 21/21`.

Coverage as a list, for the changed code:

- S13.4 (`last`/`base` state): T18 — `P A100000 P R A200000`, the two-prompt fixtures, the tool_result and isMeta fixtures (a tool_result or isMeta counted as a prompt would give `''`, shown by mutants in V17), fewer than two prompts (`A420000 P A430000`, `A420000`); T20 and T21 for the observed lag and its accepted repeat.
- S13.5 (`stop` branch): T18 (key set `systemMessage` only on every output, message text, step 300k and 400k), T20 (once, on the turn after), T21 (then and once more, never a third), T19 (no blocking key in any `stop` output).
- S13.1 and the S13.4/S13.5 comments: V21 (counts below).
- S1.16 and S16.3 sentences: V21; V10 and V16 unchanged.
- Not covered by any case: a lag longer than one turn (D62: it would still speak, later); a `/compact` inside the two-turn range hiding a crossing until the next `Stop` (D62's known limit); the live display and the model run (I1c, the user's). Accepted as the plan lists them.

### Gates

    $ export TMPDIR=/data/tmp/claude; for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh tests/memory-sync.test.sh tests/context-size.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/context-size.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/context-size.test.sh rc=0
    $ shellcheck <the five files>; echo "rc=$?"
    rc=0
    $ bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh | tail -3
    ok T34 an edit that lands while a push runs is sent by the next push-if-changed
    ok T35 a transfer killed before the time limit is a failure, not a timeout
    PASS 35/35
    $ bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh
    ok T1 … ok T3 … ok T4 … ok T5 … ok T6 … ok T7 … ok T8 … ok T9 … (0.07s) ok T10 … ok T11 … ok T12 … ok T13 … ok T14 … ok T15 … ok T16 … ok T17 …
    ok T18 stop: speaks when the step rose since the prompt before the last, only with systemMessage, and not otherwise
    ok T20 stop, lagging transcript: speaks once, on the turn after the crossing
    ok T21 stop, a crossing already written at its own Stop: speaks then and once more, never a third time
    ok T19 stop never blocks or continues: no decision, continue, reason or context key in any output
    ok T2 no byte of a fixture's user lines reached stdout or stderr (42 runs)
    PASS 21/21

Plugin gates (each `claude` under a new empty `CLAUDE_CONFIG_DIR`, removed after):

    ✔ Validation passed  (x3)
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop
      Skills (1)  sync-memory / Agents (0) / Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0   plugins/memory-sync/hooks/hooks.json:0   rc=1
    memory-sync.sh:1  sync-memory/SKILL.md:1  README.md:1   rc=0
    (no line)  rc=1

V-checks:

    V10 (manager, joined): the heading 1; Read the number 1; Inside a task 1; At a task boundary 1; When no line has come 1; The handoff file 1; You never run 1; Run `/clear` (S1.18) 1; `· context <n>k` 3; `dispatches <d>` 2; `glab: context <n>k` 3
        grep -rl CLAUDE_CODE_SESSION_ID: no line, rc=1
        grep -rl 'glab: context': AGENTS.md, plugins/glab/scripts/context-size.sh, plugins/glab/skills/manager/SKILL.md, README.md, tests/context-size.test.sh
        grep -c SESSION-HANDOFF manager-bootstrap.sh: 0
    V16 hooks keys SessionStart,UserPromptSubmit,PostToolUse,Stop; four command lines (PostToolUse with matcher Agent; prompt, agent, stop; every timeout 5);
        AGENTS.md glab green line 1, memory-sync green line 1; UserPromptSubmit README 1, AGENTS 2;
        README: 'the `glab` hook falls back to plain text without it' 0, S16.2 sentence 1, '· a context hook on …' 1, 'context hook adds one line of about ten tokens' 1;
        AGENTS: 'The hook contracts do not change without a plan.' 1, old memory-sync wording 0, 'run all four, in order' 1, 'run all three' 0
    V21 manager 'at the end of that turn or, usually, the next' 1, 'tells the user directly at the end of the turn.' 0;
        README 'usually the turn after the crossing' 1, 'at the end of a turn that crossed' 0;
        script (cjoined): 'flow-cheaper-rounds/plan.md F23' 2, '{last: 0, base: 0, cur: null}' 1, '.base = .last | .last = (.cur // 0)' 1,
        'once, when the turn just ended crossed' 0, 'at most one line to the user per 100k step' 0
    V18 decision|"continue"|exit 2|additionalContext: context-size.sh :18, :27, :28 (comments that say stop never does them), :112, :115 (modes prompt and agent); stat -c %a: 755 755
    V17 21 ok lines in the order T1, T3–T18, T20, T21, T19, T2, then PASS 21/21; missing path: usage line, rc=2;
        mutants (throwaway copies in $TMPDIR, removed, leftover count 0):
        (a) "decision":"block" on the stop JSON  FAIL T18, T20, T21, T19   FAIL 4/21
        (b) "+ 999" removed                      FAIL T1, T3, T13          FAIL 3/21
        (c) the isSidechain filter removed       FAIL T15                  FAIL 1/21
        (d) the real-prompt branch back to the as-built `.base = (.cur // 0)`  FAIL T18, T20, T21   FAIL 3/21
        (FAIL line of (d), T20: "T20 stop 4, the turn after: expected the 310k message with only systemMessage, got []" — I1b's failure, caught without a model)

### Security blast radius (`glab:security`)

- What changed: the `stop` base of `context-size.sh` (one `reduce` state key and one assignment), the comments around it, the test cases, one sentence each in `glab:manager` and `README.md`.
- Who relies on it: every session where `glab` is enabled — at each turn end the user may now see the `stop` line one turn later than the earlier build meant, and at most twice per crossing (D61).
- What data it can affect: none written; the script still prints only an integer and fixed words (T2: 42 runs, no `SECRET` byte), never blocks or continues a turn (T18 key check, T19, V18), exit 0 on every path. The `Stop` line is shown to the user only.
- Roll back: revert the change commit with the rest of this plan; `glab` stays `0.9.0` (D26, D42) because the version is raised once, by the change the plan describes.

### Follow-ups

None new. `plan/flow-cheaper-rounds/follow-ups.md` is as the earlier developer left it.

### Not done

- I1c (the model run on the rebuilt `stop`) — the user's; no `claude -p` or any model call was made. Unproven until then: that the amended `stop` speaks on turn 2 and not on turn 1 in a live session. The fixtures reproduce I1b's lag (T20) and fail the earlier script (mutant d), which is not a live run.
- Everything outside the owned steps.

## Review fix round 1

Finding (review round 1/1, SHIP, low): the `context-size.sh` header said `stop` speaks "once per crossing of a 100k step, twice at most", which is not true when fewer than two real prompts fall inside the 8 MiB window (base stays 0, so `stop` speaks at every turn end at or past 300k). Fixed with the comment only, as the manager decided.

- Change: `plugins/glab/scripts/context-size.sh:51-56` - six comment lines added after the "twice at most" sentence: the exception, what causes it (more than 8 MiB of transcript between two consecutive prompts), that it ends with the next ordinary turn, and why it is accepted (the window bounds the read cost; a line too many is the cheaper error). No code line changed.
- Search for the same bound elsewhere: `/usr/bin/grep -n -i -E 'at most|once per|per crossing|per 100k|100k step|every turn end|at every turn' README.md plugins/glab/skills/manager/SKILL.md plugins/glab/skills/bootstrap/SKILL.md AGENTS.md`, filtered to context/stop/crossing/100k/300k, printed only `manager/SKILL.md:273` and `:342` (unrelated: "one at most" questions, review rounds). `README.md:29-35` and `manager/SKILL.md:101` state no per-crossing bound ("at the end of that turn or, usually, the next"), so nothing was qualified there. The plan-record line "at most twice per crossing (D61)" in the Security section above is a record of what was built and is left as written.
- Tests: none added. The behaviour (no base, speaks at or past 300k) is already covered by T18 cases `no prompt in the window, 420k` and `one prompt in the window, 430k`. Not covered: the 9 MB-gap fixture that triggers it through the real window cut; the same `reduce` state is exercised by those cases, and a 9 MB fixture would cost a case of its own beyond the one-case allowance.
- Gates (export TMPDIR=/data/tmp/claude), real output:
  - `bash -n && test -x` on the five scripts: five lines `rc=0`.
  - `shellcheck` on the five: `rc=0`, no findings.
  - `bash tests/memory-sync.test.sh ...`: last line `PASS 35/35`.
  - `bash tests/context-size.test.sh ...`: 21 `ok` lines, last line `PASS 21/21`.
  - Plugin block: three `Validation passed`; glab `Skills (14)`, `Agents (5)`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`; memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`; `glab = glab`, `memory-sync = memory-sync`; `user_config` counts `:0` `:0` then `rc=1`; `not yet confirmed` counts `1` `1` `1` then `rc=0`; prefixed-name grep no line, `rc=1`.
