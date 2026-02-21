<CsoundSynthesizer>
<CsOptions>
</CsOptions> 
<CsInstruments>

;Esempio Cap.6.7_Lowpass filter(nogui)

instr	1

kfreq	randomi	100,20000,1	
ilayer	=	p4	;filtri in serie	
aout	rand	.6	;rumore bianco
afilt	tonex	aout,kfreq,ilayer ;banco di filtri
out	afilt 

endin


</CsInstruments>
<CsScore>
i1	0	10	1
s
i1	0	10	10
s	
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
