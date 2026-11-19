# Docs mirror

What `glab` 0.19.0 adds: a CI job that publishes a code repo's `docs/`
folder to a separate, read-only `<repo>-docs` repository on each merge
to the default branch, on GitHub Actions or GitLab CI.

## What it does

The docs stay in the code repo and change in the same PR as the code;
the record of each change reaches `docs/` before its merge, so the
mirror publishes the code and its docs together. The mirror is a
repository of its own, not a submodule, one per code repo.

Each run makes the mirror's files exactly the code repo's `docs/` at the
merged commit, nothing added and nothing outside `docs/`. A run adds one
commit on the mirror's tip, never a force-push, and each commit names
the source commit it shows. A run with nothing new adds nothing, and an
older run that finishes late is skipped.

A hand edit in the mirror is put back by the next run, which names the
edits it replaces; history keeps them. A target that is not a mirror, a
shallow checkout or a rewritten source history stops the run with one
line saying why, and the mirror is left as it was.

## Set it up

Follow `README.md` *The docs mirror*, once per code repo: create the
empty mirror repository, give it a deploy key with write access, protect
its branch, set the CI values it names, and copy the script and your
host's CI file into the code repo through its own review. The merge
that adds them makes the mirror's first commit. Every file under
`docs/` becomes readable by whoever can read the mirror.

## What is not verified

No hosted run has been made yet on either host; your first run is the
check. `README.md` *The docs mirror*, *Not verified*, lists the rest.

## Where the details are

- `README.md` *The docs mirror*: setup, what happens when, updating a
  copy.
- The header of the mirror script that section names: the rules, the
  refusals, the exit codes and what is not verified.
