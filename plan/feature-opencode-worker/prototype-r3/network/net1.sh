#!/usr/bin/env bash
# net1.sh: bwrap with its own network namespace, then pasta joins it by PID.
set -u
PASTA=$1; shift
T=$(mktemp -d /data/tmp/claude/ocr3-net.XXXXXX)
mkfifo "$T/block"
exec 4<>"$T/block"
bwrap --unshare-all --die-with-parent --new-session \
  --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 \
  --ro-bind /etc /etc --proc /proc --dev /dev --tmpfs /tmp \
  --info-fd 3 --block-fd 4 "$@" 3>"$T/info" &
bw=$!
for i in $(seq 50); do [ -s "$T/info" ] && jq -e '."child-pid"' "$T/info" >/dev/null 2>&1 && break; sleep 0.1; done
cpid=$(jq -r '."child-pid"' "$T/info")
echo "bwrap pid=$bw child=$cpid" >&2
"$PASTA" ${PASTA_OPTS:-} --userns /proc/$cpid/ns/user --netns /proc/$cpid/ns/net >"$T/pasta.out" 2>&1; echo "pasta rc=$?" >&2; cat "$T/pasta.out" >&2
echo go >&4
wait "$bw"; echo "bwrap rc=$?" >&2
rm -rf "$T"
