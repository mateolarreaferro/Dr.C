<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
0dbfs  = 1 

instr 1

asig   pluck 0.7, 55, 55, 0, 1
kpan   line 0,p3,1 
kleft  = sqrt(1-kpan) 
kright = sqrt(kpan) 
printks "square root of left channel = %f\\n", 1, kleft	;show coarse of sqaure root values
       outs asig*kleft, asig*kright					;where 0.707126 is between 2 speakers

endin 
</CsInstruments>
<CsScore>

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
