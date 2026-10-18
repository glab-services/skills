# feature-codex-agent: live probe L1 (Codex)

The manager session ran this on 2026-10-18, on the user's instruction in chat:
"Yes, Codex default model". The effort was the session's own level, `high`,
which the user gave because `CLAUDE_CODE_EFFORT_LEVEL` is unset. It ran as a
script (`probe-codex-l1/runner.sh.txt`), never pasted, on `main` at `9108ac7`
(glab 0.6.0) in this repository, with the user's own Codex login. Codex has
no "Use balance" switch (AGENTS.md, live-run exception).

All files in `probe-codex-l1/` are masked: `<home>`, `<user>`, `<uid>` and
`<tmp>` replace host values. They were scanned for tokens and key prefixes,
and none was found. The only scan hits were the word "ask-conditions".

## What ran

1. `check --backend codex`, which exited 0:
   - `login: stored`;
   - `sandbox: read-only starts`;
   - `default: gpt-6.1-sol (predicted)`;
   - seven listed models, each with its effort levels.
2. `start --backend codex --effort high --role general --label l1 --repo .`,
   with no `--model`. It exited 0 after 28 s.
   - The script's header line: `model: codex:gpt-6.1-sol · turn: 1`.
   - Codex's own header block (`transcript.log` lines 4-11): `model:
     gpt-6.1-sol`, `approval: never`, `sandbox: read-only`, `reasoning effort:
     high`, and a UUID session id.
   - The brief asked it to read AGENTS.md and list the scripts. It ran `cat
     AGENTS.md`, `rg --files …` and `head`/`cat` on the two scripts, then
     answered correctly, marking what it had proven and what it had inferred.
3. `send`, a one-sentence follow-up. It exited 0 after 6 s with `turn: 2`, on
   the same model. The reply refers to its first answer, so the session was
   continued.
4. `list` showed the agent `idle`, `codex:gpt-6.1-sol`, `turns=2`, and the
   repo at `9108ac7`.
5. `stop` exited 0 with `stopped: <id>`. The agent's directory was gone.

## The cleanup checks

The runner scanned `/proc/*/environ` for `GLAB_EXTERNAL_AGENT=<id>` at three
points: after `start`, after `send` and after `stop`. It found 0 each time.
`git status --short -uall` after the run showed only the untracked handoff,
so the repository is unchanged.

## What this settles, and what it does not

- **Settled:**
  - the real Codex 0.163.0 accepts the script's `exec` and `exec resume` argv;
  - it prints the header block in the form the script parses;
  - `--effort high` reaches it as `reasoning effort: high`;
  - its default model is read back and recorded (`codex:gpt-6.1-sol`);
  - resume continues the session;
  - no marked process was left after a turn or after `stop`.
- **Still UNVERIFIED:** that a real `exec` turn's commands *carry* the marker
  while they run. Nothing was alive to sweep at the check points, so finding
  0 does not distinguish a marker that was passed from one that was not.
  Proving it needs a turn that leaves a process running, which this run did
  not do. The turns here ended cleanly, so the sweep was not exercised on a
  real turn.
