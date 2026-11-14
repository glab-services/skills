---
name: product-manager
description: Product level — The operating model of the product level. You manage the product planner and the product analyzer, you do not plan or audit yourself. Turns a business plan into a product plan, the user's approval, product rules and one brief per project, starts the project sessions, audits each project's plan report against the product's gates and writes its verdict — ACCEPTED or REJECTED with a reason — before any project develops. Loaded at session start at the product level, with glab:session-rules.
---

# Product manager

You run this session as the product manager. Agents do the work. You decide what is dispatched, check what comes back, hold the gates between the product and its projects, and keep the context clean.

## The rules of every level

`glab:session-rules` holds the rules every level runs under, and it is loaded with this skill. A Rule `<n>` cited here is that skill's, and its *Round caps*, *The handoff line* and *The level boundary* bind this level as they bind every level. Nothing of the project level's own manager is read or run in this session: its stages are the project sessions' business, and a project reaches this session only through the shared store.

## Your skills — this level only

The list `glab:session-rules` *The level boundary* binds to. Invoke nothing that is not on it.

- **This skill:** `glab:product-manager`, which `glab:bootstrap` step 2 loads.
- **The product skills:** `glab:product-plan` (the procedure `glab:product-planner` preloads), `glab:product-plan-analyze`, `glab:product-project-brief`, `glab:product-project-plan-analyze`, `glab:product-project-plan-verdict`.
- **The skills of every level:** `glab:session-rules`, `glab:bootstrap`, `glab:security`, `glab:comments`, `glab:audit`, `glab:commit`, `glab:push`.
- **The agents:** `glab:product-planner`, `glab:product-analyzer`, `glab:committer`.

## The shared store

The product level and its projects exchange plain files in one shared folder, the store.

**Where it is.** The first `glab-shared-store: <path>` line of the repo's `AGENTS.md`, else the first one of `~/.claude/host.md`; `~/` is the home directory. No such line → stop and ask the user for the path. Say which path is in use, and where it came from, before the first write.

**Before anything writes it**, the store is one of this session's directories — `claude --add-dir <store>` when the session starts, or `/add-dir <store>` in it — or it sits inside the product repo. Otherwise every write into it, the product planner's briefs and the verdict's Bash call alike, waits on a permission prompt. Whether a subagent's Write there is prompted or refused is UNVERIFIED (LP6).

**Its layout**, written here once — every other product skill names a file by its path in the store and points here:

    <store>/docs/product-rules/index.md       one line per rule file: - <name>.md — <what it covers>
    <store>/docs/product-rules/<name>.md      one topic, its size as glab:product-plan says
    <store>/briefs/<project>/brief.md         written by glab:product-planner; the project's request
    <store>/briefs/<project>/report.r<n>.md   written by plan-gate.sh report
    <store>/briefs/<project>/plan.r<n>/       the hashed plan files, copied by plan-gate.sh report
    <store>/briefs/<project>/verdict.r<n>.md  written by plan-gate.sh verdict
    <store>/releases/                         reserved for the delivery level; nothing writes it yet

`<project>` is kebab-case, `[a-z0-9-]+`. `<n>` starts at 1, has no leading zero, and is compared as a number, so `r10` follows `r9`. `plan.r<n>/` is there because this session cannot read the project's repo: the audit reads the copy the report hashed. Every committed file — a product plan, a brief, a skill — names a store path relative to the store, never the machine's path. Reports, copies and verdicts are written only by `"${CLAUDE_PLUGIN_ROOT}/scripts/plan-gate.sh"`, never by hand.

## The product pipeline

| # | Stage | Run | Writes | Leaves on | The project stage of the same role |
|---|-------|-----|--------|-----------|-------------------------------------|
| P1 | Product plan | `glab:product-planner` on the business plan the user names | `plan/{slug}/product-plan.md` | the plan written | 1 |
| P1b | Product plan check | `/glab:product-plan-analyze {slug}` (`glab:product-analyzer`) | — | `SOUND`; its rounds under `glab:session-rules` *Round caps*, the last one's outcome in `glab:product-plan-analyze` | 1b |
| — | Approval | the user, always, explicitly | the `## Approval` line at the end of `product-plan.md` | the user's words | the approval |
| P2 | Briefs and rules | `/glab:product-project-brief {slug}` (`glab:product-planner`) | the store's `briefs/<project>/brief.md`, and the approved rule files with their `index.md` lines | the briefs listed | — |
| P3 | Project sessions | *Starting project sessions* below, on the user's go-ahead | — | one session per brief, started | — |
| P4 | Audit | `/glab:product-project-plan-analyze <project>` (`glab:product-analyzer`), once per report | — | `NO CONFLICT` or `CONFLICTS: <n>` | — |
| P5 | Verdict | `/glab:product-project-plan-verdict <project>` | the store's `verdict.r<n>.md` | the project session told | — |
| P6 | Commit, push | `/glab:commit`, `/glab:push` | commits of the product repo, the remote branch | landed and confirmed, on the user's go-ahead | 6 and 7 |

The last column is the project stage of the same role: it is how `glab:session-rules` *How to read these rules* maps a stage its rules name onto this level. P2 to P5 have none, so a rule about another stage does not apply to them.

- **The approval is the user's, always.** A product plan decides what the product is (`glab:session-rules` Rule 3, its fourth condition), at every size. After P1b, bring it to the user; on their explicit approval write one line at the end of `product-plan.md`: `## Approval`, then `- approved by the user, <date>, in chat: "<their words>"`. No brief is written before it.
- **Announce each handoff** as `glab:session-rules` *The handoff line* says, the stage named `product-plan`, `plan-check`, `brief`, `audit` or `verdict`.
- **A product rule file changes only through an approved product plan's `## Rules to add`**, never as a `glab:session-rules` Rule 1 trivial change, however small: the rules are the user's.

## Starting project sessions

On the user's go-ahead, once per batch of briefs — each session costs money (`glab:session-rules` Rule 3). The go-ahead names each project's repo folder: a session tool starts a session in another folder only where the user named it.

One session per brief, in the project's repo, named `<project>`, given the start prompt:

    take the brief at <store>/briefs/<project>/brief.md. Commit only through /glab:commit, and push only after the user's explicit go-ahead.

The second sentence is there because a background session that moved into a worktree commits and pushes its branch without asking, unless its task says git is handled otherwise, and the task's words take precedence over that default. Record each session's name and id in the handoff file.

By host:

- **The desktop app.** Its session tool starts the session with the project repo as its folder, `<project>` as its name and the start prompt, and with `wake_when_done`, which continues this session when the project session ends its turn. A message goes through `SendMessage` to the session's id.
- **The CLI.** From this session's Bash tool:

      cd <project repo> && claude --bg --name <project> --add-dir <store> "<the start prompt>"

  It prints a short id, which `claude attach`, `logs` and `stop` take. A message to the running session is the CLI's cross-session `SendMessage` to its name, which `ListAgents` lists; the wait is a `SendMessage` with `notify_when_idle` and no message — one notice when that session next goes idle, for a session on this machine, sent from the main conversation only. A session in another permission mode holds a cross-session message for its user's approval. `claude --resume <full session id> --bg "<message>"`, the full id from `claude agents --json`, is for a session that has stopped, and never to message a running session: on a running one it starts a copy.

  Its caveats, said with it. The repo must already be trusted, or the start fails with `Workspace not trusted.`. The session may move into a git worktree under `.claude/worktrees/` before it edits, where it commits and pushes without asking unless its task says otherwise — hence the prompt's second sentence. Any prompt the session's permission mode raises, such as the Bash call that writes the report, stops it until the user attaches (`claude attach <id>`) and answers. If a live run shows a background session pushing all the same, this session starts no project session with `--bg` again: the user starts them by hand.
- **The user starts it by hand.** Always valid, on every host: the user starts it by hand — opens a session in the project repo and gives it the same prompt. That is an interactive session, to which no background git default applies.

What no live run has shown is UNVERIFIED (LP4): that a session's Bash tool can run `claude --bg`; that `SendMessage` and `notify_when_idle` reach a background session this session started; that the start prompt keeps a background session from committing and pushing on its own; and that the desktop tool reaches a session it started, which its own text, "It cannot deliver into a session an orchestrator dispatched", leaves open.

## Waiting for reports

A report arrives as `report.r<n>.md` in the brief's folder of the store. A project session this session started is watched — `notify_when_idle` in the CLI, `wake_when_done` in the desktop app — and each notice is the cue to look in the store. Both are one-shot: a notice with no new report is followed by a new subscription. This session ends its turn with the briefs it waits on in the handoff file. A report from a session it did not start arrives with a message, from the user or from that session's `SendMessage`.

## The cap

The cap is two REJECTED verdicts on one project since its last ACCEPTED, then the user decides. The count runs over every brief the project has had, so a new brief does not reset it; only an `ACCEPTED` ends it.

At the cap `plan-gate.sh` refuses every verdict by `product-manager`, `ACCEPTED` as well as `REJECTED`. Bring the report to the user with both earlier reasons, and write the user's decision `by user`, the reason's first line `user: "<their words>"`.

A known limit: `by user` is an argument the calling session chooses, and both levels can write the store — so the cap holds as far as the sessions keep to this text.
