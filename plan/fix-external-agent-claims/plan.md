tier: full — step S4 changes how the OpenCode key is redacted, and `glab:manager` puts code that handles secrets at full tier

Revision 3 (2026-10-19), for review round 2 (`review-r2.md`), the last fix
round the user approved. Turns 1-4 were built and stay as written. Added:
turn 5, S6.1-S6.7 — R2-1 (the real size bound of `transcript.jsonl`, 10
times the cap, 20 when `jq` fails, in the script header, the `OUT_BYTES`
comment and the skill; F6 folded in, no new logic), R2-2 (the depth-limit
comment), R2-3 (E86 runs a `jq` wrapper that fails only `opencode_raw`'s
call, so mutant `!= "k"` now fails; the coverage acceptance and F4 closed),
and the `leak-split` guard of the advisory; the turn-5 searches. After turn
5, turn 1's search for `less than twice as long` counts 0 in both files, by
design. The test count stays 86.

Revision 2 (2026-10-19), for review round 1 (`review-r1.md`). Revision 1's
three turns were built exactly (conformance: byte-identical) and stay as
written; revision 1's S4.1 comment reads "K for a K" because the escape
`\u004b` was decoded while the plan was being written (T1). Added: turn 4,
S5.1-S5.9 — C1 (a line that is not exactly one JSON value and holds a
backslash is redacted; the comment fixed), C2 (E86 drives a split event,
two events on one line and an object key, and checks the whole file as a
stream), T1-T4; the turn-4 searches; *Coverage* for S5; the deferred
advisories as F5-F9. The test count stays 86.

# fix-external-agent-claims: plan

Make `glab:external-agents` say exactly what `external-agent.sh` does, in
every file that states the same fact, and close three small code gaps.
Source: `claims.md` (13 claims, verified at `363c38d`); evidence and the
call-site audit: `findings.md`. Target: `glab` 0.7.0 → 0.7.1. Base: `363c38d`.

## Before, processing, after

- **Before** (`363c38d`): ten statements in the skill, `README.md` and the
  script's comments say more or other than the code does (claims 1, 2, 4,
  5, 6, 7, 8, 9, 11, 12). `transcript.jsonl` keeps a key the model wrote
  JSON-escaped (claim 10). A Codex turn whose header names a wrong sandbox
  is exit 6 or 7, not 12, when it also timed out or flooded (claim 13). A
  comment-only change to an included config file is not reported, and the
  skill says it is (claim 3).
- **Processing**: three Codex developer turns (S1-S2, S3, S4), each followed
  by the manager's gates. Nothing else changes in between.
- **After**: every statement matches the code; `transcript.jsonl` holds no
  key once decoded; the sandbox check comes before the cap and timeout;
  claim 3 is documented exactly, with the wider gap as follow-up F1; the
  test has 86 cases, all `ok`; `glab` is 0.7.1.

## Decisions

- D1 — Claim 10: an event of `transcript.jsonl` that holds the key once
  decoded is written as the one event `{"type":"redacted"}`; every other line
  is written byte for byte. Not re-encoded, because `jq`'s encoding grows
  lines (DEL to `\u007f`, six bytes for one; `findings.md`) and would break
  the OUT_BYTES bound on the disk; not literal matching of escaped forms,
  because those are unbounded. A failure of `jq` writes every line of that
  turn as `{"type":"redacted"}`: it hides the turn, it does not leak it. An
  object, not a string, so a reader using `.type` keeps working.
- D2 — Claim 13: the `verify` call moves to the top of `finish_turn`, before
  the cap and timeout checks. One place, not a second call in each branch.
- D3 — Claim 3: documented, not coded. A digest of the active included
  files' bytes adds only comments and layout, which change nothing git does,
  and still misses the case that does (F1). The skill, the README and the
  script say exactly what is and is not seen.
- D4 — One commit for the whole change: every step touches `plugins/glab/`,
  and *Rules* puts the version bump in the same commit as the change; two
  commits would need two versions.
- The manager records the external developer's `- model:` line itself, from
  the user's words (`glab:manager` Rule 5). This plan carries none: a model
  line written by a planner is ignored.

## Who builds it, and the turns

The Codex external developer: `external-agent.sh start --backend codex
--role developer`, then `send` to the same agent for turns 2 and 3, each
only after the manager's checks on the previous turn are green with exit 0
and `git: unchanged` (a new agent per turn also works: each turn's brief
names its steps). Each brief names the slug `fix-external-agent-claims`, the
steps of that turn, and says: apply each edit exactly as this plan gives it;
do not run the test gate (it needs bwrap, slirp4netns and a writable
`$TMPDIR`, none of which Codex's sandbox gives) — write `not run here:`.

| turn | call | steps | files |
|---|---|---|---|
| 1 | `start` | S1, S2.1-S2.22 | `plugins/glab/.claude-plugin/plugin.json`, `plugins/glab/skills/external-agents/SKILL.md`, `README.md`, `plugins/glab/scripts/external-agent.sh` (comments only) |
| 2 | `send` | S3.1-S3.8 | `plugins/glab/scripts/external-agent.sh`, `plugins/glab/skills/external-agents/SKILL.md`, `tests/external-agent.test.sh` |
| 3 | `send` | S4.1-S4.8 | the same three |
| 4 | `send` | S5.1-S5.9 | `plugins/glab/scripts/external-agent.sh`, `README.md`, `tests/external-agent.test.sh` |
| 5 | `send` (a new agent) | S6.1-S6.7 | `plugins/glab/scripts/external-agent.sh`, `plugins/glab/skills/external-agents/SKILL.md`, `tests/external-agent.test.sh` |

Nothing in `plan/` is edited by the developer except `follow-ups.md`, if it
has one; it writes no `result.md` (its tail says so).

## How to apply an edit

Every edit below is an **Old** block and a **New** block, in that order,
under a heading that names the file. Replace the Old text with the New
text, exactly: same characters, same indentation, same line breaks.
`external-agent.sh` and `README.md` indent with spaces;
`tests/external-agent.test.sh` indents with **tabs** — each continuation
line beginning `&&` and each stub-scenario line starts with one tab
character. Each Old block occurs exactly once in its file at the time the
step runs. Line numbers are at `363c38d`, before any edit; match by text,
not by number. Apply the edits of a turn in the order given. Change nothing
else.

## Turn 1 — S1 and S2: version, and the documentation

### S1 — `plugins/glab/.claude-plugin/plugin.json` (line 3)

Old:
````text
  "version": "0.7.0",
````
New:
````text
  "version": "0.7.1",
````

### S2.1 — `plugins/glab/skills/external-agents/SKILL.md` (lines 42-45; claim 1)

Old:
````text
  - The CLI path: the one the user gave, or `~/.opencode/bin/opencode`, where
    the OpenCode installer puts its native binary. Say which you used. A
    launcher script in its place cannot run in the sandbox (it fails as exit
    7).
````
New:
````text
  - The CLI path: the one the user gave, or `~/.opencode/bin/opencode`, where
    the OpenCode installer puts its native binary. Say which you used. The
    script follows its links and mounts that one file in the sandbox, which
    holds nothing else of your home: a launcher script runs there only when
    its interpreter and everything it starts lie under `/usr`, `/bin`,
    `/sbin`, `/lib`, `/lib64` or `/etc`; one that starts a program anywhere
    else, as a package manager's launcher does, fails (exit 7).
````

### S2.2 — `README.md` (lines 39-40; claim 1)

Old:
````text
`tar` and `timeout`, and OpenCode's native binary (the installer puts it at
`~/.opencode/bin/opencode`; a launcher script does not run in the sandbox)
````
New:
````text
`tar` and `timeout`, and OpenCode's native binary (the installer puts it at
`~/.opencode/bin/opencode`; a launcher script runs in the sandbox only when
everything it starts lies under `/usr`, `/bin`, `/sbin`, `/lib`, `/lib64` or
`/etc`)
````

### S2.3 — `plugins/glab/skills/external-agents/SKILL.md` (lines 92-95; claims 2, 3)

Old:
````text
    prevent it. A write to an ignored file is not reported, except in the
    `core.hooksPath` directory or in a file the git config includes. The agent
    can make a path ignored itself, with a `.gitignore` of its own: a new
    ignored entry is reported by name, but not what is written in it.
````
New:
````text
    prevent it. A write to an ignored file is not reported, except in the
    `core.hooksPath` directory, or a changed value git reads from a file the
    git config includes. A change there that leaves every value as it was,
    such as a comment, is not reported, nor is a change to a file the config
    includes only under a condition that does not hold yet, such as an
    `includeIf "onbranch:…"` for another branch. Ignored here means ignored
    by the repository's own rules and config, or by `~/.config/git/ignore`
    (`$XDG_CONFIG_HOME/git/ignore`) when that config names no
    `core.excludesFile`: a file that only a `core.excludesFile` in your
    global or system git config ignores is reported as untracked. The agent
    can make a path ignored itself, with a `.gitignore` of its own: a new
    ignored entry is reported by name, but not what is written in it.
````

### S2.4 — `README.md` (lines 99-102; claims 2, 3)

Old:
````text
prevent it. A write to an ignored file is not reported, except in the
`core.hooksPath` directory or in a file the git config includes. The agent
can make a path ignored itself, with a `.gitignore` of its own: a new
ignored entry is reported by name, but not what is written in it.
````
New:
````text
prevent it. A write to an ignored file is not reported, except in the
`core.hooksPath` directory, or a changed value git reads from a file the
git config includes. A change there that leaves every value as it was,
such as a comment, is not reported, nor is a change to a file the config
includes only under a condition that does not hold yet, such as an
`includeIf "onbranch:…"` for another branch. Ignored here means ignored
by the repository's own rules and config, or by `~/.config/git/ignore`
(`$XDG_CONFIG_HOME/git/ignore`) when that config names no
`core.excludesFile`: a file that only a `core.excludesFile` in your
global or system git config ignores is reported as untracked. The agent
can make a path ignored itself, with a `.gitignore` of its own: a new
ignored entry is reported by name, but not what is written in it.
````

### S2.5 — `plugins/glab/skills/external-agents/SKILL.md` (lines 183-184; claim 3)

Old:
````text
then `git: unchanged`, or `git: changed` when `HEAD`, a ref, the git
config (its includes too), a hook, `info/`, the `core.hooksPath` directory,
````
New:
````text
then `git: unchanged`, or `git: changed` when `HEAD`, a ref, the git
config (its bytes, and every value git reads from it and from the files it
includes), a hook, `info/`, the `core.hooksPath` directory,
````

### S2.6 — `plugins/glab/skills/external-agents/SKILL.md` (lines 359-366; claims 2, 3, 12)

Old:
````text
  difference. It runs no `git status`, filter, fsmonitor or hook, and takes
  at most the turn's `--timeout`, 300 s at most. It sees an ignored entry
  made or removed, by name — the agent can make a path ignored itself — but
  not a write to an ignored file, other than in the `core.hooksPath`
  directory or in a file the git config includes, nor a write
  Codex itself — which runs outside its command sandbox — makes anywhere but
  the paths it lists and what it digests. A change to `.git` is reported
  after the turn, not prevented by the script.
````
New:
````text
  difference. It runs no `git status`, filter, fsmonitor or hook. Each of
  its two snapshots, before the turn and after it, runs for at most the
  turn's `--timeout`, 300 s at most, and 5 s more to end it; before every
  developer turn, and once more at `start`, the search for another `.git`
  runs for at most 300 s. Nothing bounds their sum. It sees an ignored
  entry made or removed, by name — the agent can make a path ignored
  itself — but not a write to an ignored file, other than in the
  `core.hooksPath` directory or a changed value git reads from a file the
  git config includes; not a change to an included file that leaves every
  value as it was, such as a comment, nor one to a file included only under
  a condition that does not hold yet, such as an `includeIf "onbranch:…"`
  for another branch; nor a write
  Codex itself — which runs outside its command sandbox — makes anywhere but
  the paths it lists and what it digests. Ignored means what the
  repository's own rules and config ignore, and `~/.config/git/ignore`
  (`$XDG_CONFIG_HOME/git/ignore`) when that config names no
  `core.excludesFile`; a file that only your global or system
  `core.excludesFile` ignores is untracked to the report, and listed as
  `??` when it changes. A change to `.git` is reported after the turn, not
  prevented by the script.
````

### S2.7 — `plugins/glab/scripts/external-agent.sh` (lines 133-139; claims 2, 3, 12)

Old:
````text
#   `git:` lines say what differs. It runs no git status, filter, fsmonitor or
#   hook, and at most the turn's --timeout, 300 s at most. It reports a change
#   once the turn is over and prevents none. It sees an ignored entry made or
#   removed, by name, but not a write to an ignored file, other than in the
#   core.hooksPath directory, nor a change
#   that Codex itself, outside its command sandbox, makes to anything but the
#   paths it lists and what it digests. A developer is refused (2 at start, 4
````
New:
````text
#   `git:` lines say what differs. It runs no git status, filter, fsmonitor or
#   hook. Each snapshot runs for at most the turn's --timeout, 300 s at most,
#   and 5 s more to end it, and dev_refuse's search for another .git, before
#   every developer turn and once more at start, for at most 300 s; nothing
#   bounds their sum. It reports a change
#   once the turn is over and prevents none. It sees an ignored entry made or
#   removed, by name, but not a write to an ignored file, other than in the
#   core.hooksPath directory or a changed value git reads from a file the
#   config includes - not a change that keeps every value, such as a comment,
#   nor one to a file included under a condition that does not hold yet, such
#   as another branch's includeIf onbranch: - nor a change
#   that Codex itself, outside its command sandbox, makes to anything but the
#   paths it lists and what it digests. Ignored is what the repository's own
#   rules and config ignore, and $XDG_CONFIG_HOME/git/ignore when that config
#   names no core.excludesFile: hostgit reads no global or system config, so
#   a file only their core.excludesFile ignores is untracked here. A
#   developer is refused (2 at start, 4
````

### S2.8 — `plugins/glab/scripts/external-agent.sh` (lines 431-433, the comment above `dev_git`; claim 3)

Old:
````text
# - the config, as bytes and as git reads it, includes and the worktree
#   config included and none of the user's: a core.hooksPath, core.fsmonitor
#   or filter set in an included file the agent can write is a change too;
````
New:
````text
# - the config, as bytes and as git reads it, includes and the worktree
#   config included and none of the user's: a core.hooksPath, core.fsmonitor
#   or filter set in an included file the agent can write is a change too.
#   An included file's own bytes are not digested, so a change that keeps
#   every value, such as a comment, is none; nor is a write to a file
#   included under a condition that does not hold yet, such as another
#   branch's includeIf onbranch:, whose values git does not list until it
#   does [fix-external-agent-claims/plan.md F1];
````

### S2.9 — `plugins/glab/skills/external-agents/SKILL.md` (line 160; claim 4)

Old:
````text
The exit code decides. stderr carries one line, `external-agent: <CODE>: <reason>`.
````
New:
````text
The exit code decides. On exits 2-12 stderr carries one line from the
script, `external-agent: <CODE>: <reason>`; a tool the script runs, such as
`tar` when it cannot read a file it copies, can print lines of its own there
too. The script's line is the one that starts `external-agent: `.
````

### S2.10 — `plugins/glab/scripts/external-agent.sh` (lines 46-48; claim 4)

Old:
````text
# stderr  one line `external-agent: <CODE>: <reason>` on every exit 2-12. A
#         signal ends it with 128 + the signal and no line: 129 HUP, 130 INT,
````
New:
````text
# stderr  one line `external-agent: <CODE>: <reason>` on every exit 2-12,
#         beside any line a tool the script runs prints there, such as tar's
#         for a file it cannot read. A
#         signal ends it with 128 + the signal and no line: 129 HUP, 130 INT,
````

### S2.11 — `plugins/glab/skills/external-agents/SKILL.md` (lines 162-164; claim 5)

Old:
````text
stdout of `start` and `send`: the **first line** is
`agent: <id> · model: <backend>:<model> · turn: <n> · transcript: <file>`, on
````
New:
````text
stdout of `start` and `send` is empty on exits 2-5, 9, 10 and 11. On exits
0, 6, 7, 8 and 12 the **first line** is
`agent: <id> · model: <backend>:<model> · turn: <n> · transcript: <file>`, on
````

### S2.12 — `plugins/glab/scripts/external-agent.sh` (line 22; claim 5)

Old:
````text
# stdout of start and send, in this order and nothing else:
````
New:
````text
# stdout of start and send is empty on exits 2-5, 9, 10 and 11. On exits 0,
# 6, 7, 8 and 12 it is, in this order and nothing else:
````

### S2.13 — `plugins/glab/skills/external-agents/SKILL.md` (lines 218-223; claim 6)

Old:
````text
**The transcript is for the user.** `<file>` from the first line holds every
turn: what you sent, the model's reasoning where it sends any, each tool call
and its output, and the reply — with the key redacted and control characters
removed. A Codex transcript is not redacted: it holds whatever Codex printed.
When the user wants to see how a model worked, give them that path; it is
there until `stop`.
````
New:
````text
**The transcript is for the user.** `<file>` from the first line holds every
turn: what you sent, the model's reasoning where it sends any, each tool call
and the reply — with the key redacted and control characters removed. Of an
OpenCode tool call it shows the first 500 characters of the input and the
first 2000 of the output; `transcript.jsonl` beside it keeps every event
whole. A Codex transcript is not redacted: it holds whatever Codex printed,
and `transcript.log` beside it keeps each turn's stderr and stdout as they
came. When the user wants to see how a model worked, give them that path;
it is there until `stop`.
````

### S2.14 — `plugins/glab/skills/external-agents/SKILL.md` (lines 230-232; claim 7)

Old:
````text
nothing else. An OpenCode reviewer's copy holds `HEAD` and the
working tree only, so its target is the working tree or a path in it; a branch
or range target cannot resolve there — tell the user instead of starting one.
````
New:
````text
nothing else. An OpenCode reviewer's copy holds the working tree and one
commit with `HEAD`'s tree and no parent, on the branch `HEAD` names, so its
target is the working tree or a path in it. That branch's name resolves
there, but to that one commit, not to its history, and no other branch, tag
or range resolves at all: for a branch or range target, tell the user
instead of starting one.
````

### S2.15 — `plugins/glab/skills/external-agents/SKILL.md` (lines 241-244; claim 8)

Old:
````text
returns the report block alone. It checks the block's form, not its
judgement: exactly one verdict line, and for `BLOCK: <n> issues` (or
`BLOCK: 1 issue`) an n of at least 1 and at least n findings with a `rule:`
line — advisory findings carry one too and are not counted in n. On exit 0
````
New:
````text
returns the report block alone. It checks the block's form, not its
judgement: exactly one verdict line, and for `BLOCK: <n> issues` (or
`BLOCK: 1 issue`) an n of at least 1 and at least n lines that start
`rule: ` — it counts those lines and does not check that each belongs to a
finding; advisory findings carry one too and are not counted in n. On exit 0
````

### S2.16 — `plugins/glab/skills/external-agents/SKILL.md` (lines 300-303; claim 9)

Old:
````text
- **What it may send.** The copy: the working tree's tracked files and its
  untracked files that are not ignored, the index, and the tree of `HEAD` as
  one commit — no other branch, tag or history. Ignored files are never
  copied. Everything in the copy, and every message you send, may reach the
````
New:
````text
- **What it may send.** The copy: the working tree's tracked files and its
  untracked files that are not ignored, the index, and the tree of `HEAD` as
  one commit — no other branch, tag or history. Ignored files are never
  copied, and neither is a nested repository: an untracked one is left out,
  and a submodule is an empty directory. Everything in the copy, and every
  message you send, may reach the
````

### S2.17 — `README.md` (lines 64-66; claim 9)

Old:
````text
What an OpenCode agent can send, and to whom: your working tree's tracked and
untracked-but-not-ignored files, the index and the tree of your current
commit — no other branch, tag or history, and never an ignored file — and
````
New:
````text
What an OpenCode agent can send, and to whom: your working tree's tracked and
untracked-but-not-ignored files, the index and the tree of your current
commit — no other branch, tag or history, never an ignored file and never a
nested repository — and
````

### S2.18 — `plugins/glab/scripts/external-agent.sh` (lines 66-69; claims 7, 9)

Old:
````text
# - The agent never sees the real repository. It gets a copy of the working
#   tree's tracked and untracked-but-not-ignored files, an index equal to the
#   real one, and the tree of the real HEAD as one parentless commit: no other
#   branch, tag, remote or older commit. Ignored files never leave the host.
````
New:
````text
# - The agent never sees the real repository. It gets a copy of the working
#   tree's tracked and untracked-but-not-ignored files, an index equal to the
#   real one, and the tree of the real HEAD as one parentless commit, on the
#   branch HEAD names, so that name resolves there, to that commit: no other
#   branch, tag, remote or older commit. Ignored files never leave the host,
#   and no nested repository does: an untracked one is left out, and a
#   submodule is an empty directory.
````

### S2.19 — `plugins/glab/skills/external-agents/SKILL.md` (lines 326-330; claim 11)

Old:
````text
- **Its limits.** Files up to 64 MiB, a 256 MiB `/tmp`, 256 processes, and
  4 GiB of data memory per process; at most 16 MiB of the backend's stdout
  and 16 MiB of its stderr per turn reach the disk, and a turn that writes
  more is exit 7. Total memory, and the disk the copy and its session use
  under `TMPDIR`, are not limited.
````
New:
````text
- **Its limits.** Files up to 64 MiB, a 256 MiB `/tmp`, 256 processes, and
  4 GiB of data memory per process; of the backend's stdout and of its
  stderr, the first 16 MiB per turn are kept, and a turn that writes more is
  exit 7. The 16 MiB are counted before the key is redacted, which can make
  what reaches the disk longer, but less than twice as long. Total memory,
  and the disk the copy and its session use under `TMPDIR`, are not limited.
````

### S2.20 — `plugins/glab/scripts/external-agent.sh` (lines 94-97; claim 11)

Old:
````text
#   and are bounded per file, not in total; total memory is not bounded. Of
#   the backend's stdout and of its stderr, at most 16 MiB per turn reach the
#   disk; a turn that writes more is cut there and is exit 7.
````
New:
````text
#   and are bounded per file, not in total; total memory is not bounded. Of
#   the backend's stdout and of its stderr, the first 16 MiB per turn are
#   kept; a turn that writes more is cut there and is exit 7. The cap counts
#   the bytes before the key is redacted, so what reaches the disk can be
#   longer, but less than twice as long (OUT_BYTES).
````

### S2.21 — `plugins/glab/scripts/external-agent.sh` (lines 164-166; claim 11)

Old:
````text
# - Of its stdout and its stderr, at most 16 MiB per turn reach the disk, as
#   for OpenCode; files, processes and memory are not limited by this script,
#   and nothing is redacted.
````
New:
````text
# - Of its stdout and its stderr, at most 16 MiB per turn reach the disk, cut
#   as for OpenCode; nothing is redacted, so nothing grows past the cap; files,
#   processes and memory are not limited by this script.
````

### S2.22 — `plugins/glab/scripts/external-agent.sh` (lines 203-204, the comment above `OUT_BYTES`; claim 11)

Old:
````text
# boundary, so no part of a line - of the key least of all - reaches the disk
# unredacted, and the turn is exit 7. slirp4netns's log is cut at the same size.
````
New:
````text
# boundary, so no part of a line - of the key least of all - reaches the disk
# unredacted, and the turn is exit 7. slirp4netns's log is cut at the same size.
# The cap counts the bytes as they come, before redaction, which replaces a
# key of at least 8 characters (read_secret) with the 10 of <redacted>: what
# is written can be up to 1.25 times as long
# [fix-external-agent-claims/claims.md 11].
````

Turn 1 is S1 and S2.1-S2.22.

## Turn 2 — S3: the sandbox check first (claim 13)

### S3.1 — `plugins/glab/scripts/external-agent.sh` (`finish_turn`, line 1442)

Old:
````text
  local s
  for s in stdout stderr; do
````
New:
````text
  local s
  # A host backend's own report of its sandbox, before anything it printed is
  # used, and before the output cap and the timeout: a turn whose header
  # names another sandbox or approval is 12 whatever else it did, where a
  # flood or a hang would otherwise report it as 7 or 6
  # [fix-external-agent-claims/claims.md 13]. The header block is in the
  # first 20 lines of stderr, which the cap keeps; a turn that timed out
  # before Codex printed it has no block, which codex_verify lets pass, so it
  # is still a timeout.
  if [ "$isolation" = host ]; then "${backend}_verify" "$id" "$model"; fi
  for s in stdout stderr; do
````

### S3.2 — `plugins/glab/scripts/external-agent.sh` (`finish_turn`, lines 1456-1458)

The comment and the call move into S3.1; this removes them from their old
place.

Old:
````text
  # A host backend's own report of its sandbox, before anything it printed is used.
  if [ "$isolation" = host ]; then "${backend}_verify" "$id" "$model"; fi
  err=$("${backend}_error" "$run/turn.out" | redact_stream)
````
New:
````text
  err=$("${backend}_error" "$run/turn.out" | redact_stream)
````

### S3.3 — `plugins/glab/scripts/external-agent.sh` (lines 125-128)

Old:
````text
#   `never`. A block that names another sandbox or approval is exit 12 and the
#   reply is withheld; a turn whose block is missing, or has no well-formed
````
New:
````text
#   `never`. A block that names another sandbox or approval is exit 12 and the
#   reply is withheld, checked before the output cap and the timeout, so such
#   a turn is 12 even when it also wrote too much or ran too long; a turn
#   whose block is missing, or has no well-formed
````

### S3.4 — `plugins/glab/skills/external-agents/SKILL.md` (lines 384-391)

Old:
````text
- **Its limits.** At most 16 MiB of Codex's stdout and 16 MiB of its stderr
  per turn reach the disk, and a turn that writes more is exit 7; and the
  timeout. Files, processes and memory are not limited by the script.
- **What is checked.** Every turn, the header block Codex prints must say
  `sandbox: read-only` — for a developer, exactly
  `sandbox: workspace-write [workdir]` — and `approval: never`, or the reply
  is withheld (exit 12); its model and its session id are checked for their form (exit 7); and
  the reviewer's report, as for OpenCode.
````
New:
````text
- **Its limits.** At most 16 MiB of Codex's stdout and 16 MiB of its stderr
  per turn reach the disk, and a turn that writes more is exit 7, or 12 when
  its header names another sandbox or approval (*What is checked*); and the
  timeout. Files, processes and memory are not limited by the script.
- **What is checked.** Every turn, the header block Codex prints must say
  `sandbox: read-only` — for a developer, exactly
  `sandbox: workspace-write [workdir]` — and `approval: never`, or the reply
  is withheld (exit 12). That is checked first: a turn that also ran past
  its `--timeout` or past the output cap is 12, not 6 or 7, and a turn that
  timed out before Codex printed its header is 6. Its model and its session
  id are checked for their form (exit 7); and
  the reviewer's report, as for OpenCode.
````

### S3.5 — `tests/external-agent.test.sh` (the stub `codex`, line 253)

Old:
````text
	ro-net) hs='read-only (network access enabled)' ;;
````
New:
````text
	ro-net|ro-net-flood|ro-net-slow) hs='read-only (network access enabled)' ;;
````

### S3.6 — `tests/external-agent.test.sh` (the stub `codex`, its last scenario, line 346)

Old:
````text
	*) echo "stub codex: no scenario [$scen]" ;;
````
New:
````text
	# A header naming another sandbox, then more than the cap on stdout, or a
	# turn past --timeout: the sandbox check comes first (E85).
	ro-net-flood) yes flood | head -c 17M ;;
	ro-net-slow) exec sleep 30 ;;
	*) echo "stub codex: no scenario [$scen]" ;;
````

### S3.7 — `tests/external-agent.test.sh` (after E84, line 1430; and the comment at line 729)

Old:
````text
t E84 "files a .gitignore written in the turn hides are listed as ignored (!!), not changed: none"
````
New:
````text
t E84 "files a .gitignore written in the turn hides are listed as ignored (!!), not changed: none"

# [fix-external-agent-claims/claims.md 13] The sandbox check comes before the
# output cap and the timeout: a header naming another sandbox is 12 either way.
cstart ro-net-flood; r1=$RC e1=$ERR o1=$OUT; stop_all
cstart ro-net-slow --timeout 2; r2=$RC e2=$ERR o2=$OUT; stop_all
[ "$r1" = 12 ] && command grep -qF "NOT READ-ONLY: codex reported sandbox 'read-only (network access enabled)'" <<<"$e1" && ! command grep -qx 'reply:' <<<"$o1" \
	&& [ "$r2" = 12 ] && command grep -qF "NOT READ-ONLY: codex reported sandbox 'read-only (network access enabled)'" <<<"$e2" && ! command grep -qx 'reply:' <<<"$o2" \
	&& [ "$(leftovers)" = "$BASE_PROCS" ] && OK=1
t E85 "a Codex turn whose header names another sandbox is not read-only (12) even when it also wrote past the 16 MiB cap or ran past --timeout: the sandbox check comes first"
````

### S3.8 — `tests/external-agent.test.sh` (line 729)

Old:
````text
# E37-E84 were added after E36 was written, and run before it: E36 checks
````
New:
````text
# E37-E85 were added after E36 was written, and run before it: E36 checks
````

Turn 2 is S3.1-S3.8.

## Turn 3 — S4: the key in `transcript.jsonl` (claim 10)

### S4.1 — `plugins/glab/scripts/external-agent.sh` (lines 654-656)

Old:
````text
# Its raw transcript is the turn's JSON events, as they came.
opencode_raw_name() { echo transcript.jsonl; }
opencode_raw() { cat "$run/turn.out"; }
````
New:
````text
# Its raw transcript is the turn's JSON events, as they came, but for an
# event that holds the key once decoded. The stream was redacted on its way
# to the disk on the key's literal bytes only, and a key the model wrote
# JSON-escaped - K for a K, or \" for a quote in the key - is whole only
# once jq has decoded it [feature-opencode-worker/follow-ups.md 10, 17]
# [fix-external-agent-claims/claims.md 10]. jq decodes each line and says
# whether any string in it, an object key included, holds the key; awk then
# writes every other line byte for byte, and that one as the event
# {"type":"redacted"}. Not re-encoded: jq's encoding is not the backend's,
# and writes a DEL as \u007f, six bytes for one, which would break the
# OUT_BYTES bound on the disk [fix-external-agent-claims/plan.md D1]. A line
# jq cannot decode is no event, and is kept as it came. jq prints one verdict
# per line; a line without a "-" verdict, as when jq fails, is written as
# {"type":"redacted"}, so a failure hides the turn and does not leak it. The
# key reaches jq in its environment, never on its command line.
# shellcheck disable=SC2016
readonly JQ_HOLDS_KEY='def holds_key: $ENV.K != "" and ([.. | strings, (objects | keys[])] | any(contains($ENV.K)));'
opencode_raw_name() { echo transcript.jsonl; }
opencode_raw() {
  awk 'FILENAME == ARGV[1] {v[FNR] = $0; next} {if (v[FNR] == "-") print; else print "{\"type\":\"redacted\"}"}' \
    <(K=$secret jq -R -r "$JQ_HOLDS_KEY"' try (fromjson | if holds_key then "k" else "-" end) catch "-"' "$run/turn.out") \
    "$run/turn.out"
}
````

### S4.2 — `plugins/glab/scripts/external-agent.sh` (lines 323-324, the comment above `redact_stream`)

Old:
````text
# The key is replaced line by line as the stream is written, so no unredacted
# copy reaches the disk, even when this script is killed mid-turn. With a flag
````
New:
````text
# The key, as written out, is replaced line by line as the stream is written,
# so no copy of it in that form reaches the disk, even when this script is
# killed mid-turn. A key the model wrote JSON-escaped is whole only once
# decoded: run/turn.out holds it so until run/ is removed - when the call
# ends, or after a SIGKILL at the next send or stop - and what is kept or
# printed is redacted again after decoding (opencode_raw, the renderer, the
# reply). With a flag
````

### S4.3 — `plugins/glab/scripts/external-agent.sh` (lines 98-100)

Old:
````text
# - The backend's key is inside the sandbox, because the CLI needs it, and the
#   model can read it there. It is never on a command line and never printed;
#   it is redacted from everything this script writes or prints.
````
New:
````text
# - The backend's key is inside the sandbox, because the CLI needs it, and the
#   model can read it there. It is never on a command line and never printed.
#   Written out, it is redacted from everything this script writes or prints;
#   JSON-escaped, from the reply and both transcripts, where transcript.jsonl
#   keeps an event that holds it as {"type":"redacted"}; until run/ is
#   removed, run/turn.out still holds it escaped. A key the model writes in
#   any other form is not recognised.
````

### S4.4 — `plugins/glab/scripts/external-agent.sh` (the comment S2.22 added)

Old:
````text
# is written can be up to 1.25 times as long
# [fix-external-agent-claims/claims.md 11].
````
New:
````text
# is written can be up to 1.25 times as long
# [fix-external-agent-claims/claims.md 11]. In transcript.jsonl, an event
# opencode_raw replaces is at least 12 bytes and becomes 20: under 1.67 times.
````

### S4.5 — `plugins/glab/skills/external-agents/SKILL.md` (the paragraph S2.13 wrote)

Old:
````text
first 2000 of the output; `transcript.jsonl` beside it keeps every event
whole. A Codex transcript is not redacted: it holds whatever Codex printed,
````
New:
````text
first 2000 of the output; `transcript.jsonl` beside it keeps every event
whole, but writes one that holds the key once decoded — the model wrote it
JSON-escaped — as `{"type":"redacted"}`. A Codex transcript is not
redacted: it holds whatever Codex printed,
````

### S4.6 — `plugins/glab/skills/external-agents/SKILL.md` (lines 322-325)

Old:
````text
- **Its key.** The OpenCode Go key is inside the sandbox, because the CLI
  needs it, and the model can read it there and send it out. It is never on a
  command line and never printed, and it is redacted from the reply and both
  transcripts.
````
New:
````text
- **Its key.** The OpenCode Go key is inside the sandbox, because the CLI
  needs it, and the model can read it there and send it out. It is never on a
  command line and never printed, and it is redacted from the reply and both
  transcripts where it appears as itself: written out, or JSON-escaped in an
  event, which `transcript.jsonl` then keeps as `{"type":"redacted"}`. A key
  the model writes in any other form, such as base64, is not recognised.
````

### S4.7 — `tests/external-agent.test.sh` (after E85, which S3.7 added)

Old:
````text
t E85 "a Codex turn whose header names another sandbox is not read-only (12) even when it also wrote past the 16 MiB cap or ran past --timeout: the sandbox check comes first"
````
New:
````text
t E85 "a Codex turn whose header names another sandbox is not read-only (12) even when it also wrote past the 16 MiB cap or ran past --timeout: the sandbox check comes first"

# [fix-external-agent-claims/claims.md 10] transcript.jsonl, decoded, holds no
# key: not one the model JSON-escaped, nor one whose quote and backslash any
# JSON encoder escapes. The second key is stored for this case only.
start leak-escaped; A=$ID; r1=$RC
j1=$(jq -R -r 'fromjson? | (.. | strings), (.. | objects | keys[])' "$STATE/$A/transcript.jsonl")
x1=0; command grep -qxF '{"type":"redacted"}' "$STATE/$A/transcript.jsonl" && x1=1
stop_all
K2='KEY-q"uo\te-0123'
mv "$W/home/stub-auth.json" "$W/auth.keep"
jq -cn --arg k "$K2" '[{id: "cred_1", integrationID: "opencode-go", label: "default", active: true, value: {type: "key", key: $k}}]' >"$W/home/stub-auth.json"
start leak; A=$ID; r2=$RC o2=$OUT
j2=$(jq -R -r 'fromjson? | (.. | strings), (.. | objects | keys[])' "$STATE/$A/transcript.jsonl")
x2=0; command grep -qxF '{"type":"redacted"}' "$STATE/$A/transcript.jsonl" && x2=1
stop_all
mv "$W/auth.keep" "$W/home/stub-auth.json"
[ "$r1" = 0 ] && [ -n "$j1" ] && ! command grep -qF "$KEY" <<<"$j1" && [ "$x1" = 1 ] \
	&& [ "$r2" = 0 ] && [ -n "$j2" ] && ! command grep -qF "$K2" <<<"$j2" && [ "$x2" = 1 ] && ! command grep -qF "$K2" <<<"$o2" && OK=1
t E86 "transcript.jsonl holds no key once decoded: an event with the key JSON-escaped, or with a key whose quote and backslash every encoder escapes, is written as {\"type\":\"redacted\"}"
````

### S4.8 — `tests/external-agent.test.sh` (the comment S3.8 changed)

Old:
````text
# E37-E85 were added after E36 was written, and run before it: E36 checks
````
New:
````text
# E37-E86 were added after E36 was written, and run before it: E36 checks
````

Turn 3 is S4.1-S4.8.

## Turn 4 — S5: review round 1 fixes (revision 2)

Written against the working tree after turns 1-3 (the build conformance
found byte-identical to revision 1), not against `363c38d`. Line numbers
are that tree's. One `send` to the same Codex developer, or a new one: the
brief names the slug and S5.1-S5.9. Findings: `review-r1.md`.

### S5.1 — `plugins/glab/scripts/external-agent.sh` (`opencode_raw`, line 714; C1)

Old:
````text
    <(K=$secret jq -R -r "$JQ_HOLDS_KEY"' try (fromjson | if holds_key then "k" else "-" end) catch "-"' "$run/turn.out") \
````
New:
````text
    <(K=$secret jq -R -r "$JQ_HOLDS_KEY"' try (fromjson | if holds_key then "k" else "-" end) catch (if explode | any(. == 92) then "k" else "-" end)' "$run/turn.out") \
````

### S5.2 — `plugins/glab/scripts/external-agent.sh` (the comment above `opencode_raw`, line 696; T1)

Old:
````text
# JSON-escaped - K for a K, or \" for a quote in the key - is whole only
````
New:
````text
# JSON-escaped - \u004b for a K, or \" for a quote in the key - is whole only
````

### S5.3 — `plugins/glab/scripts/external-agent.sh` (the same comment, lines 703-705; C1)

Old:
````text
# OUT_BYTES bound on the disk [fix-external-agent-claims/plan.md D1]. A line
# jq cannot decode is no event, and is kept as it came. jq prints one verdict
# per line; a line without a "-" verdict, as when jq fails, is written as
````
New:
````text
# OUT_BYTES bound on the disk [fix-external-agent-claims/plan.md D1]. A line
# that is not exactly one JSON value - half of an event split over two
# lines, two events on one line, or one past jq's depth limit - fails
# fromjson here, but the script's other readers read the file as a stream
# and decode it. A JSON string cannot span lines, so a key escaped in one is
# on a line that holds a backslash (code point 92): such a line is written
# as {"type":"redacted"}, and one without a backslash, whose strings hold no
# escape and whose written-out key was redacted on the way to the disk, as
# it came [fix-external-agent-claims/review-r1.md C1]. jq prints one verdict
# per line; a line without a "-" verdict, as when jq fails, is written as
````

### S5.4 — `README.md` (lines 76-77; T2)

Old:
````text
is inside that sandbox, where the model can read it and could send it out; it
is never printed and is redacted from what the agent returns. Each agent's
````
New:
````text
is inside that sandbox, where the model can read it and could send it out; it
is never printed and is redacted from what the agent returns, where it
appears written out or JSON-escaped; a key the model writes in any other
form, such as base64, is not recognised. Each agent's
````

### S5.5 — `tests/external-agent.test.sh` (E42's title, line 789; T3)

Old:
````text
t E42 "at most 16 MiB of a turn's stdout and of its stderr reach the disk, in whole lines; a turn that writes more is a backend error (7)"
````
New:
````text
t E42 "the first 16 MiB of a turn's stdout and of its stderr are kept, in whole lines; a turn that writes more is a backend error (7)"
````

### S5.6 — `plugins/glab/scripts/external-agent.sh` (the comment above `header`, line 1494; T4)

Old:
````text
# turn has run: header is called only after a turn, on exits 0, 6, 7 and 12.
````
New:
````text
# turn has run: header is called only after a turn, on exits 0, 6, 7, 8 and
# 12; the change report on 0, 6, 7 and 12, since a developer is never 8.
````

### S5.7 — `tests/external-agent.test.sh` (the stub `opencode`, line 159; C1, C2)

Old:
````text
	leak-escaped) k=$(key); printf '{"type":"text","sessionID":"%s","part":{"type":"text","text":"escaped \\u%04x%s here"}}\n' "$sid" "'${k:0:1}" "${k:1}" ;;
````
New:
````text
	leak-escaped) k=$(key); printf '{"type":"text","sessionID":"%s","part":{"type":"text","text":"escaped \\u%04x%s here"}}\n' "$sid" "'${k:0:1}" "${k:1}" ;;
	# The key escaped on a line that holds no one whole event: an event split
	# over two lines, two events on one line; and as an object key (E86).
	leak-split) k=$(key); printf '{"type":"text","sessionID":"%s","part":{"type":"text","text":\n"split \\u%04x%s here"}}\n' "$sid" "'${k:0:1}" "${k:1}" ;;
	leak-two) k=$(key); printf '{"type":"noise","sessionID":"%s"} {"type":"text","sessionID":"%s","part":{"type":"text","text":"two \\u%04x%s here"}}\n' "$sid" "$sid" "'${k:0:1}" "${k:1}" ;;
	leak-objkey) k=$(key); printf '{"type":"noise","sessionID":"%s","\\u%04x%s":1}\n' "$sid" "'${k:0:1}" "${k:1}"; text "objkey sent" ;;
````

### S5.8 — `tests/external-agent.test.sh` (E86's assertion, lines 1459-1461; C1, C2)

Old:
````text
mv "$W/auth.keep" "$W/home/stub-auth.json"
[ "$r1" = 0 ] && [ -n "$j1" ] && ! command grep -qF "$KEY" <<<"$j1" && [ "$x1" = 1 ] \
	&& [ "$r2" = 0 ] && [ -n "$j2" ] && ! command grep -qF "$K2" <<<"$j2" && [ "$x2" = 1 ] && ! command grep -qF "$K2" <<<"$o2" && OK=1
````
New:
````text
mv "$W/auth.keep" "$W/home/stub-auth.json"
# The whole file decoded as a stream, as the script's own readers decode it,
# object keys included [fix-external-agent-claims/review-r1.md C1, C2]: an
# event split over two lines, two events on one line, the key as an object
# key. Each must be written as {"type":"redacted"} and leave no key.
ok3=1
for sc in leak-split leak-two leak-objkey; do
	start "$sc"; A=$ID
	js=$(jq -r '(.. | strings), (.. | objects | keys[])' "$STATE/$A/transcript.jsonl" 2>/dev/null)
	{ [ "$RC" = 0 ] && ! command grep -qF "$KEY" <<<"$js" && ! command grep -qF "$KEY" "$STATE/$A/transcript.jsonl" \
		&& command grep -qxF '{"type":"redacted"}' "$STATE/$A/transcript.jsonl"; } || { ok3=0; echo "   E86 $sc: rc=$RC"; }
	stop_all
done
[ "$r1" = 0 ] && [ -n "$j1" ] && ! command grep -qF "$KEY" <<<"$j1" && [ "$x1" = 1 ] \
	&& [ "$r2" = 0 ] && [ -n "$j2" ] && ! command grep -qF "$K2" <<<"$j2" && [ "$x2" = 1 ] && ! command grep -qF "$K2" <<<"$o2" \
	&& [ "$ok3" = 1 ] && OK=1
````

### S5.9 — `tests/external-agent.test.sh` (E86's title, line 1462)

Old:
````text
t E86 "transcript.jsonl holds no key once decoded: an event with the key JSON-escaped, or with a key whose quote and backslash every encoder escapes, is written as {\"type\":\"redacted\"}"
````
New:
````text
t E86 "transcript.jsonl holds no key once decoded, line by line or as a stream: an event with the key JSON-escaped, or with a key whose quote and backslash every encoder escapes, split over two lines, sharing a line or as an object key, is written as {\"type\":\"redacted\"}"
````

Turn 4 is S5.1-S5.9. The test count stays 86: no `t E` line is added.

## Turn 5 — S6: review round 2 fixes (revision 3)

Written against the working tree after turn 4 (`review-r2.md`); line
numbers are that tree's. One `send` to a new Codex developer: the brief
names the slug and S6.1-S6.7. No new logic in the script: S6.1-S6.4 are
comments and prose; S6.5-S6.7 change E86 only. The test count stays 86.

The bound, from the code. `redact_stream` keeps whole lines while their
bytes, newline included, sum to at most OUT_BYTES (16777216), counted
before redaction. `opencode_raw` then writes each line either as it is, at
most 1.25 times as long (the literal key, 8 characters or more, becomes the
10 of `<redacted>`), or as `{"type":"redacted"}` and a newline, 20 bytes,
whatever its length. The shortest line it replaces when `jq` works is not
one JSON value and holds a backslash: `\` and its newline, 2 bytes, so
20/2 = **10 times OUT_BYTES** (160 MiB) for one turn's `transcript.jsonl`.
When `jq` fails, every line is replaced, an empty one of 1 byte included:
**20 times** (320 MiB). That second figure is F6, folded in here.

### S6.1 — `plugins/glab/scripts/external-agent.sh` (the header, lines 104-106; R2-1)

Old:
````text
#   kept; a turn that writes more is cut there and is exit 7. The cap counts
#   the bytes before the key is redacted, so what reaches the disk can be
#   longer, but less than twice as long (OUT_BYTES).
````
New:
````text
#   kept; a turn that writes more is cut there and is exit 7. The cap counts
#   the bytes before the key is redacted, so what reaches the disk can be
#   longer: stderr up to 1.25 times the cap, and a turn's transcript.jsonl
#   up to 10 times, or 20 times when jq fails (OUT_BYTES).
````

### S6.2 — `plugins/glab/scripts/external-agent.sh` (the comment above `OUT_BYTES`, lines 232-233; R2-1)

Old:
````text
# [fix-external-agent-claims/claims.md 11]. In transcript.jsonl, an event
# opencode_raw replaces is at least 12 bytes and becomes 20: under 1.67 times.
````
New:
````text
# [fix-external-agent-claims/claims.md 11]. In transcript.jsonl, opencode_raw
# writes a line it replaces as the 20 bytes of {"type":"redacted"} and its
# newline, whatever the line's length. The shortest such line when jq works
# is a backslash and its newline, 2 bytes, not one JSON value, so a turn's
# transcript.jsonl can reach 10 times OUT_BYTES; when jq fails every line
# is replaced, an empty one of 1 byte too, so 20 times
# [fix-external-agent-claims/review-r2.md R2-1].
````

### S6.3 — `plugins/glab/skills/external-agents/SKILL.md` (lines 358-359; R2-1)

Old:
````text
  exit 7. The 16 MiB are counted before the key is redacted, which can make
  what reaches the disk longer, but less than twice as long. Total memory,
````
New:
````text
  exit 7. The 16 MiB are counted before the key is redacted, which can make
  what reaches the disk longer: `transcript.jsonl` writes each line it
  redacts as one 20-byte event whatever the line's length, so one turn
  there can reach 10 times 16 MiB, about 160 MiB, and 20 times if `jq`
  fails. Total memory,
````

### S6.4 — `plugins/glab/scripts/external-agent.sh` (the comment above `opencode_raw`, lines 704-707; R2-2)

Old:
````text
# that is not exactly one JSON value - half of an event split over two
# lines, two events on one line, or one past jq's depth limit - fails
# fromjson here, but the script's other readers read the file as a stream
# and decode it. A JSON string cannot span lines, so a key escaped in one is
````
New:
````text
# that is not exactly one JSON value - half of an event split over two
# lines or two events on one line, which the script's other readers decode
# as they read the file as a stream, or one past jq's depth limit, which no
# reader decodes - fails fromjson here. A JSON string cannot span lines, so
# a key escaped in one is
````

### S6.5 — `tests/external-agent.test.sh` (E86's loop, lines 1473-1475; the advisory)

Old:
````text
		&& command grep -qxF '{"type":"redacted"}' "$STATE/$A/transcript.jsonl"; } || { ok3=0; echo "   E86 $sc: rc=$RC"; }
	stop_all
done
````
New:
````text
		&& command grep -qxF '{"type":"redacted"}' "$STATE/$A/transcript.jsonl"; } || { ok3=0; echo "   E86 $sc: rc=$RC"; }
	# Once leak-split's second line is redacted, the stream check above
	# decodes nothing of that event, so the case also shows that it came in
	# two lines and that the reply decoded it (review-r2.md, advisory).
	case $sc in leak-split) { [ "$(wc -l <"$STATE/$A/transcript.jsonl")" = 2 ] && has 'split <redacted> here'; } \
		|| { ok3=0; echo "   E86 leak-split: not two lines, or no decoded reply"; } ;; esac
	stop_all
done
````

### S6.6 — `tests/external-agent.test.sh` (E86's assertion, lines 1476-1478; R2-3)

Old:
````text
[ "$r1" = 0 ] && [ -n "$j1" ] && ! command grep -qF "$KEY" <<<"$j1" && [ "$x1" = 1 ] \
	&& [ "$r2" = 0 ] && [ -n "$j2" ] && ! command grep -qF "$K2" <<<"$j2" && [ "$x2" = 1 ] && ! command grep -qF "$K2" <<<"$o2" \
	&& [ "$ok3" = 1 ] && OK=1
````
New:
````text
# [fix-external-agent-claims/review-r2.md R2-3] A jq first on the script's
# PATH that fails only opencode_raw's call, the one whose program holds
# holds_key, and runs the real jq for every other: then every line of the
# turn is {"type":"redacted"}, and no key is left.
rjq=$(command -v jq)
# The $* and $@ are the wrapper's own (SC2016).
# shellcheck disable=SC2016
printf '#!/bin/sh\ncase "$*" in *holds_key*) exit 1 ;; esac\nexec '"'"'%s'"'"' "$@"\n' "$rjq" >"$W/bin/jq"; chmod +x "$W/bin/jq"
start leak-split; A=$ID; r4=$RC f4=$STATE/$A/transcript.jsonl
j4=$(jq -r '(.. | strings), (.. | objects | keys[])' "$f4" 2>/dev/null)
k4=0; [ "$(wc -l <"$f4")" = 2 ] && ! command grep -qvxF '{"type":"redacted"}' "$f4" && ! command grep -qF "$KEY" "$f4" && ! command grep -qF "$KEY" <<<"$j4" && k4=1
rm -f "$W/bin/jq"
stop_all
[ "$r1" = 0 ] && [ -n "$j1" ] && ! command grep -qF "$KEY" <<<"$j1" && [ "$x1" = 1 ] \
	&& [ "$r2" = 0 ] && [ -n "$j2" ] && ! command grep -qF "$K2" <<<"$j2" && [ "$x2" = 1 ] && ! command grep -qF "$K2" <<<"$o2" \
	&& [ "$ok3" = 1 ] && [ "$r4" = 0 ] && [ "$k4" = 1 ] && OK=1
````

### S6.7 — `tests/external-agent.test.sh` (E86's title, line 1479)

Old:
````text
t E86 "transcript.jsonl holds no key once decoded, line by line or as a stream: an event with the key JSON-escaped, or with a key whose quote and backslash every encoder escapes, split over two lines, sharing a line or as an object key, is written as {\"type\":\"redacted\"}"
````
New:
````text
t E86 "transcript.jsonl holds no key once decoded, line by line or as a stream: an event with the key JSON-escaped, or with a key whose quote and backslash every encoder escapes, split over two lines, sharing a line or as an object key, is written as {\"type\":\"redacted\"}, and every line is when jq fails"
````

Turn 5 is S6.1-S6.7. The test count stays 86: no `t E` line is added.

## Verify — the manager, after each turn

Codex cannot run the test gate in its sandbox, so every line below is the
manager's, on the host, after the turn. In this order:

1. The turn's exit is 0 and its report says `git: unchanged`; then the
   inspection `glab:external-agents` *The developer role* prescribes, from
   the `changed:` lines only, before any `git status` or `git diff`. The
   paths named are exactly the turn's files in *Who builds it* — no other
   path, no `!!` line.
2. `export TMPDIR=` the temp directory the host file names, then both
   blocks of `AGENTS.md` *Gates*, pasted with their output. Green as
   `AGENTS.md` defines it, with the external test's last line
   `PASS 84/84` after turn 1, `PASS 85/85` after turn 2 and `PASS 86/86`
   after turns 3, 4 and 5, and the plugin gates unchanged: `Skills (15)`,
   `Agents (5)`, `Hooks (1)  SessionStart` for `glab`.
3. The searches of that turn (below), each with the count given. Each was
   counted on `363c38d` too (the value in brackets), so each one fails on
   today's tree.
4. After turns 2 and 3, the new cases fail without the code: run the new
   test against `HEAD`'s plugin.

        old=$(mktemp -d "${TMPDIR:?}/eac-old.XXXXXX") && git archive HEAD plugins/glab | tar -x -C "$old" \
          && bash tests/external-agent.test.sh "$old/plugins/glab/scripts/external-agent.sh" </dev/null | command grep -E '^(NOT OK|PASS|FAIL)'; rm -rf "${old:?}"

   After turn 2: `NOT OK E85 …` and `FAIL 1/85`, nothing else. After turn
   3: `NOT OK E85 …`, `NOT OK E86 …` and `FAIL 2/86`, nothing else.
5. After the inspection only: `git -c core.fsmonitor=false diff --name-only`
   lists the turn's files (cumulative), and nothing under `plan/`.

Searches (`S=plugins/glab/skills/external-agents/SKILL.md`,
`E=plugins/glab/scripts/external-agent.sh`, `T=tests/external-agent.test.sh`):

After turn 1:

    jq -r .version plugins/glab/.claude-plugin/plugin.json                    # 0.7.1 [0.7.0]
    command grep -c -F 'cannot run in the sandbox' "$S"                        # 0 [1]
    command grep -c -F 'a launcher script runs there only when' "$S"           # 1 [0]
    command grep -c -F 'a launcher script does not run in the sandbox' README.md   # 0 [1]
    command grep -c -F 'a launcher script runs in the sandbox only when' README.md # 1 [0]
    command grep -c -F 'or in a file the git config includes' "$S" README.md   # S:0 R:0 [S:2 R:1]
    command grep -c -F 'includeIf "onbranch:' "$S" README.md                   # S:2 R:1 [0 0]
    command grep -c -F 'is reported as untracked' "$S" README.md               # S:1 R:1 [0 0]
    command grep -c -F 'stderr carries one line, ' "$S"                        # 0 [1]
    command grep -c -F 'is empty on exits 2-5, 9, 10 and 11' "$S" "$E"         # S:1 E:1 [0 0]
    command grep -c -F 'first 500 characters' "$S"                             # 1 [0]
    command grep -c -F 'cannot resolve there' "$S"                             # 0 [1]
    command grep -c -F 'at least n lines that start' "$S"                      # 1 [0]
    command grep -c -F 'neither is a nested repository' "$S"                   # 1 [0]
    command grep -c -F 'never an ignored file and never a' README.md           # 1 [0]
    command grep -c -F 'no nested repository does' "$E"                        # 1 [0]
    command grep -c -F 'less than twice as long' "$S" "$E"                     # S:1 E:1 [0 0]
    command grep -c -F '300 s at most. It sees' "$S"                           # 0 [1]
    command grep -c -F 'Nothing bounds their sum' "$S"                         # 1 [0]
    command grep -c -F 'once more at start, for at most 300 s' "$E"            # 1 [0]
    command grep -c -F 'beside any line a tool the script runs prints there' "$E"  # 1 [0]
    command grep -c -F 'fix-external-agent-claims/plan.md F1' "$E"             # 1 [0]
    command grep -c -F 'fix-external-agent-claims/claims.md 11' "$E"           # 1 [0]

After turn 2:

    command grep -c -F 'fix-external-agent-claims/claims.md 13' "$E" "$T"     # E:1 T:1 [0 0]
    command grep -c -F '"${backend}_verify" "$id" "$model"' "$E"               # 1 [1]
    awk '/^finish_turn\(\) \{/,/^\}/' "$E" | command grep -n -E '_verify" "\$id"|capped\.\$\$|die 6 TIMEOUT'
                                         # three lines; the _verify line has the smallest number [it has the largest]
    command grep -c -F 'That is checked first' "$S"                            # 1 [0]
    command grep -c -F 'ro-net-flood' "$T"                                     # 3 [0]
    command grep -c '^t E' "$T"                                                # 85 [84]
    command grep -c -F 'E37-E85 were added' "$T"                               # 1 [0]

After turn 3:

    command grep -c -F 'opencode_raw() { cat' "$E"                             # 0 [1]
    command grep -c -F 'JQ_HOLDS_KEY' "$E"                                     # 2 [0]
    command grep -c -F 'JSON-escaped, from the reply and both transcripts' "$E"  # 1 [0]
    command grep -c -F '{"type":"redacted"}' "$S"                              # 2 [0]
    command grep -c -F 'fix-external-agent-claims/claims.md 10' "$E" "$T"     # E:1 T:1 [0 0]
    command grep -c '^t E' "$T"                                                # 86 [84]
    command grep -c -F 'E37-E86 were added' "$T"                               # 1 [0]

After turn 4 (counted on the tree after turn 3, in brackets):

    command grep -c -F 'any(. == 92)' "$E"                                     # 1 [0]
    command grep -c -F 'catch "-"' "$E"                                        # 0 [1]
    command grep -c -F 'u004b for a K' "$E"                                    # 1 [0]
    command grep -c -F 'jq cannot decode is no event' "$E"                     # 0 [1]
    command grep -c -F 'fix-external-agent-claims/review-r1.md C1' "$E" "$T"  # E:1 T:1 [0 0]
    command grep -c -F 'such as base64, is not recognised' README.md           # 1 [0]
    command grep -c -F 't E42 "the first 16 MiB' "$T"                          # 1 [0]
    command grep -c -F 'since a developer is never 8' "$E"                     # 1 [0]
    command grep -c -E '^	leak-(split|two|objkey)\)' "$T"                    # 3 [0]
    command grep -c -F 'for sc in leak-split leak-two leak-objkey' "$T"        # 1 [0]
    command grep -c '^t E' "$T"                                                # 86 [86]

After turn 4, step 4 of this list is three mutants of the turn-4 script
instead, each under the turn-4 test: `[.. | strings, (objects | keys[])]`
to `[.. | strings]` → `NOT OK E86`, `FAIL 1/86`; the catch back to
`catch "-"` → `NOT OK E86`, `FAIL 1/86`; `v[FNR] == "-"` to `!= "k"` →
`PASS 86/86`, accepted (*Coverage*, S5.1).

After turn 5 (counted on the tree after turn 4, in brackets):

    command grep -c -F 'less than twice as long' "$S" "$E"                     # S:0 E:0 [1 1]
    command grep -c -F 'under 1.67 times' "$E"                                 # 0 [1]
    command grep -c -F 'can reach 10 times OUT_BYTES' "$E"                     # 1 [0]
    command grep -c -F 'or 20 times when jq fails (OUT_BYTES)' "$E"            # 1 [0]
    command grep -c -F 'about 160 MiB' "$S"                                    # 1 [0]
    command grep -c -F 'reader decodes - fails fromjson here' "$E"             # 1 [0]
    command grep -c -F 'fix-external-agent-claims/review-r2.md R2-1' "$E"      # 1 [0]
    command grep -c -F 'fix-external-agent-claims/review-r2.md R2-3' "$T"      # 1 [0]
    command grep -c -F 'holds_key*) exit 1' "$T"                               # 1 [0]
    command grep -c -F 'not two lines, or no decoded reply' "$T"               # 1 [0]
    command grep -c -F 'and every line is when jq fails' "$T"                  # 1 [0]
    command grep -c '^t E' "$T"                                                # 86 [86]

After turn 5, step 4 is the same three mutants under the turn-5 test, and
all three must fail: `[.. | strings]` → `NOT OK E86` (leak-objkey),
`FAIL 1/86`; `catch "-"` → `NOT OK E86` (leak-split, leak-two), `FAIL 1/86`;
`!= "k"` → `NOT OK E86`, `FAIL 1/86`.

## Post-conditions

- The ten doc claims: each statement listed in `findings.md` *Scope* now
  says what the code does, in every file of its row; the turn-1 searches
  are the check.
- Claim 13: E85 `ok`, and `NOT OK` against `HEAD`'s script; E54, E60, E64,
  E73 still `ok`.
- Claim 10: E86 `ok`, and `NOT OK` against `HEAD`'s script; E14 and E42
  still `ok` (E42: a flood's `transcript.jsonl` is still at most 16 MiB).
- Claim 3: no code change; the three files say exactly what is not seen.
- Review round 1 (turn 4): a key escaped on a line that is not exactly one
  JSON value is redacted, so `transcript.jsonl` decoded as a stream holds no
  key either (E86 `ok`; `NOT OK` under the object-key and catch mutants); the
  comments, `README.md` and E42's title say what the code does.
- Review round 2 (turn 5): the size bound is stated as the code gives it, 10
  times the cap, 20 when `jq` fails; the depth-limit comment is right; E86
  fails under every one of the three mutants.
- `glab` 0.7.1; the plugin gates as before; `PASS 86/86`.

## Coverage (AGENTS.md *Tests*: a list, not a number)

- S1: no case; the version search in *Verify*.
- S2.1-S2.22: comments and prose, no case (AGENTS.md: the Markdown files
  have no gate); the turn-1 searches.
- S3.1-S3.2: E85 (new: wrong header with a stdout flood, and with a
  timeout); E54 and E73 (wrong header, no flood: still 12), E60 (right
  header, timeout: still 6), E64 (right header, flood: still 7).
- S3.3-S3.4: prose; the turn-2 searches.
- S3.5-S3.8: the stub and E85 themselves; the mutation run in *Verify* 4.
- S4.1 as revised by S5.1: E86 (an escaped key; a key with a quote and a
  backslash; since S5.8 an event split over two lines, two events on one
  line, and the key as an object key, each also checked by decoding the
  whole file as a stream; since S6.5 `leak-split` shown to arrive in two
  lines and decoded in the reply; since S6.6 a `jq` that fails only
  `opencode_raw`'s call, so the fail-closed branch writes every line as
  `{"type":"redacted"}`). E14 and E42 as before. Mutants `[.. | strings]`,
  `catch "-"` and `v[FNR] != "k"` each fail E86.
- S4.2-S4.6: comments and prose; the turn-3 searches.
- S5.2-S5.6: comments, prose and E42's title; the turn-4 searches.
- S5.7-S5.9: the stub scenarios and E86 themselves; the mutants in *Verify*.
- S6.1-S6.4: comments and prose; the turn-5 searches; the bound measured
  in `findings.md`'s revision-3 note is the planner's standalone run.
- S6.5-S6.7: E86 itself; the three mutants in *Verify*.

## Rollback

- During the work, before the commit: after each green turn the manager
  saves the tree's diff, `git -c core.fsmonitor=false diff -- <the turn's
  files> >"$TMPDIR/eac-turn<n>.patch"`. A turn that fails its checks is the
  user's to revert (`glab:external-agents`: revert, commit or re-run nothing
  on that tree without them). With their word: `git restore --source=HEAD
  -- plugins/glab/.claude-plugin/plugin.json
  plugins/glab/skills/external-agents/SKILL.md
  plugins/glab/scripts/external-agent.sh README.md
  tests/external-agent.test.sh`, then `git apply` the last green turn's
  patch. Never `git restore` or `git clean` anything under `plan/`.
- After the commit: `git revert <sha>`. No stored format migrates:
  `{"type":"redacted"}` lines written meanwhile into an agent's
  `transcript.jsonl` stay valid JSON, nothing in the script reads that file,
  and `stop` removes it with the agent.

## Commit

One commit, Conventional Commits, scope `agents`:
`fix(agents): make the external-agent skill say what the script does`, its
body one bullet per claim group (the ten doc claims; claim 13; claim 10;
claim 3 documented, F1). It holds the five files above and
`plan/fix-external-agent-claims/`, every file in it (`claims.md`,
`findings.md`, `plan.md`, `questions.md`, `result.md`, `review-r1.md`, `review-r2.md`).
Never `plan/SESSION-HANDOFF.md`.

## Record

After the push, `glab:manager` Stage 8, at full tier:

- `docs/specs/external-agents.md` — the primary area. *How it works now*:
  the corrected statements, `transcript.jsonl`'s `{"type":"redacted"}`
  events, the sandbox check before cap and timeout, `PASS 86/86`. Its
  stated-as-of line gains `fix-external-agent-claims` lines as of the
  commit (`glab` `0.7.1`). *Known limits*: the bullet **The key in the raw
  transcript** becomes closed by this change; add what stays (other
  encodings, `run/turn.out` until `run/` is removed, F2). *Open follow-ups*:
  `[feature-opencode-worker/follow-ups.md 10]` and `17` move to *Closed*,
  closed by this commit; add `[fix-external-agent-claims/plan.md F1]`, `F2`,
  `F3`, `F4`; `[feature-opencode-worker/follow-ups.md 16]` stays open. The
  source: `[fix-external-agent-claims/claims.md]` (the Codex analyst run of
  2026-10-18, verified by `glab:analyzer`). *Records*: one line naming the
  change and the last commit on `origin/main` that holds the plan folder.
- `docs/specs/marketplace.md` — `glab` `0.7.1`, the gates' `PASS 86/86`, a
  *Records* line.
- `docs/specs/workflow.md` — only the re-read note of
  `[feature-docs-specs/result-SM.md 3]`: `PASS 86/86`, `glab` `0.7.1`, the
  allowlist unchanged.

## Follow-ups (not in this change)

- F1 — A file the git config includes only under a condition that does not
  hold yet (`includeIf "onbranch:…"`, `hasconfig:`) is not digested: a
  developer can write it, and git reads it on the user's next checkout of
  that branch (`findings.md`, run). Fix: digest every target that an
  `include.path` or `includeIf.*.path` names, conditions ignored, each
  resolved against the file that names it, with a case. Security-relevant;
  open.
- F2 — Redaction recognises the key only written out or JSON-escaped; a
  model that reads the key can write it in any other form. `run/turn.out`
  holds an escaped key until `run/` is removed. Accepted: the model can send
  the key out anyway (`SKILL.md` *Its key*); open as a known limit.
- F3 — `AGENTS.md` *One fact* lists E54 and E73 for the Codex sandbox check
  and describes OpenCode's copy without its nested-repository rule; adding
  E85 and "no nested repository" there is the user's call on that file.
- F4 — closed by turn 5: E86 drives the fail-closed branch with a `jq`
  wrapper (S6.6, `review-r2.md` R2-3).

- F5 — jq 1.6's `contains` may stop at a NUL; `$ENV` does not exist in
  jq 1.5, which fails safe (every line redacted); `README.md` names no jq
  version. UNVERIFIED: no older jq is installed here (`review-r1.md`, C
  advisory).
- F6 — closed by turn 5, folded into R2-1: the stated bound is 10 times
  the cap, and 20 times on the fail-closed path (S6.1-S6.3).
- F7 — the skill's range wording (`review-r1.md`, T advisory).
- F8 — no case shows lines without the key kept byte for byte, beyond E42's
  size and last byte (`review-r1.md`, T advisory).
- F9 — `AGENTS.md` *One fact*: name E85 for the Codex sandbox check and
  "never a nested repository" in the copy summary (`review-r1.md`, T
  advisory; the same as F3).

## Not verified

- Revision 3's dry run (2026-10-19): S6.1-S6.7 applied by script to a
  throwaway copy of the working tree after turn 4, every Old block found
  once. Both `AGENTS.md` *Gates* blocks green there: five `rc=0`,
  shellcheck `rc=0`, `PASS 35/35`, `PASS 86/86`, three `✔ Validation
  passed`, `Skills (15)`/`Agents (5)`/`Hooks (1)  SessionStart`, the
  memory-sync line, and the name and grep lines as specified. Mutants under
  the turn-5 test: `!= "k"` → `NOT OK E86`, `FAIL 1/86`; `[.. | strings]`
  → `NOT OK E86` (leak-objkey), `FAIL 1/86`; `catch "-"` → `NOT OK E86`
  (leak-split, leak-two), `FAIL 1/86`. The bound, with the built
  `opencode_raw` run standalone: 1000 lines of a backslash, 2000 bytes, came
  out 20000 bytes; 1000 empty lines, 1000 bytes, came out 1000 bytes with
  `jq` working and 20000 bytes with a `jq` that exits 1.
- UNVERIFIED: that OpenCode's real serializer ever `\u`-escapes a key, or
  what characters a real Go key holds — the analyzer's note; the fix does
  not depend on either.
- The planner's dry run (`findings.md` *Dry run*) applied this plan's Old and
  New blocks mechanically to three throwaway copies of `363c38d`, one per
  turn, and ran the gates there. It is not the developer's turn: the
  manager's *Verify* on the real tree is still the evidence for this change.
- Revision 2's dry run (2026-10-19): S5.1-S5.9 applied by script to a
  throwaway copy of the working tree after turn 3, every Old block found
  once. There: both `AGENTS.md` *Gates* blocks green — five `rc=0`,
  shellcheck `rc=0`, `PASS 35/35`, `PASS 86/86`, three `✔ Validation
  passed`, `Skills (15)`/`Agents (5)`/`Hooks (1)  SessionStart` and the
  memory-sync line, the name and grep lines as specified. Mutants under the
  turn-4 test: object keys dropped → `NOT OK E86` (leak-objkey), `FAIL
  1/86`; catch back to `catch "-"` → `NOT OK E86` (leak-split, leak-two),
  `FAIL 1/86`; `!= "k"` → `PASS 86/86` (accepted, *Coverage*).
- UNVERIFIED: the plugin gates (`claude plugin validate`, `plugin details`)
  on the changed tree — not run by the planner; no component is added or
  removed, so the counts are expected unchanged.
