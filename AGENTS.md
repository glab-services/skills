# Working agreement

This repo is a Claude Code plugin marketplace, `glab-services`, holding two
plugins. Everything under `plugins/` is **payload**: it is written for the
sessions of whoever installs a plugin, not for this repo. When payload text
and this file disagree about how to work *in this repo*, this file wins.

## Layout

- `.claude-plugin/marketplace.json` — the marketplace. It lists both plugins.
- `plugins/glab/` — the workflow plugin: its skills, agents and commands,
  `hooks/hooks.json` and `scripts/manager-bootstrap.sh`.
- `plugins/memory-sync/` — the memory sync plugin: its one skill,
  `hooks/hooks.json`, `scripts/memory-sync.sh` and `settings.example.json`.
- `tests/`, `plan/`, `host.example.md`, `README.md` and this file belong to
  the repo and to neither plugin.

## Gates

The test creates its work directory under `$TMPDIR`. Export `TMPDIR` to the
temp directory your host file names first, then run all three, in order, and
paste what they print:

    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s" && test -x "$s"; echo "$s rc=$?"; done
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh

Green is: three `rc=0` lines; `rc=0` with no findings; every line `ok`, last
line `PASS n/n`. The `test -x` is there because a hook script that has lost
its execute bit passes every other gate and then fails when the hook runs. It
is joined to `bash -n` with `&&` so that the `rc` printed is the syntax
check's when that fails; with `;` a syntax error printed `rc=0`.

Then the plugin gates. `claude` is the Claude Code CLI: `claude` on `PATH`, or
the path your host file names. A host without `claude` on `PATH` exports
`CLAUDE_BIN` as that path before running the block. **Every `claude` command run in this repo has
`CLAUDE_CONFIG_DIR` set to a new, empty directory under that temp directory.**
The CLI writes into its config directory even for `plugin validate`, and
without the variable that directory is the live `~/.claude`.

    claude=$(command -v "${CLAUDE_BIN:-claude}"); : "${claude:?no Claude Code CLI found - set CLAUDE_BIN to the path your host file names}"
    cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX") && [ -d "$cfg" ] && (
      export CLAUDE_CONFIG_DIR="$cfg"
      for p in plugins/glab plugins/memory-sync .; do "$claude" plugin validate --strict "$p" | tail -n 1; done
      "$claude" --plugin-dir ./plugins plugin details glab | command grep -E '^  (Skills|Agents|Hooks) '
      "$claude" --plugin-dir ./plugins plugin details memory-sync | command grep -E '^  (Skills|Agents|Hooks) '
    ); rm -rf "${cfg:?}"
    jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r n s; do echo "$n = $(jq -r .name "$s/.claude-plugin/plugin.json")"; done
    command grep -c user_config plugins/*/hooks/hooks.json; echo "rc=$?"
    command grep -c -F 'not yet confirmed' plugins/memory-sync/scripts/memory-sync.sh plugins/memory-sync/skills/sync-memory/SKILL.md README.md; echo "rc=$?"
    command grep -rH --include='*.md' '^name: .*:' plugins; echo "rc=$?"

The first line finds the CLI. When there is none it stops the block with the
message after `:?`, so no later line is printed as though the gates had run.
That holds when the block runs as a script or through an agent's shell; pasted
into an interactive shell, `:?` aborts only its own line and the rest still runs.
The second makes the config directory and starts no `claude` command when it
cannot — with `TMPDIR` unset nothing runs — and removes the directory again at
the end. `CLAUDE_CONFIG_DIR` is never exported empty.

Green is:

- three `✔ Validation passed` lines;
- for `glab`: `Skills (14)` naming the six skills and the eight commands, `Agents (5)`, and `Hooks (1)  SessionStart`;
- for `memory-sync`: `Skills (1)  sync-memory`, `Agents (0)`, and `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
- `glab = glab` and `memory-sync = memory-sync`. Validation does not compare a marketplace entry with the plugin it points at; it passes with a wrong name and with a directory that does not exist;
- `:0` after each `hooks.json`, then `rc=1`. `grep -c` exits 1 when it counts nothing, and nothing is the green result here. A `${user_config.…}` in a hook command passes validation and fails when the hook runs;
- a count of `1` or more after each of the three files, then `rc=0`. Read the counts, not the `rc`: `grep -c` exits 0 as soon as one file matches. The phrase is the hedge on `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` — documented as the override for the `SessionEnd` budget, not yet shown to cover a hook that a plugin provides — and no other gate notices when the script comment, the skill or the README starts stating it as fact;
- no line, then `rc=1`, from the last command. A frontmatter `name:` that carries the plugin prefix passes validation and `plugin details`, and nothing else catches it.

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
- **Nothing is copied into `~/.claude` or removed from it by an agent, and no
  agent installs a plugin.** No agent runs `claude plugin install`, `claude plugin marketplace
  add`, `claude plugin enable` or `claude plugin configure`, in a shell or
  through `/plugin`. Installing is the user's step. An agent tests with
  `claude plugin validate` and `--plugin-dir`, under the `CLAUDE_CONFIG_DIR`
  rule in *Gates*.
- **The hook contract of `memory-sync.sh` does not change without a plan:**
  the mode names, exit 0 on every path, nothing on stdout, messages on stderr.
- **One fact, one value.** A number or name stated in more than one file
  changes in all of them in the same commit. Known cases: the review round cap
  (`plugins/glab/agents/reviewer.md`, `plugins/glab/commands/ship.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/bootstrap/SKILL.md`); the four ask-conditions of
  `glab:manager` Rule 3 — destructive, costs money, exposes real data, changes
  what the product is (`plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/plan-first/SKILL.md`, `plugins/glab/commands/plan.md`,
  `plugins/glab/commands/develop.md`, and their count, four, in
  `plugins/glab/skills/bootstrap/SKILL.md`); the missing-`AGENTS.md` fallback
  (every agent and command); the hook events
  (`plugins/memory-sync/hooks/hooks.json`, `README.md`,
  `plugins/memory-sync/skills/sync-memory/SKILL.md`, the header of
  `plugins/memory-sync/scripts/memory-sync.sh`); the default time limit of
  `memory-sync.sh` (the script, its test, `README.md`); the marketplace and
  plugin names (`.claude-plugin/marketplace.json`, both `plugin.json`,
  `README.md`); the session-start rules (the text in
  `plugins/glab/scripts/manager-bootstrap.sh` and the `glab:bootstrap` skill);
  what each plugin holds — its component counts and its hook events (the
  *Gates* section of this file, `README.md`, each plugin's `hooks/hooks.json`);
  the 20-second hook timeout of `memory-sync` (every `timeout` in
  `plugins/memory-sync/hooks/hooks.json`, the comments in the script that
  reason from it, `README.md`); the largest time limit the script accepts, 17
  (the script, its test, `README.md`); the 1.5-second `SessionEnd` budget and
  the hedged sentence about its override (the script comment, the
  `memory-sync:sync-memory` skill, `README.md`, and the
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key in the plugin's settings
  example).
- **Comments and recorded incidents are kept.** Update them when the thing
  they describe changes; do not delete them.
- **Tests clean up by PID.** A test kills only processes it started itself,
  never by name or pattern.
- `plan/` is tracked and permanent.
- **A change under `plugins/<name>/` raises that plugin's `version`** in
  `plugins/<name>/.claude-plugin/plugin.json`, in the same commit. An installed
  copy is pinned to the version string: without a new one nobody receives the
  change, and nothing says so.
- **Payload text names a plugin component by its prefixed name** —
  `glab:manager`, `glab:developer`, `/glab:plan`. The frontmatter `name:` of a
  skill or agent stays bare: Claude Code adds the prefix, and an agent name
  containing `:` does not load. A role named in running prose — "the
  analyzer", "the reviewer" — is not an identifier and stays as it is.

## Commits

Conventional Commits: `type(scope): subject`, imperative subject, optional
body of short bullets. Types `feat`, `fix`, `refactor`, `perf`, `test`,
`docs`, `build`, `ci`, `chore`. Scope is optional; when used it is the area —
`sync`, `agents`, `commands`, `skills`, `repo`. One logical change per commit.
