# Result — feature-external-developer (slice P5, P6, P7)

AGENTS.md read from disk (it differs from older cached copies: the *One fact*
list carries the Codex entries at L221-L226 of the base). Skills carried:
`glab:security`, `glab:comments`.

## Stages

- **P5 — `plugins/glab/skills/external-agents/SKILL.md`: done.**
  - L3 description: read-only except a Codex developer; Rule 5 "external reviewer or developer".
  - L15-L18 opening: Codex sandbox "read-only for every role but a developer's"; "There is no external developer." replaced by the plan's sentence, verbatim, on one line (L18).
  - L29-L31 *When this applies*: the third bullet, verbatim.
  - L73-L84 once-per-session notice: "Its commands change no file, unless it is a developer"; then "For a developer, also:" and the README's P7 paragraph in the same words.
  - L115-L121 *Start*: the developer start example with `--role developer`.
  - L154-L160 *Reading what comes back*: the `changed:` / `git:` lines, on exits 0, 6, 7, 12.
  - L175 exit 12 row: a developer's `workspace-write [workdir]` sandbox; show the `changed:`/`git:` lines.
  - L227-L254 new `## The developer role` after *The reviewer role*: brief (slug, step ids, chat decisions; no file boundary, D7), no `result.md` (D6), gates may say "not run here", what to do on non-zero / `git: changed` (D8), one `send` for missing fields, stop it.
  - L295 *Where it runs*; L303-L305 *What it cannot do* scoped "unless it is a developer"; L306-L316 two new bullets: the developer's sandbox (D2) and the change report (D4) with what it does not see (ignored files, Codex's own writes outside its command sandbox) and "reported after the turn, not prevented by the script".
  - L338-L340 *What is checked*: `sandbox: workspace-write [workdir]` for a developer (D3), on one line.
- **P6 — `plugins/glab/skills/manager/SKILL.md`: done.**
  - L120 Rule 5: the external developer, Codex only, "develop on Codex" / "develop on Codex, <id>"; "An external developer is Codex only: OpenCode cannot change files."
  - L123 *Carry it*: run `/glab:develop`'s dispatch through `glab:external-agents` with `--role developer`; one agent; re-dispatch is a new agent; unavailable / timeout / failure / 12 → stop, tell the user, revert/commit/re-run nothing.
  - L125 *These two roles only*: the plan's sentence, verbatim.
  - L127 the record line `- model: glab:developer codex, effort <level> (CLAUDE_CODE_EFFORT_LEVEL | the user's answer: "<words>"), for <scope> — …`, with `codex:<id>`. The plan writes the parenthesis as `(…)`; it is spelled out as in the Codex reviewer's line, since the plan says "the reviewer's with `glab:developer`".
  - L128 the handoff line `slug · develop · model codex:<model> · round 1/1 · BUILT`.
  - L140 the table row, verbatim.
  - L155 Rule 6 *It changes nothing*: the exception clause, and the rest of the line now says "under Codex's own sandbox — read-only, or workspace-write for a developer —" (Stage 1b suggestion).
  - L157 Rule 6: `except the developer and the reviewer under Rule 5`.
- **P6 — `plugins/glab/commands/develop.md`: done.**
  - L20 *Decide the split*: one sentence (D7).
  - L43 *Dispatch*: the bullet, verbatim, one line.
  - L51-L57 *When the agents return*: exit and `git:` line first (D8), read the whole change (U3), write `result.md` from its reply (D6), then the gates. L14 (the four ask-conditions) untouched.
- **P7 — `README.md`: done.**
  - L52-L55 exit 12: "any other sandbox than the one it asked for — `read-only`, or `workspace-write [workdir]` for a developer —" (12's widened meaning, as P7 directs).
  - L77-L79 "Its commands change no file, unless it is a developer".
  - L84-L90 the new paragraph, verbatim; each searched phrase on one line.
  - L102-L106 the user-approved fix: Codex agents tested "against a stub, offline against the real `codex`, and in one live probe on 2026-10-18 (`docs/specs/external-agents.md`, *Live runs*): one read-only agent on Codex's default model answered a task and a `send` on this repository." Source: `git show 30f2c80:plan/feature-codex-agent/probe-codex-l1.md`. Then P7's sentence, verbatim, on one line.
  - `Not yet shown: any reply from a DeepSeek model` untouched (count 1).
- **P7 — `AGENTS.md`: done.** L162-L164 the manual model rule gains "(an external one: the reviewer on either backend, the developer on Codex only)"; L224-L226 the Codex sandbox check entry with E73; L229-L241 the first-message entry extended, and the two new entries. Each searched phrase on a line of its own.
- **P7 — `plugins/glab/.claude-plugin/plugin.json`: done.** L3 `"version": "0.7.0"`.

## Blocked

None.

## Unplanned changes

- `plugins/glab/skills/external-agents/SKILL.md` L209: "Every agent, of either role" → "of any role". Forced by P3/P5: there are now three roles, and the sentence is true of the developer too (P3's host text and both skills).
- Line rewraps where an inserted clause made a line long (README L77-L80, skill L73-L76 and L303-L305). Wording unchanged.

## Tests

No test case: P5-P7 are Markdown, which has no gate (`AGENTS.md` *Gates*; plan's coverage table: "P5-P7 Markdown | no gate; the searches in *After*"). Coverage is the searches below, all green for this slice.

## Gates

Plugin block of `AGENTS.md` *Gates*, `TMPDIR=/data/tmp/claude`, `CLAUDE_BIN=<the CLI path the host file names>`, throwaway `CLAUDE_CONFIG_DIR` created and removed by the block:

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

Green as `AGENTS.md` defines it.

Plan *After* step 2 searches (run before the last README rewrap, which touched no searched phrase; the README counts were re-run after it: DeepSeek 1, the three phrases 3, `workspace-write [workdir]` 2):

    --1 'There is no external developer'            → no line, rc=1
    --2 'Only the reviewer can be external'          → no line, rc=1
    --3 'workspace-write [workdir]'
        plugins/glab/scripts/external-agent.sh:3
        tests/external-agent.test.sh:0               ← P4, the other slice, in progress
        plugins/glab/skills/external-agents/SKILL.md:3
        README.md:2
        AGENTS.md:1
    --4 '--role developer' develop.md                → 1
    --5 '| an external developer |'                  → 1
    --6 'except the developer and the reviewer under Rule 5' → 1
    --7 -x '## The developer role'                   → 1
    --8 README three phrases                         → 3
    --9 AGENTS.md three phrases                      → 3
    --10 -x '## Developer, before the contract' default.md → 0   ← P3, the other slice, in progress
         'never to change anything' default.md       → 1
    --11 "version"                                   → 3:  "version": "0.7.0",

Every search for a file in this slice gives its green answer. The two that do not (`tests/external-agent.test.sh`, `profiles/default.md`) belong to P3/P4.

The four shell gates were not run: they cover the script and test the other developer is editing now, and none of my files is in them. UNVERIFIED for this tree: shell gates and `PASS 77/77`; they belong to the P1-P4 slice's result.

## Flags for the manager

- **README L106 (and the skill's notice, which repeats README wording only for P7's paragraph):** "its sandbox offline with `codex sandbox`" is written as the plan says, but becomes true only when Stage 4 (M1-M4) has run. Confirm after Stage 4, or reword it if M1-M4 do not run or fail.
- **README L102-L105:** cites `docs/specs/external-agents.md` *Live runs* for L1. That section holds L1 only in the uncommitted working copy of the spec (L805 "Codex agents have run against a real model once"), which is not part of this slice; if the spec's L1 entry does not land, the citation should point at `plan/feature-codex-agent/probe-codex-l1.md` instead.

## Follow-ups

Not written to `follow-ups.md`: the dispatch limits me to this result file under `plan/`. Out of scope, for the manager to place:

1. `README.md` L9 (the plugin table) still says `external-agent.sh` "runs read-only external agents — … or Codex in its own read-only sandbox". Not named in P7; false for a developer after this change.
2. `plugins/glab/commands/develop.md` L2 (description) and L8 say the work is done "through glab:developer agents" / "the `glab:developer` agent does". Not named in P6; an external developer is now the exception.
3. `glab:manager` Rule 5 *Carry it* still lists only external reviewers among the names to ask about ("or whether they meant an external reviewer — `opencode:…`, `codex`, or `codex:<id>`"). Not named in P6.
4. `glab:manager` L145 (*Check what comes back*) describes only the external reviewer's one correction. The external developer's one `send` for missing report fields (D7) is stated in the skill's *The developer role* only. Not named in P6.
5. The skill's *Its network* bullet states the read-only measurement only; a developer's network being off is asked for (D2) and measured at Stage 4 M4. Not named in P5.

## Not done

- P1-P4 (script, test, `profiles/default.md`): the other developer's slice.
- `docs/specs/`: record stage.
- Plan claim not verified by me: the exact header string `workspace-write [workdir]` (D3, Stage 4 M5).

## Round 2 (review r1)

Inputs read from disk: `review-r1.md`, the tail of `questions.md` (*Review round 1*: one fix round, approved by the user), `plan.md` revision 3 (P5-P7 *Revision 3* blocks), `integration.md` M2-M5. File boundary unchanged.

### Stages

- **X1, the manager's instruction: done.** The command is `git diff --no-ext-diff --no-textconv --ignore-submodules=all` (review-r1 X1; plan R3.5 leaves it as a placeholder, ⟨R3.5 command⟩).
  - Skill L261-L267 (*The developer role*, "What you do with what comes back"): read the change from the `changed:`/`git:` lines; inspect it with that command and by reading each untracked file named; never a plain `git status` (filter, fsmonitor); a nested repository stops the work, as `git: changed` does.
  - `develop.md` L54: the same.
  - Both earlier `git status` instructions are gone. `command grep -n -F 'git status'` now finds only the "never" sentence (skill L266, develop.md L54) and the guarantee "It runs no `git status`" (skill L336).
- **X6: done.** Skill L345-L348 *Its network*: under workspace-write, TCP was refused at `socket()` and a Unix-domain socket by path at `connect()`, and `/tmp`, `$TMPDIR` and every path outside the repository were read-only (integration.md M4, M2). I left out a plan path, as the read-only sentence beside it does.
- **T1: done.** README L9 uses the reviewer's wording. README L72 and skill L67 both read "(read-only, or workspace-write for a developer)". The Codex data note is checked identical in both files, and so is the developer paragraph after it (whitespace-normalised comparison: `codex note identical: True`, `developer note identical: True`).
- **T2: done.** The phrase is "in the model line for the reviewer or the developer", at skill L91-L92 and manager L156.
- **T5, the wording: done.** The script's round-2 header (L26-L36, L117-L135, as of 21:41) was read and matched:
  - Skill L156-L166: the `changed: <code> <path>` form with `??`, ` D`, ` M`, `--`; `changed: none`; `changed: unreadable`. `git: changed` covers HEAD, refs, config (includes too), hooks, `info/`, the `core.hooksPath` directory, and any `.git` below the top.
  - Skill L329-L341: the change-report guarantee. It names ls-files-based records (no `git status`, filter, fsmonitor or hook), the 16 MiB cap, and the `--timeout` bound of at most 300 s. The ignored-file exception is the `core.hooksPath` directory.
  - README L88-L92 and skill notice L84-L88, identical: "A change to .git is reported after each turn — a commit, a ref, the config, a hook, `info/`, the `core.hooksPath` directory, or a new `.git` below the top — …. A write to an ignored file is not reported, except in the `core.hooksPath` directory." The searched phrase `A change to .git is reported` is kept.
- **The refusals: done.** These are R3.1 and R3.2, as the script header states them. They go in the skill because the exit codes are a *One fact* item.
  - Skill exit row 2 (L173).
  - Skill exit row 4 (L175).
  - Skill *What stops it before a turn* (L249-L255): 2 at start, 4 before a later turn, for a state root inside the repository or a `.git` other than the top's.
- **Advisories: done.**
  - Manager L150, Rule 6: "for read-only work, except a Codex developer under Rule 5".
  - Manager L123: the external developer is offered as `codex` or `codex:<id>`.
- **develop.md L2/L8: done.** The description and the orchestrator sentence name the external Codex developer through `glab:external-agents`.
- **AGENTS.md *One fact* (R3.6, as the coordinator assigned): done.**
  - The change-report entry adds E78, E80 and E82.
  - New entry: a developer refused when the state root is inside the repository or the work tree holds another `.git`, 2 at start and 4 before a later turn (script header, E79, E81, the skill).
  - The case ids are from the titles in `tests/external-agent.test.sh` at 21:30.

### Not done, and why

- **README L106 "The developer role has been tested against a stub, and its sandbox offline with `codex sandbox`."**
  - It is now true: integration.md M1-M4 passed.
  - It is left verbatim: plan P7 gives it verbatim, and revision 3 does not change it.
  - So no integration.md citation is added. The plan does not allow one, and payload-side text does not cite `plan/` paths, which do not outlive the record.

### Unplanned changes

None beyond rewraps that keep searched phrases on one line (skill L66-L67).

### Unverified

- UNVERIFIED: that `git diff --no-ext-diff --no-textconv --ignore-submodules=all` runs no filter configured in the top repository. It is the reviewer's command. Measured M3 found `.git/config` unwritable by the developer's commands, so the agent cannot add a filter there; a filter the user already configured can still run. No test here.
- The script slice's round 2 finished after my check: `result-p1-p4.md` got its round-2 section at 21:44. `external-agent.sh` was last modified at 21:41:50, the version I matched. The md5 of header lines L26-L36 was the same before and after: `4558eb17…`. So the wording matches the script's final round-2 header.

### Gates (round 2)

The plugin block from `AGENTS.md`, with the same CLAUDE_BIN, TMPDIR and throwaway CLAUDE_CONFIG_DIR as before, printed:
- three `✔ Validation passed`;
- glab `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`;
- memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
- `glab = glab` and `memory-sync = memory-sync`;
- `:0` `:0` `rc=1`; then `1` `1` `1` `rc=0`; then `1` `rc=0`; then `rc=1`.

That is green.

*After* searches:
- §2: no line ×2; `workspace-write [workdir]` 3/5/3/2/1; then 1, 1, 1, 1, 3, 3; the default.md heading 1, with `never to change anything` 1; `"version": "0.7.0"`.
- §2b: `status --porcelain` 0; stdin-paths/hooksPath 3; `read-only except for a developer` 1; `(read-only, or workspace-write for a developer)` README 1 and skill 1, re-run after the rewrap; `in the model line for the reviewer or the developer` manager 1 and skill 1; the inspection command, skill 1 and develop.md 1.

Shell gates: not run by me (the script slice, still in progress).

## Round 2b (alignment with result-p1-p4.md *Round 2*)

Fixed against "Doc text these changes make false" in `result-p1-p4.md`:

- **`changed:` codes**: these were already done in round 2 (skill L156-L168: `??`, ` D`, ` M`, `--`). No file of mine still says the report comes from `git status`. Searching for `git status` finds only the "never run a plain `git status`" lines and "It runs no `git status`".
- **`changed: unreadable`**: the skill now says it always comes with `git: changed`, within the turn's `--timeout`, 300 s at most.
- **Refusals (2 at start, 4 before a later turn)**: they are now in:
  - the skill's *Start* step, after the developer example;
  - the skill's exit rows 2 and 4, and *What stops it before a turn* (both from round 2);
  - `glab:manager` Rule 5 *Carry it*, as a stop-and-tell-the-user condition;
  - README, in the Codex requirements paragraph after the exit-12 sentence.
- **`git: changed` scope**: README and the skill notice already listed the config, `info/`, the `core.hooksPath` directory and a new nested `.git`. The ignored-file caveat now reads "except in the `core.hooksPath` directory or in a file the git config includes". It changed in README, the skill notice and the skill's change-report guarantee. The README and skill data notes are still identical after whitespace normalisation (`identical: True` ×2).
- **16 MiB**: the skill's guarantee already says it, from round 2.
- **`find`**: README's Codex requirements add "for a developer, a `find` that takes `-files0-from` (GNU findutils 4.9 or later, or bfs)". The skill states no tools list, so it is unchanged.
- **AGENTS.md *One fact***: the change report entry now names E74, E75 and E78-E82. The refusal entry names E79 and E81.

Not added: `realpath -e`, which result-p1-p4 also lists as a new requirement. The dispatch named `find` only. `realpath -e` is GNU coreutils, which README already requires for `memory-sync` but not for Codex. This is left for the manager to decide.

Plugin gates, same block and setup as round 2:
- three `✔ Validation passed`;
- glab 15/5/1 SessionStart; memory-sync 1/0/4;
- `glab = glab`, `memory-sync = memory-sync`;
- `:0` `:0` `rc=1`; then `1` `1` `1` `rc=0`; then `1` `rc=0`; then `rc=1`.

That is green. Searches re-run:
- `workspace-write [workdir]`: skill 3, README 2, AGENTS 1;
- README three phrases 3; AGENTS three phrases 3;
- `(read-only, or workspace-write for a developer)`: 1 and 1;
- `in the model line for the reviewer or the developer`: 1 and 1;
- the inspection command: 1 and 1;
- `read-only except for a developer`: 1;
- `-files0-from` in README: 1.

## Round 3 (review r2)

Inputs read from disk:
- `review-r2.md`;
- `result-p1-p4.md` *Round 3 (review r2)*, finished at 22:07;
- the script header at `external-agent.sh` L26-L37, as of 21:59.

The file boundary is unchanged.

- **R2-1: done.** The `git diff --no-ext-diff …` line is gone from both files (`--no-ext-diff` count 0 and 0).
  - Skill L278-L287 (*The developer role*) and `develop.md` L54: a nested repository stops the work.
  - The manager inspects only on exit 0 with `git: unchanged` and when no nested repository was refused.
  - For each tracked path a `changed:` line names, it runs `git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u - <path>` (`cat-file` applies no filter). It reads untracked files directly.
  - Both files say plainly that `git status` and `git diff` can each run a clean filter or an fsmonitor, so the manager runs neither on that tree before the check.
- **R2-2: done.**
  - The skill's Codex prerequisites (L56-L59) add, for a developer, a `find` that takes `-files0-from` (GNU findutils 4.9 or later, or bfs) and a `realpath` that takes `-e` (GNU coreutils). `check` and a developer `start` exit 4 when `find` lacks `-files0-from`, matching `need_find`.
  - README L49-L52: the same requirement and exit 4. README already named `realpath -e` when I started this round. Someone else had edited README after round 2b; I adjusted my edit to their text and kept it.
- **R2-3: done.** The data note in README L98-L102 and in the skill notice L90-L94 adds: "The agent can make a path ignored itself, with a `.gitignore` of its own: a new ignored entry is reported by name, but not what is written in it." The skill's change-report guarantee (L352-L360) says it records ignored names and sees an ignored entry made or removed.
- **R2-5: done, matched to the header.** The codes are `??` untracked and `!!` ignored (by name only), as in the header, plus the two below:
  - ` D`, tracked and missing;
  - `--`, "a regular file of at most 16 MiB as the index has it (its hash and executable bit match its one stage-0 index entry) or a path no longer listed";
  - ` M`, "every other tracked path; a link or a larger file that changed is ` M`, whatever it holds".
  - The text is in the skill at L171-L181 and in README at L103-L108, a new short paragraph after the developer note, outside the mirrored data note.
  - The dispatch's exact sentence is split by the parenthesis: I used the header's precise conditions there. The search `a link or a larger file that` gives 1 in each file.
- **R2-6: done.** `AGENTS.md` L241-L244: the refusal entry now names `README.md` and `glab:manager` Rule 5. The change report entry is now E74, E75, E78-E84, adding E83 and E84 as the script slice reported.
- **Advisories: done.**
  - Skill L132 now says "no agent is created" (`nothing is created` count 0).
  - A `.git` inside an ignored dependency directory is named as the likely cause of exit 2, in the skill's *What stops it before a turn* and in README L60-L62.

Data notes, after whitespace normalisation: the Codex note is identical in README and the skill, and so is the developer note (`identical: True` ×2).

Plugin gates, same block and setup as before:
- three `✔ Validation passed`;
- glab `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`; memory-sync 1/0/4;
- `glab = glab`, `memory-sync = memory-sync`;
- `:0` `:0` `rc=1`; then `1` `1` `1` `rc=0`; then `1` `rc=0`; then `rc=1`.

That is green. Earlier searches re-run, each unchanged:
- `workspace-write [workdir]`: skill 3, README 2, AGENTS 1;
- README three phrases 3; AGENTS three phrases 3;
- the data-note phrase: 1 and 1;
- the T2 phrase: 1 and 1;
- `read-only except for a developer`: 1.

Background processes: none of mine. My one earlier background wait (round 2) completed with exit 0. My foreground waits ran under `timeout` and have exited. One `until command grep … result-p5-p7.md` loop is still running under this uid, pid 4076278, parent 3399507. It waits on this file, so it is the caller's, not mine; I left it alone.

## Scope cut

These are the changes the user approved in review round 3 (`questions.md` *Review round 3*). Nothing else changed.
- "`check` and" was removed from README L51 and skill L58: only a developer `start` exits 4 on a `find` without `-files0-from`.
- The skill (*The developer role*) and `develop.md` L54 now use `diff -u -- - <path>`. The manager directly reads each `??` and `!!` path that is a regular file. It never opens a link or a path that is not a regular file: it shows a link with `readlink` and anything else with `ls -l`.
- Skill L64: exit 4 with `<tool> not found` is a missing tool.

Plugin gates were green: 3× `✔ Validation passed`, glab 15/5/1 SessionStart, memory-sync 1/0/4, names match, `:0 :0 rc=1`, `1 1 1 rc=0`, `1 rc=0`, `rc=1`. The data notes are still identical (×2). No background process of mine is running.
