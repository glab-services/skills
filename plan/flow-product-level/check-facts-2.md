# Check: facts and intent, round 2 of 2 (the last) — flow-product-level

This is the read-only plan analyzer's check, written 2026-11-13, against `main` at `f3cfe85`. The `claude` on `PATH` here is `2.1.310`: `command -v claude` resolves to `~/.local/share/claude/versions/2.1.310`, and that folder holds only 2.1.304, 2.1.309 and 2.1.310. Every `claude` command ran under a new, empty `CLAUDE_CONFIG_DIR` in `$TMPDIR=/data/tmp/claude`, and every directory was removed afterwards. No session was started (no `--bg`, no `-p`, no interactive run) and nothing was installed.

I read in full: `AGENTS.md`, `master.md`, `plan.md`, `evidence.md`, `questions.md`, `steps-2-product.md`, `steps-3-project.md`, A3 of `steps-1b-scripts.md`, R4 and R5 of `steps-4-repo.md`, `check-facts.md`, and `plan/manager-flow-notes.md`. I compared each file with its `*.r1.md` copy. Severities follow `glab:audit`.

## Part A — facts

### A1. The round-1 F findings

| id | r1 severity | status now | evidence |
|---|---|---|---|
| F1–F3, F6, F10–F13, F15 | none | still holds | The amendment changes none of these. Hook output (F3): I extracted the A3 script and the A4 test with the plan's own `B` helper and ran them in a temp folder. Output: `PASS 13/13`, shellcheck `rc=0`. For `glab-level: product`, stdout keys are `["hookSpecificOutput"]` → `["additionalContext","hookEventName"]` and the text is 2394 bytes, well under 10,000. |
| F4 | low | **fixed** | A3 falls back to `git -C "$dir" rev-parse --show-toplevel` when the folder has no `AGENTS.md`, and test B13 passed in my run. Decision line 26 records it, and so does LP1. |
| F5 | low | **fixed** | A3's header says "The warning goes to stderr as well as into the text, for debugging only". |
| F7 | low (LP3) | **fixed** | `evidence.md` LP3 now reads "documented (F7), confirmed live here". |
| F8 | medium | **mostly fixed.** New facts below: F17, F19, F21. | P1 now gives `cd <project repo> && claude --bg --add-dir <store> "take the brief at …"` with three caveats: trust, worktree and permission prompts. CLI help (2.1.310) confirms the flag: "Prints the id that `claude attach`, `logs`, `stop` and `rm` take". https://code.claude.com/docs/en/agent-view: "`claude --bg`, the session starts in your working directory", and "Where no dialog can appear, such as in a script, the command exits with a `Workspace not trusted` error". |
| F9 | medium | **partly fixed.** P1 names one mechanism per host, but the CLI one is wrong (F17, F18). | P1 says: resume with `claude --resume <id> --bg "<message>"`. |
| F14 | medium | **fixed** | J2.8: `invoke no skill that is not on the list of your manager`. Both managers have an explicit *Your skills — this level only* list (P1, J3). Description prefixes are now only a hint (Decisions line 47). |
| F16 | none | still holds, recounted | Now `Skills (21)`, with `session-rules` added, and `Agents (9)`. These counts are the amendment's own, in `evidence.md` E18. I did not re-run the plugin gates on a build. |

### A2. Claude Code claims in new or changed text

| id | severity | claim (step) | evidence | fix |
|---|---|---|---|---|
| F17 | medium | P1 and Decision line 59: `claude --bg` "prints the session's id", and then `claude --resume <id> --bg "<message>"` resumes it with that id. | agent-view: "Claude prints the session's **short ID**", and "To continue an existing conversation in the background, **pass its full session ID** with `--resume`". The full ID is "the full session UUID" in `claude agents --json`. `--resume` given a name "always starts such a copy". CLI help: `attach <id|name>` takes "the short id that `claude --bg` prints". So the printed id works for `attach`, `logs` and `stop`, but it is not what `--resume` documents. | In P1, record the short id for `attach`. Take the full session id from `claude agents --json` for `--resume`. Or drop the resume path for messaging (F18). Add the case to LP4. |
| F18 | medium | P1, P7 and J5 say a project or product session "is resumed by a message" through "the host's tools where they reach it". In the CLI, the only such tool the plan names is `--resume … --bg`. | https://code.claude.com/docs/en/cross-session-messaging covers this. It needs "v2.1.224 or later". Messaging "is on with nothing to enable". Claude uses "`ListAgents`" and "`SendMessage`", which reach "Your other local sessions … including background sessions". `notify_when_idle` sends "one notice when that session next goes idle". On the other path, CLI help for `--bg --resume` says it "starts a copy and says so **when the session is already running**". A waiting background session stays running for about an hour (agent-view: idle sessions are stopped after "about an hour"). So a resume would usually fork the conversation. | In P1 *Starting project sessions* and *Waiting for reports*, and in J5, name the CLI mechanism. Start each project session with `--name <project>`, then message it with `SendMessage`. To wait for its report, use `notify_when_idle` from the product session. Keep `--resume <full id> --bg` only for a stopped session. Add the case to LP4. |
| F19 | medium | P1's worktree caveat says only that the session "may move into a git worktree … before it edits". | agent-view, *How file edits are isolated*: in a worktree Claude entered, "**Claude commits without asking, and pushes the branch when the repository has a remote**", and opens a "Draft pull request … when the task calls for it". It never pushes to "`main` or `master`". The page also says "Your git instructions take precedence: if the task, `CLAUDE.md`, or memory says you handle committing or pushing yourself, Claude leaves git to you". That instruction conflicts with `glab:session-rules` Rule 3, which requires "confirmation … before every push". A skill is not on the docs' precedence list. | State this caveat in P1, and in README R5 step 5. Have the start prompt itself say that commits and pushes follow `glab:manager` Stages 6–7 and that the push waits for the user. The docs name "the task" as a source that takes precedence. Add the case to LP4. |
| F20 | low | P1, desktop app: "start a session with its working folder set to the project repo". | The `start_session` tool (this desktop session) says a session in another folder is "Elsewhere ("fresh", user_asked only, **when the user named the place**): `cwd`". A fresh start also needs a `background` of "at least 80 characters". Its `wake_when_done` "continues you" once the started session "ends its turn", which is the wait P1 describes. `send_message` says "Prefer `SendMessage`", and also "It cannot deliver into a session an orchestrator dispatched". | In P1: the go-ahead for a batch names each project repo's folder. Use `wake_when_done` for the wait. Name `SendMessage` as the tool for messages. Keep the "cannot deliver" limit as UNVERIFIED in LP4. |
| F21 | low | P1: "a permission prompt — a write into the store, outside its repo, among them — stops it". | `--add-dir` makes the store one of the working directories. CLI help: "Additional directories to allow tool access to". Prompts come from the session's permission mode, which agent-view says starts "the way a new `claude` session in that directory would". `plan-gate.sh report` is a Bash command, which prompts in the default mode wherever it writes. No page documents `--bg` together with `--add-dir`, so that is UNVERIFIED. LP4 already lists it. | Reword the caveat: "any prompt the session's permission mode raises, such as the Bash call that writes the report". |
| F22 | low | J2 and J3: the boundary rule binds, and it sits in `glab:session-rules` *The level boundary*, the last section J2 adds. | https://code.claude.com/docs/en/skills: after compaction, Claude Code "re-attaches the most recent invocation of each skill … **keeping the first 5,000 tokens of each**", and "older skills can be dropped entirely". The text J2 moves is about 21 KB: `sed -n '10,90p'` gives 11507 bytes, plus 6788 for Rule 5, 961 for the round caps, and about 1.5 KB of handoff text. That is more than 5,000 tokens, so *The level boundary* and *The handoff line* fall past the cut. This is mitigated: `SessionStart` runs again on `compact` (F6), and the hook text carries "Use only the skills its *Your skills — this level only* names". | Put *The level boundary* right after *How to read these rules*. |
| F23 | low | `evidence.md` header and `check-repo.md:4` say the amendment ran on CLI `2.1.321` "from `command -v claude`". | On this host `command -v claude` gives 2.1.310, and no 2.1.321 is installed (see above). E18 itself quotes 2.1.310. | Correct the version, or say which binary was used. |
| F24 | none (holds) | J2 creates a new skill that every manager reads, `glab:session-rules`. | It is listed as `Skills (21) … session-rules …` (E18). The skills page documents no frontmatter or other way for one skill to load another. Loading it depends on text: the hook's point 2 (checked in my run of A3), `glab:bootstrap` step 2 (J9), and each manager's opening section (P1, J2.9). Today's `glab:manager` is loaded the same way. | Optionally, have LP1 also check that the session loaded `glab:session-rules`. |
| F25 | none (holds) | The boundary rests on each manager's explicit list (J2.8, P1, J3). | F14 holds: the listing "always contains every skill name". A manager's list is in its own text, read when the manager loads. For the product agents the boundary is hard, because they have no `Skill` tool (F11). For the main session it is text only. FU-P2 stays the hard option, and the `Skill(name)` syntax is documented (F15). | None. |

## Part B — intent

### B1. The round-1 I findings

| id | r1 severity | status now | evidence |
|---|---|---|---|
| I1, I4, I5, I7, I10, I14 | none | still holds | The amendment did not change these. |
| I2 | low | **fixed** | J8 adds acceptance item 8, `**A brief, quoted.**`, checked with `grep -cE '^- brief: …$'`. |
| I3 | medium | **fixed** | P2 requires the text `the product's gates` (a brief's `## Acceptance` plus its rule files). P6 and P9 hand the audit the product plan's `## Decisions`. P6 finds that plan by its `### <project>`. |
| I6 | low | **fixed** | P1 *The shared store* states the layout once. The other skills point to it (Decision line 28). |
| I8 | medium | **fixed** | The cap counts `REJECTED` verdicts since the project's last `ACCEPTED`, across every brief. At the cap the script refuses every verdict by `product-manager` (Decision line 39). T15, T16 and T26 test it. |
| I9 | medium | **partly fixed** | The user path holds. The product manager's path is now named per host, but its CLI resume and messaging are wrong or missing (F17, F18), and it misses the auto-push caveat (F19). |
| I11 | low | **fixed** | X2 shows the user the `PRODUCT_LOOP_SHOW=1` trace and keeps it out of the plan folder. Master final check 4 says the same. |
| I12 | high | **fixed** | The rules move into `glab:session-rules`, and P1 holds the post `N … 'glab:manager'`. The hook's last line now points at `glab:session-rules` Rules 1 and 0b, which I read in my run of A3. J9 rewrites `glab:bootstrap` steps 2 and 4 by level. |
| I13 | low | **fixed** | `questions.md` lines 24 and 46 carry the answers. B3 now greps `^- \*\*Answer:\*\* the user chose`. `plan.md` no longer has an *Open* section. |
| I15 | none | still holds; one addition (B3 below) | — |

### B2. The user's agreed items, point by point

| item | user's words | plan | status |
|---|---|---|---|
| The cap | "okay two is good"; notes: "2 rejections, then the decision goes to the user" | Two `REJECTED` since the last `ACCEPTED`, then only a verdict `by user` is written, with the user's words quoted. The known limit is stated: `by user` is an argument the calling session chooses (R12, FU-P5). | holds |
| The forced report | "must force managers to send back report of planing before go to development phase" | Stage 1c (J5) reports and freezes the plan. `glab:develop` runs `plan-gate.sh check` on every dispatch (J7). Acceptance item 8 requires the brief line (J8). | holds |
| The audit against gates, rules and decisions | "not conflicting with production gates rules decisions" | The audit reads the brief's `## Acceptance` and its rule files (the gates), the rules index, and the product plan's `## Decisions` (P6, P9). | holds |
| Accept or reject, with a reason | "accepted and rejected plan and small context or reason" | Both `ACCEPTED` and `REJECTED` carry a reason. `REFUSED: empty reason` (C8, P7). | holds |
| Started by the product manager or by the user | "product manager and or also me" | Both paths take the same `take the brief at …` sentence (P1). | the user's path holds. The product manager's path in the CLI needs F17–F19, and on the desktop F20. |
| "I want to see how these skills will work" | the request | A printed trace of the loop, shown to the user (X2), plus a live try-it guide (R5). | holds. The trace shows the scripts and the store files, with fixtures standing in for the agents (Decision line 65). The live guide covers the skills themselves. |

### B3. `glab:session-rules`: asked for, or added?

**Added by the plan, not asked for by the user.** The user's request is "finish product skills and wiring with project first". The plan's Decision line 49 calls the move FU-P1, pulled forward "because no other place keeps each rule once", in answer to I12. I12 offered it as one of two fixes. No user answer or `questions.md` entry covers it, and `master.md` does not name it.

**Does it serve "say it once"?** The rule is recorded in `docs/specs/workflow.md:133–136` and :1490 as "agent must receive the thing once and clear". The **once** half holds. Both managers act on Rules 0–3 and 5, and the product manager may not read `glab:manager`. So one shared owner beats two copies, and beats sending the product manager into the project manager.

The **clear** half holds only in part. The moved text keeps its project-level stage names: Stage 1b, *Pick the tier*, *What you never do*, `plan.md`. The product manager has to map each one through J2.2's reading rule ("it means the stage of the same role in the manager of your level … a rule about a stage that level does not have does not apply there"). That is a translation step for every product session.

The move also reaches past the project level's edges. Every project session now loads a third skill, and `glab:manager` loses about 21 KB of its rules. Master G3 says the project level "changes only at its edges". Behaviour is unchanged, because the text is moved word for word.

| id | severity | finding | fix |
|---|---|---|---|
| I16 | low | The plan pulls `glab:session-rules` forward on its own initiative. It reshapes `glab:manager` for every project user, but neither `master.md` (G3, *Record*) nor a question names it. | When asking for the plan's approval, tell the user about it in one line. Add a *Record* line under `workflow.md`: "the rules of every level moved to `glab:session-rules`". |
| I17 | low | The "clear" half of "say it once": the product level receives project-level stage names together with a translation rule. | Acceptable as written. Optionally, have `glab:product-manager` map its stages in one short table (P1b ↔ 1b; P6 ↔ 6–7), so the mapping is stated once rather than worked out each time. |

## Verdict

There are no `critical` or `high` findings. Round 1's high finding, I12, is fixed, and so are F4, F5, F7, F14, I2, I3, I6, I8, I11 and I13.

What remains are medium errors of fact in P1 and J5, the steps that start and reach project sessions in the CLI. F17: `--resume` takes the full session id, not the short id `--bg` prints. F18: CLI cross-session messaging exists, and resuming a running session forks it. F19: a worktree-isolated background session commits and pushes its branch without asking. These leave G6's product-manager path partly wrong as written. Each fix is text in P1, J5 and R5, plus LP4 cases. Nothing in the scripts or tests changes.

NOT BUILDABLE
