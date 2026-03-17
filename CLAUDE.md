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

- `src/session/prompt.ts` — prompt assembly, tool resolution, retrieval injection, user profile context
- `src/session/system.ts` — environment info block
- `src/session/prompt/csound.txt` — csound agent behavioral rules
- `src/session/prompt/csound-sine.txt` — lightweight sine mode prompt
- `src/session/prompt/narrator.txt` — educational narrator prompt (computer music history)
- `src/session/narration.ts` — NarrationManager: triggers Haiku narration during tool execution, TTS support
- `src/session/processor.ts` — stream event processing, narration triggering, hook triggering
- `src/agent/agent.ts` — agent definitions, permissions, models, sine/complex modes, narrator agent
- `src/tool/registry.ts` — tool registry with mode-aware filtering
- `src/tool/csound_export_html_template.ts` — web export: player with knobs, keyboard, waveform, signal flow
- `src/tool/csound_export_cabbage.ts` — Cabbage VST/AU/standalone export with auto-generated widgets
- `src/tool/csound_export_scaffold.ts` — web project scaffold + Tauri standalone scaffold
- `src/session/workspace.ts` — session temp directory for CSD/WAV operations
- `src/retrieval/engine.ts` — RAG retrieval with adaptive chunk count
- `src/retrieval/user-profile.ts` — persistent user profile at `~/.drc/profile.json` (expertise, techniques, patterns)
- `src/retrieval/expertise-tracker.ts` — analyzes messages for expertise signals
- `src/retrieval/feedback.ts` — RLHF chunk scoring with EMA
- `src/hook/index.ts` — lifecycle hooks (post-edit, post-render, session-start, pre-export)
- `src/hook/builtin.ts` — built-in hooks: auto-compile, profile recording, pre-export validation
- `src/cli/cmd/tui/routes/session/csd-panel.tsx` — CSD panel with signal flow diagram
- `src/cli/cmd/tui/component/dialog-build-target.tsx` — build target selection dialog

## Workspace Rules

**IMPORTANT**: All CSD/WAV operations redirect to `~/.drc/sessions/{sessionID}/temp/`. All Csound tools (compile, smoke, render, write, apply_csd_patch) MUST resolve paths through `SessionWorkspace.resolve(ctx.sessionID, path)` before file I/O. Users Save to copy results to `saved scripts/`.

## Conventions

- IDs: `Identifier.ascending(prefix)` — fixed prefixes only (message, part, session, etc.)
- k-rate: `kCamelCase`, a-rate: `aCamelCase`, i-rate: `iCamelCase` in CSD files
- Tables: `gi` prefix, UDOs: `PascalCase`, Channels: `lowerCamel`
- Package manager: `bun`
- UI framework: Solid.js with `@opentui/solid`
- Hooks: `Hook.trigger(lifecycle, ctx)` — fire-and-forget, never block tool execution
- Narration: 30s cooldown per session, runs in parallel, never adds latency
- Channel values: `setControlChannel()` must be called AFTER `csound.start()`, not before

## Modes (Sine vs Complex)

DrC supports two operating modes for cost control:

- **Sine mode** (`csound-sine` agent): Haiku model, minimal tools (10 core), no RAG, no sub-agents. For quick edits, param tweaks, bug fixes. ~3,000-4,000 tokens/turn.
- **Complex mode** (`csound` agent): Sonnet model, full tools, RAG retrieval, sub-agents, design exploration. For ambitious synthesis. ~10,000-12,000 tokens/turn.

## Build / Export System

`/build` command (also visible as "Build ▾" button in session footer) offers 6 export targets:

- **Web — Minimal Player**: Self-contained HTML with knobs for k-rate params, piano keyboard (when CSD uses p4 for freq), waveform viz, signal flow diagram. CSD is rewritten to use `chnget` channels for live knob control.
- **Web — Full Synth UI**: Same as minimal but with controls auto-expanded.
- **Web — Project Scaffold**: Exports `{name}-web/` folder with `index.html` + `style.css` + `app.js` for customization.
- **VST/AU Plugin (Cabbage)**: Generates `<Cabbage>` section with auto-generated rotary knobs/sliders from detected params. Opens in Cabbage if installed.
- **Standalone (Cabbage)**: Same but configured for standalone export.
- **Standalone (Tauri)**: Scaffolds a Tauri project wrapping the web player as a native app.

### Web export CSD rewriting

For keyboard-playable instruments (CSD uses `p4` for frequency):
- Score events are stripped, replaced with `f 0 3600` (engine stays alive)
- Named instruments renamed to `instr 100` for fractional instance note-off
- Each MIDI note uses `instr 100.{midi}` for independent polyphonic control

For parameter knobs:
- `kVar = VALUE` assignments detected and rewritten to `kVar chnget "_drc_kVar"`
- `chn_k` declarations injected after `0dbfs`/`seed` line
- Ranges inferred from variable names (cutoff→20-12000, resonance→0-1, etc.)

## Educational Narrator

Fires once per assistant turn (30s cooldown) when Csound tools execute. Haiku generates 2-4 sentences about computer music history related to current work. Stored as `NarrationPart` in message DB, rendered as dimmed italic `~ text` in TUI. `/narrate` toggles on/off, `/tts` enables macOS `say` for spoken narration.

## User Profile (RLHF)

Persistent at `~/.drc/profile.json`. Tracks:
- `expertiseLevel`: beginner → intermediate → advanced (auto-promotes based on render count)
- `preferredTechniques`: technique → usage count map
- `narrationDepth`: low/medium/high (adjusts based on skip/read signals)
- `sessionPatterns`: recent workflow step sequences

Injected into system prompt via `UserProfile.promptContext()` after RAG injection.

See `ARCHITECTURE.md` for full system documentation.
