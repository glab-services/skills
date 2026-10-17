# Follow-ups — feature-docs-specs

Advisories left by review round 3/3 (both reviewers `SHIP`, 2026-10-18). Not
applied: they would be unreviewed change on top of the reviewed one. Each goes
into the area spec's *Open follow-ups* at this change's record (X1), and the
payload ones into one small change of their own.

Payload and rules reviewer:

1. `AGENTS.md:225` — the `git archive` read-back extracts into a directory it
   never prints. Fix: `t=$(mktemp -d "${TMPDIR:?}/plan.XXXXXX") && git archive
   <sha> plan/<slug>/ | tar -x -C "$t" && echo "$t"`.
2. `plugins/glab/agents/analyzer.md:56`, `plugins/glab/agents/developer.md:98`
   — the record reads every file of `plan/<slug>/`, untracked ones included; a
   scratch file holding host values could reach a committed spec
   (`glab:security`). Fix: read `git ls-files -- plan/<slug>/` and name any
   untracked file in the report instead.
3. `README.md:226` — the `plan/` row says "removed once each change is
   recorded"; `AGENTS.md` removes a folder only once it has landed on
   `origin/main`. Fix: "removed after each change has landed, under this
   repo's `AGENTS.md`".
4. `plugins/glab/skills/bootstrap/SKILL.md:125` — "not in `plan/`" is wrong in
   a repo that keeps its plans (the default). Fix: "is there; `plan/` may
   still hold the working files".
5. `plugins/glab/skills/manager/SKILL.md:127` vs Stage 8's "not in
   `plan.md`" — a model the user names for the record's developer has nowhere
   to be recorded. Fix: one clause in Rule 5: for Stage 8 the instruction
   lives in the conversation only, as for a `/glab:review` with no plan.
6. `AGENTS.md:220-224` — the repo's removal rule should name the forms that
   are never valid: never `plan/`, `plan/.`, or a slug outside
   `[A-Za-z0-9._-]` (review round 2 measured that `plan/./` removes every
   folder under `plan/`).
7. Commits rule: the payload diff holds two logical changes (the Stage 8
   record and the re-pointed citations); committed as one, under 0.5.0.

Specs reviewer:

8. `docs/specs/*.md` *Records* lines, `external-agents.md:304`, `:603`, and
   `AGENTS.md:224` — `git ls-tree -r --name-only <sha> -- plan/<slug>/` prints
   nothing when run from a subdirectory (exit 0). Fix: add `--full-tree`, in
   the specs and `AGENTS.md` in the same commit.
9. The specs describe the lifecycle as of `6838133`. X1 must also update the
   pipeline bullet at `workflow.md:25-31` and the Rule 5 duration sentence at
   `workflow.md:96-97`, besides what plan.md X1 lists.
10. A stray `__pycache__/fixes-r2.cpython-314.pyc` in this folder — removed by
    the manager before commit.

Conformance round 3/4 hand-off: same as 3 above (`README.md:226`).
