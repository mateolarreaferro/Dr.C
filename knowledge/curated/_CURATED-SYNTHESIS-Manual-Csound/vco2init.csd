<CsoundSynthesizer>
<CsInstruments>


; create waveform with discontinuities, so it has a lot of high freq content
gitable ftgen 0, 0, 2^16+1, 7, -1, 2^14, 1, 0, -1, 2^14, 1, 0, -1, 2^15, 1
; make bandlimited tables of the waveform
gi_nextfree vco2init -gitable, gitable+1, 1.05, 128, 2^16, gitable
gitable_bl = -gitable

instr 1

kfreq  expon 14000, p3, 500
kfn    vco2ft kfreq, gitable_bl
asig   oscilikt 5000, kfreq, kfn
;printk 0.1, kfn

; remove semicolon on next line to hear original waveform, demonstrating the aliasing
;asig   oscili 5000, kfreq, gitable
       outs asig, asig

endin
</CsInstruments>
<CsScore>
i1 0 5
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
