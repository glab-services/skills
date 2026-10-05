#!/usr/bin/env bash
#
# Sync Claude Code memories to S3.
#
#   memory-sync.sh pull             # S3 -> local, run at session start; never overwrites a local file that
#                                   # is newer than the remote object's upload time (that is the whole
#                                   # guarantee: upload time, not the time of the edit that was uploaded).
#                                   # Staged: it downloads into a stage copy first, and it never restores
#                                   # a file that was removed from the bucket
#   memory-sync.sh push             # local -> S3, run at session end
#   memory-sync.sh push-if-changed  # local -> S3 only when a memory file changed since the last push;
#                                   # run after every tool call and at every turn end, so a memory edit
#                                   # reaches S3 within seconds instead of only at session end
#   memory-sync.sh delete <project>/memory/<file>
#                                   # removes the bucket object, then the stage and local copies;
#                                   # the only mode that deletes; run by hand
#
# Only memory directories are touched: everything under
# ~/.claude/projects/<project>/memory/ is mirrored, preserving the per-project
# layout, and nothing else in projects/ is read or written.
#
# Configuration comes from the environment, so no secrets live in this file:
#
#   CLAUDE_MEMORY_S3_URI   required, e.g. s3://my-bucket/memories
#   AWS_PROFILE            optional, the profile holding the credentials
#   CLAUDE_MEMORY_S3_ARGS  optional, extra aws args (e.g. --endpoint-url=...)
#   CLAUDE_MEMORY_S3_TIMEOUT  optional, whole seconds; default 12, maximum 17
#
# Linux with GNU coreutils, util-linux `flock` and `rsync` is required.
#
# This runs on the session's critical path, so it must never hang or fail the
# session: every path exits 0 and the transfer is bounded by a timeout.
set -uo pipefail

MODE=${1:-}
CONF="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ROOT="$CONF/projects"
# Why 12: a run can last up to the limit plus 3 s (see `bounded` below), and the hook timeout in
# settings.example.json is 20 s, so 12 leaves 5 s for the script to log its own timeout before
# the harness kills it.
TIMEOUT=${CLAUDE_MEMORY_S3_TIMEOUT:-12}
# The largest limit accepted. A run can last TIMEOUT + 3 s, so 17 is the largest value whose worst
# case (20 s) still fits the 20 s hook timeout; anything above it would let the harness kill the
# script before it can log why. Two digits at most also keeps TIMEOUT * 1000 far from overflow.
MAX_TIMEOUT=17

# Pull downloads into this staging copy first, never straight into ROOT: `aws s3 sync` S3->local
# copies any file whose SIZE differs and, for same-sized files, only skips when the local copy is
# NOT newer — so a direct pull overwrites a newer local edit with the older S3 copy. That is how
# memory edits made mid-session were lost on 2026-09-23 when a restarted session pulled before
# the end-of-session push had run. The staging copy is kept between runs so each pull is
# incremental. The stage is pruned to match the remote on every pull, so a file removed from the
# bucket can no longer be copied back out of the stage. ROOT is never pruned.
STAGE="$CONF/.memory-sync-stage"
# Time of the last successful push; push-if-changed compares memory files against it.
STAMP="$CONF/.memory-sync-pushed"
# Written when a push fails, removed when a push succeeds, read only by push-if-changed: while it
# is younger than COOLDOWN seconds push-if-changed does not try again. 300 s is the user's chosen
# cool-down.
FAILED="$CONF/.memory-sync-failed"
COOLDOWN=300
# Serialises pull, push and delete, not only pushes: the hook fires after every tool call, and
# two concurrent syncs would race.
LOCK="$CONF/.memory-sync.lock"

log() { echo "[memory-sync] $*" >&2; }

# The mode is checked before anything is probed or created, so an unknown mode leaves no trace:
# it used to create ROOT on its way to the usage line.
case "$MODE" in
	pull | push | push-if-changed | delete) ;;
	*)
		log "usage: $(basename "$0") pull|push|push-if-changed|delete <project>/memory/<file>"
		exit 0
		;;
esac

# Empty, any non-digit, or a leading zero: so 0, 08 and -3 are all rejected and no value can
# reach arithmetic as octal. A well-formed value of three digits or more, or above MAX_TIMEOUT, is
# rejected too, so the TIMEOUT + 3 s bound below always holds and the arithmetic cannot overflow;
# it gets its own line, because "not a positive integer" would be untrue of it. The digit count
# is tested first, so a value too long for the shell's integers is never compared as a number.
case "$TIMEOUT" in
	'' | *[!0-9]* | 0*)
		log "CLAUDE_MEMORY_S3_TIMEOUT is not a positive integer; using 12"
		TIMEOUT=12
		;;
	*)
		if [ "${#TIMEOUT}" -gt 2 ] || [ "$TIMEOUT" -gt "$MAX_TIMEOUT" ]; then
			log "CLAUDE_MEMORY_S3_TIMEOUT is above $MAX_TIMEOUT; using 12"
			TIMEOUT=12
		fi
		;;
esac

# One time budget for the whole run. Every lock wait and every bounded command is given at most
# the rounded-up remainder of the one shared limit, so each ends no later than TIMEOUT + 1 s after
# start; a child that ignores TERM is killed 2 s later. Worst case for any mode is therefore
# TIMEOUT + 3 s — 15 s by default, 5 s under the 20 s hook timeout — however many bounded calls
# the mode makes, because a call that would start after the limit is not started. Outside the
# bound, and accepted: the local `find` in `changed`, and mkdir, touch, mv, rm on local files.
#
# Milliseconds from `date`, not $SECONDS: $SECONDS counts wall-clock second boundaries, so it can
# read 1 a few milliseconds after start and makes the limit handed to `timeout` vary from run to
# run.
now_ms() { echo $(($(date +%s%N) / 1000000)); }
START_MS=$(now_ms)

# left prints the whole seconds of TIMEOUT still unspent, rounded up, and never more than TIMEOUT:
# a clock stepped backward during the run must not hand a child more than the whole limit.
left() {
	local now t
	now=$(now_ms)
	t=$(((TIMEOUT * 1000 - (now - START_MS) + 999) / 1000))
	[ "$t" -gt "$TIMEOUT" ] && t=$TIMEOUT
	echo "$t"
}

# bounded runs a command under what is left of the time budget and logs why it did not succeed.
# A command that would start after the limit is not started at all. CUT_OFF is 1 afterwards when
# the command was cut off rather than failing by itself, so the caller can tell "it said no" from
# "nobody knows what it did".
CUT_OFF=0
bounded() {
	local t rc=0
	CUT_OFF=0
	t=$(left)
	if [ "$t" -lt 1 ]; then
		CUT_OFF=1
		log "$MODE timed out after ${TIMEOUT}s"
		return 1
	fi
	# 9>&-: the child must not inherit the lock. A detached descendant of a transfer that was cut
	# off would otherwise keep the lock held long after this script has gone.
	timeout -k 2 "$t" "$@" 9>&- || rc=$?
	[ "$rc" -eq 0 ] && return 0
	# 124: cut off at the limit. 137 once the budget is spent: it ignored TERM and was killed 2 s
	# later. 137 while budget is left was some other KILL (the OOM killer, say) and is a failure.
	if [ "$rc" -eq 124 ] || { [ "$rc" -eq 137 ] && [ "$(left)" -lt 1 ]; }; then
		CUT_OFF=1
		log "$MODE timed out after ${TIMEOUT}s"
	else
		log "$MODE failed (exit $rc)"
	fi
	return 1
}

if [ -z "${CLAUDE_MEMORY_S3_URI:-}" ]; then
	log "CLAUDE_MEMORY_S3_URI is not set; skipping"
	exit 0
fi

# Every trailing "/" is stripped, so "$URI/" never produces "//" in an object key.
URI="${CLAUDE_MEMORY_S3_URI%"${CLAUDE_MEMORY_S3_URI##*[!/]}"}"

for tool in aws timeout flock rsync; do
	if ! command -v "$tool" >/dev/null 2>&1; then
		log "$tool not found; skipping"
		exit 0
	fi
done

mkdir -p "$ROOT"

# Only files inside a memory/ directory are in scope. --exclude runs before
# --include, so this is "nothing, except memory directories".
scope=(--exclude "*" --include "*/memory/*")

# Split on whitespace only, never glob-expanded against the hook's cwd; an argument containing
# a space is not supported.
extra=()
read -r -a extra <<<"${CLAUDE_MEMORY_S3_ARGS:-}"

# No --delete toward the remote and none toward ROOT: a half-written local state must not be able
# to wipe the remote copy, and a stale remote must not delete local memories. The only --delete
# is on the stage, which is a cache (see pull); removing a memory is the delete mode's job.
sync() {
	local src=$1 dst=$2
	shift 2
	bounded aws s3 sync "$src" "$dst" "${scope[@]}" ${extra[@]+"${extra[@]}"} "$@" --only-show-errors
}

# changed reports whether any memory file is newer than the last successful push.
changed() {
	[ -f "$STAMP" ] || return 0
	[ -n "$(find "$ROOT" -path '*/memory/*' -type f -newer "$STAMP" -print -quit 2>/dev/null)" ]
}

# cooling reports whether a push failed less than COOLDOWN seconds ago. A stamp dated in the future
# (a clock that was wrong when it was written) is not a cool-down: it would otherwise suppress
# push-if-changed, silently, until the clock caught up with it.
cooling() {
	local at age
	[ -f "$FAILED" ] || return 1
	at=$(stat -c %Y "$FAILED" 2>/dev/null) || return 1
	age=$(($(date +%s) - at))
	[ "$age" -ge 0 ] && [ "$age" -lt "$COOLDOWN" ]
}

# lock <wait|nowait> takes the exclusive lock or ends the run: `wait` blocks for what is left of
# the time budget, `nowait` gives up at once.
lock() {
	local t
	if ! { exec 9>"$LOCK"; } 2>/dev/null; then
		log "$MODE: cannot open lock file $LOCK; skipping"
		exit 0
	fi
	if [ "$1" = wait ]; then
		t=$(left)
		[ "$t" -lt 1 ] && t=1
		if ! flock -w "$t" 9; then
			log "$MODE: lock busy after ${TIMEOUT}s; skipping"
			exit 0
		fi
	elif ! flock -n 9; then
		log "$MODE: another sync is running; skipping"
		exit 0
	fi
}

push() {
	# Taken BEFORE the sync starts, so an edit that lands while the sync runs is newer than the
	# stamp and gets pushed next time rather than being marked as already sent.
	local next="$STAMP.next"
	# A stamp that cannot be written is reported after the transfer, by the mv below failing.
	touch "$next" 2>/dev/null
	if sync "$ROOT/" "$URI/"; then
		rm -f "$FAILED"
		# -T: STAMP is replaced, never entered if something made it a directory. "ok" is only said
		# when the stamp really moved; otherwise every later push-if-changed sends again, and says so.
		if mv -fT "$next" "$STAMP" 2>/dev/null; then
			log "$MODE ok"
		else
			log "$MODE: sent, but the push stamp was not updated: $STAMP"
		fi
	else
		rm -f "$next"
		touch "$FAILED"
	fi
}

case "$MODE" in
	pull)
		lock wait
		mkdir -p "$STAGE"
		if sync "$URI/" "$STAGE/" --delete; then
			# --update: copy only files that are missing locally or strictly newer in S3. The AWS
			# CLI stamps downloaded files with the object's LastModified, so the comparison is S3
			# time against local edit time. LastModified is the time of the UPLOAD, not of the edit
			# that was uploaded: a local file is safe only while it is newer than that upload.
			# --keep-dirlinks: a memory directory that is a symlink to a directory stays a symlink;
			# without it rsync replaces the link with a real directory.
			if bounded rsync -a --update --keep-dirlinks "$STAGE/" "$ROOT/"; then
				log "pull ok"
			fi
		fi
		;;
	push)
		# Never consults FAILED, so the SessionEnd push always tries.
		lock wait
		push
		;;
	push-if-changed)
		changed || exit 0
		# Silent: this mode fires after every tool call.
		cooling && exit 0
		# Does not wait for a push in flight. The second `changed` covers the case where the lock
		# was free because another push had just finished and already sent this edit.
		lock nowait
		changed || exit 0
		push
		;;
	delete)
		# A path relative to ROOT, which is also the key suffix under URI. Used byte for byte;
		# never trimmed or rewritten.
		rel=${2:-}
		valid=1
		case "/$rel/" in
			*/../* | */./* | *//*) valid=0 ;;
			/*/memory/*/) ;;
			*) valid=0 ;;
		esac
		[ -d "$ROOT/$rel" ] && valid=0
		if [ "$valid" -eq 0 ]; then
			log "delete: expected <project>/memory/<file>, relative to $ROOT; nothing removed"
			exit 0
		fi
		lock wait
		# Remote first, and the stage and local copies only if that succeeded: a local-first
		# delete whose remote half fails is exactly the resurrection this mode exists to stop.
		# Neither STAMP nor FAILED is read or written here.
		if bounded aws s3 rm "$URI/$rel" ${extra[@]+"${extra[@]}"} --only-show-errors; then
			# "ok" only when both copies are really gone: a local copy that survives is uploaded
			# again by the next push, so it is named instead.
			gone=1
			for copy in "$STAGE/$rel" "$ROOT/$rel"; do
				if ! rm -f -- "$copy" 2>/dev/null; then
					gone=0
					log "delete: remote copy removed, but this copy was NOT removed: $copy"
				fi
			done
			[ "$gone" -eq 1 ] && log "delete ok: $rel"
		elif [ "$CUT_OFF" -eq 1 ]; then
			# Cut off mid-request: the object may or may not be gone, so neither is claimed.
			log "delete: remote delete not confirmed; run delete again"
		else
			log "delete: remote copy not removed; local copy left in place"
		fi
		;;
esac

exit 0
