<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.3_glissando

0dbfs = 1

instr	1

kamp	linseg	0,p3/2,.5,p3/2,0 
kfreq	linseg	220,p3/2,440,p3/2,220
a1	oscili	kamp,kfreq,1 

out	a1

endin

</CsInstruments>
<CsScore>

f1	0	16384	10	1	1

i1	0	8

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
