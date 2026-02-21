# FOF / Formant Synthesis Recipes

## How FOF Works

FOF (Fonction d'Onde Formantique) generates formant peaks — the resonant frequencies that give vowels and vocal sounds their character. Each formant is a damped sinusoidal grain. Stack 3-5 formants to create vowel sounds.

## Vowel Formant Table

| Vowel | Example | F1 (Hz) | F2 (Hz) | F3 (Hz) | F4 (Hz) | F5 (Hz) |
|---|---|---|---|---|---|---|
| /a/ | father | 800 | 1150 | 2800 | 3500 | 4950 |
| /e/ | bet | 400 | 1600 | 2700 | 3300 | 4950 |
| /i/ | beet | 350 | 2300 | 3000 | 3700 | 4950 |
| /o/ | go | 450 | 800 | 2830 | 3500 | 4950 |
| /u/ | boot | 325 | 700 | 2530 | 3500 | 4950 |

Formant amplitudes (dB relative to F1):

| Vowel | A1 | A2 | A3 | A4 | A5 |
|---|---|---|---|---|---|
| /a/ | 0 | -4 | -20 | -36 | -60 |
| /e/ | 0 | -24 | -30 | -35 | -60 |
| /i/ | 0 | -20 | -16 | -20 | -60 |
| /o/ | 0 | -9 | -16 | -28 | -55 |
| /u/ | 0 | -12 | -26 | -26 | -44 |

Formant bandwidths (Hz):

| Vowel | BW1 | BW2 | BW3 | BW4 | BW5 |
|---|---|---|---|---|---|
| /a/ | 80 | 90 | 120 | 130 | 140 |
| /e/ | 60 | 80 | 100 | 120 | 120 |
| /i/ | 40 | 90 | 100 | 110 | 120 |
| /o/ | 70 | 80 | 100 | 130 | 135 |
| /u/ | 50 | 60 | 170 | 180 | 200 |

## Basic Vowel Sound

```csound
giSine ftgen 0, 0, 8192, 10, 1
giSigmoid ftgen 0, 0, 8192, 19, 0.5, 0.5, 270, 0.5  ; attack shape

instr Vowel
  iFreq = p4  ; fundamental frequency
  iAmp = p5

  ; /a/ vowel (father) — 3 formants
  ; fof: xamp, xfund, xform, koct, kband, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur
  a1 fof iAmp,     iFreq, 800,  0, 80,  0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a2 fof iAmp*0.6, iFreq, 1150, 0, 90,  0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a3 fof iAmp*0.1, iFreq, 2800, 0, 120, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3

  aOut = a1 + a2 + a3
  kEnv madsr 0.1, 0.1, 0.8, 0.3
  outs aOut * kEnv, aOut * kEnv
endin
```

## Vowel Morphing

Crossfade between vowel formant sets:

```csound
instr VowelMorph
  iFreq = p4
  iAmp = p5

  ; Morph position (0=vowel A, 1=vowel B)
  kMorph linseg 0, p3*0.4, 0, p3*0.2, 1, p3*0.4, 1

  ; /a/ formants
  iF1a = 800
  iF2a = 1150
  iF3a = 2800

  ; /i/ formants
  iF1b = 350
  iF2b = 2300
  iF3b = 3000

  ; Interpolate
  kF1 = iF1a + (iF1b - iF1a) * kMorph
  kF2 = iF2a + (iF2b - iF2a) * kMorph
  kF3 = iF3a + (iF3b - iF3a) * kMorph

  a1 fof iAmp,     iFreq, kF1, 0, 80,  0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a2 fof iAmp*0.5, iFreq, kF2, 0, 90,  0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a3 fof iAmp*0.1, iFreq, kF3, 0, 120, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3

  aOut = a1 + a2 + a3

  ; Add vibrato for realism
  kVib oscili 0.01 * iFreq, 5.5
  ; Re-render with vibrato applied to fundamental
  ; (In practice, pass iFreq+kVib to fof)

  kEnv madsr 0.15, 0.1, 0.8, 0.4
  outs aOut * kEnv, aOut * kEnv
endin
```

## Choir Effect

Layer multiple FOF voices with slight detuning and timing offsets:

```csound
instr Choir
  iFreq = p4
  iAmp = p5
  kEnv madsr 0.3, 0.2, 0.7, 0.5

  ; Voice 1 (center)
  kVib1 oscili 0.008*iFreq, 5.2
  a1a fof iAmp*0.3, iFreq+kVib1, 800,  0, 80, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a1b fof iAmp*0.2, iFreq+kVib1, 1150, 0, 90, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  aV1 = a1a + a1b

  ; Voice 2 (slightly sharp)
  kVib2 oscili 0.007*iFreq, 5.8
  a2a fof iAmp*0.3, iFreq*1.003+kVib2, 800,  0, 85, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a2b fof iAmp*0.2, iFreq*1.003+kVib2, 1150, 0, 95, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  aV2 = a2a + a2b

  ; Voice 3 (slightly flat)
  kVib3 oscili 0.009*iFreq, 4.9
  a3a fof iAmp*0.3, iFreq*0.997+kVib3, 800,  0, 75, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  a3b fof iAmp*0.2, iFreq*0.997+kVib3, 1150, 0, 88, 0.003, 0.02, 0.007, 50, giSine, giSigmoid, p3
  aV3 = a3a + a3b

  ; Pan voices across stereo field
  aL = (aV1*0.5 + aV2*0.3 + aV3*0.7) * kEnv
  aR = (aV1*0.5 + aV2*0.7 + aV3*0.3) * kEnv
  outs aL, aR
endin
```

## FOF Parameter Guide

| Parameter | Range | Effect |
|---|---|---|
| kris (rise time) | 0.001-0.01 | Grain attack — shorter = sharper onset |
| kdur (duration) | 0.01-0.05 | Grain length — longer = narrower bandwidth |
| kdec (decay) | 0.003-0.02 | Grain decay — longer = more ringing |
| kband (bandwidth) | 20-200 Hz | Formant width — narrow = more resonant |
| koct (octaviation) | 0-8 | Attenuation of odd partials |
| iolaps | 20-100 | Max overlapping grains — more = smoother |

## Tips

- **Male voice**: fundamental 80-180 Hz, formants as listed above
- **Female voice**: fundamental 180-300 Hz, shift all formants up ~15-20%
- **Child voice**: fundamental 250-400 Hz, shift formants up ~25-30%
- **Whisper**: remove fundamental, use noise as excitation, keep formant filters
- **Robot voice**: exact integer ratios, no vibrato, no formant variation
