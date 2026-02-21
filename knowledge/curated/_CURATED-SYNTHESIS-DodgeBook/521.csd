<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 5.21.orc

          instr 1
i1        =         1/p3
a1        rand      p5
k1        oscil     1.,i1,4
k1        =         k1*p4
k2        oscil     1.9,i1,1
k2        =         (k2+.1)*k1
a1        reson     a1,k1,k2,2,0
          out       a1
          endin

</CsInstruments>
<CsScore>
c fig5.21ns.scr
f 1 0 512 7 0 512 1
f 4 0 512 5 1 512 3
f 2 0 512 9 .5 1 0
  i1 0.000 10.000 880 13000
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
