# Folder System - Quick Start Guide

**Get started with folder-based image playback in 2 minutes**

---

## 📁 Step-by-Step Tutorial

### 1. Prepare Your Image Folder

Create a folder on your computer with images:

```
my-images/
  ├── photo_001.jpg
  ├── photo_002.jpg
  ├── photo_003.jpg
  ├── photo_004.jpg
  └── photo_005.jpg
```

**Tips:**
- Use numbered filenames (001, 002, etc.) for sequential playback
- Keep 10-50 images per folder for best performance
- Any image format works (JPG, PNG, WebP)

---

### 2. Load the Folder

1. Start the app: `http://localhost:8080/photo_multi_engine_complete.html`
2. Click **🎵 Start Audio Engine**
3. In any slot (A, B, C, or D), click **📁 Folder**
4. Select your image folder
5. Browser will load all images and show "1/5" (first of 5 images)

✅ **Folder loaded!** You'll see:
- ⬅ Prev and ➡ Next buttons appear
- Folder settings panel expands
- First image displayed

---

### 3. Choose Playback Mode

Select how images are chosen:

- **Sequential** - Play in order: 1→2→3→4→5→1→2...
- **Random** - Pick random images

**Example:** For a numbered sequence, choose Sequential. For unpredictable variety, choose Random.

---

### 4. Choose Timing Mode

Select when images change:

#### Manual Only (Default)
- You control with ⬅ Prev / ➡ Next buttons
- Great for live performance

#### On Scan Complete
- New image when green scanline reaches end and wraps
- Syncs to scan cycle duration

#### Fixed Rate
- Change every N seconds (adjustable 1-60s)
- Steady, predictable timing

#### Random Rate  
- Change at random intervals
- Set Min/Max range (e.g., 5-20 seconds)
- Organic, unpredictable feel

#### MIDI Note
- Change when specific MIDI note is played
- Set note number (e.g., 60 = Middle C)
- Perfect for drum pad triggers

---

### 5. Test It Out

**Manual Mode:**
1. Click **➡ Next** → Image advances
2. Click **⬅ Prev** → Image goes back

**Fixed Rate Mode:**
1. Set Rate to **5 seconds**
2. Click **▶ Play** in master controls
3. Watch images change every 5 seconds automatically

**MIDI Note Mode:**
1. Connect MIDI controller
2. Set MIDI Note to **60**
3. Click **▶ Play**
4. Press Middle C on keyboard → Image changes!

---

## 🎯 Common Scenarios

### Scenario 1: Ambient Slideshow
**Goal:** Slow, evolving background visuals

```
Folder: 30 abstract photos
Mode: Random
Timing: Random Rate (10-30s)
```

**Result:** Image changes every 10-30 seconds (randomly), never repeating in order

---

### Scenario 2: Rhythmic Loop
**Goal:** Repeating visual pattern

```
Folder: 8 numbered images
Mode: Sequential
Timing: Fixed Rate (4s)
```

**Result:** Loops through 1→2→3→4→5→6→7→8→1 every 32 seconds

---

### Scenario 3: Scan-Synced Morph
**Goal:** Image changes sync to scan cycle

```
Folder: 20 gradual transformation images
Mode: Sequential
Timing: On Scan Complete
```

**Result:** New image appears each time scan reaches end and wraps around

---

### Scenario 4: MIDI Performance
**Goal:** Drum hits trigger image changes

```
Folder: 16 preset images
Mode: Sequential
Timing: MIDI Note 36 (Kick drum)
```

**Result:** Each kick drum hit advances to next image

---

## 🎹 MIDI Setup

### Connect MIDI Controller

1. Plug in USB MIDI controller/keyboard
2. Start audio engine
3. Browser will request MIDI access → **Allow**
4. Console shows: "🎹 Listening to: [Your Device Name]"

### Assign Notes

1. Set **Timing Mode** → MIDI Note
2. Adjust **MIDI Note** slider (0-127)
   - 36 = Kick drum (MIDI pads)
   - 60 = Middle C (keyboard)
   - 72 = High C
3. Play that note → Image changes!

**Tip:** Use different notes per slot for independent control:
- Slot A: MIDI Note 36 (Kick)
- Slot B: MIDI Note 38 (Snare)
- Slot C: MIDI Note 42 (Hi-hat)
- Slot D: MIDI Note 60 (Melody)

---

## 🔄 Multi-Slot Coordination

### All Slots Sequential (Polyrhythm)
```
Slot A: Folder 1, Sequential, Fixed 4s
Slot B: Folder 2, Sequential, Fixed 6s
Slot C: Folder 3, Sequential, Fixed 9s
Slot D: Folder 4, Sequential, Fixed 12s
```

**Result:** 4 independent loops at different speeds → evolving polyrhythmic patterns

---

### Mixed Random & Sequential
```
Slot A: Folder 1, Random, Random 5-15s
Slot B: Folder 1 (same), Sequential, Fixed 8s
Slot C: Folder 2, Random, Random 10-30s
Slot D: Static photo (no folder)
```

**Result:** Controlled chaos - some predictable, some random

---

### All MIDI-Triggered
```
Slot A: MIDI Note 36 (Kick)
Slot B: MIDI Note 38 (Snare)
Slot C: MIDI Note 42 (Hi-hat)
Slot D: MIDI Note 46 (Open hat)
```

**Result:** Each drum pad controls a different visual slot

---

## 💾 Saving Presets

### What Gets Saved
✅ Folder mode (Sequential/Random)  
✅ Timing mode (Manual/Scan/Fixed/Random/MIDI)  
✅ All timing parameters (rates, MIDI notes)  
✅ Engine settings  
✅ Playback mode  

❌ **NOT saved**: Actual image files

### How to Save/Load

**Save:**
1. Configure all 4 slots (folders, modes, timing)
2. Click **💾 Save**
3. Enter preset name (e.g., "Ambient Flow")
4. Preset stored in browser localStorage

**Load:**
1. Click preset dropdown
2. Select preset
3. Click **📂 Load**
4. **Manually reload folders** (files aren't saved)
5. All settings restored!

---

## 🐛 Troubleshooting

### "No image files found in folder"
**Solution:** Make sure folder contains .jpg, .png, .webp, .gif files

### Folder button does nothing
**Solution:** Use Chrome, Edge, Firefox, or Safari 14+. Mobile support varies.

### MIDI doesn't work
**Solution:** 
- Use Chrome or Edge (Firefox requires manual enabling)
- Safari doesn't support Web MIDI
- Grant permission when browser asks

### Images load in wrong order
**Solution:** Use zero-padded filenames:
- ✅ `img_001.jpg`, `img_002.jpg`, `img_010.jpg`
- ❌ `img_1.jpg`, `img_2.jpg`, `img_10.jpg` (sorts as 1, 10, 2)

### Changes happen too fast/slow
**Solution:** Adjust timing parameters:
- Fixed Rate: Increase seconds
- Random Rate: Increase Min/Max range
- Or switch to Manual mode for full control

---

## 🎓 Pro Tips

1. **Test folder first:** Load folder, click through images with Prev/Next to verify order
2. **Name systematically:** Use descriptive numbered names like `ambient_001.jpg`
3. **Keep it focused:** 10-50 images per folder = snappy performance
4. **Layer timing modes:** Different modes per slot create interesting polyrhythms
5. **MIDI map smartly:** Use drum pads (36-51) for percussive triggers, keyboard (60+) for melodic control
6. **Preset workflow:** Save presets AFTER configuring timing (before loading folders)
7. **Watch the counter:** "3/24" tells you where you are in the sequence

---

## ✅ Summary

**Folder system enables:**
- ✅ Generative visual sequences
- ✅ 5 distinct timing modes
- ✅ Independent control per slot
- ✅ MIDI synchronization
- ✅ Preset save/load
- ✅ Manual override anytime

**In 3 steps:**
1. Load folder(s) with **📁 Folder** button
2. Choose mode + timing
3. Press **▶ Play** and watch images cycle automatically!

**Next:** Experiment with combinations. Try all 4 slots with different folders, modes, and timing. Create presets for different performance scenarios.

🎉 **Happy performing!**
