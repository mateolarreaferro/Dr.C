<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

gisin ftgen 1, 0, 32768, 10, 1
gienv ftgen 2, 0, 1025, 27, 0, 0,200, 1, 400, -1, 513, 0
  
instr 1

kcps init 3/p3			;play 3x over duration of note
kndx phasor kcps
ixmode = 1			;normalize to 0-1
kval table kndx, gienv, ixmode
kval = kval*100			;scale 0-100
asig poscil 1, 220+kval, 1	;add to 220 Hz
     outs asig, asig
  
endin
</CsInstruments>
<CsScore>

i 1 0 4

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
