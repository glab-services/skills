#!/usr/bin/env bash
# probe.sh <run-name> <scenario.json> <auth: file|env> [extra opencode run flags...]
set -u
D=/data/tmp/claude/ocw-plan-fake; OC=/data/tmp/claude/ocw-plan-npm/node_modules/opencode-linux-x64/bin/opencode
name=$1 scen=$2 auth=$3; shift 3
R=$D/$name; rm -rf "$R"; mkdir -p "$R/home/.local/share/opencode" "$R/tmp"
git clone -q /data/tmp/claude/ocw-plan-work/repo "$R/work"; git -C "$R/work" remote remove origin
AUTHJ='{"opencode-go":{"type":"api","key":"dummy-not-a-key"}}'
authenv=()
if [ "$auth" = file ]; then printf '%s' "$AUTHJ" > "$R/home/.local/share/opencode/auth.json"; chmod 600 "$R/home/.local/share/opencode/auth.json"; else authenv=(OPENCODE_AUTH_CONTENT="$AUTHJ"); fi
CFG='{"$schema":"https://opencode.ai/config.json","share":"disabled","autoupdate":false,"provider":{"fake":{"npm":"@ai-sdk/openai-compatible","name":"Fake","options":{"baseURL":"http://127.0.0.1:18431/v1","apiKey":"not-a-key"},"models":{"m":{"name":"m","tool_call":true}}}},"permission":{"*":"deny"},"agent":{"glab-worker":{"mode":"primary","description":"glab worker","permission":{"*":"deny","read":"allow","glob":"allow","grep":"allow","list":"allow","edit":"allow","todowrite":"allow","external_directory":"deny","webfetch":"deny","websearch":"deny","bash":{"*":"allow","git commit*":"deny"}}}}}'
echo "read the brief" > "$R/home/prompt.md"
cp "$scen" "$R/tmp/scen.json"
env -i PATH=/usr/bin:/bin HOME=/home/worker TMPDIR=/tmp LANG=C.UTF-8 OPENCODE_CONFIG_CONTENT="$CFG" "${authenv[@]}" OPENCODE_DISABLE_PROJECT_CONFIG=1 OPENCODE_DISABLE_CLAUDE_CODE=1 OPENCODE_DISABLE_AUTOUPDATE=1 OPENCODE_DISABLE_MODELS_FETCH=1 OPENCODE_DISABLE_LSP_DOWNLOAD=1 OPENCODE_DISABLE_DEFAULT_PLUGINS=1 \
timeout 100 bwrap --unshare-all --die-with-parent --new-session \
 --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 --ro-bind /etc /etc --ro-bind-try /run/systemd/resolve /run/systemd/resolve \
 --proc /proc --dev /dev --bind "$R/home" /home/worker --bind "$R/tmp" /tmp --ro-bind "$OC" /opt/worker/opencode --ro-bind "$D/server.py" /opt/fake/server.py \
 --bind "$R/work" /work --ro-bind "$R/work/.git" /work/.git --chdir /work \
 /usr/bin/bash -c 'python3 /opt/fake/server.py 18431 /tmp/scen.json /tmp/server.log & for i in $(seq 20); do python3 -c "import socket;socket.create_connection((\"127.0.0.1\",18431))" 2>/dev/null && break; sleep 0.3; done; /opt/worker/opencode run "Follow the attached brief." --format json -m fake/m --agent glab-worker --dir /work -f /home/worker/prompt.md "$@"; echo "oc rc=$?" >&2' bash "$@" > "$R/out.jsonl" 2> "$R/err.txt"
echo "outer rc=$?"; tail -3 "$R/err.txt"
jq -r 'select(.type=="tool_use") | "--- \(.part.tool) \(.part.state.status): \((.part.state.input.command // .part.state.input.filePath // "")|.[0:90])\n\((.part.state.output // .part.state.error // "")|tostring|.[0:500])"' "$R/out.jsonl"
jq -c 'select(.type=="error" or .type=="text") | {type, text: .part.text, error}' "$R/out.jsonl"
