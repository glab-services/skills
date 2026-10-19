---
description: Review changes with the glab:reviewer agent against AGENTS.md
argument-hint: "[path or branch, empty for the working tree]"
---

Read `AGENTS.md` at the repo root first (or `CLAUDE.md` if the repo has none — say so). The reviewer reads it too, but if I ask you to fix a finding you will be editing code, and the rules must be in hand before that.

Then use the **glab:reviewer** agent. Target: $ARGUMENTS — if that is empty, the uncommitted working tree. If I named a model for the reviewer, pass it as the Agent tool's `model` parameter; if I named none, pass none, and never choose one yourself (`glab:manager` Rule 5). Pass the Agent tool's `effort` parameter at the level `glab:manager` Rule 0d gives. If I named an external reviewer instead — a backend, and for OpenCode a model — run it through the `glab:external-agents` skill, with the same target. An OpenCode reviewer's copy holds only `HEAD` and the working tree, so a branch or a range cannot be its target: tell me that instead of starting one; a Codex reviewer works in the repository and can take one.

Show its report verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

Then stop. Do not fix anything, do not stage anything, do not commit. Run on its own, wait for me to say what to do with the findings; inside the `glab:manager` pipeline, Stage 5 sends them back to `/glab:develop`.
