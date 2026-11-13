# Steps 1 — the gate script and its test (A1–A2)

Each file below is given in full, between a line `~~~<language> file=<path>` and
a line `~~~`. Write it with exactly that text — the helper `X` of `plan.md`
*The post helper* compares the two byte for byte — and a script or test at
mode 0755 (`chmod 755`, then `git update-index --chmod=+x <path>` if git kept
another mode). A change to one of these texts is an amendment of this file,
never an edit of the built file alone.

The texts keep the repo's rules for scripts and tests (`AGENTS.md` *Tests* and
*Rules*): `#!/usr/bin/env bash`; shellcheck clean; work directories only from
`mktemp -d "${TMPDIR:?…}/<name>.XXXXXX"`, removed by an `EXIT` trap; no
background process, so there is nothing to kill by PID; a test prints
`ok <id> <what>` or `FAIL <id> <what>: <reason>` per case and a last line
`PASS <n>/<n>`, or `FAIL <k>/<n>` with exit 1, as `tests/context-size.test.sh`
does, and exits 2 with its usage line when an argument is missing. The
contracts C1–C11 are in `plan.md`; the comments state what they say and never
cite `C<n>`, because the plan folder is not shipped.

The last post of each step runs the built file against the *plan's* text of
its partner, cut from these files by the helper `B` — the script against the
test written here, the test against the script written here — so each step is
proven by its own file alone (`evidence.md` E17).

### A1 — `plugins/glab/scripts/plan-gate.sh`, the gate and the store writer

Create the file below. It implements C3–C8 and C11 of `plan.md`: the four
modes, the digest and its file set (round copies, version copies and
`plan.r<n>/` excluded — R2), the report with its `plan.r<n>/` copy, the
verdict, the check with its refusals in their order (R11), the parse rules
for reports and verdicts and the numeric order of `r<n>` (R4), and the
rejection cap per project since the last `ACCEPTED`, with the user's words
required on a verdict by `user` (R3, I8). Its header comment says why it is a
script: both levels must compute the same digest, and the formats need one
owner and one test.

- post: `` test -x plugins/glab/scripts/plan-gate.sh && echo ok || echo 'FAIL plan-gate.sh is not executable' ``
- post: `` X steps-1-scripts.md plugins/glab/scripts/plan-gate.sh ``
- post: `` d=$(mktemp -d "${TMPDIR:?}/fpl-r2.XXXXXX") && printf a >"$d/plan.md" && a=$(bash plugins/glab/scripts/plan-gate.sh digest "$d") && printf b >"$d/plan.r1.md" && printf c >"$d/steps-1.r1.md" && printf e >"$d/master.v1.md" && mkdir "$d/plan.r1" && printf f >"$d/plan.r1/plan.md" && b=$(bash plugins/glab/scripts/plan-gate.sh digest "$d"); rm -rf "$d"; if [ -n "$a" ] && [ "$a" = "$b" ]; then echo ok; else echo 'FAIL a round copy, a version copy or plan.r1/ moves the digest'; fi ``
- post: `` t=$(mktemp "${TMPDIR:?}/fpl-post.XXXXXX") && B steps-1-scripts.md tests/plan-gate.test.sh >"$t" && r=$(bash "$t" plugins/glab/scripts/plan-gate.sh 2>&1 | tail -n 1); rm -f "$t"; if [ "$r" = 'PASS 29/29' ]; then echo ok; else echo "FAIL plan-gate.sh against the plan's test: $r"; fi ``

~~~bash file=plugins/glab/scripts/plan-gate.sh
#!/usr/bin/env bash
# plan-gate.sh - the hash gate between the product level and the project level of glab, and the one
# writer of the files the two levels exchange in the shared store, under <store>/briefs/<project>/:
# report.r<n>.md and its copy folder plan.r<n>/ (the project manager, through
# glab:product-project-plan-report) and verdict.r<n>.md (the product manager, through
# glab:product-project-plan-verdict). glab:develop runs `check` before any developer is dispatched.
#
# Why a script and not skill text: both levels must compute the same digest byte for byte, and the
# report and verdict formats need one owner and one test (tests/plan-gate.test.sh).
# It reads no configuration - every path is an argument - and needs bash and coreutils only, with
# `shasum -a 256` standing in where `sha256sum` is missing (macOS ships only shasum).
#
#   digest  <plan dir>
#   report  <plan dir> <store> [<note file>]
#   verdict <store> <project> ACCEPTED|REJECTED product-manager|user <reason file>
#   check   <plan dir> <store>
#
# Exit 0 done; 1 refused; 2 usage - an unknown mode, wrong arguments, a folder or file that does not
# exist - or a write that failed. A refusal is one stderr line that begins "REFUSED: ", and it writes
# nothing. stdout: digest prints the digest, report and verdict the path they wrote, check the line
# "ACCEPTED r<n> <digest>". Every write goes to a temporary name in the folder it lands in and is
# then moved into place, so a reader never sees half a file.
set -u
# One collation for every sort, and byte semantics for every regex, on every host: the digest
# depends on the order of the file list.
export LC_ALL=C

usage() {
	echo 'usage: plan-gate.sh digest <plan dir> | report <plan dir> <store> [<note file>] | verdict <store> <project> ACCEPTED|REJECTED product-manager|user <reason file> | check <plan dir> <store>' >&2
	exit 2
}
refuse() {
	echo "REFUSED: $*" >&2
	exit 1
}
missing() {
	echo "plan-gate.sh: no such $1: $2" >&2
	exit 2
}
io() {
	echo "plan-gate.sh: $* failed" >&2
	exit 2
}

if command -v sha256sum >/dev/null 2>&1; then
	sha() { sha256sum; }
elif command -v shasum >/dev/null 2>&1; then
	sha() { shasum -a 256; }
else
	echo 'plan-gate.sh: neither sha256sum nor shasum is on PATH' >&2
	exit 2
fi
# hash_of <file>: the 64 hex characters of the file's sha256. Read from stdin, so the file name
# never reaches the output and both tools print the same thing.
hash_of() { sha <"$1" | cut -c1-64; }

# The temporaries of this run; the trap removes whichever was not moved into place. Two scalars and
# no array: an empty array under `set -u` is an error in the bash 3.2 that macOS ships.
TMP_DIR='' TMP_FILE=''
cleanup() {
	[ -z "$TMP_DIR" ] || rm -rf -- "$TMP_DIR"
	[ -z "$TMP_FILE" ] || rm -f -- "$TMP_FILE"
}
trap cleanup EXIT

# list_plan <dir>: the files a build follows, as ./<path>, sorted - master.md, index.md, every
# plan.md, questions.md and steps-*.md, in the plan folder and its sub-plan folders. Not hashed: the
# round copies <name>.r<n>.md and version copies master.v<n>.md the managers keep (a REJECTED verdict
# makes round copies, which must not move the digest), a copy folder plan.r<n>/, and every other
# file - evidence.md, map-<area>.md, result.md, integration.md, after-verdict.md - because none of
# them is the contract the product accepted.
list_plan() {
	(cd "$1" && find . -type d -name 'plan.r[0-9]*' -prune -o -type f \( -name master.md -o -name index.md -o -name plan.md -o -name questions.md -o -name 'steps-*.md' \) ! -name '*.r[0-9]*.md' ! -name '*.v[0-9]*.md' -print) | sort
}
# digest_of <dir>: the sha256 of the lines "<sha256>  ./<path>", one per listed file, in list order -
# the lines sha256sum itself prints, written out here so that shasum gives the same digest.
digest_of() {
	local f
	list_plan "$1" | while IFS= read -r f; do
		printf '%s  %s\n' "$(hash_of "$1/$f")" "$f"
	done | sha | cut -c1-64
}

# brief_line <plan dir>: sets PROJECT and BRIEF_SHA from the first line of master.md of the form
# "- brief: briefs/<project>/brief.md sha256 <64 hex>". A trailing CR is dropped first.
brief_line() {
	local line
	[ -f "$1/master.md" ] || refuse 'no brief line in master.md'
	line=$(tr -d '\r' <"$1/master.md" | grep -m 1 -E '^- brief: briefs/[a-z0-9-]+/brief\.md sha256 [0-9a-f]{64}$') ||
		refuse 'no brief line in master.md'
	PROJECT=${line#- brief: briefs/}
	PROJECT=${PROJECT%%/*}
	BRIEF_SHA=${line##* }
}

# highest <dir> <name>: the largest <n> of the files <name>.r<n>.md in dir, compared as numbers so
# that r10 comes after r9; 0 when there is none. A name whose <n> is empty, 0 or starts with 0 is
# not one this script writes, and is not counted.
highest() {
	local f n max=0
	for f in "$1/$2".r*.md; do
		[ -f "$f" ] || continue
		n=${f##*/"$2".r}
		n=${n%.md}
		case $n in '' | 0* | *[!0-9]*) continue ;; esac
		if [ "$n" -gt "$max" ]; then max=$n; fi
	done
	echo "$max"
}

# field <file> <name> <regex>: prints the value of the one line "<name>: <value>" above the file's
# first "## " heading, when there is exactly one such line and its whole value matches the regex;
# otherwise prints nothing and returns 1. Only that header is read, so a note or a reason that quotes
# "verdict: ACCEPTED" cannot change what the file says.
field() {
	local v
	v=$(tr -d '\r' <"$1" | awk -v k="$2: " 'index($0, "## ") == 1 { exit } index($0, k) == 1 { print substr($0, length(k) + 1) }')
	[ -n "$v" ] && [ "$(printf '%s\n' "$v" | wc -l)" -eq 1 ] && printf '%s\n' "$v" | grep -qxE "$3" && printf '%s\n' "$v"
}
# reason_of <verdict file>: the non-blank lines under its "## Reason" heading.
reason_of() { tr -d '\r' <"$1" | awk 'f && NF { print } /^## Reason$/ { f = 1 }'; }

# read_report <file> <n>: sets R_PLAN and R_BRIEF; returns 1 when the file is malformed.
read_report() {
	field "$1" report "r$2" >/dev/null &&
		R_PLAN=$(field "$1" plan-sha256 '[0-9a-f]{64}') &&
		R_BRIEF=$(field "$1" brief-sha256 '[0-9a-f]{64}') &&
		field "$1" files '[0-9]+' >/dev/null &&
		field "$1" date '[0-9]{4}-[0-9]{2}-[0-9]{2}' >/dev/null
}
# read_verdict <file> <n>: sets V_VERDICT, V_PLAN and V_BRIEF; returns 1 when the file is malformed,
# an empty reason included.
read_verdict() {
	V_VERDICT=$(field "$1" verdict 'ACCEPTED|REJECTED') &&
		field "$1" report "r$2" >/dev/null &&
		V_PLAN=$(field "$1" plan-sha256 '[0-9a-f]{64}') &&
		V_BRIEF=$(field "$1" brief-sha256 '[0-9a-f]{64}') &&
		field "$1" by 'product-manager|user' >/dev/null &&
		field "$1" date '[0-9]{4}-[0-9]{2}-[0-9]{2}' >/dev/null &&
		[ -n "$(reason_of "$1")" ]
}

# publish_file <final path>: moves TMP_FILE into place, readable by the other level's user too -
# mktemp makes it 0600, and the store is shared.
publish_file() {
	{ chmod 644 "$TMP_FILE" && mv -- "$TMP_FILE" "$1"; } || io "writing $1"
	TMP_FILE=''
}

cmd_digest() {
	[ $# -eq 1 ] || usage
	[ -d "$1" ] || missing folder "$1"
	digest_of "$1"
}

cmd_report() {
	[ $# -eq 2 ] || [ $# -eq 3 ] || usage
	local plan=$1 store=$2 note=${3:-} dir n v d f
	[ -d "$plan" ] || missing folder "$plan"
	[ -d "$store" ] || missing folder "$store"
	[ -z "$note" ] || [ -f "$note" ] || missing file "$note"
	brief_line "$plan"
	dir=$store/briefs/$PROJECT
	[ -f "$dir/brief.md" ] || missing file "$dir/brief.md"
	[ "$(hash_of "$dir/brief.md")" = "$BRIEF_SHA" ] || refuse 'the brief changed since the plan was written; plan again'
	n=$(highest "$dir" report)
	v=$(highest "$dir" verdict)
	if [ "$n" -gt "$v" ]; then refuse "report r$n has no verdict yet"; fi
	n=$((n + 1))
	# A copy folder with no report is what an interrupted run leaves behind. It is not removed here:
	# whoever looks at it decides (glab:security, detect and surface).
	if [ -e "$dir/plan.r$n" ]; then refuse "plan.r$n/ is there without report r$n; look at it and remove it by hand"; fi
	d=$(digest_of "$plan")
	TMP_DIR=$(mktemp -d "$dir/.plan-gate.XXXXXX") || io 'making a temporary folder'
	list_plan "$plan" | while IFS= read -r f; do
		mkdir -p "$TMP_DIR/$(dirname "$f")" && cp "$plan/$f" "$TMP_DIR/$f" || exit 1
	done || io 'copying the plan'
	# The copy is what the product audits; a file that changed while it was copied fails here.
	[ "$(digest_of "$TMP_DIR")" = "$d" ] || io 'copying the plan (the copy has another digest)'
	TMP_FILE=$(mktemp "$dir/.plan-gate.XXXXXX") || io 'making a temporary file'
	{
		printf '# Plan report r%s — %s\n' "$n" "$PROJECT"
		printf 'report: r%s\nplan-sha256: %s\nbrief-sha256: %s\nfiles: %s\ndate: %s\n\n## Note\n' \
			"$n" "$d" "$BRIEF_SHA" "$(list_plan "$plan" | wc -l | tr -d ' ')" "$(date +%Y-%m-%d)"
		if [ -n "$note" ] && [ -n "$(tr -d '[:space:]' <"$note")" ]; then cat -- "$note"; else echo none; fi
	} >"$TMP_FILE" || io 'writing the report'
	{ chmod 755 "$TMP_DIR" && mv -- "$TMP_DIR" "$dir/plan.r$n"; } || io "writing $dir/plan.r$n/"
	TMP_DIR=''
	publish_file "$dir/report.r$n.md"
	echo "$dir/report.r$n.md"
}

cmd_verdict() {
	[ $# -eq 5 ] || usage
	local store=$1 project=$2 verdict=$3 by=$4 reason=$5 dir n k now rejected=0
	case $verdict in ACCEPTED | REJECTED) ;; *) usage ;; esac
	case $by in product-manager | user) ;; *) usage ;; esac
	printf '%s\n' "$project" | grep -qxE '[a-z0-9-]+' || usage
	[ -d "$store" ] || missing folder "$store"
	[ -f "$reason" ] || missing file "$reason"
	dir=$store/briefs/$project
	n=$(highest "$dir" report)
	if [ "$n" -eq 0 ]; then refuse 'no report to decide'; fi
	read_report "$dir/report.r$n.md" "$n" || refuse "report r$n is malformed"
	if [ -e "$dir/verdict.r$n.md" ]; then refuse "report r$n already has a verdict"; fi
	{ [ -d "$dir/plan.r$n" ] && [ "$(digest_of "$dir/plan.r$n")" = "$R_PLAN" ]; } ||
		refuse "the copies in plan.r$n/ do not match report r$n"
	[ -f "$dir/brief.md" ] || missing file "$dir/brief.md"
	now=$(hash_of "$dir/brief.md")
	[ "$now" = "$R_BRIEF" ] || refuse "the brief changed since report r$n"
	[ -n "$(tr -d '[:space:]' <"$reason")" ] || refuse 'empty reason'
	# The rejection cap: REJECTED verdicts on this project since its last ACCEPTED, over every brief
	# the project has had - a new brief does not reset it, so the product side cannot clear the cap by
	# editing its own brief. Only an ACCEPTED does, and at the cap only the user can write one.
	for ((k = 1; k < n; k++)); do
		[ -f "$dir/verdict.r$k.md" ] || continue
		read_verdict "$dir/verdict.r$k.md" "$k" || refuse "verdict r$k is malformed"
		if [ "$V_VERDICT" = ACCEPTED ]; then rejected=0; else rejected=$((rejected + 1)); fi
	done
	if [ "$by" = user ]; then
		# The calling session chooses `by`; the quoted words are what makes the user's decision
		# visible to whoever reads the store later.
		head -n 1 "$reason" | tr -d '\r' | grep -qxE 'user: ".*[^[:space:]].*"' ||
			refuse "a verdict by user starts its reason with the user's words: user: \"<words>\""
	elif [ "$rejected" -ge 2 ]; then
		refuse 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user'
	fi
	TMP_FILE=$(mktemp "$dir/.plan-gate.XXXXXX") || io 'making a temporary file'
	{
		printf 'verdict: %s\nreport: r%s\nplan-sha256: %s\nbrief-sha256: %s\nby: %s\ndate: %s\n\n## Reason\n' \
			"$verdict" "$n" "$R_PLAN" "$now" "$by" "$(date +%Y-%m-%d)"
		cat -- "$reason"
	} >"$TMP_FILE" || io 'writing the verdict'
	publish_file "$dir/verdict.r$n.md"
	echo "$dir/verdict.r$n.md"
}

cmd_check() {
	[ $# -eq 2 ] || usage
	local plan=$1 store=$2 dir n v d
	[ -d "$plan" ] || missing folder "$plan"
	[ -d "$store" ] || missing folder "$store"
	brief_line "$plan"
	dir=$store/briefs/$PROJECT
	[ -f "$dir/brief.md" ] || missing file "$dir/brief.md"
	# The refusals in this order, so that each state has one answer: the brief, a report still
	# waiting, no verdict for this brief, a malformed verdict, REJECTED, then the plan.
	[ "$(hash_of "$dir/brief.md")" = "$BRIEF_SHA" ] || refuse 'the brief changed since the plan was written; plan again'
	n=$(highest "$dir" report)
	v=$(highest "$dir" verdict)
	if [ "$n" -gt "$v" ]; then refuse "report r$n has no verdict yet"; fi
	if [ "$v" -eq 0 ]; then refuse 'no verdict for this brief'; fi
	read_verdict "$dir/verdict.r$v.md" "$v" || refuse "verdict r$v is malformed"
	# The latest verdict answers an older brief: this plan's brief has none yet.
	[ "$V_BRIEF" = "$BRIEF_SHA" ] || refuse 'no verdict for this brief'
	[ "$V_VERDICT" = ACCEPTED ] || refuse "the latest verdict r$v is REJECTED"
	d=$(digest_of "$plan")
	[ "$d" = "$V_PLAN" ] || refuse "the plan changed since verdict r$v accepted it; report again"
	echo "ACCEPTED r$v $d"
}

mode=${1:-}
[ $# -eq 0 ] || shift
case $mode in
digest) cmd_digest "$@" ;;
report) cmd_report "$@" ;;
verdict) cmd_verdict "$@" ;;
check) cmd_check "$@" ;;
*) usage ;;
esac
~~~

### A2 — `tests/plan-gate.test.sh`, the gate's test

Create the file below: the cases T1–T29 that `plan.md` *Tests* lists, each in
its own store and plan folder under the work directory, T22 judged last over
every store. T21 builds a `PATH` of symlinks to the tools the script needs,
`shasum` among them and `sha256sum` not, and is skipped — `ok T21 … (skipped:
no shasum)` — only where `shasum` is missing.

- post: `` test -x tests/plan-gate.test.sh && echo ok || echo 'FAIL plan-gate.test.sh is not executable' ``
- post: `` X steps-1-scripts.md tests/plan-gate.test.sh ``
- post: `` t=$(mktemp "${TMPDIR:?}/fpl-post.XXXXXX") && B steps-1-scripts.md plugins/glab/scripts/plan-gate.sh >"$t" && r=$(bash tests/plan-gate.test.sh "$t" 2>&1 | tail -n 1); rm -f "$t"; if [ "$r" = 'PASS 29/29' ]; then echo ok; else echo "FAIL plan-gate.test.sh against the plan's script: $r"; fi ``

~~~bash file=tests/plan-gate.test.sh
#!/usr/bin/env bash
# Exercises plan-gate.sh against plan folders and stores written here, under $TMPDIR; it never
# touches a real shared store. Each case builds its own store and plan folder, so no case depends on
# another case's files. T22 is judged last, over every store the cases wrote.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to plan-gate.sh>" >&2; exit 2; }
# Absolute, because every run below starts from the work directory.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/plan-gate-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap only removes
# the work directory.
trap 'rm -rf "$W"' EXIT
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
printf -- '- model: glab:developer opus, for this task — the user'"'"'s instruction: "use opus"\n- round 3: analyze — high S1\n' >"$P/after-verdict.md"
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
~~~
