# feature-codex-agent: questions

Planner, 2026-10-18. The evidence behind each question is in `findings.md`
(section numbers in brackets). The answered items are the user's own words,
as the manager relayed them. Every open question meets a `glab:manager` Rule 3
ask-condition (destructive, costs money, exposes real data, changes what the
product is) or overturns a binding decision in
`docs/specs/external-agents.md`. That is why none of them is closed by
assumption, and why there is no `plan.md` yet.

## Answered (the user, 2026-10-18)

- **A1, login.** "The user logs in to Codex themselves; the script uses that
  existing login so Claude can drive Codex as a subagent: no separate API
  key, and the user said not to worry about it." Binding. How the sandbox
  gets that login is still a choice, because the mechanisms differ in what
  they expose and in whether they can break the host login (Q2).
- **A2, models.** All Codex models are allowed, and the user names the model.
  By default it is the latest model, at the same reasoning effort as the main
  Claude session. Binding. This changes the manual-model rule for this backend
  in every file `AGENTS.md` *One fact* lists for that rule and for the
  allowlist (findings §5). What "latest" is, and how the manager learns its
  own effort, cannot be decided from evidence: see Q5 and Q6.
- **A3, cost and live runs.** The user has a Max-tier OpenAI plan, so Codex
  needs no "Use balance"-style check. Live runs still happen only on the
  user's explicit instruction in chat. Binding. The plan amends `AGENTS.md`'s
  live-run exception (`AGENTS.md:109-121`) so that "after confirming that the
  console's 'Use balance' is off" applies to OpenCode only.
- **A4, roles.** Codex is to be usable as a **developer** subagent, not only
  as a reviewer or analyst. Binding. It overturns
  `[feature-opencode-worker/plan-r3.md U10]` and D34 (findings §2). Q3 and Q4
  ask how.

## Open

### Q1: one change, or two?

The read-only Codex backend and the external developer touch the same script,
skill, Rule 5, Rule 6 and test, but they carry different risks (findings §7).

- **A (recommended): two changes, in order.**
  - `feature-codex-agent` (glab 0.6.0): Codex as a read-only general or
    reviewer backend, the per-backend refactor of every OpenCode-specific line
    (findings §1), the login (Q2), and the default model and effort (Q5, Q6).
  - Then `feature-external-developer` (0.7.0): `--role developer`, the patch,
    the apply, and the pipeline wiring (Q3, Q4).
  - Consequence: the login and the sandbox mounts are proven against the stub,
    and in an offline run, before anything can write into the user's tree.
    Each review is smaller. The developer's plan is written after the read-only
    backend exists, from facts measured on it.
- **B: one change** (0.6.0). Consequence: one plan, one review, one record. But
  a review round that blocks on the developer also holds up the read-only
  backend, and the developer's design is fixed before S1, S2 and O1 have run.

### Q2: how the sandboxed Codex gets your login

This is the counterpart of today's `opencode auth export`. Each mechanism uses
the login you already have; the details are in findings §3.4. In all of them
the model's shell can read whatever is given to it, and the sandbox has the
internet. The script never prints a token, and it redacts the strings it
knows. What differs is what is exposed, and whether your login on this
machine can break.

- **L1: bind your real `~/.codex/auth.json` read-write into each turn.**
  - Codex refreshes the token in place, cooperating with your own Codex
    sessions as two local processes do.
  - **Exposes the refresh token**, a long-lived credential for your ChatGPT
    account that works until you log out or it is revoked.
  - The model can also overwrite the file and log you out on this machine.
  - A token refreshed mid-turn is not redacted until the turn ends.
- **L2: a copy each turn, written back afterwards** only if your file did not
  change meanwhile.
  - The same exposure as L1, but the model cannot write your file.
  - If your own Codex refreshes during the turn and the sandbox does too, one
    side is left with a used refresh token, and you must log in again.
  - The script writes into `~/.codex`.
- **L3 (recommended, subject to S2): the access token only.** The script
  copies the access token and the id token into the turn, with no refresh
  token, and refuses a turn (exit 4) when the access token would expire
  before the turn could end.
  - **Exposes only a short-lived access token**, plus the email and account
    id in the id token.
  - Your login on this machine cannot be broken by the sandbox.
  - When the token is near expiry, using Codex on the host refreshes it.
  - Unproven: whether Codex runs with an empty refresh token (offline
    measurement S2), and how long a ChatGPT access token lives. If it is
    short, most turns are refused. `check` would print how long the stored
    token has left, never the token.
- **L4: as L1 or L3, plus Codex's own sandbox hiding `auth.json` from the
  model's commands.** This works only if Codex's sandbox can start inside
  ours (measurement S1), which this host has not allowed for bwrap so far.

Also asked: is your Codex login stored in `~/.codex/auth.json` (the default),
or in the system keyring? With the keyring, none of L1 to L3 can read it until
`cli_auth_credentials_store = "file"` is set and you log in again. That is your
step, never an agent's.

### Q3: how a Codex developer's changes reach your working tree

(findings §4)

- **D-A (recommended): it writes in its sandboxed copy, and the script hands
  back a patch.**
  - The copy becomes writable, but its `.git` stays read-only.
  - After each turn the script builds the patch on the host. It refuses
    binary files, symlinks, mode changes, submodules, a patch over a size cap,
    and a patch containing your login (new exit codes).
  - Ignored files never leave the host, and no history is sent: today's
    guarantees stay.
  - Sub-choice, who applies it:
    - **D-A1 (recommended):** a new `external-agent.sh apply <id>`. It
      re-checks that your tree still matches what the agent was given,
      applies the patch atomically with `git apply`, and leaves the change
      unstaged. Each check gets a test.
    - **D-A2:** the manager runs `git apply` itself, after reading the
      patch, as rev 2 did.
  - In both, the script, or the manager, writes your real tree. Until now the
    script never has.
- **D-B: Codex works directly in your real tree, through a writable mount.**
  - The model would see every ignored file (`.env` and the like) and could
    send it to OpenAI.
  - It could change `.git` hooks that later run on your machine.
  - It overturns the copy's guarantees (spec decisions V2 and M2).
  - Not recommended.
- **D-C: a `git worktree` of your repository.**
  - The sandbox would need your real `.git`, writable, with all its history,
    with the same exposure as D-B for `.git`.
  - Not recommended.

### Q4: the gates run the external developer's code on this machine

U10 dropped the external developer "because applying an external patch runs
untrusted code on the host through the gates". That is still true: once
applied, the patch's tests and scripts run on this machine as you, when the
manager runs the gates (`glab:manager` Stage 2). This repo's own gates cannot
run inside the sandbox, because its test needs bwrap and slirp4netns, which do
not nest.

- **A: as for a Claude developer.** The manager reads the whole patch before
  applying it (every hunk of a test, script or build file), then runs the
  gates. Stages 3 to 5 are unchanged. Consequence: Codex output gets the same
  trust as `glab:developer`'s output, which already runs here unreviewed until
  Stage 5.
- **B: a Claude review first.** For an external developer's patch, one
  `glab:reviewer` round on the patch alone runs before the gates. Consequence:
  an extra review per develop round, and a pipeline order that differs by
  developer.
- **C: keep U10.** No external developer until gates can be sandboxed. Codex
  is read-only only, and A4 is deferred.

### Q5: what "the latest model" means when you name only Codex

There is no "latest" field. The CLI's own default is whatever OpenAI's catalog
marks as default, or else its first by priority, fetched with your login: the
bundled catalog's first is `gpt-6.1-sol`, and `gpt-6-astra` is described as
"Frontier intelligence" (findings §3.9).

- **A (recommended): a default pinned in the script, which you name now.**
  "Codex" with no model means that id. Moving it to a newer model is a
  one-line change with a version bump, as DeepSeek's end date is. Consequence:
  the record line and the header always name the exact model; when OpenAI
  ships a newer one, nothing changes until you say so.
- **B: Codex's own default.** The script passes no `--model`. Consequence: it
  follows OpenAI's choice without a script change, but the header cannot name
  the model unless the script reads it back from Codex's own session record
  (untrusted, form-checked), and the model can change between two rounds of
  one review.
- **C: no default.** You always name the model. Consequence: no guessing, but
  this contradicts A2's "by default the latest".

If A, name the model id.

### Q6: how the manager knows its own effort, and which Codex level it sends

The manager cannot see its own effort level. It cannot run `/effort status`,
and it may not read `~/.claude/settings.json`. The only effort it can read is
`CLAUDE_CODE_EFFORT_LEVEL`, and only when you set that variable (findings
§3.9).

- **A (recommended): the variable if it is set, otherwise the manager asks
  you once per session**, and records your answer with the model line (Rule 5).
  Consequence: exact, at the cost of one question when the variable is unset.
- **B: the variable if it is set, otherwise the model's documented default**
  (`medium` for Opus 5.5). Consequence: no question, but it is wrong whenever
  you changed the level with `/effort` or in settings.
- **C: a status-line script of yours writes `effort.level` to a file the
  manager reads.** Consequence: always live, but it is a change to your own
  Claude Code settings, which is your step, not an agent's.

The mapping sends the same name (`low`, `medium`, `high`, `xhigh`, `max`).
When the Codex model lacks that level (`gpt-5.5` has no `max`), either:

- **(i) (recommended)** send the highest level it has that is not above the
  requested one, and say so in the announce line; or
- **(ii)** pass the level through and let Codex refuse it, which shows up as
  exit 7.

What Codex itself does with an unsupported level is unproven.

### Q7: what the README and the skill say about OpenAI's data use

The OpenCode allowlist rested on each model's training and retention terms
(spec, *Allowlist*). For Codex on your ChatGPT plan, those terms are your
account's data controls, which the script cannot see.

- **A (recommended): state it once, as the "Use balance" line is stated.**
  The README and the skill say: what Codex receives (the copy and every
  message) goes to OpenAI under your ChatGPT account's data controls; check
  whether "Improve the model for everyone" is on.
- **B: also refuse to start until you have confirmed it once per session.**
  Consequence: one more question at the first Codex start.

## Answers (the user, 2026-10-18, relayed and written by the manager)

- **Q1: A, two changes.** This slug, `feature-codex-agent` (glab 0.6.0), is
  Codex as a read-only general or reviewer backend. The developer role is a
  second change after it (0.7.0), planned once this one exists.
- **Q2 and Q3 are replaced by one answer: Codex runs like a Claude subagent.**
  On Q2 the user asked why the login matters at all, "by calling codex cli…
  codex itself is doing it no?". On Q3 they asked for "the same flow what you
  are using for your own subagents". The manager explained that the bwrap
  sandbox hides the home folder, and asked which way Codex should run. The user
  chose: **like a Claude subagent.**
  - The script runs the Codex CLI on the host, directly in the user's repo, and
    not inside the script's bwrap sandbox on a copy.
  - Codex handles its own login (the user's existing `~/.codex` login, used by
    the Codex process itself). The script never copies, reads, exports or
    redacts a token, and never writes to `~/.codex`.
  - The containment is Codex's own sandbox. Read-only for this change; in the
    developer change, workspace-write in the working tree, editing it directly
    as `glab:developer` does.
  - Accepted consequence, as stated to the user: Codex's commands can read
    files outside the repo (for example `~/.env`), so what it reads can reach
    OpenAI, the same exposure a Claude subagent has. The bwrap copy's
    guarantees (copy only, no ignored files, own network) do not apply to the
    Codex backend. They stay in force for OpenCode.
  - L1–L4 and D-A–D-C are therefore not chosen.
- **Q4: A, same trust as a Claude developer.** For the developer change: the
  manager reads the whole change before the gates, then Stages 3 to 5 as
  usual.
- **Q5: B, Codex's own default.** No `--model` when the user names none. The
  script reads back which model actually ran, form-checked, so the header and
  the record line name it. Accepted: the model can change between rounds.
- **Q6: A.** Use `CLAUDE_CODE_EFFORT_LEVEL` when it is set; otherwise the
  manager asks the user once per session and records the answer with the model
  line. The mapping uses (i): the highest level the model supports that is not
  above the requested one, said in the announce line. The manager stated (i) as
  its default to the user, and the user did not object.
- **Q7: A, a one-time note.** The README and the skill say that what Codex
  reads (the repo and any file its commands open) goes to OpenAI under the
  user's ChatGPT account's data controls, and to check "Improve the model for
  everyone".

## Approval

- The user approved `plan.md` on 2026-10-18 ("Approve, build it"). Next:
  Stage 1b, then develop. Push waits for the user's go-ahead.

## Stage 1b, after round 2 (the user, 2026-10-18)

- Round 2/2 left five blockers, none of them a design problem
  (`analysis-1b-r2.md`). The user chose: **fix them, then one narrow third
  check of those five fixes only**, beyond the two-round cap, and develop if
  they hold.
- The user allowed **one offline run of `codex debug models --bundled`**,
  with a throwaway `CODEX_HOME` and no network (`bwrap --unshare-net`), to
  record the output's real shape. No login, no model, nothing read under
  `~/.codex`.

## Stage 4 (the user, 2026-10-18)

- Codex's own sandbox (a nested bwrap) cannot start inside
  `bwrap --unshare-net` on this host, because of AppArmor's `unpriv_bwrap`
  (`integration.md`). So S1 and O2 were not measured there.
- The user allowed **S1 and O2 to run on the host without the no-network
  wrapper**, under these limits:
  - `codex sandbox -- <command>` only, no `exec`, no model;
  - a throwaway `CODEX_HOME` and `HOME`, and a fake `auth.json`;
  - commands inside Codex's sandbox have no network;
  - the Codex program itself might check for updates.
- That allowance does not extend to `check`, `exec`, `debug models` without
  `--bundled`, or anything else that could contact OpenAI.
- **O2 failed** (`integration.md`). After the script's group kill, Codex's
  sandboxed child (bwrap) and its command keep running, because they start a
  session and group of their own, so D7 does not reach them. The user chose
  **measure, then amend the plan**:
  - the planner measures three candidates with `codex sandbox` only, under
    the allowance above:
    1. SIGTERM to Codex first, with a grace period, before the KILL;
    2. a unique environment marker on the turn, then a kill by PID of every
       process that carries it;
    3. `systemd-run --user --scope` per turn;
  - the planner amends D7 and P3/P4 to the one that provably leaves nothing;
  - the user sees the change, then develop, the gates, conformance and O2
    run again.
- The planner measured all three (findings §9.9). SIGTERM or SIGINT first
  fails. The marker, passed as `-c shell_environment_policy.set…`, works. The
  systemd scope works, but adds a dependency. **The user approved revision 4**
  (D31: the marker, a sweep by PID with a start-time check, and a sweep on
  `stop` as well) on 2026-10-18 ("Approve, build it").

## Review round 1 fixes folded into the plan (the user, 2026-10-18)

- Conformance round 3 found review r1's fixes changing texts the plan gave
  word for word, plus script details. The user approved **revision 5**, which
  adopts them:
  - the reworded data note, identical in README and skill;
  - the exit-12 wording (approval other than `never`) and the README Codex
    paragraph;
  - the effort fallback: with `models: unavailable`, send the session's level
    unchanged and say so (stated to the user earlier in chat);
  - `cmd_stop` sweeps unless a sandbox backend is named; the second sweep
    pass only after a kill; `mapfile -d ''`; `check`'s filtered and cleaned
    catalog; `default` refused as an id; E70.
- **The socket sentence is tightened**, as the user approved and the security
  review (round 2, advisory A) worded it: "no IP network, and a connect to a
  Unix-domain socket by path was refused (measured offline with
  `codex sandbox`); datagram and abstract sockets not measured". It changes in
  every place that states it.

## Revision 6 (the user, 2026-10-18)

- Conformance round 4/4 found one divergence. Review r2's R2-1 split E70 into
  E70 (the sweep before `send`, with the stub's `stale` scenario) and E71
  (the PID-named cap flag, with `late-flood-unmarked`). It also added the test
  helper `environ_line`. The plan still says 70 tests, one E70, and a
  coverage list with neither case.
- The user approved **revision 6**. It only records the built tests: the
  count of 71, E70 and E71 as built, the scenario table, the coverage list
  (including cleanup's `host_turn` sweep as uncovered, with its reason) and
  S32. It changes no code and no docs.
