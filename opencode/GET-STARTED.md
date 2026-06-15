# Dr.C Terminal — Get Started (LAC 2026)

Command-line / TUI build for shell-native workshop attendees. Pairs with **Dr.C Standalone** (GUI).

**Repo:** [github.com/mateolarreaferro/Dr.C](https://github.com/mateolarreaferro/Dr.C)  
**Path:** `Dr.C/opencode`  
**Runtime:** Bun 1.3.9+ · **Csound 7.x**

Workshop knowledge bundles are **included in the repo** — no extra sync step after clone.

---

## 1. Install Csound 7

Verify:

```bash
csound --version
```

Expect **version 7.x**.

### macOS

1. Download from [Csound releases](https://github.com/csound/csound/releases).
2. Install to `~/Applications/Csound/`.
3. Symlink: `mkdir -p ~/bin && ln -sf ~/Applications/Csound/csound ~/bin/csound`
4. If Homebrew Csound 6 shadows CS7: `brew unlink csound`

### Linux (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y build-essential cmake git libjack-jackd2-dev

# Option A — distro package (must be 7.x)
sudo apt install -y csound

# Option B — build from source
# https://github.com/csound/csound/blob/develop/BUILD.md
```

Optional user path: `~/Applications/Csound/csound` via `~/bin`.

### Windows

1. Installer from [csound.com/download.html](https://csound.com/download.html).
2. Ensure `csound.exe` is on **PATH** (reopen terminal after install).
3. Verify: `csound --version`

---

## 2. Install Bun

Dr.C Terminal runs on **Bun**, not Node.

| OS | Install |
|----|---------|
| macOS / Linux | `curl -fsSL https://bun.sh/install \| bash` then reopen terminal |
| Windows | `powershell -c "irm bun.sh/install.ps1 \| iex"` |

Verify: `bun --version` → **1.3.9+**

---

## 3. Download / clone

### Option A — Git clone (recommended for workshop)

```bash
git clone https://github.com/mateolarreaferro/Dr.C.git
cd Dr.C/opencode
bun install
```

### Option B — USB / zip

Copy the `Dr.C` folder, then:

```bash
cd Dr.C/opencode
bun install
```

---

## 4. Launch

### macOS

Double-click **`launchers/Dr.C-Terminal.command`** (after `chmod +x` if needed).

Or Terminal:

```bash
cd Dr.C/opencode
chmod +x scripts/*.sh launchers/*.sh
./scripts/launch-drc-terminal.sh
```

First time only: inside the TUI run **`/auth login`** (or `bun run dev -- auth login`).

### Linux

```bash
cd Dr.C/opencode
chmod +x scripts/*.sh launchers/*.sh
./launchers/Dr.C-Terminal.sh
```

### Windows

Double-click **`launchers\Dr.C-Terminal.bat`**.

Or Command Prompt:

```bat
cd Dr.C\opencode
scripts\launch-drc-terminal.bat
```

Default project folder: `%USERPROFILE%\lac-workshop-demo` (created automatically).

---

## 5. First steps

1. Launcher opens the TUI in your work folder.
2. Type a prompt — e.g. FM synth workshop starter (same as Standalone `WORKSHOP.md`).
3. Use built-in tools: `csound_compile`, `csound_render`, `csound_smoke`.
4. Optional: add API keys via `/auth` or provider settings.

**Offline:** load a `.csd` from disk and compile/render without any API key.

---

## 6. Verify install

### macOS / Linux

```bash
cd Dr.C/opencode
npm run test:platform   # launcher files + PATH contract
npm run test:workshop   # Csound 7, CLI, demo CSDs
```

### Windows (PowerShell)

```powershell
cd Dr.C\opencode
npm run test:platform
npm run test:workshop
```

**Expected workshop gate:** `12 passed, 0 failed` (plus platform launcher checks).

---

## Terminal vs Standalone

| Feature | Terminal | Standalone |
|---------|----------|------------|
| Interface | TUI | Electron GUI |
| Player keyboard | No | Yes |
| Web Apps gallery | Export | Built-in tab |
| Best for | Shell users | Beginners |

Standalone participant guide: [DRC-Standalone PARTICIPANTS.md](https://github.com/mateolarreaferro/DRC-Standalone/blob/lac-2026-csound7/PARTICIPANTS.md)

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `csound not found` | Re-run Csound install; use workshop launcher (sets PATH) |
| `bun not found` | Install from [bun.sh](https://bun.sh); reopen terminal |
| `bun install` fails | Bun 1.3.9+; check network for first install |
| Windows script blocked | Use `.bat` in `launchers/` |
| Full test suite slow | Use `npm run test:workshop` only (not full `bun test`) |

Instructor docs: `WORKSHOP.md`, `DRC-Standalone/TESTING.md`
