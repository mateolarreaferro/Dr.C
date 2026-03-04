; ============================================================
; basic-subtractive.csd
; Demonstrates: vco2, moogladder, madsr, linsegr, UDO, MIDI-to-Hz
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
; UDO: MonoSub — single-oscillator subtractive voice
; ============================================================
opcode MonoSub(iFreq, iAmp, kFilterEnv):a
  ; Anti-aliased sawtooth oscillator
  aSaw = vco2(iAmp, iFreq, 0)

  ; Filter cutoff driven by envelope (200 Hz to 4 kHz range)
  kCutoff = 200 + kFilterEnv * 3800

  ; Moog ladder filter with moderate resonance
  aOut = moogladder(aSaw, kCutoff, 0.35)

  xout aOut
endop

; ============================================================
; UDO: StereoWidth — mono-to-stereo via Haas-style delay
; ============================================================
opcode StereoWidth(aSig, kWidth):(a,a)
  ; Small delay on one channel creates stereo spread
  kDelayMs = kWidth * 12   ; 0-12ms spread
  aDel = vdelay(aSig, kDelayMs, 20)

  xout aSig, aDel
endop

; ============================================================
; SubSynth: Subtractive synth voice
; p4 = MIDI note number
; p5 = velocity (0-127)
; p6 = filter env amount (0-1, optional, default 0.7)
; ============================================================
instr SubSynth
  iMidi   = p4
  iVel    = p5
  iEnvAmt = (p6 == 0) ? 0.7 : p6

  iFreq = cpsmidinn(iMidi)
  iAmp  = (iVel / 127) * ampdbfs(-6)

  ; Amplitude envelope (ADSR)
  kAmpEnv = madsr(0.008, 0.12, 0.65, 0.35)

  ; Filter envelope (faster attack than amp)
  kFiltEnv = linsegr(0, 0.004, 1, 0.2, 0.3, 0.4, 0)

  ; Scale filter env by amount parameter
  kFilterDrive = kFiltEnv * iEnvAmt

  ; Synthesize voice
  aMono = MonoSub(iFreq, iAmp, kFilterDrive)

  ; Apply amplitude envelope
  aMono *= kAmpEnv

  ; Stereo spread
  aLeft, aRight StereoWidth(aMono, 0.5)

  out(aLeft, aRight)
endin

</CsInstruments>
<CsScore>
; i instrName    start  dur  midiNote  velocity  filterEnvAmt
i "SubSynth"   0       0.8    60   100       0.8
i "SubSynth"   1.0     0.8    64   90        0.7
i "SubSynth"   2.0     0.8    67   95        0.9
i "SubSynth"   3.0     2.0    60   110       1.0

; Chord
i "SubSynth"   6.0     3.0    60   100       0.8
i "SubSynth"   6.0     3.0    64   90        0.6
i "SubSynth"   6.0     3.0    67   85        0.5

e
</CsScore>
</CsoundSynthesizer>
