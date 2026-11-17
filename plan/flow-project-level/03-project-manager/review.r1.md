FINDINGS: 6

1. medium: `plugins/glab/skills/project-analyze/SKILL.md:11`. The line "**The dispatch carries the slug only**, and from round 2 on the round's inputs below" contradicts three other passages. Line 25 of the same file says round 1 is snapshotted too and its tree id goes in that round's dispatch ("round 1 included … name it in that round's dispatch"). Line 7 says the check is "named in the dispatch". `agents/project-analyzer.md:74` says the final check measures "the range the dispatch names". The summary also drifted. HEAD Stage 3 (`git show HEAD:…/project-manager/SKILL.md` line 235) said "run `/glab:project-analyze {slug}` with the slug and that summary". The new text says the summary is "for the user, not for the analyzer". Fix: say the dispatch carries the slug, the check's name, round 1's tree id or the final check's range, and from round 2 the inputs below.

2. medium: `plugins/glab/agents/project-plan-analyzer.md:3`. The description still says "Use from /glab:project-analyze for the plan check and the master check". But `project-analyze/SKILL.md:9` now sends the plan check to `/glab:project-plan-analyze`, and a named check that is not its own gets "ask which". Fix: change it to "Use from /glab:project-plan-analyze".

3. medium: `plugins/glab/agents/project-analyzer.md:3`. The description still lists "the record check" under "Use from /glab:project-analyze". The record check is now dispatched directly by `project-record/SKILL.md:7,12` ("Each dispatch below is made directly"). `project-analyze` drops the record check, so naming it there gets "ask which". Fix: point the record check at `/glab:project-record`.

4. medium: `plugins/glab/skills/project-plan-analyze/SKILL.md:12,14`. A rule was lost. HEAD lines 183 and 185 said `findings.md` is copied to `findings.r<n>.md` and `cmp`'d "in a folder from before `glab` 0.10.0". A search for `findings\.r<n>` across `plugins` and `README.md` finds it nowhere now. The analyzers still read `findings.md` in such folders (`agents/project-plan-analyzer.md:23`). Without the copy, a re-check on an old folder has no copy of `findings.md` to `cmp` or diff. Fix: restore both "findings.md … before glab 0.10.0" clauses.

5. low: `plugins/glab/skills/project-plan-accept/SKILL.md:17-18`. Two send-back rules from the checklist were lost. HEAD line 149 ended item 3 with "A findings file or section with no path list has not done this step." HEAD line 150 ended item 4 with "'Which approach do you want?' with no options is a shrug … Send those back." Searching for "has not done this step", "shrug" and "path list" finds neither anywhere. Fix: restore both sentences.

6. low: `AGENTS.md:278-290` and `AGENTS.md:255-259`. The *One fact* file lists miss files that now state those facts.
   - Analyzers' verdict lines: `project-develop`, `project-plan-report`, `project-review` and `project-record` now state `CONFORMS`, `DIVERGES` or `NOT BUILDABLE` (a search for `BUILDABLE|CONFORMS|DIVERGES` matches all four). At HEAD the first three had none (counts 0/0/0), and `project-record` is new.
   - `glab:project-plan`'s step numbers: the new `project-plan-accept` and `project-plan-analyze` cite them but are not in that entry.
   - Plan mode: `project-manager:106` and `project-plan-accept:38` still state "only when the user asks", but the entry now lists only `plan-mode.md` and `README.md`.
   - Round caps: `project-plan-analyze:16` ("after round 2 … round 3") and `project-analyze:23` ("analyze round 2/2") state cap values the entry leaves out.

   Fix: add those files to each entry, or cut the restated values down to pointers.

Advisory (low, not counted):
- `project-analyze/SKILL.md:36` says "capped as *Round caps*" without a skill name, and this file has no such section. It should say `glab:session-rules` *Round caps*.
- `project-plan-analyze/SKILL.md` has no `argument-hint`, unlike its sibling stage skills.
- Rationale text with no matching phrase in the new tree: HEAD 175-177 ("by far the cheaper of the two places"), HEAD 135 ("not a breach of Rule 2 or Rule 5"), HEAD 276 ("Verify the file list … matches what you expected").

Not findings: the plan-mode text and its UNVERIFIED L1–L7 marks are byte-for-byte except the heading. The incidents ("findings…" refusal, the plan-check real case) are kept. The removed *What you never do* items are covered by `session-rules`, `push`, `security` Rule 5, `project-review`, `project-analyze` and `project-record`. The checklist commands and the snapshot commands are unchanged.

Covered: AGENTS.md; every heading of HEAD `project-manager` mapped to its new place (1b, 1c, checklist, plan mode, Stage 2/3/4/5/6/6b/7/8, parallel, without-subagents, Rule 4, *What you never do*); the full tracked diff; all five untracked files; pointer search across `plugins`, `README.md` and `AGENTS.md`; One-fact entries for round caps, verdict lines, new agent per round, round copies, plan mode, shared store, step numbers and master/sub-plans.

Not covered: a sentence-level word-diff of Stages 1c, 2, 5 and 8 (read side by side only); One-fact entries outside the touched paths (memory-sync, hooks, store layout); `host.example.md`; anything under `plan/`. No gates run, as instructed.

Tokens: about 75k.
