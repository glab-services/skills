# Findings — bug-reviewer-findings

Planning only. Nothing outside `plan/` was edited, staged or committed.
`plan.md` is deliberately **not written**: `questions.md` holds open decisions
that belong to the user (plan-first step 2).

## 0. Working agreement

There is **no `AGENTS.md`** in this repo (`ls AGENTS.md` → `No such file or
directory`). The root `CLAUDE.md` is *published content* — a mirror of the
user's global `~/.claude/CLAUDE.md` — not a contract for this repo. So the repo
has no working agreement, and the conventions below are only what can be read
off the 25 tracked files and the single commit `bc2e399`
(`chore: import global Claude Code skills, agents and commands`, bullet body,
`Co-Authored-By` trailer).

Labels: **P** = proven (command run, output read). **I** = inferred (read from
text, not executed). Every judgment about what a document *should* say is I.

## 1. Scope surface

25 tracked files (`git ls-files | wc -l` → `25`), 2186 lines:
`CLAUDE.md`, `README.md`, `manager-bootstrap.sh`, `memory-sync.sh`,
`agents/{analyzer,committer,developer,integrator,reviewer}.md`,
`commands/{analyze,commit,develop,integrate,plan,push,review,ship}.md`,
`skills/{audit,bootstrap,comments,manager,plan-first,security,sync-memory}/SKILL.md`,
`skills/audit/references/plan-template.md`.

Live copies (P): a `cmp` loop over every tracked file except `README.md`
against `~/.claude/<path>` reported exactly one difference —
`skills/sync-memory/SKILL.md`, hunks `43c43`, `77c77`, `86c86` (the bucket
placeholder). Everything else is byte-identical. `README.md` has no live copy.

### Callers of the two scripts (call-site audit) — P

`jq` over `.hooks` of `~/.claude/settings.json` (command strings only; no env
value was read or printed — only the env *key names*: `AWS_PROFILE`,
`CLAUDE_MEMORY_S3_ARGS`, `CLAUDE_MEMORY_S3_TIMEOUT`, `CLAUDE_MEMORY_S3_URI`):

| event | matcher | command | hook timeout |
|---|---|---|---|
| SessionStart | – | `~/.claude/memory-sync.sh pull` | 20 |
| SessionStart | – | `~/.claude/manager-bootstrap.sh` | 5 |
| SessionEnd | – | `~/.claude/memory-sync.sh push` | 20 |
| PostToolUse | `Write\|Edit\|MultiEdit\|NotebookEdit\|Bash` | `~/.claude/memory-sync.sh push-if-changed` | 60 |
| Stop | – | `~/.claude/memory-sync.sh push-if-changed` | 60 |

Other callers: `skills/sync-memory/SKILL.md:29` (manual `push`), and the header
usage `memory-sync.sh:5-9`. What each relies on: the three mode names, exit 0 on
every path (`memory-sync.sh:21-22`), a bounded runtime, stderr-only logging.
Contract is shared — any new mode or changed exit behaviour touches the hook
wiring on every machine, which is not in this repo.

New fact the reviewer did not have: **the hook timeout for `pull` and `push` is
20 s while the script default is 25 s** (`memory-sync.sh:28`), and `push` can
take up to 2×TIMEOUT (lock wait `:105` + transfer `:67`). If the configured
`CLAUDE_MEMORY_S3_TIMEOUT` is ≥ 20 the harness kills the script before its own
timeout fires and nothing is logged.
`UNVERIFIED: whether the configured timeout is below the hook timeout — the env value was not read, by instruction.`

### Gates available — P

- `bash -n memory-sync.sh` → `rc=0`; `bash -n manager-bootstrap.sh` → `rc=0`.
- `shellcheck` is installed: `/usr/bin/shellcheck`, `version: 0.11.0`.
- `shellcheck memory-sync.sh manager-bootstrap.sh` → **rc=1 at baseline**:
  `memory-sync.sh line 70: SC2015 (info): Note that A && B || C is not if-then-else`.
  So shellcheck is not green today; a plan that makes it a gate must fix or
  explicitly accept `:70`.
- With the `# shellcheck disable=SC2206` at `:60` removed, shellcheck also
  reports `SC2206 (warning)` on `:61` — the suppression is hiding the real
  glob finding (A3 below).
- No Makefile, no CI config, no test suite, no markdown lint. There is no gate
  for the 23 prose files.

## 2. (A) `memory-sync.sh`

Experiments ran the repo script with a **stub `aws`** on `PATH`, a throwaway
`CLAUDE_CONFIG_DIR` under `/data/tmp/claude`, and `CLAUDE_MEMORY_S3_ARGS` /
`AWS_PROFILE` unset. The real backend was never contacted. The stub copies
`*/memory/*` files with mtimes preserved and never deletes (the real CLI's
no-`--delete` behaviour). The throwaway dir was removed afterwards (P).
Fidelity of the stub to the real CLI's size/mtime comparison is I.

### A1 — locally deleted memory is restored (MAJOR) — P

Code: `memory-sync.sh:63-64` (no `--delete`, by design), `:95-96` (stage never
pruned), `:100` (`rsync -a --update` copies anything missing locally).

    after local rm: keep.md
    [memory-sync] push ok
    [memory-sync] pull ok
    after push+pull: gone.md keep.md
    -- also deleted from remote, stage still holds it:
    [memory-sync] pull ok
    after remote rm + pull: gone.md keep.md
    stage: gone.md keep.md

Two independent causes, both proven: (1) push never removes the remote object;
(2) even with the remote object gone, the persistent stage copy resurrects it.
Fixing only one leaves the bug.

State transitions for a delete of `<p>/memory/x.md` on machine M1 (today):

| | local M1 | stage M1 | remote | local M2 |
|---|---|---|---|---|
| before | present | present | present | present |
| after `rm` | absent | present | present | present |
| after next push | absent | present | present (no delete) | present |
| after next pull | **present again** | present | present | present |

Multi-machine (I): any fix that deletes remotely must also stop M2 — which
still has the file and a stage copy — from pushing it back; M2's push has no
`--delete` either, so M2 re-uploads only if its copy differs in size or is
newer. Not executed against two config dirs.

### A2 — no backoff after a failed push; `push-if-changed` waits on the lock (MAJOR) — P

Code: `:76` (no stamp → always "changed"), `:83-90` (stamp advances only on
success), `:108-114`, `:112` (`flock -w "$TIMEOUT"`).

Stub hanging 30 s, `CLAUDE_MEMORY_S3_TIMEOUT=2`, three consecutive calls:

    [memory-sync] push-if-changed timed out after 2s
    attempt 1 took 2.016711518s   (attempts 2 and 3: 2.017s, 2.015s)
    aws calls: 3

Lock held by another process, timeout 3:

    [memory-sync] push-if-changed: lock busy; skipping
    blocked 3.009438492s

Consequence (I, from the hook table): with the endpoint down, every matched
tool call and every turn end blocks for the full timeout; worst case per call
is lock wait + transfer = 2×TIMEOUT, against a 60 s hook timeout.

### A3 — `CLAUDE_MEMORY_S3_ARGS` is glob-expanded against cwd — P

Code: `:60-61`. With `fileA`, `fileB` in cwd and `ARGS='--no-verify-ssl *'`
the stub received `[8] --no-verify-ssl [9] fileA [10] fileB`. The cwd of a hook
is the user's project directory, so the expansion differs per project.
The `disable=SC2206` at `:60` suppresses exactly this warning (see §1).

### A4 — trailing slash in the URI yields `//` — P

Code: `:85`, `:96`. `CLAUDE_MEMORY_S3_URI=s3://stub/mem/` → stub received
`[3] s3://stub/mem//`. Whether a given backend treats `//` as a distinct empty
key segment is I (not tested against any backend).

### A5 — failed `exec 9>"$LOCK"` misreported as "lock busy" — P

Code: `:104-105`, `:110-112`. Lock path made unopenable (a directory):

    memory-sync.sh: line 104: .../.memory-sync.lock: Is a directory
    flock: 9: Bad file descriptor
    [memory-sync] push: lock busy; skipping
    rc=0 ... aws calls=0

The push is skipped permanently, with a message that says "busy".

### A6 — `pull` takes no lock — I

Code: `:94-101` has no `exec 9>`/`flock`. Two sessions starting together both
run `aws s3 sync` into the same `$STAGE` and `rsync` into `$ROOT`; a pull can
also interleave with a push reading `$ROOT`. Not reproduced — a race needs a
real concurrent run; per `security` ("unlikely window means certain") it is
treated as a defect, not dismissed.

### A7 — rsync presence/failure unchecked — P (with a correction)

Code: `:100` `rsync -a --update ... && log "pull ok"`; only `aws` is probed
(`:49-52`). With rsync absent from `PATH`:

    memory-sync.sh: line 100: rsync: command not found
    rc=0

Correction to the reviewer's wording: it is not fully silent — bash itself
prints `command not found` — but there is no `[memory-sync]` line, no "pull
failed", and an rsync that *exists and fails* (non-zero) prints nothing from the
script at all (I: `&&` short-circuits, no `else`). `timeout` and `flock` are
likewise never probed (`:67`, `:105`, `:112`).

### A8 — portability — mixed

- P: this host has `timeout`, `flock`, `rsync` in `/usr/bin` and bash
  `5.3.9(1)`; `set -u; e=(); "${e[@]}"` is fine here.
- I: `flock(1)` and `timeout(1)` are not shipped on macOS; `rsync` on macOS is
  not GNU rsync.
- `UNVERIFIED: "${extra[@]}" with an empty array aborts under set -u on bash 3.2 — no bash 3.2 on this host to run it.`
  Note the live env defines `CLAUDE_MEMORY_S3_ARGS`, so the empty case does not
  occur on this machine either way.

### A9 — further instances found, not in the reviewer's list

| where | what | label |
|---|---|---|
| `:70` | `A && B \|\| C` — shellcheck SC2015, baseline rc=1 | P |
| `:28` vs hook timeout 20 | script may be killed before it logs (see §1) | I |
| `:105` + `:67` | `push` worst case is 2×TIMEOUT | I |
| `:87` | success line is `"$MODE ok"`, so it prints `push-if-changed ok`, which the skill (`SKILL.md:32`) does not list | I |
| `:30-35` | comment carries an incident date. It is history-with-a-reason, not a stale marker: per `comments` it is kept and only *amended* if pull changes | I |

Comment handling for the developer (from `comments`): every explanatory comment
in the script (`:30-35`, `:37`, `:39`, `:56-57`, `:63-64`, `:81-82`, `:97-99`,
`:111`) records a decision. Each must be kept and updated in the same edit that
changes the code under it; `:63-64` ("No --delete in either direction") is
directly contradicted by some answers to Q2 and must then be rewritten, not
left. A `TODO|FIXME|HACK|NOTE|XXX` sweep of the scope files was not run — see
"Not checked".

## 3. (B) `skills/sync-memory/SKILL.md` vs the script — I unless noted

| line | says | reality |
|---|---|---|
| `:12-13` | "Two hooks … `SessionStart` pulls, `SessionEnd` pushes" | P: four events / four memory-sync entries; `PostToolUse` and `Stop` both run `push-if-changed` (§1). The reviewer said "a third"; there are two more. Script header `:7-9` already says so |
| `:18-21` | arguments `push`, `pull`, `status` | `push-if-changed` missing; `status` is a skill procedure, not a script mode (`:116` would print usage) |
| `:32` | "`push ok` / `pull ok`" | also `push-if-changed ok` |
| `:40-42` | unset URI "skips silently by design" | script `:45` logs `CLAUDE_MEMORY_S3_URI is not set; skipping` |
| `:43`, `:47`, `:77-79`, `:86-88` | example `aws` commands | none passes `$CLAUDE_MEMORY_S3_ARGS`; on a non-AWS endpoint they address the wrong service |
| `:47-49` | `sync --dryrun` both directions shows drift | pull is stage + `rsync --update` (script `:95-100`), so a direct S3→local dry run does not describe what pull does |
| `:50-51` | hooks check expects `SessionStart` and `SessionEnd` | omits `PostToolUse`, `Stop` |
| `:61-64` | "later push wins … lost locally. There is no locking" | script has a push lock (`:39-40`, `:104-105`) and pull never overwrites a newer local file (`:30-35`, `:97-99`) |
| `:78`, `:87` | key prefix `projects/<project-dir>/memory/` | P (stub): keys are `<uri-prefix>/<project>/memory/<file>` — the script syncs `$ROOT/` to `$URI/`. `projects/` is only right if the URI itself ends in `/projects`. `UNVERIFIED: the real URI — value not read` |
| `:3`, `:45-46`, `:95-102` | RustFS named in the description; no-STS, empty `get-bucket-versioning`, null version id | one backend's behaviour presented as general |
| `:71` | "The bucket has versioning enabled" | a fact about one bucket; `UNVERIFIED` here and unknowable for a reader's bucket |
| `:25-26` | "never deletes on either side" | true, and is the cause of A1 — must be rewritten together with Q2 |

## 4. (C) Cross-file contradictions — P for every line cited (`/usr/bin/grep -n`, pattern proven against `agents/reviewer.md:90` first)

### C1 — review round cap

| says | where |
|---|---|
| four | `agents/reviewer.md:90`, `:92`, `:98`; `commands/ship.md:32` |
| three | `skills/manager/SKILL.md:102`, `:297`; `skills/bootstrap/SKILL.md:87` |
| implies three | `skills/manager/SKILL.md:148` ("a second review session is `review2`, and there is no `review4`") — reviewer missed this one |

Other caps are consistent and out of scope: plan-analyze 2
(`manager:98`, `:234`), develop-analyze 4 (`manager:100`, `:279`, `:281`;
`bootstrap:81-82`). `commands/review.md` states no cap.

### C2 — skill names

`agents/reviewer.md:15` names `guardrails` and `preserve-comments`. A search of
all 25 files for `guardrails|preserve-comments` returns only that line; the
shipped skills are `security` and `comments`. No other stale skill name found.

### C3 — duplicated bullet

`agents/committer.md:36` (bold) and `:37` (plain) are the same rule.

### C4 — behaviour when `AGENTS.md` is missing

| behaviour | where |
|---|---|
| fall back to `CLAUDE.md`, say so | `CLAUDE.md:14-15`; `manager-bootstrap.sh:9`; `skills/bootstrap/SKILL.md:20-22`; `skills/manager/SKILL.md:16`; `agents/integrator.md:11`; `commands/integrate.md:6` |
| hard stop | `agents/reviewer.md:13` (`BLOCK: target unresolved`); `agents/committer.md:13` |
| silent — says "read `AGENTS.md`", no branch | `agents/developer.md:15`; `agents/analyzer.md:18`; `commands/analyze.md:6`, `commit.md:6`, `develop.md:6`, `plan.md:6`, `review.md:6`, `ship.md:10` |
| own fallback for commit format | `skills/plan-first/SKILL.md:152` (Conventional Commits) — contradicts `committer.md:13` |

Dependent text that assumes an `AGENTS.md` with particular content:
`agents/reviewer.md:55` ("AGENTS.md requires this explicitly"), `:57`, `:82`;
`agents/committer.md:11`, `:45`.

This repo is itself the proof of the deadlock (I): it has no `AGENTS.md`, so
`reviewer` and `committer` as written refuse to run on the very change this
plan describes.

### C5 — further contradictions found

- `manager-bootstrap.sh:15` says dispatched agents carry `security`;
  `CLAUDE.md:16-17`, `bootstrap:38-39`, `manager:36-45` say `security` **and**
  `comments`.
- `manager-bootstrap.sh:11-13` says "load two skills" (`manager`, `security`)
  and never mentions `bootstrap`; `CLAUDE.md:1` says load `bootstrap` first.
- `README.md:4` says "the two hook scripts" — consistent — but nothing lists
  the four hook events.

## 5. (D) Machine- and project-specific text — P for location, I for classification

**Host paths / filesystem**
- `CLAUDE.md:19-25`; `skills/bootstrap/SKILL.md:117-125` — `/data/tmp/claude`
  mandate, tmpfs/quota description. P: `/tmp` here is `tmpfs` with `usrquota`.
  `UNVERIFIED: "/data is a dedicated disk" — findmnt /data printed nothing.`
- `skills/bootstrap/SKILL.md:120` — `/tmp/claude-1000/`. P: wrong even on this
  host for this user: `id -u` → `1001`, only `/tmp/claude-1001` exists.
- `skills/bootstrap/SKILL.md:130` — `/usr/bin/grep`.
- `README.md:30-32` — already admits both.

**"grep is ugrep"** — `skills/bootstrap/SKILL.md:127-132`, `README.md:31`.
P: `type grep` → `grep is a function` that execs the Claude Code binary as
`ugrep`. So it is a property of the **Claude Code Bash tool shell**, not of the
host — the text misattributes it. P: `'foo[\s]bar'` matches 1 line via the
function and 0 via `/usr/bin/grep`, i.e. the bracket-`\s` sentence at `:128-129`
describes GNU grep, not ugrep. The "zero matches for a leading alternation
group" claim did **not** reproduce on `-E '(foo|baz)'` (both returned 2);
one case does not disprove it. `UNVERIFIED: the alternation hazard as stated.`

**"this machine" / "here"**
`CLAUDE.md:4`, `:22`; `bootstrap:3`, `:9` ("this environment"), `:114`, `:117`,
`:157` ("Measured here"), `:173` ("leaked one here");
`agents/reviewer.md:13`, `agents/committer.md:13` ("Every repo here");
`skills/sync-memory/SKILL.md:44`, `:97`.

**Another project quoted as "this repo" / "this backend"**
`agents/analyzer.md:48` (`make lint` → `go generate`, 85 mockgen directives);
`bootstrap:65-68` (`make ci`/`ci-all`); `bootstrap:108-110` (feature switches);
`commands/develop.md:14` ("no single convention in this repo");
`skills/manager/SKILL.md:183-188`, `:201-204`, `:210-219` (anecdotes, worded as
"a real case" / "one plan" — already generalised, lowest priority);
`skills/manager/SKILL.md:263-265` (no hand-written mocks, generator directive,
≥95% coverage — a project's test policy stated as a rule for every dispatch;
reviewer missed this).

**Go-toolchain assumptions**
`CLAUDE.md:20`, `bootstrap:123` (`TMPDIR` "before any `go` command");
`bootstrap:134-143` (receiver grep), `:145-147` (`psql`), `:149-152`
(`make gotest`, `-count=1`), `:154-160` (`max-same-issues`);
`bootstrap:61-63` and `skills/security/SKILL.md:45` (`go test` — illustrative
example, lowest priority); `agents/reviewer.md:73` (`go build`).

Comment/knowledge handling (from `comments`, I): most of §5 is *history with a
reason* — an incident and the rule it produced. The plan must tell the
developer to keep the lesson and change only its attribution or location;
nothing here is deleted without the user saying so (Q4).

## 6. (E) Repo structure — P

- Root `CLAUDE.md` exists and is the install payload (`README.md:13`, `:23`);
  Claude Code loads a repo-root `CLAUDE.md` as project instructions (I — harness
  behaviour, not executed). Opening the clone therefore imposes
  `/data/tmp/claude` etc. on any contributor.
- No `settings.json` example: no tracked path contains "settings" (`0`);
  `README.md:26-28` says wiring is per machine and gives no snippet.
- No `.gitignore` (`ls .gitignore` → not found). In `~/.claude` the script
  creates `.memory-sync-stage/`, `.memory-sync-pushed`, `.memory-sync.lock` (P,
  `ls -la`); they matter to this repo only under a symlink install (Q1).
- No `AGENTS.md`, no gates defined (§0, §1).
- `plan/` did not exist before this change; it is new, untracked.

## 7. Candidate implementation boundaries

- **B1 — four slices by file set, one plan:** (i) `memory-sync.sh` +
  `skills/sync-memory/SKILL.md`; (ii) agents/commands/manager/bootstrap
  consistency (C); (iii) de-localisation (D); (iv) repo scaffolding (E).
  (ii) and (iii) both touch `bootstrap`, `reviewer`, `committer` → must be
  ordered, not parallel. *Preferred, pending the questions.*
- **B2 — script only now, prose later:** smallest diff, but leaves the skill
  contradicting the script it documents — rejected unless the user wants it.
- **Rejected — rewrite `memory-sync.sh` in another language or on
  `aws s3api`:** removes the `timeout`/`flock`/`rsync` dependencies but replaces
  a 119-line script whose every comment encodes an incident, changes the hook
  contract, and is far beyond the reviewer's findings.
- **Rejected — fix A1 by adding `--delete` to push alone:** proven insufficient
  (the stage resurrects the file) and removes the guard at `:63-64` against a
  half-written local tree wiping the remote.

## 8. Not checked

- No experiment touched the real backend; RustFS/versioning statements are
  unverified.
- No env value from `settings.json` was read (URI shape, timeout, args).
- bash 3.2 / macOS behaviour not executed.
- Concurrency (A6) not reproduced.
- `skills/audit/*`, `skills/comments`, `skills/plan-first`, `skills/security`,
  `commands/push.md`, and parts of `agents/developer.md` / `agents/integrator.md`
  and `skills/manager/SKILL.md:61-89,151-174` were covered by pattern searches
  only, not read in full; a class of defect with no keyword in my patterns
  would be missed there.
- No `TODO|FIXME|HACK|NOTE|XXX` sweep of the scope files was run; the developer
  must run it per file before editing.
- Side effect to disclose: while cleaning up the experiment the planner ran
  `pkill -u <me> -f 'sleep 30'` to reap the stub's orphans. The pattern also
  matched its own shell (exit 144) and may have matched other processes of this
  user whose command line contains `sleep 30`; afterwards `pgrep sleep` showed
  none and the throwaway dir was confirmed removed.
