<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.7.4_FMsynth4Mod(nogui)

0dbfs = 1

instr	1

iamp	=	p4
ifreq	=	p5

kfreqmod1	=	p6	
kfreqmod2	=	p7
kfreqmod3	=	p8
kfreqmod4	=	p9

;indice di modulazione con inviluppo

irise	=	0.2
idec 	=	0.5
idur	=	p3-idec

ifn	=	2
iatdec	=	0.01

kenvindx1	envlpx	.6,irise,idur,idec,ifn,p10,iatdec
kenvindx2	envlpx	.6,irise,idur,idec,ifn,p11,iatdec
kenvindx3	envlpx	.6,irise,idur,idec,ifn,p12,iatdec
kenvindx4	envlpx	.6,irise,idur,idec,ifn,p13,iatdec

kindex	=	p14


icps	=	ifreq ;frequenza osc portante

afm1	foscili	iamp,1,icps,icps*kfreqmod1,kindex*kenvindx1,1
afm2	foscili iamp,1,icps,icps*kfreqmod2,kindex*kenvindx2,1
afm3	foscili iamp,1,icps,icps*kfreqmod3,kindex*kenvindx3,1
afm4	foscili iamp,1,icps,icps*kfreqmod4,kindex*kenvindx4,1


aout	sum	afm1,afm2,afm3,afm4	

aclip	clip	aout,2,.8

outs	aclip,aclip

endin	


</CsInstruments>
<CsScore>
f1	0	65536	10	1
; a linear rising envelope
f 2 0 129 -7 0 128 1



i1	0	1.2	.6	80	.1	2	3	4	1.1	.2	2.3	.4	1	
s
i1	0	1.3	.6	180	1	.2	3	4	1.1	.2	2.3	.4	2	
s
i1	0	1.4	.6	280	1	2	.3	4	1.1	.2	2.3	.4	3	
s
i1	0	1.5	.6	380	1	2	3	.4	1.1	.2	2.3	.4	4	
s
i1	0	2	.6	480	1	2	.3	4	1.1	.2	2.3	.4	5	
s
i1	0	4	.6	580	1	.2	3	4	1.1	.2	2.3	.4	6	
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
