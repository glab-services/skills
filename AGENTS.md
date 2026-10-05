# Working agreement

This repo is the source for a global Claude Code setup. Everything the README
lists under **Installed to `~/.claude`** is **payload**: it is written for
`~/.claude` on some machine, not for this repo. That includes the root
`CLAUDE.md` — when it and this file disagree about how to work *in this
repo*, this file wins.

## Gates

The test creates its work directory under `$TMPDIR`. Export `TMPDIR` to the
temp directory your host file names first, then run all three, in order, and
paste what they print:

    for s in memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
    shellcheck memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh memory-sync.sh

Green is: three `rc=0` lines; `rc=0` with no findings; every line `ok`, last
line `PASS n/n`.

The Markdown files have no gate. A change to one is verified by running the
commands it prescribes in a throwaway directory and by the searches its plan
names.

## Tests

This section is a scoped exception to any general rule against hand-written
fakes and to any coverage percentage. It applies to the shell scripts in this
repo and to nothing else.

- **A stub executable placed first on `PATH` is the allowed way to fake an
  external CLI** such as `aws`. `tests/memory-sync.test.sh` does this.
- **Coverage is reported as a list, not a number.** No tool measures it for
  bash. For each plan step, name the test cases that cover it; name each
  change no case covers, and why that is accepted.

## Rules

- **No secrets.** No bucket name, endpoint, profile name or environment value
  in any file, commit message or report. Use `<bucket>`, `<prefix>`,
  `<profile, or delete this key>`.
- **Never run `memory-sync.sh` against a real backend from this repo.** Use
  the stub in `tests/memory-sync.test.sh`.
- **Nothing is copied into `~/.claude` by an agent.** Installing is the
  user's step.
- **The hook contract of `memory-sync.sh` does not change without a plan:**
  the mode names, exit 0 on every path, nothing on stdout, messages on stderr.
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. Known cases: the review round cap
  (`agents/reviewer.md`, `commands/ship.md`, `skills/manager/SKILL.md`,
  `skills/bootstrap/SKILL.md`); the missing-`AGENTS.md` fallback (every agent
  and command); the hook events (`settings.example.json`, `README.md`,
  `skills/sync-memory/SKILL.md`, the header of `memory-sync.sh`); the default
  time limit of `memory-sync.sh` (the script, its test, `README.md`).
- **Comments and recorded incidents are kept.** Update them when the thing
  they describe changes; do not delete them.
- **Tests clean up by PID.** A test kills only processes it started itself,
  never by name or pattern.
- `plan/` is tracked and permanent.

## Commits

Conventional Commits: `type(scope): subject`, imperative subject, optional
body of short bullets. Types `feat`, `fix`, `refactor`, `perf`, `test`,
`docs`, `build`, `ci`, `chore`. Scope is optional; when used it is the area —
`sync`, `agents`, `commands`, `skills`, `repo`. One logical change per commit.
