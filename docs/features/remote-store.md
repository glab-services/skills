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

## The store and a store clone

**The shared store.** The levels exchange plain files in one shared folder or a clone of the product's store repository,
named by a line `glab-shared-store: <path to the store folder or clone>` in the
repo's `AGENTS.md`, or else in `~/.claude/host.md`, where a machine's paths
belong. The filesystems it may sit on are named in the header of
`plugins/glab/scripts/plan-gate.sh`. Its layout:

    <store>/docs/product-rules/index.md       one line per rule file
    <store>/docs/product-rules/<name>.md      one topic, its size as glab:product-plan says
    <store>/briefs/<project>/brief.md         the project's request
    <store>/briefs/<project>/report.r<n>.md   the project's plan report
    <store>/briefs/<project>/plan.r<n>/       the plan files the report hashed
    <store>/briefs/<project>/verdict.r<n>.md  the product's verdict
    <store>/releases/                         reserved for the delivery level

**A store clone.** Each machine can hold, in place of the folder, a clone of
the product's store repository. The user creates that repository once,
empty, on its git host — its new-project page, or on a server of its own:

    git init --bare <path to the store repository>

then sets each clone up once, in one command:

    git clone -c core.autocrlf=false -c glab.store=true <store repo URL> <path to the clone>

The repository needs a first commit, made once, from the first clone, on a
machine where git already has your name and email; until then
`plan-gate.sh` refuses the clone:

    cd <path to the clone> && git commit --allow-empty -m 'store: first commit' && git push

The store line names the clone's path,
best in `~/.claude/host.md`, since it differs per machine. `plan-gate.sh`
commits and pushes the store itself, and its `sync` mode brings a clone up
to date. Without `glab.store` a clone is a plain folder.

## Where the details are

- The header of `plugins/glab/scripts/plan-gate.sh`, *A store clone*:
  the rules, the refusals, and what is not verified.
