tier: normal — one regex and one count in one script function, three new stub scenarios and one new case, prose in two command/agent files, four profile notes, the README sentence and its gate line, a version bump; no secret handling, format, exit-code or permission change

# Plan — fix-probe-findings

Probe findings 1, 3 and 5 of `plan/feature-opencode-worker/probe-r3.md`
(L1, run 2026-10-17). Base: `main` = `5e9b3a8` (glab 0.4.1). Planner: one
agent, read-only on the repo. Every "proven" below was run in throwaway
copies, `/data/tmp/claude/fpf-proto.*` (`plugins/`, `tests/`,
`.claude-plugin/`, `README.md`, `AGENTS.md` copied from `5e9b3a8`), never in
the repo, and never against a real model.

`findings.md` was refused by the Write tool in this session (a subagent
rule), so the findings are here, in *Findings*. `edits.py`, next to this
file, holds the exact before/after text of every step and applies them;
running it on a fresh copy reproduced the hashes in *After* (proven:
`diff -r` against the gated copy, `rc=0`).

## Findings

Paths (11): `plugins/glab/scripts/external-agent.sh`,
`plugins/glab/agents/reviewer.md`, `plugins/glab/commands/ship.md`,
`tests/external-agent.test.sh`, `plugins/glab/skills/external-agents/profiles/{kimi,glm,deepseek-pro,deepseek-flash}.md`,
`README.md`, `AGENTS.md`, `plugins/glab/.claude-plugin/plugin.json`.

F1 — **the check rejects `BLOCK: 1 issue`** (probe finding 1). Evidence:
the singular whole on its line, `probe-r3/kimi-k3/reviewer.transcript.txt:613`,
`probe-r3/kimi-k2.7-code/reviewer.transcript.txt:627` (also :693, :767,
:851); plural after the correction :903, :933; GLM plural,
`probe-r3/glm-5.3/reviewer.transcript.txt:780`, :874; `kimi-k3/run.log:58`
`MALFORMED REPORT: expected exactly one verdict line, found 0`. Proven, on
Kimi K3's last block extracted with the script's own awk: today's set gives
`verdicts=0`; with S1a `verdicts=1`; S1b's count gives `n=1 rule=1` — it
would have passed. Every statement of a reviewer verdict form:

| file:line | changes? |
|---|---|
| `external-agent.sh:684` comment "the set is reviewer.md's" | stays; comment added under it (S1a) |
| `external-agent.sh:685` the set | S1a |
| `external-agent.sh:689` the `sed` reading n | S1b |
| `external-agent.sh:695-696` gap messages | no: :695 is reached only from `0 issues`; :696 reads "1 issues" for the singular, accepted |
| `external-agent.sh:496-504` `reviewer_tail`, :503 sends reviewer.md's *Report* (`report_section` :457) | no edit; carries S2 to an external reviewer |
| `reviewer.md:86` the verdict line | S2 |
| `reviewer.md:44`, `:47` `BLOCK: target unresolved`; `:100-102` last-round verdicts | no |
| `ship.md:26` `BLOCK` gate line | S3 — matched whole (:22), a singular would fall to "no clear verdict" (:28) |
| `manager/SKILL.md:143` (last-round only), `:145` ("the form the agent's file gives it") | no: :145 points at reviewer.md |
| `external-agents/SKILL.md:131-134` "for `BLOCK: <n> issues` an n of at least 1 …" | no: true of the singular (n = 1) |
| `commands/review.md:10` | no form stated |
| `tests/external-agent.test.sh:124-126` stub scenarios | kept; three added (S4a) |
| `tests/external-agent.test.sh:506-507` E34 | S4b |
| `tests/external-agent.test.sh:591` E44 | no |

Other agents' `BLOCK…` lines (`analyze.md:16`, `analyzer.md:20,65`,
`developer.md:22,119`, `integrator.md:23,85`, `integrate.md:18`) are not the
reviewer's and stay; `README.md` and `glab:bootstrap` state no verdict
(`command grep -rn -F BLOCK plugins tests README.md AGENTS.md` lists neither).
Callers: the set and the `sed` sit only in `finish_turn`'s reviewer branch
(`:681-702`), every reviewer turn; cases E17, E18, E19, E44, E47, E48 drive it.

F2 — **DeepSeek refused upstream** (finding 3): `probe-r3/deepseek-v4-pro/run.log:2-3`.
Allowlist `external-agent.sh:196-202` unchanged (D3).

F3 — **sentences L1 made false** (finding 5): `README.md:52-56` ("have not
yet run against a real model", L1 "which you run"); `AGENTS.md:59` (gate
C7), `:78` (its *Green is*), `:181-182` (one-fact entry); the *Notes* bullet
"No reply from this family has been captured. The user's live probe …
captures one transcript" — `profiles/kimi.md:48-51`, `glm.md:44-47` (false:
replies captured), `deepseek-pro.md:44-47`, `deepseek-flash.md:44-47` (first
half true, second false: L1 captured none). *Notes* are never sent (E20).
No other (proven): `command grep -rn -i -E 'real model|real repl|not yet run|no real|UNVERIFIED|captured|live probe|until L1|before L1|L1 has|has not run|never run against|not been run' README.md plugins AGENTS.md`
returns only these, the gate lines, the `UNVERIFIED: <claim>` rule text, the
analyzer's `unverified`, and `AGENTS.md:106-111` (out of scope);
`command grep -rn -E '\bL1\b|probe|plan-r3' README.md plugins` returns only
`README.md:54`, the four profiles, and an unrelated "probed",
`memory-sync.sh:71`. `external-agents/SKILL.md:137` ("it keeps its context")
is now shown and stays.

F4 — **the cited records are untracked**: `probe-r3.md` and `probe-r3/`
are `??` (`git ls-files` prints nothing). At planning, 12 files under
`probe-r3/` held the real port of the user's OpenCode service; the manager
has since masked it (manager decisions below; proven after: the same
`command grep -rl -F` counts 0 files, and `probe-r3.md:12-14` records the
masking). The values are not written here. See *Commit*.

F5 — `plugin.json:3` `0.4.1`; stated nowhere else outside `plan/`.

## Decisions (user, in chat, 2026-10-17 — binding)

1. The reviewer's verdict check accepts `BLOCK: 1 issue` besides
   `BLOCK: <n> issues`.
2. DeepSeek is left as is: the workspace region is not switched; the
   allowlist does not change.
3. The README sentence is updated — false for Kimi and GLM, true for
   DeepSeek — and the C7 gate line, its *Green is* bullet and the one-fact
   entry change in the same step, so a new pinned phrase is gated.
4. glab `version` → `0.4.2`.

## Decisions (manager, 2026-10-17)

5. The port of the user's local OpenCode service and the host's LAN address
   in `probe-r3/` were masked by the manager as `<service-port>` and
   `<host-lan-ip>`, as noted in `probe-r3.md`.
6. The probe records commit lands before the fix commit.

## Decisions (planner)

- **D1 — the singular for one only**: `BLOCK: 1 issue`, not
  `BLOCK: [0-9]+ issues?`. It is the form L1 saw; `BLOCK: 3 issue` was
  written by no model and no template, and accepting it widens the check past
  the evidence. Flat alternation, like the rest of the set. The `sed` gets a
  second whole-line expression for it, so a singular without findings is
  still caught (mutant m2), and an out-of-form line beside a `SHIP` is never
  read as a count.
- **D2 — one fact**: `reviewer.md:86` keeps `BLOCK: <n> issues` as the form
  and adds "(for one issue, `BLOCK: 1 issue` is the same verdict)"; native and
  external reviewers read the same line (an external one through
  `report_section`). `ship.md:26` names both. E34 pins the singular in
  reviewer.md and in the script's set. `glab:manager` and
  `glab:external-agents` are not edited: neither enumerates the BLOCK forms.
- **D3 — the README sentence** (S6), and its pinned phrase
  `Not yet shown: any reply from a DeepSeek model`, on one line. The sentence
  states what L1 showed and, under that label, every hedge of
  `probe-r3.md` *Not verified*: DeepSeek, a real repository, a long brief, a
  Go limit, the profiles' effect. S7b lists the same five. The gate pins the label and the DeepSeek item; the
  rest of the hedge is checked by the *After* searches.
- **D4 — profile notes** (S5): factual correction only, pointing to
  `plan/feature-opencode-worker/probe-r3/`; no profile instruction changes.
- **D5 — a new case, E49**, not an extension of E44: three stub scenarios,
  `rev-one`, `rev-one-bare`, `rev-two-singular`.

## Before

    export TMPDIR=/data/tmp/claude
    git -C /home/pvhv/projects/skills log --oneline -2    # the probe records commit (decision 6), then 5e9b3a8
    git -C /home/pvhv/projects/skills diff --stat 5e9b3a8 HEAD -- plugins tests README.md AGENTS.md .claude-plugin   # prints nothing
    git -C /home/pvhv/projects/skills status --short     # ?? plan/SESSION-HANDOFF.md, and plan/fix-probe-findings/ unless it went into the records commit
    sha256sum plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/agents/reviewer.md plugins/glab/commands/ship.md plugins/glab/skills/external-agents/profiles/{kimi,glm,deepseek-pro,deepseek-flash}.md README.md AGENTS.md plugins/glab/.claude-plugin/plugin.json

Expected at `5e9b3a8` (proven, printed in the repo):

    cd83212a9d855b641c3162a22f2a6fbb23aa017dd135352f6ebc9661ca835f1d  plugins/glab/scripts/external-agent.sh
    e07ea8851a8fec1d03d76c713ff942c67059b54bd216696d57463b8785e76d19  tests/external-agent.test.sh
    c3fba25fd343a67350f6a7d9148b003ac0da189c34c2b60fc0871888b5f267c1  plugins/glab/agents/reviewer.md
    8976d4b68e1ef3b2382cbf39ba3286f8b69378625a85dfb7ffa280071b2ce9af  plugins/glab/commands/ship.md
    6ca8e669b082434f537147fa6b63ecfa8cefc4631d882eca99ecdd8ae4de950b  plugins/glab/skills/external-agents/profiles/kimi.md
    2057207a1f2ee2c3fb3e8d7a1a4ce722a8653bea3853096ae049458165632c92  plugins/glab/skills/external-agents/profiles/glm.md
    12b572dbe068552b1474e10e5585f9aa2cfae82343359e4b8d342f26b4d131ed  plugins/glab/skills/external-agents/profiles/deepseek-pro.md
    0b5a1d7991ff07cc4e2d006edc1b274d07ce0990065a7f01961014db398b9ea7  plugins/glab/skills/external-agents/profiles/deepseek-flash.md
    afece4ca69a2dc6c68a33239315cdd515a27e3d019cc8c127956371c2d4da180  README.md
    173df969826b583284c70bbdd5ba8c887bd3a51b22fb238c844beb5c31f66d68  AGENTS.md
    7ae980039b274f8e4e9da3a594d77b197aa6bd7e37348f71d788feb8e3b0ba25  plugins/glab/.claude-plugin/plugin.json

A hash that differs: stop and re-read; the line numbers are for these.

## Processing — the edits

The exact before/after text of each step is the entry with its id in
`plan/fix-probe-findings/edits.py`; each before-text occurs once (proven:
`before-text found 1 time(s)` for all 17). Apply by hand with those texts,
or run `python3 -I plan/fix-probe-findings/edits.py .` from the repo root,
which applies all and exits 1 if any before-text is not found once. Tabs in
the test are real tabs.

- **S1a** `external-agent.sh:684-685` — add `BLOCK: 1 issue|` before
  `BLOCK: [0-9]+ issues` in the set, and under the `:684` comment a comment
  recording why: Kimi's singular in L1 (`probe-r3.md`, finding 1), for one
  only (D1).
- **S1b** `external-agent.sh:689` — `sed -n -e '<plural, as today>' -e
  's/^BLOCK: \(1\) issue$/\1/p'`, with a two-line comment above it: both
  forms whole, so a line out of form is never read as a count.
- **S2** `reviewer.md:86` — after `` `BLOCK: <n> issues` `` insert
  `` (for one issue, `BLOCK: 1 issue` is the same verdict) `` before the comma.
- **S3** `ship.md:26` — `` - `BLOCK: <n> issues`, `BLOCK: 1 issue` or `BLOCK: target unresolved` → stop here. ``
- **S4a** test, after `:126` — a comment line and three scenarios:
  `rev-one` (one finding with `rule:`, `BLOCK: 1 issue`), `rev-one-bare`
  (`BLOCK: 1 issue` alone), `rev-two-singular` (two findings, `BLOCK: 2 issue`).
- **S4b** test `:506-507` (E34) — add `` '`BLOCK: 1 issue`' `` after
  `` '`BLOCK: <n> issues`' `` in the loop, and `BLOCK: 1 issue|` in the
  script string, as in S1a.
- **S4c** test `:518` — `E37-E48` → `E37-E49`.
- **S4d** test, after `:646` (`t E48 …`) — a blank line, a three-line
  comment, and E49: on `opencode-go/kimi-k3` as reviewer, `rev-one` exits 0
  with last reply line `BLOCK: 1 issue`; `rev-one-bare` exits 8 with
  `verdict says 1 issues, the report has 0 findings`; `rev-two-singular`
  exits 8 with `expected exactly one verdict line, found 0`; `stop_all` after
  each. Title: `BLOCK: 1 issue is accepted with its count checked, as BLOCK: 1 issues is; BLOCK: 2 issue is malformed (8)`.
- **S5a–d** the four profiles' `UNVERIFIED: that this text makes a real
  reply better.` bullet (kimi `:48-51`, the others `:44-47`). kimi and glm:
  replies were captured in the live probe of 2026-10-17, for the named models,
  in `plan/feature-opencode-worker/probe-r3/`, but only with this profile, so
  nothing compares them with a reply without it; tune from those transcripts
  and cite them. deepseek-pro, deepseek-flash: no reply captured — in that
  probe the model was refused upstream before its first turn; tune from the
  first transcript a run captures. The `UNVERIFIED:` label stays.
- **S6** `README.md:52-56` — replaced by:

      External agents have been tested against a stub, against the real `opencode`
      with no network, and in one live probe on 2026-10-17
      (`plan/feature-opencode-worker/probe-r3.md`): the five Kimi and GLM models
      each answered a task, a `send` and a review through the sandbox, on a
      one-file test repository.
      Not yet shown: any reply from a DeepSeek model (both were refused upstream
      before their first turn); how any model does on a real repository, a long
      brief or a Go limit; and whether the profiles make a reply better. Treat the
      first real session of any of these as the test it is.

- **S7a** `AGENTS.md:59` — `command grep -c -F 'Not yet shown: any reply from a DeepSeek model' README.md; echo "rc=$?"`.
- **S7b** `AGENTS.md:78` — the bullet's second sentence becomes: "The
  sentence says what the live probe of 2026-10-17
  (`plan/feature-opencode-worker/probe-r3.md`) did not show: a reply from a
  DeepSeek model, a real repository, a long brief, a Go limit, the profiles'
  effect. It changes only
  when a later run has shown one of them, and no other gate notices when it is
  dropped or reworded into a claim that one has been shown."
- **S7c** `AGENTS.md:181-182` — "the sentence on what the live probe did not
  show (`README.md`, pinned by its gate line above)."
- **S8** `plugin.json:3` — `0.4.1` → `0.4.2`.

No other file. `plan/SESSION-HANDOFF.md` and `probe-r3*` are not touched.

## After — the gates

`export TMPDIR=/data/tmp/claude`, then both AGENTS.md *Gates* blocks exactly
as AGENTS.md states them **after S7** (the C7 line is S7a's). Green, as the
planner saw in the copy (proven):

    plugins/memory-sync/scripts/memory-sync.sh rc=0
    plugins/glab/scripts/manager-bootstrap.sh rc=0
    plugins/glab/scripts/external-agent.sh rc=0
    tests/memory-sync.test.sh rc=0
    tests/external-agent.test.sh rc=0
    rc=0
    PASS 35/35
    ok E49 BLOCK: 1 issue is accepted with its count checked, as BLOCK: 1 issues is; BLOCK: 2 issue is malformed (8)
    ok E36 after every case: …
    PASS 49/49                         # was 48/48 (probe-r3.md, L1a)
    ✔ Validation passed  (×3)
      Skills (15) … Agents (5) … Hooks (1)  SessionStart …
      Skills (1)  sync-memory / Agents (0) / Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop …
    glab = glab
    memory-sync = memory-sync
    plugins/glab/hooks/hooks.json:0
    plugins/memory-sync/hooks/hooks.json:0
    rc=1
    …memory-sync.sh:1  …SKILL.md:1  README.md:1
    rc=0
    1
    rc=0
    rc=1

Post-condition searches. Each step changes at least one count below (step
ids in the comments), so a tree with any one step skipped prints a different
output from the finished one (proven: for each of the 17 step ids, a fresh
copy with all other steps applied gave output that differed from the full
copy's — `detected` 17 of 17). The hashes below catch everything else.

    P=plugins/glab/skills/external-agents/profiles
    jq -r .version plugins/glab/.claude-plugin/plugin.json                    # 0.4.2 (S8)
    command grep -c -F 'not yet run against a real model' README.md AGENTS.md  # README.md:0 AGENTS.md:0 — S6 skipped leaves README 1, S7a or S7b skipped leaves AGENTS 1; S7c's old text splits the phrase over two lines, so the next search covers it
    command grep -c -F 'Not yet shown: any reply from a DeepSeek model' README.md AGENTS.md   # 1 and 1 (S6, S7a)
    command grep -c -F 'probe-r3.md' AGENTS.md                                 # 1 (S7b)
    command grep -c -F 'the sentence on what the live probe did' AGENTS.md     # 1 (S7c)
    command grep -c -F "The user's live probe (L1" $P/*.md; echo "rc=$?"       # 0 for all five, rc=1 (S5a-d)
    command grep -c -F 'probe-r3/' $P/kimi.md $P/glm.md $P/deepseek-pro.md $P/deepseek-flash.md   # 1 each (S5a-d)
    command grep -c -F 'Replies from this' $P/kimi.md $P/glm.md $P/deepseek-pro.md $P/deepseek-flash.md   # 1 1 0 0 (S5a, S5b)
    command grep -c -F 'BLOCK: 1 issue' plugins/glab/agents/reviewer.md plugins/glab/commands/ship.md plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh   # 1 1 2 8 (S2, S3, S1a, S4a+S4b+S4d; 2 of the test's 8 are the old `BLOCK: 1 issues`)
    command grep -c -F "'s/^BLOCK: \(1\) issue\$/\1/p'" plugins/glab/scripts/external-agent.sh   # 1 (S1b)
    command grep -c -F 'E37-E49' tests/external-agent.test.sh                   # 1 (S4c)
    git status --short    # the 11 paths M, plus the four ?? above

Expected hashes after (proven, the copy where every gate above was green):

    5300474337059f42b2d29bf367fa8b4df43f3f46c6918cd1bea1bbd42dba6968  plugins/glab/scripts/external-agent.sh
    6c37fc7bcfba0905ee496ffb1a616860a40bb756339662a7203944b6f934a3e2  tests/external-agent.test.sh
    d3419bed8024005a2e9cebfd4feaf867a9be8ca410fb72dfce69e4aa2c058f14  plugins/glab/agents/reviewer.md
    34cda6fce2fa735bd21076c16673944e2f57bede8b03557aa0624be7c8f19ae5  plugins/glab/commands/ship.md
    b082521339edf31f84efba4494002d70c0a32a9a8ab9ec7878c79b07ff60dab4  plugins/glab/skills/external-agents/profiles/kimi.md
    8349105cc51b4fb68ee25acad8d778fb35323602afa331cea3660914d276614a  plugins/glab/skills/external-agents/profiles/glm.md
    c5241b800de0f7f3636a3e1210235e8ff761f10c31a8478898e47ece0164a6eb  plugins/glab/skills/external-agents/profiles/deepseek-pro.md
    a1fda4d56537ca8eb5b729be4fbdb9ff8657769b411dbe9a0295411f67cc4145  plugins/glab/skills/external-agents/profiles/deepseek-flash.md
    b55f917487db0ab5774b05d677a0ff404193bd6eb2e20b85bb28b1b7f164ad1a  README.md
    ef1f7eb32682ecfdd21b177633101805ecdb293cce54278761fc485340edd630  AGENTS.md
    4889cf8aa46697c1d961b1e9192f3a4cbdb868c11b408db67402d554a335ab25  plugins/glab/.claude-plugin/plugin.json

E49 and E34 fail for the reason they exist (proven, three mutants of the
script in fresh copies, the test otherwise unchanged):

    m1 set without BLOCK: 1 issue          NOT OK E34, NOT OK E49   FAIL 2/49
    m2 sed without its second expression   NOT OK E49               FAIL 1/49
    m3 BLOCK: [0-9]+ issues? and issues\{0,1\} in the sed   NOT OK E34, NOT OK E49   FAIL 2/49

## Coverage (AGENTS.md *Tests*)

- S1a: **E49** (`rev-one` 0, `rev-two-singular` 8 — m1, m3) and **E34** (the
  string). E17, E18, E19, E44 still pass: the other forms are unchanged.
- S1b: **E49** `rev-one-bare` (m2). The "line out of form beside a SHIP" in
  its comment: no case; follows from both expressions being whole-line.
- S2: **E34** (`` `BLOCK: 1 issue` `` in reviewer.md). Whether a model now
  writes either form: no case; seen only in a live run.
- S3: no case — prose; checked by the `BLOCK: 1 issue` search (ship.md 1).
- S4a–d: the test itself; its failure modes are the mutants above.
- S5a–d: no case — *Notes* are never sent (E20); checked by the searches.
- S6, S7a–c: the C7 gate line itself, and the searches; Markdown has no gate.
- S8: no case; the `jq` line.

## Commit

Order (decision 6): the probe records commit, with the masked values
(decision 5), lands before this one, because S5 and S6 cite
`plan/feature-opencode-worker/probe-r3.md` and `probe-r3/`.

The fix, one commit, the 11 paths `git add`ed by name:

    fix(agents): accept BLOCK: 1 issue from a reviewer and record the live probe

    - external-agent.sh: the verdict set and its count accept BLOCK: 1 issue,
      for one only
    - reviewer.md, ship.md: the singular is the same verdict
    - test: E49 and three stub scenarios; E34 pins the singular
    - profiles: the notes say what the live probe captured
    - README, AGENTS.md: the hedge says what the probe did not show, and the
      C7 gate pins its new phrase
    - glab 0.4.2

Then a `docs(repo)` commit: this plan and `edits.py`, unless they went into
the records commit.

## Back-out

Before the commit: `git restore` the 11 paths only. After it: no
`git revert` to `0.4.1`; a new commit restoring the text and raising glab to
`0.4.3`, the test back to `PASS 48/48`.

## Follow-ups (out of scope, not done here)

1. `AGENTS.md:110-111`: "the live probe in that plan, which the user runs
   with their own key; no agent runs it" — the manager ran L1 at the user's
   instruction. A working-agreement rule: the user's call.
2. Probe finding 4: a start refused upstream lists with `turns=2`.
3. Probe finding 2: `plan-r3.md` L1b's `send` expectation assumed the brief
   arrives inline.
4. Follow-up 12 of `plan/feature-opencode-worker/follow-ups.md`: re-tune the
   profiles from the transcripts.
