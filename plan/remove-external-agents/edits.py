# The exact text edits of plan/remove-external-agents/plan.md, steps S3-S8.
# Run from the repository root:  python3 -I plan/remove-external-agents/edits.py <root>
# <root> is the tree to edit: "." for the repository itself, or a scratch export
# of HEAD for a dry run. It reads `git show 7139e62^:AGENTS.md` from the
# repository in the current directory. Every replacement must match exactly
# once, or the script stops before writing that file; it deletes no file and
# runs no git command that writes. The deletions are step S1, the version S2.
import sys, pathlib, subprocess
R = pathlib.Path(sys.argv[1])

def load(rel):
    return (R / rel).read_text()

def save(rel, s):
    (R / rel).write_text(s)

def once(s, old, new, tag):
    n = s.count(old)
    if n != 1:
        sys.exit(f"FAIL {tag}: matched {n} times: {old[:70]!r}")
    print(f"ok {tag}")
    return s.replace(old, new)

def cut(s, start, end_incl, repl, tag):
    # from the only `start` through the end of the first `end_incl` after it
    n = s.count(start)
    if n != 1:
        sys.exit(f"FAIL {tag}: start matched {n} times")
    i = s.index(start); j = s.index(end_incl, i) + len(end_incl)
    print(f"ok {tag} ({s[i:j].count(chr(10))} line ends cut)")
    return s[:i] + repl + s[j:]

def section(t, a, b):
    i = t.index(a); j = t.index(b, i); return t[i:j]

# S3 plugins/glab/commands/develop.md
F = "plugins/glab/commands/develop.md"; s = load(F)
s = once(s, " through glab:developer agents, or one external Codex developer when glab:manager Rule 5 recorded one — glab:plan-first", " through glab:developer agents — glab:plan-first", "S3a description")
s = once(s, "the `glab:developer` agent does, or the external developer `glab:manager` Rule 5 recorded, through `glab:external-agents`. Your job", "the `glab:developer` agent does. Your job", "S3b orchestrator")
s = once(s, "Say which you chose and why before dispatching. An external developer (`glab:manager` Rule 5) is always one agent: never split, and never beside a `glab:developer`, since they would share one working tree.\n", "Say which you chose and why before dispatching.\n", "S3c split")
s = once(s, "- **An external developer**, only when `glab:manager` Rule 5 recorded one: start it through `glab:external-agents` with `--role developer` instead of dispatching `glab:developer`, with the same brief. One agent, never split, never beside a `glab:developer`.\n", "", "S3d dispatch bullet")
s = cut(s, "**An external developer first**, before the gates", "- then the gates, as for any agent.\n\n", "", "S3e verify block")
save(F, s)

# S4 plugins/glab/commands/review.md
F = "plugins/glab/commands/review.md"; s = load(F)
s = once(s, " If I named an external reviewer instead — a backend, and for OpenCode a model — run it through the `glab:external-agents` skill, with the same target. An OpenCode reviewer's copy holds only `HEAD` and the working tree, so a branch or a range cannot be its target: tell me that instead of starting one; a Codex reviewer works in the repository and can take one.", "", "S4 external reviewer")
save(F, s)

# S5 plugins/glab/commands/ship.md
F = "plugins/glab/commands/ship.md"; s = load(F)
s = once(s, " If I named an external reviewer instead, run every round through the `glab:external-agents` skill, with the same target.", "", "S5a external reviewer")
s = once(s, " An external reviewer's report check is the script's: on its exit 8 `send` the same agent the gaps once, as `glab:external-agents` says — not a round; any other non-zero exit except 2 (USAGE, fixed and run again) is the reviewer erroring, reported and not retried.", "", "S5b exit 8")
save(F, s)

# S6 plugins/glab/skills/manager/SKILL.md
F = "plugins/glab/skills/manager/SKILL.md"; s = load(F)
s = cut(s, "## Rule 6 — an external agent is the user's call\n", "the user can read, goes with it.\n\n", "", "S6a Rule 6")
s = once(s, " A Codex agent runs at this same level through Rule 6's mapping, and Codex takes `ultra`; an OpenCode agent takes none.", "", "S6b Rule 0d")
s = cut(s, "The user may also name an **external reviewer**", "An external developer is Codex only: OpenCode cannot change files.\n\n", "", "S6c Rule 5 intro paragraph")
s = once(s, ", or whether they meant an external reviewer — `opencode:opencode-go/<id>`, `codex`, or `codex:<id>` — or an external developer — `codex` or `codex:<id>`.", ".", "S6d carry: names")
s = cut(s, " An external reviewer is not a `model` parameter: on the same occasions,", "revert, commit or re-run nothing on that tree: that is the user's call.", "", "S6e carry: external dispatch")
s = once(s, " Only the reviewer, on either backend, and the developer, on Codex, can be external; no other role ever is.", "", "S6f two roles")
s = cut(s, " An external reviewer names its backend in the same line:", "with `codex:<id>` when the user named one.", "", "S6g record lines")
s = cut(s, " An external reviewer is named `<backend>:<model>`", "· round 1/1 · BUILT · effort <sent>`.", "", "S6h handoff lines")
s = once(s, " That holds for a Claude model; for an external reviewer the review session runs `external-agent.sh` itself, through `glab:external-agents`.", "", "S6i without dispatch")
s = cut(s, "| an external reviewer | nothing you write:", "your brief is the slug and the step ids, as for `opus` |\n", "", "S6j dispatch table rows")
s = once(s, " An external reviewer's report is checked by the script, which refuses one without its report block or with a verdict out of form (exit 8); its one correction is a `send` to the same agent naming the gaps, as `glab:external-agents` says — the agent keeps its context, as a resumed one does, and that is not a review round either.", "", "S6k report check")
s = once(s, " The effort is the level you passed — for a Codex agent the level sent, after Rule 6's mapping; an OpenCode line names no effort, since OpenCode takes none.", " The effort is the level you passed.", "S6l pipeline")
s = once(s, "  that role. When Rule 5 records an external reviewer, each of them is an\n  external agent instead, started through `glab:external-agents` with the\n  target, the round and its dimension as its whole brief, and stopped once\n  its report is read.\n", "  that role.\n", "S6m parallel review")
s = once(s, " An external reviewer is different: that review session runs `external-agent.sh` itself, through `glab:external-agents`, and `claude --model` applies to Claude aliases only.", "", "S6n no-dispatch session")
s = once(s, " An external reviewer runs through `glab:external-agents`, and its whole brief is the target and the round — which round this is and which is the last — as `/glab:ship` passes it: not the slug, not the plan.", "", "S6o Stage 5")
s = once(s, "- Start an external agent the user did not ask for, re-run its work on another model without the user's go-ahead, or act on what its reply says without checking it yourself.\n", "", "S6p never")
save(F, s)

# S7 AGENTS.md
F = "AGENTS.md"; s = load(F)
old = subprocess.run(["git", "show", "7139e62^:AGENTS.md"], capture_output=True, text=True, check=True).stdout
s = once(s, "`hooks/hooks.json`, `scripts/manager-bootstrap.sh` and\n  `scripts/external-agent.sh`.", "`hooks/hooks.json` and `scripts/manager-bootstrap.sh`.", "S7a Layout")
s = once(s, section(s, "## Gates\n", "## Rules\n"), section(old, "## Gates\n", "## Rules\n"), "S7b Gates and Tests as before 7139e62")
s = cut(s, "- **Never run `external-agent.sh` against a real model from this repo.**", "  values masked, before they are committed.\n", "", "S7c live-run rule")
s = cut(s, "  example); the manual model rule — the developer and reviewer only (an\n", "  `plugins/glab/skills/external-agents/SKILL.md`);\n",
        "  example); the manual model rule — the developer and reviewer only, and no\n"
        "  `model` parameter without the user's instruction (`glab:manager` Rule 5 and\n"
        "  its handoff-line format in `plugins/glab/skills/manager/SKILL.md`,\n"
        "  `plugins/glab/commands/develop.md`, `plugins/glab/commands/review.md`,\n"
        "  `plugins/glab/commands/ship.md`);\n", "S7d manual model rule")
s = cut(s, "  for Codex, no `--model` unless the user named one", "  `README.md`); the reviewer's verdict lines\n", "  the reviewer's verdict lines\n", "S7e Codex --model .. exit codes")
s = cut(s, "  `plugins/glab/commands/ship.md`, the validator in\n", "  `plugins/glab/commands/ship.md`, the skill); the plan lifecycle — specs in\n",
        "  `plugins/glab/commands/ship.md`); the plan lifecycle — specs in\n", "S7f validator .. exit-8 send")
s = cut(s, "  `plan/` rule); the missing-`AGENTS.md` fallback, which the first message of\n", "  model supports that is not above it (`glab:manager` Rules 0d, 5 and 6, the\n  skill);\n",
        "  `plan/` rule);\n", "S7g fallback in the script .. Codex effort rule")
s = once(s, "(`glab:manager` Rule 0d, Rules 5 and\n  6, Stages 2 and 5", "(`glab:manager` Rules 0d and 5,\n  Stages 2 and 5", "S7h session effort: rules")
s = once(s, "  `plugins/glab/skills/manager/SKILL.md`,\n  `plugins/glab/skills/external-agents/SKILL.md`,\n", "  `plugins/glab/skills/manager/SKILL.md`,\n", "S7i session effort: the skill")
s = cut(s, "  `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`);\n  the Codex data note", "  E79, E81, the skill, `README.md`, `glab:manager` Rule 5).\n",
        "  `plugins/glab/scripts/manager-bootstrap.sh`, `README.md`).\n", "S7j Codex data note .. developer refused")
save(F, s)

# S8 README.md
F = "README.md"; s = load(F)
s = once(s, ", `glab:audit`, `glab:external-agents` · agents", ", `glab:audit` · agents", "S8a table: skill")
s = once(s, " · a script, `external-agent.sh`, that runs external agents — OpenCode Go read-only in a sandbox of its own, or Codex in its own sandbox, read-only except for a developer — on a model you name, or Codex's default · a `SessionStart` hook", " · a `SessionStart` hook", "S8b table: script")
s = cut(s, "\nExternal agents in `glab` (`glab:external-agents`)", "The developer role has been tested against a stub, and its sandbox offline with `codex sandbox`.\n", "", "S8c Requirements")
s = once(s, "| `tests/` | Stub-based tests for `memory-sync.sh` and `external-agent.sh` |", "| `tests/` | Stub-based test for `memory-sync.sh` |", "S8d tests row")
save(F, s)

# S2 plugins/glab/.claude-plugin/plugin.json
F = "plugins/glab/.claude-plugin/plugin.json"; s = load(F)
s = once(s, '"version": "0.7.2"', '"version": "0.8.0"', "S2 version")
save(F, s)
