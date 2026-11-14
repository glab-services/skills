---
name: bootstrap
description: The first thing to run in any session — establishes the working agreement, loads the manager of the session's level, glab:session-rules and glab:security, finds the repo's real gate commands, picks up any handoff left by a previous session, and states the tooling hazards that have already produced wrong answers. Use at session start, after a context compaction, when resuming parked work, or whenever you are unsure what the operating model for this session is.
---

# Bootstrap

Six steps, in order. None is optional, and none takes long. Their whole purpose
is that the expensive mistakes in this environment are all *setup* mistakes —
work dispatched under the wrong agreement, a gate that was never the real gate,
a claim proven with a tool that silently returns nothing.

---

## 1. Read the working agreement, the host file and the constants

The session-start text of the `glab` hook, points 1 and 4, says what to read and in which order, and what to do when a file is missing. A session that received no such text — the plugin's hooks off — reads it first from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh`, and takes the text for the level its `AGENTS.md` line `glab-level:` names — the project level when there is none.

Do not skim `AGENTS.md`. It is the contract every review is held to, and an agent that skipped it produces work the repo rejects — which you pay for in a correction round, not in saved time.

The host file comes that early because steps 3 and 5 already run commands, and step 6 says why its temp-file rule matters. `docs/constants.md` holds what is already decided — only the user changes it, and a plan conforms to it and never re-asks it.

## 2. Load the manager of your level, `glab:session-rules` and `glab:security`

All three, always — the session-start text names the manager of your level, `glab:project-manager` at the project level, `glab:product-manager` at the product level. That manager governs *how* work is done at its level, not *whether*: `glab:session-rules` Rule 1 says what skips the pipeline, and what still holds when it does.

What reaches each agent is `glab:session-rules` Rule 0c's: each `glab` agent's definition preloads the skills its role uses, and a dispatch carries only the facts of its task.

## 3. Find the real gates, once

Before dispatching anything, find the repo's own targets — `Makefile`,
`package.json` scripts, `justfile`, the CI config — as `glab:security` Rule 3 says, and **write them down in one
line you reuse all session**.

**Read what a target actually does before trusting its name.** In one backend,
`make ci` and `make ci-all` run `tidy` + `download` — no build, no test, no lint.
Reporting `ci-all` green as a verification gate would be a false green, and the
name is the only thing suggesting otherwise.

If a repo has no lint target or no test target, **say so** rather than skipping
the gate silently.

## 4. Confirm the pipeline

Name the stage you are at in the pipeline of the manager of your level — `glab:project-manager` → *The pipeline* at the project level, `glab:product-manager` → *The product pipeline* at the product level. `glab:session-rules` *Round caps* says how many rounds a stage gets, and at the project level `glab:project-manager` *Pick the tier* says which stages run and `glab:project-manager` → *Running agents in parallel* how to fan out. Dispatch independent agents in a single message.

## 5. Pick up the handoff

A previous session may have left one. Look for it before asking the user to
re-explain anything:

- `plan/SESSION-HANDOFF.md`, or the nearest equivalent in `plan/`
- the area specs — `docs/specs/`, or where `AGENTS.md` puts them: what a
  finished change left open is there, not in `plan/`
- the memory index at
  `~/.claude/projects/<project>/memory/MEMORY.md`
- `git log --oneline origin/<branch>..HEAD` — unpushed commits are work in
  progress, and their messages say what it was

**Treat a handoff as a point-in-time observation, not live state.** It was true
when written. Verify anything load-bearing against the current code before
acting on it — a handoff in one repo asserted two feature switches were off
while one had since been armed, which would have misled a cold reader into
thinking the enforcement path was inert.

## 6. Know the hazards before you trust a result

Each of these produced a confidently wrong answer in a real session. They are
listed because none of them announces itself — every one returns success.

**Temp files go where the session-start text, point 4, says.** Facts true of one
machine — where temp files go, which path is the system `grep` — live in the
host file, not in this skill. Why this is a hazard at all: on one host `/tmp` was a tmpfs under a per-user quota shared
by every agent, and filling it killed the session from the inside. Growing the
tmpfs did not help: the limit was that quota, not the size of the filesystem.
The template the host file is made from, `host.example.md` at the root of the `glab-services/skills` marketplace repository, records that case
in full; the rule above does not depend on your having it.

**In Claude Code's Bash tool, `grep` can be a shell function that runs a bundled ugrep, not the system grep** —
`type grep` shows which. The two do not agree. `-E 'foo[\s]bar'` matched
`foo bar` under the function and nothing under GNU grep, where `\s` inside a
bracket expression means the literal `\` and `s`. The function has also been
observed returning **zero matches with no error** for an `-E` pattern
beginning with an alternation group. One of these differences silently
excluded `golang.org/x/tools` from a dependency audit. Use **`command grep`**,
which bypasses the function, for anything load-bearing, and confirm a pattern
matches something you *know* exists before trusting it to prove an absence.

*The next four come from one Go and PostgreSQL project. The trap in each is general; the commands are that project's.*

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
the old server. What the cache hides, and what `-count` does about it, is
`glab:security` Rule 4.

**A capped linter's per-file counts are not reproducible.** With a
`max-same-issues` cap, which files absorb a capped linter's findings varies
between runs on an unchanged tree — so a per-package or per-file comparison is
noise, while the **repo-wide total is stable**. Measured in one repo: three runs of one
command on one tree moved a package from 5 findings to 11 to 30 with the total
fixed at 717. Compare totals, and treat any per-file "delta 0" as luck until the
same run reproduces it.

**`grep -c` exits 1 on zero matches**, which reads as a failed command rather
than a true zero.

**A tool that is not installed exits 127 and prints no findings.** Zero findings
from a command that never ran is not a clean scan. Check the exit code.

---

## The one-line check

Before your first dispatch, you should be able to say, without looking anything
up: **the agreement and constants I read, the gates I will run, the stage I am
at, and what the previous session left unfinished.** If any of the four is
missing, you have not bootstrapped — go back.
