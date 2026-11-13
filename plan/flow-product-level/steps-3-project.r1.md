# Steps 3 — the project level's edges and the level wiring (J1–J11)

Paths are under `plugins/glab/`. A step that replaces text names the old text
(`N` post) and the new (`P` post). `[N3]` marks a phrase that names a
project skill by today's name. The contracts C1–C10 are in `plan.md`; payload
text states what they say and never cites `C<n>`.

### J1 — `glab:manager` says its level

In `skills/manager/SKILL.md`'s frontmatter, begin the `description:` with
`Project level — `, and replace its `Autoloaded at session start;` with
`Loaded at session start at the project level;`.

- post: `` P plugins/glab/skills/manager/SKILL.md 'description: Project level — The operating model' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'Loaded at session start at the project level;' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'Autoloaded at session start;' ``

### J2 — `glab:manager` names its skills, and the rules every level shares

In `skills/manager/SKILL.md`, after Rule 0d, add the section
`## Your skills — this level only`: the stage skills `glab:plan`,
`glab:develop`, `glab:analyze`, `glab:integrate`, `glab:review`, `glab:ship`
and `glab:product-project-plan-report`; the every-level skills
`glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`,
`glab:commit`, `glab:push`; the seven agents; and the required texts
`Never invoke a skill whose description begins Product level` and
`Rules 0b, 0c, 0d, 2, 3 and 5 hold at every level: `glab:product-manager` follows them from here`. `[N3]`

- post: `` P plugins/glab/skills/manager/SKILL.md '## Your skills — this level only' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'Never invoke a skill whose description begins Product level' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'hold at every level: `glab:product-manager` follows them from here' ``

### J3 — Stage 1 takes a brief

In `skills/manager/SKILL.md` *Stage 1 — Plan*, after its first paragraph,
add a paragraph beginning `**A brief is a request.**`: a session told to take
the brief at `<store>/briefs/<project>/brief.md` — by the user or by the
product manager — resolves the store from its `glab-shared-store:` line
(the repo's `AGENTS.md`, else the host file), and the planner's dispatch
names the brief's store path and the store; how the plan quotes the brief is
`glab:plan`'s. A plan from a brief goes to Stage 1c after its approval.

- post: `` P plugins/glab/skills/manager/SKILL.md '**A brief is a request.**' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'take the brief at `<store>/briefs/<project>/brief.md`' ``

### J4 — Stage 1c, the report to product and the wait

In `skills/manager/SKILL.md`:

1. In *The pipeline*'s table, after row `1b`, add the row `| 1c | Report to product | `/glab:product-project-plan-report {slug}`, for a plan from a brief | the store's `report.r<n>.md` and `plan.r<n>/` | the verdict |`.
2. In *Stage 1b*, change `then Stage 2 — or, after the master check, the sub-plans` to `then Stage 2 — Stage 1c first for a plan from a brief — or, after the master check, the sub-plans`.
3. After *Stage 1b*, add the section `## Stage 1c — Report to product, then wait`. It says: after every approval the tier needs, run `/glab:product-project-plan-report {slug}`; announce `{slug} · report · r<n> · WAITING · context <n>k` — no agent runs, so the line names no model or effort — bring the handoff file up to date with the report's path, and end the turn. On resuming, read the latest `verdict.r<n>.md` of the brief: `ACCEPTED` → Stage 2, whose `glab:develop` checks it; and a bullet that begins with the plain words On REJECTED (required text `On REJECTED`, no backticks inside it): keep the round copies as Stage 1b does, numbered one past the highest round copy there, dispatch a new `glab:planner` for the amendment with the verdict's reason quoted as its findings, run one Stage 1b delta round — one per verdict, which neither resets nor uses Stage 1b's round cap; still `NOT BUILDABLE` after it → the user — then the approvals the tier needs again — at full tier the user approves `plan.md` again and its `## Approval` line is replaced — and Stage 1c again, which sends report `r<n+1>`. A refusal from `glab:develop` that the plan changed since it was accepted — a `PLAN WRONG` amendment, say — is Stage 1c again; one that the brief changed is a changed request (*The master plan and sub-plans*). The rejection cap is the product level's; this session reports and waits.

- post: `` P plugins/glab/skills/manager/SKILL.md '| 1c | Report to product |' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'Stage 1c first for a plan from a brief' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '## Stage 1c — Report to product, then wait' ``
- post: `` P plugins/glab/skills/manager/SKILL.md '· report · r<n> · WAITING' ``
- post: `` P plugins/glab/skills/manager/SKILL.md 'On REJECTED' ``
- post: `` N plugins/glab/skills/manager/SKILL.md 'then Stage 2 — or, after the master check, the sub-plans' ``

### J5 — `glab:plan` reads a brief as the request

In `skills/plan/SKILL.md`:

1. In Step 1, after the bullet that begins `The spec of each area the change touches, read first`, add a bullet: when the task is a brief, the product-rule files the brief names bind like `docs/constants.md` — read each from the store; the plan conforms to them. Required text: `the product-rule files the brief names`.
2. In Step 3, after the `## Request` bullet, add: `When the task is a brief, `## Request` holds the brief verbatim`, dated, under its brief line `- brief: briefs/<project>/brief.md sha256 <hash>`, the hash being `sha256sum` of the brief as it was read; the brief is the request's words, and its `## Acceptance` reaches the goals like any other request.
3. In Step 4, in *Amending after a plan check*, say that an amendment after a `REJECTED` verdict works the same way, the verdict's reason being the round's findings. Required text: `or after a REJECTED verdict`.

- post: `` P plugins/glab/skills/plan/SKILL.md 'the product-rule files the brief names' ``
- post: `` P plugins/glab/skills/plan/SKILL.md 'When the task is a brief, `## Request` holds the brief verbatim' ``
- post: `` P plugins/glab/skills/plan/SKILL.md '- brief: briefs/<project>/brief.md sha256 <hash>' ``
- post: `` P plugins/glab/skills/plan/SKILL.md 'or after a REJECTED verdict' ``

### J6 — `glab:develop` refuses a plan from a brief without a matching verdict

In `skills/develop/SKILL.md` *Preconditions*, before `**Green tree**`, add
the bullet `**Product verdict**`: when the slug's `master.md` (a level up for
a sub-plan) has a brief line, run, from the repo root,
`"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" check plan/<slug> <store>` —
the slug folder, sub-plans included, and the store from its
`glab-shared-store:` line; anything but a line `ACCEPTED r<n> <digest>` and
exit 0 → stop, show the `REFUSED:` line, and go to `glab:manager` Stage 1c.
Run on every dispatch of this skill, fix rounds included.

- post: `` P plugins/glab/skills/develop/SKILL.md '**Product verdict**' ``
- post: `` P plugins/glab/skills/develop/SKILL.md 'plan-gate.sh" check plan/<slug> <store>' ``

### J7 — `glab:bootstrap` loads the manager of the level

In `skills/bootstrap/SKILL.md`:

1. Begin the `description:` with `Every level — `, and replace `loads the glab:manager and glab:security skills` with `loads the manager its level names and the glab:security skill`.
2. In step 1, after `reads it first from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh``, add that it takes the text for the level its `AGENTS.md` line `glab-level:` names — the project level when there is none.
3. Replace the heading `## 2. Load `glab:manager` and `glab:security`` with `## 2. Load the manager of your level, and `glab:security``, and say in its body that the session-start text names it: `glab:manager` at the project level, `glab:product-manager` at the product level. `[N3]`
4. In step 4, replace `Name the stage you are at in `glab:manager` → *The pipeline*` with `Name the stage you are at in the pipeline of the manager of your level`.

- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'description: Every level — ' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'loads the manager its level names and the glab:security skill' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md 'loads the glab:manager and glab:security skills' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'the text for the level its `AGENTS.md` line `glab-level:` names' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md '## 2. Load the manager of your level, and `glab:security`' ``
- post: `` N plugins/glab/skills/bootstrap/SKILL.md '## 2. Load `glab:manager` and `glab:security`' ``
- post: `` P plugins/glab/skills/bootstrap/SKILL.md 'Name the stage you are at in the pipeline of the manager of your level' ``

### J8 — the project stage skills say their level

Begin the `description:` of each of `skills/plan/SKILL.md`,
`skills/develop/SKILL.md`, `skills/analyze/SKILL.md`,
`skills/integrate/SKILL.md`, `skills/review/SKILL.md` and
`skills/ship/SKILL.md` with `Project level — `, the rest of each line
unchanged.

- post: `` for s in plan develop analyze integrate review ship; do P "plugins/glab/skills/$s/SKILL.md" 'description: Project level — '; done | sort | uniq -c | command grep -qx ' *6 ok' && echo ok || echo 'FAIL J8' ``

### J9 — the every-level skills say so

Begin the `description:` of each of `skills/security/SKILL.md`,
`skills/comments/SKILL.md`, `skills/audit/SKILL.md`,
`skills/commit/SKILL.md` and `skills/push/SKILL.md` with `Every level — `,
the rest of each line unchanged (`skills/bootstrap/SKILL.md` is J7's).

- post: `` for s in security comments audit commit push; do P "plugins/glab/skills/$s/SKILL.md" 'description: Every level — '; done | sort | uniq -c | command grep -qx ' *5 ok' && echo ok || echo 'FAIL J9' ``

### J10 — the project agents say their level

Begin the `description:` of each of `agents/planner.md`,
`agents/plan-analyzer.md`, `agents/developer.md`, `agents/analyzer.md`,
`agents/integrator.md` and `agents/reviewer.md` with `Project level — `, the
rest of each line unchanged.

- post: `` for a in planner plan-analyzer developer analyzer integrator reviewer; do P "plugins/glab/agents/$a.md" 'description: Project level — '; done | sort | uniq -c | command grep -qx ' *6 ok' && echo ok || echo 'FAIL J10' ``

### J11 — the committer serves every level

Begin the `description:` of `agents/committer.md` with `Every level — `, the
rest of the line unchanged.

- post: `` P plugins/glab/agents/committer.md 'description: Every level — ' ``
