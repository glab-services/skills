tier: normal — payload Markdown and one manifest version only; no schema, data, stored or wire format, auth, secrets or money (no script parses an agent report: F13)

# flow-cheaper-rounds — cheaper rounds in the glab pipeline

Six changes to `glab:manager` and `glab:plan-first`, and to every file that
states the same facts, to cut the token cost of the pipeline:

1. round caps of 2 (+1 on a critical or high finding) for Stages 1b, 3 and 5;
2. every round goes to a new agent, never a resumed one;
3. re-checks of Stages 1b and 3 look only at the delta;
4. a narrower planner search (call-site audit for changed methods only);
5. explore once (mapping files, or the planner explores, not both);
6. the manager measures its own context and suggests `/compact` or `/clear`;
   the user does it.

Under `glab:manager` this plan stops here: it is not implemented by its
author (the `glab:plan-first` seam). Base: `7df69a8` on `main`.

## Decisions

- D1 tier normal — payload text, the `glab` manifest version and `AGENTS.md`; no full-tier trigger (*Pick the tier*). The new `severity:` line in two report templates is a prompt-level contract between agents: nothing parses it (F13), and the verdict lines `/glab:ship` matches whole keep their form.
- D2 Round caps — the user's decision, relayed by the manager: "set 2 and only one more if something critical is behind". Stage 1b, Stage 3 and Stage 5 each run at most 2 rounds at every tier where the stage runs; a third only when round 2 returned a `critical` or `high` finding, recorded first as `- round 3: <stage> — <severity> <finding as file:line or step id, and its claim>` under `## Decisions`; nothing past round 3. Normal tier still has no Stage 3. It supersedes `[bug-reviewer-findings/questions.md Q3]` ("3 everywhere"), `[feature-plugin-marketplace/questions.md S3]` and `[sync-local-edits/result-followups.md D11]` (the 1b *Leaves on* wording).
- D3 "critical **or high**", not "critical" alone — the manager's choice: the real case that needed a third round was rated high. The user may overrule it; then only the word list in D2's files changes.
- D4 The severity is given by the agent that reports the finding — `glab:reviewer`, `glab:analyzer` — as a `severity:` line on each finding, on `glab:audit`'s four *Severity Levels*, and never re-ranked by the manager. `review.md:10` and `ship.md:18` already say "do not re-rank its severities", yet the reviewer's template (`reviewer.md:81-84`) has no severity (F3); this gives the round-3 condition a value someone other than the manager sets.
- D5 Reviewer round 2: it is the last round unless the reviewer reports a `critical` or `high` finding in it; then it answers `BLOCK: <n> issues` and round 3 may run, which is the last with no exception. The verdict strings do not change (`AGENTS.md` *One fact*: the verdict lines).
- D6 What happens when a stage ends its last round without passing stays what it is today for that stage and tier: 1b full → the user ("needs a design"); 1b normal → after round 2 a new planner amends once more and the plan goes on, `PLAN WRONG` the backstop; after a round 3, at every tier → the user; Stage 3 → the user with the three honest resolutions; Stage 5 → the last-round answer goes to the user. Only the round counts change.
- D7 Every round is a new agent: a plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a Stage 8 record fix — never a resume or a follow-up to the previous agent. Wider than the brief's two cases (planner amendment, developer fix) so that the rule has no unexplained gap; the cost reason (F1) is the same for each. Rule 5's report check (missing fields only) stays the one resume (`[feature-model-switch/plan.md D22]` binds). It goes in Rule 2, the context budget, because its reason is cost.
- D8 A round's findings travel in the next agent's dispatch, copied as the agent returned them — the one input not on disk. The manager writes no findings file (Rule 1: it authors no content), and neither the analyzer nor the reviewer can (read-only; the reviewer gets no slug).
- D9 A fix-round developer adds `## Fix round — <stage> round <n>` to `result.md` and does not overwrite it; the overwrite rule (`developer.md:68`) stays for a re-dispatch of the same steps. Otherwise a fresh fix agent erases the record of the round before (the incident "a re-dispatch overwrites `result.md`", `docs/specs/workflow.md` *Incidents*).
- D10 Stage 1b delta: before dispatching the amendment the manager copies `plan.md` (and `findings.md` when there is one) to `plan.r<n>.md` (`findings.r<n>.md`), `<n>` = the round that checked it; round `<n+1>` reads `diff -u plan.r<n>.md plan.md`. A copy, not git: the plan folder is untracked while it is planned (`?? plan/flow-cheaper-rounds/plan.md` in this tree), and a snapshot of a gitignored `plan/` would be silently empty. Proven in a throwaway directory (F8). The copies stay in the folder (`AGENTS.md`: no untracked file under `plan/` is removed) and are committed with it; the record takes items from the current file, not the copy.
- D11 Stage 3 delta: before each analyze round, round 1 included, the manager snapshots the tree into a tree object through a temporary index (`GIT_INDEX_FILE=<new path> git add -A && git write-tree`); round `<n+1>` gets both tree ids and runs `git diff <old> <new>`. Proven: it catches tracked, staged, untracked and deleted files, leaves the real index and `git status` unchanged, skips ignored files, and gives the same id for the same tree (F8). Ignored files are not in a snapshot, so a path the fix round's `files:` line names that the delta does not show is checked whole; a lost tree id means that round runs whole.
- D12 An empty delta is a stop, not a pass: `diff` and `git diff --quiet` exit 0 when nothing changed. Before round `<n+1>` the manager checks the delta is not empty; an analyzer handed an empty one reports `BLOCK: target unresolved`.
- D13 Review rounds are not changed. The brief says they stay whole-target; note that the payload already narrows each review round after the first to what changed since the last one (`reviewer.md:94`, `ship.md:32`), and this plan leaves that text exactly as it is. If "whole-target" meant something else, that is the manager's to raise.
- D14 Planner search: the full call-site audit covers methods the plan **changes**; for a method it only **calls**, the precondition the new call site must meet and how the plan meets it; a file it only depends on is listed by path and not read in full. Consistent with `glab:security` Rule 7, which binds before "changing any existing function's signature, return values, error cases, or timing" (`security/SKILL.md:72`), and with `reviewer.md:55` and `developer.md:40` (both: before a change). `glab:manager`'s checklist item 3 says the same.
- D15 Mapping files are `plan/{slug}/map-<area>.md`, not `findings-<area>.md`: in this session the Write tool refused a subagent's `findings-probe.md` and `findings.md` ("Subagents should return findings as text, not write report files") and accepted `map-probe.md` (F9) — the same refusal as two recorded incidents (`subagent-effort`, `remove-external-agents`).
- D16 Mapping is the manager's call per task. When it dispatches mapping agents, the planner is told the files, starts from them, and reads code only for the gaps it names; without them, the planner explores itself; never both over one area. The analyzer reads the map files with the plan, and the developer the ones the plan cites, because a plan step may cite one.
- D17 Context check (item 6, with the user's amendment): the manager measures its context with one inline command in `glab:manager`, not a script under `plugins/glab/scripts/`. A skill's text cannot name the installed plugin's directory from the model's shell (`CLAUDE_PLUGIN_ROOT` is documented for hooks; that it reaches a skill's Bash is UNVERIFIED), and a new script would join the `AGENTS.md` shell gates and need a test under *Tests*. The inline command is verified the way `AGENTS.md` verifies Markdown: run in a throwaway directory against fake transcripts (F15).
- D18 The command finds the transcript by `CLAUDE_CODE_SESSION_ID` under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/*/`, requiring exactly one match, instead of rebuilding the directory name from the working directory: it needs no knowledge of how Claude Code turns a path into a directory name (only `/` → `-` was shown, F15), and it works the same from a worktree. It prints one number and nothing else from the transcript; every failure exits 1 with a fixed message and never prints `0`, `0k` or `null` (F15).
- D19 Thresholds: inside a task, suggest `/compact` at the first handoff line at or past **300k**, and again each time the context has grown by another **100k** since the last suggestion. 300k is where a resumed agent's round already cost several times a fresh one (F1: rounds restarting at 300–450k), and about half the bad session's 648k peak; the 100k step keeps a declined suggestion from repeating on every line. At a task boundary — after the push of the Stage 8 record, or after Stage 7 when there is no plan folder — suggest `/clear` and a new session whatever the size.
- D20 Fallback when the check cannot run (`CLAUDE_CODE_SESSION_ID` unset, no single transcript, no usage, `jq` missing — any non-zero exit): say so once in the session, then suggest `/compact` after every **15** dispatches since the session started or was last compacted, and after any stage that took more than one round. 15: the brief's figure; one normal-tier task at the new caps dispatches about 8–12 agents (plan, 1–2 plan checks, develop, 1–2 reviews, fix rounds, commit, record developer and analyzer, record commit), so 15 fires about once per long task — inferred from the stage list, not measured.
- D21 The handoff line gains `· context <n>k` at its end, or `· dispatches <d>` under the fallback; the manager names the number as "the last completed call's context" and never claims more precision. The manager never runs `/clear` or `/compact`.
- D22 The handoff file is the one `glab:bootstrap` step 5 reads — `plan/SESSION-HANDOFF.md` unless the repo keeps its handoff elsewhere (`bootstrap/SKILL.md:127`: "or the nearest equivalent in `plan/`"). No `glab` step commits it. `glab:bootstrap` and `manager-bootstrap.sh` do not change for item 6: step 5 already names the file, and the hook text carries no handoff, compaction or context text (F16), so the session-start pair of *One fact* is untouched.
- D23 Rule 5 carries the model into each fix round too (a new agent no longer inherits it from a resume): Rule 5's carry bullet and `develop.md:42`.
- D24 The handoff line's `max` is the stage's cap: `2`, or `3` once the round-3 line is written; a develop line counts its fix rounds against the cap of the stage whose findings it fixes; Rule 5's example becomes `round 1/2`.
- D25 `AGENTS.md` *One fact*: the review-round-cap entry becomes "the round caps" (all three stages, the same four files; it closes `[sync-local-edits/follow-ups.md 18]`); new entries: the severity levels, every round a new agent, the mapping and round-copy file names, the handoff file.
- D26 `glab` `0.8.0` → `0.9.0`: the change alters the pipeline's contract (round caps at both tiers, two report templates, the reviewer's round-2 rule, a new handoff-line field), a feature, and features have raised the minor before 1.0 (`0.5.0`, `0.6.0`, `0.7.0`, `0.8.0`). Nothing is removed, so no `!`. `memory-sync` is not touched and keeps `0.1.0`.
- D27 One commit, `feat(skills): cap check rounds at two and run each round on a new agent`, with the plan folder: the *One fact* rule wants each fact's files in one commit, and the six items cross the same files (manager, plan-first, the agents); split commits would each need their own version bump. The manager may split it.
- D28 Out of scope, recorded as follow-ups (*Follow-ups*): a dedicated `glab:planner` agent; splitting implementation steps out of `glab:plan-first`; the user-level copies under `~/.claude` (the user ports them); the "cleanup glob deleted a reviewer report" incident.

The manager adds the session's `- effort:` line (Rule 0d); this planner does not know it.

## Findings

### F1 Evidence — measured by the manager, other project, not reproducible here

Total input over all turns 597M tokens: developers 49%, planners 21%, Stage 1b
plan checks 11%, reviewers 8%, mapping agents 6%. Cost grows with turns ×
context. Fix rounds sent back to the same resumed agent cost 149M, each round
restarting at 300–450k context; modelled as fresh agents ~37–64M. A Stage 1b
round 2 that re-read the whole plan cost 9.5M against round 1's 9.0M; targeted
re-check rounds cost ~40% of round 1. The planner, handed three mapping files,
re-touched 40 of its 157 paths that mapping had already read. Normal-tier plans
were run against full-tier caps ("round 1 of 3" review, "round 1 of 2"
buildability). The manager session itself: 1,054 turns, a 648k peak, 348M
tokens (~37% of the run), five tasks and one compaction. The manager proved on
its host that `CLAUDE_CODE_SESSION_ID` names its transcript and that the last
assistant entry's usage printed 142k.

Inferred, not shown: the savings each change brings; that a live session
follows the edited prose.

### F2 Where the caps are stated today (search, base `7df69a8`)

    $ grep -rnE -i 'round[s]? ?(cap|[0-9]|n/)|max(imum)? [0-9]+ (review |develop|round)|[0-9]+ rounds|round [0-9]|one (pass|round)|...|SCOPE CUT|DO NOT PUBLISH|last round|review2|review4' plugins README.md AGENTS.md host.example.md
    (and a second search for counts in words: one|two|three|four|once ... round|pass|amendment)

Every hit that states a cap or the last-round rule (fix-mode "one pass" hits
excluded):

- `skills/manager/SKILL.md` — `:135` handoff example `round 1/1`; `:136` "the round caps stay what *Pick the tier* gives them"; `:149` last-round verdicts (Rule 5 template); `:151` "does not count against the cap"; `:164` 1b *Leaves on* "one amendment at normal tier"; `:173` `round n/max`; `:187` 1b "one pass | max 2 rounds"; `:189` conformance "max 4 rounds"; `:191` review "one round | max 3 rounds"; `:238` "`review2`, and there is no `review4`"; `:325-328` 1b "Maximum 2 rounds at full tier … One pass at normal tier"; `:376-378` "Maximum 4 develop→analyze rounds … `analyze round 2/4` … at round 4"; `:395` "this stage's round cap"; `:397` "Maximum 3 review rounds at full tier. At round 3 …"; `:399` "One round at normal tier …"; `:421` Stage 8 "go back to the developer once".
- `agents/reviewer.md:92` "at most three rounds — one at normal tier"; `:98-102` the last-round verdicts.
- `commands/ship.md:32` "At most three rounds, then a decision"; `:22-27` verdict matching.
- `skills/bootstrap/SKILL.md:100` "Normal work runs a one-page plan, one analysis and one review"; `:101` points to the round caps.
- `README.md`, `AGENTS.md` (other than *One fact* `:106`), `manager-bootstrap.sh`, `commands/review.md`, `commands/develop.md`, `commands/analyze.md`: no cap stated.

### F3 No severity in any report template

`grep -rnE -i 'severit|critical|\bhigh\b' plugins/glab README.md`: the levels
exist only in `skills/audit/SKILL.md:49-56` (*Severity Levels*: Critical, High,
Medium, Low with meanings) and its template; `reviewer.md:15` "calibrate
severity to consequence"; `review.md:10`, `ship.md:18` "do not re-rank its
severities". The reviewer's finding block (`reviewer.md:81-84`) and the
analyzer's step block (`analyzer.md:60-63`) carry no severity field.

### F4 Resumes in the payload today

`grep -rn -E 'resum' plugins/glab` → `manager/SKILL.md:131` (Rule 5's version
floors), `:151` (the report check), `commands/ship.md:28` (the same check),
`bootstrap/SKILL.md:3` ("resuming parked work", unrelated). No stage says
whether a fix round is a resume or a new dispatch. `grep -rn -i -F 'new agent'
plugins/glab` → nothing (rc=1).

### F5 `result.md` on a re-dispatch

`developer.md:68`: "overwrite it on a re-dispatch rather than appending a
second copy". `developer.md:103`: the developer writes only `result.md` and
`follow-ups.md` in the folder.

### F6 Review rounds after the first are already narrowed

`reviewer.md:94`: "Every round after the first reviews only what changed since
the last one. Ask what changed and confirm it yourself." `ship.md:32`: "scope
each round after the first to what changed since the last one". Manager Stage
5 says nothing on how a later round learns what changed (follow-up FU7).

### F7 The plan check has no mode in the analyzer's file

`grep -rn -c BUILDABLE plugins/glab` → `skills/manager/SKILL.md:2`, every other
file `0`. `analyzer.md` knows `CONFORMS`, `DIVERGES`, `BLOCK` only; Stage 1b's
verdicts live in the manager's dispatch (FU5).

### F8 Delta mechanisms, proven in a throwaway repo under `$TMPDIR` (removed after)

Snapshot (D11), base commit with `a.txt b.txt c.txt .gitignore(*.log)`; then
`a.txt` modified, `new.txt` untracked, `b.txt` staged, `x.log` ignored:

    t1=4cb2e19e632aa8f250252eeead89aed93d3bb598 rc=0
    real index/status unchanged after snapshot:
    status-same
    staged-same
    t1 contents:
    .gitignore
    a.txt
    b.txt
    c.txt
    new.txt
    --- fix round: change new.txt, delete c.txt, add fix.txt
    t2=435b25c708024328763d9f27f6012d754d482d0b
    delta:
     c.txt   | 1 -
     fix.txt | 1 +
     new.txt | 2 +-
     3 files changed, 2 insertions(+), 2 deletions(-)
    quiet rc=1
    --- same tree twice gives the same sha:
    same-sha
    0          <- no temp index left behind

The snapshot function was
`idx="$TMPDIR/fcr-snap-$1.idx"; rm -f "$idx"; GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"`.
`a.txt`, changed before `t1`, is not in the delta; `x.log` is in neither tree.

Plan copy (D10):

    -2 b
    +2 b, amended        (and +- D2 y)
    diff rc=1
     plan.r1.md => plan.md | 3 ++-
    git-no-index rc=1
    identical rc=0

Not tested: a nested repository in the tree (`git add -A` would record it as
a gitlink and warn); a very large untracked directory that is not ignored
(every file is hashed). Both under *Known limits* of the record.

### F9 The Write tool and file names (this session)

`Write plan/flow-cheaper-rounds/findings-probe.md` and `.../findings.md` →
"Subagents should return findings as text, not write report files."
`Write .../map-probe.md` → created, then removed (`rm -f`, `ls` showed only
`plan.md`). Only these three names were tried; which other names the guard
refuses is not known.

### F10 Planner search today

`plan-first/SKILL.md:31-38` audits every method "you plan to change or call"
with four bullets, the fourth "whether the call site you are designing can
satisfy its preconditions"; `:85` Step 4 "the call-site review is complete for
any changed existing method". `manager/SKILL.md:256` checklist item 3: "Every
file … the change touches or depends on, by path, plus the call sites of
anything being changed. A findings file with no path list has not done this
step." `security/SKILL.md:72`: "Before changing any existing function's
signature, return values, error cases, or timing: grep every call site and
state what each one relied on." — binds on change, not on a call.

### F11 Specs read first (`docs/specs/workflow.md`, `docs/specs/marketplace.md`)

Binding and touched: `[feature-model-switch/plan.md D5]` (round caps do not
bend to the model — kept); `D22` (the one report-check resume — kept);
`[bug-reviewer-findings/questions.md Q3]` and `[feature-plugin-marketplace/questions.md S3]`
(cap 3 — superseded by D2); `[sync-local-edits/result-followups.md D11]`
(1b *Leaves on* — superseded); `D6` (after an amendment the develop handoff
re-runs the next stage — kept); `[feature-docs-specs/plan.md D27]` (record:
one fix round, then the analyzer — kept, now a new agent). Open follow-ups
this closes: `[sync-local-edits/follow-ups.md 18]` (analysis caps not in *One
fact*) and `[sync-local-edits/follow-ups.md 19]` (a normal-tier review fix
checked only by the gates, and `/glab:ship` with no normal-tier exception: now
one cap at every tier, and the fix gets a round 2). The incident that cut
"— one at normal tier —" from `ship.md` because `/glab:ship` cannot know a
tier is moot: the cap no longer depends on the tier.

### F12 Scope — every path

Changed: `plugins/glab/skills/manager/SKILL.md`,
`plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/bootstrap/SKILL.md`,
`plugins/glab/skills/audit/SKILL.md` (no text change; listed as an owner of
the severity levels in *One fact*), `plugins/glab/agents/reviewer.md`,
`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`,
`plugins/glab/commands/ship.md`, `plugins/glab/commands/develop.md`,
`plugins/glab/commands/analyze.md`, `plugins/glab/.claude-plugin/plugin.json`,
`AGENTS.md`. Depended on, read only where cited: `plugins/glab/skills/security/SKILL.md`,
`plugins/glab/commands/review.md`, `plugins/glab/commands/plan.md`,
`plugins/glab/scripts/manager-bootstrap.sh`, `README.md`,
`docs/specs/workflow.md`, `docs/specs/marketplace.md`. Not changed:
`README.md` (no cap, no handoff line, no component count changes: F2),
`manager-bootstrap.sh` (F16), `commands/review.md` (no cap; "do not re-rank"
already fits D4), `commands/plan.md`.

### F13 Nothing parses an agent report

`grep -rn -i -E 'verdict|severity|rule:|breaks when' plugins/*/scripts tests plugins/*/hooks` → rc=1;
the only scripts are `manager-bootstrap.sh`, `memory-sync.sh` and its test.

### F14 Baseline gates, at `7df69a8` with only `plan/` untracked

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    ok T35 a transfer killed before the time limit is a failure, not a timeout
    PASS 35/35
    ✔ Validation passed   (x3)
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

Claude Code `2.1.304`, `jq-1.8.1` on this host.

### F15 The context command, against fake transcripts in `$TMPDIR` (removed after)

The command of S1.16 run with `CLAUDE_CONFIG_DIR` pointing at a fake tree,
one fake transcript per case (a user line holding `SECRET=abc` in the first):

    == normal + partial last line      143k   rc=0   (142000+300+5; the broken last line skipped; SECRET not printed)
    == no usage entries                context: no usage in the transcript            rc=1
    == 7 tokens                        1k     rc=0   (rounded up, so a real value never prints 0k)
    == zero usage                      context: no usage in the transcript            rc=1
    == unset var                       CLAUDE_CODE_SESSION_ID: not set / context: no single transcript for this session   rc=1
    == no file                         context: no single transcript for this session rc=1
    == two files                       context: no single transcript for this session rc=1
    == empty file                      (first version: rc=4, silent; fixed by the `||` message, same path as "no usage")

The first version printed `0k` for 7 tokens and exited 4 silently with no
usage; both fixed in the version S1.16 gives. The real transcript was not read
by this planner (the brief keeps it out of `~/.claude`); the manager showed the
jq part live (F1). UNVERIFIED: that `CLAUDE_CODE_SESSION_ID` is set and that
transcripts sit under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<dir>/<id>.jsonl`
on any host or Claude Code version other than the manager's — only that host
was shown. It was set in this subagent too, so a subagent sees an id; whose it
is was not checked.

### F16 Handoff and compaction in the payload today

`grep -rn -i -E 'SESSION-HANDOFF|handoff file|/clear|/compact|compaction|context size|CLAUDE_CODE_SESSION_ID' plugins README.md AGENTS.md`
→ `bootstrap/SKILL.md:127` "`plan/SESSION-HANDOFF.md`, or the nearest
equivalent in `plan/`"; `manager/SKILL.md:69`, `:134` ("a reader after a
compaction"); `AGENTS.md:184` (never committed, this repo). Nothing in
`manager-bootstrap.sh`. The handoff-line format is stated only in
`manager/SKILL.md:135` and `:173` (`grep -rn -F 'round n/max'`).

### Boundary

Chosen: the rules live in `glab:manager` (Rule 2, *Pick the tier*, Stages 1,
1b, 2, 3, 5, 8, *What you never do*) and `glab:plan-first` Step 1; the agent
files carry only what an agent needs to do its part (severity line, re-check
section, fix-round section); commands restate one line each and point to the
manager (`[feature-model-switch/plan.md D7]`).

Rejected: (a) a script `plugins/glab/scripts/context-size.sh` for item 6 — D17;
(b) the snapshot tree for the plan delta as well — silently empty under a
gitignored `plan/` (D10); (c) the manager writing each round's findings to a
file — Rule 1, and the reviewer has no slug (D8); (d) `findings-<area>.md` —
refused by the Write tool (D15); (e) a severity judged by the manager — it
would re-rank (D4).

## Milestone

A Markdown and manifest change: nothing new runs. The existing gates stay
green with the same component counts (F14), and the searches V1–V14 return
exactly the files and lines listed, which separates a finished tree from a
half-finished one. The commands the payload prescribes (S1.12, S1.13, S1.16)
are run once in a throwaway directory (V13), as `AGENTS.md` *Gates* says a
Markdown change is verified.

## Steps

### Before

- B1 export `TMPDIR` as the temp directory the host file names; read `AGENTS.md`; `git status --short -uall` shows only `plan/` entries and the tree is at `7df69a8` or a descendant that has not touched the files of F12 (`git diff --stat 7df69a8 -- plugins AGENTS.md` prints nothing).
- B2 Run both gate blocks of `AGENTS.md` *Gates*; green as F14.

### Processing

Line numbers are at `7df69a8`. Quoted text is the new text; keep the
surrounding text as it is. Payload names stay prefixed (`glab:manager`),
frontmatter `name:` bare.

**S1 `plugins/glab/skills/manager/SKILL.md`**

- S1.1 Rule 2, after the bullet at `:90` ("Every agent writes long output to disk …"), add:
  "- **Every round is a new agent.** A plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a record fix are each dispatched to a new agent that works from the files on disk and what its dispatch names — never by resuming the agent that ran before or sending it a follow-up. A resumed agent starts again from everything it has read and written, so each round costs more than the one before; a new one reads only what its round needs. The one resume this skill allows is Rule 5's report check, for missing fields only. Stages 1b, 2, 3, 5 and 8 say what each new agent is given."
- S1.2 Rule 2, after the paragraph at `:96` ("You have taken over when …"), add the subsection of S1.16.
- S1.3 Rule 5 `:130`: "on each split slice, each re-dispatch after `BLOCKED` or `PLAN WRONG`, and each review round" → "on each split slice, each fix round, each re-dispatch after `BLOCKED` or `PLAN WRONG`, and each review round".
- S1.4 Rule 5 `:135`: the example `slug · develop · model sonnet · round 1/1 · BUILT · effort <level>` → `slug · develop · model sonnet · round 1/2 · BUILT · effort <level> · context <n>k`.
- S1.5 Rule 5 `:151`: after "The resume is not a review round and does not count against the cap." add "It is the one resume Rule 2 allows."
- S1.6 *The pipeline* table: `:163` Writes cell → "`plan/{slug}/plan.md`; at full tier `findings.md` too, and `questions.md` if Rule 3 raised one; `map-<area>.md` from mapping agents, when you dispatched them"; `:164` Leaves-on cell → "`BUILDABLE`, or at normal tier the amendment after round 2".
- S1.7 *The pipeline* `:173`: the line format → "`slug · stage · round n/max · verdict · effort <level> · context <n>k`" and after "(Rule 5)." add: "`max` is the stage's round cap (*Pick the tier*): `2`, or `3` once the round-3 line is written; a develop line counts its fix rounds against the cap of the stage whose findings it fixes. The context is the number Rule 2's check printed — `dispatches <d>` in its place when the check cannot run."
- S1.8 *Pick the tier* table: `:187` → `| 1b Analyze the plan | — | max 2 rounds | max 2 rounds |`; `:189` → `| 3 Analyze conformance | — | — | max 2 rounds |`; `:191` → `| 5 Review | — | max 2 rounds | max 2 rounds |`. After the table, before "Gates are run by you …", add:
  "**Round caps.** Stage 1b, Stage 3 and Stage 5 run at most **2 rounds** each, at every tier where the stage runs. A **third** round runs only when round 2 returned a finding rated `critical` or `high` — the severity the analyzer or reviewer gave it, on `glab:audit`'s *Severity Levels*, never re-ranked by you — and only once you have recorded it under `## Decisions`: `- round 3: <stage> — <severity> <the finding, as its file:line or step id and its claim>`. Nothing runs past round 3. What a stage does when its last round has not passed is in that stage."
- S1.9 *When subagent dispatch is not available* `:238`: "a second review session is `review2`, and there is no `review4`." → "a second review session is `review2`, a `review3` needs its round-3 line, and there is no `review4`."
- S1.10 Stage 1, after the paragraph at `:248`, add:
  "**Explore once.** Mapping — read-only agents that read an area of the code before the plan is written — is your call per task. Each mapping agent writes `plan/{slug}/map-<area>.md` — every path it read, `file:line` for what matters, proven kept apart from inferred — and returns a short report (Rule 2). Name those files in the planning agent's dispatch: it starts from them and reads code only for the gaps it names. Without mapping agents, the planning agent explores itself. Never both over one area: a planner told to explore again re-reads what the map already holds. The name is not `findings-<area>.md` because subagent writes of files named `findings…` have been refused."
- S1.11 Checklist item 3, `:256` → "3. **Findings cover the whole scope surface.** Every file, package, module and directory the change touches or depends on, by path. Each method the change **changes** carries its call sites and what each relies on; each method it only **calls** carries the precondition its new call site must meet and how the plan meets it; a file it only depends on is listed by path, not read in full (`glab:plan-first` Step 1). A findings file or section with no path list has not done this step."
- S1.12 Stage 1b, replace `:320-328` (from "**`BUILDABLE`** → Stage 2." to "… the backstop.") with:
  "**`BUILDABLE`** → Stage 2. **`NOT BUILDABLE`** → an amendment, with exactly what is missing; a missing choice is decided under Rule 3 first. **Never patch the steps yourself to make them buildable** — for the same reason Stage 3 forbids editing `plan.md` to resolve a divergence.

  **The amendment goes to a new planning agent** (Rule 2). Before you dispatch it, keep the version the round checked: `cp plan/{slug}/plan.md plan/{slug}/plan.r<n>.md`, and `findings.md` to `findings.r<n>.md` when there is one, `<n>` being the round that checked them. Give the new agent the slug, that this is the amendment after plan check round `<n>`, the round's findings copied as the analyzers returned them, and `glab:plan-first` with the seam stated. It reads the plan files from disk, changes what the findings name and what that forces, records each changed choice under `## Decisions`, and leaves the `.r<n>` copies as they are.

  **A re-check looks at the delta, not the whole plan.** Before round `<n+1>`, run `diff -u plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and the same for `findings.md`): exit 1 means the amendment changed the plan; exit 0 means it changed nothing — send it back, do not re-check it; exit 2 means a file is missing — find out why first. Give each analyzer of round `<n+1>` the previous round's findings, copied as returned, and the file pairs. It checks each of those findings, every line the diff changes and every step that rests on a changed line — the post-condition question included — and not the rest of the plan, which already passed.

  **At most 2 rounds, a third under *Pick the tier*'s round-3 rule.** A plan still `NOT BUILDABLE` after round 2 with no round 3: at full tier it needs a design, not another pass — bring that to the user; at normal tier a new planning agent amends once more from what the analyzers found and the plan goes on — the developer's `PLAN WRONG` is the backstop. Still `NOT BUILDABLE` after round 3, at any tier: bring it to the user."
- S1.13 Stage 2 dispatch list, after the effort bullet at `:340`, add:
  "- **for a fix round** — after `DIVERGES` or review findings: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. It reads `plan.md`, `result.md` and the tree itself, fixes only what the findings name, and adds a fix-round section to `result.md` instead of overwriting it. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps."
- S1.14 Stage 3, replace `:376` with:
  "**`DIVERGES` → back to Stage 2** with only the diverging steps in scope, as a fix round. **At most 2 develop→analyze rounds, a third under *Pick the tier*'s round-3 rule.** Say the round number every time: `analyze round 2/2`.

  **A re-check looks at the delta.** Before you dispatch each analyze round, round 1 included, snapshot the tree it will measure — tracked, staged and untracked files, without touching the index — with an index path that does not exist yet, in the session's temp directory:

      idx=<temp directory>/<slug>-analyze-r<n>.idx; rm -f "$idx"
      GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"

  It prints a tree id; name it in that round's dispatch. Round `<n+1>` gets the previous round's findings, copied as returned, and both tree ids; it reads `git diff --stat <old> <new>` and `git diff <old> <new>` and checks each previous finding, every step whose files the delta touches, and anything in the delta that no step asked for — not the steps the delta leaves alone. `git diff --quiet <old> <new>` exiting 0 after a fix round means nothing changed: stop and find out why. Ignored files are not in a snapshot, so a path the fix round's `files:` line names and the delta does not show is checked whole; a tree id you no longer have means that round runs whole."
  And `:378` "Still diverging at round 4 →" → "Still diverging after the last round →" (rest unchanged).
- S1.15 Stage 5, replace `:397` and `:399` with:
  "Findings → back to Stage 2 as a fix round, then the stages after it at that tier, then Stage 5 again. **At most 2 review rounds, a third under *Pick the tier*'s round-3 rule**, at every tier. Tell the reviewer which round this is and which is the last: round 2 is the last unless it reports a `critical` or `high` finding, and round 3 is the last with no exception. A round-2 `BLOCK` with no critical or high finding is not a last-round answer: Rule 5's report check applies. At the last round the answer must be `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>`, or `DO NOT PUBLISH: <why>` — bring whichever it is to the user.

  A fix that grows past its finding, or lands in full-tier code, raises the tier."
  `:401` ("Watch where findings land …") stays.
- S1.16 The subsection S1.2 places after `:96`:
  "### Your own context — measure it, suggest, never clear

  Your context grows with every turn, and every turn pays for all of it. You cannot run `/clear` or `/compact`; the user can. So you measure, and you say when.

  - **Measure at every handoff line.** This prints the context of your last completed call, in thousands, and nothing else from the transcript — which can hold secrets, so never read or print more of it:

        ( set -o pipefail
          f=$(find "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects" -mindepth 2 -maxdepth 2 -type f -name "${CLAUDE_CODE_SESSION_ID:?not set}.jsonl" 2>/dev/null)
          [ -n "$f" ] && [ "$(printf '%s\n' "$f" | wc -l)" -eq 1 ] || { echo 'context: no single transcript for this session' >&2; exit 1; }
          jq -c -R 'fromjson? | select(.type == "assistant" and .message.usage) | .message.usage' "$f" | tail -n 1 |
            jq -e -r '(.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0) | select(. > 0) | "\((. + 999) / 1000 | floor)k"' ||
            { echo 'context: no usage in the transcript' >&2; exit 1; }
        )

    Put the number at the end of the handoff line, `· context <n>k`. It is the last call's context, not your exact size now; say no more than that.
  - **Inside a task**, at the first handoff line at or past **300k**, and again each time it has grown by another **100k** since you last suggested it: bring the handoff file up to date and suggest `/compact` to the user. 300k is where a resumed agent's rounds were already costing several times a fresh one's, and half of one manager session's 648k peak.
  - **At a task boundary** — after the push of the Stage 8 record, or after Stage 7 for a change with no plan folder — bring the handoff file up to date and tell the user this is a good point to `/clear` and start the next task in a new session, whatever the number says.
  - **When the check cannot run** — any non-zero exit: the variable unset, no single transcript, no usage, no `jq` — say so once in this session, then count instead: suggest `/compact` after every **15** dispatches since the session started or was last compacted, and after any stage that took more than one round. The handoff line then ends `· dispatches <d>`.
  - **The handoff file** is the one `glab:bootstrap` step 5 reads — `plan/SESSION-HANDOFF.md`, unless the repo keeps its handoff elsewhere. Write what is done (slugs, commits), what is in progress (slug, stage, round, the next dispatch), and anything decided in this conversation that no plan file holds. No `glab` step commits it.
  - **You never run `/clear` or `/compact` yourself**, and never claim to know your context more exactly than the check printed."
- S1.17 Stage 8: `:420` "`DIVERGES` goes back to the developer once" → "`DIVERGES` goes back to a new developer once (Rule 2)"; `:421` "Its findings go back to the developer once" → "Its findings go back to a new developer once".
- S1.18 *What you never do*, add after `:436`:
  "- Resume an agent, or send it a follow-up, for another round of work — Rule 5's report check is the one resume.
  - Run `/clear` or `/compact`, or claim to know your context more exactly than Rule 2's check printed."

**S2 `plugins/glab/skills/plan-first/SKILL.md`**

- S2.1 Step 0 `:19`: after "Normal tier writes one page: `plan.md` alone, with findings and decisions as sections of it." add "Map files the manager's mapping agents wrote, `map-<area>.md`, sit beside it (Step 1)."
- S2.2 Step 1, before "**Call-site audit.**" (`:31`), add:
  "**Start from the map when there is one.** When `plan/{slug}/map-<area>.md` files exist — written by mapping agents the manager dispatched (`glab:manager` Stage 1, *Explore once*) — they are the analysis of their area. Start from them, write down the gaps they leave that the plan needs, and read code only for those gaps, naming each in your findings. Do not re-read a path a map already read unless a gap names it. With no map, you explore yourself."
- S2.3 Replace `:31-38` with:
  "**Call-site audit.** For every existing method or function the plan **changes** — its signature, return values, error cases, timing or behaviour — grep its real usage across the codebase first and record:

  - the caller list;
  - what each caller appears to rely on;
  - whether the contract is shared or caller-specific.

  For every method the plan calls from a new call site, record the precondition that call site must meet and how the plan meets it. For a method it only **calls**, that is all: its other callers are not audited, because nothing they rely on changes.

  Do not assume how a method behaves from its name or signature alone: read the precondition from its body or its documented contract.

  A file the change only depends on — imported, configured, read — is listed by path and not read in full; read only the part a precondition or a finding needs."
- S2.4 Step 4 `:85` → "- the call-site review is complete for any changed existing method, and every method the plan only calls has its precondition recorded;"
- S2.5 After Step 4's list (`:88`), add:
  "**Amending after a plan check.** Under `glab:manager` an amendment after `NOT BUILDABLE` is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:manager` Stage 1b). Change what the findings name and what that forces, record each changed choice under `## Decisions`, and leave the `plan.r<n>.md` copies the manager kept as they are. Step 1 is not run again, except for a gap a finding opens."

**S3 `plugins/glab/agents/reviewer.md`**

- S3.1 *Report* block `:81-84`: after `rule: <the AGENTS.md rule, or "correctness">` add the line `severity: <critical | high | medium | low>`. After the block (before `:86`) add:
  "The severity is one of `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. Rate by consequence. The caller does not re-rank it, and in round 2 it decides whether a round 3 runs."
- S3.2 `:92` → "A change gets **at most two rounds**, and a third only when round 2 reports a `critical` or `high` finding — at every tier, counted across the whole change rather than per file. The caller tells you which round this is and which is the last. Round 2 is the last unless you report a `critical` or `high` finding in it: then answer `BLOCK: <n> issues`, and the caller may run round 3. Round 3 is the last with no exception. In the last round the answer must be publish or do not publish; there is no round after it."
  `:94-102` unchanged.

**S4 `plugins/glab/agents/analyzer.md`**

- S4.1 Step 1 `:16` → "- `plan/<slug>/findings.md` and every `plan/<slug>/map-<area>.md`, when there are any — what the plan was built on"
- S4.2 *Report* block `:60-63`: after `gap:       <only when not done>` add `severity:  <only when not done: critical | high | medium | low>`; after the block add:
  "Rate each gap by what it costs if the plan is built, or the tree shipped, as it stands, on `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. In round 2 it decides whether a round 3 runs."
- S4.3 New section before `## The record check` (`:54`):
  "## Re-checks — round 2 and later

  When the dispatch says this is round 2 or later of a plan check or a conformance check, it gives you the previous round's findings and the delta: for a plan check, file pairs — `plan/<slug>/plan.r<n>.md` and `plan/<slug>/plan.md`, and `findings.r<n>.md` with `findings.md` when there are; for a conformance check, two tree ids. Get the delta yourself — `diff -u <old> <new>`, or `git diff --stat <old> <new>` then `git diff <old> <new>` — and check:

  - each previous finding: fixed, or still open under its old step id;
  - every line the delta changes, and every step that rests on a changed line or a changed file — for a plan check, the post-condition question included;
  - for a conformance check, anything in the delta that no step asked for.

  Do not re-walk what the delta leaves alone; it passed the round before. `diff` and `git diff --quiet` exit 1 when there is a difference and 0 when there is none: an empty delta is not a pass — report `BLOCK: target unresolved` and say the delta was empty. Name the delta you measured — the file pair or the two tree ids — beside the plan revision."
- S4.4 Record check `:56`: append "A round copy — `<name>.r<n>.md`, kept by `glab:manager` Stage 1b — is an earlier version of a file the folder still holds: take the items from the current file; the copy is not checked on its own."

**S5 `plugins/glab/agents/developer.md`**

- S5.1 Step 1 `:17`: append "Also any `plan/<slug>/map-<area>.md` the plan cites."
- S5.2 Step 5 `:68`: "overwrite it on a re-dispatch rather than appending a second copy." → "overwrite it on a re-dispatch of the same steps rather than appending a second copy; a fix round adds its own section instead (*A fix round*)."
- S5.3 New section after Step 5's template (`:94`), before `## The record`:
  "## A fix round

  When the dispatch says this is a fix round — after an analyzer's `DIVERGES` or a reviewer's findings — your scope is the findings it quotes, each one a step. You did not build what came before: read `result.md` for what earlier rounds built, and the tree (`git status --short -uall`, `git diff`, `git diff --staged`), before changing anything. Do not overwrite `result.md`: add a section `## Fix round — <stage> round <n>` with each finding `done` or `blocked` with `file:line`, then the gates. Every other rule of this file holds."
- S5.4 Record `:98`: after "Change nothing inside `plan/<slug>/`, and remove nothing." add "A round copy `<name>.r<n>.md` is an earlier version of a file the folder still holds: take the items from the current file."
- S5.5 `:103`: "**Never edit `plan.md`, `findings.md` or `questions.md`.**" → "**Never edit `plan.md`, `findings.md`, `questions.md`, a `map-<area>.md` or a round copy `<name>.r<n>.md`.**"

**S6 `plugins/glab/commands/ship.md`**

- S6.1 `:30`: "If I ask you to fix anything, return to step 1 and re-run the reviewer on the amended tree." → "If I ask you to fix anything, return to step 1 and run a new agent as the reviewer on the amended tree — never the previous one resumed (`glab:manager` Rule 2)."
- S6.2 `:32`: "**At most three rounds, then a decision.** Tell the reviewer which round this is and which is the last, and scope each round after the first to what changed since the last one. In the last round it must answer …" → "**At most two rounds, a third only on a critical or high finding, then a decision.** Tell the reviewer which round this is and which is the last, and scope each round after the first to what changed since the last one. Round 2 is the last unless the reviewer reports a `critical` or `high` finding in it and answers `BLOCK`; then round 3 runs if I ask for the fix, and it is the last with no exception. In the last round it must answer …" (rest of `:32` unchanged).

**S7 `plugins/glab/commands/develop.md`**

- S7.1 `:42`: "slices and re-dispatches alike" → "slices, fix rounds and re-dispatches alike".
- S7.2 After `:43`, add: "- for a fix round — after `DIVERGES` or review findings — or a re-dispatch after `BLOCKED` or `PLAN WRONG`: a new agent, never the previous one resumed or sent a follow-up (`glab:manager` Rule 2). A fix round's dispatch says which round it fixes and quotes that round's findings as they came back; the agent reads `plan.md`, `result.md` and the tree itself."

**S8 `plugins/glab/commands/analyze.md`**

- S8.1 After `:6`, add: "A round 2 or later is a new agent, given the previous round's findings and the delta, as `glab:manager` Stages 1b and 3 say."

**S9 `plugins/glab/skills/bootstrap/SKILL.md`**

- S9.1 `:100-101` → "Normal work runs a one-page plan, a plan check and a review, with no conformance stage; trivial work is done directly. Each check stage runs at most two rounds, a third only on a critical or high finding; `glab:manager` → *Pick the tier* has the table and the round caps."

**S10 `AGENTS.md` *One fact*** (`:106-109`)

- S10.1 "the review round cap (`…reviewer.md`, `…ship.md`, `…manager/SKILL.md`, `…bootstrap/SKILL.md`)" → "the round caps — Stage 1b, Stage 3 and Stage 5 at most 2 rounds at every tier, a third only on a `critical` or `high` finding of round 2 recorded as a `## Decisions` line, none past 3 (the same four files)".
- S10.2 After the reviewer's-verdict-lines entry, add: "the severity levels — `critical`, `high`, `medium`, `low` and their meanings (`plugins/glab/skills/audit/SKILL.md`, `plugins/glab/agents/reviewer.md`, `plugins/glab/agents/analyzer.md`); every round a new agent, Rule 5's report check the one resume (`plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/develop.md`, `plugins/glab/commands/ship.md`, `plugins/glab/commands/analyze.md`); the mapping files `map-<area>.md` and the round copies `<name>.r<n>.md` (`plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`); the handoff file `plan/SESSION-HANDOFF.md` (`plugins/glab/skills/bootstrap/SKILL.md` step 5, `plugins/glab/skills/manager/SKILL.md` Rule 2)".

**S11 `plugins/glab/.claude-plugin/plugin.json`**

- S11.1 `"version": "0.8.0"` → `"version": "0.9.0"`.

### After

Each search is run from the repo root with `/usr/bin/grep`; each lists what
it must print, so a skipped step shows as a missing or extra line.

- V1 Old caps gone: `grep -rn -E 'max 4 rounds|max 3 rounds|Maximum 4|Maximum 3|at most three|round 2/4|One pass at normal|one pass \||One round at normal|one at normal tier|one analysis and one review|round 1/1|at round 4|the review round cap' plugins/glab AGENTS.md; echo rc=$?` → no line, `rc=1`. An absence check: it cannot tell a tree where the text was rewritten wrongly; V2–V3 discriminate.
- V2 New cap: `grep -rli -E 'at most (2|two)( [a-z>→-]+)* rounds|max 2 rounds' plugins/glab AGENTS.md | sort` → exactly `AGENTS.md`, `plugins/glab/agents/reviewer.md`, `plugins/glab/commands/ship.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`. At `7df69a8` it prints only `plugins/glab/skills/manager/SKILL.md` (the full-tier 1b cell), so it discriminates for the other four files and V3 does for the manager.
- V3 Tier rows: `grep -n -E '^\| (1b|3|5) ' plugins/glab/skills/manager/SKILL.md` → three lines: `1b … | — | max 2 rounds | max 2 rounds |`, `3 … | — | — | max 2 rounds |`, `5 … | — | max 2 rounds | max 2 rounds |`. Round-3 line: `grep -c -F -- '- round 3: <stage>' plugins/glab/skills/manager/SKILL.md` → `1`.
- V4 Severity: `grep -n -F 'severity:' plugins/glab/agents/reviewer.md plugins/glab/agents/analyzer.md` → one template line in each; `grep -l -F 'unbounded memory growth' -r plugins/glab | sort` → `agents/analyzer.md`, `agents/reviewer.md`, `skills/audit/SKILL.md`.
- V5 New agents: `grep -rl -F 'new agent' plugins/glab | sort` → exactly `commands/analyze.md`, `commands/develop.md`, `commands/ship.md`, `skills/manager/SKILL.md`; `grep -l -F 'new planning agent' -r plugins/glab | sort` → `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`; `grep -c -F '## A fix round' plugins/glab/agents/developer.md` → `1`.
- V6 Resumes: `grep -rn -E 'resum' plugins/glab | cut -d: -f1,2` → exactly `bootstrap/SKILL.md:3`, the Rule 5 version-floor line, the Rule 5 report-check line, the Rule 2 bullet, the *What you never do* bullet (all `manager/SKILL.md`), `commands/develop.md` (S7.2), `commands/ship.md` (two: `:28` and S6.1).
- V7 Map files: `grep -rl -F 'map-<area>.md' plugins/glab AGENTS.md | sort` → `AGENTS.md`, `agents/analyzer.md`, `agents/developer.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`; `grep -rn -F 'findings-<area>' plugins/glab AGENTS.md` → only the S1.10 sentence that says why the name is not used.
- V8 Round copies: `grep -rl -F '.r<n>.md' plugins/glab AGENTS.md | sort` → `AGENTS.md`, `agents/analyzer.md`, `agents/developer.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`.
- V9 Planner search: `grep -n -F 'only **calls**' plugins/glab/skills/plan-first/SKILL.md plugins/glab/skills/manager/SKILL.md` → one line in each; `grep -c -F 'you plan to change or call' plugins/glab/skills/plan-first/SKILL.md` → `0`.
- V10 Context: `grep -n -E 'CLAUDE_CODE_SESSION_ID|· context <n>k|300k|dispatches <d>|/compact' plugins/glab/skills/manager/SKILL.md` → the S1.16 lines and the S1.4, S1.7, S1.18 lines; `grep -rl -F 'CLAUDE_CODE_SESSION_ID' plugins README.md AGENTS.md` → only `plugins/glab/skills/manager/SKILL.md`; `grep -c -F 'SESSION-HANDOFF' plugins/glab/scripts/manager-bootstrap.sh` → `0` (unchanged, D22).
- V11 `AGENTS.md`: `grep -n -E 'the round caps|the severity levels|every round a new agent|the handoff file' AGENTS.md` → four lines inside *One fact*.
- V12 Version: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.9.0`; `jq -r .version plugins/memory-sync/.claude-plugin/plugin.json` → `0.1.0`.
- V13 Throwaway run, under `$TMPDIR`, removed after, pasted in `result.md`: (a) the S1.14 snapshot lines, copied from the edited file, in a new repo with a tracked change, a staged change, an untracked file and an ignored file, then a second snapshot after a further change — expect F8's shape (status and index unchanged, the delta lists only the later change, `git diff --quiet` rc=1, no `.idx` left); (b) the S1.12 `diff -u` on a copy and an amended copy — rc=1, and rc=0 on identical files; (c) the S1.16 command, copied from the edited file, against fake transcripts under a fake `CLAUDE_CONFIG_DIR` — the eight cases of F15 with the same results (one number on success; `rc=1` and a fixed message otherwise; no `0k`, no `null`, no line of the fake transcript printed). Never against the real transcript.
- V14 Prefixed names: `grep -n -E '`(manager|plan-first|audit|bootstrap|security|reviewer|analyzer|developer)`' plugins/glab/skills/manager/SKILL.md plugins/glab/skills/plan-first/SKILL.md plugins/glab/agents/*.md plugins/glab/commands/*.md plugins/glab/skills/bootstrap/SKILL.md` → no line in text this change added (compare with the same search at `7df69a8`).
- V15 Both gate blocks of `AGENTS.md` *Gates*: green with F14's counts and names — `Skills (14)`, `Agents (5)`, `Hooks (1)  SessionStart`; `memory-sync` unchanged.

Test coverage (`AGENTS.md` *Tests*): no shell script changes, so
`tests/memory-sync.test.sh` covers nothing here and none is added; every step
is covered by V1–V14, and the prescribed commands by V13. Not covered by any
case: that a live session follows the prose (D-wide UNVERIFIED), and the
context command against a real transcript on a host other than the manager's.

Back-out: `git revert <commit>`; because the revert changes `plugins/glab/`,
it raises `glab` to `0.9.1` in the same commit (*A change under
`plugins/<name>/` raises that plugin's version*). Round copies and map files
already written in other repos' plan folders stay; they are inert text.

## Follow-ups

- FU1 A dedicated `glab:planner` agent (out of scope by the brief).
- FU2 Splitting the implementation steps (5–7) out of `glab:plan-first` (out of scope by the brief).
- FU3 The user-level copies under `~/.claude` — the user ports them (out of scope by the brief).
- FU4 The "cleanup glob deleted a reviewer report" incident (out of scope by the brief).
- FU5 `agents/analyzer.md` has no plan-check mode: `BUILDABLE` / `NOT BUILDABLE` appear only in `skills/manager/SKILL.md` (F7); its Steps 2–3 are written for an implementation.
- FU6 `glab:plan-first` prescribes `findings.md` at full tier, but a subagent planner's Write is refused that name (F9 and two incidents); a full-tier planner subagent cannot write its findings file as the skill says.
- FU7 Stage 5 does not say how a review round after the first learns what changed since the last one: `reviewer.md:94` has the reviewer ask, and `ship.md:32` has the caller scope it, while Stage 5 gives the reviewer the target and nothing else (F6).
- FU8 Snapshot limits: a nested repository is recorded as a gitlink with a warning, and a large untracked directory that is not ignored is hashed in full (F8, not tested).
- FU9 Whether `CLAUDE_CODE_SESSION_ID` and the transcript layout hold on other hosts and versions, and whose id a subagent sees (F15, UNVERIFIED).

## Record

After the push, `glab:manager` Stage 8 updates:

- `docs/specs/workflow.md` (primary): *How it works now* — the tier bullet (`:59-68`) and the round-caps bullet (`:169-173`) restated for 2 (+1) at every tier with the reviewer's round-2 rule; new bullets for every round a new agent (Rule 2), the delta re-checks of 1b and 3 with their two mechanisms, explore once and `map-<area>.md`, the narrower call-site audit, the context check with its command, thresholds, fallback and handoff file, and the handoff line's `· context <n>k`; the agents bullet gains the `severity:` line, the analyzer's re-check section and the developer's fix-round section. *Decisions that still bind*: D2–D27 tagged `[flow-cheaper-rounds/plan.md D<n>]`, with `[bug-reviewer-findings/questions.md Q3]` and `[sync-local-edits/result-followups.md D11]` marked superseded by D2. *Known limits*: F8's untested cases, F9's partial probe, F15's UNVERIFIED, F1's inferred savings. *Follow-ups*: FU1–FU9 open; `[sync-local-edits/follow-ups.md 18]` and `[sync-local-edits/follow-ups.md 19]` closed by this change. *Incidents*: the Write refusal of `findings-probe.md` and `findings.md` for a subagent, a third time, now with `map-probe.md` accepted.
- `docs/specs/marketplace.md`: *Versions* — `glab` `0.9.0`; the *One fact* entries this change rewrote or added (S10); `[feature-plugin-marketplace/questions.md S3]` marked superseded by D2.

No audit file under `plan/` is acted on.
