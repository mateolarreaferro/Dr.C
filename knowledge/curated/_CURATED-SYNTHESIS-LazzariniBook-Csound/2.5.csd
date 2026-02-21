/* Setting the sr to 48,000 Hz */

<CsoundSynthesizer>
<CsInstruments>
sr = 48000
instr 1
 out oscili(1000,440)
endin
schedule(1,0,1)
</CsInstruments>
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
