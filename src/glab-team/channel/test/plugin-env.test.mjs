import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { agentCheck, directoryProblem, hookArgs, localError, resolveBinding, unsafeOption } from '../plugin-env.mjs';
import { PLUGIN_DATA_NAME, normaliseUrl } from '../cli.mjs';
import { pluginAdapter } from '../plugin-config.mjs';
import { ChannelError, config } from '../config.mjs';
import { bindProject, credentialScratch, pluginScratch, runChannel, writeProjectFile } from './helpers.mjs';
import { DATA_SUBDIR, messagingDataDir } from '../project-options.mjs';
import { credentialPath } from '../credentials.mjs';

// Plan project-options P-17: resolveBinding replaced pluginEnv. The option
// mapping tests moved to the resolveBinding and hookArgs tests below; this one
// keeps the token-variable check.
test('inherited token variables never reach config next to the token file', t => {
  const s = pluginScratch(t), sentinel = 'tmc_' + 'f'.repeat(32) + '_' + 'S'.repeat(43), url = 'http://127.0.0.1:9', project = join(s.dir, 'p');
  const tokenFile = credentialScratch(s, url); bindProject(project, { url, claudeSession: 'agent', session: 'claude-plugin-abc' });
  const result = resolveBinding({ options: { broker_url: url, token_file: tokenFile, mode: 'push' }, claudeSession: 'agent', projectDir: project, env: { HOME: s.home, XDG_CONFIG_HOME: '', BROKER_TOKEN: sentinel, TEAM_BROKER_TOKEN: sentinel } });
  assert.equal(result.state, 'active');
  assert.equal('BROKER_TOKEN' in result.env, false); assert.equal('TEAM_BROKER_TOKEN' in result.env, false); assert.equal('XDG_CONFIG_HOME' in result.env, false);
  assert.ok(!JSON.stringify(result).includes(sentinel));
  const settings = config(result.env);
  assert.equal(settings.mode, 'push'); assert.equal(settings.session, 'claude-plugin-abc');
  assert.ok(settings.token !== sentinel, 'the token comes from the credential file');
});

const payload = "https://h.example/p'$(echo$IFS'INJECTED-RAN'>&2)'";
test('a broker URL or option that could leave the skills\' shell quotes is refused at join, bind and load', async t => {
  assert.throws(() => normaliseUrl(payload), { code: 'UNSAFE_BROKER_URL' });
  assert.equal(normaliseUrl('https://h.example/a b'), 'https://h.example/a%20b', 'characters URL parsing percent-encodes are safe');
  for (const url of ['https://h.example/a;b', 'https://h.example/$x', 'https://h.example/a|b', 'https://h.example/a(b)', 'https://h.example/a&b']) assert.throws(() => normaliseUrl(url), { code: 'UNSAFE_BROKER_URL' }, url);
  assert.equal(normaliseUrl('http://[::1]:8280/'), 'http://[::1]:8280');
  for (const [key, value] of [['BROKER_URL', payload], ['TOKEN_FILE', "/home/u/x'.token"], ['WORKSPACE', 'a b'], ['TOPIC', "t'$(x)"], ['SESSION_ID', 's;x'], ['MODE', 'poll;x']])
    assert.equal(unsafeOption({ [key]: value }), key, key);
  for (const [key, value] of [['broker_url', payload], ['token_file', "/home/u/x'.token"], ['mode', 'poll;x']])
    assert.deepEqual(resolveBinding({ options: { arm: 'bash', [key]: value } }), { state: 'invalid', code: 'UNSAFE_OPTION', hint: 'A saved plugin option holds characters the plugin refuses; save it again with claude plugin configure.', arm: 'bash' }, key);
  let spawned = 0;
  await assert.rejects(pluginAdapter({ url: payload, workspace: 'w', topic: null, path: '/p.token' }, { spawn: () => { spawned++; return { status: 1 }; }, env: { HOME: '/nonexistent' } }), { code: 'UNSAFE_OPTION' });
  await assert.rejects(pluginAdapter({ url: 'https://h.example', workspace: 'w', topic: null, path: "/x'y.token" }, { spawn: () => { spawned++; return { status: 1 }; }, env: { HOME: '/nonexistent' } }), { code: 'UNSAFE_OPTION' });
  assert.equal(spawned, 0, 'nothing reaches claude plugin configure');
});

test('every skill shell command keeps the widest allowed option values inert', async t => {
  const s = pluginScratch(t), bin = join(s.dir, 'bin'), record = join(s.dir, 'calls.jsonl'), marker = join(s.dir, 'INJECTED-RAN');
  mkdirSync(bin, { mode: 0o700 });
  for (const name of ['glab-team-messaging', 'glab-team-messaging-watch'])
    writeFileSync(join(bin, name), `#!${process.execPath}\nrequire('node:fs').appendFileSync(${JSON.stringify(record)}, JSON.stringify({ name: ${JSON.stringify(name)}, args: process.argv.slice(2), env: Object.fromEntries(Object.entries(process.env).filter(([k]) => k.startsWith('TM_'))) }) + '\\n');\n`, { mode: 0o700 });
  const values = { messaging_broker_url: 'https://h.example:8443/a-b_c.d~e%20/[x]', messaging_token_file: '/home/u/.config/team-messaging/credentials/a-b_c.d~e%2F.token', messaging_mode: 'push', messaging_arm: 'bash' };
  assert.equal(unsafeOption(Object.fromEntries(Object.entries(values).map(([k, v]) => [k.replace(/^messaging_/, '').toUpperCase(), v]))), null, 'these values pass the write and load checks');
  const render = text => text.replace(/\$\{user_config\.([a-z_]+)\}/g, (_, key) => values[key]).replaceAll('${CLAUDE_SESSION_ID}', 'sess-1').replaceAll('${CLAUDE_PLUGIN_DATA}', s.pluginData);
  let commands = 0;
  for (const skill of readdirSync(new URL('../../plugin/skills/', import.meta.url))) {
    const text = readFileSync(new URL(`../../plugin/skills/${skill}/SKILL.md`, import.meta.url), 'utf8');
    for (const [, block] of text.matchAll(/```sh\n([\s\S]*?)```/g)) {
      if (!block.includes('${user_config.')) continue;
      commands++;
      const result = spawnSync('/bin/sh', ['-c', render(block)], { env: { PATH: bin }, encoding: 'utf8', cwd: s.dir });
      assert.equal(result.status, 0, `${skill}: ${result.stderr}`);
    }
  }
  assert.equal(commands, 3, 'claim, status and watch interpolate options into shell commands');
  const calls = readFileSync(record, 'utf8').trim().split('\n').map(line => JSON.parse(line));
  // Plan project-options AM-1: only the credential options; the binding comes from the project file.
  for (const call of calls) assert.deepEqual(call.env, { TM_BROKER_URL: values.messaging_broker_url, TM_TOKEN_FILE: values.messaging_token_file });
  assert.deepEqual(calls.find(call => call.name === 'glab-team-messaging-watch').args, ['--mode', 'bash', '--session-key', 'sess-1', '--claude-session', 'sess-1', '--data-dir', s.data]);
  assert.deepEqual(calls.filter(call => call.name === 'glab-team-messaging').map(call => call.args).sort(), [['claim', '--claude-session', 'sess-1', '--data-dir', s.data], ['status', '--claude-session', 'sess-1', '--data-dir', s.data]]);
  // The reviewer's payload, if it ever reached a skill, would run: this is why it is refused above.
  const unsafe = spawnSync('/bin/sh', ['-c', `TM_BROKER_URL='${payload.replace('>&2', `>${marker}`)}' glab-team-messaging status`], { env: { PATH: bin }, cwd: s.dir });
  assert.equal(unsafe.status, 0); assert.ok(existsSync(marker), 'the control payload executes when not refused');
});

// Plan project-options P-12, P-14, T-6: skills never paste a path into a
// shell. Inside single quotes only ${CLAUDE_SESSION_ID}, ${CLAUDE_PLUGIN_DATA}
// and ${user_config.*} are substituted, and the Bash env has no project path
// (U-6), so the CLI finds the project through the SessionStart record. Only
// the user can start claim.
test('skills quote only the session id, the data dir and saved options, and claim is user-only', () => {
  const skills = readdirSync(new URL('../../plugin/skills/', import.meta.url));
  assert.deepEqual(skills.sort(), ['messaging-bind', 'messaging-claim', 'messaging-join', 'messaging-status', 'messaging-watch']);
  for (const skill of skills) {
    const text = readFileSync(new URL(`../../plugin/skills/${skill}/SKILL.md`, import.meta.url), 'utf8');
    for (const [quoted] of text.matchAll(/'[^'\n]*'/g)) if (quoted.includes('$')) assert.match(quoted, /^'\$\{(CLAUDE_SESSION_ID|user_config\.[a-z_]+)\}'$|^'\$\{CLAUDE_PLUGIN_DATA\}\/messaging'$/, `${skill}: ${quoted}`);
    for (const forbidden of ['$(pwd', '`pwd', '${CLAUDE_PROJECT_DIR}', '$PWD']) assert.ok(!text.includes(forbidden), `${skill}: ${forbidden}`);
    // Every plugin command runs for this Claude session and finds its project itself.
    for (const [, block] of text.matchAll(/```sh\n([\s\S]*?)```/g)) if (/(^|\s)glab-team-messaging(-watch)? /.test(block))
      assert.ok(block.includes("--claude-session '${CLAUDE_SESSION_ID}'") && block.includes("--data-dir '${CLAUDE_PLUGIN_DATA}/messaging'"), `${skill}: ${block}`);
  }
  const claim = readFileSync(new URL('../../plugin/skills/messaging-claim/SKILL.md', import.meta.url), 'utf8');
  assert.match(claim, /^---\nname: messaging-claim\n[\s\S]*?\ndisable-model-invocation: true\n[\s\S]*?---\n/);
  for (const skill of skills.filter(name => name !== 'messaging-claim')) assert.ok(!readFileSync(new URL(`../../plugin/skills/${skill}/SKILL.md`, import.meta.url), 'utf8').includes('disable-model-invocation'), skill);
});

// Decision 148: only the local writable-ancestor error, which carries `dir`,
// passes its hint through. A broker can send any code with any hint text.
test('localError passes through only the local directory hint, and directoryProblem reports only directory codes', () => {
  const local = Object.assign(new ChannelError('INSECURE_CREDENTIAL_DIR', "/h/.claude/plugins is group- or world-writable; run chmod go-w '/h/.claude/plugins'"), { dir: '/h/.claude/plugins' });
  assert.deepEqual(localError(local, 'fallback'), { code: 'INSECURE_CREDENTIAL_DIR', hint: local.hint });
  assert.deepEqual(localError(new ChannelError('INSECURE_CREDENTIAL_DIR', 'broker text'), 'fallback'), { code: 'INSECURE_CREDENTIAL_DIR', hint: 'fallback' });
  assert.deepEqual(localError(Object.assign(new Error('x'), { code: 'INSECURE_CREDENTIAL_DIR', dir: '/x', hint: 'not local' }), 'fallback').hint, 'fallback');
  assert.equal(directoryProblem(localError(local, 'fallback')), `glab-team messaging: INSECURE_CREDENTIAL_DIR: ${local.hint}`);
  assert.equal(directoryProblem({ code: 'DATA_DIR_REQUIRED', hint: 'h' }), 'glab-team messaging: DATA_DIR_REQUIRED: h');
  for (const code of ['BROKER_UNAVAILABLE', 'INSECURE_TOKEN_FILE', undefined]) assert.equal(directoryProblem({ code, hint: 'h' }), null);
});

// Plan project-options AM-1: the hook args carry only the project and data
// directories; "" and an unsubstituted ${...} literal mean unset.
test('hookArgs accepts only --project-dir and --data-dir, each once, and reads options only from CLAUDE_PLUGIN_OPTION_*', () => {
  const env = { CLAUDE_PLUGIN_OPTION_MESSAGING_BROKER_URL: 'https://b.example', CLAUDE_PLUGIN_OPTION_MESSAGING_TOKEN_FILE: '${user_config.messaging_token_file}', CLAUDE_PLUGIN_OPTION_MESSAGING_MODE: '', CLAUDE_PLUGIN_OPTION_MESSAGING_WORKSPACE: 'ignored',
    TM_TOKEN_FILE: '/leak.token', TM_ARM: 'off', TM_WORKSPACE: 'leak', CLAUDE_PLUGIN_OPTION_MESSAGING_SESSION_ID: 'ignored', CLAUDE_PLUGIN_OPTION_MESSAGING_TOPIC: 'ignored' };
  assert.deepEqual(hookArgs(['--project-dir', '/p', '--data-dir', '/d'], env), { projectDir: '/p', dataDir: '/d', options: { broker_url: 'https://b.example', token_file: '', mode: '', arm: '' } });
  assert.deepEqual(hookArgs(['--project-dir', '${CLAUDE_PROJECT_DIR}', '--data-dir', ''], {}), { projectDir: undefined, dataDir: undefined, options: { broker_url: '', token_file: '', mode: '', arm: '' } });
  assert.deepEqual(hookArgs([], {}).options, { broker_url: '', token_file: '', mode: '', arm: '' });
  assert.equal(hookArgs(['--data-dir', '${CLAUDE_PLUGIN_DATA}/messaging'], {}).dataDir, undefined);
  for (const argv of [['--project-dir'], ['--project-dir', '/a', '--project-dir', '/b'], ['--opt-broker_url', 'x'], ['--mode', 'rewake'], ['/p']])
    assert.throws(() => hookArgs(argv, {}), { code: 'INVALID_HOOK_ARGS' }, JSON.stringify(argv));
});

test('resolveBinding never throws and reports one of four states for any input', t => {
  const s = pluginScratch(t), url = 'http://127.0.0.1:9', tokenFile = credentialScratch(s, url), project = join(s.dir, 'p');
  bindProject(project, { url, claudeSession: 'agent' });
  const env = { HOME: s.home }, good = { broker_url: url, token_file: tokenFile, mode: '', arm: '' };
  const cases = [
    [{}, 'invalid', 'PROJECT_UNKNOWN'], [{ options: null }, 'invalid'], [{ options: { arm: 'bogus' } }, 'invalid', 'INVALID_ARM'], [{ options: { broker_url: 42 } }, 'invalid', 'UNSAFE_OPTION'],
    [{ options: good, projectDir: 'relative' }, 'invalid', 'PROJECT_UNKNOWN'], [{ options: good, projectDir: join(s.dir, 'missing') }, 'invalid', 'PROJECT_UNKNOWN'], [{ options: good, projectDir: 7 }, 'invalid', 'PROJECT_UNKNOWN'],
    [{ options: good, projectDir: s.dir, claudeSession: 'agent' }, 'idle'],
    [{ options: good, projectDir: project, claudeSession: undefined }, 'inert', 'SESSION_ID_UNKNOWN'], [{ options: good, projectDir: project, claudeSession: 'a b' }, 'inert', 'SESSION_ID_UNKNOWN'], [{ options: good, projectDir: project, claudeSession: {} }, 'inert', 'SESSION_ID_UNKNOWN'],
    [{ options: good, projectDir: project, claudeSession: 'other' }, 'inert', 'NOT_AGENT_SESSION'],
    [{ options: { ...good, broker_url: '' }, projectDir: project, claudeSession: 'agent' }, 'invalid', 'PLUGIN_NOT_CONFIGURED'],
    [{ options: { ...good, broker_url: 'http://example.com' }, projectDir: project, claudeSession: 'agent' }, 'invalid', 'INSECURE_BROKER_URL'],
    [{ options: good, projectDir: project, claudeSession: 'agent', env: { ...env, NODE_TLS_REJECT_UNAUTHORIZED: '0' } }, 'invalid', 'TLS_VERIFY_DISABLED'],
    [{ options: good, projectDir: project, claudeSession: 'agent' }, 'active'],
  ];
  for (const [input, state, code] of cases) {
    const result = resolveBinding({ env, ...input });
    assert.equal(result.state, state, JSON.stringify(input)); if (code) assert.equal(result.code, code, JSON.stringify(input));
    assert.ok(!JSON.stringify(result).includes('bob-test-token'), 'the token is never returned');
  }
  const active = resolveBinding({ env, options: good, projectDir: project, claudeSession: 'agent' });
  assert.deepEqual(active.env, { BROKER_URL: url, BROKER_TOKEN_FILE: tokenFile, CHANNEL_WORKSPACE: 'default', CHANNEL_SESSION_ID: 'shared-b', CHANNEL_MODE: 'poll', HOME: s.home });
  assert.deepEqual([active.agent, active.root, active.binding], ['agent', project, { workspace: 'default', topic: null, session_id: 'shared-b' }]);
});

// AM-2: the token file must be the join path for this URL, before any read.
test('resolveBinding refuses a token file that is not the join path for the broker URL, before reading it', t => {
  const s = pluginScratch(t), url = 'http://127.0.0.1:9', project = join(s.dir, 'p');
  credentialScratch(s, url); credentialScratch(s, 'http://127.0.0.1:10');
  bindProject(project, { url, claudeSession: 'agent' });
  const env = { HOME: s.home }, run = (broker_url, token_file) => resolveBinding({ env, options: { broker_url, token_file }, projectDir: project, claudeSession: 'agent' });
  assert.equal(run(url, s.tokenFile).code, 'TOKEN_FILE_MISMATCH', 'a hand-named token file');
  assert.equal(run('http://127.0.0.1:10', credentialPath(url, 'bob', { env })).code, 'TOKEN_FILE_MISMATCH', 'the credential of another broker URL');
  // A directory where the token should be: readCredential would say INSECURE_TOKEN_FILE.
  const dirToken = credentialPath(url, 'dir', { env }); mkdirSync(dirToken, { mode: 0o700 });
  assert.equal(run(url, dirToken).code, 'INSECURE_TOKEN_FILE', 'the right path is read');
  assert.equal(run(url, dirToken.replace(/[0-9a-f]{16}-/, '0123456789abcdef-')).code, 'TOKEN_FILE_MISMATCH', 'a wrong path is refused before the read');
  assert.equal(run('http://127.0.0.1:10', credentialPath('http://127.0.0.1:10', 'bob', { env })).code, 'PROJECT_OPTIONS_UNTRUSTED', 'the MAC binds the broker URL');
});

// AM-11 (review round 1): a missing or half-written file read once does not
// demote the agent; two such reads CONFIRM_MS apart do. A trusted file naming
// another agent, or a parsed file whose MAC fails, demotes at once.
test('agentCheck demotes on another agent or a bad MAC at once, and on a missing or partial file only when it persists', t => {
  const s = pluginScratch(t), url = 'http://127.0.0.1:9', tokenFile = credentialScratch(s, url), project = join(s.dir, 'p');
  const file = bindProject(project, { url, claudeSession: 'agent' }), env = { HOME: s.home };
  const resolved = resolveBinding({ env, options: { broker_url: url, token_file: tokenFile }, projectDir: project, claudeSession: 'agent' });
  assert.equal(resolved.state, 'active');
  const good = readFileSync(file, 'utf8');
  let clock = 0;
  const check = () => agentCheck(resolved, { projectDir: project, env, now: () => clock });
  const restore = () => { rmSync(file, { force: true }); writeFileSync(file, good, { mode: 0o600 }); };
  // Absent once, then restored: still the agent.
  let still = check();
  rmSync(file); assert.equal(still(), true, 'one absent read');
  clock = 3000; restore(); assert.equal(still(), true, 'restored before the second read');
  rmSync(file); clock = 5000; assert.equal(still(), true, 'the streak restarted at the good read');
  clock = 8000; assert.equal(still(), true, '3 s later is not yet confirmed');
  clock = 9000; assert.equal(still(), false, 'absent for 4 s: demoted'); restore(); assert.equal(still(), false, 'demotion is final');
  // A partly written file, then the same after 4 s.
  clock = 0; still = check();
  writeFileSync(file, good.slice(0, 40)); assert.equal(still(), true, 'partial once');
  clock = 4000; assert.equal(still(), false, 'partial on two reads 4 s apart'); restore();
  // Another agent, another binding or a failing MAC: at once.
  for (const options of [{ claudeSession: 'other' }, { session: 'another-session' }]) {
    clock = 0; still = check();
    bindProject(project, { url, ...{ claudeSession: 'agent' }, ...options }); assert.equal(still(), false, JSON.stringify(options)); restore();
  }
  clock = 0; still = check();
  bindProject(project, { url, claudeSession: 'agent', mac: 'b'.repeat(64) }); assert.equal(still(), false, 'a parsed file whose MAC fails');
  restore(); still = check();
  writeProjectFile(project, JSON.parse(good).pluginConfigs['glab-team@glab-services'].options, { other: { permissions: {} } });
  assert.equal(still(), true, 'a rewrite that keeps the binding and MAC');
});

// Review round 1: the MCP servers report VERSION, which must match the
// plugin manifests, so a release bump changes one constant and this test.
test('the reported server version is the plugin release', async () => {
  const { VERSION } = await import('../version.mjs');
  const json = path => JSON.parse(readFileSync(new URL(path, import.meta.url), 'utf8'));
  const lock = json('../../plugin/package-lock.json');
  assert.deepEqual([json('../../plugin/.claude-plugin/plugin.json').version, json('../../plugin/package.json').version, lock.version, lock.packages[''].version], [VERSION, VERSION, VERSION, VERSION]);
  assert.equal(VERSION, '0.12.0');
});

// The plugin's files live under <plugin data>/messaging so a later glab-team
// tool (telegram) can keep its own folder beside it. Every manifest passes the
// subfolder as --data-dir, and nothing may write beside it.
test('the plugin keeps its data under messaging/: every hook and skill passes ${CLAUDE_PLUGIN_DATA}/messaging, and a SessionStart run writes nothing beside it', async t => {
  const hooks = JSON.parse(readFileSync(new URL('../../plugin/hooks/hooks.json', import.meta.url), 'utf8')).hooks;
  const commands = Object.values(hooks).flat().flatMap(entry => entry.hooks);
  const dataArgs = commands.flatMap(hook => hook.args.flatMap((arg, i) => arg === '--data-dir' ? [hook.args[i + 1]] : []));
  assert.equal(dataArgs.length, 7, 'every hook passes --data-dir');
  for (const value of dataArgs) assert.equal(value, '${CLAUDE_PLUGIN_DATA}/' + DATA_SUBDIR);
  let skillCommands = 0;
  for (const skill of readdirSync(new URL('../../plugin/skills/', import.meta.url))) {
    const text = readFileSync(new URL(`../../plugin/skills/${skill}/SKILL.md`, import.meta.url), 'utf8');
    for (const [, block] of text.matchAll(/```sh\n([\s\S]*?)```/g)) if (block.includes('--data-dir')) {
      skillCommands++;
      assert.ok(block.includes("--data-dir '${CLAUDE_PLUGIN_DATA}/messaging'"), `${skill}: ${block}`);
    }
  }
  assert.equal(skillCommands, 5, 'every skill command passes --data-dir');
  assert.equal(PLUGIN_DATA_NAME, 'glab-team-glab-services', 'derived from PLUGIN_ID by replacing characters outside [A-Za-z0-9_-]');
  assert.equal(messagingDataDir('/abs'), '/abs/messaging');
  assert.equal(messagingDataDir(undefined), undefined);
  assert.equal(messagingDataDir('rel'), 'rel/messaging');
  // Run the SessionStart hook with its own manifest args, the host's substitutions applied.
  const s = pluginScratch(t), start = commands.find(hook => hook.args.some(arg => arg.endsWith('/plugin-session-start.mjs')));
  const args = start.args.slice(2).map(arg => arg.replaceAll('${CLAUDE_PLUGIN_DATA}', s.pluginData).replaceAll('${CLAUDE_PROJECT_DIR}', s.unbound()));
  const input = JSON.stringify({ hook_event_name: 'SessionStart', session_id: 'sess-data', source: 'startup' });
  const result = await runChannel('plugin-session-start.mjs', args, s.env({ url: 'http://127.0.0.1:9' }), input).result;
  assert.equal(result.code, 0, result.stderr);
  assert.deepEqual(readdirSync(s.pluginData), ['messaging'], 'nothing is written beside messaging/');
});
