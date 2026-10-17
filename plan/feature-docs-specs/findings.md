# Findings — feature-docs-specs

Planner, 2026-10-17; amended after Stage 1b round 1/2 (*Amendment* below).
Base: `main` = `origin/main` = `6838133`. When first written, `main` was three
commits ahead of `origin/main` = `5e9b3a8`; the user has since approved the
push, and `git log --oneline -1` and `git rev-parse --short origin/main` both
printed `6838133` at the amendment. Tree clean but for the untracked
`plan/SESSION-HANDOFF.md` and this folder. `AGENTS.md` read from disk:
its gate line C7 (`:59`) greps `Not yet shown: any reply from a DeepSeek model`.

Every "proven" below names the command that showed it. "Inferred" is reasoning
from text, not a run. The planner's Write of this file into `plan/` was
refused; it was written under `/data/tmp/claude/feature-docs-specs-plan/`
with `plan.md`, `questions.md` and `check.sh`, for the manager to copy into
`plan/feature-docs-specs/` (`SHA256SUMS` beside them).

## Path list — what the change touches or depends on

New: `docs/specs/marketplace.md`, `docs/specs/workflow.md`,
`docs/specs/memory-sync.md`, `docs/specs/external-agents.md`
(`ls docs` → `No such file or directory`). Under Q1 = B also
`docs/notes/external-agents/` (five files).

Changed, payload (`plugins/glab/`, so its `plugin.json` is raised):
`skills/plan-first/SKILL.md`, `skills/manager/SKILL.md`,
`skills/bootstrap/SKILL.md`, `skills/audit/SKILL.md`, `commands/plan.md`,
`commands/commit.md`, `commands/push.md`, `agents/committer.md`,
`agents/developer.md`, `agents/analyzer.md`, `scripts/manager-bootstrap.sh`
(hook text), `scripts/external-agent.sh` (comments only),
`skills/external-agents/profiles/{kimi,glm,deepseek-pro,deepseek-flash}.md`
(their `## Notes` only), `.claude-plugin/plugin.json`.

Changed, repo: `AGENTS.md`, `README.md`.

Removed: the seven folders, 124 tracked files
(`git ls-files plan | awk -F/ '{print $2}' | sort | uniq -c`):

| folder | files | change commits | record commits | last commit holding it |
|---|---|---|---|---|
| `bug-reviewer-findings` | 10 | `96b44cf` `a8f0851` `c3911b6` | `2aeb46d` | `2aeb46d` |
| `feature-plugin-marketplace` | 8 | `97d0d50` `93deb5b` `2e34cbe` `f19f7f0` | `b853635` | `b853635` |
| `sync-local-edits` | 3 | `5f69d65` `70166f4` | `0dec5e2` `9700bcb` | `9700bcb` |
| `feature-model-switch` | 2 | `1f12a37` | `889b804` | `889b804` |
| `feature-opencode-worker` | 96 | `7139e62` | `8cb2a92` `5e9b3a8` `51043c4` | `51043c4` |
| `fix-external-report-lines` | 2 | `167f432` | `5e9b3a8` | `5e9b3a8` |
| `fix-probe-findings` | 3 | `5321d76` | `6838133` | `6838133` |

"Last commit" is `git log -1 --format=%h -- plan/<slug>` (run per folder).
`51043c4`, `5321d76`, `6838133` were not on `origin` when this was first
written; they are now (`origin/main` = `6838133`).

Unchanged and depended on: `plugins/memory-sync/**` (no `plan/` citation in
the survey below), `tests/*.sh` (no record citation: no match for `plan/`,
`findings-r3`, `probe-r3` or `plan-r3`), `host.example.md`,
`.claude-plugin/marketplace.json`, `plugins/glab/skills/external-agents/SKILL.md`
(no `plan/` and no record citation), `plan/SESSION-HANDOFF.md` (untracked, stays).

## Every `plan/` occurrence outside `plan/`, by file:line

Survey: `git ls-files | grep -v '^plan/' | xargs grep -n 'plan/'` (system grep).
Counts match the brief: AGENTS 4, README 2, analyzer 5, developer 7,
integrator 3, analyze 2, develop 3, integrate 2, plan 2, external-agent.sh 3,
audit 7, bootstrap 1, the four profiles 3 each, manager 7, plan-first 9.

**G** = the generic `plan/{slug}/` workflow path: stays. **C** = a citation of
this repo's records: repointed. **L** = a lifecycle statement: changed.

| file:line | text (short) | kind | action |
|---|---|---|---|
| `AGENTS.md:16` | `` `tests/`, `plan/`, `host.example.md` … belong to the repo `` | L | Layout gains `docs/specs/`; `plan/` is the working area (step R2a) |
| `AGENTS.md:78` | C7 bullet `(plan/feature-opencode-worker/probe-r3.md)` | C | → `` `docs/specs/external-agents.md` *Live runs* `` (R2b) |
| `AGENTS.md:108` | `plan/feature-opencode-worker/plan-r3.md` *After* (offline run) | C | → `` `docs/specs/external-agents.md` *Offline run* ``; the whole rule rewritten (R2c) |
| `AGENTS.md:187` | `` `plan/` is tracked and permanent. `` | L | the new rule (R2e) |
| `README.md:54` | `(plan/feature-opencode-worker/probe-r3.md)` | C | → spec *Live runs* (R1b) |
| `README.md:219` | `` | `plan/` | Planning records | `` | L | reworded, plus a `docs/specs/` row (R1c) |
| `agents/analyzer.md:3,15,16,17,67` | description; read list; plan revision | G | stay; Step 3 gains one sentence (P8) |
| `agents/developer.md:3,16,17,18,66,114` | description; read list; `result.md` | G | stay |
| `agents/developer.md:38` | `follow-ups.md` "and stays there" | L | P7 |
| `agents/developer.md:99` (no `plan/`) | "`result.md` and `follow-ups.md` are the two files … you do write" | L | P7 |
| `agents/integrator.md:3,11,53` | description; `plan.md`; `integration.md` | G | stay |
| `commands/analyze.md:6,8` | `plan/$ARGUMENTS/` | G | stay |
| `commands/develop.md:6,13,14` | `plan.md`; `waived.md`; `questions.md` | G | stay |
| `commands/integrate.md:6,14` | `plan/$ARGUMENTS/` | G | stay |
| `commands/plan.md:13,16` | `questions.md`; `waived.md` | G | stay; the report line `:18` gains the area spec (P3) |
| `scripts/external-agent.sh:35` | `(plan/feature-opencode-worker/findings-r3.md)` | C | → spec *Isolation* (P12) |
| `scripts/external-agent.sh:193` | `(plan/feature-opencode-worker/questions.md, Q1)` | C | → spec *Allowlist* (P12) |
| `scripts/external-agent.sh:687` | `(plan/feature-opencode-worker/probe-r3.md, finding 1)` | C | → spec *Live runs* (P12) |
| `skills/audit/SKILL.md:3,8,26,31,32,33,67` | the audit file lives in `plan/` | G | stay; *After Writing* gains item 4 (P11) |
| `skills/bootstrap/SKILL.md:120` | `plan/SESSION-HANDOFF.md` | G | stays; step 5 gains an area-spec bullet (P9) |
| `profiles/deepseek-flash.md:30,31,46` | `notes/deepseek-flash.md`, `notes/diff.md`, `probe-r3/` | C | per Q1; `probe-r3/` → spec *Live runs* (P13) |
| `profiles/deepseek-pro.md:29,30,46` | the same for `deepseek-pro` | C | P13 |
| `profiles/glm.md:29,30,46` | the same for `glm` | C | P13 |
| `profiles/kimi.md:30,31,50` | the same for `kimi` | C | P13 |
| `skills/manager/SKILL.md:81,91,127,141,168,271,352` | `result.md`; `## Decisions`; `questions.md` | G | stay; `:81` gains "except for the record" (P2) |
| `skills/plan-first/SKILL.md:3` | description | L | P1 |
| `skills/plan-first/SKILL.md:23,57,63,171,177,178,179` | findings, questions, plan, waiver, quick reference | G | stay |
| `skills/plan-first/SKILL.md:109` | `follow-ups.md` "and stays there" | L | P1 |

Short record citations without `plan/`
(`grep -nE 'findings-r3|probe-r3|plan-r3|questions-r3'` outside `plan/`):
`external-agent.sh:55,96,209,226,540` — `(findings-r3)` → `(spec, *Measurements*)` (P12).
`external-agent.sh:618` — "found in the prototype" says where an incident was
seen, not a path: it stays (`AGENTS.md` *Comments and recorded incidents are kept*).

Other lifecycle statements in the payload (no `plan/` string in them):

- `skills/plan-first/SKILL.md:154` — **already** reads "Plan files are working
  files … the plan folder is then removed under the repo's own rule for that.
  A repo that keeps no specs, or keeps specs but has no rule for removing plan
  folders, keeps its plans. Never remove an untracked plan file." Committed in
  `5f69d65` (`git log -S'Plan files are working files' --oneline`). The new
  default flips "keeps its plans" to "records in `docs/specs/` and removes the
  folder after the push".
- `skills/manager/SKILL.md:196` — tier-table row
  `| Spec | — | a short entry: what it does, why, what is open | the same entry, checked by independent readers |`,
  with no stage, owner or place: `sync-local-edits/follow-ups.md` #10,
  reopened by that change's scope cut ("it dispatched the developer outside any
  plan step … and a re-dispatch overwrites `result.md`"). This change closes it.
- `skills/manager/SKILL.md:166-175` the pipeline table (stages 1–7);
  `:415-419` Stage 7; `:421-432` *What you never do*.
- `skills/bootstrap/SKILL.md:91` the pipeline diagram, ending `→  commit  →  push`;
  `:108` the commit/push bullet; `:115-124` step 5, the handoff.
- `scripts/manager-bootstrap.sh:17` (hook text) "Work moves through plan ->
  develop -> analyze -> integrate -> review -> commit -> push at full tier".
  The hook text is 2275 bytes (`awk` between its heredoc markers `| wc -c`),
  under the 10,000-character cap its header names. Bootstrap and the hook are
  one fact (`AGENTS.md` *One fact*: the session-start rules).
- `commands/push.md:87-89` *After*; `commands/commit.md:12`;
  `agents/committer.md:26-40` (staging: `git add <path>` only; `:62` never
  reset, amend, rebase).
- `docs/constants.md` (manager `:18,100,105,110,113,122,255,425`, bootstrap
  `:35`, hook `:14`) is a separate payload concept — decided facts — and this
  repo has none. Untouched.

## The seven folders — what each holds that must survive

Status: **open** as recorded; **closed** with its evidence; **open, not
re-checked** where only the record was read. The tag in brackets is the one
the spec carries (plan, *Spec rules*) and `check.sh` section 4 looks for.

### `bug-reviewer-findings` (2026-10-05: memory-sync fixes, agent text, host file)

- `follow-ups.md` 1–14 (`memory-sync.sh`) → `memory-sync.md`. 1 open
  (`memory-sync.sh:256` still `rsync -a --update --keep-dirlinks`); 2 open (cap
  still 17, `:48`); 10 open (`:227` still writes `$STAMP.next`); 5 open, not
  re-checked (`:106-113` now discuss a backward clock step — the developer
  reads them and says which); 3, 4, 6, 7, 8, 9, 11, 12, 13, 14 open, not re-checked.
- 15 → `marketplace.md`, **closed**: `AGENTS.md:142-143` list 17 and the 20 s timeout.
- 16 → `workflow.md`, changed since: `reviewer.md:73` and `integrator.md:39`
  now say "the temp directory the dispatch message names (the scratchpad only if
  it names none)". Recorded as changed, not as fixed.
- 17 → `marketplace.md`, open (`AGENTS.md:103` unchanged).
- 18 → `workflow.md`: the `developer.md:15` half is gone; the `commit.md:6` half
  still reads `— say so) — the commit format`: open.
- 19 → `workflow.md`, open (`bootstrap/SKILL.md:151` still "observed returning
  zero matches").
- 20 → `marketplace.md`, open (`ls .gitignore` → no such file; no Markdown gate).
- 21 → `marketplace.md`, **closed, superseded**: no `install.sh` is tracked;
  the plugin install replaced the copy install (`f19f7f0`, README *Coming from
  the copy install*).
- *Before adopting this on a machine* and *Unverified throughout* in
  `follow-ups.md`, and `plan.md` *A4* → `memory-sync.md` (the `host.md` bullet
  also named in `marketplace.md`).
- `questions.md` Q1 (live copies; deferred half = 21), Q4 (host file), Q5 (root
  `CLAUDE.md` and `AGENTS.md`), Q8 (scope) → `marketplace.md`; Q2 (deletion
  semantics; tombstones = 14), Q6 (portability), Q9 (push backoff) →
  `memory-sync.md`; Q3 (round cap), Q7 (missing-`AGENTS.md` fallback), Q10
  (hook wording) → `workflow.md`.

### `feature-plugin-marketplace` (2026-10-05)

- `questions.md` Q1 (marketplace name), Q6 (versioning), Q7 (root `CLAUDE.md`)
  → `marketplace.md`; Q2 (memory-sync names), Q3 (S3 settings), Q4
  (`SessionEnd` 1.5 s budget), Q5 (state files stay in the config dir) →
  `memory-sync.md`.
- `result-review1.md` *Follow-ups* 1 (plan values stale — closed: the plan is
  history), 2 (points at slice D's four), 3 (`:?` guards stop a script, not an
  interactive shell — closed: `AGENTS.md:62-65` say so) → `marketplace.md`.
- `result-slice-D.md` 1 (hedge gate — **closed**: gate line `AGENTS.md:58`),
  2 (the smoke-test fixes of item (b)), 4 (remove the hedge once the smoke test
  settles Q4) → `memory-sync.md`; 3 (stale ranges in the plan — closed: history)
  → `marketplace.md`.
- `result-slice-S.md` 1 (gate for the hedges — closed, `:58`), 4 (old fallback
  wording in the UNVERIFIED list — closed: history), 5 (version note —
  information) → `marketplace.md`; 2 (smoke-test row 10's Pass text), 3 (the
  cache layout, `.orphaned_at`, the "may" in `SKILL.md:12`) → `memory-sync.md`.
- `result-slice-G.md` UNVERIFIED (the hook fires from the plugin; prefixed names
  resolve) → `marketplace.md`.
- `plan.md` *UNVERIFIED* list (`:1897-1903`) → `marketplace.md`; *Smoke test*
  part 1 → `marketplace.md`, parts 2 and 3 → `memory-sync.md`. Part 3 has not
  run: the `not yet confirmed` hedge is in all three files (gate output below).

### `sync-local-edits` (2026-10-16: tiers, Rule 3, Rule 4)

- `follow-ups.md` 1–19 → `workflow.md`. 1–6, 8, 9, 11, 12 fixed (its *Status*
  table); 7 reopened (waiver routing); 10 reopened (the Spec row) — **this
  change closes it**: Stage 8 names the stage, the owner, the place, and what
  "independent readers" means; 13–19 open (`plan/SESSION-HANDOFF.md`: "#7,
  #10, #13–#19").
- `result-followups.md` D1–D12 and `result.md` *Decisions* → `workflow.md`.

### `feature-model-switch` (2026-10-16: Rule 5)

- `plan.md` D1–D22; `result.md` *Decisions*; I1 and I4 UNVERIFIED
  (`plan.md:34,36`; `result.md` *Not done*) → `workflow.md`. Its *Spec entry*
  (`plan.md:366-368`) feeds *How it works now*.

### `feature-opencode-worker` (2026-10-17: external agents)

- `follow-ups.md` 1–25 → `external-agents.md`. Closed by their own status
  lines: 3, 11, 13, 14, 15. Record-only, closed: 2 (post-condition hash), 4
  (mutants not re-run), 23 (record correction). 1 (a pasted `|| exit 1` closes
  the shell) closed by the rule "as a script, never pasted", and kept as an
  incident. 8 superseded by 12. Open: 5, 6, 7, 9, 10, 12, 16, 17, 18, 19, 20,
  21, 22, 24, 25.
- `questions.md` Q1 (which families may receive the code; Grok refused) and
  `questions-r3.md` Q2 (an external reviewer may gate a commit: A) → binding
  decisions; Q1 also feeds *Allowlist*.
- `plan.md` D1–D21, M1–M17 (rev 2) and `plan-r3.md` D22–D41, M1–M5 → carried
  or listed as spent.
- `plan-r3.md` *Not in this plan* 1–5 (the Codex adapter U12; an external
  developer U10; profile tuning; DeepSeek's end date 2026-10-31; slirp4netns
  `--enable-sandbox`) and *UNVERIFIED, in one place* → `external-agents.md`.
- `probe-r3.md` findings 1–6 and *Not verified*: 1 closed by `5321d76`; 2 open
  (= `fix-probe-findings/plan.md` 3); 3 the user's decision (DeepSeek left as
  is); 4 open (= FPF 2); 5 closed by `5321d76`; 6 information (7–9 minutes per model).
- `findings-r3.md` — the measurements the script comments cite
  (`external-agent.sh:55,96,209,226,540`): 2.0.31 reads only
  `~/.config/opencode` from `$HOME`; a turn ran at 1 GiB of data segment and
  aborted at 256 MiB; 128 tasks ran, 64 aborted (`:453-454`, untagged); 1.19.3
  read `auth.json` and `OPENCODE_AUTH_CONTENT`, 2.0.31 does not;
  `OPENCODE_API_KEY` also unlocks the paid provider; bwrap 0.11.1 nests the
  sandbox's user namespace inside the network namespace's owner → *Measurements*.
- `plan-r3.md` *Integrate — the real CLI, offline* (`:2570-2629`, one ````bash
  block, 22 lines, sha256 prefix `d587da19064fc0e9`) and *L1* (`:2753-2846`:
  the L1a block, 10 lines, `3a51b1f4db43f3a1`; L1b; L1c); `probe-r3/runner.sh`
  (34 lines, `207769ffe2de1783`: L1b and L1c, plus the transcript copy and the
  one exit-8 correction) → *Offline run* and *Live runs*. `AGENTS.md:106-111`
  and the C7 bullet depend on them.
- `notes/` (five files, the user's prompting notes, written by Qwen) — Q1.
- Raw records — `probe-r3/<model>/` transcripts and `run.log`, `recorded/`,
  `prototype/`, `prototype-r3/`, `rev2-build/`, `result.md`, `result-r3.md`,
  `integration-r3.md`, `findings.md` (rev 2), `SHA256SUMS-r3`: history keeps
  them; the spec names `51043c4`.

### `fix-external-report-lines` (2026-10-17)

- No follow-ups of its own (they went to `feature-opencode-worker/follow-ups.md`
  13–15 and 24). `result.md` UNVERIFIED (that a real model copies the indent)
  → `external-agents.md`: in the probe GLM passed the check first time and
  Kimi failed on the singular, not on the indent. `plan.md` *Decisions* → carried.

### `fix-probe-findings` (2026-10-17)

- `plan.md` *Follow-ups* 1 (`AGENTS.md:110-111`: the manager ran L1 at the
  user's instruction — **this change closes it** with the user's approved
  wording), 2 (`turns=2` after a refused start), 3 (L1b's `send` expectation),
  4 (re-tune the profiles = FOW 12) → `external-agents.md`.
- `result.md` *Follow-ups*: E49 pins the gap message `verdict says 1 issues` →
  `external-agents.md`.
- `plan.md` *Decisions* (user, manager, planner) → carried.

### Recorded incidents

The incidents narrated in these folders are nearly all tagged above (FOW 1
and 24; probe findings 1–4; the reasons `sync-local-edits` #7 and #10 were
reopened; the smoke test not run; rev 2's `external-worker` build archived and
replaced by rev 3). The others already live in the payload's own comments and
text, which this change does not delete (`external-agent.sh:614-618`, the
bootstrap hazards, `host.example.md`). Each spec gets an `## Incidents`
section; that it holds every incident cannot be checked by a command.

## Amendment — what Stage 1b round 1 added

- **Rule 5's duration (R2).** `grep -n -i "for this task\|task's push\|ends with"`
  over `manager/SKILL.md`, `develop.md`, `review.md`, `ship.md` and the
  `glab:external-agents` skill: only `manager/SKILL.md:126` states it
  ("\"For this task\" ends with that task's push"). A grep for `push`,
  `lasts` or `until the user` in the other four finds no duration either
  (`develop.md:68` and `ship.md:40` are about hand-offs and pushing).
- **Rev 2's P4 (M6).** `external-agent.sh:235` cites "(findings P4, re-proven
  on 2.0.31)": rev 2's `findings.md:90`, "A project config overrides the
  script's agent where the script is silent … With
  `OPENCODE_DISABLE_PROJECT_CONFIG=1` neither appeared". No other "findings"
  citation is in the script (`grep -n -i findings`: `:35,55,96,209,226,235,540`).
- **Untagged open items in `bug-reviewer-findings` (M3).** `plan.md:1325`
  `delete` does not update a project's `MEMORY.md` index; `:1326-1328` the
  pull race of findings A6 never reproduced, T18 proves only the lock;
  `result-slice1.md:247` and `result-review1-script.md:240` `delete` accepts
  nested paths under `memory/`; `plan.md:120-128` *B4*, the UNVERIFIED list
  (`~` expanded in a hook command among them). Each is now a tag.
- **Open-items sections (M3).** Every heading in a record file that matches
  follow-up, not done, unverified, not verified, open (as a word), not in this
  plan, later, deferred or out of scope — 49 sections (52 after round 2), computed with `awk` over
  the tracked `.md` records outside `probe-r3/`, `notes/`, `prototype*`,
  `rev2-build/` and `recorded/` — is a tag `[<slug>/<file> L<line>]`, in the
  heredoc of `check.sh` section 4 under kind R. (A first pass also matched
  "OpenCode" in two findings-r3 headings; the word match drops them.)
- **Decision lists (M4, M5).** Ids read from each source's decision sections
  (`awk` over headings matching "Decisions", then `^(- |[0-9]+\. )\*{0,2}(U|D|M)[0-9]+`),
  then checked by hand against the files: `feature-model-switch/plan.md`
  D1–D22; `sync-local-edits/result-followups.md` D1–D12; `sync-local-edits/result.md`
  **M1–M3 (the port's merge decisions, `:51,57,63`); `feature-opencode-worker/findings.md`
  U1–U6 (`:25-46`) and D1–D16; `feature-opencode-worker/plan.md` U1–U6
  (`:22-31`), D1–D21, M1–M17; `plan-r3.md` U1–U12 (`:28-58`; U3 sits in the
  line "U2, U3 … are narrowed by U10"), D22–D41, M1–M5;
  `fix-external-report-lines/plan.md` D1–D6; `fix-probe-findings/plan.md` 1–6
  (user 1–4, manager 5–6, as numbered list items) and D1–D5. They are fixed
  in `check.sh` section 5. `feature-plugin-marketplace/plan.md`'s **D1–D9 and
  **M1–M7 are slice steps, not decisions: they sit under "## Slice M — moves"
  (`:150`) and read "**D1** — the marketplace. New file (Q1)." (`:549`). That
  change's decisions are in its `questions.md`: the table "## Answered —
  decisions already made by the user (binding)" (`:7-19`, D1–D4 and S1–S5)
  and Q1–Q7. Round 2 (below) added what round 1 missed here. The
  plan-r3 lines matching `M01`–`M65` are mutant ids outside any decision section.

## Amendment — Stage 1b round 2/2

The migration analyzer found four gaps; the user decided to add them and build
without a third round (`plan.md` U6). Each was read in the record at `6838133`:

- `feature-opencode-worker/plan-r3.md:60-73` — "Required by the review of rev 2
  (binding):" V1 (own network namespace, internet only; named exit; README) to
  V8 (per rev-2 file, kept, changed or dropped). Seven of them sit inline in
  one bullet, so no `^- V<n>` pattern finds them; they are listed by hand in
  `check.sh` section 5's `plan-r3.md` line.
- `feature-plugin-marketplace/questions.md:7-19` — "## Answered — decisions
  already made by the user (binding)", a table: D1 plugin-first, D2 two
  plugins, D3 plugin install only, D4 repo only; S1 the test rules are
  universal, S2 a stub on `PATH` fakes a CLI, S3 review cap 3, S4 `host.md`
  stays per machine, S5 no real bucket, endpoint, profile or env value. Table
  rows, so the list-item pattern missed them.
- `sync-local-edits/result.md:66` — **P1** (where bootstrap's new paragraph
  goes) beside **M1–M3**; and `:230-232`, a second `## Decisions` with one
  unnumbered bullet (the coordinator's decision on the alignment contradictions).
- With the heading match widened to "known", "not questions" and "risk", the
  same `awk` finds exactly three more sections (52 in all):
  `bug-reviewer-findings/result-slice1.md:220` "## Known undiscriminated",
  `feature-plugin-marketplace/questions.md:202` "## Not questions — verification
  steps the plan will carry", `feature-plugin-marketplace/findings.md:614`
  "## 10. Interaction between the two plugins, and risks".

## Amendment — review round 1/3

Run on 2026-10-18, `TMPDIR=/data/tmp/claude`, in throwaway directories that were deleted afterwards.

- **A squash merge loses the branch commit but not the folder (B1, U7).** In a throwaway repo with a bare `origin`: a branch commit adding `plan/s/` was squash-merged into `main` and pushed. `git merge-base --is-ancestor <branch commit> origin/main` → `rc=1`; `git log -1 --format=%h origin/main -- plan/s/` gave the squash commit, `git merge-base --is-ancestor` of it → `rc=0`; `git diff --quiet origin/main -- plan/s/` → `rc=0`. After `git rm -r` and a commit, `git restore --source=<that commit> -- plan/s/` brought both files back (untracked); `git show <that commit>:plan/s/` printed only the names (`tree …`, `plan.md`, `result.md`) — B5 holds. `git symbolic-ref --short refs/remotes/origin/HEAD` printed `origin/main`.
- **An empty slug removes all of `plan/` (B3).** `slug=''; git rm -r -n -- "plan/$slug/"` printed `rm` for every file under `plan/` (`plan/H.md`, `plan/a/plan.md`, `plan/b/plan.md`), `rc=0`; so did `plan/../` in that repo.
- **Only `manager/SKILL.md:126` states the model's duration** (R2, round 1; unchanged).
- **The built tree** (Slices S, P, R, M built, deletions unstaged): the amended `check.sh` prints 77 `FAIL` — the seven *Records* lines not in the restore form, the `pkill` tag, the two tags still under *Open*, each round-1 insertion missing, each replaced text still there, and the four new spec strings. Nothing else fails: the tag-as-item matching (D32) finds every built tag where it was.
- **A `cp -a` copy of the built tree**, with `fixes-r1.py` run (`applied`; `git diff --stat`: 144 files, the 20 of A5 and the 124 deletions) and SR1–SR6 applied: `Q1=A STAGE=build bash check.sh` printed no `FAIL`; `tags 187/187 in place`, `insertions 103/103 present`, 17 `ok   gone from …`.
- **Eleven single faults on that copy**, each alone and undone, each printed its own `FAIL`: the committer's name guard removed; Stage 8's landing condition removed; one *Records* line left as `git show`; a closed tag also left under *Open* (`is both open and closed`); the `pkill` incident removed; "does" kept; `ship.md`'s exception removed; the old `plugin.json` description; the `EDQUOT`/ugrep line removed; the C2 bullet removed; and `DEFAULT_REF=5e9b3a8`, a default branch behind `6838133` (`on-5e9b3a8=1` for the two folders committed after it).
- **The record stage on that copy**, after committing it and a `plan/feature-docs-specs/` holding `check.sh`, with a local ref `proto-default` standing in for `origin/main` (no push from a copy): `STAGE=record DEFAULT_REF=proto-default` printed seven `FAIL` before X1 (folder present, no *Records* line, both X tags open, the three stale lines S-A6 names); none after X1 and the removal (unstaged); one when a stale line was put back; none after the commit.

## Amendment — review round 2/3 (scope cut)

Run on 2026-10-18 in a `cp -a` copy of the built tree under `/data/tmp/claude`, deleted afterwards.

- `fixes-r2.py` printed `applied` (its first run stopped on the bootstrap bullet, which the developer had rewrapped; the edit now matches it as a slice). `git diff --name-only 6838133 -- plugins README.md AGENTS.md` then listed 16 paths: `committer.md`, `commit.md`, `push.md` and `ship.md` were back to the base.
- `grep -rn 'symbolic-ref\|is-ancestor\|git restore\|git rm' plugins README.md` on the cut copy found only base text: `external-agent.sh:423` (`symbolic-ref -q HEAD`, the copy's branch) and `push.md:47` (the containment question). So `check.sh` checks those words as gone only in the files the round-1 fixes put them in.
- The SR7 `sed` left no `git restore` in the specs; `git ls-tree -r --name-only` lines: 6, 2, 1, 3 (`external-agents.md`, `marketplace.md`, `memory-sync.md`, `workflow.md`).
- `Q1=A STAGE=build bash check.sh`: the built tree printed 60 `FAIL`, every one a cut item (`git restore` cited, the seven *Records* lines, each new insertion, each text to be gone, the four files differing from the base); the cut copy printed none (`tags 187/187 in place`, `insertions 85/85 present`).
- Five single faults on the cut copy, each alone and undone, each printed its own `FAIL`: the built `committer.md` put back; `symbolic-ref` put back into Stage 8; one *Records* line put back to `git restore`; the record check's verdict changed to `DIVERGES: <n> items`; the `git archive` form dropped from `AGENTS.md`.
- The record stage on the copy, with a local ref `proto-default` for `origin/main`: seven `FAIL` before X1; after X1's edits and the repo-rule removal (the folder clean and identical on the ref, then `git rm -r -q -- plan/feature-docs-specs/`, which staged only `D` lines), none.

## Proven behaviour

- The profiles' `## Notes` never reach a model. `external-agent.sh:456`
  `section()` prints from the named heading to the next `## `, and
  `first_prompt` (`:458-493`) asks only for `## Before the contract` and
  `## After the contract`. The same `awk` over each profile at `6838133` gives
  sha256 prefixes default `4b76d5992a8d7c6e`, kimi `2d437de722ccdf58`, glm
  `8df4f6ad91d18ead`, deepseek-pro `275f2d1e9a59a5fe`, deepseek-flash
  `172b9700f982b448`. In a `cp -a` copy, after `sed` rewrote every `plan/…`
  path in the four `## Notes`, `check.sh` section 8 printed
  `ok   prompt <name>` for all five.
- `git rm -r -q -- plan/s/` in a throwaway repo (git 2.53.0): with an untracked
  file in the folder → `rc=0`, `D` for both tracked files, `?? plan/s/untracked.md`
  left on disk; with a tracked file modified → `error: the following file has
  local modifications`, `rc=1`, nothing staged. Removing the tracked files
  with `rm`, then `git add plan/s` → `rc=0`, both deletions staged.
- Base gates on this tree, `TMPDIR=/data/tmp/claude`: five `rc=0`, shellcheck
  `rc=0`, `PASS 35/35`, `PASS 49/49` (each test's last line only, here). The
  plugin block with `CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`
  and a throwaway `CLAUDE_CONFIG_DIR`: three `✔ Validation passed`;
  `Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship`;
  `Agents (5)`; `Hooks (1)  SessionStart`; `Skills (1)  sync-memory`;
  `Agents (0)`; `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
  `glab = glab`; `memory-sync = memory-sync`; `:0`, `:0`, `rc=1`; `:1` ×3,
  `rc=0`; `1`, `rc=0`; `rc=1`.
- `check.sh` (the post-condition checker, `plan.md` *After* A3 and X5), as
  amended, is `bash -n` and `shellcheck` clean. On this tree it prints 308
  `FAIL` lines after round 2 (302 after round 1) (the seven folders `present=yes`, each stale citation,
  `tags 0/186 in place`, every decision set, heading and insertion).
- **A fresh prototype** (`cp -a` of the repo at `6838133` under
  `/data/tmp/claude`, deleted afterwards): every edit of P1–P14, R1 and R2
  applied as `plan.md` quotes it, with a script that asserted each "before"
  text occurs exactly once (it failed twice on wrapped anchors — the profiles'
  `comparison table`, `AGENTS.md`'s `the\n  missing-` — and passed once they
  were matched across the wrap); stub specs carrying every tag under its
  heading, the decision ids, the records and section lines, the measurements,
  the notes citations and the three blocks; M1's loop run, **nothing staged**.
  `git diff --stat` printed `19 files changed`, the 19 of A5. Then
  `Q1=A STAGE=build bash check.sh` printed no `FAIL`: seven
  `ok   removed <slug> (unstaged deletions: <n>)`, `tags 182/182 in place`,
  eight `ok   decisions`, `insertions 72/72 present`, `ok   rules … spec-tags=6`,
  `ok   versions glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0`. The
  first *Gates* block's script lines on that tree: five `rc=0`, shellcheck
  `rc=0`, `PASS 49/49`; A4 printed `1`.
- Twelve single faults on that finished tree, each run alone and undone, each
  printed its own `FAIL`: one folder restored (section 1); a bare
  `plan/sync-local-edits/result.md` on the same line as a `git show` command
  (2); a tag moved to *Incidents* (4, naming the heading it was found under);
  `U7` dropped from a spent line (5); an empty *Incidents* (6); P4's
  "unless … keeps its plans" removed from `commit.md` (10); an untracked file
  under `plugins/memory-sync/` (9, `memory-sync-changes=1`); one byte of the
  runner (7); a D15 tag under *Closed* at `STAGE=build` (4); P4 missing from
  *Measurements* (11); an extra `## Notes` heading (6); the script's
  `(findings P4 …)` left (2, 10 and the rules line). With the faults undone it
  printed no `FAIL` again.
- **The record stage** on the same prototype, after committing it and a
  `plan/feature-docs-specs/` holding `check.sh` (`LAST` = that commit),
  running `Q1=A STAGE=record LAST=$LAST bash <(git show "$LAST:plan/feature-docs-specs/check.sh")`:
  before X1 it printed four `FAIL` (the folder present, no *Records* line, both
  D15 tags still open); after the two tags moved to *Closed*, the *Records*
  line added and the folder's tracked files removed (unstaged), no `FAIL`;
  after committing that, no `FAIL`.
- **Round 2, on a second fresh prototype** (the same build with the round-2
  texts — P9's exception included — and stubs carrying the new tags and ids;
  M1's loop run, nothing staged; `git diff --stat` printed `143 files changed`,
  the 19 edits plus the 124 unstaged deletions, and `git diff --cached --stat`
  printed nothing): `Q1=A STAGE=build bash check.sh` printed no `FAIL`,
  `tags 186/186 in place`, nine `ok   decisions` lines (`plan-r3.md (45)`,
  `feature-plugin-marketplace/questions.md (9)`, `sync-local-edits/result.md (4)`
  among them), `insertions 73/73 present`. One fault per new entry, each alone
  and undone, each printed its own `FAIL`: `V5` dropped from `plan-r3.md`'s
  spent line; `S3` dropped from the marketplace `questions.md` spent line;
  `P1` dropped from `sync-local-edits/result.md`'s; the
  `[sync-local-edits/result.md decisions]` tag removed; each of the three new
  section tags (L220, L202, L614) removed; P9's "unless … keeps its plans"
  removed from bootstrap. Undone, no `FAIL`. The copy was deleted.

## Inferred behaviour

- The specs, the payload text and `AGENTS.md` are prose: no command judges them
  correct. `check.sh` proves presence, absence and byte-equality only.
- An installed copy follows the new rule only from 0.5.0 (`AGENTS.md` version
  rule). The agents of this session are the installed 0.4.2: their
  `glab:committer` has no record-commit paragraph, so this change removes the
  folders with the 0.4.2 contracts — the developer deletes the tracked files
  after a guard, the committer stages `git add plan/<slug>` — as proven above.
- A repo that squash-merges loses branch commits from its main line. Tested in round 1 of the review (*Amendment — review round 1/3*), and answered by Stage 8 naming a commit on the default branch (U7, D25); `workflow.md`'s known-limit line on it is rewritten at X1.

## Call-site audit — contracts that change

- **`glab:committer`** gains the record commit (`git rm -r`). Callers:
  `/glab:commit` (`commands/commit.md:8`), `/glab:ship` (commits after review —
  never a record), manager Stage 6 and the new Stage 8. Every existing caller
  relies on "explicit paths, never `git add -A`"; the new paragraph applies only
  when the caller names a record commit.
- **`glab:developer`** gains the record scope. Callers: `/glab:develop`,
  manager Stage 2 and the new Stage 8. Existing callers rely on `result.md`
  being written; only a dispatch that says it is the record skips it.
- **`glab:analyzer`** does not measure `## Record`. Callers: `/glab:analyze`
  (plan-only 1b and conformance 3). A plan without `## Record` — every older
  plan — is measured as before.
- **The manager's tier-table row** "Spec" becomes "8 Record". Nothing else names
  that row (`grep -rn '| Spec |' plugins` → `manager/SKILL.md:196` only).
- **`external-agent.sh`** — comments only: no function, constant or output
  changes; `tests/external-agent.test.sh` reads no comment of it.

## State transitions — the removal

- Before: `plan/<slug>/` tracked in HEAD. For the seven, HEAD and
  `origin/main` are `6838133`: every folder's last commit is on `origin`.
- After success: no file of the folder in the index or the tree; each one
  readable with `git show <last>:plan/<slug>/<file>` from a commit on `origin`.
- After failure: a modified tracked file makes `git rm` refuse, and nothing is
  staged; the developer's guard (`git status --short -uall -- plan/<slug>`
  prints nothing) stops before any deletion in this change.
- Objects: the 124 paths `git ls-files plan/<seven>` lists at `6838133`.

## Candidate boundaries

1. **Chosen:** one spec per area under `docs/specs/`; a Stage 8 record after
   the push — the developer writes the spec, the committer removes the folder
   with `git rm -r` in the same docs commit; payload citations point at the
   spec, named with its repository.
2. Rejected: keep the folders and add an index — the user decided removal.
3. Rejected: one spec per change — the user decided one per area, living.
4. Rejected: write the spec in the change's own commits, before the push — the
   user decided after the push, and a spec cannot name the commit it is in.
5. Rejected: the developer runs `git rm` — its contract is "never stage".
6. Rejected: a tracked `runner.sh` or a `docs/runbooks/` file — an executable
   that calls a real model would sit in the tree with no gate over it, and a
   second docs directory breaks "one file per area"; the spec holds the
   procedure as blocks the user saves and runs as a script.
7. Rejected: cite the removed folders by commit from the payload — an installer
   can follow a commit of this repo no better than a path; the spec, named with
   its repository, is one place that stays current.
