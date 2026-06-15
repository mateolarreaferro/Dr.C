# Granular Synthesis Models — Workshop Foundation

Curated granular authorities for Dr.C. Users ask about **granular**, **grain**, **partikkel**, **sndwarp** — adapt these before inventing.

**11 models** · RAG IDs `granular-*` · `bundle-granular-models.json`

## Collections

### Ezine — Hans Mikelson (Csound Magazine)
Classic `grain` opcode tutorial: density envelopes, pitch scatter, sampled `limit.wav` source (instr 2).

### GrainMIDI & SndWarpMIDI — Richard Boulanger
MIDI-controlled `grain` and `sndwarp` with `midic7` controllers for density, offsets, warp rate.

### Granular+FM — Kim Ervik / Øyvind Brandtsegg patterns
Three `partikkel` instruments with **FM on grain rate and/or pitch** (`PartikkelArgs.inc` inlined).

### Partikkel+ — Øyvind Brandtsegg
- **Starter kit** — live-input buffer + `partikkel` effect processing (workshop-ready)
- **Oversampling** — anti-aliased granular processing UDOs
- **Hadron partikkel_instr** — full parameter surface from Hadron
- **ImproSculpt** — performance granular suite (reference; large patch)

### Giordani — Truax granular model
Four-voice `timout`/`reinit` grain generators with `oscil1` control functions (Barry Truax-inspired); trapezoid `linseg` grains via `oscili`.

## Priority rule

For granular prompts: prefer `granular-brandtsegg-partikkel-starter-kit` for live-input FX, `granular-boulanger-grainmidi` for classic `grain` opcode, `granular-giordani-truax` for Truax-style timout grains, `granular-fm-grain-rate-and-pitch` for FM grains.

## Models

- **Granula (Csound Magazine)** **(workshop-ready)** — `granular-ezine-granula` — grain, linseg
- **GrainMIDI** **(workshop-ready)** — `granular-boulanger-grainmidi` — ampmidi, cpsmidib, grain, linenr, midic7
- **SndWarpMIDI** — `granular-boulanger-sndwarpmidi` — ampmidi, linenr, midic7, sndwarp
- **FM_Grain_Rate** — `granular-fm-rate` — fof, ftgen, grain, partikkel, phasor, tableng
- **FM_Grain_Pitch** — `granular-fm-pitch` — fof, ftgen, grain, oscili, partikkel, phasor, tableng
- **FM_Grain_Rate_and_Pitch** **(workshop-ready)** — `granular-fm-rate-and-pitch` — fof, ftgen, grain, oscili, partikkel, phasor, tableng
- **Partikkel starter kit (live FX)** **(workshop-ready)** — `granular-brandtsegg-partikkel-starter-kit` — fof, ftgen, grain, partikkel, phasor, tableng, tablewa
- **Granular oversampling UDOs** — `granular-brandtsegg-oversampling` — diskin2, ftgen, hilbert, oscili, oversample
- **Hadron partikkel_instr** — `granular-brandtsegg-hadron-partikkel-instr` — fof, grain, partikkel
- **ImproSculpt 2017** — `granular-brandtsegg-improsculpt` — ampmidi, fof2, fog, ftgen, grain, granule, linenr, linseg
- **Granular Synth v2.1 (Truax model)** **(workshop-ready)** — `granular-giordani-truax` — grain, linseg, oscil1, oscili, rand, timout
