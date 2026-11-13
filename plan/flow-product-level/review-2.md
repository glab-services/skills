# flow-product-level — review round 2 (the last allowed)

The reviewer checked every round-1 finding and found all of them fixed, re-running the attacks for A1, A2, A3 and A6. B8 has one advisory leftover. The reviewer then found 5 new defects in `plugins/glab/scripts/plan-gate.sh`, quoted verbatim below. None is critical or high, so there is no third review round. These are fixed under the manager's decisions, and the manager reruns the gates and the attacks.

## Findings (verbatim)

1. `plan-gate.sh:87-96` (with :228, :295) — **medium** — a run killed by SIGKILL, or by a signal between the claim's subshell and `CLAIM=$1`, leaves `.plan-gate.claim.verdict.r1` in the store. After that every verdict prints `REFUSED: another run is writing verdict r1` and every report prints `report r1 has no verdict yet`. The project is stuck, nothing names the file to remove, and the comment at :88-89 says the claim is "never left in the store". Reproduced with `kill -KILL`; TERM, HUP and INT did release the claim. Fix: name the claim's path in the refusal, with "when no run is writing, remove it by hand" (as the `plan.r<n>/` refusal already does), correct the comment, and add a test that kills a run.
2. `plan-gate.sh:196-197,251-252` — **low** — `TMP_DIR` is cleared only after the `rm` that follows a successful `ln`. A TERM in that window lets the trap delete `plan.r1/` of a report that is already published. Then `verdict` says `the copies in plan.r1/ do not match report r1` and `report` says `report r1 has no verdict yet`. Reproduced by slowing `rm` by 2 s. Fix: clear `TMP_DIR` right after the `ln` succeeds, before the `rm`.
3. `plan-gate.sh:224` — **low** — a second report started while the first holds the claim and has made `plan.r1/` is told `plan.r1/ is there without report r1; look at it and remove it by hand`. That asks a person to delete a copy another run is still filling (reproduced). Fix: take the claim before this test, or test for the claim file first.
4. `plan-gate.sh:270-271` — **low** — `verdict` refuses a symlink in the copy because it "would add text to the audit that the digest does not cover", but extra regular files pass. With `plan.r1/steps-1.r1.md` and `plan.r1/evidence.md` added, `verdict ACCEPTED` exited rc=0, and `product-project-plan-analyze` gives the analyzer the whole folder. Fix: refuse when the file list of `plan.r<n>/` differs from what `list_plan` prints.
5. `plan-gate.sh:244,297` — **low** — a SIGINT sent only to the bash process while `mktemp` runs leaves a `.plan-gate.XXXXXX` file: the trap runs after the command substitution but before the assignment. Reproduced with a 2 s `mktemp`. Fix: create the temporary file under a fixed name derived from the claim, so the trap can remove it.

B8, the advisory leftover: the clause "the rules are the user's" is still in both `product-plan` :36 and `product-manager` :62.

## Manager decisions

- Apply all five as each Fix says. For finding 3, take the claim before the test.
- Each fix gets a test in `tests/plan-gate.test.sh` that fails on the current script. For finding 1, the test kills a run with SIGKILL and asserts that the refusal names the leftover claim file.
- The B8 leftover: keep the clause once, in `product-manager`. `product-plan` keeps a pointer.
- The cap holds: no third review round. The manager verifies by rerunning the gates, the gate test 5 times, and the original attack for finding 1 itself.
- Nothing else changes; `master.md` stays untouched and `glab` stays 0.14.0.
