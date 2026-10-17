#!/usr/bin/env bash
# net5.sh <slirp4netns> <libdir> -- <cmd...>
# bwrap with its own netns; the command inside first reports "ready" on fd 3 and
# waits for "go" on fd 4, so the namespaces are complete before anyone joins them.
set -u
SL=$1 LIB=$2; shift 3
T=$(mktemp -d /data/tmp/claude/ocr3-net.XXXXXX); mkfifo "$T/ready" "$T/go"
printf 'nameserver 10.0.2.3\n' > "$T/resolv.conf"
bwrap --unshare-all --die-with-parent --new-session \
  --ro-bind /usr /usr --ro-bind-try /bin /bin --ro-bind-try /sbin /sbin --ro-bind-try /lib /lib --ro-bind-try /lib64 /lib64 \
  --ro-bind /etc /etc --ro-bind "$T/resolv.conf" "$(readlink -f /etc/resolv.conf)" --ro-bind /data/tmp/claude/ocr3-scripts /s --proc /proc --dev /dev --tmpfs /tmp \
  /usr/bin/sh -c 'echo $$ >&3; exec 3>&-; read -r _ <&4; exec 4<&-; exec "$@"' sh "$@" 3>"$T/ready" 4<"$T/go" &
bw=$!
exec 6<"$T/ready" 7>"$T/go"
read -r inner <&6; exec 6<&-
# The sandbox's pid 1 is bwrap's; the command is pid 2 in its pid ns. Find it on the host side:
c=$(for p in $(pgrep -P "$bw"); do pgrep -P "$p"; echo "$p"; done | head -n 1)
echo "inner pid in ns=$inner host child=$c user=$(readlink /proc/$c/ns/user)" >&2
nsenter -t "$c" --user-parent --preserve-credentials sleep 600 & h=$!
sleep 0.2
echo "holder $h $(readlink /proc/$h/ns/user)" >&2
exec 5>"$T/sl-ready"
LD_LIBRARY_PATH=$LIB "$SL" --configure --mtu=65520 --disable-host-loopback ${SL_OPTS:-} --userns-path=/proc/$h/ns/user --netns-type=path --ready-fd=5 /proc/$c/ns/net tap0 >"$T/sl.log" 2>&1 &
sl=$!
exec 5>&-
for i in $(seq 50); do [ -s "$T/sl-ready" ] && break; sleep 0.1; done
echo "slirp ready=$(cat "$T/sl-ready") pid=$sl" >&2
for r in ${BLACKHOLE:-}; do nsenter --user=/proc/$h/ns/user --net=/proc/$c/ns/net --preserve-credentials ip route add blackhole "$r" || echo "route $r failed" >&2; done
echo go >&7; exec 7>&-
wait "$bw"; echo "bwrap rc=$?" >&2
kill "$sl" "$h" 2>/dev/null; wait "$sl" "$h" 2>/dev/null
/usr/bin/grep -iE "error|fail|denied|permit|sandbox|seccomp|WARN" "$T/sl.log" | head -5 >&2
rm -rf "$T"
