# mutants-r3.py <tree> <slirp-bin dir> [ids...]
# Each mutant replaces one exact snippet of external-agent.sh (checked to occur
# once), runs tests/external-agent.test.sh on a scratch copy of the tree, and
# records which cases failed. Run with python3 -I; TMPDIR must be set.
import os, re, shutil, subprocess, sys, tempfile
tree, slirp = sys.argv[1], sys.argv[2]
only = set(sys.argv[3:])
S = 'plugins/glab/scripts/external-agent.sh'
M = [
 ('M01','E01',"header() { printf 'agent: %s · model:","header() { printf 'agent: %s model:"),
 ('M02','E01','''  [ -n "$text" ] && while IFS= read -r l; do printf '| %s\\n' "$l"; done <<<"$text"
  echo "end: $id"''','''  [ -n "$text" ] && while IFS= read -r l; do printf '| %s\\n' "$l"; done <<<"$text"'''),
 ('M03','E02','  run_turn "$session" -','  run_turn - "$session"'),
 ('M04','E03','  label=\\(.label // "")"','"'),
 ('M05','E04','if .type == "reasoning" then','if .type == "reasoning-x" then'),
 ('M06','E05','  rm -rf "$adir" || die 4 UNAVAILABLE "cannot remove $adir"','  true'),
 ('M07','E06','    --ro-bind "$adir/work" /work --chdir /work','    --bind "$adir/work" /work --chdir /work'),
 ('M08','E06','''  tr '\\0' '\\n' <"$run/untracked" | while''','''  : <"$run/untracked" | while'''),
 ('M09','E06','  hostgit -C "$work" update-index -z --index-info <"$idx" ||','  true ||'),
 ('M10','E06',"case $f in */) ;; *) printf","case $f in */x) ;; *) printf"),
 ('M11','E06','  hostgit init -q --template= "$work"','  GIT_CONFIG_GLOBAL=$HOME/.gitconfig git init -q "$work"'),
 ('M12','E06','  chmod -R a-w "$adir/work" ||','  true ||'),
 ('M13','E07','    git -c core.fsmonitor=false -c core.untrackedCache=false','    git -c core.untrackedCache=false'),
 ('M14','E07','  hostgit -C "$top" ls-files -s -z >"$idx" ||','  hostgit -C "$top" diff --stat >/dev/null; hostgit -C "$top" ls-files -s -z >"$idx" ||'),
 ('M15','E07','  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_OPTIONAL_LOCKS=0','  GIT_CONFIG_NOSYSTEM=1 GIT_OPTIONAL_LOCKS=0'),
 ('M16','E08','  verify_copy "$top" "$work" "$tree"','  true'),
 ('M17','E09','    while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)\n    export PATH=/usr/local/bin','    export PATH=/usr/local/bin'),
 ('M18','E09','{action: "provider.use", resource: "*", effect: "deny"},','{action: "provider.use", resource: "*", effect: "allow"},'),
 ('M19','E09','  printf \'%s\\n\' OPENCODE_DISABLE_PROJECT_CONFIG=1 OPENCODE_DISABLE_CLAUDE_CODE=1','  printf \'%s\\n\' OPENCODE_DISABLE_CLAUDE_CODE=1'),
 ('M20','E09','{action: "edit"','{action: "edit"'),  # placeholder, replaced below
 ('M21','E10','--disable-host-loopback --enable-seccomp','--enable-seccomp'),
 ('M22','E10',"readonly BLACKHOLES='0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 169.254.0.0/16 172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.88.99.0/24 192.168.0.0/16 198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/4 240.0.0.0/4'","readonly BLACKHOLES=''"),
 ('M23','E10','    --ro-bind "$run/resolv.conf" "$(readlink -f /etc/resolv.conf)" \\\n',''),
 ('M24','E11','''  [ "$(cat "$run/slirp.ready" 2>/dev/null)" = 1 ] || die 9''','''  true || die 9'''),
 ('M25','E12','    --standalone --format json --thinking -m "$2"','    --format json --thinking -m "$2"'),
 ('M26','E12',"exec \"$@\" </dev/null'","exec \"$@\"'"),
 ('M27','E12','    --standalone --format json --thinking -m "$2"','    --standalone --format json -m "$2"'),
 ('M28','E13','readonly NPROC=256','readonly NPROC=4096'),
 ('M29','E13','readonly FILE_BLOCKS=65536','readonly FILE_BLOCKS=unlimited'),
 ('M30','E13','readonly DATA_KIB=4194304','readonly DATA_KIB=unlimited'),
 ('M31','E13','readonly TMP_BYTES=268435456','readonly TMP_BYTES=1073741824'),
 ('M32','E14','    print o s; fflush() }','    print $0; fflush() }'),
 ('M33','E14','''    printf 'manager:\\n'; redact_stream <"$run/message.md" | clean''','''    printf 'manager:\\n'; clean <"$run/message.md"'''),
 ('M34','E15','  [[ $secret =~ ^[[:graph:]]{8,}$ ]] ||','  [[ $secret =~ ^.*$ ]] ||'),
 ('M35','E16',"readonly JQ_CLEAN='def clean: gsub(","readonly JQ_CLEAN='def clean: .; def unused: gsub("),
 ('M36','E16',"done <<<\"$text\"\n  echo \"end: $id\"","done <<<\"$text\" | sed 's/^| //'\n  echo \"end: $id\""),
 ('M37','E17','    text=$(awk -v s="$REPORT_START"','    true || text=$(awk -v s="$REPORT_START"'),
 ('M38','E18','''      || gaps+=("no block between '$REPORT_START' and '$REPORT_END'")''','''      || true'''),
 ('M39','E19','          [ "$found" -eq "$n" ] ||','          true ||'),
 ('M40','E20','''    printf '# Your role contract\\n\\n'; body "$plugin/agents/reviewer.md"''','''    printf '# Your role contract\\n\\n\''''),
 ('M41','E20',"body() { awk 'NR == 1 && /^---$/ {fm = 1; next} fm && /^---$/ {fm = 0; next} !fm' \"$1\"; }","body() { cat \"$1\"; }"),
 ('M42','E21',"  [ \"$2\" != default ] && section \"$profiles/$2.md\" '## Before the contract'","  true"),
 ('M43','E22','''  jq -r 'select(.type == "error") | (.error.type // "error") + ": " + (.error.message // "")' "$1" 2>/dev/null \\''','''  jq -r 'select(.type == "error") | .error.name + ": " + (.error.data.message // "")' "$1" 2>/dev/null \\'''),
 ('M44','E23','  if [ -n "$err" ] || [ "$rc" -ne 0 ]; then','  if [ -n "$err" ]; then'),
 ('M45','E24','timeout --kill-after=10 "$timeout_s"','timeout --kill-after=10 "$((timeout_s * 100))"'),
 ('M46','E26','    exec setpriv --pdeathsig KILL -- timeout','    setpriv --pdeathsig KILL -- timeout'),
 ('M47','E26','    exec setpriv --pdeathsig KILL -- timeout','    exec setpriv -- timeout'),
 ('M48','E25','  flock -n "$lk" || die 11 BUSY','  true || die 11 BUSY'),
 ('M49','E25','      [ "${f[19]}" = "$st" ] && kill -TERM "$pid" 2>/dev/null','      true'),
 ('M50','E26','"$(jq -r \'.ready\' "$d/agent.json" 2>/dev/null)" != true ]; then state=broken','"$(jq -r \'.ready\' "$d/agent.json" 2>/dev/null)" != true ]; then state=idle'),
 ('M51','E27','  case $role in general|reviewer) ;; *) die 2 USAGE "--role must be general or reviewer" ;; esac',''),
 ('M52','E27','agent_dir() { # agent_dir <id> — the only way an id becomes a path\n  [[ $1 =~ ^ea-[0-9a-f]{16}$ ]] ||','agent_dir() { # agent_dir <id> — the only way an id becomes a path\n  true ||'),
 ('M53','E28','known_backend() { case $1 in opencode) return 0 ;; *) return 1 ;; esac; }','known_backend() { case $1 in opencode|codex) return 0 ;; *) return 1 ;; esac; }\ncodex_models() { opencode_models; }'),
 ('M54','E29','''  line=$("${1}_models" | awk -v m="$2" '$1 == m')''','''  line=$("${1}_models" | awk -v m="$2" '$1 == m || m ~ /^opencode\\//')'''),
 ('M55','E30','  if [ "$until_day" != - ] && [[ $today > $until_day ]]; then','  if false; then'),
 ('M56','E30','  model_allowed "$backend" "$(meta model)"\n','\n'),
 ('M57','E31','opencode-go/glm-5.2 glm -\n',''),
 ('M58','E32','cli_ok() { [ -f "$1" ] && [ -x "$1" ]; }','cli_ok() { true; }'),
 ('M59','E33','  echo "key: stored"','  echo "key: $secret"'),
 ('M60','E34','BLOCK: target unresolved|DO NOT PUBLISH: .+)$','BLOCK: target unresolved)$'),
 ('M61','E35','opencode-go/kimi-k3 kimi -','opencode-go/kimi-k3 kimi2 -'),
 ('M63','E06','  hostgit ${xf:+-c "core.excludesFile=$xf"} -C "$top" ls-files -z -o --exclude-standard','  hostgit -C "$top" ls-files -z -o --exclude-standard'),
 ('M64','E10',"""print a[1] "/32"}'); do""","""print a[1] "/32"}' | head -n 0); do"""),
 ('M65','E09',' --ro-bind "$run/empty" /home/worker/.config/opencode',''),
 ('M62','E36','  hostgit -C "$top" ls-files -s -z >"$idx" ||','  hostgit -C "$top" update-index -q --refresh >/dev/null; hostgit -C "$top" ls-files -s -z >"$idx" ||'),
]
# M20: the agent may edit
M = [m if m[0] != 'M20' else ('M20','E09','{action: "read", resource: "*", effect: "allow"},','{action: "read", resource: "*", effect: "allow"}, {action: "edit", resource: "*", effect: "allow"},') for m in M]
src = open(os.path.join(tree, S)).read()
work = tempfile.mkdtemp(prefix='ocr3-mut.', dir=os.environ['TMPDIR'])
killed = 0; total = 0
for mid, target, old, new in M:
    if only and mid not in only: continue
    total += 1
    c = src.count(old)
    if c != 1:
        print(f'{mid} target {target}: SKIPPED — snippet occurs {c} times', flush=True); continue
    d = os.path.join(work, mid); shutil.copytree(tree, d, symlinks=True)
    open(os.path.join(d, S), 'w').write(src.replace(old, new))
    env = dict(os.environ); env['PATH'] = slirp + ':' + env['PATH']
    if True:
        # Its own session, so that on a timeout the whole group this runner
        # started can be ended, and nothing else.
        pr = subprocess.Popen(['bash', 'tests/external-agent.test.sh', S], cwd=d, env=env, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True, stdin=subprocess.DEVNULL, start_new_session=True)
        try:
            out, _ = pr.communicate(timeout=420)
        except subprocess.TimeoutExpired:
            os.killpg(pr.pid, 9); out, _ = pr.communicate(); out = (out or '') + '\nTIMEOUT'
    failed = re.findall(r'^NOT OK (E\d+)', out, re.M)
    last = out.strip().splitlines()[-1] if out.strip() else '(no output)'
    k = target in failed
    killed += k
    print(f'{mid} target {target}: {"killed" if k else "NOT KILLED"} — failed cases: {" ".join(failed) or "none"} — {last}', flush=True)
    shutil.rmtree(d, ignore_errors=True)
shutil.rmtree(work, ignore_errors=True)
print(f'mutants: {total}, killed by their target case: {killed}, not: {total - killed}')
