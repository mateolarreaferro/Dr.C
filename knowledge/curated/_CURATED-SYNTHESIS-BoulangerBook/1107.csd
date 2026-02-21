<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>



;--------------------------------------------------------------------
        instr 1107
;---------------------------------------; PARAMETER LIST
;p4  : AMPLITUDE
;p5  : FREQUENCY OF FUNDAMENTAL
;p6  : ATTACK
;p7  : DECAY
;p8  : MINIMUM FREQUENCY OF RANDI
;p9  : MAXIMUM FREQUENCY OF RANDI
;---------------------------------------; GENERAL INITIALIZATION BLOCK
idur    =       p3                      ; DURATION
iamp    =       p4                      ; AMPLITUDE
iatt    =       p6                      ; ATTACK
idec    =       p7                      ; DECAY
;---------------------------------------; PULSE INITIALIZATION
ifreq   =       p5                      ; FREQUENCY OF FUNDAMENTAL
iffl    =       p5/5                    ; MAXIMUM FREQUENCY FLUCTUATION
iinh     =       int(sr/2/(p5+iffl))    ; MAXIMUM NUMBER OF HARMONICS
iplfunc =       1                       ; FUNCTION TABLE FOR BUZZ
;---------------------------------------; INIT. of RANDOM NUMBER GENERATORS
irfmin  =       p8                      ; MINIMUM FREQUENCY OF randi
irfl    =       p9-p8                   ; FREQUENCY FLUCTUATION OF randi
irfunc  =       2                       ; RANDOM GENERATION SPEED FLUCTUATION 
                                        ; FUNCTION. ALSO USED FOR       
                                        ; FUNDAMENTAL FREQUENCY FLUCTUATION.
;---------------------------------------; FIRST FORMANT
if1cf   =       500                     ; CENTER FREQUENCY
if1cff  =       100                     ; CENTER FREQUENCY FLUCTUATION
if1bw   =       30                      ; BANDWITH
;---------------------------------------; SECOND FORMANT
if2cf   =       1000                    ; CENTER FREQUENCY
if2cff  =       200                     ; CENTER FREQUENCY FLUCTUATION
if2bw   =       40                      ; BANDWITH
;---------------------------------------; THIRD FORMANT
if3cf   =       2000                    ; CENTER FREQUENCY
if3cff  =       300                     ; CENTER FREQUENCY FLUCTUATION
if3bw   =       80                      ; BANDWITH
;---------------------------------------; FOURTH FORMANT
if4cf   =       3500                    ; CENTER FREQUENCY
if4cff  =       500                     ; CENTER FREQUENCY FLUCTUATION
if4bw   =       200                     ; BANDWITH
;---------------------------------------; FIFTH FORMANT
if5cf   =       4800                    ; CENTER FREQUENCY
if5cff  =       800                     ; CENTER FREQUENCY FLUCTUATION
if5bw   =       400                     ; BANDWITH
;---------------------------------------; OVERALL ENVELOPE
kenv    linen   iamp,iatt,idur,idec      
;---------------------------------------; RANDOM NUMBER GENERATORS
krand   oscil1i 0,.5,idur,irfunc        ; OSCIL BETWEEN -.5 AND .5
krand   =       krand + .5              ; CORRECT BETWEEN 0 AND 1
krfl    =       irfmin+irfl*krand       ; FREQUENCY of RANDOM GENERATORS
k1      randi   1,krfl,.12              ; RANDOM GENERATOR 
k2      randi   1,krfl,.23              ; FOR EACH FILTER,
k3      randi   1,krfl,.34              ; EACH WITH A 
k4      randi   1,krfl,.45              ; DIFFERENT SEED
k5      randi   1,krfl,.56               
;---------------------------------------; SEQUENCE of PULSES
kfrnd   =       ifreq+iffl*krand        ; FREQUENCY FLUCTUATION
apulse  buzz    1,kfrnd,iinh,iplfunc    ; PULSE GENERATOR
;-------------------------------------------------------; FORMANT FILTERS
afilt1  reson   apulse,if1cf+k1*if1cff,if1bw*(1+k1),0
afilt2  reson   apulse,if2cf+k2*if2cff,if2bw*(1+k2),0
afilt3  reson   apulse,if3cf+k3*if3cff,if3bw*(1+k3),0
afilt4  reson   apulse,if4cf+k4*if4cff,if4bw*(1+k4),0
afilt5  reson   apulse,if5cf+k5*if5cff,if5bw*(1+k5),0
afilt   =       afilt1+afilt2+afilt3+afilt4+afilt5      ; MIX FILTER OUTPUTS
;---------------------------------------; BALANCE
abal    oscil   1,ifreq,iplfunc         ; SINE WAVE CONTROL SIGNAL
aout    balance afilt,abal              ; OUTPUT BALANCE
;---------------------------------------; OUTPUT
        out     kenv*aout 
        endin

</CsInstruments>
<CsScore>

;1107.SCO   SIMULATION OF VOCAL SOUND 
;             (C) RAJMIL FISCHMAN, 1997
;---------------------------------------
;SINEWAVE FOR PULSE GENERATION
f 1 0 4096 10 1
;PITCH/RANDOM NUMBER FREQUENCY FLUCTUATION FUNCTION
f 2 0 512  7  0 50 .6 50 .8 50 .3 50 .7 50 .9 50 .4 50 .1 50 .01 62 .2
;----------------------------------------------------
;            p3   p4     p5    p6     p7    p8   p9
;INSTR START DUR  AMP    FUND  ATTACK DECAY MINR MAX
;                        FREQ               RAND RAND
;                                           FREQ FREQ 
;----------------------------------------------------
;SINGLE SHORT SOUND
i 1107     0     .5   5000   70    .1     .1    10   15
;MIX
i 1107     1     5    2500   490   4      .5    40   45
i 1107     1     5    2500   615   4      .5    40   45
i 1107     3.5   7    2500   60    .5     1.5   3    50

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
