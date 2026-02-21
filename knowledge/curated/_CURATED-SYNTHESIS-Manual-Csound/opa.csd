<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	;sine wave at k-rate

ksig	oscil 0.8, 440, 1
; k-rate to the audio-rate conversion
asig =  a(ksig)
	outs asig, asig

endin

instr 2	;sine wave at a-rate

asig	oscil 0.8, 440, 1
	outs  asig, asig

endin

</CsInstruments>
<CsScore>
; sine wave.
f 1 0 16384 10 1

i 1 0 2
i 2 2 2
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
