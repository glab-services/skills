tier: normal — prompt wording in one script function and two profiles, one new test case, a version bump; no secret handling, no format, exit-code or permission change

# Plan — fix-external-report-lines

Follow-ups 13, 14 and 15 of `plan/feature-opencode-worker/follow-ups.md`
(lines 82–93), done as one small reviewed change before the user runs L1.
Base: `main` = `8cb2a92`. Planner: one agent, read-only on the repo; every
"proven" below was run in a throwaway copy, `/data/tmp/claude/ferl-proto.*`
(`plugins/`, `tests/`, `.claude-plugin/`, `README.md`, `AGENTS.md` copied
from `8cb2a92`), never in the repo.

## Findings

F1 — **the check is anchored, the template is not** (item 13). Proven by reading:

- `plugins/glab/scripts/external-agent.sh:676` takes the block between the
  two marker lines, each matched whole (`$0 == s`).
- `:680` counts verdicts with `^(SHIP|…|DO NOT PUBLISH: .+)$` — whole line.
- `:689` counts findings with `^rule: `.
- `:496-498` `reviewer_tail` prints the two marker lines, then appends
  `report_section "$plugin/agents/reviewer.md"` (`:457`), which is the
  reviewer's `## Report` section: its finding template is indented four
  spaces (`plugins/glab/agents/reviewer.md:81-84`, `    rule: <…>`) and its
  verdicts are quoted in backticks (`:86`, `` `SHIP` ``). Nothing in the
  message says the block's lines must be bare.
- `reviewer_tail` has two callers: `first_prompt` (`:494`, the first turn
  of a reviewer) and `cmd_send` (`:821`, every later turn of a reviewer). One
  edit in the function covers both; no other caller (`command grep -n
  reviewer_tail` returns `:494`, `:496`, `:821`).

Inferred, not proven: that a real model would copy the indent or the
backticks. No real reply exists (L1 has not run); the follow-up says "a
literal copy is exit 8", which the regexes above make true of a literal copy.

F2 — **kimi's claims rule is absolute** (item 14).
`plugins/glab/skills/external-agents/profiles/kimi.md:17`: "Every claim in
your answer names its `file:line` and quotes it." The same absolute rule is
also in the *Before the contract* section, `:11-13` ("Tie every claim to its
source: the `file:line` …"), which item 14 does not name, and the *Notes*
bullet `:34-37` describes the rule as taken. `default.md:25-26` also says
"every claim", but with the `UNVERIFIED` escape and no `file:line`, so it
is not this defect and is left alone.

F3 — **glm tells a read-only agent to act** (item 15).
`plugins/glab/skills/external-agents/profiles/glm.md:10`: "plan, then
analyse, then act". The *Notes* bullet `:33-35` records "plan, analyse, act"
as what was taken from the user's notes; the notes themselves stay as they are.

F4 — **the test reads only the manager's text** the way E47 does
(`tests/external-agent.test.sh:617-618`: from `manager:` to the first `says:`;
the stub's `prompt` scenario, `:92`, echoes the prompt after `says:`). The
transcript heads each turn `## turn <n> · …` (`external-agent.sh:639`), so
a case can read turn 1 (start) and turn 2 (send) separately.

F5 — **E47 is not disturbed**: it searches for each profile's first non-empty
*Before* line and last non-empty *After* line, read from the profile file at
test time (`:615-616`). Kimi's lines (`:10`, `:24`) do not change; glm's
first *Before* line does change, but the case reads the new one.

F6 — **one-fact list** (AGENTS.md *Rules*). Checked against what this
touches:

- the reviewer's verdict lines (`reviewer.md`, manager, ship, the validator,
  E34): **not changed** — the sentence names no verdict, and the regex at
  `:680` stays byte-identical;
- the exit codes: not changed;
- the external model allowlist: not changed;
- the case count: no payload file, `README.md` or `AGENTS.md` states it. The
  only count is the test's own comment `tests/external-agent.test.sh:518`,
  `E37-E47 were added after E36`, which becomes `E37-E48`;
- the skill's account of the report check,
  `plugins/glab/skills/external-agents/SKILL.md:130-134`, stays true: it
  says what is checked, not how the reviewer is told. See D3;
- the version rule: glab `0.4.0` → `0.4.1`
  (`plugins/glab/.claude-plugin/plugin.json:3`). Nothing else states the
  version: `command grep -rn '0\.4\.0' --include='*.md' --include='*.json' .`
  outside `plan/` returns only that line.

F7 — **baseline, before any edit** (copy of `8cb2a92`). The first run printed
`FAIL 1/47`; I captured only its last five lines, so **which case failed is
UNVERIFIED** — the tail showed E45, E46, E47 and E36 `ok`. Three more runs
right after:

    run 1 rc=0 PASS 47/47
    run 2 rc=0 PASS 47/47
    run 3 rc=0 PASS 47/47

The manager should know there is one intermittent case at `8cb2a92`,
unrelated to this change as far as I could see; not investigated.

## Decisions

- **D1 — where the sentence goes.** In `reviewer_tail`, after the two marker
  lines and before "Your contract's Report section, again:", so the model
  reads the rule before the indented template. One sentence, as item 13
  asks: the validator is not loosened (loosening it would change what an
  external report is, and E34 pins the regex).
- **D2 — kimi's *Before* section is narrowed too**, beyond item 14's text:
  the same absolute rule stands there, and narrowing only `:17` would leave
  the first one the model reads still demanding a `file:line` for the
  verdict. The manager may strike Step 3a and keep only 3b and 3c.
- **D3 — `external-agents/SKILL.md` is not edited.** Nothing it states
  becomes false, and copying the sentence there would make a second copy
  for nothing to keep in step.
- **D4 — a new case, E48, not an extension of E20.** E20 greps the whole
  transcript, the stub's echo included, and covers only the first turn. E48
  reads only the manager's text, for both a start and a send, and checks the
  order: `=== REPORT END ===` < the sentence < `Your contract's Report
  section, again:`. It pins the sentence word for word, as E34 pins the
  verdict regex.
- **D5 — the *Notes* bullets are updated**, not left describing the old text
  (AGENTS.md: comments and records are kept and kept true).
- **D6 (manager, after Stage 1b) — the sentence is narrowed.** The
  analyzer noted that "no indent and no backticks" on *every* line bans
  backticks in a finding's free text, where a reviewer quotes code, while
  the validator needs only the verdict line and the `rule:` lines bare.
  In Step 1 and in E48's `sl` (Step 2) the sentence is, word for word:
  `Inside the block, every line starts at the left edge, with no indent, even where the Report section below shows one. The verdict line and each rule: line carry no backticks, and the verdict line stands alone, with nothing else on it.`
  E48's title says "no indent, no backticks on the verdict and rule: lines".
  Consequence: the after-hashes of `external-agent.sh` and
  `tests/external-agent.test.sh` (After) no longer apply; the developer
  records the new ones in `result.md`. The other three hashes stand.
  D2 stands (the manager keeps Step 3a).
- Rejected: loosening the validator to accept indents and backticks —
  that would change what the script accepts and break E34's one-fact tie.
  Rejected: adding a `rev-indented` stub scenario that shows exit 8 — it
  tests behaviour that already exists and does not change.

## Before

    export TMPDIR=/data/tmp/claude
    git -C /home/pvhv/projects/skills rev-parse HEAD        # 8cb2a92…
    git -C /home/pvhv/projects/skills status --short        # only ?? plan/SESSION-HANDOFF.md (do not touch it)
    sha256sum plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/skills/external-agents/profiles/kimi.md plugins/glab/skills/external-agents/profiles/glm.md plugins/glab/.claude-plugin/plugin.json

Expected hashes at `8cb2a92` (proven, printed in the repo):

    81324a3374166bf832a586b457fe88176a70611f10fb8f97cd90fb3c5040a104  plugins/glab/scripts/external-agent.sh
    d06550c1232fed4381ab660eca3e1d4417a41d4b653eeb499b84128c47e3e7bd  tests/external-agent.test.sh
    7ad1561d7b5113ef129f73d27eeea652ee40a600a93ff98e4c1e4503c875a469  plugins/glab/skills/external-agents/profiles/kimi.md
    504c330908c8e309405582a479f7cdf19f7ea15b7b1eacebab79e43dc2e06950  plugins/glab/skills/external-agents/profiles/glm.md
    300dc7c5e8359221558a87193d1c279d57174f5bca3b2fd57bf85133397e220d  plugins/glab/.claude-plugin/plugin.json

A hash that differs: stop and re-read; the line numbers below are for these.

## Processing — the edits

Each before-text below was found exactly once in its file in the copy
(proven: `before-text found 1 time(s)` for all nine edits). Tabs in the test
are real tabs, as in the rest of that file.

### Step 1 — `plugins/glab/scripts/external-agent.sh:496-497`

Before:

````text
reviewer_tail() {
  printf '\n# Your final message\n\nEnd your final message with your report, and put nothing after it: the block your contract'"'"'s Report section asks for, filled in, between these two lines exactly:\n\n%s\n<the report>\n%s\n\nYour contract'"'"'s Report section, again:\n\n' "$REPORT_START" "$REPORT_END"
````

After:

````text
# finish_turn checks the block line by line from the left edge: the verdict
# line whole, and `^rule: ` for each finding. The Report section below indents
# its finding template four spaces and quotes the verdicts in backticks, so a
# reviewer that copied it as shown would be exit 8; the sentence after the two
# lines says so before that section is shown.
reviewer_tail() {
  printf '\n# Your final message\n\nEnd your final message with your report, and put nothing after it: the block your contract'"'"'s Report section asks for, filled in, between these two lines exactly:\n\n%s\n<the report>\n%s\n\nInside the block, every line starts at the left edge: no indent and no backticks, even where the Report section below shows them. The verdict line stands alone, with nothing else on it.\n\nYour contract'"'"'s Report section, again:\n\n' "$REPORT_START" "$REPORT_END"
````

The sentence has no `%` and no `\`, so it is safe in the `printf` format.

### Step 2 — `tests/external-agent.test.sh`

2a, `:518`. Before:

````text
# E37-E47 were added after E36 was written, and run before it: E36 checks
````

After:

````text
# E37-E48 were added after E36 was written, and run before it: E36 checks
````

2b, after `:626` (the `t E47 …` line) and before the blank line and E36.
Before:

````text
t E47 "for a reviewer on each family's profile, the profile's text is sent and both report lines follow it"
````

After (the E47 line unchanged, then a blank line and the new case):

````text
t E47 "for a reviewer on each family's profile, the profile's text is sent and both report lines follow it"

# The report check reads the block from the left edge, while the Report
# section a reviewer is shown indents its template and quotes the verdicts in
# backticks; every reviewer message, the first and a send, says so after the
# two report lines and before that section. Only what the manager sent is
# read, turn by turn: the stub's reply echoes the prompt after it. The
# sentence is the script's own, word for word, so a rewording fails here too.
ok=1; sl='Inside the block, every line starts at the left edge: no indent and no backticks, even where the Report section below shows them. The verdict line stands alone, with nothing else on it.'
M=opencode-go/glm-5.3 start prompt --role reviewer; A=$ID r1=$RC
send "$A" prompt; r2=$RC
for k in 1 2; do
	txt=$(awk -v h="## turn $k " 'index($0, h) == 1 {t = 1; next} t && /^manager:$/ {on = 1; next} on && /^says:$/ {exit} on' "$STATE/$A/transcript.txt")
	le=$(command grep -n -m1 -x -F '=== REPORT END ===' <<<"$txt" | cut -d: -f1)
	lx=$(command grep -n -m1 -x -F -- "$sl" <<<"$txt" | cut -d: -f1)
	la=$(command grep -n -m1 -x -F "Your contract's Report section, again:" <<<"$txt" | cut -d: -f1)
	{ [ -n "$le" ] && [ -n "$lx" ] && [ -n "$la" ] && [ "$le" -lt "$lx" ] && [ "$lx" -lt "$la" ]; } \
		|| { ok=0; echo "   E48 turn $k: end=$le sentence=$lx again=$la"; }
done; stop_all
[ "$r1" = 8 ] && [ "$r2" = 8 ] && [ "$ok" = 1 ] && OK=1
t E48 "every reviewer message, the first and each send, says after the two report lines that the block's lines start at the left edge, with no backticks and the verdict alone"
````

`r1` and `r2` are 8 because the `prompt` scenario has no report block; the
agent stays after an 8 (E18), so the send runs.

### Step 3 — `plugins/glab/skills/external-agents/profiles/kimi.md`

3a, `:11-13` (D2). Before:

````text
comments about yourself or about this message. Tie every claim to its
source: the `file:line` and a short, word-for-word quote of what is there,
in the field the template has for the claim. Add no field of your own.
````

After:

````text
comments about yourself or about this message. Tie every claim about the
code to its source: the `file:line` and a short, word-for-word quote of what
is there, in the field the template has for the claim. Add no field of your
own.
````

3b, `:17` (item 14). Before:

````text
Every claim in your answer names its `file:line` and quotes it.
````

After:

````text
Every claim about the code in your answer names its `file:line` and quotes it.
````

3c, `:34-37` (*Notes*, D5). Before:

````text
  professional tone with no filler, pleasantries or meta-commentary, and every
  claim tied to its source as a `file:line` with a short direct quote, in the
  template's own field, and the silent self-check that all four profiles
  share.
````

After:

````text
  professional tone with no filler, pleasantries or meta-commentary, and every
  claim about the code tied to its source as a `file:line` with a short direct
  quote, in the template's own field, and the silent self-check that all four
  profiles share. About the code only: a claim backed by command output, the
  verdict and the not-checked lines have no `file:line`, and a model told to
  give every claim one may invent it.
````

### Step 4 — `plugins/glab/skills/external-agents/profiles/glm.md`

4a, `:10-12` (item 15). Before:

````text
Work in three steps: plan, then analyse, then act. The plan comes first and
is for you: the task's hard constraints, and what lies outside it, which you
leave alone.
````

After:

````text
Work in three steps: plan, then analyse, then answer. The plan comes first
and is for you: the task's hard constraints, and what lies outside it, which
you leave alone.
````

4b, `:33-35` (*Notes*, D5). Before:

````text
  fills a fixed report inside the script's template was taken: plan, analyse,
  act, with the task's hard constraints and what is out of scope settled
  before starting, and the silent self-check that all four profiles share.
````

After:

````text
  fills a fixed report inside the script's template was taken: plan, analyse,
  act (said here as "then answer": the agent is read-only and changes
  nothing), with the task's hard constraints and what is out of scope settled
  before starting, and the silent self-check that all four profiles share.
````

### Step 5 — `plugins/glab/.claude-plugin/plugin.json:3`

Before: `  "version": "0.4.0",` After: `  "version": "0.4.1",`

Nothing else changes. No file outside these five; `plan/SESSION-HANDOFF.md`
is not touched.

## After — the gates

From the repo root, `export TMPDIR=/data/tmp/claude` first, then the AGENTS.md
*Gates* blocks exactly as written there (both blocks). Green:

- five `… rc=0` lines; shellcheck `rc=0` with no findings;
- `tests/memory-sync.test.sh`: every line `ok`, last line `PASS 35/35`
  (unchanged by this change);
- `tests/external-agent.test.sh … </dev/null`: every line `ok`, including
  `ok E48 …` just before `ok E36 …`, last line **`PASS 48/48`** (was 47/47);
- three `✔ Validation passed`; glab `Skills (15)`, `Agents (5)`,
  `Hooks (1)  SessionStart`; memory-sync `Skills (1)  sync-memory`,
  `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
  `glab = glab`, `memory-sync = memory-sync`; `:0` after each `hooks.json`
  then `rc=1`; `1` after each of the three files then `rc=0`; `1` then `rc=0`
  for `not yet run against a real model`; no line then `rc=1`.

Also:

    jq -r .version plugins/glab/.claude-plugin/plugin.json     # 0.4.1
    command grep -c -F 'then act' plugins/glab/skills/external-agents/profiles/glm.md     # 0
    command grep -n -F 'Every claim in your answer names' plugins/glab/skills/external-agents/profiles/kimi.md; echo "rc=$?"   # no line, rc=1
    git status --short     # the five paths M, and ?? plan/SESSION-HANDOFF.md, ?? plan/fix-external-report-lines/

Expected hashes after the edits (proven, from the copy where every gate
above was green):

    e63c489dbe803b40a3ccb466eaf87fb263e3603b84a98661bc7be756e7e81d83  plugins/glab/scripts/external-agent.sh
    982bde5bf1699bf9165d00061c9d40d90978d6e8e03c8ffa26fc7fe005e255f6  tests/external-agent.test.sh
    6ca8e669b082434f537147fa6b63ecfa8cefc4631d882eca99ecdd8ae4de950b  plugins/glab/skills/external-agents/profiles/kimi.md
    2057207a1f2ee2c3fb3e8d7a1a4ce722a8653bea3853096ae049458165632c92  plugins/glab/skills/external-agents/profiles/glm.md
    7ae980039b274f8e4e9da3a594d77b197aa6bd7e37348f71d788feb8e3b0ba25  plugins/glab/.claude-plugin/plugin.json

### What the planner ran in the copy (proven)

With all five steps applied:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    test rc=0
    48                      # count of '^ok ' lines
    ok E48 every reviewer message, the first and each send, says after the two report lines that the block's lines start at the left edge, with no backticks and the verdict alone
    ok E36 after every case: the real repository is unchanged byte for byte, no agent is left, and no sandbox, slirp4netns or stub process runs
    PASS 48/48

    PASS 35/35              # tests/memory-sync.test.sh

    ✔ Validation passed (×3)
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
    0.4.1

E48 can fail for the reason it exists (proven, two mutants of Step 1's
script in fresh copies):

    mutant drop rc=1                      # sentence removed
       E48 turn 1: end=476 sentence= again=478
       E48 turn 2: end=13 sentence= again=15
    NOT OK E48 …
    FAIL 1/48
    mutant move rc=1                      # sentence moved above the report lines
       E48 turn 1: end=478 sentence=474 again=480
       E48 turn 2: end=15 sentence=11 again=17
    NOT OK E48 …
    FAIL 1/48

The analyzer may rerun both: delete the sentence plus its `\n\n` from the
`printf` in a copy, or move it to straight after `between these two lines
exactly:\n\n`; E48 must be `NOT OK` and the summary `FAIL 1/48`.

## Coverage (AGENTS.md *Tests*)

- Step 1 (sentence in `reviewer_tail`): **E48** — present, whole, on its own
  line, after `=== REPORT END ===` and before the Report section, in the first
  message (start) and in a send. E17, E18, E19, E20, E44 and E47 still pass,
  so the markers, the block extraction and the validator are unchanged.
  The comment above the function: no case; comments are not tested.
- Step 2 (E48 and the comment): it is the test. Its failure modes are shown by
  the two mutants above.
- Step 3 (kimi): **E47** checks that kimi's first *Before* line and last
  *After* line reach a reviewer's message; neither line is one this step
  changes. The new wording itself is covered by no case: it is prompt text
  for a model, and no case can tell whether a model obeys it. Accepted; L1 is
  where it is checked.
- Step 4 (glm): **E47** reads glm's first *Before* line from the file, so it
  checks that the new line 10 is sent. Whether the model "answers" rather than
  "acts": no case, as for Step 3.
- Step 5 (version): no case; checked by the `jq` line in *After*.
- *Notes* bullets (3c, 4b): no case; never sent (E20 asserts no profile's
  notes are sent), checked by reading.

## Commit

One commit, the five paths (`git add` each by name):

    fix(skills): tell an external reviewer its report lines start at the left edge

    - external-agent.sh: reviewer_tail says the block's lines have no indent or
      backticks and the verdict stands alone, as the check needs
    - test: E48 reads the manager's first and send messages for that sentence
    - kimi profile: the file:line rule covers claims about the code only
    - glm profile: plan, analyse, then answer — the agent is read-only
    - glab 0.4.1

The records — marking follow-ups 13–15 done in
`plan/feature-opencode-worker/follow-ups.md`, and this plan — go in a
separate `docs(repo)` commit, as the repo's history does (`8cb2a92`).

## Back-out

Before the commit: `git restore` the five paths above (only them). After it:
do not `git revert` back to `0.4.0` — an installed `0.4.1` would not receive
it. Write a new commit that restores the five files' text and raises glab to
`0.4.2`, and run the same gates (the test returns to `PASS 47/47`).
