# Product — spec

The product level of `glab` and the product ⇄ project loop: the product
manager, its skills and agents, the shared store, the file contracts
between the two levels and the hash gate, the rejection cap, the start of
project sessions, and the walkthrough that plays the loop. Owned by
`plugins/glab/skills/product-manager/SKILL.md` and the six other
`plugins/glab/skills/product-*/SKILL.md`, the agents
`plugins/glab/agents/product-planner.md` and
`plugins/glab/agents/product-analyzer.md`,
`plugins/glab/scripts/plan-gate.sh` (its header comment),
`tests/plan-gate.test.sh`, `tests/product-loop.test.sh` with
`tests/fixtures/product-loop/`, `README.md` *Levels* and *Try the product
loop*, and `host.example.md` *glab shared store*. The project side of the
loop — `glab:session-rules`, the level boundary, the level line and the
session-start text by level, project Stage 1c and the develop gate — is in
`docs/specs/workflow.md`; the version, the gates and the scripts' contracts
are in `docs/specs/marketplace.md`. Stated as of `ce1a933` (`glab`
`0.14.0`), the record of `flow-product-level`, and its `plan-gate.sh`
lines (the store's filesystems, the claims, the takeover, the held
signals, the publish, the tests, the known limits and follow-ups) as of
`2724086` (`glab` `0.14.1`), the record of `flow-gate-hardening`, and its
`docs-lifecycle` lines (stage P7 Roadmap and the roadmap page, the product
plan as an uncommitted working file, the product agents' descriptions) as
of `3ed6746` (`glab` `0.16.0`, rebase-merged as `d2ca05b`), and its
`p7-delivery-gate` lines (P7's start condition, P6's done condition, the
`## Delivered` line) as of `afda097` (`glab` `0.16.1`), and its
`lifecycle-hardening` lines (P6's "nothing to commit" test, `## Delivered`
after the last `## Approval`, the brief's precondition) as of `bf9c73f`
(`glab` `0.16.2`, PR #22, not merged at this record), and its
`script-hardening` lines (`create_line`'s codes and the exit 2 after a
failed write, the pre-open guard, `command exec`, the store-filesystem
pointer, T52–T56) as of `64b4e57` (`glab` `0.16.3`, PR #23, not merged at
this record); where
this file and an owning file disagree, the owning file is right.

## How it works now

- **P6, `## Delivered` and the brief as of 0.16.2** (`glab` 0.16.2,
  `bf9c73f`, `lifecycle-hardening`; `glab:product-manager` *The product
  pipeline*, the owner; `[lifecycle-hardening/plan.md D4]`, `D10`, `D14`,
  `D20`, `D21`, `D24` item 3). This bullet supersedes the next one where
  they disagree: its P6 test, "has its `## Delivered` line", "at the end
  of", the brief's precondition and that refusal's message. P6 is done
  when it landed and was confirmed on the user's go-ahead, or when there
  is nothing to commit: in the product repo `git status --short --branch`
  exits 0 and prints one line, `## <branch>...origin/<upstream>`, with no
  bracket or exactly `[behind <n>]`; `[gone]`, `[ahead`, `No commits yet`,
  no upstream, a detached HEAD or exit ≠ 0 fail it
  (`product-manager/SKILL.md:54`; `D10`; the upstream a remote-tracking
  `origin/` branch, `D20`, the line already read, chosen over `@{push}`).
  P7 starts when each project of `## Projects` has `ACCEPTED` as its
  latest verdict, P6 has landed or had nothing to commit, and
  `product-plan.md` has a `## Delivered` line after the last `## Approval`
  (`:60`); a plan approved again after delivery needs a new `## Delivered`
  before P7, as `[p7-delivery-gate/plan.md D7]` wants. The table's
  Approval and Delivered rows say each line is "appended to
  `product-plan.md`" (`:49`, `:55`; `D14`), no longer "at the end of".
  `glab:product-project-brief`'s precondition
  (`product-project-brief/SKILL.md:9`): `product-plan.md` "has its
  `## Approval` line, and no `## Delivered` after the last `## Approval`";
  "Otherwise → stop: a brief is written only from a plan the user
  approved, and a delivered plan takes none until the user approves it
  again." So a delivered slug still takes no brief, and one approved again
  after delivery takes briefs. The roadmap page and
  `glab:product-analyzer`'s roadmap check carry "the last `## Delivered`
  line, with the user's words" (`product-plan/SKILL.md:48`,
  `product-analyzer.md:40`; `D4`, `D21`). The plan folder is removed later,
  at a session start (`:60`), now only on the user's word
  (`glab:session-rules` Rule 2; `docs/specs/workflow.md` *The docs
  lifecycle as of 0.16.2*).

- **P7 waits for the user's delivery confirmation** (since `glab` 0.16.1,
  `afda097`, `p7-delivery-gate`; `glab:product-manager` *The product
  pipeline*, the owner; `[p7-delivery-gate/plan.md D1]`–`D3`, `D6`, `D7`,
  `D9` A3, A8). This bullet supersedes the next one's delivered sentence
  ("each project … has `ACCEPTED` as its latest verdict and P6 has
  landed") and `[docs-lifecycle/plan.md D9]`. P7 starts when each project
  of `## Projects` has `ACCEPTED` as its latest verdict, P6 has landed or
  had nothing to commit, and `product-plan.md` has its `## Delivered`
  line. `ACCEPTED` approves a project's plan, not what it built
  (`glab:project-plan-report`), so it alone no longer starts P7
  (`[p7-delivery-gate/plan.md F2]`). Once every latest verdict is
  `ACCEPTED`, or when the user raises it, the product manager asks the
  user whether every project of `## Projects` has delivered; on their
  explicit yes it writes, at the end of `product-plan.md`, `## Delivered`,
  then `- confirmed by the user, <date>, in chat: "<their words>"`. No
  `## Delivered` line → no P7. P6 is done when it landed and was
  confirmed on the user's go-ahead, or when there is nothing to commit —
  the product repo's `git status --short` prints nothing — since with the
  store outside the product repo P1–P5 write only the ignored `plan/` and
  the store (`[p7-delivery-gate/plan.md F3]`, `D2`). The pipeline table
  gains ``| — | Delivered | the user, always, explicitly | the `## Delivered`
  line at the end of `product-plan.md` | the user's words | — |`` after P6,
  as the `## Approval` row sits before P2 (`D6`), and its last-column
  sentence reads "P2 to P5 and Delivered have none" (`D9` A6). The roadmap
  page carries the `## Delivered` line with the user's words
  (`glab:product-plan` *The roadmap*), and `glab:product-analyzer`'s
  roadmap check finds it `carried` or missing (`D9` A3). The plan folder's
  removal is unchanged: it still follows P7's roadmap, which now waits for
  the `## Delivered` line (`D3`). Once `## Delivered` is written, a
  delivered slug takes no new brief, because `glab:product-project-brief`'s
  precondition — `product-plan.md` "ends with its `## Approval` line" —
  no longer holds; new work becomes a new product slug (`D7`). That
  refusal's message, "a brief is written only from a plan the user
  approved", names approval, not delivery: accepted as it is (`D9` A8).

- **P7 Roadmap, and the product plan as a working file** (since `glab`
  0.16.0, `3ed6746`, `docs-lifecycle`; `glab:product-manager` *The product
  pipeline*, the owner; `[docs-lifecycle/plan.md D9]`–`D14`, `D29`, `D33`,
  `D43`). This bullet supersedes any line below where they disagree. A
  product slug is delivered when each project of `product-plan.md`
  `## Projects` has `ACCEPTED` as its latest verdict and P6 has landed;
  then P7 runs: `glab:product-planner` writes `docs/roadmap/<slug>.md` in
  the product repo, not the store (`glab:product-plan` *The roadmap*);
  `glab:product-analyzer`'s roadmap check reads the page whole, not a diff,
  against `plan/<slug>/product-plan.md`, its round copies and the store's
  verdicts, and ends `SOUND` or `NOT SOUND: <n> findings`; one fix round
  by a new planner, then the recheck, never a third (`glab:session-rules`
  *Round caps*); still `NOT SOUND`, stop and tell the user (the P7 bullet,
  `[docs-lifecycle/review.r1.md 7]`); then `/glab:commit` and `/glab:push`
  on the user's go-ahead. Its pipeline row: `| P7 | Roadmap | … |
  docs/roadmap/<slug>.md of the product repo | SOUND, committed, pushed on
  the user's go-ahead | 8 |`. The page holds the business plan (path,
  sha256, the user's words verbatim), the goals, per project its goal,
  scope, out of scope, rule files, seams, brief path and final verdict, the
  rules added, every `## Decisions` line with its reason, the answered
  questions with the user's words, the round history, the open items
  tagged `[<slug>/product-plan.md <id>]`, and its *Records* line in the form
  `glab:project-record` states. `plan/<slug>/product-plan.md` is under the
  ignored `/plan/`, so it is never committed, and it is removed like any
  plan folder once the roadmap page has landed (`glab:bootstrap` step 5,
  `glab:session-rules` Rule 2, whose record file for a product slug is
  `docs/roadmap/<slug>.md`; `docs/specs/workflow.md`, *The docs lifecycle
  as of 0.16.0*); the removal is not a P7 exit condition. The store
  `docs/product-rules/` stays committed and untouched, and `/plan/` does
  not match `briefs/<p>/plan.r<n>/` (M2). "Every file the product level
  writes — a product plan, a brief, a roadmap page, a skill — names a store
  path relative to the store". `glab:commit` and `glab:push` name stages P6
  and P7; the planner's description and write boundary include the roadmap
  page and stages P1, P2 and P7, the analyzer's the roadmap check and
  stages P1b, P4 and P7; the analyzer's *Either check* is *Every check*, and
  a missing roadmap page is `BLOCK: target unresolved`; the handoff line's
  stage names gain `roadmap`.

- **Two levels in one plugin: the product level** (since `glab` 0.14.0,
  `ce1a933`, `flow-product-level`; `[flow-product-level/master.md]` G1, the
  user's "one plugin for all"). A product session turns a business plan
  into a product plan, product rules and one brief per project, and judges
  each project's plan before that project develops; a project session is
  the workflow of `docs/specs/workflow.md`, changed only at its edges
  (there, *Project Stage 1c and the develop gate*). The product level is
  seven skills and two agents,
  all `glab:product-*` (`[flow-product-level/plan.md N1]`: a nested skill
  folder is not loaded and a frontmatter `name:` cannot hold `:`, so
  `glab:product:plan` cannot be built): `glab:product-manager`, its operating
  model, owner of *The product pipeline* — P1 product plan, P1b product plan
  check, the user's approval, P2 briefs and rules, P3 project sessions, P4
  audit, P5 verdict, P6 commit and push — with a column mapping each to the
  project stage of the same role; the entry points
  `glab:product-plan` (the procedure `glab:product-planner` preloads, owner
  of `product-plan.md`'s shape, its 49152-byte budget and the 8192-byte rule
  file), `glab:product-plan-analyze`, `glab:product-project-brief`,
  `glab:product-project-plan-analyze`, `glab:product-project-plan-verdict`;
  and `glab:project-plan-report`, which the project manager runs at
  Stage 1c and whose description says `Project level` — named
  `glab:product-project-plan-report` until `glab` 0.15.0 (`0c49626`,
  `flow-project-level`), the one name whose prefix did not say its level.
  The level-boundary exception went with that name (F13): the clause
  `, and a name's prefix does not always say the level —
  `glab:product-project-plan-report` is the project level's.` of
  `session-rules/SKILL.md` and the product manager's line
  `` `glab:product-project-plan-report` is not on it: `glab:session-rules`
  *The level boundary* says why. `` are removed
  (`[flow-project-level/01-rename/plan.md]` P3, R4); every project skill's
  prefix now says its level. The agents, flat files under
  `plugins/glab/agents/` because `plugin details` lists no agent in a
  subfolder and the model and skills gates glob `agents/*.md` (`E3`):
  `glab:product-planner` (`model: opus`; `skills:` `glab:product-plan`,
  `glab:security`; no `Skill` tool) and `glab:product-analyzer` (`model:
  opus`; read-only, `tools: Read, Grep, Glob, Bash`; `skills:`
  `glab:security`, `glab:severity` since `glab` 0.15.0 — `0cfe335`,
  `flow-project-level` 02, `glab:audit` until then; the agent and its
  preloads 16508 bytes at `db5feae`, 19721 at `1bbf4bc`), which ends a
  product plan check `SOUND`
  or `NOT SOUND: <n> findings` and a project plan audit `NO CONFLICT` or
  `CONFLICTS: <n>`, both `BLOCK: target unresolved` when a file is missing
  (`agents/product-analyzer.md`); the verdict's reason is taken from its
  findings. The user approves every product plan explicitly (it decides
  what the product is, `glab:session-rules` Rule 3's fourth condition), and
  a product rule file changes only through an approved product plan's
  `## Rules to add` — "the rules are the user's", said once, in
  `glab:product-manager` *The product pipeline* (review round 2's B8
  leftover). The product manager writes the verdict itself from the audit;
  the user decides at the cap and on anything that meets a Rule 3
  ask-condition. Delivery and support are out of scope ("I'm still thinking
  about delivery skills structure I will let you knew when I will ready",
  `master.md` *Out of scope*): only the reserved level values and the
  store's `releases/` seam them.
- **The shared store and `glab-shared-store:`** (since `ce1a933`;
  `glab:product-manager` *The shared store*, the owner of the layout, which
  every other product skill points at; `host.example.md` *glab shared
  store*). The levels exchange plain files in one folder ("Files in a
  shared folder", "plain folder"), named by the first `glab-shared-store:
  <path>` line of the repo's `AGENTS.md`, else of `~/.claude/host.md`, read
  by the manager of each level from its skill text, never by the hook, and
  passed to `plan-gate.sh` as an argument; none → the product level stops
  and asks, the project level needs it only for a brief. The layout:
  `docs/product-rules/index.md` and one file per topic beside it,
  `briefs/<project>/brief.md`, `report.r<n>.md`, `plan.r<n>/` (byte copies
  of the hashed plan files, because the product side cannot read the
  project's repo), `verdict.r<n>.md`, and `releases/` reserved for the
  delivery level; `<project>` is `[a-z0-9-]+`, `<n>` has no leading zero and
  is compared as a number. Every committed file names a store path relative
  to the store (**superseded by `docs-lifecycle`, `glab` 0.16.0,
  2026-11-18:** "every file the product level writes — a product plan, a
  brief, a roadmap page, a skill —", the product plan no longer being
  committed; `[docs-lifecycle/plan.md D13]`). Reports, copies and verdicts are written only by
  `plan-gate.sh`. The product session has the store among its directories —
  `claude --add-dir <store>` or `/add-dir` — or keeps it inside its repo, so
  its writes are not each prompted (R2-4; a subagent's Write there is LP6).
  A Notion view is optional and later, never the gate
  (`[flow-product-level/plan.md FU-P3]`).
- **`plan-gate.sh`: the digest, the report, the verdict and the check**
  (since `ce1a933`; `plugins/glab/scripts/plan-gate.sh`, its header comment
  the owner, which since `2724086` (`glab` 0.14.1) also names where a store
  may live: a filesystem with hard links, an exclusive create
  (`O_CREAT|O_EXCL`) and unix permission bits — ext4, the one the tests ran
  on, and by their documentation xfs, btrfs, zfs, tmpfs, APFS and HFS+; not
  FAT, vfat or exFAT (no hard links, and `chmod` fails there); a network,
  FUSE or synced folder UNVERIFIED; `tests/plan-gate.test.sh` T1–T51 until
  0.16.3, T1–T56 since; since `64b4e57` (`glab` 0.16.3) `README.md` *The
  shared store*, `host.example.md` *glab shared store* and
  `glab:product-manager` *The shared store* (*Where it is*) each point at
  that header in one sentence and restate nothing,
  `[script-hardening/plan.md D2]`). One script, so both levels
  compute the same bytes and the formats have one owner and one test. Modes
  `digest <plan dir>`, `report <plan dir> <store> [<note file>]`, `verdict
  <store> <project> ACCEPTED|REJECTED product-manager|user <reason file>`,
  `check <plan dir> <store>`; its contract — exit codes, refusals, writes —
  is stated once, in `docs/specs/marketplace.md` (*The repo's own rules*).
  **The hash inputs** (`plan.md` C4): under the plan
  folder, recursively, pruning every `plan.r<digits>…` folder, the regular
  files named `master.md`, `index.md`, `plan.md`, `questions.md` or
  `steps-*.md`, none matching `*.r[0-9]*.md` or `*.v[0-9]*.md`, sorted
  under `LC_ALL=C`; the digest is the sha256 of their `<sha256>  ./<path>`
  lines, `shasum -a 256` standing in for `sha256sum`. Round copies,
  version copies, `plan.r<n>/`, `evidence.md`, `map-*.md`, `result.md` and
  `after-verdict.md` are left out, so a `REJECTED`'s round copies and the
  manager's bookkeeping never move it (R1, R2; T2, T23). **The report**
  (C6) and **the verdict** (C7), each field on its own line above the first
  `## ` heading, parsed by one rule — exactly once, matching its pattern,
  `r<n>` compared as a number — else `report r<n> is malformed` or `verdict
  r<n> is malformed` (C8, R4). **The check** reads the highest-numbered
  verdict only and refuses in a fixed order: no brief line, the brief
  changed, a report still waiting, no verdict for this brief, a malformed
  verdict, `REJECTED`, the plan changed (R11); else it prints `ACCEPTED r<n>
  <digest>`. `report` and `check` refuse when the brief changed since the
  plan quoted it. **The cap** — two `REJECTED` on one project since its last
  `ACCEPTED`, over every brief, so a new brief does not reset it; then
  every verdict by `product-manager` is refused, `ACCEPTED` too, and one
  `by user` is written only when its reason opens `user: "<the user's
  words>"` (R3, I8; owned in prose by `glab:product-manager` *The cap*).
  **Since the two review rounds**, which supersede `plan.md` C8 and *Tests*
  and the full texts of `steps-1-scripts.md` for this script and its test
  (`[flow-product-level/review-1.md]`, `[flow-product-level/review-2.md]`,
  `result.md` *Final check record*): a symlink anywhere in a plan folder is
  refused by `digest`, `report` and `check`, and one in a copy folder by
  `verdict` (A1); each claim — a report's number, a verdict's — is an
  exclusive create done by bash itself with noclobber, an `O_EXCL` open
  (until 0.14.1 in a subshell, `(set -C && : >claim)`; since then in the
  run's own bash, below), the file `.plan-gate.claim.<report|verdict>.r<n>` in
  `briefs/<project>/`, and only the winner creates `plan.r<n>/` and the
  final file (A2, part 2; *Incidents*); the report's tests for `report.r<n>.md` and `plan.r<n>/` run again under
  the claim (fix round 1 part 2; review round 2 finding 3); each report and verdict is written to
  the fixed temporary name `.plan-gate.tmp.<kind>.r<n>` (finding 5) and
  published with `ln`, which never overwrites (A2), `TMP_DIR` cleared right
  after `ln` succeeds (finding 2); the copy is `chmod -R a+rX` before its
  report is linked, so another account can audit it (A3); `verdict` refuses
  a copy whose file list differs from what the digest lists (finding 4); a
  project name with a newline exits 2 (A6); a claim's refusal names the
  claim file and says to remove it by hand when no run is writing
  (finding 1). The trap removes the copy, the temp file, the claim and,
  since 0.14.1, the takeover lock on every exit it sees.
  **Since `glab` 0.14.1** (`2724086`, `flow-gate-hardening`; the header and
  the comments of `hold_signals`, `whoami`, `owner_gone`, `create_line`,
  `claim`, `take_over` and `publish_file` the owners, which supersede the
  text of `steps-1-script.md` after review round 1,
  `[flow-gate-hardening/plan.md review-fixes]`): each claim holds one line,
  `<host> <boot id> <pid namespace> <pid> <start>` (`whoami`, read from
  `/proc`, Linux only; empty where `/proc` is missing or another pid
  namespace's), written by `create_line` inside the claim's own `O_EXCL`
  create, in the run's own bash — a `( )` subshell resets the traps
  (`[flow-gate-hardening/review-1.md finding-1]`) — under `umask 022`, so a
  run of the other level's account can read it. A run that finds a claim
  hands it to `take_over`: `owner_gone` calls the claim's run gone only when
  host, boot id and pid namespace match this run's and `kill -0` says `No
  such process`, or `/proc/<pid>/stat` shows another start time (the pid
  reused) or state `Z`/`X`; anything else — an empty line (a claim written
  by 0.14.0), another host, boot or pid namespace, a process this account
  may not inspect — is "cannot tell" and keeps the refusal. A gone run's
  claim is taken over under the lock `.plan-gate.takeover.<kind>.r<n>`,
  made as a claim is, under which the claim is read again (`head -n 1`) and
  removed, with the temporary file the dead run left, only if it still
  holds the stale line; the run then makes its own claim. The refusals: a
  claim whose run is alive keeps 0.14.0's text byte for byte, `<refusal>;
  when no run is writing, remove <claim> by hand`; one that cannot be
  proven stale names the temporary file too when there is one, `remove
  <claim> and <tmp> by hand`; a held lock gives `<refusal>; when no run is
  writing, remove <lock> by hand`. A dead report run's `plan.r<n>/` stays:
  the refusal under the claim, `plan.r<n>/ is there without report r<n>;
  look at it and remove it by hand`, keeps it for a person (T43). TERM,
  HUP and INT are held — noted by a trap, not ignored, and re-sent when
  released, so the run still ends by them — across each create in `claim`
  and `take_over` and the assignment after it, and in `publish_file` from
  before `ln` until `TMP_DIR` is cleared. After a failed `ln`, a final name
  that is the temporary file itself (`-ef`) means `ln` linked and was then
  killed, and the file counts as published (T50); any other failure but a
  name already there exits 2 with `plan-gate.sh: writing <path> failed:
  <ln's message>; plan-gate.sh publishes with a hard link, so the store must
  be on a filesystem that has them - the header of plan-gate.sh names them`
  — no fallback, and the message not parsed (T51). Exit codes, stdout, the
  store layout and the walkthrough trace are unchanged: the trace
  byte-identical to `f6fcb14`'s script, 434 lines
  (`[flow-gate-hardening/plan.md final-check]`).
  **Since `glab` 0.16.3** (`64b4e57`, `script-hardening`; the comments of
  `create_line`, `create_failed`, `claim` and `take_over` the owners): the
  open and the write of a claim or lock are two commands, so their
  failures differ (`[script-hardening/plan.md D16]`). `create_line` tests
  the name first, `[ -e ] || [ -L ]` (the pre-open guard); then opens fd 9
  with `{ command exec 9>"$1"; } 2>/dev/null` under `set -C`; then writes
  the line with `{ printf '%s\n' "$ME" >&9; } 2>/dev/null`, closing fd 9
  after it. It returns (`D7`): 0 written; 1 the name is there — found by
  the guard, or found there after a failed open; 2 the open failed and no
  name is there; 3 the write failed — a full disk or quota, a file size
  limit — and the file this run made was removed again by its name,
  `rm -f -- "$1" 2>/dev/null` (`D9`); 4 the write failed and that removal
  failed too. It turns noclobber off and puts back the run's umask on
  every result — fd 9 was logged closed after 0, 1, 2 and 3, never after
  4 (*Known limits*); nothing else uses fd 9. `create_failed` ends the run for
  2, 3 or 4 with exit 2 and one stderr line: `plan-gate.sh: writing <file>
  failed` for 2 and 3, `plan-gate.sh: writing <file> failed, and removing
  it failed; remove <file> by hand` for 4. In `claim`, only 1 goes to
  `take_over`; 2/3/4 go to `create_failed`. In `take_over`, a lock that is
  there (1) keeps its refusal `<refusal>; when no run is writing, remove
  <lock> by hand`, and a lock that could not be made (2/3/4) exits 2; the
  claim's re-create under the lock refuses on 1, naming the claim, and
  exits 2 on 2/3/4. So a failed write ends in exit 2, having removed
  nothing but the file the run made itself — before 0.16.3 it ended in a
  refusal, exit 1, that asked a person to remove the run's own empty file
  (FG-1, *Closed follow-ups*). `AGENTS.md`'s contract is unchanged: its
  "no write" clause binds refusals, and this removal is on exit 2
  (`plan.md` F6, `D1`). **The pre-open guard**: noclobber opens an
  existing name that is not a regular file without `O_EXCL`, so a claim
  symlinked to `/dev/null` opened, took the line, and the run went on with
  no exclusive claim (rc 0, the trap then removing the link). Since 0.16.3
  such a name is refused: a claim symlink to `/dev/null` goes from rc 0 to
  rc 1, and a dangling one from rc 2 (`writing … failed`) to rc 1
  (`REFUSED: … remove … by hand`), the link kept in both — refusals,
  within the contract (`plan.md` F5, `D19`; `[script-hardening/plan.md
  FU-SH3]`). The guard only refuses sooner; the `O_EXCL` open is still
  what makes one run the winner. Two windows stay open, each needing a
  writer acting against the run on purpose (`D11`): (1) a non-regular name
  planted between the guard and the open still opens without `O_EXCL`, and
  when the write then fails the rm of code 3 removes that planted name
  (`[script-hardening/review.r1.md]`'s `/dev/full` probe, exit 2); (2) a
  file put at the name between a failed write and the rm is removed.
  **`command exec`**: `exec` is a special builtin, and in posix mode —
  `POSIXLY_CORRECT` in the environment — a failed redirection on it ends
  the shell at once, exit 1, its message dropped; each `exec` of fd 9 goes
  through `command`, so the failure is a status the code reads
  (`[script-hardening/review.r1.md]`, `D21`; *Incidents*). The tests, T52–T56
  before T22 (`PASS 56/56`; `PASS 51/51` before): the helper `capped` runs
  the script as `(trap '' XFSZ; ulimit -f 0; exec bash …)`, so any
  non-empty write to a regular file fails with EFBIG, standing in for
  ENOSPC or EDQUOT on the same write path, and writes its own output to
  `$W/capped`, outside the snapshotted store (`plan.md` F3, `D8`); T52 a
  decoy with another host's line at `.plan-gate.claim.report.r1`, refused
  and kept byte for byte, then capped `report` and `verdict` exit 2
  naming their claim (code 3); T53 the takeover lock's code 3 (with
  `/proc`); T54 a folder the run cannot write, claim and lock code 2 —
  coverage, not a regression test, as it passes on the base too (`D21`);
  T55 code 4, a stub `rm` first on `PATH` (`D17`, `AGENTS.md` *Tests*); T56
  under posix mode a read-only store (exit 2) and an injected claim-race
  loser (rc 1, the `REFUSED:` line, the planted line kept): a function
  `[` defined in a `bash -c`, which then runs `set -o posix;` before it
  sources the script (`D23`). On the base script T52, T53, T55, T56's
  race half and T22 fail. Under `POSIXLY_CORRECT=1` the suite gives
  `FAIL 1/56`, T47 only, which fails on the base too
  (`[script-hardening/plan.md FU-SH4]`).
- **Starting project sessions** (since `ce1a933`; `glab:product-manager`
  *Starting project sessions* and *Waiting for reports*, the owner of the
  start prompt, the hosts and their caveats; `README.md` points there,
  review round 1 B5). On the user's go-ahead, once per batch of briefs, the
  go-ahead naming each project's repo folder; one session per brief, named
  `<project>`, given the start prompt — the brief's path, then "Commit only
  through /glab:commit, and push only after the user's explicit go-ahead"
  (F19: a background session in a worktree commits and pushes unless its
  task says otherwise). By host: the desktop app's session tool with
  `wake_when_done`; in the CLI `claude --bg --name <project> --add-dir
  <store>` from the project repo, messaged by the cross-session
  `SendMessage`, waited on with `notify_when_idle`, resumed with `claude
  --resume <full session id> --bg` only once stopped (F17, F18, F21); or by
  the user, by hand, always valid ("product manager and or also me"). If a
  live run shows a background session pushing anyway, project sessions are
  started by hand. All of it but the user's own start is LP4, UNVERIFIED.
- **The walkthrough and the three tests** (since `ce1a933`;
  `tests/product-loop.test.sh` with `tests/fixtures/product-loop/`,
  `README.md` *Try the product loop*). `tests/plan-gate.test.sh` (the
  script, `PASS 51/51` until 0.16.3 and `PASS 56/56` since, T52–T56 added
  by `script-hardening` (*`plan-gate.sh`*, above): T1–T29 as planned, T30–T37 from review round 1,
  T38–T42 from round 2, and since 0.14.1 T38 rewritten — the refusal after
  a SIGKILL it asserted became the takeover, the refusal living on in T44
  and in T38's branch for a host without `/proc` — and T43–T51 added by
  `flow-gate-hardening`), `tests/manager-bootstrap.test.sh` (the hook,
  `PASS 13/13`) and `tests/product-loop.test.sh` (the walkthrough, L1–L17,
  `PASS 17/17`), one per contract. The walkthrough plays a made-up product
  with two projects through the loop under `$TMPDIR` from fixtures — what
  each agent would write — and runs the real scripts; it calls no model.
  With `PRODUCT_LOOP_SHOW=1` it prints the trace of each scene on stderr;
  the manager sent that trace (434 lines) to the user on 2026-11-13 and
  removed it, as X2 says (`result.md` *Final check record*). The gate lines
  are in `docs/specs/marketplace.md`.
- **The product session start** (since `glab` 0.15.0, `flow-project-level`
  G5; `[flow-project-level/master.md]` *Final check* step 4, the owner of
  the measure: the hook's session-start text for a `glab-level: product`
  repo, `bootstrap`, `session-rules`, `security` and `product-manager`, by
  `wc -c`). Before: 57203 bytes (`[flow-project-level/evidence.md]` E2, the
  G5 table's *Before*), the hook text 2394 of it. After: `prod` 44924
  against the cap 47104 (*Final check* step 4, run 2026-11-18 on `db5feae`
  and again for this record), the hook text 2584 (`[flow-project-level/02-shared-rules/plan.md]`
  *Dry run*: product 2584, base 2394; 2584 again for this record), with
  `bootstrap` 5212 and `session-rules` 13012. The
  product-analyzer's agent set (agent file plus preloads) is 16508.

## Decisions that still bind

- [flow-product-level/master.md Request] **The user, 2026-11-13: "finish product skills and wiring with project first, I want to see how these skills will work"** (relayed by the manager, `master.md` *Request*) — the request of this change: the product level and its wiring to the project level now, delivery and support later (*Two levels in one plugin*, above); the walkthrough and the guide to try the loop live after install show it working (G7; *The walkthrough and the three tests*, above).
- [flow-product-level/master.md Approval] **The user, 2026-11-13: "we need to develop, go with your recommendations"** — the plan with every recommendation in it approved for development, base `f3cfe85`; recorded in `master.md` *Approval* and `plan.md`'s. The same words keep `glab:session-rules` (`docs/specs/workflow.md`).
- [flow-product-level/questions.md Q1] **The user's answer, 2026-11-13: "Opus for both"** — `glab:product-planner` and `glab:product-analyzer` run on `model: opus`; Rule 5's list, the model gate and `README.md` change with it. Recommended by analogy with the planner and the plan analyzer, one level up; the product level runs them a few times per business plan and per report, not per change.
- [flow-product-level/questions.md Q2] **The user's answer, 2026-11-13: "Keep names (Recommended)"** — today's project skills and agents keep their names, unprefixed; the product level's are `glab:product-*`; delivery and support, when built, take `glab:delivery-*` and `glab:support-*`.
- [flow-product-level/master.md Request] **The user: "these skills are must communicate with each other glab:product:* glab:product:project:* glab:product:delivery:* glab:product:support:* … I think yes this is fit for one plugin for all"** (from `plan/manager-flow-notes.md`, untracked, quoted in `master.md` *Request*) — every level lives in `glab`; no `product` plugin.
- [flow-product-level/master.md Request] **The user: "okay two is good"** (from `plan/manager-flow-notes.md`, untracked, quoted in `master.md`) — the rejection cap: two `REJECTED` verdicts, then the user decides (*`plan-gate.sh`*, above; `glab:product-manager` *The cap*).
- [flow-product-level/master.md Request] **The user: "product:project:plan:accept|reject (skill(s) witch must send accepted and rejected plan and small context or reason)"** (from `plan/manager-flow-notes.md` *Idea 2*, untracked, quoted in `master.md` *Request*) — G4: the verdict is `ACCEPTED` or `REJECTED`, always with a reason, gated by the hash of the accepted plan, written by `glab:product-project-plan-verdict` through `plan-gate.sh verdict` (*`plan-gate.sh`*, above).
- [flow-product-level/master.md Request] **The user: "product manager and or also me"** (from `plan/manager-flow-notes.md`, untracked, quoted in `master.md`) — project sessions are started by the product manager or by the user, and both lead to the same brief (G6; *Starting project sessions*, above).
- [flow-product-level/master.md Request] **The user: "Files in a shared folder" and "plain folder but I'm planing to connect here notion page"** (from `plan/manager-flow-notes.md`, untracked, quoted in `master.md`) — the levels talk through a plain shared folder; a Notion view is optional and later, never the gate (`[flow-product-level/plan.md FU-P3]`, open). With it, "docs/product-rules/{named roules}.md" — small rule files with an index (G5).
- [flow-product-level/plan.md N1] Hyphenated level prefixes under `glab`, `glab:product-*`, because a nested skill folder is not loaded and the manifest `skills` key gives no level segment (`E1`, `E2`); the seven product skills keep the agreed bare names behind `product-`; agents stay flat files (`E3`).
- [flow-product-level/plan.md store] The store is named by `glab-shared-store: <path>` in the repo's `AGENTS.md`, else `~/.claude/host.md` (C2), with no machine path committed; its layout is the agreed one plus `plan.r<n>/` (C3), stated once in `glab:product-manager` *The shared store* (I6).
- [flow-product-level/plan.md digest] The digest covers the files a build follows and leaves out round copies, version copies, any `plan.r<n>/` and every working file, `after-verdict.md` among them (C4, C11, R1, R2). What goes into `after-verdict.md`, and the develop gate on every dispatch, are project edges (`docs/specs/workflow.md`, *Project Stage 1c and the develop gate*).
- [flow-product-level/plan.md one-script] One script, `plugins/glab/scripts/plan-gate.sh`, computes the digest and writes the report and the verdict (C5–C8), with one parse rule for both files (R4) and `check`'s refusals in a fixed order (R11). **Amended by `[flow-product-level/review-1.md]` and `[flow-product-level/review-2.md]`:** their decisions supersede C8's `mv` writes and closed refusal list, `plan.md` *Tests*' `PASS 29/29`, and the full texts of the script and its test in `steps-1-scripts.md` (*`plan-gate.sh`*, above).
- [flow-product-level/plan.md cap] The cap counts `REJECTED` verdicts per project since its last `ACCEPTED`, over every brief (R3, I8); at two every verdict by `product-manager` is refused and one `by user` written only with `user: "<the user's words>"`; the count restarts at an `ACCEPTED`. `by user` is an argument the calling session chooses — a known limit stated in `glab:product-manager` *The cap* and `README.md` *Levels* (R12; `[flow-product-level/plan.md FU-P5]`).
- [flow-product-level/plan.md verdict-owner] The product manager writes the verdict itself from the audit; the user decides at the cap and on any Rule 3 ask-condition, and approves every product plan explicitly; the product rules are the user's — drafted in the product plan, written to the store only after its approval, one topic per file of at most 8192 bytes, one index line each, never changed as a Rule 1 trivial change; `product-plan.md` keeps the 48 KB budget, 49152 bytes (R7).
- [flow-product-level/plan.md audit-inputs] `glab:product-project-plan-analyze` gives the audit the brief, the report, `plan.r<n>/`, the product plan's `## Decisions` and the rule files the brief names (I3), finding the product plan as the one whose `## Projects` has `### <project>`; `glab:product-analyzer` is read-only and returns its findings as text; `glab:product-project-plan-report` keeps its agreed name though the project manager runs it.
- [flow-product-level/plan.md project-sessions] Project sessions start on the user's go-ahead once per batch of briefs, naming each repo folder, by host (LP4, F8–F10, F17, F18, F20, F21); the start prompt carries the git sentence (F19), the lever because `claude --help` on 2.1.310 has no flag keeping a `--bg` session out of a worktree (`E20`); what no live run has shown is said UNVERIFIED in the skill; a reporting session that the product session started needs no message.
- [flow-product-level/plan.md tests] Three test files, one per contract; every script and test written in full in the steps and proven on a throwaway build (`E16`, `E17`); the walkthrough calls no model and writes only under `$TMPDIR`; its trace is shown to the user after the build (X2, I11); `manager-bootstrap.sh` rewritten whole, every comment of its old header carried (A3).
- [flow-product-level/plan.md record] The product level's record goes to this file, new with it and named in `AGENTS.md`'s `plan/` rule; `docs/specs/workflow.md` gets the project edges, and `docs/specs/marketplace.md` the version, the gates and the contracts.
- [flow-product-level/review-1.md decisions] The manager's round-1 decisions that stand: A1 (refuse every symlink), A2 (publish with `ln`, claim with an exclusive create — after part 1's `PLAN WRONG`, bash `set -C`, not `mkdir`), A3 (`chmod -R a+rX` on the copy), A4 with B9 (the `after-verdict.md` redirect stated once, in Stage 1c), A5 (each manager's list names its own manager), A6 (a project name's characters checked by `case`), the waiver case (a waiver from a brief still needs the product's verdict), B1–B10 and B12 by pointer under "say it once", advisory 1 and 2 applied, advisory 3 (the `jq` tabs) rejected because the tabs are the plan's own text; `glab` stays `0.14.0`, `master.md` untouched.
- [flow-product-level/review-2.md decisions] The manager's round-2 decisions: the five `plan-gate.sh` findings applied as each Fix says, finding 3 by taking the claim before the test, each with a test that fails on the script before (T38–T42); the B8 leftover kept once, in `glab:product-manager`; no third review round, no finding being `critical` or `high`.
- [flow-product-level/plan.md spent] `- effort: high (the user's words: "high (Recommended)"), for the session`; tier full (the brief, report and verdict files are a wire format between sessions, and `check` decides when development starts); one plan, not sub-plans, its steps split into five files for size only; version `0.14.0` once (`docs/specs/marketplace.md`) — scoping of that change, spent.
- [flow-gate-hardening/master.md Request] **The user, 2026-11-14: "let's work on these gates"** (relayed by the manager, `master.md` *Request*) — read by the manager as the four open follow-ups of `plan-gate.sh`, `FR1-1`, `FR1-2`, `FR2-1`, `FR2-2`, and its *Known limits*, every existing contract kept (G1–G6); all four closed (*Closed follow-ups*, below).
- [flow-gate-hardening/master.md Approval] **The user, 2026-11-14: "Yes, develop"** — the plan approved for development, base `f6fcb14`.
- [flow-gate-hardening/plan.md claim-line] Each claim holds one line, `<host> <boot id> <pid namespace> <pid> <start>` (`whoami`), written inside the claim's own `O_EXCL` create; read from `/proc`, Linux only, and empty where `/proc` is missing or another pid namespace's, so those claims are refused as before.
- [flow-gate-hardening/plan.md owner-gone] A claim's run is gone only when host, boot id and pid namespace match this run's and `kill -0` says `No such process`, or `/proc/<pid>/stat` shows another start time (pid reused) or state `Z`/`X`; anything else is "cannot tell" and keeps the refusal; `kill -0` alone was rejected.
- [flow-gate-hardening/plan.md takeover] The takeover is exclusive by the lock `.plan-gate.takeover.<kind>.r<n>`, made as a claim is, under which the claim is read again and removed only if it still holds the stale line: T46 proves the lock, T47 the re-read, T48 the plain race.
- [flow-gate-hardening/plan.md lock-left] A SIGKILL inside the takeover, a few commands, leaves the lock, and every later takeover of that number is refused naming it — accepted, against a whole run's window before; a lock for the lock only moves the window.
- [flow-gate-hardening/plan.md refusals] A claim whose run is alive keeps 0.14.0's refusal byte for byte (T33, T37, T40); one that cannot be proven stale keeps it and names the temporary file too when there is one (FR2-2); a held lock gives `<refusal>; when no run is writing, remove <lock> by hand`.
- [flow-gate-hardening/plan.md copy-left] A takeover leaves a dead report run's `plan.r<n>/` in place; the existing refusal under the claim keeps it for a person, as "detect and surface" decided (T43).
- [flow-gate-hardening/plan.md contract] A refusal still writes nothing but the takeover before it, which removes only a dead run's claim and temporary file; said in the header and in `AGENTS.md` *Rules* (`docs/specs/marketplace.md`); exit codes and stdout unchanged.
- [flow-gate-hardening/plan.md t38] T38 keeps its id and is rewritten: the refusal after a SIGKILL it asserted is the behaviour FR1-2 replaces; that refusal lives on in T44 and in T38's branch for a host without `/proc`.
- [flow-gate-hardening/plan.md hold] TERM, HUP and INT are held — noted by a trap, not ignored — from before `ln` until `TMP_DIR` is cleared, then re-sent so the run still ends by them.
- [flow-gate-hardening/plan.md hold-claim] The same hold spans each create in `claim` and `take_over` and the assignment after it, closing the window between the create and `CLAIM=$1`; proven on instrumented builds, with and without the hold, and no permanent case, since that needs an instrumented copy of the script. **Amended by `[flow-gate-hardening/review-1.md finding-1]`:** the creates run in the run's own bash (`create_line`), since a `( )` subshell resets the traps (*`plan-gate.sh`*, above).
- [flow-gate-hardening/plan.md ef] After `ln` fails, a final name that is the temporary file itself (`-ef`) means `ln` linked and was then killed, as a Ctrl-C to the process group does: the file is published (T50).
- [flow-gate-hardening/plan.md no-hardlinks] FR1-1 by a clear exit-2 message, no fallback: no fallback can be proven on the build host, FAT fails `chmod` first, and `mv` would leave exclusivity to the claim alone (T51).
- [flow-gate-hardening/plan.md no-parse] The message is printed for any `ln` failure but a name already there, not matched against errno texts: one EPERM reads `Permission denied` from uutils and `Operation not permitted` from GNU.
- [flow-gate-hardening/plan.md readers] `check` and `verdict` are unchanged: `ln` publishes a finished file, so no reader can see half of one.
- [flow-gate-hardening/plan.md exit-2] Missing hard links are a failed write, exit 2, and the message keeps the start `plan-gate.sh: writing <path> failed`; not a `REFUSED:` line, which is for a state of the store.
- [flow-gate-hardening/plan.md filesystems] The supported filesystems are named in the script header and, at the record, in this file's owner pointer (*`plan-gate.sh`*, above); `README.md` and `host.example.md` gain nothing (say it once; `[flow-gate-hardening/follow-ups.md FG-2]`, open). **Amended by `[script-hardening/plan.md D2]` (`64b4e57`, 0.16.3):** the header stays the one owner, and `README.md`, `host.example.md` and `glab:product-manager` each gain one sentence pointing at it, restating nothing; FG-2 closed (*Closed follow-ups*).
- [flow-gate-hardening/plan.md head] `take_over` reads the claim with `head -n 1`, a claim being one line; it is also where T47 holds a run between its first read and the lock.
- [flow-gate-hardening/plan.md umask] Claims and locks are made under `umask 022`, so a run of the other level's account can read the line.
- [flow-gate-hardening/plan.md limits] What stays open is listed under *Known limits*, below.
- [flow-gate-hardening/plan.md review-fixes] Review round 1 (`review-1.md`) found three lows, fixed by a new developer: the creates moved into the run's own bash, the comment tags written `[<slug>/<file> <id>]`, T44 given a case per refused field; the shipped script and test therefore differ from `steps-1-script.md` and `steps-2-test.md` — sha256 `f545c4ddc9b4da2a025b469b1efa1d2d8f0483863284d88c6d3cddcd9610fa90` (`plan-gate.sh`) and `72bf26da108baa6e69445fee64ac26e08a75e5ed706310601f9424bd537f881e` (`tests/plan-gate.test.sh`), both as at `2724086`. Review round 2: SHIP.
- [flow-gate-hardening/plan.md a6-a7-run] The manager ran A6 on the built tree, ten runs, each `PASS 51/51`. M1 (no lock) fails T46 on every run and T48 in 2 of 5, the race in T48 going either way without the lock; accepted, T46 being the deterministic bar.
- [flow-gate-hardening/plan.md final-check] The final check returned CONFORMS. Re-run on the shipped script, A4 printed `FAIL T38 FAIL T43 FAIL T44 FAIL T45 FAIL T46 FAIL T47 FAIL T48 FAIL T49 FAIL T50 FAIL T51 FAIL T22 FAIL 11/51` against `f6fcb14`'s script, and A8 `trace byte-identical`, `434`. A5 and A7 apply to the pre-fix build only; the shipped window is proven by the developer's stand-ins (`result.md` *Review round 1 fixes*) and review round 2.
- [flow-gate-hardening/plan.md spent] `- effort: high (the user's words: "high (Recommended)"), for the session`; tier full; one plan, no sub-plans, its code in steps files for size only (`one-plan`, `size`); `AGENTS.md` *Gates* unchanged (`gates`) and version `0.14.1` once (`version`), both in `docs/specs/marketplace.md` — scoping of that change, spent.
- [docs-lifecycle/plan.md M2] (manager) The store `docs/product-rules/` stays committed and untouched; the ignore line is anchored at the root, so `docs/product-rules/briefs/<p>/plan.r<n>/` is not matched; `plan-gate.sh` runs no git command.
- [docs-lifecycle/plan.md D9] A product slug is delivered, and so complete, when each project of `product-plan.md` `## Projects` has `ACCEPTED` as its latest verdict and P6 has landed. The product level sees no later event: `releases/` is reserved for the delivery level, and nothing writes it yet. (superseded by `[p7-delivery-gate/plan.md D1]`, `D2`)
- [docs-lifecycle/plan.md D10] P7 Roadmap goes in `glab:product-manager` *The product pipeline* (project-stage column 8), in this order: the product manager dispatches `glab:product-planner` to write `docs/roadmap/<slug>.md` in the product repo, not the store (the manager does not plan or audit itself); `glab:product-analyzer`'s roadmap check ends `SOUND` or `NOT SOUND: <n> findings`, reused so that *The analyzers' verdict lines* stay unchanged; one fix round to a new planner, then a recheck, still `NOT SOUND` → stop and tell the user; `/glab:commit`, then `/glab:push` on the user's go-ahead, on which P7 leaves; the folder's removal later, at a session start, is no P7 exit condition. No new skill or agent: `glab:product-record` was considered and not taken.
- [docs-lifecycle/plan.md D11] The roadmap name is the product slug: already kebab, unique, and it ties the page to its plan.
- [docs-lifecycle/plan.md D12] The roadmap page's contents (*How it works now*, above); no size cap is stated, so *The plan size budget* entry is unchanged.
- [docs-lifecycle/plan.md D13] Product plans live under `plan/<slug>/product-plan.md`, so they are ignored and removed like any plan folder; product-manager's sentence reads "Every file the product level writes — a product plan, a brief, a roadmap page, a skill — …"; the store-relative-path rule still binds the product plan.
- [docs-lifecycle/plan.md D14] P4 reads the product plan from disk (`plan/*/product-plan.md`). Removal waits for D9, after which no audit of that plan remains; a later brief for the same project is a new product plan and a new slug. A known limit (*Known limits*).
- [docs-lifecycle/plan.md D29] P7 is in every list of the product stages or the product agents' jobs: `commit/SKILL.md:7` and `push/SKILL.md:7` ("stages P6 and P7"), `product-analyzer.md:3`, `product-planner.md:3`; the planner's write boundary includes `docs/roadmap/`; *Either check* became *Every check*, and its missing-file list gained the roadmap page. Each frontmatter `description` stays ≤ 1024 bytes and `claude plugin validate --strict` passes.
- [docs-lifecycle/plan.md D33] The roadmap check reads the page whole, not a diff: a new, untracked page shows in no `git diff`.
- [docs-lifecycle/plan.md D43] P7's cap — one fix round, then the recheck, never a third — is in `glab:session-rules` *Round caps* and its `docs/one-fact.md` entry; the P7 bullet of `glab:product-manager` points at it. `[docs-lifecycle/plan.md D45]` (review round 1, finding 7): the last-round action, "still `NOT SOUND` after its last round, stop and tell the user", lives in the P7 bullet, since *Round caps* ends "What a stage does when its last round fails is in that stage."
- [p7-delivery-gate/plan.md D1] (manager) P7 also needs the user's word that every project of `## Projects` has delivered. The product manager asks once every latest verdict is `ACCEPTED`, or when the user raises it; on an explicit yes it writes `## Delivered`, then `- confirmed by the user, <date>, in chat: "<their words>"`, at the end of `product-plan.md`. No `## Delivered` line means no P7. Reason: `ACCEPTED` judges a plan (`F2`), and no file showed delivery.
- [p7-delivery-gate/plan.md D2] (manager) P6 is done when there is nothing to commit, which means the product repo's `git status --short` prints nothing; P7's condition reads "P6 has landed or had nothing to commit". Reason: `F3` — with the store outside the product repo, P1–P5 write only the ignored `plan/` and the store, so P6 had nothing to commit and the old condition never held. **Superseded in its test by `[lifecycle-hardening/plan.md D10]` (`glab` 0.16.2):** "nothing to commit" is `git status --short --branch` exiting 0 with one `## <branch>...origin/<upstream>` line, no bracket or exactly `[behind <n>]`.
- [p7-delivery-gate/plan.md D3] (manager) The removal mechanism does not change: it still follows P7's roadmap, which now waits for D1. `glab:bootstrap` step 5 and `glab:session-rules` Rule 2 key on the roadmap page's *Records* line and do not restate the condition (`F5`), so neither file changed. **Amended by `[lifecycle-hardening/plan.md D26]` (`glab` 0.16.2):** the removal still keys on the roadmap page's *Records* line, but the manager lists the folder and removes it only on the user's word.
- [p7-delivery-gate/plan.md D6] (planner, accepted by the manager in `D8`) A `| — | Delivered |` row after P6 in the pipeline table, the way the `## Approval` row sits before P2 (`F4`), so the table shows every gate; with `D9` A6, the last-column sentence names `Delivered` beside P2 to P5.
- [p7-delivery-gate/plan.md D7] (planner, accepted by the manager in `D8`) `glab:product-project-brief`'s precondition (`F8`) is unchanged: once `## Delivered` is written, a delivered slug takes no new brief; new work becomes a new product slug. `[p7-delivery-gate/plan.md D9]` A8: its refusal message for a delivered slug names approval, not delivery — accepted. **Amended by `lifecycle-hardening` (`glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`, `D24` item 3):** the meaning is kept, the words now "no `## Delivered` after the last `## Approval`", and the message also names delivery (`[lifecycle-hardening/follow-ups.md FU1]`).
- [p7-delivery-gate/plan.md D9] (manager, plan check `check.r1.md` A3) The roadmap page carries the `## Delivered` line with the user's words: an item of the roadmap contents list in `glab:product-plan` *The roadmap*, and of `glab:product-analyzer`'s roadmap check.
- [p7-delivery-gate/plan.md spent] `D4` (`glab` 0.16.1, raised once; no *One fact* file states the version, `F7`), `D5` (the record commit on the change's branch, one PR, rebase-merged; only this spec changes), `D8` (D6 and D7 accepted), `D9` A1, A2 and A5 (the order commit → push → PR → record → push → merge, the manager's; PC9's `--reverse`), A4 (the Codex findings tagged `F2` and `F3`), A6, A7, and `D10` (PC9 lists five files) — scoping of that change, spent.
- [lifecycle-hardening/plan.md D4] (its `p7-delivery-gate` half) `[p7-delivery-gate/review.r1.md 1]` → `D10`; `2` → "a `## Delivered` line after the last `## Approval`" (`product-manager/SKILL.md:60`); `3` → the brief's precondition "has its `## Approval` line, and no `## Delivered` after it" (since `D24` item 3 "… after the last `## Approval`"), and `:49` and `:55` "appended to" (`D14`); `product-plan/SKILL.md:48` → "the last `## Delivered` line". Keeps `[p7-delivery-gate/plan.md D7]`: a delivered slug takes no brief; one approved again after delivery takes briefs and needs a new `## Delivered` before P7.
- [lifecycle-hardening/plan.md D10] (`check.r1.md` M3) P6's "nothing to commit": `git status --short --branch` exits 0 and prints one line, `## <branch>...origin/<upstream>` (`D20`), with no bracket or exactly `[behind <n>]`; `[gone]`, `[ahead`, `No commits yet`, no upstream, a detached HEAD or exit ≠ 0 fail it. Reason: the old `git status --short` printed nothing with `[gone]` and unpushed commits, and in a repo with no commits whose upstream is configured (`check.r1.md` M3).
- [lifecycle-hardening/plan.md D14] (`check.r1.md` L1) `product-manager/SKILL.md:55`, the Delivered row, joins `:49`: "appended to `product-plan.md`".
- [lifecycle-hardening/plan.md D20] (`check.r2.md` N4) The P6 upstream is a remote-tracking branch, `...origin/` in the `##` line, chosen over `@{push}` because it is the line already read; a local-branch upstream (`## feat2...feat [behind 1]`) fails it.
- [lifecycle-hardening/plan.md D21] (`check.r2.md` N5) `product-analyzer.md:40` → "the last `## Delivered` line", as `product-plan:48`.
- [lifecycle-hardening/plan.md D24] item 3 (manager, `[lifecycle-hardening/review.r1.md 3]`) `product-project-brief/SKILL.md:9` → "no `## Delivered` after the last `## Approval`", matching `product-manager:60`; the same fix rewrote the refusal (`[lifecycle-hardening/follow-ups.md FU1]`). Items 1, 2 and 4 are in `docs/specs/workflow.md`, superseded.
- [script-hardening/plan.md D1] (FG-1) After a failed write a run removes only the claim or lock it opened, by that name, and exits 2 with one line, branching on `create_line`'s code; `AGENTS.md` unchanged (`plan.md` F6). Its code numbering is superseded by `D7`.
- [script-hardening/plan.md D2] (FG-2) The store-filesystem requirement stays in the `plan-gate.sh` header, which its exit-2 message and T51 point at; non-restating pointers in `glab:product-manager` *The shared store* (*Where it is*), `README.md` *The shared store* and `host.example.md` *glab shared store*; `docs/one-fact.md` unchanged.
- [script-hardening/plan.md D7] (`check.r1.md` F-a, superseding `D1`'s numbering) `create_line`'s codes 0–4 (*`plan-gate.sh`*, above): 1 only when the name is there, by the guard or by the same test after a failed open, so a failed open with no name there stays exit 2 rather than a refusal naming a file that does not exist; `claim`, the lock and the re-create map 2/3/4 through one helper (`create_failed`), the lock's 1 keeping its refusal.
- [script-hardening/plan.md D8] (`check.r1.md` F-b) The `capped` helper writes to `$W/capped`, outside `$C`, so `snap "$C"` holds.
- [script-hardening/plan.md D9] (`check.r1.md` F-e) `rm -f -- "$1" 2>/dev/null`, so code 4 is one line.
- [script-hardening/plan.md D11] (`check.r1.md` F-f) The `create_line` comment names both windows — guard to open, failed write to `rm` — each needing a hostile writer; unfixed (`[script-hardening/plan.md FU-SH3]`). Since review r1 (`D21`) window (1)'s comment also names its consequence: a planted name is removed.
- [script-hardening/plan.md D16] (`check.r2.md` N2) The open and the write are two commands — the `exec` of fd 9 under `set -C`, then `printf >&9` — so their failures differ; `set +C` and the umask restored on every path; fd 9 used nowhere else.
- [script-hardening/plan.md D17] (`check.r2.md` N3) Code 4 is reached without root by a stub `rm` first on `PATH` (T55, `AGENTS.md` *Tests*).
- [script-hardening/plan.md D19] (`check.r2.md` N5) The dangling-symlink change, rc 2 to rc 1 with the link kept, is stated (`plan.md` F5, FU-SH3).
- [script-hardening/plan.md D21] (manager, `[script-hardening/review.r1.md]`) The medium fixed as the reviewer specified: `elif ! { command exec 9>"$1"; } 2>/dev/null; then`, and every other `exec` the change added through `command`, with T56 running the read-only-store case and a claim-race loser in posix mode; the lows: T52's decoy at the same name (`.plan-gate.claim.report.r1`, a foreign line, the `REFUSED:` line and the cksum asserted), T54 listed as coverage of code 2 rather than a regression test, window (1)'s comment naming its consequence. The `take_over` hang stays FU-SH1.
- [script-hardening/plan.md D22] (manager) T47 fails under `POSIXLY_CORRECT=1` on the base and on the new script alike; it predates the change and is tracked as `[script-hardening/plan.md FU-SH4]` (*Open follow-ups*).
- [script-hardening/plan.md D23] (manager, `[script-hardening/review.r2.md]`, the review cap) T56 drops `POSIXLY_CORRECT=1` from its `bash -c` and runs `set -o posix;` inside it after the function `[` is defined, since bash 4.4–5.2 reject that name in posix mode; verified by the manager on the build host and on bash 5.2, not by a third review (*Incidents*).

## Known limits and not verified

- [flow-product-level/evidence.md LP1] UNVERIFIED until the user runs it after install: the hook picks the product text in a repo whose `AGENTS.md` says `glab-level: product`, also when the session starts in a subfolder (`F4`), and the session then loads `glab:session-rules` as well as its manager (`F24`). `tests/manager-bootstrap.test.sh` B2 and B13 show the script's output only.
- [flow-product-level/evidence.md LP2] UNVERIFIED: a product session keeps to its manager's list, also with a crowded skill listing that drops descriptions (`F14`). The main session's boundary is text only (`E11`); the hard one is `[flow-product-level/plan.md FU-P2]`.
- [flow-product-level/evidence.md LP3] UNVERIFIED live: `${CLAUDE_PLUGIN_ROOT}` is substituted in the new skills' text, which runs `plan-gate.sh` by that path — documented (`F7`), as `[flow-commands-to-skills/plan.md U6]` is for `glab:bootstrap`.
- [flow-product-level/evidence.md LP4] UNVERIFIED: starting and reaching project sessions per host — that a session's Bash tool can run `claude --bg`; that `SendMessage` and `notify_when_idle` reach a background session it started; that the start prompt's git sentence keeps a background session from committing and pushing (F19); that `claude --resume <full session id> --bg` continues a stopped one; that the desktop tool, which "cannot deliver into a session an orchestrator dispatched", reaches a session it started. Read from `claude --help` on 2.1.310 and the tool texts (`E20`), never run. The user's own start always works.
- [flow-product-level/evidence.md LP5] UNVERIFIED live: the product agents preload their `skills:` — documented (`F11`); the same claim as `[flow-commands-to-skills/plan.md U4]`.
- [flow-product-level/evidence.md LP6] UNVERIFIED: the product session, its store added with `--add-dir <store>` or `/add-dir`, writes a brief through `glab:product-planner` and a verdict through `plan-gate.sh` without a prompt per write (R2-4); and whether a subagent's Write outside the session's directories is prompted rather than refused. LP1–LP6 are `[flow-product-level/plan.md FU-P4]`, open, and `README.md` *Try the product loop* lists them.
- [flow-product-level/result.md bash-3.2] UNVERIFIED: that bash 3.2 (macOS) opens a noclobber `>` with `O_EXCL` as bash 5.3.9 does on the build host (`strace` there showed `O_WRONLY|O_CREAT|O_EXCL`), for the claims and `claimed_tmp`, and that its trap runs on TERM and INT at the same points. No macOS host was available (fix rounds 1 part 2 and 2). Since 0.14.1 also UNVERIFIED there: `trap -` with a re-sent signal (`release_signals`) and `${e//$'\n'/ }` (`publish_file`) (`[flow-gate-hardening/plan.md limits]`).
- [flow-product-level/result.md o-excl-network] UNVERIFIED: that `O_EXCL` is exclusive for a store on a network filesystem; only a local filesystem was tested. Since 0.14.1 the header of `plan-gate.sh` names where a store may live (*`plan-gate.sh`*, above), a network, FUSE or synced folder UNVERIFIED there too — whether `O_EXCL` and a link are exclusive across hosts (`[flow-gate-hardening/plan.md filesystems]`).
- [flow-product-level/review-2.md finding-2] Known limit until 0.14.1, proven then: a TERM that lands while `ln` itself runs still removed `plan.r<n>/` of a report that is linked, because bash runs the trap as soon as `ln` exits — with an `ln` stub that links then waits 2 s, `report run rc=143` and the folder `brief.md report.r1.md`. Review round 2's fix narrowed the window from `rm`'s run time to `ln`'s → closed by `2724086` (`glab` 0.14.1): TERM, HUP and INT are held from before `ln` until `TMP_DIR` is cleared, T49 (`[flow-product-level/follow-ups.md FR2-1]`, *Closed follow-ups*).
- [flow-product-level/result.md claim-window] UNVERIFIED until 0.14.1: that a signal between the claim's subshell and `CLAIM=$1` leaves the claim — the review's reasoning, stated in the script comment; no stub can stop bash between two builtins → closed by `2724086`: each create in `claim` and `take_over` and the assignment after it run under held signals, in the run's own bash (`[flow-gate-hardening/plan.md hold-claim]`, `[flow-gate-hardening/review-1.md finding-1]`); shown on instrumented builds — A5 on the pre-fix build, the developer's before-and-after stand-ins on the shipped one (`result.md` *Review round 1 fixes*) — and by no permanent case, which would need an instrumented copy. Still covered by no case: the re-tests under the claim (they need a run to lose the CPU until another has published and released), and the exit-2 branches of `publish_file`, `claim`, `claimed_tmp`, `mkdir` and `chmod -R`, which need a failing filesystem. **Amended by `script-hardening` (`64b4e57`, 0.16.3):** the exit-2 branches of `claim` and of `take_over`'s lock are covered since — T52 (claim code 3), T53 (lock code 3), T54 (claim and lock code 2), T55 (code 4) and T56 (code 2 and code 1 after a failed open, in posix mode), a write limit (`ulimit -f 0`), a folder the run cannot write and a stub `rm` standing in for a failing filesystem; still covered by no case: the re-create's 2/3/4 branch under the lock (it needs the claim's create to fail just after the lock's succeeded in the same run), both `[script-hardening/plan.md D11]` windows, and the exit-2 branches of `publish_file`, `claimed_tmp`, `mkdir` and `chmod -R`.
- [flow-gate-hardening/plan.md limits] Known limits of the takeover, as of `2724086`: it is Linux-only — elsewhere, or where `/proc` is missing or another pid namespace's, a claim stays refused until a person removes it; a claim is empty for the instant between its create and its write, and one killed there stays refused; a SIGKILL inside `take_over` leaves the lock, and every later takeover of that number is refused naming it (`[flow-gate-hardening/plan.md lock-left]`); a claim from before a reboot stays refused, since the boot id differs and `owner_gone` cannot tell (safe: a person removes it); a signal held when the run exits refused or failed is dropped, the exit keeping its status.
- [flow-gate-hardening/plan.md Tests] UNVERIFIED, covered by no case: network, FUSE and synced stores; bash 3.2 (above); a host without `/proc` (`whoami`, and the `PROC`-unset branches of T38 and T43); a store on another account (one account on the build host); `take_over`'s `io` branches and a create that fails with no file there (a failing filesystem; **covered since 0.16.3** by T54 and T56, a folder the run cannot write, `script-hardening`); a lock left by a SIGKILL inside `take_over`; the `X` state (a dead task, gone before a test can read it). M1 (the takeover without its lock) against the shipped lock code is UNVERIFIED: A7's mutants were run on the pre-fix build only (`[flow-gate-hardening/plan.md final-check]`).
- [flow-product-level/result.md final-check] The final check gave `DIVERGES: 1`, a missing record, which the manager supplied as `result.md` *Final check record*: X3 prints `253 ok` and 8 FAIL lines, not `261 ok`, every failing post checking text a review decision superseded — A1 one byte-compare, A2 two byte-compares and its partner run (`FAIL 13/42` against the superseded script), P4 (B7), P7 (B4), J2 (A4, B9), R5 two (B5). The master's *Final check* item 3 holds with these eight recorded exceptions; the plan files were not edited.
- [flow-product-level/result.md X4] X4 as `plan.md` writes it prints `xargs: command: No such file or directory`, since `command` is a shell builtin `xargs` cannot run, and `git diff --name-only main` lists no untracked new file; the developer ran an equivalent over the 49 changed and new files, which printed only `host.example.md`'s author's temp-dir lines, as on `main`.
- [flow-product-level/plan.md Tests] The Markdown has no runtime: P1–P9, J1–J12 and R1–R6 are shown by their posts and the gates only, the text there, not a live session following it — UNVERIFIED, as for every prose rule. The scripts are covered as listed in `plan.md` *Tests* and `result.md`'s fix rounds; LP1–LP6 by no case, accepted because each needs a live, logged-in session.
- [docs-lifecycle/result.md Not done] UNVERIFIED: P7 in a live product loop — no session ran the roadmap stage end to end (`[docs-lifecycle/review.r1.md]` and `review.r2.md`, *What I did not check*); `tests/product-loop.test.sh` was not changed and plays no P7. Only the greps, `plugin validate --strict` and the gates were run.
- [docs-lifecycle/plan.md Evidence] UNVERIFIED: that `claude plugin validate --strict` limits a frontmatter `description` to 1024 bytes — not run as a limit test; 1024 is the Agent Skills frontmatter limit. The new descriptions measure 472 (`product-planner.md`) and 423 bytes (`product-analyzer.md`) by `sed -n 's/^description: //p' | wc -c` (`[docs-lifecycle/result.md]` PC28), and G17–G19 pass on them.
- [docs-lifecycle/plan.md Evidence] UNVERIFIED: the product-side facts the plan rests on (its `E9`) come from the cited lines, not from a live run of the product loop.
- [docs-lifecycle/plan.md D14] Known limit: a later report for a project whose product slug was recorded and removed finds no `plan/*/product-plan.md`, and `product-project-plan-analyze:15` then asks the user (*Open follow-ups*).
- [docs-lifecycle/plan.md Not done] The delivery level (`releases/`) is still not written; "delivered" is defined at the product level only (D9; since 0.16.1, `[p7-delivery-gate/plan.md D1]`: the user's `## Delivered` confirmation).
- [p7-delivery-gate/review.r1.md] UNVERIFIED: no live product session ran through P6, the `## Delivered` confirmation and P7; that the folder's removal cannot come before `## Delivered` is reasoned from `glab:bootstrap` step 5, `glab:session-rules` Rule 2 and the P7 bullet, not run. Only the post-conditions' greps and the gates were run (`[p7-delivery-gate/result.md]`, `PASS 31/31`).
- [p7-delivery-gate/check.r1.md] UNVERIFIED: that the Codex review's P1 and P2 on PR #19 say exactly what `F2` and `F3` say — the PR was not fetched by the plan check.
- [lifecycle-hardening/result.md Not done] UNVERIFIED: no live product session ran P6's new test, the `## Delivered`-after-the-last-`## Approval` condition or the brief's new precondition; the P6 allow-list was run in throwaway repos only (`check.r1.md` M3, `check.r2.md` N4, `review.r1.md` and `review.r3.md`: `## main...origin/main` and `[behind 1]`/`[behind 2]` pass; `[ahead 1]`, `[ahead 1, behind 1]`, `[gone]`, no upstream, `## main...other`, a detached HEAD, `No commits yet … [gone]` and an untracked file's second line fail), not by the build (`result.md` *Tests*: "Not covered").
- [lifecycle-hardening/review.r1.md] Known limit, not raised as a finding: P6 fails `## main...up/main`, a remote not named `origin`; the test is safe only where `origin` is the remote (`D20`).
- [lifecycle-hardening/review.r1.md] UNVERIFIED: the roadmap page's *Records* `<first>`/`<last>` when P6 had nothing to commit (outside that diff, not checked).
- [script-hardening/plan.md Coverage] UNVERIFIED, as of `64b4e57`: a real ENOSPC or EDQUOT — EFBIG from `ulimit -f 0` stands in, on the same write path (`plan.md` F3, `check.r1.md` *Not checked*); the code 1 found after a failed open in a real race — only T56's injected loser reaches it (`result.md` *Review r1 fixes*); the claim's re-create under the lock, its 2/3/4 branch (`result.md` *Tests*); that SIGXFSZ kills the run when it is not ignored — `plan.md` F3's claim, not re-run (`check.r1.md` *Claims*); that fd 9 is closed after code 4 — never logged, the logging write itself failing under `ulimit -f 0`, and read only from the code (`[script-hardening/review.r2.md]` *Claims*, *Not checked*); both `D11` windows, described only (FU-SH3); macOS, bash 3.2 for `plan-gate.sh` and hosts without `/proc` (`[script-hardening/review.r1.md]` and `review.r2.md` *Not checked*); T54 and T56 as root, where they skip. The suite ran on bash 5.3.9 (the build host) and, for review r2's fix, on bash 5.2.37 and 5.1.16, where it passes: `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh` on the final tree `f7af56c`, in a local container image with `--network none` and the repo mounted read-only, printed `PASS 56/56` on bash 5.2.37 and `PASS 56/56` on bash 5.1.16 (the manager, this record's dispatch, 2026-11-18; *Incidents*); bash 4.4 and 5.0 were not run. The `gates.sh` side — a real bash older than 4.4 — is in `docs/specs/marketplace.md` *Known limits*.

## Open follow-ups

- [script-hardening/plan.md FU-SH1] A claim symlinked to a character device (`/dev/full`, `/dev/zero`) hangs `take_over`'s `head -n 1` (`plan.md` F5: `timeout 5`, rc 124; `[script-hardening/review.r1.md]`: hung on the base and the new script until `head` was killed by its PID, then bash's "ignored null byte" warning on stderr). It predates `script-hardening`; since 0.16.3 the pre-open guard sends every non-regular name down this path. A bounded read, or refusing a claim that is not a regular, non-symlink file before reading it, is a separate change — open.
- [script-hardening/plan.md FU-SH3] The two `D11` race windows of `create_line` stay open (*`plan-gate.sh`*, above), each needing a writer acting against the run on purpose. And the behaviour for claim symlinks changed in 0.16.3: a link to `/dev/null` went from rc 0, with no exclusive claim, to rc 1, refused; a dangling link from rc 2, `writing … failed`, to rc 1, `REFUSED: … remove … by hand`; the link kept in both (`D19`). A name planted before the run is refused; only one planted in window (1) still opens — open.
- [script-hardening/plan.md FU-SH4] (`D22`) T47 fails under `POSIXLY_CORRECT=1` — `the run that found the claim stale first: rc=0 …` — on the base script and on the 0.16.3 script alike, so `POSIXLY_CORRECT=1 bash tests/plan-gate.test.sh …` gives `FAIL 1/56` (`result.md` *Review r1 fixes*; `[script-hardening/review.r2.md]`). It predates `script-hardening` — open.
- [flow-product-level/plan.md FU-P2] A hard boundary for the main session: `Skill(...)` permission rules per level, or a hook that refuses another level's skill; feasible by the documented `Skill(name)` syntax (`F15`), needs a live test first — open.
- [flow-product-level/plan.md FU-P3] The Notion view of the store ("plain folder but I'm planing to connect here notion page"), read-only, never the gate; it changes `glab:product-manager` *The shared store* and `plan-gate.sh` only — open.
- [flow-product-level/plan.md FU-P4] The live tests LP1–LP6, run by the user after install (*Known limits*) — open.
- [flow-product-level/plan.md FU-P5] A hard hold on `by user`: today any session can pass it (R12); a check that the words came from the user needs a mechanism this plan does not have, and whether Claude Code offers one is UNVERIFIED — open.
- [manager-flow-notes.md later-1] **The user's, parked 2026-11-13** ("yes, and also main CLAUDE.md in claude code home folder must not mention about bootstrap skill, would be better to think about hook based force skill loader for main sessions, bot let's add note about this, to solve it later, good?", from `plan/manager-flow-notes.md` *Later: agent and session context cleanup*, untracked): `omitClaudeMd: true` on all nine `glab` agents, an agent frontmatter field of CLI 2.1.310 that runs a subagent without the user, project and local `CLAUDE.md` files (Claude Code's built-in Explore and Plan agents set it; the public docs not yet checked), and a gate that every agent file carries it. **Prerequisite:** the machine hazards, above all temp files in the host file's temp directory and never `/tmp`, reach agents today only through `~/.claude/CLAUDE.md`, and no `glab` agent reads the host file, so each agent first needs another way to learn them — it reads the host file at start, or the manager's dispatch carries the temp-directory line; without it an agent writing to `/tmp` can exhaust the shared tmpfs quota. Verifiable only live, by a real dispatch after install — open, agreed, not planned; timing, per `[flow-project-level/master.md]` *Out of scope*: "in the end when we will finish all agents" (the user's words, relayed by the manager 2026-11-14).
- [manager-flow-notes.md later-2] **The user's, parked 2026-11-13** (the same words, same source): no bootstrap text in `~/.claude/CLAUDE.md`; a hook-based skill loader makes the main session load its skills instead. Already true: the `SessionStart` hook injects the session-start text, and since 0.14.0 reads `glab-level` and names the level's manager and `glab:session-rules`. To prove first: whether a hook can make Claude invoke a skill or only add context (inferred: only add context, UNVERIFIED); that `additionalContext` is capped at 10,000 characters, so a hook injects a short, firm instruction and the level's skill list, never a whole skill (`glab:manager` was about 55 KB when noted, 40284 bytes at `ce1a933`); which event gives the strongest guarantee, and whether a `UserPromptSubmit` check can re-assert it after a compaction; what stays in `~/.claude/CLAUDE.md` afterwards — the machine hazards only, or nothing. Changing that home file is the user's step, never an agent's. Once it holds no session rules, `omitClaudeMd` (later-1) loses nothing but the hazards, which later-1 moves anyway — open, an idea, not planned; timing as later-1's (`[flow-project-level/master.md]` *Out of scope*).
- [docs-lifecycle/result.md follow-up-3] `plugins/glab/skills/product-plan/SKILL.md:3`, the `description`, does not mention the roadmap, which the skill's *The roadmap* now holds; no step changed it — open.
- [docs-lifecycle/result.md follow-up-4] `plugins/glab/skills/product-manager/SKILL.md:55`: the P7 row has no backticks, unlike the other rows, because it was written exactly as P14 gives it — open, cosmetic. Since 0.16.1 that row is `:56`, the Delivered row above it (`[p7-delivery-gate/plan.md D6]`).
- [docs-lifecycle/plan.md D14] Make the roadmap page an audit source, so that a P4 audit of a project whose product slug was recorded and removed has something to read instead of asking the user (*Known limits*) — open, named by the plan's *Not done* for the record to carry.
- [lifecycle-hardening/review.r3.md 6] (low) `plugins/glab/skills/product-manager/SKILL.md:60`: "The plan folder is removed later, at a session start (`glab:bootstrap` step 5)" leaves out "on the user's word". A pointer; it contradicts nothing. Suggested: add "on the user's word (`glab:session-rules` Rule 2)" — open.

## Closed follow-ups

- [flow-gate-hardening/follow-ups.md FG-1] (low, review round 2, inferred) When the exclusive open of a claim succeeds but the write fails (for example ENOSPC), the run leaves a claim file with an empty line, refuses with exit 1 and asks the user to remove its own file, where the contract (`AGENTS.md` *Rules*) expects exit 2 for a failed write. The same held before 0.14.1 (the round-1 subshell); the comment of `create_line` in `plugins/glab/scripts/plan-gate.sh` states it → **closed by `64b4e57`** (`glab` 0.16.3, `script-hardening`, PR #23), `[script-hardening/plan.md D1]`, `D7`: the open and the write are two commands, and a failed write removes only the file the run made, by its name, and exits 2 with `plan-gate.sh: writing <file> failed` (or the code-4 line when that removal fails too) instead of a refusal; reproduced before the change (`plan.md` F2: rc 1, the `REFUSED:` line, a 0-byte claim left) and covered by T52, T53 and T55 (*`plan-gate.sh`*, above).
- [flow-gate-hardening/follow-ups.md FG-2] (low, review round 1 advisory) The store's filesystem requirement (hard links; not FAT; network and synced stores UNVERIFIED) is stated only in the `plan-gate.sh` header and, since this record, in this file's owner pointer; `README.md` *The shared store* and `host.example.md` tell users to make a store folder without it. Whether the README should point at it is open (`[flow-gate-hardening/plan.md filesystems]`) → **closed by `64b4e57`** (`glab` 0.16.3, `script-hardening`, PR #23), `[script-hardening/plan.md D2]`: the header stays the owner; `README.md` *The shared store*, `host.example.md` *glab shared store* and `glab:product-manager` *The shared store* (*Where it is*) each say in one sentence that the filesystems are named in the header of `plan-gate.sh`, restating none of them (`plan.md` PC6: `FAT|xfs|O_EXCL` 0 in each file, `header of` 1 in each); `docs/one-fact.md` unchanged.
- [p7-delivery-gate/plan.md F2] Codex review on PR #19 (its P1): `glab:project-plan-report`'s "`ACCEPTED` → Stage 2" shows a verdict approves a project's *plan*, so P7's old condition could hold before anything was built → closed by `afda097` (`glab` 0.16.1, `p7-delivery-gate`): P7 also needs the user's `## Delivered` line (`[p7-delivery-gate/plan.md D1]`).
- [p7-delivery-gate/plan.md F3] Codex review on PR #19 (its P2): P6 left only on "landed and confirmed", but with the store outside the product repo P1–P5 write only the ignored `plan/` and the store, so P6 had nothing to commit and P7's old condition never held → closed by `afda097`: P6 is done also when the product repo's `git status --short` prints nothing (`[p7-delivery-gate/plan.md D2]`; its gap with an unpushed commit is `[p7-delivery-gate/review.r1.md 1]`, open).
- [flow-product-level/plan.md FU-P1] The rules every level's manager acts on, out of `glab:manager` — raised in planning because the product manager may not read `glab:manager` (I12) — closed in the same change (`ce1a933`, `glab` 0.14.0; J2): Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, *Round caps* and *The handoff line* live in `glab:session-rules`, which both managers load (`docs/specs/workflow.md`, *`glab:session-rules`*).
- [flow-product-level/follow-ups.md FR1-1] Hard links on the shared store: since review round 1 (A2) `plan-gate.sh` publishes each report and verdict with `ln`, so a store on a filesystem without hard links (some network or FAT-family mounts) fails every write with exit 2, `plan-gate.sh: writing <path> failed`, where `mv` worked before. UNVERIFIED on any such mount; nothing in this repo named which filesystems a store may live on (out of scope then: the decision chose `ln`) → closed by `2724086` (`glab` 0.14.1, `flow-gate-hardening`), `[flow-gate-hardening/plan.md no-hardlinks]`: no fallback; the exit-2 message names the requirement and points at the header, which names the filesystems (*`plan-gate.sh`*, above); simulated by an `ln` stub that prints GNU's real EPERM line, T51.
- [flow-product-level/follow-ups.md FR1-2] A claim left by a killed run: a run killed by SIGKILL or a host crash leaves `.plan-gate.claim.<report|verdict>.r<n>` in `briefs/<project>/`, and every later run for that number is refused until someone removes it by hand (proven with a planted claim, `rc=1`). Review round 2 (finding 1) made the refusal name the claim file and say to remove it by hand when no run is writing (T38); nothing told a stale claim from a live one, so a person decided → closed by `2724086`, `[flow-gate-hardening/plan.md takeover]`: a claim names its run, and a later run on the same host takes over the claim of a run that provably no longer runs, exclusively under a lock, the claim read again under it; T38 (rewritten, `[flow-gate-hardening/plan.md t38]`) and T43–T48. A claim from another host, boot or pid namespace, or one whose run cannot be proven gone, keeps the refusal (*Known limits*).
- [flow-product-level/follow-ups.md FR2-1] A signal while `ln` runs: a TERM inside `ln`'s own lifetime still removed `plan.r<n>/` of a report that is linked (*Known limits*); closing it needed the signals held off across the `ln`, which the review did not ask for → closed by `2724086`, `[flow-gate-hardening/plan.md hold]`: TERM, HUP and INT are held from before `ln` until `TMP_DIR` is cleared and re-sent after, T49 (a slow-`ln` stub, the signal arriving inside `ln`); an `ln` that linked and was then killed counts as published (`[flow-gate-hardening/plan.md ef]`), T50.
- [flow-product-level/follow-ups.md FR2-2] A temporary file left by SIGKILL: `.plan-gate.tmp.<report|verdict>.r<n>` stays beside its claim, and the claim's refusal named only the claim; the next run that takes the claim removes it (T38) (the finding asked for the trap to reach the file, which it does on every signal it sees) → closed by `2724086`, `[flow-gate-hardening/plan.md refusals]`: the run that takes over a stale claim removes that file, and a refusal of a claim that cannot be proven stale names it too; T38, T43 and T44.
- [p7-delivery-gate/review.r1.md 1] (low) `plugins/glab/skills/product-manager/SKILL.md:54`: P6's "nothing to commit" test, the product repo's `git status --short` printing nothing, also passes when P6's commit was made but its push declined (a throwaway repo: `status --short` printed nothing, `status --short --branch` printed `[ahead 1]`), and outside a git repo it prints nothing on stdout (rc 128). Harm is limited: P7's own push, on the user's go-ahead, carries those commits, and the folder is removed only once the roadmap is on origin. Fix: "`git status --short --branch` exits 0 and prints only its `##` line, with no `[ahead`", the command in backticks — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D10]`, `D20`):** `product-manager/SKILL.md:54` — "in the product repo `git status --short --branch` exits 0 and prints one line, `## <branch>...origin/<upstream>`, with no bracket or exactly `[behind <n>]`; `[gone]`, `[ahead`, `No commits yet`, no upstream, a detached HEAD or exit ≠ 0 fail it".
- [p7-delivery-gate/review.r1.md 2] (low) `plugins/glab/skills/product-manager/SKILL.md:60`: the condition is only that `product-plan.md` "has its `## Delivered` line", not tied to the last `## Approval`; a plan amended and approved again after delivery keeps the old Delivered line above the new Approval, and it still lets P7 start. Fix: "a `## Delivered` line after the last `## Approval`", or an amendment removes it — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`):** `product-manager/SKILL.md:60` — "`product-plan.md` has a `## Delivered` line after the last `## Approval`".
- [p7-delivery-gate/review.r1.md 3] (nit) `plugins/glab/skills/product-manager/SKILL.md:49` and `plugins/glab/skills/product-project-brief/SKILL.md:9` say the `## Approval` line is "at the end of" / "ends with" `product-plan.md`, no longer literally true once `## Delivered` follows it. Nothing breaks in the normal order (P2 runs before Delivered exists); only a P2 re-run after delivery is refused (`[p7-delivery-gate/plan.md D7]`). Optional fix: "ends with its `## Approval` line, or that line then `## Delivered`" — open. **Closed by `lifecycle-hardening` (`bf9c73f`, `glab` 0.16.2; `[lifecycle-hardening/plan.md D4]`, `D14`, `D24` item 3):** the Approval and Delivered rows say "appended to `product-plan.md`" (`product-manager/SKILL.md:49`, `:55`), and the brief's precondition reads "has its `## Approval` line, and no `## Delivered` after the last `## Approval`" (`product-project-brief/SKILL.md:9`), so a P2 re-run after a new approval is no longer refused.
- [lifecycle-hardening/follow-ups.md FU1] `plugins/glab/skills/product-project-brief/SKILL.md:9` — the precondition became "has its `## Approval` line, and no `## Delivered` after it", but the next sentence still read "None → stop: a brief is written only from a plan the user approved"; "None" and its reason fit only the first half, and a slug delivered after its approval also stops without saying why. Out of scope then: Step 5 named only the precondition clause (`result.md` *Follow-ups*) → closed in the review-round-1 fixes (`[lifecycle-hardening/plan.md D24]` item 3): "Otherwise → stop: a brief is written only from a plan the user approved, and a delivered plan takes none until the user approves it again."

## Incidents

- **`mkdir` was not exclusive on the build host, so the claims moved to bash `set -C`** (`flow-product-level`, review fix round 1, `[flow-product-level/result.md]` *Fix round — review round 1* and *part 2*): review round 1's A2 decided to claim `plan.r<n>/` with `mkdir`. The host's `/usr/bin/mkdir` was uutils coreutils 0.10.0, and two `mkdir` calls racing on one name both returned 0 in 23 of 40 tries (14 of 30 on a second run; 11 of 40 measured again in part 2), against 0 of 30 for GNU `mkdir` and 0 of 40 for uutils `ln`. With the fixed script and a 1 s delay, two reports ended correctly in 4 of 10 runs; in one the loser's trap deleted the winner's `plan.r1/` after its report was linked. The developer added no two-reports test, which would have failed about 6 runs in 10, and stopped A2's report half as `PLAN WRONG`, beside advisory 3 (the `jq` tabs, the plan's own text). The manager decided every claim is an exclusive create by bash itself, `(set -C && : >claim)` — `strace` showed `O_WRONLY|O_CREAT|O_EXCL` — and rejected advisory 3 (`review-1.md` *After part 1 of the fix round stopped on two PLAN WRONGs*). After: 20 of 20 races correct, the primitive alone 0 of 40, T37 `PASS` ten runs in a row. Lesson: a coreutils command's atomicity is the host's, not POSIX's; a claim the script makes itself does not depend on it. Whether bash 3.2 and a network filesystem keep it is UNVERIFIED (*Known limits*). The host hazard is pointed at from `docs/specs/marketplace.md` *Incidents*.
- **A failed `exec` redirection ended the run silently in posix mode** (`script-hardening`, review round 1, medium; `[script-hardening/review.r1.md]`, `plan-gate.sh:203` at `f425329`): the first build opened fd 9 with `{ exec 9>"$1"; } 2>/dev/null`. `exec` is a special builtin, so with `POSIXLY_CORRECT` set a failed redirection on it ended bash at once, status 1, the message dropped by `2>/dev/null`, and neither `create_failed` nor `refuse` ran: the loser of every claim race, and every claim in a folder the run cannot write, exited 1 with no `REFUSED:` line, breaking the contract. The base script, writing with a plain `printf >file`, passed T33, T37 and T54 under `POSIXLY_CORRECT=1`; the first build failed all three. Fixed by `command exec` (`[script-hardening/plan.md D21]`), with T56; on the fixed script `POSIXLY_CORRECT=1` gives `FAIL 1/56`, T47 only (FU-SH4). Lesson: a special builtin's failure is fatal in posix mode; run it under `command` when its status is read.
- **T56 failed on a correct script on bash 4.4–5.2** (`script-hardening`, review round 2, medium; `[script-hardening/review.r2.md]`, `tests/plan-gate.test.sh:1056` at `afae6db`): T56 started its `bash -c` with `POSIXLY_CORRECT=1` and then defined a function named `[`, a name bash 4.4 to 5.2 reject in posix mode (`'[': not a valid identifier`; bash 5.3's NEWS: "Posix mode no longer requires function names to be valid shell identifiers"). The reviewer ran the suite on bash 5.2.37 in a Debian container, no network, the repo mounted read-only: `FAIL 1/56`, T56 alone. The build host had only bash 5.3.9, so the developer's runs could not see it, while the gates accept 4.4 and newer. Fixed by `set -o posix;` inside the `bash -c`, after the function is defined (`[script-hardening/plan.md D23]`).
- **The planner's background run of the FU-SH1 hang had to be stopped** (`script-hardening`, planning; the manager, this record's dispatch, 2026-11-18 — no file under `plan/script-hardening/` states it): a run reading a claim symlinked to a character device does not end (`take_over`'s `head -n 1`, `[script-hardening/plan.md FU-SH1]`). `plan.md` F5 records the bounded probe, `timeout 5`, rc 124; review round 1 met the same hang and killed `head` by its PID (`[script-hardening/review.r1.md]`). Lesson: a probe of that path runs under `timeout`, and a run started in the background is stopped by its own PID.
- **Both round caps were reached, and the last fixes were verified by the manager** (`script-hardening`; `[script-hardening/plan.md D20]`, `D23`): plan check round 1 was `NOT BUILDABLE` on two highs (`[script-hardening/check.r1.md]` F-a, a failed open with no name there turned into a refusal naming a file that does not exist; F-b, the helper's file inside the snapshotted folder), and round 2, the plan-check cap, `NOT BUILDABLE` on N1 (T53 without the report it needs) and four lower findings (`[script-hardening/check.r2.md]`); N1–N5 were fixed as the checker specified and verified by the manager's greps, not by a third round (`D20`). Review round 2, the review cap, returned `FIX` on T56 (above); its fix was verified by the manager, not by a third review (`D23`): the suite on the build host and on bash 5.2.37 and 5.1.16, in local container images run with `--network none` and the repo mounted read-only (the manager, this record's dispatch).

## Records

- 2026-11-13 · flow-product-level · the product level above the project level, in `glab`: `glab:product-manager` and six `glab:product-*` skills, the agents `glab:product-planner` and `glab:product-analyzer` on `opus`; the rules every manager shares moved, words kept, into `glab:session-rules`; each manager's explicit skill list as the level boundary; the `glab-level:` line read by the session-start hook and the `glab-shared-store:` line; the shared store; `plan-gate.sh` with the hash gate and the two-rejection cap; project Stage 1c and `glab:develop`'s product-verdict precondition; three new tests and the walkthrough; `glab` 0.14.0 · change ce1a933 (the branch commit `e4b8157`, the same tree) · plan: `git ls-tree -r --name-only ce1a933 -- plan/flow-product-level/` (one file: `git show ce1a933:plan/flow-product-level/<file>`; the whole folder: `git archive ce1a933 plan/flow-product-level/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `ce1a933` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-product-level/`; PR #11, merged with rebase on the user's go, "yes merge" — the user, in chat, 2026-11-13): the folder is removed in the record commit. It holds 33 files: `master.md` with `master.sha256`, `plan.md`, `evidence.md`, `questions.md`, the five steps files `steps-1-scripts.md`, `steps-1b-scripts.md`, `steps-2-product.md`, `steps-3-project.md`, `steps-4-repo.md`, the plan checks `check-repo.md`, `check-facts.md`, `check-repo-2.md`, `check-facts-2.md`, `review-1.md`, `review-2.md`, `result.md`, `follow-ups.md`, and round copies — `master.r1.md`, `master.r2.md`, `plan.r1.md`, `plan.r2.md`, `evidence.r1.md`, `evidence.r2.md`, `questions.r1.md`, and `.r1.md` and `.r2.md` of the steps files (`steps-1-scripts.r1.md` and `steps-1b-scripts.r2.md` only for those two). The record takes its items from the current files, and for `plan-gate.sh` and its test from `review-1.md`, `review-2.md` and `result.md`, which supersede the steps' text.
  - [flow-product-level/plan.md Decisions] Decisions → the request ("finish product skills and wiring with project first, I want to see how these skills will work"), the approval ("we need to develop, go with your recommendations"), `session-rules`, `Q1` ("Opus for both"), `Q2` ("Keep names (Recommended)"), the user's words quoted in `master.md` *Request* from the untracked notes ("one plugin for all", "okay two is good", "product manager and or also me", "Files in a shared folder" / "plain folder", and G4's "accepted and rejected plan and small context or reason"), `N1`, `level-line`, `store`, `digest`, `one-script`, `report-brief`, `cap`, `verdict-owner`, `boundary`, `rules-move`, `audit-inputs`, `project-sessions`, `once-per-slug`, `rejected`, `tests`, `record`, `spent`, and the two review rounds' decisions, above under *Decisions that still bind*, but `session-rules`, `level-line`, `report-brief`, `boundary`, `rules-move`, `once-per-slug` and `rejected`, the project edges, which are in `docs/specs/workflow.md` with the user's words behind G2 ("planing skill of product manager must not work for project manager(s)") and G3 ("manager(s): must work with current flow what we have", "must force managers to send back report of planing before go to development phase"). The version, the gates, the hook contracts and the *One fact* changes → `docs/specs/marketplace.md`.
  - [flow-product-level/plan.md Contracts] Contracts → C1 the level line, C2 the store line, C3 the layout, C4 the digest, C5 the brief line, C6 the report, C7 the verdict, C8 `plan-gate.sh` (amended by the review rounds), C9 the session-start texts, C10 the audit lines, C11 the frozen plan — in *How it works now*, each with its owning file, here and, for C1, C5, C9 and C11, in `docs/specs/workflow.md`.
  - [flow-product-level/evidence.md] Evidence → `E2`, `E3`, `E11`, `E20` and the round-1 and round-2 facts `F4`, `F5`, `F11`, `F14`, `F17`–`F22` in *How it works now* and the decisions, here and in `docs/specs/workflow.md`; `LP1`–`LP6` under *Known limits*; the other `E` items were that change's readings, throwaway builds and baselines, their conclusions in the decisions; *Rejected boundaries* → the decisions `one-script`, here, and `level-line`, `once-per-slug` and `boundary`, in `docs/specs/workflow.md`.
  - [flow-product-level/follow-ups.md FR1-1] Follow-ups → `FR1-1`, `FR1-2`, `FR2-1`, `FR2-2`, `[flow-product-level/plan.md FU-P2]`–`FU-P5` open, `FU-P1` closed, above; the user's parked items `[manager-flow-notes.md later-1]` and `later-2` open, above. The older follow-ups this change altered, re-read at `ce1a933`, none closed, are in `docs/specs/workflow.md`.
  - [flow-product-level/questions.md Q1] Q1 → `[flow-product-level/questions.md Q1]`, "Opus for both"; Q2 → `[flow-product-level/questions.md Q2]`, "Keep names (Recommended)".
  - [flow-product-level/review-1.md] Review round 1 (two reviewers, 7 and 12 findings, A7 and B11 one) → all fixed in fix round 1 but A2's report half and advisory 3, stopped as `PLAN WRONG`; A2 rebuilt on bash `set -C` in part 2, advisory 3 rejected (*Incidents*); T30–T37.
  - [flow-product-level/review-2.md] Review round 2, the last (five `plan-gate.sh` findings, one medium, four low, and B8's leftover) → all fixed, T38–T42; no third round.
  - [flow-product-level/result.md Stages] Result → all 32 steps (B1–B3, A1–A5, P1–P9, J1–J12, R1–R6) done, nothing blocked; unplanned changes J2.5's `;`, J2's blank lines, R4's local rewrap, R6's plain store line, P2–P7's `argument-hint:`, and in the fix rounds `verdict`'s symlink refusal, the re-test under the claim, T33's and T37's loser lines and two shellcheck fixes; *Final check record* → *Known limits*; *Not done* → the trace kept out of the plan folder (X2), the `git add -N` slip → `docs/specs/workflow.md` *Incidents*; the fix rounds' UNVERIFIED → *Known limits*.
  - Incidents → the uutils `mkdir` and the move to `set -C`, above under *Incidents*; the `git add -N` slip and the two `NOT BUILDABLE` plan check rounds, incidents of the workflow's run, in `docs/specs/workflow.md` *Incidents*.
  - [flow-product-level/master.md Record] Record → this record, in this file, new, its primary area, in `docs/specs/workflow.md` for the project edges and in `docs/specs/marketplace.md`; no audit file.
- 2026-11-14 · flow-gate-hardening · `plan-gate.sh`'s four open follow-ups closed: a claim names its run and a later run on the same host takes over the claim of a run that provably no longer runs, exclusively under the lock `.plan-gate.takeover.<kind>.r<n>`, removing the temporary file the dead run left (FR1-2, FR2-2); TERM, HUP and INT held around each create and the publish (FR2-1, the claim window); the `-ef` check after a failed `ln`; a store without hard links an exit-2 message, no fallback, and the supported filesystems in the header (FR1-1); T38 rewritten, T43–T51 added, `PASS 51/51`; `glab` 0.14.1 · change 2724086 (PR #13, merged with rebase; the branch commit `bdee40a`, the same tree) · plan: `git ls-tree -r --name-only 2724086 -- plan/flow-gate-hardening/` (one file: `git show 2724086:plan/flow-gate-hardening/<file>`; the whole folder: `git archive 2724086 plan/flow-gate-hardening/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`). `2724086` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-gate-hardening/`): the folder is removed in the same PR as this record. It holds 10 files: `master.md` with `master.sha256`, `plan.md`, `evidence.md`, the steps files `steps-1-script.md`, `steps-2-test.md`, `steps-3-posts.md`, `review-1.md`, `result.md`, `follow-ups.md`. The record takes its items from the current files, and for `plan-gate.sh` and its test from `review-1.md`, `result.md` *Review round 1 fixes* and `plan.md` `review-fixes`, which supersede the steps' text.
  - [flow-gate-hardening/plan.md Decisions] Decisions → the request ("let's work on these gates"), the approval ("Yes, develop"), `claim-line`, `owner-gone`, `takeover`, `lock-left`, `refusals`, `copy-left`, `contract`, `t38`, `hold`, `hold-claim`, `ef`, `no-hardlinks`, `no-parse`, `readers`, `exit-2`, `filesystems`, `head`, `umask`, `limits`, `review-fixes`, `a6-a7-run`, `final-check`, and `effort`, `one-plan`, `size`, `gates` and `version` as `spent`, above under *Decisions that still bind*. The version, the gates' count and stubs, and the contract's new wording → `docs/specs/marketplace.md`.
  - [flow-gate-hardening/evidence.md] Evidence → E1–E13 were that change's readings, throwaway builds and baselines; their conclusions are in the decisions, and *Rejected boundaries* (`kill -0` alone; `flock`; a takeover by `mv`; a fallback to `mv`; a fallback by `O_EXCL` on the final name with an end marker; parsing `ln`'s message; a permanent case for the claim window) in `owner-gone`, `takeover`, `lock-left`, `no-hardlinks`, `no-parse` and `hold-claim`.
  - [flow-gate-hardening/follow-ups.md FG-1] Follow-ups → `FG-1` and `FG-2` open, above; `[flow-product-level/follow-ups.md FR1-1]`, `FR1-2`, `FR2-1` and `FR2-2` closed, above.
  - [flow-gate-hardening/review-1.md] Review round 1 (three lows and two advisories) → all three fixed (`[flow-gate-hardening/plan.md review-fixes]`), the `owner_gone` advisory as one comment sentence, the filesystem advisory → `FG-2`; review round 2: SHIP, its one low → `FG-1`; no third round.
  - [flow-gate-hardening/result.md Stages] Result → B1 and S1–S4 done, nothing blocked, no unplanned change; A6 "NOT RUN" superseded by `a6-a7-run`; its UNVERIFIED → *Known limits*.
  - Incidents → none recorded by this change.
  - [flow-gate-hardening/master.md Record] Record → this record, in this file, its primary area, and in `docs/specs/marketplace.md`; no audit file.
- 2026-11-18 · flow-project-level · recorded in `docs/specs/workflow.md`, its primary area; here: `glab` 0.15.0, the level-boundary exception gone with the name `glab:product-project-plan-report` (F13; `[flow-project-level/01-rename/plan.md]` P3 holds the old text), `glab:product-analyzer` preloading `glab:severity` in place of `glab:audit`, the product session start before (57203) and after (`prod` 44924, cap 47104; hook text 2584, base 2394), the project-level names in *How it works now* · change db5feae (01 `0c49626`, 02 `0cfe335`, 03 `db5feae`) · plan: `git ls-tree -r --name-only db5feae -- plan/flow-project-level/` (one file: `git show db5feae:plan/flow-project-level/<file>`). `db5feae` is the last commit on `origin/main` that holds it (`git log -1 --format=%h origin/main -- plan/flow-project-level/`; PR glab-services/skills#15, merged with rebase from `cf909b5`); final check CONFORMS (G1–G6).
  - Incidents → none recorded here.
  - [flow-project-level/master.md Record] Record → `docs/specs/workflow.md`, its primary area, this file for the product level's side and `docs/specs/marketplace.md` for the gates, the names and the handoff file.
- 2026-11-18 · docs-lifecycle · 3ed6746 · 3ed6746 · docs-lifecycle · #19
  - PR #19 (glab-services/skills), rebase-merged onto `main` as `d2ca05b` on 2026-11-18; recorded in `docs/specs/workflow.md`, its primary area; here: stage P7 Roadmap and `docs/roadmap/<slug>.md`, the product plan as an uncommitted working file, the product agents' descriptions and the stage lists naming P7; `glab` 0.16.0. The plan folder was not kept in git.
  - [docs-lifecycle/plan.md Decisions] Decisions → M2, D9–D14, D29, D33, D43 and D45's P7 half, above under *Decisions that still bind*; the others in `docs/specs/workflow.md` and `docs/specs/marketplace.md`.
  - Not verified → the live P7 flow, the 1024-byte description limit, E9's cited lines, D14's limit and the delivery level, above under *Known limits*.
  - Follow-ups → `[docs-lifecycle/result.md follow-up-3]`, `follow-up-4` and `[docs-lifecycle/plan.md D14]`, open above; the others in `docs/specs/workflow.md`.
  - Incidents → none at the product level; the plan check and review incidents of the change are in `docs/specs/workflow.md` *Incidents*.
  - Record → this record, in this file, `docs/specs/workflow.md`, `docs/specs/marketplace.md` and `docs/features/docs-lifecycle.md`; no audit file.
- 2026-11-18 · p7-delivery-gate · afda097 · afda097 · p7-delivery-gate · #21
  - PR #21 (glab-services/skills), not merged at this record; this file is its only spec: P7 waits for the user's `## Delivered` confirmation, P6 is done also with nothing to commit, the Delivered row, the roadmap page and its check carrying the Delivered line; `glab` 0.16.1. The plan folder was not kept in git.
  - [p7-delivery-gate/plan.md Decisions] Decisions → D1–D3, D6, D7 and D9's A3 (with A8 in D7), above under *Decisions that still bind*; D4, D5, D8, D9's other items and D10 as `spent`; `[docs-lifecycle/plan.md D9]` marked superseded, its text kept.
  - [p7-delivery-gate/plan.md Findings] Findings → `F2` and `F3`, the Codex review on PR #19, closed above; `F1`, `F4`–`F9` were that change's readings, their conclusions in the decisions.
  - Not verified → the live P6–P7 flow and the Codex text behind `F2` and `F3`, above under *Known limits*.
  - Follow-ups → `[p7-delivery-gate/review.r1.md 1]`–`3`, open above; `[docs-lifecycle/result.md follow-up-4]`'s line number updated. `check.r1.md` A1–A8 were resolved in the plan (`D9`), and `result.md`'s PC9 gap by `D10`; no `follow-ups.md`.
  - Security → no secrets; no script or hook contract changed (`[p7-delivery-gate/review.r1.md]` *AGENTS.md rules*).
  - Incidents → none recorded by this change.
  - Record → this record, in this file only; `docs/specs/workflow.md`, `docs/specs/marketplace.md` and the feature pages untouched (`[p7-delivery-gate/plan.md Record]`); no audit file.
- 2026-11-18 · lifecycle-hardening · bf9c73f · bf9c73f · lifecycle-hardening · #22
  - PR #22 (glab-services/skills), not merged at this record; recorded in `docs/specs/workflow.md`, its primary area; here: P6's "nothing to commit" test, `## Delivered` after the last `## Approval`, "appended to", the brief's precondition and refusal, "the last `## Delivered` line" in `glab:product-plan` and `glab:product-analyzer`; `glab` 0.16.2. The plan folder was not kept in git.
  - [lifecycle-hardening/plan.md Decisions] Decisions → `D4`'s `p7-delivery-gate` half, `D10`, `D14`, `D20`, `D21` and `D24` item 3 above under *Decisions that still bind*; `[p7-delivery-gate/plan.md D2]` marked superseded in its test, `D3` and `D7`'s A8 amended, their text kept; the others in `docs/specs/workflow.md` and `docs/specs/marketplace.md`.
  - Not verified → the live product flow, the P6 allow-list proven only in throwaway repos, the non-`origin` remote and the roadmap's `<first>`/`<last>`, above under *Known limits*.
  - Follow-ups → closed: `[p7-delivery-gate/review.r1.md 1]`–`3`, moved to *Closed follow-ups*, and `[lifecycle-hardening/follow-ups.md FU1]`; open: `[lifecycle-hardening/review.r3.md 6]`; the others in `docs/specs/workflow.md`.
  - Incidents → none at the product level; the change's are in `docs/specs/workflow.md` and `docs/specs/marketplace.md` *Incidents*.
  - Record → this record, in this file, `docs/specs/workflow.md`, `docs/specs/marketplace.md` and `docs/features/docs-lifecycle.md`; no audit file.
- 2026-11-18 · script-hardening · 64b4e57 · 64b4e57 · script-hardening · #23
  - PR #23 (glab-services/skills), not merged at this record; the change's one commit, `fix(skills): remove a claim the run failed to write, and harden the gates (glab 0.16.3)`. Here: `create_line`'s codes 0–4 and `create_failed`, the exit 2 after a failed write, the pre-open guard, `command exec`, the store-filesystem pointer in `README.md`, `host.example.md` and `glab:product-manager`, T52–T56 (`PASS 56/56`), through *How it works now*; the version and `tests/gates.sh` in `docs/specs/marketplace.md`. The plan folder was not kept in git.
  - [script-hardening/plan.md Decisions] Decisions → `D1`, `D2`, `D7`–`D9`, `D11`, `D16`, `D17`, `D19`, `D21`–`D23` above under *Decisions that still bind*, `[flow-gate-hardening/plan.md filesystems]` amended by `D2`; `D20` and `D23` under *Incidents*; `D3`–`D5`, `D10`, `D12`, `D13` and `D6` in `docs/specs/marketplace.md`; `D14`, `D15` and `D18` were plan text (post-conditions' before values, T53's report, a reworded example), spent.
  - [script-hardening/plan.md Findings] Findings → F1–F10 were that change's readings and baselines; F3 (the `capped` injection), F5 (the guard, the symlink cases, the hang) and F6 (the contract) in *How it works now* and the follow-ups.
  - Not verified → real ENOSPC or EDQUOT, the code 1 after a failed open in a real race, the re-create under the lock, both windows, macOS, above under *Known limits*; the claim-and-lock line of `[flow-product-level/result.md claim-window]` and `[flow-gate-hardening/plan.md Tests]` amended; a real bash older than 4.4 in `docs/specs/marketplace.md`.
  - Follow-ups → closed: `[flow-gate-hardening/follow-ups.md FG-1]`, `FG-2`, moved to *Closed follow-ups* (the flow-gate-hardening record's line above still lists `FG-1` and `FG-2` as open, as of its record); open: `[script-hardening/plan.md FU-SH1]`, `FU-SH3`, `FU-SH4`; `FU-SH2` in `docs/specs/marketplace.md`. No `follow-ups.md` in the folder.
  - Reviews → `check.r1.md` (F-a–F-h) → `D7`–`D14`; `check.r2.md` (N1–N5) → `D15`–`D19`, `D20`; `review.r1.md` (one medium, three lows, one advisory) → `D21`, the advisory FU-SH1; `review.r2.md` (one medium) → `D23`.
  - Security → no secrets; `AGENTS.md` and `docs/one-fact.md` unchanged (`plan.md` PC7); the `plan-gate.sh` contract kept (`plan.md` F6).
  - Incidents → the posix-mode `exec`, T56 on bash 4.4–5.2, the planner's stopped background run, and the two caps, above under *Incidents*.
  - Record → this record, in this file and `docs/specs/marketplace.md`; no feature page, no audit file.
