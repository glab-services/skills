# flow-commands-to-skills — steps for `glab:manager`, `glab:bootstrap` and the session-start hook

Part of `plan.md` *processing*, run after P4. File boundary: `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/scripts/manager-bootstrap.sh`. Quotes are as of `5a72155` (line numbers for orientation only); "replace A with B" as in `steps-agents.md`. A block in `~~~ <id>` fences is inserted byte for byte, as in `steps-stages.md`. Recorded cases stay word for word wherever they move. Ids with no step here (M4, M10, M16, M22, BS5) are sections that stay as they are.

## glab:manager — `plugins/glab/skills/manager/SKILL.md`

- **M1 (A10, A11).** Replace the body of *Rule 0* (`:12-18`, from "*(The `glab:bootstrap` skill runs" to "you pay for that in a correction round.") with:

~~~ M1
The session-start text of the `glab` hook and `glab:bootstrap` step 1 say what this session reads first, and what to do when there is no `AGENTS.md`. This rule is that step, named here because it is the one that cannot be skipped. Each `glab` agent reads `AGENTS.md` in its own first step, and `glab:planner` reads `docs/constants.md` too; a dispatch repeats neither (Rule 0c).
~~~

- **M2 (A11, C13, C14).** Replace the body of *Rule 0b* (`:22-28`) with:

~~~ M2
It is loaded with this skill and it is not optional: every claim you or an agent makes about the work is held to it, and its durability rules bind every stage. **No stage is reported green on an agent's word** — you run the gate; what you report is what it printed.
~~~

- **M3 (A1, A8, A10, A16, A26, B10, C2, C13; decisions FU1-2, FU1-3).** Replace the whole of *Rule 0c* — its heading and `:32-63` — with:

~~~ M3
## Rule 0c — what reaches an agent, and once

Each rule reaches an agent through one channel, never two:

- **The agent's own file** holds every rule only its role acts on.
- **A shared rule lives once, in its skill** — `glab:security`, `glab:comments`, `glab:audit`, and `glab:plan-first` for the planner. Each `glab` agent's frontmatter `skills:` list preloads the ones its role uses. An agent with no definition — a mapping agent, a read-only question, any ad-hoc agent — has no such list: its dispatch names `glab:security`, and `glab:audit` when it produces findings, and that is its one channel.
- **The dispatch carries only the facts of its task:** the slug and the step ids; the file boundary when the work is split; the paths *The master plan and sub-plans* names; the answers and decisions not written in the plan; the round, and what that round is given (Stages 1b, 2, 3, 5, 6b and 8); the temp directory (`glab:bootstrap` step 6); and the `effort` and `model` parameters (Rules 0d and 5). Never a standing rule — not "read `AGENTS.md`", not a skill the agent preloads, not a rule its own file holds. A rule repeated in a dispatch is a second copy the agent has to reconcile with the first.
~~~

  Post M1–M3: `/usr/bin/grep -c -E 'Mind the seam|even when the agent definition already requires it|An agent definition that already requires one|Your call, per dispatch|Every dispatch message says the agent carries it' plugins/glab/skills/manager/SKILL.md` prints `0`; `/usr/bin/grep -c '^## Rule 0c — what reaches an agent, and once$' …` prints `1`.

- **M5 (A11, C14).** In *Rule 1*, at the end of the *Trivial changes* bullet (`:81`), add: "`glab:security` has no such exemption: a five-line change still gets its claim verified."
- **M6 (B4, decision FU1-3).** In *Rule 2*, replace "- **Every agent writes long output to disk and returns a short report.** The developer writes `plan/{slug}/result.md`, except for the record (Stage 8); the reviewer and analyzer return their verdict block. Say this in the dispatch message." with "- **Every agent writes long output to disk and returns a short report**, as its own file's *Report* says."
- **M7 (A17, A30, B23).** In *Rule 5*:
  - replace the bullet "- **What the documentation promises, and from which version.** …live dispatch." (`:154`) with "- **Precedence.** The parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main conversation's model; only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` overrides the definitions and the parameter alike. From which Claude Code version each of these holds, and what is not yet shown by a live dispatch, is in the `glab` repository's `docs/specs/workflow.md` *Known limits and not verified*.";
  - in the bullet "- **Name it in the handoff line.**" (`:157`) delete "; under `availableModels` it warns when it substitutes, in interactive sessions" and the last sentence "`/tasks` shows the model a running subagent is on, from v2.1.242.";
  - in "- **The pipeline does not bend to the model.**" (`:158`) replace "the reviewer still gets the target and nothing else" with "the reviewer still gets only what Stage 5 gives it";
  - replace everything from "**Write the dispatch for the model it goes to.**" (`:161`) up to the line before "**Check what comes back against the role's contract**" (`:174`) — the table and the two paragraphs after it — with:

~~~ M7
**Write the dispatch for the model it goes to.** For `opus`, `fable`, `sonnet` and an agent with no definition, write it as Rule 0c and the stage say. For `haiku`, shorter: every instruction explicit, none left to inference, the work as numbered steps that are references, never content — for the committer, `1 commit the paths <list>; 2 report as your file says`. The steps point at what the agent reads; they never carry it, and you do not read the plan to write them (Rule 2). The agent's own *Report* section is its template; it is not pasted into the dispatch.
~~~

  - in *Check what comes back*, replace "Resume the same agent once — the model holds on a resume from the version named above — and ask only for the missing fields." with "Resume the same agent once — the model holds on a resume (see *Precedence*) — and ask only for the missing fields."
  - **Moved text, for the record (Stage 8 carries it into `docs/specs/workflow.md`):** the removed `:154` bullet read, verbatim: "**What the documentation promises, and from which version.** The parameter outranks the definition's `model`, which outranks `CLAUDE_CODE_SUBAGENT_MODEL`, which outranks the main conversation's model — in that order from Claude Code v2.1.251; before it the variable came first. So `CLAUDE_CODE_SUBAGENT_MODEL` no longer reaches the seven `glab` agents: their definitions set a model. Only `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, from v2.1.257, overrides the definitions and the parameter alike. A family alias runs the main conversation's exact model when that model is of the same family. The parameter still holds when the agent is resumed or sent a follow-up only from v2.1.211 — before that, a resumed agent falls back to its definition's model. That a plugin agent's frontmatter `model` and the parameter are honoured is documented — `model` is among the fields a plugin agent supports — and not yet shown by a live dispatch." The removed `:157` text read: "under `availableModels` it warns when it substitutes, in interactive sessions" and "`/tasks` shows the model a running subagent is on, from v2.1.242."
  Post M5–M7: `/usr/bin/grep -c -E 'v2\.1\.(251|257|211|242)|report template pasted|copied as written and never paraphrased|Say this in the dispatch' plugins/glab/skills/manager/SKILL.md` prints `0`; `/usr/bin/grep -c '^- \*\*Precedence\.\*\*' …` prints `1`.
- **M8 (C15, A9).** Replace the body of *Know the gates before you dispatch* (`:178-180`) with "Every stage below ends on the repo's own build, test and lint targets, found once at session start and written down in one line (`glab:bootstrap` step 3). Reuse that line all session."
- **M9 (A18).** In the pipeline table's Stage 1 row, replace "`evidence.md`, and `questions.md`" with "`evidence.md` at full tier, and `questions.md`".
- **M11 (A27).** In *The master plan and sub-plans*, replace the sentences from "No round amends a `master.md` that has an `## Approval` line." through "Remove `master.sha256` when you dispatch that agent, so the plan check does not test the new master against the old hash." with "When the user changes the request, remove `master.sha256` — so the plan check does not test the new master against the old hash — and dispatch a planning agent, granted the new master, to write it as `glab:plan-first` Step 4 says; the new master goes through its own plan check (Stage 1b), then a new approval and a new hash."
  Post: `/usr/bin/grep -c 'a version copy, never' plugins/glab/skills/manager/SKILL.md` prints `0`; in `plugins/glab/skills/plan-first/SKILL.md` it prints `1`.
- **M12 (A25, A3, B24).** In *Running agents in parallel*, replace the *Fan out with care* block (`:253-261`, from "**Fan out with care.** Develop writes:" to "Run it as one agent.") with:

~~~ M12
**Fan out with care.** Develop writes. One agent is the default: the steps of most plans build on each other — a later step importing a type an earlier one defines, a deletion waiting on its replacement to pass.

- Split `/glab:develop` **only** when the slices touch no common file — not the same test file, barrel export or config — **and** have no ordering dependency: neither needs the other's output to compile or to pass its own tests. Two agents editing one file in one working tree clobber each other, and there is no merge step to save you. A wrong split costs a red tree and two reports that each blame the other.
- Which step ids touch which files is the input to that decision: ask a read-only agent (Rule 2); never read the plan yourself to find out.
- Give each agent its explicit file boundary — the paths it owns and the paths it must not touch — and its step ids, and dispatch them in one message. If you cannot state the boundary in one sentence, the work is not splittable: run it as one agent.
- Sequential agents — one per group of steps, each dispatched once the one before returned `BUILT` and your gate run was green — suit a long plan whose steps depend on each other.
~~~

- **M13 (A5, A26, C1).** In *Stage 1*: in *Explore once* replace "proven kept apart from inferred" with "proven kept apart from inferred (`glab:security` Rule 6)"; replace the paragraph "**The planning agent, `glab:planner`, brings you what it could not settle.** … that one you do not answer on their behalf." with "**The planning agent, `glab:planner`, brings you what it could not settle**, sorted as `glab:plan-first` Step 2 says. You review its `## Decisions` lines under Rule 3, and relay only a Rule 3 question to the user — that one you do not answer on their behalf."; replace checklist item 2 ("2. **Three phases, explicitly.** … as its milestone.") with "2. **Its shape.** Every item `glab:plan-first` Step 3 lists is there, its three phases and its milestone test included."
  Post: `/usr/bin/grep -c -E 'Three phases, explicitly|may overrule one' plugins/glab/skills/manager/SKILL.md` prints `0` (M24's new line reads "overrule one by adding").
- **M14 (A2).** In *Stage 1b*, cut `:327-332` (from "It exists because of a real case." to "already carried `[BLOCKED]`.") and `:338-373` (from "Each `glab:plan-analyzer`, for its assigned surface:" to the end of the paragraph "**Ask the intent question too** …a finding like any other.") — they go to `glab:plan-analyzer` as `steps-agents.md` PA1 says. Replace "So **before dispatching `/glab:develop`, dispatch `glab:plan-analyzer` agents against the plan itself.**" and the two lines after it ("One question: … judging the prose.") with "**Before dispatching `/glab:develop`, dispatch `glab:plan-analyzer` agents against the plan itself**, split by surface (*Running agents in parallel*). What each one checks, and the case that showed why this stage exists, is `glab:plan-analyzer` *The plan check*." In *The amendment* paragraph, delete ", and `glab:plan-first` with the seam stated" and replace "replacing the changed text in place rather than adding beside it (`glab:plan-first` Step 4)" with "as `glab:plan-first` Step 4 says".
  Post: the six PA1 strings count `0` here (PA1's post); `/usr/bin/grep -c 'seam stated' …` prints `0`; `/usr/bin/grep -c 'glab:plan-analyzer` \*The plan check\*' …` prints `1`.
- **M15 (A3, A6, A14, A25, A29, B4, B21, B26, B27, C11, C12).** Replace *Stage 2* from its first line after the heading ("Run `/glab:develop {slug}`. One agent is the default.") through the end of *Verify before moving on* (`:385-420`) with:

~~~ M15
Run `/glab:develop {slug}`. Split it as *Running agents in parallel* says.

Give each `glab:developer` dispatch (Rule 0c):

- the slug and the exact step ids it owns, its file boundary when the work is split, and with sub-plans the paths *The master plan and sub-plans* names;
- **the resolved answers** from `questions.md` and anything decided in this conversation that is not written in the plan — the agent cannot see this chat;
- **your own suggestions**, marked as suggestions, so they are not mistaken for plan steps;
- **for a fix round** — after `DIVERGES`, review findings or integration regressions: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps.

Do not paste the plan. The agent reads it; a paraphrase is how a step quietly changes meaning.

### What you require back

`plan/{slug}/result.md` and the short reply, as `glab:developer` Step 5 and *Report* have them, checked as Rule 5 says.

### Verify before moving on

An agent's report is not evidence. Run the gate line you recorded (*Know the gates before you dispatch*) yourself, in order — build, then tests, then lint — and do not run a later one while an earlier one is red; `glab:security` Rules 3 to 5 hold. Where the repo separates a changed-code gate from a whole-tree sweep, the gate is what must pass: a sweep's pre-existing backlog is a burn-down list for its own task, never pass/fail on this one.

- `PLAN WRONG` → stop the build. Amending the plan is a Rule 3 decision — yours when it is an engineering choice, the user's when it meets an ask-condition — made through a new planning agent and recorded under `## Decisions`, never made by the developer; then this stage again.
- `BLOCKED: <reason>` → decide whether it is unblockable: a missing decision is yours under Rule 3 unless it meets an ask-condition; a dependency on another slice means the split was wrong — re-dispatch rather than patch it yourself.
- `BUILT` and every gate green → the next stage: Stage 3 at full tier and for every sub-plan, Stage 4 at normal tier with no sub-plans.

If you find yourself fixing an agent's work beyond a mechanical consequence, you have taken over the implementation (Rule 1), and the split stopped meaning anything.
~~~

  Post: `/usr/bin/grep -c -E 'hand-written mocks|≥95%|Chat discipline|Never run a fix-mode linter or formatter|blast-radius block' plugins/glab/skills/manager/SKILL.md` prints `0`.
- **M17 (B8, B9, B29).** Replace the body of *Stage 4* (`:443-448`) with:

~~~ M17
Run `/glab:integrate {slug}`. The `glab:integrator` agent checks or starts the external dependencies, starts the service and runs the repo's existing integration or E2E suite — at normal tier only the milestone test, as its Step 1 says. You start no service and run no suite yourself.

- **Skip this stage only when the change cannot be exercised at runtime** (documentation, plan files, a pure refactor with no behavioural change). Say you are skipping it and why; do not silently pass it.
- `INTEGRATED` → Stage 5. `FAILED: <n> regressions` → Stage 2 as a fix round, with only the failing behaviour in scope.
- `BLOCKED: no suite` → ask the user where the suite lives — the agent does not invent one. When the user names the path, **write it to memory** so no later session asks again. Any other `BLOCKED: <reason>` → do what would unblock it, under Rule 3, or bring it to the user.
~~~

- **M18 (A29, B19, B23).** In *Stage 5*, delete the last sentence of `:454` ("The report template Rule 5 has you paste is allowed in this dispatch and is not content: it describes the form of the answer, not the change.") and delete the paragraph `:456` ("Dispatch it on the model Rule 5 gives the reviewer: … what its verdict means."). `:454`'s round-2 contents stay: this stage owns them (B19).
- **M19 (B14).** In *Stage 6*, after "Verify the file list from `git show --stat` matches what you expected." add: "A commit on `main` — allowed by the user's words or the repo's `AGENTS.md` — is said in the dispatch to be deliberate, or `glab:committer` stops."
- **M20 (A21).** In *Stage 6b*, replace "After the slug's last commit, before the push, at every tier:" with "After the slug's last commit, before the push, at normal and full tier:".
- **M21 (A23).** In *Stage 7*, replace "`/glab:push` shows exactly which commits will go out and waits for the user's go-ahead. Show the `## Decisions` lines of each plan the push carries — at normal tier this is where the user reads what you decided." with "`/glab:push` shows what will go out — the `## Decisions` lines of each plan it carries included — and waits for the user's go-ahead."
- **M23 (C11).** In *What you never do*, replace "- Run a fix-mode linter, or treat a whole-tree backlog sweep as a gate." with "- Run a fix-mode linter (`glab:security` Rule 5), or treat a whole-tree backlog sweep as a gate."
- **M24 (A26).** In *Rule 3*, after "A recommendation sent to the user for confirmation is a decision you made and did not write down." add: "A planner's `## Decisions` line is reviewed the same way: overrule one by adding a new line with your reason, never by editing the planner's."
  Post M8–M24: `/usr/bin/grep -c -E 'at every tier: `/glab:analyze|write it to memory|overrule one by adding' plugins/glab/skills/manager/SKILL.md` prints `2` (Stage 4's memory line and M24's; the Stage 6b line is gone); `wc -c plugins/glab/skills/manager/SKILL.md` prints less than `61959`.

## glab:bootstrap — `plugins/glab/skills/bootstrap/SKILL.md`

- **BS1 (A11).** Replace step 1's heading and body (`:15-38`) with:

~~~ BS1
## 1. Read the working agreement, the host file and the constants

The session-start text of the `glab` hook gives the order — `AGENTS.md` (or `CLAUDE.md`, said plainly), `docs/constants.md`, `~/.claude/host.md` — and the fallback for each. A session that received no such text — the plugin's hooks off — reads it first from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh`.

Do not skim `AGENTS.md`. It is the contract every review is held to, and an agent that skipped it produces work the repo rejects — which you pay for in a correction round, not in saved time.

Read `host.md` before the first command: steps 3 and 5 already run some, and step 6 says why its temp-file rule matters. `docs/constants.md` holds what is already decided — only the user changes it, and a plan conforms to it and never re-asks it.
~~~

- **BS2 (A1, A8, A10, A11, A28, C13, C14).** Replace step 2's body (`:42-72`) with:

~~~ BS2
Both, always — the session-start text says what each governs, and they are not alternatives. `glab:manager` governs *how* work is done, not *whether*: its Rule 1 exempts questions and trivial changes from the pipeline. `glab:security` exempts nothing.

What reaches each agent is `glab:manager` Rule 0c's: each `glab` agent's definition preloads the skills its role uses, and a dispatch carries only the facts of its task.
~~~

- **BS3 (C15).** In step 3, delete the paragraph "A command you composed yourself proves nothing about CI. … exactly where the race lives." (`:80-82`), and in the first paragraph replace "the CI config — and **write them down" with "the CI config — as `glab:security` Rule 3 says, and **write them down". The `make ci` case (`:84-87`) stays.
- **BS4 (A7, A12, A13, A17).** Replace step 4's body (`:94-126`, from the fenced sequence through "See `glab:manager` → *Running agents in parallel*.") with:

~~~ BS4
Name the stage you are at in `glab:manager` → *The pipeline*; *Pick the tier* says which stages run and how many rounds each gets. Dispatch independent agents in a single message (`glab:manager` → *Running agents in parallel*).
~~~

- **BS6 (B10, C6, C16).** In step 6:
  - replace "Say its temp-file rule in every dispatch message so subagents follow it too, use unique filenames, and clean up what you create." with "Name its temp directory in every dispatch message — a value the agent cannot see — use unique filenames, and clean up what you create.";
  - replace "Re-run with `-count=1` after any dependency or infrastructure change." with "What the cache hides, and what `-count` does about it, is `glab:security` Rule 4.";
  - delete the paragraph "**Secrets never enter output — and say so in every dispatch, not only the ones you expect to touch config.** … Do not print config values at all; test them instead." (`:208-214`); its case moves to `glab:security` (`steps-shared.md` SE4).
  Post BS1–BS6: `/usr/bin/grep -c -E 'say all of it, in every dispatch|loss is invisible|Normal work runs a one-page plan|composed yourself|embedded password|^plan ⇄ analyze' plugins/glab/skills/bootstrap/SKILL.md` prints `0`; `/usr/bin/grep -c -E '335 RPC|psql \| head -8|\(cached\)|5 findings to 11|make ci' …` prints `5` (the cases stay); `/usr/bin/grep -c 'CLAUDE_PLUGIN_ROOT' …` prints `1`.

## The session-start hook — `plugins/glab/scripts/manager-bootstrap.sh`

- **H1 (A1, A7, A10, A11, C13, C14).** Replace the text between `read -r -d '' CTX <<'CTX_EOF'` and `CTX_EOF` — lines `:12-24` — with the block below, byte for byte. Nothing else in the script changes: the header comment, `jq`, the `printf` fallback and `exit 0` stay.

~~~ H1
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement. Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.

2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:
   - `glab:manager` — the operating model. Each stage of its pipeline (`glab:manager` -> *The pipeline*, as far as *Pick the tier* runs it) is dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Each `glab` agent loads its own rules: `AGENTS.md` in its own first step, and the `glab` skills its role uses from its definition. A dispatch carries only the facts of its task (`glab:manager` Rule 0c) and passes the Agent tool's `effort` parameter at the session's level (`glab:manager` Rule 0d).

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, name its temp directory in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 6 explains why this matters.

Questions and trivial changes skip the pipeline (`glab:manager` Rule 1); nothing skips `glab:security`. A trivial change still gets its claim verified, and a gate is never reported green on an agent's word.
~~~

  Post: `diff <(awk '$1=="~~~" && $2=="H1"{f=1;next} f && $0=="~~~"{f=0} f' plan/flow-commands-to-skills/steps-manager.md) <(bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext); echo "rc=$?"` prints only `rc=0`; `bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext | wc -c` prints less than `10000`; `/usr/bin/grep -c -E 'plan -> develop|carries the `glab:security` and `glab:comments`|Say all of it|repeat its temp-file rule' plugins/glab/scripts/manager-bootstrap.sh` prints `0`. The AGENTS.md script gates (`bash -n`, `test -x`, shellcheck) stay green (A1).
