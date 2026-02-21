<CsoundSynthesizer>
<CsInstruments>


; Instrument #1.
instr 1
  k1 expon 440, p3/10,880     ; begin gliss and continue
  if k1 < sr/2  kgoto contin  ; until Nyquist detected
    turnoff  ; then quit

contin:
  a1 oscil 10000, k1, 1
  out a1
endin


</CsInstruments>
<CsScore>

; Table #1: an ordinary sine wave.
f 1 0 32768 10 1

; Play Instrument #1 for 4 seconds.
i 1 0 4
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
