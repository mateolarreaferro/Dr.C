<Cabbage>
form caption("DrC Synth") size(620, 400), colour(30, 30, 35)
groupbox bounds(10, 10, 295, 180), text("Oscillator"), colour(40, 40, 48)
rslider channel("waveform"), bounds(20, 40, 80, 80), range(0, 3, 0, 1, 1), text("Wave"), colour(80, 120, 200)
rslider channel("detune"), bounds(110, 40, 80, 80), range(0, 0.02, 0.003, 0.5, 0.001), text("Detune"), colour(80, 120, 200)
rslider channel("subLevel"), bounds(200, 40, 80, 80), range(0, 1, 0.3, 1, 0.01), text("Sub"), colour(80, 120, 200)

groupbox bounds(315, 10, 295, 180), text("Filter"), colour(40, 40, 48)
rslider channel("cutoff"), bounds(325, 40, 80, 80), range(20, 18000, 3000, 0.35, 1), text("Cutoff"), colour(200, 120, 80)
rslider channel("resonance"), bounds(415, 40, 80, 80), range(0, 0.95, 0.3, 1, 0.01), text("Res"), colour(200, 120, 80)
rslider channel("filtEnv"), bounds(505, 40, 80, 80), range(0, 8000, 2000, 0.5, 1), text("Env"), colour(200, 120, 80)

groupbox bounds(10, 200, 295, 100), text("Amp Envelope"), colour(40, 40, 48)
rslider channel("attack"), bounds(20, 225, 60, 60), range(0.001, 2, 0.05, 0.4, 0.001), text("A"), colour(120, 200, 80)
rslider channel("decay"), bounds(85, 225, 60, 60), range(0.01, 2, 0.2, 0.4, 0.01), text("D"), colour(120, 200, 80)
rslider channel("sustain"), bounds(150, 225, 60, 60), range(0, 1, 0.7, 1, 0.01), text("S"), colour(120, 200, 80)
rslider channel("release"), bounds(215, 225, 60, 60), range(0.01, 4, 0.3, 0.4, 0.01), text("R"), colour(120, 200, 80)

groupbox bounds(315, 200, 295, 100), text("Master"), colour(40, 40, 48)
rslider channel("volume"), bounds(325, 225, 60, 60), range(0, 1, 0.7, 1, 0.01), text("Vol"), colour(180, 180, 180)
rslider channel("reverbMix"), bounds(395, 225, 60, 60), range(0, 1, 0.2, 1, 0.01), text("Reverb"), colour(180, 180, 180)

keyboard bounds(10, 310, 600, 80)
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 8192, 10, 1

; --- Reverb always-on instrument ---
instr 100
  aInL chnget "reverbSendL"
  aInR chnget "reverbSendR"
  kMix chnget "reverbMix"
  kMix port kMix, 0.02

  aWetL, aWetR reverbsc aInL, aInR, 0.85, 10000
  aOutL = aInL * (1 - kMix) + aWetL * kMix
  aOutR = aInR * (1 - kMix) + aWetR * kMix
  outs aOutL, aOutR

  ; Clear the bus
  chnset 0, "reverbSendL"
  chnset 0, "reverbSendR"
endin

; --- Synth voice ---
instr 1
  iFreq = p4
  iAmp = p5

  ; Read and smooth widget values
  kWave chnget "waveform"
  kDetune chnget "detune"
  kDetune port kDetune, 0.02
  kSubLevel chnget "subLevel"
  kSubLevel port kSubLevel, 0.02
  kCutoff chnget "cutoff"
  kCutoff port kCutoff, 0.01
  kRes chnget "resonance"
  kRes port kRes, 0.02
  kFiltEnvDepth chnget "filtEnv"
  kFiltEnvDepth port kFiltEnvDepth, 0.02
  kAtt chnget "attack"
  kDec chnget "decay"
  kSus chnget "sustain"
  kRel chnget "release"
  kVol chnget "volume"
  kVol port kVol, 0.02

  ; Oscillators — two detuned voices + sub
  iWave = i(kWave)
  aOsc1 vco2 0.5, iFreq * (1 - kDetune), iWave * 2
  aOsc2 vco2 0.5, iFreq * (1 + kDetune), iWave * 2
  aSub vco2 kSubLevel, iFreq * 0.5, 2  ; square sub

  aMix = aOsc1 + aOsc2 + aSub

  ; Filter with envelope
  kAmpEnv madsr i(kAtt), i(kDec), i(kSus), i(kRel)
  kFiltEnv madsr i(kAtt)*0.5, i(kDec)*0.8, i(kSus)*0.6, i(kRel)*0.3
  kCutoffFinal = kCutoff + (kFiltEnv * kFiltEnvDepth)
  kCutoffFinal limit kCutoffFinal, 20, 18000

  aFilt moogladder aMix, kCutoffFinal, kRes

  ; Output
  aOut = aFilt * kAmpEnv * iAmp * kVol
  aOut limit aOut, -1, 1

  ; Send to reverb bus
  aOldL chnget "reverbSendL"
  aOldR chnget "reverbSendR"
  chnset aOldL + aOut, "reverbSendL"
  chnset aOldR + aOut, "reverbSendR"
endin

</CsInstruments>
<CsScore>
; Start reverb instrument
i 100 0 3600
</CsScore>
</CsoundSynthesizer>
