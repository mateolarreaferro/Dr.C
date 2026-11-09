# Polyphonic / Counterpoint Feature Guide

## Overview

The **Polyphonic / Counterpoint** feature enables multi-voice musical textures by allowing multiple slots to scan the **same image** at different speeds and phase offsets. This creates contrapuntal textures similar to:

- **2-part inventions** (Bach-style two-voice counterpoint)
- **4-voice fugues** (complex polyphonic textures)
- **Canons/rounds** (same melody at staggered entry points)

## What Was Added

### 1. Per-Slot Controls (All 4 Slots)

Each slot now has two new controls in the "Polyphonic Controls" section:

- **Scan Speed** (0.25× to 4×)
  - Controls how fast the slot scans through the image
  - 1.0× = default speed
  - 0.5× = half speed (slower)
  - 2.0× = double speed (faster)
  
- **Phase Offset** (0% to 100%)
  - Sets the starting position in the scan cycle
  - 0% = start at beginning
  - 50% = start at middle
  - 100% = start at end (wraps to beginning)

### 2. Master Controls (New Section)

Located below the Musical Controls section:

- **Clone Last Image to All Slots** button
  - One-click to load the most recently loaded image into all 4 slots
  - Enables quick setup for multi-voice counterpoint
  
- **Quick Preset Buttons**:
  - **2-Part Invention** - Simple two-voice counterpoint (Slots A+B active)
  - **4-Voice Fugue** - Complex four-voice polyphony (all slots active)
  - **Canon (Round)** - Staggered entry points (all slots, same speed)

## How to Use

### Quick Start (2-Part Invention)

1. **Load an image** into any slot (A, B, C, or D)
2. Click **"Clone Last Image to All Slots"**
3. Click **"2-Part Invention"** preset button
4. Start scanning Slot A and Slot B
5. Hear two voices scanning the same image at different speeds (1× and 2×) with phase offset

**Result**: Slot A plays the melody at normal speed, Slot B plays at double speed with 25% phase offset, creating interlocking melodic lines.

### Advanced (4-Voice Fugue)

1. **Load an image** into any slot
2. Click **"Clone Last Image to All Slots"**
3. Click **"4-Voice Fugue"** preset button
4. Start scanning all 4 slots (A, B, C, D)
5. Hear four voices at different speeds:
   - Slot A: 1.0× (subject)
   - Slot B: 0.75× (answer, slower)
   - Slot C: 1.5× (countersubject, faster)
   - Slot D: 0.5× (augmentation, half-speed)

**Result**: Complex polyphonic texture with 4 independent voices derived from the same image.

### Canon (Round)

1. **Load an image** into any slot
2. Click **"Clone Last Image to All Slots"**
3. Click **"Canon (Round)"** preset button
4. Start scanning all 4 slots
5. Hear the same melody at staggered entry points:
   - Slot A: starts at 0%
   - Slot B: starts at 25%
   - Slot C: starts at 50%
   - Slot D: starts at 75%

**Result**: Like "Row, Row, Row Your Boat" - same melody, different starting positions.

### Manual Customization

You can manually adjust each slot's:

1. **Scan Speed** - Use the slider in each slot's "Polyphonic Controls" section
2. **Phase Offset** - Use the slider in each slot's "Polyphonic Controls" section

**Example Custom Setup**:
- Slot A: 1.0× speed, 0% phase
- Slot B: 1.33× speed, 33% phase
- Slot C: 0.67× speed, 67% phase
- Slot D: inactive (0.25× speed)

This creates a 3-voice heterophonic texture with custom speed relationships.

## Musical Applications

### 1. Temporal Polyphony
Multiple voices scanning at different rates create **evolving rhythmic relationships** (Steve Reich-style phase music).

### 2. Contrapuntal Textures
Two or more independent melodic lines that interweave (Bach-style counterpoint).

### 3. Heterophony
Simultaneous variations of the same melody - common in non-Western music traditions.

### 4. Textural Density Control
- **1 voice** = solo melody
- **2 voices** = duet
- **4 voices** = full ensemble

### 5. Rhythmic Complexity
Different scan speeds create complex **polyrhythmic** relationships:
- 1× vs 2× = 2:1 ratio (simple)
- 1× vs 0.75× = 4:3 ratio (complex)
- 1× vs 1.5× = 2:3 ratio (hemiol)

## Integration with Other Features

The polyphonic feature works seamlessly with:

- **BPM Clock** - All voices stay synchronized to the global tempo
- **Phrase Mode** - Each voice can have independent play/rest cycles
- **ADSR Envelopes** - Each voice has independent articulation
- **Scale Quantization** - All voices locked to the selected scale
- **5 Engines** - Each voice can use a different synthesis engine

**Example Complex Setup**:
- Slot A: FM engine, 1× speed, phrase mode (4 play / 2 rest)
- Slot B: Granular engine, 2× speed, phrase mode (8 play / 0 rest)
- Slot C: Additive engine, 0.5× speed, long ADSR attack
- Slot D: Percussive engine, 1.5× speed, short ADSR

This creates a **heterogeneous polyphonic texture** where each voice has its own timbre, rhythm, and articulation - all derived from the same image.

## Technical Details

### State Variables (Per Slot)
```javascript
scanSpeed: 1.0,      // Multiplier for scan rate (0.25× to 4×)
phaseOffset: 0.0,    // Starting position (0.0 to 1.0)
```

### Speed Multiplier Logic
```javascript
// In tick() function (line ~2159)
s.pos += 0.002 * s.scanSpeed;
```

### Phase Offset Logic
```javascript
// In loadPixels() function (line ~1597)
slots[slot].pos = slots[slot].phaseOffset;
```

### Clone Image Logic
```javascript
// Saves last loaded image globally
lastLoadedImage = { imgData, width, height, img };

// Copies to all slots
slots[slot].pixels = new Uint8ClampedArray(imgData.data);
slots[slot].pos = slots[slot].phaseOffset;
```

## Preset Values

### 2-Part Invention
- **Slot A**: 1.0× speed, 0% phase
- **Slot B**: 2.0× speed, 25% phase
- **Slots C+D**: 0.25× speed (inactive)

### 4-Voice Fugue
- **Slot A**: 1.0× speed, 0% phase (subject)
- **Slot B**: 0.75× speed, 20% phase (answer, slower)
- **Slot C**: 1.5× speed, 40% phase (countersubject, faster)
- **Slot D**: 0.5× speed, 60% phase (augmentation, half-speed)

### Canon (Round)
- **Slot A**: 1.0× speed, 0% phase
- **Slot B**: 1.0× speed, 25% phase
- **Slot C**: 1.0× speed, 50% phase
- **Slot D**: 1.0× speed, 75% phase

## Testing Checklist

- [ ] Load image into Slot A
- [ ] Click "Clone Last Image to All Slots"
- [ ] Verify all 4 slots show the same image
- [ ] Click "2-Part Invention" preset
- [ ] Start Slots A and B scanning
- [ ] Hear two voices at different speeds
- [ ] Click "4-Voice Fugue" preset
- [ ] Start all 4 slots scanning
- [ ] Hear four independent voices
- [ ] Click "Canon (Round)" preset
- [ ] Verify staggered entry points
- [ ] Manually adjust scan speed sliders
- [ ] Verify real-time speed changes
- [ ] Manually adjust phase offset sliders
- [ ] Verify scan position updates immediately
- [ ] Test with different engines per slot
- [ ] Test with phrase mode enabled
- [ ] Test with ADSR variations
- [ ] Test with scale quantization

## Implementation Summary

**Files Modified**: `photo_multi_engine_complete.html` (2673 → 2922 lines, +249 lines)

**New UI Elements**:
- 8 per-slot controls (4 slots × 2 controls)
- 1 clone button
- 3 preset buttons
- 8 value displays

**New Functions**:
- `cloneImageAll()` - Clone image to all slots
- `applyPreset2Voice()` - 2-part invention preset
- `applyPreset4Voice()` - 4-voice fugue preset
- `applyPresetCanon()` - Canon/round preset

**Modified Functions**:
- `tick()` - Apply speed multiplier to scan increment
- `loadPixels()` - Apply phase offset to initial position

**New State Variables**:
- `lastLoadedImage` (global) - Tracks last loaded image for cloning
- `scanSpeed` (per slot) - Scan speed multiplier (0.25× to 4×)
- `phaseOffset` (per slot) - Phase offset (0.0 to 1.0)

**Event Listeners Added**: 10 total
- 1 clone button
- 3 preset buttons
- 4 scan speed sliders
- 4 phase offset sliders (with real-time position update)

---

**Status**: ✅ **COMPLETE** - All polyphonic/counterpoint features implemented and ready for testing.

**Next Steps**: Load the updated HTML file at `http://localhost:8080/photo_multi_engine_complete.html` and test the presets!
