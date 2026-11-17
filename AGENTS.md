# Working agreement

This repo is a Claude Code plugin marketplace, `glab-services`, holding two
plugins. Everything under `plugins/` is **payload**: it is written for the
sessions of whoever installs a plugin, not for this repo. When payload text
and this file disagree about how to work *in this repo*, this file wins.

## Layout

- `.claude-plugin/marketplace.json` — the marketplace. It lists both plugins.
- `plugins/glab/` — the workflow plugin: its skills and agents,
  `hooks/hooks.json`, `scripts/manager-bootstrap.sh`,
  `scripts/context-size.sh` and `scripts/plan-gate.sh`.
- `plugins/memory-sync/` — the memory sync plugin: its one skill,
  `hooks/hooks.json`, `scripts/memory-sync.sh` and `settings.example.json`.
- `docs/specs/` — one spec per area: how it works now, why, what is not
  verified, what is open (*Rules*, the `plan/` rule).
- `tests/` (the scripts' tests, and `tests/fixtures/product-loop/`, the
  walkthrough's sample product), `plan/` (the working area of changes in
  progress), `docs/`, `host.example.md`, `README.md`, `.gitignore` (it holds
  `plan/handoff/`, the managers' per-session handoff files) and this file
  belong to the repo and to neither plugin.

## Gates

The tests create their work directories under `$TMPDIR`. Export `TMPDIR` to the
temp directory your host file names first, then run all seven, in order, and
paste what they print:

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh plugins/glab/scripts/plan-gate.sh tests/memory-sync.test.sh tests/context-size.test.sh tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh plugins/glab/scripts/plan-gate.sh tests/memory-sync.test.sh tests/context-size.test.sh tests/plan-gate.test.sh tests/manager-bootstrap.test.sh tests/product-loop.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
    bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh
    bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh
    bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh
    bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh

Green is: nine `rc=0` lines; `rc=0` with no findings; for each test, every
line `ok` and its last line `PASS n/n`. The `test -x` is there because a
hook script that has lost its execute bit passes every other gate and then
fails when the hook runs. It is joined to `bash -n` with `&&` so that the
`rc` printed is the syntax check's when that fails; with `;` a syntax error
printed `rc=0`.

Then the plugin gates. `claude` is the Claude Code CLI: `claude` on `PATH`, or
the path your host file names. A host without `claude` on `PATH` exports
`CLAUDE_BIN` as that path before running the block. **Every `claude` command run in this repo has
`CLAUDE_CONFIG_DIR` set to a new, empty directory under that temp directory.**
The CLI writes into its config directory even for `plugin validate`, and
without the variable that directory is the live `~/.claude`.

    claude=$(command -v "${CLAUDE_BIN:-claude}"); : "${claude:?no Claude Code CLI found - set CLAUDE_BIN to the path your host file names}"
    cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX") && [ -d "$cfg" ] && (
      export CLAUDE_CONFIG_DIR="$cfg"
      for p in plugins/glab plugins/memory-sync .; do "$claude" plugin validate --strict "$p" | tail -n 1; done
      "$claude" --plugin-dir ./plugins plugin details glab | command grep -E '^  (Skills|Agents|Hooks) '
      "$claude" --plugin-dir ./plugins plugin details memory-sync | command grep -E '^  (Skills|Agents|Hooks) '
    ); rm -rf "${cfg:?}"
    jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r n s; do echo "$n = $(jq -r .name "$s/.claude-plugin/plugin.json")"; done
    command grep -c user_config plugins/*/hooks/hooks.json; echo "rc=$?"
    command grep -c -F 'not yet confirmed' plugins/memory-sync/scripts/memory-sync.sh plugins/memory-sync/skills/sync-memory/SKILL.md README.md; echo "rc=$?"
    command grep -H '^model: ' plugins/*/agents/*.md; echo "rc=$?"
    for f in plugins/*/agents/*.md; do awk 'FNR==1{n=0} /^---$/{n++; next} n==1 && /^skills:/{s=1; next} n==1 && s && /^  - /{print FILENAME ":" $2; next} {s=0}' "$f"; done | while IFS=: read -r f p s; do r=${f%%/agents/*}; if test -f "$r/skills/$s/SKILL.md" && command grep -qx "name: $s" "$r/skills/$s/SKILL.md" && [ "$p" = "$(jq -r .name "$r/.claude-plugin/plugin.json")" ]; then echo "$f:$p:$s"; else echo "$f:$p:$s MISSING"; fi; done
    command grep -rH --include='*.md' '^name: .*:' plugins; echo "rc=$?"

The first line finds the CLI. When there is none it stops the block with the
message after `:?`, so no later line is printed as though the gates had run.
That holds when the block runs as a script or through an agent's shell; pasted
into an interactive shell, `:?` aborts only its own line and the rest still runs.
The second makes the config directory and starts no `claude` command when it
cannot — with `TMPDIR` unset nothing runs — and removes the directory again at
the end. `CLAUDE_CONFIG_DIR` is never exported empty.

Green is:

- three `✔ Validation passed` lines;
- for `glab`: `Skills (25)` naming `audit`, `bootstrap`, `comments`, `commit`, `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-analyze`, `product-project-plan-verdict`, `project-analyze`, `project-develop`, `project-integrate`, `project-manager`, `project-plan`, `project-plan-accept`, `project-plan-analyze`, `project-plan-report`, `project-record`, `project-review`, `project-ship`, `push`, `security`, `session-rules` and `severity`, `Agents (9)` naming `committer`, `product-analyzer`, `product-planner`, `project-analyzer`, `project-developer`, `project-integrator`, `project-plan-analyzer`, `project-planner` and `project-reviewer` in any order (the CLI lists them in directory read order, which is not stable), and `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`;
- for `memory-sync`: `Skills (1)  sync-memory`, `Agents (0)`, and `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
- each of those two `Hooks` lines followed, on the same line, by `  (harness-only — no model context cost)`: the CLI prints that suffix, and it is expected;
- `glab = glab` and `memory-sync = memory-sync`. Validation does not compare a marketplace entry with the plugin it points at; it passes with a wrong name and with a directory that does not exist;
- `:0` after each `hooks.json`, then `rc=1`. `grep -c` exits 1 when it counts nothing, and nothing is the green result here. A `${user_config.…}` in a hook command passes validation and fails when the hook runs;
- a count of `1` or more after each of the three files, then `rc=0`. Read the counts, not the `rc`: `grep -c` exits 0 as soon as one file matches. The phrase is the hedge on `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` — documented as the override for the `SessionEnd` budget, not yet shown to cover a hook that a plugin provides — and no other gate notices when the script comment, the skill or the README starts stating it as fact;
- exactly these nine lines, then `rc=0`: `plugins/glab/agents/project-analyzer.md:model: sonnet`, `plugins/glab/agents/committer.md:model: haiku`, `plugins/glab/agents/project-developer.md:model: sonnet`, `plugins/glab/agents/project-integrator.md:model: sonnet`, `plugins/glab/agents/project-plan-analyzer.md:model: opus`, `plugins/glab/agents/project-planner.md:model: opus`, `plugins/glab/agents/product-analyzer.md:model: opus`, `plugins/glab/agents/product-planner.md:model: opus`, `plugins/glab/agents/project-reviewer.md:model: sonnet`. `plugin validate --strict` passes an unknown model value and `plugin details` shows none, so nothing else catches a typo;
- from the skills gate, exactly these eighteen lines, none ending `MISSING`: `plugins/glab/agents/project-analyzer.md:glab:security`, `plugins/glab/agents/project-analyzer.md:glab:severity`, `plugins/glab/agents/committer.md:glab:security`, `plugins/glab/agents/project-developer.md:glab:security`, `plugins/glab/agents/project-developer.md:glab:comments`, `plugins/glab/agents/project-integrator.md:glab:security`, `plugins/glab/agents/project-integrator.md:glab:comments`, `plugins/glab/agents/project-plan-analyzer.md:glab:security`, `plugins/glab/agents/project-plan-analyzer.md:glab:severity`, `plugins/glab/agents/project-planner.md:glab:project-plan`, `plugins/glab/agents/project-planner.md:glab:security`, `plugins/glab/agents/product-analyzer.md:glab:security`, `plugins/glab/agents/product-analyzer.md:glab:severity`, `plugins/glab/agents/product-planner.md:glab:product-plan`, `plugins/glab/agents/product-planner.md:glab:security`, `plugins/glab/agents/project-reviewer.md:glab:security`, `plugins/glab/agents/project-reviewer.md:glab:comments`, `plugins/glab/agents/project-reviewer.md:glab:severity`. A line ends `MISSING` when its entry names no `skills/<name>/SKILL.md` in that plugin, when that file's frontmatter has no line `name: <name>` — Claude Code names a plugin skill by that line, not by its directory — or when it carries another plugin's prefix. `plugin validate --strict` passes an agent's `skills:` entry that names no skill and `plugin details` does not show the lists, so nothing else catches a typo;
- no line, then `rc=1`, from the last command. A frontmatter `name:` that carries the plugin prefix passes validation and `plugin details`, and nothing else catches it.

The Markdown files have no gate. A change to one is verified by running the
commands it prescribes in a throwaway directory and by the searches its plan
names.

## Tests

This section is a scoped exception to any general rule against hand-written
fakes and to any coverage percentage. It applies to the shell scripts in this
repo and to nothing else.

- **A stub executable placed first on `PATH` is the allowed way to fake an
  external CLI** such as `aws`. `tests/memory-sync.test.sh` does this.
  `tests/context-size.test.sh` fakes a missing `jq` the other way round, with
  a `PATH` that lacks it.
- **Coverage is reported as a list, not a number.** No tool measures it for
  bash. For each plan step, name the test cases that cover it; name each
  change no case covers, and why that is accepted.

## Rules

- **No secrets.** No bucket name, endpoint, profile name or environment value
  in any file, commit message or report. Use `<bucket>`, `<prefix>`,
  `<profile, or delete this key>`.
- **Never run `memory-sync.sh` against a real backend from this repo.** Use
  the stub in `tests/memory-sync.test.sh`.
- **Nothing is copied into `~/.claude` or removed from it by an agent, and no
  agent installs a plugin.** No agent runs `claude plugin install`, `claude plugin marketplace
  add`, `claude plugin enable` or `claude plugin configure`, in a shell or
  through `/plugin`. Installing is the user's step. An agent tests with
  `claude plugin validate` and `--plugin-dir`, under the `CLAUDE_CONFIG_DIR`
  rule in *Gates*.
- **The hook contracts do not change without a plan.** `memory-sync.sh`: the
  mode names, exit 0 on every path, nothing on stdout, messages on stderr.
  `context-size.sh`: the mode names, exit 0 on every path, on stdout one
  JSON object or nothing, messages on stderr, and in mode `stop` no key but
  `systemMessage` — it never blocks a turn or continues one.
  `manager-bootstrap.sh`: exit 0 on every path, on stdout one JSON object
  whose only key is `hookSpecificOutput`, or the plain text when `jq` fails,
  messages on stderr, and the level read from the first `glab-level:` line of
  the repo's `AGENTS.md` — the project level when there is none; it reads
  `session_id` from stdin with `jq`, never from a terminal, and names
  `plan/handoff/<id>.md` only for an id matching
  `^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$`, the `no session id` line otherwise.
  One script is not a hook, and its contract holds the same way —
  `plan-gate.sh`: the mode names `digest`, `report`, `verdict` and `check`;
  exit 0 done, 1 refused, 2 usage or a failed write; every refusal one `REFUSED:` line on stderr, and no
  write but the takeover before it of a claim, and its temporary file, whose
  run provably no longer runs.
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. A rule lives in the file of the
  role that acts on it; every other file points at it without restating it,
  so each fact below is one that more than one file states. Known cases:
  the round caps — Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b),
  and P1b at the product level, at most 2 rounds at every tier, per sub-plan
  where there are, a third only
  on a `critical` or `high` finding of round 2, recorded
  first as a `## Decisions` line, or in the handoff line and this
  conversation when there is no plan, none past 3
  (`plugins/glab/skills/session-rules/SKILL.md` *Round caps*,
  `plugins/glab/skills/project-plan-analyze/SKILL.md`, and the
  reviewer's round-2 rule in `plugins/glab/agents/project-reviewer.md`
  *Re-reviews*); the four ask-conditions of `glab:session-rules` Rule 3 —
  destructive, costs money, exposes real data, changes
  what the product is (`plugins/glab/skills/session-rules/SKILL.md`,
  `plugins/glab/skills/project-plan/SKILL.md` Step 2); the missing-`AGENTS.md`
  fallback (every agent, and the session-start text in
  `plugins/glab/scripts/manager-bootstrap.sh`); the hook events
  (`plugins/memory-sync/hooks/hooks.json`, `README.md`,
  `plugins/memory-sync/skills/sync-memory/SKILL.md`, the header of
  `plugins/memory-sync/scripts/memory-sync.sh`); the default time limit of
  `memory-sync.sh` (the script, its test, `README.md`); the marketplace and
  plugin names (`.claude-plugin/marketplace.json`, both `plugin.json`,
  `README.md`); what each plugin holds — its component counts and its
  hook events (the *Gates* section of this file, `README.md`, each plugin's
  `hooks/hooks.json`);
  the 20-second hook timeout of `memory-sync` (every `timeout` in
  `plugins/memory-sync/hooks/hooks.json`, the comments in the script that
  reason from it, `README.md`); the largest time limit the script accepts, 17
  (the script, its test, `README.md`); the 1.5-second `SessionEnd` budget and
  the hedged sentence about its override (the script comment, the
  `memory-sync:sync-memory` skill, `README.md`, and the
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key in the plugin's settings
  example); the model per role — each agent's frontmatter `model` per the
  table, the user's words overriding any role, no `model` parameter
  otherwise, and `model <alias>` on every agent stage's handoff line
  (`glab:session-rules` Rule 5 and *The handoff line* in
  `plugins/glab/skills/session-rules/SKILL.md`, the nine
  `plugins/glab/agents/*.md`, `README.md`, and the model gate in this file's
  *Gates*); the skills each agent preloads — its frontmatter `skills:` list,
  `glab:security` in all nine, `glab:project-plan` in the planner and
  `glab:product-plan` in the product planner, and no
  preloaded skill setting `disable-model-invocation`, which stops its
  preload (the nine `plugins/glab/agents/*.md`,
  `README.md`, and the skills gate in this file's *Gates*);
  the reviewer's verdict lines
  (`plugins/glab/agents/project-reviewer.md`, `plugins/glab/skills/project-manager/SKILL.md`,
  `plugins/glab/skills/project-review/SKILL.md`,
  `plugins/glab/skills/project-ship/SKILL.md`); the severity levels — `critical`,
  `high`, `medium`, `low` — their meanings in
  `plugins/glab/skills/severity/SKILL.md` only, which
  `plugins/glab/skills/audit/SKILL.md` points at, their four names in the
  *Report* of `plugins/glab/agents/project-reviewer.md`,
  `plugins/glab/agents/project-analyzer.md`, `plugins/glab/agents/project-plan-analyzer.md`
  and `plugins/glab/agents/product-analyzer.md`;
  every round a new agent, Rule 5's
  report check the one resume (`plugins/glab/skills/session-rules/SKILL.md`
  Rules 2 and 5, `plugins/glab/skills/project-plan-analyze/SKILL.md`,
  `plugins/glab/skills/project-develop/SKILL.md`,
  `plugins/glab/skills/project-review/SKILL.md`,
  `plugins/glab/skills/project-record/SKILL.md`,
  `plugins/glab/skills/project-plan/SKILL.md`,
  `plugins/glab/skills/project-ship/SKILL.md`, `plugins/glab/agents/project-reviewer.md`,
  `plugins/glab/agents/project-developer.md`); the
  mapping files `map-<area>.md`, the evidence file `evidence.md` — a
  subagent's Write of `findings.md` is refused — the round copies
  `<name>.r<n>.md` and the version copies `master.v<n>.md`
  (`plugins/glab/skills/project-manager/SKILL.md`,
  `plugins/glab/skills/project-plan/SKILL.md`,
  `plugins/glab/skills/project-plan-analyze/SKILL.md`,
  `plugins/glab/agents/project-analyzer.md`, `plugins/glab/agents/project-plan-analyzer.md`
  (all but the version copies), `plugins/glab/agents/project-developer.md`, and for
  the round copies `plugins/glab/scripts/plan-gate.sh`, which leaves them out
  of the digest, `plugins/glab/skills/project-plan-report/SKILL.md` and
  `plugins/glab/skills/product-plan-analyze/SKILL.md`);
  the handoff file `plan/handoff/<session id>.md` — at most 4096 bytes, its
  `- status:` first line, and the standing approval that removes a completed one
  (`plugins/glab/skills/session-rules/SKILL.md` Rule 2,
  `plugins/glab/skills/bootstrap/SKILL.md` step 5, the pointers in
  `plugins/glab/skills/security/SKILL.md` and Rule 3,
  `plugins/glab/scripts/manager-bootstrap.sh`,
  `tests/manager-bootstrap.test.sh`); the `glab` context
  hook — the modes `prompt`, `agent` and `stop` on `UserPromptSubmit`,
  `PostToolUse` with matcher `Agent` and `Stop`, the line
  `glab: context <n>k (last completed call)`,
  with `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set, the
  `Stop` message, and the first step 300k, or `GLAB_COMPACT_AT` thousand
  when set, and every 100k after it, and the warning for an invalid value
  (`plugins/glab/scripts/context-size.sh`,
  `tests/context-size.test.sh`, `plugins/glab/hooks/hooks.json`,
  `plugins/glab/skills/session-rules/SKILL.md`, `README.md`); what a review
  round after the first is given — a new reviewer, the target, the previous
  round's findings verbatim and the range of the fix, never the plan, the
  slug or the intent (`plugins/glab/skills/project-review/SKILL.md`, and
  what the reviewer does with them in `plugins/glab/agents/project-reviewer.md`);
  the plan lifecycle — specs in
  `docs/specs/` unless `AGENTS.md` names another place, the record after the
  push, and that the record never removes the plan folder
  (`plugins/glab/skills/project-plan/SKILL.md`,
  `plugins/glab/skills/project-record/SKILL.md`,
  `plugins/glab/agents/project-developer.md`, `plugins/glab/agents/project-analyzer.md`,
  `plugins/glab/skills/bootstrap/SKILL.md`,
  `plugins/glab/skills/audit/SKILL.md`, `README.md`, and this file's
  `plan/` rule);
  the session effort — the Agent tool's `effort` on every subagent dispatch,
  its order (the level the user named for the session, then
  `CLAUDE_CODE_EFFORT_LEVEL`, then ask once per session), its `- effort:`
  record line, the override for one agent, role or task, and
  `· effort <level>` in the handoff line (`glab:session-rules` Rules 0d and 5
  and *The handoff line* in `plugins/glab/skills/session-rules/SKILL.md`, the
  one pointer
  line in `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`); the plan
  size budget —
  48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`, and the
  product level's `product-plan.md`, and the `- size:` line
  (`plugins/glab/skills/project-plan/SKILL.md` Step 3,
  `plugins/glab/skills/product-plan/SKILL.md`,
  `plugins/glab/skills/project-plan-accept/SKILL.md` checklist item 6);
  amendments replace the text they change, in place
  (`plugins/glab/skills/project-plan/SKILL.md` Step 4,
  `plugins/glab/agents/project-plan-analyzer.md` *Re-checks*); `glab:project-plan`'s step
  numbers — 0 to 4
  (`plugins/glab/skills/project-plan/SKILL.md`,
  `plugins/glab/skills/project-manager/SKILL.md`, `plugins/glab/agents/project-planner.md`,
  `plugins/glab/agents/project-plan-analyzer.md`,
  `plugins/glab/skills/project-plan-accept/SKILL.md`,
  `plugins/glab/skills/project-plan-analyze/SKILL.md`);
  the master plan and sub-plans — `master.md` with its six sections,
  constant after `## Approval` and hashed in `master.sha256`, a changed
  request a new master with the old kept as `master.v<n>.md` and its
  approval and hash not carried over, `index.md`, the folders
  `<nn>-<name>/`, the user's approval of every full-tier `plan.md`, a
  single plan's or a sub-plan's, one commit per sub-plan, one final check, push and record per
  slug, and `## Record` in the master
  (`plugins/glab/skills/project-plan/SKILL.md`,
  `plugins/glab/skills/project-manager/SKILL.md`, `plugins/glab/agents/project-analyzer.md`,
  `plugins/glab/skills/project-plan-accept/SKILL.md`,
  `plugins/glab/agents/project-plan-analyzer.md`,
  `plugins/glab/agents/project-developer.md`,
  `plugins/glab/skills/project-analyze/SKILL.md`, `plugins/glab/skills/project-develop/SKILL.md`,
  `plugins/glab/skills/audit/SKILL.md`, `README.md`);
  the intent check — the analyzers at Stage 1b (`glab:project-plan-analyzer`), Stage
  3 and the final check (`glab:project-analyzer`), never the reviewer
  (`plugins/glab/agents/project-analyzer.md`, `plugins/glab/agents/project-plan-analyzer.md`,
  `plugins/glab/skills/project-analyze/SKILL.md`, `README.md`);
  the analyzers' verdict lines — `BUILDABLE`, `NOT BUILDABLE`
  (`glab:project-plan-analyzer`), `CONFORMS`, `DIVERGES: <n> steps` (`glab:project-analyzer`),
  `BLOCK: target unresolved` (all three), and `glab:product-analyzer`'s
  `SOUND`, `NOT SOUND: <n> findings`, `NO CONFLICT` and `CONFLICTS: <n>`
  (`plugins/glab/agents/project-analyzer.md`, `plugins/glab/agents/project-plan-analyzer.md`,
  `plugins/glab/skills/project-manager/SKILL.md`,
  `plugins/glab/skills/project-analyze/SKILL.md`, `plugins/glab/skills/project-plan/SKILL.md`,
  `plugins/glab/skills/project-plan-analyze/SKILL.md`,
  `plugins/glab/skills/project-develop/SKILL.md`,
  `plugins/glab/skills/project-plan-report/SKILL.md`,
  `plugins/glab/skills/project-review/SKILL.md`,
  `plugins/glab/skills/project-record/SKILL.md`,
  `plugins/glab/agents/product-analyzer.md`,
  `plugins/glab/skills/product-manager/SKILL.md`,
  `plugins/glab/skills/product-plan-analyze/SKILL.md`,
  `plugins/glab/skills/product-project-plan-analyze/SKILL.md`,
  `plugins/glab/skills/product-project-plan-verdict/SKILL.md`); approval in
  plan mode — only
  when the user asks, no plan file outside the repo, `plansDirectory` never
  changed, its claims UNVERIFIED until L1–L7
  (`plugins/glab/skills/project-plan-accept/references/plan-mode.md`,
  `plugins/glab/skills/project-manager/SKILL.md`,
  `plugins/glab/skills/project-plan-accept/SKILL.md`, `README.md`); the level line
  `glab-level:` — the first line of a repo's `AGENTS.md` that begins
  `glab-level:`; `product` and `project` built, no line the project level, any
  other value the project level with the warning, `delivery` and `support`
  reserved (`plugins/glab/scripts/manager-bootstrap.sh`,
  `tests/manager-bootstrap.test.sh`, `tests/product-loop.test.sh`,
  `plugins/glab/skills/bootstrap/SKILL.md`, `README.md`); the shared store
  line `glab-shared-store:` — the repo's `AGENTS.md` first, then the host file
  (`plugins/glab/skills/product-manager/SKILL.md`,
  `plugins/glab/skills/project-manager/SKILL.md` *Dispatching the planner*,
  `plugins/glab/skills/project-develop/SKILL.md`,
  `plugins/glab/skills/project-plan-report/SKILL.md`, `README.md`,
  `host.example.md`); the store layout — `docs/product-rules/` with
  `index.md`, `briefs/<project>/brief.md`, `report.r<n>.md`, `plan.r<n>/`,
  `verdict.r<n>.md`, `releases/` reserved
  (`plugins/glab/scripts/plan-gate.sh`,
  `plugins/glab/skills/product-manager/SKILL.md` *The shared store*,
  `plugins/glab/skills/product-plan/SKILL.md`, `README.md`); the plan digest —
  its file set, what it leaves out (round and version copies, `plan.r<n>/`,
  `after-verdict.md`) and its order — and the report and verdict lines, their
  parse rules and refusals (`plugins/glab/scripts/plan-gate.sh`,
  `tests/plan-gate.test.sh`, `tests/product-loop.test.sh`,
  `plugins/glab/skills/project-plan-report/SKILL.md`,
  `plugins/glab/skills/session-rules/SKILL.md`,
  `plugins/glab/skills/project-develop/SKILL.md` and `README.md` *Levels*); the brief
  line — `- brief: briefs/<project>/brief.md sha256 <hash>`
  (`plugins/glab/skills/project-plan/SKILL.md`, `plugins/glab/skills/project-plan-accept/SKILL.md`
  checklist item 8, `plugins/glab/scripts/plan-gate.sh`,
  `tests/fixtures/product-loop/project-plan/master.md`); the rejection cap —
  two `REJECTED` verdicts on one project since its last `ACCEPTED`, over every
  brief, then a verdict by `user` only, its reason opening with the user's
  words (`plugins/glab/scripts/plan-gate.sh`,
  `plugins/glab/skills/product-manager/SKILL.md`,
  `plugins/glab/skills/product-project-plan-verdict/SKILL.md`,
  `tests/plan-gate.test.sh`, `tests/product-loop.test.sh`, `README.md`); the
  rule file budget — 8192 bytes (`plugins/glab/skills/product-plan/SKILL.md`,
  `tests/product-loop.test.sh`); the rules of every level — Rules 0, 0b, 0c,
  0d, 1, 2, 3 and 5, *Round caps*, *The handoff line* and *The level boundary*
  in `glab:session-rules`, which each level's manager loads and cites by
  number (`plugins/glab/skills/session-rules/SKILL.md`,
  `plugins/glab/skills/project-manager/SKILL.md`,
  `plugins/glab/skills/product-manager/SKILL.md`,
  `plugins/glab/scripts/manager-bootstrap.sh`,
  `plugins/glab/skills/bootstrap/SKILL.md`, `README.md`); the level boundary —
  each manager's *Your skills — this level only* the binding list, a
  description's level prefix `Product level — ` or `Project level — ` a hint,
  no prefix on what serves every level
  (`plugins/glab/skills/session-rules/SKILL.md`,
  `plugins/glab/skills/project-manager/SKILL.md`,
  `plugins/glab/skills/product-manager/SKILL.md`,
  `plugins/glab/scripts/manager-bootstrap.sh`, the `description:` of every
  `plugins/glab/skills/*/SKILL.md` and `plugins/glab/agents/*.md`,
  `README.md`).
- **Comments and recorded incidents are kept.** Update them when the thing
  they describe changes; do not delete them.
- **Tests clean up by PID.** A test kills only processes it started itself,
  never by name or pattern.
- **`plan/` is the working area; `docs/specs/` is what stays.** A change's
  `plan/<slug>/` is committed with the change. After its push, the record
  (`glab:project-record`) updates the spec of each area it touched —
  `marketplace.md` (the marketplace, this repo's layout, gates and rules),
  `workflow.md` (the `glab` workflow), `product.md` (the product level and the
  product ⇄ project loop), `memory-sync.md`,
  `external-agents.md` (removed in 0.8.0, a record only): how the area works
  now, the decisions that still
  bind, what is not verified, every follow-up — open or closed, each tagged
  `[<slug>/<file> <id>]` — and its incidents, moved into *Incidents* rather
  than dropped (*Comments and recorded incidents are kept*). A spec states a
  fact as of its last record and names the file that owns it, so it is not
  one of the *One fact* files. Once the change has landed on `origin/main`,
  the manager session — not a `glab` step — removes the folder by its exact
  path in a `docs(repo)` commit, after checking that it is tracked, clean
  (`git status --short -uall -- plan/<slug>/` prints nothing) and identical
  on `origin/main` (`git diff --quiet origin/main -- plan/<slug>/`); the
  spec's *Records* line names the last commit on `origin/main` that holds
  it. Read it back without touching the tree: one file
  `git show <sha>:plan/<slug>/<file>`, the list
  `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole folder
  `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`.
  No untracked file under `plan/` is removed, except a completed handoff file
  under `glab:session-rules` Rule 2's standing approval;
  `plan/handoff/` is never committed.
- **A change under `plugins/<name>/` raises that plugin's `version`** in
  `plugins/<name>/.claude-plugin/plugin.json`, in the same commit. When one
  push carries several commits of one change — one per sub-plan — the first
  that changes `plugins/<name>/` raises it, once. An installed
  copy is pinned to the version string: without a new one nobody receives the
  change, and nothing says so.
- **Payload text names a plugin component by its prefixed name** —
  `glab:project-manager`, `glab:project-developer`, `/glab:project-plan`. The frontmatter `name:` of a
  skill or agent stays bare: Claude Code adds the prefix, and an agent name
  containing `:` does not load. A role named in running prose — "the
  analyzer", "the reviewer" — is not an identifier and stays as it is.

## Commits

Conventional Commits: `type(scope): subject`, imperative subject, optional
body of short bullets. Types `feat`, `fix`, `refactor`, `perf`, `test`,
`docs`, `build`, `ci`, `chore`. Scope is optional; when used it is the area —
`sync`, `agents`, `skills`, `repo`. One logical change per commit.
