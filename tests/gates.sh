#!/usr/bin/env bash
# Runs every gate of this repo and compares each result with its expected value: the syntax and
# execute-bit check and shellcheck on the scripts, the six script tests, `claude plugin validate
# --strict` (G23 is `plugins/glab-team`), the component lines of `claude plugin details` (G42-G44
# are `glab-team`'s), and the searches that nothing else catches. G36-G39, appended last, are the same three kinds of check and the test for the docs
# mirror's script. G40-G41, appended after G39, run the two Node.js suites of `src/glab-team`
# (`pnpm -s broker:test`, `pnpm -s channel:test`) and compare their failures with a pinned host
# list. G45, appended after G44, builds `src/glab-team` again offline and fails when the committed
# `plugins/glab-team` is not that build. It prints one line per check, `ok G<n> <name>` or `FAIL G<n> <name>: <reason>`,
# then `PASS n/n` or `FAIL f/n`.
#
# Ids: the loop blocks number their checks by position, so removing the `memory-sync` plugin in
# this change shifted G1-G11, G15-G19 and G21-G22 and left G12, G13 and G20 unused; G23 is the
# third entry of the validate loop, `plugins/glab-team`. The hard-coded ids (G14, G24-G26, G30,
# G31, G33-G39) did not move. G40 and G41 are hard-coded ids too, appended after G39, and G42-G45
# after G41. G46, appended after G45, is `plugin validate --strict plugins/glab-slim`.
#
# Call it as `bash tests/gates.sh`, with no arguments, from anywhere: it changes to the repo root
# before any check. It changes no tracked file in the repo. Its work directory under `$TMPDIR` is
# removed on every exit path, an INT, TERM or HUP signal included, and so is G45's build directory
# under `src/glab-team/dist/` (`dist/` itself is ignored by git and may be left, empty).
# A TERM sent to the script alone is handled once the foreground suite returns (nothing runs in the
# background). The source's tests put their temp roots under `$TMPDIR`, or under `src/glab-team/.tmp/` when it is `/tmp` or below
# (`src/glab-team/test-support/temp.mjs`); they leave that directory empty, and git ignores it.
#
# Exit codes: 0 every check passed; 1 at least one check failed; 2 a preflight failed (a bash
# older than 4.4, no TMPDIR or one that is not an absolute path, no Claude Code CLI, no jq or no
# `shellcheck`, no Node.js 24 or newer first on `PATH`, no pnpm 10 or newer, `src/glab-team` not
# installed from its lockfile, or no work directory), in which case it prints one line on stderr and no ok, FAIL
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
# before 4.4 an empty array under `set -u` is an error (the guard for it left with G28 and the
# `memory-sync` plugin; bash 4.4 stays required for the docs mirror's script) - could fail
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
# G40-G41 and G45 need Node.js 24 or newer and pnpm 10 or newer, and `src/glab-team` installed from its
# lockfile; without them the suites fail for a reason that is not theirs, so the script stops here
# like the lines above [01-import-source/plan.md 01-D4, 01-D5]. Node.js is the
# `node` first on `PATH`, with no `NODE_BIN` variable: pnpm's `#!/usr/bin/env node` runs on that
# same `node`, so one check covers both. Both versions are read as a minimum, so an upgrade does
# not stop the gates. "Installed" is the `cmp -s` below: pnpm writes
# `node_modules/.pnpm/lock.yaml` at install as a copy of the lockfile, so a missing install and
# one stale after a lockfile change differ from it, with no write and no registry; proven with
# pnpm 10.28.0 only.
nv=$(node --version 2>/dev/null)
if [[ $nv =~ ^v([0-9]+)\. ]] && [ "${BASH_REMATCH[1]}" -ge 24 ]; then :; else echo "gates.sh: Node.js 24 or newer must be the node first on PATH, found ${nv:-none} (README.md)" >&2; exit 2; fi
pv=$(pnpm --version 2>/dev/null)
if [[ $pv =~ ^([0-9]+)\. ]] && [ "${BASH_REMATCH[1]}" -ge 10 ]; then :; else echo 'gates.sh: pnpm 10 or newer not found on PATH (README.md)' >&2; exit 2; fi
cd "$(dirname "$0")/.." || exit 2
cmp -s src/glab-team/node_modules/.pnpm/lock.yaml src/glab-team/pnpm-lock.yaml || { echo 'gates.sh: src/glab-team is not installed from its lockfile - run pnpm install --frozen-lockfile there (README.md)' >&2; exit 2; }

# The work directory and the CLI's config directory inside it. The script makes the config
# directory and starts no `claude` command when it cannot - with `TMPDIR` unset nothing runs, as
# the preflight above stops first - and the trap removes the directory again on every exit path.
# Bash does not run an EXIT trap when a signal kills it, so INT, TERM and HUP each exit with the
# usual 128+n code through the EXIT trap instead.
# The script starts no background process, so there is nothing to kill by PID.
D45=''    # G45's build directory under src/glab-team/dist/, removed by the trap on every exit path
W=$(mktemp -d "$TMPDIR/gates.XXXXXX") || { echo 'gates.sh: cannot make a work directory under TMPDIR' >&2; exit 2; }
trap 'rm -rf "${W:?}"; [ -z "${D45:-}" ] || rm -rf "$D45"' EXIT
trap 'exit 130' INT; trap 'exit 143' TERM; trap 'exit 129' HUP
mkdir "$W/claude-config" || { echo 'gates.sh: cannot make the config directory under TMPDIR' >&2; exit 2; }
cfg=$W/claude-config

# The reporter for G40-G41: one `<file relative to the workspace>: <name>` line per failed or
# cancelled test, suites failing only by their subtests left out, then a `# tests ...` summary
# line. Node's default `spec` reporter prints failures with stacks and has no one-line form, and
# an option after the pnpm script (`pnpm -s x:test --test-reporter=tap`) is not honoured, so the
# reporter goes in through `NODE_OPTIONS`, which is honoured
# [01-import-source/evidence.md F7, plan.md 01-D2]. Written here, not kept as a
# repo file: only this script uses it.
cat >"$W/fail.mjs" <<'REPORTER'
// Prints `<file relative to cwd>: <name>` per failed or cancelled test (suites failing only by
// their subtests left out, skipped and todo tests left out), then `# tests N pass N fail N cancelled N skipped N todo N`.
import { relative } from 'node:path';
export default async function* (source) {
  for await (const ev of source) {
    if (ev.type === 'test:fail' && !ev.data.skip && !ev.data.todo && ev.data.details?.error?.failureType !== 'subtestsFailed')
      yield `${ev.data.file ? relative(process.cwd(), ev.data.file) : '?'}: ${String(ev.data.name).replace(/[\r\n]/g, ' ')}\n`;
    if (ev.type === 'test:summary' && ev.data.file === undefined) {
      const c = ev.data.counts;
      yield `# tests ${c.tests} pass ${c.passed} fail ${c.failed} cancelled ${c.cancelled} skipped ${c.skipped} todo ${c.todo}\n`;
    }
  }
}
REPORTER

# G45's walk of `plugins/glab-team/node_modules`: the lockfile's non-root packages (none is `dev`)
# as `<key> <name>@<version>` against what is on disk, every directory not starting with `.`, each
# package's own `node_modules/` recursed, `@scope/name` expanded. Prints `packages <n>` and exits 0
# when the sets are equal; else every `missing <entry>` line, then every `unexpected <entry>` line,
# each group in `LC_ALL=C` order, and exits 1. A package directory without `package.json` is
# reported as `<path> NO package.json`. Written here for the same reason as the reporter.
cat >"$W/nm.mjs" <<'NMWALK'
import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';
const [plugin, lock] = process.argv.slice(2);
const expected = new Set(), actual = new Set();
for (const [key, meta] of Object.entries(JSON.parse(readFileSync(lock, 'utf8')).packages)) {
  if (key === '' || meta.dev) continue;
  expected.add(`${key} ${meta.name ?? key.split('node_modules/').pop()}@${meta.version}`);
}
function walk(dir, prefix) {
  for (const name of readdirSync(dir).sort()) {
    if (name.startsWith('.')) continue;
    const path = join(dir, name);
    if (!statSync(path).isDirectory()) continue;
    if (name.startsWith('@')) { walk(path, `${prefix}${name}/`); continue; }
    const rel = `${prefix}${name}`, manifest = join(path, 'package.json');
    if (!existsSync(manifest)) { actual.add(`${rel} NO package.json`); continue; }
    const pkg = JSON.parse(readFileSync(manifest, 'utf8'));
    actual.add(`${rel} ${pkg.name}@${pkg.version}`);
    if (existsSync(join(path, 'node_modules'))) walk(join(path, 'node_modules'), `${rel}/node_modules/`);
  }
}
walk(join(plugin, 'node_modules'), 'node_modules/');
const sort = set => [...set].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
const missing = sort(new Set([...expected].filter(e => !actual.has(e)))), unexpected = sort(new Set([...actual].filter(e => !expected.has(e))));
if (missing.length || unexpected.length) {
  for (const e of missing) console.log(`missing ${e}`);
  for (const e of unexpected) console.log(`unexpected ${e}`);
  process.exit(1);
}
console.log(`packages ${actual.size}`);
NMWALK

# Expected values. These arrays are the one copy of them in this repo's tooling; `README.md` and
# each plugin's `hooks/hooks.json` state them too (docs/one-fact.md).
SCRIPTS=(
	plugins/glab/scripts/manager-bootstrap.sh
	plugins/glab/scripts/context-size.sh
	plugins/glab/scripts/plan-gate.sh
	plugins/glab/scripts/glab-level.sh
	plugins/glab/scripts/level-guard.sh
	tests/context-size.test.sh
	tests/plan-gate.test.sh
	tests/manager-bootstrap.test.sh
	tests/product-loop.test.sh
	tests/level-guard.test.sh
	tests/gates.sh
)
TESTS=(
	'bash tests/context-size.test.sh plugins/glab/scripts/context-size.sh'
	'bash tests/plan-gate.test.sh plugins/glab/scripts/plan-gate.sh'
	'bash tests/manager-bootstrap.test.sh plugins/glab/scripts/manager-bootstrap.sh'
	'bash tests/product-loop.test.sh plugins/glab/scripts/plan-gate.sh plugins/glab/scripts/manager-bootstrap.sh'
	'bash tests/level-guard.test.sh plugins/glab/scripts/level-guard.sh'
)
# The docs mirror's script (a template a code repo copies, not a hook) and its test, for G36-G39.
# Not in SCRIPTS or TESTS: appending there renumbers every later check, and G33 and G34 are named
# by number outside this file (docs/one-fact.md) [docs-mirror/plan.md D14].
MIRROR=(
	plugins/glab/templates/docs-mirror/docs-mirror.sh
	tests/docs-mirror.test.sh
)
GLAB_SKILLS=(
	audit bootstrap comments commit product-manager product-plan product-plan-analyze
	product-project-brief product-project-plan-analyze product-project-plan-verdict project-analyze
	project-develop project-integrate project-issue project-manager project-plan project-plan-accept
	project-plan-report project-record project-review project-ship push
	security session-rules severity
)
GLAB_AGENTS=(
	committer product-analyzer product-planner project-analyzer project-developer
	project-integrator project-planner project-reviewer
)
GLAB_HOOKS='Hooks (5)  SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop  (harness-only — no model context cost)'
MARKET=('glab = glab' 'glab-slim = glab-slim' 'glab-team = glab-team')
# G42-G44: the three component lines of `plugin details glab-team` (the Agents line is not pinned).
GLAB_TEAM_LINES=(
	'Skills (5)  messaging-bind, messaging-claim, messaging-join, messaging-status, messaging-watch'
	'Hooks (4)  SessionStart, PreToolUse, Stop, StopFailure  (harness-only — no model context cost)'
	'MCP servers (1)  messaging  (tool schemas resolved at runtime; not counted)'
)
MODEL_LINES=(
	'plugins/glab/agents/project-analyzer.md:model: sonnet'
	'plugins/glab/agents/committer.md:model: haiku'
	'plugins/glab/agents/project-developer.md:model: sonnet'
	'plugins/glab/agents/project-integrator.md:model: sonnet'
	'plugins/glab/agents/project-planner.md:model: opus'
	'plugins/glab/agents/product-analyzer.md:model: opus'
	'plugins/glab/agents/product-planner.md:model: opus'
	'plugins/glab/agents/project-reviewer.md:model: sonnet'
	'plugins/glab-slim/agents/planner.md:model: opus'
	'plugins/glab-slim/agents/developer.md:model: sonnet'
	'plugins/glab-slim/agents/reviewer.md:model: sonnet'
	'plugins/glab-slim/agents/committer.md:model: haiku'
)
SKILL_LINES=(
	'plugins/glab/agents/project-analyzer.md:glab:security'
	'plugins/glab/agents/project-analyzer.md:glab:severity'
	'plugins/glab/agents/committer.md:glab:security'
	'plugins/glab/agents/project-developer.md:glab:security'
	'plugins/glab/agents/project-developer.md:glab:comments'
	'plugins/glab/agents/project-integrator.md:glab:security'
	'plugins/glab/agents/project-integrator.md:glab:comments'
	'plugins/glab/agents/project-planner.md:glab:project-plan'
	'plugins/glab/agents/project-planner.md:glab:security'
	'plugins/glab/agents/product-analyzer.md:glab:security'
	'plugins/glab/agents/product-analyzer.md:glab:severity'
	'plugins/glab/agents/product-planner.md:glab:product-plan'
	'plugins/glab/agents/product-planner.md:glab:security'
	'plugins/glab/agents/project-reviewer.md:glab:security'
	'plugins/glab/agents/project-reviewer.md:glab:comments'
	'plugins/glab-slim/agents/planner.md:glab-slim:plan'
	'plugins/glab-slim/agents/planner.md:glab-slim:security'
	'plugins/glab-slim/agents/developer.md:glab-slim:security'
	'plugins/glab-slim/agents/developer.md:glab-slim:comments'
	'plugins/glab-slim/agents/reviewer.md:glab-slim:security'
	'plugins/glab-slim/agents/committer.md:glab-slim:security'
	'plugins/glab/agents/project-reviewer.md:glab:severity'
)
# The tests of `src/glab-team` that fail on the reference host, for G40-G41: each is a line
# `<file>: <name>` as the reporter prints it, and they are compared as sorted lines with duplicates
# kept. A check is `ok` when every failure is in its array, zero included, and its line names the
# known ones it saw; it is `FAIL` on any failure outside the array. A pinned test that passes is no
# failure and is not reported [the master's index.md D16].
# Broker suite: none fails on the reference host (as root and as uid 65534 alike).
BROKER_HOST_REDS=()
CHANNEL_HOST_REDS=(
	# The reference host has no IPv6 (`/proc/net/if_inet6` is absent), so a listener on `::1` cannot
	# be made; these fail as root and as uid 65534 alike.
	'channel/test/join.test.mjs: loopback channel bypasses inherited proxies for ::1'
	'channel/test/join.test.mjs: loopback cli bypasses inherited proxies for ::1'
	# The reference host runs the gates as root, and root passes the file-mode checks these tests
	# expect to refuse. Proven by the same tests passing as uid 65534
	# (the 01-import-source folder of the plan, P1, P5, P6).
	'channel/test/credentials.test.mjs: with sealedAncestors, a user-owned symlink and a non-private leaf are still refused below a sealed ancestor'
	'channel/test/join.test.mjs: F5: a real post-redemption filesystem write failure revokes the new credential and membership'
	'channel/test/join.test.mjs: credential preflight refuses a symlinked ancestor before consuming an invite'
	'channel/test/outbound-scope-rules.test.mjs: the project tree walk and the identity read fail closed'
	'channel/test/project-agent.test.mjs: bind and join write at the git root inside HOME, else the project directory, keeping other settings and the mode'
	'channel/test/scope-hook.test.mjs: D-21 edge inputs: unknown projects and unplaceable paths deny inside a window; no binding means no window'
	'channel/test/scope-hook.test.mjs: scope-window edge cases in process'
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

# G1-G11. `bash -n` and `test -x` on each script. The `test -x` is there because a hook script
# that has lost its execute bit passes every other gate and then fails when the hook runs. It is
# joined to `bash -n` with `&&` so that the rc is the syntax check's when that fails; with `;` a
# syntax error printed `rc=0`. The file list includes this script, which is checked here and in
# G14 by shellcheck, and never executed: there is no recursion.
i=0
for s in "${SCRIPTS[@]}"; do
	i=$((i + 1))
	bash -n "$s" && test -x "$s"
	rc=$?
	[ "$rc" -eq 0 ] || bad "rc=$rc (syntax error or no execute bit)"
	done_case "G$i" "syntax and execute bit: $s"
done

# G14. shellcheck on the same files. Green is rc 0 with no findings.
out=$(shellcheck "${SCRIPTS[@]}" 2>&1)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
[ -z "$out" ] || bad "findings: $(lines "$out" | head -n 1)"
done_case G14 "shellcheck on ${#SCRIPTS[@]} scripts"

# G15-G19. The five tests. The tests create their work directories under `$TMPDIR`. Each test is
# green when its rc is 0, every line but the last is `ok`, and its last line is `PASS n/n`. On
# FAIL, the reason carries the first non-ok line. The tests' own case counts are not fixed here,
# as the old gate did not fix them either.
i=14
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
	for p in plugins/glab . plugins/glab-team; do
		k=$((k + 1))
		"$claude" plugin validate --strict "$p" >"$W/validate.$k" 2>&1
		echo $? >"$W/validate.$k.rc"
	done
	# G46's run, kept out of the loop above so G21-G23 keep their ids.
	"$claude" plugin validate --strict plugins/glab-slim >"$W/validate.slim" 2>&1
	echo $? >"$W/validate.slim.rc"
	"$claude" --plugin-dir ./plugins plugin details glab >"$W/details.glab" 2>"$W/details.glab.err"
	"$claude" --plugin-dir ./plugins plugin details glab-team >"$W/details.glab-team" 2>"$W/details.glab-team.err"
)

# G21-G23. `plugin validate --strict` on the plugin, on the marketplace and on `plugins/glab-team`: its last line is
# `✔ Validation passed`, with rc 0.
i=20 k=0
for p in plugins/glab . plugins/glab-team; do
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

# G24/G25. Skills and Agents are compared as sets, with their count: the CLI lists
# them in directory read order, which is not stable.
# G26. The Hooks line is compared as an exact string. The CLI prints the suffix
# `  (harness-only — no model context cost)` after it on the same line; it prints that suffix, and
# it is expected.
component "$W/details.glab" Skills "${GLAB_SKILLS[@]}"
done_case G24 "glab Skills (${#GLAB_SKILLS[@]})"
component "$W/details.glab" Agents "${GLAB_AGENTS[@]}"
done_case G25 "glab Agents (${#GLAB_AGENTS[@]})"
line=$(command grep -E '^  Hooks ' "$W/details.glab")
[ "$line" = "  $GLAB_HOOKS" ] || bad "line [$line]"
done_case G26 "glab $GLAB_HOOKS"
# G27-G29 were the `memory-sync` plugin's Skills, Agents and Hooks checks and left with it; their
# numbers stay unused because G24-G39 are hard-coded (the loop blocks above number by position).

# G30. Each marketplace entry's name equals the name in the `plugin.json` its source points at.
# Validation does not compare a marketplace entry with the plugin it points at; it passes with a
# wrong name and with a directory that does not exist.
out=$(jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json | while read -r nm src; do echo "$nm = $(jq -r .name "$src/.claude-plugin/plugin.json")"; done)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
[ "$out" = "$(lines "${MARKET[@]}")" ] || bad "got [$(lines "$out" | paste -sd, -)]"
done_case G30 "marketplace names match plugin.json"

# G31. No `user_config` in any `hooks.json`: expected `:0` after each `hooks.json`, then rc 1.
# `grep -c` exits 1 when it counts nothing, and nothing is the green result here. A
# `${user_config.…}` in a hook command passes validation and fails when the hook runs.
# `-H` keeps the `<file>:` prefix, which `grep -c` drops when the glob matches one file,
# so `exp` matches for any number of plugins.
out=$(command grep -cH user_config plugins/*/hooks/hooks.json)
rc=$?
exp=$(for f in plugins/*/hooks/hooks.json; do echo "$f:0"; done)
[ "$out" = "$exp" ] || bad "got [$(lines "$out" | paste -sd, -)]"
[ "$rc" -eq 1 ] || bad "rc=$rc, expected 1"
done_case G31 "no user_config in hooks.json"

# G32, the check of the `not yet confirmed` hedge, left with the `memory-sync` plugin, whose files
# it read; its number stays unused.

# G33. The model of each agent, exactly these lines (compared after sorting both sides: grep
# prints them in glob order), then rc 0. `plugin validate --strict` passes an unknown model value
# and `plugin details` shows none, so nothing else catches a typo.
out=$(command grep -H '^model: ' plugins/*/agents/*.md)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
same_set "$out" "${MODEL_LINES[@]}"
done_case G33 "agent models (${#MODEL_LINES[@]} lines)"

# G34. The skills each agent preloads, exactly these lines (sorted on both sides), none ending
# `MISSING`. A line ends `MISSING` when its entry names no `skills/<name>/SKILL.md` in that
# plugin, when that file's frontmatter has no line `name: <name>` - Claude Code names a plugin
# skill by that line, not by its directory - or when it carries another plugin's prefix.
# `plugin validate --strict` passes an agent's `skills:` entry that names no skill and
# `plugin details` does not show the lists, so nothing else catches a typo.
out=$(for f in plugins/*/agents/*.md; do awk 'FNR==1{n=0} /^---$/{n++; next} n==1 && /^skills:/{s=1; next} n==1 && s && /^  - /{print FILENAME ":" $2; next} {s=0}' "$f"; done | while IFS=: read -r f p s; do r=${f%%/agents/*}; if test -f "$r/skills/$s/SKILL.md" && command grep -qx "name: $s" "$r/skills/$s/SKILL.md" && [ "$p" = "$(jq -r .name "$r/.claude-plugin/plugin.json")" ]; then echo "$f:$p:$s"; else echo "$f:$p:$s MISSING"; fi; done)
same_set "$out" "${SKILL_LINES[@]}"
done_case G34 "agent skills (${#SKILL_LINES[@]} lines)"

# G35. No line, then rc 1. A frontmatter `name:` that carries the plugin prefix passes validation
# and `plugin details`, and nothing else catches it.
out=$(command grep -rH --include='*.md' '^name: .*:' plugins)
rc=$?
[ -z "$out" ] || bad "got [$(lines "$out" | paste -sd, -)]"
[ "$rc" -eq 1 ] || bad "rc=$rc, expected 1"
done_case G35 "no prefixed name: in plugins"

# G36-G37. `bash -n` and `test -x` on the docs mirror's script and test, as G1-G11: a code repo
# runs its copy with `bash`, but the README has it copied with mode 755 from this file.
i=35
for s in "${MIRROR[@]}"; do
	i=$((i + 1))
	bash -n "$s" && test -x "$s"
	rc=$?
	[ "$rc" -eq 0 ] || bad "rc=$rc (syntax error or no execute bit)"
	done_case "G$i" "syntax and execute bit: $s"
done

# G38. shellcheck on the same two files, green as G14. The reason is shellcheck's first line that
# is not blank: its output starts with a blank line, which `head -n 1` printed as an empty reason.
out=$(shellcheck "${MIRROR[@]}" 2>&1)
rc=$?
[ "$rc" -eq 0 ] || bad "rc=$rc"
[ -z "$out" ] || bad "findings: $(lines "$out" | command grep -m 1 '[^[:space:]]')"
done_case G38 "shellcheck on ${#MIRROR[@]} docs-mirror scripts"

# G39. The docs mirror's test, judged as G15-G19.
cmd=(bash "${MIRROR[1]}" "${MIRROR[0]}")
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
done_case G39 "test: ${cmd[1]}" "${last#PASS }"

# G40-G41. The two Node.js suites of `src/glab-team`, run by the source's own pnpm scripts with the
# reporter above appended to the caller's `NODE_OPTIONS`. The `# tests ...` line is the summary,
# every other non-blank line is a failed or cancelled test. The result and its text are those
# described above the host-list arrays [01-D8].
# Each suite runs with a `HOME` and a `CLAUDE_CONFIG_DIR` of its own under the work directory: the
# suites must not read or write the person's `~/.claude` or home, and the CLI's data directory
# falls back to `$HOME/.claude` (`src/glab-team/channel/cli.mjs`). `RUN_CLAUDE_ACCEPTANCE` is
# removed so that a later change to the suites' globs cannot start the acceptance tests
# (`channel/acceptance/*.test.mjs` start a real `claude` and are skipped unless it is `1`); today
# the globs never load them.
# `opts` is the caller's `NODE_OPTIONS`, with every `--test-reporter*` word of theirs removed (and
# the word after one that has no `=`): a second reporter would mix its output into the lines read.
# It is split on blanks, so a quoted value with a blank in it is not kept.
# umask 0002: three `join.test.mjs` cases make their "group-writable" directory with
# `mkdir 0o770`, which umask 0022 turns into 0750, so they fail as root and as uid 65534 alike; that
# is a fixture's assumption and not a host red [01-D3].
# No `timeout`: it would kill pnpm and orphan the runner's children, and the only hangs seen were in
# a tree owned by another uid or under `/tmp`; a hung run is ended by the person, by the PID tree of
# the run [01-D7].
opts=${NODE_OPTIONS:-}
if [[ $opts == *--test-reporter* ]]; then
	read -r -a words <<<"$opts"
	opts='' skipnext=0
	for w in "${words[@]}"; do
		if [ "$skipnext" -eq 1 ]; then skipnext=0; continue; fi
		case $w in
		--test-reporter*)
			case $w in *=*) ;; *) skipnext=1 ;; esac
			continue
			;;
		esac
		opts=${opts:+$opts }$w
	done
fi
joinbar() { awk 'NR > 1 { printf " | " } { printf "%s", $0 }'; }
i=39
for s in broker channel; do
	i=$((i + 1))
	rc=0 summary='' okline=''
	if ! mkdir "$W/$s-home"; then
		bad "cannot make $W/$s-home"
	elif ! mkdir "$W/$s-config"; then
		bad "cannot make $W/$s-config"
	else
		(cd src/glab-team && umask 0002 && env -u RUN_CLAUDE_ACCEPTANCE HOME="$W/$s-home" CLAUDE_CONFIG_DIR="$W/$s-config" NODE_OPTIONS="${opts:+$opts }--test-reporter=\"$W/fail.mjs\"" pnpm -s "$s:test") >"$W/$s.out" 2>"$W/$s.err"
		rc=$?
		summary=$(command grep -m 1 '^# tests ' "$W/$s.out")
		command grep -v -e '^# tests ' -e '^$' "$W/$s.out" | LC_ALL=C sort >"$W/$s.failed"
		if [ "$s" = broker ]; then
			lines "${BROKER_HOST_REDS[@]}" | LC_ALL=C sort >"$W/$s.pinned"
		else
			lines "${CHANNEL_HOST_REDS[@]}" | LC_ALL=C sort >"$W/$s.pinned"
		fi
		unknown=$(LC_ALL=C comm -23 "$W/$s.failed" "$W/$s.pinned" | joinbar)
		known=$(LC_ALL=C comm -12 "$W/$s.failed" "$W/$s.pinned" | joinbar)
		m=$(LC_ALL=C comm -12 "$W/$s.failed" "$W/$s.pinned" | wc -l)
		if [[ $summary =~ ^\#\ tests\ ([0-9]+)\ pass\ ([0-9]+)\ fail\ ([0-9]+)\ cancelled\ ([0-9]+)\ skipped\ ([0-9]+)\ todo\ ([0-9]+)$ ]]; then
			t=${BASH_REMATCH[1]} p=${BASH_REMATCH[2]} f=${BASH_REMATCH[3]} c=${BASH_REMATCH[4]} k=${BASH_REMATCH[5]}
			if [ -n "$unknown" ]; then
				bad "rc=$rc; not in host list [$unknown]; known [$known]"
			elif [ "$m" -eq 0 ] && { [ "$rc" -ne 0 ] || [ "$f" -ne 0 ] || [ "$c" -ne 0 ]; }; then
				bad "rc=$rc; no failure lines; summary [$summary]"
			else
				okline="tests $t pass $p skipped $k; known host reds $m${known:+ [$known]}"
			fi
		else
			bad "no summary line; stderr [$(command grep -m 1 '[^[:space:]]' "$W/$s.err")]"
		fi
	fi
	done_case "G$i" "test: src/glab-team $s:test" "$okline"
done

# G42-G44. The three component lines of `plugin details glab-team`, each compared as an exact
# string, as G26 is. The CLI sorts the Skills names itself (03-F8), so the
# directory read order is not a risk here, unlike G24.
i=41
for l in "${GLAB_TEAM_LINES[@]}"; do
	i=$((i + 1))
	kind=${l%% (*}
	line=$(command grep -E "^  $kind " "$W/details.glab-team")
	[ "$line" = "  $l" ] || bad "line [$line]"
	done_case "G$i" "glab-team $l"
done

# G45. `plugins/glab-team` is the build of `src/glab-team`. The script builds offline
# (`--no-install`: no npm, no claude) into a new directory under `src/glab-team/dist/`, which the
# build accepts and git ignores, and the trap removes it. Three compares, none skipping another:
# every file outside `node_modules/` byte for byte (a changed, missing or added file), the
# execute bits outside it, and `node_modules/` by `<path> <name>@<version>` against
# `src/glab-team/plugin/package-lock.json` (`$W/nm.mjs`).
# What it does not guarantee: a file edited inside a package of the right name and version passes;
# `node_modules/.package-lock.json` and `.bin/` are not read. The full byte compare, `node_modules/`
# included, needs the npm registry and is run once as a command, not as a gate
# [the glab-team plan, M5]. Execute-bit branch and the INT/TERM/HUP trap are not
# exercised by a test: the first is a two-line `find` compare, the second is the mechanism of `W`.
okline=''
if mkdir -p src/glab-team/dist && D45=$(mktemp -d "$PWD/src/glab-team/dist/g45.XXXXXX"); then
	node src/glab-team/scripts/build-plugin.mjs --no-install --out "$D45" >"$W/g45.out" 2>&1
	rc=$?
	if [ "$rc" -ne 0 ]; then
		bad "build rc=$rc [$(command grep -m 1 '[^[:space:]]' "$W/g45.out")]"
	else
		d=$(diff -r --exclude=node_modules plugins/glab-team "$D45" 2>&1 | head -n 1)
		[ -z "$d" ] || bad "differs from the build [$d]"
		a=$(cd plugins/glab-team && find . -path ./node_modules -prune -o -type f -perm -u+x -print | LC_ALL=C sort)
		b=$(cd "$D45" && find . -path ./node_modules -prune -o -type f -perm -u+x -print | LC_ALL=C sort)
		[ "$a" = "$b" ] || bad "execute bits differ"
		nm=$(node "$W/nm.mjs" plugins/glab-team src/glab-team/plugin/package-lock.json 2>&1)
		rc=$?
		if [ "$rc" -ne 0 ]; then
			bad "node_modules [$(lines "$nm" | paste -sd, -)]"
		else
			okline=$nm
		fi
	fi
else
	bad "cannot make a build directory under src/glab-team/dist"
fi
done_case G45 "plugins/glab-team is the build of src/glab-team" "$okline"

# G46. `plugin validate --strict plugins/glab-slim`, green as G21-G23. A hard-coded id appended
# after G45, so no earlier id moves.
if [ -f "$W/validate.slim" ]; then
	last=$(tail -n 1 "$W/validate.slim")
	[ "$last" = '✔ Validation passed' ] || bad "last line [$last]"
	rc=$(cat "$W/validate.slim.rc")
	[ "$rc" = 0 ] || bad "rc=$rc"
else
	bad "the CLI did not run"
fi
done_case G46 "plugin validate --strict plugins/glab-slim"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
