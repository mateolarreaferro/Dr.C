<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

idur    = p3
ifreq   = p4
iamp    = p5 
iharms  = (sr*.4) / ifreq
asig    gbuzz .3, ifreq, iharms, 1, .9, 1           ; Sawtooth-like waveform
kfreq   linseg 1, idur * 0.5, 5000, idur * 0.5, 1   ; Envelope to control filter cutoff
afilt   lowpass2 asig,kfreq, 30
kenv    linseg 0, .1, iamp, idur -.2, iamp, .1, 0   ; Simple amplitude envelope
outs    afilt * kenv, afilt * kenv

endin

</CsInstruments>
<CsScore>
f1 0 8192 9 1 1 .25
;       frq     amp
i1 0 5  100     .15
i1 5 5  200     .12
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
