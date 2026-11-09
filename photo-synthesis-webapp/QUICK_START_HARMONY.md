# Quick Start: Berklee Modal Jazz Harmony

## 🎹 30-Second Test

1. Open `http://localhost:8080/photo_multi_engine_complete.html`
2. Load any image into Slot A
3. Scroll down in Slot A panel to **"Harmony (Berklee Jazz)"** section
4. Check **"Enable"** box → Parameters appear
5. Select **"Dorian"** from Modal Center dropdown
6. Start scanning Slot A
7. **Listen**: Your melody + rich jazz harmony chords!

---

## 🎵 What You'll Hear

**Melody**: From image scanning (FM/Granular/Additive/etc.)  
**Harmony**: 4-voice jazz pad (warm FM chords)  
**Progression**: Authentic Dorian modal chords (i-7, IV7, ♭VII△7, etc.)  
**Voice Leading**: Smooth, minimal motion between chords  
**Changes**: Every 4 beats (adjustable to 1, 2, 8, or 16 beats)

---

## 🎼 The 7 Modal Centers

Try each to hear different harmonic colors:

**Ionian (Major)** - Bright, happy, traditional  
→ Perfect for: Major melodies, uplifting textures

**Dorian** - Minor with bright 6th, jazz standard  
→ Perfect for: Modal jazz, "So What" vibes  
→ **Try this first!**

**Phrygian** - Dark, Spanish, exotic  
→ Perfect for: Flamenco color, tension

**Lydian** - Major with raised 4th, floating  
→ Perfect for: Dreamy, ethereal textures

**Mixolydian** - Dominant, bluesy, rock  
→ Perfect for: Blues, rock progressions

**Aeolian (Natural Minor)** - Sad, melancholic  
→ Perfect for: Minor key ballads

**Locrian** - Unstable, diminished  
→ Perfect for: Experimental, avant-garde

---

## 🎸 The 4 Voicing Types

**Drop-2 (Default)** - Open, jazz standard  
- Best for: Most situations
- Sound: Guitar/big band voicing
- Voices: 1-5-7-3 (2nd voice dropped octave)

**Close** - Compact, piano-like  
- Best for: Tight harmony
- Sound: Piano root position
- Voices: 1-3-5-7 (stacked 3rds)

**Drop-3** - Wide spread  
- Best for: Orchestral sound
- Sound: Very open
- Voices: 1-3-7-5 (3rd voice dropped)

**Spread (5-voice)** - Lush, full  
- Best for: Rich pads
- Sound: Most lush
- Voices: 1-3-5-7-9 (with 9th extension)

---

## ⏱️ Harmonic Rhythm

How often chords change:

**1 beat/chord** - Very fast (bebop feel)  
**2 beats/chord** - Fast (uptempo jazz)  
**4 beats/chord** - Standard (DEFAULT)  
**8 beats/chord** - Slow (modal vamp)  
**16 beats/chord** - Very slow (drone)

---

## 🎨 Creative Combinations

### 1. Dorian Modal Vamp (Miles Davis)
- Modal Center: **Dorian**
- Harmonic Rhythm: **8 beats/chord**
- Voicing: **Drop-2**
- Scan Mode: **Line**
- → Like "So What" or "Impressions"

### 2. Bebop ii-V-I
- Modal Center: **Ionian (Major)**
- Harmonic Rhythm: **2 beats/chord**
- Voicing: **Drop-2**
- BPM: **180-220**
- → Fast-changing jazz progressions

### 3. Ethereal Lydian Pad
- Modal Center: **Lydian**
- Harmonic Rhythm: **16 beats/chord**
- Voicing: **Spread (5-voice)**
- ADSR: Long attack (1-2s)
- → Floating, dreamy texture

### 4. Dark Phrygian Texture
- Modal Center: **Phrygian**
- Harmonic Rhythm: **8 beats/chord**
- Voicing: **Drop-3**
- → Spanish/flamenco color

### 5. Polyphonic + Harmony
- Clone image to all slots
- Slot A: Harmony enabled (Dorian, Drop-2)
- Slots B/C/D: No harmony, different speeds
- → Full ensemble: piano + 3 horns

---

## 🎛️ UI Location

**Per Slot** (located below "Polyphonic Controls"):

```
[Polyphonic Controls]
  - Scan Speed
  - Phase Offset

[Harmony (Berklee Jazz)]  ← NEW!
  ☐ Enable
  
  When enabled:
  - Voicing: [Drop-2 ▼]
  - Modal Center: [Ionian ▼]
  - Harmonic Rhythm: [4 beats ▼]
  - Current Chord: [I△7]
```

Gold accent color (#d4af37) makes harmony section easy to find.

---

## 🔧 Technical Details

**What's Happening**:
1. Every beat, system analyzes your melody frequency
2. Converts to scale degree (1st, 2nd, 3rd, etc.)
3. Uses Markov chain to select next chord
4. Generates 4-5 voice frequencies using selected voicing type
5. Applies smooth voice leading (minimal motion)
6. Sends to Csound FM pad instrument
7. You hear melody + harmony together

**Chord Display**: Shows current chord symbol in **gold text**  
(e.g., "i-7", "IV7", "♭VII△7")

---

## 🎵 Musical Examples

### Example 1: Single Slot + Harmony
```
Slot A:
  Image: Any photo
  Engine: FM
  Harmony: ON (Dorian, Drop-2, 4 beats)
  Phrase Mode: 4 play / 2 rest

Result: Melody + harmony pad, gated together
```

### Example 2: Polyphonic + Harmony
```
All Slots (same image):
  Slot A: 1× speed, Harmony ON (Lydian)
  Slot B: 2× speed, No harmony
  Slot C: 0.5× speed, No harmony
  Slot D: Inactive

Result: 3 voices + harmonic foundation from Slot A
```

### Example 3: Polymodal (Advanced)
```
All Slots (same image):
  Slot A: Harmony ON (Dorian)
  Slot B: Harmony ON (Lydian)
  Slot C: Harmony ON (Mixolydian)
  Slot D: No harmony

Result: Same melody with 3 different harmonizations!
```

---

## ⚡ Pro Tips

1. **Start with Dorian** - Most versatile, sounds great immediately
2. **Use Drop-2 voicing** - Standard jazz sound, works for everything
3. **4 beats/chord** - Good default harmonic rhythm
4. **Enable phrase mode** - Creates question/answer with harmony
5. **Try slow harmonic rhythm first** (8-16 beats) - Easier to hear chords
6. **Mouse mode + harmony** - Real-time harmonic performance
7. **Watch chord display** - See progression evolve
8. **Combine with scale quantization** - Melody and harmony in same scale

---

## 🚀 Server Status

**URL**: `http://localhost:8080/photo_multi_engine_complete.html`  
**File**: 3535 lines (includes all features)  
**Ready**: Yes! Test now!

If server not running:
```bash
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
python3 -m http.server 8080
```

---

## 📚 Full Documentation

See these files for complete details:
- `HARMONY_FEATURE_COMPLETE.md` - Full technical documentation
- `POLYPHONIC_FEATURE_GUIDE.md` - Polyphonic controls
- `MUSICAL_FEATURES_COMPLETE.md` - All 6 musical features
- `START_HERE.md` - Overall system guide

---

**Ready to make jazz with photos!** 🎶📸🎹
