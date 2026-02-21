<CsoundSynthesizer>
<CsOptions>
; By  Stefano Cucchi - 2020
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

asig vco2 0.2, 100  ; Audio signal.   	
kout randomh 1, 2, 5  ; Extracts random number between 1 & 2 - 5 times per second.

    outch kout,asig ; Sends the signal to the channel according to "kout".

printks "signal is sent to channel %d\\n", .2, kout ; Prints the channel where you hear the sound.
endin

</CsInstruments>
<CsScore>

i 1 0 15
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
