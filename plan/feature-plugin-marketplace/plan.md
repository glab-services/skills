# Plan — feature-plugin-marketplace

Turn this repo into the Claude Code plugin marketplace `glab-services` holding
two plugins, `glab` and `memory-sync`. Built on `findings.md` and the answers
at the end of `questions.md` (Q1–Q7, D1–D4). Written 2026-10-05 against `main`
at `2aeb46d`. Amended once on the same day after the plan analysis (round 1,
`BUILDABLE`): steps M5, S4, S6, S8, D2, D4 and D6 changed text, no step id
changed, checks P15–P17 are new, and P1, P2, P11 and P14 were extended.

**Scope.** Repo only. No step reads or writes anything under `~/.claude`, and
no step runs `claude plugin install`, `marketplace add`, `enable` or
`configure`. Every `claude` run uses a throwaway `CLAUDE_CONFIG_DIR`.

**How to read the steps.** Every step in `processing` is one instruction with
a stable id, in one of three forms. The forms are literal: a prototype of this
plan was built by a script that read these blocks out of this file and applied
them, so what is written here is what was tested.

- `sh` — run the fenced command from the repo root.
- `file` — create or replace the named file with exactly the fenced content.
- `edit` — in the named file, replace the first fenced block (*before*) with
  the second (*after*). The *before* text occurs exactly once in the file; if
  it does not, stop and report `PLAN WRONG`.

**The naming rule, stated once** (findings section 5; D3):

- An *identifier* gets its plugin prefix: a backticked skill or agent name, a
  slash command, and a dispatch phrase ("use the **reviewer** agent",
  "developer agents"). `` `manager` `` → `` `glab:manager` ``, `/plan` →
  `/glab:plan`, **reviewer** agent → **glab:reviewer** agent.
- A frontmatter `name:` stays bare. Claude Code adds the prefix, and an agent
  name containing `:` does not load.
- A role noun in running prose stays as it is: "the analyzer drifts",
  "dispatch analyzers", "the reviewer looked at". It names nothing callable.
  No pattern in this plan matches those, in a step or in a check.
- The exact boundary, so the steps and the checks agree: an agent name is
  prefixed only where it stands in backticks, in `**bold**` directly before
  the word "agent", or directly before " agent" / " agents". A `glab:<agent>`
  anywhere else is a mistake, and P16 counts those. A backticked word that is
  a pipeline stage and not a skill — `` `integrate` ``, `` `commit` ``,
  `` `push` ``, `` `review ⇄` `` in `skills/bootstrap/SKILL.md:86-96` — is
  not in the skill list and stays bare; it has no slash, so it is not a
  command reference either.
- One result of the rule reads oddly and is kept on purpose:
  `agents/analyzer.md:69` has the report label `` `for /review:` ``, which G8
  turns into `` `for /glab:review:` ``. It is the command's name followed by
  the label's colon. Rewording it would make that file the only one whose
  text differs from today's by more than the prefix, and P17 relies on that
  not happening.

**Boundary.** Marketplace at the repo root, plugins in `plugins/<name>/`,
tests at the root. Rejected, with reasons, in findings section 6: one plugin
for everything; the repo root as the `glab` plugin; `bin/memory-sync.sh`;
tests inside the plugin.

**Tests.** No test case is added or changed. `tests/memory-sync.test.sh` is
not edited; only the path passed to it changes. Coverage, as a list
(`AGENTS.md` `## Tests`):

| Steps | Covered by |
|---|---|
| M6 (script moves) | all 35 cases, run against the new path (gate V1) |
| S8 (comment in the script) | no case — a comment; V1 shows behaviour unchanged, P13 shows only comment lines differ |
| G3, G4 (hook text) | no test file; checked by P10 (valid JSON, size, each rule present) |
| G2, S2 (`hooks.json`) | no case — nothing here can start a session; checked by V2, V3, P11 and the user's smoke test. Accepted: this is what D4 allows |
| all Markdown and JSON steps | no gate exists for prose (`AGENTS.md`); checked by P1–P9, P12, V2, V3 |

---

# Phase `before`

Nothing is changed in this phase. Each step is a command, what it must print,
and what it printed on 2026-10-05.

**B1 — clean tree at the expected commit.**

```bash
git status --short | /usr/bin/grep -v '^?? plan/' ; git rev-parse --short HEAD
```

Must print exactly `2aeb46d` and nothing else. Recorded: `2aeb46d`. If HEAD
has moved, re-check every `file:line` below before continuing.

**B2 — baseline gates** (`AGENTS.md:15-17`, today's paths).

```bash
export TMPDIR=/data/tmp/claude
for s in memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
shellcheck memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
bash tests/memory-sync.test.sh memory-sync.sh | tail -n 1
```

Must print three `rc=0` lines, `rc=0`, `PASS 35/35`. Recorded: exactly that.
`/data/tmp/claude` is the author's host; use the directory your host file
names.

**B3 — the CLI, and a throwaway config directory.** `claude` is the Claude
Code CLI: `claude` on `PATH`, or the path your host file names. On the
author's host it is not on `PATH`; `readlink /proc/$PPID/exe` from the Bash
tool prints it.

<!-- prelude -->
```bash
export TMPDIR=/data/tmp/claude
CLAUDE=${CLAUDE:-claude}
cfg=$(mktemp -d "${TMPDIR:?}/plugplan-config.XXXXXX") && [ -d "$cfg" ] && export CLAUDE_CONFIG_DIR="$cfg" || { echo "STOP: no throwaway config directory"; CLAUDE=false; }
SK='bootstrap|manager|security|comments|plan-first|audit'
AG='developer|analyzer|integrator|reviewer|committer'
CM='plan|develop|analyze|integrate|review|commit|push|ship'
files() { git ls-files -co --exclude-standard | /usr/bin/grep -v '^plan/'; }
per_file() { local f n; for f in $(files); do [ -f "$f" ] || continue; n=$(/usr/bin/grep -o -E -- "$1" "$f" | wc -l); [ "$n" -gt 0 ] && echo "$f $n"; done; return 0; }
"$CLAUDE" --version
```

Must print a version line. Recorded: `2.1.286 (Claude Code)`. **Keep this
shell**: every check in `after` (P1–P13, V1–V3) assumes this block was run in
it — the variables, the two functions and the throwaway `CLAUDE_CONFIG_DIR`.
The CLI writes `.claude.json` into its config directory even for
`plugin validate` (findings section 1); without the variable that directory is
the live `~/.claude`. If the directory cannot be made the block prints `STOP`
and sets `CLAUDE=false`, so no later check can start the CLI against the live
directory; `CLAUDE_CONFIG_DIR` is never exported empty. Remove the directory when done:
`rm -rf "$CLAUDE_CONFIG_DIR"` — look at the value first, it must be under
`$TMPDIR`.

**B4 — the patterns find what they are meant to find.** The "no bare
reference" checks in `after` prove an absence, so each pattern is proven on
today's tree first. The recorded *today* values under P3–P8 are that proof:
62, 10, 13, 54, 9 and 8 occurrences, matching findings section 9 lists R1, R4,
R6, R7, R3 and the script paths in R8/R9.

---

# Phase `processing`

Four slices. **M runs first and alone. G, S and D then run in parallel**: no
file is touched by two of them.

| Slice | File boundary | Steps | Order |
|---|---|---|---|
| **M** — moves | Moves the 24 payload files to their new paths with `git mv`; edits no content. | M1–M7 (7) | first, alone |
| **G** — glab | Everything under `plugins/glab/`, plus the deletion of the root `CLAUDE.md`. | G1–G15 (15) | after M |
| **S** — memory-sync | Everything under `plugins/memory-sync/`. | S1–S8 (8) | after M |
| **D** — root docs | `.claude-plugin/marketplace.json`, `README.md`, `AGENTS.md`, `host.example.md`. | D1–D9 (9) | after M |

`tests/` and `plan/` are in no slice: nothing there changes. No step stages or
commits. `git mv` stages the renames it makes; every later edit is left
unstaged, which is what makes the per-slice back-out in `after` work.

## Slice M — moves

Each step moves whole files; history follows (`git log --follow`). Mode bits
travel with `git mv` and are asserted by P2.

**M1** — the six workflow skills, 7 files (`skills/{audit,bootstrap,comments,manager,plan-first,security}/`).

<!-- sh M1 -->
```bash
mkdir -p plugins/glab/skills && for s in audit bootstrap comments manager plan-first security; do git mv "skills/$s" "plugins/glab/skills/$s"; done
```

**M2** — the five agents (`agents/*.md`).

<!-- sh M2 -->
```bash
mkdir -p plugins/glab && git mv agents plugins/glab/agents
```

**M3** — the eight commands (`commands/*.md`).

<!-- sh M3 -->
```bash
mkdir -p plugins/glab && git mv commands plugins/glab/commands
```

**M4** — the bootstrap hook script (`manager-bootstrap.sh`).

<!-- sh M4 -->
```bash
mkdir -p plugins/glab/scripts && git mv manager-bootstrap.sh plugins/glab/scripts/manager-bootstrap.sh
```

**M5** — the sync skill (`skills/sync-memory/SKILL.md`). After this `skills/` is an empty directory that git does not list; the step removes it. `rmdir` removes only an empty directory, so it cannot take a file with it. `agents/` and `commands/` were moved whole by M2 and M3 and leave nothing behind (P1).

<!-- sh M5 -->
```bash
mkdir -p plugins/memory-sync/skills && git mv skills/sync-memory plugins/memory-sync/skills/sync-memory && rmdir skills
```

**M6** — the sync script (`memory-sync.sh`).

<!-- sh M6 -->
```bash
mkdir -p plugins/memory-sync/scripts && git mv memory-sync.sh plugins/memory-sync/scripts/memory-sync.sh
```

**M7** — the settings example (`settings.example.json`). It stays an example for the user's own `settings.json`; S3 reduces it to the `env` block.

<!-- sh M7 -->
```bash
git mv settings.example.json plugins/memory-sync/settings.example.json
```

## Slice G — the `glab` plugin

**G1** — manifest. New file.

<!-- file G1 plugins/glab/.claude-plugin/plugin.json -->
````json
{
  "name": "glab",
  "version": "0.1.0",
  "description": "The glab workflow: plan, develop, analyze, integrate, review, commit and push through dedicated agents, with evidence and comment discipline",
  "author": {
    "name": "glab-services"
  },
  "repository": "https://github.com/glab-services/skills"
}
````

**G2** — hook wiring. New file. One `SessionStart` hook, timeout 5 as in
`settings.example.json:12` today. Shell form with the variable in double
quotes, as the docs require for a path that may contain spaces.

<!-- file G2 plugins/glab/hooks/hooks.json -->
````json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/manager-bootstrap.sh", "timeout": 5 }
        ]
      }
    ]
  }
}
````

**G3** — header comment of the hook script (was `manager-bootstrap.sh:2-4`).
The "irreducible minimum" sentence of `CLAUDE.md:6-8` lands here, because this
script is now the only place that minimum lives.

<!-- edit G3 plugins/glab/scripts/manager-bootstrap.sh -->
````text
# SessionStart hook — makes the bootstrap, manager and security skills a requirement of every
# session, in every project, including ones with no CLAUDE.md of their own.
# Always exits 0: a bootstrap that can fail a session start is worse than none.
````
````text
# SessionStart hook of the glab plugin — makes the glab:bootstrap, glab:manager and glab:security
# skills a requirement of every session, in every project, including ones with no CLAUDE.md of
# their own.
# The text below is the irreducible minimum: the rules that must hold even in a session where
# glab:bootstrap never got loaded. A plugin cannot ship global instructions — a CLAUDE.md at a
# plugin root is not loaded — so the copy that used to sit in the global CLAUDE.md lives only
# here. Keep it short: Claude Code caps a hook's additionalContext at 10,000 characters.
# Always exits 0: a bootstrap that can fail a session start is worse than none.
````

**G4** — the injected text (was `manager-bootstrap.sh:11-17`). Prefixes the
seven skill names (findings list R1: `manager-bootstrap.sh` 11, 12, 13, 15×2,
17×2), adds the `glab:manager` Rule 0c pointer to item 3 (`CLAUDE.md:17-18`),
and adds item 4, the host-file rule, word for word from `CLAUDE.md:19-26`.
Item 1 (line 9) is not touched.

<!-- edit G4 plugins/glab/scripts/manager-bootstrap.sh -->
````text
2. Load the `bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:
   - `manager` — the operating model. Work moves through plan -> develop -> analyze -> integrate -> review -> commit -> push, each stage dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Every agent you dispatch reads `AGENTS.md` first AND carries the `security` and `comments` disciplines. Say all of it in the dispatch message.

`manager` governs HOW work is done, not whether: questions are answered directly, and trivial changes (~5 lines, no architectural impact) are made directly — the skill says so itself. `security` does not have that exemption. A trivial change still gets its claim verified, and a gate is never reported green on an agent's word.
````
````text
2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load two skills and run the session under both:
   - `glab:manager` — the operating model. Work moves through plan -> develop -> analyze -> integrate -> review -> commit -> push, each stage dispatched to its own agent. You manage; you do not implement. Keep to the context budget it defines.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Every agent you dispatch reads `AGENTS.md` first AND carries the `glab:security` and `glab:comments` disciplines. Say all of it in the dispatch message. See `glab:manager` Rule 0c for the full list and for which skills are your call per dispatch.

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, repeat its temp-file rule in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 1 has the read; step 6 explains why this matters.

`glab:manager` governs HOW work is done, not whether: questions are answered directly, and trivial changes (~5 lines, no architectural impact) are made directly — the skill says so itself. `glab:security` does not have that exemption. A trivial change still gets its claim verified, and a gate is never reported green on an agent's word.
````

**G5** — prefix every backticked skill name in the plugin's Markdown.
Findings list R1, the glab files: `agents/reviewer.md` 15×2;
`commands/develop.md` 13, 51; `commands/plan.md` 6, 12, 16;
`skills/bootstrap/SKILL.md` 35×2, 39, 41, 45, 46, 47, 51, 52, 53, 54×2, 57,
59, 87, 100; `skills/manager/SKILL.md` 12, 20, 38, 41, 50, 53, 54, 258 —
31 occurrences in 5 files, now under `plugins/glab/`.

<!-- sh G5 -->
```bash
sed -i -E 's/`(bootstrap|manager|security|comments|plan-first|audit)`/`glab:\1`/g' plugins/glab/agents/*.md plugins/glab/commands/*.md plugins/glab/skills/*/SKILL.md
```

**G6** — prefix every backticked agent name. Findings list R4, the glab
files: `commands/develop.md` 8, 37; `skills/manager/SKILL.md` 241, 285, 303 —
5 occurrences in 2 files.

<!-- sh G6 -->
```bash
sed -i -E 's/`(developer|analyzer|integrator|reviewer|committer)`/`glab:\1`/g' plugins/glab/agents/*.md plugins/glab/commands/*.md plugins/glab/skills/*/SKILL.md
```

**G7** — prefix every dispatch phrase. Findings list R6: `commands/analyze.md`
2, 6; `commit.md` 2, 8; `develop.md` 2; `integrate.md` 2, 6; `review.md` 2, 8;
`ship.md` 2×2, 16, 36 — 13 occurrences in 6 files. Two expressions: the bold
form, then the plain form. The plain form requires that the name is not
already preceded by `:`, a letter, a backtick or `*`, so it cannot match a
second time and cannot touch what G6 produced.

<!-- sh G7 -->
```bash
sed -i -E -e 's/\*\*(developer|analyzer|integrator|reviewer|committer)\*\* agent/**glab:\1** agent/g' -e 's/(^|[^:A-Za-z`*])(developer|analyzer|integrator|reviewer|committer) (agents?)/\1glab:\2 \3/g' plugins/glab/commands/*.md
```

**G8** — prefix every slash command. Findings list R7, the glab files:
`agents/analyzer.md` 3×2, 69; `agents/developer.md` 3, 9;
`agents/integrator.md` 3×3; `commands/analyze.md` 10, 14, 15; `commit.md` 12;
`develop.md` 2, 12, 13, 47, 61, 67×2; `integrate.md` 10×2, 16, 17; `plan.md`
16; `ship.md` 14×2, 40; `skills/manager/SKILL.md` 97–104, 125, 155, 161, 190,
239, 275, 285, 293, 303, 309×2 — 46 occurrences in 10 files. The command must
be preceded by line start, a space, a backtick, `(`, `*` or `"`, which is what
keeps `plan/{slug}/plan.md` and `../plan-first/` out.

<!-- sh G8 -->
```bash
sed -i -E 's#(^|[ `(*"])/(plan|develop|analyze|integrate|review|commit|push|ship)($|[^A-Za-z0-9_/-])#\1/glab:\2\3#g' plugins/glab/agents/*.md plugins/glab/commands/*.md plugins/glab/skills/*/SKILL.md
```

**G9** — skill named without backticks, in a description (was `commands/develop.md:2`; G7 and G8 change other words on the same line, this step only the skill name).

<!-- edit G9 plugins/glab/commands/develop.md -->
````text
 — plan-first steps 5 to 7 — 
````
````text
 — glab:plan-first steps 5 to 7 — 
````

**G10** — the same (was `commands/plan.md:2`).

<!-- edit G10 plugins/glab/commands/plan.md -->
````text
plan a task with the plan-first skill, before
````
````text
plan a task with the glab:plan-first skill, before
````

**G11** — the same (was `skills/audit/SKILL.md:3`).

<!-- edit G11 plugins/glab/skills/audit/SKILL.md -->
````text
leads directly into implementation, use plan-first instead.
````
````text
leads directly into implementation, use glab:plan-first instead.
````

**G12** — link text (was `skills/audit/SKILL.md:21`). The link target is not changed: both skills are siblings in the plugin, so `../plan-first/SKILL.md` still resolves (P12).

<!-- edit G12 plugins/glab/skills/audit/SKILL.md -->
````text
changing the code, use [plan-first](../plan-first/SKILL.md) instead
````
````text
changing the code, use [glab:plan-first](../plan-first/SKILL.md) instead
````

**G13** — link text (was `skills/audit/SKILL.md:69`).

<!-- edit G13 plugins/glab/skills/audit/SKILL.md -->
````text
that work goes through [plan-first](../plan-first/SKILL.md).
````
````text
that work goes through [glab:plan-first](../plan-first/SKILL.md).
````

**G14** — skills named without backticks, in a description (was `skills/bootstrap/SKILL.md:3`).

<!-- edit G14 plugins/glab/skills/bootstrap/SKILL.md -->
````text
loads the manager and security skills, finds
````
````text
loads the glab:manager and glab:security skills, finds
````

**G15** — delete the root `CLAUDE.md` (Q7). Run after G3 and G4: by then each
of its rules is in the hook text (table under P10). History keeps the file.

<!-- sh G15 -->
```bash
git rm -q CLAUDE.md
```

## Slice S — the `memory-sync` plugin

**S1** — manifest. New file. No `userConfig` (Q3).

<!-- file S1 plugins/memory-sync/.claude-plugin/plugin.json -->
````json
{
  "name": "memory-sync",
  "version": "0.1.0",
  "description": "Syncs Claude Code memories to and from S3 or an S3-compatible store on session hooks, with a skill for doing it by hand",
  "author": {
    "name": "glab-services"
  },
  "repository": "https://github.com/glab-services/skills"
}
````

**S2** — hook wiring. New file. The four entries of
`settings.example.json:11,19,27,34`, with the same matcher and the same 20 s
timeouts, and the path changed to the plugin's own. `manager-bootstrap.sh` is
not here: it belongs to `glab` (G2).

<!-- file S2 plugins/memory-sync/hooks/hooks.json -->
````json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/memory-sync.sh pull", "timeout": 20 }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/memory-sync.sh push", "timeout": 20 }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|NotebookEdit|Bash",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/memory-sync.sh push-if-changed", "timeout": 20 }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/memory-sync.sh push-if-changed", "timeout": 20 }
        ]
      }
    ]
  }
}
````

**S3** — the settings example becomes the `env` block only (Q3, Q4). Replaces
the whole file moved by M7. The `hooks` object is gone — the hooks ship in the
plugins — and one key is new: the `SessionEnd` budget (Q4). Placeholders only.

<!-- file S3 plugins/memory-sync/settings.example.json -->
````json
{
  "env": {
    "CLAUDE_MEMORY_S3_URI": "s3://<bucket>/<prefix>",
    "AWS_PROFILE": "<profile, or delete this key>",
    "CLAUDE_MEMORY_S3_ARGS": "<extra aws arguments, or delete this key>",
    "CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS": "20000"
  }
}
````

**S4** — where the script is and what runs it (was `skills/sync-memory/SKILL.md:11-13`).

<!-- edit S4 plugins/memory-sync/skills/sync-memory/SKILL.md -->
````text
`~/.claude/memory-sync.sh`. Four hook events in `~/.claude/settings.json` run it automatically: `SessionStart` pulls,
````
````text
`${CLAUDE_PLUGIN_ROOT}/scripts/memory-sync.sh`, the script this plugin ships. Claude Code fills that path in when it loads this skill, and it changes with every plugin update, so copy it from here each time; the variable does not exist in the shell. If the path above still begins with a dollar sign and a brace, it was not filled in: do not run it as written. Find the script with `find "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins" -type f -name memory-sync.sh -path '*memory-sync*'`, tell the user which copy you are using, and put that path in the commands below; if nothing is found, say so and stop. Four hook events in the plugin's `hooks/hooks.json` run the script automatically: `SessionStart` pulls,
````

**S5** — the hand-run example (was `skills/sync-memory/SKILL.md:30`).

<!-- edit S5 plugins/memory-sync/skills/sync-memory/SKILL.md -->
````text
~/.claude/memory-sync.sh push
````
````text
"${CLAUDE_PLUGIN_ROOT}/scripts/memory-sync.sh" push
````

**S6** — the "are the hooks live" check (was `skills/sync-memory/SKILL.md:65-66`).
It also records the `SessionEnd` limit (findings 7.4) where someone diagnosing
a silent sync will read it. Line 52 ("It is set in the `env` block of
`~/.claude/settings.json`") stays: Q3 keeps that true.

<!-- edit S6 plugins/memory-sync/skills/sync-memory/SKILL.md -->
````text
4. **Are the hooks live?** `jq '.hooks' ~/.claude/settings.json` should show
   `SessionStart`, `SessionEnd`, `PostToolUse` and `Stop` entries pointing at the script.
````
````text
4. **Are the hooks live?** They ship in this plugin, not in `settings.json`:
   `jq '.hooks | keys' "${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json"` should show
   `PostToolUse`, `SessionEnd`, `SessionStart` and `Stop`, and `/plugin` should list `memory-sync` as enabled.
   An entry for the script that is still in `~/.claude/settings.json` from before the plugin runs as well, so every sync happens twice — it should be removed.
   `SessionEnd` is the weak one: Claude Code gives all `SessionEnd` hooks 1.5 seconds between them, and a timeout set by a plugin's hook does not raise that. `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` in the `env` block is the documented override for that budget; whether it also covers a hook that a plugin provides is not yet confirmed. Until it is, the final push is best effort: it can be cut off with no log line. Edits already sent by `push-if-changed` are not affected.
````

**S7** — the delete example (was `skills/sync-memory/SKILL.md:101`).

<!-- edit S7 plugins/memory-sync/skills/sync-memory/SKILL.md -->
````text
~/.claude/memory-sync.sh delete <project>/memory/<file>
````
````text
"${CLAUDE_PLUGIN_ROOT}/scripts/memory-sync.sh" delete <project>/memory/<file>
````

**S8** — a comment in the script that names a file which no longer holds the
hook timeout (was `memory-sync.sh:38-40`). Comment only: no line of code
changes, the hook contract is untouched (P13). The `SessionEnd` exception is
recorded here because this comment is where the 20 s reasoning lives.

<!-- edit S8 plugins/memory-sync/scripts/memory-sync.sh -->
````text
# Why 12: a run can last up to the limit plus 3 s (see `bounded` below), and the hook timeout in
# settings.example.json is 20 s, so 12 leaves 5 s for the script to log its own timeout before
# the harness kills it.
````
````text
# Why 12: a run can last up to the limit plus 3 s (see `bounded` below), and the hook timeout in
# this plugin's hooks/hooks.json is 20 s, so 12 leaves 5 s for the script to log its own timeout
# before the harness kills it. SessionEnd is the exception: Claude Code gives all SessionEnd hooks
# 1.5 s between them, and a plugin hook's own timeout does not raise that. The documented override
# is CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS; whether it covers a plugin-provided hook is not yet
# confirmed, so at session end the harness can kill the script before it logs anything.
````

## Slice D — root documents

**D1** — the marketplace. New file (Q1).

<!-- file D1 .claude-plugin/marketplace.json -->
````json
{
  "name": "glab-services",
  "description": "The glab workflow for Claude Code, and a hook that syncs Claude Code memories to S3",
  "owner": {
    "name": "glab-services"
  },
  "plugins": [
    {
      "name": "glab",
      "source": "./plugins/glab",
      "description": "The glab workflow: skills, agents, commands and the session bootstrap hook"
    },
    {
      "name": "memory-sync",
      "source": "./plugins/memory-sync",
      "description": "Syncs Claude Code memories to and from S3 on session hooks"
    }
  ]
}
````

**D2** — `README.md`, rewritten (D3: plugin install only, prefixed names).
Replaces the whole file. Carried over from today's README: the requirements
(`:36-39`), the host-file step (`:43-46`), the event table (`:61-66`), the
time-limit paragraph (`:68-72`), the `AWS_PROFILE` warning (`:76-78`), the
hand-run `delete` (`:80-81`). Dropped: the `cp` install (`:47-53`) and the
hook-wiring instruction (`:58-59`) — D3. Rewritten: the `SessionEnd` sentence
(`:72-74`), which is wrong for a plugin hook — the new paragraph says what is
documented and what is not yet confirmed (Q4). New: who can install and what
credential they need, background auto-update, and the two settings keys for a
team rollout. Those three follow
`https://code.claude.com/docs/en/plugins/host-marketplace.md` ("Grant access
to a private marketplace", "What background auto-update does with
credentials", "Turn on auto-update") and
`https://code.claude.com/docs/en/plugins/org.md` ("Require a marketplace and
its plugins", "Require plugins per repository"), read again on 2026-10-05.
They describe the docs; none of it was run (D4).

<!-- file D2 README.md -->
````markdown
# skills

A Claude Code plugin marketplace, `glab-services`, with two plugins: the
workflow we run in every session, and the hooks that sync Claude Code memories
to S3.

| Plugin | What it adds |
|---|---|
| `glab` | Skills `glab:bootstrap`, `glab:manager`, `glab:security`, `glab:comments`, `glab:plan-first`, `glab:audit` · agents `glab:developer`, `glab:analyzer`, `glab:integrator`, `glab:reviewer`, `glab:committer` · commands `/glab:plan`, `/glab:develop`, `/glab:analyze`, `/glab:integrate`, `/glab:review`, `/glab:commit`, `/glab:push`, `/glab:ship` · a `SessionStart` hook that injects the session bootstrap rules |
| `memory-sync` | Skill `memory-sync:sync-memory` · hooks on four events that run `memory-sync.sh` |

In `glab` the skills, agents and commands are one set: `glab:manager`
dispatches the agents through the commands, and every agent carries
`glab:security` and `glab:comments`. The two plugins do not depend on each
other; install either alone.

A plugin cannot ship global instructions. The session rules reach a session
through the `glab` `SessionStart` hook, so they hold only while `glab` is
enabled.

## Requirements

Linux with bash. `jq` is optional: the `glab` hook falls back to plain text
without it. `memory-sync` also needs GNU coreutils (`timeout`, `stat`,
`date`), util-linux `flock`, `rsync` and the AWS CLI. macOS is not supported.

## Install

This marketplace is a private repository, for people in the organization
only. Claude Code has no token of its own: it runs `git` on your machine with
the credentials the machine already holds, and with prompts turned off.
Before you add the marketplace you need both of these:

- read access to `glab-services/skills` on GitHub;
- a credential git can use without asking: either an SSH key for GitHub that
  is loaded in `ssh-agent`, with `github.com` already in `known_hosts`, or a
  stored HTTPS credential — run `gh auth login`, then `gh auth setup-git`.

Adding by `owner/repo`, as below, tries SSH first and falls back to HTTPS.
Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` to skip the SSH attempt.

1. **Create `~/.claude/host.md` from `host.example.md` first**, and edit it for
   the machine. Facts about one machine — the temp directory, tool paths — live
   there and nowhere in these files. Without it a session has no temp-directory
   rule and falls back to `$TMPDIR` or its scratchpad, which may be a small `/tmp`.
2. Add the marketplace and install the plugins you want:

   ```bash
   claude plugin marketplace add glab-services/skills
   claude plugin install glab@glab-services
   claude plugin install memory-sync@glab-services
   ```
3. For `memory-sync`, set its environment, below.

Each plugin carries a `version`. `claude plugin update glab@glab-services`
fetches a newer one; a change that did not raise the version is not delivered.

Background auto-update is off for this marketplace until you turn it on
(`/plugin`, Marketplaces, Enable auto-update). When it is on it uses the same
stored credentials and never prompts. A `GITHUB_TOKEN` in the environment
does not authenticate it by itself: a token takes effect through a credential
helper, such as the one `gh auth setup-git` installs.

### Rolling out to a team

To register the marketplace and enable both plugins from settings instead of
by hand, set these two keys — in managed settings for every machine, or in one
repository's `.claude/settings.json` for the people who work in it:

```json
{
  "extraKnownMarketplaces": {
    "glab-services": {
      "source": { "source": "github", "repo": "glab-services/skills" }
    }
  },
  "enabledPlugins": {
    "glab@glab-services": true,
    "memory-sync@glab-services": true
  }
}
```

Every person still needs the access and the credential described above. In a
repository's settings the marketplace entry applies only once that person has
trusted the folder.

## Configuring `memory-sync`

The hooks ship in the plugin. Its settings do not, because a plugin cannot set
environment variables: merge the `env` block of
`plugins/memory-sync/settings.example.json` into `~/.claude/settings.json` and
replace every `<…>` placeholder.

| Event | Runs |
|---|---|
| `SessionStart` | `memory-sync.sh pull` |
| `SessionEnd` | `memory-sync.sh push` |
| `PostToolUse` | `memory-sync.sh push-if-changed` |
| `Stop` | `memory-sync.sh push-if-changed` |

`CLAUDE_MEMORY_S3_TIMEOUT` is optional and defaults to 12 seconds. A run can
last up to 3 seconds longer than that, and the plugin gives each hook 20
seconds. The largest value accepted is 17, because 17 + 3 seconds is that
20-second hook timeout; a larger value is rejected — the script says so on
stderr and uses 12.

Keep `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` in the `env` block. All
`SessionEnd` hooks share a 1.5-second budget, and the timeout a plugin sets on
its own hook does not raise it. Claude Code documents this variable as the
override for that budget; whether it also covers a hook that a plugin provides
is not yet confirmed. Until it is, treat the push at session end as best
effort: it can be cut off with no log line. Edits made during the session are
not affected: `push-if-changed` has already sent them.

`AWS_PROFILE` is optional. In the `env` block it sets the profile for every
`aws` command any agent runs in every session, not only for `memory-sync.sh` —
delete the key if you do not want that.

`memory-sync.sh delete <project>/memory/<file>` is run by hand, never from a
hook. It is the only way to remove a memory for good — see the
`memory-sync:sync-memory` skill, which also gives the script's installed path.

The script keeps its stage copy, its stamps and its lock in `~/.claude`
(`.memory-sync-*`), not in the plugin's data directory, so hooks and hand runs
share one lock. Uninstalling the plugin leaves those files in place.

## Working on this repo

| Path | What it is |
|---|---|
| `AGENTS.md` | Working agreement for changes to this repo, and the gates |
| `.claude-plugin/marketplace.json` | The marketplace: lists both plugins |
| `plugins/` | The two plugins. Payload: written for the sessions of whoever installs them |
| `host.example.md` | Template for the per-machine `~/.claude/host.md` |
| `tests/` | Stub-based test for `memory-sync.sh` |
| `plan/` | Planning records |

To try a change without installing anything, load the plugins for one session:
`claude --plugin-dir ./plugins` loads both, `claude --plugin-dir ./plugins/glab`
loads one. Do not pass the repo root: the CLI does not read `marketplace.json` from a
`--plugin-dir`, so neither plugin loads — at most an empty plugin named after
the directory. Loading
`memory-sync` this way runs its hooks against whatever `CLAUDE_MEMORY_S3_URI`
that session has.
````

**D3** — `AGENTS.md`, what the repo is and where things are (was `AGENTS.md:3-7`).

<!-- edit D3 AGENTS.md -->
````text
This repo is the source for a global Claude Code setup. Everything the README
lists under **Installed to `~/.claude`** is **payload**: it is written for
`~/.claude` on some machine, not for this repo. That includes the root
`CLAUDE.md` — when it and this file disagree about how to work *in this
repo*, this file wins.
````
````text
This repo is a Claude Code plugin marketplace, `glab-services`, holding two
plugins. Everything under `plugins/` is **payload**: it is written for the
sessions of whoever installs a plugin, not for this repo. When payload text
and this file disagree about how to work *in this repo*, this file wins.

## Layout

- `.claude-plugin/marketplace.json` — the marketplace. It lists both plugins.
- `plugins/glab/` — the workflow plugin: its skills, agents and commands,
  `hooks/hooks.json` and `scripts/manager-bootstrap.sh`.
- `plugins/memory-sync/` — the memory sync plugin: its one skill,
  `hooks/hooks.json`, `scripts/memory-sync.sh` and `settings.example.json`.
- `tests/`, `plan/`, `host.example.md`, `README.md` and this file belong to
  the repo and to neither plugin.
````

**D4** — `AGENTS.md`, the gates (was `AGENTS.md:15-20`). New paths for the
three existing gates; the plugin gates are added.

<!-- edit D4 AGENTS.md -->
````text
    for s in memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
    shellcheck memory-sync.sh manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh memory-sync.sh

Green is: three `rc=0` lines; `rc=0` with no findings; every line `ok`, last
line `PASS n/n`.
````
````text
    for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; test -x "$s"; echo "$s rc=$?"; done
    shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
    bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh

Green is: three `rc=0` lines; `rc=0` with no findings; every line `ok`, last
line `PASS n/n`. The `test -x` is there because a hook script that has lost
its execute bit passes every other gate and then fails when the hook runs.

Then the plugin gates. `claude` is the Claude Code CLI: `claude` on `PATH`, or
the path your host file names. **Every `claude` command run in this repo has
`CLAUDE_CONFIG_DIR` set to a new, empty directory under that temp directory.**
The CLI writes into its config directory even for `plugin validate`, and
without the variable that directory is the live `~/.claude`.

    cfg=$(mktemp -d "${TMPDIR:?}/claude-config.XXXXXX") && [ -d "$cfg" ] && (
      export CLAUDE_CONFIG_DIR="$cfg"
      for p in plugins/glab plugins/memory-sync .; do claude plugin validate --strict "$p" | tail -n 1; done
      claude --plugin-dir ./plugins plugin details glab | command grep -E '^  (Skills|Agents|Hooks) '
      claude --plugin-dir ./plugins plugin details memory-sync | command grep -E '^  (Skills|Agents|Hooks) '
    ); rm -rf "${cfg:?}"
    jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r n s; do echo "$n = $(jq -r .name "$s/.claude-plugin/plugin.json")"; done
    command grep -c user_config plugins/*/hooks/hooks.json; echo "rc=$?"
    command grep -rH --include='*.md' '^name: .*:' plugins; echo "rc=$?"

The first of these makes the config directory and starts no `claude` command
when it cannot — with `TMPDIR` unset nothing runs — and removes the directory
again at the end. `CLAUDE_CONFIG_DIR` is never exported empty.

Green is:

- three `✔ Validation passed` lines;
- for `glab`: `Skills (14)` naming the six skills and the eight commands, `Agents (5)`, and `Hooks (1)  SessionStart`;
- for `memory-sync`: `Skills (1)  sync-memory`, `Agents (0)`, and `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`;
- `glab = glab` and `memory-sync = memory-sync`. Validation does not compare a marketplace entry with the plugin it points at; it passes with a wrong name and with a directory that does not exist;
- `:0` after each `hooks.json`, then `rc=1`. `grep -c` exits 1 when it counts nothing, and nothing is the green result here. A `${user_config.…}` in a hook command passes validation and fails when the hook runs;
- no line, then `rc=1`, from the last command. A frontmatter `name:` that carries the plugin prefix passes validation and `plugin details`, and nothing else catches it.
````

**D5** — `AGENTS.md`, the install rule (was `AGENTS.md:45-46`).

<!-- edit D5 AGENTS.md -->
````text
- **Nothing is copied into `~/.claude` by an agent.** Installing is the
  user's step.
````
````text
- **Nothing is copied into `~/.claude` by an agent, and no agent installs a
  plugin.** No agent runs `claude plugin install`, `claude plugin marketplace
  add`, `claude plugin enable` or `claude plugin configure`, in a shell or
  through `/plugin`. Installing is the user's step. An agent tests with
  `claude plugin validate` and `--plugin-dir`, under the `CLAUDE_CONFIG_DIR`
  rule in *Gates*.
````

**D6** — `AGENTS.md`, the paths in "One fact, one value" (was `AGENTS.md:51-55`), and three new known cases. The third exists because the expected counts in *Gates* are a copy of the tree: add a skill and the number in this file is wrong until someone changes it.

<!-- edit D6 AGENTS.md -->
````text
  (`agents/reviewer.md`, `commands/ship.md`, `skills/manager/SKILL.md`,
  `skills/bootstrap/SKILL.md`); the missing-`AGENTS.md` fallback (every agent
  and command); the hook events (`settings.example.json`, `README.md`,
  `skills/sync-memory/SKILL.md`, the header of `memory-sync.sh`); the default
  time limit of `memory-sync.sh` (the script, its test, `README.md`).
````
````text
  (`plugins/glab/agents/reviewer.md`, `plugins/glab/commands/ship.md`,
  `plugins/glab/skills/manager/SKILL.md`,
  `plugins/glab/skills/bootstrap/SKILL.md`); the missing-`AGENTS.md` fallback
  (every agent and command); the hook events
  (`plugins/memory-sync/hooks/hooks.json`, `README.md`,
  `plugins/memory-sync/skills/sync-memory/SKILL.md`, the header of
  `plugins/memory-sync/scripts/memory-sync.sh`); the default time limit of
  `memory-sync.sh` (the script, its test, `README.md`); the marketplace and
  plugin names (`.claude-plugin/marketplace.json`, both `plugin.json`,
  `README.md`); the session-start rules (the text in
  `plugins/glab/scripts/manager-bootstrap.sh` and the `glab:bootstrap` skill);
  what each plugin holds — its component counts and its hook events (the
  *Gates* section of this file, `README.md`, each plugin's `hooks/hooks.json`).
````

**D7** — `AGENTS.md`, two new rules, placed after the last rule (was `AGENTS.md:60`): the version bump (Q6) and the naming rule, so the next edit follows it.

<!-- edit D7 AGENTS.md -->
````text
- `plan/` is tracked and permanent.
````
````text
- `plan/` is tracked and permanent.
- **A change under `plugins/<name>/` raises that plugin's `version`** in
  `plugins/<name>/.claude-plugin/plugin.json`, in the same commit. An installed
  copy is pinned to the version string: without a new one nobody receives the
  change, and nothing says so.
- **Payload text names a plugin component by its prefixed name** —
  `glab:manager`, `glab:developer`, `/glab:plan`. The frontmatter `name:` of a
  skill or agent stays bare: Claude Code adds the prefix, and an agent name
  containing `:` does not load. A role named in running prose — "the
  analyzer", "the reviewer" — is not an identifier and stays as it is.
````

**D8** — `host.example.md`, the skill name (was `host.example.md:4`; findings list R1).

<!-- edit D8 host.example.md -->
````text
facts that are true of one machine only. `bootstrap` step 1 reads it at
````
````text
facts that are true of one machine only. `glab:bootstrap` step 1 reads it at
````

**D9** — `host.example.md`, where the CLI is (was `host.example.md:23`). A
placeholder, not the author's path: the path holds a version number and is
stale after the next update.

<!-- edit D9 host.example.md -->
````text
The system grep is `/usr/bin/grep`.
````
````text
The system grep is `/usr/bin/grep`.

The Claude Code CLI is `<path to the claude binary on this host>`. A session
started by the desktop app has no `claude` on `PATH`; from its Bash tool,
`readlink /proc/$PPID/exe` prints the binary that is running the session. The
path contains the CLI version, so it changes with every update — look it up
each time rather than keeping an old one.
````

---

# Phase `after`

## Post-conditions

Run from the repo root, in the shell that ran the B3 block. Each gives the
command, what a finished tree prints, and what today's tree (`2aeb46d`)
printed. Both values are real: *finished* was recorded on a prototype built
from the steps above, *today* on a clean clone of `2aeb46d`. A check that
cannot tell the two apart is marked **non-discriminating** and says what it is
for instead.

**P1 — nothing is left at an old path, not even an empty directory, and every
file is at its new one.**

<!-- check P1 -->
```bash
git ls-files -- skills agents commands manager-bootstrap.sh memory-sync.sh settings.example.json CLAUDE.md | wc -l
ls -d skills agents commands 2>/dev/null | wc -l
git ls-files -co --exclude-standard -- plugins .claude-plugin | LC_ALL=C sort
```

Finished — `0`, `0`, then exactly these 29 paths:

```
0
0
.claude-plugin/marketplace.json
plugins/glab/.claude-plugin/plugin.json
plugins/glab/agents/analyzer.md
plugins/glab/agents/committer.md
plugins/glab/agents/developer.md
plugins/glab/agents/integrator.md
plugins/glab/agents/reviewer.md
plugins/glab/commands/analyze.md
plugins/glab/commands/commit.md
plugins/glab/commands/develop.md
plugins/glab/commands/integrate.md
plugins/glab/commands/plan.md
plugins/glab/commands/push.md
plugins/glab/commands/review.md
plugins/glab/commands/ship.md
plugins/glab/hooks/hooks.json
plugins/glab/scripts/manager-bootstrap.sh
plugins/glab/skills/audit/SKILL.md
plugins/glab/skills/audit/references/plan-template.md
plugins/glab/skills/bootstrap/SKILL.md
plugins/glab/skills/comments/SKILL.md
plugins/glab/skills/manager/SKILL.md
plugins/glab/skills/plan-first/SKILL.md
plugins/glab/skills/security/SKILL.md
plugins/memory-sync/.claude-plugin/plugin.json
plugins/memory-sync/hooks/hooks.json
plugins/memory-sync/scripts/memory-sync.sh
plugins/memory-sync/settings.example.json
plugins/memory-sync/skills/sync-memory/SKILL.md
```

Today — `25` tracked files at old paths, the `3` directories, no new path:

```
25
3
```

**P2 — the moves are renames git can follow, and the scripts are executable
in the index and on disk.** The index mode cannot fail on its own: `git mv`
copies it whatever the file on disk says. The third command reads the disk,
which is what the hook runner uses.

<!-- check P2 -->
```bash
git status --short | /usr/bin/grep -c '^R'
git ls-files -s -- plugins/glab/scripts/manager-bootstrap.sh plugins/memory-sync/scripts/memory-sync.sh tests/memory-sync.test.sh | awk '{print $1, $4}'
for f in plugins/glab/scripts/manager-bootstrap.sh plugins/memory-sync/scripts/memory-sync.sh tests/memory-sync.test.sh; do test -x "$f" && echo "executable $f" || echo "NOT executable $f"; done
```

Finished:

```
24
100755 plugins/glab/scripts/manager-bootstrap.sh
100755 plugins/memory-sync/scripts/memory-sync.sh
100755 tests/memory-sync.test.sh
executable plugins/glab/scripts/manager-bootstrap.sh
executable plugins/memory-sync/scripts/memory-sync.sh
executable tests/memory-sync.test.sh
```

Today:

```
0
100755 tests/memory-sync.test.sh
NOT executable plugins/glab/scripts/manager-bootstrap.sh
NOT executable plugins/memory-sync/scripts/memory-sync.sh
executable tests/memory-sync.test.sh
```

The `24` holds before the commit; it is what tells a `git mv` from a
copy-and-delete.

**P3 — no bare backticked skill name remains; the prefixed form is there.**

<!-- check P3 -->
```bash
per_file "\`($SK|sync-memory)\`"
echo --
per_file "\`(glab:($SK)|memory-sync:sync-memory)\`"
```

Finished: nothing from the first command, then

```
--
AGENTS.md 2
README.md 11
host.example.md 1
plugins/glab/agents/reviewer.md 2
plugins/glab/commands/develop.md 2
plugins/glab/commands/plan.md 3
plugins/glab/scripts/manager-bootstrap.sh 9
plugins/glab/skills/bootstrap/SKILL.md 16
plugins/glab/skills/manager/SKILL.md 8
```

Today: the first command prints the 9 files of findings list R1 (62 in all),
the second prints nothing:

```
CLAUDE.md 11
README.md 12
agents/reviewer.md 2
commands/develop.md 2
commands/plan.md 3
host.example.md 1
manager-bootstrap.sh 7
skills/bootstrap/SKILL.md 16
skills/manager/SKILL.md 8
--
```

**P4 — no bare backticked agent name remains; the prefixed form is there.**

<!-- check P4 -->
```bash
per_file "\`($AG)\`"
echo --
per_file "\`glab:($AG)\`"
```

Finished: nothing, then

```
--
AGENTS.md 1
README.md 5
plugins/glab/commands/develop.md 2
plugins/glab/skills/manager/SKILL.md 3
```

Today (list R4, 10 in all), then nothing:

```
README.md 5
commands/develop.md 2
skills/manager/SKILL.md 3
--
```

**P5 — no bare dispatch phrase remains; the prefixed form is there.**

<!-- check P5 -->
```bash
per_file "\*\*($AG)\*\* agent|(^|[^:A-Za-z\`*])($AG) agents?"
echo --
per_file "\*\*glab:($AG)\*\* agent|glab:($AG) agents?"
```

Finished: nothing, then

```
--
plugins/glab/commands/analyze.md 2
plugins/glab/commands/commit.md 2
plugins/glab/commands/develop.md 1
plugins/glab/commands/integrate.md 2
plugins/glab/commands/review.md 2
plugins/glab/commands/ship.md 4
```

Today (list R6, 13 in all), then nothing:

```
commands/analyze.md 2
commands/commit.md 2
commands/develop.md 1
commands/integrate.md 2
commands/review.md 2
commands/ship.md 4
--
```

**P6 — no bare slash command remains; the prefixed form is there.**

<!-- check P6 -->
```bash
per_file "(^|[ \`(*\"])/($CM)(\$|[^A-Za-z0-9_/-])"
echo --
per_file "/glab:($CM)(\$|[^A-Za-z0-9_/-])"
```

Finished: nothing, then

```
--
AGENTS.md 1
README.md 8
plugins/glab/agents/analyzer.md 3
plugins/glab/agents/developer.md 2
plugins/glab/agents/integrator.md 3
plugins/glab/commands/analyze.md 3
plugins/glab/commands/commit.md 1
plugins/glab/commands/develop.md 7
plugins/glab/commands/integrate.md 4
plugins/glab/commands/plan.md 1
plugins/glab/commands/ship.md 3
plugins/glab/skills/manager/SKILL.md 19
```

Today (list R7, 54 in all), then nothing:

```
README.md 8
agents/analyzer.md 3
agents/developer.md 2
agents/integrator.md 3
commands/analyze.md 3
commands/commit.md 1
commands/develop.md 7
commands/integrate.md 4
commands/plan.md 1
commands/ship.md 3
skills/manager/SKILL.md 19
--
```

**P7 — the only unprefixed, unbackticked skill names left are the two
frontmatter `name:` lines; every frontmatter name is still bare.**

<!-- check P7 -->
```bash
for f in $(files); do [ -f "$f" ] && /usr/bin/grep -n -H -E "(^|[^\`/A-Za-z:-])(plan-first|sync-memory)(\$|[^\`/A-Za-z-])|(^|[^:\`A-Za-z])(bootstrap|manager|security|comments|audit)( and [a-z:-]+|, [a-z:-]+ and [a-z:-]+)? skills?( |,|\$)" "$f"; done | cut -c1-110
/usr/bin/grep -h '^name: ' plugins/*/skills/*/SKILL.md plugins/glab/agents/*.md 2>&1 | sort | paste -sd' '
```

Finished:

```
plugins/glab/skills/plan-first/SKILL.md:2:name: plan-first
plugins/memory-sync/skills/sync-memory/SKILL.md:2:name: sync-memory
name: analyzer name: audit name: bootstrap name: comments name: committer name: developer name: integrator name: manager name: plan-first name: reviewer name: security name: sync-memory
```

Today:

```
commands/develop.md:2:description: Implement an approved plan through developer agents — plan-first steps 5 to
commands/plan.md:2:description: Size, analyze, question and plan a task with the plan-first skill, before any 
manager-bootstrap.sh:2:# SessionStart hook — makes the bootstrap, manager and security skills a requirement of
skills/audit/SKILL.md:3:description: Produce a structured audit findings document in plan/ after examining a s
skills/audit/SKILL.md:21:If the analysis is the first step toward changing the code, use [plan-first](../plan-
skills/audit/SKILL.md:69:3. Ask whether they want to act on any finding now — if so, that work goes through [p
skills/bootstrap/SKILL.md:3:description: The first thing to run in any session — establishes the working agree
skills/plan-first/SKILL.md:2:name: plan-first
skills/sync-memory/SKILL.md:2:name: sync-memory
/usr/bin/grep: plugins/glab/agents/*.md: No such file or directory /usr/bin/grep: plugins/*/skills/*/SKILL.md: No such file or directory
```

P7 is the only check in this plan that catches a prefixed frontmatter name
such as `name: glab:reviewer`: `validate --strict`, `plugin list` and
`plugin details` all still pass with one. D4 therefore puts the same test into
`AGENTS.md` as a permanent gate.

**P8 — no path to a script in `~/.claude` remains; no `cp` install; the
install commands are there.**

<!-- check P8 -->
```bash
per_file '~/\.claude/(memory-sync|manager-bootstrap)\.sh'
/usr/bin/grep -c -E 'cp -a|Installed to' README.md
/usr/bin/grep -c -E 'claude plugin (marketplace add glab-services/skills|install (glab|memory-sync)@glab-services)$' README.md
per_file 'CLAUDE_PLUGIN_ROOT'
```

Finished:

```
0
3
plugins/glab/hooks/hooks.json 1
plugins/memory-sync/hooks/hooks.json 4
plugins/memory-sync/skills/sync-memory/SKILL.md 4
```

Today:

```
settings.example.json 5
skills/sync-memory/SKILL.md 3
2
0
```

**P9 — `CLAUDE.md`: the file is gone, the four references to it as payload
are gone, and the 17 "no `AGENTS.md` → read `CLAUDE.md`" fallback occurrences
outside that file are all still there.**

<!-- check P9 -->
```bash
test -e CLAUDE.md && echo present || echo absent
/usr/bin/grep -c 'CLAUDE\.md' README.md AGENTS.md
per_file 'CLAUDE\.md' | /usr/bin/grep -v -E '^(README|AGENTS|CLAUDE)\.md '
```

Finished:

```
absent
README.md:0
AGENTS.md:0
plugins/glab/agents/analyzer.md 1
plugins/glab/agents/committer.md 1
plugins/glab/agents/developer.md 1
plugins/glab/agents/integrator.md 1
plugins/glab/agents/reviewer.md 2
plugins/glab/commands/analyze.md 1
plugins/glab/commands/commit.md 1
plugins/glab/commands/develop.md 1
plugins/glab/commands/integrate.md 1
plugins/glab/commands/plan.md 1
plugins/glab/commands/review.md 1
plugins/glab/commands/ship.md 1
plugins/glab/scripts/manager-bootstrap.sh 4
plugins/glab/skills/bootstrap/SKILL.md 1
plugins/glab/skills/manager/SKILL.md 1
```

Today:

```
present
README.md:3
AGENTS.md:1
agents/analyzer.md 1
agents/committer.md 1
agents/developer.md 1
agents/integrator.md 1
agents/reviewer.md 2
commands/analyze.md 1
commands/commit.md 1
commands/develop.md 1
commands/integrate.md 1
commands/plan.md 1
commands/review.md 1
commands/ship.md 1
manager-bootstrap.sh 2
skills/bootstrap/SKILL.md 1
skills/manager/SKILL.md 1
```

Of the 18 fallback occurrences in findings list R11, 17 remain: 15 in the
agents, the commands and two skills, plus the hook script's own 2 (its comment
and item 1). The 18th was `CLAUDE.md:15` itself, deleted with the file. The
hook script's count rises from 2 to 4 because G3's comment names `CLAUDE.md`
twice more.

**P10 — every rule of the deleted `CLAUDE.md` is in the hook output, which is
valid JSON under the 10,000-character cap.**

| `CLAUDE.md` | Rule | Lands | Phrase checked |
|---|---|---|---|
| `:1-4` | load `bootstrap` first | hook item 2 (G4) | ``Load the `glab:bootstrap` skill first`` |
| `:6-8` | the irreducible minimum | header comment (G3) | `irreducible minimum` (in the file, not the output) |
| `:10-13` | `manager` and `security` every session; never green on an agent's word | hook item 2 and last paragraph (G4) | ``- `glab:manager` —``, ``- `glab:security` —``, `never reported green on an agent's word` |
| `:14-15` | read `AGENTS.md`; none → `CLAUDE.md`, say so | hook item 1, unchanged | `If the repo has none, read` |
| `:16-18` | dispatched agents carry `security` and `comments`; Rule 0c | hook item 3 (G4) | ``carries the `glab:security` and `glab:comments` disciplines``, ``See `glab:manager` Rule 0c`` |
| `:19-26` | temp files go where `~/.claude/host.md` says; the fallback | hook item 4 (G4); also `glab:bootstrap` steps 1 and 6, unchanged | ``Temporary files go where `~/.claude/host.md` says``, `keep temp files few and small` |

<!-- check P10 -->
```bash
H=plugins/glab/scripts/manager-bootstrap.sh; [ -f "$H" ] || H=manager-bootstrap.sh
bash "$H" | jq -r '.hookSpecificOutput.hookEventName'; echo "jq rc=$?"
out=$(bash "$H" | jq -r '.hookSpecificOutput.additionalContext'); printf '%s' "$out" | wc -m
for p in 'Load the `glab:bootstrap` skill first' '- `glab:manager` —' '- `glab:security` —' "never reported green on an agent's word" 'If the repo has none, read' 'carries the `glab:security` and `glab:comments` disciplines' 'See `glab:manager` Rule 0c' 'Temporary files go where `~/.claude/host.md` says' 'keep temp files few and small'; do printf '%s ' "$(printf '%s' "$out" | /usr/bin/grep -c -F -- "$p")"; done; echo
/usr/bin/grep -c 'irreducible minimum' "$H"
```

Finished:

```
SessionStart
jq rc=0
2035
1 1 1 1 1 1 1 1 1 
1
```

Today:

```
SessionStart
jq rc=0
1294
0 0 0 1 1 0 0 0 0 
0
```

The last line but one is one count per phrase, in the order of the table; nine `1`s
is every rule present. The character count must stay under 10000. Not
covered: the script's plain-text fallback when `jq` is missing — that line is
not changed by this plan.

**P11 — the JSON files say what the plan says.**

<!-- check P11 -->
```bash
jq -r '.name, (.plugins[] | .name + " " + .source)' .claude-plugin/marketplace.json 2>&1
jq -r '.name + " " + .version' plugins/glab/.claude-plugin/plugin.json plugins/memory-sync/.claude-plugin/plugin.json 2>&1
jq -r '.hooks | to_entries[] | .key as $e | .value[].hooks[] | $e + " " + (.timeout|tostring) + " " + .command' plugins/glab/hooks/hooks.json plugins/memory-sync/hooks/hooks.json 2>&1
jq -c '[keys, (.env | keys)]' plugins/memory-sync/settings.example.json 2>&1
/usr/bin/grep -c user_config plugins/*/hooks/hooks.json 2>&1
jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json 2>/dev/null | while read -r n s; do echo "$n = $(jq -r .name "$s/.claude-plugin/plugin.json" 2>&1)"; done
```

Finished:

```
glab-services
glab ./plugins/glab
memory-sync ./plugins/memory-sync
glab 0.1.0
memory-sync 0.1.0
SessionStart 5 "${CLAUDE_PLUGIN_ROOT}"/scripts/manager-bootstrap.sh
SessionStart 20 "${CLAUDE_PLUGIN_ROOT}"/scripts/memory-sync.sh pull
SessionEnd 20 "${CLAUDE_PLUGIN_ROOT}"/scripts/memory-sync.sh push
PostToolUse 20 "${CLAUDE_PLUGIN_ROOT}"/scripts/memory-sync.sh push-if-changed
Stop 20 "${CLAUDE_PLUGIN_ROOT}"/scripts/memory-sync.sh push-if-changed
[["env"],["AWS_PROFILE","CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS","CLAUDE_MEMORY_S3_ARGS","CLAUDE_MEMORY_S3_URI"]]
plugins/glab/hooks/hooks.json:0
plugins/memory-sync/hooks/hooks.json:0
glab = glab
memory-sync = memory-sync
```

Today:

```
jq: error: Could not open file .claude-plugin/marketplace.json: No such file or directory
jq: error: Could not open file plugins/glab/.claude-plugin/plugin.json: No such file or directory
jq: error: Could not open file plugins/memory-sync/.claude-plugin/plugin.json: No such file or directory
jq: error: Could not open file plugins/glab/hooks/hooks.json: No such file or directory
jq: error: Could not open file plugins/memory-sync/hooks/hooks.json: No such file or directory
jq: error: Could not open file plugins/memory-sync/settings.example.json: No such file or directory
/usr/bin/grep: plugins/*/hooks/hooks.json: No such file or directory
```

Every hook command starts with `"${CLAUDE_PLUGIN_ROOT}"` in double quotes. The
last two lines compare each marketplace entry with the `plugin.json` its
`source` points at: `validate --strict .` passes with a wrong entry name and
with a source directory that does not exist, so this is the only check of
that link.

**P12 — the relative links in the audit skill still resolve; no real value
is anywhere.**

<!-- check P12 -->
```bash
test -f plugins/glab/skills/audit/../plan-first/SKILL.md && echo link-ok || echo link-broken
for f in $(files); do [ -f "$f" ] && /usr/bin/grep -h -o -E 's3://[^ "`/]*' "$f"; done | LC_ALL=C sort -u
```

Finished:

```
link-ok
s3://<bucket>
s3://my-bucket
s3://stub
```

Today:

```
link-broken
s3://<bucket>
s3://my-bucket
s3://stub
```

The second part is **non-discriminating** on purpose: it must print the same
three example values before and after — the placeholder, the example in the
script header, and the test's stub. Anything else is a real value and a
blocker.

**P13 — the script's code and the test are untouched.**

<!-- check P13 -->
```bash
git diff -M HEAD -- memory-sync.sh plugins/memory-sync/scripts/memory-sync.sh | /usr/bin/grep -E '^[+-][^+-]' | /usr/bin/grep -v -c -E '^[+-]#'
git diff -M HEAD -- memory-sync.sh plugins/memory-sync/scripts/memory-sync.sh | /usr/bin/grep -c -E '^[+-]#'
git diff HEAD --stat -- tests | wc -l
```

Finished — changed lines that are not comments, changed comment lines (S8;
its first line is unchanged), changed test files:

```
0
7
0
```

Today:

```
0
0
0
```

The first and third are **non-discriminating**: they guard the hook contract,
they do not show progress. The second does.

**P14 — `AGENTS.md` and `host.example.md` say the new things and name no old
path.** The first command counts lines of `AGENTS.md` that still name a
payload file at its old place. The second prints one count per new passage:
D3, D4 (seven: the strict validation, the guarded config directory, the
entry comparison, the frontmatter test, and three expected component lines),
D5, D6 (two), D7 (two), then D9 in `host.example.md`.

<!-- check P14 -->
```bash
/usr/bin/grep -c -E '(^| |`)(agents|commands|skills)/[a-z-]+(/SKILL)?\.md|(^| )(memory-sync|manager-bootstrap)\.sh|settings\.example\.json`\)?,' AGENTS.md
for p in '## Layout' 'plugin validate --strict' '${TMPDIR:?}/claude-config' '$n = $(jq -r .name' "'^name: .*:' plugins" '`Skills (14)` naming the six skills and the eight commands, `Agents (5)`, and `Hooks (1)  SessionStart`' '`Skills (1)  sync-memory`, `Agents (0)`, and `Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop`' 'test -x "$s"' 'no agent installs a' 'the marketplace and' 'its component counts and its hook events' "raises that plugin's" 'by its prefixed name'; do printf '%s ' "$(/usr/bin/grep -c -F -- "$p" AGENTS.md)"; done; /usr/bin/grep -c -F '<path to the claude binary on this host>' host.example.md
```

Finished:

```
0
1 1 1 1 1 1 1 1 1 1 1 1 1 1
```

Today:

```
7
0 0 0 0 0 0 0 0 0 0 0 0 0 0
```

**P15 — the README carries every number and every required paragraph.** One
count per fixed string, in this order: the default limit, the 3 seconds, the
maximum 17, the 20-second hook timeout, the 1.5-second budget, the "not yet
confirmed" hedge, the `AWS_PROFILE` warning, the hand-run delete, macOS, the
host-file step, read access, the credential, the HTTPS switch, the token
sentence, auto-update off, the folder-trust sentence, the shared lock, the
repo-root warning. Then the rollout block, parsed.

<!-- check P15 -->
```bash
for p in 'defaults to 12 seconds' 'up to 3 seconds longer' 'The largest value accepted is 17, because 17 + 3 seconds' '20-second hook timeout' 'share a 1.5-second budget' 'is not yet confirmed' 'sets the profile for every' 'is run by hand, never from a' 'macOS is not supported' 'Create `~/.claude/host.md` from `host.example.md` first' 'read access to `glab-services/skills` on GitHub' 'run `gh auth login`, then `gh auth setup-git`' 'CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1' 'does not authenticate it by itself' 'Background auto-update is off for this marketplace' 'trusted the folder' 'share one lock' 'Do not pass the repo root'; do printf '%s ' "$(/usr/bin/grep -c -F -- "$p" README.md)"; done; echo
awk '/^```json$/{f=1;next} /^```$/{f=0} f' README.md | jq -c . 2>&1
```

Finished:

```
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
{"extraKnownMarketplaces":{"glab-services":{"source":{"source":"github","repo":"glab-services/skills"}}},"enabledPlugins":{"glab@glab-services":true,"memory-sync@glab-services":true}}
```

Today:

```
1 1 1 1 1 0 1 1 1 1 0 0 0 0 0 0 0 0 
```

**P16 — no agent name carries the prefix outside the three places the naming
rule allows.** Every `glab:<agent>` is printed with what follows it, and the
ones followed by a backtick, `**` or " agent(s)" are dropped; what is left is
counted.

<!-- check P16 -->
```bash
for f in $(files); do [ -f "$f" ] && /usr/bin/grep -o -H -E "glab:($AG)(\`|\*\*| agents?)?" "$f"; done | /usr/bin/grep -v -c -E "(\`|\*\*| agents?)\$"
for f in $(files); do [ -f "$f" ] && /usr/bin/grep -o -h -E "glab:($AG)(\`|\*\*| agents?)?" "$f"; done | wc -l
```

Finished:

```
0
24
```

Today:

```
0
0
```

The first number is **non-discriminating** for progress — it is `0` before and
after — and exists to fail on a role noun that was prefixed in prose ("the
glab:reviewer looked at"). The second number shows the pattern has something
to look at.

**P17 — the 20 Markdown files of `glab` differ from the committed ones by the
prefix and by nothing else.** Each built file, with every `glab:` removed, is
compared byte for byte with the file at `2aeb46d`. This is what guards the
text the plan must not change — the review cap of 3, the manager's test rules,
every hazard in `bootstrap` — and what proves no rename rewrote the wrong
thing.

<!-- check P17 -->
```bash
n=0; for f in $(git ls-files -co --exclude-standard -- 'plugins/glab/*.md'); do if sed 's/glab://g' "$f" | cmp -s - <(git show "2aeb46d:${f#plugins/glab/}" 2>/dev/null); then n=$((n + 1)); else echo "DIFFERS $f"; fi; done; echo "$n identical"
```

Finished:

```
20 identical
```

Today:

```
0 identical
```

## Gates

**V1 — the repo's gates, at the new paths** (as D4 writes them).

<!-- check V1 -->
```bash
for s in plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; do bash -n "$s"; echo "$s rc=$?"; done
shellcheck plugins/memory-sync/scripts/memory-sync.sh plugins/glab/scripts/manager-bootstrap.sh tests/memory-sync.test.sh; echo "rc=$?"
bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh | tail -n 1
```

Finished:

```
plugins/memory-sync/scripts/memory-sync.sh rc=0
plugins/glab/scripts/manager-bootstrap.sh rc=0
tests/memory-sync.test.sh rc=0
rc=0
PASS 35/35
```

Today:

```
bash: plugins/memory-sync/scripts/memory-sync.sh: No such file or directory
plugins/memory-sync/scripts/memory-sync.sh rc=127
bash: plugins/glab/scripts/manager-bootstrap.sh: No such file or directory
plugins/glab/scripts/manager-bootstrap.sh rc=127
tests/memory-sync.test.sh rc=0
plugins/memory-sync/scripts/memory-sync.sh: plugins/memory-sync/scripts/memory-sync.sh: openBinaryFile: does not exist (No such file or directory)
plugins/glab/scripts/manager-bootstrap.sh: plugins/glab/scripts/manager-bootstrap.sh: openBinaryFile: does not exist (No such file or directory)
rc=2
usage: memory-sync.test.sh <path to memory-sync.sh>
```

**V2 — strict validation of each plugin and of the marketplace.**

<!-- check V2 -->
```bash
for p in plugins/glab plugins/memory-sync .; do "$CLAUDE" plugin validate --strict "$p" >/dev/null 2>&1; echo "$p rc=$?"; "$CLAUDE" plugin validate --strict "$p" 2>&1 | sed -n -e '1s/:.*//p' -e '$p'; done
```

Finished:

```
plugins/glab rc=0
Validating plugin manifest
✔ Validation passed
plugins/memory-sync rc=0
Validating plugin manifest
✔ Validation passed
. rc=0
Validating marketplace manifest
✔ Validation passed
```

Today:

```
plugins/glab rc=1
Validating plugin manifest
✘ Validation failed
plugins/memory-sync rc=1
Validating plugin manifest
✘ Validation failed
. rc=0
Validating components in
✔ Validation passed
```

**V3 — the components load, by name.** The agent list is sorted here because
the CLI prints it in no fixed order.

<!-- check V3 -->
```bash
"$CLAUDE" --plugin-dir ./plugins plugin list 2>&1 | /usr/bin/grep -E '❯|Status|No plugins'
for n in glab memory-sync; do "$CLAUDE" --plugin-dir ./plugins plugin details "$n" 2>&1 | /usr/bin/grep -E '^  (Skills|Hooks) ' | sed 's/  (harness-only.*//'; "$CLAUDE" --plugin-dir ./plugins plugin details "$n" 2>&1 | sed -n 's/^  Agents ([0-9]*) *//p' | tr -d ' ' | tr ',' '\n' | sort | paste -sd, | sed 's/^/  Agents: /'; done
```

Finished:

```
  ❯ glab@inline
    Status: ✔ loaded
  ❯ memory-sync@inline
    Status: ✔ loaded
  Skills (14)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, plan-first, push, review, security, ship
  Hooks (1)  SessionStart
  Agents: analyzer,committer,developer,integrator,reviewer
  Skills (1)  sync-memory
  Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop
  Agents: 
```

Today:

```
  ❯ inline[0]: ✘ Path not found: <repo>/plugins (commands)
  Agents: 
  Agents: 
```

## Mutants — what catches a skipped step

The prototype was rebuilt with one step left out each time and the checks run
again.

| Step skipped | Later steps that then stop with "before occurs 0 times" or a failed command | Checks whose output differs from the finished tree |
|---|---|---|
| M1 | G5, G6, G8, G11–G14 | P1 P2 P3 P4 P6 P7 P9 P12 V3 |
| M2 | G5, G6, G8 | P1 P2 P3 P6 P7 P9 V3 |
| M3 | G5–G10 | P1 P2 P3 P4 P5 P6 P7 P9 V3 |
| M4 | G3, G4 | P1 P2 P3 P7 P9 P10 V1 |
| M5 | S4–S7 | P1 P2 P7 P8 V3 |
| M6 | S8 | P1 P2 P13 V1 |
| M7 | none | P1 P2 P8 |
| G1 | none | P1 P11 V2 V3 |
| G2 | none | P1 P8 P11 V3 |
| G3 | none | P7 P9 P10 |
| G4 | none | P3 P10 |
| G5 | none | P3 |
| G6 | none | P4 |
| G7 | none | P5 |
| G8 | none | P6 |
| G9, G10, G11, G12, G13, G14 (each alone) | none | P7 |
| G15 | none | P1 P3 P9 |
| S1 | none | P1 P11 V2 V3 |
| S2 | none | P1 P8 P11 V3 |
| S3 | none | P8 P11 |
| S4, S5, S6, S7 (each alone) | none | P8 |
| S8 | none | P13 |
| D1 | none | P1 P11 V2 |
| D2 | none | P3 P4 P6 P8 P9 |
| D3 | none | P9 P14 |
| D4, D5, D9 (each alone) | none | P14 |
| D6 | none | P3 P14 |
| D7 | none | P3 P4 P6 P14 |
| D8 | none | P3 |

All 39 steps were skipped one at a time; every one is caught by at least one
check. Two things the run showed and the plan was changed for: skipping D4 was
first caught by **nothing**, which is why P14 exists; and M2 and M3 first
depended on M1 having made `plugins/glab/`, so each now makes it itself.
Steps caught by one check only (G5–G14, S4–S8, D4, D5, D8, D9) have no second
net: for those the named check is the whole proof.

### Mutants for the checks added in the amendment

After the analysis round, checks were added or extended (P1, P2, P11, P14 and
the new P15–P17, plus the permanent gates D4 writes into `AGENTS.md`). Each
was shown failing on a tree built from this plan and then damaged in one way.

| Damage done to a finished tree | Checks whose output changes | The `AGENTS.md` gate block (D4), run as written |
|---|---|---|
| `chmod 644` on both hook scripts | P2 (`NOT executable` twice) | both script lines print `rc=1` |
| README: "17" changed to "18" | P15 | — |
| README: the `SessionEnd` paragraph deleted | P15 | — |
| README: the "read access" line deleted | P15 | — |
| README: one `enabledPlugins` line deleted from the rollout block | P15 (the parsed JSON) | — |
| a frontmatter `name: glab:reviewer` | P7, P16 — V2 and V3 do not change | the last command prints `plugins/glab/agents/reviewer.md:name: glab:reviewer` and `rc=0` |
| a role noun prefixed in prose ("the glab:reviewer looked at") | P16 (`1`) | — |
| `skills/manager`: "(max 3 rounds)" changed to 4 | P17 (`DIFFERS …/manager/SKILL.md`, `19 identical`) | — |
| a wrong rewrite: `/glab:plan` turned into `/glab:plans` | P6, P17 | — |
| marketplace entry name `glab` changed to `glabx` | P11 — V2 does not change | `glabx = glab` |
| marketplace `source` pointed at a missing directory | P11 — V2 does not change | `memory-sync = ` |
| `AGENTS.md`: `Skills (14)` changed to `Skills (13)` | P14 | — |
| `AGENTS.md`: `${TMPDIR:?}` weakened to `$TMPDIR` | P14 | — |
| an empty `skills/` directory left behind | P1 (`1`) | — |
| a `${user_config.x}` in a hook command | P11 — V2 does not change | `plugins/memory-sync/hooks/hooks.json:1` |

Also run, on the finished tree: the gate block with `TMPDIR` set made one
config directory, used it for all five `claude` calls and removed it; with
`TMPDIR` unset it started **no** `claude` call and stopped at
`TMPDIR: parameter null or not set`.

The 39 single-step mutants of the table above were not all re-run after the
amendment; the steps they skip are unchanged except M5 (which gained
`rmdir skills`), S4, S6, S8, D2, D4 and D6, whose text changed. A fresh build
from this file applies all 39 steps and reproduces every recorded value.

## Smoke test — RUN BY THE USER, UNVERIFIED until then

Nothing above starts a session, so nothing above proves these. They need a
terminal where `claude` runs. None of it installs or enables anything:
`--plugin-dir` loads a plugin for that one session only.

**Expect everything twice in part 1 if it is run against the live
`~/.claude`.** The old copies are still installed there, so `plan` and
`glab:plan`, `developer` and `glab:developer` both exist, and the bootstrap
text is injected twice — once by the old hook (bare names, three items) and
once by the plugin (`glab:` names, four items). That is the old setup and the
plugin side by side, not a fault. It also means the *bare-name* questions
cannot be answered there; they need the clean config directory below.

**Part 1 — `glab` only.** Loading only this plugin keeps the test away from
the S3 backend.

```bash
cd <this repo>
claude --plugin-dir ./plugins/glab
```

| # | Do | Pass |
|---|---|---|
| 1 | type `/glab:` | 14 entries: the 8 commands and the 6 skills; `/glab:plan` among them |
| 2 | `/plugin`, Installed tab | `glab@inline`, loaded, no row under Errors |
| 3 | ask: "Quote item 4 of the session bootstrap text you were given." | the `~/.claude/host.md` sentence, with `glab:bootstrap` in it |
| 4 | ask: "Load the glab:security skill and tell me its first heading." | the skill loads; the answer is "Security" |
| 5 | ask: "Dispatch the glab:developer agent with the task: reply with the single word ok." | an agent of type `glab:developer` runs and returns |
| 6 | run `/glab:plan say only which skill you would follow` | it names `glab:plan-first` |

**The clean config directory — made once, used for everything below.** It
needs a login; the login is stored inside it, so do not make a second one.
Print the path: the second terminal in part 3 needs it pasted in.

```bash
export CLAUDE_CONFIG_DIR="$(mktemp -d /data/tmp/claude/smoke-config.XXXXXX)"; echo "$CLAUDE_CONFIG_DIR"
claude --plugin-dir ./plugins/glab
```

In that session, the bare names: does bare `/plan` exist; does "load the
manager skill" resolve; does "dispatch the developer agent" resolve. Whatever
the answers, the plugin text uses the prefixed names and does not depend on
them — record them in `follow-ups.md`.

**Part 2 — `memory-sync`, with no bucket configured.** Same terminal, same
`CLAUDE_CONFIG_DIR`. That directory has no `env` block, so
`CLAUDE_MEMORY_S3_URI` is unset, and the script's state and the memories it
would sync are that directory's, not the real ones. Under the live `~/.claude`
the `env` block is applied by Claude Code itself, so a shell `env -u` does not
keep the hooks off the real backend.

```bash
echo "$CLAUDE_CONFIG_DIR"        # must print the smoke-config path, not nothing
env -u CLAUDE_MEMORY_S3_URI claude --debug --plugin-dir ./plugins/memory-sync
```

| # | Do | Pass | If not |
|---|---|---|---|
| 7 | in the session, in the Bash tool: `[ -n "$CLAUDE_MEMORY_S3_URI" ] && echo set \|\| echo unset` | `unset` | it says `set`: **close the terminal window, do not type `/exit`** — a clean exit runs the `SessionEnd` push against whatever that variable names |
| 8 | read the debug log under `$CLAUDE_CONFIG_DIR/debug/` | the `SessionStart` hook ran and printed `[memory-sync] CLAUDE_MEMORY_S3_URI is not set; skipping` | no such line: the plugin's hooks did not fire — check `/plugin` Errors |
| 9 | run `/memory-sync:sync-memory status` and ask: "Quote the script path from the first paragraph of the skill." | an absolute path ending in `/plugins/memory-sync/scripts/memory-sync.sh`, and that file exists | the path begins with `${`: the substitution does not happen. **Fail.** The skill's own fallback then applies — row 10 |
| 10 | only if row 9 failed: ask "Follow the skill's instruction for a path that was not filled in." | Claude runs the `find` the skill gives and either names a copy of the script or says none was found and stops (under `--plugin-dir` nothing is installed, so "none found" is the right answer here) | Claude runs the unfilled path as written: the fallback wording does not work — S4–S7 need another way to find the script, as a plan of its own |

**Part 3 — the `SessionEnd` budget (Q4).** Same config directory, a stub
`aws` that takes 5 seconds, never a real backend. Three runs; before each,
clear the log and the stamps.

```bash
S="$(mktemp -d /data/tmp/claude/smoke-stub.XXXXXX)"; export STUB_LOG="$S/log"
printf '%s\n' '#!/usr/bin/env bash' 'echo "START $(date +%T) $*" >>"$STUB_LOG"' 'sleep 5' 'echo "END $(date +%T)" >>"$STUB_LOG"' >"$S/aws"; chmod +x "$S/aws"
mkdir -p "$CLAUDE_CONFIG_DIR/projects/p1/memory"
echo "second terminal:  echo x >> $CLAUDE_CONFIG_DIR/projects/p1/memory/a.md"
reset_run() { : >"$STUB_LOG"; rm -f "$CLAUDE_CONFIG_DIR"/.memory-sync-pushed "$CLAUDE_CONFIG_DIR"/.memory-sync-pushed.next "$CLAUDE_CONFIG_DIR"/.memory-sync-failed; }
after_run() { tail -n 2 "$STUB_LOG"; ls -l --time-style=+%T "$CLAUDE_CONFIG_DIR"/.memory-sync-pushed* "$CLAUDE_CONFIG_DIR/projects/p1/memory/a.md" 2>&1; }
```

For each run: start the session with the command in the table; paste the
printed `echo x >> …` line into a second terminal (the path is already written
out in it); leave the session with `/exit`; run `after_run`.

| Run | Start with | What `after_run` shows |
|---|---|---|
| A — no override | `reset_run; PATH="$S:$PATH" CLAUDE_MEMORY_S3_URI=s3://stub/mem claude --plugin-dir ./plugins/memory-sync` | **cut**: the last line is a `START` with no `END` after it, `.memory-sync-pushed.next` exists, and `.memory-sync-pushed` is missing or older than `a.md`. **not cut**: `START` then `END` about 5 s later, no `.next`, `.memory-sync-pushed` newer than `a.md` |
| B — override in the shell | the same, with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=20000` in front of `claude` | the same two outcomes |
| C — override where the README puts it | first `printf '%s\n' '{"env":{"CLAUDE_MEMORY_S3_URI":"s3://stub/mem","CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS":"20000"}}' >"$CLAUDE_CONFIG_DIR/settings.json"`, then `reset_run; PATH="$S:$PATH" claude --plugin-dir ./plugins/memory-sync` | the same two outcomes |

A missing `END` alone is not enough to call a run cut — the stub may simply
not have been reached — which is why the stamp files are read as well.

Reading the three:

- A cut, C not cut — the docs hold and the README is right. Remove the
  "not yet confirmed" hedge (D2, S6, S8) in a follow-up.
- A cut, B not cut, C cut — the variable works only from the shell. The
  README's instruction is wrong: rewrite D2's paragraph and S3's key.
- A, B and C all cut — the variable does not help a plugin hook. The Q4
  fallback applies, as a plan of its own because the hook events are a "one
  fact, one value" item. It rewrites: **S2** (drop the `SessionEnd` entry),
  **S3** (drop the `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` key), **S6** and
  **S8** (the `SessionEnd` sentences), **D2** (the event table and the
  paragraph), **D4** (`Hooks (4)` becomes `Hooks (3)`), and the script
  header's "run at session end" line.
- A not cut — the 1.5-second budget does not apply as documented; record what
  happened and change nothing.

Afterwards: `echo "$S" "$CLAUDE_CONFIG_DIR"`, check both are under
`/data/tmp/claude`, then `rm -rf "$S" "$CLAUDE_CONFIG_DIR"`.

## Back-out

**Before the commit, per slice.** The developer stages nothing, so the index
holds exactly "the moves, unedited". That makes G, S and D separately
reversible; M is not, because the other three sit on top of it.

| Unit | Command | Leaves |
|---|---|---|
| G | `git restore --worktree -- plugins/glab && rm -r plugins/glab/.claude-plugin plugins/glab/hooks && git restore --source=HEAD --staged --worktree -- CLAUDE.md` | the moved glab files with their original text, the root `CLAUDE.md` back, no manifest and no hook. `--plugin-dir ./plugins` then loads `memory-sync` only: a folder of plugins loads only subfolders that have a manifest |
| S | `git restore --worktree -- plugins/memory-sync && rm -r plugins/memory-sync/.claude-plugin plugins/memory-sync/hooks` | the moved files, the full `settings.example.json`, no manifest, no hooks |
| D | `git restore --worktree -- README.md AGENTS.md host.example.md && rm -r .claude-plugin` | the old README and `AGENTS.md` — whose gates then name paths that no longer exist. Not a working tree on its own: redo D or back out everything |
| everything (includes M) | `git restore --source=HEAD --staged --worktree -- . && rm -r plugins .claude-plugin` | the tree at `2aeb46d`; `plan/` untouched |

Each `rm -r` names only directories this plan creates. Run
`git status --short` first and read it. All four were run on the prototype;
G left every glab file byte-identical to `2aeb46d` and `CLAUDE.md` restored;
S left the script and `settings.example.json` byte-identical; the last one
ended with `git status --short` printing only the `plan/` line, no diff
against HEAD, and `PASS 35/35` at the old path.

**After the commit.** Commit the whole change as **one** commit: the moves,
the manifests, the renames and the documents are one logical change, and no
subset of it leaves `AGENTS.md`'s gates and the tree agreeing. Back-out is
then `git revert <that commit>`, one unit. The units cannot be reverted
independently once committed, and this plan does not pretend otherwise.

**Nothing to migrate.** No state file, no format and no installed copy is
touched. The back-out has no data side.

## Adoption on the user's own machine — a note, not steps of this plan

Nothing in this plan touches `~/.claude`; three live sessions keep running on
the copied files. Switching a machine over is the user's step, later:

1. While the old copies and the plugins are both present, every skill, agent
   and command exists twice, the bootstrap text is injected twice, and every
   sync runs twice. The two syncs share one lock (Q5), so they queue or skip
   rather than race.
2. With no session in the middle of work: `claude plugin marketplace add
   glab-services/skills`, then install `glab@glab-services` and
   `memory-sync@glab-services`. The repository is private: the machine needs
   read access and a credential git can use without prompting — the README's
   `## Install` section says which, and that is the first thing to check if
   the add fails.
3. In `~/.claude/settings.json`: remove the four `memory-sync.sh` hook entries
   and the `manager-bootstrap.sh` entry; keep the `env` block; add
   `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` to it. The live `PostToolUse` and
   `Stop` timeouts were 60 s; the plugin ships 20.
4. Delete the old copies: `~/.claude/skills/` (the seven), `~/.claude/agents/`
   (the five), `~/.claude/commands/` (the eight),
   `~/.claude/manager-bootstrap.sh`, `~/.claude/memory-sync.sh`.
5. `~/.claude/CLAUDE.md`: its rules now arrive through the `glab` hook. Remove
   the copied text, or keep it knowing it names the skills without a prefix.
6. Keep `~/.claude/host.md` and the `.memory-sync-*` files.
7. Sessions already running keep what they loaded until they are restarted.

## UNVERIFIED — what this plan rests on without proof

- `UNVERIFIED: prefixed names resolve in a live session (/glab:plan, the Skill tool with glab:manager, the Agent tool with glab:developer) — needs a session; smoke test part 1.`
- `UNVERIFIED: the bootstrap hook fires from a plugin and its text reaches the model — needs a session; smoke test row 3. Proven only: the script prints valid JSON when run from the plugin path (P10).`
- `UNVERIFIED: ${CLAUDE_PLUGIN_ROOT} is substituted in the sync-memory skill body — documented, needs a session; smoke test row 9. The fallback the skill names (S4) is itself unverified: that an installed plugin's script lies under <config dir>/plugins is taken from the docs ("~/.claude/plugins/ holds what Claude Code has fetched and installed"), and row 10 tests only that the wording is followed.`
- `UNVERIFIED: everything the README says about credentials, SSH-then-HTTPS, CLAUDE_CODE_PLUGIN_PREFER_HTTPS, background auto-update and the extraKnownMarketplaces / enabledPlugins keys — it restates the docs pages named under D2; nothing was added, installed or rolled out (D4).`
- `UNVERIFIED: CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS raises the budget for a plugin's SessionEnd hook, and what a cut-off looks like — documented for the variable, not for plugin hooks; smoke test part 3, runs A–C. The README, the skill and the script comment say "not yet confirmed" for this reason.`
- `UNVERIFIED: "claude plugin marketplace add glab-services/skills" works for a teammate against the private repo — needs another machine's git credentials; D4 forbids trying it here.`
- `UNVERIFIED: the README's "claude plugin update glab@glab-services" delivers a raised version — the command exists in "plugin --help"; an update needs an install.`
