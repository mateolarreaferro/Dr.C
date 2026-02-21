<CsoundSynthesizer>
<CsOptions>
</CsOptions>

<CsInstruments>

0dbfs = 1

instr 1

kenvelopemod linseg 0, 2, p4, p3-4, p4, 2, 0

kFreqMod expseg 200, p3, 800
amodulator oscil kenvelopemod, kFreqMod, 2

acarf phasor 440
ifn = 1
ixmode = 1
ixoff = 0
iwrap = 1
acarrier tablei acarf+amodulator, ifn, ixmode, ixoff, iwrap

kgenenvelop linseg 0, 0.5, 0.3, p3-1, 0.3, 0.5, 0
out acarrier * kgenenvelop

endin

</CsInstruments>

<CsScore>

f1 0 4096 10 1
f2 0 4096 10 1 0.3 0.5 0.24 0.56 0.367

i1 0 5 0.2 
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
