# Live probe: the Codex developer role (glab 0.7.0)

The manager session ran this on 2026-10-18, on the user's instruction in chat:
"then go to test this one", and then "Yes, rerun with a plan". It used Codex's
default model and the session's effort, `high`. It ran as a script
(`run1/runner.sh.txt`, `run2/runner.sh.txt`), never pasted, at `74c5830`,
with the user's own Codex login. Each run used `--role developer` on a
**throwaway git repo** under the temp folder, never the user's repository.

All files here are masked: `<home>`, `<user>`, `<uid>`, `<tmp>` and
`<session-uuid>` replace host values and session ids. They were scanned for
tokens and key prefixes, and none was found.

## Run 1: a bare brief, with no plan

- `check` exited 0. `start` exited 0 after 33 s, and `send` exited 0 after
  17 s.
- Codex's header on both turns read `sandbox: workspace-write [workdir]`,
  `approval: never`, `reasoning effort: high` and `model: gpt-6.1-sol`.
- Codex changed nothing and answered `BLOCKED: no contract; provide plan.md
  or waived.md`. The `glab:developer` contract it receives requires a plan,
  and the brief had none. The report read `changed: none` and `git:
  unchanged`, and the repository's own `git status` was empty, which agrees.
- The marker: Codex ran `printenv GLAB_EXTERNAL_AGENT` in its sandbox and
  printed the agent's id.

## Run 2: with `plan/test/plan.md` (P1–P3) in the throwaway repo

- Turn 1 (`start`, P1 and P2) exited 0 after 58 s, with `BUILT`.
  - The report: `changed:  M calc.py`, `changed: ?? notes.txt`, `git:
    unchanged`.
  - The repository's own `git status`: ` M calc.py`, `?? notes.txt`. They
    agree.
- Turn 2 (`send`, P3) exited 0 after 24 s, with `BUILT`. The report listed
  only what that turn changed: `changed:  M calc.py`, `git: unchanged`.
- The result is correct. `calc.sub(5, 3) == 2`, with the docstring "Return a
  minus b.", and `notes.txt` reads `sub added`.
- The header was the same as in run 1 on both turns. The marker was printed
  on both turns.

## Both runs

- HEAD, `.git/config` and the hooks list were unchanged after each run.
- The `/proc/*/environ` scan for the agent's marker found 0 processes after
  `start`, after `send` and after `stop`. The agent's directory was gone
  after `stop`.
- The user's repository was unchanged: only the untracked handoff.

## What this settles

- **Proven on a real Codex turn:**
  - the developer header `workspace-write [workdir]`, which the script
    accepts;
  - the change report on real edits (a modified file, a new file), matching
    git, per turn;
  - `git: unchanged` when `.git` is untouched;
  - the marker reaching the turn's commands, which closes the open item from
    live probe L1;
  - cleanup after each turn and at `stop`.
- **Observed:** an external developer follows the `glab:developer` contract,
  and refuses to change anything without `plan/<slug>/plan.md` or a waiver.
- **Not shown by these runs:** a turn that leaves a process running (so the
  sweep killed nothing here); a turn that writes `.git` or makes a nested
  repository (M3 and the stub tests cover those offline); any repository
  other than a three-file toy.
