# flow-commands-to-skills — steps for `AGENTS.md`

Part of `plan.md` *processing*, run after P5. File boundary: `AGENTS.md` only (P5–P8 in `plan.md` hold the other repo files). Blocks in `~~~ <id>` fences go in byte for byte, as in `steps-stages.md`.

## R1 — *One fact, one value* shrinks to the files that still state each fact

Replace the whole bullet — from "- **One fact, one value.**" (`AGENTS.md:115`) through "`plugins/glab/scripts/manager-bootstrap.sh`)." (`:258`), the line before "- **Comments and recorded incidents are kept.**" — with the R1 block. **Q1 = B:** then replace, inside it, "numbers — 0 to 4 in `SKILL.md`\n  (`plugins/glab/skills/plan-first/SKILL.md`," with "numbers — 0 to 4 in `SKILL.md`, 5 to 7 in `implement.md`\n  (`plugins/glab/skills/plan-first/SKILL.md`,\n  `plugins/glab/skills/plan-first/implement.md`,".

What changed against `5a72155`, entry by entry (every other entry is carried word for word): the opening adds who owns a rule (decision FU1-1); round caps → manager and the reviewer's last-round rule (A13, B6, B7, B20); ask-conditions → manager and plan-first (A28); missing-`AGENTS.md` fallback → every agent and the hook text (A10, B18); model per role → the seven stage files dropped (A29, B17); a new entry for the preloaded skills (A1); reviewer's verdict lines → `ship.md` renamed; severity levels → meanings in `glab:audit` only (C17); every round a new agent → three command files dropped (A10, B19, B27, B28); what a review round after the first is given → manager Stage 5 and the reviewer (B19); plan lifecycle → `commands/plan.md` and the script dropped (A7, B30); session effort → stage files, Stages 2 and 5, bootstrap dropped (A11, A29); amendments in place → manager dropped (A2); step numbers → per Q1 (A4, A15); master plan and sub-plans → `commands/plan.md` dropped, the other two renamed (B30); intent check → `commands/analyze.md` dropped (B28); analyzers' verdict lines → renamed (B5); stage sequence → bootstrap step 4 and the script dropped (A7, A12).

~~~ R1
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
  `plugins/glab/skills/plan-first/SKILL.md` Step 2); the missing-`AGENTS.md`
  fallback (every agent, and the session-start text in
  `plugins/glab/scripts/manager-bootstrap.sh`); the hook events
  (`plugins/memory-sync/hooks/hooks.json`, `README.md`,
  `plugins/memory-sync/skills/sync-memory/SKILL.md`, the header of
  `plugins/memory-sync/scripts/memory-sync.sh`); the default time limit of
  `memory-sync.sh` (the script, its test, `README.md`); the marketplace and
  plugin names (`.claude-plugin/marketplace.json`, both `plugin.json`,
  `README.md`); the session-start rules (the text in
  `plugins/glab/scripts/manager-bootstrap.sh`, which `glab:bootstrap` steps 1
  and 2 point at); what each plugin holds — its component counts and its
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
  `glab:security` in all seven (the seven `plugins/glab/agents/*.md`,
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
  `plugins/glab/skills/plan-first/SKILL.md`,
  `plugins/glab/agents/developer.md`); the
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
  slug or the intent (`plugins/glab/skills/manager/SKILL.md` Stage 5, and
  what the reviewer does with them in `plugins/glab/agents/reviewer.md`);
  the plan lifecycle — specs in
  `docs/specs/` unless `AGENTS.md` names another place, the record after the
  push, and that the record never removes the plan folder
  (`plugins/glab/skills/plan-first/SKILL.md`,
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
  the `- size:` line (`plugins/glab/skills/plan-first/SKILL.md` Step 3,
  `plugins/glab/skills/manager/SKILL.md` acceptance checklist item 6);
  amendments replace the text they change, in place
  (`plugins/glab/skills/plan-first/SKILL.md` Step 4,
  `plugins/glab/agents/plan-analyzer.md` *Re-checks*); `glab:plan-first`'s step
  numbers — 0 to 4 in `SKILL.md`
  (`plugins/glab/skills/plan-first/SKILL.md`,
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
  `plugins/glab/agents/developer.md`,
  `plugins/glab/skills/analyze/SKILL.md`, `plugins/glab/skills/develop/SKILL.md`,
  `plugins/glab/skills/audit/SKILL.md`, `README.md`);
  the intent check — the analyzers at Stage 1b (`glab:plan-analyzer`), Stage
  3 and the final check (`glab:analyzer`), never the reviewer
  (`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/skills/manager/SKILL.md`, `README.md`);
  the analyzers' verdict lines — `BUILDABLE`, `NOT BUILDABLE`
  (`glab:plan-analyzer`), `CONFORMS`, `DIVERGES: <n> steps` (`glab:analyzer`),
  `BLOCK: target unresolved` (both)
  (`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/plan-analyzer.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/analyze/SKILL.md`,
  `plugins/glab/skills/plan-first/SKILL.md`); approval in plan mode — only
  when the user asks, no plan file outside the repo, `plansDirectory` never
  changed, its claims UNVERIFIED until L1–L7
  (`plugins/glab/skills/manager/SKILL.md`, `README.md`);
  the stage sequence with the final check
  (`plugins/glab/skills/manager/SKILL.md` description and *The pipeline*).
~~~

Post: `/usr/bin/grep -c 'plugins/glab/commands/' AGENTS.md` prints `0`; `/usr/bin/grep -c 'bootstrap/SKILL.md` step 4' AGENTS.md` prints `0`; `/usr/bin/grep -c -E 'skills:` list|skills gate' AGENTS.md` prints `3` or more (this entry, R2's gate text and green line); every path the R1 block names exists after the build: `awk '$1=="~~~" && $2=="R1"{f=1;next} f && $0=="~~~"{f=0} f' plan/flow-commands-to-skills/steps-repo.md | /usr/bin/grep -o -E '(plugins|tests)/[A-Za-z0-9_./*-]+\.(md|sh|json)' | sort -u | while read -r p; do ls $p >/dev/null 2>&1 || echo "missing $p"; done` prints nothing (Q1 = B: `implement.md` included).

## R2 — the skills gate (A1; decision FU1-2)

- In the plugin-gate block of *Gates*, insert the R2a line between the model gate (`command grep -H '^model: ' …`, `:57`) and the name gate (`:58`), so the name gate stays the last command its green line names.

~~~ R2a
    for f in plugins/*/agents/*.md; do awk 'FNR==1{n=0} /^---$/{n++; next} n==1 && /^skills:/{s=1; next} n==1 && s && /^  - /{print FILENAME ":" $2; next} {s=0}' "$f"; done | while IFS=: read -r f p s; do r=${f%%/agents/*}; if test -f "$r/skills/$s/SKILL.md" && [ "$p" = "$(jq -r .name "$r/.claude-plugin/plugin.json")" ]; then echo "$f:$p:$s"; else echo "$f:$p:$s MISSING"; fi; done
~~~

- In *Green is*, insert the R2b bullet between the model-gate bullet (`:76`) and the name-gate bullet (`:77`).

~~~ R2b
- from the skills gate, exactly these fourteen lines, none ending `MISSING`: `plugins/glab/agents/analyzer.md:glab:security`, `plugins/glab/agents/analyzer.md:glab:audit`, `plugins/glab/agents/committer.md:glab:security`, `plugins/glab/agents/developer.md:glab:security`, `plugins/glab/agents/developer.md:glab:comments`, `plugins/glab/agents/integrator.md:glab:security`, `plugins/glab/agents/integrator.md:glab:comments`, `plugins/glab/agents/plan-analyzer.md:glab:security`, `plugins/glab/agents/plan-analyzer.md:glab:audit`, `plugins/glab/agents/planner.md:glab:plan-first`, `plugins/glab/agents/planner.md:glab:security`, `plugins/glab/agents/reviewer.md:glab:security`, `plugins/glab/agents/reviewer.md:glab:comments`, `plugins/glab/agents/reviewer.md:glab:audit`. A line ends `MISSING` when its entry names no `skills/<name>/SKILL.md` in that plugin or carries another plugin's prefix. `plugin validate --strict` passes an agent's `skills:` entry that names no skill and `plugin details` does not show the lists, so nothing else catches a typo;
~~~

Post: the R2a line run on the finished tree prints the fourteen R2b lines in that order and no `MISSING`; `/usr/bin/grep -c -F "print FILENAME" AGENTS.md` prints `1`. The gate's discrimination was shown on a throwaway copy (F14): a made-up skill name and a foreign prefix each printed `MISSING`.
