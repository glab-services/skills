#!/usr/bin/env bash
set -u
T=$(mktemp -d /data/tmp/claude/ocr3-net.XXXXXX); mkfifo "$T/block"; exec 4<>"$T/block"
bwrap --unshare-all --die-with-parent --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 --proc /proc --dev /dev \
  --info-fd 3 --block-fd 4 /usr/bin/true 3>"$T/info" &
bw=$!
for i in $(seq 50); do jq -e '."child-pid"' "$T/info" >/dev/null 2>&1 && break; sleep 0.1; done
c=$(jq -r '."child-pid"' "$T/info")
ls -l /proc/$c/ns/ 2>&1 | head -3; cat /proc/$c/status | /usr/bin/grep -E '^(Uid|CapEff|NSpid|NStgid)'; cat /proc/$c/attr/current 2>&1; cat /proc/$$/attr/current
nsenter -t "$c" -U -n --preserve-credentials /usr/sbin/ip -br addr; echo "nsenter U+n rc=$?"
nsenter -t "$c" -n /usr/sbin/ip -br addr; echo "nsenter n rc=$?"
echo go >&4; wait $bw; rm -rf "$T"
