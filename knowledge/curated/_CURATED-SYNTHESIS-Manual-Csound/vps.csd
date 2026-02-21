<CsoundSynthesizer>
<CsInstruments>
0dbfs = 1

instr 1
 kd = oscili:k(0.5,2) + 0.5
 kv = oscili:k(0.5,1.5) + 0.5
 aph = vps(phasor(p5),kd,kv)
 asig = p4*tablei:a(aph,-1,1,0.25,1)
 out(linenr(asig,0.1,0.1,0.01))
endin

</CsInstruments>
<CsScore>

i 1 0 10 0.5 110 


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
