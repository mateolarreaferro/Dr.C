# Dr.C Terminal — LAC 2026 Workshop

Command-line / TUI build for experienced attendees. Pairs with **Dr.C Standalone** (GUI) and **CsoundLive Web**.

---

## Version

| Item | Value |
|------|-------|
| Package | `drc` **1.2.5** (`packages/opencode`) |
| Repo | [github.com/mateolarreaferro/Dr.C](https://github.com/mateolarreaferro/Dr.C) |
| Runtime | **Bun 1.3.9+** |
| Csound | **7.x** recommended (`~/bin`, `~/Applications/Csound`) |

---

## Quick start

```bash
git clone https://github.com/mateolarreaferro/Dr.C.git ~/Dr.C
cd ~/Dr.C/opencode
bun install
export PATH="$HOME/bin:$HOME/Applications/Csound:$PATH"
bun run dev -- auth login          # first time only
bun run dev -- ~/lac-workshop-demo # start TUI in demo folder
```

Or double-click **`~/lac-workshop-demo/Dr.C-Terminal.command`**.

---

## Workshop smoke test

```bash
export PATH="$HOME/bin:$HOME/Applications/Csound:$PATH"
cd ~/Dr.C/opencode
npm run test:workshop
```

Checks: Csound 7, `drc --help`, Csound tools, demo CSDs, shared Standalone starters, bash tool unit tests.

**Expected:** `12 passed, 0 failed`.

> Full `bun test` (983 tests) includes upstream network fixtures — use workshop script for LAC gate.

---

## Suggested attendee prompt

Same as Standalone (`WORKSHOP.md` in DRC-Standalone):

```
make a plain Csound CSD only — no Cabbage. Simple 2-operator FM synth with foscili, warm and resonant. Score should demo the instrument: scale, arpeggios, ostinato, closing chord (~12 s).
```

---

## Terminal vs Standalone

| Feature | Terminal | Standalone |
|---------|----------|------------|
| Interface | TUI in terminal | Electron GUI |
| Player (live keyboard) | No — compile/render tools | Yes |
| Web Apps gallery | Export / convert | Built-in tab |
| Offline FM bell demo | Load CSD from disk | One-click workshop buttons |
| Best for | Shell-native devs | Workshop beginners |

---

## Csound tools (built-in)

| Tool | Purpose |
|------|---------|
| `csound_compile` | Syntax check |
| `csound_render` | Offline WAV |
| `csound_smoke` | Short timed run (handles `f0 z` via timeout) |

Skill snippets in `skills/csound/snippets/` use Cabbage + `f0 z` — use smoke tool, not raw long `csound -n`.

---

## External apps

- **Cabbage** — `Open in Cabbage` on CSD panel; detects versioned `Cabbage-2.10.x.app` on macOS
- **CsoundQt 7** — same as Standalone; install separately

---

## Install docs

Full platform steps: `~/dB-Studio/DRC-URLS.C/INSTALL-TERMINAL.md`

Standalone + shared workshop notes: `~/DRC-Standalone/WORKSHOP.md`, `VERSIONS.md`, `TESTING.md`
