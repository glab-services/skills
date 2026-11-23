---
name: security
description: The short evidence and safety rules of the glab workflows — never claim what you did not run, run the repo's own gates, stay in scope, look before deleting, keep secrets out of output; plus a durability checklist for changes on data, format or concurrency paths only.
---

# Security

Short on purpose. Apply each rule once, where it bears. Do not repeat a check you already ran.

## Always

1. **Never claim what you did not run.** "Tests pass" means you ran them in this change and saw them pass. If you could not run something, write it once as `UNVERIFIED: <claim> — <why>` and move on. This is not a failure.
2. **Run the repo's own targets** — the gate line — not a command you made up. Run them once on the finished change, not after every edit.
3. **Green means green.** No failures, and no skipped suite you meant to run. Call a failure pre-existing only after you have seen it fail on the base branch.
4. **No fix-mode linters or formatters** (`--fix`, `--write`, `-w`). They rewrite files outside your change.
5. **Stay inside the task.** If you notice something else worth doing, note it as a follow-up and leave it.
6. **Look before you delete or overwrite.** For anything that cannot be recovered (untracked files, dropped data, remote history, a reset tree), stop and ask.
7. **Secrets never enter output:** commit messages, logs, reports, fixtures, printed URLs or config values. Name a remote, never print its URL.

## Only when the change touches stored data, a wire or file format, or concurrency

Check each item once, in the plan and in the review:

- Identity data (keys, IDs, paths, names) passes through byte for byte: no trim, no case fold, no re-encoding.
- Each encoding has one decode, applied in one place.
- A format or schema change stays readable both ways for one release, or the plan says how to roll back.
- Report an inconsistency; do not auto-heal it on a guess.
- Never wave a race away as unlikely. Prove it impossible, or fix it.
- Every handle, connection and lock has one owner and one close path.
- Any change to a write path, checksum or retry is top severity until shown otherwise.

## The final report

Write it once, in `result.md` or the last message, not in every stage:

    gates: <gate line> -> ok | red | UNVERIFIED: why
    changed: <the behaviour that changed, and who calls it>
    not done: <what was not checked, or "none">
