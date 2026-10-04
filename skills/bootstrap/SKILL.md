---
name: bootstrap
description: The first thing to run in any session on this machine — establishes the working agreement, loads the manager and security skills, finds the repo's real gate commands, picks up any handoff left by a previous session, and states the tooling hazards that have already produced wrong answers here. Use at session start, after a context compaction, when resuming parked work, or whenever you are unsure what the operating model for this session is.
---

# Bootstrap

Six steps, in order. None is optional, and none takes long. Their whole purpose
is that the expensive mistakes in this environment are all *setup* mistakes —
work dispatched under the wrong agreement, a gate that was never the real gate,
a claim proven with a tool that silently returns nothing.

---

## 1. Read the working agreement

Read **`AGENTS.md` at the repo root** before anything else — before answering,
before searching, before dispatching.

No `AGENTS.md`? Read `CLAUDE.md` instead, and **say plainly that the repo has no
working agreement**. Then the conventions you enforce are the ones you can read
off the existing code, not ones you invented.

Do not skim it. It is the contract every review is held to, and an agent that
skipped it produces work the repo rejects — which you pay for in a correction
round, not in saved time.

## 2. Load `manager` and `security`

Both. Always. They are not alternatives.

- **`manager`** — the operating model. You manage; you do not implement. Work
  moves through the pipeline in step 4, each stage dispatched to its own agent.
- **`security`** — evidence and durability. Every claim about your own work is
  backed by a command whose real output you paste, or written
  `UNVERIFIED: <claim> — <why>`.

**Every agent you dispatch reads `AGENTS.md` first and carries both `security`
and `comments` — say all of it, in every dispatch message**, even when the agent
definition already requires it. `comments` is the one that gets dropped, and its
loss is invisible: a `TODO` deleted in passing leaves nothing in the diff saying
it was ever there.

Two more are the manager's call per dispatch rather than automatic — **`audit`**
for an agent producing findings rather than a change, and **`plan-first`** for a
planning agent's document structure. `manager` Rule 0c has the full contract,
including the seam where `plan-first` and `manager` disagree about whether a
planner implements.

`manager` governs *how* work is done, not *whether*. Questions get answered
directly. Trivial changes — roughly five lines, no architectural impact — get
made directly. `security` has **no** such exemption: a one-line change still
gets its claim verified, and a gate is never reported green on an agent's word.

## 3. Find the real gates, once

Before dispatching anything, find the repo's own targets — `Makefile`,
`package.json` scripts, `justfile`, the CI config — and **write them down in one
line you reuse all session**.

A command you composed yourself proves nothing about CI. `go test ./somepkg`
when the repo's target is `go test ./... -race` is not the same check, and the
difference is exactly where the race lives.

**Read what a target actually does before trusting its name.** In this backend,
`make ci` and `make ci-all` run `tidy` + `download` — no build, no test, no lint.
Reporting `ci-all` green as a verification gate would be a false green, and the
name is the only thing suggesting otherwise.

If a repo has no lint target or no test target, **say so** rather than skipping
the gate silently.

## 4. Confirm the pipeline

```
plan ⇄ analyze  →  develop ⇄ analyze  →  integrate  →  review ⇄  →  commit  →  push
```

- **`plan ⇄ analyze`** — the plan is analyzed *before any code exists*: can this
  be built exactly as written? See `manager` Stage 1b.
- **`develop ⇄ analyze`** — conformance: did we build what the plan said? Max 4
  rounds.
- **`integrate`** — against a real running system, local only, never a live
  endpoint. Skip only when the change cannot be exercised at runtime, and say
  you are skipping it and why.
- **`review ⇄`** — an external auditor gets the target and nothing else. Not the
  slug, not the plan, not what it was supposed to do. Max 3 rounds.
- **`commit`**, then **`push`** — push waits for the user's explicit go-ahead,
  every time.

**Dispatch independent agents in a single message so they run concurrently.**
Analyze and review fan out freely by surface or dimension; develop splits only
across disjoint file boundaries. See `manager` → *Running agents in parallel*.

## 5. Pick up the handoff

A previous session may have left one. Look for it before asking the user to
re-explain anything:

- `plan/SESSION-HANDOFF.md`, or the nearest equivalent in `plan/`
- the memory index at
  `~/.claude/projects/<project>/memory/MEMORY.md`
- `git log --oneline origin/<branch>..HEAD` — unpushed commits are work in
  progress, and their messages say what it was

**Treat a handoff as a point-in-time observation, not live state.** It was true
when written. Verify anything load-bearing against the current code before
acting on it — a handoff in this repo asserted two feature switches were off
while one had since been armed, which would have misled a cold reader into
thinking the enforcement path was inert.

## 6. Know the hazards before you trust a result

Each of these produced a confidently wrong answer on this machine. They are
listed because none of them announces itself — every one returns success.

**Temp files go in `/data/tmp/claude`, never `/tmp`** — `/data` is a dedicated disk. `/tmp` here is a tmpfs
under a **per-user quota shared by every agent**. Exhausting it returns `EDQUOT`
on every write and takes the Bash tool down with it — the harness writes its own
task output under `/tmp/claude-1000/`, so a full `/tmp` is not a slow session,
it is a dead one, and it cannot be repaired from inside that session. Growing
the tmpfs does not help: `size=` is the filesystem, `usrquota` is the per-user
cut of it. `export TMPDIR=/data/tmp/claude` before any `go` command, use unique
filenames, clean up what you create, **and say all of this in every dispatch
message** so subagents do the same.

**`grep` is ugrep, not GNU grep.** It returns **zero matches with no error** for
`-E` patterns beginning with an alternation group, and `\s` inside a bracket
expression means the literal `\` and `s` — which silently excluded
`golang.org/x/tools` from a dependency audit. Use **`/usr/bin/grep`** for
anything load-bearing, and confirm a pattern matches something you *know* exists
before trusting it to prove an absence.

**A receiver name in a Go grep silently undercounts.** `func (rcv *Route)` and
`func (r *Route)` are the same method set; a pattern naming one finds a fraction
of the other. This produced three wrong counts in one workstream — 335 RPC
handlers that were 431, 462 gin handlers that were 547 — and each reached a plan
document as a measured fact. Match the receiver as `[a-zA-Z]*` — with a
star, not a plus, because **an anonymous receiver makes `+` return zero**, and a
silent zero is worse than a wrong number: all 109 `TableName` methods in that
same repo have anonymous receivers, so the obvious fix found none of them. When a
count is load-bearing, break it down by receiver and confirm the parts sum to the
whole.

**Never conclude from a truncated query.** A `psql | head -8` cut 16 constraint
rows to 6 and produced a confident "this column has no foreign key" that reached
a plan document as fact. It had five.

**A cached test result is not evidence.** `make gotest` reported green with
`(cached)` after a database major-version change — it had reused a result from
the old server. Re-run with `-count=1` after any dependency or infrastructure
change.

**A capped linter's per-file counts are not reproducible.** With a
`max-same-issues` cap, which files absorb a capped linter's findings varies
between runs on an unchanged tree — so a per-package or per-file comparison is
noise, while the **repo-wide total is stable**. Measured here: three runs of one
command on one tree moved a package from 5 findings to 11 to 30 with the total
fixed at 717. Compare totals, and treat any per-file "delta 0" as luck until the
same run reproduces it.

**`grep -c` exits 1 on zero matches**, which reads as a failed command rather
than a true zero.

**A tool that is not installed exits 127 and prints no findings.** Zero findings
from a command that never ran is not a clean scan. Check the exit code.

**Secrets never enter output — and say so in every dispatch, not only the ones
you expect to touch config.** Not logs, not error messages, not commit messages,
not a URL you print. A brief that omits this is how the same credential leaks a
third time: an agent enumerating config for an unrelated reason redacted by key
name and printed a DSN's embedded password. A DSN carries a password in the middle of a
value, not only after an `@` — two different redaction attempts leaked one here.
Do not print config values at all; test them instead.

---

## The one-line check

Before your first dispatch, you should be able to say, without looking anything
up: **the agreement I read, the gates I will run, the stage I am at, and what
the previous session left unfinished.** If any of the four is missing, you have
not bootstrapped — go back.
