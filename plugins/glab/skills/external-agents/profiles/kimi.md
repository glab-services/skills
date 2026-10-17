# Profile — Kimi

Sent after the default profile's matching section, to every model whose line
in the allowlist of `external-agent.sh` names `kimi`. Its two sections are
tuned from the user's notes on prompting this family, which another model
wrote: secondary advice, not yet checked against a reply. See *Notes*.

## Before the contract

Write in a strict, professional register: no filler, no pleasantries, and no
comments about yourself or about this message. Tie every claim about the
code to its source: the `file:line` and a short, word-for-word quote of what
is there, in the field the template has for the claim. Add no field of your
own.

## After the contract

Every claim about the code in your answer names its `file:line` and quotes it.

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
  fills a fixed report inside the script's template was taken: a strict
  professional tone with no filler, pleasantries or meta-commentary, and every
  claim about the code tied to its source as a `file:line` with a short direct
  quote, in the template's own field, and the silent self-check that all four
  profiles share. About the code only: a claim backed by command output, the
  verdict and the not-checked lines have no `file:line`, and a model told to
  give every claim one may invent it.
- Left out: the notes' own answer shapes (traces, final-answer, summary and
  blind-spot sections), a visible `<thinking>` block in the answer (the
  backend captures reasoning separately), the "INSUFFICIENT DATA" string (the
  repository's rule is `UNVERIFIED: <claim> — <why>`), tool-calling JSON
  directives (OpenCode handles tools), `[INSERT …]` placeholders, and every
  architecture, parameter, context-size, cost or training claim. Those are
  unverified, and some are wrong: a persona does not select a model's experts.
- UNVERIFIED: that this text makes a real reply better. Replies from this
  family were captured in the live probe of 2026-10-17, for `kimi-k3` and
  `kimi-k2.7-code` (`docs/specs/external-agents.md`, *Live runs*), but only
  with this profile, so nothing compares them with a reply without it. Tune
  this profile from those transcripts, and cite them here.
