<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;------------------------------------------------------------------------
; TONE WHEEL ORGAN WITH ROTATING SPEAKER
;------------------------------------------------------------------------

;------------------------------------------------------------------------
; GLOBAL INITIALIZATION
;------------------------------------------------------------------------
          instr     1001      
gispeedf init  p4                       ; INITIALIZE ROTOR SPEED
          endin          
;------------------------------------------------------------------------
; THIS INSTRUMENT ACTS AS THE FOOT SWITCH CONTROLLING ROTOR SPEEDS.
;------------------------------------------------------------------------
          instr 1002          
gispeedi init  gispeedf            ; SAVE OLD SPEED
gispeedf init  p4                       ; UPDATE NEW SPEED
gkenv     linseg    gispeedi*.8, 1, gispeedf*.8, .01, gispeedf*.8
gkenvlow linseg     gispeedi*.7, 2, gispeedf*.7, .01, gispeedf*.7
          endin          
;------------------------------------------------------------------------
; TONE WHEEL ORGAN
;------------------------------------------------------------------------
          instr 1003          
gaorgan   init 0                        ; GLOBAL SEND TO SPEAKER
iphase    init p2                       ; CONTINUOUS PHASE CHANGE
ikey init 12*int(p5)+100*(p5%1)-59  ; KEYBOARD KEY PRESSED
ifqc init cpspch(p5)               ; CONVERT TO CYCLES/SEC.
iwheel1   init ((ikey-12) > 12 ? 1 : 2) ; LOWER 12 TONEWHEELS HAVE
iwheel2   init ((ikey+7)  > 12 ? 1 : 2) ; INCREASED ODD HARMONIC
iwheel3   init (ikey      > 12 ? 1 : 2) ; CONTENT.
iwheel4   init 1    
;------------------------------------------------------------------------
kenv linseg    0, .01, p4, p3-.02, p4, .01, 0
;------------------------------------------------------------------------
asubfund oscil p6, .5*ifqc, iwheel1, iphase/(ikey-12)
asub3rd   oscil     p7, 1.4983*ifqc, iwheel2, iphase/(ikey+7)
afund     oscil     p8, ifqc, iwheel3, iphase/ikey
a2nd oscil     p9, 2*ifqc, iwheel4, iphase/(ikey+12)
a3rd oscil     p10, 2.9966*ifqc, iwheel4, iphase/(ikey+19)
a4th oscil     p11, 4*ifqc, iwheel4, iphase/(ikey+24)
a5th oscil     p12, 5.0397*ifqc, iwheel4, iphase/(ikey+28)
a6th oscil     p13, 5.9932*ifqc, iwheel4, iphase/(ikey+31)
a8th oscil     p14, 8*ifqc, iwheel4, iphase/(ikey+36)
gaorgan =      gaorgan+kenv*(asubfund+asub3rd+afund+a2nd+a3rd+a4th+a5th+a6th+a8th)
          endin          
;------------------------------------------------------------------------
;ROTATING SPEAKER
;------------------------------------------------------------------------
          	instr     1004 
iioff     	init p4
isep		init p5                       ; PHASE SEPARATION BETWEEN RIGHT AND LEFT
iradius   	init .00025                   ; RADIUS OF THE ROTATING HORN.
iradlow   	init .00035              ; RADIUS OF THE ROTATING SCOOP.
ideleng   	init .02                 ; LENGTH OF DELAY LINE.
;------------------------------------------------------------------------
asig =         gaorgan                  ; GLOBAL INPUT FROM ORGAN
;------------------------------------------------------------------------
asig =         asig/40000          ; DISTORTION EFFECT USING WAVESHAPING.
aclip     tablei    asig, 5, 1, .5      ; A LAZY "S" CURVE, USE TABLE 6 ...
aclip     =         aclip*16000         ; ... FOR INCREASED DISTORTION.
;------------------------------------------------------------------------
aleslie   delayr    ideleng, 1               ; PUT "CLIPPED" SIGNAL
          
          
          
;------------------------------------------------------------------------
koscl     oscil     1, gkenv, 1, iioff  ; DOPPLER EFFECT IS RESULT
koscr     oscil     1, gkenv, 1, iioff+isep  ; OF DELAYTAPS OSCILLATING
kdopl     =         ideleng/2-koscl*iradius  ; LEFT AND RIGHT ARE
kdopr     =         ideleng/2-koscr*iradius  ; SLIGHT OUT OF PHASE TO
aleft     deltapi   kdopl                    ; SIMULATE SEPARATN BETWN
aright    deltapi   kdopr                    ; EARS OR MICROPHONES


;------------------------------------------------------------------------
koscllow oscil 1, gkenvlow, 1, iioff ; DOPPLER FOR LOW FRQ
koscrlow oscil 1, gkenvlow, 1, iioff+isep
kdopllow =          ideleng/2-koscllow*iradlow
kdoprlow =          ideleng/2-koscrlow*iradlow
aleftlow 	deltapi kdopllow     
arightlow deltapi kdoprlow    
delayw    aclip                    ; ClIPPED SIGNAL INTO A DELAY LINE.


;------------------------------------------------------------------------
alfhi     butterbp aleft, 8000, 3000    ; DIVIDE FREQ INTO THREE
arfhi     butterbp aright, 8000, 3000   ; GROUPS AND MOD EACH WITH
alfmid    butterbp aleft, 3000, 2000    ; DIFFERENT WIDTH PULSE TO
arfmid    butterbp aright, 3000, 2000   ; ACCOUNT FOR DIFFERENT
alflow    butterlp aleftlow, 1000       ; DISPERSION OF DIFFERENT
arflow    butterlp arightlow, 1000 ; FREQUENCIES.
kflohi    oscil     1, gkenv, 3, iioff  
kfrohi    oscil     1, gkenv, 3, iioff+isep  
kflomid   oscil     1, gkenv, 4, iioff  
kfromid   oscil     1, gkenv, 4, iioff+isep  
;------------------------------------------------------------------------
; AMPLITUDE EFFECT ON LOWER SPEAKER
kalosc    =         koscllow*.6+1  
karosc    =         koscrlow*.6+1  
;------------------------------------------------------------------------
; ADD ALL FREQUENCY RANGES AND OUTPUT THE RESULT.
          outs1     alfhi*kflohi+alfmid*kflomid+alflow*kalosc
          outs2     arfhi*kfrohi+arfmid*kfromid+arflow*karosc
gaorgan   =         0         
          endin

</CsInstruments>
<CsScore>
;------------------------------------------------------------------------
; SINE
f 1 0   8192    10  1 .02 .01
f 2 0   1024    10  1 0 .2 0 .1 0 .05 0 .02
;------------------------------------------------------------------------
; ROTATING SPEAKER FILTER ENVELOPES
f 3 0   256 7   .2 110 .4 18 1 18 .4 110 .2
f 4 0   256 7   .4 80 .6 16 1 64 1 16 .6 80 .4
;------------------------------------------------------------------------
; DISTORTION TABLES
f 5 0   8192    8   -.8 336 -.78 800 -.7 5920 .7 800 .78 336 .8
f 6 0   8192    8   -.8 336 -.76 3000 -.7 1520 .7 3000 .76 336 .8
;------------------------------------------------------------------------
t 0 200
;------------------------------------------------------------------------
; INITIALIZES GLOBAL VARIABLES
i 1001  0   1   1
;------------------------------------------------------------------------
; INS   STA DUR SPEED
i 1002  0   6   1
i 1002  +   6   10
i 1002  .   12  1
i 1002  .   6   10
;------------------------------------------------------------------------
; INS   STA DUR AMP PIT SUBF    SUB3    FUND    2ND 3RD 4TH 5TH 6TH 8TH
i 1003  0   6   200 8.04    8   8   8   8   3   2   1   0   4
i 1003  0   6   .   8.11    .   .   .   .   .   .   .   .   .
i 1003  0   6   .   9.02    .   .   .   .   .   .   .   .   .
i 1003  6   1   .   8.04    .   .   .   .   .   .   .   .   .
i 1003  6   1   .   8.11    .   .   .   .   .   .   .   .   .
i 1003  6   1   .   9.04    .   .   .   .   .   .   .   .   .
i 1003  7   1   .   8.04    .   .   .   .   .   .   .   .   .
i 1003  7   1   .   8.11    .   .   .   .   .   .   .   .   .
i 1003  7   1   .   9.02    .   .   .   .   .   .   .   .   .
i 1003  8   1   .   8.04    .   .   .   .   .   .   .   .   .
i 1003  8   1   .   8.09    .   .   .   .   .   .   .   .   .
i 1003  8   1   .   9.01    .   .   .   .   .   .   .   .   .
i 1003  9   8   .   8.04    .   .   .   .   .   .   .   .   .
i 1003  9   8   .   8.08    .   .   .   .   .   .   .   .   .
i 1003  9   8   .   8.11    .   .   .   .   .   .   .   .   .
i 1003  17  16  200 10.04   8   4   8   3   1   1   0   .   3
i 1003  20  13  200 9.09    8   4   8   3   1   1   0   .   3
i 1003  23  10  200 8.04    8   4   8   3   1   1   0   .   3
i 1003  26  7   200 7.04    8   4   8   3   1   1   0   .   3
;------------------------------------------------------------------------
;ROTATING SPEAKER
; INS   STA DUR OFFSET  SEPERATION
i 1004  0   33.2    .5  .1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
 <height>180</height>
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
