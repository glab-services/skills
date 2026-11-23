---
name: comments
description: Code comments, kept minimal — comment only what the code cannot say, in one line, and never drop a TODO, FIXME, HACK, NOTE or XXX marker silently. Use when writing, editing or reviewing code.
---

# Comments

- **Code first.** Make names and structure say what happens. A comment is for what the code cannot say: a non-obvious reason, a magic value's source, a workaround's bug.
- **One line.** No comment blocks, no history, no restating the code, no commented-out code.
- **Exported symbols** get a one-line doc comment when the name alone leaves the contract unclear.
- **Keep them true.** Changing code under a comment updates or deletes the comment in the same edit.
- **Markers.** `TODO`, `FIXME`, `HACK`, `NOTE` and `XXX` stay where they are. Remove one only when its work is done, and name it in your report.
