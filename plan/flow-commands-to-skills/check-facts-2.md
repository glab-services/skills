# flow-commands-to-skills — fact check, round 2 of 2

Checked 2026-11-13 against the amended `plan.md` (*Decisions*, I1–I5, U1–U8, *Plan-check findings*) and the six steps files, each diffed against its `*.r1.md` (`steps-bootstrap.md` has no round-1 copy; its BS1 and H1 were in `steps-manager.r1.md` and `plan.r1.md`). HEAD `5a72155`, `2.1.310 (Claude Code)`. Read-only. This file is the only one written.

Sources:

- docs, fetched this session:
  - https://code.claude.com/docs/en/skills (all of it, in two reads)
  - https://code.claude.com/docs/en/sub-agents
- the CLI bundle `~/.local/share/claude/versions/2.1.310`, read with `grep -a -b` and `dd`. A minified bundle is evidence of this build only, not a documented contract;
- a throwaway copy, made with `git archive HEAD` into `$TMPDIR/fc2-copy.XXXXXX`, with these applied:
  - P1, verbatim;
  - PF0's `name: plan` and `argument-hint` lines;
  - AG0.6, the planner's `skills:` list `glab:plan`, `glab:security`.

Under a fresh `CLAUDE_CONFIG_DIR` (`$TMPDIR/fc2-cfg.XXXXXX`):

    ✔ Validation passed
    validate rc=0
    glab 0.12.0
      Skills (13)  analyze, audit, bootstrap, comments, commit, develop, integrate, manager, plan, push, review, security, ship
      Agents (7)  reviewer, integrator, developer, analyzer, committer, planner, plan-analyzer

Both directories were removed afterwards: `ls -d /data/tmp/claude/fc2-*` returned `No such file or directory`, `rc=2`.

## Findings

A row marked `holds` is a point the plan states correctly. Only gaps carry a `glab:audit` severity.

| id | severity | point | evidence | fix |
|---|---|---|---|---|
| F2-1 | holds | **F1 handled.** U4 now gives the exact debug-log check. FU1-2 names the exact-match form. | `plan.md` U4: "search the debug log: `Preloaded skill 'glab:security'` present, and `specified in frontmatter was not found` absent". In the 2.1.310 preload loop (offset ≈255269200) both strings are present verbatim: `` t(`[Agent: ${e.agentType}] Warning: Skill '${it}' specified in frontmatter was not found` `` and `` t(`[Agent: ${e.agentType}] Preloaded skill '${it}'`) ``. | None. |
| F2-2 | holds | **F7 handled.** I5 plus the decision on bare aliases. | skills: "The bare `/fancy` also invokes the skill unless another command already uses that name." The CLI registers a plugin skill with `unqualifiedName:e,aliases:[e]` (offset ≈249996000). | None. |
| F2-3 | holds | **F8 handled.** I1 cites the loading page. *Rejected boundaries* marks `Skills (22)` as never run. | `plan.md` I1 and *Rejected boundaries*, as quoted in the plan. | None. |
| F2-4 | holds | **F11 handled.** I3 counts the manager's re-invocations. U7 keeps them UNVERIFIED. | `plan.md` I3: "each stage skill it invokes with a new argument … appends that skill's full body again". | None. |
| F2-5 | holds | **I4/U8: a preloaded `glab:plan` sees `$ARGUMENTS` as the empty string.** It does not see the literal token, and no `ARGUMENTS:` line is appended. | **Docs:** silent. The sub-agents page says nothing about arguments to preloaded skills (fetch: "No sentence says whether arguments are passed to preloaded skills"). **CLI code:** the preload calls `dt.getPromptForCommand("",{…isSkillPreload:!0…})`. The file skill then calls `G1e(lo,go,…)` with `go=""`. `G1e` returns the text unchanged only `if(n===void 0\|\|n===null)`. With `""` it runs `e.replaceAll("$ARGUMENTS",()=>(Q=!0,w(n)))`, which gives the empty string. The append is guarded by `!Q&&r&&n`, which is false for `""` (offset ≈247650600). A typed `/glab:plan <task>` gets the task, per skills: "The `$ARGUMENTS` placeholder always expands to the full argument string as typed." PF1's sentence still reads correctly with the token empty. | None. U8 is right to stay UNVERIFIED: this is a code reading, not a run. |
| F2-6 | holds | **One skill can be both preloaded by an agent and typed by a person.** | skills: "By default, both you and Claude can invoke any skill. You can type `/skill-name` to invoke it directly". sub-agents: "You can't preload skills that set `disable-model-invocation: true`, since preloading draws from the same set of skills Claude can invoke". The only exclusion is that key, and PF0 sets neither it nor `user-invocable` (decision, F4). The throwaway run validates and lists `plan` among `Skills (13)` with the planner's list in place. | None. |
| F2-7 | holds | **`argument-hint` in a preloaded copy.** It is UI only, so it has no effect in the preload. `$ARGUMENTS` differs between the two copies, as F2-5 shows. | skills, `argument-hint` row: "Hint shown during autocomplete to indicate expected arguments." The CLI stores it as `argumentHint:pn.argumentHint` on the command object, and `getPromptForCommand` does not read it. | None. PF0 keeping it is correct for the typed path. |
| F2-8 | holds | **PF0's new description fits the listing.** | skills: "each entry's combined text is capped at 1,536 characters regardless of budget". `awk` on the PF0 `new` block gives 568 characters. | None. |
| F2-9 | low | **The planner can load `glab:plan` a second time.** AG0.6 keeps `Skill` in the planner's `tools`. The docs say preloading does not restrict access, and PF0's description says "Use for every non-trivial task". A planner that also calls the Skill tool on `glab:plan` (args differ from the preload's `""`) gets a second full copy, about 3.4k tokens (I3). I3 does not count this. | sub-agents, `skills` row: "Subagents can still invoke unlisted project, user, and plugin skills through the Skill tool". Same section: "This field controls which skills are preloaded, not which skills the subagent can access". skills, *Skill content lifecycle* (round 1, F11): when the rendered content differs, "Claude Code appends the full content again". PL1's "Follow the preloaded `glab:plan`" makes a reload unlikely, but it does not forbid one. | Optional. Extend PL1's new text: "it is already in your context; do not load it again through the Skill tool". Or add one clause to I3. No step depends on this. |
| F2-10 | low | **The skills gate (R2a) relies on the directory name. Claude Code resolves a plugin skill by its frontmatter `name`.** The gate prints `ok` for `skills/<entry>/SKILL.md`. Claude Code names the skill `<plugin>:<name:>`. Today the two agree, because every `name:` equals its directory (F7, PF0 `name: plan`). A later `name:` edit would leave the gate green and the preload missing. | skills: "In a plugin skill, the frontmatter `name` replaces the directory name in the last segment of the command". `steps-repo.md` R2a: `test -f "$r/skills/$s/SKILL.md"`. The same text is in `steps-repo.r1.md`, so the gap predates this round; the merge adds the planner's `glab:plan` entry under it. | Optional. In R2a, also require `` /usr/bin/grep -qx "name: $s" "$r/skills/$s/SKILL.md" ``. Or record in the new *One fact* entry that the gate assumes name equals directory. |

Other new or changed Claude Code claims, read in the diffs and needing no row:

- **M0.3: the manager invokes each stage skill through the Skill tool.** This is U2, covered by round 1's F6.
- **M0.5/M0.6: Stage 1 dispatches `glab:planner` with no skill in between.** No Claude Code behaviour beyond preloading.
- **H1 point 3, "the `glab` skills its role uses from its definition".** This is U4/U5.
- **BS1's `${CLAUDE_PLUGIN_ROOT}`.** Covered by round 1's F9.
- **The stage skills (S1–S8) put `$ARGUMENTS` inside backticks and prose.** It substitutes there too (`replaceAll`). The same holds in the current commands, `plugins/glab/commands/analyze.md:6`.
- **Substitution side effects.** No skill the agents preload, and no new block, contains `$<digit>`, `$ARGUMENTS[`, `` !` `` or `CLAUDE_SKILL_DIR`: a scan of every `SKILL.md`, every command and every `new`/`file` block found only the intended `$ARGUMENTS` and BS1's `${CLAUDE_PLUGIN_ROOT}`. So the preload's substitution pass (F2-5) changes nothing else.

Counts: critical 0, high 0, medium 0, low 2 (F2-9, F2-10), holds 8. Round 1's four lows are each handled as the plan says. No claim the plan rests on is false. The new merge behaviour, an empty `$ARGUMENTS` in the preload, a skill that is both typed and preloaded, and `argument-hint` as UI only, holds in the docs and in the 2.1.310 code.

BUILDABLE
