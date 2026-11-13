# Steps 1 — scripts and tests (A1–A6)

Every script and test follows the repo's rules: `#!/usr/bin/env bash`, mode
0755 (`git update-index --chmod=+x` if needed), `shellcheck` clean, work
directories from `mktemp -d "${TMPDIR:?}/<name>.XXXXXX"` removed by an
`EXIT` trap, no background process (so nothing to kill), the case lines
`ok <id> <what>` / `FAIL <id> <what>: <reason>` and the last line
`PASS <n>/<n>` or `FAIL <k>/<n>` (exit 1), as `tests/context-size.test.sh`
prints them. A test takes the script under test as its argument and exits 2
with a usage line without it. The contracts C1–C10 are in `plan.md`.

### A1 — the gate script

Create `plugins/glab/scripts/plan-gate.sh`, mode 0755, implementing C3–C8
exactly: the four modes, the digest of C4, the report of C6 with its
`plan.r<n>/` copy (each hashed file copied to the same relative path, made
with `mkdir -p` and `cp`, no GNU-only flag), the verdict of C7, the check, the
exit codes, and the refusal lines word for word. It reads no configuration —
every path is an argument — and depends on nothing but bash and coreutils
(`sha256sum`, or `shasum -a 256` when that is missing). Its header comment
says why it is a script: both levels must compute the same digest, and the
report and verdict formats need one owner and one test.

- post: `` test -x plugins/glab/scripts/plan-gate.sh && echo ok || echo FAIL ``
- post: `` P plugins/glab/scripts/plan-gate.sh 'two REJECTED verdicts on this brief; the next verdict is by user' ``
- post: `` P plugins/glab/scripts/plan-gate.sh 'the plan changed since verdict r' ``
- post: `` if bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh 2>&1 | tail -n 1 | command grep -qx 'PASS 22/22'; then echo ok; else echo 'FAIL plan-gate.test.sh'; fi ``

### A2 — the gate script's test

Create `tests/plan-gate.test.sh`, mode 0755, with the cases T1–T22 that
`plan.md` *Tests* lists, each in its own temp store and plan folder written
by the test. T21 builds its `PATH` from a directory of symlinks to the tools
the script needs, `shasum` included and `sha256sum` left out, and is skipped
— printed `ok T21 … (skipped: no shasum)` — only where `shasum` is missing.

- post: `` test -x tests/plan-gate.test.sh && P tests/plan-gate.test.sh 'T22' || echo FAIL ``
- post: `` P tests/plan-gate.test.sh 'REFUSED: report r1 has no verdict yet' ``

### A3 — the session-start hook reads the level

Change `plugins/glab/scripts/manager-bootstrap.sh` to C1 and C9: read the
level from `${CLAUDE_PROJECT_DIR:-$PWD}/AGENTS.md`, print the product or the
project text, put C1's warning first in the text and on stderr for a level
not built. The project text stays today's text but for its new first line.
Keep `exit 0` on every path, stdout as C9 says, nothing else on stdout. The
header comment gains the level (where it is read, the default, the reserved
values) and the hook's contract as C9 states it.

- post: `` P plugins/glab/scripts/manager-bootstrap.sh 'glab-level:' ``
- post: `` P plugins/glab/scripts/manager-bootstrap.sh 'the operating model of the product level' ``
- post: `` P plugins/glab/scripts/manager-bootstrap.sh 'is not built in this version of glab; this session runs at the project level' ``
- post: `` if bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh 2>&1 | tail -n 1 | command grep -qx 'PASS 11/11'; then echo ok; else echo 'FAIL manager-bootstrap.test.sh'; fi ``

### A4 — the hook's test

Create `tests/manager-bootstrap.test.sh`, mode 0755, with the cases B1–B11
that `plan.md` *Tests* lists. Each case runs the script with
`CLAUDE_PROJECT_DIR` set to a temp repo the case writes (B6 unsets it and
runs from that repo). B5's `PATH` is a directory of symlinks to the tools the
script needs, without `jq`. B11 is skipped — `ok B11 … (skipped: running as
root)` — when the test runs as root, where `chmod 000` does not stop a read.
`[N3]`: B1–B3 look for `` `glab:manager` — the operating model ``.

- post: `` test -x tests/manager-bootstrap.test.sh && P tests/manager-bootstrap.test.sh 'B11' || echo FAIL ``
- post: `` P tests/manager-bootstrap.test.sh 'glab-level: delivery' ``

### A5 — the walkthrough's fixtures

Create the folder `tests/fixtures/product-loop/` with these files, each short
and about a made-up product, a notes app with a sync API, owned by no real
company:

- `business-plan.md` — the user's input: the product, two projects (`notes-api`, `notes-web`), and one constraint the rules carry;
- `product-rules/index.md` — one line per rule file, in C3's form;
- `product-rules/data-retention.md` — the rule `Request logs are kept at most 90 days.`;
- `product-rules/api-versioning.md` — a second rule, so the brief names a subset;
- `brief.md` — the brief for `notes-api`, in the format `glab:product-plan` gives (step P2), naming `docs/product-rules/data-retention.md`;
- `project-plan/master.md` — a project master whose `## Request` holds the brief line of C5 with the placeholder `<brief-sha256>`, which the walkthrough replaces with the real hash;
- `project-plan/plan.md` — a project plan whose step keeps request logs `365 days`, the conflict the audit finds;
- `reasons/r1-rejected.md` — the verdict reason: the plan keeps logs 365 days against `data-retention.md`;
- `reasons/r2-accepted.md` — the reason for the acceptance: no conflict with the rules the brief names.

- post: `` for f in business-plan.md product-rules/index.md product-rules/data-retention.md product-rules/api-versioning.md brief.md project-plan/master.md project-plan/plan.md reasons/r1-rejected.md reasons/r2-accepted.md; do test -f "tests/fixtures/product-loop/$f" || echo "FAIL missing $f"; done; echo ok ``
- post: `` P tests/fixtures/product-loop/project-plan/master.md '- brief: briefs/notes-api/brief.md sha256 <brief-sha256>' ``
- post: `` P tests/fixtures/product-loop/product-rules/data-retention.md 'Request logs are kept at most 90 days.' ``

The first post prints `FAIL missing …` lines and then `ok`; X3's count shows
any `FAIL` line.

### A6 — the walkthrough

Create `tests/product-loop.test.sh`, mode 0755, taking the paths of
`plan-gate.sh` and `manager-bootstrap.sh`, with the cases L1–L15 that
`plan.md` *Tests* lists. It builds, under one temp directory, a product repo
(`AGENTS.md` with `glab-level: product`), a project repo (`AGENTS.md` with no
level line), and a store; it copies the fixtures in where an agent would
write them, saying in each case's comment which role writes that file in a
live session (`glab:product-planner`, `glab:planner`, the project manager
through `plan-gate.sh report`, `glab:product-analyzer`, the product manager
through `plan-gate.sh verdict`); it applies the amendment of L10 with `sed`
(`365 days` → `90 days`). With `PRODUCT_LOOP_SHOW=1` it prints to stderr,
after each case, the path and text of every store file that case wrote, so
stdout keeps only the case lines. Its header comment says that it calls no
model, writes only under `$TMPDIR`, and is the user's way to see the loop.

- post: `` test -x tests/product-loop.test.sh && P tests/product-loop.test.sh 'PRODUCT_LOOP_SHOW' || echo FAIL ``
- post: `` if bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>/dev/null | tail -n 1 | command grep -qx 'PASS 15/15'; then echo ok; else echo 'FAIL product-loop.test.sh'; fi ``
