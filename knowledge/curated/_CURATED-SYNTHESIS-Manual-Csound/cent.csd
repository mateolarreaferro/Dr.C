<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	; original pitch
  
iroot = 440	; root note = A (440 Hz)

print iroot	;print out

asig oscili 0.6, iroot, 1 
     outs asig, asig

endin

instr 2
  
iroot   = 440	; root note = A (440 Hz)
icents  = p4	; change root note by 300 and 1200 cents

ifactor = cent(icents) ; calculate new note
inew    = iroot * ifactor

print iroot	; Print all
print ifactor
print inew

asig oscili 0.6, inew, 1 
     outs asig, asig

endin

</CsInstruments>
<CsScore>
; sine wave
f1 0 32768 10 1

i 1 0  2  	;no change
i 2 2.5 2 300	;note = C above A
i 2 5  2 1200	;1 octave higher 

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
