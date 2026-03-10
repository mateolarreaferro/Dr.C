# DrC Architecture Reference

This is the detailed architecture reference for DrC. The agent does NOT need this on every turn — it can `read ARCHITECTURE.md` on demand. For essential conventions, see `CLAUDE.md`.

## Core Source: `packages/opencode/src/`

| Directory | Purpose |
|-----------|---------|
| `agent/` | Agent definitions (csound, csound-sine, csound-synthesis, csound-effects, csound-modulation, build, plan, explore, title, etc.) |
| `session/` | Session management, prompt assembly, message handling, compaction, workspace |
| `tool/` | All tools — bash, read, edit, csound_compile, csound_render, task_parallel, etc. |
| `csound/` | CSD parser, design tree (branching, pruning), param writer, snapshot system |
| `retrieval/` | Hybrid retrieval + RLHF system with pre-computed bundle support |
| `provider/` | LLM provider abstraction (Anthropic, OpenAI, Google, etc.) |
| `cli/cmd/tui/` | Terminal UI components (Solid.js + @opentui) |
| `config/` | Configuration, markdown parsing |
| `plugin/` | Plugin system hooks |

## Session Workspace

All CSD/WAV operations (both new files and edits to existing files) are redirected to `~/.drc/sessions/{sessionID}/temp/`. Users must explicitly Save to copy results to `saved scripts/`. The project directory stays clean.

- `src/session/workspace.ts` — `init()`, `resolve()`, `save()`, `discard()`, `status()`, `cleanup()`
- **Save destination**: `<project root>/saved scripts/` — always creates a new copy, never overwrites (appends `_2`, `_3`, etc. if filename exists)
- UI: "DRAFT" badge in CSD panel header when unsaved changes exist
- Commands: "Save CSD to saved scripts" and "Discard workspace changes" in command palette
- Auto-cleanup: sessions older than 7 days removed on startup
- Events: `workspace.saved`, `workspace.discarded`, `workspace.activated` (BusEvent)

## Two-Column Layout

```
┌─────────────────────────────────┬──────────────────────────────────────────────┐
│  Chat messages (scrollbox)      │  CSD header (filename + save/web/cabbage/play│
│  (~70% of left column)          │  Code view (scrollbox, ~80%)                 │
│                                 │  ─── border ───                              │
│  Prompt                         │  Waveform + Signal Flow (combined, ~20%)     │
│  Session footer (model/tokens)  │  Footer (instr/flow/params/lines)            │
│  ─── border ───                 │                                              │
│  Version History (~30%)         │                                              │
└─────────────────────────────────┴──────────────────────────────────────────────┘
   ~35% width                        ~65% width
```

- **Left column**: `session/index.tsx` — chat (flexGrow=5) + `VersionHistoryPanel` (flexGrow=1, maxHeight=10)
- **Right column**: `session/csd-panel.tsx` — code (flexGrow=4) + combined waveform+signal flow (flexGrow=1)
- **Chat footer**: agent name, model, tokens, %, cost, directory, drC version
- Column widths: CSD panel = `max(40, floor(width * 0.6))`, chat = remainder

## Design Space Explorer

Interactive Csound design exploration with non-destructive branching:

- `src/csound/parser.ts` — CSD parameter extraction (rates, sources, ranges), locked param store
- `src/csound/design-tree.ts` — tree of design exploration paths with snapshot restore, branch naming, soft-delete pruning
- `src/csound/param-writer.ts` — updates param values in CSD files
- `src/tool/csound_propose_alternatives.ts` — presents 2-4 design choices via `Question.ask()`, auto-names branches
- `src/cli/cmd/tui/routes/session/csd-panel.tsx` — CSD panel, version history panel, DRAFT badge, waveform, signal flow, render progress
- `src/cli/cmd/tui/routes/session/dialog-lock-params.tsx` — parameter locking dialog with toggle checkboxes
- `src/cli/cmd/tui/component/waveform-display.tsx` — ASCII waveform envelope renderer
- `src/cli/cmd/tui/component/csd-change-summary.tsx` — semantic diff summary for CSD changes

### Version History

Session-scoped version history tracks all CSD file changes across a session in one timeline:

- Stored at `~/.drc/version-history/<base64(sessionID)>.json`
- Each `CsdVersion` has: `id`, `description`, `snapshotHash`, `timestamp`, `changeSummary`, `csdBasename`, `resolvedPath`
- Auto-populates via 2s polling — detects content hash changes, captures `CsdSnapshot`
- Click any version to restore via `CsdSnapshot.restore()`
- `VersionHistoryPanel` component: exported from `csd-panel.tsx`, used in `index.tsx` below chat

## Multi-Agent Parallel Architecture

Domain-specific sub-agents run concurrently for independent tasks:

| Agent | Specialization | Prompt File |
|-------|---------------|-------------|
| `csound-synthesis` | Oscillators, FM/AM, additive, subtractive, wavetable, physical modeling | `src/session/prompt/csound-synthesis.txt` |
| `csound-effects` | Reverb, delay, filter, distortion, EQ, dynamics, spatialization | `src/session/prompt/csound-effects.txt` |
| `csound-modulation` | Envelopes, LFOs, control signals, scheduling, MIDI/OSC | `src/session/prompt/csound-modulation.txt` |

- `src/tool/task_parallel.ts` — spawns concurrent sub-agents via `Promise.allSettled()`, per-task timeout (default 60s)
- Parallel criteria: 2+ independent dimensions, no shared signal chain, changes to different instruments/sections

## Hybrid Retrieval + RLHF System

Dynamic, per-query knowledge injection from The Csound Book (53K lines):

| File | Role |
|------|------|
| `src/retrieval/knowledge.ts` | Chunks into ~200-400 token semantic chunks with opcode/technique tags |
| `src/retrieval/knowledge-sources.ts` | Registry of sources (multi-source, custom files in `~/.drc/knowledge/custom/`) |
| `src/retrieval/engine.ts` | Orama-based hybrid BM25 + vector, RLHF boost, domain bias, adaptive chunk count |
| `src/retrieval/embeddings.ts` | OpenAI/Voyage embedding with caching; BM25-only fallback |
| `src/retrieval/query-rewriter.ts` | Context-aware query expansion + domain classification |
| `src/retrieval/feedback.ts` | RLHF with 10 signals; EMA scoring with time decay |
| `src/retrieval/format.ts` | Formats chunks as `<csound-reference>` blocks |

**Loading priority**: pre-computed bundle → disk cache → fresh build from sources.
**Data**: `~/.drc/knowledge/` (chunks, index, embeddings, feedback).
**Custom sources**: `.txt`/`.md` in `~/.drc/knowledge/custom/`.

### Feedback Signals

| Signal | Value | Source |
|--------|-------|--------|
| `compile_success` | +1.0 | csound_compile/csound_smoke success |
| `compile_failure` | -0.5 | compile/smoke failure |
| `render_success` | +0.8 | csound_render success |
| `audio_silent` | -0.3 | WAV RMS < -60dB |
| `audio_clipping` | -0.2 | WAV peak > 0.99 |
| `user_thumbs_up` | +1.5 | "Rate retrieval: helpful" command |
| `user_thumbs_down` | -1.5 | "Rate retrieval: not helpful" command |
| `user_revert` | -1.0 | User reverts changes |
| `session_continues` | +0.1 | Default |
| `alternative_selected` | +0.5 | Design alternative chosen |

## Prompt Flow (csound agent, complex mode)

1. `SystemPrompt.environment(model)` — env info + triggers retrieval init + workspace cleanup
2. `InstructionPrompt.system()` — CLAUDE.md, project instructions (skipped in sine mode)
3. Agent prompt (`csound.txt` or `csound-sine.txt`) — behavioral rules
4. **Retrieval injection** — adaptive search, `<csound-reference>` blocks (skipped in sine mode)
5. **Locked param constraints** — `<constraints>` block if params locked
6. `processor.process()` — LLM call with tools
7. **Feedback recording** — compile/render outcomes, audio analysis, chunk score updates

## Parameter Locking

- **Dialog**: "Lock parameters" in command palette → toggle checkboxes
- **Store**: `CsdParser.setLockedParams(sessionID, params)` / `getLockedParams()`
- **Prompt**: `CsdParser.formatLockedConstraints()` → `<constraints>DO NOT modify...</constraints>`
- **Validation**: `apply_csd_patch.ts` checks locked params after patch

## Csound Knowledge Sources

- **The Csound Book** (Boulanger, MIT Press 2000): `csound_book.txt` (53K lines)
- **Csound 7 Anti-Patterns**: `antipatterns.md` — 19 common AI failure modes
- **Csound 7 Syntax Rules**: `syntax-rules.md` — rate system, UDO syntax, control flow
- **Csound 7 Code Patterns**: `patterns.md` — curated templates
- **Custom**: any `.txt`/`.md` in `~/.drc/knowledge/custom/`
