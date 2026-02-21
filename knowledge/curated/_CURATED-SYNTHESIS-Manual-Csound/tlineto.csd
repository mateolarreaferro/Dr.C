<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 2^10, 10, 1

instr 1


kmtr lfo 1, .5, 1			;produce trigger signal			
ktr  trigger kmtr, .5, 0		;with triangle wave

ktime = p4				
kfreq randh 1000, 3, .2, 0, 500		;generate random values
kfreq tlineto kfreq, ktime, ktr		;different glissando times
aout  poscil .4, kfreq, giSine
      outs aout, aout

endin
</CsInstruments>
<CsScore>

i 1 0 10 .2	;short glissando
i 1 11 10 .8	;longer glissande
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
