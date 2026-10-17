# Questions, revision 3 — feature-opencode-worker

Q1 (rev 2, the model allowlist) is answered and binding: option A.

## Q2 — may an external model's review gate a commit?

**Why it is yours (Rule 3: changes what the product is).** Rev 2 let you name
an external **reviewer** for `glab:reviewer`, and its verdict then counted the
way a Claude reviewer's does: in Stage 5, in `/glab:review`, and in
`/glab:ship`, where a `SHIP` leads straight to a commit. Your new direction
drops the external developer and makes external agents a read-only tool; it
does not say whether the reviewer wiring stays. `plan-r3.md` is written on
option A and marks D34 pending until you answer.

What does not change either way: an external agent never changes a file;
nothing runs on one unless you name the model; the reviewer's report is
checked by the script against the reviewer's own verdict set (exit 8 when it
is malformed); and you can always ask the manager for an external review as
an extra opinion (Rule 6).

**Options**

- **A — recommended: keep it.** When you say "review on OpenCode, <model>",
  each review round of Stage 5, `/glab:review` and `/glab:ship` runs as a new
  read-only external agent with the reviewer's contract; its report is the
  round's report. *Consequence:* that model's `SHIP` can lead to a commit
  through `/glab:ship`, as a Claude reviewer's does — the manager still runs
  the gates itself and the push still waits for you. A model that fills the
  template without reviewing well lets through what a stronger reviewer
  would block; the round caps do not change. Review work moves off your
  Claude plan.
- **B — drop it.** External agents are only Rule 6's tool; their reviews are
  advice the manager shows you, and every Stage 5, `/glab:review` and
  `/glab:ship` round runs on `glab:reviewer`. *Consequence:* no external
  verdict ever gates a commit; reviews stay on your Claude plan. The plan
  loses B1–B8, B10, B11 and B13–B16 (Rule 5's external-reviewer bullets, the
  stage and command wiring) and the C6 cases for the record line, the token
  and the `send` correction; `--role reviewer` stays, as framing for an
  advisory review.

**Answer:** A — keep the external reviewer wiring. Given by the user at plan
approval on 2026-10-17, together with approval of `plan-r3.md`. D34 is
therefore decided on option A, as the plan is written.
