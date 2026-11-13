tier: full — new file formats that cross between sessions (brief, report, verdict) and a gate that decides when development may start.

# Plan — flow-product-level

The request, goals and final check are in `master.md`; the findings, by id
`E<n>`, are in `evidence.md`. The steps are in four files, read in order:
`steps-1-scripts.md` (A1–A6), `steps-2-product.md` (P1–P9),
`steps-3-project.md` (J1–J11), `steps-4-repo.md` (R1–R6).

## Decisions

- effort: high (the user's words: "high (Recommended)"), for the session
- Tier full: the brief, report and verdict files are a wire format between sessions, and `plan-gate.sh check` decides whether development may start (`glab:manager` *Pick the tier*).
- One plan, not sub-plans: there is one milestone, the product ⇄ project loop, and no part runs alone — the gate without the skills that call it, or the skills without the gate, leaves nothing new running; the steps are split into four files for size.
- N1: hyphenated level prefixes under `glab` — `glab:product-*` — because a nested skill folder is not loaded and the manifest `skills` key gives no level segment (E1, E2).
- The seven product skills keep the agreed bare names behind the `product-` prefix: `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-report`, `product-project-plan-analyze`, `product-project-plan-verdict`.
- Agents stay flat files (`agents/product-planner.md`, `agents/product-analyzer.md`): `plugin details` does not list a subfolder agent and the model and skills gates glob `agents/*.md` (E3).
- The level is a line `glab-level: <level>` in the repo's `AGENTS.md` (C1), not an environment variable: it belongs to the repo the session runs in (*Rejected boundaries* in `evidence.md`).
- No level line, or no `AGENTS.md`, is the project level: every existing repo keeps today's session start.
- A level not built yet (`delivery`, `support`, a typo) runs as project, with a warning in the context and on stderr: the project level never touches a live system, so it is the safe fallback; `delivery` and `support` are the reserved seam.
- The shared store is named by a line `glab-shared-store: <path>` in the repo's `AGENTS.md`, else in `~/.claude/host.md` (C2); every committed file names store paths relative to the store, so no machine path is committed.
- The store layout is the agreed one plus `plan.r<n>/`, byte copies of the hashed plan files beside each report, because the product side cannot read the project's repo (C3).
- The plan digest covers `master.md`, `index.md`, every `plan.md`, every `steps-*.md` and `questions.md` under the plan folder (C4): the files a build follows; round copies, version copies, evidence, maps and results are not the contract.
- One script, `plugins/glab/scripts/plan-gate.sh`, computes the digest and writes the report and the verdict (C5–C8): both sides must compute the same bytes, and the formats then have one owner and one test.
- The report is sent after every approval of the plan (master's, and `plan.md`'s at full tier), as Stage 1c: an approval line written after the report would change the digest.
- The gate also refuses when the brief changed since the verdict: a plan accepted against an older brief answers an older request.
- The rejection cap counts `REJECTED` verdicts carrying the current brief's hash: a new brief starts a new count; the script refuses a third `REJECTED` unless `by` is `user`.
- The product manager writes the verdict itself from the audit; the user decides only at the cap, and on anything that meets a `glab:manager` Rule 3 ask-condition.
- The user approves every product plan explicitly: it decides what the product is (`glab:manager` Rule 3, fourth condition).
- The product rules are the user's: the product planner drafts new ones in the product plan and writes them to the store only after that plan's approval; one topic per file, at most 8192 bytes, and one index line each.
- The product agents have no `Skill` tool: their `skills:` list is all they load, which makes the boundary hard for them (E11).
- `glab:product-manager` follows `glab:manager` Rules 0b, 0c, 0d, 2, 3 and 5 by reference — they hold at every level and `glab:manager` owns them — and never its pipeline; moving them to a shared skill is FU-P1.
- Project sessions are started by the product manager through the host's session tool or `claude --bg`, on the user's go-ahead once per batch of briefs, or by the user; either way the session is told the brief's store path (E9; LP4).
- A project session that sent its report ends its turn and records the wait in the handoff file; it is resumed by a message, from the user or the product manager.
- On `REJECTED`: round copies, a new planning agent amends from the verdict's reason as its findings, one Stage 1b delta round per verdict outside Stage 1b's cap (as Stage 3's round after a review fix is outside Stage 3's), the approvals the tier needs, then report `r<n+1>`.
- Three new test files, one per contract: `plan-gate.test.sh` (the script), `manager-bootstrap.test.sh` (the hook), `product-loop.test.sh` (the walkthrough, run by the user to see the loop).
- The walkthrough writes what each agent would write from fixtures and runs the real scripts; it calls no model and writes only under `$TMPDIR`.
- The product level's record goes to a new `docs/specs/product.md`, named in `AGENTS.md`'s `plan/` rule; `workflow.md` gets the project edges.
- Every skill and agent `description:` begins with its level: `Product level — `, `Project level — ` or `Every level — ` (N2).
- Every-level skills: `glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`, `glab:commit`, `glab:push`, and the agent `glab:committer`; the product repo commits and pushes through them.
- `glab:product-project-plan-report` keeps its agreed name though the project manager runs it: the product chain sets the contract, and its description says `Project level`.
- `glab:product-analyzer` is read-only and returns its findings as text, as `glab:plan-analyzer` does; the verdict's reason is taken from it.
- The version is raised once, to `0.14.0`, in the commit that changes `plugins/glab/` (`AGENTS.md` *Rules*).

## Open — the answers this plan waits for

- **[Q1]** the model of `glab:product-planner` and `glab:product-analyzer` (`questions.md` Q1). Steps P8, P9, R3 and R5 are written with the recommended `opus`; a different answer changes only the `model:` values and the lines that state them.
- **[N3]** whether today's project skills keep their names (`questions.md` Q2, being asked by the manager). Every step is written for **keep**. On **move**, an amendment adds a rename step group after R6 and rewrites each phrase marked `[N3]`; no other step depends on it.

## Contracts

These are the facts every step cites. Where a file states one, it states it as here.

- **C1 — the level line.** In the repo-root `AGENTS.md`, the first line matching `^glab-level:[[:space:]]*([a-z][a-z-]*)[[:space:]]*$` (a trailing `\r` removed first). Built values: `product`, `project`. No match, no file, an unreadable file → `project`. Any other value → `project` and the warning `glab: level "<value>" is not built in this version of glab; this session runs at the project level`. Reserved for later levels: `delivery`, `support`.
- **C2 — the store line.** `glab-shared-store: <path>` — the first such line in the repo-root `AGENTS.md`, else in `~/.claude/host.md`; `~/` is the home directory. Read by the manager of each level (skill text), never by the hook, and passed to `plan-gate.sh` as an argument. None: the product level stops and asks the user; the project level needs it only for a brief.
- **C3 — the store layout.**

      <store>/docs/product-rules/index.md       one line per rule file: - <name>.md — <what it covers>
      <store>/docs/product-rules/<name>.md      one topic, at most 8192 bytes
      <store>/briefs/<project>/brief.md         written by glab:product-planner; the project's request
      <store>/briefs/<project>/report.r<n>.md   written by plan-gate.sh report
      <store>/briefs/<project>/plan.r<n>/       the hashed plan files, copied by plan-gate.sh report
      <store>/briefs/<project>/verdict.r<n>.md  written by plan-gate.sh verdict
      <store>/releases/                         reserved for the delivery level; nothing writes it yet

  `<project>` is kebab-case, `[a-z0-9-]+`. `<n>` starts at 1.
- **C4 — the plan digest.** Under the plan folder, recursively, the regular files named exactly `master.md`, `index.md`, `plan.md`, `questions.md`, or matching `steps-*.md`; listed as `./<path>`, sorted with `LC_ALL=C sort`; `sha256sum` of each, in that order; the digest is the `sha256sum` of those lines, 64 lowercase hex characters. `shasum -a 256` stands in where `sha256sum` is missing. Only `plan-gate.sh digest` computes it (E8).
- **C5 — the brief line.** In a project plan's `master.md`, under `## Request`: `- brief: briefs/<project>/brief.md sha256 <64 hex>`, the hash being `sha256sum` of `brief.md` as the planner read it. The first line matching `^- brief: briefs/([a-z0-9-]+)/brief\.md sha256 ([0-9a-f]{64})$` counts.
- **C6 — the report.** `report.r<n>.md`, these lines in this order, then the note:

      # Plan report r<n> — <project>
      report: r<n>
      plan-sha256: <digest of the plan folder>
      brief-sha256: <the hash in the brief line>
      files: <the number of files hashed>
      date: <YYYY-MM-DD>

      ## Note
      <the note file's text, or: none>

- **C7 — the verdict.** `verdict.r<n>.md`, `<n>` the report it decides:

      verdict: ACCEPTED | REJECTED
      report: r<n>
      plan-sha256: <digest of plan.r<n>/>
      brief-sha256: <sha256sum of brief.md now>
      by: product-manager | user
      date: <YYYY-MM-DD>

      ## Reason
      <the reason file's text; never empty>

- **C8 — `plan-gate.sh`.** Modes and arguments: `digest <dir>`; `report <plan dir> <store> [<note file>]`; `verdict <store> <project> ACCEPTED|REJECTED product-manager|user <reason file>`; `check <plan dir> <store>`. Exit 0 done, 1 refused, 2 usage (unknown mode, wrong arguments, a directory or file that does not exist). stdout: `digest` the digest; `report` and `verdict` the path written; `check` `ACCEPTED r<n> <digest>`. Every refusal is one stderr line beginning `REFUSED: ` and writes nothing; every write goes to a temporary name in the same folder and is moved into place. The refusals, exactly:
  - `report`: `REFUSED: no brief line in master.md` · `REFUSED: the brief changed since the plan was written; plan again` · `REFUSED: report r<n> has no verdict yet`.
  - `verdict`: `REFUSED: no report to decide` · `REFUSED: report r<n> already has a verdict` · `REFUSED: the copies in plan.r<n>/ do not match report r<n>` · `REFUSED: the brief changed since report r<n>` · `REFUSED: empty reason` · `REFUSED: two REJECTED verdicts on this brief; the next verdict is by user`.
  - `check`: `REFUSED: no brief line in master.md` · `REFUSED: no verdict for this brief` · `REFUSED: the latest verdict r<n> is REJECTED` · `REFUSED: the plan changed since verdict r<n> accepted it; report again` · `REFUSED: the brief changed since verdict r<n>; plan again`.

  `check` reads the highest-numbered verdict only. `report` numbers the next report one past the highest existing one.
- **C9 — the session-start texts.** The project text is today's text with one first line: `Level: project — no other glab-level line in AGENTS.md says otherwise.` The product text is the same text with that line reading `Level: product — glab-level: product in AGENTS.md.`, and point 2 naming `glab:product-manager` — "the operating model of the product level" — in place of `glab:manager`. A warning (C1) goes first, above the level line. Each text stays under 10,000 characters. stdout is one JSON object `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":<text>}}`, or the plain text when `jq` fails; exit 0 on every path; messages only on stderr. `[N3]`
- **C10 — the audit and check verdict lines.** `glab:product-analyzer`'s product plan check ends `SOUND` or `NOT SOUND: <n> findings`; its project plan audit ends `NO CONFLICT` or `CONFLICTS: <n>`; both use `BLOCK: target unresolved` when a file it needs is missing.

## Milestone

The product ⇄ project loop runs end to end without a model:
`bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh`
prints `ok` for L1–L15 and `PASS 15/15`. With `PRODUCT_LOOP_SHOW=1` it also
prints, on stderr, each file of the store as it is written, so the user can
read the loop.

## Phases

- **before** — B1–B3, below.
- **processing** — A1–A6, P1–P9, J1–J11, R1–R6, in that order, in the steps files.
- **after** — X1–X6, below.

### before

- **B1** — Branch `flow-product-level` from `main`; `main` = `origin/main`, no tracked change. post: `` test "$(git rev-parse --abbrev-ref HEAD)" = flow-product-level && test -z "$(git status --short --untracked-files=no)" && echo ok || echo FAIL ``
- **B2** — `export TMPDIR=/data/tmp/claude` (or the host file's temp directory) and run every gate in `AGENTS.md` *Gates* as it stands; all green as it states (`Skills (13)`, `Agents (7)`, `PASS 35/35`, `PASS 24/24`). post: the pasted output.
- **B3** — `questions.md` Q1 and Q2 carry the user's answers, written by the manager. post: `` command grep -c '^- \*\*Answer' plan/flow-product-level/questions.md `` prints `2`.

### after

- **X1** — Run every gate in the changed `AGENTS.md` *Gates*; green exactly as its changed *Green is* says.
- **X2** — The milestone command above prints `PASS 15/15`; run it again with `PRODUCT_LOOP_SHOW=1` and keep the stderr out of the plan folder.
- **X3** — Every post of A1–R6 prints `ok`: paste the helper below into a shell at the repo root, then `for f in plan/flow-product-level/steps-*.md; do sed -n 's/^- post: `` \(.*\) ``$/\1/p' "$f"; done | while IFS= read -r c; do eval "$c"; done | sort | uniq -c` prints one line, `114 ok`.
- **X4** — No machine path in a new or changed file: `git diff --name-only main -- plugins tests README.md AGENTS.md host.example.md | xargs command grep -n -E '/home/|/data/|/Users/|/tmp/' ` prints nothing but the lines that already held them on `main` (`AGENTS.md`'s `/tmp` hazard notes, `host.example.md`'s author's paths).
- **X5** — `wc -c` on `master.md`, `plan.md`, `evidence.md` and each `steps-*.md` of this folder: each at most 49152.
- **X6** — Back-out: `git revert` the commit. An installed copy is pinned to its version string, so a user on 0.13.0 is unaffected until they update; a repo with `glab-level: product` then runs as project under 0.13.0, which ignores the line.

### The post helper

    J() { tr '\n' ' ' < "$1" | tr -s ' '; }
    P() { if [ -f "$1" ] && J "$1" | command grep -q -F -- "$2"; then echo ok; else echo "FAIL $1: $2"; fi; }
    N() { if [ -f "$1" ] && ! J "$1" | command grep -q -F -- "$2"; then echo ok; else echo "FAIL $1: still $2"; fi; }

`P` says the phrase is there and `N` that it is gone, over the file's text
joined into one line with runs of spaces squeezed, so a phrase matches
however the developer wraps it. A phrase in a step is the exact text the post
looks for, written once with single spaces; the developer writes the prose
around it.

## Tests

- **`tests/plan-gate.test.sh <plan-gate.sh>`** — T1–T22, each `ok T<n> <what>`, last line `PASS 22/22`:
  T1 `digest` prints 64 hex characters, exit 0 · T2 it ignores `evidence.md`, `*.r1.md`, `master.v1.md`, `result.md`, `map-x.md` · T3 an edit to a sub-plan `plan.md`, a `steps-1.md` or `questions.md` changes it · T4 the copy `report` makes has the plan's digest · T5 `digest` of a missing folder exits 2 · T6 `report` writes `report.r1.md` with C6's lines and `plan.r1/` · T7 a second `report` while r1 has no verdict is refused and writes nothing · T8 `report` after the brief changed is refused · T9 `report` with no brief line is refused · T10 `verdict … ACCEPTED` writes C7's lines · T11 `verdict` over tampered copies is refused · T12 `verdict` after the brief changed is refused · T13 a second verdict for one report is refused · T14 an empty reason is refused · T15 a third `REJECTED` by `product-manager` is refused, by `user` written · T16 the count starts again on a new brief · T17 `check` after `ACCEPTED` prints `ACCEPTED r1 <digest>`, exit 0 · T18 `check` after a `plan.md` edit is refused, exit 1 · T19 `check` with no verdict, with the latest `REJECTED`, and after a brief edit: each refused with its line · T20 an unknown mode and missing arguments exit 2 with the usage line · T21 with a `PATH` that lacks `sha256sum` but has `shasum`, the same digest · T22 no temporary file is left in the store after any run.
- **`tests/manager-bootstrap.test.sh <manager-bootstrap.sh>`** — B1–B11, last line `PASS 11/11`:
  B1 no `AGENTS.md`: exit 0, stdout one JSON object whose only key is `hookSpecificOutput`, `hookEventName` `SessionStart`, the project text · B2 `glab-level: product`: the product text · B3 `glab-level: project`: the same text as B1 · B4 `glab-level: delivery`: the project text with C1's warning first, and the warning on stderr · B5 a `PATH` without `jq`: the plain text, exit 0 · B6 `CLAUDE_PROJECT_DIR` unset: the level read from `$PWD/AGENTS.md` · B7 a CRLF `AGENTS.md`: the level still read · B8 every text under 10,000 characters · B9 only the first level line counts · B10 stderr empty in B1–B3 · B11 an unreadable `AGENTS.md`: the project text, exit 0.
- **`tests/product-loop.test.sh <plan-gate.sh> <manager-bootstrap.sh>`** — L1–L15, the milestone, last line `PASS 15/15`: L1 a product repo's session start names `glab:product-manager` · L2 a project repo's names `glab:manager` `[N3]` · L3 the rules and their index in the store, each rule file at most 8192 bytes and on one index line · L4 the brief names rule files that exist · L5 the project plan carries the brief line and `check` refuses before any report · L6 report r1, its copies' digest equal to the report's · L7 a second report while r1 waits is refused · L8 the simulated audit `CONFLICTS: 1` and verdict r1 `REJECTED` with its reason · L9 `check` refuses · L10 the amended plan, report r2, verdict r2 `ACCEPTED` · L11 `check` passes: development may start · L12 `plan.md` edited after acceptance: `check` refuses; report r3, verdict r3 `ACCEPTED`, `check` passes · L13 the brief edited after acceptance: `check` refuses · L14 a second project: two `REJECTED`, a third by `product-manager` refused, by `user` written · L15 nothing was written in the store outside `docs/` and `briefs/`.
- Coverage, per step: A1 → T1–T22, L5–L15; A3 → B1–B11, L1, L2; P1–P9, J1–J11, R1–R6 → their posts and the gates only (Markdown has no runtime, `AGENTS.md` *Gates*); not covered by any case: LP1–LP5 (`evidence.md`), accepted because each needs a live, logged-in session.

## The chosen boundary

The product level is seven skills and two agents inside `glab`, named
`glab:product-*`; the level is chosen per repo by one `AGENTS.md` line that
the session-start hook reads; the levels exchange files in a plain shared
folder whose formats one script writes and checks; the project level changes
at three points — Stage 1 reads a brief, a new Stage 1c reports and waits,
and `glab:develop` refuses a plan from a brief without a matching
`ACCEPTED`. Proven against the code: E2 (names), E6–E7 (the hook), E8 (the
digest). The other boundaries and why they lost: `evidence.md` *Rejected
boundaries*.

## Follow-ups

- **FU-P1** — move the every-level manager rules (`glab:manager` Rules 0b, 0c, 0d, 2, 3, 5) into a shared skill before the delivery level is built.
- **FU-P2** — a hard boundary for the main session: `Skill(...)` permission rules per level, or a hook that refuses another level's skill; needs a live test first.
- **FU-P3** — the Notion view of the store, read-only, never the gate.
- **FU-P4** — the live tests LP1–LP5 (`evidence.md`), run by the user after install.
