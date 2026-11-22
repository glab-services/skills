# Working agreement

- This folder is the maintained source of the `glab-team` plugin; the
  repository's `AGENTS.md` governs and wins where the two differ.
- `plugins/glab-team/` at the repository root is this folder's build, committed with its `node_modules/`: never edit it. After a change to `plugin/`, `channel/*.mjs`, `shared/address.mjs` or `LICENSE`, raise the version in `plugin/.claude-plugin/plugin.json`, `plugin/package.json`, `plugin/package-lock.json` and `channel/version.mjs` and in the tests that assert it, remove `../../plugins/glab-team` and run `pnpm -s plugin:build` (npm registry and `claude` needed); the repository's gate G45 fails until the two agree.
- Naming is per tool: the messaging tool's skills are `messaging-*`
  (`/glab-team:messaging-*`), its MCP server is `messaging`
  (`plugin:glab-team:messaging`), its data is `<plugin data>/messaging`, its
  plugin options are `messaging_*` and its CLI is `glab-team-messaging`. The
  scope hook confines a team-message window to the `messaging` server's tools
  only (`OUR_PREFIX` and `OUR_SERVER` in `channel/scope-hook.mjs`): a later
  `glab-team` tool server, such as `telegram`, must revise those two constants
  to be allowed in a window.
- Use Node.js 24+ and pnpm. Read broker/README.md and channel/README.md before
  changing messaging behavior. Keep changes scoped and stop for review after
  each self-contained change.
- Messaging tools must not execute commands on another developer's machine or
  expose human-only resolve/reopen operations to agents.
- Agents must never send information from outside the project root or about
  the machine (OS, host, user, home, packages, processes, network, hardware,
  environment, credentials). The plugin enforces this as a constant
  (OUTBOUND_SCOPE, the team-message window); no option may weaken it.
- Use the existing Conventional Commit style: `feat(scope): ...`,
  `fix(scope): ...`, `test(scope): ...`, or `docs(scope): ...`. Keep review
  findings in separate commits with relevant regression coverage.
- Run the gates for the area changed: `pnpm broker:test` and
  `pnpm broker:smoke` for broker changes; `pnpm channel:test` and
  `pnpm channel:smoke` for channel changes. Run both sets when shared messaging
  behavior or workspace dependencies change. Check `git diff --check` too.
- Reproduce functional bugs before fixing them. Use real HTTP/stdio integration
  tests for delivery and lifecycle behavior. Documentation-only edits do not
  need new tests. Distinguish SDK smoke results from real Claude Code acceptance
  and record the exact scenario covered.
- Put test databases, tokens, configs, and diagnostic artifacts under `$TMPDIR`
  (never `/tmp`) or ignored `.tmp/`. Use unique names, stop spawned services,
  and remove what you create. Never commit real credentials or token files.
- Never print secrets: no tokens, `tokens.json` contents, `.env` values, or
  credentials in logs, error messages, test output, commit messages, or PR
  comments. Test a configuration value instead of echoing it.
