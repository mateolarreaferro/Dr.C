<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
0dbfs  = 1 

instr 1

asaw vco2 .2, 220	;sawtooth
kcf  line 220, p3, 1760	;vary cut-off frequency from 220 to 1280 Hz
kbw  = p4		;vary bandwidth of filter too		
ares reson asaw, kcf, kbw
asig balance ares, asaw
     outs asig, asig

endin
</CsInstruments>
<CsScore>

i 1 0 4 10	;bandwidth of filter = 10 Hz
i 1 + 4 50	;50 Hz and
i 1 + 4 200	;200 Hz
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
