# Follow-ups — feature-opencode-worker (rev 3 build)

Out of scope for the rev-3 build; each needs its own decision.

1. **K2 is not applied, and the replacement as given does not work.**
   L1b's two `|| exit 1` (`plan-r3.md` *After*, L1b; also
   `prototype-r3/l1b.sh` lines 5 and 11) close an interactive shell when the
   block is pasted. The given replacement `{ return 1 2>/dev/null || exit 1; }`
   closes it too: at an interactive top level `return` fails (status 1), so
   `exit 1` runs. Probe on this host, the line pasted into `bash -i`:
   it printed `exit`, never the next line's `STILL-ALIVE`, rc 1. It only
   helps when the block is sourced (`. file` → `sourced returned rc=1`).
   L1b exists only in `plan-r3.md` (not the developer's to edit) and in the
   hashed planning record `prototype-r3/l1b.sh`. The planner or manager
   decides the text the user runs.
2. **The post-condition hash of the skill now differs from the plan's
   record**: `plugins/glab/skills/external-agents/SKILL.md` is
   `34f0a824596a2760`, not `a2e6651ce7d43418`. K3 caused it, adding the
   fan-out reviewer's dimension to one sentence. An analyzer should expect
   this difference and no other.
3. **The *Integrate — the real CLI, offline* block was not run.** It runs
   the user's own `~/.opencode/bin/opencode`, which this build was told not
   to run. It belongs to Stage 4.
   *Status (manager, 2026-10-17):* run in Stage 4, `INTEGRATED`; see
   `integration-r3.md`.
4. **The mutant table was not re-run.** It is the planner's record
   (`prototype-r3/mutants-r3.py`). The tree's script and test are
   byte-identical to the plan's blocks (post-condition hashes), so the table
   applies to them unchanged.

## From review round 1 (the manager's decisions: not now)

5. **bwrap `--disable-userns`** for the sandbox, so the agent cannot make
   user namespaces of its own. This waits for the live probe, which has to
   show that OpenCode 2.0.31 still runs with it.
6. **Bind only the files of `/etc` the backend needs**, not the whole
   directory read-only. This also waits for the live probe, to confirm
   OpenCode still works.
7. **No case drives the window C4 closes in `send`**: the agent removed by a
   `stop` between `send`'s check and its lock. It is a race between two
   processes with no injection point. The re-check after the lock and the
   UNKNOWN AGENT answer, when the lock file can no longer be opened, are
   covered by reading the code only.
8. **The Kimi and GLM profiles were tuned from the user's notes**
   (`plan/feature-opencode-worker/notes/`), which are documentation-derived.
   They stay UNVERIFIED until L1 captures a real reply. Then re-tune each one
   from its transcript and cite it there.

## From review round 2

9. **No case drives R2-3's race, and none proves that `list` takes no
   lock.** The race is a `send` that locks the old lock file after a `stop`
   renamed the agent aside. Both need two processes interleaved at a point
   with no injection hook. Both rest on reading the code: the rename under the
   lock, the `-ef` check in `lock_agent`, and `turn_alive` in `list`.
10. **Raw `transcript.jsonl` can hold the key JSON-escaped**, for example its
    first character as `K`. `redact_stream` on the raw stream matches
    bytes and cannot see it. The decoded reply and `transcript.txt` are
    redacted (R2-6, E14). Redacting the raw JSON after decoding needs a
    decision on what the raw file is for.
11. **Rerun the offline Integrate block after R2-4.** It has to show that
    opencode 2.0.31 keeps its database in `~/.local/share/opencode` when
    `HOME=/home/worker`, and that `send` continues the session there. The
    block runs the user's real CLI, so this developer did not run it.
    *Status (manager, 2026-10-17):* rerun, `INTEGRATED` — `send` ended in
    the expected timeout, no unknown-session error; `integration-r3.md`,
    "Rerun after review round 2". That turn 2 sees turn 1's messages stays
    UNVERIFIED until L1.
12. **All four family profiles were tuned from the user's notes**
    (`plan/feature-opencode-worker/notes/`), which another model wrote as
    fill-in templates. They are secondary advice and stay UNVERIFIED until L1
    captures real replies. Then re-tune each one from its transcript, cite the
    transcript, and confirm the report marker lines survive.

## From review round 3 (all three reviewers `SHIP`; advisories, not fixed)

Round 3 was the last review round, so nothing was changed after it: the
commit is the tree the reviewers passed. Items 13–15 should be done as one
small reviewed change **before the user runs L1**, because 13 can make a
real reviewer's first report fail the check.

13. **The report check needs bare lines; the prompt never says so.** The
    validator matches `^rule: ` and the verdict at the left edge, while the
    reviewer's template the model fills is indented four spaces and shows
    verdicts in backticks — a literal copy is exit 8. Add one sentence to
    `reviewer_tail` in `external-agent.sh`: inside the block every line
    starts at the left edge, no indent, no backticks, the verdict line alone.
14. **`profiles/kimi.md`: "Every claim in your answer names its `file:line`"
    is absolute.** Claims backed by command output, the verdict and the
    not-checked lines have none; a model may invent one. Say "every claim
    about the code".
15. **`profiles/glm.md`: "plan, then analyse, then act"** goes to a
    read-only agent. Say "then answer".
16. **Truncation before redaction.** `opencode_error` cuts to 300 characters
    and the renderer slices to 500/2000 before `redact_stream`, so a key the
    raw pass missed and that crosses the cut keeps its prefix. Redact first,
    then cut (in jq, read the key from the environment, not argv).
17. **`transcript.jsonl` and the redaction claims** (with item 10): the
    skill says the key is redacted from "both transcripts", and the header,
    the skill and `README.md` say "everything this script writes". Only
    literal occurrences are replaced. Either re-encode the raw file through
    `jq -c .` before redaction and extend E14, or narrow the claim to
    "every literal occurrence" in all three files in one commit.
18. **Symlink-parent check and tar read are separate steps.** A parent
    swapped for a symlink in between is followed. Needs another process
    already writing to the user's own working tree; accepted. Record it in
    the header comment, or refuse any symlink in a parent position of a
    listed path after extraction.
19. **`turn_alive` prints a stray stderr line when `turn.pid` is missing**:
    bash applies `<` before `2>/dev/null`. Use
    `{ read -r tpid st <"$1/turn.pid"; } 2>/dev/null || return 1`.
20. **`send` during a start's key lookup gets 10, not 11.** `agent.json` is
    written after `read_secret` (up to 60 s). Write it with `ready: false`
    first, or return 11 when the directory exists, `agent.json` does not and
    the turn is alive.
21. **`stop` waits 30 s, but a TERM trap runs only after the foreground
    command ends** — up to the 60 s key lookup or a large copy, so `stop`
    can say BUSY although the turn ends later. Wait longer than the lookup,
    or run the lookup in the background and `wait` for it.
22. **Uncovered by any case** (AGENTS.md *Tests*): the `-ef` live-lock check
    in `lock_agent` (the race window cannot be made deterministic), and the
    gitlink `mkdir` reason (no test repo has a 160000 entry).
23. **Record correction:** `result-r3.md`, *Profile pass (round 2)*, says
    GLM's "one closing line" is gone. It is not: `glm.md` still says that
    with no template the out-of-scope note goes "in one closing line". That
    line is about where the note goes, not about the report shape, so P1
    holds (analyze round 3 found it; the code conforms).
