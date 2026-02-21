<CsoundSynthesizer>

<CsInstruments>

0dbfs  = 1

; user defined waveform -2: fixed table size (64), number of partials
; multiplier is 1.4
itmp    ftgen 2, 0, 64, 5, 1, 2, 120, 60, 1, 1, 0.001, 1
ift     vco2init -2, 3, 1.4, 4096, 4096, 2


instr 1

icps = p4
ifn  vco2ift icps, -2, 0.5	;with user defined waveform
print ifn
asig oscili 1, 220, ifn		; (-2), and sr/2 bandwidth
     outs asig, asig

endin
</CsInstruments>
<CsScore>

i 1 0 2 20
i 1 3 2 2000
i 1 6 2 20000

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
