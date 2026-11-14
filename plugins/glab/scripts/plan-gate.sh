#!/usr/bin/env bash
# plan-gate.sh - the hash gate between the product level and the project level of glab, and the one
# writer of the files the two levels exchange in the shared store, under <store>/briefs/<project>/:
# report.r<n>.md and its copy folder plan.r<n>/ (the project manager, through
# glab:project-plan-report) and verdict.r<n>.md (the product manager, through
# glab:product-project-plan-verdict). glab:project-develop runs `check` before any developer is dispatched.
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
# nothing - but for a takeover before it (take_over below), which removes only the claim, and the
# temporary file, of a run that provably no longer runs. stdout: digest prints the digest, report
# and verdict the path they wrote, check the line "ACCEPTED r<n> <digest>". Before it writes
# anything, a report run claims its number and a verdict run the number of the report it decides
# (see claim below): of two runs at once only one gets the claim, and only that one creates
# plan.r<n>/ and the final file; the other is refused and touches nothing. A report or verdict file
# is written to a temporary name in the folder it lands in and then hard-linked to its final name,
# which never overwrites, so a reader never sees half a file. The copy folder plan.r<n>/ is filled
# before its report is linked: a reader finds a copy through its report. Everything written is made
# readable by every account, since the other level's session may run as another user.
#
# Where a store may live: on a filesystem with hard links, an exclusive create (O_CREAT|O_EXCL) and
# unix permission bits - ext4, the one the tests ran on, and by their documentation the other usual
# local ones, xfs, btrfs, zfs, tmpfs, APFS and HFS+. Not FAT, vfat or exFAT: no hard links, and
# chmod fails there. On a filesystem without hard links every report and verdict fails with exit 2,
# its message naming this requirement (publish_file); there is no fallback. A network, FUSE or
# synced folder is UNVERIFIED: whether O_EXCL and a link are exclusive there, across hosts, was
# never tested. A run killed by SIGKILL leaves its claim; on Linux a later run on the same host takes
# it over once that run provably no longer runs (take_over), elsewhere a person removes it.
#
# A symlink anywhere in a plan folder, or in a copy folder, is refused: find does not follow links,
# so a linked file or folder would sit beside the plan without moving its digest.
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

# What this run made and has not yet published: the trap removes it - the copy folder of a report
# that was not linked, and a temporary file - and then the claim this run holds, and last the
# takeover lock it holds (take_over), always. Four scalars and no array: an empty array under
# `set -u` is an error in the bash 3.2 that macOS ships. The claim goes after the copy folder: until
# the copy folder is gone, no other run can take the number and find it.
TMP_DIR='' TMP_FILE='' CLAIM='' LOCK=''
cleanup() {
	[ -z "$TMP_DIR" ] || rm -rf -- "$TMP_DIR"
	[ -z "$TMP_FILE" ] || rm -f -- "$TMP_FILE"
	[ -z "$CLAIM" ] || rm -f -- "$CLAIM"
	[ -z "$LOCK" ] || rm -f -- "$LOCK"
}
trap cleanup EXIT

# hold_signals, then release_signals: between the two a TERM, HUP or INT does not end the run at
# once. It is held - its trap only notes it - and release_signals restores the default and sends it
# to this bash again, so the EXIT trap runs then, reading variables that are true by that time. One
# held signal is kept, the last. Bash runs a trap as soon as the foreground command exits, so with
# the EXIT trap alone a TERM that arrived while ln ran removed plan.r<n>/ of a report ln had just
# linked [flow-product-level/review-2.md finding-2] [flow-product-level/follow-ups.md FR2-1]:
# publish_file holds the signals from before ln until TMP_DIR is cleared. claim and take_over hold
# them from before each create until the variable that tells the trap about the new file is set, so
# a signal that lands between the two - after the create, before CLAIM=$1 or LOCK=$lock - no longer
# leaves a claim or a lock behind. That holds because the create runs in this bash (create_line): a
# ( ) subshell resets the traps, so an INT to the whole process group - Ctrl-C - ended a create's
# subshell after its open and the file was left [flow-gate-hardening/review-1.md finding-1]. A run
# that exits while it holds a signal - refused, or a write failed - ends with that exit's status,
# the signal dropped.
HELD=''
hold_signals() {
	HELD=''
	trap 'HELD=TERM' TERM
	trap 'HELD=HUP' HUP
	trap 'HELD=INT' INT
}
release_signals() {
	trap - TERM HUP INT
	if [ -n "$HELD" ]; then kill -s "$HELD" "$$"; fi
}

# proc_stat <line of /proc/<pid>/stat>: sets P_STATE and P_START, the process's state and its start
# time in clock ticks since boot - fields 3 and 22, counted after the last ") ", since the command
# name in field 2 may hold spaces and parentheses.
proc_stat() {
	local IFS=' '
	set -f
	# shellcheck disable=SC2086 # split into fields on purpose; globbing is off
	set -- ${1##*) }
	set +f
	P_STATE=${1:-} P_START=${20:-}
}
# whoami: sets ME, the line this run writes into each claim it makes, "<host> <boot id> <pid
# namespace> <pid> <start>" - the host's name (uname -n), the kernel's boot id, this process's pid
# namespace, this bash's pid and its start time (proc_stat). Together they name one process for as
# long as the host runs: a pid is reused only by a process that starts later. Linux only, read from
# /proc; ME is empty where there is no /proc, or where /proc is another pid namespace's - it gives
# this bash a pid that is not $$ - and then no later run can prove this run's claims stale. Read in
# the main shell, never in $( ): only there is /proc/self this bash.
ME=''
whoami() {
	local stat boot host ns
	ME=''
	{ read -r stat </proc/self/stat && read -r boot </proc/sys/kernel/random/boot_id; } 2>/dev/null || return 0
	[ "${stat%% *}" = "$$" ] || return 0
	host=$(uname -n 2>/dev/null) && ns=$(readlink /proc/self/ns/pid 2>/dev/null) || return 0
	proc_stat "$stat"
	case "$host:$boot:$ns:$P_START" in *[[:space:]]* | :* | *::* | *:) return 0 ;; esac
	case $P_START in *[!0-9]*) return 0 ;; esac
	ME="$host $boot $ns $$ $P_START"
}
# owner_gone <claim line>: whether the run that wrote the line still runs. 0: provably not - no
# process has its pid (kill -0 says "No such process"), or the process with that pid started at
# another time, the pid reused, or is a zombie, which runs no trap again. 1: provably yes. 2: this run
# cannot tell - an empty line (a claim written before glab 0.14.1, or by a run killed between the
# claim's create and its write, or by one whose ME was empty), another host, boot or pid namespace,
# or a process this account may not inspect (kill -0 says "Operation not permitted" when /proc hides
# it). Only 0 lets take_over remove a claim, so every doubt keeps the refusal. Only the bash is
# checked: a child of that run, an ln in flight, can outlive a SIGKILL sent to the bash alone, which
# is harmless - the new run refuses on the plan.r<n>/ that child may leave, and ln never overwrites.
owner_gone() {
	local stat
	[ -n "$ME" ] || return 2
	set -f
	# shellcheck disable=SC2086 # split into fields on purpose; globbing is off
	set -- $1
	set +f
	[ $# -eq 5 ] && [ "$1 $2 $3" = "${ME% * *}" ] || return 2
	case $4$5 in *[!0-9]*) return 2 ;; esac
	if { read -r stat <"/proc/$4/stat"; } 2>/dev/null; then
		proc_stat "$stat"
		case $P_START in '' | *[!0-9]*) return 2 ;; esac
		case $P_STATE in Z | X) return 0 ;; esac
		if [ "$P_START" = "$5" ]; then return 1; fi
		return 0
	fi
	case $(kill -0 "$4" 2>&1) in *'No such process'*) return 0 ;; esac
	return 2
}
# create_line <file>: creates <file> holding the line ME, with bash's own O_CREAT|O_EXCL open
# (noclobber, set -C) under umask 022; 1 when the name is there or the write fails, bash's message
# dropped, so that the caller's refusal stays the one line on stderr. In this bash, not a ( )
# subshell, so that the signals held around it stay held (hold_signals). It turns noclobber off and
# puts back MASK, the umask this run started with, on either result: nothing else in this script
# sets either. MASK is read once here, before any signal is held, since $( ) is a subshell too.
MASK=$(umask)
create_line() {
	local rc=0
	umask 022
	set -C
	{ printf '%s\n' "$ME" >"$1"; } 2>/dev/null || rc=1
	set +C
	umask "$MASK"
	return "$rc"
}

# claim <file> <refusal>: makes this run the one writer of a number, or refuses with <refusal> when
# another run holds it. The claim is the file <file> holding the line ME, created by bash itself with
# noclobber (set -C), which opens a name that is not there with O_CREAT|O_EXCL: of two runs at once
# only one creates it. Not mkdir, and not a test for the name followed by a write: whether mkdir
# fails on a name that exists depends on the coreutils, and the open is bash's own. Measured on a
# host whose mkdir is uutils coreutils 0.10.0: two mkdir calls racing on one name both exited 0 in
# 11 of 40 tries (GNU mkdir 0 of 40, these set -C opens 0 of 40); with the copy folder claimed by
# mkdir, two reports at once, each delayed 1 s before its mkdir, both wrote into one folder in 10 of
# 20 runs - either both failed, or the loser's trap removed the winner's copy after its report was
# linked. A claim names a file in briefs/<project>/, never one in a plan or copy folder, so no digest
# reads it; it starts ".plan-gate." like the temporary files, and the trap removes it on every exit
# the trap sees - done, refused, failed, or ended by TERM, HUP or INT, also one that lands between
# the create and CLAIM=$1, which is held (hold_signals). It is made under umask 022, so that a run of
# the other level's account can read the line. A run killed by SIGKILL runs no trap and leaves its
# claim: a later run finds it and hands it to take_over, which takes it over when that run provably
# no longer runs and otherwise refuses, naming the file - a live run's claim and one that cannot be
# proven stale look the same to a person. Because a claim is removed, a run that read the store
# before another run published that number can claim it afterwards: the caller tests again under
# the claim.
claim() {
	whoami
	hold_signals
	if create_line "$1"; then
		CLAIM=$1
		release_signals
		return 0
	fi
	release_signals
	[ -e "$1" ] || io "writing $1"
	take_over "$1" "$2"
}
# take_over <claim> <refusal>: the claim <claim> is there and is not this run's. Takes it over when
# the run that made it provably no longer runs (owner_gone), removing first the temporary file that
# run left (claimed_tmp's name) [flow-product-level/follow-ups.md FR2-2]; else refuses with
# <refusal>, naming the claim, and the temporary file too when there is one and the claim's run is
# not proven alive. The takeover is
# itself exclusive: it holds the lock .plan-gate.takeover.<kind and number>, created as a claim is,
# and under the lock reads the claim again and removes it only when it still holds the line found
# stale. Of two runs that both found it stale, one makes the lock and the other is refused; a run
# that found it stale before another run took it over finds that run's line under the lock, and is
# refused. Nothing but its holder or a takeover removes a claim, and a takeover needs the lock, so
# the line read under the lock stays the claim's until this run removes it; a line names one process,
# so a new claim never repeats a stale one. The claim is read with head, one line - a claim is one.
# A run killed by SIGKILL while it holds the lock, a few commands long, leaves the lock: every later
# takeover of that number is refused, naming it, until someone removes it.
take_over() {
	local line again kind=${1##*/.plan-gate.claim.}
	local tmp=${1%/*}/.plan-gate.tmp.$kind lock=${1%/*}/.plan-gate.takeover.$kind
	line=$(head -n 1 -- "$1" 2>/dev/null)
	owner_gone "$line"
	case $? in
	0) ;;
	1) refuse "$2; when no run is writing, remove $1 by hand" ;;
	*)
		if [ -e "$tmp" ]; then refuse "$2; when no run is writing, remove $1 and $tmp by hand"; fi
		refuse "$2; when no run is writing, remove $1 by hand"
		;;
	esac
	hold_signals
	if ! create_line "$lock"; then
		release_signals
		if [ -e "$lock" ]; then refuse "$2; when no run is writing, remove $lock by hand"; fi
		io "writing $lock"
	fi
	LOCK=$lock
	again=$(head -n 1 -- "$1" 2>/dev/null)
	if [ "$again" = "$line" ]; then rm -f -- "$tmp" "$1" || io "writing $1"; fi
	if create_line "$1"; then CLAIM=$1; fi
	rm -f -- "$lock" || io "writing $lock"
	LOCK=''
	release_signals
	if [ -z "$CLAIM" ]; then
		[ -e "$1" ] || io "writing $1"
		refuse "$2; when no run is writing, remove $1 by hand"
	fi
}
# claimed_tmp: sets TMP_FILE to the temporary file of the claim this run holds, .plan-gate.tmp.<the
# claim's kind and number>, and makes it, empty, in place of any file a killed run left under that
# name. The name is fixed and set before the file is made, so the trap removes the file whatever
# moment a signal lands: with mktemp in a command substitution, a SIGINT to bash while mktemp ran
# left a .plan-gate.XXXXXX file, the trap running after the substitution and before the assignment.
# Only the claim's holder uses the name, and take_over, which removes the file of a stale claim under
# its lock before it holds the claim itself. rm first, because the file a killed run left may be a
# link to a name it published; the create is bash's own O_EXCL open, as in claim.
claimed_tmp() {
	TMP_FILE=${CLAIM%/*}/.plan-gate.tmp.${CLAIM##*/.plan-gate.claim.}
	if ! { rm -f -- "$TMP_FILE" && (set -C && : >"$TMP_FILE") 2>/dev/null; }; then io 'making a temporary file'; fi
}

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
# first_link <dir>: prints the first symlink under dir, as ./<path>, the folder itself not counted;
# prints nothing when there is none. Links are not followed, so a linked folder is one line.
first_link() { (cd "$1" && find . -type l -print | sort | head -n 1); }
# all_files <dir>: every entry under dir that is not a folder, as ./<path>, sorted as list_plan sorts.
all_files() { (cd "$1" && find . ! -type d -print | sort); }
# no_links <dir> <what>: refuses when dir holds a symlink.
no_links() {
	local l
	l=$(first_link "$1")
	[ -z "$l" ] || refuse "$2 holds a symlink, $l; links are not followed - replace it with the file"
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

# publish_file <final path> <refusal>: links TMP_FILE to its final name, readable by the other
# level's user too - the umask can leave it readable by this account alone, and the store is shared.
# Called under the claim, so no other run of this script writes that name; ln never overwrites all
# the same: when the name is already there, something else wrote it, and this run is refused with
# <refusal>; the trap removes the temporary file, and this run's copy folder with it. When ln fails
# but the final name is the temporary file itself (-ef), ln made the link and was then killed - a
# Ctrl-C reaches the whole process group, ln too - and the file is published. Any other failure of
# ln ends the run with exit 2 and ln's own message, and names the requirement: a filesystem without
# hard links fails here on every write (the header). The message is not parsed to tell that case
# from another: for the same EPERM, GNU ln says "Operation not permitted" and uutils ln 0.10.0
# "Permission denied". There is no fallback to a write that can be seen half done, or to mv, which
# overwrites. TERM, HUP and INT are held from before ln until TMP_DIR is cleared (hold_signals).
publish_file() {
	local e
	chmod 644 "$TMP_FILE" || io "writing $1"
	hold_signals
	if ! e=$(ln -- "$TMP_FILE" "$1" 2>&1) && ! [ "$TMP_FILE" -ef "$1" ]; then
		release_signals
		if [ -e "$1" ]; then refuse "$2"; fi
		e=${e//$'\n'/ }
		echo "plan-gate.sh: writing $1 failed: ${e:-ln printed nothing}; plan-gate.sh publishes with a hard link, so the store must be on a filesystem that has them - the header of plan-gate.sh names them" >&2
		exit 2
	fi
	# The file is published: from here the copy folder is the report's, and the trap must not remove
	# it. Cleared before the rm, not after: a TERM while rm ran let the trap remove plan.r<n>/ of a
	# report already linked, and every later verdict and report on the project was refused.
	TMP_DIR=''
	release_signals
	rm -f -- "$TMP_FILE"
	TMP_FILE=''
}

cmd_digest() {
	[ $# -eq 1 ] || usage
	[ -d "$1" ] || missing folder "$1"
	no_links "$1" 'the plan folder'
	digest_of "$1"
}

cmd_report() {
	[ $# -eq 2 ] || [ $# -eq 3 ] || usage
	local plan=$1 store=$2 note=${3:-} dir n v d f
	[ -d "$plan" ] || missing folder "$plan"
	[ -d "$store" ] || missing folder "$store"
	[ -z "$note" ] || [ -f "$note" ] || missing file "$note"
	no_links "$plan" 'the plan folder'
	brief_line "$plan"
	dir=$store/briefs/$PROJECT
	[ -f "$dir/brief.md" ] || missing file "$dir/brief.md"
	[ "$(hash_of "$dir/brief.md")" = "$BRIEF_SHA" ] || refuse 'the brief changed since the plan was written; plan again'
	n=$(highest "$dir" report)
	v=$(highest "$dir" verdict)
	if [ "$n" -gt "$v" ]; then refuse "report r$n has no verdict yet"; fi
	n=$((n + 1))
	d=$(digest_of "$plan")
	# The claim on r<n> covers report.r<n>.md and plan.r<n>/ alike: of two runs that both passed the
	# tests above, one gets it and the other is refused before it makes anything.
	claim "$dir/.plan-gate.claim.report.r$n" "another run is writing report r$n"
	# The tests again, under the claim: a run that read the store before another run published r<n>
	# and released its claim finds r<n> taken here, and never reaches the mkdir below.
	if [ -e "$dir/report.r$n.md" ]; then refuse "another run wrote report r$n first"; fi
	# A copy folder with no report is what an interrupted run leaves behind. It is not removed here:
	# whoever looks at it decides (glab:security, detect and surface). Tested under the claim only:
	# before it, the folder may be the one a live run holding the claim is filling, and this refusal
	# would ask a person to remove it.
	if [ -e "$dir/plan.r$n" ]; then refuse "plan.r$n/ is there without report r$n; look at it and remove it by hand"; fi
	# Only the claim's holder gets here, so mkdir is no longer the claim; from here on the trap removes
	# the folder unless its report is linked.
	mkdir -- "$dir/plan.r$n" || io "writing $dir/plan.r$n/"
	TMP_DIR=$dir/plan.r$n
	list_plan "$plan" | while IFS= read -r f; do
		mkdir -p "$TMP_DIR/$(dirname "$f")" && cp "$plan/$f" "$TMP_DIR/$f" || exit 1
	done || io 'copying the plan'
	# The copy is what the product audits; a file that changed while it was copied fails here.
	[ "$(digest_of "$TMP_DIR")" = "$d" ] || io 'copying the plan (the copy has another digest)'
	# cp and mkdir follow the umask, which can leave the copy readable by this account alone.
	chmod -R a+rX "$TMP_DIR" || io "writing $dir/plan.r$n/"
	claimed_tmp
	{
		printf '# Plan report r%s — %s\n' "$n" "$PROJECT"
		printf 'report: r%s\nplan-sha256: %s\nbrief-sha256: %s\nfiles: %s\ndate: %s\n\n## Note\n' \
			"$n" "$d" "$BRIEF_SHA" "$(list_plan "$plan" | wc -l | tr -d ' ')" "$(date +%Y-%m-%d)"
		if [ -n "$note" ] && [ -n "$(tr -d '[:space:]' <"$note")" ]; then cat -- "$note"; else echo none; fi
	} >"$TMP_FILE" || io 'writing the report'
	publish_file "$dir/report.r$n.md" "another run wrote report r$n first"
	echo "$dir/report.r$n.md"
}

cmd_verdict() {
	[ $# -eq 5 ] || usage
	local store=$1 project=$2 verdict=$3 by=$4 reason=$5 dir n k now rejected=0
	case $verdict in ACCEPTED | REJECTED) ;; *) usage ;; esac
	case $by in product-manager | user) ;; *) usage ;; esac
	# A case pattern sees the whole word; grep -x would match each line of a name with a newline.
	case $project in '' | *[!a-z0-9-]*) usage ;; esac
	[ -d "$store" ] || missing folder "$store"
	[ -f "$reason" ] || missing file "$reason"
	dir=$store/briefs/$project
	n=$(highest "$dir" report)
	if [ "$n" -eq 0 ]; then refuse 'no report to decide'; fi
	read_report "$dir/report.r$n.md" "$n" || refuse "report r$n is malformed"
	if [ -e "$dir/verdict.r$n.md" ]; then refuse "report r$n already has a verdict"; fi
	# A symlink in the copy would add text to the audit that the digest does not cover, and so would
	# any other file beside the hashed ones - a round copy, evidence.md, a nested plan.r<n>/ - since
	# the analyzer is given the whole folder: the copy holds exactly the files list_plan prints.
	{ [ -d "$dir/plan.r$n" ] && [ -z "$(first_link "$dir/plan.r$n")" ] && [ "$(all_files "$dir/plan.r$n")" = "$(list_plan "$dir/plan.r$n")" ] &&
		[ "$(digest_of "$dir/plan.r$n")" = "$R_PLAN" ]; } ||
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
	# One verdict per report: of two runs at once, one gets the claim on r<n> and the other is refused
	# before it makes anything. Tested again under the claim, as in report.
	claim "$dir/.plan-gate.claim.verdict.r$n" "another run is writing verdict r$n"
	if [ -e "$dir/verdict.r$n.md" ]; then refuse "report r$n already has a verdict"; fi
	claimed_tmp
	{
		printf 'verdict: %s\nreport: r%s\nplan-sha256: %s\nbrief-sha256: %s\nby: %s\ndate: %s\n\n## Reason\n' \
			"$verdict" "$n" "$R_PLAN" "$now" "$by" "$(date +%Y-%m-%d)"
		cat -- "$reason"
	} >"$TMP_FILE" || io 'writing the verdict'
	publish_file "$dir/verdict.r$n.md" "report r$n already has a verdict"
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
	no_links "$plan" 'the plan folder'
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
