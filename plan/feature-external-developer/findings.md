# feature-external-developer — findings

Base: `9108ac7` (glab 0.6.0). Line numbers are of that commit.

## F1 — what exists

- `plugins/glab/scripts/external-agent.sh`
  - `cmd_start` (L1223): `--role` is checked at L1239,
    `case $role in general|reviewer)`, before the backend is known (L1247).
    The role is stored in `agent.json` (L1272) and read back with
    `meta role` by `finish_turn` (L1152), `cmd_send` (L1337) and `list` (L1357).
  - `codex_argv` (L506-L526) always passes `-c 'sandbox_mode="read-only"'
    -c 'approval_policy="never"'`, on `exec` and on `exec resume` alike.
  - `codex_verify` (L591-L598) accepts exactly `sandbox: read-only` and
    `approval: never` from the header block, else prints the header and
    `end:` and exits 12 `NOT READ-ONLY`. `finish_turn` calls it after the
    turn, before any error check.
  - `header` (L1110) prints the first stdout line. Its only callers are
    `finish_turn` (every post-turn exit: 6, 7, 8, 0) and `codex_verify` (12)
    (`command grep -n 'header "' plugins/glab/scripts/external-agent.sh`).
  - `run_host` (L1053) runs the turn in `$(meta repo)` under
    `setpriv … setsid timeout … codex`, then the group kill and
    `sweep_agent`. `run_turn` (L970) calls it, then writes the transcripts.
  - `first_prompt` (L822): the host text says "you cannot change any file.
    You are not asked to."; the reviewer gets `agents/reviewer.md`'s body as
    its contract; every other role gets the two skills and `# Your task`.
  - `hostgit` (L289) ignores global and system config, fsmonitor, the
    untracked cache and hooks, and takes no optional locks.
- `tests/external-agent.test.sh`: the Codex stub (L176-L300) prints
  `sandbox: read-only` unless a scenario overrides it. E27 (L613) expects
  `--role developer` on OpenCode to fail with `--role must be general or
  reviewer`. E51 pins the read-only argv, E54 the 12 refusals, E61 the host
  first message. The last case is E71.
- Payload text that says there is no external developer:
  `plugins/glab/skills/manager/SKILL.md` L120 ("There is no external
  developer: an external agent changes no file."), L125 ("Only the reviewer
  can be external"), L154 ("It changes nothing."), L156 ("It takes no
  stage's role, except the reviewer under Rule 5");
  `plugins/glab/skills/external-agents/SKILL.md` L17 ("There is no external
  developer."); `README.md` L71-L79 ("Its commands change no file").
  `docs/specs/external-agents.md` L34 says it too; specs change only at the
  record.
- `plugins/glab/agents/developer.md`: Step 5 writes `result.md`; the Report
  block ends in `BUILT`, `BLOCKED: …` or `PLAN WRONG: …`; "Never commit.
  Never push. Never stage."

## F2 — Codex's workspace-write, as far as it is known

Proven (run here, with a throwaway `HOME` and `CODEX_HOME` under `$TMPDIR`,
removed afterwards):

    $ env -i PATH=/usr/bin:/bin HOME=<d>/home CODEX_HOME=<d>/cx TMPDIR=/data/tmp/claude <home>/.local/bin/codex --version
    codex-cli 0.163.0
    $ … codex sandbox --help
    Usage: codex sandbox [OPTIONS] [COMMAND]... [COMMAND]
      -c, --config <key=value>   Override a configuration value …
          --sandbox-state-disable-network …
      -P, --permission-profile <NAME> …
      -C, --cd <DIR>   Working directory used for profile resolution and command execution
    rc=0

So `codex sandbox` takes the sandbox through `-c`, as `codex_check` already
does for read-only (L634), and `-C` for the working directory. It has no
`--sandbox` flag. (Each call also printed a `WARNING: … could not create PATH
aliases` line, because `CODEX_HOME` sat directly under `$TMPDIR`; the sibling
`CODEX_HOME`/`TMPDIR` layout of `9108ac7:plan/feature-codex-agent/integration.md`
avoids it.)

Inferred, from Codex's source on `main` (not the 0.163.0 tag), read
2026-10-18 at
<https://raw.githubusercontent.com/openai/codex/main/codex-rs/utils/sandbox-summary/src/sandbox_summary.rs>:

- The header's `sandbox:` value for workspace-write is `workspace-write`
  then ` [<entries>]`: `workdir` always; `/tmp` unless `exclude_slash_tmp`;
  `$TMPDIR` unless `exclude_tmpdir_env_var`; then each extra writable root.
  ` (network access enabled)` is appended when network is on.
- So with `sandbox_workspace_write.exclude_slash_tmp=true`,
  `sandbox_workspace_write.exclude_tmpdir_env_var=true`,
  `sandbox_workspace_write.network_access=false` and no `writable_roots`, the
  value is exactly `workspace-write [workdir]`.
- `9108ac7:plan/feature-codex-agent/findings.md` §9.2 quotes Codex's docs:
  `<writable_root>/.git` and `<writable_root>/.codex` are protected as
  read-only in workspace-write. Not measured.

Not known until Stage 4 measures it (plan, *After*):

- whether a write to `.git` (config, hooks, refs, index) fails under
  workspace-write on this host;
- whether 0.163.0 honours the two `exclude_*` keys (an unknown `-c` key may
  be ignored silently, so a control run without them is needed);
- the exact header string 0.163.0 prints for that sandbox.

## F3 — consequences for the design

- Without the two `exclude_*` keys, Codex's commands could write `/tmp` and
  `$TMPDIR`. Here `$TMPDIR` holds `glab-external-agents/`, the state of every
  agent, `agent.json` and `run/stderr.txt` (which `codex_verify` reads)
  included. So both are excluded, and the developer's commands can write in
  the repository only. A command that needs a scratch directory, a build
  cache under `~`, or a nested bwrap (this repo's own test) fails inside the
  sandbox. The gates are the manager's (Q4 = A).
- Codex itself is not sandboxed; only its commands are. Codex may write git
  objects for its own snapshots; that is not a ref change. What can do harm
  in `.git` is a changed `HEAD`, ref, `config` or hook (a hook runs on the
  committer's next commit). That is what the after-turn check compares.
- `git status --porcelain` alone does not show a further edit to a file that
  was already modified before the turn (`M` stays `M`). The report therefore
  compares each listed path's content hash too, with
  `git hash-object --no-filters`, which writes nothing and runs no filter.
  A path that is a symlink or not a regular file is never opened: a link to
  a FIFO or `/dev/zero` would hang the hash.
- `git status` does not list ignored files; a write to one is not reported.
  Accepted and stated (`--ignored` would hash every build output each turn).

## F4 — rejected boundaries

- **A patch the manager applies** (Codex read-only, emitting a diff): the
  user chose the working tree directly (Q3).
- **`/tmp` and `$TMPDIR` writable, or a scratch root**: the first exposes
  every agent's state; a scratch root beside `run/` is possible but adds a
  writable root, a `TMPDIR` override and a TOML-quoted path, for a gain the
  manager's gates already cover. Not in this plan.
- **A new exit code for a changed `.git`**: the change has happened when the
  turn ends, so an exit code withholds nothing. A `git: changed` line the
  manager must stop on is enough, and leaves the exit-code fact as it is.
- **The script validating the developer's verdict line** (as exit 8 does for
  the reviewer): the manager reads the reply and the change itself (Q4 = A).
  Not in this plan.
