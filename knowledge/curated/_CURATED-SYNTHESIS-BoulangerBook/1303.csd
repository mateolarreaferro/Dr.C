
; 13sine22.csd: THIS .CSD GENERATES A 220 HZ SINE TONE

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr      =      	44100
kr    	=     	4410
ksmps  	=     	10
nchnls	=		1

        instr   1303
a1      oscil   20000, 220, 1, 0
        out     a1
        endin

</CsInstruments>
<CsScore>

f 1 0 524288 10 1

i 1303 0 10

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
