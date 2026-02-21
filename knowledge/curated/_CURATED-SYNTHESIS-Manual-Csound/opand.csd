<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kval    randomh 0, 1.2, 20		;choose between 0 and 1.2
if kval >0 && kval<=.5 then		;3 possible outcomes
	kval = 1			
elseif kval >.5 && kval<=1 then
	kval =2
elseif kval >1 then
	kval =3
endif

printk2 kval				;print value when it changes
asig    poscil .7, 440*kval, 1
        outs asig, asig

endin
</CsInstruments>
<CsScore>
f1 0 16384 10 1

i 1 0 5
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
