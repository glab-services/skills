---
name: comments
description: How to write and keep code comments — record why a thing is the way it is, including small details like a default value or an odd property, and never delete or rewrite TODO, FIXME, HACK, NOTE or XXX markers without approval. Use whenever writing, editing, refactoring or rewriting any file, and when reviewing a change that touches non-obvious logic.
---

# Comments

Two halves. Write the comments that carry knowledge. Never delete the ones already there.

---

# Part 1 — Write it down

## The default is not silence

Most style guidance says "don't write comments that restate the code." It is correct, and it gets over-applied into "don't write comments," which produces code that is readable line by line and inexplicable as a whole.

The bar is not *is this important enough to comment*. The bar is:

> **Would a reader six months from now know why this is the way it is?**

If not, write it down. That reader is usually the person who wrote it.

## Comment the decision, not the mechanism

A reader can already see *what* a line does. What they cannot see:

- why this approach and not the obvious one;
- what breaks if the order changes;
- which specification, ticket, or measurement produced this value;
- what was tried before and did not work;
- which bug a guard exists for;
- what a caller is allowed to assume, and what it must guarantee.

That is the comment. If the sentence you wrote restates the code, delete it and write the missing half instead.

```go
// Bad — restates the code.
// set retries to 3
retries := 3

// Good — carries the reason.
// 3: the gateway already retries twice internally, so this is the
// third and final attempt before the request is failed to the caller.
retries := 3
```

## Small things count most

A one-line property, a default, a magic number, an unusual type choice, a field that is deliberately not a pointer — these are exactly what gets forgotten. They were too small to write down at the time and too small to re-derive later, so the knowledge simply leaves.

**Size is not the trigger. Non-obviousness is.** A single field can carry more history than a whole function, and if it does, it gets the comment.

## Every exported symbol carries a doc comment

What it is for, what the caller must guarantee, and what it guarantees back. Not a restatement of its own name — `// UserStore stores users` tells a reader nothing they did not have.

Include the parts that are invisible from the signature: whether it is safe for concurrent use, whether it retains or copies what it is given, what it does on the empty or nil case, and which errors a caller is expected to handle rather than propagate.

## History belongs in the code, not only in git

"Changed to X because Y" survives a rename, a file move, and a refactor. `git blame` survives none of those reliably, and in practice nobody runs it before editing.

If a change encodes a lesson — a workaround for a real bug, a value that came from a measurement, a deliberate divergence from the obvious or from a specification — leave the lesson where the next person will be standing when they need it.

## What not to write

- Restatements: `// increment i`, `// return the result`.
- Anything the type already says.
- Commented-out code. Delete it; version control has it.
- Facts that go stale silently: a line number, a version, a date, a person's name, "see the function below."
- Ceremony headers on every function that say nothing. A comment nobody reads trains people not to read the ones that matter.

## Keep them true

A wrong comment is worse than no comment, because it is trusted and it is not tested. When you change code that sits under a comment, update the comment in the same edit or delete it. Never leave it describing the previous behaviour.

## In review

A diff that changes non-obvious logic and adds no comment is incomplete. Say so as a finding, and say what the missing comment should record.

---

# Part 2 — Never delete what is there

## Hard rule

**Never remove, rewrite, or replace `TODO`, `FIXME`, `HACK`, `NOTE`, `XXX`, or any similar historical-context comment without explicit approval.**

| Marker | Meaning |
|--------|---------|
| `TODO:` | Deferred implementation, planned future work |
| `FIXME:` | Known issue that needs correction |
| `HACK:` | Workaround carrying technical debt |
| `NOTE:` | Context for whoever reads this next |
| `XXX:` | Warning or caution marker |

These encode deferred decisions, known gaps, and planned work. They were placed deliberately. Removing them silently erases institutional memory and causes real work to be forgotten — the cost lands on someone else, months later, with no trace of what happened.

## When editing

- Read the existing comments before you change anything.
- A marker in code you are modifying stays exactly as it is.
- If your refactor makes a marker irrelevant, **flag it — do not delete it.** Whether it is genuinely resolved is not yours to decide alone.
- Rewriting a whole file means carrying every marker into the new version.

## When rewriting a file

1. `grep -n "TODO\|FIXME\|HACK\|NOTE\|XXX" <file>` on the original.
2. Carry every match into the new version, at the place it still applies.
3. If a marker's location no longer makes sense, ask where it should go.

## The one exception

A marker may be removed when the work it describes is genuinely done — and then you say so explicitly in your report, naming the marker and what closed it. Silence is what is forbidden, not deletion.
