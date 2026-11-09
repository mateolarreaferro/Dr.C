# 🚨 URGENT FLORIDA FIX - Audio Context NULL

## THE PROBLEM
`getAudioContext()` returns NULL → Csound uses "dummy interface" → NO SOUND

But instruments ARE running! Just outputting to silence.

---

## IMMEDIATE FIX TO TRY IN FLORIDA

### Option 1: Check csound7-lib Installation

The local `csound7-lib/csound.js` might be corrupted or wrong version.

**Test with CDN instead:**

Change line 913 in `photo_multi_engine_complete.html`:

```javascript
// OLD:
import { Csound } from './csound7-lib/csound.js';

// NEW (try CDN):
import { Csound } from 'https://unpkg.com/@csound/browser@7.0.0-beta5/dist/csound.js';
```

Save, reload incognito, click Start Audio Engine.

---

### Option 2: Force Audio Context Creation

Add BEFORE `csound = await Csound()`:

```javascript
log('🎵 Loading Csound 7 WASM...');

// Create audio context manually FIRST
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
log('🔊 Pre-created audio context:', audioCtx.state);
await audioCtx.resume();
log('🔊 Pre-created audio context resumed:', audioCtx.state);

csound = await Csound({
  useWorker: false,
  useSPN: false,
  outputChannelCount: 2,
  audioContext: audioCtx  // Pass it in!
});
```

---

### Option 3: Check Chrome Permissions

1. Chrome → Settings → Privacy and Security → Site Settings
2. Sound → Check if localhost is blocked
3. Try in Safari instead (different audio engine)

---

### Option 4: Test with Simple Csound Page

Create `test_audio.html`:

```html
<!DOCTYPE html>
<html>
<head><title>Csound Test</title></head>
<body>
<button id="start">START</button>
<div id="log"></div>

<script type="module">
import { Csound } from './csound7-lib/csound.js';

document.getElementById('start').addEventListener('click', async () => {
  const log = (msg) => {
    document.getElementById('log').innerHTML += msg + '<br>';
    console.log(msg);
  };

  try {
    log('Creating Csound...');
    const cs = await Csound({ useWorker: false, useSPN: false, outputChannelCount: 2 });
    
    log('Compiling...');
    await cs.compileOrc(`
      sr = 48000
      ksmps = 32
      nchnls = 2
      0dbfs = 1
      
      instr 1
        aSig = oscili:a(0.3, 440)
        out aSig, aSig
      endin
    `);
    
    log('Setting option...');
    await cs.setOption('-odac');
    
    log('Getting audio context...');
    const ctx = await cs.getAudioContext();
    log('Context: ' + (ctx ? ctx.state : 'NULL'));
    
    if (ctx && ctx.state === 'suspended') {
      await ctx.resume();
      log('Resumed: ' + ctx.state);
    }
    
    log('Starting...');
    await cs.start();
    
    log('Playing note...');
    await cs.inputMessage('i 1 0 3');
    
    log('DONE - you should hear 440 Hz tone!');
  } catch (e) {
    log('ERROR: ' + e.message);
  }
});
</script>
</body>
</html>
```

Open in browser, click START. If you hear tone → csound works, problem is in main app. If no tone → csound7-lib is broken.

---

## DIAGNOSTICS

**Current state:**
- ✅ Csound loads
- ✅ Orchestra compiles
- ✅ Instruments start (10, 90, 501-504 all allocated)
- ✅ Channels initialize
- ❌ Audio context is NULL
- ❌ "setting dummy interface" → silent output

**The code is 99% correct!** Just need audio context to connect.

---

## NUCLEAR OPTION: Use Csound 6 + Cabbage

If Csound 7 Web Audio won't work:

1. Export CSD files from the app
2. Use local Csound 6.18 CLI with `-odac`
3. Build Cabbage plugin instead
4. Demo with local audio instead of web

**You have the orchestra - it compiles perfectly. Just need audio routing to work!**

---

## KEY FINDING

Your working `weather_sonification_v2.html` likely has:
- Different version of `@csound/browser`
- OR different import path
- OR different initialization code

**In Florida**: Compare the EXACT import line in weather_sonification_v2.html vs photo_multi_engine_complete.html!

---

**Safe flight! Try Option 1 (CDN) first when you land! 🌴✈️**

The code is perfect - just need the audio context to exist!
