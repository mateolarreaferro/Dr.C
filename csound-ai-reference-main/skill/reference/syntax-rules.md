# Csound 7 Syntax Rules

## Rate System

Csound's execution model has three rates. Every variable and opcode operates at exactly one rate.

### Init Rate (`i`)
- Evaluated **once** when a note starts
- Used for fixed parameters: frequency, table lookups, computed constants
- `i`-rate code runs before the performance loop begins
- Cannot change during a note's lifetime

### Control Rate (`k`)
- Evaluated every **k-period** (every `ksmps` samples)
- Used for slowly-changing parameters: envelopes, LFOs, MIDI control
- At `sr=48000, ksmps=64`: k-rate runs at 750 Hz
- Most "modulation" signals are k-rate

### Audio Rate (`a`)
- Evaluated every **sample**
- Used for all audio signals
- Computationally most expensive

### Rate Promotion Rules
- **i-rate values can be used freely in k-rate and a-rate expressions.** This is fundamental to Csound. Example: `asig = vco2(p5, p4)` where p4 and p5 are i-rate is correct and idiomatic.
- **k-rate signals are auto-promoted to a-rate** when used in a-rate expressions. `aOut = aSig * kAmp` is perfectly valid — Csound treats the k-rate value as constant for each k-period block of samples.
- The output rate of an expression is determined by the **highest rate** of its operands: i < k < a.
- Use `init` to set a k-rate variable at i-time: `kAmp init 0.5`
- Use type-disambiguated calls when a function is polymorphic: `linen:a()`, `random:i()`, `expon:a()`

---

## Variable Naming

### Prefix Convention (Traditional)
```
[rate prefix][descriptive name]

iFreq     ; i-rate frequency
kCutoff   ; k-rate filter cutoff
aSig      ; a-rate audio signal
aLeft     ; a-rate left channel
kEnv      ; k-rate envelope
SFilename ; string filename
```

### Explicit Type Annotations (Csound 7)
```csound
glid:k expon 440, p3, 880     ; k-rate variable named "glid"
sigLeft:a vco2 0.5, glid       ; a-rate audio signal
signals:a[] init 4             ; a-rate array
tick:i = itick % itotal        ; i-rate
test:b init true               ; boolean type
```

Local variables are scoped to their instrument or UDO. Global variables use `g` prefix:
```csound
gaReverb  init 0   ; global audio accumulator
gkTempo   init 120 ; global k-rate value
gi_scale[] = array(0, 2, 4, 5, 7, 9, 11)  ; global i-rate array
```

Arrays use `[]` suffix on the variable name: `iArr[]`, `kArr[]`, `aArr[]`, `SNames[]`.
2D arrays: `ga_sbus[][] init 16, 2`

---

## UDO (User-Defined Opcodes)

Csound 7 supports two UDO syntax styles.

### New-Style Syntax (Csound 7 — Preferred)

```csound
opcode Name(args):returnType
  ; body — args are directly available by name, no xin needed
  xout result
endop
```

**Input types are inferred from arg name prefixes or declared with `:type` annotations:**
```csound
; Type inferred from i-prefix
opcode set_tempo(itempo):void
  gk_tempo init itempo
endop

; Explicit type annotation
opcode myadd(value0:i):i
  xout value0 + 1
endop

; Multiple returns
opcode melodic(kdurs[], kpchs[], kamps[]):(i,i,i)
  ; ...
  xout idur, ipch, iamp
endop

; Array parameters and return
opcode cycle(indx, kvals[]):k
  kval = kvals[indx % lenarray(kvals)]
  xout kval
endop

opcode remove(ival, karr[]):k[]
  kout[] init lenarray(karr)
  kout = karr
  xout kout
endop

; Polymorphic overloading — same name, different signatures
opcode now():i
  xout i(gk_now)
endop
opcode now():k
  xout gk_now
endop
```

**Optional argument type codes (new-style):**
- `:o` = optional i-rate (default 0), `:p` = (default 1), `:j` = (default -1)
- `:O` = optional k-rate (default 0), `:P` = (default 1), `:J` = (default -1)

### Old-Style Syntax (Still Valid)

```csound
opcode Name, outTypes, inTypes
  [inputs xin]
  ; body
  [xout outputs]
endop
```

### Type Strings (Old-Style)

| Character | Meaning |
|-----------|---------|
| `0` | No arguments (use for no inputs or no outputs) |
| `i` | i-rate scalar |
| `k` | k-rate scalar |
| `a` | a-rate signal |
| `S` | String |
| `f` | f-signal (spectral) |
| `k[]` | k-rate array |
| `a[]` | a-rate array |
| `i[]` | i-rate array |
| `o` | Optional k-rate, defaults to 0 |
| `O` | Optional i-rate, defaults to 0 |
| `j` | Optional k-rate, defaults to -1 |
| `J` | Optional i-rate, defaults to -1 |
| `p` | Optional i-rate, defaults to 0.5 |

### Calling Opcodes as Functions

In Csound 7, **any opcode** (built-in or UDO) can be called using functional syntax. **Always use functional style for single-output opcodes** — this includes oscillators, envelopes, filters, and all other opcodes that return one value:

```csound
; Functional style (Csound 7 — ALWAYS use for single-output opcodes)
aSig = vco2(p5, p4)
aSig = zdf_ladder(aSig, expon(10000, p3, 400), 5)
aSig *= linen:a(1, 0, p3, .01)
kEnv = madsr(0.01, 0.1, 0.7, 0.3)
kEnv = linsegr(0, 0.01, 1, 0.1, 0.7, 0.2, 0)
kEnv = transegr(0, 0.01, 0, 1, 0.2, -4.2, 0.7, 0.3, -4.2, 0)
pan_verb_mix(aSig, 0.5, 0.2)

; Statement style — ONLY for multi-output opcodes
aL, aR reverbsc aDryL, aDryR, kFeedback, kCutoff
aLP zdf_2pole aSig, kCutoff, kRes
```

**Type disambiguation** — when an opcode is polymorphic, use `:type` suffix:
```csound
asig *= linen:a(1, 0, p3, .01)    ; force a-rate output
aenv = expon:a(1, p3, 0.001)      ; force a-rate
iVal = random:i(0, 10)            ; force i-rate
iLen = lenarray:i(kArr)            ; force i-rate
arr:k[] = genarray:k[](0, 10)     ; k-rate array output
```

### Examples (New-Style — Preferred)

```csound
; No inputs, stereo audio output (use multiple return values)
opcode StereoNoise():(a,a)
  aNoise1 = random:a(-1, 1)
  aNoise2 = random:a(-1, 1)
  xout aNoise1, aNoise2
endop

; i-rate freq, k-rate amp, a-rate output
opcode ToneGen(iFreq, kAmp):a
  aSig = oscili(kAmp, iFreq)
  xout aSig
endop

; Optional argument with :o (defaults to 0)
opcode SoftClip(aSig, kDrive, kThreshold:O):a
  kThresh = (kThreshold == 0) ? 0.8 : kThreshold
  aOut = distort1(aSig, kDrive, kThresh, 0, 0)
  xout aOut
endop

; Recursive UDO
opcode Harmonics(iBaseFreq, iNumHarmonics, iHarmonic):a
  aSig = oscili(1/iHarmonic, iBaseFreq * iHarmonic)
  if iHarmonic < iNumHarmonics then
    aSub = Harmonics(iBaseFreq, iNumHarmonics, iHarmonic + 1)
    aSig += aSub
  endif
  xout aSig
endop

; Void return — side-effect only UDO
opcode set_tempo(itempo):void
  gk_tempo init itempo
endop

; Polymorphic overloading — same name, different return types
opcode now():i
  xout i(gk_now)
endop
opcode now():k
  xout gk_now
endop
```

### Examples (Old-Style — Still Valid)

```csound
opcode StereoNoise, aa, 0
  aNoise1 rand 1
  aNoise2 rand 1
  xout aNoise1, aNoise2
endop

opcode ToneGen, a, ik
  iFreq, kAmp xin
  aSig oscili kAmp, iFreq
  xout aSig
endop
```

---

## Control Flow

```csound
; If/then/else (i-rate)
if iVal > 0 then
  iResult = 1
elseif iVal == 0 then
  iResult = 0
else
  iResult = -1
endif

; Rate-specific conditionals: use ithen/kthen to force rate
if iCondition == 1 ithen
  iResult = 100
endif

if kVal > kThresh kthen
  kState = 1
endif

; If/then/else (k-rate)
if kVal > kThresh then
  kState = 1
endif

; While loop (i-rate only)
iCount = 0
while iCount < 8 do
  iArr[iCount] = iCount * 100
  iCount += 1
od
```

---

## Struct Types (Csound 7)

```csound
; Define a struct
struct Point x:i, y:i
struct Note freq:k, amp:k, dur:i

; Members can use explicit types or prefix convention
struct MyType imaginary:k, real:k, kimaginary, kreal

; Create and initialize
var1:Point init 1, 2
note:Note init 440, 0.5, 1.0

; Member access
iX = var1.x
var1.y = 10

; Arrays of structs
points:Point[] init 4
points[0].x = 100

; Structs in UDOs
opcode processPoint(p:Point):Point
  result:Point init p.x + 1, p.y + 1
  xout result
endop
```

---

## Instrument Parameters

`p` fields from the score:
- `p1` — instrument number
- `p2` — start time
- `p3` — duration (negative = held until note-off)
- `p4`, `p5`, ... — user-defined

```csound
instr 1
  iMidi = p4           ; e.g., MIDI note number
  iVel  = p5           ; velocity 0-127
  iFreq = cpsmidinn(iMidi)
  iAmp  = (iVel/127) * 0dbfs * 0.5
endin
```

For **indefinite duration** (held until explicit note-off), use negative `p3`:
```csound
; Score: i 1 0 -1   ; starts at 0, held until i 1 0 0 (note-off)
```

---

## Mathematical Operators and Functions

```csound
; Standard operators
iVal = a + b
iVal = a - b
iVal = a * b
iVal = a / b
iVal = a ^ b    ; power
iVal = a % b    ; modulo

; Built-in math functions
iVal = abs(x)
iVal = int(x)
iVal = frac(x)
iVal = floor(x)
iVal = ceil(x)
iVal = round(x)
iVal = sqrt(x)
iVal = log(x)
iVal = log2(x)
iVal = log10(x)
iVal = exp(x)
iVal = sin(x)     ; x in radians
iVal = cos(x)
iVal = atan(x)
iVal = atan2(y, x)

; Conditional expression (ternary)
iVal = (condition) ? trueVal : falseVal
kVal = (kSig > 0.5) ? 1 : 0
```

---

## Tables (Ftables)

Ftables are numbered arrays of floats, often used as wavetables or data stores.

```csound
; Score-defined tables
f tableNum  startTime  size  genRoutine  [args...]

; Common GEN routines
f 1  0  4096  10  1              ; GEN10: sine wave (harmonic 1)
f 2  0  4096  10  1 0 0.5 0 0.2 ; GEN10: harmonics 1,3,5 mixed
f 3  0  4096  7   0 4096 1       ; GEN07: linear ramp 0→1
f 4  0  4096  5   0.001 4096 1   ; GEN05: exponential ramp (no zero)
f 5  0  16    -2  100 200 300 400 ; GEN02: literal values (no size normalization with -)

; Orchestra-defined tables (Csound 7)
iTable  ftgen  0, 0, 4096, 10, 1          ; returns table number
iTable  ftgen  0, 0, 4096, -7, 0, 2048, 1, 2048, 0  ; triangle

; Reading tables
iVal  tab_i  iIndex, iTable         ; i-rate read
kVal  tab    kIndex, iTable         ; k-rate read
aVal  tablei aIndex, iTable, 1      ; a-rate interpolating read (1=wrap)
```

---

## Strings

```csound
SFilename  = "/path/to/file.wav"
SFormatted sprintfk "Frequency: %f Hz", kFreq

; String comparison
if strcmp(S1, S2) == 0 then
  ; equal
endif

; Concatenation
SFull strcat SPath, SFilename
```

---

## Printing and Debugging

```csound
print   iVal                    ; print i-rate value once
printk  kInterval, kVal         ; print k-rate value every kInterval seconds
printk2 kVal                    ; print whenever kVal changes
prints  "Message\n"             ; print string
printf  "Val: %f\n", ktrig, kVal ; conditional printf (prints when ktrig != 0)
```
