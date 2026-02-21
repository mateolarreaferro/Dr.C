<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
0dbfs  = 1

giSine ftgen 0, 0, 2^10, 10, 1

instr 1

asig poscil3 .5, 880, giSine
;write a raw file: 32 bits with header
     fout "fout_880.wav", 15, asig	
     outs asig, asig

endin

instr 2

klfo lfo 1, 2, 0
asig poscil3 .5*klfo, 220, giSine
;write an aiff file: 32 bits with header
     fout "fout_aif.aiff", 25, asig	
;        fout "fout_all3.wav", 14, asig
     outs asig, asig

endin

instr 99 ;read the stereo csound output buffer

allL, allR monitor
;write the output of csound to an audio file
;to a wav file: 16 bits with header
           fout "fout_all.wav", 14, allL, allR

endin
</CsInstruments>
<CsScore>

i 1 0 2
i 2 0 3
i 99 0 3
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
