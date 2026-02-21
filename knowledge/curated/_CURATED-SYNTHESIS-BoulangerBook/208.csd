<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr 208		
idur	=		p3	
iamp	=		p4	
icarfrq	=		p5	
imodfrq	=		p6			
aenv	expseg	.01, idur*.1, iamp, idur*.8, iamp*.75, idur*.1, .01
i1		=		p7*imodfrq			; p7=MOD. INDEX START
i2		=		p8*imodfrq			; p8=MOD. INDEX END
adev	line	i1, idur, i2		; MODULATION FREQUENCY
aindex	line	p7, idur, p8		; MODULATION INDEX
; r VALUE ENVELOPE: p9-p10 = EXP. PARTIAL STRENGTH PARAMETER START AND END
ar		linseg	1, .1, p9, p3-.2, p10, .1, 1
amp1	=		(aindex*(ar+(1/ar)))/2	
afmod	oscili	amp1, imodfrq, 1	; FM MODULATOR (SINE)
atab	=		(aindex*(ar-(1/ar)))/2	; INDEX TO TABLE
alook	tablei	atab, 37			; TABLE LOOKUP TO GEN12
aamod	oscili	atab, imodfrq, 2	; AM MODULATOR (COSINE)
aamod	=		(exp(alook+aamod))*aenv	
acar	oscili	aamod, afmod+icarfrq, 1	; AFM (CARRIER)	
asig	balance	acar, aenv
		out		asig	
		endin		

</CsInstruments>
<CsScore>
f 1     0   8192    10  1               
f 2     0   8192    9   1 1 90          
f37 0   1024    -12 40  ;BESSEL FUNCTION-DEFINED FROM 0 TO 40

i 208  0  2  6800      800  800    1    6   .1   2
i 208  +  .  .         1900 147    8    1    4   .2
i 208  .  .  .         1100 380    2    9   .5   2
i 208  .  10 .         100  100    11   3   .2   5

s
i 208  0  1  3000       200 100    1    6   .1   2
i 208  +  .  <          <    <      <    <   <    <
i 208  +  .  .          <    <      <    <   <    <
i 208  +  .  .          <    <      <    <   <    <
i 208  +  .  .          <    <      <    <   <    <
i 208  +  .  .          <    <      <    <   <    <
i 208  +  .  .          <    <      <    <   <    <
i 208  +  10 5000       800  800    9    1   .9   6

s
i 208  0  11 3800       50   51     1    6   .1   2
i 208  1  9  1600       700  401    1    6   .1   2
i 208  2  8  .          900 	147    8    1    4   .2
i 208  3  7  .          1100 381    2    9   .5   2
i 208  4  6  .          200  102    11   3   .2   5
i 208  5  6  .          800  803    9    1   .9   6

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
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
