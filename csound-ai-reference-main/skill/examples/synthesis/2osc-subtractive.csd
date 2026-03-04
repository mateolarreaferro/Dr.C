; ============================================================
; 2osc-subtractive.csd
; Two-oscillator subtractive synthesizer
; Features:
;   - 2x VCO2 sawtooth oscillators with detune spread
;   - zdf_2pole lowpass filter
;   - transegr envelopes: linear attack, -4.2 curve decay/release
;   - Key tracking: filter cutoff follows pitch
;   - Velocity tracking: harder hits open the filter
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
; UDO: TwoOscVoice — dual detuned sawtooth oscillators
; iFreq     = base pitch in Hz
; iAmp      = linear amplitude
; iDetuneCt = detune spread in cents (each osc offset ±half)
; Returns mixed mono audio signal
; ============================================================
opcode TwoOscVoice(iFreq, iAmp, iDetuneCt):a
  ; Split detune: osc1 flat, osc2 sharp by half the spread
  iHalfCents = iDetuneCt * 0.5
  iFreq1     = iFreq * semitone(-iHalfCents / 100)
  iFreq2     = iFreq * semitone( iHalfCents / 100)

  ; Anti-aliased sawtooth waves (mode 0)
  aOsc1 = vco2(iAmp, iFreq1, 0)
  aOsc2 = vco2(iAmp, iFreq2, 0)

  ; Equal-power mix (scale by 0.5 to avoid clipping)
  aOut = (aOsc1 + aOsc2) * 0.5

  xout aOut
endop

; ============================================================
; UDO: FilteredVoice — zdf_2pole LPF with envelope input
; aSig        = audio input
; kCutoffBase = base cutoff (Hz) after key + velocity tracking
; kFilterEnv  = 0..1 filter envelope signal
; iEnvAmt     = Hz range the filter envelope sweeps
; kRes        = filter resonance / Q (0..1 typical)
; Returns filtered audio
; ============================================================
opcode FilteredVoice(aSig, kCutoffBase, kFilterEnv, iEnvAmt, kRes):a
  ; Apply envelope sweep on top of base cutoff
  kCutoff = kCutoffBase + kFilterEnv * iEnvAmt

  ; Clamp to safe range: 20 Hz – 20 kHz
  kCutoff = limit(kCutoff, 20, 20000)

  ; zdf_2pole returns LP, BP, HP — use LP output
  aLP  zdf_2pole  aSig, kCutoff, kRes

  xout aLP
endop

; ============================================================
; Instrument: TwoOscSynth
; p4 = MIDI note number
; p5 = velocity (0–127)
; p6 = detune spread in cents (default 8)
; p7 = filter env amount Hz (default 3000)
; p8 = resonance Q (default 0.3)
; ============================================================
instr TwoOscSynth
  iMidi    = p4
  iVel     = p5
  iDetune  = (p6 == 0) ? 8    : p6
  iEnvAmt  = (p7 == 0) ? 3000 : p7
  iRes     = (p8 == 0) ? 0.3  : p8

  iFreq    = cpsmidinn(iMidi)
  iAmpLin  = (iVel / 127) * ampdbfs(-8)

  ; --------------------------------------------------------
  ; Key tracking
  ; Cutoff tracks pitch relative to C4 (261.63 Hz).
  ; iKeyTrack = 1.0: full 1:1 tracking (cutoff doubles per octave)
  ; iKeyTrack = 0.5: half tracking
  ; --------------------------------------------------------
  iKeyTrack   = 0.75
  iBaseCutoff = 600                               ; cutoff at C4 before velocity
  iKeyCutoff  = iBaseCutoff * pow(iFreq / 261.63, iKeyTrack)

  ; --------------------------------------------------------
  ; Velocity tracking
  ; Adds up to iVelRange Hz at maximum velocity (127)
  ; --------------------------------------------------------
  iVelRange   = 2000
  iVelCutoff  = iVelRange * (iVel / 127)

  ; Combined base cutoff (key + velocity, static per note)
  iCutoffBase = iKeyCutoff + iVelCutoff

  ; --------------------------------------------------------
  ; Envelopes (transegr: linear attack, -4.2 curve elsewhere)
  ; --------------------------------------------------------
  ; Amplitude envelope: attack → peak → decay → sustain | release
  ; Segments: 0→1 linear, 1→0.65 curve -4.2, sustain→0 curve -4.2 (release)
  kAmpEnv = transegr(0, 0.008, 0, 1, 0.15, -4.2, 0.65, 0.35, -4.2, 0)

  ; Filter envelope: fast sweep up, curved decay, release to zero
  ; Segments: 0→1 linear, 1→0.3 curve -4.2, 0.3→0 curve -4.2 (release)
  kFiltEnv = transegr(0, 0.005, 0, 1, 0.25, -4.2, 0.3, 0.4, -4.2, 0)

  ; --------------------------------------------------------
  ; Audio path
  ; --------------------------------------------------------
  ; Dual detuned oscillators
  aRaw = TwoOscVoice(iFreq, iAmpLin, iDetune)

  ; ZDF 2-pole lowpass filter
  aFilt = FilteredVoice(aRaw, iCutoffBase, kFiltEnv, iEnvAmt, iRes)

  ; Apply amplitude envelope
  aOut = aFilt * kAmpEnv

  out(aOut, aOut)
endin

</CsInstruments>
<CsScore>
; i instrName       start  dur  midiNote  vel  detuneCt  envAmt  res
i "TwoOscSynth"   0       0.8    60   90    8        3000    0.3
i "TwoOscSynth"   1.0     0.8    64   80    8        3000    0.3
i "TwoOscSynth"   2.0     0.8    67   85    8        3000    0.3
i "TwoOscSynth"   3.0     2.0    60   110   8        3000    0.3

; High notes — key tracking opens the filter
i "TwoOscSynth"   6.0     0.8    72   90    8        3000    0.3
i "TwoOscSynth"   7.0     0.8    79   90    8        3000    0.3
i "TwoOscSynth"   8.0     0.8    84   90    8        3000    0.3

; Velocity sweep — harder hits open the filter
i "TwoOscSynth"  10.0     0.8    60   40    8        3000    0.3
i "TwoOscSynth"  11.0     0.8    60   70    8        3000    0.3
i "TwoOscSynth"  12.0     0.8    60  100    8        3000    0.3
i "TwoOscSynth"  13.0     0.8    60  127    8        3000    0.3

; Chord with resonance
i "TwoOscSynth"  15.0     3.0    48   100   10       4000    0.6
i "TwoOscSynth"  15.0     3.0    55   90    10       4000    0.6
i "TwoOscSynth"  15.0     3.0    60   85    10       4000    0.6

e
</CsScore>
</CsoundSynthesizer>
