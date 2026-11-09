const fs = require('fs');
const html = fs.readFileSync('photo_multi_engine_complete.html', 'utf8');

// Extract JavaScript section (module script)
const scriptMatch = html.match(/<script[^>]*>([\s\S]*?)<\/script>/);
if (!scriptMatch) {
  console.log('ERROR: No script section found');
  process.exit(1);
}

const js = scriptMatch[1];

// Check key features are present
const features = {
  'cloneImageAll function': /function cloneImageAll\(\)/.test(js),
  'applyPreset2Voice function': /function applyPreset2Voice\(\)/.test(js),
  'applyPreset4Voice function': /function applyPreset4Voice\(\)/.test(js),
  'applyPresetCanon function': /function applyPresetCanon\(\)/.test(js),
  'scanSpeed state': /scanSpeed:\s*1\.0/.test(js),
  'phaseOffset state': /phaseOffset:\s*0\.0/.test(js),
  'lastLoadedImage variable': /let lastLoadedImage/.test(js),
  'speed multiplier in tick': /s\.pos \+= 0\.002 \* s\.scanSpeed/.test(js),
  'phase offset in loadPixels': /slots\[slot\]\.pos = slots\[slot\]\.phaseOffset/.test(js),
  'scanMode: manual': /scanMode.*manual/.test(js),
};

console.log('=== FEATURE CHECK ===\n');
let allPresent = true;
for (const [feature, present] of Object.entries(features)) {
  const status = present ? '✓' : '✗';
  console.log(`${status} ${feature}`);
  if (!present) allPresent = false;
}

console.log('\n=== FILE STATS ===');
console.log(`Total lines: ${html.split('\n').length}`);
console.log(`JS lines: ${js.split('\n').length}`);

// Count UI elements
const uiCounts = {
  'scanSpeed inputs': (html.match(/id="scanSpeed[ABCD]"/g) || []).length,
  'phaseOffset inputs': (html.match(/id="phaseOffset[ABCD]"/g) || []).length,
  'preset buttons': (html.match(/id="(cloneImageAll|preset2Voice|preset4Voice|presetCanon)"/g) || []).length,
  'scan mode buttons (manual)': (html.match(/data-mode="manual"/g) || []).length,
};

console.log('\n=== UI ELEMENTS ===');
for (const [element, count] of Object.entries(uiCounts)) {
  console.log(`${element}: ${count}`);
}

if (allPresent) {
  console.log('\n✅ ALL FEATURES PRESENT');
} else {
  console.log('\n❌ MISSING FEATURES');
  process.exit(1);
}
