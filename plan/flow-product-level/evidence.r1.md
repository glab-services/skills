# Evidence — flow-product-level

Planned 2026-11-13 on `main` at `f3cfe85` (`glab` 0.13.0), Claude Code CLI
`2.1.310`, every `claude` command under a new empty `CLAUDE_CONFIG_DIR` in
`$TMPDIR=/data/tmp/claude`. Proven means a command was run here and its output
is quoted; inferred means read from a document or from the code, not run;
UNVERIFIED means neither, with the reason (`glab:security` Rule 6).

## Scope

The change touches, by path:

- `plugins/glab/scripts/manager-bootstrap.sh` (the `SessionStart` hook text; contract change, E6);
- new `plugins/glab/scripts/plan-gate.sh` (the hash gate and the store file writers, E8);
- new skills `plugins/glab/skills/{product-manager,product-plan,product-plan-analyze,product-project-brief,product-project-plan-report,product-project-plan-analyze,product-project-plan-verdict}/SKILL.md`;
- new agents `plugins/glab/agents/{product-planner,product-analyzer}.md`;
- `plugins/glab/skills/{manager,plan,develop,bootstrap}/SKILL.md` (the project edges and the level wiring);
- the `description:` line of every other skill and agent under `plugins/glab/` (the level each names, N2);
- `plugins/glab/.claude-plugin/plugin.json` (0.14.0);
- new `tests/{plan-gate,manager-bootstrap,product-loop}.test.sh` and `tests/fixtures/product-loop/`;
- `AGENTS.md` (*Layout*, *Gates*, *Rules*), `README.md`, `host.example.md`.

Depended on, not read in full: `plugins/glab/hooks/hooks.json` (calls the hook
with no argument, `timeout 5`, unchanged), `.claude-plugin/marketplace.json`
(names unchanged), `plugins/glab/agents/*.md` bodies (only `description:`
changes), `docs/specs/workflow.md` and `docs/specs/marketplace.md` (read by
section: *How it works now* head, the `skills:` preload and invocation
decisions, *Known limits* U3/U4/I1; their decisions bind, below).
Untouched: `plugins/memory-sync/`, `plugins/glab/scripts/context-size.sh`,
`tests/memory-sync.test.sh`, `tests/context-size.test.sh`, `docs/specs/`
(the record's, Stage 8).

Binding decisions read from the specs: no stage or preloaded skill sets
`disable-model-invocation` or `user-invocable` (`[flow-commands-to-skills/plan.md invocation]`,
`docs/specs/workflow.md:1497`); a frontmatter `name:` is bare and equals the
skill's directory (`AGENTS.md` *Gates*, the skills gate); a sibling file in a
skill folder changes neither validation nor the counts
(`[flow-planner/evidence.md F2]`); that a live dispatch preloads a `skills:`
entry is UNVERIFIED (`[flow-commands-to-skills/plan.md U4]`).

## N1 — names

- **E1 (docs, inferred).** https://code.claude.com/docs/en/plugins/components.md, *Skills*: a plugin skill's command name is "`/<plugin>:<directory>`", and a frontmatter `name` "replaces the last segment and the plugin prefix stays". https://code.claude.com/docs/en/skills says the same for plugin skills. Neither page describes a nested folder adding a segment to a plugin skill; the `apps/web:deploy` form there is for a project `.claude/skills/` directory below the start directory whose name clashes, not for plugins. https://code.claude.com/docs/en/plugins-reference, *Standard layout*: Skills "One `<name>/SKILL.md` per skill"; the `skills` manifest key lists "Directories to scan for skills, each a directory of `<name>/SKILL.md` folders".
- **E2 (proven).** A throwaway copy of `plugins/` with `skills/product/plan/SKILL.md` (`name: probe-nested`) and `skills/product-brief/SKILL.md` (`name: product-brief`): `✔ Validation passed`; `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, product-brief, push, review, security, ship` — the two-level folder is not loaded at all. With `"skills": ["./skills/product/"]` added to `plugin.json`: `Skills (15)  … manager, plan, plan, product-brief, …` — loaded, listed under its directory name and with no `product` segment. A colon namespace for skills does not exist; **hyphenated level prefixes it is**: `glab:product-plan`.
- **E3 (docs inferred, CLI proven).** components.md, *Organize agents in subfolders*: `agents/review/security.md` "loads as `my-plugin:review:security`". On `2.1.310` the same copy with `agents/product/probe-planner.md` printed `Agents (7)` — `plugin details` did not list it — and the model and skills gates in `AGENTS.md` glob `plugins/*/agents/*.md`, so they would not see it either. Agents stay flat, with the same hyphenated prefix.
- **E4 (docs).** components.md, *Commands*: "`commands/db/migrate.md` is `/my-plugin:db:migrate`". Commands were removed in 0.13.0 (skills only); not used.
- **E5 (docs).** plugins-reference, `name`: a plugin name has no `:`. `AGENTS.md` *Gates*, last command: a `name:` containing `:` is a gate failure.

## N2 — the level boundary

- **E6 (proven by reading the code).** `plugins/glab/scripts/manager-bootstrap.sh` builds one fixed text `CTX` in a heredoc (lines 11–25), prints `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":…}}` through `jq -n`, falls back to `printf '%s\n' "$CTX"` when `jq` fails (lines 27–29), and exits 0 (line 31). It writes nothing to stderr today (`jq … 2>/dev/null`). Its header says Claude Code caps `additionalContext` at 10,000 characters. Its callers: `plugins/glab/hooks/hooks.json:6` (`SessionStart`, no argument, `timeout 5`) and `glab:bootstrap` step 1, which reads the script's text when hooks are off. Hook processes receive `CLAUDE_PROJECT_DIR` (plugins-reference, *Where each variable resolves*: hook commands export "`CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`, `CLAUDE_PROJECT_DIR`").
- **E7 (proven).** A level line parsed with `sed -n 's/^glab-level:[[:space:]]*\([a-z][a-z-]*\)[[:space:]]*$/\1/p' | head -n 1` gave `[product] -> [product]`, `[project] -> [project]`, `[delivery] -> [delivery]`, and an empty value `-> [project]` with the default applied.
- **E8 (proven).** Prototype digest in a temp tree: `find . -type f \( -name master.md -o -name index.md -o -name plan.md -o -name 'steps-*.md' -o -name questions.md \) | LC_ALL=C sort`, `sha256sum` per file, `sha256sum` of those lines. It listed `./01-a/plan.md ./master.md ./plan.md ./questions.md ./steps-1.md` and skipped `plan.r1.md`, `master.v1.md`, `evidence.md`; a copy of the listed files gave the same digest (`6b7d39…c5fc97` both); editing `evidence.md` left it unchanged; editing `plan.md` changed it (`3756e3…3e3202`).
- **E9 (proven, CLI help).** `claude --help` on `2.1.310`: "`--bg, --background` Start the session in the background and return immediately". UNVERIFIED: that a session's Bash tool can start one, in which directory it runs, and what it costs — live test LP4.
- **E10 (docs).** plugins-reference, *Environment variables*: the variables "aren't present in the environment of commands Claude runs through the Bash tool"; in skill and agent content Claude Code "substitutes the path inline". `glab:bootstrap` step 1 already relies on `${CLAUDE_PLUGIN_ROOT}` in skill text. UNVERIFIED live for the new skills — LP3.
- **E11 (docs).** components.md, *Frontmatter fields in plugin agents*: supported include `model`, `tools`, `skills`; a plugin agent cannot add hooks. An agent without the `Skill` tool cannot load another skill itself, so its `skills:` list is all it has — the one hard part of the boundary. The main session's boundary is text only: every skill of every level is listed in every session (E2's listing). UNVERIFIED that a live session keeps to it — LP2.
- **E12 (proven).** `jq`, `shellcheck`, `sha256sum` and `shasum` are on this host (`/usr/bin/*`); GNU bash 5.3.9. macOS has `shasum` and no `sha256sum` (inferred), hence the fallback in `plan-gate.sh`.

## Call sites

- **`manager-bootstrap.sh` output** (changed): read by Claude Code at `SessionStart` (E6) and by `glab:bootstrap` step 1 as plain text. Both rely on: one JSON object or the plain text on stdout, exit 0, under 10,000 characters. The new text keeps all three and adds a level; `glab:bootstrap` step 1's fallback — read the script's text — now finds two texts and must pick by the level line (step J7).
- **`glab:bootstrap` step 2** (changed): its one caller is the hook text, point 2 (`plugins/glab/scripts/manager-bootstrap.sh:16`), changed in the same step group.
- **`glab:develop` preconditions** (changed: one bullet added): callers `glab:manager` Stage 2 and a user typing `/glab:develop`. Both rely on "no dispatch until every precondition holds"; the new bullet applies only when `master.md` carries a `- brief:` line, so every existing plan starts as before.
- **`glab:plan` Step 1 and Step 3 `## Request`** (changed: brief input): callers `glab:planner` (preloads it) and `/glab:plan` typed by a user; readers of `## Request` are `glab:plan-analyzer` (`agents/plan-analyzer.md:37`) and `glab:analyzer` (`agents/analyzer.md:65`), which treat it as the user's words. A brief quoted there with its path and hash is read the same way; their files do not change.
- **`plan-gate.sh`** (new): called only from the text of `glab:product-project-plan-report`, `glab:product-project-plan-verdict`, `glab:develop`, and the tests. Precondition of each call: the plan folder and the store exist; the skills resolve the store first (C2).
- **Skill `description:` lines** (changed): read by Claude Code for listing and auto-invocation only; no file parses them. The `name:` lines do not change, so the skills gate and every `glab:<name>` reference hold.

## Rejected boundaries

- **A colon namespace** (`glab:product:plan`): not produced for skills (E2); agent subfolders give one in the docs but not in `plugin details`, and the gates would miss them (E3).
- **One plugin per level**: the user decided one plugin for all (notes, 2026-11-13).
- **Notion as the gate**: agreed against; files are the gate, Notion later as a view.
- **The level from an environment variable** (`GLAB_LEVEL`): the level belongs to the repo a session runs in, not to the shell that starts it; a product manager starting a project session would have to set it right every time.
- **Enforcing the boundary with permission rules** (`Skill(...)` deny rules in each repo's settings): writes persistent configuration into users' repos; follow-up FU-P2.
- **Moving the every-level manager rules (0b–0d, 2, 3, 5) into a shared skill now**: a rewrite of the 55 KB `glab:manager` and of every pointer to it; follow-up FU-P1, before the delivery level.
- **The hash in skill text as a pipeline** instead of a script: both sides must compute it byte-identically, and a script has a test; the text would be copied into three skills.

## The posts, proven on throwaway builds

- **E13 (proven).** The 114 post lines of `steps-*.md`, extracted with the step they belong to, run with the helper of `plan.md` *The post helper* in throwaway copies of `git archive HEAD` (`f3cfe85`) under `$TMPDIR`: on the unchanged tree `114 FAIL`; on a tree with every step simulated — each `P` phrase appended to its file, each `N` phrase removed, each new file created with its mode, the version set — `111 ok`, the other 3 being the test-run posts of A1, A3 and A6, which only the real scripts can turn green; and for each of the 32 steps A1–R6, a tree with every step but that one simulated showed all of that step's posts red and no other step's post red (`skip-one defects: 0`). The simulation proves the posts tell a finished tree from one with the step skipped; that the prose around each phrase is right is the plan check's and the review's.

## Not verified (live, after install)

LP1 the hook picks the product text in a repo whose `AGENTS.md` says `glab-level: product`; LP2 a product session keeps to its skills; LP3 `${CLAUDE_PLUGIN_ROOT}` is substituted in the new skills' text; LP4 `claude --bg` started from a product session's Bash tool; LP5 the product agents preload their `skills:`. Each is in `README.md`'s try-it guide (step R5) and carried to the record.
