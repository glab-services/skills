# Host file — example

Copy this to `~/.claude/host.md` and edit it. It is never shipped: it holds
facts that are true of one machine only. `glab:bootstrap` step 1 reads it at
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

The Claude Code CLI is `<path to the claude binary on this host>`. A session
started by the desktop app has no `claude` on `PATH`; from its Bash tool,
`readlink /proc/$PPID/exe` prints the binary that is running the session. The
path contains the CLI version, so it changes with every update — look it up
each time rather than keeping an old one. The plugin gates of the
`glab-services/skills` repository read it from `CLAUDE_BIN`: export that
variable as this path before running them.

## glab shared store

glab-shared-store: <path to the shared folder>

The folder where the product level and its projects exchange briefs, reports
and verdicts. Its path is a fact of one machine, so it sits here; a repo whose
`AGENTS.md` has its own `glab-shared-store:` line uses that one instead. The
filesystems it may sit on are named in the header of
`plugins/glab/scripts/plan-gate.sh`.
