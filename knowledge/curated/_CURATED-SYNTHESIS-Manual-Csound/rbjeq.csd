<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

imode = p4
a1    vco2    .3, 155.6			; sawtooth wave
kfco  expon   8000, p3, 200		; filter frequency
asig  rbjeq   a1, kfco, 1, kfco * 0.005, 1, imode
      outs asig, asig

endin
</CsInstruments>
<CsScore>

i 1 0  5 0	;lowpass
i 1 6  5 2	;highpass
i 1 12 5 4	;bandpass
i 1 18 5 8	;equalizer

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
