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
`0.14.0`), the record of `flow-product-level`; where this file and an
owning file disagree, the owning file is right.

## How it works now

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
  and `glab:product-project-plan-report`, which the project manager runs at
  Stage 1c and whose description says `Project level` (its agreed name kept:
  the product chain sets the contract). The agents, flat files under
  `plugins/glab/agents/` because `plugin details` lists no agent in a
  subfolder and the model and skills gates glob `agents/*.md` (`E3`):
  `glab:product-planner` (`model: opus`; `skills:` `glab:product-plan`,
  `glab:security`; no `Skill` tool) and `glab:product-analyzer` (`model:
  opus`; read-only, `tools: Read, Grep, Glob, Bash`; `skills:`
  `glab:security`, `glab:audit`), which ends a product plan check `SOUND`
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
  to the store. Reports, copies and verdicts are written only by
  `plan-gate.sh`. The product session has the store among its directories —
  `claude --add-dir <store>` or `/add-dir` — or keeps it inside its repo, so
  its writes are not each prompted (R2-4; a subagent's Write there is LP6).
  A Notion view is optional and later, never the gate
  (`[flow-product-level/plan.md FU-P3]`).
- **`plan-gate.sh`: the digest, the report, the verdict and the check**
  (since `ce1a933`; `plugins/glab/scripts/plan-gate.sh`, its header comment
  the owner; `tests/plan-gate.test.sh` T1–T42). One script, so both levels
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
  exclusive create done by bash itself, `(set -C && : >claim)`, an
  `O_EXCL` open, the file `.plan-gate.claim.<report|verdict>.r<n>` in
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
  (finding 1). The trap removes the copy, the temp file and the claim on
  every signal it sees.
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
  script, `PASS 42/42`: T1–T29 as planned, T30–T37 from review round 1,
  T38–T42 from round 2), `tests/manager-bootstrap.test.sh` (the hook,
  `PASS 13/13`) and `tests/product-loop.test.sh` (the walkthrough, L1–L17,
  `PASS 17/17`), one per contract. The walkthrough plays a made-up product
  with two projects through the loop under `$TMPDIR` from fixtures — what
  each agent would write — and runs the real scripts; it calls no model.
  With `PRODUCT_LOOP_SHOW=1` it prints the trace of each scene on stderr;
  the manager sent that trace (434 lines) to the user on 2026-11-13 and
  removed it, as X2 says (`result.md` *Final check record*). The gate lines
  are in `docs/specs/marketplace.md`.

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

## Known limits and not verified

- [flow-product-level/evidence.md LP1] UNVERIFIED until the user runs it after install: the hook picks the product text in a repo whose `AGENTS.md` says `glab-level: product`, also when the session starts in a subfolder (`F4`), and the session then loads `glab:session-rules` as well as its manager (`F24`). `tests/manager-bootstrap.test.sh` B2 and B13 show the script's output only.
- [flow-product-level/evidence.md LP2] UNVERIFIED: a product session keeps to its manager's list, also with a crowded skill listing that drops descriptions (`F14`). The main session's boundary is text only (`E11`); the hard one is `[flow-product-level/plan.md FU-P2]`.
- [flow-product-level/evidence.md LP3] UNVERIFIED live: `${CLAUDE_PLUGIN_ROOT}` is substituted in the new skills' text, which runs `plan-gate.sh` by that path — documented (`F7`), as `[flow-commands-to-skills/plan.md U6]` is for `glab:bootstrap`.
- [flow-product-level/evidence.md LP4] UNVERIFIED: starting and reaching project sessions per host — that a session's Bash tool can run `claude --bg`; that `SendMessage` and `notify_when_idle` reach a background session it started; that the start prompt's git sentence keeps a background session from committing and pushing (F19); that `claude --resume <full session id> --bg` continues a stopped one; that the desktop tool, which "cannot deliver into a session an orchestrator dispatched", reaches a session it started. Read from `claude --help` on 2.1.310 and the tool texts (`E20`), never run. The user's own start always works.
- [flow-product-level/evidence.md LP5] UNVERIFIED live: the product agents preload their `skills:` — documented (`F11`); the same claim as `[flow-commands-to-skills/plan.md U4]`.
- [flow-product-level/evidence.md LP6] UNVERIFIED: the product session, its store added with `--add-dir <store>` or `/add-dir`, writes a brief through `glab:product-planner` and a verdict through `plan-gate.sh` without a prompt per write (R2-4); and whether a subagent's Write outside the session's directories is prompted rather than refused. LP1–LP6 are `[flow-product-level/plan.md FU-P4]`, open, and `README.md` *Try the product loop* lists them.
- [flow-product-level/result.md bash-3.2] UNVERIFIED: that bash 3.2 (macOS) opens a noclobber `>` with `O_EXCL` as bash 5.3.9 does on the build host (`strace` there showed `O_WRONLY|O_CREAT|O_EXCL`), for the claims and `claimed_tmp`, and that its trap runs on TERM and INT at the same points. No macOS host was available (fix rounds 1 part 2 and 2).
- [flow-product-level/result.md o-excl-network] UNVERIFIED: that `O_EXCL` is exclusive for a store on a network filesystem; only a local filesystem was tested. With `[flow-product-level/follow-ups.md FR1-1]` (hard links), what filesystems a store may live on is named nowhere.
- [flow-product-level/review-2.md finding-2] Known limit, proven: a TERM that lands while `ln` itself runs still removes `plan.r<n>/` of a report that is linked, because bash runs the trap as soon as `ln` exits — with an `ln` stub that links then waits 2 s, `report run rc=143` and the folder `brief.md report.r1.md`. Review round 2's fix narrowed the window from `rm`'s run time to `ln`'s; it is open as `[flow-product-level/follow-ups.md FR2-1]` (*Open follow-ups*).
- [flow-product-level/result.md claim-window] UNVERIFIED: that a signal between the claim's subshell and `CLAIM=$1` leaves the claim — the review's reasoning, stated in the script comment; no stub can stop bash between two builtins. Not covered by any case either: the re-tests under the claim (they need a run to lose the CPU until another has published and released), and the exit-2 branches of `publish_file`, `claim`, `claimed_tmp`, `mkdir` and `chmod -R`, which need a failing filesystem.
- [flow-product-level/result.md final-check] The final check gave `DIVERGES: 1`, a missing record, which the manager supplied as `result.md` *Final check record*: X3 prints `253 ok` and 8 FAIL lines, not `261 ok`, every failing post checking text a review decision superseded — A1 one byte-compare, A2 two byte-compares and its partner run (`FAIL 13/42` against the superseded script), P4 (B7), P7 (B4), J2 (A4, B9), R5 two (B5). The master's *Final check* item 3 holds with these eight recorded exceptions; the plan files were not edited.
- [flow-product-level/result.md X4] X4 as `plan.md` writes it prints `xargs: command: No such file or directory`, since `command` is a shell builtin `xargs` cannot run, and `git diff --name-only main` lists no untracked new file; the developer ran an equivalent over the 49 changed and new files, which printed only `host.example.md`'s author's temp-dir lines, as on `main`.
- [flow-product-level/plan.md Tests] The Markdown has no runtime: P1–P9, J1–J12 and R1–R6 are shown by their posts and the gates only, the text there, not a live session following it — UNVERIFIED, as for every prose rule. The scripts are covered as listed in `plan.md` *Tests* and `result.md`'s fix rounds; LP1–LP6 by no case, accepted because each needs a live, logged-in session.

## Open follow-ups

- [flow-product-level/follow-ups.md FR1-1] Hard links on the shared store: since review round 1 (A2) `plan-gate.sh` publishes each report and verdict with `ln`, so a store on a filesystem without hard links (some network or FAT-family mounts) fails every write with exit 2, `plan-gate.sh: writing <path> failed`, where `mv` worked before. UNVERIFIED on any such mount; nothing in this repo names which filesystems a store may live on — open (out of scope: the decision chose `ln`).
- [flow-product-level/follow-ups.md FR1-2] A claim left by a killed run: a run killed by SIGKILL or a host crash leaves `.plan-gate.claim.<report|verdict>.r<n>` in `briefs/<project>/`, and every later run for that number is refused until someone removes it by hand (proven with a planted claim, `rc=1`). Review round 2 (finding 1) made the refusal name the claim file and say to remove it by hand when no run is writing (T38) — still open: nothing tells a stale claim from a live one, so a person decides.
- [flow-product-level/follow-ups.md FR2-1] A signal while `ln` runs: a TERM inside `ln`'s own lifetime still removes `plan.r<n>/` of a report that is linked (*Known limits*) — open; closing it needs the signals held off across the `ln`, for example `trap '' TERM HUP INT` around it, which the review did not ask for.
- [flow-product-level/follow-ups.md FR2-2] A temporary file left by SIGKILL: `.plan-gate.tmp.<report|verdict>.r<n>` stays beside its claim, and the claim's refusal names only the claim; the next run that takes the claim removes it (T38) — open (the finding asked for the trap to reach the file, which it now does on every signal it sees).
- [flow-product-level/plan.md FU-P2] A hard boundary for the main session: `Skill(...)` permission rules per level, or a hook that refuses another level's skill; feasible by the documented `Skill(name)` syntax (`F15`), needs a live test first — open.
- [flow-product-level/plan.md FU-P3] The Notion view of the store ("plain folder but I'm planing to connect here notion page"), read-only, never the gate; it changes `glab:product-manager` *The shared store* and `plan-gate.sh` only — open.
- [flow-product-level/plan.md FU-P4] The live tests LP1–LP6, run by the user after install (*Known limits*) — open.
- [flow-product-level/plan.md FU-P5] A hard hold on `by user`: today any session can pass it (R12); a check that the words came from the user needs a mechanism this plan does not have, and whether Claude Code offers one is UNVERIFIED — open.
- [manager-flow-notes.md later-1] **The user's, parked 2026-11-13** ("yes, and also main CLAUDE.md in claude code home folder must not mention about bootstrap skill, would be better to think about hook based force skill loader for main sessions, bot let's add note about this, to solve it later, good?", from `plan/manager-flow-notes.md` *Later: agent and session context cleanup*, untracked): `omitClaudeMd: true` on all nine `glab` agents, an agent frontmatter field of CLI 2.1.310 that runs a subagent without the user, project and local `CLAUDE.md` files (Claude Code's built-in Explore and Plan agents set it; the public docs not yet checked), and a gate that every agent file carries it. **Prerequisite:** the machine hazards, above all temp files in the host file's temp directory and never `/tmp`, reach agents today only through `~/.claude/CLAUDE.md`, and no `glab` agent reads the host file, so each agent first needs another way to learn them — it reads the host file at start, or the manager's dispatch carries the temp-directory line; without it an agent writing to `/tmp` can exhaust the shared tmpfs quota. Verifiable only live, by a real dispatch after install — open, agreed, not planned.
- [manager-flow-notes.md later-2] **The user's, parked 2026-11-13** (the same words, same source): no bootstrap text in `~/.claude/CLAUDE.md`; a hook-based skill loader makes the main session load its skills instead. Already true: the `SessionStart` hook injects the session-start text, and since 0.14.0 reads `glab-level` and names the level's manager and `glab:session-rules`. To prove first: whether a hook can make Claude invoke a skill or only add context (inferred: only add context, UNVERIFIED); that `additionalContext` is capped at 10,000 characters, so a hook injects a short, firm instruction and the level's skill list, never a whole skill (`glab:manager` was about 55 KB when noted, 40284 bytes at `ce1a933`); which event gives the strongest guarantee, and whether a `UserPromptSubmit` check can re-assert it after a compaction; what stays in `~/.claude/CLAUDE.md` afterwards — the machine hazards only, or nothing. Changing that home file is the user's step, never an agent's. Once it holds no session rules, `omitClaudeMd` (later-1) loses nothing but the hazards, which later-1 moves anyway — open, an idea, not planned.

## Closed follow-ups

- [flow-product-level/plan.md FU-P1] The rules every level's manager acts on, out of `glab:manager` — raised in planning because the product manager may not read `glab:manager` (I12) — closed in the same change (`ce1a933`, `glab` 0.14.0; J2): Rules 0, 0b, 0c, 0d, 1, 2, 3 and 5, *Round caps* and *The handoff line* live in `glab:session-rules`, which both managers load (`docs/specs/workflow.md`, *`glab:session-rules`*).

## Incidents

- **`mkdir` was not exclusive on the build host, so the claims moved to bash `set -C`** (`flow-product-level`, review fix round 1, `[flow-product-level/result.md]` *Fix round — review round 1* and *part 2*): review round 1's A2 decided to claim `plan.r<n>/` with `mkdir`. The host's `/usr/bin/mkdir` was uutils coreutils 0.10.0, and two `mkdir` calls racing on one name both returned 0 in 23 of 40 tries (14 of 30 on a second run; 11 of 40 measured again in part 2), against 0 of 30 for GNU `mkdir` and 0 of 40 for uutils `ln`. With the fixed script and a 1 s delay, two reports ended correctly in 4 of 10 runs; in one the loser's trap deleted the winner's `plan.r1/` after its report was linked. The developer added no two-reports test, which would have failed about 6 runs in 10, and stopped A2's report half as `PLAN WRONG`, beside advisory 3 (the `jq` tabs, the plan's own text). The manager decided every claim is an exclusive create by bash itself, `(set -C && : >claim)` — `strace` showed `O_WRONLY|O_CREAT|O_EXCL` — and rejected advisory 3 (`review-1.md` *After part 1 of the fix round stopped on two PLAN WRONGs*). After: 20 of 20 races correct, the primitive alone 0 of 40, T37 `PASS` ten runs in a row. Lesson: a coreutils command's atomicity is the host's, not POSIX's; a claim the script makes itself does not depend on it. Whether bash 3.2 and a network filesystem keep it is UNVERIFIED (*Known limits*). The host hazard is pointed at from `docs/specs/marketplace.md` *Incidents*.

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
