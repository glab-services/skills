#!/usr/bin/env python3
# The fix-probe-findings edits, S1a-S8 of plan.md, applied to the tree at
# argv[1] (the repo root, or a copy of it); later arguments pick step ids.
# Every before-text must occur exactly once in its file, or nothing is
# written for that edit and the exit status is 1.
import sys, pathlib

root = pathlib.Path(sys.argv[1])
only = set(sys.argv[2:])  # optional: step ids to apply

UNV_OLD = """- UNVERIFIED: that this text makes a real reply better. No reply from this
  family has been captured. The user's live probe (L1 in
  `plan/feature-opencode-worker/plan-r3.md`) captures one transcript; tune
  this profile from what it shows, and cite that transcript here.
"""

def refused(model):
    return f"""- UNVERIFIED: that this text makes a real reply better. No reply from this
  family has been captured: in the live probe of 2026-10-17
  (`plan/feature-opencode-worker/probe-r3/`), `{model}` was refused
  upstream before its first turn. Tune this profile from the first transcript
  a run captures, and cite that transcript here.
"""

EDITS = [
 ("S1a", "plugins/glab/scripts/external-agent.sh",
  """      # The verdict set is the one plugins/glab/agents/reviewer.md states.
      verdicts=$(command grep -cE '^(SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+)$' <<<"$text")
""",
  """      # The verdict set is the one plugins/glab/agents/reviewer.md states.
      # `BLOCK: 1 issue` is the same verdict as `BLOCK: 1 issues`: both Kimi
      # models wrote the singular in the live probe
      # (plan/feature-opencode-worker/probe-r3.md, finding 1). For one only:
      # no template and no reviewer writes `BLOCK: 3 issue`, and accepting it
      # would widen the check past what was seen.
      verdicts=$(command grep -cE '^(SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: 1 issue|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+)$' <<<"$text")
"""),
 ("S1b", "plugins/glab/scripts/external-agent.sh",
  """        n=$(sed -n 's/^BLOCK: \\([0-9][0-9]*\\) issues$/\\1/p' <<<"$text")
""",
  """        # Both forms, each matched whole as in the set above, so a line out of
        # form, such as `BLOCK: 3 issue` beside a SHIP, is never read as a count.
        n=$(sed -n -e 's/^BLOCK: \\([0-9][0-9]*\\) issues$/\\1/p' -e 's/^BLOCK: \\(1\\) issue$/\\1/p' <<<"$text")
"""),
 ("S2", "plugins/glab/agents/reviewer.md",
  "End with one verdict line: `SHIP`, `BLOCK: <n> issues`, or `BLOCK: target unresolved` when step 2b",
  "End with one verdict line: `SHIP`, `BLOCK: <n> issues` (for one issue, `BLOCK: 1 issue` is the same verdict), or `BLOCK: target unresolved` when step 2b"),
 ("S3", "plugins/glab/commands/ship.md",
  "- `BLOCK: <n> issues` or `BLOCK: target unresolved` → stop here.",
  "- `BLOCK: <n> issues`, `BLOCK: 1 issue` or `BLOCK: target unresolved` → stop here."),
 ("S4a", "tests/external-agent.test.sh",
  """\trev-zero) text "$(printf '=== REPORT START ===\\nBLOCK: 0 issues\\n=== REPORT END ===')" ;;
""",
  """\trev-zero) text "$(printf '=== REPORT START ===\\nBLOCK: 0 issues\\n=== REPORT END ===')" ;;
\t# The singular verdict, for one issue and for two (E49).
\trev-one) text "$(printf '=== REPORT START ===\\na.txt:1 — x\\nrule: correctness\\nbreaks when: y\\nfix: z\\nBLOCK: 1 issue\\n=== REPORT END ===')" ;;
\trev-one-bare) text "$(printf '=== REPORT START ===\\nBLOCK: 1 issue\\n=== REPORT END ===')" ;;
\trev-two-singular) text "$(printf '=== REPORT START ===\\na.txt:1 — x\\nrule: correctness\\nbreaks when: y\\nfix: z\\nb.txt:2 — w\\nrule: correctness\\nbreaks when: y\\nfix: z\\nBLOCK: 2 issue\\n=== REPORT END ===')" ;;
"""),
 ("S4b", "tests/external-agent.test.sh",
  """for v in '`SHIP`' '`SHIP WITH SCOPE CUT: <what to drop>`' '`BLOCK: <n> issues`' '`BLOCK: target unresolved`' '`DO NOT PUBLISH: <one line why>`'; do command grep -qF -- "$v" "$W/plugin/agents/reviewer.md" || ok=0; done
command grep -qF -- 'SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+' "$SCRIPT" || ok=0
""",
  """for v in '`SHIP`' '`SHIP WITH SCOPE CUT: <what to drop>`' '`BLOCK: <n> issues`' '`BLOCK: 1 issue`' '`BLOCK: target unresolved`' '`DO NOT PUBLISH: <one line why>`'; do command grep -qF -- "$v" "$W/plugin/agents/reviewer.md" || ok=0; done
command grep -qF -- 'SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: 1 issue|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+' "$SCRIPT" || ok=0
"""),
 ("S4c", "tests/external-agent.test.sh",
  "# E37-E48 were added after E36 was written, and run before it: E36 checks\n",
  "# E37-E49 were added after E36 was written, and run before it: E36 checks\n"),
 ("S4d", "tests/external-agent.test.sh",
  """t E48 "every reviewer message, the first and each send, says after the two report lines that the block's lines start at the left edge: no indent, no backticks on the verdict and rule: lines, and the verdict alone"
""",
  """t E48 "every reviewer message, the first and each send, says after the two report lines that the block's lines start at the left edge: no indent, no backticks on the verdict and rule: lines, and the verdict alone"

# Both Kimi models wrote the verdict for one issue in the singular in the live
# probe. It is accepted for one only, and its count is checked as the
# plural's is: without the second sed expression rev-one-bare would pass.
M=opencode-go/kimi-k3 start rev-one --role reviewer; r1=$RC o1=$(reply)
stop_all
M=opencode-go/kimi-k3 start rev-one-bare --role reviewer; r2=$RC e2=$ERR
stop_all
M=opencode-go/kimi-k3 start rev-two-singular --role reviewer; r3=$RC e3=$ERR
stop_all
[ "$r1" = 0 ] && [ "$(tail -n 1 <<<"$o1")" = 'BLOCK: 1 issue' ] \\
\t&& [ "$r2" = 8 ] && command grep -qF 'verdict says 1 issues, the report has 0 findings' <<<"$e2" \\
\t&& [ "$r3" = 8 ] && command grep -qF 'expected exactly one verdict line, found 0' <<<"$e3" && OK=1
t E49 "BLOCK: 1 issue is accepted with its count checked, as BLOCK: 1 issues is; BLOCK: 2 issue is malformed (8)"
"""),
 ("S5a", "plugins/glab/skills/external-agents/profiles/kimi.md", UNV_OLD,
  """- UNVERIFIED: that this text makes a real reply better. Replies from this
  family were captured in the live probe of 2026-10-17, for `kimi-k3` and
  `kimi-k2.7-code` (`plan/feature-opencode-worker/probe-r3/`), but only with
  this profile, so nothing compares them with a reply without it. Tune this
  profile from those transcripts, and cite them here.
"""),
 ("S5b", "plugins/glab/skills/external-agents/profiles/glm.md", UNV_OLD,
  """- UNVERIFIED: that this text makes a real reply better. Replies from this
  family were captured in the live probe of 2026-10-17, for `glm-5.3`,
  `glm-5.3-flash` and `glm-5.2` (`plan/feature-opencode-worker/probe-r3/`),
  but only with this profile, so nothing compares them with a reply without
  it. Tune this profile from those transcripts, and cite them here.
"""),
 ("S5c", "plugins/glab/skills/external-agents/profiles/deepseek-pro.md", UNV_OLD, refused("deepseek-v4-pro")),
 ("S5d", "plugins/glab/skills/external-agents/profiles/deepseek-flash.md", UNV_OLD, refused("deepseek-v4.1-flash")),
 ("S6", "README.md",
  """External agents have been tested against a stub and against the real
`opencode` with no network, and have not yet run against a real model: that
is the live probe in `plan/feature-opencode-worker/plan-r3.md` (L1), which you
run with your own key. Until it has, treat the first real session as the
test it is.
""",
  """External agents have been tested against a stub, against the real `opencode`
with no network, and in one live probe on 2026-10-17
(`plan/feature-opencode-worker/probe-r3.md`): the five Kimi and GLM models
each answered a task, a `send` and a review through the sandbox, on a
one-file test repository.
Not yet shown: any reply from a DeepSeek model (both were refused upstream
before their first turn); how any model does on a real repository, a long
brief or a Go limit; and whether the profiles make a reply better. Treat the
first real session of any of these as the test it is.
"""),
 ("S7a", "AGENTS.md",
  """    command grep -c -F 'not yet run against a real model' README.md; echo "rc=$?"
""",
  """    command grep -c -F 'Not yet shown: any reply from a DeepSeek model' README.md; echo "rc=$?"
"""),
 ("S7b", "AGENTS.md",
  "The sentence says the external agents have not yet run against a real model; it stays until the user's live probe (`plan/feature-opencode-worker/plan-r3.md`, L1) has run, and no other gate notices when it is dropped or reworded into a claim that they have.",
  "The sentence says what the live probe of 2026-10-17 (`plan/feature-opencode-worker/probe-r3.md`) did not show: a reply from a DeepSeek model, a real repository, a long brief, a Go limit, the profiles' effect. It changes only when a later run has shown one of them, and no other gate notices when it is dropped or reworded into a claim that one has been shown."),
 ("S7c", "AGENTS.md",
  """  `external-agent.sh` also states; the sentence that external agents have not
  yet run against a real model (`README.md`, pinned by its gate line above).
""",
  """  `external-agent.sh` also states; the sentence on what the live probe did
  not show (`README.md`, pinned by its gate line above).
"""),
 ("S8", "plugins/glab/.claude-plugin/plugin.json",
  '  "version": "0.4.1",\n', '  "version": "0.4.2",\n'),
]

bad = 0
for sid, f, old, new in EDITS:
    if only and sid not in only:
        continue
    p = root / f
    s = p.read_text()
    c = s.count(old)
    print(f"{sid} {f}: before-text found {c} time(s)")
    if c != 1:
        bad = 1
        continue
    p.write_text(s.replace(old, new))
sys.exit(bad)
