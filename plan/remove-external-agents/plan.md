Tier: full — it removes a feature of `glab` (eight files, a skill, a gate suite) and changes seven more files that hold many *One fact* pairs.

# remove-external-agents — plan

The user ended the external-agents experiment ("let's remove external
subagents implementation, experiment failed") and chose to remove all of it:
both backends of `plugins/glab/scripts/external-agent.sh`, the
`glab:external-agents` skill and its `profiles/`, `tests/external-agent.test.sh`
and its gate lines and prose, and every mention in `glab:manager`, the
commands, `README.md` and `AGENTS.md`. `docs/specs/external-agents.md` stays as
a record. `glab` goes to 0.8.0.

The Write tool refused the file name `findings.md` for this planning agent,
so the findings are the *Findings* section at the end of this file. There is
no `questions.md`: nothing open is the user's (see D1–D16).

## Decisions

- D1 Tier full (first line). The user approves the plan before any agent writes.
- D2 One commit, `feat(agents): remove the external agents and their script` (the committer may word it), with the deletions, the edits, the version and this folder. The *One fact* rule wants the component counts in `AGENTS.md` *Gates* and `README.md` changed in the same commit as the skill's removal, and the version rule wants `plugin.json` in it too. Its body names `6b2a024` as the last commit with the code. `feat` because the plugin's feature set changes and the version takes a minor step; `AGENTS.md` names no breaking-change marker, so none is added.
- D3 The note at the top of `docs/specs/external-agents.md` goes in **Stage 8, not in this change**. (a) `AGENTS.md` *Rules*, the `plan/` rule: after the push, the record updates each touched area's spec, and a spec states a fact "as of its last record"; `glab:manager` Stage 8: "The record changes the spec and nothing else", in a docs commit of its own. (b) "The last commit on `origin/main` that has the code" can only be read after the push: it is the removal commit's parent on `origin/main`, which is `6b2a024` only if nothing else lands first; the record checks it (`git rev-parse <removal>^` and `git ls-tree <that> -- plugins/glab/scripts/external-agent.sh`). (c) A note written now would say "removed" while the review can still stop the change.
- D4 The target of every edited passage is its text before `7139e62`, plus the later changes that are not about external agents (`fed95f9`, the `BLOCK: 1 issue` of `5321d76`, `abda43a`'s session effort). The dry run (*Findings*, *What the target text is*) shows `edits.py` reaches exactly that.
- D5 *Record it before the next dispatch* loses "The effort is not in the model line: Rule 0d's `- effort:` line records it, for Codex too." in full. `abda43a` added it only because the Codex model lines had carried an effort clause; no Claude model line ever did, and the bullet comes back to its pre-`7139e62` text.
- D6 *The pipeline* keeps "The effort is the level you passed." and loses only the Codex and OpenCode clause: it still holds for every Claude dispatch, and the session-effort *One fact* entry names *The pipeline*.
- D7 Rule 0d keeps "for an Agent tool dispatch" before "a level it does not take": a smaller edit, and still true.
- D8 `AGENTS.md`'s `plan/` rule keeps `external-agents.md` in its list of area specs. The spec stays, and this change's own Stage 8 updates it. Whether to reword that list item once the record has run is a Stage 8 question (see *Record*). It is the one hit the narrow search is expected to return.
- D9 `BLOCK: 1 issue` stays in `/glab:ship` and in the verdict entry. `5321d76` added it for the script's validator, but `glab:reviewer` (`agents/reviewer.md:86`) emits it.
- D10 No "removed" note goes in `README.md` or the payload. The user said remove all of it, and the narrow search has to come back empty. The record of the removal, with what a 0.7.x host can still hold (`$TMPDIR/glab-external-agents/`, Codex's own sessions), goes into the spec's top note at Stage 8 and into the commit body.
- D11 No new text for a user who names an external reviewer or developer after 0.8.0. Rule 5's existing "A name the parameter does not take: say so, and ask which of the four the user means" already covers it.
- D12 `glab` `0.7.2` → `0.8.0`, the user's choice. `memory-sync` is not touched and keeps its version.
- D13 One `glab:developer` agent. The steps touch disjoint files and could be split, but the whole change is small, and S9 checks every file together.
- D14 Removing Rule 6 renumbers nothing, because it is the last numbered rule of `glab:manager` (*Findings*, *Other facts*).
- D15 `plan/remove-external-agents/edits.py` is the exact list of the text edits (S2–S8). The developer runs it from the repository root as `python3 -I plan/remove-external-agents/edits.py .`, or applies the same edits by hand. Either way the S9 hashes are the check. The script fails before writing a file whose edit does not match exactly once. It deletes nothing and runs no git command that writes.
- D16 Nothing goes into `docs/specs/` in this change. `workflow.md`, `marketplace.md` and `external-agents.md` are Stage 8's (*Record*).
- Approved by the user, 2026-10-20: "go ahead".
- effort: high (the user's words: "let's for now set the effort for your subagent you current session high level"), for the session

## Milestone

This plan removes code and adds no behaviour, so its milestone is the
existing gates. They must stay green with the external parts gone: the
`memory-sync` suite still at `PASS 35/35`, and the plugin block with
`Skills (14)` naming the six skills and the eight commands. The S9 checks are
what tell a finished tree from a half-finished one. Validation and the count
alone cannot: a copy with only the skill and the script removed, every
mention of them still in place, also printed `✔ Validation passed` and
`Skills (14)` (*Findings*).

## Boundary

Remove the eight files. Edit every caller back to its text before the
feature, keeping the later changes that are not about external agents (D4).
`docs/specs/` and `plan/SESSION-HANDOFF.md` stay as they are. The other
candidate boundaries, and why each was rejected, are in *Findings*,
*Candidate boundaries*: `git revert` (it conflicts and takes Stage 8 and the
session effort with it), keeping the script deprecated (the user said
remove), a payload tombstone (D10), folding Rule 6 into another rule (new
text under a removal).

## Before — run once on the untouched tree

`export TMPDIR=/data/tmp/claude`, then the four shell gates and the plugin
block exactly as `AGENTS.md` *Gates* has them at `6b2a024`. Expected: the
baseline in *Findings*, which ends with `PASS 35/35`, `PASS 86/86`,
`Skills (15)  ... external-agents ...`. A red baseline means stop (manager:
"Dispatching onto a red tree ...").

## Steps

**S1 — remove the eight files.**
`git rm -- plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/skills/external-agents/SKILL.md plugins/glab/skills/external-agents/profiles/default.md plugins/glab/skills/external-agents/profiles/kimi.md plugins/glab/skills/external-agents/profiles/glm.md plugins/glab/skills/external-agents/profiles/deepseek-pro.md plugins/glab/skills/external-agents/profiles/deepseek-flash.md`.
Every target is tracked, clean and recoverable at `6b2a024`, and nothing
untracked or ignored sits beside them (*Findings*). Look at
`git status --short --ignored -uall -- plugins/glab/skills/external-agents`
first, and stop if it prints anything.
Verify: check C1 below.

**S2 — version.** `plugins/glab/.claude-plugin/plugin.json`: `"version": "0.7.2"` → `"version": "0.8.0"`; nothing else in the file changes.
Verify: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.8.0`, and the C5 hash.

**S3 — `plugins/glab/commands/develop.md`** (`edits.py` S3a–S3e):
the description loses ", or one external Codex developer when glab:manager
Rule 5 recorded one"; the orchestrator line loses ", or the external
developer `glab:manager` Rule 5 recorded, through `glab:external-agents`";
*Decide the split* loses its external-developer sentence; *Dispatch* loses the
**An external developer** bullet; *When the agents return* loses the block
from "**An external developer first**" through "- then the gates, as for any
agent." and the blank line after it.
Verify: C2, C3, C5; `git show 7139e62^:plugins/glab/commands/develop.md | diff - plugins/glab/commands/develop.md` shows only the `- the effort, always:` bullet.

**S4 — `plugins/glab/commands/review.md`** (S4): line 8 loses the two sentences from "If I named an external reviewer instead" through "a Codex reviewer works in the repository and can take one."
Verify: C2, C5; the diff against `7139e62^` shows only the `effort` sentence.

**S5 — `plugins/glab/commands/ship.md`** (S5a, S5b): step 1 loses "If I named an external reviewer instead, run every round through the `glab:external-agents` skill, with the same target."; the *No clear verdict* bullet loses "An external reviewer's report check is the script's: ... reported and not retried."
Verify: C2, C5; the diff against `7139e62^` shows only the two effort sentences and `BLOCK: 1 issue` (D9). The round cap text (`At most three rounds`) does not change.

**S6 — `plugins/glab/skills/manager/SKILL.md`** (S6a–S6p):
- S6a: remove the section `## Rule 6 — an external agent is the user's call`, its lines 157–167, and the blank line after it, so `## Know the gates before you dispatch` follows Rule 5's last paragraph;
- S6b: Rule 0d loses "A Codex agent runs at this same level through Rule 6's mapping, and Codex takes `ultra`; an OpenCode agent takes none." (D7);
- S6c: Rule 5 loses its second paragraph (the **external reviewer**/**external developer** one) and the blank line after it;
- S6d, S6e: *Carry it* ends its name sentence at "ask which of the four the user means." and loses everything from "An external reviewer is not a `model` parameter:" to the end of the bullet;
- S6f: *These two roles only* loses its last sentence;
- S6g: *Record it* loses everything after "the user can restate it." (D5);
- S6h: *Name it* loses the two external handoff-line sentences at its end;
- S6i: *Without subagent dispatch* loses "That holds for a Claude model; ...";
- S6j: the dispatch table loses its two external rows;
- S6k: *Check what comes back* loses its exit-8 sentence;
- S6l: *The pipeline* paragraph ends "(Rule 5). The effort is the level you passed." (D6);
- S6m: the parallel review bullet ends at "that role.";
- S6n: the no-dispatch bullet loses "An external reviewer is different: ...";
- S6o: Stage 5 loses "An external reviewer runs through `glab:external-agents`, ...";
- S6p: *What you never do* loses the "Start an external agent ..." bullet.
Kept: lines 279, 401, 412 ("external API", "external dependencies", "external auditor").
Verify: C2, C3, C4, C5; the diff against `7139e62^` shows only the Rule 0d section, the Stage 8 and record hunks, and the effort hunks (*Findings*).

**S7 — `AGENTS.md`** (S7a–S7j):
- S7a *Layout*: "`hooks/hooks.json` and `scripts/manager-bootstrap.sh`.";
- S7b *Gates* and *Tests*, from `## Gates` up to `## Rules`, become the text they had at `7139e62^`: "The test creates its work directory ...", "run all three", the loop and `shellcheck` over the three scripts, no suite line for the external agents, "Green is: three `rc=0` lines; ... every line `ok`, last line `PASS n/n`", no `bwrap`/`slirp4netns`/`python3` prose, no DeepSeek gate line and no green bullet for it, `Skills (14)` naming the six skills and the eight commands, and the *Tests* stub bullet ending "`tests/memory-sync.test.sh` does this.";
- S7c *Rules*: the bullet "**Never run `external-agent.sh` against a real model from this repo.**" with its live-run exception goes;
- S7d–S7j *One fact, one value*: the manual model rule comes back to "the developer and reviewer only, and no `model` parameter ... `plugins/glab/commands/ship.md`);"; the reviewer's verdict lines keep `reviewer.md`, the manager and `ship.md` and lose the validator and E34; the session effort names "`glab:manager` Rules 0d and 5" and loses the skill; every external-only entry goes (the list in *Findings*, *One-fact pairs*). The other entries are not touched: the round cap, the ask-conditions, the fallback ("every agent and command"), the hook events, the time limits, the names, the session-start rules, the component counts, the plan lifecycle.
Kept: line 96 ("an external CLI such as `aws`") and line 267 (D8).
Verify: C2, C3, C4, C5; `diff <(git show 7139e62^:AGENTS.md | sed -n '/^## Gates/,/^## Rules/p') <(sed -n '/^## Gates/,/^## Rules/p' AGENTS.md)` prints nothing.

**S8 — `README.md`** (S8a–S8d): the `glab` row of the plugin table loses `, glab:external-agents` and " · a script, `external-agent.sh`, that runs external agents — ... or Codex's default"; *Requirements* loses everything from "External agents in `glab` (`glab:external-agents`)" through "The developer role has been tested against a stub, and its sandbox offline with `codex sandbox`." (lines 35–139, with the blank line before them), so it ends at "macOS is not supported." and `## Install` follows; the `tests/` row reads "Stub-based test for `memory-sync.sh`".
Verify: C2, C3, C5; the diff against `7139e62^` shows only the effort sentence and the `plan/`/`docs/specs/` text of `fed95f9`.

**S9 — the gates and checks after**, below, pasted into `plan/remove-external-agents/result.md` with the coverage list.

## After — the gates as they will read

`export TMPDIR=/data/tmp/claude`. These are the blocks `AGENTS.md` *Gates*
holds after S7:

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh

Green: three `rc=0` lines; `rc=0` and no findings; every line `ok`, last line `PASS 35/35`.

Then the plugin block as `AGENTS.md` *Gates* has it after S7. It is the
current block without the `Not yet shown: any reply from a DeepSeek model`
line, run under a new `CLAUDE_CONFIG_DIR`, as the block itself does. Green
(seen in the dry run):

    ✔ Validation passed   (three times)
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
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
    rc=1

`Skills (14)` must name exactly the 14 above, with no `external-agents`.

### Discriminating checks

Run from the repository root. Each one prints something different on a
half-finished tree.

**C1 — files that must no longer exist:**

    for p in plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/skills/external-agents; do test ! -e "$p"; echo "$p gone rc=$?"; done
    git ls-files -- plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/skills/external-agents | wc -l

Green: three `gone rc=0` lines, then `0`. A directory left behind with an
untracked file in it gives `rc=1`.

**C2 — the narrow search, which must return exactly one line:**

    git grep -n -i -E 'external[- ]agents?|external (reviewer|developer)|opencode|codex|deepseek|kimi|\bglm\b|grok|slirp4netns|bwrap|bubblewrap|glab-external|use balance|exit[- ]8|any reply from a' -- . ':!docs/specs/' ':!plan/'

Green: exactly one line, `AGENTS.md:<n>:  `external-agents.md`: how the area works now, the decisions that still` (the `plan/` rule, D8). Any other line is a passage left behind. `plan/` is left out because this folder names everything it removes, and `docs/specs/` because it is the record. Git history is not searched.

**C3 — the broad search of the task, which must return exactly seven lines:**

    git grep -n -i -E 'external|opencode|codex|external-agent' -- . ':!docs/specs/' ':!plan/' | cut -d: -f1,3- | cut -c1-60

Green: the six kept lines and the C2 line — `AGENTS.md` (`external CLI** such as \`aws\``), `AGENTS.md` (`` `external-agents.md` ``), `plugins/glab/agents/integrator.md` (external dependencies), `plugins/glab/skills/bootstrap/SKILL.md` (external auditor), `plugins/glab/skills/manager/SKILL.md` three times (external API, external dependencies, external auditor). `| wc -l` → `7`.

**C4 — no reference to the manager's Rule 6:**

    git grep -n -E "Rule 6|Rules [^.;]*\b6\b|^ *6, " -- AGENTS.md README.md host.example.md plugins/glab ':!plugins/glab/skills/security/SKILL.md'; echo "rc=$?"

Green: no line, `rc=1`. On the tree at `6b2a024` it prints eight lines (manager 71, 157, 189; `AGENTS.md` 223, 228, 235, 250; the removed skill's line 26). `glab:security` has a Rule 6 of its own and is left out.

On the untouched tree, measured while planning: C1 prints three `gone rc=1` and `8`; C2 prints 709 lines; C3 prints 692. So each check tells the tree before from the tree after, and a tree with only S1 done still fails C2, C3 and C4.

**C5 — the edited files are the dry run's:**

    sha256sum AGENTS.md README.md plugins/glab/skills/manager/SKILL.md plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/.claude-plugin/plugin.json

Expected, from `edits.py` run on an export of `HEAD` at `6b2a024`:

    82a1e98626bd7febcacdf838806987f5dfc0070fd59a5f32c3c6c2b4197d1ab4  AGENTS.md
    eb03a698c20ef867c9d252467908ad4546038f26747bd95a79b93fa4a788c7bb  README.md
    c585c94386745489555a8601de5b1d7380813cea8d299dd7f2e91be77ad2ab78  plugins/glab/skills/manager/SKILL.md
    4b6370e4e013ca4e6a41804ce4fe03c5d751ba2539d759a134f989d71677803e  plugins/glab/commands/develop.md
    5cd07a1e3eb265d959832fd4e0c909b9825e8ef56a953774e61ddcebc661af5c  plugins/glab/commands/review.md
    34e59254580cbf6259e3e6879c6218bdf19382b71826d2aaa4241e6722737f0b  plugins/glab/commands/ship.md
    85a832d7bf9635b66a774a26ce51e87a619f8dfd759e2543ee8710396478f885  plugins/glab/.claude-plugin/plugin.json

A mismatch is a difference from the plan's edits. Show it with `diff` against
the dry run (rerun `edits.py` on a fresh `git archive 6b2a024` export), and
either remove it or report it as a change to the plan.

**C6 — nothing else changed:**

    git status --short -uall | grep -v -E '^\?\? plan/'

Green: exactly the eight `D` paths of S1 and `M` for the seven files of C5,
fifteen lines, and nothing under `docs/specs/`. `plan/SESSION-HANDOFF.md` stays
untracked and unchanged.

## Tests and coverage (`AGENTS.md` *Tests*: a list, not a number)

- No test is added. `tests/external-agent.test.sh` and its 86 cases go with
  the script they tested (S1). This is the mechanical consequence the change
  allows: the code they covered no longer exists.
- S1: covered by C1, the `Skills (14)` line, and the three-script shell gates.
- S2: `jq -r .version` and C5.
- S3–S8 are Markdown, and Markdown has no gate (`AGENTS.md` *Gates*). They are
  covered by C2, C3, C4, C5, C6 and the per-step diffs against `7139e62^`. No
  case runs a session against the edited text, and that is accepted: it is
  prose for sessions, and the searches show that nothing which names the
  removed parts is left.
- `memory-sync` is not touched. Its suite (`PASS 35/35`) shows the shared
  gates still run.

## Not in scope

- `docs/specs/*` (D3, D16); `plan/SESSION-HANDOFF.md`; any host's leftovers
  (D10); the user's own auto-memory entry about Codex (*Findings*, *Inferred*:
  the user's file, outside the repository).
- Any wording change outside the removed passages. A gap noticed on the way
  goes to `plan/remove-external-agents/follow-ups.md`.

## Record

After the push, Stage 8 updates three specs. Its primary area is
`docs/specs/external-agents.md`.

- **`docs/specs/external-agents.md`** — a short note at the top: removed in
  `glab` 0.8.0 by `<removal commit>`, because the user ended the experiment
  ("let's remove external subagents implementation, experiment failed"); the
  last commit on `origin/main` that has the code, checked as D3(b) says
  (`6b2a024` unless something landed first); how to read the code back
  (`git show <sha>:plugins/glab/scripts/external-agent.sh`,
  `git ls-tree -r --name-only <sha> -- plugins/glab/skills/external-agents/`);
  and what a 0.7.x host can still hold (D10). The body stays as the record of
  how it worked, as of that commit: *How it works now* is marked as of that
  commit, not rewritten. Every open follow-up (60 at `6b2a024`) is closed with
  "closed: removed with the feature in glab 0.8.0
  [remove-external-agents/plan.md D2]" rather than dropped. One that still
  applies outside external agents moves to the spec of its area, under its
  own tag. *Incidents* and *Measurements* are kept as they are. The *Records*
  line names this change.
- **`docs/specs/marketplace.md`** — `glab` 0.8.0; the component counts
  `Skills (14)`, six skills and eight commands (today lines 30–31, 63, 166);
  the gates: three scripts, one stub suite at `PASS 35/35`; no `PASS 86/86`,
  no `bwrap`/`slirp4netns`/`python3` need, no DeepSeek gate line (today lines
  55–66); *Layout* without the script; *Rules* without the live-run
  exception; *Tests* without the `opencode`/`codex` stub; the removed and
  trimmed *One fact* entries (S7d–S7j); the open follow-up
  `[feature-docs-specs/follow-ups.md 8]` re-read; the *Records* line.
- **`docs/specs/workflow.md`** — `glab:manager` without Rule 6, Rule 5 without
  the external reviewer and developer, Rule 0d without the Codex mapping, the
  handoff and record lines for Claude only; `/glab:develop`, `/glab:review`
  and `/glab:ship` without the external paths; Stage 5 and the parallel review
  without them; the open follow-ups
  `[feature-docs-specs/result-SM.md 3]` (it re-reads `PASS 86/86`, the
  allowlist and DeepSeek's end date, all gone now) and
  `[subagent-effort/record.md round-2-ultra]` re-read and closed or carried
  as they now stand; the *Records* line. The spec has 86 hit lines today.
- Stage 8 also decides whether `AGENTS.md`'s `plan/` rule still lists
  `external-agents.md` once the record has run (D8). Changing that is an
  `AGENTS.md` change, not a spec change, so it goes back through the
  pipeline.
- Then, under `AGENTS.md`'s `plan/` rule, the manager session removes
  `plan/remove-external-agents/` in a `docs(repo)` commit once it is on
  `origin/main`.

---

# Findings

(The Write tool refused `findings.md`, so this section holds that file's content.)

State read: `HEAD` = `origin/main` = `6b2a024`. The only untracked path is
`plan/`, which holds `plan/SESSION-HANDOFF.md`; that file is not touched.

## Baseline at 6b2a024 (proven)

The gates of `AGENTS.md` *Gates*, run as written with
`TMPDIR=/data/tmp/claude`:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0                                   (shellcheck)
    memory-sync suite: exit=0, 35 lines `ok `, nothing else but PASS 35/35
    external-agent suite: exit=0, 86 lines `ok `, nothing else but PASS 86/86

    ✔ Validation passed   (x3)
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

Every line is green as `AGENTS.md` *Gates* defines it. The config directory
was removed again: `ls "$TMPDIR" | grep -c claude-config` printed `0`.

## Scope surface — the search

The pattern is `external|opencode|codex|external-agent`, case-insensitive,
over every tracked file except `docs/specs/`. `git ls-files` never lists
`.git`.

Controls first:

    positive control (must be >0): grep -c -i -E '<pattern>' AGENTS.md                         -> 54
    negative control (must be 0, rc=1): grep -c -i -E '<pattern>' .claude-plugin/marketplace.json -> 0, rc=1

Per file (`git ls-files -z | grep -zv '^docs/specs/' | xargs -0 grep -c -i -E '<pattern>'`),
692 hit lines in all:

| file | hits | fate |
|---|---|---|
| `plugins/glab/scripts/external-agent.sh` | 236 | removed (S1) |
| `tests/external-agent.test.sh` | 214 | removed (S1) |
| `plugins/glab/skills/external-agents/SKILL.md` | 97 | removed (S1) |
| `plugins/glab/skills/external-agents/profiles/kimi.md` | 5 | removed (S1) |
| `plugins/glab/skills/external-agents/profiles/glm.md` | 5 | removed (S1) |
| `plugins/glab/skills/external-agents/profiles/deepseek-pro.md` | 5 | removed (S1) |
| `plugins/glab/skills/external-agents/profiles/deepseek-flash.md` | 5 | removed (S1) |
| `plugins/glab/skills/external-agents/profiles/default.md` | 4 | removed (S1) |
| `AGENTS.md` | 54 | 52 removed or reworded, 2 kept (S7) |
| `README.md` | 32 | all removed or reworded (S8) |
| `plugins/glab/skills/manager/SKILL.md` | 25 | 22 removed or reworded, 3 kept (S6) |
| `plugins/glab/commands/develop.md` | 5 | all (S3) |
| `plugins/glab/commands/ship.md` | 2 | all (S5) |
| `plugins/glab/commands/review.md` | 1 | all (S4) |
| `plugins/glab/skills/bootstrap/SKILL.md` | 1 | kept |
| `plugins/glab/agents/integrator.md` | 1 | kept |
| the other 25 tracked files | 0 | — |

571 of the hits sit in the eight removed files and 121 in the eight files that
stay. These have no hit: `host.example.md`,
`plugins/glab/scripts/manager-bootstrap.sh`, `plugins/glab/hooks/hooks.json`,
both `plugin.json`, the marketplace, and the whole `memory-sync` plugin.

A second search looked for words tied to the feature that the first pattern
misses, keeping only lines without `external|opencode|codex`:
`rule 6|backend|exit[ -]8|deepseek|kimi|glm|grok|slirp|bwrap|python3|allowlist|use balance|announce line|profile|state root|...`.
It found further hits only in `AGENTS.md` (37, 38, 63, 172, 207, 208, 222,
223, 244, 255) and `README.md` (38, 45, 47, 55, 63, 74, 128, 130, 132, 138).
Each one sits inside a passage the plan already removes. Its other hits are
unrelated and stay: `profile` and `backend` in `memory-sync` (`AWS_PROFILE`,
"a real backend"), `glab:manager` 119 ("backend owns the API contract"),
`glab:bootstrap` 84, and `glab:security`'s own *Rule 6*.

### Every hit in the files that stay

`AGENTS.md` (54):

| lines | class | step |
|---|---|---|
| 13 | reword: *Layout* drops `scripts/external-agent.sh` | S7a |
| 28, 29, 31 | remove from the gate block: the script and its test in the `bash -n` loop and in `shellcheck`, and the suite line | S7b |
| 34, 35, 36 | remove: the gate prose on the stub `opencode`/`codex`, `bwrap`, `slirp4netns`, `python3` listeners | S7b |
| 82 | remove: the green bullet for the pinned DeepSeek sentence | S7b |
| 96 | **keep**: "fake an external CLI such as `aws`" uses the word in its general sense, about `memory-sync`'s stub | — |
| 97, 98 | remove: the *Tests* bullet's `tests/external-agent.test.sh` clause | S7b |
| 111, 112, 114, 116, 118, 120, 121, 124 | remove: the *Rules* bullet "Never run `external-agent.sh` against a real model", with its live-run exception | S7c |
| 163 | reword: the manual model rule loses "(an external one: ...)" | S7d |
| 167, 168 | remove: "and the same rule for external agents in" the skill | S7d |
| 169, 171, 174, 175, 176, 177, 179, 180, 181 | remove: Codex `--model`, the record line and its `<backend>:<model>` token, `codex` alone, the exit codes | S7e |
| 186–189, 191, 192, 194, 196–198, 200, 201, 204, 209 | remove: the validator and E34 from the verdict entry, the allowlist, Codex's id check, OpenCode's sandbox, where agents live, the CLI paths, "Use balance", what OpenCode and Codex send, Grok, the exit-8 `send` | S7f |
| 220, 224, 227 | remove: the fallback "which the first message of `external-agent.sh` also states", the guarantees per backend, the Codex sandbox check, the Codex effort rule | S7g |
| 237 | remove: the skill from the session-effort entry | S7i |
| 241, 247, 248, 249 | remove: the Codex data note, the host and developer first messages, the external developer, the change report, the refused developer | S7j |
| 267 | **keep**: the `plan/` rule's list of area specs names `external-agents.md`. The spec stays as a record, and this change's own Stage 8 updates it (D8) | — |

The lines between hits in one passage (172, 207, 208, 222, 223, 228,
234–235, 244, 250–257, ...) go with that passage. `edits.py` cuts whole
passages.

`README.md` (32):

| lines | class | step |
|---|---|---|
| 9 | reword: the `glab` row drops `glab:external-agents` and the `external-agent.sh` clause | S8a, S8b |
| 35, 36, 37, 40, 41, 44, 46, 49, 51, 56, 57, 58, 67, 72, 76, 81, 84, 86, 90, 92, 93, 95, 98, 99, 125, 127, 135, 136, 137, 139 | remove: the whole external-agents part of *Requirements*, lines 35–139. That includes line 130, the sentence the gate pins (`Not yet shown: any reply from a DeepSeek model`) | S8c |
| 297 | reword: the `tests/` row names `memory-sync.sh` only | S8d |

`plugins/glab/skills/manager/SKILL.md` (25):

| line | class | step |
|---|---|---|
| 71 | reword: Rule 0d drops the Codex and OpenCode effort sentence | S6b |
| 129 | remove: the Rule 5 paragraph that names the external reviewer and developer | S6c |
| 132 | reword: *Carry it* drops the external names and the external dispatch sentences | S6d, S6e |
| 134 | reword: *These two roles only* drops "Only the reviewer, on either backend, ..." | S6f |
| 136 | reword: *Record it* drops the external and Codex record lines and the Codex-only effort sentence (D5) | S6g |
| 137 | reword: *Name it* drops the external handoff-line formats | S6h |
| 139 | reword: *Without subagent dispatch* drops the external-reviewer sentence | S6i |
| 148, 149 | remove: the dispatch table's two external rows | S6j |
| 155 | reword: *Check what comes back* drops the exit-8 sentence | S6k |
| 157, 159, 161, 164, 165, 166 | remove: all of Rule 6, lines 157–168, including the lines without a hit (160, 162, 163, 167) | S6a |
| 189 | reword: the pipeline keeps "The effort is the level you passed." and drops the Codex/OpenCode clause (D6) | S6l |
| 225, 226 | reword: the parallel review bullet ends at "that role." | S6m |
| 258 | reword: the no-dispatch bullet drops the external-reviewer sentence | S6n |
| 279 | **keep**: "reimplements a documented external API" is about vendor APIs, unrelated | — |
| 401 | **keep**: "the external dependencies (database, queue, cache)" is Stage 4 | — |
| 412 | **keep**: "The reviewer is an external auditor" is the reviewer's stance | — |
| 414 | reword: Stage 5 drops "An external reviewer runs through ..." | S6o |
| 456 | remove: the *never* bullet "Start an external agent the user did not ask for, ..." | S6p |

The commands and the rest:

| file:line | class | step |
|---|---|---|
| `commands/develop.md:2` | reword: the description drops ", or one external Codex developer ..." | S3a |
| `commands/develop.md:8` | reword: drops ", or the external developer ... through `glab:external-agents`" | S3b |
| `commands/develop.md:20` | reword: drops the external-developer sentence | S3c |
| `commands/develop.md:44` | remove: the external developer dispatch bullet | S3d |
| `commands/develop.md:52` | remove: the *An external developer first* block, lines 52–58 | S3e |
| `commands/review.md:8` | reword: drops the sentences on the external reviewer and on OpenCode's and Codex's targets | S4 |
| `commands/ship.md:16` | reword: drops "If I named an external reviewer instead, ..." | S5a |
| `commands/ship.md:28` | reword: drops the exit-8 `send` sentence | S5b |
| `skills/bootstrap/SKILL.md:110` | **keep**: "an external auditor gets the target" is the reviewer's stance | — |
| `agents/integrator.md:3` | **keep**: "brings up the external dependencies it needs" is Stage 4 | — |

## Call sites (proven)

The search is `git ls-files -z | grep -zv '^docs/specs/' | xargs -0 grep -n -F 'external-agent.sh'`,
outside the script itself, plus a search for `source`/`.`/`bash`/`exec` of it.

- **Nothing sources or executes the script at runtime.**
  `plugins/glab/hooks/hooks.json` runs only `manager-bootstrap.sh`. Every
  invocation is text in the skill (`SKILL.md:49, 63, 127, 133, 140`,
  `"<this skill's base directory>/../../scripts/external-agent.sh" ...`),
  which the manager follows when Rule 5 or Rule 6 sends it there.
- **Tests:** only `tests/external-agent.test.sh`, which takes the script's
  path as `$1` (line 25). `tests/memory-sync.test.sh` has no reference.
- **Gate lines:** `AGENTS.md:28, 29, 31` (the `bash -n`/`test -x` loop,
  `shellcheck`, the suite), and `AGENTS.md:63`, which pins the README sentence
  that came from the script's probe.
- **What sends a session to the skill:** `glab:manager` Rule 5 (lines 129,
  132, 136, 137, 139, 148, 149, 155), Rule 6 (157–167), *The pipeline* (189),
  parallel review (225–226), the no-dispatch section (258), Stage 5 (414),
  *never* (456); `/glab:develop` (2, 8, 20, 44, 52); `/glab:review` (8);
  `/glab:ship` (16, 28).
- **The profiles directory** is read only by the script. Outside the removed
  files, only `AGENTS.md:188` and `:247` name it, and S7 removes both.

Each caller needs the script only on the external path, which runs only when
the user named an external reviewer, developer or agent. The Claude path
never touches it. Removing the script together with every caller leaves no
caller behind.

## One-fact pairs the removal touches

The entries of `AGENTS.md` *One fact, one value*, as they read now, and what
happens to each:

| entry | fate |
|---|---|
| review round cap (`reviewer.md`, `ship.md`, manager, bootstrap) | **unchanged**. The removed text holds a `round 1/3` example (manager:137, removed); the cap itself (`Maximum 3 review rounds`, manager:416; `ship.md:32`) stays |
| missing-`AGENTS.md` fallback, "every agent and command" (line 144) | stays |
| the same fallback "which the first message of `external-agent.sh` also states" (219–220) | **removed** (S7g). That second statement goes with the script; the fact stays in the first entry |
| manual model rule (162–168) | **reworded** (S7d) back to its pre-`7139e62` text: the developer and reviewer only. The external parenthesis and the skill go |
| reviewer's verdict lines (183–186) | **file list shrinks** (S7f). "The validator in `external-agent.sh`, and case E34 of its test" go; `reviewer.md`, the manager and `ship.md` stay. The fact stays |
| session effort (230–240) | **file list shrinks** (S7h, S7i): "Rules 0d and 5" replaces "Rule 0d, Rules 5 and 6", and the skill goes |
| what each plugin holds (153–154) | stays. Its values change in this commit in all three files: `AGENTS.md` *Gates* (S7b), the `README.md` row (S8a, S8b), the hooks files (unchanged) |
| Codex `--model`, record line and token, `codex` alone, exit codes, allowlist, Codex id check, OpenCode sandbox, where agents live, CLI paths, "Use balance", what OpenCode/Codex send, Grok, exit-8 `send`, the live-probe sentence, guarantees per backend, Codex sandbox check, Codex effort rule, Codex data note, first messages, external developer, change report, refused developer | **removed**. In this commit, every file that stated one of them is either removed or loses the statement |
| plan lifecycle (210–218) | unchanged |

## What the target text is (proven by a dry run)

The external text came in with `7139e62`, `9108ac7`, `5321d76`, `3965622`,
`33a28df` and `abda43a`. `fed95f9` (Stage 8) and `abda43a` (session effort)
also changed these files in ways that stay. `plan/remove-external-agents/edits.py`
holds every text edit as an exact-once replacement. It was run against an
export of `HEAD` (`git archive HEAD | tar -x`), with the eight files then
removed. It printed `ok` for all 39 edits and `script rc=0`, and then:

- `git show 7139e62^:<file> | diff - <edited>` for `develop.md` showed only
  the `the effort, always` bullet (`abda43a`). For `review.md` it showed only
  the effort sentence. For `ship.md` it showed only the effort sentence,
  `BLOCK: 1 issue` (`5321d76`) and the committer's effort. For `glab:manager`
  it showed only Rule 0d, Stage 8, and the record and effort hunks of
  `fed95f9` and `abda43a`. For `README.md` it showed only the effort sentence
  and the `plan/`/`docs/specs/` text of `fed95f9`. For `AGENTS.md` it showed
  only the *Layout* `docs/specs/` lines, the verdict, plan-lifecycle and
  session-effort entries, and the `plan/` rule. The *Gates* and *Tests*
  sections came out byte-identical to `7139e62^`'s.
- The *After* gates printed three `rc=0` lines, shellcheck `rc=0`,
  `PASS 35/35`, three `✔ Validation passed`,
  `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`,
  `Agents (5)`, `Hooks (1)  SessionStart`, and the other lines as in the
  baseline, without the DeepSeek pair.
- The C2 search returned only `AGENTS.md:168`, the `plan/` rule line naming
  `external-agents.md`. The C3 search returned only that line and the six
  kept lines. The C4 search returned nothing outside `glab:security`.

The sha256 of each edited file from that run is in C5. The scratch export was
removed afterwards, along with every other scratch file of this planning run:
`ls /data/tmp/claude | grep -c '^ra-'` printed `0`.

## Other facts (proven)

- **Rule numbering.** `glab:manager`'s headings run Rule 0, 0b, 0c, 0d, 1–5,
  6, then *Know the gates*, so Rule 6 is the last numbered rule. Every
  reference to it (`git grep -n -E "Rule 6|Rules [^.;]*\b6\b|^ *6, "`) sits
  in manager 71, 157, 189, in `AGENTS.md` 223, 228, 235, 250, and in the
  removed skill. Removing it renumbers nothing.
- **Nothing untracked or ignored sits under the removed paths.**
  `git status --short --ignored -uall -- plugins/glab/skills/external-agents plugins/glab/scripts tests`
  printed nothing. The eight files are tracked and clean, so each one can be
  recovered from `6b2a024` (`git show 6b2a024:<path>`).
- **The removed files hold no marker.** `grep -n -E '\b(TODO|FIXME|HACK|NOTE|XXX)\b'`
  over the eight files found none. What they record as measured or observed
  is also in `docs/specs/external-agents.md` (*Measurements*, *Live runs*,
  *Incidents*), which stays: the Codex Unix-socket and write measurements, the
  live probe of 2026-10-17, and the "singular" verdict note. The files stay
  readable at `6b2a024`.
- **`plugin validate` does not see dangling prose.** A throwaway copy of
  `plugins/` with only the skill directory and the script removed, every
  `glab:external-agents` mention still in place, printed
  `✔ Validation passed` and `Skills (14)`. The validator and the count cannot
  tell a finished tree from a half-finished one; C2 to C5 can.
- **`plugin.json` and the marketplace say nothing of external agents** (no
  hit). Only `glab`'s `version` changes, from `0.7.2` to `0.8.0`. No other
  tracked file outside `docs/specs/` states the version:
  `git grep -n -E '0\.7\.[0-9]|0\.8\.0' -- . ':!docs/specs/'` found only
  `plugin.json:3`.
- **`README.md` line 228** ("seven skill directories under `skills/`") is the
  old copy install's list. It includes `sync-memory` and never had
  `external-agents`, so it stays.

## Inferred

- A user who names an external reviewer or developer after 0.8.0 meets Rule
  5's existing sentence "A name the parameter does not take: say so, and ask
  which of the four the user means". Inferred from the text; no session was
  run.
- A host that ran 0.7.x can hold leftovers the plugin never removed:
  transcripts under `$TMPDIR/glab-external-agents/` from an agent that was
  never stopped, and Codex's own sessions under its home, which the README
  says `stop` does not remove. Inferred from `README.md` 81–82 and 92–94; no
  host was checked.
- The user's own auto-memory, outside this repo, has an entry that keeps
  Codex as an outside analyst, reviewer and developer "via the skill". After
  this change that entry points at a skill that no longer exists. It is the
  user's file, and this change does not touch it.

## Candidate boundaries

- **Chosen — remove the files and edit every caller back to its text before
  the feature, keeping the later changes that are not about external
  agents.** One commit. The dry run shows the result is exactly that.
- **Rejected — `git revert` of the feature commits.** `fed95f9`, `5321d76`,
  `3965622` and `abda43a` touch the same paragraphs; `abda43a` rewrote Codex
  effort text inside Rule 5 and *The pipeline*. A revert would conflict, and
  would take Stage 8 and the session effort out along with the feature.
- **Rejected — keep the script, unadvertised or marked deprecated.** The user
  chose to remove all of it.
- **Rejected — a "removed in 0.8.0" note in `README.md` or the payload.** The
  user said remove all of it, and such a note is the one line C2 would have
  to let through. The record goes in the spec (D10).
- **Rejected — move Rule 6's general points (the reply is untrusted, stop
  what you start) into another rule.** Nothing else uses them once external
  agents are gone, and it would add new text under a removal.
