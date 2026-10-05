**Load the `bootstrap` skill first, before anything else in the session.** It is
the single source for the session-start sequence — the working agreement, the
skills to load, finding the repo's real gate commands, picking up a handoff, and
the tooling hazards that return success while being wrong.

Everything below used to be spelled out here and now lives in `bootstrap`. What
remains is the irreducible minimum: the rules that must hold even in a session
where `bootstrap` never got loaded.

- **`manager` and `security` run on every session.** `manager` is the operating
  model — you manage agents, you do not implement. `security` is evidence
  discipline — paste the command and its real output, or write
  `UNVERIFIED: <claim> — <why>`. A gate is never green on an agent's word.
- **Read `AGENTS.md` at the repo root before anything else.** No `AGENTS.md` →
  read `CLAUDE.md` and say plainly the repo has no working agreement.
- **Every agent you dispatch reads `AGENTS.md` first and carries `security` and
  `comments`.** Say it in the dispatch message. See `manager` Rule 0c for the
  full list and for which skills are your call per dispatch.
- **Temporary files go where `~/.claude/host.md` says.** That file belongs to
  the machine — temp directory, tool paths, anything true of one host only.
  Read it with the working agreement, before the first command, repeat its temp-file rule in every
  dispatch message, use unique filenames, and clean up what you create. No
  `host.md` → say the machine has no host file, then use `$TMPDIR` if it is
  set and the session's scratchpad directory otherwise — and keep temp files
  few and small, because that fallback may itself sit on a small `/tmp`.
  `bootstrap` step 1 has the read; step 6 explains why this matters.
