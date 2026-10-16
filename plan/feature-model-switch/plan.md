tier: normal — prose-only change to one plugin's skill and three commands, no stored or wire format, no permissions, no secrets

# Plan — feature-model-switch

**Goal.** The user can tell the manager which cheaper model the `glab:developer` or the `glab:reviewer` runs on, to stretch a Max subscription over large work. Never automatic: no instruction from the user, no override.

Written against HEAD `9700bcb` on `main`, tree clean. Every `file:line` below is a line of that commit.

## Findings

### Proven

| # | fact | how |
|---|---|---|
| F1 | A subagent definition takes an optional frontmatter `model`: `sonnet`, `opus`, `haiku`, `fable`, a full model ID, or `inherit`; omitted, the subagent model order decides. | https://code.claude.com/docs/en/sub-agents.md fetched with `curl -sSL` on 2026-10-16 (1447 lines), line 310. |
| F2 | "When Claude invokes a subagent, it can also pass a `model` parameter for that specific invocation." Order: 1. per-invocation `model` parameter, 2. frontmatter `model`, 3. `CLAUDE_CODE_SUBAGENT_MODEL`, 4. the main conversation's model. | same file, lines 363–368. |
| F3 | The per-invocation `model` also holds when the subagent is resumed or sent a follow-up message. | same file, line 392. |
| F4 | What can override the parameter: a mod's `agent.spawn` model (line 370); the organization's `availableModels` allowlist, which substitutes and warns in interactive sessions (lines 383–388); `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, under which "Claude can't pass a model when it starts a subagent" (line 416). `/tasks` names the model a running subagent is on (line 390). | same file. |
| F5 | A family alias that names the main conversation's own family resolves to the main conversation's exact model (lines 372–374). Asking for `opus` under an Opus manager changes nothing; asking for a cheaper family does. | same file. |
| F6 | Plugin subagents ignore `hooks`, `mcpServers` and `permissionMode`; `model` is not in that list. | same file, line 239. |
| F16 | Version floors: `CLAUDE_CODE_SUBAGENT_MODEL` overrode the parameter before v2.1.251 (line 381); `/tasks` names the model from v2.1.242 (line 390); resume keeps the parameter from v2.1.211 (line 392). | sub-agents.md re-fetched at Stage 1b, `sed -n '381p;390p;392p'`. |
| F7 | A session's own model is set with `/model <alias|name>` or `claude --model <alias|name>`. Fable can bill to usage credits on some plans. | https://code.claude.com/docs/en/model-config.md, lines 120–121 and 95. |
| F8 | Neither `glab:developer` nor `glab:reviewer` sets `model`; no glab agent does. Every agent's frontmatter keys are `name: description: tools:`. | `sed -n '2,/^---$/p'` over `plugins/glab/agents/*.md`; `/usr/bin/grep -l '^model:' plugins/glab/agents/*.md` → no output, `rc=1`. |
| F9 | Nothing in `plugins/glab`, `README.md` or `AGENTS.md` mentions a model choice today. | `/usr/bin/grep -rniw 'model\|sonnet\|haiku\|opus\|fable'` → only "operating model" in `manager-bootstrap.sh:17`, `bootstrap/SKILL.md:3,44`, `manager/SKILL.md:3`. |
| F10 | Dispatch points of the two roles — the full list. `commands/develop.md:35-43` (*Dispatch*, `glab:developer`); `commands/review.md:8` (`glab:reviewer`); `commands/ship.md:16` (`glab:reviewer`; rounds at `:30-32` re-run step 1); `skills/manager/SKILL.md:290-300` (Stage 2), `:347-351` (Stage 5), `:168-170` (review fan-out by dimension) and `:193-202` (*When subagent dispatch is not available*, one session per stage) — the last two added at Stage 1b; the handoff-line format at `manager/SKILL.md:135`. Every other hit is a hand-off pointer, not a dispatch: `commands/plan.md:16`, `analyze.md:10`, `integrate.md:10,16,17`, `agents/analyzer.md:3,69`, `agents/integrator.md:3`, `manager/SKILL.md:128,131,176,212,241`, `README.md:9`. | `/usr/bin/grep -rnE 'glab:developer\|glab:reviewer\|developer agent\|reviewer agent\|/glab:develop\|/glab:review\|/glab:ship' plugins/glab README.md AGENTS.md` (GNU grep 3.12; `type grep` shows the shell `grep` is the ugrep function). Known positive: `/usr/bin/grep -c 'glab:developer' plugins/glab/commands/develop.md` → `3`. |
| F11 | `docs/constants.md` does not exist in this repo. | `ls docs` → `No such file or directory`. |
| F12 | `plugins/glab/.claude-plugin/plugin.json:3` is `"version": "0.2.1"`; `memory-sync` is `0.1.0` and is not touched. | `/usr/bin/grep -rn '"version"' --include='*.json'`. |
| F13 | "Rule 5" is free in `glab:manager` (Rules 0, 0b, 0c, 1–4). The only other "Rule 5" in the plugin is `glab:security` *Rule 5* (`security/SKILL.md:53`), so the commands cite it as `` `glab:manager` Rule 5 ``. | `/usr/bin/grep -rnF 'Rule 5' plugins/glab AGENTS.md` → `security/SKILL.md:53` only. |
| F14 | Each of the eleven *before* texts below occurs exactly once, at the cited line, and the edits apply cleanly. With them applied, the gates stay green: three `✔ Validation passed`, `Skills (14)`, `Agents (5)`, `Hooks (1)  SessionStart`, no prefixed `name:`. | Stage 1b re-run: a script parsed the eleven E-blocks out of this file (`edits found: 11 E1 … E11`) and applied them to a fresh `git archive HEAD` copy under `/data/tmp/claude`, bottom-up within each file. It checked that each *before* occurs once and starts at the line cited. Every edit printed `before-count=1` with `starts-at-line` equal to `cited`, then `apply rc=0`. The whole *Gates* block of `AGENTS.md` on that copy printed exactly F15. |
| F15 | The baseline gates are green at HEAD: three `rc=0`; shellcheck `rc=0`; `PASS 35/35`; three `✔ Validation passed`; glab `Skills (14)`, `Agents (5)`, `Hooks (1)  SessionStart`; memory-sync `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`; `glab = glab`, `memory-sync = memory-sync`; `:0`,`:0`,`rc=1`; `1`,`1`,`1`,`rc=0`; nothing, then `rc=1`. | The *Gates* block of `AGENTS.md`, run at HEAD by the planner. |

### Inferred

- I1. The Agent tool takes `model` with the values `sonnet`, `opus`, `haiku`, `fable`, and documents it as taking precedence over the definition's frontmatter. This was read from the Agent tool definition given to the planning session; no command prints it. `UNVERIFIED: the manager's host shows the same values — the tool definition depends on the Claude Code version and host`. Rule 5 therefore says what to do when a named model is not one the parameter takes.
- I2. The instruction must be kept in a file to survive a compaction. A compaction summary may carry it, but nothing guarantees that.
- I4. Plugin agents honour the per-dispatch `model`. Inferred from line 239, which lists the fields a plugin agent ignores and leaves `model` out. `UNVERIFIED: a plugin agent dispatched with model haiku runs on haiku — needs a live dispatch`. Rule 5 says this in its own text.
- I3. `glab:developer` and `glab:reviewer` cannot change their own model, so a note in their files tells them nothing they can act on.

## Decisions

- D1 (user) — **Manual only.** The model changes only when the user names it, for one dispatch, a task or the session. The manager never lowers or raises it on its own, and never because of quota. No file switches it, `docs/constants.md` included.
- D2 (user) — **Developer and reviewer only.** Analyzer, integrator, committer and planning agents get no `model` parameter.
- D3 (user) — **The user does not run commands or skills.** "I will tell the agent" means the user tells the manager in conversation, and the manager carries the choice into every dispatch of that role through whichever command or stage it runs, until the user changes or clears it. So the rule lives where the manager reads it, not in a command argument.
- D4 (user) — **The handoff line names the model**, so the user sees what was asked for.
- D5 (user) — **The pipeline does not bend.** The manager still runs the gates, the reviewer still gets only the target, push still waits for the user. A cheaper reviewer changes neither the tier nor the round caps.
- D6 — **The mechanism is the Agent tool's per-invocation `model` parameter** (F2), passed on each dispatch. It is the top of the documented order, it applies to one dispatch only, and it holds across a resume (F3).
- D7 — **One home for the rule: a new `glab:manager` Rule 5.** Stage 2, Stage 5, the handoff-line format and the three commands point to it, each in one sentence. The commands restate the minimum a reader needs on the spot ("pass it; named none → pass none; never choose one yourself"), because `/glab:review` and `/glab:ship` also run outside the pipeline.
- D8 — **No change to the agent files** (I3). Their frontmatter keeps no `model`, so with no instruction the documented default applies, unchanged for every installed copy.
- D9 — **Where the choice is recorded:** a `- model: …` line under `## Decisions` in the task's `plan.md`. That is the file a later stage, a compaction or a stage session already reads, and Rule 1 already lets the manager write decision lines there. A review or ship with no plan keeps the choice in conversation only. When it is lost, the fallback is the default model, which costs more but loses nothing, and the handoff line shows `model default` so the user can say it again.
- D10 — **Unspecified duration = the task in progress** (the session when there is no task). The narrower of the two: a lost choice falls back to the default, never to a cheaper model nobody asked for. The manager writes which one it took in the recorded line.
- D11 — **The handoff line always names the model on develop and review lines**, `model default` included. Shown only when set, a lost choice would be invisible.
- D12 — **Rule 5 names its limits** (F4): the line states what was passed. A forced subagent model, an allowlist or a mod can run something else, and `/tasks` shows what actually runs.
- D13 — **Without subagent dispatch** (one session per stage), the stage session's model is the one the user starts it with (F7). The manager names the recorded model in the line that hands off to it.
- D14 — **`AGENTS.md` gains a known case** under *One fact, one value*, because the rule is now stated in four payload files.
- D15 — **Version `0.2.1` → `0.3.0`** in `plugins/glab/.claude-plugin/plugin.json`. A minor bump, because what the manager does changes. A sibling plan (an OpenCode worker) may bump too: **whichever of the two lands second takes `0.4.0`**, and its *before* texts are re-checked first, since both may touch `develop.md` and `manager/SKILL.md`.
- D16 — **No change to `glab:bootstrap` or `manager-bootstrap.sh`.** Rule 5 itself says to re-read the recorded line after a compaction, and `glab:bootstrap` loads `glab:manager`. This leaves the session-start-rules pair in `AGENTS.md` untouched.
- D17 — **Rule 5 states the version floors (F16) and the I4 inference itself**, so a manager on an older Claude Code knows a resume can drop the model, and nobody reads the rule as proven.
- D18 — **Naming `fable` is a money choice the user makes** (F7). The manager says once that it can bill to usage credits, then uses it. It is not a Rule 3 question, because the user made the choice.
- D19 — **Stage 1b amendment (the one pass normal tier allows).** Version floors, the inference and the `fable` clause were added to E1. E1 no longer says "or at the start of a stage session", because the D13 bullet covers that case. In E3, "not in the message text" became "passed with the dispatch", which no longer contradicts the list's "in the dispatch message:" opener. E10 and E11 are new: the review fan-out and the one-session-per-stage section now point to Rule 5. There are new Rule 5 post-conditions, and the back-out is now spelled out step by step.
- D20 (user) — **The dispatch fits the model.** Each model has its own way of reading instructions, so Rule 5 carries a three-row table — `opus`/default/`fable`, `sonnet`, `haiku` — of what changes in the dispatch message. Nothing changes in the agent files (D8 holds).
- D21 — **The report template comes from the agent's own *Report* section, copied as written.** One source, so the template cannot drift into a second copy. Reading that one section is named in Rule 5 as an exception to Rule 2, because Rule 2 otherwise forbids reading what an agent will read.
- D22 (user) — **A malformed report is not evidence.** The manager checks every report for its required fields and a verdict line in the agent file's form, re-dispatches once on the same model with the gaps named, then stops and tells the user. Rule 5 does not list the verdicts again; it points to the agent files, so the verdict set stays stated where it already is. This applies whatever the model, because a report with a missing field is never evidence. The re-dispatch is not a review round.

### Rejected

- `model: sonnet` in the agent frontmatter: a static switch, contrary to D1, and it would change every installed copy's default.
- A command argument (`/glab:develop <slug> sonnet`): the user does not type commands (D3).
- `CLAUDE_CODE_SUBAGENT_MODEL` in a settings file: a file-based switch (D1). It also reaches every subagent (D2), and it ranks below frontmatter and the parameter (F2).
- Extra agents (`developer-sonnet`): the manager would pick by name, the component counts in the gates and `README.md` would change, and every rule would be stated twice.
- A memory file: it outlives the session, so a "for the session" choice would quietly carry into later sessions, and memory-sync uploads it.

## Before

1. `git status --short` empty, HEAD contains `9700bcb`. If the sibling OpenCode plan has landed, check every *before* text first: `/usr/bin/grep -c -F '<before>' <file>` must print `1`. Re-anchor by text and use `0.4.0` in E9.
2. The *Gates* block of `AGENTS.md` is green as in F15, with `export TMPDIR=/data/tmp/claude` first.

## Processing

One developer, one slice: the steps share `manager/SKILL.md`. Line numbers are HEAD's. Apply each file's edits bottom-up (E4, E3, E11, E10, E2, E1), or match by the *before* text, which is unique (F14). Replace the *before* text with the *after* text exactly. Text outside the blocks does not change.

- **S1 — `glab:manager` Rule 5, pointers, handoff format:** E1, E2, E3, E4, E10, E11.
- **S2 — commands:** E5 (`develop.md`), E6 (`review.md`), E7 (`ship.md`).
- **S3 — working agreement:** E8 (`AGENTS.md`).
- **S4 — version:** E9.

### Edits

**E1** — `plugins/glab/skills/manager/SKILL.md:116`

Before:

````text
## Know the gates before you dispatch
````

After:

````text
## Rule 5 — the model a developer or reviewer runs on is the user's call

The user may tell you which model the `glab:developer` or the `glab:reviewer` runs on — "use sonnet for the developer", "reviewer on haiku for this task". That instruction is the only thing that changes it. It exists so that large work can be stretched over a limited plan, and only the user decides when that trade is worth making.

- **No instruction, no override.** Dispatch with no `model` parameter, and the agent runs on its default: neither agent definition sets a `model`, so Claude Code's own order picks it. Never choose a cheaper or a dearer model yourself — not because a usage limit is near, not because the work looks easy, not because a round failed. No file switches it either, `docs/constants.md` included.
- **Carry it into every dispatch of that role.** Pass the named model as the Agent tool's `model` parameter — `sonnet`, `opus`, `haiku` or `fable` — on each split slice, each re-dispatch after `BLOCKED` or `PLAN WRONG`, and each review round, whether the dispatch runs through `/glab:develop`, `/glab:review`, `/glab:ship` or directly. A name the parameter does not take: say so, and ask which of the four the user means. `fable` can bill to usage credits rather than the plan's included limits, so naming it spends money: when the user names it, say that once, then use it — the user makes that choice knowingly.
- **What the documentation promises, and from which version.** The parameter outranks the agent definition. It outranks `CLAUDE_CODE_SUBAGENT_MODEL` only from Claude Code v2.1.251, and it still holds when the agent is resumed or sent a follow-up only from v2.1.211 — before that, a resumed agent falls back to its default. That a plugin agent such as these two honours the parameter at all is inferred, not shown: the documentation lists the fields a plugin agent ignores and `model` is not one of them, but no live dispatch has confirmed it.
- **These two roles only.** `glab:analyzer`, `glab:integrator`, `glab:committer` and planning agents are dispatched with no `model` parameter, whatever the user said about the developer or the reviewer.
- **It lasts as long as the user says**, until the user changes or clears it. "For this task" ends with that task's push; "for the session" holds across tasks. Said neither way, take it for the task in progress — for the session when there is none — and write which in the line that records it.
- **Record it before the next dispatch**, where a reader after a compaction or in a new session will look: one line under `## Decisions` in `plan/{slug}/plan.md`, such as `- model: glab:developer sonnet, for this task — the user's instruction, not a manager choice`. A session-wide instruction gets that line in the plan of every task it covers. After a compaction, read that line before dispatching either role. A `/glab:review` or `/glab:ship` with no plan behind it has nowhere to record it: the instruction lives in this conversation only, and once you can no longer find it, dispatch with no `model` parameter — never reconstruct it from memory. The handoff line then says `model default`, and the user can restate it.
- **Name it in the handoff line.** A develop or review line carries the model after the stage — `slug · develop · model sonnet · round 1/1 · BUILT` — or `model default` when the user named none. It names what you passed. Claude Code can run something else: `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, an organization's `availableModels` list or a mod can override the parameter, and it warns when it substitutes. `/tasks` shows the model a running subagent is on, from v2.1.242.
- **The pipeline does not bend to the model.** You still run the gates yourself, the reviewer still gets the target and nothing else, the push still waits for the user, and the tier and the round caps stay what *Pick the tier* gives them. A cheaper reviewer's `SHIP` is a `SHIP`, and it earns no extra round.
- **Without subagent dispatch**, a develop or review session runs on the model the user starts it with — `claude --model <alias>` or `/model <alias>`. When you hand off to one, name the recorded model so the user starts it on that one.

**Write the dispatch for the model it goes to.** Each model reads instructions in its own way. When the user has named a cheaper model for a role, write that dispatch for it. The agent's file stays as it is; only your dispatch message changes:

| model | what changes in the dispatch |
|---|---|
| `opus`, default, `fable` | nothing — write it as Rule 0c and the stage say |
| `sonnet` | as for `opus`, plus the role's report template pasted in full, to be filled in |
| `haiku` | shorter; every instruction explicit, none left to inference; the work as numbered steps; the role's report template pasted in full, to be filled in |

The report template is the *Report* section of the agent's own file, copied as written and never paraphrased. Reading that one section is the exception to Rule 2 this needs.

**Check what comes back against the role's contract**, whatever the model: every field the role's report requires is present, and the verdict line has the form the agent's file gives it. A report that misses either is not evidence. Re-dispatch once, on the same model, naming exactly what was missing. If the second report is malformed too, stop and tell the user what is missing — never switch the model yourself. The re-dispatch is not a review round and does not count against the cap.

## Know the gates before you dispatch
````

**E2** — `plugins/glab/skills/manager/SKILL.md:135`

Before:

````text
Announce each handoff in one line: `slug · stage · round n/max · verdict`.
````

After:

````text
Announce each handoff in one line: `slug · stage · round n/max · verdict`, with `model <m>` after the stage on a develop or review line (Rule 5).
````

**E3** — `plugins/glab/skills/manager/SKILL.md:298`

Before:

````text
- **your own suggestions**, marked as suggestions, so they are not mistaken for plan steps.
````

After:

````text
- **your own suggestions**, marked as suggestions, so they are not mistaken for plan steps;
- **the model, only when the user named one for the developer** — passed with the dispatch as the Agent tool's `model` parameter (Rule 5). None named, none passed.
````

**E4** — `plugins/glab/skills/manager/SKILL.md:351`

Before:

````text
Do not defend the plan to it and do not re-rank its severities.
````

After:

````text
Do not defend the plan to it and do not re-rank its severities.

Dispatch it on the model Rule 5 gives the reviewer: the one the user named, as the Agent tool's `model` parameter, or none. A cheaper reviewer does not change this stage's round cap or what its verdict means.
````

**E5** — `plugins/glab/commands/develop.md:41`

Before:

````text
- anything decided in this conversation that is not written in the plan — an answer I gave you, a constraint I added. The agent cannot see this conversation and will build the plan as written unless you tell it otherwise.
````

After:

````text
- anything decided in this conversation that is not written in the plan — an answer I gave you, a constraint I added. The agent cannot see this conversation and will build the plan as written unless you tell it otherwise;
- the model, only when I named one for the developer: pass it as the Agent tool's `model` parameter on every `glab:developer` dispatch, slices and re-dispatches alike. I named none → pass none. Never choose one yourself (`glab:manager` Rule 5).
````

**E6** — `plugins/glab/commands/review.md:8`

Before:

````text
Then use the **glab:reviewer** agent. Target: $ARGUMENTS — if that is empty, the uncommitted working tree.
````

After:

````text
Then use the **glab:reviewer** agent. Target: $ARGUMENTS — if that is empty, the uncommitted working tree. If I named a model for the reviewer, pass it as the Agent tool's `model` parameter; if I named none, pass none, and never choose one yourself (`glab:manager` Rule 5).
````

**E7** — `plugins/glab/commands/ship.md:16`

Before:

````text
The agent owns that procedure; do not restate it here.
````

After:

````text
The agent owns that procedure; do not restate it here. If I named a model for the reviewer, pass it as the Agent tool's `model` parameter in every round; if I named none, pass none, and never choose one yourself (`glab:manager` Rule 5).
````

**E8** — `AGENTS.md:128`

Before:

````text
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key in the plugin's settings
  example).
````

After:

````text
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key in the plugin's settings
  example); the manual model rule — the developer and reviewer only, and no
  `model` parameter without the user's instruction (`glab:manager` Rule 5 and
  its handoff-line format in `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/commands/develop.md`, `plugins/glab/commands/review.md`,
  `plugins/glab/commands/ship.md`).
````

**E9** — `plugins/glab/.claude-plugin/plugin.json:3`

Before:

````text
  "version": "0.2.1",
````

After:

````text
  "version": "0.3.0",
````

**E10** — `plugins/glab/skills/manager/SKILL.md:169`

Before:

````text
  handling, test quality, `AGENTS.md` conformance. They are deduplicated by you,
  not by them.
````

After:

````text
  handling, test quality, `AGENTS.md` conformance. They are deduplicated by you,
  not by them. Each one is a `glab:reviewer` dispatch, on the model Rule 5 gives
  that role.
````

**E11** — `plugins/glab/skills/manager/SKILL.md:199`

Before:

````text
- The round caps still apply and are counted by the file record, not by memory: a second review session is `review2`, and there is no `review4`.
````

After:

````text
- The round caps still apply and are counted by the file record, not by memory: a second review session is `review2`, and there is no `review4`.
- A develop or review session runs on the model the user starts it with; Rule 5 says how you name the recorded one when you hand off to it.
````

## After

### Post-conditions — run from the repo root

````bash
sec() { awk -v h="$1" 'index($0,h)==1{on=1;next} on&&/^## /{on=0} on' plugins/glab/skills/manager/SKILL.md; }
for f in plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md; do echo "$f $(/usr/bin/grep -c -F '`glab:manager` Rule 5' "$f")"; done
for h in '## Rule 5 ' '## Stage 2 ' '## Stage 5 '; do echo "manager '$h' $(sec "$h" | /usr/bin/grep -c -F '`model` parameter')"; done
for h in '## Running agents in parallel' '## When subagent dispatch is not available'; do echo "manager '$h' $(sec "$h" | /usr/bin/grep -c -F 'Rule 5')"; done
for s in 'model default' 'does not bend' 'Without subagent dispatch' 'v2.1.251' 'v2.1.211' 'v2.1.242' 'usage credits'; do echo "rule5 '$s' $(sec '## Rule 5 ' | /usr/bin/grep -c -F "$s")"; done
for s in '| `opus`, default, `fable` |' '| `sonnet` |' '| `haiku` |' 'is not evidence'; do echo "rule5 '$s' $(sec '## Rule 5 ' | /usr/bin/grep -c -F -- "$s")"; done
echo "rule5 stage-session-phrase $(sec '## Rule 5 ' | /usr/bin/grep -c -F 'or at the start of a stage session')"
echo "stage2 message-text-phrase $(sec '## Stage 2 ' | /usr/bin/grep -c -F 'not in the message text')"
echo "handoff-format $(/usr/bin/grep -c -F 'with `model <m>` after the stage on a develop or review line (Rule 5)' plugins/glab/skills/manager/SKILL.md)"
echo "version $(jq -r .version plugins/glab/.claude-plugin/plugin.json)"
echo "agents-known-case $(/usr/bin/grep -c -F 'the manual model rule' AGENTS.md)"
/usr/bin/grep -rlF '`glab:manager` Rule 5' plugins | sort; echo "list rc=$?"
/usr/bin/grep -l '^model:' plugins/glab/agents/*.md; echo "frontmatter-model rc=$?"
/usr/bin/grep -c -F '`model` parameter' plugins/glab/agents/*.md plugins/glab/commands/analyze.md plugins/glab/commands/integrate.md plugins/glab/commands/commit.md plugins/glab/commands/push.md plugins/glab/commands/plan.md; echo "others rc=$?"
````

A finished tree prints exactly what follows. The planner ran these lines at Stage 1b on a fresh `git archive HEAD` copy, with E1–E11 parsed out of this file and applied (F14). At HEAD every count is `0`, the version is `0.2.1` and the file list is empty.

````text
plugins/glab/commands/develop.md 1
plugins/glab/commands/review.md 1
plugins/glab/commands/ship.md 1
manager '## Rule 5 ' 4
manager '## Stage 2 ' 1
manager '## Stage 5 ' 1
manager '## Running agents in parallel' 1
manager '## When subagent dispatch is not available' 1
rule5 'model default' 2
rule5 'does not bend' 1
rule5 'Without subagent dispatch' 1
rule5 'v2.1.251' 1
rule5 'v2.1.211' 1
rule5 'v2.1.242' 1
rule5 'usage credits' 1
rule5 '| `opus`, default, `fable` |' 1
rule5 '| `sonnet` |' 1
rule5 '| `haiku` |' 1
rule5 'is not evidence' 1
rule5 stage-session-phrase 0
stage2 message-text-phrase 0
handoff-format 1
version 0.3.0
agents-known-case 1
plugins/glab/commands/develop.md
plugins/glab/commands/review.md
plugins/glab/commands/ship.md
list rc=0
frontmatter-model rc=1
plugins/glab/agents/analyzer.md:0
plugins/glab/agents/committer.md:0
plugins/glab/agents/developer.md:0
plugins/glab/agents/integrator.md:0
plugins/glab/agents/reviewer.md:0
plugins/glab/commands/analyze.md:0
plugins/glab/commands/integrate.md:0
plugins/glab/commands/commit.md:0
plugins/glab/commands/push.md:0
plugins/glab/commands/plan.md:0
others rc=1
````

Which lines discriminate and which do not:

- **Discriminating** — the three command lines, the five `manager '…'` lines, every `rule5 '…'` line (the three table rows included), `handoff-format`, `version` and `agents-known-case`. Each step changes at least one of them from its HEAD value. The `rule5` lines fail a Rule 5 that is only partly built. `version` prints `0.4.0` if the sibling plan landed first (D15).
- **The three-file list** discriminates by its content. Its `list rc=$?` is `sort`'s exit status and is `0` on any tree, so it proves nothing.
- **Guards that cannot discriminate** — `rule5 stage-session-phrase`, `stage2 message-text-phrase`, `frontmatter-model` and `others` print the same at HEAD and when finished. The first two catch the text the Stage 1b amendment removed, if a pre-amendment copy of E1 or E3 is used. The last two only prove that D2 and D8 were not broken.

### Gates

The whole *Gates* block of `AGENTS.md`, both halves, with `export TMPDIR=/data/tmp/claude`. Green is exactly F15. No component count changes: still `Skills (14)` and `Agents (5)`.

### Milestone

The gates are green, and the post-conditions print the block above: every dispatch point of the developer and the reviewer (`develop.md`, `review.md`, `ship.md`, manager Stage 2, Stage 5, the review fan-out and the one-session-per-stage section) names the manual model rule, and Rule 5 holds it. Stage 4 (integrate) is skipped. The change is prose and its runtime effect is a parameter Claude Code documents (F2). `UNVERIFIED: a live dispatch with model haiku runs on haiku — that takes a logged-in session and spends the user's quota, which no agent here may do; the user can confirm it once with /tasks (F4)`.

### Tests

No shell script changes, so `tests/memory-sync.test.sh` gains no case. Its `PASS 35/35` is only a regression guard.

### Spec entry

The manager runs `glab:developer` or `glab:reviewer` on a model only when the user names one, passes it per dispatch as the Agent tool's `model` parameter, records it in the plan's `## Decisions`, and names it in each handoff line. It writes the dispatch for that model (Rule 5's table) and accepts no malformed report as evidence. Why: to stretch a limited plan over large work. Open: I1, and the live check above.

### Commit

One commit, `feat(skills): let the user choose the developer and reviewer model`, holding E1–E11. `AGENTS.md` goes in it under *One fact, one value*, and the version bump under the version rule. This plan file goes in a separate `docs(repo)` commit.

### Back-out

Before the commit: `git restore plugins/glab/skills/manager/SKILL.md plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/.claude-plugin/plugin.json AGENTS.md`. After it: `git revert --no-commit <hash>`, set `"version"` in `plugins/glab/.claude-plugin/plugin.json` to `0.3.1`, `git add plugins/glab/.claude-plugin/plugin.json`, then `git commit`, so the revert ships as `0.3.1` rather than the reverted `0.2.1`. The revert is itself a change under `plugins/glab/`, and the `AGENTS.md` version rule requires a new version string for it. `UNVERIFIED: that an installed 0.3.0 copy ignores a move back to 0.2.1 — inferred from the AGENTS.md note that an installed copy is pinned to the version string; not tested`. No data or state is involved: with no instruction from the user, the manager already dispatches exactly as it does today.
