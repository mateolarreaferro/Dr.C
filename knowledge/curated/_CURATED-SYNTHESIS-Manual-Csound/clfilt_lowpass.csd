<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	; white noise

asig rand 0.5
outs asig, asig

endin

instr 2	; filtered noise 

asig rand 0.9
; Lowpass filter signal asig with a 
; 10-pole Butterworth at 500 Hz.
a1 clfilt asig, 500, 0, 10
   outs a1, a1

endin

</CsInstruments>
<CsScore>

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
