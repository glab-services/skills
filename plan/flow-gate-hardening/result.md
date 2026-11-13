# Result — flow-gate-hardening

Built on `flow-gate-hardening` at `f6fcb14`; nothing staged or committed. `TMPDIR=/data/tmp/claude` for every command; no temp directory left behind (`ls -d $TMPDIR/fgh-* $TMPDIR/plan-gate-f6fcb14.* $TMPDIR/claude-config.* | wc -l` → `0`).

## Stages

- **B1** done: `git diff --quiet f6fcb14 -- <four files>; echo rc=$?` → `rc=0`; HEAD `f6fcb14`. B2 was run by the manager before dispatch (nine `rc=0`, shellcheck `rc=0`, PASS 35/24/42/13/17); not re-run.
- **S1** done: `plugins/glab/scripts/plan-gate.sh` replaced by the `awk` extract of `steps-1-script.md`; sha256 `e6cb9bfb5dc3d5b97ae9ab528365d0fb98ebe08a82544a91bd6ac9a793239bcd`, 520 lines, mode kept (no mode change in `git diff`). Diff hunks against `f6fcb14` fall at old lines 20, 67, 74, 77, 79, 96, 100, 107, 206–216: header, trap block, `claim` up to `claimed_tmp`, `publish_file` — as S1 says. No TODO/FIXME/NOTE/XXX line removed (`git diff … | grep -E '^-.*(TODO|FIXME|NOTE|XXX)'` → rc=1).
- **S2** done: `tests/plan-gate.test.sh` replaced by the `awk` extract of `steps-2-test.md`; sha256 `e405b9f1ed7a2084e88e30d26281c75da794e575da25b5fae53769628a665d1d`, 939 lines, mode kept. Hunks at old lines 10, 507, 527, 532, 538, 604 (header comment, T37 comment, helpers after `launched`, T38, T43–T51 before T22).
- **S3** done: `plugins/glab/.claude-plugin/plugin.json:3` `"version": "0.14.1"`.
- **S4** done: `AGENTS.md:128-130`, the plan's replacement text, nothing else.

## Blocked

None.

## Unplanned changes

None.

## Tests

- Updated T38; added T43–T51 (from S2's text, not authored here). `bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh` → 51 `ok`, `PASS 51/51`.
- Coverage, per `AGENTS.md` *Tests* (a list): as `plan.md` *Tests* states; confirmed by A7 below, each mutant failing the case the plan maps to it. Uncovered and accepted per the plan: the holds in `claim`/`take_over` at the instant after a create (A5 only), a lock left by SIGKILL inside `take_over`, `take_over`'s `io` branches, state `X`, a store on another account, hosts without `/proc` — UNVERIFIED as the plan says.

## Gates

Shell block (once):
- nine lines `<file> rc=0`; `shellcheck … ; echo rc=$?` → `rc=0`, no findings.
- memory-sync `PASS 35/35`, context-size `PASS 24/24`, plan-gate `PASS 51/51`, manager-bootstrap `PASS 13/13`, product-loop `PASS 17/17`; every other line `ok`.

Plugin block (once, `CLAUDE_CONFIG_DIR` a fresh empty mktemp dir, removed after):
- three `✔ Validation passed`.
- `Skills (21)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, product-manager, product-plan, product-plan-analyze, product-project-brief, product-project-plan-analyze, product-project-plan-report, product-project-plan-verdict, push, review, security, session-rules, ship`; `Agents (9)  reviewer, product-planner, integrator, developer, analyzer, product-analyzer, committer, planner, plan-analyzer`; `Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)`.
- `Skills (1)  sync-memory`, `Agents (0)`, `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)`.
- `glab = glab`, `memory-sync = memory-sync`; `user_config` `:0`, `:0`, `rc=1`; `not yet confirmed` `:1` ×3, `rc=0`.
- model gate: the nine expected `model:` lines exactly, `rc=0`.
- skills gate: the eighteen expected lines exactly, none `MISSING`.
- prefixed `name:` search: no line, `rc=1`.

## Posts

- **A1/A2**: as Gates; `PASS 51/51`.
- **A3**: four `openat` lines in order — claim `O_RDONLY|O_CLOEXEC`, `.plan-gate.takeover.report.r1` `O_WRONLY|O_CREAT|O_EXCL`, claim `O_RDONLY|O_CLOEXEC`, claim `O_WRONLY|O_CREAT|O_EXCL`. (I also stripped strace's pid prefix with `sed` for display.)
- **A4**: `FAIL T38 FAIL T43 FAIL T44 FAIL T45 FAIL T46 FAIL T47 FAIL T48 FAIL T49 FAIL T50 FAIL T51 FAIL T22 FAIL 11/51` — as expected.
- **A5**: the five expected lines exactly (`window-old`/`nohold`/`takeover-nohold` leave the claim; `window-new`/`takeover` leave `brief.md` only; all `rc=143`).
- **A6**: NOT RUN — the dispatch forbade ten-run loops for budget. UNVERIFIED: ten consecutive `PASS 51/51` on this tree — not run by instruction; one run of each is green (A1, A7 base).
- **A7** (once): M10 `FAIL T43`; M11 `FAIL T44`; M12 `FAIL T44`; M1 `FAIL T46 FAIL T48 FAIL 2/51`; M2 `FAIL T47`; M3, M4, M5 `FAIL T49`; M6 `FAIL T50`; M7 `FAIL T51`; M8b `FAIL T33 T37 T40 T44 FAIL 4/51`; M8 `FAIL T45 T22`; M9 `FAIL T45 T22`. None `PASS`. One difference from E11's list: M1 also failed T48 (E11 lists T46 only); the post's bar (none `PASS`, the mapped case fails) holds. Whether T48 fails on M1 every run is UNVERIFIED — one run only.
- **A8**: `trace byte-identical`, `434`.
- **A9**: `0.14.1`; `1`; `1 file changed, 2 insertions(+), 1 deletion(-)`.
- **A10**: the four ` M` lines and the expected `??` lines, plus `plan/flow-gate-hardening/master.sha256` (allowed by A10); `result.md` is added by this report.

## Follow-ups

None written.

## Not done

- The `docs/specs/` edits of `master.md` *Record* — held for the record step, per dispatch.
- A6 (see Posts).

## Review round 1 fixes

`TMPDIR=/data/tmp/claude` throughout. Every temp directory was removed afterwards (count `0`). Nothing is staged.

- **Finding 1 (create in a subshell)**: `plugins/glab/scripts/plan-gate.sh:174-189` adds `MASK=$(umask)`, read once at load before any signal is held, and `create_line <file>`. It is the main-shell create: `umask 022`, `set -C`, `{ printf '%s\n' "$ME" >"$1"; } 2>/dev/null || rc=1`, `set +C`, `umask "$MASK"`, `return "$rc"`. The three subshell creates now call it: claim `:213`, the lock `:250`, and take_over's claim `:258`. The last one is the same pattern as the other two, so it has the same gap. Refusal texts and exit codes are unchanged. The comment at `:90-104` now says why the create runs in this bash, tagged `[flow-gate-hardening/review-1.md finding-1]`. That file name assumes the manager saves this round's review as `review-1.md`.
  - Stand-in check: `create_line` was extracted and run under `umask 077`. The first call gave `rc=0`, mode `644`, the line written, and umask `0077` and flags `hBc` afterwards. The second call gave `rc=1` with nothing on stderr and the same umask and flags.
  - Before and after proof: I built instrumented copies under `$TMPDIR`, each sleeping 2 s right after one create's open. Each copy ran as `report` in its own process group, with SIGINT reset to default through a `python3` `setsid`/`execvp` wrapper (a background job starts with INT ignored). After 1 s, `kill -INT -- -<pgid>`. Results:
    - `before-claim: rc=130 left: .plan-gate.claim.report.r1 brief.md`
    - `before-lock: rc=130 left: .plan-gate.claim.report.r1 .plan-gate.takeover.report.r1 brief.md` (stale claim planted)
    - `before-takeover: rc=130 left: .plan-gate.claim.report.r1 brief.md` (stale claim planted)
    - `after-claim`, `after-lock` and `after-takeover`: each `rc=130 left: brief.md`, stderr empty.
  - No permanent case was added. It would need an instrumented copy of the script.
- **Finding 2 (tags)**: `plan-gate.sh:95` now reads `[flow-product-level/review-2.md finding-2] [flow-product-level/follow-ups.md FR2-1]`, and `:224` reads `[flow-product-level/follow-ups.md FR2-2]`.
- **Finding 3 (T44)**: in `tests/plan-gate.test.sh:668-698`, case 2 (`:677-680`) now uses the real boot id and pid namespace, a foreign host and a dead pid, guarded by `PROC`. The new case 5 (`:689-692`) has the real host and namespace, the boot id `00000000-0000-0000-0000-000000000000` and a dead pid. The loop now runs `1 2 3 4 5`, and the comment and the `done_case` text name the new case.
  - Mutant check: one mutant drops the host comparison in `owner_gone` and one drops the boot comparison. Each gives `FAIL T44 FAIL 1/51`.
- **Advisory**: the `owner_gone` comment at `plan-gate.sh:152-154` now says only the bash is checked. A child such as an `ln` in flight can outlive a SIGKILL sent to the bash. That is harmless: the new run refuses on `plan.r<n>/`, and `ln` never overwrites.

New sha256 values (they no longer match steps-1/steps-2, as expected):
- `plugins/glab/scripts/plan-gate.sh`: `f545c4ddc9b4da2a025b469b1efa1d2d8f0483863284d88c6d3cddcd9610fa90` (543 lines).
- `tests/plan-gate.test.sh`: `72bf26da108baa6e69445fee64ac26e08a75e5ed706310601f9424bd537f881e` (948 lines).

Gates:
- Shell block, run once: nine `rc=0` lines. Shellcheck gave `rc=0` with no findings. memory-sync `PASS 35/35`, context-size `PASS 24/24`, plan-gate `PASS 51/51`, manager-bootstrap `PASS 13/13`, product-loop `PASS 17/17`, and every other line `ok`.
- plan-gate test, run 3 times in a row: `PASS 51/51` each time.
- Plugin block, run once with a fresh `CLAUDE_CONFIG_DIR` that was removed afterwards: three `✔ Validation passed`; `Skills (21)`, `Agents (9)` and `Hooks (4)` as *Gates* lists them; `Skills (1)  sync-memory`, `Agents (0)` and `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`; `glab = glab`, `memory-sync = memory-sync`; `:0 :0 rc=1`; `:1 ×3 rc=0`; the nine model lines with `rc=0`; the eighteen skills lines, none `MISSING`; the prefixed-name search printed nothing, `rc=1`.
