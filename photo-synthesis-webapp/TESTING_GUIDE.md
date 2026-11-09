# Musical Features Testing Guide

**Server Running**: `http://localhost:8080/photo_multi_engine_complete.html`  
**Status**: ✅ All features implemented, ready for testing

---

## Quick Start (5 Minutes)

### 1. Load the Application
```
http://localhost:8080/photo_multi_engine_complete.html
```

### 2. Basic Setup
1. Click **"Load Image"** and select an image (or drag & drop)
2. Click **"Start"** to begin audio engine
3. Set **Master Gain** to 0.5 (middle position)
4. Select **Slot A** (should auto-select on start)

### 3. Test BPM Clock (30 seconds)
1. Locate **BPM slider** at top (default: 120)
2. Watch **4 beat lights** pulse in sync
3. Adjust BPM to 80 → lights slow down
4. Adjust BPM to 160 → lights speed up
5. Click **"Tap Tempo"** button 4 times rhythmically → BPM updates

✅ **Expected**: Beat lights pulse evenly, BPM value updates

### 4. Test Phrase Mode (1 minute)
1. Check **"Enable Phrase"** checkbox for Slot A
2. Set **Play Beats** to 4
3. Set **Rest Beats** to 2
4. Listen: Sound plays for 4 beats, silent for 2 beats, repeats

✅ **Expected**: Rhythmic gating synchronized to beat lights

### 5. Test ADSR Envelope (1 minute)
1. Set **Attack** to 500ms
2. Set **Decay** to 200ms
3. Set **Sustain** to 0.6
4. Set **Release** to 1000ms
5. Enable phrase mode → hear slow attack, quick decay, smooth release

✅ **Expected**: Amplitude envelope shapes each phrase cycle

### 6. Test Scale Quantization (1 minute)
1. Select **Scale**: "major"
2. Select **Root**: "C"
3. Move mouse over image → pitches snap to C major scale
4. Change scale to "pentatonic-minor" → different harmonic content
5. Change root to "D" → transposed

✅ **Expected**: Pitches locked to selected scale/root

### 7. Test Scan Modes (1 minute)
1. **Line mode** (default): Vertical scanning line auto-advances
2. Click **"Mouse"** button: Move mouse → sound follows position, crosshair visible
3. Click **"Random"**: Position jumps every 4 beats (default), crosshair jumps
4. Adjust **Random Jump Rate** to 2 beats → faster jumps

✅ **Expected**: 3 distinct scanning behaviors, visual feedback matches

---

## Detailed Feature Testing (20 Minutes)

### BPM Clock System

#### Basic Tempo
- [ ] BPM slider: 40 BPM → very slow pulses
- [ ] BPM slider: 240 BPM → very fast pulses
- [ ] Beat lights: 4 lights cycle 0→1→2→3→0 repeatedly
- [ ] Beat counter visible in UI (if indicator added)

#### Tap Tempo
1. Click **"Tap Tempo"** 2 times, 1 second apart → BPM ≈ 60
2. Click **"Tap Tempo"** 4 times, 0.5 seconds apart → BPM ≈ 120
3. Click **"Tap Tempo"** 3 times irregularly → BPM averages taps
4. Wait 3 seconds, tap again → resets tap sequence

✅ **Expected**: BPM calculates from tap intervals (min 2 taps, max 4)

---

### Phrase Mode (Per Slot)

#### Basic Gating
1. Slot A: Enable phrase, 4 play, 2 rest
2. Slot B: Enable phrase, 8 play, 4 rest
3. Listen: A gates faster than B (independent timing)

#### Edge Cases
- [ ] Play beats = 1, Rest beats = 0 → continuous sound (no rest)
- [ ] Play beats = 16, Rest beats = 8 → long cycles
- [ ] Play beats = 2, Rest beats = 6 → sparse, percussive

#### Synchronization
- [ ] All phrase transitions align with beat lights
- [ ] Changing BPM doesn't break phrase cycles
- [ ] Disable phrase → sound continuous

✅ **Expected**: Precise beat-locked gating per slot

---

### ADSR Envelopes

#### Test Each Engine
For each engine (FM, Granular, Additive, Percussive, Waveguide):

1. **Attack Test**: Set Attack = 2000ms → slow fade-in
2. **Decay Test**: Set Attack = 10ms, Decay = 1000ms → quick rise, slow fall
3. **Sustain Test**: Set Sustain = 0.2 → low held level
4. **Release Test**: Set Release = 3000ms → long tail after note-off

**Engines to Test**:
- [ ] FM (instr 10/20/30/40)
- [ ] Granular (instr 11/21/31/41)
- [ ] Additive (instr 12/22/32/42)
- [ ] Percussive (instr 13/23/33/43)
- [ ] Waveguide (instr 14/24/34/44)

#### Phrase + ADSR Interaction
1. Enable phrase: 4 play, 4 rest
2. Set Attack = 1000ms, Release = 1000ms
3. Listen: 1s fade-in during play beats, 1s fade-out during rest beats

✅ **Expected**: Smooth amplitude shaping across all engines

---

### Scale Quantization

#### Test All Scales
For each scale, move mouse over image and listen for pitch snapping:

- [ ] **chromatic** → no quantization (all pitches allowed)
- [ ] **major** → happy, tonal (C-D-E-F-G-A-B)
- [ ] **minor** → sad, tonal (C-D-Eb-F-G-Ab-Bb)
- [ ] **harmonic-minor** → exotic, raised 7th
- [ ] **melodic-minor** → smooth, raised 6th+7th
- [ ] **pentatonic-major** → simple, 5 notes (C-D-E-G-A)
- [ ] **pentatonic-minor** → bluesy, 5 notes (C-Eb-F-G-Bb)
- [ ] **blues** → bluesy with b5 (C-Eb-F-F#-G-Bb)
- [ ] **dorian** → modal, jazzy (C-D-Eb-F-G-A-Bb)
- [ ] **phrygian** → Spanish, dark (C-Db-Eb-F-G-Ab-Bb)
- [ ] **lydian** → bright, dreamy (C-D-E-F#-G-A-B)
- [ ] **mixolydian** → rock, dominant (C-D-E-F-G-A-Bb)
- [ ] **whole-tone** → dreamy, ambiguous (C-D-E-F#-G#-A#)

#### Root Note Transposition
1. Scale = "major", Root = "C" → C major (no sharps/flats)
2. Scale = "major", Root = "D" → D major (F#, C#)
3. Scale = "major", Root = "Bb" → Bb major (Bb, Eb)

✅ **Expected**: Clear harmonic differences, correct transposition

---

### Manual Scan Mode

#### Mouse Control
1. Click **"Mouse"** button
2. Move mouse slowly left-to-right → pitch changes
3. Move mouse slowly top-to-bottom → brightness/timbre changes
4. Move mouse in circles → sound follows path
5. Crosshair overlay visible, follows mouse exactly

#### Edge Cases
- [ ] Mouse at top-left corner → extreme parameter values
- [ ] Mouse at bottom-right corner → opposite extreme
- [ ] Mouse off canvas → sound stops/freezes (expected behavior)
- [ ] Rapid mouse movement → smooth parameter transitions

✅ **Expected**: Real-time tracking, no audio glitches

---

### Random Scan Mode

#### Beat-Synced Jumps
1. Click **"Random"** button
2. Set **Random Jump Rate** to 4 beats
3. Watch crosshair jump every 4 beat lights
4. Set **Random Jump Rate** to 1 beat → jump every beat

#### Independent Per Slot
1. Slot A: Random mode, jump rate = 2 beats
2. Slot B: Random mode, jump rate = 4 beats
3. Listen: A jumps 2× faster than B

#### Visual Feedback
- [ ] Crosshair jumps to new position on beat
- [ ] Jump timing aligns with beat lights
- [ ] Each jump produces audible parameter change

✅ **Expected**: Precise beat-locked jumps per slot

---

### Scan Mode Switching

#### Smooth Transitions
1. Start in **Line** mode (vertical scanning)
2. Switch to **Mouse** mode → no audio dropout, crosshair appears
3. Switch to **Random** mode → no audio dropout, jumps start
4. Switch back to **Line** mode → scanning resumes

#### Visual Consistency
- [ ] Line mode: Vertical scan line visible
- [ ] Mouse mode: Crosshair follows mouse
- [ ] Random mode: Crosshair jumps on beats
- [ ] Overlay always shows correct mode feedback

✅ **Expected**: Seamless mode changes, no glitches

---

## Integration Testing (10 Minutes)

### All Features Active
1. **Setup**:
   - BPM = 100
   - Scale = "pentatonic-minor", Root = "A"
   - Slot A: FM, Phrase (4 play, 2 rest), ADSR (300/200/0.6/500), Random (jump 4 beats)
   - Slot B: Granular, Phrase (8 play, 0 rest), ADSR (100/100/0.8/200), Mouse mode
   - Slot C: Additive, Phrase (2 play, 6 rest), ADSR (500/300/0.5/1000), Line mode
   - Slot D: Waveguide, continuous, ADSR (50/50/0.9/100), Random (jump 2 beats)

2. **Listen**: 
   - A and C gate rhythmically (different patterns)
   - B is continuous
   - D is continuous but jumps position
   - All pitches locked to A pentatonic-minor
   - ADSR shapes each slot differently

3. **Change BPM to 140**:
   - All phrase cycles speed up
   - Random jumps speed up
   - Beat lights speed up

4. **Change Scale to "major", Root to "C"**:
   - Harmonic content shifts (minor → major)
   - All slots immediately reflect new scale

✅ **Expected**: Complex rhythmic/harmonic interplay, no conflicts

---

## Performance Testing

### CPU Usage
1. Open **Activity Monitor** (macOS) or **Task Manager** (Windows)
2. Find browser process (Chrome/Safari/Firefox)
3. Note CPU % with:
   - All 4 slots active
   - All features enabled (BPM, phrase, ADSR, scale, random scan)
   - Master gain at 0.5

✅ **Expected**: <50% CPU on modern machine (M1/M2, i7/i9)

### Audio Dropout
1. Enable all 4 slots with different engines
2. Enable phrase mode on all slots
3. Set BPM to 200 (fast)
4. Move mouse rapidly in Manual mode
5. Listen for:
   - [ ] Clicks/pops
   - [ ] Audio dropouts
   - [ ] Stuttering
   - [ ] Latency

✅ **Expected**: Clean audio, no dropouts

---

## Bug Reporting Template

If you find issues, use this format:

```
**Feature**: [BPM Clock / Phrase Mode / ADSR / Scale / Manual Scan / Random Scan]
**Engine**: [FM / Granular / Additive / Percussive / Waveguide / All]
**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Behavior**:

**Actual Behavior**:

**Browser**: [Chrome 120 / Safari 17 / Firefox 121]
**OS**: [macOS 14 / Windows 11 / Linux]
**Console Errors**: [Copy from browser dev console]
```

---

## Success Criteria

### Minimum Viable (Must Pass)
- [x] All 5 engines compile without errors
- [ ] BPM clock runs at correct tempo
- [ ] Beat lights pulse in sync
- [ ] Phrase mode gates amplitude correctly
- [ ] ADSR envelopes shape sound in all engines
- [ ] Scale quantization affects all frequencies
- [ ] Manual scan tracks mouse position
- [ ] Random scan jumps on beat

### Nice to Have
- [ ] Tap tempo works accurately
- [ ] All 13 scales sound distinct
- [ ] Phrase mode + ADSR interaction smooth
- [ ] No audio glitches during mode switching
- [ ] CPU usage <50%

### Excellent
- [ ] All features work simultaneously without conflicts
- [ ] Smooth transitions between all states
- [ ] Intuitive UI behavior
- [ ] No browser console errors
- [ ] CPU usage <30%

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Update `README.md` with musical features documentation
2. Create user tutorial video/guide
3. Add preset system for saving musical state
4. Consider additional features (LFO, step sequencer, MIDI input)

### If Issues Found 🐛
1. Document bugs in `BUGS.md`
2. Prioritize fixes (critical → nice-to-have)
3. Create fix plan
4. Iterate and re-test

---

**Happy Testing! 🎵**

Let me know what you discover — excited to hear this in action!

---
