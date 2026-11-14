# Evidence — flow-project-level (the master and the split)

Slug-level evidence for `master.md` and `index.md`, taken on `main` at `0a44fac`, `glab` 0.14.1, on 2026-11-14. The section-by-section analysis is `audit.md` beside this file (the slug's mapping file, taken at `f6fcb14`); its findings are cited as F1–F27 and not restated. This file holds only what the audit left open or what changed since it.

## E1 — The audit's byte counts still hold at 0a44fac

`0.14.1` changed none of the files the audit measured:

```
$ git diff --stat f6fcb14 0a44fac -- plugins/glab/skills plugins/glab/agents plugins/glab/scripts/manager-bootstrap.sh
(no output)
```

Re-measured anyway (`wc -c`, and the hook run with `CLAUDE_PROJECT_DIR` set to a scratch folder, one with `glab-level: product` in its `AGENTS.md`):

```
proj hook=2425
prod hook=2394
   953 integrate   966 review  1107 commit  1572 product-project-plan-report  1963 analyze  3000 ship
  3127 develop  3812 audit  6989 push  8234 bootstrap  10897 product-manager  13243 security
 15422 plan  22435 session-rules  40284 manager
descriptions=9614      # cat plugins/glab/skills/*/SKILL.md plugins/glab/agents/*.md | grep '^description: ' | wc -c
```

The listing figure is 9614 bytes, not the audit's 9584: this count includes the `description: ` key and the newline of each of the 30 lines. The audit's method for that one figure is not recorded, so this file's command is the one the final check uses.

## E2 — The baseline the budget goal is measured against

Proven sums of E1's numbers (the token figures in `audit.md` are inferred and not used here):

| Moment | Formula | Bytes |
|---|---|---:|
| Project session start | hook 2425 + `bootstrap` 8234 + `manager` 40284 + `session-rules` 22435 + `security` 13243 | **86621** |
| Product session start | hook 2394 + 8234 + `product-manager` 10897 + 22435 + 13243 | **57203** |
| Skill and agent listing, both levels | E1 | **9614** |
| One normal-tier task, single plan, one round per stage, each stage skill invoked once (Stage 3 skipped; 6b re-uses the loaded `analyze`; Stage 8 reuses the loaded `commit` and `push`) | 86621 + `analyze` 1963 + `develop` 3127 + `integrate` 953 + `review` 966 + `commit` 1107 + `push` 6989 | **101726** |

`audit.md` §1 gives 101725 for the last row; the sum of its own terms is 101726. This file's figure is the one used.

Per dispatch (agent file + preloaded skills, sizes proven, full preload UNVERIFIED as `audit.md` says): `analyzer` 26580, `plan-analyzer` 26288, `reviewer` 30973 — each carrying `audit` 3812 for its 366-byte *Severity Levels* (F10).

## E3 — Every file that names a renamed component

```
$ P='glab:(manager|plan|develop|analyze|integrate|review|ship|planner|plan-analyzer|analyzer|developer|integrator|reviewer|product-project-plan-report)([^-a-z]|$)'
$ /usr/bin/grep -rcE "$P" plugins README.md AGENTS.md tests host.example.md .claude-plugin | /usr/bin/grep -v ':0$' | sort
AGENTS.md:8   README.md:10
plugins/glab/agents/analyzer.md:8  developer.md:4  integrator.md:1  plan-analyzer.md:6  planner.md:7
plugins/glab/scripts/manager-bootstrap.sh:1  plan-gate.sh:2
plugins/glab/skills/analyze:5  audit:4  bootstrap:2  commit:1  develop:8  integrate:3  manager:46  plan:14
  product-manager:1  product-project-plan-report:4  push:1  review:4  session-rules:16  ship:6
tests/manager-bootstrap.test.sh:1  tests/plan-gate.test.sh:1  tests/product-loop.test.sh:15
$ ... | wc -l          # lines in all
179
```

Path forms — `skills/<old>/` and `agents/<old>.md` — appear 78 times in `AGENTS.md` (the *One fact* entries and the gates' expected lines) and 5 times in `README.md`. Bare backticked names appear on one line: `AGENTS.md:76`, the *Gates* `Skills (21)` / `Agents (9)` lists. `host.example.md`, `.claude-plugin/` and `tests/fixtures/` name none.

`docs/specs/` names old components on 377 lines (`workflow.md` 300, `external-agents.md` 36, `marketplace.md` 35, `product.md` 5, `memory-sync.md` 1). Specs state facts as of their last record and are updated by the record (`AGENTS.md` *Rules*, the `plan/` rule), so no sub-plan edits them; the record does (`master.md` `## Record`).

## E4 — plan-gate.sh after 0.14.1 (F24 is resolved)

```
$ /usr/bin/grep -nE 'glab:|planner|developer|analyzer|reviewer|integrator' plugins/glab/scripts/plan-gate.sh
5:# glab:product-project-plan-report) and verdict.r<n>.md (the product manager, through
6:# glab:product-project-plan-verdict). glab:develop runs `check` before any developer is dispatched.
430:	# whoever looks at it decides (glab:security, detect and surface). Tested under the claim only:
472:	# the analyzer is given the whole folder: the copy holds exactly the files list_plan prints.
```

`flow-gate-hardening` landed as `2724086` (0.14.1), so F24's wait is over. Only the comments at `:5-6` name renamed components; `:472` is a role word and stays. No line the script parses holds a component name, so the rename changes no stored format the gate reads. The `- model: glab:developer opus …` lines in `tests/plan-gate.test.sh:305` and `tests/product-loop.test.sh:220` sit in `after-verdict.md`, which the digest leaves out; they are test data and are renamed with the rest.

## E5 — The rename works end to end: a dry run in a throwaway clone

A clone of `0a44fac` under `$TMPDIR`, renamed by this script, then every gate of `AGENTS.md` *Gates* run in it. The clone was removed afterwards.

```
for s in manager plan develop analyze integrate review ship; do git mv plugins/glab/skills/$s plugins/glab/skills/project-$s; sed -i "s/^name: $s\$/name: project-$s/" plugins/glab/skills/project-$s/SKILL.md; done
git mv plugins/glab/skills/product-project-plan-report plugins/glab/skills/project-plan-report   # and its name: line
for a in planner plan-analyzer analyzer developer integrator reviewer; do git mv plugins/glab/agents/$a.md plugins/glab/agents/project-$a.md; sed -i "s/^name: $a\$/name: project-$a/" plugins/glab/agents/project-$a.md; done
perl -pi -e 's/glab:(manager|plan|develop|analyze|integrate|review|ship|planner|plan-analyzer|analyzer|developer|integrator|reviewer)(?![-a-z])/glab:project-$1/g; s/glab:product-project-plan-report(?![-a-z])/glab:project-plan-report/g; s{skills/(manager|plan|develop|analyze|integrate|review|ship)/}{skills/project-$1/}g; s{skills/product-project-plan-report/}{skills/project-plan-report/}g; s{agents/(planner|plan-analyzer|analyzer|developer|integrator|reviewer)\.md}{agents/project-$1.md}g' $(git ls-files plugins README.md AGENTS.md tests host.example.md)
perl -pi -e 'if ($.==76) { s/`(manager|plan|develop|analyze|integrate|review|ship|planner|plan-analyzer|analyzer|developer|integrator|reviewer)`/`project-$1`/g; s/`product-project-plan-report`/`project-plan-report`/g }' AGENTS.md
```

Results in the clone:

```
absence grep (E3's pattern, plus the path forms) over plugins README.md AGENTS.md tests host.example.md .claude-plugin → no line, rc=1
nine "<script> rc=0" lines; shellcheck rc=0
PASS 35/35  PASS 24/24  PASS 51/51  PASS 13/13  PASS 17/17   (memory-sync, context-size, plan-gate, manager-bootstrap, product-loop; 0 lines that are neither ok nor PASS)
✔ Validation passed ×3
  Skills (21)  audit, bootstrap, comments, commit, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-verdict, project-analyze, project-develop, project-integrate, project-manager, project-plan, project-plan-report, project-review, project-ship, push, security, session-rules
  Agents (9)  project-planner, product-planner, project-developer, project-integrator, product-analyzer, committer, project-analyzer, project-reviewer, project-plan-analyzer
  Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)
glab = glab ; memory-sync = memory-sync ; user_config :0 :0 rc=1 ; 'not yet confirmed' 1 1 1 rc=0
model gate: nine lines, project-* names, same models; skills gate: eighteen lines, none MISSING ; prefixed name: no line, rc=1
```

This proves: an agent named `project-plan-analyzer` and a skill named `project-plan` load under the plugin; a `skills:` entry `glab:project-plan` resolves; the hook test and the product-loop test pass once their expected strings move with the hook text. What it does not prove: the sentences that become false after a mechanical rename (E6), the README's migration note, the version, and the text of any other sub-plan.

## E6 — Text a mechanical rename makes false

- `session-rules/SKILL.md:10` ends: "a name's prefix does not always say the level — `glab:product-project-plan-report` is the project level's." After the rename it would read `glab:project-plan-report` is the project level's, which is true and needs no exception (F13).
- `product-manager/SKILL.md:23`: "`glab:product-project-plan-report` is not on it: `glab:session-rules` *The level boundary* says why." Same.
- `README.md:9` and the `## Levels` section list the components by name; a user who types `/glab:plan` after 0.15.0 gets no skill. The README must say what each old name became (`AGENTS.md` *Rules*: an installed copy is pinned to the version string).

## E7 — Inputs for the decisions in `index.md`

- `plugins/glab/agents/planner.md:5` — `tools: Read, Write, Edit, Grep, Glob, Bash, Skill, WebFetch, WebSearch`; `:20` is the only line that gives the planner a use for `Skill` ("which is for the `glab:manager` sections it points at") (F3).
- `plugins/glab/agents/product-analyzer.md:8` preloads `glab:audit`; `:42` is its only use: "Rate each finding by `glab:audit`'s *Severity Levels*". A fourth agent with F10's pattern, beside `analyzer`, `plan-analyzer` and `reviewer`.
- `manager/SKILL.md:235`: "Summarise it to at most 10 lines for the user, then run `/glab:analyze {slug}` with the slug and that summary." `/usr/bin/grep -n 'result' plugins/glab/agents/analyzer.md` prints nothing: the analyzer never reads `result.md` nor a summary of it. The summary is for the user; the analyzer reads the tree and the plan (F5).
- `manager-bootstrap.sh:59` names `glab:manager` → *The pipeline* and *Pick the tier* and *Your skills — this level only*; `tests/manager-bootstrap.test.sh:37` and `tests/product-loop.test.sh:126` hold the same string. Keeping those three section titles in the new manager means no script or test changes after the rename sub-plan.
- `plugins/glab/.claude-plugin/plugin.json:3` — `"version": "0.14.1"`.

## E8 — The fixed *Final check* searches on today's tree (plan check round 1)

Run on `0a44fac` from the lines of `master.md` as written, extracted with `sed` and run with `bash`:

```
step 2, second search:   1
step 5:                  every line "<skill> [<string>] missing"   (15 lines; no project-* skill exists yet)
```

The same strings in today's `manager/SKILL.md` (`/usr/bin/grep -c`): `^## Stage ` 11, `sha256sum` 1, `Plan acceptance checklist` 1, `NOT BUILDABLE` 3, `DIVERGES` 5, `-analyze-r` 1, `PLAN WRONG` 4, `INTEGRATED` 2, `after-verdict.md` 2, `docs/specs` 2, `SHIP` 1. `schema or data migration` occurs once in the manager and 0 times in `plan/SKILL.md`. Those are the texts 03 moves. No step-5 string is in today's source of the skill it is searched in, so none passes after 01-rename alone: `project-plan`'s string is 0 in `plan/SKILL.md`; `project-analyze` is searched for `-analyze-r` (0 in `analyze/SKILL.md`), not `DIVERGES` (1 there, round 2 N1); `after-verdict.md` 0 in `product-project-plan-report`, `PLAN WRONG` and `BLOCKED` 0 in `develop`, `INTEGRATED` 0 in `integrate`, `SHIP` 0 in `review`; `project-plan-accept`, `project-plan-analyze` and `project-record` have no source file today. Descriptions: 30 files, and 30 lines match `^description: .\{40,\}`. `bootstrap/SKILL.md` has `## 5. Pick up the handoff` and `## 6. Know the hazards before you trust a result`, which `manager-bootstrap.sh:79` and `AGENTS.md:202` cite by number.
