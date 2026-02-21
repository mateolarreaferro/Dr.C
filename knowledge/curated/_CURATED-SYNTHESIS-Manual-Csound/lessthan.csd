<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

ipch = p4
ipitch	= (ipch < 15 ? cpspch(ipch) : ipch)	;if p4 is lower then 15, it assumes p4 to be pitch-class
;print ipitch					;and not meant to be a frequency in Hertz
asig  poscil .5,  ipitch , 1
      outs asig, asig
  
endin
</CsInstruments>
<CsScore>
f1 0 8192 10 1	;sine wave

i1 0  3 8.00	;pitch class
i1 4  3 800	;frequency

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
