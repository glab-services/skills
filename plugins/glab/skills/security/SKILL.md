---
name: security
description: Evidence and durability discipline for any substantive code change — how to prove a claim you make about your own work, and the rules that must not be broken in systems that hold real data. Use whenever writing, changing or deleting code, running commands, changing configuration or infrastructure, reporting a result, or claiming something is done or fixed. Applies by default on real engineering work, not only when asked.
---

# Security

Two halves. The first is how you prove a claim. The second is what you must not break. Most defects that reach production come from the first — not from a rule nobody knew, but from a claim nobody checked.

---

# Part 1 — Evidence

## Rule 1: never claim what you did not run

These phrases are banned unless the output that proves them is in your reply:

> "should work" · "this fixes it" · "now correct" · "tests pass" · "verified" · "no longer possible"

If you could not run it, write the claim in this exact form instead:

    UNVERIFIED: <the claim> — <why you could not check it>

`UNVERIFIED` is not a failure. Reporting it as verified is.

A reference to a named open test — `UNVERIFIED: L5` — is that form when the paragraph citing it states the why once.

## Rule 2: paste real output, not a description of it

Show the command and what it actually printed. Trim to the relevant lines; never paraphrase a result into prose. Summarising output you saw is fine. Summarising output you did not see is fabrication, and it is indistinguishable from the real thing to the person reading you — which is exactly why it destroys trust in everything else you reported.

## Rule 2b: the command must be able to fail for the reason you are claiming

Evidence is not any output. It is output that **would have looked different if your claim were false**.

`git diff --check` prints nothing when there are no whitespace errors. It also prints nothing when the change is completely wrong. So it supports exactly one claim — "no whitespace errors" — and no other, however confident the rest of the report sounds.

Two ways this goes wrong, both of which read as thorough:

- **A weak proxy.** You ran something, it passed, and it does not test what you asserted. State what the command actually proves, not what you wanted it to prove. If nothing you can run would distinguish your claim from its opposite, the claim is `inferred`, not `proven`.
- **Presence used to prove absence.** A search that finds three call sites proves those three exist. To claim something appears *nowhere else*, run the search that would have found a counterexample, show it returning nothing, and say what it searched. An absence claim backed by a positive result is the most common false "proven" there is.

## Rule 3: run the repo's own targets

Find them before you start: `Makefile`, `package.json` scripts, `justfile`, the CI config. Use those.

A command you composed yourself proves nothing about CI. Running `go test ./somepkg` when the repo's target is `go test ./... -race` is not the same check, and the difference is where the race lives.

## Rule 4: green means green

No failures. No skipped suite you meant to cover. No ignored race or warning. A cached result is not a run: `-count=1` defeats Go's test cache, and a test that fails only on its second run shows only under `-count=2`.

A test that was already red is only "pre-existing" once you have **proved** it: check out the merge base, run it there, paste that too. An unproven "pre-existing failure" is a guess, and it is the most common way a real regression gets waved through.

## Rule 5: never run a fix-mode linter or formatter

No `--fix`, `--write`, `-w`, or a target that wraps one.

Auto-fixers rewrite the whole tree rather than your diff, so their damage is inseparable from your change. They routinely emit code that does not compile — a call added without its import, an import left stranded when its last use goes — and they are frequently not idempotent, so one pass is not a fixed point.

Check whether the repo's lint target carries a fix flag before running it; if it does, run the underlying tool without that flag. Fix findings by hand and understand each one. That is the entire point of the gate.

## Rule 6: separate proven from inferred, always

Two labels, in every report:

- **Proven** — you executed it and read the output.
- **Inferred** — you reasoned it from the code, the types, or the name.

Inference is legitimate and often necessary. Presenting inference as observation is not. This one habit catches more errors than any checklist in Part 2, because it forces you to notice which of your beliefs you never actually tested.

## Rule 7: check the callers before you change behaviour

Before changing any existing function's signature, return values, error cases, or timing: grep every call site and state what each one relied on.

Reasoning about a function from its name and signature is not evidence. Neither is reading its body — the question is what its *callers* assume, and that is only visible at the call sites.

If you cannot enumerate the callers, say so and stop. A change whose blast radius you did not measure is not scoped, however small the diff looks.

## Rule 8: stay inside what was asked

An unrequested improvement bundled into a requested fix is unreviewed change riding on reviewed change. It is how regressions enter through the one commit everybody trusted.

Spotted something worth doing? Write it down as a follow-up and leave it. That includes: a better file layout, a richer API than asked for, a rename, an import regroup, a formatting sweep, blank lines left where deleted code was, a bug you noticed in passing. A plan that forbids a registry also forbids the registry's vocabulary.

---

# Part 2 — Durability

**When the change touches stored data, a schema, a serialized, file or wire format, a write path, a checksum, a retry, an encoding, a lock, a handle or concurrency, read `${CLAUDE_PLUGIN_ROOT}/skills/security/references/durability.md` first, and hold the change to it.** Otherwise it does not apply.

Two of its rules hold on every change:

- **Destructive operations are proven, not assumed.** Before any delete, overwrite, truncate, reset, drop or force, look at the target first: confirm it is what you think it is, and whether it is recoverable. Untracked files, dropped volumes, remote branch history and reset working trees are not recoverable. For those, stop and ask. Approval for one destructive action never carries to the next, except the standing approval of `glab:session-rules` Rule 2.
- **Secrets never enter output.** Keep them out of logs, error messages, commit messages, test fixtures, traces and printed URLs. Name a remote instead of printing its URL. Do not print config values at all; test them instead.

---

# The report

The final report of a stage that changed code ends with this: the developer's `result.md`, an integrator's `integration.md`. Other reports state their claims inline, proven or inferred, without the table. It is short on purpose, and its value is that a gap in it is visible.

    ## Claims
    | claim | proven / inferred | how |
    |---|---|---|
    | <what you assert is true> | proven | <command, and what it printed> |
    | <what you assert is true> | inferred | <from what code, and what would prove it> |

    ## Gates
    build: <command> -> <ok | red | UNVERIFIED: why>
    test:  <command> -> <ok | red | UNVERIFIED: why>
    lint:  <command> -> <ok | red | UNVERIFIED: why>

    ## Blast radius
    changed: <each function or format whose behaviour changed>
    callers: <who calls it, and what each relied on>
    data:    <what existing data or state this can affect, or "none">
    rollback: <how to undo it, or why it cannot be undone>

    ## Not done
    <what you did not check, what you left out of scope, what you are unsure of>

A row you cannot fill is the finding. Write `UNVERIFIED` and say why — never leave it blank, and never fill it with something you did not do.

**`proven` requires a command that actually ran, and that bears on that specific claim.** No command — or a command that would have printed the same thing had your claim been false — makes the row `inferred`, not `proven`.

A judgment about a document is **always** `inferred`: "the plan is clear", "the checklist is 5/5", "the questions are resolved", "the design is sound". No command reads a plan and returns *correct*. Say who judged it and against what.

And one command backs one claim. Reusing a single run to support several unrelated rows is the weak-proxy error wearing a different hat — if the same output appears next to a different claim in your next report, at most one of them was ever evidence.


# Stopping is a correct outcome

Stop and ask, rather than proceeding on an assumption, when:

- the change is destructive and you cannot establish that the target is recoverable;
- you cannot enumerate the callers of something you are about to change;
- the specification is ambiguous and one reading is unsafe;
- fixing the reported problem requires changing behaviour nobody asked you to change;
- you would have to write `UNVERIFIED` against the claim the whole task rests on.

Delivering nothing and saying why beats delivering something and implying it was checked.
