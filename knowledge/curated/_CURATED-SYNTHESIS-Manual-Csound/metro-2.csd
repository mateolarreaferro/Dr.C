<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kpch    random   1,20		;produce values at k-rate
ktrig   metro    10		;trigger 10 times per second
kval	samphold kpch, ktrig 	;change value whenever ktrig = 1 
asig	buzz	 1, 220, kval, 1;harmonics
        outs     asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 4096 10 1	; sine

i 1 0 10
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
