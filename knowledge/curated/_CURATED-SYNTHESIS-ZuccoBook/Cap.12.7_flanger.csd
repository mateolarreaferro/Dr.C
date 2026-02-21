<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.12.7_flanger
sr = 44100
kr = 4410
ksmps = 10
nchnls = 2
0dbfs = 1

instr	1

a1	vco2	.2,55,0	;sawtooth
a2	vco2	.2,220,0

asum	sum	a1,a2

idepth	=	p4	;profondit‡
irate	=	p5	;velocit‡ LFO

adel1	poscil	idepth/2000,irate/2000,1
adel2	poscil	idepth/2000,irate/1000,1

kfeedback	=	p6	;feedback

aflang1	flanger	asum,adel1,kfeedback
aflang2	flanger	asum,adel2,kfeedback

outs	(aflang1+asum)*.5,(aflang2+asum)*.5

endin


</CsInstruments>
<CsScore>

f1	0	4096	10	1

i1	0	5	20	1	.1
s		
i1	0	5	20	20	.4
s
i1	0	5	40	40	.9
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
