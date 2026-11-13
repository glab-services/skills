# Steps 1b — the session-start hook, its test and the walkthrough (A3–A5)

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
its partner, cut from this file and `steps-1-scripts.md` by the helper `B` — the script against the
test written here, the test against the script written here — so each step is
proven by its own file alone (`evidence.md` E17).

### A3 — `plugins/glab/scripts/manager-bootstrap.sh` reads the level

Replace the file with the text below (C1, C9). It reads the level line of the
repo's `AGENTS.md` — any `glab-level:` line, its value checked afterwards, so a
value that is not built warns (R10) — falling back to the top of the git work
tree when the session's folder has none (F4); prints the product or the
project text, the C1 warning first when there is one; keeps exit 0 on every
path and stdout as C9 says. Every comment of the old header is carried, each
brought up to date (`AGENTS.md` *Comments and recorded incidents are kept*):
what the hook makes a requirement, the irreducible minimum, why the text lives
only here, the 10,000-character cap, and why it always exits 0; the header
adds the level and the contract, and says the stderr copy of the warning is
for debugging only (F5).

- post: `` test -x plugins/glab/scripts/manager-bootstrap.sh && echo ok || echo 'FAIL manager-bootstrap.sh is not executable' ``
- post: `` X steps-1b-scripts.md plugins/glab/scripts/manager-bootstrap.sh ``
- post: `` t=$(mktemp "${TMPDIR:?}/fpl-post.XXXXXX") && B steps-1b-scripts.md tests/manager-bootstrap.test.sh >"$t" && r=$(bash "$t" plugins/glab/scripts/manager-bootstrap.sh 2>&1 | tail -n 1); rm -f "$t"; if [ "$r" = 'PASS 13/13' ]; then echo ok; else echo "FAIL manager-bootstrap.sh against the plan's test: $r"; fi ``

~~~bash file=plugins/glab/scripts/manager-bootstrap.sh
#!/usr/bin/env bash
# SessionStart hook of the glab plugin — makes the glab:bootstrap skill, the manager of the
# session's level, glab:session-rules and glab:security a requirement of every session, in every
# project, including ones with no CLAUDE.md of their own.
# The text below is the irreducible minimum: the rules that must hold even in a session where
# glab:bootstrap never got loaded. A plugin cannot ship global instructions — a CLAUDE.md at a
# plugin root is not loaded — so the copy that used to sit in the global CLAUDE.md lives only
# here. Keep it short: Claude Code caps a hook's additionalContext at 10,000 characters, and each
# of the two texts must stay under that (tests/manager-bootstrap.test.sh B8).
#
# The level. The first line of the repo's AGENTS.md that begins `glab-level:` names it; the value
# is the rest of the line, blanks around it dropped, a trailing CR too. `product` gives the product
# text, `project` or no such line the project text — every repo that predates levels keeps the
# session start it had. Any other value, `delivery` and `support` (reserved for levels not built
# yet) included, gives the project text with a warning above it: the project level never touches a
# live system, so it is the safe fallback. The repo is $CLAUDE_PROJECT_DIR — the folder the session
# started in — or $PWD when that is unset; when that folder has no AGENTS.md, the top of its git
# work tree is tried, so a session started in a subfolder of its repo still finds the line.
#
# The contract: always exits 0 — a bootstrap that can fail a session start is worse than none; on
# stdout one JSON object whose only key is hookSpecificOutput, or the plain text when jq fails;
# messages only on stderr. The warning goes to stderr as well as into the text, for debugging only:
# Claude Code shows no stderr of a hook that exits 0 to the session.

dir=${CLAUDE_PROJECT_DIR:-$PWD}
if [ ! -e "$dir/AGENTS.md" ] && top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) && [ -n "$top" ]; then
	dir=$top
fi
# An unreadable or missing file gives no line, which is the project level.
line=$({ tr -d '\r' <"$dir/AGENTS.md" | grep -m 1 '^glab-level:'; } 2>/dev/null)
# The value as it is shown back in the warning: printable characters only, at most 40.
value=$(printf '%s' "${line#glab-level:}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -cd '[:print:]' | cut -c1-40)
level=project warn=''
case $line in
'') ;;
*)
	case $value in
	product | project) level=$value ;;
	*) warn="glab: level \"$value\" is not built in this version of glab; this session runs at the project level" ;;
	esac
	;;
esac

if [ "$level" = product ]; then
	HEAD=$(cat <<'CTX_EOF'
Level: product — glab-level: product in AGENTS.md.
CTX_EOF
)
	MANAGER=$(cat <<'CTX_EOF'
   - `glab:product-manager` — the operating model of the product level. Each stage of its pipeline (`glab:product-manager` -> *The product pipeline*) is dispatched to its own agent. You manage; you do not implement. Use only the skills its *Your skills — this level only* names: never another level's manager or stage skill.
CTX_EOF
)
else
	HEAD=$(cat <<'CTX_EOF'
Level: project — no other glab-level line in AGENTS.md says otherwise.
CTX_EOF
)
	MANAGER=$(cat <<'CTX_EOF'
   - `glab:manager` — the operating model of the project level. Each stage of its pipeline (`glab:manager` -> *The pipeline*, as far as *Pick the tier* runs it) is dispatched to its own agent. You manage; you do not implement. Use only the skills its *Your skills — this level only* names: never another level's manager or stage skill.
CTX_EOF
)
fi

BEFORE=$(cat <<'CTX_EOF'
Session bootstrap — this is a requirement, not a suggestion:

1. Read `AGENTS.md` at the repo root before anything else this session. If the repo has none, read `CLAUDE.md` instead and say plainly that there is no working agreement. Then read `docs/constants.md` — the decided facts every session on this product builds on. No such file? Say so once and carry on; do not write one.

2. Load the `glab:bootstrap` skill first — it is the full session-start sequence — then load three skills and run the session under all three:
CTX_EOF
)

AFTER=$(cat <<'CTX_EOF'
   - `glab:session-rules` — the rules every level's manager runs under: the context budget, decisions and questions, the effort and the model of every dispatch, the round caps.
   - `glab:security` — evidence and durability discipline. Prove every claim you make about your own work: paste the command and its real output, or write `UNVERIFIED: <claim> — <why>`. Never break its durability rules.

3. Each `glab` agent loads its own rules: `AGENTS.md` in its own first step, and the `glab` skills its role uses from its definition. A dispatch carries only the facts of its task (`glab:session-rules` Rule 0c) and passes the Agent tool's `effort` parameter at the session's level (`glab:session-rules` Rule 0d).

4. Temporary files go where `~/.claude/host.md` says. That file belongs to the machine — temp directory, tool paths, anything true of one host only. Read it with the working agreement, before the first command, name its temp directory in every dispatch message, use unique filenames, and clean up what you create. No `host.md` → say the machine has no host file, then use `$TMPDIR` if it is set and the session's scratchpad directory otherwise — and keep temp files few and small, because that fallback may itself sit on a small `/tmp`. `glab:bootstrap` step 6 explains why this matters.

What skips the pipeline, and what still holds when it does: `glab:session-rules` Rule 1. Who runs a gate before it is reported green: `glab:session-rules` Rule 0b.
CTX_EOF
)

CTX="$HEAD

$BEFORE
$MANAGER
$AFTER"
if [ -n "$warn" ]; then
	CTX="$warn

$CTX"
	printf '%s\n' "$warn" >&2
fi

jq -n --arg c "$CTX" \
	'{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}' 2>/dev/null ||
	printf '%s\n' "$CTX"

exit 0
~~~

### A4 — `tests/manager-bootstrap.test.sh`, the hook's test

Create the file below: the cases B1–B13 of `plan.md` *Tests*. B5's `PATH` is a
folder of symlinks to the tools the hook needs, without `jq`. B11 is skipped
as root, where `chmod 000` does not stop a read; B13 where `git` is missing.

- post: `` test -x tests/manager-bootstrap.test.sh && echo ok || echo 'FAIL manager-bootstrap.test.sh is not executable' ``
- post: `` X steps-1b-scripts.md tests/manager-bootstrap.test.sh ``
- post: `` t=$(mktemp "${TMPDIR:?}/fpl-post.XXXXXX") && B steps-1b-scripts.md plugins/glab/scripts/manager-bootstrap.sh >"$t" && r=$(bash tests/manager-bootstrap.test.sh "$t" 2>&1 | tail -n 1); rm -f "$t"; if [ "$r" = 'PASS 13/13' ]; then echo ok; else echo "FAIL manager-bootstrap.test.sh against the plan's hook: $r"; fi ``

~~~bash file=tests/manager-bootstrap.test.sh
#!/usr/bin/env bash
# Exercises manager-bootstrap.sh, the SessionStart hook, against repos written here under $TMPDIR.
# Every run must keep the hook contract - exit 0, stdout one JSON object whose only key is
# hookSpecificOutput (or the plain text when jq is missing) - and each case checks which level's
# text it printed.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: $(basename "$0") <path to manager-bootstrap.sh>" >&2; exit 2; }
# Absolute, because the runs below start from other directories.
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/manager-bootstrap-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap removes the
# work directory, after giving back the read bit B11 takes away.
trap 'chmod -R u+rwx "$W" 2>/dev/null; rm -rf "$W"' EXIT
cd "$W" || exit 1

pass=0 fail=0 n=0
reason='' # why the current case failed; empty while it holds
OUT='' ERR='' RC=0 TEXT=''
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

PROJECT_LINE='Level: project — no other glab-level line in AGENTS.md says otherwise.'
PRODUCT_LINE='Level: product — glab-level: product in AGENTS.md.'
WARN_DELIVERY='glab: level "delivery" is not built in this version of glab; this session runs at the project level'
# The manager each text loads. The backticks are the text's own Markdown, not a command.
# shellcheck disable=SC2016
PROJECT_MGR='`glab:manager` — the operating model of the project level'
# shellcheck disable=SC2016
PRODUCT_MGR='`glab:product-manager` — the operating model of the product level'

# repo <name> [AGENTS.md text]: a repo folder, with that AGENTS.md when a text is given.
repo() {
	mkdir -p "$W/$1"
	if [ $# -gt 1 ]; then printf '%s\n' "$2" >"$W/$1/AGENTS.md"; fi
	echo "$W/$1"
}
# hook <repo>: runs the hook with CLAUDE_PROJECT_DIR set to the repo; sets OUT, ERR, RC and TEXT, the
# additionalContext. Asserts the contract on every run.
hook() {
	OUT=$(CLAUDE_PROJECT_DIR=$1 bash "$SCRIPT" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
	contract
}
contract() {
	[ "$RC" -eq 0 ] || bad "rc=$RC"
	[ "$(jq -s length <<<"$OUT" 2>/dev/null)" = 1 ] || bad "stdout is not one JSON value"
	jq -e 'keys == ["hookSpecificOutput"] and .hookSpecificOutput.hookEventName == "SessionStart" and (.hookSpecificOutput | keys == ["additionalContext", "hookEventName"])' \
		<<<"$OUT" >/dev/null 2>&1 || bad "stdout is not one SessionStart object: [${OUT:0:120}]"
	TEXT=$(jq -r .hookSpecificOutput.additionalContext <<<"$OUT" 2>/dev/null)
}
# is_project / is_product: the text is that level's, by its first line and the manager it names.
is_project() {
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$PROJECT_LINE" ] || bad "first line [$(printf '%s\n' "$TEXT" | head -n 1)] is not the project line"
	has "$PROJECT_MGR"
	hasnt "$PRODUCT_MGR"
}
is_product() {
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$PRODUCT_LINE" ] || bad "first line is not the product line"
	has "$PRODUCT_MGR"
	hasnt "$PROJECT_MGR"
}
has() { case $TEXT in *"$1"*) ;; *) bad "the text lacks [$1]" ;; esac; }
hasnt() { case $TEXT in *"$1"*) bad "the text holds [$1]" ;; esac; }
no_err() { [ -z "$ERR" ] || bad "stderr not empty: [$ERR]"; }

# B1
hook "$(repo b1)"
is_project
no_err
B1_TEXT=$TEXT
done_case B1 "no AGENTS.md: exit 0, one SessionStart object, the project text"

# B2
hook "$(repo b2 $'# Working agreement\n\nglab-level: product\nglab-shared-store: <store>')"
is_product
has 'glab:session-rules'
no_err
B2_TEXT=$TEXT
done_case B2 "glab-level: product: the product text"

# B3
hook "$(repo b3 $'# Working agreement\nglab-level: project')"
[ "$TEXT" = "$B1_TEXT" ] || bad "the text differs from B1's"
no_err
done_case B3 "glab-level: project: the same text as with no AGENTS.md"

# B4
hook "$(repo b4 'glab-level: delivery')"
[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "$WARN_DELIVERY" ] || bad "the warning is not the first line"
[ "$(printf '%s\n' "$TEXT" | sed -n 3p)" = "$PROJECT_LINE" ] || bad "the project line does not follow the warning"
has "$PROJECT_MGR"
[ "$ERR" = "$WARN_DELIVERY" ] || bad "stderr [$ERR] is not the warning"
done_case B4 "glab-level: delivery: the project text with the warning first, and on stderr"

# B5
mkdir -p "$W/bin"
for t in bash cat cut git grep sed tr; do
	p=$(command -v "$t") && ln -s "$p" "$W/bin/$t"
done
r=$(repo b5 'glab-level: product')
OUT=$(CLAUDE_PROJECT_DIR=$r PATH=$W/bin bash "$SCRIPT" 2>"$W/err")
RC=$?
[ "$RC" -eq 0 ] || bad "rc=$RC"
[ "$OUT" = "$B2_TEXT" ] || bad "stdout is not the plain product text"
[ -z "$(PATH=$W/bin command -v jq)" ] || bad "jq is still on the test PATH"
done_case B5 "a PATH without jq: the plain text, exit 0"

# B6
r=$(repo b6 'glab-level: product')
OUT=$(cd "$r" && env -u CLAUDE_PROJECT_DIR bash "$SCRIPT" 2>"$W/err")
RC=$?
ERR=$(cat "$W/err")
contract
is_product
done_case B6 "CLAUDE_PROJECT_DIR unset: the level read from \$PWD/AGENTS.md"

# B7
hook "$(repo b7 $'# Working agreement\r\nglab-level: product\r')"
is_product
done_case B7 "a CRLF AGENTS.md: the level still read"

# B8
for t in "$B1_TEXT" "$B2_TEXT"; do
	[ "${#t}" -lt 10000 ] || bad "a text is ${#t} characters"
done
hook "$(repo b8 'glab-level: support')"
[ "${#TEXT}" -lt 10000 ] || bad "the text with a warning is ${#TEXT} characters"
done_case B8 "every text, the warning included, is under 10,000 characters"

# B9
hook "$(repo b9 $'glab-level: project\nglab-level: product')"
is_project
done_case B9 "only the first level line counts"

# B10 is judged by no_err in B1-B3 above; it repeats them so its own line says so.
for a in '' 'glab-level: project' 'glab-level: product'; do
	if [ -n "$a" ]; then r=$(repo "b10-$RANDOM" "$a"); else r=$(repo "b10-none"); fi
	hook "$r"
	no_err
done
done_case B10 "stderr is empty for the built levels and for no level"

# B11
r=$(repo b11 'glab-level: product')
if [ "$(id -u)" -eq 0 ]; then
	done_case B11 "an unreadable AGENTS.md: the project text, exit 0 (skipped: running as root)"
else
	chmod 000 "$r/AGENTS.md"
	hook "$r"
	is_project
	done_case B11 "an unreadable AGENTS.md: the project text, exit 0"
fi

# B12
for v in 'Product' 'product2' 'product # note'; do
	hook "$(repo "b12-$RANDOM" "glab-level: $v")"
	[ "$(printf '%s\n' "$TEXT" | head -n 1)" = "glab: level \"$v\" is not built in this version of glab; this session runs at the project level" ] ||
		bad "[$v]: no warning first"
	has "$PROJECT_MGR"
done
done_case B12 "a value that is not built - case, digits, a comment - warns and runs as project"

# B13
r=$(repo b13 'glab-level: product')
if command -v git >/dev/null 2>&1 && git -C "$r" init -q 2>/dev/null; then
	mkdir -p "$r/sub/dir"
	hook "$r/sub/dir"
	is_product
	done_case B13 "a session started in a subfolder of its repo: the level read at the repo's top"
else
	done_case B13 "a session started in a subfolder of its repo: the level read at the repo's top (skipped: no git)"
fi

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
~~~

### A5 — the walkthrough and its fixtures

Create the twelve fixtures and `tests/product-loop.test.sh` below. The
fixtures are a made-up product — a notes app with a sync API, owned by no
real company — with two projects, `notes-api` and `notes-web`, and one rule
that a first plan breaks (logs kept 365 days against `data-retention.md`'s 90).
The walkthrough runs L1–L17 of `plan.md` *Tests* — L16 a plan from a brief
split into sub-plans, reported once for the slug (R2-1); each case says which role
writes what in a live session. With `PRODUCT_LOOP_SHOW=1` it prints the trace
of the loop on stderr — each scene, each command a session runs, each
refusal, the text of every store file written — which X2 shows the user (I11).
Its last post runs it against the plan's texts of both scripts.

- post: `` for f in business-plan.md product-plan.md product-rules/index.md product-rules/data-retention.md product-rules/api-versioning.md brief.md brief-web.md project-plan/master.md project-plan/plan.md reasons/r1-rejected.md reasons/r2-accepted.md reasons/user-accepted.md; do X steps-1b-scripts.md "tests/fixtures/product-loop/$f"; done | sort | uniq -c | command grep -qx ' *12 ok' && echo ok || echo 'FAIL a fixture is missing or differs' ``
- post: `` test -x tests/product-loop.test.sh && echo ok || echo 'FAIL product-loop.test.sh is not executable' ``
- post: `` X steps-1b-scripts.md tests/product-loop.test.sh ``
- post: `` t=$(mktemp "${TMPDIR:?}/fpl-post.XXXXXX") && u=$(mktemp "${TMPDIR:?}/fpl-post.XXXXXX") && B steps-1-scripts.md plugins/glab/scripts/plan-gate.sh >"$t" && B steps-1b-scripts.md plugins/glab/scripts/manager-bootstrap.sh >"$u" && r=$(bash tests/product-loop.test.sh "$t" "$u" 2>/dev/null | tail -n 1); rm -f "$t" "$u"; if [ "$r" = 'PASS 17/17' ]; then echo ok; else echo "FAIL product-loop.test.sh against the plan's scripts: $r"; fi ``

~~~markdown file=tests/fixtures/product-loop/business-plan.md
# Business plan — Notes (a sample product)

A made-up product for the glab product-loop walkthrough; no real company owns it.

Notes is a note-taking app whose notes sync between devices through an API.

- **notes-api** — the sync API: stores notes and serves them to every device.
- **notes-web** — the web client: reads and edits notes through the API.

Constraint: request logs that can hold a user's notes are kept at most 90 days.
~~~

~~~markdown file=tests/fixtures/product-loop/product-plan.md
# Product plan — notes-app

## Business plan

`business-plan.md`, as the user gave it: "Notes is a note-taking app whose notes sync between devices through an API."

## Goals

- **P1** — notes sync between devices through one API.
- **P2** — a web client reads and edits notes.

## Projects

### notes-api

- Goal: P1. Scope: the sync API. Out of scope: any client.
- Product rules: `docs/product-rules/data-retention.md`, `docs/product-rules/api-versioning.md`.
- Seams: notes-web calls it, versioned as `api-versioning.md` says.

### notes-web

- Goal: P2. Scope: the web client. Out of scope: storage.
- Product rules: `docs/product-rules/api-versioning.md`.
- Seams: calls notes-api.

## Rules to add

- `data-retention.md` — how long request logs are kept.
- `api-versioning.md` — how the API is versioned.

## Decisions

- Two projects, not one: the client and the API ship on their own schedules.

## Questions

none
~~~

~~~markdown file=tests/fixtures/product-loop/product-rules/index.md
# Product rules

- data-retention.md — how long request logs are kept
- api-versioning.md — how the API is versioned
~~~

~~~markdown file=tests/fixtures/product-loop/product-rules/data-retention.md
# Data retention

Request logs are kept at most 90 days.

Why: a request log can hold a user's notes, and the business plan keeps them no longer than that.
~~~

~~~markdown file=tests/fixtures/product-loop/product-rules/api-versioning.md
# API versioning

Every endpoint lives under `/v<n>/`; a change that breaks a client gets a new `<n>`.
~~~

~~~markdown file=tests/fixtures/product-loop/brief.md
# Brief — notes-api

## Goal

Notes sync between devices through one API (product goal P1).

## Scope

The sync API: store notes, serve them to every device, log requests.

## Out of scope

Any client.

## Product rules

- `docs/product-rules/data-retention.md`
- `docs/product-rules/api-versioning.md`

## Seams

notes-web calls this API.

## Acceptance

The plan keeps request logs no longer than `data-retention.md` allows, and versions every endpoint.
~~~

~~~markdown file=tests/fixtures/product-loop/brief-web.md
# Brief — notes-web

## Goal

A web client reads and edits notes (product goal P2).

## Scope

The web client, and the request log of its own server.

## Out of scope

Storage: notes-api holds the notes.

## Product rules

- `docs/product-rules/data-retention.md`
- `docs/product-rules/api-versioning.md`

## Seams

Calls notes-api under `/v1/`.

## Acceptance

The plan keeps request logs no longer than `data-retention.md` allows.
~~~

~~~markdown file=tests/fixtures/product-loop/project-plan/master.md
# Master — notes-api-v1

## Request

The brief, taken 2026-11-13:

- brief: briefs/notes-api/brief.md sha256 <brief-sha256>

## Goals

- **G1** — notes sync through one versioned API.
- **G2** — request logs are kept.

## Out of scope

Any client.

## Final check

The API's tests pass, and a request log older than its limit is removed.

## Record

- `docs/specs/api.md`.
~~~

~~~markdown file=tests/fixtures/product-loop/project-plan/plan.md
tier: full — a new stored format, the request log.

# Plan — notes-api-v1

## Decisions

- Logs in one table, removed by a daily job.

### S1 — the request log

Keep request logs 365 days, then remove them in the daily job.

### S2 — the routes

Serve every endpoint under `/v1/`.
~~~

~~~markdown file=tests/fixtures/product-loop/reasons/r1-rejected.md
S1 keeps request logs 365 days; docs/product-rules/data-retention.md allows at most 90.
~~~

~~~markdown file=tests/fixtures/product-loop/reasons/r2-accepted.md
No conflict with docs/product-rules/data-retention.md or docs/product-rules/api-versioning.md.
~~~

~~~markdown file=tests/fixtures/product-loop/reasons/user-accepted.md
user: "accept notes-web as it is; its logs hold no notes"
The user decided at the rejection cap.
~~~

~~~bash file=tests/product-loop.test.sh
#!/usr/bin/env bash
# The product <-> project loop of glab, end to end, without a model: the user's way to see how the
# product skills work before installing anything. It builds a product repo, a project repo and a
# shared store under $TMPDIR, writes from tests/fixtures/product-loop/ what each agent would write
# in a live session - each case says which role writes what - and runs the real plan-gate.sh and
# manager-bootstrap.sh at every point where a live session runs them. It calls no model and writes
# nothing outside its own work directory.
#
#   PRODUCT_LOOP_SHOW=1 bash tests/product-loop.test.sh <plan-gate.sh> <manager-bootstrap.sh>
#
# With PRODUCT_LOOP_SHOW=1 it also prints the trace of the loop on stderr - each case's scene, every
# command a session runs, each refusal, and the text of every store file the case wrote - so stdout
# keeps only the case lines. Send the trace to a file and read it there.
set -uo pipefail
[ -f "${1:-}" ] && [ -f "${2:-}" ] || {
	echo "usage: $(basename "$0") <path to plan-gate.sh> <path to manager-bootstrap.sh>" >&2
	exit 2
}
GATE=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
HOOK=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
FX=$(cd "$(dirname "$0")" && pwd)/fixtures/product-loop
[ -d "$FX" ] || { echo "no fixtures at $FX" >&2; exit 2; }
W=$(mktemp -d "${TMPDIR:?set TMPDIR to the temp directory your host file names}/product-loop-test.XXXXXX") || exit 1
# The test starts no background process, so there is nothing to kill by PID; the trap only removes
# the work directory.
trap 'rm -rf "$W"' EXIT
SHOW=${PRODUCT_LOOP_SHOW:-}
STORE=$W/store PRODUCT=$W/product-repo PROJECT=$W/notes-api-repo
mkdir -p "$STORE" "$PRODUCT" "$PROJECT"
printf '# Working agreement — the product repo\n\nglab-level: product\nglab-shared-store: <store>\n' >"$PRODUCT/AGENTS.md"
printf '# Working agreement — the notes-api repo\n\nglab-shared-store: <store>\n' >"$PROJECT/AGENTS.md"
SLUG=plan/notes-api-v1 BR=briefs/notes-api

pass=0 fail=0 n=0
reason='' # why the current case failed; empty while it holds
OUT='' ERR='' RC=0 SNAP=''
bad() { reason="${reason:+$reason; }$*"; }
say() { [ -z "$SHOW" ] || printf '%s\n' "$*" >&2; }
snap() { (cd "$STORE" && find . -type f -exec cksum {} + | LC_ALL=C sort); }
# scene <id> <who> <what>: the start of a case - its header in the trace, and the store as it was.
scene() {
	SNAP=$(snap)
	say ''
	say "=== $1 · $2"
	say "    $3"
}
# shown <store file>: in the trace, the file's store path and its text.
shown() { say "--- ${1#"$STORE"/}" && [ -z "$SHOW" ] || sed 's/^/    | /' "$1" >&2; }
# show_writes: in the trace, each store file this case wrote or changed that a gate run did not show
# already - the rules, the briefs. A copy folder plan.r<n>/ is the plan the trace showed; it is named
# by the report that wrote it.
show_writes() {
	[ -n "$SHOW" ] || return 0
	local f
	comm -13 <(printf '%s\n' "$SNAP") <(snap) | awk '{ print $3 }' | LC_ALL=C sort | while IFS= read -r f; do
		case $f in
		./briefs/*/plan.r*/* | ./briefs/*/report.r*.md | ./briefs/*/verdict.r*.md) ;;
		*) shown "$STORE/${f#./}" ;;
		esac
	done
}
done_case() { # done_case <id> <name>
	show_writes
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
# gate <args...>: runs plan-gate.sh from the repo whose turn it is ($HERE), as the session there would.
# In the trace the store is <store> and a fixture is named by its path under the fixtures folder;
# a report or verdict the run wrote is shown at once, so the trace reads in the order of the loop.
gate() {
	local a shown_args=''
	for a in "$@"; do
		a=${a//"$STORE"/<store>}
		shown_args="$shown_args ${a#"$FX"/}"
	done
	say "    \$ plan-gate.sh$shown_args"
	OUT=$(cd "$HERE" && bash "$GATE" "$@" 2>"$W/err")
	RC=$?
	ERR=$(cat "$W/err")
	[ -z "$ERR" ] || say "      $ERR"
	case $1:$RC in
	report:0) shown "$OUT" && say "    (and plan.r<n>/ beside it: a byte copy of the plan files it hashed)" ;;
	verdict:0) shown "$OUT" ;;
	*) [ -z "$OUT" ] || say "      ${OUT//"$STORE"/<store>}" ;;
	esac
}
ok_gate() { gate "$@"; [ "$RC" -eq 0 ] || bad "[plan-gate.sh $*] rc=$RC: $ERR"; }
no_gate() { # no_gate <REFUSED line> <args...>
	local line=$1
	shift
	gate "$@"
	[ "$RC" -eq 1 ] && [ "$ERR" = "REFUSED: $line" ] || bad "[plan-gate.sh $*] gave rc=$RC [$ERR], not [REFUSED: $line]"
}
h256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -c1-64; }
# start <repo>: the session start in that repo; prints the context text the hook gives it.
start() { CLAUDE_PROJECT_DIR=$1 bash "$HOOK" 2>/dev/null | jq -r .hookSpecificOutput.additionalContext; }
# audit <project>: stands in for glab:product-analyzer's project plan audit of the latest copy - it
# holds every file of the copy, sub-plans included, to data-retention.md's 90 days - and prints its
# verdict line.
audit() {
	local d k=0 i
	for d in "$STORE/briefs/$1"/plan.r*; do
		i=${d##*/plan.r}
		if [ "$i" -gt "$k" ]; then k=$i; fi
	done
	if grep -rq '365 days' "$STORE/briefs/$1/plan.r$k"; then echo 'CONFLICTS: 1'; else echo 'NO CONFLICT'; fi
}
# project_plan <repo> <project>: glab:planner's plan from the brief, its brief line holding the hash
# of the brief as it read it.
project_plan() {
	mkdir -p "$1/$SLUG"
	sed "s/<brief-sha256>/$(h256 <"$STORE/briefs/$2/brief.md")/; s/notes-api/$2/g" "$FX/project-plan/master.md" >"$1/$SLUG/master.md"
	cp "$FX/project-plan/plan.md" "$1/$SLUG/plan.md"
}

# The manager each text names. The backticks are the text's own Markdown, not a command.
# shellcheck disable=SC2016
PRODUCT_MGR='`glab:product-manager` — the operating model of the product level' PROJECT_MGR='`glab:manager` — the operating model of the project level' ANY_PROJECT_MGR='`glab:manager` — the operating model'

HERE=$PRODUCT
scene L1 'the glab SessionStart hook, in the product repo' 'AGENTS.md says glab-level: product, so the session loads the product manager.'
t=$(start "$PRODUCT")
say "    $(printf '%s\n' "$t" | head -n 1)"
case $t in *"$PRODUCT_MGR"*) ;; *) bad "the product session is not told to load glab:product-manager" ;; esac
case $t in *"$ANY_PROJECT_MGR"*) bad "the product session is told to load glab:manager" ;; esac
done_case L1 "a product repo's session start names glab:product-manager"

scene L2 'the glab SessionStart hook, in the project repo' 'No glab-level line: the project level, today'"'"'s glab:manager.'
t=$(start "$PROJECT")
say "    $(printf '%s\n' "$t" | head -n 1)"
case $t in *"$PROJECT_MGR"*) ;; *) bad "the project session is not told to load glab:manager" ;; esac
done_case L2 "a project repo's session start names glab:manager"

scene L3 'glab:product-planner, then the user, then glab:product-planner' 'The business plan becomes a product plan; the user approves it; the rules it drafted go to the store.'
mkdir -p "$PRODUCT/plan/notes-app" "$STORE/docs/product-rules"
cp "$FX/business-plan.md" "$PRODUCT/business-plan.md"
cp "$FX/product-plan.md" "$PRODUCT/plan/notes-app/product-plan.md"
printf '\n## Approval\n\n- approved by the user, 2026-11-13, in chat: "approved"\n' >>"$PRODUCT/plan/notes-app/product-plan.md"
say "--- wrote plan/notes-app/product-plan.md in the product repo, then its ## Approval line"
[ -z "$SHOW" ] || sed 's/^/    | /' "$PRODUCT/plan/notes-app/product-plan.md" >&2
cp "$FX/product-rules/"*.md "$STORE/docs/product-rules/"
for f in "$STORE/docs/product-rules/"*.md; do
	b=$(basename "$f")
	[ "$b" = index.md ] && continue
	[ "$(wc -c <"$f")" -le 8192 ] || bad "$b is over 8192 bytes"
	[ "$(grep -c "^- $b — " "$STORE/docs/product-rules/index.md")" -eq 1 ] || bad "$b is not on exactly one index line"
done
done_case L3 "the rules and their index in the store, each rule at most 8192 bytes and on one index line"

scene L4 'glab:product-planner, through glab:product-project-brief' 'One brief per project; it names the rule files that apply.'
mkdir -p "$STORE/$BR"
cp "$FX/brief.md" "$STORE/$BR/brief.md"
while IFS= read -r r; do
	[ -f "$STORE/$r" ] || bad "the brief names $r, which is not in the store"
done < <(grep -o 'docs/product-rules/[a-z0-9-]*\.md' "$STORE/$BR/brief.md")
done_case L4 "the brief names rule files that exist"

HERE=$PROJECT
scene L5 'glab:planner in the project session, told "take the brief at <store>/briefs/notes-api/brief.md"' 'The plan quotes the brief with its hash; glab:develop'"'"'s check refuses before any report.'
project_plan "$PROJECT" notes-api
say "--- wrote $SLUG/master.md and plan.md in the project repo"
[ -z "$SHOW" ] || sed 's/^/    | /' "$PROJECT/$SLUG/master.md" "$PROJECT/$SLUG/plan.md" >&2
grep -qE '^- brief: briefs/notes-api/brief\.md sha256 [0-9a-f]{64}$' "$PROJECT/$SLUG/master.md" || bad "no brief line"
no_gate 'no verdict for this brief' check "$SLUG" "$STORE"
done_case L5 "the project plan carries the brief line, and check refuses before any report"

scene L6 'the project manager, Stage 1c, through glab:product-project-plan-report' 'After the approvals the plan is reported to product; the session then waits.'
ok_gate report "$SLUG" "$STORE"
ok_gate digest "$STORE/$BR/plan.r1"
grep -qx "plan-sha256: $OUT" "$STORE/$BR/report.r1.md" || bad "the copies' digest is not the report's"
done_case L6 "report r1, its copies' digest equal to the report's"

scene L7 'the project manager, reporting again too early' 'A second report while r1 waits for its verdict.'
no_gate 'report r1 has no verdict yet' report "$SLUG" "$STORE"
done_case L7 "a second report while r1 waits is refused"

HERE=$PRODUCT
scene L8 'glab:product-analyzer, then the product manager through glab:product-project-plan-verdict' 'The audit holds the copy to the rules the brief names; one conflict, so REJECTED with its reason.'
a=$(audit notes-api)
say "    audit: $a"
[ "$a" = 'CONFLICTS: 1' ] || bad "the audit gave [$a], not CONFLICTS: 1"
ok_gate verdict "$STORE" notes-api REJECTED product-manager "$FX/reasons/r1-rejected.md"
if ! { grep -qx 'verdict: REJECTED' "$STORE/$BR/verdict.r1.md" && grep -q '365 days' "$STORE/$BR/verdict.r1.md"; }; then
	bad "verdict r1 is not REJECTED with its reason"
fi
done_case L8 "the audit finds CONFLICTS: 1, and verdict r1 is REJECTED with its reason"

HERE=$PROJECT
scene L9 'glab:develop in the project session' 'Development may not start on a REJECTED plan.'
no_gate 'the latest verdict r1 is REJECTED' check "$SLUG" "$STORE"
done_case L9 "check refuses after REJECTED"

scene L10 'a new glab:planner amends; the project manager reports r2; the product audits and accepts' 'The round copy is kept; the step now keeps logs 90 days.'
cp "$PROJECT/$SLUG/plan.md" "$PROJECT/$SLUG/plan.r1.md"
sed 's/365 days/90 days/' "$PROJECT/$SLUG/plan.r1.md" >"$PROJECT/$SLUG/plan.md"
say "    the amendment: $(grep 'days' "$PROJECT/$SLUG/plan.md")"
ok_gate report "$SLUG" "$STORE"
HERE=$PRODUCT
a=$(audit notes-api)
say "    audit: $a"
[ "$a" = 'NO CONFLICT' ] || bad "the audit of r2 gave [$a]"
ok_gate verdict "$STORE" notes-api ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
grep -qx 'verdict: ACCEPTED' "$STORE/$BR/verdict.r2.md" || bad "verdict r2 is not ACCEPTED"
done_case L10 "the amended plan, report r2, verdict r2 ACCEPTED"

HERE=$PROJECT
scene L11 'glab:develop in the project session' 'The accepted plan matches its verdict: development may start.'
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r2 '*) ;; *) bad "check printed [$OUT]" ;; esac
done_case L11 "check passes: development may start"

scene L12 'the project manager, recording after the verdict' 'A model line and a round-3 line go to after-verdict.md, outside the hash.'
printf -- '- model: glab:developer opus, for this task — the user'"'"'s instruction: "use opus for the developer"\n- round 3: analyze — high S1 the job does not run\n' >"$PROJECT/$SLUG/after-verdict.md"
ok_gate check "$SLUG" "$STORE"
done_case L12 "bookkeeping in after-verdict.md: check still passes"

scene L13 'the project manager, after a PLAN WRONG amendment of a step' 'An edited step is a changed plan: refused, reported again, accepted again.'
printf '\n### S3 — a health route\n\nServe /v1/health.\n' >>"$PROJECT/$SLUG/plan.md"
no_gate 'the plan changed since verdict r2 accepted it; report again' check "$SLUG" "$STORE"
ok_gate report "$SLUG" "$STORE"
HERE=$PRODUCT
ok_gate verdict "$STORE" notes-api ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
HERE=$PROJECT
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r3 '*) ;; *) bad "check after r3 printed [$OUT]" ;; esac
done_case L13 "plan.md edited after acceptance: check refuses; report r3, verdict r3 ACCEPTED, check passes"

HERE=$PRODUCT
scene L14 'the product manager edits the brief after acceptance' 'A plan answers the brief it read: the project must plan again.'
printf '\nAlso: export notes as Markdown.\n' >>"$STORE/$BR/brief.md"
HERE=$PROJECT
no_gate 'the brief changed since the plan was written; plan again' check "$SLUG" "$STORE"
done_case L14 "the brief edited after acceptance: check refuses"

WEB=$W/notes-web-repo
mkdir -p "$WEB"
printf '# Working agreement — the notes-web repo\n\nglab-shared-store: <store>\n' >"$WEB/AGENTS.md"

HERE=$PRODUCT
scene L15 'a second project, notes-web: two rejections, then the user decides' 'At the cap the product manager can write no verdict; only the user'"'"'s decision, in the user'"'"'s words, is written.'
mkdir -p "$STORE/briefs/notes-web"
cp "$FX/brief-web.md" "$STORE/briefs/notes-web/brief.md"
SLUG=plan/notes-web-v1
project_plan "$WEB" notes-web
for k in 1 2; do
	HERE=$WEB
	[ "$k" -eq 1 ] || printf '\nAmended, round %s.\n' "$k" >>"$WEB/$SLUG/plan.md"
	ok_gate report "$SLUG" "$STORE"
	HERE=$PRODUCT
	ok_gate verdict "$STORE" notes-web REJECTED product-manager "$FX/reasons/r1-rejected.md"
done
HERE=$WEB
printf '\nAmended, round 3.\n' >>"$WEB/$SLUG/plan.md"
ok_gate report "$SLUG" "$STORE"
HERE=$PRODUCT
no_gate 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$STORE" notes-web REJECTED product-manager "$FX/reasons/r1-rejected.md"
no_gate 'two REJECTED verdicts since the last ACCEPTED; the next verdict is by user' verdict "$STORE" notes-web ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
ok_gate verdict "$STORE" notes-web ACCEPTED user "$FX/reasons/user-accepted.md"
grep -qx 'by: user' "$STORE/briefs/notes-web/verdict.r3.md" || bad "verdict r3 is not by user"
HERE=$WEB
ok_gate check "$SLUG" "$STORE"
done_case L15 "a second project: two REJECTED, then product-manager refused either way, the user's ACCEPTED written, check passes"

HERE=$PROJECT
SLUG=plan/notes-api-v2
scene L16 'glab:planner in the notes-api session, the changed brief planned again as two sub-plans' 'The master and every sub-plan are planned, checked and approved before one report covers them all; each sub-plan'"'"'s glab:develop checks that one verdict, and a sub-plan added later is a changed plan.'
project_plan "$PROJECT" notes-api
rm "$PROJECT/$SLUG/plan.md"
printf '# Index — notes-api-v2\n\n- 01-log · goals G2 · depends none · tier full\n- 02-routes · goals G1 · depends 01-log · tier full\n' >"$PROJECT/$SLUG/index.md"
mkdir -p "$PROJECT/$SLUG/01-log" "$PROJECT/$SLUG/02-routes"
sed 's/365 days/90 days/' "$FX/project-plan/plan.md" >"$PROJECT/$SLUG/01-log/plan.md"
cp "$PROJECT/$SLUG/01-log/plan.md" "$PROJECT/$SLUG/02-routes/plan.md"
# 01-log's own plan check took two rounds: its round copy is kept, and is not hashed.
cp "$PROJECT/$SLUG/01-log/plan.md" "$PROJECT/$SLUG/01-log/plan.r1.md"
say "--- wrote $SLUG/master.md, index.md, 01-log/plan.md and 02-routes/plan.md in the project repo"
ok_gate report "$SLUG" "$STORE"
grep -qx 'files: 4' "$STORE/$BR/report.r4.md" || bad "report r4 does not hash the master, the index and both sub-plans"
{ [ -f "$STORE/$BR/plan.r4/01-log/plan.md" ] && [ -f "$STORE/$BR/plan.r4/02-routes/plan.md" ]; } || bad "the copies of r4 lack a sub-plan"
HERE=$PRODUCT
a=$(audit notes-api)
say "    audit: $a"
[ "$a" = 'NO CONFLICT' ] || bad "the audit of r4 gave [$a]"
ok_gate verdict "$STORE" notes-api ACCEPTED product-manager "$FX/reasons/r2-accepted.md"
HERE=$PROJECT
say "    01-log's glab:develop:"
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r4 '*) ;; *) bad "check for 01-log printed [$OUT]" ;; esac
printf 'S1 done\n' >"$PROJECT/$SLUG/01-log/result.md"
say "    01-log built and committed; 02-routes's glab:develop:"
ok_gate check "$SLUG" "$STORE"
case $OUT in 'ACCEPTED r4 '*) ;; *) bad "check for 02-routes printed [$OUT]" ;; esac
mkdir -p "$PROJECT/$SLUG/03-health"
cp "$PROJECT/$SLUG/02-routes/plan.md" "$PROJECT/$SLUG/03-health/plan.md"
say "    a sub-plan 03-health planned after the report:"
no_gate 'the plan changed since verdict r4 accepted it; report again' check "$SLUG" "$STORE"
done_case L16 "a plan from a brief with sub-plans: one report r4 for the slug, both sub-plans checked against verdict r4, a later sub-plan refused"

scene L17 'the store, at the end' 'Only the agreed folders were written, and no temporary file is left.'
others=$(cd "$STORE" && find . -mindepth 1 -maxdepth 1 ! -name docs ! -name briefs)
[ -z "$others" ] || bad "written outside docs/ and briefs/: $others"
left=$(find "$STORE" -name '.plan-gate.*')
[ -z "$left" ] || bad "temporary files left: $left"
say "    $(cd "$STORE" && find . -type f | LC_ALL=C sort | tr '\n' ' ')"
done_case L17 "nothing was written in the store outside docs/ and briefs/"

if [ "$fail" -eq 0 ]; then
	echo "PASS $pass/$n"
else
	echo "FAIL $fail/$n"
	exit 1
fi
~~~
