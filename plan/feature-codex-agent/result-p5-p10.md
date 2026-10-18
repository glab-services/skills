# Result — feature-codex-agent, steps P5–P10

Developer, 2026-10-18. Working agreement: `AGENTS.md`, read from disk. Plan
revision 3, `questions.md` and `findings.md` §9 read. Scope: P5–P10 only.
P1–P4 (`plugins/glab/scripts/external-agent.sh`,
`tests/external-agent.test.sh`) are another developer's, and neither file
was touched here. Nothing is staged, committed or pushed. No Codex command
ran, nothing under `~/.codex` was read, and `external-agent.sh` ran only
through its own stub test.

## Stages

- **P5 — `plugins/glab/skills/external-agents/SKILL.md`: done.**
  - `:3` description, the plan's text verbatim.
  - `:8-17` intro: one sentence for each backend; "There is no external
    developer." kept, on one line (`:17`).
  - `:21-25` *When this applies*: "naming the model for OpenCode; for Codex,
    naming one or leaving it to Codex's default", plus the three Codex
    examples.
  - `:37-72` *Before the first one*: an **OpenCode** bullet (`:37-48`), with
    the three existing bullets as sub-bullets, unchanged except their
    indent; a **Codex** bullet (`:49-72`): the CLI path `~/.local/bin/codex`
    (`:50`), `check --backend codex` with exits 4 and 12 and the
    user-config sentence (`:52-60`), "Tell the user once per session:" and
    the data note verbatim (`:61-68`), and the effort: U5, D30 and mapping
    (i) (`:69-73`).
  - `:82-83` the brief "goes to the model's provider, with the copy for
    OpenCode and with whatever Codex reads for Codex".
  - `:91-98` a Codex start example (`--backend codex --effort <level>`, with
    `--model <id>` only when the user named one) and the Codex announce line.
  - `:106-108` the `stop` item, the plan's text.
  - `:129` exit row 4, `:130` row 5, `:132` row 7, `:134` row 9 "(OpenCode
    only)", `:137` the new row 12, verbatim.
  - `:157` the transcript paragraph: a Codex transcript is not redacted.
  - `:166-169` *The reviewer role*: the branch-or-range sentence said of an
    OpenCode reviewer; a Codex reviewer can take one.
  - `:191` the label **OpenCode.** over the existing guarantee bullets, which
    are unchanged; `:225-253` **Codex.**, from §9.3's Codex column (runs,
    sees, writes, network, login, tools, limits, checked, state).
  - No profile file changed: the plan names none.
- **P6 — `plugins/glab/skills/manager/SKILL.md`: done.** `:120`, `:123`
  (the three tokens; "or reports that it did not run read-only (12)"),
  `:127` (the Codex record line, verbatim, on one line, with the
  `codex:<id>` sentence), `:128`, `:139`, `:149`, `:151`, `:154` (verbatim)
  and the new `:155` bullet (verbatim).
- **P7 — `plugins/glab/commands/review.md:8`: done**, the plan's two
  sentences verbatim.
- **P8 — `README.md`: done.**
  - `:9` the `glab` row, verbatim.
  - `:34-51` the two paragraphs, verbatim, with the plan's own line breaks.
  - `:53` "What an OpenCode agent can send"; `:57-58` the sentence that goes
    before the allowlist sentence, verbatim.
  - `:69-75` the data note, verbatim, as its own paragraph.
  - `:87-88` the Codex test sentence, as a new paragraph after the probe
    paragraph. The probe paragraph and its gate line are unchanged.
- **P9 — `AGENTS.md`: done.**
  - `:35-36` *Gates*.
  - `:97-99` *Tests*.
  - `:112-122` *Rules*, the external-agent rule: the offline run, "own key or
    login", and the live-run sentence.
  - *One fact*: the manual model rule `:163-164`; the record line `:169-170`;
    the allowlist `:182-186`; the sandbox limits `:186`; the CLI path
    `:192-193`; "Use balance" `:194`; the copy and what a Codex agent may
    read and send `:195-200`; the five new entries `:216-221`.
- **P10 — `plugins/glab/.claude-plugin/plugin.json:3`: done.** `0.5.0` →
  `0.6.0`.

## Blocked

Nothing.

## Unplanned changes, and wording the plan left open

Every one of these follows from a step. None adds a fact the plan does not
hold.

- P5, intro: "`stop` ends one and removes everything it had" became
  "removes what the script kept of it". Under D12 the old words are false
  for Codex, whose session stays in Codex's history. The plan rewrites this
  paragraph without giving its text.
- P5, intro: "There is no external developer." starts a line of its own. My
  first rewrap had split it across two lines, so G2 printed `0` for the
  skill; after the fix it prints `1`.
- P5, *Before*: the three OpenCode bullets are now sub-bullets of
  **OpenCode.**, as "one bullet per backend" requires. Their text is
  unchanged, but one line break moved (`exit` / `7)`).
- P5, *Start*: the Codex example says "with `--model <id>` only when the
  user named one". That is the manual model rule for Codex, and P9's *One
  fact* entry names the skill as one of the rule's files.
- P5, row 4: the plan's "…" after "a repository that moved" became "since
  the agent started". Row 5 reads "or names a Codex id that is not one",
  not the plan's bare "or a Codex id that is not one", so that the sentence
  parses.
- P6 `:127`: the Codex line is introduced by "A Codex reviewer's line also
  records the effort:".
- P8: the data note and the Codex test sentence are each a paragraph of
  their own.
- P9: the lines next to each changed phrase were rewrapped so that every
  searched phrase stays on one line (*Before* 5). The text "Grok refused for
  its 30 days' retention" now starts its own line (`:201`): a rewrap only.

## Tests

These steps are Markdown and JSON, and no test case covers them (plan,
*Tests and coverage*: "P5–P10 are text: *After* §2, S1–S27, and review").
Coverage is the search list below, plus a check of every text the plan
gives verbatim, after collapsing whitespace. The checker,
`/data/tmp/claude/fca-p5p10/verb.py`, has been removed; its output was:

    ok   data note in README.md
    ok   data note in plugins/glab/skills/external-agents/SKILL.md
    ok   README :34-43 paragraphs in README.md
    ok   skill description in plugins/glab/skills/external-agents/SKILL.md
    ok   exit 12 row in plugins/glab/skills/external-agents/SKILL.md
    ok   P6 :154 in plugins/glab/skills/manager/SKILL.md
    ok   P6 new bullet in plugins/glab/skills/manager/SKILL.md
    ok   P6 :127 line in plugins/glab/skills/manager/SKILL.md
    ok   P7 in plugins/glab/commands/review.md
    ok   P8 README sentence in README.md
    ok   P8 :45 sentence in README.md

## Gates

All gates were run with `export TMPDIR=/data/tmp/claude`.

**The plugin block**, exactly as in `AGENTS.md` *Gates*, run as a script
with `CLAUDE_BIN=<the CLI path the host file names>`:

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
    1
    rc=0
    rc=1

Green, as *Green is* defines it. Afterwards, no `claude-config.*` directory
was left under `$TMPDIR` (count `0`).

**The B-block**, the four shell gates, run against the script and test as
they stood. The other developer had not changed either file yet: `git
status` showed neither as modified. So this is the baseline, not P1–P4.

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0                     (shellcheck)
    PASS 35/35               (memory-sync test, last line)
    ea rc=0; 49 lines `ok`; no other line apart from PASS 49/49

**The S searches on my files**, each command as the plan writes it,
followed by its output:

    S0  jq -r .version plugins/glab/.claude-plugin/plugin.json                 → 0.6.0
    S1  'or a Codex session on this host under Codex' (skill)                  → 1
    S2  "for Codex, naming one or leaving it to Codex's default" (skill)       → 1
    S3  'with whatever Codex reads for Codex' (skill)                          → 1
    S4  '12 | NOT READ-ONLY' (skill)                                           → 1
    S5  "under your ChatGPT account's data controls"                           → README.md:1, skill:1
    S6  'Improve the model for everyone'                                       → README.md:1, skill:1
    S7  '- model: glab:reviewer codex, effort <level>' (manager)               → AS WRITTEN: grep: invalid option -- ' ' (rc=2)
        same with -e                                                           → 1
    S8  'an OpenCode or a Codex session the user asks for' (manager)           → 1
        'an OpenCode session on a model the user names' (manager)              → 0
    S9  'naming the model for OpenCode — for Codex, naming one or leaving it'  → 1
    S10 "**Codex's effort** is the session's" (manager)                        → 1
    S11 'a Codex reviewer works in the repository and can take one' (review)   → 1
    S12 'or Codex in its own read-only sandbox' README.md                      → 1
    S13 "naming the model — or, for Codex, leaving it to Codex's default."     → 1
    S14 "the script checks only the id's form" README.md                       → 1
    S15 'exit 12 (NOT READ-ONLY)' README.md                                    → 1
    S16 'none has run against a real model yet' README.md                      → 1
    S17 'and its stub `codex` on the host' AGENTS.md                           → 1
    S18 'its stub `opencode` and its stub `codex` to the script' AGENTS.md     → 1
    S19 'for an OpenCode run, after confirming that the console' AGENTS.md     → 1
        'names the models, after confirming' AGENTS.md                         → 0
    S20 'a dummy key or login in a throwaway home'                             → 1
    S21 'the guarantees each backend has'                                      → 1
    S22 'the Codex read-only check'                                            → 1
    S23 'the Codex effort rule'                                                → 1
    S24 'the Codex data note'                                                  → 1
    S25 'the host first message'                                               → 1
    S26 '~/.local/bin/codex' AGENTS.md                                         → 1
    S27 "OpenCode's sandbox limits" 1 · "OpenCode's \"Use balance\" warning" 1 · 'what a Codex agent may read and send' 1 · "checks an id's form only" 1 · 'for Codex, no `--model` unless the user' 1 · "in the record line for Codex's default" 1
    S37 "run with the user's own key or login" AGENTS.md                       → 1
    G2  'There is no external developer'                                       → manager:1, skill:1
    S36 git status --short → " M AGENTS.md", " M README.md", " M plugins/glab/.claude-plugin/plugin.json",
        " M plugins/glab/commands/review.md", " M plugins/glab/skills/external-agents/SKILL.md",
        " M plugins/glab/skills/manager/SKILL.md", "?? plan/"
        (the script and the test are not yet ` M`; they belong to P1–P4)

The S searches were saved as a script, `/data/tmp/claude/fca-p5p10/s.sh`,
and run from there. The paths above are shortened; the commands used the
full ones.

**S7 is a defect in the plan, not in the tree.** As written, `grep -c -F
'- model: …'` reads the pattern as options and exits 2. With `-e` it counts
`1`. Stage 4 needs `-e` or `--` to run it.

## Blast radius (`glab:security`)

- **Changed**: six text files (four Markdown files of payload, `AGENTS.md`,
  one JSON version string). No script, hook, test or config changed.
- **What it reaches**: the instructions every session that installs `glab`
  0.6.0 follows for external agents. These are the Codex data note, the
  Codex effort question, and the `check --backend codex` steps. Each refers
  to behaviour that P1–P4 build. Until those are merged, the payload
  describes a backend that the script does not yet have.
- **Secrets**: none. A diff scan for endpoints, emails, tokens and keys
  matched only the existing word "password" in the skill's brief rule.
- **Not run**: no Codex command, no live model, no `claude plugin install`,
  `enable`, `configure` or `marketplace add`. Nothing was read or written
  under `~/.codex` or `~/.claude`. Every `claude` command ran under a fresh
  `CLAUDE_CONFIG_DIR` under `$TMPDIR`, which was removed afterwards.
- **Temp files**: `/data/tmp/claude/fca-p5p10/` (backups, `s.sh`, `p9.py`,
  `pg.sh`, `verb.py`, the test output) is removed at the end of this run.
- `UNVERIFIED`: that the payload text matches P1–P4's behaviour (the
  `check` output lines, exits 4 and 12, `--effort`, the header's model).
  Why: those steps were being built in parallel and were not in the tree
  when I checked.

## Follow-ups (deferred; not in this slice)

- **F-a, the plan's S7**: add `-e` (or `--`) to the command. For the
  manager or Stage 4; this slice may not edit `plan.md`.
- **F-b, the skill**: when `check` prints `models: unavailable`, the effort
  mapping (i) has no levels to work from. The plan gives no rule for that
  case.
- **F-c, `README.md:59`**: "The script runs only Kimi and GLM models…" now
  follows a sentence about Codex. It means OpenCode, but only from context.
  The plan keeps that sentence unchanged.
- **F-d, the skill's *Reading what comes back***: it says
  `model: <backend>:<model>` without saying that for Codex this is the model
  that ran. The plan states that only in the manager's `:128`.

## Not done

- P1–P4 are outside this slice. So are S28–S35, G1, G3 and G4, which test
  the script and the test; this report did not run them.
- `docs/specs/` is Stage 8's, and was not touched.

## Round 2 (plan revision 4, P5 `:64`)

- **Done**: the `stop` item at
  `plugins/glab/skills/external-agents/SKILL.md:106-109` now uses the
  plan's wording from plan.md:809-812. For Codex it reads "its directory and
  transcript, and any process its turns left running, while its session
  stays in Codex's own history". The searched phrase is on one line (`:108`).
- **Rewrap**: the item's lines were rewrapped inside the item. Round 1 had
  left a line of 101 characters there (`… history. Stop each agent when its
  task is done, and`), and it now wraps like the rest. Nothing else changed.
- **The new phrase**:

      $ command grep -n -F 'and any process its turns left running' plugins/glab/skills/external-agents/SKILL.md; echo "rc=$?"
      108:   transcript, and any process its turns left running, while its session
      rc=0

- **The plugin block**, exactly as in `AGENTS.md` *Gates*, with
  `TMPDIR=/data/tmp/claude` and
  `CLAUDE_BIN=<the CLI path the host file names>`, run
  as a script that was then removed:

      ✔ Validation passed
      ✔ Validation passed
      ✔ Validation passed
        Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
      1
      rc=0
      rc=1

  Green, as *Green is* defines it.
- **Blast radius**: one Markdown item in the payload. No Codex command ran,
  nothing was read under `~/.codex`, and nothing was staged or committed.

## Round 3 (review r1)

My items from `review-r1.md`: S1 (the wording), S2 with T2, S3, T1, T3, T4
(`SKILL.md:98`), T5 and T6. I used the reviewer's fix and the coordinator's
decisions. Where I departed from either, the reason is given. The files
touched were the skill, the manager skill, `README.md` and `AGENTS.md`.
`review.md`, the script, the test and the version (still 0.6.0) were not
touched.

**Done**

All line numbers are in `plugins/glab/skills/external-agents/SKILL.md` unless
another file is named.

- **S1 and S3: the data note.** It is identical in both files: whitespace
  collapsed, the two copies compare equal (`True`). It is at `:61-73` and
  `README.md:73-84`. Compared with before, it:
  - adds that files outside the repository include "credential files such
    as Codex's own login, SSH keys and cloud keys";
  - replaces "it changes no file" with "Its commands change no file, while
    Codex itself keeps the session under `~/.codex`, with everything the
    model read, and `stop` does not remove it";
  - replaces "Its commands have no network" with "Its commands have no
    network, neither IP nor Unix-domain sockets (measured offline with
    `codex sandbox`, not in a real turn)".
- **S1: the guarantees.** The same two wordings replace "writes nothing in
  any file" and "its commands have none" at `:248-255`.
- **S2 and T2: the tools.** `:258-265` now gives the script header's list:
  web search, apps, plugins, hooks, memories, the browser and computer
  tools, image generation and multi-agent. It also says that MCP is not
  turned off by a flag. A turn has no MCP server only because it ignores the
  user's `config.toml`. A managed or system config is not ignored, and the
  script checks only the sandbox and approval policy that the header
  reports.
- **T3: exit 12.** The skill's row at `:149` adds "or ran with an approval
  policy other than `never`". `README.md:52-54` adds "or an approval policy
  other than `never`".
- **T1: the README.**
  - The Codex model-id sentence moved into the Codex paragraph, at
    `README.md:50-51`.
  - The OpenCode sentence now begins "For OpenCode, the script runs only
    Kimi…" (`README.md:60`).
  - The plan's other half, "OpenCode runs only the models named below", is
    dropped, because the "For OpenCode" sentence now says the same thing.
- **T4: the model token.**
  - The announce line (`:105-109`) is `codex:<model>`. `<model>` is what the
    script's header prints: the model that ran once one has; before that,
    the id the user named, else `default` (`codex:default`).
  - It also says that the record line names `codex` alone for Codex's
    default.
  - Manager `:128`: "(`codex:default` when none has run)".
  - `AGENTS.md`'s "`codex` alone" clause stays, and the three now agree.
  - The skill's `:245-247` says that `default` is refused as a model id
    (exit 5). That is what the script's `codex_model_allowed` does now:
    `external-agent.sh:483`.
- **T5: `models: unavailable`.** When `check` prints it, the manager sends
  the level unchanged and says in the announce line that no levels were
  known. This is at `:81-82` and, as `effort <sent> (no levels known)`, at
  `:106`. Manager Rule 6 `:155` says the same, because the effort rule's
  *One fact* entry names Rules 5 and 6 and the skill.
- **T6: `AGENTS.md`.** Each clause is now an entry of its own and lists only
  the files that state it:
  - **The general manual model rule**: its original list, restored
    (`:162-167`).
  - **"for Codex, no `--model` unless the user named one"** (`:168-170`):
    `glab:manager` Rule 5 and the skill's start example. For Rule 5 to state
    the fact, manager `:120` now adds "with no `--model`".
  - **The token entry**: E50 and E55 join E01 (`:175`).
  - **"`codex` alone in the record line for Codex's default"**
    (`:175-178`): Rule 5 and the skill's announce step.
  - **"checks an id's form only"** (`:189-190`): the skill is added, since
    it states the fact.

**Where I departed from the reviewer's fix**

- **T6.** I did not list `plugins/glab/commands/review.md` for the Codex
  `--model` clause. It says "a backend, and for OpenCode a model", which
  never states that no `--model` is passed. Listing it would break "every
  listed file must state the fact". Editing it to state the fact would
  duplicate the skill that it delegates to.
- **T4.** The announce token also covers a model the user named before any
  model has run. The script's header prints `codex:<named id>` then, not
  `codex:default`. So the skill names all three cases the header prints,
  rather than only the two the coordinator gave.

**Not changed, flagged**

- The intro's "neither can change anything" (`:15`) and manager Rule 6's
  "**It changes nothing.**" (plan text) speak of the agent's work. Codex's
  own writes to `~/.codex` are stated in the data note and the guarantees.
- The new network wording rests on integration.md *Round 4*. That round
  measured one AF_UNIX stream socket, by path. It did not measure
  abstract-namespace, datagram or seqpacket sockets, `socketpair`, or a
  descriptor passed in from outside. The wording, which the coordinator
  chose, says "Unix-domain sockets" without that limit. Recorded here as a
  follow-up for the spec's *Known limits*.
- The plan still holds revision 4's data note (D25, plan.md:938-944) and the
  old exit-12 row. The tree now differs from both, by decision of the
  review. Updating plan.md is the manager's job; this slice may not edit it.
- `README.md:60` is now 87 characters long. It was left unwrapped so that
  the paragraph below it stays as it was.

**The changed phrases**, as grepped. The commands used `command grep -c -F
-e`, or `-n -F -e`, on `README.md` and the skill unless another file is
named:

    neither IP nor Unix-domain sockets                                    README.md:1  skill:2
    measured offline with `codex sandbox`, not in a real turn             README.md:1  skill:2
    change no file, while Codex itself keeps the session under `~/.codex` README.md:1  skill:2
    credential files such as Codex's own login, SSH keys and cloud keys   README.md:1  skill:1
    under your ChatGPT account's data controls                            README.md:1  skill:1
    Improve the model for everyone                                        README.md:1  skill:1
    writes nothing in any file                                            README.md:0  skill:0
    it changes no file                                                    README.md:0  skill:0
    skill 258: memories, the browser and computer tools · 260: MCP is not turned off by a flag · 261: a managed or system config
    skill 149: or ran with an approval policy other than `never`
    README 53: or an approval policy other than `never` · 54: exit 12 (NOT READ-ONLY)
    README 51: the script checks only the id's form · 60: For OpenCode, the script runs only Kimi
    'OpenCode runs only the models named below' (README)                  no line
    'codex:<model or default>' (skill)                                    no line
    skill 105: codex:<model> · effort · 108: (`codex:default`) · 109: names `codex` alone for Codex's default
    manager 120: default model, with no `--model` · 128: (`codex:default` when none has run)
    skill 81 and 106: models: unavailable · manager 155: When `check` knew no levels (`models: unavailable`), send the level unchanged
    AGENTS 168: for Codex, no `--model` unless the user · 169: and the start example in · 175: E01, E50 and E55
    AGENTS 176: in the record line for Codex's default · 177: and the announce step of
    data note identical (whitespace collapsed): True

Round 1's searches still hold, at 1 each: S1–S4, the `:64` phrase, G2,
S12, S13, S16, S7 (with `-e`), S9, S10, S26, and S27's "OpenCode's sandbox
limits" and "checks an id's form only". S21–S25 were not changed.

**The plugin block**, exactly as in `AGENTS.md` *Gates*, with
`TMPDIR=/data/tmp/claude` and
`CLAUDE_BIN=<the CLI path the host file names>`:

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
    1
    rc=0
    rc=1

Green, as *Green is* defines it. `jq -r .version` prints `0.6.0`.

**Blast radius.** The changes are payload text and `AGENTS.md`. The data
note now warns that credential files can reach OpenAI. No secret, host
value or uid is in the text: the bus path appears nowhere. No Codex command
ran, nothing under `~/.codex` was read, and nothing was staged or
committed. The scratch directory `/data/tmp/claude/fca-r3/` (backups and
scripts) is removed after this section is written.

## Round 4 (review r2)

This round builds review r2's R2-2 and the docs items of plan revision 5's
*Revision 5: still to build*. All the text is the plan's, verbatim, from
D25, D32 and P8. The files changed are `README.md`, the skill and
`AGENTS.md`. Nothing else was touched: not the manager skill or
`review.md`, not the script or the test, and not the version (still 0.6.0).

**Done**

- **The socket clause.** It now reads: "no IP network, and a connect to a
  Unix-domain socket by path was refused (measured offline with `codex
  sandbox`); datagram and abstract sockets not measured". It is in:
  - the README's data note, `README.md:78-80`;
  - the skill's data note, `plugins/glab/skills/external-agents/SKILL.md:70-72`;
  - the skill's *Its network*, `:252-255`, as plan "still to build" 1 gives
    it, ending "Codex itself reaches OpenAI."

  Each copy of the data note matches plan P8's text, whitespace collapsed
  (`True` for both files), and the two copies are identical (the diff
  below).
- **D32.**
  - `README.md:50-51` gets ", and refuses `default`, the word its output
    uses for Codex's own default". This is the plan's P8 line, verbatim and
    on one line.
  - `AGENTS.md:189` gets ", and refuses `default`".
  - The skill's `:245-247` gets "the script checks only the id's form", next
    to its sentence that `default` is refused (exit 5).
- **Line breaks.** Each searched phrase is on one line. Two lines are now
  long: the README D32 line (111 characters) and the skill's data-note line
  71/72. Both keep the plan's own breaks.

**Searches**

    $ S5   command grep -c -F "under your ChatGPT account's data controls" README.md <skill>
    README.md:1
    plugins/glab/skills/external-agents/SKILL.md:1
    $ S6   command grep -c -F 'Improve the model for everyone' README.md <skill>
    README.md:1
    plugins/glab/skills/external-agents/SKILL.md:1
    $ S40  command grep -c -F 'a connect to a Unix-domain socket by path was refused' README.md <skill> <script>
    README.md:1
    plugins/glab/skills/external-agents/SKILL.md:2
    plugins/glab/scripts/external-agent.sh:0
    $ S41  command grep -c -F 'neither IP nor Unix-domain sockets' README.md <skill> <script>
    README.md:0
    plugins/glab/skills/external-agents/SKILL.md:0
    plugins/glab/scripts/external-agent.sh:1
    $ S42  command grep -c -F 'and refuses `default`' README.md AGENTS.md; command grep -c -F "the script checks only the id's form" <skill>
    README.md:1
    AGENTS.md:1
    1
    $ S14  command grep -c -F "the script checks only the id's form" README.md      → 1
    $ S27  command grep -c -F "checks an id's form only" AGENTS.md                  → 1

S40 and S41 are as the plan expects for README and the skill (`1`, `2`; and
`0`, `0`). The script still shows `0` and `1`, because its header comment is
the script developer's item 1, which was not yet built when I checked. That
is not in this slice.

**The data-note diff.** Each copy was cut from "A Codex agent runs on this
machine" to "Its transcript is not redacted.", with whitespace squeezed and
the text folded at 72:

    $ diff "$TMPDIR/fca-r4-note-readme" "$TMPDIR/fca-r4-note-skill"; echo "diff rc=$?"
    diff rc=0

The temporary files were removed afterwards.

**The plugin block**, as in `AGENTS.md` *Gates*, with
`TMPDIR=/data/tmp/claude` and
`CLAUDE_BIN=<the CLI path the host file names>`. It ran
through `bash -c`, with the block's inner single quotes written as double
quotes; the commands are otherwise the same:

    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (15)  analyze, audit, bootstrap, comments, commit, develop, external-agents, integrate, manager, plan, plan-first, push, review, security, ship
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
    1
    rc=0
    rc=1

Green. `jq -r .version` prints `0.6.0`.

**Blast radius.** Three text files changed. The new wording claims less
than before: datagram and abstract sockets are now named as not measured,
and the earlier "neither IP nor Unix-domain sockets" overclaim is gone from
the docs. It is still in the script header, which is the script developer's
item. There are no secrets and no host values. No Codex command ran,
nothing under `~/.codex` was read, and nothing was staged or committed.
`/data/tmp/claude/fca-r4/` has been removed.

**Follow-up.** The socket follow-up from Round 3 is now partly met: the
wording names datagram and abstract sockets as not measured. Still not
named: seqpacket sockets, `socketpair`, and a descriptor passed in from
outside (integration.md *Round 4*). They belong in the spec's *Known
limits* at Stage 8.
