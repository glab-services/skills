# Result — fix-external-report-lines

Developer, 2026-10-17. Base `8cb2a92`. Nothing staged, committed or pushed.
`plan/SESSION-HANDOFF.md` not touched. This folder has no `findings.md` or
`questions.md`; the plan's own *Findings* and *Decisions* were the contract.

## Stages

- **Before** — done. `HEAD` = `8cb2a921c82d348ae312a24f38a2dddde9ea24a9`;
  status was only `?? plan/SESSION-HANDOFF.md`, `?? plan/fix-external-report-lines/`;
  all five before-hashes matched the plan byte for byte (`81324a33…`,
  `d06550c1…`, `7ad1561d…`, `504c3309…`, `300dc7c5…`).
  Every before-text was found exactly once (`before-text found 1 time(s)` ×9)
  before anything was written.
- **Step 1** — done. `plugins/glab/scripts/external-agent.sh:496-500` (new
  comment), `:502` (sentence in the `printf`, after the two marker lines and
  before "Your contract's Report section, again:"). Sentence is D6's, word
  for word (see *Deviations*). Callers re-checked: `reviewer_tail` is called
  at `:494` (`first_prompt`) and `:826` (`cmd_send`) only; one edit covers both.
- **Step 2a** — done. `tests/external-agent.test.sh:518` `E37-E47` → `E37-E48`.
- **Step 2b** — done. `tests/external-agent.test.sh:628-646`, new case E48
  after E47, before E36. `sl` is D6's sentence; title per D6.
- **Step 3a** — done. `plugins/glab/skills/external-agents/profiles/kimi.md:11-14`.
- **Step 3b** — done. `kimi.md:18`.
- **Step 3c** — done. `kimi.md:36-40` (*Notes*).
- **Step 4a** — done. `plugins/glab/skills/external-agents/profiles/glm.md:10-12`.
- **Step 4b** — done. `glm.md:33-36` (*Notes*).
- **Step 5** — done. `plugins/glab/.claude-plugin/plugin.json:3` `0.4.0` → `0.4.1`.
- **After** — done; all gates green (below).

### Deviations — D6 applied

The plan's Step 1 sentence and E48 `sl` were replaced by D6's text, word for word:

    Inside the block, every line starts at the left edge, with no indent, even where the Report section below shows one. The verdict line and each rule: line carry no backticks, and the verdict line stands alone, with nothing else on it.

E48's title, so that it contains D6's phrase "no indent, no backticks on the
verdict and rule: lines":

    every reviewer message, the first and each send, says after the two report lines that the block's lines start at the left edge: no indent, no backticks on the verdict and rule: lines, and the verdict alone

The wording around D6's phrase in the title is mine; D6 named the phrase, not
the whole title. The comment above `reviewer_tail` and the comment above E48
are as the plan wrote them: both still hold with the narrower sentence.

### After-hashes

    cd83212a9d855b641c3162a22f2a6fbb23aa017dd135352f6ebc9661ca835f1d  plugins/glab/scripts/external-agent.sh        (new, D6; plan's e63c489d… no longer applies)
    e07ea8851a8fec1d03d76c713ff942c67059b54bd216696d57463b8785e76d19  tests/external-agent.test.sh                  (new, D6; plan's 982bde5b… no longer applies)
    6ca8e669b082434f537147fa6b63ecfa8cefc4631d882eca99ecdd8ae4de950b  plugins/glab/skills/external-agents/profiles/kimi.md   (= plan)
    2057207a1f2ee2c3fb3e8d7a1a4ce722a8653bea3853096ae049458165632c92  plugins/glab/skills/external-agents/profiles/glm.md    (= plan)
    7ae980039b274f8e4e9da3a594d77b197aa6bd7e37348f71d788feb8e3b0ba25  plugins/glab/.claude-plugin/plugin.json                (= plan)

## Blocked

Nothing.

## Unplanned changes

None in the five payload/test paths. The manager's dispatch asked for an edit to
`plan/feature-opencode-worker/follow-ups.md` (see *Follow-ups*); that is a record,
not a plan step.

## Tests

- Added: **E48** (`tests/external-agent.test.sh:628-646`). Changed: the comment at `:518`.
- `tests/external-agent.test.sh`: `PASS 48/48`, 48 `ok` lines, no other line;
  `ok E48 …` comes right before `ok E36 …`.
- `tests/memory-sync.test.sh`: `PASS 35/35` (unchanged).
- E48 fails for the reason it exists. I re-ran the plan's two mutants on D6's
  sentence, each in its own throwaway copy under `/data/tmp/claude` (removed afterwards):

      mutant drop rc=1                      # sentence and its \n\n removed
         E48 turn 1: end=476 sentence= again=478
         E48 turn 2: end=13 sentence= again=15
      NOT OK E48 every reviewer message, the first and each send, ...
      FAIL 1/48
      mutant move rc=1                      # sentence moved right after "between these two lines exactly:\n\n"
         E48 turn 1: end=478 sentence=474 again=480
         E48 turn 2: end=15 sentence=11 again=17
      NOT OK E48 every reviewer message, the first and each send, ...
      FAIL 1/48

  (In both, the only other non-`ok` lines were the two detail lines that
  `t` prints under `NOT OK`: `rc=0 stderr=[]` and `stdout=[stopped: ea-…]`.)

### Coverage (AGENTS.md *Tests*: a list, not a number)

- Step 1, the sentence: **E48**. It checks that the sentence is there, whole, on
  a line of its own, after `=== REPORT END ===` and before the Report section, in
  the first message (start) and in a send. E17, E18, E19, E20, E44 and E47 still
  pass, so the markers, the block extraction and the validator did not change.
  The comment above `reviewer_tail`: no case covers it, because comments are not tested.
- Step 2: this is the test. The two mutants above show how it fails.
- Step 3a, 3b (kimi): **E47** checks that kimi's first *Before* line (`:10`) and
  last *After* line reach a reviewer. Neither is a line this step changes. No case
  covers the new wording. It is prompt text for a model, and no case can tell
  whether a model obeys it; L1 is where that gets checked. Step 3a is checked only
  by the after-hash of `kimi.md`.
- Step 3c (kimi *Notes*): no case covers it. Notes are never sent (E20). It is
  checked only by the after-hash of `kimi.md`.
- Step 4a (glm): **E47** reads glm's first *Before* line from the file, so it
  checks that the new line 10 is sent. Whether the model answers rather than acts:
  no case can check that.
- Step 4b (glm *Notes*): no case covers it. Notes are never sent (E20). It is
  checked only by the after-hash of `glm.md`.
- Step 5: no case. It is checked by `jq -r .version` → `0.4.1`.

## Gates

`export TMPDIR=/data/tmp/claude`, run from the repo root. These are the AGENTS.md
blocks as they are on disk (they name `external-agent.sh`, and they include the
`not yet run against a real model` line).

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0

`bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh`:
rc=0, every line but the last is `ok`, and the last line is `PASS 35/35`.

`bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null`:
rc=0, 48 `^ok ` lines and no other line apart from the summary. The tail:

    ok E48 every reviewer message, the first and each send, says after the two report lines that the block's lines start at the left edge: no indent, no backticks on the verdict and rule: lines, and the verdict alone
    ok E36 after every case: the real repository is unchanged byte for byte, no agent is left, and no sandbox, slirp4netns or stub process runs
    PASS 48/48

Plugin gates, with `CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`
and the block exactly as AGENTS.md writes it (`CLAUDE_CONFIG_DIR` is a fresh
`mktemp -d` under `$TMPDIR` and is removed at the end; no `claude-config.*`
was left over afterwards):

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

The plan's *After* extras:

    0.4.1        # jq -r .version plugins/glab/.claude-plugin/plugin.json
    0            # grep -c -F 'then act' glm.md
    rc=1         # grep -n -F 'Every claim in your answer names' kimi.md: no line

`command grep -rn '0\.4\.0' --include='*.md' --include='*.json' .`, with
`plan/` filtered out, finds no line (`rc=1`). Old wording elsewhere:
`then act`, `Every claim in your answer` and `Tie every claim to its`, searched
outside `plan/` and `.git`, match only
`plugins/glab/skills/external-agents/profiles/default.md:25`. F2 leaves that
line alone on purpose.

### Blast radius

    $ git status --short -uall
     M plan/feature-opencode-worker/follow-ups.md
     M plugins/glab/.claude-plugin/plugin.json
     M plugins/glab/scripts/external-agent.sh
     M plugins/glab/skills/external-agents/profiles/glm.md
     M plugins/glab/skills/external-agents/profiles/kimi.md
     M tests/external-agent.test.sh
    ?? plan/SESSION-HANDOFF.md
    ?? plan/fix-external-report-lines/plan.md
    $ git diff --stat
     plan/feature-opencode-worker/follow-ups.md         | 11 +++++++++++
     plugins/glab/.claude-plugin/plugin.json            |  2 +-
     plugins/glab/scripts/external-agent.sh             |  7 ++++++-
     .../glab/skills/external-agents/profiles/glm.md    |  9 +++++----
     .../glab/skills/external-agents/profiles/kimi.md   | 17 ++++++++++-------
     tests/external-agent.test.sh                       | 22 +++++++++++++++++++++-
     6 files changed, 54 insertions(+), 14 deletions(-)

(`result.md` is written after this snapshot, so it shows as a new untracked
file in this folder.) The five plan paths go in the `fix(skills)` commit.
`follow-ups.md` and this folder go in the separate `docs(repo)` commit, as the
plan's *Commit* section says.

## Follow-ups

Written to `plan/feature-opencode-worker/follow-ups.md`, as the manager's
dispatch asked:

- Items 13, 14 and 15 each have a status line:
  `*Status (developer, 2026-10-17):* done in `fix-external-report-lines`.`
  This matches the existing `*Status (…):*` format of items 3 and 11.
- New heading `## From the report-lines fix`, item 24: the intermittent 1-of-47
  failure in the planner's baseline at `8cb2a92`, using the manager's text.
  It is out of scope here because it predates this change and its case is unknown.
  No further failure happened in this run: one run with `PASS 48/48` and two
  mutant runs where only E48 failed.

Nothing else was found that wanted doing.

## Not done

- All steps in scope were done. The commit is not made; that is the committer's job.
- UNVERIFIED: that a real model copies the indent or the backticks, and that it
  obeys the new sentence or profile wording. No real model was run, as the
  rules require; L1 is the user's step.
