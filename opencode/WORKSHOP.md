# Dr.C Terminal — LAC 2026 Workshop

Command-line / TUI build for experienced attendees. Pairs with **Dr.C Standalone** (GUI) and **CsoundLive Web**.

> **LAC 2026:** macOS and Linux only.

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

**Participants:** **[GET-STARTED.md](./GET-STARTED.md)** (macOS and Linux).

```bash
git clone https://github.com/mateolarreaferro/Dr.C.git ~/Dr.C
cd ~/Dr.C/opencode
bun install
chmod +x scripts/*.sh launchers/*.sh launchers/*.command
./scripts/launch-drc-terminal.sh
```

Or double-click **`launchers/Dr.C-Terminal.command`** (macOS) or **`launchers/Dr.C-Terminal.sh`** (Linux).

---

## Workshop smoke test

Run on **macOS and Linux** before LAC:

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

## API keys & local models (workshops)

| Path | Notes |
|------|--------|
| **Ollama (local)** | Best free option — [ollama.com/download](https://ollama.com/download) → `ollama pull qwen2.5-coder:7b` → `/settings` → use Ollama |
| Your Anthropic/OpenAI key | Best quality — paste in `/settings` or `drc auth login` |
| Groq / Gemini (free) | Optional backups — rate limits apply |

Full local-LLM handout (models, RAM, troubleshooting): **[Dr.C-Standalone/LOCAL-LLM.md](https://github.com/mateolarreaferro/Dr.C-Standalone/blob/lac-2026-csound7/LOCAL-LLM.md)** (same repo family as Standalone).

**Attendee launcher:** `./scripts/launch-workshop-attendee.sh` (macOS/Linux).

---

## Suggested attendee prompt

Same as Standalone (`WORKSHOP.md` in Dr.C-Standalone):

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

**[GET-STARTED.md](./GET-STARTED.md)** — participant install/download/launch for macOS and Linux.

Standalone workshop notes: `~/Dr.C-Standalone/PARTICIPANTS.md`, `WORKSHOP.md`, `TESTING.md`
