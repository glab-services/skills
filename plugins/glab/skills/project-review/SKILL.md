---
name: project-review
description: Project level — Review changes with the glab:project-reviewer agent against AGENTS.md
argument-hint: "[path or branch, empty for the working tree]"
---

Stage 5 of `glab:project-manager` *The pipeline*. The session that runs it — `glab:project-manager`, or a person who typed `/glab:project-review` — dispatches the **glab:project-reviewer** agent, as `glab:session-rules` Rules 0d and 5 say, with the input below. Target: $ARGUMENTS — if that is empty, the uncommitted working tree.

Show its report as `glab:project-manager` *The pipeline* says — to a user who typed the skill, verbatim: every finding and the verdict line. Do not summarise it, do not soften it, do not add praise, do not re-rank its severities.

Then stop. Do not fix anything, do not stage anything, do not commit. Inside the `glab:project-manager` pipeline, *After the verdict* below says where the findings go; run on its own, wait for the user to say what to do with them.

## The reviewer's input

**The reviewer is an external auditor.** Give it the target and nothing else — **not the slug, not the plan, not the findings, not what the plan intended.** From round 2 on it is a new reviewer (Rule 2) and gets two things more: the previous review round's findings, copied as it returned them, and the range of the fix — the tree id of the tree that round reviewed and of the tree now, each taken with `glab:project-analyze`'s snapshot, or two commit ids when the fix is committed. Still never the slug, the plan or the intent. It cares about correctness and security, not conformance; conformance was Stage 3. Do not defend the plan to it and do not re-rank its severities.

**Split by dimension**: correctness, security, concurrency, error handling, test quality, `AGENTS.md` conformance — one `glab:project-reviewer` dispatch each, on the model Rule 5 gives that role, deduplicated by you, not by them.

## After the verdict

`SHIP` → Stage 6, `/glab:commit`.

Findings → a `glab:project-develop` fix round, then the stages after it at that tier, then this review again. At full tier, Stage 3 after a review fix is one delta round per review fix, against the tree id the last `CONFORMS` measured, and the analyzer is also given the review findings the fix answered; it neither resets nor uses Stage 3's round cap. A `DIVERGES` there goes back to Stage 2 inside the same review round, and that fix goes on to Stage 5 without another Stage 3 round. **Review rounds are capped at 2 (`glab:session-rules` *Round caps*)**, at every tier. Before each review round, snapshot the tree it will review as `glab:project-analyze` does. Tell the reviewer which round this is and which is the last; what it answers in each is `glab:project-reviewer` *Re-reviews*. A last round's answer goes to the user, whichever it is. Rule 5's report check is for a report with missing fields or no clear verdict only.

A fix that grows past its finding, or lands in full-tier code, raises the tier.

When the reviewer reports that a round's findings sit mostly in the previous round's fix (`glab:project-reviewer` *Re-reviews*), cut scope rather than adding another guard.
