#!/usr/bin/env bash
# Exercises plan-gate.sh against plan folders and stores written here, under $TMPDIR; it never
# touches a real shared store. Each case builds its own store and plan folder, so no case depends on
# another case's files. T22 is judged last, over every store the cases wrote, git dirs included.
# T57 to T77 run the store as a git clone [remote-store/plan-tests.md]: T57 the plain paths beside a
# repository, T58 to T61 each mode on a clone, T62 to T65 two clones racing one remote, T66 a remote
# that refuses, T67 each precondition, T68 a TERM between commit and push, T69 a push that landed
# yet failed, T70 real concurrency, T71 a hostile git config and environment, T72 the clone claim;
# T73 to T77 the review's fixes [remote-store/review-r1.md]: T73 the store's own .gitignore, T74 a
# reader waiting on the clone claim, T75 GIT_CONFIG, T76 a path with a newline or a tab, T77 a
# symlink given to sync; T78 to T81 those of review round 2 [remote-store/review-r2.md]: T78 the
# other config and pathspec names in the environment, T79 an ignored file a killed verdict run left,
# T80 a TERM after the push landed, T81 a newline in the store path; T82 to T84 those of round 3
# [remote-store/review-r3.md]: T82 a rule file named as a glob, and a literal pathspec, T83 an
# ignored local file the remote adds, T84 a TERM after a push another push built on; T85 and T86
# the verification's [remote-store/review-r3.md A12a, A12b]: T85 a clone with no commit yet, T86 an
# ignored file at a parent folder of a path the remote brings.
# Their remote is a bare repository by path under the case folder, never a network one, and git
# reads no config of the host: the test's own GIT_CONFIG_GLOBAL, HOME and XDG_CONFIG_HOME, and no
# system file [remote-store/plan.md D24].
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to plan-gate.sh>" >&2; exit 2; }
# git 2.28 or newer: the cases make their remotes with `git init -b`.
gv=$(git --version 2>/dev/null) || gv=''
gv=${gv#git version }
gmaj=${gv%%.*} gmin=${gv#*.}
gmin=${gmin%%.*}
case $gmaj.$gmin in *[!0-9.]* | .* | *.) gmaj=0 gmin=0 ;; esac
if ! { [ "$gmaj" -gt 2 ] || { [ "$gmaj" -eq 2 ] && [ "$gmin" -ge 28 ]; }; }; then
	echo 'plan-gate.test.sh: git 2.28 or newer is required' >&2
	exit 2
fi
# Absolute, because every run below starts from the work directory.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/plan-gate-test.XXXXXX") || exit 1
# T33, T37 and T48 each start two runs in the background and wait for both, and T45 a parent that
# keeps a zombie; BG holds those PIDs while they may run. In T47 a stub starts a second run in the
# background and records its PID in $C/pid2, which joins BG only once the first run is back: a test
# killed while the first run waits in that stub, up to 10 s, does not kill the second, which ends on
# its own once its date stub stops waiting, 10 s at most. T70 starts two runs in the background in
# each of its rounds, T72 a sleep whose pid it writes into a claim, and T74 such sleeps, a subshell
# that removes one claim and a run that waits on another; each joins BG and is waited on by its PID. The trap kills only the PIDs in BG, should the test end first, then removes the
# work directory.
BG=''
trap 'for p in $BG; do kill "$p" 2>/dev/null; done; rm -rf "$W"' EXIT
cd "$W" || exit 1
# For the whole test, the test's own git commands included: an empty global config, no system one,
# and a HOME and XDG_CONFIG_HOME of the test's, so that no setting of the host - an autocrlf, a
# signing key, an attributes or ignore file - reaches a case; and none of the GIT_* names that
# plan-gate.sh unsets [remote-store/plan.md D24].
mkdir -p "$W/xdg" "$W/home" && : >"$W/gitconfig" || exit 1
export GIT_CONFIG_GLOBAL=$W/gitconfig GIT_CONFIG_NOSYSTEM=1 XDG_CONFIG_HOME=$W/xdg HOME=$W/home
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_AUTHOR_DATE GIT_COMMITTER_DATE GIT_CONFIG
unset GIT_CONFIG_PARAMETERS GIT_CONFIG_COUNT GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS

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
# The takeover of a stale claim needs /proc (plan-gate.sh, whoami): PROC is set where /proc is this
# test's pid namespace's, as the script requires. Elsewhere T38 and T43 expect the refusal instead,
# and T45 to T48 say "skipped: no /proc". Set here, before T33, which live reads.
PROC=''
if { read -r s </proc/self/stat; } 2>/dev/null && [ "${s%% *}" = "$$" ]; then PROC=1; fi
# live <refusal> <claim>: the refusal of a claim whose run is alive. With PROC the script proves it
# alive and says no more, since that claim must not be removed by hand [remote-store/review-r1.md
# A2]; without /proc it cannot tell, and says to remove the claim when no run is writing.
live() { if [ -n "$PROC" ]; then printf '%s' "$1"; else printf '%s; when no run is writing, remove %s by hand' "$1" "$2"; fi; }
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
	[ "$(cat "$C/e$lost")" = "REFUSED: $(live 'another run is writing verdict r1' "$S/$B/.plan-gate.claim.verdict.r1")" ] || bad "the losing run said [$(cat "$C/e$lost")]"
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
	[ "$(cat "$C/e$lost")" = "REFUSED: $(live 'another run is writing report r1' "$S/$B/.plan-gate.claim.report.r1")" ] || bad "the losing run said [$(cat "$C/e$lost")]"
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
[ "$(cat "$C/e2" 2>/dev/null)" = "REFUSED: $(live 'another run is writing report r1' "$S/$B/.plan-gate.claim.report.r1")" ] || bad "the second run said [$(cat "$C/e2" 2>/dev/null)]"
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
# temporary file too, unless the claim's run is alive; then it names nothing to remove, since a live
# run's claim must not be removed by hand [remote-store/review-r1.md A2].
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
		owner "$$" "$(started "$$")" >"$claim" && : >"$tmp" && want=''
		;;
	5)
		[ -n "$PROC" ] || continue
		printf '%s 00000000-0000-0000-0000-000000000000 %s %s 1\n' "$(uname -n)" "$(readlink /proc/self/ns/pid)" "$(dead_pid)" >"$claim" && : >"$tmp" && want="remove $claim and $tmp by hand"
		;;
	esac
	refused "another run is writing verdict r1${want:+; when no run is writing, $want}" verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done
rm -f "$claim" "$tmp"
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
done_case T44 "a claim no run can prove stale is refused and kept - empty, from another host, from another pid namespace, alive, or from another boot - naming the temporary file too, and naming nothing to remove when its run is alive"

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
	# A zombie: sleep 0 exits under a parent that became sleep 60, which never reaps it. The parent
	# was sleep 5 until 2026-11-21: G16 failed once in 3 gate runs with `awk: cannot open
	# "/proc/<pid>/stat"` from started below — inferred, not reproduced, to be this zombie reaped
	# once a 5 s parent exited under load. The parent is killed by its PID after the case.
	# shellcheck disable=SC2016 # $! and $1 are the child shell's
	bash -c 'sleep 0 & echo $! >"$1"; exec sleep 60' _ "$C/z" &
	BG=$!
	z=''
	for _ in $(seq 50); do
		z=$(cat "$C/z" 2>/dev/null)
		if [ -n "$z" ] && [ "$(awk '{ sub(/.*\) /, ""); print $1 }' "/proc/$z/stat" 2>/dev/null)" = Z ]; then break; fi
		sleep 0.1
	done
	[ "$(awk '{ sub(/.*\) /, ""); print $1 }' "/proc/$z/stat" 2>/dev/null)" = Z ] || bad "no zombie to claim: pid [$z]"
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

# T57 to T72: the store as a git clone [remote-store/plan-tests.md]. A case's remote is the bare
# repository $C/remote.git, by path; $C/seed made its first commit; $S and $S2 are two store clones
# of it, made as the user makes them, with core.autocrlf=false and glab.store=true. "Clean" (gclean)
# is: git status prints nothing, no .plan-gate.* is left under the case, and HEAD is the value given.
# tgit <args...>: git as the test's own author, t <t@t.invalid>, for the commits a case makes by hand.
tgit() { git -c user.name=t -c user.email=t@t.invalid "$@"; }
# gitcase <id> [<project>...]: newcase, a bare remote, a seed clone committing each project's brief -
# the text brief writes - and docs/product-rules/index.md, then $S and $S2.
gitcase() {
	local pr
	newcase "$1"
	shift
	S2=$C/store2
	{ git init -q --bare -b main "$C/remote.git" && git clone -q "$C/remote.git" "$C/seed"; } >/dev/null 2>&1 || bad "gitcase: no remote or seed"
	for pr in "$@"; do
		mkdir -p "$C/seed/briefs/$pr" && printf '# Brief — %s\n\n## Goal\n\n%s\n' "$pr" 'Store notes.' >"$C/seed/briefs/$pr/brief.md"
	done
	mkdir -p "$C/seed/docs/product-rules" && printf '# Product rules\n\n- data-retention.md\n' >"$C/seed/docs/product-rules/index.md"
	{ git -C "$C/seed" add -A && tgit -C "$C/seed" commit -q -m seed && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "gitcase: the seed commit failed"
	rmdir "$S"
	{ git clone -q -c core.autocrlf=false -c glab.store=true "$C/remote.git" "$S" && git clone -q -c core.autocrlf=false -c glab.store=true "$C/remote.git" "$S2"; } >/dev/null 2>&1 ||
		bad "gitcase: a store clone failed"
}
# plan_in <dir> <project>: plan_for into another plan folder, $C/plan2 for a second project.
plan_in() {
	# shellcheck disable=SC2034 # read by plan_for
	local P=$1
	mkdir -p "$1" && plan_for "$2"
}
# gsnap: snap of the case with every .git and the remote pruned, then HEAD of each clone and main of
# the remote - a fetch may change the clones' remote-tracking refs, nothing else.
gsnap() {
	local d
	(cd "$C" && find . \( -name .git -o -name remote.git \) -prune -o -print | LC_ALL=C sort &&
		find . \( -name .git -o -name remote.git \) -prune -o -type f -exec cksum {} + | LC_ALL=C sort)
	for d in "$C/store" "$C/store2" "$C/seed"; do git -C "$d" rev-parse HEAD 2>/dev/null; done
	git -C "$C/remote.git" rev-parse main 2>/dev/null
}
# grefused <line> <args...>: refused, over gsnap.
grefused() {
	local line=$1 before
	shift
	before=$(gsnap)
	gate "$@"
	[ "$RC" -eq 1 ] || bad "rc=$RC, not 1, for [$*]: [$ERR]"
	[ -z "$OUT" ] || bad "stdout not empty: [$OUT]"
	[ "$ERR" = "REFUSED: $line" ] || bad "stderr [$ERR] is not [REFUSED: $line]"
	[ "$before" = "$(gsnap)" ] || bad "the refusal of [$*] wrote something"
}
# tip: main of the case's remote.
tip() { git -C "$C/remote.git" rev-parse main 2>/dev/null; }
# gclean <clone> <commit>: the clone is clean, at <commit>.
gclean() {
	local st left
	st=$(git -C "$1" status --porcelain --untracked-files=all)
	[ -z "$st" ] || bad "$1 is not clean: [$st]"
	left=$(find "$C" -name '.plan-gate.*')
	[ -z "$left" ] || bad "left under the case: $left"
	[ "$(git -C "$1" rev-parse HEAD 2>/dev/null)" = "$2" ] || bad "HEAD of $1 is not $2"
}
# who <repo> <rev>: "<author name> <email>|<committer name> <email>" of the commit.
who() { git -C "$1" log -1 --format='%an <%ae>|%cn <%ce>' "$2"; }
PG='glab plan-gate <plan-gate@glab.invalid>'
# one_line <text>: the text is one line.
one_line() { [ -n "$1" ] && [ "$(printf '%s\n' "$1" | wc -l)" -eq 1 ]; }

# T57
newcase t57a
before=$(snap "$C")
ran sync "$S"
[ "$OUT" = folder ] || bad "a: sync of a folder with no .git printed [$OUT]"
[ "$before" = "$(snap "$C")" ] || bad "a: sync of a folder with no .git wrote something"
for k in b c; do
	gitcase "t57$k" notes-api
	if [ "$k" = b ]; then git -C "$S" config --unset glab.store; else git -C "$S" config glab.store false; fi
	plan_for notes-api
	ran report "$P" "$S"
	[ "$OUT" = "$S/$B/report.r1.md" ] || bad "$k: report printed [$OUT]"
	ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	[ "$OUT" = "$S/$B/verdict.r1.md" ] || bad "$k: verdict printed [$OUT]"
	[ "$(git -C "$S" rev-list --count HEAD)" = 1 ] || bad "$k: a commit was made"
	st=$(git -C "$S" status --porcelain --untracked-files=all)
	[ "$st" = "$(printf '?? %s\n' "$B/plan.r1/master.md" "$B/plan.r1/plan.md" "$B/report.r1.md" "$B/verdict.r1.md")" ] || bad "$k: status is [$st]"
	ran sync "$S"
	[ "$OUT" = folder ] || bad "$k: sync printed [$OUT]"
done
gitcase t57d notes-api
git -C "$S" config glab.store maybe
plan_for notes-api
grefused "glab.store of $S cannot be read (git exit 128); look at its .git/config" report "$P" "$S"
done_case T57 "a plain folder, and a repository whose glab.store is unset or false, run as 0.17.0 with no commit; glab.store maybe is refused"

# T58
gitcase t58 notes-api
plan_for notes-api
ran report "$P" "$S"
[ "$OUT" = "$S/$B/report.r1.md" ] || bad "stdout [$OUT] is not the report's path"
[ "$(tip)" = "$(git -C "$S" rev-parse HEAD)" ] || bad "the remote's main is not the clone's HEAD"
got=$(git -C "$S" diff --name-only main^ main)
[ "$got" = "$(printf '%s\n' "$B/plan.r1/master.md" "$B/plan.r1/plan.md" "$B/report.r1.md")" ] || bad "the commit holds [$got]"
[ "$(git -C "$S" log -1 --format=%s)" = 'store(report): notes-api r1 by notes-api' ] || bad "subject [$(git -C "$S" log -1 --format=%s)]"
[ "$(who "$S" HEAD)" = "$PG|$PG" ] || bad "author and committer [$(who "$S" HEAD)]"
got=$(git -C "$S" log -1 --format=%b)
[ "$got" = "$(printf '%s\n' "$B/report.r1.md" "$B/plan.r1/")" ] || bad "body [$got]"
for f in plan.r1/master.md plan.r1/plan.md report.r1.md; do
	[ "$(git -C "$S" cat-file blob "main:$B/$f" | h256)" = "$(h256 <"$S/$B/$f")" ] || bad "the blob of $f is not the file's bytes"
done
gclean "$S" "$(tip)"
gitcase t58b notes-api
plan_for notes-api
ran report "$P" "${S#"$W/"}"
[ "$OUT" = "${S#"$W/"}/$B/report.r1.md" ] || bad "relative: stdout [$OUT]"
[ "$(tip)" = "$(git -C "$S" rev-parse HEAD)" ] || bad "relative: the remote's main is not the clone's HEAD"
gclean "$S" "$(tip)"
done_case T58 "report on a clone commits exactly its files as glab plan-gate and pushes them, the store given absolute or relative"

# T59
gitcase t59 notes-api
plan_for notes-api
ran report "$P" "$S"
ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$OUT" = "$S/$B/verdict.r1.md" ] || bad "stdout [$OUT] is not the verdict's path"
[ "$(git -C "$S" log -1 --format=%s)" = 'store(verdict): notes-api r1 ACCEPTED by product-manager' ] || bad "subject [$(git -C "$S" log -1 --format=%s)]"
[ "$(git -C "$S" diff --name-only HEAD^ HEAD)" = "$B/verdict.r1.md" ] || bad "the commit holds [$(git -C "$S" diff --name-only HEAD^ HEAD)]"
gclean "$S" "$(tip)"
gitcase t59b notes-api
plan_for notes-api
round REJECTED product-manager "$C/no"
printf 'amended\n' >>"$P/plan.md"
round REJECTED product-manager "$C/no"
printf 'amended again\n' >>"$P/plan.md"
ran report "$P" "$S"
ran verdict "$S" notes-api REJECTED user "$C/user"
[ "$(git -C "$S" log -1 --format=%s)" = 'store(verdict): notes-api r3 REJECTED by user' ] || bad "subject at the cap [$(git -C "$S" log -1 --format=%s)]"
gclean "$S" "$(tip)"
done_case T59 "verdict on a clone commits its one file, ACCEPTED by product-manager and, at the cap, REJECTED by user"

# T60
gitcase t60 notes-api
plan_for notes-api
ran report "$P" "$S2"
ran verdict "$S2" notes-api ACCEPTED product-manager "$C/ok"
gate digest "$P"
d=$OUT
ran check "$P" "$S"
[ "$OUT" = "ACCEPTED r1 $d" ] || bad "check from the clone behind printed [$OUT]"
[ "$(git -C "$S" rev-parse HEAD)" = "$(tip)" ] || bad "check did not bring the clone to the remote's main"
mv "$C/remote.git" "$C/remote.away"
gate check "$P" "$S"
[ "$RC" -eq 2 ] && [ -z "$OUT" ] || bad "with no remote: rc=$RC [$OUT]"
one_line "$ERR" || bad "with no remote: stderr is not one line: [$ERR]"
case $ERR in 'plan-gate.sh: fetching the store from its remote origin failed'*) ;; *) bad "with no remote: stderr [$ERR]" ;; esac
case $ERR in *"$C/remote"*) bad "stderr names the remote's path: [$ERR]" ;; esac
mv "$C/remote.away" "$C/remote.git"
done_case T60 "check brings a clone behind up to date and passes; with its remote gone it exits 2, one line naming the remote by name"

# T61
gitcase t61 notes-api other-api
mkdir -p "$C/seed/releases" && printf 'r1\n' >"$C/seed/releases/r1.md"
{ git -C "$C/seed" add releases && tgit -C "$C/seed" commit -q -m r1 && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's second commit failed"
printf 'a local edit\n' >>"$S/briefs/other-api/brief.md"
ran sync "$S"
[ "$OUT" = "git $(tip)" ] || bad "sync printed [$OUT], not [git $(tip)]"
[ "$(git -C "$S" rev-parse HEAD)" = "$(tip)" ] || bad "sync did not fast-forward the clone"
if ! { [ "$(git -C "$S" status --porcelain --untracked-files=all)" = ' M briefs/other-api/brief.md' ] && grep -qx 'a local edit' "$S/briefs/other-api/brief.md"; }; then
	bad "the local edit was not kept"
fi
git -C "$S" checkout -q -- briefs/other-api/brief.md
mkdir -p "$S/briefs/web-app" && printf '# Brief — web-app\n\n## Goal\n\nShow notes.\n' >"$S/briefs/web-app/brief.md"
printf -- '- notes.md\n' >>"$S/docs/product-rules/index.md"
base=$(tip)
ran sync "$S" product-manager
[ "$OUT" = "git $(tip)" ] || bad "sync product-manager printed [$OUT], not [git $(tip)]"
[ "$(git -C "$C/remote.git" rev-parse main^)" = "$base" ] || bad "not one commit on the remote"
[ "$(git -C "$C/remote.git" log -1 --format=%s main)" = 'store(sync): 2 files by product-manager' ] || bad "subject [$(git -C "$C/remote.git" log -1 --format=%s main)]"
got=$(git -C "$C/remote.git" log -1 --format=%b main | grep -v '^$' | LC_ALL=C sort)
[ "$got" = "$(printf '%s\n' briefs/web-app/brief.md docs/product-rules/index.md)" ] || bad "body [$got]"
[ "$(who "$C/remote.git" main)" = "$PG|$PG" ] || bad "author and committer [$(who "$C/remote.git" main)]"
gclean "$S" "$(tip)"
mkdir -p "$S/releases" && printf 'x\n' >"$S/releases/x.md"
grefused 'the store clone has a change plan-gate.sh does not commit: releases/x.md; look at it' sync "$S" product-manager
gate sync "$S" user
usage_ok 'sync <store> user'
done_case T61 "sync fast-forwards and keeps local edits; with product-manager it commits a brief and a rule file, refuses any other change; a bad word is usage"

# T62 to T66 and T68 put a git stub first on PATH (stub, launched); it acts on a push alone and
# runs every other git command as the real one. A stub that runs git itself strips $STUB_C/bin: from
# PATH first, as T40 does.
# T62
gitcase t62 notes-api other-api
plan_for notes-api
plan_in "$C/plan2" other-api
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) if (set -C && : >"$STUB_C/fired") 2>/dev/null; then PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" report "$STUB_C/plan2" "$STUB_C/store" >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; fi ;; esac'
launched report "$P" "$S2"
[ "$RC" -eq 0 ] && [ "$OUT" = "$S2/$B/report.r1.md" ] && [ -z "$ERR" ] || bad "S2: rc=$RC [$OUT] [$ERR]"
[ "$(cat "$C/r2" 2>/dev/null)" = 0 ] || bad "the report from S exited [$(cat "$C/r2" 2>/dev/null)]: [$(cat "$C/e2" 2>/dev/null)]"
if ! { git -C "$C/remote.git" cat-file -e "main:$B/report.r1.md" && git -C "$C/remote.git" cat-file -e main:briefs/other-api/report.r1.md; }; then
	bad "the remote lacks a report"
fi
[ "$(git -C "$C/remote.git" rev-parse main^)" = "$(git -C "$S" rev-parse HEAD)" ] || bad "S2's commit does not sit on S's"
got=$(git -C "$C/remote.git" diff --name-only main^ main | grep -v "^$B/")
[ -z "$got" ] || bad "S2's commit touches [$got]"
ran sync "$S"
ran sync "$S2"
gclean "$S" "$(tip)"
gclean "$S2" "$(tip)"
done_case T62 "two projects' reports interleaved on one remote: the second is replayed on the first, both land"

# T63
gitcase t63 notes-api
plan_for notes-api
printf 'from S\n' >"$C/note"
base=$(tip)
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) if (set -C && : >"$STUB_C/fired") 2>/dev/null; then PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" report "$STUB_C/plan" "$STUB_C/store" "$STUB_C/note" >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; fi ;; esac'
launched report "$P" "$S2"
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: the store's remote changed $B/ while this run wrote r1; run it again" ] || bad "S2: rc=$RC [$OUT] [$ERR]"
[ "$(cat "$C/r2" 2>/dev/null)" = 0 ] || bad "the report from S exited [$(cat "$C/r2" 2>/dev/null)]"
git -C "$C/remote.git" show "main:$B/report.r1.md" | grep -qx 'from S' || bad "the remote's report.r1.md is not S's"
[ "$(git -C "$S2" rev-parse HEAD)" = "$base" ] || bad "S2's HEAD is not its base"
[ -z "$(git -C "$S2" status --porcelain --untracked-files=all)" ] || bad "S2 kept [$(git -C "$S2" status --porcelain --untracked-files=all)]"
ran sync "$S2"
gclean "$S2" "$(tip)"
done_case T63 "two writers of one r<n> on one remote: the second is refused and undone"

# T64
gitcase t64a notes-api
plan_for notes-api
ran report "$P" "$S"
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) if (set -C && : >"$STUB_C/fired") 2>/dev/null; then printf "and tags\n" >>"$STUB_C/store/briefs/notes-api/brief.md"; PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" sync "$STUB_C/store" product-manager >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; fi ;; esac'
launched verdict "$S2" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: the store's remote changed $B/ while this run wrote r1; run it again" ] || bad "a: rc=$RC [$OUT] [$ERR]"
[ "$(cat "$C/r2" 2>/dev/null)" = 0 ] || bad "a: the brief's sync exited [$(cat "$C/r2" 2>/dev/null)]: [$(cat "$C/e2" 2>/dev/null)]"
! git -C "$C/remote.git" cat-file -e "main:$B/verdict.r1.md" 2>/dev/null || bad "a: a verdict on the old brief landed"
gitcase t64b notes-api
plan_for notes-api
ran report "$P" "$S"
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) if (set -C && : >"$STUB_C/fired") 2>/dev/null; then PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" verdict "$STUB_C/store" notes-api REJECTED product-manager "$STUB_C/no" >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; fi ;; esac'
launched verdict "$S2" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: the store's remote changed $B/ while this run wrote r1; run it again" ] || bad "b: rc=$RC [$OUT] [$ERR]"
git -C "$C/remote.git" show "main:$B/verdict.r1.md" 2>/dev/null | grep -qx 'verdict: REJECTED' || bad "b: the remote's verdict.r1.md is not S's REJECTED"
gitcase t64c notes-api other-api
plan_for notes-api
plan_in "$C/plan2" other-api
round REJECTED product-manager "$C/no"
printf 'amended\n' >>"$P/plan.md"
ran report "$P" "$S"
base=$(tip)
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) if (set -C && : >"$STUB_C/fired") 2>/dev/null; then PATH=${PATH#"$STUB_C/bin:"} bash "$STUB_SCRIPT" report "$STUB_C/plan2" "$STUB_C/store" >"$STUB_C/o2" 2>"$STUB_C/e2"; echo $? >"$STUB_C/r2"; fi ;; esac'
launched verdict "$S2" notes-api ACCEPTED product-manager "$C/ok"
[ "$RC" -eq 0 ] && [ "$OUT" = "$S2/$B/verdict.r2.md" ] && [ -z "$ERR" ] || bad "c: rc=$RC [$OUT] [$ERR]"
[ "$(git -C "$C/remote.git" rev-parse main^)" != "$base" ] || bad "c: the verdict was not replayed"
got=$(git -C "$C/remote.git" diff --name-only "$base" main^ -- "$B/")
[ -z "$got" ] || bad "c: the state it landed on differs under $B/: [$got]"
done_case T64 "no verdict lands on a state it did not read: a brief or a verdict landed first is refused; another project's report is replayed over"

# T65
for k in 5 4; do
	gitcase "t65-$k" notes-api
	plan_for notes-api
	git clone -q "$C/remote.git" "$C/third" 2>/dev/null
	# shellcheck disable=SC2016 # expanded when the stub runs
	stub git 'case " $* " in *" push "*) k=$(($(cat "$STUB_C/count" 2>/dev/null || echo 0) + 1)); echo "$k" >"$STUB_C/count"; if [ "$k" -le "$STUB_MOVES" ]; then (PATH=${PATH#"$STUB_C/bin:"} && cd "$STUB_C/third" && git pull -q --ff-only origin main && mkdir -p releases && echo "$k" >"releases/n$k.md" && git add releases && git -c user.name=t -c user.email=t@t.invalid commit -q -m "n$k" && git push -q origin HEAD:main) >/dev/null 2>&1; fi ;; esac'
	STUB_MOVES=$k launched report "$P" "$S"
	[ "$(cat "$C/count" 2>/dev/null)" = 5 ] || bad "$k moves: [$(cat "$C/count" 2>/dev/null)] pushes, not 5"
	if [ "$k" = 5 ]; then
		[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: the store's remote moved 5 times while this run pushed; run it again" ] || bad "5 moves: rc=$RC [$OUT] [$ERR]"
		got=$(git -C "$C/remote.git" ls-tree -r --name-only main -- "$B/")
		[ "$got" = "$B/brief.md" ] || bad "5 moves: the remote holds [$got]"
		gclean "$S" "$(git -C "$C/remote.git" rev-parse main^)"
	else
		[ "$RC" -eq 0 ] && [ "$OUT" = "$S/$B/report.r1.md" ] && [ -z "$ERR" ] || bad "4 moves: rc=$RC [$OUT] [$ERR]"
		gclean "$S" "$(tip)"
	fi
done
done_case T65 "a remote that moves before each of 5 pushes is refused, undone at the last base; one that moves 4 times takes the 5th"

# T66
gitcase t66a notes-api
plan_for notes-api
printf '#!/bin/sh\nexit 1\n' >"$C/remote.git/hooks/pre-receive" && chmod +x "$C/remote.git/hooks/pre-receive"
base=$(tip)
gate report "$P" "$S"
[ "$RC" -eq 2 ] && [ -z "$OUT" ] || bad "a: rc=$RC [$OUT]"
one_line "$ERR" || bad "a: stderr is not one line: [$ERR]"
case $ERR in 'plan-gate.sh: pushing the store to its remote origin failed (git exit 1), and the remote did not move'*) ;; *) bad "a: stderr [$ERR]" ;; esac
case $ERR in *"$C/remote.git"*) bad "a: stderr names the remote's path" ;; esac
[ "$(tip)" = "$base" ] || bad "a: the remote moved"
[ "$(git -C "$S" rev-parse HEAD)" = "$base" ] && [ ! -e "$S/$B/report.r1.md" ] && [ ! -e "$S/$B/plan.r1" ] || bad "a: not undone"
gclean "$S" "$base"
gitcase t66b notes-api
plan_for notes-api
base=$(tip)
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) : >"$STUB_C/pushed"; exit 1 ;; *" fetch "*) [ ! -e "$STUB_C/pushed" ] || exit 1 ;; esac'
launched report "$P" "$S"
[ "$RC" -eq 2 ] && [ -z "$OUT" ] || bad "b: rc=$RC [$OUT]"
one_line "$ERR" || bad "b: stderr is not one line: [$ERR]"
case $ERR in "plan-gate.sh: pushing the store to its remote origin failed, and fetching it again failed (git exit 1); whether this run's commit "*" landed is unknown - run sync") ;; *) bad "b: stderr [$ERR]" ;; esac
[ "$(git -C "$S" rev-parse HEAD)" = "$base" ] && [ ! -e "$S/$B/report.r1.md" ] && [ ! -e "$S/$B/plan.r1" ] || bad "b: not undone"
gclean "$S" "$base"
done_case T66 "a remote that refuses the push, or a fetch that fails after it: exit 2, one line naming the remote by name, the run undone"

# T67
r4() { printf "the store clone has a change under %s/ that is not committed: %s; look at it, and commit, push or remove it by hand" "$B" "$1"; }
gitcase t67a notes-api
plan_for notes-api
printf 'edited\n' >>"$S/$B/brief.md"
grefused "$(r4 "$B/brief.md")" report "$P" "$S"
gitcase t67b notes-api
plan_for notes-api
printf 'x\n' >"$S/$B/report.r9.md"
grefused "$(r4 "$B/report.r9.md")" report "$P" "$S"
gitcase t67c notes-api
plan_for notes-api
mkdir -p "$S/docs/x" && printf 'x\n' >"$S/docs/x/a.md" && git -C "$S" add docs/x && tgit -C "$S" commit -q -m ahead
grefused "the store clone has commit $(git -C "$S" rev-parse HEAD) that its remote does not have; push it or remove it by hand" report "$P" "$S"
gitcase t67d notes-api
plan_for notes-api
printf 'y\n' >"$S/y.md" && git -C "$S" add y.md
grefused 'the store clone has staged changes; unstage them by hand' report "$P" "$S"
gitcase t67e notes-api
plan_for notes-api
printf -- '- from the remote\n' >>"$C/seed/docs/product-rules/index.md"
{ tgit -C "$C/seed" commit -q -am rules && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1
printf -- '- from the clone\n' >>"$S/docs/product-rules/index.md"
grefused "the store's remote changed docs/product-rules/index.md, which the store clone has changed too; look at both" report "$P" "$S"
gitcase t67f notes-api
plan_for notes-api
git -C "$S" checkout -q -b local
grefused "the store clone's branch local has no upstream on a remote" report "$P" "$S"
gitcase t67g notes-api
plan_for notes-api
mkdir -p "$C/nogit"
for t in bash cat chmod cp cut date dirname find grep head awk mkdir mktemp mv rm sort tr wc sha256sum shasum uname readlink ln; do
	p=$(command -v "$t") && ln -s "$p" "$C/nogit/$t"
done
[ -z "$(PATH=$C/nogit command -v git)" ] || bad "g: git is still on the test PATH"
before=$(gsnap)
OUT=$(PATH=$C/nogit "$C/nogit/bash" "$SCRIPT" report "$P" "$S" 2>"$W/err")
RC=$?
ERR=$(cat "$W/err")
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: $S holds .git and git is not on PATH, so plan-gate.sh cannot tell whether it is a store clone" ] || bad "g: rc=$RC [$OUT] [$ERR]"
[ "$before" = "$(gsnap)" ] || bad "g: the refusal wrote something"
gitcase t67h notes-api
plan_for notes-api
base=$(tip)
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) if (set -C && : >"$STUB_C/fired") 2>/dev/null; then (PATH=${PATH#"$STUB_C/bin:"} && git init -q -b main "$STUB_C/third" && cd "$STUB_C/third" && echo root >root.md && git add root.md && git -c user.name=t -c user.email=t@t.invalid commit -q -m root && git push -q -f "$STUB_C/remote.git" HEAD:main) >/dev/null 2>&1; fi ;; esac'
launched report "$P" "$S"
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: the store's remote no longer holds this clone's commit $base; look at its history" ] || bad "h: rc=$RC [$OUT] [$ERR]"
[ "$(git -C "$S" rev-parse HEAD)" = "$base" ] && [ ! -e "$S/$B/report.r1.md" ] && [ ! -e "$S/$B/plan.r1" ] || bad "h: the run's commit is not undone"
gitcase t67i notes-api
plan_for notes-api
git -C "$S" checkout -q --detach
grefused "the store clone $S is on no branch" report "$P" "$S"
newcase t67j
{ git init -q --bare -b main "$C/remote.git" && rmdir "$S" && git clone -q -c core.autocrlf=false -c glab.store=true "$C/remote.git" "$S"; } >/dev/null 2>&1 || bad "j: no empty remote and clone"
grefused "the store's remote branch has no commit; make its first commit by hand" sync "$S"
gitcase t67k notes-api
plan_for notes-api
seed=$(git -C "$C/seed" rev-parse HEAD; git -C "$C/seed" for-each-ref)
GIT_DIR=$C/seed/.git gate report "$P" "$S"
[ "$RC" -eq 0 ] && [ "$OUT" = "$S/$B/report.r1.md" ] && [ -z "$ERR" ] || bad "k: rc=$RC [$OUT] [$ERR]"
git -C "$C/remote.git" cat-file -e "main:$B/report.r1.md" || bad "k: the report is not on S's remote"
[ "$seed" = "$(git -C "$C/seed" rev-parse HEAD; git -C "$C/seed" for-each-ref)" ] || bad "k: the seed's HEAD or refs moved"
gitcase t67l notes-api
plan_for notes-api
base=$(tip)
printf '#!/bin/sh\nexit 1\n' >"$S/.git/hooks/pre-commit" && chmod +x "$S/.git/hooks/pre-commit"
gate report "$P" "$S"
[ "$RC" -eq 2 ] && [ -z "$OUT" ] && [ "$ERR" = 'plan-gate.sh: committing to the store failed (git exit 1)' ] || bad "l: rc=$RC [$OUT] [$ERR]"
gclean "$S" "$base"
gitcase t67m notes-api
plan_for notes-api
before=$(gsnap)
GIT_TEST_ASSUME_DIFFERENT_OWNER=1 gate report "$P" "$S"
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "REFUSED: git refuses the store clone $S (git exit 128); if another account owns it, see git's safe.directory" ] || bad "m: rc=$RC [$OUT] [$ERR]"
[ "$before" = "$(gsnap)" ] || bad "m: the refusal wrote something"
done_case T67 "each precondition of a clone is refused writing nothing: a change under the brief's folder, a commit ahead, a staged file, an overlap, no upstream, no git, a rewritten remote, no branch, an empty remote, a pre-commit hook, another owner; a GIT_DIR of the caller is ignored"

# T68
gitcase t68 notes-api
plan_for notes-api
base=$(tip)
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) kill -TERM "$(cat "$STUB_C/pid")"; exit 1 ;; esac'
launched report "$P" "$S"
[ "$RC" -eq 143 ] || bad "the run exited $RC, not 143: [$ERR]"
[ "$(git -C "$S" rev-parse HEAD)" = "$base" ] || bad "HEAD is not the base"
git -C "$S" diff --cached --quiet || bad "something is staged"
[ ! -e "$S/$B/report.r1.md" ] && [ ! -e "$S/$B/plan.r1" ] || bad "the report or plan.r1/ was left"
[ "$(tip)" = "$base" ] || bad "the remote moved"
gclean "$S" "$base"
done_case T68 "a TERM between commit and push undoes the commit, unstages, removes the report and plan.r1/, and leaves no .plan-gate.*"

# T69
gitcase t69 notes-api
plan_for notes-api
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) PATH=${PATH#"$STUB_C/bin:"} git "$@" >/dev/null 2>&1; exit 1 ;; esac'
launched report "$P" "$S"
[ "$RC" -eq 0 ] && [ "$OUT" = "$S/$B/report.r1.md" ] && [ -z "$ERR" ] || bad "rc=$RC [$OUT] [$ERR]"
git -C "$C/remote.git" cat-file -e "main:$B/report.r1.md" || bad "the report is not on the remote"
gclean "$S" "$(tip)"
done_case T69 "a push that landed and then failed is told by the remote's tip: exit 0, nothing undone"

# T70
for i in 1 2 3 4 5 6 7 8 9 10; do
	gitcase "t70a-$i" notes-api
	plan_for notes-api
	# Two notes, so that the two reports differ: two runs that write the same bytes in the same second
	# make one commit, the same sha, and the remote's tip is then each run's own commit - both land,
	# rightly, and the race is not one (plan-gate.sh, store_push).
	printf 'from S\n' >"$C/n1" && printf 'from S2\n' >"$C/n2"
	bash "$SCRIPT" report "$P" "$S" "$C/n1" >"$C/o1" 2>"$C/e1" &
	p1=$!
	BG=$p1
	bash "$SCRIPT" report "$P" "$S2" "$C/n2" >"$C/o2" 2>"$C/e2" &
	p2=$!
	BG="$p1 $p2"
	wait "$p1"
	r1=$?
	wait "$p2"
	r2=$?
	BG=''
	case "$r1 $r2" in
	'0 1') lost=2 ;;
	'1 0') lost=1 ;;
	*) lost='' && bad "a$i: the runs exited $r1 and $r2: [$(cat "$C/e1" "$C/e2")]" ;;
	esac
	if [ -n "$lost" ]; then
		case $(cat "$C/e$lost") in
		"REFUSED: the store's remote changed $B/ while this run wrote r1; run it again" | 'REFUSED: report r1 has no verdict yet') ;;
		*) bad "a$i: the losing run said [$(cat "$C/e$lost")]" ;;
		esac
	fi
	got=$(git -C "$C/remote.git" ls-tree -r --name-only main -- "$B/" | grep -c 'report\.r[0-9]*\.md$')
	[ "$got" = 1 ] || bad "a$i: the remote holds $got reports"
	gitcase "t70b-$i" notes-api other-api
	plan_for notes-api
	plan_in "$C/plan2" other-api
	bash "$SCRIPT" report "$P" "$S" >"$C/o1" 2>"$C/e1" &
	p1=$!
	BG=$p1
	bash "$SCRIPT" report "$C/plan2" "$S2" >"$C/o2" 2>"$C/e2" &
	p2=$!
	BG="$p1 $p2"
	wait "$p1"
	r1=$?
	wait "$p2"
	r2=$?
	BG=''
	[ "$r1 $r2" = '0 0' ] || bad "b$i: the runs exited $r1 and $r2: [$(cat "$C/e1" "$C/e2")]"
	if ! { git -C "$C/remote.git" cat-file -e "main:$B/report.r1.md" && git -C "$C/remote.git" cat-file -e main:briefs/other-api/report.r1.md; }; then
		bad "b$i: the remote lacks a report"
	fi
done
done_case T70 "10 rounds of two clones at once: one r1 of one project lands once, the other refused; two projects both land"

# T71
gitcase t71 notes-api
plan_for notes-api
mkdir -p "$C/xdg/git"
printf '[core]\n\tautocrlf = true\n[commit]\n\tgpgSign = true\n[push]\n\tgpgSign = true\n[merge]\n\tverifySignatures = true\n[gc]\n\tauto = 1\n[author]\n\tname = hostile author\n[committer]\n\temail = hostile-committer@glab.invalid\n' >"$C/gitconfig"
printf '*.md text eol=crlf\n' >"$C/xdg/git/attributes"
printf 'report.r*.md\n' >"$C/xdg/git/ignore"
# The clones' own core.autocrlf=false, set by gitcase as the user sets it, is unset: else it hid the
# hostile autocrlf=true and this case passed without plan-gate.sh's own -c settings
# [remote-store/review-r1.md A3].
{ git -C "$S" config --unset core.autocrlf && git -C "$S2" config --unset core.autocrlf; } || bad "unsetting the clones' core.autocrlf failed"
# Prefixes on the two runs alone, never exported: $W/xdg is every case's, and hostile files there
# would turn the next case's brief.md CRLF and hide an untracked report from the clean check
# [remote-store/check-r2-code.md N3].
GIT_CONFIG_GLOBAL=$C/gitconfig XDG_CONFIG_HOME=$C/xdg GIT_AUTHOR_NAME='hostile author env' GIT_COMMITTER_EMAIL=hostile-env@glab.invalid ran report "$P" "$S"
GIT_CONFIG_GLOBAL=$C/gitconfig XDG_CONFIG_HOME=$C/xdg GIT_AUTHOR_NAME='hostile author env' GIT_COMMITTER_EMAIL=hostile-env@glab.invalid ran verdict "$S2" notes-api ACCEPTED product-manager "$C/ok"
[ "$(who "$C/remote.git" main^)" = "$PG|$PG" ] || bad "the report's author and committer [$(who "$C/remote.git" main^)]"
[ "$(who "$C/remote.git" main)" = "$PG|$PG" ] || bad "the verdict's author and committer [$(who "$C/remote.git" main)]"
[ "$(git -C "$C/remote.git" cat-file blob "main:$B/plan.r1/plan.md" | h256)" = "$(h256 <"$P/plan.md")" ] || bad "the remote's plan.r1/plan.md is not the plan's bytes"
[ "$(h256 <"$S2/$B/brief.md")" = "$(h256 <"$S/$B/brief.md")" ] || bad "S2 reads brief.md with other bytes"
done_case T71 "a hostile git config, attributes, ignore file and identity in the environment change no byte and no author"

# T72
gitcase t72 notes-api
plan_for notes-api
if [ -n "$PROC" ]; then
	claim=$(git -C "$S" rev-parse --absolute-git-dir)/.plan-gate.claim.store
	sleep 30 &
	sp=$!
	BG=$sp
	owner "$sp" "$(started "$sp")" >"$claim"
	grefused 'another run is using the store clone' report "$P" "$S"
	kill "$sp" 2>/dev/null
	wait "$sp" 2>/dev/null
	BG=''
	owner "$(dead_pid)" 1 >"$claim"
	ran report "$P" "$S"
	[ "$OUT" = "$S/$B/report.r1.md" ] || bad "the run that took the clone claim over printed [$OUT]"
	gclean "$S" "$(tip)"
	done_case T72 "a live run's clone claim is refused at once, naming nothing to remove; a dead run's is taken over and nothing is left"
else
	done_case T72 "a live run's clone claim is refused, a dead run's taken over (skipped: no /proc)"
fi

# T73
gitcase t73 notes-api
plan_for notes-api
printf '# Questions\n\nnone\n' >"$P/questions.md"
# The store's own .gitignore, committed: it names a file of the copy folder, the verdict and every
# brief. A report and a verdict commit their files all the same; sync refuses a new brief it would
# not commit [remote-store/review-r1.md A1].
printf 'questions.md\nverdict.r*.md\nbrief.md\n' >"$C/seed/.gitignore"
{ git -C "$C/seed" add .gitignore && tgit -C "$C/seed" commit -q -m ignore && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's .gitignore commit failed"
ran report "$P" "$S"
git -C "$C/remote.git" cat-file -e "main:$B/plan.r1/questions.md" 2>/dev/null || bad "the remote's plan.r1/ lacks questions.md"
gclean "$S" "$(tip)"
ran verdict "$S2" notes-api ACCEPTED product-manager "$C/ok"
git -C "$C/remote.git" cat-file -e "main:$B/verdict.r1.md" 2>/dev/null || bad "the remote lacks verdict.r1.md"
gclean "$S2" "$(tip)"
ran check "$P" "$S"
[ "${OUT%% *}" = ACCEPTED ] || bad "check on the first clone printed [$OUT]"
mkdir -p "$S/briefs/web-app" && printf '# Brief — web-app\n\n## Goal\n\nShow notes.\n' >"$S/briefs/web-app/brief.md"
grefused "the store clone ignores briefs/web-app/brief.md, so sync does not commit it; look at the store's .gitignore" sync "$S" product-manager
done_case T73 "the store's own .gitignore drops no file a report or verdict wrote; sync refuses a brief it ignores"

# T74
if [ -n "$PROC" ]; then
	# (b) first, in the background: a check on a clone whose claim's run stays alive is refused once
	# the wait is over, about 30 s later, naming nothing to remove. (a) runs meanwhile: a sync on a
	# clone whose live run's claim goes after 2 s takes the claim then and runs [remote-store/review-r1.md A2].
	gitcase t74b notes-api
	plan_for notes-api
	cb=$C claimb=$(git -C "$S" rev-parse --absolute-git-dir)/.plan-gate.claim.store
	sleep 60 &
	hb=$!
	BG=$hb
	owner "$hb" "$(started "$hb")" >"$claimb"
	lineb=$(cat "$claimb")
	tb=$(date +%s)
	bash "$SCRIPT" check "$P" "$S" >"$cb/ob" 2>"$cb/eb" &
	rb=$!
	BG="$hb $rb"
	gitcase t74a notes-api
	claima=$(git -C "$S" rev-parse --absolute-git-dir)/.plan-gate.claim.store
	sleep 60 &
	ha=$!
	BG="$hb $rb $ha"
	owner "$ha" "$(started "$ha")" >"$claima"
	(sleep 2 && rm -f -- "$claima") &
	ga=$!
	BG="$hb $rb $ha $ga"
	ta=$(date +%s)
	gate sync "$S"
	ta=$(($(date +%s) - ta))
	[ "$RC" -eq 0 ] && [ "$OUT" = "git $(tip)" ] && [ -z "$ERR" ] || bad "a: the sync that waited: rc=$RC [$OUT] [$ERR]"
	[ "$ta" -ge 1 ] || bad "a: the sync did not wait, ${ta} s"
	wait "$ga"
	kill "$ha" 2>/dev/null
	wait "$ha" 2>/dev/null
	BG="$hb $rb"
	gclean "$S" "$(tip)"
	wait "$rb"
	r=$?
	tb=$(($(date +%s) - tb))
	BG=$hb
	[ "$r" -eq 1 ] && [ -z "$(cat "$cb/ob")" ] && [ "$(cat "$cb/eb")" = 'REFUSED: another run is using the store clone' ] ||
		bad "b: the check on a live claim: rc=$r [$(cat "$cb/ob")] [$(cat "$cb/eb")]"
	[ "$tb" -ge 29 ] || bad "b: the check was refused after ${tb} s, not after its wait"
	[ "$(cat "$claimb" 2>/dev/null)" = "$lineb" ] || bad "b: the live run's claim changed or went"
	kill "$hb" 2>/dev/null
	wait "$hb" 2>/dev/null
	BG=''
	rm -f -- "$claimb"
	done_case T74 "a reader waits on a live run's clone claim: it runs once the claim goes, and is refused after 30 s, naming nothing to remove"
else
	done_case T74 "a reader waits on a live run's clone claim (skipped: no /proc)"
fi

# T75
gitcase t75 notes-api
plan_for notes-api
# A GIT_CONFIG naming another upstream ref: git config reads it as its --file, so the push went
# there. plan-gate.sh unsets it [remote-store/review-r1.md A4]. A prefix on the run alone.
printf '[branch "main"]\n\tremote = origin\n\tmerge = refs/heads/hostile\n[remote "origin"]\n\turl = %s\n' "$C/remote.git" >"$C/hostile"
GIT_CONFIG=$C/hostile ran report "$P" "$S"
[ "$(git -C "$S" rev-parse HEAD)" = "$(tip)" ] || bad "the report did not land on the remote's main"
if git -C "$C/remote.git" rev-parse -q --verify refs/heads/hostile >/dev/null; then bad "the report was pushed to the ref GIT_CONFIG names"; fi
gclean "$S" "$(tip)"
done_case T75 "a GIT_CONFIG of the caller is ignored: the report lands on the clone's own upstream"

# T76
gitcase t76 notes-api
plan_for notes-api
# One REFUSED line for a path with a newline or a tab: each is written \n or \t
# [remote-store/review-r1.md A5].
printf 'a\n' >"$S/$B/x"$'\n'"y.md"
grefused "$(r4 "$B/x\\ny.md")" report "$P" "$S"
rm -f -- "$S/$B/x"$'\n'"y.md"
printf 'a\n' >"$S/docs/product-rules/x"$'\t'"y.md"
grefused 'the store clone has a change plan-gate.sh does not commit: docs/product-rules/x\ty.md; look at it' sync "$S" product-manager
rm -f -- "$S/docs/product-rules/x"$'\t'"y.md"
done_case T76 "a path with a newline or a tab is refused in one line, written \\n or \\t"

# T77
gitcase t77 notes-api
# sync product-manager refuses a brief or rule file that is a symlink: git would commit the link
# [remote-store/review-r1.md A6].
printf '# Brief — web-app\n\n## Goal\n\nShow notes.\n' >"$C/elsewhere.md"
mkdir -p "$S/briefs/web-app" && ln -s "$C/elsewhere.md" "$S/briefs/web-app/brief.md"
grefused 'the store clone has a change plan-gate.sh does not commit: briefs/web-app/brief.md, not a regular file; replace it with the file' sync "$S" product-manager
rm -f -- "$S/briefs/web-app/brief.md"
ln -s index.md "$S/docs/product-rules/links.md"
grefused 'the store clone has a change plan-gate.sh does not commit: docs/product-rules/links.md, not a regular file; replace it with the file' sync "$S" product-manager
rm -f -- "$S/docs/product-rules/links.md"
[ "$(tip)" = "$(git -C "$S" rev-parse HEAD)" ] || bad "a commit landed"
done_case T77 "sync product-manager refuses a brief or rule file that is a symlink, committing nothing"

# T78
gitcase t78a notes-api
plan_for notes-api
# The config names git reads from the environment, each a prefix on one run alone: a pushurl by
# GIT_CONFIG_COUNT and an upstream ref by GIT_CONFIG_PARAMETERS each redirected the push; then
# GIT_LITERAL_PATHSPECS undid sync's refusal of an ignored brief [remote-store/review-r2.md A7].
git init -q --bare -b main "$C/elsewhere.git" || bad "no second remote"
GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=remote.origin.pushurl GIT_CONFIG_VALUE_0=$C/elsewhere.git ran report "$P" "$S"
[ "$(git -C "$S" rev-parse HEAD)" = "$(tip)" ] || bad "the report did not land on the remote's main"
[ -z "$(git -C "$C/elsewhere.git" for-each-ref)" ] || bad "the report was pushed to the pushurl GIT_CONFIG_COUNT names"
GIT_CONFIG_PARAMETERS="'branch.main.merge'='refs/heads/hostile'" ran verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
[ "$(git -C "$S" rev-parse HEAD)" = "$(tip)" ] || bad "the verdict did not land on the remote's main"
if git -C "$C/remote.git" rev-parse -q --verify refs/heads/hostile >/dev/null; then bad "the verdict was pushed to the ref GIT_CONFIG_PARAMETERS names"; fi
gclean "$S" "$(tip)"
gitcase t78b notes-api
printf 'brief.md\n' >"$C/seed/.gitignore"
{ git -C "$C/seed" add .gitignore && tgit -C "$C/seed" commit -q -m ignore && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's .gitignore commit failed"
ran sync "$S"
mkdir -p "$S/briefs/web-app" && printf '# Brief — web-app\n\n## Goal\n\nShow notes.\n' >"$S/briefs/web-app/brief.md"
GIT_LITERAL_PATHSPECS=1 grefused "the store clone ignores briefs/web-app/brief.md, so sync does not commit it; look at the store's .gitignore" sync "$S" product-manager
done_case T78 "GIT_CONFIG_COUNT, GIT_CONFIG_PARAMETERS and GIT_LITERAL_PATHSPECS of the caller are ignored"

# T79
if [ -n "$PROC" ]; then
	gitcase t79 notes-api
	plan_for notes-api
	# A verdict run killed by SIGKILL after it published verdict.r1.md, which the store's .gitignore
	# hides from git status: the next check takes the dead run's clone claim over and must refuse on
	# that file, not read it as the verdict [remote-store/review-r2.md A8].
	printf 'verdict.r*.md\n' >"$C/seed/.gitignore"
	{ git -C "$C/seed" add .gitignore && tgit -C "$C/seed" commit -q -m ignore && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's .gitignore commit failed"
	ran report "$P" "$S"
	# shellcheck disable=SC2016 # expanded when the stub runs
	stub git 'case " $* " in *" add "*) kill -KILL "$(cat "$STUB_C/pid")"; exit 1 ;; esac'
	launched verdict "$S" notes-api ACCEPTED product-manager "$C/ok"
	rm -f -- "$C/bin/git"
	[ "$RC" -eq 137 ] && [ -f "$S/$B/verdict.r1.md" ] || bad "the killed verdict run: rc=$RC, verdict.r1.md left: $([ -f "$S/$B/verdict.r1.md" ] && echo yes || echo no)"
	grefused "$(r4 "$B/verdict.r1.md")" check "$P" "$S"
	rm -f -- "$S/$B/.plan-gate.claim.verdict.r1" "$S/$B/verdict.r1.md"
	done_case T79 "an ignored verdict.r1.md a killed verdict run left is refused by the next check, not read as the verdict"
else
	done_case T79 "an ignored verdict.r1.md a killed verdict run left is refused (skipped: no /proc)"
fi

# T80
gitcase t80 notes-api
plan_for notes-api
base=$(tip)
# A git stub whose push runs the real push, then sends TERM to the run: the push landed, and the
# trap must not undo it [remote-store/review-r2.md A9].
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) PATH=${PATH#"$STUB_C/bin:"} git "$@" >/dev/null 2>&1; kill -TERM "$(cat "$STUB_C/pid")"; exit 0 ;; esac'
launched report "$P" "$S"
[ "$RC" -eq 143 ] || bad "the run exited $RC, not 143: [$ERR]"
{ [ "$(tip)" != "$base" ] && git -C "$C/remote.git" cat-file -e "main:$B/report.r1.md" 2>/dev/null; } || bad "the report is not on the remote"
[ -f "$S/$B/report.r1.md" ] && [ -d "$S/$B/plan.r1" ] || bad "the clone lost report.r1.md or plan.r1/"
gclean "$S" "$(tip)"
done_case T80 "a TERM after the push landed undoes nothing: the report stays on the remote and in the clone"

# T81
gitcase t81 notes-api
# A store clone whose path holds a newline: the refusal naming it is one line, the newline written
# \n [remote-store/review-r2.md A10].
nl=$C/st$'\n'ore
{ git clone -q -c core.autocrlf=false -c glab.store=true "$C/remote.git" "$nl" && git -C "$nl" checkout -q --detach; } >/dev/null 2>&1 || bad "no clone at a path with a newline"
grefused "the store clone $C/st\\nore is on no branch" sync "$nl"
done_case T81 "a store path with a newline is printed in one line, written \\n"

# T82
gitcase t82 notes-api
# (a) An untracked rule file named docs/product-rules/*.md beside an excluded private/secret.md:
# sync refuses the name, and nothing reaches the remote. (b) A remote path read as a glob would match
# an ignored local file of another name; as a literal pathspec it does not, and sync runs
# [remote-store/review-r3.md A11].
printf 'private/\na.md\n' >>"$S/.git/info/exclude"
mkdir -p "$S/docs/product-rules/private" && printf 'secret\n' >"$S/docs/product-rules/private/secret.md"
printf -- '- a rule\n' >"$S/docs/product-rules/*.md"
grefused 'the store clone has a change plan-gate.sh does not commit: docs/product-rules/*.md; look at it' sync "$S" product-manager
if git -C "$C/remote.git" log --all --format=%H -- docs/product-rules/private | grep -q .; then bad "a: secret.md reached the remote"; fi
rm -f -- "$S/docs/product-rules/*.md"
printf 'mine\n' >"$S/docs/product-rules/a.md"
printf 'theirs\n' >"$C/seed/docs/product-rules/[a].md"
{ git -C "$C/seed" add -A && tgit -C "$C/seed" commit -q -m bracket && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's second commit failed"
ran sync "$S"
[ "$OUT" = "git $(tip)" ] || bad "b: sync printed [$OUT], not [git $(tip)]"
[ "$(cat "$S/docs/product-rules/a.md")" = mine ] || bad "b: the ignored a.md changed"
done_case T82 "a rule file named as a glob is refused and no excluded file is pushed; a remote path is a literal pathspec"

# T83
gitcase t83 notes-api
# An ignored local file at a path the remote then adds: the fast-forward would overwrite it without
# a word, and is refused instead [remote-store/review-r3.md A12].
printf 'local.md\n' >>"$S/.git/info/exclude"
printf 'mine\n' >"$S/docs/product-rules/local.md"
printf 'theirs\n' >"$C/seed/docs/product-rules/local.md"
{ git -C "$C/seed" add -A && tgit -C "$C/seed" commit -q -m local && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's second commit failed"
grefused "the store's remote changed docs/product-rules/local.md, which the store clone holds as an ignored file; look at both" sync "$S"
done_case T83 "a fast-forward that would overwrite an ignored local file is refused, the file kept"

# T84
gitcase t84 notes-api
plan_for notes-api
# The push lands, a third clone pushes on top of it, then TERM: the trap's fetch finds the run's
# commit under the remote's tip, so it landed and is not undone [remote-store/review-r3.md A13].
# shellcheck disable=SC2016 # expanded when the stub runs
stub git 'case " $* " in *" push "*) PATH=${PATH#"$STUB_C/bin:"}; git "$@" >/dev/null 2>&1; (git clone -q "$STUB_C/remote.git" "$STUB_C/third" && cd "$STUB_C/third" && echo n >n.md && git add n.md && git -c user.name=t -c user.email=t@t.invalid commit -q -m n && git push -q origin HEAD:main) >/dev/null 2>&1; kill -TERM "$(cat "$STUB_C/pid")"; exit 0 ;; esac'
launched report "$P" "$S"
[ "$RC" -eq 143 ] || bad "the run exited $RC, not 143: [$ERR]"
git -C "$C/remote.git" cat-file -e "main:n.md" 2>/dev/null || bad "the third clone's commit is not on the remote"
[ "$(git -C "$S" rev-parse HEAD)" = "$(git -C "$C/remote.git" rev-parse main^)" ] || bad "the clone's commit was undone"
[ -f "$S/$B/report.r1.md" ] && [ -d "$S/$B/plan.r1" ] || bad "the clone lost report.r1.md or plan.r1/"
gclean "$S" "$(git -C "$C/remote.git" rev-parse main^)"
done_case T84 "a TERM after a push that another push already built on undoes nothing"

# T85
newcase t85
# A clone made before the store's first push, as README.md sets one up, holding an excluded
# docs/product-rules/index.md; the first push then brings that path. The commit-less fast-forward
# would overwrite it, and is refused instead [remote-store/review-r3.md A12a].
{ git init -q --bare -b main "$C/remote.git" && rmdir "$S" && git clone -q -c core.autocrlf=false -c glab.store=true "$C/remote.git" "$S"; } >/dev/null 2>&1 || bad "no empty remote and clone"
printf 'index.md\n' >>"$S/.git/info/exclude"
mkdir -p "$S/docs/product-rules" && printf 'mine\n' >"$S/docs/product-rules/index.md"
{ git clone -q "$C/remote.git" "$C/seed" && mkdir -p "$C/seed/docs/product-rules" && printf 'theirs\n' >"$C/seed/docs/product-rules/index.md" &&
	git -C "$C/seed" add -A && tgit -C "$C/seed" commit -q -m first && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the first push failed"
grefused "the store's remote changed docs/product-rules/index.md, which the store clone holds as an ignored file; look at both" sync "$S"
done_case T85 "a clone with no commit yet refuses a first fast-forward that would overwrite an ignored file"

# T86
gitcase t86 notes-api
# An excluded local file docs/x; the remote then brings docs/x/y.md. The fast-forward would delete
# docs/x to make the folder, and is refused instead [remote-store/review-r3.md A12b].
printf 'x\n' >>"$S/.git/info/exclude"
printf 'mine\n' >"$S/docs/x"
mkdir -p "$C/seed/docs/x" && printf 'theirs\n' >"$C/seed/docs/x/y.md"
{ git -C "$C/seed" add -A && tgit -C "$C/seed" commit -q -m x && git -C "$C/seed" push -q origin HEAD:main; } >/dev/null 2>&1 || bad "the seed's second commit failed"
grefused "the store's remote changed docs/x/y.md, under docs/x, which the store clone holds as an untracked file; look at both" sync "$S"
done_case T86 "a fast-forward that would delete an ignored file at a parent folder of a path it brings is refused"

# T22 last: judged over every store the cases above wrote, and every git dir in them
left=$(find "$W" -name '.plan-gate.*')
[ -z "$left" ] || bad "temporary files left: $left"
done_case T22 "no temporary file is left in any store after any run"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
