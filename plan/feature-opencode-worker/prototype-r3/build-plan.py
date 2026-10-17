# build-plan.py <prototype tree> <out file> — writes plan-r3.md from the
# prototype's files and edits-r3.py, so the plan's blocks are those files byte
# for byte. Recorded outputs are filled in from <out dir>/recorded/*.txt when
# present (placeholders otherwise).
import os, sys, importlib.util
tree, out = sys.argv[1], sys.argv[2]
rec_dir = os.path.join(os.path.dirname(out), 'recorded')
spec = importlib.util.spec_from_file_location('edits', os.path.join(os.path.dirname(__file__), 'edits-r3.py'))
ed = importlib.util.module_from_spec(spec); spec.loader.exec_module(ed)

def rec(name):
    p = os.path.join(rec_dir, name + '.txt')
    return open(p).read().rstrip('\n') if os.path.exists(p) else f'@@{name}@@'

def fence(body, info):
    assert '\n````' not in '\n' + body, info
    if not body.endswith('\n'): body += '\n'
    return f'````{info}\n{body}````\n'

NEW = [
 ('A1', 'plugins/glab/scripts/external-agent.sh', '755', 'bash', 'The script. Its header states the contract, and every behaviour in it is pinned by a case of A2.'),
 ('A2', 'tests/external-agent.test.sh', '755', 'bash', 'The test: a stub CLI run inside the real sandbox and network namespace; 36 cases, E01–E36.'),
 ('A3', 'plugins/glab/skills/external-agents/SKILL.md', '644', 'markdown', 'The skill `glab:external-agents`: the manager\'s manual.'),
 ('A4', 'plugins/glab/skills/external-agents/profiles/default.md', '644', 'markdown', 'The default profile, rewritten for read-only work.'),
 ('A5', 'plugins/glab/skills/external-agents/profiles/kimi.md', '644', 'markdown', 'Moved from rev 2 with the script\'s new name; carries no claim.'),
 ('A6', 'plugins/glab/skills/external-agents/profiles/glm.md', '644', 'markdown', 'As A5.'),
 ('A7', 'plugins/glab/skills/external-agents/profiles/deepseek-pro.md', '644', 'markdown', 'As A5.'),
 ('A8', 'plugins/glab/skills/external-agents/profiles/deepseek-flash.md', '644', 'markdown', 'As A5.'),
]

P = []
w = P.append
w('tier: full — the change sends repository contents to an outside provider, holds the user\'s API key, and runs a third-party agent with internet access on the user\'s host\n')
w('''
# Plan, revision 3 — feature-opencode-worker

**Goal.** The manager can use an **external agent** the way it uses a
background subagent, when the user asks for one and names the model: `start`
it with a task on a sandboxed read-only copy of the repository and get back an
id and its reply, `send` it more in the same session, `list` the open ones,
and `stop` one, which removes its copy, its session and its transcript. Read-
only work only: review, analysis, research, questions about the code. The
user can read each agent's transcript, with the model named in every turn,
until it is stopped. OpenCode Go is the backend today; the names and the
adapter boundary are backend-neutral.

**Base.** Written 2026-10-17 against `main` at `889b804` (`= origin/main`,
glab `0.3.0`). The working tree holds the uncommitted rev-2 build. This plan
is a **clean restart from `889b804`** (D22): step R0 archives the rev-2 build
into `plan/feature-opencode-worker/rev2-build/` and removes it, and every
`file:line` below is a line of `889b804` — checkable with
`git show 889b804:<file>`. It builds on `findings-r3.md` (R1–R15, N1–N6,
C1–C8 and N7 proven; I7, I8 inferred) and on rev 2's `questions.md` Q1, whose answer
stays binding. `plan.md` (rev 2) and `result.md` are history.

## Decisions

The user's, carried from rev 2 (binding; `findings.md` U1–U6):

- U1 — **Manual only.** External only when the user names it; no file turns
  it on; no silent fallback either way.
- U4 — **Backend-neutral contract; Codex later as an adapter.**
- U5 — **Per-model profiles, separate from adapters; no invented quirks.**
- U6 / Q1 (user, 2026-10-16, option A) — **allow `opencode-go/kimi-k3`,
  `opencode-go/kimi-k2.7-code`, `opencode-go/glm-5.3`,
  `opencode-go/glm-5.3-flash`, `opencode-go/glm-5.2` with no end;
  `opencode-go/deepseek-v4-pro` and `opencode-go/deepseek-v4.1-flash` until
  `2026-10-31`, enforced by the script; refuse `opencode-go/grok-4.7`.**
- U2, U3 (developer and reviewer; the user tells the manager) are narrowed by
  U10 below: the reviewer only.

The user's new direction (2026-10-17, relayed by the manager; binding):

- U7 — **An external agent works like a background subagent, as a tool of the
  manager**: `start` (a brief, a named model, its own sandboxed read-only copy
  of the repo; returns an agent id and the agent's reply), `send <id>
  <message>` (the same OpenCode session, context kept), `list` (id, model,
  task label, workspace, last activity), `stop <id>` (ends it and removes its
  workspace and session data).
- U8 — **Usable in the background**: the manager runs a call as a background
  shell command and is told when it exits.
- U9 — **The user can see how models work**: each agent's transcript, key
  redacted, readable until `stop`; the model shown with every reply.
- U10 — **Read-only work only.** No patch is produced or applied; the
  developer wiring of rev 2 is dropped (applying an external patch runs
  untrusted code on the host through the gates; a later plan, once gates can
  be sandboxed).
- U11 — **Manual only**, as U1: the user says when and which model; the
  manager never starts one on its own and never falls back silently.
- U12 — **Backend-neutral names and an adapter boundary**, so Codex is a new
  adapter later.

Required by the review of rev 2 (binding):

- V1 — the sandbox has its own network namespace, internet only, no host
  service or socket; a named exit when that is unavailable; README says how
  to install it. V2 — a copy no git setting can change or use to run code on
  the host, verified against the real tree; every command checked, one stderr
  line per failure. V3 — nothing left after an interruption or a kill. V4 —
  model text is untrusted: control characters stripped, forged lines
  impossible, no path from it acted on. V5 — process and memory limits, or a
  plain statement of what is not limited. V6 — the key on no command line,
  never printed, redacted from transcripts. V7 — every OpenCode fact
  re-verified on the installed 2.0.31; the binary's path taken explicitly.
  V8 — say per rev-2 file what is kept, changed or dropped
  (`findings-r3.md`).

The planner's (Rule 3), with the evidence in `findings-r3.md`:

- D22 — **Clean restart from `889b804`**, the rev-2 build archived first (R0).
  Almost every rev-2 hunk is about the patch or the developer; anchoring on a
  commit makes every *before* text checkable.
- D23 — **Names**: `plugins/glab/scripts/external-agent.sh`, skill
  `glab:external-agents` (`plugins/glab/skills/external-agents/`, profiles in
  its `profiles/`), `tests/external-agent.test.sh`. The slug stays.
- D24 — **The network: slirp4netns**, attached to the sandbox's network
  namespace by path through a holder process in the namespace's owner (found
  with `lsns`, checked, not assumed); `--disable-host-loopback`,
  `--enable-seccomp`, `--exit-fd` tied to the script; blackhole routes for
  every non-public IPv4 range and each host address; no IPv6; the resolver
  bound to `10.0.2.3`. Any step failing is exit 9 NO ISOLATED NETWORK and the
  agent does not run. pasta rejected (N1). `--enable-sandbox` not used: it
  failed unprofiled and is not proven on the installed package either.
- D25 — **The key**: read on the host with `<cli> auth export opencode-go
  --standalone` (2.0.31's own interface, R5), stdin `/dev/null`, into a shell
  variable; exported only into the sandbox as `OPENCODE_API_KEY`; redacted
  line by line from every stream before it reaches the disk. The config's
  provider policy allows OpenCode Go alone, so the paid provider the same
  variable unlocks cannot be used (R3, R4).
- D26 — **OpenCode 2.0.31 config, native keys**: one agent `glab-agent`,
  `* deny`, allow `read glob grep shell`, `external_directory` deny but
  `/tmp/*`; `update: disable`, `share: disabled`; the project-config,
  Claude-Code, autoupdate, models-fetch and filewatcher switches; argv `run
  <message> --standalone --format json --thinking -m <model> --agent
  glab-agent (--title <label> | --session <id>) -f /opt/glab/message.md`,
  stdin `/dev/null` (R2, R6–R13). `--session` only with the id read back
  from the first turn (R11: an unknown id would be created).
- D27 — **The copy**: git plumbing and tar only, under `GIT_CONFIG_GLOBAL=/dev/null`,
  `GIT_CONFIG_NOSYSTEM=1`, `GIT_OPTIONAL_LOCKS=0`, `-c core.fsmonitor=false`,
  `-c core.untrackedCache=false`, `-c core.hooksPath=/dev/null`, every
  caller's `GIT_*` and `TAR_OPTIONS` unset; the user's `core.excludesFile`
  carried as a value, because their ignore rules decide what never leaves the
  host; verified afterwards (file archives, index, HEAD tree); `chmod -R a-w`;
  bound read-only (C1–C4).
- D28 — **Output**: first line `agent: <id> · model: <backend>:<model> ·
  turn: <n> · transcript: <file>`, then `reply:` and the reply with `| `
  before every line, then `end: <id>` last. Model text has C0 (but tab and
  newline), DEL, C1, zero-width and bidirectional controls removed.
- D29 — **Exit codes**: 0 OK, 2 USAGE, 3 UNKNOWN BACKEND, 4 UNAVAILABLE, 5
  MODEL REFUSED, 6 TIMEOUT, 7 BACKEND ERROR, 8 MALFORMED REPORT (reviewer
  only), 9 NO ISOLATED NETWORK, 10 UNKNOWN AGENT, 11 BUSY. Rev 2's 9 and 10
  never shipped; the numbers are reused.
- D30 — **State** under `$TMPDIR/glab-external-agents/<id>/`, mode 700; an id
  is `ea-` and 16 hex digits and is the only way to a path; `agent.json` is
  written by the script only and is outside the sandbox.
- D31 — **One turn at a time** per agent (`flock`); `stop` signals the running
  turn's process after checking its start time, waits up to 30 s, then
  removes the agent.
- D32 — **Process lifetime**: `exec setpriv --pdeathsig KILL -- timeout …
  bwrap --die-with-parent …` as a direct child of the script (C6); the holder
  with its own pdeathsig; slirp4netns on an exit FIFO; the sandbox's first
  command waits for the network and ends if the script is gone.
- D33 — **Limits**: files 64 MiB, `/tmp` 256 MiB, 256 tasks in the sandbox's
  user namespace, 4 GiB data per process (R15, C5). Total memory and the disk
  used under `TMPDIR` are not limited, and the README and skill say so.
- D34 — **PENDING the user's answer to `questions-r3.md` Q2; written on the
  recommended answer.** **The external reviewer stays, the external developer goes**: Rule 5's
  external choice now applies to `glab:reviewer` only; each round is a new
  `--role reviewer` agent whose report the script validates (exit 8); the one
  correction is a `send`, which keeps the context. Rev 2's patch path is gone.
- D35 — **`glab:manager` gains Rule 6**, the general rule for external agents:
  only on the user's word, reply untrusted, changes nothing, stop what you
  start.
- D36 — Carried from rev 2: every backend error is exit 7 with its message
  (D7); `TMPDIR` required (D9); 3600 s per turn by default (D11); the
  allowlist and end dates in the script only, payload prose naming no model
  id (D6); version `0.3.0` → `0.4.0` (D15), rev 2 never having been
  committed.
- D37 — **The CLI path is explicit** (`--cli`), resolved and stored per agent;
  the script never looks the CLI up on `PATH`. The skill names
  `~/.opencode/bin/opencode`, the installer's location.
- D38 — **The test needs a real bwrap and a real slirp4netns**; without them
  it is red, not skipped. The user installs `slirp4netns` before Develop
  (*Before* step 2).
- D39 — **Records**: `rev2-build/` (R0) and `prototype-r3/` (the probe and
  mutant scripts behind `findings-r3.md`) are committed with the plan files.
- D40 — **The live probe is the last step, run by the user** (L1a, L1b).
- D41 — **One developer, slices R0 → A → B → C**, in order.

The manager's, after Stage 1b round 1 (Rule 3, recorded as given and built
into the blocks):

- M1 — **README says the external agents have not yet run against a real
  model** until L1 has, and a gate line pins the sentence the way `not yet
  confirmed` is pinned (R2, C7, C8).
- M2 — **Every external agent carries what every dispatch carries** (Rule 0,
  Rule 0c): its first message tells it to read the repository's `AGENTS.md`
  first (`CLAUDE.md` and say so when there is none) and holds `glab:security`
  and `glab:comments`, for both roles (A1; Rule 6 in B9; E20, E21).
- M3 — **D34 is the user's call**: it moves to `questions-r3.md` Q2, with the
  recommendation to keep it; this plan is written on that answer and D34 is
  marked pending.
- M4 — **slirp4netns 1.3.3 is installed** at `/usr/bin/slirp4netns`; rev-3
  I6 is proven (`findings-r3.md` N7), and *Before* step 2 checks that path.
- M5 — Notes closed: L1b's reviewer target is non-empty (a correct `add()`
  committed, the bug uncommitted); L1 is copy-ready (`CLI`, `MODEL`, ids read
  with `sed`, `command grep`, `bash -n`); C6 gains seven cases, each matched
  by a census line; B11 gives the external reviewer's whole brief and B16
  covers fan-out reviewers; B2 orders the `send` correction before the stop;
  the post-conditions print modes for new files only; A1's header names the
  signal exits and the skill lists them; E10 checks the host's own blackhole
  route; E14 says "inside the sandbox"; the skill says a 6 or 7 before a
  session began is a `stop` and a new `start`.

### Rejected

pasta (N1); a shared network (rev 2); the rev-2 copy with porcelain (C2); the
key as a file in the sandbox; a key file of this plugin's own; `ulimit -v`;
cgroups through `systemd-run --user`; building on the rev-2 build in place;
an external developer applying patches (U10). Reasons in `findings-r3.md`
*Rejected*.

## Before

Run from the repo root.

1. **Tree and base.** `git rev-parse --short HEAD; git status --short -uall | /usr/bin/grep -v '^?? plan/feature-opencode-worker/'`
   must print exactly this — `889b804`, then the fifteen lines of the rev-2
   build:

````text
''')
w(rec('before_status') + '\n````\n')
w('''
2. **slirp4netns is installed.** `/usr/bin/slirp4netns --version | head -n 1; command -v slirp4netns`
   must print `slirp4netns version 1.3.3` (the version this plan was proven
   with; the user installed it on 2026-10-17) and `/usr/bin/slirp4netns`. If
   not, stop and ask the user to run `sudo apt install slirp4netns` (Debian,
   Ubuntu); no agent installs it.
3. **bubblewrap works here.** `bwrap --unshare-all --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 --proc /proc --dev /dev /usr/bin/true; echo "bwrap rc=$?"`
   must print `bwrap rc=0`.
4. **Gates green at the base.** `export TMPDIR=<the host file's temp directory>`,
   `CLAUDE_BIN` where `claude` is not on `PATH`, then the *Gates* block of
   `AGENTS.md` at `889b804`. Recorded on a `git archive 889b804` copy, the
   test's 35 `ok` lines left out:

````text
''')
w(rec('before_gates') + '\n````\n')
w('''
5. **Approval.** Full tier: the user approves this plan before any step runs.
   R0 removes uncommitted work (after archiving it); the approval covers that
   step, and nothing else is removed.

## Processing

One developer runs the slices in order (D41). New files are copied out of
this plan byte for byte, and edits applied by text, with the two scripts
below — not retyped: a retyped block is how an escape like `\\u200b` turns
into the invisible character it names.

- **Slice R0 — archive and remove the rev-2 build.** Boundary:
  `plan/feature-opencode-worker/rev2-build/` (new), the seven tracked files
  restored to `889b804`, the ten rev-2 files removed.
- **Slice A — new files.** Boundary: the eight files A1–A8, and nothing else.
- **Slice B — the manager and the commands.** Boundary:
  `plugins/glab/skills/manager/SKILL.md`, `plugins/glab/commands/review.md`,
  `plugins/glab/commands/ship.md`.
- **Slice C — working agreement, README, version.** Boundary: `AGENTS.md`,
  `README.md`, `plugins/glab/.claude-plugin/plugin.json`.

The extractor for slice A (each block's info string names its path and mode):

````bash
python3 -I - plan/feature-opencode-worker/plan-r3.md <<'PY'
import os, re, sys
t = open(sys.argv[1]).read()
for m in re.finditer(r'^````[a-z]* file=(\\S+) mode=(\\d+)\\n(.*?)^````$', t, re.M | re.S):
    path, mode, body = m.group(1), m.group(2), m.group(3)
    if os.path.exists(path): sys.exit(f'{path} exists; stop')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w').write(body); os.chmod(path, int(mode, 8)); print('wrote', mode, path)
PY
````

The applier for slices B and C (each edit is a *before* and an *after* block;
it checks every *before* occurs once and starts on its cited line in the
untouched file, then applies a file's edits last-first):

````bash
python3 -I - plan/feature-opencode-worker/plan-r3.md <<'PY'
import re, sys
t = open(sys.argv[1]).read()
eds = {}
for m in re.finditer(r'^````text edit=(\\S+) file=(\\S+) line=(\\d+) part=(before|after)\\n(.*?)^````$', t, re.M | re.S):
    eds.setdefault(m.group(1), {}).update(file=m.group(2), line=int(m.group(3)), **{m.group(4): m.group(5)})
byfile = {}
for sid, e in eds.items(): byfile.setdefault(e['file'], []).append((sid, e))
n = 0
for f, es in byfile.items():
    s = open(f).read(); pos = []
    for sid, e in es:
        c = s.count(e['before']); at = s[:s.find(e['before'])].count('\\n') + 1 if c == 1 else -1
        print(f"{sid} {f}:{e['line']} before-count={c} starts-at-line={at}")
        if c != 1 or at != e['line']: sys.exit(f'{sid}: stop')
        pos.append((s.find(e['before']), e['before'], e['after']))
    for i, b, a in sorted(pos, reverse=True): s = s[:i] + a + s[i + len(b):]; n += 1
    open(f, 'w').write(s)
print(f'edits={n} apply rc=0')
PY
````

### Slice R0 — archive and remove the rev-2 build

R0.1 archives, R0.2 checks the archive against the hashes recorded here, and
only if every hash matches does R0.3 remove anything.

````bash
A=plan/feature-opencode-worker/rev2-build
mkdir -p "$A/profiles" \\
  && cp -p plugins/glab/scripts/external-worker.sh tests/external-worker.test.sh "$A/" \\
  && cp -p plugins/glab/skills/workers/SKILL.md "$A/workers-SKILL.md" \\
  && cp -p plugins/glab/skills/workers/profiles/*.md "$A/profiles/" \\
  && git diff 889b804 -- AGENTS.md README.md plugins/glab/.claude-plugin/plugin.json plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/skills/manager/SKILL.md >"$A/tracked.diff" \\
  && echo "R0.1 rc=0"
(cd "$A" && for f in external-worker.sh external-worker.test.sh workers-SKILL.md profiles/*.md tracked.diff; do echo "$(sha256sum <"$f" | cut -c1-16) $f"; done)
````

R0.2 — that must print `R0.1 rc=0` and exactly:

````text
''')
w(rec('r0_hashes') + '\n````\n')
w('''
R0.3 — only then:

````bash
git restore AGENTS.md README.md plugins/glab/.claude-plugin/plugin.json plugins/glab/commands/develop.md plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/skills/manager/SKILL.md \\
  && rm -f plugins/glab/scripts/external-worker.sh tests/external-worker.test.sh && rm -rf plugins/glab/skills/workers && echo "R0.3 rc=0"
git status --short -uall | /usr/bin/grep -v '^?? plan/feature-opencode-worker/'; echo "rc=$?"
````

which prints `R0.3 rc=0` and `rc=1` (nothing outside the plan folder).

### Slice A — new files
''')
for sid, path, mode, lang, note in NEW:
    body = open(os.path.join(tree, path)).read()
    w(f'\n#### {sid} — `{path}` · new · mode {mode}\n\n{note}\n\n')
    w(fence(body, f'{lang} file={path} mode={mode}'))
w('''
### Slice B — the manager and the commands

Every *before* text is quoted from `889b804`; where it starts inside a line,
the line named is the one it starts on. Each *after* keeps the *before* text
and adds to it, unless it says otherwise.
''')
titles = {
 'B1': 'Rule 5, its opening paragraph: the external reviewer, and no external developer',
 'B2': 'Rule 5, *Carry it into every dispatch*: a new agent each round; no fallback',
 'B3': 'Rule 5, *These two roles only*: only the reviewer can be external',
 'B4': 'Rule 5, *Record it*: the record line of an external reviewer',
 'B5': 'Rule 5, *Name it in the handoff line*: the `<backend>:<model>` token',
 'B6': 'Rule 5, *Without subagent dispatch*: the review session runs the script',
 'B7': 'Rule 5, the dispatch table: a row for the external reviewer',
 'B8': 'Rule 5, *Check what comes back*: the script\'s check and the `send` correction',
 'B9': 'a new Rule 6, before *Know the gates before you dispatch*',
 'B10': '*When subagent dispatch is not available*',
 'B11': 'Stage 5',
 'B12': '*What you never do*',
 'B13': '`/glab:review`',
 'B14': '`/glab:ship`, step 1',
 'B15': '`/glab:ship`, step 2: the external reviewer\'s exit 8',
 'B16': '*Running agents in parallel*: fan-out reviewers when an external reviewer is recorded',
 'C7': 'Gates: the line that pins the README\'s "not yet run against a real model"',
 'C8': 'Gates, *Green is*: what that line prints',
 'C1': 'Layout: the new script',
 'C2': 'Gates: the new script and test, and what the test needs',
 'C3': 'Gates: `Skills (15)`',
 'C4': 'Tests: the stub passed with `--cli`',
 'C5': 'Rules: never against a real model from this repo',
 'C6': 'Rules, *One fact, one value*: the new known cases',
 'R1': 'the `glab` row',
 'R2': 'Requirements: what external agents need, and what they can send',
 'R3': '*Working on this repo*: the tests row',
 'V1': 'the version',
}
slice_c_started = False
for sid, f, line, before, after in ed.EDITS:
    if sid[0] in 'CRV' and not slice_c_started:
        w('\n### Slice C — working agreement, README, version\n')
        slice_c_started = True
    w(f'\n#### {sid} — `{f}:{line}` — {titles[sid]}\n\n')
    w(fence(before, f'text edit={sid} file={f} line={line} part=before'))
    w('\n')
    w(fence(after, f'text edit={sid} file={f} line={line} part=after'))
w('''
## After

### Post-conditions — run from the repo root

````bash
''')
w(open(os.path.join(os.path.dirname(__file__), 'postcond.sh')).read())
w('''````

Recorded on a clone of this repository at `889b804` with the rev-2 build
copied in, after R0, the extractor and the applier ran there exactly as
written above. Extractor and applier output:

````text
''')
w(rec('extract_apply') + '\n````\n\nPost-conditions:\n\n````text\n')
w(rec('postcond') + '\n````\n')
w('''
The same block on a `git archive 889b804` copy, for contrast — what each
line prints when the change is absent:

````text
''')
w(rec('postcond_base') + '\n````\n')
w('''
What each line proves: the hashes are the blocks of this plan and the
edited files (any hand edit changes one); the modes of the eight new files
are A's (the edited files keep the mode their checkout gave them, `664`
here); `rev-2 paths left: 0` and the archive hashes are
R0; the manager counts show each section names the skill or the external
reviewer (`0` in `Rule 5` or `Rule 6` would mean B1–B9 were not applied); the
censuses are the files that state each fact of C6 (`AGENTS.md` appears in most, because C6 itself quotes the fact) — a file outside that
list in a census line is a fact C6 does not record (the token census cannot
see the script, which prints the `model:` field from `%s:%s`); the guards
print `0`, and the last line is the known positive that shows the
invisible-character search can find one.

### Gates

`export TMPDIR=<the host file's temp directory>` (and `CLAUDE_BIN` where
`claude` is not on `PATH`), then the *Gates* block of `AGENTS.md` **as C2 and
C3 leave it**, both halves, every `claude` command under a throwaway
`CLAUDE_CONFIG_DIR` as the block itself does. Recorded on the same tree,
with the installed `/usr/bin/slirp4netns` 1.3.3, each test's `ok` lines left
out (35 and 36 of them):

````text
''')
w(rec('gates') + '\n````\n')
w('''
Green is that output: five `rc=0` lines, shellcheck `rc=0`, `PASS 35/35` and
`PASS 36/36`, three `✔ Validation passed`, `Skills (15)` with
`external-agents`, `Agents (5)`, `Hooks (1)  SessionStart`, the
`memory-sync` lines unchanged, `glab = glab`, `memory-sync = memory-sync`,
`:0`, `:0`, `rc=1`, `1`, `1`, `1`, `rc=0`, `1`, `rc=0`, then `rc=1`. The test
took 13–14 s on the planning host, three runs in a row.

### Integrate — the real CLI, offline

Stage 4 runs this: the user's real `opencode`, a dummy key in a throwaway
home, and a slirp4netns stand-in that wires nothing, so the sandbox has only
its own loopback and no request leaves this host. It proves the script's
argv, config, environment and parsing against 2.0.31 itself, which the stub
cannot. `CLI` defaults to `~/.opencode/bin/opencode`; set it where the native
binary is elsewhere. Run from the repo root.

````bash
''')
w(open(os.path.join(os.path.dirname(__file__), 'offline.sh')).read())
w('''````

Recorded (`<X>` is the throwaway directory; ids differ per run):

````text
''')
w(rec('offline') + '\n````\n')
w('''
Expected: `start` ends in exit 7 with `provider.transport` (the sandbox has no
route out — the CLI got as far as its API call), the session id recorded;
`send` ends in exit 6 after about 15 s; `list` shows one idle agent with two
turns; `stop` prints `stopped: <id>`; the dummy key is in no file under the
agent's state (`0`), while the known positive — the throwaway home's
database — holds it (`1`); no process is left (`0`).

### Milestone

`bash tests/external-agent.test.sh plugins/glab/scripts/external-agent.sh </dev/null`
prints `PASS 36/36`: the script, run against a stub CLI inside its real
sandbox and network namespace, starts, continues, lists and stops agents,
keeps the real repository untouched, keeps the host unreachable, and refuses
what it must; and `plugin details glab` shows `Skills (15)` with
`external-agents`.

### Mutants — every case can fail for its reason

`prototype-r3/mutants-r3.py` replaced one exact snippet of A1 at a time
(checked to occur once) and ran A2 on a scratch copy of the tree. Each case
E01–E36 is failed by at least one mutant aimed at it:

````text
''')
w(rec('mutants') + '\n````\n')
w('''
A mutant that also fails other cases shares their cause (M01 breaks the id
every later case reads; M09 leaves the copy's index empty, so the copy's
verification refuses every start). The one mutant marked `NOT KILLED` is a
layer no case can tell apart from its twin: M15 drops
`GIT_CONFIG_GLOBAL=/dev/null`, but each global setting the test plants is
also overridden by name (`core.fsmonitor=false`, `--template=`), so the
variable guards only against settings nobody listed. It stays (D27). M64,
which drops the host's own `/32` routes, is killed by E10 since the
amendment: E10 now reads the sandbox's route table for the host's address,
so it fails even on a host whose addresses all fall inside the blackholed
private ranges. Collateral cases can differ between runs on a loaded host
(an analyzer's M02 also failed E26, ours did not); the target case does not.

### Coverage, as a list (`AGENTS.md` *Tests*)

- A1 — arguments and roles E27; backend E28; allowlist E29, E31; end date E30
  (start and send); CLI path E32; key lookup E15, E33; the copy E06, E07,
  E08; read-only copy E06; prompt and profiles E20, E21; environment and
  config E09; network E10, E11; argv and stdin E12; limits E13; redaction
  E14; control characters and forged lines E16; reviewer validation E17–E19;
  backend errors E22, E23; timeout E24; busy and stop-while-running E25;
  SIGKILL E26; output format E01; send E02; list E03; transcript E04; stop
  E05; check E33; verdict set E34; profile census E35; real repo, leftovers
  E36.
- **Not covered, accepted:** the `die` lines for a flag with no value, an
  unknown argument, a brief or message that is not a file, `--repo` outside
  a work tree, a repository with no commit, `mkdir`/`mkfifo`/`jq` write
  failures, a missing tool in `net_tools`, `lsns` finding no owner, a holder
  that cannot join, a blackhole route `ip` refuses, bwrap not reporting a
  pid, and `stop` timing out after 30 s; and the `137` arm of the timeout
  check. Each is one condition and one `die` on a path E10, E11, E24–E28 and
  E32 exercise. An unreadable `core.excludesFile` and a `git config` error
  are one `die` each, not driven.
- A2 — is the test; its strength is the mutant table.
- A3–A8, B1–B16, C1–C8, R1–R3 — prose, checked by the post-conditions; E20,
  E21 and E35 check the profiles. `AGENTS.md` gives Markdown no other gate.
- V1 — post-condition `version 0.4.0`.

''')
L1 = '### L1 — the live probe · RUN BY THE USER · UNVERIFIED until then\n\nNo agent runs this: it uses the user\'s own key and calls a real model (C5).\nRun from the repo root after commit 1, in one shell, all three blocks in\nturn. `CLI` defaults to `~/.opencode/bin/opencode`; `MODEL` is one of the\nseven allowed ids. Each block passes `bash -n`.\n\n**L1a — no model is called.** Answer the manager with what each step printed.\n\n````bash\n\'\'\' + "@@L1A@@" + \'\'\'````\n\nExpected: `177   E   L   F`; `cli: …`, `tools: …`, `key: stored`, `models: …`,\n`check rc=0`; `PASS 36/36`; and "Use balance" **off**. `check rc=4` with `no\nopencode key stored`: run `"$CLI" auth login`, choose OpenCode Go, and\nrepeat. `check rc=9`: slirp4netns is missing or cannot start (*Before* step\n2). If "Use balance" is on, turn it off first. Only then L1b.\n\n**L1b — the real round trip** on a throwaway repository: a general agent, a\n`send` to it, `list`, and a reviewer agent.\n\n````bash\n\'\'\' + "@@L1B@@" + \'\'\'````\n\nExpected, and what each part proves once seen:\n\n- `start rc=0`, and the header with `model: opencode:<MODEL>`, `reply:`,\n  three numbered `| ` lines and `end: <id>` — the manager talking to a real\n  external model through the sandbox (I7). Line 1 says `add()` subtracts;\n  line 2 shows `/home` holding only `worker`, `default via 10.0.2.2 dev tap0`\n  among blackhole routes, and `nameserver 10.0.2.3`; line 3 a failed `curl`\n  (host loopback, where your own OpenCode service listens, is closed) and a\n  failed write (read-only copy).\n- `send rc=0`, quoting `Answer in three numbered lines:` — the session kept\n  its context (I7).\n- `list` shows the agent `idle` with `turns=2`.\n- `review rc=0` and a report whose verdict is `BLOCK: 1 issues` — the\n  uncommitted `a - b` is the one finding. `review rc=8` means the model did\n  not fill the template: its transcript is the input for tuning that model\'s\n  profile (U5).\n- the `redacted=` counts are whatever they are (`0` is fine: the model was\n  not asked to print the key).\n- `rc=7` anywhere: keep the stderr line — a limit, or the API unreachable.\n\nNow read both transcripts (the paths printed last): that is what the user\nwanted to see — how the model worked and what it was told. Hand the manager\nevery line printed and both transcripts; the manager records them in\n`plan/feature-opencode-worker/probe-r3.md` and decides, from them, whether a\nprofile needs text (U5). Then **L1c**, which prints `stopped: <id>` twice and\n`agents: 0`:\n\n````bash\n\'\'\' + "@@L1C@@" + \'\'\'````\n\nUntil this has run: `UNVERIFIED: a real Go model answers through the\nisolated network, keeps its session context, and fills the reviewer\'s\nreport` — and the README says so (R2, gated by C7).\n\n'
for f in ('l1a', 'l1b', 'l1c'):
    L1 = L1.replace('@@' + f.upper() + '@@', open(os.path.join(os.path.dirname(__file__), f + '.sh')).read())
L1 = L1.replace("''' + \"", '').replace("\" + '''", '')
w(L1)
w('''### Spec entry

The manager can start, continue, list and stop read-only external agents —
OpenCode sessions on an allowed `opencode-go/<id>` the user names — through
`glab:external-agents` and `external-agent.sh`: a verified read-only copy of
the working tree in a bubblewrap sandbox with its own slirp4netns network
(internet only), limits on files, processes and memory, the key never printed
and redacted from a transcript the user can read until `stop`, and replies
returned as untrusted, prefixed text. The external reviewer of Rule 5 runs on
it. Why: to let the user see how other models work and move read-only work
off the Claude plan, without loosening the gates. Open: L1, I7, I8, and `questions-r3.md` Q2.

### Commits

1. `feat(skills): add read-only external agents that the manager starts, continues and stops`
   — A1–A8, B1–B16, C1–C8, R1–R3, V1 in one commit: the version rule and the
   one-fact rule both need `plugin.json`, `AGENTS.md` and `README.md` to move
   with the payload. R0's removals are of uncommitted files and need no
   commit.
2. `docs(repo): add records for the external agents` — the whole of
   `plan/feature-opencode-worker/`: rev 2's `findings.md`, `questions.md`,
   `plan.md`, `result.md`, `prototype/`; `rev2-build/`; `findings-r3.md`,
   `plan-r3.md`, `prototype-r3/`; and the developer's `result-r3.md`.

### Back-out

- **Before commit 1, per slice:** C — `git restore AGENTS.md README.md plugins/glab/.claude-plugin/plugin.json`.
  B — `git restore plugins/glab/skills/manager/SKILL.md plugins/glab/commands/review.md plugins/glab/commands/ship.md`.
  A — check `git status --short -uall` lists exactly the eight A files as
  `??` outside `plan/`, then `rm -f plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh && rm -rf plugins/glab/skills/external-agents`.
  Back out A only together with B and C: their text names A's skill.
  R0 — to bring the rev-2 build back: `A=plan/feature-opencode-worker/rev2-build; git apply "$A/tracked.diff" && cp -p "$A/external-worker.sh" plugins/glab/scripts/ && cp -p "$A/external-worker.test.sh" tests/ && mkdir -p plugins/glab/skills/workers/profiles && cp -p "$A/workers-SKILL.md" plugins/glab/skills/workers/SKILL.md && cp -p "$A"/profiles/*.md plugins/glab/skills/workers/profiles/`,
  then *Before* step 1 prints the fifteen lines again.
- **After commit 1:**

  ````bash
  git revert --no-commit <hash of commit 1>
  sed -i 's/^  "version": "0.3.0",$/  "version": "0.4.1",/' plugins/glab/.claude-plugin/plugin.json
  jq -r .version plugins/glab/.claude-plugin/plugin.json   # must print 0.4.1
  git add plugins/glab/.claude-plugin/plugin.json
  git commit -m "fix(skills): withdraw the external agents"
  ````

  The revert alone would set the version back to `0.3.0`, and an installed
  copy moves only on a new version string, hence `0.4.1`. `revert` is not a
  commit type in `AGENTS.md`, so the subject is a `fix`.
  `UNVERIFIED: that an installed 0.4.0 copy ignores a move back to 0.3.0 — inferred from the AGENTS.md version rule, not tested`.
- **State outside the tree:** each agent's directory under
  `$TMPDIR/glab-external-agents/`; `external-agent.sh list`, then `stop`
  each, removes them. The `slirp4netns` package the user installed stays;
  removing it is the user's call.

### Not in this plan

- The Codex adapter (U12; `findings-r3.md` *Later: Codex*).
- An external developer, until gates can run sandboxed too (U10).
- Tuning a profile: it waits for L1b's transcripts.
- Moving DeepSeek's end date: a one-line change after re-reading the Go page,
  with a version bump. It falls on 2026-10-31, two weeks after this plan.
- slirp4netns `--enable-sandbox`, once it can be proven on an installed copy.

### UNVERIFIED, in one place

I7 (a real Go model, through the isolated network, keeping its session), I8 (which models send reasoning), rev-2 I3 (a
Go limit's text) and I5 (each family's reading style), the back-out version
inference above, and that slirp4netns's own code — run outside the sandbox,
as the user, on the sandbox's packets — has no exploitable bug.
''')
open(out, 'w').write(''.join(P))
print('wrote', out)
