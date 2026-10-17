# Findings, revision 3 — feature-opencode-worker

Written 2026-10-17 against `main` at `889b804` (`= origin/main`), with the
uncommitted rev-2 build in the working tree (`git status`: seven modified
tracked files, ten new files under `plugins/` and `tests/`). The rev-2 records
— `findings.md`, `questions.md`, `plan.md`, `result.md`, `prototype/` — stay
as history and are not edited. This file and `plan-r3.md` supersede them where
they disagree. `questions.md` Q1 (the model allowlist, option A) stays
binding.

## Why there is a revision 3

**The user's new direction** (binding; `plan-r3.md` *Decisions* U7–U12): an
external agent that works like a background subagent, for the manager to use
as a tool — `start` (brief, named model, its own sandboxed read-only copy;
returns an id and the reply), `send <id>` (same session, context kept),
`list`, `stop <id>` (removes workspace and session data); usable in the
background; a transcript the user can read until `stop`, and the model named
in every reply; **read-only work only** — the developer wiring is dropped;
manual only; backend-neutral names and an adapter boundary.

**The review of rev 2** asked for: an isolated network (pasta or slirp4netns)
and a named refusal without it; a copy no git setting of the user can change
or use to run code on the host, verified against the real tree; nothing left
after an interruption or a kill; model text treated as untrusted; process and
memory limits; the key on no command line and in no output; every OpenCode
fact re-verified on the version now installed.

## The rev-2 build against the installed OpenCode

The user has `opencode v2.0.31` at `~/.opencode/bin/opencode` (native ELF,
211 793 376 bytes, sha256 prefix `2df936a20cf74af5`; not on the agent shell's
`PATH`). Rev 2 was proven on `1.19.3`. On 2.0.31 the rev-2 script cannot
work:

| rev-2 assumption | on 2.0.31 | proof |
|---|---|---|
| the key travels in `OPENCODE_AUTH_CONTENT` | **ignored**: with it set, `auth list` → `No authenticated integrations`, and `models` lists only 10 free `opencode/*` ids | `strings -n 8 opencode \| /usr/bin/grep -c '\bOPENCODE_AUTH_CONTENT\b'` → `0` (known positive `OPENCODE_API_KEY` → `2`); offline runs |
| the stored key is `auth.json` | credentials live in `opencode.db`: a dummy key imported into a fake home was found in `opencode.db`, and no file named `auth*` existed | `find <fake home> -name 'auth*'` → nothing; `/usr/bin/grep -l <dummy> …/opencode.db` → the file |
| `run` takes `--pure`, `--dir` | both gone; `run --help` lists `--standalone --server --continue/-c --session/-s --fork --model/-m --agent --format --file/-f --title --thinking --auto` | `opencode run --help`, offline |
| `-f` swallows a message after it (rev-2 P2) | no longer: `run … -f prompt.md "MSG-AFTER"` sent `MSG-AFTER` and the file | fake-model run, server log |
| the tool is `bash`; config keys `permission`, `agent`, `autoupdate` | the tool is `shell`; native keys are `permissions` (a list of `{action, resource, effect}`), `agents`, `update`, `policies`; old keys are migrated (`debug config` prints the migrated form) | `debug config` |
| an error event has `.error.name`, `.error.data.message` | `{"type":"error","sessionID":…,"error":{"type":"provider.transport","message":"…"}}` | offline runs |
| `OPENCODE_DISABLE_LSP_DOWNLOAD` | not in the binary (`grep -c` → `0`) | `strings` |
| `run` reads nothing from stdin | **`run` reads a non-terminal stdin to its end**: with stdin left open it hung until `timeout` (rc 124, no request reached the fake server); with `</dev/null` the same run finished (rc 0) | fake-model runs |
| `--share-net` is acceptable | the user's own OpenCode background service listens on host loopback — `ss -ltnpH` shows `127.0.0.1:<port> … users:(("opencode",pid=…))` — beside other local services (a message broker and two databases on loopback addresses, a web app on all addresses); a shared network reaches all of them | `ss -ltnH` |

## Proven — OpenCode 2.0.31

Every OpenCode run used the user's binary with a **fake `HOME`**, the real home
hidden by a `--tmpfs`, and **no network** (`bwrap --unshare-net`, or a sandbox
whose only interface is its own loopback). Model runs talked to a scripted
fake OpenAI-compatible server inside that sandbox. Keys were placeholders
(`dummy-not-a-key-NN`). No model was called, no real key used, and neither the
user's OpenCode data directory nor its credential store was read.

| # | fact | how |
|---|---|---|
| R1 | `opencode --version` → `opencode v2.0.31`. | offline |
| R2 | Without `--standalone` a command uses, or **starts, a background service**: after `auth list` the fake home held `state/opencode/service.json` with `"url":"http://127.0.0.1:<port>","pid":20` and a password in `config/opencode/service.json`. With `--standalone` the server is private and ends with the command. | `debug paths`; the files |
| R3 | `OPENCODE_API_KEY` is a credential for two integrations — `auth list` → `OpenCode Go  OPENCODE_API_KEY  environment` and `OpenCode Console  OPENCODE_API_KEY  environment` — and `models` then lists 84 `opencode/` and 29 `opencode-go/` ids, the eight of U6 among them. | offline, dummy key |
| R4 | `"enabled_providers": ["opencode-go"]` is migrated to `policies: [{provider.use, *, deny}, {provider.use, opencode-go, allow}]`; `models` then lists the 29 `opencode-go/` ids only, and `run -m opencode/big-pickle` → `{"type":"error",…,"error":{"type":"provider.no-route","message":"Model unavailable: opencode/big-pickle"}}`. The paid provider R3 unlocks cannot be used even by id. | `debug config`, `models`, fake-model run |
| R5 | `auth export opencode-go --standalone` prints `[{"id":…,"integrationID":"opencode-go","label":"default","active":true,"value":{"type":"key","key":"<key>"}}]`, and `[]` with nothing stored. Import from stdin and export did not write the key to `opencode.log` (`/usr/bin/grep -c <dummy>` → `0`; known positive `grep -c 'auth.*export'` → `2`). An argument does get logged: each command's argv is in the log (`message="cli starting" … args="[…]"`), and a dummy key passed to `api … -d` appeared there. | fake home |
| R6 | A project `opencode.json` and `.opencode/` show as config sources; with **either** `OPENCODE_DISABLE_PROJECT_CONFIG=1` or `OPENCODE_CONFIG_PROJECT_DISABLE=1` both are gone, leaving the global directory and the inline `OPENCODE_CONFIG_CONTENT`. | `debug config`, planted project config |
| R7 | Tools offered: with `* allow` — `edit glob grep question read shell skill subagent webfetch websearch write execute`; with the agent's `* deny` plus allow `read glob grep shell` — exactly `glob grep read shell`. A call to a removed tool → `No tool named "edit" is currently available`. `subagent` takes a `model` argument and `execute` takes `code`: both stay denied. | fake-model runs, server log |
| R8 | `read /etc/hostname` under `external_directory: * deny, /tmp/* allow` → `Permission denied: external_directory`; `shell` is not path-checked (`cat /etc/hostname` ran). The permission set is a second layer; the sandbox is the boundary. | fake-model run |
| R9 | In a `shell` call the environment holds `OPENCODE_API_KEY` (and `OPENCODE_CONFIG_CONTENT`, `OPENCODE_SESSION_ID`, …): the model can read the key. | `env \| cut -d= -f1` in a fake-model run |
| R10 | Every `--format json` event carries `sessionID` (`ses_` + 24 characters). Text: `{"type":"text","part":{"type":"text","text":…}}`; tools: `type:"tool_use"`, `part.tool`, `part.state.{status,input,output}`; `step_start`/`step_finish` around them. With **`--thinking`** reasoning arrives as `{"type":"reasoning","part":{"type":"reasoning","text":…}}`; without it, not at all. | fake-model runs |
| R11 | **`--session <id>` continues with context**: the second run's request carried the whole first turn (`system,user,assistant,tool,…,user`, two user messages), and `--continue` a third. `--fork` gives a new id with the history. An unknown id is **created**, not refused (`--session ses_doesnotexist…` answered under that id). | fake-model runs |
| R12 | `session list --standalone --format json` → `[{"id","title","updated","created","projectId",…}]`; `session delete --standalone <id>` → `Session <id> deleted`. Sessions, credentials and logs live under the data dir (`opencode.db`, `log/`, `snapshot/`, `shell/`). `--title` sets the title. | offline |
| R13 | `-f <file>` inlines the file into the user message as `<file name="prompt.md">…</file>`. | server log |
| R14 | With the dummy key, `-m opencode-go/kimi-k3` and no network → `{"type":"error",…,"error":{"type":"provider.transport","message":"getaddrinfo ETIMEOUT opencode.ai"}}`, CLI exit 1; without a key → `provider.no-route`, `Model unavailable: opencode-go/kimi-k3`. No `install` line in the log (`grep -c install` → `0`): rev 2's start-up hang (P11) did not recur. | offline |
| R15 | Under `ulimit -d` 4 GiB and 1 GiB a turn completed; at 256 MiB the CLI aborted (rc 134). Under `ulimit -u` 128 a turn with eight parallel shell children completed; at 64 it aborted (rc 134). | limit probes |

## Proven — the sandbox's network

pasta and slirp4netns were unpacked without root (`apt-get download` +
`dpkg -x` into a throwaway directory; each package's sha256 equals
`apt-cache show`: passt `49eaf773…9840`, slirp4netns `dda3ca51…dd4`, libslirp0
`bfc8e5af…83fb`). Neither is installed on this host.

| # | fact | how |
|---|---|---|
| N1 | **pasta cannot run here unprofiled**: joining a bwrap namespace by PID → `Couldn't switch to pasta namespaces: Operation not permitted`; spawning its own → `Couldn't write to /proc/self/uid_map`. `kernel.apparmor_restrict_unprivileged_userns = 1`, and pasta's AppArmor profile (`usr.bin.pasta`, in the package, not loaded) is what grants it `userns`. Its defaults also open the host: `--map-host-loopback` maps the gateway to host loopback, `-T`/`-U auto` forward the namespace's loopback to host ports, `-t`/`-u auto` expose the namespace's ports on the host (`man pasta`). | pasta runs; man page |
| N2 | bwrap 0.11.1 here puts the network namespace in an **outer** user namespace and the sandbox in an **inner** one: `NS_GET_USERNS` of the sandbox's netns returned the parent of the sandbox's userns. | ioctl probe |
| N3 | **slirp4netns 1.3.3 works unprivileged**, attached by path, with a holder process in the owner userns (`nsenter -t <pid> --user-parent … sleep`): `--configure --mtu=65520 --disable-host-loopback --userns-path=/proc/<holder>/ns/user --netns-type=path /proc/<pid>/ns/net tap0` → ready `1`; inside, `default via 10.0.2.2 dev tap0`, and a TCP connect to `example.com:443` succeeded (nothing sent). `lsns -t net -n -o NS,ONS` names the owner, so the holder is checked, not assumed. `--enable-seccomp` works (it warns `Support for seccomp is experimental`); `--enable-sandbox` failed unprofiled (`parent failed`). A first prototype that read the sandbox pid as soon as bwrap printed it raced bwrap's own setup (`nsenter: reassociate to namespace 'ns/user' failed: Invalid argument`); waiting for the sandbox's command to report in removed the race. | network prototypes |
| N4 | `--disable-host-loopback` alone closes host loopback (`10.0.2.2:<port>` → `Network is unreachable`; the sandbox's `127.0.0.1` is its own) but **leaves every other host address and the LAN open**: a host listener on `0.0.0.0` answered on the host's LAN address and on both of its container-bridge addresses, and the LAN router answered one TCP connect on port 80 (one SYN, no data; later runs used a documentation address instead). | network prototype |
| N5 | **Blackhole routes** — private, CGNAT, link-local, IETF and documentation, benchmarking, multicast and reserved ranges, plus each host address as a `/32` — added through `nsenter --user=<holder> --net=<sandbox>` close them all (the LAN address and both bridge addresses → `Invalid argument`), while DNS through `10.0.2.3` and the internet still work: `10.0.2.0/24` is more specific than `10.0.0.0/8`. The sandboxed process cannot change routes: `ip route add` → `RTNETLINK answers: Operation not permitted`. | network prototype |
| N6 | No host socket reaches the sandbox: `/run` is not mounted, and abstract Unix sockets belong to the network namespace. The resolver inside is `nameserver 10.0.2.3`, bound over the target of `/etc/resolv.conf`. | E06, E10 |
| N7 | **The installed package works the same.** The user installed it on 2026-10-17: `/usr/bin/slirp4netns --version` → `slirp4netns version 1.3.3`, `libslirp: 4.9.1`, `libseccomp: 2.6.0`; `dpkg -s` → `slirp4netns 1.3.3-1`, `libslirp0 4.9.1-1ubuntu1.1`, `install ok installed`; covered by `/etc/apparmor.d/slirp4netns`. With it on `PATH` and no wrapper, the test passed `PASS 36/36` three times in a row (13–14 s), E10 included. | Stage 1b amendment |

**Chosen: slirp4netns** (D24). pasta is rejected: it does not run here without
its AppArmor profile, so nothing about it can be proven before the user
installs it, and its defaults need six switches turned off to stop it
opening the host.

## Proven — copy, limits, lifecycle (the prototype)

The prototype is `plan-r3.md`'s own blocks built into a `git archive 889b804`
copy. Its test passes `PASS 36/36` (three consecutive runs, 13–14 s each, with the
installed slirp4netns; the first prototype used the unpacked package through
a wrapper); `shellcheck` rc 0 on both scripts. `plan-r3.md` *After* records every output.

| # | fact | case |
|---|---|---|
| C1 | The copy is HEAD's tree on its branch with the staged, unstaged and untracked changes; no `.env`, nested repository or hook; unwritable inside even after `chmod u+w`, and `u-w` on the host too. | E06 |
| C2 | With the real repository's config naming a program for `core.fsmonitor`, `filter.evil.clean`/`smudge` (`.gitattributes`: `* filter=evil diff=evil`), `diff.evil.textconv` and `diff.external`, a global config adding `color.ui=always`, `diff.noprefix` and an `init.templateDir` with a hook, and the caller's `GIT_DIR` and `TAR_OPTIONS=--exclude=a.txt`, the copy is still exact and the program **never runs on the host**. Without `-c core.fsmonitor=false`, plumbing alone runs it: a mutant hung in `git … ls-files -s -z` with `/bin/sh …/bin/hostile 2 <token>` as its child (the fsmonitor hook protocol). | E06, E07 |
| C3 | A tar that drops a file during the copy is caught by the byte-for-byte comparison: exit 4, nothing left. | E08 |
| C4 | The real repository is unchanged byte for byte, `.git` and mtimes included, after all 36 cases. | E36 |
| C5 | Inside: `ulimit -f 65536`, `-u 256`, `-d 4194304`; a 70 MiB file and a 300 MiB `/tmp` are refused, 1 MiB is not. `RLIMIT_NPROC` counts the sandbox's user namespace only: at a limit of 32, 30 forks succeeded inside while the user had 75 processes outside (outside, `ulimit -u 64` made the next fork fail). | E13; fork probe |
| C6 | **A subshell between the script and `setpriv` outlived a SIGKILL of the script** and kept three processes running (first prototype, `lp=3`); with `exec setpriv --pdeathsig KILL -- timeout …` as a direct child, a SIGKILL mid-turn leaves none, and `list` shows the agent `broken` until `stop`. | E26 |
| C7 | The first prototype wrote the manager's brief into the transcript unredacted (a brief carrying the key); the transcript now redacts what the manager sent too. | E14 |
| C8 | The real binary, offline: `start --cli ~/.opencode/bin/opencode` with a dummy key in a fake home and a slirp4netns stand-in that wires nothing → exit 7 `BACKEND ERROR: provider.transport: getaddrinfo ETIMEOUT opencode.ai` after 80 s, the session id recorded, the dummy key in no file under the agent (`0`; known positive in the fake `opencode.db`: `1`); `send --timeout 15` → exit 6 after 16 s, no process left; `list`, `stop` → `stopped: <id>`, nothing left. | *After*, the offline block |

## Inferred

- I6. Proven since: N7.
- I7. A real OpenCode Go model answers through the isolated network and
  honours `--session`. `UNVERIFIED: no real call was made — L1b`.
- I8. Reasoning reaches the transcript only from models whose API returns it
  (R10 shows the event shape with a fake reasoning field). Which of the seven
  do: `UNVERIFIED — L1b`.
- Rev-2 I1 is moot (the key is read through `auth export`); I3 (the text of a
  Go limit) and I5 (each family's reading style) stand.

## Kept, changed, dropped — the rev-2 build, per file

Base for rev 3 is a **clean restart from `889b804`** (D22): step R0 archives
the rev-2 build into `plan/feature-opencode-worker/rev2-build/`, then removes
it.

| rev-2 file | rev 3 |
|---|---|
| `plugins/glab/scripts/external-worker.sh` | **replaced** by `external-agent.sh`. Kept: the allowlist and its end date, the profile/section/body/report-section prompt assembly, the reviewer validator and its verdict set, the awk redaction, `die`, the read-only copy and the parentless HEAD commit. Changed: the copy (plumbing + tar + verification instead of `diff`/`apply`/`reset`/`add`), the key (`auth export`, `OPENCODE_API_KEY`), the OpenCode config (2.0.31 keys, provider policy), argv, the error shape, the network (its own namespace), limits, process lifetime, the output format. Dropped: the developer role, the patch, exits 9 SECRET IN OUTPUT and 10 BINARY IN PATCH (the numbers are reused, D29), `--share-net`. |
| `tests/external-worker.test.sh` | **replaced** by `tests/external-agent.test.sh`. Kept: the harness (`w`, `t`, the stub reading its scenario from the attached file, the `date` stub), the allowlist, end-date, verdict-set and profile-census cases. Changed: the stub speaks 2.0.31 and keeps sessions; the fingerprint is a byte-for-byte tar of the real repo. New: send/list/stop, network, hostile git settings, copy verification, limits, busy, stop-while-running, SIGKILL. |
| `plugins/glab/skills/workers/SKILL.md` | **replaced** by `plugins/glab/skills/external-agents/SKILL.md` (start/send/list/stop, untrusted replies, transcripts, the reviewer role); the patch section is dropped. |
| `plugins/glab/skills/workers/profiles/*.md` | **moved** to `skills/external-agents/profiles/`: the four family profiles keep their text with the new script name and "reply"/"transcript" for "report"; `default.md` is rewritten for read-only work. |
| `plugins/glab/skills/manager/SKILL.md` | from `889b804`: the reviewer half of rev 2's Rule 5 edits, reworded for `glab:external-agents` and a `send` correction; a new Rule 6; Stage 5, stage sessions, *What you never do*. Dropped: Rule 1's delivery clause, Stage 2's external developer, the patch boundary sentence. |
| `plugins/glab/commands/develop.md` | **not edited** — there is no external developer. |
| `plugins/glab/commands/review.md`, `ship.md` | from `889b804`: one sentence each for the external reviewer, and `ship.md`'s exit-8 handling as a `send`. |
| `AGENTS.md`, `README.md`, `plugin.json` | from `889b804`: new names, the slirp4netns requirement, the data-exposure paragraph, version `0.4.0`. |

## Rejected

- **pasta** (N1). **A shared network** (rev 2): the user's own OpenCode
  service and other local services are reachable from it.
- **bwrap inside a namespace another tool made** (pasta or `unshare` first):
  an unprofiled creator gets a user namespace without capabilities here (N1).
- **The rev-2 copy** (`git diff | git apply`, `reset --hard`, `add -A`):
  porcelain runs textconv, external diff drivers, filters and fsmonitor that
  the user's or the repository's config names, and its output depends on
  settings (`color`, `noprefix`). Plumbing alone still ran fsmonitor (C2), so
  that is switched off as well.
- **The key as a file in the sandbox** (an `opencode.db` in the agent's home
  holding it): it would be created through the CLI and would persist on disk
  between turns; the variable dies with the process.
- **A key file owned by this plugin**: a second copy of the user's secret;
  `auth export` reads the one OpenCode keeps (R5).
- **`ulimit -v`**: the CLI reserves address space it never touches; `-d`
  binds without that (R15).
- **cgroups through `systemd-run --user`**: needs the user's session bus in an
  environment the script clears, and is not on every host. Total memory is
  stated as not limited instead.
- **Building on the rev-2 build** in place: nearly every hunk is about the
  patch or the developer, so editing it would be a revert in disguise;
  anchoring on `889b804` makes every *before* text checkable with
  `git show 889b804:<file>`.

## Later: Codex

What a `codex` adapter must provide, every Codex fact `UNVERIFIED — not
researched`: `codex_models` (allowlist with profiles), `codex_secret` (the
stored key, read without a command line), `codex_secret_var`, `codex_env`
(config keeping it read-only and on one provider), `codex_argv` (first turn
and continuation by session id, JSON output, prompt as a file, stdin unused),
`codex_session`, `codex_text`, `codex_error`, `codex_render`; one line in
`known_backend`; a stub in the test. Copy, sandbox, network, limits, output,
exit codes and lifecycle are reused unchanged.

## UNVERIFIED, in one place

- I7 a real Go model through the isolated
  network, with `--session`; I8 which models send reasoning; rev-2 I3 the text
  of a Go limit; rev-2 I5 each family's reading style.
- That slirp4netns's own code — which runs outside the sandbox, as the user,
  and parses the sandbox's packets — has no exploitable bug. `--enable-seccomp`
  narrows it; `--enable-sandbox` could not be proven here (N3).
