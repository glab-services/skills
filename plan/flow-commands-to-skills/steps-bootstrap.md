# flow-commands-to-skills — steps for `glab:bootstrap` and the session-start hook

Part of `plan.md` *processing*, run after P1. File boundary: `plugins/glab/skills/bootstrap/SKILL.md` and `plugins/glab/scripts/manager-bootstrap.sh` only. Old texts are as of `5a72155`; line numbers in the headings are for orientation only. The blocks follow `plan.md` *Block formats*, in the order written; each edit's check is its line in the posts block at the end of this file. Recorded cases stay word for word wherever they move. BS5, step 5, stays as it is.

## glab:bootstrap — `plugins/glab/skills/bootstrap/SKILL.md`

### BS1 — step 1, heading and body (A11) — `:15-38`

~~~ BS1 old plugins/glab/skills/bootstrap/SKILL.md
## 1. Read the working agreement and the constants

Read **`AGENTS.md` at the repo root** before anything else — before answering,
before searching, before dispatching.

No `AGENTS.md`? Read `CLAUDE.md` instead, and **say plainly that the repo has no
working agreement**. Then the conventions you enforce are the ones you can read
off the existing code, not ones you invented.

Do not skim it. It is the contract every review is held to, and an agent that
skipped it produces work the repo rejects — which you pay for in a correction
round, not in saved time.

**Then read `~/.claude/host.md`, before the first command** — steps 3 and 5
already run some. It belongs to the machine: where temp files go, which path is
the system `grep`. No `host.md` → say the machine has no host file, then use
`$TMPDIR` if it is set and the session's scratchpad directory otherwise — and
keep temp files few and small, because that fallback may itself sit on a small
`/tmp`. Step 6 says why this matters.

Then read **`docs/constants.md`** — the decided facts every session on this
product builds on: who owns which surface, names, contracts, choices already
made. Only the user changes it. A plan conforms to it and never re-asks it. No
such file? Say so once and carry on; do not write one.
~~~
~~~ BS1 new
## 1. Read the working agreement, the host file and the constants

The session-start text of the `glab` hook gives the order — `AGENTS.md` (or `CLAUDE.md`, said plainly), `docs/constants.md`, `~/.claude/host.md` — and the fallback for each. A session that received no such text — the plugin's hooks off — reads it first from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh`.

Do not skim `AGENTS.md`. It is the contract every review is held to, and an agent that skipped it produces work the repo rejects — which you pay for in a correction round, not in saved time.

Read `host.md` before the first command: steps 3 and 5 already run some, and step 6 says why its temp-file rule matters. `docs/constants.md` holds what is already decided — only the user changes it, and a plan conforms to it and never re-asks it.
~~~

### BS2 — step 2's body (A1, A8, A10, A11, A28, C13, C14) — `:42-72`

It also removes step 2's two `glab:plan-first` references.

~~~ BS2 old plugins/glab/skills/bootstrap/SKILL.md
Both. Always. They are not alternatives.

- **`glab:manager`** — the operating model. You manage; you do not implement. Work
  moves through the pipeline in step 4, each stage dispatched to its own agent.
  Engineering choices are yours to make and record; its Rule 3 names the four
  ask-conditions that go to the user, and the skill names its other escalations
  where they arise.
- **`glab:security`** — evidence and durability. Every claim about your own work is
  backed by a command whose real output you paste, or written
  `UNVERIFIED: <claim> — <why>`.

**Every agent you dispatch reads `AGENTS.md` first and carries both `glab:security`
and `glab:comments` — say all of it, in every dispatch message**, even when the agent
definition already requires it. `glab:comments` is the one that gets dropped, and its
loss is invisible: a `TODO` deleted in passing leaves nothing in the diff saying
it was ever there.

Every dispatch also passes the Agent tool's `effort` parameter at the session's
level — `glab:manager` Rule 0d says where the level comes from and how it is
recorded.

Two more are the manager's call per dispatch rather than automatic — **`glab:audit`**
for an agent producing findings rather than a change, and **`glab:plan-first`** for a
planning agent's document structure. `glab:manager` Rule 0c has the full contract,
including the seam where `glab:plan-first` and `glab:manager` disagree about whether a
planner implements.

`glab:manager` governs *how* work is done, not *whether*. Questions get answered
directly. Trivial changes — roughly five lines, no architectural impact — get
made directly. `glab:security` has **no** such exemption: a one-line change still
gets its claim verified, and a gate is never reported green on an agent's word.
~~~
~~~ BS2 new
Both, always — the session-start text says what each governs, and they are not alternatives. `glab:manager` governs *how* work is done, not *whether*: its Rule 1 exempts questions and trivial changes from the pipeline. `glab:security` exempts nothing.

What reaches each agent is `glab:manager` Rule 0c's: each `glab` agent's definition preloads the skills its role uses, and a dispatch carries only the facts of its task.
~~~

### BS3 — step 3 points at `glab:security` Rule 3 (C15)

The paragraph `:80-82` and the blank line after it go; the `make ci` case (`:84-87`) stays:

~~~ BS3.1 delete plugins/glab/skills/bootstrap/SKILL.md
A command you composed yourself proves nothing about CI. `go test ./somepkg`
when the repo's target is `go test ./... -race` is not the same check, and the
difference is exactly where the race lives.

~~~

~~~ BS3.2 old plugins/glab/skills/bootstrap/SKILL.md
the CI config — and **write them down
~~~
~~~ BS3.2 new
the CI config — as `glab:security` Rule 3 says, and **write them down
~~~

### BS4 — step 4's body (A7, A12, A13, A17) — `:94-126`

~~~ BS4 old plugins/glab/skills/bootstrap/SKILL.md
```
plan ⇄ analyze  →  develop ⇄ analyze  →  integrate  →  review ⇄  →  commit  →  final check  →  push  →  record
```

That is the **full** pipeline, for the changes `glab:manager` → *Pick the tier*
makes full tier; a full-tier plan with no sub-plans
skips the final check, which its conformance check asked.
Normal work runs a one-page plan, a plan check, a review and the final
check, with no conformance stage unless it splits into sub-plans; trivial
work is done directly. Each check stage runs
at most two rounds, a third only on a critical or high finding;
`glab:manager` → *Pick the tier* has the table and the round caps.

- **`plan ⇄ analyze`** — the plan is analyzed *before any code exists*: can this
  be built exactly as written? See `glab:manager` Stage 1b.
- **`develop ⇄ analyze`** — conformance: did we build what the plan said?
  Full tier, and every sub-plan at every tier.
- **`integrate`** — against a real running system, local only, never a live
  endpoint. Skip only when the change cannot be exercised at runtime, and say
  you are skipping it and why.
- **`review ⇄`** — an external auditor gets the target and nothing else. Not the
  slug, not the plan, not what it was supposed to do.
- **`commit`**, **`final check`**, then **`push`** — one commit per sub-plan;
  the final check compares everything committed with the user's request in
  `master.md` (`glab:manager` Stage 6b); push waits for the user's explicit
  go-ahead, every time.
- **`record`** — after the push, what stays true goes into the area spec, in a
  docs commit of its own (`glab:manager` Stage 8); the plan folder stays unless
  the repo's `AGENTS.md` says otherwise.

**Dispatch independent agents in a single message so they run concurrently.**
Analyze and review fan out freely by surface or dimension; develop splits only
across disjoint file boundaries. See `glab:manager` → *Running agents in parallel*.
~~~
~~~ BS4 new
Name the stage you are at in `glab:manager` → *The pipeline*; *Pick the tier* says which stages run and how many rounds each gets. Dispatch independent agents in a single message (`glab:manager` → *Running agents in parallel*).
~~~

### BS6 — step 6 (B10, C6, C16; R6)

The temp-file sentence, across its line break (`:154-155`):

~~~ BS6.1 old plugins/glab/skills/bootstrap/SKILL.md
not in this skill. Say its temp-file rule in every dispatch message so
subagents follow it too, use unique filenames, and clean up what you create.
~~~
~~~ BS6.1 new
not in this skill. Name its temp directory in every dispatch message — a value
the agent cannot see — use unique filenames, and clean up what you create.
~~~

The cache sentence, across its line breaks (`:191-192`):

~~~ BS6.2 old plugins/glab/skills/bootstrap/SKILL.md
the old server. Re-run with `-count=1` after any dependency or infrastructure
change.
~~~
~~~ BS6.2 new
the old server. What the cache hides, and what `-count` does about it, is
`glab:security` Rule 4.
~~~

The secrets paragraph and the blank line after it go (`:208-215`); its case moves to `glab:security` (`steps-shared.md` SE4):

~~~ BS6.3 delete plugins/glab/skills/bootstrap/SKILL.md
**Secrets never enter output — and say so in every dispatch, not only the ones
you expect to touch config.** Not logs, not error messages, not commit messages,
not a URL you print. A brief that omits this is how the same credential leaks a
third time: an agent enumerating config for an unrelated reason redacted by key
name and printed a DSN's embedded password. A DSN carries a password in the middle of a
value, not only after an `@` — two different redaction attempts leaked one.
Do not print config values at all; test them instead.

~~~

## The session-start hook — `plugins/glab/scripts/manager-bootstrap.sh`

### H1 — the text between `read -r -d '' CTX <<'CTX_EOF'` and `CTX_EOF` (A1, A7, A10, A11, C13, C14) — `:12-24`

Nothing else in the script changes: the header comment, `jq`, the `printf` fallback and `exit 0` stay.

~~~ H1 old plugins/glab/scripts/manager-bootstrap.sh
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement. Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.

2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:
   - `glab:manager` — the operating model. Work moves through plan -> develop -> analyze -> integrate -> review -> commit -> final check -> push -> record, as far as the tier runs them (`glab:manager` -> *Pick the tier* says which), each stage dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Every agent you dispatch reads `AGENTS.md` first AND carries the `glab:security` and `glab:comments` disciplines. Say all of it in the dispatch message. See `glab:manager` Rule 0c for the full list and for which skills are your call per dispatch. Pass the Agent tool's `effort` parameter on every dispatch, at the session's level (`glab:manager` Rule 0d).

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, repeat its temp-file rule in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 1 has the read; step 6 explains why this matters.

`glab:manager` governs HOW work is done, not whether: questions are answered directly, and trivial changes (~5 lines, no architectural impact) are made directly — the skill says so itself. `glab:security` does not have that exemption. A trivial change still gets its claim verified, and a gate is never reported green on an agent's word.
~~~
~~~ H1 new
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement. Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.

2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:
   - `glab:manager` — the operating model. Each stage of its pipeline (`glab:manager` -> *The pipeline*, as far as *Pick the tier* runs it) is dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Each `glab` agent loads its own rules: `AGENTS.md` in its own first step, and the `glab` skills its role uses from its definition. A dispatch carries only the facts of its task (`glab:manager` Rule 0c) and passes the Agent tool's `effort` parameter at the session's level (`glab:manager` Rule 0d).

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, name its temp directory in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 6 explains why this matters.

Questions and trivial changes skip the pipeline (`glab:manager` Rule 1); nothing skips `glab:security`. A trivial change still gets its claim verified, and a gate is never reported green on an agent's word.
~~~

## Posts

~~~ posts
BS1 | 1 | /usr/bin/grep -c -x -F '## 1. Read the working agreement, the host file and the constants' plugins/glab/skills/bootstrap/SKILL.md
BS1 | 1 | /usr/bin/grep -c -F 'CLAUDE_PLUGIN_ROOT' plugins/glab/skills/bootstrap/SKILL.md
BS2 | 0 | /usr/bin/grep -c -F 'say all of it, in every dispatch' plugins/glab/skills/bootstrap/SKILL.md
BS2 | 0 | /usr/bin/grep -c -F 'plan-first' plugins/glab/skills/bootstrap/SKILL.md
BS3.1 | 0 | /usr/bin/grep -c -F 'composed yourself' plugins/glab/skills/bootstrap/SKILL.md
BS3.2 | 1 | /usr/bin/grep -c -F 'as `glab:security` Rule 3 says, and' plugins/glab/skills/bootstrap/SKILL.md
BS4 | 0 | /usr/bin/grep -c -E '^plan ⇄ analyze' plugins/glab/skills/bootstrap/SKILL.md
BS4 | 1 | /usr/bin/grep -c -F 'Name the stage you are at in' plugins/glab/skills/bootstrap/SKILL.md
BS6.1 | 1 | /usr/bin/grep -c -F 'Name its temp directory in every dispatch message' plugins/glab/skills/bootstrap/SKILL.md
BS6.2 | 1 | /usr/bin/grep -c -F 'What the cache hides, and what `-count` does about it' plugins/glab/skills/bootstrap/SKILL.md
BS6.3 | 0 | /usr/bin/grep -c -F 'embedded password' plugins/glab/skills/bootstrap/SKILL.md
H1 | rc=0 | diff <(awk '$1=="~~~" && $2=="H1" && $3=="new"{f=1;next} f && $0=="~~~"{f=0} f' plan/flow-commands-to-skills/steps-bootstrap.md) <(bash plugins/glab/scripts/manager-bootstrap.sh | jq -r .hookSpecificOutput.additionalContext); echo "rc=$?"
~~~
