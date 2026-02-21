# Additive Synthesis Recipes

## How Additive Works

Additive synthesis builds sounds by summing individual sine wave partials, each with independent control over frequency, amplitude, and phase. This gives maximum timbral precision at the cost of complexity.

## Organ (Drawbar Model)

Hammond-style organ using harmonics at drawbar positions:

```csound
giSine ftgen 0, 0, 8192, 10, 1

instr Organ
  iFreq = p4
  iAmp = p5
  kEnv madsr 0.005, 0.01, 1.0, 0.01  ; near-instant on/off like a real organ

  ; Hammond drawbar positions (16', 5-1/3', 8', 4', 2-2/3', 2', 1-3/5', 1-1/3', 1')
  ; Harmonic numbers:        0.5,  1.5,    1,   2,    3,     4,    5,      6,      8
  ; Drawbar levels 0-8, normalized to 0-1:
  iDraw1 = 0.8   ; 16' (sub-octave)
  iDraw2 = 0.0   ; 5-1/3' (fifth below)
  iDraw3 = 0.7   ; 8' (fundamental)
  iDraw4 = 0.5   ; 4' (octave)
  iDraw5 = 0.0   ; 2-2/3' (octave + fifth)
  iDraw6 = 0.3   ; 2' (2 octaves)
  iDraw7 = 0.0   ; 1-3/5' (2 oct + major third)
  iDraw8 = 0.0   ; 1-1/3' (2 oct + fifth)
  iDraw9 = 0.0   ; 1' (3 octaves)

  a1 oscili iDraw1, iFreq * 0.5, giSine
  a2 oscili iDraw2, iFreq * 1.5, giSine
  a3 oscili iDraw3, iFreq,       giSine
  a4 oscili iDraw4, iFreq * 2,   giSine
  a5 oscili iDraw5, iFreq * 3,   giSine
  a6 oscili iDraw6, iFreq * 4,   giSine
  a7 oscili iDraw7, iFreq * 5,   giSine
  a8 oscili iDraw8, iFreq * 6,   giSine
  a9 oscili iDraw9, iFreq * 8,   giSine

  aOut = (a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9) / 3
  aOut = aOut * kEnv * iAmp

  outs aOut, aOut
endin
```

Presets:
- **Jazz organ**: drawbars 888000000
- **Rock organ**: drawbars 888800000
- **Full organ**: drawbars 888888888
- **Flute stop**: drawbars 008000000
- **Diapason**: drawbars 008800000

## Evolving Additive Timbre

Each partial has its own envelope, creating morphing timbres:

```csound
giSine ftgen 0, 0, 8192, 10, 1

instr EvolvingAdditive
  iFreq = p4
  iAmp = p5

  ; Partial 1 (fundamental) — always present
  kA1 linseg 1, p3*0.3, 0.8, p3*0.7, 1
  a1 oscili kA1, iFreq, giSine

  ; Partial 2 — fades in
  kA2 linseg 0, p3*0.2, 0, p3*0.3, 0.6, p3*0.5, 0.4
  a2 oscili kA2, iFreq * 2, giSine

  ; Partial 3 — pulse in middle
  kA3 linseg 0, p3*0.3, 0, p3*0.1, 0.5, p3*0.2, 0.5, p3*0.1, 0, p3*0.3, 0
  a3 oscili kA3, iFreq * 3, giSine

  ; Partial 4 — inverse of fundamental
  kA4 linseg 0.3, p3*0.3, 0, p3*0.4, 0, p3*0.3, 0.3
  a4 oscili kA4, iFreq * 4, giSine

  ; Partial 5 — bright shimmer
  kA5 oscili 0.15, 0.3  ; tremolo on 5th partial
  kA5 = kA5 + 0.15
  a5 oscili kA5, iFreq * 5, giSine

  ; Partial 7 — subtle odd harmonic color
  kA7 randi 0.1, 2
  kA7 = abs(kA7)
  a7 oscili kA7, iFreq * 7, giSine

  aOut = (a1 + a2 + a3 + a4 + a5 + a7) * iAmp * 0.3

  kEnv madsr 0.5, 0.2, 0.8, 1.0
  outs aOut * kEnv, aOut * kEnv
endin
```

## Spectral Morphing

Crossfade between two harmonic profiles:

```csound
giSine ftgen 0, 0, 8192, 10, 1

; Spectrum A: hollow (odd harmonics only, like clarinet)
giSpecA ftgen 0, 0, 16, -2, 1.0, 0.0, 0.33, 0.0, 0.2, 0.0, 0.14, 0.0, 0.11, 0.0, 0.09, 0.0, 0.07, 0.0, 0.06, 0.0

; Spectrum B: bright (all harmonics, like saw)
giSpecB ftgen 0, 0, 16, -2, 1.0, 0.5, 0.33, 0.25, 0.2, 0.167, 0.14, 0.125, 0.11, 0.1, 0.09, 0.083, 0.07, 0.067, 0.06, 0.058

instr SpectralMorph
  iFreq = p4
  iAmp = p5
  iNumPartials = 16

  kMorph linseg 0, p3*0.4, 0, p3*0.2, 1, p3*0.4, 1

  aOut = 0
  kIdx = 0
  while kIdx < iNumPartials do
    kAmpA table kIdx, giSpecA
    kAmpB table kIdx, giSpecB
    kPartAmp = kAmpA + (kAmpB - kAmpA) * kMorph
    aPartial oscili kPartAmp, iFreq * (kIdx + 1), giSine
    aOut = aOut + aPartial
    kIdx += 1
  od

  aOut = aOut * iAmp * 0.15
  kEnv madsr 0.1, 0.1, 0.8, 0.3
  outs aOut * kEnv, aOut * kEnv
endin
```

## Using buzz/gbuzz for Efficient Additive

When all partials follow a pattern, `buzz`/`gbuzz` is more efficient:

```csound
instr BuzzOrgan
  iFreq = p4
  iAmp = p5
  kEnv madsr 0.01, 0.05, 0.9, 0.05

  ; gbuzz: xamp, xcps, knh, klh, kmul, ifn
  ; knh = number of harmonics, klh = lowest harmonic, kmul = amplitude ratio
  kBright linseg 0.7, p3*0.3, 0.9, p3*0.7, 0.7  ; animate brightness
  aOut gbuzz iAmp, iFreq, 12, 1, kBright, giCosine

  outs aOut * kEnv, aOut * kEnv
endin
```

## Tips

- Keep partial count reasonable (8-32) — more partials = more CPU
- Use `buzz`/`gbuzz` when partials follow a geometric amplitude pattern
- For inharmonic additive (bells, metallic sounds), use non-integer frequency ratios
- Apply a global amplitude envelope after summing all partials
- Consider using `hsboscil` for efficient additive with brightness control
