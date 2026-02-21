<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	702
idur	=		abs(p3)				; MAIN INIT BLOCK
ipch1	=		cpspch(p6)	
ipch2	=		cpspch(p5)	
kpch	=		ipch2	
iport	=		0.1					; 100msec PORTAMENTO
iatt	=		0.05				; DEFAULT DURS FOR AMPLITUDE RAMPS
idec	=		0.05				; ASSUME THIS IS A TIED NOTE:
iamp	=		p4					; SO START AT p4 LEVEL...
i1		=		-1					; ... AND KEEP PHASE CONTINUITY
		ir		tival				;  CONDITIONAL INIT BLOCK:TIED NOTE?
		tigoto	start	
i1		=		0					; FIRST NOTE: RESET PHASE
iamp	=		0					; AND ZERO iamp
start:			
iadjust	=		iatt+idec	
		if		idur >= iadjust igoto doamp	; ADJUST RAMP DURATIONS FOR SHORT...
iatt	=		idur/2-0.005		; ... NOTES, 10msecs LIMIT
idec	=		iatt				; ENSURE NO ZERO-DUR SEGMENTS
iadjust	=		idur-0.01	
iport	=		0.005				; MAKE AMPLITUDE RAMP...
doamp:								; ... (arate FOR CLEANNESS) AND...
ilen	=		idur-iadjust		; ... SKIP PITCH RAMP GENERATION...
amp		linseg	iamp, iatt, p4, ilen, p4, idec, p7
		if 		ir == 0 || p6 == p5 kgoto slur	;...IF FIRST NOTE OR TIE.
; MAKE PITCH RAMP, PORTAMENTO AT START OF NOTE
kpramp	linseg	ipch1, iport, ipch2, idur-iport, ipch2
kpch	=		kpramp	
slur:								; MAKE THE NOTE
aamp	=		amp	
asig	oscili	aamp, kpch, 1, i1	
		out		asig	
		endin

</CsInstruments>
<CsScore>
f 1 0   1024    10  1 0.95 0.1 0.05 0.01 0.001

;BASIC P-FIELDS ... CONTEXT P-FIELDS
; INS   ST  DUR AMP     PCH    PREVPCH  NEXTAMP
i 702   0   -1  10000   7.03    7.03    np4
i 702   +   .   4000    8.00    pp5     np4
i 702   .   .   22000   7.06    pp5     np4
;POSITIVE DUR (P3) FOR LAST TIED NOTE
i 702   .   1   4000    7.08    pp5     0
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>892</width>
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
