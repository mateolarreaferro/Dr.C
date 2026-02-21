<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kamp    init p4
kcpsmin init 2
kcpsmax init 20

ksp  jspline kamp, kcpsmin, kcpsmax
aout pluck 1, 200+ksp, 1000, 0, 1
aout dcblock aout	;remove DC
     outs aout, aout

endin
</CsInstruments>
<CsScore>

i 1 0 10 2	;a bit jitter
i 1 8 10 10	;some more
i 1 16 10 20	;lots more
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
