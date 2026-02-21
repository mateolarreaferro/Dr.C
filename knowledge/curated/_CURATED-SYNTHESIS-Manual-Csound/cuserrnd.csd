<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1	; every run time same values

kuser cuserrnd 0, 100, 1
      printk .2, kuser
asig  poscil .5, 220+kuser, 3
      outs asig, asig
endin

instr 2	; every run time different values

      seed 0
kuser cuserrnd 0, 100, 1
      printk .2, kuser
asig  poscil .5, 220+kuser, 3
      outs asig, asig
endin
</CsInstruments>
<CsScore>
f 1 0 16 -7 1 4 0 8 0 4 1	;distrubution using GEN07
f 2 0 16384 40 1		;GEN40 is to be used with cuserrnd
f 3 0 8192 10 1			;sine

i 1 0 2
i 2 3 2
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
