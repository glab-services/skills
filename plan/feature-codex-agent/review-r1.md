# feature-codex-agent: review, round 1/3

Three reviewers looked at `git diff HEAD`, leaving out `plan/`, on 2026-10-18.
Each returned BLOCK: correctness 3, security 3, tests/docs/rules 6. The
manager relays their findings here, numbered by reviewer, and assigns each
one.

## C: correctness, concurrency and process lifecycle (BLOCK: 3)

- **C1** `external-agent.sh:1281` (`cmd_send`), with the flag paths at
  1024-1025 and the check at 1071. Picture a `send` after a SIGKILLed Codex
  turn. The old redact filters are still alive and hold the helper's streams.
  The new turn's `rm -rf "$run" && mkdir "$run"` reuses the same path, and
  the old awk filter's `printf "" >flag` lands in the new `run/`, so
  `finish_turn` fails a turn that printed one line with exit 7. The reviewer
  reproduced it with a stub.
  - Fix: in `cmd_send`, after `lock_agent` and before `rm -rf "$run"`, call
    `sweep_agent "$id"` when isolation is host.
  - Fix: give the cap flags names only this invocation uses
    (`capped.$$.stdout` and `.stderr`) in `run_host`, `run_sandboxed` and
    `finish_turn`.
  - Fix: add a case after E69: SIGKILL a `send`, then `send` again.
- **C2** `:176` (`cleanup`) and `:1056`. Host cleanup takes about 3 s. A
  second HUP, INT or TERM in that window runs `exit` inside the EXIT trap,
  which skips the rest of cleanup and leaves the helper running and an
  unfinished start's directory behind. Line 1056 clears `sandbox_pid` before
  the post-turn sweep at 1059, so a signal during that sweep reaches a
  cleanup that does not sweep. The reviewer reproduced both.
  - Fix: make the first line of `cleanup` `trap '' HUP INT TERM`.
  - Fix: keep a `host_turn` flag set until `sweep_agent` at 1059 returns, and
    have cleanup sweep whenever it is set.
- **C3** `:212-216`, `:1325`, `:588/603`. `sweep_agent` always runs a second
  pass after `sleep 1`. It also runs on every OpenCode `stop`, and twice on
  `check`. This is the suite's 38 s → 3 min. A throwaway patch measured
  1m13s with PASS 69/69.
  - Fix: keep a `hit` flag and run pass 2 only when pass 1 killed something.
  - Fix: in `cmd_stop`, sweep only when `agent.json` names a host backend or
    is missing.
  - Fix: set `cmark=''` after the sweep at 603.
  - Fix: read `environ` with `mapfile -d '' -t` (see C-D).

Advisory, taken:

- **C-A** `:1266`: compute `isolation` after `lock_agent`, to keep the
  one-line stderr contract when a concurrent `stop` happens.
- **C-B** `:569`, `:1068`, `:592`: make `header` and `cx` top-level functions
  with explicit arguments, instead of nested functions and dynamic-scope
  `id`.
- **C-D** `:218-223`: match the marker on NUL-separated entries
  (`mapfile -d ''`), not after a NUL→newline translation.

Advisory, deferred to follow-ups:

- **C-C**: no bound on `wait "$jpid" "$epid"`.
- **C-E**: the group-kill PID-reuse window.

## S: security and data exposure (BLOCK: 3)

- **S1** `SKILL.md:236-240`, `README.md:74-75`, `external-agent.sh:90-91`
  and `:801` state "its commands have no network" and "writes nothing in any
  file" as guarantees, but only an IP connect was measured. No case tries a
  Unix-domain socket, for example the user's session bus at
  `/run/user/<uid>/bus`. UNVERIFIED: whether Codex allows that connect.
  - Fix: add a Unix-socket probe to S1 (`codex sandbox` only).
  - Fix: until it is shown, say "no IP network; Unix-domain sockets not
    measured".
  - Assigned: the integrator measures first, then docs states the result.
- **S2** `SKILL.md:243-244`: "MCP … turned off on every turn" overstates it.
  `codex_argv` does not disable MCP. Servers are absent only because
  `--ignore-user-config` skips the user's config, and a managed or system
  config is not covered. Fix: say what is true (the same fix as T2).
- **S3** `README.md:69-75` and `SKILL.md:60-68`, the data note. "It changes
  no file" is wrong: Codex writes `~/.codex` on every turn, its session keeps
  everything the model read, and `stop` does not remove it. The note also
  does not say that "files outside the repo" include credential files, such
  as Codex's own login, SSH keys and cloud keys.
  - Fix: reword both copies identically.

Advisory, taken:

- **S-4** `:608-613`: pass `check`'s catalog output through `clean`, and
  keep only slugs of the model-id form and levels that pass the effort check.

Advisory, deferred:

- **S-5**: the group-kill window (as C-E).
- **S-6**: the header block is trusted on its position alone.
- **S-7**: environment values are passed newline-separated.

## T: tests, docs and AGENTS.md conformance (BLOCK: 6)

- **T1** `README.md:57-59`. The Codex "any model id" sentence sits inside the
  OpenCode paragraph, and the next sentence says "The script runs only Kimi
  and GLM…".
  - Fix: move the Codex sentence into the Codex paragraph, and start the
    next with "For OpenCode, …".
- **T2** `SKILL.md:243`. The MCP claim (as S2). The list also leaves out
  memories, the browser and computer tools, image generation and
  multi-agent, which the script header lists.
  - Fix: use the script header's list, and say what is true about MCP and a
    managed config.
- **T3** `README.md:50-51` and `SKILL.md:138`. The exit-12 condition is
  stated too narrowly. Fix: add "or an approval policy other than `never`".
- **T4** The default-model token is written two ways. `SKILL.md:98` says
  `codex:<model or default>`; the script prints `codex:default`; AGENTS.md
  and Rule 5 use `codex` alone in the record line. `codex_model_allowed`
  (`:457`) also accepts `default` as a model id, so `--model default` sends
  `-m default`.
  - Fix: `codex_model_allowed` refuses `default` (exit 5), with a new E58
    line.
  - Fix: align `SKILL.md:98` with what the script prints.
- **T5** `SKILL.md:69-75`. The effort step has no rule for
  `models: unavailable`.
  - Fix (the manager's default, to be stated to the user): send the session's
    level unchanged, and say in the announce line that no levels were known.
- **T6** `AGENTS.md:163-170`. The new clauses are attached to *One fact*
  entries whose listed files do not state them.
  - Fix: list exactly the files that hold each clause (manager Rule 5,
    `review.md` and the skill for the Codex `--model` clause; manager Rule 5
    for `codex` alone; E50 and E55 beside E01), or make them entries of
    their own.

Advisory, taken:

- **T-7**: script comments cite plan ids ("(D31)", "findings §9.x", "Q5")
  that will dangle once the plan folder is removed. Cite the spec's tag form
  instead, for example `[feature-codex-agent/plan.md D31]`.
- **T-8**: E56 never tests the pass-through side of the allowlist. Pass
  `HTTPS_PROXY=x USER=t` and expect both.
- **T-9**: E60 replaces `$CXH/pids` between sub-cases, so cleanup can miss
  one. Append instead.

## Assignment

- **Integrator:** the S1 Unix-socket probe, with `codex sandbox` only, under
  the user's allowance.
- **Script developer** (`external-agent.sh`, the test): C1, C2, C3, C-A, C-B,
  C-D, S-4, T4 (script and E58), T-7, T-8, T-9, plus the script-header wording
  of S1 once the probe result is known.
- **Docs developer** (skill, manager, `review.md`, README, AGENTS.md): S1
  (wording after the probe), S2/T2, S3, T1, T3, T4 (`SKILL.md:98`), T5, T6.
- **Follow-ups:** C-C, C-E/S-5, S-6, S-7.
