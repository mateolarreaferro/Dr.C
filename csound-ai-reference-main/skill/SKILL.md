# SKILL: Csound 7 Code Generation

## Trigger
Use this skill whenever generating, editing, or reviewing **Csound** code (`.csd`, `.orc`, `.sco` files).

## Before Writing Any Csound Code

1. Confirm the target version is **Csound 7** unless told otherwise
2. Review the variable rate prefix rules (i/k/a/S/f)
3. Use new-style UDO syntax (`opcode Name(args):returnType` / `endop`)
4. Always include the standard orchestra header (`sr`, `ksmps`, `nchnls`, `0dbfs = 1`)

## Rate Prefix Rules (Non-Negotiable)

Every variable name prefix determines its update rate:
- `i` = init rate (once per note)
- `k` = control rate (every ksmps samples, ~64/sr seconds)
- `a` = audio rate (every sample)
- `S` = string
- `f` = spectral (f-sig)

Opcodes have defined output rates — match the variable prefix to the opcode's output rate.

## UDO Template (Always Use This Form)

```csound
; New-style (Csound 7 — preferred)
opcode UDOName(aSig, kParam):a
  ; processing — args available directly by name
  xout result
endop

; Multiple return values use parenthesized types
opcode StereoProcess(aSigL, aSigR, kMix):(a,a)
  ; processing
  xout aOutL, aOutR
endop
```

Type codes for optional args: `:o` (i-rate, default 0), `:O` (k-rate, default 0), `:p`/`:P` (default 1), `:j`/`:J` (default -1).

## CSD File Template

```csound
<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

; UDOs go here

instr MySynth
  ; instrument code
endin

</CsInstruments>
<CsScore>
i "MySynth"  0  4
e
</CsScore>
</CsoundSynthesizer>
```

## Key Opcode Signatures to Get Right

| Task | Correct Opcode | Signature |
|------|---------------|----------|
| Sine oscillator | `oscili` | `aSig = oscili(iAmp, kFreq [, iFtable])` |
| Anti-aliased VCO | `vco2` | `aSig = vco2(iAmp, kFreq [, iMode])` |
| ADSR envelope | `madsr` | `kEnv = madsr(iAtk, iDec, iSus, iRel)` |
| Moog filter | `moogladder` | `aOut = moogladder(aSig, kCutoff, kRes)` |
| ZDF filter | `zdf_ladder` | `aOut = zdf_ladder(aSig, kCutoff, kRes)` |
| Schroeder reverb | `reverbsc` | `aL, aR reverbsc aInL, aInR, kFb, kCo` |
| Variable delay | `vdelay` | `aDel = vdelay(aSig, kDelayMs, iMaxMs)` |
| MIDI note→Hz | `cpsmidinn` | `iFreq = cpsmidinn(iMidiNote)` |
| dB→amplitude | `ampdbfs` | `iAmp = ampdbfs(iDb)` |
| Portamento | `port` | `kSmooth = port(kSig, kHalfTime)` |

## Checklist Before Outputting Code

- [ ] All variable names have correct rate prefix
- [ ] UDOs use new-style syntax with named args
- [ ] Orchestra header has `sr`, `ksmps`, `nchnls`, `0dbfs = 1`
- [ ] **All single-output opcodes use functional style** (`kEnv = madsr(...)`, not `kEnv madsr ...`)
- [ ] Statement style used ONLY for multi-output opcodes (`reverbsc`, `zdf_2pole`, etc.)
- [ ] No `cpspch` usage
- [ ] `expseg` values are all > 0
- [ ] `linseg`/`expseg` argument count is odd (value, dur, value, dur, ..., value)
- [ ] UDOs have `xout` for return values
- [ ] `out()` used for stereo output (not deprecated `outs`)

## Consulting the Csound Manual

Csound has 1500+ opcodes. For opcode signatures and detailed behavior, consult the official manual:
- **Manual home**: https://csound.com/manual/
- **Opcode quick reference**: https://csound.com/manual/opcodesQuickRef/
- **Individual opcode pages**: `https://csound.com/manual/opcodes/{opcode_name}/`

## Reference Files (Skill Package)

- `reference/syntax-rules.md` — full rate/type rules
- `reference/opcodes.md` — manual URL directory and common opcode signatures
- `reference/patterns.md` — common synthesis and effects patterns
- `reference/antipatterns.md` — common AI mistakes
- `examples/` — working annotated `.csd` files
