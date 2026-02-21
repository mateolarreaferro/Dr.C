<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
 
0dbfs  = 1 

instr 1

kenv linseg 0,0.1,1, p3-0.2,1, 0.1, 0		;declick envelope	
asig buzz .6*kenv, 100, 100, 1
kf   expseg 100, p3/2, 5000, p3/2, 1000		;envelope for filter cutoff
ahp,alp,abp,abr statevar asig, kf, 4
     outs alp,ahp				; lowpass left, highpass right
	
endin	
</CsInstruments>
<CsScore>
f 1 0 16384 10 1	;sine wave

i1 0 5 
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
