# fix-external-agent-claims: review, round 1/3

Two reviewers looked at `git diff HEAD` (without `plan/`) on 2026-10-19. Conformance had already passed: the
build matches the plan byte for byte. Both reviewers returned BLOCK, 2 issues and 4 issues. The manager relays
their findings here.

## Correctness and security (BLOCK: 2)

- **C1** `external-agent.sh:711-715` `opencode_raw`. It decodes each line on its own, but the script's
  readers (`opencode_text`, `opencode_render`, `opencode_session`) decode the file as a stream. So a key
  that is JSON-escaped is kept unredacted in two cases: an event split over two lines
  (`{"type":"text","part":{"text":` then `"<escaped key>"}}`), and a line holding two values
  (`{"type":"x"} {…}`; `fromjson` fails with "Unexpected extra JSON values" and the catch keeps the line).
  The reviewer reproduced it with the real functions, and `jq -r '.. | strings'` printed the key twice. The
  comment at :703-704, "A line jq cannot decode is no event", is false for those readers.
  - Fix, fail closed. A JSON string cannot span lines, so redact any line that does not decode as exactly
    one value and contains a backslash: `try (fromjson | if holds_key then "k" else "-" end) catch
    (if test("\\\\") then "k" else "-" end)`. This also covers lines past jq's depth limit.
  - Tests: add stub cases to E86 for the split event and the two-values line. Add a whole-file check
    `jq -r '.. | strings' transcript.jsonl`, with no key found.
  - Fix the comment.
- **C2** `tests/external-agent.test.sh:1444-1461` E86. Mutant `[.. | strings]` (object keys dropped)
  passes 86/86, and so does mutant `v[FNR] != "k"` (a missing verdict kept).
  - Fix: add a stub event whose object key is the escaped key, asserting `{"type":"redacted"}`.
  - List fail-closed-on-jq-failure as uncovered in the coverage list, with the reason: jq cannot be failed
    from the stub alone, since the script uses jq everywhere.
- Advisory, deferred to follow-ups: jq 1.6's `contains` may stop at a NUL; `$ENV` does not exist in jq 1.5
  (that fails safe: everything is redacted); README names no jq version. UNVERIFIED, since no older jq is
  installed here.

## Docs, tests and rules (BLOCK: 4)

- **T1** `external-agent.sh:696`. The comment "K for a K" means nothing: the `K` escape was decoded
  in the plan text (`plan.md:683`). Fix: `JSON-escaped - K for a K, or \" for a quote in the key -`.
- **T2** `README.md:76-77`. "it is never printed and is redacted from what the agent returns" overstates
  it. Fix: add "where it appears written out or JSON-escaped; a key the model writes in any other form,
  such as base64, is not recognised" (the *One fact* entry for the guarantees each backend has).
- **T3** `tests/external-agent.test.sh:789`. E42's title still says "at most 16 MiB … reach the disk".
  Fix: "the first 16 MiB of a turn's stdout and of its stderr are kept, in whole lines; a turn that writes
  more is a backend error (7)". The assertion stays as it is.
- **T4** `external-agent.sh:1494`. The `header()` comment says exits 0, 6, 7 and 12. Fix: "on exits 0, 6,
  7, 8 and 12; the change report on 0, 6, 7 and 12, since a developer is never 8".
- Advisory, deferred: qualify "less than twice as long" for the jq-failure path; the skill's range wording;
  no case for lines kept byte for byte; AGENTS.md *One fact* should name E85 for the sandbox check, and
  "never a nested repository" for the copy summary.
