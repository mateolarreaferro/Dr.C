# Csound AI Eval Prompts

These prompts test AI tools' ability to generate correct Csound 7 code. Each includes a description of what correct output should contain.

---

## Eval 1: Basic Oscillator with Envelope

**Prompt:**
> Write a Csound 7 instrument that plays a sawtooth wave at 440 Hz for 2 seconds with an ADSR envelope (attack 10ms, decay 100ms, sustain 0.7, release 200ms). The amplitude should be -10 dBFS. Include the full .csd file.

**Must-have in correct output:**
- `0dbfs = 1` in orchestra header
- `vco2` or `oscili` for oscillator (not `oscil`)
- `madsr` or `linsegr` for ADSR
- `ampdbfs(-10)` for amplitude (not a raw number without `0dbfs`)
- `out(aL, aR)` for stereo output (not deprecated `outs`)
- Variable prefixes correct: `aSig`, `kEnv`, `iAmp` etc.

**Common AI failures:**
- Missing `0dbfs = 1`
- Using `a` prefix for envelope (should be `k`)
- Using `0.3` as amplitude without referencing `0dbfs`
- Using `outs` (deprecated) instead of `out(aL, aR)`

---

## Eval 2: UDO Creation

**Prompt:**
> Write a Csound 7 UDO called `LowpassSweep` that takes an audio signal input and a k-rate sweep rate (in Hz), and returns a filtered audio signal. The filter cutoff should sweep from 200 Hz to 8000 Hz cyclically at the given rate. Use a Moog ladder filter.

**Must-have in correct output:**
- `opcode LowpassSweep(aSig, kRate):a` (new-style UDO syntax with named args)
- `xout aOut` — output with `xout`
- `moogladder` with correct 3-argument signature: `moogladder aSig, kCutoff, kRes`
- Cutoff oscillation using `oscili` on k-rate variable

**Common AI failures:**
- Using old-style type strings (`opcode LowpassSweep, a, ak` with `xin`)
- Missing `xout`
- Wrong `moogladder` signature (missing resonance argument)
- Using audio-rate (`a`) variable for cutoff frequency

---

## Eval 3: MIDI Instrument

**Prompt:**
> Write a Csound 7 .csd that sets up a MIDI-controlled synthesizer. It should: respond to MIDI note on/off with proper amplitude envelope, support pitch bend of ±2 semitones, use MIDI velocity for amplitude scaling, and include a master instrument for reverb that runs always.

**Must-have in correct output:**
- `massign 0, 1` (or specific channel)
- `notnum` and `veloc` opcodes
- `pchbend -2, 2` for pitch bend
- `cpsmidinn(iMidi)` for frequency conversion
- `f 0 3600` or similar to keep running for MIDI
- Channel bus (`chnmix`/`chnget`/`chnclear`) OR `ga` global variable with `clear`
- Master instrument with always-on score event

**Common AI failures:**
- Using `cpspch` instead of `cpsmidinn`
- No `massign`
- Forgetting to clear global audio bus each k-cycle
- No master instrument for reverb
- Missing `f 0` statement for MIDI mode

---

## Eval 4: Effects Chain UDO

**Prompt:**
> Write a Csound 7 UDO called `AnalogDelay` that takes: a stereo audio input (two a-rate signals), a delay time in milliseconds (k-rate), a feedback amount (k-rate, 0-1), and returns stereo audio. The delay should have subtle saturation on the feedback path.

**Must-have in correct output:**
- `opcode AnalogDelay(aSigL, aSigR, kDelayMs, kFeedback):(a,a)` — new-style with named args
- `vdelay` with correct ms arguments
- `distort1` or similar for saturation on feedback
- `xout aOutL, aOutR` — two outputs

**Common AI failures:**
- Using old-style type strings (`opcode AnalogDelay, aa, aakk` with `xin`)
- Using `delay` instead of `vdelay` (wrong opcode)
- `reverbsc` used when delay was requested
- Feedback applied after output (not in the loop)

---

## Eval 5: Frequency Conversion

**Prompt:**
> Write a Csound 7 instrument that plays the note A4 (concert A, 440 Hz), then up a perfect fifth (to E5, ~660 Hz), then up another perfect fourth (to A5, 880 Hz), each for 1 second. Use MIDI note numbers and correct conversion functions. Do not hardcode Hz values.

**Must-have in correct output:**
- `cpsmidinn(69)` for A4 (MIDI 69)
- `cpsmidinn(76)` for E5 (MIDI 76)  
- `cpsmidinn(81)` for A5 (MIDI 81)
- OR: `semitone(7)` and `semitone(5)` multipliers from base frequency
- NOT: `cpspch` notation

**Common AI failures:**
- Using `cpspch(8.09)` old notation
- Hardcoding 440, 660, 880 directly
- Wrong MIDI note numbers
- Forgetting that `cpsmidinn` takes a note number, not a frequency

---

## Eval 6: Correct `linseg` Usage

**Prompt:**
> Write a Csound 7 k-rate envelope that: starts at 0, rises to 1 over 50ms, falls to 0.6 over 200ms, then falls to 0 over 300ms. Use `linseg`.

**Must-have in correct output:**
```csound
kEnv = linseg(0, 0.05, 1, 0.2, 0.6, 0.3, 0)
```
- Functional calling style (not `kEnv linseg 0, ...`)
- 7 arguments (odd count: val, dur, val, dur, val, dur, val)
- All durations in seconds (not ms)
- `k` prefix on output variable

**Common AI failures:**
- Even number of arguments
- Durations in milliseconds instead of seconds
- `i` or `a` prefix instead of `k`
- Using `linsegr` (which adds release) when `linseg` was specified

---

## Eval 7: Array Usage

**Prompt:**
> Write a Csound 7 instrument that uses a k-rate array of 8 elements to store different filter cutoff values (200, 400, 600, 800, 1000, 1500, 2000, 3000 Hz), cycles through them at a rate of 2 steps per second, and applies each cutoff to a Butterworth lowpass filter on a sawtooth wave.

**Must-have in correct output:**
- `kArr[] init 8` — correct array declaration
- Element assignment: `kArr[0] = 200` etc.
- `kIndex` at k-rate to step through array
- `kArr[kIndex]` to read from array
- `butlp aSig, kArr[kIndex]` — filter using array value

**Common AI failures:**
- Using `i`-rate array when k-rate stepping is needed
- `iArr[kIndex]` — mixing rates in array index
- Incorrect array initialization syntax
- Using `tab` opcode (for ftables) instead of array indexing

---

## Scoring Rubric

For each eval:
- **Pass** (2 pts): Code is syntactically correct and logically correct
- **Minor errors** (1 pt): Mostly correct but has 1-2 small mistakes (wrong variable prefix, missing optional argument)
- **Fail** (0 pts): Fundamental errors (missing `0dbfs`, wrong opcode, missing `xout`, using deprecated syntax, etc.)

**Baseline score to beat:** Test your tool against these prompts without providing the reference files, then with them, to measure improvement.
