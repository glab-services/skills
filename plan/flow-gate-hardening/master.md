# Master — flow-gate-hardening

## Request

- 2026-11-14, the user, relayed by the manager: **"let's work on these gates"**.
- The manager's reading of those words, in its dispatch of the same date: the four open follow-ups of `plugins/glab/scripts/plan-gate.sh` recorded in `docs/specs/product.md` — `FR1-1`, `FR1-2`, `FR2-1`, `FR2-2` — and its *Known limits*. Quoted from the dispatch:
  - "**FR1-2:** a run killed by SIGKILL or a crash leaves its claim file, and every later run for that number is refused until a person removes it. Close it with automatic stale-claim detection." The claim records what proves its owner gone; "A later run on the same host may take over a claim whose owner provably no longer runs. The takeover must itself be exclusive, so two runs that both see a stale claim cannot both take it over. Prove that with a race test." "A claim from another host, or one whose owner can't be proven dead, keeps today's refusal naming the file."
  - "**FR2-2:** SIGKILL also leaves `.plan-gate.tmp.<kind>.r<n>`. Whoever takes over a stale claim removes it, and a refusal names it too."
  - "**FR2-1:** a TERM, HUP or INT arriving while `ln` runs makes the trap delete `plan.r<n>/` of a report already linked. Close it by holding those signals across the publish step and acting on a held signal right after. Prove it with the slow-`ln` stub the review used, with the signal arriving inside `ln`."
  - "**FR1-1:** publishing with `ln` fails on a store whose filesystem has no hard links." "Decide and prove a fallback that stays exclusive, or else a clear refusal naming the requirement." "Readers must never see a half-written report or verdict. If the fallback can expose one, the readers (`check`, `verdict`) must detect and refuse it." "Name the supported filesystems in the script header and in `docs/specs/product.md`'s owner pointer." "Simulate a store without hard links in the test (for example an `ln` stub that fails with the real error)."
  - "Also close what the spec lists as UNVERIFIED, if you can prove it here: the signal landing between the claim's subshell and `CLAIM=$1`."
  - "**Keep:** every existing contract: exit codes, stdout and stderr, the store layout, the walkthrough trace; all 42 `tests/plan-gate.test.sh` cases and 17 `tests/product-loop.test.sh` cases passing; the walkthrough trace byte-identical, unless a change is intended and said."
  - "The version goes to 0.14.1. AGENTS.md *One fact* and *Gates*: update whatever counts or entries change."
- The session effort, the user's words: "high (Recommended)".

## Goals

- **G1** — A claim left by a killed run is taken over automatically by a later run on the same host once its run provably no longer runs; the takeover is exclusive, shown by a race test; a claim from another host, or one whose run cannot be proven gone, keeps today's refusal naming the file (FR1-2).
- **G2** — The run that takes over a stale claim removes the temporary file the killed run left, and a refusal names that file too (FR2-2).
- **G3** — A TERM, HUP or INT that arrives while `ln` runs is held across the publish step and acted on right after, so `plan.r<n>/` of a linked report stays; shown with a slow-`ln` stub, the signal arriving inside `ln` (FR2-1).
- **G4** — A store without hard links gets a decided, proven answer — an exclusive fallback whose readers never see half a file, or a clear refusal naming the requirement — simulated in the test; the supported filesystems are named in the script header and in `docs/specs/product.md`'s owner pointer (FR1-1).
- **G5** — The signal landing between the claim's subshell and `CLAIM=$1` is closed and proven, if it can be proven here.
- **G6** — Every existing contract kept — exit codes, stdout and stderr, the store layout, the walkthrough trace byte-identical unless a change is intended and said; the 42 and 17 cases pass; `glab` goes to 0.14.1; `AGENTS.md` *One fact* and *Gates* follow what changes.

## Out of scope

none — the request names no exclusion.

## Final check

On the finished tree, with `TMPDIR` exported to the host's temp directory: both gate blocks of `AGENTS.md` *Gates* green, `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh` ending `PASS 51/51` and `bash tests/product-loop.test.sh …` ending `PASS 17/17`; the same test file run against `git show f6fcb14:plugins/glab/scripts/plan-gate.sh` printing exactly `FAIL T38`, `FAIL T43` … `FAIL T51` and `FAIL T22`, and every other case `ok`; the walkthrough trace (`PRODUCT_LOOP_SHOW=1`) byte-identical between that old script and the new one; `jq -r .version plugins/glab/.claude-plugin/plugin.json` printing `0.14.1`. `plan.md` *After* gives each command.

## Record

- **`docs/specs/product.md`**, the primary area:
  - the owner pointer: `plugins/glab/scripts/plan-gate.sh` (its header comment, which also names where a store may live: a filesystem with hard links, an exclusive create and unix permission bits — ext4 tested, xfs, btrfs, zfs, tmpfs, APFS and HFS+ by their documentation; not FAT, vfat or exFAT; a network, FUSE or synced folder UNVERIFIED);
  - *How it works now*, the `plan-gate.sh` bullet: the claim line `<host> <boot id> <pid namespace> <pid> <start>`, the takeover under `.plan-gate.takeover.<kind>.r<n>` with the claim read again under it, the refusal texts, the held signals around the claim, the takeover and the publish, the `-ef` check after a failed `ln`, the exit-2 message on a store without hard links, `T1`–`T51`;
  - *Known limits*: the `review-2.md finding-2` and `result.md claim-window` lines rewritten as closed, with what still holds (the re-tests under the claim and the exit-2 branches uncovered); `o-excl-network` pointing at the header's list; the new limits of `plan.md` *Decisions* `limits`;
  - *Open follow-ups* `FR1-1`, `FR1-2`, `FR2-1`, `FR2-2` moved to *Closed follow-ups*, each with its mechanism and test ids;
  - *Decisions that still bind*: the decisions of `plan.md`, by id; *Records*: this change's line.
- **`docs/specs/marketplace.md`**: the version `0.14.1`; `plan-gate.sh`'s contract as `AGENTS.md` *Rules* now states it; the stubs of `tests/plan-gate.test.sh` (now also `ln` and `head`) and its `PASS 51/51`.
- No audit file.

## Approval

- approved by the user, 2026-11-14, in chat: "Yes, develop"; base f6fcb14
