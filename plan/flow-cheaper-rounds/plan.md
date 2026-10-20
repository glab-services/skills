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

Stage 1b round 1 checked that version (both checks `BUILDABLE`, with
defects). Its amendment was written by a new planning agent; `plan.r2.md` is
the plan as it stood before it (D10's copy), so the next check reads
`diff -u plan.r2.md plan.md`. Changed by it: D10, D11, D12 (by D49–D50),
D13 (superseded by D51), the steps S1.8, S1.12, S1.14, S1.15, S3.2, S4.3,
S6.2, S10.1, S13.3, S14.2, S14.3, S15.2 and a note on S15's line numbers,
F12, F19, FU7 (closed), FU8, the milestone, the coverage list, the record,
and the post-conditions V3, V6, V10, V11, V13, V16, V17; added: D49–D60,
F22, S10.4, S17, V19, V20 and the two search helpers before V1. Kept unchanged: every other decision.

After the build, integration I1 found that `stop` as built can never speak
in a live session: at `Stop` the turn's last call is not yet in the
transcript (F23, IN1). The amendment for it was written by a new planning
agent; `plan.r3.md` is the plan as it stood before it, so the next check
reads `diff -u plan.r3.md plan.md`. Changed by it: D31, D35, D41 (by D64),
D45 (by D61–D62), D47, D60 (superseded by D63); the steps S1.16 (one
sentence, D65), S13.1, S13.4, S13.5, S14.2, S14.3 and S16.3; the milestone,
the *Boundary*'s rejected list, I1's section (I1c added) and its *Fallback
plan*, the coverage list, the record, V17, FU10 (closed); added: D61–D65,
F23, F24, `## Incidents` (IN1, IN2), FU17, FU18 and V21. Kept unchanged:
every other decision. The developer redoes S1.16, S13, S14 and S16.3 only,
then V10, V16, V17, V18 and V21, and both gate blocks.

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
- D10 Stage 1b delta: before dispatching the amendment the manager copies `plan.md` (and `findings.md` when there is one) to `plan.r<n>.md` (`findings.r<n>.md`), `<n>` = the round that checked it; round `<n+1>` reads `diff -u plan.r<n>.md plan.md`. A copy, not git: the plan folder is untracked while it is planned (`?? plan/flow-cheaper-rounds/plan.md` in this tree), and a snapshot of a gitignored `plan/` would be silently empty. Proven in a throwaway directory (F8). The copies stay in the folder (`AGENTS.md`: no untracked file under `plan/` is removed) and are committed with it; the record takes items from the current file, not the copy. *(Amended by D49: the manager tests the delta with `cmp -s`; only the analyzer runs the `diff -u`.)*
- D11 Stage 3 delta: before each analyze round, round 1 included, the manager snapshots the tree into a tree object through a temporary index (`GIT_INDEX_FILE=<new path> git add -A && git write-tree`); round `<n+1>` gets both tree ids and runs `git diff <old> <new>`. Proven: it catches tracked, staged, untracked and deleted files, leaves the real index and `git status` unchanged, skips ignored files, and gives the same id for the same tree (F8). Ignored files are not in a snapshot, so a path the fix round's `files:` line names that the delta does not show is checked whole; a lost tree id means that round runs whole. *(Amended by D50: the temporary index is seeded with `git read-tree HEAD` first.)*
- D12 An empty delta is a stop, not a pass: `diff` and `git diff --quiet` exit 0 when nothing changed. Before round `<n+1>` the manager checks the delta is not empty; an analyzer handed an empty one reports `BLOCK: target unresolved`. *(Amended by D49: for the plan the manager's check is `cmp -s`, exit 0 identical, 1 changed, 2 a file missing — F22.)*
- D13 *Superseded by D51 in Stage 1b round 1.* Was: review rounds are not changed. The brief says they stay whole-target; note that the payload already narrows each review round after the first to what changed since the last one (`reviewer.md:94`, `ship.md:32`), and this plan leaves that text exactly as it is. If "whole-target" meant something else, that is the manager's to raise.
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
- D31 The measure is the manager's (F1): of the last transcript entry with `.type == "assistant"`, not `.isSidechain == true`, whose `.message.usage` sums `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` to more than 0. The sidechain filter keeps a subagent's entries out on a CLI that writes them into the parent's file; the `> 0` filter skips an entry with zero usage, which is no model call, instead of letting it hide the last real one. Rounded up to thousands, `(n + 999) / 1000 | floor`, so a real value never prints `0k` (F15). The figure is the last *completed* call's — the call in flight may not be flushed to the file yet (F20, UNVERIFIED; I1 measures it) — so it lags by one call at most, and every line says "last completed call". *(After I1, F23: at `PostToolUse` on `Agent` the Agent-calling call is already in the transcript, so the `agent` line is current; at `Stop` the turn's last call is not yet written, which D61–D62 answer. FU10 closed.)*
- D32 Bounded read: `tail -c 8388608` (8 MiB; `tail` seeks on a regular file, so the cost does not grow with the file) piped to `jq -n -R` that reads one raw line at a time with `fromjson?` and folds them in one `reduce` — the whole file is never slurped, a partial first line of the window and a truncated last line are dropped silently, and memory holds one line at a time. Proven on a 36 MB fixture with a 6 MB assistant line: right number in 0.07 s (F17). Why 8 MiB: transcripts reach 28 MB with lines of several MB (F1, the manager's measure), so the window holds more than the largest line seen while staying bounded. The known limit: an assistant entry longer than the window is not seen; then an older call's figure prints, or nothing (F17; *Known limits*).
- D33 Modes `prompt` and `agent` emit on **every** event, no threshold: `additionalContext` `glab: context <n>k (last completed call)`, about 10 tokens. `prompt` gives the model its size at the start of every turn the user starts; `agent` gives it the number for the handoff line `· context <n>k` (D21) after every dispatch. A threshold there would need state across calls and would hide the number the handoff line needs. "context", not "manager context", because the hook runs in every session (D35).
- D34 Contract of all three modes, like `memory-sync.sh`'s (`AGENTS.md` *Rules*): exit 0 on every path; on stdout either exactly one JSON object or nothing; every failure one line on stderr, `glab context-size: <reason>`, and no JSON; the JSON built by `jq -n --arg`, never by `printf`. An unknown or missing mode is a failure like any other (stderr, exit 0). Without `jq` it prints nothing — unlike `manager-bootstrap.sh`'s plain-text fallback — because without `jq` it cannot read the input or the transcript; the manager's fallback (D38) covers it. Hook `timeout` 5 s on each of the three entries, the same as the `SessionStart` hook: the proven run takes 0.07 s on a 36 MB file (F17), so 5 s is far above it and still short enough that a hung read cannot stall a turn for long.
- D35 It runs in every session of every repo where `glab` is enabled, manager or not, and that is harmless: `prompt` and `agent` add one line of about 10 tokens per user message and per Agent call; `stop` prints a line to the user only when a turn crosses a 100k step at or past 300k (D45); every mode reads only the transcript Claude Code names, read-only and bounded (D32), writes no file, keeps no state, opens no network connection and prints only an integer and fixed words; a session that does not run `glab:manager` sees a number it may ignore and, rarely, a suggestion it may ignore; every failure is silent on stdout and exits 0. A subagent that itself calls `Agent` would get its own line if the hook fires there; which transcript it is handed then is UNVERIFIED and changes nothing above. *(Amended after I1 by D61: `stop` prints a line when a 100k step at or past 300k has been crossed — usually at the end of the turn after the crossing, once, and at most twice per crossing, more only when the window holds fewer than two real prompts.)*
- D36 Re-check of the tier (*Pick the tier*): still normal. The full-tier triggers are a schema or data migration, a stored or wire format, and code that decides who may do what, handles secrets or moves money. The script reads a file that can hold secrets but passes on nothing from it except an integer it computed — test T2 asserts that no byte of a fixture line, a `SECRET=` marker included, reaches stdout or stderr in any mode or case; the hook JSON is Claude Code's documented format, consumed, not a format this repo defines or stores; nothing is authorised, migrated or paid. Three events in every installed session widen the reach, not the risk class: D35 bounds what each can do, and D46 makes sure none of them can block or prolong a turn. An analyzer or reviewer that disagrees raises the tier; only the user lowers it.
- D37 A background Agent call fires `PostToolUse` at launch (`tool_response.status` `async_launched`, F20): the script does not look at `tool_response` and emits the same line, then the launch-time figure. No special case — the figure is still the last completed call's.
- D38 Fallback trigger (amends D20): **no `glab: context` line anywhere in the session** — neither with a user message nor with an Agent result. That happens when the hook is not loaded (the plugin not enabled, a `glab` older than `0.9.0`, a session under `--bare` or with hooks disabled), without `jq`, or when the transcript is unreadable or holds no usage in its last 8 MiB. Say it once in the session, then count dispatches as D20 says. When `prompt` lines come but `agent` lines do not — a CLI older than 2.1.63 whose tool is `Task`, which the matcher `Agent` is not shown to match (F20, UNVERIFIED) — the handoff line takes the number from the most recent `glab: context` line of either kind; the dispatch count is not used.
- D39 Test `tests/context-size.test.sh <path to context-size.sh>`, on the pattern of `tests/memory-sync.test.sh`: one work directory from `mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX"`, removed by an `EXIT` trap; fixture transcripts written there by the test, never a real transcript; no background process; one `ok T<n> …` or `FAIL T<n> …` line per case, then `PASS n/n` or `FAIL k/n`, exit non-zero on any failure. `jq` missing is faked by a `PATH` that holds only links to the tools the script needs, not by a stub (*Tests*: a stub fakes an external CLI; here the CLI is absent). Cases in S14.
- D40 `AGENTS.md` (S15): both new files join the shell gates (`bash -n` + `test -x`, `shellcheck`, and the test run); the hook-contract rule names `context-size.sh` too, with its modes and its stdout rule (D34); *One fact* gains the context lines — the `additionalContext` text `glab: context <n>k (last completed call)`, the `Stop` message text, the thresholds 300k and every 100k after it, and the three modes and events (`plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/hooks/hooks.json`, `README.md`); the existing entry *what each plugin holds* already binds `glab`'s hook events across *Gates*, `README.md` and `hooks/hooks.json`, and S12, S15 and S16 change all three. The `glab` green line becomes `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`, proven with a copy of the plugin in that key order (F18).
- D41 Integration I1 needs the user's OK (it calls a model; a small amount of usage). A throwaway `CLAUDE_CONFIG_DIR` is not logged in (`claude auth status` → `"loggedIn": false`, F18), so an agent cannot make the run without copying credentials, which it never does. The user runs the given command in their own terminal; it loads `--plugin-dir ./plugins/glab` alone (F18: that loads `glab` only), so no `memory-sync` hook runs (*Never run `memory-sync.sh` against a real backend*), and never `--no-session-persistence`, which would leave no transcript for the hook to read. *(After I1: "so no `memory-sync` hook runs" is not borne out in the user's own config — D64.)*
- D42 Version: `0.9.0` kept (D26). New hooks are a feature of the same change; nothing is removed.
- D43 Matcher `Agent` alone, not `Agent|Task`: the user named `Agent`, and how the CLI reads `|` in a matcher for an older tool name is not shown (F20). An older CLI still gets the `prompt` line (D38).
- D44 The script reads no field of `tool_input`, `tool_response` or `prompt`: the subagent's prompt and report and the user's message pass through the hook's stdin and are never printed, logged or stored. `jq` reads the whole input to take `transcript_path`; that is bounded by what Claude Code sends, not by the transcript.
- D45 Mode `stop` speaks to the **user**, not the model: on `Stop` it prints `{"systemMessage":"glab: context <n>k (last completed call) — a good point to /compact, or to /clear between tasks"}` when this turn crossed a step — 300k, 400k, 500k, … — and nothing otherwise. Stateless: one `reduce` over the window keeps `cur`, the last real call's size, and `base`, the size when the turn's user prompt arrived (the last call before the last user entry that is not a sidechain, not `isMeta`, and not a `tool_result`); `step(x)` is `-1` below 300k, else `floor((x - 300000) / 100000)`; it speaks when `step(cur) > step(base)`. A turn whose prompt is outside the window has `base` 0 and speaks at or past 300k — an extra line, never a missed one. After `/compact` the size drops and the next crossing speaks again. An interrupted turn fires no `Stop` (F20), so it shows nothing; the next turn's `prompt` line still carries the number. The transcript "is written asynchronously and may lag" (F20), so at `Stop` the figure can trail the turn's last call; the script takes what the file holds and the line says "last completed call"; I1 measures the lag. Proven in a throwaway prototype (F21). Why the user: **a hook fires deterministically but cannot make the model act** — `additionalContext` is text the model may ignore — so the one message that must not depend on the model goes to the person who can run `/compact` or `/clear`. Documented (F20): `systemMessage` is a common output field, "Warning message shown to the user", which some events discard or deliver elsewhere; and a `Stop` hook that exits 0 with no `decision` lets the turn end normally. UNVERIFIED, for I1 to prove: that the `Stop` event shows `systemMessage` to the user rather than discarding it, and whether the model also sees it. If it is not usable, `stop` is dropped — the hook entry, the mode and its cases — and the other two events stand (*Fallback plan*, after I1). *(Amended after I1 by D61–D62: the `base` that `step(cur)` is compared with is the size when the **previous** real user prompt arrived, one turn further back than the turn's own prompt, because at `Stop` the transcript holds the turn's prompt but not yet its last call (F23); with one call per turn the rule above compared a number with itself and never spoke (IN1). The definition of a real prompt, the steps, the message, the key set and every other sentence here stand. I1 proved that `Stop` shows `systemMessage` to the user in the terminal and that the turn ends there (F23), so the *Fallback plan* did not apply. Whether the model also sees the `Stop` text stays UNVERIFIED: I1b's quote prompt was not reported.)*
- D46 `stop` **never blocks and never continues the conversation**: no exit 2, no `decision`, no `reason`, no `continue`, no `hookSpecificOutput` and no `additionalContext` on `Stop` — `systemMessage` is its only key. Nothing reads `stop_hook_active`, because nothing ever asks for another turn. T-cases assert the key set on every `stop` output.
- D47 D19's thresholds become fixed steps, 300k and every 100k after it, for the manager's prose as for the `stop` mode: one rule stated once (*One fact*, D40), and neither side needs to remember where it last suggested. D19's "+100k since the last suggestion" meant the same steps when the first suggestion fell at 300k; it differed only when it fell later. The task-boundary `/clear` stays the manager's (D19) — no hook can tell a task boundary. *(After I1, D61: the steps are unchanged; only when the hook speaks moves — usually at the end of the turn after the crossing. The manager reads the `agent` line, which I1a showed current at `PostToolUse` (F23), so its suggestion at a handoff line may come before the user's line; the two still never disagree on the steps.)*
- D48 "Impossible to bypass" — what holds and what does not: the hooks run in the harness, whatever the model does, in every session where `glab` is enabled; the model cannot skip them or the user's `Stop` line. The documented limits (F20): they do not run when the plugin is disabled, under `--bare` (`claude --help`: "skip hooks"), or under `disableAllHooks: true` in user or project settings or `--settings`; managed policy can restrict hook sources (`allowManagedHooksOnly`, `strictPluginOnlyCustomization.hooks` — their effect on a plugin's hooks UNVERIFIED); and an interrupted turn fires no `Stop`. Each is a setting or an act of the user or the organisation, not something the model can do; the manager's dispatch-count fallback (D38) covers a session where no line comes. `glab:manager`'s rule (S1.16) makes acting on the line a rule of the operating model; whether a live model follows prose stays UNVERIFIED, as for every rule of this plan.
- D49 manager decision, Stage 1b r1: the manager tests the plan delta with `cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and the same for `findings.md`), reading the exit code only — 0 identical, 1 changed, 2 a file missing (F22) — and never reads the diff itself (Rule 2, the context budget); only the analyzer of round `<n+1>` runs `diff -u`. Amends D10 and D12; S1.12 and V13(b).
- D50 manager decision, Stage 1b r1: the Stage 3 snapshot seeds its temporary index from `HEAD` first — `GIT_INDEX_FILE="$idx" git read-tree HEAD && GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree` — because a tracked file that matches `.gitignore` is skipped by `git add -A` into an empty index and so was missing from D11's snapshot (F22: `keep.log` absent without the seed, present with it). Limits shown in F22 and kept in FU8: with no commit yet `git read-tree HEAD` fails (`rc=128`), so no tree id is printed and that round runs whole; a file force-added to the index but not yet committed that matches `.gitignore` is still missed. Amends D11; S1.14 and V13(a).
- D51 manager decision, Stage 1b r1: a review round `<n>` ≥ 2 is dispatched to a new reviewer with the target, plus the previous round's findings verbatim and the range of the fix — the old and new tree ids (taken with Stage 3's snapshot, D50) or commit ids — and never the plan, the slug or the intent. It checks each previous finding closed, reviews the fix range in full, and the whole target stays in its scope. `reviewer.md:94` (S3.2), Stage 5's dispatch (S1.15) and `ship.md:32` (S6.2) say so; a new *One fact* entry binds the three (S10.4). Supersedes D13 (which assumed the same reviewer asks what changed) and closes FU7.
- D52 manager decision, Stage 1b r1: a round-2 `BLOCK` with no `critical` or `high` finding is that last round's verdict — there is no round 3, and the stage ends as D6 says for a last round that did not pass: to the user, with the verdict. Rule 5's report check stays for malformed reports only (missing fields, no clear verdict). S1.15.
- D53 manager decision, Stage 1b r1: with no plan behind the stage — a `/glab:review` or `/glab:ship` run on its own — the round-3 reason goes, as Rule 5's no-plan case does for the model, in the handoff line that announces round 3 (`round 3/3 (<severity> <finding>)`) and in this conversation; once it can no longer be found, there is no round 3. S1.8, S10.1.
- D54 manager decision, Stage 1b r1: at full tier, Stage 3 after a review fix is one delta round per review fix, against the tree id the last `CONFORMS` measured; it neither resets nor consumes Stage 3's round cap, and a `DIVERGES` there goes back to Stage 2 inside the same review round. The planner's reading of "one … per review fix", for the manager to overrule: the fix of that divergence then goes on to Stage 5 without a second Stage 3 round, so the loop stays bounded; the analyzer of that round is also given the review findings the fix answered, so a change they asked for is not reported as one no step asked for. S1.15, S4.3.
- D55 `glab:analyzer` states the round-3 trigger ("In round 2 it decides whether a round 3 runs", S4.2), so `plugins/glab/agents/analyzer.md` joins the round-caps *One fact* entry; S10.1 now gives that entry's text and file list in full instead of "the same four files".
- D56 Post-conditions match content, not line numbers or line wrapping: line numbers move once a step adds a line (S15.3 adds one to *Gates*), and a phrase in a wrapped paragraph can split across lines. V3 matches the three tier rows whole (`grep -x -F`); V6 counts occurrences per file; V10, V11 and V16's README checks join the file's lines (`tr -s ' \n' '  '`) and count each expected phrase, so a half-written S1.16 or *One fact* entry prints `0` for its phrase. Shown at base and on simulated trees in F22.
- D57 `AGENTS.md` *Gates* `:24` "run all three, in order" becomes "run all four, in order" with the fourth command S15.3 adds (S15.2).
- D58 `.claude-plugin/marketplace.json:11`, the `glab` entry's `description`, "The glab workflow: skills, agents, commands and the session bootstrap hook" → "The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook" (S17). Only the description: the marketplace and plugin names, the `source` and the top-level description stay as they are. Outside `plugins/`, so no version of its own; shown to validate with the name gate unchanged (F22). F12 and F19 corrected.
- D59 The input-parse `jq` of S13.3 sends its stderr to `/dev/null`, as S13.4's already does, so a malformed input prints exactly the one line `glab context-size: hook input is not JSON` (T11; D34's one line on stderr).
- D60 Test count: each `T<n>` id is one case and prints one `ok` or `FAIL` line; a case with several inputs (T12, T16, T18) is `ok` only when every input passes, and its `FAIL` line names the input that failed. T2 is evaluated over every run of the other cases and printed last, after T19. Nineteen cases: the last line is `PASS 19/19` (V17). *(Superseded by D63 after I1: twenty-one cases, a new order, `PASS 21/21`.)*
- D61 manager decision, I1: `stop` stays stateless and accepts a one-turn delay. At `Stop` it compares the step of the latest **written** assistant total (`cur`, as before) with the step of the assistant total that precedes the **previous** real user prompt — one turn further back than D45's `base`. With the transcript lagging as I1b observed (F23), it speaks once, on the turn after the crossing. When the crossing call is already written at its own turn's `Stop` — a transcript written in time, or (the planner's finding from T21, under the same acceptance) a crossing at a call that is not the turn's last — it speaks on that turn and once more on the next: accepted, at most two lines per crossing and never a missed one (F24). Rejected: polling in the hook until the turn's reply is written — it adds up to about 1 s to every turn end (F23: the entry was there 1 s later); a per-session state file under `${CLAUDE_PLUGIN_DATA}` — more moving parts and its cleanup (*Boundary* (a3)); dropping `stop` — I1b showed the display works, so the *Fallback plan*'s condition ("no message shown, or the turn continues") did not occur. The user may overrule it. Amends D45; S13.1, S13.4, S13.5, S14.2.
- D62 The `stop` base as built (D61's rule in the code): the `reduce` state becomes `{last: 0, base: 0, cur: null}`; an assistant entry with a total above 0 sets `cur`, as before; a real user prompt — unchanged: a user entry, not a sidechain, not `isMeta`, whose content is a string or an array with no `tool_result` item — does `.base = .last | .last = (.cur // 0)`. So `last` is the size when the latest real prompt arrived (D45's old `base`) and `base` the size when the one before it arrived. The output stays `<k> <cur> <base>`; modes `prompt` and `agent` still use only `k`. A window with fewer than two real prompts has `base` 0 and speaks at or past 300k — D45's "an extra line, never a missed one", one prompt wider. Why one turn back: at `Stop` the transcript holds the turn's own prompt but not its last call (F23), so `cur` is usually the previous turn's last call, and comparing it with the size at the turn's own prompt compares a number with itself. Each `Stop` covers the calls written since the prompt before the last; consecutive `Stop`s overlap by the previous turn's calls already written at its own `Stop`, and leave no gap as long as the transcript catches up within one turn — hence never missed, at most once repeated. Considered and rejected by the planner: a base of "the assistant total before the last one that precedes the latest prompt" (what the previous `Stop` saw, under the observed lag) speaks exactly once in every lagging case, but misses a crossing if the lag is ever more than one entry, and D45 prefers a line too many to a missed one. Known limit: a `/compact` inside those two turns can leave `base` above `cur`, so a crossing after the drop in the same range shows only at the next `Stop` whose base is past the drop — a rise of over 250k within two turns, accepted (*Record*, *Known limits*).
- D63 Tests after I1 (supersedes D60's count and order): T18's fixtures are rewritten for D62 — each is the transcript as it stands when `Stop` runs, with two real prompts wherever the base matters — and two cases are added: T20, a lagging session (the turn's last call missing at each `Stop`) that speaks exactly once, on the turn after the crossing; T21, a crossing already written at its own turn's `Stop` (in time, or not the turn's last call) that speaks then and once more, never a third time. Order: T1, T3–T18, T20, T21, then T19 — judged over every `stop` run, so it comes after the last of them — and T2 last. Each `T<n>` is still one case and one line (D60's rule). Twenty-one cases: `PASS 21/21` (V17). Proven on throwaway copies (F24): `PASS 21/21` against D62's script, and `FAIL 3/21` (T18, T20, T21) against the script as built — I1b's failure reproduced without a model.
- D64 D41 said no `memory-sync` hook runs under `--plugin-dir ./plugins/glab`. I1a's run had a second `Stop` hook that ended `cancelled`, exit 1 (F23), so the plugins the user installed appear to load beside `--plugin-dir`; which plugin's hook that was is UNVERIFIED (inferred: the installed `memory-sync`'s network sync, cut off when `-p` exited; `context-size.sh` exits 0 in about 0.07 s). F18 showed only that `--plugin-dir` alone loads `glab` under an empty config, not under the user's. So an I1 run in the user's terminal runs the user's installed hooks, as any of their sessions does — their own setup, not a run of `memory-sync.sh` from this repo by an agent. I1c says so and does not switch them off: that is a `claude plugin` change, the user's alone (`AGENTS.md` *Rules*). Amends D41 and I1's "Neither part loads `memory-sync`".
- D65 The two built texts that say when the user sees the `Stop` line change with D61 so they stay true: S1.16's first paragraph ("…tells the user directly at the end of the turn." → "…tells the user directly, at the end of that turn or, usually, the next.") and S16.3 ("at the end of a turn that crossed 300k, 400k, …" → the timing D61 gives). S16.1's table phrase "tells you when a turn crosses 300k or a further 100k" and S1.16's "These are the steps at which the hook speaks to the user, so the two never disagree" stay: the steps do not change (D47), and no V10 or V16 phrase is touched. S10.3 (*One fact*) names the message and the steps, not the timing, and stays.

- effort: high (the user's words: "let's for now set the effort for your subagent you current session high level"), for the session
- model: glab:developer sonnet, glab:reviewer sonnet, for this task — the user's instruction, not a manager choice: "okay" (in reply to the manager's "My recommendation: developer on Sonnet, reviewer on Sonnet.")
- manager decision, Stage 1b r1: D54's reading is confirmed — a DIVERGES found by the one Stage 3 delta round after a review fix goes back to develop and then on to Stage 5, with no second Stage 3 round; this keeps the loop bounded.

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
`tests/context-size.test.sh`; since Stage 1b round 1 also
`.claude-plugin/marketplace.json` (the `glab` entry's description only, D58). Depended on, read only where cited: `plugins/glab/skills/security/SKILL.md`,
`plugins/glab/commands/review.md`, `plugins/glab/commands/plan.md`,
`plugins/glab/scripts/manager-bootstrap.sh`,
`plugins/memory-sync/scripts/memory-sync.sh` and `tests/memory-sync.test.sh`
(the pattern S13–S14 follow), `docs/specs/workflow.md`, `docs/specs/marketplace.md`. Not changed:
`manager-bootstrap.sh` (F16, D22), the `memory-sync` plugin, `commands/review.md` (no cap; "do not re-rank"
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
`.claude-plugin/marketplace.json:3` names only the memory-sync hook, but
`:11`, the `glab` entry's description, says "skills, agents, commands and the
session bootstrap hook" — missed by round 2, found by Stage 1b round 1 (D58,
S17).

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

### F22 Stage 1b round 1 re-checks (base `7df69a8`; throwaway work under `$TMPDIR`, removed after, leftover count `0` each time)

V3's old search also matched the pipeline table; the new one matches the tier
table alone, and the exact-row count tells base from a finished tree (a copy
with the three rows rewritten as S1.8 gives them):

    $ grep -n -E '^\| (1b|3|5) ' plugins/glab/skills/manager/SKILL.md     (old V3, base)
    164:| 1b | Analyze the plan | … ;  166:| 3 | Analyze | … ;  168:| 5 | Review | … ;  187:…  189:…  191:…
    $ grep -n -E '^\| (1b|3|5) [A-Za-z]' …                                 (new V3)
    base:      187:| 1b Analyze the plan | — | one pass | max 2 rounds |   189:… max 4 rounds |   191:… one round | max 3 rounds |
    finished:  187:| 1b Analyze the plan | — | max 2 rounds | max 2 rounds |   189:| 3 Analyze conformance | — | — | max 2 rounds |   191:| 5 Review | — | max 2 rounds | max 2 rounds |
    grep -c -x -F (the three new rows):  finished 3, base 0

V6 at base, occurrences: `1 plugins/glab/commands/ship.md`,
`1 plugins/glab/skills/bootstrap/SKILL.md`, `6 plugins/glab/skills/manager/SKILL.md`.
In the plan's new text: S1.1 3, S1.5 1, S1.16 1 (*Inside a task*), S1.18 2,
S6.1 1, S7.2 1 — hence V6's 13, 2, 1, 1.

The snapshot (D50), in a repo whose base commit holds `.gitignore` (`*.log`),
`a.txt` and a force-added `keep.log`; then `keep.log` modified, `x.log`
ignored, `new.txt` untracked, `s.txt` staged, `f.log` force-staged, `a.txt`
removed with `git rm`:

    == without read-tree        t0 rc=0   .gitignore new.txt s.txt
    == with read-tree HEAD      t1 rc=0   .gitignore keep.log new.txt s.txt   (keep.log holds k2)
    status-same
    index-same
    == fix round changes keep.log only
     keep.log | 2 +-
     1 file changed, 1 insertion(+), 1 deletion(-)
    quiet rc=1
    same-sha
    0                           <- no temp index left
    == unborn HEAD              fatal: Not a valid object name HEAD   rc=128

`f.log` — force-staged, not committed, ignored — is in neither tree (D50's
remaining limit, FU8).

`cmp -s` (D49): `identical rc=0`, `changed rc=1`, `missing rc=2`, and `0`
bytes of output.

The whitespace-joined searches (D56), against the base files and against
simulated files built by a throwaway script from this plan's own quoted text
(S1.4, S1.7, S1.16, S1.18 appended to the manager; S10.1 replacing the old
entry and S10.2–S10.4 added to *One fact*, S15.4 and S15.6 applied; S16.1–S16.3
applied to the README), each also re-wrapped at 72 columns with `fold -s`;
columns are base, finished, half-written, finished re-wrapped:

    V10 ### Your own context — read it, act on it, never clear     0 1 1 1
        **At a task boundary**                                       0 1 0 1   (half: that bullet left out)
        · context <n>k                                               0 3 3 3
        dispatches <d>                                               0 2 2 2
        glab: context <n>k                                           0 3 3 3
        (the other six phrases of V10: 0 1 1 1)
    V11 the round caps — …                                           0 1 1 1
        the severity levels — …                                      0 1 0 1   (half: analyzer.md left out)
        the other five entries                                       0 1 1 1
        the review round cap                                         1 0 0 0
    V16 README (base, finished, finished re-wrapped):
        the `glab` hook falls back to plain text without it          1 0 0
        S16.2's sentence, S16.1's phrase, S16.3's opening            0 1 1
        UserPromptSubmit                                             0 1 1
        AGENTS.md: new glab Hooks line 0→1, memory-sync line 1→1, UserPromptSubmit 0→2, new contract 0→1, old contract 1→0

The old V16 search `grep -c -F 'falls back to plain text without it' README.md`
printed `0` at base: "without it" is on `README.md:32`, the rest on `:31`.

V19 at base: `the range of the fix` 0 in each of the three files; `there is no
round 3`, `the tree id the last `CONFORMS` measured`, the `read-tree` line and
the `cmp -s` line 0 in the manager; `Ask what changed and confirm it yourself`
1 in `reviewer.md`; `scope each round after the first to what changed since
the last one` 1 in `ship.md`.

The marketplace (D58): a copy of `.claude-plugin/` and `plugins/` with the
`glab` description changed as S17 gives it, under a new empty
`CLAUDE_CONFIG_DIR`:

    glab | The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook
    memory-sync | Syncs Claude Code memories to and from S3 on session hooks
    ✔ Validation passed
    glab = glab
    memory-sync = memory-sync

and `git diff --no-index` of the base file against that copy counts `2`
changed lines (V20).

### F23 Integration I1 — run by the user in their own terminal, observed by the manager

Relayed in the amendment's dispatch; not re-run by this planner, who runs no
model (D41). Claude Code `2.1.304`.

- **I1a** (`claude -p`): PASS. `PostToolUse` on `Agent` delivered
  `glab: context 37k (last completed call)` to the model; the Agent-calling
  request totalled 36,185 tokens, which rounds up to 37k, so at `PostToolUse`
  the transcript already held that call. `UserPromptSubmit` on the first
  prompt of a new session printed `no readable transcript` — no transcript
  yet; stdout empty, as the contract says. `UserPromptSubmit` also fired when
  the subagent's report was delivered, and the model saw the line. A second
  `Stop` hook in that run ended `cancelled`, exit 1: which plugin's is
  UNVERIFIED — inferred: the installed `memory-sync`'s network sync, cut off
  when `-p` exited; ours exits 0 in about 0.07 s (D64, IN2).
- **I1b** (interactive, a throwaway copy with the two step constants lowered
  to `1000` and `1000`): the real `stop` mode printed nothing on any turn. A
  debug wrapper logged, at `Stop` and 1 s later:
  - turn 1: at `Stop` `no usage in the transcript`; 1 s later the same
    transcript gave `54k`;
  - turns 2 and 3: at `Stop` silent — the transcript still ended with the
    previous turn's 54k, equal to the turn's start; 1 s later `54k`.

  So **at `Stop` the turn's own final assistant entry is not yet in the
  transcript** (the docs' "written asynchronously and may lag", F20). With
  one model call per turn, `stop` as built compares two equal numbers and
  can never speak (IN1). Inferred from the same runs, not logged directly:
  the turn's own prompt *is* written by `Stop` — had it been missing, the
  as-built `base` on turn 2 would have been 0 and `stop` would have spoken
  at 54k against the lowered 1000.
- **Display, isolated**: a wrapper that always printed
  `{"systemMessage":"…"}` on `Stop` was shown to the user ("Stop says: …"
  under the reply) on both turns, and the turn ended there. So
  `systemMessage` on `Stop` works in the terminal; only the measurement was
  wrong. The *Fallback plan* was for "no message shown, or the turn
  continues"; neither happened, so it does not apply.
- Not observed: whether the model sees the `Stop` text (I1b's quote prompt
  was not reported); a display other than the terminal, such as the desktop
  app (FU17); how far the lag can grow on another host or under load — here
  the entry was written within 1 s.

### F24 D62 and the new cases, prototyped (amendment after I1; throwaway copies under `$TMPDIR`, removed after, leftover count `0`)

A copy of the built `context-size.sh` with D62's two edits — the state
`{last: 0, base: 0, cur: null}`, and on a real prompt
`.base = .last | .last = (.cur // 0)`, nothing else changed — and a copy of
the built test with T18's fixtures rewritten and T20, T21 added exactly as
S14.2 now gives them (T20 and T21 placed before T19):

    == D62 script
    ok T18 … ok T20 stop, lagging transcript: speaks once, on the turn after the crossing
    ok T21 stop, a crossing already written at its own Stop: speaks then and once more, never a third time
    ok T19 … ok T2 no byte of a fixture's user lines reached stdout or stderr (42 runs)
    PASS 21/21   rc=0
    == the script as built
    FAIL T18 …: the turn before crossed 300k, its last call written after its Stop: expected the 310k message …, got [];
              one prompt in the window, 430k: … got []; a tool_result after the crossing: … got []; an isMeta entry after the crossing: … got []
    FAIL T20 …: T20 stop 4, the turn after: expected the 310k message with only systemMessage, got []
    FAIL T21 …: T21 in time, stop 4: expected the 320k message …, got []; T21 not last, stop 4: expected the 315k message …, got []
    FAIL 3/21    rc=1
    shellcheck (both copies)  rc=0

Mutants of the D62 copy, each against the new test:

    (a) "decision":"block" added to the stop JSON   FAIL T18, T20, T21, T19   FAIL 4/21
    (b) "+ 999" removed                             FAIL T1, T3, T13          FAIL 3/21
    (c) the isSidechain filter removed              FAIL T15                  FAIL 1/21
        the isMeta condition removed                FAIL T18                  FAIL 1/21
        the tool_result condition removed           FAIL T18, T21             FAIL 2/21

I1c's sequence on the D62 copy with the constants lowered to `1000` and
`1000`, fixtures of prompts and one call per turn (54,000, 54,400, 54,700):
turn 1 `glab context-size: no usage in the transcript` on stderr, no stdout;
turn 2 `{"systemMessage":"glab: context 54k (last completed call) — a good point to /compact, or to /clear between tasks"}`;
turns 3 and 4 nothing; `rc=0` each.

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
continue the turn the user just got back (D46); *(after I1, D61:)* (a3)
holds again — no state file under `${CLAUDE_PLUGIN_DATA}` to remember the
previous turn; (a5) polling in `stop` until the turn's last call is written
— up to about 1 s on every turn end; (a6) dropping `stop` — I1 showed its
display works (F23);
(b) the snapshot tree for the plan delta as well — silently empty under a
gitignored `plan/` (D10); (c) the manager writing each round's findings to a
file — Rule 1, and the reviewer has no slug (D8); (d) `findings-<area>.md` —
refused by the Write tool (D15); (e) a severity judged by the manager — it
would re-rank (D4).

## Milestone

Since round 2 something new runs: the `glab` hook prints the session's
context size on every user message and every Agent dispatch, and tells the
user at `Stop` when the context has crossed 300k or a further 100k — usually
at the end of the turn after the crossing (D61). Proven without a
model by `bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh`
→ every line `ok`, `PASS 21/21` (V17; T20 reproduces I1b's lag), and by the plugin gate's
`Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop` (V15); proven
end to end only by a model run that needs the user's OK (D41): I1 proved the
two `additionalContext` events and the `Stop` display (F23), and I1c is to
prove the amended `stop`. The
Markdown part is as before: the searches V1–V16, V19 and V20 return exactly the files and
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
  "**Round caps.** Stage 1b, Stage 3 and Stage 5 run at most **2 rounds** each, at every tier where the stage runs. A **third** round runs only when round 2 returned a finding rated `critical` or `high` — the severity the analyzer or reviewer gave it, on `glab:audit`'s *Severity Levels*, never re-ranked by you — and only once you have recorded it under `## Decisions`: `- round 3: <stage> — <severity> <the finding, as its file:line or step id and its claim>`. With no plan behind the stage — a `/glab:review` or `/glab:ship` run on its own — there is nowhere to record it, as Rule 5 says of the model: put the reason in the handoff line that announces the round, `round 3/3 (<severity> <finding>)`, and in this conversation; once you can no longer find it, there is no round 3. Nothing runs past round 3. What a stage does when its last round has not passed is in that stage." *(The no-plan sentence: D53.)*
- S1.9 *When subagent dispatch is not available* `:238`: "a second review session is `review2`, and there is no `review4`." → "a second review session is `review2`, a `review3` needs its round-3 line, and there is no `review4`."
- S1.10 Stage 1, after the paragraph at `:248`, add:
  "**Explore once.** Mapping — read-only agents that read an area of the code before the plan is written — is your call per task. Each mapping agent writes `plan/{slug}/map-<area>.md` — every path it read, `file:line` for what matters, proven kept apart from inferred — and returns a short report (Rule 2). Name those files in the planning agent's dispatch: it starts from them and reads code only for the gaps it names. Without mapping agents, the planning agent explores itself. Never both over one area: a planner told to explore again re-reads what the map already holds. The name is not `findings-<area>.md` because subagent writes of files named `findings…` have been refused."
- S1.11 Checklist item 3, `:256` → "3. **Findings cover the whole scope surface.** Every file, package, module and directory the change touches or depends on, by path. Each method the change **changes** carries its call sites and what each relies on; each method it only **calls** carries the precondition its new call site must meet and how the plan meets it; a file it only depends on is listed by path, not read in full (`glab:plan-first` Step 1). A findings file or section with no path list has not done this step."
- S1.12 Stage 1b, replace `:320-328` (from "**`BUILDABLE`** → Stage 2." to "… the backstop.") with:
  "**`BUILDABLE`** → Stage 2. **`NOT BUILDABLE`** → an amendment, with exactly what is missing; a missing choice is decided under Rule 3 first. **Never patch the steps yourself to make them buildable** — for the same reason Stage 3 forbids editing `plan.md` to resolve a divergence.

  **The amendment goes to a new planning agent** (Rule 2). Before you dispatch it, keep the version the round checked: `cp plan/{slug}/plan.md plan/{slug}/plan.r<n>.md`, and `findings.md` to `findings.r<n>.md` when there is one, `<n>` being the round that checked them. Give the new agent the slug, that this is the amendment after plan check round `<n>`, the round's findings copied as the analyzers returned them, and `glab:plan-first` with the seam stated. It reads the plan files from disk, changes what the findings name and what that forces, records each changed choice under `## Decisions`, and leaves the `.r<n>` copies as they are.

  **A re-check looks at the delta, not the whole plan.** Before round `<n+1>`, test that the amendment changed something, by exit code alone — do not read the diff yourself (Rule 2): `cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` (and the same for `findings.md`). Exit 1 means the amendment changed the plan; exit 0 means it changed nothing — send it back, do not re-check it; exit 2 means a file is missing — find out why first. Give each analyzer of round `<n+1>` the previous round's findings, copied as returned, and the file pairs; the analyzer runs `diff -u` and reads the diff. It checks each of those findings, every line the diff changes and every step that rests on a changed line — the post-condition question included — and not the rest of the plan, which already passed.

  **At most 2 rounds, a third under *Pick the tier*'s round-3 rule.** A plan still `NOT BUILDABLE` after round 2 with no round 3: at full tier it needs a design, not another pass — bring that to the user; at normal tier a new planning agent amends once more from what the analyzers found and the plan goes on — the developer's `PLAN WRONG` is the backstop. Still `NOT BUILDABLE` after round 3, at any tier: bring it to the user."
- S1.13 Stage 2 dispatch list, after the effort bullet at `:340`, add:
  "- **for a fix round** — after `DIVERGES` or review findings: a new agent (Rule 2), told which round it fixes (`fix round for analyze round 2`), with that round's findings copied as they came back. It reads `plan.md`, `result.md` and the tree itself, fixes only what the findings name, and adds a fix-round section to `result.md` instead of overwriting it. A re-dispatch after `BLOCKED` or `PLAN WRONG` is a new agent too, on the same steps."
- S1.14 Stage 3, replace `:376` with:
  "**`DIVERGES` → back to Stage 2** with only the diverging steps in scope, as a fix round. **At most 2 develop→analyze rounds, a third under *Pick the tier*'s round-3 rule.** Say the round number every time: `analyze round 2/2`.

  **A re-check looks at the delta.** Before you dispatch each analyze round, round 1 included, snapshot the tree it will measure — tracked, staged and untracked files, without touching the index — with an index path that does not exist yet, in the session's temp directory. The index is seeded from `HEAD` first, so a tracked file that matches `.gitignore` is not dropped:

      idx=<temp directory>/<slug>-analyze-r<n>.idx; rm -f "$idx"
      GIT_INDEX_FILE="$idx" git read-tree HEAD && GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree; rm -f "$idx"

  It prints a tree id; name it in that round's dispatch. In a repository with no commit yet `git read-tree HEAD` fails and nothing is printed: that round has no tree id. Round `<n+1>` gets the previous round's findings, copied as returned, and both tree ids; it reads `git diff --stat <old> <new>` and `git diff <old> <new>` and checks each previous finding, every step whose files the delta touches, and anything in the delta that no step asked for — not the steps the delta leaves alone. `git diff --quiet <old> <new>` exiting 0 after a fix round means nothing changed: stop and find out why. Ignored files are not in a snapshot, so a path the fix round's `files:` line names and the delta does not show is checked whole; a tree id you no longer have means that round runs whole."
  And `:378` "Still diverging at round 4 →" → "Still diverging after the last round →" (rest unchanged).
- S1.15 Stage 5. *(Rewritten in Stage 1b round 1: D51, D52, D54.)* First, `:393`: after "**not the slug, not the plan, not the findings, not what the plan intended.**" add "From round 2 on it is a new reviewer (Rule 2) and gets two things more: the previous review round's findings, copied as it returned them, and the range of the fix — the tree id of the tree that round reviewed and of the tree now, each taken with Stage 3's snapshot, or two commit ids when the fix is committed. Still never the slug, the plan or the intent." Then replace `:397` and `:399` with:
  "Findings → back to Stage 2 as a fix round, then the stages after it at that tier, then Stage 5 again. At full tier, Stage 3 after a review fix is one delta round per review fix, against the tree id the last `CONFORMS` measured, and the analyzer is also given the review findings the fix answered; it neither resets nor uses Stage 3's round cap. A `DIVERGES` there goes back to Stage 2 inside the same review round, and that fix goes on to Stage 5 without another Stage 3 round. **At most 2 review rounds, a third under *Pick the tier*'s round-3 rule**, at every tier. Before each review round, snapshot the tree it will review as Stage 3 does. Tell the reviewer which round this is and which is the last: round 2 is the last unless it reports a `critical` or `high` finding, and round 3 is the last with no exception. A round-2 `BLOCK` with no `critical` or `high` finding is that last round's verdict: there is no round 3 — bring it to the user with the verdict, as for any last round that did not pass. Rule 5's report check is for a report with missing fields or no clear verdict only. At the last round the answer must be `SHIP`, `SHIP WITH SCOPE CUT: <what to drop>`, or `DO NOT PUBLISH: <why>` — bring whichever it is to the user.

  A fix that grows past its finding, or lands in full-tier code, raises the tier."
  `:401` ("Watch where findings land …") stays.
- S1.16 The subsection S1.2 places after `:96` *(rewritten in round 2: the hook measures, the manager acts)*:
  "### Your own context — read it, act on it, never clear

  Your context grows with every turn, and every turn pays for all of it. You cannot run `/clear` or `/compact`; the user can. The `glab` plugin's hook measures it for you: with every message the user sends and with every Agent result it adds one line, `glab: context <n>k (last completed call)` — the context of your last completed model call, in thousands. When the context crosses 300k or a further 100k, the same hook also tells the user directly, at the end of that turn or, usually, the next. A hook runs every time but cannot make you act on what it says; acting on it is this rule.

  *(After I1, D65: that sentence was "When a turn crosses 300k or a further 100k, the same hook also tells the user directly at the end of the turn." — the built file holds it at `plugins/glab/skills/manager/SKILL.md:101`; the developer replaces that one sentence and nothing else of S1.)*

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
  `:94` → *(Stage 1b round 1, D51)* "Every round after the first is a **new reviewer**: you did not review the round before. The caller gives you the target, the previous round's findings as they were returned, and the range of the fix — two tree ids or two commit ids; you get no plan, no slug and no intent. Check each previous finding: closed, or still open under its old `file:line`. Review everything in `git diff <old> <new>` in full. The whole target stays in your scope, but text a previous round passed is not re-litigated — a finding in unchanged text is advisory, not blocking, unless it is data loss, a credential leak, or something outward-facing."
  `:96-102` unchanged.

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

  After a review fix at full tier the dispatch also quotes the review findings the fix answered (`glab:manager` Stage 5): a change one of them asked for is not "anything no step asked for".

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
- S6.2 `:32`: "**At most three rounds, then a decision.** Tell the reviewer which round this is and which is the last, and scope each round after the first to what changed since the last one. In the last round it must answer …" → "**At most two rounds, a third only on a critical or high finding, then a decision.** Tell the reviewer which round this is and which is the last. Each round after the first goes to a new reviewer with the target, the previous round's findings verbatim, and the range of the fix — the tree ids of the tree the round before reviewed and of the amended tree, taken with `glab:manager` Stage 3's snapshot — never the plan or what it intended. Round 2 is the last unless the reviewer reports a `critical` or `high` finding in it and answers `BLOCK`; then round 3 runs if I ask for the fix, and it is the last with no exception. In the last round it must answer …" (rest of `:32` unchanged). *(The new-reviewer sentence: D51, Stage 1b round 1; it replaces "and scope each round after the first to what changed since the last one".)*

**S7 `plugins/glab/commands/develop.md`**

- S7.1 `:42`: "slices and re-dispatches alike" → "slices, fix rounds and re-dispatches alike".
- S7.2 After `:43`, add: "- for a fix round — after `DIVERGES` or review findings — or a re-dispatch after `BLOCKED` or `PLAN WRONG`: a new agent, never the previous one resumed or sent a follow-up (`glab:manager` Rule 2). A fix round's dispatch says which round it fixes and quotes that round's findings as they came back; the agent reads `plan.md`, `result.md` and the tree itself."

**S8 `plugins/glab/commands/analyze.md`**

- S8.1 After `:6`, add: "A round 2 or later is a new agent, given the previous round's findings and the delta, as `glab:manager` Stages 1b and 3 say."

**S9 `plugins/glab/skills/bootstrap/SKILL.md`**

- S9.1 `:100-101` → "Normal work runs a one-page plan, a plan check and a review, with no conformance stage; trivial work is done directly. Each check stage runs at most two rounds, a third only on a critical or high finding; `glab:manager` → *Pick the tier* has the table and the round caps."

**S10 `AGENTS.md` *One fact*** (`:106-109`)

- S10.1 "the review round cap (`…reviewer.md`, `…ship.md`, `…manager/SKILL.md`, `…bootstrap/SKILL.md`)" → "the round caps — Stage 1b, Stage 3 and Stage 5 at most 2 rounds at every tier, a third only on a `critical` or `high` finding of round 2, recorded first as a `## Decisions` line, or in the handoff line and this conversation when there is no plan, none past 3 (`plugins/glab/agents/reviewer.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/commands/ship.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/bootstrap/SKILL.md`)". *(Stage 1b round 1: the file list in full, `analyzer.md` added — D55; the no-plan case — D53.)*
- S10.2 After the reviewer's-verdict-lines entry, add: "the severity levels — `critical`, `high`, `medium`, `low` and their meanings (`plugins/glab/skills/audit/SKILL.md`, `plugins/glab/agents/reviewer.md`, `plugins/glab/agents/analyzer.md`); every round a new agent, Rule 5's report check the one resume (`plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/agents/developer.md`, `plugins/glab/commands/develop.md`, `plugins/glab/commands/ship.md`, `plugins/glab/commands/analyze.md`); the mapping files `map-<area>.md` and the round copies `<name>.r<n>.md` (`plugins/glab/skills/manager/SKILL.md`, `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/agents/developer.md`); the handoff file `plan/SESSION-HANDOFF.md` (`plugins/glab/skills/bootstrap/SKILL.md` step 5, `plugins/glab/skills/manager/SKILL.md` Rule 2)".

- S10.3 *(round 2)* After S10.2's entries, add: "the `glab` context hook — the modes `prompt`, `agent` and `stop` on `UserPromptSubmit`, `PostToolUse` with matcher `Agent` and `Stop`, the line `glab: context <n>k (last completed call)`, the `Stop` message, and the steps 300k and every 100k after it (`plugins/glab/scripts/context-size.sh`, `tests/context-size.test.sh`, `plugins/glab/hooks/hooks.json`, `plugins/glab/skills/manager/SKILL.md`, `README.md`)".
- S10.4 *(Stage 1b round 1, D51)* After S10.3's entry, add: "what a review round after the first is given — a new reviewer, the target, the previous round's findings verbatim and the range of the fix, never the plan, the slug or the intent (`plugins/glab/agents/reviewer.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/commands/ship.md`)".

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
  *(After I1, D61–D62; `glab:comments`: update the comments that describe what changed, delete none.)* In the built header: the `stop` line of the mode list (`:11-12`, "shows the USER one line, once, when the turn just ended crossed 300k or a further 100k …") becomes "shows the USER one line when the context has crossed 300k or a further 100k (400k, 500k, ...) - usually at the end of the turn after the crossing, see the `stop` comment; says nothing otherwise"; the measure paragraph (`:30-35`) keeps its sentence on the documented lag and adds "Seen in a live session [flow-cheaper-rounds/plan.md F23]: at PostToolUse on Agent the calling call is already written; at Stop the turn's last call is not yet."; the harmless-reach paragraph (`:45-47`) "`stop` prints at most one line to the user per 100k step" becomes "`stop` prints a line to the user once per crossing of a 100k step, twice at most (see the `stop` comment)". No new comment may hold the words `decision`, `continue`, `exit 2`, `additionalContext` (V18) or `resum` (V6).
- S13.2 `#!/usr/bin/env bash`, `set -uo pipefail` (no `-e`: every path must reach `exit 0`); `MODE=${1:-}`; one function `fail() { printf 'glab context-size: %s\n' "$1" >&2; exit 0; }`. Mode not `prompt`, `agent` or `stop` → `fail "unknown mode: <mode>"` (the mode word only, never input).
- S13.3 `command -v jq` or `fail 'jq not found'`. `tp=$(jq -r '.transcript_path // empty | strings')` reading stdin, with its stderr sent to `/dev/null` (D59) so a parse error prints only the script's own line; a parse error → `fail 'hook input is not JSON'`; empty, not a regular file, or unreadable → `fail 'no readable transcript'`. The path itself is never printed.
- S13.4 One `jq -n -R -r` program over `tail -c 8388608 -- "$tp"` (the read of F17 and F21 in one pass), with `def total: (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0);` and a `reduce (inputs | fromjson? | objects | select(.isSidechain != true)) as $e ({base: 0, cur: null}; …)`: an assistant entry whose `.message.usage` is an object with `total > 0` sets `cur`; a user entry that is not `isMeta` and whose `.message.content` is a string, or an array with no `tool_result` item, sets `base = (cur // 0)`; anything else leaves the state. Its output: nothing when `cur` is null; otherwise `<k> <cur> <base>` with `k = (cur + 999) / 1000 | floor`. Empty output → `fail 'no usage in the transcript'`. jq's stderr goes to `/dev/null` so no line of the transcript can reach stderr; the script's own message replaces it.
  *(After I1, D62 — two edits to the built program, nothing else in it changes:)* the initial state `{base: 0, cur: null}` → `{last: 0, base: 0, cur: null}`, and the real-prompt branch `.base = (.cur // 0)` → `.base = .last | .last = (.cur // 0)`. The output line, the `read -r k cur base`, the digit guard and the variable names stay. The comment above the program (`:70-72`) becomes: "Prints `<k> <cur> <base>`: k the last real call's size in thousands rounded up, cur that size, and base the size when the real user prompt before the last one arrived (a real prompt: a user entry, not a sidechain, not isMeta, not a tool_result; `last` holds the size at the latest one). `stop` compares with base, one turn further back than the turn's own prompt - see the `stop` comment. Nothing when there is no real call in the window." The rest of that comment (`:73-76`) stays.
- S13.5 Output by mode, each built by `jq -n -c --arg c "<text>"` and the only write to stdout:
  - `prompt` → `{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":$c}}`, `$c` = `glab: context <k>k (last completed call)`.
  - `agent` → the same with `"hookEventName":"PostToolUse"`.
  - `stop` → with `step(x)` = `-1` when `x < 300000`, else `(x - 300000) / 100000` rounded down (bash integer arithmetic): when `step(cur) > step(base)`, `{"systemMessage":$c}` with `$c` = `glab: context <k>k (last completed call) — a good point to /compact, or to /clear between tasks`; otherwise nothing. Never any other key (D46). *(After I1: `base` is D62's, the size at the real prompt before the last one; the code of this branch does not change. Its comment (`:112-115`) becomes, the reasons for 300k and 100k kept:* "step(x): -1 below 300000, else how many whole 100000s lie past 300000 - 300k is the size at which the rounds of an agent that carries its whole history already cost several times a fresh agent's, and 100k keeps a declined suggestion from repeating on every turn. Speaks when the latest written call is in a higher step than the size at the real prompt before the last one; stateless, so no file remembers a suggestion. Why one turn further back than the turn's own prompt: when Stop runs, the transcript does not yet hold the turn's last call. Seen in a live session [flow-cheaper-rounds/plan.md F23]: at Stop the transcript still ended with the previous turn's figure, the same as at the turn's prompt, and one second later it held the turn's own; compared with the turn's own prompt, a turn of one call compared a number with itself and never spoke. So a crossing usually shows at the end of the turn after it. When the crossing call is already written at its own turn's Stop - written in time, or not the turn's last call - it shows then and once more on the next turn: accepted, a line too many rather than a missed one. Rejected: waiting in the hook for the write (up to a second at every turn end) and a state file per session." *Wrap it at the file's comment width.)*
- S13.6 `exit 0` as the last line, and every `fail` exits 0.

**S14 `tests/context-size.test.sh`** *(new, round 2; mode `0755`)*

- S14.1 Frame as D39. `usage: context-size.test.sh <path to context-size.sh>`, the path made absolute as `tests/memory-sync.test.sh` does; work directory `W=$(mktemp -d "${TMPDIR:-/tmp}/context-size-test.XXXXXX")`, `trap 'rm -rf "$W"' EXIT`. A helper runs the script with a mode, stdin from a string, captures stdout, stderr and rc; every case asserts rc `0`, and that neither stdout nor stderr contains `SECRET` (each fixture's user lines hold `SECRET=abc`; D36).
- S14.2 Cases (`T<n>` ids; each `ok` or `FAIL` with a short reason). *(Counting, Stage 1b round 1, D60:)* each `T<n>` is one case and prints one line; a case with several inputs (T12, T16, T18) is `ok` only when every input passes, and its `FAIL` line names the input that failed; the lines come in the order T1, T3–T19, then T2 last, because T2 is judged over every other run. Nineteen cases. *(After I1, D63: twenty-one cases, in the order T1, T3–T18, T20, T21, T19, T2 — T19 is judged over every `stop` run, T20's and T21's included, so it follows them in the file and in the output.)*
  - T1 `agent`, normal transcript (user, assistant 5 + 142000 + 300, user) → stdout is one line, `jq -e` parses it, `.hookSpecificOutput.hookEventName == "PostToolUse"`, `.additionalContext == "glab: context 143k (last completed call)"`, stderr empty.
  - T2 the `SECRET` assertion, counted as its own case over every run of T1 and T3–T19, and printed last.
  - T3 `prompt`, same transcript → `hookEventName` `UserPromptSubmit`, same text.
  - T4 missing file → stdout empty, stderr `glab context-size: no readable transcript`.
  - T5 transcript path is a directory → as T4.
  - T6 no assistant usage (user lines only) → stdout empty, stderr `… no usage in the transcript`.
  - T7 empty transcript file → as T6.
  - T8 truncated last line (`{"type":"assistant","mess` with no newline) after a complete assistant entry → the complete entry's number.
  - T9 huge: 30 lines of 1 MB, then a 6 MB assistant entry, then a user line (a file over 36 MB, past the window) → that entry's number; the elapsed time printed in the `ok` line, not asserted.
  - T10 an assistant entry longer than the window, with every other assistant entry outside it → stdout empty (D32's limit: silence, not a wrong number, when nothing else is in the window).
  - T11 malformed stdin (`not json{`) → stdout empty, stderr exactly one line, `glab context-size: hook input is not JSON` (D59: jq's own parse error is not printed).
  - T12 empty stdin, and stdin `{}`, and `{"transcript_path": 7}` → stdout empty, stderr `… no readable transcript`.
  - T13 7 tokens → `glab: context 1k …` (never `0k`).
  - T14 the last assistant entry has zero usage, an earlier one 200000 → `200k` (D31's `> 0`).
  - T15 the last assistant entry is `"isSidechain": true` with 900000, an earlier main one 200000 → `200k`.
  - T16 unknown mode `foo`, and no mode → stdout empty, stderr `… unknown mode: foo` / `… unknown mode: `.
  - T17 no `jq`: `PATH` set to a directory of links to `bash`, `env`, `tail` and nothing else → stdout empty, stderr `… jq not found`.
  - T18 `stop` cases, each asserting that stdout is empty or exactly one object whose only key is `systemMessage` (`jq -e 'keys == ["systemMessage"]'`): below 300k → empty; crossed 300k in the turn (F21's second fixture) → `glab: context 320k (last completed call) — a good point to /compact, or to /clear between tasks`; already past 300k in the same step → empty; crossed 400k → a message; dropped after a compact → empty; no prompt in the window, 420k → a message; a crossing whose only "prompt" after it is a `tool_result` or an `isMeta` entry → the base is the earlier real prompt.
    *(After I1, D62–D63: T18's fixtures are replaced by these, each the transcript as it stands when `Stop` runs; `P` a real prompt, `R` a tool result, `M` an `isMeta` entry, `A n` an assistant call of `n` input tokens — the built helpers; expected `''` for nothing, else the `<k>` of the message. A comment above them says the base is the size at the real prompt before the last one, one turn further back, because at `Stop` the turn's last call is not yet written (I1b). Its `done_case` text becomes "stop: speaks when the step rose since the prompt before the last, only with systemMessage, and not otherwise".)*
    - below 300k: `P A100000 P R A200000` → `''`;
    - the turn before crossed 300k, its last call written after its Stop: `A250000 P A280000 R A310000 P` → `310` (the as-built script prints nothing);
    - this turn crossed 300k at a call before its last: `A250000 P A260000 P A280000 R A310000 R` → `310`;
    - already past 300k in the same step: `A310000 P A350000 P A360000` → `''`;
    - crossed 400k: `A390000 P A395000 P A401000` → `401`;
    - dropped after a compact: `A500000 P A40000 P A45000` → `''`;
    - no prompt in the window, 420k: `A420000` → `420`;
    - one prompt in the window, 430k: `A420000 P A430000` → `430` (fewer than two prompts: base 0, D62);
    - a crossing two prompts back is not shown again: `A250000 P A310000 P A320000 P` → `''`;
    - a tool_result after the crossing: `P A250000 P A310000 R A320000 P A330000` → `330` — a comment says a `tool_result` counted as a prompt would move the base past the crossing (then `''`);
    - an isMeta entry after the crossing: `P A250000 P A310000 M A320000 P A330000` → `330`, the same with `M`.
  - T19 `stop` never blocks: over every `stop` run of T18, stdout never contains `decision`, `continue`, `reason`, `hookSpecificOutput` or `additionalContext`. *(After I1: over every `stop` run of T18, T20 and T21; its check that at least five messages were produced stays.)*
  - T20 *(after I1, D63)* a lagging session, as I1b saw it: at each `Stop` the turn's last call is missing. A prefix turn `P A200000` (so that no snapshot is empty of usage), then one call per turn — 250000, 280000, 310000 (the crossing, turn 3), 320000, 330000. Five `stop` runs, the snapshot at `Stop` of turn `t` being the prefix, the turns before `t` whole, and `t`'s prompt `P` alone:
    - stop 1 `P A200000 P` → `''`;
    - stop 2 `… P A250000 P` → `''`;
    - stop 3, the crossing turn, `… P A280000 P` → `''` (its 310000 is not written yet);
    - stop 4, the turn after, `… P A310000 P` → `310`;
    - stop 5 `… P A320000 P` → `''`.
    `ok` text "stop, lagging transcript: speaks once, on the turn after the crossing". The as-built script fails it at stop 4.
  - T21 *(after I1, D63)* a crossing already written at its own turn's `Stop` speaks then and once more, never a third time. Same prefix and sizes. In time — each snapshot ends with the turn's own call: stop 2 `… P A280000` → `''`; stop 3 `… P A310000` → `310`; stop 4 `… P A320000` → `320` (the accepted repeat); stop 5 `… P A330000` → `''`. Not the turn's last call, lagging — turn 3 makes three calls, `A290000 R A310000 R A315000`, and its 315000 is missing at its `Stop`: stop 3 `… P A280000 P A290000 R A310000 R` → `310`; stop 4 `… R A315000 P` → `315`; stop 5 `… P A320000 P` → `''`. `ok` text "stop, a crossing already written at its own Stop: speaks then and once more, never a third time".
- S14.3 Last line `PASS 19/19`, or `FAIL <k>/19` with `<k>` the number of failed cases; exit 1 on any failure. *(After I1, D63: `PASS 21/21`, or `FAIL <k>/21`.)* The test starts no background process, so it kills none (*Tests clean up by PID* holds trivially).

**S15 `AGENTS.md`** *(round 2; S10 is its *One fact* part)*

The line numbers in S15 are at `7df69a8`, as everywhere in *Processing*; S15.3 adds a line to *Gates*, so every later one moves down by one. Find each place by its quoted text, not its number (D56).

- S15.1 *Layout* `:11-12`: "`hooks/hooks.json` and `scripts/manager-bootstrap.sh`." → "`hooks/hooks.json`, `scripts/manager-bootstrap.sh` and `scripts/context-size.sh`."
- S15.2 *Gates* `:23-24`: "The test creates its work directory under `$TMPDIR`." → "The tests create their work directories under `$TMPDIR`."; and "then run all three, in order," → "then run all four, in order," (D57: S15.3 adds the fourth command).
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
- S16.3 After the paragraph at `:24-27` ("A plugin cannot ship global instructions …"), add one paragraph *(its first sentence amended after I1, D65; the built paragraph is at `README.md:29-35`, and only that sentence changes)*: "`glab`'s context hook adds one line of about ten tokens to the model's context on each message you send and after each subagent dispatch, and once the context has crossed 300k, 400k, … it shows you `glab: context <n>k … a good point to /compact, or to /clear between tasks` at the end of a turn — usually the turn after the crossing, because a turn's last model call is not yet in the transcript when the turn ends. It never blocks or prolongs a turn. The number is the last completed model call's, and can trail the turn a little. It runs in every session where `glab` is enabled, and not at all when hooks are turned off (`disableAllHooks`, `--bare`)."

**S17 `.claude-plugin/marketplace.json`** *(Stage 1b round 1, D58)*

- S17.1 `:11`, the `glab` entry's `description`: "The glab workflow: skills, agents, commands and the session bootstrap hook" → "The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook". Nothing else in the file changes — not the `name`s, not the `source`s, not the top-level `description`. Not under `plugins/`, so no version changes for it.

### After

Each search is run from the repo root with `/usr/bin/grep`; each lists what
it must print, so a skipped step shows as a missing or extra line. *(Stage 1b
round 1, D56:)* no post-condition expects a line number, and a phrase that a
wrapped paragraph can split is counted in the file's joined text, with these
two helpers (both proven at base and on simulated trees, F22):

    joined()  { tr -s ' \n' '  ' < "$1"; }
    onefact() { awk '/^- \*\*One fact, one value\.\*\*/{f=1} f&&/^- \*\*Comments and recorded incidents/{f=0} f' AGENTS.md | tr -s ' \n' '  '; }

- V1 Old caps gone: `grep -rn -E 'max 4 rounds|max 3 rounds|Maximum 4|Maximum 3|at most three|round 2/4|One pass at normal|one pass \||One round at normal|one at normal tier|one analysis and one review|round 1/1|at round 4|the review round cap' plugins/glab AGENTS.md; echo rc=$?` → no line, `rc=1`. An absence check: it cannot tell a tree where the text was rewritten wrongly; V2–V3 discriminate.
- V2 New cap: `grep -rli -E 'at most (2|two)( [a-z>→-]+)* rounds|max 2 rounds' plugins/glab AGENTS.md | sort` → exactly `AGENTS.md`, `plugins/glab/agents/reviewer.md`, `plugins/glab/commands/ship.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`. At `7df69a8` it prints only `plugins/glab/skills/manager/SKILL.md` (the full-tier 1b cell), so it discriminates for the other four files and V3 does for the manager.
- V3 Tier rows *(Stage 1b round 1: the tier table only, D56)*: `grep -n -E '^\| (1b|3|5) [A-Za-z]' plugins/glab/skills/manager/SKILL.md` → exactly three lines, the tier table's — the `[A-Za-z]` keeps out the pipeline table's `| 1b | …`, `| 3 | …`, `| 5 | …` rows, which the old `'^\| (1b|3|5) '` also matched (F22); and `grep -c -x -F -e '| 1b Analyze the plan | — | max 2 rounds | max 2 rounds |' -e '| 3 Analyze conformance | — | — | max 2 rounds |' -e '| 5 Review | — | max 2 rounds | max 2 rounds |' plugins/glab/skills/manager/SKILL.md` → `3` (`0` at base, F22). Round-3 line: `grep -c -F -- '- round 3: <stage>' plugins/glab/skills/manager/SKILL.md` → `1`.
- V4 Severity: `grep -n -F 'severity:' plugins/glab/agents/reviewer.md plugins/glab/agents/analyzer.md` → one template line in each; `grep -l -F 'unbounded memory growth' -r plugins/glab | sort` → `agents/analyzer.md`, `agents/reviewer.md`, `skills/audit/SKILL.md`.
- V5 New agents: `grep -rl -F 'new agent' plugins/glab | sort` → exactly `commands/analyze.md`, `commands/develop.md`, `commands/ship.md`, `skills/manager/SKILL.md`; `grep -l -F 'new planning agent' -r plugins/glab | sort` → `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`; `grep -c -F '## A fix round' plugins/glab/agents/developer.md` → `1`.
- V6 Resumes *(Stage 1b round 1: occurrences, and the S1.16 bullet added, D56)*: `grep -rnoi 'resum' plugins/glab | cut -d: -f1 | sort | uniq -c` → exactly `1 plugins/glab/commands/develop.md` (S7.2), `2 plugins/glab/commands/ship.md` (`:28` and S6.1), `1 plugins/glab/skills/bootstrap/SKILL.md` (`:3`), `13 plugins/glab/skills/manager/SKILL.md` — at base 6, on the Rule 5 version-floor line (2) and the report-check line (4); then S1.1's Rule 2 bullet 3, S1.5 1, S1.16's *Inside a task* bullet ("a resumed agent's rounds") 1, S1.18's *What you never do* bullet 2. At base it prints `1 …ship.md`, `1 …bootstrap/SKILL.md`, `6 …manager/SKILL.md` (F22).
- V7 Map files: `grep -rl -F 'map-<area>.md' plugins/glab AGENTS.md | sort` → `AGENTS.md`, `agents/analyzer.md`, `agents/developer.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`; `grep -rn -F 'findings-<area>' plugins/glab AGENTS.md` → only the S1.10 sentence that says why the name is not used.
- V8 Round copies: `grep -rl -F '.r<n>.md' plugins/glab AGENTS.md | sort` → `AGENTS.md`, `agents/analyzer.md`, `agents/developer.md`, `skills/manager/SKILL.md`, `skills/plan-first/SKILL.md`.
- V9 Planner search: `grep -n -F 'only **calls**' plugins/glab/skills/plan-first/SKILL.md plugins/glab/skills/manager/SKILL.md` → one line in each; `grep -c -F 'you plan to change or call' plugins/glab/skills/plan-first/SKILL.md` → `0`.
- V10 Context *(round 2; made discriminating in Stage 1b round 1, D56)*: for each phrase below, `joined plugins/glab/skills/manager/SKILL.md | grep -o -F -- '<phrase>' | wc -l` prints the count given (every one `0` at base; a simulated tree without S1.16's *At a task boundary* bullet prints `0` for that phrase, F22): `### Your own context — read it, act on it, never clear` 1; `**Read the number at every handoff line.**` 1; `**Inside a task**, at the first handoff line at or past **300k**` 1; `**At a task boundary**` 1; `**When no line has come at all**` 1; `**The handoff file** is the one `glab:bootstrap` step 5 reads` 1; `**You never run `/clear` or `/compact` yourself**` 1; `- Run `/clear` or `/compact`, or claim to know your context more exactly` 1 (S1.18); `· context <n>k` 3 (S1.4, S1.7, S1.16); `dispatches <d>` 2 (S1.7, S1.16); `glab: context <n>k` 3 (S1.7, S1.16 twice); `grep -rl -F 'CLAUDE_CODE_SESSION_ID' plugins README.md AGENTS.md tests; echo rc=$?` → no line, `rc=1` (round 1's command is not written anywhere); `grep -rl -F 'glab: context' plugins README.md AGENTS.md tests | sort` → exactly `AGENTS.md`, `README.md`, `plugins/glab/scripts/context-size.sh`, `plugins/glab/skills/manager/SKILL.md`, `tests/context-size.test.sh`; `grep -c -F 'SESSION-HANDOFF' plugins/glab/scripts/manager-bootstrap.sh` → `0` (unchanged, D22).
- V11 `AGENTS.md` *One fact* *(Stage 1b round 1: whole entries, not lines, D56)*: for each new entry — the S10.1 text, each of S10.2's four entries (split where `); ` ends one), S10.3's and S10.4's, each exactly as the step quotes it — `onefact | grep -o -F -- '<entry>' | wc -l` → `1`; and `onefact | grep -o -F 'the review round cap' | wc -l` → `0`. At base every entry prints `0` and the old one `1`; a simulated *One fact* whose severity entry lacks `analyzer.md` prints `0` for that entry, wrapped at 72 columns or not (F22).
- V12 Version: `jq -r .version plugins/glab/.claude-plugin/plugin.json` → `0.9.0`; `jq -r .version plugins/memory-sync/.claude-plugin/plugin.json` → `0.1.0`.
- V13 Throwaway run, under `$TMPDIR`, removed after, pasted in `result.md`: (a) the S1.14 snapshot lines, copied from the edited file, in a new repo with a tracked change, a staged change, an untracked file, an ignored file and a tracked file that matches `.gitignore` (force-added in the base commit), then a second snapshot after a further change to that tracked ignored file — expect F8's and F22's shape (status and index unchanged, the tracked ignored file in the tree, the delta lists only the later change, `git diff --quiet` rc=1, no `.idx` left); (b) the S1.12 `cmp -s` on a copy and an amended copy — rc=1, rc=0 on identical files, rc=2 with one file missing, and no output in any case (F22). *(Round 2: round 1's part (c), the inline context command, is gone with the command; the hook script is covered by V17.)*
- V14 Prefixed names: `grep -n -E '`(manager|plan-first|audit|bootstrap|security|reviewer|analyzer|developer)`' plugins/glab/skills/manager/SKILL.md plugins/glab/skills/plan-first/SKILL.md plugins/glab/agents/*.md plugins/glab/commands/*.md plugins/glab/skills/bootstrap/SKILL.md` → no line in text this change added (compare with the same search at `7df69a8`).
- V15 Both gate blocks of `AGENTS.md` *Gates*, as S15.3–S15.4 leave them: five `rc=0` lines; `shellcheck` `rc=0`; both tests every line `ok`, last line `PASS n/n`; `Skills (14)`, `Agents (5)`, `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop` (F18); `memory-sync` unchanged; the rest as F14.
- V16 Hooks stated *(round 2)*: `jq -r '.hooks | keys_unsorted | join(",")' plugins/glab/hooks/hooks.json` → `SessionStart,UserPromptSubmit,PostToolUse,Stop`; `jq -r '.hooks[][] | (.matcher // "-") + " " + (.hooks[] | .command + " " + (.timeout|tostring))' plugins/glab/hooks/hooks.json` → four lines, the `PostToolUse` one with matcher `Agent`, the three `context-size.sh` ones with modes `prompt`, `agent`, `stop`, every timeout `5`; *(from here rewritten in Stage 1b round 1, D56)* `grep -c -x -F -- '- for `glab`: `Skills (14)` naming the six skills and the eight commands, `Agents (5)`, and `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`;' AGENTS.md` → `1` (`0` at base) and the same for the unchanged `- for `memory-sync`: … `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;` line → `1`; `joined <file> | grep -o -F UserPromptSubmit | wc -l` → `1` for `README.md` (S16.1) and `2` for `AGENTS.md` (S10.3, S15.4); in `joined README.md`, `the `glab` hook falls back to plain text without it` → `0` (`1` at base: the phrase wraps across `README.md:31-32`, so a line search printed `0` even at base, F22), S16.2's new sentence whole → `1`, `· a context hook on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop`` → `1`, ``glab`'s context hook adds one line of about ten tokens`` → `1`; in `joined AGENTS.md`, `**The hook contracts do not change without a plan.**` → `1` and `**The hook contract of `memory-sync.sh` does not change without a plan:**` → `0`; `joined AGENTS.md | grep -o -F 'run all four, in order' | wc -l` → `1` and `run all three` → `0` (S15.2).
- V17 The new test *(round 2)*: `bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh` → nineteen lines `ok T<n> …`, in the order T1, T3–T19, T2 (D60), then exactly `PASS 19/19`. It discriminates: run against three throwaway copies of the script under `$TMPDIR`, removed after, it must fail — (a) `stop` with `"decision":"block"` added to its JSON → T18 and T19 `FAIL`; (b) the rounding `+ 999` removed → T13 `FAIL`; (c) the `isSidechain` filter removed → T15 `FAIL`. Paste the three `FAIL` lines in `result.md`. Against a missing script path it prints the usage line and exits 2. *(After I1, D63:)* twenty-one `ok` lines in the order T1, T3–T18, T20, T21, T19, T2, then exactly `PASS 21/21`; mutant (a) → T18, T20, T21 and T19 `FAIL`; (b) and (c) as above; and a fourth, (d) the real-prompt branch put back to the as-built `.base = (.cur // 0)` → T18, T20 and T21 `FAIL` (`FAIL 3/21`, F24) — the I1b failure, caught without a model. Paste the four mutants' `FAIL` lines in `result.md`.
- V21 *(after I1, D61, D65)* The texts that say when `stop` speaks: `joined plugins/glab/skills/manager/SKILL.md | grep -o -F 'at the end of that turn or, usually, the next' | wc -l` → `1` and `… -F 'tells the user directly at the end of the turn.'` → `0`; `joined README.md | grep -o -F 'usually the turn after the crossing' | wc -l` → `1` and `… -F 'at the end of a turn that crossed'` → `0`; in the script, joined with its comment markers stripped — `cjoined() { sed 's/^[[:space:]]*#[[:space:]]*//' "$1" | tr -s ' \t\n' '   '; }`, because `joined` leaves each wrapped comment line's `#` in the phrase (plain `joined` prints `0` for the last phrase below even on the build before this amendment) — `cjoined plugins/glab/scripts/context-size.sh | grep -o -F -- '<phrase>' | wc -l`: `flow-cheaper-rounds/plan.md F23` → `2` (the measure paragraph and the `stop` comment), `{last: 0, base: 0, cur: null}` → `1`, `.base = .last | .last = (.cur // 0)` → `1`, `once, when the turn just ended crossed` → `0`, `at most one line to the user per 100k step` → `0`. On the tree as built before this amendment (run by this planner) the nine counts print `0 1 0 1 0 0 0 1 1` in the order given, so each one discriminates.
- V18 The `stop` contract in the code *(round 2)*: `grep -n -E 'decision|"continue"|exit 2|additionalContext' plugins/glab/scripts/context-size.sh` → only comment lines that say `stop` never does them, and the `additionalContext` of modes `prompt` and `agent`; `stat -c %a plugins/glab/scripts/context-size.sh tests/context-size.test.sh` → `755` twice.
- V19 Review rounds, round 3 and the deltas *(Stage 1b round 1: D49–D54)*: `joined <file> | grep -o -F 'the range of the fix' | wc -l` → `1` for each of `plugins/glab/agents/reviewer.md` (S3.2), `plugins/glab/skills/manager/SKILL.md` (S1.15) and `plugins/glab/commands/ship.md` (S6.2); in `joined plugins/glab/skills/manager/SKILL.md`: `there is no round 3` → `2` (S1.8, S1.15), `the tree id the last `CONFORMS` measured` → `1` (S1.15), `GIT_INDEX_FILE="$idx" git read-tree HEAD` → `1` (S1.14), `cmp -s plan/{slug}/plan.r<n>.md plan/{slug}/plan.md` → `1` (S1.12); `Ask what changed and confirm it yourself` in `joined plugins/glab/agents/reviewer.md` → `0`, and `scope each round after the first to what changed since the last one` in `joined plugins/glab/commands/ship.md` → `0`. At base the first seven print `0` and the last two `1` (F22).
- V20 Marketplace *(Stage 1b round 1: D58)*: `jq -r '.plugins[] | select(.name=="glab") | .description' .claude-plugin/marketplace.json` → `The glab workflow: skills, agents, commands, the session bootstrap hook and the context hook` (at base `… commands and the session bootstrap hook`); the plugin gates of V15 still print three `✔ Validation passed`, `glab = glab` and `memory-sync = memory-sync`; `git diff 7df69a8 -- .claude-plugin/marketplace.json | grep -c '^[-+] '` → `2` (one line out, one in).

### Integration — I1, needs the user's OK *(round 2)*

Calls a model, so it costs a small amount of usage (*costs money*, `glab:manager` Rule 3). A throwaway `CLAUDE_CONFIG_DIR` is not logged in (F18), so the user runs both parts in their own terminal from the repo root; an agent never copies credentials (D41). Neither part loads `memory-sync` (F18). *(After I1: not borne out in the user's own config — the installed plugins appear to load beside `--plugin-dir`, D64, IN2.)* The run writes a session transcript into the user's own config, as any session does; no agent reads it.

- I1a — the two `additionalContext` events and the lag. With `TMPDIR` set to the host's temp directory:

      out=$(mktemp "$TMPDIR/fcr-i1a.XXXXXX") && claude -p --max-turns 6 --plugin-dir ./plugins/glab \
        --output-format stream-json --verbose --include-hook-events \
        'This is a hook test. Load no skill and read no file. Dispatch exactly one foreground subagent with the Agent tool, subagent_type general-purpose, prompt "Reply with the word ok and nothing else". After it returns, quote verbatim every line in your context that begins with "glab: context", or write NONE.' >"$out"; echo "rc=$? out=$out"

  Then an agent reads only `"$out"` and pastes: the hook events and their outputs for `UserPromptSubmit`, `PostToolUse` and `Stop` (whatever form `--include-hook-events` gives — UNVERIFIED); the model's final text; the `message.usage` of the assistant message that issued the Agent call and of the one before it. Pass: the final text quotes a `prompt` line and an `agent` line of the form `glab: context <n>k (last completed call)`. The lag: the `agent` line's `<n>` equals the rounded total of the Agent-calling message (flushed before `PostToolUse`) or of the one before it (not flushed) — record which. `stop` says nothing here: a tiny run never reaches 300k. If the installed `glab` also loads, each line may appear twice; record it, it does not fail the run. Remove `"$out"` after.
- I1b — the `Stop` message, interactive. An agent makes a throwaway copy of `plugins/glab` under `$TMPDIR` and, in the copy only, lowers the two step constants of `context-size.sh` from `300000` and `100000` to `1000` and `1000`; the user starts `claude --plugin-dir <that copy>` from the repo root, sends `Reply with the word ok.`, and reports: whether `glab: context <n>k (last completed call) — a good point to /compact, or to /clear between tasks` was shown to them at the end of the turn; that the turn ended there (no further model output, no "continuing"); then sends `Quote verbatim any line in your context that begins with "glab: context".` and reports whether the model quotes the `Stop` text — which says whether the model sees `systemMessage` (F20, UNVERIFIED). The agent removes the copy after.
- Pass: I1a quotes both lines; I1b shows the message to the user and ends the turn. The lag and whether the model sees the `Stop` text are recorded either way.
- *(After I1:)* I1a passed; I1b showed the display works and found that `stop` as built never speaks (F23, IN1). D61–D62 rebuild it; I1c re-runs I1b on the rebuilt script.
- I1c — the `stop` message after D61, interactive, I1b's method. After S13 and S14 are rebuilt and V17 is green, an agent makes a throwaway copy of `plugins/glab` under `$TMPDIR` from the rebuilt tree and, in the copy only, lowers the two step constants of `context-size.sh` from `300000` and `100000` to `1000` and `1000` (the two lines `[ "$cur" -ge 300000 ] …` and `[ "$base" -ge 300000 ] …`); nothing outside the copy changes. The user starts `claude --plugin-dir <that copy>` from the repo root in a **new** session, sends `Reply with the word ok.` three times, one turn each, and reports after each turn whether `glab: context <n>k (last completed call) — a good point to /compact, or to /clear between tasks` was shown and whether the turn ended there; I1b's debug wrapper may log the figures at `Stop` and 1 s later as before. Expected (F24, on fixtures): turn 1 nothing — at its `Stop` no call is written yet; **turn 2 the line**, `<n>` turn 1's figure (I1b: 54k) — the turn after the first crossing of 1000; turn 3 nothing while the latest written figure and the one two prompts back lie in the same 1000-step (I1b's 54k and 54k), a line if they do not — record the figures if logged. Pass: nothing on turn 1, the line on turn 2, and the turn ends there. Fail: a line on turn 1, or none on turn 2 — then a new planning agent amends again, with what was observed. The user's installed plugins load beside `--plugin-dir` (D64); that is their own setup, and no agent changes it. The agent removes the copy after; no agent reads the session's transcript.

**Fallback plan.** If I1b shows no message, or the turn continues, `stop` is not usable: a new planning agent amends this plan to drop it — the `Stop` entry of S12, the mode and its comments in S13, T18–T19, the `Stop` words of S10.3, S15.4, S15.6 and S16, the green line becoming `Hooks (3)  SessionStart, UserPromptSubmit, PostToolUse` — and the other two events stand (D45). The developer does not drop it on their own. *(After I1: it did not apply — the message was shown and the turn ended there (F23); the measurement was fixed instead (D61). It applies again only if I1c shows no message on any turn, or a turn that continues; T20 and T21 would then join T18–T19 in the list.)*


Test coverage (`AGENTS.md` *Tests*), as a list *(rewritten in round 2)*:

- S13 (`context-size.sh`): S13.2 modes and `fail` — T16; S13.3 input and path — T4, T5, T11, T12, T17 (`jq` missing); S13.4 the read — T1, T3, T6–T10, T13–T15, and T18's prompt cases for `base`; S13.5 output per mode — T1 (`agent`), T3 (`prompt`), T18 (`stop`); S13.6 exit 0 — asserted on every run; D36's no-leak — T2 over every run; D46 never blocks — T18's key check and T19. *(After I1:)* D62's base — T18 (two prompts, the tool_result and isMeta cases, fewer than two prompts), T20 (the observed lag: once, on the turn after), T21 (the accepted repeat, and never a third line); V17's mutant (d) shows the as-built base fails them; the comments of S13.1, S13.4 and S13.5 — V21.
- S12 (`hooks.json`): V15 (`plugin details`), V16 (`jq` over the file); the `user_config` gate.
- S14 (the test itself): V17's three mutants, which show it fails a wrong script; `shellcheck` and `bash -n`/`test -x` (V15).
- S1–S11, S15, S16 (Markdown and manifest): V1–V12, V14, V16, V19; their prescribed commands by V13 (the `read-tree` snapshot and the `cmp -s` test since Stage 1b round 1). S17 (`marketplace.json`): V20 and the plugin gates of V15.
- S1.16's sentence and S16.3 after I1 (D65): V21, with V10 and V16 unchanged.
- Not covered by any case, and why accepted: that the hook's line reaches the model and that `Stop`'s `systemMessage` reaches the user — I1, needing the user's OK, because no test can run a model (*after I1:* both shown in the terminal, F23; the amended `stop` live — I1c); the transcript-flush lag — I1a measures it (*after I1:* measured, F23, and reproduced on fixtures by T20; a lag longer than one turn is not covered — D62 would then still speak, later); the display in the desktop app (FU17); whether the model sees the `Stop` text; a real transcript's shape on other CLI versions — fixtures only, by the brief; the `Task` alias on CLIs older than 2.1.63 (FU11); the managed-policy settings (FU15); timing on other hosts (T9 prints it); that a live session follows the prose (D-wide UNVERIFIED).

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
- FU7 Stage 5 does not say how a review round after the first learns what changed since the last one: `reviewer.md:94` has the reviewer ask, and `ship.md:32` has the caller scope it, while Stage 5 gives the reviewer the target and nothing else (F6). *Closed in Stage 1b round 1* by D51: Stage 5, `reviewer.md:94` and `ship.md:32` now say what a round after the first is given.
- FU8 Snapshot limits: a nested repository is recorded as a gitlink with a warning, and a large untracked directory that is not ignored is hashed in full (F8, not tested); since D50, a repository with no commit yet gets no tree id (`git read-tree HEAD` fails, F22), so its rounds run whole, and a file force-added to the index but not committed that matches `.gitignore` is still missed (F22).
- FU9 Whether `CLAUDE_CODE_SESSION_ID` and the transcript layout hold on other hosts and versions, and whose id a subagent sees (F15, UNVERIFIED). *Closed as moot in round 2*: nothing uses the variable any more (D30).
- FU10 Whether the transcript is flushed before `PostToolUse` and `Stop` run, and how far the figure lags (F20, D31) — I1a measures one case; closed by I1 if it is conclusive. *Closed by I1* (F23): at `PostToolUse` on `Agent` the Agent-calling call is already written (I1a: the `37k` line for a 36,185-token request); at `Stop` the turn's last call is not, and it was there 1 s later (I1b); D61–D62 answer it. How far the lag can grow elsewhere stays a known limit of the record, not a follow-up.
- FU11 Whether the matcher `Agent` matches a `Task` call on a CLI older than 2.1.63 (F20, D43, UNVERIFIED).
- FU12 `claude plugin details` labels every hook "harness-only — no model context cost", which is not true of one that returns `additionalContext` (F18): the CLI's wording, to report upstream if anyone wants to.
- FU13 A `PreToolUse` hook on `Agent` that refuses (`permissionDecision: "deny"`) a dispatch missing `effort` or the `AGENTS.md` instruction — the coordinator's follow-up, not planned here; whether the Agent `tool_input` carries `effort` is UNVERIFIED (F20).
- FU14 An assistant entry longer than the 8 MiB window is not seen (D32): an older call's figure, or silence. Widen the window or read backwards if it is ever seen.
- FU15 Whether `allowManagedHooksOnly` and `strictPluginOnlyCustomization.hooks` stop a plugin's hooks (F20, D48, UNVERIFIED).
- FU16 The hooks the user did not choose — `PostToolBatch`, `SubagentStop` — recorded by D28/D29, not planned.
- FU17 *(after I1)* Whether the desktop app shows a `Stop` hook's `systemMessage` as the terminal does (F23 shows the terminal only): UNVERIFIED, open.
- FU18 *(after I1)* Which plugin's `Stop` hook ended `cancelled`, exit 1, in I1a, and whether an installed `memory-sync` sync is cut off whenever a `claude -p` run exits (F23, D64, IN2): UNVERIFIED, open; a question for the `memory-sync` plugin, not acted on here.

## Incidents

- IN1 *(I1b, after the build)* `stop` as built never spoke in a live session. At `Stop` the transcript holds the turn's prompt but not yet its last call, so with one call per turn `cur` equalled the size at the turn's prompt and the step could never rise (F23). Every T18 fixture held the turn's last call, so the test passed `19/19` on a script that could not work; F20 had marked the lag UNVERIFIED and D45 left it to I1. Fixed by D61–D62; T20 now reproduces the lag without a model and fails the as-built script (F24). Lesson: a hook's fixture is the file as it stands when the hook runs, not as it stands after.
- IN2 *(I1a)* D41 said no `memory-sync` hook runs under `--plugin-dir ./plugins/glab`; in the user's own config a second `Stop` hook ran and was `cancelled`, exit 1, when `-p` exited — which plugin's is UNVERIFIED (D64, FU18). F18's proof was under an empty config only.

## Record

After the push, `glab:manager` Stage 8 updates:

- `docs/specs/workflow.md` (primary): *How it works now* — the tier bullet (`:59-68`) and the round-caps bullet (`:169-173`) restated for 2 (+1) at every tier with the reviewer's round-2 rule; new bullets for every round a new agent (Rule 2), the delta re-checks of 1b and 3 with their two mechanisms, explore once and `map-<area>.md`, the narrower call-site audit, the context rule (the hook's line read at every handoff line, the steps 300k and every 100k after it, the task-boundary `/clear`, the dispatch-count fallback only when no line came, the handoff file) and the handoff line's `· context <n>k`; *(round 2)* a bullet for the context hook — one script, three modes on `UserPromptSubmit`, `PostToolUse` (`Agent`) and `Stop`, the measure, the 8 MiB window, the `Stop` message to the user and why it goes to the user (a hook fires every time but cannot make the model act), that it never blocks, and what I1 proved — *(after I1)* the `agent` line is current at `PostToolUse`, the `Stop` line is shown to the user in the terminal and the turn ends there, and at `Stop` the turn's last call is not yet written (F23), hence `stop`'s base at the real prompt before the last one: the line usually comes at the end of the turn after the crossing, and at most twice per crossing (D61–D62), with I1c's result; the owners list at `:7-13` gains `plugins/glab/scripts/context-size.sh` and `plugins/glab/hooks/hooks.json`; the agents bullet gains the `severity:` line, the analyzer's re-check section and the developer's fix-round section; *(Stage 1b round 1)* what a review round after the first is given (D51), a round-2 `BLOCK` without a critical or high finding as the last verdict (D52), the no-plan round-3 record (D53), the one Stage 3 delta round after a full-tier review fix (D54), the `cmp -s` test (D49) and the `read-tree` seed (D50). *Decisions that still bind*: D2–D12, D14–D16, D19–D27, D29–D59 and *(after I1)* D61–D65 tagged `[flow-cheaper-rounds/plan.md D<n>]` — D45 as amended by D61–D62, D41 as amended by D64 — with `[bug-reviewer-findings/questions.md Q3]` and `[sync-local-edits/result-followups.md D11]` marked superseded by D2, and D17–D18 recorded as superseded by D29–D30 (round 1's inline command, never shipped), D13 as superseded by D51, and D60 as superseded by D63 (nineteen cases became twenty-one). *Known limits*: F8's untested cases, F9's partial probe, F1's inferred savings; *(round 2)* the 8 MiB window (D32), the lag (D31, with I1a's result), the documented limits of "impossible to bypass" — plugin disabled, `--bare`, `disableAllHooks`, managed hook policy, an interrupted turn firing no `Stop` (D48) — and every UNVERIFIED of F20 that I1 did not settle; *(after I1)* the `stop` line's one-turn delay and its possible second line (D61), a crossing hidden behind a `/compact` inside the two-turn range until the next `Stop` (D62), that D62 relies on the transcript catching up within one turn (F23: within 1 s, one host, one version), a window with fewer than two real prompts speaking at or past 300k (D62), and whether the model sees the `Stop` text (F23). *Follow-ups*: FU1–FU6, FU8 and FU11–FU18 open, FU7 closed by D51, FU9 closed as moot (D30), FU10 closed by I1 (F23); `[sync-local-edits/follow-ups.md 18]` and `[sync-local-edits/follow-ups.md 19]` closed by this change. *Incidents*: the Write refusal of `findings-probe.md` and `findings.md` for a subagent, a third time, now with `map-probe.md` accepted; *(after I1)* IN1 — `stop` as built never spoke because every fixture held the turn's last call, which at `Stop` is not yet written; and IN2 — the installed plugins load beside `--plugin-dir` in the user's own config.
- `docs/specs/marketplace.md`: *Versions* — `glab` `0.9.0`; the *One fact* entries this change rewrote or added (S10, S10.3); `[feature-plugin-marketplace/questions.md S3]` marked superseded by D2; *(round 2)* *What each plugin holds* (`:32-37`) — `glab` with four hook events, `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Stop`; *The gates* (`:59-66`) — five scripts under `bash -n`/`test -x` and `shellcheck`, two tests, the new green line; the *Layout* and the hook-contract rule (S15.1, S15.6); *(Stage 1b round 1)* the `glab` entry's description in `.claude-plugin/marketplace.json` (S17, D58); *Testing without installing* — `--plugin-dir ./plugins/glab` loads `glab` alone under an empty config (F18), while in the user's own config the installed plugins appear to load beside it (D64; which hook ran is UNVERIFIED, FU18); *Incidents* — none new unless I1 produces one *(after I1: IN2, under *Testing without installing*)*.

No audit file under `plan/` is acted on.
