# Csound 7 — Common Patterns

## Synthesis Patterns

### Subtractive Synthesis

```csound
opcode SubSynth(kFreq, kCutoff, kRes):a
  ; Oscillator with slight detuning for richness
  aSaw1 = vco2(0.4, kFreq)
  aSaw2 = vco2(0.4, kFreq * 1.005)   ; +0.5 cents detune
  aSaw3 = vco2(0.4, kFreq * 0.995)   ; -0.5 cents detune
  aMix  = aSaw1 + aSaw2 + aSaw3

  ; Filter with envelope
  aOut = moogladder(aMix, kCutoff, kRes)
  xout aOut
endop

instr SubSynth
  iFreq  = cpsmidinn(p4)
  iAmp   = ampdbfs(-12)

  kAmpEnv  = madsr(0.01, 0.1, 0.7, 0.3)
  kFiltEnv = madsr(0.005, 0.2, 0.4, 0.4)

  kCutoff = 200 + kFiltEnv * 3000   ; envelope opens filter

  aSig = SubSynth(iFreq, kCutoff, 0.3)
  aOut = aSig * kAmpEnv * iAmp

  out(aOut, aOut)
endin
```

### FM Synthesis (2-Operator)

```csound
opcode FM2Op(kCarrFreq, kModRatio, kModIndex, kAmp):a
  kModFreq = kCarrFreq * kModRatio
  kModAmp  = kModFreq * kModIndex    ; FM index scales with mod frequency

  aMod = oscili(kModAmp, kModFreq)
  aOut = oscili(kAmp, kCarrFreq + aMod)
  xout aOut
endop

instr FMSynth
  iFreq = cpsmidinn(p4)
  iAmp  = ampdbfs(-10)

  kEnv  = linsegr(0, 0.01, 1, p3-0.05, 0.8, 0.05, 0)
  ; Modulation index sweeps for brighter attack
  kIdx  = linsegr(5, 0.1, 1.5, p3-0.1, 1.5, 0.1, 0)

  aSig = FM2Op(iFreq, 2, kIdx, iAmp)
  aOut = aSig * kEnv

  out(aOut, aOut)
endin
```

### Additive Synthesis (Partial Stack)

```csound
opcode AdditiveSynth(kFreq, iAmps[], kDetunes[]):a
  iNumPartials = lenarray:i(iAmps)
  aMix = 0
  iPartial = 0

  while iPartial < iNumPartials do
    aPartial = oscili(iAmps[iPartial], kFreq * (iPartial + 1) + kDetunes[iPartial])
    aMix += aPartial
    iPartial += 1
  od

  xout aMix
endop
```

### Wavetable Synthesis

```csound
instr WaveTable
  iTable = p4      ; ftable number passed as parameter
  iFreq  = cpsmidinn(p5)
  iAmp   = ampdbfs(-6)

  kEnv  = linsegr(0, 0.005, 1, p3-0.1, 0.9, 0.1, 0)
  aSig = poscil(iAmp, iFreq, iTable)    ; poscil = high-accuracy oscillator

  out(aSig * kEnv, aSig * kEnv)
endin
```

### Granular Synthesis (Basic)

```csound
instr GranularSynth
  iSoundFile = p4   ; sample table
  iAmp       = ampdbfs(-6)

  kGrainRate  = 25                ; grains per second
  kGrainDur   = 0.08              ; grain duration in seconds
  kPitch      = 1.0               ; pitch ratio
  kPosition   = 0.5              ; position in source (0-1)

  aSig  granule iAmp, kGrainRate, kGrainDur, kPitch, iSoundFile, \
                kPosition, 0.05, 0, 0, 0

  out(aSig, aSig)
endin
```

---

## Effects Patterns

### Stereo Reverb with Wet/Dry Mix

```csound
opcode StereoReverb(aDryL, aDryR, kRoomSize, kWetMix):(a,a)
  ; Clamp room size to valid range
  kRoom = (kRoomSize > 0.98) ? 0.98 : kRoomSize

  aWetL, aWetR reverbsc aDryL, aDryR, kRoom, 8000

  aOutL = ntrpol(aDryL, aWetL, kWetMix)
  aOutR = ntrpol(aDryR, aWetR, kWetMix)
  xout aOutL, aOutR
endop
```

### Tempo-Synced Delay

```csound
opcode SyncDelay(aSig, kBPM, kFeedback, iSubdivision):a
  ; iSubdivision: 1=quarter, 2=eighth, 4=sixteenth
  kDelayTime = (60 / kBPM) / iSubdivision
  kDelayMs   = kDelayTime * 1000
  iMaxMs     = 2000

  aDel  = vdelay(aSig, kDelayMs, iMaxMs)
  aOut  = aSig + aDel
  xout  aOut
endop
```

### Ping-Pong Delay

```csound
opcode PingPongDelay(aSig, kBPM, kFeedback, iSubdivision):(a,a)
  kDelayMs = (60000 / kBPM) / iSubdivision
  iMaxMs   = 4000

  ; Left tap feeds right, right tap feeds left
  aDelL = vdelay(aSig + aDelR * kFeedback, kDelayMs, iMaxMs)
  aDelR = vdelay(aSig + aDelL * kFeedback, kDelayMs * 0.5, iMaxMs)

  aOutL = aSig + aDelL
  aOutR = aSig + aDelR
  xout aOutL, aOutR
endop
```

### Chorus / Ensemble

```csound
opcode Chorus(aSig, kDepth, kRate):(a,a)
  ; Multiple modulated delay taps
  kMod1 = oscili(kDepth, kRate)
  kMod2 = oscili(kDepth, kRate * 1.1, 0, 0.25)    ; phase offset
  kMod3 = oscili(kDepth, kRate * 0.9, 0, 0.5)

  iBase = 20   ; base delay in ms
  iMax  = 50

  aCh1 = vdelay(aSig, iBase + kMod1 * 10, iMax)
  aCh2 = vdelay(aSig, iBase + kMod2 * 10, iMax)
  aCh3 = vdelay(aSig, iBase + kMod3 * 10, iMax)

  ; Spread to stereo
  aOutL = (aSig + aCh1) * 0.5
  aOutR = (aSig + aCh2 + aCh3) * 0.5
  xout aOutL, aOutR
endop
```

### Soft Saturation

```csound
opcode Saturate(aSig, kDrive, kMix):a
  aDriven = aSig * kDrive
  aSat    = distort1(aDriven, 1, 0.5, 0, 0)  ; soft clip (pregain, postgain, shape1, shape2)
  ; Compensate for gain increase
  aComp = aSat / kDrive
  aOut  = ntrpol(aSig, aComp, kMix)
  xout  aOut
endop
```

### Parametric EQ Band

```csound
opcode ParaEQ(aSig, kFreq, kGainDB, kQ):a
  ; Convert dB to linear for gain
  kGain = pow(10, kGainDB / 20)

  ; Peak/notch filter via peaking EQ formula
  aOut = pareq(aSig, kFreq, kGain, kQ, 1)   ; mode 1 = peaking
  xout aOut
endop
```

---

## Envelope Patterns

### Standard ADSR (Named Parameters)

```csound
opcode ADSR(kAtk, kDec, kSus, kRel):k
  kEnv = madsr(kAtk, kDec, kSus, kRel)
  xout kEnv
endop
```

### Looping LFO

```csound
opcode LFO(kFreq, kDepth, iShape, kPhase:O):k
  ; iShape: 0=sine, 1=triangle, 2=square, 3=sawtooth
  kLFO = oscili(kDepth, kFreq, iShape + 1)   ; ftable 1=sine, 2=tri etc.
  xout kLFO
endop
```

### Triggered Envelope

```csound
; Envelope that re-triggers on k-rate gate signal
opcode TrigEnv(kGate, kAtk, kDec, kRel):k
  kTrig  trigger kGate, 0.5, 0    ; detect rising edge
  kEnv   = linsegr(0, 0.001, 1, kAtk, 1, kDec, 0)
         reinit  ; restart on trigger
  xout   kEnv
endop
```

---

## MIDI and Real-Time Patterns

### Basic MIDI Instrument

```csound
instr MIDISynth
  ; MIDI opcodes auto-fill from MIDI event
  iMidi  notnum
  iFreq  = cpsmidinn(iMidi)
  iVel   veloc   0, 127
  iAmp   = (iVel / 127) * 0dbfs * 0.5

  kEnv   = linsegr(0, 0.01, 1, 0.1, 0.8, 0.3, 0)
  kBend  pchbend 0, 2                  ; pitch bend ±2 semitones
  kMod   midictrl 1, 0, 1              ; CC1 mod wheel, range 0-1

  ; Mod wheel controls vibrato
  kVib = oscili(kMod * 0.5, 5)         ; vibrato depth * rate
  aSig = vco2(iAmp, iFreq * semitone(kBend + kVib))

  kFiltCut = 500 + kMod * 3000
  aOut = moogladder(aSig, kFiltCut, 0.3)
  aOut *= kEnv

  out(aOut, aOut)
endin
```

### Channel Routing / Mixdown

```csound
; Instruments write to global buses; mixer instrument reads and outputs
instr SynthVoice
  ; ... synthesis ...
  chnmix aOut, "synthBus"
endin

instr DrumVoice
  ; ... drum synthesis ...
  chnmix aKick, "drumBus"
endin

instr Master  ; always-on mixer
  aSynth chnget "synthBus"
  aDrum  chnget "drumBus"

  ; Apply reverb to synth
  aRevL, aRevR reverbsc aSynth, aSynth, 0.8, 8000
  aMixL = aSynth * 0.6 + aRevL * 0.4 + aDrum * 0.9
  aMixR = aSynth * 0.6 + aRevR * 0.4 + aDrum * 0.9

  out(aMixL, aMixR)

  ; Clear buses
  chnclear "synthBus"
  chnclear "drumBus"
endin
```

---

## Audio File Playback

```csound
instr PlayFile
  SFile  = p4             ; file path from score string
  iAmp   = ampdbfs(-6)
  iSpeed = 1.0            ; playback speed (1 = normal)

  aSigL, aSigR diskin2 SFile, iSpeed, 0, 1  ; loop=1

  out(aSigL * iAmp, aSigR * iAmp)
endin
```

```csound
; Score string parameter
i "PlayFile"  0  4  "mysound.wav"
```
