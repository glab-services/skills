# Brief — notes-api

## Goal

Notes sync between devices through one API (product goal P1).

## Scope

The sync API: store notes, serve them to every device, log requests.

## Out of scope

Any client.

## Product rules

- `docs/product-rules/data-retention.md`
- `docs/product-rules/api-versioning.md`

## Seams

notes-web calls this API.

## Acceptance

The plan keeps request logs no longer than `data-retention.md` allows, and versions every endpoint.
