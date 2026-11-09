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

; Test FM engine with ADSR
opcode FmVoice, aa, Skkkkkkkkkk
  SPrefix, kFreq, kRatio, kIndex, kCut, kRes, kAmp, kAtk, kDec, kSus, kRel xin
  
  kEnv = madsr:k(kAtk, kDec, kSus, kRel)
  kModFreq = kFreq * kRatio
  aMod = oscili:a(kIndex * kModFreq, kModFreq)
  aCar = oscili:a(0.3, kFreq + aMod)
  aFilt = moogladder:a(aCar, limit(kCut, 30, 18000), limit(kRes, 0, 0.95))
  aL = aFilt * kAmp * kEnv
  aR = aFilt * kAmp * kEnv
  xout aL, aR
endop

instr 10
  SPrefix = "A_"
  kFreq = chnget:k(strcat(SPrefix, "freq"))
  kRatio = chnget:k(strcat(SPrefix, "ratio"))
  kIndex = chnget:k(strcat(SPrefix, "index"))
  kCut = chnget:k(strcat(SPrefix, "cutoff"))
  kRes = chnget:k(strcat(SPrefix, "res"))
  kAmp = chnget:k(strcat(SPrefix, "amp"))
  kAtk = chnget:k(strcat(SPrefix, "attack"))
  kDec = chnget:k(strcat(SPrefix, "decay"))
  kSus = chnget:k(strcat(SPrefix, "sustain"))
  kRel = chnget:k(strcat(SPrefix, "release"))
  
  aL, aR FmVoice SPrefix, kFreq, kRatio, kIndex, kCut, kRes, kAmp, kAtk, kDec, kSus, kRel
  outs aL, aR
endin

; Master reverb
instr 90
  kSize = chnget:k("revSize")
  kSize = limit(kSize, 0.3, 0.98)
  kGain = chnget:k("masterGain")
  aRL, aRR reverbsc gaRevL, gaRevR, kSize, 10000
  outs aRL * kGain, aRR * kGain
  clear gaRevL, gaRevR
endin
</CsInstruments>
<CsScore>
f 0 3600
</CsScore>
</CsoundSynthesizer>
