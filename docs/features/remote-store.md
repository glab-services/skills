# Remote store

What `glab` 0.18.0 adds: the shared store of the product level and its
projects can be a git repository, so sessions on other machines see the
same briefs, reports and verdicts.

## What it does

Each machine keeps a clone of the product's store repository and names
its path where it named the store folder. `plan-gate.sh` fetches the
clone before it reads, and commits and pushes each report, verdict, brief
and rule file itself. These store pushes need no go-ahead from you; your
repos' own pushes are unchanged.

When two machines write at once, the push decides: the later run writes
again on the new state only if nothing it read has moved, and is refused
otherwise. Anything it cannot do safely, such as a local change in the
way, a clone ahead of its remote or a missing upstream, stops the run
with one `REFUSED:` line naming what to look at. Nothing is repaired for
you.

A plain folder works exactly as before, and so does a clone without
`glab.store` on a machine with git.

## Set it up

Follow `README.md` *The shared store*, *A store clone*: create an empty
repository for the store on your git host once, clone it on each machine
with the settings it names, make the first commit once, and name each
machine's clone in the store line. Every machine that uses the clone
needs `git`.

## Where the details are

- `README.md` *The shared store*, *A store clone*.
- The header of `plugins/glab/scripts/plan-gate.sh`, *A store clone*:
  the rules, the refusals, and what is not verified.
