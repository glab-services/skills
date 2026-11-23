# Working agreement

This repo is a Claude Code plugin marketplace, `glab-services`, holding `project`, `product`, `test`, `glab-team` and the archived `glab`. Everything under `plugins/` is **payload**: it is written for the
sessions of whoever installs a plugin, not for this repo. When payload text
and this file disagree about how to work *in this repo*, this file wins.

## Layout

- `.claude-plugin/marketplace.json` — the marketplace. It lists the plugins.
- `plugins/glab/` — archived at 0.21.0, kept as it is; its scripts' tests still run. The workflow plugin: its skills and agents,
  `hooks/hooks.json`, `scripts/` (`manager-bootstrap.sh`,
  `context-size.sh`, `level-guard.sh`, `glab-level.sh` — the level
  rule both hooks source — and `plan-gate.sh`) and `templates/`.
- `plugins/project/` — the project workflow: four agents, seven skills,
  no hooks; `scripts/plan-gate.sh` is a byte copy of glab's (G48).
- `plugins/product/` — the product level: its manager, skills and two
  agents, no hooks; `scripts/plan-gate.sh` is a byte copy of glab's (G48).
- `plugins/test/` — manual QA: three forked skills run by one tester agent.
- `plugins/glab-team/` — the build of `src/glab-team/`.
- `docs/specs/` — one spec per area: how it works now, why, what is not
  verified, what is open (*Rules*, the `plan/` rule).
- `docs/features/` — one page per feature: what it does, how to use it.
- `tests/` (the scripts' tests, `tests/gates.sh`, which runs every gate, and
  `tests/fixtures/product-loop/`, the walkthrough's sample product), `plan/`
  (the working area of changes in progress), `docs/`, `docs/one-fact.md` (the
  *One fact* registry), `src/glab-team/` (its `AGENTS.md` yields to this
  file), `host.example.md`, `README.md`, `.gitignore` (it holds `/plan/`, the
  working area, handoff files included) and this file belong to the repo and
  not to a plugin.

## Gates

The tests create their work directories under `$TMPDIR`. Export `TMPDIR` to
the temp directory your host file names, run `bash tests/gates.sh`, and paste
what it prints. Green is its last line, `PASS n/n`, with exit 0; each `FAIL`
line names the check and why. Each check's expected value and the reason for
it are in the script: the values in its arrays, the reasons in its comments.
`claude` is the Claude Code CLI: `claude` on `PATH`, or `CLAUDE_BIN` set to
the path your host file names; without one the script stops before any check.
It also stops, exit 2, without Node.js 24 or newer first on `PATH`, pnpm 10
or newer, or `src/glab-team` installed from its lockfile (`README.md`).
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
  external CLI** such as `ssh`. `tests/docs-mirror.test.sh` does this.
  `tests/context-size.test.sh` fakes a missing `jq` the other way round, with
  a `PATH` that lacks it.
- **Coverage is reported as a list, not a number.** No tool measures it for
  bash. For each plan step, name the test cases that cover it; name each
  change no case covers, and why that is accepted.

## Rules

- **No secrets.** No bucket name, endpoint, profile name or environment value
  in any file, commit message or report. Use `<bucket>`, `<prefix>`,
  `<profile, or delete this key>`.
- **Nothing is copied into `~/.claude` or removed from it by an agent, and no
  agent installs a plugin.** No agent runs `claude plugin install`, `claude plugin marketplace
  add`, `claude plugin enable` or `claude plugin configure`, in a shell or
  through `/plugin`. Installing is the user's step. An agent tests with
  `claude plugin validate` and `--plugin-dir`, under the `CLAUDE_CONFIG_DIR`
  rule in *Gates*.
- **The hook contracts do not change without a plan.** `context-size.sh`: the
  mode names, exit 0 on every path, on stdout one JSON object or nothing,
  messages on stderr, and in mode `stop` no key but `systemMessage` — it
  never blocks a turn or continues one.
  `manager-bootstrap.sh`: exit 0 on every path, on stdout one JSON object
  whose only key is `hookSpecificOutput`, or the plain text when `jq` fails,
  messages on stderr, and the level read from the first `glab-level:` line of
  the repo's `AGENTS.md` — the project level when there is none, and, with a
  warning, when `glab-level.sh` is missing beside it; it reads
  `session_id` from stdin with `jq`, never from a terminal, and names
  `plan/handoff/<id>.md` only for an id matching
  `^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$`, the `no session id` line otherwise.
  `level-guard.sh`: the mode names `skill` and `bash`, exit 0 on every path,
  on stdout one JSON object whose only key is `hookSpecificOutput`, or
  nothing, messages on stderr;
  `skill` decides only `deny`, `bash` only `ask`, never `allow`; the level
  from `glab-level.sh`, which `manager-bootstrap.sh` sources too.
  `plan-gate.sh`, not a hook, likewise: modes `digest`, `report`,
  `verdict`, `check`, `sync`; exit 0 done, 1 refused, 2 usage, a failed
  write or fetch; every refusal one `REFUSED:` line on stderr; on 1 or 2 no
  write but taking over a provably dead run's claim and temporary file, a
  clone's sync, and what it wrote and undoes (header); no `.git`, no git.
  Nor do `glab-team`'s hooks, MCP and CLI; its Node suites gate them.
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. A rule lives in the file of the
  role that acts on it; every other file points at it without restating it.
  The known cases — each such fact and the files that state it — are in
  `docs/one-fact.md`.
- **Comments are minimal.** Comment only what the code cannot say, in one
  line. Keep a comment true or delete it.
- **Tests clean up by PID.** A test kills only processes it started itself,
  never by name or pattern.
- **`plan/` is the working area; `docs/` is what stays.** `plan/` is ignored
  by git and never committed. A change that alters how an area works updates
  its spec in `docs/specs/` (current state only, at most about 10 KB, no
  history) and its page in `docs/features/` when what a user sees changed,
  in the same push. A folder under `plan/` is removed only on the user's word.
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
`agents`, `skills`, `repo`. One logical change per commit.
