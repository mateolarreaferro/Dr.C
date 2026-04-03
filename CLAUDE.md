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

- `src/session/prompt.ts` — prompt assembly, tool resolution, retrieval injection, user profile + memory context
- `src/session/system.ts` — environment info block
- `src/session/prompt/csound.txt` — csound agent behavioral rules
- `src/session/prompt/csound-sine.txt` — lightweight sine mode prompt
- `src/session/prompt/sketch.txt` — sketch pad mode prompt (exploration-first, higher temperature)
- `src/session/prompt/narrator.txt` — educational narrator prompt (computer music history + walkthrough mode)
- `src/session/narration.ts` — NarrationManager: triggers Haiku narration during tool execution, TTS support
- `src/session/processor.ts` — stream event processing, narration triggering, hook triggering
- `src/agent/agent.ts` — agent definitions, permissions, models, sine/complex/sketch modes, narrator agent
- `src/tool/registry.ts` — tool registry with mode-aware filtering (22+ tools in complex mode)
- `src/tool/csound_export_html_template.ts` — web export: player with knobs, keyboard, waveform, signal flow
- `src/tool/csound_export_cabbage.ts` — Cabbage VST/AU/standalone export with auto-generated widgets
- `src/tool/csound_export_scaffold.ts` — web project scaffold + Tauri standalone scaffold
- `src/session/workspace.ts` — session temp directory for CSD/WAV operations
- `src/retrieval/engine.ts` — RAG retrieval with adaptive chunk count
- `src/retrieval/user-profile.ts` — persistent user profile at `~/.drc/profile.json` (expertise, techniques, patterns, sonic refs)
- `src/retrieval/expertise-tracker.ts` — analyzes messages for expertise signals
- `src/retrieval/feedback.ts` — RLHF chunk scoring with EMA
- `src/memory/store.ts` — persistent memory storage (session summaries, sonic identity, technique journals)
- `src/memory/manager.ts` — memory orchestration: auto-summary generation, identity updates, prompt injection
- `src/osc/client.ts` — zero-dependency OSC client over UDP for Ableton integration
- `src/osc/ableton-bridge.ts` — Ableton Live API: sendClip, setParam, createTrack via AbletonOSC
- `src/csound/live-engine.ts` — persistent Csound process with UDP control for real-time parameter tweaking
- `src/analysis/wav-analyzer.ts` — WAV file analysis: RMS, spectral centroid, silence detection
- `src/export/pipeline.ts` — shared export validation and CSD reading pipeline
- `src/educational/lineage-data.ts` — 10 technique lineages (FM, granular, spectral, physical modeling, etc.)
- `src/educational/challenges.ts` — 15 synthesis challenges with compilable starter CSDs
- `src/educational/floss-links.ts` — 100+ opcode → FLOSS manual URL mappings
- `src/server/routes/companion.ts` — web companion UI SPA with waveform viz, knobs, design tree, chat
- `src/server/companion-sync.ts` — WebSocket manager for real-time companion sync
- `src/hook/index.ts` — lifecycle hooks (post-edit, post-render, session-start, pre-export, session-end, post-export)
- `src/hook/builtin.ts` — built-in hooks: auto-compile, profile recording, memory triggers, live engine sync
- `src/cli/cmd/tui/routes/session/csd-panel.tsx` — CSD panel with signal flow diagram
- `src/cli/cmd/tui/component/dialog-build-target.tsx` — build target selection dialog (9 targets)

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
- Memory: all memory operations fire-and-forget, never block prompts or tools
- Channel values: `setControlChannel()` must be called AFTER `csound.start()`, not before

## Modes (Sine vs Complex vs Sketch)

DrC supports three operating modes:

- **Sine mode** (`csound-sine` agent): Haiku model, minimal tools (10 core), no RAG, no sub-agents. For quick edits, param tweaks, bug fixes. ~3,000-4,000 tokens/turn.
- **Complex mode** (`csound` agent): Sonnet model, full tools, RAG retrieval, sub-agents, design exploration. For ambitious synthesis. ~10,000-12,000 tokens/turn.
- **Sketch mode** (`sketch` agent): Sonnet model, temperature 0.8, exploration-first. Generates short 2-4 second sketches, responds to mood/texture descriptions, "surprise me" from historical techniques. Always branches design tree (never overwrites).

## Persistent Memory

Three-layer cross-session memory at `~/.drc/memory/`:

- **Session Summaries** (`sessions/{id}.json`): Auto-generated via Haiku on session end. 3-5 sentences capturing what was built, techniques used, outcome. Last 5 injected into prompt.
- **Sonic Identity** (`identity.json`): Aesthetic preferences, signature signal chains, reference artists, avoidances, opcode frequency. Auto-updated from session messages and CSD content.
- **Technique Journals** (`techniques/{name}.json`): Per-technique entry log with outcomes (success/partial/failed), CSD snippets, lessons. Auto-recorded after 3+ renders or on export.

Injected into system prompt as `<memory>` block via `MemoryManager.promptContext()` (~500 tokens max). Agent can also use the `memory` tool to recall, save, or query identity/journals explicitly.

## Build / Export System

`/build` command offers 9 export targets:

- **Web — Minimal Player**: Self-contained HTML with knobs for k-rate params, piano keyboard (when CSD uses p4), waveform viz, signal flow diagram.
- **Web — Full Synth UI**: Same as minimal but with controls auto-expanded.
- **Web — Project Scaffold**: Exports `{name}-web/` folder with `index.html` + `style.css` + `app.js`.
- **VST/AU Plugin (Cabbage)**: Generates `<Cabbage>` section with auto-generated widgets. Opens in Cabbage if installed.
- **Standalone (Cabbage)**: Same but configured for standalone export.
- **Standalone (Tauri)**: Scaffolds a Tauri project wrapping the web player.
- **Ableton Live Clip**: Sends rendered WAV to Ableton via OSC bridge (requires AbletonOSC).
- **Stems Export**: Per-instrument WAV files from multi-instrument CSDs.
- **Preset Pack**: Bundles design tree variations as a preset bank with JSON manifest.

### Web export CSD rewriting

For keyboard-playable instruments (CSD uses `p4` + `instr`):
- Score events are stripped, replaced with `f 0 3600` (engine stays alive)
- Named instruments renamed to `instr 100` for fractional instance note-off
- Each MIDI note uses `instr 100.{midi}` for independent polyphonic control
- `inputMessage` calls are awaited (Promise-based in `@csound/browser`)

For parameter knobs:
- `kVar = VALUE` assignments detected and rewritten to `kVar chnget "_drc_kVar"`
- `chn_k` declarations injected after `0dbfs`/`seed` line
- Ranges inferred from variable names (cutoff→20-12000, resonance→0-1, etc.)

## Ableton OSC Bridge

Zero-dependency OSC client (`src/osc/client.ts`) with minimal binary encoding over UDP. Connects to AbletonOSC (default `127.0.0.1:11000`). Three tools: `ableton_send_clip`, `ableton_set_param`, `ableton_create_track`. Server routes at `/ableton` for connect/disconnect/status. Connection state broadcast via bus events.

## Live Coding Mode

Persistent Csound process (`src/csound/live-engine.ts`) with `-odac` + `--port=PORT` for real-time audio and UDP control. Per-session port allocation (10000-10100). Three tools: `live_coding_start_stop`, `live_coding_set_channel` (sends `chnset` over UDP), `live_coding_hot_reload` (sends new orchestra via UDP without restart). Process type `"live"` tracked in `CsoundProcessRegistry`.

## Web Companion UI

Self-contained SPA served at `/companion` (before query validator middleware). Dark theme (#0a0a0a bg, #00ff88 accent). Three-panel layout: waveform + audio | CSD code | controls + design tree. WebSocket sync via `CompanionSync` for real-time updates. Accessible via `/companion` slash command in TUI or `ctrl+p` → "Open Web Companion". Auto-connects to active session via `?sessionID=` query param.

## Sketch Pad Mode

Exploration-first creative mode. Four tools: `sketch_mood_palette` (set/query mood descriptors), `sketch_branch_compare` (render 2-4 branches in parallel), `sketch_surprise` (suggest underexplored techniques from RAG), `sketch_reference` (store sonic references for generation context). Design tree extended with `SketchMetadata` (moods, references, tags, surpriseSource).

## Prompt-Free Interactions

Four tools for interacting without explicit prompts: `edit_by_ear` (analyze WAV at timestamp, identify active instrument/event), `suggest_params` (propose parameter changes for a creative direction), `auto_variation` (generate N CSD variations with perturbed params), `gesture_to_envelope` (convert time/value points to linseg/expseg/gen07 code). WAV analysis via `src/analysis/wav-analyzer.ts` (RMS, spectral centroid, silence detection — no external deps).

## Educational Layer

- **Technique Lineage** (`technique_lineage` tool): 10 techniques with full historical chains (FM, granular, spectral, additive, physical modeling, subtractive, wavetable, stochastic, sample-based, ring mod).
- **CSD Walkthrough** (`csd_walkthrough` tool): Line-by-line CSD explanation with FLOSS manual links.
- **Challenges** (`csound_challenge` tool): 15 challenges (5 beginner, 5 intermediate, 5 advanced) with compilable starter CSDs, hints, evaluation criteria.
- **FLOSS Links**: 100+ opcode → `https://flossmanual.csound.com/` URL mappings.

## Educational Narrator

Fires once per assistant turn (30s cooldown) when Csound tools execute. Haiku generates 2-4 sentences about computer music history related to current work. Stored as `NarrationPart` in message DB, rendered as dimmed italic `~ text` in TUI. `/narrate` toggles on/off, `/tts` enables macOS `say` for spoken narration. Supports walkthrough mode for detailed line-by-line annotation.

## User Profile (RLHF)

Persistent at `~/.drc/profile.json`. Tracks:
- `expertiseLevel`: beginner → intermediate → advanced (auto-promotes based on render count)
- `preferredTechniques`: technique → usage count map
- `narrationDepth`: low/medium/high (adjusts based on skip/read signals)
- `sessionPatterns`: recent workflow step sequences
- `favoriteTextures`: mood/texture descriptors across sessions
- `sonicReferences`: reference label → description map
- `challengeProgress`: challenge completion tracking
- `autoVariationEnabled`: toggle for auto-variation generation

Injected into system prompt via `UserProfile.promptContext()` after RAG injection, followed by `MemoryManager.promptContext()`.

See `ARCHITECTURE.md` for full system documentation.
