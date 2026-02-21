<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


      
        instr 1104
;---------------------------------------; PARAMETER LIST
; p4                      : OVERALL AMPLITUDE
; p5                      : REFERENCE FREQUENCY (FUNDAMENTAL IF SPECTRUM IS HARMONIC)
; p6                      : ATTACK
; p7                      : DECAY
; p8                      : MAXIMUM AMPLITUDE DEVIATION (% OF EACH COMPONENT AMPLITUDE) 
; p9                      : MAXIMUM FREQUENCY DEVIATION (% OF EACH COMPONENT FREQUENCY)
; p10,p14,p18,p22,p26,p30 : RELATIVE AMPLITUDES OF COMPONENTS
; p11,p15,p19,p23,p27,p31 : RELATIVE FREQUENCIES OF COMPONENTS
; p12,p16,p20,p24,p28,p32 : FUNCTION FOR AMPLITUDE FLUCTUATION OF EACH COMPONENT
; p13,p17,p21,p25,p29,p33 : FUNCTION FOR FREQUENCY FLUCTUATION OF EACH COMPONENT
; p34                     : PAN FUNCTION
;---------------------------------------; INITIALIZATION BLOCK
idur      =          p3                       ; DURATION
iamp      =          p4                       ; OVERALL AMPLITUDE
ifreq     =          p5                       ; REFERENCE FREQUENCY
iatt      =          p6                       ; ATTACK
idec      =          p7                       ; DECAY
imaxaf    =          p8/100.00                ; MAXIMUM AMPLITUDE FLUCTUATION
imaxff    =          p9/100.00                ; MAXIMUM FREQUENCY FLUCTUATION
isr2      =          sqrt(2.0)                ; SQUARE ROOT OF 2
isr2b2    =          isr2/2.0                 ; HALF OF SQUARE ROOT OF 2
imaxpan   =          2                        ; MAXIMUM PAN
ipanfunc  =          p34                      ; PAN FUNCTION TABLE
;---------------------------------------------------------------------
kenv      linen      iamp, iatt, idur, idec   ; OVERALL ENVELOPE
;--------------------------------------- ; PANNING
kpan      oscil1     0,imaxpan,idur,ipanfunc  ; PANNING TRAJECTORY
          if    kpan<-1 kgoto beyondl    ; CHECK FOR PAN BEYOND LEFT SPEAKER
          if    kpan>1  kgoto beyondr    ; CHECK FOR PAN BEYOND RIGHT SPEAKER
;--------------------------------------- ; PAN BETWEEN SPEAKERS
ktemp     =          sqrt(1+kpan*kpan)
kpleft    =          isr2b2*(1-kpan)/ktemp
kpright   =          isr2b2*(1+kpan)/ktemp
          kgoto      donepan
beyondl:                                ; PAN BEYOND LEFT SPEAKER
kpleft    =          2.0/(1+kpan*kpan)
kpright   =          0
          kgoto      donepan
beyondr:                                ; PAN BEYOND RIGHT SPEAKER
kpleft    =          0
kpright   =          2.0/(1+kpan*kpan)
donepan:
;----------------------------------------------- ; FIRST COMPONENT
iramp1    =          p10                              ; RELATIVE AMPLITUDE
imaxaf1   =          iramp1*imaxaf                    ; MAXIMUM AMPLITUDE FLUCTUATION
iafunc1   =          p12                              ; AMPLITUDE FLUCTUATION FUNCTION
ifreq1    =          p11*ifreq                        ; FREQUENCY
imaxff1   =          ifreq1*imaxff                    ; MAXIMUM FREQUENCY FLUCTUATION
iffunc1   =          p13                              ; FREQUENCY FLUCTUATION FUNCTION
kampf1    oscil1     0,imaxaf1,idur,iafunc1           ; AMPLITUDE CONTROL
kfreqf1   oscil1     0,imaxff1,idur,iffunc1           ; FREQUENCY CONTROL
a1        oscili     iramp1+kampf1,ifreq1+kfreqf1,1   ; OSCILLATOR
;----------------------------------------------- ;SECOND COMPONENT
iramp2    =          p14                              ; RELATIVE AMPLITUDE
imaxaf2   =          iramp2*imaxaf                    ; MAXIMUM AMPLITUDE FLUCTUATION
iafunc2   =          p16                              ; AMPLITUDE FLUCTUATION FUNCTION
ifreq2    =          p15*ifreq                        ; FREQUENCY
imaxff2   =          ifreq2*imaxff                    ; MAXIMUM FREQUENCY FLUCTUATION
iffunc2   =          p17                              ; FREQUENCY FLUCTUATION FUNCTION
kampf2    oscil1     0,imaxaf2,idur,iafunc2           ; AMPLITUDE CONTROL
kfreqf2   oscil1     0,imaxff2, idur, iffunc2         ; FREQUENCY CONTROL      
a2        oscili     iramp2+kampf2,ifreq2+kfreqf2,1   ; OSCILLATOR
;----------------------------------------------- ;THIRD COMPONENT
iramp3    =          p18                              ; RELATIVE AMPLITUDE
imaxaf3   =          iramp3*imaxaf                    ; MAXIMUM AMPLITUDE FLUCTUATION
iafunc3   =          p20                              ; AMPLITUDE FLUCTUATION FUNCTION
ifreq3    =          p19*ifreq                        ; FREQUENCY
imaxff3   =          ifreq3*imaxff                    ; MAXIMUM FREQUENCY FLUCTUATION
iffunc3   =          p21                              ; FREQUENCY FLUCTUATION FUNCTION
kampf3    oscil1     0,imaxaf3,idur,iafunc3           ; AMPLITUDE CONTROL
kfreqf3   oscil1     0,imaxff3,idur,iffunc3           ; FREQUENCY CONTROL
a3        oscili     iramp3+kampf3,ifreq3+kfreqf3,1   ; OSCILLATOR
;----------------------------------------------- ; FOURTH COMPONENT
iramp4    =          p22                              ; RELATIVE AMPLITUDE
imaxaf4   =          iramp4*imaxaf                    ; MAXIMUM AMPLITUDE FLUCTUATION
iafunc4   =          p24                              ; AMPLITUDE FLUCTUATION FUNCTION
ifreq4    =          p23*ifreq                        ; FREQUENCY
imaxff4   =          ifreq4*imaxff                    ; MAXIMUM FREQUENCY FLUCTUATION
iffunc4   =          p25                              ; FREQUENCY FLUCTUATION FUNCTION
kampf4    oscil1     0,imaxaf4,idur,iafunc4           ; AMPLITUDE CONTROL
kfreqf4   oscil1     0,imaxff4,idur,iffunc4           ; FREQUENCY CONTROL
a4        oscili     iramp4+kampf4,ifreq4+kfreqf4,1   ; OSCILLATOR
;----------------------------------------------- ; FIFTH COMPONENT
iramp5    =          p26                              ; RELATIVE AMPLITUDE
imaxaf5   =          iramp5*imaxaf                    ; MAXIMUM AMPLITUDE FLUCTUATION
iafunc5   =          p28                              ; AMPLITUDE FLUCTUATION FUNCTION
ifreq5    =          p27*ifreq                        ; FREQUENCY
imaxff5   =          ifreq5*imaxff                    ; MAXIMUM FREQUENCY FLUCTUATION
iffunc5   =          p29                              ; FREQUENCY FLUCTUATION FUNCTION
kampf5    oscil1     0,imaxaf5,idur,iafunc5           ; AMPLITUDE CONTROL
kfreqf5   oscil1     0,imaxff5,idur,iffunc5           ; FREQUENCY CONTROL
a5        oscili     iramp5+kampf5,ifreq5+kfreqf5,1   ; OSCILLATOR
;----------------------------------------------- ; SIXTH COMPONENT
iramp6    =          p30                              ; RELATIVE AMPLITUDE
imaxaf6   =          iramp6*imaxaf                    ; MAXIMUM AMPLITUDE FLUCTUATION
iafunc6   =          p32                              ; AMPLITUDE FLUCTUATION FUNCTION
ifreq6    =          p31*ifreq                        ; FREQUENCY
imaxff6   =          ifreq6*imaxff                    ; MAXIMUM FREQUENCY FLUCTUATION
iffunc6   =          p33                              ; FREQUENCY FLUCTUATION FUNCTION
kampf6    oscil1     0,imaxaf6,idur,iafunc6           ; AMPLITUDE CONTROL
kfreqf6   oscil1     0,imaxff6,idur,iffunc6           ; FREQUENCY CONTROL
a6        oscili     iramp6+kampf6,ifreq6+kfreqf6,1   ; OSCILLATOR
;---------------------------------------------------------; MIX
iampsum   =          iramp1+iramp2+iramp3+iramp4+iramp5+iramp6 ; MAXIMUM AMPLITUDE
asig      =          kenv*(a1+a2+a3+a4+a5+a6)/(iampsum)        ; BALANCED MIX
;---------------------------------------------------------
          outs       kpleft*asig,kpright*asig                  ;OUTPUT
          endin


</CsInstruments>
<CsScore>

; 1104.SCO  PRODUCES DYNAMIC SPECTRUM
;		    (C) RAJMIL FISCHMAN, 1997
;-------------------------------------
;SINEWAVE
f 1 0 8192 10 1	 
;FIRST COMPONENT

f 11 0 1024 9	0.5 1 55	1.3 2.3 40  2.6 1.32 35	3.45 3 20				  ;AMPLITUDE
f 12 0 1024 9	1 1 90	1.3 2.3 84  1.6 1.32 75	2.45 3 60				  ;FREQUENCY
;SECOND COMPONENT
f 21 0 1024 9	0.7 3 66	1.63 2.2 37  3.36 4.32 16  1.45 3 12			  ;AMPLITUDE
f 22 0 1024 9	1 1 10	2.6 1.13 84  .8 2.46 75	 4.9 1.5 60			  ;FREQUENCY
;THIRD COMPONENT
f 31 0 1024 9	2.1 1 22	 4.18 6.6 111	1.12 1.1 5  5.15 9 36			  ;AMPLITUDE
f 32 0 1024 9	1 1 79	 2.6 1.13 84	.8 2.46 75  4.9 1.5 60			  ;FREQUENCY
;FOURTH COMPONENT
f 41 0 1024 9	6.62 2.5 44  7.1 2.2 48	2.89 3.5 1					  ;AMPLITUDE
f 42 0 1024 9	0.2 1.6 179  2.55 1.2 4	.16 4.12 123					  ;FREQUENCY
;FIFTH COMPONENT
f 51 0 1024 9	8.4 0.25 188  1.02 9.9 8	   4.48 4.4 100  1.37 2.25 90		  ;AMPLITUDE
f 52 0 1024 9	0.25 4 79	    5.4 .42 184  .8 9.12 57	1.24 6 6			  ;FREQUENCY
;SIXTH COMPONENT
f 61 0 1024 9	1.62 .25 8  5.1 9.9 180	.89 4.4 1	   3 2.4 30  6.85 2.25 270 ;AMPLITUDE
f 62 0 1024 9	1.25 4 79	  2.55 2.1 48	.16 9.12 37  2.4 3 7   5.96 6 160	  ;FREQUENCY
;PANNING FUNCTIONS
f 71 0 1024 10 1 1 1 1 1 1 1 1 1 1 
f 72 0 1024 10 0 0 0 1 0 1 0 1 0 1
f 73 0 1024 9	1.5 0.8 180  2.4 0.78 170  3.5 0.8 160	4.6 0.65 140
f 74 0 1024 9	1.3 0.5 170  3.34 0.6 190  4.7 0.7 140	5.33 0.35 200
;--------------------------------------------------------------------------------
;	   p3    p4	 p5	 p6	 p7	  p8	   p9    p10..	 p11..  p12..	p13..  p34 
;									    p30	 p31	   p32	p33
;  STT  DUR   AMP    REF  ATT  DEC   MAX   MAX   REL    REL    AMP    FREQ   PAN
;                    FREQ            AMP   FREQ  AMP    FREQ   FUNC   FUNC   FUNC
;                                    FLUC  FLUC
;							  (%)   (%)
;--------------------------------------------------------------------------------
i 1104 0	   5	   7000  100  1	1.5	 20	  5	   1		1	  11	    12
									    0.86	 2.01   21	22
									    0.77	 3.02   31	32
									    0.68	 4.03   41	42
									    0.59	 5.04   51	52
									    0.5	 6.05   61	62	  11
i 1104 2	   7	   11000 107  2	1.5	 20	  10	   0.05	1	  12	    11
									    0.68	 1.35   22	21
									    0.79	 1.78   32	31
									    0.67	 2.13   42	41
									    0.59	 2.55   52	51
									    0.82	 3.23   62	61	  74
i 1104 5	   7	   11000 222  2	1.5	 20	  10	   0.7	1	  12	    11
									    0.68	 1.35   22	21
									    0.79	 1.78   32	31
									    0.67	 2.13   42	41
									    0.59	 2.55   52	51
									    0.82	 3.23   62	61	  22
i 1104 5.59  4.35 4000  4316 1.5	2	 30	  8	   0.8	1	  12	    11
									    0.7	 1.35   61	62
									    0.6	 1.78   52	52
									    0.5	 1.13   22	22
									    0.55	 1.55   41	42
									    0.76	 1.23   32	31	  73
i 1104 5.6   10.3 11000 62   3.5	3	 20	  10	   0.97	1	  12	    11
									    0.79	 1.23   32	31
									    0.68	 1.34   22	21
									    0.59	 2.45   52	51
									    0.67	 2.63   42	41
									    0.82	 3.76   62	61	  71
i 1104 6.1   3.25 3000  5555 1.5	1.5	 30	  8	   0.8	1	  32	    21
									    0.7	 1.35   42	51
									    0.6	 1.78   12	61
									    0.5	 1.13   62	11
									    0.55	 1.55   51	42
									    0.76	 1.23   22	31	  41
i 1104 6.5   1.3  12000 250  1	0.05	 20	  5	   0.8	1	  62	    61
									    0.7	 2.35   52	51
									    0.6	 3.78   42	41
									    0.5	 4.13   32	31
									    0.55	 5.55   22	21
									    0.76	 6.23   12	11	  71
i 1104 7.2   0.95 12000 324  0.6	0.05	 30	  8	   0.8	1	  22	    21
									    0.7	 2.35   52	51
									    0.6	 3.78   62	61
									    0.5	 4.13   11	12
									    0.55	 5.55   41	42
									    0.76	 6.23   31	32	  72
i 1104 7.5   8	   2500  1000 2.5	3.5	 15	  2	   1		1	  11	    12
									    0.86	 2.01   21	22
									    0.77	 3.02   31	32
									    0.68	 4.03   41	42
									    0.59	 5.04   51	52
									    0.5	 6.05   61	62	  73
i 1104 7.65  8	   2500  993  1.5	3.5	 15	  2	   1		1	  12	    11
									    0.86	 2.01   21	22
									    0.77	 3.02   32	31
									    0.68	 4.03   41	42
									    0.59	 5.04   52	51
									    0.5	 6.05   61	62	  11
i 1104 9.35  0.6  7000  850  0.05	0.15	 20	  5	   0.8	1	  22	    11
									    0.7	 2.35   32	61
									    0.6	 3.78   52	51
									    0.5	 4.13   42	21
									    0.55	 5.55   62	41
									    0.76	 6.23   12	31	  74
i 1104 9.55  6	   9000  666  0.15	3	 20	  5	   0.8	1	  51	    32
									    0.7	 2.35   31	12
									    0.6	 3.78   41	42
									    0.5	 4.13   11	22
									    0.55	 5.55   61	62
									    0.76	 6.23   21	32	  72
i 1104 10.66 1.45 3000  6200 1.2	0.05	 30	  8	   0.8	1	  22	    21
									    0.7	 1.35   52	51
									    0.6	 1.78   62	61
									    0.5	 1.13   12	11
									    0.55	 1.55   41	42
									    0.76	 1.23   32	31	  73
i 1104 11.87 1.5  6000  1050 0.1	1.05	 30	  8	   0.8	1	  22	    21 
									    0.7	 1.35   52	51
									    0.6	 1.78   62	61
									    0.5	 1.13   12	11
									    0.55	 1.55   41	42
									    0.76	 1.23   32	31	  74
i 1104 12	   3.85 5000  7733 0.05	2.05	 30	  8	   0.8	1	  22	    21
									    0.7	 1.35   52	51
									    0.6	 1.78   62	61
									    0.5	 1.13   12	11
									    0.55	 1.55   41	42
									    0.76	 1.23   32	31	  72
i 1104 12.05 4.75 3000  9987 1	2	 30	  8	   0.8	1	  22	    21
									    0.7	 1.35   52	51
									    0.6	 1.78   62	61
									    0.5	 1.13   12	11
									    0.55	 1.55   41	42
									    0.76	 1.23   32	31	  41
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
