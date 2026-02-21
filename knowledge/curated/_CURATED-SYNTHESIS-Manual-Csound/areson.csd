<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs = 1

instr 1	; unfiltered noise

asig rand 0.5		; white noise signal.
     outs asig, asig
endin

instr 2 ; filtered noise

kcf  init 1000
kbw  init 100
asig rand 0.5
afil areson asig, kcf, kbw
afil balance afil,asig 	; afil = very loud
     outs afil, afil
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
