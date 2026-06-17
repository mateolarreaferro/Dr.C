# Dr.C Terminal launchers (macOS & Linux — LAC 2026)

| OS | Double-click / run |
|----|---------------------|
| **macOS** | `Dr.C Mac Terminal.command` or `Dr.C-Terminal.command` |
| **Linux** | `chmod +x Dr.C-Terminal.sh && ./Dr.C-Terminal.sh` |

Desktop symlink (presenter):

```bash
ln -sf "$HOME/Dr.C/opencode/launchers/Dr.C Mac Terminal.command" ~/Desktop/
```

From repo root:

```bash
./scripts/launch-drc-terminal.sh [work-folder]
```

Default work folder: `~/lac-workshop-demo` (created if missing).

Full install steps: **[GET-STARTED.md](../GET-STARTED.md)**

> Windows `.bat` launchers remain in the repo for future use but are **not** part of LAC 2026.
