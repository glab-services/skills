tier: full — a new stored format, the request log.

# Plan — notes-api-v1

## Decisions

- Logs in one table, removed by a daily job.

### S1 — the request log

Keep request logs 365 days, then remove them in the daily job.

### S2 — the routes

Serve every endpoint under `/v1/`.
