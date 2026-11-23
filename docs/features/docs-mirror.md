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

## The details

The CI job needs bash 4.4 or newer, git 2.28 or newer and an ssh client on its runner.

`glab` ships, under `plugins/glab/templates/docs-mirror/`, a script and two
CI files that publish a code repo's `docs/` to a read-only `<repo>-docs`
repository on each merge to its default branch. The docs stay in the code
repo and change in the same PR as the code; the mirror lets them be read
without the code. It is a repository of its own, not a submodule, which
would need a pointer bump after every docs change and show only that
pointer in a PR. Each code repo has its own mirror.

Each run makes the mirror's tree exactly the code repo's `docs/` at the
merged commit, at the mirror's root, with nothing added: modes, symlinks,
line endings, deletions and renames carry, and no file outside `docs/`
reaches it. A run whose tree differs adds one commit on the mirror's tip,
never a force-push, by `glab docs-mirror <docs-mirror@glab.invalid>`, with
the subject `docs: mirror <first 12 hex of the source commit>` and the last
line `Source-Commit: <full sha of the source commit>`; a run whose tree is
equal adds nothing, unless it adopts a rewritten source (below), which
always adds one. The run reads the code repo's checkout and changes none of
its refs, config, index or files; it writes only `FETCH_HEAD`, the
fetched mirror objects and the mirror commit into its `.git`.

**Set it up once per code repo:**

1. Create `<repo>-docs` on the git host, empty, with no README, and private
   unless the docs may be public: every file under `docs/` becomes readable
   by whoever can read the mirror.
2. Make its key:
   `ssh-keygen -t ed25519 -N '' -C '<repo>-docs mirror' -f <a path outside every repo>`.
3. Add the public key to the mirror as a deploy key with write access —
   GitHub: *Allow write access*; GitLab: *Grant write permissions to this
   key*.
4. Protect the mirror's branch: `main` on GitHub (the branch the template's
   `run:` line passes), the code repo's default branch on GitLab. GitHub: a
   ruleset on `main` with *Restrict deletions* and *Block force pushes*,
   and not *Restrict updates*, which lets only bypass actors push — on
   github.com a deploy key cannot be one, so every run's push would be
   refused. Read-only then rests on who holds write access to the mirror
   and on the next run overwriting a hand edit. A ruleset on a private
   mirror needs a paid plan (inferred from GitHub's plans page). GitLab:
   not yet — the first merge creates that branch, so this is step 7.
5. Set three values in the code repo's CI settings. GitHub: *Settings →
   Secrets and variables → Actions*, the **Variables** tab for
   `DOCS_MIRROR_URL` and `DOCS_MIRROR_KNOWN_HOSTS` — the job reads `vars.`
   and is skipped while `DOCS_MIRROR_URL` is empty, so a URL saved as a
   secret never runs — and the **Secrets** tab for `DOCS_MIRROR_SSH_KEY`.
   GitLab: *Settings → CI/CD → Variables*, all three, the key Protected,
   type Variable, not masked — a multi-line value cannot be — and with
   *Environments* set to `docs-mirror`, the template job's environment,
   so that no other job of the pipeline gets it. Leave the other two at
   *All (default)*: the job's `rules:` reads `DOCS_MIRROR_URL` when the
   pipeline is created, and GitLab warns that an environment-scoped
   variable may not be defined then. The values:
   - `DOCS_MIRROR_URL` = `git@<host>:<owner>/<repo>-docs.git`;
   - `DOCS_MIRROR_KNOWN_HOSTS` = the host's published `known_hosts`
     line(s) (GitHub publishes them; a self-hosted server's come from its
     admin);
   - `DOCS_MIRROR_SSH_KEY` = the private key's text.

   Then delete the local private key file.
6. From a checkout of this marketplace repository at the commit of the
   installed `glab` version (`plugins/glab/.claude-plugin/plugin.json`
   `version`) — the newest commit on `main` with that `version`, since one
   version can span several commits — copy
   `plugins/glab/templates/docs-mirror/docs-mirror.sh` to
   `.glab/docs-mirror.sh` (`chmod 755`) and the one CI file of the code
   repo's host: `github-docs-mirror.yml` to
   `.github/workflows/docs-mirror.yml` — when the code repo's default
   branch is not `main`, replace `main` on its `branches:` line, and leave
   the `run:` line's `main`, the mirror's branch — or
   `gitlab-docs-mirror.yml` to `.gitlab/docs-mirror.yml`, plus this entry
   in `.gitlab-ci.yml`'s `include:` list, or the key with it if the file
   has none:

       include:
         - local: .gitlab/docs-mirror.yml

   Merge them through the repo's own review. That merge makes the mirror's
   first commit.
7. GitLab only: protect that branch now. It became the mirror's default
   branch, protected by default but without the deploy key: put the deploy
   key, alone, in its *Allowed to push and merge* and turn *Allowed to
   force push* off. Until then the next run is refused.

**What happens when:**

- `docs/` did not change: no commit (`nothing to mirror`).
- A stale run — an earlier merge's run that finishes after a later one's:
  skipped, no commit.
- Someone edited the mirror by hand: the next run's commit stacks on the
  hand commits, puts back the tree of `docs/`, names them in its body
  (`Replaces <n> commit(s) not made by the mirror: …`) and warns; the
  history keeps them.
- A wrong target — the URL names a repository whose branch has commits but
  none made by the mirror: refused, nothing written.
- A shallow checkout: refused, naming `fetch-depth: 0` and `GIT_DEPTH: "0"`,
  which the templates already set.
- On GitLab, a merge whose pipeline has a failed job, or no job but this
  one (it runs in `stage: .post`), is not mirrored; the next merge's run
  is.
- The mirror cannot be reached or refuses the push: the run fails and
  prints up to four of git's first error lines, each starting
  `docs-mirror: git:`, with the remote shown as `<remote>`; the next run
  retries.
- A rewritten source — the default branch's history rewritten, so it no
  longer holds the commit the mirror last published: the run is refused
  and names the mirror's last source commit; set `DOCS_MIRROR_ADOPT` (a
  variable on GitHub, on the **Variables** tab, not a secret; a CI/CD
  variable on GitLab) to that full sha, merge the next change to the
  default branch, and delete the variable once that run has mirrored — a
  run that finds it non-empty and unused warns.

**Updating a copy:** `cmp` each copy with the same file of a checkout at
the newer version; a difference is the update.

**Not verified:** no hosted run yet, on either host — UNVERIFIED until your
first run; whether a re-run of a refused job sees a variable set after the
first attempt; on GitLab, that the first push into an empty project is
accepted under its default-branch protection, and that the job, whose
environment has `action: access`, creates the `docs-mirror` environment
on its first run and gets the key scoped to it (GitLab's docs say such a
job gets environment-scoped variables).
