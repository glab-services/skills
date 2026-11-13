# Brief — notes-web

## Goal

A web client reads and edits notes (product goal P2).

## Scope

The web client, and the request log of its own server.

## Out of scope

Storage: notes-api holds the notes.

## Product rules

- `docs/product-rules/data-retention.md`
- `docs/product-rules/api-versioning.md`

## Seams

Calls notes-api under `/v1/`.

## Acceptance

The plan keeps request logs no longer than `data-retention.md` allows.
