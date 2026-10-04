---
name: sync-memory
description: Sync Claude Code memories to or from S3 (RustFS), recover an earlier version of a memory
  from bucket versioning, and report whether the automatic session hooks are working. Use when the user
  asks to back up, restore, push or pull memories, wants a previous version of a memory file, or asks
  why memory sync is not working.
---

# Memory sync

Memories live in `~/.claude/projects/<project>/memory/` and are mirrored to S3 by
`~/.claude/memory-sync.sh`. Two hooks in `~/.claude/settings.json` run it
automatically: `SessionStart` pulls, `SessionEnd` pushes. This skill is for doing
it by hand, and for diagnosing it when the automatic path is silent.

## Arguments

- `push` — local to S3. Use after writing memories you want available elsewhere,
  without waiting for the session to end.
- `pull` — S3 to local. Use when another machine has newer memories.
- no argument, or `status` — report configuration and drift, change nothing.

## Doing a sync

Run the script directly. It is safe to run at any time: it never deletes on
either side, and it exits 0 even on failure so it can never break a session.

```
~/.claude/memory-sync.sh push
```

Report what it printed. `push ok` / `pull ok` means the transfer completed;
anything else is the reason it did not.

## Status check

When asked for status, or when a sync did not do what the user expected, gather
these and report them together rather than one at a time:

1. **Is a bucket configured?** `CLAUDE_MEMORY_S3_URI` must be non-empty. When it
   is empty the script skips silently by design, which is the most common reason
   "nothing happens". It is set in the `env` block of `~/.claude/settings.json`.
2. **Do credentials work?** `aws s3 ls s3://<bucket>/` with the configured
   `AWS_PROFILE`. A failure here surfaces as a failed sync with no other clue.
   Do not reach for `aws sts get-caller-identity` — the backend is RustFS, which
   does not implement STS, so it fails even when the credentials are perfect.
3. **What differs?** `aws s3 sync --dryrun` in both directions shows what a push
   or pull would move without moving it. This is the honest answer to "are my
   memories backed up".
4. **Are the hooks live?** `jq '.hooks' ~/.claude/settings.json` should show
   `SessionStart` and `SessionEnd` entries pointing at the script.

## What is and is not synced

Only files under a `memory/` directory. Session transcripts, plans, and
everything else in `~/.claude/projects/` stay local — that scoping is what makes
this safe to point at a bucket, so do not widen it without saying so explicitly.

## Conflicts

`aws s3 sync` compares size and modification time; it has no merge. Two machines
editing the same memory file between syncs means the later push wins and the
earlier edit is lost locally. There is no locking. If the user works from several
machines at once, say this plainly rather than implying the sync resolves it.

What makes that survivable is versioning, below: the overwritten content is still
in the bucket and can be recovered.

## Recovering an earlier version

The bucket has versioning enabled, so every overwrite keeps the previous content.
A memory that was clobbered, or edited into something worse, is recoverable.

List what exists for one file, newest first:

```
aws s3api list-object-versions --bucket <bucket> \
  --prefix projects/<project-dir>/memory/<file>.md \
  --query 'Versions[].{Id:VersionId,Latest:IsLatest,When:LastModified,Size:Size}'
```

Read one without overwriting anything local — always do this before restoring, so
the user can confirm it is the version they meant:

```
aws s3api get-object --bucket <bucket> \
  --key projects/<project-dir>/memory/<file>.md \
  --version-id <id> /dev/stdout
```

Restore by writing that content back over the local file, then push. Do not use
`s3api delete-object` to "roll back" — deleting the newer version destroys it
permanently, while a normal restore keeps both.

Two RustFS quirks to expect:

- `get-bucket-versioning` returns an empty response here. That is an unimplemented
  API call, **not** evidence that versioning is off. To confirm versioning really
  works, overwrite a throwaway key twice and check it has two version ids.
- Objects written before versioning was switched on report version id
  `00000000-0000-0000-0000-000000000000`, the null version. They are still
  retrievable by that id, and are preserved as history once overwritten.
