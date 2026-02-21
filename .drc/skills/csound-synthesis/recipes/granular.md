# Granular Synthesis Recipes

## How Granular Works

Granular synthesis breaks sound into tiny pieces (grains, typically 10-100ms) and reassembles them with control over density, duration, pitch, and position. This enables time-stretching, pitch-shifting, and textural transformations.

## Basic Granular Texture (grain3)

```csound
giSample ftgen 1, 0, 0, 1, "sample.wav", 0, 0, 0  ; load sample
giWindow ftgen 2, 0, 8192, 20, 2  ; Hanning window

instr GranularTexture
  iAmp = p4
  iPitch = p5  ; pitch ratio (1=normal, 0.5=octave down, 2=octave up)

  ; grain3: kcps, kphs, kfmd, kpmd, kgdur, kdens, imaxovr, ifn, iwfn, ifrpow, iprpow
  ; kcps = pitch (Hz or ratio), kphs = phase/position, kfmd = freq scatter
  ; kpmd = phase scatter, kgdur = grain duration, kdens = grains/sec
  kPos line 0, p3, 1  ; scan through sample
  aOut grain3 iPitch, kPos, 0.02, 0.01, 0.04, 60, 50, giSample, giWindow, 0, 0

  aOut = aOut * iAmp
  outs aOut, aOut
endin
```

## Texture Cloud / Drone

High density, randomized position, for evolving textures:

```csound
giSample ftgen 1, 0, 0, 1, "source.wav", 0, 0, 0
giWindow ftgen 2, 0, 8192, 20, 2

instr TextureCloud
  iAmp = p4

  ; Slow random position scanning
  kPos randi 0.5, 0.1
  kPos = kPos + 0.5  ; center around middle of sample

  ; Subtle pitch scatter for thickness
  kFreqScatter = 0.03

  ; High density, short grains
  aOut grain3 1, kPos, kFreqScatter, 0.15, 0.035, 80, 100, giSample, giWindow, 1, 1

  ; Stereo version with different random seed
  aOut2 grain3 1.002, kPos+0.01, kFreqScatter, 0.15, 0.038, 75, 100, giSample, giWindow, 1, 1

  outs aOut * iAmp, aOut2 * iAmp
endin
```

## Time Stretch (sndwarp)

Stretch time without changing pitch:

```csound
giSample ftgen 1, 0, 0, 1, "sample.wav", 0, 0, 0
giWindow ftgen 2, 0, 8192, 20, 2

instr TimeStretch
  iAmp = p4
  iStretch = p5  ; stretch factor (2 = half speed, 0.5 = double speed)

  ; sndwarp: xamp, xtimewarp, xresample, ifn1, ibeg, iwsize, irandw, ioverlap, ifn2, itimemode
  aOut, aSync sndwarp iAmp, 1/iStretch, 1, giSample, 0, 0.04, 0.01, 8, giWindow, 1

  outs aOut, aOut
endin
```

## Partikkel (Advanced Granular)

`partikkel` is the most feature-rich granular opcode:

```csound
giSample ftgen 1, 0, 0, 1, "sample.wav", 0, 0, 0
giWindow ftgen 2, 0, 8192, 20, 2  ; Hanning
giCosine ftgen 3, 0, 8192, 9, 1, 1, 90  ; cosine for panning

instr PartikkelGrain
  iAmp = p4

  kGrainRate = 60       ; grains per second
  kGrainDur = 0.04      ; grain duration (seconds)
  kPos line 0, p3, 1    ; scan position

  ; Pitch variations
  kPitch = 1            ; base pitch ratio
  kPitchSpread = 0.02   ; random pitch variation

  aOut partikkel kGrainRate, 0, -1, giSample, \
    kPitch, kPitchSpread, 0.5, \
    kGrainDur, 0.5, 0.5, giWindow, \
    -1, kPos, 0, 0, \
    giCosine, 1, 1, -1, -1, \
    0, 0, 0, 0

  outs aOut * iAmp, aOut * iAmp
endin
```

## Granular Parameter Guide

### Grain Density (grains/sec)
- Sparse/rhythmic: 5-15
- Smooth texture: 30-80
- Dense cloud: 80-200
- Ultra-dense: 200-500 (CPU intensive)

### Grain Duration (seconds)
- Tiny/clicky: 0.005-0.015
- Short/percussive: 0.015-0.03
- Medium/smooth: 0.03-0.06
- Long/washy: 0.06-0.15

### Pitch Scatter
- None: 0 (clean)
- Subtle thickness: 0.01-0.03
- Noticeable chorus: 0.03-0.08
- Extreme/noise-like: 0.1-0.5

### Position Scatter
- Focused (time-stretch): 0-0.02
- Moderate: 0.02-0.1
- Wide/textural: 0.1-0.3
- Maximum randomness: 0.3-0.5

### Window Functions (GEN20)
- 1: Hamming — balanced, general purpose
- 2: Hanning — smooth, most common
- 3: Bartlett (triangle) — more attack
- 4: Blackman — very smooth, less energy at edges
- 6: Gaussian — natural sounding, smooth
