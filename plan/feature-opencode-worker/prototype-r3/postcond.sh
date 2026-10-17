sec() { awk -v h="$1" 'index($0,h)==1{on=1;next} on&&/^## /{on=0} on' plugins/glab/skills/manager/SKILL.md; }
# The eight new files with their modes; the edited files by content only,
# since git restore gives them whatever mode the umask allows.
for f in plugins/glab/scripts/external-agent.sh tests/external-agent.test.sh plugins/glab/skills/external-agents/SKILL.md plugins/glab/skills/external-agents/profiles/default.md plugins/glab/skills/external-agents/profiles/kimi.md plugins/glab/skills/external-agents/profiles/glm.md plugins/glab/skills/external-agents/profiles/deepseek-pro.md plugins/glab/skills/external-agents/profiles/deepseek-flash.md; do if [ -f "$f" ]; then echo "$(sha256sum <"$f" | cut -c1-16) $(stat -c %a "$f") $f"; else echo "absent $f"; fi; done
for f in plugins/glab/skills/manager/SKILL.md plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/commands/develop.md AGENTS.md README.md plugins/glab/.claude-plugin/plugin.json; do if [ -f "$f" ]; then echo "$(sha256sum <"$f" | cut -c1-16) $f"; else echo "absent $f"; fi; done
echo "files under external-agents: $(find plugins/glab/skills/external-agents -type f | sort | paste -sd' ' -)"
echo "rev-2 paths left: $(ls -d plugins/glab/scripts/external-worker.sh tests/external-worker.test.sh plugins/glab/skills/workers 2>/dev/null | wc -l)"
echo "rev2-build: $(cd plan/feature-opencode-worker/rev2-build 2>/dev/null && for f in external-worker.sh external-worker.test.sh workers-SKILL.md profiles/*.md tracked.diff; do sha256sum <"$f" | cut -c1-16; done | paste -sd' ' -)"
for h in '## Rule 5 ' '## Rule 6 ' '## When subagent dispatch is not available' '## Stage 5 ' '## What you never do'; do echo "manager '$h' $(sec "$h" | /usr/bin/grep -c -F -e 'glab:external-agents' -e 'external reviewer' -e 'external agent')"; done
echo "rule 6 headings: $(/usr/bin/grep -c '^## Rule 6 ' plugins/glab/skills/manager/SKILL.md)"
for f in plugins/glab/commands/review.md plugins/glab/commands/ship.md plugins/glab/commands/develop.md; do echo "$f $(/usr/bin/grep -c -F 'glab:external-agents' "$f")"; done
echo "version $(jq -r .version plugins/glab/.claude-plugin/plugin.json)"
echo "census exit codes: $(/usr/bin/grep -rlE 'exit (8|9|10|11)\b|\((8|9|10|11)\)|MALFORMED REPORT|NO ISOLATED NETWORK|UNKNOWN AGENT|MODEL REFUSED' plugins tests AGENTS.md README.md | sort | paste -sd' ' -)"
echo "census verdicts: $(/usr/bin/grep -rlE 'SHIP WITH SCOPE CUT|DO NOT PUBLISH' plugins tests AGENTS.md README.md | sort | paste -sd' ' -)"
echo "census token: $(/usr/bin/grep -rlE 'opencode:opencode-go|glab:reviewer opencode opencode-go' plugins tests AGENTS.md README.md | sort | paste -sd' ' -)"
echo "census allowlist: $(/usr/bin/grep -rliE 'kimi|glm|deepseek|2026-10-31' plugins tests AGENTS.md README.md | sort | paste -sd' ' -)"
echo "census limits: $(/usr/bin/grep -rlE '64 MiB|256 MiB|4 GiB|256 processes|slirp4netns' plugins tests AGENTS.md README.md | sort | paste -sd' ' -)"
c() { echo "census $1: $(/usr/bin/grep -rlE -- "$2" plugins tests AGENTS.md README.md | sort | paste -sd' ' -)"; }
c 'state dir' 'glab-external-agents'; c 'default cli' '\.opencode/bin/opencode'; c 'use balance' 'Use balance'
c 'what the copy sends' 'not ignored|untracked-but-not-ignored'; c 'grok' 'Grok|grok'
c 'send correction' 'exit-8 `send`|`send` the same agent|`send` to the same agent'
c 'manual rule, external' "is the user's call"
c 'not run against a real model' 'not yet run against a real model'
echo "guard: model ids in payload prose $(/usr/bin/grep -rlE 'opencode-go/[a-z0-9]' --include='*.md' plugins | wc -l)"
echo "guard: grok in allowlist $(/usr/bin/grep -cE '^opencode-go/grok' plugins/glab/scripts/external-agent.sh)"
echo "guard: rev-2 names $(/usr/bin/grep -rlE 'external-worker|glab:workers|skills/workers' plugins tests AGENTS.md README.md | wc -l)"
echo "guard: invisible characters $(LC_ALL=C /usr/bin/grep -rlP '\xe2\x80[\x8b-\x8f\xa8-\xae]|\xe2\x81[\xa6-\xa9]|\xc2[\x80-\x9f]' plugins tests AGENTS.md README.md | wc -l)"
echo "guard: known positive for that search $(printf 'a\xe2\x80\x8bb\n' | LC_ALL=C /usr/bin/grep -cP '\xe2\x80[\x8b-\x8f\xa8-\xae]')"
