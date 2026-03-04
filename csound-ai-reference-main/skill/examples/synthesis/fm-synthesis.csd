; ============================================================
; fm-synthesis.csd
; Demonstrates: 2-op and 3-op FM, index envelopes, ratio control
; Csound 7 new-style syntax
; ============================================================

<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

; ============================================================
; UDO: FM2Op — two-operator FM synthesis
;
; FM equation: carrier = A * sin(2π * fc * t + I * sin(2π * fm * t))
; where I = modulation index, fc = carrier freq, fm = modulator freq
; ============================================================
opcode FM2Op(iCarrFreq, iModRatio, iAmp, kIndex):a
  iModFreq = iCarrFreq * iModRatio

  ; Modulator amplitude scales with modulator frequency * index
  ; (this maintains perceived brightness across pitches)
  kModAmp = iModFreq * kIndex

  aMod = oscili(kModAmp, iModFreq)
  aOut = oscili(iAmp, iCarrFreq + aMod)

  xout aOut
endop

; ============================================================
; UDO: FM3Op — three-operator FM (modulator chain: M2 → M1 → Carrier)
; ============================================================
opcode FM3Op(iCarrFreq, iMod1Ratio, iMod2Ratio, iAmp, kIdx1, kIdx2):a
  iMod1Freq = iCarrFreq * iMod1Ratio
  iMod2Freq = iCarrFreq * iMod2Ratio

  kMod2Amp = iMod2Freq * kIdx2
  kMod1Amp = iMod1Freq * kIdx1

  aMod2 = oscili(kMod2Amp, iMod2Freq)
  aMod1 = oscili(kMod1Amp, iMod1Freq + aMod2)
  aOut  = oscili(iAmp, iCarrFreq + aMod1)

  xout aOut
endop

; ============================================================
; FMPluck: Bright FM pluck (2-op, high index → decaying)
; p4 = MIDI note, p5 = velocity
; ============================================================
instr FMPluck
  iFreq = cpsmidinn(p4)
  iAmp  = (p5 / 127) * ampdbfs(-8)

  ; Index starts high (bright/metallic) and decays quickly
  kIndex = expsegr(8, 0.05, 4, 0.2, 1.5, 0.15, 0.1)

  ; Amplitude envelope
  kAmp = linsegr(0, 0.002, 1, p3 * 0.6, 0.5, 0.15, 0)

  ; Integer ratio 1:2 = harmonic (octave mod), bright and bell-like
  aSig = FM2Op(iFreq, 2, iAmp, kIndex)
  aOut = aSig * kAmp

  out(aOut, aOut)
endin

; ============================================================
; EPiano: Electric piano (2-op, ratio 1:1, gentle index)
; p4 = MIDI note, p5 = velocity
; ============================================================
instr EPiano
  iFreq = cpsmidinn(p4)
  iAmp  = (p5 / 127) * ampdbfs(-10)

  ; Index decays from moderate to near zero (classic DX EP behavior)
  kIndex = expsegr(3, 0.02, 2, p3 * 0.5, 0.3, 0.3, 0.01)

  kAmp = linsegr(0, 0.003, 1, p3 * 0.7, 0.2, 0.3, 0)

  ; Ratio 1:1 = FM with self — creates even harmonics
  aSig = FM2Op(iFreq, 1, iAmp, kIndex)
  aOut = aSig * kAmp

  out(aOut, aOut)
endin

; ============================================================
; Bell: Bell (3-op, inharmonic ratios)
; p4 = MIDI note
; ============================================================
instr Bell
  iFreq = cpsmidinn(p4)
  iAmp  = ampdbfs(-10)

  ; 3-op with inharmonic modulator ratios → metallic bell timbre
  kIdx1 = expsegr(5, 0.01, 3, p3 * 0.5, 0.5, 0.5, 0.01)
  kIdx2 = expsegr(2, 0.05, 1, p3 * 0.7, 0.3, 0.3, 0.01)

  kAmp = linsegr(0, 0.005, 1, p3 * 0.8, 0.1, 0.5, 0)

  ; Ratios 1.4 and 2.8 are inharmonic (bell/metallic character)
  aSig = FM3Op(iFreq, 1.4, 2.8, iAmp, kIdx1, kIdx2)
  aOut = aSig * kAmp

  ; Light reverb for bells
  aRevL, aRevR reverbsc aOut, aOut, 0.88, 6000
  aMixL = aOut * 0.5 + aRevL * 0.5
  aMixR = aOut * 0.5 + aRevR * 0.5

  out(aMixL, aMixR)
endin

</CsInstruments>
<CsScore>
; Pluck melody
i "FMPluck"  0.0   1.2   69   100
i "FMPluck"  0.5   1.0   72   90
i "FMPluck"  1.0   1.5   76   95
i "FMPluck"  2.0   2.5   74   85

; Electric piano chords
i "EPiano"  5.0   3.0   60   80
i "EPiano"  5.0   3.0   64   75
i "EPiano"  5.0   3.0   67   70

i "EPiano"  9.0   3.0   62   80
i "EPiano"  9.0   3.0   65   75
i "EPiano"  9.0   3.0   69   70

; Bell hits
i "Bell"  13.0  4.0   84   100
i "Bell"  13.5  4.0   88   90
i "Bell"  14.0  5.0   91   95

e
</CsScore>
</CsoundSynthesizer>
