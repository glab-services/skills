# Result — sync-local-edits

There is no `plan.md` for this change. The dispatch message was the specification:
take the user's edits of 2026-10-08 to their local copies under `~/.claude` (each
edit is `diff -u <(git show bc2e399:<path>) ~/.claude/<path>`) and apply them to
`plugins/glab/<path>`, with identifiers in the `glab:` prefixed form. Nothing under
`~/.claude` was written; it was only read.

Scope check: of the files under `agents/`, `commands/` and `skills/`, exactly the 12
named in the dispatch differ from bc2e399 locally. The others are byte-identical
(`same` for committer, integrator, commit, integrate, push, plan-template, comments, security).

## Stages

| File | User hunks | Ported | Changed lines (result) |
|---|---|---|---|
| `plugins/glab/agents/analyzer.md` | 1 | 1 | 16-17 |
| `plugins/glab/agents/developer.md` | 1 | 1 | 16-18 |
| `plugins/glab/agents/reviewer.md` | 1 | 1 (merge M1) | 90, 92, 98 |
| `plugins/glab/commands/analyze.md` | 1 | 1 | 14 |
| `plugins/glab/commands/develop.md` | 2 | 2 (merge M2) | 14-15, 61, 63, 67 |
| `plugins/glab/commands/plan.md` | 1 | 1 | 13-14, 18 |
| `plugins/glab/commands/review.md` | 1 | 1 | 12 |
| `plugins/glab/commands/ship.md` | 1 | 0, already present (M3) | none |
| `plugins/glab/skills/audit/SKILL.md` | 1 | 1 | 47 |
| `plugins/glab/skills/bootstrap/SKILL.md` | 4 | 4 (placement P1) | 15, 35-39, 46-47, 93-96, 99-100, 105, 204-206 |
| `plugins/glab/skills/manager/SKILL.md` | 12 | 12 | 3, 18, 65, 72, 87-113, 124-129, 135-156, 198, 206-224, 278-286, 326-327, 340, 351-353, 365, 372-373 |
| `plugins/glab/skills/plan-first/SKILL.md` | 6 | 6 | 3, 11, 19, 51-65, 74-82, 154, 178-180 |
| `plugins/glab/.claude-plugin/plugin.json` | — | version 0.1.0 → 0.2.0 | 3 |

All done. No hunk BLOCKED.

Identifiers the new text brings in, in prefixed form: `glab:manager` (develop.md 14, 61, 63; plan.md 14;
review.md 12; audit 47; bootstrap 95; plan-first 19, 56), `/glab:integrate` (analyze.md 14, develop.md 67),
`/glab:analyze` (develop.md 67), `/glab:develop` (review.md 12), and in manager `glab:security` (Rule 3) plus
`/glab:plan`, `/glab:analyze`, `/glab:review`, `/glab:push` in the rewritten table rows and Stage 7. Inside
`glab:manager` itself, "Rule 3", "Rule 1", "*Pick the tier*" stay unprefixed (self-references).
Bootstrap "its Rule 3" names no identifier and stays as written. Pipeline stage labels stay bare.
A search of every added line for a bare backticked component name or bare slash command found none
(`rc=1`; the same pattern matched a known positive, count 1).

How it was applied: plan-first and manager had no repo change since bc2e399 apart from prefixes, so
the local file was taken and the prefixes put back. Check: stripping `glab:` gives the local file
byte for byte, and the result-vs-HEAD diff has the same hunks as local-vs-bc2e399. One slip came up
and was fixed before installing: the regex turned `plan/{slug}/plan.md` into `plan/{slug}/glab:plan.md`
in two manager lines. After the fix, every `/glab:` in the file has a backtick in front of it. The other 10 files were
edited hunk by hunk with exact-match replacements, each asserted to match once.

### Merges (rule 2)

**M1 — reviewer.md re-review section.** Repo and user both changed the four-round text.
- bc2e399: `## Re-reviews — four rounds, then a decision` / `A change gets **four rounds**, … By round four … there is no round five.` / `At round four pick one`
- repo HEAD: `three rounds` / `**three rounds**` / `By round three … there is no round four.` / `At round three pick one`
- local: `capped rounds` / `**at most three rounds** — one at normal tier — … The caller tells you which round this is and which is the last. In the last round … there is no round after it.` / `At the last round pick one`
- result: the local wording. The repo version holds no fact the local one does not (both say three).

**M2 — develop.md, `questions.md` bullet (line 14).**
- bc2e399: `These files have no single convention in this repo, so do not try to decide mechanically …`
- repo HEAD: `These files have no single convention, so do not try to decide mechanically …` (repo removed "in this repo")
- local: `These files have no single convention in this repo, so do not refuse on stale text. A question that is mine — …`
- result: `These files have no single convention, so do not refuse on stale text. A question that is mine — … (`glab:manager` Rule 3).` The repo's removal is kept and the user's new sentence goes in after it.

**M3 — ship.md round cap.** The local edit (`Four rounds` → `Three rounds`, `round four`/`five` → `three`/`four`)
is word for word the repo change already at HEAD. Nothing to port, and the file is not modified.

**P1 — bootstrap.md step 1, where the new paragraph goes.** Repo and user each put a paragraph straight after
the AGENTS.md paragraph ("… round, not in saved time."): the repo's `~/.claude/host.md` paragraph, the user's
`docs/constants.md` paragraph. In the result the host.md paragraph comes first and the constants paragraph second,
just before `## 2.`. Why: the host.md text says "before the first command", so it stays first; this order keeps the
repo's leading context and the user's trailing context; and the mechanical check then shows the host.md block as the
same hunk that the repo-only diff shows. The user's heading change (`… and the constants`) went in as written, even
though the repo's host.md read also sits in this step. Rule 3 rules out rewording the heading to mention it.

### Mechanical check

The check: the lines of `diff <(sed 's/glab://g' plugins/glab/<path>) ~/.claude/<path>` were compared with the
lines of `diff <(sed 's/glab://g' <(git show HEAD:plugins/glab/<path>)) <(git show bc2e399:<path>)` (only the `<`/`>` lines).
- **Same lines, rc=0:** analyzer, developer, analyze, plan, review, audit, bootstrap, manager, plan-first.
  Audit, manager and plan-first leave no difference at all against the local file. In the others, what is left is
  only repo work from after bc2e399: the `(or CLAUDE.md if the repo has none — say so)` fallback, the host-file
  move and de-localised wording in bootstrap ("in one repo", "in a real session", grep and temp-file hazards,
  description), and in analyzer "in one repo `make lint`".
- **reviewer.md, rc=1:** the left-over difference is the HEAD-vs-bc2e399 diff minus the three re-review lines
  (M1). The local text replaced them, so they no longer differ. The lines still left are all repo work: the
  no-AGENTS.md fallback, the `agreement:` line, loading `glab:security`/`glab:comments`, the correctness/compliance
  wording, and the temp-directory sentence.
- **develop.md, rc=1:** the left-over difference is line 14 only, i.e. M2. The repo's "in this repo" removal
  now sits in the user's new sentence.
- **ship.md, rc=1:** the repo-only round-cap line drops out because local equals HEAD there (M3). What remains
  is the CLAUDE.md fallback on line 10.

## Blocked

None.

## Unplanned changes

None. No consequential edit was needed: none of the hits below makes two files contradict each
other in a way that can be fixed without choosing new wording (see *Not done*).

## Tests

No test covers Markdown payload. AGENTS.md says Markdown "has no gate" and is checked by the commands
it prescribes and by searches. The ported text prescribes no command to run. The searches run were:
the per-file mechanical check above, the bare-identifier search over added lines (none found), and the
consistency searches below. `tests/memory-sync.test.sh` does not exercise the glab plugin. It was run
as a gate and covers none of these steps.

## Gates

`export TMPDIR=/data/tmp/claude`; `CLAUDE_BIN=/home/pvhv/.claude/remote/ccd-cli/2.1.299-686c67ec1014`
(found with `readlink /proc/$PPID/exe`). Both blocks ran exactly as AGENTS.md writes them, with a throwaway `CLAUDE_CONFIG_DIR`
that the block itself removed. Afterwards no `claude-config.*` was left under `/data/tmp/claude` (count 0).

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0                                  # shellcheck, no findings
    ok T01 … ok T35 (35 ok lines, 1 non-ok line which is) PASS 35/35

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

All green as AGENTS.md defines it. Component counts are unchanged.

## Version

`plugins/glab/.claude-plugin/plugin.json` `"version": "0.1.0"` → `"0.2.0"`. README.md and AGENTS.md do not
state the glab version: a search for `version|0\.1\.0|0\.2\.0` hits only README:57-58 and AGENTS.md:130-132,
which talk about versions in general. `0.1.0` appears nowhere else in `.claude-plugin`, `plugins/glab`, README or AGENTS (`rc=1`).
`docs/constants.md` was not created. This repo has no `docs/` directory.

## Contradictions reported, not changed

The user's local copies say the same thing in every case below; none of these lines was edited locally.

1. `plugins/glab/commands/analyze.md:15` "**Changing the plan is my call, never yours.**" and
   `plugins/glab/skills/manager/SKILL.md:334` "change the plan (the user's call, never yours)" disagree with the new
   `plugins/glab/commands/develop.md:61`: "Amending the plan is a `glab:manager` Rule 3 decision — yours when it
   is an engineering choice, mine when it meets an ask-condition". This is the one real cross-file contradiction.
   It was not changed, because fixing it means choosing which of the user's texts wins and writing new wording.
   That is the user's call.
2. `plugins/glab/commands/develop.md:2` (description) "Implement an approved plan … then hand off to /glab:analyze".
   Its own body (15, 67) now says approval is full-tier only and the handoff is `/glab:integrate` at normal tier.
3. `plugins/glab/agents/developer.md:3,7` "an approved plan": a normal-tier plan has no approval.
4. `plugins/glab/agents/integrator.md:3` "after /glab:analyze and before /glab:review". At normal tier, conformance
   analysis (Stage 3) does not run, so integrate follows develop. `plugins/glab/agents/analyzer.md:3`
   "Use after /glab:develop and before /glab:review" is still literally true, now that integrate sits between them.
5. `plugins/glab/commands/ship.md:32` "**Three rounds, then a decision** … By round three … no round four" is a
   fixed count with no tier qualifier. Elsewhere it is now "at most three — one at normal tier".
6. `AGENTS.md:103-107` lists `plugins/glab/skills/bootstrap/SKILL.md` among the files that state the review round
   cap. After this change bootstrap no longer states a number: it points to `glab:manager` → *Pick the tier*.
   This is not a contradiction, but the list is now out of date.
7. `plugins/glab/scripts/manager-bootstrap.sh:17` "plan -> develop -> analyze -> integrate -> review -> commit -> push"
   is the full pipeline with no tier. Item 3 there ("Every agent you dispatch reads `AGENTS.md` first") does not
   mention `docs/constants.md`, which the edited bootstrap step 1 and manager Rule 0a now add. AGENTS.md makes the
   session-start rules one fact between this script and `glab:bootstrap`. The script leaves things out but contradicts nothing.
8. Older "questions" wording: `plugins/glab/commands/plan.md:2` "Size, analyze, question and plan",
   `plugins/glab/skills/audit/SKILL.md:21` "carries analysis through questions, plan, …",
   `plugins/glab/skills/manager/SKILL.md:53` "the `findings.md` / `questions.md` / `plan.md` structure",
   `plugins/glab/skills/plan-first/SKILL.md:156` "Reuse the same folder for findings, questions, and plan".
   None of them says `questions.md` is mandatory.
9. `plugins/glab/skills/manager/SKILL.md:332` "Maximum 4 develop→analyze rounds" has no qualifier, but it sits under
   Stage 3, which now opens "**Full tier only.**". This is consistent.
10. `AGENTS.md:129` "`plan/` is tracked and permanent" is this repo's own rule, not payload. The new plan-first text
    ("Plan files are working files … A repo that keeps no specs keeps its plans") leaves it to the repo's own rule.
    It was left as it is.

No README.md statement contradicts the edits (searched: analy|review|approv|tier|constants|question|plan/).

## Blast radius

A session with glab 0.2.0 loaded now:
- reads `docs/constants.md` at bootstrap step 1, and tells dispatched agents to read it (manager Rule 0a). Where
  the file is missing it says so once and does not write one. The one-line check now says "agreement and constants".
- picks a tier (trivial / normal / full) at Stage 1 and writes it as the first line of `plan.md`. Normal tier is a
  one-page plan with no user approval, one plan-analysis pass, no conformance analysis (Stage 3), the milestone
  test at integrate, and one review round. Full tier keeps the old caps (1b ≤2, 3 ≤4, review ≤3) and the user's approval.
- under Rule 3, decides engineering choices itself and records them under `## Decisions`. It asks the user only when
  a choice is destructive, costs money, exposes real data or changes what the product is, with at most one question
  per plan as the target. `/glab:plan` and plan-first Step 2 now sort gaps into fact, choice and question.
- under Rule 4, treats a session as owning one surface (named in `docs/constants.md`): it settles seams with the
  other session directly, and a relayed decision binds once it is recorded.
- after `CONFORMS`, goes to `/glab:integrate` (it used to go to `/glab:review`). `/glab:review` findings go back to
  `/glab:develop` when the pipeline runs. A developer `PLAN WRONG` no longer always goes to the user.
- shows the `## Decisions` lines at `/glab:push`. The reviewer agent works to a caller-named last round.
- plan-first no longer calls plan files permanent: they become a spec entry, and then the repo's own rule decides.

Installed copies pinned at 0.1.0 get none of this until the user runs a plugin update to 0.2.0.
Nothing was installed or updated by this work.

## Rollback

Nothing is committed. `git diff -- plugins/glab` shows the whole change: 12 files, 137+/72-. Reverting it puts
0.1.0 and the earlier text back. Once committed, `git revert <commit>` does the same. A user who has already
updated to 0.2.0 would need a 0.2.1 (or later) for the revert to reach them.

## Follow-ups

None written to `follow-ups.md`. The contradictions above are for the user to decide.

## Not done

- No commit, push or staging.
- `~/.claude/skills/sync-memory` and `~/.claude/skills/synced` were not looked at beyond the directory listing. They are out of scope.
- `UNVERIFIED: that the user's local edits are exactly the 2026-10-08 change — inferred from the dispatch message
  and the file mtimes (2026-10-08 16:18), not from any record of the edit.`

---

# Second set: alignment edits (the coordinator's re-dispatch)

## Decisions

- The coordinator decided this as manager and asked for it to be recorded here. The contradictions reported above are resolved in favour of the user's newer text (tiers, Rule 3). The reason given: the 2026-10-08 edits are the user's latest statement of intent, and the stale lines are places those edits did not reach. Items 8 (older "questions" wording that is not wrong) and 9 (the repo's own `plan/` rule) stay as they are. This is the manager's decision, not the user's approval.

## Alignment edits (separate from the port; the version is not raised again, 0.2.0 covers both)

Four of these files also carry port hunks: `commands/analyze.md`, `skills/manager/SKILL.md`, `commands/develop.md` and `agents/developer.md`. Splitting them into two commits needs hunk-level staging. Every hunk listed below is a separate hunk from the port hunks.

1. `plugins/glab/commands/analyze.md:15`
   - before: `**Changing the plan is my call, never yours.**`
   - after: `**Changing the plan is a `glab:manager` Rule 3 decision** — yours when it is an engineering choice, mine when it meets an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer.` This is develop.md:61's wording.
   - `plugins/glab/skills/manager/SKILL.md:334`
   - before: `change the plan (the user's call, never yours), or cut the scope.`
   - after: `change the plan (a Rule 3 decision — yours when it is an engineering choice, the user's when it meets an ask-condition — made through the planning agent, recorded under `## Decisions`, never made by the developer), or cut the scope.` "Rule 3" is not prefixed because the file is referring to itself.
2. `plugins/glab/commands/develop.md:2` (description)
   - before: `Implement an approved plan through glab:developer agents — glab:plan-first steps 5 to 7 — then hand off to /glab:analyze`
   - after: `Implement a plan (approved, at full tier) through glab:developer agents — glab:plan-first steps 5 to 7 — then hand off to /glab:analyze at full tier or /glab:integrate at normal`
3. `plugins/glab/agents/developer.md:3`
   - before: `Implements an approved plan from plan/{slug}/,`
   - after: `Implements a plan (approved, at full tier) from plan/{slug}/,`
   - `plugins/glab/agents/developer.md:7`
   - before: `You build what an approved plan says, and nothing else.`
   - after: `You build what a plan says — approved, at full tier — and nothing else.`
4. `plugins/glab/agents/integrator.md:3`
   - before: `Use from /glab:integrate, after /glab:analyze and before /glab:review.`
   - after: `Use from /glab:integrate, after /glab:analyze at full tier or /glab:develop at normal, and before /glab:review.`
5. `plugins/glab/commands/ship.md:32`
   - before: `**Three rounds, then a decision.** Tell the reviewer which round this is, and scope … By round three it must answer … — there is no round four.`
   - after: `**At most three rounds — one at normal tier — then a decision.** Tell the reviewer which round this is and which is the last, and scope … In the last round it must answer … — there is no round after it.`
   - The rest of the paragraph is unchanged. "which is the last" is there because `glab:reviewer` (reviewer.md:92) now expects its caller to say which round is the last.
6. `AGENTS.md:103-105`, the review-round-cap entry in the "one fact, one value" list
   - before: it listed reviewer.md, ship.md, manager/SKILL.md and bootstrap/SKILL.md.
   - after: bootstrap is dropped. Bootstrap no longer states a number; its line 95 points to `glab:manager` → *Pick the tier* "has the table and the round caps".
   - Proof: after the port, a search of bootstrap for `round|Max|max [0-9]` finds only line 26 ("correction round") and line 95.
   - The three files that remain all state three: reviewer.md:92, ship.md:32, and manager/SKILL.md:151 and 351.
7. `plugins/glab/scripts/manager-bootstrap.sh:14` (item 1 of the injected text)
   - added after the CLAUDE.md fallback sentence: `Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.`
   - These are the bootstrap skill's own step-1 words. The message attributed "where the repo has one" to the bootstrap skill, but that phrase is `glab:manager` Rule 0a's wording for dispatched agents, not bootstrap's.
   - The constants read went into item 1, the session's own read, which matches bootstrap step 1. Item 3 (dispatch) was left alone, because bootstrap's own dispatch paragraph does not mention constants either.
   - The rest of the hook text is not restructured, and the full-pipeline mention stays.
   - Hook check, run through the `hooks.json` command form with `CLAUDE_PLUGIN_ROOT=$PWD/plugins/glab`: `rc=0`, 0 bytes on stderr; `jq -e .hookSpecificOutput.hookEventName` → `"SessionStart"`; `additionalContext` length 2184, under the 10,000 cap.
   - Frontmatter for items 2-4: each changed description parses with `yaml.safe_load` (none contains `": "`).

The user's local copies under `~/.claude` still carry the stale lines (`commands/analyze.md`, `skills/manager/SKILL.md`, `commands/develop.md`, `agents/developer.md`, `agents/integrator.md`, `commands/ship.md`). By rule they were not touched. A user who copies from the repo, or who later edits the local copies, should know they now differ there.

## Gates (second run, the full AGENTS.md block, TMPDIR=/data/tmp/claude, CLAUDE_BIN as above)

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

Green as AGENTS.md defines it. The tree now has 16 files changed, 146+/82-, plus this untracked result file. Nothing is staged or committed.
