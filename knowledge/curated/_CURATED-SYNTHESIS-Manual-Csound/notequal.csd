<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

ipch   = cpspch(p4)
iprint = p5
if (iprint != 1) goto skipPrint
print  ipch
asig   vco .7, ipch, 2, 0.5, 1
       outs asig, asig

skipPrint:

endin

</CsInstruments>
<CsScore>
f 1 0 65536 10 1	;sine wave

i1 0 .5 8.00 0
i1 + .5 8.01 1 ; this note will print it's ipch value and only this one will be played
i1 + .5 8.02 2

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
