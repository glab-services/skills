: "${TMPDIR:?export TMPDIR as the temp directory your host file names}"
CLI=${CLI:-$HOME/.opencode/bin/opencode}
S=$PWD/plugins/glab/scripts/external-agent.sh
# 1. The binary is the native one: prints "177   E   L   F".
od -An -c -N4 "$CLI"
# 2. The tools, the stored key (never printed) and the allowed models.
"$S" check --backend opencode --cli "$CLI"; echo "check rc=$?"
# 3. The sandbox and its network on this host, with the stub only.
bash tests/external-agent.test.sh "$S" </dev/null | tail -n 1
# 4. No command: open the OpenCode console and look at the Go "Use balance" switch.
