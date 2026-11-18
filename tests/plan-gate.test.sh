#!/usr/bin/env bash
# Exercises plan-gate.sh against plan folders and stores written here, under $TMPDIR; it never
# touches a real shared store. Each case builds its own store and plan folder, so no case depends on
# another case's files. T22 is judged last, over every store the cases wrote.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to plan-gate.sh>" >&2; exit 2; }
# Absolute, because every run below starts from the work directory.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/plan-gate-test.XXXXXX") || exit 1
# T33, T37 and T48 each start two runs in the background and wait for both, and T45 a parent that
# keeps a zombie; BG holds those PIDs while they may run. In T47 a stub starts a second run in the
# background and records its PID in $C/pid2, which joins BG only once the first run is back: a test
# killed while the first run waits in that stub, up to 10 s, does not kill the second, which ends on
# its own once its date stub stops waiting, 10 s at most. The trap kills only the PIDs in BG, should
# the test end first, then removes the work directory.
BG=''
trap 'for p in $BG; do kill "$p" 2>/dev/null; done; rm -rf "$W"' EXIT
cd "$W" || exit 1

pass=0 fail=0 n=0
reason='' # why the current case failed; empty while it holds
OUT='' ERR='' RC=0
bad() { reason="${reason:+$reason; }$*"; }
done_case() { # done_case <id> <name>
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

# h256: the sha256 of stdin, with whichever tool the host has - the test hashes briefs the way the
# planner does, independently of the script under test.
h256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -c1-64; }
# gate <args...>: runs the script; sets OUT, ERR and RC.
gate() {
	OUT=$(bash "$SCRIPT" "$@" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
}
# snap <dir>: every path under dir and every file's checksum, to show that a refusal wrote nothing.
snap() { (cd "$1" && find . | LC_ALL=C sort && find . -type f -exec cksum {} + | LC_ALL=C sort); }
# refused <line> <args...>: the run is refused with exactly that line, prints nothing on stdout, and
# leaves the case's store and plan folder as they were.
refused() {
	local line=$1 before
	shift
	before=$(snap "$C")
	gate "$@"
	[ "$RC" -eq 1 ] || bad "rc=$RC, not 1, for [$*]"
	[ -z "$OUT" ] || bad "stdout not empty: [$OUT]"
	[ "$ERR" = "REFUSED: $line" ] || bad "stderr [$ERR] is not [REFUSED: $line]"
	[ "$before" = "$(snap "$C")" ] || bad "the refusal of [$*] wrote something"
}
# ran <args...>: the run succeeds with empty stderr.
ran() {
	gate "$@"
	[ "$RC" -eq 0 ] || bad "rc=$RC for [$*]: [$ERR]"
	[ -z "$ERR" ] || bad "stderr not empty for [$*]: [$ERR]"
}

# newcase <id>: a fresh store $S, plan folder $P and reason files under $C.
newcase() {
	C=$W/$1
	S=$C/store P=$C/plan
	mkdir -p "$S" "$P"
	printf 'No conflict with docs/product-rules/data-retention.md.\n' >"$C/ok"
	printf 'S1 keeps request logs 365 days; docs/product-rules/data-retention.md allows 90.\n' >"$C/no"
	printf 'user: "accept it, the 365 days are approved for this project"\n' >"$C/user"
}
# brief <project> <text>: writes the project's brief in the store.
brief() { mkdir -p "$S/briefs/$1" && printf '# Brief — %s\n\n## Goal\n\n%s\n' "$1" "$2" >"$S/briefs/$1/brief.md"; }
# plan_for <project>: master.md quoting the brief's line for the brief as it is now, and a plan.md
# when there is none yet.
plan_for() {
	printf '# Master\n\n## Request\n\n- brief: briefs/%s/brief.md sha256 %s\n\n## Goals\n\n- G1 — request logs are kept\n' \
		"$1" "$(h256 <"$S/briefs/$1/brief.md")" >"$P/master.md"
	[ -f "$P/plan.md" ] || printf 'tier: full — test\n\n# Plan\n\n## Decisions\n\n- one\n\n### S1\n\nKeep request logs 365 days.\n' >"$P/plan.md"
}
# loop_case <id> <project>: a case with a brief and a plan made from it.
loop_case() { newcase "$1" && brief "$2" 'Store notes.' && plan_for "$2"; }
B=briefs/notes-api
# round <verdict> <by> <reason file>: report the plan, then decide it.
round() { ran report "$P" "$S" && ran verdict "$S" notes-api "$1" "$2" "$3"; }

# T1
loop_case t1 notes-api
ran digest "$P"
printf '%s\n' "$OUT" | grep -qxE '[0-9a-f]{64}' || bad "digest [$OUT] is not 64 hex characters"
done_case T1 "digest prints 64 hex characters, exit 0"

# T2
loop_case t2 notes-api
printf 'x\n' >"$P/steps-1.md"
gate digest "$P"
d=$OUT
mkdir -p "$P/plan.r1" "$P/01-a"
for f in evidence.md steps-1.r1.md plan.r1.md plan.r10.md master.v1.md result.md map-x.md after-verdict.md integration.md plan.r1/plan.md plan.r1/master.md 01-a/plan.r2.md; do printf 'not the contract\n' >"$P/$f"; done
gate digest "$P"
[ "$OUT" = "$d" ] || bad "a round copy, version copy, copy folder or working file moved the digest"
done_case T2 "digest ignores round copies, version copies, plan.r<n>/, evidence, maps, results, after-verdict.md"

# T3
loop_case t3 notes-api
gate digest "$P"
seen=$OUT
# change <k>: the k-th edit, each to one hashed file.
change() {
	case $1 in
	1) mkdir -p "$P/01-a" && printf a >"$P/01-a/plan.md" ;;
	2) printf a >"$P/steps-1.md" ;;
	3) printf a >"$P/questions.md" ;;
	4) printf a >"$P/index.md" ;;
	5) printf a >>"$P/plan.md" ;;
	6) printf a >>"$P/master.md" ;;
	7) printf b >>"$P/01-a/plan.md" ;;
	esac
}
for k in 1 2 3 4 5 6 7; do
	change "$k"
	gate digest "$P"
	case " $seen " in *" $OUT "*) bad "no new digest after edit $k" ;; esac
	seen="$seen $OUT"
done
done_case T3 "an edit to master.md, index.md, plan.md, a sub-plan's plan.md, steps-*.md or questions.md changes it"

# T4
loop_case t4 notes-api
ran report "$P" "$S"
gate digest "$S/$B/plan.r1"
c=$OUT
gate digest "$P"
[ "$c" = "$OUT" ] || bad "the copy's digest [$c] is not the plan's [$OUT]"
grep -qx "plan-sha256: $OUT" "$S/$B/report.r1.md" || bad "the report does not carry the plan's digest"
done_case T4 "the copy report makes in plan.r1/ has the plan's digest"

# T5
newcase t5
gate digest "$C/none"
[ "$RC" -eq 2 ] && [ "$ERR" = "plan-gate.sh: no such folder: $C/none" ] || bad "rc=$RC stderr [$ERR]"
done_case T5 "digest of a missing folder exits 2"

# T6
loop_case t6 notes-api
printf 'Two projects share the notes table.\n' >"$C/note"
ran report "$P" "$S" "$C/note"
[ "$OUT" = "$S/$B/report.r1.md" ] || bad "stdout [$OUT] is not the report's path"
gate digest "$P"
want=$(printf '# Plan report r1 — notes-api\nreport: r1\nplan-sha256: %s\nbrief-sha256: %s\nfiles: 2\n' "$OUT" "$(h256 <"$S/$B/brief.md")")
[ "$(head -n 5 "$S/$B/report.r1.md")" = "$want" ] || bad "the report's first lines are [$(head -n 5 "$S/$B/report.r1.md")]"
sed -n 6p "$S/$B/report.r1.md" | grep -qxE 'date: [0-9]{4}-[0-9]{2}-[0-9]{2}' || bad "no date line"
[ "$(tail -n 3 "$S/$B/report.r1.md")" = "$(printf '\n## Note\nTwo projects share the notes table.')" ] || bad "the note is not under ## Note"
[ -f "$S/$B/plan.r1/master.md" ] && [ -f "$S/$B/plan.r1/plan.md" ] || bad "plan.r1/ lacks the hashed files"
done_case T6 "report writes report.r1.md with its lines in order, the note, and plan.r1/"

# T7
loop_case t7 notes-api
ran report "$P" "$S"
refused 'report r1 has no verdict yet' report "$P" "$S"
done_case T7 "a second report while r1 has no verdict is refused and writes nothing"

# T8
loop_case t8 notes-api
brief notes-api 'Store notes and tags.'
refused 'the brief changed since the plan was written; plan again' report "$P" "$S"
done_case T8 "report after the brief changed is refused"

# T9
loop_case t9 notes-api
printf '# Master\n\n## Request\n\nno brief\n' >"$P/master.md"
refused 'no brief line in master.md' report "$P" "$S"
done_case T9 "report with no brief line is refused"

# T10
loop_case t10 notes-api
ran report "$P" "$S"
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$OUT" = "$S/$B/verdict.r1.md" ] || bad "stdout [$OUT] is not the verdict's path"
want=$(printf 'verdict: ACCEPTED\nreport: r1\n%s\nbrief-sha256: %s\nby: product-manager\n' "$(grep '^plan-sha256: ' "$S/$B/report.r1.md")" "$(h256 <"$S/$B/brief.md")")
[ "$(head -n 5 "$S/$B/verdict.r1.md")" = "$want" ] || bad "the verdict's first lines are [$(head -n 5 "$S/$B/verdict.r1.md")]"
[ "$(tail -n 3 "$S/$B/verdict.r1.md")" = "$(printf '\n## Reason\nNo conflict with docs/product-rules/data-retention.md.')" ] || bad "the reason is not under ## Reason"
done_case T10 "verdict ACCEPTED writes its lines in order and the reason"

# T11
loop_case t11 notes-api
ran report "$P" "$S"
printf 'edited\n' >>"$S/$B/plan.r1/plan.md"
refused 'the copies in plan.r1/ do not match report r1' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T11 "verdict over tampered copies is refused"

# T12
loop_case t12 notes-api
ran report "$P" "$S"
brief notes-api 'Store notes and tags.'
refused 'the brief changed since report r1' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T12 "verdict after the brief changed is refused"

# T13
loop_case t13 notes-api
round ACCEPTED product-manager "$C/ok"
refused 'report r1 already has a verdict' verdict "$S" notes-api REJECTED product-manager "$C/no"
done_case T13 "a second verdict for one report is refused"

# T14
loop_case t14 notes-api
ran report "$P" "$S"
printf ' \n\t\n' >"$C/empty"
refused 'empty reason' verdict "$S" notes-api REJECTED product-manager "$C/empty"
done_case T14 "an empty or blank reason is refused"

# T15
loop_case t15 notes-api
round REJECTED product-manager "$C/no"
printf 'amended\n' >>"$P/plan.md"
round REJECTED product-manager "$C/no"
printf 'amended again\n' >>"$P/plan.md"
ran report "$P" "$S"
refused 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$S" notes-api REJECTED product-manager "$C/no"
refused 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
refused "a verdict by user starts its reason with the user's words: user: \"<words>\"" verdict "$S" notes-api ACCEPTED user "$C/ok"
ran verdict "$S" notes-api ACCEPTED user "$C/user"
if ! { grep -qx 'by: user' "$S/$B/verdict.r3.md" && grep -qx 'user: "accept it, the 365 days are approved for this project"' "$S/$B/verdict.r3.md"; }; then
	bad "verdict r3 does not carry by: user and the user's words"
fi
done_case T15 "after two REJECTED: REJECTED and ACCEPTED by product-manager refused, by user without words refused, with words written"

# T16
loop_case t16 notes-api
round REJECTED product-manager "$C/no"
printf 'amended\n' >>"$P/plan.md"
round REJECTED product-manager "$C/no"
brief notes-api 'Store notes; logs 365 days allowed.'
plan_for notes-api
ran report "$P" "$S"
refused 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T16 "a new brief does not reset the count"

# T17
loop_case t17 notes-api
round ACCEPTED product-manager "$C/ok"
gate digest "$P"
d=$OUT
ran check "$P" "$S"
[ "$OUT" = "ACCEPTED r1 $d" ] || bad "stdout [$OUT] is not [ACCEPTED r1 $d]"
done_case T17 "check after ACCEPTED prints ACCEPTED r1 <digest>, exit 0"

# T18
loop_case t18 notes-api
round ACCEPTED product-manager "$C/ok"
printf 'one more step\n' >>"$P/plan.md"
refused 'the plan changed since verdict r1 accepted it; report again' check "$P" "$S"
done_case T18 "check after a plan.md edit is refused, exit 1"

# T19
loop_case t19 notes-api
refused 'no verdict for this brief' check "$P" "$S"
ran report "$P" "$S"
refused 'report r1 has no verdict yet' check "$P" "$S"
ran verdict "$S" notes-api REJECTED product-manager "$C/no"
refused 'the latest verdict r1 is REJECTED' check "$P" "$S"
printf 'amended\n' >>"$P/plan.md"
round ACCEPTED product-manager "$C/ok"
brief notes-api 'Store notes and tags.'
refused 'the brief changed since the plan was written; plan again' check "$P" "$S"
plan_for notes-api
refused 'no verdict for this brief' check "$P" "$S"
done_case T19 "check refuses: no verdict, a report waiting, the latest REJECTED, the brief changed, a verdict for an older brief"

# T20
newcase t20
usage_ok() { if [ "$RC" -ne 2 ] || [ "${ERR#usage: plan-gate.sh }" = "$ERR" ]; then bad "[$1]: rc=$RC stderr [$ERR]"; fi; }
for args in '' 'nomode' 'digest' 'report x' 'check x' 'verdict a b ACCEPTED product-manager' 'verdict S p MAYBE product-manager r' \
	'verdict S p ACCEPTED someone r' 'verdict S Notes ACCEPTED user r' 'digest a b'; do
	# shellcheck disable=SC2086 # the words are the arguments
	gate $args
	usage_ok "$args"
done
done_case T20 "an unknown mode, wrong arguments or a bad word exit 2 with the usage line"

# T21
loop_case t21 notes-api
if command -v shasum >/dev/null 2>&1; then
	mkdir -p "$C/bin"
	for t in bash cat chmod cp cut date dirname find grep head awk mkdir mktemp mv rm sort tr wc shasum; do
		p=$(command -v "$t") && ln -s "$p" "$C/bin/$t"
	done
	gate digest "$P"
	d=$OUT
	OUT=$(PATH=$C/bin bash "$SCRIPT" digest "$P" 2>"$W/err")
	[ "$OUT" = "$d" ] || bad "shasum gave [$OUT], sha256sum [$d]: [$(cat "$W/err")]"
	[ -z "$(PATH=$C/bin command -v sha256sum)" ] || bad "sha256sum is still on the test PATH"
	done_case T21 "with shasum and no sha256sum on PATH, the same digest"
else
	done_case T21 "with shasum and no sha256sum on PATH, the same digest (skipped: no shasum)"
fi

# T23
loop_case t23 notes-api
round ACCEPTED product-manager "$C/ok"
cp "$P/plan.md" "$P/plan.r1.md"
printf -- '- model: glab:project-developer opus, for this task — the user'"'"'s instruction: "use opus"\n- round 3: analyze — high S1\n' >"$P/after-verdict.md"
ran check "$P" "$S"
case $OUT in 'ACCEPTED r1 '*) ;; *) bad "check after bookkeeping printed [$OUT]" ;; esac
done_case T23 "after ACCEPTED, after-verdict.md lines and a round copy leave check passing"

# T24
loop_case t24 notes-api
round ACCEPTED product-manager "$C/ok"
cp "$S/$B/verdict.r1.md" "$C/v1"
# spoil <k>: verdict.r1.md spoiled the k-th way - a repeated verdict line, a hash that is not hex,
# the wrong report, no reason.
spoil() {
	case $1 in
	1) awk '{ print } /^by: / { print "verdict: REJECTED" }' "$C/v1" ;;
	2) awk '/^plan-sha256: / { print "plan-sha256: not-hex"; next } { print }' "$C/v1" ;;
	3) awk '/^report: r1$/ { print "report: r2"; next } { print }' "$C/v1" ;;
	4) awk '/^## Reason$/ { exit } { print }' "$C/v1" ;;
	esac >"$S/$B/verdict.r1.md"
}
for k in 1 2 3 4; do
	spoil "$k"
	refused 'verdict r1 is malformed' check "$P" "$S"
done
spoil 1
printf 'amended\n' >>"$P/plan.md"
ran report "$P" "$S"
refused 'verdict r1 is malformed' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
grep -v '^files: ' "$S/$B/report.r2.md" >"$C/r2" && mv "$C/r2" "$S/$B/report.r2.md"
refused 'report r2 is malformed' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T24 "a malformed verdict or report is refused: a repeated line, a non-hex hash, the wrong report, no reason"

# T25
loop_case t25 notes-api
for i in 1 2 3 4 5 6 7 8 9; do
	round ACCEPTED product-manager "$C/ok"
	printf 'step %s\n' "$i" >>"$P/plan.md"
done
round REJECTED product-manager "$C/no"
refused 'the latest verdict r10 is REJECTED' check "$P" "$S"
printf 'amended\n' >>"$P/plan.md"
ran report "$P" "$S"
[ "$OUT" = "$S/$B/report.r11.md" ] || bad "the report after r10 is [$OUT]"
done_case T25 "r10 is read after r9, and the next report is r11"

# T26
loop_case t26 notes-api
round REJECTED product-manager "$C/no"
printf 'a\n' >>"$P/plan.md"
round REJECTED product-manager "$C/no"
printf 'b\n' >>"$P/plan.md"
round ACCEPTED user "$C/user"
printf 'c\n' >>"$P/plan.md"
round REJECTED product-manager "$C/no"
[ -f "$S/$B/verdict.r4.md" ] || bad "no verdict r4 after the user's ACCEPTED"
done_case T26 "an ACCEPTED ends the count: the next REJECTED by product-manager is written"

# T27
loop_case t27 notes-api
ran report "$P" "$S"
printf 'verdict: ACCEPTED\nThe plan would be accepted with 90 days.\n' >"$C/quote"
ran verdict "$S" notes-api REJECTED product-manager "$C/quote"
refused 'the latest verdict r1 is REJECTED' check "$P" "$S"
done_case T27 "a reason that quotes 'verdict: ACCEPTED' does not change the verdict"

# T28
loop_case t28 notes-api
round REJECTED product-manager "$C/no"
mkdir "$S/$B/plan.r2"
refused 'plan.r2/ is there without report r2; look at it and remove it by hand' report "$P" "$S"
done_case T28 "a copy folder left without its report is refused, not removed"

# T29
loop_case t29 notes-api
awk '{ printf "%s\r\n", $0 }' "$P/master.md" >"$C/crlf" && mv "$C/crlf" "$P/master.md"
ran report "$P" "$S"
[ -f "$S/$B/report.r1.md" ] || bad "a CRLF master.md gave no report"
done_case T29 "a brief line in a CRLF master.md is read"

# T30
loop_case t30 notes-api
round ACCEPTED product-manager "$C/ok"
printf 'Keep request logs 365 days.\n' >"$C/other.md"
mkdir -p "$P/02-evil" && ln -s "$C/other.md" "$P/02-evil/plan.md"
link='the plan folder holds a symlink, ./02-evil/plan.md; links are not followed - replace it with the file'
refused "$link" check "$P" "$S"
refused "$link" digest "$P"
printf 'amended\n' >>"$P/plan.md"
refused "$link" report "$P" "$S"
done_case T30 "a symlinked file in the plan folder is refused by check, digest and report"

# T31
loop_case t31 notes-api
round ACCEPTED product-manager "$C/ok"
mkdir -p "$C/elsewhere" && printf 'Keep request logs 365 days.\n' >"$C/elsewhere/plan.md"
ln -s "$C/elsewhere" "$P/03-evil"
link='the plan folder holds a symlink, ./03-evil; links are not followed - replace it with the file'
refused "$link" check "$P" "$S"
refused "$link" digest "$P"
printf 'amended\n' >>"$P/plan.md"
refused "$link" report "$P" "$S"
done_case T31 "a symlinked folder in the plan folder is refused by check, digest and report"

# T32
loop_case t32 notes-api
ran report "$P" "$S"
printf 'Keep request logs 365 days.\n' >"$C/other.md"
mkdir -p "$S/$B/plan.r1/02-evil" && ln -s "$C/other.md" "$S/$B/plan.r1/02-evil/plan.md"
refused 'the copies in plan.r1/ do not match report r1' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T32 "a symlink in the copy folder is refused by verdict"

# T33
loop_case t33 notes-api
ran report "$P" "$S"
# A date that waits a second first: the run that got the claim on r1 holds it while it waits, and
# the other, past every check by then, finds it taken. date, not mktemp: verdict no longer calls
# mktemp (plan-gate.sh, claimed_tmp).
mkdir -p "$C/bin"
printf '#!/usr/bin/env bash\nsleep 1\nexec %s "$@"\n' "$(command -v date)" >"$C/bin/date" && chmod +x "$C/bin/date"
PATH=$C/bin:$PATH bash "$SCRIPT" verdict "$S" notes-api REJECTED product-manager "$C/no" >"$C/o1" 2>"$C/e1" &
p1=$!
BG=$p1
PATH=$C/bin:$PATH bash "$SCRIPT" verdict "$S" notes-api ACCEPTED product-manager "$C/ok" >"$C/o2" 2>"$C/e2" &
p2=$!
BG="$p1 $p2"
wait "$p1"
r1=$?
wait "$p2"
r2=$?
BG=''
case "$r1 $r2" in
'0 1') won=REJECTED lost=2 ;;
'1 0') won=ACCEPTED lost=1 ;;
*) won='' lost='' && bad "the two runs exited $r1 and $r2, not one 0 and one 1: [$(cat "$C/e1" "$C/e2")]" ;;
esac
if [ -n "$won" ]; then
	[ "$(cat "$C/e$lost")" = "REFUSED: another run is writing verdict r1; when no run is writing, remove $S/$B/.plan-gate.claim.verdict.r1 by hand" ] || bad "the losing run said [$(cat "$C/e$lost")]"
	[ -z "$(cat "$C/o$lost")" ] || bad "the losing run printed [$(cat "$C/o$lost")]"
	grep -qx "verdict: $won" "$S/$B/verdict.r1.md" || bad "verdict.r1.md is not the winning run's $won"
fi
done_case T33 "two verdicts on one report at once: one is written, the other refused"

# T34
loop_case t34 notes-api
mkdir -p "$P/01-a" && printf 'x\n' >"$P/01-a/plan.md"
(umask 077 && bash "$SCRIPT" report "$P" "$S" >/dev/null 2>&1 && bash "$SCRIPT" verdict "$S" notes-api ACCEPTED product-manager "$C/ok" >/dev/null 2>&1) ||
	bad "report or verdict under umask 077 failed"
[ -f "$S/$B/plan.r1/01-a/plan.md" ] || bad "plan.r1/ lacks the sub-plan's plan.md"
shut=$(cd "$S/$B" && find plan.r1 report.r1.md verdict.r1.md \( -type f ! -perm -004 \) -o \( -type d ! -perm -005 \))
[ -z "$shut" ] || bad "not readable by another account: $(printf '%s' "$shut" | tr '\n' ' ')"
done_case T34 "under umask 077 the copy, its folders, the report and the verdict are readable by every account"

# T35
loop_case t35 notes-api
ran report "$P" "$S"
gate verdict "$S" "$(printf 'notes-api\n../x')" ACCEPTED product-manager "$C/ok"
usage_ok 'a project name with a newline'
[ ! -e "$S/$B/verdict.r1.md" ] || bad "a verdict was written"
done_case T35 "a project name with a newline exits 2 with the usage line"

# T36
loop_case t36 notes-api
round ACCEPTED product-manager "$C/ok"
grep '^- brief: ' "$P/master.md" >"$P/waived.md"
rm "$P/master.md" "$P/plan.md"
refused 'no brief line in master.md' check "$P" "$S"
done_case T36 "a waived.md made from a brief, with no master.md, is refused by check"

# T37
loop_case t37 notes-api
# A mkdir that waits a second before the copy folder's mkdir (mkdir -p does not wait): the run that
# got the claim on r1 holds it while it waits, and the other, past every check by then, finds it
# taken. While mkdir was the claim, both runs wrote into one folder in 10 of 20 such runs on a host
# with uutils mkdir (plan-gate.sh, claim).
mkdir -p "$C/bin"
# shellcheck disable=SC2016 # $1 is the stub's own argument, expanded when the stub runs
printf '#!/usr/bin/env bash\ncase $1 in -p) ;; *) sleep 1 ;; esac\nexec %s "$@"\n' "$(command -v mkdir)" >"$C/bin/mkdir" && chmod +x "$C/bin/mkdir"
PATH=$C/bin:$PATH bash "$SCRIPT" report "$P" "$S" >"$C/o1" 2>"$C/e1" &
p1=$!
BG=$p1
PATH=$C/bin:$PATH bash "$SCRIPT" report "$P" "$S" >"$C/o2" 2>"$C/e2" &
p2=$!
BG="$p1 $p2"
wait "$p1"
r1=$?
wait "$p2"
r2=$?
BG=''
case "$r1 $r2" in
'0 1') won=1 lost=2 ;;
'1 0') won=2 lost=1 ;;
*) won='' lost='' && bad "the two runs exited $r1 and $r2, not one 0 and one 1: [$(cat "$C/e1" "$C/e2")]" ;;
esac
if [ -n "$won" ]; then
	[ "$(cat "$C/e$lost")" = "REFUSED: another run is writing report r1; when no run is writing, remove $S/$B/.plan-gate.claim.report.r1 by hand" ] || bad "the losing run said [$(cat "$C/e$lost")]"
	[ -z "$(cat "$C/o$lost")" ] || bad "the losing run printed [$(cat "$C/o$lost")]"
	[ "$(cat "$C/o$won")" = "$S/$B/report.r1.md" ] || bad "the winning run printed [$(cat "$C/o$won")]"
fi
gate digest "$P"
d=$OUT
grep -qx "plan-sha256: $d" "$S/$B/report.r1.md" 2>/dev/null || bad "report.r1.md does not carry the plan's digest"
gate digest "$S/$B/plan.r1"
[ "$RC" -eq 0 ] && [ "$OUT" = "$d" ] || bad "plan.r1/ hashes to [$OUT] rc=$RC [$ERR], not the report's [$d]"
got=$(cd "$S/$B" 2>/dev/null && find . | LC_ALL=C sort | tr '\n' ' ')
[ "$got" = '. ./brief.md ./plan.r1 ./plan.r1/master.md ./plan.r1/plan.md ./report.r1.md ' ] || bad "the project folder holds [$got]"
done_case T37 "two reports at once: one is written, the other refused, and the copy hashes to the report"

# T38 to T43, T49 and T50 interrupt one run at a set point. A stub first on PATH sends the signal to the
# run, by the PID that $W/launch wrote before it became that run, so a case signals only the run it
# started, and the run is in the foreground: no case waits for a background job. T46, T47 and T51
# use the same launcher and stubs to place a second run, or a failing ln, at a set point.
cat >"$W/launch" <<'EOF'
echo $$ >"$1"
shift
exec bash "$@"
EOF
# stub <name> <line>: $C/bin/<name> runs <line>, then the real <name>.
stub() {
	mkdir -p "$C/bin" &&
		printf '#!/usr/bin/env bash\n%s\nexec %q "$@"\n' "$2" "$(command -v "$1")" >"$C/bin/$1" && chmod +x "$C/bin/$1"
}
# launched <args...>: as gate, with $C/bin first on PATH and the run's PID in $C/pid. The stubs read
# STUB_C, the case folder, and STUB_SCRIPT, the script under test. A stub that is to act once creates
# $C/fired with noclobber first.
launched() {
	OUT=$(PATH=$C/bin:$PATH STUB_C=$C STUB_SCRIPT=$SCRIPT bash "$W/launch" "$C/pid" "$SCRIPT" "$@" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
}
# The takeover of a stale claim needs /proc (plan-gate.sh, whoami): PROC is set where /proc is this
# test's pid namespace's, as the script requires. Elsewhere T38 and T43 expect the refusal instead,
# and T45 to T48 say "skipped: no /proc".
PROC=''
if { read -r s </proc/self/stat; } 2>/dev/null && [ "${s%% *}" = "$$" ]; then PROC=1; fi
# owner <pid> <start>: the claim line of a run on this host with that pid and start time, made here
# from uname, the boot id and the pid namespace, independently of the script.
owner() { printf '%s %s %s %s %s\n' "$(uname -n)" "$(cat /proc/sys/kernel/random/boot_id)" "$(readlink /proc/self/ns/pid)" "$1" "$2"; }
# started <pid>: the process's start time, field 22 of /proc/<pid>/stat.
started() { awk '{ sub(/.*\) /, ""); print $20 }' "/proc/$1/stat"; }
# dead_pid: the pid of a process that has exited and been reaped.
# shellcheck disable=SC2016 # $$ is the child's own pid
dead_pid() { bash -c 'echo $$'; }

# T38
loop_case t38 notes-api
ran report "$P" "$S"
# A date that kills the run with SIGKILL: verdict calls it while it holds the claim on r1 and writes
# its temporary file, and no trap runs on SIGKILL, so the claim and the file are left as a killed run
# leaves them.
# shellcheck disable=SC2016 # expanded when the stub runs
stub date 'kill -KILL "$(cat "$STUB_C/pid")"'
launched verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" -eq 137 ] || bad "the killed run exited $RC, not 137: [$ERR]"
claim=$S/$B/.plan-gate.claim.verdict.r1 tmp=$S/$B/.plan-gate.tmp.verdict.r1
[ -f "$claim" ] && [ -f "$tmp" ] || bad "the killed run left no claim and temporary file"
if [ -n "$PROC" ]; then
	# shellcheck disable=SC2046 # the line's five words
	set -- $(cat "$claim")
	[ $# -eq 5 ] && [ "$4" = "$(cat "$C/pid")" ] || bad "the claim [$*] does not name the killed run's pid"
	ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	[ "$OUT" = "$S/$B/verdict.r1.md" ] || bad "the run that took the claim over printed [$OUT]"
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left in the store: $left"
	done_case T38 "a claim and temporary file left by a run killed with SIGKILL are taken over: the next verdict is written and nothing is left"
else
	refused "another run is writing verdict r1; when no run is writing, remove $claim and $tmp by hand" verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	rm -f "$claim" "$tmp"
	ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	done_case T38 "a claim and temporary file left by a run killed with SIGKILL (no /proc: refused, naming both; removed by hand, the next verdict is written)"
fi

# T39
loop_case t39 notes-api
# An rm that sends SIGTERM to the run the first time it is called with report.r1.md linked: the trap
# runs once that rm is done, with the report published.
# shellcheck disable=SC2016 # expanded when the stub runs
stub rm '[ -e "$STUB_C/store/briefs/notes-api/report.r1.md" ] && (set -C && : >"$STUB_C/fired") 2>/dev/null && kill -TERM "$(cat "$STUB_C/pid")"'
launched report "$P" "$S"
[ "$RC" -eq 143 ] || bad "the run exited $RC, not 143: [$ERR]"
[ -f "$C/fired" ] || bad "the stub never sent SIGTERM"
gate digest "$P"
d=$OUT
gate digest "$S/$B/plan.r1"
[ "$RC" -eq 0 ] && [ "$OUT" = "$d" ] || bad "plan.r1/ hashes to [$OUT] rc=$RC [$ERR], not the report's [$d]"
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T39 "a SIGTERM after report.r1.md is linked keeps plan.r1/, and verdict decides the report"

# T40
loop_case t40 notes-api
# A date that, the first time, runs a second report without the stubs and waits for it: the first run
# holds the claim on r1 then, and has filled plan.r1/.
# shellcheck disable=SC2016 # expanded when the stub runs
stub date '! (set -C && : >"$STUB_C/fired") 2>/dev/null || { PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" report "$STUB_C/plan" "$STUB_C/store" >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; }'
launched report "$P" "$S"
[ "$RC" -eq 0 ] && [ "$OUT" = "$S/$B/report.r1.md" ] || bad "the first run: rc=$RC [$OUT] [$ERR]"
[ "$(cat "$C/r2" 2>/dev/null)" = 1 ] || bad "the second run exited [$(cat "$C/r2" 2>/dev/null)], not 1"
[ "$(cat "$C/e2" 2>/dev/null)" = "REFUSED: another run is writing report r1; when no run is writing, remove $S/$B/.plan-gate.claim.report.r1 by hand" ] || bad "the second run said [$(cat "$C/e2" 2>/dev/null)]"
[ -z "$(cat "$C/o2" 2>/dev/null)" ] || bad "the second run printed [$(cat "$C/o2")]"
done_case T40 "a report while another run holds the claim and fills plan.r1/ is told another run is writing, not to remove plan.r1/"

# T41
loop_case t41 notes-api
ran report "$P" "$S"
# Each file is one the digest leaves out, put in the copy beside the hashed files; the analyzer is
# given the whole folder.
for x in steps-1.r1.md evidence.md 01-a/notes.md plan.r2/plan.md; do
	mkdir -p "$S/$B/plan.r1/$(dirname "$x")" && printf 'S1 keeps request logs 90 days.\n' >"$S/$B/plan.r1/$x"
	refused 'the copies in plan.r1/ do not match report r1' verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	rm -rf "${S:?}/$B/plan.r1/${x%%/*}"
done
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T41 "verdict refuses a copy holding a file the digest leaves out: a round copy, evidence.md, a file in a sub-folder, a plan.r<n>/"

# T42
loop_case t42 notes-api
ran report "$P" "$S"
# A mktemp and a date that send SIGINT to the run, whichever is called first: verdict calls each while
# it holds the claim, with its temporary file being made or being written.
for t in mktemp date; do
	# shellcheck disable=SC2016 # expanded when the stub runs
	stub "$t" '! (set -C && : >"$STUB_C/fired") 2>/dev/null || kill -INT "$(cat "$STUB_C/pid")"'
done
launched verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" -eq 130 ] || bad "the run exited $RC, not 130: [$ERR]"
[ ! -e "$S/$B/verdict.r1.md" ] || bad "the interrupted run wrote verdict.r1.md"
left=$(find "$S" -name '.plan-gate.*')
[ -z "$left" ] || bad "left in the store: $left"
done_case T42 "a SIGINT while the verdict's temporary file is made or written leaves nothing in the store"

# T43
loop_case t43 notes-api
# A date that kills a report run with SIGKILL: report calls it with plan.r1/ filled, holding the
# claim on r1 and writing its temporary file.
# shellcheck disable=SC2016 # expanded when the stub runs
stub date 'kill -KILL "$(cat "$STUB_C/pid")"'
launched report "$P" "$S"
[ "$RC" -eq 137 ] || bad "the killed run exited $RC, not 137: [$ERR]"
claim=$S/$B/.plan-gate.claim.report.r1 tmp=$S/$B/.plan-gate.tmp.report.r1
[ -f "$claim" ] && [ -f "$tmp" ] && [ -d "$S/$B/plan.r1" ] || bad "the killed run left no claim, temporary file and plan.r1/"
if [ -n "$PROC" ]; then
	# The takeover removes the claim and the temporary file; plan.r1/ is still refused under the claim
	# and kept, for a person to look at (plan-gate.sh, cmd_report).
	gate report "$P" "$S"
	[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = 'REFUSED: plan.r1/ is there without report r1; look at it and remove it by hand' ] ||
		bad "after the takeover: rc=$RC [$OUT] [$ERR]"
	[ ! -e "$claim" ] && [ ! -e "$tmp" ] || bad "the claim or the temporary file is still there"
	[ -d "$S/$B/plan.r1" ] || bad "plan.r1/ was removed"
	rm -rf "${S:?}/$B/plan.r1"
	ran report "$P" "$S"
	[ "$OUT" = "$S/$B/report.r1.md" ] || bad "the next report printed [$OUT]"
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left in the store: $left"
	done_case T43 "a report run killed with SIGKILL: its claim and temporary file are taken over, plan.r1/ is refused and kept; removed by hand, the next report is written"
else
	refused "another run is writing report r1; when no run is writing, remove $claim and $tmp by hand" report "$P" "$S"
	rm -rf "$claim" "$tmp" "${S:?}/$B/plan.r1"
	done_case T43 "a report run killed with SIGKILL (no /proc: refused, naming the claim and the temporary file)"
fi

# T44
loop_case t44 notes-api
ran report "$P" "$S"
claim=$S/$B/.plan-gate.claim.verdict.r1 tmp=$S/$B/.plan-gate.tmp.verdict.r1
boot=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null)
# Claims no run can prove stale, each refused and kept: an empty one, as glab 0.14.0 wrote them; one
# from another host; one from another pid namespace; and the line of a run that is alive, this
# test's own bash; and one from another boot. Cases 2, 3 and 5 name a dead pid and differ from this
# host's line in that one field only, so that field alone refuses them. The refusal names the
# temporary file too, unless the claim's run is alive.
for k in 1 2 3 4 5; do
	rm -f "$claim" "$tmp"
	case $k in
	1) : >"$claim" && want="remove $claim by hand" ;;
	2)
		[ -n "$PROC" ] || continue
		printf 'plan-gate-test-elsewhere %s %s %s 1\n' "$boot" "$(readlink /proc/self/ns/pid)" "$(dead_pid)" >"$claim" && : >"$tmp" && want="remove $claim and $tmp by hand"
		;;
	3)
		[ -n "$PROC" ] || continue
		printf '%s %s pid:[1] %s 1\n' "$(uname -n)" "$boot" "$(dead_pid)" >"$claim" && : >"$tmp" && want="remove $claim and $tmp by hand"
		;;
	4)
		[ -n "$PROC" ] || continue
		owner "$$" "$(started "$$")" >"$claim" && : >"$tmp" && want="remove $claim by hand"
		;;
	5)
		[ -n "$PROC" ] || continue
		printf '%s 00000000-0000-0000-0000-000000000000 %s %s 1\n' "$(uname -n)" "$(readlink /proc/self/ns/pid)" "$(dead_pid)" >"$claim" && : >"$tmp" && want="remove $claim and $tmp by hand"
		;;
	esac
	refused "another run is writing verdict r1; when no run is writing, $want" verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done
rm -f "$claim" "$tmp"
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T44 "a claim no run can prove stale is refused and kept - empty, from another host, from another pid namespace, alive, or from another boot - naming the temporary file too unless its run is alive"

# T45
loop_case t45 notes-api
if [ -n "$PROC" ]; then
	ran report "$P" "$S"
	# The line of a run whose pid is now this test's bash, which started at another time: the pid
	# was reused.
	owner "$$" 1 >"$S/$B/.plan-gate.claim.verdict.r1"
	ran verdict "$S" notes-api REJECTED product-manager "$C/no"
	[ -f "$S/$B/verdict.r1.md" ] || bad "no verdict r1 after the takeover of a reused pid's claim"
	printf 'amended\n' >>"$P/plan.md"
	ran report "$P" "$S"
	# A zombie: sleep 0 exits under a parent that became sleep 5, which never reaps it.
	# shellcheck disable=SC2016 # $! and $1 are the child shell's
	bash -c 'sleep 0 & echo $! >"$1"; exec sleep 5' _ "$C/z" &
	BG=$!
	z=''
	for _ in $(seq 50); do
		z=$(cat "$C/z" 2>/dev/null)
		if [ -n "$z" ] && [ "$(awk '{ sub(/.*\) /, ""); print $1 }' "/proc/$z/stat" 2>/dev/null)" = Z ]; then break; fi
		sleep 0.1
	done
	owner "$z" "$(started "$z")" >"$S/$B/.plan-gate.claim.verdict.r2"
	ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	[ -f "$S/$B/verdict.r2.md" ] || bad "no verdict r2 after the takeover of a zombie's claim"
	kill "$BG" 2>/dev/null
	wait "$BG" 2>/dev/null
	BG=''
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left in the store: $left"
	done_case T45 "a claim whose pid was reused, or whose run is a zombie, is taken over"
else
	done_case T45 "a claim whose pid was reused, or whose run is a zombie, is taken over (skipped: no /proc)"
fi

# T46
loop_case t46 notes-api
if [ -n "$PROC" ]; then
	ran report "$P" "$S"
	claim=$S/$B/.plan-gate.claim.verdict.r1 lock=$S/$B/.plan-gate.takeover.verdict.r1
	owner "$(dead_pid)" 1 >"$claim"
	# An rm that, the first time it is called while the takeover lock is there - the takeover
	# removing the stale claim - runs a second verdict without the stubs and waits for it.
	# shellcheck disable=SC2016 # expanded when the stub runs
	stub rm '[ ! -e "$STUB_C/store/briefs/notes-api/.plan-gate.takeover.verdict.r1" ] || ! (set -C && : >"$STUB_C/fired") 2>/dev/null || { PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" verdict "$STUB_C/store" notes-api REJECTED product-manager "$STUB_C/no" >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; }'
	launched verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	[ "$RC" -eq 0 ] && [ "$OUT" = "$S/$B/verdict.r1.md" ] || bad "the run that took the claim over: rc=$RC [$OUT] [$ERR]"
	[ "$(cat "$C/r2" 2>/dev/null)" = 1 ] || bad "the second run exited [$(cat "$C/r2" 2>/dev/null)], not 1"
	[ "$(cat "$C/e2" 2>/dev/null)" = "REFUSED: another run is writing verdict r1; when no run is writing, remove $lock by hand" ] ||
		bad "the second run said [$(cat "$C/e2" 2>/dev/null)]"
	[ -z "$(cat "$C/o2" 2>/dev/null)" ] || bad "the second run printed [$(cat "$C/o2")]"
	grep -qx 'verdict: ACCEPTED' "$S/$B/verdict.r1.md" 2>/dev/null || bad "verdict.r1.md is not the first run's ACCEPTED"
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left in the store: $left"
	done_case T46 "a run that finds a stale claim while another run holds the takeover lock is refused, naming the lock"
else
	done_case T46 "a run that finds a stale claim while another run holds the takeover lock is refused (skipped: no /proc)"
fi

# T47
loop_case t47 notes-api
if [ -n "$PROC" ]; then
	ran report "$P" "$S"
	claim=$S/$B/.plan-gate.claim.verdict.r1
	owner "$(dead_pid)" 1 >"$claim"
	# A head that, the first time it reads the claim, reads it, then lets a second verdict take the
	# claim over, and only then hands this run the stale line: the second run, started in the
	# background with a date that waits for $C/go, holds its own claim and has released the lock
	# when this run goes on to the lock. Its PID is in $C/pid2, its exit code in $C/r2.
	mkdir -p "$C/bin" "$C/binA"
	{
		printf '#!/usr/bin/env bash\nreal=%q\n' "$(command -v head)"
		cat <<-'EOF'
			claim=$STUB_C/store/briefs/notes-api/.plan-gate.claim.verdict.r1
			lock=$STUB_C/store/briefs/notes-api/.plan-gate.takeover.verdict.r1
			if [ "${!#}" = "$claim" ] && (set -C && : >"$STUB_C/fired") 2>/dev/null; then
				x=$("$real" "$@")
				(
					PATH=$STUB_C/binA:${PATH#"$STUB_C/bin:"} bash "$STUB_C/../launch" "$STUB_C/pid2" "$STUB_SCRIPT" verdict "$STUB_C/store" notes-api ACCEPTED product-manager "$STUB_C/ok" >"$STUB_C/o2" 2>"$STUB_C/e2"
					echo $? >"$STUB_C/r2"
				) </dev/null >/dev/null 2>&1 &
				for _ in $(seq 100); do
					y=$("$real" -n 1 -- "$claim" 2>/dev/null)
					if [ -n "$y" ] && [ "$y" != "$x" ] && [ ! -e "$lock" ]; then break; fi
					sleep 0.1
				done
				printf '%s\n' "$x"
				exit 0
			fi
			exec "$real" "$@"
		EOF
	} >"$C/bin/head"
	{
		printf '#!/usr/bin/env bash\nreal=%q\n' "$(command -v date)"
		cat <<-'EOF'
			for _ in $(seq 100); do [ ! -e "$STUB_C/go" ] || break; sleep 0.1; done
			exec "$real" "$@"
		EOF
	} >"$C/binA/date"
	chmod +x "$C/bin/head" "$C/binA/date"
	launched verdict "$S" notes-api REJECTED product-manager "$C/no"
	BG=$(cat "$C/pid2" 2>/dev/null)
	[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: another run is writing verdict r1; when no run is writing, remove $claim by hand" ] ||
		bad "the run that found the claim stale first: rc=$RC [$OUT] [$ERR]"
	: >"$C/go"
	for _ in $(seq 100); do
		[ ! -e "$C/r2" ] || break
		sleep 0.1
	done
	# BG is cleared only once the second run is over: when $C/r2 never came it may still run, and is
	# killed by its PID first.
	if [ ! -e "$C/r2" ]; then kill "$BG" 2>/dev/null; fi
	BG=''
	[ "$(cat "$C/r2" 2>/dev/null)" = 0 ] || bad "the run that took the claim over exited [$(cat "$C/r2" 2>/dev/null)]: [$(cat "$C/e2" 2>/dev/null)]"
	grep -qx 'verdict: ACCEPTED' "$S/$B/verdict.r1.md" 2>/dev/null || bad "verdict.r1.md is not the second run's ACCEPTED"
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left in the store: $left"
	done_case T47 "a run that found a claim stale before another run took it over finds the new claim under the lock and is refused; the other run writes the verdict"
else
	done_case T47 "a run that found a claim stale before another run took it over is refused (skipped: no /proc)"
fi

# T48
loop_case t48 notes-api
if [ -n "$PROC" ]; then
	ran report "$P" "$S"
	claim=$S/$B/.plan-gate.claim.verdict.r1 lock=$S/$B/.plan-gate.takeover.verdict.r1
	owner "$(dead_pid)" 1 >"$claim"
	# A head that waits a second before it reads the claim: two runs started at once both find it
	# stale before either takes the lock.
	# shellcheck disable=SC2016 # expanded when the stub runs
	stub head '[ "${!#}" != "$STUB_C/store/briefs/notes-api/.plan-gate.claim.verdict.r1" ] || sleep 1'
	PATH=$C/bin:$PATH STUB_C=$C bash "$SCRIPT" verdict "$S" notes-api REJECTED product-manager "$C/no" >"$C/o1" 2>"$C/e1" &
	p1=$!
	BG=$p1
	PATH=$C/bin:$PATH STUB_C=$C bash "$SCRIPT" verdict "$S" notes-api ACCEPTED product-manager "$C/ok" >"$C/o2" 2>"$C/e2" &
	p2=$!
	BG="$p1 $p2"
	wait "$p1"
	r1=$?
	wait "$p2"
	r2=$?
	BG=''
	case "$r1 $r2" in
	'0 1') won=REJECTED lost=2 ;;
	'1 0') won=ACCEPTED lost=1 ;;
	*) won='' lost='' && bad "the two runs exited $r1 and $r2, not one 0 and one 1: [$(cat "$C/e1" "$C/e2")]" ;;
	esac
	if [ -n "$won" ]; then
		case $(cat "$C/e$lost") in
		"REFUSED: another run is writing verdict r1; when no run is writing, remove $lock by hand") ;;
		"REFUSED: another run is writing verdict r1; when no run is writing, remove $claim by hand") ;;
		*) bad "the losing run said [$(cat "$C/e$lost")]" ;;
		esac
		[ -z "$(cat "$C/o$lost")" ] || bad "the losing run printed [$(cat "$C/o$lost")]"
		grep -qx "verdict: $won" "$S/$B/verdict.r1.md" || bad "verdict.r1.md is not the winning run's $won"
	fi
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left in the store: $left"
	done_case T48 "two runs at once on one stale claim: one takes it over and writes the verdict, the other is refused"
else
	done_case T48 "two runs at once on one stale claim (skipped: no /proc)"
fi

# T49
for sig in TERM HUP INT; do
	loop_case "t49-$sig" notes-api
	# An ln that links, then sends the signal to the run and waits a second before it exits: the
	# signal arrives while ln runs, with report.r1.md linked.
	mkdir -p "$C/bin"
	{
		printf '#!/usr/bin/env bash\n%q "$@"\nrc=$?\n' "$(command -v ln)"
		# shellcheck disable=SC2016 # expanded when the stub runs
		printf 'kill -%s "$(cat "$STUB_C/pid")"\nsleep 1\nexit $rc\n' "$sig"
	} >"$C/bin/ln" && chmod +x "$C/bin/ln"
	launched report "$P" "$S"
	case $sig in TERM) want=143 ;; HUP) want=129 ;; INT) want=130 ;; esac
	[ "$RC" -eq "$want" ] || bad "$sig: the run exited $RC, not $want: [$ERR]"
	gate digest "$P"
	d=$OUT
	grep -qx "plan-sha256: $d" "$S/$B/report.r1.md" 2>/dev/null || bad "$sig: report.r1.md is not there with the plan's digest"
	gate digest "$S/$B/plan.r1"
	[ "$RC" -eq 0 ] && [ "$OUT" = "$d" ] || bad "$sig: plan.r1/ hashes to [$OUT] rc=$RC [$ERR], not the report's [$d]"
	left=$(find "$S" -name '.plan-gate.*')
	[ -z "$left" ] || bad "$sig: left in the store: $left"
	ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done
done_case T49 "a TERM, HUP or INT while ln runs is held: report.r1.md and plan.r1/ stay, the run ends by the signal, and verdict decides the report"

# T50
loop_case t50 notes-api
# An ln that links and is then killed before it exits, as a Ctrl-C to the whole process group can
# end it: ln fails, with report.r1.md linked.
mkdir -p "$C/bin"
{
	printf '#!/usr/bin/env bash\n%q "$@"\n' "$(command -v ln)"
	# shellcheck disable=SC2016 # expanded when the stub runs
	printf 'kill -KILL $$\n'
} >"$C/bin/ln" && chmod +x "$C/bin/ln"
launched report "$P" "$S"
[ "$RC" -eq 0 ] && [ "$OUT" = "$S/$B/report.r1.md" ] && [ -z "$ERR" ] || bad "the run: rc=$RC [$OUT] [$ERR]"
gate digest "$P"
d=$OUT
gate digest "$S/$B/plan.r1"
[ "$RC" -eq 0 ] && [ "$OUT" = "$d" ] || bad "plan.r1/ hashes to [$OUT] rc=$RC [$ERR], not the report's [$d]"
left=$(find "$S" -name '.plan-gate.*')
[ -z "$left" ] || bad "left in the store: $left"
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T50 "an ln killed after it linked report.r1.md: the report is published and plan.r1/ kept"

# T51
loop_case t51 notes-api
# An ln that fails as GNU ln does on a filesystem without hard links, for the final name in
# $C/final, and links nothing: its message, exit 1 (the message measured with GNU ln on this host's
# EPERM). Every other link is the real ln's.
mkdir -p "$C/bin"
{
	printf '#!/usr/bin/env bash\nreal=%q\n' "$(command -v ln)"
	cat <<-'EOF'
		case $3 in */"$(cat "$STUB_C/final")") echo "ln: failed to create hard link '$3' => '$2': Operation not permitted" >&2 && exit 1 ;; esac
		exec "$real" "$@"
	EOF
} >"$C/bin/ln" && chmod +x "$C/bin/ln"
# nolink <file> <kind>: the line plan-gate.sh prints when <file> cannot be linked.
nolink() { printf "plan-gate.sh: writing %s failed: ln: failed to create hard link '%s' => '%s': Operation not permitted; plan-gate.sh publishes with a hard link, so the store must be on a filesystem that has them - the header of plan-gate.sh names them" "$S/$B/$1" "$S/$B/$1" "$S/$B/.plan-gate.tmp.$2"; }
echo report.r1.md >"$C/final"
launched report "$P" "$S"
[ "$RC" -eq 2 ] && [ -z "$OUT" ] && [ "$ERR" = "$(nolink report.r1.md report.r1)" ] || bad "report: rc=$RC [$OUT] [$ERR]"
got=$(cd "$S/$B" && find . | LC_ALL=C sort | tr '\n' ' ')
[ "$got" = '. ./brief.md ' ] || bad "after the report the project folder holds [$got]"
ran report "$P" "$S"
echo verdict.r1.md >"$C/final"
launched verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" -eq 2 ] && [ -z "$OUT" ] && [ "$ERR" = "$(nolink verdict.r1.md verdict.r1)" ] || bad "verdict: rc=$RC [$OUT] [$ERR]"
[ ! -e "$S/$B/verdict.r1.md" ] || bad "a verdict was written"
left=$(find "$S" -name '.plan-gate.*')
[ -z "$left" ] || bad "left in the store: $left"
done_case T51 "on a store without hard links, report and verdict exit 2 naming the requirement, and leave nothing"

# T52 to T55 make a claim's or a lock's create fail (plan-gate.sh, create_line). capped <args...>:
# as gate, but the run may write no byte to a regular file - ulimit -f 0 - so that its first write,
# the line of its claim, fails as on a full disk; the file is still created, empty. Only regular
# files are capped, not pipes, so OUT and ERR come back through pipes - gate's stderr file would
# fail the same way - and RC and ERR are written to $W/capped by the outer shell, which is not
# capped, outside $C so that snap "$C" holds. trap '' because a write over the limit sends SIGXFSZ,
# which kills the run; a signal ignored when bash starts stays ignored in it, so the write fails
# with EFBIG instead.
capped() {
	local e
	OUT=$( { e=$( (trap '' XFSZ; ulimit -f 0; exec bash "$SCRIPT" "$@") 2>&1 1>&3 ); printf '%s\n%s' "$?" "$e" >"$W/capped"; } 3>&1 )
	RC=$(head -n 1 "$W/capped")
	ERR=$(tail -n +2 "$W/capped")
}

# T52
loop_case t52 notes-api
# A decoy at the very name the run claims, holding another host's line: the capped run is refused
# on it and leaves it as it was - it removes only a file it made itself [script-hardening/review.r1.md].
decoy=$S/$B/.plan-gate.claim.report.r1
printf 'plan-gate-test-elsewhere x pid:[1] 1 1\n' >"$decoy"
sum=$(cksum <"$decoy")
before=$(snap "$C")
capped report "$P" "$S"
[ "$RC" = 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: another run is writing report r1; when no run is writing, remove $decoy by hand" ] || bad "report on the decoy: rc=$RC [$OUT] [$ERR]"
[ "$(cksum <"$decoy" 2>/dev/null)" = "$sum" ] || bad "the decoy changed or went"
[ "$before" = "$(snap "$C")" ] || bad "the refused report wrote something"
rm -f -- "$decoy"
before=$(snap "$C")
capped report "$P" "$S"
[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $S/$B/.plan-gate.claim.report.r1 failed" ] || bad "report: rc=$RC [$OUT] [$ERR]"
[ "$before" = "$(snap "$C")" ] || bad "the failed report left something"
ran report "$P" "$S"
before=$(snap "$C")
capped verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $S/$B/.plan-gate.claim.verdict.r1 failed" ] || bad "verdict: rc=$RC [$OUT] [$ERR]"
[ "$before" = "$(snap "$C")" ] || bad "the failed verdict left something"
done_case T52 "a claim whose line cannot be written: exit 2 naming it, its own empty file removed; another run's claim at that name refused and kept"

# T53
loop_case t53 notes-api
if [ -n "$PROC" ]; then
	ran report "$P" "$S"
	claim=$S/$B/.plan-gate.claim.verdict.r1 lock=$S/$B/.plan-gate.takeover.verdict.r1
	owner "$(dead_pid)" 1 >"$claim"
	sum=$(cksum <"$claim")
	capped verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $lock failed" ] || bad "verdict: rc=$RC [$OUT] [$ERR]"
	[ "$(cksum <"$claim" 2>/dev/null)" = "$sum" ] || bad "the stale claim changed or went"
	[ ! -e "$lock" ] || bad "the takeover lock was left"
	rm -f -- "$claim"
	done_case T53 "a takeover lock whose line cannot be written: exit 2 naming it, the lock removed, the stale claim kept"
else
	done_case T53 "a takeover lock whose line cannot be written (skipped: no /proc)"
fi

# T54
loop_case t54 notes-api
chmod a-w "$S/$B"
if [ -w "$S/$B" ]; then
	chmod u+w "$S/$B"
	done_case T54 "a claim or lock in a folder this run cannot write: exit 2 naming it (skipped: the folder stays writable, root)"
else
	before=$(snap "$C")
	gate report "$P" "$S"
	[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $S/$B/.plan-gate.claim.report.r1 failed" ] || bad "report: rc=$RC [$OUT] [$ERR]"
	[ "$before" = "$(snap "$C")" ] || bad "the failed report wrote something"
	if [ -n "$PROC" ]; then
		chmod u+w "$S/$B"
		ran report "$P" "$S"
		claim=$S/$B/.plan-gate.claim.verdict.r1
		owner "$(dead_pid)" 1 >"$claim"
		chmod a-w "$S/$B"
		before=$(snap "$C")
		gate verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
		[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $S/$B/.plan-gate.takeover.verdict.r1 failed" ] || bad "verdict: rc=$RC [$OUT] [$ERR]"
		[ "$before" = "$(snap "$C")" ] || bad "the failed verdict wrote something"
		chmod u+w "$S/$B"
		rm -f -- "$claim"
	fi
	chmod u+w "$S/$B"
	done_case T54 "a claim or lock in a folder this run cannot write: exit 2 naming it, nothing written"
fi

# T55
loop_case t55 notes-api
# An rm that fails, with a line on stderr that the script must drop: the run cannot remove the
# empty claim its failed write left.
stub rm 'echo "rm: stub, failing on purpose" >&2; exit 1'
PATH=$C/bin:$PATH capped report "$P" "$S"
claim=$S/$B/.plan-gate.claim.report.r1
[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $claim failed, and removing it failed; remove $claim by hand" ] || bad "report: rc=$RC [$OUT] [$ERR]"
[ -f "$claim" ] && [ ! -s "$claim" ] || bad "no empty claim was left"
rm -f -- "$claim"
done_case T55 "a claim whose line cannot be written nor its file removed: exit 2, one line naming it to remove by hand"

# T56
# Under POSIXLY_CORRECT bash runs in posix mode, where a failed redirection on exec, a special
# builtin, ends the shell at once with no message - the caller's one line never printed
# [script-hardening/review.r1.md] [script-hardening/plan.md D21]. Two failed opens: one in a folder
# the run cannot write (code 2), and the loser of a claim race (code 1). The race is made certain
# here: the run is sourced by a bash whose function [ wraps the builtin and, the first time
# create_line's guard tests the claim with -L, puts another run's claim at that name, as a run that
# won between the guard and the open would. The line is another host's, so the refusal does not
# need /proc. That bash turns posix mode on with set -o posix after the function is defined, not
# with POSIXLY_CORRECT at its start: bash 4.4 to 5.2 rejects the name [ in posix mode, and only 5.3
# accepts it [script-hardening/review.r2.md] [script-hardening/plan.md D23].
loop_case t56 notes-api
chmod a-w "$S/$B"
if [ -w "$S/$B" ]; then
	chmod u+w "$S/$B"
	done_case T56 "under POSIXLY_CORRECT a failed open still ends in one line (skipped: the folder stays writable, root)"
else
	before=$(snap "$C")
	POSIXLY_CORRECT=1 gate report "$P" "$S"
	[ "$RC" = 2 ] && [ -z "$OUT" ] && [ "$ERR" = "plan-gate.sh: writing $S/$B/.plan-gate.claim.report.r1 failed" ] || bad "read-only store: rc=$RC [$OUT] [$ERR]"
	[ "$before" = "$(snap "$C")" ] || bad "the failed report wrote something"
	chmod u+w "$S/$B"
	claim=$S/$B/.plan-gate.claim.report.r1 line='plan-gate-test-elsewhere x pid:[1] 1 1'
	# shellcheck disable=SC2016 # expanded by the bash that sources the script
	OUT=$(PLANT=$claim LINE=$line bash -c '
		planted=""
		[ () {
			local r=0
			builtin [ "$@" || r=1
			if builtin [ -z "$planted" ] && builtin [ "$#" -eq 3 ] && builtin [ "$1" = -L ] && builtin [ "$2" = "$PLANT" ]; then
				planted=1
				printf "%s\n" "$LINE" >"$PLANT"
			fi
			return "$r"
		}
		set -o posix
		s=$1
		shift
		. "$s"' _ "$SCRIPT" report "$P" "$S" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
	[ "$RC" = 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: another run is writing report r1; when no run is writing, remove $claim by hand" ] || bad "race loser: rc=$RC [$OUT] [$ERR]"
	[ "$(cat "$claim" 2>/dev/null)" = "$line" ] || bad "the other run's claim changed or went"
	rm -f -- "$claim"
	done_case T56 "under POSIXLY_CORRECT a failed open still ends in one line: exit 2 in a folder it cannot write, REFUSED for a claim race lost"
fi

# T22 last: judged over every store the cases above wrote
left=$(find "$W" -name '.plan-gate.*')
[ -z "$left" ] || bad "temporary files left: $left"
done_case T22 "no temporary file is left in any store after any run"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
