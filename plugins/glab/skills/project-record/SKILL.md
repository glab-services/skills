---
name: project-record
description: Project level — Record a pushed change: the area spec and feature pages written from its plan folder, checked by glab:project-analyzer, then committed
argument-hint: "[plan slug]"
---

Stage 8 of `glab:project-manager` *The pipeline*. `$ARGUMENTS` is the slug; none → ask which — never the most recent, never a guess. Each dispatch below is made directly, as `glab:session-rules` Rules 0d and 5 say.

After Stage 7 has confirmed the push. What stays true moves into the spec of each area the change touched: `glab:project-plan` *Plan files are working files* is the rule, and `docs/specs/` the place, with feature pages in `docs/features/`, unless the repo's `AGENTS.md` names another. The record changes the specs and feature pages and nothing else. It never removes `plan/{slug}/` or an audit file: the manager does, once the record has landed and only on the user's word (`glab:session-rules` Rule 2). A *Records* line — a spec's, or a roadmap page's (`glab:product-plan` *The roadmap*) — is `- <date> · <slug> · <first> · <last> · <branch> · <PR/MR, or pushed without a PR>`: it names the slug, and the change's commits on the pushed branch by both ends, `<first>` and `<last>` (two short shas, not a range), the branch, and the PR/MR when one exists, because the folder is not kept; a squash or rebase merge can give the commits new shas, so the branch and the PR are what to look up.

Commit the record on the change's branch, after its push and before its merge, so that it lands with the change it records, in the same merge. A record on another branch still lands, and `glab:session-rules` Rule 2 lists its folder for removal the same way.

- Dispatch `glab:project-developer` for the record alone: the slug, the area specs `master.md`'s `## Record` names (`plan.md`'s, with no master; for a waiver, the ones you name), and the feature pages `## Record` names, and any audit file it names as a source. It writes the spec from the folder's files, sub-plan folders included and the audit file, carries every follow-up still open, every binding decision and every incident with its source file and number, and changes nothing inside the folder.
- Dispatch `glab:project-analyzer` for the record check, at every tier: the spec and feature-page paths — its record check says how it reads them — against the folder's files and the audit file. `DIVERGES` → a new developer once (Rule 2), then the analyzer again on the fix; still `DIVERGES`: stop and tell the user.
- At full tier, one `glab:project-reviewer` pass on the uncommitted spec and feature-page paths alone — the target only, as in Stage 5. Its findings → a new developer once; the analyzer checks that fix too.
- Then `/glab:commit` with the spec files and feature pages, and `/glab:push` on its own go-ahead.

A decision made at this stage goes in the dispatch and in the spec, not in `plan.md`: the folder is the record's source and does not change. A plan folder whose `master.md` — or `plan.md`, with no master — has no `## Record` predates the rule and is not recorded here.
