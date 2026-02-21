<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kamp = .6
kcps = 440
ifn  = p4

asig oscil3 kamp, kcps, ifn
     outall asig

endin
</CsInstruments>
<CsScore>
f1 0 128 10 1                                          ; Sine with a small amount of data
f2 0 128 10 1 0.5 0.3 0.25 0.2 0.167 0.14 0.125 .111   ; Sawtooth with a small amount of data
f3 0 128 10 1 0   0.3 0    0.2 0     0.14 0     .111   ; Square with a small amount of data
f4 0 128 10 1 1   1   1    0.7 0.5   0.3  0.1          ; Pulse with a small amount of data

i 1  0 2 1
i 2  3 2 1
i 1  6 2 2
i 2  9 2 2
i 1 12 2 3
i 2 15 2 3
i 1 18 2 4
i 2 21 2 4

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
