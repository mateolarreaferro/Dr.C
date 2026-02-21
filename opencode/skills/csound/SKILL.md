---
name: csound
description: Csound/Cabbage instrument design and audio programming
version: 0.1.0
tags:
  - csound
  - cabbage
  - audio
  - synthesis
  - dsp
---

# Csound/Cabbage Reference

## CSD File Structure

Every Csound instrument for Cabbage follows this structure:

```
<Cabbage>
; Widget definitions for the GUI
form caption("My Synth") size(600, 400), colour(30, 30, 30)
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  ; Instrument code here
endin
</CsInstruments>
<CsScore>
f0 z  ; Keep running indefinitely
</CsScore>
</CsoundSynthesizer>
```

## Cabbage Widget Reference

### Common Widget Properties
- `bounds(x, y, width, height)` — Position and size
- `channel("name")` — Channel name for chnget/chnset
- `text("Label")` — Display text
- `colour(r, g, b)` — Widget color
- `fontColour(r, g, b)` — Text color
- `trackerColour(r, g, b)` — Active element color

### Widget Types

**rslider** — Rotary knob
```
rslider bounds(10, 10, 80, 80), channel("cutoff"), range(20, 20000, 1000, 0.5, 1), text("Cutoff"), trackerColour(255, 165, 0)
```

**hslider** — Horizontal slider
```
hslider bounds(10, 100, 200, 30), channel("volume"), range(0, 1, 0.7, 1, 0.01), text("Volume")
```

**combobox** — Dropdown
```
combobox bounds(10, 140, 120, 25), channel("waveform"), text("Saw", "Square", "Tri", "Sine"), value(1)
```

**button** — Toggle/momentary
```
button bounds(10, 180, 80, 25), channel("bypass"), text("Off", "On"), latched(1)
```

**checkbox** — On/off toggle
```
checkbox bounds(10, 220, 80, 20), channel("reverb"), text("Reverb"), value(0)
```

**keyboard** — MIDI keyboard
```
keyboard bounds(0, 300, 600, 100)
```

**groupbox** — Visual grouping
```
groupbox bounds(5, 5, 290, 200), text("Oscillator"), colour(40, 40, 40)
```

## Common Opcodes

### Oscillators
- `vco2 aAmp, kFreq [, iMode]` — Band-limited oscillator (0=saw, 2=square, 4=tri)
- `poscil aAmp, kFreq, iFn` — Precise oscillator with function table
- `oscil aAmp, kFreq, iFn` — Simple oscillator

### Filters
- `moogladder aIn, kCutoff, kResonance` — Moog-style ladder filter
- `lpf18 aIn, kCutoff, kResonance, kDistortion` — 3-pole low-pass
- `zdf_2pole aIn, kCutoff, kQ [, iMode]` — Zero-delay feedback filter
- `butterlp aIn, kCutoff` — Butterworth low-pass
- `butterhp aIn, kCutoff` — Butterworth high-pass

### Envelopes
- `madsr iAttack, iDecay, iSustain, iRelease` — MIDI ADSR
- `linsegr i1, t1, i2 [, t2, i3...], iRelTime, iFinal` — Linear segments with release
- `expsegr i1, t1, i2 [, t2, i3...], iRelTime, iFinal` — Exponential segments

### Effects
- `aL, aR reverbsc aInL, aInR, kFeedback, kCutoff` — Stereo reverb
- `aOut delay aIn, iDelTime` — Simple delay
- `aOut vdelay aIn, aDelTime, iMaxDel` — Variable delay

### Channel I/O
- `kVal chnget "channel"` — Read channel value
- `chnset kVal, "channel"` — Write channel value
- `kVal port kVal, kHalfTime` — Portamento smoothing

### Output
- `outs aLeft, aRight` — Stereo output
- `aOut limit aIn, -1, 1` — Clip to safe range

## Widget-Channel Binding Pattern

Every Cabbage widget channel MUST have a corresponding `chnget` with smoothing:

```csound
; In <Cabbage>:
rslider channel("cutoff"), range(20, 20000, 1000, 0.5), text("Cutoff")

; In <CsInstruments>:
kCutoff chnget "cutoff"
kCutoff port kCutoff, 0.01
```

## Standard ksmps Values
- `ksmps = 16` — Low latency, higher CPU
- `ksmps = 32` — Default, good balance
- `ksmps = 64` — Lower CPU, acceptable latency
- `ksmps = 128` — Minimal CPU, higher latency
