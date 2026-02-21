# Acoustic & Psychoacoustic Principles for Sound Design

Principles drawn from instrument acoustics and psychoacoustics that make synthesized sounds convincing and musically effective.

## 1. Amplitude-Timbre Coupling

In all acoustic instruments, loudness and brightness are linked:
- **Louder = brighter**: When a string is plucked harder, a brass player blows stronger, or a drum is hit harder, the sound has more high-frequency energy
- **Softer = darker**: Quiet notes are mellower, with energy concentrated in lower harmonics

### Implementation
```csound
; Link filter cutoff to amplitude
kAmp madsr 0.01, 0.2, 0.6, 0.1
kCutoff = 500 + (kAmp * 4000)  ; cutoff rises with amplitude
aFilt moogladder aSig, kCutoff, 0.2
```

For FM synthesis, link the modulation index to amplitude:
```csound
kIdx = 1 + (kAmp * 8)  ; brighter when louder
```

## 2. Spectral Decay (Frequency-Dependent Damping)

High frequencies decay faster than low frequencies in nearly all acoustic systems — strings, air columns, rooms. A sound that decays uniformly across the spectrum sounds synthetic.

### Implementation
```csound
; Multi-band envelope: highs decay faster
aLow butterlp aSig, 500
aMid butterbp aSig, 2000, 2000
aHigh butterhp aSig, 4000

kDecLow expseg 1, p3, 0.5
kDecMid expseg 1, p3*0.6, 0.1
kDecHigh expseg 1, p3*0.3, 0.01

aOut = aLow*kDecLow + aMid*kDecMid + aHigh*kDecHigh
```

Or simply use a decaying filter cutoff:
```csound
kCutoff expseg 8000, p3, 400
aFilt tone aSig, kCutoff
```

## 3. Formant Preservation

Vocal and many acoustic instrument sounds have fixed resonant frequencies (formants) that do NOT change with pitch. This is what makes a violin sound like a violin regardless of which note is played.

### Implementation
Use fixed-frequency filters rather than pitch-tracking ones:
```csound
; CORRECT: Fixed formants (like a real instrument body)
aBody resonz aSig, 500, 50    ; body resonance at 500 Hz always
aBody2 resonz aSig, 1200, 80  ; second formant always at 1200 Hz

; WRONG: Filter that tracks pitch (sounds synthetic)
; aBody resonz aSig, iFreq*2, 50  ; this moves with pitch — not realistic
```

## 4. Envelope Interdependence

Attack characteristics are linked — you can't change one without affecting perception of others:
- **Fast attacks** → more noise, broader initial spectrum, percussive character
- **Slow attacks** → less noise, gentler onset, sustained character
- **Short decay** → percussive, plucked
- **Long decay** → sustained, bowed/blown

### Implementation
```csound
; Fast attack with noise burst (like a hammer/pluck)
aNoise noise 0.3, 0
aTransient = aNoise * expseg(1, 0.005, 0.001, p3-0.005, 0.0001)
aOut = aTonal + aTransient

; Slow attack without noise (like a bowed string)
kAmp linseg 0, 0.3, 1, p3-0.3, 1  ; no transient needed
```

## 5. Micro-Variation and Humanization

No acoustic sound is perfectly periodic. Subtle random variations in pitch, amplitude, and timing make sounds feel alive:
- **Pitch jitter**: ±1-5 cents at 3-10 Hz (like natural vibrato irregularity)
- **Amplitude jitter**: ±0.5-2 dB at 2-8 Hz
- **Timing jitter**: ±1-5 ms per grain/note

### Implementation
```csound
; Pitch micro-variation
kJitFreq jitter 0.003*iFreq, 2, 8  ; ±0.3% at 2-8 Hz
aOsc oscili iAmp, iFreq + kJitFreq, giSine

; Amplitude micro-variation
kJitAmp jitter 0.02, 3, 10  ; ±2% at 3-10 Hz
aOut = aOsc * (1 + kJitAmp)

; Combined vibrato + jitter for realism
kVibrato oscili 0.005*iFreq, 5.5  ; regular vibrato
kJitter jitter 0.002*iFreq, 1, 4   ; irregular jitter
aOsc oscili iAmp, iFreq + kVibrato + kJitter, giSine
```

## 6. Room and Environment

Sounds exist in spaces. Even "dry" sounds have micro-reflections:
- **Close/intimate**: very short reverb (0.3-0.8s), minimal early reflections
- **Room**: moderate reverb (0.8-1.5s), clear early reflections
- **Hall**: long reverb (1.5-3s), diffuse reflections
- **Cathedral**: very long reverb (3-8s), dense wash

### Implementation
```csound
; Always add at least a tiny bit of space
aL, aR reverbsc aDryL, aDryR, 0.85, 12000  ; feedback, cutoff
aOutL = aDryL * 0.85 + aL * 0.15  ; 15% wet
aOutR = aDryR * 0.85 + aR * 0.15
```

## 7. Instrument Frequency Ranges

| Instrument | Low (Hz) | High (Hz) | Fundamental Range |
|---|---|---|---|
| Bass (electric) | 41 | 400 | E1-G4 |
| Guitar | 82 | 1320 | E2-E6 |
| Piano | 27.5 | 4186 | A0-C8 |
| Violin | 196 | 3520 | G3-A7 |
| Cello | 65 | 1047 | C2-C6 |
| Flute | 262 | 2093 | C4-C7 |
| Clarinet | 147 | 1568 | D3-G6 |
| Trumpet | 165 | 988 | E3-B5 |
| Male voice | 85 | 350 | Fundamental |
| Female voice | 165 | 700 | Fundamental |
| Kick drum | 40 | 100 | Fundamental |
| Snare drum | 150 | 250 | Fundamental |

## 8. Critical Bands and Masking

When two frequencies are within a critical band (~100 Hz at low frequencies, ~1/3 octave at high), they interfere and create roughness or masking. Use this knowledge to:
- **Avoid muddiness**: don't stack sounds in the same critical band
- **Create roughness intentionally**: slight detuning within a critical band
- **Create clarity**: spread harmonics across different critical bands

## 9. The Missing Fundamental

The brain perceives pitch based on harmonic series even when the fundamental is absent. A sound with partials at 200, 300, 400, 500 Hz is perceived as having a 100 Hz fundamental. Use this for:
- Adding bass presence without low-frequency energy (small speakers)
- Creating perceived pitch below the actual lowest frequency

```csound
; "Phantom" bass — harmonics suggest fundamental
a2 oscili 0.5, iFreq*2, giSine  ; 2nd harmonic
a3 oscili 0.4, iFreq*3, giSine  ; 3rd harmonic
a4 oscili 0.3, iFreq*4, giSine  ; 4th harmonic
aOut = a2 + a3 + a4  ; perceived pitch = iFreq, but no energy at iFreq
```

## 10. Transient Importance

The first 20-50ms of a sound is critical for identification. The attack transient tells the listener what kind of sound it is (pluck, bow, strike, breath). Modifying the attack completely changes the perceived instrument.

Design transients explicitly:
```csound
; Pluck transient: noise burst + pitch drop
aNoise noise 0.5, 0
aTransient = aNoise * expseg(1, 0.003, 0.001, p3-0.003, 0.0001)
kPitch expseg iFreq*1.5, 0.01, iFreq, p3-0.01, iFreq  ; slight pitch drop

; Bow transient: gradual noise onset
aNoise noise 0.1, 0
kNoiseEnv linseg 0, 0.1, 0.1, 0.2, 0.02, p3-0.3, 0
aTransient = aNoise * kNoiseEnv

; Breath transient: filtered noise
aNoise noise 0.3, 0
aBreath butterbp aNoise, 2000, 1500
kBreathEnv linseg 0, 0.05, 0.3, 0.1, 0.05, p3-0.15, 0
aTransient = aBreath * kBreathEnv
```
