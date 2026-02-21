<CsoundSynthesizer>
<CsInstruments>

nchnls = 2

instr 1

asig diskin2 "beats.wav", 1
     outs asig, asig
endin

instr 2

kton line 10000, p3, 0		;all the way down to 0 Hz
asig diskin2 "beats.wav", 1
asig tone asig, kton		;half-power point at 500 Hz
     outs asig, asig
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
