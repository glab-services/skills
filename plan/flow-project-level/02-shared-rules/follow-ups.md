# Follow-ups — flow-project-level/02-shared-rules

- `docs/specs/workflow.md:117` lists "the skills of every level" without `glab:severity`. W15 added it to both managers. The spec is the record's (`../master.md` *Record*), not 02's.
- For the record: the hook now replaces a closed stdin with `/dev/null` (`{ : 3<&0; }`, because bash 5.3.9 treats `0<&0` as a no-op), and it keeps an id's trailing newline with a sentinel, so that id fails the match (B18, B19).
