<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 5.20.orc

          instr 1
a1        rand      p5
k2        oscil     p4,p6,2
a1        reson     a1,0,k2,2,0
          out       a1
          endin

</CsInstruments>
<CsScore>
c fig5.20ns.scr
f 2 0 512 9 .5 1 0
  i1 0.000 5.000 300 13000 3.000
end of score
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
