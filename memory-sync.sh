#!/usr/bin/env bash
#
# Sync Claude Code memories to S3.
#
#   memory-sync.sh pull             # S3 -> local, run at session start; never overwrites a newer local file
#   memory-sync.sh push             # local -> S3, run at session end
#   memory-sync.sh push-if-changed  # local -> S3 only when a memory file changed since the last push;
#                                   # run after every tool call and at every turn end, so a memory edit
#                                   # reaches S3 within seconds instead of only at session end
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
#
# This runs on the session's critical path, so it must never hang or fail the
# session: every path exits 0 and the transfer is bounded by a timeout.
set -uo pipefail

MODE=${1:-}
CONF="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ROOT="$CONF/projects"
TIMEOUT=${CLAUDE_MEMORY_S3_TIMEOUT:-25}

# Pull downloads into this staging copy first, never straight into ROOT: `aws s3 sync` S3->local
# copies any file whose SIZE differs and, for same-sized files, only skips when the local copy is
# NOT newer — so a direct pull overwrites a newer local edit with the older S3 copy. That is how
# memory edits made mid-session were lost on 2026-09-23 when a restarted session pulled before
# the end-of-session push had run. The staging copy is kept between runs so each pull is
# incremental.
STAGE="$CONF/.memory-sync-stage"
# Time of the last successful push; push-if-changed compares memory files against it.
STAMP="$CONF/.memory-sync-pushed"
# Serialises pushes: the hook fires after every tool call, and two concurrent syncs would race.
LOCK="$CONF/.memory-sync.lock"

log() { echo "[memory-sync] $*" >&2; }

if [ -z "${CLAUDE_MEMORY_S3_URI:-}" ]; then
	log "CLAUDE_MEMORY_S3_URI is not set; skipping"
	exit 0
fi

if ! command -v aws >/dev/null 2>&1; then
	log "aws cli not found; skipping"
	exit 0
fi

mkdir -p "$ROOT"

# Only files inside a memory/ directory are in scope. --exclude runs before
# --include, so this is "nothing, except memory directories".
scope=(--exclude "*" --include "*/memory/*")

# shellcheck disable=SC2206
extra=(${CLAUDE_MEMORY_S3_ARGS:-})

# No --delete in either direction: a half-written local state must not be able
# to wipe the remote copy, and a stale remote must not delete local memories.
sync() {
	local rc=0
	timeout "$TIMEOUT" aws s3 sync "$1" "$2" \
		"${scope[@]}" "${extra[@]}" --only-show-errors || rc=$?
	[ "$rc" -eq 0 ] && return 0
	[ "$rc" -eq 124 ] && log "$MODE timed out after ${TIMEOUT}s" || log "$MODE failed (exit $rc)"
	return 1
}

# changed reports whether any memory file is newer than the last successful push.
changed() {
	[ -f "$STAMP" ] || return 0
	[ -n "$(find "$ROOT" -path '*/memory/*' -type f -newer "$STAMP" -print -quit 2>/dev/null)" ]
}

push() {
	# Taken BEFORE the sync starts, so an edit that lands while the sync runs is newer than the
	# stamp and gets pushed next time rather than being marked as already sent.
	local next="$STAMP.next"
	touch "$next"
	if sync "$ROOT/" "$CLAUDE_MEMORY_S3_URI/"; then
		mv -f "$next" "$STAMP"
		log "$MODE ok"
	else
		rm -f "$next"
	fi
}

case "$MODE" in
	pull)
		mkdir -p "$STAGE"
		if sync "$CLAUDE_MEMORY_S3_URI/" "$STAGE/"; then
			# --update: copy only files that are missing locally or strictly newer in S3. The AWS
			# CLI stamps downloaded files with the object's LastModified, so the comparison is S3
			# time against local edit time.
			rsync -a --update "$STAGE/" "$ROOT/" && log "pull ok"
		fi
		;;
	push)
		exec 9>"$LOCK"
		flock -w "$TIMEOUT" 9 || { log "push: lock busy; skipping"; exit 0; }
		push
		;;
	push-if-changed)
		changed || exit 0
		exec 9>"$LOCK"
		# Wait for a push already in flight, then re-check: it may already have sent this edit.
		flock -w "$TIMEOUT" 9 || { log "push-if-changed: lock busy; skipping"; exit 0; }
		changed || exit 0
		push
		;;
	*) log "usage: $(basename "$0") pull|push|push-if-changed"; exit 0 ;;
esac

exit 0
