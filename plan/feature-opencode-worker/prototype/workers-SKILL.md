---
name: workers
description: How the manager runs a glab:developer or glab:reviewer dispatch on an external model the user named — OpenCode Go today — through external-worker.sh, a sandboxed copy of the repo, and the same report contract as the internal agent. Use only when glab:manager Rule 5 has recorded an external choice for that role; never on your own initiative.
---

# Workers

`glab:manager` Rule 5 says which model a `glab:developer` or `glab:reviewer`
dispatch runs on. One of the choices the user can make there is an **external
worker**: a backend CLI and a model, such as `opencode opencode-go/kimi-k3`.
This skill is how you run that choice. Everything Rule 5 says still holds —
the user names it, you record it, you never switch on your own, and the
pipeline does not bend.

## When this applies

Only when the recorded `- model:` line for the role names a backend and a
model, in the user's own words. Today the one backend is `opencode`. No such
line → the role runs internally, as Rule 5 says. Never for any other role.

## Before the first external dispatch of a session

Check, once, and tell the user what is missing rather than working around it:

- `bwrap` and the backend CLI (`opencode`) are on `PATH`, and the user has
  stored an OpenCode Go key with `opencode auth login`. The script reads that
  key itself; never ask for it, never put it in a brief.
- `TMPDIR` names the temp directory the host file gives. The script refuses
  to run without it.
- Say once, in one line: the OpenCode console's **Use balance** switch must
  be off, or a Go limit spends paid balance instead of stopping — the script
  cannot see that switch.

## Dispatch

1. Write the brief to a new file under `$TMPDIR`. It is the dispatch message
   you would give the internal agent: for the developer the slug, the step
   ids, the file boundary and anything decided in conversation; for the
   reviewer the target and the round, and nothing else. The script adds the
   agent's contract, `glab:security`, `glab:comments`, the model's profile and
   the report template itself; do not paste them.
2. Run, from the repo root, in the background:

       "<this skill's base directory>/../../scripts/external-worker.sh" \
         --role developer --backend opencode --model opencode-go/kimi-k3 \
         --brief "$TMPDIR/<brief file>" --repo .

3. Announce it like any dispatch: `slug · develop · model opencode:opencode-go/kimi-k3 · round 1/4 · running`.

## Reading it back

The exit code decides. stderr carries one line, `external-worker: <CODE>: <reason>`.

| exit | code | what you do |
|---|---|---|
| 0 | OK | stdout is the report, then `out: <dir>`. Treat the report as the internal agent's. |
| 2 | USAGE | Your call was wrong. Fix it and run again; this is not the user's. |
| 3 | UNKNOWN BACKEND | Stop. Tell the user the backend has no adapter. |
| 4 | UNAVAILABLE | Stop. Tell the user what is missing: CLI, `bwrap`, sandbox, credential. |
| 5 | MODEL REFUSED | Stop. Tell the user; the line lists the models allowed. Allowing another is theirs. |
| 6 | TIMEOUT | Stop and report. |
| 7 | BACKEND ERROR | Stop and report the line verbatim: a Go limit arrives here. |
| 8 | MALFORMED REPORT | Not evidence. Run once more, same model, the brief naming the gaps from stderr. Malformed again → stop and tell the user. |
| 9 | SECRET IN OUTPUT | Stop. The worker wrote the key into its changes; nothing was kept. Tell the user. |

On 3–7 and 9 you never re-run the role on a Claude model or on another
external model yourself: either spends something the user did not choose.
Say what happened and wait.

**A developer's changes come back as a patch, not as edits.** On exit 0, read
`<dir>/changes.patch` with `git apply --stat` and check it against the plan's
file boundary. Inside it: `git apply --check <dir>/changes.patch`, then
`git apply <dir>/changes.patch`, from the repo root. Applying it unchanged is
taking delivery, not implementing; editing it is implementing, and Rule 1
forbids it. A patch that does not apply, or touches a path outside the
boundary, is not applied: report it. Then run the gates yourself, as for any
developer.

A reviewer's run leaves no patch; its tree was read-only.

Remove `<dir>` once you have read it. It holds the transcript, which is the
only copy of what the model saw and said.

## What the script guarantees, and what it does not

- The worker runs on a disposable copy: tracked files plus staged, unstaged
  and untracked changes. Ignored files — `.env` and the like — are never
  copied, so they are never sent. Everything in the copy may reach the
  model's provider.
- Its `.git` is read-only, so it cannot commit, stage, branch, tag, stash or
  change hooks or config. It has no `/home`, no other repository and no
  environment variable of yours.
- The network is open, because the backend needs its API. The worker can
  reach anything the host can reach without a credential.
- The OpenCode Go key is inside the sandbox, because the CLI needs it. It is
  redacted from the transcript and report, and a patch that contains it is
  refused.
