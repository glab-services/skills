Tier: normal — prose slimming of two shared skills, one new shared skill, and a hook that reads one id it validates before use; no schema, stored or wire format, secret, money or authorization code (`../index.md` D3).

# 02-shared-rules — the shared rules slimmed, and one handoff file per session

Sub-plan of `flow-project-level` (`../master.md` v2, approved, hashed in `../master.sha256`). Its `index.md` line: `02-shared-rules · goals G4, G5, G6 · depends 01-rename · tier normal`. Built on `1bbf4bc` (01-rename). It resolves F6, F8 (all but the manager's sentence), F9 (the shared half), F10, F22, F25 and F26 (`session-rules`' and `bootstrap`'s descriptions), and G6 by D21–D30 (`../index.md`). It leaves to 03, untouched in their current words: `session-rules:18` (*Where a record line goes*), `:124` (*Without subagent dispatch*), and the clause "`glab:project-manager` Rule 4 does not apply to the model choice" of `:121` (F17, F19); and the manager's halves of F8, F9 and F26.

## Decisions

- W1 — Section targets below sum to 13102 bytes for `session-rules`, 210 under the 13312 cap, because the exact G6 bullets (1373, plan check round 1) and the lines 03 owns (`:18`, `:124`, 499 together) were not in the audit's 13000 estimate (`../audit.md` §2). Only the cap binds; the targets steer the cut.
- W2 — The G6 text, the hook text and every pointer named "exact" below are written as given, because *Final check* step 8 searches their words; everything else is a rewrite by the per-section rules.
- W3 — The hook's handoff line is appended as the last paragraph of both texts, after the *What skips the pipeline* line, so points 1–4 keep their numbers (`bootstrap` steps 1 and 6 cite points 1 and 4) and the text before it is byte-for-byte what it was.
- W4 — The hook writes nothing to stderr for an input it cannot use: the text's `no session id` line already tells the manager, and B10's "stderr empty" stays true for every built level.
- W5 — `bootstrap` step 6's four Go and PostgreSQL hazards move verbatim to `plugins/glab/skills/bootstrap/references/hazards.md`, read on demand, with a one-line pointer: they stay in the payload (D12, *Comments and recorded incidents are kept*) and leave every session's start. `host.example.md` and a spec were rejected: neither reaches an installed manager.
- W6 — `glab:severity` holds the four-row table moved verbatim from `glab:audit` *Severity Levels*, which keeps its heading and becomes a pointer; the managers' *Your skills — this level only* lists do not gain it, because no manager invokes it — it is preloaded only.
- W7 — Rule 5's `haiku` paragraph moves to `glab:commit`, and Rule 5 keeps one clause pointing at it, so a user override that puts another role on `haiku` still finds the rule (F6).
- W8 — Rule 5's *why these models* (`:115`) and the precedence detail of `:119` leave the payload; `docs/specs/workflow.md` already holds the precedence order with versions (`:60`, `:976`), and the record adds the rationale sentence (D15). Rule 5 keeps one precedence sentence, since the report check relies on the parameter holding on a resume.
- W9 — Rule numbers, the titles *Your own context*, *Round caps*, *The handoff line* and *The level boundary*, and `bootstrap`'s six step numbers and titles stay: `AGENTS.md` *One fact* and every manager cite them (D5).
- W10 — A file in `plan/handoff/` with no status line is treated as `in-flight` by step 5, the safe reading: only a first line `- status: completed` is covered by the standing approval (D30).
- W11 — The planner row of G5 (`project-planner` ≤ 31168) is 03's: on `1bbf4bc` it measures 31496 (the rename grew it) and 02's `security` pointer adds about 60; 03 must cut at least about 390 from the planner's set (D9, F3). Recorded here so 03's planner sees it in the record, not as 02's goal.
- W12 — The tty case of D21 ("reads no stdin that is a terminal") gets no test: a terminal cannot be made portably in this test, and the `[ ! -t 0 ]` branch is one line read in review.
- W13 — The "skills of every level" list in `project-manager/SKILL.md:20` and `product-manager/SKILL.md:20` does not gain `glab:severity`: that list names the skills a manager invokes, and `glab:severity` is preloaded only (W6; the manager's decision, plan check round 1).
- W14 — A3's expected `anonymous receiver` count in `bootstrap/references/hazards.md` is 2, not 1: P9 copies `1bbf4bc:plugins/glab/skills/bootstrap/SKILL.md` lines 91–117 verbatim, and those lines hold the phrase twice (`sed -n 91,117p | grep -c` prints 2 on both). The tree is right and the plan's number was off; the manager's decision after develop.
- W15 — W13 is reversed: `glab:severity` goes into both managers' "skills of every level" lists (`project-manager/SKILL.md:20`, `product-manager/SKILL.md:20`), because *The level boundary* makes that list binding and `glab:session-rules` *Round caps* and Rule 0c now cite `glab:severity`; both review-1 reviewers found it independently. The manager's decision after review round 1.

## Boundary

Chosen: the three shared start files (`session-rules`, `bootstrap`, `security`'s one sentence), the hook and its two tests, the new `severity` skill with `audit`, `commit` and the four rating agents, a root `.gitignore`, and the `AGENTS.md` and `README.md` lines those changes force. Rejected: moving Rule 5's override text to a reference file (D4, the manager's); editing the managers' files (03's, or untouched — `product-manager` does not change); moving the hazards out of the payload (W5).

## Milestone

The gates green as `AGENTS.md` then states, with `Skills (22)` and the skills gate's four `audit` lines now `severity`; `tests/manager-bootstrap.test.sh` at `PASS 17/17` with B14–B17; `session-rules` ≤ 13312 and `bootstrap` ≤ 6144 by `wc -c`; *Final check* step 8 printing its targets.

## Before

- B1 — The tree is `1bbf4bc` plus the slug-level files v2 changed (`git status --short` shows only `plan/` entries); `jq -r .version plugins/glab/.claude-plugin/plugin.json` prints `0.15.0` (D29: no raise).
- B2 — Both gate blocks of `AGENTS.md` *Gates* green on that tree (`PASS 13/13` for the hook test, `Skills (21)`).
- B3 — The measures this plan starts from (2026-11-14, `wc -c` per `sed -n` range on `1bbf4bc`): `session-rules` 22530, `bootstrap` 8266, `security` 13243, `audit` 3876, `commit` 1115; hook text 2441 (project) and 2394 (product); agent sets (agent file + preloads) `project-analyzer` 26732, `project-plan-analyzer` 26424, `project-reviewer` 31045, `product-analyzer` 19721, `project-planner` 31496; `list=9798 files=30 onel=30`.

## Processing

### P1 — `plugins/glab/scripts/manager-bootstrap.sh` (D21, W3, W4)

Insert this block immediately before `if [ "$level" = product ]; then`:

```bash
# The session id names the session's own handoff file, plan/handoff/<id>.md (glab:session-rules
# Rule 2). Claude Code gives a command hook its input as JSON on stdin, with `session_id` on every
# SessionStart source - startup, resume, clear, compact - and the id stays the same across /compact
# and a resume (plan/flow-project-level/evidence.md E11). Only an id of letters, digits, `_` and `-`, beginning with a
# letter or digit and at most 128 long, is used, so no input can name a path outside plan/handoff/.
# A terminal on stdin is never read: a person running this by hand would wait on it. No input,
# input that is not JSON, no `session_id`, an id that fails the match, or no jq give the no-id line,
# whose fixed words `no session id` tell the manager to name the file itself.
id=''
if [ ! -t 0 ]; then
	id=$(jq -r '.session_id // empty | strings' 2>/dev/null) || id=''
fi
[[ $id =~ ^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$ ]] || id=''
# The backticks are the text's own Markdown, not a command.
# shellcheck disable=SC2016
if [ -n "$id" ]; then
	HANDOFF=$(printf 'Your handoff file is `plan/handoff/%s.md`, named by the id of this session. What it holds, and when it is removed: `glab:session-rules` Rule 2.' "$id")
else
	HANDOFF='Your handoff file: no session id reached this hook, so name it `plan/handoff/<UTC yyyymmddThhmmss>Z.md` and say so once. What it holds, and when it is removed: `glab:session-rules` Rule 2.'
fi

```

Replace `CTX="$HEAD` … `$AFTER"` (the four-line assignment) by the same with `\n\n$HANDOFF` after `$AFTER`:

```bash
CTX="$HEAD

$BEFORE
$MANAGER
$AFTER

$HANDOFF"
```

In the header comment's contract paragraph (`:20-23`), after "messages only on stderr.", add: "It reads stdin once, for the session id, only when stdin is not a terminal."

Verify: `bash -n`, `shellcheck` rc=0; P2's tests; A2's hook posts.

### P2 — `tests/manager-bootstrap.test.sh` (D21, B14–B17)

1. Replace the `hook()` comment and its first line:
   ```bash
   # hook <repo> [stdin]: runs the hook with CLAUDE_PROJECT_DIR set to the repo and that text as its
   # hook input - none, /dev/null, when it is not given, so no run inherits the test's own stdin; sets
   # OUT, ERR, RC and TEXT, the additionalContext. Asserts the contract on every run.
   hook() {
   	if [ $# -gt 1 ]; then
   		OUT=$(printf '%s' "$2" | CLAUDE_PROJECT_DIR=$1 bash "$SCRIPT" 2>"$W/err")
   	else
   		OUT=$(CLAUDE_PROJECT_DIR=$1 bash "$SCRIPT" </dev/null 2>"$W/err")
   	fi
   ```
   (the `RC=$?`, `ERR=`, `contract` lines after it stay).
2. After the `PRODUCT_MGR=` line add:
   ```bash
   # The handoff line's two forms: the path the id names, and the fixed words of the no-id line.
   # shellcheck disable=SC2016
   ID_PATH='`plan/handoff/abc-123.md`'
   NO_ID='no session id'
   ```
3. B5: replace its `OUT=$(CLAUDE_PROJECT_DIR=$r PATH=$W/bin bash "$SCRIPT" 2>"$W/err")` with
   ```bash
   # The input carries an id; without jq it cannot be read, so the plain text has the no-id line, as
   # B2's run without input does.
   OUT=$(printf '%s' '{"session_id":"abc-123"}' | CLAUDE_PROJECT_DIR=$r PATH=$W/bin bash "$SCRIPT" 2>"$W/err")
   ```
   and its `done_case` line with
   ```bash
   case $OUT in *"$NO_ID"*) ;; *) bad "the plain text lacks the no-id line" ;; esac
   done_case B5 "a PATH without jq: the plain text with the no-id line, exit 0"
   ```
4. B6: add `</dev/null` before `2>"$W/err"` in its `env -u CLAUDE_PROJECT_DIR` run.
5. Before `if [ "$fail" -eq 0 ]; then` add:
   ```bash
   # B14
   for a in '' 'glab-level: product'; do
   	if [ -n "$a" ]; then r=$(repo "b14-$RANDOM" "$a"); else r=$(repo "b14-none"); fi
   	hook "$r" '{"session_id":"abc-123","source":"startup"}'
   	has "$ID_PATH"
   	hasnt "$NO_ID"
   	no_err
   done
   done_case B14 "a session id: both levels' texts name plan/handoff/<id>.md"

   # B15
   hook "$(repo b15)"
   has "$NO_ID"
   hasnt 'plan/handoff/abc'
   [ "$TEXT" = "$B1_TEXT" ] || bad "the text differs from B1's"
   done_case B15 "no hook input: the no-id line"

   # B16: each input that must not give a path - not JSON, no session_id, a number, an empty id, a
   # path, a dot first, a newline inside, 129 characters, two JSON values.
   long=$(printf 'a%.0s' $(seq 129))
   for in in 'not json' '{}' '{"session_id":123}' '{"session_id":""}' '{"session_id":"../x"}' \
   	'{"session_id":".x"}' '{"session_id":"a\nb"}' "{\"session_id\":\"$long\"}" '{"session_id":"a"}{"session_id":"b"}'; do
   	hook "$(repo "b16-$RANDOM")" "$in"
   	has "$NO_ID"
   	hasnt 'plan/handoff/.'
   	hasnt 'plan/handoff/a'
   	no_err
   done
   done_case B16 "an input with no usable id: the no-id line, no path, exit 0"

   # B17
   hook "$(repo b17-none)" '{"session_id":"abc-123","source":"compact"}'
   r=$(repo b17-start)
   [ "$TEXT" = "$(cd "$W" && printf '%s' '{"session_id":"abc-123","source":"startup"}' | CLAUDE_PROJECT_DIR=$r bash "$SCRIPT" 2>/dev/null | jq -r .hookSpecificOutput.additionalContext)" ] ||
   	bad "the text after /compact differs from the startup text"
   has "$ID_PATH"
   done_case B17 "source compact: the same text, and path, as at startup"
   ```
6. The header comment (`:2-5`): add "and, from its stdin, whether it named the session's handoff file".

Verify: `bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh` prints 17 `ok` lines and `PASS 17/17`; A5's mutant.

### P3 — `tests/product-loop.test.sh:103` (D21)

In `start()`, `bash "$HOOK" 2>/dev/null` becomes `bash "$HOOK" </dev/null 2>/dev/null`. Verify: `PASS 17/17`.

### P4 — root `.gitignore` (D27)

A new file, exactly:

```
# The per-session handoff files of glab managers (glab:session-rules Rule 2): never committed.
plan/handoff/
```

Verify: `git check-ignore -q plan/handoff/x.md; echo "rc=$?"` prints `rc=0`; `git status --short plan/handoff` prints nothing.

### P5 — `glab:severity`, `glab:audit` and the four rating agents (D10, F10, W6)

1. New `plugins/glab/skills/severity/SKILL.md`, at most 700 bytes: frontmatter `name: severity` and the one-line description `description: The four severity levels — critical, high, medium, low — and what each means. Preloaded by the agents that rate findings; cited by glab:audit and the round caps.`; a heading `# Severity`; the sentence "Rate each finding on one of these four, never another."; then `audit/SKILL.md`'s table (`| Level | Meaning |` and its four rows) verbatim. The dry run's draft of this file was 616 bytes.
2. `plugins/glab/skills/audit/SKILL.md`: under `## Severity Levels`, the table is replaced by "The four levels and their meanings are `glab:severity`'s." Item 5 of the document structure becomes "**Issues Table** — every issue, classified on `glab:severity`."
3. In `plugins/glab/agents/{project-analyzer,project-plan-analyzer,project-reviewer,product-analyzer}.md`: the frontmatter line `  - glab:audit` becomes `  - glab:severity`; in the body, `on \`glab:audit\` *Severity Levels* — the one part of the preloaded \`glab:audit\` you use: you write no audit document` becomes `on \`glab:severity\`` (three agents), and in `product-analyzer.md` `by \`glab:audit\`'s *Severity Levels*` becomes `on \`glab:severity\``.

Verify: `/usr/bin/grep -rn 'glab:audit' plugins/glab/agents` prints nothing; the skills gate prints the four lines `…:glab:severity`; A1's agent sums.

### P6 — `glab:commit` takes the `haiku` rule (F6, W7)

Append to `plugins/glab/skills/commit/SKILL.md`, before *Report back*, `session-rules:126` rewritten for its one reader: "**Write the dispatch for `haiku`**, the committer's model: every instruction explicit, none left to inference, the work as numbered steps that are references, never content — `1 commit the paths <list>; 2 report as your file says`. The steps point at what it reads and never carry it; you do not read the plan to write them (`glab:session-rules` Rule 2). Its own *Report* section is its template, never pasted into the dispatch." Verify: `/usr/bin/grep -c 'report as your file says' plugins/glab/skills/commit/SKILL.md` prints `1`, and in `session-rules` prints `0`.

### P7 — `plugins/glab/skills/session-rules/SKILL.md` to at most 13312 bytes (D4, F6, F8, F9, F25, F26, G6)

A rewrite section by section. "Keep" means the rule and every registered string stay (A3 lists them); prose is compressed — one sentence where there were two, no example where the rule is plain, no restatement of what another section owns. Targets are bytes including the heading (W1).

| Section (today's lines, bytes) | Keeps | Drops / moves | Target |
|---|---|---|---:|
| frontmatter (1-4, 454) | `name:` | description, exact: `description: The rules every glab manager runs under, at every level — evidence, what reaches an agent, the effort and model of each dispatch, what skips the pipeline, the context budget and the handoff file, decide-record-move-on, the round caps and the handoff line.` (F26) | 300 |
| The level boundary (8-13, 688) | both rules, the prefixes `Product level — ` and `Project level — `, *Your skills — this level only* | the listing-budget sentence compressed | 500 |
| How to read these rules (14-17, 591) | that each manager cites these rules by number; a project stage named here means the product stage of the same role, and a rule for a stage a level lacks does not apply there; `plan.md` is `product-plan.md` at the product level | the list of examples (F25) | 230 |
| *Where a record line goes* (18, 227) | verbatim (03's) | — | 227 |
| Rule 0 (20-22, 438) | heading; exact body: "Point 1 of the session-start text owns it; each `glab` agent reads `AGENTS.md` in its own first step (Rule 0c)." | the restatement (F8) | 150 |
| Rule 0b (24-26, 335) | the rule and the bold sentence | "It is loaded with this skill" (F8) | 220 |
| Rule 0c (28-34, 1242) | the three channels; the shared-skill list becomes `glab:security`, `glab:comments`, `glab:severity`, `glab:audit`; the ad-hoc agent's dispatch names `glab:security`, and `glab:audit` when it writes findings | the stage list `(Stages 1b, 2, 3, 5, 6b and 8)` becomes "what the stage's own text says that round is given" (F25) | 850 |
| Rule 0d (36-43, 1986) | every bullet's rule: the default order (the user's level for the session, then `CLAUDE_CODE_EFFORT_LEVEL`, then ask once), the `- effort:` record line verbatim, the override for one agent, role or task, the five values and `ultra`, `effort default` when rejected, effort in the handoff line | the nine-name list (`:38`) becomes "every subagent, whatever its role" | 750 |
| Rule 1 (45-54, 1120) | both exemptions and that `glab:security` has none; the pipeline at the tier `glab:project-manager` *Pick the tier* gives | example phrases cut to one each | 650 |
| Rule 2 head (56-68, 1668) | every bullet; "Every round is a new agent" with "The one resume this skill allows is Rule 5's report check"; the one bullet "Dispatch independent agents in a single message so they run concurrently" (F9: its only place); the take-over test | "Stages 1b, 2, 3, 5, 6b and 8 say what each new agent is given" becomes "the stage's own text says what each is given" (F25) | 1000 |
| *Your own context* head and bullets `:74-76`, `:78`, `:80` (2602) | the hook's line `glab: context <n>k (last completed call)` and `; compact at <t>k` verbatim, 300k, 100k, `GLAB_COMPACT_AT`, "you cannot run `/clear` or `/compact`", the 648k incident, the smaller-window rule, the no-line fallback (15 dispatches, `· dispatches <d>`), never read the transcript | the hook mechanics beyond what the manager acts on | 1250 |
| `:77` and `:79` (665) | replaced by the three G6 bullets below, exact | `plan/SESSION-HANDOFF.md` | 1373 |
| Rule 3 (82-99, 1632) | the four ask-conditions as they stand (*One fact*), one question per plan, the three untouched things; the third bullet exact as below | — | 1250 |
| Rule 5 head and table (101-113, 815) | the head sentence; nine lines of the form ``- `glab:<agent>` — `<model>`;`` (their purposes dropped) | — | 400 |
| `:115` (274) | — | to the record (W8) | 0 |
| `:117` no parameter (566) | all of it | wording | 300 |
| `:118`, `:120`, `:121` the override (2317) | only the user's words change a role; pass `model` on every dispatch of that role (slices, fix rounds, re-dispatches, analyze and review rounds, stage skill or direct); `sonnet`, `opus`, `haiku`, `fable`, else ask; `fable` may bill usage credits, said once; how long it lasts (task, session, neither said); the `- model:` record line example verbatim; only a line quoting the user counts, others named to the user; the clause "`glab:project-manager` Rule 4 does not apply to the model choice" verbatim (03's); no plan behind it: this conversation only, then no parameter | repetition (D4: compressed in place) | 760 |
| `:119` precedence (470) | one sentence: the parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`; only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` overrides both; the parameter holds on a resume | versions and the spec pointer (W8) | 200 |
| `:122` model in the handoff line (708) | moved into *The handoff line*: `model <m>` after the stage, `model haiku (user)` for an override, it names what was passed; what can override the parameter, and telling the user when the tool rejects it | — | 0 |
| `:123` no bending (364) | all of it | wording | 220 |
| `:124` (272) | verbatim (03's) | — | 272 |
| `:126` (569) | one clause: "A `haiku` dispatch is written as `glab:commit` says." | the rule, to `glab:commit` (P6) | 70 |
| `:128` report check (748) | all of it: "the one resume Rule 2 allows", the model holds on a resume | "(see *Precedence*)" | 480 |
| *Round caps* (130-132, 1029) | every registered fact (stages, 2 rounds, round 3 on `critical`/`high` of round 2, the `- round 3:` line, the no-plan form `round 3/3 (<severity> <finding>)`, nothing past 3); "on `glab:audit`'s *Severity Levels*" becomes "on `glab:severity`" | wording | 750 |
| *The handoff line* (134-138, 749) | the line form, `max`, the develop rule, context or `dispatches <d>`, the effort; with `:122`'s model clause | the sub-plan example kept as one clause | 900 |

The three G6 bullets, exact, in *Your own context* where `:77` stood (`:79` goes):

```
- **Your handoff file** is the `plan/handoff/<id>.md` the session-start text names — with `no session id` there, the name it gives — and `plan/handoff/` is never committed. It holds the current state only: slug, stage, round, the next dispatch, what you wait on, and decisions no plan file holds — rewritten in place, never appended to, at most 4096 bytes (`wc -c`). Its first lines are `- status: in-flight` or `- status: completed`, `- session: <id>` and `- updated: <UTC ISO 8601>`. After a compaction keep writing the file your summary names as yours; if the session-start text names another, say so once.
- **At a task boundary** — after a task's last push, its record's when it has a plan folder — write `- status: completed`, then remove your own handoff file, and tell the user this is a good point to `/clear` and start the next task in a new session, whatever the number says; the next task opens a new file. No hook can tell a task boundary.
- **The standing approval.** The user's words "managers are must clean completed sessions handoffs, just remove them" are the one standing approval of a removal: they cover a file `plan/handoff/<id>.md` whose first line is `- status: completed`, and nothing else — no subdirectory, no other name, no file that holds the line anywhere but its first line. Every other removal stops and asks (`glab:security`).
```

Rule 3's third bullet, exact:

```
- **`glab:security` still stops you.** Its stop list and its *Destructive operations are proven* rule hold at every tier, and so does this skill's confirmation before every destructive action — except the standing approval of Rule 2 — and before every push (`glab:push`, at every level).
```

If the file is over 13312 after the pass, cut further in this order, never a string A3 lists: *Your own context*'s mechanics, Rule 0d, Rule 1, the override's wording; still over → stop and report the size to the manager (moving the override to a reference file is D4's call, not the developer's).

Verify: A1, A2's `session-rules` posts, A3.

### P8 — `plugins/glab/skills/security/SKILL.md:146` (D30)

The sentence "For those, stop and ask — approval for one destructive action never carries to the next." becomes, exact: "For those, stop and ask — approval for one destructive action never carries to the next, except the standing approval of `glab:session-rules` Rule 2." Nothing else in the file changes. Verify: A2's `security` post; `git diff --stat` shows one line changed there.

### P9 — `plugins/glab/skills/bootstrap/SKILL.md` to at most 6144 bytes (D12, D25, D26, F8, F9, F22, W5, W9)

Targets in bytes; about 5500 in all.

- Frontmatter (503 → 300): description, exact: `description: The first thing to run in any glab session — the working agreement, the skills to load, the real gates, the handoff files in plan/handoff/, and the tooling hazards that return success while wrong. Use at session start, after a compaction, when resuming parked work, or when unsure of the operating model.`
- Intro (318 → 200): the six steps in order, none optional; why — the costly mistakes here are setup mistakes. One sentence each.
- Step 1 (908 → 350): a pointer — points 1 and 4 of the session-start text say what to read, in which order, and what to do when a file is missing; with no such text (hooks off), read it from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh` for the level of the `glab-level:` line. Keep "Do not skim `AGENTS.md`" with its one-clause reason; `docs/constants.md` is decided, a plan conforms to it. Drop the paragraph on why the host file comes early (F8, F22).
- Step 2 (588 → 250): a pointer — point 2 of the session-start text names the three skills for your level; what skips the pipeline is `glab:session-rules` Rule 1. Drop the Rule 0c restatement (F8).
- Step 3 (641 → 550): kept, wording only; the `make ci` incident stays.
- Step 4 (520 → 250): name your stage in the pipeline of your manager (`glab:project-manager` → *The pipeline*, `glab:product-manager` → *The product pipeline*); round caps: `glab:session-rules` *Round caps*. Drop "Dispatch independent agents in a single message" (F9) and the *Pick the tier* and *Running agents in parallel* restatements.
- Step 5 (866 → about 1100): exact text:

```
## 5. Pick up the handoff

Before asking the user to re-explain anything, look in `plan/handoff/`. Each file is one manager session's (`glab:session-rules` Rule 2):

- your own file, the one the session-start text names: after a compaction or a resume it is where you left off;
- each other file whose first line is `- status: completed`: remove it without asking, under Rule 2's standing approval;
- each other file marked `in-flight`, or with no status line, and the legacy `plan/SESSION-HANDOFF.md` of glab 0.14 and earlier: its session may still run, and no file says whether. List its session, slug, stage and `updated` line, and take it over — its state into your file, then the old file removed — only on the user's yes;
- the area specs (`docs/specs/`, or where `AGENTS.md` puts them), the memory index `~/.claude/projects/<project>/memory/MEMORY.md`, and `git log --oneline origin/<branch>..HEAD`.

**A handoff is a point-in-time observation, not live state.** Verify anything load-bearing against the current code first: one asserted a feature switch was off after it had been armed.
```

- Step 6 (3617 → about 1600): the temp paragraph to about 400 (where point 4 says; facts of one machine live in the host file; the tmpfs quota that killed a session, which growing the tmpfs did not fix; `host.example.md` records it); the `grep` function paragraph to about 600 (every fact kept: `type grep`, the `[\s]` example, zero matches for a leading alternation group, the `golang.org/x/tools` exclusion, `command grep`, a known match before an absence); `:89-117` — the italic intro line `:89`, a blank, and the four hazards `:91-117`; only `:91-117` is copied, verbatim, to `hazards.md` below, whose own first line replaces `:89` — replaced by, exact: "**Four more, from one Go and PostgreSQL project** — a receiver name in a Go grep, a truncated query, a cached test result, a capped linter's per-file counts — are in [references/hazards.md](references/hazards.md). Read it before such a count or result reaches a plan."; the `grep -c` and exit-127 paragraphs kept.
- *The one-line check* (305): kept, wording only.
- New `plugins/glab/skills/bootstrap/references/hazards.md`: `# Hazards from one Go and PostgreSQL project`, the line "Moved from `glab:bootstrap` step 6 in glab 0.15.0. The trap in each is general; the commands are that project's.", then `bootstrap/SKILL.md:91-117` verbatim (`sed -n '91,117p'` of today's file).

Verify: A1, A2's `bootstrap` posts, A3's step check.

### P10 — `AGENTS.md` (D16, D28, F10)

Each edit exact; each must match once.

1. *Layout*, the last bullet: "`docs/`, `host.example.md`, `README.md` and this file belong to" becomes "`docs/`, `host.example.md`, `README.md`, `.gitignore` (it holds `plan/handoff/`, the managers' per-session handoff files) and this file belong to".
2. *Gates*, the `glab` bullet: `Skills (21)` becomes `Skills (22)`, and "`security` and `session-rules`" becomes "`security`, `session-rules` and `severity`".
3. *Gates*, the skills gate bullet: the four `…:glab:audit` lines become `…:glab:severity` (same files, same order); the count stays eighteen.
4. *Rules*, the `manager-bootstrap.sh` contract: after "— the project level when there is none" add "; it reads `session_id` from stdin with `jq`, never from a terminal, and names `plan/handoff/<id>.md` only for an id matching `^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$`, the `no session id` line otherwise".
5. *One fact*, the severity entry (`:180-181`; the match spans the line wrap, so match it with the newline and indent as whitespace, and rewrap the paragraph afterwards): "their meanings in `plugins/glab/skills/audit/SKILL.md` only" becomes "their meanings in `plugins/glab/skills/severity/SKILL.md` only, which `plugins/glab/skills/audit/SKILL.md` points at".
6. *One fact*, the handoff entry (`:201-203`; across the line wrap, rewrapped afterwards, as in 5) becomes: "the handoff file `plan/handoff/<session id>.md` — at most 4096 bytes, its `- status:` first line, and the standing approval that removes a completed one (`plugins/glab/skills/session-rules/SKILL.md` Rule 2, `plugins/glab/skills/bootstrap/SKILL.md` step 5, the pointers in `plugins/glab/skills/security/SKILL.md` and Rule 3, `plugins/glab/scripts/manager-bootstrap.sh`, `tests/manager-bootstrap.test.sh`)".
7. *Rules*, the `plan/` rule's last sentence (`:358-359`; across the line wrap, rewrapped afterwards, as in 5) becomes: "No untracked file under `plan/` is removed, except a completed handoff file under `glab:session-rules` Rule 2's standing approval; `plan/handoff/` is never committed."

Verify: A2's `AGENTS.md` posts; A4's gates as `AGENTS.md` then states.

### P11 — `README.md:9`

"`glab:comments`, `glab:audit` ·" becomes "`glab:comments`, `glab:audit`, `glab:severity` ·". No other README line changes (D28: no handoff in README).

## After

- A1 — Bytes, from the repo root: `wc -c plugins/glab/skills/session-rules/SKILL.md plugins/glab/skills/bootstrap/SKILL.md` prints at most 13312 and 6144; *Final check* step 4's last loop prints `project-analyzer` ≤ 23580, `project-plan-analyzer` ≤ 23288, `project-reviewer` ≤ 27973, `product-analyzer` ≤ 16657 (G5's *Before* minus 3000; `project-planner` is 03's, W11); step 4's `prod` is at most 47104 and `list` at most 10240 with `onel` equal to `files` (31). `proj` and `task` are not judged until 03.
- A2 — *Final check* step 8, from a fenced block of `../master.md`, as written there: the first search prints only `plugins/glab/skills/bootstrap/SKILL.md`; the hook runs print `1`, `0 1`, `0 1`, `1`; `rc=0`; every `c`, `rule2` and `rule3` line a count of 1 or more.
- A3 — Registered facts kept, each `/usr/bin/grep -cF` on `session-rules` printing 1 or more: `Product level — `, `Project level — `, `Your skills — this level only`, `is destructive`, `costs money`, `exposes real data`, `changes what the product is`, `2 rounds`, `- round 3: `, `round 3/3 (`, `glab:severity`, `- effort: `, `CLAUDE_CODE_EFFORT_LEVEL`, `effort default`, `model haiku (user)`, `glab: context <n>k (last completed call)`, `; compact at <t>k`, `300k`, `100k`, `GLAB_COMPACT_AT`, `· dispatches <d>`, `new agent`, `one resume`, `fable`, `Where a record line goes`, `Without subagent dispatch`, `Rule 4 does not apply to the model choice`; ``A `haiku` dispatch is written as `glab:commit` says`` printing exactly `1` (`glab:commit` alone already counts 2 on `1bbf4bc`); the nine pairs ``- `glab:<agent>` — `<model>` `` of the model gate, each `1`; `/usr/bin/grep -c '^## Rule \(0\|0b\|0c\|0d\|1\|2\|3\|5\) ' ` prints `8`. On `bootstrap`: `/usr/bin/grep -c '^## [1-6]\. '` prints `6`; `references/hazards.md`, `command grep`, `make ci` each 1 or more; on `references/hazards.md`: `anonymous receiver`, `psql | head -8`, `(cached)`, `max-same-issues` each `1`. `/usr/bin/grep -c 'Dispatch independent agents' plugins/glab/skills/bootstrap/SKILL.md` prints `0`, in `session-rules` `1`.
- A4 — Both gate blocks of `AGENTS.md` *Gates*, as written after P10: nine `rc=0`; shellcheck `rc=0`; `PASS 35/35`, `PASS 24/24`, `PASS 51/51`, `PASS 17/17`, `PASS 17/17`, every line `ok`; three `✔ Validation passed`; `Skills (22)` naming P10's list and `Agents (9)`; both hooks lines; `glab = glab`, `memory-sync = memory-sync`; `:0 :0 rc=1`; `1 1 1 rc=0`; the nine model lines; the eighteen skills lines with four `…:glab:severity`, none `MISSING`; no prefixed `name:`, `rc=1`.
- A5 — Mutant (D18, one): replace P1's `[[ $id =~ … ]] || id=''` line with `: mutant` (`sed -i 's/^\[\[ \$id =~ .*$/: mutant/'`); `tests/manager-bootstrap.test.sh` must end `FAIL 1/17` with B16 failing; restore the line from P1's block (not `git checkout`, the file's change is unstaged) and re-run to `PASS 17/17`.
- A6 — The live check, the user's, after installing 0.15.0 (E11 proved the raw id; this proves the path): in a manager session on the test repo, ask the session to quote its session-start line beginning `Your handoff file`; type `/compact`; ask again. Both quotes name the same `plan/handoff/<id>.md`, and neither says `no session id`. Optional: archive and resume the session and ask a third time. Until then the path after `/compact` is UNVERIFIED in a live session — B17 proves only that the same id gives the same text.
- A7 — Commit: one Conventional Commit, e.g. `feat(skills): slim the shared rules and give each manager session its own handoff file (glab 0.15.0)`, holding P1–P11's files, this folder, and the slug-level files v2 changed (`../master.md`, `../master.v1.md`, `../master.sha256`, `../index.md`, `../evidence.md`) with any round copies (`../master.md` *Final check* step 7). `plan/handoff/` is never committed; after P4 it is ignored.
- A8 — Back-out: before the commit, `git restore --staged --worktree -- plugins README.md AGENTS.md tests` and remove `.gitignore`, `plugins/glab/skills/severity/` and `plugins/glab/skills/bootstrap/references/` after looking at them (untracked: `glab:security`); after it, `git revert <sha>`.
- A9 — The skipped-step posts, each `/usr/bin/grep -cF`: `'</dev/null'` prints `2` in `tests/manager-bootstrap.test.sh` (P2.1's `hook()`, P2.4's B6) and `1` in `tests/product-loop.test.sh` (P3), on `1bbf4bc` `0` and `0`; `"whether it named the session's handoff file"` in `tests/manager-bootstrap.test.sh` prints `1` (P2.6); ``glab:audit`, `glab:severity` `` in `README.md` prints `1` (P11).

## Tests and coverage

Added: B14–B17 in `tests/manager-bootstrap.test.sh`. Updated: `hook()` (explicit stdin), B5 (id offered, no `jq`: the no-id line), B6 (`</dev/null`), `tests/product-loop.test.sh` `start()`. Coverage per step (`AGENTS.md` *Tests*):

- P1 — B14 (id, both levels), B15 (no input), B16 (nine unusable inputs, the regex's reason to exist, A5 proves it), B17 (compact = startup), B5 (no `jq`), B8 (both texts under 10000). The terminal branch: none (W12).
- P2, P3 — the gates themselves; A9 notices a skipped P2.4, P2.6 or P3.
- P4 — A2's `git check-ignore`.
- P5 — the skills gate (a misspelt `glab:severity` or `name:` ends `MISSING`); A1's sums; the agents' sentences by search only.
- P6–P9, P11 — Markdown has no gate: A1–A3's and A9's sizes and searches only, accepted.
- P10 — A4 against the CLI's output, A2's searches.

## Findings placed

F6 (P6, P7 Rule 5), F8 (P7 Rules 0 and 0b, P9 steps 1–2; the manager's sentence is 03's), F9 (P7 Rule 2 keeps the one copy, P9 step 4 drops its copy; the manager's half is 03's), F10 (P5), F22 (P9), F25 (P7 *How to read*, Rules 0c and 2), F26 (P7 and P9 descriptions; the manager's is 03's). Left to 03 by `index.md`: F17 and F19 (`:121`'s clause and `:124` stay verbatim).

## Record

Carried by `../master.md` *Record*; 02 adds for `docs/specs/workflow.md`: Rule 5's rationale sentence "The plugin's author chose them for cost, and gave the reviewer no `haiku` default: it is the last gate" (W8); that the four Go and PostgreSQL hazards live in `glab:bootstrap`'s `references/hazards.md` (W5); W11's planner overrun for 03; and E11 (`evidence.md`), which supersedes `../master.md` *Record*'s "Not verified: whether `session_id` is unchanged after `/compact` and on `resume`" for Claude Desktop; the CLI `--resume` and `--fork-session` stay unverified.

## Dry run

A clone of `1bbf4bc` under `$TMPDIR` (`git clone`), 2026-11-14: P1, P2 and P3 applied as written above, plus a draft `severity/SKILL.md` (616 bytes) and a `bootstrap/references/hazards.md` (`sed -n '89,117p'`, 1797 bytes; P9's `91,117` is 1677) to see the plugin gates take a new skill and a reference directory; no Markdown rewrite. The clone was removed afterwards (`ls -d "$TMPDIR"/fpl02*` finds nothing). First shellcheck run flagged an unused `B14_TEXT` (SC2034); the line was dropped, and P2 is written without it. Output:

```
nine lines "<script> rc=0"; shellcheck rc=0
PASS 35/35 ; PASS 24/24 ; PASS 51/51 ; PASS 17/17 (B1-B17 all ok) ; PASS 17/17
✔ Validation passed x3
  Skills (22)  audit, bootstrap, comments, commit, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-verdict, project-analyze, project-develop, project-integrate, project-manager, project-plan, project-plan-report, project-review, project-ship, push, security, session-rules, severity
  Agents (9)  (the nine)   Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
  Skills (1)  sync-memory   Agents (0)   Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
glab = glab ; memory-sync = memory-sync ; hooks.json :0 :0 rc=1 ; not yet confirmed 1 1 1 rc=0 ; nine model lines rc=0 ; MISSING 0 ; prefixed name: rc=1
step-8 hook runs: 1 ; 0 1 ; 0 1 ; 1
hook text bytes: project 2631, product 2584 (base 2441, 2394)
mutant (A5): FAIL B16 …; FAIL 1/17 — restored, PASS 17/17
```

With the hook at 2584, the product start after 02 is at most 2584 + 6144 + 10795 (`product-manager`, unchanged) + 13312 + about 13300 (`security` with P8) = 46135 at the caps, under 47104.
