# Photo Additive Synthesizer v3 - Complete Edition

**16-partial additive synthesis with full MIDI Learn, parameter locks, and advanced presets**

## 🎯 What's New in v3

### Complete MIDI Integration
- **MIDI Device Selection** - Choose from multiple connected controllers
- **MIDI Learn** - Click any parameter → move controller → binding saved
- **MIDI Override Mode** - Direct control or range adjustment
- **Visual Feedback** - CC# labels, learning state indicators
- **Persistent Bindings** - Saved to localStorage

### Parameter Locks
- **🔒/🔓 Buttons** - Lock any of the 5 parameters
- **Smart Randomization** - Locked parameters skip randomization
- **Lock State in Presets** - Saved with each preset

### Advanced Preset System
- **Photo Capture** - Images saved as base64 in presets (up to 800px)
- **3 Factory Presets** - Starter configurations included
- **User Presets** - Unlimited custom presets
- **Preset Management**:
  - Save as... (new preset)
  - Rename (user presets only)
  - Delete (user presets only)
  - Reorder (⬆⬇ buttons)
  - Export/Import JSON
- **Keyboard Shortcuts**:
  - 1-9: Load preset slot
  - Shift+1-9: Quick save to slot
  - ↑↓: Navigate presets

### Other Improvements
- **Keyboard Shortcuts** - Space, R, 1-9, Shift+1-9, ↑↓, ?
- **Help Dialog** - Complete reference (press ?)
- **Scan Speed Control** - Adjustable scan rate
- **Improved UI** - Cleaner parameter rows, better visual hierarchy

---

## 🚀 Quick Start

```bash
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
python3 -m http.server 8080
```

Open: **http://localhost:8080/photo_additive_web_v3_complete.html**

---

## 📖 How to Use

### 1. Start Audio Engine
Click **"🎵 Start Audio"** and wait for Csound 7 to initialize.

### 2. Load a Photo
- **Drag & drop** an image onto the photo zone
- Or click **"📂 Load photo..."**
- Supported formats: JPG, PNG, WebP

### 3. Adjust Parameters (5 core controls)

| Parameter | Range | Effect |
|-----------|-------|--------|
| **Fundamental** | 50-550 Hz | Base frequency of harmonic series |
| **Brightness** | 0-1 | Overall amplitude multiplier |
| **Inharmonicity** | 0-10% | Deviation from perfect harmonic ratios |
| **Spectral Tilt** | 0-1 | High-frequency roll-off (0=bright, 1=dark) |
| **Master Gain** | 0-1 | Output level |

### 4. Press ▶ Scan
Watch the **green scan line** move across the photo. The **spectrum visualizer** shows real-time harmonic amplitudes (16 bars).

### 5. MIDI Learn (Optional)

**Setup:**
1. Connect MIDI controller (hardware or virtual)
2. Select device from **MIDI Device** dropdown
3. Click **"🎛️ MIDI Learn: OFF"** to turn **ON**

**Bind a Parameter:**
1. Click any **parameter name** (e.g., "Fundamental")
2. Parameter turns **red** with pulsing animation
3. Move a **knob/fader** on your controller
4. Binding saved! **CC#** appears next to parameter

**Two Control Modes:**
- **MIDI Override Mode OFF** (default): MIDI adjusts parameter range
- **MIDI Override Mode ON**: MIDI directly controls value (ignores photo)

### 6. Lock Parameters
- Click **🔓** to lock → **🔒**
- Locked parameters skip randomization
- Lock state saved in presets

### 7. Save Presets
1. Configure all parameters + load a photo
2. Click **💾 Save as...**
3. Enter a name
4. Preset saved with photo (base64)

---

## 🎹 Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Space** | Toggle scan play/pause |
| **R** | Randomize unlocked parameters |
| **1-9** | Load preset slot 1-9 |
| **Shift+1-9** | Quick save to slot 1-9 |
| **↑ Up Arrow** | Previous preset |
| **↓ Down Arrow** | Next preset |
| **?** | Show help dialog |

---

## 🎛️ Factory Presets

### 1. Pure Harmonics
- **Fundamental**: 110 Hz
- **Brightness**: 0.8
- **Inharmonicity**: 0.5%
- **Spectral Tilt**: 0.3 (bright)
- **Use for**: Clean, organ-like tones

### 2. Organic Texture
- **Fundamental**: 220 Hz
- **Brightness**: 0.6
- **Inharmonicity**: 5%
- **Spectral Tilt**: 0.6 (mid)
- **Use for**: Natural, evolving textures

### 3. Dark Evolving
- **Fundamental**: 80 Hz
- **Brightness**: 0.3
- **Inharmonicity**: 2%
- **Spectral Tilt**: 0.85 (dark)
- **Use for**: Deep, bass-heavy atmospheres

---

## 🔧 Technical Details

### Synthesis Architecture
- **16 Sine Oscillators** - One per partial (1f, 2f, 3f... 16f)
- **Inharmonicity** - Each partial slightly detuned: `f * (n + n*inharm*0.01)`
- **Spectral Tilt** - Progressive amplitude reduction for high partials
- **Portamento** - Smooth parameter changes (50ms glide)

### Image Analysis
1. Photo scanned **vertically** (line moves left to right)
2. Scan line divided into **16 horizontal bands**
3. Each band's average brightness → partial amplitude
4. Real-time updates at **~60 fps**

### Csound Implementation
```csound
instr 1
  kFund   = port(chnget:k("fund"), 0.05)     ; Smooth control
  kBright = port(chnget:k("bright"), 0.05)
  kInharm = port(chnget:k("inharm"), 0.05)
  kTilt   = port(chnget:k("tilt"), 0.05)
  kGain   = port(chnget:k("gain"), 0.05)
  
  ; 16 partials with tilt + inharmonicity
  a1  = oscili:a(kA1 * kBright * 1.0,                    kFund * (1 + 0*kInharm))
  a2  = oscili:a(kA2 * kBright * (1.0 - kTiltFactor*0.05), kFund * (2 + 1*kInharm*0.01))
  ; ... partials 3-16 ...
  
  aSig = (a1+a2+...+a16) * 0.08 * kGain
  out(aSig, aSig)
endin
```

### MIDI Implementation
- **Web MIDI API** - Direct browser access to MIDI devices
- **CC Messages** - Control Change (0xB0) for parameter control
- **localStorage** - Persistent bindings across sessions
- **Per-Device Bindings** - Different controllers can have different mappings

### Preset Storage
```json
{
  "params": {
    "fund": 200,
    "bright": 0.5,
    "inharm": 0.01,
    "tilt": 0.7,
    "gain": 0.4
  },
  "locks": {
    "fund": false,
    "bright": false,
    "inharm": true,
    "tilt": false,
    "gain": false
  },
  "speed": 200,
  "photo": "data:image/jpeg;base64,/9j/4AAQ..." // Optional
}
```

---

## 🎨 Creative Techniques

### 1. Harmonic Scanning
- Use **high-contrast** images (sharp edges)
- **Slow scan** (60-100s per pass)
- **Low inharmonicity** (0-1%)
- Result: Clear harmonic evolution

### 2. Textural Clouds
- Use **detailed** photos (trees, fabric, clouds)
- **Fast scan** (5-15s per pass)
- **High inharmonicity** (5-10%)
- Result: Dense, organic textures

### 3. Bass Drones
- Use **low fundamental** (50-100 Hz)
- **High spectral tilt** (0.8-1.0)
- **Low brightness** (0.2-0.4)
- Result: Deep, rumbling pads

### 4. Bright Leads
- Use **high fundamental** (300-550 Hz)
- **Low spectral tilt** (0.1-0.3)
- **High brightness** (0.7-1.0)
- Result: Cutting, bell-like tones

### 5. MIDI Performance
1. **Lock fundamental** (🔒) to fix pitch
2. Map **brightness** to MIDI CC (e.g., mod wheel)
3. Map **spectral tilt** to another CC (e.g., expression)
4. **Enable MIDI Override Mode**
5. Play expressively while photo scans

---

## 🔍 Comparison to v1 (FIXED)

| Feature | v1 FIXED | v3 Complete |
|---------|----------|-------------|
| Parameters | 5 | 5 |
| MIDI Learn | ❌ | ✅ Full |
| MIDI Device Select | ❌ | ✅ |
| Parameter Locks | ❌ | ✅ |
| Advanced Presets | ❌ Basic | ✅ Complete |
| Photo in Presets | ❌ | ✅ Base64 |
| Keyboard Shortcuts | ❌ | ✅ 7 shortcuts |
| Preset Reorder | ❌ | ✅ ⬆⬇ buttons |
| Export/Import | ❌ | ✅ JSON |
| Help Dialog | ❌ | ✅ Press ? |
| MIDI Override Mode | ❌ | ✅ |
| Factory Presets | ❌ | ✅ 3 included |
| File Size | 305 lines | 820 lines |

---

## 🐛 Troubleshooting

### "Failed to load module"
**Problem**: Opening HTML directly (`file://`)  
**Solution**: Must serve via HTTP (`python3 -m http.server 8080`)

### No MIDI devices shown
1. Connect MIDI controller **before** starting audio
2. Check browser MIDI permissions
3. Try **Chrome** (best Web MIDI support)
4. Refresh page after connecting device

### MIDI Learn not working
1. Ensure MIDI device is **selected** in dropdown
2. Click **"MIDI Learn: OFF"** to turn **ON**
3. Click **parameter name** (not slider)
4. Move controller **immediately** (3-second timeout)
5. Check browser console for errors (F12)

### Locked parameters still randomize
- This is a bug - locked params should skip randomization
- Check that lock button shows **🔒** (not 🔓)
- Try saving/loading preset to verify lock state

### Photo not saved in preset
- Photos only save when preset is created with photo loaded
- Large photos may fail (800px max downsampling)
- Check browser console for errors
- Manually reload photo after loading preset if needed

### Audio clicks/pops
- Reduce **scan speed** (slower = smoother)
- Increase **portamento** in Csound code (`port(..., 0.05)` → `0.1`)
- Lower **brightness** to reduce overall level

---

## 🌐 Browser Compatibility

| Browser | MIDI Support | Audio | Overall |
|---------|-------------|-------|---------|
| Chrome 90+ | ✅ Excellent | ✅ | ✅ Recommended |
| Firefox 88+ | ⚠️ Limited | ✅ | ⚠️ MIDI may be flaky |
| Safari 14+ | ❌ No Web MIDI | ✅ | ⚠️ No MIDI Learn |
| Edge 90+ | ✅ Excellent | ✅ | ✅ Recommended |

**Requirements:**
- WebAssembly
- Web Audio API
- Web MIDI API (for MIDI features)
- ES6 modules
- localStorage
- Canvas API

---

## 📝 Known Limitations

1. **Photo storage**: Presets with large photos can exceed localStorage quota (5-10MB)
2. **MIDI latency**: ~10-30ms depending on browser and OS
3. **Safari**: No Web MIDI API support (MIDI Learn won't work)
4. **CPU usage**: 16 oscillators = moderate CPU (acceptable on modern hardware)
5. **Preset limit**: ~100 presets max before localStorage fills up

---

## 🔮 Future Enhancements

### Planned
- [ ] Webcam support (live video → synthesis)
- [ ] Polyphonic mode (MIDI keyboard notes)
- [ ] Per-partial envelope control
- [ ] FFT-based analysis (better spectral accuracy)
- [ ] Wavetable export (save spectrum as wavetable)

### Wishlist
- [ ] VST/AU plugin (via Cabbage)
- [ ] Preset cloud sync
- [ ] MIDI CC automation recording
- [ ] Multi-photo layers
- [ ] 3D visualization (spectrum over time)

---

## 📚 Learning Resources

- [Additive Synthesis Basics](https://flossmanual.csound.com/sound-synthesis/additive-synthesis)
- [Harmonic Series Theory](https://en.wikipedia.org/wiki/Harmonic_series_(music))
- [Web MIDI API](https://developer.mozilla.org/en-US/docs/Web/API/Web_MIDI_API)
- [Csound Documentation](https://csound.com/docs/manual/index.html)

---

## 🎓 Educational Value

This synthesizer demonstrates:
1. **Additive Synthesis** - Building complex timbres from simple sine waves
2. **Harmonic Series** - Natural relationship between overtones
3. **Inharmonicity** - How real-world instruments deviate from perfect harmonics
4. **Spectral Filtering** - Shaping timbre with amplitude envelopes
5. **Image Analysis** - Converting visual data to audio parameters
6. **MIDI Control** - Hardware integration with web audio
7. **Web Audio** - Modern browser-based synthesis

---

**Built with Csound 7 + Web Audio + Web MIDI**

Complete additive synthesizer with photo-driven harmonic control, full MIDI integration, and advanced preset management.
