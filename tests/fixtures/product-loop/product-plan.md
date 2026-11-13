# Product plan — notes-app

## Business plan

`business-plan.md`, as the user gave it: "Notes is a note-taking app whose notes sync between devices through an API."

## Goals

- **P1** — notes sync between devices through one API.
- **P2** — a web client reads and edits notes.

## Projects

### notes-api

- Goal: P1. Scope: the sync API. Out of scope: any client.
- Product rules: `docs/product-rules/data-retention.md`, `docs/product-rules/api-versioning.md`.
- Seams: notes-web calls it, versioned as `api-versioning.md` says.

### notes-web

- Goal: P2. Scope: the web client. Out of scope: storage.
- Product rules: `docs/product-rules/api-versioning.md`.
- Seams: calls notes-api.

## Rules to add

- `data-retention.md` — how long request logs are kept.
- `api-versioning.md` — how the API is versioned.

## Decisions

- Two projects, not one: the client and the API ship on their own schedules.

## Questions

none
