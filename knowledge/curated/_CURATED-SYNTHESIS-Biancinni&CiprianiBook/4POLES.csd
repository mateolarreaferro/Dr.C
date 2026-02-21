<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;4poles.orc

	instr	1
iamp	=	p4	;sine wave amplitude
;-------------------- parameters of filter 1
ifilt1	=	p6	;center frequency in Hz
ibw1	=	p7	;bandwidth in Hz 
iamp1	=	p8	;formant amplitude
;-------------------- parameters of filter 2
ifilt2	=	p9	;center frequency in Hz
ibw2	=	p10	;bandwidth in Hz 
iamp2	=	p11	;formant amplitude
;-------------------- parameters of filter 3
ifilt3	=	p12	;center frequency in Hz
ibw3	=	p13	;bandwidth in Hz 
iamp3	=	p14	;formant amplitude
;-------------------- parameters of filter 3
ifilt4	=	p15	;center frequency in Hz
ibw4	=	p16	;bandwidth in Hz 
iamp4	=	p17	;formant amplitude
; -------------------- control signal for the frequency sweep
kfrq	line	10,p3,10000
;-------------------- sine wave generation
a1	oscili	iamp,kfrq,1
;-------------------- filtering : 
af1	butterbp	a1,ifilt1,ibw1	;filter 1
af2	butterbp	a1,ifilt2,ibw2	;filter 2
af3	butterbp	a1,ifilt3,ibw3	;filter 3
af4	butterbp	a1,ifilt4,ibw4	;filter 4
;-------------------- sum of the 4 filtered signals
aout	=	af1*iamp1+af2*iamp2+af3*iamp3+af4*iamp4
	out	aout
	endin
 

</CsInstruments>
<CsScore>
;4poles.sco
f1 0 4096 10 1
;               fc1  lb1 amp1 fc2 lb2 amp2  fc3 lb3 amp3 fc4  lb4 amp4
i1 0 10 5000 0  400  200 	1   900 300 .5    1500 200 1.5 3000 400  1

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
