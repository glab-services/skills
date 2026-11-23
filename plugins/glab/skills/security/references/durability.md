# Durability — the rules for code that holds someone else's data

Read by `glab:security` *Part 2* whenever a change touches stored data, a schema, a serialized, file or wire format, a write path, a checksum, a retry, an encoding, a lock, a handle or concurrency.

These are the rules for code that holds data belonging to someone else. Break one and the failure is usually silent, discovered later, and not recoverable.

## Never infer a rule by mirroring a neighbour

Read the specification. Do not copy the sibling case, do not mirror the value above, do not reason from what obviously matches.

This has a measured cost. In one real audit, sixteen permission mappings had been inferred by mirroring their neighbours; eight were wrong when checked against the actual specification — and **every one was wrong in the unsafe direction**, each turning a restricted operation into a permitted one. Mirroring does not fail randomly. It fails toward whatever the neighbouring case was permissive about.

A conformance suite is not a specification either. A failing case is a prompt to go read the spec, not a bug report to code against. A passing one proves nothing about behaviour it does not exercise, and the suite can be depending on your bug.

## Identity data is carried byte for byte

Keys, IDs, paths, filenames, user-supplied names. No trim, no case fold, no normalize, no re-encode, no "cleanup".

A key that is silently rewritten produces an object that cannot be found, cannot be deleted, and blocks every operation scoped to its container — forever, with no error anywhere. From the outside that is indistinguishable from data loss, and it is worse, because the bytes are still on disk paying for storage while being unreachable.

## Encode and decode are paired and idempotent

Every encoding has exactly one decode and exactly one place that owns applying it.

A decode applied twice is a different function: `+` becomes a space, `%2F` becomes a separator, and the value silently changes meaning halfway through the system. Before adding a decode, find where it is already applied. Before removing one, find who depends on it — a double-decode that existing data was written through cannot simply be deleted without stranding that data.

## Format changes need dual-read

Deploys are not atomic. Old readers meet new writers, and new readers meet old data, both in production, at the same time.

Any change to a serialized format, a schema, a database document, or a wire protocol must be readable both ways for at least one release. If you cannot roll back through the change, it is not shippable — write the migration and the compatibility window, or do not change the format.

## Detect and surface; do not auto-heal

An automatic repair that runs on a wrong assumption destroys both the data and the evidence of what went wrong.

Report the inconsistency, name what is affected, and let a human decide. Reserve automatic correction for cases where the correct value is provably reconstructible and the failure to act is worse than acting.

## "Unlikely window" means certain

A race that needs a 10 ms window happens continuously at production request rates. At scale, per-request probabilities are frequencies.

Never dismiss a concurrency hazard by arguing it is improbable. Dismiss it by proving it impossible — a lock held, an ordering enforced, an invariant that cannot be observed broken — or fix it.

## In-flight corruption outranks everything

A validator that checks data at rest cannot see data corrupted on the way in. The bytes land, they verify against themselves, and they are wrong.

So any change touching a write path, a checksum, a buffer, a partial write, or a retry is **top severity by default** until proven otherwise. This is the one category where "we would have noticed" is never true.

## Resource lifecycle is ownership

Every descriptor, handle, connection and lock has exactly one owner and one close path. State who owns it and where it is released.

A buffer shared across concurrent requests is a defect until proven otherwise. A handle closed in two places is a use-after-close waiting for the right interleaving. A handle closed in none is a leak that looks fine until the process runs out.

## Destructive operations are proven, not assumed

Before any delete, overwrite, truncate, reset, drop or force: **look at the target first.** Confirm it is what you think it is, and establish whether it is recoverable.

Untracked files, dropped volumes, remote branch history and reset working trees are not recoverable. For those, stop and ask — approval for one destructive action never carries to the next, except the standing approval of `glab:session-rules` Rule 2.

## Secrets never enter output

Not into logs, error messages, commit messages, test fixtures, exception traces, or any URL you print. Assume anything printed is retained and indexed somewhere you cannot reach.

A remote URL can carry credentials in its userinfo. Name the remote instead of printing it.

Do not print config values at all; test them instead. A brief that left this out is how one credential leaked a third time: an agent enumerating config for an unrelated reason redacted by key name and printed a DSN's embedded password. A DSN carries a password in the middle of a value, not only after an `@` — two different redaction attempts leaked one.
