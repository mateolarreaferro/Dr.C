# Csound 7 — Anti-Patterns and Common AI Mistakes

These are the most frequent errors AI tools make when generating Csound code. Each entry shows the **wrong** pattern and the **correct** fix.

---

## 1. Wrong Variable Rate Prefix

**Wrong:**
```csound
kOut  oscili  0.5, 440    ; oscili outputs a-rate, not k-rate
iFreq oscili  0.5, 440    ; doubly wrong
```

**Correct:**
```csound
aOut  oscili  0.5, 440
```

**Rule:** The variable prefix must match the output rate of the opcode. Check the manual for every opcode's output type.

---

## 2. Missing `0dbfs = 1`

**Wrong:**
```csound
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
; no 0dbfs!

instr 1
  aSig oscili 0.5, 440    ; 0.5 means 0.5/32768 amplitude — nearly silent
endin
```

**Correct:**
```csound
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1              ; amplitude 1.0 = full scale

instr 1
  aSig oscili 0.5, 440   ; 0.5 = -6 dBFS
endin
```

---

## 3. Old-Style UDO (Missing Type Strings)

**Wrong (old-style without type strings):**
```csound
opcode MyFilter
  aSig, kCutoff xin
  aOut butlp aSig, kCutoff
  xout aOut
endop
```

**Correct (new-style — preferred in Csound 7):**
```csound
opcode MyFilter(aSig, kCutoff):a
  aOut = butlp(aSig, kCutoff)
  xout aOut
endop
```

**Also correct (old-style with type strings):**
```csound
opcode MyFilter, a, ak
  aSig, kCutoff xin
  aOut butlp aSig, kCutoff
  xout aOut
endop
```

---

## 4. Using `cpspch` or `cpsmidi(p4)` Instead of `cpsmidinn`

**Wrong:**
```csound
iFreq = cpspch(8.09)    ; old octave.pitch-class notation, fragile
iFreq = cpsmidi(p4)     ; WRONG: cpsmidi takes NO arguments (reads from MIDI event)
```

**Correct:**
```csound
; From MIDI note number (p-field or variable)
iFreq = cpsmidinn(p4)   ; convert MIDI note number to Hz
iFreq = cpsmidinn(69)   ; A4 = 440 Hz

; cpsmidi (no args) only works inside MIDI-triggered instruments
iFreq = cpsmidi()        ; reads note from current MIDI event

; Manual calculation
iFreq = 440 * pow(2, (p4 - 69) / 12)
```

**Rule:** `cpsmidinn(value)` converts a MIDI note number to Hz. `cpsmidi()` reads from a live MIDI event and takes no arguments. Never pass arguments to `cpsmidi`.

---

## 5. Zero or Negative Values in `expseg`/`expsegr`

**Wrong:**
```csound
kEnv = expseg(0, 0.01, 1, 0.5, 0)    ; 0 values cause errors/NaN
```

**Correct:**
```csound
kEnv = expseg(0.0001, 0.01, 1, 0.5, 0.0001)   ; use small positive values
; OR use linseg if you need to go to/from zero
kEnv = linseg(0, 0.01, 1, 0.5, 0)
```

---

## 6. Wrong Argument Count in `linseg`/`expseg`

The pattern must be: `startVal, dur1, val2, dur2, val3, ...` — always an **odd** number of arguments.

**Wrong:**
```csound
kEnv = linseg(0, 0.01, 1, 0.5)      ; even count — missing final value
kEnv = linseg(0.01, 1, 0.5, 0)      ; starting with duration — wrong order
```

**Correct:**
```csound
kEnv = linseg(0, 0.01, 1, 0.5, 0)   ; 5 args: val,dur,val,dur,val ✓
kEnv = linseg(0, 0.01, 1)            ; 3 args also valid: val,dur,val ✓
```

---

## 7. Missing `xin` / `xout` in Old-Style UDOs

In **old-style** UDOs (with type strings), `xin` is required to access inputs. In **new-style** UDOs, arguments are named in the declaration and `xin` is NOT needed.

**Wrong (old-style):**
```csound
opcode Scale, k, kk
  ; forgot xin — inputs not accessible
  kOut = kLow + (kHigh - kLow) * 0.5
  xout kOut
endop
```

**Correct (old-style):**
```csound
opcode Scale, k, kk
  kLow, kHigh xin            ; declare inputs with xin
  kOut = kLow + (kHigh - kLow) * 0.5
  xout kOut
endop
```

**Correct (new-style — no xin needed):**
```csound
opcode Scale(kLow, kHigh):k
  kOut = kLow + (kHigh - kLow) * 0.5
  xout kOut
endop
```

---

## 8. Using `outs` (Deprecated in Csound 7)

**Wrong:**
```csound
outs aLeft, aRight    ; deprecated — produces a warning in Csound 7
out  aLeft, aRight    ; 'out' with two args is an error
```

**Correct:**
```csound
out(aLeft, aRight)    ; stereo output — functional style (Csound 7)
out(aSig)             ; mono output (single channel)
```

---

## 9. UDO Output Count Mismatch

**Wrong:**
```csound
opcode StereoGen, aa, i     ; declares two outputs
  iFreq xin
  aSig oscili 0.5, iFreq
  xout aSig                  ; only outputting one — mismatch
endop
```

**Correct:**
```csound
opcode StereoGen, aa, i
  iFreq xin
  aSigL oscili 0.5, iFreq
  aSigR oscili 0.5, iFreq * 1.003
  xout aSigL, aSigR
endop
```

---

## 10. Accumulating into Global Variables Without Clearing

**Wrong:**
```csound
gaReverb init 0

instr 1
  aSig oscili 0.5, 440
  gaReverb = gaReverb + aSig   ; keeps accumulating across notes!
endin
```

**Correct — clear at the end of each k-cycle:**
```csound
gaReverb init 0

instr 1
  aSig oscili 0.5, 440
  gaReverb += aSig
endin

instr 99  ; master — runs after all voices
  aIn = gaReverb
  aRevL, aRevR reverbsc aIn, aIn, 0.85, 8000
  out(aRevL, aRevR)
  clear gaReverb    ; reset accumulator each k-period
endin
```

---

## 11. Unnecessary Rate Conversion in Arithmetic

Csound automatically promotes lower rates to higher rates in expressions. k-rate values are treated as constant for each k-period block when used in a-rate expressions. **Do not** use `upsamp` or other conversion for simple arithmetic.

**Unnecessary (overly cautious):**
```csound
aOffset  upsamp kOffset        ; not needed — k auto-promotes to a
aOut     = aSig + aOffset
```

**Correct — rate promotion is automatic:**
```csound
aOut = aSig * iAmp             ; i-rate in a-rate expression: valid
aOut = aSig * kAmp             ; k-rate in a-rate expression: valid (auto-promoted)
aOut = aSig * kAmp + kOffset   ; mixing k-rate and a-rate: valid
aOut = aSig * iAmp + kOffset   ; mixing i-rate and k-rate with a-rate: valid
```

**Rule:** The output rate of an expression is determined by the highest rate of its operands (i < k < a). Csound promotes lower-rate values automatically. This is fundamental to how Csound works.

---

## 12. Incorrect `reverbsc` Usage

**Wrong:**
```csound
aRev  reverbsc aSig, 0.85, 8000   ; wrong: missing second input channel
```

**Correct:**
```csound
aRevL, aRevR  reverbsc aSig, aSig, 0.85, 8000   ; stereo: input L and R
```

---

## 13. Forgetting to Set `massign` for MIDI

**Wrong:**
```csound
; Just writing an instr without routing MIDI
instr 1
  iMidi notnum
  ; ...
endin
```

**Correct:**
```csound
massign 0, 1    ; route all MIDI channels to instr 1 (0 = all channels)

instr 1
  iMidi notnum
  ; ...
endin
```

---

## 14. Using `p3` Incorrectly with `linsegr`

**Wrong:**
```csound
; Trying to force total duration using p3 — but linsegr handles release automatically
kEnv = linsegr(0, 0.01, 1, p3 - 0.1, 0.7, 0.1, 0)
; This can overshoot or produce wrong timings when release is triggered early
```

**Correct:**
```csound
; Let linsegr handle it — the sustain segment stretches to fill note duration
kEnv = linsegr(0, 0.01, 1, 0.1, 0.7, 0.2, 0)
; attack: 0→1 in 0.01s
; decay: 1→0.7 in 0.1s (sustain level)
; sustain: 0.7 (held until note-off)
; release: 0.7→0 in 0.2s (triggers on note-off)
```

---

## 15. String Channel Names with Spaces

**Wrong:**
```csound
chnset kVal, "my channel"    ; spaces in channel names cause issues
```

**Correct:**
```csound
chnset kVal, "myChannel"
chnset kVal, "my_channel"
```

---

## 16. Using `xin` in New-Style UDOs

In new-style UDOs, arguments are named directly in the declaration. Using `xin` is unnecessary and wrong.

**Wrong:**
```csound
opcode MyOsc(iFreq, kAmp):a
  iFreq, kAmp xin               ; ERROR: xin not needed in new-style
  aSig = oscili(kAmp, iFreq)
  xout aSig
endop
```

**Correct:**
```csound
opcode MyOsc(iFreq, kAmp):a
  aSig = oscili(kAmp, iFreq)    ; args available directly by name
  xout aSig
endop
```

---

## 17. Wrong Type Disambiguation Syntax

When calling polymorphic opcodes as functions, the `:type` suffix goes on the opcode name, not the variable.

**Wrong:**
```csound
asig = linen(1, 0, p3, .01):a    ; suffix on wrong side
aenv:a = expon(1, p3, 0.001)     ; type annotation on variable doesn't force opcode rate
```

**Correct:**
```csound
asig = linen:a(1, 0, p3, .01)    ; :type suffix on the opcode name
aenv = expon:a(1, p3, 0.001)     ; forces a-rate output from expon
iVal = random:i(0, 10)           ; forces i-rate output from random
```

---

## 18. Using `cpsmidi` with Arguments

`cpsmidi` reads directly from a live MIDI event — it takes **no arguments**. Use `cpsmidinn` to convert a numeric MIDI note to Hz.

**Wrong:**
```csound
iFreq = cpsmidi(p4)       ; ERROR: cpsmidi doesn't take arguments
iFreq = cpsmidi(iNote)    ; ERROR: same mistake
```

**Correct:**
```csound
iFreq = cpsmidinn(p4)     ; convert MIDI note number from p-field
iFreq = cpsmidinn(iNote)  ; convert MIDI note number from variable
iFreq = cpsmidi()          ; only in MIDI-triggered instruments (reads from event)
```

---

## 19. Old-Style Statement Syntax for Single-Output Opcodes

All single-output opcodes — including envelopes — must use functional calling style. The only exception is multi-output opcodes like `reverbsc` and `zdf_2pole`.

**Wrong:**
```csound
kEnv  madsr  0.01, 0.1, 0.7, 0.3              ; old statement style
kEnv  linsegr 0, 0.01, 1, 0.1, 0.7, 0.2, 0   ; old statement style
kEnv  transegr 0, 0.01, 0, 1, 0.2, -4, 0.7, 0.3, -4, 0  ; old statement style
aSig  vco2   0.5, 440                          ; old statement style
```

**Correct:**
```csound
kEnv = madsr(0.01, 0.1, 0.7, 0.3)
kEnv = linsegr(0, 0.01, 1, 0.1, 0.7, 0.2, 0)
kEnv = transegr(0, 0.01, 0, 1, 0.2, -4, 0.7, 0.3, -4, 0)
aSig = vco2(0.5, 440)
```

**Rule:** If an opcode returns a single value, always use `variable = opcode(args)`. Statement style (`variable opcode args`) is only acceptable for multi-output opcodes where `=` is not possible.
