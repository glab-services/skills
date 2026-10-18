# fix-external-agent-claims: findings

Input: `claims.md` in this folder: 13 claims, each verified by a read-only
`glab:analyzer` against `363c38d`. Line numbers below are at `363c38d`
(S = `plugins/glab/skills/external-agents/SKILL.md`, E =
`plugins/glab/scripts/external-agent.sh`, T = `tests/external-agent.test.sh`,
R = `README.md`).

## Scope

Ten claims are documentation that says more, or other, than the code does
(1, 2, 4, 5, 6, 7, 8, 9, 11, 12). Three are code gaps (3, 10, 13). Every
fact touched is stated in more than one file; AGENTS.md *One fact* ties them
together. These are the files each fact lives in:

| claim | fact | S | R | E (comments) | other |
|---|---|---|---|---|---|
| 1 | what a CLI launcher needs in the sandbox | 42-45 | 40 | — | — |
| 2 | which files the change report counts as ignored | 92-95, 361-363 | 99-102 | 136-139 | — |
| 3 | what of an included config file the report sees | 92-93, 183-184, 362-363 | 99-100 | 136-139, 431-433 (`dev_git`) | — |
| 4 | what stderr holds | 160 | — | 46-48 | — |
| 5 | when stdout is empty | 162-165 | — | 22 | — |
| 6 | what each transcript keeps | 218-223 | — | — | — |
| 7 | what a branch name resolves to in OpenCode's copy | 229-233 | — | 66-69 | — |
| 8 | what the verdict check counts | 240-245 | — | — | — |
| 9 | nested repositories in OpenCode's copy | 300-303 | 64-66 | 66-69 | — |
| 10 | key redaction in `transcript.jsonl` | 218-221, 322-325 | 74 (still true) | 98-100, 323-324, 650-656 | T E14 |
| 11 | the 16 MiB cap and redaction | 326-330 | — | 94-97, 164-166, 200-204 | — |
| 12 | how long the change report can take | 359-360 | — | 133-135 | — |
| 13 | when the Codex sandbox header is checked | 384-391 | — | 125-128, 1456-1457 | T E54, E60, E64 |

`glab:manager` Rule 6, `plugins/glab/commands/*.md` and the agents state
none of these specifics (searched for `redact`, `transcript`, `reach the
disk`, `ignored file`, `includes`, `16 MiB`, `stderr`, `300 s`: no hit on
these facts).

## Proven behavior (run, output read)

- **Claim 3, and a wider gap.** In a throwaway repository with
  `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1`, `.git/config`
  including an absolute `inc` and, under `includeIf "onbranch:other"`, an
  absolute `inc2`; the sha256 of `git config --includes --list -z` compared
  after each change:

      comment-only change: list unchanged
      onbranch:other (false) include change: list unchanged
      value change: list changed
      # after `git checkout other`:
      $ git config --includes --get core.fsmonitor
      /bin/true

  So `dev_git` sees a changed *value* in an active include and nothing else
  of included files. It does not see a write to a file the config includes
  only under a condition that does not hold yet; that file then takes effect
  on the user's next checkout of that branch. Not in `claims.md`; recorded as
  a follow-up (plan *Follow-ups* F1).
- **Claim 2, exactly.** Same throwaway setup, a file ignored only by
  `$XDG_CONFIG_HOME/git/ignore` and one only by a global `core.excludesFile`,
  `git ls-files -o --exclude-standard`:

      with global config:
      xdgonly
      hostgit-like (global /dev/null):
      globonly

  Under `hostgit` (E:308-311), git still applies its default
  `$XDG_CONFIG_HOME/git/ignore` but not a `core.excludesFile` from the global
  or system config. That a `core.excludesFile` in the repository's own config
  is still read is inferred: `hostgit` does not disable the local config.
- **Claim 10, the fix's behaviour.** The planned `opencode_raw` (plan step
  S4.1), run as a standalone script with `mawk 1.3.4` and `jq-1.8.1` on a
  sample stream: an event with the key `\u`-escaped became
  `{"type":"redacted"}`; an object key holding the escaped key, the same; a
  literally redacted event, a non-JSON line with bytes `\xff\xfe` and a NUL,
  an empty line, a line holding DEL, and a last line with no newline were
  each written unchanged (a newline added to the last). A key containing
  `"` and `\` (`KEY-q"uo\te-0123`), JSON-encoded by `jq --arg`, became
  `{"type":"redacted"}`. With a `jq` that exits 1, every line became
  `{"type":"redacted"}`. A 16777198-byte stream of `{"type":"noise"}` lines
  came out `cmp`-identical in 2.5 s. `shellcheck` on the function: rc=0.
- **Why not re-encode.** `jq -R -r '. as $l | try ($l|fromjson|tojson) catch $l'`
  wrote a raw DEL inside a JSON string as `\u007f` (one byte to six), and
  replaced each invalid UTF-8 byte of a non-JSON line with U+FFFD (one byte
  to three). Re-encoding every line would break the OUT_BYTES bound on the
  disk.

## Dry run of the plan (planner, 2026-10-18)

`plan.md`'s Old and New blocks, applied by a script, in order, each required
to occur exactly once, to three throwaway copies of `git archive 363c38d`
(turn 1; turns 1-2; turns 1-3) under `$TMPDIR`, removed afterwards:

    23 edits / 31 edits / 39 edits          # every Old block found exactly once
    turns 1-3: bash -n && test -x            # five rc=0 lines
    turns 1-3: shellcheck (the five files)   # rc=0, no findings; turns 1 and 2 alone: rc=0
    turn 1:    tests/external-agent.test.sh  # PASS 84/84
    turns 1-2: tests/external-agent.test.sh  # PASS 85/85
    turns 1-3: tests/external-agent.test.sh  # 86 ok lines, ok E85, ok E86, PASS 86/86 (76 s)
    turns 1-2 tests on 363c38d's plugin      # NOT OK E85, FAIL 1/85
    turns 1-3 tests on 363c38d's plugin      # NOT OK E85, NOT OK E86, FAIL 2/86

Every search in `plan.md` *Verify* was run on each state and on `363c38d`,
and printed the count the plan gives for each. No test process was left
running afterwards (`pgrep` matched only the shell that ran it). Not run:
the plugin gates.

## Inferred behavior (read from the code, not run)

- **Claim 13.** `codex_verify` (E:849-857) returns 0 when `codex_block` is
  empty, and otherwise either returns 0 or prints the header and `end:` and
  dies 12. Moving its call (E:1457) above the cap loop (E:1443-1448) changes
  only turns whose header names a wrong sandbox or approval: those become 12
  where they were 6 or 7. A turn with the right header goes on to the same
  checks as today; a turn with no complete header block (timed out before
  Codex printed it) is passed by `codex_verify` and is still 6 or 7. The
  header block is in the first 20 lines of stderr (`CODEX_BLOCK_AWK`), and
  the cap cuts the end of the stream at a line boundary, so a capped stderr
  keeps it. `header` uses `turn_model`, set in `run_turn` before
  `finish_turn` runs.
- **Claim 5.** Every `die` with 6, 7, 8 or 12 after a turn is preceded by
  `header` and `echo "end: …"` (E:856, 1447, 1454, 1460-1461, 1464, 1470,
  1475, 1507). No `die` 2-5, 9, 10 or 11 prints to stdout, and none happens
  after `header` has printed.
- **Claim 12.** `dev_snap` runs `timeout --kill-after=5 "$lim"` with `lim` =
  min(--timeout, 300) (E:473-483), once before and once after the turn
  (E:1376, 1429); `dev_refuse`'s `find` runs under `timeout 300` (E:511) at
  every developer turn (E:1375) and once more at start (E:1578).
- **Claim 11.** `redact_stream` counts input bytes against the cap and
  replaces each key occurrence (at least 8 characters, E:956) with the 10 of
  `<redacted>`: at most 1.25 times as long. After S4.1, a line of
  `transcript.jsonl` that holds the key once decoded is at least 12 bytes
  (the key's 8 characters, at least one of them escaped, two quotes, a
  newline) and becomes the 20 of `{"type":"redacted"}` and a newline: under
  1.67 times. So "less than twice" holds for both.

## Call-site audit

- `opencode_raw` — one caller, `run_turn` (E:1290), as `"${backend}_raw"
  >>"$adir/$("${backend}_raw_name")"`, which relies on it printing the
  turn's raw transcript on stdout and nothing else. It runs after the turn,
  with `$run/turn.out` complete and `$secret` set (`read_secret`, E:1600 /
  1658). Nothing in the script reads `transcript.jsonl` back; the renderer,
  `opencode_text`, `opencode_error` and `opencode_session` read
  `$run/turn.out`. Only E14 (T:554) and E42 (T:777-783) read the file: E14
  checks that the literal key is absent, E42 its size and last byte, on
  lines with no key, which S4.1 writes byte for byte.
- `finish_turn` — two callers, `cmd_start` (E:1624) and `cmd_send` (E:1669),
  both as their last statement; it always exits. The reordering changes no
  output format.
- `codex_verify` — one caller, `finish_turn`, through `"${backend}_verify"`,
  only for `isolation = host`; OpenCode has none.

## State and lifecycle

- `transcript.jsonl` is append-only per turn. Lines already written are not
  touched; a new turn may now contain `{"type":"redacted"}` lines, which are
  JSON objects, so a reader using `.type` keeps working.
- `$run/turn.out` keeps the stream redacted on literal bytes only. `run/` is
  removed by `cleanup` when the call ends, recreated by the next `send`
  (E:1665) and removed by `stop`; after a SIGKILL it stays until one of
  those. The plan's comment says so; no code changes there.
- `opencode_raw` opens nothing it does not close: `awk` reads the process
  substitution and `turn.out` and ends; `jq` ends at end of input.

## Candidate boundaries, and the ones rejected

- **Claim 10.** Chosen: decode in `jq`, mark the lines that hold the key,
  and have `awk` replace only those, every other line byte for byte.
  Rejected: (a) redacting escaped forms literally — the escaped spellings of
  a key are unbounded (any character can be `\u`-escaped, in either case of
  hex); (b) writing the jsonl from decoded, redacted, re-encoded events — it
  grows lines (DEL 6x, invalid UTF-8 3x, run above) and rewrites every
  event; (c) decoding inside `redact_stream` — it also carries stderr,
  Codex's streams and the cap, none of which is JSON.
- **Claim 13.** Chosen: move the `verify` call to the top of `finish_turn`.
  Rejected: a second `verify` call inside the cap and timeout branches — two
  places to keep in step for one rule.
- **Claim 3.** Chosen: document. Digesting the raw bytes of each active
  included file would add only comment and layout changes, which change
  nothing git does, and would still miss the conditional includes above,
  which do. A correct fix enumerates every `include.path` and
  `includeIf.*.path`, conditions ignored, resolves each against the file
  that names it, and digests it: a design with its own cases, left to F1.
