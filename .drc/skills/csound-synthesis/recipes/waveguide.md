# Waveguide / Physical Modeling Recipes

## How Waveguides Work

A waveguide simulates a vibrating string or air column using a delay line with filtering. An excitation signal (noise burst, impulse) enters the delay loop and circulates, losing energy through the loop filter on each pass. The delay length sets the pitch.

## Plucked String

```csound
instr PluckedString
  iFreq = p4
  iAmp = p5

  ; wgpluck2: icps, iamp, ifn, iplk, idamp, ifilt, iAx, iy
  ; iplk = pluck position (0-1, 0.5=center=mellow, near 0 or 1=bright)
  ; idamp = damping factor (30-500, higher=brighter decay)
  ; ifilt = filter coefficient (0-1, lower=darker)
  aOut wgpluck2 iFreq, iAmp, giSine, 0.4, 120, 0.5, 0, 0

  ; Alternative: repluck for more control
  ; aExcite noise 1, 0
  ; aExcite = aExcite * expseg(1, 0.002, 0.001)
  ; aOut repluck iplk, iAmp, iFreq, 0.4, 0.95

  outs aOut, aOut
endin
```

Parameters to tweak:
- **Pluck position** (iplk 0.1-0.9): 0.5 = round/mellow, near 0 or 1 = thin/bright/nasal
- **Damping** (30-500): low = muted/nylon, high = bright/steel
- **Filter**: lower = darker (nylon guitar), higher = brighter (steel string)

Variations:
- **Nylon guitar**: iplk=0.4, low damping (40-80), low filter (0.3)
- **Steel guitar**: iplk=0.3, high damping (200-400), high filter (0.7)
- **Banjo**: iplk=0.15 (near bridge), very high damping, high filter
- **Harp**: iplk=0.5, medium damping, medium filter, longer decay

## Bowed String

```csound
instr BowedString
  iFreq = p4
  iAmp = p5

  ; wgbow: kamp, kfreq, kpres, krat, kvibf, kvibamp, ifn
  ; kpres = bow pressure (1-10, affects brightness/noise)
  ; krat = bow position (0.01-1, affects timbre)
  kPres = 3.5
  kRat = 0.13  ; near bridge = brighter
  kVibF = 5.5  ; vibrato frequency
  kVibA = 0.005 * iFreq  ; vibrato depth

  ; Pressure envelope for natural bowing
  kPres linseg 1, 0.1, 3.5, p3-0.2, 3, 0.1, 0

  aOut wgbow iAmp, iFreq, kPres, kRat, kVibF, kVibA, giSine
  outs aOut, aOut
endin
```

Parameters:
- **Bow pressure** (1-10): low = airy/harmonic-rich, high = scratchy/forceful
- **Bow position** (0.01-1): near 0 = sul ponticello (bright), near 1 = sul tasto (mellow)
- **Vibrato**: rate 5-6 Hz, depth 0.3-1% of frequency

## Flute

```csound
instr Flute
  iFreq = p4
  iAmp = p5

  ; wgflute: kamp, kfreq, kjet, iatt, idetk, kngain, kvibf, kvibamp, ifn
  ; kjet = jet delay (0.001-0.5, affects overblowing)
  ; kngain = noise gain (0-1, breath noise)
  kJet = 0.1
  kNoise = 0.15  ; subtle breath noise
  kVibF = 5
  kVibA = 0.01 * iFreq

  ; Breath envelope
  kAmp linsegr 0, 0.08, iAmp, p3-0.18, iAmp*0.95, 0.1, 0

  aOut wgflute kAmp, iFreq, kJet, 0.05, 0.05, kNoise, kVibF, kVibA, giSine
  outs aOut, aOut
endin
```

## Clarinet

```csound
instr Clarinet
  iFreq = p4
  iAmp = p5

  ; wgclar: kamp, kfreq, kstiff, iatt, idetk, kngain, kvibf, kvibamp, ifn
  kStiff = -0.3  ; reed stiffness (-1 to 0)
  kNoise = 0.1
  kVibF = 5
  kVibA = 0.008 * iFreq

  kAmp linsegr 0, 0.06, iAmp, p3-0.16, iAmp, 0.1, 0
  aOut wgclar kAmp, iFreq, kStiff, 0.05, 0.05, kNoise, kVibF, kVibA, giSine
  outs aOut, aOut
endin
```

## Custom Waveguide (Delay Line)

For sounds not covered by built-in opcodes, build from primitives:

```csound
instr CustomWaveguide
  iFreq = p4
  iAmp = p5
  iDelayTime = 1/iFreq  ; delay = 1/frequency

  ; Excitation: filtered noise burst
  aNoise noise 1, 0
  aExcite = aNoise * expseg(1, 0.003, 0.001, p3-0.003, 0.0001)

  ; Delay loop with filtering
  aLoop init 0
  aInput = aExcite + aLoop * 0.996  ; feedback < 1 for decay
  aDelay delayr iDelayTime + 0.001  ; max delay
    aTap deltapi iDelayTime          ; tap at pitch frequency
  delayw aInput
  aLoop tone aTap, iFreq * 3        ; loop filter (controls brightness decay)

  aOut = aTap * iAmp
  outs aOut, aOut
endin
```

## Drums with Mode Synthesis

Use `mode` opcode to create resonant modes excited by noise:

```csound
instr ModalDrum
  iAmp = p5

  ; Excitation: short noise burst
  aNoise noise 1, 0
  aExcite = aNoise * expseg(1, 0.005, 0.001, p3-0.005, 0.0001)

  ; Multiple resonant modes at drum frequencies
  aMode1 mode aExcite, 180, 80   ; fundamental
  aMode2 mode aExcite, 280, 60   ; second mode
  aMode3 mode aExcite, 420, 40   ; third mode
  aMode4 mode aExcite, 590, 25   ; fourth mode

  aOut = (aMode1 * 0.5 + aMode2 * 0.3 + aMode3 * 0.15 + aMode4 * 0.05) * iAmp
  aOut limit aOut, -1, 1
  outs aOut, aOut
endin
```

Tuning guide:
- **Kick drum**: fundamental 50-80 Hz, 2-3 modes
- **Snare**: fundamental 150-250 Hz, 4-6 modes + noise component
- **Tom**: fundamental 80-300 Hz (varies by size), 3-4 modes
- **Cymbal**: many closely spaced modes (200-8000 Hz), long decay
