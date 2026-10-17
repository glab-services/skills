: "${TMPDIR:?export TMPDIR as the temp directory your host file names}"
CLI=${CLI:-$HOME/.opencode/bin/opencode}
S=$PWD/plugins/glab/scripts/external-agent.sh
X=$(mktemp -d "$TMPDIR/agent-offline.XXXXXX") && mkdir -p "$X/home" "$X/bin" "$X/tmp" || exit 1
# A slirp4netns stand-in: says it is ready, wires nothing, waits for the exit FIFO.
printf '#!/bin/sh\necho 1 >&7; exec 7>&-; cat <&8 >/dev/null\n' >"$X/bin/slirp4netns" && chmod +x "$X/bin/slirp4netns"
# A dummy key, imported into the throwaway home through stdin, without network.
printf '[{"id":"cred_000000000000fakeid00000AAA","integrationID":"opencode-go","label":"default","active":true,"value":{"type":"key","key":"dummy-not-a-key-99"}}]' \
  | bwrap --unshare-net --die-with-parent --dev-bind / / env -i PATH=/usr/bin:/bin HOME="$X/home" OPENCODE_DISABLE_MODELS_FETCH=1 OPENCODE_DISABLE_AUTOUPDATE=1 "$CLI" auth import --standalone
git -C "$X" init -q -b main repo && echo hi >"$X/repo/a.txt" && git -C "$X/repo" add a.txt && git -C "$X/repo" -c user.name=p -c user.email=p@p commit -qm init
printf 'Say hello.\n' >"$X/brief"; printf 'Say hello again.\n' >"$X/msg"
run() { env -i PATH="$X/bin:/usr/bin:/bin" HOME="$X/home" TMPDIR="$X/tmp" bash "$S" "$@" </dev/null; }
s=$SECONDS; run start --backend opencode --model opencode-go/kimi-k3 --cli "$CLI" --brief "$X/brief" --repo "$X/repo" --label offline >"$X/out" 2>"$X/err"; echo "start rc=$? after $((SECONDS - s)) s"
sed "s|$X|<X>|g" "$X/out" "$X/err"
id=$(sed -n 's/^agent: \(ea-[0-9a-f]*\) · .*/\1/p' "$X/out" | head -n 1)
echo "session recorded: $(jq -r '.session | test("^ses_")' "$X/tmp/glab-external-agents/$id/agent.json")"
s=$SECONDS; run send "$id" --message "$X/msg" --timeout 15 2>&1 | sed "s|$X|<X>|g"; echo "send rc=${PIPESTATUS[0]} after $((SECONDS - s)) s"
run list | sed "s|$X|<X>|g; s|$id|<id>|g"
echo "dummy key under the agent: $(/usr/bin/grep -rlF dummy-not-a-key-99 "$X/tmp" | wc -l); known positive, the throwaway home: $(/usr/bin/grep -rlF dummy-not-a-key-99 "$X/home" | wc -l)"
run stop "$id" | sed "s|$id|<id>|"
echo "agents left: $(find "$X/tmp/glab-external-agents" -mindepth 1 -maxdepth 1 | wc -l); processes left: $(ps -u "$(id -u)" -o args= | /usr/bin/grep -c "^bwrap .*$X")"
rm -rf "$X"
