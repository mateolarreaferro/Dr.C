# 🌴 Quick Start Guide - Florida Session

**Goal**: Pick up exactly where we left off and get audio working!

---

## 🚀 Step 1: Start the Server (2 commands)

Open Terminal and run:

```bash
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
python3 -m http.server 8080
```

**Leave this terminal window open** (server runs in foreground).

---

## 🌐 Step 2: Open Browser (1 command)

**In a NEW terminal window**, run:

```bash
open -na "Google Chrome" --args --incognito http://localhost:8080/photo_multi_engine_complete.html
```

This opens Chrome in **incognito mode** (no cache issues).

---

## 🔍 Step 3: Open Browser Console

In Chrome:
- Press `Cmd+Option+J` (Mac)
- Or: View → Developer → JavaScript Console

---

## 📊 Step 4: Check What You See

### ✅ Good Signs (Orchestra Compiled):
```
--Csound version 7.0 (double samples) 2026-10-22
setting dummy interface
```

### ❌ Bad Signs (Errors):
```
syntax error, Unable to find opcode...
INIT ERROR...
```

---

## 🎵 Step 5: Test Audio

1. Click **"Choose Folder"** button (Slot A)
2. Select a folder with images
3. Click **"Mouse Scan"** mode button
4. **Move mouse** over the image

**Expected**: Should hear sound 👂  
**Current**: No sound ⚠️

---

## 🐛 Step 6: Debug (If No Sound)

### Quick Check: Are Instruments Running?

In the browser console, type:

```javascript
await csound.inputMessage('i 999 0 5')
```

This should play a **5-second test tone** (we'll add this instrument if it doesn't exist).

### Check Audio Context:

```javascript
const ctx = await csound.getAudioContext();
console.log('Audio state:', ctx.state);
console.log('Sample rate:', ctx.sampleRate);
```

**Should see**:
- `Audio state: "running"`
- `Sample rate: 44100`

**If you see** `Audio state: "suspended"`, run:

```javascript
await ctx.resume();
console.log('Audio state:', ctx.state);
```

---

## 📖 Step 7: Read the Full Session Summary

Open the detailed handoff document:

```bash
open SESSION_HANDOFF_FLORIDA.md
```

This has:
- ✅ Everything we fixed (envelopes, schedules, UDOs)
- 🔍 6 debugging hypotheses
- 🎯 Detailed test procedures
- 💡 What to try next

---

## 🎯 Most Likely Issues (Priority Order)

### Issue #1: Audio Context Suspended
**Test**: Check `audioContext.state` in console  
**Fix**: Call `audioContext.resume()`

### Issue #2: Missing Instruments 98 & 99
**Test**: Search for `instr 98` in the HTML file  
**Fix**: Add the grain/percussion instruments

### Issue #3: Channels Not Connected
**Test**: Log channel values in console  
**Fix**: Verify `setControlChannel` is working

---

## 🛠️ Quick Reference Commands

### If Server Stops:
```bash
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
python3 -m http.server 8080
```

### If Browser Needs Refresh:
```bash
# In browser: Cmd+Shift+R (hard reload)
# Or reopen incognito:
open -na "Google Chrome" --args --incognito http://localhost:8080/photo_multi_engine_complete.html
```

### View Recent Changes:
```bash
cd /Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp
git diff photo_multi_engine_complete.html | less
```

### Search for Code:
```bash
grep -n "instr 98" photo_multi_engine_complete.html
grep -n "schedkwhen" photo_multi_engine_complete.html
```

---

## 📁 Important Files

All in: `/Users/richardboulanger/Dr.C-Terminal.C/photo-synthesis-webapp/`

- **photo_multi_engine_complete.html** - The main file (127 KB)
- **SESSION_HANDOFF_FLORIDA.md** - Full session summary (detailed!)
- **START_IN_FLORIDA.md** - This quick start guide
- **ENVELOPE_FIX_COMPLETE.md** - What we fixed (envelopes)

---

## ✅ What's Already Working

- ✅ **Orchestra compiles** (no syntax errors!)
- ✅ **Csound 7.0 running** in browser
- ✅ **All envelopes fixed** (9 locations with i(k) casting)
- ✅ **Schedule calls fixed** (schedkwhen instead of schedule)
- ✅ **Function tables created** (sine wave for harmony)
- ✅ **25 instruments defined** (5 engines × 4 slots + 4 harmony + 1 reverb)

---

## 🎵 The Final Step

**We're one debugging session away from audio!**

The hard work is done - orchestra compiles perfectly. Just need to connect the audio pipeline.

---

## 💡 If You Get Stuck

### Option 1: Add Test Tone Instrument

Edit the HTML file, add this **before the closing `</CsInstruments>`** (around line 1545):

```csound
; === TEST INSTRUMENT ===
instr 999
  aSig = oscili:a(0.3, 440)  ; 440 Hz sine wave at 30% amplitude
  outs aSig, aSig
endin
```

Then in browser console:
```javascript
await csound.inputMessage('i 999 0 5')  // 5 second test tone
```

**If you hear this**, audio pipeline works - issue is with main instruments.  
**If you don't hear this**, audio context or browser permission issue.

### Option 2: Check for Missing Instruments

Search the HTML file:
```bash
grep -n "^instr 98\|^instr 99" photo_multi_engine_complete.html
```

If these don't exist, that's the problem - `schedkwhen` is trying to schedule instruments that don't exist!

### Option 3: Simplify and Test

Comment out harmony instruments (501-504) temporarily and test with just FM engine.

---

## 🎓 Remember

**The system compiled with ZERO errors** - this is HUGE progress! 

All the Csound 7 compatibility issues are solved:
- ✅ i(k) casting
- ✅ schedkwhen syntax
- ✅ UDO parameter counts
- ✅ UDO output types
- ✅ Function tables

**Only issue**: Audio output not connected yet.

---

## 🌴 Florida Workflow

1. **Terminal 1**: Start server (`python3 -m http.server 8080`)
2. **Terminal 2**: Open browser (incognito Chrome)
3. **Browser**: Open console (`Cmd+Option+J`)
4. **Test**: Load images, mouse scan mode
5. **Debug**: Check console messages, test audio context
6. **Fix**: Add test instrument, check for missing instrs 98/99
7. **Celebrate**: When you hear sound! 🎉

---

**Good luck in Florida! You're SO close!** 🚀🎵

**Next agent can pick up from here by reading `SESSION_HANDOFF_FLORIDA.md`**
