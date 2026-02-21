<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.7.9_distort

gifn ftgen 0,0,257,9,.5,1,270,1.5,.33,90,2.5,.2,270,3.5,.143,90,4.5,.111,270

instr 1

asig pluck 10000,80,220,0,1
awsh distort asig,p4,gifn
anoise rand 100
adeclick  linseg 0,0.02,1,p3-0.05,1,0.02,0,0.01,0
aout = (awsh+anoise)*adeclick
out aout

endin

</CsInstruments>
<CsScore>
i1 0 1 0
i1 2 1 0.2
i1 4 1 0.4
i1 6 1 0.6
i1 8 1 0.8
i1 10 1 1
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
