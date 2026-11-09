const fs = require('fs');
const html = fs.readFileSync('photo_multi_engine_complete.html', 'utf8');

console.log('=== MUSICAL FEATURES CHECK ===\n');

const musicalFeatures = {
  'BPM Clock': {
    'BPM state variable': /let currentBPM = 120/.test(html),
    'BPM update function': /function updateBPM\(/.test(html),
    'Tap tempo': /function handleTapTempo\(/.test(html),
    'Beat tick function': /function beatTick\(/.test(html),
  },
  'Phrase Mode': {
    'phraseEnabled state': /phraseEnabled:\s*false/.test(html),
    'phrasePlayBeats state': /phrasePlayBeats:\s*4/.test(html),
    'phraseRestBeats state': /phraseRestBeats:\s*2/.test(html),
    'phraseGate state': /phraseGate:\s*1/.test(html),
  },
  'ADSR Envelopes': {
    'attack state': /attack:\s*0\.01/.test(html),
    'decay state': /decay:\s*0\.2/.test(html),
    'sustain state': /sustain:\s*0\.7/.test(html),
    'release state': /release:\s*0\.5/.test(html),
    'ADSR channel sends': /setControlChannel.*attack/.test(html),
  },
  'Scale Quantization': {
    'scales object': /const scales = {/.test(html),
    'quantizeToScale function': /function quantizeToScale\(/.test(html),
    'currentScale state': /let currentScale = 'chromatic'/.test(html),
  },
  'Scan Modes': {
    'line mode': /scanMode === 'line'/.test(html),
    'manual mode': /scanMode === 'manual'/.test(html),
    'random mode': /scanMode === 'random'/.test(html),
    'manualX state': /manualX:\s*0\.5/.test(html),
    'manualY state': /manualY:\s*0\.5/.test(html),
  },
  'Polyphonic Controls': {
    'scanSpeed state': /scanSpeed:\s*1\.0/.test(html),
    'phaseOffset state': /phaseOffset:\s*0\.0/.test(html),
    'clone function': /function cloneImageAll\(/.test(html),
    '2-voice preset': /function applyPreset2Voice\(/.test(html),
    '4-voice preset': /function applyPreset4Voice\(/.test(html),
    'canon preset': /function applyPresetCanon\(/.test(html),
  }
};

let totalTests = 0;
let passedTests = 0;

for (const [category, tests] of Object.entries(musicalFeatures)) {
  console.log(`\n${category}:`);
  for (const [test, result] of Object.entries(tests)) {
    totalTests++;
    if (result) {
      passedTests++;
      console.log(`  ✓ ${test}`);
    } else {
      console.log(`  ✗ ${test}`);
    }
  }
}

console.log(`\n=== SUMMARY ===`);
console.log(`Tests passed: ${passedTests}/${totalTests}`);
console.log(`Success rate: ${(passedTests/totalTests*100).toFixed(1)}%`);

if (passedTests === totalTests) {
  console.log('\n✅ ALL MUSICAL FEATURES VERIFIED');
} else {
  console.log(`\n⚠️  ${totalTests - passedTests} features missing or not found`);
}
