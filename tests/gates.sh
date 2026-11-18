#!/usr/bin/env bash
# Runs every gate of this repo and compares each result with its expected value: the syntax and
# execute-bit check and shellcheck on the scripts, the five script tests, `claude plugin validate
# --strict`, the component lines of `claude plugin details`, and the searches that nothing else
# catches. It prints one line per check, `ok G<n> <name>` or `FAIL G<n> <name>: <reason>`, then
# `PASS n/n` or `FAIL f/n`.
#
# Call it as `bash tests/gates.sh`, with no arguments, from anywhere: it changes to the repo root
# before any check. It changes no file in the repo; its work directory under `$TMPDIR` is removed
# on every exit path, an INT, TERM or HUP signal included.
#
# Exit codes: 0 every check passed; 1 at least one check failed; 2 a preflight failed (a bash
# older than 4.4, no TMPDIR or one that is not an absolute path, no Claude Code CLI, no jq or no
# `shellcheck`, or no work directory), in which case it prints one line on stderr and no ok, FAIL
# or PASS line.
set -uo pipefail

# Preflight. A failed one stops the script before any check, with one stderr line and exit 2,
# so no later line is printed as though the gates had run: neither FAIL lines nor a skip, since a
# skip could be pasted as green and a list of partial `ok` lines could pass as gate evidence.
# History: the old block in AGENTS.md stopped with `: "${claude:?...}"`. That held when the block
# ran as a script or through an agent's shell, but pasted into an interactive shell the `:?`
# aborts only its own line and the rest still ran; a script stops instead. `:?` is not used here
# either: it prints a bash-formatted `...: line n: ...` message and exits 1, not 2.
# The bash line is first: this script is known to have run on bash 5.3.9 only, and an older bash -
# before 4.4 an empty array under `set -u` is an error (the guard at G24 below) - could fail
# part-way with its own message; this line stops it with one line instead
# [slim-agents-md/follow-ups.md FU2] [script-hardening/plan.md D4]. Only this bash is checked; the
# tests below run under the `bash` on `PATH`, which may be another [script-hardening/plan.md FU-SH2].
# That a real bash older than 4.4 reaches this line and is refused is UNVERIFIED: none was at hand,
# so only copies of this script with the version numbers replaced ran it.
# The TMPDIR, PATH and CLI lines run before the `cd` below: a relative `TMPDIR` would put the work
# directory inside the repo, so it is refused; a relative `PATH` entry is made absolute against the
# directory the script was called from, and so is a relative `CLAUDE_BIN`.
if [ "${BASH_VERSINFO[0]}" -lt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 4 ]; }; then echo "gates.sh: bash 4.4 or newer is required, this is bash $BASH_VERSION" >&2; exit 2; fi
[ -n "${TMPDIR:-}" ] || { echo 'gates.sh: TMPDIR unset - export it to the temp directory your host file names' >&2; exit 2; }
case $TMPDIR in /*) ;; *) echo 'gates.sh: TMPDIR is not an absolute path - export it to the temp directory your host file names' >&2; exit 2 ;; esac
# Every relative `PATH` entry made absolute against the directory the script was called from, an
# empty one - which means that directory - included: the preflight's `command -v` found a relative
# one from there, but the checks run after the `cd`, where the same entry names another directory or
# none, so jq, shellcheck and the tests used another tool than the one the preflight found
# [slim-agents-md/follow-ups.md FU1]. An entry starting `/` is kept, and so is one starting `~`,
# which bash expands against `$HOME` when it searches `PATH`. The `:` added at the end ends the last
# entry, so a trailing empty entry is kept too.
rest=$PATH: p=''
while [ -n "$rest" ]; do
	e=${rest%%:*} rest=${rest#*:}
	case $e in
	/* | '~'*) ;;
	'') e=$PWD ;;
	*) e=$PWD/$e ;;
	esac
	p=${p:+$p:}$e
done
PATH=$p
# `claude` is the Claude Code CLI: `claude` on `PATH`, or the path in `CLAUDE_BIN` that the host
# file names, for a host without `claude` on `PATH`.
claude=$(command -v "${CLAUDE_BIN:-claude}") || { echo 'gates.sh: no Claude Code CLI found - set CLAUDE_BIN to the path your host file names' >&2; exit 2; }
case $claude in /*) ;; *) claude=$PWD/$claude ;; esac
command -v jq >/dev/null || { echo 'gates.sh: no jq found on PATH' >&2; exit 2; }
command -v shellcheck >/dev/null || { echo 'gates.sh: no shellcheck found on PATH' >&2; exit 2; }
cd "$(dirname "$0")/.." || exit 2

# The work directory and the CLI's config directory inside it. The script makes the config
# directory and starts no `claude` command when it cannot - with `TMPDIR` unset nothing runs, as
# the preflight above stops first - and the trap removes the directory again on every exit path.
# Bash does not run an EXIT trap when a signal kills it, so INT, TERM and HUP each exit with the
# usual 128+n code through the EXIT trap instead.
# The script starts no background process, so there is nothing to kill by PID.
W=$(mktemp -d "$TMPDIR/gates.XXXXXX") || { echo 'gates.sh: cannot make a work directory under TMPDIR' >&2; exit 2; }
trap 'rm -rf "${W:?}"' EXIT
trap 'exit 130' INT; trap 'exit 143' TERM; trap 'exit 129' HUP
mkdir "$W/claude-config" || { echo 'gates.sh: cannot make the config directory under TMPDIR' >&2; exit 2; }
cfg=$W/claude-config

# Expected values. These arrays are the one copy of them in this repo's tooling; `README.md` and
# each plugin's `hooks/hooks.json` state them too (docs/one-fact.md).
SCRIPTS=(
	plugins/memory-sync/scripts/memory-sync.sh
	plugins/glab/scripts/manager-bootstrap.sh
	plugins/glab/scripts/context-size.sh
	plugins/glab/scripts/plan-gate.sh
	tests/memory-sync.test.sh
	tests/context-size.test.sh
	tests/plan-gate.test.sh
	tests/manager-bootstrap.test.sh
	tests/product-loop.test.sh
	tests/gates.sh
)
TESTS=(
	'bash tests/memory-sync.test.sh plugins/memory-sync/scripts/memory-sync.sh'
	'bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh'
	'bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh'
	'bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh'
	'bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh'
)
GLAB_SKILLS=(
	audit bootstrap comments commit product-manager product-plan product-plan-analyze
	product-project-brief product-project-plan-analyze product-project-plan-verdict project-analyze
	project-develop project-integrate project-manager project-plan project-plan-accept
	project-plan-analyze project-plan-report project-record project-review project-ship push
	security session-rules severity
)
GLAB_AGENTS=(
	committer product-analyzer product-planner project-analyzer project-developer
	project-integrator project-plan-analyzer project-planner project-reviewer
)
GLAB_HOOKS='Hooks (4)  SessionStart, UserPromptSubmit, PostToolUse, Stop  (harness-only — no model context cost)'
MS_SKILLS=(sync-memory)
# Count 0, so its line is `Agents (0)` with no names.
MS_AGENTS=()
MS_HOOKS='Hooks (4)  SessionStart, SessionEnd, PostToolUse, Stop  (harness-only — no model context cost)'
MARKET=('glab = glab' 'memory-sync = memory-sync')
MODEL_LINES=(
	'plugins/glab/agents/project-analyzer.md:model: sonnet'
	'plugins/glab/agents/committer.md:model: haiku'
	'plugins/glab/agents/project-developer.md:model: sonnet'
	'plugins/glab/agents/project-integrator.md:model: sonnet'
	'plugins/glab/agents/project-plan-analyzer.md:model: opus'
	'plugins/glab/agents/project-planner.md:model: opus'
	'plugins/glab/agents/product-analyzer.md:model: opus'
	'plugins/glab/agents/product-planner.md:model: opus'
	'plugins/glab/agents/project-reviewer.md:model: sonnet'
)
SKILL_LINES=(
	'plugins/glab/agents/project-analyzer.md:glab:security'
	'plugins/glab/agents/project-analyzer.md:glab:severity'
	'plugins/glab/agents/committer.md:glab:security'
	'plugins/glab/agents/project-developer.md:glab:security'
	'plugins/glab/agents/project-developer.md:glab:comments'
	'plugins/glab/agents/project-integrator.md:glab:security'
	'plugins/glab/agents/project-integrator.md:glab:comments'
	'plugins/glab/agents/project-plan-analyzer.md:glab:security'
	'plugins/glab/agents/project-plan-analyzer.md:glab:severity'
	'plugins/glab/agents/project-planner.md:glab:project-plan'
	'plugins/glab/agents/project-planner.md:glab:security'
	'plugins/glab/agents/product-analyzer.md:glab:security'
	'plugins/glab/agents/product-analyzer.md:glab:severity'
	'plugins/glab/agents/product-planner.md:glab:product-plan'
	'plugins/glab/agents/product-planner.md:glab:security'
	'plugins/glab/agents/project-reviewer.md:glab:security'
	'plugins/glab/agents/project-reviewer.md:glab:comments'
	'plugins/glab/agents/project-reviewer.md:glab:severity'
)

pass=0 fail=0 n=0
reason=''    # why the current case failed; empty while it holds

bad() { reason="${reason:+$reason; }$*"; }

done_case() { # done_case <id> <name> [extra text for the ok line]
	n=$((n + 1))
	if [ -z "$reason" ]; then
		pass=$((pass + 1))
		echo "ok $1 $2${3:+ $3}"
	else
		fail=$((fail + 1))
		echo "FAIL $1 $2: $reason"
	fi
	reason=''
}

# lines <value...>: one value per line, and nothing at all for no values.
lines() { [ "$#" -eq 0 ] || printf '%s\n' "$@"; }

# same_set <actual text> <expected value...>: compares the lines of the actual text with the
# expected values after `LC_ALL=C sort` on both sides, and names what is missing and unexpected.
same_set() {
	local act=$1 exp miss extra
	shift
	exp=$(lines "$@" | LC_ALL=C sort)
	act=$(lines "$act" | command grep -v '^$' | LC_ALL=C sort)
	[ "$act" = "$exp" ] && return 0
	miss=$(LC_ALL=C comm -23 <(lines "$exp") <(lines "$act") | paste -sd, -)
	extra=$(LC_ALL=C comm -13 <(lines "$exp") <(lines "$act") | paste -sd, -)
	bad "${miss:+missing [$miss]}${miss:+${extra:+ }}${extra:+unexpected [$extra]}"
}

# component <details file> <Skills|Agents> <expected name...>: parses `  <kind> (N)  a, b, ...`
# from the `plugin details` output, then checks N and the names as a set.
component() {
	local file=$1 kind=$2 line cnt names
	shift 2
	line=$(command grep -E "^  $kind " "$file")
	if [ "$(lines "$line" | command grep -c .)" -ne 1 ]; then
		bad "expected one '  $kind ' line, got [$line]"
		return
	fi
	if [[ ! $line =~ ^\ \ $kind\ \(([0-9]+)\)(\ \ (.*))?$ ]]; then
		bad "unparsed line [$line]"
		return
	fi
	cnt=${BASH_REMATCH[1]} names=${BASH_REMATCH[3]}
	[ "$cnt" -eq "$#" ] || bad "count $cnt, expected $#"
	same_set "${names//, /$'\n'}" "$@"
}

# G1-G10. `bash -n` and `test -x` on each script. The `test -x` is there because a hook script
# that has lost its execute bit passes every other gate and then fails when the hook runs. It is
# joined to `bash -n` with `&&` so that the rc is the syntax check's when that fails; with `;` a
# syntax error printed `rc=0`. The file list includes this script, which is checked here and in
# G11 by shellcheck, and never executed: there is no recursion.
i=0
for s in "${SCRIPTS[@]}"; do
	i=$((i + 1))
	bash -n "$s" && test -x "$s"
	rc=$?
	[ "$rc" -eq 0 ] || bad "rc=$rc (syntax error or no execute bit)"
	done_case "G$i" "syntax and execute bit: $s"
done

# G11. shellcheck on the same files. Green is rc 0 with no findings.
out=$(shellcheck "${SCRIPTS[@]}" 2>&1)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
[ -z "$out" ] || bad "findings: $(lines "$out" | head -n 1)"
done_case G11 "shellcheck on ${#SCRIPTS[@]} scripts"

# G12-G16. The five tests. The tests create their work directories under `$TMPDIR`. Each test is
# green when its rc is 0, every line but the last is `ok`, and its last line is `PASS n/n`. On
# FAIL, the reason carries the first non-ok line. The tests' own case counts are not fixed here,
# as the old gate did not fix them either.
i=11
for t in "${TESTS[@]}"; do
	i=$((i + 1))
	read -r -a cmd <<<"$t"
	out=$("${cmd[@]}" 2>&1)
	rc=$?
	[ "$rc" -eq 0 ] || bad "rc=$rc"
	last=$(lines "$out" | tail -n 1)
	first=$(lines "$out" | sed '$d' | command grep -v -m 1 '^ok ')
	[ -z "$first" ] || bad "first non-ok line [$first]"
	if [[ $last =~ ^PASS\ ([0-9]+)/([0-9]+)$ ]] && [ "${BASH_REMATCH[1]}" = "${BASH_REMATCH[2]}" ]; then
		:
	else
		bad "last line [$last], expected PASS n/n"
	fi
	done_case "G$i" "test: ${cmd[1]}" "${last#PASS }"
done

# Every `claude` command runs in this one subshell, with `CLAUDE_CONFIG_DIR` set to the new, empty
# directory made above. The CLI writes into its config directory even for `plugin validate`, and
# without the variable that directory is the live `~/.claude`. The subshell starts no `claude`
# command when the directory is missing, and the variable is never exported empty. All CLI output
# goes into the work directory; the comparisons run afterwards.
(
	[ -d "$cfg" ] || exit 1
	export CLAUDE_CONFIG_DIR="$cfg"
	k=0
	for p in plugins/glab plugins/memory-sync .; do
		k=$((k + 1))
		"$claude" plugin validate --strict "$p" >"$W/validate.$k" 2>&1
		echo $? >"$W/validate.$k.rc"
	done
	"$claude" --plugin-dir ./plugins plugin details glab >"$W/details.glab" 2>"$W/details.glab.err"
	"$claude" --plugin-dir ./plugins plugin details memory-sync >"$W/details.ms" 2>"$W/details.ms.err"
)

# G17-G19. `plugin validate --strict` on each plugin and on the marketplace: its last line is
# `✔ Validation passed`, with rc 0.
i=16 k=0
for p in plugins/glab plugins/memory-sync .; do
	i=$((i + 1)) k=$((k + 1))
	if [ -f "$W/validate.$k" ]; then
		last=$(tail -n 1 "$W/validate.$k")
		[ "$last" = '✔ Validation passed' ] || bad "last line [$last]"
		rc=$(cat "$W/validate.$k.rc")
		[ "$rc" = 0 ] || bad "rc=$rc"
	else
		bad "the CLI did not run"
	fi
	done_case "G$i" "plugin validate --strict $p"
done

# G20/G21 and G23/G24. Skills and Agents are compared as sets, with their count: the CLI lists
# them in directory read order, which is not stable.
# G22/G25. The Hooks line is compared as an exact string. The CLI prints the suffix
# `  (harness-only — no model context cost)` after it on the same line; it prints that suffix, and
# it is expected.
component "$W/details.glab" Skills "${GLAB_SKILLS[@]}"
done_case G20 "glab Skills (${#GLAB_SKILLS[@]})"
component "$W/details.glab" Agents "${GLAB_AGENTS[@]}"
done_case G21 "glab Agents (${#GLAB_AGENTS[@]})"
line=$(command grep -E '^  Hooks ' "$W/details.glab")
[ "$line" = "  $GLAB_HOOKS" ] || bad "line [$line]"
done_case G22 "glab $GLAB_HOOKS"
component "$W/details.ms" Skills "${MS_SKILLS[@]}"
done_case G23 "memory-sync Skills (${#MS_SKILLS[@]})"
# The `+` expansion: an empty array under `set -u` is an unbound-variable error before bash 4.4.
# The preflight refuses such a bash, but the guard stays: that refusal never ran on a real bash
# older than 4.4 (UNVERIFIED), and the guard costs nothing.
component "$W/details.ms" Agents ${MS_AGENTS[@]+"${MS_AGENTS[@]}"}
done_case G24 "memory-sync Agents (${#MS_AGENTS[@]})"
line=$(command grep -E '^  Hooks ' "$W/details.ms")
[ "$line" = "  $MS_HOOKS" ] || bad "line [$line]"
done_case G25 "memory-sync $MS_HOOKS"

# G26. Each marketplace entry's name equals the name in the `plugin.json` its source points at.
# Validation does not compare a marketplace entry with the plugin it points at; it passes with a
# wrong name and with a directory that does not exist.
out=$(jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r nm src; do echo "$nm = $(jq -r .name "$src/.claude-plugin/plugin.json")"; done)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
[ "$out" = "$(lines "${MARKET[@]}")" ] || bad "got [$(lines "$out" | paste -sd, -)]"
done_case G26 "marketplace names match plugin.json"

# G27. No `user_config` in any `hooks.json`: expected `:0` after each `hooks.json`, then rc 1.
# `grep -c` exits 1 when it counts nothing, and nothing is the green result here. A
# `${user_config.…}` in a hook command passes validation and fails when the hook runs.
out=$(command grep -c user_config plugins/*/hooks/hooks.json)
rc=$?
exp=$(for f in plugins/*/hooks/hooks.json; do echo "$f:0"; done)
[ "$out" = "$exp" ] || bad "got [$(lines "$out" | paste -sd, -)]"
[ "$rc" -eq 1 ] || bad "rc=$rc, expected 1"
done_case G27 "no user_config in hooks.json"

# G28. A count of 1 or more after each of the three files, then rc 0. Read the counts, not the
# rc: `grep -c` exits 0 as soon as one file matches. The phrase is the hedge on
# `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` - documented as the override for the `SessionEnd`
# budget, not yet shown to cover a hook that a plugin provides - and no other gate notices when
# the script comment, the skill or the README starts stating it as fact.
hedge=(plugins/memory-sync/scripts/memory-sync.sh plugins/memory-sync/skills/sync-memory/SKILL.md README.md)
out=$(command grep -c -F 'not yet confirmed' "${hedge[@]}")
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
for f in "${hedge[@]}"; do
	c=$(lines "$out" | command grep -F "$f:" | sed 's/.*://')
	[[ $c =~ ^[0-9]+$ ]] && [ "$c" -ge 1 ] || bad "$f count [${c}]"
done
done_case G28 "'not yet confirmed' hedge in ${#hedge[@]} files"

# G29. The model of each agent, exactly these lines (compared after sorting both sides: grep
# prints them in glob order), then rc 0. `plugin validate --strict` passes an unknown model value
# and `plugin details` shows none, so nothing else catches a typo.
out=$(command grep -H '^model: ' plugins/*/agents/*.md)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
same_set "$out" "${MODEL_LINES[@]}"
done_case G29 "agent models (${#MODEL_LINES[@]} lines)"

# G30. The skills each agent preloads, exactly these lines (sorted on both sides), none ending
# `MISSING`. A line ends `MISSING` when its entry names no `skills/<name>/SKILL.md` in that
# plugin, when that file's frontmatter has no line `name: <name>` - Claude Code names a plugin
# skill by that line, not by its directory - or when it carries another plugin's prefix.
# `plugin validate --strict` passes an agent's `skills:` entry that names no skill and
# `plugin details` does not show the lists, so nothing else catches a typo.
out=$(for f in plugins/*/agents/*.md; do awk 'FNR==1{n=0} /^---$/{n++; next} n==1 && /^skills:/{s=1; next} n==1 && s && /^  - /{print FILENAME ":" $2; next} {s=0}' "$f"; done | while IFS=: read -r f p s; do r=${f%%/agents/*}; if test -f "$r/skills/$s/SKILL.md" && command grep -qx "name: $s" "$r/skills/$s/SKILL.md" && [ "$p" = "$(jq -r .name "$r/.claude-plugin/plugin.json")" ]; then echo "$f:$p:$s"; else echo "$f:$p:$s MISSING"; fi; done)
same_set "$out" "${SKILL_LINES[@]}"
done_case G30 "agent skills (${#SKILL_LINES[@]} lines)"

# G31. No line, then rc 1. A frontmatter `name:` that carries the plugin prefix passes validation
# and `plugin details`, and nothing else catches it.
out=$(command grep -rH --include='*.md' '^name: .*:' plugins)
rc=$?
[ -z "$out" ] || bad "got [$(lines "$out" | paste -sd, -)]"
[ "$rc" -eq 1 ] || bad "rc=$rc, expected 1"
done_case G31 "no prefixed name: in plugins"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
