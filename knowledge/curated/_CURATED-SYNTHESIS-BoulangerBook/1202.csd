<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	1202	; A BETTER SIMPLE FM INSTRUMENT
isine	=		1					; f1 HAS A SINE WAVE - BEST FOR SIMPLE FM
iamp	=		p4					; PEAK AMP OF CARRIER
ihz0	=		cpspch(p5)+p18		; BASIC PITCH +DETUNE
icfac	=		p6					; CARRIER FACTOR
imfac	=		p7					; MODULATOR FACTOR
index	=		p8					; MAXIMUM INDEX VALUE
ieva	=		p9					; ATTACK TIME OF MAIN ENVELOPE
ievd	=		p10					; DECAY TIME OF MAIN ENVELOPE
iamp2	=		p11*iamp			; MAIN AMP SUSTAIN LEVEL
ievr	=		p12					; RELEASE TIME OF MAIN ENVELOPE
ievss	=		p3-ieva-ievd-ievr	; ENV STEADY STATE
indx1	=		p13*index			; INITIAL/FINAL INDEX
idxa	=		p14					; ATTACK TIME OF INDEX
idxd	=		p15					; DECAY TIME OF INDEX
indx2	=		p16*index			; SUSTAINED INDEX
idxr	=		p17					; RELEASE TIME OF INDEX
idxss	=		p3-idxa-idxd-idxr	; INDEX STEADY STATE
kndx	linseg	indx1, idxa, index, idxd, indx2, idxss, indx2, idxr, indx1	
kamp	linseg	0, ieva, iamp, ievd, iamp2, ievss, iamp2, ievr, 0	
asig	foscili	kamp, ihz0, icfac, imfac, kndx, isine	
		out		asig	
		endin		

</CsInstruments>
<CsScore>
f 1 0   2048    10  1   ;SIMPLE SINE WAVE               
;   ST  DUR AMP PCH CFAC    MFAC    INDEX   RISE    DEC
i 1202  0   1   20000   8.09    1   1   5   .05 .01
;   AFACT   REL XFAC1   XRIS    XDEC    XFAC2   XREL    DETUNE  
    1   .2  0   .1  .5  .25 .25 0   
i 1202  2   .   .   .   3   1   2   .   .
    .   .   .   .   .01 1   .25     
i 1202  4   .   .   6.09    5   1   1.5     
                                    
i 1202  6   .   .   8.09    3   2   4   .   .
    .   .   .5  .   .   1           
;THREE NOTES SLIGHTLY DETUNED AND SLIGHTLY STAGGERED ENTRANCES                                  
i 1202  8   6   10000   6.00    1   1.4 10  3   1.9
    .7  1   0   3   1.9 .25 1       
i 1202  8.005   .   .   .   .   .   .   .   .
    .   .   .   .   .   .   .   1   
i 1202  8.012   .   .   .   .   .   .   .   .
    .   .   .   .   .   .   .   -1  
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
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
