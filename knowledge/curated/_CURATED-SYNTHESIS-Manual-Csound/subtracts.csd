<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

idur = p3
iatt = p4
idec = p5
isus = p3-iatt-idec				;calculate sustain time from subtracting attack and decay
printf_i "sutain time= note duration - attack - decay --> %.1f-%.1f-%.1f = %.1f\n", 1, idur, iatt, idec, isus

kenv expseg 0.01, iatt, 1, isus, 1, idec, 0.01	;envelope
asig poscil 1*kenv, 200, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 4096 10 1	;sine wave
;      attack decay
i 1 0 3 .1     .2
i 1 4 3 .5    1.5
i 1 8 5  4     .5

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
