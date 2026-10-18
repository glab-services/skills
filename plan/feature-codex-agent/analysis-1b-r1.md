# feature-codex-agent: Stage 1b, round 1/2

Three analyzers checked `plan.md` against the code at `067b719` on 2026-10-18.
All three returned **NOT BUILDABLE**. The manager relays their reports here,
as they gave them. The user approved sending them back to the planner for
amendment ("Yes, amend and recheck").

## A1: script steps P1–P3: NOT BUILDABLE

1. P3, `first_prompt` (`external-agent.sh:463-478`). No step changes the
   "Where you are working" heredoc for host agents. Yet the One-fact table
   (plan:593) and E61 both need a host text that names the repo top and does
   not say "/work is a read-only copy". That text also carries the
   missing-AGENTS.md fallback (a One-fact item) and the network and web lines.
   The plan never gives it, so the developer would have to write payload text
   that nobody approved.
2. P1/P3 against D15 and O1, `:644`. P1 makes `:644` append only
   `$run/turn.out` (stdout) to the raw transcript, and P3 keeps that common
   tail. No step appends `$run/stderr.txt`, and cleanup deletes `run/`
   (`:139`). So `transcript.log` never holds the header block, and O1's
   "transcript.log shows `sandbox: read-only`, `approval: never` and a UUID
   session id" (plan:646) fails at Stage 4.
3. P3, `run_turn`, `:591-592`. P3 keeps the common preparation, but those
   lines are sandbox-only.
   - `sandbox_args` would call `"${backend}_mounts"`, which P1 defines only
     for sandbox backends. A Codex turn would then hit "`codex_mounts`: command
     not found", which breaks the one-line stderr contract.
   - `"${backend}_argv"` is passed `/opt/glab/backend`, so `codex_argv` would
     print `/opt/glab/backend exec …`. No step says to pass the real `$cli`
     for host backends.

Non-blocking:

- a. D5 against P3. Turn 1 checks only `ran`, so a block with a malformed
  session id still records `session ""` and exits 0. On turn 2 and later, a
  malformed model keeps the earlier `ran`, where D5 says exit 7.
- b. `codex_check`.
  - A `die 4` or `die 12` exits before `$root/check.$$` is removed, so E59's
    "nothing left" fails unless that directory is registered with cleanup, as
    `authd` is.
  - Cleanup (`:130-145`) also needs a global isolation flag, because `backend`
    is local.
  - The group kill has to run before `wait "$jpid" "$epid"` (`:640`). A
    grandchild still holding the pipes (the child of E60's sleep stub) would
    block it.
- c. D7 holds as written. The background subshell of a non-interactive bash
  is not a process-group leader, so util-linux setsid (2.41.3) does not fork
  and the group id equals `$!`, as long as the chain is still exec'd as at
  `:620`. `timeout` is uutils coreutils 0.10.0.
- d. D19 changes OpenCode's error order. With no `--model`, a missing TMPDIR,
  an unreadable brief or an unknown backend is now reported instead, and an
  unknown backend gets exit 3 rather than 2. The plan declares this, but it
  contradicts "P1 no behaviour change". No E-case pins `--model is required`.
  The header text "on every exit 2-11" (`:22`) is not in P3's list of lines
  to rewrite.
- e. Codex 0.163.0 help, run with a throwaway home.
  - `exec` takes `--color`, `-m`, `-c`, `--disable`, `--ignore-user-config`,
    `--ignore-rules` and `-` (prompt on stdin).
  - `exec resume [SESSION_ID] [PROMPT]` takes the same flags except `--color`
    and `-s`, so the argv is valid.
  - `login status`, `debug models` and `sandbox` have no
    `--ignore-user-config`, so `check` runs under the user's `config.toml`
    while turns do not.
  - `debug models` without `--bundled` refreshes the catalog over the
    network.
  - `browser_use_external` (plan:63) has no evidence in findings.md; O1 is
    its only check.
- f. *Before* is met for what was run. HEAD is `067b719`, and the five
  syntax checks, shellcheck, PASS 35/35 and PASS 49/49 all came back green.
  Every cited line resolves.

## A2: tests and post-conditions (P4, *After*): NOT BUILDABLE

1. P3/P4 E61. The host first-message text that E61 tests is never specified
   (the same gap as A1.1). `first_prompt` at `:459-496` has
   "/work is a read-only copy…" and "Read /work/AGENTS.md…" hard-coded, and no
   P3 bullet changes them.
2. P4 E56 (plan:403). "exactly PATH HOME TMPDIR CODEX_HOME LANG TERM" cannot
   hold for a bash stub: `env -i PATH=… LANG=… TERM=… bash -c env` printed
   `LANG PATH PWD SHLVL TERM _`. The plan has to say whether the stub drops
   `PWD`, `SHLVL` and `_`, or add them to the expected set.

Present in the harness: env pass-through `w VAR=val --` (test:215-219),
`--cli` taking any path, `t` counting (251-255, so 49+16 = 65), E36 staying
last (666), `leftovers()` (235-245), the polling loops of E25 and E37, and
`u()` (454).

Non-blocking. These post-conditions cannot tell a finished tree from a
half-finished one:

- `'"Use balance" is'` in AGENTS.md already counts 1 today, and `grep -c`
  cannot check which line it is on.
- `There is no external developer` and the empty `.codex` code grep are
  already true today, so they only guard against regressions. Only the first
  is marked as such.
- `'12 NOT READ-ONLY'` ≥1 is met by the header comment alone, without any
  `die 12`.
- PASS 65/65 and `^ok E[56][0-9]`=16 are totals: any 16 passing cases meet
  them.
- The function-count greps prove the functions exist, not what they do.
- E50 "first stdin line is the profile's first line": `default.md:9` is
  blank, so a turn with empty stdin also passes.

Coverage gaps the list does not name:

- the D8 mismatch check now also applies to OpenCode, and no case covers it
  there;
- the `codex:default` header and list fallback (nothing in `ran`) is never
  asserted, and E55 does not check the header;
- `run_host` exit 4 when the repo is no longer its top;
- `codex_check` exit 4 for a missing tool;
- D11, a symlinked `--cli` kept unresolved.

Also:

- The transcript heading at `run_turn:646` uses `$model`, which is empty for
  Codex's default.
- On a red run, the test's cleanup does not kill the pids in `$CXH/pids`, so
  a host `sleep 300` lingers. Killing by recorded PID is allowed.

## A3: docs and One-fact (P5–P10): NOT BUILDABLE

1. Missing-AGENTS.md fallback (One-fact row, plan:593): no step writes the
   host text (the same gap as A1.1).
2. Allowlist row (plan:587) says "README (P8) says Codex has none", and P9
   names `README.md` and E58 as stating it. No bullet in P8 writes such a
   sentence.
3. Text the plan leaves unchanged that will contradict U4/D6 (no model named
   means Codex's default) and D2:
   - manager `SKILL.md:150` Rule 6: "Only when the user asks, naming the
     model" (P6 rewrites `:149` and `:154`, not `:150`);
   - external-agents `SKILL.md:18`: "naming the model";
   - external-agents `SKILL.md:48`: "the brief goes to the model's provider
     with the copy" (listed in findings §9.4, dropped from P5);
   - `README.md:34-35`: "naming the model" (P8 leaves it "as now");
   - `README.md:9`: "a model you name (OpenCode Go)", a
     *what each plugin holds* file that neither §9.4 nor P8 names.

Non-blocking:

- Wrong citations: `review.md:76` is really `:8`; the probe paragraph is
  `README.md:59-67`, not `:58-61`; AGENTS.md *One fact* runs `:130-201`, not
  `:155-190`.
- The exit-codes row (plan:586) says the manager skill is unchanged, but P6
  adds "(12)" at manager `:123`. P6 is right; the row is wrong.
- P9 puts the Codex effort rule in two entries: the manual-model-rule entry
  (whose files include `develop.md` and `ship.md`, which will not state it)
  and a new effort entry. Keep it in one.
- P8 says only "Exit 12 is named". The *After* post-condition needs the
  literal `NOT READ-ONLY` in `README.md`.
- P8's Codex requirements leave out tools the script needs: `setpriv`,
  `setsid`, `timeout`, `flock` (D10), plus `git` and `jq`.
- P5's exit-4 row names only the Codex login. Two more exit-4 causes go
  unnamed: D18 (a repository path holding `"`, `\` or a control character)
  and `run_host`'s "no longer that repository's top".
- P5's "one line" data note and P8's paragraph give two wordings of the new
  data-note entry.
- AGENTS.md *Gates* `:34-35` ("runs its stub inside the script's real
  sandbox") will no longer be true of the Codex stub, but P9 leaves *Gates*
  unchanged.
- P9's offline-run wording points at a spec section that records a Codex run
  only at Stage 8, after O1 has already run at Stage 4.
- *Rules*: the version bump, prefixed names, no secrets and specs at Stage 8
  all hold. `ship.md`, `develop.md`, `bootstrap/SKILL.md` and `default.md`
  need no change.
