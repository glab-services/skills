# Result — feature-external-developer, P1-P4

Slice: P1, P2, P3 and P4 of `plan.md` revision 2. Files:
`plugins/glab/scripts/external-agent.sh`, `tests/external-agent.test.sh`,
and `plugins/glab/skills/external-agents/profiles/default.md` (the P3
section). Read first: `AGENTS.md` (from disk), `plan.md`, `findings.md`, `questions.md`.
No Codex command was run, and `~/.codex` was not read. Nothing was staged or committed.

## Stages

- **P1 done** (`plugins/glab/scripts/external-agent.sh`)
  - Header L2-L8: the verbatim opening of P1, then re-wrapped so that "The glab:external-agents skill is the caller's manual, and tests/external-agent.test.sh pins every behaviour here." is kept (Stage 1b suggestion).
  - Usage L11-L16: `[--role general|reviewer|developer]`, and "--role developer is taken by codex only" in the note under it.
  - Exit list L43-L44: under `12 NOT READ-ONLY`, "(12, for a developer: a sandbox other than the workspace-write one it asked for)".
  - Codex bullet L100-L114: rewritten to hold for both modes. Read-only keeps its measured facts. The developer's sandbox is workspace-write, with the network off and `/tmp` and `$TMPDIR` excluded, and its network and sockets are cited as `[feature-external-developer/plan.md M4]`. The header check accepts `read-only`, or `workspace-write [workdir]` for a developer.
  - Change-report bullet L115-L122 (D4), naming what it does not see: a write to an ignored file, and a change Codex itself makes outside its command sandbox.
  - `cmd_start` L1408: `general|reviewer|developer`, with the new message. L1416: the OpenCode refusal, after `isolation=` and before `mkdir`.
  - `codex_argv` L590-L603: the four D2 `-c` arguments, in plan order, in place of `sandbox_mode="read-only"` for `role=developer`. Every other argument is byte for byte as before (E51 still passes). The comment says why `/tmp` and `$TMPDIR` are excluded (F3), and that the header check, not these flags, decides.
  - `codex_verify` L692-L700: `want` is `workspace-write [workdir]` for a developer and `read-only` otherwise. The die message is the plan's. The comment gives the F2 source URL, and says that the match is exact, so an extra entry or a ` (network access enabled)` suffix fails it.
- **P2 done** (`plugins/glab/scripts/external-agent.sh`)
  - Stdout block L26-L31: the `changed:` and `git:` lines between `agent:` and `reply:`, marked "developer only".
  - `dev_state` L327-L343, next to `hostgit`. It records the status entries (`XY TAB kind TAB %q path`, sorted under the script's `LC_ALL=C`), then the `git TAB sha256` line. It uses the common dir from `rev-parse --path-format=absolute --git-common-dir`.
  - `dev_git` L348-L360: the digest input. `head: none`, `symref: none`, `config: none`, and an absent hooks directory are states. Any other non-zero exit fails.
  - `dev_report` L365-L376: the per-path compare, sorted by path, `--` for a path no longer listed, `changed: none`, then `git: unchanged` or `git: changed`. All of it goes through `clean`.
  - `run_host` L1216-L1219: `state.before`, or `die 4 UNAVAILABLE "cannot read the state of $repo"`. L1268-L1272: `state.after` after `sweep_agent` and the filter wait, or `git<TAB>unreadable`.
  - `header` L1274-L1281: `dev_report` when the role is developer and `state.after` exists.
- **P3 done**
  - `first_prompt` L924-L1017. A developer gets default.md's `## Developer, before the contract` (L930) and no family section. It gets the developer host text, verbatim, with `@TOP@` replaced. Then `# Your role contract` with `body agents/developer.md` (L1001, shared with the reviewer branch), both skills, `# Your dispatch`, the brief, `# Before you answer` and *After the contract*. `developer_tail` comes last (L1016).
  - `developer_tail` L1031-L1051, verbatim.
  - `cmd_send` L1507: appends `developer_tail` for a developer.
  - `profiles/default.md`:
    - L3-L7: the intro amended for the third, developer-only section (Stage 1b suggestion).
    - L30-L41: the new section, verbatim.
    - L51-L55: the *Notes* bullet, verbatim.
    - *Before the contract* is unchanged.
- **P4 done** (`tests/external-agent.test.sh`)
  - Stub argv parse L211-L227, and the sandbox line computed from the argv as F2 describes, L240-L250.
  - Scenarios: `ww-tmp`, `ww-net`, `ww-full`, `ww-plain` and `ro-forced` at L255-L260 and L263; `dev-edit`, `dev-commit`, `dev-hook` and `dev-config` at L264-L286.
  - E27 L647 (`--role writer`, the new message) and its title, L654.
  - New cases, before E36: `drepo` L1153; E72 L1155-L1174; E73 L1176-L1195; E74 L1197-L1225; E75 L1227-L1241; E76 L1243-L1245; E77 L1247-L1297.
  - Each developer case runs on a throwaway repository of its own under `$W`, through `CR`.

## Blocked

Nothing.

## Unplanned changes

These are mechanical consequences and interpretations, each one forced by a named step:

- `codex_argv`'s comment "runs read-only" now says "(a developer's: workspace-write)" (P1; `glab:comments`, the subject changed).
- The `first_prompt` host branch went from `while read … <<'EOF'` to `{ if developer; then cat <<EOF …; else cat <<EOF …; fi; } | while read …`. Two texts share the one `@TOP@` replacement (P3). The read-only text is byte for byte as before (E61 passes).
- The reviewer and developer contract branches share `body "$plugin/agents/$1.md"` (P3).
- `dev_git` is a helper of `dev_state` that the plan does not name. It holds the digest input that P2's second and third sub-bullets describe, so that the expected exits can be told from failures.
- Interpretation (P2): in `<common dir>/hooks`, a regular file gets `sha256sum`. Any other entry (symlink, FIFO, directory) is listed by type, path and link target, and never opened. The plan says "sha256sum of each file"; following a symlinked hook to `/dev/zero` would hang the report, the same hazard F3 rules out for status entries.
- Interpretation (P2, literal): when `dev_state` fails after the turn, the after-file is only `git<TAB>unreadable`. That makes `git: changed`, as the plan says, and it also prints `changed: --` for every path that was listed before. No case covers it.
- The test comment at L710, "E37-E71 were added after E36", now says E37-E77 (P4; `glab:comments`).
- E74 and E75 have known-positive checks: each one first shows that the stub really made its change (the link, the deletion, the newline name, the commit count, the hook file, the config key).
- E73's 12 cases also check the exact `where '<wanted>' and 'never' were asked` text: `workspace-write [workdir]` for a developer, `read-only` for the general `ww-plain` case.

## Tests

Six cases added (E72-E77) and one changed (E27). `PASS 77/77`; the baseline before any edit was `PASS 71/71`.

Coverage, as a list (`AGENTS.md` *Tests*):

| step | cases |
|---|---|
| P1 role parsing and OpenCode refusal | E27 (`writer` refused with the new message), E76 (OpenCode developer is 2, `agents` 0, stdout empty), E72 (a Codex developer is accepted) |
| P1 argv | E72 (start and send), E51 and E52 (other roles unchanged) |
| P1 header check | E73 (developer accepted; `ww-tmp`, `ww-net`, `ww-full`, `ro-forced` and `ro-appr` are 12; a general agent with `ww-plain` is 12), E54 (read-only refusals unchanged) |
| P2 snapshot and report | E74 (the six paths; `%q`; sorted; a further edit to an already-modified file; the untouched untracked file not listed; a link to `/dev/zero` not opened; `changed: none` on the next turn; a general agent prints no report), E75 (commit, hook, config: `git: changed`, exit 0, reply shown), E73 (the report on the exit-12 path) |
| P3 first message, `default.md` section, send tail | E77 (in order; the negatives; the send ends with the tail; a general agent still gets *Before the contract*), E61 (general host text unchanged), E20 (reviewer unchanged) |

Mutation runs, each on a throwaway copy under `/data/tmp/claude/feature-external-developer-dev/`, removed afterwards:

- mut1, the `## Developer, before the contract` section removed from default.md: `NOT OK E77` ("missing, or out of order: [You are an external developer in the glab workflow. A manager has started]"), `FAIL 1/77`.
- mut2, `codex_verify` also accepting `read-only` for a developer: `NOT OK E73` ("E73 ro-forced: rc=0"), `FAIL 1/77`.

Not covered by any case:

- The report on exits 6 and 7. `header` is the one place it is printed, and E73 shows it on 12 through that same call. The plan accepts this gap.
- `dev_state` failing before the turn (`die 4`). The stub cannot make a repository git cannot read without breaking `--repo`. The plan accepts this gap.
- `dev_state` failing after the turn (`git<TAB>unreadable`). The plan names no case for it. Accepted for the time budget.
- `dev_git`'s fixed words. They are not in the plan's case list. I exercised them once by hand: I extracted `hostgit`, `dev_state` and `dev_git` from the script and ran them on throwaway repositories under `$TMPDIR`, which were then removed:

      == empty: rc=0 lines=2 last=git	acca6b34
      == det: rc=0 lines=1 last=git	14eb7404
      == bare: rc=0 lines=1 last=git	840a8d92
      == no-commit digest input: head: none
      == detached digest input: symref: none
      == not a repo: rc=1
      X removed: yes

  "empty" is a repository with no commit, "det" a detached HEAD, "bare" one with its hooks directory moved away. `config: none` was not exercised.
- The real sandbox's behaviour belongs to Stage 4, M1-M5.

## Gates

`export TMPDIR=/data/tmp/claude`, then the four gates of `AGENTS.md`, run as one block (block rc=0):

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    ...
    PASS 35/35
    ...
    ok E72 a Codex developer's turns get workspace-write with network off and /tmp and $TMPDIR excluded in place of read-only, everything else as in E51, on start and on send; list shows role=developer
    ok E73 a developer is accepted with workspace-write [workdir] and never only: ...
    ok E74 a developer's turn lists each path whose status or content changed, ...
    ok E75 a developer's commit, new hook or new config key prints git: changed, with exit 0 and the reply
    ok E76 an OpenCode developer is refused (2) before anything is created
    ok E77 a developer's first message holds the default profile's developer section, ...
    ok E36 after every case: ...
    PASS 77/77

Every test line was `ok`: no line other than `ok …`, `PASS …` or `… rc=0` was printed.

Flake, recorded: the first post-edit run printed `NOT OK E47 … E47 kimi: rc=9` (`NO ISOLATED NETWORK`), `FAIL 1/77`. E47 is an OpenCode reviewer case, and the diff touches none of the slirp4netns or blackhole code. Searching the diff for `slirp|BLACKHOLES|wire_network|run_sandboxed|die 9` printed nothing, rc=1. The four runs after it passed E47: the rerun and the gate run were green, and each mutation run failed only its target case.

*After* searches for these files:

    $ command grep -c -F 'workspace-write [workdir]' plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh
    plugins/glab/scripts/external-agent.sh:3
    tests/external-agent.test.sh:5
    $ command grep -c -x -F '## Developer, before the contract' plugins/glab/skills/external-agents/profiles/default.md
    1
    $ command grep -c -F 'never to change anything' plugins/glab/skills/external-agents/profiles/default.md
    1
    $ command grep -n -F 'There is no external developer' <the three files>
    (no line) rc=1

The plugin gates were not run here: their lines are P5-P7's, or cover the whole plugin, which another developer is changing at the same time.

## Blast radius

- Every Codex turn: `codex_argv`, `codex_verify` and `header` each read `meta role` once more. For a general agent or a reviewer, the argv, the accepted header and the stdout are unchanged (E50-E71).
- Every OpenCode turn: `header` reads `meta role` once. Nothing else changes, and `--role developer` is refused before anything is created.
- A Codex developer's turn runs `git status` and one `hash-object` per listed path on the real repository, twice per turn, under `hostgit`.
- `first_prompt`: the general and reviewer texts are byte for byte as before (E20, E61). default.md gains a section that no other role receives (E77's general check, E61).
- The die message of exit 12 is longer. Its prefix `NOT READ-ONLY: codex reported sandbox`, which E54 matches, is unchanged.

## Follow-ups

They are recorded here, because this dispatch allows no other file under `plan/`. None of them was built.

- `dev_state`'s `git status` runs with the repository's own config and `.gitattributes`. A clean filter there, such as git-lfs, can run on the host for racily clean entries. `hostgit` turns off fsmonitor and hooks, but not filters. This is not in the plan.
- The hooks digest hashes content and type, not mode. Making an existing non-executable `.git/hooks/<name>` executable is not reported as `git: changed`.
- One `hash-object` process per listed path: a tree with many untracked files makes each developer turn slower. `--stdin-paths` would batch it.
- When `state.after` is unreadable, every path listed before is reported as `changed: --` (see *Unplanned changes*).
- E47 failed once with exit 9 in an unchanged OpenCode sandbox path (see *Gates*).

## Not done

- P5-P7: another developer's slice. Not touched.
- `docs/specs/`: not touched. They showed as modified at session start, and `git status` no longer lists them; that change is not mine.
- Stage 4, M1-M5, and every claim that rests on them: whether 0.163.0 prints exactly `workspace-write [workdir]`, whether it honours the `exclude_*` keys, and what a `.git` write does under workspace-write. UNVERIFIED: the header string — inferred from Codex's source (F2), only the stub prints it here.

## Round 2 (review r1)

Scope: X1-X6 with their two advisories, T3, T4, T5 (the `dev_git` side) and T6, from `review-r1.md`. They are approved as revision 3 (`questions.md`, *Review round 1*). I read both files from disk. The file boundary is unchanged.

Line numbers below are of the working tree after round 2. Round 1's line numbers above no longer hold.

### Items

- **X1 done.** `dev_state` (`external-agent.sh:362`) no longer runs `git status`. It reads:
  - the index, with `ls-files -s -z`;
  - the untracked files that are not ignored, with `ls-files -o -z --exclude-standard`;
  - each listed path's type, mode, size, times, inode and link target, in one `find -files0-from - -maxdepth 0 -printf` that opens nothing;
  - the hash of each regular file up to the cap, in one `hash-object --no-filters --stdin-paths` call. Each path is C-quoted first, which `--stdin-paths` unquotes, so a newline in a name is safe.

  No filter, fsmonitor or hook can run. Line format: `<%q path> TAB <index entry or -> TAB <kind> TAB <code>`. The code is `??`, ` D`, ` M` or `--`. A refusal at start (`dev_refuse`, `:483`, called at `:1551`) covers a submodule git dir or nested repository in the work tree.
- **X2 done.**
  - `dev_refuse` refuses a developer when there is any `.git`, directory or gitfile, below the top other than `<top>/.git`. It does this at `start` with exit 2 USAGE, before `mkdir`, and before each developer turn with exit 4 UNAVAILABLE (`:1351`).
  - `dev_git` (`:427`) digests every nested `.git`, so one made in a turn is `git: changed`.
- **X3 done.**
  - `dev_git` digests the `core.hooksPath` directory. It reads the path with plain `git config --includes --type=path` (not `hostgit`, whose `-c` sets it) and takes a relative path from the top.
  - It also digests `git config --includes --list -z`, the config as git reads it. A setting in an ignored file that the config includes is a change too. *Unplanned:* this goes beyond "check `core.hooksPath`", and it is how that value is read safely. It also catches a `core.fsmonitor` or filter planted the same way.
- **X4 done.** `dev_refuse` refuses when `realpath -e "$root"` is the top or below it: 2 at start, 4 before a later turn.
- **X5 done.**
  - `dev_snap` (`:460`) runs `dev_state` as `setsid timeout --kill-after=5 <limit> bash -c`, with the functions exported only in that subshell and the agent's lock fd closed. Its group carries the agent's marker, and the group is killed when `dev_snap` ends. `cleanup` (`:237`) also kills it, so a stop or a signal ends it. A SIGKILLed script leaves it for the sweep at stop or at the next send.
  - The limit is the turn's `--timeout`, and at most `DEV_STATE_S=300` (`:206`). Using the turn's limit is my choice: it makes the bound testable.
  - Above `DEV_HASH_BYTES=16 MiB` (`:203`), a file's kind is `big <mode> <size> <mtime> <ctime> <inode>`.
  - Hashing is one batch per snapshot.
- **X6 and T6 done.**
  - Header `:109-118`: the developer's sandbox facts are cited as measured, with `[feature-external-developer/integration.md M2, M3, M4]`.
  - `codex_verify` comment `:815-823`: the string is cited as printed in `[…integration.md M5]`. The source URL and F2 are kept as where it was first inferred.
  - Stdout block `:26-36` and the change-report bullet `:124-136`: rewritten to describe the new report.
- **Advisories done.**
  - Every file's mode is in its kind, untracked files included: a `chmod +x` is listed.
  - An unreadable after-state prints one `changed: unreadable` line, then `git: changed` (`dev_report`, `:496`).
- **T3 done.** E74: an untracked link retargeted in the turn is `changed: ?? zl2`.
- **T4 done.**
  - E74: `-- r.txt` (a modified file put back as committed), and `?? d/f` (a new directory).
  - E75: `dev-switch` (a branch switch) is `git: changed`.
- **T5 done.** `dev_git` digests `<common dir>/info`. E75's `dev-info` case covers it.

### Tests

| case | what | fails without (mutation) |
|---|---|---|
| E78 | X1: a repository with a clean filter, `required`, and an fsmonitor set; the turn touches a tracked file. The report runs neither, and the touch is no change. Known positive: a plain `git status` there does run it | X1: `hostgit status` added to `dev_state` |
| E79 | X2: a nested repo, and a gitfile, are refused 2 with nothing created; `git init nest` in a turn is `git: changed`; the next send is refused 4 | X2: both `-name .git` searches disabled |
| E80 | X3: a new hook in an ignored `core.hooksPath` dir, and a setting in an ignored included file, are each `git: changed` | X3: the hooksPath digest removed |
| E81 | X4: TMPDIR inside the repo is refused 2, with nothing created. With TMPDIR a link, re-pointed after the state is moved into the repo, a send is refused 4; stop still works | X4: the state-root check disabled |
| E82 | X5: a stand-in `git` that hangs once the turn makes its flag gives `changed: unreadable` and `git: changed` within 20 s (limit 3 s) and leaves no process. A sparse 64 GiB file is `changed: ?? big`, not read | X5a: `timeout` removed; X5b: the cap raised to 1 PB |
| E74 | T3, T4, mode | T3: the link target dropped from the kind |
| E75 | T4 (switch), T5 (info) | T5: the `info/` digest removed |

Mutation runs. Each was on a throwaway copy under `/data/tmp/claude/fed-r2/`, removed after it ran. The script that ran them printed:

    == X1: rc=1 wall=63s
    NOT OK E78 a developer's change report runs none of the repository's filters or fsmonitor, where git status would, and a touch alone is no change
    FAIL 1/82
    == X2: rc=1 wall=65s
    NOT OK E79 a developer is refused (2) where the work tree holds another .git, a directory or a gitfile, and nothing is created; one made in a turn is git: changed, and the next send is refused (4)
    FAIL 1/82
    == X3: rc=1 wall=64s
    NOT OK E80 a new hook in an ignored core.hooksPath directory, and a setting in an ignored file the config includes, are git: changed
    FAIL 1/82
    == X4: rc=1 wall=65s
    NOT OK E81 a developer is refused where the state root is inside the repository: at start (2), with nothing created, and before a later turn (4)
    FAIL 1/82
    == X5a: rc=1 wall=92s
    NOT OK E82 a change report past its time limit is changed: unreadable and git: changed, within the limit, and leaves no process; ...
    FAIL 1/82
    == X5b: rc=1 wall=70s
    NOT OK E82 a change report past its time limit ...
    FAIL 1/82
    == T3: rc=1 wall=64s
    NOT OK E74 a developer's turn lists each path whose index entry, type, mode or content changed, ...
    FAIL 1/82
    == T5: rc=1 wall=66s
       E75 dev-info: k1=x rc=0 err=[]
    NOT OK E75 a developer's commit, new hook, new config key, branch switch or info/exclude line prints git: changed, with exit 0 and the reply
    FAIL 1/82

Each mutant's diff was printed before its run. Each is the single change named in the table (X2 changes two lines).

Uncovered, with the reason:

- The report on exits 6 and 7, as before (accepted by the plan).
- `dev_snap` failing before the turn (`die 4`). A failing before-state needs the same stand-in as E82, armed before the turn. Not added, for the time budget.
- `dev_refuse`'s "cannot resolve" and "cannot search … within 300 s" branches. Reaching them needs a root or top that disappears mid-call, or a 300 s tree walk.
- `config list: none`: the stub cannot make `git config --list` fail in a valid repository.

### Gates

`export TMPDIR=/data/tmp/claude`, the four gates of `AGENTS.md` as one block: block rc=0, **wall 86 s**.

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    PASS 35/35
    ok E72 … ok E82 (each ok)
    PASS 82/82
    lines other than ok/PASS/rc=0: 0

The first run after the round-2 edits also passed, `PASS 82/82` (64 s, test only). The test alone now takes about 64 s; it took about 57 s in round 1.

Searches:

- `workspace-write [workdir]`: `external-agent.sh:3`, `external-agent.test.sh:5`.
- `## Developer, before the contract` in default.md: 1.
- `never to change anything`: 1.
- `git status` calls between `dev_state` and `dev_report`: none (grep rc=1).

### Requirements this adds

- `find` with `-files0-from` and `-printf`: GNU findutils 4.9 or later, or bfs. This host's `find` is bfs 4.1.1.
- `realpath -e` and `setsid`. `setsid` is already required.

### Doc text these changes make false (for the docs developer)

- Anything that says the `changed:` code is "XY as git status prints it". The code is now `??` untracked, ` D` tracked and missing, ` M` tracked and not as the index has it, `--` as the index has it or no longer listed.
- Anything that says the report uses, or is "from", `git status`. The developer tail (`external-agent.sh`, "lists every path you changed, from git") is still true and is unchanged.
- The new output `changed: unreadable` (with `git: changed`). It is printed when the report could not be read within the turn's `--timeout`, 300 s at most.
- New refusals of a developer: exit 2 at start, 4 before a later turn. They happen when the state root under `TMPDIR` is in the repository, or when the work tree holds a `.git` other than the top's (a nested repository or a submodule's git dir). The skill's *Start* and exit tables, the manager's D8 handling, and README need them.
- What `git: changed` covers. It now includes the config as git reads it, includes too, plus `info/`, the `core.hooksPath` directory, and any new nested `.git`. "A write to an ignored file is not reported" is now true except for the `core.hooksPath` directory and included config files (both are in `git:`).
- Files above 16 MiB are compared by size, times and inode, not content.
- The *One fact* entry for the change report names E74 and E75. E78-E82 now pin it too, and E79 and E81 pin the developer refusals.

### Follow-ups (not built)

- A tracked symlink is always code ` M` when its line changes: its target is not hashed against the index.
- A tracked file above 16 MiB is ` M` whenever its metadata changes, even if its content is unchanged.
- The before and after snapshots each hash every tracked file up to 16 MiB, so a very large tree can reach the time limit. A before-state that cannot be read in time fails the turn with exit 4.
- Round 1's follow-ups on repository filters in `git status` and on hook modes are closed by X1 and by the new metadata digest.

## Round 3 (review r2)

Scope: R2-2, R2-3, R2-4, the header part of R2-5, R2-7, and the `/` advisory, from `review-r2.md`, which I read from disk. The file boundary is unchanged, and nothing beyond the listed items was added. No background process or wait loop of mine is left running.

### Items

- **R2-2 done.** `need_find` (`external-agent.sh:494`) probes with `printf '.\0' | find -files0-from - -maxdepth 0 -printf x`, and exits 4 UNAVAILABLE when the answer is not `x`. It runs:
  - at a developer `start`, before anything is created (`:1575`);
  - in `codex_check`, after the tools loop (`:882`). It prints nothing when it passes, so the output of `check` is unchanged (E59).
- **R2-3 done.** `dev_state` lists the ignored entries, by name only, with `ls-files -z -o -i --exclude-standard --directory` (`:381`). Each is one line, `<%q path> TAB - TAB ignored TAB !!` (`:421`). A new or removed ignored name is reported with code `!!`; a write inside an ignored file or directory is not.
- **R2-4 done, both tested.**
  - `dev-edit` now deletes the pre-existing untracked `u.txt`, and E74 expects `changed: -- u.txt`. E74 keeps an untouched untracked file, `v.txt`, which must not be listed.
  - `dev-switch` checks out a branch that already exists at the same commit (the test makes it first, `test:1257`). Only `symbolic-ref HEAD` changes.
- **R2-5 (header) done.** Stdout block `:26-37`. `--` is "a tracked regular file of at most 16 MiB whose hash and executable bit match its one stage-0 index entry, or a path no longer listed". ` M` is "every other tracked path, each tracked symlink and each tracked file above 16 MiB included, whatever it holds". `!!` is ignored. The `dev_state` comment and the change-report bullet say the same.
- **R2-7 done.** `test:1170-1172`: the comment no longer says the report runs `git status`.
- **Advisory done.** `dev_refuse` matches with `"${t%/}"/*` (`:508`), so a top of `/` holds every root.

### Tests

- **E83 (new):** a stand-in `find` that rejects `-files0-from` makes a developer `start` exit 4, with no agent created, and makes `check` exit 4.
- **E84 (new):** a `pkg/zz/.gitignore` of `*`, written in the turn with a file beside it, gives exactly `!! pkg/`, `!! pkg/zz/`, `!! pkg/zz/.gitignore`, `!! pkg/zz/new.txt`, then `git: unchanged`. Known positive: `ls-files -o --exclude-standard` lists nothing there.
- **E74:** expects `-- u.txt` (R2-4, gone).
- **E75:** `dev-switch` switches to an existing branch (R2-4, nosymref).
- **E80:** `dev-include` now also prints `changed: !! .inc`, because the included file is a new ignored name.

Mutation runs, each on a throwaway copy under `/data/tmp/claude/fed-r3b/`, removed after it ran. Each mutant's diff was printed before its run:

    == probe: rc=1 wall=66s
    NOT OK E83 a find without -files0-from is unavailable (4) for a developer's start, before anything is created, and for check
    FAIL 1/84
    == ignored: rc=1 wall=65s
    NOT OK E80 a new hook in an ignored core.hooksPath directory, and a setting in an ignored file the config includes, are git: changed; the new ignored file is listed by name
    NOT OK E84 files a .gitignore written in the turn hides are listed as ignored (!!), not changed: none
    FAIL 2/84
    == gone: rc=1 wall=64s
    NOT OK E74 a developer's turn lists each path whose index entry, type, mode or content changed, ...
    FAIL 1/84
    == nosymref: rc=1 wall=64s
       E75 dev-switch: k1=other rc=0 err=[]
    NOT OK E75 a developer's commit, new hook, new config key, switch to an existing branch at the same commit, or info/exclude line prints git: changed, with exit 0 and the reply
    FAIL 1/84

The mutants were: `probe`, `need_find`'s test replaced by `true`; `ignored`, the ignored lines not printed; `gone`, the "no longer listed" pass of `dev_report` removed; `nosymref`, the `symbolic-ref` lines removed from `dev_git`.

Uncovered: the `${t%/}` advisory. Testing it needs a repository whose top is `/`.

### Gates

`export TMPDIR=/data/tmp/claude`, the four gates of `AGENTS.md` as one block: block rc=0, **wall 86 s**.

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    PASS 35/35
    PASS 84/84
    lines other than ok/PASS/rc=0: 0

The first run after the edits was also `PASS 84/84` (65 s, test only).

### Doc text these changes make false (for the docs developer)

- Any list of the `changed:` codes without `!!`, the ignored-name code. Any text saying ignored files are never in the report: a new or removed ignored name is now listed, by name only.
- Any wording of `--` as "as the index has it": the exact wording is under R2-5 above.
- `check` and a developer `start` can now exit 4 with "find does not take -files0-from (findutils 4.9 or later, or bfs); see the README's Requirements". README's *Requirements* needs that line, and the skill's Codex prerequisites need it (R2-2's docs side).
- The *One fact* entry for the change report: E83 and E84 now pin it too.

## Scope cut (review r3)

Applied from `questions.md` *Review round 3*. Removed: the `need_find` call in `codex_check` and its comment, so `check` no longer probes `find`. The call on a developer `start` stays (`external-agent.sh:1575`). E83 no longer has its `check` half. The script header never said `check` probes `find`, so the header did not change; `need_find`'s comment (`:489-494`) now says it runs at a developer's start only, and why.

Mutation, with the probe removed from a developer `start`: `NOT OK E83 … FAIL 1/84`.

Gates: B-block rc=0, wall 86 s; five `rc=0`, shellcheck `rc=0`, `PASS 35/35`, `PASS 84/84`, every line `ok`.

Doc text this makes false: any line saying `check` exits 4 on a `find` without `-files0-from`. That is README L51 and SKILL L58, which the docs developer owns.
