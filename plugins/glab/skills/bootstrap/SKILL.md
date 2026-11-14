---
name: bootstrap
description: The first thing to run in any glab session — the working agreement, the skills to load, the real gates, the handoff files in plan/handoff/, and the tooling hazards that return success while wrong. Use at session start, after a compaction, when resuming parked work, or when unsure of the operating model.
---

# Bootstrap

Six steps, in order, none optional. The costly mistakes here are setup mistakes: the wrong agreement, a gate that was never the real one, a tool that silently returns nothing.

---

## 1. Read the working agreement, the host file and the constants

Points 1 and 4 of the session-start text say what to read, in which order, and what to do when a file is missing. With no such text — hooks off — read it from `${CLAUDE_PLUGIN_ROOT}/scripts/manager-bootstrap.sh`, for the level of the `glab-level:` line.

Do not skim `AGENTS.md`: every review is held to it. `docs/constants.md` is decided; a plan conforms to it.

## 2. Load the manager of your level, `glab:session-rules` and `glab:security`

Point 2 of the session-start text names the three skills for your level. What skips the pipeline is `glab:session-rules` Rule 1.

## 3. Find the real gates, once

Before dispatching anything, find the repo's own targets — `Makefile`, `package.json` scripts, `justfile`, the CI config — as `glab:security` Rule 3 says, and **write them down in one line you reuse all session**.

**Read what a target does before trusting its name.** In one backend, `make ci` and `make ci-all` ran `tidy` + `download` — no build, no test, no lint. Reporting `ci-all` green would have been a false green, and only the name suggested otherwise.

A repo with no lint or test target: **say so** rather than skip the gate silently.

## 4. Confirm the pipeline

Name your stage in the pipeline of your manager — `glab:project-manager` → *The pipeline*, `glab:product-manager` → *The product pipeline*. Round caps: `glab:session-rules` *Round caps*.

## 5. Pick up the handoff

Before asking the user to re-explain anything, look in `plan/handoff/`. Each file is one manager session's (`glab:session-rules` Rule 2):

- your own file — the one the session-start text names, with `no session id` there the name it gives; after a compaction the file your summary names as yours: after a compaction or a resume it is where you left off;
- each other `<id>.md` that Rule 2's standing approval covers (first line `- status: completed`): remove it without asking;
- every other file under `plan/handoff/` — `in-flight`, no status line, a status not on its first line or of another value — and the legacy `plan/SESSION-HANDOFF.md` of glab 0.14 and earlier: treat it as in-flight; its session may still run, and no file says whether. List its session, slug, stage and `updated` line, and take it over — its state into your file, then the old file removed — only on the user's yes;
- the area specs (`docs/specs/`, or where `AGENTS.md` puts them), the memory index `~/.claude/projects/<project>/memory/MEMORY.md`, and `git log --oneline origin/<branch>..HEAD`.

**A handoff is a point-in-time observation, not live state.** Verify anything load-bearing against the current code first: one asserted a feature switch was off after it had been armed.

## 6. Know the hazards before you trust a result

Each produced a confidently wrong answer in a real session, and each returned success.

**Temp files go where point 4 of the session-start text says.** Facts of one machine live in the host file, not here. On one host `/tmp` was a tmpfs under a per-user quota shared by every agent; filling it killed the session, and growing the tmpfs did not help — the limit was the quota. `host.example.md`, in the `glab-services/skills` repository, records it.

**In Claude Code's Bash tool, `grep` can be a shell function running a bundled ugrep** — `type grep` shows which. They disagree: `-E 'foo[\s]bar'` matched `foo bar` under the function and nothing under GNU grep, where `[\s]` is a literal `\` or `s`; the function has returned **zero matches with no error** for an `-E` pattern beginning with an alternation group, and one difference silently excluded `golang.org/x/tools` from a dependency audit. Use **`command grep`** for anything load-bearing, and match something you *know* exists before trusting a pattern to prove an absence.

**Four more, from one Go and PostgreSQL project** — a receiver name in a Go grep, a truncated query, a cached test result, a capped linter's per-file counts — are in [references/hazards.md](references/hazards.md). Read it before such a count or result reaches a plan.

**`grep -c` exits 1 on zero matches**, which reads as a failed command rather than a true zero.

**A tool that is not installed exits 127 and prints no findings.** Zero findings from a command that never ran is not a clean scan. Check the exit code.

---

## The one-line check

Before your first dispatch, you should be able to say, without looking anything up: **the agreement and constants I read, the gates I will run, the stage I am at, and what the previous session left unfinished.** If any of the four is missing, you have not bootstrapped — go back.
