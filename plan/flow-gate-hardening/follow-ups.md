# Follow-ups — flow-gate-hardening

Open items found during this change and left out of its scope, filed by the manager 2026-11-14.

- **FG-1** (low, review round 2, inferred): when the exclusive open of a claim succeeds but the write fails (for example ENOSPC), the run leaves a claim file with an empty line, refuses with exit 1 and asks the user to remove its own file, where the contract (`AGENTS.md` *Rules*) expects exit 2 for a failed write. The same held before this change (the round-1 subshell), and the comment at `plugins/glab/scripts/plan-gate.sh` `create_line` states it.
- **FG-2** (low, review round 1 advisory): the store's filesystem requirement (hard links; not FAT; network and synced stores UNVERIFIED) is stated only in the `plan-gate.sh` header. `README.md` *The shared store* and `host.example.md` tell users to make a store folder without it. The record adds it to the owner pointer in `docs/specs/product.md`; whether the README should point at it is open.
