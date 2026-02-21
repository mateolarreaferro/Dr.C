<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kres = p4
inumlayer = 4

kenv linseg 0, p3*.1, 1, p3*.8, 1, p3*.1, 0 	;envelope
asig vco .3 * kenv, 220, 1			;sawtooth
kcut line 30, p3, 1000				;note: kcut is not in Hz
alx  lowresx asig, kcut, kres, inumlayer	;note: kres is not in dB
aout balance alx, asig				;avoid very loud sounds
     outs aout, aout

endin
</CsInstruments>
<CsScore>
;sine wave
f 1 0 16384 10 1

i 1 0 5 1
i 1 + 5 3
i 1 + 5 20
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
