# Csound 7 — LLM Reference

> This file follows the llms.txt convention. Include it as context when using AI tools to generate Csound code.

## What is Csound?

Csound is a sound design and signal processing language. Programs are `.csd` files containing an XML-like wrapper with three sections: `<CsOptions>` (command-line flags), `<CsInstruments>` (orchestra), and `<CsScore>` (score/events).

## Version

This reference targets **Csound 7**. Key changes from Csound 6:
- New-style UDO syntax with named arguments (preferred over old type-string style)
- Functional opcode calling syntax: `asig = vco2(0.5, 440)`
- Explicit type annotations: `glid:k`, `sig:a`
- `outs` deprecated — use `out(aL, aR)` for stereo output
- Improved array and struct support

## Core Concepts

### Variable Rate Prefixes

Variable names are typed by prefix:
- `i` — init rate (evaluated once at note start)
- `k` — control rate (evaluated every `ksmps` samples)
- `a` — audio rate (evaluated every sample)
- `S` — string variable
- `f` — f-signal (spectral domain)

Global variables add `g` prefix: `gk_tempo`, `gaReverb`, `gi_table`.
Arrays use `[]` suffix: `iArr[]`, `kArr[]`, `aArr[]`.

### Rate Promotion Rules

- **i-rate values can be used freely in k-rate and a-rate expressions.** Example: `asig = vco2(p5, p4)` where p4/p5 are i-rate is correct and idiomatic.
- **k-rate values auto-promote to a-rate** when used in a-rate expressions. `aOut = aSig * kAmp` is valid — Csound treats the k-rate value as constant for each k-period block.
- The output rate = highest rate of operands: i < k < a.

### Orchestra Header

```csound
sr     = 48000   ; sample rate
ksmps  = 64      ; samples per control period
nchnls = 2       ; output channels
0dbfs  = 1       ; amplitude reference (always set this)
```

### UDO (User-Defined Opcode) Syntax

**New-style (Csound 7 — preferred):**
```csound
opcode Saturate(asig, ksat):a
  xout tanh(asig * ksat) / tanh(ksat)
endop

; Multiple returns use parenthesized types
opcode StereoWidth(aSig, kWidth):(a,a)
  aDel = vdelay(aSig, kWidth * 12, 20)
  xout aSig, aDel
endop
```

Arguments are named in the declaration — no `xin` needed. Types inferred from prefixes or declared with `:type` annotations.

**Old-style (still valid):**
```csound
opcode Name, outputTypeString, inputTypeString
  in1, in2 xin
  xout out1
endop
```

### Instrument

Named instruments are preferred in Csound 7:

```csound
instr SubSynth
  iFreq = cpsmidinn(p4)
  iAmp  = ampdbfs(p5)
  kEnv  = linsegr(0, 0.01, 1, 0.1, 0.8, 0.2, 0)
  asig  = vco2(iAmp, iFreq)
  asig *= linen:a(1, 0, p3, .01)
  out(asig * kEnv, asig * kEnv)
endin
```

Use `:type` suffix for polymorphic opcodes: `linen:a()`, `random:i()`, `expon:a()`.

## Key Opcodes

### Oscillators
- `aSig = oscili(iAmp, kFreq [, iFtable])` — interpolating oscillator
- `aSig = vco2(iAmp, kFreq [, iMode])` — anti-aliased VCO; mode 0=saw, 2=square/PWM, 10=square, 12=triangle
- `aSig = poscil(iAmp, kFreq, iFtable)` — high-precision oscillator

### Envelopes
- `kEnv = linseg(ia, id, ib [, id, ic ...])` — linear segments (odd arg count)
- `kEnv = linsegr(ia, id, ib [, ...], iRel, iFinal)` — linear with release
- `kEnv = madsr(iAtk, iDec, iSus, iRel)` — MIDI-style ADSR

### Filters
- `aOut = moogladder(aSig, kCutoff, kRes)` — Moog ladder; res 0-1
- `aOut = zdf_ladder(aSig, kCutoff, kRes)` — ZDF ladder (more accurate)
- `aOut = butlp(aSig, kCutoff)` — Butterworth lowpass

### Effects
- `aL, aR reverbsc aInL, aInR, kFeedback, kCutoff` — stereo reverb
- `aDel = vdelay(aSig, kDelayMs, iMaxMs)` — variable delay
- `aOut = distort1(aSig, kPregain, kPostgain, kShape1, kShape2)` — waveshaping distortion (5 required args)

### Utility
- `iFreq = cpsmidinn(iMidi)` — MIDI note to Hz
- `iAmp = ampdbfs(iDb)` — dBFS to linear amplitude
- `kSmooth = port(kSig, kHalfTime)` — portamento/lag

## Score

```csound
; Named instruments (preferred)
i "SubSynth"  0  2     60  -12

; Numbered instruments (still valid)
i 1  0  2     60  -12

; Function tables
f 1  0  4096  10  1      ; sine wave table (GEN10)
e
```

## Common Mistakes

1. Wrong rate prefix on variable (e.g., `kSig` for an audio output)
2. Missing `0dbfs = 1` in header
3. Using old-style UDO syntax without type strings (or `xin` in new-style)
4. Using `cpspch` instead of `cpsmidinn()`
5. Zero/negative values in `expseg` (must be > 0; use 0.0001)
6. Wrong argument count in `linseg` (must be odd: val,dur,val,dur,...,val)
7. Missing `xout` in UDOs
8. Using `outs` (deprecated in Csound 7) — use `out(aL, aR)` instead
9. Old statement style for single-output opcodes — use `kEnv = madsr(...)` not `kEnv madsr ...`. This applies to ALL single-output opcodes including envelopes (`linseg`, `linsegr`, `madsr`, `transegr`, etc.). Statement style is only for multi-output opcodes.
10. Not clearing global accumulators (`clear gaReverb`)
11. Wrong `distort1` args (needs 5: aSig, kPregain, kPostgain, kShape1, kShape2)

## Consulting the Csound Manual

Csound has **1500+ opcodes**. For opcode signatures, arguments, and detailed behavior, always consult the official manual rather than guessing.

- **Manual home**: https://csound.com/manual/
- **Opcode quick reference**: https://csound.com/manual/opcodesQuickRef/
- **Individual opcode pages**: `https://csound.com/manual/opcodes/{opcode_name}/`
  - Example: `vco2` → https://csound.com/manual/opcodes/vco2/
- **GEN routines**: https://csound.com/manual/genIndex/

## Further Reference

- Csound 7 Manual: https://csound.com/manual/
