# Profile — DeepSeek Flash

Sent after the default profile's matching section, to every model whose line
in the allowlist of `external-agent.sh` names `deepseek-flash`. Its two
sections are tuned from the user's notes on prompting this family, which
another model wrote: secondary advice, not yet checked against a reply. See
*Notes*.

## Before the contract

Read the task as one instruction led by its verb, such as review, find or
explain, and do that. Every "do not" in the rules and the task binds you
without exception. Write no filler: no opening, no recap, and no offer of
more help.

## After the contract

Every "do not" in the rules and the task is obeyed.

Then, silently: draft your answer, critique it as a hostile critic would,
and fix what the critique finds. The critique stays out of the answer.

Your answer is the template filled in, inside the two report lines when your
message gives them, and nothing else around it. With no template, answer the
task directly.

## Notes

- Source: the user's notes on prompting this family,
  `plan/feature-opencode-worker/notes/deepseek-flash.md`, and the comparison
  table `plan/feature-opencode-worker/notes/diff.md`. Another model wrote
  them, as fill-in prompt templates in a documentation style: secondary
  advice, not observed here. Only what fits an OpenCode agent that reads a
  repository and fills a fixed report inside the script's template was taken:
  the task as one verb-led instruction, every explicit "do not" obeyed, and no
  filler, and the silent self-check that all four profiles share.
- Left out: the notes' own answer shapes (traces, final-answer, summary and
  blind-spot sections), a visible `<thinking>` block in the answer (the
  backend captures reasoning separately), the "INSUFFICIENT DATA" string (the
  repository's rule is `UNVERIFIED: <claim> — <why>`), tool-calling JSON
  directives (OpenCode handles tools), `[INSERT …]` placeholders, and every
  architecture, parameter, context-size, cost or training claim. Those are
  unverified, and some are wrong: a persona does not select a model's experts.
- UNVERIFIED: that this text makes a real reply better. No reply from this
  family has been captured: in the live probe of 2026-10-17
  (`plan/feature-opencode-worker/probe-r3/`), `deepseek-v4.1-flash` was refused
  upstream before its first turn. Tune this profile from the first transcript
  a run captures, and cite that transcript here.
