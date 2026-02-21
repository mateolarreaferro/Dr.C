<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

iroot = 440		; root note is A above middle-C (440 Hz)
koct  lfo 5, 1, 5	; generate sawtooth, go from 5 octaves higher to root
koc = int(koct)		; produce only whole numbers
kfactor = octave(koc)	; for octave
knew = iroot * kfactor
printk2 knew

asig pluck 1, knew, 1000, 0, 1 
asig dcblock asig	;remove DC
     outs asig, asig

endin
</CsInstruments>
<CsScore>

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
