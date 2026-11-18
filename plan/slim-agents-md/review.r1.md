FIX: 4 findings

1. /home/pvhv/projects/skills/tests/gates.sh:9-10, 34, 37 — medium. The comments say the work directory "is removed on every exit path", but the only trap is `trap 'rm -rf "${W:?}"' EXIT`, and bash does not run that trap when a signal kills it. I tested a copy of lines 15 and 36-37 with a `sleep` and sent it signals: `TERM rc=143 left=yes`, `INT rc=130 left=yes`, `HUP rc=129 left=yes`. So stopping the run partway (Ctrl-C, or an agent shell timeout during a run that takes minutes) leaves `$TMPDIR/gates.*/claude-config` behind. The old block did not clean up on signals either, so this is not a regression, but the new text claims it does. Fix: add `trap 'exit 130' INT; trap 'exit 143' TERM; trap 'exit 129' HUP` next to the EXIT trap, or narrow the claim to "on every exit".
2. /home/pvhv/projects/skills/docs/one-fact.md:164-167 — low. Splitting the entry into bullets changed its meaning. The old text was "and for the round copies `plan-gate.sh`, which leaves them out of the digest, `project-plan-report/SKILL.md` and `product-plan-analyze/SKILL.md`", which limits all three files to the round copies. As separate bullets, the last two now look like they state all four facts. A search for `map-|evidence\.md|findings\.md|master\.v` in those two files found only round-copy text (project-plan-report:39 "keep round copies", product-plan-analyze:14 `product-plan.r<n>.md`). Fix: put all three under one bullet, "for the round copies only: …".
3. /home/pvhv/projects/skills/AGENTS.md:30-31 — low. It says "Each check's expected value and the reason for it are in the script's comments". Most expected values (skill and agent names, model lines, skill lines, hooks strings) are in the arrays at gates.sh:43-109, not in comments. Fix: "…are in the script: the values in its arrays, the reasons in its comments."
4. /home/pvhv/projects/skills/tests/gates.sh:16, 28, 36, 254 — low, read but not run (UNVERIFIED). Two things:
   - The script runs `cd` to the repo root (line 16) before it uses `$TMPDIR` (line 36) or resolves `CLAUDE_BIN` (line 28). A relative `TMPDIR` would therefore put the work directory inside the repo, which contradicts "It changes no file in the repo", and a relative `CLAUDE_BIN` would be looked up from the repo root.
   - `"${MS_AGENTS[@]}"` on an empty array under `set -u` is an unbound-variable error before bash 4.4, so the script would stop without a PASS line. It fails safe, and README.md:183 says "macOS is not supported".
   Fix: resolve both paths before the `cd`, or reject a `TMPDIR` that does not start with `/`; `${MS_AGENTS[@]+"${MS_AGENTS[@]}"}` if old bash matters.

Checked and clean:
- **gates.sh expected values:** the same as the old Green list. The 18 skill lines and 9 model lines match the old text exactly (diff printed `same-lines`). The 25 skills, 9 agents and both Hooks strings match.
- **gates.sh return-code rules:** G27 needs `:0` for each file and rc 1. G28 reads each file's count and also needs rc 0. G31 needs no output and rc 1.
- **`claude` commands:** they run only inside the subshell at :211-222. It exports `CLAUDE_CONFIG_DIR` only after `[ -d "$cfg" ]`, and `$cfg` comes from `mktemp`, so it is never empty. Missing CLI output makes G17-G25 FAIL, not pass.
- **Old Gates reasons:** every one moved into the script comments (`test -x`, `&&` vs `;`, `:?` history, the Hooks suffix, read order, marketplace, `user_config`, hedge, model, MISSING, prefix). None is lost.
- **One-fact registry:** a count of every backticked token, old against new, found nothing dropped, only additions from headings and `tests/gates.sh`.
- **AGENTS.md:68 pointer:** it still resolves to the bold rule at AGENTS.md:33-34. No payload file under `plugins/` points at *Gates*. The `docs/specs` records still describe the old block, which is for the record step to update.
- **README.md rows:** accurate.

Run: with `TMPDIR=/data/tmp/claude` and an outer `CLAUDE_CONFIG_DIR` set to a fresh empty directory, `bash tests/gates.sh` printed G1-G31 `ok`, then `PASS 31/31` and `exit=0`. It left no `gates.*` directory behind, and the outer config directory stayed empty.

Not checked: whether any check goes red on a deliberately broken tree (I made no mutated copy), the empty-array behaviour on bash before 4.4, and the `docs/specs` and `plan/` files.
