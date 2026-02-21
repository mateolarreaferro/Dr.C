<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
;Esempio Cap.12.11_connect_alwayson

0dbfs = 1


connect	"impulse","impulse_outL","reverbx","rev_outL"	;left
connect	"impulse","impulse_outR","reverbx","rev_outR"	;right

alwayson	"reverbx"


instr	impulse

k1	randomi	.05,.2,5	;impulsi random con risonatore
a1 	mpulse	4,k1
kfreq	randomi	100,1000,5
areso	wguide1	a1,kfreq,kfreq*2,.9

kpan	randomi	0,1,5	;random pan
aL,aR	pan2	areso,kpan

outleta	"impulse_outL",aL	;bus uscita per riverbero
outleta	"impulse_outR",aR

outs	aL,aR	;uscita audio

endin



instr	reverbx

a1	inleta	"rev_outL"	;segnale ingresso da instr impulse
a2	inleta	"rev_outR"

al,ar	reverbsc	a1,a2,.9,12000,sr,0

outs	al,ar

endin

</CsInstruments>
<CsScore>

i"impulse"	0	200

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
