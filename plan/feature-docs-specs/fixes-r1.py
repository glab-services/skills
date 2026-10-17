# Round-1 review fixes: (file, old text in the built tree, new text). Slices: (file, start, end-inclusive, new).
PF='plugins/glab/skills/plan-first/SKILL.md'; MG='plugins/glab/skills/manager/SKILL.md'
T_PF=("**Plan files are working files; the spec is what stays.** `plan/{slug}/` is committed with the change, as its records commit (`glab:manager` Stage 6). "
"Once the change has landed on the repo's default branch — however it was merged — `glab:manager` Stage 8 records it, as a change of its own: one docs commit updates the spec of each area the change touched — how the area works now, the decisions that still bind, what is not verified, and every follow-up still open and every incident, each under its source file and number — and removes the plan folder. "
"The spec names the last commit on the default branch that holds the folder, so `git restore --source=<that commit> -- plan/{slug}/` brings the folder back and `git show <that commit>:plan/{slug}/<file>` one file. "
"When no commit on the default branch holds the folder, nothing is removed: stop and say so. "
"Specs live in `docs/specs/`, one file per area, unless the repo's `AGENTS.md` names another place; a repo whose `AGENTS.md` keeps its plans records the spec the same way and removes nothing. "
"Never remove an untracked plan file. A plan folder whose `plan.md` has no `## Record` was written before the repo followed this rule: it stays until a change of its own migrates it.")
STAGE8='''## Stage 8 — Record

What stays true moves into the spec of each area the change touched, and the plan folder goes: `glab:plan-first` *Plan files are working files* is the rule, `docs/specs/` the default place, and the repo's `AGENTS.md` may name another place or keep its plans. The record is a change of its own — on its own branch and merge request where the repo merges that way.

**Start only when all three hold**; otherwise stop and say which does not:

1. The change has landed on the default branch. Run `git fetch <remote>`; the default branch is what `git symbolic-ref --short refs/remotes/<remote>/HEAD` prints (it prints nothing: ask the user). `git cat-file -e <remote>/<default>:plan/<slug>/` exits 0 and `git diff --quiet <remote>/<default> -- plan/<slug>/` exits 0 — the folder there is the folder here, whether the change was merged, squashed or rebased.
2. `git status --short -uall -- plan/<slug>/` prints nothing: every file of the folder is committed.
3. The commit the spec will name is `git log -1 --format=%h <remote>/<default> -- plan/<slug>/`, and `git merge-base --is-ancestor <that commit> <remote>/<default>` exits 0.

Then:

- Dispatch `glab:developer` for the record alone: the slug, that commit, the area specs the plan's `## Record` names (for a waiver, the ones you name), and any audit file under `plan/` it names as a source. It writes the spec from the folder's tracked files and the audit file, carries every follow-up still open and every incident with its source file and number, and changes nothing inside the folder.
- Dispatch `glab:analyzer` for the record check, at every tier: the spec diff against every tracked file of the folder and the audit file. `DIVERGES` goes back to the developer once, then to the analyzer again, which checks the fix; still `DIVERGES`: stop and tell the user. Nothing is removed before a `CONFORMS`.
- At full tier, one `glab:reviewer` pass on the spec diff alone — the target and nothing else, as in Stage 5. Its findings go back to the developer once, and the analyzer checks that fix too.
- Then `/glab:commit`, naming the spec, the folder and the audit file: `glab:committer` removes them in the same docs commit, under its guards. A repo that keeps its plans: the same commit, without the removal.
- That commit leaves through `/glab:push`, on its own go-ahead.

A plan folder whose `plan.md` has no `## Record` predates the rule and is not recorded here.

## What you never do'''
COMMITTER=("**A record commit** (`glab:manager` Stage 8) also removes the plan folder the caller names, and an audit file the caller names with it. "
"Check the name first: `<slug>` is non-empty, holds no `/` and no `..`, and `git ls-files -- plan/<slug>/` lists at least one file — otherwise stop; never remove `plan/` itself. An audit file must be tracked, directly under `plan/`, and end in `.md`. "
"Look — `git status --short -uall -- plan/<slug>/` — then run `git rm -r -q -- plan/<slug>/`, and `git rm -q -- plan/<audit file>` for a named audit file, and stage the spec by its path. "
"`git rm` takes only tracked files and refuses one with uncommitted changes: if it refuses, stop and report it, never `-f`. "
"Then `git diff --staged --name-status` must list only `D` lines under `plan/<slug>/`, the named audit file's `D` line, and the spec files; for anything else, unstage it and stop. "
"An untracked file left in the folder is named in the report, never staged and never deleted. A repo whose `AGENTS.md` keeps its plans: commit the spec and remove nothing.")
DEVREC=("When the dispatch says this is the record, that is your whole scope. Update the area specs the dispatch names — those the plan's `## Record` names — as `glab:plan-first` *Plan files are working files* says, from the folder's tracked files (`git ls-files -- plan/<slug>/`) and any audit file the dispatch names: how the area works now, the decisions that still bind, what is not verified, and every follow-up still open and every incident, each with its source file and number. None is dropped. "
"Name an untracked file in the folder in your report; do not read it as a source. "
"The commit the spec names is the one the dispatch gives — the last commit on the default branch that holds the folder — and the spec says `git restore --source=<that commit> -- plan/<slug>/` to bring the folder back. "
"Change nothing inside `plan/<slug>/`, `result.md` included: the committer removes the folder with `git rm`, which refuses a file with uncommitted changes. Step 5 does not apply: write no `result.md`; your report is the reply alone, and `detail:` names the spec files. Step 3's gates run as for any change; where none reaches the spec files, say so in the report.")
ANALYZER='''## The record check — `glab:manager` Stage 8

When the dispatch says this is the record check, your contract is not a plan's steps but the folder: every tracked file of `plan/<slug>/` (`git ls-files -- plan/<slug>/`) and any audit file the dispatch names. Against the spec diff, report each follow-up, open item, binding decision and incident they record as `carried` (cite the spec's `file:line`) or `missing`. A follow-up the records closed may be carried as closed. End with `CONFORMS` — every item carried — or `DIVERGES: <n> items`.

## Report'''
AUDIT="4. The file is a working file, as a plan folder is: once the user has decided what to act on, the plan of the change that acts on it names the file in its `## Record`; at that change's record (`glab:manager` Stage 8) the developer carries what is still open into the area spec, `glab:analyzer` checks it was carried, and the record commit removes the file, unless the repo's `AGENTS.md` keeps its plans."
README_P='''Each change's working files — findings, plan, results — live in
`plan/<slug>/` and are committed with the change. Once the change has landed
on the default branch, a docs change of its own moves what stays true — how
the area works, the decisions that still bind, what is open — into
`docs/specs/<area>.md` and removes the folder; the spec names the commit on
the default branch that still holds it, and
`git restore --source=<that commit> -- plan/<slug>/` brings it back. A repo's
`AGENTS.md` can put specs elsewhere, or keep its plans.
'''
AGENTS_RULE='''- **`plan/` is the working area; `docs/specs/` is what stays.** A change's
  `plan/<slug>/` is committed with the change, in a records commit of its
  own. Once the change has landed on `origin/main`, one `docs(repo)` commit
  updates the spec of each area the change touched and removes the folder:
  `marketplace.md` (the marketplace, this repo's layout, gates and rules),
  `workflow.md` (the `glab` workflow), `memory-sync.md`,
  `external-agents.md`. The spec says how the area works now, the decisions
  that still bind, what is not verified, every follow-up of the change —
  open or closed, each tagged `[<slug>/<file> <id>]` — its incidents, moved
  into the spec's *Incidents* rather than dropped (*Comments and recorded
  incidents are kept*), and a *Records* line naming the last commit on
  `origin/main` that holds the folder, so
  `git restore --source=<sha> -- plan/<slug>/` brings it back
  (`git show <sha>:plan/<slug>/<file>` one file). A spec states a fact as of
  its last record and names the file that owns it, so it is not one of the
  *One fact* files: the record brings it up to date. No untracked file under
  `plan/` is removed; `plan/SESSION-HANDOFF.md` is never committed.
'''
PAIRS=[
(PF,"- why the other candidate boundaries were rejected.\n- `## Record` — the area spec or specs this change updates once it is pushed, and what the entry will say.","- why the other candidate boundaries were rejected;\n- `## Record` — the area spec or specs this change updates once it has landed, any audit file under `plan/` it acts on, and what the entry will say."),
(PF,"and once the change is pushed records it in the area spec under docs/specs/.","and once the change has landed records it in the area spec under docs/specs/."),
(PF,"| Record | Spec entry; plan folder removed | the area spec, after the push (`glab:manager` Stage 8) |","| Record | Spec entry; plan folder removed | the area spec, once the change has landed on the default branch (`glab:manager` Stage 8) |"),
(MG,"Run `/glab:commit`. The `glab:committer` re-reads","Run `/glab:commit`, and name `plan/{slug}/` in its scope: the plan folder is committed with the change, as a records commit of its own, unless the repo's `AGENTS.md` keeps plan files out of git. The `glab:committer` re-reads"),
(MG,"| 8 | Record | `glab:developer` on the record, then `/glab:commit` |","| 8 | Record | `glab:developer` on the record, `glab:analyzer` on what it carried, then `/glab:commit` |"),
(MG,"| 8 Record | — | the area spec updated and the plan folder removed, in one docs commit after the push |","| 8 Record | — | once the change has landed: the area spec updated, `glab:analyzer`'s check that every follow-up and incident is carried, and the plan folder removed, in one docs commit |"),
(MG,"A change with a plan folder goes on to Stage 8.","A change with a plan folder goes on to Stage 8 once it has landed on the default branch."),
(MG,"- Remove a plan folder before its push has landed, or one the repo's rule keeps.","- Remove a plan folder before its change has landed on the default branch, before `glab:analyzer` has found every item carried, or when the repo's rule keeps it."),
('plugins/glab/commands/commit.md',"For a record commit (`glab:manager` Stage 8), name the spec and the plan folder: the committer removes the folder in the same commit, unless the repo's `AGENTS.md` keeps its plans.","When `glab:manager` Stage 6 names the change's plan folder, `plan/{slug}/`, it is in the scope: it is committed as a records commit of its own. For a record commit (`glab:manager` Stage 8), name the spec, the plan folder and any audit file: the committer removes the folder and the file in the same commit, under its guards, unless the repo's `AGENTS.md` keeps its plans."),
('plugins/glab/commands/ship.md',"Anything the reviewer did not see does not get committed, however tempting.","Anything the reviewer did not see does not get committed, however tempting. The one exception is the change's plan folder, `plan/<slug>/`, when I name it: its records go in a commit of their own."),
('plugins/glab/commands/push.md',"A change with a plan folder then goes to `glab:manager` Stage 8, which records it in its area spec and, unless the repo's `AGENTS.md` keeps its plans, removes the folder, in a docs commit of its own. That commit needs its own go-ahead here.","A change with a plan folder goes to `glab:manager` Stage 8 once it has landed on the default branch. Its record is a docs change of its own, which, unless the repo's `AGENTS.md` keeps its plans, removes the folder; it needs its own go-ahead here."),
('plugins/glab/agents/analyzer.md',"it runs after the push (`glab:manager` Stage 8), so its absence from the tree is not `missing`.","it runs once the change has landed (`glab:manager` Stage 8), so its absence from the tree is not `missing`; the record check below is a separate dispatch."),
('plugins/glab/agents/analyzer.md',"## Report",ANALYZER),
('plugins/glab/skills/bootstrap/SKILL.md',"- **`record`** — once the push has landed, what stays true goes into the area\n  spec and,","- **`record`** — once the change has landed on the default branch, what stays\n  true goes into the area spec and,"),
('plugins/glab/.claude-plugin/plugin.json',"review, commit and push through dedicated agents","review, commit, push and record through dedicated agents"),
('AGENTS.md',"*Live runs*) does, and its transcripts","*Live runs*) did, and its transcripts"),
]
SLICES=[ # (file, start marker, end marker (inclusive, first occurrence after start), new text)
(PF,"**Plan files are working files; the spec is what stays.**","migrates it.",T_PF),
(MG,"## Stage 8 — Record","## What you never do",STAGE8),
('plugins/glab/agents/committer.md',"**A record commit** (`glab:manager` Stage 8)","commit the spec and remove nothing.",COMMITTER),
('plugins/glab/agents/developer.md',"When the dispatch says this is the record, that is your whole scope.","where none reaches the spec files, say so in the report.",DEVREC),
('plugins/glab/skills/audit/SKILL.md',"4. The file is a working file, as a plan folder is:","unless the repo's `AGENTS.md` keeps its plans.",AUDIT),
('README.md',"Each change's working files","or keep its plans.\n",README_P),
('AGENTS.md',"- **`plan/` is the working area; `docs/specs/` is what stays.**","`plan/SESSION-HANDOFF.md` stays untracked.\n",AGENTS_RULE),
]
import re
def apply():
    for f,a,b in PAIRS:
        s=open(f).read(); assert s.count(a)==1,(f,s.count(a),a[:60]); open(f,'w').write(s.replace(a,b))
    for f,st,en,new in SLICES:
        s=open(f).read(); assert s.count(st)==1,(f,st[:50]); i=s.index(st); j=s.index(en,i)+len(en); open(f,'w').write(s[:i]+new+s[j:])
    # one-fact list: ship.md joins the lifecycle files, after push.md
    s=open('AGENTS.md').read()
    m=re.search(r"`plugins/glab/commands/push\.md`,(\s+)`plugins/glab/agents/committer\.md`",s); assert m
    s=s[:m.start()]+"`plugins/glab/commands/push.md`,"+m.group(1)+"`plugins/glab/commands/ship.md`, `plugins/glab/agents/committer.md`"+s[m.end():]
    open('AGENTS.md','w').write(s)
if __name__=='__main__': apply(); print('applied')
