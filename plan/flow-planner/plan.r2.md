tier: normal — payload text, one read-only hook script and its test, one quoted heredoc, `AGENTS.md`, `README.md` and the manifest version; no full-tier trigger.

# flow-planner — cheaper plans, a constant master plan, sub-plans and the intent check

Round 2: the user widened the scope (D23, D32, D37, D38). Evidence: `evidence.md` (F0–F16, *Boundary*). Line numbers are at `cf614ec`; find each place by its quoted anchor.

## Decisions

- effort: high, for the session — the user's words after the 2026-10-22 compact: "Subagent effort high (record the `- effort:` line in each plan)".
- D1 Findings are `evidence.md`: a subagent's Write of `findings.md` is refused and `evidence.md` was accepted (F8, IN1).
- D2 `master.md`, `plan.md`, `index.md` and `evidence.md` at most 48 KB each (`wc -c`), because every later agent reads them again (F1: 155 KB, from 59 KB).
- D3 A decision is one line, choice and reason in at most two sentences, evidence cited by id, never restated; a fact is written once (F1).
- D4 A plan that cannot be split carries `- size: <n> KB — <why it is one plan>` under `## Decisions`, and the manager decides under Rule 3.
- D5 Amendments replace the text they change, in place, under the same id; the `.r<n>` copies are the history (`[flow-cheaper-rounds/plan.md D10]`), and the manager's overrule line stays (`[sync-local-edits/result-followups.md D9]`).
- D6 The manager checks size by `wc -c` alone (Rule 2 forbids reading the plan); the analyzer checks in-place amending on its re-check, the one reader of the diff.
- D7 Steps 5–7 and the three implementation-only repo rules move byte for byte, numbers kept, to `plan-first/implement.md`, so no caller breaks (F2).
- D8 Rejected homes for them: `glab:developer` and a new skill (B1, B2).
- D9 No `glab:planner` agent in this plan — the user's decision, carried: the agent count changes once, in `flow-models-per-role` (F3).
- D10 The developer's context rules (S5) are prose in `glab:developer` — the user's decision, carried; no hook is shown to shorten a tool's output (F4).
- D11 No `scripts/gate.sh`: one inline line does it (F4).
- D12 The first context step is `GLAB_COMPACT_AT` thousand when set, default 300k, then every 100k — the user's decision, carried; amends `[flow-cheaper-rounds/plan.md D45]` and `D47` by the variable only (F5).
- D13 No per-model table and no fraction of the window: the hook is not told the window (F5).
- D14 A set, valid value ends the line `; compact at <t>k)` in all three modes, so the manager reads the step from the line.
- D15 An invalid value (not `^[1-9][0-9]{0,5}$`) warns once on stderr and uses the default; read after the transcript, so each failure path keeps one stderr line (F5).
- D16 Empty is unset: no warning.
- D17 On a window not larger than the first step plus 100k the manager tells the user once and names the variable; the number is the user's (F5).
- D18 `glab` 0.9.0 → 0.10.0, nothing removed, so no `!`; `memory-sync` untouched.
- D19 One `glab:developer`: most steps share `manager/SKILL.md` or `AGENTS.md`.
- D20 One commit with the plan folder: *One fact* wants each fact's files together, and this plan has no sub-plans (D41).
- D21 `flow-models-per-role` stays a separate plan, after this one — the user's decision, carried (F7).
- D22 *One fact* changes as S8 says.
- D23 The user's decision: a constant master plan and isolated sub-plans — "planner must logical isolated plan stages to separated plans … the based high level plan as a constatn / sub plans witch are must be a low level plans / each low level plans must be iterated with isolated planning cycle / and must be good to have low level plan specs constant validation or verification flow also"; its aim: "subagents can read all plan … it can consume more tokens".
- D24 Every folder gets `master.md`, and beside it one `plan.md` by default or `index.md` and sub-plan folders, each a full plan folder: a small task has two files and no tree (B5). The split lives in `index.md`, an engineering choice that amendments change (B6).
- D25 Constant means hashed: `master.sha256` after `## Approval`, checked with `sha256sum -c` by every analyzer and by `/glab:develop` (B11).
- D26 Approval comes after Stage 1b, so the user approves a checked plan — the user's at full tier and whenever the work split; full-tier approval moves from before 1b to after it (F11).
- D27 Split only into parts with their own goals and milestone, never across a fact the repo changes in one commit (F15); each is planned once its dependencies are committed and built one at a time in `<nn>` order, so it cites the tree it is built on and each review sees one change.
- D28 An agent reads `master.md`, its own folder and its `index.md` line — the user's token aim (D23); only the coverage and final checks read all of `index.md`.
- D29 Round caps per sub-plan and stage; the master and final checks have the same cap, their round-3 line in `index.md` (`plan.md` with no sub-plans).
- D30 One commit per sub-plan, one push and one record per slug (B7); a single plan commits once. `AGENTS.md`'s version rule then reads per push: the push's first commit that changes the plugin raises it (F15).
- D31 Stage 3 runs for every sub-plan at every tier, as the user listed the cycle "plan → analyzer plan check → develop → analyzer conformance → review"; this amends `[sync-local-edits/result-followups.md D5]` for sub-plans only; a normal-tier single plan keeps none (B12).
- D32 The user's decision: the analyzer checks the intent at Stage 1b, Stage 3 and the final check — "analyzed … on every stage must validate and find gaps between original business plan and implementation"; the reviewer stays blind — "review agent must only check the code itself without any plan" — so no reviewer file and no *One fact* review entry changes (F10, B9).
- D33 The final check is Stage 6b, after the slug's last commit and before the push; skipped only for a single full-tier plan, whose Stage 3 asked it.
- D34 An intent gap after the build is a defect of the plan: it goes to a planning agent, and a developer reports it as `PLAN WRONG`.
- D35 `glab:analyzer` gets the plan check and its verdicts `BUILDABLE` and `NOT BUILDABLE`, until now stated only by the manager (F10).
- D36 No two analyzer kinds here: each check gains the intent question, and the split goes to `flow-models-per-role` with the planner agent (B8).
- D37 The user's decision: the flow should "work with claude app|cli builtin flow". Plan mode carries the master's approval only when the user asks, main session only (F12), after Stage 1b with no agent running, no plan file outside the repo, `plansDirectory` untouched; L1–L7 are the user's.
- D38 `evidence.md` and `evidence.r<n>.md` wherever the payload names the file; readers still accept `findings.md` in a folder from before 0.10.0 (F9, F11).
- D39 `## Record` moves to `master.md`; a folder with no master keeps `plan.md`'s.
- D40 The stage listings gain "final check" (F13).
- D41 This plan runs under the 0.9.0 rules it changes: no `master.md`; the user's words are in D9, D10, D12, D21, D23, D32, D37.
- D42 A single plan's Stage 1b analyzer reads `master.md` and `plan.md` together.

## Milestone

`bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh` prints `PASS 24/24`, and `FAIL 3/24` against the `cf614ec` script; every gate in *After* prints its line. The Markdown has no runtime: the searches prove it, and L1–L7 the plan-mode behaviour.

## Steps

### Before

- B0 `git status --short -uall` shows only `plan/` untracked; `export TMPDIR=/data/tmp/claude`; the gates print F14.

### Processing

- **S1 `plugins/glab/skills/plan-first/`.**
  - Create `implement.md`: line 1 `# Plan First — implementation`; then one paragraph: "Steps 5 to 7 of `glab:plan-first`, kept apart so that a planning agent does not load them. Start them only once the plan is verified (Step 4) and, at full tier, approved."; then `SKILL.md` lines 97–147 (`## Step 5 — Implement` … Step 7's last bullet) byte for byte; then `## Repo Rules for the implementation` and lines 151–161 (Service lifecycle, Nested repositories, Commits) byte for byte. No frontmatter.
  - In `SKILL.md`, remove lines 97–148 and 151–162; in place of Steps 5–7:

        ## Steps 5 to 7 — Implement, E2E tests, unit tests

        They are in [`implement.md`](implement.md), beside this file, with the repo rules that bind only the implementation — service lifecycle, nested repositories, commits. Read it once the plan is verified (Step 4) and, at full tier, approved. **A planning agent stops at Step 4 and does not read it.**

  - Step 0 (l. 19): "Normal tier writes one page: `plan.md` alone, with findings and decisions as sections of it." → "Normal tier writes `master.md` and one page, `plan.md`, with evidence and decisions as sections of it."
  - Step 1 (l. 23): "Write findings to `plan/{slug}/findings.md`. Include:" → "Write findings to `plan/{slug}/evidence.md` — not `findings.md`: Claude Code refuses a subagent's Write of a file by that name. Include:"
  - Step 3, the `## Record` bullet (l. 79): its first words "`## Record` — the area spec" → "`## Record`, in `master.md` (below) — the area spec".
  - After Step 3's last paragraph (l. 81) add:

        **Size and shape — every later agent reads the plan again**, round after round, so every line is paid for many times. Keep `master.md`, `plan.md`, `index.md` and `evidence.md` at or under **48 KB** each (`wc -c`). A decision is one line: the choice and its reason, in at most two sentences; its evidence stays in `evidence.md` and is cited by id, never restated. Write a fact once, where it belongs, and cite it elsewhere. A plan that will not fit is usually two plans: split it (below). When it cannot be split, say why under `## Decisions` as `- size: <n> KB — <why it is one plan>`, and the manager decides (`glab:manager` Rule 3).

        ### The master plan, and sub-plans when the work splits

        Every plan folder starts with `plan/{slug}/master.md` — what the user asked for, constant once accepted; the plans say how. It holds:

        - `## Request` — the user's words that define the task, verbatim and dated, later words added the same way until approval. Never paraphrase them: every intent check reads them.
        - `## Goals` — `G1`, `G2`, …: one line each, what must be true for the user when done, citing its words, saying no more and no less.
        - `## Out of scope` — what the user excluded, in their words, or `none`.
        - `## Final check` — the test that shows the whole request done, end to end.
        - `## Record` — the record, as Step 3 says.
        - `## Approval` — the manager writes it (`glab:manager` Stage 1); you never do. After it the master is never edited.

        **One plan by default** — one `plan.md` beside the master — when the work has one milestone and fits the size budget. **Split it** only into parts that each serve their own goals, carry their own milestone test and can be built, reviewed and committed one after another. Each part is a sub-plan: a folder `plan/{slug}/<nn>-<name>/` that is a plan folder under every rule of this skill — its own `plan.md`, tier line, `evidence.md`, `questions.md` and round copies. `<nn>` is two digits in build order, never reused or renumbered; `<name>` is kebab-case. Files the repo requires to change in one commit belong to one sub-plan.

        The split goes into `plan/{slug}/index.md`, one line per sub-plan — `<nn>-<name> · goals G1, G3 · depends <nn>-<name>, … | none · tier <normal | full>` — and a `## Decisions` section for choices about the split. Every goal is on at least one line.

        **Planning in cycles.** The first planning agent writes `master.md` and, when the work splits, `index.md` — no sub-plan yet. Each sub-plan is then planned by its own agent from `master.md`, its own `index.md` line and the map files it needs — never from another sub-plan — once what it depends on is committed, so it cites the tree it will be built on. A sub-plan that needs another goal or another sub-plan's files says so and does not reach into them: the split is the manager's.

  - Replace Step 4's amending paragraph (l. 95) with:

        **Amending after a plan check.** Under `glab:manager` an amendment after `NOT BUILDABLE` is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:manager` Stage 1b). Change what the findings name and what that forces, and **replace the text you change, in place**: the step, the finding or the decision line is rewritten under its own id, a changed choice with its new reason. Never append an amendment section, a "superseded" line or a round marker beside the old text — the `<name>.r<n>.md` copies the manager kept are the history; leave them as they are. A line the manager added to overrule a decision stays as the manager wrote it. A `master.md` with an `## Approval` line is never amended: a change to the request goes back to the user. Step 1 is not run again, except for a gap a finding opens.

  - Step 4: "at full tier, the user has approved the plan;" → "the plan check has passed and `master.md` has its `## Approval` line — the user's at full tier and whenever the work split;".
  - *Plan files are working files* (l. 163): "A plan folder whose `plan.md` has no `## Record`" → "A plan folder whose `master.md` — or `plan.md`, in a folder with no master — has no `## Record`".
  - Quick Reference: Analyze row → `` `plan/{slug}/evidence.md` ``; above it `| Intent | Request, goals, final check, record | `plan/{slug}/master.md`, the split in `index.md` |`; Verify row → "the plan check, then the master's approval".
  Verify: `python3 -I -c 'import subprocess as s; a=s.run(["git","show","cf614ec:plugins/glab/skills/plan-first/SKILL.md"],capture_output=True,text=True).stdout.splitlines(); b=open("plugins/glab/skills/plan-first/implement.md").read(); print("\n".join(a[96:147]) in b, "\n".join(a[150:161]) in b)'` → `True True`; in `SKILL.md`: `grep -c '^## Step [567] '` → `0` (in `implement.md` → `3`); `grep -c '^## Step [0-4] '` → `5`; `grep -c 'Service lifecycle\|Nested repositories'` → `0`; `grep -c -F '**48 KB**'` → `1`; `grep -c 'replace the text you change, in place'` → `1`; `grep -c 'findings\.md'` → `1` (the reason in Step 1); `grep -c 'evidence\.md'` → `≥4`; `grep -c '^### The master plan, and sub-plans'` → `1`.

- **S2 `plugins/glab/skills/manager/SKILL.md` — names, tables, Stage 1, Stage 1b.**
  - `findings.md` → `evidence.md` and `findings.r<n>.md` → `evidence.r<n>.md` at l. 53, 175, 197, 338, 340; l. 92 and 262 stay.
  - l. 3 description: "→ commit → push → record" → "→ commit → final check → push → record". Rule 2 l. 91: "Stages 1b, 2, 3, 5 and 8" → "Stages 1b, 2, 3, 5, 6b and 8".
  - Pipeline table: row 1 *Writes* starts "`plan/{slug}/master.md`, and `plan.md` or `index.md` with sub-plan folders;" and says `evidence.md`; row 1 *Leaves on* loses "; user approval at full tier", row 1b's gains "; then the master's `## Approval`"; after row 6 add `| 6b | Final check | `/glab:analyze {slug}`, the final check | — | `CONFORMS` |`. After the handoff-line paragraph add: "With sub-plans the line names the sub-plan for the slug: `{slug}/02-hooks · analyze · round 1/2 · …`."
  - Tier table: row 1 cells start with `master.md` and say `evidence.md`, the normal one ending "— or sub-plans (*The master plan and sub-plans*)"; *Approval* row → `| Approval, after 1b | — | yours, reported — the user's when the work split | the user's, explicit |`; row 3 normal cell → "each sub-plan: max 2 rounds"; after row 5 add `| 6b Final check | — | max 2 rounds | max 2 rounds; a single plan: Stage 3's |`.
  - *Round caps*: "Stage 1b, Stage 3 and Stage 5 run at most **2 rounds** each" → "Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b) run at most **2 rounds** each — per sub-plan where there are sub-plans —".
  - After *Pick the tier* (before *Running agents in parallel*) add:

        ## The master plan and sub-plans

        `glab:plan-first` Step 3 has the layout: `master.md` — the request verbatim, the goals, the final check, the record — and beside it one `plan.md`, or `index.md` and sub-plan folders `plan/{slug}/<nn>-<name>/`.

        - **The master is constant once accepted.** Write its `## Approval` line (Stage 1), then, from the repo root, `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256`, and never edit it again. Before that it is amended like a plan. A request the user changes afterwards means a new master — `master.r<n>.md` kept, amended by a planning agent, approved and hashed again — and Stage 1b again for every sub-plan not yet committed; the committed ones meet it at the final check.
        - **Each sub-plan runs its own cycle** — Stages 1 (its own planning agent), 1b, 2, 3, 4, 5 and 6 — at its own tier, Stage 3 at every tier. Commands take `{slug}/<nn>-<name>` for a slug: `/glab:analyze {slug}/02-hooks`. Round caps count per sub-plan and stage; its round-3 line and round copies stay in its folder.
        - **In `<nn>` order, one at a time.** A sub-plan is planned once what it depends on is committed; independent ones may be planned and checked in parallel. Development, review and commit run one sub-plan at a time, so each review sees only its own change.
        - **Every agent reads `master.md`, its own folder and its own `index.md` line** — never another sub-plan. Name those paths in each dispatch; the reviewer gets none (Stage 5).
        - **A change to the split** is a planning agent's amendment of `index.md` (Rule 3, `index.r<n>.md` kept), checked by Stage 1b's coverage question.
        - **The slug ends once:** the final check (Stage 6b), one push, one record.

  - Acceptance checklist: "until all five hold" → "until all seven hold"; after item 5 add:

        6. **Within its size.** `glab:plan-first` Step 3 caps `master.md`, `plan.md`, `index.md` and `evidence.md` at 48 KB each. Check it by size alone, without reading them (Rule 2): `wc -c` on each that exists, and `grep -c '^- size: ' plan/{slug}/plan.md`. Over the cap with no `- size:` line: send it back to be split or cut. With one: that is a Rule 3 choice of yours — accept it, or send it back to be split.
        7. **A master.** `grep -c '^## \(Request\|Goals\|Out of scope\|Final check\|Record\)$' plan/{slug}/master.md` prints `5`, and with sub-plans `index.md` has one line per sub-plan folder. Checked by search, not by reading.

  - Replace the paragraph "At full tier, then get explicit approval. Nothing records it, so ask. At normal tier, report the tier and the decisions and go on to Stage 1b." with:

        **Approval comes after Stage 1b has passed** — the master check, when the work split — so the user approves a checked plan: explicitly at full tier and whenever the work split. At normal tier with no sub-plans, report the tier and the decisions and go on. Then write the last section of `master.md`, `## Approval`, one line — `- approved by the user, <date>, in chat | in plan mode: "<their words>"; base <git rev-parse --short HEAD>`, or `- accepted at normal tier, reported to the user, <date>; base <sha>` — and hash it (*The master plan and sub-plans*). The base is where the final check's range starts.

        ### Approval in Claude Code's plan mode — only when the user asks for it

        Plan mode ends in an approval dialog that can carry the master's approval. Use it only when the user asked for it, in this session or a standing instruction; otherwise ask in the chat. Only you can: Claude Code gives no subagent the plan-mode tools.

        1. **After Stage 1b, with no agent running.** Plan mode blocks edits until approval: dispatch no agent while in it.
        2. **Tell the user first, in one line:** the dialog sets the session's permission mode from then on — pick the current one, since auto or accept-edits lets the session do more without asking and nothing here relies on it — and changes go through "No, keep planning", not a Ctrl+G edit, which never reaches `master.md`.
        3. **EnterPlanMode, then ExitPlanMode with `master.md` as the plan** — its path and its text, read once for this: the one exception to Rule 2 it needs. If plan mode asks for a plan file outside the repo — `~/.claude/plans` by default — do not write it: ask the user to leave plan mode (Shift+Tab) and approve in the chat. Inside the repo, where the user's own `plansDirectory` put it, write `master.md`'s text there byte for byte and never commit it. Never change that setting.
        4. **Approved** → the `## Approval` line says `in plan mode`, with any words the user gave. **"No, keep planning"** → the user leaves plan mode (Shift+Tab) before you dispatch the amendment; their words go into `## Request`.

  - Stage 1b: "**`BUILDABLE`** → Stage 2." → "**`BUILDABLE`** → the approval (Stage 1), then Stage 2 — or, after the master check, the sub-plans." Before it add:

        **Ask the intent question too** — `glab:analyzer` *The intent question*: of the master, whether every request reaches a goal and every goal a line of `index.md` (the coverage question); of each plan, whether it delivers its goals as `## Request` words them. For a single plan one analyzer asks both, of `master.md` and `plan.md` together. A gap is a finding like any other.

  - Stage 1b, the amendment paragraph (l. 338): "records each changed choice under `## Decisions`, and leaves" → "replacing the changed text in place rather than adding beside it (`glab:plan-first` Step 4), and leaves"; and after "`<n>` being the round that checked them." add " The same holds for `master.md` before its approval and for `index.md`, each copied as `<name>.r<n>.md` beside it."
  Verify: `grep -c 'findings\.md\|findings\.r<n>'` → `0` (l. 262 names `findings-<area>.md`); `grep -c 'evidence\.md'` → `≥5`; `grep -c 'until all seven hold'` → `1`; `grep -c '^6\. \*\*Within its size\.\*\*'` → `1`; `grep -c '^7\. \*\*A master\.\*\*'` → `1`; `grep -c '^## The master plan and sub-plans'` → `1`; `grep -c '^### Approval in Claude Code.s plan mode'` → `1`; `grep -c 'Ask the intent question too'` → `1`; `grep -c 'replacing the changed text in place'` → `1`; `grep -c 'final check → push'` → `1`; `grep -c -F 'sha256sum plan/{slug}/master.md'` → `1`.

- **S3 `plugins/glab/skills/manager/SKILL.md` — Stages 3, 6, 6b, 7, 8.**
  - Stage 3 (l. 385): "**Full tier only.** At normal tier the step list" → "**Full tier, and every sub-plan at every tier.** At normal tier with no sub-plans the step list"; after its "then Stage 4" add "; the intent question waits for the final check (Stage 6b)".
  - After "Do not let it drift." (l. 389) add: "Where the folder has a master it also asks the intent question: does the build serve the master's goals, beyond matching the steps? A step built as written that misses its goal is a defect of the plan: it goes to a planning agent's amendment, then Stage 2 — never to a developer told to build past its plan."
  - Stage 6, after its first paragraph, add: "With sub-plans, commit each one after its Stage 5: its own folder, and with the first also `master.md`, `master.sha256`, `index.md` and the map files. Nothing is pushed before the final check."
  - Between Stage 6 and Stage 7 add:

        ## Stage 6b — Final check

        After the slug's last commit, before the push, at every tier: `/glab:analyze {slug}` as the final check. The analyzer reads `master.md`, `index.md` and the range from the `## Approval` base to `HEAD`, and asks of every goal whether it is delivered, and where. Run the gates yourself on that tree. Skipped only for a single plan at full tier, whose Stage 3, delta rounds included, asked it.

        `CONFORMS` → Stage 7. `DIVERGES` → the gaps go to a new planning agent: with sub-plans, a new sub-plan with the next `<nn>` and its line in `index.md`; without, an amendment of `plan.md`. It runs its cycle to its commit; round 2 gets round 1's findings and the two commit ids. At most 2 rounds, a third under *Pick the tier*'s rule, its line in `index.md` (`plan.md` with no sub-plans); still diverging: bring it to the user.

  - Stage 7 (l. 433): "Show the plan's `## Decisions` lines with them" → "Show the `## Decisions` lines of each plan the push carries".
  - Stage 8: l. 441 "the plan's `## Record` names" → "`master.md`'s `## Record` names — `plan.md`'s, with no master —", and "from the folder's files" → "from the folder's files, sub-plan folders included"; l. 446 "whose `plan.md` has no `## Record`" → "whose `master.md` — or `plan.md`, with no master — has no `## Record`".
  - *When subagent dispatch is not available* (l. 250): after "`<slug> review`," add " `<slug> final`,".
  - *What you never do*: "Give the reviewer the plan." → "Give the reviewer the plan, `master.md` or `index.md`."; add the bullet "Edit `master.md` after its `## Approval`, or enter plan mode the user did not ask for."
  Verify: `grep -c '^## Stage 6b — Final check'` → `1`; `grep -c 'Full tier, and every sub-plan at every tier'` → `1`; `grep -c 'build past its plan'` → `1`; `grep -c 'Nothing is pushed before the final check'` → `1`; `grep -c 'or enter plan mode the user did not ask for'` → `1`.

- **S4 `plugins/glab/agents/analyzer.md`.**
  - l. 3 description: "Checks an implementation against its plan in plan/{slug}/ — conformance only" → "Checks a plan before the build, and an implementation after it, against the plan and the user's request in master.md — conformance and intent only"; "ending in CONFORMS or DIVERGES" → "ending in BUILDABLE, NOT BUILDABLE, CONFORMS or DIVERGES".
  - l. 7, after "**did the implementation do what the plan said?**" add " With a master you also ask whether it serves what the user asked for (*The intent question*)."
  - Step 1 list, first bullet before `plan.md`: "- `master.md` — `plan/<slug>/master.md`, or for a sub-plan `plan/<slug>/<nn>-<name>/` the one a level up — when there is one: the request and its goals. First run `sha256sum -c plan/<slug>/master.sha256` from the repo root when that file exists; anything but `OK` is a finding rated `high` — the master changed after approval. Of `index.md` read only your folder's line, except in a coverage or final check. Never read another sub-plan's folder."
  - l. 16: "`plan/<slug>/findings.md` and every" → "`plan/<slug>/evidence.md` (`findings.md` in a folder from before `glab` 0.10.0) and every".
  - After Step 4 add:

        ## The intent question — wherever there is a master

        `master.md` quotes the user (`## Request`) and lists the goals `G<n>` resting on those words: what was asked, where the plan says how. Ask, on top of your check:

        - **in a plan check:** of the master — does every request reach a goal or `## Out of scope`, each goal say no more and no less than its words, and every goal reach a line of `index.md` (the plan, with no index)? Of a plan — do its steps deliver every goal its line names as `## Request` words it, nothing dropped, narrowed or reshaped?
        - **in a conformance check:** does what was built serve those goals, beyond matching the steps? A step built as written that misses its goal is a gap in the plan: say so.
        - **in the final check:** for each goal — delivered, and where (commit, `file:line`), or not.

        Report each goal as a step: `goal G<n>: <served | partial | missing | reshaped>`, `request said:` quoting the words, then `built:` or `planned:`, `gap:` and `severity:` as *Report* has them. A goal not served counts in your verdict as one step. No master — a folder from before `glab` 0.10.0 — no intent question: say so.

        ## The plan check — `glab:manager` Stage 1b

        There is no implementation yet: skip Step 2, check each step against the code it cites as `glab:manager` Stage 1b says — its mechanism, its constraints side by side, whether its post-condition tells a finished tree from a half-finished one — and ask the intent question. End with `BUILDABLE`, or `NOT BUILDABLE` with each finding under its step or goal id and its severity.

        ## The final check — `glab:manager` Stage 6b

        Your contract is `master.md` and `index.md`; the implementation is the range the dispatch names — `git log --oneline <base>..HEAD`, `git diff <base>..HEAD`. Do not walk the sub-plans' steps, which were checked. Answer the intent question for every goal and end with `CONFORMS`, or `DIVERGES: <n> steps`, one per goal not served. Round 2 gets round 1's findings and the range of the gap work.

  - *Re-checks* l. 56: "`plan/<slug>/plan.r<n>.md` and `plan/<slug>/plan.md`, and `findings.r<n>.md` with `findings.md` when there are" → "each `<name>.r<n>.md` the manager kept with its current file — `plan.md`, `evidence.md`, `master.md`, `index.md`"; after the bullet ending "the post-condition question included;" add the bullet: "- for a plan check, an amendment that added text beside what it changes — an amendment section, a "superseded" line, a round marker, or an old step or decision left standing next to its new form — rather than replacing it in place (`glab:plan-first` Step 4): one finding, on that step or decision id;".
  - Record check (l. 68): "every file of `plan/<slug>/`" → "every file of `plan/<slug>/`, its sub-plan folders included,".
  - *Report*, the verdict list: before `CONFORMS` add "- `BUILDABLE` — a plan check: every step can be built as written and the intent question found no gap." and "- `NOT BUILDABLE` — a plan check: anything else."
  Verify: `grep -c '^## The intent question'` → `1`; `grep -c '^## The plan check'` → `1`; `grep -c '^## The final check'` → `1`; `grep -c 'NOT BUILDABLE'` → `≥2`; `grep -c 'sha256sum -c'` → `1`; `grep -c 'rather than replacing it in place'` → `1`; `grep -c 'findings\.md'` → `1` (the older-folder clause); `grep -c 'findings\.r<n>'` → `0`.

- **S5 `plugins/glab/agents/developer.md`.**
  - Step 1 list, after the `AGENTS.md` bullet: "- `master.md` — `plan/<slug>/master.md`, a level up for a sub-plan — when there is one: why the work exists. Context, not scope: a step that, built as written, cannot serve its goal is `PLAN WRONG`, not something to build around. Never read another sub-plan's folder."
  - l. 17: "`plan/<slug>/findings.md`, when there is one" → "`plan/<slug>/evidence.md` — `findings.md` in a folder from before `glab` 0.10.0 — when there is one".
  - l. 107: "**Never edit `plan.md`, `findings.md`, `questions.md`," → "**Never edit `plan.md`, `master.md`, `master.sha256`, `index.md`, `evidence.md` or `findings.md`, `questions.md`,".
  - The record (l. 102): "those the plan's `## Record` names" → "those `master.md`'s `## Record` names — `plan.md`'s, with no master"; "from the files of `plan/<slug>/`" → "from the files of `plan/<slug>/`, sub-plan folders included,".
  - Between Step 1 and Step 2 add, unnumbered so no step number moves:

        ## Keep your context small

        Everything you read stays in your context and is paid for again on every later call. One developer that read whole test runs and its plan three times peaked past 500k tokens in a single round.

        - **Read the contract once.** After Step 1, re-open only the part you need — `grep -n` for the step id, then read by line range — never the whole plan again.
        - **Gate and test output go to a log; read its end and its failures.** In the temp directory the repo or host names, never `/tmp`:

              log=$(mktemp "${TMPDIR:?}/gate.XXXXXX"); <the gate command> >"$log" 2>&1; rc=$?; tail -n 30 "$log"; echo "rc=$rc"

          On a red gate, `grep -n` the log for the runner's failure lines and read around them by range. The tail and the `rc` are the gate output `result.md` records. Remove each log when you are done with it.
        - **Do not re-read a file after editing it.** Edit fails when it does not apply; check the change with `git diff -- <file>`.
        - **Edit, do not rewrite.** Change an existing file with Edit; Write is for a new file. Rewriting a whole file to change part of it puts the whole file through your context again.
        - **Search before you read.** `grep -n` first, then read the lines that matter; read a large file by range.

  Verify: `grep -c '^## Keep your context small'` → `1`; `grep -c -F 'tail -n 30 "$log"'` → `1`; `grep -c '^## Step [1-5] '` → `5`; `grep -c 'master\.md'` → `≥3`; `grep -c 'evidence\.md'` → `≥2`.

- **S6 The commands.**
  - `commands/plan.md` gate 3: "**A full-tier plan needs my approval** before a line of code is written. A normal-tier plan does not" → "**A full-tier plan, and a split into sub-plans, need my approval** of `master.md` — after the plan check, before a line of code is written (`glab:manager` Stage 1). A normal-tier plan with no sub-plans does not"; last paragraph: "Report the slug, the tier," → "Report the slug, the tier, the goals, the sub-plans when the work split,".
  - `commands/analyze.md`: after l. 8 add: "The slug may name a sub-plan, `<slug>/<nn>-<name>`. With a `master.md` the analyzer also asks the intent question (`glab:analyzer` *The intent question*); after the slug's last commit, `/glab:analyze <slug>` named as the final check asks it of the whole slug (`glab:manager` Stage 6b)."; l. 12: "This step asks one question: **did we build the thing the plan said?**" → "This step asks: **did we build the thing the plan said, and does it serve what the user asked for?**".
  - `commands/develop.md` l. 6: after "then `plan/$ARGUMENTS/plan.md`." add " The slug may name a sub-plan, `<slug>/<nn>-<name>`; its `master.md` is a level up."; in the *Approval* bullet, "**Approval** → full tier only;" → "**Approval** → with a `master.md` (a level up for a sub-plan), its `## Approval` line is there and `sha256sum -c plan/<slug>/master.sha256`, run from the repo root, prints `OK`, or stop and tell me. With none — a plan from before `glab` 0.10.0 — full tier only;"; in *Decide the split*, after the bullet "the slug, and the exact step ids it owns;" add "- the paths of `master.md` and of the plan folder, and that no other sub-plan's folder is read;".
  Verify: `grep -c 'a split into sub-plans, need my approval' commands/plan.md` → `1`; `grep -c 'intent question' commands/analyze.md` → `≥1`; `grep -c 'asks one question' commands/analyze.md` → `0`; `grep -c 'sha256sum -c' commands/develop.md` → `1`; `grep -c 'With none' commands/develop.md` → `1`.

- **S7 The first context step and the stage listing.**
  - `plugins/glab/scripts/context-size.sh`: just before `line=` (l. 113), read `GLAB_COMPACT_AT`: unset or empty → first step 300000, no suffix; matching `^[1-9][0-9]{0,5}$` → that many thousands, suffix `; compact at <v>k`; anything else → one stderr line `glab context-size: GLAB_COMPACT_AT is not a whole number of thousands from 1 to 999999; using 300`, then the default. The line becomes `glab: context ${k}k (last completed call${suffix})`. In `stop`, l. 140–141 compare with and subtract the first step instead of `300000`. Comments (`glab:comments`): the header names the variable, its default and its suffix; why the default is absolute (the user's working limit, the same on every model); why not a per-model table or a fraction (the hook is not told the window); why an invalid value warns instead of failing (a typo must not silence the number) and why it is read after the transcript (each failure path keeps exactly one stderr line); the `stop` comment says "the first step" where it says 300k. Every path still ends `exit 0`.
  - `tests/context-size.test.sh`: `unset GLAB_COMPACT_AT` before T1, so T1–T21 run on the default whatever the caller exported; `stop_case`'s expected text gains `${SUFFIX:-}` before `)`, empty by default. New cases, each exporting the variable and unsetting it after:
    - **T22** `GLAB_COMPACT_AT=150`, T1's fixture: `agent` prints `glab: context 143k (last completed call; compact at 150k)` (PostToolUse), `prompt` the same (UserPromptSubmit); stderr empty.
    - **T23** `GLAB_COMPACT_AT=150`, `SUFFIX='; compact at 150k'`, through `stop_spec`: `'below 150k' '' 'P A100000 P R A140000'`; `'crossed 150k' 160 'A140000 P A145000 P A160000'`; `'same step' '' 'A160000 P A200000 P A240000'`; `'crossed 250k' 251 'A240000 P A245000 P A251000'`.
    - **T24** invalid: for each of `abc`, `0`, `1234567`, `15.5`, `-1`, `agent` on T1's fixture prints the default line with no suffix and stderr is exactly the warning; for `abc`, `stop` on `A250000 P A280000 P A310000` speaks the 310k default message with no suffix, with the warning on stderr — a direct `runt` with its own checks, since `stop_case` wants stderr empty; `GLAB_COMPACT_AT=` (empty) on `agent` prints the default line and nothing on stderr.
    - Order T1, T3–T18, T20–T24, T19, T2; T23's stop runs append to `stopouts` through `stop_case`, so T19 judges them.
  - `manager/SKILL.md` Rule 2: l. 101 — after "it adds one line, `glab: context <n>k (last completed call)`" add ", ending `; compact at <t>k)` when the user set `GLAB_COMPACT_AT`", and "When the context crosses 300k or a further 100k" → "When the context crosses the first step — 300k, or the user's `GLAB_COMPACT_AT` — or a further 100k"; l. 104 — "at the first handoff line at or past **300k**, and again at the first line past each further **100k** — 400k, 500k, … —" → "at the first handoff line at or past the first step — **300k**, or `<t>k` when the line names `compact at <t>k` — and again at the first line past each further **100k** —". After l. 104 add:

        - **A smaller window.** When your model's context window is not larger than the first step plus 100k — a 200k window under the default — tell the user once that the step is near or past the window, and that `GLAB_COMPACT_AT`, in thousands, exported in the shell that starts Claude Code, moves it. The number is the user's; never choose it yourself.

  - `plugins/glab/scripts/manager-bootstrap.sh` l. 17: "commit -> push -> record" → "commit -> final check -> push -> record" (inside the quoted heredoc; nothing else).
  Verify: the test prints `PASS 24/24`; `git show cf614ec:plugins/glab/scripts/context-size.sh >"$TMPDIR/fp-old.sh"; bash tests/context-size.test.sh "$TMPDIR/fp-old.sh" | tail -n 1; rm -f "$TMPDIR/fp-old.sh"` → `FAIL 3/24` (T22, T23, T24 fail); `grep -c -e '-ge 300000' -e '- 300000)' plugins/glab/scripts/context-size.sh` → `0`; `grep -c GLAB_COMPACT_AT` → `≥1` in the script and the test, `≥2` in `manager/SKILL.md`; `grep -c 'final check -> push' plugins/glab/scripts/manager-bootstrap.sh` → `1`.

- **S8 `README.md`, `AGENTS.md` and the version.**
  - `README.md` l. 18–19: "Each change's working files — findings, plan, results — live in `plan/<slug>/`." → "Each change's working files live in `plan/<slug>/`: `master.md` — your request in your words, its goals and the final check, constant once accepted — and one `plan.md`, or sub-plans `<nn>-<name>/` that each run their own cycle. The analyzer checks every stage against `master.md`, the reviewer sees only the code, and a final check before the push compares the master with everything built." After "It never blocks or prolongs a turn." (l. 34): "300k is the default first step. On a model with a smaller context window, export `GLAB_COMPACT_AT` with the first step in thousands — `export GLAB_COMPACT_AT=150` in the shell that starts Claude Code — and the steps become 150k, 250k, …; every line then ends `; compact at 150k)`." After that paragraph, a new one: "Ask for it, and the manager has you approve `master.md` in Claude Code's plan mode instead of the chat; the dialog then sets the session's permission mode, so pick the one you were in. The plugin never changes `plansDirectory`, and the manager writes no plan file under `~/.claude/plans`."
  - `AGENTS.md` *Rules*, the version rule: after "in the same commit." add " When one push carries several commits of one change — one per sub-plan — the first that changes `plugins/<name>/` raises it, once."
  - `AGENTS.md` *One fact*: the round-caps entry "Stage 1b, Stage 3 and Stage 5 at most 2 rounds at every tier" → "Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b) at most 2 rounds at every tier, per sub-plan where there are"; the context-hook entry: "the line `glab: context <n>k (last completed call)`" → "the line `glab: context <n>k (last completed call)`, with `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set", and "the steps 300k and every 100k after it" → "the first step 300k, or `GLAB_COMPACT_AT` thousand when set, and every 100k after it, and the warning for an invalid value"; the entry "the mapping files `map-<area>.md` and the round copies `<name>.r<n>.md`" → "the mapping files `map-<area>.md`, the evidence file `evidence.md` — a subagent's Write of `findings.md` is refused — and the round copies `<name>.r<n>.md`" (files unchanged). After the session-effort entry (it ends `` `README.md`). ``), turn its `.` into `;` and add the entries below, each path but `README.md` written in full from `plugins/glab/`, as the other entries are: "the plan size budget — 48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`, and the `- size:` line (`skills/plan-first/SKILL.md` Step 3, `skills/manager/SKILL.md` acceptance checklist item 6); amendments replace the text they change, in place (`skills/plan-first/SKILL.md` Step 4, `skills/manager/SKILL.md` Stage 1b, `agents/analyzer.md` *Re-checks*); `glab:plan-first`'s step numbers — 0 to 4 in `SKILL.md`, 5 to 7 in `implement.md` (`skills/plan-first/SKILL.md`, `skills/plan-first/implement.md`, `commands/plan.md`, `commands/develop.md`, `skills/manager/SKILL.md`); the master plan and sub-plans — `master.md` with its six sections, constant after `## Approval` and hashed in `master.sha256`, `index.md`, the folders `<nn>-<name>/`, one commit per sub-plan, one final check, push and record per slug, and `## Record` in the master (`skills/plan-first/SKILL.md`, `skills/manager/SKILL.md`, `agents/analyzer.md`, `agents/developer.md`, `commands/plan.md`, `commands/analyze.md`, `commands/develop.md`, `README.md`); the intent check — the analyzer at Stage 1b, Stage 3 and the final check, never the reviewer (`agents/analyzer.md`, `skills/manager/SKILL.md`, `commands/analyze.md`, `README.md`); the analyzer's verdict lines — `BUILDABLE`, `NOT BUILDABLE`, `CONFORMS`, `DIVERGES: <n> steps`, `BLOCK: target unresolved` (`agents/analyzer.md`, `skills/manager/SKILL.md`, `commands/analyze.md`); approval in plan mode — only when the user asks, no plan file outside the repo, `plansDirectory` never changed (`skills/manager/SKILL.md`, `README.md`); the stage sequence with the final check (`skills/manager/SKILL.md` description, `scripts/manager-bootstrap.sh`)."
  - `plugins/glab/.claude-plugin/plugin.json`: `"version": "0.10.0"`.
  Verify: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.10.0`; `grep -rlF '48 KB' plugins AGENTS.md README.md | sort` → `AGENTS.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`; in `AGENTS.md`: `grep -c 'GLAB_COMPACT_AT'` → `≥1`, `grep -c 'implement.md'` → `≥1`, `grep -c 'evidence.md'` → `≥2`, `grep -c 'master.sha256'` → `1`, `grep -c 'final check (Stage 6b)'` → `1`; `grep -c 'GLAB_COMPACT_AT\|master.md\|plansDirectory' README.md` → `≥3`. Keep each searched phrase unbroken by line wrapping.

### After

The gates of `AGENTS.md`, with `TMPDIR` exported, print exactly the lines of F14, with `PASS 24/24` in place of `PASS 21/21`: `Skills (14)` and `Agents (5)` do not change, since `implement.md` is not a skill (F2). Then `grep -rc 'findings\.md' plugins README.md AGENTS.md | grep -v ':0$'` → `analyzer.md:1`, `developer.md:2`, `plan-first/SKILL.md:1`, `AGENTS.md:1` (older folders and the reasons); `git diff --stat cf614ec -- plugins/glab/agents/reviewer.md plugins/glab/commands/review.md plugins/glab/commands/ship.md` prints nothing; `wc -c` of `plan.md` and `evidence.md` ≤ 49152; the S1–S8 searches print their values. Integration at normal tier is the milestone test. Back out: revert the commit; with `GLAB_COMPACT_AT` unset the hook behaves as at `0.9.0`, and a folder with no `master.md` runs the 0.9.0 rules.

Cannot discriminate, by design: each `grep -c … → 0` prints `0` on an untouched tree too, so each is paired with a presence check on its file; the reviewer files' empty diff guards against a stray edit only.

Tests added: T22, T23, T24 in `tests/context-size.test.sh`. Coverage: S7's script by T22 (suffix, both context modes), T23 (moved step, steps of 100k, suffix in `stop`), T24 (warning, default, empty), T1–T21 (default unchanged), T19 and T2 over every run. S1–S6, S8 and S7's heredoc line are Markdown, JSON and fixed text with no test: the searches, `bash -n`, shellcheck and `plugin validate` cover them; the sub-plan cycle first runs in the next split plan (FU9) — accepted, as nothing can run it sooner.

### Live tests — the user's, in their own terminal (D37)

They call a model in the user's own configuration, so the user runs them, as `[flow-cheaper-rounds/plan.md D41]` set for I1: `d=$(mktemp -d "$TMPDIR/pm.XXXXXX"); cd "$d"; git init -q; claude --version`, then `claude`. Before and after each, in a second terminal: `ls -t ~/.claude/plans 2>/dev/null | head -3`. The manager carries the results into the record.

- **L1 Inline plan.** Ask: "Call EnterPlanMode, then ExitPlanMode with exactly the plan text `L1 probe`. Write no file." Record: whether it took the text without a Write, whether a file appeared under `~/.claude/plans` (name, content), what the dialog showed.
- **L2 `plansDirectory`.** Write `$d/.claude/settings.local.json` as `{"plansDirectory": "plans-l2"}` yourself, restart `claude`, repeat L1: where did the file land, under which name?
- **L3 The three answers.** L1 three times — approve; "No, keep planning" with `change one line`; Ctrl+G, add a line, approve — each time asking the model to quote the ExitPlanMode result. Record whether it carries the feedback and the edit.
- **L4 The mode after approval.** Each mode the dialog offers, the footer's mode afterwards, and whether the session's earlier mode is offered.
- **L5 A subagent in plan mode.** "Dispatch a general-purpose subagent to write `l5.txt` here." Record any refusal; `ls l5.txt`.
- **L6 Desktop.** L1 in the desktop app: what the Plan pane shows.
- **L7 The tools.** Ask the main session, then a general-purpose subagent: "List your tools whose names contain PlanMode." 

Then `rm -rf "$d"`.

## Follow-ups

- FU1 A `glab:planner` agent and the analyzer's two kinds — into `flow-models-per-role` (carries `[flow-cheaper-rounds/plan.md FU1]`); open.
- FU2 `[flow-cheaper-rounds/plan.md FU2]`, Steps 5–7 out of `glab:plan-first`: closed by S1.
- FU3 A size warning for a subagent's own context: needs proof that hooks fire inside a subagent, and with which `transcript_path`; open, UNVERIFIED.
- FU4 Whether a settings file's `env` block reaches a plugin hook; open, UNVERIFIED.
- FU5 The manager's own gate runs could use the developer's log template; open.
- FU6 `[flow-cheaper-rounds/plan.md FU6]`, a subagent cannot write `findings.md`: closed by `evidence.md` (S1, S2, S4, S5; F8).
- FU7 L1–L7 unverified until the user runs them; if ExitPlanMode needs a file and `plansDirectory` stays default, plan-mode approval stays unused; open.
- FU8 Which other names the Write rule refuses (`summary.md`, `report.md`) is untested (F8); open.
- FU9 The first split plan first runs the sub-plan cycle, the hash and Stage 6b; its record says what they cost and caught; open.

## Incidents

- IN1 The Write tool refused `plan/flow-planner/findings.md` to this planning subagent — "Subagents should return findings as text, not write report files" — in round 1 and in round 2's probe (F8); the findings are `evidence.md` (D1).

## Record

After the push, `glab:manager` Stage 8 updates `docs/specs/workflow.md` — *How it works now*: the size and shape rule, `implement.md`, the developer's context rules, `GLAB_COMPACT_AT`, the master and sub-plans, the intent check, Stage 6b, plan-mode approval, `evidence.md`; *Decisions that still bind*: D2–D7, D9, D10, D12–D17, D21, D23–D40, naming what D12, D26 and D31 amend; *Known limits*: L1–L7 as reported; *Open follow-ups*: FU1, FU3–FU5, FU7–FU9, `[flow-cheaper-rounds/plan.md FU1]` re-pointed to FU1; *Closed*: `[flow-cheaper-rounds/plan.md FU2]` (FU2) and `FU6` (FU6); *Incidents*: IN1 — and `docs/specs/marketplace.md`: the *One fact* changes of S8, the version rule per push, `glab` `0.10.0`. No audit file.
