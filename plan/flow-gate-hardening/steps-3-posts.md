# Posts — the helper files of `plan.md` A5 and A7

Not part of the change: written to a throwaway folder under `$TMPDIR` by the post that uses them, and removed with it. Extract one with

    awk -v n=<name> '$0 == "~~~~ " n { f = 1; next } /^~~~~$/ { f = 0 } f' plan/flow-gate-hardening/steps-3-posts.md >"$T/<name>"

## window.sh

~~~~ window.sh
# window.sh <plan-gate.sh> [stale]: a report run whose claim's create subshell sleeps 2 s (inserted
# by the caller), sent TERM 1 s in; prints its exit code and what is left in the project folder.
# With "stale", the folder first holds a claim on r1 whose run is gone (a dead pid), so the run
# reaches that create through take_over.
set -u
c=$(mktemp -d "${TMPDIR:?}/fgh-window.XXXXXX") || exit 1
S=$c/store P=$c/plan
mkdir -p "$S/briefs/notes-api" "$P"
printf '# Brief\n' >"$S/briefs/notes-api/brief.md"
printf -- '- brief: briefs/notes-api/brief.md sha256 %s\n' "$(sha256sum <"$S/briefs/notes-api/brief.md" | cut -c1-64)" >"$P/master.md"
printf 'plan\n' >"$P/plan.md"
if [ "${2:-}" = stale ]; then
	# shellcheck disable=SC2016 # $$ is the child's own pid
	printf '%s %s %s %s 1\n' "$(uname -n)" "$(cat /proc/sys/kernel/random/boot_id)" "$(readlink /proc/self/ns/pid)" "$(bash -c 'echo $$')" >"$S/briefs/notes-api/.plan-gate.claim.report.r1"
fi
bash "$1" report "$P" "$S" >/dev/null 2>"$c/err" &
p=$!
sleep 1
kill -TERM "$p"
wait "$p"
echo "rc=$? left: $(cd "$S/briefs/notes-api" && ls -A | paste -sd ' ')"
rm -rf "$c"
~~~~

## window-builds.py

~~~~ window-builds.py
# window-builds.py <old plan-gate.sh> <new plan-gate.sh> <out dir>: the instrumented builds of
# plan.md A5 - sleep 2 inside the claim's create subshell in claim, in the old script, in the new
# one, and in the new one with the hold in claim taken out; and sleep 2 inside the claim's create
# subshell in take_over, in the new script and in the new one with the hold in take_over taken out.
import sys, os
o, n, d = open(sys.argv[1]).read(), open(sys.argv[2]).read(), sys.argv[3]
def put(name, text):
    open(os.path.join(d, name), 'w').write(text)
a = 'if ! (set -C && : >"$1") 2>/dev/null; then'
assert o.count(a) == 1
put('window-old.sh', o.replace(a, 'if ! (set -C && : >"$1" && sleep 2) 2>/dev/null; then'))
b = '''	if (set -C && umask 022 && printf '%s\\n' "$ME" >"$1") 2>/dev/null; then
		CLAIM=$1
		release_signals'''
assert n.count(b) == 1
w = n.replace(b, b.replace('>"$1")', '>"$1" && sleep 2)'))
put('window-new.sh', w)
c = '''	whoami
	hold_signals
	if (set -C'''
assert w.count(c) == 1
put('window-nohold.sh', w.replace(c, '''	whoami
	HELD=''
	if (set -C'''))
e = '''	if (set -C && umask 022 && printf '%s\\n' "$ME" >"$1") 2>/dev/null; then CLAIM=$1; fi'''
assert n.count(e) == 1
t = n.replace(e, e.replace('>"$1")', '>"$1" && sleep 2)'))
put('window-takeover.sh', t)
f = '''	hold_signals
	if ! (set -C && umask 022 && printf '%s\\n' "$ME" >"$lock")'''
assert t.count(f) == 1
put('window-takeover-nohold.sh', t.replace(f, '''	HELD=''
	if ! (set -C && umask 022 && printf '%s\\n' "$ME" >"$lock")'''))
~~~~

## mutants.py

~~~~ mutants.py
# mutants.py <new plan-gate.sh> <out dir>: writes one mutant per name below, each one change to the
# new script, for plan.md A7. A replacement that does not apply stops the run.
import sys, os
src = open(sys.argv[1]).read()
M = {
    'M1-no-lock': [('''	if ! (set -C && umask 022 && printf '%s\\n' "$ME" >"$lock") 2>/dev/null; then
		release_signals
		if [ -e "$lock" ]; then refuse "$2; when no run is writing, remove $lock by hand"; fi
		io "writing $lock"
	fi
	LOCK=$lock''', '''	LOCK=''')],
    'M2-no-reread': [('''	if [ "$again" = "$line" ]; then rm -f -- "$tmp" "$1" || io "writing $1"; fi''', '''	rm -f -- "$tmp" "$1" || io "writing $1"''')],
    'M3-no-hold-publish': [('''	chmod 644 "$TMP_FILE" || io "writing $1"
	hold_signals''', '''	chmod 644 "$TMP_FILE" || io "writing $1"
	HELD=\'\'''')],
    'M4-hold-TERM-only': [('''	trap 'HELD=HUP' HUP
	trap 'HELD=INT' INT''', '')],
    'M5-ignore-not-hold': [("""	trap 'HELD=TERM' TERM
	trap 'HELD=HUP' HUP
	trap 'HELD=INT' INT""", """	trap '' TERM HUP INT""")],
    'M6-no-ef': [('''&& ! [ "$TMP_FILE" -ef "$1" ]''', '')],
    'M7-generic-io': [('''		e=${e//$'\\n'/ }
		echo "plan-gate.sh: writing $1 failed: ${e:-ln printed nothing}; plan-gate.sh publishes with a hard link, so the store must be on a filesystem that has them - the header of plan-gate.sh names them" >&2
		exit 2''', '''		io "writing $1"''')],
    'M8-no-start-compare': [('''		if [ "$P_START" = "$5" ]; then return 1; fi
		return 0''', '''		return 1''')],
    'M8b-readable-is-gone': [('''		if [ "$P_START" = "$5" ]; then return 1; fi
		return 0''', '''		return 0''')],
    'M9-no-zombie': [('''		case $P_STATE in Z | X) return 0 ;; esac\n''', '')],
    'M10-keep-tmp': [('''rm -f -- "$tmp" "$1" || io''', '''rm -f -- "$1" || io''')],
    'M11-no-pidns': [('''[ "$1 $2 $3" = "${ME% * *}" ]''', '''[ "$1 $2" = "${ME% * * *}" ]''')],
    'M12-tmp-not-named': [('''		if [ -e "$tmp" ]; then refuse "$2; when no run is writing, remove $1 and $tmp by hand"; fi\n''', '')],
}
for name, edits in M.items():
    s = src
    for a, b in edits:
        assert s.count(a) == 1, (name, a)
        s = s.replace(a, b)
    open(os.path.join(sys.argv[2], name + '.sh'), 'w').write(s)
    print(name)
~~~~

