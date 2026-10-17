#!/usr/bin/env bash
# probe.sh <dir> <scenario.json> <config json> [opencode args...]
# Runs opencode 2.0.31 in a bwrap sandbox with no network but its own loopback,
# where a scripted fake OpenAI-compatible server answers. <dir> keeps home and work
# between calls, so a second call can continue a session.
set -u
R=$1 scen=$2 cfg=$3; shift 3
OC=/home/pvhv/.opencode/bin/opencode
S=/data/tmp/claude/ocr3-scripts
mkdir -p "$R/home" "$R/tmp" "$R/log"
if [ ! -d "$R/work" ]; then
  git init -q -b main "$R/work"; printf 'a\n' > "$R/work/a.txt"
  git -C "$R/work" add a.txt; git -C "$R/work" -c user.name=p -c user.email=p@p commit -qm init
fi
cp "$scen" "$R/tmp/scen.json"
env -i LIM_D=${LIM_D:-unlimited} LIM_U=${LIM_U:-unlimited} PATH=/usr/bin:/bin HOME=/home/worker TMPDIR=/tmp LANG=C.UTF-8 TERM=dumb \
  OPENCODE_CONFIG_CONTENT="$cfg" OPENCODE_DISABLE_PROJECT_CONFIG=1 OPENCODE_DISABLE_CLAUDE_CODE=1 \
  OPENCODE_DISABLE_AUTOUPDATE=1 OPENCODE_DISABLE_MODELS_FETCH=1 ${PROBE_ENV:-} \
  timeout "${PROBE_T:-60}" bwrap --unshare-all --die-with-parent --new-session \
  --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 \
  --ro-bind /etc /etc --proc /proc --dev /dev \
  --bind "$R/home" /home/worker --bind "$R/tmp" /tmp --bind "$R/log" /log \
  --ro-bind "$OC" /opt/worker/backend --ro-bind "$S/fake-model-server.py" /opt/fake/server.py \
  --bind "$R/work" /work --ro-bind "$R/work/.git" /work/.git --chdir /work \
  /usr/bin/bash -c 'ulimit -d ${LIM_D:-unlimited}; ulimit -u ${LIM_U:-unlimited}; python3 -I /opt/fake/server.py 18431 /tmp/scen.json /log/server.log & for i in $(seq 30); do python3 -Ic "import socket;socket.create_connection((\"127.0.0.1\",18431))" 2>/dev/null && break; sleep 0.2; done; /opt/worker/backend "$@"; echo "oc rc=$?" >&2' bash "$@"
