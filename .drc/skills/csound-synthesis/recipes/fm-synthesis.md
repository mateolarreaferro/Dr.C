# FM Synthesis Recipes

## How FM Works in Csound

FM synthesis modulates the frequency of a carrier oscillator with another oscillator (modulator). The **index** controls how many sidebands (harmonics) are produced — higher index = brighter/more complex.

`foscili` wraps this in one opcode:
```csound
aOut foscili iAmp, iFreq, iCarrier, iModulator, kIndex, giSine
; iCarrier:iModulator = frequency ratio (integers = harmonic, non-integers = inharmonic)
; kIndex = modulation index (0 = sine, higher = more harmonics)
```

## Bell / Glockenspiel

Inharmonic C:M ratios produce metallic, bell-like tones. High initial index with fast decay.

```csound
instr Bell
  iFreq = p4
  iAmp = p5
  ; Inharmonic ratio creates metallic partials
  iCar = 1
  iMod = 1.4  ; or 2.76 for more complex bell
  ; Index envelope: bright attack, decays to near-sine
  kIdx expseg 12, 0.01, 12, 0.5, 2, p3-0.51, 0.5
  kAmp expseg iAmp, 0.001, iAmp, p3-0.001, 0.001
  aOut foscili kAmp, iFreq, iCar, iMod, kIdx, giSine
  outs aOut, aOut
endin
```

Variations:
- **Tubular bell**: C:M = 1:2.76, index 10-20, longer decay (3-5s)
- **Glockenspiel**: C:M = 1:3.5, index 6-10, short decay (0.5-1s)
- **Chime**: C:M = 1:1.414 (√2), index 8-15, medium decay (2-3s)
- **Gamelan**: C:M = 1:1.26 or 1:2.52, index 5-12

## Brass

Harmonic C:M ratio (1:1) with index that rises with amplitude — mimics how brass gets brighter when played louder.

```csound
instr Brass
  iFreq = p4
  iAmp = p5
  ; Amplitude envelope with attack
  kAmp linsegr 0, 0.08, iAmp, p3-0.18, iAmp*0.9, 0.1, 0
  ; Index tracks amplitude (brighter when louder)
  kIdx = 3 + (kAmp/iAmp) * 5
  aOut foscili kAmp, iFreq, 1, 1, kIdx, giSine
  ; Add slight vibrato for realism
  kVib oscili 0.01*iFreq, 5.5
  aOut foscili kAmp, iFreq+kVib, 1, 1, kIdx, giSine
  outs aOut, aOut
endin
```

Parameter ranges:
- Soft brass: index 2-4
- Medium brass: index 4-7
- Loud/bright brass: index 7-12
- Vibrato rate: 5-6 Hz, depth: 0.5-1.5% of freq

## Electric Piano (DX7-style)

Two FM pairs layered — one for the fundamental tone, one for the tine/attack.

```csound
instr EPiano
  iFreq = p4
  iAmp = p5
  iVel = p5 / (1/127)  ; assume p5 is 0-1

  ; Tone component: warm fundamental
  kIdx1 expseg 2.5, 0.01, 2.5, 1.5, 0.8, p3-1.51, 0.3
  aTone foscili iAmp*0.7, iFreq, 1, 1, kIdx1, giSine

  ; Tine component: bright attack transient
  kIdx2 expseg 5, 0.005, 5, 0.3, 0.5, p3-0.305, 0.1
  kTineAmp expseg iAmp*0.4, 0.01, iAmp*0.4, 0.8, iAmp*0.05, p3-0.81, 0.001
  aTine foscili kTineAmp, iFreq, 1, 7, kIdx2, giSine

  aMix = aTone + aTine
  aMix limit aMix, -1, 1
  outs aMix, aMix
endin
```

Variations:
- **Wurlitzer**: C:M = 1:1, index 1.5-3, more bark/growl (add distortion)
- **Rhodes**: C:M = 1:1 + 1:7 tine, index 2-5, cleaner decay
- **Clavinet**: C:M = 1:1, very short decay, higher index on attack

## Metallic Textures

Use irrational C:M ratios for dense, non-harmonic spectra.

```csound
instr MetalTexture
  iFreq = p4
  iAmp = p5
  ; √2 ratio = maximally inharmonic
  kIdx linseg 15, p3*0.1, 15, p3*0.9, 1
  aOut foscili iAmp, iFreq, 1, 1.41421, kIdx, giSine
  ; Stereo with slight detune
  aOut2 foscili iAmp, iFreq*1.003, 1, 1.41421, kIdx*0.95, giSine
  outs aOut, aOut2
endin
```
