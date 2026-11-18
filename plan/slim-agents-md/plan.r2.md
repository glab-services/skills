tier: normal — repo docs (AGENTS.md, README.md, a new docs file) and a new repo test script; no payload, schema, secret or money.

# slim-agents-md

## Decisions

- D1 `tests/gates.sh` runs every gate from both *Gates* blocks and compares each result with its expected value. It prints one line per check, `ok G<n> <name>` or `FAIL G<n> <name>: <reason>` (the `done_case` style of `tests/context-size.test.sh`), then `PASS 31/31` or `FAIL <f>/31`. It exits 0 when all pass, 1 on any FAIL, and 2 when a preflight fails. The 31 checks:
  - G1–G10: `bash -n && test -x` on 10 scripts (the old 9 plus `tests/gates.sh`);
  - G11: shellcheck on the same 10;
  - G12–G16: the five tests;
  - G17–G19: `plugin validate --strict` (glab, memory-sync, `.`);
  - G20–G22: the glab Skills/Agents/Hooks lines; G23–G25: the same three for memory-sync;
  - G26: marketplace names; G27: `user_config`; G28: `not yet confirmed`; G29: model lines; G30: skills lines; G31: prefixed `name:`.
- D2 The script checks itself without running itself. `tests/gates.sh` is in its own file list, so G10 runs `bash -n` and `test -x` on it and G11 runs shellcheck on it. Neither executes the file, so there is no recursion. The script never runs `bash tests/gates.sh`.
- D3 The preflight comes first. Before any check, the script needs:
  - `TMPDIR`: `[ -n "${TMPDIR:-}" ] || { echo 'gates.sh: TMPDIR unset - export it to the temp directory your host file names' >&2; exit 2; }`;
  - the CLI: `claude=$(command -v "${CLAUDE_BIN:-claude}") || { echo 'gates.sh: no Claude Code CLI found - set CLAUDE_BIN to the path your host file names' >&2; exit 2; }`;
  - `jq` and `shellcheck`, the same way.

  It does not use `:?`: under `env -u TMPDIR`, `: "${TMPDIR:?…}"` prints a bash-formatted `…: line 3: TMPDIR: …` and exits 1 (the plan check ran it). A failed preflight prints exactly one stderr line, exits 2, and prints no ok, FAIL or PASS line. It is neither FAIL lines nor a skip. A skip could be pasted as green, and a list of partial `ok` lines could pass as gate evidence; that is the old `:?` intent: "no later line is printed as though the gates had run".
- D4 Every `claude` command runs in one subshell. Before it, the script makes `W=$(mktemp -d "$TMPDIR/gates.XXXXXX")` with `trap 'rm -rf "${W:?}"' EXIT`, then `mkdir "$W/claude-config"`. The subshell checks `[ -d "$cfg" ]`, then runs `export CLAUDE_CONFIG_DIR="$cfg"`, and writes all CLI output into `$W`. The comparisons run afterwards. The variable is never exported empty, and the trap removes the directory on every exit path. The script starts no background process, so it kills nothing.
- D5 Skills and Agents are compared as sets. The script parses `  Skills (N)  a, b, …`, then checks N and that the sorted names equal the sorted expected list. The CLI lists them in directory read order, which is not stable (baseline E3: the Agents order differs from AGENTS.md). Hooks lines are compared as exact strings, suffix included. Model lines and skills lines are compared after `LC_ALL=C sort` on both sides: the baseline order (E4) is glob order, not the order AGENTS.md lists.
- D6 The script does not hard-code the five tests' own counts. G12–G16 need rc 0, every line but the last starting `ok `, and a last line `PASS k/k`. The old gate did not fix those counts either, so the script adds no new copy of them.
- D7 AGENTS.md loses its copy of the expected values. Today the component counts and names, hook lines, model lines, skills lines and marketplace pairs are stated in AGENTS.md *Gates* and, per registry #7, in README.md and each `hooks.json`. After the change they are stated in `tests/gates.sh` (as arrays at the top), README.md and the `hooks.json` files, the list #7 names. AGENTS.md says "green is a last line `PASS n/n`" and states no n, so the change adds no new copy. One copy moves from AGENTS.md to `tests/gates.sh`.
- D8 Every reason in *Gates* moves into a `#` comment above the check it explains, by the phrases listed in Step 5, so that P6 can check it. The prototype's flaws are not carried over: a hard-coded `cd` and TMPDIR, `| tr` hiding the rc, no comparisons, and no exit status.
- D9 The registry moves to `docs/one-fact.md`. The file has a title and one intro line. The intro says the rule is in `AGENTS.md` *Rules* (*One fact, one value*) and that every fact listed is one that more than one file states (that clause moves out of AGENTS.md). All 37 entries stay in today's order, each as one section:
  - a `## <fact>` heading;
  - a paragraph holding the entry's text before its file list, verbatim (line wrapping may change);
  - a `- ` list with one bullet per file of the entry's last parenthetical, qualifiers kept on the bullet ("(all but the version copies)", "for the round copies, which leaves them out of the digest").

  Entry #14 (severity) has no parenthetical and is a paragraph only. The wording changes only where D10 says.
- D10 Registry entries are numbered by E8's rule. These change; all others stay as they are:
  - #6 marketplace and plugin names: add `tests/gates.sh` (it expects `glab = glab`, `memory-sync = memory-sync`).
  - #7 what each plugin holds: "the *Gates* section of this file" becomes `tests/gates.sh`.
  - #10 the `SessionEnd` budget and its hedge: add `tests/gates.sh` (G28 and its comment state the hedge).
  - #11 model per role: "the model gate in this file's *Gates*" becomes "the model check (G29) in `tests/gates.sh`".
  - #12 skills each agent preloads: "the skills gate in this file's *Gates*" becomes "the skills check (G30) in `tests/gates.sh`".
  - #20 plan lifecycle: "this file's `plan/` rule" becomes "`AGENTS.md`'s `plan/` rule".
  - #4 (memory-sync hook events) and #18 (context hook) are covered through #7, as today, and are not changed.
- D11 In AGENTS.md, the *One fact* rule shrinks to: "A number or name stated in more than one file changes in all of them in the same commit. A rule lives in the file of the role that acts on it; every other file points at it without restating it. The known cases — each such fact and the files that state it — are in `docs/one-fact.md`." Its meaning does not change.
- D12 Per paragraph of *Rules*. **Shrinks:** *One fact* (D11). **Stays verbatim:**
  - No secrets
  - memory-sync backend
  - `~/.claude`/install: it cites "the `CLAUDE_CONFIG_DIR` rule in *Gates*", which stays in *Gates*
  - Comments kept
  - PID cleanup
  - the `plan/` rule: the user's queued docs-lifecycle slug rewrites it
  - version bump
  - prefixed names
  - the hook contracts: an agent acts on this rule in this repo, and the payload comment `plugins/glab/scripts/context-size.sh:34` cites "AGENTS.md *Rules*" for it (E5). Moving it would leave that pointer dangling or force a payload edit and a version bump.

  *Layout*, *Tests* and *Commits* stay; *Layout* gains the two new paths.
- D13 Size target: `wc -c AGENTS.md` ≤ 8800, expected about 8.4 KB. The hook-contract paragraph (about 1220 B) and the `plan/` rule (about 1727 B) stay verbatim for the reasons in D12.
- D14 `README.md`: the `tests/` row names `tests/gates.sh`; a new row names `docs/one-fact.md`; the `AGENTS.md` row ("and the gates") stays true, because AGENTS.md still says how to run them.
- D15 No file under `plugins/` or `.claude-plugin/` changes, so no plugin version is raised (E7).
- D16 `docs/specs/*.md` is not touched. Its lines that cite AGENTS.md *Gates*, *Rules* or *One fact* are records "as of <sha>" or current-state lines that the next `glab:project-record` updates (`marketplace.md`: the gates, the rules).
- D17 (manager) The size target becomes ≤ 8800 bytes instead of about 6 KB: the hook contracts stay because `plugins/glab/scripts/context-size.sh:34` points at them (moving them is a payload edit and a version bump), and the `plan/` rule shrinks in the queued docs-lifecycle slug.

## Evidence

E1 Size per section (awk sum of line lengths; the total matches `wc -c` = 29824):
```
## Layout 880 / ## Gates 8818 / ## Tests 642 / ## Rules 18856 / ## Commits 306 / intro 321
Rules: secrets 182, backend 119, ~/.claude 416, hook contracts 1220, One fact 14164,
comments 120, PID 104, plan/ 1727, version 401, prefixed names 393
```
E2 Baseline, block 1 as written (`TMPDIR=/data/tmp/claude`):
```
plugins/memory-sync/scripts/memory-sync.sh rc=0 … tests/product-loop.test.sh rc=0   (9 lines, all rc=0)
rc=0                                                     (shellcheck, no findings)
memory-sync PASS 35/35 · context-size PASS 24/24 · plan-gate PASS 51/51 ·
manager-bootstrap PASS 19/19 · product-loop PASS 17/17   (each: rc 0, only non-ok line is the last)
```
E3 Baseline, block 2, the `claude` part, run directly in the shell (a `bash -c` wrapper around it was refused by the harness's rm safety check):
```
✔ Validation passed   (×3)
  Skills (25)  audit, bootstrap, comments, commit, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-verdict, project-analyze, project-develop, project-integrate, project-manager, project-plan, project-plan-accept, project-plan-analyze, project-plan-report, project-record, project-review, project-ship, push, security, session-rules, severity
  Agents (9)  project-planner, product-planner, project-developer, project-integrator, product-analyzer, committer, project-analyzer, project-reviewer, project-plan-analyzer
  Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
  Skills (1)  sync-memory
  Agents (0)
  Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
cfg left: 0
```
E4 Baseline, the rest of block 2:
```
glab = glab / memory-sync = memory-sync
plugins/glab/hooks/hooks.json:0 / plugins/memory-sync/hooks/hooks.json:0 / rc=1
memory-sync.sh:1 / sync-memory/SKILL.md:1 / README.md:1 / rc=0
committer.md:model: haiku, product-analyzer opus, product-planner opus, project-analyzer sonnet,
project-developer sonnet, project-integrator sonnet, project-plan-analyzer opus, project-planner opus,
project-reviewer sonnet / rc=0                         (9 lines, glob order)
18 skills lines, none MISSING (committer:security … project-reviewer:severity, glob order)
rc=1                                                   (no prefixed name:)
```
All values match AGENTS.md's green lists. Only the order of the Agents, model and skills lines differs.

E5 References to this repo's AGENTS.md sections. `/usr/bin/grep -rnE "AGENTS\.md[^a-z]{0,4}\*[A-Z]|\*(Gates|Rules|One fact[^*]*|Tests|Layout)\*" plugins README.md host.example.md tests .claude-plugin docs/*.md`:
```
plugins/glab/scripts/context-size.sh:34:# Contract, like memory-sync.sh's (AGENTS.md *Rules*): …
plugins/glab/skills/session-rules/SKILL.md:64:- **One fact from a long document?** …   (unrelated)
```
- Every other `AGENTS.md` in `plugins/`, `README.md` (lines 41, 42, 80, 85, 94, 145, 147) and `host.example.md:39` means the installing repo's file; that payload stays unchanged.
- Own references to retarget: `README.md:369` and `:373` (the layout table), and AGENTS.md itself (D10).
- `.claude-plugin/` and `docs/` outside `specs/` have no hit.
- Matches in `docs/specs/` (records and current-state lines, unchanged): marketplace.md 94, workflow.md 54, external-agents.md 10, memory-sync.md 5, product.md 4.

E6 The tests read fixtures, never this repo's AGENTS.md. `/usr/bin/grep -c '^glab-level:' AGENTS.md` → `0`.
- `tests/manager-bootstrap.test.sh:10,14`: `W=$(mktemp -d "${TMPDIR:?…}/manager-bootstrap-test.XXXXXX")`, `cd "$W"`. It writes `"$W/$1/AGENTS.md"` (line 48) and runs with `CLAUDE_PROJECT_DIR=$r` or `cd "$r"` (lines 56, 133).
- `tests/product-loop.test.sh:23,30,31,244`: it writes `$PRODUCT/AGENTS.md`, `$PROJECT/AGENTS.md` and `$WEB/AGENTS.md` under `$W`.

E7 Plugins: `git diff --stat origin/main -- plugins/` → empty. Versions: `glab` "0.15.0", `memory-sync` "0.1.0".

E8 The registry has 37 entries. Rule: inside the "Known cases:" run (origin/main AGENTS.md, whitespace joined), an entry ends at a `;` that is outside backticks and parentheses and follows either a `)` or the severity entry's last span ``and `plugins/glab/agents/product-analyzer.md` ``. The script that splits paragraph from file list (last top-level parenthetical) printed `37`, and per entry its paragraph and list lengths: all 37 have a non-empty paragraph and 36 have a list, the exception being `14 392 0`. Entry starts: 1 round caps … 14 severity, 15 every round a new agent, 16 mapping files, 17 handoff file, 18 context hook, 19 review round after the first, 20 plan lifecycle … 37 level boundary. The run has 133 unique backtick spans and 11 italic names; `*Gates*` is the only self-reference.

E9 The base test helpers in `tests/context-size.test.sh`: `pass=0 fail=0 n=0` (line 15), `reason=''` (line 16), `bad()` (line 20), `done_case()` (lines 37–47); the end is lines 346–351. `bash -c 'type -t grep'` → `file`, so a child bash does not inherit the interactive `grep` function. The script still uses `command grep`, as the old block did.

E10 Prototype `/tmp/claude-1001/-home-pvhv-projects-skills/1028ab57-733a-4f6f-a77a-e2fb1d2fb2c6/scratchpad/gates.sh`:
- it has `cd /home/pvhv/projects/skills` and `export TMPDIR=/data/tmp/claude` hard-coded;
- `grep -c … | tr '\n' ' '; echo "rc=$?"` prints `tr`'s rc;
- no expected value is compared;
- the `:?` aborts after the first checks have already printed;
- it has no exit status.

## Steps

**Before**
1. On branch `slim-agents-md`, run `export TMPDIR=/data/tmp/claude` and confirm `git diff --quiet origin/main -- AGENTS.md README.md plugins/ tests/; echo $?` prints `0`.
2. Post-condition P4 reads the old registry from `git show origin/main:AGENTS.md`; nothing else needs saving.

**Processing**
3. Create `/home/pvhv/projects/skills/tests/gates.sh` with `#!/usr/bin/env bash`, `set -uo pipefail` and `chmod +x`. Header comment: what it runs, how to call it (`bash tests/gates.sh`, no arguments, from anywhere), that it changes no file, and its exit codes 0, 1 and 2.
   - `cd "$(dirname "$0")/.." || exit 2`.
   - Preflight per D3.
   - Then `W`, the trap and `cfg` per D4.
   - Then the counters and helpers, copied from `tests/context-size.test.sh`: lines 15–16 (`pass=0 fail=0 n=0`, `reason=''`), line 20 (`bad()`) and lines 37–47 (`done_case()`).
4. Put the expected values at the top as arrays, taken from E3 and E4 (which equal AGENTS.md):
   - `SCRIPTS` (10 paths: the 9 in today's order, then `tests/gates.sh`);
   - `TESTS` (the 5 test command lines from block 1);
   - `GLAB_SKILLS` (25), `GLAB_AGENTS` (9), `GLAB_HOOKS='Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)'`;
   - `MS_SKILLS=(sync-memory)`, an empty `MS_AGENTS` with count 0 and line `Agents (0)`, `MS_HOOKS='Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)'`;
   - `MARKET=('glab = glab' 'memory-sync = memory-sync')`, `MODEL_LINES` (9), `SKILL_LINES` (18).
5. Write G1–G31 in the order of D1. Each check runs the same command as the old block, with `grep` written as `command grep`, captures stdout and rc, compares, and calls `done_case`. The reasons move into comments, each containing the quoted phrase verbatim (P6 checks them):
   - G1–G10: "lost its execute bit" (a hook script that has lost its execute bit passes every other gate and then fails when the hook runs). "a syntax error printed" (`&&` makes the rc the syntax check's; with `;` a syntax error printed `rc=0`). The file list includes this script, which is checked here and never executed.
   - G11: green is rc 0 with no findings.
   - G12–G16: the tests create their work directories under `$TMPDIR`. Each test is green when every line is `ok` and its last line is `PASS n/n`. On FAIL, the reason carries the first non-ok line.
   - Preflight and before G17: "as though the gates had run". "writes into its config directory even for" (`plugin validate`; without the variable that directory is the live `~/.claude`). "unset nothing runs" (with `TMPDIR` unset nothing runs). "never exported empty". "aborts only its own line": the history — pasted into an interactive shell, the old block's `:?` aborted only its own line, so a script stops instead.
   - G20/G21/G23/G24: "directory read order, which is not stable".
   - G22/G25: "prints that suffix, and it is expected".
   - G26: "compare a marketplace entry with the plugin it points at"; "passes with a wrong name" (and with a directory that does not exist).
   - G27: expected `:0` per `hooks.json`, then rc 1. "exits 1 when it counts nothing" (and nothing is green). "in a hook command passes validation" (a `${user_config.…}` there fails when the hook runs).
   - G28: a count ≥1 for each of the three files, rc 0. "Read the counts, not the" rc; "exits 0 as soon as one file matches". The hedge on `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` — documented as the override for the `SessionEnd` budget, "not yet shown to cover a hook" that a plugin provides — and "no other gate notices" when the script comment, the skill or the README starts stating it as fact.
   - G29: "passes an unknown model value" (and `plugin details` shows none, so nothing else catches a typo).
   - G30: the three MISSING conditions (no `skills/<name>/SKILL.md` in that plugin; no frontmatter line `name: <name>` — Claude Code names a plugin skill by that line, "not by its directory"; another plugin's prefix). `--strict` passes a `skills:` entry that names no skill, and `plugin details` "does not show the lists".
   - G31: no line and rc 1. A frontmatter `name:` that "carries the plugin prefix" passes validation and `plugin details`, and nothing else catches it.
6. End `tests/gates.sh` as `tests/context-size.test.sh:346-351` ends: `PASS $pass/$n`, or `FAIL $fail/$n` and `exit 1`.
7. Create `/home/pvhv/projects/skills/docs/one-fact.md` per D9 with the 37 entries in E8 order, applying exactly the retargets of D10.
8. Edit `/home/pvhv/projects/skills/AGENTS.md`:
   - *Layout*: the `tests/` item gains "`tests/gates.sh`, which runs every gate". The repo-owned list gains `docs/one-fact.md` ("the *One fact* registry").
   - *Gates*: replace the whole section, up to but not including the paragraph "The Markdown files have no gate…" (which stays), with this text:
     > The tests create their work directories under `$TMPDIR`. Export `TMPDIR` to the temp directory your host file names, run `bash tests/gates.sh`, and paste what it prints. Green is its last line, `PASS n/n`, with exit 0; each `FAIL` line names the check and why. Each check's expected value and the reason for it are in the script's comments. `claude` is the Claude Code CLI: `claude` on `PATH`, or `CLAUDE_BIN` set to the path your host file names; without one the script stops before any check. **Every `claude` command run in this repo has `CLAUDE_CONFIG_DIR` set to a new, empty directory under that temp directory.** The CLI writes into its config directory even for `plugin validate`, and without the variable that directory is the live `~/.claude`.
   - *Rules*: replace the *One fact* bullet with the D11 text. Every other bullet stays byte-for-byte.
9. Edit `/home/pvhv/projects/skills/README.md` per D14. Line 373, `tests/` row: add "and `tests/gates.sh`, every gate with its expected result". Add the row `| docs/one-fact.md | The *One fact, one value* registry: each fact more than one file states, and the files that state it |` after the `docs/specs/` row.

**After**
10. Run Post-conditions P1–P9 and paste their output into the review. List coverage per AGENTS.md *Tests*:
    - checks with a mutation: G4 (M2), G10 (M4), G29 (M1), G30 (M3), and the preflight (M5, M6);
    - checks with no mutation: G1–G3, G5–G9, G11–G28 and G31. This is accepted: they are direct string, count or rc comparisons of the same kind, and P2 shows each of them green on the real tree.

## Post-conditions

Run from `/home/pvhv/projects/skills` with `export TMPDIR=/data/tmp/claude`.

- P1 `wc -c < AGENTS.md` prints a number ≤ 8800. `/usr/bin/grep -c '^glab-level:' AGENTS.md` prints `0`.
- P2 `ls -d "$TMPDIR"/gates.* 2>/dev/null | wc -l; bash tests/gates.sh; echo "rc=$?"; ls -d "$TMPDIR"/gates.* 2>/dev/null | wc -l` prints:
  - `0`;
  - 31 lines `ok G1 …` to `ok G31 …`;
  - `PASS 31/31`;
  - `rc=0`;
  - `0`.
- P3 `bash -n tests/gates.sh && test -x tests/gates.sh && shellcheck tests/gates.sh; echo rc=$?` prints `rc=0`.
- P4 Every entry is present, verbatim, in order. Run:
  ```
  python3 -I - <<'EOF'
  import re,subprocess
  t=subprocess.run(["git","show","origin/main:AGENTS.md"],capture_output=True,text=True).stdout
  x=" ".join(t[t.index("Known cases:")+12:t.index("- **Comments and recorded")].split()).rstrip(".")
  for a,b in [("the *Gates* section of this file","`tests/gates.sh`"),
              ("the model gate in this file's *Gates*","the model check (G29) in `tests/gates.sh`"),
              ("the skills gate in this file's *Gates*","the skills check (G30) in `tests/gates.sh`"),
              ("this file's `plan/` rule","`AGENTS.md`'s `plan/` rule")]:
      assert a in x, a; x=x.replace(a,b)
  E=[];d=0;cur="";bt=False
  for c in x:
      if c=="`": bt=not bt
      if not bt:
          d+=(c=="(")-(c==")")
          if c==";" and d==0 and (cur.rstrip().endswith(")") or cur.rstrip().endswith("and `plugins/glab/agents/product-analyzer.md`")):
              E.append(cur.strip()); cur=""; continue
      cur+=c
  E.append(cur.strip())
  def split(e):
      if not e.endswith(")"): return e,""
      d=0;bt=False
      for i in range(len(e)-1,-1,-1):
          if e[i]=="`": bt=not bt
          if bt: continue
          d+=(e[i]==")")-(e[i]=="(")
          if d==0: return e[:i].rstrip(), e[i:]
  S=[" ".join(s.split()) for s in re.split(r"(?m)^## ",open("docs/one-fact.md").read())[1:]]
  bad=0
  for i,(e,s) in enumerate(zip(E,S),1):
      p,l=split(e); w=set(re.findall(r"[A-Za-z0-9]+",s))
      miss=[m for m in re.findall(r"`[^`]+`|\*[A-Za-z][^*`]*\*",l) if m not in s]+[m for m in re.findall(r"[A-Za-z0-9]+",l) if m not in w]
      if p not in s or miss: bad+=1; print("BAD",i,"paragraph" if p not in s else miss[:5])
  print(len(E),len(S),bad)
  EOF
  ```
  It prints exactly `37 37 0`. The paragraph check catches any changed or dropped entry text; the span and word checks catch a dropped file.

  Then each italic name, with its asterisks: `for n in '*Dispatching the planner*' '*Levels*' '*Re-checks*' '*Re-reviews*' '*Report*' '*Round caps*' '*The handoff line*' '*The level boundary*' '*The shared store*' '*Your skills — this level only*'; do printf '%s %s\n' "$(/usr/bin/grep -cF -- "$n" docs/one-fact.md)" "$n"; done` prints a count ≥1 on each of the 10 lines.
- P5 Retargets: `/usr/bin/grep -c 'tests/gates.sh' docs/one-fact.md` prints `5` (entries #6, #7, #10, #11, #12, one bullet each). Running `/usr/bin/grep -rnE --exclude=gates.sh "Gates\* section of this file|this file's \*Gates\*|this file's .plan/. rule|Known cases:|Validation passed|Skills \(25\)" AGENTS.md README.md docs/one-fact.md tests host.example.md plugins .claude-plugin; echo rc=$?` prints only `rc=1`. `tests/gates.sh` is excluded because it holds the expected `Validation passed` and `Skills (25)` values.
- P6 Reasons kept. The comments are matched whitespace-joined, so a phrase wrapped across two comment lines still matches. Run:
  ```
  c=$(/usr/bin/grep -o '#.*' tests/gates.sh | sed 's/^#[[:space:]]*//' | tr '\n' ' ' | tr -s ' ')
  for p in 'lost its execute bit' 'a syntax error printed' 'as though the gates had run' 'writes into its config directory even for' 'unset nothing runs' 'never exported empty' 'aborts only its own line' 'directory read order, which is not stable' 'prints that suffix, and it is expected' 'compare a marketplace entry with the plugin it points at' 'passes with a wrong name' 'exits 1 when it counts nothing' 'in a hook command passes validation' 'Read the counts, not the' 'exits 0 as soon as one file matches' 'not yet shown to cover a hook' 'no other gate notices' 'passes an unknown model value' 'not by its directory' 'does not show the lists' 'carries the plugin prefix'; do case "$c" in *"$p"*) ;; *) echo "MISSING: $p" ;; esac; done; echo checked
  ```
  It prints only `checked`. Each phrase is reason text, not a value or a command.
- P7 `git diff --quiet origin/main -- plugins/ .claude-plugin/ docs/specs/; echo $?` prints `0`. `git status --short -uall` lists only:
  - `M AGENTS.md`, `M README.md`;
  - `?? docs/one-fact.md`, `?? tests/gates.sh`;
  - `?? plan/manager-flow-notes.md` (pre-existing, untouched);
  - `?? plan/slim-agents-md/*` lines.
- P8 Mutations. Each runs in a fresh copy: `D=$(mktemp -d "$TMPDIR/gates-mut.XXXXXX"); git ls-files -co --exclude-standard -z | tar --null -T - -cf - | tar -x -C "$D"`. Apply one mutation, run `bash "$D/tests/gates.sh"; echo rc=$?`, then `rm -rf "${D:?}"` (the user may need to approve that rm).
  - M1 `sed -i '/^model: /d' "$D/plugins/glab/agents/committer.md"` → `FAIL G29 …`, last line `FAIL 1/31` or `FAIL 2/31` (the second being G17, if `validate --strict` rejects an agent with no `model:`; UNVERIFIED), `rc=1`.
  - M2 `chmod -x "$D/plugins/glab/scripts/plan-gate.sh"` → `FAIL G4 …`, `FAIL 1/31`, `rc=1`. The tests call it via `bash`, as `tests/product-loop.test.sh:84` does.
  - M3 `sed -i 's/^  - glab:comments$/  - glab:coments/' "$D/plugins/glab/agents/project-developer.md"` → `FAIL G30 …` naming `…:glab:coments MISSING`, `rc=1`.
  - M4 `chmod -x "$D/tests/gates.sh"` → `FAIL G10 …`, `FAIL 1/31`, `rc=1` (the self-check works without recursion).
  - M5 `CLAUDE_BIN=/nonexistent bash "$D/tests/gates.sh"; echo rc=$?` → stdout empty, one stderr line `gates.sh: no Claude Code CLI found - set CLAUDE_BIN to the path your host file names`, `rc=2`.
  - M6 `env -u TMPDIR bash "$D/tests/gates.sh"; echo rc=$?` → stdout empty, one stderr line `gates.sh: TMPDIR unset - export it to the temp directory your host file names`, `rc=2`, and nothing created.
  - After all six: `ls -d "$TMPDIR"/gates.* "$TMPDIR"/gates-mut.* 2>/dev/null | wc -l` prints `0`.
- P9 The baseline is reproduced: in P2, G20 states Skills 25 and G21 Agents 9, matching E3, and G29/G30 hold 9 and 18 lines, matching E4.

## Not done

- AGENTS.md is not brought to 6 KB (D13, D17). The hook-contract paragraph and the `plan/` rule stay verbatim (D12).
- `docs/specs/marketplace.md` (*The gates*, *What each plugin holds*, the One-fact records) and the other specs are not updated. The record of this slug does that.
- The `plan/` rule is not rewritten (the queued docs-lifecycle slug).
- No plugin version bump: no payload file changes (E7).
- The five tests' own case counts are not pinned in `tests/gates.sh` (D6).
- UNVERIFIED: the outcomes of M1–M6 and P4 on the new files — those files do not exist yet. P4's splitter was run only against the origin/main registry (E8).
- UNVERIFIED: whether the CLI's Hooks order is stable — taken as stable because the old gate compared that line exactly and E3 matches it.

### Critical Files for Implementation
- /home/pvhv/projects/skills/AGENTS.md
- /home/pvhv/projects/skills/tests/gates.sh (new)
- /home/pvhv/projects/skills/docs/one-fact.md (new)
- /home/pvhv/projects/skills/tests/context-size.test.sh (the style to copy: lines 15–16, 20, 37–47, 346–351)
- /home/pvhv/projects/skills/README.md (lines 369–375)
