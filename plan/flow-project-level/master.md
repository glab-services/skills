# flow-project-level — master

`glab` 0.15.0. Analysis: `audit.md` (findings F1–F27) and `evidence.md` (E1–E10), both in this folder. The split and its decisions: `index.md`.

Version 2 of this master, for the changed request of words 5 and 6; version 1, approved 2026-11-14 on base `0a44fac`, is kept as `master.v1.md`. Sub-plan 01-rename was built and committed under v1 as `1bbf4bc` (not pushed) and stands: v2 changes none of its goals and none of its files' content.

## Request

The user's words, verbatim. The first was recorded in `audit.md` on 2026-11-13; all four were relayed by the manager in the planning dispatch of 2026-11-14. The original dates of words 2–4 are not in the dispatch.

1. (2026-11-13) "these skills are still let's revalidate and move to product:project:* group, also project manager skills is extremely big about 40k characters, it's a lot, let's fix this make it light weight like a product manager skill. It's simply not financially viable to use 40k lines."
2. (relayed 2026-11-14) Asked how to name the project-level skills, the user chose "glab:project-* (Recommended)".
3. (relayed 2026-11-14) Asked whether the six project agents are renamed too: "Yes, rename agents".
4. (relayed 2026-11-14) The reason for all of it: "ensure that this flow doesn't consume more than 20% of the Ultra package over an 8-hour period".
5. (2026-11-14, relayed verbatim by the manager in the v2 planning dispatch) "product and project all agents are must have own handoff files in plan/handoff/sessionId.md / managers are must clean completed sessions handoffs, just remove them, / managers them self must keep handoff file small"
6. (2026-11-14, relayed) Asked whether to fold words 5 into this slug, the user chose "Master v2".

## Goals

- **G1** — The project manager is "light weight like a product manager skill" (words 1): `plugins/glab/skills/project-manager/SKILL.md` is at most 10240 bytes (`glab:product-manager` is 10897; `glab:manager` is 40284, E1), and holds only what the manager acts on at every stage; each stage's detail lives in the skill that runs that stage (F1, F2).
- **G2** — The project-level skills "move to [the] project … group" as `glab:project-*` (words 1, 2): `manager`, `plan`, `develop`, `analyze`, `integrate`, `review`, `ship` become `project-<name>`, `product-project-plan-report` becomes `project-plan-report`, and every new project stage skill is `project-*`. The shared skills (`session-rules`, `bootstrap`, `security`, `comments`, `audit`, `commit`, `push`) and the product skills keep their names. No old name is left in the payload, `README.md`, `AGENTS.md` or `tests/`, and `README.md` says what each old name became, since a typed `/glab:plan` stops working.
- **G3** — The six project agents are renamed "too" (words 3): `planner`, `plan-analyzer`, `analyzer`, `developer`, `integrator`, `reviewer` become `project-<name>`. `committer` and the product agents keep their names.
- **G4** — The project skills and agents are "revalidate[d]" (words 1): every conflict has one owner — who writes the tier line (F4), what the Stage 3 analyze dispatch carries (F5), what the planner may load (F3) — and every finding F1–F27 is either resolved by a named sub-plan step or carried to the record as a follow-up with its reason. Each rule lives with the role that acts on it.
- **G5** — The flow costs less (words 1 "not financially viable", words 4): the bytes each session and stage loads fall to these caps, measured with `wc -c` as *Final check* step 4 does. The byte caps are the proxy this slug can prove. They are not the user's measure. The user's measure is the share of the Ultra plan, taken with `get_usage` before and after a live run on the user's test repo, once the user has installed 0.15.0. That run is a named follow-up of the record (*Record*). The master's approval covers this split: the caps are proven here, and the share is measured after install (manager's decision, plan check round 1).

  | Measure | Before (E2) | Cap after |
  |---|---:|---:|
  | Project session start: hook + `bootstrap` + the manager + `session-rules` + `security` | 86621 | 47104 |
  | Product session start: the same with `product-manager` | 57203 | 47104 |
  | One normal-tier task, single plan, one round per stage, each stage skill once (E2's set, plus `project-plan-accept`, `project-plan-analyze` and `project-record`) | 101726 | 81920 |
  | Skill and agent listing (`description:` lines) | 9614 | 10240 |
  | `glab:session-rules` | 22435 | 13312 |
  | `glab:bootstrap` | 8234 | 6144 |
  | Each of `project-analyzer`, `project-plan-analyzer`, `project-reviewer`, `product-analyzer`: agent file + preloaded skills | 26580, 26288, 30973, 19657 | each at least 3000 lower |
  | `project-planner`: agent file + `project-plan` + `security` | 31168 | no higher |

- **G6** — Every manager session has its "own handoff file[] in plan/handoff/sessionId.md", the managers "clean completed sessions handoffs, just remove them", and each manager keeps "handoff file small" (words 5). "All agents" is read as every manager session, at the product and the project level alike; subagents write no handoff (the manager's reading, relayed in the v2 dispatch). True when done: the session id reaches the manager in the `SessionStart` text, which names `plan/handoff/<session id>.md` (D21); the file holds the current state only, rewritten in place, at most 4096 bytes (D22); a status line says whether it is completed (D23); the manager removes its own file at the task boundary, and `glab:bootstrap` step 5 removes completed files, picks up in-flight work and never removes a file of a session that may still run without the user's yes (D24, D25); the user's standing instruction (words 5) is the one standing approval of a removal, it covers a file `plan/handoff/<id>.md` whose first line is `- status: completed`, and nothing else, and it lives in `glab:session-rules` Rule 2, which the destructive-action rules of `glab:security` and `glab:session-rules` Rule 3 point at (D30); `plan/handoff/` is ignored by git in this repo (D27); no payload, `AGENTS.md` or test line names `plan/SESSION-HANDOFF.md` except step 5's one legacy pickup (D26). G5's caps bind the new text: `session-rules` ≤ 13312, `bootstrap` ≤ 6144, and the session-start totals, which hold the hook text.

## Out of scope

- later-1 (`omitClaudeMd`) and later-2 (the hook-based loader): "in the end when we will finish all agents" (the user's words, relayed by the manager 2026-11-14).
- The delivery and support levels: "I'm still thinking about delivery skills structure I will let you knew when I will ready" (the user's earlier words, relayed by the manager 2026-11-14).
- The user's separate request of 2026-11-14 — plan files never committed, the product manager writing `docs/roadmap/<name>.md`, the project manager writing `docs/specs` and `docs/features` — is its own slug after this one (the manager's decision, relayed in the round-1 amendment dispatch).

## Final check

Run from the repo root on the tree after the last sub-plan's commit, `TMPDIR` exported as the host file says. Each step's expected output is the green result.

1. **The gates.** Both blocks of `AGENTS.md` *Gates*, as written there after this change: nine `rc=0` lines, shellcheck `rc=0`, five `PASS n/n` with every line `ok`; three `✔ Validation passed`; `Skills (25)` naming exactly the list `AGENTS.md` then gives — the 21 of E5 plus `project-plan-accept`, `project-plan-analyze`, `project-record` and `severity` — and `Agents (9)` naming `committer`, `product-analyzer`, `product-planner` and the six `project-*` agents; the model gate's nine lines and the skills gate's eighteen lines exactly as `AGENTS.md` lists them, none `MISSING`.
2. **No old name.** Both searches below, from a fenced block so the backticks are literal. The first prints only `rc=1`. The second prints `0`; on the tree before 01-rename it prints `1` (E8).
   ```
   /usr/bin/grep -rnE 'glab:(manager|plan|develop|analyze|integrate|review|ship|planner|plan-analyzer|analyzer|developer|integrator|reviewer|product-project-plan-report)([^-a-z]|$)|skills/(manager|plan|develop|analyze|integrate|review|ship|product-project-plan-report)/|agents/(planner|plan-analyzer|analyzer|developer|integrator|reviewer)\.md' plugins README.md AGENTS.md tests host.example.md .claude-plugin; echo "rc=$?"
   /usr/bin/grep -E '^- for .glab.: .Skills' AGENTS.md | /usr/bin/grep -cE '`(manager|plan|develop|analyze|integrate|review|ship|planner|plan-analyzer|analyzer|developer|integrator|reviewer|product-project-plan-report)`'
   ```
3. **The version and the migration note.** `jq -r .version plugins/glab/.claude-plugin/plugin.json` prints `0.15.0`; `README.md` has one line per old skill and agent name, naming its new one (`/usr/bin/grep -c` on the section 01-rename's plan names prints 14), and one line on `- model: glab:<old agent> …` lines in plan folders begun before 0.15.0, which name agents that no longer exist (D17).
4. **The bytes (G5).** This prints the four sums and the three files, each at or under its cap:
   ```
   S=plugins/glab/skills; w=$(mktemp -d "${TMPDIR:?}/fpl-final.XXXXXX") && mkdir -p "$w/proj" "$w/prod" && printf 'glab-level: product\n' >"$w/prod/AGENTS.md"
   h(){ CLAUDE_PROJECT_DIR="$w/$1" bash plugins/glab/scripts/manager-bootstrap.sh </dev/null 2>/dev/null | jq -r .hookSpecificOutput.additionalContext | wc -c; }
   b(){ cat "$@" | wc -c; }
   core=$(b $S/bootstrap/SKILL.md $S/session-rules/SKILL.md $S/security/SKILL.md)
   proj=$(( $(h proj) + core + $(b $S/project-manager/SKILL.md) )); prod=$(( $(h prod) + core + $(b $S/product-manager/SKILL.md) ))
   task=$(( proj + $(b $S/project-plan-accept/SKILL.md $S/project-plan-analyze/SKILL.md $S/project-develop/SKILL.md $S/project-integrate/SKILL.md $S/project-review/SKILL.md $S/commit/SKILL.md $S/project-analyze/SKILL.md $S/push/SKILL.md $S/project-record/SKILL.md) ))
   list=$(cat $S/*/SKILL.md plugins/glab/agents/*.md | /usr/bin/grep '^description: ' | wc -c)
   files=$(ls $S/*/SKILL.md plugins/glab/agents/*.md | wc -l); onel=$(cat $S/*/SKILL.md plugins/glab/agents/*.md | /usr/bin/grep -c '^description: .\{40,\}')
   echo "proj=$proj prod=$prod task=$task list=$list files=$files onel=$onel"; wc -c $S/project-manager/SKILL.md $S/session-rules/SKILL.md $S/bootstrap/SKILL.md; rm -rf "${w:?}"
   for a in project-analyzer project-plan-analyzer project-reviewer product-analyzer project-planner; do f=plugins/glab/agents/$a.md; n=$(wc -c <"$f"); for s in $(awk '/^---$/{n++; next} n==1 && /^  - glab:/{sub(/^  - glab:/,""); print}' "$f"); do n=$((n + $(wc -c <"$S/$s/SKILL.md"))); done; echo "$a $n"; done
   ```
   Caps: `proj` ≤ 47104, `prod` ≤ 47104, `task` ≤ 81920, `list` ≤ 10240 and `onel` equal to `files` (every description is one line, so a block-scalar `description: >-` cannot slip past `list`; today 30 = 30, E8); `project-manager` ≤ 10240, `session-rules` ≤ 13312, `bootstrap` ≤ 6144; the first four agents each at least 3000 below their *Before* in G5, `project-planner` ≤ 31168.
5. **Each stage's detail is in its stage skill, not the manager (G1, F1, F2).** Each `project-*` line prints a count of 1 or more; the three `project-manager` lines print `0`. The strings are verdicts and file names that other files register (`AGENTS.md` *One fact*), so a stage skill that holds its stage must name them. On today's tree every line prints `missing`, since no `project-*` skill exists yet; the same three strings occur 11, 1 and 1 times in today's `manager/SKILL.md` (E8).
   ```
   S=plugins/glab/skills; c(){ n=$(/usr/bin/grep -cF -- "$2" "$S/$1/SKILL.md" 2>/dev/null); echo "$1 [$2] ${n:-missing}"; }
   c project-plan 'schema or data migration'; c project-plan-accept 'sha256sum plan/'; c project-plan-accept '## Approval'; c project-plan-accept '- size: '
   c project-plan-analyze 'NOT BUILDABLE'; c project-plan-report 'after-verdict.md'; c project-develop 'PLAN WRONG'; c project-develop 'BLOCKED'
   c project-analyze '-analyze-r'; c project-integrate 'INTEGRATED'; c project-review 'SHIP'; c project-record 'docs/specs'
   c project-manager '## Stage '; c project-manager 'sha256sum'; c project-manager 'Plan acceptance checklist'
   ```
6. **Every finding is placed (G4).** Run over the sub-plans only: `for f in $(seq 1 27); do printf 'F%s ' $f; cat plan/flow-project-level/0*/plan.md | /usr/bin/grep -cw "F$f"; done` prints no `0`. Then run each sub-plan's milestone searches once more (the owners of F3, F4 and F5 among them); each prints what its plan says.
7. **One commit per sub-plan, in `<nn>` order,** on top of the master's base: `git log --format=%s <base>..HEAD` shows three Conventional Commits, and the first raises the version. A plan folder is committed with its change (`AGENTS.md` *Rules*, the `plan/` rule). So 01-rename's commit carries the slug-level files `master.md`, `master.sha256`, `index.md`, `evidence.md` and `audit.md` with `01-rename/`; 02's carries its own folder, the slug-level files v2 changed (`master.md`, `master.v1.md`, `master.sha256`, `index.md`, `evidence.md`) and the round copies written since; 03's its own folder and its round copies.
8. **The handoff files (G6).** From a fenced block. The first search prints only `plugins/glab/skills/bootstrap/SKILL.md` (on `1bbf4bc` it prints that file, `plugins/glab/skills/session-rules/SKILL.md` and `AGENTS.md`, E10). The four hook runs print `1`, `0 1`, `0 1` and `1`; the last line prints `rc=0` (today `rc=1`, E10). `tests/manager-bootstrap.test.sh` is among step 1's `PASS` lines and holds the cases 02's plan names for these runs.
   ```
   /usr/bin/grep -rl 'SESSION-HANDOFF' plugins README.md AGENTS.md tests host.example.md
   w=$(mktemp -d "${TMPDIR:?}/fpl-g6.XXXXXX"); t(){ CLAUDE_PROJECT_DIR=$w bash plugins/glab/scripts/manager-bootstrap.sh 2>/dev/null | jq -r .hookSpecificOutput.additionalContext; }
   printf '{"session_id":"abc-123","source":"startup"}' | t | /usr/bin/grep -cF 'plan/handoff/abc-123.md'
   echo "$(t </dev/null | /usr/bin/grep -c 'plan/handoff/[A-Za-z0-9]') $(t </dev/null | /usr/bin/grep -c 'no session id')"
   echo "$(printf '{"session_id":"../x"}' | t | /usr/bin/grep -c 'plan/handoff/\.\.') $(printf '{"session_id":"../x"}' | t | /usr/bin/grep -c 'no session id')"
   printf '{"session_id":"abc-123","source":"compact"}' | t | /usr/bin/grep -cF 'plan/handoff/abc-123.md'; rm -rf "${w:?}"
   git check-ignore -q plan/handoff/x.md; echo "rc=$?"
   S=plugins/glab/skills; c(){ n=$(/usr/bin/grep -cF -- "$2" "$1" 2>/dev/null); echo "$1 [$2] ${n:-missing}"; }
   for s in 'plan/handoff/' '4096' 'status: completed' 'standing approval' 'remove your own handoff file'; do c $S/session-rules/SKILL.md "$s"; done
   echo "rule2 [and nothing else] $(sed -n '/^## Rule 2/,/^## Rule 3/p' $S/session-rules/SKILL.md | /usr/bin/grep -cF 'and nothing else')"
   echo "rule3 [standing approval] $(sed -n '/^## Rule 3/,/^## Rule 5/p' $S/session-rules/SKILL.md | /usr/bin/grep -cF 'standing approval')"
   for s in 'plan/handoff/' 'status: completed' 'in-flight' 'Rule 2'; do c $S/bootstrap/SKILL.md "$s"; done
   c $S/security/SKILL.md 'standing approval'
   for s in 'plan/handoff/<session id>.md' '.gitignore' 'standing approval' '`plan/handoff/` is never committed'; do c AGENTS.md "$s"; done
   ```
   Each `c`, `rule2` and `rule3` line prints a count of 1 or more: `rule2` shows Rule 2 holds D30's narrowing words, `rule3` that Rule 3's pointer (`:99`) is there by itself. On `1bbf4bc` every `c`, `rule2` and `rule3` line prints `0` (E10). `4096` is searched in `session-rules` only: Rule 2 owns it and step 5 points at Rule 2 (*One fact, one value*). The fixed words — `no session id` (D21), `standing approval` (D30), `remove your own handoff file` (D24) — are the searches' anchors; 02's plan may choose other words and then changes this step's searches to them, nothing else.

## Record

After the push, the record stage (Stage 8) updates:

- `docs/specs/workflow.md` — the project level as of 0.15.0: the old → new names; the manager's sections and that each stage skill holds its stage; who writes the tier line; what Stage 3's dispatch carries; `glab:severity`; the G5 table with the measured *after* column; the decisions of `index.md` and the sub-plans that still bind. Not verified: whether a repeated `Skill` call injects the body again, whether a preloaded skill loads in full, what a compaction keeps (`audit.md` *How the numbers were taken*), and the 20 % of Ultra over 8 hours. Follow-ups: measure that budget with `get_usage` on the punching-bag repo; F27 (Go test policy in the developer); dropping the pre-0.11.0 clauses (F11); `glab:security` Part 2 and the `push` rationale as further levers; later-1 and later-2; and each rationale passage a sub-plan moved out of the payload, named in that sub-plan's plan.
- `docs/specs/product.md` — the product level's side: the level-boundary exception gone (F13), `glab:product-analyzer` preloading `glab:severity`, the product session start before and after.
- `docs/specs/marketplace.md` — the *Gates* lists (25 skills, the renamed agents, the model and skills gate lines) and the old-name search of *Final check* step 2.
- `docs/specs/workflow.md` and `docs/specs/marketplace.md`, for G6 — the per-session handoff file as of 0.15.0, replacing the current-state lines that name `plan/SESSION-HANDOFF.md` (E10 lists them; the dated follow-up and record lines stay as records). After the record, from `docs/specs/`: `/usr/bin/grep -cF 'SESSION-HANDOFF.md` (`glab:bootstrap` step 5' marketplace.md` and `/usr/bin/grep -cF 'removed; `plan/SESSION-HANDOFF.md` is' marketplace.md` print `0` (today `1`, `1`), `/usr/bin/grep -cF 'SESSION-HANDOFF.md` unless the repo keeps it elsewhere' workflow.md` prints `1`, the dated D22 line of `:1506` (today `2`), and `/usr/bin/grep -cF 'plan/handoff/' marketplace.md workflow.md` prints `1` or more for each (today `0`, E10); the `SessionStart` hook's new input and the no-id text; D21–D27. Not verified: whether `session_id` is unchanged after `/compact` and on `resume` (E9); whether a live session can be told from a dead one (D25). Follow-up: the user's other repos keep no `.gitignore` line for `plan/handoff/` unless their owners add one (D27).
- `plan/flow-project-level/audit.md` — acted on: each of F1–F27, with the sub-plan that resolved it or the follow-up that carries it.

## Approval

- approved by the user, 2026-11-14, in chat: "Yes, approve", which answers the question asked with it, "Approve master v2, with subagents writing no handoff?"; base 1bbf4bc (01-rename, under v1)
