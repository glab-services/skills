---
name: project-review
description: Project level — Review changes with the glab:project-reviewer agent against AGENTS.md
argument-hint: "[path or branch, empty for the working tree]"
---

The entry point of `glab:project-manager` Stage 5, and of the record's review (Stage 8). The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-review` — dispatches the **glab:project-reviewer** agent, as `glab:session-rules` Rules 0d and 5 say, with what Stage 5 gives a reviewer. Target: $ARGUMENTS — if that is empty, the uncommitted working tree.

Show its report as `glab:project-manager` *The pipeline* says — to a user who typed the skill, verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

Then stop. Do not fix anything, do not stage anything, do not commit. Inside the `glab:project-manager` pipeline, Stage 5 says where the findings go; run on its own, wait for the user to say what to do with them.
