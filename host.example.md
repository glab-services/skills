# Host file — example

Copy this to `~/.claude/host.md` and edit it. It is never shipped: it holds
facts that are true of one machine only. `bootstrap` step 1 reads it at
session start.

What follows is the author's host, kept in full because each line is a lesson.

## Temp files

**Temp files go in `/data/tmp/claude`, never `/tmp`** — `/data` is a dedicated disk. `/tmp` here is a tmpfs
under a **per-user quota shared by every agent**. Exhausting it returns `EDQUOT`
on every write and takes the Bash tool down with it — the harness writes its own
task output under `/tmp/claude-<uid>/`, so a full `/tmp` is not a slow session,
it is a dead one, and it cannot be repaired from inside that session. Growing
the tmpfs does not help: `size=` is the filesystem, `usrquota` is the per-user
cut of it. `export TMPDIR=/data/tmp/claude` before any `go` command, use unique
filenames, clean up what you create, **and say all of this in every dispatch
message** so subagents do the same.

## Tool paths

The system grep is `/usr/bin/grep`.
