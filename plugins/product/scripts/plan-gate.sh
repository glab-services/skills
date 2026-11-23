#!/usr/bin/env bash
# plan-gate.sh - the hash gate between the product level and the project level of glab, and the one
# writer of the files the two levels exchange in the shared store, under <store>/briefs/<project>/:
# report.r<n>.md and its copy folder plan.r<n>/ (the project manager, through
# glab:project-plan-report) and verdict.r<n>.md (the product manager, through
# glab:product-project-plan-verdict). glab:project-develop runs `check` before any developer is dispatched.
#
# Why a script and not skill text: both levels must compute the same digest byte for byte, and the
# report and verdict formats need one owner and one test (tests/plan-gate.test.sh).
# For a plain store it reads no configuration - every path is an argument - and needs bash and
# coreutils only, with `shasum -a 256` standing in where `sha256sum` is missing (macOS ships only
# shasum). For a store clone (A store clone, below) it also reads the clone's glab.store, branch and
# upstream from its git config, and needs git.
#
#   digest  <plan dir>
#   report  <plan dir> <store> [<note file>]
#   verdict <store> <project> ACCEPTED|REJECTED product-manager|user <reason file>
#   check   <plan dir> <store>
#   sync    <store> [product-manager]
#
# Exit 0 done; 1 refused; 2 usage - an unknown mode, wrong arguments, a folder or file that does not
# exist - or a write or fetch that failed. A refusal is one stderr line that begins "REFUSED: ", and
# it writes nothing - but for a takeover before it (take_over below), which removes only the claim,
# and the temporary file, of a run that provably no longer runs, and in a store clone its sync and
# what it published and committed before a refusal, which it undoes (A store clone, below)
# [remote-store/review-r1.md B1] [remote-store/review-r2.md B7]. stdout: digest prints the digest,
# report and verdict the path they wrote, check the line "ACCEPTED r<n> <digest>", sync "git <40-hex HEAD>" for a store clone and "folder"
# for a plain folder, where it does nothing. Before it writes
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
# never tested. A store clone is a local folder, so this holds for the clone's filesystem; the
# remote is reached only by git. A run killed by SIGKILL leaves its claim; on Linux a later run on
# the same host takes it over once that run provably no longer runs (take_over), elsewhere a person
# removes it.
#
# A store clone.
# In a store clone - its top holds .git and its glab.store is true - a run also
# fetches and fast-forwards the clone before it reads it; commits only the paths
# it wrote, which the store's own ignore files do not drop, or for sync
# product-manager the brief and rule files it names, as
# glab plan-gate <plan-gate@glab.invalid>; pushes them to the clone's upstream,
# never forced; and on any exit before its push landed undoes its own commit and
# removes the files it published, never sync's - once a push was sent, the trap
# fetches first, and a remote tip that is the run's own commit has landed and is
# not undone [remote-store/review-r2.md A9]. A failed fetch is exit 2; a clone
# git cannot use, or whose setup is incomplete, is refused. A store without .git
# runs no git command; one with .git and no git on PATH is refused.
# The switch is opt-in: .git is a folder and `git config --file .git/config --bool --get
# glab.store`, run in the store, prints true - a file read, to which git's ownership check
# (safe.directory) does not apply, so a clone another account owns is refused rather than run as a
# plain folder; with .git a file, `config --local`. Unset or false is a plain folder and runs the
# plain code; any other failing read is refused. A user who already versions a plain store by hand
# must not find it committing and pushing after an upgrade [remote-store/plan.md D2]
# [remote-store/evidence.md X9]. report, verdict and check fetch and fast-forward the clone before
# their first store read, and report and verdict commit and push what they wrote before exit 0;
# sync serves the readers that are not this script and the files written by hand
# [remote-store/plan.md D5]. One clone-wide claim, <git dir>/.plan-gate.claim.store, is taken
# through claim like every claim, after the opt-in read and before the first git command that reads
# or writes the work tree, the index or a ref: two runs in one clone otherwise collide in git
# itself, 10 of 20 concurrent commits failed [remote-store/plan.md D6] [remote-store/evidence.md
# X5]. A reader - check, and sync without product-manager - waits for that claim up to 30 s while
# its run provably runs, so that a report or verdict in the same clone does not turn a check into a
# refusal; a writer is refused at once [remote-store/plan.md D37]. Across machines the push is the compare-and-swap: a run commits on the base it read and
# pushes HEAD:<upstream ref>, never forced, and the remote takes it only as a fast-forward of that
# base; the local claims complement it and replace nothing [remote-store/plan.md D7]
# [remote-store/evidence.md X11]. A failed push is told by the remote's tip after a fetch, never by
# git's words - under true concurrency 63 of 80 misses read "incorrect old value provided", 17
# "fetch first": the tip is this run's commit, it landed; the base, the remote refused, exit 2; a
# descendant of the base, a miss; anything else, the remote was rewritten, refused
# [remote-store/plan.md D9] [remote-store/evidence.md X11]. A miss is replayed only when nothing
# under briefs/<project>/ - every store input of a report, verdict or check
# [remote-store/evidence.md E1] - moved between the base and the new tip, so the replay is
# byte-identical to deciding again: reset to the base, fast-forward, commit the same paths, push
# again; else it is refused. Not git rebase: a blind rebase landed a verdict on a brief it never
# read, with no conflict [remote-store/plan.md D8] [remote-store/evidence.md X3]. At most 5 pushes
# per run [remote-store/plan.md D10]. Every run first requires an index equal to HEAD, a HEAD equal
# to its upstream or behind it, a fast-forward that would overwrite no local change - git refuses
# that itself, and the check names the path [remote-store/evidence.md X6] - and, for report,
# verdict and check, nothing uncommitted under briefs/<project>/ but .plan-gate.* names
# [remote-store/evidence.md X8]; each failure is one refusal, and nothing is repaired
# [remote-store/plan.md D11]. Every git command runs through sgit, whose settings keep the bytes,
# hence the hashes, and the run its own - autocrlf and the per-user attribute and ignore files
# [remote-store/evidence.md X7], signing, background gc and fsmonitor, prompts - and git's stdout
# and stderr are never printed, since they carry the remote's URL [remote-store/plan.md D12]
# [remote-store/evidence.md X1, X4]. The store's own .gitattributes and .git/info/* stay a known
# limit. Author and committer of every commit are glab plan-gate <plan-gate@glab.invalid>, exported
# on the commit alone, so no user's identity reaches a team store [remote-store/plan.md D13]. The
# EXIT trap undoes a run that had not landed - its own commit, or its staging, never a commit it did
# not make - then removes the files it published; after a push was sent, a push that finished before
# the trap's fetch has landed - the fetched tip holds the run's commit - even when a TERM ended the
# run then [remote-store/review-r3.md A13]; a SIGKILL leaves untracked files or a commit ahead, and
# the next run refuses on either, naming it [remote-store/plan.md D14].
#
# A symlink anywhere in a plan folder, or in a copy folder, is refused: find does not follow links,
# so a linked file or folder would sit beside the plan without moving its digest.
set -u
# One collation for every sort, and byte semantics for every regex, on every host: the digest
# depends on the order of the file list.
export LC_ALL=C

usage() {
	echo 'usage: plan-gate.sh digest <plan dir> | report <plan dir> <store> [<note file>] | verdict <store> <project> ACCEPTED|REJECTED product-manager|user <reason file> | check <plan dir> <store> | sync <store> [product-manager]' >&2
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
# that was not linked, and a temporary file - and then the claim this run holds, and the takeover
# lock it holds (take_over), always. Scalars only and no array: an empty array under `set -u` is an
# error in the bash 3.2 that macOS ships. The claim goes after the copy folder: until the copy folder
# is gone, no other run can take the number and find it. In a store clone (GIT_STORE set) the trap
# first undoes the run's git state and removes what it published but did not push (git_undo), while
# the clone claim is still held, so that no other run sees the clone half undone; then the four
# lines above, then the clone claim's temporary file and the clone claim itself, last. A failed undo
# makes the exit 2; after a signal the status stays 128+n, since bash re-sends the signal once the
# trap is done, and the undo's line is the record [remote-store/plan.md S1.4]
# [remote-store/check-r1-code.md C9]. The scalars of a store clone are set by store_open,
# store_push and publish_file.
TMP_DIR='' TMP_FILE='' CLAIM='' LOCK=''
GIT_STORE='' S_ROOT='' S_GITDIR='' S_REMOTE='' S_MERGE='' S_BASE='' S_ADDED='' S_COMMIT='' S_PUSHED='' S_PUSHING='' S_SHOW='' S_FILE='' S_DIR='' S_TMP='' DIRTY='' DIRTY_BAD='' STORE_CLAIM='' UNDO_FAILED=''
cleanup() {
	[ -z "$GIT_STORE" ] || git_undo
	[ -z "$TMP_DIR" ] || rm -rf -- "$TMP_DIR"
	[ -z "$TMP_FILE" ] || rm -f -- "$TMP_FILE"
	[ -z "$CLAIM" ] || rm -f -- "$CLAIM"
	[ -z "$LOCK" ] || rm -f -- "$LOCK"
	[ -z "$S_TMP" ] || rm -f -- "$S_TMP"
	[ -z "$STORE_CLAIM" ] || rm -f -- "$STORE_CLAIM"
	[ -z "$UNDO_FAILED" ] || exit 2
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
# (noclobber, set -C) under umask 022, and returns what happened, bash's messages dropped so that
# the caller's line stays the one line on stderr [script-hardening/plan.md D7]:
#   0 written;
#   1 the name is there - found before the open, or found there after the open failed;
#   2 the open failed and no name is there;
#   3 the write failed - a full disk or quota, a file size limit - and the file this run made is
#     removed again, by its name;
#   4 the write failed and that removal failed too (create_failed says so).
# The open is an `exec` of fd 9 and the write a second command, so the two failures differ. When one
# redirection opened and wrote at once, a failed write looked like a name that is there: claim then
# handed the run's own empty file to take_over, which refused and asked a person to remove it
# [flow-gate-hardening/follow-ups.md FG-1]. Each exec goes through `command`: exec is a special
# builtin, and in posix mode - POSIXLY_CORRECT in the environment - a failed redirection on it ended
# the shell at once, exit 1 and its message dropped, so a run that lost a claim race or could not
# write the folder printed nothing; under `command` the failure is a status the code below reads
# [script-hardening/review.r1.md] [script-hardening/plan.md D21]. The name is tested first, a
# symlink included, because noclobber opens an existing name that is not a regular file without
# O_EXCL: a claim that was a link to /dev/null opened and took the line, and the run went on with no
# exclusive claim. Two windows stay open, each needing a writer that acts against this run on
# purpose [script-hardening/plan.md D11, FU-SH3]: (1) a name that is not a regular file, put there
# between the test and the open, still opens without O_EXCL, and when the write then fails, the rm
# of code 3 removes that planted name - a symlink to /dev/full did so in the review's probe, the run
# exiting 2 [script-hardening/review.r1.md]; (2) a file put at the name between a failed write and
# the rm is removed. In this bash, not a ( ) subshell, so that the signals held around it
# stay held (hold_signals). It turns noclobber off and puts back MASK, the umask this run started
# with, on every result: nothing else in this script sets either, and nothing else uses fd 9. MASK is
# read once here, before any signal is held, since $( ) is a subshell too.
MASK=$(umask)
create_line() {
	local rc=0
	umask 022
	set -C
	if [ -e "$1" ] || [ -L "$1" ]; then
		rc=1
	elif ! { command exec 9>"$1"; } 2>/dev/null; then
		if [ -e "$1" ] || [ -L "$1" ]; then rc=1; else rc=2; fi
	elif ! { printf '%s\n' "$ME" >&9; } 2>/dev/null; then
		command exec 9>&-
		if rm -f -- "$1" 2>/dev/null; then rc=3; else rc=4; fi
	else
		command exec 9>&-
	fi
	set +C
	umask "$MASK"
	return "$rc"
}
# create_failed <file> <code>: ends the run with exit 2 for create_line's code 2, 3 or 4 on <file>,
# in one stderr line. For 4 the line names the file left behind, which no later run can tell from a
# live run's claim or lock.
create_failed() {
	if [ "$2" -eq 4 ]; then
		echo "plan-gate.sh: writing $1 failed, and removing it failed; remove $1 by hand" >&2
		exit 2
	fi
	io "writing $1"
}

# claim <file> <refusal> [<seconds>]: makes this run the one writer of a number, or refuses with
# <refusal> when another run holds it. The claim is the file <file> holding the line ME, created by bash itself with
# noclobber (set -C), which opens a name that is not there with O_CREAT|O_EXCL: of two runs at once
# only one creates it. Not mkdir, and not a test for the name followed by a write: whether mkdir
# fails on a name that exists depends on the coreutils, and the open is bash's own; the test
# create_line makes before the open only refuses sooner, the O_EXCL open is still what makes one run
# the winner. Measured on a
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
# no longer runs and otherwise refuses - naming the file only when that run cannot be proven to run
# still: a person cannot tell such a claim from a stale one, and a live run's must not be removed.
# Only create_line's 1, the name is there, goes to
# take_over; a create that failed (2, 3 or 4) ends the run with exit 2 (create_failed), having
# removed nothing but the file it made itself, by that name - not another run's claim, which it
# never opened. Because a claim is removed, a run that read the store before another run published
# that number can claim it afterwards: the caller tests again under the claim. With <seconds>, a
# claim whose run provably runs (owner_gone 1) is tried again once a second, up to that many times,
# before take_over decides; a claim that went meanwhile is tried again at once. Only a reader of a
# store clone passes it (store_open): a check that met a report or verdict in its clone was refused,
# and glab:project-develop then reported the plan again [remote-store/review-r1.md A2]
# [remote-store/plan.md D37].
claim() {
	local rc g wait=${3:-0}
	whoami
	while :; do
		rc=0
		hold_signals
		create_line "$1" || rc=$?
		if [ "$rc" -eq 0 ]; then
			CLAIM=$1
			release_signals
			return 0
		fi
		release_signals
		[ "$rc" -eq 1 ] || create_failed "$1" "$rc"
		[ "$wait" -gt 0 ] || break
		wait=$((wait - 1))
		if [ -e "$1" ] || [ -L "$1" ]; then
			g=0
			owner_gone "$(head -n 1 -- "$1" 2>/dev/null)" || g=$?
			[ "$g" -eq 1 ] || break
			sleep 1
		fi
	done
	take_over "$1" "$2"
}
# take_over <claim> <refusal>: the claim <claim> is there and is not this run's. Takes it over when
# the run that made it provably no longer runs (owner_gone), removing first the temporary file that
# run left (claimed_tmp's name) [flow-product-level/follow-ups.md FR2-2]; else refuses with
# <refusal> - alone when the claim's run is proven alive, else naming the claim, and the temporary
# file too when there is one - since a person told to remove a live run's claim by hand would break
# that run [remote-store/review-r1.md A2]. The takeover is
# itself exclusive: it holds the lock .plan-gate.takeover.<kind and number>, created as a claim is,
# and under the lock reads the claim again and removes it only when it still holds the line found
# stale. Of two runs that both found it stale, one makes the lock and the other is refused; a run
# that found it stale before another run took it over finds that run's line under the lock, and is
# refused. Nothing but its holder or a takeover removes a claim, and a takeover needs the lock, so
# the line read under the lock stays the claim's until this run removes it; a line names one process,
# so a new claim never repeats a stale one. The claim is read with head, one line - a claim is one.
# A run killed by SIGKILL while it holds the lock, a few commands long, leaves the lock: every later
# takeover of that number is refused, naming it, until someone removes it. create_line's codes
# decide each create here: a lock that is there (1) is refused, naming it; a lock that could not be
# made (2, 3 or 4) ends the run with exit 2 (create_failed), and so does a claim whose re-create
# under the lock failed - a re-create that finds the name there (1) is refused, naming the claim.
take_over() {
	local line again rc=0 kind=${1##*/.plan-gate.claim.}
	local tmp=${1%/*}/.plan-gate.tmp.$kind lock=${1%/*}/.plan-gate.takeover.$kind
	line=$(head -n 1 -- "$1" 2>/dev/null)
	owner_gone "$line"
	case $? in
	0) ;;
	1) refuse "$2" ;;
	*)
		if [ -e "$tmp" ]; then refuse "$2; when no run is writing, remove $1 and $tmp by hand"; fi
		refuse "$2; when no run is writing, remove $1 by hand"
		;;
	esac
	hold_signals
	create_line "$lock" || rc=$?
	if [ "$rc" -ne 0 ]; then
		release_signals
		if [ "$rc" -eq 1 ]; then refuse "$2; when no run is writing, remove $lock by hand"; fi
		create_failed "$lock" "$rc"
	fi
	LOCK=$lock
	again=$(head -n 1 -- "$1" 2>/dev/null)
	if [ "$again" = "$line" ]; then rm -f -- "$tmp" "$1" || io "writing $1"; fi
	create_line "$1" || rc=$?
	if [ "$rc" -eq 0 ]; then CLAIM=$1; fi
	rm -f -- "$lock" || io "writing $lock"
	LOCK=''
	release_signals
	if [ -z "$CLAIM" ]; then
		[ "$rc" -eq 1 ] || create_failed "$1" "$rc"
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
	# In a store clone the file and its copy folder become the run's until its push lands: the trap
	# removes them if it has not (git_undo). Set only here, after ln made the link, so that the trap
	# never removes a name another writer made.
	if [ -n "$GIT_STORE" ]; then S_FILE=$1 S_DIR=$TMP_DIR; fi
	TMP_DIR=''
	release_signals
	rm -f -- "$TMP_FILE"
	TMP_FILE=''
}

# sgit <args...>: git on the store clone S_ROOT, the store as its argument gave it. Every git command
# of this script goes through it [remote-store/plan.md D12]. The settings keep the stored bytes, and
# so the hashes, whatever the user's config says: a clone with core.autocrlf=true checks an LF file
# out with other bytes [remote-store/evidence.md X7], and the per-user attributes and ignore files are
# read even under GIT_CONFIG_GLOBAL [remote-store/check-r1-code.md C7]; a signing setting would fail
# every push or fast-forward [remote-store/check-r1-code.md C13]; no background gc, maintenance or
# fsmonitor daemon outlives the run; no stash is made for a merge. stdin is /dev/null, so no prompt
# waits for a headless session (GIT_TERMINAL_PROMPT, store_open), and stderr is dropped: git's
# messages name the remote's URL [remote-store/evidence.md X1, X4]. Callers drop stdout too, or read
# it - never print it. Hooks of the clone run. Every pathspec is literal (--literal-pathspecs): a
# rule file named docs/product-rules/*.md, passed to add as a glob, added an excluded
# docs/product-rules/private/secret.md, which was pushed [remote-store/review-r3.md A11].
sgit() {
	git --literal-pathspecs -C "$S_ROOT" -c core.autocrlf=false -c core.eol=lf -c core.safecrlf=false -c core.attributesFile=/dev/null \
		-c core.excludesFile=/dev/null -c core.fsmonitor=false -c gc.auto=0 -c maintenance.auto=false \
		-c advice.diverging=false -c push.gpgSign=false -c merge.verifySignatures=false -c merge.autoStash=false \
		"$@" </dev/null 2>/dev/null
}
# git_failed <step> <rc>: ends the run with exit 2, io's line with git's exit code.
git_failed() {
	echo "plan-gate.sh: $1 failed (git exit $2)" >&2
	exit 2
}
# store_broken <rc>: refuses on a git read that failed on a clone past rev-parse --absolute-git-dir -
# a state of the store, not a failed write [remote-store/plan.md D32, D36].
store_broken() { refuse "git refuses the store clone $S_SHOW (git exit $1); if another account owns it, see git's safe.directory"; }

# store_open <store> [read]: steps 1 to 3 of a run on a store clone [remote-store/plan.md
# Processing]. A store without .git returns at once, and no git command runs. Otherwise the caller's
# GIT_* names that would point git at another repository, or date its commit, are unset before the
# first git command, the opt-in read included, and prompts are off - GIT_CONFIG too, which git config
# reads as its --file, so that a hostile one named the branch, remote and upstream ref the push went
# to [remote-store/review-r1.md A4]; and the other names that set config or change how git reads a
# pathspec, GIT_CONFIG_PARAMETERS, GIT_CONFIG_COUNT - its GIT_CONFIG_KEY_<n> and _VALUE_<n> are read
# only with a count - and GIT_*_PATHSPECS: each redirected the push, or undid the refusal of an
# ignored path [remote-store/review-r2.md A7]. S_SHOW is the store path as messages print it,
# printable, so that a newline in it leaves every line one line [remote-store/review-r2.md A10].
# With read - check, sync without product-manager - the clone
# claim is waited for up to 30 s while its run provably runs (claim) [remote-store/plan.md D37]. Then: the opt-in read (D2), the clone
# claim (D6), the branch and its upstream, a clean index, the fetch, and the fast-forward (D11).
# Sets GIT_STORE only once glab.store reads true, and S_BASE to the HEAD the run decides on.
store_open() {
	local v b r t0 u h rc=0 wait=0
	S_ROOT=$1
	[ -e "$1/.git" ] || return 0
	S_SHOW=$(printable "$1")
	unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_AUTHOR_DATE GIT_COMMITTER_DATE GIT_CONFIG
	unset GIT_CONFIG_PARAMETERS GIT_CONFIG_COUNT GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS
	export GIT_TERMINAL_PROMPT=0
	command -v git >/dev/null 2>&1 || refuse "$S_SHOW holds .git and git is not on PATH, so plan-gate.sh cannot tell whether it is a store clone"
	# The file named relative to the store, as sgit runs there: --file <store>/.git/config would apply
	# a relative store path twice, read no file, exit 1 and run the plain path silently
	# [remote-store/check-r2-code.md N1].
	if [ -d "$1/.git" ]; then
		v=$(sgit config --file .git/config --bool --get glab.store) || rc=$?
	else
		v=$(sgit config --local --bool --get glab.store) || rc=$?
	fi
	case $rc:$v in
	0:true) ;;
	0:false | 1:) return 0 ;;
	*) refuse "glab.store of $S_SHOW cannot be read (git exit $rc); look at its .git/config" ;;
	esac
	GIT_STORE=1
	S_GITDIR=$(sgit rev-parse --absolute-git-dir) || store_broken $?
	if [ "${2:-}" = read ]; then wait=30; fi
	claim "$S_GITDIR/.plan-gate.claim.store" 'another run is using the store clone' "$wait"
	STORE_CLAIM=$CLAIM
	CLAIM=''
	# The clone claim's temporary-file name, so that take_over removes one a killed run left.
	S_TMP=$S_GITDIR/.plan-gate.tmp.store
	rc=0
	b=$(sgit symbolic-ref -q --short HEAD) || rc=$?
	if [ "$rc" -eq 1 ]; then refuse "the store clone $S_SHOW is on no branch"; fi
	[ "$rc" -eq 0 ] || store_broken "$rc"
	# The remote's URL is tested, never printed.
	if ! { S_REMOTE=$(sgit config "branch.$b.remote") && [ -n "$S_REMOTE" ] && sgit config "remote.$S_REMOTE.url" >/dev/null &&
		S_MERGE=$(sgit config "branch.$b.merge") && [ -n "$S_MERGE" ]; }; then
		refuse "the store clone's branch $b has no upstream on a remote"
	fi
	# diff --cached works on an unborn HEAD; diff-index --cached HEAD exits 128 there.
	rc=0
	sgit diff --cached --quiet || rc=$?
	if [ "$rc" -eq 1 ]; then refuse 'the store clone has staged changes; unstage them by hand'; fi
	[ "$rc" -eq 0 ] || store_broken "$rc"
	# The remote-tracking tip before the fetch: a HEAD equal to it that the fetched tip no longer
	# contains means the remote was rewritten, not that this clone made a commit.
	t0=$(sgit rev-parse -q --verify '@{u}') || t0=''
	rc=0
	sgit fetch -q "$S_REMOTE" >/dev/null || rc=$?
	if [ "$rc" -ne 0 ]; then
		echo "plan-gate.sh: fetching the store from its remote $S_REMOTE failed (git exit $rc)" >&2
		exit 2
	fi
	if ! u=$(sgit rev-parse -q --verify '@{u}'); then
		r=$(sgit for-each-ref --count=1 "refs/remotes/$S_REMOTE/") || store_broken $?
		[ -n "$r" ] || refuse "the store's remote branch has no commit; make its first commit by hand"
		refuse "the store clone's branch $b has no upstream on a remote"
	fi
	if ! h=$(sgit rev-parse -q --verify HEAD); then
		# An unborn branch - a clone made before the store's first push, as README.md sets one up: the
		# merge works on it. git refuses to overwrite an untracked file itself [remote-store/evidence.md
		# X6], but not an ignored one, which it overwrites, or one at a parent folder of a path the remote
		# brings, which it deletes, without a word: the overlap check runs here too, over every path of
		# the new tip [remote-store/review-r3.md A12a].
		store_overlap "$u"
		rc=0
		sgit merge -q --ff-only '@{u}' >/dev/null || rc=$?
		[ "$rc" -eq 0 ] || git_failed 'fast-forwarding the store clone' "$rc"
	elif [ "$h" != "$u" ]; then
		rc=0
		sgit merge-base --is-ancestor "$h" "$u" || rc=$?
		case $rc in
		0)
			store_overlap "$u"
			rc=0
			sgit merge -q --ff-only '@{u}' >/dev/null || rc=$?
			[ "$rc" -eq 0 ] || git_failed 'fast-forwarding the store clone' "$rc"
			;;
		1)
			if [ "$h" = "$t0" ]; then refuse "the store's remote no longer holds this clone's commit $h; look at its history"; fi
			refuse "the store clone has commit $h that its remote does not have; push it or remove it by hand"
			;;
		*) store_broken "$rc" ;;
		esac
	fi
	S_BASE=$(sgit rev-parse HEAD) || store_broken $?
}

# printable <path>: the path with each newline written \n and each tab \t, for a one-line message.
printable() {
	local p=${1//$'\n'/\\n}
	printf '%s' "${p//$'\t'/\\t}"
}
# store_dirty [<pathspec>...]: sets DIRTY to the clone's uncommitted entries, one "XY<TAB>path" line
# each, in git status order, the paths store-relative; an entry whose last component starts
# ".plan-gate." - a claim or a temporary file of a run - is dropped [remote-store/evidence.md X8].
# Called in this shell, never in $( ): a refusal there would end only the subshell, and $( ) drops
# the NULs. git's output goes to S_TMP and is read back with read -d '', which keeps every byte; a
# renamed or copied entry carries its old path as the next field, which is skipped. A path holding a
# newline or a tab cannot be one line of DIRTY: DIRTY_BAD is set to it, as git gave it but with each
# newline and tab written \n and \t (printable), and the function returns 1, for the caller to
# refuse with its own line naming it - one line, as every refusal is [remote-store/review-r1.md A5].
store_dirty() {
	local e p skip=''
	DIRTY='' DIRTY_BAD=''
	if [ $# -eq 0 ]; then
		sgit status --porcelain=v1 -z --untracked-files=all >"$S_TMP" || store_broken $?
	else
		sgit status --porcelain=v1 -z --untracked-files=all -- "$@" >"$S_TMP" || store_broken $?
	fi
	while IFS= read -r -d '' e; do
		if [ -n "$skip" ]; then
			skip=''
			continue
		fi
		case $e in R* | C* | ?R* | ?C*) skip=1 ;; esac
		p=${e#???}
		case ${p##*/} in .plan-gate.*) continue ;; esac
		case $p in *$'\n'* | *$'\t'*)
			DIRTY_BAD=$(printable "$p")
			return 1
			;;
		esac
		DIRTY=$DIRTY${e:0:2}$'\t'$p$'\n'
	done <"$S_TMP"
}
# store_overlap <new tip>: refuses when the fast-forward to <new tip> would touch a path the clone
# has changed: git would refuse the merge itself [remote-store/evidence.md X6], and this names the
# path. The diff is read from S_TMP as store_dirty reads status, never through $( ), which drops the
# NULs and makes bash warn on stderr beside the refusal [remote-store/check-r2-code.md N2]. A
# changed path holding a newline or a tab is one plan-gate.sh never commits, and is refused as such.
# An ignored file is not in git status, and git overwrites it in the fast-forward without a word: the
# paths the diff names are given to ls-files -o -i as well, and one it lists is refused
# [remote-store/review-r3.md A12]. ls-files never lists a file at a parent folder of such a path,
# which git deletes to make the folder: each parent folder that is there as anything but a folder,
# and is not tracked, is refused too [remote-store/review-r3.md A12b]. On an unborn HEAD the paths
# are every path of the new tip (ls-tree) [remote-store/review-r3.md A12a]. The paths go into the
# positional parameters, not an array (the trap's comment).
store_overlap() {
	local p q tip=$1 k=0 rc
	store_dirty || refuse "the store clone has a change plan-gate.sh does not commit: $DIRTY_BAD; look at it"
	if sgit rev-parse -q --verify HEAD >/dev/null; then
		sgit diff --name-only -z --no-renames HEAD "$tip" >"$S_TMP" || store_broken $?
	else
		sgit ls-tree -r --name-only -z "$tip" >"$S_TMP" || store_broken $?
	fi
	while IFS= read -r -d '' p; do
		case $DIRTY in *$'\t'"$p"$'\n'*) refuse "the store's remote changed $p, which the store clone has changed too; look at both" ;; esac
		q=$p
		while case $q in */*) true ;; *) false ;; esac; do
			q=${q%/*}
			if [ -L "$S_ROOT/$q" ] || { [ -e "$S_ROOT/$q" ] && ! [ -d "$S_ROOT/$q" ]; }; then
				rc=0
				sgit ls-files --error-unmatch -- "$q" >/dev/null || rc=$?
				if [ "$rc" -eq 1 ]; then refuse "the store's remote changed $(printable "$p"), under $(printable "$q"), which the store clone holds as an untracked file; look at both"; fi
				[ "$rc" -eq 0 ] || store_broken "$rc"
			fi
		done
		if [ "$k" -eq 0 ]; then set -- "$p"; else set -- "$@" "$p"; fi
		k=$((k + 1))
	done <"$S_TMP"
	[ "$k" -gt 0 ] || return 0
	sgit ls-files -z -o -i --exclude-standard -- "$@" >"$S_TMP" || store_broken $?
	p=''
	IFS= read -r -d '' p <"$S_TMP"
	[ -z "$p" ] || refuse "the store's remote changed $(printable "$p"), which the store clone holds as an ignored file; look at both"
}
# store_clean <project>: refuses when briefs/<project>/ of a store clone holds an uncommitted entry
# but a .plan-gate.* name - a hand edit, or the files a killed run left [remote-store/plan.md D11,
# D14] - an untracked file the store's own .gitignore or .git/info/exclude ignores included: git
# status never lists one, and a killed verdict run's verdict.r<n>.md that the store ignores was read
# by the next check as the verdict [remote-store/review-r2.md A8]. Nothing for a plain store.
store_clean() {
	local l p
	[ -n "$GIT_STORE" ] || return 0
	store_dirty "briefs/$1/" || refuse "the store clone has a change under briefs/$1/ that is not committed: $DIRTY_BAD; look at it, and commit, push or remove it by hand"
	if [ -n "$DIRTY" ]; then
		l=${DIRTY%%$'\n'*}
		refuse "the store clone has a change under briefs/$1/ that is not committed: ${l#*$'\t'}; look at it, and commit, push or remove it by hand"
	fi
	sgit ls-files -z -o -i --exclude-standard -- "briefs/$1/" >"$S_TMP" || store_broken $?
	while IFS= read -r -d '' p; do
		case ${p##*/} in .plan-gate.*) continue ;; esac
		refuse "the store clone has a change under briefs/$1/ that is not committed: $(printable "$p"); look at it, and commit, push or remove it by hand"
	done <"$S_TMP"
}

# store_push <subject> <scope> <path...>: step 6 [remote-store/plan.md Processing]: commits the paths
# this run wrote - a folder with a trailing / - and pushes them to the clone's upstream, up to 5
# times [remote-store/plan.md D7-D10]. <scope> is the one pathspec that holds every input of the
# run's decision, briefs/<project>/, or - meaning the paths themselves (sync)
# [remote-store/check-r1-code.md C2]. Nothing for a plain store. Each round: briefs/<project>/ holds
# nothing uncommitted but these paths and .plan-gate.* names; add, commit, push. A failed push is
# judged by the remote's tip after a fetch (D9). On a miss, when the remote moved nothing under
# <scope> the round is replayed on the new tip - reset to the base, the overlap check, a
# fast-forward, the same paths committed again - else it is refused (D8). Signals are held from
# before S_ADDED=1, which comes before the add so that a partly staged index is unstaged too, to the
# end of the add, and from before the commit until S_COMMIT is set: a TERM during an unheld commit
# ran the trap with S_COMMIT empty, which only unstages, and removed the files of a commit still at
# HEAD [remote-store/check-r2-code.md N5]. Not around fetch or push: a network call stays
# interruptible, and the trap's undo covers it (D14) - S_PUSHING, set before the first push, has
# the trap fetch first, so that a TERM after the remote took the push does not undo a commit that
# landed [remote-store/review-r2.md A9].
store_push() {
	local subject=$1 scope=$2 body l p a own rc tip k pushes=0
	[ -n "$GIT_STORE" ] || return 0
	shift 2
	body=$(printf '%s\n' "$@")
	# r<n> for the refusal: the first path is report.r<n>.md or verdict.r<n>.md.
	k=${1##*.r}
	k=${k%.md}
	while :; do
		if [ "$scope" != - ]; then
			store_dirty "$scope" || refuse "the store clone has a change under $scope that is not committed: $DIRTY_BAD; look at it, and commit, push or remove it by hand"
			l=$DIRTY
			while [ -n "$l" ]; do
				p=${l%%$'\n'*}
				l=${l#*$'\n'}
				p=${p#*$'\t'}
				own=''
				for a in "$@"; do
					case $a in
					*/) case $p in "$a"*) own=1 ;; esac ;;
					*) if [ "$p" = "$a" ]; then own=1; fi ;;
					esac
				done
				[ -n "$own" ] || refuse "the store clone has a change under $scope that is not committed: $p; look at it, and commit, push or remove it by hand"
			done
		fi
		hold_signals
		S_ADDED=1
		rc=0
		# -f: a path the store's own .gitignore or .git/info/exclude names is added all the same - the
		# commit otherwise lacked it, exit 0, and the other clone's verdict was refused on a copy
		# folder short of a file [remote-store/review-r1.md A1]. sync's paths are never ignored
		# (cmd_sync refuses them), so for sync -f changes nothing.
		sgit add -f -- "$@" >/dev/null || rc=$?
		release_signals
		[ "$rc" -eq 0 ] || git_failed "staging the store's files" "$rc"
		hold_signals
		GIT_AUTHOR_NAME='glab plan-gate' GIT_AUTHOR_EMAIL=plan-gate@glab.invalid \
			GIT_COMMITTER_NAME='glab plan-gate' GIT_COMMITTER_EMAIL=plan-gate@glab.invalid \
			sgit commit -q --no-gpg-sign -m "$subject" -m "$body" -- "$@" >/dev/null || rc=$?
		if [ "$rc" -eq 0 ]; then S_COMMIT=$(sgit rev-parse HEAD) || rc=$?; fi
		release_signals
		[ "$rc" -eq 0 ] || git_failed 'committing to the store' "$rc"
		pushes=$((pushes + 1))
		rc=0
		S_PUSHING=1
		sgit push -q "$S_REMOTE" "HEAD:$S_MERGE" >/dev/null || rc=$?
		if [ "$rc" -eq 0 ]; then
			S_PUSHED=1
			return 0
		fi
		a=0
		sgit fetch -q "$S_REMOTE" >/dev/null || a=$?
		if [ "$a" -ne 0 ]; then
			echo "plan-gate.sh: pushing the store to its remote $S_REMOTE failed, and fetching it again failed (git exit $a); whether this run's commit $S_COMMIT landed is unknown - run sync" >&2
			exit 2
		fi
		tip=$(sgit rev-parse -q --verify '@{u}') || store_broken $?
		# A push that landed and still failed - killed after the remote took it, or a hook's late failure.
		# Two runs that wrote the same bytes on the same base in the same second make one commit, one
		# sha: the tip is then this run's commit too, and it did land.
		if [ "$tip" = "$S_COMMIT" ]; then
			S_PUSHED=1
			return 0
		fi
		if [ "$tip" = "$S_BASE" ]; then
			echo "plan-gate.sh: pushing the store to its remote $S_REMOTE failed (git exit $rc), and the remote did not move; this run's commit is undone - run git -C $S_SHOW push --dry-run to see why" >&2
			exit 2
		fi
		a=0
		sgit merge-base --is-ancestor "$S_BASE" "$tip" || a=$?
		if [ "$a" -eq 1 ]; then refuse "the store's remote no longer holds this clone's commit $S_BASE; look at its history"; fi
		[ "$a" -eq 0 ] || store_broken "$a"
		# A miss. The decision's inputs are all under <scope>: when the remote moved one of them, a
		# replay would land a decision on a state it never read [remote-store/evidence.md X3].
		a=0
		if [ "$scope" = - ]; then
			sgit diff --quiet --no-renames "$S_BASE" "$tip" -- "$@" || a=$?
		else
			sgit diff --quiet --no-renames "$S_BASE" "$tip" -- "$scope" || a=$?
		fi
		if [ "$a" -eq 1 ] && [ "$scope" = - ]; then
			sgit diff --name-only -z --no-renames "$S_BASE" "$tip" -- "$@" >"$S_TMP" || store_broken $?
			p=''
			IFS= read -r -d '' p <"$S_TMP"
			refuse "the store's remote changed $p while this run committed it; look at both"
		fi
		if [ "$a" -eq 1 ]; then refuse "the store's remote changed $scope while this run wrote r$k; run it again"; fi
		[ "$a" -eq 0 ] || store_broken "$a"
		[ "$pushes" -lt 5 ] || refuse "the store's remote moved 5 times while this run pushed; run it again"
		# The replay. The reset takes HEAD back to the base this run's commit sits on; S_COMMIT is
		# cleared right after it, and S_BASE moved right after the fast-forward, so that the trap
		# never resets off a commit this run did not make [remote-store/check-r1-code.md C3]. A reset
		# that fails leaves this run's commit at HEAD, and names the command that undoes it.
		rc=0
		sgit reset -q --mixed "$S_BASE" >/dev/null || rc=$?
		if [ "$rc" -ne 0 ]; then
			S_COMMIT='' S_ADDED=''
			echo "plan-gate.sh: undoing this run's commit in $S_SHOW failed; run git -C $S_SHOW reset --mixed $S_BASE by hand" >&2
			exit 2
		fi
		S_COMMIT=''
		store_overlap "$tip"
		rc=0
		sgit merge -q --ff-only "$tip" >/dev/null || rc=$?
		[ "$rc" -eq 0 ] || git_failed 'fast-forwarding the store clone' "$rc"
		S_BASE=$tip
	done
}

# git_undo: the trap's first step in a store clone, on every exit before the push landed
# [remote-store/plan.md D14]. When HEAD is this run's commit, a reset to its parent; else, when the
# run staged, an unstage: it never moves HEAD off a commit this run did not make
# [remote-store/check-r1-code.md C3]. Then the report and its copy folder, or the verdict, that this
# run published - by name, since publish_file set them; sync's files are the planner's and never
# set. A reset that fails prints the command that does it by hand, and the exit becomes 2. Once a
# push was sent (S_PUSHING), a fetch first: a remote tip that holds this run's commit - is it, or
# another push already built on it - means the push landed, a TERM after it having ended the run
# before S_PUSHED was set, and nothing is undone; a fetch that fails, or any other tip, undoes as
# before [remote-store/review-r2.md A9] [remote-store/review-r3.md A13]. A push still running when
# the trap fetches can land after it, and is undone here all the same: the next run's fetch brings
# the commit back.
git_undo() {
	local h t u
	[ -z "$S_PUSHED" ] || return 0
	if [ -n "$S_PUSHING" ] && [ -n "$S_COMMIT" ] && sgit fetch -q "$S_REMOTE" >/dev/null &&
		u=$(sgit rev-parse -q --verify '@{u}') && sgit merge-base --is-ancestor "$S_COMMIT" "$u"; then
		return 0
	fi
	if [ -n "$S_COMMIT" ] && h=$(sgit rev-parse -q --verify HEAD) && [ "$h" = "$S_COMMIT" ]; then
		if ! sgit reset -q --mixed "$S_COMMIT^" >/dev/null; then
			t=$(sgit rev-parse -q --verify "$S_COMMIT^") || t=$S_BASE
			echo "plan-gate.sh: undoing this run's commit in $S_SHOW failed; run git -C $S_SHOW reset --mixed $t by hand" >&2
			UNDO_FAILED=1
		fi
	elif [ -n "$S_ADDED" ]; then
		if ! sgit reset -q --mixed HEAD >/dev/null; then
			echo "plan-gate.sh: undoing this run's commit in $S_SHOW failed; run git -C $S_SHOW reset --mixed HEAD by hand" >&2
			UNDO_FAILED=1
		fi
	fi
	[ -z "$S_FILE" ] || rm -f -- "$S_FILE"
	[ -z "$S_DIR" ] || rm -rf -- "$S_DIR"
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
	store_open "$store"
	store_clean "$PROJECT"
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
	store_push "store(report): $PROJECT r$n by $PROJECT" "briefs/$PROJECT/" "briefs/$PROJECT/report.r$n.md" "briefs/$PROJECT/plan.r$n/"
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
	store_open "$store"
	store_clean "$project"
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
	store_push "store(verdict): $project r$n $verdict by $by" "briefs/$project/" "briefs/$project/verdict.r$n.md"
	echo "$dir/verdict.r$n.md"
}

cmd_check() {
	[ $# -eq 2 ] || usage
	local plan=$1 store=$2 dir n v d
	[ -d "$plan" ] || missing folder "$plan"
	[ -d "$store" ] || missing folder "$store"
	brief_line "$plan"
	store_open "$store" read
	store_clean "$PROJECT"
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

# cmd_sync <store> [product-manager]: brings a store clone up to date for a reader that is not this
# script, and with product-manager also commits and pushes the files the planner wrote by hand -
# a ` M` or `??` entry that is a brief, briefs/<project>/brief.md, or a rule file,
# docs/product-rules/<name>.md; any other uncommitted entry but a .plan-gate.* name is refused, and
# local edits are otherwise left in place [remote-store/plan.md D16]. Refused too: a brief or rule
# file the store's own .gitignore or .git/info/exclude ignores, which git status never lists, so
# sync would have pushed nothing and said nothing; and an entry that is not a regular file, since a
# symlink would be committed as a link (mode 120000) [remote-store/review-r1.md A1, A6]. A plain folder: "folder", and
# nothing else is done [remote-store/check-r1-code.md C20]. The trap never removes sync's files.
cmd_sync() {
	[ $# -eq 1 ] || { [ $# -eq 2 ] && [ "$2" = product-manager ]; } || usage
	local store=$1 writer=${2:-} l p h k=0
	[ -d "$store" ] || missing folder "$store"
	if [ -n "$writer" ]; then store_open "$store"; else store_open "$store" read; fi
	if [ -z "$GIT_STORE" ]; then
		echo folder
		exit 0
	fi
	if [ -n "$writer" ]; then
		store_dirty || refuse "the store clone has a change plan-gate.sh does not commit: $DIRTY_BAD; look at it"
		# The folders are literal pathspecs (sgit), so the names are matched here, as :(glob) matched
		# them: one level, a brief under briefs/<name>/ and a rule file directly in docs/product-rules/.
		sgit ls-files -z -o -i --exclude-standard -- briefs docs/product-rules >"$S_TMP" || store_broken $?
		while IFS= read -r -d '' p; do
			case $p in
			briefs/*/*/* | docs/product-rules/*/*) ;;
			briefs/*/brief.md | docs/product-rules/*.md)
				refuse "the store clone ignores $(printable "$p"), so sync does not commit it; look at the store's .gitignore"
				;;
			esac
		done <"$S_TMP"
		l=$DIRTY
		while [ -n "$l" ]; do
			p=${l%%$'\n'*}
			l=${l#*$'\n'}
			case ${p%%$'\t'*} in ' M' | '??') ;; *) refuse "the store clone has a change plan-gate.sh does not commit: ${p#*$'\t'}; look at it" ;; esac
			p=${p#*$'\t'}
			# No glob character in a rule file's name: git read one as a pattern [remote-store/review-r3.md A11].
			printf '%s\n' "$p" | grep -qxE 'briefs/[a-z0-9-]+/brief\.md|docs/product-rules/[^/*?[\]+\.md' ||
				refuse "the store clone has a change plan-gate.sh does not commit: $p; look at it"
			if [ -L "$store/$p" ] || ! [ -f "$store/$p" ]; then
				refuse "the store clone has a change plan-gate.sh does not commit: $p, not a regular file; replace it with the file"
			fi
			# The paths go into the positional parameters, not an array (the trap's comment).
			if [ "$k" -eq 0 ]; then set -- "$p"; else set -- "$@" "$p"; fi
			k=$((k + 1))
		done
		if [ "$k" -gt 0 ]; then store_push "store(sync): $k files by product-manager" - "$@"; fi
	fi
	h=$(sgit rev-parse HEAD) || store_broken $?
	echo "git $h"
}

mode=${1:-}
[ $# -eq 0 ] || shift
case $mode in
digest) cmd_digest "$@" ;;
report) cmd_report "$@" ;;
verdict) cmd_verdict "$@" ;;
check) cmd_check "$@" ;;
sync) cmd_sync "$@" ;;
*) usage ;;
esac
