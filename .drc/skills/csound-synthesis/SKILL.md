---
name: csound-synthesis
description: Csound synthesis technique reference — maps sound descriptions to synthesis approaches, parameter ranges, and opcode patterns
---

# Csound Synthesis Knowledge

Use this skill when a user describes a sound they want to create. Match their description to the right synthesis technique and provide working Csound code.

## Quick Decision Tree

| Target Sound | Technique | Start With |
|---|---|---|
| Bell, glockenspiel, chime | FM Synthesis | `foscili`, C:M = 1:1.4, index 8-15 |
| Brass, trumpet | FM Synthesis | `foscili`, C:M = 1:1, index 3-8 |
| Electric piano, DX-style | FM Synthesis | `foscili`, C:M = 1:1 or 1:7, index 2-5 |
| Warm pad, strings | Subtractive | `vco2` saw → `moogladder` |
| Bass (analog) | Subtractive | `vco2` saw/square → `lpf18` |
| Lead synth | Subtractive | `vco2` → `zdf_2pole` |
| Plucked string, guitar | Waveguide | `wgpluck2` or `repluck` |
| Bowed string, violin | Waveguide | `wgbow` |
| Flute, wind | Waveguide | `wgflute` |
| Texture, drone | Granular | `grain3` or `partikkel` |
| Time-stretch | Granular | `sndwarp` or `granule` |
| Vocal, choir | FOF/Formant | `fof` with vowel formants |
| Organ | Additive | Multiple `oscili` or `gbuzz` |
| Spectral morph | Additive | Per-partial envelopes |

## Common Parameter Ranges

### Filter Cutoff (Hz)
- Dark bass: 80–400
- Warm pad: 500–2000
- Bright lead: 2000–8000
- Open/airy: 8000–16000

### FM Index
- Subtle warmth: 0.5–2
- Moderate brightness: 2–5
- Bright metallic: 5–10
- Extreme/harsh: 10–25

### Reverb Send
- Dry/intimate: 0.05–0.15
- Room: 0.15–0.30
- Hall: 0.30–0.60
- Cathedral/wash: 0.60–0.90

### LFO Rates (Hz)
- Subtle drift: 0.05–0.2
- Gentle movement: 0.2–1.0
- Vibrato: 4–7
- Tremolo: 5–10
- Fast wobble: 10–20

## Recipe Files

Detailed synthesis recipes with code examples:
- `recipes/fm-synthesis.md` — FM bells, brass, electric piano
- `recipes/subtractive.md` — Pads, bass, leads with filters
- `recipes/waveguide.md` — Physical modeling strings, winds
- `recipes/granular.md` — Textures, drones, time-stretch
- `recipes/fof-vocal.md` — Vocal/formant synthesis
- `recipes/additive.md` — Organ, spectral, harmonic control

## Reference Files

- `reference/opcodes-extended.md` — Comprehensive opcode listing by category
- `reference/acoustic-principles.md` — Psychoacoustic design principles
