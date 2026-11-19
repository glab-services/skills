#!/usr/bin/env bash
# docs-mirror.sh - the glab docs mirror: publishes the docs/ folder of a source checkout, as one
# commit, to a branch of a separate mirror repository that readers use read-only. A CI job of the
# source repository runs it on each push to the default branch; the job is one of the two thin
# callers beside this file, github-docs-mirror.yml and gitlab-docs-mirror.yml. Every decision is
# here, none in the callers, so the one script is tested once (tests/docs-mirror.test.sh in the
# glab marketplace repository) and behaves the same on both hosts [docs-mirror/plan.md D1, D2].
#
#   docs-mirror.sh <mirror remote> <branch>
#
# Run inside the source work tree (any folder of it). <mirror remote> is a URL git accepts, the
# SSH URL in CI, never a remote name of the checkout: a fetch through a name would move that
# remote's refs/remotes/<name>/ ref, so a name is refused. <branch> is the mirror's branch, created
# by the first run.
# Exit 0: mirrored, nothing to mirror, or skipped (a stale run). Exit 1: refused, the mirror
# unchanged. Exit 2: usage (not two arguments, an empty remote or one starting "-", a branch
# `git check-ref-format --branch` rejects or changes, or one starting "-"), configuration (a key
# without known hosts, a TMPDIR whose path is not usable), bash older than 4.4, no git or git older
# than 2.28, not inside a work tree, a failed ls-remote or fetch, a fetched tip git cannot read, a
# failed read of the mirror's history, a merge-base rc other than 0 or 1, a failed commit-tree.
# Nothing is printed on stdout, ever. stderr gets one "docs-mirror: ..." line per outcome, plus the
# warnings below; a refusal is one "docs-mirror: REFUSED: ..." line. git's own output goes to the
# temporary folder and is not printed, except that a failed ls-remote, fetch or push prints, before
# the outcome line, at most the first 4 lines of git's stderr that are not blank, each prefixed
# "docs-mirror: git: ", with the remote replaced by <remote>: a wrong host key, a key without write
# access, a missing ssh, a mistyped URL and a protected branch would otherwise all read the same.
# The first lines, not the last: git ends every ls-remote and fetch failure with the same fixed
# "Could not read from remote repository" tail, and the cause comes before it. The remote is
# replaced as passed, with its "<user>@" removed, the form git prints ("git@h:p" as "h:p",
# "ssh://git@h/p" as "ssh://h/p") [docs-mirror/plan.md D13], then its path alone, the form a server
# prints ("fatal: 'p' does not appear to be a git repository"), and then its "<user>@<host>" and
# its host alone, the forms ssh prints ("git@h: Permission denied (publickey).", "ssh: connect to
# host h port 22: ..."). The path and the host are replaced wherever they occur in a line, so a
# short one may also replace part of a word; the line is a diagnostic, and a host or path left in
# it would not be. The key is never printed: git only ever sees the path of its file.
#
# The environment:
#   DOCS_MIRROR_SSH_KEY      the private key of the mirror's deploy key (write access, that one
#                            repository only). Read into a variable that is not exported and
#                            unset before the first git call, so no git or ssh child inherits the
#                            key text; non-empty, it is written to a file in the temporary folder.
#                            Empty or unset: git uses the environment's own credential.
#   DOCS_MIRROR_KNOWN_HOSTS  the mirror host's known_hosts line(s); required with a key. There is
#                            no accept-new: on an ephemeral runner every connection is a first use,
#                            so trusting a first use would trust anyone.
#   DOCS_MIRROR_ADOPT        the full sha this run may adopt after the source history was
#                            rewritten on purpose (below). Set for one run, then removed.
#   DOCS_MIRROR_URL          not read here: the callers pass it as <mirror remote>.
# An empty value counts as unset for each of them: the GitHub caller passes every variable, empty
# when it is not configured [docs-mirror/plan.md D8, D12].
#
# The rules, and why:
# - The mirror's tree is exactly the tree object HEAD:docs, at the mirror's root, nothing added.
#   Copying the tree object keeps modes, symlinks, CRLF bytes, deletions and renames exactly, and
#   runs no attribute filter, which a copy through a work tree would. Files outside docs/ never
#   reach the mirror [D4].
# - One mirror commit per run whose tree differs, or that adopts; its parent the mirror's tip; its
#   subject "docs: mirror <first 12 hex of HEAD>"; its last line "Source-Commit: <full sha>";
#   author and committer glab docs-mirror <docs-mirror@glab.invalid> whatever the caller's
#   identity, unsigned. The mirror gets a history of its own in which each commit names the
#   source commit it shows. A run whose tree is equal makes no commit [D5].
# - Never a forced update, a forced refspec or a ref deletion, and the push runs no hook and sends
#   no tag. The mirror moves only by fast-forward, so a run never destroys what is there [D5].
# - The source checkout is read, never written: no ref, config, index or work-tree change. The
#   mirror's tip is fetched into FETCH_HEAD only (its objects land in the object store) [D7].
# - The last mirror commit M is the first commit on the tip's first-parent line whose author email
#   is docs-mirror@glab.invalid and whose message's last non-empty line is "Source-Commit: " and
#   40 or 64 hex; that sha is S. The commits above M are hand commits [D9].
# - A hand edit in the mirror is overwritten, not refused: the next mirror commit stacks on the
#   hand commits, so history keeps them, and its body names them ("Replaces <n> commit(s) not made
#   by the mirror: ...", at most 20, then "and <k> more"), with one warning. The right tree is
#   rebuilt from the source and nothing is destroyed; a refusal would leave the readers on stale
#   docs until someone acted [D10].
# - Refused (exit 1, the mirror unchanged): a remote name of the checkout as <mirror remote>; no
#   docs/ tree at HEAD; a branch that has commits but none of the mirror's (a wrong target: a
#   commit there would replace its whole tree); S not in this history and not adopted; a shallow
#   checkout with S other than HEAD; a refused or failed push. There is no retry: the next
#   merge's run repairs a failed one [D11].
# - Order: S is HEAD, or an ancestor of it: mirror (or nothing, the tree being equal). HEAD an
#   ancestor of S: a stale run - CI hosts do not promise to run merges in order - so exit 0,
#   "skipped", no commit. Neither, or S unknown here: refused, unless DOCS_MIRROR_ADOPT equals S
#   exactly, which the user sets for one run after rewriting the source on purpose; that commit's
#   body adds "Adopts <S> after the source history changed.". An adopting run always commits, an
#   equal tree included, so the mirror's Source-Commit moves to HEAD and the next run finds it in
#   the history; without that commit every later run would be refused again. DOCS_MIRROR_ADOPT
#   non-empty and not used: one warning to remove it, and the run goes on [D12, D30].
#
# Where it lives: a source repository vendors a copy at .glab/docs-mirror.sh, beside its CI file,
# .github/workflows/docs-mirror.yml or .gitlab/docs-mirror.yml; nothing of glab is fetched at CI
# time and the copy is reviewed in that repository's own PR [D3]. The copies carry no version
# stamp: a copy is stale when `cmp` finds it differs from templates/docs-mirror/docs-mirror.sh in
# a checkout of the glab marketplace repository at the newer version. Setup: the glab README,
# "The docs mirror".
#
# UNVERIFIED: a hosted run on GitHub Actions or GitLab CI, and a real ssh client (the tests use a
# stub); bash other than 5.3.9 and git other than 2.53.0; SHA-256 repositories; LFS pointers and
# gitlinks under docs/ are carried as they are (the pointer, the submodule commit), not resolved;
# a symlink under docs/ that points outside it dangles in the mirror. bash runs a signal's trap
# only after the git command in flight returns, so a TERM during the push may still publish the
# commit.
set -uo pipefail

# 1. bash 4.4 or newer, the floor glab's scripts share (before 4.4 an empty array under `set -u`
# is an error); only 5.3.9 ran this. An older bash stops here with one line instead of failing
# part-way. The version is one number, major * 1000 + minor, so the test can change it in a copy.
if ((BASH_VERSINFO[0] * 1000 + BASH_VERSINFO[1] < 4004)); then
	echo "docs-mirror: bash 4.4 or newer is required, this is bash $BASH_VERSION" >&2
	exit 2
fi
# A caller's git environment must not redirect the run to another repository, index or config,
# nor change how paths match or which dates a commit gets: the names plan-gate.sh unsets too
# [docs-mirror/plan.md D25].
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_AUTHOR_DATE GIT_COMMITTER_DATE GIT_CONFIG
unset GIT_CONFIG_PARAMETERS GIT_CONFIG_COUNT GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS
# Nor turn on git's tracing, whose lines go to stderr before git's own message: they would fill the
# 4 printed lines and push the cause out, and git's trace of the ssh command names the host and the
# path in a form the redaction does not replace. Every GIT_TRACE* name is unset, whatever git adds
# later (GIT_TRACE_REFS among them). The trace2 targets can also come from a config file
# (trace2.normalTarget, eventTarget, perfTarget), which the environment overrides: 0 turns each off.
unset "${!GIT_TRACE@}" GIT_CURL_VERBOSE
export GIT_TRACE2=0 GIT_TRACE2_EVENT=0 GIT_TRACE2_PERF=0
# The mirror's identity, whatever the caller's: D9 finds the last mirror commit by this email.
export GIT_AUTHOR_NAME='glab docs-mirror' GIT_AUTHOR_EMAIL=docs-mirror@glab.invalid
export GIT_COMMITTER_NAME='glab docs-mirror' GIT_COMMITTER_EMAIL=docs-mirror@glab.invalid
# A CI job has no terminal: a credential prompt would hang the job instead of failing it.
export GIT_TERMINAL_PROMPT=0
# The key, read here, before the first git call (step 2), and unset at once, so no git child
# inherits it. The unset of ssh_key first drops an export the caller may have given that name, so
# the variable that holds the key is never exported; it is unset once the key file is written.
unset ssh_key
ssh_key=${DOCS_MIRROR_SSH_KEY:-}
unset DOCS_MIRROR_SSH_KEY

# 2. git 2.28 or newer, checked before the arguments, whose check calls git: without git that
# check would print bash's "command not found" and the wrong reason. 2.28 is the floor the tests
# need (`git init -b`); only 2.53.0 ran this. The same one-number form as step 1.
command -v git >/dev/null 2>&1 || {
	echo 'docs-mirror: git 2.28 or newer is required, and no git is on PATH' >&2
	exit 2
}
gv=$(git --version 2>/dev/null) || gv=''
gv=${gv#git version }
gmaj=${gv%%.*} gmin=${gv#*.}
gmin=${gmin%%.*}
if ! [[ $gmaj =~ ^[0-9]+$ && $gmin =~ ^[0-9]+$ ]] || ((gmaj * 1000 + gmin < 2028)); then
	echo 'docs-mirror: git 2.28 or newer is required' >&2
	exit 2
fi

# 3. The arguments. The usage line never echoes them: the remote is not printed (D13).
usage() {
	echo "docs-mirror: usage: docs-mirror.sh <mirror remote> <branch> ($1)" >&2
	exit 2
}
[ "$#" -eq 2 ] || usage 'two arguments'
remote=$1 branch=$2
# A remote or branch starting "-" could be read as an option by a git command that takes no "--"
# before it, check-ref-format below among them.
case $remote in '' | -*) usage 'the remote is empty or starts with -' ;; esac
case $branch in -*) usage 'the branch starts with -' ;; esac
# check-ref-format --branch prints the name back; inside a repository it expands @{-N} to another
# branch's name and exits 0, so the printed name must equal the one given. Its stdout is captured:
# nothing reaches stdout.
chk=$(git check-ref-format --branch "$branch" 2>/dev/null) && [ "$chk" = "$branch" ] ||
	usage 'the branch is not a valid branch name'

# 4. The source work tree, and the docs/ tree at HEAD. stderr to /dev/null: the temporary folder of
# step 5, where git's output goes, does not exist yet.
if ! { top=$(git rev-parse --show-toplevel 2>/dev/null) && [ -n "$top" ] && cd "$top" 2>/dev/null; }; then
	echo 'docs-mirror: not inside a git work tree' >&2
	exit 2
fi
refuse() {
	echo "docs-mirror: REFUSED: $*" >&2
	exit 1
}
# A remote name of the checkout is refused, not used: the argument is a URL (the header says why).
while IFS= read -r l; do
	[ "$l" != "$remote" ] || refuse 'the mirror remote is a remote name of this checkout: pass its URL'
done < <(git remote 2>/dev/null)
# HEAD is resolved once, and docs/ read from that commit, so the two cannot name different commits.
H=$(git rev-parse --verify -q 'HEAD^{commit}' 2>/dev/null) || refuse 'no docs/ tree at HEAD'
T=$(git rev-parse --verify -q "$H:docs" 2>/dev/null) || refuse 'no docs/ tree at HEAD'
[ "$(git cat-file -t "$T" 2>/dev/null)" = tree ] || refuse 'no docs/ tree at HEAD'

# 5. The temporary folder: git's output, the key and the known-hosts file. umask 077 so that no
# other account on the runner can read the key. The traps are set right after mktemp and before
# the path check, so a refused path leaves no folder behind. Bash runs no EXIT trap when a signal
# kills it, so INT, TERM and HUP each exit with the usual 128+n through the EXIT trap. A SIGKILL
# runs no trap: the GitHub caller points TMPDIR at the runner's per-job temp folder for that reason.
umask 077
TD=$(mktemp -d "${TMPDIR:-/tmp}/docs-mirror.XXXXXX" 2>/dev/null) || {
	echo 'docs-mirror: TMPDIR not usable: mktemp -d failed there' >&2
	exit 2
}
trap 'rm -rf -- "$TD"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
# git runs GIT_SSH_COMMAND through `sh -c`, so the paths in it are single-quoted, and that is
# only safe for a path without quotes, spaces or control characters; bash's printf %q would write
# bash syntax that sh does not read in every case. So the path must be plain [D8].
[[ $TD =~ ^/[A-Za-z0-9/._-]+$ ]] || {
	echo 'docs-mirror: TMPDIR not usable: its path must be absolute and hold only letters, digits and / . _ -' >&2
	exit 2
}
if [ -n "$ssh_key" ]; then
	[ -n "${DOCS_MIRROR_KNOWN_HOSTS:-}" ] || {
		echo 'docs-mirror: DOCS_MIRROR_KNOWN_HOSTS is empty: a key needs the mirror host'"'"'s known_hosts line' >&2
		exit 2
	}
	# printf is a builtin, so the key text never appears in a process's arguments. ssh needs the
	# key file to end with a newline; a value that already ends with one is not given a second.
	if ! { printf '%s\n' "${ssh_key%$'\n'}" >"$TD/key" &&
		printf '%s\n' "${DOCS_MIRROR_KNOWN_HOSTS%$'\n'}" >"$TD/known_hosts"; }; then
		echo 'docs-mirror: TMPDIR not usable: the key file could not be written' >&2
		exit 2
	fi
	# StrictHostKeyChecking=yes with the given file only: -F /dev/null reads no ssh_config of the
	# runner (system or user) and GlobalKnownHostsFile=/dev/null trusts no system known_hosts file;
	# BatchMode so a missing or wrong key fails instead of asking; IdentitiesOnly so no agent key of
	# the runner is offered instead.
	export GIT_SSH_COMMAND="ssh -F /dev/null -i '$TD/key' -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile='$TD/known_hosts' -o GlobalKnownHostsFile=/dev/null -o BatchMode=yes"
fi
unset ssh_key

# The remote as git prints it, without its "<user>@": "git@h:p" is printed "h:p" and
# "ssh://git@h/p" as "ssh://h/p" [D13]. A local path has no "<user>@" and no second form.
bare=''
if [[ $remote =~ ^([A-Za-z][A-Za-z0-9+.-]*://)?[^@/]+@(.+)$ ]]; then
	bare=${BASH_REMATCH[1]}${BASH_REMATCH[2]}
fi
# The host, and "<user>@<host>" when the remote names a user, as ssh prints them: from
# "scheme://[user@]host[:port]/..." or the scp form "[user@]host:path". Only a host name of letters,
# digits and . _ - counts; anything else (a local path, a bracketed IPv6 address) sets none, so no
# stray character is replaced everywhere.
# A URL with no host ("file:///p") sets none: the scp form is tried only for a remote with no "://".
# With a host, the path after it too, as the server prints it ("fatal: '<path>' does not appear to
# be a git repository"): "/p" from "scheme://host[:port]/p", "p" from "host:p"; a path of only "/"
# sets none, so no "/" is replaced everywhere.
host='' userhost='' path='' h='' u='' p=''
if [[ $remote == *://* ]]; then
	[[ $remote =~ ^[A-Za-z][A-Za-z0-9+.-]*://(([^@/]+)@)?([^:/]+)(:[^/]*)?(/.*)? ]] && h=${BASH_REMATCH[3]} u=${BASH_REMATCH[2]} p=${BASH_REMATCH[5]}
else
	[[ $remote =~ ^(([^@/:]+)@)?([^:/@]+):(.*)$ ]] && h=${BASH_REMATCH[3]} u=${BASH_REMATCH[2]} p=${BASH_REMATCH[4]}
fi
if [[ $h =~ ^[A-Za-z0-9._-]+$ ]]; then
	host=$h
	[ -z "$u" ] || userhost=$u@$host
	[[ $p != *[!/]* ]] || path=$p
fi
# git_lines: the first 4 lines of git's stderr that are not blank, prefixed and with the remote
# replaced (the header says why). The longer forms are replaced first, as the shorter are part of
# them; the path before the host, which a path may contain.
git_lines() {
	local l k=0
	while [ "$k" -lt 4 ] && IFS= read -r l; do
		case $l in *[![:space:]]*) ;; *) continue ;; esac
		l=${l//"$remote"/<remote>}
		[ -z "$bare" ] || l=${l//"$bare"/<remote>}
		[ -z "$path" ] || l=${l//"$path"/<remote>}
		[ -z "$userhost" ] || l=${l//"$userhost"/<remote>}
		[ -z "$host" ] || l=${l//"$host"/<remote>}
		printf 'docs-mirror: git: %s\n' "$l" >&2
		k=$((k + 1))
	done <"$TD/err"
}

# 6. Does the branch exist? ls-remote patterns match the tail of a ref name, so refs/heads/main
# also lists refs/heads/x/refs/heads/main: the branch exists only when a line's ref is exactly
# refs/heads/<branch> [D29].
git ls-remote --heads -- "$remote" "refs/heads/$branch" >"$TD/ls" 2>"$TD/err"
rc=$?
if [ "$rc" -ne 0 ]; then
	git_lines
	echo "docs-mirror: could not list the mirror (ls-remote rc=$rc)" >&2
	exit 2
fi
exists=''
while IFS= read -r l; do
	[ "${l#*$'\t'}" != "refs/heads/$branch" ] || exists=1
done <"$TD/ls"

tip='' hand=0 hand_list='' adopting=''
if [ -n "$exists" ]; then
	# 7. The mirror's tip, into FETCH_HEAD only: no ref of the source checkout changes (D7). --refmap=
	# (empty) keeps a remote's fetch refspec from also updating its refs/remotes/<name>/ ref: a legacy
	# .git/remotes/<name> file names a remote that `git remote` does not list (step 4), yet git
	# resolves it. The push of step 10 through such a name still moves that ref (a push has no
	# --refmap): the argument is a URL, as the header says [docs-mirror/follow-ups.md FU-DM-R3].
	git fetch -q --no-tags --no-recurse-submodules --refmap= -- "$remote" "refs/heads/$branch" >"$TD/out" 2>"$TD/err"
	rc=$?
	if [ "$rc" -ne 0 ]; then
		git_lines
		echo "docs-mirror: could not fetch the mirror (fetch rc=$rc)" >&2
		exit 2
	fi
	tip=$(git rev-parse --verify -q 'FETCH_HEAD^{commit}' 2>"$TD/err") || {
		echo 'docs-mirror: could not read the fetched mirror tip' >&2
		exit 2
	}

	# 8. The last mirror commit M and its source commit S, from %B and not %(trailers): the parse is
	# the script's, so it does not depend on how a git version reads trailers [D9]. -z separates the
	# records with NUL, which a message cannot contain; %x1f the fields.
	git log -z --first-parent --format='%H%x1f%ae%x1f%B' "$tip" >"$TD/log" 2>"$TD/err" || {
		echo 'docs-mirror: could not read the mirror history' >&2
		exit 2
	}
	S=''
	while IFS= read -r -d '' rec || [ -n "$rec" ]; do
		sha=${rec%%$'\x1f'*} rest=${rec#*$'\x1f'}
		email=${rest%%$'\x1f'*} body=${rest#*$'\x1f'}
		last=''
		while IFS= read -r l; do
			[ -z "$l" ] || last=$l
		done <<<"$body"
		if [ "$email" = docs-mirror@glab.invalid ] && [[ $last =~ ^Source-Commit:\ ([0-9a-f]{40}|[0-9a-f]{64})$ ]]; then
			S=${BASH_REMATCH[1]}
			break
		fi
		# A hand commit: counted, and the first 20 named by their first 12 hex, as the subject names
		# the source commit.
		hand=$((hand + 1))
		[ "$hand" -gt 20 ] || hand_list=${hand_list:+$hand_list }${sha:0:12}
	done <"$TD/log"
	[ -n "$S" ] || refuse 'the mirror branch holds no commit of the mirror: not a docs mirror'

	# 9. Order and adoption [D12]. A shallow checkout cannot answer the ancestry question
	# (merge-base exits 128 there, not 1), so it is refused unless S is HEAD itself.
	adopt=${DOCS_MIRROR_ADOPT:-}
	diverged="the mirror's source commit $S is not in this history (set DOCS_MIRROR_ADOPT=$S once to accept)"
	if [ "$S" != "$H" ]; then
		[ "$(git rev-parse --is-shallow-repository 2>"$TD/err")" != true ] ||
			refuse 'shallow checkout: fetch the full history (fetch-depth: 0 / GIT_DEPTH: "0")'
		if ! git cat-file -e "$S^{commit}" 2>"$TD/err"; then
			[ "$adopt" = "$S" ] || refuse "$diverged"
			adopting=1
		else
			git merge-base --is-ancestor "$S" "$H" 2>"$TD/err"
			rc=$?
			if [ "$rc" -eq 1 ]; then
				git merge-base --is-ancestor "$H" "$S" 2>"$TD/err"
				rc=$?
				if [ "$rc" -eq 0 ]; then
					echo "docs-mirror: skipped: the mirror already holds a later source commit ${S:0:12}" >&2
					exit 0
				fi
				if [ "$rc" -eq 1 ]; then
					[ "$adopt" = "$S" ] || refuse "$diverged"
					adopting=1
				fi
			fi
			if [ "$rc" -ne 0 ] && [ -z "$adopting" ]; then
				echo "docs-mirror: could not compare the source commits (merge-base rc=$rc)" >&2
				exit 2
			fi
		fi
	fi
fi
# Reached by every run that goes on, the first run of a new branch included.
if [ -n "${DOCS_MIRROR_ADOPT:-}" ] && [ -z "$adopting" ]; then
	echo 'docs-mirror: DOCS_MIRROR_ADOPT is set but this run did not need it: remove it' >&2
fi

# 10. Commit and publish. An equal tree needs no commit, unless the run adopts (step 9).
if [ -n "$tip" ] && [ -z "$adopting" ] && [ "$(git rev-parse --verify -q "$tip^{tree}" 2>"$TD/err")" = "$T" ]; then
	if [ "$hand" -gt 0 ]; then
		echo "docs-mirror: nothing to mirror ($hand commit(s) not made by the mirror leave the tree equal to docs/)" >&2
	else
		echo 'docs-mirror: nothing to mirror' >&2
	fi
	exit 0
fi
{
	printf 'docs: mirror %s\n' "${H:0:12}"
	if [ "$hand" -gt 0 ]; then
		if [ "$hand" -gt 20 ]; then
			printf '\nReplaces %s commit(s) not made by the mirror: %s and %s more\n' "$hand" "$hand_list" "$((hand - 20))"
		else
			printf '\nReplaces %s commit(s) not made by the mirror: %s\n' "$hand" "$hand_list"
		fi
	fi
	[ -z "$adopting" ] || printf '\nAdopts %s after the source history changed.\n' "$S"
	printf '\nSource-Commit: %s\n' "$H"
} >"$TD/msg"
if [ -n "$tip" ]; then
	c=$(git commit-tree --no-gpg-sign "$T" -p "$tip" -F "$TD/msg" 2>"$TD/err")
else
	c=$(git commit-tree --no-gpg-sign "$T" -F "$TD/msg" 2>"$TD/err")
fi
rc=$?
[ "$rc" -eq 0 ] && [ -n "$c" ] || {
	echo "docs-mirror: could not make the mirror commit (commit-tree rc=$rc)" >&2
	exit 2
}
[ "$hand" -eq 0 ] || echo "docs-mirror: warning: the mirror held $hand commit(s) not made by the mirror; this commit replaces their changes and names them" >&2
git push -q --no-verify --no-follow-tags -- "$remote" "$c:refs/heads/$branch" >"$TD/out" 2>"$TD/err"
rc=$?
if [ "$rc" -ne 0 ]; then
	git_lines
	refuse "the mirror refused the push (rc=$rc); the next run retries"
fi
echo "docs-mirror: mirrored ${H:0:12} as ${c:0:12}" >&2
exit 0
