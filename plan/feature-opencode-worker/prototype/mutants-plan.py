# The plan round's mutant runner (plan.md, After, Mutants). T was a tree built
# from plan.md's own blocks on a git archive of 889b804, removed after the run;
# rebuild it and point T and M at it to re-run. Applies one mutation at a time
# to a copy of external-worker.sh, runs external-worker.test.sh, and prints
# which cases failed. Expected: the target case fails.
import subprocess, shutil, os, sys, re
T='/data/tmp/claude/ocw-p3/t1'; M='/data/tmp/claude/ocw-p3/mut'
src=open(f'{T}/plugins/glab/scripts/external-worker.sh').read()
muts=[
 ('W08','--ro-bind "$work/.git" /work/.git ',''),
 ('W12','[ "$1" = ro ] && tree=--ro-bind','[ "$1" = ro ] && tree=--bind'),
 ('W09','while IFS= read -r v; do unset "$v" 2>/dev/null; done < <(compgen -e)',':'),
 ('W09',"""{"opencode-go": .["opencode-go"]}'""",""".'"""),
 ('W12','[ "$1" = reviewer ] && edit=deny',':'),
 ('W10',"printf '%s\\n' OPENCODE_DISABLE_PROJECT_CONFIG=1 ","printf '%s\\n' "),
 ('W11','run "Read the attached file and follow it exactly. It is your whole task." \\\n    --pure --format json -m "$1" --agent glab-worker --dir /work -f "$3"','run --pure --format json -m "$1" --agent glab-worker --dir /work -f "$3" "Read the attached file and follow it exactly. It is your whole task."'),
 ('W11','--pure --format json','--auto --pure --format json'),
 ('W04',"| tar -C \"$top\" --null -T - -cf - | tar -C \"$work\" -xf - || return 1","| tar -C \"$top\" --null -T - -cf - >/dev/null || return 1"),
 ('W04','git -C "$top" diff --binary --staged | git -C "$work" apply --index --allow-empty || return 1',':'),
 ('W04','git -C "$top" ls-files -z -o --exclude-standard','git -C "$top" ls-files -z -o'),
 ('W06','[ "$profile" != default ] && section "$profiles/$profile.md" \'## Before the contract\'',':'),
 ('W07','section "$profiles/$profile.md" \'## Before the contract\'','section "$profiles/kimi.md" \'## Before the contract\''),
 ('W05',"  section \"$profiles/default.md\" '## After the contract'","  cat \"$profiles/default.md\""),
 ('W05','body() { awk \'NR == 1 && /^---$/ {fm = 1; next} fm && /^---$/ {fm = 0; next} !fm\' "$1"; }','body() { cat "$1"; }'),
 ('W20','{on = 0; last = b; got = 1; next}','{on = 0; if (!got) last = b; got = 1; next}'),
 ('W17','command grep -q "^$f:" "$out/report.txt" || gaps+=("no \'$f:\' line")',':'),
 ('W18','*) [ -f "$work/$detail" ] || gaps+=("detail: $detail was not written") ;;','*) ;;'),
 ('W19','|| gaps+=("last line is not BUILT, BLOCKED: <reason> or PLAN WRONG: <what>")','|| :'),
 ('W15','[ "$found" -eq "$n" ] || gaps+=','[ "$found" -ge 0 ] || gaps+='),
 ('W14',"found=$(command grep -c '^rule: ' \"$out/report.txt\")","found=$(command grep -cE '^(rule|fix): ' \"$out/report.txt\")"),
 ('W21','err=$("${backend}_error" "$out/transcript.jsonl")','err='),
 ('W22','if [ -n "$err" ] || [ "$rc" -ne 0 ]; then','if [ -n "$err" ]; then'),
 ('W23','exec timeout --kill-after=10 "$timeout_s" bwrap','exec timeout --kill-after=10 600 bwrap'),
 ('W24','redact "$out/transcript.jsonl"; redact "$out/stderr.txt"',':'),
 ('W25','if contains "$out/changes.patch"; then','if false; then'),
 ('W26',"  *) die 3 'UNKNOWN BACKEND'","  *) backend=opencode;; x) die 3 'UNKNOWN BACKEND'"),
 ('W27','if [ -z "$line" ]; then','if false; then'),
 ('W28','if [ "$until_day" != - ] && [[ $today > $until_day ]]; then','if false; then'),
 ('W29','opencode-go/glm-5.2 glm -\n',''),
 ('W30','cli=$("${backend}_locate") || die 4 UNAVAILABLE "$backend CLI not found on PATH"','cli=$("${backend}_locate") || cli=/usr/bin/true'),
 ('W31','cred=$("${backend}_credential") || die 4 UNAVAILABLE "no $backend credential found"','cred=$("${backend}_credential") || cred=\'{"opencode-go":{"key":"x"}}\''),
 ('W32','case $role in developer|reviewer) ;;','case $role in developer|reviewer|analyzer) ;;'),
 ('W33',"PLAN\\ WRONG:\\ .+","PLAN\\ FAIL:\\ .+"),
 ('W01','cat "$out/report.txt"\necho "out: $out"','cat "$out/report.txt"\necho debug\necho "out: $out"'),
 ('W03','chmod -R u+rwX "$run" 2>/dev/null; rm -rf "$run"; fi',':; fi'),
 ('W02','GIT_INDEX_FILE=$run/end.index git -C "$work" add -A\n','GIT_INDEX_FILE=$run/end.index git -C "$work" add -A\n  base=$(GIT_INDEX_FILE=$run/end.index git -C "$work" write-tree)\n'),
 ('W16',"if [ ${#gaps[@]} -gt 0 ]; then\n  echo \"out: $out\"","if [ ${#gaps[@]} -gt 0 ]; then\n  :"),
 ('W13',"$0 == e && on {on = 0; last = b; got = 1; next} on {b = b $0 \"\\n\"}","$0 == e && on {on = 0; last = b; got = 1; next} /^not checked/ {next} on {b = b $0 \"\\n\"}"),
 ('W39',"  tree=$(git -C \"$top\" rev-parse 'HEAD^{tree}') || return 1","  git -C \"$work\" fetch -q --update-head-ok \"$top\" '+refs/*:refs/*'\n  tree=$(git -C \"$top\" rev-parse 'HEAD^{tree}') || return 1"),
 ('W37','"$tree" "$work" /work --ro-bind','"$tree" "$top" /work --ro-bind'),
 ('W35','    git -C "$work" update-ref --no-deref HEAD "$commit"','    :'),
 ('W38',"if [ \"$got\" -eq 0 ] && command grep -q '^out: ' \"$out/report.txt\"; then","if false; then"),
 ('W40','  if git -C "$work" diff-tree --numstat','  if false && git -C "$work" diff-tree --numstat'),
 ('W41','  ulimit -f "$FILE_BLOCKS"\n',''),
 ('W41','--size "$TMP_BYTES" --tmpfs /tmp','--tmpfs /tmp'),
 ('W36','bwrap "${sb_ro[@]}" /usr/bin/true 2>/dev/null || die 4 UNAVAILABLE "bwrap cannot start a sandbox on this host"',':'),
 ('W34','opencode-go/glm-5.2 glm -','opencode-go/glm-5.2 glm-old -'),
]
env=dict(os.environ, TMPDIR='/data/tmp/claude')
bad=0
for i,(target,old,new) in enumerate(muts,1):
    c=src.count(old)
    if c!=1: print(f'M{i:02d} {target} SKIPPED: pattern count {c}'); bad+=1; continue
    d=f'{M}/m{i}'; shutil.rmtree(d,ignore_errors=True); shutil.copytree(f'{T}/plugins/glab',d+'/glab')
    open(d+'/glab/scripts/external-worker.sh','w').write(src.replace(old,new))
    r=subprocess.run(['bash',f'{T}/tests/external-worker.test.sh',d+'/glab/scripts/external-worker.sh'],capture_output=True,text=True,env=env,timeout=600)
    failed=re.findall(r'^NOT OK (W\d+)',r.stdout,re.M)
    hit = target in failed
    if not hit: bad+=1
    print(f'M{i:02d} target {target}: {"killed" if hit else "SURVIVED"} — failed cases: {" ".join(failed) or "none"} — {r.stdout.strip().splitlines()[-1]}')
    shutil.rmtree(d)
print(f'mutants: {len(muts)}, not killed or skipped: {bad}')
