# Result — flow-project-level/02-shared-rules

Built on `1bbf4bc`, 2026-11-14. Nothing staged, committed or pushed. `plugins/glab/.claude-plugin/plugin.json` still reads `0.15.0` (D29: no raise).

## Stages

- P1 — done. `plugins/glab/scripts/manager-bootstrap.sh`: the contract sentence is at `:22`; the id block is at `:44-63` and is P1's text exactly; `$HANDOFF` closes `CTX` at `:107-112`.
- P2 — done. `tests/manager-bootstrap.test.sh`: header `:5`, `ID_PATH`/`NO_ID` `:40-43`, `hook()` `:51-59`, B5 `:115-129`, B6 `</dev/null` `:133`, B14–B17 `:197-233`.
- P3 — done. `tests/product-loop.test.sh:103`.
- P4 — done. New `.gitignore`, two lines, exactly as the plan gives them.
- P5 — done. New `plugins/glab/skills/severity/SKILL.md` (616 bytes). In `plugins/glab/skills/audit/SKILL.md`, the table became the pointer under `:49` and item 5 is `:45`. In the four agents the frontmatter line is at `:8` (`project-reviewer` `:9`), and the body sentences are at `project-analyzer:100`, `project-plan-analyzer:109`, `project-reviewer:88` and `product-analyzer:42`.
- P6 — done. `plugins/glab/skills/commit/SKILL.md:11`.
- P7 — done. `plugins/glab/skills/session-rules/SKILL.md` was rewritten to 13298 bytes. Line 18 (*Where a record line goes*), the *Without subagent dispatch* bullet and the Rule 4 clause are verbatim: each `grep -cxF` / `-cF` against the `1bbf4bc` text prints `1`. The `:80` bullet ("You never run `/clear` or `/compact` yourself") is merged into the head of *Your own context* ("you cannot run `/clear` or `/compact` — never do").
- P8 — done. `plugins/glab/skills/security/SKILL.md:146`. `git diff --numstat` prints `1 1`.
- P9 — done. `plugins/glab/skills/bootstrap/SKILL.md` was rewritten to 5013 bytes. Step 5 is the plan's text exactly. New `plugins/glab/skills/bootstrap/references/hazards.md`: its heading, the line, then `sed -n '91,117p'` of the `1bbf4bc` file. `cmp` against that range prints `verbatim`.
- P10 — done. `AGENTS.md:20-22` (Layout), `:77` (Skills (22)), `:84` (four `…:glab:severity`), `:127-130` (hook contract), `:185-186` (severity), `:206-212` (handoff entry), `:367-369` (`plan/` rule). Only the edited lines were rewrapped. One break was moved so that `` `plan/handoff/` is never committed `` and `` `- status:` `` each stay on one line, which *Final check* step 8 needs.
- P11 — done. `README.md:9`.

## Blocked

None.

## Unplanned changes

- AGENTS.md: the rewrap of P10.4 and P10.7 reflowed the neighbouring lines of the same paragraph: `:130-132` (`One script is not a hook` … `a failed write;`) and `:22` (`belong to the repo …`). The words are unchanged.

## Tests

- Added: B14, B15, B16 and B17. Changed: `hook()`, B5 and B6 in `tests/manager-bootstrap.test.sh`, and `start()` in `tests/product-loop.test.sh`. Result: `PASS 17/17` and `PASS 17/17`.
- Coverage, as a list (`AGENTS.md` *Tests*):
  - P1: B14 (an id, both levels), B15 (no input), B16 (nine unusable inputs), B17 (compact equals startup), B5 (no `jq`) and B8 (the size limit).
  - The terminal branch `[ ! -t 0 ]` has no test (W12).
  - P2 and P3: the gates themselves, plus A9.
- A5 mutant: with `: mutant` in place of the regex line, the run printed `FAIL B16 …` and `FAIL 1/17`. After restoring the line from P1's block it printed `PASS 17/17`.

## Gates

**Script gates**
- `bash -n && test -x`: nine `rc=0`.
- shellcheck: `rc=0`.
- Test runs: `PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 17/17`, `PASS 17/17`, with 0 lines that are not `ok`.

**Plugin gates**
- `plugin validate --strict`: three `✔ Validation passed`, with `CLAUDE_CONFIG_DIR` set to a new `mktemp -d` under `/data/tmp/claude` and removed afterwards.
- `Skills (22)`: `… security, session-rules, severity`.
- `Agents (9)`: the nine.
- Both `Hooks (4)` lines carry the harness-only suffix.
- `glab = glab`, `memory-sync = memory-sync`.
- `user_config`: `:0 :0 rc=1`.
- `not yet confirmed`: `1 1 1 rc=0`.
- Model gate: the nine model lines, then `rc=0`.
- Skills gate: eighteen lines, four of them `…:glab:severity`, none `MISSING`.
- Prefixed `name:`: no line, `rc=1`.

**Posts**
- A1, sizes:
  - `session-rules` 13298 against a cap of 13312; `bootstrap` 5013 against 6144.
  - `prod=44994` (cap 47104), `list=9663` (cap 10240), `files=31 onel=31`.
  - Agent sets: `project-analyzer` 23437 (cap 23580), `project-plan-analyzer` 23129 (cap 23288), `project-reviewer` 27750 (cap 27973), `product-analyzer` 16508 (cap 16657).
  - `project-planner` is 31557. It belongs to 03 (W11).
  - `proj=75074` and `task=90971` are not judged until 03; three skill files belong to 03 and do not exist yet, so `cat` reports them missing.
  - Hook text: 2631 bytes (project), 2584 bytes (product).
- A2, *Final check* step 8:
  - The first search prints only `plugins/glab/skills/bootstrap/SKILL.md`.
  - The hook runs print `1`, `0 1`, `0 1`, `1`.
  - `rc=0`.
  - Every `c` line is 1 or more (session-rules: 2, 1, 3, 2, 1; bootstrap: 2, 1, 1, 2; security: 1; AGENTS.md: 1, 1, 2, 1). `rule2` is 1 and `rule3` is 1.
  - `git status --short plan/handoff` prints nothing.
- A3:
  - Every listed string on `session-rules` is 1 or more, and the `haiku`/`glab:commit` clause is exactly `1`.
  - The nine model pairs are each `1`; the rule headings count `8`.
  - `bootstrap`: steps `6`; `references/hazards.md`, `command grep` and `make ci` are each `1`.
  - `hazards.md`: `psql | head -8` 1, `(cached)` 1, `max-same-issues` 1.
  - `anonymous receiver` prints **2**, not the `1` the plan expects. The plan prescribes a verbatim copy, and that copy holds the phrase twice: line 6 has "an anonymous receiver" and line 8 has "anonymous receivers". `git show 1bbf4bc:…bootstrap/SKILL.md | sed -n '91,117p' | grep -nF` prints both lines. So the plan's expected count is off by one, and the tree is not.
  - `Dispatch independent agents`: bootstrap `0`, session-rules `1`.
- P5: `grep -rn 'glab:audit' plugins/glab/agents` prints nothing, `rc=1`.
- P6: `report as your file says` counts `1` in commit and `0` in session-rules.
- A9: `</dev/null` counts `2` and `1` (`0` and `0` on `1bbf4bc`); the header line `1`; README `1`.
- `master.md` was untouched: `sha256sum -c master.sha256` prints `master.md: OK`.

## Follow-ups

None written. The A3 off-by-one is a plan-text count, reported here for the planner or manager. It is not tree work.

## Not done

- A6, the live `/compact` check, is the user's to run after installing 0.15.0. UNVERIFIED: the handoff path is unchanged after `/compact` in a live session. B17 proves only that the same id gives the same text.
- A7, the commit, and A8, the back-out, are not mine to run.
- 03's lines are left as they stand: the `project-planner` sum, `proj` and `task`.

## Review round 1 fixes

The manager's reconciliation of two reviewers, fixes 1–10, plus W15. 2026-11-14.

- **1, closed stdin** — `plugins/glab/scripts/manager-bootstrap.sh:57`: `{ : 3<&0; } 2>/dev/null || exec </dev/null`, with its comment at `:53-54`. Before: `timeout 3 bash manager-bootstrap.sh <&-` printed `closed rc=124`. **This differs from the guard the manager prescribed.** `{ : <&0; }` was measured to succeed with fd 0 closed: a probe script printed `guard-open`, then `ls: cannot access '/proc/<pid>/fd/0'`. Bash 5.3.9 treats `0<&0` as a no-op, so the hang stayed (B18 failed with `rc=124`). A copy to fd 3 fails on a closed fd 0: the probe printed `guard-closed`, and fd 0 became `/dev/null`. It printed `guard-open` with a pipe on stdin. Test: B18 (`tests/manager-bootstrap.test.sh:235`) runs the hook with `<&-` under `timeout 10` and asserts the contract, the no-id text and an empty stderr.
- **2, trailing newline** — `manager-bootstrap.sh:59-64`: a sentinel. `jq -r … && printf .`, then `${id%.}` and `${id%$'\n'}`, so only jq's own newline is removed. The rest of an id goes to the bash regex as it came. Before: `{"session_id":"abc\n"}` named `plan/handoff/abc.md`. The jq option was rejected, because measured `printf '"abc\n"' | jq -r 'select(test("^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$"))'` printed `a b c \n \n`: jq's `$` matches before a final newline. The sentinel also keeps the bash `[[ $id =~ … ]]` line as the only guard, so A5's mutant still targets it. A jq failure still gives `id=''`. Test: B19 (`:245`).
- **3** — `manager-bootstrap.sh:47-48`: the `evidence.md E11` path is replaced by "measured live in Claude Desktop, 2026-11-14: unchanged across startup, /compact and resume".
- **4** — `session-rules/SKILL.md:118`: the clause "which outranks the main conversation's model" is restored. "overrides both" became "overrides the parameter and the definition", because "both" became ambiguous with three items. A hedge was added: "Versions, and what no live dispatch has shown yet: the `glab` repository's `docs/specs/workflow.md`."
- **5** — `:117`: "After a compaction, read that line before dispatching that role." is restored.
- **6** — `:16`: "At the product level, a project stage named here …".
- **7** — Rule 2 `:78` now reads "a regular file `plan/handoff/<id>.md`, `<id>` matching `[A-Za-z0-9][A-Za-z0-9_-]{0,127}` as the no-id name does, whose first line is `- status: completed`, and nothing else". The enumeration "no subdirectory, no other name, no file that holds the line anywhere but its first line" is dropped, because "regular file", the pattern and "first line" now say the same thing. Checked: `[[ 20261114T190300Z =~ ^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$ ]]` printed `fallback name matches`. `bootstrap/SKILL.md:39`: "each other `<id>.md` that Rule 2's standing approval covers (first line `- status: completed`)".
- **8** — `bootstrap/SKILL.md:40`: "every other file under `plan/handoff/` — `in-flight`, no status line, a status not on its first line or of another value — and the legacy … : treat it as in-flight", which needs the user's yes as before. `:38` now uses Rule 2's wording: "the one the session-start text names, with `no session id` there the name it gives; after a compaction the file your summary names as yours".
- **9 (W15)** — `project-manager/SKILL.md:20` and `product-manager/SKILL.md:20` now list `glab:severity` after `glab:audit`. The `AGENTS.md` *One fact* level-boundary entry holds no skill list, so it is unchanged. Nor does `README.md`: `:9` already names `glab:severity`, and `:274` is a rename statement. `docs/specs/workflow.md:117` holds the same list without it. That is the record's job, and it went to `follow-ups.md`.
- **10** — Not covered: `[ ! -t 0 ]` (`manager-bootstrap.sh:59`). A test needs a pty, and none can be made portably here (W12). Re-run once: the reviewer's mutant (`if true; then`, on a copy under `$TMPDIR`) printed `PASS 19/19`, so no case catches it.

Cuts that pay for fixes 4–7 in `session-rules`. They change wording only, and no rule another file points at is touched:

- `:57`: "Your context is the scarce resource: spend …" became "Spend your context …".
- `:61`: "pays again for all it read" became "re-pays all it read". "The stage's own text says what each is given." is dropped: Rule 0c `:34` already says it.
- `:71`: "Every turn pays for all your context, and" is dropped. That is rationale.
- `:38`: ", whatever its role" is dropped.
- `:42`: "The handoff line says it." is dropped: *The handoff line* already says "the effort is the level you passed".
- `:34`: ": a second copy the agent must reconcile" is dropped. That is rationale.
- `:124`: ", and the one resume Rule 2 allows" is dropped: Rule 2 `:61` names Rule 5's report check as its one resume.

Not run: A5's `: mutant`, because the dispatch allowed no mutant beyond the `true` one. Its `sed` pattern still matches `manager-bootstrap.sh:67`. That was checked with `grep -n`, not by running the mutant.

Sizes, measured with the plan's own commands:

- `session-rules` 13310 ≤ 13312.
- `bootstrap` 5212 ≤ 6144.
- Hook text: project 2631, product 2584. Both are unchanged, and both are under 10000.
- *Final check* step 4:
  - `prod=45222` ≤ 47104;
  - `list=9663` ≤ 10240;
  - `files=31 onel=31`;
  - `project-analyzer 23437` ≤ 23580;
  - `project-plan-analyzer 23129` ≤ 23288;
  - `project-reviewer 27750` ≤ 27973;
  - `product-analyzer 16508` ≤ 16657.
- 03's, not judged here:
  - `proj=75302`;
  - `task=91199`, with `cat` reporting three missing 03 skills;
  - `project-planner 31557`;
  - `project-manager` 40845.
- `product-manager` grew from 10795 to 10812 (+17, fix 9) and stays inside `prod`.

Gates and posts, run once at the end:

- `AGENTS.md` block 1:
  - nine `rc=0`;
  - shellcheck `rc=0`;
  - `PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 19/19` (B1–B19; it was 17/17, and B18 and B19 are new) and `PASS 17/17`;
  - no line other than `ok`.
- `AGENTS.md` block 2:
  - three `✔ Validation passed`;
  - `Skills (22)` with the 22 names, including `severity`;
  - `Agents (9)`;
  - both `Hooks (4)` lines with the suffix;
  - `glab = glab` and `memory-sync = memory-sync`;
  - `:0 :0 rc=1`;
  - `1 1 1 rc=0`;
  - the nine model lines, then `rc=0`;
  - the eighteen skills lines, four of them `glab:severity`, none `MISSING`;
  - no prefixed `name:`, then `rc=1`.
- An incident in the gate run itself: block 2 was first extracted one line too early. Line 50 of `AGENTS.md` is prose, and bash ran it. That printed `line 1: /home/pvhv/.claude: Is a directory` (a backticked `~/.claude` tried as a command) and `without: command not found`. Nothing was run or written there. The last two gate lines were then re-run from the right range.
- *Final check* step 8:
  - only `plugins/glab/skills/bootstrap/SKILL.md`;
  - `1`, `0 1`, `0 1`, `1`;
  - `rc=0`;
  - every `c`, `rule2` and `rule3` count ≥ 1.
- A3: every registered fact ≥ 1. The `haiku` line printed `1`, the nine model pairs `1` each, the Rule headings `8` and the bootstrap steps `6`. In `hazards.md`: `1 1 1 2 1 1 1` (W14). `Dispatch independent agents` printed `0 1`.
- A9: `2 1 1 1`.

UNVERIFIED: that `{ : 3<&0; }` behaves the same on bash versions other than 5.3.9 (on macOS, bash 3.2). Only 5.3.9 was run.

## Review round 2

- **Verdict:** SHIP, from a new reviewer given round 1's findings and the fix locations.
- **The one low:** `manager-bootstrap.sh:57` exited 1 under `bash --posix <&-`, because `:` is a special builtin.
- **The fix:** the manager made it as a trivial edit, `:` → `true`, with a comment saying why.
- **Proven after the fix:** `bash --posix` with stdin closed gives rc=0, and a plain closed stdin gives rc=0. `bash -n`/`test -x` and shellcheck give rc=0. `PASS 19/19` (manager-bootstrap) and `PASS 17/17` (product-loop).
