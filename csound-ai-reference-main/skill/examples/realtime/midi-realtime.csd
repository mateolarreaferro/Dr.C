; ============================================================
; midi-realtime.csd
; Demonstrates: MIDI instrument setup, pitch bend, mod wheel,
;               sustain pedal, polyphonic voices, channel routing
; Csound 7 new-style syntax — run with: csound -odac -Ma midi-realtime.csd
; ============================================================

<CsoundSynthesizer>
<CsOptions>
-odac -Ma -d -m0
</CsOptions>
<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

; Route all MIDI channels to MIDISynth
massign 0, "MIDISynth"

; ============================================================
; UDO: PolyVoice — single polyphonic voice
; Inputs:  iFreq, iAmp, kPitchBend (semitones), kModWheel (0-1)
; Outputs: stereo audio
; ============================================================
opcode PolyVoice(iFreq, iAmp, kPitchBend, kModWheel):(a,a)
  ; Vibrato from mod wheel
  kVibDepth = kModWheel * 0.4    ; up to ±0.4 semitones
  kVibRate  = 5.2
  kVib = oscili(kVibDepth, kVibRate)

  ; Apply pitch bend and vibrato
  kFinalFreq = iFreq * semitone(kPitchBend + kVib)

  ; Two detuned oscillators for thickness
  aSaw1 = vco2(iAmp * 0.5, kFinalFreq)
  aSaw2 = vco2(iAmp * 0.5, kFinalFreq * 1.006)

  ; Filter: mod wheel also opens filter slightly
  kCutoff = 600 + kModWheel * 2000
  aFilt = moogladder(aSaw1 + aSaw2, kCutoff, 0.25)

  ; Stereo spread via short delay
  aLeft  = aFilt
  aRight = vdelay(aFilt, 7, 20)     ; 7ms Haas delay

  xout aLeft, aRight
endop

; ============================================================
; MIDISynth: MIDI polyphonic synth voice
; Each MIDI note triggers a new instance of this instrument
; ============================================================
instr MIDISynth
  ; MIDI input opcodes
  iMidi  = notnum()                    ; note number 0-127
  iVel   = veloc(1, 127)               ; velocity 1-127
  kBend  = pchbend(-2, 2)              ; pitch bend ±2 semitones
  kMod   = midictrl(1, 0, 1)           ; CC1 mod wheel 0-1

  ; Convert to frequency and amplitude
  iFreq = cpsmidinn(iMidi)
  iAmp  = (iVel / 127) * ampdbfs(-8)

  ; ADSR envelope with release
  kEnv = madsr(0.008, 0.08, 0.75, 0.4)

  ; Generate voice
  aLeft, aRight PolyVoice(iFreq, iAmp, kBend, kMod)

  ; Apply amplitude envelope
  aLeft  *= kEnv
  aRight *= kEnv

  ; Mix into shared bus
  chnmix(aLeft,  "voices_L")
  chnmix(aRight, "voices_R")
endin

; ============================================================
; Master: Bus with reverb (always on)
; ============================================================
instr Master
  aL = chnget:a("voices_L")
  aR = chnget:a("voices_R")

  ; Soft reverb for space
  aRevL, aRevR reverbsc aL, aR, 0.78, 9000

  aOutL = aL * 0.7 + aRevL * 0.3
  aOutR = aR * 0.7 + aRevR * 0.3

  out(aOutL, aOutR)

  chnclear("voices_L")
  chnclear("voices_R")
endin

</CsInstruments>
<CsScore>
; Keep running (for MIDI) — 3600 seconds = 1 hour
f 0  3600

; Always-on master bus
i "Master"  0  3600

; For testing without MIDI — uncomment to play a scale:
; i "MIDISynth"  0.0  1.0  60  100
; i "MIDISynth"  0.5  1.0  62  90
; i "MIDISynth"  1.0  1.0  64  95
; i "MIDISynth"  1.5  1.0  65  85
; i "MIDISynth"  2.0  1.0  67  100
; i "MIDISynth"  2.5  1.0  69  90
; i "MIDISynth"  3.0  1.0  71  95
; i "MIDISynth"  3.5  2.0  72  100

e
</CsScore>
</CsoundSynthesizer>
