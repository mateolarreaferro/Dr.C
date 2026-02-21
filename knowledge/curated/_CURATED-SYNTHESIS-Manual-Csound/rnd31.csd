<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1
                            ; Create random numbers at a-rate in the range -2 to 2 with
a31 rnd31 2, -0.5           ; a triangular distribution, seed from the current time.
afreq = a31 * 500 + 100     ; Use the random numbers to choose a frequency.
a1 oscili .5, afreq         ; uses sine
outs a1, a1

endin

</CsInstruments>
<CsScore>
i 1 0 1
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
