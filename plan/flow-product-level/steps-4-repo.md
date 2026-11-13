# Steps 4 — the repo: version, working agreement, README, host template (R1–R6)

These files belong to the repo, except `plugin.json`. No real path, bucket,
host or profile in any of them (`AGENTS.md` *Rules*, *No secrets*):
`<path to the shared folder>` and `<store>` are the placeholders. `AGENTS.md`
is wrapped prose: an old text below is matched across its line breaks, as the
post helper matches it, and the new text is wrapped the same way.

### R1 — version and description

In `plugins/glab/.claude-plugin/plugin.json`, set `"version": "0.14.0"` and
the description to
`The glab workflow: a product level that plans a business plan into project briefs and judges each project's plan, and a project level that plans, develops, analyzes, integrates, reviews, commits, pushes and records through dedicated agents, with evidence and comment discipline`.
This is the one version raise of the change (`AGENTS.md` *Rules*).

- post: `` test "$(jq -r .version plugins/glab/.claude-plugin/plugin.json)" = 0.14.0 && echo ok || echo 'FAIL version' ``
- post: `` P plugins/glab/.claude-plugin/plugin.json 'a product level that plans a business plan into project briefs' ``

### R2 — `AGENTS.md` *Layout*

In the `plugins/glab/` bullet, replace `` `scripts/manager-bootstrap.sh` and `scripts/context-size.sh` `` with
`` `scripts/manager-bootstrap.sh`, `scripts/context-size.sh` and `scripts/plan-gate.sh` ``;
in the bullet that names what belongs to the repo, say that `tests/` holds
the scripts' tests and `tests/fixtures/product-loop/`, the walkthrough's
sample product.

- post: `` P AGENTS.md '`scripts/context-size.sh` and `scripts/plan-gate.sh`' ``
- post: `` N AGENTS.md '`scripts/manager-bootstrap.sh` and `scripts/context-size.sh`' ``
- post: `` P AGENTS.md '`tests/fixtures/product-loop/`' ``

### R3 — `AGENTS.md` *Gates*

1. Replace the lead-in's `run all four` with `run all seven`, and the first gate block with these seven commands:

        for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh plugins/glab/scripts/plan-gate.sh tests/memory-sync.test.sh tests/context-size.test.sh tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
        shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh plugins/glab/scripts/plan-gate.sh tests/memory-sync.test.sh tests/context-size.test.sh tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; echo "rc=$?"
        bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
        bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh
        bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh
        bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh
        bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh

   In its *Green is*, replace ``five `rc=0` lines`` with ``nine `rc=0` lines``.
2. In the plugin gates' *Green is*: for `glab`, replace `Skills (13)` and its thirteen names with `Skills (21)` naming `analyze`, `audit`, `bootstrap`, `comments`, `commit`, `develop`, `integrate`, `manager`, `plan`, `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-analyze`, `product-project-plan-report`, `product-project-plan-verdict`, `push`, `review`, `security`, `session-rules` and `ship`, and `Agents (7)` and its seven names with `Agents (9)` naming `analyzer`, `committer`, `developer`, `integrator`, `plan-analyzer`, `planner`, `product-analyzer`, `product-planner` and `reviewer`; replace `exactly these seven lines` with `exactly these nine lines`, adding `plugins/glab/agents/product-analyzer.md:model: opus` and `plugins/glab/agents/product-planner.md:model: opus` in their sorted places (Q1); and replace `exactly these fourteen lines` with `exactly these eighteen lines`, adding `plugins/glab/agents/product-analyzer.md:glab:security`, `plugins/glab/agents/product-analyzer.md:glab:audit`, `plugins/glab/agents/product-planner.md:glab:product-plan` and `plugins/glab/agents/product-planner.md:glab:security`.

- post: `` P AGENTS.md 'run all seven' ``
- post: `` N AGENTS.md 'run all four' ``
- post: `` P AGENTS.md 'tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; do bash -n' ``
- post: `` P AGENTS.md 'tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; echo "rc=$?"' ``
- post: `` P AGENTS.md 'bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh' ``
- post: `` P AGENTS.md 'bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh' ``
- post: `` P AGENTS.md 'bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh' ``
- post: `` P AGENTS.md 'nine `rc=0` lines' ``
- post: `` N AGENTS.md 'five `rc=0` lines' ``
- post: `` P AGENTS.md 'Skills (21)' ``
- post: `` N AGENTS.md 'Skills (13)' ``
- post: `` P AGENTS.md '`security`, `session-rules` and `ship`' ``
- post: `` P AGENTS.md 'Agents (9)' ``
- post: `` N AGENTS.md 'Agents (7)' ``
- post: `` P AGENTS.md 'plugins/glab/agents/product-planner.md:model: opus' ``
- post: `` P AGENTS.md 'exactly these nine lines' ``
- post: `` N AGENTS.md 'exactly these seven lines' ``
- post: `` P AGENTS.md 'exactly these eighteen lines' ``
- post: `` N AGENTS.md 'exactly these fourteen lines' ``
- post: `` P AGENTS.md 'plugins/glab/agents/product-planner.md:glab:product-plan' ``

### R4 — `AGENTS.md` *Rules*

1. In *The hook contracts do not change without a plan*, add `manager-bootstrap.sh`'s contract — required text `` `manager-bootstrap.sh`: exit 0 on every path `` — then: on stdout one JSON object whose only key is `hookSpecificOutput`, or the plain text when `jq` fails; messages on stderr; the level read from the first `glab-level:` line of the repo's `AGENTS.md`, the project level when there is none. Add a sentence for the script that is not a hook — required text `` `plan-gate.sh`: the mode names `` — then: `digest`, `report`, `verdict`, `check`; exit 0 done, 1 refused, 2 usage or a failed write; every refusal one `REFUSED:` line on stderr, and no write.
2. In *One fact, one value*, replace in place:
   - in the round caps: `Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b) at most 2 rounds` → `Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b), and P1b at the product level, at most 2 rounds`, and `` (`plugins/glab/skills/manager/SKILL.md` *Pick the tier*, and the `` → `` (`plugins/glab/skills/session-rules/SKILL.md` *Round caps*, the table of `plugins/glab/skills/manager/SKILL.md` *Pick the tier*, and the ``;
   - `` the four ask-conditions of `glab:manager` Rule 3 `` → `` the four ask-conditions of `glab:session-rules` Rule 3 ``, and `` what the product is (`plugins/glab/skills/manager/SKILL.md`, `` → `` what the product is (`plugins/glab/skills/session-rules/SKILL.md`, ``;
   - in the model per role: `` (`glab:manager` Rule 5 and its handoff-line format in `plugins/glab/skills/manager/SKILL.md`, the seven `` → `` (`glab:session-rules` Rule 5 and *The handoff line* in `plugins/glab/skills/session-rules/SKILL.md`, the nine `` (R5);
   - in the skills each agent preloads: `` `glab:security` in all seven and `glab:plan` in the planner `` → `` `glab:security` in all nine, `glab:plan` in the planner and `glab:product-plan` in the product planner ``, and `preload (the seven` → `preload (the nine`;
   - in the severity levels: `` `plugins/glab/agents/analyzer.md` and `plugins/glab/agents/plan-analyzer.md`; `` → `` `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md` and `plugins/glab/agents/product-analyzer.md`; ``;
   - in every round a new agent: `` report check the one resume (`plugins/glab/skills/manager/SKILL.md`, `` → `` report check the one resume (`plugins/glab/skills/session-rules/SKILL.md` Rules 2 and 5, `plugins/glab/skills/manager/SKILL.md`, ``;
   - in the handoff file: `` `plugins/glab/skills/manager/SKILL.md` Rule 2) `` → `` `plugins/glab/skills/session-rules/SKILL.md` Rule 2) ``;
   - in the context hook: `` `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/manager/SKILL.md`, `README.md` `` → `` `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/session-rules/SKILL.md`, `README.md` ``;
   - in the session effort: `` (`glab:manager` Rules 0d and 5 and *The pipeline* in `plugins/glab/skills/manager/SKILL.md`, `` → `` (`glab:session-rules` Rules 0d and 5 and *The handoff line* in `plugins/glab/skills/session-rules/SKILL.md`, ``;
   - in the plan size budget: `` `index.md` and `evidence.md`, and the `- size:` line (`plugins/glab/skills/plan/SKILL.md` Step 3, `` → `` `index.md` and `evidence.md`, and the product level's `product-plan.md`, and the `- size:` line (`plugins/glab/skills/plan/SKILL.md` Step 3, `plugins/glab/skills/product-plan/SKILL.md`, `` (R7);
   - in the round copies (R2-5): `` (all but the version copies), `plugins/glab/agents/developer.md`); `` → `` (all but the version copies), `plugins/glab/agents/developer.md`, and for the round copies `plugins/glab/scripts/plan-gate.sh`, which leaves them out of the digest, `plugins/glab/skills/manager/SKILL.md` Stage 1c and `plugins/glab/skills/product-plan-analyze/SKILL.md`); ``;
   - in the analyzers' verdict lines: `` `BLOCK: target unresolved` (both) `` → `` `BLOCK: target unresolved` (all three), and `glab:product-analyzer`'s `SOUND`, `NOT SOUND: <n> findings`, `NO CONFLICT` and `CONFLICTS: <n>` ``, its files gaining `plugins/glab/agents/product-analyzer.md`, `plugins/glab/skills/product-plan-analyze/SKILL.md`, `plugins/glab/skills/product-project-plan-analyze/SKILL.md` and `plugins/glab/skills/product-project-plan-verdict/SKILL.md`;
   - and the list's last `.` becomes `;` before these entries, each with its files:
     - required text `` the level line `glab-level:` `` — the first line of a repo's `AGENTS.md` that begins `glab-level:`; `product` and `project` built, no line the project level, any other value the project level with the warning, `delivery` and `support` reserved (`plugins/glab/scripts/manager-bootstrap.sh`, `tests/manager-bootstrap.test.sh`, `tests/product-loop.test.sh`, `plugins/glab/skills/bootstrap/SKILL.md`, `README.md`);
     - required text `` the shared store line `glab-shared-store:` `` — the repo's `AGENTS.md` first, then the host file (`plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/skills/manager/SKILL.md` Stage 1, `plugins/glab/skills/develop/SKILL.md`, `plugins/glab/skills/product-project-plan-report/SKILL.md`, `README.md`, `host.example.md`);
     - required text `the store layout` — `docs/product-rules/` with `index.md`, `briefs/<project>/brief.md`, `report.r<n>.md`, `plan.r<n>/`, `verdict.r<n>.md`, `releases/` reserved (`plugins/glab/scripts/plan-gate.sh`, `plugins/glab/skills/product-manager/SKILL.md` *The shared store*, `plugins/glab/skills/product-plan/SKILL.md`, `README.md`);
     - required text `the plan digest` — its file set, what it leaves out (round and version copies, `plan.r<n>/`, `after-verdict.md`) and its order — and the report and verdict lines, their parse rules and refusals (`plugins/glab/scripts/plan-gate.sh`, `tests/plan-gate.test.sh`, `tests/product-loop.test.sh`, `plugins/glab/skills/manager/SKILL.md` Stage 1c, `plugins/glab/skills/session-rules/SKILL.md`, `plugins/glab/skills/develop/SKILL.md` and `README.md` *Levels*) (R2-5);
     - required text `the brief line` — `- brief: briefs/<project>/brief.md sha256 <hash>` (`plugins/glab/skills/plan/SKILL.md`, `plugins/glab/skills/manager/SKILL.md` checklist item 8, `plugins/glab/scripts/plan-gate.sh`, `tests/fixtures/product-loop/project-plan/master.md`);
     - required text `the rejection cap` — two `REJECTED` verdicts on one project since its last `ACCEPTED`, over every brief, then a verdict by `user` only, its reason opening with the user's words (`plugins/glab/scripts/plan-gate.sh`, `plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/skills/product-project-plan-verdict/SKILL.md`, `tests/plan-gate.test.sh`, `tests/product-loop.test.sh`, `README.md`);
     - required text `the rule file budget` — 8192 bytes (`plugins/glab/skills/product-plan/SKILL.md`, `tests/product-loop.test.sh`);
     - required text `the rules of every level` — Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, *Round caps*, *The handoff line* and *The level boundary* in `glab:session-rules`, which each level's manager loads and cites by number (`plugins/glab/skills/session-rules/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/scripts/manager-bootstrap.sh`, `plugins/glab/skills/bootstrap/SKILL.md`, `README.md`) (R7);
     - required text `the level boundary` — each manager's *Your skills — this level only* the binding list, a description's level prefix `Product level — ` or `Project level — ` a hint, no prefix on what serves every level (`plugins/glab/skills/session-rules/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/product-manager/SKILL.md`, `plugins/glab/scripts/manager-bootstrap.sh`, the `description:` of every `plugins/glab/skills/*/SKILL.md` and `plugins/glab/agents/*.md`, `README.md`).
3. In *`plan/` is the working area*, add to the specs it lists `` `product.md` (the product level and the product ⇄ project loop) ``.

- post: `` P AGENTS.md '`manager-bootstrap.sh`: exit 0 on every path' ``
- post: `` P AGENTS.md '`plan-gate.sh`: the mode names' ``
- post: `` P AGENTS.md 'and P1b at the product level, at most 2 rounds' ``
- post: `` P AGENTS.md '(`plugins/glab/skills/session-rules/SKILL.md` *Round caps*' ``
- post: `` N AGENTS.md '(`plugins/glab/skills/manager/SKILL.md` *Pick the tier*, and the' ``
- post: `` P AGENTS.md 'the four ask-conditions of `glab:session-rules` Rule 3' ``
- post: `` N AGENTS.md 'the four ask-conditions of `glab:manager` Rule 3' ``
- post: `` P AGENTS.md 'what the product is (`plugins/glab/skills/session-rules/SKILL.md`,' ``
- post: `` N AGENTS.md 'what the product is (`plugins/glab/skills/manager/SKILL.md`,' ``
- post: `` P AGENTS.md '(`glab:session-rules` Rule 5 and *The handoff line*' ``
- post: `` N AGENTS.md '(`glab:manager` Rule 5 and its handoff-line format in `plugins/glab/skills/manager/SKILL.md`,' ``
- post: `` N AGENTS.md 'the seven `plugins/glab/agents/*.md`' ``
- post: `` N AGENTS.md 'in all seven and' ``
- post: `` P AGENTS.md 'in all nine, `glab:plan` in the planner and `glab:product-plan` in the product planner' ``
- post: `` P AGENTS.md '`plugins/glab/agents/plan-analyzer.md` and `plugins/glab/agents/product-analyzer.md`;' ``
- post: `` P AGENTS.md 'report check the one resume (`plugins/glab/skills/session-rules/SKILL.md` Rules 2 and 5' ``
- post: `` P AGENTS.md '`plugins/glab/skills/session-rules/SKILL.md` Rule 2)' ``
- post: `` N AGENTS.md '`plugins/glab/skills/manager/SKILL.md` Rule 2)' ``
- post: `` N AGENTS.md '`plugins/glab/hooks/hooks.json`, `plugins/glab/skills/manager/SKILL.md`' ``
- post: `` P AGENTS.md '(`glab:session-rules` Rules 0d and 5 and *The handoff line*' ``
- post: `` N AGENTS.md '(`glab:manager` Rules 0d and 5 and *The pipeline*' ``
- post: `` P AGENTS.md 'and the product level'"'"'s `product-plan.md`' ``
- post: `` P AGENTS.md 'and for the round copies `plugins/glab/scripts/plan-gate.sh`, which leaves them out of the digest' ``
- post: `` N AGENTS.md 'the version copies), `plugins/glab/agents/developer.md`);' ``
- post: `` P AGENTS.md '`plugins/glab/skills/develop/SKILL.md` and `README.md` *Levels*' ``
- post: `` P AGENTS.md 'CONFLICTS: <n>' ``
- post: `` N AGENTS.md '`BLOCK: target unresolved` (both)' ``
- post: `` P AGENTS.md 'the level line `glab-level:`' ``
- post: `` P AGENTS.md 'the shared store line `glab-shared-store:`' ``
- post: `` P AGENTS.md 'the store layout' ``
- post: `` P AGENTS.md 'the plan digest' ``
- post: `` P AGENTS.md 'the brief line' ``
- post: `` P AGENTS.md 'the rejection cap' ``
- post: `` P AGENTS.md 'the rule file budget' ``
- post: `` P AGENTS.md 'the rules of every level' ``
- post: `` P AGENTS.md 'the level boundary' ``
- post: `` P AGENTS.md '`product.md` (the product level and the product ⇄ project loop)' ``

### R5 — `README.md`

1. In the plugins table's `glab` row, add `glab:session-rules` to its skills, and the product skills and agents by their prefixed names, `glab:product-manager` and `glab:product-project-plan-verdict` among them.
2. Replace `` `glab:security` in all seven, `glab:plan` in the planner `` with `` `glab:security` in all nine, `glab:plan` in the planner and `glab:product-plan` in the product planner ``, and `the planner and the plan check on Opus` with `the planner, the plan check, the product planner and the product analyzer on Opus` (Q1).
3. In *Requirements*, replace `` `glab:manager` then counts dispatches instead `` with `` the session's manager then counts dispatches instead (`glab:session-rules` Rule 2) ``.
4. Add a section `## Levels`: what a level is; the `glab-level:` line, its default and its warning, read from the folder the session starts in or the top of its git work tree (F4); the `glab-shared-store:` line and where it may sit; what the session start loads at each level — the manager of the level, `glab:session-rules` and `glab:security`; the store layout; the loop (brief → report → verdict → development) and its gate in two sentences, and that the manager's record lines after a report go to `after-verdict.md`, outside the hash; the rejection cap, two `REJECTED` since the last `ACCEPTED` of a project, then the user; the boundary — each manager's list binds, a description's level prefix is a hint, and only the product agents (no `Skill` tool) are held to it by Claude Code itself; and its known limits: the main session's boundary is text, and — required text — `` `by user` is an argument the calling session chooses `` (R12).
5. Add a section `## Try the product loop`: first `PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>trace.txt`, from a shell where `TMPDIR` is set, which needs no install and calls no model, and the trace it writes; then, after the user installs 0.14.0, a live run: a store folder, a product repo whose `AGENTS.md` has `glab-level: product` and `glab-shared-store: <path to the shared folder>`, its session started with the store among its directories (`claude --add-dir <store>`; R2-4), a project repo whose `AGENTS.md` has the store line; a business plan given to the product session; the approval; the briefs; a project session started one of three ways — the desktop app's session tool, `claude --bg --name <project> --add-dir <store> …` from the project repo, or by hand — and given the start prompt `take the brief at <store>/briefs/<project>/brief.md. Commit only through /glab:commit, and push only after the user's explicit go-ahead.`, with its caveat (F19): a background session that moved into a worktree commits and pushes its branch without asking unless its task says otherwise, which is why the prompt's second sentence is there, and that it is enough is UNVERIFIED until LP4 has run; the report, the verdict, development starting; and the live checks LP1–LP6 with what each should show, each marked UNVERIFIED until run.
6. In *Working on this repo*'s table, the `tests/` row says it holds the scripts' tests and the product-loop walkthrough with its fixtures.

- post: `` P README.md 'glab:product-project-plan-verdict' ``
- post: `` P README.md 'glab:session-rules' ``
- post: `` N README.md 'in all seven,' ``
- post: `` P README.md 'in all nine, `glab:plan` in the planner and `glab:product-plan` in the product planner' ``
- post: `` N README.md 'the planner and the plan check on Opus' ``
- post: `` P README.md 'the product planner and the product analyzer on Opus' ``
- post: `` N README.md '`glab:manager` then counts dispatches instead' ``
- post: `` P README.md '## Levels' ``
- post: `` P README.md 'glab-level: product' ``
- post: `` P README.md 'since the last `ACCEPTED`' ``
- post: `` P README.md 'after-verdict.md' ``
- post: `` P README.md '## Try the product loop' ``
- post: `` P README.md 'PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh' ``
- post: `` P README.md 'claude --bg --name <project> --add-dir <store>' ``
- post: `` P README.md 'push only after the user'"'"'s explicit go-ahead' ``
- post: `` P README.md '`by user` is an argument the calling session chooses' ``
- post: `` P README.md 'LP6' ``
- post: `` P README.md 'product-loop walkthrough' ``

### R6 — `host.example.md`

Add a section `## glab shared store` with the line
`glab-shared-store: <path to the shared folder>` and two sentences: the
store's path is a fact of one machine, so it sits here; a repo whose
`AGENTS.md` has its own `glab-shared-store:` line uses that one instead.

- post: `` P host.example.md '## glab shared store' ``
- post: `` P host.example.md 'glab-shared-store: <path to the shared folder>' ``
