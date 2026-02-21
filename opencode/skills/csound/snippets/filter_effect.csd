<Cabbage>
form caption("Filter Effect") size(400, 250), colour(30, 30, 30), pluginId("filt")

groupbox bounds(5, 5, 390, 150), text("Filter"), colour(40, 40, 40) {
  combobox bounds(10, 30, 120, 25), channel("filterType"), text("LowPass", "HighPass", "BandPass", "Notch"), value(1)
  rslider bounds(10, 60, 80, 80), channel("cutoff"), range(20, 20000, 1000, 0.5, 1), text("Cutoff")
  rslider bounds(100, 60, 80, 80), channel("resonance"), range(0.1, 30, 1, 0.5, 0.1), text("Q")
  rslider bounds(190, 60, 80, 80), channel("drive"), range(0, 1, 0, 1, 0.01), text("Drive")
  rslider bounds(280, 60, 80, 80), channel("mix"), range(0, 1, 1, 1, 0.01), text("Mix")
}

rslider bounds(160, 170, 80, 70), channel("volume"), range(0, 1, 0.8, 1, 0.01), text("Volume")
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
  kFilterType chnget "filterType"
  kCutoff chnget "cutoff"
  kCutoff port kCutoff, 0.01
  kResonance chnget "resonance"
  kResonance port kResonance, 0.01
  kDrive chnget "drive"
  kDrive port kDrive, 0.01
  kMix chnget "mix"
  kMix port kMix, 0.01
  kVolume chnget "volume"
  kVolume port kVolume, 0.01

  aInL inch 1
  aInR inch 2

  ; Drive stage
  aDriveL = tanh(aInL * (1 + kDrive * 4))
  aDriveR = tanh(aInR * (1 + kDrive * 4))

  ; Filter selection
  if kFilterType == 1 then
    aFiltL zdf_2pole aDriveL, kCutoff, kResonance, 0
    aFiltR zdf_2pole aDriveR, kCutoff, kResonance, 0
  elseif kFilterType == 2 then
    aFiltL zdf_2pole aDriveL, kCutoff, kResonance, 2
    aFiltR zdf_2pole aDriveR, kCutoff, kResonance, 2
  elseif kFilterType == 3 then
    aFiltL zdf_2pole aDriveL, kCutoff, kResonance, 1
    aFiltR zdf_2pole aDriveR, kCutoff, kResonance, 1
  else
    aFiltL butterlp aDriveL, kCutoff
    aFiltR butterlp aDriveR, kCutoff
    ; Notch via subtraction
    aFiltL = aDriveL - aFiltL
    aFiltR = aDriveR - aFiltR
  endif

  aOutL = (aInL * (1 - kMix) + aFiltL * kMix) * kVolume
  aOutR = (aInR * (1 - kMix) + aFiltR * kMix) * kVolume

  aOutL limit aOutL, -1, 1
  aOutR limit aOutR, -1, 1

  outs aOutL, aOutR
endin

</CsInstruments>
<CsScore>
f0 z
</CsScore>
</CsoundSynthesizer>
