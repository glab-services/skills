# Hazards from one Go and PostgreSQL project

Moved from `glab:bootstrap` step 6 in glab 0.15.0. The trap in each is general; the commands are that project's.

**A receiver name in a Go grep silently undercounts.** `func (rcv *Route)` and
`func (r *Route)` are the same method set; a pattern naming one finds a fraction
of the other. This produced three wrong counts in one workstream — 335 RPC
handlers that were 431, 462 gin handlers that were 547 — and each reached a plan
document as a measured fact. Match the receiver as `[a-zA-Z]*` — with a
star, not a plus, because **an anonymous receiver makes `+` return zero**, and a
silent zero is worse than a wrong number: all 109 `TableName` methods in that
same repo have anonymous receivers, so the obvious fix found none of them. When a
count is load-bearing, break it down by receiver and confirm the parts sum to the
whole.

**Never conclude from a truncated query.** A `psql | head -8` cut 16 constraint
rows to 6 and produced a confident "this column has no foreign key" that reached
a plan document as fact. It had five.

**A cached test result is not evidence.** `make gotest` reported green with
`(cached)` after a database major-version change — it had reused a result from
the old server. What the cache hides, and what `-count` does about it, is
`glab:security` Rule 4.

**A capped linter's per-file counts are not reproducible.** With a
`max-same-issues` cap, which files absorb a capped linter's findings varies
between runs on an unchanged tree — so a per-package or per-file comparison is
noise, while the **repo-wide total is stable**. Measured in one repo: three runs of one
command on one tree moved a package from 5 findings to 11 to 30 with the total
fixed at 717. Compare totals, and treat any per-file "delta 0" as luck until the
same run reproduces it.
