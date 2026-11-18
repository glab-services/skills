# Result — slim-agents-md

## Stages
- 1 done: branch `slim-agents-md`; `git diff --quiet origin/main -- AGENTS.md README.md plugins/ tests/; echo $?` printed `0` (origin/main 684163d).
- 2 done: nothing saved; P4 reads `git show origin/main:AGENTS.md`.
- 3 done: `tests/gates.sh` (new, mode +x): header 1-14, `set -uo pipefail` 15, `cd` 16, preflight 18-30 (D3), `W`/trap/`cfg` 32-39 (D4), counters and helpers 111-126 copied from `tests/context-size.test.sh` 15-16, 20, 37-47; plus `lines`, `same_set`, `component` 128-161 (D5 set compare).
- 4 done: arrays 41-107 (`SCRIPTS` 10, `TESTS` 5, `GLAB_SKILLS` 25, `GLAB_AGENTS` 9, `GLAB_HOOKS`, `MS_SKILLS`, `MS_AGENTS=()`, `MS_HOOKS`, `MARKET`, `MODEL_LINES` 9, `SKILL_LINES` 18).
- 5 done: G1-G31 at 163-319, each with its reason comment; the one `claude` subshell at 211-222.
- 6 done: end 321-326.
- 7 done: `docs/one-fact.md` (new): title, one intro line, 37 `## ` sections in E8 order; D10 retargets at lines 59 (#6), 65 (#7), 92 (#10), 106 (#11), 117 (#12) and #20 ("and `AGENTS.md`'s `plan/` rule").
- 8 done: `AGENTS.md` *Layout* lines 18-21; *Gates* lines 26-35 (the given text) with "The Markdown files have no gate…" kept verbatim; *Rules* *One fact* bullet replaced by the D11 text. Every other *Rules* bullet byte-identical with origin/main (checked by script: `True`).
- 9 done: `README.md` `tests/` row extended; new `docs/one-fact.md` row after `docs/specs/`.
- 10 done: post-conditions below.

## Blocked
None.

## Unplanned changes
- `tests/gates.sh`: a failed `mktemp -d` or `mkdir` of the work/config directory also exits 2 with one stderr line (needed so the D4 trap never sees an empty `W`); not in D3's list.
- `tests/gates.sh`: the G1-G10 comment was reworded so that no comment line starts with the word "shellcheck" (shellcheck parses such a line as a directive, SC1072/SC1073). Text kept; only the word order on that line changed.
- `README.md` new row: the path is in backticks (`` `docs/one-fact.md` ``), like every other row; the plan's row text sat inside one code span and could not show them.
- G12-G16 capture stdout and stderr together (2>&1), so a stray stderr line counts as a non-ok line.
- G17-G19 check the validate rc (0) as well as the last line.

## Tests
Coverage per AGENTS.md *Tests* (a list, not a number):
- Mutated checks: G4 (M2), G10 (M4), G29 (M1), G30 (M3), preflight CLI (M5), preflight TMPDIR (M6). All gave the expected result.
- No mutation: G1-G3, G5-G9, G11-G28, G31. Accepted per plan step 10: direct string, count or rc comparisons of the same kind, each shown green on the real tree in P2.
- M1 resolves the plan's UNVERIFIED: `validate --strict` did not reject an agent with no `model:`; only G29 failed (`FAIL 1/31`).

## Gates
This change's gate is `bash tests/gates.sh` (P2, green). P1-P9 and M1-M6 output:

```
== P1
8181
0
== P2
0
ok G1 syntax and execute bit: plugins/memory-sync/scripts/memory-sync.sh
ok G2 syntax and execute bit: plugins/glab/scripts/manager-bootstrap.sh
ok G3 syntax and execute bit: plugins/glab/scripts/context-size.sh
ok G4 syntax and execute bit: plugins/glab/scripts/plan-gate.sh
ok G5 syntax and execute bit: tests/memory-sync.test.sh
ok G6 syntax and execute bit: tests/context-size.test.sh
ok G7 syntax and execute bit: tests/plan-gate.test.sh
ok G8 syntax and execute bit: tests/manager-bootstrap.test.sh
ok G9 syntax and execute bit: tests/product-loop.test.sh
ok G10 syntax and execute bit: tests/gates.sh
ok G11 shellcheck on 10 scripts
ok G12 test: tests/memory-sync.test.sh 35/35
ok G13 test: tests/context-size.test.sh 24/24
ok G14 test: tests/plan-gate.test.sh 51/51
ok G15 test: tests/manager-bootstrap.test.sh 19/19
ok G16 test: tests/product-loop.test.sh 17/17
ok G17 plugin validate --strict plugins/glab
ok G18 plugin validate --strict plugins/memory-sync
ok G19 plugin validate --strict .
ok G20 glab Skills (25)
ok G21 glab Agents (9)
ok G22 glab Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
ok G23 memory-sync Skills (1)
ok G24 memory-sync Agents (0)
ok G25 memory-sync Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
ok G26 marketplace names match plugin.json
ok G27 no user_config in hooks.json
ok G28 'not yet confirmed' hedge in 3 files
ok G29 agent models (9 lines)
ok G30 agent skills (18 lines)
ok G31 no prefixed name: in plugins
PASS 31/31
rc=0
0
== P3
rc=0
== P4
37 37 0
1 *Dispatching the planner*
1 *Levels*
1 *Re-checks*
1 *Re-reviews*
1 *Report*
2 *Round caps*
3 *The handoff line*
1 *The level boundary*
1 *The shared store*
1 *Your skills — this level only*
== P5
5
rc=1
== P6
checked
== P7
0
 M AGENTS.md
 M README.md
?? docs/one-fact.md
?? plan/manager-flow-notes.md
?? plan/slim-agents-md/check.r1.md
?? plan/slim-agents-md/check.r2.md
?? plan/slim-agents-md/plan.md
?? plan/slim-agents-md/plan.r1.md
?? plan/slim-agents-md/plan.r2.md
?? tests/gates.sh
== P8
== M1
FAIL G29 agent models (9 lines): missing [plugins/glab/agents/committer.md:model: haiku]
FAIL 1/31
rc=1
== M2
FAIL G4 syntax and execute bit: plugins/glab/scripts/plan-gate.sh: rc=1 (syntax error or no execute bit)
FAIL 1/31
rc=1
== M3
FAIL G30 agent skills (18 lines): missing [plugins/glab/agents/project-developer.md:glab:comments] unexpected [plugins/glab/agents/project-developer.md:glab:coments MISSING]
FAIL 1/31
rc=1
== M4
FAIL G10 syntax and execute bit: tests/gates.sh: rc=1 (syntax error or no execute bit)
FAIL 1/31
rc=1
== M5
rc=2
stdout bytes: 0
stderr lines: 1
gates.sh: no Claude Code CLI found - set CLAUDE_BIN to the path your host file names
== M6
rc=2
stdout bytes: 0
stderr lines: 1
gates.sh: TMPDIR unset - export it to the temp directory your host file names
gates.* before 0 after 0
== after
0
== P9
P2: G20 "glab Skills (25)", G21 "glab Agents (9)", G29 "agent models (9 lines)", G30 "agent skills (18 lines)" - matches E3/E4.
```

P8 "after" counts only `gates.*` and `gates-mut.*`; the `gates-*.log` files in the temp directory existed before this run and were left alone.

Sizes: `AGENTS.md` 8181 B (was 29824), `docs/one-fact.md` 14974 B, `tests/gates.sh` 16192 B, `README.md` 21468 B (was 21283).

## Follow-ups
None added.

## Not done
- Per the plan's *Not done*: no 6 KB target, no `docs/specs/` update, no `plan/` rule rewrite, no version bump, no pinned per-test counts.
- UNVERIFIED: whether the CLI's Hooks order is stable (kept from the plan; G22/G25 compare it exactly and passed).
- Nothing staged or committed.

## Fix round 1

Review `review.r1.md` (snapshot 2d3ecfc), decision D19: all four fixed. Files changed: `tests/gates.sh`, `docs/one-fact.md`, `AGENTS.md` only.

- 1 done: `tests/gates.sh:45` `trap 'exit 130' INT; trap 'exit 143' TERM; trap 'exit 129' HUP` after the EXIT trap (:44). The comments at :9-10 and :39-41 now say the dir is removed on INT, TERM or HUP as well.
- 2 done: `docs/one-fact.md`: the three round-copy files are now one bullet, "for the round copies only: `plan-gate.sh`, which leaves them out of the digest, `project-plan-report/SKILL.md` and `product-plan-analyze/SKILL.md`".
- 3 done: `AGENTS.md:29-30` "...are in the script: the values in its arrays, the reasons in its comments." The next two lines are rewrapped.
- 4 done: `tests/gates.sh:25-35`: the TMPDIR and CLI preflight now runs before the `cd` (which moved to :35). `:28` refuses a TMPDIR that does not start with `/` (one stderr line, exit 2). `:32` makes a relative `command -v` result absolute against the caller's `$PWD`. `:263` uses `${MS_AGENTS[@]+"${MS_AGENTS[@]}"}`, with a reason comment. The exit-code header (:12-14) lists the new preflight failure.

Unplanned: none. Nothing staged or committed.

Evidence (TMPDIR=/data/tmp/claude, bash 5.3.9):
- `bash tests/gates.sh; echo rc=$?`: G1-G31 ok, `PASS 31/31`, `rc=0`. Afterwards `ls -d "$TMPDIR"/gates.* | wc -l` printed `0`.
- TERM: `bash tests/gates.sh >out 2>&1 & pid=$!; sleep 4`. `ps -p $pid` printed `bash tests/gates.sh` and there was 1 work dir (`during=1`). `kill -TERM $pid; wait $pid` gave `rc=143`, then `after=0`, with the last line `ok G11 shellcheck on 10 scripts` and no test process left. Bash runs the trap only after the current foreground child returns.
  Two earlier attempts killed the wrong process: the PID was a wrapper subshell, because `export ... && bash ... &` backgrounds the whole list. In those runs the script went on to `PASS 31/31`, and its EXIT trap still removed the dir (count 0 afterwards).
- `TMPDIR=rel bash tests/gates.sh`: `rc=2`, stdout 0 bytes, 1 stderr line `gates.sh: TMPDIR is not an absolute path - export it to the temp directory your host file names`. `git status --short -uall` was the same before and after (cmp), and no `rel` dir was created.
- `CLAUDE_BIN=./nope` printed the existing no-CLI line, rc=2. The resolution lines, run from /usr with `CLAUDE_BIN=./bin/env` and then `cd` to the repo, gave `/usr/./bin/env`, which is executable.
- UNVERIFIED: a full run with a relative CLAUDE_BIN pointing at the real CLI. Only the two resolution lines were run, not a whole gate run.
- UNVERIFIED: the `+` expansion on bash < 4.4, because no older bash is available here. On 5.3 G24 passes.
- `bash -n tests/gates.sh && test -x tests/gates.sh && shellcheck tests/gates.sh; echo rc=$?` printed `rc=0`. `wc -c < AGENTS.md` printed `8225`.
- P4 python from plan.md *Post-conditions* printed `37 37 0`.
