#!/usr/bin/env bash
# net3.sh <slirp4netns> <libdir> -- <cmd...>: bwrap with its own netns; slirp4netns
# attaches by PID with host loopback disabled; blackhole routes for non-public ranges.
set -u
SL=$1 LIB=$2; shift 3
T=$(mktemp -d /data/tmp/claude/ocr3-net.XXXXXX); mkfifo "$T/block"; exec 4<>"$T/block"
printf 'nameserver 10.0.2.3\n' > "$T/resolv.conf"
bwrap --unshare-all --die-with-parent --new-session \
  --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 \
  --ro-bind /etc /etc --ro-bind "$T/resolv.conf" "$(readlink -f /etc/resolv.conf)" --ro-bind /data/tmp/claude/ocr3-scripts /s --proc /proc --dev /dev --tmpfs /tmp \
  --info-fd 3 --block-fd 4 "$@" 3>"$T/info" &
bw=$!
for i in $(seq 50); do jq -e '."child-pid"' "$T/info" >/dev/null 2>&1 && break; sleep 0.1; done
c=$(jq -r '."child-pid"' "$T/info")
# bwrap puts the netns in an outer user namespace and the child in an inner one;
# a holder process in the outer one gives slirp4netns a userns path that owns the netns.
nsenter -t "$c" --user-parent --preserve-credentials sleep 600 & h=$!
for i in $(seq 50); do [ "$(readlink /proc/$h/ns/user)" != "$(readlink /proc/$$/ns/user)" ] && break; sleep 0.05; done
echo "holder $h $(readlink /proc/$h/ns/user)" >&2
exec 5>"$T/ready"
LD_LIBRARY_PATH=$LIB "$SL" --configure --mtu=65520 --disable-host-loopback ${SL_OPTS:-} --userns-path=/proc/$h/ns/user --netns-type=path --ready-fd=5 /proc/$c/ns/net tap0 >"$T/sl.log" 2>&1 &
sl=$!
exec 5>&-
for i in $(seq 50); do [ -s "$T/ready" ] && break; sleep 0.1; done
echo "slirp ready=$(cat "$T/ready") pid=$sl" >&2
for r in ${BLACKHOLE:-}; do nsenter --user=/proc/$h/ns/user --net=/proc/$c/ns/net --preserve-credentials ip route add blackhole "$r" || echo "route $r failed" >&2; done
echo go >&4
wait "$bw"; echo "bwrap rc=$?" >&2
kill "$sl" "$h" 2>/dev/null; wait "$sl" "$h" 2>/dev/null
tail -3 "$T/sl.log" >&2
rm -rf "$T"
