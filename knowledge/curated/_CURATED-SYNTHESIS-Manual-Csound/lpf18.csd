<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1
  
kamp init 1                         ; Note that its amplitude (kamp) ranges from 0 to 1.
kcps init 440
knh init 3
ifn = 1
asine buzz kamp, kcps, knh, ifn     ; Generate a sine waveform.
kfco line 300, p3, 3000             ; Filter the sine waveform.
kres init 0.8                       ; Vary the cutoff frequency (kfco) from 300 to 3,000 Hz.
kdist = p4
ivol = p5
aout lpf18 asine, kfco, kres, kdist
outs aout * ivol, aout * ivol

endin

</CsInstruments>
<CsScore>
f 1 0 16384 10 1    ; sine wave.

; different distortion and volumes to compensate
i 1 0 4     0.2         .8
i 1 4.5 4   0.9         .7
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
