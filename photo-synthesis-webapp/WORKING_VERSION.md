# Photo Synthesis — working version (9 Nov 2026)

This is the version that sounds good. It runs in the browser on local Csound 7 (`csound7-lib/csound.js`, `@csound/browser` 7.0.0). Open the pages over `http://localhost:8080/`, not as files.

```bash
python3 -m http.server 8080
```

A copy of the five instrument pages and the shared scripts is in `backups/2026-11-09/`.

## The five instruments

Each page scans a photo or the camera, and can load a folder of photos. The scan, the keyboard, the chords, and the bass have their own mix faders. MIDI uses the Launchkey MIDI Out port, not the DAW port.

| Page | Voice |
| --- | --- |
| `photo_fm_web_v3a_fm.html` | FM |
| `photo_fm_web_v3b_granular.html` | Grains |
| `photo_fm_web_v3c_additive.html` | Additive partials |
| `photo_fm_web_v3d_percussive.html` | Pitched mallets |
| `photo_fm_web_v3e_waveguide.html` | Plucked strings |

Chords and bass use that same voice. They are not a shared bowed pad.

## Harmony and the keyboard

Chords and the walking bass move on the chord-rate clock (about 3 to 7 seconds). A fast melody does not build a new chord on every key.

While you play, the next chord leans toward the scale degree you have actually settled on. Passing notes leave the harmony where it is. A held three-note grip can lead, from its lowest note. If the line is scattered, the picture keeps choosing the progression. The Root control stays the key. Key mode “retune the drone” is the control that moves the root with the keyboard.

The bass still walks, with passing tones on some chords, and each step decays instead of holding like a bow. While keys are down, the chord thins and sits back so the solo stays clear.

## What comes next

Not in this save:

1. Keyboard tunings beyond 12-tone: Bohlen–Pierce, Wendy Carlos Alpha / Beta / Gamma, Harry Partch, and Stockhausen Studie II.
2. More models as 3f, 3g, 3h, 3i, 3j: textural and noise percussion, pitched grains against noise-band grains, resonant noise, and the other synthesis models still missing (modal, vector, subtractive, physical models).
3. Three images at once. Each image gets its own scan and its own model, so the counterpoint is three different voices, with one shared chord and bass ensemble.

GitHub has this tree on the branch `photo-synthesis` in `mateolarreaferro/Dr.C`. `main` is not pushed from this machine because an older commit contains a 606 MB audio file that GitHub rejects.
