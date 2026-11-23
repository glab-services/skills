---
name: verdict
description: Write the verdict on a project's reported plan, ACCEPTED or REJECTED with its reason, to the shared store through plan-gate.sh, and tell the project session.
argument-hint: "[project]"
---

Stage P5. `$ARGUMENTS` is `<project>`; none → ask, never guess.

- `NO CONFLICT` → `ACCEPTED`, the reason one line naming the rules checked.
- `CONFLICTS: <n>` → `REJECTED`, one line per conflict, with the rule file it breaks.

Write the reason to a file in the temp directory, then run:

    "${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh" verdict <store> <project> ACCEPTED|REJECTED product-manager <reason file>

Show the path it prints, or the `REFUSED:` line. The refusal `two REJECTED verdicts since the last ACCEPTED; the next verdict is by user` → `glab-product:manager` *The cap*.

Then tell the project session the verdict is there — `SendMessage` to its name, or a resume of a stopped CLI session — or tell the user, who tells it.
