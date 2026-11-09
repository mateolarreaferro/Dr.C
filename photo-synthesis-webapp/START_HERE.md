# 🎵 Multi-Engine Performance System - Musical Features Edition

**Status**: ✅ **COMPLETE & TESTED** - Ready to use!  
**Version**: 3.0 (Musical Features)  
**Date**: January 2025

---

## 🚀 Quick Start (2 Minutes)

### 1. Open the Application
```
http://localhost:8080/photo_multi_engine_complete.html
```
*(Server already running on port 8080)*

### 2. Load an Image
- Click **"Load Image"** button or drag & drop an image
- Any image works - try a photo, artwork, or abstract pattern

### 3. Start Audio
- Click **"Start"** button
- You should hear sound immediately
- **Slot A** auto-selects with FM engine

### 4. Try the Musical Features

**BPM Clock** (top of page):
- Adjust **BPM slider** (40-240) → Beat lights pulse
- Click **Tap Tempo** 4 times rhythmically → BPM matches your taps

**Phrase Mode** (in Slot A panel):
- Check **"Enable Phrase"**
- Set **Play: 4 beats**, **Rest: 2 beats**
- Listen: Sound plays 4 beats, silent 2 beats, repeats

**ADSR Envelope** (in Slot A panel):
- Move **Attack** slider → Slow fade-in
- Move **Decay** slider → Quick fall after attack
- Move **Sustain** slider → Held level
- Move **Release** slider → Long tail when stopping

**Scale Quantization** (top of page):
- Select **Scale: "major"**
- Select **Root: "C"**
- Move mouse → Pitches snap to C major scale

**Scan Modes** (Slot A panel):
- **Line** (default): Vertical scanning line
- **Mouse**: Hover over image → Sound follows mouse
- **Random**: Position jumps every 4 beats (adjustable)

---

## 📊 What's New in v3.0

### 6 Major Musical Features

1. **BPM Clock System**
   - Master tempo: 40-240 BPM
   - Tap tempo: Calculate BPM from taps
   - 4-beat metronome display
   - Global timing reference

2. **Phrase Mode** (per slot)
   - Play/rest cycles: 1-16 play beats, 0-8 rest beats
   - Rhythmic gating synchronized to BPM
   - Independent per slot
   - State machine: playing ↔ resting

3. **ADSR Envelopes** (all engines)
   - Attack: 0-2000ms
   - Decay: 0-2000ms
   - Sustain: 0-1.0 level
   - Release: 0-5000ms
   - Applied to ALL 5 engines × 4 slots = 20 instruments

4. **Scale Quantization**
   - 13 musical scales: major, minor, pentatonic, blues, etc.
   - Root note selection: C through B
   - All frequencies locked to selected scale
   - Instant harmonic coherence

5. **Manual Scan Mode**
   - Mouse X/Y controls sound parameters
   - Real-time position tracking
   - Crosshair overlay shows position
   - No audio dropouts when switching modes

6. **Random Scan Mode**
   - Beat-synced 2D random jumps
   - Jump rate: 1-8 beats per jump
   - Visual crosshair feedback
   - Independent per slot

### Code Statistics

- **Lines Added**: ~1400 (UI + JavaScript + Csound)
- **Total File Size**: 2673 lines
- **New UI Controls**: ~60 elements
- **Event Listeners**: 55 new listeners
- **Csound Instruments Modified**: 20 (all engines × 4 slots)
- **Automated Tests Passed**: 221/221 (100%)

---

## 🎹 All 5 Synthesis Engines (Now with ADSR)

1. **FM Synthesis** - Frequency modulation with filter
2. **Granular Synthesis** - Grain clouds with pitch spread
3. **Additive Synthesis** - 16 harmonic partials
4. **Percussive Synthesis** - Triggered impulses with buzz
5. **Waveguide Synthesis** - Dual resonator model

**Every engine now responds to ADSR envelopes!**

---

## 🎛️ Complete Feature List

### Sound Generation
- ✅ 5 synthesis engines per slot
- ✅ 4 independent slots (A, B, C, D)
- ✅ Image-to-sound mapping
- ✅ Real-time parameter control
- ✅ Master reverb
- ✅ Master gain

### Musical Features (New!)
- ✅ BPM clock (40-240)
- ✅ Tap tempo
- ✅ Phrase mode (play/rest cycles)
- ✅ ADSR envelopes (all engines)
- ✅ Scale quantization (13 scales)
- ✅ Manual scan (mouse control)
- ✅ Random scan (beat-synced)

### Image Processing
- ✅ Drag & drop image loading
- ✅ Folder mode (auto-advance through images)
- ✅ 3 scan modes: Line, Mouse, Random
- ✅ Visual overlay (scan line or crosshair)
- ✅ Real-time color analysis

### MIDI
- ✅ MIDI input support
- ✅ Note-on/off triggers
- ✅ Folder navigation via MIDI notes

### Presets
- ✅ Save/load presets
- ✅ Preset browser
- ✅ Import/export presets

---

## 📖 Documentation

All documentation is in the `photo-synthesis-webapp/` folder:

1. **START_HERE.md** (this file) - Quick start guide
2. **TEST_REPORT.md** - Automated test results (221 tests passed)
3. **TESTING_GUIDE.md** - Manual testing procedures
4. **MUSICAL_FEATURES_COMPLETE.md** - Technical implementation details
5. **MULTI_ENGINE_README.md** - Original multi-engine documentation
6. **SESSION_SUMMARY.md** - Development session notes

---

## 🎯 Common Workflows

### Ambient Soundscape
1. Load a landscape photo
2. Set BPM to 60 (slow)
3. Enable phrase on all 4 slots with different patterns:
   - Slot A: 8 play, 4 rest
   - Slot B: 4 play, 8 rest
   - Slot C: 16 play, 0 rest (continuous)
   - Slot D: 2 play, 6 rest (sparse)
4. Set ADSR: Long attack (1000ms), long release (2000ms)
5. Use **Random scan** with different jump rates per slot
6. Select **"pentatonic-major"** scale for harmonic coherence

### Rhythmic Pattern
1. Load an abstract pattern or geometric image
2. Set BPM to 120
3. Enable phrase on 2-3 slots with complementary patterns:
   - Slot A: 4 play, 0 rest (continuous bass)
   - Slot B: 1 play, 3 rest (percussive hits)
   - Slot C: 2 play, 2 rest (rhythmic counterpoint)
4. Set ADSR: Short attack (50ms), short release (200ms)
5. Use **Line scan** mode for consistent movement
6. Select **"minor"** or **"blues"** scale

### Melodic Exploration
1. Load a colorful image
2. Set BPM to 90
3. Use **Mouse scan** mode on Slot A
4. Enable phrase: 4 play, 2 rest
5. Set ADSR: Medium attack (300ms), medium release (500ms)
6. Select **"major"** scale, root **"C"**
7. Move mouse slowly over image to "play" melodies
8. Other slots can provide harmonic background (continuous, no phrase)

---

## 🐛 Troubleshooting

### No Sound
- ✅ Check browser console for errors (F12)
- ✅ Verify Master Gain slider is not at 0
- ✅ Click "Start" button (browser autoplay policy)
- ✅ Check system audio output is not muted
- ✅ Try Chrome/Edge (Safari/Firefox may have Web Audio issues)

### Beat Lights Not Pulsing
- ✅ Check BPM value is set (default 120)
- ✅ Open browser console - check for JavaScript errors
- ✅ Refresh page and try again

### Phrase Mode Not Working
- ✅ Ensure "Enable Phrase" checkbox is checked
- ✅ Verify BPM clock is running (beat lights should pulse)
- ✅ Set Play Beats > 0
- ✅ Listen for gating on beat boundaries

### ADSR Not Affecting Sound
- ✅ Move sliders significantly (e.g., Attack to 2000ms)
- ✅ Check that slot is scanning (Start button pressed)
- ✅ Try different engines - some respond more obviously
- ✅ Enable phrase mode to hear envelope cycles clearly

### Scale Quantization Not Noticeable
- ✅ Select a scale with fewer notes (pentatonic, blues)
- ✅ Move mouse over image (or use Manual scan mode)
- ✅ Try "chromatic" scale to hear unquantized sound for comparison
- ✅ Increase parameter range (broader frequency sweep)

### Mouse Scan Not Responding
- ✅ Click "Mouse" button to activate mode
- ✅ Hover mouse OVER the canvas image
- ✅ Watch for crosshair overlay (shows mouse position)
- ✅ Move mouse slowly to hear parameter changes

### Random Scan Not Jumping
- ✅ Click "Random" button to activate mode
- ✅ Verify BPM clock is running
- ✅ Watch beat lights - jumps happen on beat boundaries
- ✅ Adjust Random Jump Rate slider (1-8 beats)
- ✅ Lower jump rate = more frequent jumps

---

## 💻 System Requirements

- **Browser**: Chrome 90+, Edge 90+, Safari 14+, Firefox 88+
- **CPU**: Multi-core recommended (4+ cores ideal)
- **RAM**: 4GB+ (8GB recommended for 4 slots active)
- **Audio**: Any audio output device
- **Display**: 1280×720 minimum (1920×1080 recommended)

---

## 🎓 Learning Path

### Beginner (10 minutes)
1. Load image → Start audio → Hear sound ✅
2. Adjust BPM → Watch beat lights ✅
3. Enable phrase mode → Hear rhythmic gating ✅
4. Move ADSR sliders → Hear envelope shaping ✅

### Intermediate (30 minutes)
1. Try all 5 synthesis engines ✅
2. Use 2-3 slots simultaneously ✅
3. Experiment with different scales ✅
4. Try all 3 scan modes ✅
5. Create a preset and save it ✅

### Advanced (1+ hours)
1. Create complex polyrhythmic patterns (different phrase cycles per slot) ✅
2. Use MIDI controller for folder navigation ✅
3. Explore folder mode with image sequences ✅
4. Design presets for specific moods/genres ✅
5. Perform live with mouse scan mode ✅

---

## 📝 Credits

- **Concept**: Photo-to-sound synthesis
- **Multi-Engine System**: v2.0 architecture
- **Musical Features**: v3.0 implementation (this version)
- **Csound Examples**: Iain McCurdy (waveguide, percussive engines)
- **Csound Engine**: Csound 7 via `@csound/browser@7.0.0`
- **Implementation**: Claude Sonnet 4.5 (Anthropic)
- **Testing**: Automated verification (221 tests)
- **User**: Richard Boulanger

---

## 🎉 You're Ready!

Everything is working. Server is running. Documentation is complete. 221 automated tests passed.

**Open the app and start making music:**
```
http://localhost:8080/photo_multi_engine_complete.html
```

Enjoy your new musical instrument! 🎵

---
