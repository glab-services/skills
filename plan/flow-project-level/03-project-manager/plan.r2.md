tier: normal — prose moves between payload skill files plus three new skills and two reference files. No schema, no stored or wire format (no script or test changes), no secret, no money. Removing `Skill` from the planner's `tools:` only narrows one agent's tool list, the D3 precedent.

# 03-project-manager — plan

Base: `d6797e0` (02 on top of 01 `1bbf4bc`), branch `flow-project-level`, `glab` 0.15.0. Goals G1, G4 and G5 of `master.md`; the scope is the 03 line of `index.md` *Scope*. Analysis: `audit.md` §2 (the manager map), §6 (the target), F1–F5, F7, F9, F11, F12, F14–F21, F23, F26, F27. In this file, "HEAD" means `d6797e0` and "PM" means `plugins/glab/skills/project-manager/SKILL.md`. Every line range named "HEAD:" is read with `git show HEAD:<path> | sed -n <a>,<b>p`, so the source survives step P12's rewrite. "Description bytes" always means `/usr/bin/grep '^description: ' <file> | wc -c`, the measure `list` sums.

## Decisions

- effort: high (the user's level for this session), for the session
- planner: the built-in Plan agent (read-only), the manager saved the file — a typed agent, for the budget
- W1 — The new PM keeps three section titles from D5: *The pipeline*, *Pick the tier* and *Your skills — this level only*. It also keeps *The rules of every level*, *The master plan and sub-plans* (the orchestration still lives there) and *Running agents in parallel*, so the hook text and `session-rules:53` stay true. Rule 4 becomes `## What this session owns` (F17). Stage 1's manager side becomes `## Dispatching the planner`. No heading in PM begins `Stage `, because master *Final check* step 5 requires `## Stage ` to count 0.
- W2 — Pointer rule. A pointer `glab:project-manager` Stage <n> whose detail moves is retargeted to the skill that now holds that detail:
  - 1b → `glab:project-plan-analyze`
  - 1c → `glab:project-plan-report`
  - Stage 1's approval and hash, and the changed-request route of *The master plan and sub-plans* (HEAD:PM `:82`) → `glab:project-plan-accept`
  - 2 → `glab:project-develop`
  - 3 and 6b → `glab:project-analyze`
  - 4 → `glab:project-integrate`
  - 5 → `glab:project-review`
  - 8 → `glab:project-record`
  - Rule 4 → *What this session owns*
  - checklist items → `glab:project-plan-accept` item <n>

  A pointer that names only a stage row the table keeps stays as written: `commit:7` Stage 6, `push:7` Stage 7, `project-develop:13,17` "planning (Stage 1)". Every retarget replaces only the pointer token, and each token is shorter than the old one. That matters for the analyzer sets: on HEAD they are only 143 (`project-analyzer`) and 159 (`project-plan-analyzer`) bytes under their G5 caps.
- W3 — F4/D7: `glab:project-plan` Step 0 takes the tier criteria. It keeps the exact phrase `a schema or data migration` (Final check step 5) and adds "a `plan.md` with no tier line is full tier". The planner writes the tier line. `glab:project-plan-accept` is where the manager accepts the tier or sends the plan back to be raised; a raise after acceptance is a `## Decisions` overrule line. PM *Pick the tier* keeps who runs what per tier, and says only the user lowers a tier.
- W4 — F7: the tier table's round cells read `capped`. Each stage skill says "capped as `glab:session-rules` *Round caps*" and then what follows the last round. The *One fact* round-cap entry drops the PM table from its file list, because the table no longer states the number.
- W5 — F5/D8: the Stage 3 and Stage 6b dispatches carry the slug only, plus a round's inputs from round 2 on. The ≤10-line `result.md` summary goes to the user. This is said once, in `glab:project-analyze`.
- W6 — F11/D11: the two `findings.md` (pre-0.10.0) clauses at HEAD:PM `:183` and `:185` are not carried into `project-plan-analyze`. The agents keep their own clauses, because they act on them. `project-develop:16`'s pre-0.11.0 clause stays: it is the only copy, and that skill acts on it. `index.md` D11 replaces audit §6's *Older folders* section, so `project-plan` gets none.
- W7 — F9, the manager's half. "One message" is said only in `session-rules` Rule 2 (`:66` on HEAD, already there). PM *Running agents in parallel* keeps the independence rule and "reconcile before acting", in ≤ 450 bytes.
  - The develop split rules, with their incident ("a red tree and two reports that each blame the other"), move to `project-develop`.
  - The review dimensions move to `project-review`.
  - "Never in parallel: commit and push" moves to `glab:commit`.
- W8 — F12: `project-analyze` keeps only the conformance check and the final check. Every check is run by `glab:project-analyzer`, and with no `result.md` it points at `/glab:project-plan-analyze`. `project-review` drops its Stage 8 claim. `project-record` dispatches `glab:project-analyzer` and, at full tier, `glab:project-reviewer` directly.
- W9 — F14: HEAD:PM Stage 6 (`:270-277`, except `:274`) and Stage 7 (`:284-289`) are cut, not moved, because `commit` and `push` already hold them. `:274`, the sub-plan commit order, goes into PM *The master plan and sub-plans*. F15: *Know the gates* becomes one clause of *The pipeline*. F16: `project-develop` adds only the fix-round naming and the `BLOCKED`/`PLAN WRONG` re-dispatch to Rule 0c's list.
- W10 — F19: the no-subagent case moves to `project-manager/references/without-subagents.md` and is merged with `session-rules:120`, the bullet that sat at `:124` on `1bbf4bc`; that bullet is removed. PM keeps a one-line pointer. The product manager has no no-subagent text on HEAD (`grep -i subagent product-manager/SKILL.md`, run: only an unrelated line 29), so the product level loses nothing it acted on. The gap goes to the record as a follow-up.
- W11 — F20: plan-mode approval moves to `project-plan-accept/references/plan-mode.md` with all 10 of its `UNVERIFIED` marks (HEAD:PM `:164-172`, counted with `grep -o UNVERIFIED | wc -l`).
- W12 — F21/D14: *The pipeline* says to invoke each stage skill once per context, follow its loaded text for later rounds, and invoke it again only after a compaction. Whether a repeated call re-injects the body is UNVERIFIED, and that goes to the record.
- W13 — F3/D9: `project-plan` names `glab:project-manager` 0 times (15 mentions on 12 lines on HEAD), and *Quick Reference* (751 B) goes. `project-planner.md` loses the Skill-tool clause of `:20` and `Skill` from `tools:`. Its `:3` description keeps "Use from glab:project-manager Stage 1", which names the dispatching row. Its *Where you write* line (`:28`) "`glab:project-plan` or `glab:project-manager` says" becomes "`glab:project-plan` says", because the master's constancy is stated there (Step 3). Result: exactly 1 `glab:project-manager` in `project-planner.md` (3 on HEAD).
- W14 — F18: "(approved, at full tier)" in the `project-develop` description and "— approved, at full tier —" in `project-developer.md:3` and `:11` read "an accepted plan — the user's approval at full tier".
- W15 — F26: PM's description goes from 576 description bytes to ≤ 300, and `project-plan`'s from 673 to ≤ 400. The three new descriptions are ≤ 220 each and one line each, so `onel` = `files` = 34.
- W16 — The per-file targets in the byte table are post-conditions. One may be overrun only if every milestone sum still holds; the overrun is then recorded in `result.md` as a deviation with its bytes. The caps are what bind (`index.md`, the estimates line).
- W17 — The incidents move with their rules:
  - The `findings-` Write refusal stays in PM *Explore once*.
  - The red-tree incident goes to `project-develop`.
  - The rationale of HEAD:PM `:175-177` stays a pointer to `glab:project-plan-analyzer` *The plan check*, which holds it in full (audit §2).

  No rationale passage leaves the payload. Everything cut and not moved is a duplicate whose owner is named in W7, W9 or W13.
- W18 — D15: no `docs/specs/` edit. The untracked `plan/manager-flow-notes.md` (it shows in `git status` on HEAD) is not this slug's: it is not staged, not edited and not removed.
- W19 — F27/D13: the Go test policy in `project-developer.md` is left as it is, and goes to the record as a follow-up.
- W20 — No question for the user. Nothing here is destructive, costs money, exposes data or changes what the product is.
- W21 — plan check round 1: NOT BUILDABLE, 12 findings (check.r1.md); amended in place
- W22 — The PM target is ≤ 10000, not 9600, and `project-plan-accept` is ≤ 5600, not 5300.
  - Why: what P12 keeps measures about 11.1k on HEAD (the plan check's measure, and my per-range `wc -c`). Only the named cuts in P12's budget table bring it to 9950. A 9600 target left no slack for prose that has to stay byte for byte.
  - 10000 is under G1's 10240 and leaves 240 for wording.
  - `project-plan-accept`'s sources come to about 5.55k with frontmatter (P1). It is cut only where P1 says.
  - Recomputed: `proj` 44247, `task` 80694 (1226 under 81920), `list` ≈ 9834. No other target moves, and each sum is under its cap.

## Evidence (measured on HEAD, `TMPDIR=/data/tmp/claude`)

- `wc -c`:

  | File | Bytes |
  |---|---:|
  | PM | 40845 |
  | `project-plan` | 15654 |
  | `project-planner.md` | 2599 |
  | `project-plan-report` | 1604 |
  | `project-develop` | 3247 |
  | `project-analyze` | 2059 |
  | `project-integrate` | 1017 |
  | `project-review` | 1030 |
  | `commit` | 1547 |
  | `push` | 6997 |
  | `session-rules` | 13310 |
  | `bootstrap` | 5212 |
  | `security` | 13304 |
  | `product-manager` | 10812 |
  | `project-analyzer.md` | 9517 |
  | `project-plan-analyzer.md` | 9209 |
  | `project-developer.md` | 12109 |
  | `project-ship` | 3088 |
  | `AGENTS.md` | 28997 |

- Hook text with stdin `/dev/null` (Final check step 4's `h`): project 2631, product 2584. `core` = 31826.
- Sums:
  - `proj` = 75302. 02's result says 75074. Cause UNVERIFIED — not re-run at 02's tree; inferred to be an edit after 02's measurement.
  - `prod` = 45222.
  - `list` = 9663, `files` = 31, `onel` = 31.
- Agent sets (step 4's loop): `project-analyzer` 23437 (cap 23580), `project-plan-analyzer` 23129 (cap 23288), `project-reviewer` 27750 (cap 27973), `product-analyzer` 16508 (cap 16657), `project-planner` 31557 (cap 31168).
- Description bytes: PM 576, `project-plan` 673 (the plan check's run, round 1).
- PM sub-ranges (`sed -n <r>p | wc -c`):

  | Range | Bytes |
  |---|---:|
  | `1,4` | 606 |
  | `6,9` | 165 |
  | `37,49` (the table) | 1489 |
  | `51` | 923 |
  | `55,59` (the criteria) | 527 |
  | `61,73` (the tier table) | 1126 |
  | `75,77` | 179 |
  | `80,81` | 217 |
  | `82` | 686 |
  | `83` | 574 |
  | `84` | 578 |
  | `85,88` | 479 |
  | `135` | 723 |
  | `137` | 464 |
  | `139` | 715 |
  | `274` | 193 |

  Section totals (awk over headings): `14-22` 765, `23-30` 927, `89-120` 2479, `143-157` 2706, `158-163` 1246, `164-172` 2060, `173-188` 3360, `189-203` 2851, `301-311` 771.
- `session-rules` on HEAD: `:18` record-line routing (226 B), `:117` the Rule 4 cite (555 B), `:120` the no-subagent bullet (271 B). These are the `:18`, `:121` and `:124` of `1bbf4bc`.
- Marker counts (`/usr/bin/grep -c -E 'TODO|FIXME|HACK|NOTE|XXX'`): `project-developer.md` 1, `AGENTS.md` 2, and 0 in every other file this plan touches.
- Final check step 5 strings in PM today: `## Stage ` 11, `sha256sum` 1, `Plan acceptance checklist` 1. `project-plan` has `schema or data migration` 0 times.
- `jq -r .version plugins/glab/.claude-plugin/plugin.json` prints `0.15.0`.
- `README.md` holds no skill count: `/usr/bin/grep -n 22 README.md` matched no count line. Its skill list is row 9.

## Byte table

Moves cite HEAD:PM line ranges.

| File | HEAD | Target | What moves where |
|---|---:|---:|---|
| `project-manager/SKILL.md` | 40845 | ≤ 10000 | the sections of P12's budget table (W1, W22) |
| `project-plan-accept/SKILL.md` (new) | 0 | ≤ 5600 | `:143-163`, `:82`'s hash and changed request, `:83`'s full-tier sub-plan approval, the tier acceptance (W3) |
| `project-plan-accept/references/plan-mode.md` (new) | 0 | ≤ 2200 | `:164-172` (W11) |
| `project-plan-analyze/SKILL.md` (new) | 0 | ≤ 3800 | `:173-188`, without the 0.10.0 clauses (W6) |
| `project-plan-report/SKILL.md` | 1604 | ≤ 4300 | `:189-203`, `session-rules:18`'s routing, `:84`'s brief exception |
| `project-develop/SKILL.md` | 3247 | ≤ 6100 | `:204-230`, `:103-111` split + incident (W7, F16) |
| `project-analyze/SKILL.md` | 2059 | ≤ 5200 | `:231-249`, `:278-283`; loses the plan check and the record check (W8), F5 |
| `project-integrate/SKILL.md` | 1017 | ≤ 1700 | `:250-257` |
| `project-review/SKILL.md` | 1030 | ≤ 3200 | `:258-269`, `:96-101` dimensions, `SHIP` → Stage 6 |
| `project-record/SKILL.md` (new) | 0 | ≤ 2100 | `:290-300` |
| `project-manager/references/without-subagents.md` (new) | 0 | ≤ 1500 | `:121-132` + `session-rules:120` |
| `commit/SKILL.md` | 1547 | ≤ 1750 | `:112-115` never in parallel |
| `session-rules/SKILL.md` | 13310 | ≤ 13100 | `:18` retarget, `:117` cite, `:120` out |
| `project-plan/SKILL.md` | 15654 | ≤ 15100 | + tier criteria; − *Quick Reference*, − 15 manager mentions, description ≤ 400 |
| `agents/project-planner.md` | 2599 | ≤ 2540 | − `Skill`, − the `:20` clause, `:28` retarget |
| `agents/project-analyzer.md`, `project-plan-analyzer.md` | 9517, 9209 | ≤ HEAD each | W2 retargets only (they shrink) |
| `agents/project-developer.md` | 12109 | ≤ 12170 | W14, `:119` retarget |
| `project-ship/SKILL.md` | 3088 | ≤ 3088 | `:27` retarget |
| `AGENTS.md`, `README.md` | 28997, — | uncapped | F23 retargets, Gates `Skills (25)`, README row 9, `:280` |

Sums at the targets (inferred until step A2 measures them):

- `proj` = 2631 + 5212 + 13100 + 13304 + 10000 = **44247** (cap 47104).
- `prod` = 2584 + 5212 + 13100 + 13304 + 10812 = **45012** (cap 47104).
- `task` = 44247 + 5600 + 3800 + 6100 + 1700 + 3200 + 1750 + 5200 + 6997 + 2100 = **80694** (cap 81920).
- `list` ≈ 9663 − 276 − 273 + 660 + 60 = **≈ 9834** (cap 10240), with `files` = `onel` = 34.
- Planner set ≤ 2540 + 15100 + 13304 = **30944** (cap 31168).
- Skills: 22 + 3 = **25** (D16).

## Steps

### Before

- B1 — Confirm the base. `git rev-parse --short HEAD` prints `d6797e0`. `git status --short` prints only `?? plan/manager-flow-notes.md` plus this slug's `03-project-manager/` folder. Run master *Final check* step 4's block. The result is this plan's *Evidence* numbers; its `task` line errors on the three missing files, which is expected before. Post: those values, pasted into `result.md`.

### Processing

Each step names one file. The source of every move is a HEAD range. Prose is condensed, never re-reasoned. Every incident and every UNVERIFIED mark is carried.

- P1 — Create `plugins/glab/skills/project-plan-accept/SKILL.md`.
  - Frontmatter: `name: project-plan-accept`, a one-line `description: Project level — …` of ≤ 220 description bytes, and `argument-hint: "[plan slug]"`.
  - Body: `$ARGUMENTS` is the slug or `<slug>/<nn>-<name>`; none → ask, never guess.
  - The tier line (W3).
  - `### Plan acceptance checklist`, items 1–8 and the vendor-URL line from HEAD:PM `:143-157`, with each command byte for byte (items 6, 7 and 8). "skip to the acceptance checklist" for a plan the user handed over says to run this skill on theirs.
  - *A question blocks* from `:158-160`, where "Stage 1c" becomes `glab:project-plan-report`.
  - The approval from `:161-163`, plus `:82`: the `## Approval` line forms, `sha256sum plan/{slug}/master.md > plan/{slug}/master.sha256`, never edited after, and the changed-request route. Plus `:83`'s full-tier sub-plan `## Approval` sentence.
  - One line: "Approval in plan mode, only when the user asks: read `references/plan-mode.md`."
  - Rounds: none.
  - The only cut (W22): items 3 and 4 lose their restated examples ("A findings file … has not done this step"; "'Which approach do you want?' … Send those back"), about 300 B. Every item's test stays.

  Post:
  - `wc -c` ≤ 5600.
  - `/usr/bin/grep -cF` each of: `name: project-plan-accept` → 1, `sha256sum plan/` → 1, `Plan acceptance checklist` → 1, `references/plan-mode.md` → 1, `- size: ` → 1.
  - `/usr/bin/grep -c '## Approval'` → ≥ 3 (the line forms, the master, `plan.md`).
- P2 — Create `plugins/glab/skills/project-plan-accept/references/plan-mode.md` from HEAD:PM `:164-172`, steps 1–4. "after Stage 1b" stays as a stage name. Post: `wc -c` ≤ 2200; `/usr/bin/grep -o UNVERIFIED <file> | wc -l` → 10; `/usr/bin/grep -cF 'plansDirectory'` → 1.
- P3 — Create `plugins/glab/skills/project-plan-analyze/SKILL.md`.
  - Frontmatter: `name: project-plan-analyze`, description ≤ 220.
  - Body: the slug rule. It dispatches `glab:project-plan-analyzer` for the plan check or the master check, split by surface (PM *Running agents in parallel*), as `session-rules` Rules 0d and 5 say.
  - HEAD:PM `:173-188`. The opening contrast (`:175-177`) becomes the pointer to `glab:project-plan-analyzer` *The plan check*. "the approval (Stage 1)" becomes `glab:project-plan-accept`. The two `findings.md` clauses are dropped (W6). The round copies, `master.v<n>.md`, the `cmp -s` delta and its exits 0/1/2 are kept.
  - "At most 2 rounds…" becomes "capped as `glab:session-rules` *Round caps*", followed by `:188`'s after-last-round text.
  - It shows the report as *The pipeline* says.

  Post:
  - `wc -c` ≤ 3800.
  - `/usr/bin/grep -cF`: `NOT BUILDABLE` ≥ 2, `cmp -s` → 1, `0.10.0` → 0, `*Round caps*` → 1, `The plan check` → 1.
  - `/usr/bin/grep -cE 'At most 2|max 2'` → 0.
- P4 — Edit `plugins/glab/skills/project-plan-report/SKILL.md`.
  - Its two `glab:project-manager` Stage 1c pointers become "below".
  - Its `:11` "`glab:project-manager` acceptance checklist item 8" becomes `glab:project-plan-accept` item 8.
  - Its description drops "which the project manager runs at glab:project-manager Stage 1c" and reads "which the project manager runs after the plan check" (≤ 300 description bytes).
  - Append HEAD:PM `:189-203` as `## Before the report`, `## Waiting`, `## The freeze` and `## On resuming`. Inside it:
    - "Stage 1b" becomes `glab:project-plan-analyze`.
    - `:200`'s "(*The master plan and sub-plans*)" becomes "(`glab:project-plan-accept`)": the changed-request route moves there in P1 (W2).
  - It owns the record-line routing (`session-rules:18`): a line for a frozen file goes to `plan/{slug}/after-verdict.md`. It also owns `:84`'s brief exception: every sub-plan is planned and checked before the report, from the master's base and its own `index.md` line.

  Post:
  - `wc -c` ≤ 4300.
  - `/usr/bin/grep -cF 'after-verdict.md'` ≥ 1.
  - `/usr/bin/grep -c 'glab:project-manager'` → 0.
  - `/usr/bin/grep -cF 'master plan and sub-plans'` → 0.
  - `/usr/bin/grep -cF 'WAITING'` → 1.
- P5 — Edit `plugins/glab/skills/project-develop/SKILL.md`.
  - Description per W14 (≤ 210 description bytes).
  - `:7` "The entry point of `glab:project-manager` Stage 2" becomes "Stage 2 of `glab:project-manager` *The pipeline*".
  - Every `glab:project-manager` Stage 1c becomes `glab:project-plan-report`.
  - `:16`'s "(`glab:project-manager` → *Pick the tier*)" becomes "(`glab:project-plan` Step 0)".
  - Append:
    - `## Splitting`, from HEAD:PM `:103-111`, with the red-tree incident.
    - `## The dispatch`: only the fix-round naming (`fix round for analyze round 2`, a new agent, the findings copied) and the `BLOCKED`/`PLAN WRONG` re-dispatch, on top of Rule 0c (F16); "do not paste the plan"; what comes back is per `glab:project-developer` Step 5 and *Report*.
    - `## Verify before moving on`, from `:221-230`.

  Post:
  - `wc -c` ≤ 6100.
  - `/usr/bin/grep -cF`: `PLAN WRONG` ≥ 2, `BLOCKED` ≥ 2, `two reports that each blame the other` → 1, `approved, at full tier` → 0.
  - `/usr/bin/grep -cE 'glab:project-manager.? Stage (1c|2)'` → 0.
- P6 — Rewrite `plugins/glab/skills/project-analyze/SKILL.md`.
  - Description: "Project level — Check an implementation with the glab:project-analyzer agent — conformance and the final check, intent, not correctness" (≤ 220).
  - Body:
    - The conformance check (Stage 3) and the final check (Stage 6b), both through `glab:project-analyzer`. No `result.md` and no check named → the sentence "Nothing is built: that is the plan check, `/glab:project-plan-analyze {slug}`." (W8).
    - The dispatch carries the slug only; the ≤ 10-line summary of `result.md` is for the user (W5).
    - HEAD:PM `:231-249`: the normal-tier skip, the question, `CONFORMS` → Stage 4, `DIVERGES` → a `project-develop` fix round, capped as *Round caps*, `analyze round 2/2`, and the snapshot recipe byte for byte, `<slug>-analyze-r<n>.idx` included, with the three resolutions.
    - `:278-283`, the final check and its gaps route.
    - The report shown as *The pipeline* says.

  Post:
  - `wc -c` ≤ 5200.
  - `/usr/bin/grep -cF`: `-analyze-r` → 1, `/glab:project-plan-analyze` ≥ 1, `Stage 1b` → 0, `Stage 8` → 0, `that summary` → 0, `git write-tree` → 1.
- P7 — Edit `plugins/glab/skills/project-integrate/SKILL.md`. The `:7` entry line becomes "Stage 4 of `glab:project-manager` *The pipeline*". Replace "What each verdict leads to … is Stage 4's" with HEAD:PM `:252-257`: skip only when the change cannot run, `INTEGRATED` → Stage 5, `FAILED` → a `project-develop` fix round, `BLOCKED: no suite` → ask and write to memory. Post: `wc -c` ≤ 1700; `/usr/bin/grep -cF 'INTEGRATED'` ≥ 1; `/usr/bin/grep -cF 'is Stage 4'` → 0.
- P8 — Edit `plugins/glab/skills/project-review/SKILL.md`.
  - Drop ", and of the record's review (Stage 8)" (W8).
  - The entry line becomes "Stage 5 of `glab:project-manager` *The pipeline*".
  - Append from HEAD:PM `:262-269` + `:96-101`:
    - the external auditor and what round 2 gets (the tree ids from `glab:project-analyze`'s snapshot);
    - the split by dimension (`project-reviewer` per dimension, deduplicated by the manager);
    - `SHIP` → Stage 6 (`/glab:commit`);
    - findings → a `project-develop` fix round, then the full-tier delta rule, capped as *Round caps*;
    - the tier raise;
    - cut scope.

  Post:
  - `wc -c` ≤ 3200.
  - `/usr/bin/grep -cF`: `SHIP` ≥ 1, `Stage 8` → 0, `*Re-reviews*` ≥ 1, `max 2` → 0.
- P9 — Create `plugins/glab/skills/project-record/SKILL.md`.
  - Frontmatter: `name: project-record`, description ≤ 220, `argument-hint: "[plan slug]"`.
  - Body: the slug rule, then HEAD:PM `:290-300` — after the confirmed push; the spec in `docs/specs/` unless `AGENTS.md` names another place; never removes `plan/{slug}/`; the developer, analyzer and full-tier reviewer dispatches, made directly; `/glab:commit`, then `/glab:push` on its own go-ahead; no `## Record` → not recorded.
  - It also carries "Remove `plan/{slug}/` or an audit file as part of the record" from *What you never do*.

  Post: `wc -c` ≤ 2100; `/usr/bin/grep -cF 'docs/specs'` ≥ 1; `/usr/bin/grep -cF 'glab:project-reviewer'` → 1; `/usr/bin/grep -cF 'name: project-record'` → 1.
- P10 — Edit `plugins/glab/skills/commit/SKILL.md`: add, before *Report back*, one paragraph from HEAD:PM `:112-115` — never in parallel with another commit or a push; name the exact paths when something else writes. Post: `wc -c` ≤ 1750; `/usr/bin/grep -cF 'in parallel'` → 1.
- P11 — Create `plugins/glab/skills/project-manager/references/without-subagents.md` from HEAD:PM `:123-131`, with HEAD:`session-rules:120` merged in: the model the user starts the stage session with, `claude --model <alias>` or `/model <alias>`, and the role's model named at handoff. Add `<slug> plan-accept`, `<slug> plan-analyze` and `<slug> report` to the session names. Post: `wc -c` ≤ 1500; `/usr/bin/grep -cF 'review4'` → 1; `/usr/bin/grep -cF -- '--model <alias>'` → 1.
- P12 — Rewrite PM (`plugins/glab/skills/project-manager/SKILL.md`), section by section, to these budgets (W22). The budgets total 9950, against a target of ≤ 10000. Each section's HEAD bytes are measured, from *Evidence*. Keeps and losses:

  | Section | HEAD source (bytes) | Budget | Keeps | Loses |
  |---|---|---:|---|---|
  | frontmatter + `# Manager` | `1,9` (772) | 500 | `name:`, the intro | the description, 576 → ≤ 300 description bytes: "Project level — The operating model of a project session: you manage agents, you do not implement. Runs each change through its stage skills at the tier its risk calls for. Loaded at session start at the project level." |
  | `## The rules of every level` | `10-13` (285) | 250 | the one line | ", but Rule 4," |
  | `## Your skills — this level only` | `14-22` (765) | 830 | the four bullets; + `glab:project-plan-accept`, `glab:project-plan-analyze`, `glab:project-record` | "which `glab:bootstrap` step 2 loads" |
  | `## What this session owns` | `23-30` (927) | 750 | the surfaces, the seam rule, the relayed-decision rule | the restated examples of surfaces condensed |
  | `## The pipeline` | `35-52` (2431) + `31-34` (224) | 2200 | the table, with Run cells 1 `glab:project-planner`, then `/glab:project-plan-accept {slug}`; 1b `/glab:project-plan-analyze {slug}`; 3/6b `/glab:project-analyze {slug}`; 8 `/glab:project-record {slug}`. The paragraph: invoked by you through the Skill tool, the user may type it, no slug → the skill asks, show only verdict/counts/path (Rule 2), a missing skill → its agent directly, the handoff line, + W12 (≈ 180 B), + the gate clause (F15, ≈ 110 B) | row 1's *Writes* cell becomes "the plan files (`glab:project-plan` Step 3)" (≈ −250); the "empty argument makes the path `plan/`" rationale (each stage skill asks for a missing slug); *Know the gates* as a section |
  | `## Pick the tier` | `53-77` (1905) | 1200 | the planner writes the tier line (`glab:project-plan` Step 0), you accept or raise it (`glab:project-plan-accept`), only the user lowers one; the table with cells `capped` (W4); *Round caps* pointer; gates and push at every tier | the criteria `55-59` (527, → `project-plan`); the Stage 1 row cells become "Step 3's normal layout" / "Step 3's full layout" (≈ −200); the Stage 8 row cells become "`glab:project-record`" / "the same, with one reviewer pass" (≈ −200) |
  | `## The master plan and sub-plans` | `78-88` (2568) + `274` (193) | 1350 | `80-81`; one line for `:82`: "constant once accepted; its approval, hash and a changed request: `glab:project-plan-accept`"; `:83`'s cycle, `{slug}/<nn>-<name>`, round caps per sub-plan; `:84`'s order rule with the brief exception as a pointer to `glab:project-plan-report`; `85-88`; `:274`'s commit order | `:82`'s procedure (686, → P1); `:83`'s full-tier approval sentence (→ P1); `:84`'s brief detail (→ P4) |
  | `## Running agents in parallel` | `89-120` (2479) | 450 | independence; reconcile before acting; the fan-out of read-only agents in one line | the "one message" restatement, the split (→ P5), the dimensions (→ P8), never in parallel (→ P10) |
  | `## Dispatching the planner` | `133-142` (2198) | 1600 | the planner preloads `glab:project-plan`; the typed `/glab:project-plan` exception with Steps 0 to 4; a handed-over plan → `/glab:project-plan-accept`; `waived.md`; *A brief is a request* with the `glab-shared-store:` resolution; *Explore once* with the `findings-` incident; the review of decisions under Rule 3 | "Planning here is the user's choice, so it is not a breach…" (≈ −150); the repeated "Every plan request … still goes to" sentence; condensing of `:139` keeping its rule and incident |
  | `## After a report to product` | `195` (part) | 300 | the freeze: record lines go to `after-verdict.md` (`glab:project-plan-report`) | the rest of Stage 1c (→ P4) |
  | `## Without subagent dispatch` | `121-132` (1196) | 120 | one line: read `references/without-subagents.md` | all of it (→ P11) |
  | `## What you never do` | `301-311` (771) | 400 | lower a tier; edit `master.md` after `## Approval`; start a service outside Stage 4; plan mode unasked | the five items that restate their owners |

  Carry each HEAD fact this table keeps byte for byte where it is a command or a fixed word. All `## Stage …` sections not listed are gone (→ P1–P9, or cut per W9).

  Post:
  - `wc -c` ≤ 10000.
  - `/usr/bin/grep -cF`: `## Stage ` → 0, `sha256sum` → 0, `Plan acceptance checklist` → 0, `references/without-subagents.md` → 1, `Rule 4` → 0, `schema or data migration` → 0, `findings-` ≥ 1.
  - Each of these headings counts exactly 1 with `/usr/bin/grep -cxF`: `## The rules of every level`, `## Your skills — this level only`, `## What this session owns`, `## The pipeline`, `## Pick the tier`, `## The master plan and sub-plans`, `## Running agents in parallel`, `## Dispatching the planner`.
  - `/usr/bin/grep -c '^description: .\{40,\}'` → 1, and its description bytes ≤ 300.
- P13 — Edit `plugins/glab/skills/project-plan/SKILL.md`.
  - Step 0's "— `glab:project-manager` → *Pick the tier* says which" becomes the criteria: full is not a judgment call — a schema or data migration, a change to a stored or wire format, code that decides who may do what, handles secrets or moves money; trivial is Rule 1's line; normal is everything else; a `plan.md` with no tier line is full tier. Step 3's tier-line sentence (`:75`) names Step 0.
  - Each of the 15 `glab:project-manager` mentions is retargeted per W2:
    - `:3` → "goes to glab:project-planner"
    - `:22` → the criteria above
    - `:35` → the parenthesis dropped
    - `:83` and `:126` → `glab:project-record`
    - `:99` → `glab:project-plan-accept`
    - `:105` → `glab:project-plan-report`
    - `:109` → `glab:project-plan-analyze` and `glab:project-plan-accept`
    - `:118`, all four: "Under `glab:project-manager` an amendment" → "Under the project manager, an amendment"; Stage 1b → `glab:project-plan-analyze`; Stage 1c → `glab:project-plan-report`; *The master plan and sub-plans* → `glab:project-plan-accept`
    - `:122` → `glab:project-develop`
    - the two in *Quick Reference* go with it
  - Delete `## Quick Reference` (`:145-155`).
  - The description ≤ 400 description bytes (W15).

  Post:
  - `wc -c` ≤ 15100.
  - `/usr/bin/grep -c 'glab:project-manager'` → 0.
  - `/usr/bin/grep -cF`: `schema or data migration` → 1, `## Quick Reference` → 0.
  - `/usr/bin/grep -c '^## Step [0-4] '` → 5.
- P14 — Edit `plugins/glab/agents/project-planner.md` (W13): `tools:` at `:5`, the clause at `:20`, the retarget at `:28`. Post: `wc -c` ≤ 2540; `/usr/bin/grep -c 'glab:project-manager'` → 1; `/usr/bin/grep -c '^tools: .*Skill'` → 0; `/usr/bin/grep -cF 'through the Skill tool'` → 0.
- P15 — Edit `plugins/glab/skills/session-rules/SKILL.md`:
  - `:18` "there `glab:project-manager` Stage 1c says where" becomes "there `glab:project-plan-report` says where".
  - `:117` "— `glab:project-manager` Rule 4 does not apply to the model choice —" becomes "— no relayed decision binds the model choice —".
  - Delete `:120` (W10).

  Post: `wc -c` ≤ 13100; `/usr/bin/grep -c 'glab:project-manager'` → 1 (`:53`, *Pick the tier*); `/usr/bin/grep -cF 'Without subagent dispatch'` → 0.
- P16 — Retarget the remaining pointers per W2:
  - `agents/project-analyzer.md`: `:51` and `:88` → `glab:project-record`, `:72` → `glab:project-analyze`, `:84` → `glab:project-review`, `:90` → `glab:project-plan-analyze`.
  - `agents/project-plan-analyzer.md` `:3`, `:43` → `glab:project-plan-analyze`.
  - `agents/project-developer.md` `:119` → `glab:project-record`, plus W14 at `:3` and `:11`.
  - `skills/audit/SKILL.md:65` → `glab:project-record`.
  - `skills/project-ship/SKILL.md:27` → `glab:project-review`.
  - `README.md:280` → `(`glab:project-plan-report`)`.

  Post:
  - `/usr/bin/grep -rnE 'glab:project-manager`? (Stage (1b|1c|2|3|4|5|6b|8)|Rule 4|acceptance checklist|checklist item)' plugins README.md tests; echo "rc=$?"`, run from the repo root, prints only `rc=1`. On HEAD it prints 29 lines and `rc=0` (the plan check's run, round 1); P4–P8, P13, P15 and P16 cover every one of those lines.
  - `/usr/bin/grep -cF 'approved, at full tier' plugins/glab/agents/project-developer.md` → 0.
- P17 — Edit `AGENTS.md`.
  - *Gates* `:77`: `Skills (22)` → `Skills (25)`, with `project-plan-accept`, `project-plan-analyze` and `project-record` added in sorted position.
  - *One fact* (F23), one retarget per entry:
    1. Round caps: drop "the table of `plugins/glab/skills/project-manager/SKILL.md` *Pick the tier*, and" (W4).
    2. Reviewer verdict lines: add `plugins/glab/skills/project-review/SKILL.md`.
    3. Every round a new agent: `project-manager/SKILL.md` → `project-plan-analyze`, `project-develop`, `project-review` and `project-record` `SKILL.md`.
    4. Round copies: add `project-plan-analyze/SKILL.md`; "`project-manager/SKILL.md` Stage 1c" → `project-plan-report/SKILL.md`.
    5. What a review round is given: "`project-manager/SKILL.md` Stage 5" → `project-review/SKILL.md`.
    6. Plan lifecycle: `project-manager/SKILL.md` → `project-record/SKILL.md`.
    7. Plan size budget: "`project-manager/SKILL.md` acceptance checklist item 6" → "`project-plan-accept/SKILL.md` checklist item 6".
    8. Master plan and sub-plans: add `project-plan-accept/SKILL.md`.
    9. Intent check: `project-manager/SKILL.md` → `project-analyze/SKILL.md`.
    10. Analyzers' verdict lines: add `project-plan-analyze/SKILL.md`.
    11. Plan mode: `project-manager/SKILL.md` → `project-plan-accept/references/plan-mode.md`.
    12. Shared store line: "`project-manager/SKILL.md` Stage 1" → "`project-manager/SKILL.md` *Dispatching the planner*".
    13. Plan digest: "`project-manager/SKILL.md` Stage 1c" → `project-plan-report/SKILL.md`.
    14. Brief line, wrapped over `:314-315`: "`project-manager/SKILL.md` checklist item 8" → "`project-plan-accept/SKILL.md` checklist item 8".
    15. The `plan/` rule (`:347`): "(`glab:project-manager` Stage 8)" → "(`glab:project-record`)".

  Post:
  - `/usr/bin/grep -cE 'project-manager/SKILL\.md`? (Stage|acceptance|checklist|\*Pick)' AGENTS.md` → 0.
  - `/usr/bin/grep -cF 'project-plan-accept/SKILL.md' AGENTS.md` → 3 (entries 7, 8 and 14).
  - `/usr/bin/grep -cF 'references/plan-mode.md' AGENTS.md` → 1.
  - `/usr/bin/grep -cF 'Skills (25)' AGENTS.md` → 1.
  - `/usr/bin/grep -cF 'Skills (22)' AGENTS.md` → 0.
- P18 — Edit `README.md` row 9: add `/glab:project-plan-accept`, `/glab:project-plan-analyze` and `/glab:project-record` to the stage-skill list. Post: `/usr/bin/grep -c 'glab:project-plan-accept' README.md` ≥ 1, and the same for the other two; the version is untouched (`jq` prints `0.15.0`).

### After

- A1 — Markers. The B1 counts are unchanged: `project-developer.md` 1, `AGENTS.md` 2, and every other touched file and all five new files 0.
- A2 — The milestone below, pasted into `result.md`, with the measured *after* column for the record.

## Milestone (master *Final check* steps 1, 2, 4, 5)

1. Both *Gates* blocks of `AGENTS.md`, as written after P17, under the `CLAUDE_CONFIG_DIR` rule. Expect:
   - nine `rc=0` lines, shellcheck `rc=0`, and five `PASS n/n` with every line `ok` (no script or test changed);
   - three `✔ Validation passed`;
   - `Skills (25)` naming exactly AGENTS.md's list; `Agents (9)`; `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop`;
   - the model gate's nine lines and the skills gate's eighteen lines as listed, none `MISSING` — the planner still preloads `glab:project-plan` and `glab:security`.
2. The two old-name searches of *Final check* step 2: the first prints only `rc=1`, the second `0`. The new names `project-plan-accept`, `project-plan-analyze` and `project-record` do not match its alternation, because each is followed by `-` or a letter.
4. *Final check* step 4's block verbatim. Expect:
   - `proj` ≤ 47104 (target 44247)
   - `prod` ≤ 47104 (≈ 45012)
   - `task` ≤ 81920 (target 80694)
   - `list` ≤ 10240 (≈ 9834)
   - `files=34 onel=34`
   - `project-manager` ≤ 10240 (target 10000), `session-rules` ≤ 13312, `bootstrap` 5212 ≤ 6144
   - `project-analyzer` ≤ 23580, `project-plan-analyzer` ≤ 23288, `project-reviewer` ≤ 27973, `product-analyzer` ≤ 16657, `project-planner` ≤ 31168 (target 30944)
5. *Final check* step 5's block verbatim. Every `project-*` line prints a count of 1 or more and no line prints `missing`; the three `project-manager` lines print `0`.

## Tests and coverage

- No shell script or test changes, so no new case and no mutant (D18: mutants only for a changed shell branch). The five suites in Milestone 1 prove the hook text, which P12 must not change: `tests/manager-bootstrap.test.sh` and `tests/product-loop.test.sh` assert `PROJECT_MGR`, and *The pipeline*/*Pick the tier* stay (W1).
- P1–P11 and P13–P15 (moved prose): covered by each step's `grep -cF` post-conditions and Milestone 4–5. No test reads prose meaning. That is accepted because the change is prose, and the analyzer's Stage 3 conformance check is the semantic check.
- P12: Milestone 4 (bytes), Milestone 5 (absences), P12's eight heading counts, Milestone 1 (hook tests).
- P16–P18: P16's `rc=1` search, P17's counts, Milestone 1's gate lists, Milestone 2.
- Not covered by any case: whether a manager acting on the new PM behaves as before (only a live run shows that, and it is a record follow-up), and whether a repeated `Skill` call re-injects a body (W12, UNVERIFIED).

## Record

Additions for the master's *Record* (D15: carried by Stage 8, not edited here):

- `docs/specs/workflow.md`:
  - PM's sections after 03 and the stage skill that holds each stage (the byte table and P12's budget table above);
  - the planner writes the tier line and `project-plan-accept` accepts or raises it (W3/D7);
  - Stage 3 and 6b dispatches carry the slug only (W5/D8);
  - `project-planner` without the `Skill` tool (D9);
  - the measured *after* column of G5 from A2.
  - Not verified: re-injection on a repeated `Skill` call (W12/D14); the `proj` difference between 02's 75074 and the 75302 measured on HEAD here.
  - Follow-ups:
    - F27, the Go test policy in `project-developer.md` (W19/D13);
    - dropping the pre-0.10/0.11 clauses (F11/W6);
    - a no-subagent note for the product level (W10);
    - `docs/specs/workflow.md:117`'s skill list lacks `severity` (02's follow-up), and now also the three new skills.
- `docs/specs/marketplace.md`: 25 skills, with the three new names.
- `plan/flow-project-level/audit.md`, acted on by 03:
  - F1 and F2: P1–P12
  - F3: P13, P14
  - F4: P1, P13
  - F5: P6
  - F7: P3, P6, P8, P12
  - F9: P5, P8, P10, P12
  - F11: P3
  - F12: P6, P8, P9
  - F14 and F15: P12
  - F16: P5
  - F17: P12, P15
  - F18: P5, P16
  - F19: P11, P15
  - F20: P2
  - F21: P12
  - F23: P17
  - F26: P12, P13
  - F27: left, as a follow-up

## Not done

- No step was run. Every *after* number in this plan is a target or an inference until A2 measures it. In P12's budget table, the HEAD bytes are measured and the budgets and the "≈ −" savings are inferred.
- The exact wording of each condensed passage is the developer's, held to the post-conditions. I did not read `evidence.md` or audit §1/§3/§7, nor `project-plan` Steps 1–4 in full, beyond the lines cited. I also did not read `product-manager` beyond a search. Within the budget I judged none of them necessary for 03's scope.
- `docs/specs/` is untouched (D15).
- The user's measure — the share of the Ultra plan over 8 hours — stays the master's after-install follow-up.
