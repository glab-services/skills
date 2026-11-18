# Docs lifecycle

For anyone using `glab` in a repo: what happens to the files it writes
for a change, and where the lasting docs go.

## Plan folders are working files

Each change gets `plan/<slug>/`: its plan, checks, reviews and results.
`plan/` is ignored by git and never committed. If your repo does not
ignore it yet, the manager says so at a session start and adds `/plan/` to
`.gitignore` with the next commit.

## Where the lasting docs go

After the push, the record (`/glab:project-record <slug>`) writes what
stays true:

- `docs/specs/<area>.md` — one spec per area: how it works now, what still
  binds, what is not verified, what is open, and a *Records* line naming
  the change's commits, branch and PR.
- `docs/features/<feature>.md` — one page per feature, like this one: what
  it does and how to use it, written when what you see changed.
- `docs/roadmap/<slug>.md` — at the product level, one page per delivered
  business plan (stage P7).

Your repo's `AGENTS.md` can name other places.

## When a plan folder is removed

The record never removes anything, and nothing removes a plan folder
without asking you. Once the record has landed on the default branch, the
manager lists `plan/<slug>` at a later session start when every check
passes: neither `plan` nor the folder is a symlink, it resolves inside this
repo, and it holds no nested repository and no tracked file. With each
folder it shows the commit that landed the record and every file in the
folder newer than that commit's author date, and it asks you once which to
remove. It removes only the folders you name, checking them again first; a
folder you keep is not asked about again that session. Not landed yet: it
waits. A check that cannot run: it stays, and the session start says so.
Any other failure: the manager asks you. A folder committed before glab
0.16.0 is never removed this way. After removal the docs are the only
copy.

## Where the rules live

- `glab:project-plan` *Plan files are working files* — the lifecycle.
- `glab:project-record` — what a record writes, and the *Records* line.
- `glab:session-rules` Rule 2 — the plan-folder listing, its checks and the removal.
- `glab:bootstrap` step 5 — where the removal and `.gitignore` check run.
- `glab:product-manager` P7 — the roadmap page.
