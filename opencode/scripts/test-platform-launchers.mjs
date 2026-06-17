#!/usr/bin/env node
/**
 * Cross-platform launcher checks for Dr.C Terminal.
 * Run on each OS to verify launcher files exist.
 *
 * Full workshop smoke (`npm run test:workshop`) is **macOS + Linux only**.
 *
 *   node scripts/test-platform-launchers.mjs
 */

import { existsSync, readFileSync, statSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { spawnSync } from 'node:child_process'

const REPO = dirname(dirname(fileURLToPath(import.meta.url)))
const platform = process.platform

let passed = 0
let failed = 0

function ok(msg) { console.log('  PASS', msg); passed++ }
function bad(msg, detail = '') { console.log('  FAIL', msg, detail); failed++ }
function skip(msg) { console.log('  SKIP', msg) }

const REQUIRED = [
  'GET-STARTED.md',
  'WORKSHOP.md',
  'launchers/README.md',
  'scripts/workshop-path.sh',
  'scripts/workshop-path.ps1',
  'scripts/launch-drc-terminal.sh',
  'scripts/launch-drc-terminal.ps1',
  'scripts/launch-drc-terminal.bat',
  'launchers/Dr.C-Terminal.command',
  'launchers/Dr.C-Terminal.sh',
  'launchers/Dr.C-Terminal.bat',
]

console.log(`\n[terminal-platform-launchers] OS=${platform} arch=${process.arch}\n`)

for (const rel of REQUIRED) {
  if (existsSync(join(REPO, rel))) ok(`exists: ${rel}`)
  else bad(`missing: ${rel}`)
}

const guide = readFileSync(join(REPO, 'GET-STARTED.md'), 'utf-8')
for (const section of ['### macOS', '### Linux']) {
  if (guide.includes(section)) ok(`GET-STARTED.md has ${section}`)
  else bad(`GET-STARTED.md missing ${section}`)
}

if (platform !== 'win32') {
  for (const rel of ['scripts/launch-drc-terminal.sh']) {
    const mode = statSync(join(REPO, rel)).mode & 0o111
    if (mode) ok(`${rel} is executable`)
    else bad(`${rel} not executable — chmod +x ${rel}`)
  }
  const sh = spawnSync('bash', ['-n', join(REPO, 'scripts/launch-drc-terminal.sh')], { encoding: 'utf-8' })
  if (sh.status === 0) ok('bash -n launch-drc-terminal.sh')
  else bad('launch-drc-terminal.sh syntax error', sh.stderr)
}

if (spawnSync('bun', ['--version'], { encoding: 'utf-8' }).status === 0) {
  ok(`bun available: ${spawnSync('bun', ['--version'], { encoding: 'utf-8' }).stdout.trim()}`)
} else skip('bun not on PATH — install before workshop')

const cs = spawnSync('csound', ['--version'], { encoding: 'utf-8' })
if (cs.status === 0) ok(`csound: ${(cs.stdout || cs.stderr || '').split('\n')[0].trim()}`)
else skip('csound not on PATH on this host')

console.log(`\n${passed} passed, ${failed} failed\n`)
process.exit(failed > 0 ? 1 : 0)
