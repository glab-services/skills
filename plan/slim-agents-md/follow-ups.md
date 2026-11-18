# Follow-ups — slim-agents-md

- FU1 — `tests/gates.sh:33-35` (review round 2, low): only `claude` is made absolute before the `cd`; `jq` and `shellcheck` found through a relative `PATH` entry pass the preflight and then give FAIL lines instead of exit 2. Fix: resolve both the way `:32` resolves `claude`, or say in the `:24-26` comment that only `claude` gets it.
- FU2 — `${MS_AGENTS[@]+…}` and the rest of the script are untested on bash older than 4.4 (only 5.3.9 here).
- FU3 — `docs/specs/marketplace.md` still describes the old *Gates* block and the registry in AGENTS.md; the record of this slug updates it (D16).

## Incidents

- IN1 — 2026-11-18, fix round 1: the fix developer cleaned up with `rm -f "$TMPDIR"/fr1-*.out "$TMPDIR"/fr1-*.err` in the shared `/data/tmp/claude`, where other sessions keep `fr1-*` files. Whether another session's `.out`/`.err` file was removed is unknown. Briefs now say: remove temp files by exact path only.
