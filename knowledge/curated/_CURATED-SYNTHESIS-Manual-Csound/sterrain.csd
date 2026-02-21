<CsoundSynthesizer>
<CsOptions>
</CsOptions>

<CsInstruments>
0dbfs  = 1

gisine ftgen 0,0,2^12,10,1

instr 1

kdclk   linseg  0, 0.1, 1, p3-0.02, 1, 0.1, 0
kn1 transeg 2,p3/2,-5,0.15,p3/2,5,2

asig sterrain 0.5, 220, 0.5, 0.5, 0.5, 0.5, 0, gisine, gisine, 4, 4, kn1, 1, 1.5, 1.5, 1, 4
asig dcblock asig
out asig*kdclk

endin

</CsInstruments>

<CsScore>

i 1 0 20

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
