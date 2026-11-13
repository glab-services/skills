# flow-commands-to-skills — steps for `AGENTS.md`

Part of `plan.md` *processing*, run after P1. File boundary: `AGENTS.md` only (`plan.md` P6–P8 hold the other repo files). Old texts are as of `5a72155`. The blocks follow `plan.md` *Block formats*, in the order written; each edit's check is its line in the posts block at the end of this file.

## R0 — the component "command" leaves the layout, the *Gates* green line and the scopes (F8)

`:11`, *Layout*:

~~~ R0.1 old AGENTS.md
— the workflow plugin: its skills, agents and commands,
~~~
~~~ R0.1 new
— the workflow plugin: its skills and agents,
~~~

`:71`, *Green is*, the `glab` line — the rest of the line stays:

~~~ R0.2 old AGENTS.md
`Skills (14)` naming the six skills and the eight commands
~~~
~~~ R0.2 new
`Skills (13)` naming `analyze`, `audit`, `bootstrap`, `comments`, `commit`, `develop`, `integrate`, `manager`, `plan`, `push`, `review`, `security` and `ship`
~~~

`:303`, *Commits*:

~~~ R0.3 old AGENTS.md
`sync`, `agents`, `commands`, `skills`, `repo`
~~~
~~~ R0.3 new
`sync`, `agents`, `skills`, `repo`
~~~

## R1 — *One fact, one value* shrinks to the files that still state each fact

The whole bullet, `:115-258` — from "- **One fact, one value.**" through "`plugins/glab/scripts/manager-bootstrap.sh`).", the line before "- **Comments and recorded incidents are kept.**" — becomes the new block.

What changed against `5a72155`, entry by entry (every other entry is carried word for word): the opening adds who owns a rule (decision FU1-1); round caps → manager and the reviewer's last-round rule (A13, B6, B7, B20); ask-conditions → manager and `glab:plan` (A28); missing-`AGENTS.md` fallback → every agent and the hook text (A10, B18); model per role → the seven stage files dropped (A29, B17); a new entry for the preloaded skills, with the `disable-model-invocation` rule (A1; F4 of `check-facts.md`); reviewer's verdict lines → `ship.md` renamed; severity levels → meanings in `glab:audit` only (C17); every round a new agent → three command files dropped, `ship/SKILL.md` and `reviewer.md` added (A10, B19, B27, B28; R7); what a review round after the first is given → manager Stage 5 and the reviewer (B19); plan lifecycle → `commands/plan.md` and the script dropped (A7, B30); session effort → stage files, Stages 2 and 5, bootstrap dropped (A11, A29); amendments in place → manager dropped (A2); step numbers → `glab:plan`'s 0 to 4, with `planner.md` and `plan-analyzer.md` (A4, A15; R7); master plan and sub-plans → `commands/plan.md` dropped, the other two renamed (B30); intent check → `commands/analyze.md` dropped, `analyze/SKILL.md` added (B28; R7); analyzers' verdict lines → renamed (B5); the session-start rules and the stage sequence → dropped, as one file now states each — `manager-bootstrap.sh`, which `glab:bootstrap` points at, and `glab:manager` — so every entry left is a fact more than one file states (A7, A12; R2-5 of `check-repo-2.md`); every `plugins/glab/skills/plan-first/SKILL.md` → `plugins/glab/skills/plan/SKILL.md` (decision *glab:plan*).

~~~ R1 old AGENTS.md
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. Known cases:
  the round caps — Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b)
  at most 2 rounds at every tier, per sub-plan where there are, a third only
  on a `critical` or `high` finding of round 2, recorded
  first as a `## Decisions` line, or in the handoff line and this
  conversation when there is no plan, none past 3
  (`plugins/glab/agents/reviewer.md`, `plugins/glab/agents/analyzer.md`,
  `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/commands/ship.md`, `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/bootstrap/SKILL.md`); the four ask-conditions of
  `glab:manager` Rule 3 — destructive, costs money, exposes real data, changes
  what the product is (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/commands/plan.md`,
  `plugins/glab/commands/develop.md`, and their count, four, in
  `plugins/glab/skills/bootstrap/SKILL.md`); the missing-`AGENTS.md` fallback
  (every agent and command); the hook events
  (`plugins/memory-sync/hooks/hooks.json`, `README.md`,
  `plugins/memory-sync/skills/sync-memory/SKILL.md`, the header of
  `plugins/memory-sync/scripts/memory-sync.sh`); the default time limit of
  `memory-sync.sh` (the script, its test, `README.md`); the marketplace and
  plugin names (`.claude-plugin/marketplace.json`, both `plugin.json`,
  `README.md`); the session-start rules (the text in
  `plugins/glab/scripts/manager-bootstrap.sh` and the `glab:bootstrap` skill);
  what each plugin holds — its component counts and its hook events (the
  *Gates* section of this file, `README.md`, each plugin's `hooks/hooks.json`);
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
  (`glab:manager` Rule 5 and its handoff-line format in
  `plugins/glab/skills/manager/SKILL.md`, the seven
  `plugins/glab/agents/*.md`, `plugins/glab/commands/develop.md`,
  `plugins/glab/commands/review.md`, `plugins/glab/commands/ship.md`,
  `plugins/glab/commands/analyze.md`, `plugins/glab/commands/integrate.md`,
  `plugins/glab/commands/commit.md`, `plugins/glab/commands/plan.md`,
  `README.md`, and the model gate in this file's *Gates*);
  the reviewer's verdict lines
  (`plugins/glab/agents/reviewer.md`, `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/commands/ship.md`); the severity levels — `critical`,
  `high`, `medium`, `low` and their meanings
  (`plugins/glab/skills/audit/SKILL.md`, `plugins/glab/agents/reviewer.md`,
  `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`);
  every round a new agent, Rule 5's
  report check the one resume (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan-first/SKILL.md`,
  `plugins/glab/agents/developer.md`, `plugins/glab/commands/develop.md`,
  `plugins/glab/commands/ship.md`, `plugins/glab/commands/analyze.md`); the
  mapping files `map-<area>.md`, the evidence file `evidence.md` — a
  subagent's Write of `findings.md` is refused — the round copies
  `<name>.r<n>.md` and the version copies `master.v<n>.md`
  (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan-first/SKILL.md`,
  `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`
  (all but the version copies), `plugins/glab/agents/developer.md`);
  the handoff file `plan/SESSION-HANDOFF.md`
  (`plugins/glab/skills/bootstrap/SKILL.md` step 5,
  `plugins/glab/skills/manager/SKILL.md` Rule 2); the `glab` context hook —
  the modes `prompt`, `agent` and `stop` on `UserPromptSubmit`,
  `PostToolUse` with matcher `Agent` and `Stop`, the line
  `glab: context <n>k (last completed call)`,
  with `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set, the
  `Stop` message, and the first step 300k, or `GLAB_COMPACT_AT` thousand
  when set, and every 100k after it, and the warning for an invalid value
  (`plugins/glab/scripts/context-size.sh`,
  `tests/context-size.test.sh`, `plugins/glab/hooks/hooks.json`,
  `plugins/glab/skills/manager/SKILL.md`, `README.md`); what a review round
  after the first is given — a new reviewer, the target, the previous
  round's findings verbatim and the range of the fix, never the plan, the
  slug or the intent (`plugins/glab/agents/reviewer.md`,
  `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/commands/ship.md`);
  the plan lifecycle — specs in
  `docs/specs/` unless `AGENTS.md` names another place, the record after the
  push, and that the record never removes the plan folder
  (`plugins/glab/skills/plan-first/SKILL.md`,
  `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/commands/plan.md`,
  `plugins/glab/agents/developer.md`, `plugins/glab/agents/analyzer.md`,
  `plugins/glab/skills/bootstrap/SKILL.md`,
  `plugins/glab/skills/audit/SKILL.md`,
  `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`, and this file's
  `plan/` rule);
  the session effort — the Agent tool's `effort` on every subagent dispatch,
  its order (the level the user named for the session, then
  `CLAUDE_CODE_EFFORT_LEVEL`, then ask once per session), its `- effort:`
  record line, the override for one agent, role or task, and
  `· effort <level>` in the handoff line (`glab:manager` Rules 0d and 5,
  Stages 2 and 5 and *The pipeline* in
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/commands/develop.md`, `plugins/glab/commands/review.md`,
  `plugins/glab/commands/ship.md`, `plugins/glab/commands/analyze.md`,
  `plugins/glab/commands/integrate.md`, `plugins/glab/commands/commit.md`,
  `plugins/glab/commands/plan.md`, `plugins/glab/skills/bootstrap/SKILL.md`,
  `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`); the plan size
  budget —
  48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`, and
  the `- size:` line (`plugins/glab/skills/plan-first/SKILL.md` Step 3,
  `plugins/glab/skills/manager/SKILL.md` acceptance checklist item 6);
  amendments replace the text they change, in place
  (`plugins/glab/skills/plan-first/SKILL.md` Step 4,
  `plugins/glab/skills/manager/SKILL.md` Stage 1b,
  `plugins/glab/agents/plan-analyzer.md` *Re-checks*); `glab:plan-first`'s step
  numbers — 0 to 4 in `SKILL.md`, 5 to 7 in `implement.md`
  (`plugins/glab/skills/plan-first/SKILL.md`,
  `plugins/glab/skills/plan-first/implement.md`,
  `plugins/glab/commands/plan.md`, `plugins/glab/commands/develop.md`,
  `plugins/glab/skills/manager/SKILL.md`);
  the master plan and sub-plans — `master.md` with its six sections,
  constant after `## Approval` and hashed in `master.sha256`, a changed
  request a new master with the old kept as `master.v<n>.md` and its
  approval and hash not carried over, `index.md`, the folders
  `<nn>-<name>/`, the user's approval of every full-tier `plan.md`, a
  single plan's or a sub-plan's, one commit per sub-plan, one final check, push and record per
  slug, and `## Record` in the master
  (`plugins/glab/skills/plan-first/SKILL.md`,
  `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/analyzer.md`,
  `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/agents/developer.md`, `plugins/glab/commands/plan.md`,
  `plugins/glab/commands/analyze.md`, `plugins/glab/commands/develop.md`,
  `plugins/glab/skills/audit/SKILL.md`, `README.md`);
  the intent check — the analyzers at Stage 1b (`glab:plan-analyzer`), Stage
  3 and the final check (`glab:analyzer`), never the reviewer
  (`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/commands/analyze.md`, `README.md`);
  the analyzers' verdict lines — `BUILDABLE`, `NOT BUILDABLE`
  (`glab:plan-analyzer`), `CONFORMS`, `DIVERGES: <n> steps` (`glab:analyzer`),
  `BLOCK: target unresolved` (both)
  (`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/commands/analyze.md`,
  `plugins/glab/skills/plan-first/SKILL.md`); approval in plan mode — only
  when the user asks, no plan file outside the repo, `plansDirectory` never
  changed, its claims UNVERIFIED until L1–L7
  (`plugins/glab/skills/manager/SKILL.md`, `README.md`);
  the stage sequence with the final check
  (`plugins/glab/skills/manager/SKILL.md` description,
  `plugins/glab/skills/bootstrap/SKILL.md` step 4,
  `plugins/glab/scripts/manager-bootstrap.sh`).
~~~
~~~ R1 new
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. A rule lives in the file of the
  role that acts on it; every other file points at it without restating it,
  so each fact below is one that more than one file states. Known cases:
  the round caps — Stage 1b, Stage 3, Stage 5 and the final check (Stage 6b)
  at most 2 rounds at every tier, per sub-plan where there are, a third only
  on a `critical` or `high` finding of round 2, recorded
  first as a `## Decisions` line, or in the handoff line and this
  conversation when there is no plan, none past 3
  (`plugins/glab/skills/manager/SKILL.md` *Pick the tier*, and the
  reviewer's round-2 rule in `plugins/glab/agents/reviewer.md`
  *Re-reviews*); the four ask-conditions of
  `glab:manager` Rule 3 — destructive, costs money, exposes real data, changes
  what the product is (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan/SKILL.md` Step 2); the missing-`AGENTS.md`
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
  (`glab:manager` Rule 5 and its handoff-line format in
  `plugins/glab/skills/manager/SKILL.md`, the seven
  `plugins/glab/agents/*.md`, `README.md`, and the model gate in this file's
  *Gates*); the skills each agent preloads — its frontmatter `skills:` list,
  `glab:security` in all seven and `glab:plan` in the planner, and no
  preloaded skill setting `disable-model-invocation`, which stops its
  preload (the seven `plugins/glab/agents/*.md`,
  `README.md`, and the skills gate in this file's *Gates*);
  the reviewer's verdict lines
  (`plugins/glab/agents/reviewer.md`, `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/ship/SKILL.md`); the severity levels — `critical`,
  `high`, `medium`, `low` — their meanings in
  `plugins/glab/skills/audit/SKILL.md` only, their four names in the
  *Report* of `plugins/glab/agents/reviewer.md`,
  `plugins/glab/agents/analyzer.md` and `plugins/glab/agents/plan-analyzer.md`;
  every round a new agent, Rule 5's
  report check the one resume (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan/SKILL.md`,
  `plugins/glab/skills/ship/SKILL.md`, `plugins/glab/agents/reviewer.md`,
  `plugins/glab/agents/developer.md`); the
  mapping files `map-<area>.md`, the evidence file `evidence.md` — a
  subagent's Write of `findings.md` is refused — the round copies
  `<name>.r<n>.md` and the version copies `master.v<n>.md`
  (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan/SKILL.md`,
  `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`
  (all but the version copies), `plugins/glab/agents/developer.md`);
  the handoff file `plan/SESSION-HANDOFF.md`
  (`plugins/glab/skills/bootstrap/SKILL.md` step 5,
  `plugins/glab/skills/manager/SKILL.md` Rule 2); the `glab` context hook —
  the modes `prompt`, `agent` and `stop` on `UserPromptSubmit`,
  `PostToolUse` with matcher `Agent` and `Stop`, the line
  `glab: context <n>k (last completed call)`,
  with `; compact at <t>k` before the `)` when `GLAB_COMPACT_AT` is set, the
  `Stop` message, and the first step 300k, or `GLAB_COMPACT_AT` thousand
  when set, and every 100k after it, and the warning for an invalid value
  (`plugins/glab/scripts/context-size.sh`,
  `tests/context-size.test.sh`, `plugins/glab/hooks/hooks.json`,
  `plugins/glab/skills/manager/SKILL.md`, `README.md`); what a review round
  after the first is given — a new reviewer, the target, the previous
  round's findings verbatim and the range of the fix, never the plan, the
  slug or the intent (`plugins/glab/skills/manager/SKILL.md` Stage 5, and
  what the reviewer does with them in `plugins/glab/agents/reviewer.md`);
  the plan lifecycle — specs in
  `docs/specs/` unless `AGENTS.md` names another place, the record after the
  push, and that the record never removes the plan folder
  (`plugins/glab/skills/plan/SKILL.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/agents/developer.md`, `plugins/glab/agents/analyzer.md`,
  `plugins/glab/skills/bootstrap/SKILL.md`,
  `plugins/glab/skills/audit/SKILL.md`, `README.md`, and this file's
  `plan/` rule);
  the session effort — the Agent tool's `effort` on every subagent dispatch,
  its order (the level the user named for the session, then
  `CLAUDE_CODE_EFFORT_LEVEL`, then ask once per session), its `- effort:`
  record line, the override for one agent, role or task, and
  `· effort <level>` in the handoff line (`glab:manager` Rules 0d and 5 and
  *The pipeline* in `plugins/glab/skills/manager/SKILL.md`, the one pointer
  line in `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`); the plan
  size budget —
  48 KB each for `master.md`, `plan.md`, `index.md` and `evidence.md`, and
  the `- size:` line (`plugins/glab/skills/plan/SKILL.md` Step 3,
  `plugins/glab/skills/manager/SKILL.md` acceptance checklist item 6);
  amendments replace the text they change, in place
  (`plugins/glab/skills/plan/SKILL.md` Step 4,
  `plugins/glab/agents/plan-analyzer.md` *Re-checks*); `glab:plan`'s step
  numbers — 0 to 4
  (`plugins/glab/skills/plan/SKILL.md`,
  `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/planner.md`,
  `plugins/glab/agents/plan-analyzer.md`);
  the master plan and sub-plans — `master.md` with its six sections,
  constant after `## Approval` and hashed in `master.sha256`, a changed
  request a new master with the old kept as `master.v<n>.md` and its
  approval and hash not carried over, `index.md`, the folders
  `<nn>-<name>/`, the user's approval of every full-tier `plan.md`, a
  single plan's or a sub-plan's, one commit per sub-plan, one final check, push and record per
  slug, and `## Record` in the master
  (`plugins/glab/skills/plan/SKILL.md`,
  `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/agents/analyzer.md`,
  `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/agents/developer.md`,
  `plugins/glab/skills/analyze/SKILL.md`, `plugins/glab/skills/develop/SKILL.md`,
  `plugins/glab/skills/audit/SKILL.md`, `README.md`);
  the intent check — the analyzers at Stage 1b (`glab:plan-analyzer`), Stage
  3 and the final check (`glab:analyzer`), never the reviewer
  (`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/analyze/SKILL.md`, `README.md`);
  the analyzers' verdict lines — `BUILDABLE`, `NOT BUILDABLE`
  (`glab:plan-analyzer`), `CONFORMS`, `DIVERGES: <n> steps` (`glab:analyzer`),
  `BLOCK: target unresolved` (both)
  (`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/analyze/SKILL.md`,
  `plugins/glab/skills/plan/SKILL.md`); approval in plan mode — only
  when the user asks, no plan file outside the repo, `plansDirectory` never
  changed, its claims UNVERIFIED until L1–L7
  (`plugins/glab/skills/manager/SKILL.md`, `README.md`).
~~~

## R2 — the skills gate (A1; decision FU1-2)

The R2a line goes into the plugin-gate block of *Gates*, after the model gate (`:57`) and before the name gate (`:58`), so the name gate stays the last command its green line names:

~~~ R2a old AGENTS.md
    command grep -H '^model: ' plugins/*/agents/*.md; echo "rc=$?"
~~~
~~~ R2a new
    command grep -H '^model: ' plugins/*/agents/*.md; echo "rc=$?"
    for f in plugins/*/agents/*.md; do awk 'FNR==1{n=0} /^---$/{n++; next} n==1 && /^skills:/{s=1; next} n==1 && s && /^  - /{print FILENAME ":" $2; next} {s=0}' "$f"; done | while IFS=: read -r f p s; do r=${f%%/agents/*}; if test -f "$r/skills/$s/SKILL.md" && command grep -qx "name: $s" "$r/skills/$s/SKILL.md" && [ "$p" = "$(jq -r .name "$r/.claude-plugin/plugin.json")" ]; then echo "$f:$p:$s"; else echo "$f:$p:$s MISSING"; fi; done
~~~

The R2b bullet goes into *Green is*, after the model-gate bullet (`:76`) and before the name-gate bullet (`:77`):

~~~ R2b old AGENTS.md
- exactly these seven lines, then `rc=0`: `plugins/glab/agents/analyzer.md:model: sonnet`, `plugins/glab/agents/committer.md:model: haiku`, `plugins/glab/agents/developer.md:model: sonnet`, `plugins/glab/agents/integrator.md:model: sonnet`, `plugins/glab/agents/plan-analyzer.md:model: opus`, `plugins/glab/agents/planner.md:model: opus`, `plugins/glab/agents/reviewer.md:model: sonnet`. `plugin validate --strict` passes an unknown model value and `plugin details` shows none, so nothing else catches a typo;
~~~
~~~ R2b new
- exactly these seven lines, then `rc=0`: `plugins/glab/agents/analyzer.md:model: sonnet`, `plugins/glab/agents/committer.md:model: haiku`, `plugins/glab/agents/developer.md:model: sonnet`, `plugins/glab/agents/integrator.md:model: sonnet`, `plugins/glab/agents/plan-analyzer.md:model: opus`, `plugins/glab/agents/planner.md:model: opus`, `plugins/glab/agents/reviewer.md:model: sonnet`. `plugin validate --strict` passes an unknown model value and `plugin details` shows none, so nothing else catches a typo;
- from the skills gate, exactly these fourteen lines, none ending `MISSING`: `plugins/glab/agents/analyzer.md:glab:security`, `plugins/glab/agents/analyzer.md:glab:audit`, `plugins/glab/agents/committer.md:glab:security`, `plugins/glab/agents/developer.md:glab:security`, `plugins/glab/agents/developer.md:glab:comments`, `plugins/glab/agents/integrator.md:glab:security`, `plugins/glab/agents/integrator.md:glab:comments`, `plugins/glab/agents/plan-analyzer.md:glab:security`, `plugins/glab/agents/plan-analyzer.md:glab:audit`, `plugins/glab/agents/planner.md:glab:plan`, `plugins/glab/agents/planner.md:glab:security`, `plugins/glab/agents/reviewer.md:glab:security`, `plugins/glab/agents/reviewer.md:glab:comments`, `plugins/glab/agents/reviewer.md:glab:audit`. A line ends `MISSING` when its entry names no `skills/<name>/SKILL.md` in that plugin, when that file's frontmatter has no line `name: <name>` — Claude Code names a plugin skill by that line, not by its directory — or when it carries another plugin's prefix. `plugin validate --strict` passes an agent's `skills:` entry that names no skill and `plugin details` does not show the lists, so nothing else catches a typo;
~~~

The gate's discrimination was shown on a throwaway copy (F14): a made-up skill name and a foreign prefix each printed `MISSING`. On the built tree, `name: security` changed to `name: sec` in `glab:security`'s `SKILL.md` printed `MISSING` on all seven `glab:security` lines; the round-2 gate, without the `name:` test, printed none (F2-10 of `check-facts-2.md`). That the R2a line prints exactly the fourteen R2b lines on the finished tree is A1's.

## Posts

R1's first line compares the built bullet with the block byte for byte (R5 of `check-repo.md`); its second checks that every path the built bullet names exists.

~~~ posts
R0.1 | 1 | /usr/bin/grep -c -F '— the workflow plugin: its skills and agents,' AGENTS.md
R0.2 | 1 | /usr/bin/grep -c -F '`Skills (13)` naming `analyze`, `audit`, `bootstrap`' AGENTS.md
R0.3 | 1 | /usr/bin/grep -c -F '`sync`, `agents`, `skills`, `repo`' AGENTS.md
R1 | rc=0 | awk '/^- \*\*One fact, one value\.\*\*/{f=1} /^- \*\*Comments and recorded incidents are kept\.\*\*/{f=0} f' AGENTS.md | diff <(awk '$1=="~~~" && $2=="R1" && $3=="new"{f=1;next} f && $0=="~~~"{f=0} f' plan/flow-commands-to-skills/steps-repo.md) -; echo "rc=$?"
R1 | paths checked | awk '/^- \*\*One fact, one value\.\*\*/{f=1} /^- \*\*Comments and recorded incidents are kept\.\*\*/{f=0} f' AGENTS.md | /usr/bin/grep -o -E '(plugins|tests)/[A-Za-z0-9_./*-]+\.(md|sh|json)' | sort -u | while read -r p; do ls $p >/dev/null 2>&1 || echo "missing $p"; done; echo "paths checked"
R1 | 0 | /usr/bin/grep -c -E 'the session-start rules \(|the stage sequence with' AGENTS.md
R2a | 1 | /usr/bin/grep -c -F 'print FILENAME ":" $2' AGENTS.md
R2a | 1 | /usr/bin/grep -c -F 'command grep -qx "name: $s" "$r/skills/$s/SKILL.md"' AGENTS.md
R2b | 1 | /usr/bin/grep -c -F 'from the skills gate, exactly these fourteen lines' AGENTS.md
R2b | 1 | /usr/bin/grep -c -F 'when that file'"'"'s frontmatter has no line `name: <name>`' AGENTS.md
~~~
