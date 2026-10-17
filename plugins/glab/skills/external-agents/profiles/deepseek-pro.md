# Profile — DeepSeek Pro

Sent after the default profile's matching section, to every model whose line
in the allowlist of `external-agent.sh` names `deepseek-pro`. Its two sections
are tuned from the user's notes on prompting this family, which another model
wrote: secondary advice, not yet checked against a reply. See *Notes*.

## Before the contract

Work from first principles: what the code has to do, and what it does. Look
for the ways it fails, such as edge cases, unusual inputs and states nobody
tested. When the task's premise looks wrong, say so as a finding or a line
inside the template, not as a section of your own.

## After the contract

Each failure mode you found is in the answer, inside the template.

Then, silently: draft your answer, critique it as a hostile critic would,
and fix what the critique finds. The critique stays out of the answer.

Your answer is the template filled in, inside the two report lines when your
message gives them, and nothing else around it. With no template, answer the
task directly.

## Notes

- Source: the user's notes on prompting this family and their comparison
  table, kept in the history of the glab-services/skills repository
  (`docs/specs/external-agents.md`, *Profiles*). Another model wrote them, as
  fill-in prompt templates in a documentation style: secondary advice, not
  observed here. Only what fits an OpenCode agent that reads a repository and
  fills a fixed report inside the script's template was taken: first
  principles, failure modes and edge cases, and saying when the task's premise
  looks wrong, inside the template, and the silent self-check that all four
  profiles share.
- Left out: the notes' own answer shapes (traces, final-answer, summary and
  blind-spot sections), a visible `<thinking>` block in the answer (the
  backend captures reasoning separately), the "INSUFFICIENT DATA" string (the
  repository's rule is `UNVERIFIED: <claim> — <why>`), tool-calling JSON
  directives (OpenCode handles tools), `[INSERT …]` placeholders, and every
  architecture, parameter, context-size, cost or training claim. Those are
  unverified, and some are wrong: a persona does not select a model's experts.
- UNVERIFIED: that this text makes a real reply better. No reply from this
  family has been captured: in the live probe of 2026-10-17
  (`docs/specs/external-agents.md`, *Live runs*), `deepseek-v4-pro` was
  refused upstream before its first turn. Tune this profile from the first
  transcript a run captures, and cite that transcript here.
