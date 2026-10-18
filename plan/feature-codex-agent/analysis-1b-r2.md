# feature-codex-agent: Stage 1b, round 2/2

Three analyzers checked `plan.md` revision 2 on 2026-10-18. All three found
the round-1 items resolved. All three still returned **NOT BUILDABLE**, with
five blockers between them, none of them a design problem. The manager relays
their reports here, as they gave them.

## B1: script steps P1–P3: NOT BUILDABLE (1)

1. P2 `codex_check` step 5 (plan:378-381) and the P4 stub (plan:541-545).
   - Neither the plan nor findings gives the JSON shape of
     `codex debug models`: not its top-level form, and not whether
     `supported_reasoning_levels` holds strings or objects.
   - So the developer would invent the shape and write the stub to match it,
     and E59 would pass either way.
   - No Stage-4 run uses `check` against the real Codex, so a wrong guess
     ships as `models: unavailable` with exit 0.
   - The same gap holds for `login status`: findings record its text, never
     its exit status.
   - Fix: record the raw shape from an offline run (`debug models --bundled`,
     throwaway `CODEX_HOME`, no network), and add `check --backend codex`
     to O1.

Non-blocking:

- a. `opencode_model_allowed` cannot keep the body of `:315-326` unchanged,
  because its arguments shift by one. E30 would catch it.
- b. Under `set -u`, the plan does not say where `isolation` and `turn_model`
  are initialised, or that `turn_model` is global.
- c. For host agents, the plan does not say how `head` and `branch` are
  computed once `copy_repo` is skipped, or what happens in a repository with
  no commit.
- d. Quoted `-c` keys such as `projects."<top>"` are unproven. D18 does not
  refuse `.` in the path, and O1's path has no dot.
- e. The host-text grep (plan:921) fails under a `%s` format, as B2.2 also
  found.
- f. The plan does not say which two binds of `:515-516` go into
  `opencode_mounts`. `setsid --wait` would be a safety net.

## B2: tests and post-conditions: NOT BUILDABLE (3)

1. The coverage list (plan:1013-1056) has gaps.
   - It claims E63 covers `codex_render`, but E63 asserts only `list` and
     `stop`.
   - No case covers the transcript heading `## turn n · codex:<model>`.
   - No scenario covers a present block whose model or session id is
     malformed (D5).
   - No case covers `run_host` closing inherited descriptors, the host
     counterpart of E40.
   - None of these is named as an accepted gap.
2. The post-condition at plan:921 (the host first message) cannot pass on a
   finished tree. With `<top>` passed through `printf`, removing `<top>`
   leaves "at  itself", and the `'` in single-quoted strings does not appear
   literally either. Either define the fragments that are searched, or rely
   on E61 alone.
3. Some steps pass every D line even when skipped:
   - P3's header-comment rewrite (nothing greps "2-12" or "12 NOT
     READ-ONLY");
   - P7 (checked only as "modified");
   - P6's Codex record line;
   - P8 `:9` and `:34-35`;
   - every One-fact entry P9 adds.

   AGENTS.md:84-86 makes the plan's searches the only check on Markdown.

Non-blocking:

- E56 holds. The exact form, re-run, gives
  `CODEX_HOME HOME LANG PATH TERM TMPDIR` after filtering.
- The test cleanup needs three things:
  - `CXH` defined before the trap, or written `${CXH:-}`;
  - the kill placed before the KEEP_W return;
  - a guard against PID reuse, killing only when `/proc/<pid>/environ` holds
    `TMPDIR=$W/tmp`.
- The `debug models` shape is not given anywhere (as B1.1).
- E28 is a G check, not a D one.
- The `turns` scenario is undefined.
- The greps at plan:926-927 are fragile when the text is rewrapped.
- Minor gaps the plan does not name:
  - the host stderr cap;
  - the `.model` fallback in `list`;
  - the `known_list` text;
  - E15 for `opencode_secret_hint`;
  - the host's `head` and `branch`.

## B3: docs and One-fact (P5–P10): NOT BUILDABLE (1)

1. The plan has no `## Record` section. `plan-first/SKILL.md:74` requires
   one, and `manager/SKILL.md:426,431` needs it for Stage 8. The section
   must also name `docs/specs/marketplace.md`, because P9 and P10 change the
   gates, the rules and the version.

Non-blocking:

- a. The rule that quoted phrases stay on one line should be extended to the
  greps at plan:926-927.
- b. The host-text grep should split each line at `<top>`.
- c. The plan does not say where the effort answer goes for a general Codex
  agent: Rule 5's line exists only for the developer and the reviewer.
- d. There are no greps for the A3.3 rewrites, and no per-step verification
  in P5–P8.
- e. The plan does not give the combined wording for README `:34-43`.
- f. The skill's `:64` and `:86` are OpenCode-only, and P5 does not qualify
  them. The README sentence at plan:810 is true only once O1 has passed.
