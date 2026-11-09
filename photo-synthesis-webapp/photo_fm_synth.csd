<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

gaRevL init 0
gaRevR init 0
gaDryL init 0
gaDryR init 0

; reads a control channel, smoothed by its own glide channel "gl_<name>"
opcode Ctl, k, S
  SName xin
  SGlide = strcat("gl_", SName)
  iInit = chnget:i(SName)
  kGlide = chnget:k(SGlide)
  kRaw = chnget:k(SName)
  kOut = portk(kRaw, kGlide, iInit)
  xout kOut
endop

; sustained FM voice driven by the scan line
instr 1
  kFreq  = Ctl("carFreq")
  kRatio = Ctl("ratio")
  kIndex = Ctl("index")
  kCut   = Ctl("cutoff")
  kRes   = Ctl("reso")
  kDet   = Ctl("detune")
  kWobR  = Ctl("wobbleRate")
  kWobD  = Ctl("wobbleDepth")
  kPulR  = Ctl("pulseRate")
  kPulD  = Ctl("pulseDepth")
  kPan   = Ctl("pan")
  kSend  = Ctl("revSend")
  kAmp   = Ctl("amp")
  kGain  = port(chnget:k("masterGain"), 0.05)

  ; index wobble LFO
  kWob   = 1 + kWobD * oscili:k(1, kWobR)
  kModF  = kFreq * kRatio
  aMod   = oscili:a(kIndex * kWob * kModF, kModF)

  ; three detuned carriers share the modulator
  kDetR  = cent(kDet)
  aC1    = oscili:a(0.22, kFreq + aMod)
  aC2    = oscili:a(0.22, (kFreq + aMod) * kDetR)
  aC3    = oscili:a(0.22, (kFreq + aMod) / kDetR)

  kCut   = limit(kCut, 30, 18000)
  kRes   = limit(kRes, 0, 0.95)
  aFilt  = moogladder:a(aC1 + aC2 + aC3, kCut, kRes)

  ; amplitude pulse (tremolo)
  kTrem  = 1 - kPulD * (0.5 + 0.5 * oscili:k(1, kPulR))
  kEnv   = madsr:k(1, 0, 1, 2)
  aSig   = aFilt * kEnv * kAmp * kGain * kTrem

  aL, aR pan2 aSig, kPan
  gaDryL += aL
  gaDryR += aR
  gaRevL += aL * kSend
  gaRevR += aR * kSend
endin

; global reverb + master soft clip
instr 2
  kSize  = Ctl("revSize")
  kSize  = limit(kSize, 0.3, 0.98)
  aRL, aRR reverbsc gaRevL, gaRevR, kSize, 10000
  out(tanh(gaDryL + aRL), tanh(gaDryR + aRR))
  clear gaRevL, gaRevR, gaDryL, gaDryR
endin

; test harness: initial channel values
instr 99
  chnset 220, "carFreq"
  chnset 0.1, "gl_carFreq"
  chnset 1.5, "ratio"
  chnset 0.1, "gl_ratio"
  chnset 4, "index"
  chnset 0.1, "gl_index"
  chnset 2000, "cutoff"
  chnset 0.1, "gl_cutoff"
  chnset 0.3, "reso"
  chnset 0.1, "gl_reso"
  chnset 8, "detune"
  chnset 0.1, "gl_detune"
  chnset 2, "wobbleRate"
  chnset 0.1, "gl_wobbleRate"
  chnset 0.3, "wobbleDepth"
  chnset 0.1, "gl_wobbleDepth"
  chnset 4, "pulseRate"
  chnset 0.1, "gl_pulseRate"
  chnset 0.3, "pulseDepth"
  chnset 0.1, "gl_pulseDepth"
  chnset 0.5, "pan"
  chnset 0.1, "gl_pan"
  chnset 0.4, "revSend"
  chnset 0.1, "gl_revSend"
  chnset 0.85, "revSize"
  chnset 0.1, "gl_revSize"
  chnset 0.6, "amp"
  chnset 0.1, "gl_amp"
  chnset 0.6, "masterGain"
  chnset 0.1, "gl_masterGain"
endin

; test harness: simulated scan-line sweep
instr 98
  kF = linseg:k(110, 7, 880)
  chnset kF, "carFreq"
  kC = expseg:k(300, 3.5, 7000, 3.5, 400)
  chnset kC, "cutoff"
  kP = linseg:k(0, 7, 1)
  chnset kP, "pan"
  kI = linseg:k(1, 3.5, 10, 3.5, 2)
  chnset kI, "index"
  kD = linseg:k(0, 7, 0.6)
  chnset kD, "pulseDepth"
endin
</CsInstruments>
<CsScore>
i 99 0 0.01
i 2 0 10
i 98 0.02 7
i 1 0.05 7
</CsScore>
</CsoundSynthesizer>
