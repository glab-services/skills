# Result — feature-plugin-marketplace, Slice S (S1–S8)

Built 2026-10-05 on `main` at `2aeb46d`, on top of the staged Slice M renames.
Nothing staged, committed or pushed. Nothing under `plan/` edited except this
file. No file outside `plugins/memory-sync/**` written.

## Stages

| Step | State | Where |
|---|---|---|
| S1 manifest | done, plan literal | `plugins/memory-sync/.claude-plugin/plugin.json:1-9` (new) |
| S2 hook wiring | done, plan literal | `plugins/memory-sync/hooks/hooks.json:1-33` (new) |
| S3 settings example, `env` only | done, plan literal | `plugins/memory-sync/settings.example.json:1-8` (whole file replaced) |
| S4 script location and fallback | done, **deviates from the literal — see (a)** | `plugins/memory-sync/skills/sync-memory/SKILL.md:12` |
| S5 hand-run example | done, plan literal | `SKILL.md:30` |
| S6 "are the hooks live" | done, plan literal | `SKILL.md:65-69` |
| S7 delete example | done, plan literal | `SKILL.md:104` |
| S8 script comment | done, plan literal | `plugins/memory-sync/scripts/memory-sync.sh:38-43` |

Every `edit` step's *before* text was counted before editing: each occurred
exactly once (S4, S5, S6 both lines, S7; S8 at `:38-40`).

## Blocked

Nothing.

## Deviations from the plan literal

**(a) S4 — the fallback for an unsubstituted `${CLAUDE_PLUGIN_ROOT}`.** Ordered
by the dispatch (final plan analysis). The plan's sentence

    Find the script with `find "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins" -type f -name memory-sync.sh -path '*memory-sync*'`, tell the user which copy you are using, and put that path in the commands below; if nothing is found, say so and stop.

was replaced, inside the same S4 edit, by text that:

- searches only under the config directory's `plugins/`;
- matches only `-path '*/memory-sync/*/scripts/memory-sync.sh'`. This is the
  cache form `<marketplace>/memory-sync/<version>/scripts/memory-sync.sh`. The
  plan's own layout guarantees only the tail `memory-sync/…/scripts/memory-sync.sh`
  (plugin directory name from D1, script path from M6); the `<version>` level
  between them comes from the docs, and the text says so: "may be kept … that
  layout is taken from the docs and has not been checked on an installed
  plugin";
- drops a copy whose plugin root (the directory above `scripts/`) holds
  `.orphaned_at`;
- one path → name it to the user and use it; more than one → "list them and
  ask the user which to use; do not choose one yourself"; none → "say so and
  stop";
- ends with "Never use a `memory-sync.sh` that lies directly in the config
  directory instead: that is a copy from before the plugin". The literal
  string `~/.claude/memory-sync.sh` is not written, so P8's first pattern
  stays empty.

The command avoids `-execdir` (GNU find refuses it when `PATH` has a relative
entry) and avoids any `$1`-shaped token (a skill body substitutes positional
arguments). Run as extracted from the skill text, on a fake layout under
`/data/tmp/claude` (removed afterwards):

    -- case 1: current + orphaned + checkout + other plugin + old root copy
    plugins/cache/glab-services/memory-sync/0.1.0/scripts/memory-sync.sh
    -- case 2: a second live version
    plugins/cache/glab-services/memory-sync/0.2.0/scripts/memory-sync.sh
    plugins/cache/glab-services/memory-sync/0.1.0/scripts/memory-sync.sh
    -- case 3: none
    (end)
    -- case 4: space in config dir
    a b/plugins/cache/m/memory-sync/1/scripts/memory-sync.sh
    -- old plan literal on the same kind of layout, for contrast
    plugins/cache/glab-services/memory-sync/0.1.0/scripts/memory-sync.sh
    plugins/cache/other/memory-sync-tools/1.0/scripts/memory-sync.sh
    plugins/cache/other/otherplugin/1.0/scripts/memory-sync.sh
    plugins/marketplaces/glab-services/plugins/memory-sync/scripts/memory-sync.sh

`shellcheck -s bash` on the extracted command: rc=0.

Consequence, known and accepted: a marketplace checkout
(`…/plugins/memory-sync/scripts/memory-sync.sh`, no version level) is not
matched. If the real cache has no version level either, the fallback prints
nothing and the skill stops — it fails closed.

`UNVERIFIED: the real install layout and the .orphaned_at marker — taken from the docs; nothing is installed here (D4).`
`UNVERIFIED: a model follows the three-way instruction — needs a session; smoke-test row 10.`

Effect on recorded plan values: **none.** P8 still prints
`plugins/memory-sync/skills/sync-memory/SKILL.md 4`. Smoke-test row 10's Pass
text ("either names a copy … or says none was found") gains a third valid
outcome — it lists several and asks; under `--plugin-dir` "none found" is
still the right answer.

**(b) Unguarded text — fixed strings a gate could count** (plan not edited).
All counted with `/usr/bin/grep -c -F`, each prints `1` today:

| File:line | Fixed string |
|---|---|
| `plugins/memory-sync/scripts/memory-sync.sh:42` | `plugin-provided hook is not yet` |
| `plugins/memory-sync/scripts/memory-sync.sh:43` | `# confirmed, so at session end the harness can kill` |
| `plugins/memory-sync/skills/sync-memory/SKILL.md:69` | `is not yet confirmed` |
| `plugins/memory-sync/skills/sync-memory/SKILL.md:69` | `the final push is best effort` |
| `SKILL.md:12` | `do not run it as written` |
| `SKILL.md:12` | `-path '*/memory-sync/*/scripts/memory-sync.sh'` |
| `SKILL.md:12` | `has not been checked on an installed plugin` |
| `SKILL.md:12` | `list them and ask the user which to use; do not choose one yourself` |
| `SKILL.md:12` | `Never use a ` + backtick + `memory-sync.sh` + backtick + ` that lies directly in the config directory` |
| `SKILL.md:12` | `.orphaned_at` (1 line, 2 occurrences) |

The script's hedge is split across lines 42/43 by the plan's own S8 wrapping:
`not yet confirmed` as one string counts **0** in the script. A gate must use
the two half-strings above. A negative a gate can also count, `0` today:
`-name memory-sync.sh -path '*memory-sync*'` in `SKILL.md`.

**(c) `hooks.json`.** `grep -c user_config` → `0`; `userConfig` in
`plugin.json` → `0`; jq test that every command starts with
`"${CLAUDE_PLUGIN_ROOT}"/` → `true`. Matches the plan literal; no deviation.

## Unplanned changes

None. No call site, test or other file was forced to change.

## Tests

No test added or changed (plan `Tests`; `tests/` untouched, P13 third value 0).
Coverage as a list (`AGENTS.md` `## Tests`):

- S8 — no case: a comment. The 35 cases at the new path show behaviour
  unchanged; P13 shows 0 non-comment lines differ.
- S2 — no case: nothing here can start a session. Checked by `validate
  --strict`, `plugin details`, P11. Accepted by the plan (D4).
- S1, S3, S4–S7 — JSON and prose, no gate exists; checked by P8, P11, P12 and,
  for the S4 fallback only, the fake-layout run above.

## Gates

`export TMPDIR=/data/tmp/claude` first. CLI `2.1.286 (Claude Code)`, run under
a throwaway `CLAUDE_CONFIG_DIR` made with `${TMPDIR:?}` and removed.

| Command | Output |
|---|---|
| `bash -n plugins/memory-sync/scripts/memory-sync.sh` | `rc=0` (and `test -x` rc=0) |
| `shellcheck plugins/memory-sync/scripts/memory-sync.sh tests/memory-sync.test.sh` | no findings, `rc=0` |
| `bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh` | rc=0, 35 `ok` lines, `PASS 35/35` |
| `git diff -M HEAD -- memory-sync.sh plugins/memory-sync/scripts/memory-sync.sh` | `similarity index 96%`, one hunk `@@ -36,8 +36,11 @@`, 2 `-#` and 5 `+#` lines, nothing else |
| `jq .` on `hooks.json`, `plugin.json`, `settings.example.json` | rc=0 each |
| `claude plugin validate --strict plugins/memory-sync` | `✔ Validation passed`, rc=0 |
| `claude --plugin-dir plugins/memory-sync plugin details memory-sync` | `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`, rc=0 |

Note on the diff gate: the dispatch's one-path form
(`git diff HEAD -M -- plugins/memory-sync/scripts/memory-sync.sh`) prints the
whole file as new, because a pathspec that omits the old path hides the
rename. The plan's P13 two-path form was used; it is the one that shows
comment lines only.

Not run by me: `bash -n`/`shellcheck` of `plugins/glab/scripts/manager-bootstrap.sh`
(Slice G's file), `validate --strict .` and `plugins/glab` (G, D).

## Post-conditions — actual next to the plan's "finished"

| Check | S part, actual | Plan | State |
|---|---|---|---|
| P1 | `0`, `0`; the five `plugins/memory-sync/*` paths all listed | same | S part finished. The full 29-path list depends on G and D |
| P2 | `24`; `100755 plugins/memory-sync/scripts/memory-sync.sh`; `executable` | same | S part finished; the `manager-bootstrap.sh` lines are G's/M's |
| P7 | in `plugins/memory-sync/**` only `SKILL.md:2:name: sync-memory` | same | S part finished; rest is G |
| P8 | line 1 empty; `0`; `3`; `plugins/glab/hooks/hooks.json 1`, `plugins/memory-sync/hooks/hooks.json 4`, `…/sync-memory/SKILL.md 4` | same | prints the finished value in full right now; the `0`/`3` README lines and the glab line are D's and G's work |
| P11 | `memory-sync 0.1.0`; four hook lines `SessionStart 20 … pull`, `SessionEnd 20 … push`, `PostToolUse 20 … push-if-changed`, `Stop 20 … push-if-changed`; `[["env"],["AWS_PROFILE","CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS","CLAUDE_MEMORY_S3_ARGS","CLAUDE_MEMORY_S3_URI"]]`; `hooks.json:0` | same | S lines finished; marketplace and glab lines depend on D and G, not run |
| P12 | `s3://<bucket>`, `s3://my-bucket`, `s3://stub` | same | finished (second part); `link-ok` is G's |
| P13 | `0`, `7`, `0` | `0`, `7`, `0` | finished |
| V1 | S lines: `rc=0`, shellcheck `rc=0`, `PASS 35/35` | same | `manager-bootstrap.sh` line is G's |
| V2/V3 | memory-sync: `✔ Validation passed`; `Skills (1)  sync-memory`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop` | same | run with `--plugin-dir plugins/memory-sync`, not `./plugins`; the combined form needs G |

No post-condition differs from the plan.

## Blast radius

- **Hook wiring an installer now gets.** Enabling `memory-sync` wires four
  hooks with no further step: `SessionStart` → `pull`, `SessionEnd` → `push`,
  `PostToolUse` (matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`) and `Stop`
  → `push-if-changed`, 20 s each. They run against whatever
  `CLAUDE_MEMORY_S3_URI` the session has; unset → the script logs "not set;
  skipping" and exits 0. A machine that still has the old `settings.json`
  entries runs every sync twice (same lock, so they queue or skip).
- **`SessionEnd` 1.5 s budget.** The hook's `"timeout": 20` no longer raises
  the shared `SessionEnd` budget once it is plugin-provided. Without a working
  override the final `push` can be killed mid-run: no log line,
  `.memory-sync-pushed.next` left behind, no cool-down marker. S3 ships
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=20000` in the example; whether it
  covers a plugin hook is stated as not yet confirmed in both places it is
  mentioned. That variable, once merged, applies to every `SessionEnd` hook on
  the machine.
- **What hand-run commands rely on.** `SKILL.md:12,30,66,104` rely on Claude
  Code substituting `${CLAUDE_PLUGIN_ROOT}` into the skill body (UNVERIFIED,
  smoke row 9). If it is not substituted, the S4 fallback applies; it depends
  on the unverified cache layout and otherwise stops. Hand runs still read
  `CLAUDE_MEMORY_S3_*` from the user's `env` block (Q3) and share the config
  directory's lock and state with the hooks (Q5).
- **Script.** Comment only; hook contract unchanged (modes, exit 0,
  stderr-only, 12 default / 17 cap / +3 bound).
- **Rollback, before the commit** (plan *Back-out*, unit S; not run here):
  `git restore --worktree -- plugins/memory-sync && rm -r plugins/memory-sync/.claude-plugin plugins/memory-sync/hooks`.

## Follow-ups

Not written to `follow-ups.md` (the dispatch limits me to this file under `plan/`):

1. A gate for the hedges and the fallback, using the strings in (b).
2. Smoke-test row 10's Pass text should name the third outcome (several
   copies → ask).
3. After an install exists: confirm the cache layout and the `.orphaned_at`
   marker, then drop the "may" in `SKILL.md:12`.
4. The plan's UNVERIFIED list (`plan.md:1899`) describes the old fallback
   wording; its substance still holds.
5. `AGENTS.md` D7 version-bump rule: `0.1.0` is the first version, no bump due.

## Not done

Slices M, G, D — not mine. Not verified by me: anything needing a session
(substitution of `${CLAUDE_PLUGIN_ROOT}`, hooks firing, `SessionEnd` cut-off).
