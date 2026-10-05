---
name: sync-memory
description: Sync Claude Code memories to or from S3 or an S3-compatible store, recover an earlier version of a memory
  from bucket versioning, delete a memory everywhere, and report whether the automatic session hooks are working. Use when the user
  asks to back up, restore, push or pull memories, wants a previous version of a memory file, or asks
  why memory sync is not working.
---

# Memory sync

Memories live in `~/.claude/projects/<project>/memory/` and are mirrored to S3 by
`~/.claude/memory-sync.sh`. Four hook events in `~/.claude/settings.json` run it automatically: `SessionStart` pulls, `SessionEnd` pushes, and `PostToolUse` and `Stop` run `push-if-changed`, so an edited memory reaches S3 within seconds. This skill is for doing
it by hand, and for diagnosing it when the automatic path is silent.

## Arguments

- `push` — local to S3. Use after writing memories you want available elsewhere,
  without waiting for the session to end.
- `pull` — S3 to local. Use when another machine has newer memories. A `memory`
  directory that is a symlink to a directory stays a symlink; pull does not replace it.
- `push-if-changed` — what the hooks run: pushes only when a memory file is newer than the last successful push. It skips while another sync holds the lock, and for 5 minutes after a failed push.
- `delete <project>/memory/<file>` — removes one memory from the bucket, the stage and this machine. See *Deleting a memory*.
- no argument, or `status` — report configuration and drift, change nothing. This is a procedure in this skill, not a mode of the script.

## Doing a sync

Run the script directly. It is safe to run at any time: `pull` and `push` never delete a memory on either side, only `delete` does, and it exits 0 even on failure so it can never break a session.

```
~/.claude/memory-sync.sh push
```

Report what it printed. `push ok`, `push-if-changed ok`, `pull ok` or `delete ok: <path>` means it completed;
anything else is the reason it did not. Three lines mean it only half completed:

- `delete: remote copy removed, but this copy was NOT removed: <path>` — the
  bucket object is gone but a copy on this machine is not. See *Deleting a memory*.
- `delete: remote delete not confirmed; run delete again` — the remote delete
  was cut off by the time limit, so nobody knows whether the object is gone.
- `<mode>: sent, but the push stamp was not updated: <path>` — the transfer
  succeeded but the stamp file at that path could not be replaced, so every
  later `push-if-changed` sends again until that is fixed.

## Status check

When asked for status, or when a sync did not do what the user expected, gather
these and report them together rather than one at a time:

1. **Is a bucket configured?** `CLAUDE_MEMORY_S3_URI` must be non-empty. Test it
   without printing its value: `[ -n "$CLAUDE_MEMORY_S3_URI" ] && echo set`. When it
   is empty the script logs `CLAUDE_MEMORY_S3_URI is not set; skipping` and exits 0, which is the most common reason
   "nothing happens". It is set in the `env` block of `~/.claude/settings.json`.
2. **Do credentials work?** `aws s3 ls "$CLAUDE_MEMORY_S3_URI/" $CLAUDE_MEMORY_S3_ARGS` with the configured
   `AWS_PROFILE`. A failure here surfaces as a failed sync with no other clue.
   Do not reach for `aws sts get-caller-identity` — some S3-compatible stores, RustFS among them, do not implement STS, so it fails even when the credentials are perfect.
3. **What differs?** The push direction is
   `aws s3 sync ~/.claude/projects/ "$CLAUDE_MEMORY_S3_URI/" --exclude '*' --include '*/memory/*' $CLAUDE_MEMORY_S3_ARGS --dryrun`,
   which shows what a push would move without moving it. This is the honest
   answer to "are my memories backed up". Pull drift has no dry run: pull downloads into
   `~/.claude/.memory-sync-stage` and then copies only files that are missing
   locally or newer in S3, so a direct S3-to-local dry run overstates what a pull
   would change.
   Without `$CLAUDE_MEMORY_S3_ARGS` these commands talk to AWS itself, not to the configured endpoint.
   When you report what these commands print, replace the bucket name with a placeholder.
4. **Are the hooks live?** `jq '.hooks' ~/.claude/settings.json` should show
   `SessionStart`, `SessionEnd`, `PostToolUse` and `Stop` entries pointing at the script.
5. **Is a failed push cooling down?** For 5 minutes after a failed push,
   `push-if-changed` skips without printing anything. The marker is
   `~/.claude/.memory-sync-failed`: `ls -l` it and compare its time with now. A
   plain `push` ignores the cool-down, and a successful push removes the file.

## What is and is not synced

Only files under a `memory/` directory. Session transcripts, plans, and
everything else in `~/.claude/projects/` stay local — that scoping is what makes
this safe to point at a bucket, so do not widen it without saying so explicitly.

Known limitation, not fixed: `push-if-changed` may not notice edits under a
symlinked `memory` directory, because its change scan does not follow links.
This was not reproduced.

## Conflicts

A push overwrites the remote object when the local file differs — there is no
merge. A pull never overwrites a local file that is newer than the remote
object's upload time — upload time, not the time of the edit that was uploaded.
The consequence: a machine holding an older copy can still upload it at session
end if its size differs, and other machines then pull that older content;
previous versions remain recoverable from bucket versioning where it is enabled.
Syncs on one machine are serialised by a lock file, but **there is no lock across machines**:
two machines editing the same memory file between syncs means the later push
wins in the bucket. If the user works from several
machines at once, say this plainly rather than implying the sync resolves it.

What makes that survivable is bucket versioning, when it is enabled (below): the overwritten content is still
in the bucket and can be recovered.

## Deleting a memory

```
~/.claude/memory-sync.sh delete <project>/memory/<file>
```

The path is relative to `~/.claude/projects/`. The script removes the bucket
object first, and the stage and local copies only if that succeeded — when the
remote delete fails nothing local is touched. Plain `rm` is not enough: the file
is still in the bucket, so the next pull brings it back.

Two failures need a second run:

- **The local copy could not be removed.** The next push restores it to the
  bucket, so remove the local file by hand and run `delete` again.
- **The remote delete was cut off by the time limit.** The outcome is unknown,
  so run `delete` again.

**Confirm the exact path with the user before running it.**

Another machine that still has the file will upload it again on its next push,
so run `delete` there too. With versioning enabled the content stays recoverable
as an earlier version — see the next section.

## Recovering an earlier version

When the bucket has versioning enabled, every overwrite and every delete keeps the previous content. Check that it is before relying on this.
A memory that was clobbered, or edited into something worse, is recoverable.

List what exists for one file, newest first:

```
aws s3api list-object-versions --bucket <bucket> \
  --prefix <prefix>/<project-dir>/memory/<file>.md \
  --query 'Versions[].{Id:VersionId,Latest:IsLatest,When:LastModified,Size:Size}' $CLAUDE_MEMORY_S3_ARGS
```

`<prefix>` is the path part of `CLAUDE_MEMORY_S3_URI`; the key is that prefix plus the file's path under `~/.claude/projects/`.

Read one without overwriting anything local — always do this before restoring, so
the user can confirm it is the version they meant:

```
aws s3api get-object --bucket <bucket> \
  --key <prefix>/<project-dir>/memory/<file>.md \
  --version-id <id> /dev/stdout $CLAUDE_MEMORY_S3_ARGS
```

Restore by writing that content back over the local file, then push. Do not use
`s3api delete-object` to "roll back" — deleting the newer version destroys it
permanently, while a normal restore keeps both.

Two quirks seen on RustFS — other stores may differ:

- `get-bucket-versioning` returns an empty response on RustFS. That is an unimplemented
  API call, **not** evidence that versioning is off. To confirm versioning really
  works, overwrite a throwaway key twice and check it has two version ids.
- Objects written before versioning was switched on report version id
  `00000000-0000-0000-0000-000000000000`, the null version. They are still
  retrievable by that id, and are preserved as history once overwritten.
