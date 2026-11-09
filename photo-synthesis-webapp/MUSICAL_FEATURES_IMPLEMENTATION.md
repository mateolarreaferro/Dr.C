# Musical Features Implementation Plan

**Status:** IN PROGRESS  
**Features:** BPM Clock, Phrase Mode, ADSR Envelopes, Scale Quantization, Manual Scan, Random Scan

---

## Implementation Checklist

### ✅ Phase 1: UI Components (COMPLETE)
- [x] BPM slider + tap tempo button
- [x] Beat indicator (4 lights)
- [x] Scale selector (13 scales)
- [x] Root note selector
- [x] Scan mode buttons (Line/Mouse/Random) per slot
- [x] Phrase mode enable checkbox per slot
- [x] Phrase play/rest sliders per slot
- [x] ADSR sliders per slot (4 params)
- [x] CSS styling for all new controls

**UI Added:** ~400 lines (HTML + CSS)

---

## Phase 2: State Management (NEXT)

### Global State to Add:
```javascript
// BPM Clock
let bpm = 120;
let beatInterval = 0;  // ms per beat
let lastBeatTime = 0;
let beatCount = 0;     // 0-3 (for 4/4 time)
let tapTimes = [];

// Scale Quantization
let currentScale = 'chromatic';
let rootNote = 0;  // 0-11 (C=0, C#=1, etc.)
const SCALES = {
  'chromatic': [0,1,2,3,4,5,6,7,8,9,10,11],
  'major': [0,2,4,5,7,9,11],
  'minor': [0,2,3,5,7,8,10],
  // ... all 13 scales
};
```

### Per-Slot State to Add:
```javascript
{
  // Scan Mode
  scanMode: 'line',  // 'line' | 'manual' | 'random'
  manualX: 0.5,      // 0-1
  manualY: 0.5,      // 0-1
  randomJumpRate: 4, // beats between jumps
  randomLastJump: 0, // beat count
  
  // Phrase Mode
  phraseEnabled: false,
  phrasePlayBeats: 4,
  phraseRestBeats: 2,
  phraseState: 'playing',  // 'playing' | 'resting'
  phraseBeatCount: 0,
  phraseGate: 1,  // 0 or 1 (amplitude multiplier)
  
  // ADSR
  attack: 0.01,   // seconds
  decay: 0.2,     // seconds
  sustain: 0.7,   // 0-1
  release: 0.5,   // seconds
}
```

---

## Phase 3: BPM Clock System

### Functions to Implement:
1. **updateBPM(bpm)** - Calculate beat interval, update UI
2. **beatTick()** - Called every frame, advances beat count
3. **updateBeatIndicator()** - Visual metronome lights
4. **handleTapTempo()** - Calculate BPM from tap times
5. **beatsToMs(beats)** - Convert beats to milliseconds
6. **msToBeats(ms)** - Convert milliseconds to beats

### Integration Points:
- Replace all folder timing "seconds" with optional "beats" mode
- Phrase mode timing is beat-based
- Random scan jump rate is beat-based

---

## Phase 4: Phrase Mode Logic

### Functions to Implement:
1. **updatePhraseState(slot)** - Called every beat, transitions play/rest
2. **getPhraseGate(slot)** - Returns 0 (rest) or 1 (play)
3. **resetPhrase(slot)** - Reset to start of phrase cycle

### Phrase State Machine:
```
PLAYING (beatCount 0-3) → REST (beatCount 4-5) → PLAYING (0-3) → ...
```

### Amplitude Gating:
- When `phraseState === 'resting'` → multiply all Csound channel values by 0
- When `phraseState === 'playing'` → normal operation
- Smooth transitions via ADSR release/attack

---

## Phase 5: ADSR Envelopes

### Csound Integration:
Need to modify ALL instrument opcodes to accept ADSR params:

```csound
opcode FmVoice, aa, Skkkkkkkkkk
  SPrefix, kFreq, kRatio, kIndex, kCut, kRes, kAmp, kAtk, kDec, kSus, kRel xin
  
  kEnv = madsr:k(kAtk, kDec, kSus, kRel)
  kAmp = kAmp * kEnv
  
  ; ... rest of synthesis
endop
```

### Required Changes:
- Update all 5 engine opcodes (FmVoice, GranVoice, AddVoice, PercVoice, WGuideVoice)
- Add 4 new channel reads per slot (attack, decay, sustain, release)
- Apply envelope to amplitude

**Note:** For phrase mode, use simple gating instead of full ADSR on phrase transitions (ADSR already handles note articulation)

---

## Phase 6: Scale Quantization

### Frequency Quantization Function:
```javascript
function quantizeToScale(freqHz) {
  if (currentScale === 'chromatic') return freqHz;
  
  // Convert Hz → MIDI note
  let midi = 69 + 12 * Math.log2(freqHz / 440);
  
  // Quantize to scale
  const scaleNotes = SCALES[currentScale];
  const octave = Math.floor(midi / 12);
  const semitone = Math.round(midi % 12);
  
  // Find closest scale degree
  let closest = scaleNotes.reduce((prev, curr) => {
    return Math.abs(curr - semitone) < Math.abs(prev - semitone) ? curr : prev;
  });
  
  // Apply root note offset
  closest = (closest + rootNote) % 12;
  
  // Convert back to Hz
  const quantizedMidi = octave * 12 + closest;
  return 440 * Math.pow(2, (quantizedMidi - 69) / 12);
}
```

### Integration:
- Apply to all frequency parameters before sending to Csound
- `setControlChannel(freq)` becomes `setControlChannel(quantizeToScale(freq))`
- Per-slot enable/disable option (add checkbox)

---

## Phase 7: Manual Scan Mode (Mouse)

### Mouse Tracking:
```javascript
zone.addEventListener('mousemove', e => {
  if (slots[slot].scanMode !== 'manual') return;
  
  const rect = zone.getBoundingClientRect();
  slots[slot].manualX = (e.clientX - rect.left) / rect.width;
  slots[slot].manualY = (e.clientY - rect.top) / rect.height;
});
```

### Analysis Update:
```javascript
function analyzeLine(slot) {
  const s = slots[slot];
  if (!s.pixels) return defaultFeatures;
  
  let x, y;
  
  if (s.scanMode === 'line') {
    x = Math.floor(s.pos * s.W);
    y = 0;  // scan full height
  } else if (s.scanMode === 'manual') {
    x = Math.floor(s.manualX * s.W);
    y = Math.floor(s.manualY * s.H);
  } else if (s.scanMode === 'random') {
    // ... random logic
  }
  
  // ... rest of analysis
}
```

---

## Phase 8: Random Scan Mode

### Random Jump Logic:
```javascript
function updateRandomScan(slot) {
  const s = slots[slot];
  if (s.scanMode !== 'random') return;
  
  // Jump every N beats
  if (beatCount - s.randomLastJump >= s.randomJumpRate) {
    s.manualX = Math.random();
    s.manualY = Math.random();
    s.randomLastJump = beatCount;
  }
}
```

### Integration:
- Called in `beatTick()` function
- Respects BPM timing
- Adjustable jump rate (1-16 beats)

---

## Estimated Code Addition

| Component | Lines |
|-----------|-------|
| UI (HTML/CSS) | ~400 ✅ |
| State Management | ~100 |
| BPM Clock | ~150 |
| Phrase Mode | ~100 |
| ADSR Integration | ~200 (Csound orchestra changes) |
| Scale Quantization | ~150 |
| Manual Scan | ~50 |
| Random Scan | ~50 |
| Event Listeners | ~200 |
| **TOTAL** | **~1400 lines** |

---

## Testing Checklist

### BPM Clock
- [ ] BPM slider changes tempo
- [ ] Tap tempo works (3+ taps)
- [ ] Beat indicator flashes on beat
- [ ] Beat 1 highlighted differently

### Phrase Mode
- [ ] Enable checkbox shows/hides params
- [ ] Play beats slider works (1-16)
- [ ] Rest beats slider works (0-8)
- [ ] Sound gates off during rest
- [ ] Sound plays during play
- [ ] Transitions smooth (ADSR)

### ADSR
- [ ] Attack slider shapes note start
- [ ] Decay slider shapes note body
- [ ] Sustain slider sets hold level
- [ ] Release slider shapes note end
- [ ] Works with phrase mode gating

### Scale Quantization
- [ ] Scale selector changes quantization
- [ ] Root note selector works
- [ ] Frequencies snap to scale
- [ ] Chromatic disables quantization
- [ ] All 13 scales work

### Manual Scan
- [ ] Mouse button activates mode
- [ ] Hovering scans image
- [ ] X/Y position tracked
- [ ] Features update in real-time

### Random Scan
- [ ] Random button activates mode
- [ ] Jumps occur at beat intervals
- [ ] Jump rate adjustable
- [ ] Full 2D coverage

---

## Implementation Order (Recommended)

1. ✅ **UI Components** (Complete)
2. **State Management** (Add all new properties)
3. **BPM Clock** (Foundation for all timing)
4. **Scan Modes** (Manual + Random)
5. **ADSR** (Envelope shaping)
6. **Phrase Mode** (Uses BPM + ADSR)
7. **Scale Quantization** (Final polish)

---

## Next Steps

Given the scope (~1400 lines), I recommend implementing in phases:

**Option A:** Implement all features now (~30-45 minutes of work)
**Option B:** Implement BPM + Scan Modes first, test, then do Phrase/ADSR/Scale in next session
**Option C:** Just implement one feature (e.g., BPM Clock + Phrase Mode) to test the approach

Which would you prefer? I'm ready to proceed with full implementation if you'd like!
