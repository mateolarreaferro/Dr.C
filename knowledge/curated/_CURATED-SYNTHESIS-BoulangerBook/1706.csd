<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


          instr     1706 
ipkamp    =         p4                       ; INITIALIZATION BLOCK:
idurfn    =         p5                       ; THE POSSIBLE DURATIONS
ipchfn    =         p6                       ; THE POSSIBLE PITCHES
iampfn    =         p7                       ; AMP SCALING FUNCTION
iprise    =         p8                       ; PHRASE ENV RISE TIME
ipdec     =         p9                       ; PHRASE ENV DECAY TIME
inrise    =         p10                      ; INDIVIDUAL NOTE AMP RISE
indec     =         p11                      ; INDIVIDUAL NOTE AMP DECAY
iseed1    =         p12                      ; FOR DURATION RAND UNIT
iseed2    =         p13                      ; FOR PITCH RAND UNIT
iseed3    =         p14                      ; FOR PANNING RAND UNIT
ipkdur    =         .2501                    ; MAX EXPECTED DUR
                                             ; THE PHRASE ENVELOPE:
kphrase   expseg    .001, iprise, 1, p3-iprise-ipdec, 1, ipdec, .001
kdurloc   rand .5, iseed1                    ; GET RANDOM TABLE INDICES
kpchloc   rand .5, iseed2                    ; BETWEEN -.5 AND +.5
kpan      rand .5, iseed3          
noteinit:                                    ; START REINIT BLOCK
idurloc   =         .5+i(kdurloc)            ; MAKE POSITIVE i-time VAR
idur      table     idurloc, idurfn, 1       ; SELECT FROM DUR TABLE
iamp      table     idur/ipkdur, iampfn, 1   ; RELATE AMP TO DUR
iamp      =         .25+.75*iamp             ; AMP RANGE FROM .25 TO 1
ipchloc   =         .5+i(kpchloc)            ; MAKE A POSITIVE i-var
ipch      table     ipchloc, ipchfn, 1       ; SELECT FROM PCH TABLE
icps      =         (ipch==0?0:cpspch(ipch)) ; ALLOW FOR 0s (RESTS)
ilfac     =         i(kpan)+.5               ; MAKE POSITIVE
ileft     =         sqrt(ilfac)              ; "FILL THE HOLE...
iright    =         sqrt(1-ilfac)            ; ...BETWEEN THE SPEAKERS"
          if        (icps==0) goto rest      ; A TABLE VAL OF 0 = A REST
irise     =         inrise*idur              ; COMPUTE NOTE RISE TIME
idecay    =         indec*idur               ; COMPUTE NOTE DECAY TIME
isust     =         idur-irise-idecay        ; SUSTAIN PORTION
knote     expseg    .001, irise, 1, isust, 1, idecay, .001
asig      pluck     knote*iamp*ipkamp, icps, icps, 0, 1, 0, 0
asig      =         asig*kphrase             ; APPLY THE PHRASE ENVELOPE
          outs      asig*ileft, asig*iright  ; APPLY THE PANNING
rest:     timout    0, idur, exit            ; TIMOUT CAN BE ANYWHERE
          reinit    noteinit                 ; IN THE REINIT BLOCK
exit:     endin                              ; WHICH ENDS HERE

</CsInstruments>
<CsScore>


;PITCH FUNCTION 1 - A C MINOR 7 CHORD WITH OCTAVE DOUBLINGS
f 1 0   8   -2  6.00    6.07    7.00    7.07    
                8.00    8.03    8.07    8.10    
;AMP FACTOR FUNCTION (QUARTER SINE WAVE)
f 2 0   129 9   .25 1   0       
;DURATION FUNCTION 1 - JUST QUARTERS OR 8THS
f 3 0   2   -2  .25 .125            
;DURATION FUNCTION 2 - MOSTLY 8THS, SOME QUARTERS AND 16THS
f 4 0   8   -2  .25 .25 .125    .125    
                .125    .125    .0625   .0625   
;PITCH FUNCTION 2 - LOTS OF FS WITH SOME QUARTER AND 8TH-TONE DETUNINGS
;SOME RESTS, TOO.
f 5 0   32  -2  9.05    9.05    9.05    9.05    9.05
    10.05   10.05   10.05   8.05    8.05    9.055   9.055   10.055
    9.045   9.  .045    8.055   8.055   10.055  10.055  9.0525
    9.0525  9.0525  9.0475  9.0475  9.0475          
;PITCH FUNCTION 3 - LOW EBS AND FBS, AN OCCASIONAL BB OR REST
f 6 0   8   -2  7.03    7.03    7.03    7.03    
                7.05    7.05    6.10        
                                
;DUR FUNCTION 3 - ONLY 3 CHOICES: TWO THIRDS 16THS, ONE THIRD 8TH NOTES
f 7 0   4   -2  .0625   .0625   .125        
                                

;GENERATE A SHORT COMPOSITION USING TABLES FOR PITCHES AND DURATIONS

;TWO PRIMARY VOICES FOR THE BASIC RHYTHM TRACK
;         ST   DUR   PKAMP   DURFN   PCHFN   AMPFN     RISE    DECAY
i 1706    0    40    16000   3       1       2         .001    3
;   NOTE ENVLP FACS RANDOM SEED VALUES          
;   RISE    DECAY   DUR  PCH  PAN         
    .001    .1      .030251 .071983 .022186    
         
;         ST     DUR     PKAMP   DURFN   PCHFN   AMPFN   RISE    DECAY
i 1706    2      38      16000   3       1       2      .001        3
;   NOTE ENVLP FACS RANDOM SEED VALUES          
;   RISE    DECAY   DUR  PCH  PAN         
    .001    .1      .070703 .012719 .081447  
           
;SOLO VOICE WITH SOME QUARTER-TONES AND SHORTER DURATIONS AFTER 12 BEATS
;       ST  DUR PKAMP     DURFN   PCHFN   AMPFN   RISE    DECAY
i 1706  12  12  20000     4        5      2       2       3
;   NOTE ENVLP FACS RANDOM SEED VALUES          
;   RISE    DECAY   DUR  PCH  PAN         
    .001    .1      .010149 .100153 .012345
             
;SECOND, FASTER SOLO WITH LOWER PITCHES AT 25.125 BEATS
;         ST   DUR       PKAMP   DURFN   PCHFN   AMPFN   RISE    DECAY
i 1706  25.125  10       16000   7       6       2       2       3

;   NOTE ENVLP FACS RANDOM SEED VALUES          
;   RISE    DECAY   DUR  PCH  PAN         
    .001    .1      .030251 .071983 .022186         
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>8</height>
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
