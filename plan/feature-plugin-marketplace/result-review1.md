# Result — feature-plugin-marketplace, review round 1

Built 2026-10-05 on `main` at `2aeb46d`, on top of Slices M, G, S and D.
Nothing staged, committed or pushed. Nothing under `~/.claude` was written.
These are review-forced changes outside the plan; `plan.md` is not edited.

**Verdict: BUILT.** All nine findings are fixed and every gate is green.
Four plan checks now print something other than the plan's *finished* value;
each is the direct result of a finding and is listed under *Check deltas*.

## Findings

| # | State | Before | After |
|---|---|---|---|
| 1 | fixed | README had no migration text | new section `## Coming from the copy install`, `README.md:93-129` |
| 2 | fixed | `AGENTS.md:24` `bash -n "$s"; test -x "$s"; echo …` | `AGENTS.md:24` `bash -n "$s" && test -x "$s"; echo …`; reason added at `:29-32` |
| 3 | fixed | `AGENTS.md:38-43` called the literal `claude` | `AGENTS.md:41` resolves `${CLAUDE_BIN:-claude}` and stops when it is not found; `:44-46` call `"$claude"`; sentence at `:35-36`; explanation at `:53-57`. `host.example.md:29-31` says to export `CLAUDE_BIN` (it already carried the placeholder; still a placeholder) |
| 4 | fixed, sentences confirmed | `README.md:58-62` gave no source | `README.md:64-67` cites the docs page and says neither statement was tried here |
| 5 | fixed | three shared facts not listed; hedge gate covered two files | `AGENTS.md:115-123` lists the 20-second hook timeout, the cap of 17, and the 1.5-second budget with its hedged override; gate line `:50` and green bullet `:66` now cover `README.md` too (three counts) |
| 6 | fixed | `README.md:42` "**Create `~/.claude/host.md` …**" for everyone | `README.md:42-47` "**If you install `glab`, create …**", says where `host.example.md` is and that `memory-sync` does not read it |
| 7 | fixed | `SKILL.md:12`, one paragraph | `plugins/memory-sync/skills/sync-memory/SKILL.md:12-25`: a numbered list of five; step 4 (`:22`) is new and says what the plugin root is and where to put it |
| 8 | fixed | `SKILL.md:65-67` "`/plugin` should list `memory-sync` as enabled" | `SKILL.md:78-80`: the `jq` shows what ships; the agent asks the user to open `/plugin` and confirm |
| 9 | fixed | `plugins/glab/skills/bootstrap/SKILL.md:131` | same line, pointer now says where the template is — exact diff under *Check deltas*, P17 |

Finding 3, how it stops: the first line of the block is

    claude=$(command -v "${CLAUDE_BIN:-claude}"); : "${claude:?no Claude Code CLI found - set CLAUDE_BIN to the path your host file names}"

the same `:?` idiom the block already used for `TMPDIR`. Run as a script or
through a `bash -c`, it ends the shell there. Typed into an interactive shell
it aborts that line only, and the following lines would still run — the same
limit the `TMPDIR` guard has always had.

Finding 4: the page was fetched with `curl` (`http=200`, 38182 bytes). Both
sentences are there now — line 151, "If a user sets `GITHUB_TOKEN` or another
provider token in the environment, that alone doesn't authenticate the
background check. A token takes effect through a credential helper, such as
the `gh` CLI's helper, which reads `GH_TOKEN` and `GITHUB_TOKEN`."; line 175,
"Background auto-update is off for your marketplace by default". Line 135 also
carries "uses the user's configured git credential helpers and never prompts".

Finding 7: the required strings each still occur in the skill —
`do not run it as written`, `has not been checked on an installed plugin`,
`list them and ask the user which to use; do not choose one yourself`,
`.orphaned_at`, the full `find` command, and the ban on a `memory-sync.sh`
lying directly in the config directory. Counts printed: `1 1 1 1 1 1 1 1`.
Step 4 describes the placeholder in words. Writing it out would have had
Claude Code substitute it, and would have moved P8's count.

## Unplanned changes

- `host.example.md:29-31` — three lines, allowed by finding 3 on the condition
  that the placeholder was already there. It was.
- `AGENTS.md:29-32` and `:53-57` — the prose that explains the two changed
  gate lines was updated with them; the old text described the old lines.
- No plugin `version` was raised. Both are `0.1.0` and have never been
  committed or released, so there is no installed copy to move.

## Gates

`claude` is not on `PATH` here. `CLAUDE_BIN` pointed at a wrapper in a temp
directory that logged each call and then ran the real binary (found with
`readlink /proc/$PPID/exe`).

**Full block as written, `TMPDIR=/data/tmp/claude`, `CLAUDE_BIN` set** — block rc=0:

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    ... 35 lines `ok` ...
    PASS 35/35
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
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
    --- calls=5 distinct cfg=1 all under TMPDIR=5 left=0

**Plugin block, `TMPDIR` unset, recording wrapper as `CLAUDE_BIN`:**

    <tmp>/gate2.sh: line 2: TMPDIR: parameter null or not set
    <tmp>/gate2.sh: line 7: cfg: parameter null or not set
    block rc=1
    --- calls=0
    --- after positive control calls=1

**Plugin block, `CLAUDE_BIN` unset, `claude` not on `PATH`:**

    claude: not on PATH
    <tmp>/gate2.sh: line 1: claude: no Claude Code CLI found - set CLAUDE_BIN to the path your host file names
    block rc=1
    left=0

Nothing after line 1 was printed.

**Finding 2 proofs** (throwaway files; `bad.sh` holds only `if true; then`
and is executable, `noexec.sh` is valid and not executable):

    <tmp>/bad.sh: line 2: syntax error: unexpected end of file from `if' command on line 1
    bad.sh new rc=2
    noexec.sh new rc=1
    good.sh new rc=0
    bad.sh old form rc=0

**README rollout JSON** — `jq rc=0`, same object as before.

`UNVERIFIED: the five real CLI calls wrote nothing under ~/.claude — not
measured directly; every call had CLAUDE_CONFIG_DIR set to the one throwaway
directory.`

## Check deltas (P1–P17)

Only these four differ from the plan's *finished* values. P1, P2, P4–P8,
P10–P14 and P16 print exactly what the plan records (P14 is still `0` and
fourteen `1`s; P8's skill count is still 4).

| Check | Plan | Now | Cause |
|---|---|---|---|
| P3, second list | `AGENTS.md 2` | `AGENTS.md 3` | finding 5: the new known case names `` `memory-sync:sync-memory` `` |
| P9 | `README.md:0` | `README.md:1` | finding 1: `README.md:121` tells the user what to remove from `~/.claude/CLAUDE.md` |
| P15, 10th count | `1` | `0` | finding 6: the sentence now begins "If you install `glab`, create", so the fixed string with a capital "Create" no longer matches. The other seventeen are `1` |
| P17 | `20 identical` | `DIFFERS plugins/glab/skills/bootstrap/SKILL.md`, `19 identical` | finding 9, one line |

P17, the whole difference between HEAD's file and the built one with the
prefix stripped:

    131c131
    < The template the host file is made from, `host.example.md`, records that case
    ---
    > The template the host file is made from, `host.example.md` at the root of the `glab-services/skills` marketplace repository, records that case

## Old-install mentions

Search of `README.md`, `AGENTS.md` and `plugins/` for `cp -a`, `Installed to`,
`~/.claude/{skills,agents,commands,memory-sync.sh,manager-bootstrap.sh,CLAUDE.md}`,
`copy install`, `copied`:

| Hit | What it is |
|---|---|
| `README.md:93`, `:95`, `:108`, `:121` | the new migration section |
| `AGENTS.md:92` | the standing rule that no agent copies into `~/.claude` — current |
| `plugins/memory-sync/scripts/memory-sync.sh:56` | unrelated: a comment about the stage copy |

Also about the old install, found by reading rather than by that search, and
current, not stale: `sync-memory/SKILL.md:23` (the ban on a `memory-sync.sh`
directly in the config directory) and `:81` (an old `settings.json` entry
makes every sync run twice). No stale hit.

## Blast radius

- **A user with the old copy install** now has the steps to remove it by
  hand. The section removes only named files; it tells them to keep the `env`
  block, `host.md` and the `.memory-sync-*` files.
- **Every agent running the gates:** a syntax error in a script now shows a
  non-zero `rc`. On a host without `claude` on `PATH` the plugin block stops
  until `CLAUDE_BIN` is exported. The hedge gate prints three counts.
- **An agent using the sync skill** no longer claims the hooks are live from
  the plugin's own file; it asks the user. With an unfilled placeholder it
  now knows the plugin root as well as the script path.
- **Rollback:** these edits are unstaged changes in five tracked files and
  cannot be backed out separately from the slices they sit on, other than by
  hand; the plan's per-slice back-out commands take them along.

## Follow-ups

1. `plan.md` records values that no longer hold: P3 (`AGENTS.md 2`), P9
   (`README.md:0`), P15 (10th string), P17 (`20 identical`). Whoever owns the
   plan decides whether to amend the checks.
2. `follow-ups.md` still does not exist; the four items in
   `result-slice-D.md` are still open, except the hedge gate, which is green.
3. The `:?` guards stop a script, not an interactive shell.
