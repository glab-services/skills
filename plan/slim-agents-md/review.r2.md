Verdict: SHIP (one low finding, no critical or high, so no round 3 is needed)

1: fixed. I copied `tests/gates.sh:43-45` (mktemp, EXIT trap, and the new `trap 'exit 130' INT; trap 'exit 143' TERM; trap 'exit 129' HUP`) into a script with `sleep 2` and sent each signal. It printed `TERM rc=143 left=no`, `INT rc=130 left=no`, `HUP rc=129 left=no`. The comments at :9-10 and :40-41 now match that.
2: fixed. `docs/one-fact.md:164-166` is now one bullet starting "for the round copies only:" and holds all three files.
3: fixed. `AGENTS.md:30-31` now reads "are in the script: the values in its arrays, the reasons in its comments."
4: fixed. `TMPDIR=rel bash tests/gates.sh` printed `gates.sh: TMPDIR is not an absolute path - ...` and returned `rc=2`. A relative `CLAUDE_BIN=bin/claude` or a `PATH=bin:...` entry gives `command -v` output `bin/claude`, and :32 makes that `$PWD/bin/claude` before the `cd` at :35. :263 now uses `${MS_AGENTS[@]+"${MS_AGENTS[@]}"}`, and `MS_AGENTS=()` is at :84.

New in the fix range:
- tests/gates.sh:33-35 — low — Moving the `cd` to after the preflight means `jq` and `shellcheck` are found from the caller's directory but run from the repo root. If either is only reachable through a relative `PATH` entry, the preflight passes, the later calls at :186 and :272 can't find the tool, and you get FAIL lines instead of exit 2. This is from reading the code; I did not run it. Fix: store `jq=$(command -v jq)` and `shellcheck=...` and make them absolute the same way :32 does for claude, or say in the :24-26 comment that only claude gets this treatment.

Checks run: `shellcheck tests/gates.sh` gave `sc=0`. `tests/gates.sh`, `docs/one-fact.md`, `AGENTS.md` and `README.md` in the working tree are identical to snapshot 5709a38.

Not checked: I did not run the full `tests/gates.sh`, and I did not test the `+` expansion on bash older than 4.4 (only bash 5.3.9 is installed). I did not re-review anything outside the fix range. The scratch files are in /tmp/claude-1001/-home-pvhv-projects-skills/1028ab57-733a-4f6f-a77a-e2fb1d2fb2c6/scratchpad.
