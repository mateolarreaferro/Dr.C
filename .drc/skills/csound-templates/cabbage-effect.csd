<Cabbage>
form caption("DrC Effect") size(500, 300), colour(30, 30, 35)
groupbox bounds(10, 10, 235, 130), text("Filter"), colour(40, 40, 48)
rslider channel("cutoff"), bounds(20, 40, 70, 70), range(20, 18000, 4000, 0.35, 1), text("Cutoff"), colour(200, 120, 80)
rslider channel("resonance"), bounds(95, 40, 70, 70), range(0, 0.95, 0.3, 1, 0.01), text("Res"), colour(200, 120, 80)
rslider channel("filterMix"), bounds(170, 40, 70, 70), range(0, 1, 0.5, 1, 0.01), text("Mix"), colour(200, 120, 80)

groupbox bounds(255, 10, 235, 130), text("Reverb"), colour(40, 40, 48)
rslider channel("reverbSize"), bounds(265, 40, 70, 70), range(0.1, 0.99, 0.8, 1, 0.01), text("Size"), colour(80, 120, 200)
rslider channel("reverbDamp"), bounds(340, 40, 70, 70), range(500, 16000, 8000, 0.5, 1), text("Damp"), colour(80, 120, 200)
rslider channel("reverbMix"), bounds(415, 40, 70, 70), range(0, 1, 0.25, 1, 0.01), text("Mix"), colour(80, 120, 200)

groupbox bounds(10, 150, 480, 130), text("Delay"), colour(40, 40, 48)
rslider channel("delayTime"), bounds(20, 175, 70, 70), range(0.01, 1, 0.3, 0.5, 0.01), text("Time"), colour(120, 200, 80)
rslider channel("delayFeedback"), bounds(95, 175, 70, 70), range(0, 0.9, 0.4, 1, 0.01), text("Fback"), colour(120, 200, 80)
rslider channel("delayHighCut"), bounds(170, 175, 70, 70), range(500, 16000, 8000, 0.5, 1), text("Tone"), colour(120, 200, 80)
rslider channel("delayMix"), bounds(245, 175, 70, 70), range(0, 1, 0.3, 1, 0.01), text("Mix"), colour(120, 200, 80)
rslider channel("masterVol"), bounds(370, 175, 70, 70), range(0, 2, 1, 1, 0.01), text("Volume"), colour(180, 180, 180)
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
  ; --- Read input ---
  aInL inch 1
  aInR inch 2

  ; --- Read and smooth all parameters ---
  kCutoff chnget "cutoff"
  kCutoff port kCutoff, 0.01
  kRes chnget "resonance"
  kRes port kRes, 0.02
  kFilterMix chnget "filterMix"
  kFilterMix port kFilterMix, 0.02

  kRevSize chnget "reverbSize"
  kRevSize port kRevSize, 0.05
  kRevDamp chnget "reverbDamp"
  kRevDamp port kRevDamp, 0.02
  kRevMix chnget "reverbMix"
  kRevMix port kRevMix, 0.02

  kDelTime chnget "delayTime"
  kDelTime port kDelTime, 0.05
  kDelFB chnget "delayFeedback"
  kDelFB port kDelFB, 0.02
  kDelHC chnget "delayHighCut"
  kDelHC port kDelHC, 0.02
  kDelMix chnget "delayMix"
  kDelMix port kDelMix, 0.02

  kVol chnget "masterVol"
  kVol port kVol, 0.02

  ; --- Filter ---
  aFiltL moogladder aInL, kCutoff, kRes
  aFiltR moogladder aInR, kCutoff, kRes
  aL = aInL * (1 - kFilterMix) + aFiltL * kFilterMix
  aR = aInR * (1 - kFilterMix) + aFiltR * kFilterMix

  ; --- Delay ---
  aDelFbL init 0
  aDelFbR init 0

  aReadL delayr 2.0
    aTapL deltapi kDelTime
  delayw aL + aDelFbL * kDelFB
  aDelFbL tone aTapL, kDelHC

  aReadR delayr 2.0
    aTapR deltapi kDelTime * 0.75
  delayw aR + aDelFbR * kDelFB
  aDelFbR tone aTapR, kDelHC

  aL = aL * (1 - kDelMix) + aDelFbL * kDelMix
  aR = aR * (1 - kDelMix) + aDelFbR * kDelMix

  ; --- Reverb ---
  aWetL, aWetR reverbsc aL, aR, kRevSize, kRevDamp
  aL = aL * (1 - kRevMix) + aWetL * kRevMix
  aR = aR * (1 - kRevMix) + aWetR * kRevMix

  ; --- Output ---
  aL = aL * kVol
  aR = aR * kVol
  aL limit aL, -1, 1
  aR limit aR, -1, 1
  outs aL, aR
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
