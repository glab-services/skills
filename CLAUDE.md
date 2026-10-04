**Load the `bootstrap` skill first, before anything else in the session.** It is
the single source for the session-start sequence — the working agreement, the
skills to load, finding the repo's real gate commands, picking up a handoff, and
the tooling hazards on this machine that return success while being wrong.

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
- **Temporary files go in `/data/tmp/claude`, never `/tmp`** (its own disk).
  `export TMPDIR=/data/tmp/claude` before any `go` command, say so in every
  dispatch message, use unique filenames, and clean up what you create. `/tmp`
  here is a tmpfs under a per-user quota shared by every agent; exhausting it
  returns `EDQUOT` on every write and kills the session from the inside, with no
  way to repair it from that session. `bootstrap` explains why remounting does
  not help.
