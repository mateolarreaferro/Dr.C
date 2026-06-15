#!/usr/bin/env node
//
// Dr.C Terminal — LAC 2026 workshop smoke (CLI / TUI build)
//
//   node scripts/workshop-test.mjs
//
// Checks Csound 7, CLI entrypoint, demo CSDs, and core Csound tools.
// Does NOT run the full upstream opencode unit suite (961 tests — many need network).

import { spawnSync } from 'node:child_process'
import { existsSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const REPO = dirname(dirname(fileURLToPath(import.meta.url)))
const HOME = process.env.HOME ?? process.env.USERPROFILE ?? ''
const DEMO = join(HOME, 'lac-workshop-demo')
const STANDALONE = join(HOME, 'DRC-Standalone')
const TMP = tmpdir()

const lines = []
let passed = 0
let failed = 0

function ok(msg) {
  passed++
  lines.push(`  PASS  ${msg}`)
}
function bad(msg, detail) {
  failed++
  lines.push(`  FAIL  ${msg}${detail ? ` — ${detail}` : ''}`)
}
function section(name) {
  lines.push(`\n[${name}]`)
}

function pathDelimiter() {
  return process.platform === 'win32' ? ';' : ':'
}

function withCsoundPath() {
  const home = process.env.HOME ?? process.env.USERPROFILE ?? ''
  const delim = pathDelimiter()
  const parts = (process.env.PATH ?? '').split(delim).filter(Boolean)
  let extras = []
  if (process.platform === 'win32') {
    const pf = process.env.ProgramFiles ?? 'C:\\Program Files'
    const pfx86 = process.env['ProgramFiles(x86)'] ?? 'C:\\Program Files (x86)'
    const local = process.env.LOCALAPPDATA ?? join(home, 'AppData', 'Local')
    extras = [
      join(home, 'bin'),
      join(local, 'Csound'),
      join(pf, 'Csound'),
      join(pfx86, 'Csound'),
      join(pf, 'Csound-x64'),
    ]
  } else if (process.platform === 'linux') {
    extras = [
      join(home, 'bin'),
      join(home, '.local/bin'),
      join(home, 'Applications/Csound'),
      '/usr/local/bin',
      '/usr/bin',
      '/opt/csound/bin',
      '/snap/bin',
    ]
  } else {
    extras = [
      join(home, 'bin'),
      join(home, 'Applications/Csound'),
      join(home, '.local/bin'),
      '/opt/homebrew/bin',
      '/usr/local/bin',
    ]
  }
  for (const p of extras) {
    if (p && !parts.includes(p)) parts.unshift(p)
  }
  return { ...process.env, PATH: parts.join(delim) }
}

function csound(args, opts = {}) {
  return spawnSync('csound', args, {
    env: withCsoundPath(),
    encoding: 'utf-8',
    timeout: opts.timeout ?? 20_000,
  })
}

function shortenHoldScore(csd) {
  return csd.replace(/<CsScore>([\s\S]*?)<\/CsScore>/i, (_, score) => {
    let s = score
    s = s.replace(/\bf\s+0\s+(\d{3,})\b/gi, 'f 0 1')
    s = s.replace(/\bf0\s+z\b/gi, 'f 0 1')
    s = s.replace(/\bi\s+(\d+)\s+0\s+(\d{3,})\b/gi, 'i $1 0 1')
    return `<CsScore>${s}</CsScore>`
  })
}

section('environment')
const ver = spawnSync('csound', ['--version'], { env: withCsoundPath(), encoding: 'utf-8' })
if (ver.error?.code === 'ENOENT') bad('csound not on PATH')
else if (/version 7/i.test(ver.stdout || ver.stderr || '')) ok('Csound 7 on PATH')
else bad('Csound 7 not detected', (ver.stdout || ver.stderr || '').split('\n')[0])

const bun = spawnSync('bun', ['--version'], { encoding: 'utf-8' })
if (bun.status === 0) ok(`Bun ${(bun.stdout || '').trim()}`)
else bad('bun not installed')

section('CLI entrypoint')
const help = spawnSync('bun', ['run', 'dev', '--', '--help'], { cwd: REPO, encoding: 'utf-8', timeout: 15_000 })
if (help.status === 0 && /drc auth/.test(help.stdout || '')) ok('drc CLI help (auth, run, session)')
else bad('drc CLI help failed', String(help.stderr || help.stdout).slice(0, 120))

section('Csound tools in repo')
const smokeSrc = join(REPO, 'packages/opencode/src/tool/csound_smoke.ts')
const compileSrc = join(REPO, 'packages/opencode/src/tool/csound_compile.ts')
const extApps = join(REPO, 'packages/opencode/src/util/external-apps.ts')
if (existsSync(smokeSrc) && readFileSync(smokeSrc, 'utf-8').includes('CsoundSmokeTool')) ok('csound_smoke tool')
else bad('csound_smoke tool missing')
if (existsSync(compileSrc)) ok('csound_compile tool')
else bad('csound_compile tool missing')
if (existsSync(extApps) && /Cabbage-\d/.test(readFileSync(extApps, 'utf-8'))) ok('versioned Cabbage.app detection')
else bad('external-apps.ts missing versioned Cabbage detection')

section('lac-workshop-demo CSDs')
for (const file of ['pluck_bass.csd', 'pluck_bass_midi.csd']) {
  const path = join(DEMO, file)
  if (!existsSync(path)) {
    lines.push(`  SKIP  ${file} — not at ${DEMO}`)
    continue
  }
  const r = csound(['-n', '-d', '-m0', '-o', join(TMP, 'drc-workshop.wav'), path])
  if (r.status === 0 && !/(\d+)\s+errors in performance/i.test(r.stderr || '')?.[1]) ok(`${file} compiles`)
  else if (r.status === 0) ok(`${file} compiles`)
  else bad(`${file} compile failed`, (r.stderr || '').slice(0, 100))
}

section('standalone workshop starters (shared offline demos)')
if (existsSync(STANDALONE)) {
  const starters = join(STANDALONE, 'resources/workshop-starters')
  for (const file of ['fm_starter.csd', 'fm_bell_starter.csd', 'player_fm_bell.csd']) {
    const path = join(starters, file)
    if (!existsSync(path)) {
      bad(`${file} missing in DRC-Standalone`)
      continue
    }
    let csd = readFileSync(path, 'utf-8')
    if (/player_fm_bell|f\s+0\s+\d{3,}|f0\s+z/i.test(csd)) csd = shortenHoldScore(csd)
    const tmp = join(TMP, `drc-cli-${file}`)
    writeFileSync(tmp, csd)
    const r = csound(['-n', '-d', '-m0', '-o', join(TMP, 'drc-ws.wav'), tmp])
    if (r.status === 0) ok(`${file} compiles (via DRC-Standalone)`)
    else bad(`${file} compile failed`, (r.stderr || '').slice(0, 100))
  }
} else {
  lines.push(`  SKIP  DRC-Standalone not at ${STANDALONE}`)
}

section('targeted unit tests (tool/bash)')
const bashTest = spawnSync('bun', ['test', 'test/tool/bash.test.ts'], {
  cwd: join(REPO, 'packages/opencode'),
  encoding: 'utf-8',
  timeout: 60_000,
})
if (bashTest.status === 0) ok('tool/bash unit tests')
else bad('tool/bash unit tests failed')

lines.push(`\n${passed} passed, ${failed} failed`)
console.log(lines.join('\n'))
process.exit(failed > 0 ? 1 : 0)
