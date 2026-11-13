tier: normal — payload Markdown moves from `commands/` to `skills/`, payload and repo Markdown and one hook's text change, plus manifest text and a version bump; no schema, stored or wire format, authorization, secret or money path (`glab:manager` → *Pick the tier*)

# flow-commands-to-skills — the eight `glab` commands become stage skills, and every rule gets one owner

Slug `flow-commands-to-skills`. Planned by the installed workflow (`~/.claude/skills/plan-first`), which writes `plan.md` alone at normal tier; no `master.md` is written (the user keeps the installed workflow in this repo — memory *Keep current manager workflow*). This `plan.md` is the contract; the steps it runs are in five files beside it, named under *processing*. The question in `questions.md` (Q1) is open, and the build waits for it.

## Request

1. Remove `plugins/glab/commands/`. Each of its eight commands — `analyze`, `commit`, `develop`, `integrate`, `plan`, `push`, `review`, `ship` — becomes `plugins/glab/skills/<same-name>/SKILL.md`. A person can still type `/glab:<name>` to step in; `glab:manager` invokes the stages itself through the Skill tool. User's goal: "full agent based workflow with minimal human interaction".
2. The user, relayed by the manager: "We also need to carefully examine and remove any conflicting or redundant elements within the project manager skills" — the manager skills and agents — and "agent must receive the thing once and clear, Skills should not have a repeating context for project manager skills". The test for every rule: **who acts on it**. The acting role's file owns it; other files drop it or keep a short pointer. *One fact* registration is no exemption; recorded incidents are kept, in one place, next to the rule they explain; a collapsed duplicate shrinks its *One fact* entry in this plan.

Out of scope: product, delivery and support manager levels; `docs/specs/` (the record stage updates it after the push).

## Milestone

After this plan, from a tree with no `plugins/glab/commands/`: `claude --plugin-dir ./plugins plugin details glab` (under the *Gates* `CLAUDE_CONFIG_DIR` rule) prints `glab 0.13.0` and `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`; the new skills gate prints its fourteen lines with no `MISSING`; every AGENTS.md gate is green as A1 lists; and the ownership searches of A2 and A3 return what they name. The test that proves it is A1–A3. That the `Skills (14)` line comes out of the moved tree was proven in a throwaway export (F6).

## Findings

The three audits beside this file are the findings for request 2: `audit-a-model.md` (A1–A30), `audit-b-agents.md` (B1–B33), `audit-c-shared.md` (C1–C18), each finding with its evidence and P/I label. *Disposition* below settles each by id. What follows is the evidence for request 1 and for the decisions.

### Proven

- **F1 — the eight command files** (`plugins/glab/commands/*.md`, HEAD `5a72155`). Frontmatter of every file is exactly `description:` and `argument-hint:`; none sets `allowed-tools`, `model`, `name`, `disable-model-invocation` or `user-invocable` (`grep -n -i -E 'allowed-tools|^model:|disable-model|user-invocable' plugins/glab/commands/*.md` printed nothing for those keys). `$ARGUMENTS` is used in analyze, commit, develop, integrate, plan, push, review and ship. Sizes 839–7836 bytes.
- **F2 — skills accept every key the commands use.** https://code.claude.com/docs/en/skills frontmatter table: `description`, `argument-hint`, `allowed-tools`, `model`; `$ARGUMENTS` — "All arguments passed when invoking the skill", and "Both you and Claude can pass arguments when invoking a skill". Same page: "Custom commands have been merged into skills."
- **F3 — a plugin skill is `/glab:<name>`.** https://code.claude.com/docs/en/skills: "`my-plugin/skills/review/SKILL.md` → `/my-plugin:review`". https://code.claude.com/docs/en/plugins-reference standard layout: `commands/` — "Prefer `skills/` for new plugins".
- **F4 — `disable-model-invocation` and `user-invocable`.** https://code.claude.com/docs/en/skills: `disable-model-invocation: true` keeps Claude from invoking a skill through the Skill tool — it **would stop `glab:manager` invoking that stage** — and "prevents the skill from being preloaded into subagents"; `user-invocable: false` hides it from the `/` menu. Defaults (`false`, `true`) are what this change needs.
- **F5 — `Skills (14)` before and after the move.** Baseline: `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship` — the CLI already counts the eight commands as skills. A throwaway copy with the eight moved and `commands/` removed printed the identical line, `Agents (7)`, `Hooks (4)`, `✔ Validation passed`.
- **F6 — the move simulated** (P1–P8 as first planned, `git archive HEAD` export under `$TMPDIR`, removed afterwards): `diff` of each moved file against its command showed only `1a2 > name: <n>` (plus the then-planned P3 lines); three `✔ Validation passed`; `glab 0.13.0`; the F5 line; `glab = glab`, `memory-sync = memory-sync`; 7 model lines; name gate no line, `rc=1`.
- **F7 — existing skills carry a bare `name:`** equal to their directory; with `name: <n>` added to the eight the name gate printed no line, `rc=1`, and its positive control matched `plugins/glab/skills/push/SKILL.md`.
- **F8 — references to the component "command"** that must change: `AGENTS.md:11`, `:71`, `:131` (inside the *One fact* bullet, R1), `:303`; 30 path references in *One fact* (R1 rewrites them); `README.md:9`, `:12–13`; `.claude-plugin/marketplace.json:11`; `plugins/glab/skills/manager/SKILL.md:3`, `:153`, `:197`, `:231`; `plugins/glab/.claude-plugin/plugin.json:3` `0.12.0`.
- **F9 — what keeps the word.** `hooks.json` `"type": "command"`; `reviewer.md:34` and `committer.md:23` (`?? .claude/commands/` is an example); `README.md:167–170` (the old copy install); every `/glab:<name>` reference (the stage skill keeps the name); `tests/`, `host.example.md` (none).
- **F10 — baseline gates green** on `5a72155`: five `rc=0`; shellcheck `rc=0`; `PASS 35/35`, `PASS 24/24`; the plugin block as A1 lists for 0.12.0; hooks `:0 :0 rc=1`; `not yet confirmed` `1 1 1 rc=0`; seven model lines `rc=0`; name gate `rc=1`.
- **F11 — commands already reach the Skill tool** in this session's skill list (`analyze` … `ship`, from `~/.claude/commands/*.md`).
- **F12 — the preload channel exists for plugin agents.** https://code.claude.com/docs/en/sub-agents frontmatter table: "`skills` — Skills to preload into the subagent's context at startup. The full skill content is injected, not only the description"; `tools` row: "To preload Skills into context, use the `skills` field rather than listing `Skill` here"; "up to the first 32 distinct names"; a missing skill is skipped with a debug-log warning. https://code.claude.com/docs/en/plugins/components, *Frontmatter fields in plugin agents*: "Supported fields: `name`, `description`, `model`, `effort`, … `tools`, `disallowedTools`, `skills`, …". Neither page shows how a plugin skill is named in the list.
- **F13 — validation does not check the list.** Throwaway copy (`$TMPDIR/fcts-skillsprobe.*`, removed): `skills:` with `glab:security`, `glab:comments`, `glab:audit` on `reviewer.md` and `glab:no-such-skill` on `analyzer.md` → `claude plugin validate --strict plugins/glab` printed `✔ Validation passed`, `rc=0`; `plugin details glab` showed `reviewer ~2.3k`, `analyzer ~2.2k` on-invoke, the same as the unchanged tree — it neither checks nor counts the preload.
- **F14 — the skills gate (R2a) discriminates.** On a throwaway copy with `glab:security,glab:comments,glab:audit` (reviewer), `glab:security,glab:no-such` (analyzer), `other:security` (committer) it printed the four good entries and `analyzer.md:glab:no-such MISSING`, `committer.md:other:security MISSING`. On today's tree it prints nothing (no `skills:` yet).
- **F15 — first-person voice in the commands:** `grep -o -w -E 'me|my|mine|I'` counts analyze 4, develop 12, integrate 2, plan 9, push 13, review 4, ship 10 (54); commit 0.
- **F16 — the hook text round-trips:** `diff <(sed -n 12,24p plugins/glab/scripts/manager-bootstrap.sh) <(bash … | jq -r .hookSpecificOutput.additionalContext)` printed nothing, `rc=0` — H1's post-condition can compare the block with the hook's output.
- **F17 — the S1–S8 blocks pass their own checks** when extracted with the `steps-stages.md` `awk`: first-person count `0` in all eight; the waits (`go-ahead`, `main`, `Approval`, `ask-condition`, `waived`) present in push, commit, develop and plan; `diff` of S6 against `commands/push.md` shows only the voice lines, step 4's `## Decisions` sentence and the security pointer.
- **F18 — R1's path check has a positive control:** on today's tree it reports exactly `skills/analyze`, `skills/develop`, `skills/ship` `SKILL.md` missing — the three post-move paths it names.

### Inferred

- **I1** — On update to 0.13.0 an installed `glab` loses `commands/` and gains the eight skills under the same `/glab:<name>`, so nothing is listed twice (F3, F5, the version pin rule; no install run).
- **I2** — With no `disable-model-invocation`, the model may load `glab:push` or `glab:commit` on its own, as it could the commands (F11); push still waits at step 7 for the user's go-ahead, and commit never pushes.
- **I3** — The preload costs context per dispatch: by `plugin details`' on-invoke estimates, `glab:security` ~3k, `glab:comments` ~1.3k, `glab:audit` ~0.8k, `glab:plan-first` ~3.4k tokens, on top of each agent's ~0.5–2.9k. In exchange the agent files and every dispatch drop their copies.

### Rejected boundaries

- `disable-model-invocation: true` on any stage skill: blocks the manager's Skill-tool call (F4).
- Keep `commands/` beside the skills: two components per name, `Skills (22)`, and the request says remove the folder.
- A `commands` or `skills` key in `plugin.json`: `skills/` is the default scan; `commands` would replace a folder that no longer exists.
- Copy the few shared rules each role needs into its agent file (A1's and C2's recommended channel): a second copy of each rule per agent, which request 2 forbids once a preload channel exists (F12).
- Add `Skill` to each agent's `tools` with a load-first line: the docs say to use `skills:` instead (F12), and a load the agent may skip is not a channel.
- Split into a master with sub-plans: the installed workflow has none here; one slug, one commit, and five disjoint slices (P9) give the same parallelism.

## Decisions

- effort: high (the user's words: "high (Recommended)"), for the session
- FU1-1 — A rule only one role acts on lives in that role's file; Stage 1b's per-analyzer checks and their cases move into `glab:plan-analyzer` *The plan check*, and the manager keeps one pointer (A2) — the manager's decision.
- FU1-2 — A shared rule lives once, in `glab:security`, `glab:comments` or `glab:audit` (and `glab:plan-first` for the planner), and reaches each agent through its frontmatter `skills:` list, which plugin agents support and which needs no `Skill` tool (F12, https://code.claude.com/docs/en/sub-agents, https://code.claude.com/docs/en/plugins/components); entries are written `glab:<name>` as a YAML list; that the content loads is UNVERIFIED (U4, U5).
- FU1-3 — A dispatch carries only per-task facts: slug, step ids, file boundary, sub-plan paths, decisions and answers not in the plan, the round and its inputs, the temp directory, the `effort` and `model` parameters; Rule 0c, bootstrap step 2 and hook point 3 shrink to say so (M3, BS2, H1).
- FU1-4 — A stage skill is an entry point: preconditions, the agent it dispatches, a pointer. Routing, dispatch lists and gate runs are the manager stage's, which wins where they disagreed (B5, B9, B21); push keeps its own procedure and ship its verdict gate, which no manager stage holds.
- The preload lists: `glab:security` for all seven; `glab:comments` for developer, integrator and reviewer, which write or judge code and its comments; `glab:audit` for reviewer, analyzer and plan-analyzer, which rate by its *Severity Levels* and say they write no audit document; `glab:plan-first` for the planner, which keeps its `Skill` tool.
- An agent with no definition has no frontmatter, so its dispatch names `glab:security` (and `glab:audit` for findings): its one channel (M3).
- The temp directory is a value the agent cannot see, so the dispatch carries it; "never `/tmp`" is said once in each agent file that writes temp files (B10).
- Restatements of `glab:security` in agent files go once the agent preloads it (D3, D4, D6, RV2, RV3, IN3, IN4, IN6); what only the role does stays — the developer's closed list and record rules, the integrator's container rules, the committer's deny-list.
- Rule 5's report-template paste for `sonnet` and `haiku` goes (B23): the agent's own *Report* is its template, and Rule 5's report check stays the backstop; this reverses a 0.12.0 dispatch choice, not the model table.
- The plan-analyzer's step status `done` becomes `buildable` (B16); the manager matches verdicts, not step statuses.
- Plan-first Step 3 gains the three phases, and the manager's checklist item 2 checks Step 3's list (A5): the planner writes the shape, the manager only checks it.
- Gates and tests stay the bootstrap's (step 3) and the developer's; the manager's *Know the gates* and Stage 2 verify point at them (C12 with the owner FU1-4 gives, not `develop.md` as C12 proposed).
- Stage skills write "the user" for the first person and "the session that runs it" for the second; every wait for the user stays — push go-ahead, force-push and upstream choices, `main` before pushing, a commit on `main`, full-tier approval, Rule 3 questions, the waiver.
- The waiver is only the user's own words; the manager never writes `waived.md` for them (S5).
- Cases are kept once, next to their rule: Stage 1b's case and measurements in `plan-analyzer.md`; the DSN leak in `glab:security` *Secrets never enter output*; `make lint` / 85 mockgen in `analyzer.md` Step 4; the cached-test case stays in bootstrap step 6 with a pointer to Rule 4; the deleted-`TODO` reasoning is already `glab:comments`' (`:98`), so the manager's and bootstrap's copies go.
- The Rule 5 version history leaves the manager (A30); its exact text is kept in `steps-manager.md` M7 for the record to carry into `docs/specs/workflow.md`.
- A `/glab:review` round tells the reviewer the round, and the reviewer keeps its own round-2 rule ("round 2 is the last unless you report `critical` or `high`"), because it acts on it; the analyzers only rate, so their round-3 sentence goes (A13).
- *One fact* entries shrink to the files that still state the fact, and a new entry and gate cover the `skills:` lists (R1, R2): validation passes a wrong name and `plugin details` shows none (F13).
- A8/A15/B33/C18 change what a person running `glab:plan-first` alone gets, so they are Q1 in `questions.md`, recommended A; steps carry an A and a B form.
- No stage skill sets `disable-model-invocation` or `user-invocable` (F4); `push` and `ship` get the same frontmatter as the others.
- Each moved file gains `name: <n>` on line 2, bare (F7); `description` and `argument-hint` stay byte-identical except `develop`'s description (A4).
- No `allowed-tools` or `model` in any stage skill: no command set one (F1), and a skill-level `model` would override the session's.
- Files move with `git mv` first and P3 proves the bodies moved unchanged; S1–S8 then replace each body.
- Wording outside the stage skills changes where it names the component (F8) and where *Disposition* names a step; generic "command" and every `/glab:<name>` stay (F9).
- The manager's new sentence goes at the head of the line after the pipeline table (P4); it says the manager invokes the stage skill itself and a person may type it.
- `commands` leaves the AGENTS.md commit-scope list; past `fix(commands)` commits stay.
- `glab` goes 0.12.0 → 0.13.0, once, in this change's one commit; `memory-sync` is untouched.
- One commit, suggested `feat(skills): move the glab commands into stage skills and give each rule one owner (glab 0.13.0)`; the committer owns the subject.
- Stage 4 runs the milestone test — A1–A3 — as there is no service; an interactive run is the user's after install (U1, U4), since `claude -p` would spend money.
- size: `plan.md` stays under 48 KB by holding the contract only; the edits are in `steps-stages.md`, `steps-agents.md`, `steps-manager.md`, `steps-shared.md` and `steps-repo.md`.

## Disposition

`apply` (the step ids that carry it), `merge → <id>` (carried by that finding's steps), or `reject`. None is rejected.

| id | disposition | steps |
|---|---|---|
| A1 | apply | AG0, M3, BS2, H1, P6; D3, D4, D6, RV1–RV3, IN3, IN4, IN6 |
| A2 | apply | PA1, M14 |
| A3 | apply | S3, M12, M15 |
| A4 | apply | S3, R1 |
| A5 | apply | PF5, M13 |
| A6 | apply | D5, M15 |
| A7 | apply | H1, BS4, R1 |
| A8 | apply (seam) + Q1 | M3, M14, BS2; PF1 |
| A9 | merge → C12 | — |
| A10 | apply | M1, M3, H1, S1–S8, R1 |
| A11 | apply | H1, BS1, BS2, M1, M2, M5 |
| A12 | apply | BS4 |
| A13 | apply | AN3, PA3, RV4, RV6, S8, BS4, R1 |
| A14 | apply | M15 |
| A15 | Q1 | PF9, PF10, IM1, D4b |
| A16 | apply | M3, PL1 |
| A17 | apply | M7, BS4 |
| A18 | apply | PF3, PF6, M9 |
| A19 | apply | PF1, PF2 |
| A20 | apply | AN2 |
| A21 | apply | M20 |
| A22 | merge → B5 | — |
| A23 | apply | S6, M21 |
| A24 | merge → C11 | — |
| A25 | apply | M12, M15 |
| A26 | apply | M3, M13, M24 |
| A27 | apply | PF8, M11 |
| A28 | apply | S3, S5, BS2, R1 |
| A29 | apply | S1–S8, M15, M18, R1 |
| A30 | apply | M7 |
| B1 | apply | D1, AN1 |
| B2 | apply | D1 |
| B3 | merge → A6 | — |
| B4 | apply | M6, M15 |
| B5 | apply | S1 |
| B6 | merge → A13 | — |
| B7 | merge → A13 | — |
| B8 | apply | IN2, M17, S4 (the tier table's cell stays: it is the manager's index of what runs) |
| B9 | apply | M17 |
| B10 | apply | D2, RV5, IN5, BS6, H1, M3 |
| B11 | merge → A20 | — |
| B12 | merge → A1 | — |
| B13 | merge → A29 | — |
| B14 | apply | CM1, M19, S2 |
| B15 | apply | IN1, IN2, S4 |
| B16 | apply | PA2 |
| B17 | merge → A29 | — |
| B18 | merge → A10 | — |
| B19 | apply | M18 (Stage 5 owns), RV6, S8, R1 |
| B20 | merge → A13 | — |
| B21 | apply | M15, S3 |
| B22 | merge → A14 | — |
| B23 | apply | M7, M18 |
| B24 | merge → A25 | — |
| B25 | merge → C11 | — |
| B26 | apply | M15, S3 |
| B27 | apply | M15, S3 |
| B28 | apply | S1 (Stage 3 and *What you never do* keep the manager's never-edit) |
| B29 | apply | M17, S4 |
| B30 | apply | S5 |
| B31 | apply | PA4 |
| B32 | apply | S2, S8 |
| B33 | merge → A15 | — |
| C1 | apply | AU1, AU2, PF3, PF4, PF7, M13 |
| C2 | merge → A1 | — |
| C3 | merge → A1 | — (the developer preloads `glab:comments`) |
| C4 | merge → A6 | — |
| C5 | apply | RV1 |
| C6 | apply | SE2, BS6 |
| C7 | apply | IN6, D4, S3 |
| C8 | apply | SE1 |
| C9 | apply | CO1 |
| C10 | apply | P6 |
| C11 | apply | SE3, M15, M23, D4, RV3, S3 |
| C12 | apply | M8, M15, S3, D4 |
| C13 | apply | M2, M3, BS2, H1 |
| C14 | apply | M2, M5, BS2, H1 |
| C15 | apply | BS3, M8 |
| C16 | apply | SE4, BS6 |
| C17 | apply | AG0, AN3, PA3, RV4, R1 |
| C18 | apply | D3; Q1 for `implement.md` |

Counts: 62 apply (A15 carried by Q1), 19 merge, 0 reject — 81.

## Steps

Every shell step: `export TMPDIR=/data/tmp/claude` first; `/usr/bin/grep`, not `grep`; any `claude` command only inside the AGENTS.md `CLAUDE_CONFIG_DIR` block. Run from the repo root. Each post-condition is checked when its step is done; a later step may change the same file.

### before

- **B0 — Q1 is answered.** `questions.md` Q1's *Status* line names `A` or `B` in the user's words. Otherwise stop: the build has no contract for the Q1 steps.
- **B1 — Confirm the starting tree.** `git status --short -uall -- plugins AGENTS.md README.md .claude-plugin` prints nothing. Otherwise stop and report.
- **B2 — Run the AGENTS.md gates once** (script gates and plugin-gate block, verbatim from *Gates*) and keep the output. Post: the F10 results. A red gate stops the build before any edit.
- **B3 — Positive controls for the absence searches**, on the unchanged tree:
  - `/usr/bin/grep -n -i -E 'slash commands|`/glab:` command|^A command that|Commands take' plugins/glab/skills/manager/SKILL.md` → lines 3, 153, 197, 231;
  - `/usr/bin/grep -n -E 'its skills, agents and commands|six skills and the eight commands|`commands`, `skills`' AGENTS.md` → lines 11, 71, 303;
  - `/usr/bin/grep -o -w -E 'me|my|mine|I' plugins/glab/commands/*.md | wc -l` → `54` (F15);
  - each absence pattern a steps-file post-condition uses matches today in the file it names (run each with `-c`; every count is 1 or more). A pattern that matches nothing today proves nothing later — report it as `PLAN WRONG`.
  Post: each prints as stated; otherwise the plan is stale — stop and report `PLAN WRONG`.

### processing

- **P1 — Move the files.** For each `n` in `analyze commit develop integrate plan push review ship`: `mkdir -p plugins/glab/skills/$n && git mv plugins/glab/commands/$n.md plugins/glab/skills/$n/SKILL.md`. Then `rmdir plugins/glab/commands` (never `rm -r`).
  Post: `test ! -e plugins/glab/commands && echo gone` prints `gone`; `ls plugins/glab/skills/*/SKILL.md | wc -l` prints `14`; `git status --short -- plugins/glab` shows eight `R` entries.
- **P2 — Add the name line.** In each of the eight new `SKILL.md`, insert `name: <n>` as line 2. Change nothing else.
- **P3 — Prove the bodies moved unchanged.** For each `n`: `diff <(git show HEAD:plugins/glab/commands/$n.md) plugins/glab/skills/$n/SKILL.md`.
  Post: exactly `1a2` and `> name: $n` for all eight. Then S1–S8 replace the bodies.
- **P4 — `glab:manager`** (`plugins/glab/skills/manager/SKILL.md`), four edits:
  - line 3, in `description:`: "using slash commands and subagents" → "using its stage skills and subagents";
  - line 153: "whether the dispatch runs through a `/glab:` command or directly" → "whether the dispatch runs through a `/glab:` stage skill or directly";
  - line 197: replace the opening sentence "A command that does not exist in this repo → dispatch the agent of the same role directly with the same contract." with "Each `/glab:<name>` under *Run* is the `glab:<name>` stage skill: invoke it yourself through the Skill tool, with the slug or the task as its argument, and do not wait for the user to type it — the user can type the same `/glab:<name>` to step in. A stage skill that is not available in this session → dispatch the agent of the same role directly with the same contract." The rest of the line stays;
  - line 231: "Commands take `{slug}/<nn>-<name>` for a slug" → "Stage skills take `{slug}/<nn>-<name>` for a slug".
  Post: the B3 manager search prints nothing, `rc=1`; `/usr/bin/grep -c 'invoke it yourself through the Skill tool' plugins/glab/skills/manager/SKILL.md` prints `1`.
- **P5 — `AGENTS.md`**, outside *One fact* (R1 rewrites that bullet):
  - line 11: "its skills, agents and commands," → "its skills and agents,";
  - line 71: "`Skills (14)` naming the six skills and the eight commands" → "`Skills (14)` naming `analyze`, `audit`, `bootstrap`, `comments`, `commit`, `develop`, `integrate`, `manager`, `plan`, `plan-first`, `push`, `review`, `security` and `ship`". The rest of the line stays;
  - line 303: "`sync`, `agents`, `commands`, `skills`, `repo`" → "`sync`, `agents`, `skills`, `repo`".
  Post: the B3 AGENTS.md search prints nothing, `rc=1`.
- **P6 — `README.md`** (with C10).
  - line 9: replace "· commands `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`, `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship` ·" with "· stage skills `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`, `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship`, which `glab:manager` runs itself and you can type to step in ·".
  - lines 12–16, the paragraph from "In `glab` the skills, agents and commands are one set:" to "install either alone.", become: "In `glab` the skills and agents are one set: `glab:manager` runs each stage through its stage skill, which dispatches the agents. Each agent preloads, through the `skills:` list in its definition, the `glab` skills its role uses — `glab:security` in all seven — and runs at the session's effort level, which the manager passes on every dispatch. The two plugins do not depend on each other; install either alone." (rewrap freely).
  - Lines 167–170 stay (F9).
  Post: `/usr/bin/grep -n -E '· commands|agents and commands|through the commands|every agent carries' README.md` prints nothing, `rc=1`; `/usr/bin/grep -c 'stage skills `/glab:plan`' README.md` prints `1`; `/usr/bin/grep -c 'skills:` list in its definition' README.md` prints `1`.
- **P7 — `.claude-plugin/marketplace.json`**, the `glab` entry's `description`: "The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook" → "The glab workflow: skills, agents, the session bootstrap hook and the context hook".
  Post: `jq -r '.plugins[0].description' .claude-plugin/marketplace.json` prints the new text; `jq . .claude-plugin/marketplace.json >/dev/null; echo rc=$?` prints `rc=0`.
- **P8 — `plugins/glab/.claude-plugin/plugin.json`**: `"version": "0.12.0"` → `"version": "0.13.0"`.
  Post: `jq -r .version plugins/glab/.claude-plugin/plugin.json` prints `0.13.0`.
- **P9 — Run the five steps files**, each step with its post-condition. Their file boundaries are disjoint, so the manager may give each its own developer (*Running agents in parallel*); one developer runs them in this order:
  1. `steps-stages.md` S1–S8 (after P3) — the eight stage `SKILL.md`;
  2. `steps-agents.md` AG0, PL1, D1–D6, AN1–AN3, PA1–PA4, RV1–RV6, IN1–IN6, CM1 — `plugins/glab/agents/` (PA1 takes its text from `git show HEAD:plugins/glab/skills/manager/SKILL.md`, so it does not depend on when M14 runs);
  3. `steps-manager.md` M1–M24, BS1–BS6, H1 (after P4) — manager, bootstrap, hook script;
  4. `steps-shared.md` SE1–SE4, CO1, AU1–AU2, PF1–PF10, IM1 — security, comments, audit, plan-first;
  5. `steps-repo.md` R1, R2 (after P5) — `AGENTS.md`.
  Post: every step's post-condition held when it ran.

### after

- **A1 — Run every AGENTS.md gate**, verbatim from the new *Gates*. Expected:
  - script gates: five `rc=0` lines; shellcheck `rc=0` with no findings; `PASS 35/35` and `PASS 24/24`, every line `ok` (H1 changes only the heredoc text of a hook script);
  - plugin gates: three `✔ Validation passed`; `  Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship`; `  Agents (7)` with the seven agents in any order; `  Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop` with its trailing note; for `memory-sync` `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
  - `glab = glab`, `memory-sync = memory-sync`;
  - `plugins/glab/hooks/hooks.json:0`, `plugins/memory-sync/hooks/hooks.json:0`, `rc=1`;
  - `not yet confirmed`: `1` after each of the three files, `rc=0`;
  - model gate: exactly the seven lines AGENTS.md lists, `rc=0`;
  - skills gate: exactly the fourteen lines of R2b, in that order, none `MISSING`;
  - name gate: no line, `rc=1`.
  Also, inside the same `CLAUDE_CONFIG_DIR` block, `"$claude" --plugin-dir ./plugins plugin details glab | head -n 1` prints `glab 0.13.0`.
- **A2 — The reference sweep.** `/usr/bin/grep -rn -E 'commands/' plugins README.md AGENTS.md .claude-plugin tests host.example.md`.
  Post: exactly `plugins/glab/agents/reviewer.md` and `plugins/glab/agents/committer.md` (the `?? .claude/commands/` examples) and the four `README.md` lines of the old copy install that list `commands/plan.md` … `commands/ship.md` (F9).
- **A3 — Ownership searches** (request 2), each printing what it names:
  - each stage skill equals its S block (the `steps-stages.md` post-condition, rerun for all eight): `rc=0` eight times;
  - `/usr/bin/grep -rl -E 'even when the agent definition already requires it|Say all of it in the dispatch|say all of it, in every dispatch' plugins` prints nothing, `rc=1` (FU1-3);
  - `/usr/bin/grep -rc -F 'unbounded memory growth' plugins/glab` prints `1` for `skills/audit/SKILL.md` only — every other file `:0` (C17);
  - `/usr/bin/grep -rc -F 'each call `Apply`' plugins/glab` prints `1` for `agents/plan-analyzer.md` only (A2);
  - `/usr/bin/grep -rc -E -- '--fix' plugins/glab` prints `1` for `skills/security/SKILL.md` only (C11);
  - `/usr/bin/grep -rc 'Proven\*\* —' plugins/glab` prints `1` for `skills/security/SKILL.md` only (C1);
  - `/usr/bin/grep -rn 'no contract' plugins` prints only `developer.md`'s `BLOCKED: no contract` line (B1, B2).
- **A4 — The change's footprint.** `git status --short -uall -- . ':!plan/'`.
  Post: the eight renames (`R`, then `M` content on the same paths), `D plugins/glab/skills/plan-first/implement.md` under Q1 = A only, and `M` for exactly: `AGENTS.md`, `README.md`, `.claude-plugin/marketplace.json`, `plugins/glab/.claude-plugin/plugin.json`, `plugins/glab/scripts/manager-bootstrap.sh`, the seven `plugins/glab/agents/*.md`, and `SKILL.md` of `manager`, `bootstrap`, `security`, `comments`, `audit`, `plan-first`, plus `plugins/glab/skills/audit/references/plan-template.md`. Nothing under `docs/specs/`, `plugins/memory-sync/` or `tests/`.
- **A5 — Clean up** every temp file the build made under `$TMPDIR`; the gate block removes its own config dir.
  Post: `ls /data/tmp/claude | /usr/bin/grep -c -E 'claude-config|fcts-'` prints `0` for directories this build created (report any that predate it rather than removing them).

## Tests

No test file changes: the one script change is heredoc text, run by the script gates; `tests/*.test.sh` run as gates only. Coverage, as a list:

- P1–P3: A1 plugin gates and P3's diff.
- P4–P8: their posts; A1 (`Skills (14)` against the new line 71, `glab = glab`, `glab 0.13.0`); A2.
- S1–S8: the block `diff` (A3), the voice and waits searches.
- AG0: the skills gate (A1), whose discrimination F14 showed.
- Agent, manager, bootstrap, shared and repo steps: their posts and A3's single-owner counts; H1 also its round-trip `diff` (F16) and the script gates.
- R1: its path-existence check (control F18).
- Not covered by any case: that a typed `/glab:<name>` and the manager's Skill-tool call run the moved skills (U1, U2), and that the `skills:` preload injects the plugin skills into a plugin agent (U4, U5). Accepted: the docs state each (F2–F4, F12), and a runtime check needs an interactive session or a paid `claude -p` run.

## Not verified

- **U1** — UNVERIFIED: typing `/glab:<name>` runs the moved skill with `$ARGUMENTS` — docs (F2, F3) and `plugin details` only. The user can check after installing 0.13.0 with `/glab:review`.
- **U2** — UNVERIFIED: `glab:manager`'s Skill-tool call on `glab:<name>` loads the plugin skill with its argument — docs (F2, F4) and F11 only.
- **U3** — UNVERIFIED: an installed copy updated to 0.13.0 drops the old commands with no duplicate listing (I1) — no install may be run from this repo.
- **U4** — UNVERIFIED: a plugin agent's `skills:` entry written `glab:security` preloads that plugin skill's full content — the docs name the field for plugin agents but show no plugin-skill name form (F12), and validation and `plugin details` do not resolve it (F13); a live dispatch was not run. After install the user can dispatch `glab:reviewer` on a clean path and ask it to quote `glab:security` Rule 5's first line; a missing skill is also logged as a warning in the debug log (F12).
- **U5** — UNVERIFIED: the preload works for an agent whose `tools` list lacks `Skill` — inferred from the docs telling authors to use `skills:` "rather than listing `Skill` here" (F12).
- **U6** — UNVERIFIED: `${CLAUDE_PLUGIN_ROOT}` in `glab:bootstrap` step 1 is substituted when the skill loads — documented for "Skill, command, and agent content" (https://code.claude.com/docs/en/plugins-reference, *Environment variables*), not run.
- **U7** — UNVERIFIED: the preload's per-dispatch cost (I3) — `plugin details` estimates; no transcript was measured.

## Record

After the push, the record stage updates `docs/specs/workflow.md` — the stage skills, F4's invocation decision, FU1-1 to FU1-4 and the preload lists, the B23 reversal, Q1's answer, U1–U7, and the Rule 5 version history kept verbatim in `steps-manager.md` M7 into *Known limits and not verified* — and `docs/specs/marketplace.md` — the layout, the *Gates* `Skills (14)` line and the new skills gate, the commit-scope list, the *One fact* changes of R1. This plan edits no spec.
