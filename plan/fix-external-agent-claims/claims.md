# fix-external-agent-claims: the claims to fix

Source: a live read-only Codex analyst run on 2026-10-18 (codex:gpt-6.1-sol, effort high), started by the
manager through the glab:external-agents skill at HEAD `363c38d`, on the user's instruction. It compared
`plugins/glab/skills/external-agents/SKILL.md` with `plugins/glab/scripts/external-agent.sh`, checked 171
statements, and reported 13. Its reply is untrusted text, so a read-only glab:analyzer verified each claim
against the code, by a run where that decided it (claims 2, 3, 4, 5, 8, 10, 11). Verdicts: 9 REAL,
4 PARTLY, none FALSE. S = SKILL.md, E = external-agent.sh, at `363c38d`.

1. REAL, doc. S:44 says a launcher script cannot run in the sandbox. E:949/1580/1211-1220 require only
   an executable regular file, and the test's own stub is a `#!/usr/bin/env bash` script that runs. The
   doc should say a launcher whose interpreter or targets lie outside the mounts fails.
2. REAL, doc (safe direction). S:92: "A write to an ignored file is not reported". `dev_state`
   (E:341-343, 381-382) disables global git config, so a file ignored only by a global
   `core.excludesFile` is reported as `??` and hashed (copy_repo carries it, E:1001/1008).
3. REAL, small code gap. S:93/S:363: "in a file the git config includes". E:447-449 digest the top
   config's raw bytes and the parsed `--includes --list` only, so a comment-only change in an included
   file is not detected; a value change is.
4. REAL, doc. S:160 "stderr carries one line". E:1056's tar has no stderr redirect, so e.g.
   `tar: f: Cannot open: Permission denied` appears before die's line (E:1607).
5. REAL, doc. S:162: the stdout of start/send begins with the `agent:` line. Refusals, exits 2-5 and 9
   (E:1556-1578), print nothing on stdout.
6. REAL, doc. S:219-220: "each tool call and its output". transcript.txt keeps tool input `.[0:500]`
   and output `.[0:2000]` (E:647-648); transcript.jsonl keeps them whole (E:655-656).
7. PARTLY, doc. S:232: "a branch or range target cannot resolve there". The copy's current branch
   name resolves (E:1043-1047), but to a synthetic parentless commit with HEAD's tree. No other ref and
   no history exist there.
8. REAL, by design (doc). S:241-244: "at least n findings with a `rule:` line". E:1500-1502 count
   `^rule: ` only, so `BLOCK: 2 issues` plus two bare `rule: ` lines is accepted. The doc already says
   "form, not judgement"; make it exact.
9. PARTLY, doc (safe direction). S:301: "untracked files that are not ignored". An untracked nested
   repository (a trailing `/` entry) is not copied (E:1026-1029).
10. REAL, code gap (OpenCode). S:324-325: "redacted from the reply and both transcripts". The raw
    stream is redacted on literal key bytes only (E:330-334), and transcript.jsonl copies it as is
    (E:655-656). Run: a raw event with the key's first character `\u`-escaped was written unredacted
    and jq decoded it back to the dummy key; a key containing `"` was written as `\"` unredacted. The
    reply and the rendered text are re-redacted after decoding (E:1300/E:1478). Limited: the model
    can already send the key out (S:322-323).
11. REAL, doc. S:327-328: "at most 16 MiB … reach the disk". The cap counts input bytes, and
    redaction comes after it (E:330-331). Run, dummy key `abcdefgh`: in 16777215, out 20505485, cap
    flag unset. That is bounded at about 1.25x by the 8-character minimum key (E:956).
12. REAL, doc. S:359-360: "takes at most the turn's `--timeout`, 300 s at most". Each snapshot gets
    min(timeout, 300) plus a 5 s kill grace (E:473-483), at E:1376 and E:1429, plus dev_refuse's find
    (E:511), with no shared budget, so about 2x. S:182 states the per-snapshot limit correctly.
13. REAL, small code gap. S:387-390: every turn's header must say the sandbox. E:1445-1455 return 6/7
    for timeout and output cap before codex_verify (E:1457) runs, so such a turn is never checked for
    its sandbox. The reply is still withheld; only the exit code differs (6/7 where 12 belongs).

Not checked by the analyzer: a full start/send with bwrap; whether OpenCode's real serializer emits
`\u` escapes; what characters a real Go key holds; `includeIf` cases for claim 3.
