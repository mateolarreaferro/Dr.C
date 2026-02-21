<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1	;use sr to find maximum harmonics

ihar	= int(sr/2/p4)		; maximum possible number of harmonics w/o aliasing
prints  "maximum number of harmonics = %d \\n", ihar
kenv	linen .5, 1, p3, .2	; envelope
asig	buzz  kenv, p4, ihar, 1
	outs  asig, asig

endin
</CsInstruments>
<CsScore>
f1 0 4096 10 1	;sine wave

i 1 0 3 100	;different frequencies
i 1 + 3 1000
i 1 + 3 10000
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
