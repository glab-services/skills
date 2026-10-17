# Questions — feature-docs-specs

One question. It blocks only step M1's handling of one subfolder and steps
P13 and S4's *Profiles* text; everything else in the plan is buildable now.

## Q1 — the user's prompting notes: do they leave the working tree with their folder?

**Context.** `plan/feature-opencode-worker/notes/` holds five files you
supplied — prompting notes for each model family and a comparison table
(`deepseek-flash.md`, `deepseek-pro.md`, `glm.md`, `kimi.md`, `diff.md`), which
another model (Qwen) wrote as fill-in templates. They are inputs, not records
of the work: the four family profiles were tuned from them, and each profile's
`## Notes` cites them by path
(`plugins/glab/skills/external-agents/profiles/kimi.md:30-31`, `glm.md:29-30`,
`deepseek-pro.md:29-30`, `deepseek-flash.md:30-31`). Those `## Notes` are never
sent to a model (`external-agent.sh:456` reads only *Before* and *After the
contract*; proven by hash in `findings.md`). Open follow-up 12 of
`feature-opencode-worker` says to re-tune the profiles from the live-probe
transcripts, which this change moves into history with the rest of the folder.

**Why it is yours.** It is your own material, and either answer decides what a
reader of the tree can still open without `git`. Nothing is lost either way:
every answer keeps the files in history at `51043c4`.

**Candidates.**

- **A — they go with the folder (recommended).** The five files leave the
  tree in the removal commit; `docs/specs/external-agents.md` *Profiles* names
  `git show 51043c4:plan/feature-opencode-worker/notes/<file>`, and each
  profile's `## Notes` cites that section instead of the path. Consequence:
  the tree holds no second copy of advice the profiles already distilled; a
  re-tune reads the notes from history, as it reads the transcripts.
- **B — they move, unchanged, to `docs/notes/external-agents/`.** Same five
  files, byte for byte; the profiles cite that path; the spec says what they
  are (your notes, written by another model, secondary advice) and that they
  are frozen input, not maintained. Consequence: you can open them in the tree;
  `docs/` gains a second directory beside `docs/specs/`, and nothing keeps
  those files current.
- **C — they stay where they are.** Consequence: `plan/feature-opencode-worker/`
  is not removed, which contradicts the rule this change adds; `check.sh`
  section 1 would then need an exception. Not recommended.

**Recommended:** A.

**Answer:** A — they go with the folder and stay in history at `51043c4`; the spec and the profiles cite that. Given by the user in chat on 2026-10-17, together with approval of `plan.md` (full tier) and the go-ahead to push `51043c4..6838133`.
