# feature-external-developer: review, round 1/3

Two reviewers looked at `git diff HEAD`, leaving out `plan/`, on 2026-10-18,
with the Stage 4 record (`integration.md`, M1–M5 all passed) as evidence.
Both returned BLOCK: 6 issues each. The manager relays their findings here.
The user chose **one fix round for all of them** ("One fix round now"), with
the fixes summarised to them as follows:

- rewrite the report's snapshot without `git status`;
- treat a nested `.git` as changed;
- check `core.hooksPath`;
- refuse a `TMPDIR` inside the repo;
- put a time limit on hashing;
- fix the docs and tests.

## X: correctness and security (BLOCK: 6)

- **X1** `external-agent.sh:329` (`dev_state`). The change report runs code
  the agent wrote on the host, outside any sandbox.
  - `git status` runs the clean filters from the repo's config for
    racily-clean entries. A `touch` of a tracked file is enough.
  - It also runs them inside a submodule whose git dir is a real directory
    in the work tree (`sub/.git/`). Codex protects only `<top>/.git`;
    UNVERIFIED that it leaves a nested `.git` writable.
  - The manager's own follow-up `git status`, which the skill and
    `develop.md` tell it to run, also runs a submodule's `core.fsmonitor`.

  The reviewer reproduced all three: `SUB-RAN-ON-HOST`, `RAN-ON-HOST` and
  `FSMON-RAN`.

  Fix:
  - take the snapshot without `git status`: `ls-files -s -z`,
    `ls-files -o -z --exclude-standard`, and `hash-object --no-filters
    --stdin-paths`;
  - refuse a developer `start` when the work tree holds any `.git` other
    than `<top>/.git` (a gitfile or a directory);
  - report `git: changed` when one appears after a turn;
  - tell the manager in the skill and `develop.md` to read changes from the
    script's report and `git diff --no-ext-diff --no-textconv
    --ignore-submodules=all`, never a plain `git status`. Or name the exact
    safe command.
- **X2** `:332-334`. A nested repository (`?? nest/`, a submodule ` M sub`)
  is kind `other`, so nothing inside it is ever reported. The agent can make
  one with `git init nest`. Reproduced: `changed: none`. Fix: covered by X1's
  refusal and `git: changed`.
- **X3** `:357-360` (`dev_git`). Only `<common dir>/hooks` is digested;
  `core.hooksPath` is ignored. husky v9 uses an ignored work-tree directory.
  Reproduced: `changed: none`, then `HOOK-RAN` on the next commit.
  - Fix: read `core.hooksPath` from the repo config (`git config --file
    "$2/config" --get core.hooksPath`, relative to the top) and digest that
    directory as `hooks/` is digested.
- **X4** `:1411-1416`, `:1212`. With `$TMPDIR` inside the repo top, the
  workdir's writable root covers the state root. The agent could then
  rewrite `state.before`, `stderr.txt` or any agent's `agent.json` `cli`,
  which is exec'd unsandboxed on the next send. This is from reading the
  code.
  - Fix: in `cmd_start` for a developer, and in `run_host` before each
    developer turn, refuse when `realpath "$root"` is `realpath "$top"` or
    below it.
- **X5** `:1270-1271`. The post-turn `dev_state` has no time bound, and
  `stop` leaves it running. A 4 GiB sparse file took 14 s, so 100 TiB would
  take hours; millions of files mean one `hash-object` each.
  - Fix: run it under `timeout`, and treat a timeout as unreadable.
  - Fix: batch the hashing with `--stdin-paths`.
  - Fix: above a size cap, record size, mtime, ctime and inode instead of a
    hash.
- **X6** `:104-107`. The header says the developer's network is "not
  measured yet"; integration.md M2/M4 measured it, and the docs state it as
  fact. Fix: cite integration.md M2/M4, and give the skill's *Its network*
  the developer's measurement.
- Advisory, taken:
  - record an untracked file's mode;
  - when the after-state is unreadable, print one line saying so, instead of
    `changed: --` for every path.

## T: tests, docs and rules (BLOCK: 6)

- **T1** README:9, README:72 and SKILL:66 still say every Codex agent is
  read-only.
  - Fix, README:9: "runs external agents — OpenCode Go read-only in a
    sandbox of its own, or Codex in its own sandbox, read-only except for a
    developer —".
  - Fix, README:72 and SKILL:66: "under Codex's own sandbox (read-only, or
    workspace-write for a developer)". The data note must stay identical in
    both files.
- **T2** manager SKILL:156 and skill:88-91. The effort rule sends a
  developer's effort to `- effort:`, while Rule 5 puts it in the model line.
  Fix: "in the model line for the reviewer or the developer (Rule 5)", in
  both places.
- **T3** E74's "a link is not opened" is not tested; a mutant without the
  `-L` branch passes. Fix: an untracked link retargeted during the turn,
  expecting `changed: ?? zl2`, or what the new snapshot prints.
- **T4** Three parts of the report have no test:
  - the `--` (gone) form;
  - files in a new subdirectory;
  - a branch switch.

  Fix: add cases (revert `m.txt`, write `d/f`, a `dev-switch` scenario), or
  name each as uncovered with a reason.
- **T5** "A change to .git is reported" is broader than `dev_git` checks:
  `info/exclude` and `info/attributes` are not covered. Fix: add `$2/info` to
  `dev_git`, with a stub case. Or reword exactly.
- **T6** Comments stale after Stage 4:
  - header `:105-107`: "not measured yet" (as X6);
  - `codex_verify` `:685-690`: "inferred from Codex's source". Cite
    integration.md M5.
- Advisory, taken:
  - manager:150 Rule 6 "for read-only work": add "except a Codex developer
    under Rule 5";
  - manager:123: offer an external developer as well as a reviewer.

## Also from conformance (stale text the plan did not require)

`develop.md` L2/L8 "through glab:developer agents" must name the external
developer path too.

## Assignment

- **Script developer** (script, test, `default.md`): X1–X6 and their
  advisories, T3, T4, T5 (the `dev_git` side), and T6.
- **Docs developer** (skill, manager, `develop.md`, README, AGENTS.md):
  - X1's manager instruction;
  - X6 (the skill's *Its network*);
  - T1, T2, T5 (the wording), and their advisories;
  - `develop.md` L2/L8;
  - any *One fact* entry that the script changes alter.
- **Planner:** revision 3, recording these fixes as approved, for conformance.
