<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1
; iscale does not need to be set here because already 0dbfs = 1  
aout vco .3, 220, 1	; Use a nice sawtooth waveform.
kfco line 200, p3, 2000	; filter-cutoff frequency from .2 to 2 KHz
krez init p4
asig moogvcf aout, kfco, krez
     outs asig, asig

endin
</CsInstruments>
<CsScore>
;a sine wave
f 1 0 16384 10 1

i 1 0 3 .1
i 1 + 3 .7
i 1 + 3 .95
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
