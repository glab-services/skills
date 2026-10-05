# Questions — bug-reviewer-findings

All open. `plan.md` is not written until these are answered (plan-first step 2).
Evidence and line references are in `findings.md`. Recommendations are the
planner's judgment (inferred), not decisions.

---

## Q1 — Do the fixes go back to the live copies in `~/.claude`, and how?

**Problem.** The repo is a byte-identical mirror of `~/.claude` (one file
differs, by the bucket placeholder). The hooks run `~/.claude/memory-sync.sh`,
not the repo's. A fix that lands only in the repo changes nothing on the
machine that has the bugs, and the two copies start to drift.

**Why it blocks.** It decides whether the plan has an install step, whether
`.gitignore` matters, whether the `<bucket>` placeholder survives, and what
"verified" means for the script (repo copy under a stub vs the live hook).

- **a. Repo only.** Smallest plan. Live bugs remain until the user copies by
  hand; drift is invisible.
- **b. Repo, then a documented manual `cp` (README's existing line), run by the
  user.** No new machinery. The copy overwrites the live sync-memory skill with
  the `<bucket>` placeholder, which is harmless (it is prose) but loses the
  local value.
- **c. Add an `install.sh` that copies and reports a diff first.** One more
  script to gate and maintain; makes drift checkable (`install.sh --check`).
- **d. Symlink `~/.claude/{skills,agents,commands,…}` into the clone.** No
  drift ever, but the working tree becomes live config: a half-edited file is
  in force immediately, and runtime files need `.gitignore`.

**Recommended: b now, c as a follow-up.** Nothing in this change is applied to
`~/.claude` by an agent; the user runs the copy after review.

---

## Q2 — Deletion semantics for memories

**Problem.** A memory deleted locally comes back on the next pull, for two
proven, independent reasons: push never deletes the remote object, and the
persistent stage copy re-supplies it even when the remote object is gone
(findings A1). With several machines, each other machine also still holds the
file and can push it back.

**Why it blocks.** This is delete/rollback semantics on a store holding the
user's data — the plan cannot prescribe a shape by assumption. It also decides
whether the comment at `memory-sync.sh:63-64` and the "never deletes" promise
in the skill (`:25-26`) are rewritten or kept.

- **a. Tombstones.** A delete writes a marker (e.g. `<file>.deleted`) that is
  synced; pull removes the local file and stage copy when a tombstone is newer.
  Correct across machines, never needs `--delete`, bucket versioning keeps the
  content. Cost: most code, a new on-disk format (needs dual-read thinking),
  and something must *create* the tombstone — Claude deleting a memory with
  `rm` will not.
- **b. Explicit `delete <path>` subcommand.** Removes local, stage and remote
  object in one deliberate act; with versioning the remote delete is a delete
  marker and recoverable. Small, explicit, no auto-deletion. Does not stop
  another machine that still has the file from re-pushing it, and a plain `rm`
  still resurrects.
- **c. Mirror-delete (`--delete` on push, pruned stage).** Deletions just work
  on one machine. Reverses the script's stated guard: a half-written or
  freshly-installed empty local tree wipes the remote, and a new machine's
  first push deletes everything it has not pulled yet. Recoverable only if
  versioning really is on, which is unverified.
- **d. Document only.** State that deletion is not supported and how to remove
  an object by hand. No code risk; the MAJOR finding stays open.

**Recommended: b**, plus pruning the stage of files absent from the remote
listing so the stage alone can no longer resurrect, plus a documented
multi-machine caveat. Tombstones (a) as a follow-up if multi-machine deletes
matter in practice.

Sub-question the answer needs: **is bucket versioning actually enabled on the
real bucket?** The skill asserts it; nothing here verified it, and b/c lean on
it for recovery.

---

## Q3 — Canonical review round cap: 3 or 4

**Problem.** `agents/reviewer.md:90,92,98` and `commands/ship.md:32` say four;
`skills/manager/SKILL.md:102,297` and `skills/bootstrap/SKILL.md:87` say three,
and `manager:148` ("there is no `review4`") implies three.

**Why it blocks.** The reviewer must give a terminal verdict "at round N"; with
the manager counting to 3 and the reviewer to 4, the manager stops a round
before the reviewer believes it must decide, so the forced
`SHIP / SCOPE CUT / DO NOT PUBLISH` verdict never fires.

- **a. Three everywhere.** Edits `reviewer.md` (3 lines) and `ship.md`. Matches
  the manager, which is the orchestrator and the newer text.
- **b. Four everywhere.** Edits `manager` (`:102`, `:148`, `:297`) and
  `bootstrap:87`. Matches develop⇄analyze's cap of 4.
- **c. Remove the number from the agent and command; the caller passes
  `round n/max`.** One source of truth (`manager`), but `/ship` and a direct
  `/review` then have no cap unless they state one.

**Recommended: a**, with `ship.md` naming the same number so the standalone
path is still capped.

---

## Q4 — Machine-specific text: generalise in place, or split into a per-host file

**Problem.** `CLAUDE.md`, `bootstrap`, and several agents state one machine's
paths (`/data/tmp/claude`, `/tmp/claude-1000/` — wrong even here, uid is 1001),
one project's internals as "this repo", and Go-specific hazards as universal
(findings §5). Each item is also a recorded lesson, which the `comments` rule
says must not be silently deleted.

**Why it blocks.** It decides whether lessons are reworded, moved or dropped,
and whether a new file and a new read step in `bootstrap` exist.

- **a. Generalise in place.** State the principle ("put temp files where the
  host says; never fill a quota'd `/tmp`"), keep each incident as an example
  attributed to "one project". No new file. The user's own machine loses its
  hard mandate unless it is restated somewhere.
- **b. Split: generic text in the repo, host facts in an unshipped
  `~/.claude/host.md` that `bootstrap` reads if present; ship a
  `host.example.md`.** Keeps the mandate in force on this machine and out of
  everyone else's. One more file and one more session-start read; CLAUDE.md's
  "irreducible minimum" bullet for temp files must point at it.
- **c. Leave as is; README already warns.** No work; the reviewer finding
  stays, and the wrong uid path stays.

**Recommended: b.** Go/psql/linter hazards stay in `bootstrap` reworded as
language-tagged examples; the anecdotes in `manager:183-219` are already
generic and stay untouched.

Sub-question: `skills/manager/SKILL.md:263-265` (no hand-written mocks,
generator directive, ≥95% coverage "stated in every dispatch") — is that a
universal rule of yours, or one project's policy that should defer to the
repo's own agreement?

---

## Q5 — Root `CLAUDE.md`, and does the repo get its own `AGENTS.md`

**Problem.** The root `CLAUDE.md` is the global-instructions payload, but
Claude Code also loads it as *project* instructions for anyone working in the
clone. And the repo has no `AGENTS.md`, so its own pipeline (reviewer,
committer) refuses to run on it as written.

**Why it blocks.** Moving the file changes the install command and the
"layout mirrors `~/.claude`" promise in `README.md:6`; adding `AGENTS.md`
defines the gates this very change must pass and the commit format.

- **a. Keep `CLAUDE.md` at the root; add `AGENTS.md`** stating that the root
  `CLAUDE.md` is payload, plus gates and commit format. Install unchanged.
  Contributors still get the payload loaded as project instructions.
- **b. Move the payload under a subdirectory (e.g. `home/` holding everything
  that installs), add a repo-level `CLAUDE.md` + `AGENTS.md`.** Clean
  separation; every path in README and the install command changes, and Q1's
  live-copy diff no longer lines up path for path.
- **c. Move only `CLAUDE.md` (e.g. `global/CLAUDE.md`).** Small move, but the
  mirror is no longer exact — one special case in the install line.
- **d. Change nothing.**

**Recommended: a** — and the payload stops being harmful to contributors once
Q4 removes the host-specific text from it. `AGENTS.md` content to confirm:
gates = `bash -n` and `shellcheck` on both scripts (shellcheck is red today on
`memory-sync.sh:70`, must be fixed in this change); Conventional Commits as in
`bc2e399`; `plan/` is tracked; no secrets, bucket or endpoint in any file.

Sub-questions: add a `.gitignore` (only needed under a symlink install — Q1d)?
Ship a `settings.example.json` with the four hook events and placeholder
`CLAUDE_MEMORY_S3_*` keys (recommended yes, placeholders only)?

---

## Q6 — Portability target for `memory-sync.sh`

**Problem.** The script needs `timeout`, `flock`, `rsync` (none probed) and
uses `"${extra[@]}"` under `set -u`, which is reported to abort on bash 3.2
when empty (unverified here — no bash 3.2 available).

**Why it blocks.** "Linux only" makes the fix a dependency check and a README
line; "also macOS" changes the locking and timeout mechanisms themselves and
cannot be verified on this host.

- **a. Linux/GNU only, documented, with a startup probe** that logs which tool
  is missing and exits 0. Small, fully testable here.
- **b. Also macOS / bash 3.2.** Replace `flock` (e.g. `mkdir` lock), `timeout`
  (CLI read/connect timeouts or a watchdog), guard the empty array. Larger
  change to the lock path that A2/A5/A6 also touch, and no way to run it here —
  every macOS claim would ship `UNVERIFIED`.
- **c. a, plus the one-line empty-array guard**, since it is free and harmless.

**Recommended: c.**

---

## Q7 — Behaviour of `reviewer` and `committer` when `AGENTS.md` is missing

**Problem.** `agents/reviewer.md:13` and `agents/committer.md:13` hard-stop;
`CLAUDE.md`, `manager-bootstrap.sh`, `bootstrap`, `manager`, `integrator` and
`/integrate` fall back to `CLAUDE.md`; `developer`, `analyzer` and six commands
say nothing; `plan-first:152` already gives the committer's fallback
(Conventional Commits). In a repo with no `AGENTS.md` the pipeline deadlocks at
review and at commit — including in this repo.

**Why it blocks.** It is the contract for two agents and decides the wording in
up to ten files.

- **a. Fall back everywhere:** read `CLAUDE.md`, say there is no working
  agreement; reviewer reviews correctness only and reports no rule findings;
  committer uses Conventional Commits and the repo's own `git log` style.
  Unblocks every repo; a review without rules is weaker and must say so in its
  verdict.
- **b. Keep the hard stop, and make the upstream docs agree** (manager and
  bootstrap say "create `AGENTS.md` first"). Strict; every new repo needs an
  agreement before any change can ship.
- **c. Split:** reviewer falls back (correctness-only, flagged); committer
  still stops, because a commit format guessed wrong is permanent history.
  Still deadlocks at commit.

**Recommended: a**, with the reviewer's verdict line required to say
"no AGENTS.md — correctness only".

---

## Q8 — Scope and ordering of this change (added by the planner)

**Problem.** Five finding groups across ~15 files; groups C and D both edit
`bootstrap`, `reviewer.md`, `committer.md`.

**Why it blocks.** Decides whether this is one plan/one review cycle or
several, and whether developers can run in parallel.

- **a. One plan, four ordered slices** (script+skill → consistency →
  de-localisation → scaffolding), separate commits.
- **b. Two plans:** the script and its skill now (`bug-…`), prose and
  structure after.
- **c. Script only; everything else to follow-ups.**

**Recommended: a.**

---

## Q9 — Push failure backoff policy (added by the planner)

**Problem.** After a failed push every `push-if-changed` retries and blocks for
the full timeout (proven). A backoff needs a number and a rule.

**Why it blocks.** The retry interval, and whether the `SessionEnd` `push`
ignores the backoff, are behaviour choices that trade data freshness against
session latency; also the hook timeout (20 s) is below the script default
(25 s).

- **a. Failure stamp + fixed cool-down (e.g. 5 min) for `push-if-changed`
  only; explicit `push` always tries; `push-if-changed` takes the lock
  non-blocking (`flock -n`).**
- **b. Exponential backoff** — more state, little gain for a single user.
- **c. a, and also lower the script's default timeout below the hook timeout**
  so the script's own log line always appears.

**Recommended: c.** Please confirm the cool-down length.

---

## Q10 — `manager-bootstrap.sh` wording (added by the planner)

**Problem.** `manager-bootstrap.sh:11-15` tells the session to load `manager`
and `security` and that dispatched agents carry `security`; `CLAUDE.md:1,16-17`
and `bootstrap:38-39` say load `bootstrap` first and that agents carry
`security` **and** `comments`.

**Why it blocks.** It is outside the reviewer's list; touching it is scope the
user did not ask for.

- **a. Fix in this change** (add `comments`, mention `bootstrap`).
- **b. Record as a follow-up, do not touch.**

**Recommended: a** — same class as (C), one file, gated by `bash -n` and
shellcheck.

---

## Answers — recorded by the manager from the user, 2026-10-04

All ten questions are resolved. Where the answer is "recommended", it is the
planner's recommended candidate in the question above, unchanged.

| Q | Answer |
|---|---|
| Q1 | **Repo only.** Nothing is copied, symlinked or installed into `~/.claude` in this change. The user's words: "do not cp to the globals"; they will say what to do with the live copies once the fixes are in and the manager flow works. Do not add an install script. |
| Q2 | Recommended: explicit `delete` subcommand + prune the stage; tombstones are a follow-up. Sub-question answered: **bucket versioning is on** (user's statement, not verified by any command). |
| Q3 | Recommended: **3** review rounds everywhere, including `skills/manager/SKILL.md:148`. |
| Q4 | Recommended: split machine-specific text into an unshipped per-host file read by `bootstrap`, ship an example. Sub-question answered: the test rules at `skills/manager/SKILL.md:263-265` (no hand-written mocks, generator directive, coverage >= 95%) are **universal** — they stay in `manager` as written. |
| Q5 | Recommended: keep `CLAUDE.md` at the repo root, add `AGENTS.md` (gates, commit format), add `settings.example.json` with placeholders only. |
| Q6 | Recommended: Linux/GNU only, documented, with a tool probe, plus the empty-array guard. |
| Q7 | Recommended: fall back to `CLAUDE.md` everywhere; the reviewer's verdict must say "no AGENTS.md — correctness only". |
| Q8 | Recommended: one plan, four ordered slices. |
| Q9 | Recommended policy; cool-down length is **5 minutes**. `SessionEnd` push always tries. |
| Q10 | Recommended: fix `manager-bootstrap.sh` in this change. |

### Further answers — recorded by the manager from the user, 2026-10-04 (after plan analysis round 1)

| Q | Answer |
|---|---|
| Q7 (clarified) | The "no AGENTS.md — correctness only" notice goes on its own `agreement:` line above an **unchanged** verdict line, because `/ship` matches the verdict line whole. The user accepted this in place of "the verdict must say". |
| Q11 — manager test rules vs the stub `aws` | **Scoped exception in this repo's `AGENTS.md`.** For shell scripts in this repo, a stub executable on `PATH` is the allowed way to fake an external CLI, and coverage is reported as a per-step list of which test case covers which change, because no tool can measure it for bash. `skills/manager/SKILL.md` stays unchanged. |
