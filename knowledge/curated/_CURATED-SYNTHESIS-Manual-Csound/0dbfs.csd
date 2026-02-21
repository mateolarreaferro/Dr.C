<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; Set the 0dbfs to 1.
0dbfs = 1

instr 1  ; from linear amplitude (0-1 range)
print p4
a1 oscil p4, 440, 1
outs a1, a1
endin

instr 2  ; from linear amplitude (0-32767 range)
iamp = p4 / 32767
print iamp
a1 oscil iamp, 440, 1
outs a1, a1
endin

instr 3  ; from dB FS
iamp = ampdbfs(p4)
print iamp
a1 oscil iamp, 440, 1
outs a1, a1
endin


</CsInstruments>
<CsScore>

; Table #1, a sine wave.
f 1 0 16384 10 1

i 1 0 1   1
i 1 + 1   0.5
i 1 + 1   0.1
s
i 2 0 1   32767
i 2 + 1   [32767/2]
i 2 + 1   [3276.7]
s
i 3 0 1   0
i 3 + 1   -6
i 3 + 1   -20
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
