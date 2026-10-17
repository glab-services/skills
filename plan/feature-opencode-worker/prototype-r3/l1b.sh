: "${TMPDIR:?export TMPDIR as the temp directory your host file names}"
: "${MODEL:?set MODEL to one allowed id, such as opencode-go/glm-5.3}"
CLI=${CLI:-$HOME/.opencode/bin/opencode}
S=$PWD/plugins/glab/scripts/external-agent.sh
P=$(mktemp -d "$TMPDIR/agent-probe.XXXXXX") || exit 1
id_of() { sed -n 's/^agent: \(ea-[0-9a-f]*\) · .*/\1/p' "$1" | head -n 1; }
# A correct add() is committed and the bug left uncommitted, so the reviewer's
# target, the working tree, is not empty: it holds the bug.
git -C "$P" init -q -b main && printf 'def add(a, b):\n    return a + b\n' >"$P/calc.py" && git -C "$P" add calc.py \
  && git -C "$P" -c user.name=probe -c user.email=probe@example.invalid commit -qm init \
  && printf 'def add(a, b):\n    return a - b\n' >"$P/calc.py" || exit 1
# The port your own OpenCode service listens on, if one runs: the agent must not reach it.
PORT=$(ss -ltnpH | awk '/"opencode"/ {n = split($4, a, ":"); print a[n]; exit}'); echo "OpenCode service port: ${PORT:-none}"
printf '%s\n' 'Answer in three numbered lines:' '1. what calc.py does, and whether add() is correct;' \
  '2. the exact output of: ls -a ~ /home; ip -4 route; cat /etc/resolv.conf' \
  "3. the exact output of: curl -sS -m 5 http://10.0.2.2:${PORT:-1}/ ; echo x >>calc.py" >"$P.brief"
"$S" start --backend opencode --model "$MODEL" --cli "$CLI" --brief "$P.brief" --label probe --repo "$P" >"$P.out1"; echo "start rc=$?"; cat "$P.out1"
A=$(id_of "$P.out1"); echo "agent: ${A:-none}"
printf 'Quote the first line of my first message, word for word.\n' >"$P.msg"
"$S" send "$A" --message "$P.msg"; echo "send rc=$?"
"$S" list
printf 'Review the uncommitted working tree. This is round 1 of 1, the last.\n' >"$P.rev"
"$S" start --backend opencode --model "$MODEL" --cli "$CLI" --brief "$P.rev" --role reviewer --label probe-review --repo "$P" >"$P.out2"; echo "review rc=$?"; cat "$P.out2"
B=$(id_of "$P.out2"); echo "review agent: ${B:-none}"
for t in $(sed -n 's/.* · transcript: //p' "$P.out1" "$P.out2"); do echo "$t redacted=$(command grep -c '<redacted>' "$t")"; done
