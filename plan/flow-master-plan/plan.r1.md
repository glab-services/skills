tier: normal — payload text, one quoted heredoc, `AGENTS.md`, `README.md` and the manifest version; no full-tier trigger.

# flow-master-plan — a constant master plan, sub-plans and the intent check

**Depends on `flow-planner` having landed on `origin/main` (`glab` 0.10.0).** Do not run Stage 1b or build before it has (D43, B0). Every edit below is written against the tree as it is after `flow-planner`: a place in a file `flow-planner` changes is cited by heading or quoted text — `l.` only where noted as unmoved by it — and Stage 1b re-resolves every citation against that tree. `commands/*.md` and `scripts/manager-bootstrap.sh` are not changed by `flow-planner`: their `l.` are at `cf614ec`.

Round 3 split `plan/flow-planner/plan.r2.md` in two, so the low-risk part ships first. This plan, `glab` 0.10.0 → 0.11.0, carries round 2's D23–D37, D39, D40 and D42, and the split's D43–D45; step ids are round 2's — S1–S8, each holding only this plan's part, S3 and S6 whole. Evidence: `evidence.md` (F0, F3, F10–F16, *Boundary* B5–B12). `[flow-planner/…]` cites the other plan; read it with `git show` once its folder is removed.

## Decisions

- effort: high, for the session — the user's words after the 2026-10-22 compact: "Subagent effort high (record the `- effort:` line in each plan)".
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
- D39 `## Record` moves to `master.md`; a folder with no master keeps `plan.md`'s.
- D40 The stage listings gain "final check" (F13).
- D42 A single plan's Stage 1b analyzer reads `master.md` and `plan.md` together.
- D43 (round 3, the split) This plan is built on the tree `flow-planner` leaves on `origin/main`, and nothing in `flow-planner` depends on it; its Stage 1b re-resolves every citation against that tree.
- D44 (round 3, the split) As `[flow-planner/plan.md D18]`, `D19`, `D20` and `D22`, for this plan: `glab` 0.10.0 → 0.11.0, nothing removed, so no `!`, `memory-sync` untouched; one `glab:developer`, one commit with the plan folder, and *One fact* changes as S8 says.
- D45 (round 3, the split) This plan runs under the 0.10.0 rules it changes, as `[flow-planner/plan.md D41]` did under 0.9.0: no `master.md`, its findings in `evidence.md`; the user's words are in D23, D32, D37.

## Milestone

The Markdown has no runtime: the S1–S8 searches prove it, and L1–L7 the plan-mode behaviour; every gate in *After* prints its line, `PASS 24/24` unchanged from `flow-planner`. The sub-plan cycle, the hash and Stage 6b first run in the next split plan (FU9).

## Steps

### Before

- B0 `flow-planner` has landed: `git show origin/main:plugins/glab/.claude-plugin/plugin.json | jq -r .version` → `0.10.0`, and `git show origin/main:plugins/glab/skills/plan-first/implement.md | head -n 1` → `# Plan First — implementation`; otherwise stop. `git status --short -uall` shows only `plan/` untracked; `export TMPDIR=/data/tmp/claude`; the gates print `[flow-planner/plan.md]` *After*: F14 with `PASS 24/24`.

### Processing

- **S1 `plugins/glab/skills/plan-first/SKILL.md`.**
  - Step 0 (l. 19, unmoved by `flow-planner`): "Normal tier writes one page: `plan.md` alone, with findings and decisions as sections of it." → "Normal tier writes `master.md` and one page, `plan.md`, with evidence and decisions as sections of it."
  - Step 3, the `## Record` bullet (l. 79, unmoved): its first words "`## Record` — the area spec" → "`## Record`, in `master.md` (below) — the area spec".
  - The *Size and shape* paragraph `flow-planner` added after Step 3 (it starts "**Size and shape — every later agent reads the plan again**"): "Keep `plan.md` and `evidence.md` at or under **48 KB** each" → "Keep `master.md`, `plan.md`, `index.md` and `evidence.md` at or under **48 KB** each"; "split it. When it cannot" → "split it (below). When it cannot". This extends `[flow-planner/plan.md D2]` to the two files this plan adds. After that paragraph add:

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

  - Step 4's amending paragraph (`flow-planner`'s text, starting "**Amending after a plan check.**"): before its last sentence, "Step 1 is not run again, except for a gap a finding opens.", insert "A `master.md` with an `## Approval` line is never amended: a change to the request goes back to the user. ".
  - Step 4: "at full tier, the user has approved the plan;" → "the plan check has passed and `master.md` has its `## Approval` line — the user's at full tier and whenever the work split;".
  - *Plan files are working files*: "A plan folder whose `plan.md` has no `## Record`" → "A plan folder whose `master.md` — or `plan.md`, in a folder with no master — has no `## Record`".
  - Quick Reference: above the Analyze row (`` `plan/{slug}/evidence.md` `` since `flow-planner`) add `| Intent | Request, goals, final check, record | `plan/{slug}/master.md`, the split in `index.md` |`; Verify row → "the plan check, then the master's approval".
  Verify: `grep -c 'evidence\.md'` → `≥4`; `grep -c 'findings\.md'` → `1` (the reason in Step 1); `grep -c '^### The master plan, and sub-plans'` → `1`; `grep -c -F '`master.md`, `plan.md`, `index.md` and `evidence.md` at or under **48 KB**'` → `1`; `grep -c 'split it (below)'` → `1`; `grep -c 'is never amended: a change to the request goes back to the user'` → `1`; `grep -c 'the user has approved the plan'` → `0`; `grep -c '^## Step [0-4] '` → `5`.

- **S2 `plugins/glab/skills/manager/SKILL.md` — tables, the layout, Stage 1, Stage 1b.**
  - l. 3 description (unmoved by `flow-planner`): "→ commit → push → record" → "→ commit → final check → push → record". Rule 2 l. 91 (unmoved): "Stages 1b, 2, 3, 5 and 8" → "Stages 1b, 2, 3, 5, 6b and 8".
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

  - Acceptance checklist (`flow-planner` left six items): "until all six hold" → "until all seven hold"; in item 6, "caps `plan.md` and `evidence.md` at 48 KB each" → "caps `master.md`, `plan.md`, `index.md` and `evidence.md` at 48 KB each"; after item 6 add:

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

  - Stage 1b, the amendment paragraph (`flow-planner`'s text, with "replacing the changed text in place"): after "`<n>` being the round that checked them." add " The same holds for `master.md` before its approval and for `index.md`, each copied as `<name>.r<n>.md` beside it."
  Verify: `grep -c 'findings\.md\|findings\.r<n>'` → `0`; `grep -c 'until all seven hold'` → `1`; `grep -c 'until all six hold'` → `0`; `grep -c '^7\. \*\*A master\.\*\*'` → `1`; `grep -c -F 'caps `master.md`, `plan.md`, `index.md` and `evidence.md` at 48 KB'` → `1`; `grep -c '^## The master plan and sub-plans'` → `1`; `grep -c '^### Approval in Claude Code.s plan mode'` → `1`; `grep -c 'Ask the intent question too'` → `1`; `grep -c 'final check → push'` → `1`; `grep -c -F 'sha256sum plan/{slug}/master.md'` → `1`; `grep -c 'each copied as `<name>.r<n>.md` beside it'` → `1`.

- **S3 `plugins/glab/skills/manager/SKILL.md` — Stages 3, 6, 6b, 7, 8.**
  - Stage 3: "**Full tier only.** At normal tier the step list" → "**Full tier, and every sub-plan at every tier.** At normal tier with no sub-plans the step list"; after its "then Stage 4" add "; the intent question waits for the final check (Stage 6b)".
  - After Stage 3's "Do not let it drift." add: "Where the folder has a master it also asks the intent question: does the build serve the master's goals, beyond matching the steps? A step built as written that misses its goal is a defect of the plan: it goes to a planning agent's amendment, then Stage 2 — never to a developer told to build past its plan."
  - Stage 6, after its first paragraph, add: "With sub-plans, commit each one after its Stage 5: its own folder, and with the first also `master.md`, `master.sha256`, `index.md` and the map files. Nothing is pushed before the final check."
  - Between Stage 6 and Stage 7 add:

        ## Stage 6b — Final check

        After the slug's last commit, before the push, at every tier: `/glab:analyze {slug}` as the final check. The analyzer reads `master.md`, `index.md` and the range from the `## Approval` base to `HEAD`, and asks of every goal whether it is delivered, and where. Run the gates yourself on that tree. Skipped only for a single plan at full tier, whose Stage 3, delta rounds included, asked it.

        `CONFORMS` → Stage 7. `DIVERGES` → the gaps go to a new planning agent: with sub-plans, a new sub-plan with the next `<nn>` and its line in `index.md`; without, an amendment of `plan.md`. It runs its cycle to its commit; round 2 gets round 1's findings and the two commit ids. At most 2 rounds, a third under *Pick the tier*'s rule, its line in `index.md` (`plan.md` with no sub-plans); still diverging: bring it to the user.

  - Stage 7: "Show the plan's `## Decisions` lines with them" → "Show the `## Decisions` lines of each plan the push carries".
  - Stage 8: "the plan's `## Record` names" → "`master.md`'s `## Record` names — `plan.md`'s, with no master —", and "from the folder's files" → "from the folder's files, sub-plan folders included"; "whose `plan.md` has no `## Record`" → "whose `master.md` — or `plan.md`, with no master — has no `## Record`".
  - *When subagent dispatch is not available*: after "`<slug> review`," add " `<slug> final`,".
  - *What you never do*: "Give the reviewer the plan." → "Give the reviewer the plan, `master.md` or `index.md`."; add the bullet "Edit `master.md` after its `## Approval`, or enter plan mode the user did not ask for."
  Verify: `grep -c '^## Stage 6b — Final check'` → `1`; `grep -c 'Full tier, and every sub-plan at every tier'` → `1`; `grep -c 'build past its plan'` → `1`; `grep -c 'Nothing is pushed before the final check'` → `1`; `grep -c 'or enter plan mode the user did not ask for'` → `1`.

- **S4 `plugins/glab/agents/analyzer.md`.**
  - l. 3 description (unmoved by `flow-planner`): "Checks an implementation against its plan in plan/{slug}/ — conformance only" → "Checks a plan before the build, and an implementation after it, against the plan and the user's request in master.md — conformance and intent only"; "ending in CONFORMS or DIVERGES" → "ending in BUILDABLE, NOT BUILDABLE, CONFORMS or DIVERGES".
  - l. 7 (unmoved), after "**did the implementation do what the plan said?**" add " With a master you also ask whether it serves what the user asked for (*The intent question*)."
  - Step 1 list, first bullet before `plan.md`: "- `master.md` — `plan/<slug>/master.md`, or for a sub-plan `plan/<slug>/<nn>-<name>/` the one a level up — when there is one: the request and its goals. First run `sha256sum -c plan/<slug>/master.sha256` from the repo root when that file exists; anything but `OK` is a finding rated `high` — the master changed after approval. Of `index.md` read only your folder's line, except in a coverage or final check. Never read another sub-plan's folder."
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

  - *Re-checks* (`flow-planner`'s text): "each `<name>.r<n>.md` the manager kept with its current file — `plan.md`, `evidence.md`" → "each `<name>.r<n>.md` the manager kept with its current file — `plan.md`, `evidence.md`, `master.md`, `index.md`".
  - Record check: "every file of `plan/<slug>/`" → "every file of `plan/<slug>/`, its sub-plan folders included,".
  - *Report*, the verdict list: before `CONFORMS` add "- `BUILDABLE` — a plan check: every step can be built as written and the intent question found no gap." and "- `NOT BUILDABLE` — a plan check: anything else."
  Verify: `grep -c '^## The intent question'` → `1`; `grep -c '^## The plan check'` → `1`; `grep -c '^## The final check'` → `1`; `grep -c 'NOT BUILDABLE'` → `≥2`; `grep -c 'sha256sum -c'` → `1`; `grep -c -F '`plan.md`, `evidence.md`, `master.md`, `index.md`'` → `1`; `grep -c 'rather than replacing it in place'` → `1` (`flow-planner`'s, kept); `grep -c 'findings\.md'` → `1`.

- **S5 `plugins/glab/agents/developer.md`.**
  - Step 1 list, after the `AGENTS.md` bullet: "- `master.md` — `plan/<slug>/master.md`, a level up for a sub-plan — when there is one: why the work exists. Context, not scope: a step that, built as written, cannot serve its goal is `PLAN WRONG`, not something to build around. Never read another sub-plan's folder."
  - `flow-planner`'s "**Never edit `plan.md`, `evidence.md` or `findings.md`, `questions.md`," → "**Never edit `plan.md`, `master.md`, `master.sha256`, `index.md`, `evidence.md` or `findings.md`, `questions.md`,".
  - The record: "those the plan's `## Record` names" → "those `master.md`'s `## Record` names — `plan.md`'s, with no master"; "from the files of `plan/<slug>/`" → "from the files of `plan/<slug>/`, sub-plan folders included,".
  Verify: `grep -c 'master\.md'` → `≥3`; `grep -c 'master\.sha256'` → `1`; `grep -c '^## Keep your context small'` → `1` (`flow-planner`'s, kept); `grep -c '^## Step [1-5] '` → `5`; `grep -c 'findings\.md'` → `2`.

- **S6 The commands** (unchanged by `flow-planner`; `l.` at `cf614ec`).
  - `commands/plan.md` gate 3: "**A full-tier plan needs my approval** before a line of code is written. A normal-tier plan does not" → "**A full-tier plan, and a split into sub-plans, need my approval** of `master.md` — after the plan check, before a line of code is written (`glab:manager` Stage 1). A normal-tier plan with no sub-plans does not"; last paragraph: "Report the slug, the tier," → "Report the slug, the tier, the goals, the sub-plans when the work split,".
  - `commands/analyze.md`: after l. 8 add: "The slug may name a sub-plan, `<slug>/<nn>-<name>`. With a `master.md` the analyzer also asks the intent question (`glab:analyzer` *The intent question*); after the slug's last commit, `/glab:analyze <slug>` named as the final check asks it of the whole slug (`glab:manager` Stage 6b)."; l. 12: "This step asks one question: **did we build the thing the plan said?**" → "This step asks: **did we build the thing the plan said, and does it serve what the user asked for?**".
  - `commands/develop.md` l. 6: after "then `plan/$ARGUMENTS/plan.md`." add " The slug may name a sub-plan, `<slug>/<nn>-<name>`; its `master.md` is a level up."; in the *Approval* bullet, "**Approval** → full tier only;" → "**Approval** → with a `master.md` (a level up for a sub-plan), its `## Approval` line is there and `sha256sum -c plan/<slug>/master.sha256`, run from the repo root, prints `OK`, or stop and tell me. With none — a plan from before `glab` 0.10.0 — full tier only;"; in *Decide the split*, after the bullet "the slug, and the exact step ids it owns;" add "- the paths of `master.md` and of the plan folder, and that no other sub-plan's folder is read;".
  Verify: `grep -c 'a split into sub-plans, need my approval' commands/plan.md` → `1`; `grep -c 'intent question' commands/analyze.md` → `≥1`; `grep -c 'asks one question' commands/analyze.md` → `0`; `grep -c 'sha256sum -c' commands/develop.md` → `1`; `grep -c 'With none' commands/develop.md` → `1`.

- **S7 The stage listing.**
  - `plugins/glab/scripts/manager-bootstrap.sh` l. 17 (unchanged by `flow-planner`): "commit -> push -> record" → "commit -> final check -> push -> record" (inside the quoted heredoc; nothing else).
  Verify: `grep -c 'final check -> push' plugins/glab/scripts/manager-bootstrap.sh` → `1`.

- **S8 `README.md`, `AGENTS.md` and the version.**
  - `README.md` l. 18–19 (unmoved by `flow-planner`): "Each change's working files — findings, plan, results — live in `plan/<slug>/`." → "Each change's working files live in `plan/<slug>/`: `master.md` — your request in your words, its goals and the final check, constant once accepted — and one `plan.md`, or sub-plans `<nn>-<name>/` that each run their own cycle. The analyzer checks every stage against `master.md`, the reviewer sees only the code, and a final check before the push compares the master with everything built." After `flow-planner`'s paragraph that starts "300k is the default first step.", a new one: "Ask for it, and the manager has you approve `master.md` in Claude Code's plan mode instead of the chat; the dialog then sets the session's permission mode, so pick the one you were in. The plugin never changes `plansDirectory`, and the manager writes no plan file under `~/.claude/plans`."
  - `AGENTS.md` *Rules*, the version rule: after "in the same commit." add " When one push carries several commits of one change — one per sub-plan — the first that changes `plugins/<name>/` raises it, once."
  - `AGENTS.md` *One fact*: the round-caps entry "Stage 1b, Stage 3 and Stage 5 at most 2 rounds at every tier" → "Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b) at most 2 rounds at every tier, per sub-plan where there are"; in `flow-planner`'s plan-size-budget entry, "48 KB each for `plan.md` and `evidence.md`" → "48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`". After `flow-planner`'s last entry (`glab:plan-first`'s step numbers; it ends `` `skills/manager/SKILL.md`). ``), turn its `.` into `;` and add, each path but `README.md` written in full from `plugins/glab/`, as the other entries are: "the master plan and sub-plans — `master.md` with its six sections, constant after `## Approval` and hashed in `master.sha256`, `index.md`, the folders `<nn>-<name>/`, one commit per sub-plan, one final check, push and record per slug, and `## Record` in the master (`skills/plan-first/SKILL.md`, `skills/manager/SKILL.md`, `agents/analyzer.md`, `agents/developer.md`, `commands/plan.md`, `commands/analyze.md`, `commands/develop.md`, `README.md`); the intent check — the analyzer at Stage 1b, Stage 3 and the final check, never the reviewer (`agents/analyzer.md`, `skills/manager/SKILL.md`, `commands/analyze.md`, `README.md`); the analyzer's verdict lines — `BUILDABLE`, `NOT BUILDABLE`, `CONFORMS`, `DIVERGES: <n> steps`, `BLOCK: target unresolved` (`agents/analyzer.md`, `skills/manager/SKILL.md`, `commands/analyze.md`); approval in plan mode — only when the user asks, no plan file outside the repo, `plansDirectory` never changed (`skills/manager/SKILL.md`, `README.md`); the stage sequence with the final check (`skills/manager/SKILL.md` description, `scripts/manager-bootstrap.sh`)."
  - `plugins/glab/.claude-plugin/plugin.json`: `"version": "0.11.0"`.
  Verify: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.11.0`; `grep -rlF '48 KB' plugins AGENTS.md README.md | sort` → `AGENTS.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`; in `AGENTS.md`: `grep -c 'master.sha256'` → `1`, `grep -c 'final check (Stage 6b)'` → `1`, `grep -c 'raises it, once'` → `1`, `grep -c -F '48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`'` → `1`; `grep -c 'GLAB_COMPACT_AT\|master.md\|plansDirectory' README.md` → `≥3`. Keep each searched phrase unbroken by line wrapping.

### After

The gates of `AGENTS.md`, with `TMPDIR` exported, print exactly the lines of F14, with `PASS 24/24` in place of `PASS 21/21` — as after `flow-planner`: `Skills (14)` and `Agents (5)` do not change. Then `grep -rc 'findings\.md' plugins README.md AGENTS.md | grep -v ':0$'` → `analyzer.md:1`, `developer.md:2`, `plan-first/SKILL.md:1`, `AGENTS.md:1`, as after `flow-planner`; `git diff --stat cf614ec -- plugins/glab/agents/reviewer.md plugins/glab/commands/review.md plugins/glab/commands/ship.md` prints nothing; `git diff --stat origin/main -- plugins/glab/scripts/context-size.sh tests plugins/glab/skills/plan-first/implement.md` prints nothing (`flow-planner`'s files, untouched here); `wc -c` of `plan.md` and `evidence.md` ≤ 49152; the S1–S8 searches print their values. Integration at normal tier is the milestone test. Back out: revert the commit; a folder with no `master.md` runs the 0.10.0 rules.

Cannot discriminate, by design: each `grep -c … → 0` prints `0` on an untouched tree too, so each is paired with a presence check on its file; the reviewer files' empty diff guards against a stray edit only.

Tests added: none. Coverage: S1–S8 are Markdown, JSON and fixed heredoc text with no test: the searches, `bash -n`, shellcheck and `plugin validate` cover them; the sub-plan cycle first runs in the next split plan (FU9) — accepted, as nothing can run it sooner.

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

- FU7 L1–L7 unverified until the user runs them; if ExitPlanMode needs a file and `plansDirectory` stays default, plan-mode approval stays unused; open.
- FU9 The first split plan first runs the sub-plan cycle, the hash and Stage 6b; its record says what they cost and caught; open.

The analyzer's two kinds (D36) and the planner agent are `[flow-planner/plan.md FU1]`.

## Record

After the push, `glab:manager` Stage 8 updates `docs/specs/workflow.md` — *How it works now*: the master and sub-plans, the intent check, Stage 6b, plan-mode approval, `## Record` in the master; *Decisions that still bind*: D23–D37, D39, D40, naming what D26 and D31 amend; *Known limits*: L1–L7 as reported; *Open follow-ups*: FU7, FU9 — and `docs/specs/marketplace.md`: the *One fact* changes of S8, the version rule per push, `glab` `0.11.0`. No audit file.
