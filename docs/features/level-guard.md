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

## The boundary and known limits

**The boundary.** Each manager's *Your skills — this level only* list is the
rule a session keeps to; a description's `Product level — ` or
`Project level — ` prefix is a hint. No `glab` agent has the `Skill` tool,
and a `PreToolUse` hook refuses every other Skill call to a `glab:` skill not
on the session's list — except when it cannot read the call, the list or the
level rule, and then it lets the call through.

**Known limits.** The hook judges the skills Claude calls, in subagents too;
it judges no agent. A skill you type yourself as `/glab:<name>` is never
refused, but a skill it calls in turn through the Skill tool is judged
(inferred: no live run made such a call). A verdict `by user` opens the
permission dialog, so only you pass it, as far as the command's text shows
`plan-gate.sh`, `verdict` and `user`; it reads the command of a Bash or
PowerShell call, and by inference of a Monitor call, whose input is not
verified; where no dialog can open — a -p run, dontAsk mode included, and by
inference dontAsk outside -p — the call is refused; with an allow rule that
covers the command, the dialog still opens — seen in auto mode, while a -p run
refused it, and other interactive modes are UNVERIFIED; under
bypassPermissions, a -p run still refused it; an interactive session was not
tried. Seen live on Linux, 2026-11-19: the refusals, the typed skill, and a
by-user verdict refused in -p runs under an allow rule, in dontAsk mode and
under bypassPermissions, of Claude Code 2.1.325; and the dialog in an
interactive session of Claude Code 2.1.327 in auto mode with an allow rule,
where Yes ran the command and No left it unrun. Both levels can write the
store, so beyond that the cap holds as far as the sessions keep to the skill
text. Skill names are matched case-sensitively; whether the CLI resolves a
skill name case-insensitively is UNVERIFIED. A skill of your own with the same
bare name as a `glab` skill of the other level is refused too.

## Where the details are

- `docs/one-fact.md` *The `glab` guard hook* and *The `by user` hold*:
  the files that state the reason texts and the hold.
