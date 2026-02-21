<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr	1

kcount init 440
ktrig  metro 10
kcount = kcount + ktrig
String sprintfk "frequency in Hertz : %d \n", kcount
       puts	String, kcount
       asig poscil .7, kcount, 1
       outs asig, asig
	
endin
</CsInstruments>
<CsScore>
f1 0 16384 10 1

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
