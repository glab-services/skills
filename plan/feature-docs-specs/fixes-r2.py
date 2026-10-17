# Review round 2/3 scope cut (U10, U11): run from the repo root on the built tree.
# Each edit asserts its built text occurs exactly once and stops otherwise.
import re, subprocess
PF='plugins/glab/skills/plan-first/SKILL.md'; MG='plugins/glab/skills/manager/SKILL.md'
BASE='6838133'
# The four files whose round-1 record text the cut removes entirely go back to the base.
REVERT=['plugins/glab/agents/committer.md','plugins/glab/commands/commit.md','plugins/glab/commands/push.md','plugins/glab/commands/ship.md']
T_PF=("**Plan files are working files; the spec is what stays.** Once the change is pushed, `glab:manager` Stage 8 records it: a docs change updates the spec of each area the change touched — how the area works now, the decisions that still bind, what is not verified, and every follow-up still open and every incident, each under its source file and number. "
"Specs live in `docs/specs/`, one file per area, unless the repo's `AGENTS.md` names another place. "
"The record never removes `plan/{slug}/` or an audit file: whether a recorded plan folder is then removed, and how, is the repo's own `AGENTS.md` decision. "
"A plan folder whose `plan.md` has no `## Record` was written before the repo followed this rule, and Stage 8 does not record it.")
STAGE8='''## Stage 8 — Record

After Stage 7 has confirmed the push. What stays true moves into the spec of each area the change touched: `glab:plan-first` *Plan files are working files* is the rule, and `docs/specs/` the place unless the repo's `AGENTS.md` names another. The record changes the spec and nothing else. It never removes `plan/{slug}/` or an audit file: that is the repo's own `AGENTS.md` decision, carried out outside this stage. It is an ordinary docs change, through the normal commit and push.

- Dispatch `glab:developer` for the record alone: the slug, the area specs the plan's `## Record` names (for a waiver, the ones you name), and any audit file it names as a source. It writes the spec from the folder's files and the audit file, carries every follow-up still open, every binding decision and every incident with its source file and number, and changes nothing inside the folder.
- Dispatch `glab:analyzer` for the record check, at every tier: the spec diff against the folder's files and the audit file. `DIVERGES` goes back to the developer once, then to the analyzer again, which checks the fix; still `DIVERGES`: stop and tell the user.
- At full tier, one `glab:reviewer` pass on the spec diff alone — the target and nothing else, as in Stage 5. Its findings go back to the developer once, and the analyzer checks that fix too.
- Then `/glab:commit` with the spec files, and `/glab:push` on its own go-ahead.

A decision made at this stage goes in the dispatch and in the spec, not in `plan.md`: the folder is the record's source and does not change. A plan folder whose `plan.md` has no `## Record` predates the rule and is not recorded here.

'''
DEVREC=("When the dispatch says this is the record, that is your whole scope. Update the area specs the dispatch names — those the plan's `## Record` names — as `glab:plan-first` *Plan files are working files* says, from the files of `plan/<slug>/` and any audit file the dispatch names: how the area works now, the decisions that still bind, what is not verified, and every follow-up still open, every binding decision and every incident, each with its source file and number. None is dropped. "
"Change nothing inside `plan/<slug>/`, and remove nothing. Step 5 does not apply: write no `result.md`; your report is the reply alone, and `detail:` names the spec files. Step 3's gates run as for any change; where none reaches the spec files, say so in the report.")
ANALYZER='''## The record check — `glab:manager` Stage 8

When the dispatch says this is the record check, your contract is not a plan's steps but the folder: every file of `plan/<slug>/` and any audit file the dispatch names. Against the spec diff, report each follow-up, open item, binding decision and incident they record as `carried` (cite the spec's `file:line`) or `missing`. A follow-up the records closed may be carried as closed. End with the verdicts of *Report*: `CONFORMS` when every item is carried, `DIVERGES: <n> steps` otherwise, each missing item counted as one step.

'''
AUDIT="4. When a change acts on the file, its plan's `## Record` names it, and that change's record (`glab:manager` Stage 8) carries what is still open into the area spec and `glab:analyzer` checks it was carried. The record never removes the file; whether it is removed afterwards is the repo's own `AGENTS.md` decision."
README_P='''Each change's working files — findings, plan, results — live in
`plan/<slug>/`. Once the change has been pushed, the workflow records what
stays true — how the area works, the decisions that still bind, what is open
— in `docs/specs/<area>.md`, as a docs commit of its own. It never removes the
plan folder: whether a repo does is that repo's `AGENTS.md` decision. A
repo's `AGENTS.md` can also put specs elsewhere.
'''
AGENTS_RULE='''- **`plan/` is the working area; `docs/specs/` is what stays.** A change's
  `plan/<slug>/` is committed with the change. After its push, the record
  (`glab:manager` Stage 8) updates the spec of each area it touched —
  `marketplace.md` (the marketplace, this repo's layout, gates and rules),
  `workflow.md` (the `glab` workflow), `memory-sync.md`,
  `external-agents.md`: how the area works now, the decisions that still
  bind, what is not verified, every follow-up — open or closed, each tagged
  `[<slug>/<file> <id>]` — and its incidents, moved into *Incidents* rather
  than dropped (*Comments and recorded incidents are kept*). A spec states a
  fact as of its last record and names the file that owns it, so it is not
  one of the *One fact* files. Once the change has landed on `origin/main`,
  the manager session — not a `glab` step — removes the folder by its exact
  path in a `docs(repo)` commit, after checking that it is tracked, clean
  (`git status --short -uall -- plan/<slug>/` prints nothing) and identical
  on `origin/main` (`git diff --quiet origin/main -- plan/<slug>/`); the
  spec's *Records* line names the last commit on `origin/main` that holds
  it. Read it back without touching the tree: one file
  `git show <sha>:plan/<slug>/<file>`, the list
  `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole folder
  `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`.
  No untracked file under `plan/` is removed; `plan/SESSION-HANDOFF.md` is
  never committed.
'''
LIFE=("the plan lifecycle — specs in `docs/specs/` unless `AGENTS.md` names another place, the record after the push, and that the record never removes the plan folder "
"(`plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/commands/plan.md`, `plugins/glab/agents/developer.md`, `plugins/glab/agents/analyzer.md`, `plugins/glab/skills/bootstrap/SKILL.md`, `plugins/glab/skills/audit/SKILL.md`, `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`, and this file's `plan/` rule);")
PAIRS=[
(PF,"and once the change has landed records it in the area spec under docs/specs/.","and once the change is pushed records it in the area spec under docs/specs/."),
(PF,"- `## Record` — the area spec or specs this change updates once it has landed, any audit file under `plan/` it acts on, and what the entry will say.","- `## Record` — the area spec or specs this change updates once it is pushed, any audit file under `plan/` it acts on, and what the entry will say."),
(PF,"Its folder is recorded and removed like a plan's (*Plan files are working files*).","Its folder is recorded like a plan's (*Plan files are working files*)."),
(PF,"| Record | Spec entry; plan folder removed | the area spec, once the change has landed on the default branch (`glab:manager` Stage 8) |","| Record | Spec entry | the area spec, after the push (`glab:manager` Stage 8) |"),
(MG,"Run `/glab:commit`, and name `plan/{slug}/` in its scope: the plan folder is committed with the change, as a records commit of its own, unless the repo's `AGENTS.md` keeps plan files out of git. The `glab:committer` re-reads","Run `/glab:commit`. The `glab:committer` re-reads"),
(MG,"| the area spec; the plan folder removed |","| the area spec |"),
(MG,"| 8 Record | — | once the change has landed: the area spec updated, `glab:analyzer`'s check that every follow-up and incident is carried, and the plan folder removed, in one docs commit |","| 8 Record | — | after the push: the area spec updated and `glab:analyzer`'s check that every follow-up, decision and incident is carried, in one docs commit |"),
(MG,"A change with a plan folder goes on to Stage 8 once it has landed on the default branch.","A change with a plan folder goes on to Stage 8."),
(MG,"- Remove a plan folder before its change has landed on the default branch, before `glab:analyzer` has found every item carried, or when the repo's rule keeps it.","- Remove `plan/{slug}/` or an audit file as part of the record (Stage 8)."),
('plugins/glab/agents/analyzer.md',"it runs once the change has landed (`glab:manager` Stage 8),","it runs after the push (`glab:manager` Stage 8),"),
]
SLICES=[
('plugins/glab/skills/bootstrap/SKILL.md',"- **`record`** — once the change has landed on the default branch","(`glab:manager` Stage 8).","- **`record`** — after the push, what stays true goes into the area spec, in a\n  docs commit of its own (`glab:manager` Stage 8); the plan folder stays unless\n  the repo's `AGENTS.md` says otherwise."),
(PF,"**Plan files are working files; the spec is what stays.**","migrates it.",T_PF),
(MG,"## Stage 8 — Record","## What you never do",STAGE8+"## What you never do"),
('plugins/glab/agents/developer.md',"When the dispatch says this is the record, that is your whole scope.","where none reaches the spec files, say so in the report.",DEVREC),
('plugins/glab/agents/analyzer.md',"## The record check — `glab:manager` Stage 8","## Report",ANALYZER+"## Report"),
('plugins/glab/skills/audit/SKILL.md',"4. The file is a working file, as a plan folder is:","unless the repo's `AGENTS.md` keeps its plans.",AUDIT),
('README.md',"Each change's working files","or keep its plans.\n",README_P),
('AGENTS.md',"- **`plan/` is the working area; `docs/specs/` is what stays.**","is never committed.\n",AGENTS_RULE),
]
def apply():
    subprocess.run(['git','checkout',BASE,'--']+REVERT,check=True)
    for f,a,b in PAIRS:
        s=open(f).read(); assert s.count(a)==1,(f,s.count(a),a[:60]); open(f,'w').write(s.replace(a,b))
    for f,st,en,new in SLICES:
        s=open(f).read(); assert s.count(st)==1,(f,st[:50]); i=s.index(st); j=s.index(en,i)+len(en); open(f,'w').write(s[:i]+new+s[j:])
    s=open('AGENTS.md').read()
    m=re.search(r"the plan lifecycle — .*?this file's\s+`plan/` rule\);",s,re.S); assert m
    s=s[:m.start()]+LIFE+s[m.end():]
    open('AGENTS.md','w').write(s)
if __name__=='__main__': apply(); print('applied')
