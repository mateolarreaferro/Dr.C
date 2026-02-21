<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs = 1

gamix init 0 

instr 1 

acps    expon p4, p3, p5
asig	vco  0.6, acps, 1
	outs  asig, asig 

gamix = gamix + asig 

endin

instr 99 

arvt1 line 3.5*1.5, p3, 6
arvt2 line 3.5, p3, 4
ilpt =  0.1
aleft	alpass gamix, arvt1, ilpt
aright	alpass gamix, arvt2, ilpt*2
	outs   aleft, aright

gamix = 0	; clear mixer
 
endin

</CsInstruments>
<CsScore>
f1 0 4096 10 1
i 1 0 3 20 2000

i 99 0 8
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
