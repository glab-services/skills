# Product loop

How to try the product ⇄ project loop of `glab`, with no model or live. How the loop works: `docs/specs/product.md`.

## Try it

Without installing anything and without a model, from the repo root in a
shell where `TMPDIR` is set:

    PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh 2>"$TMPDIR/trace.txt"

It plays a made-up product with two projects through the whole loop under
`$TMPDIR` and prints one `ok` line per step; `$TMPDIR/trace.txt` holds the
trace — each scene, the role that acts in it, every `plan-gate.sh` command,
each refusal and the text of every brief, report, verdict and rule written.

Live, after installing `glab` at the version in
`plugins/glab/.claude-plugin/plugin.json`:

1. Make a store folder, or a clone, as above. Give a product repo an `AGENTS.md` with
   `glab-level: product` and `glab-shared-store: <path to the store folder or clone>`,
   and a project repo an `AGENTS.md` with the same store line.
2. Start the product session with the store among its directories:
   `claude --add-dir <store>`. Give it a business plan; approve the product
   plan it brings you; it writes the briefs and the rules to the store.
3. Start a project session in the project repo, with the start prompt, as
   `glab:product-manager` *Starting project sessions* says: the desktop
   app's session tool, `claude --bg` from the project repo, or by hand. That
   the prompt keeps a background session from pushing its repo is UNVERIFIED until
   LP4 has run.
4. The project session plans, has you approve, reports and waits; the product
   session audits the report and writes the verdict; on `ACCEPTED` the project
   session develops.

The live checks, each UNVERIFIED until run:

- **LP1** — in the product repo, and in a subfolder of it, the session-start
  text names `glab:product-manager`, and the session loads
  `glab:session-rules` with it.
- **LP2** — the product session uses only its manager's skills, also when
  many plugins crowd the skill listing.
- **LP3** — `${CLAUDE_PLUGIN_ROOT}` is replaced by the plugin's path in the
  product skills' commands.
- **LP4** — a project session starts and is reached on each host: the
  desktop app's session tool; `claude --bg` from the product session's Bash
  tool, reached by `SendMessage` and waited on with `notify_when_idle`; and by
  hand. The start prompt keeps a background session from pushing its repo.
- **LP5** — the product agents preload their `skills:`.
- **LP6** — with the store added by `--add-dir`, the product session writes a
  brief through `glab:product-planner` and a verdict through `plan-gate.sh`
  without a permission prompt for each write.
- **LP7** — two machines, one store repository: a report from one, the
  verdict from the other, and the develop gate passing on the first.
