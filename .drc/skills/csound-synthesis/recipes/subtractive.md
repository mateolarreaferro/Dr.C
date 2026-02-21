# Subtractive Synthesis Recipes

## How Subtractive Works

Start with harmonically rich oscillators (`vco2`), then sculpt the timbre with filters. Envelope the filter cutoff for dynamic timbral changes.

```csound
; Basic subtractive chain:
aSaw vco2 iAmp, iFreq, 0       ; sawtooth (mode 0)
aFilt moogladder aSaw, kCutoff, kRes  ; resonant low-pass
aOut = aFilt * kAmpEnv           ; amplitude envelope
```

## Warm Pad

Detuned oscillators through a gently modulated low-pass filter.

```csound
instr WarmPad
  iFreq = p4
  iAmp = p5
  kAmp madsr 1.5, 0.3, 0.7, 2.0  ; slow attack, long release

  ; Two detuned saws for thickness
  aSaw1 vco2 0.5, iFreq * 0.998
  aSaw2 vco2 0.5, iFreq * 1.002

  ; Slow LFO on filter cutoff for movement
  kLfo oscili 400, 0.15
  kCutoff = 1800 + kLfo

  aMix = aSaw1 + aSaw2
  aFilt moogladder aMix, kCutoff, 0.15
  aOut = aFilt * kAmp * iAmp

  ; Gentle stereo spread
  aL = aOut * 0.6 + aSaw1 * kAmp * iAmp * 0.15
  aR = aOut * 0.6 + aSaw2 * kAmp * iAmp * 0.15
  outs aL, aR
endin
```

Tweaks:
- **Wider**: increase detune to ±0.005–0.01
- **Darker**: drop cutoff to 800–1200
- **More movement**: faster LFO (0.3–0.8 Hz), wider range (±800 Hz)
- **Lush**: add chorus or `reverbsc`

## Bass

Tight, punchy low-end with quick filter envelope.

```csound
instr Bass
  iFreq = p4
  iAmp = p5
  kAmp madsr 0.01, 0.15, 0.6, 0.08

  ; Single saw or square
  aSaw vco2 1, iFreq, 0  ; saw
  ; aSqr vco2 1, iFreq, 2  ; square alternative

  ; Filter envelope: bright attack, settles low
  kFiltEnv expsegr 8000, 0.05, 1200, 0.3, 400, 0.1, 400
  aFilt lpf18 aSaw, kFiltEnv, 0.4, 0.2  ; 303-style filter with distortion

  aOut = aFilt * kAmp * iAmp
  outs aOut, aOut
endin
```

Variations:
- **Sub bass**: iFreq in 30-80 Hz range, cutoff 200-500, low resonance
- **Acid bass**: `lpf18` with res 0.6-0.8, high filter envelope sweep
- **Reese bass**: two detuned saws, no filter, slight phaser
- **Pluck bass**: very fast filter envelope (0.01s decay)

## Lead Synth

Saw lead with portamento and moderate filtering.

```csound
instr Lead
  iFreq = p4
  iAmp = p5
  kAmp madsr 0.02, 0.1, 0.8, 0.15

  ; Portamento for legato feel
  kFreq port cpsmidinn(p4), 0.05

  ; Saw with sub-octave for body
  aSaw vco2 0.7, kFreq, 0
  aSub vco2 0.3, kFreq * 0.5, 2  ; square sub

  kCutoff = 3500
  aMix = aSaw + aSub
  aFilt zdf_2pole aMix, kCutoff, 0.3, 0  ; LP mode

  aOut = aFilt * kAmp * iAmp
  outs aOut, aOut
endin
```

Note: For portamento to work across notes, use legato mode (MIDI or overlapping score events).

## Strings Ensemble

Multiple detuned saws with slow chorus and gentle filtering.

```csound
instr Strings
  iFreq = p4
  iAmp = p5
  kAmp madsr 0.8, 0.2, 0.85, 1.0

  ; Three detuned voices per channel
  aSaw1 vco2 0.33, iFreq * 0.997
  aSaw2 vco2 0.33, iFreq
  aSaw3 vco2 0.33, iFreq * 1.003

  aSaw4 vco2 0.33, iFreq * 0.995
  aSaw5 vco2 0.33, iFreq * 1.001
  aSaw6 vco2 0.33, iFreq * 1.005

  aL = aSaw1 + aSaw2 + aSaw3
  aR = aSaw4 + aSaw5 + aSaw6

  ; Gentle filtering
  aL moogladder aL, 4000, 0.05
  aR moogladder aR, 4000, 0.05

  outs aL * kAmp * iAmp, aR * kAmp * iAmp
endin
```

## Filter Types Comparison

| Filter | Character | Best For |
|---|---|---|
| `moogladder` | Warm, classic, musical resonance | Pads, leads, general use |
| `lpf18` | Aggressive, squelchy, has built-in distortion | Acid bass, aggressive leads |
| `zdf_2pole` | Clean, precise, multiple modes (LP/HP/BP) | Clean leads, surgical filtering |
| `zdf_ladder` | Clean ladder character | Modern analog emulation |
| `butterlp` | Transparent, no resonance | Gentle high-cut, mastering |
| `resonz` | Bandpass with bandwidth control | Formant-like effects, resonances |

## vco2 Waveform Modes

- Mode 0: Sawtooth (brightest, most harmonics)
- Mode 2: Square/pulse
- Mode 4: Triangle (fewer harmonics, softer)
- Mode 8: Integrated sawtooth
- Mode 10: Square (no PWM)
- Mode 12: Triangle (no DC)
