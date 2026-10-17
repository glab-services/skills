#!/usr/bin/env bash
# Post-condition check for plan/feature-docs-specs (glab:manager Stage 1b asks of each check:
# can it tell a finished tree from a half-finished one?). Run from the repo root:
#   Q1=A STAGE=build bash plan/feature-docs-specs/check.sh            (After A3)
#   Q1=A STAGE=record LAST=<sha> bash <(git show <sha>:plan/feature-docs-specs/check.sh)   (X5)
# DEFAULT_REF is the remote's default branch, origin/main unless set (glab:manager Stage 8).
# LAST is the last commit that holds plan/feature-docs-specs/. A finished tree prints no line
# starting "FAIL". It reads the working tree, so it holds whether the deletions are staged or not.
set -u
G=$(type -P grep)
B=6838133 # the last commit that holds all seven migrated folders
S=docs/specs
STAGE=${STAGE:-build}
DEFAULT_REF=${DEFAULT_REF:-origin/main}
# git status and diff may refresh .git/index; a check must not write to the repo it measures.
export GIT_OPTIONAL_LOCKS=0
fail() { echo "FAIL $*"; }
# A file as one line: each line's leading spaces dropped, lines joined by one space, so a phrase
# that wraps in the source is still found. Spaces inside a line are kept (the bootstrap diagram).
flat() { awk 'BEGIN{ORS=""} {sub(/^ +/, ""); if (NR > 1) print " "; print}' "$1" 2>/dev/null; }
# The "## " heading each line holding the fixed string $2 falls under, in file $1.
heads_of() { awk -v s="$2" '/^## /{h=substr($0, 4)} index($0, s){print h}' "$1" 2>/dev/null; }
# The same, for a line that is an item starting with the string: "- [tag] …", indented or not. A tag
# named inside another item ("the same item as [tag]") is a cross-reference, not the item.
item_heads_of() { awk -v s="- $2" '/^## /{h=substr($0, 4)} {l=$0; sub(/^ +/, "", l)} index(l, s) == 1 {print h}' "$1" 2>/dev/null; }
case "$STAGE" in build|record) ;; *) fail "STAGE must be build or record"; exit 0 ;; esac
SLUGS="bug-reviewer-findings feature-model-switch feature-opencode-worker feature-plugin-marketplace fix-external-report-lines fix-probe-findings sync-local-edits"
[ "$STAGE" = record ] && SLUGS="$SLUGS feature-docs-specs"

# 1. Each folder is gone from the working tree, and no file of it is left in the index
#    unless the index entry is a deletion still to be staged (A3 runs before C3 stages them).
for d in $SLUGS; do
  p=no; [ -e "plan/$d" ] && p=yes
  t=$(git ls-files -- "plan/$d" | wc -l); x=$(git ls-files --deleted -- "plan/$d" | wc -l)
  if [ "$p" = no ] && [ "$t" = "$x" ]; then echo "ok   removed $d (unstaged deletions: $x)"; else fail "removed $d present=$p indexed=$t deleted-in-tree=$x"; fi
done

# 2. No citation of a removed folder outside plan/ — docs/specs/ included — except as a
#    read-only recovery command: `git show <sha>:plan/...`, `git ls-tree -r --name-only <sha> -- plan/...`
#    or `git archive <sha> plan/...` (U11). `git restore --source` writes into the tree and FAILs below. Matched per path, not per line, so a bare path
#    beside a recovery command on the same line is still caught. Untracked new files count.
re="plan/($(tr ' ' '|' <<<"$SLUGS"))"
hits=$(git ls-files -co --exclude-standard | $G -v '^plan/' | xargs -d '\n' "$G" -noE "(git show [0-9a-f]{7,}:|git ls-tree -r --name-only [0-9a-f]{7,} -- |git archive [0-9a-f]{7,} )?$re" 2>/dev/null | $G -vE ':(git show [0-9a-f]{7,}:|git ls-tree -r --name-only [0-9a-f]{7,} -- |git archive [0-9a-f]{7,} )plan/')
restores=$(git ls-files -co --exclude-standard | $G -v '^plan/' | xargs -d '\n' "$G" -nF 'git restore --source' 2>/dev/null)
if [ -z "$restores" ]; then echo "ok   no git restore --source anywhere (U11)"; else fail "git restore --source cited:"; printf '%s\n' "$restores"; fi
if [ -z "$hits" ]; then echo "ok   no stale plan/ citation"; else fail "stale plan/ citations:"; printf '%s\n' "$hits"; fi
# The short record names: only in docs/specs/ and once in AGENTS.md (the live-run rule).
r3=$(git ls-files -co --exclude-standard | $G -vE '^(plan/|docs/specs/)' | xargs -d '\n' "$G" -cE '(findings|plan|probe|questions|integration|result)-r3|findings P[0-9]' 2>/dev/null | $G -v ':0$' | tr '\n' ' ')
if [ "$r3" = "AGENTS.md:1 " ]; then echo "ok   short record names: $r3"; else fail "short record names: '$r3' (want 'AGENTS.md:1 ')"; fi

# 3. Each folder can be brought back from a commit on the default branch, and its primary spec
#    names that commit, in *Records*, as the read-only list command (the repo's plan/ rule; U11).
while read -r slug sha spec; do
  [ "$slug" = feature-docs-specs ] && { [ "$STAGE" = record ] || continue; sha=${LAST:-unset}; }
  git cat-file -e "$sha:plan/$slug/" 2>/dev/null; rc=$?
  git merge-base --is-ancestor "$sha" "$DEFAULT_REF" 2>/dev/null; on=$?
  h=$(heads_of "$S/$spec" "git ls-tree -r --name-only $sha -- plan/$slug/" | $G -cx 'Records')
  if [ "$h" -ge 1 ] && [ $rc = 0 ] && [ $on = 0 ]; then echo "ok   record $slug $sha in $spec"; else fail "record $slug $sha in $spec under-Records=$h recoverable_rc=$rc on-$DEFAULT_REF=$on"; fi
done <<'R'
bug-reviewer-findings 2aeb46d memory-sync.md
feature-plugin-marketplace b853635 marketplace.md
sync-local-edits 9700bcb workflow.md
feature-model-switch 889b804 workflow.md
feature-opencode-worker 51043c4 external-agents.md
fix-external-report-lines 5e9b3a8 external-agents.md
fix-probe-findings 6838133 external-agents.md
feature-docs-specs LAST workflow.md
R

# 4. Every follow-up, question, open list and open-items section, by its tag, in its spec and
#    under the heading its kind allows: F open or closed follow-ups; K known limits; D decisions;
#    R records (one line per open-items section of a folder); X open at build, closed at record;
#    C closed; I incidents. No tag may sit under both open and closed follow-ups.
n=0; m=0
while read -r spec kind tag; do
  n=$((n+1))
  case "$kind" in
    F) want='Open follow-ups|Closed follow-ups' ;; K) want='Known limits and not verified' ;;
    D) want='Decisions that still bind' ;; R) want='Records' ;;
    X) if [ "$STAGE" = build ]; then want='Open follow-ups'; else want='Closed follow-ups'; fi ;;
    C) want='Closed follow-ups' ;; I) want='Incidents' ;;
  esac
  where=$(item_heads_of "$S/$spec" "[$tag]" | sort -u)
  if ! $G -qxE "$want" <<<"$where"; then
    m=$((m+1)); fail "tag [$tag] not under '$want' in $spec (found under: $(tr '\n' ';' <<<"$where"))"
  elif $G -qx 'Open follow-ups' <<<"$where" && $G -qx 'Closed follow-ups' <<<"$where"; then
    m=$((m+1)); fail "tag [$tag] is both open and closed in $spec"
  fi
done <<'T'
memory-sync.md F bug-reviewer-findings/follow-ups.md 1
memory-sync.md F bug-reviewer-findings/follow-ups.md 2
memory-sync.md F bug-reviewer-findings/follow-ups.md 3
memory-sync.md F bug-reviewer-findings/follow-ups.md 4
memory-sync.md F bug-reviewer-findings/follow-ups.md 5
memory-sync.md F bug-reviewer-findings/follow-ups.md 6
memory-sync.md F bug-reviewer-findings/follow-ups.md 7
memory-sync.md F bug-reviewer-findings/follow-ups.md 8
memory-sync.md F bug-reviewer-findings/follow-ups.md 9
memory-sync.md F bug-reviewer-findings/follow-ups.md 10
memory-sync.md F bug-reviewer-findings/follow-ups.md 11
memory-sync.md F bug-reviewer-findings/follow-ups.md 12
memory-sync.md F bug-reviewer-findings/follow-ups.md 13
memory-sync.md F bug-reviewer-findings/follow-ups.md 14
memory-sync.md K bug-reviewer-findings/follow-ups.md before-adopting
memory-sync.md K bug-reviewer-findings/follow-ups.md unverified
memory-sync.md K bug-reviewer-findings/plan.md A4
memory-sync.md K bug-reviewer-findings/plan.md B4
memory-sync.md I bug-reviewer-findings/findings.md pkill
memory-sync.md F bug-reviewer-findings/plan.md memory-index
memory-sync.md F bug-reviewer-findings/plan.md pull-race
memory-sync.md F bug-reviewer-findings/result-slice1.md nested-delete
memory-sync.md F bug-reviewer-findings/result-review1-script.md nested-delete
memory-sync.md D bug-reviewer-findings/questions.md Q2
memory-sync.md D bug-reviewer-findings/questions.md Q6
memory-sync.md D bug-reviewer-findings/questions.md Q9
memory-sync.md D feature-plugin-marketplace/questions.md Q2
memory-sync.md D feature-plugin-marketplace/questions.md Q3
memory-sync.md D feature-plugin-marketplace/questions.md Q4
memory-sync.md D feature-plugin-marketplace/questions.md Q5
memory-sync.md F feature-plugin-marketplace/result-slice-D.md 1
memory-sync.md F feature-plugin-marketplace/result-slice-D.md 2
memory-sync.md F feature-plugin-marketplace/result-slice-D.md 4
memory-sync.md F feature-plugin-marketplace/result-slice-S.md 2
memory-sync.md F feature-plugin-marketplace/result-slice-S.md 3
memory-sync.md K feature-plugin-marketplace/plan.md smoke-test-2
memory-sync.md K feature-plugin-marketplace/plan.md smoke-test-3
marketplace.md F bug-reviewer-findings/follow-ups.md 15
marketplace.md F bug-reviewer-findings/follow-ups.md 17
marketplace.md F bug-reviewer-findings/follow-ups.md 20
marketplace.md F bug-reviewer-findings/follow-ups.md 21
marketplace.md D bug-reviewer-findings/questions.md Q1
marketplace.md D bug-reviewer-findings/questions.md Q4
marketplace.md D bug-reviewer-findings/questions.md Q5
marketplace.md D bug-reviewer-findings/questions.md Q8
marketplace.md D feature-plugin-marketplace/questions.md Q1
marketplace.md D feature-plugin-marketplace/questions.md Q6
marketplace.md D feature-plugin-marketplace/questions.md Q7
marketplace.md F feature-plugin-marketplace/result-review1.md 1
marketplace.md F feature-plugin-marketplace/result-review1.md 2
marketplace.md F feature-plugin-marketplace/result-review1.md 3
marketplace.md F feature-plugin-marketplace/result-slice-D.md 3
marketplace.md F feature-plugin-marketplace/result-slice-S.md 1
marketplace.md F feature-plugin-marketplace/result-slice-S.md 4
marketplace.md F feature-plugin-marketplace/result-slice-S.md 5
marketplace.md K feature-plugin-marketplace/result-slice-G.md unverified
marketplace.md K feature-plugin-marketplace/plan.md unverified
marketplace.md K feature-plugin-marketplace/plan.md smoke-test-1
workflow.md F bug-reviewer-findings/follow-ups.md 16
workflow.md F bug-reviewer-findings/follow-ups.md 18
workflow.md F bug-reviewer-findings/follow-ups.md 19
workflow.md D bug-reviewer-findings/questions.md Q3
workflow.md D bug-reviewer-findings/questions.md Q7
workflow.md D bug-reviewer-findings/questions.md Q10
workflow.md F sync-local-edits/follow-ups.md 1
workflow.md F sync-local-edits/follow-ups.md 2
workflow.md F sync-local-edits/follow-ups.md 3
workflow.md F sync-local-edits/follow-ups.md 4
workflow.md F sync-local-edits/follow-ups.md 5
workflow.md F sync-local-edits/follow-ups.md 6
workflow.md F sync-local-edits/follow-ups.md 7
workflow.md F sync-local-edits/follow-ups.md 8
workflow.md F sync-local-edits/follow-ups.md 9
workflow.md X sync-local-edits/follow-ups.md 10
workflow.md F sync-local-edits/follow-ups.md 11
workflow.md F sync-local-edits/follow-ups.md 12
workflow.md F sync-local-edits/follow-ups.md 13
workflow.md F sync-local-edits/follow-ups.md 14
workflow.md F sync-local-edits/follow-ups.md 15
workflow.md F sync-local-edits/follow-ups.md 16
workflow.md F sync-local-edits/follow-ups.md 17
workflow.md F sync-local-edits/follow-ups.md 18
workflow.md F sync-local-edits/follow-ups.md 19
workflow.md K feature-model-switch/plan.md I1
workflow.md K feature-model-switch/plan.md I4
workflow.md D feature-model-switch/result.md decisions
workflow.md D sync-local-edits/result.md decisions
external-agents.md F feature-opencode-worker/follow-ups.md 1
external-agents.md F feature-opencode-worker/follow-ups.md 2
external-agents.md F feature-opencode-worker/follow-ups.md 3
external-agents.md F feature-opencode-worker/follow-ups.md 4
external-agents.md F feature-opencode-worker/follow-ups.md 5
external-agents.md F feature-opencode-worker/follow-ups.md 6
external-agents.md F feature-opencode-worker/follow-ups.md 7
external-agents.md F feature-opencode-worker/follow-ups.md 8
external-agents.md F feature-opencode-worker/follow-ups.md 9
external-agents.md F feature-opencode-worker/follow-ups.md 10
external-agents.md F feature-opencode-worker/follow-ups.md 11
external-agents.md F feature-opencode-worker/follow-ups.md 12
external-agents.md F feature-opencode-worker/follow-ups.md 13
external-agents.md F feature-opencode-worker/follow-ups.md 14
external-agents.md F feature-opencode-worker/follow-ups.md 15
external-agents.md F feature-opencode-worker/follow-ups.md 16
external-agents.md F feature-opencode-worker/follow-ups.md 17
external-agents.md F feature-opencode-worker/follow-ups.md 18
external-agents.md F feature-opencode-worker/follow-ups.md 19
external-agents.md F feature-opencode-worker/follow-ups.md 20
external-agents.md F feature-opencode-worker/follow-ups.md 21
external-agents.md F feature-opencode-worker/follow-ups.md 22
external-agents.md F feature-opencode-worker/follow-ups.md 23
external-agents.md F feature-opencode-worker/follow-ups.md 24
external-agents.md F feature-opencode-worker/follow-ups.md 25
external-agents.md D feature-opencode-worker/questions.md Q1
external-agents.md D feature-opencode-worker/questions-r3.md Q2
external-agents.md F feature-opencode-worker/plan-r3.md not-in-plan-1
external-agents.md F feature-opencode-worker/plan-r3.md not-in-plan-2
external-agents.md F feature-opencode-worker/plan-r3.md not-in-plan-3
external-agents.md F feature-opencode-worker/plan-r3.md not-in-plan-4
external-agents.md F feature-opencode-worker/plan-r3.md not-in-plan-5
external-agents.md K feature-opencode-worker/plan-r3.md unverified
external-agents.md K feature-opencode-worker/findings-r3.md unverified
external-agents.md K feature-opencode-worker/findings.md unverified
external-agents.md F feature-opencode-worker/probe-r3.md 1
external-agents.md C feature-opencode-worker/probe-r3.md 2
external-agents.md F feature-opencode-worker/probe-r3.md 3
external-agents.md F feature-opencode-worker/probe-r3.md 4
external-agents.md F feature-opencode-worker/probe-r3.md 5
external-agents.md F feature-opencode-worker/probe-r3.md 6
external-agents.md K feature-opencode-worker/probe-r3.md not-verified
external-agents.md K fix-external-report-lines/result.md unverified
external-agents.md X fix-probe-findings/plan.md follow-up-1
external-agents.md F fix-probe-findings/plan.md follow-up-2
external-agents.md C fix-probe-findings/plan.md follow-up-3
external-agents.md F fix-probe-findings/plan.md follow-up-4
external-agents.md F fix-probe-findings/result.md E49
memory-sync.md R bug-reviewer-findings/plan.md L120
memory-sync.md R bug-reviewer-findings/plan.md L1319
memory-sync.md R bug-reviewer-findings/result-review1-prose.md L109
memory-sync.md R bug-reviewer-findings/result-review1-prose.md L122
memory-sync.md R bug-reviewer-findings/result-review1-script.md L221
memory-sync.md R bug-reviewer-findings/result-review1-script.md L242
memory-sync.md R bug-reviewer-findings/result-review1-script.md L247
memory-sync.md R bug-reviewer-findings/result-slice1.md L220
memory-sync.md R bug-reviewer-findings/result-slice1.md L239
memory-sync.md R bug-reviewer-findings/result-slice1.md L253
memory-sync.md R bug-reviewer-findings/result-slice2.md L99
memory-sync.md R bug-reviewer-findings/result-slice2.md L109
memory-sync.md R bug-reviewer-findings/result-slice3-4.md L207
memory-sync.md R bug-reviewer-findings/result-slice3-4.md L220
workflow.md R feature-model-switch/result.md L96
workflow.md R feature-model-switch/result.md L100
external-agents.md R feature-opencode-worker/findings-r3.md L169
external-agents.md R feature-opencode-worker/findings-r3.md L180
external-agents.md R feature-opencode-worker/findings.md L374
external-agents.md R feature-opencode-worker/findings.md L385
external-agents.md R feature-opencode-worker/findings.md L453
external-agents.md R feature-opencode-worker/plan-r3.md L2753
external-agents.md R feature-opencode-worker/plan-r3.md L2900
external-agents.md R feature-opencode-worker/plan-r3.md L2909
external-agents.md R feature-opencode-worker/plan.md L2097
external-agents.md R feature-opencode-worker/plan.md L2211
external-agents.md R feature-opencode-worker/probe-r3.md L109
external-agents.md R feature-opencode-worker/result-r3.md L629
external-agents.md R feature-opencode-worker/result-r3.md L645
external-agents.md R feature-opencode-worker/result.md L243
external-agents.md R feature-opencode-worker/result.md L250
marketplace.md R feature-plugin-marketplace/findings.md L614
marketplace.md R feature-plugin-marketplace/questions.md L202
marketplace.md R feature-plugin-marketplace/plan.md L1730
marketplace.md R feature-plugin-marketplace/plan.md L1895
marketplace.md R feature-plugin-marketplace/result-review1.md L179
marketplace.md R feature-plugin-marketplace/result-slice-D.md L201
marketplace.md R feature-plugin-marketplace/result-slice-D.md L213
marketplace.md R feature-plugin-marketplace/result-slice-G.md L159
marketplace.md R feature-plugin-marketplace/result-slice-G.md L167
marketplace.md R feature-plugin-marketplace/result-slice-M.md L227
marketplace.md R feature-plugin-marketplace/result-slice-M.md L232
marketplace.md R feature-plugin-marketplace/result-slice-S.md L199
marketplace.md R feature-plugin-marketplace/result-slice-S.md L212
external-agents.md R fix-external-report-lines/result.md L197
external-agents.md R fix-external-report-lines/result.md L213
external-agents.md R fix-probe-findings/plan.md L333
external-agents.md R fix-probe-findings/result.md L226
external-agents.md R fix-probe-findings/result.md L238
workflow.md R sync-local-edits/follow-ups.md L58
workflow.md R sync-local-edits/result.md L215
workflow.md R sync-local-edits/result.md L219
T
echo "tags $((n-m))/$n in place"

# 5. Decisions: each id is carried as "[src id]" or named on that source's "[src spent]" line,
#    and either one sits under "## Decisions that still bind". The id lists were read from each
#    source's decision sections at 6838133 (findings.md, *Decision lists*): a fixed list, so a
#    format the extraction would miss cannot shrink it.
while read -r spec src ids; do
  spent=$(awk -v s="- [$src spent]" '/^## /{h=substr($0, 4)} {l=$0; sub(/^ +/, "", l)} index(l, s) == 1 && h == "Decisions that still bind"' "$S/$spec" 2>/dev/null)
  miss=''
  for i in $ids; do
    item_heads_of "$S/$spec" "[$src $i]" | $G -qx 'Decisions that still bind' || $G -qwF -- "$i" <<<"$spent" || miss="$miss $i"
  done
  if [ -z "$miss" ]; then echo "ok   decisions $src ($(wc -w <<<"$ids"))"; else fail "decisions $src missing:$miss"; fi
done <<'D'
workflow.md feature-model-switch/plan.md D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15 D16 D17 D18 D19 D20 D21 D22
workflow.md sync-local-edits/result-followups.md D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12
workflow.md sync-local-edits/result.md M1 M2 M3 P1
external-agents.md feature-opencode-worker/findings.md U1 U2 U3 U4 U5 U6 D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15 D16
external-agents.md feature-opencode-worker/plan.md U1 U2 U3 U4 U5 U6 D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15 D16 D17 D18 D19 D20 D21 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17
external-agents.md feature-opencode-worker/plan-r3.md U1 U2 U3 U4 U5 U6 U7 U8 U9 U10 U11 U12 V1 V2 V3 V4 V5 V6 V7 V8 D22 D23 D24 D25 D26 D27 D28 D29 D30 D31 D32 D33 D34 D35 D36 D37 D38 D39 D40 D41 M1 M2 M3 M4 M5
external-agents.md fix-external-report-lines/plan.md D1 D2 D3 D4 D5 D6
marketplace.md feature-plugin-marketplace/questions.md D1 D2 D3 D4 S1 S2 S3 S4 S5
external-agents.md fix-probe-findings/plan.md decision-1 decision-2 decision-3 decision-4 decision-5 decision-6 D1 D2 D3 D4 D5
D

# 6. Headings: exactly these "## " headings, each once, in this order, and none empty.
check_heads() { # check_heads <spec> <heading>...
  local f=$S/$1; shift
  [ -r "$f" ] || { fail "missing $f"; return; }
  local got; got=$(awk '/^## /{print substr($0, 4)}' "$f")
  if [ "$got" = "$(printf '%s\n' "$@")" ]; then echo "ok   headings in order: ${f#"$S"/}"; else fail "headings of ${f#"$S"/}: want '$*', got '$(tr '\n' ';' <<<"$got")'"; fi
  local empty; empty=$(awk '/^## /{if (h != "" && c == 0) print h; h=substr($0, 4); c=0; next} h != "" && NF {c++} END {if (h != "" && c == 0) print h}' "$f" 2>/dev/null | tr '\n' ';')
  if [ -z "$empty" ]; then echo "ok   no empty section: ${f#"$S"/}"; else fail "empty sections in ${f#"$S"/}: $empty"; fi
}
C='How it works now|Decisions that still bind|Known limits and not verified|Open follow-ups|Closed follow-ups|Incidents|Records'
IFS='|' read -r -a common <<<"$C"
for spec in marketplace workflow memory-sync; do check_heads "$spec.md" "${common[@]}"; done
check_heads external-agents.md 'How it works now' Isolation Measurements Allowlist Profiles 'Decisions that still bind' 'Known limits and not verified' 'Offline run' 'Live runs' 'Open follow-ups' 'Closed follow-ups' Incidents Records

# 7. The two run procedures, byte for byte, from history.
blk() { [ -r "$1" ] || return 0; awk -v h="$2" -v n="$3" -v f="$4" 'index($0,h)==1{on=1;next} on && /^#{2,3} /{on=0} on && $0==f{c++; if(c==n){inb=1; next}} inb && $0=="````"{inb=0; exit} inb' "$1"; }
P=$(mktemp "${TMPDIR:?}/fds-plan-r3.XXXXXX"); git show "$B:plan/feature-opencode-worker/plan-r3.md" >"$P"
a=$(blk "$P" '### Integrate — the real CLI, offline' 1 '````bash' | sha256sum); b=$(blk "$S/external-agents.md" '## Offline run' 1 '````bash' | sha256sum)
if [ "$a" = "$b" ]; then echo "ok   offline block"; else fail "offline block differs"; fi
a=$(blk "$P" '### L1 — the live probe' 1 '````bash' | sha256sum); b=$(blk "$S/external-agents.md" '## Live runs' 1 '````bash' | sha256sum)
if [ "$a" = "$b" ]; then echo "ok   L1a block"; else fail "L1a block differs"; fi
a=$(git show "$B:plan/feature-opencode-worker/probe-r3/runner.sh" | sha256sum); b=$(blk "$S/external-agents.md" '## Live runs' 2 '````bash' | sha256sum)
if [ "$a" = "$b" ]; then echo "ok   runner block"; else fail "runner block differs"; fi
r=$(blk "$S/external-agents.md" '## Live runs' 2 '````bash')
if [ "$(printf '%s\n' "$r" | wc -l)" -ge 30 ] && bash -n <<<"$r"; then echo "ok   runner block parses"; else fail "runner block missing or bash -n fails"; fi
rm -f "$P"

# 8. The profiles' prompt text is unchanged: only ## Notes may change (external-agent.sh:456).
for x in default:4b76d5992a8d7c6e kimi:2d437de722ccdf58 glm:8df4f6ad91d18ead deepseek-pro:275f2d1e9a59a5fe deepseek-flash:172b9700f982b448; do
  f=plugins/glab/skills/external-agents/profiles/${x%%:*}.md
  h=$( { awk -v h='## Before the contract' 'index($0, h) == 1 {on = 1; next} on && /^## / {on = 0} on' "$f"; awk -v h='## After the contract' 'index($0, h) == 1 {on = 1; next} on && /^## / {on = 0} on' "$f"; } | sha256sum | cut -c1-16)
  if [ "$h" = "${x#*:}" ]; then echo "ok   prompt ${x%%:*}"; else fail "prompt ${x%%:*} $h"; fi
done

# 9. Versions: glab raised, memory-sync untouched (an untracked new file there counts).
ms=$( { git diff --name-only "$B" -- plugins/memory-sync; git ls-files -o --exclude-standard -- plugins/memory-sync; } | wc -l)
v="glab=$(jq -r .version plugins/glab/.claude-plugin/plugin.json) memory-sync=$(jq -r .version plugins/memory-sync/.claude-plugin/plugin.json) memory-sync-changes=$ms"
if [ "$v" = "glab=0.5.0 memory-sync=0.1.0 memory-sync-changes=0" ]; then echo "ok   versions $v"; else fail "versions $v"; fi

# 10. Every quoted insertion of P1–P13, R1 and R2, one fixed string each (plan.md, *After* A3).
#     Each file is read flat (see flat), so a wrapped insertion is found; tab separates file and string.
n=0; m=0
while IFS=$'\t' read -r f s; do
  n=$((n+1)); c=$(flat "$f" | $G -oF -- "$s" | wc -l)
  [ "$c" -ge 1 ] || { m=$((m+1)); fail "$f lacks: $s"; }
done <<'I'
plugins/glab/skills/plan-first/SKILL.md	- The spec of each area the change touches, read first — `docs/specs/<area>.md`, or where the repo's `AGENTS.md` puts specs.
plugins/glab/skills/plan-first/SKILL.md	and stays there until the change is recorded, when each one still open moves into the area spec.
plugins/glab/skills/plan-first/SKILL.md	**Plan files are working files; the spec is what stays.**
plugins/glab/skills/manager/SKILL.md	→ commit → push → record
plugins/glab/skills/manager/SKILL.md	The developer writes `plan/{slug}/result.md`, except for the record (Stage 8);
plugins/glab/skills/manager/SKILL.md	"For this task" ends with that task's record (Stage 8), or with its push when it has no plan folder;
plugins/glab/skills/manager/SKILL.md	`<slug> review`, `<slug> record`.
plugins/glab/skills/manager/SKILL.md	## Stage 8 — Record
plugins/glab/skills/manager/SKILL.md	- Dispatch `glab:developer` for the record alone:
plugins/glab/skills/manager/SKILL.md	- At full tier, one `glab:reviewer` pass on the spec diff alone
plugins/glab/commands/plan.md	the area spec its `## Record` names (`glab:manager` Stage 8), and where the plan is.
plugins/glab/agents/developer.md	and stays there until the record moves it into the area spec.
plugins/glab/agents/developer.md	you do write — and during the record, none.
plugins/glab/agents/developer.md	A plan's `## Record` is not one of these steps: it is built only at Stage 8, when the dispatch says this is the record.
plugins/glab/agents/developer.md	## The record — `glab:manager` Stage 8
plugins/glab/agents/developer.md	Step 5 does not apply: write no `result.md`
plugins/glab/agents/developer.md	Step 3's gates run as for any change; where none reaches the spec files, say so in the report.
plugins/glab/agents/analyzer.md	A plan's `## Record` is not a step you measure
plugins/glab/skills/bootstrap/SKILL.md	→  commit  →  push  →  record
plugins/glab/skills/bootstrap/SKILL.md	- the area specs — `docs/specs/`, or where `AGENTS.md` puts them
plugins/glab/scripts/manager-bootstrap.sh	-> commit -> push -> record at full tier
plugins/glab/scripts/external-agent.sh	# Isolation, and why each part is there (docs/specs/external-agents.md in the # glab-services/skills repository, *Isolation* and *Measurements*):
plugins/glab/scripts/external-agent.sh	(docs/specs/external-agents.md, *Allowlist*)
plugins/glab/scripts/external-agent.sh	(docs/specs/external-agents.md, *Live runs*, finding 1)
plugins/glab/scripts/external-agent.sh	(spec, *Measurements*, P4, re-proven on 2.0.31)
plugins/glab/skills/external-agents/profiles/kimi.md	kept in the history of the glab-services/skills repository (`docs/specs/external-agents.md`, *Profiles*)
plugins/glab/skills/external-agents/profiles/kimi.md	(`docs/specs/external-agents.md`, *Live runs*)
plugins/glab/skills/external-agents/profiles/glm.md	kept in the history of the glab-services/skills repository (`docs/specs/external-agents.md`, *Profiles*)
plugins/glab/skills/external-agents/profiles/glm.md	(`docs/specs/external-agents.md`, *Live runs*)
plugins/glab/skills/external-agents/profiles/deepseek-pro.md	kept in the history of the glab-services/skills repository (`docs/specs/external-agents.md`, *Profiles*)
plugins/glab/skills/external-agents/profiles/deepseek-pro.md	(`docs/specs/external-agents.md`, *Live runs*)
plugins/glab/skills/external-agents/profiles/deepseek-flash.md	kept in the history of the glab-services/skills repository (`docs/specs/external-agents.md`, *Profiles*)
plugins/glab/skills/external-agents/profiles/deepseek-flash.md	(`docs/specs/external-agents.md`, *Live runs*)
README.md	(`docs/specs/external-agents.md`, *Live runs*)
README.md	| `plan/` | Working area: the files of changes in progress, removed once each change is recorded |
README.md	| `docs/specs/` | One spec per area: how it works now, why, what is not verified, what is open |
AGENTS.md	- `docs/specs/` — one spec per area: how it works now, why, what is not verified, what is open
AGENTS.md	`plan/` (the working area of changes in progress), `docs/`
AGENTS.md	(`docs/specs/external-agents.md` *Live runs*) did not show
AGENTS.md	or the offline run in `docs/specs/external-agents.md` *Offline run*, whose sandbox has no network
AGENTS.md	The one exception is a live run with the user's own key: the live probe in `docs/specs/external-agents.md` *Live runs*, or a later one recorded the same way.
AGENTS.md	It runs only when the user says so in chat for that run and names the models, after confirming that the console's "Use balance" is off.
AGENTS.md	The user runs it, or the manager session does at that instruction, as a script, never pasted; no dispatched agent runs it.
AGENTS.md	Each run's record goes under `plan/`, as `probe-r3.md` (`docs/specs/external-agents.md` *Live runs*) did, and its transcripts are scanned for secrets, and host values masked, before they are committed.
AGENTS.md	the "Use balance" warning (the skill, `README.md`, and this file's live-run exception)
AGENTS.md	the plan lifecycle — specs in `docs/specs/` unless `AGENTS.md` names another place
AGENTS.md	`plugins/glab/scripts/manager-bootstrap.sh`, `README.md`, and this file's `plan/` rule);
AGENTS.md	**`plan/` is the working area; `docs/specs/` is what stays.**
AGENTS.md	No untracked file under `plan/` is removed; `plan/SESSION-HANDOFF.md` is never committed.
plugins/glab/skills/plan-first/SKILL.md	- why the other candidate boundaries were rejected; - `## Record`
plugins/glab/skills/manager/SKILL.md	- Dispatch `glab:analyzer` for the record check, at every tier
plugins/glab/skills/manager/SKILL.md	A plan folder whose `plan.md` has no `## Record` predates the rule and is not recorded here.
plugins/glab/agents/analyzer.md	## The record check — `glab:manager` Stage 8
plugins/glab/agents/analyzer.md	report each follow-up, open item, binding decision and incident they record as `carried` (cite the spec's `file:line`) or `missing`.
plugins/glab/.claude-plugin/plugin.json	review, commit, push and record through dedicated agents
plugins/glab/skills/plan-first/SKILL.md	and once the change is pushed records it in the area spec under docs/specs/.
plugins/glab/skills/plan-first/SKILL.md	- `## Record` — the area spec or specs this change updates once it is pushed, any audit file under `plan/` it acts on, and what the entry will say.
plugins/glab/skills/plan-first/SKILL.md	The record never removes `plan/{slug}/` or an audit file: whether a recorded plan folder is then removed, and how, is the repo's own `AGENTS.md` decision.
plugins/glab/skills/plan-first/SKILL.md	A plan folder whose `plan.md` has no `## Record` was written before the repo followed this rule, and Stage 8 does not record it.
plugins/glab/skills/plan-first/SKILL.md	Its folder is recorded like a plan's (*Plan files are working files*).
plugins/glab/skills/plan-first/SKILL.md	| Record | Spec entry | the area spec, after the push (`glab:manager` Stage 8) |
plugins/glab/skills/manager/SKILL.md	| 8 | Record | `glab:developer` on the record, `glab:analyzer` on what it carried, then `/glab:commit` | the area spec |
plugins/glab/skills/manager/SKILL.md	| 8 Record | — | after the push: the area spec updated and `glab:analyzer`'s check that every follow-up, decision and incident is carried, in one docs commit |
plugins/glab/skills/manager/SKILL.md	A change with a plan folder goes on to Stage 8.
plugins/glab/skills/manager/SKILL.md	The record changes the spec and nothing else. It never removes `plan/{slug}/` or an audit file
plugins/glab/skills/manager/SKILL.md	It is an ordinary docs change, through the normal commit and push.
plugins/glab/skills/manager/SKILL.md	- Then `/glab:commit` with the spec files, and `/glab:push` on its own go-ahead.
plugins/glab/skills/manager/SKILL.md	A decision made at this stage goes in the dispatch and in the spec, not in `plan.md`
plugins/glab/skills/manager/SKILL.md	- Remove `plan/{slug}/` or an audit file as part of the record (Stage 8).
plugins/glab/agents/developer.md	from the files of `plan/<slug>/` and any audit file the dispatch names
plugins/glab/agents/developer.md	Change nothing inside `plan/<slug>/`, and remove nothing.
plugins/glab/agents/analyzer.md	every file of `plan/<slug>/` and any audit file the dispatch names
plugins/glab/agents/analyzer.md	`DIVERGES: <n> steps` otherwise, each missing item counted as one step.
plugins/glab/skills/bootstrap/SKILL.md	- **`record`** — after the push, what stays true goes into the area spec, in a docs commit of its own (`glab:manager` Stage 8); the plan folder stays unless the repo's `AGENTS.md` says otherwise.
plugins/glab/skills/audit/SKILL.md	4. When a change acts on the file, its plan's `## Record` names it
plugins/glab/skills/audit/SKILL.md	The record never removes the file; whether it is removed afterwards is the repo's own `AGENTS.md` decision.
README.md	Each change's working files — findings, plan, results — live in `plan/<slug>/`. Once the change has been pushed, the workflow records what stays true
README.md	It never removes the plan folder: whether a repo does is that repo's `AGENTS.md` decision.
AGENTS.md	`plan/<slug>/` is committed with the change. After its push, the record (`glab:manager` Stage 8) updates the spec of each area it touched
AGENTS.md	and its incidents, moved into *Incidents* rather than dropped (*Comments and recorded incidents are kept*)
AGENTS.md	the manager session — not a `glab` step — removes the folder by its exact path in a `docs(repo)` commit, after checking that it is tracked, clean (`git status --short -uall -- plan/<slug>/` prints nothing) and identical on `origin/main` (`git diff --quiet origin/main -- plan/<slug>/`)
AGENTS.md	the spec's *Records* line names the last commit on `origin/main` that holds it.
AGENTS.md	one file `git show <sha>:plan/<slug>/<file>`, the list `git ls-tree -r --name-only <sha> -- plan/<slug>/`, the whole folder `git archive <sha> plan/<slug>/ | tar -x -C "$(mktemp -d "${TMPDIR:?}/plan.XXXXXX")"`.
AGENTS.md	the plan lifecycle — specs in `docs/specs/` unless `AGENTS.md` names another place, the record after the push, and that the record never removes the plan folder
AGENTS.md	`plugins/glab/commands/plan.md`, `plugins/glab/agents/developer.md`, `plugins/glab/agents/analyzer.md`
I
echo "insertions $((n-m))/$n present"
# Texts the review of round 1/3 replaced (plan.md, *Amendments — review round 1/3*): each must be
# gone, read flat as section 10 reads. At STAGE=record also the spec lines X1 rewrites.
gone=$(cat <<'G'
plugins/glab/skills/plan-first/SKILL.md	Once the change's push has landed
plugins/glab/skills/plan-first/SKILL.md	nor a folder that was never committed
plugins/glab/skills/plan-first/SKILL.md	- why the other candidate boundaries were rejected. - `## Record`
plugins/glab/skills/plan-first/SKILL.md	git restore
plugins/glab/skills/plan-first/SKILL.md	default branch
plugins/glab/skills/plan-first/SKILL.md	as its records commit (`glab:manager` Stage 6)
plugins/glab/skills/manager/SKILL.md	Only after Stage 7 has confirmed that the push landed.
plugins/glab/skills/manager/SKILL.md	now, or with the next push; say which
plugins/glab/skills/manager/SKILL.md	in one docs commit after the push
plugins/glab/skills/manager/SKILL.md	symbolic-ref
plugins/glab/skills/manager/SKILL.md	merge-base --is-ancestor
plugins/glab/skills/manager/SKILL.md	default branch
plugins/glab/skills/manager/SKILL.md	name `plan/{slug}/` in its scope
plugins/glab/skills/manager/SKILL.md	Nothing is removed before a `CONFORMS`
plugins/glab/skills/manager/SKILL.md	the plan folder removed
plugins/glab/agents/developer.md	Name the last commit that holds the folder
plugins/glab/agents/developer.md	from every file in `plan/<slug>/`
plugins/glab/agents/developer.md	git restore
plugins/glab/agents/developer.md	git ls-files -- plan/<slug>/
plugins/glab/agents/analyzer.md	it runs once the change has landed
plugins/glab/agents/analyzer.md	DIVERGES: <n> items
plugins/glab/agents/analyzer.md	git ls-files -- plan/<slug>/
plugins/glab/skills/bootstrap/SKILL.md	once the push has landed
plugins/glab/skills/bootstrap/SKILL.md	on the default branch
plugins/glab/skills/audit/SKILL.md	and the record commit removes the file
plugins/glab/.claude-plugin/plugin.json	review, commit and push through dedicated agents
README.md	are committed as the work goes. Once the change has been pushed
README.md	git restore
README.md	default branch
AGENTS.md	*Live runs*) does, and its transcripts
AGENTS.md	so `git show <sha>:plan/<slug>/` brings it back
AGENTS.md	Nothing untracked under `plan/` is removed or committed
AGENTS.md	git restore
AGENTS.md	the record once the change has landed on the default branch
docs/specs/workflow.md	on a squash it may live only on the branch
docs/specs/workflow.md	no stage carries out
docs/specs/marketplace.md	`feature-docs-specs` changes this rule
G
)
[ "$STAGE" = record ] || gone=$($G -v '^docs/specs/' <<<"$gone")
while IFS=$'\t' read -r f x; do
  c=$(flat "$f" | $G -oF -- "$x" | wc -l)
  if [ "$c" = 0 ]; then echo "ok   gone from $f: $x"; else fail "$f still has: $x"; fi
done <<<"$gone"
# The old texts gone, the new rows counted, the script's short tags replaced.
o="permanent=$($G -c 'tracked and permanent' AGENTS.md) keeps-plans=$($G -c 'has no rule for removing plan folders, keeps its plans' plugins/glab/skills/plan-first/SKILL.md) spec-row=$($G -c '^| Spec |' plugins/glab/skills/manager/SKILL.md) record-row=$($G -c '^| 8 Record |' plugins/glab/skills/manager/SKILL.md) stage8-heading=$($G -cx '## Stage 8 — Record' plugins/glab/skills/manager/SKILL.md) task-push=$($G -cF "\"For this task\" ends with that task's push" plugins/glab/skills/manager/SKILL.md) findings-r3=$($G -cF '(findings-r3)' plugins/glab/scripts/external-agent.sh) spec-tags=$($G -cF '(spec, *Measurements*' plugins/glab/scripts/external-agent.sh)"
if [ "$o" = "permanent=0 keeps-plans=0 spec-row=0 record-row=1 stage8-heading=1 task-push=0 findings-r3=0 spec-tags=6" ]; then echo "ok   rules $o"; else fail "rules $o"; fi

# The four files the scope cut (U10) returns to the base: no record text in them.
if git diff --quiet "$B" -- plugins/glab/agents/committer.md plugins/glab/commands/commit.md plugins/glab/commands/push.md plugins/glab/commands/ship.md; then echo "ok   committer, commit, push, ship as at $B"; else fail "committer, commit, push or ship differ from $B"; fi

# 11. What the script comments cite is in the spec's *Measurements* or *Allowlist*, and the
#     review of round 1/3's spec additions (S-A2, S-A3, S-A5) are under their headings.
# shellcheck disable=SC2016 # the backticks are literal Markdown, not expansions
for x in 'Measurements:core.fsmonitor' 'How it works now:`BLOCK: target unresolved`' 'Measurements:2.0.31' 'Measurements:1 GiB' 'Measurements:256 MiB' 'Measurements:1.19.3' 'Measurements:OPENCODE_API_KEY' 'Measurements:0.11.1' 'Measurements:OPENCODE_DISABLE_PROJECT_CONFIG' 'Allowlist:Grok' 'Allowlist:30 days'; do
  h=${x%%:*}; s=${x#*:}
  if heads_of "$S/external-agents.md" "$s" | $G -qx "$h"; then echo "ok   $h has '$s'"; else fail "*$h* lacks '$s'"; fi
done
for s in EDQUOT 'leading alternation'; do
  if heads_of "$S/marketplace.md" "$s" | $G -qx Incidents; then echo "ok   marketplace.md *Incidents* has '$s'"; else fail "marketplace.md *Incidents* lacks '$s'"; fi
done

# A removed folder is cited as `git restore --source=<sha> -- <path>/`; `git show` of a folder
# lists only names (conformance round 2/4).
# shellcheck disable=SC2016 # the backtick is literal Markdown, not an expansion
dirshow=$($G -nE 'git show [0-9a-f]{7,}:[^` ]*/`' "$S"/*.md 2>/dev/null)
if [ -z "$dirshow" ]; then echo "ok   no folder cited with git show"; else fail "folder cited with git show:"; printf '%s\n' "$dirshow"; fi

# 12. Patterns that must not appear in the specs. An absence check: it cannot prove that no
#     other host value leaked, only that these did not.
leak=$($G -nE '192\.168\.|(^|[^0-9.])172\.(1[6-9]|2[0-9]|3[01])\.|s3://[a-z0-9]|/data/tmp' "$S"/*.md 2>/dev/null | $G -v 's3://stub')
if [ -z "$leak" ]; then echo "ok   no listed leak pattern (absence check)"; else fail "leak pattern:"; printf '%s\n' "$leak"; fi

# 13. The notes, per the user's answer to Q1 (A: in history only; B: moved unchanged).
case "${Q1:-}" in
  A) n=$(git ls-files -co --exclude-standard -- docs/notes | wc -l)
     if [ "$n" = 0 ]; then echo "ok   Q1=A no notes in the tree"; else fail "Q1=A but $n files under docs/notes"; fi
     for f in deepseek-flash deepseek-pro diff glm kimi; do
       if heads_of "$S/external-agents.md" "git show 51043c4:plan/feature-opencode-worker/notes/$f.md" | $G -qx Profiles; then echo "ok   Q1=A note $f cited"; else fail "Q1=A note $f not cited under *Profiles*"; fi
     done ;;
  B) for f in deepseek-flash deepseek-pro diff glm kimi; do
       if git show "$B:plan/feature-opencode-worker/notes/$f.md" | cmp -s - "docs/notes/external-agents/$f.md"; then echo "ok   Q1=B note $f"; else fail "Q1=B note $f"; fi
     done ;;
  *) fail "set Q1=A or Q1=B to the user's answer" ;;
esac

# 14. Printed only, stage-dependent: the untracked handoff; what is tracked under plan/.
# An index entry whose file is gone from the tree (an unstaged deletion) is not counted.
kept=$(LC_ALL=C comm -23 <(git ls-files plan | LC_ALL=C sort) <(git ls-files --deleted plan | LC_ALL=C sort) | cut -d/ -f2 | sort -u | tr '\n' ' ')
echo "info handoff: '$(git status --short -- plan/SESSION-HANDOFF.md)' | in the tree and the index under plan/: '$kept'"
exit 0
