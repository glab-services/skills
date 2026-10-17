---
name: workers
description: How the manager runs a glab:developer or glab:reviewer dispatch on an external worker the user named — a backend CLI and a model, OpenCode Go today — through external-worker.sh, on a sandboxed copy of the repo, with the same report contract as the internal agent. Use only when glab:manager Rule 5 has recorded an external choice for that role; never on your own initiative.
---

# Workers

`glab:manager` Rule 5 says which model a `glab:developer` or `glab:reviewer`
dispatch runs on. One choice the user can make there is an **external
worker**: a backend and a model, such as `opencode opencode-go/<id>`. This
skill is how you run that choice. Everything Rule 5 says still holds — the
user names it, you record it, you never switch on your own, and the pipeline
does not bend.

## When this applies

Only when the recorded `- model:` line for the role names a backend and a
model, in the user's own words. Today the one backend is `opencode`. No such
line → the role runs as the internal agent, as Rule 5 says. Never for any
other role.

## Before the first external dispatch of a session

Check once, and tell the user what is missing rather than working around it:

- `bwrap` (bubblewrap) and the backend's CLI (`opencode`) are on `PATH`, and
  the user has stored an OpenCode Go key with `opencode auth login`. The
  script reads that key itself: never ask for it, never put it in a brief.
- `TMPDIR` names the temp directory the host file gives. The script refuses
  to run without it.
- Say once, in one line: the OpenCode console's **Use balance** switch must be
  off, or a Go limit spends pay-as-you-go balance instead of stopping. The
  script cannot see that switch.

## Dispatch

1. Write the brief to a new file under `$TMPDIR`. It is the dispatch message
   you would give the internal agent — for the developer the slug, the step
   ids, the file boundary and anything decided in conversation; for the
   reviewer the target, the round and which round is the last, and nothing
   else. The reviewer's copy holds only `HEAD` and the working tree, so its
   target is the working tree or a path in it: a branch or range target
   cannot resolve there — tell the user instead of dispatching it. The script adds the agent's own file, `glab:security`,
   `glab:comments`, the model's profile and the report template itself: do not
   paste them, and do not write the brief in another style for the model —
   the profile does that.
2. Run it from the repo root, in the background:

       "<this skill's base directory>/../../scripts/external-worker.sh" \
         --role developer --backend opencode --model opencode-go/<id> \
         --brief "$TMPDIR/<brief file>" --repo .

3. Announce it like any dispatch, naming the choice as Rule 5 does:
   `slug · develop · model opencode:opencode-go/<id> · round 1/4 · running`.

## Reading it back

The exit code decides. stderr carries one line, `external-worker: <CODE>: <reason>`.
`<dir>` is taken from the **last** stdout line only, `out: <dir>`. Before you
read from it or remove it, check that it lies under `$TMPDIR` and that its
name starts with `external-worker.` — anything else, stop and tell the user.

| exit | code | what you do |
|---|---|---|
| 0 | OK | stdout is the report, then `out: <dir>`. Check it as Rule 5 says, and treat it as the internal agent's report. |
| 2 | USAGE | Your call was wrong. Fix it and run again; this is not the user's. |
| 3 | UNKNOWN BACKEND | Stop. Tell the user the backend has no adapter. |
| 4 | UNAVAILABLE | Stop. Tell the user what is missing: CLI, `bwrap`, a sandbox this host allows, or the credential. |
| 5 | MODEL REFUSED | Stop. Tell the user; the line lists the models allowed. Allowing another is theirs to decide, because it decides where their code goes. |
| 6 | TIMEOUT | Stop and report. |
| 7 | BACKEND ERROR | Stop and report the line as printed. A Go usage limit arrives here. |
| 8 | MALFORMED REPORT | Not evidence. Run once more, same role and model, with the gaps from stderr added to the brief. For a reviewer, keep the findings in the first run's `<dir>/report.txt` and show them with the second run's — none is dropped, and the second run is not a review round. Malformed again → stop and tell the user what is missing. |
| 9 | SECRET IN OUTPUT | Stop. The worker wrote the key into its changes; the patch was deleted. Tell the user. |
| 10 | BINARY IN PATCH | Stop. The worker's changes include a binary file, which cannot be read or scanned for the key; the patch was deleted. Tell the user. |

On 3–7, 9 and 10 never re-run the role on a Claude model or on another external
model yourself: either spends something the user did not choose. Say what
happened and wait. An external run cannot be resumed, so the one retry Rule 5
allows is the fresh run of exit 8, and it redoes the work on a fresh copy.

**A developer's work comes back as a patch, `<dir>/changes.patch`, not as
edits.** Inspect it with `git apply --stat` and `--summary`: it may touch the dispatch's file boundary plus `plan/{slug}/result.md` — when the work is not split, the files the plan's steps name plus `result.md`. Refuse a patch that adds a symlink
(`create mode 120000` in the summary) or changes a file mode (`mode change`)
unless a plan step names that. Then, from the repo root, `git apply --check
<dir>/changes.patch` and `git apply <dir>/changes.patch`. Applying it
unchanged after this inspection is taking delivery, not implementing; editing
it is implementing, which Rule 1 forbids. A patch that does not apply, or that
fails the inspection, is not applied: report it. Then run the gates yourself,
as for any developer. `result.md` arrives inside the patch.

A reviewer's run leaves no patch: its copy was read-only.

Remove `<dir>` once you have read what you need. It holds the transcript, the
only record of what the model saw and said.

## What the script guarantees, and what it does not

- The worker runs on a disposable copy: the tree of the real `HEAD` as one
  commit — no other branch, tag, remote-tracking ref or older commit — with
  the real tree's staged, unstaged and untracked changes. Ignored files —
  `.env` and the like — are never copied, so they are never sent. Everything
  in the copy may reach the model's provider.
- The copy's `.git` is read-only, so the worker cannot commit, stage, branch,
  tag, stash or change hooks or config. It sees no other home directory, no
  other repository and no environment variable of yours. It does see the
  host's `/usr` and `/etc`, read-only, because the CLI and the tools need them.
  Every file it writes is capped at 64 MiB, and its `/tmp` at 256 MiB. Those
  caps cover single files and the sandbox `/tmp` only, not every writable
  mount: the copy and its home are on disk under `TMPDIR`, bounded per file
  and not in total.
- The network is the host's, because the backend needs its API. The worker
  can reach anything the host reaches without a credential — services
  listening on 127.0.0.1 that trust local connections included. Do not run an
  external worker on a host whose local services hold sensitive data without
  authentication.
- The OpenCode Go key is inside the sandbox, because the CLI needs it. It is
  redacted from the transcript and the report, and a patch that contains it
  is refused — but only a literal copy in text is detected. An encoded copy is
  not, which is why a patch with a binary change is refused outright.
- Only the models in the script's allowlist run, each until the end date its
  line gives. The script prints the list when it refuses one.
