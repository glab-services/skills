#!/usr/bin/env bash
# external-agent.sh — start, continue, list and stop read-only external agents
# on two backends: an OpenCode session on a model the user named, working on a
# sandboxed read-only copy of a repository; or a Codex session on this host,
# working in the repository itself under Codex's own read-only sandbox, on the
# model the user named or Codex's default. The glab:external-agents skill is the
# caller's manual, and tests/external-agent.test.sh pins every behaviour here.
#
#   external-agent.sh start --backend <name> --model <id> --cli <path> --brief <file>
#                           [--role general|reviewer] [--label <text>] [--repo <dir>]
#                           [--timeout <seconds>] [--effort <level>]
#                           --model is optional for codex, which then runs its
#                           own default; --effort low|medium|high|xhigh|max|ultra
#                           is taken by codex only
#   external-agent.sh send <agent id> --message <file> [--timeout <seconds>]
#   external-agent.sh list
#   external-agent.sh stop <agent id>
#   external-agent.sh check --backend <name> --cli <path>
#
# stdout of start and send, in this order and nothing else:
#   agent: <id> · model: <backend>:<model> · turn: <n> · transcript: <file>
#                   for codex, <model> is the model that ran, as its header
#                   block named it; else the one asked for, else `default`
#   reply:          (exit 0 only)
#   | <one line of the model's reply per line, control characters removed>
#   end: <id>       always the last line
# Every line the model wrote starts with "| ", and no line the script writes
# does, so nothing in a reply can pass for a field of the script's.
# stderr  one line `external-agent: <CODE>: <reason>` on every exit 2-12. A
#         signal ends it with 128 + the signal and no line: 129 HUP, 130 INT,
#         143 TERM - the last is a turn that `stop` ended.
# exit    0 OK · 2 USAGE · 3 UNKNOWN BACKEND · 4 UNAVAILABLE · 5 MODEL REFUSED ·
#         6 TIMEOUT · 7 BACKEND ERROR · 8 MALFORMED REPORT · 9 NO ISOLATED NETWORK ·
#         10 UNKNOWN AGENT · 11 BUSY · 12 NOT READ-ONLY
#
# State: $TMPDIR/glab-external-agents/<id>/ holds agent.json (written by this
# script only), work/ (the copy), data/ (the backend's data directory: its
# session database), transcript.jsonl and transcript.txt (redacted, readable
# by the user until stop), and run/ for the turn in progress, the turn's own
# $HOME included. stop moves it aside as .stopping.<id> and removes that.
# A Codex agent has no work/ and no data/: its raw transcript is
# transcript.log (each turn's stderr and stdout, not redacted), beside
# transcript.txt, and its session stays in Codex's own history under
# ~/.codex, which stop does not touch.
#
# Isolation, and why each part is there (docs/specs/external-agents.md in the
# glab-services/skills repository, *Isolation* and *Measurements*):
# OpenCode:
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
#   an empty read-only mount in every turn (spec, *Measurements*).
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
# Codex (the user chose it to run as a Claude subagent does):
# - It runs on this host, in the real repository, with its working directory
#   at the top, and sees what the user can read: the working tree with its
#   history and its ignored files, and, through its commands, files outside
#   the repository too. The user accepted that. It uses its own login under
#   ~/.codex; this script never reads, copies, exports or redacts a token, and
#   never writes ~/.codex. Codex writes its own state there, as it does for the
#   user.
# - Codex's own read-only sandbox is the containment: its commands change no
#   file, and have no IP network, and
#   a connect to a Unix-domain socket by path was refused (measured offline
#   with `codex sandbox`); datagram and abstract sockets not measured. Codex
#   itself reaches OpenAI, and keeps the session, what the model read
#   included, under ~/.codex. Every turn
#   asks for sandbox_mode read-only and approval_policy never, and the header
#   block Codex prints on stderr is read back: a block that names another
#   sandbox or approval is exit 12 and the reply is withheld; a turn whose
#   block is missing, or has no well-formed model or session id, is exit 7.
# - Every turn ignores the user's config.toml and rules, which could turn the
#   sandbox off or a tool on, and turns off web search, apps, plugins, hooks,
#   memories, the browser and computer tools, image generation and
#   multi-agent: they run outside Codex's command sandbox or reach past the
#   repository. With the user's config ignored, no project is trusted, so the
#   repository's own .codex/ config, hooks and rules do not load either.
# - Its environment is an allowlist: the path, home, user, temp, Codex home,
#   XDG, D-Bus, proxy and certificate variables when set, LANG=C.UTF-8 and
#   TERM=dumb; no other variable of the caller's, whose environment may hold
#   Claude's credentials. The values are exported, never on a command line.
# - The turn runs as setpriv --pdeathsig KILL -- setsid timeout ... setpriv
#   --pdeathsig KILL -- codex, in a process group of its own whose id is the
#   started pid. After every turn, and when this script ends, the whole group
#   gets TERM, then KILL. That is not enough on its own: Codex's sandbox
#   helper and the commands under it start a session and group of their own,
#   and outlive the group kill and SIGTERM or SIGINT to Codex. So every
#   process of the turn carries GLAB_EXTERNAL_AGENT=<agent id>, exported and
#   passed through shell_environment_policy.set, and sweep_agent kills each
#   process that holds it, by PID: after every turn, in cleanup, before every
#   send, and at every stop. The last two end what a turn left when its script
#   was SIGKILLed.
# - Of its stdout and its stderr, at most 16 MiB per turn reach the disk, as
#   for OpenCode; files, processes and memory are not limited by this script,
#   and nothing is redacted.
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
# 1 GiB and aborted at 256 MiB (spec, *Measurements*), so this binds without starving it.
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
adir='' run='' started_ok=1 child='' holder='' slirp='' sandbox_pid='' gfd='' xfd='' authd='' cmark='' host_turn=''
cleanup() {
  # A second HUP, INT or TERM while this runs would run `exit` inside the
  # trap and skip the rest: a helper left running, an unfinished start left
  # behind. A host cleanup takes seconds, so they are ignored from here on.
  trap '' HUP INT TERM
  [ -n "$gfd" ] && exec {gfd}>&-
  [ -n "$xfd" ] && exec {xfd}>&-
  # Each of these is a process this invocation started; never a name or pattern.
  [ -n "$holder" ] && kill -KILL "$holder" 2>/dev/null
  [ -n "$slirp" ] && kill -TERM "$slirp" 2>/dev/null
  [ -n "$child" ] && kill -KILL "$child" 2>/dev/null
  if [ -n "$sandbox_pid" ] && [ "$isolation" = host ]; then
    # A host turn's whole process group, as run_host ends every turn.
    kill -TERM -- -"$sandbox_pid" 2>/dev/null
    for _ in $(seq 20); do kill -0 -- -"$sandbox_pid" 2>/dev/null || break; sleep 0.1; done
    kill -KILL -- -"$sandbox_pid" 2>/dev/null
  else
    [ -n "$sandbox_pid" ] && kill -TERM "$sandbox_pid" 2>/dev/null && wait "$sandbox_pid" 2>/dev/null
  fi
  # What left the group: Codex's sandbox helper and its commands. host_turn
  # stays set until run_host's own sweep has returned, so a signal during that
  # sweep still gets one here [feature-codex-agent/plan.md D31].
  [ -n "$host_turn" ] && sweep_agent "$host_turn"
  [ -n "$cmark" ] && sweep_agent "$cmark"
  [ -n "$slirp" ] && wait "$slirp" 2>/dev/null
  [ -n "$run" ] && [ -d "$run" ] && rm -rf "$run"
  [ -n "$authd" ] && [ -d "$authd" ] && rm -rf "$authd"
  # A start that did not finish leaves nothing: no copy, no data, no transcript.
  if [ "$started_ok" -eq 0 ] && [ -n "$adir" ] && [ -d "$adir" ]; then
    chmod -R u+rwX "$adir" 2>/dev/null; rm -rf "$adir"
  fi
}
# Codex's sandbox helper, and every command under it, start a session and a
# process group of their own, so a host turn's group kill misses them, and
# they outlive SIGTERM and SIGINT to Codex too
# [feature-codex-agent/findings.md §9.9]. Every process of a host turn
# therefore carries GLAB_EXTERNAL_AGENT=<marker>, and this kills each process
# of this uid that holds that exact environment entry, by PID: its start time
# is read, then the entry and the start time are checked again, so a PID
# reused in between is not killed. The entries are compared whole, as the
# NUL-separated records environ holds, so no value that contains a newline
# can pass for one. Only a pass that killed something gets a second one,
# 1 s later, for what was starting during it; a sweep that finds nothing,
# as for every OpenCode agent, costs one scan of /proc. Killing the helper
# also ends its PID namespace, so a command that unset the marker ends with
# it. It prints nothing.
sweep_agent() { # sweep_agent <marker>
  local pass d pid st hit
  for pass in 1 2; do
    if [ "$pass" = 2 ]; then [ -n "$hit" ] || break; sleep 1; fi
    hit=''
    for d in /proc/[0-9]*; do
      [ -O "$d" ] || continue
      environ_has "$d" "GLAB_EXTERNAL_AGENT=$1" || continue
      pid=${d#/proc/}
      st=$(proc_start "$pid") || continue
      if environ_has "$d" "GLAB_EXTERNAL_AGENT=$1" && [ "$(proc_start "$pid")" = "$st" ]; then
        kill -KILL "$pid" 2>/dev/null && hit=1
      fi
    done
  done
  return 0
}
# True when /proc/<pid>/environ holds <entry> whole; a process this uid
# cannot read is skipped silently.
environ_has() { # environ_has </proc/<pid>> <entry>
  local x e=()
  mapfile -d '' -t e 2>/dev/null <"$1/environ" || return 1
  for x in "${e[@]}"; do [ "$x" = "$2" ] && return 0; done
  return 1
}
# Field 22 of /proc/<pid>/stat, the start time; the name in parentheses may
# hold spaces, so the fields are counted after its closing one.
proc_start() { # proc_start <pid>
  local s f
  s=$(cat "/proc/$1/stat" 2>/dev/null) || return 1
  s=${s##*) }; read -r -a f <<<"$s"
  [ -n "${f[19]:-}" ] && printf '%s\n' "${f[19]}"
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
# per backend. <b>_isolation says where the backend runs, and the common flow
# branches on it: `sandbox`, in this script's bwrap sandbox on a verified copy
# (OpenCode), or `host`, on this host in the repository itself, under the
# backend's own sandbox (Codex).
# - Every backend: <b>_isolation, <b>_model_allowed, <b>_effort_ok,
#   <b>_session_ok, <b>_raw_name, <b>_raw, <b>_ran, <b>_check, <b>_argv,
#   <b>_env, <b>_session, <b>_text, <b>_error and <b>_render.
# - A sandbox backend also: <b>_models, <b>_secret, <b>_secret_var,
#   <b>_secret_hint and <b>_mounts.
# - A host backend also: <b>_verify.
# A new backend is a new set plus one line in known_backend, one in
# model_optional if `--model` may be left out, and a stub in the test.

# One line per allowed model: <model id> <profile> <last day it may be used, or ->.
# Source: https://opencode.ai/docs/go/ read 2026-10-16. Every line is a model
# the page lists with Training "Not used" and Retention "0 days". DeepSeek's
# zero-retention agreement "is renewed monthly" and is "valid through October
# 31, 2026", hence its end date: past it, re-read the page and move the date.
# A model outside this list is refused (exit 5); allowing one is the user's
# call, because it decides where their code is sent. Grok 4.7 is left out on
# purpose: the page gives it 30 days' retention, and the user refused it on
# 2026-10-16 (docs/specs/external-agents.md, *Allowlist*).
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
# 1.19.3 did (spec, *Measurements*). --standalone: a private server that ends with the
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
# provider, which the policy in opencode_env forbids (spec, *Measurements*).
opencode_secret_var() { echo OPENCODE_API_KEY; }

# The permission set is the second layer, not the first: the sandbox is what
# contains the agent. Native 2.0.31 keys: "permissions" is a list of rules,
# the shell tool's action is "shell", and "policies" decides which provider
# may be used: only OpenCode Go, so a paid model cannot be reached even by id.
# Every rule is allow or deny, because a non-interactive run rejects every ask.
# OPENCODE_DISABLE_PROJECT_CONFIG stops an opencode.json or .opencode/ in the
# copy from merging keys into this agent (spec, *Measurements*, P4, re-proven on 2.0.31).
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
# OpenCode runs in this script's sandbox, on the copy.
opencode_isolation() { echo sandbox; }
# Its raw transcript is the turn's JSON events, as they came.
opencode_raw_name() { echo transcript.jsonl; }
opencode_raw() { cat "$run/turn.out"; }
# Its events do not say which model ran; the header names the one asked for.
opencode_ran() { :; }
# The session id form 2.0.31 prints, checked before send passes one back.
opencode_session_ok() { [[ $1 =~ ^ses_[A-Za-z0-9]{1,64}$ ]]; }
# OpenCode takes no effort level from this script.
opencode_effort_ok() { return 1; }
# The end of read_secret's message when no key is stored.
opencode_secret_hint() { # opencode_secret_hint <cli>
  printf '%s' "run \`$1 auth login\` for OpenCode Go"
}
# Where the backend keeps its data inside the sandbox's $HOME: the one
# directory bound from the agent's state, so that its sessions outlive a turn.
readonly DATA_IN_HOME=.local/share/opencode
# The sandbox's binds that are OpenCode's own, NUL-separated: its data
# directory, and its config directory as an empty read-only mount.
opencode_mounts() {
  printf '%s\0' --bind "$adir/data" "/home/worker/$DATA_IN_HOME" \
    --ro-bind "$run/empty" /home/worker/.config/opencode
}
opencode_model_allowed() { # opencode_model_allowed <model> — sets profile
  local line until_day today
  line=$(opencode_models | awk -v m="$1" '$1 == m')
  [ -n "$line" ] || die 5 'MODEL REFUSED' "$1 is not allowed; allowed: $(opencode_models | awk '{print $1}' | paste -sd' ' -)"
  read -r _ profile until_day <<<"$line"
  # The clock decides, in UTC. The test crosses an end date with a `date` stub
  # first on PATH; there is no variable that overrides it.
  today=$(date -u +%F) || die 4 UNAVAILABLE "date failed"
  if [ "$until_day" != - ] && [[ $today > $until_day ]]; then
    die 5 'MODEL REFUSED' "$1 was allowed until $until_day; re-check its data policy before moving the date"
  fi
}
opencode_check() { # opencode_check <cli> — what check prints after cli:
  net_tools
  echo "tools: slirp4netns nsenter setpriv lsns ip bwrap timeout flock"
  # No agent exists here, so the lookup gets a directory of its own under the
  # state root, removed straight after.
  read_secret opencode "$1" "$root/check.$$"
  echo "key: stored"
  echo "models: $(opencode_models | awk '{print $1 ($3 == "-" ? "" : " (until " $3 ")")}' | paste -sd, - | sed 's/,/, /g')"
}

# --- Codex ----------------------------------------------------------------------
# The evidence for the choices below is [feature-codex-agent/findings.md §9.2]
# and [feature-codex-agent/findings.md §9.8], which the record of that change
# carries into docs/specs/external-agents.md.
# Codex runs on this host, in the repository itself, under its own read-only
# sandbox and with its own login, which this script never reads.
codex_isolation() { echo host; }
# Its raw transcript keeps each turn's stderr, the header block included, and
# its stdout, the final message, under a line that names the turn and stream.
codex_raw_name() { echo transcript.log; }
codex_raw() {
  printf '=== turn %s stderr ===\n' "$turn"; cat "$run/stderr.txt"
  printf '=== turn %s stdout ===\n' "$turn"; cat "$run/turn.out"
}
# The levels Codex's config takes for model_reasoning_effort. Which of them a
# model supports is check's list; the manager maps the session's level onto it.
codex_effort_ok() { case $1 in low|medium|high|xhigh|max|ultra) return 0 ;; *) return 1 ;; esac; }
# The header prints the session id as a UUID; resume takes one.
codex_session_ok() { [[ $1 =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; }
# Any model id the user names, by form only: Codex has no allowlist here, and
# no model at all means Codex's own default
# [feature-codex-agent/questions.md Q5]. `default` is the word the header and
# list print for that case, not an id: as --model it would be sent as
# `-m default`, so it is refused.
codex_model_allowed() { # codex_model_allowed <model or empty> — sets profile
  profile=default
  [ "$1" != default ] || die 5 'MODEL REFUSED' "default is not a Codex model id; leave --model out for Codex's default"
  [ -z "$1" ] || [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$ ]] \
    || die 5 'MODEL REFUSED' "$(printf '%q' "$1" | head -c 80) is not a Codex model id"
}
# Every turn, first or continued, runs read-only with no approval prompt and
# without what could reach past Codex's command sandbox:
# - --ignore-user-config and --ignore-rules: the user's config.toml could turn
#   the sandbox off or a tool on. Under them no project is trusted, so the
#   repository's own .codex/ config, hooks and rules stay off too.
# - web search, apps, plugins, the browsers, computer use, image generation,
#   hooks, memories, multi-agent and MCP dependency installs run outside the
#   command sandbox or reach past the repository, so each is off. Every name
#   is in 0.163.0's `codex features list`.
# - history, telemetry, feedback and the update check are off: none of them
#   is the user's task.
# - shell_environment_policy.set carries the agent's marker (sweep_agent) to
#   Codex's sandbox helper and its commands: an exported variable stops at
#   Codex's bwrap under inherit="core". The key's last segment has no `.`,
#   which a -c key would be split at.
# --color never is taken by `exec` only, not by `exec resume`. The prompt is
# stdin (`-`), so no part of it is on a command line.
codex_argv() { # codex_argv <cli> <model or empty> <session or ->
  local f effort
  effort=$(meta effort)
  if [ "$3" = - ]; then printf '%s\0' "$1" exec --color never; else printf '%s\0' "$1" exec resume; fi
  printf '%s\0' --ignore-user-config --ignore-rules \
    -c 'sandbox_mode="read-only"' -c 'approval_policy="never"' \
    -c 'web_search="disabled"' -c 'shell_environment_policy.inherit="core"' -c 'history.persistence="none"' \
    -c analytics.enabled=false -c feedback.enabled=false -c 'otel.metrics_exporter="none"' \
    -c check_for_update_on_startup=false -c "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$(meta id)\""
  for f in apps plugins remote_plugin browser_use browser_use_external computer_use in_app_browser \
    image_generation hooks memories multi_agent skill_mcp_dependency_install; do
    printf '%s\0' --disable "$f"
  done
  if [ -n "$2" ]; then printf '%s\0' -m "$2"; fi
  if [ -n "$effort" ]; then printf '%s\0' -c "model_reasoning_effort=\"$effort\""; fi
  if [ "$3" != - ]; then printf '%s\0' "$3"; fi
  printf '%s\0' -
}
# The environment of the Codex process: what it needs to find itself, its
# login and the network, each name only when it is set, and nothing else of
# the caller's, whose environment may hold Claude's credentials. The marker
# marks the outer chain for sweep_agent.
codex_env() { # codex_env <marker>
  local v
  for v in PATH HOME USER LOGNAME TMPDIR CODEX_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME \
    XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS HTTPS_PROXY HTTP_PROXY NO_PROXY ALL_PROXY https_proxy http_proxy \
    no_proxy all_proxy SSL_CERT_FILE SSL_CERT_DIR; do
    if [ -n "${!v+x}" ]; then printf '%s=%s\n' "$v" "${!v}"; fi
  done
  printf '%s\n' LANG=C.UTF-8 TERM=dumb "GLAB_EXTERNAL_AGENT=$1"
}
# Codex's human output prints a header block on stderr before the turn starts:
# "OpenAI Codex v<version>", "--------", one "key: value" line per setting
# (workdir, model, provider, approval, sandbox, reasoning effort, reasoning
# summaries, session id) and "--------" again; its --json stream names no
# model, which is why this backend reads the human output. Only the first
# version line within the first 20 lines opens it, and only a whole block
# counts: a block later in the stream, as a command's output or the model's
# reply could print one, is text, not settings. Its input has SGR removed.
# part=block prints the block's key: value lines, or nothing; part=rest prints
# what follows the block, or all of stderr when there is none.
# shellcheck disable=SC2016
readonly CODEX_BLOCK_AWK='
  { l[NR] = $0 }
  part == "block" && !s && NR <= 20 && /^OpenAI Codex v[0-9]/ { s = NR }
  part == "block" && ((!s && NR >= 20) || (s && NR > s + 1 && $0 == "--------")) { exit }
  END {
    s = 0; e = 0
    for (i = 1; i <= NR && i <= 20; i++) if (l[i] ~ /^OpenAI Codex v[0-9]/) { s = i; break }
    if (s && l[s + 1] == "--------")
      for (j = s + 2; j <= NR; j++) {
        if (l[j] == "--------") { e = j; break }
        if (l[j] !~ /^[A-Za-z][A-Za-z _-]*:( |$)/) break
      }
    if (part == "block") { if (e) for (k = s + 2; k < e; k++) print l[k]; exit }
    for (k = e + 1; k <= NR; k++) print l[k]
  }'
codex_block() { sed 's/\x1b\[[0-9;]*m//g' "$run/stderr.txt" 2>/dev/null | awk -v part=block "$CODEX_BLOCK_AWK"; }
codex_field() { # codex_field <key> — the value of the block's first line with exactly that key
  codex_block | awk -v k="$1" 'index($0, k ": ") == 1 {print substr($0, length(k) + 3); exit}'
}
# The model that ran and the session it ran in, each only in its own form: the
# header is Codex's, but it is read as untrusted as the rest of the stream.
codex_ran() { local m; m=$(codex_field model); if [[ $m =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$ ]]; then printf '%s\n' "$m"; fi; }
codex_session() { local s; s=$(codex_field 'session id'); if codex_session_ok "$s"; then printf '%s\n' "$s"; fi; }
# stdout holds the final agent message only.
codex_text() { cat "$1"; }
# A failed turn says why on a stderr line that starts "ERROR: "; the last one
# after the block is the reason. An exit 0 is no error, whatever a command
# printed.
codex_error() { # codex_error <stdout file>
  [ "$rc" -ne 0 ] || return 0
  sed 's/\x1b\[[0-9;]*m//g' "$run/stderr.txt" 2>/dev/null | awk -v part=rest "$CODEX_BLOCK_AWK" \
    | sed -n 's/^ERROR: //p' | tail -n 1 | cut -c1-300 | clean
}
codex_render() { # codex_render <stdout file> — the readable transcript of one turn
  printf 'codex: model=%s sandbox=%s approval=%s effort=%s session=%s\n' "$(codex_field model)" "$(codex_field sandbox)" \
    "$(codex_field approval)" "$(codex_field 'reasoning effort')" "$(codex_field 'session id')" | clean
  sed 's/\x1b\[[0-9;]*m//g' "$run/stderr.txt" 2>/dev/null | awk -v part=rest "$CODEX_BLOCK_AWK" | clean
  printf 'says:\n'; clean <"$1"
}
# The read-only check of every Codex turn. A managed config or MDM sits above
# the session's -c flags and could still change the sandbox, so what Codex
# reports is what decides. `read-only` with no suffix also means its commands
# had no network: Codex appends " (network access enabled)" otherwise.
codex_verify() { # codex_verify <agent id> <model asked for, or empty>
  local sb ap
  [ -n "$(codex_block)" ] || return 0
  sb=$(codex_field sandbox) ap=$(codex_field approval)
  [ "$sb" = read-only ] && [ "$ap" = never ] && return 0
  header "$1" codex "$2"; echo "end: $1"
  die 12 'NOT READ-ONLY' "codex reported sandbox '$(printf '%s' "$sb" | head -c 80 | clean)' and approval '$(printf '%s' "$ap" | head -c 80 | clean)'; its reply is withheld"
}
# check's Codex commands run under the user's own Codex config: only exec and
# exec resume take --ignore-user-config. `login status` exits 0 for every
# logged-in mode and 1 otherwise, and its text is never printed. `debug models`
# refreshes the catalog with Codex's login and falls back to the bundled one;
# its default is predicted as the first listed model by priority, and the
# header of a turn is what names the model that ran.
# One of check's Codex commands, run from <dir> with the turns' environment
# for <marker>, values exported rather than on a command line, under
# `timeout 60` and with stdin at end-of-file.
codex_cmd() { # codex_cmd <dir> <marker> <command...>
  (
    local benv
    mapfile -t benv < <(codex_env "$2")
    cd "$1" || exit 1
    shift 2
    while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
    for kv in "${benv[@]}"; do export "${kv?}"; done
    exec timeout 60 "$@" </dev/null
  )
}
codex_check() { # codex_check <cli>
  local t err out
  for t in setpriv setsid timeout flock; do
    command -v "$t" >/dev/null || die 4 UNAVAILABLE "$t not found; see the README's Requirements"
  done
  echo "tools: setpriv setsid timeout flock"
  # A directory of its own under the state root, which cleanup removes.
  authd=$root/check.$$
  { rm -rf "$authd" && mkdir -m 700 "$authd"; } || die 4 UNAVAILABLE "cannot create $authd"
  # check's own marker, global so that cleanup sweeps it too.
  cmark=check-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n') || die 4 UNAVAILABLE "no random marker"
  err=$(codex_cmd "$authd" "$cmark" "$1" login status 2>&1 >/dev/null) \
    || die 4 UNAVAILABLE "Codex is not logged in; log in with \`codex login\` yourself"
  echo "login: stored"
  local src=0
  err=$(codex_cmd "$authd" "$cmark" "$1" sandbox -c 'sandbox_mode="read-only"' \
    -c "shell_environment_policy.set.GLAB_EXTERNAL_AGENT=\"$cmark\"" -- /bin/true 2>&1 >/dev/null) || src=$?
  # The only command here that starts Codex's sandbox helper; once swept,
  # cleanup has nothing of check's left to sweep.
  sweep_agent "$cmark"; cmark=''
  [ "$src" -eq 0 ] \
    || die 12 'NOT READ-ONLY' "Codex's read-only sandbox does not start on this host: $(command grep -v -m1 '^WARNING:' <<<"$err" | cut -c1-300 | clean)"
  echo "sandbox: read-only starts"
  # stderr is dropped here: only the catalog on stdout is read. The catalog
  # is fetched from outside, so only a slug in the model-id form that
  # codex_model_allowed takes, and only a level that codex_effort_ok takes,
  # is printed, and the lines are cleaned like any other untrusted text.
  if out=$(codex_cmd "$authd" "$cmark" "$1" debug models 2>/dev/null | jq -r '[.models[] | select(.visibility == "list")
         | select(.slug | strings | test("^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$"))] | sort_by(.priority)
       | if length == 0 then error("no listed model") else
         "default: \(.[0].slug) (predicted)",
         "models: " + (map(.slug + " (" + ([.supported_reasoning_levels[]?.effort | strings
           | select(IN("low", "medium", "high", "xhigh", "max", "ultra"))] | join(" ")) + ")") | join(", "))
       end' 2>/dev/null); then
    printf '%s\n' "$out" | clean
  else
    echo "models: unavailable"
  fi
  rm -rf "$authd"; authd=''
}

known_backend() { case $1 in codex|opencode) return 0 ;; *) return 1 ;; esac; }
known_list() { echo 'codex, opencode'; }
# A pure case, so that it can run before the backend name is checked.
model_optional() { case $1 in codex) return 0 ;; *) return 1 ;; esac; }

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
  "${1}_model_allowed" "$2"
}
cli_ok() { [ -f "$1" ] && [ -x "$1" ]; }
read_secret() { # read_secret <backend> <cli> <directory to create, empty, and run the lookup from>
  authd=$3
  { rm -rf "$authd" && mkdir -m 700 "$authd"; } || die 4 UNAVAILABLE "cannot create $authd"
  secret=$("${1}_secret" "$2" "$authd") || secret=''
  rm -rf "$authd"; authd=''
  # A key with whitespace could not be redacted reliably, and an empty one not at all.
  [[ $secret =~ ^[[:graph:]]{8,}$ ]] || { secret=''; die 4 UNAVAILABLE "no $1 key stored; $("${1}_secret_hint" "$2")"; }
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
  local profiles=$plugin/skills/external-agents/profiles line
  section "$profiles/default.md" '## Before the contract'
  [ "$2" != default ] && section "$profiles/$2.md" '## Before the contract'
  if [ "$isolation" = host ]; then
    # The text holds the repository's top as @TOP@. The replacement is quoted:
    # with patsub_replacement on, as in bash 5.3, an unquoted one would turn an
    # & in the path into the matched @TOP@.
    while IFS= read -r line; do printf '%s\n' "${line//@TOP@/"$top"}"; done <<'EOF'

# Where you are working

- You are working in the repository at @TOP@ itself: the user's real
  working tree, its history and its ignored files, not a copy. Codex runs
  you in its read-only sandbox: you can read files and run commands, and
  you cannot change any file. You are not asked to.
- Your commands can also read files outside the repository. Read nothing
  outside @TOP@ unless your task names it: what you read is sent to the
  model's provider.
- Your commands have no network. You have no web tool: do not try to fetch
  pages.
- Read @TOP@/AGENTS.md before anything else: it is the repository's
  working agreement. If there is none, read @TOP@/CLAUDE.md and say in
  your answer that the repository has no working agreement.

EOF
  else
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
  fi
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
    --bind "$run/home" /home/worker
  "${backend}_mounts"
  printf '%s\0' --size "$TMP_BYTES" --tmpfs /tmp \
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
  # the sandbox in an inner one (spec, *Measurements*), so slirp4netns needs a process in
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
run_turn() { # run_turn <session or -> <title>; sets rc, turn, turn_model
  local cli backend model
  cli=$(meta cli) backend=$(meta backend) model=$(meta model)
  cli_ok "$cli" || die 4 UNAVAILABLE "the backend CLI $cli is gone"
  turn=$(( $(meta turns) + 1 )) turn_model=''
  if [ "$isolation" = host ]; then run_host "$1"; else run_sandboxed "$1" "$2"; fi
  "${backend}_raw" >>"$adir/$("${backend}_raw_name")"
  # The model the backend reports it ran, when it reports one in its form;
  # list shows the last one.
  turn_model=$("${backend}_ran")
  # shellcheck disable=SC2016
  [ -z "$turn_model" ] || set_meta '.ran = $r' --arg r "$turn_model"
  { printf '\n## turn %s · %s:%s · %s\n\n' "$turn" "$backend" "${turn_model:-${model:-default}}" "$(date -u +%FT%TZ)"
    printf 'manager:\n'; redact_stream <"$run/message.md" | clean
    # The rendered text is redacted again: the raw stream was, but a key the
    # model wrote JSON-escaped is only whole once jq has decoded it.
    printf '\n'; "${backend}_render" "$run/turn.out" | redact_stream
  } >>"$adir/transcript.txt"
  # shellcheck disable=SC2016
  set_meta '.turns = $t | .last = $l' --argjson t "$turn" --arg l "$(date -u +%FT%TZ)"
}
run_sandboxed() { # run_sandboxed <session or -> <title>; sets rc
  local sb argv benv rfd line jfd efd jpid epid
  # run/ is new for every turn, and so is the $HOME made in it: nothing a turn
  # writes there is left for the next, and only data/ is bound back in.
  { printf 'nameserver 10.0.2.3\n' >"$run/resolv.conf" && mkfifo "$run/ready" "$run/go" && mkdir "$run/empty" "$run/home"; } \
    || die 4 UNAVAILABLE "cannot prepare $run"
  mapfile -d '' sb < <(sandbox_args "$cli")
  mapfile -d '' argv < <("${backend}_argv" /opt/glab/backend "$model" "$1" "$2" /opt/glab/message.md)
  mapfile -t benv < <("${backend}_env")
  # Both streams are capped and redacted on their way to the disk. The two
  # filters are children of this script and end when the sandbox closes its
  # side, or at the cap.
  exec {jfd}> >(redact_stream "$run/capped.$$.stdout" >"$run/turn.out"); jpid=$!
  exec {efd}> >(redact_stream "$run/capped.$$.stderr" >"$run/stderr.txt"); epid=$!
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
}
# On the host, in the repository itself: no copy, no bwrap and no network
# helper; the backend's own sandbox is the containment, and its verify adapter
# checks what the backend reports of it.
run_host() { # run_host <session or ->; sets rc
  local repo argv benv jfd efd jpid epid
  repo=$(meta repo)
  [ "$(hostgit -C "$repo" rev-parse --show-toplevel 2>/dev/null)" = "$repo" ] \
    || die 4 UNAVAILABLE "$repo is no longer the repository the agent started in"
  mapfile -d '' argv < <("${backend}_argv" "$cli" "$model" "$1")
  mapfile -t benv < <("${backend}_env" "$(meta id)")
  # Both streams are capped on their way to the disk, as in the sandbox. The
  # filters do not keep the agent's lock: if this script is SIGKILLed, they
  # live as long as a process of the turn holds the streams, and stop, whose
  # sweep ends that process, must still be able to take the lock
  # [feature-codex-agent/plan.md D31]. The cap flags carry this script's pid:
  # a filter left by a killed turn writes into the same run/ path, and its
  # flag must not fail the next turn.
  exec {jfd}> >(exec {lk}>&-; redact_stream "$run/capped.$$.stdout" >"$run/turn.out"); jpid=$!
  exec {efd}> >(exec {lk}>&-; redact_stream "$run/capped.$$.stderr" >"$run/stderr.txt"); epid=$!
  host_turn=$(meta id)
  (
    # No descriptor this script inherited reaches the backend; only the two
    # streams stay, and the exec below points stdin at the message.
    for f in /proc/"$BASHPID"/fd/*; do
      f=${f##*/}
      case $f in 0|1|2|"$jfd"|"$efd") ;; *) { exec {f}>&-; } 2>/dev/null ;; esac
    done
    # The backend's environment is its env adapter's allowlist only, exported
    # here so that no value appears on a command line.
    while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
    for kv in "${benv[@]}"; do export "${kv?}"; done
    cd -- "$repo" || exit 1
    # exec, so that the started pid is setsid's: setsid does not fork here,
    # because this subshell is not a process group leader, so the new group's
    # id is that pid, and every process of the turn is in it unless it leaves.
    # setpriv and setsid exec into timeout, which keeps the first death
    # signal: if this script dies, timeout gets SIGKILL. timeout forks the
    # backend, and a fork clears it, hence the second setpriv: if timeout
    # dies, the backend does.
    exec setpriv --pdeathsig KILL -- setsid timeout --kill-after=10 "$timeout_s" \
      setpriv --pdeathsig KILL -- "${argv[@]}" <"$run/message.md" >&"$jfd" 2>&"$efd" {jfd}>&- {efd}>&-
  ) &
  sandbox_pid=$! turn_start=$SECONDS
  exec {jfd}>&- {efd}>&-
  wait "$sandbox_pid"; rc=$?
  # The whole group, before the filters are waited for: a process the backend
  # left behind would hold its streams open, and the wait would never end.
  # timeout's own group handling is not relied on (uutils 0.10.0 here).
  kill -TERM -- -"$sandbox_pid" 2>/dev/null
  for _ in $(seq 20); do kill -0 -- -"$sandbox_pid" 2>/dev/null || break; sleep 0.1; done
  kill -KILL -- -"$sandbox_pid" 2>/dev/null; sandbox_pid=''
  # Then what left the group [feature-codex-agent/plan.md D31]: Codex's
  # sandbox helper and its commands, which would otherwise hold the streams,
  # and the wait below, open.
  sweep_agent "$host_turn"; host_turn=''
  wait "$jpid" "$epid" 2>/dev/null
}
# The first line start and send print. The model is the one the backend
# reported it ran, else the one asked for, else the backend's own default,
# which it did not name.
header() { # header <agent id> <backend> <model asked for, or empty>
  printf 'agent: %s · model: %s:%s · turn: %s · transcript: %s\n' "$1" "$2" "${turn_model:-${3:-default}}" "$turn" "$adir/transcript.txt"
}
# Prints the outcome of the turn just run and exits with its code.
finish_turn() {
  local backend model id err gaps=() text n found verdicts reported
  backend=$(meta backend) model=$(meta model) id=$(meta id)
  local s
  for s in stdout stderr; do
    if [ -e "$run/capped.$$.$s" ]; then
      header "$id" "$backend" "$model"; echo "end: $id"; die 7 'BACKEND ERROR' "$backend wrote more than $((OUT_BYTES / 1048576)) MiB on its $s in one turn; what came after that was not kept"
    fi
  done
  # 124 is timeout's own status and 137 its SIGKILL after the grace, but a
  # backend can exit 124 itself or be killed inside, so either is a timeout
  # only once the limit has passed.
  if { [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; } && [ $((SECONDS - turn_start)) -ge "$timeout_s" ]; then
    header "$id" "$backend" "$model"; echo "end: $id"; die 6 TIMEOUT "no reply within $timeout_s s"
  fi
  # A host backend's own report of its sandbox, before anything it printed is used.
  if [ "$isolation" = host ]; then "${backend}_verify" "$id" "$model"; fi
  err=$("${backend}_error" "$run/turn.out" | redact_stream)
  if [ "$rc" -gt 128 ] && [ "$rc" -lt 160 ]; then
    header "$id" "$backend" "$model"; echo "end: $id"
    die 7 'BACKEND ERROR' "$backend was killed by signal $((rc - 128)) ($(kill -l $((rc - 128)) 2>/dev/null || echo unknown))${err:+; $err}"
  fi
  if [ -n "$err" ] || [ "$rc" -ne 0 ]; then
    header "$id" "$backend" "$model"; echo "end: $id"; die 7 'BACKEND ERROR' "${err:-$backend exited $rc with no error event; see the transcript}"
  fi
  reported=$("${backend}_session" "$run/turn.out")
  # A host turn is trusted only with a well-formed model and session from its
  # header block, the first turn included.
  if [ "$isolation" = host ] && { [ -z "$turn_model" ] || [ -z "$reported" ]; }; then
    header "$id" "$backend" "$model"; echo "end: $id"; die 7 'BACKEND ERROR' "$backend printed no header block naming its model and session"
  fi
  # A backend given a session it does not find may start a new one silently, as
  # Codex does; a continued turn is accepted only in the session recorded.
  if [ "$turn" -gt 1 ] && [ "$reported" != "$(meta session)" ]; then
    header "$id" "$backend" "$model"; echo "end: $id"; die 7 'BACKEND ERROR' "$backend continued another session (${reported:-none}) instead of $(meta session)"
  fi
  # Decoded, cleaned and then redacted, for the reason the transcript is.
  text=$("${backend}_text" "$run/turn.out" | clean | redact_stream)
  if [ "$(meta role)" = reviewer ]; then
    text=$(awk -v s="$REPORT_START" -v e="$REPORT_END" '$0 == s {on = 1; b = ""; next} $0 == e && on {on = 0; last = b; got = 1; next} on {b = b $0 "\n"} END {if (got) printf "%s", last; else exit 1}' <<<"$text") \
      || gaps+=("no block between '$REPORT_START' and '$REPORT_END'")
    if [ ${#gaps[@]} -eq 0 ]; then
      # The verdict set is the one plugins/glab/agents/reviewer.md states.
      # `BLOCK: 1 issue` is the same verdict as `BLOCK: 1 issues`: both Kimi
      # models wrote the singular in the live probe
      # (docs/specs/external-agents.md, *Live runs*, finding 1). For one only:
      # no template and no reviewer writes `BLOCK: 3 issue`, and accepting it
      # would widen the check past what was seen.
      verdicts=$(command grep -cE '^(SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: 1 issue|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+)$' <<<"$text")
      if [ "$verdicts" -ne 1 ]; then
        gaps+=("expected exactly one verdict line, found $verdicts")
      else
        # Both forms, each matched whole as in the set above, so a line out of
        # form, such as `BLOCK: 3 issue` beside a SHIP, is never read as a count.
        n=$(sed -n -e 's/^BLOCK: \([0-9][0-9]*\) issues$/\1/p' -e 's/^BLOCK: \(1\) issue$/\1/p' <<<"$text")
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
      header "$id" "$backend" "$model"; echo "end: $id"; die 8 'MALFORMED REPORT' "$(IFS=';'; echo "${gaps[*]}")"
    fi
  fi
  header "$id" "$backend" "$model"
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
  local backend='' model='' cli='' brief='' role=general label='' repo=. top id effort=''
  timeout_s=$DEFAULT_TIMEOUT
  while [ $# -gt 0 ]; do
    case $1 in
      --backend|--model|--cli|--brief|--role|--label|--repo|--timeout|--effort)
        [ $# -ge 2 ] || die 2 USAGE "$1 needs a value"
        case $1 in
          --backend) backend=$2 ;; --model) model=$2 ;; --cli) cli=$2 ;; --brief) brief=$2 ;;
          --role) role=$2 ;; --label) label=$2 ;; --repo) repo=$2 ;; --timeout) parse_timeout "$2" ;;
          --effort) effort=$2 ;;
        esac
        shift 2 ;;
      *) die 2 USAGE "unknown argument: $(printf '%s' "$1" | head -c 40 | clean)" ;;
    esac
  done
  case $role in general|reviewer) ;; *) die 2 USAGE "--role must be general or reviewer" ;; esac
  [ -n "$model" ] || model_optional "$backend" || die 2 USAGE "--model is required"
  [ -f "$brief" ] && [ -r "$brief" ] || die 2 USAGE "--brief must name a readable file"
  [ -z "$label" ] || [[ $label =~ ^[[:print:]]{1,80}$ ]] || die 2 USAGE "--label must be 1-80 printable ASCII characters"
  need_tmpdir
  top=$(hostgit -C "$repo" rev-parse --show-toplevel 2>/dev/null) || die 2 USAGE "--repo is not inside a git work tree"
  known_backend "$backend" || die 3 'UNKNOWN BACKEND' "no adapter for backend '$backend' (known: $(known_list))"
  isolation=$("${backend}_isolation")
  [ -z "$effort" ] || "${backend}_effort_ok" "$effort" || die 2 USAGE "--effort is not taken by the $backend backend, or $effort is not a level"
  model_allowed "$backend" "$model"
  [ -n "$cli" ] || die 2 USAGE "--cli is required: the path of the $backend binary"
  if [ "$isolation" = sandbox ]; then
    { cli=$(readlink -f -- "$cli") && cli_ok "$cli"; } || die 4 UNAVAILABLE "the $backend CLI is not an executable file: $cli"
    net_tools
  else
    # Absolute, but not resolved: a link the backend's updates move, such as
    # Codex's current link, is followed at every turn.
    [[ $cli == /* ]] || cli=$PWD/$cli
    cli_ok "$cli" || die 4 UNAVAILABLE "the $backend CLI is not an executable file: $cli"
  fi
  id=ea-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n') || die 4 UNAVAILABLE "no random id"
  adir=$root/$id
  started_ok=0
  if [ "$isolation" = sandbox ]; then
    mkdir -m 700 "$adir" "$adir/data" "$adir/run" || die 4 UNAVAILABLE "cannot create $adir"
  else
    mkdir -m 700 "$adir" "$adir/run" || die 4 UNAVAILABLE "cannot create $adir"
  fi
  run=$adir/run
  lock_agent
  # The key lookup runs in a directory of the agent's own; a start that
  # cannot read the key leaves nothing, as every unfinished start does.
  if [ "$isolation" = sandbox ]; then read_secret "$backend" "$cli" "$adir/auth"; fi
  jq -n --arg id "$id" --arg b "$backend" --arg m "$model" --arg e "$effort" --arg p "$profile" --arg r "$role" \
    --arg l "$label" --arg c "$cli" --arg t "$top" --arg now "$(date -u +%FT%TZ)" \
    '{id: $id, backend: $b, model: $m, effort: $e, ran: "", profile: $p, role: $r, label: $l, cli: $c, repo: $t,
      head: "", branch: "", created: $now, last: $now, turns: 0, session: "", ready: false}' >"$adir/agent.json" \
    || die 4 UNAVAILABLE "cannot write $adir/agent.json"
  if [ "$isolation" = sandbox ]; then
    copy_repo "$top" "$adir/work" || die 4 UNAVAILABLE "could not copy $top: $why"
    # The copy is read-only for everyone, this script included, until stop.
    chmod -R a-w "$adir/work" || die 4 UNAVAILABLE "cannot make the copy read-only"
  else
    # The backend works in the repository itself, which needs no commit: one
    # with none records an empty head and branch.
    head_short=$(hostgit -C "$top" rev-parse -q --verify HEAD) || head_short=''
    head_short=${head_short:0:12}
    branch=$(hostgit -C "$top" symbolic-ref -q HEAD) || branch=''
  fi
  # shellcheck disable=SC2016
  set_meta '.head = $h | .branch = $br' --arg h "$head_short" --arg br "$branch"
  first_prompt "$role" "$profile" "$brief" >"$run/message.md" || die 4 UNAVAILABLE "cannot write the prompt"
  run_turn - "${label:-glab external agent}"
  # shellcheck disable=SC2016
  set_meta '.session = $s | .ready = true' --arg s "$("${backend}_session" "$run/turn.out")"
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
  # Only once the lock shows the directory is live: a stop that ran in
  # between would leave no agent.json to read, and bash's own message would
  # break the one stderr line.
  isolation=$("$(meta backend)_isolation")
  [ "$(meta ready)" = true ] || die 10 'UNKNOWN AGENT' "agent $id did not finish starting; stop it"
  local session backend
  session=$(meta session) backend=$(meta backend)
  "${backend}_session_ok" "$session" || die 10 'UNKNOWN AGENT' "agent $id has no session to continue; stop it and start another"
  model_allowed "$backend" "$(meta model)"
  if [ "$isolation" = sandbox ]; then
    net_tools
    read_secret "$backend" "$(meta cli)" "$adir/auth"
  fi
  run=$adir/run
  # A turn whose script was SIGKILLed may have left its helper and its
  # stream filters running, and they would write into the new run/
  # [feature-codex-agent/plan.md D31].
  if [ "$isolation" = host ]; then sweep_agent "$id"; fi
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
      "\($d)  \($s)  \(.backend // "?"):\(if (.ran // "") != "" then .ran elif (.model // "") != "" then .model else "default" end)  role=\(.role // "?")  turns=\(.turns // 0)  last=\(.last // "?")  repo=\(.repo // "?")@\(.head // "?")  label=\(.label // "")" | clean' \
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
  local tpid sb gone=$root/.stopping.$1
  { exec {lk}>>"$adir/lock"; } 2>/dev/null || { [ -d "$adir" ] || die 10 'UNKNOWN AGENT' "no agent $1"; die 4 UNAVAILABLE "cannot open $adir/lock"; }
  if ! flock -n "$lk"; then
    # A turn is running: signal the process that runs it, if the recorded pid
    # is still that process.
    turn_alive "$adir" && kill -TERM "$tpid" 2>/dev/null
    flock -w 30 "$lk" || die 11 BUSY "agent $1 did not end its turn within 30 s"
  fi
  # Whatever a host turn left running when its script was SIGKILLed, and so
  # ran no cleanup [feature-codex-agent/plan.md D31]. No process of an
  # OpenCode agent carries the marker, so an agent whose agent.json names a
  # sandbox backend is not swept; one whose agent.json is missing, or names
  # no backend this script knows, is.
  sb=$(jq -r '.backend // empty' "$adir/agent.json" 2>/dev/null) || sb=''
  if [ -z "$sb" ] || ! known_backend "$sb" || [ "$("${sb}_isolation")" != sandbox ]; then
    sweep_agent "$1"
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
  known_backend "$backend" || die 3 'UNKNOWN BACKEND' "no adapter for backend '$backend' (known: $(known_list))"
  isolation=$("${backend}_isolation")
  # Resolved for a sandbox backend, whose sandbox binds that one file; only
  # made absolute for a host backend, as start does.
  if [ "$isolation" = sandbox ]; then
    { cli=$(readlink -f -- "$cli") && cli_ok "$cli"; } || die 4 UNAVAILABLE "the $backend CLI is not an executable file: ${cli:-unset}"
  else
    { [ -n "$cli" ] && { [[ $cli == /* ]] || cli=$PWD/$cli; } && cli_ok "$cli"; } \
      || die 4 UNAVAILABLE "the $backend CLI is not an executable file: ${cli:-unset}"
  fi
  echo "cli: $cli"
  "${backend}_check" "$cli"
}

cmd=${1:-}
[ $# -gt 0 ] && shift
secret='' root='' profile='' head_short='' branch='' why='' turn=0 rc=0 timeout_s=$DEFAULT_TIMEOUT lk='' turn_start=0 isolation='' turn_model=''
case $cmd in
  start) cmd_start "$@" ;;
  send) cmd_send "$@" ;;
  list) cmd_list "$@" ;;
  stop) cmd_stop "$@" ;;
  check) cmd_check "$@" ;;
  *) die 2 USAGE "usage: external-agent.sh start|send|list|stop|check ..." ;;
esac
