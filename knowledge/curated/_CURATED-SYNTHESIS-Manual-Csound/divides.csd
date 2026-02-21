<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

idiv  = 1/p3 * p4
ktrm  oscil 1, idiv, 1						;use oscil as an envelope
printf "retrigger rate per note duration = %f\n",1, idiv
kndx  line 5, p3, 1						;vary index of FM
asig  foscil ktrm, 200, 1, 1.4, kndx, 1
      outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1  0 4096 10   1    ;sine wave

i 1 0 3	10   
i 1 4 3 15  	
i 1 8 3 2 

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
