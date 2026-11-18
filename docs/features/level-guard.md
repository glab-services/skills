# Level guard

What `glab` 0.17.0 does when a session reaches for a skill of the other
level, or writes a verdict in your name.

## Another level's skill is refused

Your repo's `AGENTS.md` names its level with a `glab-level:` line; no
line means the project level. When Claude calls a `glab:` skill that
this level's manager does not list, Claude Code refuses the call, and
Claude is told the skill is not of this level and that you can type it.
Skills that serve every level are allowed, skills of other plugins are
not judged, and subagents are judged like the main session. Agents are
not judged.

To run the other level's skill anyway, type it yourself, as
`/glab:<name>`. A skill you type is never refused.

## A verdict `by user` waits for you

When a session runs `plan-gate.sh verdict` with the word `user`, Claude
Code opens its permission dialog, naming the `glab` hook. Answer Yes only
if the verdict is your own decision and its reason file opens with your
words. The dialog shows the command, not the file, so the manager tells
you the file's first line before it runs. No leaves the verdict
unwritten.

In a run where no dialog can open, such as `claude -p`, the call is
refused instead: run the command in your own shell.

## When the hook cannot read the call

The hook lets the call through, and the skill text still applies. This
happens when the call, the level's list or the level rule cannot be read,
or when a command hides the name or the words.

## Where the details are

- `README.md` *Levels*: *The boundary* and *Known limits*, which name the
  modes that were tried and what the hold does not stop.
- `docs/one-fact.md` *The `glab` guard hook* and *The `by user` hold*:
  the files that state the reason texts and the hold.
