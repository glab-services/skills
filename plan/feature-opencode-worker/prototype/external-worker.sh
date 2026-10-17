#!/usr/bin/env bash
# external-worker.sh — run one glab:developer or glab:reviewer dispatch on an
# external model the user named, inside a bubblewrap sandbox, on a disposable
# copy of the repository. The glab:workers skill is the caller's manual, and
# tests/external-worker.test.sh pins every behaviour stated here.
#
#   external-worker.sh --role developer|reviewer --backend <name> --model <id>
#                      --brief <file> [--repo <dir>] [--timeout <seconds>]
#
# stdout  exit 0: the validated report block, then `out: <dir>`. Exits 6-9:
#         `out: <dir>` only, so the transcript can still be read. Nothing else
#         is ever printed on stdout.
# stderr  one line `external-worker: <CODE>: <reason>` on every non-zero exit.
# exit    0 OK · 2 USAGE · 3 UNKNOWN BACKEND · 4 UNAVAILABLE · 5 MODEL REFUSED ·
#         6 TIMEOUT · 7 BACKEND ERROR · 8 MALFORMED REPORT · 9 SECRET IN OUTPUT
#
# <dir> holds report.txt, transcript.jsonl, stderr.txt and, for the developer,
# changes.patch. The caller reads them and removes <dir>; this script removes
# only its own working copy and sandbox home inside it.
#
# Isolation, and why each part is there (findings of feature-opencode-worker):
# - The worker never sees the real repository. It gets a fresh clone plus the
#   real tree's staged, unstaged and untracked-but-not-ignored changes. Ignored
#   files (.env and the like) are never copied, so they never leave the host.
# - The copy's .git is bound read-only inside the sandbox: no commit, ref, tag,
#   stash, hook or config write can happen, whatever command the model runs.
#   A before/after check of the real repo cannot be fooled or false-positive
#   because the real repo is not mounted at all.
# - The sandbox has no /home, no /data, no host /tmp: only /usr, /etc, the
#   copy at /work, a scratch /tmp and a throwaway $HOME. The environment is
#   rebuilt from an allowlist, so no token of the caller's reaches it.
# - The network is shared: the backend has to reach its API. That is the one
#   open path, and the credential inside the sandbox is the backend's own key.
#   The key is redacted from the transcript and report, and a patch carrying
#   it is refused (exit 9).
# The adapter functions are called as "${backend}_<name>" and cleanup() by
# trap, which shellcheck cannot follow; SC2329 would flag each one.
# shellcheck disable=SC2329
set -u

readonly MARK_START='=== REPORT START ==='
readonly MARK_END='=== REPORT END ==='
# 3600 s: a developer slice is usually well under an hour; past that the
# manager should hear about it rather than wait. --timeout overrides it.
readonly DEFAULT_TIMEOUT=3600

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
plugin=$(cd "$here/.." && pwd)
out='' run='' keep_out=0 secret=''

die() { # die <exit code> <CODE> <reason>
  printf 'external-worker: %s: %s\n' "$2" "$3" >&2
  exit "$1"
}

cleanup() {
  # The worker may have chmod-ed files in its copy; make them removable first.
  if [ -n "$run" ] && [ -d "$run" ]; then chmod -R u+rwX "$run" 2>/dev/null; rm -rf "$run"; fi
  if [ -n "$out" ] && [ "$keep_out" -eq 0 ]; then rm -rf "$out"; fi
}
trap cleanup EXIT

# --- arguments ---------------------------------------------------------------
role='' backend='' model='' brief='' repo=. timeout_s=$DEFAULT_TIMEOUT
while [ $# -gt 0 ]; do
  case $1 in
    --role|--backend|--model|--brief|--repo|--timeout)
      [ $# -ge 2 ] || die 2 USAGE "$1 needs a value"
      case $1 in
        --role) role=$2 ;; --backend) backend=$2 ;; --model) model=$2 ;;
        --brief) brief=$2 ;; --repo) repo=$2 ;; --timeout) timeout_s=$2 ;;
      esac
      shift 2 ;;
    *) die 2 USAGE "unknown argument: $1" ;;
  esac
done
case $role in developer|reviewer) ;; *) die 2 USAGE "--role must be developer or reviewer" ;; esac
[ -n "$model" ] || die 2 USAGE "--model is required"
[ -f "$brief" ] || die 2 USAGE "--brief must name a file"
case $timeout_s in ''|*[!0-9]*|0) die 2 USAGE "--timeout must be a positive number of seconds" ;; esac
# TMPDIR is required, not defaulted: on some hosts /tmp is a small shared
# tmpfs, and the host file names the temp directory to use instead.
[ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ] || die 2 USAGE "TMPDIR must name an existing directory"
top=$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null) || die 2 USAGE "--repo is not inside a git work tree"
git -C "$top" rev-parse -q --verify HEAD >/dev/null || die 2 USAGE "the repository has no commit yet"

# --- backend adapters --------------------------------------------------------
# Everything that depends on the backend is in this section, one function set
# per backend: <b>_models, <b>_locate, <b>_credential, <b>_env, <b>_argv,
# <b>_text, <b>_error. A new backend is a new set plus one line in the case
# below and a stub in the test; nothing outside this section changes.

# One line per allowed model: <model id> <profile> <last day it may be used, or ->.
# Source: https://opencode.ai/docs/go/ read 2026-10-16. Every line is a model
# the page lists with Training "Not used" and Retention "0 days". DeepSeek's
# zero-retention agreement "is renewed monthly" and is "valid through October
# 31, 2026", hence its end date: past it, re-read the page and move the date.
# A model outside this list is refused (exit 5); allowing one is the user's
# call, because it decides where their code is sent.
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

opencode_locate() {
  local p
  p=$(command -v opencode) || return 1
  readlink -f "$p"
}

# Prints the JSON that OPENCODE_AUTH_CONTENT takes, holding the OpenCode Go
# entry only, so no other provider's key from auth.json enters the sandbox.
# The key is passed in the environment, not as auth.json in the sandbox home:
# with auth.json present, opencode 1.19.3 blocked at start-up on an npm
# install of @opencode-ai/plugin (findings), and with the variable it did not.
opencode_credential() {
  local f="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/auth.json"
  [ -r "$f" ] || return 1
  jq -ce 'select((.["opencode-go"].key | type) == "string" and (.["opencode-go"].key | length) > 0)
          | {"opencode-go": .["opencode-go"]}' "$f" 2>/dev/null
}
opencode_secret() { jq -r '.["opencode-go"].key' <<<"$1"; }

# The permission set is the second layer, not the first: the sandbox is what
# contains the worker. "*": deny first, then each tool the role needs; every
# rule is allow or deny, because a non-interactive run rejects every "ask".
# OPENCODE_DISABLE_PROJECT_CONFIG stops a project opencode.json or .opencode/
# in the copy from merging keys into this agent (findings: without it a
# project file replaced the agent's prompt and allowed external_directory).
opencode_env() { # opencode_env <role> <credential json>
  local edit=allow
  [ "$1" = reviewer ] && edit=deny
  printf 'OPENCODE_AUTH_CONTENT=%s\n' "$2"
  printf 'OPENCODE_CONFIG_CONTENT=%s\n' "$(jq -cn --arg edit "$edit" '{
    "$schema": "https://opencode.ai/config.json", share: "disabled", autoupdate: false,
    permission: {"*": "deny"},
    agent: {"glab-worker": {mode: "primary", description: "glab external worker",
      permission: {"*": "deny", read: "allow", glob: "allow", grep: "allow", list: "allow",
        todowrite: "allow", edit: $edit, bash: "allow",
        external_directory: {"*": "deny", "/tmp/*": "allow"},
        webfetch: "deny", websearch: "deny", task: "deny", skill: "deny",
        question: "deny", doom_loop: "deny"}}}}')"
  printf '%s\n' OPENCODE_DISABLE_PROJECT_CONFIG=1 OPENCODE_DISABLE_CLAUDE_CODE=1 \
    OPENCODE_DISABLE_AUTOUPDATE=1 OPENCODE_DISABLE_LSP_DOWNLOAD=1
}

# The message goes before -f: -f takes an array, and a message after it is
# read as a second file ("Error: File not found: <message>").
opencode_argv() { # opencode_argv <model> <cli path in sandbox> <prompt path in sandbox>
  printf '%s\0' "$2" run "Read the attached file and follow it exactly. It is your whole task." \
    --pure --format json -m "$1" --agent glab-worker --dir /work -f "$3"
}

# --format json prints one event per line; the model's words are the "text"
# events' part.text, in order.
opencode_text() { jq -r 'select(.type == "text") | .part.text' "$1" 2>/dev/null; }
# A failure arrives as {"type":"error","error":{"name":..,"data":{"message":..}}}.
opencode_error() {
  jq -r 'select(.type == "error") | .error.name + ": " + (.error.data.message // "")' "$1" 2>/dev/null | head -n 1 | cut -c1-300
}

case $backend in
  opencode) ;;
  *) die 3 'UNKNOWN BACKEND' "no adapter for backend '$backend' (known: opencode)" ;;
esac

# --- model, CLI, credential, sandbox -------------------------------------------
line=$("${backend}_models" | awk -v m="$model" '$1 == m')
if [ -z "$line" ]; then
  die 5 'MODEL REFUSED' "$model is not allowed; allowed: $("${backend}_models" | awk '{print $1}' | paste -sd' ' -)"
fi
read -r _ profile until_day <<<"$line"
# EXTERNAL_WORKER_TODAY exists so the test can cross an end date; the date
# comes from the clock otherwise.
today=${EXTERNAL_WORKER_TODAY:-$(date -u +%F)}
if [ "$until_day" != - ] && [[ $today > $until_day ]]; then
  die 5 'MODEL REFUSED' "$model was allowed until $until_day; re-check its data policy before moving the date"
fi

cli=$("${backend}_locate") || die 4 UNAVAILABLE "$backend CLI not found on PATH"
command -v bwrap >/dev/null || die 4 UNAVAILABLE "bwrap (bubblewrap) not found on PATH"
cred=$("${backend}_credential") || die 4 UNAVAILABLE "no $backend credential found"
secret=$("${backend}_secret" "$cred")

out=$(mktemp -d "$TMPDIR/external-worker.XXXXXX") || die 4 UNAVAILABLE "cannot create a directory under TMPDIR"
run=$out/.run
mkdir -p "$run/home" "$run/tmp"
work=$run/work

# The one place the sandbox is defined. Prints bwrap's arguments, NUL-separated.
sandbox_args() { # sandbox_args ro|rw
  local tree=--bind
  [ "$1" = ro ] && tree=--ro-bind
  printf '%s\0' --unshare-all --share-net --die-with-parent --new-session \
    --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin \
    --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 --ro-bind /etc /etc \
    --ro-bind-try /run/systemd/resolve /run/systemd/resolve \
    --proc /proc --dev /dev \
    --bind "$run/home" /home/worker --bind "$run/tmp" /tmp \
    --ro-bind "$cli" /opt/worker/backend \
    "$tree" "$work" /work --ro-bind "$work/.git" /work/.git --chdir /work
}

# --- the copy ------------------------------------------------------------------
copy_repo() {
  local head branch
  git init -q "$work" || return 1
  # Branches, tags and remote-tracking refs, so a reviewer's branch or range
  # target resolves as it does in the real repo. No remote is configured in
  # the copy, so nothing can be pushed from it.
  git -C "$work" fetch -q --no-tags --update-head-ok "$top" '+refs/heads/*:refs/heads/*' \
    '+refs/tags/*:refs/tags/*' '+refs/remotes/*:refs/remotes/*' || return 1
  head=$(git -C "$top" rev-parse HEAD)
  if branch=$(git -C "$top" symbolic-ref -q HEAD); then
    git -C "$work" symbolic-ref HEAD "$branch"
  else
    git -C "$work" update-ref --no-deref HEAD "$head"
  fi
  git -C "$work" reset -q --hard "$head" || return 1
  git -C "$top" diff --binary --staged | git -C "$work" apply --index --allow-empty || return 1
  git -C "$top" diff --binary | git -C "$work" apply --allow-empty || return 1
  # Untracked, not ignored. An entry ending in / is a nested repository: it is
  # its own history and is not copied.
  git -C "$top" ls-files -z -o --exclude-standard \
    | while IFS= read -r -d '' f; do case $f in */) ;; *) printf '%s\0' "$f" ;; esac; done \
    | tar -C "$top" --null -T - -cf - | tar -C "$work" -xf - || return 1
}
copy_repo || die 4 UNAVAILABLE "could not build the working copy of $top"

# Baseline of the copy as the worker receives it, in an index file outside
# the copy, so the copy's own index (what the worker sees as staged) is kept.
cp "$work/.git/index" "$run/base.index"
GIT_INDEX_FILE=$run/base.index git -C "$work" add -A
base=$(GIT_INDEX_FILE=$run/base.index git -C "$work" write-tree)

mapfile -d '' sb_ro < <(sandbox_args ro)
bwrap "${sb_ro[@]}" /usr/bin/true 2>/dev/null || die 4 UNAVAILABLE "bwrap cannot start a sandbox on this host"

# --- the prompt ------------------------------------------------------------------
body() { awk 'NR == 1 && /^---$/ {fm = 1; next} fm && /^---$/ {fm = 0; next} !fm' "$1"; }
section() { awk -v h="$2" 'index($0, h) == 1 {on = 1; next} on && /^## / {on = 0} on' "$1"; }
report_section() { awk '/^## Report/ {on = 1} on && /^## / && !/^## Report/ {on = 0} on' "$1"; }
profiles=$plugin/skills/workers/profiles
{
  section "$profiles/default.md" '## Before the contract'
  [ "$profile" != default ] && section "$profiles/$profile.md" '## Before the contract'
  cat <<EOF

# Where you are working

- /work is a disposable copy of the repository. Nothing you do there reaches
  the real one until the manager has read your work and decided to apply it.
- /work/.git is read-only. You cannot commit, stage, branch, tag, stash or
  change git config or hooks, and you are not asked to: never try.
- Your scratch directory is /tmp. Use it, and nothing outside /work, for
  throwaway files.
- There is no /home and no access to any other repository or credential.

EOF
  printf '# Your role contract\n\n'; body "$plugin/agents/$role.md"
  printf '\n# The skills you carry\n\n'
  body "$plugin/skills/security/SKILL.md"; printf '\n'; body "$plugin/skills/comments/SKILL.md"
  printf '\n# Your dispatch\n\n'; cat "$brief"
  printf '\n'
  section "$profiles/default.md" '## After the contract'
  [ "$profile" != default ] && section "$profiles/$profile.md" '## After the contract'
  printf '\n# Your final message\n\nEnd your final message with your report, and put nothing after it. The report is the block your contract'"'"'s Report section asks for, filled in, between these two lines exactly:\n\n%s\n<the report>\n%s\n\nYour contract'"'"'s Report section, again:\n\n' "$MARK_START" "$MARK_END"
  report_section "$plugin/agents/$role.md"
} > "$run/home/prompt.md"

# --- the run ---------------------------------------------------------------------
mode=rw
[ "$role" = reviewer ] && mode=ro
mapfile -d '' sb < <(sandbox_args "$mode")
mapfile -d '' argv < <("${backend}_argv" "$model" /opt/worker/backend /home/worker/prompt.md)
mapfile -t benv < <("${backend}_env" "$role" "$cred")
(
  # A clean environment built here rather than with `env -i K=V`, so that no
  # value - the credential least of all - appears on any command line.
  while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)
  export PATH=/usr/local/bin:/usr/bin:/bin HOME=/home/worker TMPDIR=/tmp LANG=C.UTF-8 TERM=dumb
  for kv in "${benv[@]}"; do export "${kv?}"; done
  exec timeout --kill-after=10 "$timeout_s" bwrap "${sb[@]}" "${argv[@]}"
) > "$out/transcript.jsonl" 2> "$out/stderr.txt"
rc=$?

# --- read back ---------------------------------------------------------------------
contains() { K=$secret awk 'BEGIN {k = ENVIRON["K"]} k != "" && index($0, k) {f = 1} END {exit !f}' "$1"; }
redact() {
  K=$secret awk 'BEGIN {k = ENVIRON["K"]} {
    s = $0; o = ""
    while (k != "" && (i = index(s, k)) > 0) { o = o substr(s, 1, i - 1) "<redacted>"; s = substr(s, i + length(k)) }
    print o s }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}
redact "$out/transcript.jsonl"; redact "$out/stderr.txt"
keep_out=1

if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
  echo "out: $out"; die 6 TIMEOUT "no result within $timeout_s s"
fi
err=$("${backend}_error" "$out/transcript.jsonl")
if [ -n "$err" ] || [ "$rc" -ne 0 ]; then
  echo "out: $out"; die 7 'BACKEND ERROR' "${err:-$backend exited $rc with no error event; see stderr.txt}"
fi

"${backend}_text" "$out/transcript.jsonl" \
  | awk -v s="$MARK_START" -v e="$MARK_END" '$0 == s {on = 1; b = ""; next} $0 == e && on {on = 0; last = b; got = 1; next} on {b = b $0 "\n"} END {if (got) printf "%s", last; else exit 1}' \
  > "$out/report.txt"
got=$?
redact "$out/report.txt"

gaps=()
if [ "$got" -ne 0 ]; then
  gaps+=("no block between '$MARK_START' and '$MARK_END'")
elif [ "$role" = developer ]; then
  for f in steps files tests gates detail; do
    command grep -q "^$f:" "$out/report.txt" || gaps+=("no '$f:' line")
  done
  # The verdict set is the one plugins/glab/agents/developer.md states.
  last=$(awk 'NF {l = $0} END {print l}' "$out/report.txt")
  [[ $last =~ ^(BUILT|BLOCKED:\ .+|PLAN\ WRONG:\ .+)$ ]] || gaps+=("last line is not BUILT, BLOCKED: <reason> or PLAN WRONG: <what>")
  detail=$(sed -n 's/^detail:[[:space:]]*//p' "$out/report.txt" | head -n 1)
  case $detail in
    ''|/*|*..*) gaps+=("detail: must name a file inside the repository") ;;
    *) [ -f "$work/$detail" ] || gaps+=("detail: $detail was not written") ;;
  esac
else
  # The verdict set is the one plugins/glab/agents/reviewer.md states.
  verdicts=$(command grep -cE '^(SHIP|SHIP WITH SCOPE CUT: .+|BLOCK: [0-9]+ issues|BLOCK: target unresolved|DO NOT PUBLISH: .+)$' "$out/report.txt")
  if [ "$verdicts" -ne 1 ]; then
    gaps+=("expected exactly one verdict line, found $verdicts")
  else
    n=$(sed -n 's/^BLOCK: \([0-9][0-9]*\) issues$/\1/p' "$out/report.txt")
    if [ -n "$n" ]; then
      found=$(command grep -c '^rule: ' "$out/report.txt")
      [ "$found" -eq "$n" ] || gaps+=("verdict says $n issues, the report has $found findings with a rule: line")
    fi
  fi
fi
if [ ${#gaps[@]} -gt 0 ]; then
  echo "out: $out"
  die 8 'MALFORMED REPORT' "$(IFS=';'; echo "${gaps[*]}")"
fi

if [ "$role" = developer ]; then
  cp "$run/base.index" "$run/end.index"
  GIT_INDEX_FILE=$run/end.index git -C "$work" add -A
  end=$(GIT_INDEX_FILE=$run/end.index git -C "$work" write-tree)
  git -C "$work" diff-tree -p --binary --no-renames "$base" "$end" > "$out/changes.patch"
  if contains "$out/changes.patch"; then
    rm -f "$out/changes.patch"
    echo "out: $out"; die 9 'SECRET IN OUTPUT' "the worker's changes contain the $backend credential; the patch was deleted"
  fi
fi

cat "$out/report.txt"
echo "out: $out"
exit 0
