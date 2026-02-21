<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1	 
                                        
kcps  init cpspch(p4) 
asig1 vco2 0.5, kcps ; SOUND

kfreq1 linseg p5, p3, p6 ; frequency filter 1
kfreq2 expseg p6, p3, p5 ; frequency filter 2
idecay = p7 ; keep it very small

afilter1 gtf asig1, kfreq1, idecay ; SOUND - filter 1
afilter2 gtf asig1, kfreq2, idecay ; SOUND - filter 2

aref oscili 0.25, 440 ; AMPLITUDE reference
afilter1 balance afilter1, aref ; compare filtered SOUND with reference
afilter2 balance afilter2, aref ; ; compare filtered SOUND with reference

outs afilter1, afilter2

endin

</CsInstruments>


<CsScore>

;i 1 0 5 6.00 200 12000 0.1
i 1 0 5 6.00 200 12000 0.01		


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
