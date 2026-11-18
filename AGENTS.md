# Working agreement

This repo is a Claude Code plugin marketplace, `glab-services`, holding two
plugins. Everything under `plugins/` is **payload**: it is written for the
sessions of whoever installs a plugin, not for this repo. When payload text
and this file disagree about how to work *in this repo*, this file wins.

## Layout

- `.claude-plugin/marketplace.json` — the marketplace. It lists both plugins.
- `plugins/glab/` — the workflow plugin: its skills and agents,
  `hooks/hooks.json`, `scripts/manager-bootstrap.sh`,
  `scripts/context-size.sh` and `scripts/plan-gate.sh`.
- `plugins/memory-sync/` — the memory sync plugin: its one skill,
  `hooks/hooks.json`, `scripts/memory-sync.sh` and `settings.example.json`.
- `docs/specs/` — one spec per area: how it works now, why, what is not
  verified, what is open (*Rules*, the `plan/` rule).
- `docs/features/` — one page per feature: what it does, how to use it.
- `tests/` (the scripts' tests, `tests/gates.sh`, which runs every gate, and
  `tests/fixtures/product-loop/`, the walkthrough's sample product), `plan/`
  (the working area of changes in progress), `docs/`, `docs/one-fact.md` (the
  *One fact* registry), `host.example.md`, `README.md`, `.gitignore`
  (it holds `/plan/`, the working area, handoff files included) and this file
  belong to the repo and to neither plugin.

## Gates

The tests create their work directories under `$TMPDIR`. Export `TMPDIR` to
the temp directory your host file names, run `bash tests/gates.sh`, and paste
what it prints. Green is its last line, `PASS n/n`, with exit 0; each `FAIL`
line names the check and why. Each check's expected value and the reason for
it are in the script: the values in its arrays, the reasons in its comments.
`claude` is the Claude Code CLI: `claude` on `PATH`, or `CLAUDE_BIN` set to
the path your host file names; without one the script stops before any check.
**Every `claude` command run in this repo has
`CLAUDE_CONFIG_DIR` set to a new, empty directory under that temp directory.**
The CLI writes into its config directory even for `plugin validate`, and
without the variable that directory is the live `~/.claude`.

The Markdown files have no gate. A change to one is verified by running the
commands it prescribes in a throwaway directory and by the searches its plan
names.

## Tests

This section is a scoped exception to any general rule against hand-written
fakes and to any coverage percentage. It applies to the shell scripts in this
repo and to nothing else.

- **A stub executable placed first on `PATH` is the allowed way to fake an
  external CLI** such as `aws`. `tests/memory-sync.test.sh` does this.
  `tests/context-size.test.sh` fakes a missing `jq` the other way round, with
  a `PATH` that lacks it.
- **Coverage is reported as a list, not a number.** No tool measures it for
  bash. For each plan step, name the test cases that cover it; name each
  change no case covers, and why that is accepted.

## Rules

- **No secrets.** No bucket name, endpoint, profile name or environment value
  in any file, commit message or report. Use `<bucket>`, `<prefix>`,
  `<profile, or delete this key>`.
- **Never run `memory-sync.sh` against a real backend from this repo.** Use
  the stub in `tests/memory-sync.test.sh`.
- **Nothing is copied into `~/.claude` or removed from it by an agent, and no
  agent installs a plugin.** No agent runs `claude plugin install`, `claude plugin marketplace
  add`, `claude plugin enable` or `claude plugin configure`, in a shell or
  through `/plugin`. Installing is the user's step. An agent tests with
  `claude plugin validate` and `--plugin-dir`, under the `CLAUDE_CONFIG_DIR`
  rule in *Gates*.
- **The hook contracts do not change without a plan.** `memory-sync.sh`: the
  mode names, exit 0 on every path, nothing on stdout, messages on stderr.
  `context-size.sh`: the mode names, exit 0 on every path, on stdout one
  JSON object or nothing, messages on stderr, and in mode `stop` no key but
  `systemMessage` — it never blocks a turn or continues one.
  `manager-bootstrap.sh`: exit 0 on every path, on stdout one JSON object
  whose only key is `hookSpecificOutput`, or the plain text when `jq` fails,
  messages on stderr, and the level read from the first `glab-level:` line of
  the repo's `AGENTS.md` — the project level when there is none; it reads
  `session_id` from stdin with `jq`, never from a terminal, and names
  `plan/handoff/<id>.md` only for an id matching
  `^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$`, the `no session id` line otherwise.
  One script is not a hook, and its contract holds the same way —
  `plan-gate.sh`: the mode names `digest`, `report`, `verdict` and `check`;
  exit 0 done, 1 refused, 2 usage or a failed write; every refusal one `REFUSED:` line on stderr, and no
  write but the takeover before it of a claim, and its temporary file, whose
  run provably no longer runs.
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. A rule lives in the file of the
  role that acts on it; every other file points at it without restating it.
  The known cases — each such fact and the files that state it — are in
  `docs/one-fact.md`.
- **Comments and recorded incidents are kept.** Update them when the thing
  they describe changes; do not delete them.
- **Tests clean up by PID.** A test kills only processes it started itself,
  never by name or pattern.
- **`plan/` is the working area; `docs/` is what stays.** `plan/` is ignored
  by git and never committed. After a change's push, the record
  (`glab:project-record`) writes, from `plan/<slug>/` on disk, the spec of
  each area it touched —
  `marketplace.md` (the marketplace, this repo's layout, gates and rules),
  `workflow.md` (the `glab` workflow), `product.md` (the product level and the
  product ⇄ project loop), `memory-sync.md`,
  `external-agents.md` (removed in 0.8.0, a record only): how the area works
  now, the decisions that still
  bind, what is not verified, every follow-up — open or closed, each tagged
  `[<slug>/<file> <id>]` — and its incidents, moved into *Incidents* rather
  than dropped (*Comments and recorded incidents are kept*) — and a page in
  `docs/features/` when what a user sees changed. A spec states a fact as of
  its last record and names the file that owns it, so it is not one of the
  *One fact* files. Its *Records* line names the date, the slug, and the
  change's commits on the pushed branch by both ends, `<first>` and `<last>`,
  the branch, and the PR when one exists; a squash or rebase merge can give the commits new shas, so
  the branch and the PR are what to look up. The record is committed
  on the change's branch, after its push and before its merge
  (`glab:project-record`). Once the record has landed on
  `origin/main`, the manager lists `plan/<slug>` at a session start and
  removes it only on the user's word (`glab:session-rules` Rule 2).
  Nothing else under `plan/` is removed, except a completed handoff file under
  the same Rule. A folder committed before glab 0.16.0 is read back from the
  commit its *Records* line names: `git show <sha>:plan/<slug>/<file>`.
- **A change under `plugins/<name>/` raises that plugin's `version`** in
  `plugins/<name>/.claude-plugin/plugin.json`, in the same commit. When one
  push carries several commits of one change — one per sub-plan — the first
  that changes `plugins/<name>/` raises it, once. An installed
  copy is pinned to the version string: without a new one nobody receives the
  change, and nothing says so.
- **Payload text names a plugin component by its prefixed name** —
  `glab:project-manager`, `glab:project-developer`, `/glab:project-plan`. The frontmatter `name:` of a
  skill or agent stays bare: Claude Code adds the prefix, and an agent name
  containing `:` does not load. A role named in running prose — "the
  analyzer", "the reviewer" — is not an identifier and stays as it is.

## Commits

Conventional Commits: `type(scope): subject`, imperative subject, optional
body of short bullets. Types `feat`, `fix`, `refactor`, `perf`, `test`,
`docs`, `build`, `ci`, `chore`. Scope is optional; when used it is the area —
`sync`, `agents`, `skills`, `repo`. One logical change per commit.
