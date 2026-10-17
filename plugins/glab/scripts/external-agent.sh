#!/usr/bin/env bash
# external-agent.sh — start, continue, list and stop read-only external agents:
# an OpenCode session (today) on a model the user named, working on a sandboxed
# read-only copy of a repository. The glab:external-agents skill is the
# caller's manual, and tests/external-agent.test.sh pins every behaviour here.
#
#   external-agent.sh start --backend <name> --model <id> --cli <path> --brief <file>
#                           [--role general|reviewer] [--label <text>] [--repo <dir>]
#                           [--timeout <seconds>]
#   external-agent.sh send <agent id> --message <file> [--timeout <seconds>]
#   external-agent.sh list
#   external-agent.sh stop <agent id>
#   external-agent.sh check --backend <name> --cli <path>
#
# stdout of start and send, in this order and nothing else:
#   agent: <id> · model: <backend>:<model> · turn: <n> · transcript: <file>
#   reply:          (exit 0 only)
#   | <one line of the model's reply per line, control characters removed>
#   end: <id>       always the last line
# Every line the model wrote starts with "| ", and no line the script writes
# does, so nothing in a reply can pass for a field of the script's.
# stderr  one line `external-agent: <CODE>: <reason>` on every exit 2-11. A
#         signal ends it with 128 + the signal and no line: 129 HUP, 130 INT,
#         143 TERM - the last is a turn that `stop` ended.
# exit    0 OK · 2 USAGE · 3 UNKNOWN BACKEND · 4 UNAVAILABLE · 5 MODEL REFUSED ·
#         6 TIMEOUT · 7 BACKEND ERROR · 8 MALFORMED REPORT · 9 NO ISOLATED NETWORK ·
#         10 UNKNOWN AGENT · 11 BUSY
#
# State: $TMPDIR/glab-external-agents/<id>/ holds agent.json (written by this
# script only), work/ (the copy), data/ (the backend's data directory: its
# session database), transcript.jsonl and transcript.txt (redacted, readable
# by the user until stop), and run/ for the turn in progress, the turn's own
# $HOME included. stop moves it aside as .stopping.<id> and removes that.
#
# Isolation, and why each part is there (plan/feature-opencode-worker/findings-r3.md):
# - The agent never sees the real repository. It gets a copy of the working
#   tree's tracked and untracked-but-not-ignored files, an index equal to the
#   real one, and the tree of the real HEAD as one parentless commit: no other
#   branch, tag, remote or older commit. Ignored files never leave the host.
#   The copy is built with git plumbing and tar only, under a git environment
#   that ignores the user's global and system config and turns off fsmonitor,
#   so no hook, filter, textconv or diff driver runs on the host; then it is
#   compared byte for byte with the real tree. Every path list stays
#   NUL-separated end to end, and a path that is absolute, has a .. component,
#   holds a control character or has a parent directory that is a symlink is
#   refused, not copied: tar would read it from elsewhere, or as other names.
# - The copy is bound read-only, .git included: the agent can change nothing
#   in it. It sees no /home but its own, no /data, no /run, no host /tmp,
#   and no file descriptor of the caller's: all but the turn's own are closed.
#   Every turn gets a new, empty $HOME. Only the backend's data directory,
#   ~/.local/share/opencode (data/, which holds the session database that send
#   continues), is the same from turn to turn: whatever a turn writes anywhere
#   else in $HOME is gone by the next. Its OpenCode config directory,
#   ~/.config/opencode, the only config directory 2.0.31 reads from $HOME, is
#   an empty read-only mount in every turn (findings-r3).
# - Its network is its own namespace, wired to the internet by slirp4netns
#   with host loopback disabled, and with blackhole routes for every private,
#   link-local and reserved range and for each of the host's own addresses: no
#   service on the host or the LAN is reachable, and no host socket is mounted.
#   Name lookups go to slirp4netns's resolver, which asks the host's.
# - Per process: files up to 64 MiB, 4 GiB of data memory; 256 processes in
#   the sandbox; a 256 MiB /tmp. The copy and $HOME are on disk under TMPDIR
#   and are bounded per file, not in total; total memory is not bounded. Of
#   the backend's stdout and of its stderr, at most 16 MiB per turn reach the
#   disk; a turn that writes more is cut there and is exit 7.
# - The backend's key is inside the sandbox, because the CLI needs it, and the
#   model can read it there. It is never on a command line and never printed;
#   it is redacted from everything this script writes or prints.
# The adapter functions are called as "${backend}_<name>" and cleanup() by
# trap, which shellcheck cannot follow; SC2329 would flag each one.
# shellcheck disable=SC2329
set -u -o pipefail
export LC_ALL=C
umask 077
# git and tar take settings from the environment. None of the caller's may
# reach them: a GIT_DIR, GIT_CONFIG_PARAMETERS or TAR_OPTIONS would change
# what is copied or what runs.
while IFS= read -r v; do case $v in GIT_*|TAR_OPTIONS) unset "$v" ;; esac; done < <(compgen -e)
# ip lives in sbin, which a user's PATH may lack.
export PATH="$PATH:/usr/sbin:/sbin"

readonly STATE_DIR_NAME=glab-external-agents
readonly REPORT_START='=== REPORT START ==='
readonly REPORT_END='=== REPORT END ==='
# 3600 s per turn: a review of a large change is well under an hour; past
# that the manager should hear about it rather than wait. --timeout overrides.
readonly DEFAULT_TIMEOUT=3600
# 256 MiB for the sandbox's /tmp: room for a throwaway repo or build, small
# enough that a runaway loop fills it and stops there. It is the sandbox's own
# tmpfs, not the host /tmp and not its quota.
readonly TMP_BYTES=268435456
# 64 MiB, in the 1024-byte blocks bash's `ulimit -f` counts: the largest file
# any sandboxed process may write, the session database included.
readonly FILE_BLOCKS=65536
# 4 GiB of data segment per process, in KiB. opencode 2.0.31 ran a turn at
# 1 GiB and aborted at 256 MiB (findings-r3), so this binds without starving it.
readonly DATA_KIB=4194304
# 256 tasks in the sandbox's user namespace, threads included. opencode 2.0.31
# ran a turn with eight parallel shell children at 128 and aborted at 64.
# The count is the namespace's own: the user's processes outside do not use it.
readonly NPROC=256
# 16 MiB of the backend's stdout, and as much of its stderr, per turn: a turn's
# JSON events are far less, and a backend that floods either stream would
# otherwise fill the disk under TMPDIR. Past it the stream is cut at a line
# boundary, so no part of a line - of the key least of all - reaches the disk
# unredacted, and the turn is exit 7. slirp4netns's log is cut at the same size.
readonly OUT_BYTES=16777216
# Where the backend keeps its data inside the sandbox's $HOME: the one
# directory bound from the agent's state, so that its sessions outlive a turn.
readonly DATA_IN_HOME=.local/share/opencode
# Never routed from the sandbox: this-network, RFC 1918, CGNAT, link-local,
# IETF and documentation ranges, benchmarking, multicast and reserved. The
# slirp4netns network 10.0.2.0/24 is more specific than 10.0.0.0/8 and stays
# reachable, which keeps its resolver (10.0.2.3); its gateway 10.0.2.2, the
# host's loopback, is closed by --disable-host-loopback.
readonly BLACKHOLES='0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 169.254.0.0/16 172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.88.99.0/24 192.168.0.0/16 198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/4 240.0.0.0/4'

# die is not defined yet, so these two say it themselves.
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || { echo 'external-agent: UNAVAILABLE: cannot find its own directory' >&2; exit 4; }
plugin=$(cd "$here/.." && pwd) || { echo 'external-agent: UNAVAILABLE: cannot find its plugin directory' >&2; exit 4; }

die() { # die <exit code> <CODE> <reason>
  printf 'external-agent: %s: %s\n' "$2" "$3" >&2
  exit "$1"
}

# --- state of this invocation, for cleanup -------------------------------------
adir='' run='' started_ok=1 child='' holder='' slirp='' sandbox_pid='' gfd='' xfd='' authd=''
cleanup() {
  [ -n "$gfd" ] && exec {gfd}>&-
  [ -n "$xfd" ] && exec {xfd}>&-
  # Each of these is a process this invocation started; never a name or pattern.
  [ -n "$holder" ] && kill -KILL "$holder" 2>/dev/null
  [ -n "$slirp" ] && kill -TERM "$slirp" 2>/dev/null
  [ -n "$child" ] && kill -KILL "$child" 2>/dev/null
  [ -n "$sandbox_pid" ] && kill -TERM "$sandbox_pid" 2>/dev/null && wait "$sandbox_pid" 2>/dev/null
  [ -n "$slirp" ] && wait "$slirp" 2>/dev/null
  [ -n "$run" ] && [ -d "$run" ] && rm -rf "$run"
  [ -n "$authd" ] && [ -d "$authd" ] && rm -rf "$authd"
  # A start that did not finish leaves nothing: no copy, no data, no transcript.
  if [ "$started_ok" -eq 0 ] && [ -n "$adir" ] && [ -d "$adir" ]; then
    chmod -R u+rwX "$adir" 2>/dev/null; rm -rf "$adir"
  fi
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# --- text from the model is untrusted -------------------------------------------
# Removes C0 controls but tab and newline, DEL, C1, zero-width and
# bidirectional overrides: what a terminal would act on, or what would make
# printed text read differently from its bytes.
readonly JQ_CLEAN='def clean: gsub("[\u0000-\u0008\u000b-\u001f\u007f-\u009f\u200b-\u200f\u2028\u2029\u202a-\u202e\u2066-\u2069]"; "");'
clean() { jq -Rr "$JQ_CLEAN"' clean'; }
# The key is replaced line by line as the stream is written, so no unredacted
# copy reaches the disk, even when this script is killed mid-turn. With a flag
# file, it is also the cap of OUT_BYTES: head bounds what awk can be handed,
# so one endless line cannot fill memory either; awk passes whole lines only
# while they fit, and creates the flag when more came. It then exits, which
# closes the pipe on the writer.
redact_stream() { # redact_stream [<flag file>]
  if [ -n "${1:-}" ]; then head -c "$((OUT_BYTES + 1))"; else cat; fi | K=$secret awk -v cap="${1:+$OUT_BYTES}" -v flag="${1:-}" 'BEGIN {k = ENVIRON["K"]} {
    if (cap != "" && (n += length($0) + 1) > cap + 0) { printf "" >flag; exit }
    s = $0; o = ""
    while (k != "" && (i = index(s, k)) > 0) { o = o substr(s, 1, i - 1) "<redacted>"; s = substr(s, i + length(k)) }
    print o s; fflush() }'
}

# --- git on the host ------------------------------------------------------------
# Reads the real repository without the user's global or system config, with
# fsmonitor and the untracked cache off (fsmonitor is a program git would run),
# and without optional locks, so not even the index is rewritten.
hostgit() {
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_OPTIONAL_LOCKS=0 GIT_TERMINAL_PROMPT=0 \
    git -c core.fsmonitor=false -c core.untrackedCache=false -c core.hooksPath=/dev/null "$@"
}

# --- backend adapters -----------------------------------------------------------
# Everything that depends on the backend is in this section, one function set
# per backend: <b>_models, <b>_secret, <b>_secret_var, <b>_env, <b>_argv,
# <b>_session, <b>_text, <b>_error, <b>_render. A new backend is a new set plus
# one line in known_backend and a stub in the test.

# One line per allowed model: <model id> <profile> <last day it may be used, or ->.
# Source: https://opencode.ai/docs/go/ read 2026-10-16. Every line is a model
# the page lists with Training "Not used" and Retention "0 days". DeepSeek's
# zero-retention agreement "is renewed monthly" and is "valid through October
# 31, 2026", hence its end date: past it, re-read the page and move the date.
# A model outside this list is refused (exit 5); allowing one is the user's
# call, because it decides where their code is sent. Grok 4.7 is left out on
# purpose: the page gives it 30 days' retention, and the user refused it on
# 2026-10-16 (plan/feature-opencode-worker/questions.md, Q1).
opencode_models() {
  cat <<'EOF'
opencode-go/kimi-k3 kimi -
opencode-go/kimi-k2.7-code kimi -
opencode-go/glm-5.3 glm -
opencode-go/glm-5.3-flash glm -
opencode-go/glm-5.2 glm -
opencode-go/deepseek-v4-pro deepseek-pro 2026-10-31
opencode-go/deepseek-v4.1-flash deepseek-flash 2026-10-31
EOF
}

# Prints the stored OpenCode Go key, for the caller to hold in a variable.
# opencode 2.0.31 keeps credentials in its database and prints them with
# `auth export`; it no longer reads auth.json or OPENCODE_AUTH_CONTENT, which
# 1.19.3 did (findings-r3). --standalone: a private server that ends with the
# command, instead of starting the user's background service. stdin is
# /dev/null because `opencode` reads a non-terminal stdin to its end. It runs
# from a new empty directory of this script's, with the switches every turn
# has, so no opencode.json or .opencode/ in the caller's working directory can
# apply to it on the host.
opencode_secret() { # opencode_secret <cli> <empty directory to run it from>
  local out sw
  mapfile -t sw < <(opencode_switches)
  out=$(cd "$2" && env -i PATH="$PATH" HOME="$HOME" \
    ${XDG_DATA_HOME:+XDG_DATA_HOME="$XDG_DATA_HOME"} ${XDG_CONFIG_HOME:+XDG_CONFIG_HOME="$XDG_CONFIG_HOME"} \
    ${XDG_STATE_HOME:+XDG_STATE_HOME="$XDG_STATE_HOME"} ${XDG_CACHE_HOME:+XDG_CACHE_HOME="$XDG_CACHE_HOME"} \
    "${sw[@]}" timeout 60 "$1" auth export opencode-go --standalone </dev/null 2>/dev/null) || return 1
  jq -er '[.[] | select(.integrationID == "opencode-go" and .active == true and .value.type == "key")
           | .value.key | select(type == "string")] | first // empty' <<<"$out" 2>/dev/null
}
# The variable the CLI reads its key from. It also unlocks OpenCode's paid
# provider, which the policy in opencode_env forbids (findings-r3).
opencode_secret_var() { echo OPENCODE_API_KEY; }

# The permission set is the second layer, not the first: the sandbox is what
# contains the agent. Native 2.0.31 keys: "permissions" is a list of rules,
# the shell tool's action is "shell", and "policies" decides which provider
# may be used: only OpenCode Go, so a paid model cannot be reached even by id.
# Every rule is allow or deny, because a non-interactive run rejects every ask.
# OPENCODE_DISABLE_PROJECT_CONFIG stops an opencode.json or .opencode/ in the
# copy from merging keys into this agent (findings P4, re-proven on 2.0.31).
opencode_env() {
  printf 'OPENCODE_CONFIG_CONTENT=%s\n' "$(jq -cn '{
    "$schema": "https://opencode.ai/config.json", update: "disable", share: "disabled",
    policies: [{action: "provider.use", resource: "*", effect: "deny"},
               {action: "provider.use", resource: "opencode-go", effect: "allow"}],
    permissions: [{action: "*", resource: "*", effect: "deny"}],
    agents: {"glab-agent": {mode: "primary", description: "glab external agent, read-only",
      permissions: [{action: "*", resource: "*", effect: "deny"},
        {action: "read", resource: "*", effect: "allow"}, {action: "glob", resource: "*", effect: "allow"},
        {action: "grep", resource: "*", effect: "allow"}, {action: "shell", resource: "*", effect: "allow"},
        {action: "external_directory", resource: "*", effect: "deny"},
        {action: "external_directory", resource: "/tmp/*", effect: "allow"}]}}}')"
  opencode_switches
}
# The switches of every OpenCode process this script starts, in the sandbox and
# on the host: no project config, no Claude Code files or skills, no update, no
# model list fetch, no file watcher.
opencode_switches() {
  printf '%s\n' OPENCODE_DISABLE_PROJECT_CONFIG=1 OPENCODE_DISABLE_CLAUDE_CODE=1 \
    OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1 OPENCODE_DISABLE_AUTOUPDATE=1 OPENCODE_DISABLE_MODELS_FETCH=1 \
    OPENCODE_DISABLE_FILEWATCHER=1
}

# --standalone: without it, `run` looks for or starts a background service.
# --thinking: the transcript then holds the model's reasoning where it sends any.
# --session continues the recorded session; an id it does not know would be
# created, so only the id read back from the first turn is ever passed.
opencode_argv() { # opencode_argv <cli in sandbox> <model> <session or -> <title> <file in sandbox>
  printf '%s\0' "$1" run "Read the attached file and follow it. It is the whole of your next instruction." \
    --standalone --format json --thinking -m "$2" --agent glab-agent
  if [ "$3" = - ]; then printf '%s\0' --title "$4"; else printf '%s\0' --session "$3"; fi
  printf '%s\0' -f "$5"
}
# Every event carries the session id; it is checked for form, because the
# stream is written inside the sandbox and is as untrusted as the model.
opencode_session() { jq -r '.sessionID // empty' "$1" 2>/dev/null | command grep -m1 -E '^ses_[A-Za-z0-9]{1,64}$'; }
opencode_text() { jq -r 'select(.type == "text") | .part.text // empty' "$1" 2>/dev/null; }
# 2.0.31: {"type":"error","error":{"type":"provider.transport","message":".."}};
# 1.19.3 had error.name and error.data.message instead.
opencode_error() {
  jq -r 'select(.type == "error") | (.error.type // "error") + ": " + (.error.message // "")' "$1" 2>/dev/null \
    | head -n 1 | cut -c1-300 | clean
}
opencode_render() { # opencode_render <turn jsonl> — the readable transcript of one turn
  jq -r "$JQ_CLEAN"'
    if .type == "reasoning" then "thinking:\n" + (.part.text // "" | clean)
    elif .type == "text" then "says:\n" + (.part.text // "" | clean)
    elif .type == "tool_use" then "tool " + (.part.tool // "?" | clean) + " (" + (.part.state.status // "?" | clean) + "): "
      + (.part.state.input | tostring | .[0:500] | clean) + "\n"
      + ((.part.state.output // .part.state.error // "") | tostring | .[0:2000] | clean)
    elif .type == "error" then "error: " + ((.error.type // "") + " " + (.error.message // "") | clean)
    else empty end' "$1" 2>/dev/null
}

known_backend() { case $1 in opencode) return 0 ;; *) return 1 ;; esac; }

# --- common checks --------------------------------------------------------------
need_tmpdir() {
  # TMPDIR is required, not defaulted: on some hosts /tmp is a small shared
  # tmpfs, and the host file names the temp directory to use instead.
  [ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ] || die 2 USAGE "TMPDIR must name an existing directory"
  root=$TMPDIR/$STATE_DIR_NAME
  if [ ! -e "$root" ]; then mkdir -m 700 "$root" || die 4 UNAVAILABLE "cannot create $root"; fi
  [ -d "$root" ] && [ ! -L "$root" ] && [ -O "$root" ] || die 4 UNAVAILABLE "$root is not a directory owned by you"
}
agent_dir() { # agent_dir <id> — the only way an id becomes a path
  [[ $1 =~ ^ea-[0-9a-f]{16}$ ]] || die 2 USAGE "not an agent id: $(printf '%s' "$1" | head -c 40 | clean)"
  adir=$root/$1
  [ -f "$adir/agent.json" ] || die 10 'UNKNOWN AGENT' "no agent $1"
}
meta() { jq -r --arg k "$1" '.[$k] // empty' "$adir/agent.json"; }
# The filters are jq programs whose $names are jq variables, hence the single
# quotes at every call (shellcheck SC2016 is disabled at each).
set_meta() { # set_meta <jq filter> [jq args...]
  local f=$1; shift
  { jq "$@" "$f" "$adir/agent.json" >"$adir/agent.json.tmp" && mv "$adir/agent.json.tmp" "$adir/agent.json"; } \
    || die 4 UNAVAILABLE "cannot update $adir/agent.json"
}
model_allowed() { # model_allowed <backend> <model> — sets profile
  local line until_day today
  line=$("${1}_models" | awk -v m="$2" '$1 == m')
  [ -n "$line" ] || die 5 'MODEL REFUSED' "$2 is not allowed; allowed: $("${1}_models" | awk '{print $1}' | paste -sd' ' -)"
  read -r _ profile until_day <<<"$line"
  # The clock decides, in UTC. The test crosses an end date with a `date` stub
  # first on PATH; there is no variable that overrides it.
  today=$(date -u +%F) || die 4 UNAVAILABLE "date failed"
  if [ "$until_day" != - ] && [[ $today > $until_day ]]; then
    die 5 'MODEL REFUSED' "$2 was allowed until $until_day; re-check its data policy before moving the date"
  fi
}
cli_ok() { [ -f "$1" ] && [ -x "$1" ]; }
read_secret() { # read_secret <backend> <cli> <directory to create, empty, and run the lookup from>
  authd=$3
  { rm -rf "$authd" && mkdir -m 700 "$authd"; } || die 4 UNAVAILABLE "cannot create $authd"
  secret=$("${1}_secret" "$2" "$authd") || secret=''
  rm -rf "$authd"; authd=''
  # A key with whitespace could not be redacted reliably, and an empty one not at all.
  [[ $secret =~ ^[[:graph:]]{8,}$ ]] || { secret=''; die 4 UNAVAILABLE "no $1 key stored; run \`$2 auth login\` for OpenCode Go"; }
}
net_tools() {
  local t
  for t in slirp4netns nsenter setpriv lsns ip bwrap timeout flock; do
    command -v "$t" >/dev/null || die 9 'NO ISOLATED NETWORK' "$t not found; see the README's Requirements"
  done
}

# --- the copy -------------------------------------------------------------------
# A parent directory that is a symlink would make tar read the file through
# it, from wherever it points: outside the repository, perhaps outside the
# user's home. Such a path is refused, not followed. Each directory is looked
# at once; notlink remembers the ones that are not symlinks.
declare -A notlink=()
link_parent() { # link_parent <top> <path>; true, with lp set, when a parent of <path> is a symlink
  local p=$2
  while [[ $p == */* ]]; do
    p=${p%/*}
    [ -n "${notlink[$p]:-}" ] && continue
    if [ -L "$1/$p" ]; then lp=$p; return 0; fi
    notlink[$p]=1
  done
  return 1
}
# A path from git reaches the tar list only if it can mean nothing but itself:
# not absolute, no .. component, no control character - a newline or a tab
# would split it into other names in any line-based tool - and no parent that
# is a symlink. It is shown with printf %q, so the reason itself is one line.
safe_path() { # safe_path <top> <path>; fails with why set when <path> is refused
  local shown
  shown=$(printf '%q' "$2" | head -c 200)
  case $2 in
    '' | /*) why="refused the path $shown: it is empty or absolute"; return 1 ;;
    .. | ../* | */.. | */../*) why="refused the path $shown: it has a .. component"; return 1 ;;
    *[[:cntrl:]]*) why="refused the path $shown: it holds a control character"; return 1 ;;
  esac
  if link_parent "$1" "$2"; then why="$(printf '%q' "$lp" | head -c 200) is a symlink, and the copy does not follow one"; return 1; fi
}
copy_repo() { # copy_repo <top> <work>; sets head_short branch
  local top=$1 work=$2 tree head commit list=$run/files idx=$run/index xf xrc lp='' rec meta mode obj f
  # hostgit reads no global config, but the user's own ignore rules decide
  # what never leaves this host: their core.excludesFile is the one setting
  # carried over, read as a value (reading config runs nothing). Unset, git
  # still applies its default, $XDG_CONFIG_HOME/git/ignore.
  xf=$(git -C "$top" config --path --get core.excludesFile); xrc=$?
  [ "$xrc" -le 1 ] || { why="cannot read core.excludesFile"; return 1; }
  [ -z "$xf" ] || [ -r "$xf" ] || { why="core.excludesFile $xf is not readable"; return 1; }
  head=$(hostgit -C "$top" rev-parse -q --verify HEAD) || { why="the repository has no commit"; return 1; }
  tree=$(hostgit -C "$top" rev-parse "HEAD^{tree}") || { why="rev-parse HEAD^{tree} failed"; return 1; }
  head_short=${head:0:12}
  hostgit -C "$top" ls-files -s -z >"$idx" || { why="ls-files -s failed"; return 1; }
  hostgit ${xf:+-c "core.excludesFile=$xf"} -C "$top" ls-files -z -o --exclude-standard >"$run/untracked" \
    || { why="ls-files -o failed"; return 1; }
  # Every list below is NUL-separated, read record by record from a file, so
  # no name is ever split and a refusal can set why and return. An index
  # record is "<mode> <object> <stage>\t<path>"; the path is all after the
  # first tab, the mode and object the first two words before it.
  : >"$run/files.all"; : >"$run/blobs"; : >"$run/gitlinks"
  while IFS= read -r -d '' rec; do
    meta=${rec%%$'\t'*} f=${rec#*$'\t'}
    mode=${meta%% *} obj=${meta#* }; obj=${obj%% *}
    safe_path "$top" "$f" || return 1
    # A gitlink (160000) is a commit of another repository, not here to copy:
    # it gets an empty directory, which git reads as a submodule not checked out.
    if [ "$mode" = 160000 ]; then printf '%s\0' "$f" >>"$run/gitlinks"; continue; fi
    printf '%s\n' "$obj" >>"$run/blobs"
    # Tracked files still present in the working tree are copied as bytes.
    if [ -e "$top/$f" ] || [ -L "$top/$f" ]; then printf '%s\0' "$f" >>"$run/files.all"; fi
  done <"$idx"
  # Untracked files that are not ignored. An entry ending in / is a nested
  # repository, its own history, and is not copied.
  while IFS= read -r -d '' f; do
    case $f in */) continue ;; esac
    safe_path "$top" "$f" || return 1
    printf '%s\0' "$f" >>"$run/files.all"
  done <"$run/untracked"
  # A path in more than one stage of a merge is copied once.
  sort -z -u "$run/files.all" >"$list" || { why="listing the files failed"; return 1; }
  # Objects: HEAD's tree and every blob the index names, as bare ids.
  { hostgit -C "$top" rev-list --objects --no-object-names "$tree" && cat "$run/blobs"; } \
    | sort -u | hostgit -C "$top" pack-objects -q --stdout >"$run/objects.pack" \
    || { why="pack-objects failed"; return 1; }
  hostgit init -q --template= "$work" || { why="git init failed"; return 1; }
  hostgit -C "$work" unpack-objects -q <"$run/objects.pack" || { why="unpack-objects failed"; return 1; }
  # gpgsign off: a user who signs every commit would otherwise be asked to sign
  # this one. commit-tree runs no hook.
  commit=$(hostgit -C "$work" -c user.name=external-agent -c user.email=external-agent@invalid -c commit.gpgsign=false \
    commit-tree -m 'HEAD of the real repository, copied by external-agent.sh' "$tree") || { why="commit-tree failed"; return 1; }
  if branch=$(hostgit -C "$top" symbolic-ref -q HEAD); then
    { hostgit -C "$work" update-ref "$branch" "$commit" && hostgit -C "$work" symbolic-ref HEAD "$branch"; } \
      || { why="setting the branch failed"; return 1; }
  else
    branch=''
    hostgit -C "$work" update-ref --no-deref HEAD "$commit" || { why="setting a detached HEAD failed"; return 1; }
  fi
  hostgit -C "$work" update-index -z --index-info <"$idx" || { why="update-index failed"; return 1; }
  while IFS= read -r -d '' f; do
    mkdir -p "$work/$f" || { why="cannot create the directory of the gitlink $(printf '%q' "$f" | head -c 200)"; return 1; }
  done <"$run/gitlinks"
  tar -C "$top" --null --no-recursion -T "$list" -cf - | tar -C "$work" -xpf - \
    || { why="copying the working tree failed"; return 1; }
  verify_copy "$top" "$work" "$tree"
}
# The copy must equal the real tree: the same file names, bytes, modes and
# link targets (an archive of each, mtimes and owners fixed), the same index,
# and HEAD's tree. A tree that changed while it was copied fails here too.
verify_copy() { # verify_copy <top> <work> <tree>
  local a b
  a=$(tar -C "$1" --null --no-recursion -T "$run/files" --mtime=@0 --owner=0 --group=0 --numeric-owner -cf - | sha256sum) \
    || { why="archiving the real tree failed"; return 1; }
  # A file missing from the copy fails this archive: that is a difference too.
  b=$(tar -C "$2" --null --no-recursion -T "$run/files" --mtime=@0 --owner=0 --group=0 --numeric-owner -cf - 2>/dev/null | sha256sum) \
    || b=unreadable
  [ "$a" = "$b" ] || { why="the copy's files differ from the working tree; was it changing?"; return 1; }
  { a=$(hostgit -C "$1" ls-files -s -z | sha256sum) && b=$(hostgit -C "$2" ls-files -s -z | sha256sum); } \
    || { why="listing an index failed"; return 1; }
  [ "$a" = "$b" ] || { why="the copy's index differs from the real one; was it changing?"; return 1; }
  [ "$(hostgit -C "$2" rev-parse 'HEAD^{tree}')" = "$3" ] || { why="the copy's HEAD tree differs"; return 1; }
}

# --- the prompt -----------------------------------------------------------------
body() { awk 'NR == 1 && /^---$/ {fm = 1; next} fm && /^---$/ {fm = 0; next} !fm' "$1"; }
section() { awk -v h="$2" 'index($0, h) == 1 {on = 1; next} on && /^## / {on = 0} on' "$1"; }
report_section() { awk '/^## Report/ {on = 1} on && /^## / && !/^## Report/ {on = 0} on' "$1"; }
first_prompt() { # first_prompt <role> <profile> <brief>
  local profiles=$plugin/skills/external-agents/profiles
  section "$profiles/default.md" '## Before the contract'
  [ "$2" != default ] && section "$profiles/$2.md" '## Before the contract'
  cat <<'EOF'

# Where you are working

- /work is a read-only copy of the repository: its tracked files, its
  untracked files that are not ignored, its index, and its current commit
  with no history. You cannot change anything in it, and you are not asked to.
- Your scratch directory is /tmp. There is no other home directory, and no
  access to any other repository or credential.
- You have the internet, and nothing on the machine you run on or its local
  network. You have no web tool: do not try to fetch pages.
- Read /work/AGENTS.md before anything else: it is the repository's working
  agreement. If there is none, read /work/CLAUDE.md and say in your answer
  that the repository has no working agreement.

EOF
  if [ "$1" = reviewer ]; then
    printf '# Your role contract\n\n'; body "$plugin/agents/reviewer.md"
    printf '\n# The skills you carry\n\n'
    body "$plugin/skills/security/SKILL.md"; printf '\n'; body "$plugin/skills/comments/SKILL.md"
    printf '\n# Your dispatch\n\n'
  else
    # The same two skills every internal dispatch carries (glab:manager Rule 0c).
    printf '# The rules you carry\n\n'
    body "$plugin/skills/security/SKILL.md"; printf '\n'; body "$plugin/skills/comments/SKILL.md"
    printf '\n# Your task\n\n'
  fi
  cat "$3"; printf '\n'
  # A heading of its own, so that the self-check is not read as part of the task.
  printf '\n# Before you answer\n\n'
  section "$profiles/default.md" '## After the contract'
  [ "$2" != default ] && section "$profiles/$2.md" '## After the contract'
  if [ "$1" = reviewer ]; then reviewer_tail; fi
}
# finish_turn checks the block line by line from the left edge: the verdict
# line whole, and `^rule: ` for each finding. The Report section below indents
# its finding template four spaces and quotes the verdicts in backticks, so a
# reviewer that copied it as shown would be exit 8; the sentence after the two
# lines says so before that section is shown.
reviewer_tail() {
  printf '\n# Your final message\n\nEnd your final message with your report, and put nothing after it: the block your contract'"'"'s Report section asks for, filled in, between these two lines exactly:\n\n%s\n<the report>\n%s\n\nInside the block, every line starts at the left edge, with no indent, even where the Report section below shows one. The verdict line and each rule: line carry no backticks, and the verdict line stands alone, with nothing else on it.\n\nYour contract'"'"'s Report section, again:\n\n' "$REPORT_START" "$REPORT_END"
  report_section "$plugin/agents/reviewer.md"
}

# --- one turn -------------------------------------------------------------------
# The sandbox. Prints bwrap's arguments, NUL-separated.
sandbox_args() { # sandbox_args <cli>
  printf '%s\0' --unshare-all --die-with-parent --new-session \
    --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin \
    --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 --ro-bind /etc /etc \
    --ro-bind "$run/resolv.conf" "$(readlink -f /etc/resolv.conf)" \
    --proc /proc --dev /dev \
    --bind "$run/home" /home/worker --bind "$adir/data" "/home/worker/$DATA_IN_HOME" \
    --ro-bind "$run/empty" /home/worker/.config/opencode \
    --size "$TMP_BYTES" --tmpfs /tmp \
    --ro-bind "$1" /opt/glab/backend --ro-bind "$run/message.md" /opt/glab/message.md \
    --ro-bind "$adir/work" /work --chdir /work --info-fd 5
}
# Runs inside the sandbox before the backend: sets the limits, says it is
# there (the namespaces are then complete), and waits until the network is
# wired. If this script dies first, the read sees end-of-file and the
# sandbox ends without starting the backend.
# shellcheck disable=SC2016
readonly INNER='ulimit -f "$1" && ulimit -u "$2" && ulimit -d "$3" || exit 120
echo ready >&3 || exit 121
exec 3>&-
read -r _ <&4 || exit 122
exec 4<&-
shift 3
exec "$@" </dev/null'
ns_inode() { readlink "/proc/$2/ns/$1" | tr -dc '0-9'; }
wire_network() {
  local owner mode hu
  child=$(jq -r '."child-pid" // empty' "$run/info" 2>/dev/null)
  [[ $child =~ ^[0-9]+$ ]] || die 9 'NO ISOLATED NETWORK' "bwrap reported no sandbox pid"
  owner=$(lsns -t net -n -o NS,ONS | awk -v n="$(ns_inode net "$child")" '$1 == n {print $2}')
  [ -n "$owner" ] || die 9 'NO ISOLATED NETWORK' "cannot find the owner of the sandbox's network namespace"
  # bwrap 0.11.1 here puts the network namespace in an outer user namespace and
  # the sandbox in an inner one (findings-r3), so slirp4netns needs a process in
  # the owner: the sandbox's own user namespace, or its parent. A holder joins
  # the candidate, is checked against the owner, and lives only until wired.
  for mode in -U --user-parent; do
    nsenter -t "$child" "$mode" --preserve-credentials setpriv --pdeathsig KILL -- sleep 60 \
      </dev/null >/dev/null 2>&1 {gfd}>&- {lk}>&- &
    holder=$!
    for _ in $(seq 50); do
      hu=$(ns_inode user "$holder")
      [ -n "$hu" ] && [ "$hu" != "$(ns_inode user $$)" ] && break
      sleep 0.1
    done
    [ "$hu" = "$owner" ] && break
    kill -KILL "$holder" 2>/dev/null; wait "$holder" 2>/dev/null; holder=''
  done
  [ -n "$holder" ] || die 9 'NO ISOLATED NETWORK' "cannot join the owner of the sandbox's network namespace"
  mkfifo "$run/slirp.exit" || die 9 'NO ISOLATED NETWORK' "mkfifo failed"
  # Its log goes through head, so that slirp4netns cannot fill the disk with
  # it. The filter is opened before the exit FIFO below, so it never holds that
  # FIFO, and it closes the go FIFO and the lock.
  local sfd spid
  exec {sfd}> >(exec head -c "$OUT_BYTES" >"$run/slirp.log" {gfd}>&- {lk}>&-); spid=$!
  # slirp4netns exits when every writer of this FIFO is gone, which is when
  # this script is, however it ends.
  exec {xfd}<>"$run/slirp.exit"
  slirp4netns --configure --mtu=65520 --disable-host-loopback --enable-seccomp \
    --userns-path="/proc/$holder/ns/user" --netns-type=path --ready-fd=7 --exit-fd=8 \
    "/proc/$child/ns/net" tap0 7>"$run/slirp.ready" 8<"$run/slirp.exit" </dev/null >&"$sfd" 2>&1 {sfd}>&- {gfd}>&- {xfd}>&- {lk}>&- &
  slirp=$!
  exec {sfd}>&-
  for _ in $(seq 100); do [ -s "$run/slirp.ready" ] && break; kill -0 "$slirp" 2>/dev/null || break; sleep 0.1; done
  if [ "$(cat "$run/slirp.ready" 2>/dev/null)" != 1 ]; then
    # slirp4netns ended first, so that its log is complete when it is read.
    kill -TERM "$slirp" 2>/dev/null; wait "$slirp" 2>/dev/null; slirp=''; wait "$spid" 2>/dev/null
    die 9 'NO ISOLATED NETWORK' "slirp4netns did not start: $(tail -n 1 "$run/slirp.log" | head -c 300 | clean)"
  fi
  for r in $BLACKHOLES $(ip -4 -o addr show | awk '{split($4, a, "/"); if (a[1] !~ /^127\./) print a[1] "/32"}'); do
    nsenter --user="/proc/$holder/ns/user" --net="/proc/$child/ns/net" --preserve-credentials ip route add blackhole "$r" \
      </dev/null >/dev/null 2>&1 || die 9 'NO ISOLATED NETWORK' "cannot add the blackhole route $r"
  done
  kill -KILL "$holder" 2>/dev/null; wait "$holder" 2>/dev/null; holder=''
}
run_turn() { # run_turn <session or -> <title>; sets rc, turn
  local cli backend model sb argv benv rfd line jfd efd jpid epid
  cli=$(meta cli) backend=$(meta backend) model=$(meta model)
  cli_ok "$cli" || die 4 UNAVAILABLE "the backend CLI $cli is gone"
  # run/ is new for every turn, and so is the $HOME made in it: nothing a turn
  # writes there is left for the next, and only data/ is bound back in.
  { printf 'nameserver 10.0.2.3\n' >"$run/resolv.conf" && mkfifo "$run/ready" "$run/go" && mkdir "$run/empty" "$run/home"; } \
    || die 4 UNAVAILABLE "cannot prepare $run"
  mapfile -d '' sb < <(sandbox_args "$cli")
  mapfile -d '' argv < <("${backend}_argv" /opt/glab/backend "$model" "$1" "$2" /opt/glab/message.md)
  mapfile -t benv < <("${backend}_env")
  turn=$(( $(meta turns) + 1 ))
  # Both streams are capped and redacted on their way to the disk. The two
  # filters are children of this script and end when the sandbox closes its
  # side, or at the cap.
  exec {jfd}> >(redact_stream "$run/capped.stdout" >"$run/turn.jsonl"); jpid=$!
  exec {efd}> >(redact_stream "$run/capped.stderr" >"$run/stderr.txt"); epid=$!
  exec {rfd}<>"$run/ready" {gfd}<>"$run/go"
  (
    # A clean environment built here rather than with `env -i K=V`, so that no
    # value - the key least of all - appears on any command line.
    while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
    export PATH=/usr/local/bin:/usr/bin:/bin HOME=/home/worker TMPDIR=/tmp LANG=C.UTF-8 TERM=dumb
    for kv in "${benv[@]}"; do export "${kv?}"; done
    export "$("${backend}_secret_var")=$secret"
    # No descriptor this script inherited reaches the sandbox: bwrap passes on
    # every open one. Only the two streams stay; the exec below opens 3, 4 and
    # 5 itself and points stdin at /dev/null.
    for f in /proc/"$BASHPID"/fd/*; do
      f=${f##*/}
      case $f in 0|1|2|"$jfd"|"$efd") ;; *) { exec {f}>&-; } 2>/dev/null ;; esac
    done
    # exec, so that setpriv's parent is this script itself: if the script is
    # killed, even with SIGKILL, timeout gets SIGKILL, and bwrap's
    # --die-with-parent then takes the whole sandbox down. A subshell left in
    # between would outlive the script and keep it all running (found in the
    # prototype: three processes stayed after a SIGKILL).
    exec setpriv --pdeathsig KILL -- timeout --kill-after=10 "$timeout_s" \
      bwrap "${sb[@]}" /usr/bin/bash -c "$INNER" bash "$FILE_BLOCKS" "$NPROC" "$DATA_KIB" "${argv[@]}" \
      3>"$run/ready" 4<"$run/go" 5>"$run/info" >&"$jfd" 2>&"$efd" </dev/null \
      {jfd}>&- {efd}>&-
  ) &
  sandbox_pid=$! turn_start=$SECONDS
  exec {jfd}>&- {efd}>&-
  line=''
  for _ in $(seq 30); do
    read -r -t 1 line <&"$rfd" && break
    kill -0 "$sandbox_pid" 2>/dev/null || break
  done
  exec {rfd}>&-
  if [ "$line" != ready ]; then
    wait "$sandbox_pid" 2>/dev/null; sandbox_pid=''; wait "$epid" 2>/dev/null
    die 4 UNAVAILABLE "bwrap cannot start a sandbox on this host: $(head -n 1 "$run/stderr.txt" 2>/dev/null | clean)"
  fi
  wire_network
  echo go >&"$gfd"; exec {gfd}>&-; gfd=''
  wait "$sandbox_pid"; rc=$?; sandbox_pid=''
  wait "$jpid" "$epid" 2>/dev/null
  child=''
  kill -TERM "$slirp" 2>/dev/null; wait "$slirp" 2>/dev/null; slirp=''
  exec {xfd}>&-; xfd=''
  cat "$run/turn.jsonl" >>"$adir/transcript.jsonl"
  { printf '\n## turn %s · %s:%s · %s\n\n' "$turn" "$backend" "$model" "$(date -u +%FT%TZ)"
    printf 'manager:\n'; redact_stream <"$run/message.md" | clean
    # The rendered text is redacted again: the raw stream was, but a key the
    # model wrote JSON-escaped is only whole once jq has decoded it.
    printf '\n'; "${backend}_render" "$run/turn.jsonl" | redact_stream
  } >>"$adir/transcript.txt"
  # shellcheck disable=SC2016
  set_meta '.turns = $t | .last = $l' --argjson t "$turn" --arg l "$(date -u +%FT%TZ)"
}
# Prints the outcome of the turn just run and exits with its code.
finish_turn() {
  local backend model id err gaps=() text n found verdicts
  backend=$(meta backend) model=$(meta model) id=$(meta id)
  header() { printf 'agent: %s · model: %s:%s · turn: %s · transcript: %s\n' "$id" "$backend" "$model" "$turn" "$adir/transcript.txt"; }
  local s
  for s in stdout stderr; do
    if [ -e "$run/capped.$s" ]; then
      header; echo "end: $id"; die 7 'BACKEND ERROR' "$backend wrote more than $((OUT_BYTES / 1048576)) MiB on its $s in one turn; what came after that was not kept"
    fi
  done
  # 124 is timeout's own status and 137 its SIGKILL after the grace, but a
  # backend can exit 124 itself or be killed inside, so either is a timeout
  # only once the limit has passed.
  if { [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; } && [ $((SECONDS - turn_start)) -ge "$timeout_s" ]; then
    header; echo "end: $id"; die 6 TIMEOUT "no reply within $timeout_s s"
  fi
  err=$("${backend}_error" "$run/turn.jsonl" | redact_stream)
  if [ "$rc" -gt 128 ] && [ "$rc" -lt 160 ]; then
    header; echo "end: $id"
    die 7 'BACKEND ERROR' "$backend was killed by signal $((rc - 128)) ($(kill -l $((rc - 128)) 2>/dev/null || echo unknown))${err:+; $err}"
  fi
  if [ -n "$err" ] || [ "$rc" -ne 0 ]; then
    header; echo "end: $id"; die 7 'BACKEND ERROR' "${err:-$backend exited $rc with no error event; see the transcript}"
  fi
  # Decoded, cleaned and then redacted, for the reason the transcript is.
  text=$("${backend}_text" "$run/turn.jsonl" | clean | redact_stream)
  if [ "$(meta role)" = reviewer ]; then
    text=$(awk -v s="$REPORT_START" -v e="$REPORT_END" '$0 == s {on = 1; b = ""; next} $0 == e && on {on = 0; last = b; got = 1; next} on {b = b $0 "\n"} END {if (got) printf "%s", last; else exit 1}' <<<"$text") \
      || gaps+=("no block between '$REPORT_START' and '$REPORT_END'")
    if [ ${#gaps[@]} -eq 0 ]; then
      # The verdict set is the one plugins/glab/agents/reviewer.md states.
      verdicts=$(command grep -cE '^(SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+)$' <<<"$text")
      if [ "$verdicts" -ne 1 ]; then
        gaps+=("expected exactly one verdict line, found $verdicts")
      else
        n=$(sed -n 's/^BLOCK: \([0-9][0-9]*\) issues$/\1/p' <<<"$text")
        if [ -n "$n" ]; then
          # Every finding carries a rule: line; advisory ones do too and are
          # not counted in n (plugins/glab/agents/reviewer.md), so the report
          # has at least n of them, not exactly n.
          found=$(command grep -c '^rule: ' <<<"$text")
          if [ "$n" -lt 1 ]; then gaps+=("BLOCK: $n issues blocks on nothing; a BLOCK names at least one issue")
          elif [ "$found" -lt "$n" ]; then gaps+=("verdict says $n issues, the report has $found findings with a rule: line"); fi
        fi
      fi
    fi
    if [ ${#gaps[@]} -gt 0 ]; then
      header; echo "end: $id"; die 8 'MALFORMED REPORT' "$(IFS=';'; echo "${gaps[*]}")"
    fi
  fi
  header
  echo 'reply:'
  [ -n "$text" ] && while IFS= read -r l; do printf '| %s\n' "$l"; done <<<"$text"
  echo "end: $id"
  exit 0
}

# --- commands -------------------------------------------------------------------
lock_agent() { # takes the agent's lock or exits 11
  # The braces keep bash's own message off stderr: the one line is die's.
  { exec {lk}>>"$adir/lock"; } 2>/dev/null || { [ -d "$adir" ] || die 10 'UNKNOWN AGENT' "no agent $(basename "$adir")"; die 4 UNAVAILABLE "cannot open $adir/lock"; }
  flock -n "$lk" || die 11 BUSY "agent $(basename "$adir") is in a turn; wait for it, or stop it"
  # stop moves an agent aside under this lock, so the file locked here must
  # still be the lock of the live directory; if not, the agent was stopped.
  [ "/proc/$$/fd/$lk" -ef "$adir/lock" ] || die 10 'UNKNOWN AGENT' "no agent $(basename "$adir"): it was stopped"
  local s; s=$(cat "/proc/$$/stat") && s=${s##*) }
  # pid and start time: stop signals this process only if both still match.
  read -r -a f <<<"$s"
  printf '%s %s\n' "$$" "${f[19]}" >"$adir/turn.pid"
}
parse_timeout() {
  # Zero is refused however it is written: 0, 00, 000.
  case $1 in ''|*[!0-9]*) die 2 USAGE "--timeout must be a positive number of seconds" ;; esac
  [[ $1 =~ ^0+$ ]] && die 2 USAGE "--timeout must be a positive number of seconds"
  # Seven digits, 115 days at most: enough for any turn, and far from where
  # bash's or timeout's arithmetic would wrap.
  [ ${#1} -le 7 ] || die 2 USAGE "--timeout must have at most 7 digits"
  timeout_s=$1
}
# True when the process in <dir>/turn.pid is alive and still the one that
# wrote it (the same start time, not a reused pid): a turn is running there.
# It opens no lock, so a list cannot make a send see a false BUSY.
turn_alive() { # turn_alive <agent dir>; sets tpid
  local st cur f
  read -r tpid st <"$1/turn.pid" 2>/dev/null || return 1
  [[ ${tpid:-} =~ ^[0-9]+$ ]] && cur=$(cat "/proc/$tpid/stat" 2>/dev/null) || return 1
  cur=${cur##*) }; read -r -a f <<<"$cur"
  [ "${f[19]}" = "$st" ]
}

cmd_start() {
  local backend='' model='' cli='' brief='' role=general label='' repo=. top id
  timeout_s=$DEFAULT_TIMEOUT
  while [ $# -gt 0 ]; do
    case $1 in
      --backend|--model|--cli|--brief|--role|--label|--repo|--timeout)
        [ $# -ge 2 ] || die 2 USAGE "$1 needs a value"
        case $1 in
          --backend) backend=$2 ;; --model) model=$2 ;; --cli) cli=$2 ;; --brief) brief=$2 ;;
          --role) role=$2 ;; --label) label=$2 ;; --repo) repo=$2 ;; --timeout) parse_timeout "$2" ;;
        esac
        shift 2 ;;
      *) die 2 USAGE "unknown argument: $(printf '%s' "$1" | head -c 40 | clean)" ;;
    esac
  done
  case $role in general|reviewer) ;; *) die 2 USAGE "--role must be general or reviewer" ;; esac
  [ -n "$model" ] || die 2 USAGE "--model is required"
  [ -f "$brief" ] && [ -r "$brief" ] || die 2 USAGE "--brief must name a readable file"
  [ -z "$label" ] || [[ $label =~ ^[[:print:]]{1,80}$ ]] || die 2 USAGE "--label must be 1-80 printable ASCII characters"
  need_tmpdir
  top=$(hostgit -C "$repo" rev-parse --show-toplevel 2>/dev/null) || die 2 USAGE "--repo is not inside a git work tree"
  known_backend "$backend" || die 3 'UNKNOWN BACKEND' "no adapter for backend '$backend' (known: opencode)"
  model_allowed "$backend" "$model"
  [ -n "$cli" ] || die 2 USAGE "--cli is required: the path of the $backend binary"
  { cli=$(readlink -f -- "$cli") && cli_ok "$cli"; } || die 4 UNAVAILABLE "the $backend CLI is not an executable file: $cli"
  net_tools
  id=ea-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n') || die 4 UNAVAILABLE "no random id"
  adir=$root/$id
  started_ok=0
  mkdir -m 700 "$adir" "$adir/data" "$adir/run" || die 4 UNAVAILABLE "cannot create $adir"
  run=$adir/run
  lock_agent
  # The key lookup runs in a directory of the agent's own; a start that
  # cannot read the key leaves nothing, as every unfinished start does.
  read_secret "$backend" "$cli" "$adir/auth"
  jq -n --arg id "$id" --arg b "$backend" --arg m "$model" --arg p "$profile" --arg r "$role" --arg l "$label" \
    --arg c "$cli" --arg t "$top" --arg now "$(date -u +%FT%TZ)" \
    '{id: $id, backend: $b, model: $m, profile: $p, role: $r, label: $l, cli: $c, repo: $t,
      head: "", branch: "", created: $now, last: $now, turns: 0, session: "", ready: false}' >"$adir/agent.json" \
    || die 4 UNAVAILABLE "cannot write $adir/agent.json"
  copy_repo "$top" "$adir/work" || die 4 UNAVAILABLE "could not copy $top: $why"
  # The copy is read-only for everyone, this script included, until stop.
  chmod -R a-w "$adir/work" || die 4 UNAVAILABLE "cannot make the copy read-only"
  # shellcheck disable=SC2016
  set_meta '.head = $h | .branch = $br' --arg h "$head_short" --arg br "$branch"
  first_prompt "$role" "$profile" "$brief" >"$run/message.md" || die 4 UNAVAILABLE "cannot write the prompt"
  run_turn - "${label:-glab external agent}"
  # shellcheck disable=SC2016
  set_meta '.session = $s | .ready = true' --arg s "$("${backend}_session" "$run/turn.jsonl")"
  started_ok=1
  finish_turn
}

cmd_send() {
  local id=${1:-} message=''
  [ $# -gt 0 ] && shift
  timeout_s=$DEFAULT_TIMEOUT
  while [ $# -gt 0 ]; do
    case $1 in
      --message|--timeout)
        [ $# -ge 2 ] || die 2 USAGE "$1 needs a value"
        case $1 in --message) message=$2 ;; --timeout) parse_timeout "$2" ;; esac
        shift 2 ;;
      *) die 2 USAGE "unknown argument: $(printf '%s' "$1" | head -c 40 | clean)" ;;
    esac
  done
  [ -f "$message" ] && [ -r "$message" ] || die 2 USAGE "--message must name a readable file"
  need_tmpdir
  agent_dir "$id"
  # The lock before the ready check: a start still in its first turn holds it,
  # and is busy (11), not unknown; only an agent nobody holds and that never
  # finished starting is 10.
  lock_agent
  [ "$(meta ready)" = true ] || die 10 'UNKNOWN AGENT' "agent $id did not finish starting; stop it"
  local session backend
  session=$(meta session) backend=$(meta backend)
  [[ $session =~ ^ses_[A-Za-z0-9]{1,64}$ ]] || die 10 'UNKNOWN AGENT' "agent $id has no session to continue; stop it and start another"
  model_allowed "$backend" "$(meta model)"
  net_tools
  read_secret "$backend" "$(meta cli)" "$adir/auth"
  run=$adir/run
  { rm -rf "$run" && mkdir -m 700 "$run"; } || die 4 UNAVAILABLE "cannot create $run"
  { cat "$message" && if [ "$(meta role)" = reviewer ]; then reviewer_tail; fi; } >"$run/message.md" \
    || die 4 UNAVAILABLE "cannot write the message"
  run_turn "$session" -
  finish_turn
}

cmd_list() {
  [ $# -eq 0 ] || die 2 USAGE "list takes no arguments"
  need_tmpdir
  local d state n=0 lines='' tpid
  # ea-* only: an agent that stop has moved aside, .stopping.<id>, is gone.
  for d in "$root"/ea-*; do
    [ -d "$d" ] || continue
    n=$((n + 1))
    # Running first: a start still in its first turn is not ready yet, and is
    # running, not broken.
    if turn_alive "$d"; then state=running
    elif [ ! -f "$d/agent.json" ] || [ "$(jq -r '.ready' "$d/agent.json" 2>/dev/null)" != true ]; then state=broken
    else state=idle; fi
    lines+=$(jq -r --arg d "$(basename "$d")" --arg s "$state" "$JQ_CLEAN"'
      "\($d)  \($s)  \(.backend // "?"):\(.model // "?")  role=\(.role // "?")  turns=\(.turns // 0)  last=\(.last // "?")  repo=\(.repo // "?")@\(.head // "?")  label=\(.label // "")" | clean' \
      "$d/agent.json" 2>/dev/null || printf '%s  %s' "$(basename "$d")" "$state")$'\n'
  done
  echo "agents: $n"
  printf '%s' "$lines"
}

cmd_stop() {
  [ $# -eq 1 ] || die 2 USAGE "stop takes one agent id"
  need_tmpdir
  [[ $1 =~ ^ea-[0-9a-f]{16}$ ]] || die 2 USAGE "not an agent id: $(printf '%s' "$1" | head -c 40 | clean)"
  adir=$root/$1
  [ -d "$adir" ] || die 10 'UNKNOWN AGENT' "no agent $1"
  local tpid gone=$root/.stopping.$1
  { exec {lk}>>"$adir/lock"; } 2>/dev/null || { [ -d "$adir" ] || die 10 'UNKNOWN AGENT' "no agent $1"; die 4 UNAVAILABLE "cannot open $adir/lock"; }
  if ! flock -n "$lk"; then
    # A turn is running: signal the process that runs it, if the recorded pid
    # is still that process.
    turn_alive "$adir" && kill -TERM "$tpid" 2>/dev/null
    flock -w 30 "$lk" || die 11 BUSY "agent $1 did not end its turn within 30 s"
  fi
  # A start stopped in its first turn removes its own agent as it ends; then
  # the file locked here is no longer the live lock, and the agent is stopped.
  if ! [ "/proc/$$/fd/$lk" -ef "$adir/lock" ]; then echo "stopped: $1"; exit 0; fi
  # Under the lock, one rename takes the agent out of reach: a send that
  # locks the old file afterwards finds it is not the live lock (lock_agent),
  # and the removal after it can take as long as it takes.
  if [ -e "$gone" ]; then chmod -R u+rwX "$gone" 2>/dev/null; rm -rf "$gone"; fi
  mv -T "$adir" "$gone" || die 4 UNAVAILABLE "cannot move $adir aside"
  chmod -R u+rwX "$gone" 2>/dev/null
  rm -rf "$gone" || die 4 UNAVAILABLE "cannot remove $gone"
  echo "stopped: $1"
}

cmd_check() {
  local backend='' cli=''
  while [ $# -gt 0 ]; do
    case $1 in
      --backend|--cli) [ $# -ge 2 ] || die 2 USAGE "$1 needs a value"
        case $1 in --backend) backend=$2 ;; --cli) cli=$2 ;; esac; shift 2 ;;
      *) die 2 USAGE "unknown argument: $(printf '%s' "$1" | head -c 40 | clean)" ;;
    esac
  done
  need_tmpdir
  known_backend "$backend" || die 3 'UNKNOWN BACKEND' "no adapter for backend '$backend' (known: opencode)"
  { cli=$(readlink -f -- "$cli") && cli_ok "$cli"; } || die 4 UNAVAILABLE "the $backend CLI is not an executable file: ${cli:-unset}"
  echo "cli: $cli"
  net_tools
  echo "tools: slirp4netns nsenter setpriv lsns ip bwrap timeout flock"
  # No agent exists here, so the lookup gets a directory of its own under the
  # state root, removed straight after.
  read_secret "$backend" "$cli" "$root/check.$$"
  echo "key: stored"
  echo "models: $("${backend}_models" | awk '{print $1 ($3 == "-" ? "" : " (until " $3 ")")}' | paste -sd, - | sed 's/,/, /g')"
}

cmd=${1:-}
[ $# -gt 0 ] && shift
secret='' root='' profile='' head_short='' branch='' why='' turn=0 rc=0 timeout_s=$DEFAULT_TIMEOUT lk='' turn_start=0
case $cmd in
  start) cmd_start "$@" ;;
  send) cmd_send "$@" ;;
  list) cmd_list "$@" ;;
  stop) cmd_stop "$@" ;;
  check) cmd_check "$@" ;;
  *) die 2 USAGE "usage: external-agent.sh start|send|list|stop|check ..." ;;
esac
