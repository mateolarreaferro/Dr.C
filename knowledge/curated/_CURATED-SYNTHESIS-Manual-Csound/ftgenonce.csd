<CsoundSynthesizer> 
<CsOptions>
</CsOptions>
<CsInstruments> 

0dbfs  = 1

instr 1 
; Use ftgenonce instead of ftgen, ftgentmp, or f statement
iHz	= p4
isine	ftgenonce 0, 0, 1024, 10, 1 
aoscili	pluck .7, iHz, 100, isine, 1 
aadsr 	adsr 0.015, 0.07, 0.6, 0.3
asig 	= aoscili * aadsr
        outs asig, asig
endin 

</CsInstruments> 
<CsScore> 

i 1 0 1 220 
i 1 2 1 261 
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
