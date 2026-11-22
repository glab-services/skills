#!/usr/bin/env node
// Builds the glab-team plugin into one directory (no marketplace: the
// repository's .claude-plugin/marketplace.json lists it).
// Local-path plugins load in place with no dependency install, and copied
// plugins cannot reach files outside their root (plugins/loading.md), so the
// bundle carries channel/, shared/ and node_modules itself.
import { chmodSync, cpSync, existsSync, mkdirSync, readdirSync, realpathSync, renameSync, rmSync, statSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { basename, dirname, join, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
// A build goes into a sibling temp directory and is renamed to its target only
// when every step has passed, so a failed run leaves no half-built output and
// leaves an existing (empty) target as it was. `staging` is set once created.
let staging;
function fail(message) { if (staging) rmSync(staging, { recursive: true, force: true }); process.stderr.write(`build-plugin: ${message}\n`); process.exit(1); }
// realpath of the deepest existing ancestor plus the not-yet-existing rest, so
// a symlink under an admitted root cannot lead the build elsewhere.
function real(path) {
  const rest = [];
  let head = path;
  while (!existsSync(head)) { rest.unshift(basename(head)); head = dirname(head); }
  return join(realpathSync(head), ...rest);
}
const args = process.argv.slice(2);
// Exactly one target: --out <dir>, or --publish for this repository's
// committed plugins/glab-team. --no-install is for the repository's offline
// gate G45, which builds every file outside node_modules without npm or
// claude; the committed copy is validated separately (G23).
const usage = () => { process.stderr.write('build-plugin: use build-plugin.mjs --out <dir> | --publish [--no-install]\n'); process.exit(2); };
let noInstall = false, publish = false, target;
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--no-install' && !noInstall) noInstall = true;
  else if (args[i] === '--publish' && !publish) publish = true;
  else if (args[i] === '--out' && target === undefined && i + 1 < args.length) target = args[++i];
  else usage();
}
if (publish === (target !== undefined)) usage();
// --publish is the one way to the committed plugin: the path is exact, so no
// other plugins/ directory is reachable, and package.json's plugin:build holds
// no "..", which the channel's parent_escape rule would refuse (03-F18).
const out = publish ? resolve(root, '..', '..', 'plugins', 'glab-team') : real(resolve(target)), inside = base => out === base || out.startsWith(base + sep);
// /tmp is a small shared tmpfs on the build machine; --out goes under
// $TMPDIR or the ignored dist/, and never over existing files.
if (!publish) {
  if (inside('/tmp')) fail('refusing /tmp; use $TMPDIR or dist/');
  if (!((process.env.TMPDIR && inside(real(resolve(process.env.TMPDIR)))) || inside(real(join(root, 'dist'))))) fail('--out must be under $TMPDIR or dist/; use --publish for plugins/glab-team');
}
if (existsSync(out)) {
  if (!statSync(out).isDirectory()) fail(`${out} is not a directory`);
  if (readdirSync(out).length) fail(`${out} is not empty; remove it or choose another directory`);
}
mkdirSync(dirname(out), { recursive: true });
staging = `${out}.build-${process.pid}`;
const plugin = staging;
cpSync(join(root, 'plugin'), plugin, { recursive: true });
mkdirSync(join(plugin, 'runtime', 'channel'), { recursive: true });
mkdirSync(join(plugin, 'runtime', 'shared'), { recursive: true });
// runtime/channel and runtime/shared keep the channel's ../shared import valid.
for (const file of readdirSync(join(root, 'channel'))) if (file.endsWith('.mjs')) cpSync(join(root, 'channel', file), join(plugin, 'runtime', 'channel', file));
cpSync(join(root, 'shared', 'address.mjs'), join(plugin, 'runtime', 'shared', 'address.mjs'));
// Apache-2.0 section 4(a) requires a copy of the license with every
// redistribution. The plugin root is copied on its own at install, so its own
// copy is the one that travels.
cpSync(join(root, 'LICENSE'), join(plugin, 'LICENSE'));
const run = (command, argv, options = {}) => spawnSync(command, argv, { stdio: 'inherit', ...options });
if (!noInstall && run('npm', ['ci', '--omit=dev', '--ignore-scripts', '--no-audit', '--no-fund'], { cwd: plugin }).status !== 0) fail('npm ci failed in the plugin root');
for (const file of readdirSync(join(plugin, 'bin'))) chmodSync(join(plugin, 'bin', file), 0o755);
if (!noInstall) {
  const claude = run('claude', ['--version'], { stdio: 'ignore' });
  if (claude.error?.code === 'ENOENT') {
    if (process.env.PLUGIN_VALIDATE_SKIP !== '1') fail('claude is not on PATH; install it or set PLUGIN_VALIDATE_SKIP=1');
    process.stdout.write('SKIP: claude plugin validate (claude not on PATH)\n');
  } else if (run('claude', ['plugin', 'validate', plugin, '--strict']).status !== 0) fail(`claude plugin validate --strict failed for ${out}`);
}
renameSync(staging, out);
staging = undefined;
process.stdout.write(`built ${out}\n`);
