# Steps 3 — the rules of every level, the project level's edges, the level wiring (J1–J12)

Paths are under `plugins/glab/`. A step that replaces text names the old text
(`N` post) and the new (`P` post). Today's project skills keep their names
(Q2). The contracts C1–C11 are in `plan.md`; payload text states what they
say and never cites `C<n>`. J2 runs before every other step that edits
`skills/manager/SKILL.md`, because it moves text out of it.

### J1 — `glab:manager` says its level

In `skills/manager/SKILL.md`'s frontmatter, begin the `description:` with
`Project level — `, and replace its `Autoloaded at session start;` with
`Loaded at session start at the project level;`.

- post: `` P plugins/glab/skills/manager/SKILL.md 'description: Project level — The operating model' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'Loaded at session start at the project level;' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'Autoloaded at session start;' ``

### J2 — `glab:session-rules`: the rules both managers act on, moved out of `glab:manager`

Create `skills/session-rules/SKILL.md` and move into it, out of
`skills/manager/SKILL.md`, the text both managers act on (I12, R6, R7). Moved
text keeps its words but for the edits listed here.

1. Frontmatter: `name: session-rules`, and a `description:` with no level prefix — it serves every level — that begins `The rules every glab manager runs under, at every level` and names what it holds: the working agreement first, evidence alongside, what reaches an agent, the effort and the model of every dispatch, who implements and what skips the pipeline, the context budget, decide-record-move-on and its four ask-conditions, the round caps, the handoff line and the level boundary; loaded at session start with the manager of the session's level.
2. A heading `# Session rules`, then, as the skill's first section, `## The level boundary` (item 8) — first because after a compaction Claude Code keeps only the first part of each skill it re-attaches (F22; the user's decision of 2026-11-13) — then the section `## How to read these rules`. It says: each level's manager — `glab:manager` at the project level, `glab:product-manager` at the product level — runs under these rules and cites them by number; required text `it means the stage of the same role in the manager of your level` — where a rule names a stage, a section or a stage skill (Stage 1b, *Pick the tier*, *The pipeline*, `/glab:review`), it names the project level's, and at the product level it means the stage of the same role in the manager of your level, while a rule about a stage that level does not have does not apply there; `plan/{slug}/plan.md` is `plan/{slug}/product-plan.md` at the product level. Then a paragraph that begins `**Where a record line goes.**`: each line these rules say to write under `## Decisions` in `plan.md` goes there, except in a project plan from a brief, where, from its first report on, it goes to `` `plan/{slug}/after-verdict.md` `` (`glab:manager` Stage 1c).
3. Move, in this order, the sections `## Rule 0 — the working agreement first, always`, `## Rule 0b — …`, `## Rule 0c — …`, `## Rule 0d — …`, `## Rule 1 — you are not the implementer`, `## Rule 2 — the context budget` with its `### Your own context …`, `## Rule 3 — decide, record, move on`, and `## Rule 5 — each agent runs on its role's model; the user's words override it`, each with its whole body. `## Rule 4 — what this session owns` stays in `glab:manager`: one session's surface is a project-level fact.
4. In the moved Rule 1, replace `goes through the stages below, at the tier *Pick the tier* gives it.` with `goes through the pipeline of the manager of your level — at the project level at the tier `glab:manager` *Pick the tier* gives it.`
5. In the moved Rule 5: add to its list of roles, after `glab:committer` — `haiku`, the two lines `` `glab:product-planner` — `opus`: the product plan, the briefs, the rule drafts; `` and `` `glab:product-analyzer` — `opus`: the product plan check, the project plan audit. `` (Q1, R5); replace `not one of the seven` with `not one of the nine`; and replace `— Rule 4 does not apply to the model choice —` with `` — `glab:manager` Rule 4 does not apply to the model choice — ``.
6. Move the paragraph of `glab:manager` *Pick the tier* that begins `**Round caps.**` into a section `## Round caps`, its first sentence beginning `Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b) at the project level, and P1b at the product level, run at most **2 rounds** each`; in its place in *Pick the tier*, the line `**Round caps** — `glab:session-rules` *Round caps*.`
7. Move, from `glab:manager` *The pipeline*, the sentences from `Announce each handoff in one line:` to the end of that paragraph, and the next paragraph, `With sub-plans the line names the sub-plan for the slug: …`, into a section `## The handoff line`; in their place, `Announce each handoff as `glab:session-rules` *The handoff line* says.`
8. The section `## The level boundary`, the first of the skill (item 2; a post checks the order): each level's manager names the skills its session may use in its *Your skills — this level only*; required text `invoke no skill that is not on the list of your manager`, whatever its name or description says — the listing can drop a skill's description to fit its budget (F14), and a name's prefix does not always say the level (`glab:product-project-plan-report` is the project level's); a skill that serves every level carries no level prefix and may be on any list; every other skill's and agent's description begins with its level, `Product level — ` or `Project level — `, a hint and never the rule.
9. In `skills/manager/SKILL.md`, where Rule 0 began, add the section `## The rules of every level`: `glab:session-rules` holds Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, *Round caps*, *The handoff line* and *The level boundary*; they bind this level as every level, and a Rule `<n>` cited here, but Rule 4, is that skill's; it is loaded with this skill. Required text: `a Rule <n> cited here, but Rule 4, is that skill's`.
10. In the moved text, point each pointer at the section that now holds what it names (R2-2): in Rule 0d, `(see *The pipeline*)` becomes `(see *The handoff line*)`; in Rule 5, `the tier and the round caps stay what *Pick the tier* gives them` becomes `` the tier stays what `glab:manager` *Pick the tier* gives it and the round caps what *Round caps* gives them ``; in *The handoff line*, `round cap (*Pick the tier*)` becomes `round cap (*Round caps*)`; and in Rule 3, `` `/glab:push` and *What you never do* say so for the push `` becomes `` `glab:push` says so for the push, at every level `` — the product manager has no *What you never do*, and `glab:push` waits for the user's go-ahead at both levels.

- post: `` P plugins/glab/skills/session-rules/SKILL.md 'name: session-rules' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'description: The rules every glab manager runs under, at every level' ``
- post: `` test "$(command grep -m 1 '^## ' plugins/glab/skills/session-rules/SKILL.md 2>/dev/null)" = '## The level boundary' && echo ok || echo 'FAIL J2 the level boundary is not the first section' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '## Rule 0 — ' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '## Rule 0b — ' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '## Rule 0d — ' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'it means the stage of the same role in the manager of your level' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '**Where a record line goes.**' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '`plan/{slug}/after-verdict.md`' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '## Rule 0c — what reaches an agent, and once' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '## Rule 3 — decide, record, move on' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '### Your own context — read it, act on it, never clear' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'goes through the pipeline of the manager of your level' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '`glab:product-analyzer` — `opus`' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'not one of the nine' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '`glab:manager` Rule 4 does not apply to the model choice' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'and P1b at the product level, run at most **2 rounds** each' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '## The handoff line' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'invoke no skill that is not on the list of your manager' ``
- post: `` N plugins/glab/skills/session-rules/SKILL.md '## Rule 4 — what this session owns' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '(see *The handoff line*)' ``
- post: `` N plugins/glab/skills/session-rules/SKILL.md '(see *The pipeline*)' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'the round caps what *Round caps* gives them' ``
- post: `` N plugins/glab/skills/session-rules/SKILL.md 'the round caps stay what *Pick the tier* gives them' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md 'round cap (*Round caps*)' ``
- post: `` N plugins/glab/skills/session-rules/SKILL.md 'round cap (*Pick the tier*)' ``
- post: `` P plugins/glab/skills/session-rules/SKILL.md '`glab:push` says so for the push, at every level' ``
- post: `` N plugins/glab/skills/session-rules/SKILL.md '*What you never do* say so for the push' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'a Rule <n> cited here, but Rule 4, is that skill'"'"'s' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '## Rule 4 — what this session owns' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 5 — each agent runs on its role' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 2 — the context budget' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 0b — ' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 0 — ' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 0c — ' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 0d — ' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 1 — ' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '## Rule 3 — ' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '**Round caps.** Stage 1b' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'Announce each handoff in one line:' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '**Round caps** — `glab:session-rules` *Round caps*.' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'Announce each handoff as `glab:session-rules` *The handoff line* says.' ``

### J3 — `glab:manager` names its skills

In `skills/manager/SKILL.md`, after *The rules of every level*, add the
section `## Your skills — this level only`, the list `glab:session-rules`
*The level boundary* binds to: the stage skills `glab:plan`, `glab:develop`,
`glab:analyze`, `glab:integrate`, `glab:review`, `glab:ship` and
`glab:product-project-plan-report`; the skills of every level
`glab:session-rules`, `glab:bootstrap`, `glab:security`, `glab:comments`,
`glab:audit`, `glab:commit`, `glab:push`; and the agents `glab:planner`,
`glab:plan-analyzer`, `glab:developer`, `glab:analyzer`, `glab:integrator`,
`glab:reviewer`, `glab:committer`.

- post: `` P plugins/glab/skills/manager/SKILL.md '## Your skills — this level only' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '`glab:ship` and `glab:product-project-plan-report`' ``

### J4 — Stage 1 takes a brief

In `skills/manager/SKILL.md` *Stage 1 — Plan*, after its first paragraph,
add a paragraph beginning `**A brief is a request.**`: a session told to take
the brief at `<store>/briefs/<project>/brief.md` — by the user or by the
product manager — resolves the store from its `glab-shared-store:` line
(the repo's `AGENTS.md`, else the host file), and the planner's dispatch
names the brief's store path and the store; how the plan quotes the brief is
`glab:plan`'s. A plan from a brief goes to Stage 1c after its approval.

- post: `` P plugins/glab/skills/manager/SKILL.md '**A brief is a request.**' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'take the brief at `<store>/briefs/<project>/brief.md`' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'glab-shared-store:' ``

### J5 — Stage 1c, the report to product, the frozen plan and the wait

In `skills/manager/SKILL.md`:

1. In *The pipeline*'s table, after row `1b`, add the row `| 1c | Report to product | `/glab:product-project-plan-report {slug}`, for a plan from a brief, once per slug | the store's `report.r<n>.md` and `plan.r<n>/` | the verdict |`.
2. In *Stage 1b*, change `then Stage 2 — or, after the master check, the sub-plans` to `then Stage 2 — Stage 1c first for a plan from a brief — or, after the master check, the sub-plans, which for a plan from a brief are all planned, checked and approved before Stage 1c`.
3. In *A question blocks; a decision does not*, after `**write the answer into `plan/{slug}/questions.md` yourself**`, add `— after a report to product, into `after-verdict.md` (Stage 1c) —`.
4. After *Stage 1b*, add the section `## Stage 1c — Report to product, then wait`. It says:
   - for a plan from a brief — its `master.md` carries the brief line — once per slug: when the master and, if the work splits, every sub-plan have been planned, checked at Stage 1b and given every approval their tiers need, run `/glab:product-project-plan-report {slug}`. Required text `one report covers the master and every sub-plan`: one report and one verdict per slug, so the product audits the slug once, not once per sub-plan, and each sub-plan's `glab:develop` checks against that one accepted digest (R2-1). Announce `{slug} · report · r<n> · WAITING · context <n>k` — no agent runs, so the line names no model or effort; tell the product session that the report is there — a session the product session started is watched by its idle notice and needs no message; else `SendMessage` to the product session when `ListAgents` lists it, else ask the user to (F18); bring the handoff file up to date with the report's path; and end the turn;
   - a paragraph that begins `**From the first report on, the plan's hashed files are frozen.**` (R1): `master.md`, `index.md`, every `plan.md`, `questions.md` and every `steps-*.md` are what the product judges and `glab:develop` checks by their hash. Each line `glab:session-rules` or this skill says to write into one of them — an `- effort:` or `- model:` line, a `- round 3:` line, a Rule 3 decision or overrule, a question's answer — goes to `plan/{slug}/after-verdict.md` instead, in the form it would have had, and that file is named in every later dispatch that reads the plan. A line there never changes a step, a goal or a decision the product accepted: that is an amendment, and Stage 1c again. The freeze lifts only for the amendment after a `REJECTED`, until the next report;
   - on resuming, read the latest `verdict.r<n>.md` of the brief, numbers compared as numbers: `ACCEPTED` → Stage 2, whose `glab:develop` checks it; and a bullet that begins with the plain words On REJECTED (required text `On REJECTED`, no backticks inside it): keep the round copies as Stage 1b does, numbered one past the highest round copy there; dispatch a new `glab:planner` for the amendment with the verdict's reason quoted as its findings; run one Stage 1b delta round — one per verdict, which neither resets nor uses Stage 1b's round cap; still `NOT BUILDABLE` after it → the user; then the approvals the tier needs again — at full tier the user approves `plan.md` again and its `## Approval` line is replaced — and Stage 1c again, which sends report `r<n+1>`. Required text `a changed request, not an amendment`: a `REJECTED` whose fix needs `master.md` — a goal, the final check — is a changed request, not an amendment (*The master plan and sub-plans*; R13);
   - a refusal from `glab:develop` that the plan changed since it was accepted — a `PLAN WRONG` amendment, say — is Stage 1c again; one that the brief changed is a changed request. The rejection cap is the product level's; this session reports and waits.
5. In *The master plan and sub-plans*, in the bullet that begins `**In `<nn>` order, one at a time.**`, after its sentence `A sub-plan is planned once what it depends on is committed; independent ones may be planned and checked in parallel.`, add: required text `A plan from a brief is the exception: every sub-plan is planned and checked before Stage 1c` — each from the tree at the master's base and its own `index.md` line, never another sub-plan's folder, because one report covers them all; a sub-plan that the built tree then proves wrong is amended, and reported again (Stage 1c). Development, review and commit still run one sub-plan at a time.

- post: `` P plugins/glab/skills/manager/SKILL.md '| 1c | Report to product |' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'Stage 1c first for a plan from a brief' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'then Stage 2 — or, after the master check, the sub-plans' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'which for a plan from a brief are all planned, checked and approved before Stage 1c' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'one report covers the master and every sub-plan' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'A plan from a brief is the exception: every sub-plan is planned and checked before Stage 1c' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'after a report to product, into `after-verdict.md` (Stage 1c)' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '## Stage 1c — Report to product, then wait' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '· report · r<n> · WAITING' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '**From the first report on, the plan'"'"'s hashed files are frozen.**' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'goes to `plan/{slug}/after-verdict.md` instead' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'On REJECTED' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'a changed request, not an amendment' ``

### J6 — `glab:plan` reads a brief as the request

In `skills/plan/SKILL.md`:

1. In Step 1, after the bullet that begins `The spec of each area the change touches, read first`, add a bullet: when the task is a brief, the product-rule files the brief names bind like `docs/constants.md` — read each from the store; the plan conforms to them. Required text: `the product-rule files the brief names`.
2. In Step 3, after the `## Request` bullet, add: `When the task is a brief, `## Request` holds the brief verbatim`, dated, under its brief line `- brief: briefs/<project>/brief.md sha256 <hash>`, the hash being `sha256sum` of the brief as it was read; the brief is the request's words, and its `## Acceptance` reaches the goals like any other request.
3. In Step 4, in *Amending after a plan check*, say that an amendment after a `REJECTED` verdict works the same way, the verdict's reason being the round's findings. Required text: `or after a REJECTED verdict`.
4. In Step 3, *Planning in cycles*, after `once what it depends on is committed, so it cites the tree it will be built on.`, add: required text `When the task is a brief, every sub-plan is planned before any is built` — from the tree the slug starts on and its own `index.md` line, never another sub-plan's folder, because one report to product covers the master and every sub-plan (`glab:manager` Stage 1c; R2-1).

- post: `` P plugins/glab/skills/plan/SKILL.md 'the product-rule files the brief names' ``
- post: `` P plugins/glab/skills/plan/SKILL.md 'When the task is a brief, `## Request` holds the brief verbatim' ``
- post: `` P plugins/glab/skills/plan/SKILL.md '- brief: briefs/<project>/brief.md sha256 <hash>' ``
- post: `` P plugins/glab/skills/plan/SKILL.md 'or after a REJECTED verdict' ``
- post: `` P plugins/glab/skills/plan/SKILL.md 'When the task is a brief, every sub-plan is planned before any is built' ``

### J7 — `glab:develop` refuses a plan from a brief without a matching verdict

In `skills/develop/SKILL.md` *Preconditions*:

1. In the `questions.md` bullet, after `→ read it.`, add `Read `after-verdict.md` with it when there is one (`glab:manager` Stage 1c).`
2. Before `**Green tree**`, add the bullet `**Product verdict**`: when the slug's `master.md` (a level up for a sub-plan) has a brief line, run, from the repo root, `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" check plan/<slug> <store>` — the slug folder, sub-plans included, and the store from its `glab-shared-store:` line; anything but a line `ACCEPTED r<n> <digest>` and exit 0 → stop, show the `REFUSED:` line, and go to `glab:manager` Stage 1c. Run on every dispatch of this skill, fix rounds included: the manager's own record lines are in `after-verdict.md`, outside the hash, so only a change to what the product accepted is refused (R1).

- post: `` P plugins/glab/skills/develop/SKILL.md 'Read `after-verdict.md` with it when there is one' ``
- post: `` P plugins/glab/skills/develop/SKILL.md '**Product verdict**' ``
- post: `` P plugins/glab/skills/develop/SKILL.md 'plan-gate.sh" check plan/<slug> <store>' ``

### J8 — a plan from a brief quotes it (I2)

In `skills/manager/SKILL.md` *Plan acceptance checklist*, replace
`until all seven hold` with `until all eight hold`, and add item 8:
`**A brief, quoted.**` — a plan made from a brief:
`grep -cE '^- brief: briefs/[a-z0-9-]+/brief\.md sha256 [0-9a-f]{64}$' plan/{slug}/master.md`
prints `1`; a plan from a brief without the line, or with another brief's, is
sent back: without it nothing reports it and nothing gates it.

- post: `` P plugins/glab/skills/manager/SKILL.md 'until all eight hold' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'until all seven hold' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '**A brief, quoted.**' ``

### J9 — `glab:bootstrap` loads the manager of the level

In `skills/bootstrap/SKILL.md`:

1. In the `description:`, replace `loads the glab:manager and glab:security skills` with `loads the manager of the session's level, glab:session-rules and glab:security`; no level prefix, since it serves every level.
2. In step 1, after `reads it first from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh``, add that it takes the text for the level its `AGENTS.md` line `glab-level:` names — the project level when there is none.
3. Replace the heading `## 2. Load `glab:manager` and `glab:security`` with `## 2. Load the manager of your level, `glab:session-rules` and `glab:security``, and its first paragraph with: all three, always — the session-start text names the manager of your level, `glab:manager` at the project level, `glab:product-manager` at the product level; that manager governs *how* work is done at its level, not *whether*: `glab:session-rules` Rule 1 says what skips the pipeline, and what still holds when it does. In its second paragraph replace `` `glab:manager` Rule 0c's `` with `` `glab:session-rules` Rule 0c's ``.
4. In step 4, replace its first paragraph with: name the stage you are at in the pipeline of the manager of your level — `glab:manager` → *The pipeline* at the project level, `glab:product-manager` → *The product pipeline* at the product level; `glab:session-rules` *Round caps* says how many rounds a stage gets, and at the project level `glab:manager` *Pick the tier* which stages run and `glab:manager` → *Running agents in parallel* how to fan out. Dispatch independent agents in a single message.

- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'loads the manager of the session'"'"'s level, glab:session-rules and glab:security' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md 'loads the glab:manager and glab:security skills' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'the text for the level its `AGENTS.md` line `glab-level:` names' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md '## 2. Load the manager of your level, `glab:session-rules` and `glab:security`' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md '## 2. Load `glab:manager` and `glab:security`' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md 'its Rule 1 says what skips the pipeline' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md '`glab:manager` Rule 0c' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'Name the stage you are at in the pipeline of the manager of your level' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md 'Name the stage you are at in `glab:manager` → *The pipeline*' ``

### J10 — the project stage skills say their level

Begin the `description:` of each of `skills/plan/SKILL.md`,
`skills/develop/SKILL.md`, `skills/analyze/SKILL.md`,
`skills/integrate/SKILL.md`, `skills/review/SKILL.md` and
`skills/ship/SKILL.md` with `Project level — `, the rest of each line
unchanged.

- post: `` for s in plan develop analyze integrate review ship; do P "plugins/glab/skills/$s/SKILL.md" 'description: Project level — '; done | sort | uniq -c | command grep -qx ' *6 ok' && echo ok || echo 'FAIL J10' ``

### J11 — the project agents say their level

Begin the `description:` of each of `agents/planner.md`,
`agents/plan-analyzer.md`, `agents/developer.md`, `agents/analyzer.md`,
`agents/integrator.md` and `agents/reviewer.md` with `Project level — `, the
rest of each line unchanged. `agents/committer.md` serves every level and
keeps its description.

- post: `` for a in planner plan-analyzer developer analyzer integrator reviewer; do P "plugins/glab/agents/$a.md" 'description: Project level — '; done | sort | uniq -c | command grep -qx ' *6 ok' && echo ok || echo 'FAIL J11' ``

### J12 — every pointer to a moved rule, and the skills of every level, name `glab:session-rules`

The rules J2 moves are cited elsewhere; each pointer moves with them, and the
skills that serve every level stop speaking for the project level alone (R6).

1. Replace `` `glab:manager` Rules 0d and 5 `` with `` `glab:session-rules` Rules 0d and 5 `` in `skills/analyze/SKILL.md`, `skills/integrate/SKILL.md`, `skills/review/SKILL.md` and `skills/ship/SKILL.md` (once each); `` `glab:manager` Rule 5 `` with `` `glab:session-rules` Rule 5 `` in `skills/ship/SKILL.md`; `` `glab:manager` Rule 3 `` with `` `glab:session-rules` Rule 3 `` in `skills/plan/SKILL.md` (twice), `skills/develop/SKILL.md` and `skills/audit/SKILL.md`; `` `glab:manager` Rule 1 `` and `glab:manager Rule 1` with the same under `glab:session-rules` in `skills/plan/SKILL.md` (its Step 0 and its `description:`).
2. In `skills/commit/SKILL.md`, replace its first paragraph's opening, `The entry point of `glab:manager` Stage 6, and of the record's commit (Stage 8). The session that runs it — `glab:manager`, or a person who typed `/glab:commit` — dispatches the **glab:committer** agent, as `glab:manager` Rules 0d and 5 say.`, with `The entry point of the commit stage of the manager of your level — `glab:manager` Stage 6 and the record's commit (Stage 8) at the project level, `glab:product-manager` stage P6 at the product level. The session that runs it — that manager, or a person who typed `/glab:commit` — dispatches the **glab:committer** agent, as `glab:session-rules` Rules 0d and 5 say.`; and replace its `A commit on `main`: `glab:manager` Stage 6.` with the rule itself, moved from `glab:manager` Stage 6, which both managers act on: `A commit on `main` — allowed by the user's words or the repo's `AGENTS.md` — is said in the dispatch to be deliberate; without that, `glab:committer` Step 3 applies.` In `skills/manager/SKILL.md` *Stage 6 — Commit*, that sentence becomes `A commit on `main`: `glab:commit`.`
3. In `skills/push/SKILL.md`, replace `The entry point of `glab:manager` Stage 7, and of the record's push (Stage 8).` with `The entry point of the push stage of the manager of your level — `glab:manager` Stage 7 and the record's push (Stage 8) at the project level, `glab:product-manager` stage P6 at the product level.`, and `The session that runs it — `glab:manager`, or a person who typed `/glab:push` —` with `The session that runs it — that manager, or a person who typed `/glab:push` —`.
4. In `scripts/context-size.sh`, in its comments only: `glab:manager Rule 2` and `` `glab:manager` Rule 2 `` become `glab:session-rules Rule 2` and `` `glab:session-rules` Rule 2 ``, and every other `glab:manager` becomes `the session's manager` — the hook now speaks to the manager of either level. Its code and `tests/context-size.test.sh` do not change.
5. In `skills/manager/SKILL.md`, every `a third under *Pick the tier*'s round-3 rule` (Stages 1b, 3 and 5, three in all) and `a third under *Pick the tier*'s rule` (Stage 6b) becomes `` a third under `glab:session-rules` *Round caps* ``, where the round caps now are (R2-2).
6. In `skills/ship/SKILL.md`, `within *Pick the tier*'s round caps` becomes `` within `glab:session-rules` *Round caps* `` (R2-2).

- post: `` for s in analyze integrate review ship; do N "plugins/glab/skills/$s/SKILL.md" '`glab:manager` Rules 0d and 5'; done | sort | uniq -c | command grep -qx ' *4 ok' && echo ok || echo 'FAIL J12.1 Rules 0d and 5' ``
- post: `` for s in plan develop audit ship; do N "plugins/glab/skills/$s/SKILL.md" '`glab:manager` Rule '; done | sort | uniq -c | command grep -qx ' *4 ok' && echo ok || echo 'FAIL J12.1 a moved Rule still under glab:manager' ``
- post: `` N plugins/glab/skills/plan/SKILL.md 'glab:manager Rule 1' ``
- post: `` P plugins/glab/skills/ship/SKILL.md '`glab:session-rules` Rule 5' ``
- post: `` P plugins/glab/skills/commit/SKILL.md 'The entry point of the commit stage of the manager of your level' ``
- post: `` P plugins/glab/skills/commit/SKILL.md 'is said in the dispatch to be deliberate; without that, `glab:committer` Step 3 applies' ``
- post: `` N plugins/glab/skills/commit/SKILL.md '`glab:manager` Rules 0d and 5' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'A commit on `main`: `glab:commit`.' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'is said in the dispatch to be deliberate' ``
- post: `` P plugins/glab/skills/push/SKILL.md 'The entry point of the push stage of the manager of your level' ``
- post: `` N plugins/glab/skills/push/SKILL.md 'The session that runs it — `glab:manager`,' ``
- post: `` N plugins/glab/scripts/context-size.sh 'glab:manager' ``
- post: `` P plugins/glab/scripts/context-size.sh 'glab:session-rules Rule 2' ``
- post: `` N plugins/glab/skills/manager/SKILL.md '*Pick the tier*'"'"'s round-3 rule' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'a third under *Pick the tier*'"'"'s rule' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'a third under `glab:session-rules` *Round caps*' ``
- post: `` N plugins/glab/skills/ship/SKILL.md 'within *Pick the tier*'"'"'s round caps' ``
- post: `` P plugins/glab/skills/ship/SKILL.md 'within `glab:session-rules` *Round caps*' ``
