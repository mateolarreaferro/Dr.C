<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.5_Bassline

0dbfs = 1


instr 1

kfreq	=	p4	;velocit‡ loop
ktrig	=	0
kamp	=	.7
ksig	loopseg	kfreq,ktrig,0,0,1,kamp,1,0 ;inviluppo ampiezza
knote	lpshold kfreq,ktrig,1,cpspch(6.01),1,cpspch(7.00),\;tabella pitch
1,cpspch(6.02),1,cpspch(9.00),1,cpspch(6.01),1,cpspch(7.02),\
1,cpspch(9.00),1,cpspch(6.01),1,cpspch(6.02),1
a1	vco2	ksig,knote;vco sawtooth
kmoog	linseg 100,p3/2,9000,p3/2,100;frequenza controllo filtro moog
afilt	moogladder a1,kmoog,.6;emulazione filtro moog
out	afilt;uscita vco filtrato

endin

</CsInstruments>
<CsScore>
i1	0	20	.8
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
