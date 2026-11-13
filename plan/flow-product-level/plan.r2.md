tier: full — new file formats that cross between sessions (brief, report, verdict) and a gate that decides when development may start.

# Plan — flow-product-level

The request, goals and final check are in `master.md`; the findings, by id
`E<n>`, are in `evidence.md`; the answers in `questions.md`. The steps are in
five files, read in order: `steps-1-scripts.md` (A1–A2),
`steps-1b-scripts.md` (A3–A5), `steps-2-product.md` (P1–P9),
`steps-3-project.md` (J1–J12), `steps-4-repo.md` (R1–R6). A finding id in
brackets — R1, F8, I12 — names the plan-check finding of round 1 the line
answers (`check-repo.md`, `check-facts.md`).

## Decisions

- effort: high (the user's words: "high (Recommended)"), for the session
- Tier full: the brief, report and verdict files are a wire format between sessions, and `plan-gate.sh check` decides whether development may start (`glab:manager` *Pick the tier*).
- One plan, not sub-plans: there is one milestone, the product ⇄ project loop, and no part runs alone; the steps are split into five files for size only.
- Q1, answered: `glab:product-planner` and `glab:product-analyzer` run on `opus` ("Opus for both").
- Q2, answered: today's project skills and agents keep their names ("Keep names"); the product level's are `glab:product-*`.
- N1: hyphenated level prefixes under `glab` — `glab:product-*` — because a nested skill folder is not loaded and the manifest `skills` key gives no level segment (E1, E2).
- The seven product skills keep the agreed bare names behind the `product-` prefix: `product-manager`, `product-plan`, `product-plan-analyze`, `product-project-brief`, `product-project-plan-report`, `product-project-plan-analyze`, `product-project-plan-verdict`.
- Agents stay flat files (`agents/product-planner.md`, `agents/product-analyzer.md`): `plugin details` does not list a subfolder agent and the model and skills gates glob `agents/*.md` (E3).
- The level is a line `glab-level: <level>` in the repo's `AGENTS.md` (C1), not an environment variable: it belongs to the repo the session runs in (*Rejected boundaries* in `evidence.md`).
- No level line, or no `AGENTS.md`, is the project level: every existing repo keeps today's session start, with one level line above it.
- Any `glab-level:` line whose value is not built — `delivery`, `support`, `Product`, `product2`, `product # note` — runs as project with the warning, because the value is checked after the line is found [R10]: the project level never touches a live system.
- The level is read from `$CLAUDE_PROJECT_DIR`, else `$PWD`, and from the top of its git work tree when that folder has no `AGENTS.md`, so a session started in a subfolder finds it [F4]; the warning's stderr copy is for debugging only, since Claude Code shows no stderr of a hook that exits 0 [F5].
- The shared store is named by a line `glab-shared-store: <path>` in the repo's `AGENTS.md`, else in `~/.claude/host.md` (C2); every committed file names store paths relative to the store, so no machine path is committed.
- The store layout is the agreed one plus `plan.r<n>/`, byte copies of the hashed plan files beside each report, because the product side cannot read the project's repo (C3); `glab:product-manager` *The shared store* states it once and the other product skills point there, so a Notion view later changes one skill and the script (I6; FU-P3).
- The digest covers the files a build follows (C4) and leaves out round copies `*.r<n>.md`, version copies `*.v<n>.md`, any `plan.r<n>/` folder and every working file [R2]: a `REJECTED` makes round copies, which must not move it. A1's third post and T2 fail if one is hashed.
- The manager's own record lines after a report go to `plan/{slug}/after-verdict.md`, outside the digest (C11) [R1]: an `- effort:`, `- model:` or `- round 3:` line, a Rule 3 decision or overrule, a question's answer. So `check` refuses any change to what the product accepted and never refuses bookkeeping; proven on a throwaway build by T18 and L13 (an edited step refused) and T23 and L12 (added record lines accepted), E14.
- `glab:manager` Stage 1c owns that rule; `glab:session-rules` *Where a record line goes*, Stage 1's question answers and `glab:develop`'s precondition point at it, and the develop gate still runs on every dispatch, fix rounds included [R1].
- One script, `plugins/glab/scripts/plan-gate.sh`, computes the digest and writes the report and the verdict (C5–C8): both sides must compute the same bytes, and the formats then have one owner and one test.
- Every new script and test is written in full in the steps, proven green and shellcheck clean on a throwaway build (E16), so the plan check can run them; the developer writes each byte for byte and the post `X` compares.
- Each script step's last post runs the built file against the plan's text of its partner, so each step is proven by its own file alone and skipping one turns only its own posts red (E17).
- The report is sent after every approval of the plan (master's, and `plan.md`'s at full tier), as Stage 1c: an approval line written after the report would change the digest.
- `report` and `check` refuse when the brief changed since the plan quoted it: a plan accepted against an older brief answers an older request.
- `check`'s refusals come in a fixed order — the brief, a report still waiting, no verdict for this brief, a malformed verdict, `REJECTED`, the plan — and a latest verdict that answers an older brief is `no verdict for this brief` (C8) [R11].
- Reports and verdicts are parsed by one rule (C8) [R4]: each field from its own line above the first `## ` heading, exactly once, matching its pattern; anything else is `REFUSED: verdict r<n> is malformed` or `report r<n> is malformed`; `r<n>` numbers are compared as numbers, so r10 follows r9 (T24, T25, T27).
- The rejection cap counts `REJECTED` verdicts per project since its last `ACCEPTED`, over every brief the project has had, so a new brief does not reset it [R3, I8]. At two, `plan-gate.sh` refuses every verdict by `product-manager`, `ACCEPTED` too, and writes a verdict `by user` only when its reason opens with `user: "<the user's words>"` (T15, T16, T26, L15).
- The count restarts at an `ACCEPTED` because, without it, one bad stretch would hand every later verdict of the project to the user; at the cap that `ACCEPTED` can only be the user's.
- `by user` is an argument the calling session chooses, and both sessions can write the store, so the cap holds as far as the sessions keep to the skill text; this known limit is stated in `glab:product-manager` *The cap*, in README *Levels* and in the product spec [R12].
- The product manager writes the verdict itself from the audit; the user decides at the cap, and on anything that meets a `glab:session-rules` Rule 3 ask-condition.
- The user approves every product plan explicitly: it decides what the product is (`glab:session-rules` Rule 3, fourth condition).
- The product rules are the user's: the product planner drafts new ones in the product plan and writes them to the store only after that plan's approval; one topic per file, at most 8192 bytes, and one index line each; a rule file never changes as a Rule 1 trivial change.
- `product-plan.md` keeps the plan size budget, 49152 bytes, and the size-budget entry of `AGENTS.md` names it [R7].
- The product agents have no `Skill` tool: their `skills:` list is all they load, which makes the boundary hard for them (E11; documented, F11).
- The boundary is each level manager's explicit list *Your skills — this level only*, and the rule that binds to it — invoke no skill not on your manager's list — is written once, in `glab:session-rules` *The level boundary* [I12, F14]: the skill listing can drop descriptions, so a description prefix is a hint only.
- A skill or agent that serves every level — `glab:session-rules`, `glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`, `glab:commit`, `glab:push`, the agent `glab:committer` — carries no level prefix and may be on any list; every other one's description begins `Product level — ` or `Project level — ` (N2, amended).
- Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, the round caps and the handoff line move from `glab:manager` into the new skill `glab:session-rules` (J2), which both managers load [I12, R6, R7]: both act on them, and the product manager may not read `glab:manager`. This was FU-P1; it is pulled forward because no other place keeps each rule once.
- Rule 4 stays in `glab:manager`: one session's surface is a project-level fact; the moved Rule 5 names it as `glab:manager` Rule 4.
- The moved text keeps its words; one reading rule at its top maps a stage it names to the stage of the same role at the product level, so the moved rules are not rewritten twice (J2).
- Rule 5's list gains the two product roles on `opus`, and every file the model fact lives in changes with it (J2, R3, R4, R5) [R5].
- `glab:commit` and `glab:push` name the stage of the manager of either level, and the rule on a commit on `main` moves from `glab:manager` Stage 6 into `glab:commit`, which both managers run [R6].
- Every pointer to a moved rule names `glab:session-rules` (J12), `scripts/context-size.sh`'s comments included; its code and test do not change.
- `glab:audit`'s two project-scoped sentences — use `glab:plan` when the analysis leads to changing code, and the record of Stage 8 — stay: they speak of changing code and recording, which only the project level does.
- The session-start text points each level at its own manager and both at `glab:session-rules`; `glab:bootstrap` steps 2 and 4 name the manager and the pipeline by level [I12, R6].
- A plan made from a brief must quote it: item 8 of the acceptance checklist greps the brief line, since without it nothing reports the plan and nothing gates it [I2].
- `glab:product-project-plan-analyze` gives the audit the brief, the report, `plan.r<n>/`, the product plan's `## Decisions` and the rule files the brief names — the product's gates, with the brief's `## Acceptance` [I3]; it finds the product plan as the one whose `## Projects` has `### <project>`, because a brief cites nothing the project cannot read.
- Project sessions are started on the user's go-ahead once per batch of briefs, by host [LP4, F8, F9, I9, F10]: in the desktop app through its session tools, in the CLI by `cd <project repo> && claude --bg --add-dir <store> "take the brief at …"` with its caveats (workspace trust, a worktree, a permission prompt that waits for the user) and `claude --resume <id> --bg "<message>"` to resume, or by the user by hand, always valid.
- What no live run has shown stays UNVERIFIED and is said in the skill: that a session's Bash tool can run `claude --bg`, and that the desktop tools reach a session the product session did not start (LP4).
- A project session that sent its report tells the product session where the host's tools reach it, else asks the user to, ends its turn with the wait in the handoff file, and is resumed by a message.
- On `REJECTED`: round copies, a new planning agent amends from the verdict's reason as its findings, one Stage 1b delta round per verdict outside Stage 1b's cap (as Stage 3's round after a review fix is outside Stage 3's), the approvals the tier needs, then report `r<n+1>`.
- A `REJECTED` whose fix needs `master.md` is a changed request, not an amendment: an approved master is never amended [R13].
- Three new test files, one per contract: `plan-gate.test.sh` (the script), `manager-bootstrap.test.sh` (the hook), `product-loop.test.sh` (the walkthrough, run by the user to see the loop).
- The walkthrough writes what each agent would write from fixtures and runs the real scripts; it calls no model and writes only under `$TMPDIR`.
- The walkthrough's trace, `PRODUCT_LOOP_SHOW=1`, is shown to the user by the manager after the build (X2), as how the product skills work: brief, report, verdict, a rejection, an acceptance, a refused edited plan and the cap [I11].
- `manager-bootstrap.sh` is rewritten whole (A3); every comment of its old header is carried, brought up to date.
- The product level's record goes to a new `docs/specs/product.md`, named in `AGENTS.md`'s `plan/` rule; `workflow.md` gets the project edges.
- `glab:product-project-plan-report` keeps its agreed name though the project manager runs it: the product chain sets the contract, and its description says `Project level`.
- `glab:product-analyzer` is read-only and returns its findings as text, as `glab:plan-analyzer` does; the verdict's reason is taken from it.
- The version is raised once, to `0.14.0`, in the commit that changes `plugins/glab/` (`AGENTS.md` *Rules*).

## Contracts

These are the facts every step cites. Where a file states one, it states it as here.

- **C1 — the level line.** In the repo-root `AGENTS.md`, the first line that begins `glab-level:`, a trailing `\r` removed; its value is the rest of the line with the blanks around it dropped. `product` and `project` are built. No such line, no file, an unreadable file → `project`. Any other value, an empty one included → `project` and the warning `glab: level "<value>" is not built in this version of glab; this session runs at the project level`, the value shown in printable characters, at most 40. Reserved for later levels: `delivery`, `support`. The repo is `$CLAUDE_PROJECT_DIR`, else `$PWD`, else — when that folder has no `AGENTS.md` — the top of its git work tree.
- **C2 — the store line.** `glab-shared-store: <path>` — the first such line in the repo-root `AGENTS.md`, else in `~/.claude/host.md`; `~/` is the home directory. Read by the manager of each level (skill text), never by the hook, and passed to `plan-gate.sh` as an argument. None: the product level stops and asks the user; the project level needs it only for a brief.
- **C3 — the store layout.**

      <store>/docs/product-rules/index.md       one line per rule file: - <name>.md — <what it covers>
      <store>/docs/product-rules/<name>.md      one topic, at most 8192 bytes
      <store>/briefs/<project>/brief.md         written by glab:product-planner; the project's request
      <store>/briefs/<project>/report.r<n>.md   written by plan-gate.sh report
      <store>/briefs/<project>/plan.r<n>/       the hashed plan files, copied by plan-gate.sh report
      <store>/briefs/<project>/verdict.r<n>.md  written by plan-gate.sh verdict
      <store>/releases/                         reserved for the delivery level; nothing writes it yet

  `<project>` is kebab-case, `[a-z0-9-]+`. `<n>` starts at 1, has no leading zero, and is compared as a number.
- **C4 — the plan digest.** Under the plan folder, recursively, pruning every folder named `plan.r<digits>…`, the regular files named exactly `master.md`, `index.md`, `plan.md`, `questions.md`, or matching `steps-*.md`, but none matching `*.r[0-9]*.md` or `*.v[0-9]*.md`; listed as `./<path>`, sorted under `LC_ALL=C`; for each, the line `<sha256 of the file>  ./<path>`, in that order; the digest is the sha256 of those lines, 64 lowercase hex characters. `shasum -a 256` stands in where `sha256sum` is missing, and gives the same digest. Only `plan-gate.sh digest` computes it (E8).
- **C5 — the brief line.** In a project plan's `master.md`, under `## Request`: `- brief: briefs/<project>/brief.md sha256 <64 hex>`, the hash being `sha256sum` of `brief.md` as the planner read it. The first line matching `^- brief: briefs/([a-z0-9-]+)/brief\.md sha256 ([0-9a-f]{64})$`, after a trailing `\r` is removed, counts.
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
      brief-sha256: <sha256 of brief.md now>
      by: product-manager | user
      date: <YYYY-MM-DD>

      ## Reason
      <the reason file's text; never blank; by user, its first line user: "<the user's words>">

- **C8 — `plan-gate.sh`.** Modes and arguments: `digest <dir>`; `report <plan dir> <store> [<note file>]`; `verdict <store> <project> ACCEPTED|REJECTED product-manager|user <reason file>`; `check <plan dir> <store>`. Exit 0 done, 1 refused, 2 usage (an unknown mode, wrong arguments or words, a folder or file that does not exist) or a failed write. stdout: `digest` the digest; `report` and `verdict` the path written; `check` `ACCEPTED r<n> <digest>`. Every refusal is one stderr line beginning `REFUSED: `, prints nothing on stdout and writes nothing; every write goes to a temporary name in the folder it lands in and is moved into place. **Parse rule:** a field of a report or verdict is read only from its own line above the file's first `## ` heading; the line is there exactly once and its whole value matches its pattern — `ACCEPTED|REJECTED`, `r<n>` equal to the file's own number, 64 lowercase hex, `[0-9]+`, `product-manager|user`, `YYYY-MM-DD` — and a verdict's reason has a non-blank line; else the file is malformed. The refusals, exactly and in this order:
  - `report`: `REFUSED: no brief line in master.md` · `REFUSED: the brief changed since the plan was written; plan again` · `REFUSED: report r<n> has no verdict yet` · `REFUSED: plan.r<n>/ is there without report r<n>; look at it and remove it by hand`.
  - `verdict`: `REFUSED: no report to decide` · `REFUSED: report r<n> is malformed` · `REFUSED: report r<n> already has a verdict` · `REFUSED: the copies in plan.r<n>/ do not match report r<n>` · `REFUSED: the brief changed since report r<n>` · `REFUSED: empty reason` · `REFUSED: verdict r<k> is malformed` · `REFUSED: a verdict by user starts its reason with the user's words: user: "<words>"` · `REFUSED: two REJECTED verdicts since the last ACCEPTED; the next verdict is by user`.
  - `check`: `REFUSED: no brief line in master.md` · `REFUSED: the brief changed since the plan was written; plan again` · `REFUSED: report r<n> has no verdict yet` · `REFUSED: no verdict for this brief` (none, or the latest answers an older brief) · `REFUSED: verdict r<n> is malformed` · `REFUSED: the latest verdict r<n> is REJECTED` · `REFUSED: the plan changed since verdict r<n> accepted it; report again`.

  `check` reads the highest-numbered verdict only; `verdict` reads every earlier one, for the cap. `report` numbers the next report one past the highest existing one.
- **C9 — the session-start texts.** Both texts are in A3's script: the level line first — `Level: project — no other glab-level line in AGENTS.md says otherwise.` or `Level: product — glab-level: product in AGENTS.md.` — then today's points 1, 3 and 4, and a point 2 that loads `glab:bootstrap`, then three skills: the manager of the level (`glab:manager` — "the operating model of the project level", or `glab:product-manager` — "the operating model of the product level"), `glab:session-rules` and `glab:security`; the last line points at `glab:session-rules` Rules 1 and 0b. A warning (C1) goes first, above the level line. Each text stays under 10,000 characters. stdout is one JSON object `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":<text>}}`, or the plain text when `jq` fails; exit 0 on every path; messages only on stderr.
- **C10 — the audit and check verdict lines.** `glab:product-analyzer`'s product plan check ends `SOUND` or `NOT SOUND: <n> findings`; its project plan audit ends `NO CONFLICT` or `CONFLICTS: <n>`; both use `BLOCK: target unresolved` when a file it needs is missing.
- **C11 — the frozen plan.** From a project plan's first report on, its files in C4's set change only by an amendment that is reported again. Every record line the manager would write into them — `- effort:`, `- model:`, `- round 3:`, a Rule 3 decision or overrule, a question's answer — goes to `plan/{slug}/after-verdict.md`, which C4 leaves out; a line there never changes a step, a goal or a decision the product accepted. The freeze lifts only for the amendment after a `REJECTED`, until the next report.

## Milestone

The product ⇄ project loop runs end to end without a model:
`bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh`
prints `ok` for L1–L16 and `PASS 16/16`. With `PRODUCT_LOOP_SHOW=1` it also
prints, on stderr, the trace of the loop — each scene, each command a session
runs, each refusal, and the text of every store file written — so the user
can read how the skills work.

## Phases

- **before** — B1–B3, below.
- **processing** — A1–A5, P1–P9, J1–J12, R1–R6, in that order, in the steps files; J2 before any other step that edits `skills/manager/SKILL.md`.
- **after** — X1–X6, below.

### before

- **B1** — Branch `flow-product-level` from `main`; `main` = `origin/main`, no tracked change. post: `` test "$(git rev-parse --abbrev-ref HEAD)" = flow-product-level && test -z "$(git status --short --untracked-files=no)" && echo ok || echo FAIL ``
- **B2** — `export TMPDIR=/data/tmp/claude` (or the host file's temp directory) and run every gate in `AGENTS.md` *Gates* as it stands; all green as it states (`Skills (13)`, `Agents (7)`, `PASS 35/35`, `PASS 24/24`; E18). post: the pasted output.
- **B3** — `questions.md` Q1 and Q2 carry the user's answers on their Answer lines. post: `` command grep -c '^- \*\*Answer:\*\* the user chose' plan/flow-product-level/questions.md `` prints `2`.

### after

- **X1** — Run every gate in the changed `AGENTS.md` *Gates*; green exactly as its changed *Green is* says (the expected output is E18's).
- **X2** — The milestone command above prints `PASS 16/16`. Then run `PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>"$TMPDIR/product-loop-trace.txt"`; the manager shows the user that trace as how the product skills work, and removes the file afterwards. It never goes into the plan folder or a commit.
- **X3** — Every post of A1–R6 prints `ok`: paste the helper below into a shell at the repo root, with `TMPDIR` exported, then `for f in plan/flow-product-level/steps-*.md; do case $f in *.r[0-9]*.md) continue ;; esac; sed -n 's/^- post: `` \(.*\) ``$/\1/p' "$f"; done | while IFS= read -r c; do eval "$c"; done | sort | uniq -c` prints one line, `214 ok`. The `case` leaves out the round copies, whose posts are the round's.
- **X4** — No machine path in a new or changed file: `git diff --name-only main -- plugins tests README.md AGENTS.md host.example.md | xargs command grep -n -E '/home/|/data/|/Users/|/tmp/' ` prints nothing but the lines that already held them on `main` (`AGENTS.md`'s `/tmp` hazard notes, `host.example.md`'s author's paths).
- **X5** — `wc -c` on `master.md`, `plan.md`, `evidence.md` and each `steps-*.md` of this folder: each at most 49152.
- **X6** — Back-out: `git revert` the commit. An installed copy is pinned to its version string, so a user on 0.13.0 is unaffected until they update; a repo with `glab-level: product` then runs as project under 0.13.0, which ignores the line, and a store written by 0.14.0 is plain files that nothing reads.

### The post helper

    J() { tr '\n' ' ' < "$1" | tr -s ' '; }
    P() { if [ -f "$1" ] && J "$1" | command grep -q -F -- "$2"; then echo ok; else echo "FAIL $1: $2"; fi; }
    N() { if [ -f "$1" ] && ! J "$1" | command grep -q -F -- "$2"; then echo ok; else echo "FAIL $1: still $2"; fi; }
    B() { awk -v f="$2" '/^~~~[a-z]* file=/ && substr($0, index($0, " file=") + 6) == f { on = 1; next } on && $0 == "~~~" { exit } on' "plan/flow-product-level/$1"; }
    X() { if B "$1" "$2" | cmp -s - "$2"; then echo ok; else echo "FAIL $2 differs from its text in $1"; fi; }

`P` says the phrase is there and `N` that it is gone, over the file's text
joined into one line with runs of spaces squeezed, so a phrase matches
however the developer wraps it. A phrase in a step is the exact text the post
looks for, written once with single spaces; the developer writes the prose
around it. `B <steps file> <path>` prints the text a steps file gives for
`<path>`, between its `~~~… file=<path>` line and the next `~~~`; `X` says
the built file is that text, byte for byte.

## Tests

- **`tests/plan-gate.test.sh <plan-gate.sh>`** — T1–T29, each `ok T<n> <what>`, last line `PASS 29/29`; every refusal checked for its exact line, an empty stdout and an unchanged store:
  T1 `digest` prints 64 hex characters, exit 0 · T2 it ignores round copies (`steps-1.r1.md`, `plan.r1.md`, `plan.r10.md`, a sub-plan's `plan.r2.md`), `master.v1.md`, a `plan.r1/` folder, `evidence.md`, `map-x.md`, `result.md`, `integration.md`, `after-verdict.md` · T3 an edit to `master.md`, `index.md`, `plan.md`, a sub-plan's `plan.md`, `steps-1.md` or `questions.md` changes it · T4 the copy `report` makes has the plan's digest · T5 `digest` of a missing folder exits 2 · T6 `report` writes `report.r1.md` with C6's lines in order, the note, and `plan.r1/` · T7 a second `report` while r1 has no verdict is refused · T8 `report` after the brief changed is refused · T9 `report` with no brief line is refused · T10 `verdict … ACCEPTED` writes C7's lines and the reason · T11 `verdict` over tampered copies is refused · T12 `verdict` after the brief changed is refused · T13 a second verdict for one report is refused · T14 an empty or blank reason is refused · T15 after two `REJECTED`, `REJECTED` and `ACCEPTED` by `product-manager` refused, by `user` without the words refused, with them written · T16 a new brief does not reset the count · T17 `check` after `ACCEPTED` prints `ACCEPTED r1 <digest>`, exit 0 · T18 `check` after a `plan.md` edit is refused, exit 1 · T19 `check` refuses with no verdict, a report waiting, the latest `REJECTED`, a changed brief, and a verdict for an older brief · T20 an unknown mode, wrong arguments or a bad word exit 2 with the usage line · T21 with a `PATH` that lacks `sha256sum` but has `shasum`, the same digest · T23 after `ACCEPTED`, `after-verdict.md` lines and a round copy leave `check` passing · T24 a malformed verdict — a repeated line, a hash that is not hex, the wrong report, no reason — and a malformed report are refused · T25 r10 is read after r9, and the next report is r11 · T26 an `ACCEPTED` ends the count · T27 a reason that quotes `verdict: ACCEPTED` changes nothing · T28 a copy folder left without its report is refused, not removed · T29 a CRLF `master.md`'s brief line is read · T22, last: no temporary file is left in any store.
- **`tests/manager-bootstrap.test.sh <manager-bootstrap.sh>`** — B1–B13, last line `PASS 13/13`: B1 no `AGENTS.md`: exit 0, stdout one JSON object whose only key is `hookSpecificOutput`, `hookEventName` `SessionStart`, the project text · B2 `glab-level: product`: the product text, naming `glab:session-rules` · B3 `glab-level: project`: the same text as B1 · B4 `glab-level: delivery`: the project text with C1's warning first, and the warning on stderr · B5 a `PATH` without `jq`: the plain text, exit 0 · B6 `CLAUDE_PROJECT_DIR` unset: the level read from `$PWD/AGENTS.md` · B7 a CRLF `AGENTS.md`: the level still read · B8 every text, a warning included, under 10,000 characters · B9 only the first level line counts · B10 stderr empty for the built levels and for none · B11 an unreadable `AGENTS.md`: the project text, exit 0 · B12 `Product`, `product2`, `product # note`: the warning, the project text · B13 a session started in a subfolder of its git repo: the level read at the repo's top.
- **`tests/product-loop.test.sh <plan-gate.sh> <manager-bootstrap.sh>`** — L1–L16, the milestone, last line `PASS 16/16`: L1 a product repo's session start names `glab:product-manager` and not `glab:manager` · L2 a project repo's names `glab:manager` · L3 the product plan, its approval, the rules and their index in the store, each rule file at most 8192 bytes and on one index line · L4 the brief names rule files that exist · L5 the project plan carries the brief line and `check` refuses before any report · L6 report r1, its copies' digest equal to the report's · L7 a second report while r1 waits is refused · L8 the simulated audit `CONFLICTS: 1` and verdict r1 `REJECTED` with its reason · L9 `check` refuses · L10 the amended plan with its round copy, report r2, verdict r2 `ACCEPTED` · L11 `check` passes: development may start · L12 a `- model:` and a `- round 3:` line in `after-verdict.md`: `check` still passes · L13 a step edited after acceptance: `check` refuses; report r3, verdict r3 `ACCEPTED`, `check` passes · L14 the brief edited after acceptance: `check` refuses · L15 a second project: two `REJECTED`, then `REJECTED` and `ACCEPTED` by `product-manager` refused, the user's `ACCEPTED` written, `check` passes · L16 nothing was written in the store outside `docs/` and `briefs/`, and no temporary file is left.
- Coverage, per step: A1 → T1–T29, L5–L16, and its R2 post; A2 → its run against A1's text; A3 → B1–B13, L1, L2; A4 → its run against A3's text; A5 → L1–L16; P1–P9, J1–J12, R1–R6 → their posts and the gates only (Markdown has no runtime, `AGENTS.md` *Gates*); J12.4 changes comments only, so `tests/context-size.test.sh` and its gates are its proof. Not covered by any case: LP1–LP5 (`evidence.md`), accepted because each needs a live, logged-in session.

## The chosen boundary

The product level is seven skills and two agents inside `glab`, named
`glab:product-*`, beside one skill both levels load, `glab:session-rules`,
which holds the rules every level's manager acts on; the level is chosen per
repo by one `AGENTS.md` line that the session-start hook reads; each manager
names the skills of its level, and that list binds; the levels exchange files
in a plain shared folder whose formats one script writes and checks; the
project level changes at four points — Stage 1 reads a brief, a new Stage 1c
reports, freezes the hashed plan and waits, the acceptance checklist requires
the brief line, and `glab:develop` refuses a plan from a brief without a
matching `ACCEPTED`. Proven against the code: E2 (names), E6–E7 (the hook),
E8 (the digest), E14–E17 (the scripts, the record lines, the posts). The
other boundaries and why they lost: `evidence.md` *Rejected boundaries*.

## Follow-ups

- **FU-P1** — closed in this plan: the every-level manager rules move into `glab:session-rules` (J2), because the product manager may not read `glab:manager`.
- **FU-P2** — a hard boundary for the main session: `Skill(...)` permission rules per level, or a hook that refuses another level's skill; feasible by the documented `Skill(name)` syntax (F15), needs a live test first.
- **FU-P3** — the Notion view of the store, read-only, never the gate; it changes `glab:product-manager` *The shared store* and `plan-gate.sh` only.
- **FU-P4** — the live tests LP1–LP5 (`evidence.md`), run by the user after install.
- **FU-P5** — a hard hold on `by user`: today any session can pass it (R12); a check that the words came from the user needs a mechanism this plan does not have (UNVERIFIED that Claude Code offers one).
