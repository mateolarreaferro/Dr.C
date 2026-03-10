# DrC

DrC is a fork/rebrand of "opencode" — an AI coding assistant TUI specialized for Csound sound design. Binary: `drc`. All source lives in `opencode/packages/opencode/`.

## Build & Run

```bash
cd opencode/packages/opencode
bun install && bun run build    # build binary
bun run dev                     # dev mode
bun test                        # tests (30s timeout)
```

## Key Files

- `src/session/prompt.ts` — prompt assembly, tool resolution, retrieval injection
- `src/session/system.ts` — environment info block
- `src/session/prompt/csound.txt` — csound agent behavioral rules
- `src/session/prompt/csound-sine.txt` — lightweight sine mode prompt
- `src/agent/agent.ts` — agent definitions, permissions, models, sine/complex modes
- `src/tool/registry.ts` — tool registry with mode-aware filtering
- `src/session/workspace.ts` — session temp directory for CSD/WAV operations
- `src/retrieval/engine.ts` — RAG retrieval with adaptive chunk count

## Workspace Rules

**IMPORTANT**: All CSD/WAV operations redirect to `~/.drc/sessions/{sessionID}/temp/`. All Csound tools (compile, smoke, render, write, apply_csd_patch) MUST resolve paths through `SessionWorkspace.resolve(ctx.sessionID, path)` before file I/O. Users Save to copy results to `saved scripts/`.

## Conventions

- IDs: `Identifier.ascending(prefix)` — fixed prefixes only (message, part, session, etc.)
- k-rate: `kCamelCase`, a-rate: `aCamelCase`, i-rate: `iCamelCase` in CSD files
- Tables: `gi` prefix, UDOs: `PascalCase`, Channels: `lowerCamel`
- Package manager: `bun`
- UI framework: Solid.js with `@opentui/solid`

## Modes (Sine vs Complex)

DrC supports two operating modes for cost control:

- **Sine mode** (`csound-sine` agent): Haiku model, minimal tools (10 core), no RAG, no sub-agents. For quick edits, param tweaks, bug fixes. ~3,000-4,000 tokens/turn.
- **Complex mode** (`csound` agent): Sonnet model, full tools, RAG retrieval, sub-agents, design exploration. For ambitious synthesis. ~10,000-12,000 tokens/turn.

See `ARCHITECTURE.md` for full system documentation.
