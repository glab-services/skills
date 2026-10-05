# Result — bug-reviewer-findings, review round 1, prose/config

Review-forced changes outside the plan. `AGENTS.md` read first (it now exists).
Nothing committed or staged (`git diff --cached --stat | wc -l` -> `0`); nothing
written under `~/.claude`; `~/.claude/settings.json` not read; `plan.md`,
`findings.md`, `questions.md` not edited.

Marker sweep before editing (`/usr/bin/grep -c -E 'TODO|FIXME|HACK|NOTE|XXX'`):
0 in every file of this round except the two known sentences
(`agents/reviewer.md:15`, `skills/bootstrap/SKILL.md` "a `TODO` deleted in
passing"), both kept — the reviewer one keeps its second sentence unchanged.

## Findings

| # | state | before | after |
|---|---|---|---|
| 1 | fixed | `agents/integrator.md:39` "redirect its log to the scratchpad"; `agents/reviewer.md:73` "throwaway repo under the scratchpad" | same lines: "…the temp directory the dispatch message names (the scratchpad only if it names none)". Rest of each sentence unchanged |
| 2 | fixed | `skills/bootstrap/SKILL.md:117` (step 6) "Read `~/.claude/host.md` before the first command" plus the no-host fallback; `CLAUDE.md:21` "Read it before the first command", `:26` "step 6 explains why" | read instruction and fallback now in step 1, `skills/bootstrap/SKILL.md:28-33`; step 6 `:124-132` keeps the dispatch rule and the why. `CLAUDE.md:21` "Read it with the working agreement, before the first command"; `:26` "step 1 has the read; step 6 explains why this matters" |
| 3 | fixed | `skills/bootstrap/SKILL.md:125-126` "The file `host.example.md` in the skills repo keeps that case in full." | `:129-132`: "Growing the tmpfs did not help: the limit was that quota, not the size of the filesystem. The template the host file is made from, `host.example.md`, records that case in full; the rule above does not depend on your having it." |
| 4 | fixed | `agents/reviewer.md:15` "If the repo ships `security` and `comments` skills, read them too." | `:15` "Load the `security` and `comments` skills if they are available." Second sentence of the line unchanged |
| 5 | fixed | `skills/sync-memory/SKILL.md:47-52` — "This is the honest answer…" after the pull text | `:49-53`: the sentence follows the push dry run directly; then "Pull drift has no dry run: …" |
| 6 | fixed | `:40-42` no test command; `:47-48` no redaction line | `:40-41` "Test it without printing its value: `[ -n "$CLAUDE_MEMORY_S3_URI" ] && echo set`"; `:55` "When you report what these commands print, replace the bucket name with a placeholder." |
| 7 | fixed | status list ended at item 4 | new item 5, `:58-61`, naming `~/.claude/.memory-sync-failed`. Name and behaviour read from `memory-sync.sh` (read only): `:53` `FAILED="$CONF/.memory-sync-failed"`, `:54` `COOLDOWN=300`, `:183` removed on success, `:205` push never consults it, `:212` `cooling && exit 0` |
| 8 | fixed | `README.md:63` "`memory-sync.sh pull`, then `manager-bootstrap.sh`" | `:63` "`memory-sync.sh pull` and `manager-bootstrap.sh`" |
| 9 | fixed | no statement; `settings.example.json:4` `"<profile>"` | `README.md:74-76` one sentence; `settings.example.json:4` `"<profile, or delete this key>"` |

Finding 2 checks: "Six steps, in order" (`bootstrap:8`) still true — no step
added. The one-line check at the end still lists four things (agreement, gates,
stage, handoff) and reads true; it does not mention the host file and was not
changed — see follow-ups. The step 1 heading ("Read the working agreement") was
left as is.

## Unplanned changes

- `host.example.md:4` — "`bootstrap` step 6 reads it" -> "step 1 reads it".
  Forced by finding 2 (the sentence would have been false). In this round's boundary.
- `README.md:70-72` — the optional `SessionEnd` fact (1.5-second shared budget,
  raised to an explicit per-hook timeout up to 60 seconds). Added as permitted.
  `UNVERIFIED: the hooks-reference wording — taken from the coordinator's quote; I did not read the reference myself.`
  Same for finding 8's "run in parallel".
- Wording chosen to keep plan probes green where it cost nothing: item 5 and the
  redaction line use no hook event name, no `<bucket>`, no extra
  `$CLAUDE_MEMORY_S3_ARGS`; step 6 says "that quota" so `per-user quota` stays on one line.

## Gates

No markdown lint exists. `TMPDIR=/data/tmp/claude`.

```
jq . settings.example.json >/dev/null; echo "jq rc=$?"      -> jq rc=0
bash -n manager-bootstrap.sh; echo "bash -n rc=$?"          -> bash -n rc=0
shellcheck manager-bootstrap.sh; echo "rc=$?"  (P2.10)      -> rc=0
```

`memory-sync.sh` and `tests/` belong to the other developer this round; the
script/test gates were not run here. Both files were checksummed before and
after my edits: unchanged by me (`OK`), as were `skills/manager/SKILL.md`,
`AGENTS.md`, `agents/analyzer.md`, `commands/develop.md`.

## Post-condition deltas (P2.x, P3.x, P4.x re-run in full)

Two changed. Both are **expected failures of a plan probe**, not green:

| check | plan expects | now | why |
|---|---|---|---|
| P2.4 | `1` | `0` | finding 4 removed the literal ``ships `security` and `comments` skills``. Replacement probe ``Load the `security` and `comments` skills if they are available`` -> `1` |
| P4.9 line 1 | `README.md:1 AGENTS.md:0` | `README.md:0 AGENTS.md:0` | finding 8 changed "…pull`, then `…" to "…pull` and `…". Replacement probe on the new row -> `1` |

Everything else printed exactly what it did last run: P2.1-P2.3, P2.5-P2.12,
P3.1-P3.6 (P3.3 still `2` / `2` — the two `host.md` mentions in bootstrap moved
from step 6 to step 1), P4.1-P4.4, P4.6-P4.8, P4.9 lines 2-10. P4.10 README part
`1`; its script and test parts and P4.5 were not re-run (other developer's files).
Slice-1 probes my skill edits could disturb, re-run: P1.6 `2/2/2/2`, P1.7 `5`,
P1.10 `2`, P1.11 "is not set; skipping` and exits 0" `1` — unchanged.

Note: `README.md` and `settings.example.json` are no longer byte-identical to the
plan's fenced blocks (findings 8, 9, the optional addition). `AGENTS.md` is untouched.

## "the scratchpad" sweep — every hit in tracked and new files

| file:line | text | consistent with the new rule? |
|---|---|---|
| `CLAUDE.md:24` | fallback when there is no `host.md`: `$TMPDIR`, else scratchpad | yes — the rule's own fallback |
| `skills/bootstrap/SKILL.md:31` | same fallback, step 1 | yes |
| `README.md:46` | install step 1, describing that fallback | yes |
| `agents/integrator.md:39` | "(the scratchpad only if it names none)" | yes — fixed, finding 1 |
| `agents/reviewer.md:73` | "(the scratchpad only if it names none)" | yes — fixed, finding 1 |

No other hit (`/usr/bin/grep -n -i scratchpad` over `git ls-files` plus the four
new files; the pattern is proven by these five positives).

## Blast radius

- `bootstrap` now tells a session to read the host file in step 1, before the
  gate search (step 3) and `git log` (step 5). With no `host.md` the fallback and
  its "say so" are unchanged, only earlier.
- Reviewer: now loads `security`/`comments` in any repo where they are installed
  globally — previously skipped unless the repo shipped them. Reviewer and
  integrator write throwaway repos and logs where the dispatch says; a dispatch
  that names no directory behaves as before.
- `sync-memory` status: the agent no longer has a reason to print the URI; new
  item 5 is read-only (`ls -l`).
- `settings.example.json`: placeholder text only; P4.1-P4.3 unchanged.
- Not in effect until the user installs — nothing copied to `~/.claude`.
- Rollback: these are uncommitted edits on top of slices 1-4; there is no
  per-round undo other than reversing the hunks listed above by hand, or backing
  out the slices per plan A6.

## Follow-ups

- `bootstrap` "one-line check" could name the host file as a fifth item — not
  asked for, not done.
- `AGENTS.md` `## Rules` names the placeholder `<profile>`; the example now reads
  `<profile, or delete this key>`. Still a placeholder (P4.3 passes); `AGENTS.md`
  was outside this round's boundary.
- Plan probes P2.4 and P4.9 line 1 are now stale against the tree; `plan.md` not edited.
- Pending from the coordinator: the list of sentences made stale by the other
  developer's script fixes (delete failure message, "remote delete not confirmed",
  timeout cap, header claim). Not guessed at.
- Carried over from `result-slice3-4.md`, unchanged.

## follow-up 1 — text made stale by the script fixes

Reference: `memory-sync.sh` as it stood when read (read only; `MAX_TIMEOUT=17` at
`:45`, default at `:41`). Nothing committed or staged.

| # | state | where (after) | what |
|---|---|---|---|
| 1 | fixed | `skills/sync-memory/SKILL.md:85-89` | pull guarantee narrowed to "newer than the remote object's upload time", plus the consequence sentence (older copy uploaded at session end when its size differs; versioning where enabled) |
| 2 | fixed | `skills/sync-memory/SKILL.md:34-42` | three half-completed lines added, copied from the script with `<path>` / `<mode>` for the variable parts |
| 3 | fixed | `skills/sync-memory/SKILL.md:109-114` | the two delete failure cases and what to do |
| 4 | fixed | `skills/sync-memory/SKILL.md:19-20` (pull keeps a symlinked `memory` directory); `:78-80` known limitation, worded "may", marked not reproduced |
| 5 | fixed | `README.md:68-72` | maximum 17, the 17 + 3 = 20 reason, larger value rejected and 12 used — described, log text not quoted. "at least 5 seconds above it" became "at least 3 seconds above it": with 17 accepted against a 20-second hook the old sentence contradicted the script. The skill does not mention the timeout variable anywhere (`/usr/bin/grep -n -i timeout` on it: no hit), so nothing to change there |
| 6 | fixed | `AGENTS.md:42` | `<profile>` -> `<profile, or delete this key>`; nothing else in the file touched |

Gates:

```
jq . settings.example.json >/dev/null; echo "rc=$?"      -> rc=0
/usr/bin/grep -c -F -e '<fixed part>' memory-sync.sh / skills/sync-memory/SKILL.md
  delete: remote copy removed, but this copy was NOT removed:   -> script 1, skill 1
  delete: remote delete not confirmed; run delete again         -> script 1, skill 1
  : sent, but the push stamp was not updated:                   -> script 1, skill 1
  CLAUDE_MEMORY_S3_URI is not set; skipping (known positive)    -> script 1, skill 1
  negative control 'delete: no such line anywhere'              -> script 0
```

P1.6-P1.11 re-run: **no deltas** — P1.6 `2/2/2/2`, P1.7 `5`, P1.8 `1`, P1.9 `rc=1`
no line, P1.10 `2`, P1.11 thirteen lines each `: 1`. The new text was worded to
avoid hook event names (it says "at session end"), `<bucket>` and extra
`$CLAUDE_MEMORY_S3_ARGS`. P4.4, P4.9 `defaults to 12 seconds` and the two
`AGENTS.md` probes: unchanged.

Open:

- `AGENTS.md:42` now tells writers to use `<profile, or delete this key>` in "any
  file, commit message or report", which reads oddly outside the JSON example.
  It agrees with `settings.example.json` as asked; a cleaner wording is a decision
  for the user.
- README item 5 describes the over-cap log line rather than quoting it; when read,
  the script still printed the "not a positive integer; using 12" line for that case
  (the other developer's edit was pending).
- UNVERIFIED: the symlink limitation (item 4) — taken from the coordinator's
  description; not reproduced here either.
