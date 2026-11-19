# Workflow — spec

The `glab` workflow: how a session runs a change through plan, analysis,
development, integration, review, commit and push, at the depth a tier
gives it; the rules of `glab:manager`; the agents and the stage skills (the
commands until `glab` 0.13.0); the model
each agent runs on and the user's override of it (until `glab` 0.12.0 the
user's choice of model for the developer and reviewer only); and what happens to a
change's plan files, up to the record that moves what stays true into an
area spec; and, since `glab` 0.14.0, the rules every level's manager
shares and the project level's edges to the product level above it, which
is `docs/specs/product.md`. Owned by `plugins/glab/skills/manager/SKILL.md`,
`plugins/glab/skills/session-rules/SKILL.md` (the rules of every level, since
0.14.0),
`plugins/glab/skills/plan/SKILL.md` (`plugins/glab/skills/plan-first/SKILL.md`
until `glab` 0.13.0),
`plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/audit/SKILL.md`,
`plugins/glab/skills/security/SKILL.md` and
`plugins/glab/skills/comments/SKILL.md` (the shared rules the agents preload,
since 0.13.0), the agents under `plugins/glab/agents/`, the stage skills
`plugins/glab/skills/{analyze,commit,develop,integrate,push,review,ship}/SKILL.md`
(since 0.13.0; until then the commands under `plugins/glab/commands/`),
`plugins/glab/scripts/manager-bootstrap.sh`
(the `SessionStart` hook text), and, since `glab` 0.9.0 (`2a1e919`),
`plugins/glab/scripts/context-size.sh` and `plugins/glab/hooks/hooks.json`
(the context hook). The external agents, removed in `glab`
0.8.0 (`467b7c4`, 2026-10-20), are recorded in
`docs/specs/external-agents.md`, now a record only. Stated as of `09d2787` (`glab` `0.5.0`), the
record of `feature-docs-specs`, and its `feature-codex-agent` lines (Rules 5
and 6 for Codex, `/glab:review`) as of `30f2c80` (`glab` `0.6.0`), and its
`feature-external-developer` lines (Rule 5's external developer, Rule 6's
exceptions, `/glab:develop`'s external path) as of `33a28df` (`glab`
`0.7.0`), and its `subagent-effort` lines (Rule 0d, the effort in the
handoff line and in Rules 5 and 6, the dispatch text of Stages 2 and 5, of
`/glab:develop`, `/glab:review`, `/glab:ship`, `glab:bootstrap` and the hook)
as of `abda43a` (`glab` `0.7.2`), and its `remove-external-agents` lines
(Rule 6 gone, Rules 0d and 5 and *The pipeline* without their Codex and
OpenCode sentences, the commands without their external paths, every
statement of an external agent marked as history) as of `467b7c4` (`glab`
`0.8.0`), and its `flow-cheaper-rounds` lines (the round caps, every round a
new agent, the delta re-checks, explore once, the narrower call-site audit,
the severity line, the context rule and the context hook, the handoff
line's `· context <n>k`) as of `2a1e919` (`glab` `0.9.0`), and its
`flow-planner` lines (`evidence.md`, the plan size budget and in-place
amending, `glab:plan-first`'s `implement.md`, the developer's context
rules, `GLAB_COMPACT_AT`) as of `2912002` (`glab` `0.10.0`), which added
`plugins/glab/skills/plan-first/implement.md` to the owning files (removed in
`glab` 0.13.0), and its
`flow-master-plan` lines (the master plan and sub-plans, the intent check,
the analyzer's plan check, Stage 6b, approval after Stage 1b and in plan
mode, `## Record` in the master, the stage listings) as of `0cbf5b0`
(`glab` `0.11.0`), and its `flow-models-per-role` lines (the model per
role in each agent's frontmatter, Rule 5 reworded, `model <alias>` on every
agent stage's handoff line, `glab:planner` and `/glab:plan` dispatching it,
the two analyzer kinds and `/glab:analyze`'s routing by kind, the dispatch
table for the default) as of `517b7b6` (`glab` `0.12.0`), and its
`flow-commands-to-skills` lines (the stage skills in place of the commands,
`glab:plan` in place of `glab:plan-first`, one owner per rule, the
`skills:` preload, Rule 0c's dispatch of task facts only, Rule 5's
*Precedence*, the session-start text, and every line below marked
"since `glab` 0.13.0") as of `6f8b948` (`glab` `0.13.0`), and its
`flow-product-level` lines (`glab:session-rules`, the level boundary, the
level line, project Stage 1c and the develop gate, the session-start text
by level, and every line below marked "since `glab` 0.14.0") as of
`ce1a933` (`glab` `0.14.0`), whose product level is recorded in
`docs/specs/product.md`, and its `docs-lifecycle` lines (plan folders
never committed, the record's feature pages and *Records* line, Rule 2's
plan-folder approval and its removal at `glab:bootstrap` step 5, the
committer's `plan/` bullet, the analyzers' revision line, `glab:push`
step 4) as of `3ed6746` (`glab` `0.16.0`, rebase-merged as `d2ca05b`),
whose subsection *The docs lifecycle as of 0.16.0* supersedes every
statement of plan-folder removal below it, and its `lifecycle-hardening`
lines (the plan-folder removal on the user's word, asked once per folder
at `glab:bootstrap` step 5, Rule 2's listing and its outcomes, the record
committed on the change's branch, the record check's and the reviewer's
paths) as of `bf9c73f` (`glab` `0.16.2`, PR #22, not merged at this
record), whose subsection *The docs lifecycle as of 0.16.2* supersedes
*The docs lifecycle as of 0.16.0* and every line below it where they
disagree, and its `level-guard` lines (the level boundary held by the
`PreToolUse` hook `level-guard.sh`, the new paragraph of
`glab:session-rules` *The level boundary*, the level read shared through
`plugins/glab/scripts/glab-level.sh`) as of `632dcb0` (`glab` `0.17.0`,
PR #24, not merged at this record), whose subsection *The level guard as
of 0.17.0* supersedes every line below it that calls the main session's
boundary text only, and whose hook is recorded in full in
`docs/specs/product.md`, and its `remote-store` lines (the planner's
`sync` before it reads a brief and its write boundary,
`glab:project-plan-report`'s store push and its sync on resuming,
`glab:session-rules` Rule 3's store-push exception, the `project-planner`
set re-measured) as of `0634bd5` (`glab` `0.18.0`, PR #25, not merged at
this record), whose subsection *The store sync as of 0.18.0* supersedes
every line below it that has the project side read the store without a
sync or confirm every push, and whose store clone is recorded in full in
`docs/specs/product.md`; where this file
and an owning file disagree, the owning file is right.

## How it works now

### The store sync as of 0.18.0

- **The project-level edge of the store clone** (`glab` 0.18.0,
  `0634bd5`, `remote-store`; the owners `glab:project-plan` *The task*,
  `glab:project-plan-report` *Run* and *On resuming*,
  `plugins/glab/agents/project-planner.md` *Where you write* and
  `glab:session-rules` Rule 3; `[remote-store/plan.md D19]`, `D28`,
  `D34`, `D37`, `D38`, their text in `docs/specs/product.md` *Decisions
  that still bind*). The store may be a clone of the product's store
  repository, which `plan-gate.sh` fetches, commits and pushes itself
  (`docs/specs/product.md` *How it works now*); the project side reads it
  only after a sync. The planner reads a brief only after
  `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" sync <store>` — "anything
  but exit 0 → stop and show its stderr line" (`project-plan/SKILL.md:11`,
  `[remote-store/review-r2.md B6]`; the planner has `Bash`). Its write
  boundary allows that sync: "Only the plan folder your dispatch names, and
  the store's `sync` that `glab:project-plan` *The task* has you run."
  (`project-planner.md:27`), and its description now says it "never edits
  outside the plan folder its dispatch names but the store's sync" (`:3`,
  `[remote-store/review-r2.md B9]`). `glab:project-plan-report` *Run*: "In
  a store clone it also commits and pushes them itself: the store's commit
  and push, not this repo's (`glab:session-rules` Rule 3)." (`:20`); *On
  resuming* syncs before it reads the latest verdict, with the same stop
  (`:36`). `glab:project-develop` is unchanged: `check` syncs itself.
  `glab:session-rules` Rule 3's last bullet now ends "and before every
  push (`glab:push`, any level), bar `plan-gate.sh`'s store push." — the
  exception stated once, the sentence tightened so the file shrinks by one
  byte, 18394 → 18393, its session-start cap already exceeded
  (`[remote-store/review-r1.md B2]`, `D28`); the project session's start
  prompt says "push this repo only after the user's explicit go-ahead"
  (`glab:product-manager`). `glab:push`, Stage 7 and
  `glab:project-manager` are unchanged (10016 bytes);
  `project-manager/SKILL.md:68` and `session-rules/SKILL.md:138` still say
  the push waits for the user without pointing at the exception
  (`[remote-store/follow-ups.md FU-RS11]`), and the wider rule — agents
  push and merge below `main` on their own — is
  `[remote-store/follow-ups.md FU-RS2]`. The level guard asks for no
  `sync` command, its `bash` mode needing the word `verdict` (inferred;
  `tests/level-guard.test.sh` unchanged, `PASS 29/29`).

### The level guard as of 0.17.0

- **The project-level edge of the level guard** (`glab` 0.17.0,
  `632dcb0`, `level-guard`; `glab:session-rules` *The level boundary*,
  the owner of the rule; `plugins/glab/scripts/level-guard.sh` and
  `plugins/glab/hooks/hooks.json`, the owners of the hook;
  `[level-guard/plan.md D2]`, `D5`, `D8`, `D9`). Since 0.17.0 the
  boundary's skill half is held by a `PreToolUse` hook on `Skill`: in a
  project session (no `glab-level:` line, or `glab-level: project`), a
  Skill call to a `glab:` skill that `glab:project-manager` *Your skills —
  this level only* does not list — every `glab:product-*` skill — is
  refused, in the main session and in subagents alike, and the deny reason
  tells Claude the user can type `/glab:<name>`; in a product session the
  same holds against `glab:product-manager`'s list (`docs/specs/product.md`
  *How it works now*, LV1, LV3, LV4). Measured offline by LG1 and LG2 over
  every shipped skill: at the project level 19 pass and 6 are refused, at
  the product level 14 and 11. The list stays where the manager reads it:
  the hook parses that section — the exact heading, its `- **` bullets but
  the agents', one line each — so each list stays one bullet per line, and
  LG1 and LG2 fail the gates when a list stops parsing (`D2`, `D10`). The
  level is the one `manager-bootstrap.sh` names, both reading it through
  `glab_level` in `glab-level.sh` (`D3`), from `$CLAUDE_PROJECT_DIR`, never
  the call's `cwd` (`D4`). A skill the user types never reaches the hook
  (`D8`); agents are not judged, so "dispatch no agent not on it" stays
  text (`D9`, `[level-guard/follow-ups.md FU-LG1]`). Where the hook cannot
  read the call, the list or the level rule, it lets the call through, and
  the text rule still holds (`D10`). `glab:session-rules` *The level
  boundary* gains one paragraph (`session-rules/SKILL.md:14`): "Since
  `glab` 0.17.0 a `PreToolUse` hook, `level-guard.sh`, holds the list too:
  it reads it from that section and refuses a Skill call to a `glab:` skill
  not on it, in subagents as well. It judges no agent. A skill the user
  types as `/glab:<name>` never reaches it, but a skill that one calls in
  turn through the Skill tool is judged (inferred; no live run made such a
  call) — when the user wants another level's skill, ask them to type it."
  `glab:session-rules` grows from 17951 to 18394 bytes (`wc -c`), its
  session-start cap already exceeded at the base
  (`[level-guard/follow-ups.md FU-LG4]`, `docs/specs/product.md`). No glab
  agent has the `Skill` tool, so the hook reaches the main session and
  non-glab subagents such as `general-purpose` (`D5`).

### The docs lifecycle as of 0.16.2

- **This subsection supersedes *The docs lifecycle as of 0.16.0* and every
  line below it where they disagree about the removal of a plan folder,
  where the record is committed and what the record check reads** (`glab`
  0.16.2, `bf9c73f`, `lifecycle-hardening`, PR #22, not merged at this
  record); the files it names own each fact.
- **The plan-folder removal is on the user's word, asked once per folder**
  (`glab:session-rules` Rule 2, the owner, `session-rules/SKILL.md:79`–`94`;
  `[lifecycle-hardening/plan.md D26]`, `D27`). It is not a standing
  approval: the manager never removes a plan folder unasked. Rule 2 keeps
  the user's 0.16.0 words, "The manager removes plan/<slug>/ right after
  the record is merged, under a standing approval (like completed
  handoffs). Nothing piles up; the docs are the only lasting copy.", as a
  record, with why they ended: in 0.16.0 and 0.16.1 the manager removed a
  folder unasked once a date guard passed; review round 2 found that an
  amended squash or a rewritten default branch still passed it, and the
  same day the user, asked "Drop automatic removal and ask once per folder,
  or keep it for squash merges only?", answered "Ask once per folder"
  (`D26`; *Incidents*). At a session start (`glab:bootstrap` step 5) the
  manager runs the listing on each `plan/<slug>` a *Records* line names,
  from the repo root (`cd "$(git rev-parse --show-toplevel)"` first):
  - the structural checks, unchanged from 0.16.0: the slug matches
    `[A-Za-z0-9][A-Za-z0-9_-]{0,127}` as a whole name and is not `handoff`;
    `! test -L plan`, `test -d plan/<slug>`, `! test -L plan/<slug>`; its
    `realpath` is `<toplevel>/plan/<slug>`; `find plan/<slug> -name .git`
    prints nothing; `git ls-files -- plan/<slug>` prints nothing; the
    record-file list (the specs and feature pages its `## Record` names, or
    `docs/roadmap/<slug>.md` for a product slug) is non-empty;
  - its record has landed: after `git fetch origin`,
    `git diff --quiet origin/<default> -- <record files>` exits 0;
  - its facts, in one shell command, `<line>` being `- <date> · <slug> ·`,
    the opening of its *Records* line (`D9`):
    `c=$(git log --reverse --date=iso-strict --format='%h %ad %at' -S'<line>' origin/<default> -- <record files> | head -1) && test -n "$c" && echo "plan/<slug> · record ${c% *}" && find plan/<slug> -newerct "@${c##* }"`
    — the folder, the first commit on `origin/<default>` that adds that
    line, with its author date, then every path in the folder whose ctime
    is newer than that date. The reasons Rule 2 records: a rebased record
    keeps its author date, a squash's is the merge time, and a rebase with
    `--ignore-date` or `--reset-author-date` resets it (`D11`), so the
    user decides with the list in front of them; `-newerct`, because
    `cp -p`, `tar` or `rsync -t` keep the old mtime but not the ctime, so a
    copied or restored folder shows as newer (`D15`); a `git log` fatal
    behind `| head -1` prints nothing and exits 0, so `test -n "$c"` fails.

  "The outcomes, the first that applies" (`session-rules/SKILL.md:89`):
  every check holds → listed with its facts; a file in it is tracked (a
  folder committed before 0.16.0) → not listed, never removed under the
  rule, one report line, no question; not landed → not listed, without a
  word; a check cannot be evaluated (`git fetch` fails, the `## Record` or
  the *Records* line not found, an empty record-file list, `$c` empty, a
  command errors) → not listed, one report line, no question; any other
  check fails (the slug pattern, a symlink, `realpath`, a `.git`) → not
  listed, named with the check that failed, and the manager asks
  (`glab:security`; `D27`). The manager asks once which listed folders to
  remove, removes only those the user names, each by `rm -r -- plan/<slug>`
  with no trailing slash, after every structural check up to the
  record-file list passes on it again right before; a folder the user
  keeps is not asked about again in that session. The date guard,
  `<record-sha>`, `<ref>`, `--ancestry-path`, `--is-ancestor`, `<land-sha>`
  and `lct` are gone (`D26`). Rule 2 has one standing approval again, *The
  handoff approval* (`session-rules/SKILL.md:78`); `glab:security`
  (`security/SKILL.md:146`) and Rule 3's *`glab:security` still stops you*
  (`session-rules/SKILL.md:115`) say "the standing approval", and
  `glab:audit` (`audit/SKILL.md:65`) says an audit file is not under "Rule
  2's plan-folder listing: ask".
- **`glab:bootstrap` step 5** (`bootstrap/SKILL.md:41`; `D7`, `D26`) runs
  Rule 2's listing and applies Rule 2's outcomes, in their order, each
  report line they give being a line of the session-start report; it asks
  the user once which listed folders to remove, with the facts of each,
  and removes only those named, by Rule 2's command and after its
  re-check, never one unasked. It no longer restates the outcomes.
- **The record is committed on the change's branch, after its push and
  before its merge** (`glab:project-record`, `project-record/SKILL.md:11`,
  the owner; `AGENTS.md:114`–`116`; `docs/one-fact.md` *Where the record is
  committed*; `[lifecycle-hardening/plan.md D3]`, `D27`), so that it lands
  with the change it records, in the same merge. A record on another
  branch still lands, and Rule 2 lists its folder the same way: the
  listing searches `origin/<default>`, not the branch. This record is
  committed on `lifecycle-hardening`, before PR #22's merge.
- **The record check and the reviewer read paths, not a diff**
  (`[lifecycle-hardening/plan.md D4]`): `glab:project-record` dispatches the
  analyzer with "the spec and feature-page paths — its record check says
  how it reads them —" (`project-record/SKILL.md:14`), and the full-tier
  `glab:project-reviewer` pass is "on the uncommitted spec and feature-page
  paths alone — the target only, as in Stage 5" (`:15`).
  `glab:project-analyzer`'s record check lists new, untracked pages with
  "`git status --short -uall --` on the spec and feature-page paths the
  dispatch names" (`project-analyzer.md:90`), the one place the rule is
  stated; `-- docs/` is gone from both files.
- **Every other statement of the removal points at Rule 2**: `AGENTS.md`'s
  `plan/` rule (`:117`–`118`, "lists `plan/<slug>` at a session start and
  removes it only on the user's word"), `README.md:42`–`44` and `:378`,
  `docs/one-fact.md` *The plan lifecycle*,
  `docs/features/docs-lifecycle.md` *When a plan folder is removed*,
  `glab:project-plan` (`project-plan/SKILL.md:126`) and
  `glab:project-record` (`:9`, "only on the user's word");
  `glab:product-manager:60` points at `glab:bootstrap` step 5 without "on
  the user's word" (`[lifecycle-hardening/review.r3.md 6]`, open in
  `docs/specs/product.md`).
- **The product level** — P6's "nothing to commit" test, `## Delivered`
  after the last `## Approval`, and the brief's precondition — is in
  `docs/specs/product.md`.

### The docs lifecycle as of 0.16.0

- **This subsection supersedes every line below it where they disagree
  about plan files, the record and the removal of a plan folder** (`glab`
  0.16.0, `3ed6746`, `docs-lifecycle`, PR #19, rebase-merged as
  `d2ca05b`); the files it names own each fact.
- **Plan files are working files; the docs are what stay**
  (`glab:project-plan` *Plan files are working files*, the owner,
  `[docs-lifecycle/plan.md D3]`): `/plan/` is ignored by git and never
  committed. The line is `/plan/`, anchored at the root, so a `src/plan/`
  elsewhere is not ignored (`D2`). `glab:bootstrap` step 5: when
  `git check-ignore -q plan/x` fails, the manager says so once and adds
  `/plan/` to `.gitignore` as a `glab:session-rules` Rule 1 trivial change
  with the next commit (`D4`). `glab:committer` never stages anything under
  `plan/`, even where `.gitignore` does not yet say so (`D15`). Every reader
  of a plan reads it from disk: the analyzers' plan revision is
  `sha256sum plan/<slug>/plan.md | cut -c1-12` (of `master.md` and
  `index.md` in a final or master check; `D16`), and `glab:push` step 4
  shows the slug's `## Decisions` lines from `plan/<slug>/` on disk (`D17`).
- **The record writes specs and feature pages** (`glab:project-record`,
  Stage 8; `[docs-lifecycle/plan.md M3]`, `D3`, `D7`, `D8`, `D24`): after Stage 7 has confirmed the push,
  from `plan/<slug>/` on disk, the area specs in `docs/specs/` and the
  feature pages `docs/features/<feature>.md` that `## Record` names
  (`## Record` names the pages, or `feature pages: none`;
  `glab:project-plan`), unless `AGENTS.md` names other places. A feature
  page says what the feature does, who it is for and how to use it, and
  never holds decisions, incidents, follow-ups or records (`D7`). The record
  check (`glab:project-analyzer`) reads the spec and feature-page diff, and
  each new, untracked spec or feature page whole, listed with
  `git status --short -uall -- docs/`; it also checks that a feature page
  makes no claim the spec contradicts and holds nothing that belongs in the
  spec (`D8`; `[docs-lifecycle/review.r1.md 3]`, `4`). **Since 0.16.2**
  the listing is "`git status --short -uall --` on the spec and
  feature-page paths the dispatch names", not `-- docs/`
  (`[lifecycle-hardening/plan.md D4]`). Stage 8 writes "the
  area spec and feature pages" (`glab:project-manager` *The pipeline*). The
  record never removes `plan/<slug>/` or an audit file.
- **The *Records* line** is stated once, in `glab:project-record`
  (`D18`, `D26`; `[docs-lifecycle/review.r1.md 5]`):
  `- <date> · <slug> · <first> · <last> · <branch> · <PR/MR, or pushed without a PR>`
  — the change's commits on the pushed branch by both ends, two short
  shas, not a range; a squash or rebase merge can give them new shas, so
  the branch and the PR are what to look up. Earlier *Records* lines keep
  their own form.
- **The plan-folder approval** (`glab:session-rules` Rule 2, the owner;
  `[docs-lifecycle/plan.md D5]`, `D22`–`D27`, `D35`–`D38`, `D42`, `D45`).
  **Superseded by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2;
  `[lifecycle-hardening/plan.md D26]`):** no plan folder is removed under a
  standing approval any more; the manager lists it and removes it only on
  the user's word (*The docs lifecycle as of 0.16.2*). Kept as the rule of
  0.16.0 and 0.16.1:
  the user's words "The manager removes plan/<slug>/ right after the record
  is merged, under a standing approval (like completed handoffs). Nothing
  piles up; the docs are the only lasting copy." (2026-11-18, in chat) are
  the other of the two standing approvals of a removal, beside *The handoff
  approval* (renamed from *The standing approval*,
  `[docs-lifecycle/review.r1.md 6]`). "Merged" means landed on the default
  branch, checked at the next session start; the manager removes, not
  `glab:project-record`. From the repo root, it covers `plan/<slug>` only
  when the slug matches the whole-name pattern and is not `handoff`;
  neither `plan` nor the folder is a symlink and the folder's `realpath` is
  `<toplevel>/plan/<slug>`; it holds no `.git` and no tracked file; the
  record-file list is non-empty; `git diff --quiet origin/<default> --
  <record files>` exits 0 after `git fetch origin`; and nothing in it is
  newer than `<record-sha>`, the first commit after `<last>` on `<branch>`
  touching the record files, guarded by `ct=… && test -n "$ct"`. Then
  `rm -r -- plan/<slug>`, with no trailing slash. Not landed → stays,
  silent; cannot be evaluated → stays, one report line, no question; a
  tracked file (a folder committed before 0.16.0) → never removed under
  it, one report line, no question; any other failure → the manager asks
  (`glab:security`). Every other removal stops and asks. The removal runs
  in one place, `glab:bootstrap` step 5 at a session start; it is not an
  exit condition of any stage or of the task boundary (`D24`).
  `glab:security` and `glab:session-rules`' *`glab:security` still stops
  you* now say "the standing approvals" (`D6`). An audit file is never committed and its removal is not under the
  approval: ask (`glab:audit`).
- **The product level** gains P7 Roadmap and `docs/roadmap/<slug>.md`:
  `docs/specs/product.md`.

### The project level as of 0.15.0

- **This subsection supersedes every line below it where they disagree**
  (`glab` 0.15.0, `db5feae`, `flow-project-level`); the files it names own
  each fact. Below, each line keeps its own record's facts and the names
  its record wrote; read them through the map in *The names*.
- **The names** (`[flow-project-level/index.md D1]`, `D2`; 01-rename,
  `0c49626`): `glab:<name>` → `glab:project-<name>` for the skills
  `manager`, `plan`, `develop`, `analyze`, `integrate`, `review`, `ship` and
  the agents `planner`, `plan-analyzer`, `analyzer`, `developer`,
  `integrator`, `reviewer`; `glab:product-project-plan-report` →
  `glab:project-plan-report`. `README.md` maps each old name (D17).
- **`glab:project-manager` holds no stage** (03, `db5feae`;
  `plugins/glab/skills/project-manager/SKILL.md`, 9998 bytes, the owner).
  Its sections: *The rules of every level*, *Your skills — this level only*,
  *What this session owns* (Rule 4), *The pipeline*, *Pick the tier*, *The
  master plan and sub-plans*, *Running agents in parallel*, *Dispatching the
  planner*, *After a report to product*, *Without subagent dispatch*, *What
  you never do*. Each stage is its *Run* cell's skill's: 1
  `glab:project-planner`, then `glab:project-plan-accept` (new: approval,
  hash, changed request, tier; `references/plan-mode.md`), 1b
  `glab:project-plan-analyze` (new), 1c `glab:project-plan-report`, 2
  `glab:project-develop`, 3 and 6b `glab:project-analyze`, 4
  `glab:project-integrate`, 5 `glab:project-review`, 6 `glab:commit`, 7
  `glab:push`, 8 `glab:project-record` (new); with no subagent dispatch,
  `project-manager/references/without-subagents.md` (D6). Each stage skill
  is invoked once per context, again only after a compaction (D14).
- **The tier line**: the planner writes it by `glab:project-plan` Step 0's
  criteria; `glab:project-plan-accept` accepts it or sends the plan back to
  be raised; a raise after acceptance is a `## Decisions` overrule line (03
  W3, D7). **Stage 3 and 6b dispatches carry the slug only**, plus a round's
  inputs from round 2 on; the `result.md` summary is for the user (W5, D8;
  `glab:project-analyze`). **`glab:project-planner` has no `Skill` tool**
  (D9).
- **`glab:severity`** (02, new) owns the four severity levels' meanings; the
  three project rating agents and `glab:product-analyzer` preload it instead
  of `glab:audit` (D10). It is a skill of every level. `glab:session-rules`
  Rule 5 lost its *why these models*; the rationale, for the record: "The
  plugin's author chose them for cost, and gave the reviewer no `haiku`
  default: it is the last gate" (02 W8). The four Go and PostgreSQL hazards
  are in `glab:bootstrap`'s `references/hazards.md` (02 W5).
- **The handoff file is per session** (02; `glab:session-rules` Rule 2, the
  owner; D21–D27): `plan/handoff/<session id>.md`, current state only, ≤
  4096 bytes, first line `- status: in-flight` or `- status: completed`.
  `manager-bootstrap.sh` reads `session_id` from the `SessionStart` hook's
  stdin with `jq`, used only if it matches
  `^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$`; else its text says `no session id`
  and the file is `plan/handoff/<UTC yyyymmddThhmmss>Z.md`. A closed stdin
  becomes `/dev/null` (`{ : 3<&0; }`) and an id's trailing newline is kept
  by a sentinel, so that id fails the match (B18, B19). `glab:bootstrap`
  step 5 removes other sessions' `completed` files, and takes over an
  `in-flight` one or the legacy `plan/SESSION-HANDOFF.md` only on the user's
  yes (D25, D26).
- **G5's bytes** (`master.md` *Final check* step 4; *before* as `master.md`
  G1 and G5 state it; *after*, the final check of 2026-11-18):
  | Measure | Before | After | Cap |
  |---|---:|---:|---:|
  | `proj` | 86621 | 44157 | 47104 |
  | `prod` | 57203 | 44924 | 47104 |
  | `task` | 101726 | 80206 | 81920 |
  | `list` | 9614 | 9541 | 10240 |
  | `files` = `onel` | 30 = 30 | 34 = 34 | equal |
  | `project-manager/SKILL.md` | 40284 | 9998 | 10240 |
  | `session-rules/SKILL.md` | 22435 | 13012 | 13312 |
  | `bootstrap/SKILL.md` | 8234 | 5212 | 6144 |
  | `project-analyzer` set | 26580 | 23423 | 3000 lower |
  | `project-plan-analyzer` set | 26288 | 23097 | 3000 lower |
  | `project-reviewer` set | 30973 | 27750 | 3000 lower |
  | `product-analyzer` set | 19657 | 16508 | 3000 lower |
  | `project-planner` set | 31168 | 30484 | no higher |

  **Re-measured by `remote-store`** (`0634bd5`, `glab` 0.18.0;
  `[remote-store/plan.md]` PC15): the `project-planner` set
  (`agents/project-planner.md`, `project-plan/SKILL.md`,
  `security/SKILL.md`, `cat … | wc -c`) is 31430, 31193 at `9f0c9bc`,
  already past 31168 at that base; its "no higher" measured
  `flow-project-level` against its own before, not a standing cap
  (`[level-guard/follow-ups.md FU-LG4]` as amended, `docs/specs/product.md`).

### The lines of earlier records

- **The product level is `docs/specs/product.md`** (since `glab` 0.14.0,
  `ce1a933`, `flow-product-level`): the product manager, its skills and
  agents, the shared store and `glab-shared-store:`, `plan-gate.sh` and
  the hash gate, the rejection cap, the start of project sessions and the
  walkthrough. This file keeps the project level's side of it, below.
- **`glab:session-rules`, the rules every level's manager runs under**
  (since `ce1a933`; `plugins/glab/skills/session-rules/SKILL.md`, the owner;
  `[flow-product-level/plan.md session-rules]`). Rules 0, 0b, 0c, 0d, 1, 2,
  3 and 5, *Round caps* and *The handoff line* moved, words kept, out of
  `glab:manager` into this new skill, which the session-start text loads at
  both levels (J2): both managers act on them, and the product manager may
  not read `glab:manager`. It was `[flow-product-level/plan.md FU-P1]`
  (closed, `docs/specs/product.md`), pulled forward because no other place keeps each rule once. Rule 4 stays
  in `glab:manager` — one session's surface is a project-level fact — and
  the moved Rule 5 names it as `glab:manager` Rule 4. Its first section is
  *The level boundary* (below), because after a compaction only the first
  part of a skill may be kept (`F22`); then *How to read these rules*: a
  stage, section or stage skill a rule names is the project level's, and at
  the product level it means the stage of the same role in that level's
  manager, a rule about a stage that level lacks not applying there;
  `plan.md` is `product-plan.md` there; and *Where a record line goes*,
  pointing at `glab:manager` Stage 1c for a reported plan. Rule 5's list
  gained the two product roles on `opus` (J2), Rule 0d's agent list too
  (review round 1 B10). Each manager opens with *The rules of every level*, citing them by
  number. Sizes, `wc -c` at `ce1a933`: `skills/manager/SKILL.md` 55251 →
  40284 bytes, `skills/session-rules/SKILL.md` 22435,
  `skills/product-manager/SKILL.md` 10897. This changes `glab:manager` for
  every project user, beyond the project edges, the words kept — the
  user's "go with your recommendations" of 2026-11-13 (I16, I17;
  `check-facts-2.md` B3 found it added by the plan, not asked for; the user,
  asked about keeping it, answered in those words, `master.md` *Request*). Every
  pointer to a moved rule names `glab:session-rules` (J12), the comments of
  `plugins/glab/scripts/context-size.sh` included (its code and test
  unchanged); `glab:manager` *What you never do* opens with one pointer to
  Rules 0b, 1, 2 and 3 instead of restating them (review round 1,
  advisory 1); the rule on a commit on `main` moved from Stage 6 into
  `glab:commit`, and `glab:commit` and `glab:push` name the stage of the
  manager of either level (R6).
- **The level boundary: each manager's explicit list** (since `ce1a933`;
  `glab:session-rules` *The level boundary*, the owner;
  `[flow-product-level/plan.md boundary]`). Each manager's *Your skills —
  this level only* (`skills/manager/SKILL.md`,
  `skills/product-manager/SKILL.md`) is the list that binds: invoke no skill
  and dispatch no agent not on your manager's list. Each list names its own
  manager skill (review round 1 A5), the level's skills and agents, and the
  skills of every level — `glab:session-rules`, `glab:bootstrap`,
  `glab:security`, `glab:comments`, `glab:audit`, `glab:commit`, `glab:push`,
  and since 0.15.0 `glab:severity`
  — with the agent `glab:committer`; these carry no level prefix. Every
  other skill's and agent's `description:` begins `Product level — ` or
  `Project level — ` (J1, J10, J11: `glab:manager`'s, six stage skills' and six agents'
  prefixed, with `glab:product-project-plan-report`'s fourteen
  `Project level` lines; no `name:` changed), a hint only, because the skill listing can drop
  descriptions to fit its budget (`F14`). The product agents have no `Skill`
  tool, so their `skills:` list is all they load — the one hard part of the
  boundary (`E11`); the main session's boundary is text only, every level's
  skills being listed in every session, and a hard boundary is
  `[flow-product-level/plan.md FU-P2]`, open (`docs/specs/product.md`).
  **Amended by `level-guard` (`632dcb0`, `glab` 0.17.0):** the skill
  half of the boundary is held by the `PreToolUse` hook, and FU-P2 is
  closed; the agent half stays text (*The level guard as of 0.17.0*).
- **The level line `glab-level:` and the session-start text by level**
  (since `ce1a933`; `plugins/glab/scripts/manager-bootstrap.sh`, rewritten
  whole by A3, its header comment the owner of the read rule;
  `tests/manager-bootstrap.test.sh` B1–B13). The first line of the repo's
  `AGENTS.md` that begins `glab-level:` names the level, a trailing CR and
  the blanks around the value dropped; `product` gives the product text,
  `project` or no line, no file or an unreadable file the project text, so
  every repo that predates levels starts as before with one level line
  above; any other value — `delivery` and `support`, reserved, a typo such
  as `Product`, `product2` or `product # note` — the project text with the
  warning `glab: level "<value>" is not built in this version of glab; this
  session runs at the project level` above it (R10), and on stderr for
  debugging only, since Claude Code shows no stderr of a hook that exits 0
  (`F5`). The repo is `$CLAUDE_PROJECT_DIR`, else `$PWD`, else — when that
  folder has no `AGENTS.md` — the top of its git work tree (`F4`). The level
  is a line of the repo, not an environment variable (*Rejected
  boundaries*). Each text opens with its level line, then point 2 loads
  `glab:bootstrap`, the manager of the level — `glab:manager` or
  `glab:product-manager` — `glab:session-rules` and `glab:security`, and
  the last line points at `glab:session-rules` Rules 1 and 0b. Sizes, the
  `additionalContext` piped through `wc -c` at `ce1a933`: project 2425
  bytes, product 2394 (2048 before), each under the 10,000-character cap
  that B8 checks. Its hook contract is an `AGENTS.md` *Rules* hook contract
  since `ce1a933`, stated once, in `docs/specs/marketplace.md` (*The repo's
  own rules*). `glab:bootstrap` steps 2 and 4 name the
  manager and the pipeline by level (J9).
- **Project Stage 1c and the develop gate** (since `ce1a933`;
  `glab:manager` Stage 1 *A brief is a request*, Stage 1c, acceptance
  checklist item 8; `glab:develop` *Preconditions*). A session told to
  "take the brief at `<store>/briefs/<project>/brief.md`" — by the user or
  by the product manager — plans it as a request; its `master.md` quotes it
  under `## Request` in the brief line, `- brief:
  briefs/<project>/brief.md sha256 <hash>` (`glab:plan` Step 3), and item 8
  sends back a plan from a brief without it (I2). **Stage 1c — Report to
  product, then wait**, once per slug: when the master and every sub-plan
  are planned, checked and given every approval their tiers need — a plan
  from a brief plans all its sub-plans before Stage 1c, each from the tree
  at the master's base (R2-1) — `/glab:product-project-plan-report {slug}`
  sends one report; the handoff line is `{slug} · report · r<n> · WAITING ·
  context <n>k`; the session tells the product session (none needed when
  that session started it and watches its idle notice), updates the
  handoff file and ends its turn. From the first report on the hashed files
  are frozen, and every record line the rules would write into them goes
  to `plan/{slug}/after-verdict.md` instead — Stage 1c owns that rule, the
  other files point at it (review round 1 A4, B9). On `REJECTED`: round
  copies, a new `glab:planner` amending from the verdict's reason as its
  findings, one Stage 1b delta round per verdict outside Stage 1b's cap,
  the approvals again, report `r<n+1>`; a `REJECTED` whose fix needs
  `master.md` is a changed request (R13). **`glab:develop`** runs
  `plan-gate.sh check plan/<slug> <store>` on every dispatch, fix rounds
  included, when the slug's `master.md` has the brief line or its
  `waived.md` names a brief — a user's waiver of planning is not a waiver
  of the product's verdict, so a waiver from a brief is always refused and
  planned (review round 1, the waiver case; T36) — and stops on anything
  but `ACCEPTED r<n> <digest>`. Plans without the line are unchanged. The
  rejection cap is the product level's (`docs/specs/product.md`); the
  project session reports and waits.
- **The commands are gone; they are stage skills** (since `glab` 0.13.0,
  `6f8b948`, `flow-commands-to-skills`; `[flow-commands-to-skills/plan.md]`
  request 1 and decision FU1-4). `plugins/glab/commands/` no longer exists.
  Seven of its eight commands moved with `git mv` to
  `plugins/glab/skills/<name>/SKILL.md` — `analyze`, `commit`, `develop`,
  `integrate`, `push`, `review`, `ship` — and `commands/plan.md` was removed
  with `git rm`, its wrapper text not carried over (*`glab:plan`*, below). A
  person still types `/glab:<name>` to step in; `glab:manager` invokes each
  stage skill itself through the Skill tool, with the argument *Run* shows
  (`glab:manager` *The pipeline*, the paragraph after the table, which owns
  it). Each stage skill carries a bare `name: <name>`, the command's
  `description` and `argument-hint` (only `develop`'s description reworded,
  A4), and no `allowed-tools`, `model`, `disable-model-invocation` or
  `user-invocable` key: `disable-model-invocation` would stop the manager's
  Skill-tool call and a preload (`[flow-commands-to-skills/plan.md F4]`, the
  decision on invocation). **A stage skill is an entry point** —
  preconditions, the agent it dispatches, a pointer: routing, dispatch lists
  and gate runs are the manager stage's, which won where the two disagreed;
  `glab:push` keeps its own procedure and `glab:ship` its verdict gate, which
  no manager stage holds (FU1-4). They speak of "the user" and "the session
  that runs it", never in the first person (54 first-person words in the
  commands, `:0` in each of the seven skills, `[flow-commands-to-skills/result.md]`
  A3), and every wait for the user stays — push's go-ahead, the force-push
  and upstream choices, `main` before pushing, a commit on `main`, full-tier
  approval, Rule 3 questions. With no `disable-model-invocation`, the model
  may load `glab:push` or `glab:commit` on its own, as it could the
  commands; push still waits for the go-ahead and commit never pushes
  (`[flow-commands-to-skills/plan.md I2]`). `name: <name>` also gives a bare
  `/push`, `/ship`, `/develop` where nothing else holds the name; accepted,
  since each keeps its waits (`I5`, the decision on bare aliases). Review
  round 1 settled four seams the move opened (`[flow-commands-to-skills/review-1.md]`,
  each now in its owner): a `/glab:ship` fix with no plan behind it is a
  `glab:developer` fix round whose contract is the review findings quoted in
  the dispatch, the one exception to the developer's `BLOCKED: no contract`
  (`skills/ship/SKILL.md`, `agents/developer.md` Step 1; A1); Stage 3's
  `CONFORMS` goes to Stage 4 (A3); where a stage skill says to show an
  agent's report, Rule 2 wins when the manager invoked it — the verdict, the
  counts and the report's path (A4); a stage skill with no slug asks which
  plan, never the most recent (B7) — the last two stated once, in
  `glab:manager` *The pipeline*.
- **`glab:plan` replaces `glab:plan-first`** (since `6f8b948`;
  `[flow-commands-to-skills/plan.md]` request 4, the user's "Yes, merge
  them", and Q1, the user's "A: plan only"). `skills/plan-first/SKILL.md`
  moved with `git mv` to `skills/plan/SKILL.md`, named `plan`, and
  `skills/plan-first/implement.md` was removed with `git rm`: one skill, the
  planning procedure, Steps 0 to 4, which stops at Step 4. The one rule
  `implement.md` held that `glab:developer` lacked is now `developer.md` Step
  3 (D4b). Step 0 points at
  `glab:manager` Rule 1 for trivial work and stops; *User Override* alone
  holds the user-only waiver rule, and Stage 1 names the manager as the one
  who writes `waived.md` under it (R2-1, R2-2); Step 3 gained the three
  phases, which the manager's checklist item 2 checks (A5). **Who plans**
  (`glab:manager` Stage 1, the owner): the manager dispatches `glab:planner`
  directly, with no stage skill between, and the planner preloads
  `glab:plan`. **A `/glab:plan <task>` the user types plans in the user's
  session**: the manager follows `glab:plan` Steps 0 to 4 itself — the
  user's choice, so not a breach of Rule 2 or Rule 5 — and every plan
  request the user does not type as `/glab:plan` still goes to
  `glab:planner` (review round 1 A2, decided by the user, "Plan in my
  session"). `glab:plan`'s `description` says the same, so the model does
  not pick the inline procedure for an ordinary build or fix request; it
  sets no `disable-model-invocation`, which would stop the preload.
  `glab:planner` keeps its `Skill` tool to load `glab:manager` for the
  sections `glab:plan` points at — *Pick the tier*, Rule 3, Stages 1b and 8
  — and is told not to load `glab:plan` through it again
  (`agents/planner.md`; PL1, F2-9; review finding A6 rejected, its cost
  `[flow-commands-to-skills/follow-ups.md FU-3]`). Every `plan-first`
  reference was renamed; `git grep -n plan-first -- ':!docs/specs/' ':!plan/'`
  prints one line, `README.md:166`, the old copy install's migration step,
  which deletes a `~/.claude/skills/plan-first/` that keeps that name
  (`docs/specs/marketplace.md`).
- **Each rule has one owner: the role that acts on it** (since `6f8b948`;
  `[flow-commands-to-skills/plan.md]` request 2 — the user: "agent must
  receive the thing once and clear, Skills should not have a repeating
  context for project manager skills"). The acting role's file owns the
  rule; every other file drops it or keeps a pointer. Three audits
  (`audit-a-model.md` A1–A30, `audit-b-agents.md` B1–B33,
  `audit-c-shared.md` C1–C18) gave 81 findings, 62 applied and 19 merged,
  none rejected (*Disposition*). The general rule is stated in `AGENTS.md`
  *One fact* (`docs/specs/marketplace.md`) and, for what reaches an agent,
  in `glab:manager` Rule 0c. What moved, by owner: Stage 1b's per-analyzer
  checks and their case into `glab:plan-analyzer` *The plan check*, the
  manager keeping one pointer (FU1-1, A2); the gate order and the
  changed-code gate against a whole-tree sweep in `glab:developer` Step 3 and
  `glab:bootstrap` step 3, Stage 2's verify one pointer (C12; review finding
  B3, applied the plan's way after the developer stopped it as `PLAN WRONG`);
  the round caps in *Pick the tier* and the reviewer's own round-2 rule in
  `agents/reviewer.md` *Re-reviews*, the analyzers' round-3 sentence gone
  (A13; the manager's Stage 5 restatement too, review round 1); the temp-file
  rule in the session-start text, point 4, `glab:bootstrap` step 6 pointing
  at it; the missing-`AGENTS.md` fallback in each agent's first step and the
  session-start text; a commit on `main` in `agents/committer.md` Step 3;
  the severity meanings in `glab:audit` only; the deleted-`TODO` reasoning in
  `glab:comments`. Cases are kept once, beside their rule: Stage 1b's in
  `plan-analyzer.md`, the DSN leak in `glab:security` *Secrets never enter
  output*, `make lint` and the 85 mockgen files in `analyzer.md` Step 4, the
  cached test in bootstrap step 6. `glab:security` Rule 8 gained the two
  items the move would have lost (B8). Sizes, `wc -c`: `manager/SKILL.md`
  61959 → 55251 bytes, `bootstrap/SKILL.md` 12145 → 7720.
- **Shared skills reach agents through frontmatter `skills:`** (since
  `6f8b948`; FU1-2 and the decision on the preload lists). A shared rule lives
  once, in `glab:security`, `glab:comments` or `glab:audit`, the planner's
  procedure in `glab:plan`, and each agent's frontmatter `skills:` list,
  written `glab:<name>` as a YAML list, preloads what its role uses:
  `glab:security` in all seven; `glab:comments` in `glab:developer`,
  `glab:integrator` and `glab:reviewer`, which write or judge code and its
  comments; `glab:audit` in `glab:reviewer`, `glab:analyzer` and
  `glab:plan-analyzer`, which rate by its *Severity Levels*; `glab:plan` in
  `glab:planner`. The docs say a preload injects the skill's full content and
  needs no `Skill` tool (`[flow-commands-to-skills/plan.md F12]`); the
  restatements of `glab:security` in the agent files went once each agent
  preloaded it, and what only the role does stays — the developer's closed
  list and record rules, the integrator's container rules, the committer's
  deny-list. `plugin validate --strict` passes a wrong entry and `plugin
  details` shows no list (`F13`), so a skills gate prints each entry
  (`docs/specs/marketplace.md`). That the content loads is UNVERIFIED
  (*Known limits*, U4, U5), and so is what it costs per dispatch (U7).
  Since `glab` 0.14.0 (`ce1a933`) nine agents; the two product agents'
  `skills:` lists are in `docs/specs/product.md` (*Two levels in one plugin*).
- **A dispatch carries only facts about its task** (`glab:manager` Rule 0c,
  since `6f8b948`; FU1-3): the slug and step ids, the file boundary, the
  sub-plan paths, decisions and answers not in the plan, the round and its
  inputs, the temp directory, the `effort` and `model` parameters — never a
  standing rule, "not 'read `AGENTS.md`', not a skill the agent preloads, not
  a rule its own file holds". An agent with no definition has no `skills:`
  list, so its dispatch names `glab:security`, and `glab:audit` when it
  produces findings: its one channel. `docs/constants.md` is read by
  `glab:planner` alone, and every later agent works from the plan (R11). The
  temp directory is a value the agent cannot see, so the dispatch carries it;
  "never `/tmp`" is said once in each agent file that writes temp files
  (B10). Rule 5's report-template paste for `sonnet` and `haiku` is gone —
  the agent's own *Report* is its template, Rule 5's report check the
  backstop — reversing a 0.12.0 dispatch choice, not the model table (B23;
  *The model rule*, below). `glab:bootstrap` step 2 and the session-start
  text's point 3 shrank to say so.
- **The session-start text** since `6f8b948` (`plugins/glab/scripts/manager-bootstrap.sh`,
  H1; 2418 → 2048 bytes of context, `bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext | wc -c`):
  four points — read `AGENTS.md` (or `CLAUDE.md`, said plainly) and
  `docs/constants.md`; load `glab:bootstrap`, then `glab:manager` and
  `glab:security`; each agent loads its own rules, a dispatch carries only
  its task's facts and passes `effort` (Rules 0c, 0d); the host file's temp
  directory — and two pointer lines, to Rule 1 and Rule 0b. It names no stage
  sequence: it points at `glab:manager` *The pipeline* "as far as *Pick the
  tier* runs it", and `glab:bootstrap` step 4 does the same, so the
  manager's description is the one file that lists the stages. Since
  `glab` 0.14.0 (`ce1a933`) there is one text per level: *The level line
  `glab-level:` and the session-start text by level*, above.
- **Session start.** The `SessionStart` hook injects the irreducible rules
  (load `glab:bootstrap`, `glab:manager`, `glab:security`; read `AGENTS.md`,
  or `CLAUDE.md` and say there is no agreement; agents carry `glab:security`
  and `glab:comments`, and every dispatch passes the Agent tool's `effort`
  at the session's level, Rule 0d, since `abda43a`; the host file's temp
  directory); `glab:bootstrap` runs
  the full sequence — agreement and `docs/constants.md`, skills, the repo's
  real gates, the handoff, the host's hazards — and ends on the one-line
  check. The hook text and the skill are one fact (`AGENTS.md` *One fact*).
  History, until `glab` 0.13.0 (`6f8b948`): that was so; since then each
  session-start rule has one owner and the *One fact* entry "the
  session-start rules" is gone (`[flow-commands-to-skills/plan.md R2-5]`,
  review round 1 A5 and B2): the hook text owns the read order, the
  fallback and the temp-file rule, `glab:bootstrap` points at it, and
  "agents carry `glab:security` and `glab:comments`" became "each `glab`
  agent loads its own rules" (*The session-start text*, above).
- **The pipeline** (`glab:manager` *The pipeline*; since `glab` 0.14.0,
  `ce1a933`, a row 1c, Report to product, for a plan from a brief, once per
  slug, and the handoff line's format in `glab:session-rules` *The handoff
  line* — *Project Stage 1c and the develop gate*, above; since `glab` 0.13.0 each
  `/glab:<name>` below is the stage skill the manager invokes itself, and
  Stage 1 dispatches `glab:planner` with no stage skill between): 1 Plan
  (`/glab:plan` until 0.13.0,
  `glab:planner` since `glab` 0.12.0, `09d5664`),
  1b Analyze the plan (`/glab:analyze`, plan only, `glab:plan-analyzer`
  since `09d5664`), 2 Develop
  (`/glab:develop`), 3 Analyze conformance, 4 Integrate (`/glab:integrate`),
  5 Review (`/glab:review`), 6 Commit (`/glab:commit`), 6b Final check
  (`/glab:analyze {slug}` as the final check, since `glab` 0.11.0,
  `0cbf5b0`; *Stage 6b*, below), 7 Push
  (`/glab:push`, no push agent), 8 Record (after the push: `glab:developer`
  on the record, `glab:analyzer` on what it carried, then `/glab:commit`; it
  leaves on the record commit verified, then pushed on the user's go-ahead).
  A change with a plan folder goes on from Stage 7 to Stage 8. Each handoff
  is one line, `slug · stage · round n/max · verdict · effort <level> · context <n>k`
  (Rule 0d; `slug · stage · round n/max · verdict` before `abda43a`; the
  `· context <n>k` field since `glab` 0.9.0, `2a1e919`, with
  `· dispatches <d>` in its place only when no `glab: context` line has
  come in the session — *The context rule*, below), with
  `model <m>` after the stage on every line of a stage that dispatches an
  agent (Rule 5; since `09d5664`, `[flow-models-per-role/plan.md D11]`:
  the definition's alias when no parameter was passed, `model <alias> (user)`
  when the user's override was; until then on a develop or review line
  only, `model default` when the user had named none). `max` is the
  stage's round cap, `2`, or `3` once the round-3 line is written, and a
  develop line counts its fix rounds against the cap of the stage whose
  findings it fixes (`glab:manager` *The pipeline*;
  `[flow-cheaper-rounds/plan.md D24]`). The effort is the
  level passed ("The effort is the level you passed.", *The pipeline*, as
  of `467b7c4`). History, until `glab` 0.8.0 (`467b7c4`, 2026-10-20): the
  sentence went on "for a Codex agent the level sent, after Rule 6's
  mapping; an OpenCode line names no effort, since OpenCode takes none".
  Without subagent dispatch each stage is a fresh
  session, `<slug> record` among them, and `<slug> final` since `0cbf5b0`.
  With sub-plans the handoff line names the sub-plan for the slug,
  `{slug}/02-hooks · analyze · round 1/2 · …`. The stage sequence is one
  fact in three places (`AGENTS.md` *One fact*, since `0cbf5b0`): the
  manager's description reads "→ review → commit → final check → push →
  record", the bootstrap diagram (step 4) "review ⇄  →  commit  →  final
  check  →  push  →  record", and the hook text "plan -> develop -> analyze
  -> integrate -> review -> commit -> final check -> push -> record, as far
  as the tier runs them (`glab:manager` -> *Pick the tier* says which)" —
  no tier runs every stage once a single full-tier plan skips the final
  check (`[flow-master-plan/plan.md D33]`, `D40`). Until `0cbf5b0` the hook
  text read `-> push -> record at full tier`. History since `glab` 0.13.0
  (`6f8b948`): the bootstrap diagram and the hook's stage list are gone, both
  pointing at *The pipeline*, and the *One fact* entry "the stage sequence"
  with them (`[flow-commands-to-skills/plan.md R2-5]`, BS4, H1); the
  manager's description is the one listing left.
- **The tier** (`glab:manager` *Pick the tier*), the first line of `plan.md`
  with its reason; no tier line means full. **Full**: a schema or data
  migration, a stored or wire format, code that decides who may do what,
  handles secrets or moves money — `evidence.md` (`findings.md` until
  `glab` 0.10.0, `2912002`), `plan.md`, `questions.md`
  if a question was raised, the user's explicit approval, 1b at most 2
  rounds, conformance at most 2 rounds, the whole suite at integrate, review
  at most 2 rounds. **Normal**: everything else — a one-page `plan.md`, no
  approval (the tier and decisions are reported), 1b at most 2 rounds, no
  conformance stage, the milestone test at integrate, review at most 2
  rounds. **Since `glab` 0.11.0** (`0cbf5b0`) every tier that plans writes
  `master.md` too (*The master plan and sub-plans*, below); the *Approval*
  row reads "Approval, after 1b": at normal tier yours, reported — the
  user's when the work split — and at full tier the user's, explicit, of
  `master.md` and of every full-tier `plan.md`, a single plan's or a
  sub-plan's; a sub-plan runs Stage 3 at every tier, max 2 rounds; and the
  row "6b Final check" is max 2 rounds at normal tier and at full tier,
  where a single plan uses Stage 3's instead. Until `0cbf5b0` full-tier
  approval came before Stage 1b (`[flow-master-plan/plan.md D26]`).
  **Trivial**: Rule 1's five lines, done directly. Each cap can
  grow by one round under *Round caps*, below (`glab:manager` *Pick the
  tier*, as of `2a1e919`). History, until `glab` 0.9.0 (`2a1e919`): the
  caps were 1b 2 rounds (full) or one pass (normal), conformance 4, review
  3 (full) or one round whose findings were fixed once (normal).
  An analyzer or reviewer that finds a full-tier trigger raises the tier;
  only the user lowers one. The tier table's **8 Record** row: none at
  trivial; at normal, "after the push: the area spec updated and
  `glab:analyzer`'s check that every follow-up, decision and incident is
  carried, in one docs commit"; at full, "the same, with one `glab:reviewer`
  pass on the spec diff alone". It replaced the **Spec** row of `6838133`
  ("a short entry", "checked by independent readers"), which had no stage,
  owner or place (`[sync-local-edits/follow-ups.md 10]`, now closed).
- **The rules of `glab:manager`**, one line each — since `glab` 0.14.0
  (`ce1a933`) all of them but Rule 4 live, words kept, in
  `glab:session-rules`, and the manager cites them from there
  (*`glab:session-rules`*, above); each line below names the rule as it
  reads there:
  - Rule 0 — read `AGENTS.md` first (or `CLAUDE.md`, saying there is no
    agreement), and make every dispatched agent read it, with
    `docs/constants.md` where there is one. Since `glab` 0.13.0 the rule
    points at the session-start text and `glab:bootstrap` step 1 for what
    to read; each agent reads `AGENTS.md` in its own first step, only
    `glab:planner` reads `docs/constants.md`, and a dispatch repeats neither
    (Rule 0c).
  - Rule 0b — `glab:security` runs alongside: paste the command and its
    output or write `UNVERIFIED`; no stage is green on an agent's word.
  - Rule 0c — since `glab` 0.13.0 (`6f8b948`), "what reaches an agent, and
    once": each rule through one channel — the agent's own file, a shared
    skill its `skills:` list preloads, or the dispatch, which carries only
    the facts of its task (*A dispatch carries only facts about its task*,
    above). History, until `6f8b948`: every dispatch named `glab:security`
    and `glab:comments`; `glab:audit` and `glab:plan-first` per dispatch,
    with the plan-first seam stated; from `09d5664` `glab:plan-first` was
    "for `glab:planner`, the planning agent".
  - Rule 0d — every dispatch, to every subagent, passes the Agent tool's
    `effort` parameter at the session's level (*The session effort*,
    below); since `abda43a`. Since `09d5664` its agent list names
    `glab:planner` and `glab:plan-analyzer` too, and "An agent dispatched
    with no `model` parameter — on its definition's model (Rule 5) — still
    gets `effort`."
  - Rule 1 — the manager does not implement; questions and trivial changes
    are not the pipeline.
  - Rule 2 — the context budget: never read what an agent will read; agents
    write long output to disk and return a short report. Since `glab` 0.9.0
    it also holds *Every round is a new agent* and *Your own context — read
    it, act on it, never clear* (below), because the reason of both is cost.
  - Rule 3 — engineering choices are the manager's, recorded under
    `## Decisions`; the user is asked only when a choice is destructive,
    costs money, exposes real data or changes what the product is — at most
    one question per plan.
  - Rule 4 — one surface per session; seams are settled through the channel
    `docs/constants.md` names, or the user relays.
  - Rule 5 — since `glab` 0.12.0 (`09d5664`), "each agent runs on its
    role's model; the user's words override it" (*The model rule*,
    below): each of the seven agents' definitions sets its model, and the
    user's words, passed as `sonnet`, `opus`, `haiku` or `fable`, override
    it for the role they name. Since `glab` 0.13.0 (`6f8b948`) its version
    floors live in this spec, not in the rule (*Rule 5's version history*,
    below). History, from `467b7c4` until `09d5664`: the
    model a `glab:developer` or `glab:reviewer` runs on was the user's call,
    `sonnet`, `opus`, `haiku` or `fable`, and nothing else; every other role
    got no `model` parameter. History, until `glab` 0.8.0 (`467b7c4`,
    2026-10-20): an external reviewer on OpenCode or Codex, and an external
    developer on Codex only, were included. "Only the reviewer, on either
    backend, and the developer, on Codex, can be external; no other role
    ever is." That paragraph and sentence are gone; a name the parameter
    does not take is said and asked about ("ask which of the four the user
    means").
  - Rule 6 — **gone since `glab` 0.8.0 (`467b7c4`, 2026-10-20)**: it was the
    last numbered rule, so nothing was renumbered
    (`[remove-external-agents/plan.md D14]`); *Know the gates before you
    dispatch* follows Rule 5. History, as it read until then: an external agent, an OpenCode or a Codex session, is the
    user's call, its reply untrusted (`docs/specs/external-agents.md`), for
    read-only work, **except a Codex developer under Rule 5**: an OpenCode
    agent works on a read-only copy in the script's sandbox; a Codex agent
    works in the repository itself under Codex's own sandbox — read-only, or
    workspace-write for a developer — and its commands can read any file the
    user can, outside the repository too. Its two exceptions since
    `feature-external-developer`: *It changes nothing*, "except a Codex
    developer under Rule 5, which changes files in the repository and
    nowhere else"; and *It takes no stage's role*, "except the developer and
    the reviewer under Rule 5". Only when the user asks, naming the model
    for OpenCode — for Codex, naming one or leaving it to Codex's default.
    **Codex's effort** is the session's (Rule 0d), or the level the user
    named for that agent or role (below).
- **Agents** (`plugins/glab/agents/`; nine since `glab` 0.14.0, `ce1a933`,
  with `glab:product-planner` and `glab:product-analyzer`, both `opus` —
  `docs/specs/product.md`, *Two levels in one plugin* — and each project
  agent's description prefixed `Project level — `; seven since `glab` 0.12.0,
  `09d5664`, each with its frontmatter `model`, *The model rule* below):
  `glab:planner` (`model: opus`, new in `09d5664`: plans one task in its
  folder by `glab:plan-first` and stops where that skill says planning
  ends; never writes code, never edits outside the plan folder its dispatch
  names — a new sub-plan's line in the slug's index and a new master when
  the user changed the request only when the dispatch grants it — never
  stages or commits; `tools: Read, Write, Edit, Grep, Glob, Bash, Skill,
  WebFetch, WebSearch`, no `Agent`; restates no `glab:plan-first` value,
  `[flow-models-per-role/plan.md D4]`, `D5`, `D18`), `glab:plan-analyzer`
  (`model: opus`, new in `09d5664`: the plan check and the master check of
  Stage 1b, with the intent question's plan-check part and the plan-check
  re-checks, ending `BUILDABLE`, `NOT BUILDABLE` or
  `BLOCK: target unresolved`; read-only, `tools: Read, Grep, Glob, Bash`;
  a conformance, final or record check dispatched to it ends
  `BLOCK: target unresolved`, naming `glab:analyzer`; `D6`, `D18`, `D20`),
  `glab:developer` (`model: sonnet`; builds the named
  steps, writes `plan/{slug}/result.md` and `follow-ups.md`, never stages;
  at the record it updates the area specs only and writes no `result.md`),
  `glab:analyzer` (`model: sonnet`; since `09d5664` the conformance check,
  the final check and the record check of Stage 8, ending `CONFORMS`,
  `DIVERGES: <n> steps` or `BLOCK: target unresolved`, and a plan check or
  master check dispatched to it ends `BLOCK: target unresolved`, naming
  `glab:plan-analyzer`, `D6`, `D7`; until `09d5664` it also did the
  plan-only analysis of Stage 1b — since `0cbf5b0` the plan check and the
  master check, with `BUILDABLE` and `NOT BUILDABLE` — each check with the
  intent question since `0cbf5b0`), `glab:integrator`
  (`model: sonnet`; the real running system, local only), `glab:reviewer`
  (`model: sonnet`; correctness and
  `AGENTS.md` rules, gets the target and nothing else; its verdict lines are
  one fact with `ship.md` and the manager — and, until `467b7c4`, the
  external-agent validator),
  `glab:committer` (`model: haiku`; explicit paths, never `git add -A`;
  Conventional Commits as `AGENTS.md` says). Until `09d5664` there were
  five agents, none with a `model` line, and no planning agent of its own:
  `/glab:plan` had the invoking session follow `glab:plan-first` itself,
  and the manager dispatched a generic agent for planning, on the main
  conversation's model (`[flow-models-per-role/plan.md E7]`, inferred
  there). **Since `glab` 0.13.0** (`6f8b948`) each of the seven also has a
  frontmatter `skills:` list (*Shared skills reach agents through
  frontmatter `skills:`*, above); `glab:planner` follows the preloaded
  `glab:plan`, not `glab:plan-first`; `glab:plan-analyzer` holds Stage 1b's
  per-analyzer checks and their case, and its step status `done` became
  `buildable` (B16); `glab:developer` holds the gate order, the changed-code
  gate rule and `implement.md`'s one rule in Step 3, and its *A fix round*
  takes an integrator's `FAILED: <n> regressions` (header
  `integrate round <n>`) and a no-plan `/glab:ship` fix (review round 1 A1,
  A7/B4). **Commands** — history: removed in `glab` 0.13.0 (`6f8b948`), now
  the stage skills (above); as they stood until then
  (`plugins/glab/commands/`): `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`,
  `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship`. Since
  `09d5664` `/glab:plan` uses the `glab:planner` agent, "dispatched as
  `glab:manager` Rules 0c, 0d and 5 say; it follows the `glab:plan-first`
  skill", as `/glab:analyze` dispatches its analyzer (`D4`); its three gates
  and its report list are unchanged. `/glab:analyze` keeps its one name and
  its slug argument and **routes by kind** (`D8`, `commands/analyze.md:6`
  as of `517b7b6`): the check is named in the dispatch message or by the
  user, never in `$ARGUMENTS`, which is only the slug; a named check comes
  first, whatever the folder holds — a plan check or a master check
  (Stage 1b) goes to `glab:plan-analyzer`, even when a `result.md` from an
  earlier build is there, as after a plan is amended; a final or record
  check (Stages 6b and 8) to `glab:analyzer`; with no check named, the
  folder settles it — a `result.md` under `plan/$ARGUMENTS/` means the
  conformance check, `glab:analyzer`, none means the plan check,
  `glab:plan-analyzer`; a named check that is none of these is asked about,
  never guessed. The named check is tested before the folder because a
  slug with sub-plans has no `result.md` at its own level, so its final
  check would otherwise reach `glab:plan-analyzer` (review round 1,
  `[flow-models-per-role/result.md R2.4]`, the manager's decision, which
  replaced "otherwise ask which check" for every unnamed check with a
  `result.md`); and a named plan or master check is tested before the
  folder because an amended plan keeps its earlier `result.md` (the PR #7
  review comment, fixed in `517b7b6`, D8 updated in place). A plan or
  master check sent to `glab:analyzer`, or a conformance, final or record
  check sent to `glab:plan-analyzer`, ends `BLOCK: target unresolved`
  (`[flow-models-per-role/result.md blast-radius]`). Since `09d5664`
  `/glab:analyze`, `/glab:integrate` and `/glab:commit` say their agent is
  "dispatched as `glab:manager` Rules 0d and 5 say" (review round 1,
  `[flow-models-per-role/result.md R2.10]`).
  Since `glab` 0.8.0 (`467b7c4`) no command has an external path:
  `/glab:develop` dispatches `glab:developer` only, and `/glab:review` and
  `/glab:ship` the `glab:reviewer` only; `/glab:ship` keeps
  `BLOCK: 1 issue` among its verdicts (`[remove-external-agents/plan.md D9]`).
  History, until then (2026-10-20): `/glab:develop` had an external path: when Rule 5 recorded an external
  developer, *Dispatch* starts it through `glab:external-agents` with
  `--role developer` instead of dispatching `glab:developer`, with the same
  brief — one agent, never split and never beside a `glab:developer`
  (*Decide the split*); *When the agents return* handles it first, before
  the gates: the exit and the `git:` line (any exit but 0, or
  `git: changed`, stops the pipeline: the user is shown the `changed:` lines
  and nothing is reverted, committed or re-run); then, only on 0 with
  `git: unchanged` and no nested repository refused, the manager reads the
  whole change against the plan without a filter
  (`git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u -- - <path>`
  per tracked path, untracked and ignored regular
  files read directly, links and special files never opened, neither
  `git status` nor `git diff` before that); then writes `result.md` from its
  reply, marked as that model's words, with the `changed:`/`git:` lines and
  the gates as it ran them; then the gates (`commands/develop.md` at
  `33a28df`). `/glab:review`
  named Codex: an external reviewer the user named was "a backend, and for
  OpenCode a model", run through `glab:external-agents` with the same
  target; an OpenCode reviewer's copy held only `HEAD` and the working
  tree, so a branch or a range could not be its target, while "a Codex reviewer
  works in the repository and can take one" (`commands/review.md:8` at
  `6b2a024`); both external paths ended at `467b7c4`. `/glab:ship` reviews
  the working tree only, then as now. Every agent
  and command falls back to `CLAUDE.md` when `AGENTS.md` is missing, and the
  reviewer then puts `agreement: no AGENTS.md — correctness only` on its own
  line above an unchanged verdict line.
- **Round caps** (`glab:manager` *Pick the tier*, *Round caps*, as of
  `2a1e919`, `glab` 0.9.0). Stage 1b, Stage 3 and Stage 5 each run at most
  **2 rounds** at every tier where the stage runs (normal tier has no Stage
  3). Since `0cbf5b0` the final check (Stage 6b) has the same cap, and
  every cap counts per sub-plan where there are sub-plans; normal tier runs
  Stage 3 for a sub-plan; a sub-plan's round-3 line and round copies stay
  in its folder, and the master and final checks have theirs in `index.md`
  (`plan.md` with no sub-plans) (`[flow-master-plan/plan.md D29]`). A
  **third** round runs only when round 2 returned a finding rated
  `critical` or `high`, and only after the manager has recorded it under
  `## Decisions` as `- round 3: <stage> — <severity> <the finding, as its
  file:line or step id and its claim>`; with no plan behind the stage — a
  `/glab:review` or `/glab:ship` run on its own — the reason goes in the
  handoff line that announces the round, `round 3/3 (<severity> <finding>)`,
  and in the conversation, and once it can no longer be found there is no
  round 3. Nothing runs past round 3. The reviewer's side
  (`agents/reviewer.md`): round 2 is the last unless the reviewer reports a
  `critical` or `high` finding in it and answers `BLOCK: <n> issues`; round
  3 is the last with no exception; a round-2 `BLOCK` with no `critical` or
  `high` finding is that last round's verdict, there is no round 3, and it
  goes to the user (Rule 5's report check is for a malformed report only).
  What a stage does when its last round has not passed is unchanged: 1b at
  full tier → the user ("needs a design"); 1b at normal tier → after round 2
  a new planner amends once more and the plan goes on, `PLAN WRONG` the
  backstop; after a round 3, at every tier → the user; Stage 3 → the user
  with the three resolutions; Stage 5 → the last-round answer to the user
  (`[flow-cheaper-rounds/plan.md D6]`). At the last round the answer is
  `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>` or `DO NOT PUBLISH: <why>`;
  the verdict strings did not change. The round caps are one fact in
  `reviewer.md`, `analyzer.md`, `ship.md`, the manager and bootstrap
  (`AGENTS.md` *One fact*), and `plan-analyzer.md` since `09d5664`. Since
  `glab` 0.13.0 (`6f8b948`) the entry names two owners only, `glab:manager`
  *Pick the tier* and the reviewer's round-2 rule in `agents/reviewer.md`
  *Re-reviews*: the analyzers only rate, so their round-3 sentence went, and
  `glab:bootstrap`, `glab:ship` and Stage 5 point instead of restating
  (`[flow-commands-to-skills/plan.md]` A13, R1; review round 1, the
  repeat at `manager:342`). History, until `glab` 0.9.0: plan analysis 2
  (full) or one pass (normal); conformance 4; review 3 (full) or 1
  (normal), "round 1 of 1" in Rule 5's example line.
- **Every round is a new agent** (`glab:manager` Rule 2, *Every round is a
  new agent*; `commands/develop.md`, `commands/ship.md`,
  `commands/analyze.md`; `[flow-cheaper-rounds/plan.md D7]`). A plan check,
  a planner's amendment, a developer's fix round, a re-dispatch after
  `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a
  Stage 8 record fix are each dispatched to a new agent that works from the
  files on disk and what its dispatch names — never by resuming the agent
  that ran before or sending it a follow-up. The cost reason is the one the
  change measured (*Known limits and not verified*, F1). The one resume is
  Rule 5's report check, for missing fields only. A round's findings travel
  in the next agent's dispatch, copied as the agent returned them — the one
  input not on disk, because the manager writes no findings file and the
  analyzer and reviewer are read-only (`D8`). A fix-round developer adds
  `## Fix round — <stage> round <n>` to `result.md` instead of overwriting
  it (`agents/developer.md` *A fix round*, `D9`); the overwrite rule stays
  for a re-dispatch of the same steps. Rule 5 carries the user's model into
  each fix round too, since a new agent no longer inherits it from a resume
  (`D23`).
- **Re-checks look at the delta** (`glab:manager` Stages 1b and 3,
  `agents/analyzer.md` *Re-checks — round 2 and later*). *Stage 1b.* Before
  the amendment goes to a new planner the manager keeps the version the
  round checked: `cp plan/{slug}/plan.md plan/{slug}/plan.r<n>.md`, and
  `evidence.md` to `evidence.r<n>.md` when there is one — `findings.md` to
  `findings.r<n>.md` in a folder from before `glab` 0.10.0, the only form
  until `2912002` (`[flow-planner/plan.md D38]`). It tests that the
  amendment changed something by exit code alone, `cmp -s` (0 identical,
  1 changed, 2 a file missing), for `plan.md` and for `evidence.md` (or
  `findings.md` in an older folder) — an empty delta is a stop, not a pass — and
  never reads the diff itself; only the analyzer of round `<n+1>` —
  `glab:plan-analyzer` since `09d5664` — runs
  `diff -u`, and checks each previous finding, every changed line and every
  step that rests on one, not the rest of the plan. A copy, not git,
  because the plan folder is untracked while it is planned and a snapshot
  of a gitignored `plan/` would be empty. The copies stay in the folder and
  are committed with it. Since `0cbf5b0` the same holds for `master.md`
  before its approval and for `index.md` (`master.r<n>.md`,
  `index.r<n>.md`, per sub-plan folder for a sub-plan's files; a master
  check has no `plan.md` to copy); after the approval a changed request
  leaves only a version copy `master.v<n>.md` (*The master plan and
  sub-plans*). The `cmp -s` runs as
  `cmp -s plan/{slug}/<name>.r<n>.md plan/{slug}/<name>.md` for each file
  the round checked; exit 1 on any file means the amendment changed the
  plan, exit 0 on every file that it changed nothing. *Stage 3.* Before each analyze round, round 1
  included, the manager snapshots the tree into a tree object through a
  temporary index, seeded from `HEAD` first (`GIT_INDEX_FILE="$idx" git
  read-tree HEAD && … git add -A && … git write-tree`), because a tracked
  file that matches `.gitignore` is otherwise missing; round `<n+1>` gets
  both tree ids and the previous findings and reads `git diff <old> <new>`.
  Ignored files are not in a snapshot, so a path the fix round's `files:`
  line names that the delta does not show is checked whole; a lost tree id
  means the round runs whole; with no commit yet `git read-tree HEAD` fails
  and that round runs whole (`D10`, `D11`, `D12`, `D49`, `D50`).
- **A review round after the first** is a new reviewer given the target,
  the previous round's findings verbatim and the range of the fix — the old
  and new tree ids (taken with Stage 3's snapshot) or two commit ids — and
  never the plan, the slug or the intent. It checks each previous finding
  closed or still open, reviews the fix range in full, and the whole target
  stays in its scope; text a previous round passed is not re-litigated
  (`agents/reviewer.md`, `glab:manager` Stage 5, `commands/ship.md`;
  `D51`, a *One fact* entry). At full tier, Stage 3 after a review fix is
  one delta round per review fix, against the tree id the last `CONFORMS`
  measured, handed also the review findings the fix answered; it neither
  resets nor uses Stage 3's cap, a `DIVERGES` there goes back to Stage 2
  inside the same review round, and that fix goes on to Stage 5 without a
  second Stage 3 round, so the loop stays bounded (`D54`).
- **Severity.** Each finding of `glab:reviewer` and each gap of
  `glab:analyzer` — and of `glab:plan-analyzer` since `09d5664` — carries a `severity:` line, `critical`, `high`, `medium`
  or `low`, on `glab:audit`'s *Severity Levels*, given by the agent that
  reports it and never re-ranked by the manager; it is the value the
  round-3 condition reads (`D4`). Nothing parses it (`F13`): it is a
  prompt-level contract between agents, and the verdict lines
  `/glab:ship` matches whole did not change.
- **Explore once** (`glab:manager` Stage 1, `glab:plan-first` Step 1). Mapping
  — read-only agents that read an area before the plan is written — is the
  manager's call per task. Each mapping agent writes
  `plan/{slug}/map-<area>.md` (every path it read, `file:line`, proven kept
  apart from inferred) and returns a short report; the planner is told the
  files, starts from them and reads code only for the gaps it names;
  without mapping agents the planner explores itself; never both over one
  area. The name is not `findings-<area>.md` because the Write tool refused
  that name for a subagent (*Incidents*). The analyzer reads the map files
  with the plan, the developer the ones the plan cites. Since `glab` 0.10.0
  (`2912002`) the same refusal names the plan's own findings file
  `evidence.md` (*Plan files*, below; `[flow-planner/plan.md D1]`).
- **The planner's call-site audit** (`glab:plan-first` Step 1, Step 4;
  `glab:manager` checklist item 3). The full audit — callers, what each
  relies on, shared or caller-specific contract — covers methods the plan
  **changes**; for a method it only **calls**, the precondition the new call
  site must meet and how the plan meets it; a file it only depends on is
  listed by path and not read in full. This is consistent with
  `glab:security` Rule 7, which binds before changing a function's
  signature, return values, error cases or timing (`D14`).
- **The context rule** (`glab:manager` Rule 2, *Your own context — read it,
  act on it, never clear*). The manager reads the number in the most recent
  `glab: context <n>k` line the hook added and puts it at the end of every
  handoff line (`· context <n>k`), as "the last completed call's context"
  and no more exact; it never reads the transcript. Inside a task, at the
  first handoff line at or past the first step — **300k**, or `<t>k` when
  the line names `compact at <t>k` (since `glab` 0.10.0, `2912002`; a fixed
  300k until then) — and again at the first past each
  further **100k**, it brings the handoff file up to date and suggests
  `/compact`. **A smaller window** (since `2912002`): when the line names no
  `compact at <t>k` and the manager's model has a context window not larger
  than the first step plus 100k — a 200k window under the default — it tells
  the user once that the step is near or past the window and that
  `GLAB_COMPACT_AT`, in thousands, exported in the shell that starts Claude
  Code, moves it; the number is the user's, never the manager's
  (`[flow-planner/plan.md D17]`). At a task boundary — after the push of the Stage 8 record, or
  after Stage 7 when there is no plan folder — it suggests `/clear` and a
  new session whatever the number says (no hook can tell a task boundary).
  Only when no `glab: context` line has come at all in the session (the
  plugin not enabled or older than 0.9.0, hooks off, no `jq`, no readable
  transcript) it says so once and counts instead: `/compact` after every 15
  dispatches and after any stage that took more than one round, the line
  ending `· dispatches <d>`; when lines come with user messages but not with
  Agent results it uses the most recent of either kind. The manager never
  runs `/clear` or `/compact` and never claims more precision (*What you
  never do*). As of 0.15.0 the handoff file is the session's own,
  `plan/handoff/<session id>.md` (`glab:session-rules` Rule 2; *The project
  level as of 0.15.0*, above), which `glab:bootstrap` step 5 reads with the
  other sessions' files; no `glab` step commits it. 300k is where a resumed agent's rounds were already
  costing several times a fresh one's (*Known limits*, F1).
- **The context hook** (`plugins/glab/hooks/hooks.json`,
  `plugins/glab/scripts/context-size.sh`, tested by
  `tests/context-size.test.sh`; `[flow-cheaper-rounds/plan.md D29]`). One
  script, three modes, three new `glab` hook events — `UserPromptSubmit` →
  `context-size.sh prompt`, `PostToolUse` with matcher `Agent` →
  `context-size.sh agent`, `Stop` → `context-size.sh stop` — each with
  `timeout` 5, beside the unchanged `SessionStart` hook (`Hooks (4)`). It
  reads only `transcript_path` from the hook's stdin, never `tool_input`,
  `tool_response` or `prompt`. The measure is the last completed model call
  of the main conversation: of the last transcript entry that is an
  assistant entry, not a sidechain, whose usage sums
  `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` to
  more than 0, rounded up to thousands so a real value never prints `0k`;
  read from the last 8 MiB of the file (`tail -c 8388608` into one `jq`
  fold, one line at a time), so the cost does not grow with the file and an
  assistant entry longer than the window is not seen. `prompt` and `agent`
  emit on every event, with no threshold, `additionalContext`
  `glab: context <n>k (last completed call)` (about ten tokens), in the
  hook-specific output of their own event. `stop` speaks to the **user**:
  `{"systemMessage":"glab: context <n>k (last completed call) — a good point
  to /compact, or to /clear between tasks"}`, when the step of the latest
  written call (300k, 400k, 500k, …) is higher than the step at the real
  prompt before the last one. **`GLAB_COMPACT_AT`** (since `glab` 0.10.0,
  `2912002`; `[flow-planner/plan.md D12]` to `D16`): read from the
  environment after the transcript, in thousands. Unset or empty, the first
  step is 300k and the line is as above. A value matching
  `^[1-9][0-9]{0,5}$` makes the first step that many thousand, the steps
  after it stay 100k apart, and the line ends `; compact at <t>k)` in all
  three modes — `glab: context <n>k (last completed call; compact at <t>k)` —
  so the manager reads the step from the line. Any other value prints one
  stderr line, `glab context-size: GLAB_COMPACT_AT is not a whole number of
  thousands from 1 to 999999; using 300`, and the run goes on with the
  default, printing on stdout what it would print with the variable unset:
  a typo must not silence the number, and reading it after the transcript
  keeps each failure path at exactly one stderr line. The default is
  absolute, not a share of the window — the user's working limit, the same
  on every model — and there is no per-model table, because the hook is not
  told the window. Tested by T22 (the suffix in `agent` and `prompt`), T23
  (a moved step, the 100k steps after it and the suffix in `stop`) and T24
  (invalid values, an invalid value in `stop`, empty), with
  `unset GLAB_COMPACT_AT` before T1 so T1–T21 run on the default; `PASS
  24/24`, and `FAIL 3/24` against the `0.9.0` script. Why the user: a hook fires every time but
  cannot make the model act, so the one message that must not depend on the
  model goes to the person who can run `/compact` or `/clear`. `stop` is
  stateless (no file remembers a suggestion) and **never blocks or
  continues a turn**: `systemMessage` is its only key, no exit 2, no
  `decision`, nothing reads `stop_hook_active`. The contract of all three
  modes, like `memory-sync.sh`'s: exit 0 on every path; on stdout one JSON
  object (built by `jq -n --arg`) or nothing; every failure one line on
  stderr, `glab context-size: <reason>`; without `jq` it prints nothing and
  the manager's dispatch-count fallback covers it. It runs in every
  session of every repo where `glab` is enabled, manager or not, and writes
  no file, keeps no state and opens no network connection
  (`AGENTS.md` *Rules* hook contracts, *One fact*).
  *What I1 showed* (the user ran it in their terminal, Claude Code
  `2.1.304`, one host; `[flow-cheaper-rounds/plan.md F23]`): at
  `PostToolUse` on `Agent` the Agent-calling call is already in the
  transcript, so the `agent` line is current; `UserPromptSubmit` and
  `PostToolUse` lines reached the model; `Stop`'s `systemMessage` is shown
  to the user in the terminal and the turn ends there; but at `Stop` the
  turn's own last call is **not yet written** (the entry was there a second
  later). So `stop`'s base is the size at the real prompt before the last
  one, one turn further back than the turn's own prompt, and the line comes
  usually at the end of the turn after the crossing — once, or twice per
  crossing when the crossing call was already written at its own turn's
  `Stop`, never missed and never a third time (`D61`, `D62`). The manager's
  suggestion at a handoff line, read from the current `agent` line, may come
  before the user's line; the two use the same steps (`D47`). A first
  version compared the size with the turn's own prompt and never spoke
  (*Incidents*, IN1).
- **The agents** since `glab` 0.9.0, beside *Agents* above: `glab:reviewer`
  and `glab:analyzer` carry a `severity:` line in their report templates;
  `glab:analyzer` has a *Re-checks — round 2 and later* section (the
  previous findings and the delta, an empty delta reported as `BLOCK: target
  unresolved`) and reads `map-<area>.md` and treats a `<name>.r<n>.md` copy
  as an earlier version of a file the folder still holds, taking the record
  items from the current file; `glab:developer` has an *A fix round* section
  (read `result.md` and the tree first, add `## Fix round — <stage> round
  <n>`), reads the map files its plan cites and never edits a
  `map-<area>.md` or a round copy.
- **The agents since `glab` 0.10.0** (`2912002`): `glab:analyzer` and
  `glab:developer` read `plan/<slug>/evidence.md`, and `findings.md` in a
  folder from before 0.10.0 (`[flow-planner/plan.md D38]`); the analyzer's
  *Re-checks* pairs each `<name>.r<n>.md` the manager kept with its current
  file and, for a plan check, reports an amendment added beside what it
  changes — an amendment section, a "superseded" line, a round marker, an
  old step or decision left standing — as one finding on that id
  (`[flow-planner/plan.md D6]`); since `09d5664` that plan-check part is
  `glab:plan-analyzer`'s *Re-checks*, and `glab:analyzer`'s keeps the
  conformance parts (`[flow-models-per-role/plan.md S2]`, `S3`). `glab:developer` gains *Keep your context
  small*, unnumbered between Step 1 and Step 2, prose only
  (`[flow-planner/plan.md D10]`, `D11`): read the contract once and re-open
  only by `grep -n` and line range; gate and test output go to a log under
  the repo's or host's temp directory —
  `log=$(mktemp "${TMPDIR:?}/gate.XXXXXX"); { <the gate command>; } >"$log" 2>&1; rc=$?; tail -n 30 "$log"; echo "rc=$rc"`,
  the braces sending every command of a compound gate line to the log
  (added in review fix round 1, `[flow-planner/result.md R1]`) — and only its
  tail, its `rc` and its failure lines are read; no re-read after an edit
  (`git diff -- <file>` instead); Edit, not a whole-file Write; search
  before reading. Its reason: one developer in another project peaked past
  500k tokens in one round (`[flow-planner/evidence.md F4]`). It never
  edits `evidence.md` or `findings.md`.
- **`glab:plan-first` since `glab` 0.10.0** (`2912002`). *Size and shape*,
  after Step 3: `plan.md` and `evidence.md` at most **48 KB** each
  (`wc -c`) — since `0cbf5b0` `master.md`, `plan.md`, `index.md` and
  `evidence.md`, the manager's checklist item 6 checking the same four,
  which extends `[flow-planner/plan.md D2]` — because every later agent
  reads them again; a decision is one
  line, choice and reason in at most two sentences, evidence cited by id and
  never restated; a fact is written once; a plan that will not fit is split,
  and one that cannot be carries `- size: <n> KB — <why it is one plan>`
  under `## Decisions` for the manager to decide under Rule 3
  (`[flow-planner/plan.md D2]`–`D4`). The manager's acceptance checklist
  has a sixth item, *Within its size*: `wc -c` on each file against 49152
  bytes and `grep -c '^- size: '`, never reading them (Rule 2;
  `[flow-planner/plan.md D6]`). *Amending after a plan check* (Step 4) and
  Stage 1b: an amendment replaces the text it changes, in place, under the
  same id — no amendment section, "superseded" line or round marker; the
  `.r<n>` copies are the history; a line the manager added to overrule a
  decision stays as written (`[flow-planner/plan.md D5]`). Steps 5–7 and the
  three repo rules that bind only the implementation (service lifecycle,
  nested repositories, commits) moved byte for byte, numbers kept, to
  `plugins/glab/skills/plan-first/implement.md`, a sibling file with no
  frontmatter — not a skill, so `Skills (14)` holds; `SKILL.md` keeps Steps
  0–4, a pointer *Steps 5 to 7 — Implement, E2E tests, unit tests*, and "A
  planning agent stops at Step 4 and does not read it." The waiver
  paragraph says "Then implement, from `implement.md`" (review fix round 1,
  `[flow-planner/result.md R3]`), and since `0cbf5b0` goes on ": the
  waiver stands in for the verified, approved plan it asks for"; the
  pointer reads "Read it once the plan is verified and approved (Step 4),
  or once a waiver is written (*User Override*)", and `implement.md` l. 3
  "Start them only once the plan is verified and approved
  (`glab:plan-first` Step 4), or once `plan/{slug}/waived.md` records a
  waiver (*User Override* in `SKILL.md`), which stands in for both"
  (`[flow-master-plan/plan.md S9]`, `D47`). The manager's checklist has a
  seventh item since `0cbf5b0`, *A master*: `grep -c '^## \(Request\|Goals\|Out of scope\|Final check\|Record\)$' plan/{slug}/master.md`
  prints `5`, and with sub-plans `index.md` has one line per sub-plan
  folder. `/glab:develop`'s "glab:plan-first steps
  5 to 7" still resolves (`[flow-planner/plan.md D7]`, `D8`). Step 1
  writes `plan/{slug}/evidence.md`, "not `findings.md`: Claude Code refuses
  a subagent's Write of a file by that name". **History since `glab` 0.13.0**
  (`6f8b948`): the skill is `glab:plan` and `implement.md` is gone (Q1, the
  user's "A: plan only"; *`glab:plan` replaces `glab:plan-first`*, above):
  the pointer *Steps 5 to 7* and "A planning agent stops at Step 4 and does
  not read it" went with it, and the waiver paragraph (*User Override*) now
  reads "Then `/glab:develop` builds from it: the waiver stands in for the
  verified, approved plan"; the *One fact* entry is
  "`glab:plan`'s step numbers — 0 to 4", and `Skills (14)` became
  `Skills (13)`. The 48 KB budget, in-place amending, the checklist items 6
  and 7 and Step 1's `evidence.md` stand, in `glab:plan`.
- **The model rule** (`glab:manager` Rule 5, "each agent runs on its
  role's model; the user's words override it", since `glab` 0.12.0,
  `09d5664`; `[flow-models-per-role/plan.md D2]`, `D3`, `D9`–`D13`; the
  user's answer "Default", `[flow-models-per-role/questions.md Q1]`). Each
  agent's definition sets its model in its frontmatter `model`, an alias,
  never a full ID (`D3`): `glab:planner` `opus` (planning, sub-plan
  planning, amendments), `glab:plan-analyzer` `opus` (the plan check, the
  master check), `glab:analyzer` `sonnet` (the conformance check, the final
  check, the record check), `glab:developer` `sonnet` (develop, fix rounds,
  the record), `glab:reviewer` `sonnet` (review, the record's review),
  `glab:integrator` `sonnet`, `glab:committer` `haiku` — the table the user
  approved on 2026-10-20 ("good let's use your suggestions") for cost
  (`flow-models-per-role/master.md` *Request*: in one measured run
  developers were 49% of tokens, planners 21%, plan checks 11%, reviewers
  8%; "A cheaper model lowers the price per token, not the number of
  tokens"). The definitions ship with the plugin, so every installer runs
  on these models and pays their price; the reviewer has no `haiku`
  default, "it is the last gate" (review round 1,
  `[flow-models-per-role/result.md R2.7]`). **No instruction, no
  parameter**: the manager dispatches with no `model` and the definition's
  model runs; it never picks a cheaper or a dearer one, and no file
  switches it, `docs/constants.md` included; an agent with no definition —
  a mapping agent, a read-only question, any ad-hoc or fan-out agent not
  one of the seven — gets no parameter unless the user names a model for
  it, and Claude Code's own order picks (`D9`, `D19`). **The user's words
  override the role they name** — `sonnet`, `opus`, `haiku` or `fable`,
  for any role — passed as the Agent tool's `model` parameter on every
  dispatch of that role: each split slice, fix round, re-dispatch after
  `BLOCKED` or `PLAN WRONG`, analyze round and review round, through a
  `/glab:` command or directly; a name the parameter does not take is said
  and asked about; naming `fable` can spend money and is said once. The
  override is recorded as a `- model:` line quoting the user under
  `## Decisions` in `plan.md` (the example is now
  `- model: glab:reviewer opus, for this task — … "use opus for the reviewer"`,
  since the developer's default is already `sonnet`, R2.7); a `/glab:review`
  or `/glab:ship` with no plan, **and the Stage 8 record's agents**, keep it
  in the conversation only, and once it cannot be found the dispatch goes
  with no parameter and the handoff line names the definition's model
  (`D12`). Its duration is unchanged: "For this task" ends with that task's
  record (Stage 8), or with its push when it has no plan folder; "for the
  session" with the session. **The handoff line** names the model on every
  line of a stage that dispatches an agent —
  `slug · develop · model sonnet · round 1/2 · BUILT · effort <level> · context <n>k`
  — the definition's alias when the user named none, `model haiku (user)`
  when the override was passed (`D11`). **The documented order**
  (`[flow-models-per-role/plan.md E1]`, `E2`): the per-dispatch parameter,
  then the definition's frontmatter `model`, then
  `CLAUDE_CODE_SUBAGENT_MODEL`, then the main conversation's model, in that
  order from Claude Code v2.1.251; so `CLAUDE_CODE_SUBAGENT_MODEL` no longer
  reaches the seven agents, and only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`,
  from v2.1.257, overrides the definitions and the parameter alike — Rule 5
  and `README.md` say so, because an installer who set the variable to save
  money would otherwise lose that without a word (`D13`); a family alias
  runs the main conversation's exact model when it is of that family; the
  parameter holds on resume from v2.1.211; `model` is documented among the
  fields a plugin agent supports, and that a live dispatch honours it is
  not yet shown (I1, *Known limits*). **The dispatch-per-model table**
  applies to the model the agent runs on, its default included (`D10`,
  `[feature-model-switch/plan.md D20]`'s rule kept): rows `opus`, `fable`
  (nothing changes), "default — an agent with no definition, on Claude
  Code's own order" (nothing changes; R2.8), `sonnet` (the role's report
  template pasted in full), `haiku` (shorter, every instruction explicit,
  numbered reference steps, the template pasted); so a `glab:committer`
  dispatch is written for `haiku` and every Sonnet-default dispatch pastes
  the role's *Report* section. **Since `glab` 0.13.0** (`6f8b948`;
  `[flow-commands-to-skills/plan.md]` B23, M7.5) the table is one paragraph:
  `opus`, `fable`, `sonnet` and an agent with no definition get the dispatch
  Rule 0c and the stage say; `haiku` a shorter one, every instruction
  explicit, the work as numbered steps that are references — "for the
  committer, `1 commit the paths <list>; 2 report as your file says`"; and
  "The agent's own *Report* section is its template; it is not pasted into
  the dispatch". The paste for `sonnet` and `haiku` was reversed, not the
  model table. The report check is unchanged: every
  report is checked against the role's contract, the agent resumed once for
  missing fields (the one resume the manager allows since `glab` 0.9.0,
  *Every round is a new agent* above). **Without subagent dispatch** a
  stage session runs on the model the user starts it with, and the manager
  names the role's model or the recorded override when it hands off (review
  round 1, `[flow-models-per-role/result.md R1.4]`). Every role gets
  `effort` (Rule 0d: "The model is Rule 5's, the effort is this rule's.");
  no frontmatter has an `effort:` key, and a subagent on a model other than
  the main conversation's does not take the session's level unless `effort`
  is passed — one more reason it always is (`D14`,
  `[flow-models-per-role/plan.md E4]`). The pipeline does not bend: the
  manager still runs the gates, the reviewer still gets only the target,
  push still waits for the user, and a reviewer's `SHIP` on any model is a
  `SHIP`. History, until `glab` 0.12.0 (`09d5664`), as it stood
  (`[feature-model-switch/plan.md D2]`, `D8`, superseded): the user may name the model of the developer
  or the reviewer — `sonnet`, `opus`, `haiku` or `fable` — and nothing else
  changes it. The manager passes it as the Agent tool's per-dispatch `model`
  parameter on every dispatch of that role, records it as a `- model:` line
  quoting the user under `## Decisions` in `plan.md`, names it in every
  develop and review handoff line (`model default` when none), writes the
  dispatch for that model (a three-row table: `opus`/default/`fable`,
  `sonnet`, `haiku`; until `467b7c4` also a row for an external reviewer
  and one for an external developer), and checks every
  report against the role's contract, resuming the agent once for missing
  fields (the one resume the manager allows since `glab` 0.9.0, *Every
  round is a new agent* above). "For this task" ends with that task's record (Stage 8), or with its
  push when it has no plan folder; "for the session" with the session. Every other role gets no `model` parameter; every role, these two
  included, gets `effort` (Rule 0d: "The model is Rule 5's, the effort is
  this rule's."). The pipeline does
  not bend: the manager still runs the gates, the reviewer still gets only
  the target, push still waits for the user.
- **Rule 5's version history** (moved out of `glab:manager` in `glab`
  0.13.0, `6f8b948`; `[flow-commands-to-skills/plan.md]` A30, M7, R10).
  Rule 5's *Precedence* bullet (`glab:manager` Rule 5, the owner) names
  this spec for the versions and for what no live dispatch has shown yet;
  review round 1 (finding B1) put its resume sentence back, so *Check what
  comes back*'s "(see *Precedence*)" points at something. That is this file:
  the versions are *The documented order* under *The model rule*, above,
  and what is not shown is under *Known limits*
  (`[feature-model-switch/plan.md I4]`,
  `[flow-models-per-role/plan.md I1]`). The plugin does not ship
  `docs/specs/`, so an installer reaches it only in the repository (review
  round 1 B1, accepted under R10). The removed bullet read, verbatim
  (`steps-manager.md` M7): "**What the documentation promises, and from
  which version.** The parameter outranks the definition's `model`, which
  outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main
  conversation's model — in that order from Claude Code v2.1.251; before it
  the variable came first. So `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches
  the seven `glab` agents: their definitions set a model. Only
  `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, from v2.1.257, overrides the
  definitions and the parameter alike. A family alias runs the main
  conversation's exact model when that model is of the same family. The
  parameter still holds when the agent is resumed or sent a follow-up only
  from v2.1.211 — before that, a resumed agent falls back to its
  definition's model. That a plugin agent's frontmatter `model` and the
  parameter are honoured is documented — `model` is among the fields a
  plugin agent supports — and not yet shown by a live dispatch." The removed
  text of *Name it in the handoff line* read: "under `availableModels` it
  warns when it substitutes, in interactive sessions" and "`/tasks` shows
  the model a running subagent is on, from v2.1.242." In *The pipeline does
  not bend to the model*, "the reviewer still gets the target and nothing
  else" became "the reviewer still gets only what Stage 5 gives it" (M7.4).
- **The external developer** — history: removed in `glab` 0.8.0
  (`467b7c4`, 2026-10-20), with Rule 5's paragraph, its table row and
  `/glab:develop`'s external path; as it stood until then
  (`glab:manager` Rule 5, as of `33a28df`; the
  decisions are in `docs/specs/external-agents.md`). The user may name an
  external developer, Codex only — "develop on Codex", or "develop on Codex,
  <id>" — which `glab:external-agents` runs as a `--role developer` agent
  with the developer's contract, in the repository itself; "An external
  developer is Codex only: OpenCode cannot change files." It is recorded,
  lasts and is shown the way a Claude model is. Its record line is the Codex
  reviewer's with `glab:developer`:
  `- model: glab:developer codex, for <scope> — the user's instruction, not a manager choice: "<the user's words>"`,
  with `codex:<id>` when the user named a model; its handoff line
  `slug · develop · model codex:<model> · round 1/1 · BUILT · effort <sent>`
  (as of `abda43a`; from `33a28df` to `3965622` the line carried
  `effort <level> (CLAUDE_CODE_EFFORT_LEVEL | the user's answer: "<words>")`
  after `codex`, and the handoff line ended at `BUILT`). A name the
  `model` parameter does not take may have meant an external developer too:
  `codex` or `codex:<id>`. It is not a `model` parameter: on the
  developer's occasions `/glab:develop`'s dispatch runs through
  `glab:external-agents` with `--role developer` — one agent, never split,
  never beside a `glab:developer`; a re-dispatch after `BLOCKED` or
  `PLAN WRONG` is a new agent, the old one stopped. When the backend is
  unavailable, times out, fails, or reports a sandbox other than the one it
  asked for (12), or the developer is refused, the manager stops and tells
  the user and reverts, commits or re-runs nothing. Rule 5's dispatch table
  has its row: "nothing you write: the script frames it with the default
  profile's developer section, the developer's contract and its tail
  (`glab:external-agents`); your brief is the slug and the step ids, as for
  `opus`". Codex's effort is not in this model line: "The effort is not in
  the model line: Rule 0d's `- effort:` line records it, for Codex too"
  (Rule 5, as of `abda43a`; until then it went "in the model line for the
  reviewer or the developer (Rule 5)"). The pipeline does not bend:
  the manager reads the whole change and runs every gate itself before
  Stages 3–5, which do not change (`[feature-external-developer/plan.md U3]`).
- **The model rule for Codex** — history: removed in `glab` 0.8.0
  (`467b7c4`, 2026-10-20), with Rule 6 and Rule 5's external reviewer; as
  it stood until then (`glab:manager` Rules 5 and 6, as of
  `30f2c80`; the decisions are in `docs/specs/external-agents.md`). The user
  may name an external reviewer as Codex alone — "review on Codex" — which
  runs Codex's own default model, with **no `--model` unless the user named
  one**, or "review on Codex, <id>". A name the Agent tool's `model`
  parameter does not take may have meant an external reviewer:
  `opencode:opencode-go/<id>`, `codex`, or `codex:<id>`. The record line
  names `codex` alone for Codex's default:
  `- model: glab:reviewer codex, for the session — the user's instruction, not a manager choice: "<the user's words>"`,
  with `codex:<id>` in place of `codex` when the user named a model; since
  `abda43a` it carries no effort ("The effort is not in the model line:
  Rule 0d's `- effort:` line records it, for Codex too."). The
  handoff line names the model the script's header named, which for Codex is
  the model that ran (`codex:default` when none has run). **The effort** is
  the session's, as Rule 0d gives it — the level the user named for the
  session, otherwise `CLAUDE_CODE_EFFORT_LEVEL`, otherwise asked once per
  session — or the level the user named for that agent or role, recorded as
  Rule 0d's `- effort:` line (Rule 6, `glab:external-agents`; *The session
  effort*, below). From `30f2c80` to `3965622` it was
  `CLAUDE_CODE_EFFORT_LEVEL` when set, otherwise asked once per session and
  recorded in the model line for the reviewer or the developer (Rule 5), and
  as `- effort: codex <level> (the user's answer: "<words>"), for the session`
  for any other Codex agent (Rule 6), placed by
  `[feature-codex-agent/plan.md D30]`; `subagent-effort` replaced both
  record forms with Rule 0d's line, whose placement Rule 0d states
  (`[feature-codex-agent/record.md effort-line]`, closed). It sends the highest
  level the model supports that is not above it and says so in the announce
  line; when `check` printed `models: unavailable`, it sends the level
  unchanged and says no levels were known. When an external reviewer's
  backend is unavailable, refuses the model, times out or fails, or reports
  that it did not run read-only (12), the manager stops and tells the user.
  The Codex record token, the `--model` clause and the
  effort rule were each a *One fact* entry of their own in `AGENTS.md`
  until `467b7c4`
  (`docs/specs/marketplace.md`).
- **The session effort** (`glab:manager` Rule 0d, as of `abda43a`). Every
  dispatch, to every subagent — `glab:developer`, `glab:reviewer`,
  `glab:analyzer`, `glab:integrator`, `glab:committer`, and any other;
  `glab:planner` and `glab:plan-analyzer` named too since `09d5664` —
  passes the Agent tool's `effort` parameter: omitted, the agent runs at its
  own usual effort, which is not necessarily the session's, and nothing in
  its report says which. The level, in order: the one the user named for
  the session in the main session; else `CLAUDE_CODE_EFFORT_LEVEL` when it
  is set; else the manager asks once per session and reuses the answer —
  never guessed. It is recorded as
  `- effort: <level> (the user's words: "<words>" | CLAUDE_CODE_EFFORT_LEVEL), for the session`
  under `## Decisions` in the current task's `plan.md` (a session-wide level
  in the plan of every task it covers), or in the conversation when there
  is no plan; a level that can no longer be found is asked again, not
  reconstructed. The user may name another level for one agent, one role
  or one task, which overrides the default for that and nothing else,
  recorded the same way with its scope. The parameter takes `low`,
  `medium`, `high`, `xhigh` or `max`; for an Agent tool dispatch, a level it
  does not take — `ultra`, for one — is said and asked about; Rule 0d is
  otherwise unchanged for Claude subagents by `467b7c4`, and keeps "for an
  Agent tool dispatch" (`[remove-external-agents/plan.md D7]`). History,
  until `glab` 0.8.0 (`467b7c4`, 2026-10-20): "A Codex agent
  runs at the same level through Rule 6's mapping, and Codex takes `ultra`;
  an OpenCode agent takes none." If the Agent tool rejects `effort` or does
  not offer it, the manager tells the user, dispatches without it and writes
  `effort default` in the handoff line. The dispatch text carries it where
  it lists Agent tool parameters: Stage 2's "**the effort, always**",
  Stage 5's "at the effort Rule 0d gives", `/glab:develop`'s bullet for
  every `glab:developer` dispatch, `/glab:review`'s and `/glab:ship`'s
  reviewer sentence and `/glab:ship`'s committer dispatch; `glab:bootstrap`
  and the hook's item 3 say every dispatch passes it; `README.md` says every
  agent "runs at the session's effort level, which the manager passes on
  every dispatch". `/glab:plan`, `/glab:analyze`, `/glab:integrate` and
  `/glab:commit` do not mention it (`[subagent-effort/plan.md D4]`;
  `[subagent-effort/result.md finding-4]`, open); since `09d5664` they cite
  the rule instead — `/glab:plan` "dispatched as `glab:manager` Rules 0c,
  0d and 5 say", the other three "Rules 0d and 5"
  (`[flow-models-per-role/result.md R2.10]`) — and no agent definition
  has an `effort:` key (`[subagent-effort/plan.md D6]`,
  `[flow-models-per-role/plan.md D14]`). The session effort
  is a *One fact* entry of `AGENTS.md` (`docs/specs/marketplace.md`).
  **Since `glab` 0.13.0** (`6f8b948`) the commands are stage skills —
  `glab:analyze`, `glab:commit`, `glab:integrate`, `glab:review` and
  `glab:ship` cite "`glab:manager` Rules 0d and 5", `glab:develop` dispatches
  "as Stage 2 says" — Rule 0c lists the `effort`
  parameter among what every dispatch carries, the session-start text's
  point 3 is one pointer to Rule 0d, and the entry names Rules 0d and 5 and
  *The pipeline*, that pointer line and `README.md` only.
- **Plan files** (`glab:plan-first`; `glab:plan` since `glab` 0.13.0, whose
  *Plan files are working files* holds the rule; the report of the specs the
  record will update, the `/glab:plan` command's until then, is
  `glab:planner`'s, `agents/planner.md` *Report*): `plan/{slug}/` holds `evidence.md`
  (`findings.md` until `glab` 0.10.0, `2912002`: a subagent's Write of that
  name is refused, *Incidents*; every reader still accepts `findings.md` in
  an older folder, `[flow-planner/plan.md D38]`),
  `questions.md`, `plan.md`, the developer's `result.md` and
  `follow-ups.md`, `integration.md`, and `waived.md` when the user waives
  planning; since `glab` 0.9.0 also `map-<area>.md` from mapping agents and
  the round copies `<name>.r<n>.md` the manager keeps at Stage 1b (an
  earlier version of a file the folder still holds: a record takes its
  items from the current file); a waiver's folder is recorded like a plan's.
  Since `glab` 0.11.0 (`0cbf5b0`) also `master.md`, `master.sha256`, a
  version copy `master.v<n>.md` when the request changed after approval,
  and, when the work split, `index.md` and the sub-plan folders
  `<nn>-<name>/`, each a full plan folder (*The master plan and
  sub-plans*, below). The rule is
  "**Plan files are working files; the spec is what stays.**" Step 1 reads
  the spec of each area the change touches first — its decisions still
  bind, its known limits still hold, its open follow-ups may already
  describe the task. Step 3's `plan.md` includes `## Record` — since
  `0cbf5b0` `master.md` does, and `plan.md` only in a folder with no master
  (`[flow-master-plan/plan.md D39]`): the area spec
  or specs the change updates once it is pushed, any audit file under
  `plan/` it acts on, and what the entry will say; `/glab:plan` reports the
  spec it names. A follow-up stays in `follow-ups.md` until the record moves
  it into the area spec. Specs live in `docs/specs/`, one file per area,
  unless the repo's `AGENTS.md` names another place. A plan folder whose
  `plan.md` has no `## Record` was written before the repo followed the rule
  and is not recorded — since `0cbf5b0`, whose `master.md`, or `plan.md` in
  a folder with no master, has none. An audit file stays where `glab:audit` writes it;
  the plan that acts on it names it in `## Record`, and its open items reach
  the spec at that change's record (`glab:audit` *After Writing*, item 4).
- **Stage 8 — Record** (`glab:manager` *Stage 8 — Record*), after Stage 7
  has confirmed the push. `glab:developer` is dispatched for the record
  alone — the slug, the area specs the plan's `## Record` names (since
  `0cbf5b0` `master.md`'s, `plan.md`'s with no master; for a
  waiver, the ones the manager names), any audit file it names — and
  updates each spec from the folder's files, sub-plan folders included
  since `0cbf5b0`: how the area works now, the
  decisions that still bind, what is not verified, every follow-up still
  open, every binding decision and every incident with its source file and
  number. It changes nothing inside the folder, removes nothing and writes
  no `result.md`; its report is the reply, and Step 3's gates run as for any
  change (`agents/developer.md` *The record — `glab:manager` Stage 8*). `glab:analyzer` then runs the
  record check at every tier: its contract is the folder and the audit file,
  each item `carried` (with the spec's `file:line`) or `missing`, ending
  `CONFORMS` or `DIVERGES: <n> steps`; `DIVERGES` goes back to the developer
  once and to the analyzer again, then to the user (`agents/analyzer.md`
  *The record check — `glab:manager` Stage 8*). At full tier one `glab:reviewer` pass on the spec diff
  alone follows, its findings fixed once and checked by the analyzer. Then
  `/glab:commit` with the spec files and `/glab:push` on its own go-ahead:
  an ordinary docs change. A decision made at this stage goes in the
  dispatch and the spec, not in `plan.md`. **The record never removes
  `plan/{slug}/` or an audit file**; whether a recorded folder is then
  removed, and how, is the repo's own `AGENTS.md` decision, carried out
  outside the stage, and the manager's *What you never do* says so. The
  bootstrap's `record` bullet: "the plan folder stays unless the repo's
  `AGENTS.md` says otherwise"; its handoff step looks in the area specs for
  what a finished change left open. This repo's own rule — the manager
  session removes a landed folder — is in `docs/specs/marketplace.md`.
  **Superseded by `docs-lifecycle` (`glab` 0.16.0, 2026-11-18):** the
  folder is never committed, and the manager removes it under
  `glab:session-rules` Rule 2's plan-folder approval, not under a repo's
  own `AGENTS.md` rule (*The docs lifecycle as of 0.16.0*, above).
- **The master plan and sub-plans** (since `glab` 0.11.0, `0cbf5b0`;
  `glab:plan-first` Step 3 *The master plan, and sub-plans when the work
  splits*, `glab:manager` *The master plan and sub-plans*;
  `[flow-master-plan/plan.md D23]`–`D30`). Every plan folder starts with
  `master.md` — what the user asked for, constant once accepted; the plans
  say how. Its sections: `## Request` (the user's words, verbatim and
  dated, never paraphrased), `## Goals` (`G1`, `G2`, …, one line each,
  citing those words), `## Out of scope`, `## Final check`, `## Record`
  and `## Approval`, which only the manager writes. Normal tier writes
  `master.md` and one page, `plan.md`; full tier `master.md`,
  `evidence.md`, `plan.md` and `questions.md` if one was raised. **One plan
  by default**; the work is **split** only into parts with their own goals
  and milestone test, built, reviewed and committed one after another, and
  never across files the repo changes in one commit. Each part is a
  sub-plan folder `plan/{slug}/<nn>-<name>/` — `<nn>` two digits in build
  order, never reused — that is a plan folder under every rule; the split
  is `index.md`, one line per sub-plan (`<nn>-<name> · goals G1, G3 ·
  depends … | none · tier <normal | full>`) and a `## Decisions` section,
  amended like a plan (`index.r<n>.md`). **The master is constant:** after
  its `## Approval` line the manager runs
  `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256` from the
  repo root and never edits it again; every analyzer and `/glab:develop`
  check it with `sha256sum -c`, anything but `OK` an analyzer finding rated
  `high` (`D25`). No round amends an approved master: a changed request is
  a new `master.md`, the old kept as `master.v<n>.md` — a version copy,
  never `.r<n>` — whose approval and hash do not carry over; the manager
  removes `master.sha256` when it dispatches that planner, the new master
  gets its own Stage 1b, approval and hash, and every sub-plan not yet
  committed its Stage 1b again (review fix round 1,
  `[flow-master-plan/result.md R1]`). **Planning in cycles:** the first
  planning agent writes `master.md` and, when the work splits, `index.md`
  and no sub-plan; each sub-plan is planned by its own agent once what it
  depends on is committed, from `master.md`, its own `index.md` line and
  the slug-level `map-<area>.md` files its dispatch names, never from
  another sub-plan's folder (`D27`, `D28`). **Each sub-plan runs its own
  cycle** — Stages 1, 1b, 2, 3, 4, 5 and 6, Stage 3 at every tier — in
  `<nn>` order, development, review and commit one at a time, so each
  review sees only its own change; commands take `{slug}/<nn>-<name>` as
  the slug (`/glab:analyze {slug}/02-hooks`), the master a level up. **One
  commit per sub-plan** — its own folder, the first also `master.md`,
  `master.sha256`, `index.md` and the map files — then one final check,
  one push and one record per slug (`D30`); a single plan commits once.
  The developer reads `master.md` as context, not scope — a step that,
  built as written, cannot serve its goal is `PLAN WRONG` — and never edits
  `master.md`, `master.sha256`, `index.md` or a version copy.
- **The intent check** (since `0cbf5b0`; `glab:analyzer` *The intent
  question*, *The plan check*, *The final check*;
  `[flow-master-plan/plan.md D32]`–`D36`). The analyzer — never the
  reviewer, which stays blind to the plan, `master.md` and `index.md` —
  asks, on top of its check, whether the work serves what the user asked
  for, wherever there is a master: **in a plan check** (Stage 1b), of the
  master whether every request reaches a goal or `## Out of scope`, each
  goal says no more and no less than its words, and every goal reaches a
  line of `index.md` (the coverage question, the *master check* of a split
  folder before any sub-plan is planned); of a plan whether its steps
  deliver its goals as `## Request` words them — for a single plan one
  analyzer asks both of `master.md` and `plan.md` together (`D42`); **in a
  conformance check** (Stage 3), whether the build serves the goals beyond
  matching the steps; **in the final check**, for each goal, delivered and
  where. Each goal is reported as a step, `goal G<n>: <served | partial |
  missing | reshaped>`, quoting the request. A folder with no master — from
  before 0.11.0 — gets no intent question, and the analyzer says so. An
  intent gap after the build is a defect of the plan: a planning agent's
  amendment, then Stage 2, never a developer told to build past its plan
  (`D34`). The analyzer's own file now holds the plan check and its
  verdicts `BUILDABLE` and `NOT BUILDABLE`, beside `CONFORMS`,
  `DIVERGES: <n> steps` and `BLOCK: target unresolved` — the five one fact
  in `AGENTS.md` (`D35`); a master check or a final check has no `plan.md`,
  so its contract is `master.md` and `index.md`, and `BLOCK` only when
  there is no `master.md` either. For a sub-plan, an untracked file in
  another sub-plan's folder is not its implementation. Its description
  names the plan check, the conformance check and the final check
  (`[flow-master-plan/result.md R5]`). `/glab:analyze` asks "did we build
  the thing the plan said, and does it serve what the user asked for?" and
  routes `BUILDABLE` to the approval and `/glab:develop` (or, after a
  master check, the sub-plans' planning), `NOT BUILDABLE` to a new planning
  agent, and `CONFORMS` after the final check to `/glab:push`. Until
  `09d5664` one analyzer agent did every kind of check (`D36`). **Since
  `glab` 0.12.0** the analyzer is two kinds (`[flow-models-per-role/plan.md D6]`,
  `D7`): `glab:plan-analyzer` (`opus`) holds the plan check, the master
  check, the intent question's plan-check part and the verdicts
  `BUILDABLE` and `NOT BUILDABLE`; `glab:analyzer` (`sonnet`) keeps its
  name — so the Stage 3, 6b and 8 citations and `/glab:analyze`'s name
  stay — with the conformance, final and record checks, the conformance and
  final-check parts of the intent question and `CONFORMS` and
  `DIVERGES: <n> steps`; both end `BLOCK: target unresolved` on a check that
  is not theirs. Two files, not one with two modes, because a frontmatter
  default is per file and a per-dispatch model would put the default back
  in the manager's memory (`[flow-models-per-role/plan.md B2]`, rejected), and each file
  loads less: `analyzer.md` was 11269 bytes, its plan-check text read by
  every conformance, final and record dispatch (`[flow-models-per-role/plan.md E10]`).
  Stage 1b's citations moved to `glab:plan-analyzer` (Stage 1b cites
  `glab:plan-analyzer` *The intent question*); the intent check and the
  analyzers' verdict lines are one fact in both files (`AGENTS.md` *One
  fact*, `docs/specs/marketplace.md`). In `analyzer.md` "except in a
  coverage or final check", "except in a master check or a final check"
  and "in a master check or a final check" became "in a final check" (`S3`).
- **Stage 6b — Final check** (since `0cbf5b0`; `glab:manager`
  *Stage 6b — Final check*; `[flow-master-plan/plan.md D33]`). After the
  slug's last commit, before the push, at every tier: `/glab:analyze {slug}`
  as the final check. The analyzer reads `master.md`, `index.md` (the plan,
  with no index) and the range from the `## Approval` base to `HEAD`, does
  not walk the sub-plans' steps, and answers the intent question for every
  goal; the manager runs the gates on that tree. Skipped only for a single
  plan at full tier, whose Stage 3, delta rounds included, asked it.
  `CONFORMS` → Stage 7; `DIVERGES` → the gaps go to a new planning agent —
  a new sub-plan with the next `<nn>`, or an amendment of `plan.md` without
  sub-plans — which runs its cycle to its commit; round 2 gets round 1's
  findings and the two commit ids; at most 2 rounds, a third under the
  round-3 rule, then the user. Nothing is pushed before it, and Stage 7
  shows the `## Decisions` lines of each plan the push carries.
- **Approval after Stage 1b** (since `0cbf5b0`; `glab:manager` Stage 1;
  `[flow-master-plan/plan.md D26]`, `D46`). The user approves a checked
  plan: after Stage 1b has passed — the master check, when the work split —
  explicitly at full tier and whenever the work split; at normal tier with
  no sub-plans the manager reports the tier and the decisions and goes on.
  The manager then writes `master.md`'s last section, one line —
  `- approved by the user, <date>, in chat | in plan mode: "<their words>"; base <git rev-parse --short HEAD>`,
  or `- accepted at normal tier, reported to the user, <date>; base <sha>`
  — and hashes it; the base is where the final check's range starts. At
  full tier the user also approves `plan.md` explicitly — a single plan's
  together with the master, each full-tier sub-plan's after its own Stage
  1b — and that `plan.md` ends with its own `## Approval` line in the same
  form; at normal tier the master's approval covers the sub-plans (`D46`,
  extended to a single full-tier plan by review fix round 1,
  `[flow-master-plan/result.md R2]`). `/glab:develop`'s *Approval*
  precondition: with a `master.md`, its `## Approval` line, `sha256sum -c`
  printing `OK`, and at full tier the `plan.md`'s own line — or stop; with
  none, a plan from before 0.11.0, full tier only, as before. `/glab:plan`
  reports the goals, and the sub-plans when the work split.
- **Approval in Claude Code's plan mode** (since `0cbf5b0`; `glab:manager`
  *Approval in Claude Code's plan mode — only when the user asks for it*;
  `[flow-master-plan/plan.md D37]`, the user's: the flow should "work with
  claude app|cli builtin flow"). Only when the user asked for it, in the
  session or a standing instruction; otherwise the approval is asked in the
  chat. Only the main session can (no subagent has the plan-mode tools,
  UNVERIFIED: L7), after Stage 1b with no agent running (L5); the manager
  first tells the user in one line that the dialog sets the session's
  permission mode from then on (L4) and that changes go through "No, keep
  planning", not Ctrl+G (L3); it calls EnterPlanMode, then ExitPlanMode
  with `master.md` as the plan (L1, L2). It writes no plan file outside the
  repo — `~/.claude/plans` by default — and asks the user to leave plan
  mode and approve in the chat instead; inside the repo, where the user's
  own `plansDirectory` put it, it writes `master.md`'s text there byte for
  byte and never commits it; it never changes `plansDirectory`. Approved →
  the `## Approval` line says `in plan mode`; "No, keep planning" → the
  user leaves plan mode before the amendment, and their words go into
  `## Request`. Every plan-mode claim is read from Claude Code's
  documentation and marked UNVERIFIED in the payload and `README.md`, each
  naming the live test L1–L7 that settles it (*Known limits*, below); a
  step whose claim fails falls back to approval in the chat.

## Decisions that still bind

- [feature-model-switch/plan.md D1] Manual only: the model changes only when the user names it, for one dispatch, a task or the session; never on the manager's own initiative, never because of quota, never from a file. **Amended by `[flow-models-per-role/plan.md D2]` and `D9` since `glab` 0.12.0 (`09d5664`):** each role now has a default, its definition's frontmatter `model`; this decision still governs every change from that default.
- [feature-model-switch/plan.md D2] **Superseded by `[flow-models-per-role/plan.md D9]` since `glab` 0.12.0 (`09d5664`).** It was: developer and reviewer only; analyzer, integrator, committer and planning agents get no `model` parameter. The user's words now override any role, and an agent with no definition gets no parameter unless the user names one.
- [feature-model-switch/plan.md D3] The user does not run commands: the user tells the manager, who carries the choice into every dispatch of the role until the user changes or clears it.
- [feature-model-switch/plan.md D4] The handoff line names the model, so the user sees what was asked for.
- [feature-model-switch/plan.md D5] The pipeline does not bend to the model: gates, the reviewer's target-only brief, the push go-ahead, the tier and the round caps stay.
- [feature-model-switch/plan.md D6] The mechanism is the Agent tool's per-invocation `model` parameter, passed on each dispatch; it tops the documented order and holds across a resume.
- [feature-model-switch/plan.md D7] One home for the rule, `glab:manager` Rule 5; the stages and commands point to it, the commands restating only the minimum. **Amended since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md]` FU1-4):** the commands are stage skills, which cite Rules 0d and 5 and restate none of Rule 5; the one home stands.
- [feature-model-switch/plan.md D8] **Superseded by `[flow-models-per-role/plan.md D2]` since `glab` 0.12.0 (`09d5664`).** It was: no change to the agent files: no `model` in their frontmatter, so the documented default applies without an instruction. Each of the seven definitions now sets its role's `model`.
- [feature-model-switch/plan.md D9] The choice is recorded as a `- model:` line under `## Decisions` in the task's `plan.md`; a review or ship with no plan keeps it in conversation only, and a lost one falls back to the default.
- [feature-model-switch/plan.md D10] An unspecified duration means the task in progress (the session when there is no task): a lost choice falls back to the default, never to a cheaper model.
- [feature-model-switch/plan.md D11] Develop and review handoff lines always name the model, `model default` included. **Amended by `[flow-models-per-role/plan.md D11]` since `glab` 0.12.0 (`09d5664`):** every line of a stage that dispatches an agent names it, the definition's alias when none was passed and `model <alias> (user)` for the user's override; `model default` is gone.
- [feature-model-switch/plan.md D12] Rule 5 names its limits: the line states what was passed; a forced subagent model, an allowlist or a mod can run something else, and `/tasks` shows what runs. **Amended since `glab` 0.13.0 (`6f8b948`; M7.3):** the `/tasks` sentence and its version left Rule 5 with the version history (*Rule 5's version history*, above); the rest of the limit stays in *Name it in the handoff line*.
- [feature-model-switch/plan.md D13] Without subagent dispatch the stage session runs on the model the user starts it with, and the manager names the recorded model in the handoff.
- [feature-model-switch/plan.md D14] `AGENTS.md` *One fact* carries the manual model rule as a known case. **Amended since `glab` 0.12.0 (`09d5664`; `[flow-models-per-role/plan.md S8]`):** the entry is "the model per role" (`docs/specs/marketplace.md`).
- [feature-model-switch/plan.md D17] Rule 5 states the version floors and that a plugin agent honouring the parameter is inferred, not shown. **Superseded since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md]` A30, M7, R10):** Rule 5 states no version floor; its *Precedence* bullet names this spec, which holds the floors and what is inferred (*Rule 5's version history*, above).
- [feature-model-switch/plan.md D18] Naming `fable` is the user's money choice: said once, then used; not a Rule 3 question.
- [feature-model-switch/plan.md D20] The dispatch fits the model: Rule 5's table says what changes in the message per model; the agent files do not change. **Extended by `[flow-models-per-role/plan.md D10]` since `glab` 0.12.0 (`09d5664`):** the table applies to the model the agent runs on, its definition's default included. **Amended again since `glab` 0.13.0 (`6f8b948`; B23):** the table is one paragraph, and no model's dispatch pastes the report template.
- [feature-model-switch/plan.md D21] The report template is the agent's own *Report* section, copied as written; reading it is Rule 2's one exception. **Superseded since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md]` B23):** the agent's own *Report* is its template and is not pasted into the dispatch, so reading it is no longer an exception to Rule 2; Rule 5's report check stays the backstop.
- [feature-model-switch/plan.md D22] A malformed report is not evidence: check the required fields and the verdict line's form, correct once on the same model, then stop and tell the user; not a review round. (The review fix round made the correction a resume of the same agent.)
- [feature-model-switch/plan.md spent] D15, D16, D19 — scoping of that change: the `0.3.0` bump, leaving bootstrap and the hook untouched, and its Stage 1b amendment.
- [feature-model-switch/result.md decisions] The single normal-tier review said to cut Rule 5's per-model table and report check; the manager fixed the findings once instead, because the user had asked for per-model dispatch (Stage 5's normal-tier rule) — that is why the table and the check are in Rule 5.
- [sync-local-edits/result-followups.md D1] Sessions settle a seam through the channel `docs/constants.md` names, and the user relays when it names none; a relayed decision binds only when it arrived that way and is recorded as a `## Decisions` line naming the session.
- [sync-local-edits/result-followups.md D2] A `plan.md` with no tier line is full tier, stated once in *Pick the tier*.
- [sync-local-edits/result-followups.md D3] Rule 3 keeps `glab:security`'s stop list and its *Destructive operations are proven* rule, and states confirmation before every destructive action and every push as the manager's own rule (as corrected after review, #3).
- [sync-local-edits/result-followups.md D4] Bootstrap stays on the review-round-cap list, and the four ask-conditions are a known *One fact* case naming every file that states them.
- [sync-local-edits/result-followups.md D5] `/glab:integrate` runs after `/glab:analyze` at full tier and after `/glab:develop` at normal; normal tier runs the milestone test, full tier the whole suite. **Amended by `[flow-master-plan/plan.md D31]` since `glab` 0.11.0 (`0cbf5b0`), for sub-plans only:** a sub-plan runs Stage 3 at every tier, so `/glab:integrate` follows `/glab:analyze` there; a normal-tier plan with no sub-plans keeps this decision (`commands/develop.md`: "`/glab:analyze` at full tier and for every sub-plan, `/glab:integrate` at normal with no sub-plans"). **Amended since `glab` 0.13.0 (`6f8b948`; FU1-4):** `commands/develop.md` is gone; which stage follows Stage 2 is the manager stage's, and `glab:develop` hands off "as Stage 2 says".
- [sync-local-edits/result-followups.md D6] After an amendment, the develop handoff re-runs the plan's next stage.
- [sync-local-edits/result-followups.md D8] `/glab:analyze` says "If the plan is amended". **Lapsed since `glab` 0.13.0 (`6f8b948`; FU1-4):** `glab:analyze` holds no routing after an amendment; what follows a check is the stage's (`skills/analyze/SKILL.md`: "go on as the stage that ran the check says").
- [sync-local-edits/result-followups.md D9] The planner decides each choice and records it with its reason; the manager reviews those lines and may overrule one, recording the overrule as a new line.
- [sync-local-edits/result-followups.md D10] Only its `glab:plan-first` half stands, reworded by `feature-docs-specs`: no `glab` step removes a plan folder, and whether a recorded one is removed is the repo's own `AGENTS.md` decision (it said: a repo that keeps specs but has no rule for removing plan folders keeps its plans). Its manager half — the Spec row's stage, owner and place — was removed by the review's scope cut; Stage 8 now gives the record a stage, owner and place (`[sync-local-edits/follow-ups.md 10]`, closed). **Superseded in its removal half by `[docs-lifecycle/plan.md D5]` (`glab` 0.16.0, 2026-11-18):** no `glab` step of the record removes a plan folder still, but whether a recorded one is removed is no longer the repo's `AGENTS.md` decision — the manager removes it at a session start under `glab:session-rules` Rule 2's plan-folder approval.
- [sync-local-edits/result-followups.md D11] **Superseded by `[flow-cheaper-rounds/plan.md D2]` since `glab` 0.9.0 (`2a1e919`).** It was: the 1b row's "Leaves on" reads "`BUILDABLE`, or one amendment at normal tier". It now reads "`BUILDABLE`, or at normal tier the amendment after round 2" (`glab:manager` *The pipeline*).
- [sync-local-edits/result-followups.md D12] Bootstrap points to *Pick the tier* for the full-tier triggers and names the four as Rule 3's ask-conditions; `review.md` says Stage 5 sends findings back; the hook text says "at full tier". **Amended since `glab` 0.13.0 (`6f8b948`):** `glab:review` says "Inside the `glab:manager` pipeline, Stage 5 says where the findings go"; the session-start text no longer lists the stages and says no "at full tier" (H1, R2-5).
- [sync-local-edits/result-followups.md spent] D7 — the waiver routing it decided was removed by the review's scope cut (`[sync-local-edits/follow-ups.md 7]`, reopened).
- [sync-local-edits/result.md spent] M1, M2, M3, P1 — the port's merge choices (the reviewer's round-cap wording, the develop `questions.md` bullet, `ship.md` already matching, where bootstrap's new paragraph goes), applied in `5f69d65`; nothing in them governs later work.
- [sync-local-edits/result.md decisions] The coordinator, as manager, resolved the contradictions the port reported in favour of the user's newer text (tiers, Rule 3), because the 2026-10-08 edits were the user's latest statement of intent; the older "questions" wording and the repo's own `plan/` rule stayed. The manager's decision, not the user's approval.
- [bug-reviewer-findings/questions.md Q3] **Superseded by `[flow-cheaper-rounds/plan.md D2]` since `glab` 0.9.0 (`2a1e919`).** It was: the review round cap is 3 everywhere, `/glab:ship` stating the same number so the standalone path is capped too (later "at most three — one at normal tier"). What survives is that `/glab:ship` states the same cap as the manager, so the standalone path is capped too — now 2, and a third only on a `critical` or `high` finding.
- [bug-reviewer-findings/questions.md Q7] With no `AGENTS.md`, every agent and command falls back to `CLAUDE.md` and says so; the reviewer reviews correctness only and puts `agreement: no AGENTS.md — correctness only` on its own line above an unchanged verdict line, because `/glab:ship` matches the verdict line whole. **Amended since `glab` 0.13.0 (`6f8b948`):** with the commands gone, the fallback is in every agent and the session-start text (`AGENTS.md` *One fact*).
- [bug-reviewer-findings/questions.md Q10] `manager-bootstrap.sh`'s text matches the bootstrap rules (load `glab:bootstrap`; agents carry `glab:security` and `glab:comments`); the two stay one fact. **Amended since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md R2-5]`, review round 1 A5 and B2):** the *One fact* entry "the session-start rules" is gone; each rule has one owner — the hook text for the read order, the fallback and the temp-file rule — and `glab:bootstrap` points at it; "agents carry `glab:security` and `glab:comments`" became "each `glab` agent loads its own rules".
- [feature-docs-specs/plan.md U1] Specs live in `docs/specs/`, one per area, living: how the area works now, why (the decisions that still bind), known limits and what is not verified, and its open follow-ups (the user's).
- [feature-docs-specs/plan.md U2] `plan/<slug>/` is committed during the work and removed after the change has landed, with the spec naming the commit that holds it; `plan/SESSION-HANDOFF.md` stays untracked (the user's) — the removal is this repo's rule, done by the manager session, not by `glab` (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md U4] The rule goes into the payload wherever it describes the plan lifecycle; the default for installers is `docs/specs/`, and a repo's own `AGENTS.md` may name another place (the user's) — its "removal after the push" default was cut by `[feature-docs-specs/plan.md U10]`.
- [feature-docs-specs/plan.md U9] The default for installers is the user's decision (U4), not the planner's.
- [feature-docs-specs/plan.md U10] Scope cut (the user's, 2026-10-18): in the payload, Stage 8 "Record" is the spec only — the developer writes the spec from `plan/<slug>/`, `glab:analyzer` checks at every tier that nothing was dropped, and it is committed as a docs change; `glab` never removes `plan/<slug>/` or an audit file, and whether a folder is removed is the repo's own `AGENTS.md` decision; this repo's `AGENTS.md` keeps a short rule under which the manager session removes a landed folder (`docs/specs/marketplace.md`). **Superseded in its removal half by `[docs-lifecycle/plan.md D3]` and `D5` (`glab` 0.16.0, 2026-11-18):** the record is still the specs (and now feature pages) only and never removes; the folder is never committed, and the manager removes it under `glab:session-rules` Rule 2's plan-folder approval.
- [feature-docs-specs/plan.md U11] Retrieval is read-only everywhere: one file `git show <sha>:plan/<slug>/<file>`, the list `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole folder `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`; no `git restore` into the repo (the user's).
- [feature-docs-specs/plan.md D1] Four areas — `marketplace.md`, `workflow.md`, `memory-sync.md`, `external-agents.md` — following the plugin boundary; `AGENTS.md`'s `plan/` rule names them.
- [feature-docs-specs/plan.md D2] Fixed headings and greppable tags: every follow-up, question and open list keeps its source as `[<slug>/<file> <id>]`, so "none lost" is a search, not a judgment.
- [feature-docs-specs/plan.md D3] A spec names the last commit that holds the folder, not the removal commit, because a commit cannot carry its own hash; in this repo that is the last commit on `origin/main` that holds it (`AGENTS.md`, the `plan/` rule).
- [feature-docs-specs/plan.md D4] Stage 8 — Record, after Stage 7: `glab:developer` writes the spec from the folder and changes nothing inside it, so it writes no `result.md`; at full tier one `glab:reviewer` pass on the spec diff alone is what "checked by independent readers" now means; the commit goes out on its own go-ahead — its removal by `glab:committer` was cut (`[feature-docs-specs/plan.md U10]`, D34).
- [feature-docs-specs/plan.md D5] Installer wording: specs in `docs/specs/` unless the repo's `AGENTS.md` names another place, and a folder from before the rule (a `plan.md` with no `## Record`) is not recorded; its removal clauses moved to the repo's own `AGENTS.md` (`[feature-docs-specs/plan.md U10]`), where no untracked file under `plan/` is removed. **Amended by `[flow-master-plan/plan.md D39]` since `glab` 0.11.0 (`0cbf5b0`):** `## Record` is in `master.md`, so a pre-rule folder is one whose `master.md` — or `plan.md`, in a folder with no master — has no `## Record`.
- [feature-docs-specs/plan.md D8] Payload text cites the spec, named with its repository, never a `plan/` path or a commit of this repo: an installer can follow neither.
- [feature-docs-specs/plan.md D10] A spec is not one of the *One fact* files: it states a fact as of its last record and names the file that owns it; `AGENTS.md`'s `plan/` rule says so.
- [feature-docs-specs/plan.md D11] Closed items migrate too, under *Closed follow-ups* with their evidence (`AGENTS.md`: every follow-up, open or closed).
- [feature-docs-specs/plan.md D16] An audit file is a working file too: its still-open items go into the area spec when the change that acts on it is recorded — its removal by that record commit was cut (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md D22] A model choice "for this task" ends with the task's record, not its push; a task with no plan folder ends with its push. Only `manager/SKILL.md` Rule 5 states the duration.
- [feature-docs-specs/plan.md D26] An audit file stays where `glab:audit` puts it, directly under `plan/`; the plan's `## Record` names it and Stage 8 hands it to the developer and the analyzer as a source — its removal by the committer was cut (`[feature-docs-specs/plan.md U10]`).
- [feature-docs-specs/plan.md D27] The record check is `glab:analyzer`, at every tier, with the folder's tracked files as its contract (the payload reads every file: `[feature-docs-specs/follow-ups.md 2]`); one fix round, then the analyzer again; still `DIVERGES` → the user. The full-tier reviewer pass stays, on the spec diff alone.
- [feature-docs-specs/plan.md D28] A pre-rule folder is one whose `plan.md` has no `## Record`; a waiver's folder has no `plan.md` and is recorded. **Amended by `[flow-master-plan/plan.md D39]` since `glab` 0.11.0 (`0cbf5b0`):** the `## Record` looked for is `master.md`'s, `plan.md`'s only in a folder with no master.
- [feature-docs-specs/plan.md D32] Tags are matched as items: only a line that starts with `- [tag]` counts, a tag inside another item is a cross-reference, and no tag sits under both *Open* and *Closed follow-ups*.
- [feature-docs-specs/plan.md D33] Stage 6 does not commit `plan/{slug}/`: nothing in the payload needs plan files in git, since the record reads the folder from disk; whether plan files are committed is the repo's convention (this repo's `AGENTS.md`: they are).
- [feature-docs-specs/plan.md D34] `committer.md`, `commit.md`, `push.md` and `ship.md` carry no record text: the record commit is an ordinary docs commit. **Amended since `glab` 0.13.0 (`6f8b948`):** they are `agents/committer.md` and `skills/{commit,push,ship}/SKILL.md`; `glab:commit` and `glab:review` name themselves the entry point of the record's commit and review (Stage 8) and still carry no record procedure.
- [feature-docs-specs/plan.md D35] The record check ends in the analyzer's existing verdicts: `CONFORMS`, or `DIVERGES: <n> steps`, each missing item one step.
- [feature-docs-specs/plan.md D36] The record is an ordinary docs change, through the normal commit and push stages; a decision made at Stage 8 goes in the dispatch and the spec, not in `plan.md`.
- The decisions behind Rule 5's external developer, Rule 6's exceptions and `/glab:develop`'s external path — `[feature-external-developer/plan.md U1]` to `U4`, `D1`, `D6`, `D7`, `D8`, `R4.7` and the user's approvals of revisions 3 and 4 and of the round 3 scope cut — are carried in `docs/specs/external-agents.md`, the change's primary area, and bind here too. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): they no longer bind, since what they governed was removed; kept in that spec as a record.
- The decisions behind Rules 5 and 6 for Codex — `[feature-codex-agent/plan.md U4]`, `U5`, `D6`, `D17`, `D30` and the user's Q5 and Q6 — are carried in `docs/specs/external-agents.md`, the change's primary area, and bind here too. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): they no longer bind, since Rule 6 and Rule 5's Codex reviewer were removed; kept in that spec as a record.
- [subagent-effort/questions.md Q1] A — "One shared effort (Recommended)": one session effort, one record line and one source order for Claude subagents and Codex; Codex still maps the level down to the highest its model supports. It supersedes the record-line half and the source order of `[feature-codex-agent/questions.md Q6]` (carried in `docs/specs/external-agents.md`): when the user has named a session level in chat, Codex follows it instead of `CLAUDE_CODE_EFFORT_LEVEL` (the user's, 2026-10-19). History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): its Codex half lapsed with Codex; the one session effort still binds for Claude subagents.
- [subagent-effort/plan.md D1] Rule 0d sits in `glab:manager` between Rule 0c and Rule 1, as the user's approved text with `glab:`-prefixed role names.
- [subagent-effort/plan.md D2] The handoff line is `slug · stage · round n/max · verdict · effort <level>`, `model <m>` still after the stage on develop and review lines; it names the level passed — for Codex the level sent; an OpenCode line names none, because OpenCode takes no effort. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): the Codex and OpenCode clauses lapsed; the line names the level passed (`[remove-external-agents/plan.md D6]`).
- [subagent-effort/plan.md D3] Rule 0d's bullet "The model is Rule 5's, the effort is this rule's": an agent dispatched with no `model` still gets `effort`, and a level the parameter does not take (`ultra`) is asked about, as Rule 5 does for a model name.
- [subagent-effort/plan.md D4] Commands change only where they list Agent tool parameters — `develop.md`, `review.md`, `ship.md`; `plan.md`, `analyze.md`, `integrate.md` and `commit.md` stay, as they stay for Rule 0c. **Superseded since `glab` 0.13.0 (`6f8b948`; FU1-3, FU1-4):** the commands are gone; the stage skills cite Rules 0d and 5, and Rule 0c lists the `effort` parameter among what every dispatch carries.
- [subagent-effort/plan.md D5] `glab:bootstrap`, `manager-bootstrap.sh` and `README.md` each gain one clause, because each states the dispatch contract as complete. **Amended since `glab` 0.13.0 (`6f8b948`; FU1-3, BS2, H1):** `glab:bootstrap` holds no dispatch clause; the session-start text's point 3 is one pointer to Rules 0c and 0d; `README.md` keeps its clause.
- [subagent-effort/plan.md D6] No agent definition changes: the parent passes the level per dispatch; an `effort:` key would fix one level per role in the plugin instead of the session's, and the user asked for the parent to pass it.
- [subagent-effort/plan.md D7] The UNVERIFIED that a plugin agent honours `effort` goes into this record's *not verified*, not into the payload — the user's approved wording has no such sentence (`[subagent-effort/plan.md unverified]`, below).
- [subagent-effort/plan.md D8] Rule 0d's level and record line are Codex's too, mapped down to the highest level the model supports — Q1 = A, the user's answer, not a planner choice. History since `glab` 0.8.0 (`467b7c4`, 2026-10-20): lapsed with Codex.
- [subagent-effort/plan.md stage-1b] Stage 1b ended at round 2/2 `NOT BUILDABLE` on two missing checks; the user chose "Add checks, then build" (2026-10-19), with no third round.
- [subagent-effort/plan.md approval] Approved by the user, 2026-10-19: "go a head". Its session line, `- effort: high (the user's words: "let's for now set the effort for your subagent you current session high level"), for the session`, was that change's own and is spent.
- [feature-docs-specs/plan.md spent] U3, U5, U6, U7, U8, D7, D9, D12, D13, D14, D15, D17, D18, D19, D20, D21, D23, D24, D25, D29, D30, D31 — scoping and sequencing of that change: the migration of the seven folders, the live-run wording (applied in `AGENTS.md`; `docs/specs/external-agents.md`), the 0.5.0 bump and the `plugin.json` description, the commit split, the check script and its modes, the record's result file; U7 and D25 were superseded by U10 and U11 (the payload names no commit and checks no landing). D6 and `[feature-docs-specs/questions.md Q1]` bind in `docs/specs/external-agents.md`.
- [remove-external-agents/plan.md D4] The target of every edited passage was its text before `7139e62`, plus the later changes that are not about external agents (`fed95f9`'s Stage 8, the `BLOCK: 1 issue` of `5321d76`, `abda43a`'s session effort); the removal is not a `git revert`, which would have taken Stage 8 and the session effort with it.
- [remove-external-agents/plan.md D5] Rule 5's *Record it before the next dispatch* lost "The effort is not in the model line: Rule 0d's `- effort:` line records it, for Codex too." in full: it was added only because Codex model lines had carried an effort, and no Claude model line ever did.
- [remove-external-agents/plan.md D6] *The pipeline* keeps "The effort is the level you passed.", which still holds for every Claude dispatch, and lost only its Codex and OpenCode clause.
- [remove-external-agents/plan.md D7] Rule 0d keeps "for an Agent tool dispatch" before "a level it does not take": a smaller edit, and still true.
- [remove-external-agents/plan.md D9] `BLOCK: 1 issue` stays in `/glab:ship`, and the reviewer's verdict-lines entry of `AGENTS.md` *One fact* still lists `plugins/glab/commands/ship.md`: `5321d76` added it for the script's validator, but `glab:reviewer` emits it (`agents/reviewer.md:86` at `6b2a024`).
- [remove-external-agents/plan.md D11] No new text for a user who names an external reviewer or developer after 0.8.0: Rule 5's "A name the parameter does not take: say so, and ask which of the four the user means" covers it (inferred, `[remove-external-agents/plan.md inferred]`).
- [remove-external-agents/plan.md D14] Removing Rule 6 renumbered nothing: it was the last numbered rule of `glab:manager`.
- [remove-external-agents/plan.md approval] Approved by the user, 2026-10-20: "go ahead". Its session line, `- effort: high (the user's words: "let's for now set the effort for your subagent you current session high level"), for the session`, was that change's own and is spent.
- [remove-external-agents/plan.md spent] D1 (tier full), D13 (one `glab:developer`), D15 (`edits.py` as the exact edit list), D16 (nothing into `docs/specs/` in the change itself) — scoping of that change; `D2`, `D8`, `D10` and `D12` are in `docs/specs/marketplace.md`, `D3` in `docs/specs/external-agents.md`.
- [flow-cheaper-rounds/plan.md D1] Tier normal for the change — payload text, the `glab` manifest version, `AGENTS.md`, `README.md`, and one read-only hook script with its test; no full-tier trigger. The `severity:` line is a contract between agents that nothing parses (`F13`). Scoping of that change; it governs no later work. Re-checked by D36.
- [flow-cheaper-rounds/plan.md D2] The round caps — **the user's decision**, relayed by the manager: "set 2 and only one more if something critical is behind". Stage 1b, Stage 3 and Stage 5 each run at most 2 rounds at every tier where the stage runs; a third only when round 2 returned a `critical` or `high` finding, recorded first as a `- round 3: <stage> — <severity> <finding>` line under `## Decisions`; nothing past round 3. It supersedes `[bug-reviewer-findings/questions.md Q3]`, `[feature-plugin-marketplace/questions.md S3]` (`docs/specs/marketplace.md`) and `[sync-local-edits/result-followups.md D11]`. **Extended by `[flow-master-plan/plan.md D29]` since `glab` 0.11.0 (`0cbf5b0`):** the final check (Stage 6b) has the same cap, every cap counts per sub-plan where there are sub-plans, and the master and final checks write their round-3 line in `index.md` (`plan.md` with no sub-plans).
- [flow-cheaper-rounds/plan.md D3] "Critical **or high**", not "critical" alone — **the manager's choice, not the user's**: the real case that needed a third round was rated high. The user may overrule it; then only the word list in D2's files changes.
- [flow-cheaper-rounds/plan.md D4] The severity is given by the agent that reports the finding (`glab:reviewer`, `glab:analyzer`), as a `severity:` line on `glab:audit`'s four *Severity Levels*, and never re-ranked by the manager.
- [flow-cheaper-rounds/plan.md D5] Reviewer round 2 is the last round unless it reports a `critical` or `high` finding; then it answers `BLOCK: <n> issues` and round 3 may run, which is the last with no exception. The verdict strings did not change.
- [flow-cheaper-rounds/plan.md D6] What happens when a stage ends its last round without passing is unchanged for that stage and tier (1b full → the user; 1b normal → one more amendment, `PLAN WRONG` the backstop; after round 3 → the user; Stage 3 → the user with three resolutions; Stage 5 → the last-round answer to the user); only the round counts changed.
- [flow-cheaper-rounds/plan.md D7] Every round is a new agent — a plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a Stage 8 record fix; Rule 5's report check (missing fields only) is the one resume (`[feature-model-switch/plan.md D22]` binds). It sits in Rule 2 because its reason is cost.
- [flow-cheaper-rounds/plan.md D8] A round's findings travel in the next agent's dispatch, copied as the agent returned them — the one input not on disk; the manager writes no findings file (Rule 1) and the analyzer and reviewer are read-only.
- [flow-cheaper-rounds/plan.md D9] A fix-round developer adds `## Fix round — <stage> round <n>` to `result.md` and does not overwrite it; the overwrite rule stays for a re-dispatch of the same steps.
- [flow-cheaper-rounds/plan.md D10] The Stage 1b delta is a copy `plan.r<n>.md` (and `findings.r<n>.md`) made before the amendment is dispatched, not git: the plan folder is untracked while it is planned. The copies stay and are committed with the folder. Amended by D49: the manager tests the delta with `cmp -s`, only the analyzer runs `diff -u`. **Amended by `[flow-planner/plan.md D38]` since `glab` 0.10.0 (`2912002`), by the file name only:** the copy is `evidence.r<n>.md` of `evidence.md`, and `findings.r<n>.md` only in a folder from before 0.10.0. **Extended since `glab` 0.11.0 (`0cbf5b0`; `[flow-master-plan/evidence.md F11]`, `[flow-master-plan/result.md R1]`):** also `master.r<n>.md` before the master's approval and `index.r<n>.md`, per sub-plan folder for a sub-plan's files; after approval only a version copy `master.v<n>.md`.
- [flow-cheaper-rounds/plan.md D11] The Stage 3 delta is a tree object snapshotted before each analyze round through a temporary index; round `<n+1>` gets both tree ids. Amended by D50: the index is seeded with `git read-tree HEAD` first. A path the fix round names that the delta does not show is checked whole; a lost tree id means that round runs whole.
- [flow-cheaper-rounds/plan.md D12] An empty delta is a stop, not a pass, because `diff` and `git diff --quiet` exit 0 when nothing changed; an analyzer handed an empty delta reports `BLOCK: target unresolved`. For the plan the manager's check is `cmp -s` (D49).
- [flow-cheaper-rounds/plan.md D13] **Superseded by `D51` in Stage 1b round 1.** It was: review rounds are not changed, on the assumption that the same reviewer asks what changed; D51 gave a later round a new reviewer and the range of the fix.
- [flow-cheaper-rounds/plan.md D14] The planner's full call-site audit covers methods the plan **changes**; for a method it only **calls**, the precondition the new call site must meet and how the plan meets it; a file it only depends on is listed by path and not read in full. Consistent with `glab:security` Rule 7.
- [flow-cheaper-rounds/plan.md D15] Mapping files are `plan/{slug}/map-<area>.md`, not `findings-<area>.md`, because the Write tool refused `findings-probe.md` and `findings.md` for a subagent and accepted `map-probe.md` (`F9`; *Incidents*).
- [flow-cheaper-rounds/plan.md D16] Mapping is the manager's call per task; with mapping agents the planner starts from their files and reads code only for the gaps it names, without them it explores itself, never both over one area; the analyzer reads the map files with the plan and the developer the ones the plan cites.
- [flow-cheaper-rounds/plan.md D17] **Superseded by `D29` in round 2.** It was: the manager measures its context with one inline command in `glab:manager`, not a script. Round 1's command was never shipped; the manager now runs no command for its context and reads the hook's line.
- [flow-cheaper-rounds/plan.md D18] **Superseded by `D30` in round 2.** It was: the inline command finds the transcript by `CLAUDE_CODE_SESSION_ID` under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/*/`. The hook is handed `transcript_path`. What it kept: one number and nothing else from the transcript, never `0`, `0k` or `null`.
- [flow-cheaper-rounds/plan.md D19] The thresholds: inside a task suggest `/compact` at 300k and at each further 100k; at a task boundary suggest `/clear` whatever the size. 300k is where a resumed agent's round already cost several times a fresh one's (`F1`). Its steps became fixed ones by D47.
- [flow-cheaper-rounds/plan.md D20] The fallback when there is no measurement: say so once, then suggest `/compact` after every 15 dispatches since the session started or was last compacted and after any stage that took more than one round. 15 is inferred from the stage list (about 8–12 dispatches per normal-tier task), not measured. Its trigger was changed by D38.
- [flow-cheaper-rounds/plan.md D21] The handoff line gains `· context <n>k` at its end, copied from the most recent `glab: context <n>k` line, or `· dispatches <d>` under the fallback; the manager names it "the last completed call's context" and never claims more precision, and never runs `/clear` or `/compact`.
- [flow-cheaper-rounds/plan.md D22] The handoff file is the one `glab:bootstrap` step 5 reads, `plan/SESSION-HANDOFF.md` unless the repo keeps it elsewhere; no `glab` step commits it. `glab:bootstrap` and `manager-bootstrap.sh` did not change for the context items: the `SessionStart` text carries no handoff, compaction or context text, and the new hook is a separate script.
- [flow-cheaper-rounds/plan.md D23] Rule 5 carries the user's model into each fix round too, because a new agent no longer inherits it from a resume (Rule 5's carry bullet, `commands/develop.md`).
- [flow-cheaper-rounds/plan.md D24] The handoff line's `max` is the stage's cap, `2` or `3` once the round-3 line is written; a develop line counts its fix rounds against the cap of the stage whose findings it fixes; Rule 5's example reads `round 1/2`.
- [flow-cheaper-rounds/plan.md D25] `AGENTS.md` *One fact*: the review-round-cap entry became "the round caps" (all three stages, five files); new entries for the severity levels, every round a new agent, the mapping and round-copy file names, the handoff file, and the context hook (`docs/specs/marketplace.md`). It closed `[sync-local-edits/follow-ups.md 18]`.
- [flow-cheaper-rounds/plan.md D26] `glab` `0.8.0` → `0.9.0`: the change alters the pipeline's contract and adds a feature, and features have raised the minor before 1.0; nothing removed, so no `!`. `memory-sync` untouched, `0.1.0`.
- [flow-cheaper-rounds/plan.md D27] One commit for all seven items with the plan folder, because the *One fact* rule wants each fact's files together and the hook events are one fact across `hooks/hooks.json`, `README.md` and `AGENTS.md`; the manager may split it. Done as one commit, `2a1e919`. A slug with sub-plans commits once per sub-plan since `glab` 0.11.0 (`[flow-master-plan/plan.md D30]`); this decision bound its own change only.
- [flow-cheaper-rounds/plan.md D28] Out of scope, recorded as follow-ups: a dedicated `glab:planner` agent (FU1), splitting the implementation steps out of `glab:plan-first` (FU2), the user-level copies under `~/.claude` (FU3), the "cleanup glob deleted a reviewer report" incident (FU4), and the hooks the user did not choose (FU16). FU1, the `glab:planner` agent, was built by `flow-models-per-role` (`09d5664`, closed below).
- [flow-cheaper-rounds/plan.md D29] The context hook — **the user's decision**, as amended during round 2: "We need a clear rule stating that the agent must check token usage, and we need a definitive hook that triggers whenever an agent finishes its turn or after I send a message. We have to choose an approach that is impossible to bypass." (Its first form, `PostToolUse` on `Agent` alone, was superseded.) Three hook events — `UserPromptSubmit`, `PostToolUse` with matcher `Agent`, `Stop` — all running one script, `plugins/glab/scripts/context-size.sh`, chosen by a mode argument. Not `PostToolBatch`; not `SubagentStop`, whose `additionalContext` goes to the subagent, not the parent. Supersedes D17.
- [flow-cheaper-rounds/plan.md D30] The script takes `transcript_path` from the hook input on stdin and nothing from the environment. Supersedes D18; `[flow-cheaper-rounds/plan.md FU9]`'s question became moot.
- [flow-cheaper-rounds/plan.md D31] The measure is the manager's: the last transcript entry that is an assistant entry, not a sidechain, whose usage sums to more than 0, rounded up to thousands. The figure is the last *completed* call's, and every line says so. After I1: current at `PostToolUse` on `Agent`, lagging at `Stop` (D61–D62).
- [flow-cheaper-rounds/plan.md D32] Bounded read: the last 8 MiB of the transcript through `tail -c`, folded by one `jq` program one line at a time, a partial first line and a truncated last line dropped silently. Why 8 MiB: transcripts reach 28 MB with lines of several MB. Known limit: an assistant entry longer than the window is not seen (FU14).
- [flow-cheaper-rounds/plan.md D33] Modes `prompt` and `agent` emit on every event with no threshold, about ten tokens; a threshold there would need state and would hide the number the handoff line needs. The text says "context", not "manager context", because the hook runs in every session.
- [flow-cheaper-rounds/plan.md D34] The contract of all three modes, like `memory-sync.sh`'s: exit 0 on every path; on stdout exactly one JSON object or nothing; every failure one line on stderr, `glab context-size: <reason>`; JSON built by `jq -n --arg`; an unknown or missing mode is a failure like any other; without `jq` it prints nothing. Hook `timeout` 5 s on each of the three entries.
- [flow-cheaper-rounds/plan.md D35] The hook runs in every session of every repo where `glab` is enabled, and that is harmless: one line of about ten tokens per user message and per Agent call, a user line from `stop` only at a crossing, read-only and bounded, no file, no state, no network, only an integer and fixed words. Amended after I1 by D61: `stop` speaks usually at the end of the turn after the crossing, once, at most twice per crossing, and at every turn end past 300k when the window holds fewer than two real prompts.
- [flow-cheaper-rounds/plan.md D36] The tier is still normal: the script reads a file that can hold secrets but passes on nothing except an integer it computed (test T2 asserts no fixture byte reaches stdout or stderr in any case); the hook JSON is Claude Code's format, consumed, not defined here. Only the user lowers a tier.
- [flow-cheaper-rounds/plan.md D37] A background Agent call fires `PostToolUse` at launch (`tool_response.status` `async_launched`); the script does not read `tool_response` and emits the same line, the launch-time figure.
- [flow-cheaper-rounds/plan.md D38] The fallback trigger (amends D20): **no `glab: context` line anywhere in the session**. When `prompt` lines come but `agent` lines do not — a CLI older than 2.1.63 whose tool is `Task`, which the matcher `Agent` is not shown to match — the handoff line takes the number from the most recent line of either kind; the dispatch count is not used.
- [flow-cheaper-rounds/plan.md D39] Test `tests/context-size.test.sh <path to context-size.sh>` on the pattern of `tests/memory-sync.test.sh`: one work directory from `mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX"` removed by an `EXIT` trap, fixture transcripts written by the test, no background process, one `ok`/`FAIL` line per case; a missing `jq` is faked by a `PATH` that lacks it, not by a stub.
- [flow-cheaper-rounds/plan.md D40] `AGENTS.md` changes: both new files join the shell gates; the hook-contract rule names `context-size.sh` with its modes and its stdout rule; *One fact* gains the context-hook entry (the line text, the `Stop` message, the steps 300k and every 100k, the three modes and events); the `glab` green line becomes `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`.
- [flow-cheaper-rounds/plan.md D41] Integration I1 needs the user's OK, because it calls a model and a throwaway `CLAUDE_CONFIG_DIR` is not logged in; the user runs the command in their own terminal, with `--plugin-dir ./plugins/glab`, never `--no-session-persistence`. Amended by D64: "so no `memory-sync` hook runs" is not borne out in the user's own config.
- [flow-cheaper-rounds/plan.md D42] Version `0.9.0` kept (D26).
- [flow-cheaper-rounds/plan.md D43] Matcher `Agent` alone, not `Agent|Task`: the user named `Agent`, and how the CLI reads `|` for an older tool name is not shown (FU11).
- [flow-cheaper-rounds/plan.md D44] The script reads no field of `tool_input`, `tool_response` or `prompt`; they pass through the hook's stdin and are never printed, logged or stored.
- [flow-cheaper-rounds/plan.md D45] `stop` speaks to the **user**, not the model, with `systemMessage`; stateless; a step is `-1` below 300k, else `floor((x - 300000) / 100000)`; it speaks when the step of the latest written call is above the step at an earlier prompt. Amended after I1 by D61–D62: that earlier prompt is the real prompt before the last one. A real prompt is a user entry that is not a sidechain, not `isMeta` and not a `tool_result`. I1 proved that `Stop` shows `systemMessage` to the user in the terminal and the turn ends there. Whether the model also sees the `Stop` text stays UNVERIFIED. **Amended by `[flow-planner/plan.md D12]` since `glab` 0.10.0 (`2912002`), by the variable only:** the step is counted from the first step — 300k, or `GLAB_COMPACT_AT` thousand when set — not from a fixed 300k.
- [flow-cheaper-rounds/plan.md D46] `stop` never blocks and never continues the conversation: no exit 2, no `decision`, no `reason`, no `continue`, no `hookSpecificOutput`, no `additionalContext`; `systemMessage` is its only key; nothing reads `stop_hook_active`. Test cases assert the key set on every `stop` output.
- [flow-cheaper-rounds/plan.md D47] D19's thresholds became fixed steps — 300k and every 100k after it — for the manager's prose as for the `stop` mode: one rule stated once. The task-boundary `/clear` stays the manager's, because no hook can tell a task boundary. After I1 (D61): the manager reads the current `agent` line, so its suggestion may come before the user's line; the two never disagree on the steps. **Amended by `[flow-planner/plan.md D12]` since `glab` 0.10.0 (`2912002`), by the variable only:** the first step is 300k by default or `GLAB_COMPACT_AT` thousand when set, every 100k after it; the manager reads it from the line's `; compact at <t>k`.
- [flow-cheaper-rounds/plan.md D48] "Impossible to bypass" — what holds: the hooks run in the harness whatever the model does, in every session where `glab` is enabled. What does not: they do not run when the plugin is disabled, under `--bare`, or under `disableAllHooks: true`; managed policy can restrict hook sources (effect on a plugin's hooks UNVERIFIED, FU15); an interrupted turn fires no `Stop`. Each is a setting or an act of the user or organisation, not something the model can do; the dispatch-count fallback covers a session where no line comes. Whether a live model follows the prose rule stays UNVERIFIED.
- [flow-cheaper-rounds/plan.md D49] Manager decision, Stage 1b round 1: the manager tests the plan delta with `cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and `findings.md`), reading the exit code only — 0 identical, 1 changed, 2 a file missing — and never reads the diff itself; only the analyzer of round `<n+1>` runs `diff -u`. Amends D10 and D12. **Amended by `[flow-planner/plan.md D38]` since `glab` 0.10.0 (`2912002`), by the file name only:** the second `cmp` is of `evidence.md`, or `findings.md` in a folder from before 0.10.0. **Extended since `glab` 0.11.0 (`0cbf5b0`; `[flow-master-plan/plan.md S2]`):** one `cmp -s plan/{slug}/<name>.r<n>.md plan/{slug}/<name>.md` per file the round checked — `master.md` and `index.md` too where it checked them; exit 1 on any file is a change, exit 0 on every file none.
- [flow-cheaper-rounds/plan.md D50] Manager decision, Stage 1b round 1: the Stage 3 snapshot seeds its temporary index from `HEAD` first, because a tracked file that matches `.gitignore` is skipped by `git add -A` into an empty index. Limits kept in FU8: with no commit yet `git read-tree HEAD` fails and that round runs whole; a file force-added to the index but not committed that matches `.gitignore` is still missed. Amends D11.
- [flow-cheaper-rounds/plan.md D51] Manager decision, Stage 1b round 1: a review round `<n>` ≥ 2 goes to a new reviewer with the target, the previous round's findings verbatim and the range of the fix, and never the plan, the slug or the intent. A *One fact* entry binds `reviewer.md`, the manager and `ship.md`. Supersedes D13 and closed FU7.
- [flow-cheaper-rounds/plan.md D52] Manager decision, Stage 1b round 1: a round-2 `BLOCK` with no `critical` or `high` finding is that last round's verdict — there is no round 3; the stage ends as D6 says, to the user. Rule 5's report check stays for malformed reports only.
- [flow-cheaper-rounds/plan.md D53] Manager decision, Stage 1b round 1: with no plan behind the stage (`/glab:review` or `/glab:ship` on its own) the round-3 reason goes in the handoff line that announces round 3 (`round 3/3 (<severity> <finding>)`) and in the conversation; once it can no longer be found, there is no round 3.
- [flow-cheaper-rounds/plan.md D54] Manager decision, Stage 1b round 1, **confirmed by the manager at the plan's `## Decisions`** (the planner's reading, open to the user's overrule): at full tier, Stage 3 after a review fix is one delta round per review fix, against the tree id the last `CONFORMS` measured; it neither resets nor uses Stage 3's cap; a `DIVERGES` there goes back to develop and then on to Stage 5 with no second Stage 3 round, so the loop stays bounded; the analyzer is also given the review findings the fix answered.
- [flow-cheaper-rounds/plan.md D55] `glab:analyzer` states the round-3 trigger ("In round 2 it decides whether a round 3 runs"), so `agents/analyzer.md` joins the round-caps *One fact* entry. **Superseded since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md]` A13, R1):** the analyzers only rate and their round-3 sentence went; the round-caps entry names `glab:manager` *Pick the tier* and the reviewer's round-2 rule only.
- [flow-cheaper-rounds/plan.md D56] The plan's post-conditions match content, not line numbers or line wrapping (joined text, counts per file), so a half-written step prints `0` for its phrase. Scoping of that change's searches; `AGENTS.md` *Tests* and the Markdown gate (`[bug-reviewer-findings/follow-ups.md 20]`) are unchanged.
- [flow-cheaper-rounds/plan.md D57] `AGENTS.md` *Gates* reads "run all four, in order", with the fourth command (`bash tests/context-size.test.sh …`) added; the green line is five `rc=0` lines and, for each test, every line `ok` and a last line `PASS n/n`.
- [flow-cheaper-rounds/plan.md D58] `.claude-plugin/marketplace.json`, the `glab` entry's `description`, became "The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook"; only the description changed; outside `plugins/`, so no version of its own (`docs/specs/marketplace.md`).
- [flow-cheaper-rounds/plan.md D59] The input-parse `jq` of the script sends its stderr to `/dev/null`, so a malformed input prints exactly one line, `glab context-size: hook input is not JSON`.
- [flow-cheaper-rounds/plan.md D60] **Superseded by `D63` after I1.** It was: nineteen test cases, the last line `PASS 19/19`, T2 printed last. It is now twenty-one cases, `PASS 21/21`. What survives: each `T<n>` is one case and prints one line; a case with several inputs is `ok` only when every input passes.
- [flow-cheaper-rounds/plan.md D61] Manager decision, I1: `stop` stays stateless and accepts a one-turn delay. At `Stop` it compares the step of the latest *written* assistant total with the step of the total that precedes the **previous** real user prompt. It speaks once, on the turn after the crossing; when the crossing call is already written at its own turn's `Stop` (a transcript written in time, or a crossing at a call that is not the turn's last) it speaks then and once more — at most two lines per crossing, never a missed one. Rejected: polling in the hook until the turn's reply is written (up to about 1 s on every turn end); a per-session state file under `${CLAUDE_PLUGIN_DATA}`; dropping `stop` (I1b showed the display works). The user may overrule it. Amends D45.
- [flow-cheaper-rounds/plan.md D62] The `stop` base as built: the `reduce` state is `{last: 0, base: 0, cur: null}`; a real prompt does `.base = .last | .last = (.cur // 0)`. A window with fewer than two real prompts has `base` 0 and speaks at or past 300k. Each `Stop` covers the calls written since the prompt before the last, so consecutive `Stop`s overlap and leave no gap as long as the transcript catches up within one turn. Rejected by the planner: a base of "the assistant total before the last one that precedes the latest prompt", which speaks exactly once in every lagging case but misses a crossing if the lag is ever more than one entry; D45 prefers a line too many to a missed one. Known limit: a `/compact` inside the two turns can leave `base` above `cur`, so a crossing after the drop in that range shows only at the next `Stop` whose base is past the drop — a rise of over 250k within two turns, accepted.
- [flow-cheaper-rounds/plan.md D63] Tests after I1 (supersedes D60's count): T18's fixtures rewritten for D62 (each the transcript as it stands when `Stop` runs), T20 (a lagging session speaks once, on the turn after) and T21 (a crossing already written speaks then and once more, never a third time) added; the order is T1, T3–T18, T20, T21, T19, T2; `PASS 21/21`. Against the script as built before the fix, T18, T20 and T21 fail (`FAIL 3/21`): I1b's failure reproduced without a model.
- [flow-cheaper-rounds/plan.md D64] D41 said no `memory-sync` hook runs under `--plugin-dir ./plugins/glab`; I1a's run had a second `Stop` hook that ended `cancelled`, exit 1, so the plugins the user installed appear to load beside `--plugin-dir` in their own config; which plugin's hook it was is UNVERIFIED (inferred: the installed `memory-sync`'s network sync cut off when `-p` exited; FU18). `--plugin-dir` alone loads `glab` only under an empty config. An I1 run in the user's terminal runs the user's installed hooks, as any of their sessions does; switching them off is a `claude plugin` change, the user's alone. Amends D41.
- [flow-cheaper-rounds/plan.md D65] The two built texts that say when the user sees the `Stop` line were changed with D61 to stay true: `glab:manager` Rule 2 ("…tells the user directly, at the end of that turn or, usually, the next.") and `README.md` ("usually the turn after the crossing"). The steps did not change (D47), so the rest of those texts stands.
- [flow-cheaper-rounds/plan.md model] `- model: glab:developer sonnet, glab:reviewer sonnet, for this task` — **the user's instruction**, not a manager choice: "okay", in reply to the manager's recommendation. "For this task" ended with this task's record (Rule 5, `[feature-docs-specs/plan.md D22]`); **it does not bind later tasks.**
- [flow-cheaper-rounds/plan.md effort] `- effort: high`, the user's words for the session (as in `[subagent-effort/plan.md approval]`) — that session's own line, spent.
- [flow-planner/plan.md D1] The plan's findings file is `evidence.md`: a subagent's Write of `findings.md` is refused and `evidence.md` was accepted (`[flow-planner/evidence.md F8]`, `IN1`).
- [flow-planner/plan.md D2] `plan.md` and `evidence.md` are at most 48 KB each (`wc -c`), because every later agent reads them again; `flow-cheaper-rounds`' plan grew from 59 KB to 155 KB over three amendments (`[flow-planner/evidence.md F1]`). **Extended by `[flow-master-plan/plan.md S1]` since `glab` 0.11.0 (`0cbf5b0`):** the 48 KB budget covers `master.md`, `plan.md`, `index.md` and `evidence.md`.
- [flow-planner/plan.md D3] A decision is one line, choice and reason in at most two sentences, evidence cited by id and never restated; a fact is written once.
- [flow-planner/plan.md D4] A plan that cannot be split carries `- size: <n> KB — <why it is one plan>` under `## Decisions`, and the manager decides under Rule 3.
- [flow-planner/plan.md D5] Amendments replace the text they change, in place, under the same id; the `.r<n>` copies are the history (`[flow-cheaper-rounds/plan.md D10]`), and the manager's overrule line stays (`[sync-local-edits/result-followups.md D9]`).
- [flow-planner/plan.md D6] The manager checks the size by `wc -c` alone (Rule 2 forbids reading the plan); the analyzer checks in-place amending on its re-check, as the one reader of the diff.
- [flow-planner/plan.md D7] Steps 5–7 of `glab:plan-first` and the three implementation-only repo rules moved byte for byte, numbers kept, to `plan-first/implement.md`, so no caller breaks (`[flow-planner/evidence.md F2]`). It closed `[flow-cheaper-rounds/plan.md FU2]`. **Superseded since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/questions.md Q1]`, A15):** `implement.md` is removed and its one rule `glab:developer` lacked is in `developer.md` Step 3.
- [flow-planner/plan.md D8] Rejected homes for Steps 5–7: `glab:developer` (a session implementing without subagents loses them, and "steps 5 to 7" points at nothing) and a new `glab:implement` skill (`Skills (14)` → 15 in four files) (`[flow-planner/evidence.md B1]`, `B2`). **Superseded since `glab` 0.13.0 (`6f8b948`; Q1, the user's "A: plan only"):** implementation is `glab:developer`'s, through `/glab:develop`; no session follows Steps 5–7 from a skill, so the case against `glab:developer` as their home no longer applies.
- [flow-planner/plan.md D9] No `glab:planner` agent in that change — **the user's decision**, carried: the agent count changes once, in `flow-models-per-role` (`[flow-planner/evidence.md F3]`; `[flow-planner/plan.md FU1]`). Carried again by `[flow-master-plan/plan.md D36]`: the analyzer's two kinds wait for the same plan. Done there, in `glab` 0.12.0 (`09d5664`): the agent count went from five to seven at once (`[flow-models-per-role/plan.md D4]`, `D6`).
- [flow-planner/plan.md D10] The developer's context rules are prose in `glab:developer` — **the user's decision**, carried; no hook is shown to shorten a tool's output (`[flow-planner/evidence.md F4]`).
- [flow-planner/plan.md D11] No `scripts/gate.sh`: one inline line does it.
- [flow-planner/plan.md D12] The first context step is `GLAB_COMPACT_AT` thousand when set, default 300k, then every 100k — **the user's decision**, carried. It amends `[flow-cheaper-rounds/plan.md D45]` and `D47` by the variable only (`[flow-planner/evidence.md F5]`).
- [flow-planner/plan.md D13] No per-model table and no fraction of the window: the hook is not told the window.
- [flow-planner/plan.md D14] A set, valid value ends the line `; compact at <t>k)` in all three modes, so the manager reads the step from the line.
- [flow-planner/plan.md D15] An invalid value (not `^[1-9][0-9]{0,5}$`) warns once on stderr and uses the default; it is read after the transcript, so each failure path keeps one stderr line.
- [flow-planner/plan.md D16] Empty is unset: no warning.
- [flow-planner/plan.md D17] On a window not larger than the first step plus 100k the manager tells the user once and names the variable; the number is the user's.
- [flow-planner/plan.md D18] `glab` `0.9.0` → `0.10.0`, nothing removed, so no `!`; `memory-sync` untouched, `0.1.0`.
- [flow-planner/plan.md D20] One commit with the plan folder, because *One fact* wants each fact's files together and the plan has no sub-plans. Done as one commit, `2912002`. Since `glab` 0.11.0 a slug with sub-plans commits once per sub-plan (`[flow-master-plan/plan.md D30]`).
- [flow-planner/plan.md D21] `flow-models-per-role` stays a separate plan, after this one — **the user's decision**, carried (`[flow-planner/evidence.md F7]`; `[flow-cheaper-rounds/follow-ups.md FUc]`). That plan ran after `flow-master-plan` and landed as `09d5664` and `517b7b6` (`glab` 0.12.0).
- [flow-planner/plan.md D22] `AGENTS.md` *One fact* changed as its S8 says: the mapping-files entry names `evidence.md`, the context-hook entry the suffix, the first step and the warning, and three entries are new — the plan size budget, in-place amendments, `glab:plan-first`'s step numbers (`docs/specs/marketplace.md`).
- [flow-planner/plan.md D38] `evidence.md` and `evidence.r<n>.md` wherever the payload names the file; readers, and the manager's Stage 1b copy and `cmp`, still accept `findings.md` in a folder from before 0.10.0. It amends `[flow-cheaper-rounds/plan.md D10]` and `D49` by the name only (`[flow-planner/evidence.md F9]`, `F11`).
- [flow-planner/plan.md D19] One `glab:developer` for the change, since most steps shared `manager/SKILL.md` or `AGENTS.md` — scoping of that change, spent.
- [flow-planner/plan.md D41] The change ran under the 0.9.0 rules it changed, with no `master.md` — scoping of that change, spent. Round 3 split round 2's plan in two, on the user's approval: the plan carried D1–D22, D38 and D41 of round 2's ids, and round 2's other decisions, its S3 and S6 and FU7 and FU9 moved to `plan/flow-master-plan/`, not recorded here.
- [flow-planner/plan.md effort] `- effort: high`, the user's words for that session after its compact — that session's own line, spent.
- [flow-master-plan/plan.md D23] **The user's decision:** a constant master plan and isolated sub-plans — "planner must logical isolated plan stages to separated plans … the based high level plan as a constatn / sub plans witch are must be a low level plans / each low level plans must be iterated with isolated planning cycle / and must be good to have low level plan specs constant validation or verification flow also"; its aim: "subagents can read all plan … it can consume more tokens".
- [flow-master-plan/plan.md D24] Every folder gets `master.md`, and beside it one `plan.md` by default or `index.md` and sub-plan folders, each a full plan folder: a small task has two files and no tree (`[flow-master-plan/evidence.md B5]`). The split lives in `index.md`, an engineering choice that amendments change (`B6`).
- [flow-master-plan/plan.md D25] Constant means hashed: `master.sha256` after `## Approval`, checked with `sha256sum -c` by every analyzer and by `/glab:develop`; `chmod a-w` was rejected (`[flow-master-plan/evidence.md B11]`).
- [flow-master-plan/plan.md D26] Approval comes after Stage 1b, so the user approves a checked plan — the user's at full tier and whenever the work split. It amends the manager's earlier order, in which full-tier approval came before Stage 1b (`glab:manager` Stage 1 until `0cbf5b0`; `[flow-master-plan/evidence.md F11]`).
- [flow-master-plan/plan.md D27] Split only into parts with their own goals and milestone, never across a fact the repo changes in one commit (`[flow-master-plan/evidence.md F15]`); each is planned once its dependencies are committed and built one at a time in `<nn>` order, so it cites the tree it is built on and each review sees one change.
- [flow-master-plan/plan.md D28] An agent reads `master.md`, its own folder, its `index.md` line and the slug-level map files its dispatch names — the user's token aim (D23); only the coverage and final checks read all of `index.md`.
- [flow-master-plan/plan.md D29] Round caps per sub-plan and stage; the master and final checks have the same cap, their round-3 line in `index.md` (`plan.md` with no sub-plans). It extends `[flow-cheaper-rounds/plan.md D2]` (marked above).
- [flow-master-plan/plan.md D30] One commit per sub-plan, one push and one record per slug; a single plan commits once (`[flow-master-plan/evidence.md B7]`: with one commit per slug the blind reviewer of sub-plan 2 would see sub-plan 1's uncommitted change). `AGENTS.md`'s version rule then reads per push: the push's first commit that changes the plugin raises it (`[flow-master-plan/evidence.md F15]`; `docs/specs/marketplace.md`).
- [flow-master-plan/plan.md D31] Stage 3 runs for every sub-plan at every tier, as the user listed the cycle "plan → analyzer plan check → develop → analyzer conformance → review"; it amends `[sync-local-edits/result-followups.md D5]` for sub-plans only (marked above); a normal-tier single plan keeps none (`[flow-master-plan/evidence.md B12]`).
- [flow-master-plan/plan.md D32] **The user's decision:** the analyzer checks the intent at Stage 1b, Stage 3 and the final check — "analyzed … on every stage must validate and find gaps between original business plan and implementation"; the reviewer stays blind — "review agent must only check the code itself without any plan" — so no reviewer file and no *One fact* review entry changed (`[flow-master-plan/evidence.md F10]`, `B9`). `[feature-model-switch/plan.md D5]` and `[flow-cheaper-rounds/plan.md D51]` stand.
- [flow-master-plan/plan.md D33] The final check is Stage 6b, after the slug's last commit and before the push; skipped only for a single full-tier plan, whose Stage 3 asked it.
- [flow-master-plan/plan.md D34] An intent gap after the build is a defect of the plan: it goes to a planning agent, and a developer reports it as `PLAN WRONG`.
- [flow-master-plan/plan.md D35] `glab:analyzer` gets the plan check and its verdicts `BUILDABLE` and `NOT BUILDABLE`, until then stated only by the manager (`[flow-master-plan/evidence.md F10]`); a master check or a final check has no `plan.md`, so its contract is `master.md` and `index.md` (`[flow-master-plan/evidence.md F17]`). It closes `[flow-cheaper-rounds/plan.md FU5]`. **Amended by `[flow-models-per-role/plan.md D6]` since `glab` 0.12.0 (`09d5664`):** the plan check, the master check and the two verdicts moved to `glab:plan-analyzer`; `glab:analyzer`'s final check keeps the `master.md` and `index.md` contract.
- [flow-master-plan/plan.md D36] No two analyzer kinds in that change: each check gains the intent question, and the split goes to `flow-models-per-role` with the planner agent (`[flow-master-plan/evidence.md B8]`, `[flow-planner/plan.md FU1]`). Done there (`[flow-models-per-role/plan.md D6]`, `09d5664`).
- [flow-master-plan/plan.md D37] **The user's decision:** the flow should "work with claude app|cli builtin flow". Plan mode carries the master's approval only when the user asks, main session only (`[flow-master-plan/evidence.md F12]`), after Stage 1b with no agent running, no plan file outside the repo, `plansDirectory` untouched. L1–L7 are the user's and no precondition of Stage 2; until they run, the payload and `README.md` mark each plan-mode claim F12 holds inferred or UNVERIFIED as `UNVERIFIED` and name the live test that settles it — the manager's decision after plan check round 1. A `PreToolUse` hook on `ExitPlanMode` to record the approval was rejected (`[flow-master-plan/evidence.md B10]`).
- [flow-master-plan/plan.md D39] `## Record` moves to `master.md`; a folder with no master keeps `plan.md`'s. It amends `[feature-docs-specs/plan.md D5]` and `D28` (marked above).
- [flow-master-plan/plan.md D40] The stage listings gain "final check" (`[flow-master-plan/evidence.md F13]`): the manager's description, `glab:bootstrap` step 4 and the hook text. **Amended since `glab` 0.13.0 (`6f8b948`; R2-5, BS4, H1):** `glab:bootstrap` step 4 and the hook text point at *The pipeline* and list no stages; the manager's description is the one listing, and the *One fact* entry is gone.
- [flow-master-plan/plan.md D42] A single plan's Stage 1b analyzer reads `master.md` and `plan.md` together.
- [flow-master-plan/plan.md D43] (round 3 of `flow-planner`, the split) The plan was built on the tree `flow-planner` left on `origin/main`, `28f7d1d`, and nothing in `flow-planner` depends on it — scoping of that change, spent.
- [flow-master-plan/plan.md D44] (the split) As `[flow-planner/plan.md D18]`, `D19`, `D20` and `D22`, for this change: `glab` 0.10.0 → 0.11.0, nothing removed, so no `!`, `memory-sync` untouched at `0.1.0`; one `glab:developer`, one commit with the plan folder (`0cbf5b0`), and *One fact* changed as its S8 says (`docs/specs/marketplace.md`) — scoping of that change, spent but for the version.
- [flow-master-plan/plan.md D45] (the split) The change ran under the 0.10.0 rules it changed, as `[flow-planner/plan.md D41]` did under 0.9.0: no `master.md`, its findings in `evidence.md`; the user's words are in D23, D32, D37 — scoping of that change, spent. The first plan to run under the master rules is the next one (`[flow-master-plan/plan.md FU9]`).
- [flow-master-plan/plan.md D46] The manager's decision after plan check round 1: at full tier each sub-plan's `plan.md` also gets the user's explicit approval after its own Stage 1b, as an `## Approval` line at its end; at normal tier the master's approval covers the sub-plans — so *Pick the tier*'s explicit approval holds for every full-tier plan. Extended in review fix round 1 to a single full-tier plan's `plan.md`, approved together with the master (`[flow-master-plan/result.md R2]`).
- [flow-master-plan/plan.md D47] The change closed the two follow-ups `flow-planner`'s record left it, `[flow-planner/record.md review-waiver-implement]` (S1, S9) and `[flow-planner/record.md review-t19-comment]` (S10) (`[flow-master-plan/evidence.md F17]`); both under *Closed follow-ups*.
- [flow-master-plan/result.md R1] Review fix round 1, the manager's decision on a blocking finding: no round amends an approved `master.md`; a changed request is a new master, the old kept as `master.v<n>.md`, its approval and hash not carried over, `master.sha256` removed when the planner is dispatched, and a new Stage 1b, approval and hash.
- [flow-master-plan/plan.md effort] `- effort: high`, the user's words for that session after its compact — that session's own line, spent.
- [flow-models-per-role/questions.md Q1] **The user's answer, 2026-11-11: "Default"** — to a Rule 3 ask (it costs money and changes what the product is): the approved table ships as glab's default for every installer, each agent's model set in its definition, the user's words for a task still overriding it, Rule 5 reworded, every installer getting these models and their cost. The option text is as the manager relayed it, not the user's verbatim option (`questions.md`). The plan rests on it in D2 and D7–D10.
- [flow-models-per-role/plan.md D1] One plan, one commit, no sub-plans: the *One fact* entries the change rewrote (the model rule, the agent count, the analyzers' verdict lines, the intent check, the severity levels) each span files of every part, and the plan fit the 48 KB budget. Done as `09d5664`; the PR #7 review fix `517b7b6` landed with it on `origin/main` through PR #7 (merged 2026-11-12).
- [flow-models-per-role/plan.md D2] The table ships as each agent's default, set by the frontmatter `model:` of its definition — the user's answer "Default" (Q1), not a planner choice. Supersedes `[feature-model-switch/plan.md D8]`.
- [flow-models-per-role/plan.md D3] The values are the aliases `opus`, `sonnet`, `haiku`, never full IDs: aliases follow the recommended version per provider and a full name pins one (`E3`); the Agent tool's `model` parameter takes aliases only (`E1`, `E2`), so overrides and defaults speak one vocabulary.
- [flow-models-per-role/plan.md D4] A `glab:planner` agent exists (`model: opus`) and `/glab:plan` dispatches it, as `/glab:analyze` dispatches its analyzer: until then no file named the planning agent's type, so it ran on whatever generic agent the manager picked, on the main conversation's model (`E7`); a default needs a definition to live in. Closes `[flow-planner/plan.md FU1]` and `[flow-cheaper-rounds/plan.md FU1]`. **Amended since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md]` request 4, review round 1 A2):** `commands/plan.md` is gone; `glab:manager` Stage 1 dispatches `glab:planner` directly, and a `/glab:plan <task>` the user types runs `glab:plan` in the user's session (the user's "Plan in my session").
- [flow-models-per-role/plan.md D5] `glab:planner` has the explicit `tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch` — every tool `glab:plan-first` needs and no `Agent`, so it cannot start nested subagents that would run with no model or effort set under Rules 0d and 5 — **the manager's decision on review finding R2.2**, replacing "no `tools` line, inherit every tool"; its body confines its writes to the plan folder its dispatch names, with the exceptions the dispatch can grant (R2.1). **Amended since `glab` 0.13.0 (`6f8b948`; the decision on the preload lists, PL1):** the planner also preloads `glab:plan` and `glab:security` through `skills:`, and keeps `Skill` for the `glab:manager` sections `glab:plan` points at, never to reload `glab:plan`; its cost is `[flow-commands-to-skills/follow-ups.md FU-3]`.
- [flow-models-per-role/plan.md D6] Two analyzer agents, not one with two modes: `glab:plan-analyzer` (`model: opus`) takes the plan check and the master check of Stage 1b; `glab:analyzer` (`model: sonnet`) keeps the conformance check, the final check and the record check. A frontmatter default is per file, and one file with a per-dispatch model would put the default back in the manager's memory (rejected `B2`); each file also loads less (`E10`). Amends `[flow-master-plan/plan.md D35]`; carries out `[flow-master-plan/plan.md D36]`.
- [flow-models-per-role/plan.md D7] `glab:analyzer` keeps its name for the conformance kind, so the Stage 3, 6b and 8 citations and `/glab:analyze`'s name stay; only Stage 1b's citations move to `glab:plan-analyzer`.
- [flow-models-per-role/plan.md D8] One `/glab:analyze` command, its argument still the slug, routes by the check the dispatch names first: a named plan or master check to `glab:plan-analyzer`, even with a `result.md` present (an amended plan keeps its earlier `result.md`; the PR #7 review comment, fixed in `517b7b6` and D8 updated in place), a named final or record check to `glab:analyzer`; with no check named, the folder settles it — a `result.md`, the conformance check (`glab:analyzer`), none, the plan check (`glab:plan-analyzer`); it asks only when a named check is none of these — **the manager's decision on review finding R2.4**: asking whenever `result.md` exists would stop every Stage 3 for the user, and a sub-plan slug has no slug-level `result.md`, so the folder alone cannot route its final check. Rejected: a new `/glab:plan-check` command (`B4`: `Skills (14)` → 15 for no gain). **Amended since `glab` 0.13.0 (`6f8b948`):** the command is the stage skill `glab:analyze` (`skills/analyze/SKILL.md`, *Which agent*), its argument still the slug; the routing is unchanged.
- [flow-models-per-role/plan.md D9] Rule 5 reworded: with no instruction, no `model` parameter, and the definition's model runs; the user's words override for any role they name, passed as the `model` parameter on every dispatch of that role; the manager never picks one; an agent with no definition (mapping, read-only, fan-out not one of the seven) gets no parameter unless the user names one for it — Q1's answer. Supersedes `[feature-model-switch/plan.md D2]`, amends `D1`.
- [flow-models-per-role/plan.md D10] Rule 5's dispatch-per-model table applies to the model the agent runs on, its default included: a `glab:committer` dispatch is written for `haiku` and every Sonnet-default dispatch pastes the role's *Report* section — `[feature-model-switch/plan.md D20]`'s rule kept, now met by defaults. **Superseded in part since `glab` 0.13.0 (`6f8b948`; `[flow-commands-to-skills/plan.md]` B23):** no dispatch pastes the *Report* section; a `glab:committer` dispatch is still written for `haiku`.
- [flow-models-per-role/plan.md D11] The handoff line names the model on every stage that dispatches an agent, not only develop and review: `model <alias>` after the stage, the table's alias when no parameter was passed, `model <alias> (user)` when the user's override was; `model default` goes, because every role now has one. Amends `[feature-model-switch/plan.md D11]`.
- [flow-models-per-role/plan.md D12] An override for the Stage 8 record's agents, which have no `plan.md` to record it in, lives in the conversation only, as for a `/glab:review` with no plan. Closes `[feature-docs-specs/follow-ups.md 5]`.
- [flow-models-per-role/plan.md D13] Rule 5 and `README.md` say that `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the seven glab agents — a frontmatter `model` outranks it — and that `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` still overrides both the definitions and the parameter, from v2.1.257 (`E1`): an installer who set the variable to save money would otherwise lose that without a word.
- [flow-models-per-role/plan.md D14] No `effort:` in any frontmatter: Rule 0d passes `effort` on every dispatch at the session's level, and its substance did not change (S5 edited only its agent list and its no-`model` sentence); a subagent on a model other than the main conversation's does not take the session's level unless `effort` is passed (`E4`), one more reason the parameter is always passed. Keeps `[subagent-effort/plan.md D6]`.
- [flow-models-per-role/plan.md D15] A new gate in `AGENTS.md` *Gates* prints every agent's `model:` line, because `plugin validate --strict` passes an unknown value such as `model: sonnett` and `plugin details` shows no model (`E6`). Binds `docs/specs/marketplace.md` too.
- [flow-models-per-role/plan.md D16] `Agents (5)` became `Agents (7)` in `AGENTS.md` *Gates*, and `README.md`'s table lists the seven; the `README.md` line naming "five agents under `agents/`" stays: it lists what an old copied install put in `~/.claude/agents/`, which a new agent was never part of (`E8`). Binds `docs/specs/marketplace.md` too.
- [flow-models-per-role/plan.md D17] `glab` `0.11.0` → `0.12.0`: new agents and a changed default, nothing removed, so no `!`; `memory-sync` untouched, `0.1.0`. Binds `docs/specs/marketplace.md` too.
- [flow-models-per-role/plan.md D18] The new agent files restate no *One fact* value they can cite instead — the manager's decision: `glab:planner` cites `glab:plan-first` and restates none of its values (no step numbers, no `implement.md`, no `map-<area>.md`, no master `## Approval`), so `planner.md` joins no *One fact* entry; `glab:plan-analyzer` carries, copied from `glab:analyzer`, only what its check needs — the contract read, the plan check, the intent question's plan-check bullet, the plan-check re-check, the severity scale, the verdicts `BUILDABLE`, `NOT BUILDABLE`, `BLOCK: target unresolved` — and `AGENTS.md`'s entries for those facts gained its path. **Amended since `glab` 0.13.0 (`6f8b948`; R1):** `glab:planner` follows the preloaded `glab:plan` and joins the *One fact* entry "`glab:plan`'s step numbers — 0 to 4".
- [flow-models-per-role/plan.md D19] Mapping agents keep no model: they are not in the table, so D9's no-definition rule covers them (`FU2`).
- [flow-models-per-role/plan.md D20] `glab:plan-analyzer`'s `tools` is `analyzer.md`'s, `Read, Grep, Glob, Bash`, without `Skill`, though the docs say a `tools` list without `Skill` cannot invoke skills (`E9`): all five agents then had that gap (`E13`), so closing it for one file widens scope; it is `FU1`. Review finding R2.3 raised it again for the new agent; **the manager kept this decision**, and `FU1` covers all six. **Amended since `glab` 0.13.0 (`6f8b948`; FU1-2):** the gap `FU1` named is closed in the tree by the `skills:` preload, which needs no `Skill` tool; `tools` is unchanged; that the preload loads is UNVERIFIED (U4, U5).
- [flow-models-per-role/plan.md effort] `- effort: high (the user's words: "high (Recommended)"), for the session` — that session's own line, spent.
- [flow-commands-to-skills/questions.md Q1] **The user's answer, 2026-11-13: "A: plan only"** — `glab:plan-first`, now `glab:plan`, plans and stops at Step 4; `implement.md` is removed with `git rm`; its one rule `glab:developer` lacked moves into `developer.md` Step 3 (D4b). Recommended because a rule lives once, in the file of the role that acts on it, and the role that implements is `glab:developer`. Option B, keeping `implement.md` for a session that implements by itself, was not taken.
- [flow-commands-to-skills/plan.md glab:plan] **The user, 2026-11-13: "Yes, merge them"** — `glab:plan-first` merges into the stage skill `glab:plan`: one skill, `plugins/glab/skills/plan/SKILL.md` (Steps 0–4), moved with `git mv`; `commands/plan.md` removed with `git rm`, its wrapper text not carried over; Stage 1 dispatches `glab:planner` directly; the planner preloads `glab:plan`; every `plan-first` reference renamed but one (below).
- [flow-commands-to-skills/review-1.md A2] **The user, 2026-11-13: "Plan in my session"** — replacing the manager's round-1 decision that every `/glab:plan` go to `glab:planner`: a `/glab:plan <task>` the user types runs `glab:plan` Steps 0–4 in the user's own session, as `plan.md` request 4 said; that is the user's choice and no breach of Rule 2 or Rule 5, said once, in `glab:manager` Stage 1; every plan request not typed as `/glab:plan` still goes to `glab:planner`; `glab:plan`'s `description` says so; no `disable-model-invocation`, which the preload needs unset.
- [flow-commands-to-skills/plan.md request-2] **The user's principle, "say it once"**, relayed by the manager: "We also need to carefully examine and remove any conflicting or redundant elements within the project manager skills", and "agent must receive the thing once and clear, Skills should not have a repeating context for project manager skills". The test for every rule is who acts on it: the acting role's file owns it, other files drop it or keep a short pointer; *One fact* registration is no exemption; recorded incidents are kept, once, beside the rule they explain. It binds every later change to the payload, and this spec follows it by naming owning files instead of restating their rules.
- [flow-commands-to-skills/plan.md FU1-1] A rule only one role acts on lives in that role's file; Stage 1b's per-analyzer checks and their cases moved into `glab:plan-analyzer` *The plan check*, the manager keeping one pointer — the manager's decision.
- [flow-commands-to-skills/plan.md FU1-2] A shared rule lives once, in `glab:security`, `glab:comments` or `glab:audit` (the planner's procedure in `glab:plan`), and reaches each agent through its frontmatter `skills:` list, written `glab:<name>` as a YAML list, which plugin agents support and which needs no `Skill` tool; that the content loads is UNVERIFIED (U4, U5).
- [flow-commands-to-skills/plan.md FU1-3] A dispatch carries only per-task facts — slug, step ids, file boundary, sub-plan paths, decisions and answers not in the plan, the round and its inputs, the temp directory, the `effort` and `model` parameters; Rule 0c, `glab:bootstrap` step 2 and the session-start text's point 3 say so.
- [flow-commands-to-skills/plan.md FU1-4] A stage skill is an entry point: preconditions, the agent it dispatches, a pointer. Routing, dispatch lists and gate runs are the manager stage's, which won where they disagreed; `glab:push` keeps its own procedure and `glab:ship` its verdict gate.
- [flow-commands-to-skills/plan.md preload-lists] `glab:security` for all seven agents; `glab:comments` for developer, integrator and reviewer; `glab:audit` for reviewer, analyzer and plan-analyzer; `glab:plan` for the planner, which keeps its `Skill` tool for the `glab:manager` sections `glab:plan` points at and is told not to load `glab:plan` again (PL1, F2-9). Review finding A6 (read only those sections) was rejected: the Skill tool loads a whole skill and a read by path in an installed plugin is UNVERIFIED; the cost is `[flow-commands-to-skills/follow-ups.md FU-3]`.
- [flow-commands-to-skills/plan.md restatements] An agent file's restatements of `glab:security` go once the agent preloads it; what only the role does stays — the developer's closed list and record rules, the integrator's container rules, the committer's deny-list.
- [flow-commands-to-skills/plan.md invocation] No stage skill and no preloaded skill sets `disable-model-invocation` or `user-invocable` (F4): the first would stop the manager's Skill-tool call and the preload. No `allowed-tools` or `model` in any stage skill. The bare aliases (`/push`, `/ship`, …) are accepted: every stage skill keeps its waits for the user (I5).
- [flow-commands-to-skills/plan.md frontmatter] Each stage skill's frontmatter carries `name: <n>` on line 2, bare (F7); its `description` and `argument-hint` stayed byte-identical to the command's except `develop`'s description (A4); `glab:plan` kept the command's `argument-hint` (PF0).
- [flow-commands-to-skills/plan.md constants] `docs/constants.md` is read by `glab:planner` alone; no dispatch repeats it (R11). An agent with no definition gets `glab:security` (and `glab:audit` for findings) named in its dispatch, its one channel. The temp directory is carried by the dispatch; "never `/tmp`" is said once in each agent file that writes temp files (B10).
- [flow-commands-to-skills/plan.md B23] Rule 5's report-template paste for `sonnet` and `haiku` goes: the agent's own *Report* is its template, Rule 5's report check the backstop; this reverses a 0.12.0 dispatch choice, not the model table. It supersedes `[feature-model-switch/plan.md D21]` and part of `[flow-models-per-role/plan.md D10]` (marked above).
- [flow-commands-to-skills/plan.md A30] The Rule 5 version history leaves the manager; its exact text is carried into this spec (*Rule 5's version history*), and the *Precedence* bullet names `docs/specs/workflow.md` without a section (R10). It supersedes `[feature-model-switch/plan.md D17]` (marked above).
- [flow-commands-to-skills/plan.md cases] Cases are kept once, next to their rule: Stage 1b's in `plan-analyzer.md`, the DSN leak in `glab:security`, `make lint` and 85 mockgen in `analyzer.md` Step 4, the cached test in bootstrap step 6, the deleted-`TODO` reasoning in `glab:comments`.
- [flow-commands-to-skills/plan.md A13] A `/glab:review` round tells the reviewer the round, and the reviewer keeps its own round-2 rule because it acts on it; the analyzers only rate, so their round-3 sentence goes. Supersedes `[flow-cheaper-rounds/plan.md D55]` (marked above).
- [flow-commands-to-skills/plan.md B16] The plan-analyzer's step status `done` became `buildable`; the manager matches verdicts, not step statuses.
- [flow-commands-to-skills/plan.md A5] `glab:plan` Step 3 gains the three phases; the manager's checklist item 2 checks Step 3's list.
- [flow-commands-to-skills/plan.md C12] Gates and tests stay the bootstrap's (step 3) and the developer's (Step 3); the manager's *Know the gates* and Stage 2 verify point at them. Review finding B3 (move them into `glab:security`) was stopped by the fix-round developer as `PLAN WRONG` and then applied the plan's way, the manager's text shrinking to one pointer.
- [flow-commands-to-skills/plan.md voice] Stage skills write "the user" for the first person and "the session that runs it" for the second; every wait for the user stays — push go-ahead, force-push and upstream choices, `main` before pushing, a commit on `main`, full-tier approval, Rule 3 questions.
- [flow-commands-to-skills/plan.md waiver] The trivial-work line and its reason live once, in `glab:manager` Rule 1, which `glab:plan` Step 0 points at before it stops; the user-only waiver rule lives once, in `glab:plan` *User Override*, and Stage 1 names the manager as the one who writes `waived.md` under it (R2-1, R2-2).
- [flow-commands-to-skills/review-1.md decisions] The manager's round-1 decisions that stand: A1 (a no-plan `/glab:ship` fix is a `glab:developer` fix round whose contract is the review findings quoted verbatim, the one exception to `BLOCKED: no contract`), A4 (Rule 2 wins when the manager invoked a stage skill), A7/B4 (the developer's fix round takes the integrator's `FAILED`), B10 (the comments, security and status-enum changes belong to this plan; not split out), and "say it once" applied to the two repeats the reviewer did not count (`manager:342` against the round-3 rule and `reviewer.md:96`; `manager:346` against `reviewer.md:100`); A2 as the user answered it, A6 rejected, B3 the plan's way (above); `glab` stays `0.13.0` through the fix round.
- [flow-commands-to-skills/plan.md spent] Tier normal; the installed workflow planned it with no `master.md`; one commit with the plan folder (`6f8b948`), the committer owning the subject; six steps files for a 48 KB `plan.md`; every edit a block with its own red-when-skipped post; P1 through `git mv`/`git rm`; Stage 4 as the milestone test A1–A3; plan check round 2 `BUILDABLE` with no third round; `- effort: high (the user's words: "high (Recommended)"), for the session` — scoping of that change, spent. The version, the *One fact* changes, the commit-scope list and the `README.md:164` exception bind in `docs/specs/marketplace.md`.
- [flow-product-level/plan.md session-rules] **The user, 2026-11-13: "go with your recommendations"** — the rules every manager shares live once in `glab:session-rules`, which both managers read; *The level boundary* is its first section (`F22`); and this record says it changes `glab:manager` for every project user, beyond the project edges, the words kept (I16, I17).
- [flow-product-level/plan.md level-line] The level is a line `glab-level: <level>` in the repo's `AGENTS.md` (C1), not an environment variable; no line or no file is the project level; any value not built runs as project with the warning, the value checked after the line is found (R10); read from `$CLAUDE_PROJECT_DIR`, else `$PWD`, else the top of the git work tree (`F4`).
- [flow-product-level/master.md Request] **The user: "manager(s): must work with current flow what we have" and "product:project:plan:report (must force managers to send back report of planing before go to development phase)"** (from `plan/manager-flow-notes.md` *Idea 1* and *Idea 2*, untracked, quoted in `master.md` *Request*) — G3: the project level runs today's flow and changes only at its edges; it sends its plan report before development and waits for the verdict (Stage 1c and the develop gate, `report-brief` and `once-per-slug`, here).
- [flow-product-level/plan.md report-brief] The report is sent after every approval the plan needs, as Stage 1c; `report` and `check` refuse when the brief changed since the plan quoted it; a plan from a brief must quote it (checklist item 8, I2).
- [flow-product-level/master.md Request] **The user: "mean: example: planing skill of product manager must not work for project manager(s)"** (from `plan/manager-flow-notes.md` *Idea 1*, untracked, quoted in `master.md` *Request*) — G2: a session runs one level only, and each manager uses only its own level's skills (`boundary`, below).
- [flow-product-level/plan.md boundary] The boundary is each level manager's explicit list *Your skills — this level only*, and the rule binding to it is written once, in `glab:session-rules` *The level boundary* (I12, F14, F22); a skill or agent serving every level carries no prefix; every other description begins `Product level — ` or `Project level — ` (N2, amended); the product agents have no `Skill` tool (`E11`). **Amended by `[level-guard/plan.md D2]` (`632dcb0`, `glab` 0.17.0):** the list stays the one owner, and `level-guard.sh` reads it from that section to refuse another level's skill (*The level guard as of 0.17.0*); the decisions of the hook are in `docs/specs/product.md`.
- [flow-product-level/plan.md rules-move] Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, the round caps and the handoff line move into `glab:session-rules` with their words kept and one reading rule at its top (J2; `FU-P1`, closed); Rule 4 stays in `glab:manager`; Rule 5's list gains the two product roles; `glab:commit` and `glab:push` name either level's stage and take the commit-on-`main` rule (R6); every pointer names `glab:session-rules` (J12); `glab:audit`'s two project-scoped sentences stay.
- [flow-product-level/plan.md once-per-slug] A plan from a brief is reported once per slug, every sub-plan planned, checked and approved before Stage 1c (R2-1; L16): one report per sub-plan lost, being an audit per sub-plan, against Q1's "not per change".
- [flow-product-level/plan.md rejected] On `REJECTED`: round copies, a new planning agent amending from the verdict's reason, one Stage 1b delta round per verdict outside Stage 1b's cap, the approvals, report `r<n+1>`; a `REJECTED` whose fix needs `master.md` is a changed request (R13).
- [flow-project-level/index.md D5] `glab:project-manager` keeps the titles *The pipeline*, *Pick the tier* and *Your skills — this level only*, which the session-start hook text and its two tests name.
- [flow-project-level/index.md D6] The project stage skills are `glab:project-*`; the three new ones are `glab:project-plan-accept` (Stage 1, the manager's side), `glab:project-plan-analyze` (1b) and `glab:project-record` (8); `glab:project-analyze` keeps Stages 3 and 6b only. A stage's detail lives in its stage skill, not the manager (`[flow-project-level/03-project-manager/plan.md W1]`, `W2`: a pointer `glab:project-manager` Stage <n> is retargeted to the skill that holds it).
- [flow-project-level/index.md D7] The planner writes the tier line by `glab:project-plan` Step 0's criteria; the manager accepts it or sends the plan back to be raised, in `glab:project-plan-accept`; a raise after acceptance is a `## Decisions` overrule line.
- [flow-project-level/index.md D8] The Stage 3 and 6b dispatches carry the slug only; the `result.md` summary is for the user; said once, in `glab:project-analyze`.
- [flow-project-level/index.md D9] `glab:project-planner` has no `Skill` tool; nothing the planner acts on stays in the manager.
- [flow-project-level/index.md D10] `glab:severity` owns the four levels and their meanings; the four rating agents preload it instead of `glab:audit`, which points at it.
- [flow-project-level/index.md D11] A pre-0.11.0 compatibility clause stays only in the role file that acts on it; dropping them is a follow-up (below).
- [flow-project-level/index.md D12] `glab:bootstrap` stays at most 6144 bytes and `glab:session-rules` at most 13312 (D4); a restated step is a pointer, and the four tool hazards stay in the payload, in `references/hazards.md` (`[flow-project-level/02-shared-rules/plan.md W5]`).
- [flow-project-level/index.md D14] Invoke a stage skill once per context, again only after a compaction (re-injection UNVERIFIED, *Known limits*).
- [flow-project-level/index.md D17] `README.md` lists each old name bare, in a column headed "was `glab:`", beside its new name, so the old-name search stays a plain absence check.
- [flow-project-level/02-shared-rules/plan.md W7] Rule 5's `haiku` dispatch paragraph is `glab:commit`'s; Rule 5 keeps one pointing clause.
- [flow-project-level/index.md D21] The handoff file is `plan/handoff/<session id>.md`, the id read from the `SessionStart` hook's stdin with `jq` and used only when it matches `^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$`; else the hook text says `no session id` and the manager names `plan/handoff/<UTC yyyymmddThhmmss>Z.md`.
- [flow-project-level/index.md D22] It holds the current state only, rewritten in place, at most 4096 bytes (`wc -c`); D23: it opens with `- status: in-flight` or `- status: completed`, `- session: <id>`, `- updated: <UTC ISO 8601>`, and a file with no status line is `in-flight` (`[flow-project-level/02-shared-rules/plan.md W10]`).
- [flow-project-level/index.md D24] At the task boundary the manager writes `- status: completed` and removes its own file; D30: the one standing approval, in `glab:session-rules` Rule 2, covers a file `plan/handoff/<id>.md` whose first line is `- status: completed`, and nothing else. **Amended by `[docs-lifecycle/plan.md D5]`, `D27` and `[docs-lifecycle/review.r1.md 6]` (`glab` 0.16.0):** it is now one of the two standing approvals, labelled *The handoff approval*, covering "nothing else of the handoff files"; the other is the plan-folder approval.
- [flow-project-level/index.md D25] A live session cannot be told from a dead one: `glab:bootstrap` step 5 removes other sessions' `completed` files without asking, lists each other `in-flight` one and takes one over only on the user's yes; after a compaction a session keeps the file its own summary names. D26: `plan/SESSION-HANDOFF.md` is a legacy `in-flight` file, removed only on the user's yes.
- [flow-project-level/index.md D27] `plan/handoff/` is never committed; this repo's root `.gitignore` holds it, and no `glab` step edits a user repo's `.gitignore`. **Superseded by `[docs-lifecycle/plan.md D4]` (`glab` 0.16.0):** `glab:bootstrap` step 5 has the manager add `/plan/`, which covers `plan/handoff/`, to a repo's `.gitignore` when `git check-ignore -q plan/x` fails; this repo's line is `/plan/` (`D2`).
- [docs-lifecycle/plan.md U1] **The user, 2026-11-18, in chat:** after a slug's record is merged, the manager removes its untracked `plan/<slug>/` under a standing approval, like a completed handoff file; the docs are then the only lasting copy. D22 holds the exact words: asked "Under the docs lifecycle, plan folders are never committed, so once one is deleted it is gone for good. After a slug's record has written docs/specs/ and docs/features/, who removes its untracked plan/<slug>/ folder?", the user chose "Record removes it (Recommended)", whose text was "The manager removes plan/<slug>/ right after the record is merged, under a standing approval (like completed handoffs). Nothing piles up; the docs are the only lasting copy." Rule 2 quotes the option text, not the question and not the label, which says the record removes (`D38`). **Superseded by `[lifecycle-hardening/plan.md D26]` (`glab` 0.16.2):** the user's "Ask once per folder" (2026-11-18, in chat) replaced this standing approval for plan folders; Rule 2 keeps its words as a record, and the manager removes a folder only on the user's word.
- [docs-lifecycle/plan.md D2] The ignore line is `/plan/`, anchored at the root; an unanchored `plan/` would match any directory named `plan` at any depth, such as a `src/plan/` package in an installing repo.
- [docs-lifecycle/plan.md D3] The lifecycle rule's owner stays `glab:project-plan` *Plan files are working files*: `/plan/` ignored and never committed; after the push the record writes spec and feature pages; the record never removes; the manager removes the folder at a later session start, once the record has landed on the default branch. Every other file points at it.
- [docs-lifecycle/plan.md D4] `glab:bootstrap` step 5 checks `git check-ignore -q plan/x`; when it fails the manager adds `/plan/` to `.gitignore` as a Rule 1 trivial change with the next commit. Without the line, the first change's commit can carry every plan file.
- [docs-lifecycle/plan.md D5] Rule 2's plan-folder approval and its conditions, run from the repo root (`D36`): the slug's whole-name pattern, not `handoff` (`D23`); `! test -L plan`, `test -d plan/<slug>`, `! test -L plan/<slug>` (`D23`, `D36`); `realpath` inside this repo's `plan/` (`D36`); no `.git` (`D23`); no tracked file; a non-empty record-file list (`D37`); landed by `git diff --quiet origin/<default> -- <record files>`, which works for squash merges where ancestry does not (`D24`); nothing newer than its record (`D25`, with `<record-sha>` as `D45` set it); the command `rm -r -- plan/<slug>`, no trailing slash (`D23`); the outcomes as `D42` and `D45` set them. A legacy tracked folder, an audit file and anything else stop and ask, a tracked folder now reported in one line instead (`D45`). **Superseded in part by `[lifecycle-hardening/plan.md D26]` (`glab` 0.16.2):** the structural checks, the landed check and the command stay; "nothing newer than its record" is no condition any more, the newer files are listed as facts, and the folder is removed only on the user's word.
- [docs-lifecycle/plan.md D6] The `glab:security` and `glab:session-rules` pointers say "the standing approvals" and restate nothing.
- [docs-lifecycle/plan.md D7] A feature page `docs/features/<feature>.md` (kebab-case; the area's name when the area is one feature) says what the feature does, who it is for and how to use it: commands, inputs, outputs and the limits a user meets. It never holds decisions, incidents, follow-ups or records. The record writes or updates it only when what a user sees changed; `## Record` names the pages, or `feature pages: none`.
- [docs-lifecycle/plan.md D8] The record check also reads the feature-page diff for two things: no claim the spec contradicts, and no decision, incident or follow-up that belongs in the spec. The verdict lines are unchanged.
- [docs-lifecycle/plan.md D15] `glab:committer` never stages anything under `plan/`, even in a repo that has not yet added `/plan/` (the reason of D4).
- [docs-lifecycle/plan.md D16] The analyzers' plan revision line is `sha256sum plan/<slug>/plan.md | cut -c1-12` (of `master.md`/`index.md` in a final or master check); the old `git log -1 --format=%h -- plan/<slug>/plan.md` prints nothing once `plan/` is ignored.
- [docs-lifecycle/plan.md D17] `glab:push` step 4 shows the `## Decisions` lines of the slug's plan folder read from disk; the commits no longer carry it.
- [docs-lifecycle/plan.md D18] The *Records* line of a spec, and of a roadmap page, names the date, the slug, the change's commits on the pushed branch by both ends (`<first>` and `<last>`, not a `<first>..<last>` range, which leaves `<first>` out), the branch, and the PR/MR or "pushed without a PR". Old dated *Records* lines stay as records. `AGENTS.md` keeps one legacy pointer: a folder committed before `glab` 0.16.0 is read back with `git show <sha>:plan/<slug>/<file>`. `D26`: the squash/rebase note is in the rule.
- [docs-lifecycle/plan.md D24] One timing: the record runs after Stage 7 confirms the push. The removal is no exit condition of any stage, of P7 or of the task boundary; it is a separate manager action at `glab:bootstrap` step 5, at the next session start. U1's "merged" is read as landed on the default branch.
- [docs-lifecycle/plan.md D25] "The folder the record just recorded" is checked as no file under `plan/<slug>` newer than the record commit (`find … -newermt`, which must print nothing and exit 0); otherwise stop and ask. **Superseded by `[lifecycle-hardening/plan.md D26]` (`glab` 0.16.2):** `find plan/<slug> -newerct` (`D15`) only lists the newer paths beside the record commit, for the user to decide.
- [docs-lifecycle/plan.md D27] "Every other removal stops and asks (`glab:security`)" stands after both approval bullets, so no sentence forbids what the next bullet allows; the count words are "one of the two standing approvals" and "the other of the two standing approvals".
- [docs-lifecycle/plan.md D42] A removal check that cannot be evaluated leaves the folder, removes nothing and says so in one line of the session-start report, with no question; not landed is silent; every other failed condition asks. A folder whose branch was deleted after its merge is therefore never removed by the approval. **Superseded in part by `[lifecycle-hardening/plan.md D26]` (`glab` 0.16.2):** "cannot be evaluated" and "not landed" keep their effect; a folder whose branch is gone is listed and asked about, since the listing searches `origin/<default>`, not the branch; and "every other failed condition" is now a structural check, named and asked (`D27`).
- [docs-lifecycle/plan.md D45] (manager, review round 1) `<record-sha>` is the first commit after `<last>` touching the record files (`git log --reverse --format=%H <last>..<branch> -- <record files> | head -1`); the empty-sha guard is `ct=$(git log -1 --format=%ct "<record-sha>") && test -n "$ct"`; the record check covers feature pages, new pages read whole; the *Records* line format, with `<slug>`, is stated once in `glab:project-record` and pointed at; "The handoff approval"; tracked pre-0.16.0 plan folders are reported in one line, never removed or asked about; `project-developer:121` names feature pages. Finding 10 is accepted (*Open follow-ups*). **Superseded in part by `[lifecycle-hardening/plan.md D26]` (`glab` 0.16.2):** `<record-sha>`, its `<last>..<branch>` search and the `ct=` guard are gone; finding 10 is closed (*Closed follow-ups*).
- [lifecycle-hardening/plan.md D26] **The user, 2026-11-18, in chat**, answering "Drop automatic removal and ask once per folder, or keep it for squash merges only?" after review round 2 found that a squash amended or a rewritten default branch still passed the date guard: "Ask once per folder". This supersedes `D23` and `[docs-lifecycle/plan.md U1]`'s standing approval for plan folders. The manager never removes a plan folder unasked. At session start (`glab:bootstrap` step 5) it lists each `plan/<slug>` whose record has landed on `origin/<default>` and that passes the structural guards (slug pattern, repo root, no symlink at `plan` or the folder, `realpath` inside this repo's `plan/`, no nested `.git`, nothing tracked, record-file list non-empty), with the facts for each — the commit on `origin/<default>` that added its *Records* line (plain pickaxe on `- <date> · <slug> ·`) and the files in the folder newer (`find -newerct`) than that commit's author date — and asks the user once which to remove. It removes only those the user names, by exact path, `rm -r -- plan/<slug>`, re-checking the structural guards right before. A folder the user keeps is not asked about again in that session. The date guard, `--ancestry-path`, `--is-ancestor` and `<land-sha>`/`lct` logic go. Rule 2 again has one standing approval (handoff files); the plan-folder rule is a removal on the user's word, not an approval. Review r2's findings are moot. "Once per folder" is read as once per session (`[lifecycle-hardening/review.r3.md 5]`, open).
- [lifecycle-hardening/plan.md D27] (manager, D26 rework) The record still goes on the change's branch, now because it lands with the change it records, in the same merge; a folder that fails a structural check is not listed — the manager names it with the failed check and asks; the post-condition values `D26` makes stale are listed in `result.md` *D26 rework* and replaced by its searches and listing runs.
- [lifecycle-hardening/plan.md D3] The record is committed on the change's branch, after the change's push and before its merge, said in `glab:project-record` and in `AGENTS.md`'s `plan/` rule; the new *One fact* entry *Where the record is committed* lists both files (`docs/specs/marketplace.md`). Its reason was "while `<branch>` or `origin/<branch>` exists, Rule 2 can remove the folder unasked"; since `D27` it is that the record lands with its change, in the same merge. Recommended, not required: a record on another branch still lands, and Rule 2 lists its folder the same way.
- [lifecycle-hardening/plan.md D4] The lows, each as its follow-up proposed, refined: `[docs-lifecycle/review.r2.md session-rules:87]` → "in one shell command" (now on the facts command, `session-rules/SKILL.md:87`); `[docs-lifecycle/review.r2.md session-rules:91,93]` → "The outcomes, the first that applies:", tracked before not landed (`:89`, `:91`, `:92`); `[docs-lifecycle/review.r2.md project-record:13]` → the reviewer's target is "the uncommitted spec and feature-page paths" (`project-record/SKILL.md:15`); `[docs-lifecycle/review.r2.md project-record:12]` → "the spec and feature-page paths" (`:14`), the analyzer's `-- docs/` becoming "the spec and feature-page paths the dispatch names" (`project-analyzer.md:90`), the full rule kept only there. Its `p7-delivery-gate` half is in `docs/specs/product.md`.
- [lifecycle-hardening/plan.md D6] The record (on this branch, before the merge) closes each follow-up of the scope with `[lifecycle-hardening/plan.md D<n>]` (*Closed follow-ups*).
- [lifecycle-hardening/plan.md D7] `glab:bootstrap` step 5 stops restating Rule 2's outcomes and points at them ("apply Rule 2's outcomes, in their order"); it keeps what it owns — since `D26`: ask once, remove only the named folders, after the re-check, and the report line.
- [lifecycle-hardening/plan.md D9] (`check.r1.md` M1) `<line>` is `- <date> · <slug> ·`, the opening of the *Records* line already read; it stays stable when the PR field is edited, and an unanchored `· <slug> ·` also matches another slug's branch field (the plan's evidence (a), a throwaway repo: anchored → `2c174a2 rec-p7a`, unanchored `-S'· p7a ·'` → `7320774 other-rec`). Still binding: the facts command searches it.
- [lifecycle-hardening/plan.md D11] (`check.r1.md` M4) Rule 2's reason states the limit: a rebase with `--ignore-date` or `--reset-author-date` resets `%at` to its run time, so a file written between the record and that rebase is not listed as newer. Since `D26` it is a fact shown to the user, not a guard (*Known limits*).
- [lifecycle-hardening/plan.md D15] (`check.r1.md` L3) `find … -newerct` replaces `-newermt`: `cp -p`, `tar` or `rsync -t` keep the old mtime but not the ctime, so a copied or restored folder shows as newer. Proven: after `cp -p` of a 2020 file over `s/f.md` one second after `at`, `-newermt "@$at"` printed nothing and `-newerct "@$at"` printed `s/f.md`.
- [lifecycle-hardening/plan.md D22] (manager, 2026-11-18) Round 2 was the plan-check cap; `check.r2.md` N1–N5 were fixed as the checker specified and verified by the manager's greps, not by a third round (*Incidents*).
- [lifecycle-hardening/plan.md D23] **The user, 2026-11-18, in chat**, answering "Build the guarded automatic removal, or switch to one question per folder?": "Build it as planned". **Superseded by `[lifecycle-hardening/plan.md D26]`** ("Ask once per folder", the same day, after review round 2): kept as the user's earlier answer.
- [lifecycle-hardening/plan.md D1] `<record-sha>` is the commit that added the slug's *Records* line, searched on `<ref>` = `<branch>`, else `origin/<branch>` (its form `D8`, `D9`); `D1b`: the date compared is its author date `%at`, which a default rebase keeps (limit `D11`). **Superseded by `D26`:** no `<record-sha>` or `<ref>`; the facts command searches `origin/<default>` only.
- [lifecycle-hardening/plan.md D2] (refined) `<record-sha>` empty on `<ref>`, or neither ref exists: the pickaxe on `origin/<default>` (`D18`); a commit found only there → the folder stays and the manager asks, naming the commit, its `%at` and what `find` prints, since a squash's `%at` is the merge time and nothing in git tells it from a rebased record commit; found nowhere → "cannot be evaluated" (`D16`). **Superseded by `D26`:** every landed folder is asked about, with these facts.
- [lifecycle-hardening/plan.md D8] (`check.r1.md` H1) The automatic path searched only descendants of `<last>`: `git log --reverse --ancestry-path --format=%H -S'<line>' <last>..<ref> -- <record files> | head -1`; the ask path dropped `--ancestry-path` and searched `origin/<default>` (`D18`: kept, git is fatal, `fatal: --ancestry-path given but there are no bottom commits`, and `| head -1` hides it). `D12`, `D13`, `D16`, `D19`: "cannot be evaluated" as "`<record-sha>` empty on `<ref>` and on `origin/<default>`, or `$at` empty", the post-conditions guarding it, `D2`/`D3` softened. **Superseded by `D26`:** the facts command keeps only the plain pickaxe on `origin/<default>`.
- [lifecycle-hardening/plan.md D17] (`check.r2.md` N1) The automatic path also required `git merge-base --is-ancestor "<record-sha>" origin/<default>` to exit 1, so a squash or a commit merged unchanged asked; repos merging with merge commits or fast-forwards always asked. Proven: S1 rc=1, S5 rc=0. **Superseded by `D26`.**
- [lifecycle-hardening/plan.md D24] (manager, `review.r1.md`) Findings 1–4 fixed as the reviewer specified: (1) the automatic path also required `<land-sha>` (`git log --reverse --format=%H -S'<line>' origin/<default> -- <record files> | head -1`) non-empty and `%at` of `<record-sha>` strictly less than `%ct` of `<land-sha>`, otherwise ask; (2) `project-record:11` "can remove … unasked", pointing at Rule 2; (3) the brief's precondition (`docs/specs/product.md`); (4) both safe cases named in Rule 2 (no `<ref>` and not on the default branch; a `git log` fatal hidden by `| head -1`). **Items 1 and 2 superseded by `D26`/`D27`**; item 4's `| head -1` sentence survives in the facts command's reason; item 3 binds.
- [lifecycle-hardening/plan.md D25] (manager) After `D24`, three post-condition values changed as `result.md` *Review r1 fixes* explains (session-rules `--ancestry-path` → 1, `format=%ct` → 1, the brief's old phrase → 0). **Superseded by `D27`:** the values `D26` makes stale are in `result.md` *D26 rework*.

## Known limits and not verified

- [feature-model-switch/plan.md I1] That the Agent tool on the manager's host takes `model` with the values `sonnet`, `opus`, `haiku`, `fable`, ranked above the definition's frontmatter — read from the tool definition given to one session; it depends on the Claude Code version and host. Its documentation citations (F1–F7, F16) were not re-fetched by the developer (`result.md` *Not done*). Re-read by `flow-models-per-role`: the docs fetched 2026-11-11 give the same alias set and rank the parameter above the frontmatter (`[flow-models-per-role/plan.md E1]`); the tool's own accepted values are still read from one tool definition, UNVERIFIED (`[flow-models-per-role/plan.md E12]`).
- [feature-model-switch/plan.md I4] That a plugin agent honours the per-dispatch `model` — inferred from the docs' list of fields a plugin agent ignores; no live dispatch on `haiku` has been seen running on `haiku`. Rule 5 says so in its own text; `/tasks` would show it. **Re-read by `flow-models-per-role` (`09d5664`):** that `model` is supported in a plugin agent is now documented, not only inferred from the ignore list (`plugins/components.md:324`, `[flow-models-per-role/plan.md E2]`); that a live dispatch honours it, frontmatter or parameter, is still not shown — `[flow-models-per-role/plan.md I1]`.
- [subagent-effort/plan.md unverified] UNVERIFIED: that a plugin agent honours the Agent tool's `effort` parameter — no live dispatch has shown it, the same hedge Rule 5 makes for `model`; the tool schema of the planning session showed only that `effort` takes `low|medium|high|xhigh|max` and that an omitted one leaves the agent at its usual effort. Unlike Rule 5's hedge, Rule 0d's payload text does not say so (`[subagent-effort/plan.md D7]`). Also not checked: how a session started without subagent dispatch is put at the recorded effort (`[subagent-effort/plan.md F1]`). `result.md` restates the first item.
- [subagent-effort/result.md blast-radius] Inferred, not tested: an older plan's `- model: … codex, effort <level> (…)` line is still readable prose, while the rule now records the effort in a `- effort:` line instead. Since `glab` 0.8.0 (`467b7c4`) no rule reads a Codex model line at all.
- [remove-external-agents/plan.md inferred] Inferred, not shown: a user who names an external reviewer or developer after 0.8.0 meets Rule 5's "say so, and ask which of the four the user means" (`D11`); no session was run. The user's own auto-memory, outside this repository, still describes Codex as an outside reviewer and developer "via the skill", which no longer exists; it is the user's file and the change did not touch it.
- [remove-external-agents/result.md not-done] UNVERIFIED: that a live session follows the edited prose of `glab:manager` and the commands as intended — no session was run against it, as the plan accepts; the searches C2–C4 show only that nothing naming the removed parts is left outside `docs/specs/` and `plan/`.
- That the user's local edits ported by `sync-local-edits` were exactly their 2026-10-08 change: inferred from the dispatch and the file times, not from a record of the edit (`[sync-local-edits/result.md L219]`).
- No `glab` stage removes a plan folder: Stage 8 writes the spec only, and a repo that wants its folders removed says how in its own `AGENTS.md` (`[feature-docs-specs/plan.md U10]`). A repo with no such rule keeps every recorded folder in its tree. This repo's rule is in `docs/specs/marketplace.md`. **Superseded by `docs-lifecycle` (`glab` 0.16.0, 2026-11-18):** the manager removes a recorded, landed folder at a session start under `glab:session-rules` Rule 2's plan-folder approval (*The docs lifecycle as of 0.16.0*).
- Stage 8 names no commit and checks no landing: it starts once Stage 7 has confirmed the push, and the record reads the folder from disk, so a squash or rebase merge does not change what it records. Naming the commit that holds a removed folder is the repo's own rule; this repo's names the last commit on `origin/main` that holds it, after `git diff --quiet origin/main -- plan/<slug>/`. In a throwaway repo a squash merge left the branch commit off `origin/main` and the folder on it, and `git log -1 --format=%h origin/main -- plan/<slug>/` gave the squash commit (feature-docs-specs findings, *Amendment — review round 1/3*). **Superseded by `docs-lifecycle` (`glab` 0.16.0, 2026-11-18):** Stage 8 still checks no landing, but no folder is committed, so no commit holds one; the *Records* line names `<first>`, `<last>`, the branch and the PR (`glab:project-record`), and the landing check is the removal's, `git diff --quiet origin/<default> -- <record files>` (`glab:session-rules` Rule 2).
- [feature-docs-specs/plan.md unverified] Not shown, as of the record: that an installed `0.5.0` runs Stage 8 as written (needs a session on an installed copy); that every incident of the seven migrated folders reached a spec and each migrated status is true (the check script proves tags and presence, not truth); that the payload texts read well; and the back-out's inference that an installed `0.5.0` ignores a move back to `0.4.2`. The squash-merge item of that list is answered above.
- [feature-docs-specs/findings.md inferred] The specs, the payload text and `AGENTS.md` are prose: no command judges them correct. An installed copy follows the rule only from `0.5.0`; the agents that built and recorded `feature-docs-specs` ran the installed `0.4.2`, so its folders were removed under `0.4.2` contracts, and its record (X1) was dispatched with Stage 8's steps in the message.
- [flow-cheaper-rounds/plan.md F1] **Measured by the manager in another project, not reproducible here** — the evidence the change rests on: total input over all turns 597M tokens, of which developers 49%, planners 21%, Stage 1b plan checks 11%, reviewers 8%, mapping agents 6%. Fix rounds sent back to the same resumed agent cost 149M, each round restarting at 300–450k context, modelled as fresh agents at about 37–64M. A Stage 1b round 2 that re-read the whole plan cost 9.5M against round 1's 9.0M; targeted re-check rounds cost about 40% of round 1. The planner, handed three mapping files, re-touched 40 of its 157 paths that mapping had already read. Normal-tier plans were run against full-tier caps. The manager session itself: 1,054 turns, a 648k peak, 348M tokens (about 37% of the run), five tasks and one compaction. **Inferred, not shown:** the savings each change brings, and that a live session follows the edited prose (UNVERIFIED, as for every rule of this change).
- [flow-cheaper-rounds/plan.md F8] Untested cases of the two delta mechanisms: a nested repository in the tree (`git add -A` would record a gitlink with a warning) and a large untracked directory that is not ignored (every file is hashed). Shown in a throwaway repo only: the snapshot catches tracked, staged, untracked and deleted files, leaves the real index and `git status` unchanged, skips ignored files, gives the same id for the same tree; `cmp -s` exits 0, 1 or 2 with no output. Limits kept in `[flow-cheaper-rounds/plan.md FU8]`.
- [flow-cheaper-rounds/plan.md F9] The Write-tool probe was partial: only `findings-probe.md`, `findings.md` (refused) and `map-probe.md` (accepted) were tried; which other names the guard refuses is not known. Extended by `[flow-planner/evidence.md F8]` (below): `evidence.md` and five other names accepted, `summary.md` and `report.md` still untried.
- [flow-cheaper-rounds/plan.md F15] Round 1's UNVERIFIED — that `CLAUDE_CODE_SESSION_ID` is set and names the transcript on any host other than the manager's — no longer binds anything: nothing reads the variable since `D30` (`FU9`, closed as moot).
- [flow-cheaper-rounds/plan.md F20] **Documented by Claude Code, not proven here, and UNVERIFIED where marked:** `PostToolUse` and `UserPromptSubmit` take `additionalContext`; `Stop` takes `systemMessage` (common field, "Warning message shown to the user") and, with exit 0 and no `decision`, lets the turn end; `SubagentStop`'s `additionalContext` goes to the subagent; the transcript "is written asynchronously and may lag"; hooks do not run under `disableAllHooks: true` or `--bare`. UNVERIFIED: that the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 (`FU11`); whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks (`FU15`); whether the Agent `tool_input` carries `effort` (`FU13`); which transcript a subagent that itself calls `Agent` is handed, if the hook fires there (changes nothing above). An interrupted turn fires no `Stop` (documented), so shows nothing; the next turn's `prompt` line still carries the number.
- [flow-cheaper-rounds/plan.md F23] What integration I1 showed and did not (the user ran it in their terminal, Claude Code `2.1.304`, one host, one version): shown — `agent` line current at `PostToolUse` (a 36,185-token request printed `37k`), the `prompt` line reached the model, `Stop`'s `systemMessage` shown to the user in the terminal with the turn ending there, and at `Stop` the turn's last call not yet written (there 1 s later). **Not observed:** whether the model also sees the `Stop` text (I1b's quote prompt was not reported); a display other than the terminal, such as the desktop app (`FU17`); how far the lag can grow on another host or under load (D62 relies on the transcript catching up within one turn); which plugin's second `Stop` hook ended `cancelled`, exit 1, in I1a (`FU18`). I1c, the re-run of I1b on the rebuilt `stop` (expected: nothing on turn 1, the line on turn 2, the turn ending there), **passed**: the plan folder holds no I1c output (`F24` holds the fixture run only); what it showed turn by turn, as the manager observed it from the user's screenshot, is in *Incidents* (IN1).
- [flow-cheaper-rounds/plan.md F24] The `stop` base and the new cases were proven on throwaway copies without a model: the rebuilt script `PASS 21/21`, the script as built before the fix `FAIL 3/21` (T18, T20, T21), and mutants of the rebuilt copy fail the test (a `"decision":"block"` in the `stop` JSON → T18, T20, T21, T19; `+ 999` removed → T1, T3, T13; the `isSidechain` filter removed → T15; the old real-prompt branch → T18, T20, T21). Fixtures only: a real transcript's shape on other CLI versions was not read (the brief keeps transcripts out of reach).
- [flow-cheaper-rounds/plan.md D62-limits] Known limits of `stop`'s base: a `/compact` inside the two turns it covers can hide a crossing until the next `Stop` whose base is past the drop; a lag longer than one turn is not covered by any case (it would still speak, later); and a window with fewer than two real prompts speaks at or past 300k.
- [flow-cheaper-rounds/result.md review-fix-1] Review round 1/1 (`SHIP`, low) found the script header claiming `stop` speaks "once per crossing, twice at most", untrue when fewer than two real prompts fall inside the 8 MiB window: then `base` stays 0 and `stop` speaks at **every** turn end while the context is at or past 300k. That needs more than 8 MiB of transcript between two consecutive prompts (one turn of very large tool results) and ends with the next ordinary turn. Accepted — the window bounds the read cost, a line too many is the cheaper error — and fixed by comment only (`plugins/glab/scripts/context-size.sh` header); the behaviour is covered by the T18 cases `no prompt in the window` and `one prompt in the window`, not by a 9 MB fixture.
- [flow-cheaper-rounds/plan.md F17] Not measured: how long `context-size.sh` takes on any host but this one. T9 prints it (0.07 s here on a 36 MB transcript); the hook's 5 s `timeout` is the bound if a host is slower. UNVERIFIED elsewhere.
- [flow-cheaper-rounds/result.md digit-guard] Not covered by any test case: the defensive digit guard in `context-size.sh` (`[[ $v =~ ^[0-9]{1,15}$ ]]`, its `fail` branch) — `jq`'s `floor` cannot fail it for any usage the fixtures can hold except an exponent form (usage above 1e17); it exists so the script can never reach a bash arithmetic error, which would break the exit-0 contract.
- [flow-cheaper-rounds/plan.md F18] The CLI labels every hook "harness-only — no model context cost" in `plugin details`, which is not true of a hook that returns `additionalContext` (`FU12`); the gate's green line for `glab` prints the events in the file's key order, so reordering `hooks.json` changes the line.
- [flow-planner/evidence.md F2] Shown: a sibling file in a skill folder changes neither validation nor the counts (a throwaway copy with `implement.md` added, a fresh `CLAUDE_CONFIG_DIR`: `✔ Validation passed`, `Skills (14)`, `Agents (5)`), and in that session the Skill tool put only `SKILL.md` into context. **Inferred:** that a sibling file costs nothing until read on other Claude Code versions, and that a session following `SKILL.md`'s pointer reads `implement.md` (Markdown has no runtime).
- [flow-planner/evidence.md F4] The developer figures — a 509k peak in one round, about 480k characters of tool output, `plan.md` read three times — are the caller's measurements of another project, inferred here. **UNVERIFIED:** that a `PostToolUse` hook can shorten a built-in tool's output (`[flow-planner/plan.md FU3]`); the context rules are prose, and whether a live developer follows them is not shown.
- [flow-planner/evidence.md F5] `GLAB_COMPACT_AT` was proven on throwaway copies and by T22–T24 only. **Inferred:** that a variable exported in the shell that starts Claude Code reaches its hooks (child processes); **UNVERIFIED:** that a settings file's `env` block does (`[flow-planner/plan.md FU4]`). No live session with the variable set has been run.
- [flow-planner/evidence.md F8] The Write-tool probe of round 2 (one subagent, one session): `findings.md` refused; `evidence.md`, `master.md`, `01-probe/plan.md`, `01-probe/evidence.md`, `index.md` and `evidence.r1.md` accepted. **Inferred:** the refusal keys on the name, not the directory or the agent type. Which other names it refuses (`summary.md`, `report.md`) is not known (`[flow-planner/plan.md FU8]`); this extends `[flow-cheaper-rounds/plan.md F9]`.
- [flow-planner/plan.md S7] One branch of the `GLAB_COMPACT_AT` code is covered by no case: the warning printed together with a failure line. Unreachable by construction — the variable is read after every `fail` path, and `fail` exits (`[flow-planner/result.md S7]`).
- [flow-planner/plan.md S8] The Markdown steps (S1, S2, S4, S5, S8 and the manager's S7 text) have no runtime: their searches, `bash -n`, shellcheck and `plugin validate` show the text is there, not that a live session follows it — UNVERIFIED, as for every prose rule. The plan's `grep -c … → 0` checks print `0` on an untouched tree too, so each is paired with a presence check.
- [flow-master-plan/plan.md L1] UNVERIFIED, the user's live test of approval in plan mode — inline plan. Steps: in a throwaway repo (`d=$(mktemp -d "${TMPDIR:?}/pm.XXXXXX") && cd "$d" && git init -q`, which stops before `git init` when `TMPDIR` is unset or `mktemp` fails; the plan's own `;` form ran `git init` in the current directory then — final review, low, fixed in this record), start `claude` and ask "Call EnterPlanMode, then ExitPlanMode with exactly the plan text `L1 probe`. Write no file."; list `~/.claude/plans` before and after. Settled by: whether ExitPlanMode took the text without a Write, whether a file appeared under `~/.claude/plans` (name, content), what the dialog showed. Each live test ends with `rm -rf "$d"`. The payload claim it settles: the plan-mode dialog can carry the master's approval, and whether ExitPlanMode takes the plan as text (`glab:manager` *Approval in Claude Code's plan mode*, `README.md`; `[flow-master-plan/evidence.md F12]`, `F17`). Not run as of `0cbf5b0`; the manager carries the results into a record (`[flow-master-plan/plan.md FU7]`, open).
- [flow-master-plan/plan.md L2] UNVERIFIED — `plansDirectory`. Steps: write `$d/.claude/settings.local.json` as `{"plansDirectory": "plans-l2"}` by hand, restart `claude`, repeat L1. Settled by: where the plan file landed, and under which name. Settles: where the plan file lands and how `plansDirectory` moves it (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L3] UNVERIFIED — the dialog's three answers. Steps: L1 three times — approve; "No, keep planning" with `change one line`; Ctrl+G, add a line, approve — each time asking the model to quote the ExitPlanMode result. Settled by: whether the result carries the feedback and the edit, and whether Shift+Tab then leaves plan mode. Settles: what "No, keep planning" and a Ctrl+G edit pass on, and leaving plan mode by Shift+Tab (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L4] UNVERIFIED — the permission mode after approval. Steps: approve through each mode the dialog offers. Settled by: the footer's mode afterwards, and whether the session's earlier mode is offered. Settles: that the dialog sets the session's permission mode from then on — the one-line warning the manager gives first (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L5] UNVERIFIED — writes in plan mode. Steps: in plan mode, ask "Write `l5a.txt` here", then "Dispatch a general-purpose subagent to write `l5.txt` here." Settled by: any refusal, and `ls l5*.txt`. Settles: that plan mode blocks the main session's edits and a subagent's — why the manager dispatches no agent in it (`F12`, `F17`; `FU7`).
- [flow-master-plan/plan.md L6] UNVERIFIED — the desktop app. Steps: L1 in the desktop app. Settled by: what the Plan pane shows. Settles: which source the desktop Plan pane shows, UNVERIFIED in `F12`; no payload text rests on it (`FU7`).
- [flow-master-plan/plan.md L7] UNVERIFIED — who has the plan-mode tools. Steps: ask the main session, then a general-purpose subagent, "List your tools whose names contain PlanMode." Settled by: which of the two lists EnterPlanMode and ExitPlanMode. Settles: that no subagent has the plan-mode tools, so only the main session can approve there (`F12`, `F17`; `FU7`).
- [flow-master-plan/evidence.md F12] The plan-mode facts the payload rests on came from a `claude-code-guide` agent reading Claude Code's documentation, relayed by the manager and not re-fetched — inferred; `EnterPlanMode` is in the manager's tool list but not in the docs, and the plan file's name, whether ExitPlanMode takes text, and the desktop Plan pane's source are UNVERIFIED. The planning subagent had neither tool, consistent with L7, not a proof of it. Each point is one of L1–L7 (above).
- [flow-master-plan/evidence.md F16] Inferred from the command text, not run: that `$ARGUMENTS` keeps a `/`, so `/glab:analyze <slug>/<nn>-<name>` reaches the sub-plan's folder through `plan/$ARGUMENTS/` (`commands/analyze.md`, `develop.md`, `integrate.md`); the developer ran no command with a sub-plan slug (`[flow-master-plan/result.md Not done]`).
- [flow-master-plan/evidence.md F11] Inferred from git's pathspec semantics, not run: that this repo's removal checks, `git status --short -uall -- plan/<slug>/` and `git diff --quiet origin/main -- plan/<slug>/`, take the sub-plan folders with them.
- [flow-master-plan/plan.md Milestone] The Markdown has no runtime: the S1–S10 searches, `bash -n`, shellcheck, `PASS 24/24` and `plugin validate` show the text is there, not that a live session follows it — UNVERIFIED, as for every prose rule. The sub-plan cycle, the master hash and Stage 6b have never run; they first run in the next split plan (`[flow-master-plan/plan.md FU9]`). Each `→ 0` search of the plan prints `0` on an untouched tree too, so each is paired with a presence search (`[flow-master-plan/evidence.md F18]`).
- [flow-models-per-role/plan.md I1] UNVERIFIED until the user runs it (it calls models, so it costs; a throwaway `CLAUDE_CONFIG_DIR` is not logged in, `[flow-cheaper-rounds/plan.md D41]`): in the user's own terminal, `claude --plugin-dir ./plugins/glab`, a `glab:committer` dispatch with "run `git status --short`, commit nothing" and no `model` parameter, and a `glab:reviewer` dispatch with `model: haiku` on an empty target; `/tasks` while each runs should name Haiku. Settles: that a live dispatch runs on the frontmatter `model` and that the parameter overrides it — documented (`E1`, `E2`), not shown. Not a precondition of Stage 5; `master.md` *Final check* item 3 and `result.md` *Not done* record it as not run.
- [flow-models-per-role/plan.md E12] UNVERIFIED: that the Agent tool takes `model` ∈ `sonnet|opus|haiku|fable` and `effort` ∈ `low|medium|high|xhigh|max` — read by the planning agent from its own tool definition, which no command prints; the docs give the same alias set (`E1`). The host's `claude --version` was `2.1.310`, above every version floor Rule 5 and Rule 0d name (2.1.211, 2.1.242, 2.1.251, 2.1.257, 2.1.292); `2.1.310` again for this record.
- [flow-models-per-role/plan.md E9] From the docs, not run live: an omitted `tools` inherits every tool available to subagents, and a `tools` list without `Skill` cannot invoke skills (`sub-agents.md:300`, `:629`); `Skill`, `WebFetch` and `WebSearch` are not among the tools subagents lose. The basis of `D5` and `D20`, and of `FU1`.
- [flow-models-per-role/plan.md E6] Proven on a throwaway copy (Claude Code `2.1.310`): `plugin validate --strict` passes `model: sonnett`, and `plugin details` shows no model, so only the model gate catches a typo. Inferred, not verified: that `plugin details` lists agents in an unstable directory read order — the external analyzer's copy listed the two new files last, and the build's run and this record's run both printed `reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer` (`[flow-models-per-role/result.md not-done]`); the gate accepts any order.
- [flow-models-per-role/plan.md E4] From the docs: a subagent on a model other than the main conversation's does not take the session's effort level unless `effort` is passed; levels per model differ, and a model not listed — Haiku 4.5, the `haiku` alias on Bedrock — supports no effort (`model-config.md:620-628`, `:42-50`). Whether Rule 0d's `effort` does anything on a `glab:committer` on such a provider is `FU3`.
- [flow-models-per-role/plan.md Tests] No shell script or test changed; the two suites ran unchanged as gates (`PASS 35/35`, `PASS 24/24`). Coverage as a list: S1–S9 by V1–V9 and the plugin gates; not covered by any case — that a live dispatch runs on the frontmatter model and that the parameter overrides it (I1, the user's), accepted because it calls models; that the prose of each wording adaptation is right is not provable by search (`[flow-models-per-role/result.md unplanned]`). Guards that cannot discriminate: V3 passes on a file that names `CLAUDE.md` for another reason.
- [flow-commands-to-skills/plan.md U1] UNVERIFIED: typing `/glab:<name>` runs the moved stage skill with `$ARGUMENTS` — docs (`F2`, `F3`) and `plugin details` only. The user can check after installing 0.13.0 with `/glab:review`.
- [flow-commands-to-skills/plan.md U2] UNVERIFIED: `glab:manager`'s Skill-tool call on `glab:<name>` loads the plugin skill with its argument — docs (`F2`, `F4`) and `F11` only.
- [flow-commands-to-skills/plan.md U3] UNVERIFIED: an installed copy updated to 0.13.0 drops the old commands and `glab:plan-first` with no duplicate listing (`I1`, inferred from the loading docs: a new version is a new cache directory, and a running session keeps 0.12.0's components until its next start or `/reload-plugins`) — no install may be run from this repo.
- [flow-commands-to-skills/plan.md U4] UNVERIFIED: a plugin agent's `skills:` entry written `glab:security` preloads that plugin skill's full content — the docs name the field for plugin agents but show no plugin-skill name form (`F12`); validation and `plugin details` do not resolve it (`F13`); CLI 2.1.310's code resolves the exact name first (`check-facts.md` F1, a code reading, not a run). After install the user can run `claude --debug`, dispatch one `glab` agent, and search the debug log: `Preloaded skill 'glab:security'` present, `specified in frontmatter was not found` absent. This is the runtime half of `[flow-models-per-role/plan.md FU1]`, closed in the tree (below).
- [flow-commands-to-skills/plan.md U5] UNVERIFIED: the preload works for an agent whose `tools` list lacks `Skill` — documented in the sub-agents `tools` row (`F12`); the run is U4's.
- [flow-commands-to-skills/plan.md U6] UNVERIFIED: `${CLAUDE_PLUGIN_ROOT}` in `glab:bootstrap` step 1 is substituted when the skill loads — documented for "Skill, command, and agent content", not run. Whether an agent can resolve it, so that the planner could read `glab:manager` sections by path, is the open half of `[flow-commands-to-skills/follow-ups.md FU-3]`.
- [flow-commands-to-skills/plan.md U7] UNVERIFIED: the context cost of `I3` — by `plugin details`' on-invoke estimates `glab:security` ~3k, `glab:comments` ~1.3k, `glab:audit` ~0.8k, `glab:plan` ~3.4k tokens per preload on top of each agent's ~0.5–2.9k, and in the manager session each stage skill invoked with a new argument appending its full body again (0.8–7.8 KB), an identical re-invocation a short note, compaction keeping at most 5,000 tokens per skill within 25,000 — from the estimates and the docs; no transcript was measured. It bears on the 300k compact step (*The context rule*).
- [flow-commands-to-skills/plan.md U8] UNVERIFIED: a typed `/glab:plan <task>` substitutes the task into the `$ARGUMENTS` hook, and the planner's preloaded copy renders it empty (`I4`, `check-facts.md` F12, a code reading), worded so that an empty value reads as "the task its dispatch names" — docs (`F2`) and a code reading only.
- [flow-commands-to-skills/result.md fix-round-2] UNVERIFIED: that `glab:plan`'s new `description` stops the model choosing the inline procedure for an untyped build or fix request — needs a live session after install, as U1 and U2.
- [flow-commands-to-skills/plan.md Tests] The Markdown has no runtime: 140 edits and 171 post lines, each shown red with its own edit skipped in 140 throwaway builds and `ok` when built, the gates, A2–A4 and the rename search show the text is there, not that a live session follows it — UNVERIFIED, as for every prose rule. No test file changed (`PASS 35/35`, `PASS 24/24`); `manager-bootstrap.sh` changed only its heredoc text, checked by its round-trip `diff` (`F16`). Not covered by any case: U1, U2, U4, U5, accepted because a runtime check needs an interactive session or a paid `claude -p` run.
- [flow-project-level/index.md D14] Whether a repeated `Skill` call injects the body again — UNVERIFIED, no live session ran it (`[flow-project-level/03-project-manager/plan.md W12]`); `glab:project-manager` *The pipeline* carries the mark.
- [flow-project-level/audit.md How the numbers were taken] Whether a preloaded `skills:` entry puts the whole body in the agent's context, and what a compaction keeps of a loaded skill — UNVERIFIED, neither measured; G5's bytes are a proxy, and tokens (bytes ÷ 3.7) are inferred.
- [flow-project-level/master.md G5] The user's measure, the share of the Ultra plan over 8 hours, is not taken: `get_usage` before and after a live run once 0.15.0 is installed (*Open follow-ups*).
- [flow-project-level/evidence.md E11] `session_id` is unchanged after `/compact` and after a resume in Claude Desktop (one live probe, 2026-11-14: one id across `startup`, `compact`, `resume`); this supersedes `master.md` *Record*'s "not verified" (E9) for Desktop. A CLI `claude --resume` and `--fork-session` stay UNVERIFIED; a fork is inferred to get a new id. `[flow-project-level/02-shared-rules/result.md A6]`: the live `/compact` check of the handoff path is the user's after install.
- [flow-project-level/index.md D25] Whether a live session can be told from a dead one — no: the hook input has no process id and reading another session's transcript is ruled out; step 5 asks instead.
- [flow-project-level/03-project-manager/plan.md Evidence] `proj` was 75302 on 03's base `d6797e0`, against 75074 in 02's `result.md`; the cause is UNVERIFIED, inferred to be an edit after 02's measurement.
- [flow-project-level/03-project-manager/result.md Not done] No live run yet of the new `glab:project-manager`: whether a manager running it drives the pipeline as before is UNVERIFIED.
- [flow-project-level/02-shared-rules/result.md Review round 1 fixes] The hook's closed-stdin guard `{ : 3<&0; }` ran on bash 5.3.9 only; bash 3.2 (macOS) is UNVERIFIED.
- [docs-lifecycle/review.r2.md claims] UNVERIFIED: that a live manager session follows `glab:bootstrap` step 5's removal as written — no live session ran it (review rounds 1 and 2, *Claims*; `[docs-lifecycle/result.md Not done]`: only the greps, `plugin validate --strict` and the gates were run, `PASS 31/31`).
- [docs-lifecycle/plan.md E11] Shown in throwaway repos only, not in a session: `rm -r -- plan/s` on a symlinked `plan/s` removes the link and keeps its target, and with a trailing slash empties the target (`E11`; `[docs-lifecycle/review.r1.md]` *Claims*); `find -newermt "@<epoch>"` works in GNU find and in the shell's `find` function (`bfs`) (since 0.16.2 the listing uses `-newerct`, `[lifecycle-hardening/plan.md D15]`), and `find … -newermt "@"` exits 1 with nothing on stdout; for a repo reached through a symlinked directory, `git rev-parse --show-toplevel` prints the physical path, so the `realpath` test holds (`E13`); `/plan/` ignores `plan/x` even with no `plan/` directory and not `src/plan/x` or `docs/product-rules/briefs/p/plan.r1/x` (`[docs-lifecycle/check.r1.md]` *Checked and holding*).
- [docs-lifecycle/review.r2.md 2] Shown in throwaway repos (review round 2): the new `<record-sha>` picks the slug's own record and a file added after it fails the check, where the old form picked a later change's record of the same spec; an empty sha makes the `ct=` guard exit 128; with the placeholder and its quotes dropped it exits 0 with HEAD's time, which only the separate "not empty" condition catches; a bad `<last>` gives an empty sha with pipe exit 0 (the outcome, "cannot be evaluated", inferred); `$ct` set in one shell and `find` run in another exits 1, failing safe; `git rm -r --cached -- plan/old` untracks a folder, keeps it on disk, and it is then ignored.
- [docs-lifecycle/review.r2.md record-branch] Inferred by review round 2, and measured for this record: the record commit must sit on the branch its *Records* line names, or `<record-sha>` is empty and the folder stays as "cannot be evaluated". This repo commits a record on a branch of its own (`docs-lifecycle-record`), while the line names the change's branch `docs-lifecycle`: before the record's commit, `git log --reverse --format=%h 3ed6746..docs-lifecycle -- <the four record files> | head -1` printed nothing, and the record lands on another branch. A3's older form, `git log -1 --format=%h docs-lifecycle -- <record files>`, printed `ae769ec` (2026-11-18 04:57 +0400), older than every file of `plan/docs-lifecycle/` (05:15–06:02 +0400 by `ls -l`), so its `-newermt` check would fail and ask. Neither form removes `plan/docs-lifecycle` unaided (*Open follow-ups*). **Superseded by `lifecycle-hardening` (`glab` 0.16.2; `[lifecycle-hardening/plan.md D26]`, `D3`):** there is no `<record-sha>` on the branch; the facts command searches `origin/<default>`, so a record committed on any branch is found once it lands, and the record is committed on the change's branch (*Closed follow-ups*).
- [docs-lifecycle/plan.md Not done] Known limits as the plan states them: no migration of plan folders an installing repo has already committed — a tracked folder stays tracked despite `/plan/`, and untracking it is that repo's call (since `D45` the approval names it in one line and never removes it); the removal waits for a session start after the record has landed, so a folder can outlive its merge by one session; a folder whose branch is gone locally and on the remote cannot be checked and stays, and the user removes it (`[docs-lifecycle/review.r1.md 10]`). **Superseded in part by `lifecycle-hardening` (`glab` 0.16.2; `[lifecycle-hardening/plan.md D26]`):** the branch is not needed any more, so such a folder is listed and asked about; the other two limits stand, the removal now also waiting for the user's word.
- [lifecycle-hardening/result.md Not done] UNVERIFIED: that a live manager session follows the new Rule 2 listing and `glab:bootstrap` step 5 as written — no live session ran it; the listing was run as written, placeholders substituted, in throwaway repos only (`result.md` *D26 rework* *Proof*: `plan/land` listed with its record, `plan/unland` not listed, `git diff --quiet` rc=1, `plan/link` not listed, `test -L` rc=0, `plan/newer` listed with `plan/newer/late.md`; `review.r3.md`: the structural checks on a symlinked folder and `plan`, a nested `.git`, a tracked file, and the slugs `a b`, `..`, `x;id`, `-x`, and the named `rm -r -- plan/s1` leaving `../outside/s3/keep` untouched).
- [lifecycle-hardening/review.r3.md Not checked] UNVERIFIED: BSD/macOS `find -newerct "@<epoch>"` and `git log --date=iso-strict` there (`review.r1.md`, `review.r2.md` and `result.md` *D26 rework* name the same gap); only GNU find 4.10 (`/usr/bin/find`; the shell's `find` is a `bfs` wrapper) and git 2.53 were run (`check.r2.md`).
- [lifecycle-hardening/plan.md Not done] UNVERIFIED: a shallow clone's boundary commit matching the pickaxe (inferred only, `check.r1.md`, `check.r2.md`).
- [lifecycle-hardening/plan.md Not done] UNVERIFIED: what author date GitHub's squash and rebase merges set, and whether a forge's squash has `%at` equal to `%ct` (`check.r1.md`, `check.r2.md`, `review.r2.md`, `review.r3.md`: only local CLI squash, rebase and `--no-ff` merges were run). Since `D26` it decides nothing: it only changes which files the listing shows as newer.
- [lifecycle-hardening/plan.md D11] Known limit, stated in Rule 2's reason: a rebase with `--ignore-date` or `--reset-author-date` resets `%at` to its run time, so a file written between the record and that rebase is not listed as newer (proven in `check.r1.md` M4: a default rebase kept `at=01-03`, either option set it to the run day; not re-run). A rewrite of the default branch with `--reset-author-date` is reasoned, not run (`review.r2.md`).
- [lifecycle-hardening/review.r3.md Not checked] Not checked by review round 3: bind mounts inside a plan folder (`rm -r` has no `--one-file-system`; also `review.r1.md`'s mount points), `<record files>` paths with spaces (the facts command leaves them unquoted), the window between the re-check and `rm`, and clock skew between machines (`review.r1.md`, `review.r2.md`).
- [level-guard/result.md Live test (S10)] The project-level edge, as of `632dcb0`: the refusals were shown live from a product repo only (LV1, LV3, LV4: `glab:project-plan` refused, on Linux, Claude Code 2.1.325 `-p`, haiku and opus); a project session refusing a `glab:product-*` skill is shown offline only, by LG2 (`tests/level-guard.test.sh`; LG1 is the product level's). UNVERIFIED: whether Claude makes a Skill call in turn after a typed skill (`[level-guard/follow-ups.md FU-LG5]`), case-insensitive name resolution (FU-LG6), and that a live session follows the new paragraph of *The level boundary* rather than meeting the refusal, as for every prose rule; the rest in `docs/specs/product.md` *Known limits*.
- [remote-store/plan.md Not verified] The project side of a store clone, as of `0634bd5`, is text: that a live planner runs `sync` before it reads a brief, that `glab:project-plan-report` syncs and stops on anything but exit 0 on resuming, and that a project session reads Rule 3's store-push exception as its own permission to let `plan-gate.sh` push the store, is UNVERIFIED — no live session ran a store clone (LP7, FU-RS4, `docs/specs/product.md` *Known limits*). The start prompt's literal "Commit only through /glab:commit" would forbid `plan-gate.sh report`'s store commit (inferred, `[remote-store/plan.md D19]`); `glab:project-plan-report` *Run* states the exception for that reason.

## Open follow-ups

- [sync-local-edits/follow-ups.md 7] `commands/develop.md:67`: a `waived.md` has no tier line, so the waiver path has no next stage — reopened: the routing to `/glab:integrate` was removed by the review's scope cut, because a waiver has no plan and no tier, and the integrator, the integrate scope and the review cap need both. A fix has to give a waiver a tier and an integrator input first. Re-read at `6f8b948`: `commands/develop.md` is gone; `glab:develop` (`skills/develop/SKILL.md:14`) accepts a `waived.md` as a valid start and hands off "as Stage 2 says", and *The pipeline* and Stage 2 of `glab:manager` name no next stage for a waiver — still open. Re-read at `ce1a933`: `skills/develop/SKILL.md:14` still accepts a `waived.md` as a valid start with no next stage named; since `glab` 0.14.0 a waiver that names a brief is stopped at the product-verdict precondition (`:17`) and sent to planning, so no waiver from a brief reaches this gap — still open for every other waiver.
- [sync-local-edits/follow-ups.md 13] `glab:manager` Rule 0c seam note and Stage 1, `glab:plan-first`: "may overrule one" conflicts with Rule 4, where a relayed decision binds and the surface owner has the last word. Suggested: except a line recording another session's decision — open. Re-read at `6f8b948`: Rule 0c no longer holds a seam note; "may overrule one" is now Rule 3's (`skills/manager/SKILL.md:74`, "overrule one by adding a new line with your reason") with a pointer from `glab:plan` Step 2 (`skills/plan/SKILL.md:65`), still with no exception for a line recording another session's decision — still open. Re-read at `ce1a933`: Rule 3 moved, words kept, into `glab:session-rules` (`skills/session-rules/SKILL.md:84`, "overrule one by adding a new line with your reason, never by editing the planner's"), `glab:plan` Step 2 (`skills/plan/SKILL.md:66`) pointing at it; Rule 4, the seam rule, stays in `glab:manager`; no exception for a relayed decision — still open.
- [sync-local-edits/follow-ups.md 14] Stage 1: recording an overrule as a new line leaves steps built on the old choice. Suggested: send the plan back to the planning agent to amend them — open. Re-read at `6f8b948`: Rule 3 (`:74`) still records an overrule as a new line and says nothing of the steps built on the old choice — still open. Re-read at `ce1a933`: Rule 3 is now `glab:session-rules`' (`skills/session-rules/SKILL.md:84`), unchanged in this respect; after a report to product an overrule goes to `after-verdict.md` and may not change a step the product accepted (`glab:manager` Stage 1c) — still open.
- [bug-reviewer-findings/follow-ups.md 18] Cosmetic: `agents/developer.md:15` calls the fallback file "the working agreement" in passing; `commands/commit.md:6` has two dashes in a row — open: re-read at `6838133`, `commit.md:6` still reads `— say so) — the commit format`, and `developer.md:15` still reads `(or CLAUDE.md if the repo has none — say so) — the working agreement`. Re-read at `6f8b948`: the `commands/commit.md` half went with the file (`skills/commit/SKILL.md` has no two dashes in a row); `agents/developer.md:19` still reads `(or CLAUDE.md if the repo has none — say so) — the working agreement` — still open, for that half.
- [bug-reviewer-findings/follow-ups.md 19] Bootstrap's grep hazard ("leading alternation returns zero matches") did not reproduce in three attempts and is worded as observed — open: `bootstrap/SKILL.md:156` (at `09d2787`; `:151` at `6838133`) still reads "observed returning **zero matches with no error**". Re-read at `6f8b948`: `skills/bootstrap/SKILL.md:83` still reads so — still open. Re-read at `db5feae` (`flow-project-level`): `skills/bootstrap/SKILL.md:51` reads "the function has returned **zero matches with no error** for an `-E` pattern beginning with an alternation group" — still open.
- [bug-reviewer-findings/result-review1-prose.md L109] Bootstrap's one-line check could name the host file as a fifth item — open, not asked for: at `6838133` it names four (agreement and constants, gates, stage, what the previous session left). Re-read at `6f8b948`: *The one-line check* (`skills/bootstrap/SKILL.md:127`) still names four — still open.
- [bug-reviewer-findings/result-slice2.md L99] `agents/reviewer.md`'s description (`:3`) still speaks of `AGENTS.md` only, beside the `CLAUDE.md` fallback in its body — open, cosmetic. Re-read at `6f8b948`: `agents/reviewer.md:3` still names `AGENTS.md` only, the fallback at `:18` — still open.
- [feature-docs-specs/follow-ups.md 2] `agents/analyzer.md:56` and `agents/developer.md:98`: the record reads every file of `plan/<slug>/`, untracked ones included, so a scratch file holding host values could reach a committed spec (`glab:security`). Suggested: read `git ls-files -- plan/<slug>/` and name any untracked file in the report instead — open, for one small payload change of its own. Re-read at `6f8b948`: `agents/analyzer.md:90` still takes "every file of `plan/<slug>/`" as the record check's contract, and `agents/developer.md` *The record* (`:119`) points at `glab:plan` *Plan files are working files* — still open. Re-read at `3ed6746` (`docs-lifecycle`): nothing under `plan/` is tracked any more, so the suggested fix, reading `git ls-files -- plan/<slug>/`, would list nothing; `agents/project-analyzer.md:90` still takes "every file of `plan/<slug>/`" as the contract, and the specs are the only lasting copy — still open, and its fix has to be another one.
- [feature-docs-specs/follow-ups.md 7] Commits rule: `fed95f9` holds two logical changes of the payload, the Stage 8 record and the re-pointed citations, committed as one under `0.5.0` — open, an advisory of review round 3/3; nothing to undo now, a reminder for the next payload change.
- [feature-docs-specs/result-SM.md 3] Facts the specs state as of their record that move with their owners and that no gate ties to the specs (`[feature-docs-specs/plan.md D10]` accepts this): `PASS 35/35` and `PASS 49/49`, the allowlist and DeepSeek's end date, 2026-10-31, the `glab` version — open: each record has to re-read them; re-read by `feature-codex-agent`'s record: `PASS 71/71` at `9108ac7`, `glab` `0.6.0`, the allowlist and its end date unchanged; by `feature-external-developer`'s: `PASS 84/84` at `33a28df`, `glab` `0.7.0`, the allowlist unchanged; by `fix-external-agent-claims`'s: `PASS 86/86` at `3965622`, `glab` `0.7.1`, the allowlist unchanged; by `subagent-effort`'s: `PASS 35/35` and `PASS 86/86` at `abda43a`, `glab` `0.7.2`, the allowlist unchanged (the change touched neither the script nor its tests); by `remove-external-agents`'s: `PASS 35/35` at `467b7c4` (run for this record), `glab` `0.8.0`, and `PASS 86/86`, the allowlist and DeepSeek's end date gone with the script and its test, so what is left to re-read is the `memory-sync` count and the versions. Re-read by `flow-commands-to-skills`' record: `PASS 35/35` and `PASS 24/24` at `6f8b948` (run for this record), `glab` `0.13.0`, `memory-sync` `0.1.0`. Re-read by `flow-product-level`'s record: `PASS 35/35`, `PASS 24/24` and the three new suites `PASS 42/42`, `PASS 13/13`, `PASS 17/17` at `ce1a933` (run for this record), `glab` `0.14.0`, `memory-sync` `0.1.0` — five counts to re-read now. Re-read by `flow-gate-hardening`'s record: `PASS 51/51` at `2724086` (not run for this record; the manager ran it three times in a row on the shipped tree before the commit), `glab` `0.14.1`, `memory-sync` `0.1.0`, the other four counts unchanged.
- [subagent-effort/plan.md F1] `glab:manager` *When subagent dispatch is not available* says how a stage session is started on the recorded model but not at the recorded effort; whether `claude` takes an effort at start was not checked — open. Re-read at `6f8b948`: *When subagent dispatch is not available* (`skills/manager/SKILL.md:217`) still names the model a stage session starts on, not the effort — still open. Re-read at `ce1a933`: the section stays in `glab:manager` (`skills/manager/SKILL.md:121`), unchanged in this respect — still open. Re-read at `db5feae` (`flow-project-level`): the section is now `skills/project-manager/references/without-subagents.md` (F19), which names no effort either — still open.
- [subagent-effort/record.md round-2-ultra] Review round 2 advisory, carried from the manager's Stage 8 dispatch record (no review file is in the folder): `skills/manager/SKILL.md` Rule 0d (`:71` at `abda43a`) has the manager ask which level the user means when they name `ultra` for an Agent tool dispatch, but does not say how far that answer reaches — for that dispatch only, or for the session; Codex still takes `ultra` — open. Re-read at `467b7c4`: Rule 0d (`:71`) still does not say how far the answer reaches; Rule 0d's Codex sentence is gone with Rule 6, so "Codex still takes `ultra`" is history — still open. Re-read at `6f8b948`: Rule 0d (`:32`) still ends "say so and ask which the user means", with no reach — still open. Re-read at `ce1a933`: Rule 0d moved, words kept, into `glab:session-rules` (`skills/session-rules/SKILL.md:42`), still "say so and ask which the user means" with no reach — still open.
- [subagent-effort/record.md round-2-pipeline-default] Review round 2 advisory, from the same dispatch record: *The pipeline*'s handoff sentence (`skills/manager/SKILL.md:189` at `abda43a`) says the effort is "the level you passed" and does not name `effort default`, which Rule 0d (`:67`) has the handoff line carry when the Agent tool rejects or does not offer `effort` — open. Re-read at `467b7c4`: the sentence (`:173`) now ends "The effort is the level you passed." and still does not name `effort default` — still open. Re-read at `6f8b948`: *The pipeline*'s paragraph (`:145`) still ends "The effort is the level you passed." — still open. Re-read at `ce1a933`: the handoff sentence moved into `glab:session-rules` *The handoff line* (`skills/session-rules/SKILL.md:136`), which still says the effort is the level passed and does not name `effort default`, while Rule 0d (`:38`) still has the line carry it — still open.
- [flow-cheaper-rounds/plan.md FU3] The user-level copies under `~/.claude` — the user ports them (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU4] The "cleanup glob deleted a reviewer report" incident (out of scope by the brief) — open.
- [flow-cheaper-rounds/plan.md FU8] Snapshot limits: a nested repository is recorded as a gitlink with a warning and a large untracked directory that is not ignored is hashed in full (not tested); a repository with no commit yet gets no tree id (`git read-tree HEAD` fails), so its rounds run whole; a file force-added to the index but not committed that matches `.gitignore` is still missed — open.
- [flow-cheaper-rounds/plan.md FU11] Whether the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 — UNVERIFIED, open. An older CLI still gets the `prompt` line, and the handoff line then uses it (`D38`).
- [flow-cheaper-rounds/plan.md FU12] `claude plugin details` labels every hook "harness-only — no model context cost", which is not true of one that returns `additionalContext`: the CLI's wording, to report upstream if anyone wants to — open.
- [flow-cheaper-rounds/plan.md FU13] A `PreToolUse` hook on `Agent` that refuses (`permissionDecision: "deny"`) a dispatch missing `effort` or the `AGENTS.md` instruction — the coordinator's follow-up, not planned; whether the Agent `tool_input` carries `effort` is UNVERIFIED — open. The same item as `[flow-cheaper-rounds/follow-ups.md FUd]`.
- [flow-cheaper-rounds/plan.md FU14] An assistant entry longer than the 8 MiB window is not seen (`D32`): an older call's figure, or silence. Widen the window or read backwards if it is ever seen — open.
- [flow-cheaper-rounds/plan.md FU15] Whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks — UNVERIFIED, open.
- [flow-cheaper-rounds/plan.md FU16] The hooks the user did not choose — `PostToolBatch`, `SubagentStop` — recorded by D28 and D29, not planned — open.
- [flow-cheaper-rounds/plan.md FU17] Whether the desktop app shows a `Stop` hook's `systemMessage` as the terminal does (I1 shows the terminal only) — UNVERIFIED, open.
- [flow-cheaper-rounds/plan.md FU18] Which plugin's `Stop` hook ended `cancelled`, exit 1, in I1a, and whether an installed `memory-sync` sync is cut off whenever a `claude -p` run exits — UNVERIFIED, open; a question for the `memory-sync` plugin, not acted on here (`docs/specs/memory-sync.md`).
- [flow-cheaper-rounds/follow-ups.md FUa] The *One fact* entries "the manual model rule" and "the session effort" in `AGENTS.md` both name the handoff-line format (`plugins/glab/skills/manager/SKILL.md` Rule 5 and *The pipeline*, `commands/develop.md`, `review.md`, `ship.md`). The line now ends `· context <n>k` and Rule 5's example reads `round 1/2`, but those commands do not show the line's full form, so nothing disagrees today, while the two entries do not list the context field. Decide whether the context field joins them — open. Re-read at `517b7b6`: "the manual model rule" is now "the model per role", naming `model <alias>` on every agent stage's handoff line and four more commands (`docs/specs/marketplace.md`); neither it nor "the session effort" lists the context field — still open. Re-read at `6f8b948`: both entries lost their command files (`docs/specs/marketplace.md`) — "the model per role" now names Rule 5 and its handoff-line format, the seven agents, `README.md` and the model gate; "the session effort" Rules 0d and 5 and *The pipeline*, the one pointer line of `manager-bootstrap.sh` and `README.md` — and neither lists the context field — still open. Re-read at `ce1a933`: both entries now name `glab:session-rules` — "the model per role" its Rule 5 and *The handoff line*, the nine agents, `README.md` and the model gate; "the session effort" its Rules 0d and 5 and *The handoff line*, the hook's pointer line and `README.md` — and neither lists the context field, which the context-hook entry ties to `glab:session-rules` — still open.
- [flow-cheaper-rounds/follow-ups.md FUb] Payload text cites a plan file: `plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh` and `plugins/glab/skills/manager/SKILL.md` cite `[flow-cheaper-rounds/plan.md F23]` (and the script `[flow-cheaper-rounds review round 1]`). The plan folder is removed after the record and is never part of an installed plugin, so an installer cannot follow the citation; it stays readable only through `git show <sha>:…` (cf. `[feature-docs-specs/plan.md D8]`: payload cites the spec, never a `plan/` path). Decide whether payload cites the area spec instead — open (review round 1, advisory). Re-read at `db5feae` (`flow-project-level`): `glab:project-manager` no longer cites a plan file; `context-size.sh:51`, `:159` and `tests/context-size.test.sh:210` still do — still open.
- [flow-cheaper-rounds/follow-ups.md FUd] The manager's: a `PreToolUse` hook on `Agent` that refuses a dispatch missing `effort` or the `AGENTS.md` instruction (`[flow-cheaper-rounds/plan.md FU13]`), so Rule 0d and Rule 0c are enforced rather than remembered — open.
- [flow-planner/plan.md FU3] A size warning for a subagent's own context: needs proof that hooks fire inside a subagent, and with which `transcript_path` — open, UNVERIFIED.
- [flow-planner/plan.md FU4] Whether a settings file's `env` block reaches a plugin hook, so `GLAB_COMPACT_AT` could be set there — open, UNVERIFIED.
- [flow-planner/plan.md FU5] The manager's own gate runs could use the developer's log template (*Keep your context small*) — open.
- [flow-planner/plan.md FU8] Which other names the Write rule refuses (`summary.md`, `report.md`) is untested (`[flow-planner/evidence.md F8]`) — open.
- [flow-planner/follow-ups.md FD2] `plugins/glab/scripts/context-size.sh` l. 37: the contract comment's `GLAB_COMPACT_AT` sentence sits as its own unwrapped line between two wrapped ones, so the plan's searched phrase stays on one line; no reflow was done, since no step named one — open, cosmetic.
- [flow-master-plan/plan.md FU7] L1–L7 are unverified until the user runs them; if ExitPlanMode needs a file and `plansDirectory` stays default, plan-mode approval stays unused — open (*Known limits*, L1–L7).
- [flow-master-plan/plan.md FU9] The first split plan first runs the sub-plan cycle, the hash and Stage 6b; its record says what they cost and caught — open.
- [flow-master-plan/follow-ups.md DEV1] `plugins/glab/skills/manager/SKILL.md` Stage 8 dispatch bullet reads "from the folder's files, sub-plan folders included and the audit file" with no comma after "included", unlike `developer.md`'s "sub-plan folders included,"; built as the plan wrote it — open, a one-character wording fix. Re-read at `6f8b948`: Stage 8's dispatch bullet (`:372`) still reads "sub-plan folders included and the audit file" — still open. Re-read at `ce1a933`: the bullet is now `skills/manager/SKILL.md:294`, unchanged — still open. Re-read at `db5feae` (`flow-project-level`): the bullet is now `skills/project-record/SKILL.md:11`, unchanged — still open.
- [flow-master-plan/follow-ups.md DEV2] `glab:manager` *Pick the tier* table: the row `Approval, after 1b` sits above the `1b` row, and `6b Final check` after `5 Review` and before `6–7 Commit, push`, as the plan placed them; whether the row order should follow the stage order — open. Re-read at `6f8b948`: the table is unchanged — still open. Re-read at `db5feae` (`flow-project-level`): the table is `glab:project-manager` *Pick the tier*, its row order unchanged — still open.
- [flow-models-per-role/plan.md FU2] Mapping agents and other definition-less agents run on the main conversation's model (`D19`); a mapping-agent definition with a table model is the user's call — open. Re-read at `6f8b948`: since Rule 0c (`glab` 0.13.0) such an agent gets `glab:security`, and `glab:audit` when it produces findings, named in its dispatch, its one channel; its model is unchanged — still open.
- [flow-models-per-role/plan.md FU3] A `glab:committer` on `haiku` where the provider's Haiku takes no effort (`E4`): Rule 0d's `effort` then does nothing; not checked live — open.
- [flow-commands-to-skills/follow-ups.md FU-1] `plugins/glab/skills/security/SKILL.md` has two blank lines before `# Stopping is a correct outcome` (`:189-190` after the change, `:185-186` at `5a72155`): already there, named by no step, so left alone — open, cosmetic.
- [flow-project-level/index.md D13] F27: the Go test policy in `plugins/glab/agents/project-developer.md` (generated mocks) is the user's, left as it is (`[flow-project-level/03-project-manager/plan.md W19]`) — open.
- [flow-project-level/index.md D11] F11: dropping the pre-0.10.0 and pre-0.11.0 compatibility clauses for good (`[flow-project-level/03-project-manager/plan.md W6]`) — open.
- [flow-project-level/index.md D20] `glab:security` Part 2 and `glab:push`'s rationale as further levers on the bytes; neither is in the user's words and G5's caps hold without them — open.
- [flow-project-level/master.md later-1] `omitClaudeMd: true` on the `glab` agents, and [later-2] a hook-based skill loader: "in the end when we will finish all agents" (`master.md` *Out of scope*; the untracked `plan/manager-flow-notes.md` *Later: agent and session context cleanup*) — not opened again here: they are the user's parked `[manager-flow-notes.md later-1]` and `later-2`, held open in `docs/specs/product.md` with this timing.
- [flow-project-level/02-shared-rules/plan.md W8] Rationale that left the payload: `glab:session-rules` Rule 5's *why these models* (quoted under *How it works now*) and the precedence detail of its `:119` (this file keeps the order) — open, whether either returns. 01 moved no text (D2); 03 moved none out (`[flow-project-level/03-project-manager/plan.md W13]`) but carried two rationale lines only as a pointer or not at all (FU7, below).
- [flow-project-level/03-project-manager/plan.md W10] A no-subagent note for the product level: `glab:product-manager` has none — open.
- [flow-project-level/master.md G5] Measure the budget with `get_usage` before and after a live run on the punching-bag repo, once the user has installed 0.15.0 — open, the user's.
- [flow-project-level/03-project-manager/follow-ups.md FU2] `README.md:281` still reads "where Stage 1c puts every record line"; the rule now lives in `glab:project-plan-report` *The freeze* — open.
- [flow-project-level/03-project-manager/follow-ups.md FU3] `plugins/glab/skills/commit/SKILL.md:7` still names "the record's commit (Stage 8)", whose detail is now `glab:project-record`'s — open.
- [flow-project-level/03-project-manager/follow-ups.md FU4] `/usr/bin/grep -cE 'Stage (1b|1c|2|3|4|5|6b|8)\b' README.md` prints `2` (`:35`, `:281`) — open.
- [flow-project-level/03-project-manager/follow-ups.md FU2 (second)] The file holds FU2–FU4 twice; this entry and the next two are its second FU2–FU4. `glab:project-manager:36` states a round-cap value ("the amendment after round 2"); point it at `glab:session-rules` *Round caps* or list the file in the `AGENTS.md` round-caps entry — open.
- [flow-project-level/03-project-manager/follow-ups.md FU3 (second)] `agents/project-developer.md:115`, `skills/project-develop/SKILL.md:17` and `skills/project-plan-report/SKILL.md:11` state registered facts and are not in their *One fact* entry — open.
- [flow-project-level/03-project-manager/follow-ups.md FU4 (second)] Two rationale lines of the old manager were not carried: `:175-177` "by far the cheaper of the two places" (a pointer to `glab:project-plan-analyzer` *The plan check*) and `:135` "not a breach of Rule 2 or Rule 5" (cut) — open, review round 1 advisories.
- [lifecycle-hardening/review.r3.md 1] (low) `plugins/glab/skills/session-rules/SKILL.md:86`: the landed check, `git diff --quiet origin/<default> -- <record files>`, exits 0 whenever the checked-out branch has no record either — on `main` with the record on an unmerged branch (review r3's s7: `git diff --quiet` rc=0, then the facts command rc=1) — so the folder falls to "cannot be evaluated" and is reported in one line at every session start instead of "not landed, without a word". Never listed, so not unsafe. Suggested: when the diff passes but `$c` is empty, report it as not landed, or make the facts command's `-S` on `origin/<default>` the landed test — open.
- [lifecycle-hardening/review.r3.md 2] (low) `session-rules/SKILL.md:87`: `-newerct "@<epoch>"` has one-second resolution, so a plan file written in the same second as the record shows as newer (review r3's s6/a). It only lengthens the list. Suggested: one clause saying so — open.
- [lifecycle-hardening/review.r3.md 3] (low) `session-rules/SKILL.md:83`: `find plan/<slug> -name .git` "prints nothing" has no exit-code test; if `find` fails (an unreadable subdirectory), stdout is empty and the check passes, though `rm` would then fail on that directory. Suggested: add "and exits 0", as the old `-newermt` clause had — open.
- [lifecycle-hardening/review.r3.md 4] (low) `session-rules/SKILL.md:89`–`94`: "the first that applies" puts "not landed" and "cannot be evaluated" before the symlink, `realpath` and `.git` failures, so a symlinked folder whose record has not landed is never named and never asked about. Safe: it is never listed. Suggested: none, or move the structural outcome before "not landed" — open.
- [lifecycle-hardening/review.r3.md 5] (low) `session-rules/SKILL.md:79`: the user's "Ask once per folder" could mean once ever; the rule re-asks about a kept folder at every session start and stops asking only within one session, and `docs/features/docs-lifecycle.md` says the same, so the files agree. The reading was not confirmed with the user (review r3 could not check the chat). Suggested: confirm it with the user — open, the user's.
- [lifecycle-hardening/review.r3.md 6] `glab:product-manager:60` omits "on the user's word" — open, in `docs/specs/product.md`.
- [level-guard/follow-ups.md FU-LG1] The boundary's agent half, an `Agent` matcher refusing a `subagent_type` of another level — open, in `docs/specs/product.md`.
- [level-guard/follow-ups.md FU-LG5] A skill a typed other-level skill calls in turn is judged; whether Claude makes such a call is UNVERIFIED — open, in `docs/specs/product.md`.
- [remote-store/follow-ups.md FU-RS2] The user's standing rule — agents commit, push, open PRs and merge below `main` on their own; the merge to `main` and release merges stay the user's — across `glab:session-rules`, `glab:push` and the start prompt (`[remote-store/plan.md D19]`): `remote-store` exempts only the store's commits and pushes — open.
- [remote-store/follow-ups.md FU-RS11] `glab:project-manager` `SKILL.md:68` and `glab:session-rules` `SKILL.md:138` say "push waits for the user" without pointing at Rule 3's store-push exception; safe direction; blocked by the session-start caps, with `[level-guard/follow-ups.md FU-LG4]` (`[remote-store/review-r3.md]` *Follow-ups*) — open.

## Closed follow-ups

- [sync-local-edits/follow-ups.md 1] Rule 4 named no channel for settling a seam, and a relayed decision bound with no stated source — fixed (D1; `manager/SKILL.md` Rule 4).
- [sync-local-edits/follow-ups.md 2] Nothing said what a `plan.md` with no tier line is — fixed (D2): full tier.
- [sync-local-edits/follow-ups.md 3] Rule 3 credited `glab:security` with confirmations it does not state — fixed, then corrected after review (D3): the stop list and *Destructive operations are proven* stay `glab:security`'s, confirmation before every destructive action and push is the manager's own rule.
- [sync-local-edits/follow-ups.md 4] *One fact*: bootstrap had been dropped from the round-cap list; the ask-conditions were not a known case — fixed (D4; `AGENTS.md` *One fact*).
- [sync-local-edits/follow-ups.md 5] `commands/integrate.md:10` was not updated for normal tier — fixed (D5).
- [sync-local-edits/follow-ups.md 6] `develop.md:61` re-ran `/glab:analyze` after an amendment at normal tier — fixed (D6).
- [sync-local-edits/follow-ups.md 8] `analyze.md:18` "If I do amend it" contradicted its line 15 — fixed (D8).
- [sync-local-edits/follow-ups.md 9] Manager and plan-first disagreed on who decides a planning choice — fixed (D9).
- [sync-local-edits/follow-ups.md 11] The 1b row's "Leaves on" ignored normal tier's one amendment — fixed (D11).
- [sync-local-edits/follow-ups.md 12] Wording in bootstrap, `review.md` and the hook was narrower than the manager's — fixed (D12).
- [sync-local-edits/follow-ups.md 10] The spec entry had no stage, owner or location; "checked by independent readers" was undefined; plan-folder removal depended on a repo rule that may not exist (reopened by the scope cut of 2026-10-16) — closed by `feature-docs-specs`: Stage 8 names its stage, owner, place and readers (`glab:developer` writes the area spec under `docs/specs/`, `glab:analyzer` checks it at every tier, one `glab:reviewer` pass at full tier), and removal is the repo's own `AGENTS.md` decision.
- [feature-docs-specs/follow-ups.md 9] The specs described the lifecycle as of `6838133`; the record had also to update the pipeline bullet and the Rule 5 duration sentence of this file, besides what `plan.md` X1 listed — closed: done in this record (*How it works now*, the pipeline and the model rule).
- [feature-docs-specs/follow-ups.md 10] A stray `__pycache__/fixes-r2.cpython-314.pyc` in the plan folder — closed: removed by the manager before commit; `git ls-tree -r --name-only 09d2787 -- plan/feature-docs-specs/` lists no `__pycache__`.
- [feature-docs-specs/result-SM.md 1] The record had to move every mention of `[sync-local-edits/follow-ups.md 10]`, not one bullet — closed: *How it works now*, the D10 line and *Known limits* now state Stage 8; its *Records* section line keeps the history of the reopening.
- [feature-docs-specs/result-SM.md 2] `[bug-reviewer-findings/follow-ups.md 18]`'s status differed from that change's `findings.md` — closed: re-read at `09d2787`, `agents/developer.md:15` and `commands/commit.md:6` still read as the item quotes, so the spec's status (open) is the tree's.
- [feature-codex-agent/record.md effort-line] Raised by this record (Stage 8, review of the record): `glab:manager` Rule 6 gives the `- effort: codex <level> …, for the session` line for a general Codex agent but not where it goes; D30's placement — under `## Decisions` of the plan in progress, or the conversation only with no plan — is in `plan.md` alone at `30f2c80`. Suggested: one clause in Rule 6 — closed by `subagent-effort` (`abda43a`): the `- effort: codex` line is gone (`command grep -c -F -- '- effort: codex'` → `0` in `skills/manager/SKILL.md` and `skills/external-agents/SKILL.md`, S3 and S4 of its `result.md`); Rule 6 (`skills/manager/SKILL.md:165`) records Codex's effort "as Rule 0d says", and Rule 0d (`:69`) places its `- effort:` line "under `## Decisions` in the current task's `plan/{slug}/plan.md`, or in this conversation when there is no plan".
- [flow-cheaper-rounds/plan.md FU7] Stage 5 did not say how a review round after the first learns what changed since the last one (`reviewer.md` had the reviewer ask, `ship.md` had the caller scope it) — closed in Stage 1b round 1 by `D51`: Stage 5, `agents/reviewer.md` and `commands/ship.md` now give the new reviewer the previous findings and the range of the fix.
- [flow-cheaper-rounds/plan.md FU9] Whether `CLAUDE_CODE_SESSION_ID` and the transcript layout hold on other hosts and versions, and whose id a subagent sees — closed as moot in round 2: nothing uses the variable since `D30`; `grep -rl CLAUDE_CODE_SESSION_ID plugins README.md AGENTS.md tests` prints no line (the plan's V10, run by the developer).
- [flow-cheaper-rounds/plan.md FU10] Whether the transcript is flushed before `PostToolUse` and `Stop` run, and how far the figure lags — closed by I1 (`F23`): at `PostToolUse` on `Agent` the calling call is already written; at `Stop` the turn's last call is not, and was there 1 s later; `D61`–`D62` answer it. How far the lag can grow elsewhere is a known limit (above), not a follow-up.
- [sync-local-edits/follow-ups.md 18] `AGENTS.md` *One fact*: the analysis round caps were stated in the manager and bootstrap but not listed — closed by `flow-cheaper-rounds` (`2a1e919`, `D25`): the entry "the round caps" lists all three stages and their five files.
- [sync-local-edits/follow-ups.md 19] After a normal-tier review fix the develop handoff re-ran integrate and review while the manager said the gates were the only check on that fix, and `/glab:ship` had no normal-tier exception — closed by `flow-cheaper-rounds` (`2a1e919`) as the plan's `F11` reads it: the cap is now one at every tier, so a normal-tier review fix gets a round 2, and `/glab:ship` states the same cap with no tier exception. The record did not re-read the line numbers the item cites (`commands/develop.md:67`, `commands/ship.md:32`).

- [flow-cheaper-rounds/plan.md FU2] Splitting the implementation steps (5–7) out of `glab:plan-first` — closed by `flow-planner` (`2912002`, `glab` 0.10.0; `[flow-planner/plan.md FU2]`, S1): Steps 5–7 and the three implementation-only repo rules are in `plugins/glab/skills/plan-first/implement.md`, numbers kept.
- [flow-cheaper-rounds/plan.md FU6] `glab:plan-first` prescribed `findings.md` at full tier, but a subagent planner's Write is refused that name — closed by `flow-planner` (`2912002`; `[flow-planner/plan.md FU6]`, S1, S2, S4, S5): the file is `evidence.md`, which a subagent's Write accepts (`[flow-planner/evidence.md F8]`), and every reader still accepts `findings.md` in an older folder (*Incidents*, the fourth and fifth refusal).
- [flow-planner/plan.md FU2] `[flow-cheaper-rounds/plan.md FU2]`, Steps 5–7 out of `glab:plan-first` — closed by S1 (above).
- [flow-planner/plan.md FU6] `[flow-cheaper-rounds/plan.md FU6]`, a subagent cannot write `findings.md` — closed by `evidence.md` (S1, S2, S4, S5; `[flow-planner/evidence.md F8]`).
- [flow-planner/follow-ups.md FD1] `context-size.sh` l. 37: the contract sentence the plan prescribed, "the run goes on with the default and still prints its JSON", was loose for `stop` below a step, where nothing prints — closed in review fix round 1 on the manager's instruction: it reads "prints on stdout what it would print with the variable unset - one JSON object or nothing"; no other file carried the sentence (`[flow-planner/result.md FD1]`).
- [flow-cheaper-rounds/plan.md FU5] `agents/analyzer.md` has no plan-check mode: `BUILDABLE` / `NOT BUILDABLE` appear only in `skills/manager/SKILL.md`, and its Steps 2–3 are written for an implementation — closed by `flow-master-plan` (`0cbf5b0`, `glab` 0.11.0; `[flow-master-plan/plan.md D35]`, S4): `agents/analyzer.md` has *The plan check — `glab:manager` Stage 1b*, skips Step 2 there, and lists `BUILDABLE` and `NOT BUILDABLE` among its verdicts.
- [flow-planner/record.md review-waiver-implement] Review advisory, carried from the manager's Stage 8 dispatch (no review file is in the folder), for the later plan `flow-master-plan`: `glab:plan-first`'s waiver paragraph (`plugins/glab/skills/plan-first/SKILL.md:122` at `2912002`) says "Then implement, from `implement.md`", but `implement.md` (l. 3) says to start Steps 5–7 "only once the plan is verified (Step 4) and, at full tier, approved" — a condition a waived task, which has no plan, cannot meet — closed by `flow-master-plan` (`0cbf5b0`; `[flow-master-plan/plan.md D47]`, S1, S9): `implement.md` l. 3 now starts Steps 5–7 "once the plan is verified and approved (`glab:plan-first` Step 4), or once `plan/{slug}/waived.md` records a waiver (*User Override* in `SKILL.md`), which stands in for both", and the waiver paragraph says the waiver "stands in for the verified, approved plan it asks for".
- [flow-planner/record.md review-t19-comment] Review advisory, from the same dispatch, for `flow-master-plan`: the T19 comment in `tests/context-size.test.sh` (l. 335 at `2912002`) reads "judged over every stop run above, T20's and T21's included", but T24's `stop` run now feeds `stopouts` too (review fix round 1, `[flow-planner/result.md R4]`), and T23's runs through `stop_case` — closed by `flow-master-plan` (`0cbf5b0`; `[flow-master-plan/plan.md D47]`, S10): the comment (l. 335) reads "judged over every stop run above: T18's, T20's, T21's and T23's through stop_case, and T24's own"; one line out, one in, `PASS 24/24`.
- [flow-cheaper-rounds/plan.md FU1] A dedicated `glab:planner` agent (out of scope by the brief) — open; carried since `glab` 0.10.0 as `[flow-planner/plan.md FU1]`, into `flow-models-per-role`. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0; `[flow-models-per-role/plan.md D4]`):** `plugins/glab/agents/planner.md` exists, `model: opus`, and `/glab:plan` dispatches it.
- [flow-planner/plan.md FU1] A `glab:planner` agent and the analyzer's two kinds — into `flow-models-per-role` (`[flow-planner/plan.md D9]`, `D21`; carries `[flow-cheaper-rounds/plan.md FU1]`) — open. Re-read at `0cbf5b0`: `[flow-master-plan/plan.md D36]` keeps one analyzer with every kind of check and leaves the split to `flow-models-per-role` — still open. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0; `[flow-models-per-role/plan.md D4]`, `D6`):** `glab:planner` and the two analyzer kinds, `glab:plan-analyzer` and `glab:analyzer`; `Agents (7)`.
- [flow-cheaper-rounds/follow-ups.md FUc] **The user's, 2026-10-20:** the next plan `flow-models-per-role` — a model per role (planner and plan check Opus; conformance and record check Sonnet; developer, reviewer, integrator Sonnet; committer Haiku) and two kinds of analyzer; it extends `glab:manager` Rule 5 beyond the developer and reviewer — open, not planned. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0):** the table ships as each agent's frontmatter `model` (`[flow-models-per-role/plan.md D2]`, the user's "Default", `[flow-models-per-role/questions.md Q1]`), the analyzer is two kinds (`D6`), and Rule 5 covers every role (`D9`); the model gate prints the seven lines.
- [feature-docs-specs/follow-ups.md 5] `skills/manager/SKILL.md:127` against Stage 8's "not in `plan.md`": a model the user names for the record's developer has nowhere to be recorded. Suggested: one clause in Rule 5 — for Stage 8 the instruction lives in the conversation only, as for a `/glab:review` with no plan — open. **Closed by `flow-models-per-role` (`09d5664`, `glab` 0.12.0; `[flow-models-per-role/plan.md D12]`):** Rule 5's *Record it before the next dispatch* now reads "A `/glab:review` or `/glab:ship` with no plan behind it, and the Stage 8 record's agents, have nowhere to record it: the instruction lives in this conversation only".
- [flow-models-per-role/plan.md FU4] `docs/specs/marketplace.md` and `workflow.md` restated `Agents (5)` and Rule 5 as of their records — closed by this record (`master.md` *Record*): both specs now state `Agents (7)` and the reworded Rule 5 as of `517b7b6`.
- [flow-models-per-role/result.md FUa] `manager/SKILL.md` Rule 5, *Record it*, still gave `"use sonnet for the developer"` as its example `- model:` line, an override that changes nothing once the developer's default is `sonnet` (found while building, out of scope of S5 (f)) — closed in review round 1 by R2.7: the example is now `- model: glab:reviewer opus, … "use opus for the reviewer"`.
- [sync-local-edits/follow-ups.md 15] Rule 3 still reads as "the manager writes the decision line", while Stage 1 says the planner writes it. Suggested: one clause, during planning the planner writes it and the manager reviews it — open. **Closed by `flow-commands-to-skills` (`6f8b948`, `glab` 0.13.0):** Rule 3 (`skills/manager/SKILL.md:74`) now reads, after "write it as one line": "A planner's `## Decisions` line is reviewed the same way: overrule one by adding a new line with your reason, never by editing the planner's" — the planner writes it, the manager reviews it, the clause the item suggested.
- [sync-local-edits/follow-ups.md 16] `commands/integrate.md:10`: the integrator agent is never told the normal-tier scope (milestone test only). Suggested: "Say which in the dispatch." — open. **Closed by `flow-commands-to-skills` (`6f8b948`; `[flow-commands-to-skills/plan.md]` B15, IN1, IN2, M17):** `commands/integrate.md` is gone; `agents/integrator.md` Step 1 (`:15`) says "At normal tier run the test that proves the plan's milestone", and Stage 4 says "at normal tier only the milestone test, as its Step 1 says" — the integrator reads the tier line itself, so no dispatch has to say it (Rule 0c).
- [sync-local-edits/follow-ups.md 17] `scripts/manager-bootstrap.sh:17`: "-> commit -> push -> record at full tier" (as at `09d2787`; it read "-> push at full tier" when raised) can read as "only at full tier", and Stage 1b is missing. Suggested: "At full tier work moves through plan -> analyze -> develop -> …" — open. Re-read at `0cbf5b0`: the hook text now reads "plan -> develop -> analyze -> integrate -> review -> commit -> final check -> push -> record, as far as the tier runs them" (`[flow-master-plan/plan.md S7]`), so the "only at full tier" reading is gone; Stage 1b is still not named — still open, for that half. **Closed by `flow-commands-to-skills` (`6f8b948`; H1, R2-5):** the session-start text lists no stages at all: "Each stage of its pipeline (`glab:manager` -> *The pipeline*, as far as *Pick the tier* runs it) is dispatched to its own agent", so neither the "only at full tier" reading nor a missing Stage 1b is left.
- [bug-reviewer-findings/follow-ups.md 16] `reviewer.md` and `integrator.md` fell back to "the scratchpad" while `CLAUDE.md` and bootstrap said "`$TMPDIR` if set, scratchpad otherwise" — changed since, not shown fixed: both now say "the temp directory the dispatch message names (the scratchpad only if it names none)" (`reviewer.md:73`, `integrator.md:39` at `6838133`); whether that agrees with bootstrap's wording was not re-checked. **Closed by `flow-commands-to-skills` (`6f8b948`; B10, RV5, IN5):** both agents now use "the temp directory the dispatch names, never `/tmp`" (`agents/reviewer.md:76`, `agents/integrator.md:43`) with no scratchpad fallback of their own; the dispatch always carries the directory (Rule 0c), and the session's fallback — `$TMPDIR`, then the scratchpad — is stated once, in the session-start text's point 4.
- [subagent-effort/result.md finding-4] Review round 1's finding 4: `commands/commit.md`, `commands/analyze.md` and `commands/integrate.md` dispatch an agent and do not mention the effort; accepted as-is under `[subagent-effort/plan.md D4]` (commands change only where they list Agent tool parameters), not fixed — open. Re-read at `517b7b6`: since `09d5664` the three say their agent is "dispatched as `glab:manager` Rules 0d and 5 say" (`[flow-models-per-role/result.md R2.10]`), a citation of Rule 0d, not the word effort; `flow-models-per-role`'s `## Record` does not close it — still open. **Closed by `flow-commands-to-skills` (`6f8b948`; FU1-3, FU1-4):** the three commands are gone; their stage skills say their agent is dispatched "as `glab:manager` Rules 0d and 5 say" (`skills/{commit,analyze,integrate}/SKILL.md:7`), and under the "say it once" rule a citation of Rule 0d, which Rule 0c lists among what every dispatch carries, is the intended form, not a gap.
- [flow-master-plan/follow-ups.md DEV3] `AGENTS.md` *One fact* round-caps entry names the final check, but of the files it lists only `plugins/glab/skills/manager/SKILL.md` states the final check's cap; `agents/analyzer.md` *The final check* names round 2 but no cap, and the reviewer files stay untouched by decision (D32). The value, 2, agrees wherever it is stated; whether each listed file must state it — open, for a later plan. **Closed by `flow-commands-to-skills` (`6f8b948`; `[flow-commands-to-skills/plan.md]` A13, R1):** the round-caps entry now names only the files that state the fact — `glab:manager` *Pick the tier*, which states the final check's cap (`skills/manager/SKILL.md` *Round caps*), and the reviewer's round-2 rule in `agents/reviewer.md` *Re-reviews*; `analyzer.md`, `plan-analyzer.md`, `ship` and `bootstrap` left it.
- [flow-models-per-role/plan.md FU1] A documented gap: every glab agent with a `tools` list but `glab:planner` — `glab:analyzer`, `glab:committer`, `glab:developer`, `glab:integrator`, `glab:reviewer` and the new `glab:plan-analyzer` (`D20`) — lacks `Skill` (`E13`; `command grep -H '^tools:' plugins/*/agents/*.md` at `517b7b6`, run for this record, prints `Skill` on `planner.md` only), and the docs say such an agent cannot invoke skills (`E9`), yet Rule 0c's dispatches tell them to load `glab:security` and `glab:comments` (`reviewer.md:15`: "if they are available"). Review finding R2.3 raised it again for `glab:plan-analyzer`, `glab:analyzer` and `glab:reviewer`; the manager kept D20 and left it here, one follow-up for a separate change (`[flow-models-per-role/result.md R2.3]`); `glab:planner` left the gap when R2.2 gave it a `tools` line with `Skill`. Fix: add `Skill` to each `tools`, or a `skills:` field (`E9`) — open. **Closed in the tree by `flow-commands-to-skills` (`6f8b948`, `glab` 0.13.0; `[flow-commands-to-skills/plan.md FU1-2]`), the runtime still UNVERIFIED:** the fix this item named second, a `skills:` field, is in every agent — `glab:security` in all seven, `glab:comments`, `glab:audit` and `glab:plan` as *Shared skills reach agents through frontmatter `skills:`* says — and the docs say a preload needs no `Skill` tool, so no `tools` line changed; Rule 0c's dispatches no longer tell an agent to load them. The skills gate prints the fourteen entries, none `MISSING` (`docs/specs/marketplace.md`). That a live dispatch loads them is `[flow-commands-to-skills/plan.md U4]` and `U5`, under *Known limits*.
- [flow-commands-to-skills/follow-ups.md FU-3] `plugins/glab/agents/planner.md:20` keeps the `Skill` tool and loads `glab:manager` for the sections `glab:plan` points at (*Pick the tier*, Rule 3, Stages 1b and 8). The Skill tool loads a whole skill, so the planner pays for all of `skills/manager/SKILL.md` (55251 bytes, `wc -c`) and holds the manager's operating model in its context. Review finding A6 (read only those sections) was rejected, the plan decision on the preload lists standing, because reading the sections by path in an installed plugin is UNVERIFIED (whether an agent can resolve `${CLAUDE_PLUGIN_ROOT}`; cf. U6) — open, for its own task: prove a path-based read, or move what the planner needs out of `glab:manager`. **Altered by `flow-product-level` (`ce1a933`):** Rule 1 and Rule 3 left `glab:manager` for `glab:session-rules`, and `glab:plan` Steps 0 and 2 (`skills/plan/SKILL.md:19`, `:66`) now point there, while *Pick the tier*, Stages 1b and 8 stay in `glab:manager`, now 40284 bytes; `agents/planner.md:20` still keeps `Skill` "for the `glab:manager` sections it points at", and its `skills:` list does not name `glab:session-rules`, so the planner now loads `glab:manager` and, for those two rules, `glab:session-rules` (22435 bytes) through the Skill tool — inferred from the files, no dispatch was run. Still open: the half the move created — what the planner needs now lies in two skills — and the path-based read, which LP3 bears on (`docs/specs/product.md`). **Closed by `flow-project-level` (`db5feae`):** `glab:project-planner` has no `Skill` tool and loads no manager (`[flow-project-level/index.md D9]`, F3); its `tools:` is `Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch`.
- [flow-commands-to-skills/follow-ups.md FU-2] `plugins/glab/skills/commit/SKILL.md:9` ("If it refuses to stage something, that is the correct outcome — relay the reason, do not work around it") restates `plugins/glab/skills/manager/SKILL.md:354` ("A refusal to stage is the correct outcome — relay the reason, never work around it"), and `:354` also lists the committer's deny-list, which `agents/committer.md` Step 3 owns. Found in review fix round 1; no round-1 finding named either, so the fix round left them — open, for one owner and pointers under the "say it once" rule. Re-read at `ce1a933`: the commit-on-`main` rule moved from Stage 6 into `glab:commit`, but `skills/manager/SKILL.md:276` still reads "Its deny-list is authoritative: nested repositories, credentials and `.env` files, local noise, and anything the user did not ask about. **A refusal to stage is the correct outcome** — relay the reason, never work around it", beside `skills/commit/SKILL.md:9` — still open. **Closed by `flow-project-level` (`db5feae`):** `glab:project-manager` holds no Stage 6 text: no refusal sentence and no deny-list (`grep -c deny-list` → `0`); `glab:commit` and `glab:committer` own them (F14, 03 P12).
- [feature-docs-specs/follow-ups.md 4] `skills/bootstrap/SKILL.md:125`: "what a finished change left open is there, not in `plan/`" is wrong in a repo that keeps its plans, which is `glab`'s default. Suggested: "is there; `plan/` may still hold the working files" — open. Re-read at `6f8b948`: the line is now `skills/bootstrap/SKILL.md:54` and still reads "what a finished change left open is there, not in `plan/`" — still open. **Closed by `flow-project-level` (`db5feae`):** `glab:bootstrap` no longer holds the sentence (02 P9; `grep 'finished change left open'` finds nothing).
- [flow-project-level/03-project-manager/follow-ups.md FU1] `project-plan-analyze/SKILL.md` had no `argument-hint:` — closed: `:4` is `argument-hint: "[plan slug]"` (review round 1 advisory, `[flow-project-level/03-project-manager/plan.md W24]`).
- [flow-project-level/02-shared-rules/follow-ups.md 1] The every-level skill list of *The level boundary* lacked `glab:severity` — closed by this record (*How it works now*), which also names the three new project skills (*The project level as of 0.15.0*).
- [flow-project-level/02-shared-rules/follow-ups.md 2] For the record: the hook replaces a closed stdin with `/dev/null` (`{ : 3<&0; }`, since bash 5.3.9 treats `0<&0` as a no-op) and keeps an id's trailing newline with a sentinel, so that id fails the match (B18, B19) — recorded under *How it works now*.
- [flow-project-level/index.md D27] The user's other repos keep no `.gitignore` line for `plan/handoff/` unless their owners add one — open. **Closed in the tree by `docs-lifecycle` (`3ed6746`, `glab` 0.16.0; `[docs-lifecycle/plan.md D4]`, P9), the live run UNVERIFIED:** `glab:bootstrap` step 5 has the manager add `/plan/`, which covers `plan/handoff/`, to `.gitignore` when `git check-ignore -q plan/x` fails.
- [docs-lifecycle/result.md follow-up-1] `plugins/glab/skills/session-rules/SKILL.md:78` kept the bold title **The standing approval.** (singular) beside **The plan-folder approval.** — closed by review fix round 1 (`[docs-lifecycle/review.r1.md 6]`): it is **The handoff approval.**
- [docs-lifecycle/result.md follow-up-2] `plugins/glab/skills/bootstrap/SKILL.md:39` said "Rule 2's standing approval covers" for the handoff files — closed by the same fix: "Rule 2's handoff approval covers".
- [docs-lifecycle/review.r1.md 10] (low, inferred) When both `<branch>` and `origin/<branch>` are gone — an MR merged with "delete source branch" and a pruning fetch — the folder stays for good, with a one-line report at every session start and no question, against the user's "Nothing piles up". Suggested: fall back to the PR/MR's merge commit, or ask once. Accepted by `[docs-lifecycle/plan.md D45]`: the folder stays with its one-line notice and the user removes it by hand — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D26]`):** the branch is not needed any more — Rule 2's facts command searches `origin/<default>` for the commit that adds the *Records* line, so a landed folder whose branches are gone is listed and asked about once per session, like every other (`session-rules/SKILL.md:87`); nothing stays for good unasked.
- [docs-lifecycle/review.r2.md record-branch] A record committed on a branch other than the one its *Records* line names gives an empty `<record-sha>` (*Known limits*), and this repo commits each record on a branch of its own; `plan/docs-lifecycle` is the first case, so Rule 2's approval leaves it as "cannot be evaluated" and A3's form asks. Whether `<branch>` in Rule 2 should be where the record was committed, or the record pushed onto the change's branch — open, for the user (the folder's removal meanwhile is by hand, or by A3 on the user's yes). This folder has no `## Record`, so A1 stood in for it, and under Rule 2 as written (`glab:session-rules`, "the `## Record` … is not found") the folder would also stay; the manager removes it under U1 (D22, A3) after checking every D5 guard by hand with the actual record commit. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D3]`, `D26`, `D27`):** the record is committed on the change's branch, after its push and before its merge (`project-record/SKILL.md:11`, `AGENTS.md:114`–`116`), and this record is so committed, on `lifecycle-hardening`; and the listing no longer reads the branch, so a record on another branch is found on `origin/<default>` once it lands.
- [docs-lifecycle/review.r2.md project-record:13] (low) `plugins/glab/skills/project-record/SKILL.md:13`: the full-tier reviewer pass is "on the spec and feature-page diff"; if the manager pastes `git diff` output, a new, untracked page is missed (given paths or the working tree, as in Stage 5, the reviewer reads every `??` itself, `project-reviewer.md:22-36`). Suggested: "one `glab:project-reviewer` pass whose target is the uncommitted spec and feature-page paths — the target only, as in Stage 5" — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`):** `project-record/SKILL.md:15` reads "one `glab:project-reviewer` pass on the uncommitted spec and feature-page paths alone — the target only, as in Stage 5".
- [docs-lifecycle/result.md review-r1-follow-up] The developer's follow-up from review fix round 1, the same item as the one above: "the full-tier reviewer pass (`project-record/SKILL.md:13`) is still given a diff, so a new, untracked feature page is not in it. F4 named only `:12` and the analyzer" — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`), with the item above:** the reviewer's target is the uncommitted spec and feature-page paths (`project-record/SKILL.md:15`).
- [docs-lifecycle/review.r2.md session-rules:87] (low) `plugins/glab/skills/session-rules/SKILL.md:87`: `ct=…` and `find … "@$ct"` work only in one shell, and the manager's Bash tool keeps no variables between calls; run apart, `find` exits 1 and nothing is removed (fails safe). Suggested: add "in one shell command" after the `ct=` clause — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`):** the `ct=` clause is gone (`D26`); its successor, the facts command, is "its facts, in one shell command" (`session-rules/SKILL.md:87`).
- [docs-lifecycle/review.r2.md session-rules:91,93] (low) `plugins/glab/skills/session-rules/SKILL.md:91` and `:93`: a tracked folder whose record has not landed matches two outcomes, "without a word" and "named in one line"; both keep the folder. Suggested: say which comes first, for example "tracked is checked before landed" — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`):** the outcomes open "The outcomes, the first that applies:" (`session-rules/SKILL.md:89`), tracked (`:91`) before not landed (`:92`).
- [docs-lifecycle/review.r2.md project-record:12] (low) `plugins/glab/skills/project-record/SKILL.md:12` hard-codes `docs/` (`git status --short -uall -- docs/`) where specs may live "where `AGENTS.md` puts them", and restates the analyzer's untracked-page rule of `project-analyzer.md:90`. Suggested: "under the spec and feature-page paths", the full rule kept only in the analyzer — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`):** `project-record/SKILL.md:14` dispatches the analyzer with "the spec and feature-page paths — its record check says how it reads them —", and `project-analyzer.md:90` lists untracked pages with "`git status --short -uall --` on the spec and feature-page paths the dispatch names", the one place the rule is stated.

## Incidents

- **#7 and #10 were reopened by the review's scope cut** (2026-10-16): one normal-tier review of the follow-up fixes returned `SHIP WITH SCOPE CUT`. The waiver routing was removed, since a waiver has no plan and no tier; the manager's spec-entry paragraph was removed, since it dispatched the developer outside any plan step and a re-dispatch overwrites `result.md`. The earlier sync review had already cut "— one at normal tier —" from `ship.md:32`, because `/glab:ship` takes only a path and cannot know a plan's tier.
- **Why Stage 1b exists, and the 40-of-45 post-condition**: told in `glab:manager` *Stage 1b — Analyze the plan* (a step that could not be built found only by a developer's whole run; a check expecting 40 patterns, exactly what a tree with one step skipped produces). Pointed at, not copied.
- **A regex prefixed a path**: porting the user's edits, the substitution that put `glab:` back turned `plan/{slug}/plan.md` into `plan/{slug}/glab:plan.md` in two manager lines; it was caught by checking that every `/glab:` has a backtick before it, and fixed before the change was installed (`sync-local-edits` `result.md`, *Stages*).
- **One review verdict set, stated four times**: the model-switch review fix named the three last-round verdicts in Rule 5 against its own D22, so the set was then stated in Rule 5, Stage 5, `ship.md` and `reviewer.md` with no *One fact* case (`feature-model-switch` `result.md`, *Tension with the plan*). `AGENTS.md` now lists the reviewer's verdict lines as a known case.
- **Review round 1 fixes added the machinery round 2 blocked** (`feature-docs-specs`, 2026-10-18): round 1 asked for a guarded removal, so its fixes gave the payload a committer `git rm` with a guard, default-branch and `merge-base --is-ancestor` preconditions and a `git restore` instruction; round 2 returned `BLOCK 4` and `BLOCK 1`, every finding in that fix code. The user cut the scope (`[feature-docs-specs/plan.md U10]`, `U11`): Stage 8 records the spec only, retrieval is read-only, and round 3 removed logic and added no guard. The four files the cut returned to the base were checked equal to `6838133`.
- **The planner's write into its own plan folder was refused** (`feature-docs-specs`): it wrote the plan files under `$TMPDIR` with a `SHA256SUMS` file, and the manager verified and copied them in.
- **A file named `findings.md` was refused** (`subagent-effort`): the session's Write tool refused a file of that name, so the findings were written as a `## Findings` section of `plan.md`, which `glab:plan-first` allows at normal tier (`plan.md` *Findings*). The folder holds no `findings.md`.
- **Stage 1b ended on missing checks** (`subagent-effort`): round 2/2 returned `NOT BUILDABLE` on two missing checks; the user chose "Add checks, then build", and the plan was built with no third round (`[subagent-effort/plan.md stage-1b]`).
- **A file named `findings.md` was refused again** (`remove-external-agents`, 2026-10-20): the Write tool refused that file name for the planning agent, so the findings are the *Findings* section at the end of `plan.md`, as in `subagent-effort`; the folder holds no `findings.md` and no `questions.md`.
- **`stop` as built never spoke in a live session** (`flow-cheaper-rounds`, integration I1b, 2026-10-20; IN1, `[flow-cheaper-rounds/plan.md IN1]`): at `Stop` the transcript holds the turn's prompt but not yet its last call, so with one call per turn the latest written figure equalled the size at the turn's prompt and the step could never rise. A debug wrapper at `Stop` and one second later showed it: turn 1 `no usage in the transcript` then `54k`; turns 2 and 3 silent, the transcript still ending with the previous turn's 54k, then `54k`. Every T18 fixture held the turn's last call, so the test passed `19/19` on a script that could not work; the docs' "may lag" had been marked UNVERIFIED and left to I1. Fixed by `D61`–`D62` (the base is the real prompt before the last one); T20 reproduces the lag without a model and fails the earlier script (`FAIL 3/21`). The same I1 run showed the display itself works (a wrapper that always printed a `systemMessage` was shown on both turns), so the fallback (drop `stop`) did not apply. The re-run on the rebuilt script (I1c, the user's interactive Claude Code 2.1.304 session, thresholds lowered to 1000/1000 in a throwaway copy) passed, as observed by the manager from the user's screenshot: turn 1 silent; turn 2 showed `Stop says: glab: context 48k (last completed call) — a good point to /compact, or to /clear between tasks` and the turn ended there; turn 3 silent. Lesson: a hook's fixture is the file as it stands when the hook runs, not as it stands after.
- **The installed plugins load beside `--plugin-dir` in the user's own config** (`flow-cheaper-rounds`, integration I1a; IN2, `[flow-cheaper-rounds/plan.md IN2]`): the plan said no `memory-sync` hook runs under `--plugin-dir ./plugins/glab`; in the user's own config a second `Stop` hook ran and ended `cancelled`, exit 1, when `-p` exited. Which plugin's it was is UNVERIFIED (inferred: the installed `memory-sync`'s network sync cut off when `-p` exited; `context-size.sh` exits 0 in about 0.07 s) — `[flow-cheaper-rounds/plan.md FU18]`. The earlier proof that `--plugin-dir ./plugins/glab` loads `glab` alone was under an empty config only (`docs/specs/marketplace.md`, *Testing without installing*).
- **A file named `findings.md` and `findings-probe.md` were refused for a subagent a third time** (`flow-cheaper-rounds`, the planning session): the Write tool answered "Subagents should return findings as text, not write report files" for both and accepted `map-probe.md`, which was then removed; the plan therefore names mapping files `map-<area>.md` (`D15`) and the plan's findings are its *Findings* section.
- **Review round 1/1 of the built change returned `SHIP` with one low finding** (`flow-cheaper-rounds`, `[flow-cheaper-rounds/result.md review-fix-1]`, under *Known limits*): the script header's "twice at most" was not true with fewer than two prompts in the window; fixed by comment only.
- **A file named `findings.md` was refused a fourth and a fifth time, and the plan's findings file was renamed** (`flow-planner`, 2026-10-22; IN1, `[flow-planner/plan.md IN1]`): the Write tool refused `plan/flow-planner/findings.md` to the planning subagent — "Subagents should return findings as text, not write report files" — in round 1 and again in round 2's probe, which accepted `evidence.md` and five other names (`[flow-planner/evidence.md F8]`). After three refusals worked around by a *Findings* section, `glab` 0.10.0 names the file `evidence.md` in the payload (`[flow-planner/plan.md D1]`, `D38`); this closes `[flow-cheaper-rounds/plan.md FU6]`. The folder holds `evidence.md` and its round copies `evidence.r2.md`, `evidence.r3.md`, and no `findings.md`.
- **A planning agent died mid-amendment on an API 403** (`flow-master-plan`, 2026-10-22; carried from the manager's Stage 8 dispatch — no file in the plan folder records it): the agent amending the plan after plan check round 1 stopped on an API error, HTTP 403 `oauth_org_not_allowed`, with its edits to the plan files written but unverified and two temp files left under the temp directory. Nothing was trusted on the dead agent's word: the round-2 plan check, a new analyzer, verified the edits (the versions round 1 checked are kept as `plan.r1.md` and `evidence.r1.md`); the two temp files, `fmp-checks.<pid>.sh` and `fmp-out.<pid>.txt`, which the developer later found and left as not its own (`result.md` *Not done*), were removed by the manager. Lesson: an agent that dies mid-write leaves a half-amended plan that looks finished; the delta check of the next round, not the agent's report, is what shows what landed.
- **A partial platform outage stopped background agents twice** (`flow-commands-to-skills`, 2026-11-13; carried from the manager's Stage 8 dispatch — no file in the plan folder records it): during the change Claude Code's status page reported elevated errors on Claude Code, and two background agents stopped mid-run. Each was resumed from its saved transcript, and nothing was lost. UNVERIFIED here: which agents and stages they were, and the status page's own wording — this record had only the manager's account.
- **`claude --version` ran without `CLAUDE_CONFIG_DIR`** (`flow-commands-to-skills`, the round-1 developer, `[flow-commands-to-skills/result.md]` *Not done*): before B1 the developer ran `claude --version` once with no `CLAUDE_CONFIG_DIR` set, to read the CLI version (`2.1.310`), against the `AGENTS.md` rule that every `claude` command runs under a new empty config directory; every other `claude` command ran inside the *Gates* block. Whether `--version` writes to `~/.claude` is UNVERIFIED, because other sessions write there constantly, so a before-and-after look cannot tell. The agent that wrote this record made the same slip once, 2026-11-13, appending `claude --version` after the gate block it ran for the record; it is UNVERIFIED for the same reason. The rule and its reason are `AGENTS.md` *Gates* (`docs/specs/marketplace.md` *Incidents*).
- **The fix-round developer stopped three review fixes as `PLAN WRONG`, correctly** (`flow-commands-to-skills`, review round 1, `[flow-commands-to-skills/result.md]` *Fix round — review round 1*): A2, A6 and B3, as the manager had decided them, each contradicted a plan decision — A2 request 4 and `README.md:9` (a typed `/glab:plan` plans in the user's session), A6 the decision on the preload lists (the planner's `Skill` tool for the manager sections), B3 the decision C12 and C7 (the gate order stays the developer's and the bootstrap's) — so it applied the other 14 fixes, named the three and did not choose between plan and review. A2 went to the user, who kept the plan: "Plan in my session". The manager rejected A6 (its cost is `[flow-commands-to-skills/follow-ups.md FU-3]`) and had B3 applied the plan's way; a second fix round built them (`review-1.md` *After the fix round stopped on three*). The rule it followed is `glab:developer`'s: a plan that turns out wrong is reported, never worked around.
- **A developer touched the index with `git add -N` and reverted it** (`flow-product-level`, the build, X4; `[flow-product-level/result.md]` *Not done*): preparing X4, whose command as written cannot run (`docs/specs/product.md` *Known limits*, `[flow-product-level/result.md X4]`), the developer ran `git add -N plugins tests` (intent-to-add), against its rule never to stage, and reverted it at once with `git reset -q -- plugins tests`; `git diff --cached --name-status | wc -l` printed `0` afterwards, so nothing was staged. It reported the slip itself.
- **Both plan check rounds ended `NOT BUILDABLE`, and the user approved the plan amended after round 2** (`flow-product-level`, Stage 1b; `[flow-product-level/check-repo.md]`, `check-facts.md`, `check-repo-2.md`, `check-facts-2.md`): round 1 returned `NOT BUILDABLE` from both analyzers — high `R1` (the manager's record lines after acceptance would change the digest, so `check` would refuse bookkeeping) and high `I12` (the product manager told both to read `glab:manager` and never to invoke a `Project level` skill), with medium and low findings beside them. The amendment answered them: `after-verdict.md` outside the digest (C11), `glab:session-rules` pulled forward (FU-P1), the explicit lists as the boundary. Round 2, the last, returned `NOT BUILDABLE` again with no `critical` or `high` finding — against the repo medium `R2-1` (a plan from a brief with sub-plans had no stated Stage 1c) and low `R2-2`–`R2-6`; on the facts medium `F17`–`F19` (`--resume` takes the full session id; CLI cross-session messaging exists and resuming a running session forks it; a worktree background session commits and pushes without asking) and low `I16`, `I17` — so no third round ran (*Round caps*). The plan was amended once more for them — once per slug (R2-1), the pointers and posts (R2-2, R2-3; X3's post count, `214` when round 2 checked it, is `261` in the plan as built), `--add-dir` and LP6 (R2-4), the *One fact* files (R2-5), the start prompt and the CLI path (F17–F21, `E20`) — without a third check. The user, asked about keeping `glab:session-rules` (I16), answered "go with your recommendations", and approved the plan: "we need to develop, go with your recommendations". The round copies `plan.r1.md`, `plan.r2.md`, `evidence.r1.md`, `evidence.r2.md`, `master.r1.md`, `master.r2.md`, `questions.r1.md` and those of the steps files keep what each round checked. The build then did all 32 steps with nothing blocked (`result.md` *Stages*).
- **The disk filled to 0 bytes during 03's fix round 1** (`flow-project-level`, 2026-11-18): the fix agent stopped, and two files it had emptied were restored from the reviewed snapshot tree `f7ed3a6` with `git cat-file blob`, each checked with `git hash-object` (`[flow-project-level/03-project-manager/result.md]` *Fix round for review round 1*; the files are not named there).
- **03's plan check round 1 ended `NOT BUILDABLE`**, 12 findings, amended in place (`[flow-project-level/03-project-manager/plan.md W21]`); round 2 `BUILDABLE` (W23).
- **03's review round 2 ended in a scope cut** (`[flow-project-level/03-project-manager/plan.md W25]`): `project-plan-analyze/SKILL.md:17`'s pointer rewrite gave two outcomes for one state and was cut back to the old manager's sentence; no round 3.
- **Every agent of 03 overran its cap** (the manager's tally, relayed in the record dispatch; no plan file holds it): planner 175k against 80k, plan checks 63k and 56k against 50k, developer 183k against 150k, reviewer round 1 116k against 80k. In 02 the planner's G5 set measured 31496 against 31168 on `1bbf4bc` and was handed to 03 (`[flow-project-level/02-shared-rules/plan.md W11]`), which brought it to 30484.
- **02's gate run executed a line of prose** (`[flow-project-level/02-shared-rules/result.md]`): a block of `AGENTS.md` *Gates* extracted one line early ran `:50` as bash, printing `Is a directory` and `command not found`; nothing was run or written, and the gate lines were re-run from the right range.
- **The first removal command would have emptied a symlinked folder's target** (`docs-lifecycle`, plan check round 1, 2026-11-18; `[docs-lifecycle/check.r1.md F1]`, blocker): the plan's command was `rm -r -- plan/<slug>/`. In a throwaway repo with `ln -s ../outside plan/slug` and `outside/keep1 keep2`, `git ls-files -- plan/slug/` printed nothing (rc=0), so every condition of the approval passed; `rm -r -- plan/slug/` printed `rm: cannot remove 'plan/slug/': Not a directory` (rc=1), and `ls outside` showed it empty — keep1 and keep2 were gone. Fixed by `[docs-lifecycle/plan.md D23]`: `test -d` and `! test -L plan/<slug>`, no `.git`, the whole-name slug pattern, and `rm -r -- plan/<slug>` with no trailing slash.
- **The same through a symlinked `plan`** (`docs-lifecycle`, plan check round 2; `[docs-lifecycle/check.r2.md N2]`, high): the F1 fix checked the slug folder but not `plan` itself. In a throwaway repo with `plan -> ../out` and `out/s/k1`, the directory check passed (0), `find -name .git` printed nothing, `git ls-files -- plan/s` printed nothing, and `rm -r -- plan/s` then emptied `../out`; `git check-ignore -q plan` returned 1, so `/plan/` does not ignore a symlink named `plan` and it can be staged. Fixed by `[docs-lifecycle/plan.md D36]`: the checks start with `cd "$(git rev-parse --show-toplevel)"`, add `! test -L plan`, and require `realpath plan/<slug>` to equal `<toplevel>/plan/<slug>`. Round 2 also proved the blocker `[docs-lifecycle/check.r2.md N1]`: the order check's `awk` kept the last "Every other removal" it saw and printed `1` on a tree that kept the old sentence (fixed by `D35`).
- **Plan check round 2 was the cap; N1–N9 were fixed without a third round** (`docs-lifecycle`; `[docs-lifecycle/plan.md D44]`, the manager's, 2026-11-18): both rounds ended `NOT BUILDABLE` (F1–F12, then N1–N9); the plan was amended as the checker specified each fix (`D35`–`D43`) and the manager verified the amendment by its own greps, not by a third check. The round copies `plan.r1.md`, `plan.r2.md` and `plan.r3.md` keep what each round checked.
- **Review round 1 found the built removal rule could remove a later file** (`docs-lifecycle`; `[docs-lifecycle/review.r1.md 1]`, high, and `2`, medium; verdict `FIX`): `<record-sha>` as built was the newest commit on the branch touching the record files, which need not be the record. In a throwaway repo — slug s1 recorded 2026-01-01, `plan/s1/added-after-record.md` dated 2026-03-01, a second change's record of the same spec 2026-06-01 — it resolved to the second record, `find -newermt` printed nothing, and `rm -r` would have removed the later file. And the rule's sentence "An empty `<record-sha>` makes `find` fail" held only for a quoted `''`. Fixed by `[docs-lifecycle/plan.md D45]`; review round 2, the last, rebuilt the repro on the fix and returned `SHIP` with four lows (*Open follow-ups*).
- **The automatic removal failed four checks in a row, so D26 dropped it** (`lifecycle-hardening`, 2026-11-18; `[lifecycle-hardening/plan.md D26]`). Each round found a topology in which the guarded automatic path would have run `rm -r` on a file written after the real record, each in a throwaway repo under `/data/tmp/claude`, removed by exact path:
  - **Plan check round 1, the merge-back squash** (`[lifecycle-hardening/check.r1.md H1]`, high; verdict `NOT BUILDABLE`): the record committed on its own branch and squash-merged, then `origin/main` merged into the change branch. The pickaxe on the branch found the squash, whose `%at` is the merge time: record at 01-05, squash at 01-10, `git merge origin/main` into `p7-delivery-gate`, and the pickaxe printed `0ed538f at=01-10 squash p7dg`; with that sha `find plan/p7-delivery-gate -newermt "@$at"` printed nothing (rc 0) for a file dated 01-07, so the file would have been removed (`lh-chk.nIOUPm`). Fixed by `D8` (`--ancestry-path <last>..<ref>`), which printed nothing in that case.
  - **Plan check round 2, merge or fast-forward plus squash** (`[lifecycle-hardening/check.r2.md N1]`, high; `NOT BUILDABLE`, the cap): with the change merged by a merge commit (S4, `--no-ff`) or a fast-forward (S5), the record squash-merged from its own branch and main merged back, `origin/<default>` already held `<last>` and `--ancestry-path` still found the squash: `record-sha=squash rec`, `at=NOW+100`, `find` printed nothing with rc 0, so `plan/p7/new.md`, whose ctime was after the real record (`at=NOW-100`), would have been removed (`lh-chk2.BcoRdf`). The same round found `D13`'s ask-path pointer would keep `--ancestry-path` with no bottom commit, a fatal hidden by `| head -1` (`N2`). Fixed by `D17` (`--is-ancestor` must exit 1: S5 rc=0 asks, S1 rc=1) and `D18`, without a third round (`D22`).
  - **Review round 1, the cherry-picked squash** (`[lifecycle-hardening/review.r1.md 1]`, medium; verdict `FIX`): the record committed on its own branch, squash-merged, and the squash cherry-picked onto the change branch: the copy descends from `<last>`, adds `<line>`, is not an ancestor of `origin/main` (`--is-ancestor` exits 1) and carries the merge time as `%at`; `plan/s/written-after-record`, written 2 s after the record and before the squash, gave `REMOVE (picked: S-squash-at-merge-time)`. `git merge --squash origin/main` on the branch did the same. Fixed by `D24` (`%at` of `<record-sha>` strictly less than `%ct` of `<land-sha>`); the developer's proof (`result.md` *Review r1 fixes*, `lh-fix1.Przqqr`): case A asked, B and C (a genuine record, squash or rebase) still removed.
  - **Review round 2, an amended squash or a rewritten main** (`[lifecycle-hardening/review.r2.md]`, medium; verdict `FIX`, the last round, the reviewer's decision `SHIP WITH SCOPE CUT`): a squash whose committer date is later than its author date passed `D24`'s guard — amended before the push, `O1-REMOVE rec=S-squash-amended at=1794989013 land=S-squash-amended at=1794989013 ct=1794989073`; `origin/main` rewritten and force-pushed after the cherry-pick, `O1-REMOVE rec=S-squash at=1794989017 land=S-squash ct=1794989049` — and `plan/s/written-after-record` (written 2 s before the squash) was not newer than `$at`, so `rm -r` would have deleted it. The reviewer's `%at`-of-`<land-sha>` variant closed both but made a genuine rebase-merge ask, and left a `--reset-author-date` rewrite open; "the date guard grows faster than it converges".
  - **Outcome:** asked "Drop automatic removal and ask once per folder, or keep it for squash merges only?", the user answered "Ask once per folder" (`D26`), superseding their "Build it as planned" (`D23`). Review round 3 then returned `SHIP`: nothing is removed without the user naming it. Lesson: no git fact tells a record commit from a squash or a rewritten copy of it, so a removal of untracked, unrecoverable files is put to the user with the facts, not decided from dates.
- **Review round 3's helper wrote outside the temp root** (`lifecycle-hardening`; `[lifecycle-hardening/review.r3.md]`, process note): one file went to `/tmp/.x`, outside `/data/tmp/claude`; the reviewer removed it by its exact path, and `/data/tmp/claude/rv-rule2-c5uvw6` too; the repo kept the same 16 modified files and no new one. Told in `docs/specs/marketplace.md` *Incidents* beside the host's temp-file rule.

## Records

- 2026-10-16 · sync-local-edits · the user's local edits of 2026-10-08 ported into `glab` (risk tiers, Rule 3 decisions, Rule 4 surfaces), then twelve consistency fixes; two reopened, seven new found · change 5f69d65 70166f4 · records 0dec5e2 9700bcb · plan: `git ls-tree -r --name-only 9700bcb -- plan/sync-local-edits/` (one file: `git show 9700bcb:plan/sync-local-edits/<file>`)
  - [sync-local-edits/follow-ups.md L58] After the review of the follow-up fixes (2026-10-16) → `[sync-local-edits/follow-ups.md 7]` and `[sync-local-edits/follow-ups.md 10]` reopened, `[sync-local-edits/follow-ups.md 3]` corrected, new `13`–`19`, all under their tags above.
  - [sync-local-edits/result.md L215] Follow-ups → none written; the contradictions it reported were decided in its second set, `[sync-local-edits/result.md decisions]`; nothing open.
  - [sync-local-edits/result.md L219] Not done → the UNVERIFIED that the local edits are exactly the 2026-10-08 change, under *Known limits*; no commit was its step.
- 2026-10-16 · feature-model-switch · `glab:manager` Rule 5: the user names the model of the developer or the reviewer, passed per dispatch, recorded, shown in each handoff, the dispatch written for it · change 1f12a37 · records 889b804 · plan: `git ls-tree -r --name-only 889b804 -- plan/feature-model-switch/` (one file: `git show 889b804:plan/feature-model-switch/<file>`)
  - [feature-model-switch/result.md L96] Follow-ups → nothing open ("None").
  - [feature-model-switch/result.md L100] Not done → the commit split: done (`1f12a37`, `889b804`); `[feature-model-switch/plan.md I1]` and `[feature-model-switch/plan.md I4]`, with the unchecked doc citations, under *Known limits*.
- 2026-10-05 · bug-reviewer-findings · recorded in `docs/specs/memory-sync.md`; its workflow items (questions Q3, Q7, Q10; follow-ups 16, 18, 19; two open items from its result files) are tagged above · plan: `git ls-tree -r --name-only 2aeb46d -- plan/bug-reviewer-findings/` (one file: `git show 2aeb46d:plan/bug-reviewer-findings/<file>`)
- 2026-10-18 · feature-docs-specs · one spec per area in `docs/specs/`, the seven plan folders migrated into them and removed; `glab` `0.5.0` gains Stage 8, the record, which writes the area spec and never removes a plan folder; this repo's `AGENTS.md` keeps the removal for the manager session · change e3e0d69 fed95f9 196ff22 · records 09d2787 · plan: `git ls-tree -r --name-only 09d2787 -- plan/feature-docs-specs/` (one file: `git show 09d2787:plan/feature-docs-specs/<file>`)
  - [feature-docs-specs/follow-ups.md L1] Follow-ups (review round 3/3 advisories) → `2`, `4`, `5`, `7` open and `9`, `10` closed, here; `1`, `3`, `6`, `8` open in `docs/specs/marketplace.md`.
  - [feature-docs-specs/plan.md L504] Not in this plan → the migrated follow-ups it did not fix stay under their own tags; the Markdown gate is `[bug-reviewer-findings/follow-ups.md 20]` (`docs/specs/marketplace.md`); the profile re-tune `[feature-opencode-worker/follow-ups.md 12]`, DeepSeek's end date `[feature-opencode-worker/plan-r3.md not-in-plan-4]` (`docs/specs/external-agents.md`); the smoke test `[feature-plugin-marketplace/plan.md smoke-test-1]`; a `docs/constants.md` and a spec index were not asked for; `plan/SESSION-HANDOFF.md` stays untracked — nothing new open.
  - [feature-docs-specs/plan.md L511] UNVERIFIED, in one place → `[feature-docs-specs/plan.md unverified]`; its squash-merge item answered under *Known limits*.
  - [feature-docs-specs/findings.md L443] Inferred behaviour → `[feature-docs-specs/findings.md inferred]`; its squash-merge item answered under *Known limits*.
  - [feature-docs-specs/result-PR.md L31] Blocked → nothing.
  - [feature-docs-specs/result-PR.md L113] Follow-ups → none written; so too its round sections at `L251`, `L305` and `L418` ("None.").
  - [feature-docs-specs/result-PR.md L117] Not done → the other slice and the commits: done (`e3e0d69`, `fed95f9`, `196ff22`, `09d2787`); B2: checked; the record: this record; its UNVERIFIED → `[feature-docs-specs/plan.md unverified]`.
  - [feature-docs-specs/result-SM.md L59] Blocked → none.
  - [feature-docs-specs/result-SM.md L254] Follow-ups → `[feature-docs-specs/result-SM.md 1]` and `2` closed, `3` open, here.
  - [feature-docs-specs/result-SM.md L273] Not done → the other slice, the commits and the record: done; B2 checked without `git fetch`: history; its UNVERIFIED → `[feature-docs-specs/plan.md unverified]`.
  - [feature-docs-specs/result-SM.md L368] Follow-ups (review round 1 fixes) → none new.
- 2026-10-18 · feature-codex-agent · recorded in `docs/specs/external-agents.md`, its primary area; here: Rule 5's Codex record line, its `--model` rule and the effort, Rule 6 covering two backends, D30's effort line, `/glab:review` naming Codex · change 9108ac7 · records 30f2c80 · plan: `git ls-tree -r --name-only 30f2c80 -- plan/feature-codex-agent/` (one file: `git show 30f2c80:plan/feature-codex-agent/<file>`)
- 2026-10-18 · feature-external-developer · recorded in `docs/specs/external-agents.md`, its primary area; here: Rule 5's external developer (Codex only) with its record and handoff lines and its table row, Rule 6's two exceptions, `/glab:develop`'s external path · change 33a28df · plan: `git ls-tree -r --name-only 33a28df -- plan/feature-external-developer/` (one file: `git show 33a28df:plan/feature-external-developer/<file>`)
- 2026-10-19 · fix-external-agent-claims · recorded in `docs/specs/external-agents.md`, its primary area; here only the re-read note of `[feature-docs-specs/result-SM.md 3]` · change 3965622 · plan: `git ls-tree -r --name-only abda43a -- plan/fix-external-agent-claims/` (one file: `git show abda43a:plan/fix-external-agent-claims/<file>`). `abda43a` is the last commit on `origin/main` that holds it; the folder is the same there as at `3965622`
- 2026-10-19 · subagent-effort · `glab:manager` Rule 0d: every subagent dispatch passes the Agent tool's `effort` at the session's level, recorded in one `- effort:` line and named in the handoff line; Codex shares that one level through Rule 6's mapping, and its model lines lose their effort clause; the dispatch text of Stages 2 and 5, `/glab:develop`, `/glab:review`, `/glab:ship`, `glab:bootstrap`, the hook and `README.md`; a new *One fact* entry; `glab` 0.7.2 · change abda43a · plan: `git ls-tree -r --name-only abda43a -- plan/subagent-effort/` (one file: `git show abda43a:plan/subagent-effort/<file>`; the whole folder: `git archive abda43a plan/subagent-effort/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `abda43a` is the last commit on `origin/main` that holds it: one `docs(repo)` commit after this record removes it and `plan/fix-external-agent-claims/`
  - [subagent-effort/plan.md L15] Findings (a section of `plan.md`, not a file: *Incidents*) → its *Inferred, not shown* (`L92`) is `[subagent-effort/plan.md unverified]`; its scope table, searches and call sites were that change's.
  - [subagent-effort/plan.md L99] Decisions → `[subagent-effort/plan.md D1]` to `D8`, `stage-1b` and `approval`, above.
  - [subagent-effort/plan.md L265] Record → this record, in this file, `docs/specs/external-agents.md` and `docs/specs/marketplace.md`; `[feature-codex-agent/record.md effort-line]` closed. Order: the plan (`plan.md` L267) expected this record after the `fix-external-agent-claims` record had been committed; both records instead land in one `docs(repo)` commit, and the folder removal follows in another.
  - [subagent-effort/plan.md L276] Follow-ups → `[subagent-effort/plan.md F1]` open.
  - [subagent-effort/questions.md L3] Q1 → `[subagent-effort/questions.md Q1]`, A.
  - [subagent-effort/result.md L41] Blocked → none.
  - [subagent-effort/result.md L45] Unplanned changes → none; line wraps only.
  - [subagent-effort/result.md L209] Blast radius → `[subagent-effort/result.md blast-radius]`; its UNVERIFIED (`L228`) → `[subagent-effort/plan.md unverified]`.
  - [subagent-effort/result.md L231] Follow-ups → none added; F1 stays in `plan.md`, carried here.
  - [subagent-effort/result.md L236] Not done → the commit (`abda43a`); `docs/specs/` and `plan/SESSION-HANDOFF.md` left as they were; no real model or external agent run — nothing open.
  - [subagent-effort/result.md L244] Review round 1 fixes → fixes 1–3 built in Rule 0d (the `effort default` fallback, `ultra` scoped to an Agent tool dispatch, the session-wide line in every plan); finding 4 → `[subagent-effort/result.md finding-4]` open.
  - Review round 2 → no review file is in the folder; its two advisories, from the manager's Stage 8 dispatch record, → `[subagent-effort/record.md round-2-ultra]` and `[subagent-effort/record.md round-2-pipeline-default]` open.
- 2026-10-20 · remove-external-agents · recorded in `docs/specs/external-agents.md`, its primary area; here: `glab:manager` has no external reviewer or developer — Rule 6 gone, Rules 0d and 5 and *The pipeline* without their Codex and OpenCode sentences, Rule 5's dispatch table without its two external rows, Stage 5, the parallel review and *What you never do* without their external text; `/glab:develop`, `/glab:review` and `/glab:ship` without their external paths; Rule 0d unchanged for Claude subagents; every statement of the external agents in this file marked as history; `glab` 0.8.0 · change 467b7c4 · plan: `git ls-tree -r --name-only 467b7c4 -- plan/remove-external-agents/` (one file: `git show 467b7c4:plan/remove-external-agents/<file>`). `467b7c4` is the last commit on `origin/main` that holds it: one `docs(repo)` commit after this record removes it.
  - [remove-external-agents/plan.md L17] Decisions → `D4`, `D5`, `D6`, `D7`, `D9`, `D11`, `D14`, `approval` and `spent`, above.
  - [remove-external-agents/plan.md L567] Inferred → `[remove-external-agents/plan.md inferred]`.
  - [remove-external-agents/plan.md L247] Record → the follow-ups it names re-read: `[feature-docs-specs/result-SM.md 3]`, `[subagent-effort/record.md round-2-ultra]` and `[subagent-effort/record.md round-2-pipeline-default]` still open, each with its re-read.
  - [remove-external-agents/result.md L1] Result → every step done, no unplanned change, no follow-up written; its UNVERIFIED → `[remove-external-agents/result.md not-done]`.
- 2026-10-20 · flow-cheaper-rounds · seven changes to cut the pipeline's token cost: round caps of 2 (+1 on a `critical` or `high` finding) for Stages 1b, 3 and 5, every round a new agent, delta re-checks, a narrower planner search, explore once through `map-<area>.md`, the manager's context rule, and the `context-size.sh` hook on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop`; the `severity:` line, the analyzer's re-check section, the developer's fix-round section; the handoff line's `· context <n>k`; `glab` 0.9.0 · change 2a1e919 · plan: `git ls-tree -r --name-only 2a1e919 -- plan/flow-cheaper-rounds/` (one file: `git show 2a1e919:plan/flow-cheaper-rounds/<file>`; the whole folder: `git archive 2a1e919 plan/flow-cheaper-rounds/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `2a1e919` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-cheaper-rounds/`): one `docs(repo)` commit after this record removes it. The folder holds `plan.md` and its three earlier versions `plan.r1.md`, `plan.r2.md` and `plan.r3.md` (round copies: the record takes its items from `plan.md`), `result.md` and `follow-ups.md`.
  - [flow-cheaper-rounds/plan.md L55] Decisions → `[flow-cheaper-rounds/plan.md D1]` to `D65` and `model` and `effort`, above under *Decisions that still bind*, each in its own line; the user's are D2, D29 and `model`, the manager's choices D3, D49–D54 and D61 (the user may overrule D3, D54 and D61).
  - [flow-cheaper-rounds/plan.md L129] Findings → `F1` (the measured evidence) and `F8`, `F9`, `F15`, `F18`, `F20`, `F23`, `F24` under *Known limits and not verified*; `F2`–`F7`, `F10`–`F14`, `F16`, `F17`, `F19`, `F21`, `F22` were that change's searches, baselines and prototypes, and their conclusions are in the decisions they support (`D4`, `D7`, `D10`–`D12`, `D14`, `D31`, `D32`, `D45`, `D49`–`D50`, `D58`).
  - [flow-cheaper-rounds/plan.md L1023] Follow-ups → `FU1` to `FU18`: `FU1`–`FU6`, `FU8`, `FU11`–`FU18` open, `FU7`, `FU9`, `FU10` closed, above.
  - [flow-cheaper-rounds/plan.md L1044] Incidents → `IN1` and `IN2`, above under *Incidents*; `[flow-cheaper-rounds/plan.md FU18]` open.
  - [flow-cheaper-rounds/plan.md L1049] Record → this record, in this file and `docs/specs/marketplace.md`; `[sync-local-edits/follow-ups.md 18]` and `[sync-local-edits/follow-ups.md 19]` closed; `[bug-reviewer-findings/questions.md Q3]` and `[sync-local-edits/result-followups.md D11]` marked superseded by `D2`.
  - [flow-cheaper-rounds/result.md L5] Stages and Blocked (`L25`) → every step S1–S17 done, nothing blocked. Unplanned changes (`L29`) → implementation choices inside S13, not behaviour changes: the `jq` program reads token fields through `numbers` and emits through `floor`, and the shell accepts only 1 to 15 digits before any bash arithmetic (`[flow-cheaper-rounds/result.md digit-guard]`); two wording choices to satisfy the plan's own searches.
  - [flow-cheaper-rounds/result.md L35] Tests → `tests/context-size.test.sh`, 21 cases at `PASS 21/21` (19 before the fix round, `L178`); `tests/memory-sync.test.sh` unchanged at `PASS 35/35`; the one uncovered branch → `[flow-cheaper-rounds/result.md digit-guard]`, under *Known limits*.
  - [flow-cheaper-rounds/result.md L161] Security blast radius → `D35`, `D36`, `D44`, `D46`: the hook writes no file, keeps no state, opens no network connection, prints only an integer and fixed words, and cannot block or continue a turn; roll back by `git revert`, which raises `glab` to `0.9.1`.
  - [flow-cheaper-rounds/result.md L172] Not done → I1 and I1c, the user's runs, and that a live session follows the new prose → `[flow-cheaper-rounds/plan.md F23]` and `[flow-cheaper-rounds/plan.md F1]` (*Inferred, not shown*), under *Known limits*.
  - [flow-cheaper-rounds/result.md L178] Fix round 1 — I1 stop lag (S13.1, S13.4, S13.5, S14.2, S14.3, one sentence of S1.16, one of S16.3; the `stop_spec` helper in the test is an implementation choice) → `D61`–`D65`; Review fix round 1 (`L288`, comment only) → `[flow-cheaper-rounds/result.md review-fix-1]`.
  - [flow-cheaper-rounds/follow-ups.md L1] Follow-ups → `[flow-cheaper-rounds/follow-ups.md FUa]`, `FUb`, `FUc`, `FUd`, open, above.
- 2026-10-22 · flow-planner · cheaper plans and developers: `evidence.md` in place of `findings.md` (older folders still read), a 48 KB budget for `plan.md` and `evidence.md` with the manager's size check, amendments replaced in place, `glab:plan-first` Steps 5–7 moved to `implement.md`, the developer's *Keep your context small*, and `GLAB_COMPACT_AT` for the context hook's first step with tests T22–T24; `glab` 0.10.0 · change 2912002 · plan: `git ls-tree -r --name-only 2912002 -- plan/flow-planner/` (one file: `git show 2912002:plan/flow-planner/<file>`; the whole folder: `git archive 2912002 plan/flow-planner/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `2912002` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-planner/`): one `docs(repo)` commit after this record removes it. The folder holds `plan.md` and its earlier versions `plan.r1.md`, `plan.r2.md`, `plan.r3.md`, `evidence.md` and its earlier versions `evidence.r2.md`, `evidence.r3.md` (round copies: the record takes its items from `plan.md` and `evidence.md`), `result.md` and `follow-ups.md`.
  - [flow-planner/plan.md D1] Decisions → `D1`–`D22`, `D38`, `D41` and `effort`, above under *Decisions that still bind*, each in its own line; the user's are D9, D10, D12 and D21. Amended in earlier records, marked in place: `[flow-cheaper-rounds/plan.md D10]` and `D49` (by D38), `D45` and `D47` (by D12).
  - [flow-planner/evidence.md F0] Evidence → `F2`, `F4`, `F5`, `F8` under *Known limits and not verified*, `F8` also extending `[flow-cheaper-rounds/plan.md F9]`; `F0`, `F1`, `F3`, `F6`, `F7`, `F9`, `F11`, `F14` were that change's scope, measurements, searches and baselines, and their conclusions are in the decisions they support (`D2`, `D9`, `D21`, `D38`). *Boundary* `B1` and `B2` → `D8`, `B4` → `D13`; `B3`, rejected: a `PreToolUse` hook refusing an oversized `plan.md`, because it fires in every repo with `glab` enabled and stops a planner mid-write.
  - [flow-planner/plan.md FU1] Follow-ups → `FU1`, `FU3`, `FU4`, `FU5`, `FU8` open; `FU2` and `FU6` closed, with `[flow-cheaper-rounds/plan.md FU2]` and `FU6`; `[flow-cheaper-rounds/plan.md FU1]` re-pointed to `FU1`; `FU7` and `FU9` belong to `flow-master-plan`, not recorded here.
  - [flow-planner/plan.md IN1] Incidents → `IN1`, above under *Incidents*.
  - [flow-planner/plan.md S8] Record → this record, in this file and `docs/specs/marketplace.md` (the *One fact* changes, `glab` `0.10.0`, the gates' `PASS 24/24`); no audit file.
  - [flow-planner/result.md B0] Result → every step (B0, S1, S2, S4, S5, S7, S8, *After*) done, nothing blocked, no unplanned change in the build (fix round 1's five, R1–R4 and FD1, are below); tests T22–T24 added, `PASS 24/24`, `FAIL 3/24` against the `cf614ec` script, `tests/memory-sync.test.sh` unchanged at `PASS 35/35`; the one uncovered branch → `[flow-planner/plan.md S7]`, under *Known limits*; the inferred items → `[flow-planner/evidence.md F2]` and `F5`.
  - [flow-planner/result.md R1] Fix round 1 (review round 1 findings 1–4 and the manager's FD1) → `R1` (blocking: the log template's braces) and `R3` (the waiver points at `implement.md`) in *How it works now*, `R2` (the smaller-window bullet only when the line names no `compact at <t>k`) in *The context rule*, `R4` (T24's `stop` run judged by T19) in `[flow-planner/record.md review-t19-comment]`, `FD1` closed.
  - [flow-planner/follow-ups.md FD1] Follow-ups (developer) → `FD1` closed, `FD2` open, above.
  - Review advisories for `flow-master-plan`, from the manager's Stage 8 dispatch (no review file is in the folder) → `[flow-planner/record.md review-waiver-implement]` and `[flow-planner/record.md review-t19-comment]`, open; both closed since by `flow-master-plan` (`0cbf5b0`).
- 2026-10-22 · flow-master-plan · the master plan and sub-plans: every plan folder starts with a constant, hashed `master.md` (the request verbatim, the goals, the final check, the record), one `plan.md` or `index.md` and sub-plan folders that each run their own cycle and commit; the analyzer's intent question at Stage 1b, Stage 3 and the new Stage 6b final check, and its own plan check with `BUILDABLE` and `NOT BUILDABLE`; the user's approval after Stage 1b, in plan mode only when asked, its claims UNVERIFIED until L1–L7; `## Record` in the master; the stage listings with the final check; the two `flow-planner` advisories closed; `glab` 0.11.0 · change 0cbf5b0 · plan: `git ls-tree -r --name-only 0cbf5b0 -- plan/flow-master-plan/` (one file: `git show 0cbf5b0:plan/flow-master-plan/<file>`; the whole folder: `git archive 0cbf5b0 plan/flow-master-plan/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `0cbf5b0` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-master-plan/`): one `docs(repo)` commit after this record removes it. The folder holds `plan.md` and its earlier versions `plan.r1.md`, `plan.r2.md`, `evidence.md` and its earlier versions `evidence.r1.md`, `evidence.r2.md` (round copies: the record takes its items from `plan.md` and `evidence.md`), `result.md` and `follow-ups.md`; no `master.md`, since the change ran under the 0.10.0 rules it changed (`[flow-master-plan/plan.md D45]`).
  - [flow-master-plan/plan.md D23] Decisions → `D23`–`D37`, `D39`, `D40`, `D42`–`D47`, `effort` and fix round 1's `R1`, above under *Decisions that still bind*, each in its own line; the user's are D23, D32 and D37, the manager's D37's UNVERIFIED rule and D46; D43–D45 and `effort` spent. Marked in place: `[sync-local-edits/result-followups.md D5]` amended by D31, `[feature-docs-specs/plan.md D5]` and `D28` by D39; `[flow-cheaper-rounds/plan.md D2]` extended by D29, `D10` and `D49` by the master and index copies, `[flow-planner/plan.md D2]` by S1; `[flow-cheaper-rounds/plan.md D27]` and `[flow-planner/plan.md D20]` noted with D30, `[flow-planner/plan.md D9]` with D36. D26 amends the manager's order of approval before Stage 1b, which no tagged decision held.
  - [flow-master-plan/evidence.md F0] Evidence → `F11`, `F12`, `F16` under *Known limits and not verified*, `F12` with L1–L7; `F0`, `F3`, `F10`, `F13`–`F15`, `F17`, `F18` were that change's scope, readings, baselines and searches, and their conclusions are in the decisions they support (`D30`, `D32`, `D35`, `D36`, `D40`, `D47`), `F18` also in `[flow-master-plan/plan.md Milestone]`. *Boundary* `B5`–`B12`, rejected alternatives → D24 (`B5`, `B6`), D30 (`B7`), D36 (`B8`), D32 (`B9`), D37 (`B10`), D25 (`B11`), D31 (`B12`).
  - [flow-master-plan/plan.md FU7] Follow-ups → `FU7` and `FU9` open; `[flow-master-plan/follow-ups.md DEV1]`, `DEV2`, `DEV3` open; closed: `[flow-planner/record.md review-waiver-implement]`, `[flow-planner/record.md review-t19-comment]` (D47) and `[flow-cheaper-rounds/plan.md FU5]` (D35); re-read, still open: `[sync-local-edits/follow-ups.md 17]` (half answered by S7) and `[flow-planner/plan.md FU1]` (D36).
  - [flow-master-plan/plan.md L1] Live tests → `L1`–`L7`, the user's, not run, under *Known limits* (written there by fix round 1, `[flow-master-plan/result.md R3]`), each linked to the claim it settles and to `FU7`; the setup line now stops when `mktemp` fails (final review, one low finding, fixed in this record; no review file is in the folder).
  - Incidents → the planning agent that died on an API 403, above under *Incidents*, carried from the manager's Stage 8 dispatch; no file in the folder records it.
  - [flow-master-plan/result.md B0] Result → every step (B0, S1–S10) done, nothing blocked; unplanned changes only re-wraps in `plugins/glab/skills/bootstrap/SKILL.md`, `README.md` and `AGENTS.md`, so each searched phrase sits on one line; no test added, `PASS 35/35` and `PASS 24/24`, S10 one comment line; `$ARGUMENTS` with a `/` → `[flow-master-plan/evidence.md F16]`. Fix round 1 (review round 1) → `R1` and `R2` (blocking) in *How it works now* and the decisions, `R3` (blocking) the L1–L7 entries, `R4`–`R6` (low): the final check's "(the plan, with no index)" in `analyzer.md` and Stage 6b, the analyzer's description, `README.md`'s Stage 1b and Stage 3 sentence; two S1 searches of the plan moved to `0` by R1 and R2.
  - [flow-master-plan/plan.md Record] Record → this record, in this file and `docs/specs/marketplace.md` (the *One fact* changes, the version rule per push, `glab` `0.11.0`); no audit file.
- 2026-11-12 · flow-models-per-role · a model per role: each of the seven `glab` agents' definitions sets its role's model in its frontmatter — `glab:planner` and `glab:plan-analyzer` `opus`, `glab:analyzer`, `glab:developer`, `glab:reviewer` and `glab:integrator` `sonnet`, `glab:committer` `haiku` — shipped to every installer on the user's answer "Default"; Rule 5 reworded (the user's words override any role, no parameter otherwise, an agent with no definition none), `model <alias>` on every agent stage's handoff line, the dispatch table for the default; the new `glab:planner`, dispatched by `/glab:plan`; the analyzer split into `glab:plan-analyzer` (Stage 1b) and `glab:analyzer` (conformance, final and record checks), `/glab:analyze` routing by the check named, then by the folder; `glab` 0.12.0 · change 09d5664 517b7b6 · plan: `git ls-tree -r --name-only 517b7b6 -- plan/flow-models-per-role/` (one file: `git show 517b7b6:plan/flow-models-per-role/<file>`; the whole folder: `git archive 517b7b6 plan/flow-models-per-role/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `517b7b6` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-models-per-role/`): the `docs(repo)` commit that carries this record removes it. The folder holds `master.md`, `plan.md` (normal tier, one page, its evidence the section *Evidence*), `questions.md` and `result.md`; no round copy, no `follow-ups.md` (the build's dispatch limited its writes in the folder to `result.md`), and no `master.sha256` — `master.md` has no `## Approval` section (`/usr/bin/grep -c '^## Approval' plan/flow-models-per-role/master.md` prints `0`), so the folder records neither the master's acceptance nor its hash.
  - [flow-models-per-role/plan.md D1] Decisions → `D1`–`D20`, `effort` and `[flow-models-per-role/questions.md Q1]`, above under *Decisions that still bind*, each in its own line; the user's is Q1 ("Default"), on which D2 and D7–D10 rest; the manager's D5 (review finding R2.2), D8 (R2.4 and the PR #7 review comment), D18 and D20 (kept on R2.3); `effort` spent. Marked in place: `[feature-model-switch/plan.md D2]` and `D8` superseded (by D9 and D2); `[feature-model-switch/plan.md D1]` amended by D2 and D9, `D11` by D11, `D14` by S8, `D20` extended by D10; `[flow-master-plan/plan.md D35]` amended by D6; `[flow-planner/plan.md D9]`, `D21`, `[flow-master-plan/plan.md D36]` and `[flow-cheaper-rounds/plan.md D28]` noted as carried out.
  - [flow-models-per-role/plan.md E1] Evidence → `E4`, `E6`, `E9`, `E12` under *Known limits and not verified*, `E1` and `E2` also in the re-read `[feature-model-switch/plan.md I1]` and `I4`; `E1`–`E3`, `E5`, `E7`, `E8`, `E10`, `E11`, `E13` were that change's readings, baselines and searches, and their conclusions are in the decisions they support (`D3`, `D4`, `D6`, `D13`, `D16`, `D20`), `E7` also in *Agents* above. *Boundary*, rejected: `B1` (the table passed per dispatch from Rule 5, no frontmatter — the default would live in the manager's memory) and `B5` (no planner agent, the generic agent dispatched with `model: opus`) → D2 and D4; `B2` → D6; `B3` (full model IDs) → D3; `B4` (a `/glab:plan-check` command) → D8.
  - [flow-models-per-role/plan.md FU1] Follow-ups → `FU1` (the `Skill` gap of every agent with a `tools` list but `glab:planner`, `glab:plan-analyzer`, `glab:analyzer` and `glab:reviewer` among them, D20 and R2.3), `FU2`, `FU3` open; `FU4` closed by this record; `[flow-models-per-role/result.md FUa]` closed by R2.7; closed, as `master.md` *Record* names: `[flow-planner/plan.md FU1]`, `[flow-cheaper-rounds/plan.md FU1]` (D4, D6), `[flow-cheaper-rounds/follow-ups.md FUc]` (D2, D6, D9) and `[feature-docs-specs/follow-ups.md 5]` (D12); re-read, still open: `[flow-cheaper-rounds/follow-ups.md FUa]` and `[subagent-effort/result.md finding-4]`.
  - [flow-models-per-role/plan.md I1] Live test → `I1`, the user's, not run, under *Known limits* (`master.md` *Final check* item 3: `UNVERIFIED` until run).
  - Incidents → none: no file in the folder records one.
  - [flow-models-per-role/result.md B0] Result → every step (B0, S1–S9, A1, A2) done, nothing blocked; A3 (back out: `git revert <commit>`, installed copies follow only past `0.12.0`) not run; I1 the user's. Unplanned changes (`[flow-models-per-role/result.md unplanned]`) → wording adaptations the steps' literal text forced, no file outside the plan's list: `plan-analyzer.md`'s copied *Step 4* headed *Step 2*, its master-check exceptions, its `BLOCK` for "a check that is not yours"; in `analyzer.md` *Re-checks* the plan-check `diff -u` removed with its file pairs; Rule 5 (f) "as the next bullet says" for "as (g) says", and D12's clause in the same sentence; Rule 5 (c)'s carry list with "each analyze round" and "through a `/glab:` command or directly"; dashes and full stops in Stage 2, Stage 5, `develop.md`, `review.md`, `ship.md` and `plan.md`. No test added; the two suites unchanged (`PASS 35/35`, `PASS 24/24`); coverage → `[flow-models-per-role/plan.md Tests]`. Blast radius (`[flow-models-per-role/result.md blast-radius]`) → every installer that updates to `0.12.0` runs and pays for the table's models; `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the agents; `/glab:plan` dispatches an agent instead of planning in the invoking session; no script, hook, schema or stored format changed. *Not done* (`[flow-models-per-role/result.md not-done]`) → I1, `E12`, and the listing order (`E6`), under *Known limits*.
  - [flow-models-per-role/result.md R1.1] Review round 1 (normal tier, the one round; text fixes only, `glab` stays `0.12.0`) → `R1.1` (`planner.md` "for every amendment"), `R1.2`, `R1.3`, `R2.5`, `R2.6` (wording of the two analyzers' report and re-check lines, `unverified` among the plan-analyzer's statuses), `R1.4` (a stage session's model, *The model rule*), `R1.5` (`plan-analyzer.md` on the mapping/evidence/round-copy *One fact* entry "(all but the version copies)", `docs/specs/marketplace.md`), `R2.1` and `R2.2` (`glab:planner`'s writes and `tools`, D5), `R2.3` not fixed (D20, `FU1`), `R2.4` (`/glab:analyze`'s routing, D8), `R2.7` (Rule 5's "chose them for cost" and the example line, `FUa` closed), `R2.8` (the dispatch table's default row), `R2.9` (`README.md` "From Claude Code v2.1.251"), `R2.10` (the Rules 0d and 5 clause in three commands and two *One fact* entries). V1's second check changed by R2.2 (`planner.md` now has a `tools:` line) and V9's meaning by R2.4; the gates after the fixes green as `AGENTS.md` states them. `AGENTS.md` at `09d5664` also lists `plugins/glab/commands/plan.md` in both entries R2.10 extended, which `result.md` R2.10 says it is in neither; no file in the folder records that addition.
  - PR #7 review → a named plan or master check routes to `glab:plan-analyzer` before the folder test, because an amended plan keeps its earlier `result.md`; fixed in `517b7b6` (`plugins/glab/commands/analyze.md:6`) with D8 updated in place in `plan.md` — *Agents* above. PR #7 merged on 2026-11-12 as `09d5664` and `517b7b6` (`gh pr view 7`).
  - [flow-models-per-role/master.md Record] Record → this record, in this file and `docs/specs/marketplace.md` (the gates' `Agents (7)` and the model gate, the *One fact* changes, `glab` `0.12.0`); no audit file.
- 2026-11-13 · flow-commands-to-skills · the commands become stage skills and every rule gets one owner: `plugins/glab/commands/` removed, seven commands moved with `git mv` to `plugins/glab/skills/<name>/SKILL.md`, which `glab:manager` invokes itself and a person can type; `glab:plan-first` merged into `glab:plan` (Steps 0–4, plan only), `implement.md` and `commands/plan.md` removed, Stage 1 dispatching `glab:planner`, a typed `/glab:plan` planning in the user's session; shared skills preloaded through each agent's frontmatter `skills:`; Rule 0c's dispatch of task facts only; Rule 5's report-template paste and version history out of the manager; the session-start text and `glab:bootstrap` shrunk to their own rules; `glab` 0.13.0 · change 6f8b948 · plan: `git ls-tree -r --name-only 6f8b948 -- plan/flow-commands-to-skills/` (one file: `git show 6f8b948:plan/flow-commands-to-skills/<file>`; the whole folder: `git archive 6f8b948 plan/flow-commands-to-skills/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `6f8b948` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-commands-to-skills/`; PR #9, merged with rebase on 2026-11-13, `gh pr view 9`): the folder is removed in the record commit. It holds 31 files: `plan.md` (normal tier, no `master.md`: the installed workflow planned it), its six steps files `steps-stages.md`, `steps-agents.md`, `steps-manager.md`, `steps-bootstrap.md`, `steps-shared.md`, `steps-repo.md`, the three audits `audit-a-model.md`, `audit-b-agents.md`, `audit-c-shared.md`, the plan checks `check-repo.md`, `check-facts.md`, `check-repo-2.md`, `check-facts-2.md`, `questions.md`, `review-1.md`, `result.md`, `follow-ups.md`, and round copies — `plan.r1.md`, `plan.r2.md`, `questions.r1.md`, and `.r1.md` and `.r2.md` of every steps file but `steps-bootstrap.md` (the record takes its items from the current files).
  - [flow-commands-to-skills/plan.md Decisions] Decisions → `Q1`, the merge ("Yes, merge them"), FU1-1 to FU1-4, the preload lists, restatements, invocation, frontmatter, constants, B23, A30, cases, A13, B16, A5, C12, voice, waiver, `spent`, and the user's principle (request 2), above under *Decisions that still bind*; the review's A2 (the user's "Plan in my session") and its other standing decisions as `[flow-commands-to-skills/review-1.md A2]` and `[flow-commands-to-skills/review-1.md decisions]`. The version, the *One fact* changes, the commit-scope list and the `README.md:164` exception → `docs/specs/marketplace.md`. Marked in place: superseded `[feature-model-switch/plan.md D17]`, `D21`, `[subagent-effort/plan.md D4]`, `[flow-cheaper-rounds/plan.md D55]`, `[flow-planner/plan.md D7]`, `D8`, `[flow-models-per-role/plan.md D10]` in part; lapsed `[sync-local-edits/result-followups.md D8]`; amended `[feature-model-switch/plan.md D7]`, `D12`, `D20`, `[sync-local-edits/result-followups.md D5]`, `D12`, `[bug-reviewer-findings/questions.md Q7]`, `Q10`, `[feature-docs-specs/plan.md D34]`, `[subagent-effort/plan.md D5]`, `[flow-master-plan/plan.md D40]`, `[flow-models-per-role/plan.md D4]`, `D5`, `D8`, `D18`, `D20`.
  - [flow-commands-to-skills/plan.md Findings] Findings → `F4`, `F12`, `F13`, `I1`–`I5` in *How it works now* and *Known limits*; `F1`–`F3`, `F5`–`F11`, `F14`–`F19` were that change's baselines, readings and searches, their conclusions in the decisions; *Rejected boundaries* → the invocation and preload-list decisions (`disable-model-invocation`, `commands/` kept beside the skills, `glab:plan-first` beside a thin wrapper, a `plugin.json` key, rules copied per agent, `Skill` in each `tools`, a master with sub-plans). *Disposition*: 62 applied, 19 merged, none rejected; the plan-check findings R1–R11, F1–F11, R2-1–R2-6, F2-9, F2-10 fixed in the plan before the build.
  - [flow-commands-to-skills/plan.md U1] Not verified → `U1`–`U8`, under *Known limits*; `[flow-commands-to-skills/plan.md Tests]` there too.
  - [flow-commands-to-skills/follow-ups.md FU-1] Follow-ups → `FU-1`, `FU-2`, `FU-3` open, above. Closed by this change: `[flow-models-per-role/plan.md FU1]` (in the tree; runtime U4, U5), `[sync-local-edits/follow-ups.md 15]`, `16`, `17`, `[bug-reviewer-findings/follow-ups.md 16]`, `[subagent-effort/result.md finding-4]`, `[flow-master-plan/follow-ups.md DEV3]`. Re-read, still open: `[sync-local-edits/follow-ups.md 7]`, `13`, `14`, `[bug-reviewer-findings/follow-ups.md 18]` (half), `19`, `[bug-reviewer-findings/result-review1-prose.md L109]`, `[bug-reviewer-findings/result-slice2.md L99]`, `[feature-docs-specs/follow-ups.md 2]`, `4`, `[feature-docs-specs/result-SM.md 3]`, `[subagent-effort/plan.md F1]`, `[subagent-effort/record.md round-2-ultra]`, `round-2-pipeline-default`, `[flow-cheaper-rounds/follow-ups.md FUa]`, `[flow-master-plan/follow-ups.md DEV1]`, `DEV2`, `[flow-models-per-role/plan.md FU2]`.
  - [flow-commands-to-skills/questions.md Q1] Q1 → `[flow-commands-to-skills/questions.md Q1]`, A.
  - [flow-commands-to-skills/review-1.md] Review round 1 (two reviewers, 7 and 10 findings) → 14 fixed in fix round 1 (A1, A3, A4, A5/B2, A7/B4, B1, B5–B9, the two repeats at `manager:342` and `:346`), B10 no change, A2, A6 and B3 stopped as `PLAN WRONG` and settled in part 2 (*Incidents*); each fix in its owner, *How it works now*.
  - [flow-commands-to-skills/result.md Stages] Result → every step (B1–B3, P1, P6–P9 with the six steps files, A1–A5) done, nothing blocked, no unplanned change; 140 edits, 171 post lines `ok`; A1's gates green as recorded there and run again for this record (`docs/specs/marketplace.md`); *Not done* → U1–U8, and the `claude --version` run → *Incidents*; the fix round's UNVERIFIED → `[flow-commands-to-skills/result.md fix-round-2]`.
  - Incidents → the platform outage (from the manager's Stage 8 dispatch), the `claude --version` run, and the three `PLAN WRONG` stops, above under *Incidents*.
  - [flow-commands-to-skills/plan.md Record] Record → this record, in this file and `docs/specs/marketplace.md`; no audit file.
- 2026-11-13 · flow-product-level · recorded in `docs/specs/product.md`, its primary area, new with this record; here, the project level's edges: the rules every manager shares moved, words kept, into `glab:session-rules`; each manager's explicit skill list as the level boundary; the `glab-level:` line and the session-start text by level; project Stage 1c and `glab:develop`'s product-verdict precondition; nine agents and the pipeline's row 1c; `glab` 0.14.0 · change ce1a933 · plan: `git ls-tree -r --name-only ce1a933 -- plan/flow-product-level/` (one file: `git show ce1a933:plan/flow-product-level/<file>`)
  - Decisions → `session-rules`, `level-line`, `report-brief`, `boundary`, `rules-move`, `once-per-slug` and `rejected`, with the user's words behind G2 and G3 quoted in `master.md` *Request*, above under *Decisions that still bind*; the others in `docs/specs/product.md`.
  - Follow-ups → altered by this change, re-read at `ce1a933`: `[flow-commands-to-skills/follow-ups.md FU-3]` (the planner now needs `glab:manager` and `glab:session-rules`), `FU-2`, `[sync-local-edits/follow-ups.md 7]`, `13`, `14`, `[subagent-effort/plan.md F1]`, `[subagent-effort/record.md round-2-ultra]`, `round-2-pipeline-default`, `[flow-cheaper-rounds/follow-ups.md FUa]`, `[flow-master-plan/follow-ups.md DEV1]`, `[feature-docs-specs/result-SM.md 3]` — all still open, above; none closed. The change's own follow-ups are in `docs/specs/product.md`.
  - Incidents → the `git add -N` slip and the two `NOT BUILDABLE` plan check rounds, above under *Incidents*; the uutils `mkdir` and the move to `set -C` in `docs/specs/product.md`.
  - Record → this record, in `docs/specs/product.md`, this file and `docs/specs/marketplace.md`; no audit file.
- 2026-11-18 · flow-project-level · the project level renamed `glab:project-*` (01), the shared rules slimmed with `glab:severity` and a handoff file per session (02), and `glab:project-manager` split into its stage skills (03); `glab` 0.15.0 · change db5feae (01 `0c49626`, 02 `0cfe335`, 03 `db5feae`) · PR glab-services/skills#15 (rebase) · final check `CONFORMS` (G1–G6) · plan: `git ls-tree -r --name-only db5feae -- plan/flow-project-level/` (one file: `git show db5feae:plan/flow-project-level/<file>`)
  - Decisions → `index.md` D5–D12, D14, D17, D21–D27, D30, 02 W5, W7, W10 and 03 W1, W2, above under *Decisions that still bind*.
  - Follow-ups → new, open above: D13 (F27), D11 (F11), D20, 02 W8, 03 W10, the `get_usage` measure, D27, and 03's FU2–FU4 and its second FU2–FU4, tagged `(second)`; later-1 and later-2 point at `[manager-flow-notes.md later-1]` and `later-2` in `docs/specs/product.md`, still open, not new. Closed: 03 FU1, 02's two, and `[flow-commands-to-skills/follow-ups.md FU-3]`, `FU-2`, `[feature-docs-specs/follow-ups.md 4]`. Altered, still open: `[subagent-effort/plan.md F1]`, `[flow-cheaper-rounds/follow-ups.md FUb]`, `[flow-master-plan/follow-ups.md DEV1]`, `DEV2`, `[bug-reviewer-findings/follow-ups.md 19]`.
  - Incidents → the disk at 0 bytes, 03's `NOT BUILDABLE` round 1, 03's review scope cut, the agents' overruns, 02's prose run as bash, above under *Incidents*.
  - audit → the F1–F27 map, kept here because `audit.md` is not edited (the folder stays identical to `origin/main` until its removal): F1, F2 03 P1–P12; F3 03 P13, P14; F4 03 P1, P13; F5 03 P6; F6 02 P6, P7; F7 03 P3, P6, P8, P12; F8 02 P7, P9 (the manager's sentence left to 03, whose map does not name F8); F9 02 P7, P9 and 03 P5, P8, P10, P12; F10 02 P5; F11 03 P3, dropping them a follow-up; F12 03 P6, P8, P9; F13 01 P3 (R4, R7); F14, F15 03 P12; F16 03 P5; F17 03 P12, P15; F18 03 P5, P16; F19 03 P11, P15; F20 03 P2; F21 03 P12; F22 02 P9; F23 03 P17; F24 01 P5; F25 02 P7; F26 02 P7, P9 and 03 P12, P13; F27 left, a follow-up (D13). Maps: 01 `plan.md` :5, 02 *Findings placed*, 03 *Record*.
  - Record → this record, in this file, docs/specs/marketplace.md and docs/specs/product.md; no audit file.
- 2026-11-18 · docs-lifecycle · 3ed6746 · 3ed6746 · docs-lifecycle · #19
  - PR #19 (glab-services/skills), rebase-merged onto `main` as `d2ca05b` on 2026-11-18 (`git diff --quiet 3ed6746 d2ca05b` exits 0: the same tree). `glab` 0.16.0: `/plan/` ignored and never committed; the record writes specs and feature pages; the *Records* line in its new form; Rule 2's plan-folder approval, run at `glab:bootstrap` step 5; P7 Roadmap at the product level (`docs/specs/product.md`). The plan folder was not kept in git: this line and the specs are its record.
  - [docs-lifecycle/plan.md Decisions] Decisions → U1 (the user's), M3, D2–D8, D15–D18, D22–D27, D42 and D45 above under *Decisions that still bind*, D5 carrying D23, D25, D35–D38; M2, D9–D14, D29, D33, D43 in `docs/specs/product.md`; M1, M4, D1, D19–D21, D39, D41 and D44 in `docs/specs/marketplace.md` (D44 also under *Incidents*); D32 in the A3 line below; D28, D30, D31, D34 and D40 were that plan's post-conditions and evidence, their results in `result.md`'s post-conditions.
  - [docs-lifecycle/plan.md Evidence] Evidence → `E11` and `E13` under *Known limits*; the plan's three UNVERIFIED items: the gates baseline (answered: `PASS 31/31` at B1 and in every later run), the 1024-byte description limit and E9's cited lines, in `docs/specs/product.md`; `E1`–`E10`, `E12` were that change's baselines and searches, their conclusions in the decisions.
  - [docs-lifecycle/check.r1.md] Plan check round 1 (`NOT BUILDABLE`, F1–F12) → D23–D34; F1 under *Incidents*. [docs-lifecycle/check.r2.md] Round 2, the cap (`NOT BUILDABLE`, N1–N9) → D35–D43; N1 and N2 under *Incidents*, no third round (D44).
  - [docs-lifecycle/review.r1.md] Review round 1 (`FIX`, ten findings) → 1–9 fixed (D45; 1 and 2 under *Incidents*), 10 accepted, open above. [docs-lifecycle/review.r2.md] Review round 2, the last (`SHIP`) → 1–9 fixed; four lows open above; its *record-branch* inference under *Known limits* and open above.
  - [docs-lifecycle/result.md Stages] Result → B1, P1–P22 (P11a, P17a included) done, nothing blocked; unplanned change: `project-record/SKILL.md:9` names `docs/features/` (for PC10's count of 5), and PC5's `ls -d`; PC1–PC28 at their expected values but PC12, which waits for this record and A3; `PASS 31/31`. Follow-ups → the two closed above, the two product ones in `docs/specs/product.md`, the review-round-1 one open above. *Not done* → the UNVERIFIED live run, under *Known limits*.
  - A3 (the folder's removal, on U1's authority, `[docs-lifecycle/plan.md D32]`, as the 0.16.0 Rule 2 text may not be installed in the session that runs it) is not part of the record and was not done here; see `[docs-lifecycle/review.r2.md record-branch]`. Gates for this record: `PASS 31/31`, exit 0, at `d2ca05b`.
  - Record → this record, in this file, `docs/specs/product.md`, `docs/specs/marketplace.md` and the new `docs/features/docs-lifecycle.md`; no audit file.
- 2026-11-18 · lifecycle-hardening · bf9c73f · bf9c73f · lifecycle-hardening · #22
  - PR #22 (glab-services/skills), not merged at this record; `glab` 0.16.2. Rule 2's plan-folder removal on the user's word, asked once per folder at `glab:bootstrap` step 5, with the listing's facts; the record committed on the change's branch; the record check's and the reviewer's paths; at the product level the P6 test, `## Delivered` after the last `## Approval` and the brief's precondition (`docs/specs/product.md`); `AGENTS.md`, the *One fact* entry and the version (`docs/specs/marketplace.md`). This record is committed on `lifecycle-hardening`, before the merge (`D3`). The plan folder was not kept in git.
  - [lifecycle-hardening/plan.md Decisions] Decisions → `D26`, `D27`, `D3`, `D4` (its workflow half), `D6`, `D7`, `D9`, `D11`, `D15`, `D22` above under *Decisions that still bind*; `D23`, `D1`/`D1b`, `D2`, `D8` (with `D12`, `D13`, `D16`, `D18`, `D19`), `D17`, `D24` items 1, 2 and 4, and `D25` kept there, marked superseded by `D26`/`D27`; `[docs-lifecycle/plan.md U1]`, `D5`, `D25`, `D42`, `D45` and the 0.16.0 approval bullet marked superseded, their text kept; `D4`'s `p7-delivery-gate` half, `D10`, `D14`, `D20`, `D21` and `D24` item 3 in `docs/specs/product.md`; `D3`'s *One fact* entry and `D5` in `docs/specs/marketplace.md`.
  - [lifecycle-hardening/plan.md Findings] Findings → `F1`–`F8` were that change's readings; their evidence (a)–(d), round 3's S1/S5, the date and `cp -p` runs is cited in the decisions and *Incidents*.
  - [lifecycle-hardening/check.r1.md] Plan check round 1 (`NOT BUILDABLE`, H1, M1–M5, L1–L4) → `D8`–`D16`; H1 under *Incidents*. [lifecycle-hardening/check.r2.md] Round 2, the cap (`NOT BUILDABLE`, N1–N5) → `D17`–`D21`; N1 under *Incidents*, no third round (`D22`).
  - [lifecycle-hardening/review.r1.md] Review round 1 (`FIX`, findings 1–4) → fixed (`D24`); 1 under *Incidents*. [lifecycle-hardening/review.r2.md] Review round 2, the last (`FIX`, the reviewer's `SHIP WITH SCOPE CUT`) → its two findings moot by `D26`; the amended and rewritten squash under *Incidents*. [lifecycle-hardening/review.r3.md] Review round 3, after the `D26` rework (`SHIP`) → six lows open above (6 in `docs/specs/product.md`); its UNVERIFIED and not-checked items under *Known limits*; its `/tmp/.x` note under *Incidents*.
  - [lifecycle-hardening/result.md Stages] Result → Steps 1–7 done, then the review-round-1 fixes and the `D26` rework; nothing blocked; unplanned changes of the rework: `README.md`, `docs/features/docs-lifecycle.md`, `project-plan/SKILL.md`, `audit/SKILL.md`, `security/SKILL.md`, each stating the removal or counting Rule 2's approvals (16 files in `bf9c73f`, not the plan's 11); the stale post-condition values in `result.md` *Review r1 fixes* and *D26 rework*; gates `PASS 31/31`, exit 0, at every run. *Not done* → under *Known limits*. Its `FU1` (`follow-ups.md`), closed by `D24` item 3, in `docs/specs/product.md`.
  - Follow-ups → closed: `[docs-lifecycle/review.r1.md 10]`, `[docs-lifecycle/review.r2.md record-branch]`, `project-record:13`, `session-rules:87`, `session-rules:91,93`, `project-record:12` and `[docs-lifecycle/result.md review-r1-follow-up]`, moved to *Closed follow-ups*; `[p7-delivery-gate/review.r1.md 1]`–`3` and `FU1` in `docs/specs/product.md`. Open: `[lifecycle-hardening/review.r3.md 1]`–`5` above, `6` in `docs/specs/product.md`.
  - Security → no secrets; no script or hook contract changed (`plan.md` tier line; `review.r3.md`: no secret added, no comment or incident removed).
  - Record → this record, in this file, `docs/specs/product.md`, `docs/specs/marketplace.md` and `docs/features/docs-lifecycle.md`, shortened to 2047 bytes (`docs/specs/marketplace.md` *Records*); no audit file.
- 2026-11-19 · level-guard · 632dcb0 · 632dcb0 · level-guard · #24
  - PR #24 (glab-services/skills), not merged at this record; `glab` 0.17.0. Recorded in `docs/specs/product.md`, its primary area (the hook, its decisions, the live test, the `by user` hold); here, the project-level edge: a project session's Skill calls to `glab:product-*` skills are refused by the `PreToolUse` hook `level-guard.sh`, which reads each manager's *Your skills* list and the level through `glab-level.sh`, shared with `manager-bootstrap.sh`, and the new paragraph of `glab:session-rules` *The level boundary* (*The level guard as of 0.17.0*); the version, the gates and `AGENTS.md` in `docs/specs/marketplace.md`. The plan folder was not kept in git.
  - [level-guard/plan.md Decisions] Decisions → `D2`, `D3`–`D5`, `D8`–`D10` named in *The level guard as of 0.17.0*, their text in `docs/specs/product.md` *Decisions that still bind*; `[flow-product-level/plan.md boundary]` and the level-boundary bullet amended, their text kept.
  - Not verified → the project-side refusal shown offline only, FU-LG5, FU-LG6, the prose, above under *Known limits*.
  - Follow-ups → `[flow-product-level/plan.md FU-P2]` closed in `docs/specs/product.md`; FU-LG1 and FU-LG5 pointed at above, open; the others in `docs/specs/product.md` and `docs/specs/marketplace.md`.
  - Incidents → none at the workflow level; the change's are in `docs/specs/product.md` *Incidents*.
  - Record → this record, in this file, `docs/specs/product.md`, `docs/specs/marketplace.md` and `docs/features/level-guard.md`; no audit file.
- 2026-11-19 · remote-store · 0634bd5 · 0634bd5 · remote-store · #25
  - PR #25 (glab-services/skills), not merged at this record; `glab` 0.18.0. Recorded in `docs/specs/product.md`, its primary area (the store clone, `plan-gate.sh`'s git path and `sync`, the tests); here, the project-level edge: the planner syncs before it reads a brief and may run that sync, `glab:project-plan-report` commits and pushes the store through `plan-gate.sh` and syncs on resuming, `glab:session-rules` Rule 3 bars the store push from the confirmation before every push, and the `project-planner` set re-measured (*The store sync as of 0.18.0*, the G5 table); the version, the contract and the gates in `docs/specs/marketplace.md`. The plan folder was not kept in git.
  - [remote-store/plan.md Decisions] Decisions → `D19`, `D28`, `D34`, `D37` and `D38` named in *The store sync as of 0.18.0*, their text in `docs/specs/product.md` *Decisions that still bind*.
  - Not verified → the project side of a store clone, shown by the text only, above under *Known limits*.
  - Follow-ups → open: `[remote-store/follow-ups.md FU-RS2]` and `FU-RS11` above; the others in `docs/specs/product.md` and `docs/specs/marketplace.md`; `[level-guard/follow-ups.md FU-LG4]` amended in `docs/specs/product.md`.
  - Incidents → none at the workflow level; the change's are in `docs/specs/product.md` *Incidents*.
  - Record → this record, in this file, `docs/specs/product.md`, `docs/specs/marketplace.md` and `docs/features/remote-store.md`; no audit file.
