# Steps 4 — the repo: version, working agreement, README, host template (R1–R6)

These files belong to the repo, except `plugin.json`. No real path, bucket,
host or profile in any of them (`AGENTS.md` *Rules*, *No secrets*):
`<path to the shared folder>` and `<store>` are the placeholders.

### R1 — version and description

In `plugins/glab/.claude-plugin/plugin.json`, set `"version": "0.14.0"` and
the description to
`The glab workflow: a product level that plans a business plan into project briefs and judges each project's plan, and a project level that plans, develops, analyzes, integrates, reviews, commits, pushes and records through dedicated agents, with evidence and comment discipline`.
This is the one version raise of the change (`AGENTS.md` *Rules*).

- post: `` test "$(jq -r .version plugins/glab/.claude-plugin/plugin.json)" = 0.14.0 && echo ok || echo 'FAIL version' ``
- post: `` P plugins/glab/.claude-plugin/plugin.json 'a product level that plans a business plan into project briefs' ``

### R2 — `AGENTS.md` *Layout*

In the `plugins/glab/` bullet, add `scripts/plan-gate.sh` to the scripts it
names; in the bullet that names what belongs to the repo, say that `tests/`
holds the scripts' tests and `tests/fixtures/product-loop/`, the
walkthrough's sample product.

- post: `` P AGENTS.md '`scripts/context-size.sh` and `scripts/plan-gate.sh`' ``
- post: `` P AGENTS.md '`tests/fixtures/product-loop/`' ``

### R3 — `AGENTS.md` *Gates*

1. Replace the first gate block's four commands with seven: the syntax-and-mode loop and the `shellcheck` line each over the nine scripts `plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh plugins/glab/scripts/plan-gate.sh tests/memory-sync.test.sh tests/context-size.test.sh tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh`, the two existing test lines, and three more: `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh`, `bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh`, `bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh`. Its lead-in says `run all seven`, and its *Green is* says `nine `rc=0` lines`.
2. In the plugin gates' *Green is*: for `glab`, `Skills (20)` naming `analyze`, `audit`, `bootstrap`, `comments`, `commit`, `develop`, `integrate`, `manager`, `plan`, `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-analyze`, `product-project-plan-report`, `product-project-plan-verdict`, `push`, `review`, `security` and `ship`, and `Agents (9)` adding `product-analyzer` and `product-planner` to the seven; the model gate `exactly these nine lines`, adding `plugins/glab/agents/product-analyzer.md:model: opus` and `plugins/glab/agents/product-planner.md:model: opus` `[Q1]`; the skills gate `exactly these eighteen lines`, adding `plugins/glab/agents/product-analyzer.md:glab:security`, `plugins/glab/agents/product-analyzer.md:glab:audit`, `plugins/glab/agents/product-planner.md:glab:product-plan` and `plugins/glab/agents/product-planner.md:glab:security`.

- post: `` P AGENTS.md 'bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh' ``
- post: `` P AGENTS.md 'tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; do bash -n' ``
- post: `` P AGENTS.md 'nine `rc=0` lines' ``
- post: `` P AGENTS.md 'Skills (20)' ``
- post: `` N AGENTS.md 'Skills (13)' ``
- post: `` P AGENTS.md 'Agents (9)' ``
- post: `` P AGENTS.md 'plugins/glab/agents/product-planner.md:model: opus' ``
- post: `` P AGENTS.md 'exactly these eighteen lines' ``
- post: `` P AGENTS.md 'plugins/glab/agents/product-planner.md:glab:product-plan' ``

### R4 — `AGENTS.md` *Rules*

1. In *The hook contracts do not change without a plan*, add `manager-bootstrap.sh`'s contract — required text `` `manager-bootstrap.sh`: exit 0 on every path `` — then: on stdout one JSON object whose only key is `hookSpecificOutput`, or the plain text when `jq` fails; messages on stderr; the level read from the `glab-level:` line of the repo's `AGENTS.md`, the project level when there is none. Add a sentence for the script that is not a hook — required text `` `plan-gate.sh`: the mode names `` — then: `digest`, `report`, `verdict`, `check`; exit 0, 1 or 2; every refusal one `REFUSED:` line on stderr, and no write.
2. In *One fact, one value*, change `the seven `plugins/glab/agents/*.md`` to `the nine` in both entries that say it, and `` `glab:security` in all seven and `glab:plan` in the planner `` to `` `glab:security` in all nine, `glab:plan` in the planner and `glab:product-plan` in the product planner ``; add the analyzers' product verdict lines `SOUND`, `NOT SOUND: <n> findings`, `NO CONFLICT`, `CONFLICTS: <n>` to the verdict-lines entry, with `plugins/glab/agents/product-analyzer.md`, `plugins/glab/skills/product-plan-analyze/SKILL.md`, `plugins/glab/skills/product-project-plan-analyze/SKILL.md` and `plugins/glab/skills/product-project-plan-verdict/SKILL.md`; and add these entries, each with its files:
   - required text `the level line `glab-level:`` — its built values `product` and `project`, the project level as the default, `delivery` and `support` reserved, and the warning for a level not built (`plugins/glab/scripts/manager-bootstrap.sh`, `tests/manager-bootstrap.test.sh`, `tests/product-loop.test.sh`, `plugins/glab/skills/bootstrap/SKILL.md`, `README.md`);
   - required text `the shared store line `glab-shared-store:`` — the repo's `AGENTS.md` first, then the host file (`plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/skills/manager/SKILL.md` Stage 1, `plugins/glab/skills/develop/SKILL.md`, `plugins/glab/skills/product-project-plan-report/SKILL.md`, `README.md`, `host.example.md`);
   - the store layout — `docs/product-rules/`, `briefs/<project>/brief.md`, `report.r<n>.md`, `plan.r<n>/`, `verdict.r<n>.md`, `releases/` reserved (`plugins/glab/scripts/plan-gate.sh`, `plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/skills/product-plan/SKILL.md`, `README.md`);
   - the plan digest — its file set and its order — and the report and verdict lines and refusals (`plugins/glab/scripts/plan-gate.sh`, `tests/plan-gate.test.sh`, `tests/product-loop.test.sh`);
   - the brief line `- brief: briefs/<project>/brief.md sha256 <hash>` (`plugins/glab/skills/plan/SKILL.md`, `plugins/glab/scripts/plan-gate.sh`, `tests/fixtures/product-loop/project-plan/master.md`);
   - required text `the rejection cap` — two `REJECTED` verdicts on one brief, then the user (`plugins/glab/scripts/plan-gate.sh`, `plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/skills/product-project-plan-verdict/SKILL.md`, `tests/plan-gate.test.sh`, `tests/product-loop.test.sh`, `README.md`);
   - the 8192-byte rule file budget (`plugins/glab/skills/product-plan/SKILL.md`, `tests/product-loop.test.sh`);
   - the level at the start of every skill and agent `description:` — `Product level — `, `Project level — `, `Every level — ` (every `plugins/glab/skills/*/SKILL.md` and `plugins/glab/agents/*.md`).
3. In *`plan/` is the working area*, add to the specs it lists `` `product.md` (the product level and the product ⇄ project loop) ``.

- post: `` P AGENTS.md '`manager-bootstrap.sh`: exit 0 on every path' ``
- post: `` P AGENTS.md '`plan-gate.sh`: the mode names' ``
- post: `` N AGENTS.md 'the seven `plugins/glab/agents/*.md`' ``
- post: `` N AGENTS.md 'in all seven and' ``
- post: `` P AGENTS.md 'the level line `glab-level:`' ``
- post: `` P AGENTS.md 'the shared store line `glab-shared-store:`' ``
- post: `` P AGENTS.md 'the rejection cap' ``
- post: `` P AGENTS.md '`product.md` (the product level and the product ⇄ project loop)' ``
- post: `` P AGENTS.md 'CONFLICTS: <n>' ``

### R5 — `README.md`

1. In the plugins table's `glab` row, add the product skills and agents by their prefixed names, `glab:product-project-plan-verdict` among them.
2. Change `` `glab:security` in all seven, `glab:plan` in the planner `` to `` `glab:security` in all nine, `glab:plan` in the planner and `glab:product-plan` in the product planner ``, and `the planner and the plan check on Opus` to `the planner, the plan check, the product planner and the product analyzer on Opus` `[Q1]`.
3. Add a section `## Levels`: what a level is, the `glab-level:` line and its default, the `glab-shared-store:` line and where it may sit, what the session start loads at each level, the store layout, the loop (brief → report → verdict → development) and its gate in two sentences, the rejection cap, and that the boundary is text for the main session and hard for the product agents (no `Skill` tool).
4. Add a section `## Try the product loop`: first `PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh`, which needs no install and calls no model; then, after the user installs 0.14.0, a live run: a store folder, a product repo whose `AGENTS.md` has `glab-level: product` and `glab-shared-store: <path to the shared folder>`, a project repo whose `AGENTS.md` has the store line; a business plan given to the product session; the approval; the briefs; a project session told `take the brief at <store>/briefs/<project>/brief.md`; the report, the verdict, development starting; and the live checks LP1–LP5 with what each should show, each marked UNVERIFIED until run.
5. In *Working on this repo*'s table, the `tests/` row says it holds the scripts' tests and the product-loop walkthrough with its fixtures.

- post: `` P README.md 'glab:product-project-plan-verdict' ``
- post: `` N README.md 'in all seven,' ``
- post: `` P README.md 'the product planner and the product analyzer on Opus' ``
- post: `` P README.md '## Levels' ``
- post: `` P README.md '## Try the product loop' ``
- post: `` P README.md 'PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh' ``
- post: `` P README.md 'LP5' ``
- post: `` P README.md 'product-loop walkthrough' ``

### R6 — `host.example.md`

Add a section `## glab shared store` with the line
`glab-shared-store: <path to the shared folder>` and two sentences: the
store's path is a fact of one machine, so it sits here; a repo whose
`AGENTS.md` has its own `glab-shared-store:` line uses that one instead.

- post: `` P host.example.md '## glab shared store' ``
- post: `` P host.example.md 'glab-shared-store: <path to the shared folder>' ``
