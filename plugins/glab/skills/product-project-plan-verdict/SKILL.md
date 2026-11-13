---
name: product-project-plan-verdict
description: Product level — Write the verdict on a project's reported plan, ACCEPTED or REJECTED with its reason, to the shared store, and tell the project session it is there.
argument-hint: "[project]"
---

The entry point of stage P5 of `glab:product-manager` *The product pipeline*. `$ARGUMENTS` is `<project>`. None → ask which one — never the most recent, never a guess.

**The verdict follows the audit** (stage P4):

- `NO CONFLICT` → `ACCEPTED`, the reason one line naming the rules checked;
- `CONFLICTS: <n>` → `REJECTED`, each conflict one line of the reason, with the rule file it breaks.

**Write it.** The session writes the reason to a file in its temp directory and runs:

    "${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" verdict <store> <project> ACCEPTED|REJECTED product-manager <reason file>

It writes `briefs/<project>/verdict.r<n>.md` for the latest report and prints its path; show the path, or the `REFUSED:` line.

**At the cap.** The refusal `two REJECTED verdicts since the last ACCEPTED; the next verdict is by user` → `glab:product-manager` *The cap*.

**Then** tell the project session that the verdict is there — `SendMessage` to the name it was started under, or, for a CLI session that has stopped, a resume by its full session id (`glab:product-manager` *Starting project sessions*) — or tell the user, who tells it.
