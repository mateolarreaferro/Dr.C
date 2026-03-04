; ============================================================
; effects-chain.csd
; Demonstrates: channel buses, reverb, delay, saturation, EQ
; All effects as UDOs using Csound 7 new-style syntax
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
; UDO: StereoReverb — wet/dry reverb with room control
; ============================================================
opcode StereoReverb(aDryL, aDryR, kRoom, kWetMix):(a,a)
  ; Clamp room size to safe range
  kSafeRoom = (kRoom > 0.97) ? 0.97 : kRoom

  aWetL, aWetR reverbsc aDryL, aDryR, kSafeRoom, 7500

  aOutL = ntrpol(aDryL, aWetL, kWetMix)
  aOutR = ntrpol(aDryR, aWetR, kWetMix)

  xout aOutL, aOutR
endop

; ============================================================
; UDO: TapeDelay — tempo-synced delay with feedback and saturation
; ============================================================
opcode TapeDelay(aSigL, aSigR, kBPM, kFeedback, iSubdiv):(a,a)
  ; Convert BPM to delay time in ms
  kDelayMs = (60000 / kBPM) / iSubdiv
  iMaxMs   = 3000

  ; Ping-pong: delay L→R, R→L at half time
  aDelL = vdelay(aSigL + aSigR * kFeedback, kDelayMs, iMaxMs)
  aDelR = vdelay(aSigR + aSigL * kFeedback, kDelayMs * 0.5, iMaxMs)

  ; Light saturation on feedback path (tape character)
  aDelL = distort1(aDelL, 1.2, 0.7, 0, 0)
  aDelR = distort1(aDelR, 1.2, 0.7, 0, 0)

  aOutL = aSigL + aDelL * 0.5
  aOutR = aSigR + aDelR * 0.5

  xout aOutL, aOutR
endop

; ============================================================
; UDO: Saturator — soft harmonic saturation (drive + mix)
; ============================================================
opcode Saturator(aSigL, aSigR, kDrive, kMix):(a,a)
  ; Gain staging before clipping
  aDrivenL = aSigL * kDrive
  aDrivenR = aSigR * kDrive

  aSatL = distort1(aDrivenL, 1, 0.5, 0, 0)
  aSatR = distort1(aDrivenR, 1, 0.5, 0, 0)

  ; Compensate gain and blend
  aCompL = aSatL / kDrive
  aCompR = aSatR / kDrive

  aOutL = ntrpol(aSigL, aCompL, kMix)
  aOutR = ntrpol(aSigR, aCompR, kMix)

  xout aOutL, aOutR
endop

; ============================================================
; UDO: SimpleEQ — 3-band shelf + presence boost
; ============================================================
opcode SimpleEQ(aSigL, aSigR, kLowGain, kMidCut, kHighGain):(a,a)
  ; Low shelf ~120Hz
  aLowL = butlp(aSigL, 120)
  aLowR = butlp(aSigR, 120)
  aHiL  = buthp(aSigL, 120)
  aHiR  = buthp(aSigR, 120)

  ; Recombine with gain
  aMixL = aLowL * kLowGain + aHiL
  aMixR = aLowR * kLowGain + aHiR

  ; Mid cut (boxcar bandpass, inverted)
  aMidL = butbp(aMixL, 400, 200)
  aMidR = butbp(aMixR, 400, 200)
  aMixL = aMixL - aMidL * (1 - kMidCut)
  aMixR = aMixR - aMidR * (1 - kMidCut)

  ; High shelf presence boost ~4kHz
  aPresL = buthp(aMixL, 4000)
  aPresR = buthp(aMixR, 4000)
  aLo2L  = butlp(aMixL, 4000)
  aLo2R  = butlp(aMixR, 4000)
  aOutL  = aLo2L + aPresL * kHighGain
  aOutR  = aLo2R + aPresR * kHighGain

  xout aOutL, aOutR
endop

; ============================================================
; PadVoice: Source sound (simple pad) — writes to channel bus
; ============================================================
instr PadVoice
  iFreq = cpsmidinn(p4)
  iAmp  = ampdbfs(-12)

  kEnv = madsr(0.3, 0.1, 0.8, 0.8)

  ; Slightly detuned pair for width
  aSaw1  = vco2(iAmp * 0.5, iFreq, 0)
  aSaw2  = vco2(iAmp * 0.5, iFreq * 1.008, 0)
  aLeft  = aSaw1 * kEnv
  aRight = aSaw2 * kEnv

  chnmix(aLeft,  "synth_L")
  chnmix(aRight, "synth_R")
endin

; ============================================================
; Master: Effects bus (always on, runs last)
; p4 = BPM for delay sync
; ============================================================
instr Master
  iBPM = (p4 == 0) ? 120 : p4

  ; Read from synth bus
  aDryL = chnget:a("synth_L")
  aDryR = chnget:a("synth_R")

  ; 1. Saturation (subtle warmth)
  aSatL, aSatR Saturator(aDryL, aDryR, 1.8, 0.3)

  ; 2. 3-Band EQ (boost lows, slight mid scoop, presence)
  aEQL, aEQR SimpleEQ(aSatL, aSatR, 1.2, 0.85, 1.15)

  ; 3. Tempo-synced ping-pong delay (8th notes)
  aDelL, aDelR TapeDelay(aEQL, aEQR, iBPM, 0.4, 2)

  ; 4. Reverb
  aRevL, aRevR StereoReverb(aDelL, aDelR, 0.82, 0.35)

  ; Output with slight limiting (soft clip the master)
  aOutL = distort1(aRevL, 1, 0.95, 0, 0)
  aOutR = distort1(aRevR, 1, 0.95, 0, 0)

  out(aOutL, aOutR)

  ; Clear buses each k-period
  chnclear("synth_L")
  chnclear("synth_R")
endin

</CsInstruments>
<CsScore>
; Start master bus (always on)
; p4 = BPM
i "Master"  0  30  120

; Pad notes
i "PadVoice"   0   4    60
i "PadVoice"   0   4    64
i "PadVoice"   0   4    67

i "PadVoice"   5   4    62
i "PadVoice"   5   4    65
i "PadVoice"   5   4    69

i "PadVoice"  10   4    60
i "PadVoice"  10   4    65
i "PadVoice"  10   4    72

e
</CsScore>
</CsoundSynthesizer>
