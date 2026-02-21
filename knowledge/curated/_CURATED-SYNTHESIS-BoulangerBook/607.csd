<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr    607        
iampi   =       p4                  ; AMPLITUDE INDEX (0-96)
iocti   =       octpch(p5)*10       ; OCTAVE INDEX (0-120)
iampa   table   iampi, 90           ; f90 = Fn FOR AMP ATK
iampd   table   iampi, 91           ; f91 = Fn FOR AMP DECAY
iocta   table   iocti, 92           ; f92 = Fn FOR OCTAVE ATTACK
ioctd   table   iocti, 93           ; f93 = Fn FOR OCTAVE DECAY
iattack =       iampa*iocta*p7      ; p7 = ATTACK LENGTH
idecay  =       iampd*ioctd*p8      ; p8 = DECAY LENGTH
; SET TOTAL DURATION TO LENGTH OF NOTE + DECAY VALUE
; IF ATTACK IS LONGER THAN p3, THEN SET TOTAL DURATION TO ATTACK + DECAY 
idur    =       (iattack>p3 ? iattack+idecay : p3+idecay)
p3      =       idur    
imodf   table   p4, 94              ; f94 IS Fn FOR MOD SCALER
imodind =       imodf*p9            ; p9 IS MODULATION INDEX
kenv    linen   ampdb(p4), iattack, idur, idecay
kmodenv linen   imodind, iattack, idur, idecay
asig    foscil  kenv, cpspch(p5), 1, 1, kmodenv, p6
        out     asig    
        endin       

</CsInstruments>
<CsScore>
;------------------------------------------------------------
;  607.sco
;------------------------------------------------------------
f1 0 128 10 1   ; SINE WAVE
; AMP ATTACK FACTOR
f90 0 128 -5 2 60 2 15 1.25 5 .75 5 .6 5 .45 38 .45
; AMP DECAY FACTOR
f91 0 128 -5 .5 60 .5 15 .7 5 1 5 1.2 5 1.75 38 1.75
; OCT ATTACK FACTOR
f92 0 128 -7 2 60 2 15 1.5 5 1 10 1 38 .25
; OCT DECAY FACTOR
f93 0 128 -7 1.5 50 1.5 25 1 15 1 38 .5
; MOD INDEX SCALER
f94 0 128 -5 .5 60 .5 15 .7 5 1 5 1.5 5 2.25 38 3
;------------------------------------------------------------
;  TEST ACROSS PITCH AT HIGH AMPLITUDE
;------------------------------------------------------------
;  ST DUR AMP PCH   FT  ATT DEC MODINDEX
;------------------------------------------------------------
i 607 0 .5   85  6.00   1   .2  .2  1
i 607 + .    .   6.03
i 607 + .    .   6.06
i 607 + .    .   6.09
i 607 + .    .   7.00
i 607 + .    .   7.03
i 607 + .    .   7.06
i 607 + .    .   7.09
i 607 + .    .   8.00
i 607 + .    .   8.03
i 607 + .    .   8.06
i 607 + .    .   8.09
i 607 + .    .   9.00
i 607 + .    .   9.03
i 607 + . . 9.06
i 607 + . . 9.09
i 607 + . . 10.00

s   ;; TEST ACROSS PITCH AT MODERATE AMPLITUDE
i 607 0 .5 75  6.00    1   .2  .2  1
i 607 + . 	. 	6.03
i 607 + . 	. 	6.06
i 607 + . 	. 	6.09
i 607 + . 	. 	7.00
i 607 + . 	. 	7.03
i 607 + . 	. 	7.06
i 607 + . 	. 	7.09
i 607 + . 	. 	8.00
i 607 + . 	. 	8.03
i 607 + . 	. 	8.06
i 607 + . 	. 	8.09
i 607 + . 	. 	9.00
i 607 + . 	. 	9.03
i 607 + . 	. 	9.06
i 607 + . 	. 	9.09
i 607 + . 	. 	10.00

s   ;; TEST ACROSS PITCH AT LOW AMPLITUDE
i 607 0 .5 60   6.00    1   .2  .2  1
i 607 + . . 6.03
i 607 + . . 6.06
i 607 + . . 6.09
i 607 + . . 7.00
i 607 + . . 7.03
i 607 + . . 7.06
i 607 + . . 7.09
i 607 + . . 8.00
i 607 + . . 8.03
i 607 + . . 8.06
i 607 + . . 8.09
i 607 + . . 9.00
i 607 + . . 9.03
i 607 + . . 9.06
i 607 + . . 9.09
i 607 + . . 10.00


s   ;; TEST ACROSS AMPLITUDE AT LOW PITCH
i 607 0 .5 40   6.00    1   .2  .2  1
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . 85

s   ;; TEST ACROSS AMPLITUDE AT MIDDLE PITCH
i 607 0 .5 40   8.00    1   .2  .2  1
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . 85

s   ;; TEST ACROSS AMPLITUDE AT MIDDLE PITCH
i 607 0 .5 40   10.00   1   .2  .2  1
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . <
i 607 + . 85
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
