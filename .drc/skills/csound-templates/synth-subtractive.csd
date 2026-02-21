<CsoundSynthesizer>
<CsOptions>
-d -m0 -W
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

; ============================================================
; Subtractive Synthesizer Template
; Oscillators → Filter → Amplitude Envelope → Output
; ============================================================

; --- Function Tables ---
giSine ftgen 0, 0, 8192, 10, 1

; --- Instrument ---
instr SubSynth
  iFreq = p4                      ; <<< CUSTOMIZE: pitch (Hz or cpsmidinn)
  iAmp = p5                       ; <<< CUSTOMIZE: amplitude (0-1)

  ; --- Oscillators ---
  ; <<< CUSTOMIZE: waveform — mode 0=saw, 2=square, 4=triangle
  iWave = 0
  aOsc1 vco2 0.5, iFreq * 0.998, iWave        ; slightly flat
  aOsc2 vco2 0.5, iFreq * 1.002, iWave        ; slightly sharp
  aMix = aOsc1 + aOsc2

  ; --- Filter ---
  ; <<< CUSTOMIZE: cutoff, resonance, envelope depth
  kCutoffBase = 2000              ; base cutoff frequency (Hz)
  kResonance = 0.3                ; 0-1 (careful above 0.8)
  kFiltEnvDepth = 3000            ; how much the envelope opens the filter

  ; Filter envelope
  kFiltEnv madsr 0.05, 0.3, 0.4, 0.2
  kCutoff = kCutoffBase + (kFiltEnv * kFiltEnvDepth)

  ; <<< CUSTOMIZE: filter type — moogladder, lpf18, zdf_2pole
  aFilt moogladder aMix, kCutoff, kResonance

  ; --- Amplitude Envelope ---
  ; <<< CUSTOMIZE: ADSR times (attack, decay, sustain level, release)
  kAmpEnv madsr 0.1, 0.2, 0.7, 0.3

  ; --- Output ---
  aOut = aFilt * kAmpEnv * iAmp
  aOut limit aOut, -1, 1
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; p1   p2    p3    p4(freq)  p5(amp)
i "SubSynth" 0    2     262       0.5
i "SubSynth" 2.5  2     330       0.5
i "SubSynth" 5    3     392       0.5
e 10
</CsScore>
</CsoundSynthesizer>
