tier: normal — payload Markdown moves from `commands/` to `skills/` and `glab:plan-first` merges into `glab:plan`, payload and repo Markdown and one hook's text change, plus manifest text and a version bump; no schema, stored or wire format, authorization, secret or money path (`glab:manager` → *Pick the tier*)

# flow-commands-to-skills — the `glab` commands become stage skills, `glab:plan-first` becomes `glab:plan`, and every rule gets one owner

Slug `flow-commands-to-skills`. Planned by the installed workflow (`~/.claude/skills/plan-first`), which writes `plan.md` alone at normal tier; no `master.md` is written (the user keeps the installed workflow in this repo — memory *Keep current manager workflow*). This `plan.md` is the contract; the steps it runs are in six files beside it, named under *processing*. The user answered Q1 in `questions.md` — A, plan only — so the build waits on no question.

## Request

1. Remove `plugins/glab/commands/`. Each of its eight commands — `analyze`, `commit`, `develop`, `integrate`, `plan`, `push`, `review`, `ship` — becomes `plugins/glab/skills/<same-name>/SKILL.md`. A person can still type `/glab:<name>` to step in; `glab:manager` invokes the stages itself through the Skill tool. User's goal: "full agent based workflow with minimal human interaction".
2. The user, relayed by the manager: "We also need to carefully examine and remove any conflicting or redundant elements within the project manager skills" — the manager skills and agents — and "agent must receive the thing once and clear, Skills should not have a repeating context for project manager skills". The test for every rule: **who acts on it**. The acting role's file owns it; other files drop it or keep a short pointer. *One fact* registration is no exemption; recorded incidents are kept, in one place, next to the rule they explain; a collapsed duplicate shrinks its *One fact* entry in this plan.
3. Q1, the user's answer, 2026-11-13: "A: plan only" — `glab:plan-first` plans and stops at Step 4.
4. The user, 2026-11-13, relayed by the manager: "Yes, merge them" — `glab:plan-first` merges into the stage skill `glab:plan`: one skill, `plugins/glab/skills/plan/SKILL.md`, holding the planning procedure (Steps 0–4). The `/glab:plan` wrapper text goes; `glab:manager` Stage 1 dispatches `glab:planner` directly; the planner preloads `glab:plan`; a person who types `/glab:plan <task>` gets the procedure in their own session — keeping `argument-hint`, a `$ARGUMENTS` hook, the trivial-work stop and the user-only waiver rule, each once. `plugins/glab/skills/plan-first/` goes with `git mv`/`git rm`; every `plan-first` reference is renamed, proven by a search that finds none outside `docs/specs/` and `plan/`; the `plugin details` count drops by one.

Out of scope: product, delivery and support manager levels; `docs/specs/` (the record stage updates it after the push).

## Milestone

After this plan, from a tree with no `plugins/glab/commands/` and no `plugins/glab/skills/plan-first/`: `claude --plugin-dir ./plugins plugin details glab` (under the *Gates* `CLAUDE_CONFIG_DIR` rule) prints `glab 0.13.0` and `Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship` — one fewer than the `Skills (14)` of `5a72155`; the new skills gate prints its fourteen lines with no `MISSING`; every AGENTS.md gate is green as A1 lists; every posts block prints only `ok`; and the searches of A2 and A3 return what they name. The test that proves it is A1–A3.

## Findings

The three audits beside this file are the findings for request 2: `audit-a-model.md` (A1–A30), `audit-b-agents.md` (B1–B33), `audit-c-shared.md` (C1–C18), each finding with its evidence and P/I label. *Disposition* below settles each by id. The two plan checks, `check-repo.md` (R1–R11) and `check-facts.md` (F1–F12), are settled in *Plan-check findings*. What follows is the evidence for requests 1, 3 and 4 and for the decisions.

### Proven

- **F1 — the eight command files** (`plugins/glab/commands/*.md`, HEAD `5a72155`). Frontmatter of every file is exactly `description:` and `argument-hint:`; none sets `allowed-tools`, `model`, `name`, `disable-model-invocation` or `user-invocable` (`grep -n -i -E 'allowed-tools|^model:|disable-model|user-invocable' plugins/glab/commands/*.md` printed nothing for those keys). `$ARGUMENTS` is used in analyze, commit, develop, integrate, plan, push, review and ship. Sizes 839–7836 bytes.
- **F2 — skills accept every key the commands use.** https://code.claude.com/docs/en/skills frontmatter table: `description`, `argument-hint`, `allowed-tools`, `model`; `$ARGUMENTS` — "All arguments passed when invoking the skill", and "Both you and Claude can pass arguments when invoking a skill". Same page: "Custom commands have been merged into skills."
- **F3 — a plugin skill is `/glab:<name>`.** https://code.claude.com/docs/en/skills: "`my-plugin/skills/review/SKILL.md` → `/my-plugin:review`". https://code.claude.com/docs/en/plugins-reference standard layout: `commands/` — "Prefer `skills/` for new plugins".
- **F4 — `disable-model-invocation` and `user-invocable`.** https://code.claude.com/docs/en/skills: `disable-model-invocation: true` keeps Claude from invoking a skill through the Skill tool — it **would stop `glab:manager` invoking that stage** — and "prevents the skill from being preloaded into subagents"; `user-invocable: false` hides it from the `/` menu. Defaults (`false`, `true`) are what this change needs.
- **F5 — the count.** Baseline on `5a72155`: `Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship` — the CLI already counts the eight commands as skills. On the tree this plan builds (throwaway export, the amendment of 2026-11-13): `Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship`, `Agents (7)`, `Hooks (4)`, `glab 0.13.0`, three `✔ Validation passed`.
- **F6 — the build simulated.** Every step of this plan was applied from its blocks to a `git archive HEAD` export under `$TMPDIR` (removed afterwards); every post printed its value, every A1 gate was green, and each post went red with its own edit skipped (*Tests*).
- **F7 — existing skills carry a bare `name:`** equal to their directory; with `name: <n>` on the stage skills and `name: plan` on the merged skill, the name gate printed no line, `rc=1`.
- **F8 — references to the component "command"** that must change: `AGENTS.md:11`, `:71`, `:131` (inside the *One fact* bullet, R1), `:303`; 30 path references in *One fact* (R1 rewrites them); `README.md:9`, `:12–13`; `.claude-plugin/marketplace.json:11`; `plugins/glab/skills/manager/SKILL.md:3`, `:153`, `:186`, `:197`, `:231`, `:286`; `plugins/glab/.claude-plugin/plugin.json:3` `0.12.0`.
- **F9 — what keeps the word.** `hooks.json` `"type": "command"`; `reviewer.md:34` and `committer.md:23` (`?? .claude/commands/` is an example); `README.md:160–170`, the migration steps from the old copy install, which name `~/.claude` paths (`skills/plan-first/`, `commands/*.md`) as they exist on a machine that installed that way; every `/glab:<name>` reference of a stage skill; `tests/`, `host.example.md` (none).
- **F10 — baseline gates green** on `5a72155`: five `rc=0`; shellcheck `rc=0`; `PASS 35/35`, `PASS 24/24`; the plugin block as A1 lists for 0.12.0; hooks `:0 :0 rc=1`; `not yet confirmed` `1 1 1 rc=0`; seven model lines `rc=0`; name gate `rc=1`.
- **F11 — commands already reach the Skill tool** in this session's skill list (`analyze` … `ship`, from `~/.claude/commands/*.md`).
- **F12 — the preload channel exists for plugin agents.** https://code.claude.com/docs/en/sub-agents frontmatter table: "`skills` — Skills to preload into the subagent's context at startup. The full skill content is injected, not only the description"; `tools` row: "To preload Skills into context, use the `skills` field rather than listing `Skill` here"; "up to the first 32 distinct names"; a missing skill is skipped with a debug-log warning. https://code.claude.com/docs/en/plugins/components, *Frontmatter fields in plugin agents*: "Supported fields: `name`, `description`, `model`, `effort`, … `tools`, `disallowedTools`, `skills`, …". Neither page shows how a plugin skill is named in the list.
- **F13 — validation does not check the list.** Throwaway copy: `skills:` with `glab:security`, `glab:comments`, `glab:audit` on `reviewer.md` and `glab:no-such-skill` on `analyzer.md` → `claude plugin validate --strict plugins/glab` printed `✔ Validation passed`, `rc=0`; `plugin details glab` showed the same on-invoke sizes as the unchanged tree — it neither checks nor counts the preload.
- **F14 — the skills gate (R2a) discriminates.** On a throwaway copy with `glab:security,glab:comments,glab:audit` (reviewer), `glab:security,glab:no-such` (analyzer), `other:security` (committer) it printed the four good entries and `analyzer.md:glab:no-such MISSING`, `committer.md:other:security MISSING`. On today's tree it prints nothing (no `skills:` yet).
- **F15 — first-person voice in the commands:** `grep -o -w -E 'me|my|mine|I'` counts analyze 4, develop 12, integrate 2, plan 9, push 13, review 4, ship 10 (54); commit 0.
- **F16 — the hook text round-trips:** `diff <(sed -n 12,24p plugins/glab/scripts/manager-bootstrap.sh) <(bash … | jq -r .hookSpecificOutput.additionalContext)` printed nothing, `rc=0` — H1's post can compare the block with the hook's output.
- **F17 — the stage blocks keep the user's waits** (`go-ahead`, `main`, `Approval`, `ask-condition`) in push, commit and develop, and no first person (A3).
- **F18 — `plan-first` on `5a72155`**, outside `docs/specs/` and `plan/`: `git grep -c plan-first -- ':!docs/specs/' ':!plan/'` prints 42 matches in 12 files (`AGENTS.md:11`, `README.md:2`, `bootstrap/SKILL.md:2`, `manager/SKILL.md:7`, `plan-first/SKILL.md:1`, `plan-first/implement.md:1`, `audit/SKILL.md:3`, `commands/plan.md:4`, `commands/develop.md:3`, `developer.md:1`, `planner.md:6`, `plan-analyzer.md:1`) — B3's control for A3's rename search.
- **F19 — `plan-first/` holds `SKILL.md` and `implement.md` only**, both tracked (`ls -R`, `git ls-files`); no `references/`.

### Inferred

- **I1** — On update to 0.13.0 an installed `glab` loses `commands/` and `skills/plan-first/` and gains the stage skills under the same `/glab:<name>`, so nothing is listed twice: a new version is a new cache directory, and a running session keeps 0.12.0's components until its next start or `/reload-plugins` (https://code.claude.com/docs/en/plugins/loading, *Cleanup of previous versions*, *When auto-update runs*; no install run).
- **I2** — With no `disable-model-invocation`, the model may load `glab:push` or `glab:commit` on its own, as it could the commands (F11); push still waits at step 7 for the user's go-ahead, and commit never pushes. `glab:plan` keeps `glab:plan-first`'s triggers, so a session may load it on a build request as it could load `glab:plan-first`.
- **I3** — The preload costs context per dispatch: by `plugin details`' on-invoke estimates, `glab:security` ~3k, `glab:comments` ~1.3k, `glab:audit` ~0.8k, `glab:plan` ~3.4k tokens, on top of each agent's ~0.5–2.9k. In exchange the agent files and every dispatch drop their copies. The manager session pays too: each stage skill it invokes with a new argument — a slug, `<slug>/<nn>-<name>` — appends that skill's full body again (0.8–7.8 KB each); an identical re-invocation adds only a short note, and compaction keeps at most 5,000 tokens per skill within 25,000 in all (https://code.claude.com/docs/en/skills, *Skill content lifecycle*; `check-facts.md` F11). This bears on the 300k compact step.
- **I4** — A preload renders a skill with empty arguments (`check-facts.md` F12, CLI 2.1.310 code), so the planner's preloaded `glab:plan` shows its `$ARGUMENTS` hook empty; PF1 words the hook so that an empty value reads as "the task its dispatch names".
- **I5** — `name: <n>` also gives a bare `/push`, `/ship`, `/develop`, … where no other command holds the name (https://code.claude.com/docs/en/skills, *How a skill gets its command name*; `check-facts.md` F7); built-in `/plan` and `/review`, and a user's own `~/.claude/commands/<n>.md`, keep theirs.

### Rejected boundaries

- `disable-model-invocation: true` on any stage skill: blocks the manager's Skill-tool call, and on `glab:plan` the planner's preload (F4).
- Keep `commands/` beside the skills: two components per name, and the request says remove the folder. (A count for that tree — `Skills (22)` in the first version of this plan — was inferred, never run; no page says how a plugin that ships both is listed.)
- Keep `glab:plan-first` beside a thin `glab:plan` wrapper: the user chose one skill (request 4).
- A `commands` or `skills` key in `plugin.json`: `skills/` is the default scan; `commands` would replace a folder that no longer exists.
- Copy the few shared rules each role needs into its agent file (A1's and C2's recommended channel): a second copy of each rule per agent, which request 2 forbids once a preload channel exists (F12).
- Add `Skill` to each agent's `tools` with a load-first line: the docs say to use `skills:` instead (F12), and a load the agent may skip is not a channel.
- Split into a master with sub-plans: the installed workflow has none here; one slug, one commit, and six disjoint slices (P9) give the same parallelism.

## Decisions

- effort: high (the user's words: "high (Recommended)"), for the session
- Q1 = A — the user: "A: plan only" (2026-11-13). `glab:plan` plans and stops at Step 4; `implement.md` is removed in P1; its one rule `glab:developer` lacked goes into `developer.md` Step 3 (D4b). No step carries another form.
- *glab:plan* — the user: "Yes, merge them" (2026-11-13). `plugins/glab/skills/plan-first/SKILL.md` moves to `plugins/glab/skills/plan/SKILL.md` with `git mv` (P1) and becomes `glab:plan` (PF0–PF11); `commands/plan.md` is removed with `git rm`, its wrapper text not carried over; Stage 1 dispatches `glab:planner` directly (M0.5, M0.6); the planner preloads `glab:plan` (AG0.6); every `plan-first` reference is renamed (M25, PL0–PL2, D7, PA5, AU3, R1, R2b).
- `README.md:164` (`:166` after P6.3) keeps `skills/plan-first/`: it is the migration step that deletes the old copy install's `~/.claude/skills/plan-first/`, a directory that keeps that name on a machine that installed that way (this one included); renamed, the step would leave it behind. A3's rename search therefore prints that one line and nothing else.
- The trivial-work line and its reason live once, in `glab:manager` Rule 1, which `glab:plan` Step 0 points at before it stops (PF2; R2-2). The user-only waiver rule lives once, in `glab:plan` *User Override* (PF9.2); `glab:manager` Stage 1 only names the manager as the one who writes `waived.md` under it, as the `/glab:plan` command had it do (M0.6; R2-1).
- FU1-1 — A rule only one role acts on lives in that role's file; Stage 1b's per-analyzer checks and their cases move into `glab:plan-analyzer` *The plan check*, and the manager keeps one pointer (A2) — the manager's decision.
- FU1-2 — A shared rule lives once, in `glab:security`, `glab:comments` or `glab:audit` (and the planner's procedure in `glab:plan`), and reaches each agent through its frontmatter `skills:` list, which plugin agents support and which needs no `Skill` tool (F12, https://code.claude.com/docs/en/sub-agents, https://code.claude.com/docs/en/plugins/components); entries are written `glab:<name>` as a YAML list — the exact name CLI 2.1.310 resolves first (`check-facts.md` F1); that the content loads is UNVERIFIED (U4, U5).
- FU1-3 — A dispatch carries only per-task facts: slug, step ids, file boundary, sub-plan paths, decisions and answers not in the plan, the round and its inputs, the temp directory, the `effort` and `model` parameters; Rule 0c, bootstrap step 2 and hook point 3 shrink to say so (M3, BS2, H1).
- FU1-4 — A stage skill is an entry point: preconditions, the agent it dispatches, a pointer. Routing, dispatch lists and gate runs are the manager stage's, which wins where they disagreed (B5, B9, B21); push keeps its own procedure and ship its verdict gate, which no manager stage holds.
- The preload lists: `glab:security` for all seven; `glab:comments` for developer, integrator and reviewer, which write or judge code and its comments; `glab:audit` for reviewer, analyzer and plan-analyzer, which rate by its *Severity Levels* and say they write no audit document; `glab:plan` for the planner, which keeps its `Skill` tool for the `glab:manager` sections `glab:plan` points at — *Pick the tier*, Rule 3, Stages 1b and 8 — none of them preloaded, and is told not to load `glab:plan` through it again (PL1; F2-9).
- `docs/constants.md` is read by the planner alone (M1, R11): the plan conforms to it, and every later agent works from that plan; no dispatch repeats it (FU1-3).
- An agent with no definition has no frontmatter, so its dispatch names `glab:security` (and `glab:audit` for findings): its one channel (M3).
- The temp directory is a value the agent cannot see, so the dispatch carries it; "never `/tmp`" is said once in each agent file that writes temp files (B10).
- Restatements of `glab:security` in agent files go once the agent preloads it (D3, D4, D6, RV2, RV3, IN3, IN4, IN6); what only the role does stays — the developer's closed list and record rules, the integrator's container rules, the committer's deny-list.
- Rule 5's report-template paste for `sonnet` and `haiku` goes (B23): the agent's own *Report* is its template, and Rule 5's report check stays the backstop; this reverses a 0.12.0 dispatch choice, not the model table.
- The plan-analyzer's step status `done` becomes `buildable` (B16); the manager matches verdicts, not step statuses.
- `glab:plan` Step 3 gains the three phases, and the manager's checklist item 2 checks Step 3's list (A5): the planner writes the shape, the manager only checks it.
- Gates and tests stay the bootstrap's (step 3) and the developer's; the manager's *Know the gates* and Stage 2 verify point at them (C12 with the owner FU1-4 gives).
- Stage skills write "the user" for the first person and "the session that runs it" for the second; every wait for the user stays — push go-ahead, force-push and upstream choices, `main` before pushing, a commit on `main`, full-tier approval, Rule 3 questions.
- Cases are kept once, next to their rule: Stage 1b's case and measurements in `plan-analyzer.md`; the DSN leak in `glab:security` *Secrets never enter output*; `make lint` / 85 mockgen in `analyzer.md` Step 4; the cached-test case stays in bootstrap step 6 with a pointer to Rule 4; the deleted-`TODO` reasoning is already `glab:comments`' (`:98`), so the manager's and bootstrap's copies go.
- The Rule 5 version history leaves the manager (A30); its exact text is kept in `steps-manager.md` M7 for the record to carry into `docs/specs/workflow.md`, and the new *Precedence* bullet names that spec without a section (R10).
- A `/glab:review` round tells the reviewer the round, and the reviewer keeps its own round-2 rule ("round 2 is the last unless you report `critical` or `high`"), because it acts on it; the analyzers only rate, so their round-3 sentence goes (A13).
- *One fact* entries shrink to the files that still state the fact, and a new entry and gate cover the `skills:` lists (R1, R2): validation passes a wrong name and `plugin details` shows none (F13).
- No stage skill and no preloaded skill sets `disable-model-invocation` or `user-invocable` (F4); `push` and `ship` get the same frontmatter as the others.
- The bare aliases of I5 are accepted: every stage skill keeps its waits for the user (push's go-ahead, a commit on `main`), so a bare `/push` asks what `/glab:push` asks; preventing them would mean dropping `name:`, which every other `glab` skill carries.
- Each stage skill's `file` block carries `name: <n>` on line 2, bare (F7); `description` and `argument-hint` stay byte-identical to the command except `develop`'s description (A4); `glab:plan` keeps the command's `argument-hint` (PF0).
- No `allowed-tools` or `model` in any stage skill: no command set one (F1), and a skill-level `model` would override the session's for the turn.
- P1 moves and removes with `git mv` and `git rm`, so history stays and its posts show eight exact renames; the `file` blocks then replace the seven stage bodies, and PF0–PF11 edit the moved `glab:plan-first`.
- Every edit is a block the developer applies as written and every edit has its own post line, which goes red when that edit alone is skipped (R1, R3, R4, R6 of `check-repo.md`; *Tests*).
- Wording outside the stage skills changes where it names the component (F8) and where *Disposition* names a step; generic "command" and every stage skill's `/glab:<name>` stay (F9).
- `commands` leaves the AGENTS.md commit-scope list; past `fix(commands)` commits stay.
- `glab` goes 0.12.0 → 0.13.0, once, in this change's one commit; `memory-sync` is untouched.
- One commit, suggested `feat(skills): move the glab commands into stage skills, merge plan-first into glab:plan and give each rule one owner (glab 0.13.0)`; the committer owns the subject.
- Stage 4 runs the milestone test — A1–A3 — as there is no service; an interactive run is the user's after install (U1, U4), since `claude -p` would spend money.
- plan check round 2: BUILDABLE on both; its 8 lows folded in by amendment, each proven red-when-skipped by the planner; no third check round (cap 2, no critical or high).
- size: `plan.md` stays under 48 KB by holding the contract only; the edits are in `steps-stages.md`, `steps-agents.md`, `steps-manager.md`, `steps-bootstrap.md`, `steps-shared.md` and `steps-repo.md`.

## Disposition

`apply` (the step ids that carry it), `merge → <id>` (carried by that finding's steps), or `reject`. None is rejected.

| id | disposition | steps |
|---|---|---|
| A1 | apply | AG0, M3, BS2, H1, P6.3; D3, D4, D6, RV1–RV3, IN3, IN4, IN6 |
| A2 | apply | PA1, M14.1 |
| A3 | apply | S3, M12, M15 |
| A4 | apply | S3, R1 |
| A5 | apply | PF5, M13.3 |
| A6 | apply | D5, M15 |
| A7 | apply | H1, BS4, R1 |
| A8 | apply | M3, M14.2, BS2; PF0, PF1 (Q1 = A) |
| A9 | merge → C12 | — |
| A10 | apply | M0.6, M1, M3, H1, S1–S4, S6–S8, R1 |
| A11 | apply | H1, BS1, BS2, M1, M2, M5 |
| A12 | apply | BS4 |
| A13 | apply | AN3, PA3, RV4, RV6, S8, BS4, R1 |
| A14 | apply | M15 |
| A15 | apply (Q1 = A) | P1 (`implement.md` removed), PF9.1, PF10, D4b |
| A16 | apply | M3, PL0, PL1 |
| A17 | apply | M7, BS4 |
| A18 | apply | PF3.1, PF6, M9 |
| A19 | apply | PF0, PF1, PF2 |
| A20 | apply | AN2 |
| A21 | apply | M20 |
| A22 | merge → B5 | — |
| A23 | apply | S6, M21 |
| A24 | merge → C11 | — |
| A25 | apply | M12, M15 |
| A26 | apply | M3, M13.2, M24 |
| A27 | apply | PF8, M11, M14.4 |
| A28 | apply | S3, BS2, R1; `glab:plan` Step 2 keeps the four (PF4) |
| A29 | apply | S1–S4, S6–S8, M15, M18, R1 |
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
| B10 | apply | D2, RV5, IN5, BS6.1, H1, M3 |
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
| B30 | apply | PF9.2, M0.6 (the waiver, once) |
| B31 | apply | PA4 |
| B32 | apply | S2, S8 |
| B33 | merge → A15 | — |
| C1 | apply | AU1, AU2, PF3.2, PF4, PF7, M13.1 |
| C2 | merge → A1 | — |
| C3 | merge → A1 | — (the developer preloads `glab:comments`) |
| C4 | merge → A6 | — |
| C5 | apply | RV1 |
| C6 | apply | SE2, BS6.2 |
| C7 | apply | IN6, D4, S3 |
| C8 | apply | SE1 |
| C9 | apply | CO1 |
| C10 | apply | P6.3 |
| C11 | apply | SE3, M15, M23, D4, RV3, S3 |
| C12 | apply | M8, M15, S3, D4 |
| C13 | apply | M2, M3, BS2, H1 |
| C14 | apply | M2, M5, BS2, H1 |
| C15 | apply | BS3, M8 |
| C16 | apply | SE4, BS6.3 |
| C17 | apply | AG0, AN3, PA3, RV4, R1 |
| C18 | apply | D3.1; P1 (`implement.md` removed, Q1 = A) |

Counts: 62 apply, 19 merge, 0 reject — 81.

### Plan-check findings

| id | where it is fixed |
|---|---|
| R1 | The Stage 1b case is searched by the one-line string `never said how the subject reached them` (posts PA1, M14.1; A3); each post's count was run on `5a72155` (manager `1`, plan-analyzer `0`) and on the built tree (`0`, `1`). |
| R2 | Every post reads only its own file; PA1's manager-side counts are M14.1's, D1's tree-wide search is A3's; each steps file's posts were run green on P1 plus that file alone (*Tests*). |
| R3, R4 | One post line or more per edit — `<step>.<n>` for each edit of a multi-edit step — each shown red with that edit alone skipped (*Tests*). |
| R5 | R1's first post compares the built *One fact* bullet with the block byte for byte; its second checks the paths of the built bullet. |
| R6 | Old texts that cross a line break are blocks with the break in them (BS6.1, BS6.2, PA1's source, M14.1). |
| R7 | R1's entries name `ship/SKILL.md` and `reviewer.md`, `analyze/SKILL.md`, and `planner.md` and `plan-analyzer.md`. |
| R8 | M14.4: the version copy is the planner's (`glab:plan` Step 4). |
| R9 | P6.3 and D5 are blocks, their wrapping and 4-space indent fixed; the posts search one-line strings. |
| R10 | M7.1 names `docs/specs/workflow.md` without a section; *Record* carries the history there. |
| R11 | Decision *`docs/constants.md` is read by the planner alone*. |
| F1 | U4's after-install check reads the debug log (U4). |
| F7 | I5 and the decision on bare aliases. |
| F8 | I1 cites the loading page; the `Skills (22)` figure is marked inferred (*Rejected boundaries*). |
| F11 | I3 counts the manager's stage-skill invocations; U7. |
| R2-1 | M0.6 names the manager as the writer of `waived.md` and points at `glab:plan` *User Override*, which alone holds the user-only rule (PF9.2). |
| R2-2 | PF2 points at `glab:manager` Rule 1 and stops; the reason stays in Rule 1. |
| R2-3 | PF3.3: *Quick Reference*'s Analyze row says what PF3.1 says. |
| R2-4 | S1: `glab:analyze` dispatches the agents the stage that runs the check names; how many, and the split, are the stage's. |
| R2-5 | R1 drops the session-start rules and the stage sequence, one file each now, so the preamble holds for every entry left. |
| R2-6 | PF11: Step 4 is what the planner confirms before the plan check; the check and the approval are the manager's, checked by `/glab:develop` (S3 *Approval*). |
| F2-9 | PL1 tells the planner not to load `glab:plan` again; it keeps `Skill` for the `glab:manager` sections `glab:plan` points at (decision on the preload lists). |
| F2-10 | R2a also requires `name: <name>` in the skill's `SKILL.md`; R2b says so. |

## Steps

Every shell step: `export TMPDIR=/data/tmp/claude` first; `/usr/bin/grep`, not `grep`; any `claude` command only inside the AGENTS.md `CLAUDE_CONFIG_DIR` block. Run from the repo root.

### Block formats

Every edit in this plan and in the six steps files is a fenced block whose first line is `~~~ <id> <kind> [<path>]`; the block ends at the next line that is exactly `~~~`. A block's text is its lines joined by line breaks. A line inside a block may begin with a space; the space is part of the text.

- `file <path>` — write the file at `<path>` as the block's lines, each ended by a line break, and nothing else.
- `old <path>`, followed by `new` with the same id — the old text occurs exactly once in `<path>`, as written, with no line break after its last line; replace it with the new text, built the same way. An empty `new` block deletes the old text.
- `delete <path>` — these whole lines, each with its line break, occur exactly once in `<path>` as consecutive lines; remove them.
- `run` — run the lines from the repo root in one `bash -e` shell.

Apply a file's blocks in the order written. When an `old` or `delete` text is not found exactly once, stop and report `PLAN WRONG: <id>`; do not search for something close. Line numbers in the prose are for orientation only.

### Posts

Each steps file, and this one, ends with a `~~~ posts` block: one check per line, `<id> | <expected output> | <command>`, where `<id>` is the edit it checks. Run a block with this function, from the repo root:

    posts() { awk '$1=="~~~" && $2=="posts"{f=1;next} f && $0=="~~~"{f=0} f' "plan/flow-commands-to-skills/$1" | while IFS= read -r l; do [ -n "$l" ] || continue; id=${l%% | *}; r=${l#* | }; want=${r%% | *}; cmd=${r#* | }; got=$(bash -c "$cmd" 2>&1); if [ "$got" = "$want" ]; then echo "ok $id"; else echo "RED $id: want [$want] got [$got]"; fi; done; }

After each edit, `posts <its file>`: that edit's lines turn from `RED` to `ok`. After a file's last edit every line prints `ok`. A line that prints `ok` before its edit is made cannot tell the edit from its absence: stop and report `PLAN WRONG: <id>`.

### before

- **B1 — Confirm the starting tree.** `git status --short -uall -- plugins AGENTS.md README.md .claude-plugin` prints nothing, and `git ls-files --error-unmatch plugins/glab/skills/plan-first/SKILL.md plugins/glab/skills/plan-first/implement.md plugins/glab/commands/plan.md >/dev/null; echo "rc=$?"` prints `rc=0` — every file P1 removes is tracked, so recoverable from git. Otherwise stop and report.
- **B2 — Run the AGENTS.md gates once** (script gates and plugin-gate block, verbatim from *Gates*) and keep the output. Post: the F10 results. A red gate stops the build before any edit.
- **B3 — Controls, on the unchanged tree.** `git grep -c plan-first -- ':!docs/specs/' ':!plan/'` prints the twelve files of F18, 42 matches; `posts plan.md` prints only `RED` lines. A different result means the plan is stale: stop and report `PLAN WRONG`.

### processing

- **P1 — Move and remove.** The seven stage commands move to their stage skills, `glab:plan-first`'s `SKILL.md` moves to `glab:plan`'s place, and the command `plan.md` and `implement.md` are removed — all through git, so history stays; git removes the two directories it leaves empty. Never `rm -r`.

~~~ P1 run
for n in analyze commit develop integrate push review ship; do mkdir -p plugins/glab/skills/$n && git mv plugins/glab/commands/$n.md plugins/glab/skills/$n/SKILL.md; done
git rm -q plugins/glab/commands/plan.md
mkdir -p plugins/glab/skills/plan && git mv plugins/glab/skills/plan-first/SKILL.md plugins/glab/skills/plan/SKILL.md
git rm -q plugins/glab/skills/plan-first/implement.md
~~~

  Then, before any other edit, run `posts` on each of the six steps files: every line prints `RED`.

- **P6 — `README.md`** (with C10). The table row (`:9`): `glab:plan-first` leaves the skills, and the commands become stage skills, with `/glab:plan` as the planning procedure a person can type:

~~~ P6.1 old README.md
`glab:comments`, `glab:plan-first`, `glab:audit` · agents
~~~
~~~ P6.1 new
`glab:comments`, `glab:audit` · agents
~~~

~~~ P6.2 old README.md
· commands `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`, `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship` ·
~~~
~~~ P6.2 new
· stage skills `/glab:develop`, `/glab:analyze`, `/glab:integrate`, `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship`, which `glab:manager` runs itself and you can type to step in · `/glab:plan <task>`, the planning procedure `glab:planner` follows, which you can type to plan in your own session ·
~~~

  The paragraph after the table (`:12-16`):

~~~ P6.3 old README.md
In `glab` the skills, agents and commands are one set: `glab:manager`
dispatches the agents through the commands, and every agent carries
`glab:security` and `glab:comments`, and runs at the session's effort level,
which the manager passes on every dispatch. The two plugins do not depend on
each other; install either alone.
~~~
~~~ P6.3 new
In `glab` the skills and agents are one set: `glab:manager` runs each stage
through its stage skill, which dispatches the agents, and dispatches
`glab:planner` itself for the plan. Each agent preloads, through the `skills:`
list in its definition, the `glab` skills its role uses — `glab:security` in
all seven, `glab:plan` in the planner — and runs at the session's effort level,
which the manager passes on every dispatch. The two plugins do not depend on
each other; install either alone.
~~~

  `:160-170`, the old copy install's migration steps, stay (F9; decision on `README.md:164`).

- **P7 — `.claude-plugin/marketplace.json`**, the `glab` entry's `description`:

~~~ P7 old .claude-plugin/marketplace.json
The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook
~~~
~~~ P7 new
The glab workflow: skills, agents, the session bootstrap hook and the context hook
~~~

- **P8 — `plugins/glab/.claude-plugin/plugin.json`**, the version:

~~~ P8 old plugins/glab/.claude-plugin/plugin.json
"version": "0.12.0"
~~~
~~~ P8 new
"version": "0.13.0"
~~~

- **P9 — Run the six steps files**, each edit followed by its posts. Their file boundaries are disjoint and each reads only its own files, so the manager may give each its own developer (*Running agents in parallel*); one developer runs them in this order:
  1. `steps-stages.md` S1–S4, S6–S8 — the seven stage `SKILL.md`;
  2. `steps-agents.md` AG0, PL0–PL2, D1–D7, AN1–AN3, PA1–PA5, RV1–RV6, IN1–IN6, CM1 — `plugins/glab/agents/`;
  3. `steps-manager.md` M0–M25 — `glab:manager`;
  4. `steps-bootstrap.md` BS1–BS6, H1 — `glab:bootstrap` and the hook script;
  5. `steps-shared.md` SE1–SE4, CO1, AU1–AU3, PF0–PF11 — security, comments, audit, plan;
  6. `steps-repo.md` R0–R2 — `AGENTS.md`.
  Post: `posts` on each of the six files prints only `ok` lines.

~~~ posts
P1 | gone | test ! -e plugins/glab/commands && test ! -e plugins/glab/skills/plan-first && echo gone
P1 | analyze audit bootstrap comments commit develop integrate manager plan push review security ship | ls plugins/glab/skills/*/SKILL.md | sed 's|^plugins/glab/skills/||; s|/SKILL.md$||' | paste -sd' ' -
P1 | 8 | git diff --cached -M --name-status | /usr/bin/grep -c '^R100'
P1 | 2 | git diff --cached -M --name-status | /usr/bin/grep -c '^D'
P6.1 | 1 | /usr/bin/grep -c -F '`glab:comments`, `glab:audit` · agents' README.md
P6.2 | 1 | /usr/bin/grep -c -F '· stage skills `/glab:develop`' README.md
P6.3 | 1 | /usr/bin/grep -c -F 'through its stage skill, which dispatches the agents, and dispatches' README.md
P7 | The glab workflow: skills, agents, the session bootstrap hook and the context hook | jq -r '.plugins[0].description' .claude-plugin/marketplace.json
P8 | 0.13.0 | jq -r .version plugins/glab/.claude-plugin/plugin.json
~~~

### after

- **A1 — Run every AGENTS.md gate**, verbatim from the new *Gates*. Expected:
  - script gates: five `rc=0` lines; shellcheck `rc=0` with no findings; `PASS 35/35` and `PASS 24/24`, every line `ok` (H1 changes only the heredoc text of a hook script);
  - plugin gates: three `✔ Validation passed`; `  Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship`; `  Agents (7)` with the seven agents in any order; `  Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop` with its trailing note; for `memory-sync` `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
  - `glab = glab`, `memory-sync = memory-sync`;
  - `plugins/glab/hooks/hooks.json:0`, `plugins/memory-sync/hooks/hooks.json:0`, `rc=1`;
  - `not yet confirmed`: `1` after each of the three files, `rc=0`;
  - model gate: exactly the seven lines AGENTS.md lists, `rc=0`;
  - skills gate: exactly the fourteen lines of R2b, in that order, none `MISSING`;
  - name gate: no line, `rc=1`.
  Also, inside the same `CLAUDE_CONFIG_DIR` block, `"$claude" --plugin-dir ./plugins plugin details glab | head -n 1` prints `glab 0.13.0`.
- **A2 — The reference sweep.** `/usr/bin/grep -rn -E 'commands/' plugins README.md AGENTS.md .claude-plugin tests host.example.md` prints exactly `plugins/glab/agents/reviewer.md:36`, `plugins/glab/agents/committer.md:25` (the `?? .claude/commands/` examples) and `README.md:169`–`:172`, the four lines of the old copy install that list `commands/plan.md` … `commands/ship.md` (F9).
- **A3 — Ownership and rename searches**, each printing what it names:
  - `for f in plan.md steps-stages.md steps-agents.md steps-manager.md steps-bootstrap.md steps-shared.md steps-repo.md; do posts $f; done | /usr/bin/grep -c '^RED'` prints `0`;
  - `git grep -n plan-first -- ':!docs/specs/' ':!plan/'` prints exactly one line, `README.md:166:` — HEAD's `:164`, two lines down after P6.3 (decision on `README.md:164`);
  - `/usr/bin/grep -rn 'implement\.md' plugins README.md AGENTS.md; echo "rc=$?"` prints only `rc=1` (Q1 = A);
  - `/usr/bin/grep -rl -E 'even when the agent definition already requires it|Say all of it in the dispatch|say all of it, in every dispatch' plugins; echo "rc=$?"` prints only `rc=1` (FU1-3);
  - `/usr/bin/grep -rl -F 'never said how the subject reached them' plugins` prints exactly `plugins/glab/agents/plan-analyzer.md` (A2);
  - `/usr/bin/grep -rl -F 'unbounded memory growth' plugins/glab` prints exactly `plugins/glab/skills/audit/SKILL.md` (C17);
  - `/usr/bin/grep -rl -E -- '--fix' plugins/glab` prints exactly `plugins/glab/skills/security/SKILL.md` (C11);
  - `/usr/bin/grep -rl 'Proven\*\* —' plugins/glab` prints exactly `plugins/glab/skills/security/SKILL.md` (C1);
  - `/usr/bin/grep -rn 'no contract' plugins` prints only `developer.md`'s `BLOCKED: no contract` line (B1, B2);
  - `/usr/bin/grep -c -w -E 'me|my|mine|I' plugins/glab/skills/{analyze,commit,develop,integrate,push,review,ship}/SKILL.md` prints `:0` for all seven (54 in the commands, F15);
  - `/usr/bin/grep -c -E 'go-ahead|force-push|main|Approval|ask-condition' plugins/glab/skills/{push,commit,develop}/SKILL.md` prints a count of 1 or more for each — the user's waits are still there;
  - `bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext | wc -c` prints less than `10000`.
- **A4 — The change's footprint.** `git status --short -uall -- . ':!plan/'`.
  Post: eight renames — seven `RM` `plugins/glab/commands/<n>.md -> plugins/glab/skills/<n>/SKILL.md` and `RM plugins/glab/skills/plan-first/SKILL.md -> plugins/glab/skills/plan/SKILL.md`; `D plugins/glab/commands/plan.md` and `D plugins/glab/skills/plan-first/implement.md`; and ` M` for exactly: `AGENTS.md`, `README.md`, `.claude-plugin/marketplace.json`, `plugins/glab/.claude-plugin/plugin.json`, `plugins/glab/scripts/manager-bootstrap.sh`, the seven `plugins/glab/agents/*.md`, and `SKILL.md` of `manager`, `bootstrap`, `security`, `comments`, `audit`, plus `plugins/glab/skills/audit/references/plan-template.md`. Nothing under `docs/specs/`, `plugins/memory-sync/` or `tests/`.
- **A5 — Clean up** every temp file the build made under `$TMPDIR`; the gate block removes its own config dir.
  Post: `ls /data/tmp/claude | /usr/bin/grep -c -E 'claude-config'` prints `0` for directories this build created (report any that predate it rather than removing them).

## Tests

No test file changes: the one script change is heredoc text, run by the script gates; `tests/*.test.sh` run as gates only. Coverage, as a list:

- Every edit — P1, P6.1–P8, and every block of the six steps files — has its own post lines (*Posts*), and each was shown to discriminate on a throwaway export of `5a72155` built from these blocks (2026-11-13): with all edits applied every post printed its value; with any one edit skipped and every other applied, that edit's post lines printed something else; each steps file's posts held on P1 plus that file alone (R2). Result: 140 edits and 171 post lines; all edits applied, 171 of 171 printed their value, and each printed `RED` before its edit and `ok` after it; with one edit skipped, in 140 builds, 171 of 171 lines went red and no other line did (skipping P1 also leaves PF0–PF11 without their file and R1's paths unmet); each steps file on P1 plus itself alone, 0 red. The round-2 amendments (M0.6, PF2, PF3.3, PF11, S1, PL1, R1, R2a, R2b) were each also built with only that amendment taken back to its `.r2.md` text: its own new or changed post lines went red, every other line stayed `ok`. On that tree every A1 gate printed what A1 lists, A2–A4 printed what they name, and `plugin details glab` printed `glab 0.13.0` and `Skills (13)`.
- S1–S4, S6–S8: the block `diff` (posts), the voice and waits searches (A3).
- AG0: per-agent `skills:` lists (posts) and the skills gate (A1), whose discrimination F14 showed.
- H1: its round-trip `diff` (F16) and the script gates.
- R1: the byte-for-byte `diff` and the path check of the built bullet (posts).
- The merge: `Skills (13)` (A1), the rename search (A3), the footprint (A4).
- Not covered by any case: that a typed `/glab:<name>` and the manager's Skill-tool call run the moved skills (U1, U2), and that the `skills:` preload injects the plugin skills into a plugin agent (U4, U5). Accepted: the docs state each (F2–F4, F12), and a runtime check needs an interactive session or a paid `claude -p` run.

## Not verified

- **U1** — UNVERIFIED: typing `/glab:<name>` runs the moved skill with `$ARGUMENTS` — docs (F2, F3) and `plugin details` only. The user can check after installing 0.13.0 with `/glab:review`.
- **U2** — UNVERIFIED: `glab:manager`'s Skill-tool call on `glab:<name>` loads the plugin skill with its argument — docs (F2, F4) and F11 only.
- **U3** — UNVERIFIED: an installed copy updated to 0.13.0 drops the old commands and `glab:plan-first` with no duplicate listing (I1) — no install may be run from this repo.
- **U4** — UNVERIFIED: a plugin agent's `skills:` entry written `glab:security` preloads that plugin skill's full content — the docs name the field for plugin agents but show no plugin-skill name form (F12); validation and `plugin details` do not resolve it (F13); CLI 2.1.310's code resolves the exact name first (`check-facts.md` F1, a code reading, not a run). After install the user can run `claude --debug`, dispatch one `glab` agent, and search the debug log: `Preloaded skill 'glab:security'` present, and `specified in frontmatter was not found` absent.
- **U5** — UNVERIFIED: the preload works for an agent whose `tools` list lacks `Skill` — documented in the sub-agents `tools` row (F12); the run is the U4 check.
- **U6** — UNVERIFIED: `${CLAUDE_PLUGIN_ROOT}` in `glab:bootstrap` step 1 is substituted when the skill loads — documented for "Skill, command, and agent content" (https://code.claude.com/docs/en/plugins-reference, *Environment variables*), not run.
- **U7** — UNVERIFIED: the context cost of I3 — the preload per dispatch and the manager's stage-skill invocations — from `plugin details` estimates and the docs; no transcript was measured.
- **U8** — UNVERIFIED: a typed `/glab:plan <task>` substitutes the task into PF1's hook, and the preloaded copy renders it empty (I4) — docs (F2) and a code reading only.

## Record

After the push, the record stage updates `docs/specs/workflow.md` — the stage skills, the merge of `glab:plan-first` into `glab:plan`, F4's invocation decision, FU1-1 to FU1-4 and the preload lists, the B23 reversal, Q1's answer, U1–U8, and the Rule 5 version history kept verbatim in `steps-manager.md` M7 (the spec already holds it under *How it works now*; R10) — and `docs/specs/marketplace.md` — the layout, the *Gates* `Skills (13)` line and the new skills gate, the commit-scope list, the *One fact* changes of R1, the `README.md:164` exception. This plan edits no spec.
