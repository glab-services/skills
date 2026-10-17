#!/usr/bin/env bash
set -u
T=$(mktemp -d /data/tmp/claude/ocr3-net.XXXXXX); mkfifo "$T/block"; exec 4<>"$T/block"
bwrap --unshare-all --die-with-parent --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 --proc /proc --dev /dev \
  --info-fd 3 --block-fd 4 /usr/bin/true 3>"$T/info" &
bw=$!
for i in $(seq 50); do jq -e '."child-pid"' "$T/info" >/dev/null 2>&1 && break; sleep 0.1; done
c=$(jq -r '."child-pid"' "$T/info")
for p in $$ $bw $(pgrep -P $bw) $c; do echo "pid $p $(readlink /proc/$p/ns/user) $(readlink /proc/$p/ns/net) $(tr '\0' ' ' </proc/$p/cmdline | cut -c1-30)"; done
lsns -t net -o NS,PID,NETNSID,NSFS 2>/dev/null | head -3
python3 -I - "$c" <<'PY'
import os, sys, fcntl
c = sys.argv[1]
NS_GET_USERNS = 0xb701
fd = os.open(f"/proc/{c}/ns/net", os.O_RDONLY)
u = fcntl.ioctl(fd, NS_GET_USERNS)
print("owner of child netns:", os.readlink(f"/proc/self/fd/{u}"))
fd2 = os.open(f"/proc/{c}/ns/user", os.O_RDONLY)
NS_GET_PARENT = 0xb702
try:
    p = fcntl.ioctl(fd2, NS_GET_PARENT); print("parent of child userns:", os.readlink(f"/proc/self/fd/{p}"))
except OSError as e: print("parent:", e)
PY
echo go >&4; wait $bw; rm -rf "$T"
