# Follow-ups — 03-project-manager

Found while building 03 and left out, because no step names them.

- FU1 — `plugins/glab/skills/project-plan-analyze/SKILL.md` has no `argument-hint:`. P3 names only `name:` and `description:`; P1 and P9 name `argument-hint: "[plan slug]"`, and every other slug-taking stage skill has one. I wrote it and then removed it to keep to P3. Decide whether to add it.
- FU2 — `README.md:281` still reads "where Stage 1c puts every record line". It is a stage name, not a `glab:project-manager` pointer, so P16 does not cover it. The rule itself now lives in `glab:project-plan-report` *The freeze*.
- FU3 — `plugins/glab/skills/commit/SKILL.md:7` still names "the record's commit (Stage 8)". W2 keeps it, but Stage 8's detail now lives in `glab:project-record`.
- FU4 — `/usr/bin/grep -cE 'Stage (1b|1c|2|3|4|5|6b|8)\b' README.md` prints `2`: `:35`, which names stages as rows of the table, and `:281` (FU2). Neither is a pointer P16 names.

- FU2 — `plugins/glab/skills/project-manager/SKILL.md:36` still states a round-cap value ("the amendment after round 2"); turn it into a pointer to `glab:session-rules` *Round caps*, or list the file in the `AGENTS.md` round-caps entry. Raised by the fix round, not by a review.
- FU3 — three files stated a registered fact on HEAD and are not in its *One fact* entry: `agents/project-developer.md:115` (the analyzers' verdict lines), and `skills/project-develop/SKILL.md:17` and `skills/project-plan-report/SKILL.md:11` (`glab:project-plan`'s step numbers).
- FU4 — two rationale lines of HEAD:PM were not carried (review round 1 advisories, non-blocking): `:175-177` "by far the cheaper of the two places" (kept as a pointer to `glab:project-plan-analyzer` *The plan check*) and `:135` "not a breach of Rule 2 or Rule 5" (cut per P12).
