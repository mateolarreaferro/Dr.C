---
name: csound-templates
description: Ready-to-use Csound .csd templates for common synthesis types — copy, customize, and compile
---

# Csound Templates

Use these templates as starting points. Copy the appropriate template, customize parameters, compile, and render.

## Template Selection

| Goal | Template | Key Customizations |
|---|---|---|
| Analog-style synth (pad/bass/lead) | `synth-subtractive.csd` | Oscillator waveform, filter type/cutoff, envelope |
| FM sounds (bell/brass/epiano) | `synth-fm.csd` | C:M ratio, index envelope, carrier frequency |
| Plucked/bowed string | `synth-waveguide.csd` | Pluck position, damping, excitation type |
| Textures/drones/granular | `synth-granular.csd` | Source table, grain density/duration, pitch scatter |
| Reverb + delay effects chain | `effect-reverb-delay.csd` | Reverb size, delay time/feedback, mix |
| Filter with modulation | `effect-filter.csd` | Filter type, LFO rate/depth, resonance |
| Cabbage synth plugin (with GUI) | `cabbage-synth.csd` | Widgets, channel bindings, synthesis engine |
| Cabbage effect plugin (with GUI) | `cabbage-effect.csd` | Widgets, effect algorithm, I/O routing |

## Customization Workflow

1. Copy the template to your working directory
2. Modify parameters marked with `; <<< CUSTOMIZE` comments
3. Run `csound_compile` to verify
4. Run `csound_render` to hear the result
5. Iterate: adjust parameters, re-render, repeat

## Template Files

All templates are in this directory alongside this SKILL.md file. Each is a complete, compilable .csd that produces sound immediately.
