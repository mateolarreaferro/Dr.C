<Cabbage>
form caption("Reverb & Delay") size(400, 300), colour(30, 30, 30), pluginId("rvdl")

groupbox bounds(5, 5, 190, 180), text("Reverb"), colour(40, 40, 40) {
  rslider bounds(10, 30, 80, 80), channel("reverbMix"), range(0, 1, 0.3, 1, 0.01), text("Mix")
  rslider bounds(100, 30, 80, 80), channel("reverbSize"), range(0.1, 0.99, 0.85, 1, 0.01), text("Size")
  rslider bounds(55, 115, 80, 60), channel("reverbDamp"), range(1000, 20000, 10000, 0.5, 1), text("Damp")
}

groupbox bounds(200, 5, 190, 180), text("Delay"), colour(40, 40, 40) {
  rslider bounds(10, 30, 80, 80), channel("delayMix"), range(0, 1, 0.3, 1, 0.01), text("Mix")
  rslider bounds(100, 30, 80, 80), channel("delayTime"), range(0.01, 1, 0.25, 0.5, 0.01), text("Time")
  rslider bounds(55, 115, 80, 60), channel("delayFeedback"), range(0, 0.95, 0.4, 1, 0.01), text("FB")
}

rslider bounds(160, 200, 80, 80), channel("dryWet"), range(0, 1, 0.5, 1, 0.01), text("Dry/Wet")
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  ; Read channels
  kReverbMix chnget "reverbMix"
  kReverbMix port kReverbMix, 0.01
  kReverbSize chnget "reverbSize"
  kReverbSize port kReverbSize, 0.01
  kReverbDamp chnget "reverbDamp"
  kReverbDamp port kReverbDamp, 0.01
  kDelayMix chnget "delayMix"
  kDelayMix port kDelayMix, 0.01
  kDelayTime chnget "delayTime"
  kDelayTime port kDelayTime, 0.05
  kDelayFeedback chnget "delayFeedback"
  kDelayFeedback port kDelayFeedback, 0.01
  kDryWet chnget "dryWet"
  kDryWet port kDryWet, 0.01

  ; Input
  aInL inch 1
  aInR inch 2

  ; Delay effect
  aDelL vdelay aInL + (aDelL * kDelayFeedback), kDelayTime * 1000, 2000
  aDelR vdelay aInR + (aDelR * kDelayFeedback), kDelayTime * 1000 * 1.05, 2000

  ; Mix delay
  aPostDelL = aInL * (1 - kDelayMix) + aDelL * kDelayMix
  aPostDelR = aInR * (1 - kDelayMix) + aDelR * kDelayMix

  ; Reverb
  aRevL, aRevR reverbsc aPostDelL, aPostDelR, kReverbSize, kReverbDamp

  ; Mix reverb
  aWetL = aPostDelL * (1 - kReverbMix) + aRevL * kReverbMix
  aWetR = aPostDelR * (1 - kReverbMix) + aRevR * kReverbMix

  ; Dry/wet mix
  aOutL = aInL * (1 - kDryWet) + aWetL * kDryWet
  aOutR = aInR * (1 - kDryWet) + aWetR * kDryWet

  aOutL limit aOutL, -1, 1
  aOutR limit aOutR, -1, 1

  outs aOutL, aOutR
endin

</CsInstruments>
<CsScore>
f0 z
</CsScore>
</CsoundSynthesizer>
