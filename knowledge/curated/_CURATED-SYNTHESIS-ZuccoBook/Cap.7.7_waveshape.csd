<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.7.7_waveshape

nchnls = 1

gidist ftgen 0,0,257,9,.5,1,270,1.5,.33,90, \
 2.5,.2,270,3.5,.143,90,4.5,.111,270 

instr 1

a1 pluck 10000,220,440,0,1
adist table a1,gidist,1
out adist*10000

endin
</CsInstruments>
<CsScore>
i1 0 22
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
