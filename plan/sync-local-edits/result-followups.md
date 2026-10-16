# Result: sync-local-edits follow-ups

This change is normal tier. It has no separate `plan.md`: `follow-ups.md` (12 findings) is the
findings list, and the coordinator's dispatch message, with decisions D1-D12, is the plan. The
change sits on top of HEAD 0dec5e2. Nothing is staged or committed, and nothing under `~/.claude`
was touched.

## Decisions

The manager made these under Rule 3, as recorded in the dispatch:

- D1 (#1): sessions settle a seam through the channel `docs/constants.md` names, and the user relays when it names none. A decision from another session binds only when it arrived through that channel and is recorded as a `## Decisions` line naming the session.
- D2 (#2): a `plan.md` with no tier line is full tier. This is stated once in manager *Pick the tier*, and `commands/develop.md` points to it where it decides approval.
- D3 (#3): Rule 3's third bullet keeps `glab:security`'s stop list. It now credits the push confirmation to `/glab:push` and *What you never do*, and the destructive-action confirmation to security's "Destructive operations are proven" rule for unrecoverable targets.
- D4 (#4): bootstrap stays on the review-round-cap list. The four ask-conditions become a known case that names every file stating them.
- D5 (#5): `commands/integrate.md:10` matches the integrator agent: it runs after `/glab:analyze` at full tier and after `/glab:develop` at normal. Normal tier runs the milestone test; full tier runs the whole suite.
- D6 (#6): `develop.md:61` now says "re-running the plan's next stage".
- D7 (#7): a `waived.md` goes from `/glab:develop` to `/glab:integrate`, because there is nothing for `/glab:analyze` to measure.
- D8 (#8): `analyze.md:18` now says "If the plan is amended".
- D9 (#9): the planner decides and records each choice with its reason. The manager reviews those lines and may overrule one, recording the overrule as a new line. Manager, plan-first and the Rule 0c seam note now state this one rule.
- D10 (#10): the Spec row stays and is now defined: written after Stage 5 and before Stage 6, by the developer, dispatched by the manager, at the location AGENTS.md or `docs/constants.md` names. At full tier, "checked by independent readers" means one reviewer pass on the entry alone. A repo that keeps specs but has no rule for removing plan folders keeps its plans.
- D11 (#11): the 1b row's "Leaves on" now reads "`BUILDABLE`, or one amendment at normal tier".
- D12 (#12): bootstrap now points to *Pick the tier* for the full-tier triggers, names the four as Rule 3's ask-conditions and says manager names the other escalations. `review.md` makes clear that Stage 5 sends findings back. The hook text adds "at full tier" with a pointer.

## Items

| # | Status | File:line | Before | After |
|---|---|---|---|---|
| 1 | fixed | `plugins/glab/skills/manager/SKILL.md:113` | `settle it with the session on the other side, directly.` | `settle it with the session on the other side, through the channel `docs/constants.md` names — when it names none, the user relays.` |
| 1 | fixed | `…/manager/SKILL.md:114` | `binding once it is recorded` | `binding once it arrived through that channel and is recorded` |
| 2 | fixed | `…/manager/SKILL.md:139` | (end of the tier-line sentence) | adds: `A `plan.md` with no tier line — an older plan, or one the user handed over — is full tier.` |
| 2 | fixed | `plugins/glab/commands/develop.md:15` | `**Approval** → full tier only. Nothing records it,` | `**Approval** → full tier only; a plan with no tier line is full (`glab:manager` → *Pick the tier*). Nothing records it,` |
| 3 | fixed | `…/manager/SKILL.md:106` | `Its stop list, and confirmation before every destructive action and every push, hold at every tier.` | `Its stop list holds at every tier, and so does its *Destructive operations are proven* rule: an unrecoverable target means stop and ask. Push waits for the user's go-ahead at every tier — `/glab:push` and *What you never do* say so.` |
| 4 | fixed | `AGENTS.md:103-111` | the round-cap list without bootstrap; no ask-conditions case | bootstrap is back on the round-cap list, and there is a new case: `the four ask-conditions of `glab:manager` Rule 3 — destructive, costs money, exposes real data, changes what the product is (manager, plan-first, commands/plan.md, commands/develop.md, and their count, four, in bootstrap)` |
| 5 | fixed | `plugins/glab/commands/integrate.md:10` | `This runs after `/glab:analyze` and before `/glab:review`.` | `This runs after `/glab:analyze` at full tier or `/glab:develop` at normal, and before `/glab:review`.`, ending with: `At normal tier it runs the test that proves the plan's milestone; the whole suite is for full tier.` (the same words as manager Stage 4) |
| 6 | fixed | `…/develop.md:61` | `re-running `/glab:analyze`.` | `re-running the plan's next stage.` |
| 7 | fixed | `…/develop.md:67` | (ends `… `/glab:integrate` at normal.`) | adds: `A `waived.md` has no plan and no tier: it goes to `/glab:integrate`, since `/glab:analyze` has nothing to measure.` |
| 8 | fixed | `plugins/glab/commands/analyze.md:18` | `If I do amend it,` | `If the plan is amended,` |
| 9 | fixed | `…/manager/SKILL.md:58-60` (Rule 0c seam note) | (ends `… rejects in plans.`) | adds: `On choices both say one thing: the planner decides each and records it under `## Decisions` with its reason, and you review those lines and may overrule one, recording the overrule as a new line.` |
| 9 | fixed | `…/manager/SKILL.md:210` | `A choice comes back with its recommendation; you decide it under Rule 3 and record it.` | `A choice it decides and records under `## Decisions` with its reason; you review those lines under Rule 3 and may overrule one, recording the overrule as a new line.` |
| 9 | fixed | `plugins/glab/skills/plan-first/SKILL.md:56` | `… the choice and why. `glab:manager` Rule 3 is the rule.` | `… the choice and why. The manager reviews those lines and may overrule one, recording the overrule as a new line. `glab:manager` Rule 3 is the rule.` |
| 10 | fixed | `…/manager/SKILL.md:159` (new paragraph after the tier table) | — | `The spec entry is written after Stage 5 and before Stage 6: you dispatch the `glab:developer` agent to write it where AGENTS.md or `docs/constants.md` says specs live. At full tier, "checked by independent readers" means one reviewer pass on the entry alone.` |
| 10 | fixed | `…/plan-first/SKILL.md:154` | `A repo that keeps no specs keeps its plans.` | `A repo that keeps no specs, or keeps specs but has no rule for removing plan folders, keeps its plans.` (`Never remove an untracked plan file.` is kept) |
| 11 | fixed | `…/manager/SKILL.md:127` | `| — | `BUILDABLE` |` | `| — | `BUILDABLE`, or one amendment at normal tier |` |
| 12 | fixed | `plugins/glab/skills/bootstrap/SKILL.md:46-48` | `its Rule 3 names the four cases that go to the user.` | `its Rule 3 names the four ask-conditions that go to the user, and the skill names its other escalations where they arise.` |
| 12 | fixed | `…/bootstrap/SKILL.md:94-95` | `That is the **full** pipeline, for migrations and security-sensitive changes.` | `That is the **full** pipeline, for the changes `glab:manager` → *Pick the tier* makes full tier.` (a pointer, not a second copy of the list) |
| 12 | fixed | `plugins/glab/commands/review.md:12` | `inside the `glab:manager` pipeline they go back to `/glab:develop` (Stage 5).` | `inside the `glab:manager` pipeline, Stage 5 sends them back to `/glab:develop`.` |
| 12 | fixed | `plugins/glab/scripts/manager-bootstrap.sh:17` | `… -> commit -> push, each stage …` | `… -> commit -> push at full tier (`glab:manager` -> *Pick the tier* says how much runs), each stage …` |

Version: `plugins/glab/.claude-plugin/plugin.json` goes from 0.2.0 to 0.2.1.

## Blocked

None. Two points are noted but were not decided, because no decision covered them:
- D10 does not say what happens when neither AGENTS.md nor `docs/constants.md` names a spec location. The text leaves that case alone.
- D5 and D7 together send a waiver to `/glab:integrate` after `/glab:develop`. `integrate.md:10` names only the tiered paths and does not mention the waiver.

## Unplanned changes

None.

## Searches and coverage (AGENTS.md *Tests*: a list, not a number)

- **Ask-conditions (D4).** `command grep -rnE 'costs money|exposes real data|what the product is' README.md AGENTS.md plugins/ .claude-plugin` (run before the AGENTS.md edit) hit:
  - `manager/SKILL.md:94-96`
  - `plan-first/SKILL.md:57`
  - `commands/plan.md:13`
  - `commands/develop.md:14`

  Separately, `ask-condition|four that are mine|four cases` found the count in `develop.md:63` and `bootstrap:46`. All are named in the new AGENTS.md case. `develop.md` is listed once; it states both the conditions and the count.
- **Bootstrap still states caps (D4).** Line 94 (now 96) says "Normal work runs a one-page plan, one analysis and one review".
- **Prefixes.** Over the 31 lines this change adds:
  - Bare identifiers: none. The pattern is ``(^|[ `(])/(plan|analyze|develop|integrate|review|commit|push|ship)\b`` or a backticked bare component name; it found nothing (`rc=1`) and matched a known positive (count 1).
  - Doubled prefix: `glab:glab:|glab: *glab:|memory-sync:glab:` found nothing (`rc=1`) and matched a known positive (count 1).
- **Hook, through the `hooks.json` command form** (`"${CLAUDE_PLUGIN_ROOT}"/scripts/manager-bootstrap.sh`, with `CLAUDE_PLUGIN_ROOT=$PWD/plugins/glab`):
  - With jq: `rc=0`, 0 bytes on stderr. `hookEventName` is `SessionStart`, and `additionalContext` is 2252 characters, under the 10,000 cap. The text contains "at full tier".
  - Without jq: `env -i PATH=<dir holding only a bash symlink>`, where `command -v jq` printed `jq absent`. The run gave `rc=0` and 0 bytes on stderr, and the plain-text fallback is byte-identical to the JSON `additionalContext`.
- **Hook and `glab:bootstrap` agree.** Both now give the full pipeline as the full-tier case and point to *Pick the tier*.
- The Markdown changes prescribe no new command to run. No test case covers them, which AGENTS.md accepts for Markdown.

## Gates (the full AGENTS.md block, `TMPDIR=/data/tmp/claude`, `CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`)

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    test rc=0 ok-lines=35 non-ok:
    PASS 35/35
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    plugins/memory-sync/scripts/memory-sync.sh:1
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    README.md:1
    rc=0
    rc=1
    cfg-removed

All green as AGENTS.md defines it.

## Blast radius

What a session with glab 0.2.1 now does differently:
- It settles seams with other sessions only through the channel `docs/constants.md` names, or through the user when none is named. It no longer treats a relay that arrived any other way as binding.
- It treats a plan with no tier line as full tier, so it asks for approval and runs conformance analysis.
- It sends a waiver from `/glab:develop` to `/glab:integrate`. After an amendment it re-runs the plan's next stage, not always `/glab:analyze`.
- `/glab:integrate` runs only the milestone test at normal tier.
- The planner decides choices itself, and the manager reviews and may overrule them.
- It writes a spec entry between review and commit, through the developer. At full tier that entry gets one reviewer pass.
- The SessionStart hook text now says the full pipeline is the full-tier case.

No guard is weakened: push confirmation, gates run by the manager, the security stop list and local-only integration are unchanged. Installed copies get this only after a plugin update to 0.2.1. The user's `~/.claude` copies still carry the older text.

## Rollback

Nothing is committed. `git diff HEAD -- plugins/glab AGENTS.md` shows the whole change. Reverting it restores 0dec5e2. Once committed, `git revert <commit>` does the same, but a user who has already updated needs a later version (0.2.2) for the revert to reach them.
