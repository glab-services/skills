# feature-codex-agent: review, round 2/3

The same three reviewers looked at `git diff HEAD`, leaving out `plan/`, on
2026-10-18. Every round-1 finding was confirmed fixed, with reproductions and
mutation runs. The manager relays the new findings here. Both blockers sit in
code written to fix round 1: an E70 test that discriminates too little, and a
wording left behind by T4.

## Verdicts

- Security: **SHIP**. Advisory A is the socket wording; it is approved as
  revision 5.
- Correctness: **BLOCK: 1** (R2-1).
- Tests, docs and rules: **BLOCK: 2** (R2-1 and R2-2).

## Blocking

- **R2-1** `tests/external-agent.test.sh:1066-1082`, E70. Both reviewers
  showed it by mutation: E70 passes with either half of the C1 fix removed.
  Without the pre-turn sweep at `external-agent.sh:1333` it gives PASS 70/70,
  and without the `$$` cap-flag names it gives PASS 70/70. It fails only when
  both are gone.
  - Fix: split E70 in two.
    - (a) A pre-turn sweep case. The stub's `slow` scenario records whether the
      stale stand-in from `$CXH/pids` is alive when the new turn starts (or the
      test checks about 1 s into the running turn), and the case asserts it
      was dead.
    - (b) A cap-flag case. A late-flood stand-in started with
      `env -u GLAB_EXTERNAL_AGENT`, so no sweep reaches it, with its PID
      appended to `$CXH/pids` for cleanup. The case asserts that the new turn
      still returns 0.
  - Or, if (b) cannot be made deterministic, name the `$$` half in the
    coverage list as uncovered, with the reason.
- **R2-2** `README.md:47-48` and the AGENTS.md clause "Codex has none and
  checks an id's form only". The script and the skill refuse `default` (exit
  5), but these two places still say "form only".
  - Fix: add "and refuses `default`; leave the model out for Codex's default"
    to both, as one wording.

## Advisory, taken

- **R2-a** test:1071 cites "(C1 of the … review, round 1)". Use the tag form
  `[feature-codex-agent/review-r1.md C1]`.
- **R2-b** The script header's Codex section lists when `sweep_agent` runs.
  Add "before every `send`" (`:1333`).
- **R2-c** No case covers cleanup's `host_turn` sweep (`:201`); a mutation
  gives PASS 70/70. Name it in the coverage list as uncovered, with the
  reason (the signal window is too narrow to hit reliably).

## Advisory, deferred to follow-ups

- **R2-d** The pre-turn sweep at `:1333` runs before `host_turn` is set, so a
  signal during it skips cleanup's sweep. Low impact: the next `send` or
  `stop` sweeps.
- **R2-e** `debug models` runs with an empty `GLAB_EXTERNAL_AGENT`. Harmless;
  pass the marker explicitly, or leave the variable out.
- Still deferred from round 1: C-C, C-E/S-5, S-6, S-7.

## Assignment

- **Script developer:** R2-1, R2-a, R2-b, R2-c, plus revision 5's script
  items (the socket wording in the header).
- **Docs developer:** R2-2, plus revision 5's docs items (the socket wording
  in README and skill).
- **Review round 3 of 3 then decides:** SHIP, SHIP WITH SCOPE CUT, or DO NOT
  PUBLISH.
