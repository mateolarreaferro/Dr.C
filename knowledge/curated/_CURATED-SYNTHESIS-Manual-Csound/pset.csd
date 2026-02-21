<CsoundSynthesizer> 
<CsOptions> 
</CsOptions> 
<CsInstruments> 

0dbfs  = 1 

instr 1 ;this shows an example with non-midi use

pset 1, 0, 1, 220, 0.5 
asig poscil p5, p4, 1 
     outs asig, asig
 
endin 
</CsInstruments> 
<CsScore> 
f 1 0 1024 10 1	;sine wave

i 1 0 1 
i 1 1 1 440 
i 1 2 1 440 0.1 
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
