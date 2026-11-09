# Multi-Engine Performance System

**Complete 4-slot photo-to-synthesis performance tool with 5 engines per slot + folder-based image loading**

## 🎯 What It Does

Load up to **4 photos or folders simultaneously** (slots A, B, C, D), assign each a synthesis engine (FM / Granular / Additive / Percussive / Waveguide), and perform with flexible routing and mixing.

**NEW**: Each slot can load entire **folders of images** with automatic playback (sequential/random) and **5 timing modes** (manual, scan-complete, fixed-rate, random-rate, MIDI-triggered).

## ✨ Features

### Core System
- **4 Independent Slots** - Each with its own photo, engine, and parameters
- **5 Synthesis Engines** per slot:
  - **FM Synthesis** - 3-operator detuned carriers with Moog ladder filter
  - **Granular** - Cloud synthesis with density/pitch/duration control
  - **Additive** - 16-partial harmonic synthesis
  - **Percussive** - Event-triggered gbuzz oscillators with random variations (inspired by Iain McCurdy)
  - **Waveguide Resonator** - Dual delay + lowpass feedback resonators (inspired by Iain McCurdy)
- **Dynamic Parameter UI** - Controls change based on selected engine
- **Real-time Photo Scanning** - Each slot scans its photo independently
- **Visual Scan Overlays** - See exactly where each slot is scanning

### Playback & Routing
- **15 Playback Modes**:
  - **Solo**: A, B, C, or D individually
  - **Pair**: AB, AC, AD, BC, BD, CD
  - **Trio**: ABC, ABD, ACD, BCD
  - **Quad**: All four (ABCD)
- **Active Slot Highlighting** - Visual feedback for what's playing
- **Timeline Visualization** - Real-time display of active slots

### Sequence Mode
- **Auto-Sequence** - Automatically cycle through slots
- **4 Pattern Options**:
  - A→B→C→D (linear)
  - A→B→D→C (alternate)
  - A→C→B→D (skip)
  - Random
- **Adjustable Cycle Time** - 1-20 seconds per step

### Master Controls
- **Master Gain** - Global amplitude control (0-1)
- **Reverb Size** - Shared Schroeder reverb (0.3-0.98)
- **Preset System** - Save/load entire 4-slot configurations

### Folder-Based Image Loading (NEW)
- **Load Folders** - Select folders containing multiple images
- **2 Playback Modes**:
  - **Sequential** - Images play in filename order, loop at end
  - **Random** - Random image selection from folder
- **5 Timing Modes**:
  - **Manual Only** - User controls with Prev/Next buttons
  - **On Scan Complete** - New image when scanline wraps
  - **Fixed Rate** - Timer-based (1-60 seconds)
  - **Random Rate** - Variable intervals (min/max range)
  - **MIDI Note** - Trigger on specific MIDI note
- **Independent per Slot** - Each slot can have different folder/timing
- **Status Display** - Shows "Image 3/24" counter

## 🚀 Quick Start

```bash
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
python3 -m http.server 8080
```

Open: **http://localhost:8080/photo_multi_engine_complete.html**

## 📖 How to Use

### 1. Start Audio Engine
Click **"🎵 Start Audio Engine"** and wait 3-5 seconds for Csound 7 to load.

### 2. Load Photos or Folders
**Single Photos:**
- **Drag & drop** images onto slots A, B, C, D
- Or **click** a slot to browse files
- Supported formats: JPG, PNG, WebP

**Folders (NEW):**
- Click **📁 Folder** button in any slot
- Select folder containing images
- Choose playback mode (Sequential/Random)
- Choose timing mode (Manual/Scan/Fixed/Random/MIDI)
- Adjust timing parameters
- Use **⬅ Prev** / **➡ Next** buttons for manual control

### 3. Select Engines
Each slot has an **Engine** dropdown:
- **FM Synthesis** - 6 parameters (freq, ratio, index, cutoff, res, amp)
- **Granular** - 5 parameters (density, pitch, duration, spread, amp)
- **Additive** - 4 parameters (fundamental, brightness, inharmonicity, amp)
- **Percussive** - 6 parameters (density, pitchLo, pitchHi, harmonics, decay, amp)
- **Waveguide Resonator** - 7 parameters (freq1, freq2, cutoff1, cutoff2, feedback1, feedback2, amp)

### 4. Choose Playback Mode
Select from the **Playback Mode** dropdown:
- Start with **Quad** to hear all 4 slots
- Try **Solo: A** to isolate one slot
- Experiment with **Pair** and **Trio** modes

### 5. Play
- Click **▶ Play** to start synthesis
- Click **■ Stop** to stop all slots
- Watch the **green scan lines** move across photos
- Adjust **parameters** in real-time

### 6. Sequence Mode (Optional)
- Click **🔄 Auto-Sequence: OFF** to enable auto-cycling
- Adjust **Cycle Time** (how long each step lasts)
- Select **Pattern** (ABCD, ABDC, ACBD, or Random)
- System will automatically switch between slots

## 🎛️ Parameter Mapping

Each engine maps photo features differently:

### FM Synthesis
- **Brightness** → Carrier Frequency (50-1000 Hz)
- **Contrast** → FM Index (0-20)
- **Saturation** → Filter Cutoff (200-9000 Hz)

### Granular Synthesis
- **Contrast** → Grain Density (1-200 grains/s)
- **Brightness** → Pitch Center (50-2000 Hz)
- **Saturation** → Pitch Spread (0-100%)

### Additive Synthesis
- **Brightness** → Fundamental Frequency (50-550 Hz)
- **Saturation** → Brightness/Amplitude (0-1)
- **Contrast** → Inharmonicity (0-10%)

### Percussive Synthesis
- **Contrast** → Trigger Density (0.5-50 events/s)
- **Brightness** → Pitch Low (50-500 Hz)
- **Saturation** → Pitch High (100-2000 Hz)
- **Saturation** → Harmonic Count (1-16 harmonics)

### Waveguide Resonator
- **Brightness** → Frequency 1 (20-5000 Hz)
- **Saturation** → Frequency 2 (20-5000 Hz)
- **Contrast** → Cutoff 1 (50-12000 Hz)
- **1 - Contrast** → Cutoff 2 (50-12000 Hz)
- **Brightness** → Feedback 1 (0-0.45)
- **Saturation** → Feedback 2 (0-0.45)

## 💾 Presets

### Save Preset
1. Configure all 4 slots (photos, engines, parameters)
2. Set playback mode and master controls
3. Click **💾 Save**
4. Enter a name
5. Preset saved to browser localStorage

### Load Preset
1. Select preset from dropdown
2. Click **📂 Load**
3. All settings restored (except photos - reload those manually)

### Delete Preset
1. Select preset
2. Click **🗑 Delete**
3. Confirm deletion

## 🎨 Creative Ideas

### Ambient Layers
- **Slot A**: FM (slow scan, low index)
- **Slot B**: Additive (bright, harmonic)
- **Slot C**: Granular (sparse density)
- **Slot D**: FM (high reverb)
- **Mode**: Quad
- **Sequence**: OFF

### Rhythmic Pulses
- **All Slots**: Granular
- **Densities**: 40, 80, 120, 160 grains/s
- **Mode**: Solo A → Solo B → Solo C → Solo D
- **Sequence**: ON (2s cycle, ABCD pattern)

### Timbral Morph
- **Slot A**: FM (bright, high index)
- **Slot B**: FM (dark, low cutoff)
- **Mode**: Pair AB
- **Manually adjust**: Cross-fade by changing individual amps

### Metallic Percussion (NEW)
- **Slot A**: Percussive (high density, narrow pitch range)
- **Slot B**: Waveguide (metallic resonance, high feedback)
- **Slot C**: Percussive (low density, wide pitch range)
- **Slot D**: Waveguide (dual resonators, contrasting frequencies)
- **Mode**: Quad
- **Sequence**: ON (3s cycle, Random pattern)

### Resonant Textures (NEW)
- **All Slots**: Waveguide Resonator
- **Freq1/Freq2**: Harmonically related (200/300, 400/600, 150/225, 250/375)
- **Feedback**: Vary per slot (0.2, 0.3, 0.25, 0.35)
- **Mode**: Trio ABC or Quad
- **Sequence**: OFF (let all resonate together)

### Generative Visual Flow (NEW - Folder Mode)
- **Slot A**: Folder of 50 abstract photos, Random, Random Rate (5-20s)
- **Slot B**: Folder of 30 nature photos, Sequential, Fixed Rate (8s)
- **Slot C**: Folder of 20 textures, Random, On Scan Complete
- **Slot D**: Folder of 10 presets, Sequential, MIDI Note 60
- **Mode**: Quad
- **Result**: Never-repeating generative visual composition with MIDI control

### Generative Performance
- **All Slots**: Different engines
- **Photos**: High-contrast images
- **Mode**: Quad
- **Sequence**: ON (Random pattern, 5s cycle)

## 🔧 Technical Details

### Architecture
- **Csound 7.0.0** via `@csound/browser` WASM
- **Instrument Numbers**:
  - Slot A: 10 (FM), 11 (Granular), 12 (Additive)
  - Slot B: 20 (FM), 21 (Granular), 22 (Additive)
  - Slot C: 30 (FM), 31 (Granular), 32 (Additive)
  - Slot D: 40 (FM), 41 (Granular), 42 (Additive)
  - Master Reverb: 90
- **Sample Rate**: 48000 Hz
- **ksmps**: 32 (control rate ~1500 Hz)
- **Reverb**: Shared `reverbsc` bus (gaRevL, gaRevR)

### Image Processing
- Photos downsampled to max 480px for performance
- Vertical scan line analysis (simplified from full FM v3)
- Real-time feature extraction: hue, saturation, brightness, contrast
- Scan position: 0→1 loop at ~0.002/frame

### Performance Optimization
- Parameters sent via `setControlChannel()` (k-rate updates)
- Instruments run indefinitely (`-1` duration)
- Global audio accumulators cleared every k-cycle
- Visual overlays use HTML5 Canvas

## 🌐 Browser Compatibility

| Browser | Status |
|---------|--------|
| Chrome 90+ | ✅ Recommended |
| Firefox 88+ | ✅ Full support |
| Safari 14+ | ✅ Works (may need user gesture) |
| Edge 90+ | ✅ Full support |

**Requirements:**
- ES6 modules
- WebAssembly
- Web Audio API
- Canvas API
- FileReader API
- localStorage

## 🐛 Troubleshooting

### "Failed to load module"
**Problem**: Opening HTML file directly (`file://`)  
**Solution**: Must serve via HTTP (`python3 -m http.server 8080`)

### No sound after clicking Play
1. Check browser console for errors (F12)
2. Verify audio engine started successfully
3. Ensure at least one slot has a photo loaded
4. Check system audio settings
5. Try reloading page

### Photos won't load
- Use JPG, PNG, or WebP formats
- Try smaller images (<5MB)
- Check browser console for errors

### Clicking engine dropdown stops sound
- This is expected - changing engines restarts the instrument
- Stop playback before switching engines for clean transitions

### Sluggish performance
- Close other browser tabs
- Use smaller photos
- Reduce number of active slots
- Lower reverb size

## 📊 Comparison to Other Engines

| Feature | Multi-Engine | FM v3 FIXED | Granular FIXED |
|---------|-------------|-------------|----------------|
| Photo slots | 4 | 1 | 1 |
| Synthesis engines | 3 per slot | FM only | Granular only |
| Parameters | 4-6 per slot | 14 total | 8 total |
| MIDI Learn | ❌ Not yet | ✅ Full | ✅ Full |
| Parameter locks | ❌ Not yet | ✅ Yes | ✅ Yes |
| Presets | ✅ Basic | ✅ Advanced | ✅ Advanced |
| Playback modes | ✅ 15 modes | — | — |
| Sequence mode | ✅ Yes | — | — |
| Timeline viz | ✅ Yes | — | — |

## 🔮 Future Enhancements

### Planned (Short-term)
- [ ] MIDI Learn per slot parameter
- [ ] Parameter locks (prevent randomization)
- [ ] Cross-fade matrix (smooth transitions between slots)
- [ ] Factory presets (starter configurations)
- [ ] Better scan line visualization (waveform profile)

### Wishlist (Long-term)
- [ ] Per-slot effects (delay, chorus, distortion)
- [ ] Photo morphing (blend between two images)
- [ ] Webcam input per slot
- [ ] OSC control for external DAWs
- [ ] Export audio stems (4 separate WAV files)
- [ ] Preset sharing (cloud storage)

## 📝 Notes

- Presets **do not save photos** (localStorage size limits) - you must reload photos after loading a preset
- Engine switching while playing will cause a brief audio glitch
- All slots share one reverb bus (gaRevL/gaRevR)
- Granular synthesis uses event scheduling (instr 99) - may cause CPU spikes at high densities
- Additive synthesis uses a `while` loop for 16 partials - CPU-intensive

## 🎓 Learning Resources

- [Csound Documentation](https://csound.com/docs/manual/index.html)
- [FM Synthesis Theory](https://flossmanual.csound.com/sound-synthesis/frequency-modulation)
- [Granular Synthesis Guide](https://flossmanual.csound.com/sound-synthesis/granular-synthesis)
- [Additive Synthesis Basics](https://flossmanual.csound.com/sound-synthesis/additive-synthesis)

---

**Built with Csound 7 + Web Audio**

Complete 4-slot multi-engine performance system for real-time photo-to-sound synthesis.
