# feature-external-developer — plan

- tier: full (an external model writes in the user's real working tree)
- target: glab 0.6.0 → 0.7.0
- base: `9108ac7`; `30f2c80` on top of it adds only files under `plan/feature-codex-agent/` (`git diff --stat 9108ac7 30f2c80`), so every line number here holds on both
- the second change of two (`9108ac7:plan/feature-codex-agent/questions.md` Q1);
  closes `[feature-codex-agent/plan.md not-in-plan-1]` ("The external
  developer") and `[feature-opencode-worker/plan-r3.md not-in-plan-2]`
- findings: `findings.md` (F1-F4)
- revision 2 (after Stage 1b round 1/2, NOT BUILDABLE): see *Changes in
  revision 2* at the end.

## Decisions

Binding, from the user (`9108ac7:plan/feature-codex-agent/questions.md`):

- U1 — A4: Codex can be a developer subagent.
- U2 — Q3: it edits the working tree directly, as `glab:developer` does,
  under Codex's own `workspace-write` sandbox in the user's repository. No
  patch and no apply step.
- U3 — Q4 = A: the same trust as a Claude developer. The manager reads the
  whole change before it runs the gates; Stages 3-5 do not change.
- U4: model, effort and login work as in 0.6.0. Live runs only on the user's
  instruction.

Engineering choices (`glab:manager` Rule 3, recorded here):

- D1 — `--role developer` is Codex's only. OpenCode refuses it with exit 2
  (`USAGE`), before anything is created. OpenCode stays read-only.
- D2 — A developer turn asks for `sandbox_mode="workspace-write"` with
  `sandbox_workspace_write.network_access=false`,
  `sandbox_workspace_write.exclude_tmpdir_env_var=true` and
  `sandbox_workspace_write.exclude_slash_tmp=true`, and
  `approval_policy="never"`. Its commands can write in the repository and
  nowhere else (F3: `$TMPDIR` holds every agent's state).
- D3 — The header check accepts, for a developer, exactly
  `sandbox: workspace-write [workdir]` and `approval: never`. Anything else
  is exit 12 `NOT READ-ONLY`, with the same name and the reply withheld as
  now. For every other role it stays exactly `read-only`. The string is
  inferred from Codex's source (F2); Stage 4's M5 measures it. If 0.163.0
  prints another string for this sandbox, that is `PLAN WRONG` for P1, not
  something to widen at develop time.
- D4 — The change report. Before and after each developer turn, the script
  snapshots every tracked and every untracked-but-not-ignored path with its
  work-tree state, and a digest of `.git`'s `HEAD`, refs, `config`, hooks
  (the `core.hooksPath` directory included), `info/`, and the list of nested
  `.git` entries. Revision 3 (R3.4): the snapshot never runs `git status`,
  which ran the repository's clean filters, and a submodule's, on the host
  (`review-r1.md` X1); revision 2 said `git status --porcelain`. Between the header line and `reply:` it prints
  one `changed: <XY> <path>` line per path whose entry changed (or
  `changed: none`), then `git: unchanged` or `git: changed`. It prints them
  on every exit after a turn ran: 0, 6, 7 and 12. Exit 8 is the reviewer's
  report check (`finish_turn`, L1152) and never ends a developer's turn. A
  changed `.git` is not an exit code (F4): the manager stops on the
  `git: changed` line.
- D5 — The developer's first message: the default profile's
  *Developer, before the contract* section in place of its *Before the
  contract* section, the host text for a developer, the body of
  `agents/developer.md` as its contract, both skills, the brief, the
  profile's *After the contract*, then a developer tail (P3, verbatim).
  *Before the contract* says "to read, analyse, review or answer, never to
  change anything" (`profiles/default.md` L10-L11), which is right for every
  other role and false for this one, so a developer gets a section of its
  own rather than a sentence reworded to fit both. A Codex agent's profile
  is always `default` (`codex_model_allowed`, L484-L485), so no family
  profile needs one. `send` appends the tail too, as
  `reviewer_tail` is appended for a reviewer.
- D6 — The manager writes `result.md` from the agent's final message, marked
  as that model's words, with the script's `changed:`/`git:` lines and the
  gates the manager ran itself. The agent is told not to write it.
- D7 — One external developer at a time: no split, and never beside a
  `glab:developer`, since they share one working tree. A re-dispatch after
  `BLOCKED` or `PLAN WRONG` is a new agent; a report that is missing fields
  gets one `send`. The old agent is stopped.
- D8 — A developer turn that ends in any exit but 0, or prints
  `git: changed`, stops the pipeline: the manager shows the user the
  `changed:` lines and does not revert, commit or re-run anything on that
  tree. Reverting would be destructive (`glab:security`); it is the user's
  call.

## Before

1. `export TMPDIR=/data/tmp/claude`. Run the four *Gates* of `AGENTS.md`
   and the plugin gates, and paste what they print. Green, with
   `PASS 71/71` from `tests/external-agent.test.sh`. A red tree stops here.
2. `git status --short` shows only `?? plan/SESSION-HANDOFF.md` and this
   plan folder.

## Processing

### P1 — the developer role (`plugins/glab/scripts/external-agent.sh`)

- Header comment (`glab:comments`: amend what is there, do not only add):
  - L2-L6, the opening, which says "read-only" of every agent, become,
    verbatim:

        # external-agent.sh — start, continue, list and stop external agents
        # on two backends: an OpenCode session on a model the user named, working on a
        # sandboxed read-only copy of a repository; or a Codex session on this host,
        # working in the repository itself under Codex's own sandbox, read-only for
        # every role but a developer's, on the model the user named or Codex's default.

    The rest of that sentence (from "The glab:external-agents skill is the
    caller's manual") stays.
  - The usage line becomes `[--role general|reviewer|developer]`, with
    "developer is taken by codex only" in the note under it.
  - The exit list keeps `12 NOT READ-ONLY` and adds under it: "for a
    developer, a sandbox other than the workspace-write one it asked for".
  - The *Codex* bullet at L90-L99 ("Codex's own read-only sandbox is the
    containment: its commands change no file, … Every turn asks for
    sandbox_mode read-only and approval_policy never, …") is rewritten so it
    is true of both modes: for every role but a developer, the read-only
    sandbox as it says now, with the measurements it cites; for a developer,
    `workspace-write` with network off and `/tmp` and `$TMPDIR` excluded (D2),
    so its commands change files in the repository only; the header check
    accepts `read-only`, or `workspace-write [workdir]` for a developer (D3).
    Its measured facts (the IP network, the Unix-domain socket) stay as
    measured for read-only, and say that the developer's are Stage 4's M4.
  - Add one bullet after it for the change report (D4), naming what it does
    not see: a write to an ignored file (F3), and a change made by Codex
    itself outside its command sandbox other than to a ref, the config or a
    hook.
- `cmd_start`: L1239 becomes
  `case $role in general|reviewer|developer) ;; *) die 2 USAGE "--role must be general, reviewer or developer" ;; esac`.
  After `isolation=` is set (L1246), add
  `[ "$role" != developer ] || [ "$backend" = codex ] || die 2 USAGE "--role developer is taken by the codex backend only"`.
  This sits before `mkdir`, so nothing is created.
- `codex_argv`: the `-c 'sandbox_mode="read-only"'` argument becomes, for
  `$(meta role)` = developer, the four `-c` arguments of D2 in this order:
  `'sandbox_mode="workspace-write"'`,
  `'sandbox_workspace_write.network_access=false'`,
  `'sandbox_workspace_write.exclude_tmpdir_env_var=true'`,
  `'sandbox_workspace_write.exclude_slash_tmp=true'`. Every other argument,
  and the whole argv of every other role, stays byte for byte as it is (E51
  pins it). Comment: why `/tmp` and `$TMPDIR` are excluded (F3), and that
  the header check, not these flags, decides.
- `codex_verify`: the wanted sandbox is `workspace-write [workdir]` for a
  developer and `read-only` otherwise. The die message becomes
  `codex reported sandbox '<sb>' and approval '<ap>' where '<wanted>' and 'never' were asked; its reply is withheld`.
  Its comment adds where the developer string comes from (F2, the source
  URL) and that ` (network access enabled)` or any extra entry fails it.

Verify: `bash -n`, `shellcheck`; E51, E54, E72, E73, E76.

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).**

- **R3.1 (X4) — a state root inside the repository is refused.** In
  `cmd_start` for a developer, once `top` is known, and in `run_host` before
  every developer turn: when `realpath "$root"` is `realpath "$top"` or
  below it, the script stops before anything runs. Why, in the comment: the
  work tree is the developer's one writable root, so a state root inside it
  would let the agent rewrite `state.before`, `run/stderr.txt` (which
  `codex_verify` reads) or any agent's `agent.json`, whose `cli` the next
  `send` runs unsandboxed. Built as `dev_refuse` (`realpath -e` of both):
  exit 2 `USAGE` at `start`, before `mkdir`, so nothing is created; exit 4
  `UNAVAILABLE` before each later developer turn (E81).
- **R3.2 (X1, X2) — a nested `.git` is refused at start.** A developer
  `start` stops when the work tree holds any `.git` other than
  `<top>/.git`, a gitfile or a directory, at any depth: a submodule, a
  nested repository. Why, in the comment: git run over it, by the script or
  by the manager, loads that repository's own config (filters, fsmonitor,
  hooks), which the agent can write; Codex protects `<top>/.git` only. A
  nested `.git` that appears during a turn makes `git: changed` (R3.4).
  Built in the same `dev_refuse`, with the same exits: 2 at `start`,
  4 before each later turn (E79).
- **R3.3 (X6, T6) — comments made true after Stage 4.** The header's
  sentence on the developer's network and sockets cites
  `[feature-external-developer/integration.md M2, M3, M4]` as measured, no
  longer "not measured yet". `codex_verify`'s comment cites M5 for
  `workspace-write [workdir]`, no longer "inferred from Codex's source".

**Revision 4 (review r2, `review-r2.md`, approved by the user 2026-10-18 as the last minimal round, `questions.md` *Review round 2*).**

- **R4.1 (advisory) — `dev_refuse` with the top at `/`.** It compares
  against `${t%/}`, so a top of `/` does not make every path look like it
  is outside the top.

### P2 — the change report (`plugins/glab/scripts/external-agent.sh`)

- New `dev_state <top>`, next to `hostgit`. It prints, sorted with
  `LC_ALL=C`:
  - one line per entry of
    `hostgit -C <top> status --porcelain=v1 -z --no-renames --untracked-files=all`:
    `<XY>` TAB `<kind>` TAB `<path as printf %q>`. `<kind>` is
    `hostgit hash-object --no-filters -- <path>` for a regular file that is
    not a symlink; `link:` plus the `%q` of `readlink` for a symlink;
    `none` for a path that does not exist; `other` for anything else. A
    symlink or a special file is never opened (F3).
  - one last line, `git` TAB `<sha256>`, over: `rev-parse -q --verify HEAD`,
    `symbolic-ref -q HEAD`, `for-each-ref --format='%(objectname) %(refname)'`,
    the bytes of `<common dir>/config`, and `sha256sum` of each file under
    `<common dir>/hooks`, where the common dir is
    `hostgit -C <top> rev-parse --path-format=absolute --git-common-dir`.
    `--git-path hooks` is not used: `hostgit` sets `core.hooksPath=/dev/null`.
  - Expected non-zero exits are states, not failures, and each goes into the
    digest as a fixed word: `rev-parse -q --verify HEAD` exiting 1 (no
    commit yet) is `head: none`; `symbolic-ref -q HEAD` exiting 1 (a
    detached HEAD) is `symref: none`; a missing `config` is `config: none`; a
    missing `hooks` directory is an empty list. A repository with no commit
    is already accepted by `cmd_start` (L1282-L1286), so `dev_state` must not
    fail on it. Any other non-zero exit of these commands, or of `status` or
    `hash-object`, is a failure (the next bullet).
- `run_host`: for a developer, `dev_state "$repo" >"$run/state.before"`
  before the turn starts, and `dev_state "$repo" >"$run/state.after"` after
  `sweep_agent`. A failing `dev_state` is `die 4 UNAVAILABLE "cannot read the
  state of $repo"` before the turn; after it, the after-file holds
  `git<TAB>unreadable`, which reports `git: changed`.
- New `dev_report`: compares the two files by path and prints
  `changed: <XY after, or -- when the path is no longer listed> <path>` for
  each path whose line differs, sorted by path; `changed: none` when none
  does; then `git: unchanged` when the two `git` lines are equal, else
  `git: changed`. Every line goes through `clean`.
- `header`: after its line, `dev_report` when `$(meta role)` = developer
  and `$run/state.after` exists. Its two callers (F1) are the post-turn
  exits only, so the report is printed on 0, 6, 7 and 12 (8 is
  reviewer-only, D4).
- The header comment's stdout block lists the two new lines between the
  `agent:` line and `reply:`, "developer only".

Verify: E74, E75, and E73's refusals still printing the report.

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).** The bullets above
that name `git status` describe revision 2; where they differ from these,
these hold.

- **R3.4 (X1, X3, X5, T5, and both advisories) — `dev_state` rewritten.**
  - It never runs `git status`. Tracked paths come from
    `hostgit ls-files -s -z` (mode, object id, path), untracked ones from
    `hostgit ls-files -o -z --exclude-standard`.
  - Each path's work-tree state: its type, mode, size, times, inode and
    link target, from one `find -files0-from - -maxdepth 0 -printf` over
    all listed paths, which opens nothing; and, for a regular file up to
    `DEV_HASH_BYTES` (16 MiB), its content hash, from one
    `hostgit hash-object --no-filters --stdin-paths` for all of them
    (batched, X5), each path C-quoted first, which `--stdin-paths` unquotes,
    so a newline in a name is safe. Above the cap the kind is
    `big <mode> <size> <mtime> <ctime> <inode>`, so a sparse or huge file is
    never read. A symlink's kind carries its target and is never opened.
    Every file's mode is in its kind, an untracked file's included
    (advisory): a `chmod +x` is listed.
  - A state line is `<%q path>` TAB `<index entry, or ->` TAB `<kind>` TAB
    `<code>`. A path is reported when its line differs between before and
    after, as `changed: <code> <path>`, where the code is `??` untracked,
    ` D` tracked and missing, ` M` tracked and not as the index has it, and
    `--` as the index has it, or no longer listed. It is no longer git
    status's `XY` (revision 2).
  - The `git` digest (`dev_git`) adds: the directory `core.hooksPath`
    names, read with plain `git config --includes --type=path` (not
    `hostgit`, whose `-c` sets that key) and taken relative to the top,
    digested as `hooks/` is (X3, husky v9); the config as git reads it,
    `git config --includes --list -z`, so a setting in an ignored file that
    the config includes is a change too (built beyond the review's "check
    `core.hooksPath`": it is how that value is read safely, and it catches a
    planted `core.fsmonitor` or filter the same way); everything under
    `<common dir>/info/` (T5); and every nested `.git` in the work tree
    (R3.2).
  - Both snapshots run through `dev_snap`: `setsid timeout --kill-after=5
    <limit> bash -c`, with the functions exported in that subshell only and
    the agent's lock descriptor closed. The limit is the turn's `--timeout`,
    at most `DEV_STATE_S` (300 s). Its group carries the agent's marker and
    is killed when `dev_snap` ends, and by `cleanup`, so a stop or a signal
    ends it; one a SIGKILLed script left is swept at `stop` or at the next
    `send`. A before-state that cannot be read in time is exit 4. An
    after-state that cannot be read makes the report print one
    `changed: unreadable` line, then `git: changed`, in place of a
    `changed: --` for every path (advisory).
  - Requirements this adds: `find` with `-files0-from` and `-printf` (GNU
    findutils 4.9 or later, or bfs; this host's is bfs 4.1.1), and
    `realpath -e`.

**Revision 4 (review r2, `review-r2.md`, approved by the user 2026-10-18 as the last minimal round, `questions.md` *Review round 2*).** Where these differ from R3.4, these hold.

- **R4.2 (R2-2) — the `find` probe.** `dev_state` needs `find -files0-from`
  (findutils 4.9 or later, or bfs). An older `find` fails without a word,
  and the report then misses every tracked-file edit. So a developer
  `start`, and `check` for Codex, run
  `printf '.\0' | find -files0-from - -maxdepth 0 -printf x` once, and exit
  4 `UNAVAILABLE` when it does not print `x`. Built as `need_find`: at a
  developer `start` before anything is created, and in `codex_check` after
  the tools loop. It prints nothing when it passes, so `check`'s output is
  unchanged (E59). Its message: "find does not take -files0-from (findutils
  4.9 or later, or bfs); see the README's Requirements".
- **R4.3 (R2-3) — ignored entries.** The state also lists the ignored
  entries, by name only, with `hostgit ls-files -z -o -i --exclude-standard
  --directory`, so a path the agent makes ignored (a `.gitignore` it writes,
  such as `pkg/zz/.gitignore` holding `*`) shows up as a new entry instead
  of vanishing. Each is one line, `<%q path>` TAB `-` TAB `ignored` TAB
  `!!`. A new or removed ignored name is reported with the code `!!`; a
  write inside an ignored file or directory is not.
- **R4.4 (R2-5) — what `--` means, exactly.** The header states it word for
  word as the code assigns it. `--` is "a tracked regular file of at most
  16 MiB whose hash and executable bit match its one stage-0 index entry,
  or a path no longer listed". ` M` is "every other tracked path, each
  tracked symlink and each tracked file above 16 MiB included, whatever it
  holds". `!!` is ignored (R4.3), and `??` and ` D` are as in R3.4. The
  `dev_state` comment and the change-report bullet say the same. The
  revision-3 sentence ("as the
  index has it, or no longer listed") was wrong for a tracked symlink and a
  file over 16 MiB.

### P3 — the developer's first message (`plugins/glab/scripts/external-agent.sh`)

`first_prompt`: when `$1` = developer, it prints
`section "$profiles/default.md" '## Developer, before the contract'` in
place of the two *Before the contract* lines (L824-L825); a developer's
profile is always `default` (D5), so no family section is read. Then the
host text below in place of the read-only one; then `# Your role contract` with
`body "$plugin/agents/developer.md"`, `# The skills you carry` with both
skills, and `# Your dispatch` with the brief, as the reviewer's are framed;
then `# Before you answer` and the profiles' *After the contract*, as now;
then `developer_tail`. `cmd_send` appends `developer_tail` for a developer,
next to `reviewer_tail` (L1337).

The developer host text, verbatim, with `@TOP@` replaced as now:

    # Where you are working

    - You are working in the repository at @TOP@ itself: the user's real
      working tree, its history and its ignored files, not a copy. Codex runs
      you in its workspace-write sandbox: your commands can change files in
      @TOP@, and nowhere else, /tmp and $TMPDIR included. A command that needs
      a scratch directory or a cache outside @TOP@ fails; do not make one
      inside @TOP@ instead.
    - @TOP@/.git is not yours: never commit, stage, stash, switch branches,
      or change a ref, the git config or a hook. The script compares them
      after every turn, and a change there stops the work.
    - Your commands can also read files outside the repository. Read nothing
      outside @TOP@ unless your task names it: what you read is sent to the
      model's provider.
    - Your commands have no network. You have no web tool: do not try to fetch
      pages.
    - Read @TOP@/AGENTS.md before anything else: it is the repository's
      working agreement. If there is none, read @TOP@/CLAUDE.md and say in
      your answer that the repository has no working agreement.

`developer_tail` prints, verbatim:

    # Your final message

    Two things in your contract work differently here:

    - Do not write plan/<slug>/result.md. The manager writes it from your
      final message, so your final message is that file's content, under its
      headings, followed by your contract's Report block and its verdict line.
    - Run the gates your contract names if your sandbox lets them run. A gate
      that fails because a command cannot write outside the repository, or
      cannot start a sandbox of its own, is not red: write "not run here:"
      and its error line. The manager runs every gate itself after your turn.

    Your changes stay in the working tree. After each turn the script lists
    every path you changed, from git, for the manager.

`plugins/glab/skills/external-agents/profiles/default.md` gets a section of
its own for the developer (D5). *Before the contract* (L8-L18) is not
changed: every other role still gets it, "never to change anything"
included. The new section goes after *After the contract* and before
*Notes*. Its heading must not start with `## Before the contract`, because
`section()` (L820) matches a heading by its prefix: a heading such as
`## Before the contract, developer` would be printed to every other role
too. The section, verbatim:

    ## Developer, before the contract

    You are an external developer in the glab workflow. A manager has started
    you to do one job: to build the plan steps your dispatch names, by
    changing files in the repository you work in, and nothing else.
    This file is everything you are given: where you are working, the
    contract and the rules you carry, and the task. The manager may send you
    more messages later in this same conversation.

    Read all of it before you act. The rules are rules, not suggestions: where
    your habits differ from them, they win. Do only what the task asks. When
    something stops you, say so in your answer rather than working around it.

The *Notes* list gets one bullet, verbatim:

    - *Developer, before the contract* takes the place of *Before the
      contract* for a `--role developer` agent, which only Codex runs, so only
      this profile has it: the first section says the agent changes nothing.
      Its heading does not start with `## Before the contract`, because the
      script finds a section by its heading's prefix.

*After the contract* is sent to a developer unchanged: its three checks hold
for a developer too.

Verify: E77, and E61 unchanged for a general agent.

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).**

- `profiles/default.md` L3-L7, the intro that said two sections are sent,
  now names the third, the developer's. It was a Stage 1b note that the
  manager passed to the developer (`questions.md`, *Correction to the
  record*), recorded here so the plan names every hunk.

### P4 — tests (`tests/external-agent.test.sh`)

Stub only. The Codex stub's header `sandbox:` value is computed from its
argv the way F2 says Codex does: `read-only` for
`sandbox_mode="read-only"`; for `sandbox_mode="workspace-write"`,
`workspace-write [workdir` + `, /tmp` unless
`sandbox_workspace_write.exclude_slash_tmp=true` + `, $TMPDIR` unless
`sandbox_workspace_write.exclude_tmpdir_env_var=true` + `]`, then
` (network access enabled)` when `sandbox_workspace_write.network_access=true`.
The existing `ro-net` and `ro-appr` overrides stay. New scenarios:
`ww-tmp`, `ww-net`, `ww-full` (headers `workspace-write [workdir, /tmp, $TMPDIR]`,
`workspace-write [workdir] (network access enabled)`, `danger-full-access`),
`ww-plain` (`workspace-write [workdir]` whatever the argv), `ro-forced`
(`read-only` whatever the argv), `dev-edit`, `dev-commit`, `dev-hook`,
`dev-config`. Each `dev-*` case runs on a throwaway repository of its own
under `$W`, through `CR`.

E27's L613 becomes `--role writer` with `--role must be general, reviewer or developer`.
E27's title (L620) says "a role that is not read-only", which goes stale
now that one role writes: it becomes "a role that is not general, reviewer
or developer".

- **E72** — a Codex developer's start gets the D2 `-c` arguments in place of
  `sandbox_mode="read-only"`, everything else as in E51; its send resumes
  with the same; `list` shows `role=developer`.
- **E73** — a developer whose header says `workspace-write [workdir]` and
  `never` is exit 0 with its reply. `ww-tmp`, `ww-net`, `ww-full`,
  `ro-forced` and `ro-appr` are 12: `NOT READ-ONLY` with the wanted string in
  the message, no `reply:` and no `| ` line, the `changed:` and `git:` lines
  present, `end:` last, the agent kept. A general agent with `ww-plain` is
  12 too.
- **E74** — the change report. The test repository has a tracked file
  modified before the turn, an untracked file, and clean tracked files.
  `dev-edit` appends to the modified file, edits a clean one, deletes one,
  creates `new file` and a file whose name holds a newline, and creates an
  untracked symlink to `/dev/zero`; the pre-existing untracked file is left
  alone. The `changed:` lines are exactly those six paths, each on one line
  (the newline escaped), sorted, with `--` for none of them and `D` for the
  deleted one; the untouched untracked file is not listed; `git: unchanged`;
  the turn ends (no hang on the link). A `turns` turn on the same repository
  prints `changed: none`. A general agent prints no `changed:` or `git:` line.
- **E75** — `dev-commit` (an empty commit), `dev-hook` (writes
  `.git/hooks/pre-commit`) and `dev-config` (`git config` of a new key) each
  print `git: changed`; the exit is 0 and the reply is shown.
- **E76** — OpenCode with `--role developer` is 2 with
  `--role developer is taken by the codex backend only`, and `agents` counts
  0 after it.
- **E77** — a developer's first message holds, in order, the developer host
  text with the repository top, `# Your role contract` with a line of
  `agents/developer.md`, both skills, `# Your dispatch` and the brief,
  `# Before you answer`, and the developer tail; not the read-only
  sentence ("you cannot change any file") and not the reviewer tail. A
  developer's send message ends with the developer tail.
  The profile part, both ways: a developer's first message holds
  `You are an external developer in the glab workflow.` before the host
  text, and holds neither `never to change anything` nor
  `You are an external agent in the glab workflow.`; a general Codex
  agent's first message, on the same stub, holds `never to change anything`
  and not `You are an external developer in the glab workflow.`.

Coverage, as a list (`AGENTS.md` *Tests*):

| step | cases |
|---|---|
| P1 role parsing and OpenCode refusal | E27, E76 |
| P1 argv | E72 (developer), E51 (others unchanged) |
| P1 header check | E73, E54 |
| P2 snapshot and report | E74, E75; on the 12 path E73 |
| P3 first message, `default.md`'s developer section, send tail | E77; E61 for the general text |
| P5-P7 Markdown | no gate; the searches in *After* |

Not covered by any case, accepted:

- the report on exits 6 and 7: `header` is the one place it is printed,
  and E73 shows it on 12, a path through the same `header` call;
- `dev_state` failing before the turn (`die 4`): it needs a repository git
  cannot read, which the stub cannot make without breaking `--repo`;
- the real sandbox's behaviour: Stage 4 (*After*).

Verify: the four gates; `PASS 77/77` (revision 2; revision 3: `PASS 82/82`; revision 4: `PASS 84/84`).

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).**

New cases, each a stub case on a throwaway repository of its own (names
and order as built: E78-E82, then E74 and E75 extended):

- **E78** (X1): a repository with a clean filter, `required`, and an
  fsmonitor set; the turn touches a tracked file. The report runs neither,
  and the touch alone is no change. Known positive: a plain `git status`
  there does run them.
- **E79** (X2, R3.2): a nested repository, and a gitfile, refuse a developer
  `start` with exit 2 and nothing created; `git init nest` in a turn is
  `git: changed`; the next `send` is refused with exit 4.
- **E80** (X3): a new hook in an ignored `core.hooksPath` directory, and a
  setting in an ignored file the config includes, are each `git: changed`.
- **E81** (X4, R3.1): `TMPDIR` inside the repository is refused with exit 2
  and nothing created; with `TMPDIR` a link re-pointed after the state has
  moved into the repository, a `send` is refused with exit 4; `stop` still
  works.
- **E82** (X5): a stand-in `git` that hangs after the turn gives
  `changed: unreadable` and `git: changed` within 20 s at a 3 s limit, and
  leaves no process; a sparse 64 GiB file is `changed: ?? big`, not read.
- **E74** extended: an untracked link retargeted in the turn is
  `changed: ?? zl2` (T3); `-- r.txt`, a modified file put back as committed,
  and `?? d/f`, a new directory (T4); a mode change is listed (advisory).
- **E75** extended: `dev-switch`, a branch switch, and `dev-info`, an
  `info/exclude` line, are each `git: changed` (T4, T5).

Each of E74, E75 and E78-E82 failed against a one-change mutant of its fix
(`result-p1-p4.md`, *Round 2*, *Tests*).

Not covered, accepted: `dev_snap` failing before the turn (exit 4), which
needs E82's stand-in armed before the turn; `dev_refuse`'s "cannot resolve"
and 300 s search-limit branches; `config list: none`; the report on exits 6
and 7, as before.

Count after revision 3: `PASS 82/82`.

**Revision 4 (review r2, `review-r2.md`, approved by the user 2026-10-18 as the last minimal round, `questions.md` *Review round 2*).**

- **R4.5 (R2-4) — the two T4 mutants.** `dev-edit` also deletes the
  untracked `u.txt` that existed before the turn, and E74 expects
  `changed: -- u.txt` (kills the `gone` mutant). `dev-switch` switches to an
  existing branch at the same commit, so only the symbolic ref changes, and
  E75 still expects `git: changed` (kills the `nosymref` mutant).
- **R4.6 (R2-7).** The test comment at L1167 that says the report runs
  `git status` is amended to say what it runs now (`glab:comments`).
- New cases: a stand-in old `find` makes a developer `start` and `check`
  exit 4 (R4.2); a `.gitignore` holding `*` written in a turn under a new
  directory is reported (R4.3). As built:
  - **E83**: a stand-in `find` that rejects `-files0-from` makes a developer
    `start` exit 4 with no agent created, and makes `check` exit 4.
  - **E84**: a `pkg/zz/.gitignore` of `*` written in the turn, with a file
    beside it, gives exactly `!! pkg/`, `!! pkg/zz/`, `!! pkg/zz/.gitignore`
    and `!! pkg/zz/new.txt`, then `git: unchanged`. The known positive:
    `ls-files -o --exclude-standard` lists nothing there.
  - E74 expects `-- u.txt` and keeps an untouched untracked `v.txt`, which
    must not be listed. E75's `dev-switch` checks out a branch the test makes
    first at the same commit. E80's `dev-include` now also prints
    `changed: !! .inc`.
  - Each was failed by a one-change mutant (`probe`, `ignored`, `gone`,
    `nosymref`; `result-p1-p4.md` *Round 3*).
  - Uncovered: the `${t%/}` advisory, which needs a repository whose top
    is `/`.

  Count: `PASS 84/84`.

### P5 — `plugins/glab/skills/external-agents/SKILL.md`

- Description and opening: read-only, except a Codex developer. L17's
  "There is no external developer." becomes "A Codex agent can also be a
  developer (`--role developer`): it changes files in the repository, and
  nowhere else."
- *When this applies*: a third bullet, "Rule 5 has recorded an external
  developer for `glab:developer`: then `/glab:develop` runs one
  `--role developer` agent (*The developer role* below)."
- *Start, send, list, stop*: the start example for a developer, with
  `--role developer`.
- *Reading what comes back*: the `changed:` and `git:` lines; exit 12's row
  covers a developer's sandbox.
- New section, with the heading line `## The developer role` exactly,
  after *The reviewer role*: the brief is
  what `/glab:develop` gives a `glab:developer` (the slug, the step ids, what
  was decided in chat), no file boundary because there is no split (D7); the
  agent does not write `result.md` (D6); its commands cannot run anything
  that writes outside the repository, so its gates may say "not run here";
  what the manager does with `changed:`, `git: changed` and a non-zero exit
  (D8); one `send` for missing report fields; stop it once its report is
  read.
- *What the script guarantees*: the developer's sandbox (D2, D3), the report
  (D4), and what it does not cover: ignored files, writes Codex itself makes
  outside its command sandbox, and that a breach is reported after the turn,
  not prevented by the script.
- The once-per-session notice: for a developer, the README's sentences of
  P7, in the same words. The sentence "Its commands change no file" (L68-L69, and L249 in *What the script guarantees*) is
  scoped to every role but a developer.
- `workspace-write [workdir]` appears in the skill in backticks, on one
  line, where it states what the header check accepts.

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).**

- **The manager's inspection command (X1).** *The developer role* says the
  manager reads the change from the script's `changed:` and `git:` lines and
  from `git diff --no-ext-diff --no-textconv --ignore-submodules=all` and
  by reading each untracked file the `changed:` lines name, never from a
  plain `git status`, which runs a submodule's fsmonitor and the
  repository's clean filters on the host. A nested repository stops the
  work, as `git: changed` does. UNVERIFIED: that this `git diff` runs no
  filter the user has configured for the top repository. M3 shows that the
  agent cannot add one to `.git/config`.
- **The refusals (R3.1, R3.2)** go into the skill's exit rows 2 and 4 and a
  *What stops it before a turn* paragraph: 2 at start, 4 before a later
  turn.
- **The report's wording** follows the script: the codes `??`, ` D`, ` M`,
  `--`; `changed: none`; `changed: unreadable`; what `git: changed` covers;
  the 16 MiB cap and the time bound of at most 300 s; and, for ignored
  files, the one exception, the `core.hooksPath` directory. README L88-L92
  and the skill's notice carry it in the same words.
- **X6.** *Its network* gives the developer's measurement: TCP refused at
  `socket()` and AF_UNIX at `connect()`, under workspace-write
  (`integration.md` M4), with `/tmp`, `$TMPDIR` and paths outside the
  repository read-only (M2).
- **T1.** L66, the once-per-session notice: "under Codex's own sandbox
  (read-only, or workspace-write for a developer)", in the same words as
  README L72, so the data note stays identical in both files.
- **T2.** L88-L91, the effort rule: "in the model line for the reviewer or
  the developer (Rule 5)".

**Revision 4 (review r2, `review-r2.md`, approved by the user 2026-10-18 as the last minimal round, `questions.md` *Review round 2*).** These replace revision 3's
inspection command, which runs filters too (R2-1).

- **R4.7 (R2-1) — the inspection, filter-free.** *The developer role*
  drops the `git diff` line. The manager inspects only after
  `git: unchanged` and with no nested-repository refusal; it compares each
  path a `changed:` line names with
  `git -c core.fsmonitor=false cat-file blob HEAD:<path> | diff -u - <path>`
  (`cat-file` applies no filter), reads an untracked file directly, and runs
  neither `git status` nor `git diff` on the tree before that. It says
  plainly that both of those commands run the repository's filters (and
  fsmonitor), which is why.
- **R4.2 (R2-2).** The Codex prerequisites name `find` with `-files0-from`
  and `-printf` (GNU findutils 4.9 or later, or bfs), and `check`'s new
  line.
- **R4.3 (R2-3).** The skill says the agent can make a path ignored itself,
  and that a new ignored entry is reported by name.
- **R4.4 (R2-5).** The meaning of `--`, in the header's words.
- **Advisories.** L126: "creates nothing" becomes "creates no agent". The
  exit-2 row names a `.git` inside an ignored dependency directory (a
  vendored or installed package) as a likely cause of the refusal.

### P6 — `plugins/glab/skills/manager/SKILL.md` and `plugins/glab/commands/develop.md`

- Rule 5 (L120): the user may also name an **external developer**, Codex
  only — "develop on Codex", or "develop on Codex, <id>". "There is no
  external developer: an external agent changes no file." becomes "An
  external developer is Codex only: OpenCode cannot change files." Its
  record line is the reviewer's with `glab:developer`:
  `- model: glab:developer codex, effort <level> (…), for <scope> — the user's instruction, not a manager choice: "<the user's words>"`,
  `codex:<id>` when the user named one. Its handoff line:
  `slug · develop · model codex:<model> · round 1/1 · BUILT`.
- Rule 5, *Carry it into every dispatch* (L123): on the developer's
  occasions, run `/glab:develop`'s dispatch through `glab:external-agents`
  with `--role developer` (D7). A backend that is unavailable, times out,
  fails or reports 12: stop and tell the user (D8).
- Rule 5, *These two roles only* (L125): "Only the reviewer can be
  external; no other role ever is." becomes "Only the reviewer, on either
  backend, and the developer, on Codex, can be external; no other role ever
  is."
- Rule 5's model table (L139 is the reviewer's row): a row after it, on one
  line, verbatim (the indented block is the line):

      | an external developer | nothing you write: the script frames it with the default profile's developer section, the developer's contract and its tail (`glab:external-agents`); your brief is the slug and the step ids, as for `opus` |

- Rule 6 (L154) *It changes nothing*: "except a Codex developer under
  Rule 5, which changes files in the repository and nowhere else". L156 *It
  takes no stage's role, except the reviewer under Rule 5* becomes *It takes
  no stage's role, except the developer and the reviewer under Rule 5*, with
  `except the developer and the reviewer under Rule 5` on one line.
- `develop.md` *Decide the split*: one sentence, an external developer is
  one agent, never split and never beside a `glab:developer` (D7).
  *Dispatch*: a bullet after the existing four, verbatim, as one line of
  the file (the indented block is the line):

      - **An external developer**, only when `glab:manager` Rule 5 recorded one: start it through `glab:external-agents` with `--role developer` instead of dispatching `glab:developer`, with the same brief. One agent, never split, never beside a `glab:developer`.

  *When the agents
  return*: before the gates, for an external developer: the exit and the
  `git:` line first (D8); then read the whole change — `git status`,
  `git diff`, every untracked file the `changed:` lines name — against the
  plan (U3); then write `result.md` from its reply (D6); then the gates as
  now. The four ask-conditions sentence (L14) is not touched.

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).**

- **X1.** `develop.md` *When the agents return* names the same inspection
  command as the skill (R3.5), never a plain `git status`.
- **develop.md L2 and L8** ("through glab:developer agents", "the
  `glab:developer` agent does") also name the external developer path.
- **T2.** Rule 6's effort bullet (L156): "in the model line for the
  reviewer or the developer (Rule 5)".
- **Advisory, Rule 6 (L150):** "for read-only work" gains "except a Codex
  developer under Rule 5".
- **Advisory, Rule 5 *Carry it* (L123):** where it offers an external
  reviewer for a name the parameter does not take, it offers an external
  developer too.

**Revision 4 (review r2, `review-r2.md`, approved by the user 2026-10-18 as the last minimal round, `questions.md` *Review round 2*).**

- **R4.7 (R2-1).** `develop.md` *When the agents return* carries the same
  filter-free inspection as the skill, and no `git diff` line.

### P7 — `README.md`, `AGENTS.md`, version

- `README.md`:
  - In the Codex paragraph (L70-L81), "Its commands change no file" (L76-L77) becomes
    "Its commands change no file, unless it is a developer". After the
    paragraph, a new one, verbatim; each of the three searched phrases
    (`A Codex developer changes files in your repository`,
    `workspace-write [workdir]`, `A change to .git is reported`) stays on
    one line when it is wrapped:

        A Codex developer changes files in your repository, and runs only
        when you name it for the developer. Its sandbox is Codex's
        `workspace-write [workdir]`: no network, and no write outside your
        repository, `/tmp` and `$TMPDIR` included.
        A change to .git is reported after each turn — a commit, a ref, the
        config or a hook — and the manager stops on it; the script does not
        prevent it. A write to an ignored file is not reported.

    Superseded by revision 4's R4.8 (before *After*), which gives the
    paragraph as P5 and the README carry it now.

  - After the Codex tested-against sentence (L93-L94), verbatim:
    `The developer role has been tested against a stub, and its sandbox offline with `codex sandbox`.`
    with `The developer role has been tested against a stub` on one line.
  - The `Not yet shown: any reply from a DeepSeek model` sentence is not
    touched.
- `AGENTS.md` *One fact*:
  - the manual model rule: "the developer and reviewer only" gains "an
    external one: the reviewer on either backend, the developer on Codex
    only";
  - "the Codex read-only check (the script, E54, the skill, `README.md`)"
    becomes "the Codex sandbox check — `read-only`, or
    `workspace-write [workdir]` for a developer, with `approval: never`
    (the script, E54, E73, the skill, `README.md`)";
  - "the host first message (the script's `first_prompt`, E61)" gains "and
    the developer's first message — its host text, its tail and the
    default profile's *Developer, before the contract* section, which
    replaces *Before the contract* for a developer (the script's
    `first_prompt` and `developer_tail`,
    `plugins/glab/skills/external-agents/profiles/default.md`, E77)";
  - new: "the external developer — Codex only, `--role developer`, its
    sandbox keys (the script's header and `codex_argv`, E72, E76, the
    skill, `glab:manager` Rules 5 and 6, `plugins/glab/commands/develop.md`,
    `README.md`)";
  - new: "the developer's change report — the `changed:` and `git:` lines
    (the script's header, E74, E75, the skill,
    `plugins/glab/commands/develop.md`, `README.md`)".
  Each of the searched phrases `Developer, before the contract`,
  `the external developer — Codex only`, `the developer's change report`
  and `workspace-write [workdir]` stays on one line of `AGENTS.md`, and the first three each on a line of its own.
  The exit codes keep their numbers and names; 12's widened meaning changes
  in the files that entry names where they describe it (the header, the
  skill, `glab:manager`, `README.md`). `ship.md` speaks of the reviewer only
  and stays.
- `plugins/glab/.claude-plugin/plugin.json`: `"version": "0.7.0"`.

**Revision 3 (review r1, `review-r1.md`, approved by the user 2026-10-18, `questions.md` *Review round 1*).**

- **T1, README L9:** "runs external agents — OpenCode Go read-only in a
  sandbox of its own, or Codex in its own sandbox, read-only except for a
  developer —".
- **T1, README L72:** "under Codex's own sandbox (read-only, or
  workspace-write for a developer)", identical to the skill's L66.
- **README L93-L94, the user's decision** (`questions.md`, revision 2): the
  sentence saying no Codex agent has run against a real model is corrected
  for the live probe L1 of 2026-10-18 (`30f2c80`: read-only, Codex's default
  model). Revision 2 had left it to the previous change; the user asked for
  it here.
- **`AGENTS.md` *One fact*:** the entries the script's revision 3 alters
  (the change report's lines, the refusals and their exit codes):
  the change-report entry adds E78, E80 and E82; a new entry, the
  developer's refusals — a state root inside the repository, or a `.git`
  other than the top's: 2 at start, 4 before a later turn (the script's
  header, E79, E81, the skill).

**Revision 4 (review r2, `review-r2.md`, approved by the user 2026-10-18 as the last minimal round, `questions.md` *Review round 2*).**

- **R4.8 (R2-5, R2-3, and the P5/P7 consistency).** The README paragraph
  after the Codex paragraph is the one P5 tells the skill's notice to carry,
  in the same words, so P7's revision-2 block above is superseded by this
  text, verbatim, as built (README L84-L102; the skill's notice carries the
  same words, identical after whitespace normalisation):

        A Codex developer changes files in your repository, and runs only
        when you name it for the developer. Its sandbox is Codex's
        `workspace-write [workdir]`: no network, and no write outside your
        repository, `/tmp` and `$TMPDIR` included.
        A change to .git is reported after each turn — a commit, a ref, the
        config, a hook, `info/`, the `core.hooksPath` directory, or a new `.git`
        below the top — and the manager stops on it; the script does not
        prevent it. A write to an ignored file is not reported, except in the
        `core.hooksPath` directory or in a file the git config includes. The agent
        can make a path ignored itself, with a `.gitignore` of its own: a new
        ignored entry is reported by name, but not what is written in it.

  After it, outside the mirrored note, a short README paragraph (L103-L108)
  gives the codes in the header's terms. The skill carries the same at
  L171-L181:

        After each developer turn the manager is shown one `changed:` line per
        path whose entry changed, with the code
        `??` untracked, `!!` ignored (by name only), ` D` tracked and missing,
        `--` a regular file of at most 16 MiB as the index has it (its hash and
        executable bit match its one stage-0 index entry) or a path no longer
        listed, and ` M` every other tracked path; a link or a larger file that
        changed is ` M`, whatever it holds.

  The phrase `a link or a larger file that` is on one line in each file.
  The other built wordings of R4.2-R4.7:
  - the prerequisites: skill L56-L59 and README L49-L52 name a `find` that
    takes `-files0-from` (GNU findutils 4.9 or later, or bfs) and a
    `realpath` that takes `-e`, and the exit 4;
  - the exit-2 cause: skill *What stops it before a turn* and README
    L60-L62;
  - the inspection: skill L278-L287 and `develop.md` L54.
- **R4.9 (R2-6).** The *One fact* refusal entry (2 at start, 4 before a
  later turn) also names `README.md` and `glab:manager` Rule 5
  (`plugins/glab/skills/manager/SKILL.md`). Built (`AGENTS.md` L241-L244):
  "a developer refused where the state root is inside the repository or the
  work tree holds another `.git`, 2 at start and 4 before a later turn (the
  script's header, E79, E81, the skill, `README.md`, `glab:manager` Rule
  5)". The change-report entry now reads E74, E75, E78-E84.

## After

1. The four gates and the plugin gates, pasted. Green: five `rc=0`,
   shellcheck `rc=0`, `PASS n/n` for `memory-sync.test.sh` as before, and
   `PASS 84/84` (revision 4); the plugin gates as `AGENTS.md` lists them, `glab` still
   `Skills (15)`, `Agents (5)`, `Hooks (1)  SessionStart`.
2. Searches, each pasted. Each one gives the other answer on today's tree
   (checked on `30f2c80` while writing revision 2: every "1 or more" below
   printed 0 there, and `never to change anything` printed 1), so its
   result tells a built tree from an unbuilt one. `-F` throughout, so no
   pattern character needs escaping.
   - `command grep -rn -F 'There is no external developer' plugins README.md` → no line;
   - `command grep -n -F 'Only the reviewer can be external' plugins/glab/skills/manager/SKILL.md` → no line;
   - `command grep -c -F 'workspace-write [workdir]' plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/skills/external-agents/SKILL.md README.md AGENTS.md` → 1 or more each (P1, P4, P5, P7);
   - `command grep -c -F -- '--role developer' plugins/glab/commands/develop.md` → 1 or more (P6);
   - `command grep -c -F '| an external developer |' plugins/glab/skills/manager/SKILL.md` → 1 (P6, the table row);
   - `command grep -c -F 'except the developer and the reviewer under Rule 5' plugins/glab/skills/manager/SKILL.md` → 1 (P6, Rule 6);
   - `command grep -c -x -F '## The developer role' plugins/glab/skills/external-agents/SKILL.md` → 1 (P5);
   - `command grep -c -F -e 'A Codex developer changes files in your repository' -e 'A change to .git is reported' -e 'The developer role has been tested against a stub' README.md` → 3 (P7);
   - `command grep -c -F -e 'the external developer — Codex only' -e "the developer's change report" -e 'Developer, before the contract' AGENTS.md` → 3 (P7);
   - `command grep -c -x -F '## Developer, before the contract' plugins/glab/skills/external-agents/profiles/default.md` → 1, and `command grep -c -F 'never to change anything' plugins/glab/skills/external-agents/profiles/default.md` → still 1 (P3);
   - `command grep -n '"version"' plugins/glab/.claude-plugin/plugin.json` → `0.7.0`.
2b. Revision 3's searches, each pasted. Each gives the other answer on the
   revision-2 build that `review-r1.md` reviewed (its X and T items quote
   the old text). Each phrase stays on one line of its file.
   - `command grep -c -F 'status --porcelain' plugins/glab/scripts/external-agent.sh` → 0 (R3.4);
   - `command grep -c -F -e '--stdin-paths' -e '--get core.hooksPath' plugins/glab/scripts/external-agent.sh` → 2 or more (R3.4);
   - `command grep -c -F 'read-only except for a developer' README.md` → 1 (T1, L9);
   - `command grep -c -F '(read-only, or workspace-write for a developer)' README.md plugins/glab/skills/external-agents/SKILL.md` → 1 each (T1);
   - `command grep -c -F 'in the model line for the reviewer or the developer' plugins/glab/skills/manager/SKILL.md plugins/glab/skills/external-agents/SKILL.md` → 1 or more each (T2);
   - revision 4 replaces the line before: `command grep -c -F -- 'git diff --no-ext-diff --no-textconv --ignore-submodules=all' plugins/glab/skills/external-agents/SKILL.md plugins/glab/commands/develop.md` → 0 each, and `command grep -c -F 'cat-file blob HEAD:' plugins/glab/skills/external-agents/SKILL.md plugins/glab/commands/develop.md` → 1 or more each (R4.7);
   - `command grep -c -F -e '-files0-from' plugins/glab/skills/external-agents/SKILL.md` → 1 or more (R4.2);
   - `command grep -c -F -e '--exclude-standard --directory' plugins/glab/scripts/external-agent.sh` → 1 or more (R4.3).
3. **Stage 4, offline measurements** (`/glab:integrate`, `integration.md`).
   `codex sandbox` on the host only, under the user's standing allowance;
   M5 as an offline run under `AGENTS.md`'s rule. Each run makes
   `X=$(mktemp -d "$TMPDIR/codex-offline.XXXXXX")` with `CODEX_HOME=$X/home`
   holding only the fake `auth.json` of
   `9108ac7:plan/feature-codex-agent/integration.md` (O1), `HOME=$X/uhome`,
   Codex's `TMPDIR=$X/tmp`, a throwaway repository `$X/r` with one commit
   (never the user's repository), and `CX=<home>/.local/bin/codex` set before
   `HOME` changes. The real `~/.codex` is never read, listed or written; no
   `exec` outside M5, no `login`, no model. Every listener is killed by its
   pid; `$X` is removed, and each run prints `X removed: yes`. The scripts
   go into `integration.md` verbatim, host values masked.

   The command for M1-M4, `WW` (revision 3: without `-C "$X/r"`, which
   `codex sandbox` 0.163.0 takes only with `-P`; every call with it exited
   2, `integration.md` *Round 1*; the `cd` already sets the workdir):
   `(cd "$X/r" && env -i PATH="$P0" HOME="$X/uhome" CODEX_HOME="$X/home" TMPDIR="$X/tmp" "$CX" sandbox -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=false' -c 'sandbox_workspace_write.exclude_tmpdir_env_var=true' -c 'sandbox_workspace_write.exclude_slash_tmp=true' -- <cmd>)`.

   | id | what | expected | discriminates because |
   |---|---|---|---|
   | M1a | `sh -c 'echo x >f'` and an edit of a tracked file, in `$X/r` | rc 0; `f` holds `x`; `git status` shows both | read-only gave `Read-only file system` here |
   | M1b | the same under `-c 'sandbox_mode="read-only"'` | non-zero; nothing changed | the control: the mode switch is what changed |
   | M2a | writes to `$X/outside/f`, `$X/uhome/f`, `$X/tmp/f` and `/tmp/<unique name>` | each non-zero; none exists after | — |
   | M2b | the `$X/tmp/f` and `/tmp/<unique name>` writes under `WW` without the two `exclude_*` keys | rc 0 (the file is removed afterwards) | shows 0.163.0 honours the keys, not ignores them |
   | M3 | in `$X/r`: append to `.git/config`; create `.git/hooks/pre-commit`; `git -c user.name=t -c user.email=t@t.invalid commit --allow-empty -qm t`; `git update-ref refs/heads/x HEAD`; `git add f` | **record each rc**, and the `dev_state` `git` digest and `git rev-parse HEAD` before and after | the question of U2/D4. Either result leaves the build as written: the README and skill say only that a change to `.git` is reported (P5, P7), which holds either way. The result goes into the spec at the record; a `.git` write that succeeds is told to the user before Stage 5 |
   | M4 | a TCP connect to a `python3 -I` listener on host `127.0.0.1`, port from the kernel; an AF_UNIX connect to a listener at `$X/sock/s` | both refused; the same connects outside the sandbox succeed, and the listeners count +1 there and +0 inside | the control makes a refusal mean the sandbox |
   | M5 | inside `bwrap --dev-bind / / --unshare-net --die-with-parent`, after `netns: lo routes=0` is printed: `external-agent.sh start --backend codex --role developer --cli "$CX" --brief <hello> --repo "$X/r" --timeout 300` | rc 7 at the network; `transcript.log`'s header says `sandbox: workspace-write [workdir]` and `approval: never`; stdout has `changed: none` and `git: unchanged` | rc 12 instead means 0.163.0 prints another string: record it; `PLAN WRONG` for D3 |

4. Not shown by any of these, written `UNVERIFIED` in `integration.md`:
   whether Codex itself (outside its command sandbox) changes a ref during a
   real turn, which would print `git: changed` every turn; how a real model
   does as a developer. Both need a live run, which only the user starts.

## Rollback

`git revert` of the change's commit returns 0.6.0. No stored format
changes: `agent.json` only gains the role value `developer`. Stop every
developer agent first; a 0.6.0 `send` to one would run it read-only and
check `read-only`, which is harmless. A tree a developer turn changed is the
user's to keep or revert (D8); rollback of the plugin does not touch it.

## Record

After the push (`glab:manager` Stage 8):

- `docs/specs/external-agents.md`: the developer role (D1-D8), the
  measurements M1-M5, the developer first message and `default.md`'s developer section; L34's "There is no
  external developer" replaced; closed:
  `[feature-codex-agent/plan.md not-in-plan-1]`,
  `[feature-opencode-worker/plan-r3.md not-in-plan-2]`; open: *Not in this
  plan* below, and step 4 of *After*.
- `docs/specs/workflow.md`: Rule 5's external developer and its record and
  handoff lines, Rule 6's two exceptions, `/glab:develop`'s external path.
- `docs/specs/marketplace.md`: the new and changed *One fact* entries, glab
  0.7.0, `PASS 84/84`.

## Not in this plan

- A scratch directory or writable cache for the developer's commands (F4).
- The script checking the developer's verdict line, as exit 8 does for the
  reviewer.
- Reporting writes to ignored files.
- An OpenCode developer.
- `check` proving that workspace-write starts, as it does for read-only.
- A live Codex developer run: only on the user's instruction.
- Splitting a develop stage across external developers, or an external and
  a Claude developer together.
- Closed in revision 3, by the user's decision (P7, R3): `README.md`
  L93-L94 still says no Codex agent "has run against a real
  model yet", which predates the live probe recorded in `30f2c80`
  (`plan/feature-codex-agent/probe-codex-l1.md`). That sentence is the
  previous change's record to correct, not this plan's; P7 adds its own
  sentence after it and leaves it as it is.

## Changes in revision 2

Stage 1b round 1/2 returned NOT BUILDABLE. What changed, and where:

- **Blocker 1, the default profile.** `codex_model_allowed` always sets
  `profile=default` (L484-L485), and `first_prompt` sends default.md's
  *Before the contract* to every role (L824), whose "never to change
  anything" (default.md L10-L11) a developer's task contradicts. Now:
  - D5 states it and chooses a section of the developer's own, not a
    sentence reworded for both roles;
  - P3 gives the new default.md section and its *Notes* bullet verbatim,
    and the `first_prompt` change;
  - E77 checks both directions;
  - the coverage table names default.md;
  - *One fact* names default.md in the first-message entry;
  - *After* searches its heading.
- **Blocker 2, searches.** *After* step 2 now has one search per P5-P7
  change: `--role developer` in develop.md, the Rule 5 table row, Rule 6's
  wording, `## The developer role`, the README's three new sentences, the
  three new AGENTS.md phrases, and default.md's heading and its unchanged
  sentence. Every one printed 0 on `30f2c80`, so it fails on an unbuilt
  tree. The README now carries `workspace-write [workdir]`, so the count
  over five files holds. P5-P7 give the searched text verbatim and say each
  phrase stays on one line.
- **Notes taken:**
  - the citations: `isolation=` at L1246, Rule 5 *Carry it* at L123, the
    README's Codex paragraph at L70-L81 and its tested sentence at L93-L94,
    the reviewer's table row at L139;
  - P1 rewrites the header's L2-L6 (verbatim) and the read-only bullet at
    L90-L99, rather than only adding a bullet;
  - P2's `dev_state` treats a missing HEAD, a detached HEAD, a missing
    config and a missing hooks directory as states;
  - exit 8 is dropped from D4 and P2, because it is reviewer-only (L1152);
  - E27's title is updated.
- **Also changed.**
  - M3 no longer turns a writable `.git` into `PLAN WRONG`: the README and
    skill now say only that a change to `.git` is reported, which is true
    either way.
  - The base line names `30f2c80`.
  - `findings.md` is not edited. Its F1 citations for the README
    (L71-L79) are off in the same way, and this plan's numbers replace them.

## Changes in revision 3

Written after review round 1/3 (`review-r1.md`: BLOCK 6 and BLOCK 6), for
the one fix round the user chose (`questions.md`, *Review round 1*), so that
Stage 3 can check the fixes against the plan. Every fix is marked
**Revision 3** at the step it belongs to; the revision-2 text is kept where
it still holds, and is marked where revision 3 replaces it.

- D4 no longer describes the snapshot as `git status --porcelain`.
- P1: R3.1 (X4, a state root inside the repository), R3.2 (X1/X2, a nested
  `.git` at start), R3.3 (X6/T6, the stale comments).
- P2: R3.4 (X1, X3, X5, T5 and both advisories): `ls-files` and a batched
  `hash-object --no-filters --stdin-paths` in place of `git status`; a size
  cap; a time bound; `core.hooksPath`, `info/` and the nested-`.git` list in
  the digest; the untracked mode; one line for an unreadable after-state.
- P3: the `default.md` L3-L7 intro, recorded.
- P4: the new cases for X1-X5, T3, T4, T5 and the mode advisory.
- P5-P7: the inspection command (X1), the skill's *Its network* (X6), T1's
  and T2's wordings, both Rule 6 and Rule 5 advisories, `develop.md` L2/L8,
  and the *One fact* entries the script changes alter.
- P7: the README L93-L94 correction, which the user asked for in this
  change (`questions.md`, revision 2); revision 2 had put it under *Not in
  this plan*.
- *After* §3: `WW` loses `-C "$X/r"` (`integration.md`, *Round 1*: exit 2
  without `-P`); §2b adds revision 3's searches.
- Names, counts and wordings are aligned with the developers' *Round 2
  (review r1)* sections of `result-p1-p4.md` and `result-p5-p7.md`: the
  helpers `dev_refuse`, `dev_snap` and `dev_git`; the constants
  `DEV_HASH_BYTES` (16 MiB) and `DEV_STATE_S` (300 s); the report codes;
  `changed: unreadable`; cases E78-E82; `PASS 82/82`; the inspection
  command; and the *One fact* entries.
- Two things the developers built beyond the review's text are recorded
  as plan text, so that conformance does not flag them:
  - the config digest (`git config --includes --list -z`);
  - the time limit taken from the turn's `--timeout`.
- Gap, not built and not in this plan's steps: `README.md` *Requirements*
  does not name the new `find -files0-from`/`-printf` and `realpath -e`
  needs. That is the manager's call (a follow-up, or one more README line).

## Changes in revision 4

Written after review round 2/3 (`review-r2.md`: BLOCK 2 and BLOCK 6), for
the last minimal fix round the user chose (`questions.md`, *Review round
2*). Review round 3 ends in SHIP, SHIP WITH SCOPE CUT or DO NOT PUBLISH.
Every fix is marked **Revision 4** at the step it changes.

- P1: R4.1, `dev_refuse` with the top at `/` (advisory).
- P2: R4.2 the `find` probe (R2-2); R4.3 the ignored-entries listing
  (R2-3); R4.4 the exact meaning of `--` (R2-5).
- P4: R4.5 the two T4 mutants (R2-4); R4.6 the stale test comment (R2-7);
  the new cases.
- P5/P6: R4.7 replaces revision 3's `git diff` inspection, which runs
  filters too (R2-1), with `cat-file blob HEAD:<path> | diff -u`; the
  prerequisites, the ignored-path wording, the `--` wording and the two
  advisories.
- P7: R4.8 makes the README paragraph the one P5 tells the skill to carry.
  Conformance found that P7 still showed revision 2's text. R4.9 adds the
  refusal entry's missing files (R2-6).
- *After* §2b: the inspection search flips to 0, and three searches are
  added.
- Aligned with the developers' *Round 3 (review r2)* sections: `need_find`
  and its message; the `!!` line; the exact `--` and ` M` wording; E83, E84
  and the E74/E75/E80 changes; `PASS 84/84`; the README paragraph and the
  codes paragraph, verbatim from the README; and the *One fact* text.
- Built beyond the review's text, and recorded so that conformance does not
  flag it:
  - the skill's prerequisites also name `realpath -e`, which the script
    already needed (R3.4);
  - the codes paragraph is a README paragraph of its own (L103-L108),
    outside the note that is mirrored in the skill.
