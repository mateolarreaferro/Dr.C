# Berklee Modal Jazz Harmony - Design Document

## Overview

Add **intelligent harmonic accompaniment** that:
- Analyzes melodic contours from image scanning
- Generates chord progressions using Markov chains
- Uses Berklee-style modal jazz harmony
- Provides real-time 4-voice/5-voice jazz voicings
- Smooth voice leading between chords
- Per-slot harmony control

---

## Features to Implement

### 1. Harmony Database (Berklee Style)

**Modal Scales & Chords**:
- **Ionian (Major)**: I△7, ii-7, iii-7, IV△7, V7, vi-7, vii-ø7
- **Dorian**: i-7, ii-7, ♭III△7, IV7, v-7, vi-ø7, ♭VII△7
- **Phrygian**: i-7, ♭II△7, ♭III7, iv-7, v°7, ♭VI△7, ♭vii-7
- **Lydian**: I△7, II7, iii-7, #iv-ø7, V△7, vi-7, vii-7
- **Mixolydian**: I7, ii-7, iii-ø7, IV△7, v-7, vi-7, ♭VII△7
- **Aeolian (Natural Minor)**: i-7, ii-ø7, ♭III△7, iv-7, v-7, ♭VI△7, ♭VII7
- **Locrian**: i-ø7, ♭II△7, ♭iii-7, iv-7, ♭V△7, ♭VI7, ♭vii-7

**Common Jazz Progressions**:
- **ii-V-I**: Dorian → Mixolydian → Ionian
- **iii-vi-ii-V**: Minor approach pattern
- **I-vi-ii-V**: "Rhythm changes"
- **I-IV-vii-iii-vi-ii-V-I**: "Circle of fifths"
- **Modal vamps**: Single chord or two-chord vamps
- **Tritone substitutions**: ♭II7 for V7
- **Modal interchange**: Borrowing from parallel modes

### 2. Markov Chain Engine

**Transition Probabilities** (Berklee-derived):
```javascript
markovTransitions = {
  'I△7': { 'IV△7': 0.25, 'ii-7': 0.2, 'vi-7': 0.2, 'V7': 0.15, 'I△7': 0.2 },
  'ii-7': { 'V7': 0.5, 'iii-7': 0.15, 'I△7': 0.15, 'IV△7': 0.2 },
  'V7': { 'I△7': 0.6, 'vi-7': 0.15, 'IV△7': 0.1, 'ii-7': 0.15 },
  'vi-7': { 'ii-7': 0.4, 'V7': 0.3, 'IV△7': 0.2, 'iii-7': 0.1 },
  // ... all modal chords
}
```

**Harmonic Rhythm Options**:
- 1 beat per chord (fast changes)
- 2 beats per chord
- 4 beats per chord (standard)
- 8 beats per chord (slow vamp)
- 16 beats per chord (modal drone)

### 3. Melodic Analysis

**Analyze current frequency** to determine:
1. **Current scale degree** (relative to root)
2. **Chord tones vs passing tones**
3. **Tension level** (consonance vs dissonance)
4. **Melodic direction** (ascending/descending/static)

**Harmonic Inference**:
- If melody on 1-3-5 → Suggest tonic chord
- If melody on 2-4-6 → Suggest subdominant/dominant
- If melody on 7-9-11-13 → Suggest extension chords
- Chromatic notes → Suggest altered dominants

### 4. Chord Voicing Algorithms

**4-Voice Close Voicing**:
```
Root position: 1 3 5 7
1st inversion: 3 5 7 9
2nd inversion: 5 7 9 11
```

**Drop-2 Voicing** (jazz standard):
```
Drop-2: 1 5 7 3 (drop 2nd voice down octave)
```

**Drop-3 Voicing**:
```
Drop-3: 1 3 7 5 (drop 3rd voice down octave)
```

**5-Voice Spread Voicing**:
```
1 3 5 7 9 (with extensions)
```

### 5. Voice Leading Rules

**Smooth Voice Leading**:
1. Minimal motion (prefer common tones)
2. Step-wise motion when possible (avoid leaps)
3. Contrary motion between outer voices
4. Resolve tendency tones (7→1, 4→3)
5. Guide tones (3rd/7th) move by step

**Algorithm**:
```javascript
function voiceLead(chord1, chord2) {
  // Find common tones
  // Move remaining voices by smallest interval
  // Check voice crossing
  // Apply tendency tone resolution
}
```

### 6. Csound Harmony Instruments

**New Instruments Needed**:

```csound
instr 501  ; Slot A Harmony
  ; 4-voice chord player
  ; FM-based pad sound
  ; ADSR envelope
  ; Voice leading from channels
endin

instr 502  ; Slot B Harmony
  ; Similar structure
endin

instr 503, 504  ; Slots C, D Harmony
```

**Sound Design**:
- **Pad timbre**: Warm FM bells, chorus, reverb
- **Smooth attacks**: 100-500ms attack time
- **Sustain**: Long sustain for harmonic bed
- **Stereo spread**: Voices distributed L-C-R

### 7. UI Controls (Per Slot)

**Harmony Section** (new per-slot control):
```html
<div class="harmony-ctrl">
  <label><input type="checkbox" id="harmonyEnableA"> Enable Harmony</label>
  
  <div id="harmonyParamsA" style="display:none;">
    <div class="mini-field">
      <label>Voicing Type</label>
      <select id="voicingTypeA">
        <option value="close">Close (4-voice)</option>
        <option value="drop2">Drop-2 (4-voice)</option>
        <option value="drop3">Drop-3 (4-voice)</option>
        <option value="spread">Spread (5-voice)</option>
      </select>
    </div>
    
    <div class="mini-field">
      <label>Harmonic Rhythm</label>
      <select id="harmonicRhythmA">
        <option value="1">1 beat/chord (fast)</option>
        <option value="2">2 beats/chord</option>
        <option value="4" selected>4 beats/chord</option>
        <option value="8">8 beats/chord (slow)</option>
        <option value="16">16 beats/chord (vamp)</option>
      </select>
    </div>
    
    <div class="mini-field">
      <label>Modal Center</label>
      <select id="modalCenterA">
        <option value="ionian">Ionian (Major)</option>
        <option value="dorian">Dorian</option>
        <option value="phrygian">Phrygian</option>
        <option value="lydian">Lydian</option>
        <option value="mixolydian">Mixolydian</option>
        <option value="aeolian">Aeolian (Minor)</option>
        <option value="locrian">Locrian</option>
      </select>
    </div>
    
    <div class="mini-field">
      <label>Tension Level</label>
      <input type="range" id="tensionA" min="0" max="100" value="50">
      <span class="v" id="tensionValA">50%</span>
    </div>
    
    <div class="chord-display" id="currentChordA">—</div>
  </div>
</div>
```

**Master Harmony Controls**:
```html
<div class="master-harmony">
  <button id="harmonyGlobalEnable">Enable All Harmony</button>
  <button id="harmonyGlobalDisable">Disable All Harmony</button>
  <button id="reharmonize">Reharmonize (New Progression)</button>
</div>
```

### 8. Tension Control

**Tension = 0% (Consonant)**:
- Use only basic triads and 7th chords
- Avoid extensions (9, 11, 13)
- Prefer I, IV, V, vi
- Simple progressions

**Tension = 50% (Moderate)**:
- Add 9ths and 13ths
- Use ii-V-I patterns
- Include modal interchange
- Berklee standard voicings

**Tension = 100% (Dissonant/Outside)**:
- Add ♭9, #9, #11, ♭13 alterations
- Tritone substitutions frequent
- Polychords
- Quartal/quintal harmony
- Chromatic voice leading

---

## Implementation Plan

### Step 1: Add Harmony Database (50 lines)
- Modal chord scales
- Markov transition probabilities
- Chord quality definitions

### Step 2: Add Melodic Analyzer (40 lines)
- Frequency → scale degree
- Chord tone detection
- Tension calculation

### Step 3: Add Markov Engine (60 lines)
- Next chord selection
- Harmonic rhythm tracking
- Progression generation

### Step 4: Add Voicing Algorithm (80 lines)
- 4 voicing types
- Voice leading logic
- Pitch calculation

### Step 5: Add Csound Instruments (120 lines)
- 4 harmony instruments (501-504)
- FM pad with chorus/reverb
- ADSR control
- Voice leading

### Step 6: Add UI Controls (100 lines)
- Per-slot harmony section
- Master harmony controls
- Event listeners

### Step 7: Integration (50 lines)
- Connect analyzer to Markov engine
- Send voicings to Csound
- Beat-synchronized chord changes

**Total Estimated**: ~500 lines

---

## Example Musical Flow

1. **User loads image** → Slot A scanning
2. **Enable harmony** → Checkbox checked
3. **Modal center**: Dorian selected
4. **Tension**: 50% (moderate)
5. **Harmonic rhythm**: 4 beats/chord

**What Happens**:
- Beat 1: Analyzer detects melody on D (tonic of D Dorian)
- Markov selects: **i-7** (D-7) chord
- Voicing algorithm generates Drop-2: D A C F
- Csound plays 4-voice chord (instr 501)

- Beat 5: Melody moves to G (subdominant)
- Markov selects: **IV7** (G7) chord (50% probability from i-7)
- Voice leading: D→G, A→B, C→C (common tone), F→F (common tone)
- Smooth transition

- Beat 9: Melody on A (dominant)
- Markov selects: **v-7** (A-7)
- Voice leading continues smoothly

**Result**: Rich harmonic bed that follows and enhances the melodic contour.

---

## Musical Applications

### 1. Modal Jazz Exploration
- Set modal center to Dorian
- Scan image creates modal melody
- Harmony reinforces modal color
- Like Miles Davis "So What" texture

### 2. Contrapuntal Harmony
- Enable harmony on Slot A
- Enable polyphonic on Slots B+C
- Slot A: melody + harmony
- Slots B+C: countermelodies
- Full ensemble texture

### 3. Reharmonization Experiments
- Load same image in multiple slots
- Each slot: different modal center
- Hear same melody with different harmonizations
- Educational tool for harmony study

### 4. Tension Modulation
- Start at 0% tension (consonant)
- Gradually increase to 100% (outside)
- Hear harmonic color evolve
- Real-time tension control

### 5. Phrase-Based Harmony
- Enable phrase mode (4 play / 4 rest)
- Harmony only on play beats
- Creates question/answer texture
- Melody alone → melody + harmony alternation

---

## Next Steps

Ready to implement! This will add ~500 lines of code:
- New harmony database
- Markov chain engine
- Melodic analyzer
- Voicing algorithms
- 4 new Csound instruments
- UI controls per slot

Estimated implementation time: 45-60 minutes

Should I proceed?
