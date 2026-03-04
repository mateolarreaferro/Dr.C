# Csound 7 — Opcode Reference Guide

## Consulting the Csound Manual (IMPORTANT)

Csound has **1500+ opcodes**. No local reference can cover them all. When you need to look up an opcode's signature, arguments, or behavior, **always consult the official Csound 7 manual**.

### Key URLs

| Resource | URL |
|----------|-----|
| **Csound 7 Manual (home)** | https://csound.com/manual/ |
| **Opcode Quick Reference** | https://csound.com/manual/opcodesQuickRef/ |
| **Opcodes Index** | https://csound.com/manual/opcodesIndex/ |
| **GEN Routines Index** | https://csound.com/manual/genIndex/ |
| **Deprecated Opcodes** | https://csound.com/manual/deprecated/ |

### Individual Opcode Pages

Every opcode has a dedicated page at:

```
https://csound.com/manual/opcodes/{opcode_name}/
```

Examples:
- `oscili` → https://csound.com/manual/opcodes/oscili/
- `vco2` → https://csound.com/manual/opcodes/vco2/
- `moogladder` → https://csound.com/manual/opcodes/moogladder/
- `reverbsc` → https://csound.com/manual/opcodes/reverbsc/
- `linseg` → https://csound.com/manual/opcodes/linseg/
- `madsr` → https://csound.com/manual/opcodes/madsr/

### Category Pages

Browse opcodes by category:

| Category | URL |
|----------|-----|
| Basic Oscillators | https://csound.com/manual/siggen/basic/ |
| Dynamic Spectrum (vco2, buzz) | https://csound.com/manual/siggen/dynamic/ |
| FM Synthesis | https://csound.com/manual/siggen/fmsynth/ |
| Granular Synthesis | https://csound.com/manual/siggen/granular/ |
| Envelope Generators | https://csound.com/manual/siggen/envelope/ |
| Linear/Exponential Generators | https://csound.com/manual/siggen/lineexp/ |
| Standard Filters | https://csound.com/manual/sigmod/standard/ |
| Specialized Filters | https://csound.com/manual/sigmod/speciali/ |
| Reverberation | https://csound.com/manual/sigmod/reverbtn/ |
| Delay | https://csound.com/manual/sigmod/delayops/ |
| Special Effects | https://csound.com/manual/sigmod/speciale/ |
| Amplitude/Dynamics | https://csound.com/manual/sigmod/ampmod/ |
| Panning/Spatialization | https://csound.com/manual/sigmod/panspatl/ |
| Random/Noise Generators | https://csound.com/manual/siggen/random/ |
| Sample Playback | https://csound.com/manual/siggen/sample/ |
| Signal Output | https://csound.com/manual/sigio/output/ |
| Software Bus (chnset/chnget) | https://csound.com/manual/sigio/softbus/ |
| MIDI Input | https://csound.com/manual/midi/input/ |
| Spectral Processing | https://csound.com/manual/spectral/realtime/ |
| Models/Emulations | https://csound.com/manual/siggen/models/ |
| Waveguide Physical Modeling | https://csound.com/manual/siggen/wavguide/ |
| Instrument Invocation | https://csound.com/manual/control/invocat/ |
| Array Opcodes | https://csound.com/manual/math/array/ |

### Other Useful Pages

- **Data Types & Variables**: https://csound.com/manual/orch/data-types/
- **UDO Syntax**: https://csound.com/manual/orch/user-defined-opcodes/
- **Traditional vs Functional Code**: https://csound.com/manual/orch/traditional-functional-code/
- **Score Statements**: https://csound.com/manual/score/statements/
- **What's New in Csound 7**: https://csound.com/manual/intro/whats-new-in-csound-7/

---

## When to Consult the Manual

- **Unfamiliar opcode**: Look it up at `https://csound.com/manual/opcodes/{name}/`
- **Unsure about arguments**: The manual page lists all required and optional arguments with types
- **Looking for an opcode**: Browse the Quick Reference or category pages
- **Checking if deprecated**: See the deprecated opcodes page before using old opcodes

---

## Commonly Used Opcodes (Quick Reminder)

The opcodes below are frequently used in Csound synthesis. For full documentation on any of these, visit its manual page. Use **functional calling style** — see CLAUDE.md.

### Oscillators
- `oscili(xAmp, xCps [, iFn])` — interpolating oscillator (default sine)
- `vco2(kAmp, kCps [, iMode, kPw])` — anti-aliased VCO (0=saw, 2=square/PWM, 10=square, 12=triangle)
- `poscil(kAmp, kCps, iFn)` — high-precision oscillator
- `foscili(xAmp, kCps, xCar, xMod, kNdx [, iFn])` — FM oscillator

### Envelopes
- `linseg(ia, idur1, ib [, idur2, ic ...])` — linear segments
- `linsegr(ia, idur1, ib [, ...], iRelDur, iFinal)` — linear with release
- `expseg(ia, idur1, ib [...])` — exponential (all values > 0)
- `madsr(iAtk, iDec, iSus, iRel)` — MIDI-aware ADSR
- `linen:a(xAmp, iRise, iDur, iDec)` — simple trapezoid

### Filters
- `moogladder(aSig, xCf, xRes)` — Moog ladder LP
- `zdf_ladder(aSig, xCf, xRes)` — zero-delay feedback ladder
- `butlp(aSig, xCf)` / `buthp(aSig, xCf)` — Butterworth LP/HP
- `butbp(aSig, xCf, xBw)` — Butterworth BP
- `tone(aSig, kCf)` / `atone(aSig, kCf)` — 1-pole LP/HP

### Reverb & Delay
- `aL, aR reverbsc aInL, aInR, kFbLvl, kFco` — stereo reverb (statement style — multi-output)
- `aL, aR freeverb aInL, aInR, kRoomSize, kHFDamp` — Freeverb
- `vdelay(aSig, aDel, iMaxDel)` — variable delay (ms)

### Distortion / Waveshaping
- `distort1(aSig, kPregain, kPostgain, kShape1, kShape2)` — 5 required args
- `powershape(aSig, kShapeExp)` — power waveshaping
- `clip(aSig, iMethod, iLimit)` — clipping

### Noise
- `rand(xAmp)` — white noise
- `pinkish(xAmp)` — pink noise
- `gauss(kSigma)` — Gaussian noise

### Mixing / Utility
- `ntrpol(xSig1, xSig2, kPoint)` — crossfade (0=sig1, 1=sig2)
- `port(kSig, kHalfTime)` — portamento / lag
- `pan2(aSig, xPos)` — stereo panning

### Conversion
- `cpsmidinn(iMidi)` — MIDI note → Hz
- `ampdbfs(x)` — dBFS → linear amplitude
- `semitone(x)` — semitone ratio multiplier

### MIDI
- `notnum()` — MIDI note number
- `veloc([iLow, iHigh])` — velocity
- `pchbend([iMin, iMax])` — pitch bend
- `midictrl(iNum)` — CC value
- `massign(iChan, insNum)` — channel → instrument routing

### Channels / Bus
- `chnset(kVal, "name")` — write to channel
- `chnget:k("name")` — read from channel

### Table Operations
- `iFn = ftgen(0, 0, iSize, iGenNum, ...)` — create function table
- `tab(kNdx, iFn)` / `tab_i(iNdx, iFn)` — read table

### Score / Event Generation
- `event("i", kInsNum, kDelay, kDur [, kP4 ...])` — trigger instrument from orchestra
- `schedule(iInsNum, iDelay, iDur [, iP4 ...])` — schedule at i-time
