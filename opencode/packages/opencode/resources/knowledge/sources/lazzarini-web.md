# Csound 7 Web Examples (Lazzarini/vanilla)

Reference examples from Victor Lazzarini's "vanilla" repository demonstrating Csound 7 browser API patterns. These use `@csound/browser@7` via CDN with the modern JavaScript API.

## Common API Pattern

All examples follow this initialization:

```javascript
const { Csound } = await import("https://cdn.jsdelivr.net/npm/@csound/browser@7/dist/csound.js")
const csound = await Csound()
await csound.setOption("-odac")    // realtime output
await csound.compileOrc(code)      // compile orchestra string
await csound.start()               // start engine
```

Key API methods: `compileOrc()`, `compileCSD()`, `start()`, `inputMessage()`, `setControlChannel()`, `getControlChannel()`, `evalCode()`, `tableCopyIn()`, `tableCopyOut()`, `getNode()`, `pause()`, `resume()`, `fs.writeFile()`.

---

## 1. Ping — Basic Oscillator

Simplest possible Csound 7 web instrument. Demonstrates `oscili`, `linenr`, `schedule`, and `inputMessage`.

```csound
instr 1
  out linenr(oscili(0dbfs*p4, p5), 0.01, 0.5, 0.01)
endin
schedule(1, 0, 1, 0.2, A4)
```

**Opcodes**: oscili, linenr, schedule, out
**API**: `compileOrc()`, `start()`, `inputMessage("i1 0 1 0.2 440")`

---

## 2. Penta — Polyphony with Fractional Instruments

Demonstrates polyphonic note control using fractional instrument numbers for individual note-off.

```csound
instr 1
  out linenr(vco2(0dbfs*p4, cpsmidinn(p5)), 0.01, 0.5, 0.01)
endin
```

**Opcodes**: vco2, cpsmidinn, linenr, out
**API**: `inputMessage("i1.NOTE 0 -1 0.2 NOTE")` for note-on, `inputMessage("i-1.NOTE 0 1 0.2 NOTE")` for note-off
**Pattern**: Fractional instrument numbers (`i1.60`, `i1.62`) allow independent note control. Negative instrument number (`i-1.60`) turns off a specific note.

---

## 3. Sliders — Real-time Control via Channels

Demonstrates `chnget` with `port` for smooth parameter control from JavaScript.

```csound
instr 1
  kamp = port(chnget:k("amp"), 0.01, -1)
  kfreq = port(chnget:k("freq"), 0.01, -1)
  out linenr(vco2(0dbfs*kamp, kfreq, 10), 0.01, 0.5, 0.01)
endin
schedule(1, 0, -1)
```

**Opcodes**: chnget, port, vco2, linenr, schedule, out
**API**: `setControlChannel("amp", value)`, `setControlChannel("freq", value)` — called from slider input handlers
**Pattern**: `port()` with `-1` init value smooths channel changes; indefinite note (`-1` duration) stays active until stopped.

---

## 4. Plucks — Recursive Scheduling and evalCode

Self-scheduling instrument with randomized parameters. Uses `evalCode()` to inject new code at runtime.

```csound
0dbfs = 1
seed 0
giNotes[] fillarray 45,48,52,55,60,62,64,67,69,72,74,76,79
giAmps[] fillarray 0.05,0.1,0.2,0.3,0.4,0.6
giDurs[] fillarray 0.3,0.075,0.1,0.2,0.15,0.4

instr 1
  prints "freq:%dHz", p5
  out linenr(pluck(p4, p5, p5, 0, 1), 0, 0.1, 0.01)
  icps = cpsmidinn(giNotes[gauss(6)+6])
  iamp = giAmps[gauss(3)+3]
  schedule(1, giDurs[gauss(3)+3], 800*iamp/icps, iamp, icps)
endin
schedule(1, 0, 0.01, 0.001, 500)
```

**Opcodes**: pluck, gauss, fillarray, cpsmidinn, schedule, prints, linenr
**API**: `evalCode()` — injects modified instrument code at runtime to change behavior, `on("message", handler)` — captures `prints` output
**Pattern**: Recursive `schedule()` inside `instr` creates self-perpetuating events with randomized timing and pitch.

---

## 5. Nodes — Web Audio Graph Integration

Connects Csound output to Web Audio API AnalyserNode for visualization.

```csound
instr 1
  a2 resonz rand(0dbfs/2), 5800+randh(5000,7), 150, 2
  out linenr(a2, 0.1, 0.1, 0.01)
endin
schedule(1, 0, -1);
```

**Opcodes**: resonz, rand, randh, linenr, out, schedule
**API**: `Csound({audioContext: actx})` — pass existing AudioContext, `getNode()` — get Csound's output as Web Audio node, then `node.connect(analyserNode)` for visualization
**Pattern**: Create AudioContext first, pass to Csound constructor, then route Csound output through Web Audio graph. Use `actx.suspend()`/`actx.resume()` for pause.

---

## 6. Stria — Loading External CSD Files

Loads and plays a complete `.csd` file from the server filesystem.

**API**: `compileCSD("stria.csd", 0)` — compile CSD from virtual filesystem, `fs.writeFile(dest, data)` — write fetched file to Csound's virtual FS, `rewindScore()` — restart score playback, `pause()`/`resume()` — transport control
**Pattern**: Fetch CSD file via `fetch()`, convert to `Uint8Array`, write to Csound's virtual filesystem with `csound.fs.writeFile()`, then compile with `compileCSD()`.

---

## 7. Render — Offline Rendering to File

Renders Csound output to a downloadable audio file (OGG format).

**API**: `setOption("-o output.ogg")` — set output file instead of `-odac`, `compileCSD()` — compile the CSD, `start()` — begin offline render, `fs.readFile()` — read rendered file from virtual FS, `URL.createObjectURL(blob)` — create download link
**Pattern**: Omit `-odac`, set output filename, render completes when score ends. Read result from virtual filesystem.

---

## 8. Reso — Synthesis with Visual Feedback (p5.js)

Resonant filter instrument with real-time parameter control and p5.js visualization.

```csound
0dbfs = 1
instr 1
  kcps port cpsmidinn(p5), 0.025, -1
  tigoto end
  afc = kcps + madsr(0.01, 0.5, 0.5, 0.3)*p6
  aosc = vco2(p4, kcps*.995) + vco2(p4, kcps*1.005)
  asig vclpf aosc*linsegr(0, 0.01, 1, 0, 1), afc, 0.7
  end:
  out asig*expsegr(0.3, 0.01, 0.3, 0.4, 0.001)
endin
```

**Opcodes**: vco2, vclpf, madsr, cpsmidinn, port, tigoto, linsegr, expsegr, out
**API**: `inputMessage("i1 0 -1 amp note cutoff")` — trigger with amplitude, MIDI note, and filter cutoff
**Pattern**: `tigoto` skips initialization on tied notes for legato. Detuned oscillators (`kcps*.995` + `kcps*1.005`) create width. `vclpf` is a resonant lowpass filter. `port()` smooths pitch changes for glide.

---

## 9. WTab — Function Table I/O

Demonstrates bidirectional table data transfer between JavaScript and Csound.

```csound
ifn ftgen 1, 0, 512, 2, 0
instr 1
  out linenr(oscili(0dbfs*p4, cpsmidinn(p5), 2), 0.01, 0.5, 0.01)
endin

instr 2
  ifn ftgen 2, 0, 16384, 30, 1, 0, sr/(2*cpsmidinn(60))
  chnset ifn, "newTable"
endin
```

**Opcodes**: ftgen, oscili, cpsmidinn, linenr, chnset, GEN02, GEN30
**API**: `tableCopyIn(tableNum, float32Array)` — write waveform data to table, `tableCopyOut(tableNum)` — read table data, `getControlChannel("newTable")` — check for new table, `inputMessage("i2 0 0")` — trigger table rebuild
**Pattern**: Draw waveform in canvas, copy to Csound table with `tableCopyIn()`. GEN30 creates band-limited version. Custom wavetable synthesis with real-time waveform editing.

---

## 10. Tonnetz — MIDI and SoundFont Playback

Loads external CSD and SoundFont files for MIDI-driven General MIDI playback via interactive Tonnetz grid.

**API**: `compileCSD("gm.csd")` — compile CSD with MIDI instruments, `fs.writeFile("gm.sf2", data)` — load SoundFont to virtual FS, `midiMessage(status, data1, data2)` — send MIDI note on/off
**Pattern**: Load SoundFont with `fs.writeFile()`, compile CSD that uses `sfload`/`sfplay`. Send MIDI directly via `midiMessage(0x90, note, velocity)` for note-on, `midiMessage(0x80, note, 0)` for note-off.

---

## 11. Rubber — Real-time Audio Input Processing

Processes live microphone input with time-stretching and pitch-shifting using `temposcal`.

```csound
0dbfs = 1
chn_k "pitch", 3
chn_k "time", 3
chn_k "amp", 3

instr 1
  ifw ftgen 0, 0, p4*sr, 2, 0
  ain inch 1
  aph phasor sr/(ftlen(ifw))
  tablew ain, aph, ifw, 1
  ktime chnget "time"
  kpitch chnget "pitch"
  kamp chnget "amp"
  kamp port kamp, 0.1
  asig temposcal ktime, kamp, kpitch, ifw, 1
  out asig
endin
schedule(1, 0, -1, 2)
```

**Opcodes**: inch, phasor, tablew, ftgen, ftlen, chnget, port, temposcal, schedule, out
**API**: `setOption("-iadc")` — enable audio input, `setControlChannel("pitch", value)`, `setControlChannel("time", value)`, `setControlChannel("amp", value)`
**Pattern**: Records input into circular buffer (function table), processes with `temposcal` for independent time/pitch control. `phasor` drives circular write position. Channel controls for real-time parameter adjustment.

---

## Summary: Key Csound 7 Web API Patterns

| Pattern | API Method | Use Case |
|---------|-----------|----------|
| Realtime output | `setOption("-odac")` | All live examples |
| Audio input | `setOption("-iadc")` | Microphone processing |
| Compile orchestra | `compileOrc(string)` | Inline orchestra code |
| Compile CSD file | `compileCSD(path)` | External .csd files |
| Send events | `inputMessage(string)` | Note triggers |
| Channel control | `setControlChannel(name, val)` | Slider/knob parameters |
| Read channel | `getControlChannel(name)` | Table notifications |
| Table write | `tableCopyIn(num, array)` | Waveform drawing |
| Table read | `tableCopyOut(num)` | Waveform display |
| Runtime code | `evalCode(string)` | Hot-swap instruments |
| Virtual FS | `fs.writeFile(path, data)` | Load external files |
| Web Audio | `getNode()` | Visualization, routing |
| MIDI | `midiMessage(s, d1, d2)` | MIDI note control |
| Offline render | `setOption("-o file.ogg")` | File rendering |
