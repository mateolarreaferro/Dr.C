<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

nchnls = 1
;Esempio Cap.7.8_powershape

instr 1
	
kshape  linseg    p5, p3/2, p6,p3/2,p5
aosc oscili 10000,cpspch(p4),1
aout powershape  aosc,kshape
out aout

endin

</CsInstruments>
<CsScore>
f1 0 4096 10 1
i1 0 22  6.00  0.1 2.3
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
