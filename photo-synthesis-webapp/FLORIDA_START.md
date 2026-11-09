# 🌴 FLORIDA STARTUP GUIDE 🌴

**Last Session**: Fixed all Csound 7 compilation errors + invalid instrument numbers
**Status**: ✅ Orchestra compiles cleanly, no syntax errors
**Next**: Test audio output in Florida

---

## 🚀 QUICK START (2 minutes)

```bash
# Terminal 1:
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
python3 -m http.server 8080

# Terminal 2 (or just use browser):
open -na "Google Chrome" --args --incognito http://localhost:8080/photo_multi_engine_complete.html
```

**In Chrome**:
1. Press Cmd+Option+J to open console
2. Click "🎬 Start Audio Engine" button
3. **Slot A auto-starts with FM synth!**
4. Click 📁 folder button → load any image
5. **Move mouse over image → should hear FM synthesis!**

---

## ✅ WHAT WAS FIXED (Last Session)

### 1. **Invalid Instrument Numbers** (CRITICAL FIX)
   - **Problem**: Stop button tried to stop instruments 10-44 (ALL numbers)
   - **Issue**: Only 10,11,12,13,14,20,21... exist (NOT 15,16,17,18,19...)
   - **Fix**: Changed to only stop valid instruments
   - **Result**: No more "invalid instrument number" spam

### 2. **Engine Switch Bug**
   - **Problem**: Tried to stop old instrument but used new engine value
   - **Fix**: Save `oldEngine` before changing, use it for stop command
   - **Result**: Clean engine switching

### 3. **Auto-Start Slot A**
   - **Added**: Slot A FM synth auto-starts after initialization
   - **Why**: Immediate sound when you load an image!
   - **Result**: No need to press Play button first

### 4. **Previous Fixes (Already Applied)**
   - ✅ All 9 envelope `i(k)` casts
   - ✅ schedkwhen instead of schedule
   - ✅ Function table in orchestra header
   - ✅ Correct initialization order
   - ✅ All `outs` → `out`

---

## 🎯 EXPECTED CONSOLE OUTPUT

```
🎵 Loading Csound 7 WASM...
🎼 Compiling orchestra...
🔊 Audio context state: running
📻 Initializing channels...
🎚️ Starting master reverb...
✅ Reverb (90) started
🎹 Starting harmony instruments...
✅ Harmony A (501) started
✅ Harmony B (502) started
✅ Harmony C (503) started
✅ Harmony D (504) started
🎸 Auto-starting Slot A (FM synth)...
✅ Slot A playing - move mouse over image for sound!
✅ Ready! Load photos and press ▶ Play
--Csound version 7.0 (double samples) 2026-10-22
```

**No errors, no warnings, no "invalid instrument" messages!**

---

## 🧪 TEST COMMANDS (In Browser Console)

### Test 1: Simple Tone (440 Hz for 3 seconds)
```javascript
await csound.inputMessage('i 999 0 3')
```
Should hear: Clear 440 Hz sine tone

### Test 2: Check Channels
```javascript
await csound.setControlChannel('A_freq', 880);
const val = await csound.getControlChannel('A_freq');
console.log('Channel set to:', val);
```
Should see: `Channel set to: 880`

### Test 3: Manual Start Slot B Granular
```javascript
await csound.inputMessage('i 21 0 -1')
```
Should hear: Granular synthesis when mouse moves

### Test 4: Stop All
```javascript
await csound.inputMessage('i -10 0 0')  // Stop slot A
```
Sound should stop

---

## 🎛️ VALID INSTRUMENTS (Reference)

```
SLOT A (10-14):  10=FM  11=Granular  12=Additive  13=Percussive  14=Waveguide
SLOT B (20-24):  20=FM  21=Granular  22=Additive  23=Percussive  24=Waveguide
SLOT C (30-34):  30=FM  31=Granular  32=Additive  33=Percussive  34=Waveguide
SLOT D (40-44):  40=FM  41=Granular  42=Additive  43=Percussive  44=Waveguide

EFFECTS:         90=Master Reverb
HELPERS:         98=Percussion helper  99=Granular helper
HARMONY:         501=A  502=B  503=C  504=D
TEST:            999=440 Hz tone
```

---

## 🔧 IF STILL NO SOUND

### Check 1: Audio Context State
```javascript
const ctx = await csound.getAudioContext();
console.log('Audio context:', ctx.state);
```
Should be: `"running"` (not "suspended")

### Check 2: Verify Instruments Started
Look for these in console:
- ✅ Reverb (90) started
- ✅ Slot A playing

### Check 3: Check Channel Values
```javascript
await csound.getControlChannel('A_freq')   // Should be ~200-1000
await csound.getControlChannel('A_amp')    // Should be > 0
```

### Check 4: Browser Audio
- Make sure Chrome isn't muted
- Check system volume
- Try headphones vs speakers

### Check 5: Simplify Test
```javascript
// Bypass photo system, just play a note
await csound.setControlChannel('A_freq', 440);
await csound.setControlChannel('A_amp', 0.5);
await csound.inputMessage('i 10 0 5');  // 5 second note
```

---

## 📝 KNOWN WORKING PATTERN (From weather_sonification_v2.html)

Richard's weather sonification app works perfectly. It uses:
1. `compileOrc()` BEFORE `setOption()`
2. Audio context resume
3. `start()` then `inputMessage()`
4. `i(k)` casting for envelopes

**We copied this exact pattern!**

---

## 🐛 IF YOU SEE ERRORS

### "memory access out of bounds"
- **Cause**: Compilation failed (check for syntax errors above it)
- **Fix**: Orchestra must compile cleanly first

### "could not find playing instr X"
- **Cause**: Trying to stop an instrument that was never started
- **Fix**: Already fixed! Should not appear anymore

### "invalid instrument number"
- **Cause**: Trying to use instr 15-19, 25-29, etc (don't exist)
- **Fix**: Already fixed! Should not appear anymore

### "outs is deprecated"
- **Cause**: Old code still using `outs` instead of `out`
- **Fix**: Hard refresh (Cmd+Shift+R) or open new incognito window

---

## 🎨 WORKING WORKFLOW (Once Sound Works)

1. **Load images**: Click 📁 buttons in slots A, B, C, D
2. **Choose mode**: Dropdown (A only, A+B, All 4 slots, etc.)
3. **Select engines**: Each slot has 5 engine types
4. **Adjust params**: Sliders control synthesis parameters
5. **Play**: ▶ button (Slot A auto-starts, others need Play)
6. **Move mouse**: Over images to generate sound
7. **Harmony**: Toggle Berklee Modal Jazz chords
8. **Sequence**: Auto-scan through images
9. **Save**: Export presets, share, enjoy!

---

## 📊 SESSION HANDOFF

**File**: `photo_multi_engine_complete.html` (130KB)
**Orchestra**: Lines 919-1559 (Csound code)
**JavaScript**: Lines 2800-2900 (initialization)

**Last changes**:
- Line 2915: Fixed stop button instrument loop
- Line 2663: Fixed engine switch (use oldEngine)
- Line 2860: Added auto-start for Slot A

**Server**: `python3 -m http.server 8080` in photo-synthesis-webapp/
**Browser**: Chrome incognito (no cache)

---

## 🌟 SUCCESS CRITERIA

✅ Console shows all instruments started
✅ No syntax errors
✅ No "invalid instrument" errors
✅ Test tone works (`i 999 0 3`)
✅ Mouse over image → sound!

**When you hear sound, you're golden! 🎉**

Safe travels to Florida! 🌴✈️

---

**Next session**: If sound works, test all 5 engines × 4 slots + harmony + effects!
