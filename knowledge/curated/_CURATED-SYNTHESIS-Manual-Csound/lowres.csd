<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kres = p4
asig vco .2, 220, 1		;sawtooth

kcut line 1000, p3, 10		;note: kcut is not in Hz
as   lowres asig, kcut, kres	;note: kres is not in dB
aout balance as, asig		;avoid very loud sounds
     outs aout, aout

endin
</CsInstruments>
<CsScore>
; a sine
f 1 0 16384 10 1

i 1 0 4 3
i 1 + 4 30
i 1 + 4 60
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
