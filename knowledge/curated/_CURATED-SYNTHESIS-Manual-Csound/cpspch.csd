<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	; Convert pitch-class value into Hz 
  
ipch =	p4
icps =	cpspch(ipch)
	print icps
asig	oscil 0.7, icps, 1
	outs  asig, asig

endin

</CsInstruments>
<CsScore>
;sine wave.
f 1 0 16384 10 1

i 1 0 1 8.01
i 1 + 1 8.02
i 1 + 1 8.03
i 1 + .5 5.09

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
