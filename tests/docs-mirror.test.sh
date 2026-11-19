#!/usr/bin/env bash
# Exercises docs-mirror.sh (the glab docs mirror, plugins/glab/templates/docs-mirror/) against
# source repositories and bare mirror repositories made here, under $TMPDIR; it never reaches a
# network remote or a real ssh. Each case builds its own folder $W/<case>/ with a source repo src/
# (branch main, a docs/ tree and code.c outside it) and an empty bare mirror.git
# [docs-mirror/plan-tests.md]:
# DM1 usage (a branch starting - for that reason), DM2 not in a work tree, DM3 no docs/, DM4 docs a
# file, DM5 the first mirror (a hostile identity, GIT_DIR, GIT_INDEX_FILE and GIT_CONFIG_COUNT in
# the environment, a signing config), DM6 a second run on the same HEAD, and one with empty
# variables, DM7 modes, symlinks, CRLF, deletions and renames, DM8 a change outside docs/, DM9 a
# hand edit in the mirror (one with a Source-Commit line, and 21 hand commits), DM10 a branch that
# is not a mirror, DM11 a stale run (and a failing merge-base), DM12 a rewritten source (in the
# checkout and in a fresh clone) and its adoption, DM13 DOCS_MIRROR_ADOPT left set, DM14 a shallow
# checkout, DM15 a refused push (and a failing commit-tree), DM16 the ssh path with a key and a
# known-hosts line (a key ending in a newline too), DM17 a key without known hosts and an unusable
# TMPDIR, DM18 a TERM mid-run, DM19 git's lines cut and redacted (git tracing on, from the
# environment and from a config file; a failed fetch; ssh's own lines; the scp and ssh:// forms, the
# path alone, a host that is not a host name), DM20 the checkout untouched (a remote name refused, a
# legacy remote file's ref not moved), DM21 the two CI templates, DM22 no forced update in the
# script, DM23 a branch other than main and a nested ref of the same tail, DM24 an old bash, DM25 an
# old git.
# ssh is a stub placed first on PATH (AGENTS.md, Tests): it records its arguments and serves the
# remote command from the local bare repo. DM16 also puts a git wrapper first on PATH, which
# records whether the key text reached a git process's environment and runs the real git; DM11,
# DM15 and DM19 put another first, which fails one git subcommand with rc 128. git
# reads no config of the host: the test's own GIT_CONFIG_GLOBAL, HOME and XDG_CONFIG_HOME, and no
# system file, as tests/plan-gate.test.sh.
#
#   bash tests/docs-mirror.test.sh <path to docs-mirror.sh>
#
# One line per case, `ok DM<n> <name>` or `FAIL DM<n> <name>: <reason>`, then `PASS n/n` or
# `FAIL f/n`. Exit 0 every case passed; 1 a case failed; 2 a preflight failed (usage, bash older
# than 4.4, git older than 2.28, no TMPDIR, no work directory), with one stderr line and no ok line.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to docs-mirror.sh>" >&2; exit 2; }
# bash 4.4: an empty array under `set -u` is an error before it, and `run` below passes one.
if ((BASH_VERSINFO[0] * 1000 + BASH_VERSINFO[1] < 4004)); then echo "docs-mirror.test.sh: bash 4.4 or newer is required, this is bash $BASH_VERSION" >&2; exit 2; fi
# git 2.28 or newer: the cases make their repositories with `git init -b`.
gv=$(git --version 2>/dev/null) || gv=''
gv=${gv#git version }
gmaj=${gv%%.*} gmin=${gv#*.}
gmin=${gmin%%.*}
case $gmaj.$gmin in *[!0-9.]* | .* | *.) gmaj=0 gmin=0 ;; esac
if ! { [ "$gmaj" -gt 2 ] || { [ "$gmaj" -eq 2 ] && [ "$gmin" -ge 28 ]; }; }; then
	echo 'docs-mirror.test.sh: git 2.28 or newer is required' >&2
	exit 2
fi
[ -n "${TMPDIR:-}" ] || { echo 'docs-mirror.test.sh: TMPDIR unset - export it to the temp directory your host file names' >&2; exit 2; }
# Absolute, because every run starts from a case's folder. The templates are read beside it (DM21).
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
TPL=$(dirname "$SCRIPT")
W=$(mktemp -d "$TMPDIR/docs-mirror-test.XXXXXX") || { echo 'docs-mirror.test.sh: cannot make a work directory under TMPDIR' >&2; exit 2; }
# The only background process is DM18's run, the script's own bash, whose PID BG holds while it may
# run; BG is cleared once it is waited on, so the trap never kills a PID the test no longer holds.
# The stub ssh under that run is a grandchild: `wait` cannot wait on it (not a child of this shell)
# and the test does not kill it - a PID it did not start, which may be reused once the stub ends.
# The stub ends by itself after STUB_SSH_SLEEP seconds, so the trap polls it with kill -0 (no
# signal) for at most that plus 5 s, then removes the work directory [docs-mirror/plan.md D36].
BG='' STUB_PIDFILE='' STUB_SSH_SLEEP=5
cleanup() {
	local k=0 sp=''
	[ -z "$BG" ] || kill "$BG" 2>/dev/null
	[ -z "$STUB_PIDFILE" ] || [ ! -s "$STUB_PIDFILE" ] || sp=$(cat "$STUB_PIDFILE")
	if [ -n "$sp" ]; then
		while kill -0 "$sp" 2>/dev/null && [ "$k" -lt $(((STUB_SSH_SLEEP + 5) * 10)) ]; do
			sleep 0.1
			k=$((k + 1))
		done
	fi
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
cd "$W" || exit 2
# For the whole test, the test's own git commands included: an empty global config, no system one,
# a HOME and XDG_CONFIG_HOME of the test's, so that no setting of the host reaches a case; none of
# the GIT_* names the script unsets, nor an ssh command or a mirror variable of the host.
# GIT_CEILING_DIRECTORIES stops repository discovery at the work directory, so DM2's folder is not
# found inside a repository above it. LC_ALL=C: DM19 matches git's English words.
mkdir -p "$W/xdg" "$W/home" "$W/bin" "$W/rt" && : >"$W/gitconfig" || exit 2
export GIT_CONFIG_GLOBAL=$W/gitconfig GIT_CONFIG_NOSYSTEM=1 XDG_CONFIG_HOME=$W/xdg HOME=$W/home GIT_CEILING_DIRECTORIES=$W LC_ALL=C
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_AUTHOR_DATE GIT_COMMITTER_DATE GIT_CONFIG
unset GIT_CONFIG_PARAMETERS GIT_CONFIG_COUNT GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS
unset GIT_SSH GIT_SSH_COMMAND GIT_SSH_VARIANT DOCS_MIRROR_URL DOCS_MIRROR_SSH_KEY DOCS_MIRROR_KNOWN_HOSTS DOCS_MIRROR_ADOPT

# The stub ssh. It appends its arguments, one per line, to $STUB_CASE/ssh.args; for the argument
# after -i, the file's mode and whether it equals $STUB_CASE/expected-key, to ssh.key, and whether
# DOCS_MIRROR_SSH_KEY reached it. With STUB_SSH_FAIL it prints that text on stderr and exits 255,
# as ssh does when it cannot connect or log in (DM19). With STUB_SSH_SLEEP it writes its own PID
# and sleeps first (DM18). Then it runs its last argument, git's remote command
# (`git-upload-pack '<path>'`), as `git upload-pack '<path>'` through sh -c, so an ssh remote is
# served from the local bare repo.
cat >"$W/bin/ssh" <<'EOF'
#!/usr/bin/env bash
c=${STUB_CASE:?}
printf '%s\n' "$@" >>"$c/ssh.args"
prev=''
for a in "$@"; do
	if [ "$prev" = -i ]; then
		stat -c %a "$a" >>"$c/ssh.key"
		if cmp -s "$a" "$c/expected-key"; then echo content:equal; else echo content:differs; fi >>"$c/ssh.key"
	fi
	prev=$a
done
if [ -n "${DOCS_MIRROR_SSH_KEY+x}" ]; then echo env-key:set; else echo env-key:unset; fi >>"$c/ssh.key"
if [ -n "${STUB_SSH_FAIL:-}" ]; then
	printf '%s\n' "$STUB_SSH_FAIL" >&2
	exit 255
fi
if [ -n "${STUB_SSH_SLEEP:-}" ]; then
	echo "$$" >"$c/ssh.pid"
	sleep "$STUB_SSH_SLEEP"
fi
cmd=${!#}
exec sh -c "git ${cmd#git-}"
EOF
chmod +x "$W/bin/ssh" || exit 2
# The git wrapper (DM16), in a folder of its own so that only the runs that name it use it. Each
# call appends a line to $STUB_CASE/git.calls, and one to git.env when its environment holds the
# text of $STUB_CASE/expected-key; then it runs $STUB_REAL_GIT, the git found on PATH here.
mkdir -p "$W/gitwrap" || exit 2
cat >"$W/gitwrap/git" <<'EOF'
#!/usr/bin/env bash
c=${STUB_CASE:?}
echo call >>"$c/git.calls"
if env | /usr/bin/grep -qFf "$c/expected-key"; then echo key-text:inherited >>"$c/git.env"; fi
exec "${STUB_REAL_GIT:?}" "$@"
EOF
chmod +x "$W/gitwrap/git" || exit 2
REAL_GIT=$(command -v git) || exit 2
# The failing git (DM11, DM15, DM19), in a folder of its own: a call whose subcommand is
# $STUB_GIT_FAIL prints one line and exits 128, as git does on a fatal error; any other call runs
# $STUB_REAL_GIT.
mkdir -p "$W/failwrap" || exit 2
cat >"$W/failwrap/git" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = "${STUB_GIT_FAIL:?}" ]; then
	echo "stub: git $1 failed" >&2
	exit 128
fi
exec "${STUB_REAL_GIT:?}" "$@"
EOF
chmod +x "$W/failwrap/git" || exit 2
# fail_env <subcommand>: the environment of a run whose git fails that subcommand.
fail_env() { printf '%s\n' "PATH=$W/failwrap:$PATH" "STUB_GIT_FAIL=$1" "STUB_REAL_GIT=$REAL_GIT"; }
# The fake key: a random string made at run time, never a real key and never a PEM block.
KEY=fake-key-$RANDOM$RANDOM
KH='stub.invalid ssh-ed25519 AAAAfake'

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

# G: the test's own git commands that commit, with an identity of the test's.
G() { git -c user.name=t -c user.email=t@t.invalid "$@"; }
# nlines <text>: its number of lines, 0 for none.
nlines() { if [ -z "$1" ]; then echo 0; else printf '%s\n' "$1" | wc -l; fi; }
# tree_of <repo> <rev>: the tree id. A <rev>:<path> is used as it is: `HEAD:docs^{tree}` would name
# the path "docs^{tree}".
tree_of() { case $2 in *:*) git -C "$1" rev-parse --verify -q "$2" ;; *) git -C "$1" rev-parse --verify -q "$2^{tree}" ;; esac; }
tip() { git -C "$1" rev-parse --verify -q refs/heads/main; }
count() { git -C "$1" rev-list --count refs/heads/main 2>/dev/null || echo 0; }
# has_ref <repo> <ref>: rc 0 when the ref exists.
has_ref() { git -C "$1" rev-parse --verify -q "$2" >/dev/null; }

# newcase <id>: $C/src with docs/ and code.c in one commit, and an empty bare $C/mirror.git.
newcase() {
	C=$W/$1
	mkdir -p "$C/src/docs/sub" || return 1
	(
		cd "$C/src" || exit 1
		git init -q -b main . &&
			printf 'a\n' >docs/a.md && printf 'b\n' >docs/b.md && printf 'c\n' >docs/sub/c.md &&
			printf '#!/bin/sh\n' >docs/run.sh && printf 'int main;\n' >code.c &&
			git add -A && G commit -q -m one
	) && git init -q --bare -b main "$C/mirror.git"
}
# commit_docs <src> <text>: a change under docs/, committed.
commit_docs() { printf '%s\n' "$2" >>"$1/docs/a.md" && G -C "$1" commit -q -am "docs $2"; }

# run <dir> [NAME=value ...] -- <args...>: runs the script from <dir>; sets OUT, ERR and RC.
# Every run must print nothing on stdout (D13), and leave its temporary folder under $W/rt removed.
run() {
	local dir=$1 envs=()
	shift
	while [ "$#" -gt 0 ] && [ "$1" != -- ]; do envs+=("$1") && shift; done
	shift
	(cd "$dir" && exec env TMPDIR="$W/rt" ${envs[@]+"${envs[@]}"} bash "$SCRIPT" "$@") >"$W/out" 2>"$W/err"
	RC=$?
	OUT=$(cat "$W/out") ERR=$(cat "$W/err")
	[ -z "$OUT" ] || bad "stdout not empty: [$OUT]"
	[ -z "$(ls -A "$W/rt")" ] || bad "a temporary folder was left in TMPDIR"
}
# first <id>: a new case whose mirror holds one mirror commit of src's HEAD.
first() {
	newcase "$1" || bad "fixture failed"
	run "$C/src" -- "$C/mirror.git" main
	[ "$RC" -eq 0 ] || bad "the first mirror failed: rc=$RC [$ERR]"
}
# ssh_env: the environment of a run through the stub ssh with a key.
ssh_env() { printf '%s\n' "PATH=$W/bin:$PATH" "STUB_CASE=$C" "DOCS_MIRROR_SSH_KEY=$KEY" "DOCS_MIRROR_KNOWN_HOSTS=$KH"; }
# key_dir <case>: the folder of the key file, from the argument after -i in ssh.args.
key_dir() { local f; f=$(awk 'p{print; exit} $0=="-i"{p=1}' "$1/ssh.args" 2>/dev/null) && [ -n "$f" ] && dirname "$f"; }
# git_lines_ok <outcome prefix>: ERR's last line starts with the prefix; every other line is a
# `docs-mirror: git: ` line, at most 4, none blank after the prefix.
git_lines_ok() {
	local last others k
	last=$(printf '%s\n' "$ERR" | tail -n 1)
	[[ $last == "$1"* ]] || bad "last stderr line [$last] does not start [$1]"
	others=$(printf '%s\n' "$ERR" | sed '$d')
	k=$(nlines "$others")
	[ "$k" -le 4 ] || bad "$k lines before the outcome"
	[ -z "$others" ] || ! printf '%s\n' "$others" | /usr/bin/grep -qv '^docs-mirror: git: ' || bad "a line before the outcome is not a git line: [$others]"
	! printf '%s\n' "$others" | /usr/bin/grep -qE '^docs-mirror: git: [[:space:]]*$' || bad "a blank git line"
}

# DM1
newcase dm1 || bad "fixture failed"
{ git -C "$C/src" checkout -q -b other && git -C "$C/src" checkout -q main; } || bad "checkout other then main failed"
for args in '' "$C/mirror.git" "$C/mirror.git main x" '-x main' ' main' "$C/mirror.git a..b" "$C/mirror.git -b" "$C/mirror.git @{-1}"; do
	if [ "$args" = ' main' ]; then set -- '' main; else read -r -a a <<<"$args" && set -- ${a[@]+"${a[@]}"}; fi
	run "$C/src" -- "$@"
	[ "$RC" -eq 2 ] || bad "rc=$RC for [$args]"
	[ "$(nlines "$ERR")" -eq 1 ] && [[ $ERR == 'docs-mirror: usage: '* ]] || bad "stderr [$ERR] for [$args]"
done
# A branch starting "-" is refused for that reason, before check-ref-format would refuse it for another.
run "$C/src" -- "$C/mirror.git" -b
[ "$ERR" = 'docs-mirror: usage: docs-mirror.sh <mirror remote> <branch> (the branch starts with -)' ] || bad "-b: stderr [$ERR]"
! has_ref "$C/mirror.git" refs/heads/main || bad "the mirror got refs/heads/main"
done_case DM1 "usage: argument count, a remote starting - or empty, a bad branch, @{-1}: exit 2"

# DM2
newcase dm2 || bad "fixture failed"
mkdir -p "$C/empty"
run "$C/empty" -- "$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "rc=$RC"
[ "$(nlines "$ERR")" -eq 1 ] || bad "stderr [$ERR]"
done_case DM2 "not in a work tree: exit 2, one line"

# DM3
newcase dm3 || bad "fixture failed"
{ G -C "$C/src" rm -q -r docs && G -C "$C/src" commit -q -m 'no docs'; } || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "rc=$RC"
[ "$ERR" = 'docs-mirror: REFUSED: no docs/ tree at HEAD' ] || bad "stderr [$ERR]"
! has_ref "$C/mirror.git" refs/heads/main || bad "the mirror got refs/heads/main"
done_case DM3 "no docs/ at HEAD: refused"

# DM4
newcase dm4 || bad "fixture failed"
(cd "$C/src" && G rm -q -r docs && printf 'x\n' >docs && git add docs && G commit -q -m 'docs a file') || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "rc=$RC"
[ "$ERR" = 'docs-mirror: REFUSED: no docs/ tree at HEAD' ] || bad "stderr [$ERR]"
! has_ref "$C/mirror.git" refs/heads/main || bad "the mirror got refs/heads/main"
done_case DM4 "docs is a file: refused"

# DM5. GIT_DIR names a decoy repository with a docs/ of its own: a run that kept it would mirror
# the decoy's tree. GIT_CONFIG_COUNT sets a url.<x>.insteadOf that sends the mirror's path to a
# missing one: a run that kept it would fail to list the mirror.
# commit.gpgsign with a gpg.program that fails: a commit-tree that signed would
# fail. git 2.53's commit-tree does not read commit.gpgsign, so this part guards a git that does.
newcase dm5 || bad "fixture failed"
H=$(git -C "$C/src" rev-parse HEAD)
{ git init -q -b main "$C/decoy" && mkdir "$C/decoy/docs" && printf 'decoy\n' >"$C/decoy/docs/d.md" &&
	G -C "$C/decoy" add -A && G -C "$C/decoy" commit -q -m decoy &&
	git -C "$C/src" config commit.gpgsign true && git -C "$C/src" config gpg.program false; } || bad "fixture failed"
run "$C/src" GIT_AUTHOR_NAME=hostile GIT_COMMITTER_EMAIL=hostile@x.invalid GIT_DIR="$C/decoy/.git" GIT_INDEX_FILE="$C/decoy.index" \
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="url.$C/nowhere.git.insteadOf" GIT_CONFIG_VALUE_0="$C/mirror.git" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC [$ERR]"
M=$C/mirror.git
[ "$(count "$M")" = 1 ] || bad "count $(count "$M")"
[ "$(git -C "$M" rev-list --parents -n 1 refs/heads/main | wc -w)" -eq 1 ] || bad "the first commit has a parent"
[ "$(tree_of "$M" refs/heads/main)" = "$(tree_of "$C/src" HEAD:docs)" ] || bad "tree differs from HEAD:docs"
[ "$(git -C "$M" log -1 --format='%an <%ae>|%cn <%ce>' refs/heads/main)" = 'glab docs-mirror <docs-mirror@glab.invalid>|glab docs-mirror <docs-mirror@glab.invalid>' ] ||
	bad "identity [$(git -C "$M" log -1 --format='%an <%ae>|%cn <%ce>' refs/heads/main)]"
[ "$(git -C "$M" log -1 --format=%s refs/heads/main)" = "docs: mirror ${H:0:12}" ] || bad "subject [$(git -C "$M" log -1 --format=%s refs/heads/main)]"
[ "$(git -C "$M" log -1 --format=%B refs/heads/main | sed '/^$/d' | tail -n 1)" = "Source-Commit: $H" ] || bad "last line is not Source-Commit: $H"
! git -C "$M" ls-tree -r --name-only refs/heads/main | /usr/bin/grep -q code.c || bad "code.c reached the mirror"
[ "$ERR" = "docs-mirror: mirrored ${H:0:12} as $(tip "$M" | cut -c1-12)" ] || bad "stderr [$ERR]"
[ ! -e "$C/decoy.index" ] || bad "GIT_INDEX_FILE was written"
done_case DM5 "first mirror: one root commit, tree HEAD:docs, the mirror's identity, subject and trailer"

# DM6
first dm6
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC"
[ "$(count "$C/mirror.git")" = 1 ] || bad "count $(count "$C/mirror.git")"
[ "$ERR" = 'docs-mirror: nothing to mirror' ] || bad "stderr [$ERR]"
run "$C/src" DOCS_MIRROR_ADOPT= DOCS_MIRROR_SSH_KEY= -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "empty variables: rc=$RC"
[ "$ERR" = 'docs-mirror: nothing to mirror' ] || bad "empty variables: stderr [$ERR]"
[ "$(count "$C/mirror.git")" = 1 ] || bad "count $(count "$C/mirror.git")"
done_case DM6 "a second run on the same HEAD, and with empty variables: nothing to mirror"

# dm7_change <src>: deletes, renames, makes executable, and adds a symlink, a CRLF file, a file
# named with a space and one with a leading -; commits.
dm7_change() {
	(
		cd "$1" || exit 1
		git rm -q docs/a.md && git mv docs/b.md docs/sub/b2.md && chmod +x docs/run.sh &&
			ln -s sub/c.md docs/link.md && printf 'x\r\ny\r\n' >docs/crlf.txt &&
			printf 's\n' >'docs/with space.md' && printf 'd\n' >docs/-dash.md &&
			git add -A && G commit -q -m change
	)
}
# DM7
first dm7
old=$(tip "$C/mirror.git")
dm7_change "$C/src" || bad "fixture failed"
# The signing config of DM5, here for the commit-tree with a parent.
{ git -C "$C/src" config commit.gpgsign true && git -C "$C/src" config gpg.program false; } || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC [$ERR]"
[ "$(count "$C/mirror.git")" = 2 ] || bad "count $(count "$C/mirror.git")"
[ "$(git -C "$C/mirror.git" rev-parse refs/heads/main^)" = "$old" ] || bad "parent is not the old tip"
[ "$(tree_of "$C/mirror.git" refs/heads/main)" = "$(tree_of "$C/src" HEAD:docs)" ] || bad "tree differs from HEAD:docs"
! git -C "$C/mirror.git" ls-tree -r --name-only refs/heads/main | /usr/bin/grep -qx a.md || bad "the deleted a.md is still in the mirror"
done_case DM7 "modes, symlink, CRLF, names, deletion and rename: the mirror's tree is HEAD:docs"

# DM8
first dm8
{ printf 'int x;\n' >>"$C/src/code.c" && G -C "$C/src" commit -q -am code; } || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC"
[ "$(count "$C/mirror.git")" = 1 ] || bad "count $(count "$C/mirror.git")"
[ "$ERR" = 'docs-mirror: nothing to mirror' ] || bad "stderr [$ERR]"
done_case DM8 "a change outside docs/: nothing to mirror"

# hand_commit <case> [message]: a clone of the mirror pushes a commit by h <h@h.invalid> adding
# hand.md, with the message given or "hand"; prints the commit's sha.
hand_commit() {
	git clone -q "$1/mirror.git" "$1/hand" &&
		printf 'hand\n' >"$1/hand/hand.md" && git -C "$1/hand" add hand.md &&
		git -C "$1/hand" -c user.name=h -c user.email=h@h.invalid commit -q -m "${2:-hand}" &&
		git -C "$1/hand" push -q origin HEAD:refs/heads/main && git -C "$1/hand" rev-parse HEAD
}
# hand_ok <hand sha>: the run after a hand commit made one commit on top of it, with src's docs
# tree, naming it, and one warning beside the outcome line.
hand_ok() {
	local M=$C/mirror.git
	[ "$RC" -eq 0 ] || bad "rc=$RC [$ERR]"
	[ "$(count "$M")" = 3 ] || bad "count $(count "$M")"
	[ "$(git -C "$M" rev-parse refs/heads/main^)" = "$1" ] || bad "parent is not the hand commit"
	[ "$(tree_of "$M" refs/heads/main)" = "$(tree_of "$C/src" HEAD:docs)" ] || bad "tree differs from HEAD:docs"
	! git -C "$M" ls-tree -r --name-only refs/heads/main | /usr/bin/grep -qx hand.md || bad "hand.md is still in the mirror"
	git -C "$M" log -1 --format=%B refs/heads/main | /usr/bin/grep -qxF "Replaces 1 commit(s) not made by the mirror: ${1:0:12}" || bad "body lacks the Replaces line"
	[ "$(nlines "$ERR")" -eq 2 ] && [ "$(printf '%s\n' "$ERR" | /usr/bin/grep -c 'warning')" -eq 1 ] || bad "stderr [$ERR] is not one warning and the outcome"
	[[ $(printf '%s\n' "$ERR" | tail -n 1) == 'docs-mirror: mirrored '* ]] || bad "last stderr line is not mirrored"
}
# DM9
first dm9
hs=$(hand_commit "$C") || bad "hand commit failed"
commit_docs "$C/src" more || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" main
hand_ok "$hs"
# dm9b: the hand commit's last line is a Source-Commit line naming HEAD, but its author is not the
# mirror, so it is a hand commit all the same.
first dm9b
hs=$(hand_commit "$C" "hand"$'\n\n'"Source-Commit: $(git -C "$C/src" rev-parse HEAD)") || bad "hand commit failed"
run "$C/src" -- "$C/mirror.git" main
hand_ok "$hs"
# dm9c: 21 hand commits: the body names the newest 20, then "and 1 more".
first dm9c
git clone -q "$C/mirror.git" "$C/hand" || bad "clone failed"
for i in $(seq 21); do
	{ printf '%s\n' "$i" >"$C/hand/hand.md" && git -C "$C/hand" add hand.md &&
		git -C "$C/hand" -c user.name=h -c user.email=h@h.invalid commit -q -m "hand $i"; } || bad "hand commit $i failed"
done
git -C "$C/hand" push -q origin HEAD:refs/heads/main || bad "hand push failed"
hl=$(git -C "$C/hand" rev-list -n 20 HEAD | cut -c1-12 | paste -sd' ' -)
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "21: rc=$RC [$ERR]"
[ "$(count "$C/mirror.git")" = 23 ] || bad "21: count $(count "$C/mirror.git")"
git -C "$C/mirror.git" log -1 --format=%B refs/heads/main | /usr/bin/grep -qxF "Replaces 21 commit(s) not made by the mirror: $hl and 1 more" || bad "21: body lacks the Replaces line naming 20 and 1 more"
done_case DM9 "a hand edit is overwritten on top of it and named, with a docs/ change and without; a hand Source-Commit line; 21 hand commits"

# DM10
newcase dm10 || bad "fixture failed"
(git init -q -b main "$C/x" && printf 'x\n' >"$C/x/x.md" && git -C "$C/x" add x.md &&
	git -C "$C/x" -c user.name=x -c user.email=x@x.invalid commit -q -m x && git -C "$C/x" push -q "$C/mirror.git" HEAD:refs/heads/main) || bad "fixture failed"
old=$(tip "$C/mirror.git")
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "rc=$RC"
[ "$ERR" = 'docs-mirror: REFUSED: the mirror branch holds no commit of the mirror: not a docs mirror' ] || bad "stderr [$ERR]"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "tip changed"
done_case DM10 "a branch with no mirror commit: refused, tip unchanged"

# DM11
first dm11
H1=$(git -C "$C/src" rev-parse HEAD)
commit_docs "$C/src" two || bad "fixture failed"
H2=$(git -C "$C/src" rev-parse HEAD)
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "mirroring H2: rc=$RC"
git -C "$C/src" checkout -q --detach "$H1" || bad "checkout H1 failed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC"
[ "$(count "$C/mirror.git")" = 2 ] || bad "count $(count "$C/mirror.git")"
[ "$ERR" = "docs-mirror: skipped: the mirror already holds a later source commit ${H2:0:12}" ] || bad "stderr [$ERR]"
# merge-base failing (rc 128, neither yes nor no): exit 2, nothing mirrored.
{ git -C "$C/src" checkout -q main && commit_docs "$C/src" three; } || bad "fixture failed"
mapfile -t e < <(fail_env merge-base)
run "$C/src" "${e[@]}" -- "$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "merge-base: rc=$RC"
[ "$ERR" = 'docs-mirror: could not compare the source commits (merge-base rc=128)' ] || bad "merge-base: stderr [$ERR]"
[ "$(count "$C/mirror.git")" = 2 ] || bad "merge-base: count $(count "$C/mirror.git")"
done_case DM11 "a stale run (HEAD an ancestor of the mirror's source): skipped; a failing merge-base: exit 2"

# rewrite <src> [docs]: the source's main replaced by a new root commit lacking the old history (an
# orphan branch renamed main); with "docs", docs/ changes too, otherwise only code.c.
rewrite() {
	(
		cd "$1" || exit 1
		git checkout -q --orphan new &&
			if [ "${2:-}" = docs ]; then printf 'rewritten\n' >>docs/a.md; fi &&
			printf 'int rewritten;\n' >>code.c && git add -A && G commit -q -m rewritten && git branch -M new main
	)
}
# DM12
first dm12
commit_docs "$C/src" two || bad "fixture failed"
H2=$(git -C "$C/src" rev-parse HEAD)
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "mirroring H2: rc=$RC"
rewrite "$C/src" docs || bad "rewrite failed"
old=$(tip "$C/mirror.git")
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "1st: rc=$RC"
[ "$ERR" = "docs-mirror: REFUSED: the mirror's source commit $H2 is not in this history (set DOCS_MIRROR_ADOPT=$H2 once to accept)" ] || bad "1st: stderr [$ERR]"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "1st: tip changed"
# The same refusal from a fresh clone, as CI makes: there H2 is not in the object store at all,
# while the rewritten checkout still holds it unreachable.
git clone -q "file://$C/src" "$C/fresh" || bad "fresh clone failed"
run "$C/fresh" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "fresh: rc=$RC"
[ "$ERR" = "docs-mirror: REFUSED: the mirror's source commit $H2 is not in this history (set DOCS_MIRROR_ADOPT=$H2 once to accept)" ] || bad "fresh: stderr [$ERR]"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "fresh: tip changed"
cp -a "$C" "$W/dm12c" || bad "copy failed"
run "$C/src" DOCS_MIRROR_ADOPT="$H2" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "2nd: rc=$RC [$ERR]"
[ "$(git -C "$C/mirror.git" rev-parse refs/heads/main^)" = "$old" ] || bad "2nd: not one new commit on the old tip"
git -C "$C/mirror.git" log -1 --format=%B refs/heads/main | /usr/bin/grep -qxF "Adopts $H2 after the source history changed." || bad "2nd: body lacks the Adopts line"
C3=$W/dm12c
old3=$(tip "$C3/mirror.git")
run "$C3/src" DOCS_MIRROR_ADOPT="$(git -C "$C3/src" rev-parse HEAD)" -- "$C3/mirror.git" main
[ "$RC" -eq 1 ] || bad "3rd: rc=$RC"
[ "$(tip "$C3/mirror.git")" = "$old3" ] || bad "3rd: tip changed"
C12=$C
first dm12d
commit_docs "$C/src" two || bad "fixture failed"
H2=$(git -C "$C/src" rev-parse HEAD)
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "4th: mirroring H2: rc=$RC"
rewrite "$C/src" || bad "rewrite failed"
NH=$(git -C "$C/src" rev-parse HEAD)
run "$C/src" DOCS_MIRROR_ADOPT="$H2" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "4th: rc=$RC [$ERR]"
[ "$(count "$C/mirror.git")" = 3 ] || bad "4th: count $(count "$C/mirror.git")"
[ "$(tree_of "$C/mirror.git" refs/heads/main)" = "$(tree_of "$C/mirror.git" refs/heads/main^)" ] || bad "4th: the tree differs from its parent's"
[ "$(git -C "$C/mirror.git" log -1 --format=%B refs/heads/main | sed '/^$/d' | tail -n 1)" = "Source-Commit: $NH" ] || bad "4th: last line is not Source-Commit: <new H>"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "4th, then: rc=$RC"
[ "$ERR" = 'docs-mirror: nothing to mirror' ] || bad "4th, then: stderr [$ERR]"
done_case DM12 "a rewritten source: refused (a fresh clone too), adopted with DOCS_MIRROR_ADOPT=<S>, not with another sha; an equal tree adopted too"

# DM13
C=$C12
commit_docs "$C/src" after || bad "fixture failed"
old=$(tip "$C/mirror.git")
run "$C/src" DOCS_MIRROR_ADOPT="$H2" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC [$ERR]"
[ "$(git -C "$C/mirror.git" rev-parse refs/heads/main^)" = "$old" ] || bad "not mirrored"
[ "$(nlines "$ERR")" -eq 2 ] || bad "stderr [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -q 'DOCS_MIRROR_ADOPT .*remove it' || bad "no warning to remove DOCS_MIRROR_ADOPT: [$ERR]"
[[ $(printf '%s\n' "$ERR" | tail -n 1) == 'docs-mirror: mirrored '* ]] || bad "last stderr line is not mirrored"
done_case DM13 "DOCS_MIRROR_ADOPT left set: mirrored, one warning to remove it"

# DM14
first dm14
commit_docs "$C/src" two || bad "fixture failed"
git clone -q --depth 1 "file://$C/src" "$C/shallow" || bad "shallow clone failed"
old=$(tip "$C/mirror.git")
run "$C/shallow" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "rc=$RC"
[ "$ERR" = 'docs-mirror: REFUSED: shallow checkout: fetch the full history (fetch-depth: 0 / GIT_DEPTH: "0")' ] || bad "stderr [$ERR]"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "tip changed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "mirroring H2 from src: rc=$RC"
run "$C/shallow" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "S = H: rc=$RC"
[ "$ERR" = 'docs-mirror: nothing to mirror' ] || bad "S = H: stderr [$ERR]"
done_case DM14 "a shallow checkout: refused, unless the mirror already holds its HEAD"

# refusing_hook <mirror> [text]: a pre-receive hook that exits 1, printing the text on stderr.
# shellcheck disable=SC2016 # the quotes are the hook's own shell text
refusing_hook() { printf '#!/bin/sh\n%sexit 1\n' "${2:+echo '$2' >&2; }" >"$1/hooks/pre-receive" && chmod 755 "$1/hooks/pre-receive"; }
# DM15
first dm15
refusing_hook "$C/mirror.git" || bad "fixture failed"
commit_docs "$C/src" two || bad "fixture failed"
old=$(tip "$C/mirror.git")
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "rc=$RC"
[[ $(printf '%s\n' "$ERR" | tail -n 1) =~ ^docs-mirror:\ REFUSED:\ the\ mirror\ refused\ the\ push\ \(rc=[0-9]+\)\;\ the\ next\ run\ retries$ ]] || bad "stderr [$ERR]"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "tip changed"
# commit-tree failing, with no hook: exit 2 and nothing pushed (an empty commit would push a deletion).
first dm15b
commit_docs "$C/src" two || bad "fixture failed"
old=$(tip "$C/mirror.git")
mapfile -t e < <(fail_env commit-tree)
run "$C/src" "${e[@]}" -- "$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "commit-tree: rc=$RC"
[ "$ERR" = 'docs-mirror: could not make the mirror commit (commit-tree rc=128)' ] || bad "commit-tree: stderr [$ERR]"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "commit-tree: tip changed"
done_case DM15 "a refused push: refused, tip unchanged; a failing commit-tree: exit 2, tip unchanged"

# DM16
newcase dm16 || bad "fixture failed"
printf '%s\n' "$KEY" >"$C/expected-key"
R="ssh://stub.invalid$C/mirror.git"
mapfile -t e < <(ssh_env)
# The git wrapper first on PATH; ssh_key, the name of the script's own variable for the key,
# exported by the caller: the script must not export the key under it.
run "$C/src" "${e[@]}" PATH="$W/gitwrap:$W/bin:$PATH" STUB_REAL_GIT="$REAL_GIT" ssh_key=decoy -- "$R" main
[ "$RC" -eq 0 ] || bad "rc=$RC [$ERR]"
[ "$(count "$C/mirror.git")" = 1 ] || bad "count $(count "$C/mirror.git")"
[ -s "$C/git.calls" ] || bad "the git wrapper did not run"
[ ! -e "$C/git.env" ] || bad "the key text reached a git process's environment"
for a in -i IdentitiesOnly=yes StrictHostKeyChecking=yes BatchMode=yes GlobalKnownHostsFile=/dev/null; do
	/usr/bin/grep -qxF -- "$a" "$C/ssh.args" 2>/dev/null || bad "ssh.args lacks [$a]"
done
[ "$(awk 'p{print; exit} $0=="-F"{p=1}' "$C/ssh.args" 2>/dev/null)" = /dev/null ] || bad "ssh.args lacks [-F /dev/null]"
/usr/bin/grep -qE '^UserKnownHostsFile=/' "$C/ssh.args" 2>/dev/null || bad "ssh.args lacks UserKnownHostsFile=<f>"
k=$(sort -u "$C/ssh.key" 2>/dev/null | paste -sd, -)
[ "$k" = '600,content:equal,env-key:unset' ] || bad "ssh.key [$k]"
kd=$(key_dir "$C") && [ -n "$kd" ] || bad "no key path in ssh.args"
[ -z "$kd" ] || [ ! -e "$kd" ] || bad "the key folder is still there"
[[ "$OUT$ERR" != *"$KEY"* ]] || bad "the key text was printed"
[[ "$OUT$ERR" != *"$R"* ]] || bad "the remote was printed"
# A key that ends in a newline: the key file gets one newline, not two.
run "$C/src" "${e[@]}" DOCS_MIRROR_SSH_KEY="$KEY"$'\n' -- "$R" main
[ "$RC" -eq 0 ] || bad "newline: rc=$RC [$ERR]"
k=$(sort -u "$C/ssh.key" 2>/dev/null | paste -sd, -)
[ "$k" = '600,content:equal,env-key:unset' ] || bad "newline: ssh.key [$k]"
done_case DM16 "the ssh path: the key file 600 and kept from every child's environment, strict host keys and no ssh config, folder removed"

# DM17
newcase dm17 || bad "fixture failed"
mapfile -t e < <(ssh_env)
run "$C/src" "${e[@]}" DOCS_MIRROR_KNOWN_HOSTS= -- "ssh://stub.invalid$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "rc=$RC"
[ "$(nlines "$ERR")" -eq 1 ] || bad "stderr [$ERR]"
[ ! -e "$C/ssh.args" ] || bad "a git call reached the remote"
mkdir -p "$C/a b"
run "$C/src" "${e[@]}" TMPDIR="$C/a b" -- "ssh://stub.invalid$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "a b: rc=$RC"
[ "$(nlines "$ERR")" -eq 1 ] && [[ $ERR == *'TMPDIR not usable'* ]] || bad "a b: stderr [$ERR]"
[ -z "$(ls -A "$C/a b")" ] || bad "a b: a folder was left there"
[ ! -e "$C/ssh.args" ] || bad "a b: a git call reached the remote"
done_case DM17 "a key without known hosts, and a TMPDIR with a space: exit 2, nothing left"

# DM18
newcase dm18 || bad "fixture failed"
printf '%s\n' "$KEY" >"$C/expected-key"
STUB_PIDFILE=$C/ssh.pid
mapfile -t e < <(ssh_env)
(cd "$C/src" && exec env TMPDIR="$W/rt" "${e[@]}" STUB_SSH_SLEEP="$STUB_SSH_SLEEP" bash "$SCRIPT" "ssh://stub.invalid$C/mirror.git" main) >"$C/out" 2>"$C/err" &
BG=$!
k=0
while [ ! -s "$STUB_PIDFILE" ] && [ "$k" -lt 100 ]; do sleep 0.1 && k=$((k + 1)); done
if [ -s "$STUB_PIDFILE" ]; then
	t0=$(date +%s%N)
	kill -TERM "$BG"
	wait "$BG"
	rc=$?
	BG=''
	t1=$(date +%s%N)
	[ "$rc" -eq 143 ] || bad "rc=$rc"
	[ $(((t1 - t0) / 1000000)) -ge $(((STUB_SSH_SLEEP - 1) * 1000)) ] || bad "exited $(((t1 - t0) / 1000000)) ms after the kill, before the git call returned"
	kd=$(key_dir "$C") && [ -n "$kd" ] || bad "no key path in ssh.args"
	[ -z "$kd" ] || [ ! -e "$kd" ] || bad "the key folder is still there"
	! has_ref "$C/mirror.git" refs/heads/main || bad "the mirror got refs/heads/main"
	[ -z "$(cat "$C/out")" ] || bad "stdout not empty"
	sp=$(cat "$STUB_PIDFILE") k=0
	while kill -0 "$sp" 2>/dev/null && [ "$k" -lt 100 ]; do sleep 0.1 && k=$((k + 1)); done
	! kill -0 "$sp" 2>/dev/null || bad "the stub $sp is still running after 10 s"
else
	bad "the stub wrote no PID file within 10 s"
	kill "$BG" 2>/dev/null
	wait "$BG"
	BG=''
fi
STUB_PIDFILE=''
done_case DM18 "a TERM mid-run: exit 143 after the git call returns, key folder removed, nothing pushed"

# DM19. The local refusal's hook prints 6 numbered lines, so git's stderr starts with 6 "remote:"
# lines: the run prints the first 4, in order, and not the 5th or 6th. git pads a sideband line
# with spaces, so the lines are compared with trailing blanks removed.
first dm19
# shellcheck disable=SC2016 # the quotes are the hook's own shell text
{ printf '#!/bin/sh\nfor i in 1 2 3 4 5 6; do echo "hook line $i" >&2; done\nexit 1\n' >"$C/mirror.git/hooks/pre-receive" &&
	chmod 755 "$C/mirror.git/hooks/pre-receive"; } || bad "fixture failed"
commit_docs "$C/src" two || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "local: rc=$RC"
git_lines_ok 'docs-mirror: REFUSED: the mirror refused the push'
[[ $ERR != *"$C/mirror.git"* && $ERR != *stub.invalid* ]] || bad "local: the remote was printed: [$ERR]"
[ "$(printf '%s\n' "$ERR" | sed '$d' | sed 's/[[:space:]]*$//')" = "$(printf 'docs-mirror: git: remote: hook line %s\n' 1 2 3 4)" ] ||
	bad "local: the git lines are not hook lines 1-4 in order: [$ERR]"
run "$C/src" -- "$C/nowhere.git" main
[ "$RC" -eq 2 ] || bad "nowhere: rc=$RC"
git_lines_ok 'docs-mirror: could not list the mirror (ls-remote rc='
[[ $ERR != *"$C/nowhere.git"* ]] || bad "nowhere: the remote was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -q '^docs-mirror: git: .*does not appear to be a git repository' || bad "nowhere: no git line with the cause: [$ERR]"
# git's tracing on in the caller's environment: its lines would come first and push the cause out.
run "$C/src" GIT_TRACE=1 GIT_TRACE_SETUP=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE2=1 -- "$C/nowhere.git" main
[ "$RC" -eq 2 ] || bad "trace: rc=$RC"
git_lines_ok 'docs-mirror: could not list the mirror (ls-remote rc='
printf '%s\n' "$ERR" | /usr/bin/grep -q '^docs-mirror: git: .*does not appear to be a git repository' || bad "trace: no git line with the cause: [$ERR]"
# The same with a trace name the old list lacked, and the trace2 targets set in a global config.
printf '[trace2]\n\tnormalTarget = 2\n\teventTarget = 2\n\tperfTarget = 2\n' >"$C/trace.gitconfig" || bad "fixture failed"
run "$C/src" GIT_TRACE_REFS=1 GIT_TRACE_FSMONITOR=1 GIT_CONFIG_GLOBAL="$C/trace.gitconfig" -- "$C/nowhere.git" main
[ "$RC" -eq 2 ] || bad "trace2 config: rc=$RC"
git_lines_ok 'docs-mirror: could not list the mirror (ls-remote rc='
[ "$(printf '%s\n' "$ERR" | head -n 1)" = "docs-mirror: git: fatal: '<remote>' does not appear to be a git repository" ] || bad "trace2 config: the first git line is not the cause: [$ERR]"
# A failed fetch (the branch exists, so the run fetches): its git line, then exit 2.
mapfile -t e < <(fail_env fetch)
run "$C/src" "${e[@]}" -- "$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "fetch: rc=$RC"
git_lines_ok 'docs-mirror: could not fetch the mirror (fetch rc=128)'
[ "$ERR" = "$(printf 'docs-mirror: git: stub: git fetch failed\ndocs-mirror: could not fetch the mirror (fetch rc=128)')" ] || bad "fetch: stderr [$ERR]"
refusing_hook "$C/mirror.git" 'stub: protected branch' || bad "fixture failed"
printf '%s\n' "$KEY" >"$C/expected-key"
R="git@stub.invalid:$C/mirror.git"
mapfile -t e < <(ssh_env)
run "$C/src" "${e[@]}" -- "$R" main
[ "$RC" -eq 1 ] || bad "stub: rc=$RC"
git_lines_ok 'docs-mirror: REFUSED: the mirror refused the push'
[[ $ERR != *"$R"* && $ERR != *stub.invalid* && $ERR != *"$C/mirror.git"* ]] || bad "stub: the remote was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -q '^docs-mirror: git: remote: stub: protected branch' || bad "stub: no remote: line: [$ERR]"
# git prints the remote without its user ("To stub.invalid:<path>"): the bare form, replaced whole.
printf '%s\n' "$ERR" | /usr/bin/grep -qxF 'docs-mirror: git: To <remote>' || bad "stub: no [To <remote>] line: [$ERR]"
# The server names the path alone: the path form.
run "$C/src" "${e[@]}" -- "git@stub.invalid:$C/nowhere.git" main
[ "$RC" -eq 2 ] || bad "path: rc=$RC"
git_lines_ok 'docs-mirror: could not list the mirror (ls-remote rc='
[[ $ERR != *"$C/nowhere.git"* ]] || bad "path: the path was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF "docs-mirror: git: fatal: '<remote>' does not appear to be a git repository" || bad "path: no redacted fatal line: [$ERR]"
# The ssh:// form with a user: the bare form ("To ssh://stub.invalid/<path>"), and the path.
R="ssh://git@stub.invalid$C/mirror.git"
run "$C/src" "${e[@]}" -- "$R" main
[ "$RC" -eq 1 ] || bad "url: rc=$RC"
git_lines_ok 'docs-mirror: REFUSED: the mirror refused the push'
[[ $ERR != *stub.invalid* && $ERR != *"$C/mirror.git"* ]] || bad "url: the remote was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF 'docs-mirror: git: To <remote>' || bad "url: no [To <remote>] line: [$ERR]"
# With a port, the path is what follows it.
run "$C/src" "${e[@]}" -- "ssh://git@stub.invalid:22$C/nowhere.git" main
[ "$RC" -eq 2 ] || bad "url path: rc=$RC"
[[ $ERR != *"$C/nowhere.git"* ]] || bad "url path: the path was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF "docs-mirror: git: fatal: '<remote>' does not appear to be a git repository" || bad "url path: no redacted fatal line: [$ERR]"
# A path of only "/" sets none: no "/" in a line is replaced.
run "$C/src" "${e[@]}" -- "ssh://stub.invalid/" main
[ "$RC" -eq 2 ] || bad "root path: rc=$RC"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF "docs-mirror: git: fatal: '/' does not appear to be a git repository" || bad "root path: no unchanged fatal line: [$ERR]"
# A host that is not a host name (a bracketed IPv6 address) sets no host: its "[" is not replaced
# in git's "! [remote rejected]" line.
run "$C/src" "${e[@]}" -- "ssh://[::1]$C/mirror.git" main
[ "$RC" -eq 1 ] || bad "ipv6: rc=$RC"
git_lines_ok 'docs-mirror: REFUSED: the mirror refused the push'
[[ $ERR != *"$C/mirror.git"* ]] || bad "ipv6: the remote was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qF 'docs-mirror: git:  ! [remote rejected]' || bad "ipv6: no [! [remote rejected]] line: [$ERR]"
# ssh's own lines name "<user>@<host>" and the host alone; both are replaced.
run "$C/src" "${e[@]}" STUB_SSH_FAIL="git@stub.invalid: Permission denied (publickey)."$'\n'"ssh: connect to host stub.invalid port 22: Connection refused" -- "$R" main
[ "$RC" -eq 2 ] || bad "ssh: rc=$RC"
git_lines_ok 'docs-mirror: could not list the mirror (ls-remote rc='
[[ $ERR != *stub.invalid* ]] || bad "ssh: the host was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF 'docs-mirror: git: <remote>: Permission denied (publickey).' || bad "ssh: no redacted Permission denied line: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF 'docs-mirror: git: ssh: connect to host <remote> port 22: Connection refused' || bad "ssh: no redacted connect line: [$ERR]"
run "$C/src" "${e[@]}" STUB_SSH_FAIL="git@stub.invalid: Permission denied (publickey)."$'\n'"ssh: connect to host stub.invalid port 22: Connection refused" -- "ssh://git@stub.invalid$C/mirror.git" main
[ "$RC" -eq 2 ] || bad "ssh url: rc=$RC"
[[ $ERR != *stub.invalid* ]] || bad "ssh url: the host was printed: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF 'docs-mirror: git: <remote>: Permission denied (publickey).' || bad "ssh url: no redacted Permission denied line: [$ERR]"
printf '%s\n' "$ERR" | /usr/bin/grep -qxF 'docs-mirror: git: ssh: connect to host <remote> port 22: Connection refused' || bad "ssh url: no redacted connect line: [$ERR]"
done_case DM19 "git's first 4 lines on a failure, in order, the remote redacted in each form git and ssh print"

# DM20
first dm20
S=$C/src
snap20() { git -C "$S" for-each-ref && git -C "$S" status --porcelain=v1 --untracked-files=all && git -C "$S" rev-parse HEAD && git -C "$S" stash list; }
dm7_change "$S" || bad "fixture failed"
{ before=$(snap20) && cp "$S/.git/config" "$C/config.before"; } || bad "snapshot failed"
run "$S" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "rc=$RC [$ERR]"
[ "$before" = "$(snap20)" ] || bad "refs, status, HEAD or stash changed"
cmp -s "$S/.git/config" "$C/config.before" || bad ".git/config changed"
# A remote name of the checkout as the mirror argument: refused, so no refs/remotes/mir/ ref moves.
git -C "$S" remote add mir "$C/mirror.git" || bad "remote add failed"
before=$(snap20) old=$(tip "$C/mirror.git")
run "$S" -- mir main
[ "$RC" -eq 1 ] || bad "name: rc=$RC"
[ "$ERR" = 'docs-mirror: REFUSED: the mirror remote is a remote name of this checkout: pass its URL' ] || bad "name: stderr [$ERR]"
[ "$before" = "$(snap20)" ] || bad "name: refs, status, HEAD or stash changed"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "name: tip changed"
# A legacy .git/remotes/<name> file: `git remote` does not list it, git resolves it. The tree is
# equal, so the run fetches and pushes nothing; the fetch must not move refs/remotes/old/main.
{ mkdir -p "$S/.git/remotes" && printf 'URL: %s\nPull: refs/heads/main:refs/remotes/old/main\n' "$C/mirror.git" >"$S/.git/remotes/old"; } || bad "fixture failed"
before=$(snap20)
run "$S" -- old main
[ "$RC" -eq 0 ] || bad "legacy: rc=$RC [$ERR]"
[ "$before" = "$(snap20)" ] || bad "legacy: refs, status, HEAD or stash changed"
[ "$(tip "$C/mirror.git")" = "$old" ] || bad "legacy: tip changed"
done_case DM20 "the source checkout untouched: refs, status, config, HEAD, stash; a remote name refused"

# DM21. The single-quoted ${{ }} and $NAME are the templates' text, matched literally: hence
# each SC2016 directive.
gh=$TPL/github-docs-mirror.yml gl=$TPL/gitlab-docs-mirror.yml
# shellcheck disable=SC2016
for s in 'branches: [main]' 'contents: read' 'group: glab-docs-mirror' 'cancel-in-progress: false' 'fetch-depth: 0' 'persist-credentials: false' \
	"if: vars.DOCS_MIRROR_URL != ''" 'run: bash .glab/docs-mirror.sh "$DOCS_MIRROR_URL" main' 'TMPDIR: ${{ runner.temp }}' \
	'DOCS_MIRROR_KNOWN_HOSTS: ${{ vars.DOCS_MIRROR_KNOWN_HOSTS }}' 'DOCS_MIRROR_ADOPT: ${{ vars.DOCS_MIRROR_ADOPT }}'; do
	/usr/bin/grep -qF -- "$s" "$gh" 2>/dev/null || bad "github lacks [$s]"
done
/usr/bin/grep -qE 'uses: actions/checkout@[0-9a-f]{40} # v' "$gh" 2>/dev/null || bad "github: checkout not pinned by a full sha with its tag"
# shellcheck disable=SC2016
sl=$(/usr/bin/grep -nF '${{ secrets.' "$gh" 2>/dev/null)
[ "$(nlines "$sl")" -eq 1 ] || bad "github: \${{ secrets. on [$(nlines "$sl")] lines"
# shellcheck disable=SC2016
[ "$(printf '%s' "${sl#*:}" | sed 's/^ *//')" = 'DOCS_MIRROR_SSH_KEY: ${{ secrets.DOCS_MIRROR_SSH_KEY }}' ] || bad "github: the secrets line is [${sl#*:}]"
el=$(/usr/bin/grep -n '^ *env:$' "$gh" | cut -d: -f1) rl=$(/usr/bin/grep -n '^ *run: ' "$gh" | cut -d: -f1)
[ "$(nlines "$el")" -eq 1 ] && [ "$(nlines "$rl")" -eq 1 ] && [ "${sl%%:*}" -gt "$el" ] && [ "${sl%%:*}" -lt "$rl" ] || bad "github: the secrets line is not between env: and run:"
# shellcheck disable=SC2016
for s in 'stage: .post' 'resource_group: docs-mirror' 'GIT_DEPTH: "0"' 'GIT_STRATEGY: clone' \
	"- if: '\$CI_COMMIT_BRANCH == \$CI_DEFAULT_BRANCH && \$CI_PIPELINE_SOURCE == \"push\" && \$DOCS_MIRROR_URL'" \
	'- bash .glab/docs-mirror.sh "$DOCS_MIRROR_URL" "$CI_DEFAULT_BRANCH"'; do
	/usr/bin/grep -qF -- "$s" "$gl" 2>/dev/null || bad "gitlab lacks [$s]"
done
# The job's environment, which the key variable is scoped to: its three lines in order.
[ "$(/usr/bin/grep -A2 -E '^  environment:( |$)' "$gl" 2>/dev/null | sed 's/ *#.*//')" = "$(printf '  environment:\n    name: docs-mirror\n    action: access')" ] ||
	bad "gitlab: the job's environment is not docs-mirror with action: access"
for f in "$gh" "$gl"; do
	[ -f "$f" ] || bad "missing $f"
	! /usr/bin/grep -qE -- 'force|push -f|\+refs/' "$f" 2>/dev/null || bad "$(basename "$f") names a forced update"
done
done_case DM21 "the GitHub and GitLab templates hold the decided lines"

# DM22. `\+[^ ]*:refs/` is a forced refspec whose source is a variable, as "+$c:refs/heads/...".
f=$(/usr/bin/grep -nE -- '--force|push -f|\+refs/|\+[^ ]*:refs/|--delete|--mirror' "$SCRIPT")
[ -z "$f" ] || bad "found [$f]"
p=$(/usr/bin/grep -F 'git push' "$SCRIPT")
[ "$(nlines "$p")" -eq 1 ] && [[ $p == *--no-verify* ]] || bad "git push lines [$p]"
done_case DM22 "no forced update in the script; its one git push line carries --no-verify"

# DM23
newcase dm23 || bad "fixture failed"
run "$C/src" -- "$C/mirror.git" trunk
[ "$RC" -eq 0 ] || bad "trunk: rc=$RC [$ERR]"
has_ref "$C/mirror.git" refs/heads/trunk || bad "trunk: refs/heads/trunk not created"
! has_ref "$C/mirror.git" refs/heads/main || bad "trunk: refs/heads/main created"
newcase dm23b || bad "fixture failed"
G -C "$C/src" push -q "$C/mirror.git" HEAD:refs/heads/x/refs/heads/main || bad "fixture failed"
nested=$(git -C "$C/mirror.git" rev-parse refs/heads/x/refs/heads/main)
run "$C/src" -- "$C/mirror.git" main
[ "$RC" -eq 0 ] || bad "nested: rc=$RC [$ERR]"
has_ref "$C/mirror.git" refs/heads/main || bad "nested: refs/heads/main not created"
[ "$(git -C "$C/mirror.git" rev-list --parents -n 1 refs/heads/main 2>/dev/null | wc -w)" -eq 1 ] || bad "nested: refs/heads/main is not a root commit"
[ "$(git -C "$C/mirror.git" rev-parse refs/heads/x/refs/heads/main)" = "$nested" ] || bad "nested: refs/heads/x/refs/heads/main changed"
done_case DM23 "a branch other than main, and an exact match beside a ref of the same tail"

# old_copy <case> <sed expression>: a copy of the script with its version test changed; the sed
# must have changed the copy, or the case proves nothing.
old_copy() {
	sed "$2" "$SCRIPT" >"$W/$1.sh" || return 1
	! cmp -s "$SCRIPT" "$W/$1.sh"
}
# DM24
newcase dm24 || bad "fixture failed"
old_copy dm24 's/< 4004))/< 6000))/' || bad "the sed changed nothing"
(cd "$C/src" && exec env TMPDIR="$W/rt" bash "$W/dm24.sh" "$C/mirror.git" main) >"$W/out" 2>"$W/err"
rc=$?
[ "$rc" -eq 2 ] || bad "rc=$rc"
[ "$(nlines "$(cat "$W/err")")" -eq 1 ] || bad "stderr [$(cat "$W/err")]"
[ -z "$(cat "$W/out")" ] || bad "stdout not empty"
done_case DM24 "a bash older than required (a copy asking 6.0): exit 2, one line"

# DM25
newcase dm25 || bad "fixture failed"
old_copy dm25 's/< 2028))/< 99000))/' || bad "the sed changed nothing"
(cd "$C/src" && exec env TMPDIR="$W/rt" bash "$W/dm25.sh" "$C/mirror.git" main) >"$W/out" 2>"$W/err"
rc=$?
[ "$rc" -eq 2 ] || bad "rc=$rc"
[ "$(nlines "$(cat "$W/err")")" -eq 1 ] || bad "stderr [$(cat "$W/err")]"
[ -z "$(cat "$W/out")" ] || bad "stdout not empty"
done_case DM25 "a git older than required (a copy asking 99.0): exit 2, one line"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
