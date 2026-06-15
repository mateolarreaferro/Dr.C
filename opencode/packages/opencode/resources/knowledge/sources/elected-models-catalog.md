# Elected Csound Models — Workshop Foundation

Curated by **Dr. Richard Boulanger** for the LAC 2026 workshop. These six collections are **foundational authorities** — adapt before inventing when a prompt matches their domain.

Bundled CSDs: `resources/knowledge/elected-models/` · RAG IDs: `elected-*` in `bundle-elected-models.json`.

## Priority rule

When retrieval returns an `elected-*` catalog example or this doc, **adapt its opcode wiring and score structure** rather than generating from memory.

## Bass Wobble — Thorin Kerr

Detuned dual gbuzz layers with oscil3 wobble depth, jspline pitch drift, and cubic distort — classic wobble bass.

**Keywords:** wobble, gbuzz, bass, distort, jspline, dubstep
**Opcodes:** gbuzz, jspline, distort, oscil3, linseg, cpspch

**Files:**
- `elected-models/bass-wobble-thorin-kerr/Wobble.csd` → RAG id `elected-bass-wobble-wobble`

## Chinese Instruments — Andrew Horner

Andrew Horner physical models: Dizi (bamboo flute), Sheng (mouth organ), Hulusi (gourd pipe), HornerXing (ensemble piece).

**Keywords:** dizi, sheng, hulusi, chinese, horner, flute, reed, physical model
**Opcodes:** oscil, randi, tablei, linseg, reverb

**Files:**
- `elected-models/chinese-instruments-andrew-horner/Dizi.csd` → RAG id `elected-chinese-dizi`
- `elected-models/chinese-instruments-andrew-horner/HornerXing.csd` → RAG id `elected-chinese-hornerxing`
- `elected-models/chinese-instruments-andrew-horner/Hulusi.csd` → RAG id `elected-chinese-hulusi`
- `elected-models/chinese-instruments-andrew-horner/Sheng.csd` → RAG id `elected-chinese-sheng`

## Deep Note — Steven Yi

THX-style Deep Note: many vco2 voices gliss from high clusters to a low unison with jitter and Moog filter.

**Keywords:** deep note, thx, vco2, moogvcf, jitter, drone, glissando
**Opcodes:** vco2, moogvcf, jitter, linseg, ampdb

**Files:**
- `elected-models/deepnote-steven-yi/deepNote.csd` → RAG id `elected-deepnote-deepnote`

## SuperWaveTerrain — Richard Boulanger

sterrain opcode etude — animated wavetable terrain with rotation LFO and reverbsc space.

**Keywords:** sterrain, terrain, wavetable, docb, superwave
**Opcodes:** sterrain, reverbsc, dcblock, linseg

**Files:**
- `elected-models/sterrain-docb/sterrain2.csd` → RAG id `elected-sterrain-sterrain2`

## Groovish — Jim Aikin

Microtonal generative piece: metro-driven schedkwhen triggers layered sine/FM voices with global form lines.

**Keywords:** groovish, microtonal, schedkwhen, metro, algorithmic, generative
**Opcodes:** schedkwhen, metro, oscil, foscil, reverbsc, pan2, linsegr

**Files:**
- `elected-models/groovish-jim-aikin/groovish.csd` → RAG id `elected-groovish-groovish`

## GendyC — Richard Boulanger (2021)

GendyC etude (2021): stereo gendyc with birnd rate walk, garvb bus, alwayson freeverb master (instr 99).

**Keywords:** gendyc, stochastic, ffitch, freeverb, noise, boulanger
**Opcodes:** gendyc, birnd, freeverb, vincr, alwayson

**Files:**
- `elected-models/gendyc-richard-boulanger/gendycPiece.csd` → RAG id `elected-gendyc-gendycpiece`

## Cross-model patterns

- **Global reverb bus** — GendyC uses `garvbL/R` + `alwayson 99` + `freeverb`; Groovish uses `gaRevL/R` + instr `Reverb`.
- **Named instruments** — Groovish uses string instrument numbers (`instr gControl`, `i "SourceA"`); valid in Csound 7.
- **Long offline scores** — Deep Note and GendyC run 20–90 s; workshop Agent copies should shorten `i` durations.
- **Chinese Horner models** — extensive `p-field` docs in orchestra; preserve parameter comments when adapting.
