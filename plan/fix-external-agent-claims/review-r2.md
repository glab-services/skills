# fix-external-agent-claims: review, round 2/3

This round reviewed the turn-4 fixes, on 2026-10-19.

- **Correctness and security: SHIP.**
  - The reviewer reran its round-1 reproductions against the new code. The split event and the
    two-values line are now redacted. Decoding the whole file as a stream, and in Python, finds 0 keys.
  - Mutants: M2 (object keys dropped) gives `NOT OK E86`, and so does M6 (the catch reverted). M3
    survives, as recorded.
  - Malformed UTF-8 cannot be used to get past the backslash test.
  - Advisory: a non-JSON stdout line holding a backslash is now redacted (UNVERIFIED whether OpenCode
    prints such lines). The E86 stream check is vacuous for `leak-split`; add a guard that the line count
    is right, or that the `split ` marker is present. jq 1.5 and 1.6 remain UNVERIFIED.
- **Docs, tests and rules: BLOCK 3.** All four round-1 fixes are confirmed. The new findings are all in
  text written to close C1, and the reviewer warns that this area is not converging.
  - **R2-1:** the size-bound claims are now false. The catch turns a line of any length that holds a
    backslash and is not one JSON value into the 20-byte event, so 1000 lines of `\` (2000 B) became
    20000 B. The false claims are at `external-agent.sh:232-233` (1.67), `:104-106` ("less than twice
    as long") and `SKILL.md:358-359`. The user chose the preferred fix: state the real bound (about 10x
    the cap) in all three places, with no new logic, and fold F6 into it.
  - **R2-2:** the comment at `external-agent.sh:704-707` is wrong about the depth limit. Fix: "…or one
    past jq's depth limit, which no reader decodes - fails fromjson here."
  - **R2-3:** coverage. "jq cannot be failed from the stub alone" is false. A selective `jq` wrapper
    first on `PATH` fails only the `holds_key` call, and with it mutant M3 leaks the escaped key. Fix:
    add that wrapper case to E86, asserting every line is `{"type":"redacted"}` and no key is present.
    Then drop the acceptance and F4.

The user approved this as the last fix round (turn 5): Claude plans the exact edits, and a new Codex
developer applies them. Review round 3 must then end in SHIP, SHIP WITH SCOPE CUT or DO NOT PUBLISH.
