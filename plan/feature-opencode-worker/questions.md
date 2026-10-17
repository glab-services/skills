# Questions — feature-opencode-worker

## Q1 — which of your five model families may receive your code

**Why it is yours (Rule 3: exposes real data).** An external worker reads a
copy of the repository — tracked files, plus untracked files that are not
ignored — and anything it reads can reach the model's provider. The script's
allowlist is the only thing that decides which providers that is, so its
content is your call, not the manager's.

**What the OpenCode Go page says** (https://opencode.ai/docs/go/, fetched raw
2026-10-16), for the families you chose:

| model id | training | retention |
|---|---|---|
| `opencode-go/kimi-k3`, `opencode-go/kimi-k2.7-code` | Not used | 0 days |
| `opencode-go/glm-5.3`, `opencode-go/glm-5.3-flash`, `opencode-go/glm-5.2` | Not used | 0 days |
| `opencode-go/deepseek-v4-pro`, `opencode-go/deepseek-v4.1-flash` | Not used | 0 days — "ZDR agreement is renewed monthly. The current agreement is valid through October 31, 2026." |
| `opencode-go/grok-4.7` | Not used | **30 days** — "ZDR disables important API features that depend on stored data, including the stateful Responses API…" |

None trains on your data. Grok keeps it for 30 days; DeepSeek's zero retention
is promised for fifteen more days, then depends on a renewal.

**Why it blocks the plan:** the allowlist is a literal block in the script, its
test and the skill's wording depend on it, and a wrong entry sends code where
you did not agree to send it.

**Options**

- **A — recommended.** Allow Kimi K3, Kimi K2.7 Code, GLM-5.3, GLM-5.3-Flash
  and GLM-5.2 with no end; allow DeepSeek V4 Pro and V4.1 Flash with the end
  date `2026-10-31` written into their allowlist line, after which the script
  refuses them (exit 5, "re-check its data policy before moving the date")
  until someone re-reads the page and moves the date — a one-line change and a
  version bump. Refuse Grok 4.7. *Consequence:* no provider keeps your code;
  DeepSeek stops on 1 November unless the date is moved; Grok is unavailable
  and its profile file sits unused until you allow it.
- **B.** A, plus Grok 4.7. *Consequence:* whatever Grok reads from the copy is
  kept by its provider for 30 days.
- **C.** All eight, DeepSeek without an end date. *Consequence:* if DeepSeek's
  agreement lapses, your code goes to a provider that keeps it, and nothing
  tells you.

**Not a choice, but needed before the first live run:** the OpenCode console's
**Use balance** switch must be off. The script cannot see it; when it is on, a
Go limit spends pay-as-you-go balance instead of stopping. The plan's live
probe asks you to confirm it.

**Answer** (recorded by the manager, 2026-10-16): the user chose **option A** — "Kimi, GLM, DeepSeek to Oct 31". Allow Kimi K3, Kimi K2.7 Code, GLM-5.3, GLM-5.3-Flash and GLM-5.2 with no end; allow DeepSeek V4 Pro and V4.1 Flash with end date `2026-10-31` enforced by the script; refuse Grok 4.7. The user was told that the console's "Use balance" switch must be off and that the script cannot see it; the live probe asks them to confirm it.
