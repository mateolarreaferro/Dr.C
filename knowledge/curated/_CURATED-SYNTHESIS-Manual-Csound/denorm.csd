<CsoundSynthesizer>
<CsOptions>

0dbfs = 1

garvb init 0

instr 1

a1  oscils 0.6, 440, 0
a2  linsegr 0, 0.005, 1, 3600, 1, 0.08, 0
a1  =  a1 * a2
    vincr garvb, a1
    outs a1, a1
endin

instr 99	;"Always on"

       denorm garvb
aL, aR reverbsc garvb * 0.5, garvb * 0.5, 0.92, 10000
       clear garvb
       outs aL, aR
endin

</CsInstruments>
<CsScore>

i 99 0 -1	;held by a negative p3, means "always on" 
i 1 0 0.5
i 1 4 0.5
e 8		;8 extra seconds after the performance

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
