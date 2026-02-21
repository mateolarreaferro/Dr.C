<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;---------------------------------------------------------------------------
; MIKELSON'S MULTI-FX SYSTEM
;---------------------------------------------------------------------------
; 3002. PLUCK
; 3013. TUBE AMP DISTORTION
; 3099. MIX
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
        zakinit 30, 30
;---------------------------------------------------------------------------
; SOUND SOURCE
;---------------------------------------------------------------------------
; PLUCK PHYSICAL MODEL
;---------------------------------------------------------------------------
        instr   3002
iamp    =       p4                  ; AMPLITUDE
ifqc    =       cpspch(p5)          ; CONVERT TO FREQUENCY
itab1   =       p6                  ; INITIAL TABLE
imeth   =       p7                  ; DECAY METHOD
ioutch  =       p8                  ; OUTPUT CHANNEL
kamp    linseg  0, .002, iamp, p3-.004, iamp, .002, 0  ; DECLICK
aplk    pluck   kamp, ifqc, ifqc, itab1, imeth         ; PLUCK WAVEGUIDE MODEL
        zawm    aplk, ioutch                           ; WRITE TO OUTPUT
gifqc   =       ifqc
        endin
;---------------------------------------------------------------------------
; DISTORTION
;---------------------------------------------------------------------------
        instr   3013
igaini  =       p4                  ; PRE GAIN
igainf  =       p5                  ; POST GAIN
iduty   =       p6                  ; DUTY CYCLE OFFSET
islope  =       p7                  ; SLOPE OFFSET
izin    =       p8                  ; INPUT CHANNEL
izout   =       p9                  ; OUTPUT CHANNEL
asign   init    0                   ; DELAYED SIGNAL
kamp    linseg  0, .002, 1, p3-.004, 1, .002, 0   ; DECLICK
asig    zar     izin                ; READ INPUT CHANNEL
aold    =       asign               ; SAVE THE LAST SIGNAL
asign   =       igaini*asig/60000   ; NORMALIZE THE SIGNAL
aclip   tablei  asign,5,1,.5        ; READ THE WAVESHAPING TABLE
aclip   =       igainf*aclip*15000  ; RE-AMPLIFY THE SIGNAL
atemp   delayr  .1                  ; AMPLITUDE AND SLOPE BASED DELAY
aout    deltapi (2-iduty*asign)/1500 + islope*(asign-aold)/300
        delayw  aclip
        zaw     aout, izout         ; WRITE TO OUTPUT CHANNEL
        endin

;---------------------------------------------------------------------------
; LOW PASS RESONANT FILTER
;---------------------------------------------------------------------------
        instr   3015
idur    =       p3
itab1   =       p4                  ; CUT-OFF FREQUENCY
itab2   =       p5                  ; RESONANCE
ilpmix  =       p6                  ; LOW-PASS SIGNAL MULTIPLIER
irzmix  =       p7                  ; RESONANCE SIGNAL MULTIPLIER
izin    =       p8                  ; INPUT CHANNEL
izout   =       p9                  ; OUTPUT CHANNEL
kfco    oscil   1,1/idur,itab1      ; CUT-OFF FREQUENCY ENVELOPE FROM TABLE
kfcort  =       sqrt(kfco)          ; NEEDED FOR THE FILTER
krezo   oscil   1,1/idur,itab2      ; RESONANCE ENVELOPE FROM TABLE
krez    =       krezo*kfco/500      ; ADD MORE RESONANCE AT HIGH FCO
kamp    linseg  0, .002, 1, p3-.004, 1, .002, 0  ; DECLICK
axn     zar     izin                ; READ INPUT CHANNEL
ka1     =       1000/krez/kfco-1    ; COMPUTE FILTER COEFF. a1
ka2     =       100000/kfco/kfco    ; COMPUTE FILTER COEFF. a2
kb      =       1+ka1+ka2           ; COMPUTE FILTER COEFF. b
ay1     nlfilt  axn/kb, (ka1+2*ka2)/kb, -ka2/kb, 0, 0, 1  ; USE THE NON-LINEAR FILTER
ay      nlfilt  ay1/kb, (ka1+2*ka2)/kb, -ka2/kb, 0, 0, 1  ; AS AN ORDINARY FILTER
ka1lp   =       1000/kfco-1         ; RESONANCE OF 1 IS A LOW PASS FILTER
ka2lp   =       100000/kfco/kfco
kblp    =       1+ka1lp+ka2lp
ay1lp   nlfilt  axn/kblp, (ka1lp+2*ka2lp)/kblp, -ka2lp/kblp, 0, 0, 1   ; LOW-PASS FILTER
aylp    nlfilt  ay1lp/kblp, (ka1lp+2*ka2lp)/kblp, -ka2lp/kblp, 0, 0, 1
ayrez   =       ay - aylp           ; ExtRACT THE RESONANCE PART
ayrz    =       ayrez/kfco          ; USE LOWER AMPLITUDES AT HIGHER FCO
ay2     =       aylp*6*ilpmix + ayrz*300*irzmix  ; SCALE THE LOW PASS AND RESONANCE SEPARATELY
       zaw      ay2, izout          ; WRITE TO THE OUTPUT CHANNEL
       endin
;---------------------------------------------------------------------------
; MIXER SECTION
;---------------------------------------------------------------------------
        instr   3099    
asig1   zar p4                      ; p4 = ch1 IN
igl1    init    p5*p6               ; p5 = ch1 GAIN
igr1    init    p5*(1-p6)           ; p6 = ch1 PAN
asig2   zar     p7                  ; p7 = ch2 IN
igl2    init    p8*p9               ; p8 = ch2 GAIN
igr2    init    p8*(1-p9)           ; p9 = ch2 PAN
asig3   zar     p10                 ; p10 = ch3 IN
igl3    init    p11*p12             ; p11 = ch3 GAIN
igr3    init    p11*(1-p12)         ; p12 = ch3 PAN
asig4   zar     p13                 ; p13 = ch4 IN
igl4    init    p14*p15             ; p14 = ch4 GAIN
igr4    init    p14*(1-p15)         ; p15 = ch4 PAN
asigl   =       asig1*igl1+asig2*igl2+asig3*igl3+asig4*igl4 
asigr   =       asig1*igr1+asig2*igr2+asig3*igr3+asig4*igr4 
        outs    asigl, asigr    
        zacl    0, 30   
        endin

</CsInstruments>
<CsScore>
;---------------------------------------------------------------------------
; PLUCK WITH HEAVY DISTORTION & RESONANT LOW-PASS FILTER
;---------------------------------------------------------------------------
i 3002  0.0  1.6  16000  7.00   0     1    1
i 3002  0.2  1.4  12000  7.05   .     .    .
i 3002  0.4  1.2  10400  8.00   .     .    .
i 3002  0.6  1.0  12000  8.05   .     .    .
i 3002  0.8  0.8  16000  7.00   .     .    .
i 3002  1.0  0.6  12000  7.05   .     .    .
i 3002  1.2  0.4  10400  8.00   .     .    .
i 3002  1.4  0.2  12000  8.05   .     .    .

; TUBE DISTORTION
f 5 0 8192 7 -.8 934 -.79 934 -.77 934 -.64 1034 -.48 520 .47 2300 .48 1536 .48

; TUBE AMP
;   STA  DUR  PREGAIN  POSTGAIN  DUTYOFFSET  SLOPESHIFT  INCH  OUTCH
i 3013 0    1.6  .5       1         1           1           1     2

; RESONANT LOW-PASS FILTER
; f3=Fco, f4=Rez
f 20 0 8192 -7 50 1024 300 1024 50 2048 300 4096 40
f 21 0 8192 -7 12 1024 10  1024 12  2048 10  4096 18

;   STA  DUR  TABLE1  TABLE2  LPMIX  RZMIX  INCH  OUTCH
i 3015 0    1.6  20      21      1      1.5    2     3

; MIXER
;    STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN
i 3099 0   2    3    1     1    3    1     0    3    0     1    4    0    0
</CsScore>
</CsoundSynthesizer>
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
