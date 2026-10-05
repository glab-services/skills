# Result — feature-plugin-marketplace, Slice D

Built 2026-10-05 on `main` at `2aeb46d`, on top of the staged Slice M moves.
Nothing staged, committed or pushed. Nothing under `~/.claude` was written.

**Verdict: BLOCKED on one gate.** All nine steps are applied and every plan
post-condition for Slice D matches. The gate added by known item (a) is red:
it counts `0` for `plugins/memory-sync/scripts/memory-sync.sh`. See *Blocked*.

## Stages

Steps were applied by a script that read each fenced block out of `plan.md`
and applied it; every `edit` "before" text matched exactly once.

| Step | State | Where |
|---|---|---|
| D1 | done | `.claude-plugin/marketplace.json:1-19` (new) |
| D2 | done | `README.md:1-145` (whole file replaced) |
| D3 | done | `AGENTS.md:3-16` (intro and `## Layout`) |
| D4 | done, plus deviation (a) | `AGENTS.md:24-65` (gate block `:38-47`, green list `:54-61`) |
| D5 | done | `AGENTS.md:86-91` |
| D6 | done | `AGENTS.md:94-108` ("One fact, one value") |
| D7 | done | `AGENTS.md:114-122` |
| D8 | done | `host.example.md:4` |
| D9 | done | `host.example.md:23-29` |

`settings.example.json` belongs to Slice S (step S3); not touched here.

## Blocked

The new gate line, `AGENTS.md:46`:

    command grep -c -F 'not yet confirmed' plugins/memory-sync/scripts/memory-sync.sh plugins/memory-sync/skills/sync-memory/SKILL.md; echo "rc=$?"

prints, on the tree as Slice S left it:

    plugins/memory-sync/scripts/memory-sync.sh:0
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    rc=0

Cause: the plan's S8 literal wraps the phrase over two comment lines, and
Slice S applied it as written:

    42-# is CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS; whether it covers a plugin-provided hook is not yet
    43:# confirmed, so at session end the harness can kill the script before it logs anything.

A per-line fixed-string search cannot see it. This is not a case of Slice S
being unfinished; the count stays 0 until one of these is decided:

- the S8 comment is re-wrapped so `not yet confirmed` sits on one line
  (Slice S's file; comment-only, P13's count of changed comment lines may
  move), or
- the gate searches the script for something that is on one line, or across
  lines.

I did neither: the first is outside my boundary, the second departs from the
instruction (one fixed-string check for that phrase in both files).

## Deviations from the plan literal

- **(a) Hedge gate added to D4's text.** One command line at `AGENTS.md:46`
  (between the `user_config` line and the frontmatter-name line, so "the last
  command" in the plan's last bullet still means the same command) and one
  green bullet at `AGENTS.md:60`. Reason: nothing else guards the hedged
  sentences in Slice S's two files. Counts seen: script `0`, skill `1` — red,
  as above. P14's fourteen counts are still all `1`.
- **(b) Smoke-test fixes: nothing changed.** Neither `README.md` nor
  `AGENTS.md` repeats a smoke-test command. Search for
  `smoke|env -u|AWS_PROFILE|CLAUDE_MEMORY_S3_ARGS|STUB|reset_run` in both
  found one line, `README.md:116`, the carried-over `AWS_PROFILE` warning. The
  two fixes (clear `AWS_PROFILE` and `CLAUDE_MEMORY_S3_ARGS` with `env -u` in
  the stub parts; runs A, B, C once, in that order) still need making where
  the smoke test lives, in `plan.md`.
- **(c) Stale ranges in `plan.md`** ("P1–P13", "P1–P9, P12"): left as they
  are. Plan text.

## Unplanned changes

None beyond (a).

## Tests

None added or changed; the plan adds none. Coverage as a list (`AGENTS.md`
`## Tests`): D1 — P11 and the three validation lines; D2 — P3, P4, P6, P8, P9,
P15; D3–D7 — P14, P9, and the gate block run as written; D8 — P3; D9 — P14.
Not covered by any case: the added gate's own wording, checked only by
running it.

## Gates

`claude` is not on `PATH` on this host. For these runs a wrapper named
`claude` was put first on `PATH` from a temp directory; it logged each call
with its `CLAUDE_CONFIG_DIR` and then ran the real binary (run 1) or exited
without running anything (run 2).

**`jq . .claude-plugin/marketplace.json`** — prints the file, `jq rc=0`.

**README rollout block, extracted and parsed** — `jq rc=0`:

    {"extraKnownMarketplaces":{"glab-services":{"source":{"source":"github","repo":"glab-services/skills"}}},"enabledPlugins":{"glab@glab-services":true,"memory-sync@glab-services":true}}

**`AGENTS.md` gate block, extracted from the file and run as written,
`TMPDIR=/data/tmp/claude`:**

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    tests/memory-sync.test.sh rc=0
    rc=0
    ... 35 lines `ok` ...
    PASS 35/35
    ✔ Validation passed
    ✔ Validation passed
    ✔ Validation passed
      Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
      Agents (5)  reviewer, integrator, developer, analyzer, committer
      Hooks (1)  SessionStart  (harness-only — no model context cost)
      Skills (1)  sync-memory
      Agents (0)
      Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    plugins/memory-sync/scripts/memory-sync.sh:0        <- RED, expected 1 or more
    plugins/memory-sync/skills/sync-memory/SKILL.md:1
    rc=0
    rc=1

Wrapper log: five calls, all with the same directory, none with an empty
value; before the run 0 `claude-config.*` directories, after it 0.

    CALL cfg=/data/tmp/claude/claude-config.AACd6Q empty=no args=plugin validate --strict plugins/glab
    CALL cfg=/data/tmp/claude/claude-config.AACd6Q empty=no args=plugin validate --strict plugins/memory-sync
    CALL cfg=/data/tmp/claude/claude-config.AACd6Q empty=no args=plugin validate --strict .
    CALL cfg=/data/tmp/claude/claude-config.AACd6Q empty=no args=--plugin-dir ./plugins plugin details glab
    CALL cfg=/data/tmp/claude/claude-config.AACd6Q empty=no args=--plugin-dir ./plugins plugin details memory-sync

**Plugin gate block, `TMPDIR` and `CLAUDE_CONFIG_DIR` unset, recording
wrapper:**

    TMPDIR=UNSET
    <temp dir>/rec/claude
    gate2.sh: line 1: TMPDIR: parameter null or not set
    gate2.sh: line 6: cfg: parameter null or not set
    block rc=1
    --- shim log lines: 0
    --- config dirs left: 0

No `claude` call, no export. The wrapper was then called once by hand to show
it records: `CALL cfg=UNSET args=probe`. The block stops at
`rm -rf "${cfg:?}"`, so the `jq` and `grep` lines after it do not run either
— "nothing runs", as `AGENTS.md` says.

`UNVERIFIED: the five real CLI calls wrote nothing under ~/.claude — not
measured directly; the evidence is that every call had CLAUDE_CONFIG_DIR set
to the throwaway directory.`

## Post-conditions (Slice D)

All equal the plan's *finished* values.

| Check | Actual |
|---|---|
| P1 | `0`, `0`, 29 paths, first `.claude-plugin/marketplace.json` |
| P3 | nothing bare; `AGENTS.md 2`, `README.md 11`, `host.example.md 1` (and the six glab lines as planned) |
| P4 | nothing bare; `AGENTS.md 1`, `README.md 5` |
| P6 | nothing bare; `AGENTS.md 1`, `README.md 8` |
| P8 | no `~/.claude/*.sh` path; `0`; `3`; the three `CLAUDE_PLUGIN_ROOT` lines |
| P9 | `absent`, `README.md:0`, `AGENTS.md:0`, the 15 payload lines as planned |
| P11 (D part) | `glab-services`, `glab ./plugins/glab`, `memory-sync ./plugins/memory-sync`, `glab = glab`, `memory-sync = memory-sync` |
| P12 (values) | `s3://<bucket>`, `s3://my-bucket`, `s3://stub` only |
| P14 | `0`, then `1 1 1 1 1 1 1 1 1 1 1 1 1 1` |
| P15 | eighteen `1`s, and the rollout JSON above |
| P16 | `0`, `24` |

Also checked: `## Tests` and the hook-contract rule are not in the `AGENTS.md`
diff (0 changed lines each); no versioned or host path in `AGENTS.md`,
`README.md` or `marketplace.json` (the two `/data/tmp/claude` lines in
`host.example.md:11,17` are the existing example host, not mine); nothing of
mine is staged.

## Blast radius

- **A teammate installing:** needs read access to `glab-services/skills` and a
  git credential that works without a prompt (SSH key in the agent, or
  `gh auth login` + `gh auth setup-git`); creates `~/.claude/host.md`; runs
  the three `claude plugin …` commands; for `memory-sync`, merges the `env`
  block into their own `settings.json`. The `cp` install is gone from the
  README. Someone without repo access cannot add the marketplace.
- **Every agent working on this repo:** runs the gates at the new paths,
  including `test -x`; runs the plugin gates with `TMPDIR` exported, under a
  throwaway `CLAUDE_CONFIG_DIR`; never runs plugin install, marketplace add,
  enable or configure; raises a plugin's `version` in the same commit as any
  change under it; uses prefixed names in payload text. As written today the
  gate block cannot be fully green (see *Blocked*).
- **Rollback:** `git restore --worktree -- README.md AGENTS.md host.example.md && rm -r .claude-plugin`
  (the plan's back-out for D; not run). It leaves `AGENTS.md` gates naming
  paths that no longer exist, so it is only useful together with the rest.

## Follow-ups

Not written to `follow-ups.md`: the file does not exist yet and two other
developers are writing in this folder at the same time. For whoever owns it:

1. Decide the hedge gate for the script (see *Blocked*).
2. Apply the two smoke-test fixes of item (b) in `plan.md`.
3. Correct the stale ranges of item (c) in `plan.md`.
4. When the smoke test settles Q4, the hedge is removed from `README.md`, the
   skill and the script comment — and the gate line and its bullet in
   `AGENTS.md` go with it.

## Not done

- Slices G and S, and `tests/`: not mine, not touched.
- P2, P5, P7, P10, P13, P17, V2, V3 as separate checks: not Slice D's.
- Everything the README says about credentials, auto-update and the two
  settings keys restates the docs; none of it was run (plan `UNVERIFIED` list).
