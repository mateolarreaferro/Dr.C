<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	; white noise

asig rand 0.6
     outs asig, asig

endin

instr 2	;filtered noise

asig rand 0.7
; Highpass filter signal asig with a 6-pole Chebyshev
; Type I at 20 Hz with 3 dB of passband ripple.
a1 clfilt asig, 20, 1, 6, 1, 3
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
