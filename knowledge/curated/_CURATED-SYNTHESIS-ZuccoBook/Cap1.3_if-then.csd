<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap1.3_if-then

instr	1

ivarA	=	5	;dichiaro variabili
ivarB	=	4

if	ivarA	>	ivarB	then	;se A Ë maggiore di B suona 440Hz
a1	oscil	1,440,1	    
elseif	ivarA	<	ivarB	then	;se A Ë minore di B suona 220Hz
a1	oscil	1,220,1
endif

out	a1

endin



</CsInstruments>
<CsScore>

f1	0	4096	10	1

i1	0	10

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
