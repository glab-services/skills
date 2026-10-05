---
description: Review changes with the reviewer agent against AGENTS.md
argument-hint: "[path or branch, empty for the working tree]"
---

Read `AGENTS.md` at the repo root first (or `CLAUDE.md` if the repo has none — say so). The reviewer reads it too, but if I ask you to fix a finding you will be editing code, and the rules must be in hand before that.

Then use the **reviewer** agent. Target: $ARGUMENTS — if that is empty, the uncommitted working tree.

Show its report verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

Then stop. Do not fix anything, do not stage anything, do not commit. Wait for me to say what to do with the findings.
