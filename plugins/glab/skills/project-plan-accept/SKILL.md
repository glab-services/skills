---
name: project-plan-accept
description: Project level — Accept a project plan: its tier, a few mechanical checks, a question's answer, then the approval and the master's hash
argument-hint: "[plan slug]"
---

`$ARGUMENTS` is the slug, or a sub-plan `<slug>/<nn>-<name>`. With none, ask which plan; never take the most recent, never guess. The project manager runs this when the planner returns. When the user handed over a plan, run it on theirs.

**The tier.** The planner writes the tier line as the first line of `plan.md` (`glab:project-plan` Step 0). Accept it, or send the plan back to be raised. A raise after acceptance is a `## Decisions` overrule line. Only the user lowers a tier.

### The checks — by search, never by reading the plan (Rule 2)

When one fails, say which and send the plan back to a new planning agent.

1. **A master.** `grep -c '^## \(Request\|Goals\|Out of scope\|Final check\|Record\)$' plan/{slug}/master.md` prints `5`. With sub-plans, `index.md` has one line per sub-plan folder.
2. **Within its size.** `wc -c` on each of `master.md`, `plan.md`, `index.md` and `evidence.md` that exists: each is at most 49152 bytes (48 KB, `glab:project-plan` Step 3). Over the cap with no `- size:` line in `plan.md`: send it back. With one, accepting it or not is your Rule 3 choice.
3. **A brief or an issue, quoted.**
   - **From a brief:** `grep -cE '^- brief: briefs/[a-z0-9-]+/brief\.md sha256 [0-9a-f]{64}$' plan/{slug}/master.md` prints `1`.
   - **From an issue** (`glab:project-issue`), all four of these hold. Anything else goes back, because the master must quote exactly the issue that was fetched.
     - `grep -cE '^- issue: [^ /]+/[^ #]+#[0-9]+ sha256 [0-9a-f]{64}$' plan/{slug}/master.md` prints `1`.
     - ``grep -E '^- issue: ' plan/{slug}/master.md | grep -cF " sha256 $(sha256sum plan/{slug}/issue.md | cut -c1-64)"`` prints `1`.
     - `LC_ALL=C awk 'f && !/^> /{exit} f{print substr($0,3)} /^- issue: /{f=1}' plan/{slug}/master.md | cmp - plan/{slug}/issue.md` prints nothing.
     - The brief grep prints `0`.

### A question blocks; a decision does not

A Rule 3 question stops its plan. Bring it to the user with its full context. When they answer, **write the answer into `plan/{slug}/questions.md` yourself**, or into `after-verdict.md` once the plan has been reported to product (`glab:project-plan-report`). That file is how the developer sees it. Never close a question by assuming an answer, and never turn a choice of your own into one.

### The approval

- **Who approves:**
  - at full tier, and whenever the work split: the user, explicitly;
  - at normal tier with no sub-plans: report the tier and the decisions, and go on.
- **The `## Approval` line.** Then write `## Approval`, the last section of `master.md`, as one line. Either:
  - `- approved by the user, <date>: "<their words>"; base <git rev-parse --short HEAD>`, or
  - `- accepted at normal tier, reported to the user, <date>; base <sha>`.
- **The hash.** From the repo root: `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256`.
- **Full-tier plans.** At full tier the user also approves each `plan.md`. End it with its own `## Approval` line in the master's form.

**The master is constant once approved:** never edit it after its hash. When the user changes the request:
1. Remove `master.sha256`.
2. Dispatch a planning agent, granted the new master, to write it as `glab:project-plan` *Amending* says.
3. Write a new `## Approval` line and a new hash.
