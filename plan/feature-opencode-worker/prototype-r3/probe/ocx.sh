#!/bin/bash
# ocx.sh [K=V ...] -- <opencode args>: run the user's opencode offline:
# no network, real home hidden, fake HOME under $OCX_D.
D=${OCX_D:?}
mkdir -p "$D/home" "$D/tmp"
envs=()
while [ "$1" != -- ]; do envs+=("$1"); shift; done; shift
exec env -i PATH=/usr/bin:/bin HOME="$D/home" TMPDIR=/tmp TERM=dumb "${envs[@]}" \
  bwrap --unshare-net --unshare-pid --die-with-parent --dev-bind / / --tmpfs /home/pvhv --tmpfs /tmp \
  --bind "$D/tmp" /tmp --ro-bind /home/pvhv/.opencode/bin/opencode /home/pvhv/oc --chdir "${OCX_CWD:-$D/home}" \
  timeout "${OCX_T:-60}" /home/pvhv/oc "$@"
