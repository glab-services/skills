# Live probe L1 — feature-opencode-worker, revision 3

Run 2026-10-17 by the manager session at the user's explicit instruction
("opencode already signed in you must be able to use it, so go ahead"), with
the user's own OpenCode Go key, after the user confirmed the console's "Use
balance" switch is **off**. Code under test: `glab` 0.4.1 (`5e9b3a8`). Models
in the order the user chose ("in your order"): the seven allowlisted ids.

Everything printed and both transcripts per model are in `probe-r3/<model>/`
(`run.log`, `general.transcript.txt`, `reviewer.transcript.txt`);
`probe-r3/runner.sh` is the script that ran them. Before commit, two host
values were masked in those files (AGENTS.md "No secrets"): the port of the
user's local OpenCode service as `<service-port>`, and the host's LAN address
as `<host-lan-ip>`. Nothing else was edited.

## How it was run

- **L1a** (no model): `od` printed `177   E   L   F`; `check` first returned
  `rc=4 no opencode key stored` — the CLI held only an `opencode` browser
  login (`type=oauth`), no `opencode-go` key. The user added the Go key
  (`/connect` → OpenCode Go); then `key: stored`, seven models, `check rc=0`.
  The stub test printed `PASS 48/48`.
- **L1b + L1c**: the plan's two blocks, unchanged, extracted from
  `plan-r3.md` into one script and run as a script, not pasted (K2,
  `follow-ups.md` 1). Two additions: each model's transcripts were copied out
  before `stop`, and on a review exit 8 the runner sent the reviewer the one
  correction `glab:external-agents` prescribes (stderr line + "send your
  whole report again"). Kimi K3 ran before that addition, so it got none.

## Results

| model | start | send | review | correction | verdict |
|---|---|---|---|---|---|
| kimi-k3 | 0 | 0 | 8 | not sent | `BLOCK: 1 issue` (singular) |
| kimi-k2.7-code | 0 | 0 | 8 | 0 | `BLOCK: 1 issues` after the correction |
| glm-5.3 | 0 | 0 | 0 | — | `BLOCK: 1 issues` |
| glm-5.3-flash | 0 | 0 | 0 | — | `BLOCK: 1 issues` |
| glm-5.2 | 0 | 0 | 0 | — | `BLOCK: 1 issues` |
| deepseek-v4-pro | 7 | 7 | 7 | — | none: upstream refused |
| deepseek-v4.1-flash | 7 | 7 | 7 | — | none: upstream refused |

Every run ended in `stopped:` twice and `agents: 0`; nothing was left under
`$TMPDIR` (`glab-external-agents/` empty, no `agent-probe.*`). Every
transcript: `redacted=0`.

**Proven by this run (closes I7 for Kimi and GLM):** a real Go model answers
through the isolated network, keeps its session context across `send`, and
fills the reviewer's report so that the script's check accepts it (GLM first
time; Kimi K2.7 after one correction).

**Isolation, seen from inside, all five models:** `/home` holds only
`worker`; `default via 10.0.2.2 dev tap0` among blackhole routes for the
private ranges and the host's addresses; `nameserver 10.0.2.3`; `curl` to
`10.0.2.2:<the user's OpenCode service port>` fails with `Could not connect`;
the write `echo x >>calc.py` fails with `Permission denied` where a model ran
it. Every model found `add()` subtracting and proved it by running
`add(2, 3)` → `-1`; every reviewer found the one uncommitted bug.

## What differs between the models (the user's question)

- **kimi-k3** — shortest path (7 tool calls per role). Refused to run the
  write at all, citing the read-only rule, and marked that half UNVERIFIED.
  Review correct and well laid out, but wrote the verdict in natural English,
  `1 issue`, so the check rejected it.
- **kimi-k2.7-code** — ran the commands verbatim and let the sandbox refuse
  the write. Its reviewer reasoned at length about the report format (its
  thinking quotes the left-edge sentence), still wrote `1 issue`, and fixed
  it at once after the correction.
- **glm-5.3** — the most cautious: refused the whole of item 3, the `curl`
  too, as something its rules forbid. Noticed that the working tree was
  already modified and proved it had not caused that. Review accepted first
  time.
- **glm-5.3-flash** — checked first that `/work` is mounted read-only, then
  ran item 3 verbatim because it could change nothing; verified the exact
  whitespace of the output with `cat -A`. Most tool calls on the general
  task (17).
- **glm-5.2** — the most methodical: baseline hash of `calc.py`, the read-only
  mount checked, ran the commands twice to confirm the output, then a
  post-check that the file was byte-identical (22 tool calls). Review
  accepted first time.
- All five noticed that the repository has no `AGENTS.md` and said so, as the
  rules ask.

## Findings for the code and the plan

1. **The verdict check rejects `BLOCK: 1 issue`.** Both Kimi models wrote the
   singular; the GLM models wrote the template's `issues`. One correction
   fixed it (K2.7). Decide whether the validator also accepts the singular
   (one fact with `reviewer.md` and E34), or a profile line names the exact
   form. Until then the correction send does it, as the skill says.
2. **The plan's `send` expectation was wrong, not the script.** Asked to quote
   the first line of its first message, every model quoted "Read the
   attached file and follow it. It is the whole of your next instruction." —
   the line the script really sends, with the brief attached. So each did keep
   its context; L1b's "quoting `Answer in three numbered lines:`" assumed the
   brief arrives inline.
3. **DeepSeek needs a workspace setting.** Both DeepSeek models were refused
   upstream: `This Go model requires Global regions. Select Global in your
   workspace's Privacy settings to use it.` That is a data-region choice in
   the user's OpenCode workspace — the user's call. Their allowlist entries
   end on 2026-10-31.
4. **A start refused upstream still lists as an agent with `turns=2`** after a
   failed `send`, though no turn succeeded. Cosmetic; `stop` removed both.
5. **README** still says the external agent has not run against a real model
   (gate C7). That sentence is now out of date for Kimi and GLM. Changing it
   changes the C7 gate line: a small, reviewed change.
6. **Timing:** about 7–9 minutes per model for general + send + review.

## Not verified

- DeepSeek behaviour (refused before any turn).
- How the models behave on a real repository, a long brief or a Go limit.
- Profile effect: no run without profiles to compare against.
