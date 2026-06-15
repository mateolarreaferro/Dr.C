# Csound Haiku — Generative Ambient Models (Iain McCurdy)

Nine **real-time generative ambient** pieces (2011, exhibited as a sound-installation book). Bundled for the Dr.C workshop as **foundational models** for algorithmic composition without a traditional score.

**RAG IDs:** `mccurdy-haiku-i` … `mccurdy-haiku-ix` in `bundle-mccurdy-haiku.json`

**CSDs:** `resources/knowledge/mccurdy-haiku/`

## Why these are foundational

- Notes are **generated in the orchestra** (`metro`, `schedkwhen`, `schedkwhennamed`, `seqtime`, `event_i`) — no `i` statements in the score except `f 0` hold.
- **`alwayson`** keeps master triggers and `reverb` alive for the whole piece.
- **`rspline` / `jspline`** create natural flowing gestures on pitch, amp, pan, and timbre.
- **`gasendL/R` + `reverbsc`** is the standard Haiku spatial template.

## When to cite Haiku

User asks for: **generative**, **ambient**, **soundscape**, **evolving drone**, **installation**, **no score**, **McCurdy**, **Haiku**, **schedkwhen**, **alwayson generative**.

## Anti-patterns when adapting

- Do not replace `alwayson` + `f 0` with a long `i` score — that breaks the generative design.
- Preserve `seed 0` (or intentional seed) for reproducible installs.
- Named instruments (`instr trombone`, `alwayson "reverb"`) are idiomatic — keep string instrument numbers.
- Workshop **Agent offline render**: use short `f 0 30` hold instead of `f 0 [60*60*24*7]` for test renders only.

## Haiku I — Brass-like gbuzz drones

Six trombone voices: slow transeg glissandi, rspline/jspline timbre motion, global reverb bus.

**Opcodes:** gbuzz, transeg, rspline, jspline, metro, alwayson, reverbsc, event_i
**File:** `mccurdy-haiku/I.csd` → `mccurdy-haiku-i`

## Haiku II — Polyrhythmic inharmonic bells

Layered rhythmic sequences with GEN 9 pseudo-inharmonic spectra and quiet gbuzz shadow.

**Opcodes:** seqtime, metro, oscili, gbuzz, tonea (UDO), ftgen -17, ftgen 9, reverbsc
**File:** `mccurdy-haiku/II.csd` → `mccurdy-haiku-ii`

## Haiku III — Waveguide resonances

wguid2 physical models triggered by metro; spatial vdelay + reverbsc.

**Opcodes:** wguid2, metro, rspline, vdelay, reverbsc, schedkwhen
**File:** `mccurdy-haiku/III.csd` → `mccurdy-haiku-iii`

## Haiku IV — Morphing hsboscil clusters

Periodic gestural hsboscil spectra with ring modulation and rspline window motion.

**Opcodes:** hsboscil, ringmod, rspline, metro, reverbsc
**File:** `mccurdy-haiku/IV.csd` → `mccurdy-haiku-iv`

## Haiku V — Phaser resonances

Struck resonating objects via phaser2 with evolving rspline parameters.

**Opcodes:** phaser2, metro, rspline, reverbsc
**File:** `mccurdy-haiku/V.csd` → `mccurdy-haiku-v`

## Haiku VI — Strummed waveguides

Six wguide1 strings with staggered pink-noise plucks — guitar strum simulation.

**Opcodes:** wguid1, pinkish, metro, schedkwhen, reverbsc
**File:** `mccurdy-haiku/VI.csd` → `mccurdy-haiku-vi`

## Haiku VII — Bell garden

seqtime rhythmic triggers; long_bell oscili partials crossfade with gbuzz_long_note.

**Opcodes:** seqtime, schedkwhennamed, oscili, gbuzz, vdelay, butlp, reverbsc
**File:** `mccurdy-haiku/VII.csd` → `mccurdy-haiku-vii`

## Haiku VIII — Stochastic layers

Probability-driven note layers; Hilbert frequency shift on longer events.

**Opcodes:** schedkwhen, metro, ftgen -17, hilbert, oscili, reverbsc
**File:** `mccurdy-haiku/VIII.csd` → `mccurdy-haiku-viii`

## Haiku IX — Arpeggio clouds

Slow randomh metro rate triggers arpeggio streams with rspline harmonic motion.

**Opcodes:** schedkwhennamed, metro, randomh, rspline, oscili, reverbsc
**File:** `mccurdy-haiku/IX.csd` → `mccurdy-haiku-ix`

## Shared generative template

```csound
gasendL, gasendR init 0
alwayson "trigger_instrument"
alwayson "reverb"
instr reverb
  aL, aR reverbsc gasendL, gasendR, 0.85, 10000
  outs aL, aR
  clear gasendL, gasendR
endin
```
