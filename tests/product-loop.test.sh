#!/usr/bin/env bash
# The product <-> project loop of glab, end to end, without a model: the user's way to see how the
# product skills work before installing anything. It builds a product repo, a project repo and a
# shared store under $TMPDIR, writes from tests/fixtures/product-loop/ what each agent would write
# in a live session - each case says which role writes what - and runs the real plan-gate.sh and
# manager-bootstrap.sh at every point where a live session runs them. It calls no model and writes
# nothing outside its own work directory.
#
#   PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh <plan-gate.sh> <manager-bootstrap.sh>
#
# With PRODUCT_LOOP_SHOW=1 it also prints the trace of the loop on stderr - each case's scene, every
# command a session runs, each refusal, and the text of every store file the case wrote - so stdout
# keeps only the case lines. Send the trace to a file and read it there.
set -uo pipefail
[ -f "${1:-}" ] && [ -f "${2:-}" ] || {
	echo "usage: $(basename "$0") <path to plan-gate.sh> <path to manager-bootstrap.sh>" >&2
	exit 2
}
GATE=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
HOOK=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
FX=$(cd "$(dirname "$0")" && pwd)/fixtures/product-loop
[ -d "$FX" ] || { echo "no fixtures at $FX" >&2; exit 2; }
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/product-loop-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap only removes
# the work directory.
trap 'rm -rf "$W"' EXIT
SHOW=${PRODUCT_LOOP_SHOW:-}
STORE=$W/store PRODUCT=$W/product-repo PROJECT=$W/notes-api-repo
mkdir -p "$STORE" "$PRODUCT" "$PROJECT"
printf '# Working agreement — the product repo\n\nglab-level: product\nglab-shared-store: <store>\n' >"$PRODUCT/AGENTS.md"
printf '# Working agreement — the notes-api repo\n\nglab-shared-store: <store>\n' >"$PROJECT/AGENTS.md"
SLUG=plan/notes-api-v1 BR=briefs/notes-api

pass=0 fail=0 n=0
reason='' # why the current case failed; empty while it holds
OUT='' ERR='' RC=0 SNAP=''
bad() { reason="${reason:+$reason; }$*"; }
say() { [ -z "$SHOW" ] || printf '%s\n' "$*" >&2; }
snap() { (cd "$STORE" && find . -type f -exec cksum {} + | LC_ALL=C sort); }
# scene <id> <who> <what>: the start of a case - its header in the trace, and the store as it was.
scene() {
	SNAP=$(snap)
	say ''
	say "=== $1 · $2"
	say "    $3"
}
# shown <store file>: in the trace, the file's store path and its text.
shown() { say "--- ${1#"$STORE"/}" && [ -z "$SHOW" ] || sed 's/^/    | /' "$1" >&2; }
# show_writes: in the trace, each store file this case wrote or changed that a gate run did not show
# already - the rules, the briefs. A copy folder plan.r<n>/ is the plan the trace showed; it is named
# by the report that wrote it.
show_writes() {
	[ -n "$SHOW" ] || return 0
	local f
	comm -13 <(printf '%s\n' "$SNAP") <(snap) | awk '{ print $3 }' | LC_ALL=C sort | while IFS= read -r f; do
		case $f in
		./briefs/*/plan.r*/* | ./briefs/*/report.r*.md | ./briefs/*/verdict.r*.md) ;;
		*) shown "$STORE/${f#./}" ;;
		esac
	done
}
done_case() { # done_case <id> <name>
	show_writes
	n=$((n + 1))
	if [ -z "$reason" ]; then
		pass=$((pass + 1))
		echo "ok $1 $2"
	else
		fail=$((fail + 1))
		echo "FAIL $1 $2: $reason"
	fi
	reason=''
}
# gate <args...>: runs plan-gate.sh from the repo whose turn it is ($HERE), as the session there would.
# In the trace the store is <store> and a fixture is named by its path under the fixtures folder;
# a report or verdict the run wrote is shown at once, so the trace reads in the order of the loop.
gate() {
	local a shown_args=''
	for a in "$@"; do
		a=${a//"$STORE"/<store>}
		shown_args="$shown_args ${a#"$FX"/}"
	done
	say "    \$ plan-gate.sh$shown_args"
	OUT=$(cd "$HERE" && bash "$GATE" "$@" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
	[ -z "$ERR" ] || say "      $ERR"
	case $1:$RC in
	report:0) shown "$OUT" && say "    (and plan.r<n>/ beside it: a byte copy of the plan files it hashed)" ;;
	verdict:0) shown "$OUT" ;;
	*) [ -z "$OUT" ] || say "      ${OUT//"$STORE"/<store>}" ;;
	esac
}
ok_gate() { gate "$@"; [ "$RC" -eq 0 ] || bad "[plan-gate.sh $*] rc=$RC: $ERR"; }
no_gate() { # no_gate <REFUSED line> <args...>
	local line=$1
	shift
	gate "$@"
	[ "$RC" -eq 1 ] && [ "$ERR" = "REFUSED: $line" ] || bad "[plan-gate.sh $*] gave rc=$RC [$ERR], not [REFUSED: $line]"
}
h256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -c1-64; }
# start <repo>: the session start in that repo; prints the context text the hook gives it.
start() { CLAUDE_PROJECT_DIR=$1 bash "$HOOK" </dev/null 2>/dev/null | jq -r .hookSpecificOutput.additionalContext; }
# audit <project>: stands in for glab:product-analyzer's project plan audit of the latest copy - it
# holds every file of the copy, sub-plans included, to data-retention.md's 90 days - and prints its
# verdict line.
audit() {
	local d k=0 i
	for d in "$STORE/briefs/$1"/plan.r*; do
		i=${d##*/plan.r}
		if [ "$i" -gt "$k" ]; then k=$i; fi
	done
	if grep -rq '365 days' "$STORE/briefs/$1/plan.r$k"; then echo 'CONFLICTS: 1'; else echo 'NO CONFLICT'; fi
}
# project_plan <repo> <project>: glab:project-planner's plan from the brief, its brief line holding the hash
# of the brief as it read it.
project_plan() {
	mkdir -p "$1/$SLUG"
	sed "s/<brief-sha256>/$(h256 <"$STORE/briefs/$2/brief.md")/; s/notes-api/$2/g" "$FX/project-plan/master.md" >"$1/$SLUG/master.md"
	cp "$FX/project-plan/plan.md" "$1/$SLUG/plan.md"
}

# The manager each text names. The backticks are the text's own Markdown, not a command.
# shellcheck disable=SC2016
PRODUCT_MGR='`glab:product-manager` — the operating model of the product level' PROJECT_MGR='`glab:project-manager` — the operating model of the project level' ANY_PROJECT_MGR='`glab:project-manager` — the operating model'

HERE=$PRODUCT
scene L1 'the glab SessionStart hook, in the product repo' 'AGENTS.md says glab-level: product, so the session loads the product manager.'
t=$(start "$PRODUCT")
say "    $(printf '%s\n' "$t" | head -n 1)"
case $t in *"$PRODUCT_MGR"*) ;; *) bad "the product session is not told to load glab:product-manager" ;; esac
case $t in *"$ANY_PROJECT_MGR"*) bad "the product session is told to load glab:project-manager" ;; esac
done_case L1 "a product repo's session start names glab:product-manager"

scene L2 'the glab SessionStart hook, in the project repo' 'No glab-level line: the project level, today'"'"'s glab:project-manager.'
t=$(start "$PROJECT")
say "    $(printf '%s\n' "$t" | head -n 1)"
case $t in *"$PROJECT_MGR"*) ;; *) bad "the project session is not told to load glab:project-manager" ;; esac
done_case L2 "a project repo's session start names glab:project-manager"

scene L3 'glab:product-planner, then the user, then glab:product-planner' 'The business plan becomes a product plan; the user approves it; the rules it drafted go to the store.'
mkdir -p "$PRODUCT/plan/notes-app" "$STORE/docs/product-rules"
cp "$FX/business-plan.md" "$PRODUCT/business-plan.md"
cp "$FX/product-plan.md" "$PRODUCT/plan/notes-app/product-plan.md"
printf '\n## Approval\n\n- approved by the user, 2026-11-13, in chat: "approved"\n' >>"$PRODUCT/plan/notes-app/product-plan.md"
say "--- wrote plan/notes-app/product-plan.md in the product repo, then its ## Approval line"
[ -z "$SHOW" ] || sed 's/^/    | /' "$PRODUCT/plan/notes-app/product-plan.md" >&2
cp "$FX/product-rules/"*.md "$STORE/docs/product-rules/"
for f in "$STORE/docs/product-rules/"*.md; do
	b=$(basename "$f")
	[ "$b" = index.md ] && continue
	[ "$(wc -c <"$f")" -le 8192 ] || bad "$b is over 8192 bytes"
	[ "$(grep -c "^- $b — " "$STORE/docs/product-rules/index.md")" -eq 1 ] || bad "$b is not on exactly one index line"
done
done_case L3 "the rules and their index in the store, each rule at most 8192 bytes and on one index line"

scene L4 'glab:product-planner, through glab:product-project-brief' 'One brief per project; it names the rule files that apply.'
mkdir -p "$STORE/$BR"
cp "$FX/brief.md" "$STORE/$BR/brief.md"
while IFS= read -r r; do
	[ -f "$STORE/$r" ] || bad "the brief names $r, which is not in the store"
done < <(grep -o 'docs/product-rules/[a-z0-9-]*\.md' "$STORE/$BR/brief.md")
done_case L4 "the brief names rule files that exist"

HERE=$PROJECT
scene L5 'glab:project-planner in the project session, told "take the brief at <store>/briefs/notes-api/brief.md"' 'The plan quotes the brief with its hash; glab:project-develop'"'"'s check refuses before any report.'
project_plan "$PROJECT" notes-api
say "--- wrote $SLUG/master.md and plan.md in the project repo"
[ -z "$SHOW" ] || sed 's/^/    | /' "$PROJECT/$SLUG/master.md" "$PROJECT/$SLUG/plan.md" >&2
grep -qE '^- brief: briefs/notes-api/brief\.md sha256 [0-9a-f]{64}$' "$PROJECT/$SLUG/master.md" || bad "no brief line"
no_gate 'no verdict for this brief' check "$SLUG" "$STORE"
done_case L5 "the project plan carries the brief line, and check refuses before any report"

scene L6 'the project manager, Stage 1c, through glab:project-plan-report' 'After the approvals the plan is reported to product; the session then waits.'
ok_gate report "$SLUG" "$STORE"
ok_gate digest "$STORE/$BR/plan.r1"
grep -qx "plan-sha256: $OUT" "$STORE/$BR/report.r1.md" || bad "the copies' digest is not the report's"
done_case L6 "report r1, its copies' digest equal to the report's"

scene L7 'the project manager, reporting again too early' 'A second report while r1 waits for its verdict.'
no_gate 'report r1 has no verdict yet' report "$SLUG" "$STORE"
done_case L7 "a second report while r1 waits is refused"

HERE=$PRODUCT
scene L8 'glab:product-analyzer, then the product manager through glab:product-project-plan-verdict' 'The audit holds the copy to the rules the brief names; one conflict, so REJECTED with its reason.'
a=$(audit notes-api)
say "    audit: $a"
[ "$a" = 'CONFLICTS: 1' ] || bad "the audit gave [$a], not CONFLICTS: 1"
ok_gate verdict "$STORE" notes-api REJECTED product-manager "$FX/reasons/r1-rejected.md"
if ! { grep -qx 'verdict: REJECTED' "$STORE/$BR/verdict.r1.md" && grep -q '365 days' "$STORE/$BR/verdict.r1.md"; }; then
	bad "verdict r1 is not REJECTED with its reason"
fi
done_case L8 "the audit finds CONFLICTS: 1, and verdict r1 is REJECTED with its reason"

HERE=$PROJECT
scene L9 'glab:project-develop in the project session' 'Development may not start on a REJECTED plan.'
no_gate 'the latest verdict r1 is REJECTED' check "$SLUG" "$STORE"
done_case L9 "check refuses after REJECTED"

scene L10 'a new glab:project-planner amends; the project manager reports r2; the product audits and accepts' 'The round copy is kept; the step now keeps logs 90 days.'
cp "$PROJECT/$SLUG/plan.md" "$PROJECT/$SLUG/plan.r1.md"
sed 's/365 days/90 days/' "$PROJECT/$SLUG/plan.r1.md" >"$PROJECT/$SLUG/plan.md"
say "    the amendment: $(grep 'days' "$PROJECT/$SLUG/plan.md")"
ok_gate report "$SLUG" "$STORE"
HERE=$PRODUCT
a=$(audit notes-api)
say "    audit: $a"
[ "$a" = 'NO CONFLICT' ] || bad "the audit of r2 gave [$a]"
ok_gate verdict "$STORE" notes-api ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
grep -qx 'verdict: ACCEPTED' "$STORE/$BR/verdict.r2.md" || bad "verdict r2 is not ACCEPTED"
done_case L10 "the amended plan, report r2, verdict r2 ACCEPTED"

HERE=$PROJECT
scene L11 'glab:project-develop in the project session' 'The accepted plan matches its verdict: development may start.'
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r2 '*) ;; *) bad "check printed [$OUT]" ;; esac
done_case L11 "check passes: development may start"

scene L12 'the project manager, recording after the verdict' 'A model line and a round-3 line go to after-verdict.md, outside the hash.'
printf -- '- model: glab:project-developer opus, for this task — the user'"'"'s instruction: "use opus for the developer"\n- round 3: analyze — high S1 the job does not run\n' >"$PROJECT/$SLUG/after-verdict.md"
ok_gate check "$SLUG" "$STORE"
done_case L12 "bookkeeping in after-verdict.md: check still passes"

scene L13 'the project manager, after a PLAN WRONG amendment of a step' 'An edited step is a changed plan: refused, reported again, accepted again.'
printf '\n### S3 — a health route\n\nServe /v1/health.\n' >>"$PROJECT/$SLUG/plan.md"
no_gate 'the plan changed since verdict r2 accepted it; report again' check "$SLUG" "$STORE"
ok_gate report "$SLUG" "$STORE"
HERE=$PRODUCT
ok_gate verdict "$STORE" notes-api ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
HERE=$PROJECT
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r3 '*) ;; *) bad "check after r3 printed [$OUT]" ;; esac
done_case L13 "plan.md edited after acceptance: check refuses; report r3, verdict r3 ACCEPTED, check passes"

HERE=$PRODUCT
scene L14 'the product manager edits the brief after acceptance' 'A plan answers the brief it read: the project must plan again.'
printf '\nAlso: export notes as Markdown.\n' >>"$STORE/$BR/brief.md"
HERE=$PROJECT
no_gate 'the brief changed since the plan was written; plan again' check "$SLUG" "$STORE"
done_case L14 "the brief edited after acceptance: check refuses"

WEB=$W/notes-web-repo
mkdir -p "$WEB"
printf '# Working agreement — the notes-web repo\n\nglab-shared-store: <store>\n' >"$WEB/AGENTS.md"

HERE=$PRODUCT
scene L15 'a second project, notes-web: two rejections, then the user decides' 'At the cap the product manager can write no verdict; only the user'"'"'s decision, in the user'"'"'s words, is written.'
mkdir -p "$STORE/briefs/notes-web"
cp "$FX/brief-web.md" "$STORE/briefs/notes-web/brief.md"
SLUG=plan/notes-web-v1
project_plan "$WEB" notes-web
for k in 1 2; do
	HERE=$WEB
	[ "$k" -eq 1 ] || printf '\nAmended, round %s.\n' "$k" >>"$WEB/$SLUG/plan.md"
	ok_gate report "$SLUG" "$STORE"
	HERE=$PRODUCT
	ok_gate verdict "$STORE" notes-web REJECTED product-manager "$FX/reasons/r1-rejected.md"
done
HERE=$WEB
printf '\nAmended, round 3.\n' >>"$WEB/$SLUG/plan.md"
ok_gate report "$SLUG" "$STORE"
HERE=$PRODUCT
no_gate 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$STORE" notes-web REJECTED product-manager "$FX/reasons/r1-rejected.md"
no_gate 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$STORE" notes-web ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
ok_gate verdict "$STORE" notes-web ACCEPTED user "$FX/reasons/user-accepted.md"
grep -qx 'by: user' "$STORE/briefs/notes-web/verdict.r3.md" || bad "verdict r3 is not by user"
HERE=$WEB
ok_gate check "$SLUG" "$STORE"
done_case L15 "a second project: two REJECTED, then product-manager refused either way, the user's ACCEPTED written, check passes"

HERE=$PROJECT
SLUG=plan/notes-api-v2
scene L16 'glab:project-planner in the notes-api session, the changed brief planned again as two sub-plans' 'The master and every sub-plan are planned, checked and approved before one report covers them all; each sub-plan'"'"'s glab:project-develop checks that one verdict, and a sub-plan added later is a changed plan.'
project_plan "$PROJECT" notes-api
rm "$PROJECT/$SLUG/plan.md"
printf '# Index — notes-api-v2\n\n- 01-log · goals G2 · depends none · tier full\n- 02-routes · goals G1 · depends 01-log · tier full\n' >"$PROJECT/$SLUG/index.md"
mkdir -p "$PROJECT/$SLUG/01-log" "$PROJECT/$SLUG/02-routes"
sed 's/365 days/90 days/' "$FX/project-plan/plan.md" >"$PROJECT/$SLUG/01-log/plan.md"
cp "$PROJECT/$SLUG/01-log/plan.md" "$PROJECT/$SLUG/02-routes/plan.md"
# 01-log's own plan check took two rounds: its round copy is kept, and is not hashed.
cp "$PROJECT/$SLUG/01-log/plan.md" "$PROJECT/$SLUG/01-log/plan.r1.md"
say "--- wrote $SLUG/master.md, index.md, 01-log/plan.md and 02-routes/plan.md in the project repo"
ok_gate report "$SLUG" "$STORE"
grep -qx 'files: 4' "$STORE/$BR/report.r4.md" || bad "report r4 does not hash the master, the index and both sub-plans"
{ [ -f "$STORE/$BR/plan.r4/01-log/plan.md" ] && [ -f "$STORE/$BR/plan.r4/02-routes/plan.md" ]; } || bad "the copies of r4 lack a sub-plan"
HERE=$PRODUCT
a=$(audit notes-api)
say "    audit: $a"
[ "$a" = 'NO CONFLICT' ] || bad "the audit of r4 gave [$a]"
ok_gate verdict "$STORE" notes-api ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
HERE=$PROJECT
say "    01-log's glab:project-develop:"
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r4 '*) ;; *) bad "check for 01-log printed [$OUT]" ;; esac
printf 'S1 done\n' >"$PROJECT/$SLUG/01-log/result.md"
say "    01-log built and committed; 02-routes's glab:project-develop:"
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r4 '*) ;; *) bad "check for 02-routes printed [$OUT]" ;; esac
mkdir -p "$PROJECT/$SLUG/03-health"
cp "$PROJECT/$SLUG/02-routes/plan.md" "$PROJECT/$SLUG/03-health/plan.md"
say "    a sub-plan 03-health planned after the report:"
no_gate 'the plan changed since verdict r4 accepted it; report again' check "$SLUG" "$STORE"
done_case L16 "a plan from a brief with sub-plans: one report r4 for the slug, both sub-plans checked against verdict r4, a later sub-plan refused"

scene L17 'the store, at the end' 'Only the agreed folders were written, and no temporary file is left.'
others=$(cd "$STORE" && find . -mindepth 1 -maxdepth 1 ! -name docs ! -name briefs)
[ -z "$others" ] || bad "written outside docs/ and briefs/: $others"
left=$(find "$STORE" -name '.plan-gate.*')
[ -z "$left" ] || bad "temporary files left: $left"
say "    $(cd "$STORE" && find . -type f | LC_ALL=C sort | tr '\n' ' ')"
done_case L17 "nothing was written in the store outside docs/ and briefs/"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
