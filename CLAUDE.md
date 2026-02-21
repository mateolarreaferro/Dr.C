# DrC

DrC is a fork/rebrand of "opencode" — an AI coding assistant TUI specialized for Csound sound design. Binary: `drc`. All source lives in `opencode/packages/opencode/`.

## Build & Run

```bash
cd opencode/packages/opencode
bun run build        # builds all platform binaries
bun run dev          # dev mode
bun test             # run tests (30s timeout)
bun run scripts/build-knowledge.ts   # pre-compute RAG embeddings bundle
```

## Architecture

### Core Source: `packages/opencode/src/`

| Directory | Purpose |
|-----------|---------|
| `agent/` | Agent definitions (csound, csound-synthesis, csound-effects, csound-modulation, build, plan, explore, title, etc.) |
| `session/` | Session management, prompt assembly, message handling, compaction, workspace |
| `tool/` | All tools — bash, read, edit, csound_compile, csound_render, task_parallel, etc. |
| `csound/` | CSD parser, design tree (branching, pruning), param writer, snapshot system |
| `retrieval/` | Hybrid retrieval + RLHF system with pre-computed bundle support |
| `provider/` | LLM provider abstraction (Anthropic, OpenAI, Google, etc.) |
| `cli/cmd/tui/` | Terminal UI components (Solid.js + @opentui) |
| `config/` | Configuration, markdown parsing |
| `plugin/` | Plugin system hooks |

### Key Files

- **System prompt**: `src/session/prompt.ts` — main loop, prompt assembly (~line 649), tool resolution, retrieval injection, locked param constraints
- **Environment**: `src/session/system.ts` — `SystemPrompt.environment()` builds env info block, triggers retrieval init + workspace cleanup
- **Csound agent prompt**: `src/session/prompt/csound.txt` — behavioral rules, parallel detection instructions
- **Agent config**: `src/agent/agent.ts` — agent definitions, permissions, models (including domain sub-agents)
- **Tool registry**: `src/tool/registry.ts` — resolves available tools per agent
- **Workspace**: `src/session/workspace.ts` — session temp directory for non-destructive experimentation
- **WAV reader**: `src/util/wav-reader.ts` — minimal WAV parser, peak amplitude downsampling

### Session Workspace

All CSD/WAV edits to **existing** files are redirected to `~/.drc/sessions/{sessionID}/temp/`. Users must explicitly Save to copy results back to the project. New file creation goes directly to the project directory.

**IMPORTANT**: Workspace only activates for existing files being modified, never for new file creation. All Csound tools (compile, smoke, render, write, apply_csd_patch) resolve paths through `SessionWorkspace.resolve()`.

- `src/session/workspace.ts` — `init()`, `resolve()`, `save()`, `discard()`, `status()`, `cleanup()`
- UI: "DRAFT" badge in CSD panel header when unsaved changes exist
- Commands: "Save CSD to project" and "Discard workspace changes" in command palette
- Auto-cleanup: sessions older than 7 days removed on startup
- Events: `workspace.saved`, `workspace.discarded`, `workspace.activated` (BusEvent)

### Design Space Explorer

Interactive Csound design exploration with non-destructive branching:

- `src/csound/parser.ts` — CSD parameter extraction (rates, sources, ranges), locked param store
- `src/csound/design-tree.ts` — tree of design exploration paths with snapshot restore, branch naming, soft-delete pruning
- `src/csound/param-writer.ts` — updates param values in CSD files
- `src/tool/csound_propose_alternatives.ts` — presents 2-4 design choices via `Question.ask()`, auto-names branches
- `src/cli/cmd/tui/routes/session/csd-panel.tsx` — always-visible CSD panel (left pane), DRAFT badge, waveform display, render progress
- `src/cli/cmd/tui/routes/session/design-tree-view.tsx` — tree view with visible inactive branches, branch names, pruned filtering
- `src/cli/cmd/tui/routes/session/param-bottom-panel.tsx` — full-width bottom parameter slider panel with keyboard navigation
- `src/cli/cmd/tui/routes/session/dialog-lock-params.tsx` — parameter locking dialog with toggle checkboxes
- `src/cli/cmd/tui/component/waveform-display.tsx` — ASCII waveform envelope renderer (Unicode block chars)
- `src/cli/cmd/tui/component/csd-change-summary.tsx` — semantic diff summary for CSD changes

#### Design Tree Operations

- `DesignNode` fields: `branchName?`, `pruned?` (in addition to existing fields)
- `renameBranch(state, nodeID, name)` — set branch name
- `pruneNode(state, nodeID)` / `unpruneNode()` — soft delete/restore (with descendants)
- `getBranches(state)` — find all leaf nodes, trace paths to root
- `compareBranches(state, nodeA, nodeB)` — diff two snapshots
- `findDescendantByHash(state, nodeID, hash)` — prevent duplicate branch creation
- `getDescendants(state, nodeID)` — all children recursively

#### Slider UI

- `src/cli/cmd/tui/component/terminal-slider.tsx` — keyboard support via `useKeyboard()`: Left/Right fine, Shift+arrows coarse, Home/End min/max
- `src/cli/cmd/tui/routes/session/param-bottom-panel.tsx` — full-width bottom panel with scrollbox, Tab/Shift-Tab cycles focus between sliders
- Layout: column (top row: CSD panel + chat + tree | bottom row: parameter sliders)

### Multi-Agent Parallel Architecture

Domain-specific sub-agents run concurrently for independent tasks:

| Agent | Specialization | Prompt File |
|-------|---------------|-------------|
| `csound-synthesis` | Oscillators, FM/AM, additive, subtractive, wavetable, physical modeling | `src/session/prompt/csound-synthesis.txt` |
| `csound-effects` | Reverb, delay, filter, distortion, EQ, dynamics, spatialization | `src/session/prompt/csound-effects.txt` |
| `csound-modulation` | Envelopes, LFOs, control signals, scheduling, MIDI/OSC | `src/session/prompt/csound-modulation.txt` |

- `src/tool/task_parallel.ts` — takes 2-4 independent tasks, spawns concurrent sub-agents via `Promise.allSettled()`, per-task timeout (default 60s), aggregated results
- Csound agent prompt includes parallel detection criteria (when to use `task_parallel` vs sequential)
- Parallel criteria: 2+ independent dimensions, no shared signal chain, changes to different instruments/sections

### Hybrid Retrieval + RLHF System

Replaces static prompt reference with dynamic, per-query knowledge injection from The Csound Book (53K lines):

| File | Role |
|------|------|
| `src/retrieval/knowledge.ts` | Chunks the Csound Book into ~200-400 token semantic chunks with opcode/technique tags |
| `src/retrieval/knowledge-sources.ts` | Registry of knowledge sources (multi-source, custom user files in `~/.drc/knowledge/custom/`) |
| `src/retrieval/engine.ts` | Orama-based hybrid BM25 + vector search, RLHF boost layer, domain bias, session context, adaptive chunk count |
| `src/retrieval/embeddings.ts` | OpenAI/Voyage embedding with caching; falls back to BM25-only |
| `src/retrieval/query-rewriter.ts` | Context-aware query expansion (last 3 msgs + CSD opcodes + techniques) + domain classification |
| `src/retrieval/feedback.ts` | RLHF with 10 signals: compile, render, audio_silent, audio_clipping, user_thumbs_up/down; EMA scoring with time decay |
| `src/retrieval/audio-feedback.ts` | WAV analysis for audio quality signals (peak, RMS, silent/clipping detection) |
| `src/retrieval/format.ts` | Formats chunks as `<csound-reference>` blocks with confidence metadata |
| `scripts/build-knowledge.ts` | Build-time script to pre-compute embeddings + Orama index bundle |

**Loading priority**: pre-computed bundle (`resources/knowledge/bundle.json`) → disk cache (`~/.drc/knowledge/index.json`) → fresh build from sources.
**Data**: persisted at `~/.drc/knowledge/` (chunks, index, embeddings, feedback).
**Custom sources**: Place `.txt` or `.md` files in `~/.drc/knowledge/custom/` — auto-chunked and merged.
**Init**: lazy, fire-and-forget on first `SystemPrompt.environment()` call.
**Dependency**: `@orama/orama` (TypeScript native, hybrid BM25 + vector).

#### Retrieval Intelligence

- **Query Rewriting**: Raw user query expanded with last 3 user messages, active CSD opcodes, and assistant technique keywords
- **Domain Classification**: Keywords classify intent → `synthesis|effects|modulation|debugging|general`; domain match gives 1.3x boost
- **Adaptive Chunk Count**: Fetches 3x candidates, score dropoff detection (`score[n+1] < 0.4 * score[n]`), clamps [2, 8]; skips injection if `totalScore < 0.1`
- **Session Context**: Tracks last 10 retrieved chunk sections per session; same-section chunks get 1.15x recency boost
- **Confidence**: `high` (top > 0.5), `medium` (top > 0.2), `low`; shown in `<csound-reference>` header and TUI footer

#### Feedback Signals

| Signal | Value | Source |
|--------|-------|--------|
| `compile_success` | +1.0 | csound_compile/csound_smoke success |
| `compile_failure` | -0.5 | compile/smoke failure |
| `render_success` | +0.8 | csound_render success (stronger than compile) |
| `audio_silent` | -0.3 | WAV RMS < -60dB |
| `audio_clipping` | -0.2 | WAV peak > 0.99 |
| `user_thumbs_up` | +1.5 | "Rate retrieval: helpful" command |
| `user_thumbs_down` | -1.5 | "Rate retrieval: not helpful" command |
| `user_revert` | -1.0 | User reverts changes |
| `session_continues` | +0.1 | Default (no compile/render) |
| `alternative_selected` | +0.5 | Design alternative chosen |

### Prompt Flow (csound agent)

1. `SystemPrompt.environment(model)` — env info + triggers retrieval init + workspace cleanup
2. `InstructionPrompt.system()` — CLAUDE.md, project instructions
3. Agent prompt (`csound.txt`) — behavioral rules, CSD template, conventions, parallel detection
4. **Retrieval injection** — rewrites query with context, adaptive search with domain bias, appends `<csound-reference>` with confidence
5. **Locked param constraints** — if params locked, appends `<constraints>` block listing DO NOT MODIFY directives
6. `processor.process()` — LLM call with tools
7. **Feedback recording** — checks render/compile outcomes + audio analysis, updates chunk scores

### Parameter Locking

Users can lock specific CSD parameters to prevent agent modification:

- **Dialog**: "Lock parameters" in command palette → toggle checkboxes for each tuneable param
- **Shared Store**: `CsdParser.setLockedParams(sessionID, params)` / `getLockedParams()` — TUI writes, prompt reads
- **Prompt Injection**: `CsdParser.formatLockedConstraints()` generates `<constraints>DO NOT modify: kCutoff (currently 2000) in instr 1</constraints>`
- **Validation**: `apply_csd_patch.ts` checks locked params after patch, emits warning if values changed
- **KV Signal**: `locked_params` persisted as comma-separated `"instrId:paramName"` keys

### CSD Change Summary

When `apply_csd_patch` targets CSD files, a structured diff summary renders below the inline "Patched file.csd" message:

- Detects new/removed instruments, added/removed opcodes, parameter value changes, function table additions
- Parsed from unified diff lines (no CSD re-read needed)
- Shows up to 6 changes with `+`/`-`/`~` icons, color-coded

### Audio Visualization

- **WAV Reader** (`src/util/wav-reader.ts`): Reads 44-byte header + PCM data, downsamples to N columns of peak amplitudes
- **Waveform Display** (`src/cli/cmd/tui/component/waveform-display.tsx`): Unicode block chars `▁▂▃▄▅▆▇█`, green (<-3dB) / yellow (-3 to -1dB) / red (>-1dB)
- **CSD Panel**: Waveform appears between code scrollbox and footer when `.wav` exists; auto-reloads after render
- **Render Progress**: Elapsed time counter in CSD panel header during `csound_render` ("■ rendering 5s"); WAV duration/format info in tool output

## Conventions

- IDs: `Identifier.ascending(prefix)` — only accepts fixed prefixes (message, part, session, etc.)
- Design tree uses custom `generateNodeID()` since it's not a standard prefix
- k-rate: `kCamelCase`, a-rate: `aCamelCase`, i-rate: `iCamelCase` in CSD files
- Tables: `gi` prefix, UDOs: `PascalCase`, Channels: `lowerCamel`
- Package manager: `bun`
- UI framework: Solid.js with `@opentui/solid`
- Workspace paths: all Csound tools must call `SessionWorkspace.resolve(ctx.sessionID, path)` before file I/O

## Csound Knowledge Sources

- **The Csound Book** (Boulanger, MIT Press 2000): `csound_book.txt` (53K lines, 1.2MB) at project root
- **FLOSS Csound Manual**: `floss_manual.txt` (when available in `resources/knowledge/sources/`)
- **Opcode Reference**: `opcode_reference.txt` (when available in `resources/knowledge/sources/`)
- **Custom**: any `.txt`/`.md` in `~/.drc/knowledge/custom/`
