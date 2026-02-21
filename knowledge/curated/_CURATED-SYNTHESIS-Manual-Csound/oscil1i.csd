<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr     1   

ipanfn = p4
asig   vco2 .3, 220
kpan   oscil1i 0, 1, p3, ipanfn	;create panning &
kleft  = sqrt(kpan)		;start right away
kright = sqrt(1-kpan)     
       outs kleft*asig, kright*asig

endin
</CsInstruments>
<CsScore>                                                                                  
f 1 0  3 -7 .5  3  .5		;remain in center (.5 CONSTANT)                                                                          
f 2 0 129 7  1 129 0 		;left-->right                                                                                                     
f 3 0 129 7 .5  32 1 64 0 33 .5 ;center-->left-->right-->center    

i 1  0  2  1			;use table 1
i 1  3  2  2			;use table 2
i 1  6  2  3			;use table 3

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
