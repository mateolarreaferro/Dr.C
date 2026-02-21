<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

seed 0
gisine ftgen 0, 0, 2^10, 10, 1

instr 1

ipeak random 0, 1 		;where is the envelope peak
asig  poscil .8, 220, gisine
aenv  transeg 0, p3*ipeak, 6, 1, p3-p3*ipeak, -6, 0
aL,aR pan2 asig*aenv, ipeak	;pan according to random value
      outs aL, aR

endin

</CsInstruments>
<CsScore>
i1 0 5
i1 4 5
i1 8 5
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
