# flow-commands-to-skills — review round 1

Two reviewers, each read-only, given only the diff against HEAD. Their findings are copied verbatim below, followed by the manager's decisions. The fix round builds from this file.

## Reviewer A — correctness and coherence (FIX: 7 findings)

1. `plugins/glab/skills/ship/SKILL.md:27` — medium. A fix the user asks for runs "as Stage 5 sends findings back", which goes to Stage 2 → `/glab:develop`. That skill stops with no `plan.md`/`waived.md` (develop SKILL:13), and so does the developer (`BLOCKED: no contract`, developer.md:27). So a fix on a `/glab:ship` with no plan behind it, a case Rule 5 names at manager:117, cannot be reached. The old ship had the session make the fix itself. Fix: give a no-plan fix its own route in ship, e.g. a `glab:developer` fix round whose findings are its contract, and exempt that from developer Step 1.
2. `plugins/glab/skills/plan/SKILL.md:11` and `README.md:9` vs `manager/SKILL.md:231` — medium. A `/glab:plan` the user types now runs Steps 0–4 inside the manager session. The old command dispatched `glab:planner` on opus. Running it inline conflicts with Rule 2 ("never read a file an agent is about to read") and Rule 5 (the planner's model). The plan skill's description also triggers on any build/fix request in that session. Fix: Stage 1, or the top of `glab:plan`, should say that a session running `glab:manager` dispatches `glab:planner` with the task instead of following these steps itself.
3. `manager/SKILL.md:317` vs `analyze/SKILL.md:15` — low. `/glab:analyze` defers "CONFORMS → next" to the stage, but Stage 3 never says where `CONFORMS` goes. The removed command said `/glab:integrate`. Fix: add "`CONFORMS` → Stage 4" to Stage 3.
4. `analyze/SKILL.md:15`, `review/SKILL.md:9`, `integrate/SKILL.md:11`, `ship/SKILL.md:15` vs `manager/SKILL.md:53,145` — low. The manager now runs these skills itself, and they say "show its report verbatim", which Rule 2 forbids ("never paste … a full agent report"). Fix: say which rule wins when the manager is the caller.
5. `AGENTS.md:117-141` — low, under its own new *One fact* sentence. The change dropped the "session-start rules" entry, yet the temp-file rule is still stated in full in both `manager-bootstrap.sh:22` and `bootstrap/SKILL.md:73-74`. The commit-on-`main`-is-deliberate rule is stated in `manager/SKILL.md:354`, `commit/SKILL.md:7` and `committer.md:43` and listed nowhere. Fix: cut each to one owner plus pointers, or list it.
6. `plugins/glab/agents/planner.md:20` — low. The planner is told to load `glab:manager` through the Skill tool. That puts the 56 KB operating model ("You run this session as a manager … you do not implement", Rule 2) into a subagent that writes plan files. Fix: name the few manager sections the plan skill points at, or say to read only those.
7. `plugins/glab/agents/developer.md:115` vs `manager/SKILL.md:291` — low. Stage 2 now sends integration regressions to a fix round, but *A fix round* lists only `DIVERGES` and review findings, and its `## Fix round — <stage> round <n>` header has no round for Stage 4. Fix: add the integrator's `FAILED`.

## Reviewer B — AGENTS.md conformance and repeated text (FIX: 10 findings)

1. plugins/glab/skills/manager/SKILL.md:124 — correctness — "the model holds on a resume (see *Precedence*)" points at nothing: :115 *Precedence* dropped the v2.1.211 resume fact. :115 also sends installers to "the `glab` repository's `docs/specs/workflow.md`", which the plugin does not ship. Fix: keep the one resume clause in :115, or state it at :124. — medium
2. plugins/glab/skills/bootstrap/SKILL.md:17,25 — One fact — :17 restates the missing-`AGENTS.md` fallback and the read order, and :25 says "`glab:security` exempts nothing". The same rules are in manager-bootstrap.sh:14,24 and manager/SKILL.md:42. AGENTS.md:131-133 names only the agents and bootstrap.sh, and this change deleted the session-start entry. Fix: make both lines pointers, or add bootstrap/SKILL.md back to the entry. — medium
3. plugins/glab/skills/manager/SKILL.md:301 + plugins/glab/agents/developer.md:57,67 — repeated rule — the gate order and the "changed-code gate vs whole-tree sweep" text are written out in both files; :301 is new text in this change. Both roles run gates, so the rule belongs in `glab:security` Rule 3/4, with a pointer from each. — medium
4. plugins/glab/agents/developer.md:114 — One fact/correctness — the fix-round triggers list only `DIVERGES` and reviewer findings. manager/SKILL.md:291 and Stage 4 add integration regressions (`FAILED`). Fix: add them at :114. — low
5. AGENTS.md:235-239 — One fact — the intent-check entry names plugins/glab/skills/analyze/SKILL.md, but that file now carries only the word "intent" in its description, not the Stage 1b/3/6b mapping. Fix: drop it from the entry. — low
6. plugins/glab/skills/ship/SKILL.md:15,31-35 — repeated text — :15 copies review/SKILL.md:9 word for word. The commit step copies commit/SKILL.md:9-11 and committer.md:69. Owners: the review skill for showing the report, the commit skill and the committer for the report-back. Fix: point to them. — low
7. plugins/glab/skills/analyze/SKILL.md:9, develop/SKILL.md:9, integrate/SKILL.md:7 — repeated text — "No slug → ask which plan; do not guess, and do not pick the most recent" appears three times. Owner: the stage-skill paragraph at manager/SKILL.md:145; state it there once. — low
8. plugins/glab/agents/developer.md:47 — incidents kept — the line now points at `glab:security` Rule 8 (security/SKILL.md:84), which lacks two items from HEAD: "blank lines left where deleted code was" and implement.md's "a plan that forbids a registry also forbids the registry's vocabulary". Both are now gone from the tree. Fix: add both to Rule 8. — low
9. AGENTS.md:72-73 — Gates text — `plugin details` prints `Hooks (4)  … Stop  (harness-only — no model context cost)` for both plugins, and the green text does not show that suffix. The lines are unchanged from HEAD. Fix: say the suffix is expected. — low
10. Commit hygiene — three changes look outside commands-to-skills: comments/SKILL.md:109 (the `command grep` form), security/SKILL.md:26 (the `UNVERIFIED: L5` sentence, which serves manager plan-mode text this diff does not touch), and the analyzer/plan-analyzer status-enum fixes (analyzer.md:94, plan-analyzer.md:97). Fix: split them into their own commit, or confirm they belong to this plan. — low

The reviewer did not count two repeats because they predate this change:
- manager/SKILL.md:342 restates :170's round-3 rule and reviewer.md:96;
- manager:346 duplicates reviewer.md:100.

## Manager decisions (round 1)

- **Merged.** A7 and B4 are one finding (the developer's fix round lacks the integrator's `FAILED`). A5 and B2 are the same family (session-start and repeated rules); fix both.
- **A1.** A no-plan `/glab:ship` fix is a `glab:developer` fix round whose contract is the review findings, quoted verbatim in the dispatch. Developer Step 1 accepts that as its contract (no `BLOCKED: no contract`), and only for a fix round with findings attached.
- **A2.** In a session running `glab:manager`, `/glab:plan` and every plan request make the manager dispatch `glab:planner` with the task. Only the planner follows `glab:plan` Steps 0–4. State this once, at the top of `glab:plan` or in Stage 1, with a pointer from the other. README:9 must match.
- **A4.** When the manager is the caller, Rule 2 wins. A stage skill shows the verdict, the counts and the path of the full report, never the report itself.
- **A6.** The planner reads only the `glab:manager` sections that `glab:plan` points at, by section name. It never loads the whole manager skill.
- **B3.** The gate order and the changed-code-gate-vs-sweep rule live once, in `glab:security` (Rules 3/4). The manager and the developer each keep a one-line pointer.
- **B10.** These changes belong to this plan: they come from the plan's own audit findings. Do not split them out. No change.
- **The pre-existing repeats** (manager:342/:346 against :170 and reviewer.md:96/:100) are fixed too: the user's rule is "say it once", and that covers these.
- Every other finding is applied as its own "Fix" says.

### After the fix round stopped on three (PLAN WRONG A2, A6, B3)

- **A2: the user's answer replaces the decision above.** The user's words, 2026-11-13: "Plan in my session".
  - A `/glab:plan <task>` typed by the user runs `glab:plan` Steps 0–4 in the user's own session, as the plan says. That choice is the user's. It is not a breach of Rule 2 or Rule 5, and the manager's text says so in one place (Rule 2 or Stage 1).
  - Every plan request the user does *not* type as `/glab:plan` still goes to `glab:planner` (Stage 1).
  - `glab:plan`'s `description` must say this. Then the model doesn't pick the inline procedure for an ordinary build or fix request: it reads as the procedure the planner follows, and the one a user types.
  - Do not set `disable-model-invocation`, because the preload needs it unset.
  - README:9 stays as it is, unless it contradicts the new wording.
- **A6: rejected; the plan decision stands.** The planner keeps the `Skill` tool and loads `glab:manager` for the sections `glab:plan` points at. The Skill tool loads a whole skill, and reading the file by path in an installed plugin is UNVERIFIED. The context cost is a follow-up (FU-3), not a fix.
- **B3: applied the plan's way.** The developer and bootstrap step 3 own the gate order and the changed-code-gate-vs-sweep rule, as the plan's decision and C7 say. The gate text that `manager/SKILL.md` gained in this change (around :301) shrinks to a one-line pointer to them. Nothing moves into `glab:security`.
- **Rules for the whole fix round:**
  - each rule ends with one owner (the role that acts on it) and pointers elsewhere;
  - every *One fact* entry in AGENTS.md matches the tree afterwards;
  - no recorded incident is lost;
  - `glab` stays at 0.13.0. It was raised once already, for this change.
