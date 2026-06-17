# Dr.C Terminal — Get Started (LAC 2026)

Command-line / TUI build for shell-native workshop attendees. Pairs with **Dr.C Standalone** (GUI).

> **LAC 2026 supports macOS and Linux only.** Windows is out of scope for this session.

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

> **Ubuntu 22.04 (Jammy):** `apt install csound` gives **6.17**, not 7. Build from source (Option B) or use Csound 7 from [releases](https://github.com/csound/csound/releases) before running `npm run test:workshop`.

```bash
sudo apt update
sudo apt install -y build-essential cmake git libjack-jackd2-dev

# Option A — only if csound --version shows 7.x
sudo apt install -y csound
csound --version

# Option B — build from source (recommended on 22.04)
# https://github.com/csound/csound/blob/develop/BUILD.md
```

Optional user path: `~/Applications/Csound/csound` via `~/bin`.

---

## 2. Install Bun

Dr.C Terminal runs on **Bun**, not Node.

| OS | Install |
|----|---------|
| macOS / Linux | `curl -fsSL https://bun.sh/install \| bash` then reopen terminal |

Verify: `bun --version` → **1.3.9+**

**Linux:** after install, add Bun to your shell profile so new terminals find it:

```bash
echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Workshop launchers prepend `~/.bun/bin` automatically; manual `bun` commands in a fresh shell need the line above.

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

---

## 5. First steps

1. Launcher opens the TUI in your work folder.
2. Type a prompt — e.g. FM synth workshop starter (same as Standalone `WORKSHOP.md`).
3. Use built-in tools: `csound_compile`, `csound_render`, `csound_smoke`.
4. Optional: add API keys via `/auth` or provider settings.

**Offline:** load a `.csd` from disk and compile/render without any API key.

---

## 6. Verify install

```bash
export PATH="$HOME/.bun/bin:$HOME/bin:$HOME/Applications/Csound:$HOME/.local/bin:$PATH"
cd Dr.C/opencode
npm run test:platform
npm run test:workshop
```

Before `test:workshop`, set git identity once (embedded bash unit tests need it on fresh VMs):

```bash
git config --global user.email "workshop@local"
git config --global user.name "Workshop"
```

Optional demo folder (skips if missing): `mkdir -p ~/Dr.C-Workshop-Demo`

**Expected:** platform launcher checks + `12 passed, 0 failed`.

---

## Terminal vs Standalone

| Feature | Terminal | Standalone |
|---------|----------|------------|
| Interface | TUI | Electron GUI |
| Player keyboard | No | Yes |
| Web Apps gallery | Export | Built-in tab |
| Best for | Shell users | Beginners |

Standalone participant guide: [Dr.C-Standalone PARTICIPANTS.md](https://github.com/mateolarreaferro/Dr.C-Standalone/blob/lac-2026-csound7/PARTICIPANTS.md)

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `csound not found` | Re-run Csound install; use workshop launcher (sets PATH) |
| `bun not found` | Install from [bun.sh](https://bun.sh); add `export PATH="$HOME/.bun/bin:$PATH"` to `~/.bashrc` |
| `test:workshop` bash tests fail | Run `git config --global user.name` and `user.email` once |
| Linux apt `csound` is 6.x | Build Csound 7 — Jammy apt is 6.17 |
| `bun install` fails | Bun 1.3.9+; check network for first install |
| Full test suite slow | Use `npm run test:workshop` only (not full `bun test`) |

Instructor docs: `WORKSHOP.md`, `Dr.C-Standalone/TESTING.md`
