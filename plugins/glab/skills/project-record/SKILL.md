---
name: project-record
description: Project level — Record a pushed change: the area spec written from its plan folder, checked by glab:project-analyzer, then committed
argument-hint: "[plan slug]"
---

Stage 8 of `glab:project-manager` *The pipeline*. `$ARGUMENTS` is the slug; none → ask which — never the most recent, never a guess. Each dispatch below is made directly, as `glab:session-rules` Rules 0d and 5 say.

After Stage 7 has confirmed the push. What stays true moves into the spec of each area the change touched: `glab:project-plan` *Plan files are working files* is the rule, and `docs/specs/` the place unless the repo's `AGENTS.md` names another. The record changes the spec and nothing else. It never removes `plan/{slug}/` or an audit file: that is the repo's own `AGENTS.md` decision, carried out outside the record.

- Dispatch `glab:project-developer` for the record alone: the slug, the area specs `master.md`'s `## Record` names (`plan.md`'s, with no master; for a waiver, the ones you name), and any audit file it names as a source. It writes the spec from the folder's files, sub-plan folders included and the audit file, carries every follow-up still open, every binding decision and every incident with its source file and number, and changes nothing inside the folder.
- Dispatch `glab:project-analyzer` for the record check, at every tier: the spec diff against the folder's files and the audit file. `DIVERGES` → a new developer once (Rule 2), then the analyzer again on the fix; still `DIVERGES`: stop and tell the user.
- At full tier, one `glab:project-reviewer` pass on the spec diff alone — the target only, as in Stage 5. Its findings → a new developer once; the analyzer checks that fix too.
- Then `/glab:commit` with the spec files, and `/glab:push` on its own go-ahead.

A decision made at this stage goes in the dispatch and in the spec, not in `plan.md`: the folder is the record's source and does not change. A plan folder whose `master.md` — or `plan.md`, with no master — has no `## Record` predates the rule and is not recorded here.
