# Docs lifecycle

What `glab` does with a change's files, and where lasting docs go.

## Plan folders are working files

Each change gets `plan/<slug>/`: its plan, checks, reviews and results.
`plan/` is ignored by git and never committed. If your repo does not
ignore it yet, the manager says so at a session start and adds `/plan/` to
`.gitignore` with the next commit.

## Where the lasting docs go

After the push, the record (`/glab:project-record <slug>`) writes what
stays true:

- `docs/specs/<area>.md` — one per area: how it works now, what binds,
  what is unverified or open, and a *Records* line naming the change's
  commits, branch and PR.
- `docs/features/<feature>.md` — one per feature, like this one: what it
  does and how to use it, written when what you see changes.
- `docs/roadmap/<slug>.md` — the product level: a page per delivered
  business plan (P7).

Your repo's `AGENTS.md` can name other places.

## When a plan folder is removed

The record never removes it; nothing does without asking you. Once its
record has landed on the default branch, a later session start lists
`plan/<slug>` if neither `plan` nor the folder is a symlink, it resolves
inside this repo, and holds no nested repository or tracked file. Each is
shown with its record's commit and every file newer than that commit's
author date. You are asked once which to remove; only those you name go,
each re-checked first; one you keep is not raised again that session. Not
landed: it waits. A check that cannot run: it stays, and you are told. Any
other failure: you are asked. A folder committed before glab 0.16.0 is
never removed this way. After removal the docs are the only copy.

## Where the rules live

- `glab:project-plan` *Plan files are working files* — the lifecycle.
- `glab:project-record` — what a record writes, and the *Records* line.
- `glab:session-rules` Rule 2 — the listing and the removal.
- `glab:bootstrap` step 5 — where the removal and `.gitignore` check run.
- `glab:product-manager` P7 — the roadmap page.
