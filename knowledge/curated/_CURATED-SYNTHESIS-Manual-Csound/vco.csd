<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1

kamp  = .4 
kcps  = cpspch(p4) 
iwave = p5                              ; Select the wave form
kpw init 0.5                            ; Set the pulse-width/saw-ramp character.
ifn = 1
asig vco kamp, kcps, iwave, kpw, ifn
outs asig, asig
endin


</CsInstruments>
<CsScore>
f 1 0 65536 10 1    ; a sine wave.

;           pitch-class waveform
i 1 00 02       05.00       1   ; saw
i 1 02 02       05.00       2   ; square
i 1 04 02       05.00       3   ; tri/saw/ramp

i 1 06 02       07.00       1
i 1 08 02       07.00       2
i 1 10 02       07.00       3

i 1 12 02       09.00       1
i 1 14 02       09.00       2
i 1 16 02       09.00       3

i 1 18 02       11.00       1
i 1 20 02       11.00       2
i 1 22 02       11.00       3
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
