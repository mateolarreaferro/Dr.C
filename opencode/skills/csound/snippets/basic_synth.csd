<Cabbage>
form caption("Basic Synth") size(620, 400), colour(30, 30, 30), pluginId("bsyn")

groupbox bounds(5, 5, 300, 190), text("Oscillator"), colour(40, 40, 40) {
  rslider bounds(10, 30, 80, 80), channel("waveform"), range(0, 3, 0, 1, 1), text("Wave")
  rslider bounds(100, 30, 80, 80), channel("pulseWidth"), range(0.01, 0.99, 0.5, 1, 0.01), text("PW")
  rslider bounds(190, 30, 80, 80), channel("detune"), range(-50, 50, 0, 1, 1), text("Detune")
}

groupbox bounds(310, 5, 300, 190), text("Filter"), colour(40, 40, 40) {
  rslider bounds(10, 30, 80, 80), channel("cutoff"), range(20, 20000, 5000, 0.5, 1), text("Cutoff")
  rslider bounds(100, 30, 80, 80), channel("resonance"), range(0, 0.95, 0.3, 1, 0.01), text("Reso")
  rslider bounds(190, 30, 80, 80), channel("filterEnv"), range(0, 1, 0.5, 1, 0.01), text("Env")
}

groupbox bounds(5, 200, 300, 90), text("Envelope"), colour(40, 40, 40) {
  rslider bounds(10, 25, 60, 60), channel("attack"), range(0.001, 2, 0.01, 0.5, 0.001), text("A")
  rslider bounds(80, 25, 60, 60), channel("decay"), range(0.001, 2, 0.3, 0.5, 0.001), text("D")
  rslider bounds(150, 25, 60, 60), channel("sustain"), range(0, 1, 0.7, 1, 0.01), text("S")
  rslider bounds(220, 25, 60, 60), channel("release"), range(0.01, 5, 0.5, 0.5, 0.01), text("R")
}

rslider bounds(320, 210, 80, 80), channel("volume"), range(0, 1, 0.7, 1, 0.01), text("Volume")

keyboard bounds(0, 300, 620, 100)
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

instr 1
  ; Read channels with smoothing
  kWaveform chnget "waveform"
  kPulseWidth chnget "pulseWidth"
  kPulseWidth port kPulseWidth, 0.01
  kDetune chnget "detune"
  kDetune port kDetune, 0.01
  kCutoff chnget "cutoff"
  kCutoff port kCutoff, 0.01
  kResonance chnget "resonance"
  kResonance port kResonance, 0.01
  kFilterEnv chnget "filterEnv"
  kFilterEnv port kFilterEnv, 0.01
  kAttack chnget "attack"
  kDecay chnget "decay"
  kSustain chnget "sustain"
  kRelease chnget "release"
  kVolume chnget "volume"
  kVolume port kVolume, 0.01

  ; Velocity and frequency from MIDI
  iFreq = p4
  iAmp = p5

  ; Amplitude envelope
  aEnv madsr i(kAttack), i(kDecay), i(kSustain), i(kRelease)

  ; Oscillator (select waveform)
  iMode = i(kWaveform) * 2  ; 0=saw, 2=square, 4=tri
  aOsc vco2 iAmp, iFreq, iMode, i(kPulseWidth)

  ; Detuned second oscillator
  aOsc2 vco2 iAmp * 0.5, iFreq * cent(i(kDetune)), iMode, i(kPulseWidth)
  aMix = aOsc + aOsc2

  ; Filter with envelope modulation
  kFilterFreq = kCutoff + (kFilterEnv * aEnv * kCutoff)
  kFilterFreq limit kFilterFreq, 20, 20000
  aFilt moogladder aMix, kFilterFreq, kResonance

  ; Apply envelope and volume
  aOut = aFilt * aEnv * kVolume
  aOut limit aOut, -1, 1

  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
f0 z
</CsScore>
</CsoundSynthesizer>
