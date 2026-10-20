tier: normal — payload Markdown, one manifest version, and one read-only hook script that prints a single number; no schema, data, stored or wire format, auth, secrets or money (no script parses an agent report: F13; the hook emits nothing of the transcript but an integer: D36)

# flow-cheaper-rounds — cheaper rounds in the glab pipeline

Seven changes to `glab:manager` and `glab:plan-first`, to the `glab` hooks,
and to every file that states the same facts, to cut the token cost of the
pipeline:

1. round caps of 2 (+1 on a critical or high finding) for Stages 1b, 3 and 5;
2. every round goes to a new agent, never a resumed one;
3. re-checks of Stages 1b and 3 look only at the delta;
4. a narrower planner search (call-site audit for changed methods only);
5. explore once (mapping files, or the planner explores, not both);
6. the manager knows its own context and suggests `/compact` or `/clear`;
   the user does it;
7. one script, `plugins/glab/scripts/context-size.sh`, on three new `glab`
   hook events: `UserPromptSubmit` and `PostToolUse` on `Agent` give the
   model its context size on every user message and every dispatch, and
   `Stop` tells the user when a turn crosses 300k or a further 100k — the
   measurement item 6 reads (the user's decision, plan round 2: D29, D45).

Under `glab:manager` this plan stops here: it is not implemented by its
author (the `glab:plan-first` seam). Base: `7df69a8` on `main`.

Plan round 2 (item 7) was written by a new planning agent; `plan.r1.md` is
the plan as it stood before this amendment (D10's copy), so the next plan
check reads `diff -u plan.r1.md plan.md`. Decisions changed by round 2: D1, D17,
D18, D19 (fixed steps, D47), D20, D21, D22, D25, D27, D28 and the
*Boundary*'s rejected (a); added: D29–D48. Kept unchanged: every other
decision, including the version D26.

## Decisions

- D1 tier normal — payload text, the `glab` manifest version, `AGENTS.md`, `README.md`, and since round 2 one hook script with its test; no full-tier trigger (*Pick the tier*; for the hook, D36). The new `severity:` line in two report templates is a prompt-level contract between agents: nothing parses it (F13), and the verdict lines `/glab:ship` matches whole keep their form. *(Changed in round 2: the hook and README added.)*
- D2 Round caps — the user's decision, relayed by the manager: "set 2 and only one more if something critical is behind". Stage 1b, Stage 3 and Stage 5 each run at most 2 rounds at every tier where the stage runs; a third only when round 2 returned a `critical` or `high` finding, recorded first as `- round 3: <stage> — <severity> <finding as file:line or step id, and its claim>` under `## Decisions`; nothing past round 3. Normal tier still has no Stage 3. It supersedes `[bug-reviewer-findings/questions.md Q3]` ("3 everywhere"), `[feature-plugin-marketplace/questions.md S3]` and `[sync-local-edits/result-followups.md D11]` (the 1b *Leaves on* wording).
- D3 "critical **or high**", not "critical" alone — the manager's choice: the real case that needed a third round was rated high. The user may overrule it; then only the word list in D2's files changes.
- D4 The severity is given by the agent that reports the finding — `glab:reviewer`, `glab:analyzer` — as a `severity:` line on each finding, on `glab:audit`'s four *Severity Levels*, and never re-ranked by the manager. `review.md:10` and `ship.md:18` already say "do not re-rank its severities", yet the reviewer's template (`reviewer.md:81-84`) has no severity (F3); this gives the round-3 condition a value someone other than the manager sets.
- D5 Reviewer round 2: it is the last round unless the reviewer reports a `critical` or `high` finding in it; then it answers `BLOCK: <n> issues` and round 3 may run, which is the last with no exception. The verdict strings do not change (`AGENTS.md` *One fact*: the verdict lines).
- D6 What happens when a stage ends its last round without passing stays what it is today for that stage and tier: 1b full → the user ("needs a design"); 1b normal → after round 2 a new planner amends once more and the plan goes on, `PLAN WRONG` the backstop; after a round 3, at every tier → the user; Stage 3 → the user with the three honest resolutions; Stage 5 → the last-round answer goes to the user. Only the round counts change.
- D7 Every round is a new agent: a plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a Stage 8 record fix — never a resume or a follow-up to the previous agent. Wider than the brief's two cases (planner amendment, developer fix) so that the rule has no unexplained gap; the cost reason (F1) is the same for each. Rule 5's report check (missing fields only) stays the one resume (`[feature-model-switch/plan.md D22]` binds). It goes in Rule 2, the context budget, because its reason is cost.
- D8 A round's findings travel in the next agent's dispatch, copied as the agent returned them — the one input not on disk. The manager writes no findings file (Rule 1: it authors no content), and neither the analyzer nor the reviewer can (read-only; the reviewer gets no slug).
- D9 A fix-round developer adds `## Fix round — <stage> round <n>` to `result.md` and does not overwrite it; the overwrite rule (`developer.md:68`) stays for a re-dispatch of the same steps. Otherwise a fresh fix agent erases the record of the round before (the incident "a re-dispatch overwrites `result.md`", `docs/specs/workflow.md` *Incidents*).
- D10 Stage 1b delta: before dispatching the amendment the manager copies `plan.md` (and `findings.md` when there is one) to `plan.r<n>.md` (`findings.r<n>.md`), `<n>` = the round that checked it; round `<n+1>` reads `diff -u plan.r<n>.md plan.md`. A copy, not git: the plan folder is untracked while it is planned (`?? plan/flow-cheaper-rounds/plan.md` in this tree), and a snapshot of a gitignored `plan/` would be silently empty. Proven in a throwaway directory (F8). The copies stay in the folder (`AGENTS.md`: no untracked file under `plan/` is removed) and are committed with it; the record takes items from the current file, not the copy.
- D11 Stage 3 delta: before each analyze round, round 1 included, the manager snapshots the tree into a tree object through a temporary index (`GIT_INDEX_FILE=<new path> git add -A && git write-tree`); round `<n+1>` gets both tree ids and runs `git diff <old> <new>`. Proven: it catches tracked, staged, untracked and deleted files, leaves the real index and `git status` unchanged, skips ignored files, and gives the same id for the same tree (F8). Ignored files are not in a snapshot, so a path the fix round's `files:` line names that the delta does not show is checked whole; a lost tree id means that round runs whole.
- D12 An empty delta is a stop, not a pass: `diff` and `git diff --quiet` exit 0 when nothing changed. Before round `<n+1>` the manager checks the delta is not empty; an analyzer handed an empty one reports `BLOCK: target unresolved`.
- D13 Review rounds are not changed. The brief says they stay whole-target; note that the payload already narrows each review round after the first to what changed since the last one (`reviewer.md:94`, `ship.md:32`), and this plan leaves that text exactly as it is. If "whole-target" meant something else, that is the manager's to raise.
- D14 Planner search: the full call-site audit covers methods the plan **changes**; for a method it only **calls**, the precondition the new call site must meet and how the plan meets it; a file it only depends on is listed by path and not read in full. Consistent with `glab:security` Rule 7, which binds before "changing any existing function's signature, return values, error cases, or timing" (`security/SKILL.md:72`), and with `reviewer.md:55` and `developer.md:40` (both: before a change). `glab:manager`'s checklist item 3 says the same.
- D15 Mapping files are `plan/{slug}/map-<area>.md`, not `findings-<area>.md`: in this session the Write tool refused a subagent's `findings-probe.md` and `findings.md` ("Subagents should return findings as text, not write report files") and accepted `map-probe.md` (F9) — the same refusal as two recorded incidents (`subagent-effort`, `remove-external-agents`).
- D16 Mapping is the manager's call per task. When it dispatches mapping agents, the planner is told the files, starts from them, and reads code only for the gaps it names; without them, the planner explores itself; never both over one area. The analyzer reads the map files with the plan, and the developer the ones the plan cites, because a plan step may cite one.
- D17 *Superseded by D29 in round 2.* Was: the manager measures its context with one inline command in `glab:manager`, not a script, because a skill's text cannot name the installed plugin's directory from the model's shell and a new script joins the `AGENTS.md` shell gates and needs a test. Item 7 answers the first — a hook command gets `${CLAUDE_PLUGIN_ROOT}` substituted (F20) — and accepts the second (S13–S15). The manager now runs no command for its context: it reads the hook's line. F15 stays as the record of round 1's command.
- D18 *Superseded by D30 in round 2.* Was: the command finds the transcript by `CLAUDE_CODE_SESSION_ID` under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/*/`, requiring one match. The hook is handed `transcript_path` instead (F20), so no variable, no directory search and no knowledge of the directory naming are needed. Kept from D18: one number and nothing else from the transcript, never `0`, `0k` or `null` (D33, D34).
- D19 *(Steps changed in round 2 by D47.)* Thresholds: inside a task, suggest `/compact` at the first handoff line at or past **300k**, and again each time the context has grown by another **100k** since the last suggestion. 300k is where a resumed agent's round already cost several times a fresh one (F1: rounds restarting at 300–450k), and about half the bad session's 648k peak; the 100k step keeps a declined suggestion from repeating on every line. At a task boundary — after the push of the Stage 8 record, or after Stage 7 when there is no plan folder — suggest `/clear` and a new session whatever the size.
- D20 Fallback when there is no measurement — *changed in round 2*: the trigger is that no `glab: context` line has come at all in the session, neither with a user message nor with an Agent result (D38 lists why that happens), where round 1 had the inline command's non-zero exit: say so once in the session, then suggest `/compact` after every **15** dispatches since the session started or was last compacted, and after any stage that took more than one round. 15: the brief's figure; one normal-tier task at the new caps dispatches about 8–12 agents (plan, 1–2 plan checks, develop, 1–2 reviews, fix rounds, commit, record developer and analyzer, record commit), so 15 fires about once per long task — inferred from the stage list, not measured.
- D21 The handoff line gains `· context <n>k` at its end, `<n>` copied from the most recent `glab: context <n>k` line in the manager's context, or `· dispatches <d>` under the fallback; the manager names the number as "the last completed call's context" and never claims more precision. The manager never runs `/clear` or `/compact`. *(Changed in round 2: the number's source is the hook's line, not a command.)*
- D22 The handoff file is the one `glab:bootstrap` step 5 reads — `plan/SESSION-HANDOFF.md` unless the repo keeps its handoff elsewhere (`bootstrap/SKILL.md:127`: "or the nearest equivalent in `plan/`"). No `glab` step commits it. `glab:bootstrap` and `manager-bootstrap.sh` do not change for items 6 and 7: step 5 already names the file, the `SessionStart` text carries no handoff, compaction or context text (F16), and the new hook is a separate script with its own text, so the session-start pair of *One fact* is untouched. *(Changed in round 2: item 7 added to the reason.)*
- D23 Rule 5 carries the model into each fix round too (a new agent no longer inherits it from a resume): Rule 5's carry bullet and `develop.md:42`.
- D24 The handoff line's `max` is the stage's cap: `2`, or `3` once the round-3 line is written; a develop line counts its fix rounds against the cap of the stage whose findings it fixes; Rule 5's example becomes `round 1/2`.
- D25 `AGENTS.md` *One fact*: the review-round-cap entry becomes "the round caps" (all three stages, the same four files; it closes `[sync-local-edits/follow-ups.md 18]`); new entries: the severity levels, every round a new agent, the mapping and round-copy file names, the handoff file, and since round 2 the context line of the `glab` hook (D40).
- D26 `glab` `0.8.0` → `0.9.0`: the change alters the pipeline's contract (round caps at both tiers, two report templates, the reviewer's round-2 rule, a new handoff-line field), a feature, and features have raised the minor before 1.0 (`0.5.0`, `0.6.0`, `0.7.0`, `0.8.0`). Nothing is removed, so no `!`. `memory-sync` is not touched and keeps `0.1.0`.
- D27 One commit, `feat(skills): cap check rounds at two and run each round on a new agent`, with the plan folder, its body naming the context hook as one bullet: the *One fact* rule wants each fact's files in one commit, and the seven items cross the same files (manager, plan-first, the agents); item 7's hook events are one fact across `hooks/hooks.json`, `README.md` and `AGENTS.md` *Gates*, and item 6's prose in `glab:manager` reads the hook's line, so they land together; split commits would each need their own version bump. The manager may split it. *(Changed in round 2: item 7 joins the commit.)*
- D28 Out of scope, recorded as follow-ups (*Follow-ups*): a dedicated `glab:planner` agent; splitting implementation steps out of `glab:plan-first`; the user-level copies under `~/.claude` (the user ports them); the "cleanup glob deleted a reviewer report" incident; and since round 2 the hooks the user did not choose — `UserPromptSubmit`, `PostToolBatch`, `SubagentStop` (D29).
- D29 Item 7 — the user's decision, as amended during round 2: "We need a clear rule stating that the agent must check token usage, and we need a definitive hook that triggers whenever an agent finishes its turn or after I send a message. We have to choose an approach that is impossible to bypass." (Its first form, "maybe the second one" — `PostToolUse` on `Agent` alone — is superseded by this.) Three new hook events in `plugins/glab/hooks/hooks.json`, all running **one** script, `plugins/glab/scripts/context-size.sh`, chosen by a mode argument as `memory-sync.sh` chooses by its modes: `UserPromptSubmit` → `context-size.sh prompt`; `PostToolUse` with matcher `Agent` → `context-size.sh agent`; `Stop` → `context-size.sh stop`. Not `PostToolBatch`; not `SubagentStop` — its `additionalContext` goes to the subagent, not the parent (F20). Supersedes D17.
- D30 The script takes `transcript_path` from the hook input on stdin (F20) and nothing from the environment. Supersedes D18; F15's UNVERIFIED about `CLAUDE_CODE_SESSION_ID` no longer binds anything (FU9 closed as moot).
- D31 The measure is the manager's (F1): of the last transcript entry with `.type == "assistant"`, not `.isSidechain == true`, whose `.message.usage` sums `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` to more than 0. The sidechain filter keeps a subagent's entries out on a CLI that writes them into the parent's file; the `> 0` filter skips an entry with zero usage, which is no model call, instead of letting it hide the last real one. Rounded up to thousands, `(n + 999) / 1000 | floor`, so a real value never prints `0k` (F15). The figure is the last *completed* call's — the call in flight may not be flushed to the file yet (F20, UNVERIFIED; I1 measures it) — so it lags by one call at most, and every line says "last completed call".
- D32 Bounded read: `tail -c 8388608` (8 MiB; `tail` seeks on a regular file, so the cost does not grow with the file) piped to `jq -n -R` that reads one raw line at a time with `fromjson?` and folds them in one `reduce` — the whole file is never slurped, a partial first line of the window and a truncated last line are dropped silently, and memory holds one line at a time. Proven on a 36 MB fixture with a 6 MB assistant line: right number in 0.07 s (F17). Why 8 MiB: transcripts reach 28 MB with lines of several MB (F1, the manager's measure), so the window holds more than the largest line seen while staying bounded. The known limit: an assistant entry longer than the window is not seen; then an older call's figure prints, or nothing (F17; *Known limits*).
- D33 Modes `prompt` and `agent` emit on **every** event, no threshold: `additionalContext` `glab: context <n>k (last completed call)`, about 10 tokens. `prompt` gives the model its size at the start of every turn the user starts; `agent` gives it the number for the handoff line `· context <n>k` (D21) after every dispatch. A threshold there would need state across calls and would hide the number the handoff line needs. "context", not "manager context", because the hook runs in every session (D35).
- D34 Contract of all three modes, like `memory-sync.sh`'s (`AGENTS.md` *Rules*): exit 0 on every path; on stdout either exactly one JSON object or nothing; every failure one line on stderr, `glab context-size: <reason>`, and no JSON; the JSON built by `jq -n --arg`, never by `printf`. An unknown or missing mode is a failure like any other (stderr, exit 0). Without `jq` it prints nothing — unlike `manager-bootstrap.sh`'s plain-text fallback — because without `jq` it cannot read the input or the transcript; the manager's fallback (D38) covers it. Hook `timeout` 5 s on each of the three entries, the same as the `SessionStart` hook: the proven run takes 0.07 s on a 36 MB file (F17), so 5 s is far above it and still short enough that a hung read cannot stall a turn for long.
- D35 It runs in every session of every repo where `glab` is enabled, manager or not, and that is harmless: `prompt` and `agent` add one line of about 10 tokens per user message and per Agent call; `stop` prints a line to the user only when a turn crosses a 100k step at or past 300k (D45); every mode reads only the transcript Claude Code names, read-only and bounded (D32), writes no file, keeps no state, opens no network connection and prints only an integer and fixed words; a session that does not run `glab:manager` sees a number it may ignore and, rarely, a suggestion it may ignore; every failure is silent on stdout and exits 0. A subagent that itself calls `Agent` would get its own line if the hook fires there; which transcript it is handed then is UNVERIFIED and changes nothing above.
- D36 Re-check of the tier (*Pick the tier*): still normal. The full-tier triggers are a schema or data migration, a stored or wire format, and code that decides who may do what, handles secrets or moves money. The script reads a file that can hold secrets but passes on nothing from it except an integer it computed — test T2 asserts that no byte of a fixture line, a `SECRET=` marker included, reaches stdout or stderr in any mode or case; the hook JSON is Claude Code's documented format, consumed, not a format this repo defines or stores; nothing is authorised, migrated or paid. Three events in every installed session widen the reach, not the risk class: D35 bounds what each can do, and D46 makes sure none of them can block or prolong a turn. An analyzer or reviewer that disagrees raises the tier; only the user lowers it.
- D37 A background Agent call fires `PostToolUse` at launch (`tool_response.status` `async_launched`, F20): the script does not look at `tool_response` and emits the same line, then the launch-time figure. No special case — the figure is still the last completed call's.
- D38 Fallback trigger (amends D20): **no `glab: context` line anywhere in the session** — neither with a user message nor with an Agent result. That happens when the hook is not loaded (the plugin not enabled, a `glab` older than `0.9.0`, a session under `--bare` or with hooks disabled), without `jq`, or when the transcript is unreadable or holds no usage in its last 8 MiB. Say it once in the session, then count dispatches as D20 says. When `prompt` lines come but `agent` lines do not — a CLI older than 2.1.63 whose tool is `Task`, which the matcher `Agent` is not shown to match (F20, UNVERIFIED) — the handoff line takes the number from the most recent `glab: context` line of either kind; the dispatch count is not used.
- D39 Test `tests/context-size.test.sh <path to context-size.sh>`, on the pattern of `tests/memory-sync.test.sh`: one work directory from `mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX"`, removed by an `EXIT` trap; fixture transcripts written there by the test, never a real transcript; no background process; one `ok T<n> …` or `FAIL T<n> …` line per case, then `PASS n/n` or `FAIL k/n`, exit non-zero on any failure. `jq` missing is faked by a `PATH` that holds only links to the tools the script needs, not by a stub (*Tests*: a stub fakes an external CLI; here the CLI is absent). Cases in S14.
- D40 `AGENTS.md` (S15): both new files join the shell gates (`bash -n` + `test -x`, `shellcheck`, and the test run); the hook-contract rule names `context-size.sh` too, with its modes and its stdout rule (D34); *One fact* gains the context lines — the `additionalContext` text `glab: context <n>k (last completed call)`, the `Stop` message text, the thresholds 300k and every 100k after it, and the three modes and events (`plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/hooks/hooks.json`, `README.md`); the existing entry *what each plugin holds* already binds `glab`'s hook events across *Gates*, `README.md` and `hooks/hooks.json`, and S12, S15 and S16 change all three. The `glab` green line becomes `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`, proven with a copy of the plugin in that key order (F18).
- D41 Integration I1 needs the user's OK (it calls a model; a small amount of usage). A throwaway `CLAUDE_CONFIG_DIR` is not logged in (`claude auth status` → `"loggedIn": false`, F18), so an agent cannot make the run without copying credentials, which it never does. The user runs the given command in their own terminal; it loads `--plugin-dir ./plugins/glab` alone (F18: that loads `glab` only), so no `memory-sync` hook runs (*Never run `memory-sync.sh` against a real backend*), and never `--no-session-persistence`, which would leave no transcript for the hook to read.
- D42 Version: `0.9.0` kept (D26). New hooks are a feature of the same change; nothing is removed.
- D43 Matcher `Agent` alone, not `Agent|Task`: the user named `Agent`, and how the CLI reads `|` in a matcher for an older tool name is not shown (F20). An older CLI still gets the `prompt` line (D38).
- D44 The script reads no field of `tool_input`, `tool_response` or `prompt`: the subagent's prompt and report and the user's message pass through the hook's stdin and are never printed, logged or stored. `jq` reads the whole input to take `transcript_path`; that is bounded by what Claude Code sends, not by the transcript.
- D45 Mode `stop` speaks to the **user**, not the model: on `Stop` it prints `{"systemMessage":"glab: context <n>k (last completed call) — a good point to /compact, or to /clear between tasks"}` when this turn crossed a step — 300k, 400k, 500k, … — and nothing otherwise. Stateless: one `reduce` over the window keeps `cur`, the last real call's size, and `base`, the size when the turn's user prompt arrived (the last call before the last user entry that is not a sidechain, not `isMeta`, and not a `tool_result`); `step(x)` is `-1` below 300k, else `floor((x - 300000) / 100000)`; it speaks when `step(cur) > step(base)`. A turn whose prompt is outside the window has `base` 0 and speaks at or past 300k — an extra line, never a missed one. After `/compact` the size drops and the next crossing speaks again. An interrupted turn fires no `Stop` (F20), so it shows nothing; the next turn's `prompt` line still carries the number. The transcript "is written asynchronously and may lag" (F20), so at `Stop` the figure can trail the turn's last call; the script takes what the file holds and the line says "last completed call"; I1 measures the lag. Proven in a throwaway prototype (F21). Why the user: **a hook fires deterministically but cannot make the model act** — `additionalContext` is text the model may ignore — so the one message that must not depend on the model goes to the person who can run `/compact` or `/clear`. Documented (F20): `systemMessage` is a common output field, "Warning message shown to the user", which some events discard or deliver elsewhere; and a `Stop` hook that exits 0 with no `decision` lets the turn end normally. UNVERIFIED, for I1 to prove: that the `Stop` event shows `systemMessage` to the user rather than discarding it, and whether the model also sees it. If it is not usable, `stop` is dropped — the hook entry, the mode and its cases — and the other two events stand (*Fallback plan*, after I1).
- D46 `stop` **never blocks and never continues the conversation**: no exit 2, no `decision`, no `reason`, no `continue`, no `hookSpecificOutput` and no `additionalContext` on `Stop` — `systemMessage` is its only key. Nothing reads `stop_hook_active`, because nothing ever asks for another turn. T-cases assert the key set on every `stop` output.
- D47 D19's thresholds become fixed steps, 300k and every 100k after it, for the manager's prose as for the `stop` mode: one rule stated once (*One fact*, D40), and neither side needs to remember where it last suggested. D19's "+100k since the last suggestion" meant the same steps when the first suggestion fell at 300k; it differed only when it fell later. The task-boundary `/clear` stays the manager's (D19) — no hook can tell a task boundary.
- D48 "Impossible to bypass" — what holds and what does not: the hooks run in the harness, whatever the model does, in every session where `glab` is enabled; the model cannot skip them or the user's `Stop` line. The documented limits (F20): they do not run when the plugin is disabled, under `--bare` (`claude --help`: "skip hooks"), or under `disableAllHooks: true` in user or project settings or `--settings`; managed policy can restrict hook sources (`allowManagedHooksOnly`, `strictPluginOnlyCustomization.hooks` — their effect on a plugin's hooks UNVERIFIED); and an interrupted turn fires no `Stop`. Each is a setting or an act of the user or the organisation, not something the model can do; the manager's dispatch-count fallback (D38) covers a session where no line comes. `glab:manager`'s rule (S1.16) makes acting on the line a rule of the operating model; whether a live model follows prose stays UNVERIFIED, as for every rule of this plan.

The manager adds the session's `- effort:` line (Rule 0d); this planner does not know it.

## Findings

### F1 Evidence — measured by the manager, other project, not reproducible here

Total input over all turns 597M tokens: developers 49%, planners 21%, Stage 1b
plan checks 11%, reviewers 8%, mapping agents 6%. Cost grows with turns ×
context. Fix rounds sent back to the same resumed agent cost 149M, each round
restarting at 300–450k context; modelled as fresh agents ~37–64M. A Stage 1b
round 2 that re-read the whole plan cost 9.5M against round 1's 9.0M; targeted
re-check rounds cost ~40% of round 1. The planner, handed three mapping files,
re-touched 40 of its 157 paths that mapping had already read. Normal-tier plans
were run against full-tier caps ("round 1 of 3" review, "round 1 of 2"
buildability). The manager session itself: 1,054 turns, a 648k peak, 348M
tokens (~37% of the run), five tasks and one compaction. The manager proved on
its host that `CLAUDE_CODE_SESSION_ID` names its transcript and that the last
assistant entry's usage printed 142k.

Inferred, not shown: the savings each change brings; that a live session
follows the edited prose.

### F2 Where the caps are stated today (search, base `7df69a8`)

    $ grep -rnE -i 'round[s]? ?(cap|[0-9]|n/)|max(imum)? [0-9]+ (review |develop|round)|[0-9]+ rounds|round [0-9]|one (pass|round)|...|SCOPE CUT|DO NOT PUBLISH|last round|review2|review4' plugins README.md AGENTS.md host.example.md
    (and a second search for counts in words: one|two|three|four|once ... round|pass|amendment)

Every hit that states a cap or the last-round rule (fix-mode "one pass" hits
excluded):

- `skills/manager/SKILL.md` — `:135` handoff example `round 1/1`; `:136` "the round caps stay what *Pick the tier* gives them"; `:149` last-round verdicts (Rule 5 template); `:151` "does not count against the cap"; `:164` 1b *Leaves on* "one amendment at normal tier"; `:173` `round n/max`; `:187` 1b "one pass | max 2 rounds"; `:189` conformance "max 4 rounds"; `:191` review "one round | max 3 rounds"; `:238` "`review2`, and there is no `review4`"; `:325-328` 1b "Maximum 2 rounds at full tier … One pass at normal tier"; `:376-378` "Maximum 4 develop→analyze rounds … `analyze round 2/4` … at round 4"; `:395` "this stage's round cap"; `:397` "Maximum 3 review rounds at full tier. At round 3 …"; `:399` "One round at normal tier …"; `:421` Stage 8 "go back to the developer once".
- `agents/reviewer.md:92` "at most three rounds — one at normal tier"; `:98-102` the last-round verdicts.
- `commands/ship.md:32` "At most three rounds, then a decision"; `:22-27` verdict matching.
- `skills/bootstrap/SKILL.md:100` "Normal work runs a one-page plan, one analysis and one review"; `:101` points to the round caps.
- `README.md`, `AGENTS.md` (other than *One fact* `:106`), `manager-bootstrap.sh`, `commands/review.md`, `commands/develop.md`, `commands/analyze.md`: no cap stated.

### F3 No severity in any report template

`grep -rnE -i 'severit|critical|\bhigh\b' plugins/glab README.md`: the levels
exist only in `skills/audit/SKILL.md:49-56` (*Severity Levels*: Critical, High,
Medium, Low with meanings) and its template; `reviewer.md:15` "calibrate
severity to consequence"; `review.md:10`, `ship.md:18` "do not re-rank its
severities". The reviewer's finding block (`reviewer.md:81-84`) and the
analyzer's step block (`analyzer.md:60-63`) carry no severity field.

### F4 Resumes in the payload today

`grep -rn -E 'resum' plugins/glab` → `manager/SKILL.md:131` (Rule 5's version
floors), `:151` (the report check), `commands/ship.md:28` (the same check),
`bootstrap/SKILL.md:3` ("resuming parked work", unrelated). No stage says
whether a fix round is a resume or a new dispatch. `grep -rn -i -F 'new agent'
plugins/glab` → nothing (rc=1).

### F5 `result.md` on a re-dispatch

`developer.md:68`: "overwrite it on a re-dispatch rather than appending a
second copy". `developer.md:103`: the developer writes only `result.md` and
`follow-ups.md` in the folder.

### F6 Review rounds after the first are already narrowed

`reviewer.md:94`: "Every round after the first reviews only what changed since
the last one. Ask what changed and confirm it yourself." `ship.md:32`: "scope
each round after the first to what changed since the last one". Manager Stage
5 says nothing on how a later round learns what changed (follow-up FU7).

### F7 The plan check has no mode in the analyzer's file

`grep -rn -c BUILDABLE plugins/glab` → `skills/manager/SKILL.md:2`, every other
file `0`. `analyzer.md` knows `CONFORMS`, `DIVERGES`, `BLOCK` only; Stage 1b's
verdicts live in the manager's dispatch (FU5).

### F8 Delta mechanisms, proven in a throwaway repo under `$TMPDIR` (removed after)

Snapshot (D11), base commit with `a.txt b.txt c.txt .gitignore(*.log)`; then
`a.txt` modified, `new.txt` untracked, `b.txt` staged, `x.log` ignored:

    t1=4cb2e19e632aa8f250252eeead89aed93d3bb598 rc=0
    real index/status unchanged after snapshot:
    status-same
    staged-same
    t1 contents:
    .gitignore
    a.txt
    b.txt
    c.txt
    new.txt
    --- fix round: change new.txt, delete c.txt, add fix.txt
    t2=435b25c708024328763d9f27f6012d754d482d0b
    delta:
     c.txt   | 1 -
     fix.txt | 1 +
     new.txt | 2 +-
     3 files changed, 2 insertions(+), 2 deletions(-)
    quiet rc=1
    --- same tree twice gives the same sha:
    same-sha
    0          <- no temp index left behind

The snapshot function was
`idx="$TMPDIR/fcr-snap-$1.idx"; rm -f "$idx"; GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"`.
`a.txt`, changed before `t1`, is not in the delta; `x.log` is in neither tree.

Plan copy (D10):

    -2 b
    +2 b, amended        (and +- D2 y)
    diff rc=1
     plan.r1.md => plan.md | 3 ++-
    git-no-index rc=1
    identical rc=0

Not tested: a nested repository in the tree (`git add -A` would record it as
a gitlink and warn); a very large untracked directory that is not ignored
(every file is hashed). Both under *Known limits* of the record.

### F9 The Write tool and file names (this session)

`Write plan/flow-cheaper-rounds/findings-probe.md` and `.../findings.md` →
"Subagents should return findings as text, not write report files."
`Write .../map-probe.md` → created, then removed (`rm -f`, `ls` showed only
`plan.md`). Only these three names were tried; which other names the guard
refuses is not known.

### F10 Planner search today

`plan-first/SKILL.md:31-38` audits every method "you plan to change or call"
with four bullets, the fourth "whether the call site you are designing can
satisfy its preconditions"; `:85` Step 4 "the call-site review is complete for
any changed existing method". `manager/SKILL.md:256` checklist item 3: "Every
file … the change touches or depends on, by path, plus the call sites of
anything being changed. A findings file with no path list has not done this
step." `security/SKILL.md:72`: "Before changing any existing function's
signature, return values, error cases, or timing: grep every call site and
state what each one relied on." — binds on change, not on a call.

### F11 Specs read first (`docs/specs/workflow.md`, `docs/specs/marketplace.md`)

Binding and touched: `[feature-model-switch/plan.md D5]` (round caps do not
bend to the model — kept); `D22` (the one report-check resume — kept);
`[bug-reviewer-findings/questions.md Q3]` and `[feature-plugin-marketplace/questions.md S3]`
(cap 3 — superseded by D2); `[sync-local-edits/result-followups.md D11]`
(1b *Leaves on* — superseded); `D6` (after an amendment the develop handoff
re-runs the next stage — kept); `[feature-docs-specs/plan.md D27]` (record:
one fix round, then the analyzer — kept, now a new agent). Open follow-ups
this closes: `[sync-local-edits/follow-ups.md 18]` (analysis caps not in *One
fact*) and `[sync-local-edits/follow-ups.md 19]` (a normal-tier review fix
checked only by the gates, and `/glab:ship` with no normal-tier exception: now
one cap at every tier, and the fix gets a round 2). The incident that cut
"— one at normal tier —" from `ship.md` because `/glab:ship` cannot know a
tier is moot: the cap no longer depends on the tier.

### F12 Scope — every path

Changed: `plugins/glab/skills/manager/SKILL.md`,
`plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/bootstrap/SKILL.md`,
`plugins/glab/skills/audit/SKILL.md` (no text change; listed as an owner of
the severity levels in *One fact*), `plugins/glab/agents/reviewer.md`,
`plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`,
`plugins/glab/commands/ship.md`, `plugins/glab/commands/develop.md`,
`plugins/glab/commands/analyze.md`, `plugins/glab/.claude-plugin/plugin.json`,
`AGENTS.md`; since round 2 also `plugins/glab/hooks/hooks.json`, `README.md`,
and two new files, `plugins/glab/scripts/context-size.sh` and
`tests/context-size.test.sh`. Depended on, read only where cited: `plugins/glab/skills/security/SKILL.md`,
`plugins/glab/commands/review.md`, `plugins/glab/commands/plan.md`,
`plugins/glab/scripts/manager-bootstrap.sh`,
`plugins/memory-sync/scripts/memory-sync.sh` and `tests/memory-sync.test.sh`
(the pattern S13–S14 follow), `docs/specs/workflow.md`, `docs/specs/marketplace.md`. Not changed:
`manager-bootstrap.sh` (F16, D22), `.claude-plugin/marketplace.json` (its
description names no `glab` hook: F19), the `memory-sync` plugin, `commands/review.md` (no cap; "do not re-rank"
already fits D4), `commands/plan.md`.

### F13 Nothing parses an agent report

`grep -rn -i -E 'verdict|severity|rule:|breaks when' plugins/*/scripts tests plugins/*/hooks` → rc=1;
the only scripts are `manager-bootstrap.sh`, `memory-sync.sh` and its test.
Round 2's `context-size.sh` parses a transcript's usage numbers, not an
agent report, so this still holds after it.

### F14 Baseline gates, at `7df69a8` with only `plan/` untracked

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    ok T35 a transfer killed before the time limit is a failure, not a timeout
    PASS 35/35
    ✔ Validation passed   (x3)
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    plugins/memory-sync/scripts/memory-sync.sh:1
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    README.md:1
    rc=0
    rc=1

Claude Code `2.1.304`, `jq-1.8.1` on this host.

### F15 The context command, against fake transcripts in `$TMPDIR` (removed after)

*Round 1's evidence for the inline command, superseded by D29–D30 and kept
as the record. Its rounding and its never-`0k` result carry over (D31).*

The command of S1.16 run with `CLAUDE_CONFIG_DIR` pointing at a fake tree,
one fake transcript per case (a user line holding `SECRET=abc` in the first):

    == normal + partial last line      143k   rc=0   (142000+300+5; the broken last line skipped; SECRET not printed)
    == no usage entries                context: no usage in the transcript            rc=1
    == 7 tokens                        1k     rc=0   (rounded up, so a real value never prints 0k)
    == zero usage                      context: no usage in the transcript            rc=1
    == unset var                       CLAUDE_CODE_SESSION_ID: not set / context: no single transcript for this session   rc=1
    == no file                         context: no single transcript for this session rc=1
    == two files                       context: no single transcript for this session rc=1
    == empty file                      (first version: rc=4, silent; fixed by the `||` message, same path as "no usage")

The first version printed `0k` for 7 tokens and exited 4 silently with no
usage; both fixed in the version S1.16 gives. The real transcript was not read
by this planner (the brief keeps it out of `~/.claude`); the manager showed the
jq part live (F1). UNVERIFIED: that `CLAUDE_CODE_SESSION_ID` is set and that
transcripts sit under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<dir>/<id>.jsonl`
on any host or Claude Code version other than the manager's — only that host
was shown. It was set in this subagent too, so a subagent sees an id; whose it
is was not checked.

### F16 Handoff and compaction in the payload today

`grep -rn -i -E 'SESSION-HANDOFF|handoff file|/clear|/compact|compaction|context size|CLAUDE_CODE_SESSION_ID' plugins README.md AGENTS.md`
→ `bootstrap/SKILL.md:127` "`plan/SESSION-HANDOFF.md`, or the nearest
equivalent in `plan/`"; `manager/SKILL.md:69`, `:134` ("a reader after a
compaction"); `AGENTS.md:184` (never committed, this repo). Nothing in
`manager-bootstrap.sh`. The handoff-line format is stated only in
`manager/SKILL.md:135` and `:173` (`grep -rn -F 'round n/max'`).

### F17 The `agent`/`prompt` pipeline, prototyped against fixtures (round 2, `$TMPDIR`, removed after)

A throwaway prototype of D30–D34 (stdin `transcript_path` → `tail -c 8388608`
→ `jq -n -R` with `fromjson?` and a `reduce`; JSON by `jq -n --arg`), run on
fixtures; a user line holding `SECRET=abc` in each:

    sizes: huge.jsonl 36001421, normal.jsonl 203, nousage.jsonl 51
    == normal (complete assistant line, then a truncated `{"type":"assistant","mess`)
    {"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"glab: context 143k (last completed call)"}}
    rc=0 t=.010567334
    == nousage        glab context-size: no usage in the transcript    rc=0 (stderr, no stdout)
    == huge (30 x 1 MB user lines, a 6 MB assistant line, a user line)
    {"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"glab: context 251k (last completed call)"}}
    rc=0 t=.069310348
    == missing        glab context-size: no readable transcript        rc=0
    == malformed stdin  glab context-size: hook input is not JSON      rc=0
    == empty stdin    glab context-size: no readable transcript        rc=0
    == assistant line of 9 MB, larger than the window, older entries outside it
                      glab context-size: no usage in the transcript    rc=0

`SECRET` was in no output. The prototype lacked D31's sidechain and `> 0`
filters (added after); the test of S14 covers them. Not measured: a real
transcript (the brief keeps it out of reach), and timing on any other host.

### F18 The plugin with the new hooks, and an unauthenticated config (round 2)

A copy of `plugins/` under `$TMPDIR` with `hooks/hooks.json` as S12 gives it
and a stub `context-size.sh`, each `claude` command under a new empty
`CLAUDE_CONFIG_DIR`, both removed after (`ls` count of leftovers `0`):

    ✔ Validation passed        (plugins/glab)
    ✔ Validation passed        (plugins/memory-sync)
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0

The events print in the file's key order (an earlier copy with `PostToolUse`
alone printed `Hooks (2)  SessionStart, PostToolUse`). The CLI labels every
hook "harness-only — no model context cost", which is not true of a hook that
returns `additionalContext`; it is the CLI's wording (FU12).
`claude --plugin-dir ./plugins/glab plugin details glab` loads `glab` alone
(`Hooks (1)  SessionStart` on the unchanged tree), and the same flag with
`plugin details memory-sync` printed `Plugin "memory-sync" not found`.
`claude auth status` under the empty config: `"loggedIn": false`,
`"authMethod": "none"`. `claude --help` lists `--include-hook-events`,
`--no-session-persistence` and `--bare` ("skip hooks"). Claude Code
`2.1.304`, `jq-1.8.1`.

### F19 Every place that states `glab`'s hooks (search, base `7df69a8`)

    $ grep -rn -E 'Hooks \(|SessionStart|PostToolUse|hooks\.json|manager-bootstrap|hook event|one hook|a hook|the hook' --include='*.md' --include='*.json' --include='*.sh' . | grep -v '^./plan/' | grep -v memory-sync.sh/test

`glab`'s hooks are stated in: `AGENTS.md:11-12` (*Layout*: `hooks/hooks.json`
and `scripts/manager-bootstrap.sh`), `:27-28` (the shell gates name the
scripts), `:67` (`Hooks (1)  SessionStart`), `:103` (the hook contract,
`memory-sync.sh` only), `:123-124` (*One fact*: what each plugin holds);
`README.md:9` ("a `SessionStart` hook that injects the session bootstrap
rules"), `:26` (the session rules reach a session "through the `glab`
`SessionStart` hook" — still true), `:31` ("`jq` is optional: the `glab` hook
falls back to plain text"); `plugins/glab/hooks/hooks.json`;
`manager-bootstrap.sh:2` (its own header, unchanged); and the specs
`docs/specs/marketplace.md:32-37, :59-66, :71, :81, :189` and
`docs/specs/workflow.md:12-13, :32` (records, updated by the record, not this
change). `README.md:116-121` (the copy install) and the `memory-sync` hits
are about `memory-sync` or the old copy and do not change. The `glab` skills,
agents and commands name no hook (`grep -rn -i hook plugins/glab/skills
plugins/glab/agents plugins/glab/commands` → nothing).
`.claude-plugin/marketplace.json:3` names only the memory-sync hook.

### F20 Claude Code docs relied on (documented, not proven here)

From the docs, gathered for the manager by a docs agent:

- The subagent tool is `Agent` (alias `Task` before 2.1.63); matcher `Agent` — https://code.claude.com/docs/en/sub-agents. Whether the matcher `Agent` matches a `Task` call on an older CLI: UNVERIFIED.
- `PostToolUse` runs in the parent session; its input carries `session_id`, `transcript_path` (the parent's), `cwd`, `tool_name`, `tool_input`, `tool_response`; `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"…"}}` is added to the model's context next to the tool result; `additionalContext` is capped at 10,000 characters — https://code.claude.com/docs/en/hooks. A background Agent call fires it at launch (`tool_response.status` `async_launched`).
- `UserPromptSubmit` takes `additionalContext` the same way, with `hookEventName` `UserPromptSubmit` — https://code.claude.com/docs/en/hooks.
- `SubagentStop`'s `additionalContext` goes to the subagent — https://code.claude.com/docs/en/hooks#subagentstop.
- `systemMessage` is a common output field, "Warning message shown to the user"; some events discard it or deliver it elsewhere, each event's section says which; capped at 10,000 characters — https://code.claude.com/docs/en/hooks#json-output. Whether `Stop` shows it to the user, and whether the model also sees it: UNVERIFIED.
- `Stop` with exit 0 and no `decision` lets the turn end ("allow Claude to stop"); it runs only for the main agent, not on a user interrupt; its input carries `transcript_path`, `stop_hook_active`, `last_assistant_message`, `background_tasks`; the transcript "is written asynchronously and may lag" — https://code.claude.com/docs/en/hooks#stop.
- Hooks do not run under `disableAllHooks: true` (user, project or `--settings`); managed policy can restrict hook sources (`allowManagedHooksOnly`, `strictPluginOnlyCustomization.hooks`; effect on plugin hooks UNVERIFIED) — https://code.claude.com/docs/en/hooks.
- Plugin hooks live in `hooks/hooks.json` under a top-level `hooks` key; `${CLAUDE_PLUGIN_ROOT}` is substituted in the command — https://code.claude.com/docs/en/plugins-reference#hooks.
- For FU13 only: `PreToolUse` `permissionDecision: "deny"` refuses a call and shows the reason to the model; the Agent `tool_input` is documented as `prompt`, `description`, `subagent_type`, `model` — whether it carries `effort` is UNVERIFIED — https://code.claude.com/docs/en/hooks#pretooluse.
- UNVERIFIED in the docs: whether the parent's current call is flushed to `transcript_path` before `PostToolUse` or `Stop` runs. The figure is the last completed call's (D31).

### F21 The `stop` crossing rule, prototyped (round 2, `$TMPDIR`, removed after)

D45's `reduce` (`cur` = the last call's size, `base` = `cur` at the last user
prompt that is not a `tool_result`) on six fixtures; `A n` an assistant entry
of `n` tokens, `P` a user prompt, `R` a tool result:

    below 300k                    P A100000 R A200000            → 200 quiet
    crossed 300k in this turn     A250000 P A280000 R A310000 R A320000 → 320 SUGGEST
    already past 300k, same step  A310000 P A350000              → 350 quiet
    crossed 400k                  A390000 P A401000              → 401 SUGGEST
    after compact, drop           A500000 P A40000               → 40 quiet
    no prompt in window           A420000                        → 420 SUGGEST

all `rc=0`. The prototype lacked the `isMeta` filter of D45 (added after);
S14 covers it.

### Boundary

Chosen: the rules live in `glab:manager` (Rule 2, *Pick the tier*, Stages 1,
1b, 2, 3, 5, 8, *What you never do*) and `glab:plan-first` Step 1; the agent
files carry only what an agent needs to do its part (severity line, re-check
section, fix-round section); commands restate one line each and point to the
manager (`[feature-model-switch/plan.md D7]`). Since round 2, the
measurement lives in one hook script with three modes, the threshold for the
user's message in its `stop` mode, and what the manager does with the number
in `glab:manager` Rule 2 (S1.16): the harness measures, the model acts, the
user decides.

Rejected: (a) *round 1's choice, reversed in round 2:* an inline command in
`glab:manager` that the manager runs itself (D17) — a rule the model may skip,
where a hook fires every time (D45, D48); (a2) one script per event — three
copies of the same read and the same contract, where the modes of one script
share them as `memory-sync.sh`'s do; (a3) state kept in a file to remember
the last suggestion — the step rule (D45, D47) needs none; (a4) `Stop` with
`decision: block` or `additionalContext` to make the model suggest — it would
continue the turn the user just got back (D46);
(b) the snapshot tree for the plan delta as well — silently empty under a
gitignored `plan/` (D10); (c) the manager writing each round's findings to a
file — Rule 1, and the reviewer has no slug (D8); (d) `findings-<area>.md` —
refused by the Write tool (D15); (e) a severity judged by the manager — it
would re-rank (D4).

## Milestone

Since round 2 something new runs: the `glab` hook prints the session's
context size on every user message and every Agent dispatch, and tells the
user at `Stop` when a turn crossed 300k or a further 100k. Proven without a
model by `bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh`
→ every line `ok`, `PASS n/n` (V17), and by the plugin gate's
`Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop` (V15); proven
end to end only by I1, a model run that needs the user's OK (D41). The
Markdown part is as before: the searches V1–V16 return exactly the files and
lines listed, which separates a finished tree from a half-finished one, and
the commands the payload prescribes (S1.12, S1.14) are run once in a
throwaway directory (V13), as `AGENTS.md` *Gates* says a Markdown change is
verified.

## Steps

### Before

- B1 export `TMPDIR` as the temp directory the host file names; read `AGENTS.md`; `git status --short -uall` shows only `plan/` entries and the tree is at `7df69a8` or a descendant that has not touched the files of F12 (`git diff --stat 7df69a8 -- plugins AGENTS.md README.md tests` prints nothing), and `plugins/glab/scripts/context-size.sh` and `tests/context-size.test.sh` do not exist yet.
- B2 Run both gate blocks of `AGENTS.md` *Gates*; green as F14.

### Processing

Line numbers are at `7df69a8`. Quoted text is the new text; keep the
surrounding text as it is. Payload names stay prefixed (`glab:manager`),
frontmatter `name:` bare.

**S1 `plugins/glab/skills/manager/SKILL.md`**

- S1.1 Rule 2, after the bullet at `:90` ("Every agent writes long output to disk …"), add:
  "- **Every round is a new agent.** A plan check, a planner's amendment, a developer's fix round, a re-dispatch after `BLOCKED` or `PLAN WRONG`, a conformance check, a review round and a record fix are each dispatched to a new agent that works from the files on disk and what its dispatch names — never by resuming the agent that ran before or sending it a follow-up. A resumed agent starts again from everything it has read and written, so each round costs more than the one before; a new one reads only what its round needs. The one resume this skill allows is Rule 5's report check, for missing fields only. Stages 1b, 2, 3, 5 and 8 say what each new agent is given."
- S1.2 Rule 2, after the paragraph at `:96` ("You have taken over when …"), add the subsection of S1.16.
- S1.3 Rule 5 `:130`: "on each split slice, each re-dispatch after `BLOCKED` or `PLAN WRONG`, and each review round" → "on each split slice, each fix round, each re-dispatch after `BLOCKED` or `PLAN WRONG`, and each review round".
- S1.4 Rule 5 `:135`: the example `slug · develop · model sonnet · round 1/1 · BUILT · effort <level>` → `slug · develop · model sonnet · round 1/2 · BUILT · effort <level> · context <n>k`.
- S1.5 Rule 5 `:151`: after "The resume is not a review round and does not count against the cap." add "It is the one resume Rule 2 allows."
- S1.6 *The pipeline* table: `:163` Writes cell → "`plan/{slug}/plan.md`; at full tier `findings.md` too, and `questions.md` if Rule 3 raised one; `map-<area>.md` from mapping agents, when you dispatched them"; `:164` Leaves-on cell → "`BUILDABLE`, or at normal tier the amendment after round 2".
- S1.7 *The pipeline* `:173`: the line format → "`slug · stage · round n/max · verdict · effort <level> · context <n>k`" and after "(Rule 5)." add: "`max` is the stage's round cap (*Pick the tier*): `2`, or `3` once the round-3 line is written; a develop line counts its fix rounds against the cap of the stage whose findings it fixes. The context is the number in the most recent `glab: context <n>k` line the `glab` hook added — `dispatches <d>` in its place only when no such line has come in this session (Rule 2)."
- S1.8 *Pick the tier* table: `:187` → `| 1b Analyze the plan | — | max 2 rounds | max 2 rounds |`; `:189` → `| 3 Analyze conformance | — | — | max 2 rounds |`; `:191` → `| 5 Review | — | max 2 rounds | max 2 rounds |`. After the table, before "Gates are run by you …", add:
  "**Round caps.** Stage 1b, Stage 3 and Stage 5 run at most **2 rounds** each, at every tier where the stage runs. A **third** round runs only when round 2 returned a finding rated `critical` or `high` — the severity the analyzer or reviewer gave it, on `glab:audit`'s *Severity Levels*, never re-ranked by you — and only once you have recorded it under `## Decisions`: `- round 3: <stage> — <severity> <the finding, as its file:line or step id and its claim>`. Nothing runs past round 3. What a stage does when its last round has not passed is in that stage."
- S1.9 *When subagent dispatch is not available* `:238`: "a second review session is `review2`, and there is no `review4`." → "a second review session is `review2`, a `review3` needs its round-3 line, and there is no `review4`."
- S1.10 Stage 1, after the paragraph at `:248`, add:
  "**Explore once.** Mapping — read-only agents that read an area of the code before the plan is written — is your call per task. Each mapping agent writes `plan/{slug}/map-<area>.md` — every path it read, `file:line` for what matters, proven kept apart from inferred — and returns a short report (Rule 2). Name those files in the planning agent's dispatch: it starts from them and reads code only for the gaps it names. Without mapping agents, the planning agent explores itself. Never both over one area: a planner told to explore again re-reads what the map already holds. The name is not `findings-<area>.md` because subagent writes of files named `findings…` have been refused."
- S1.11 Checklist item 3, `:256` → "3. **Findings cover the whole scope surface.** Every file, package, module and directory the change touches or depends on, by path. Each method the change **changes** carries its call sites and what each relies on; each method it only **calls** carries the precondition its new call site must meet and how the plan meets it; a file it only depends on is listed by path, not read in full (`glab:plan-first` Step 1). A findings file or section with no path list has not done this step."
- S1.12 Stage 1b, replace `:320-328` (from "**`BUILDABLE`** → Stage 2." to "… the backstop.") with:
  "**`BUILDABLE`** → Stage 2. **`NOT BUILDABLE`** → an amendment, with exactly what is missing; a missing choice is decided under Rule 3 first. **Never patch the steps yourself to make them buildable** — for the same reason Stage 3 forbids editing `plan.md` to resolve a divergence.

  **The amendment goes to a new planning agent** (Rule 2). Before you dispatch it, keep the version the round checked: `cp plan/{slug}/plan.md plan/{slug}/plan.r<n>.md`, and `findings.md` to `findings.r<n>.md` when there is one, `<n>` being the round that checked them. Give the new agent the slug, that this is the amendment after plan check round `<n>`, the round's findings copied as the analyzers returned them, and `glab:plan-first` with the seam stated. It reads the plan files from disk, changes what the findings name and what that forces, records each changed choice under `## Decisions`, and leaves the `.r<n>` copies as they are.

  **A re-check looks at the delta, not the whole plan.** Before round `<n+1>`, run `diff -u plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and the same for `findings.md`): exit 1 means the amendment changed the plan; exit 0 means it changed nothing — send it back, do not re-check it; exit 2 means a file is missing — find out why first. Give each analyzer of round `<n+1>` the previous round's findings, copied as returned, and the file pairs. It checks each of those findings, every line the diff changes and every step that rests on a changed line — the post-condition question included — and not the rest of the plan, which already passed.

  **At most 2 rounds, a third under *Pick the tier*'s round-3 rule.** A plan still `NOT BUILDABLE` after round 2 with no round 3: at full tier it needs a design, not another pass — bring that to the user; at normal tier a new planning agent amends once more from what the analyzers found and the plan goes on — the developer's `PLAN WRONG` is the backstop. Still `NOT BUILDABLE` after round 3, at any tier: bring it to the user."
- S1.13 Stage 2 dispatch list, after the effort bullet at `:340`, add:
  "- **for a fix round** — after `DIVERGES` or review findings: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. It reads `plan.md`, `result.md` and the tree itself, fixes only what the findings name, and adds a fix-round section to `result.md` instead of overwriting it. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps."
- S1.14 Stage 3, replace `:376` with:
  "**`DIVERGES` → back to Stage 2** with only the diverging steps in scope, as a fix round. **At most 2 develop→analyze rounds, a third under *Pick the tier*'s round-3 rule.** Say the round number every time: `analyze round 2/2`.

  **A re-check looks at the delta.** Before you dispatch each analyze round, round 1 included, snapshot the tree it will measure — tracked, staged and untracked files, without touching the index — with an index path that does not exist yet, in the session's temp directory:

      idx=<temp directory>/<slug>-analyze-r<n>.idx; rm -f "$idx"
      GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"

  It prints a tree id; name it in that round's dispatch. Round `<n+1>` gets the previous round's findings, copied as returned, and both tree ids; it reads `git diff --stat <old> <new>` and `git diff <old> <new>` and checks each previous finding, every step whose files the delta touches, and anything in the delta that no step asked for — not the steps the delta leaves alone. `git diff --quiet <old> <new>` exiting 0 after a fix round means nothing changed: stop and find out why. Ignored files are not in a snapshot, so a path the fix round's `files:` line names and the delta does not show is checked whole; a tree id you no longer have means that round runs whole."
  And `:378` "Still diverging at round 4 →" → "Still diverging after the last round →" (rest unchanged).
- S1.15 Stage 5, replace `:397` and `:399` with:
  "Findings → back to Stage 2 as a fix round, then the stages after it at that tier, then Stage 5 again. **At most 2 review rounds, a third under *Pick the tier*'s round-3 rule**, at every tier. Tell the reviewer which round this is and which is the last: round 2 is the last unless it reports a `critical` or `high` finding, and round 3 is the last with no exception. A round-2 `BLOCK` with no critical or high finding is not a last-round answer: Rule 5's report check applies. At the last round the answer must be `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>`, or `DO NOT PUBLISH: <why>` — bring whichever it is to the user.

  A fix that grows past its finding, or lands in full-tier code, raises the tier."
  `:401` ("Watch where findings land …") stays.
- S1.16 The subsection S1.2 places after `:96` *(rewritten in round 2: the hook measures, the manager acts)*:
  "### Your own context — read it, act on it, never clear

  Your context grows with every turn, and every turn pays for all of it. You cannot run `/clear` or `/compact`; the user can. The `glab` plugin's hook measures it for you: with every message the user sends and with every Agent result it adds one line, `glab: context <n>k (last completed call)` — the context of your last completed model call, in thousands. When a turn crosses 300k or a further 100k, the same hook also tells the user directly at the end of the turn. A hook runs every time but cannot make you act on what it says; acting on it is this rule.

  - **Read the number at every handoff line.** Put the most recent `glab: context <n>k` number at the end of the handoff line, `· context <n>k`. It is the last completed call's context, not your exact size now; say no more than that. Never read the transcript yourself to get a better number: it can hold secrets.
  - **Inside a task**, at the first handoff line at or past **300k**, and again at the first line past each further **100k** — 400k, 500k, … — bring the handoff file up to date and suggest `/compact` to the user. These are the steps at which the hook speaks to the user, so the two never disagree. 300k is where a resumed agent's rounds were already costing several times a fresh one's, and half of one manager session's 648k peak.
  - **At a task boundary** — after the push of the Stage 8 record, or after Stage 7 for a change with no plan folder — bring the handoff file up to date and tell the user this is a good point to `/clear` and start the next task in a new session, whatever the number says. No hook can tell a task boundary; this one is yours alone.
  - **When no line has come at all** in this session — the plugin not enabled or older than `0.9.0`, hooks turned off, no `jq`, no readable transcript — say so once, then count instead: suggest `/compact` after every **15** dispatches since the session started or was last compacted, and after any stage that took more than one round. The handoff line then ends `· dispatches <d>`. When lines come with the user's messages but not with Agent results, use the most recent line of either kind; do not count.
  - **The handoff file** is the one `glab:bootstrap` step 5 reads — `plan/SESSION-HANDOFF.md`, unless the repo keeps its handoff elsewhere. Write what is done (slugs, commits), what is in progress (slug, stage, round, the next dispatch), and anything decided in this conversation that no plan file holds. No `glab` step commits it.
  - **You never run `/clear` or `/compact` yourself**, and never claim to know your context more exactly than the hook's line said."
- S1.17 Stage 8: `:420` "`DIVERGES` goes back to the developer once" → "`DIVERGES` goes back to a new developer once (Rule 2)"; `:421` "Its findings go back to the developer once" → "Its findings go back to a new developer once".
- S1.18 *What you never do*, add after `:436`:
  "- Resume an agent, or send it a follow-up, for another round of work — Rule 5's report check is the one resume.
  - Run `/clear` or `/compact`, or claim to know your context more exactly than the `glab` hook's line said."

**S2 `plugins/glab/skills/plan-first/SKILL.md`**

- S2.1 Step 0 `:19`: after "Normal tier writes one page: `plan.md` alone, with findings and decisions as sections of it." add "Map files the manager's mapping agents wrote, `map-<area>.md`, sit beside it (Step 1)."
- S2.2 Step 1, before "**Call-site audit.**" (`:31`), add:
  "**Start from the map when there is one.** When `plan/{slug}/map-<area>.md` files exist — written by mapping agents the manager dispatched (`glab:manager` Stage 1, *Explore once*) — they are the analysis of their area. Start from them, write down the gaps they leave that the plan needs, and read code only for those gaps, naming each in your findings. Do not re-read a path a map already read unless a gap names it. With no map, you explore yourself."
- S2.3 Replace `:31-38` with:
  "**Call-site audit.** For every existing method or function the plan **changes** — its signature, return values, error cases, timing or behaviour — grep its real usage across the codebase first and record:

  - the caller list;
  - what each caller appears to rely on;
  - whether the contract is shared or caller-specific.

  For every method the plan calls from a new call site, record the precondition that call site must meet and how the plan meets it. For a method it only **calls**, that is all: its other callers are not audited, because nothing they rely on changes.

  Do not assume how a method behaves from its name or signature alone: read the precondition from its body or its documented contract.

  A file the change only depends on — imported, configured, read — is listed by path and not read in full; read only the part a precondition or a finding needs."
- S2.4 Step 4 `:85` → "- the call-site review is complete for any changed existing method, and every method the plan only calls has its precondition recorded;"
- S2.5 After Step 4's list (`:88`), add:
  "**Amending after a plan check.** Under `glab:manager` an amendment after `NOT BUILDABLE` is written by a new planning agent from the files on disk and the round's findings in its dispatch (`glab:manager` Stage 1b). Change what the findings name and what that forces, record each changed choice under `## Decisions`, and leave the `plan.r<n>.md` copies the manager kept as they are. Step 1 is not run again, except for a gap a finding opens."

**S3 `plugins/glab/agents/reviewer.md`**

- S3.1 *Report* block `:81-84`: after `rule: <the AGENTS.md rule, or "correctness">` add the line `severity: <critical | high | medium | low>`. After the block (before `:86`) add:
  "The severity is one of `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. Rate by consequence. The caller does not re-rank it, and in round 2 it decides whether a round 3 runs."
- S3.2 `:92` → "A change gets **at most two rounds**, and a third only when round 2 reports a `critical` or `high` finding — at every tier, counted across the whole change rather than per file. The caller tells you which round this is and which is the last. Round 2 is the last unless you report a `critical` or `high` finding in it: then answer `BLOCK: <n> issues`, and the caller may run round 3. Round 3 is the last with no exception. In the last round the answer must be publish or do not publish; there is no round after it."
  `:94-102` unchanged.

**S4 `plugins/glab/agents/analyzer.md`**

- S4.1 Step 1 `:16` → "- `plan/<slug>/findings.md` and every `plan/<slug>/map-<area>.md`, when there are any — what the plan was built on"
- S4.2 *Report* block `:60-63`: after `gap:       <only when not done>` add `severity:  <only when not done: critical | high | medium | low>`; after the block add:
  "Rate each gap by what it costs if the plan is built, or the tree shipped, as it stands, on `glab:audit`'s *Severity Levels*: `critical` — data loss risk, crash risk, security issue, unbounded memory growth; `high` — correctness bug, significant performance issue, missing essential functionality; `medium` — code quality, maintainability, minor bugs; `low` — style, naming, documentation, non-critical config. In round 2 it decides whether a round 3 runs."
- S4.3 New section before `## The record check` (`:54`):
  "## Re-checks — round 2 and later

  When the dispatch says this is round 2 or later of a plan check or a conformance check, it gives you the previous round's findings and the delta: for a plan check, file pairs — `plan/<slug>/plan.r<n>.md` and `plan/<slug>/plan.md`, and `findings.r<n>.md` with `findings.md` when there are; for a conformance check, two tree ids. Get the delta yourself — `diff -u <old> <new>`, or `git diff --stat <old> <new>` then `git diff <old> <new>` — and check:

  - each previous finding: fixed, or still open under its old step id;
  - every line the delta changes, and every step that rests on a changed line or a changed file — for a plan check, the post-condition question included;
  - for a conformance check, anything in the delta that no step asked for.

  Do not re-walk what the delta leaves alone; it passed the round before. `diff` and `git diff --quiet` exit 1 when there is a difference and 0 when there is none: an empty delta is not a pass — report `BLOCK: target unresolved` and say the delta was empty. Name the delta you measured — the file pair or the two tree ids — beside the plan revision."
- S4.4 Record check `:56`: append "A round copy — `<name>.r<n>.md`, kept by `glab:manager` Stage 1b — is an earlier version of a file the folder still holds: take the items from the current file; the copy is not checked on its own."

**S5 `plugins/glab/agents/developer.md`**

- S5.1 Step 1 `:17`: append "Also any `plan/<slug>/map-<area>.md` the plan cites."
- S5.2 Step 5 `:68`: "overwrite it on a re-dispatch rather than appending a second copy." → "overwrite it on a re-dispatch of the same steps rather than appending a second copy; a fix round adds its own section instead (*A fix round*)."
- S5.3 New section after Step 5's template (`:94`), before `## The record`:
  "## A fix round

  When the dispatch says this is a fix round — after an analyzer's `DIVERGES` or a reviewer's findings — your scope is the findings it quotes, each one a step. You did not build what came before: read `result.md` for what earlier rounds built, and the tree (`git status --short -uall`, `git diff`, `git diff --staged`), before changing anything. Do not overwrite `result.md`: add a section `## Fix round — <stage> round <n>` with each finding `done` or `blocked` with `file:line`, then the gates. Every other rule of this file holds."
- S5.4 Record `:98`: after "Change nothing inside `plan/<slug>/`, and remove nothing." add "A round copy `<name>.r<n>.md` is an earlier version of a file the folder still holds: take the items from the current file."
- S5.5 `:103`: "**Never edit `plan.md`, `findings.md` or `questions.md`.**" → "**Never edit `plan.md`, `findings.md`, `questions.md`, a `map-<area>.md` or a round copy `<name>.r<n>.md`.**"

**S6 `plugins/glab/commands/ship.md`**

- S6.1 `:30`: "If I ask you to fix anything, return to step 1 and re-run the reviewer on the amended tree." → "If I ask you to fix anything, return to step 1 and run a new agent as the reviewer on the amended tree — never the previous one resumed (`glab:manager` Rule 2)."
- S6.2 `:32`: "**At most three rounds, then a decision.** Tell the reviewer which round this is and which is the last, and scope each round after the first to what changed since the last one. In the last round it must answer …" → "**At most two rounds, a third only on a critical or high finding, then a decision.** Tell the reviewer which round this is and which is the last, and scope each round after the first to what changed since the last one. Round 2 is the last unless the reviewer reports a `critical` or `high` finding in it and answers `BLOCK`; then round 3 runs if I ask for the fix, and it is the last with no exception. In the last round it must answer …" (rest of `:32` unchanged).

**S7 `plugins/glab/commands/develop.md`**

- S7.1 `:42`: "slices and re-dispatches alike" → "slices, fix rounds and re-dispatches alike".
- S7.2 After `:43`, add: "- for a fix round — after `DIVERGES` or review findings — or a re-dispatch after `BLOCKED` or `PLAN WRONG`: a new agent, never the previous one resumed or sent a follow-up (`glab:manager` Rule 2). A fix round's dispatch says which round it fixes and quotes that round's findings as they came back; the agent reads `plan.md`, `result.md` and the tree itself."

**S8 `plugins/glab/commands/analyze.md`**

- S8.1 After `:6`, add: "A round 2 or later is a new agent, given the previous round's findings and the delta, as `glab:manager` Stages 1b and 3 say."

**S9 `plugins/glab/skills/bootstrap/SKILL.md`**

- S9.1 `:100-101` → "Normal work runs a one-page plan, a plan check and a review, with no conformance stage; trivial work is done directly. Each check stage runs at most two rounds, a third only on a critical or high finding; `glab:manager` → *Pick the tier* has the table and the round caps."

**S10 `AGENTS.md` *One fact*** (`:106-109`)

- S10.1 "the review round cap (`…reviewer.md`, `…ship.md`, `…manager/SKILL.md`, `…bootstrap/SKILL.md`)" → "the round caps — Stage 1b, Stage 3 and Stage 5 at most 2 rounds at every tier, a third only on a `critical` or `high` finding of round 2 recorded as a `## Decisions` line, none past 3 (the same four files)".
- S10.2 After the reviewer's-verdict-lines entry, add: "the severity levels — `critical`, `high`, `medium`, `low` and their meanings (`plugins/glab/skills/audit/SKILL.md`, `plugins/glab/agents/reviewer.md`, `plugins/glab/agents/analyzer.md`); every round a new agent, Rule 5's report check the one resume (`plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/develop.md`, `plugins/glab/commands/ship.md`, `plugins/glab/commands/analyze.md`); the mapping files `map-<area>.md` and the round copies `<name>.r<n>.md` (`plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`); the handoff file `plan/SESSION-HANDOFF.md` (`plugins/glab/skills/bootstrap/SKILL.md` step 5, `plugins/glab/skills/manager/SKILL.md` Rule 2)".

- S10.3 *(round 2)* After S10.2's entries, add: "the `glab` context hook — the modes `prompt`, `agent` and `stop` on `UserPromptSubmit`, `PostToolUse` with matcher `Agent` and `Stop`, the line `glab: context <n>k (last completed call)`, the `Stop` message, and the steps 300k and every 100k after it (`plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh`, `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/manager/SKILL.md`, `README.md`)".

**S11 `plugins/glab/.claude-plugin/plugin.json`**

- S11.1 `"version": "0.8.0"` → `"version": "0.9.0"`.

**S12 `plugins/glab/hooks/hooks.json`** *(round 2)*

- S12.1 Replace the file with (key order as shown; F18 proved this order prints `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`):

      {
        "hooks": {
          "SessionStart": [
            { "hooks": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/manager-bootstrap.sh", "timeout": 5 } ] }
          ],
          "UserPromptSubmit": [
            { "hooks": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/context-size.sh prompt", "timeout": 5 } ] }
          ],
          "PostToolUse": [
            { "matcher": "Agent", "hooks": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/context-size.sh agent", "timeout": 5 } ] }
          ],
          "Stop": [
            { "hooks": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/context-size.sh stop", "timeout": 5 } ] }
          ]
        }
      }

  The `SessionStart` entry is unchanged in content; the layout of the existing file (one key per line) may be kept for it. JSON has no comments, so the reasons live in the script header (S13.1).

**S13 `plugins/glab/scripts/context-size.sh`** *(new, round 2; mode `0755`)*

- S13.1 Header comment, in the style of `memory-sync.sh`'s: what it is (the `glab` context hook, one script for three events); the three modes and the event each serves; why it exists (a hook fires every time, but cannot make the model act — hence `stop` speaks to the user: D45); the contract (D34); the measure and why "last completed call" (D31, including the documented transcript lag); why 8 MiB (D32); why `stop` never blocks (D46); that it runs in every session where `glab` is enabled and why that is harmless (D35); that it reads no `tool_input`, `tool_response` or `prompt` (D44); `jq` required, none means silence (D34). Every number in the code — `8388608`, `300000`, `100000`, `999` — carries its reason beside it (`glab:comments`).
- S13.2 `#!/usr/bin/env bash`, `set -uo pipefail` (no `-e`: every path must reach `exit 0`); `MODE=${1:-}`; one function `fail() { printf 'glab context-size: %s\n' "$1" >&2; exit 0; }`. Mode not `prompt`, `agent` or `stop` → `fail "unknown mode: <mode>"` (the mode word only, never input).
- S13.3 `command -v jq` or `fail 'jq not found'`. `tp=$(jq -r '.transcript_path // empty | strings')` reading stdin; a parse error → `fail 'hook input is not JSON'`; empty, not a regular file, or unreadable → `fail 'no readable transcript'`. The path itself is never printed.
- S13.4 One `jq -n -R -r` program over `tail -c 8388608 -- "$tp"` (the read of F17 and F21 in one pass), with `def total: (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0);` and a `reduce (inputs | fromjson? | objects | select(.isSidechain != true)) as $e ({base: 0, cur: null}; …)`: an assistant entry whose `.message.usage` is an object with `total > 0` sets `cur`; a user entry that is not `isMeta` and whose `.message.content` is a string, or an array with no `tool_result` item, sets `base = (cur // 0)`; anything else leaves the state. Its output: nothing when `cur` is null; otherwise `<k> <cur> <base>` with `k = (cur + 999) / 1000 | floor`. Empty output → `fail 'no usage in the transcript'`. jq's stderr goes to `/dev/null` so no line of the transcript can reach stderr; the script's own message replaces it.
- S13.5 Output by mode, each built by `jq -n -c --arg c "<text>"` and the only write to stdout:
  - `prompt` → `{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":$c}}`, `$c` = `glab: context <k>k (last completed call)`.
  - `agent` → the same with `"hookEventName":"PostToolUse"`.
  - `stop` → with `step(x)` = `-1` when `x < 300000`, else `(x - 300000) / 100000` rounded down (bash integer arithmetic): when `step(cur) > step(base)`, `{"systemMessage":$c}` with `$c` = `glab: context <k>k (last completed call) — a good point to /compact, or to /clear between tasks`; otherwise nothing. Never any other key (D46).
- S13.6 `exit 0` as the last line, and every `fail` exits 0.

**S14 `tests/context-size.test.sh`** *(new, round 2; mode `0755`)*

- S14.1 Frame as D39. `usage: context-size.test.sh <path to context-size.sh>`, the path made absolute as `tests/memory-sync.test.sh` does; work directory `W=$(mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX")`, `trap 'rm -rf "$W"' EXIT`. A helper runs the script with a mode, stdin from a string, captures stdout, stderr and rc; every case asserts rc `0`, and that neither stdout nor stderr contains `SECRET` (each fixture's user lines hold `SECRET=abc`; D36).
- S14.2 Cases (`T<n>` ids; each `ok` or `FAIL` with a short reason):
  - T1 `agent`, normal transcript (user, assistant 5 + 142000 + 300, user) → stdout is one line, `jq -e` parses it, `.hookSpecificOutput.hookEventName == "PostToolUse"`, `.additionalContext == "glab: context 143k (last completed call)"`, stderr empty.
  - T2 the `SECRET` assertion, counted as its own case over every run of T1–T19.
  - T3 `prompt`, same transcript → `hookEventName` `UserPromptSubmit`, same text.
  - T4 missing file → stdout empty, stderr `glab context-size: no readable transcript`.
  - T5 transcript path is a directory → as T4.
  - T6 no assistant usage (user lines only) → stdout empty, stderr `… no usage in the transcript`.
  - T7 empty transcript file → as T6.
  - T8 truncated last line (`{"type":"assistant","mess` with no newline) after a complete assistant entry → the complete entry's number.
  - T9 huge: 30 lines of 1 MB, then a 6 MB assistant entry, then a user line (a file over 36 MB, past the window) → that entry's number; the elapsed time printed in the `ok` line, not asserted.
  - T10 an assistant entry longer than the window, with every other assistant entry outside it → stdout empty (D32's limit: silence, not a wrong number, when nothing else is in the window).
  - T11 malformed stdin (`not json{`) → stdout empty, stderr `… hook input is not JSON`.
  - T12 empty stdin, and stdin `{}`, and `{"transcript_path": 7}` → stdout empty, stderr `… no readable transcript`.
  - T13 7 tokens → `glab: context 1k …` (never `0k`).
  - T14 the last assistant entry has zero usage, an earlier one 200000 → `200k` (D31's `> 0`).
  - T15 the last assistant entry is `"isSidechain": true` with 900000, an earlier main one 200000 → `200k`.
  - T16 unknown mode `foo`, and no mode → stdout empty, stderr `… unknown mode: foo` / `… unknown mode: `.
  - T17 no `jq`: `PATH` set to a directory of links to `bash`, `env`, `tail` and nothing else → stdout empty, stderr `… jq not found`.
  - T18 `stop` cases, each asserting that stdout is empty or exactly one object whose only key is `systemMessage` (`jq -e 'keys == ["systemMessage"]'`): below 300k → empty; crossed 300k in the turn (F21's second fixture) → `glab: context 320k (last completed call) — a good point to /compact, or to /clear between tasks`; already past 300k in the same step → empty; crossed 400k → a message; dropped after a compact → empty; no prompt in the window, 420k → a message; a crossing whose only "prompt" after it is a `tool_result` or an `isMeta` entry → the base is the earlier real prompt.
  - T19 `stop` never blocks: over every `stop` run of T18, stdout never contains `decision`, `continue`, `reason`, `hookSpecificOutput` or `additionalContext`.
- S14.3 Last line `PASS <n>/<n>` or `FAIL <k>/<n>`; exit 1 on any failure. The test starts no background process, so it kills none (*Tests clean up by PID* holds trivially).

**S15 `AGENTS.md`** *(round 2; S10 is its *One fact* part)*

- S15.1 *Layout* `:11-12`: "`hooks/hooks.json` and `scripts/manager-bootstrap.sh`." → "`hooks/hooks.json`, `scripts/manager-bootstrap.sh` and `scripts/context-size.sh`."
- S15.2 *Gates* `:23`: "The test creates its work directory under `$TMPDIR`." → "The tests create their work directories under `$TMPDIR`."
- S15.3 *Gates* `:27-29`, the block becomes:

      for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh tests/memory-sync.test.sh tests/context-size.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
      shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh plugins/glab/scripts/context-size.sh tests/memory-sync.test.sh tests/context-size.test.sh; echo "rc=$?"
      bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh
      bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh

  and `:31` "Green is: three `rc=0` lines; `rc=0` with no findings; every line `ok`, last line `PASS n/n`." → "Green is: five `rc=0` lines; `rc=0` with no findings; for each test, every line `ok` and its last line `PASS n/n`."
- S15.4 *Gates* `:67`: "`Hooks (1)  SessionStart`" → "`Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`". The `user_config` line (`:52`, `:70`) is unchanged: its glob already covers `plugins/glab/hooks/hooks.json`, and green stays `:0` after each, `rc=1`.
- S15.5 *Tests* `:85`: after "`tests/memory-sync.test.sh` does this." add "`tests/context-size.test.sh` fakes a missing `jq` the other way round, with a `PATH` that lacks it."
- S15.6 *Rules* `:103`: "**The hook contract of `memory-sync.sh` does not change without a plan:** the mode names, exit 0 on every path, nothing on stdout, messages on stderr." → "**The hook contracts do not change without a plan.** `memory-sync.sh`: the mode names, exit 0 on every path, nothing on stdout, messages on stderr. `context-size.sh`: the mode names, exit 0 on every path, on stdout one JSON object or nothing, messages on stderr, and in mode `stop` no key but `systemMessage` — it never blocks a turn or continues one." (The `memory-sync.sh` words are the current `:103-104`, checked at `7df69a8`.)

**S16 `README.md`** *(round 2)*

- S16.1 `:9`, the `glab` row: "· a `SessionStart` hook that injects the session bootstrap rules" → "· a `SessionStart` hook that injects the session bootstrap rules · a context hook on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop` that tells the session its context size and tells you when a turn crosses 300k or a further 100k".
- S16.2 `:31-32`: "`jq` is optional: the `glab` hook falls back to plain text without it." → "`jq` is optional: without it the `glab` `SessionStart` hook falls back to plain text, and the context hook says nothing — `glab:manager` then counts dispatches instead."
- S16.3 After the paragraph at `:24-27` ("A plugin cannot ship global instructions …"), add one paragraph: "`glab`'s context hook adds one line of about ten tokens to the model's context on each message you send and after each subagent dispatch, and at the end of a turn that crossed 300k, 400k, … it shows you `glab: context <n>k … a good point to /compact, or to /clear between tasks`. It never blocks or prolongs a turn. The number is the last completed model call's, and can trail the turn a little. It runs in every session where `glab` is enabled, and not at all when hooks are turned off (`disableAllHooks`, `--bare`)."

### After

Each search is run from the repo root with `/usr/bin/grep`; each lists what
it must print, so a skipped step shows as a missing or extra line.

- V1 Old caps gone: `grep -rn -E 'max 4 rounds|max 3 rounds|Maximum 4|Maximum 3|at most three|round 2/4|One pass at normal|one pass \||One round at normal|one at normal tier|one analysis and one review|round 1/1|at round 4|the review round cap' plugins/glab AGENTS.md; echo rc=$?` → no line, `rc=1`. An absence check: it cannot tell a tree where the text was rewritten wrongly; V2–V3 discriminate.
- V2 New cap: `grep -rli -E 'at most (2|two)( [a-z>→-]+)* rounds|max 2 rounds' plugins/glab AGENTS.md | sort` → exactly `AGENTS.md`, `plugins/glab/agents/reviewer.md`, `plugins/glab/commands/ship.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`. At `7df69a8` it prints only `plugins/glab/skills/manager/SKILL.md` (the full-tier 1b cell), so it discriminates for the other four files and V3 does for the manager.
- V3 Tier rows: `grep -n -E '^\| (1b|3|5) ' plugins/glab/skills/manager/SKILL.md` → three lines: `1b … | — | max 2 rounds | max 2 rounds |`, `3 … | — | — | max 2 rounds |`, `5 … | — | max 2 rounds | max 2 rounds |`. Round-3 line: `grep -c -F -- '- round 3: <stage>' plugins/glab/skills/manager/SKILL.md` → `1`.
- V4 Severity: `grep -n -F 'severity:' plugins/glab/agents/reviewer.md plugins/glab/agents/analyzer.md` → one template line in each; `grep -l -F 'unbounded memory growth' -r plugins/glab | sort` → `agents/analyzer.md`, `agents/reviewer.md`, `skills/audit/SKILL.md`.
- V5 New agents: `grep -rl -F 'new agent' plugins/glab | sort` → exactly `commands/analyze.md`, `commands/develop.md`, `commands/ship.md`, `skills/manager/SKILL.md`; `grep -l -F 'new planning agent' -r plugins/glab | sort` → `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`; `grep -c -F '## A fix round' plugins/glab/agents/developer.md` → `1`.
- V6 Resumes: `grep -rn -E 'resum' plugins/glab | cut -d: -f1,2` → exactly `bootstrap/SKILL.md:3`, the Rule 5 version-floor line, the Rule 5 report-check line, the Rule 2 bullet, the *What you never do* bullet (all `manager/SKILL.md`), `commands/develop.md` (S7.2), `commands/ship.md` (two: `:28` and S6.1).
- V7 Map files: `grep -rl -F 'map-<area>.md' plugins/glab AGENTS.md | sort` → `AGENTS.md`, `agents/analyzer.md`, `agents/developer.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`; `grep -rn -F 'findings-<area>' plugins/glab AGENTS.md` → only the S1.10 sentence that says why the name is not used.
- V8 Round copies: `grep -rl -F '.r<n>.md' plugins/glab AGENTS.md | sort` → `AGENTS.md`, `agents/analyzer.md`, `agents/developer.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`.
- V9 Planner search: `grep -n -F 'only **calls**' plugins/glab/skills/plan-first/SKILL.md plugins/glab/skills/manager/SKILL.md` → one line in each; `grep -c -F 'you plan to change or call' plugins/glab/skills/plan-first/SKILL.md` → `0`.
- V10 Context *(round 2)*: `grep -n -E 'glab: context|· context <n>k|300k|dispatches <d>|/compact' plugins/glab/skills/manager/SKILL.md` → the S1.16 lines and the S1.4, S1.7, S1.18 lines; `grep -rl -F 'CLAUDE_CODE_SESSION_ID' plugins README.md AGENTS.md tests; echo rc=$?` → no line, `rc=1` (round 1's command is not written anywhere); `grep -rl -F 'glab: context' plugins README.md AGENTS.md tests | sort` → exactly `AGENTS.md`, `README.md`, `plugins/glab/scripts/context-size.sh`, `plugins/glab/skills/manager/SKILL.md`, `tests/context-size.test.sh`; `grep -c -F 'SESSION-HANDOFF' plugins/glab/scripts/manager-bootstrap.sh` → `0` (unchanged, D22).
- V11 `AGENTS.md`: `grep -n -E 'the round caps|the severity levels|every round a new agent|the handoff file' AGENTS.md` → four lines inside *One fact*.
- V12 Version: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.9.0`; `jq -r .version plugins/memory-sync/.claude-plugin/plugin.json` → `0.1.0`.
- V13 Throwaway run, under `$TMPDIR`, removed after, pasted in `result.md`: (a) the S1.14 snapshot lines, copied from the edited file, in a new repo with a tracked change, a staged change, an untracked file and an ignored file, then a second snapshot after a further change — expect F8's shape (status and index unchanged, the delta lists only the later change, `git diff --quiet` rc=1, no `.idx` left); (b) the S1.12 `diff -u` on a copy and an amended copy — rc=1, and rc=0 on identical files. *(Round 2: round 1's part (c), the inline context command, is gone with the command; the hook script is covered by V17.)*
- V14 Prefixed names: `grep -n -E '`(manager|plan-first|audit|bootstrap|security|reviewer|analyzer|developer)`' plugins/glab/skills/manager/SKILL.md plugins/glab/skills/plan-first/SKILL.md plugins/glab/agents/*.md plugins/glab/commands/*.md plugins/glab/skills/bootstrap/SKILL.md` → no line in text this change added (compare with the same search at `7df69a8`).
- V15 Both gate blocks of `AGENTS.md` *Gates*, as S15.3–S15.4 leave them: five `rc=0` lines; `shellcheck` `rc=0`; both tests every line `ok`, last line `PASS n/n`; `Skills (14)`, `Agents (5)`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop` (F18); `memory-sync` unchanged; the rest as F14.
- V16 Hooks stated *(round 2)*: `jq -r '.hooks | keys_unsorted | join(",")' plugins/glab/hooks/hooks.json` → `SessionStart,UserPromptSubmit,PostToolUse,Stop`; `jq -r '.hooks[][] | (.matcher // "-") + " " + (.hooks[] | .command + " " + (.timeout|tostring))' plugins/glab/hooks/hooks.json` → four lines, the `PostToolUse` one with matcher `Agent`, the three `context-size.sh` ones with modes `prompt`, `agent`, `stop`, every timeout `5`; `grep -n -E 'Hooks \(' AGENTS.md` → `:67` with the S15.4 text and `:68` unchanged; `grep -n -F 'UserPromptSubmit' README.md AGENTS.md` → S16.1, S16.3 (if it names the event), S10.3 and S15.4; `grep -c -F 'falls back to plain text without it' README.md` → `0`; `grep -n -E 'hook contract|hook contracts' AGENTS.md` → the S15.6 line.
- V17 The new test *(round 2)*: `bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh` → every line `ok`, `PASS 19/19` (or the count S14 ends with). It discriminates: run against three throwaway copies of the script under `$TMPDIR`, removed after, it must fail — (a) `stop` with `"decision":"block"` added to its JSON → T18 and T19 `FAIL`; (b) the rounding `+ 999` removed → T13 `FAIL`; (c) the `isSidechain` filter removed → T15 `FAIL`. Paste the three `FAIL` lines in `result.md`. Against a missing script path it prints the usage line and exits 2.
- V18 The `stop` contract in the code *(round 2)*: `grep -n -E 'decision|"continue"|exit 2|additionalContext' plugins/glab/scripts/context-size.sh` → only comment lines that say `stop` never does them, and the `additionalContext` of modes `prompt` and `agent`; `stat -c %a plugins/glab/scripts/context-size.sh tests/context-size.test.sh` → `755` twice.

### Integration — I1, needs the user's OK *(round 2)*

Calls a model, so it costs a small amount of usage (*costs money*, `glab:manager` Rule 3). A throwaway `CLAUDE_CONFIG_DIR` is not logged in (F18), so the user runs both parts in their own terminal from the repo root; an agent never copies credentials (D41). Neither part loads `memory-sync` (F18). The run writes a session transcript into the user's own config, as any session does; no agent reads it.

- I1a — the two `additionalContext` events and the lag. With `TMPDIR` set to the host's temp directory:

      out=$(mktemp "$TMPDIR/fcr-i1a.XXXXXX") && claude -p --max-turns 6 --plugin-dir ./plugins/glab \
        --output-format stream-json --verbose --include-hook-events \
        'This is a hook test. Load no skill and read no file. Dispatch exactly one foreground subagent with the Agent tool, subagent_type general-purpose, prompt "Reply with the word ok and nothing else". After it returns, quote verbatim every line in your context that begins with "glab: context", or write NONE.' >"$out"; echo "rc=$? out=$out"

  Then an agent reads only `"$out"` and pastes: the hook events and their outputs for `UserPromptSubmit`, `PostToolUse` and `Stop` (whatever form `--include-hook-events` gives — UNVERIFIED); the model's final text; the `message.usage` of the assistant message that issued the Agent call and of the one before it. Pass: the final text quotes a `prompt` line and an `agent` line of the form `glab: context <n>k (last completed call)`. The lag: the `agent` line's `<n>` equals the rounded total of the Agent-calling message (flushed before `PostToolUse`) or of the one before it (not flushed) — record which. `stop` says nothing here: a tiny run never reaches 300k. If the installed `glab` also loads, each line may appear twice; record it, it does not fail the run. Remove `"$out"` after.
- I1b — the `Stop` message, interactive. An agent makes a throwaway copy of `plugins/glab` under `$TMPDIR` and, in the copy only, lowers the two step constants of `context-size.sh` from `300000` and `100000` to `1000` and `1000`; the user starts `claude --plugin-dir <that copy>` from the repo root, sends `Reply with the word ok.`, and reports: whether `glab: context <n>k (last completed call) — a good point to /compact, or to /clear between tasks` was shown to them at the end of the turn; that the turn ended there (no further model output, no "continuing"); then sends `Quote verbatim any line in your context that begins with "glab: context".` and reports whether the model quotes the `Stop` text — which says whether the model sees `systemMessage` (F20, UNVERIFIED). The agent removes the copy after.
- Pass: I1a quotes both lines; I1b shows the message to the user and ends the turn. The lag and whether the model sees the `Stop` text are recorded either way.

**Fallback plan.** If I1b shows no message, or the turn continues, `stop` is not usable: a new planning agent amends this plan to drop it — the `Stop` entry of S12, the mode and its comments in S13, T18–T19, the `Stop` words of S10.3, S15.4, S15.6 and S16, the green line becoming `Hooks (3)  SessionStart, UserPromptSubmit, PostToolUse` — and the other two events stand (D45). The developer does not drop it on their own.


Test coverage (`AGENTS.md` *Tests*), as a list *(rewritten in round 2)*:

- S13 (`context-size.sh`): S13.2 modes and `fail` — T16; S13.3 input and path — T4, T5, T11, T12, T17 (`jq` missing); S13.4 the read — T1, T3, T6–T10, T13–T15, and T18's prompt cases for `base`; S13.5 output per mode — T1 (`agent`), T3 (`prompt`), T18 (`stop`); S13.6 exit 0 — asserted on every run; D36's no-leak — T2 over every run; D46 never blocks — T18's key check and T19.
- S12 (`hooks.json`): V15 (`plugin details`), V16 (`jq` over the file); the `user_config` gate.
- S14 (the test itself): V17's three mutants, which show it fails a wrong script; `shellcheck` and `bash -n`/`test -x` (V15).
- S1–S11, S15, S16 (Markdown and manifest): V1–V12, V14, V16; their prescribed commands by V13.
- Not covered by any case, and why accepted: that the hook's line reaches the model and that `Stop`'s `systemMessage` reaches the user — I1, needing the user's OK, because no test can run a model; the transcript-flush lag — I1a measures it; a real transcript's shape on other CLI versions — fixtures only, by the brief; the `Task` alias on CLIs older than 2.1.63 (FU11); the managed-policy settings (FU15); timing on other hosts (T9 prints it); that a live session follows the prose (D-wide UNVERIFIED).

Back-out: `git revert <commit>`; because the revert changes `plugins/glab/`,
it raises `glab` to `0.9.1` in the same commit (*A change under
`plugins/<name>/` raises that plugin's version*). Round copies and map files
already written in other repos' plan folders stay; they are inert text. The
hooks stop with the revert once an installed copy updates; the script keeps
no state, so nothing is left behind.

## Follow-ups

- FU1 A dedicated `glab:planner` agent (out of scope by the brief).
- FU2 Splitting the implementation steps (5–7) out of `glab:plan-first` (out of scope by the brief).
- FU3 The user-level copies under `~/.claude` — the user ports them (out of scope by the brief).
- FU4 The "cleanup glob deleted a reviewer report" incident (out of scope by the brief).
- FU5 `agents/analyzer.md` has no plan-check mode: `BUILDABLE` / `NOT BUILDABLE` appear only in `skills/manager/SKILL.md` (F7); its Steps 2–3 are written for an implementation.
- FU6 `glab:plan-first` prescribes `findings.md` at full tier, but a subagent planner's Write is refused that name (F9 and two incidents); a full-tier planner subagent cannot write its findings file as the skill says.
- FU7 Stage 5 does not say how a review round after the first learns what changed since the last one: `reviewer.md:94` has the reviewer ask, and `ship.md:32` has the caller scope it, while Stage 5 gives the reviewer the target and nothing else (F6).
- FU8 Snapshot limits: a nested repository is recorded as a gitlink with a warning, and a large untracked directory that is not ignored is hashed in full (F8, not tested).
- FU9 Whether `CLAUDE_CODE_SESSION_ID` and the transcript layout hold on other hosts and versions, and whose id a subagent sees (F15, UNVERIFIED). *Closed as moot in round 2*: nothing uses the variable any more (D30).
- FU10 Whether the transcript is flushed before `PostToolUse` and `Stop` run, and how far the figure lags (F20, D31) — I1a measures one case; closed by I1 if it is conclusive.
- FU11 Whether the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 (F20, D43, UNVERIFIED).
- FU12 `claude plugin details` labels every hook "harness-only — no model context cost", which is not true of one that returns `additionalContext` (F18): the CLI's wording, to report upstream if anyone wants to.
- FU13 A `PreToolUse` hook on `Agent` that refuses (`permissionDecision: "deny"`) a dispatch missing `effort` or the `AGENTS.md` instruction — the coordinator's follow-up, not planned here; whether the Agent `tool_input` carries `effort` is UNVERIFIED (F20).
- FU14 An assistant entry longer than the 8 MiB window is not seen (D32): an older call's figure, or silence. Widen the window or read backwards if it is ever seen.
- FU15 Whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks (F20, D48, UNVERIFIED).
- FU16 The hooks the user did not choose — `PostToolBatch`, `SubagentStop` — recorded by D28/D29, not planned.

## Record

After the push, `glab:manager` Stage 8 updates:

- `docs/specs/workflow.md` (primary): *How it works now* — the tier bullet (`:59-68`) and the round-caps bullet (`:169-173`) restated for 2 (+1) at every tier with the reviewer's round-2 rule; new bullets for every round a new agent (Rule 2), the delta re-checks of 1b and 3 with their two mechanisms, explore once and `map-<area>.md`, the narrower call-site audit, the context rule (the hook's line read at every handoff line, the steps 300k and every 100k after it, the task-boundary `/clear`, the dispatch-count fallback only when no line came, the handoff file) and the handoff line's `· context <n>k`; *(round 2)* a bullet for the context hook — one script, three modes on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop`, the measure, the 8 MiB window, the `Stop` message to the user and why it goes to the user (a hook fires every time but cannot make the model act), that it never blocks, and what I1 proved; the owners list at `:7-13` gains `plugins/glab/scripts/context-size.sh` and `plugins/glab/hooks/hooks.json`; the agents bullet gains the `severity:` line, the analyzer's re-check section and the developer's fix-round section. *Decisions that still bind*: D2–D16, D19–D27 and D29–D48 tagged `[flow-cheaper-rounds/plan.md D<n>]`, with `[bug-reviewer-findings/questions.md Q3]` and `[sync-local-edits/result-followups.md D11]` marked superseded by D2, and D17–D18 recorded as superseded by D29–D30 (round 1's inline command, never shipped). *Known limits*: F8's untested cases, F9's partial probe, F1's inferred savings; *(round 2)* the 8 MiB window (D32), the lag (D31, with I1a's result), the documented limits of "impossible to bypass" — plugin disabled, `--bare`, `disableAllHooks`, managed hook policy, an interrupted turn firing no `Stop` (D48) — and every UNVERIFIED of F20 that I1 did not settle. *Follow-ups*: FU1–FU8 and FU10–FU16 open, FU9 closed as moot (D30); `[sync-local-edits/follow-ups.md 18]` and `[sync-local-edits/follow-ups.md 19]` closed by this change. *Incidents*: the Write refusal of `findings-probe.md` and `findings.md` for a subagent, a third time, now with `map-probe.md` accepted.
- `docs/specs/marketplace.md`: *Versions* — `glab` `0.9.0`; the *One fact* entries this change rewrote or added (S10, S10.3); `[feature-plugin-marketplace/questions.md S3]` marked superseded by D2; *(round 2)* *What each plugin holds* (`:32-37`) — `glab` with four hook events, `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Stop`; *The gates* (`:59-66`) — five scripts under `bash -n`/`test -x` and `shellcheck`, two tests, the new green line; the *Layout* and the hook-contract rule (S15.1, S15.6); *Testing without installing* — `--plugin-dir ./plugins/glab` loads `glab` alone (F18); *Incidents* — none new unless I1 produces one.

No audit file under `plan/` is acted on.
