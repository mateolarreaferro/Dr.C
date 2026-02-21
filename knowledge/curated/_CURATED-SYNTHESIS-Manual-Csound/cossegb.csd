<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 2^10, 10, 1

instr 1

kcps = cpspch(p4)
kenv cossegb 0, 0.25, 1, 1, 0
asig poscil kenv, kcps, giSine
     outs asig, asig

endin

instr 2	; scaling to duration

kcps = cpspch(p4)
kenv cossegb 0, p3*0.25, 1, p3, 0
asig poscil kenv, kcps, giSine
     outs asig, asig

endin

</CsInstruments>
<CsScore>

i 1 0 1   7.00	; = 1 sec, p3 fits exactly
i 1 2 2   7.00	; = 2 sec, p3 truncated at 1 sec

i 2 4 1   7.00	; scales to duration
i 2 6 2   7.00	; of p3

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
