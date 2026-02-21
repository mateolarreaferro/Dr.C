<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1	;same values every time

krnd randi 100, 10
 ;    printk .5, krnd			; look 
aout oscili 0.8, 440+krnd, 1		; & listen
     outs aout, aout

endin

instr 2	;different values every time

krnd randi 100, 10, 10			; seed from system clock
;     printk .5, krnd			; look 
aout oscili 0.8, 440+krnd, 1		; & listen
     outs aout, aout

endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1	;sine wave.

i 1 0 1
i 2 2 1
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
