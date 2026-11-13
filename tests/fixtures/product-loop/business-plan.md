# Business plan — Notes (a sample product)

A made-up product for the glab product-loop walkthrough; no real company owns it.

Notes is a note-taking app whose notes sync between devices through an API.

- **notes-api** — the sync API: stores notes and serves them to every device.
- **notes-web** — the web client: reads and edits notes through the API.

Constraint: request logs that can hold a user's notes are kept at most 90 days.
