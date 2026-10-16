tier: normal — new plugin payload (one skill, one script, one test) and text edits; no stored or wire format, no auth, no money moved by the code itself

# Plan — feature-external-workers

Give `glab:manager` a per-role switch between **internal** workers (Claude Code
subagents, today's behaviour) and **external** workers (OpenCode CLI on an
OpenCode Go key), so implementation can run outside the Claude plan limits
while the manager keeps planning, gating and deciding. Written 2026-10-16
against `main` at `9700bcb`. Off by default: a repo that says nothing keeps
running fully internal.

## Findings

**Scope surface** (every path this plan touches or depends on):

- `plugins/glab/skills/manager/SKILL.md` — Rule 0c (what each dispatch carries),
  Rule 2 (context budget, report shape), *Running agents in parallel*, Stage 2
  dispatch, *What you never do*.
- `plugins/glab/skills/bootstrap/SKILL.md` — step 1 (reads `docs/constants.md`
  and `~/.claude/host.md`), step 3 (the one recorded gates line), *The one-line
  check* ("four" items — a counted fact, must not change).
- `plugins/glab/scripts/manager-bootstrap.sh` — session-start rules; one fact,
  one value with `glab:bootstrap` (`AGENTS.md` *Rules*). 10,000-char cap on
  `additionalContext`.
- `plugins/glab/commands/develop.md`, `analyze.md`, `review.md` — the three
  commands that dispatch a role this plan makes switchable.
- `plugins/glab/agents/developer.md`, `analyzer.md`, `reviewer.md` — read by the
  new script as the role contract; **not edited**.
- `plugins/glab/skills/security/SKILL.md`, `comments/SKILL.md`, `audit/SKILL.md`
  — read by the new script as the carried disciplines; **not edited**.
- `plugins/glab/.claude-plugin/plugin.json` — version `0.2.1`.
- `AGENTS.md` — *Gates* (script list for `bash -n`/`test -x`/`shellcheck`,
  `Skills (14)`), *Rules* (one-fact list).
- `README.md` — the `glab` row of the plugin table; *Requirements*.
- `tests/` — new test file beside `memory-sync.test.sh`.

**Proven** (command run in this session):

- `opencode` 1.19.3 (`npm i opencode-ai`), `opencode run --help`: `-m/--model
  provider/model`, `--dir`, `--format default|json`, `-f/--file` (attach),
  `--agent`, `--pure`, `--auto` ("auto-approve permissions that are not
  explicitly denied").
- OpenCode permissions (https://opencode.ai/docs/permissions/): `permission`
  with `edit` / `bash` pattern maps, `allow|ask|deny`, last matching rule wins;
  explicit `deny` still holds under `--auto`.
- OpenCode config precedence (https://opencode.ai/docs/config/): global <
  `OPENCODE_CONFIG` < project `opencode.json` < `.opencode` < inline
  `OPENCODE_CONFIG_CONTENT` < managed. A project `opencode.json` therefore
  overrides `OPENCODE_CONFIG`; only `OPENCODE_CONFIG_CONTENT` sits above it.
- OpenCode Go (https://opencode.ai/docs/go/): limits $12 / 5 h, $30 / week,
  $60 / month; optional fallback to a paid Zen balance ("Use balance");
  providers zero-retention, no training. Model ids `opencode-go/<id>`.
- The manager already runs every gate itself and never reports green on an
  agent's word (`manager/SKILL.md` Rule 0b, Stage 2 *Verify before moving on*).
  An external worker's claims are therefore checked by the same gates as an
  internal one's — no new trust is extended.

**Inferred** (proven by a step before anything depends on it):

- I1. `OPENCODE_CONFIG_CONTENT` takes the same JSON as `opencode.json` — docs
  list it, do not specify it. Proven by step 2's stub-free probe (P3).
- I2. OpenCode loads the repo's `AGENTS.md` as rules on its own. Not relied
  on: the worker prompt tells it to read `AGENTS.md` first, as every glab
  dispatch must anyway.
- I3. Behaviour of an `ask` permission under non-interactive `run` without
  `--auto` is undocumented. Avoided: the script always passes `--auto` and
  relies on explicit `deny` rules plus its own git-state check (step 2).

## Decisions

- D1. The setting lives in the product repo's `docs/constants.md`, section
  `## Workers` — it is a decided fact only the user changes, which is what that
  file is for. No section, or no file → every role internal. Rejected: an env
  var (invisible in review, differs per shell); `~/.claude/host.md` (it holds
  what a machine *has*, not what a product *decides*).
- D2. Switchable roles: `glab:developer`, `glab:analyzer`, `glab:reviewer`.
  Never external: `glab:integrator` (starts services), `glab:committer` (its
  deny-list is authoritative), push (no agent by design). Planning stays with
  the manager's planning agent — plans are where Claude's judgement is worth
  the quota.
- D3. Full tier: `glab:developer` is internal unless `## Workers` says
  `full-tier: external` in so many words. Full tier is auth, secrets, money,
  migrations, formats — the hard and risky code the external models are
  weakest at.
- D4. No silent fallback. External unavailable, over its limit or timed out →
  the manager stops and reports; switching that dispatch to internal spends
  the Claude plan, so it is the user's call each time.
- D5. The script never enables or relies on the Zen balance. Reaching an
  OpenCode Go limit is a stop (exit 4), not a top-up. Spending money is a
  Rule 3 ask-condition.
- D6. Same contract both ways: an external worker gets the role's agent file
  body, `glab:security`, `glab:comments` (and `glab:audit` when the manager
  names it), the dispatch message, and the host temp-file rule; it writes the
  same file (`result.md` for the developer) and returns the same report block.
  The manager cannot tell the backends apart from the report, only from the
  announcement line.
- D7. Guard in two layers: an inline `OPENCODE_CONFIG_CONTENT` with explicit
  `deny` rules (no `git commit|push|add|reset|stash|checkout`; read-only roles
  also `edit: deny`), and the script's own before/after git-state check, which
  holds even if the config is ignored. A violation is exit 6 and the worker's
  report is discarded.
- D8. One new skill, `glab:workers`, holds the switch; `glab:manager` points to
  it rather than growing. Rejected: a new command (`/glab:workers`) — the
  setting is a file the user edits, and a command would add a second way to
  change it.
- D9. Parallel external developers follow the existing rule unchanged:
  disjoint files and no ordering dependency, one working tree, no worktrees.
  The script refuses to start a second external developer while one is running
  in the same tree (lock file under the host temp directory).

## Processing

S1. **`plugins/glab/skills/workers/SKILL.md`** (new). Frontmatter `name:
workers`, description: when the manager dispatches a switchable role. Body:

- the `## Workers` format in `docs/constants.md`:

      ## Workers
      - develop: external opencode-go/kimi-k2.7-code
      - analyze: internal
      - review: external opencode-go/deepseek-v4-pro
      - full-tier: internal

  one line per switchable role; absent line → internal; `full-tier` defaults
  to internal (D3);
- resolution at session start and the one announcement line (S4);
- dispatch: internal → the agent as today; external →
  `"${CLAUDE_PLUGIN_ROOT}"/scripts/external-worker.sh` with role, slug, model
  and a dispatch file, run in the background like any agent;
- the exit codes of S2 and what the manager does with each (D4: stop and
  report on 3, 4, 5; 6 → discard and report a guard violation; never re-run on
  internal without the user's go-ahead);
- D2, D3, D5, D9 stated as rules.

S2. **`plugins/glab/scripts/external-worker.sh`** (new, executable). Interface:

    external-worker.sh --role developer|analyzer|reviewer --slug <slug>
                       --model <provider/model> --dispatch <file>
                       [--skills audit] [--timeout <minutes>]

Behaviour, in order:

1. `command -v opencode` or exit 3 (`BACKEND UNAVAILABLE: opencode not found`).
2. Temp directory from `~/.claude/host.md`'s rule as passed in the dispatch,
   else `$TMPDIR`; unique per run; removed on exit except the transcript,
   whose path is printed.
3. Build the prompt file: role body (agent file minus frontmatter) + carried
   skill bodies + dispatch file + "Read `AGENTS.md` first, and
   `docs/constants.md` if present."
4. Record git state: `HEAD`, `git diff --staged --name-only`, and for read-only
   roles `git status --porcelain -uall`.
5. `opencode run --auto --pure -m <model> --dir <repo root> --format json -f
   <prompt file> "<one-line instruction>"` under `timeout`, with
   `OPENCODE_CONFIG_CONTENT` carrying the D7 deny rules. Full output to the
   transcript file only; nothing to stdout.
6. Exit 5 on timeout. Exit 4 when the output reports a usage or rate limit
   (match on the provider's limit error; the exact text is proven by P3 and
   written into the script's header comment).
7. Re-check git state: `HEAD` moved or index changed → exit 6; read-only role
   and porcelain changed → exit 6.
8. Print only the role's report block — from the first report label of that
   role's contract (`steps:` for the developer, the verdict block for
   analyzer/reviewer) to its verdict line — then `transcript: <path>`.
   No report block found → exit 7 (`NO REPORT`).

Exit 0 only when 1–8 all pass. Every path prints its reason on stderr, never a
config value or secret. `shellcheck` clean.

S3. **`tests/external-worker.test.sh`** (new, executable). Stub `opencode` first
on `PATH` (`AGENTS.md` *Tests* allows it). Cases: T1 missing CLI → 3; T2
success → only the report block and `transcript:` on stdout; T3 timeout → 5;
T4 limit message → 4; T5 developer stub commits → 6; T6 reviewer stub edits a
file → 6; T7 no report block → 7; T8 second concurrent developer → refused
(D9); T9 no secret-like env value reaches stdout. Prints `ok`/`not ok` per case
and `PASS n/n`. Kills only PIDs it started.

S4. **`plugins/glab/skills/bootstrap/SKILL.md`** step 3: the one recorded line
now ends with the worker line, e.g. `gates: make build · make test · make lint
· workers: develop=external(opencode-go/kimi-k2.7-code) analyze=internal
review=internal`. Step 1: `docs/constants.md` `## Workers` named as where it
comes from. *The one-line check* stays at four items (the worker line is part
of "the gates I will run").

S5. **`plugins/glab/scripts/manager-bootstrap.sh`**: one sentence in item 3 —
"Switchable roles dispatch per `glab:workers`; with no `## Workers` in
`docs/constants.md`, every role is internal." Same text, in substance, as S4
(one fact, one value). Stays under the 10,000-char cap (P5).

S6. **`plugins/glab/skills/manager/SKILL.md`**: Rule 0c — external dispatches
carry the same skills, via the script; Stage 2 — "dispatch per `glab:workers`";
*Running agents in parallel* — D9 in one line; *What you never do* — "Re-run an
external dispatch on an internal agent without the user's go-ahead."

S7. **`plugins/glab/commands/develop.md`, `analyze.md`, `review.md`**: where each
says "use the **glab:<role>** agent", add "— or its external worker, per
`glab:workers`". Reviewer still gets the target and nothing else.

S8. **`plugins/glab/.claude-plugin/plugin.json`**: version `0.2.1` → `0.3.0`.

S9. **`AGENTS.md`**: *Gates* — add `plugins/glab/scripts/external-worker.sh`
and `tests/external-worker.test.sh` to the `bash -n`/`test -x` loop and the
`shellcheck` line; add `bash tests/external-worker.test.sh
plugins/glab/scripts/external-worker.sh`; `Skills (14)` → `Skills (15)`
naming seven skills. *Rules* one-fact list — add: the switchable roles and the
never-external roles (`workers/SKILL.md`, `manager/SKILL.md`, README); the
exit codes of `external-worker.sh` (script, test, `workers/SKILL.md`).

S10. **`README.md`**: `glab` row adds `glab:workers` and the script;
*Requirements* — "`opencode` only when a repo turns external workers on".

## After

- **Milestone:** `bash tests/external-worker.test.sh
  plugins/glab/scripts/external-worker.sh` prints `PASS 9/9`, and `claude
  --plugin-dir ./plugins plugin details glab` shows `Skills (15)`.
- **Gates:** every *Gates* block in `AGENTS.md`, as amended by S9, green.

Checks:

- P1. `command grep -c 'glab:workers' plugins/glab/skills/manager/SKILL.md
  plugins/glab/skills/bootstrap/SKILL.md plugins/glab/scripts/manager-bootstrap.sh
  plugins/glab/commands/{develop,analyze,review}.md` — each ≥ 1. Names the six
  files: a tree missing one edit fails.
- P2. `command grep -rn 'integrator\|committer' plugins/glab/skills/workers/SKILL.md`
  — both named as never-external.
- P3. Live probe, run once by the user on their machine (needs the key; the
  test suite never calls the network): `OPENCODE_CONFIG_CONTENT` with a
  `bash: {"git commit*": "deny"}` rule, ask the model to run `git commit
  --allow-empty -m x` in a throwaway repo; expect no commit. The limit-error
  text for S2 step 6 comes from a captured real error, not from exhausting the
  quota on purpose. Until run: `UNVERIFIED: deny via inline config — I1`.
- P4. `command grep -c 'four' plugins/glab/skills/bootstrap/SKILL.md` unchanged
  from `main`.
- P5. `bash plugins/glab/scripts/manager-bootstrap.sh | jq -r
  .hookSpecificOutput.additionalContext | wc -c` < 10000.
- P6. With no `docs/constants.md` in a scratch repo, a dry dispatch resolves
  every role to internal (read the announcement line).

**Back out:** revert the commit; `0.3.0` → next version on the revert so
installed copies receive it. No data, no state outside the repo.

## Not in this plan

- Choosing models per task size beyond the `## Workers` line (a follow-up once
  a week of usage exists).
- Any other external backend (Alibaba Token Plan, Codex CLI). `--model` takes
  any `provider/model` OpenCode knows, so a second provider is config, not code.
- Writing anyone's `docs/constants.md` — that is the user's (`glab:bootstrap`
  step 1).
