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

**Participants:** **[GET-STARTED.md](./GET-STARTED.md)** (macOS, Linux, Windows).

```bash
git clone https://github.com/mateolarreaferro/Dr.C.git ~/Dr.C
cd ~/Dr.C/opencode
bun install
chmod +x scripts/*.sh launchers/*.sh launchers/*.command   # macOS/Linux
./scripts/launch-drc-terminal.sh
```

Or double-click **`launchers/Dr.C-Terminal.command`** (macOS) or **`launchers/Dr.C-Terminal.bat`** (Windows).

---

## Workshop smoke test

Run on **each OS** before LAC:

```bash
export PATH="$HOME/bin:$HOME/Applications/Csound:$HOME/.local/bin:$PATH"
cd ~/Dr.C/opencode
npm run test:platform
npm run test:workshop
```

Checks: Csound 7, `drc --help`, Csound tools, demo CSDs, shared Standalone starters, bash tool unit tests.

**Expected:** platform launcher checks + `12 passed, 0 failed`.

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

**[GET-STARTED.md](./GET-STARTED.md)** — participant install/download/launch for macOS, Linux, Windows.

Standalone workshop notes: `~/DRC-Standalone/PARTICIPANTS.md`, `WORKSHOP.md`, `TESTING.md`
