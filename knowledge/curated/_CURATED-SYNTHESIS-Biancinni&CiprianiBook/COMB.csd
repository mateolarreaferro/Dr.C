<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;comb.orc	
	sr	=	22050
	kr	=	2205
	ksmps	=	10
	nchnls	=	1
	instr 	1
kfreq 	line 	10,p3,10000
a1 	oscili 1000,kfreq,1
acomb 	comb 	a1,.5, .001
	out 	acomb
	endin
 

</CsInstruments>
<CsScore>
;comb.sco
f1 0 4096 10 1
i1 0 5

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
