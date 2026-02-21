<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


          instr     2204                     ; VDELAY VIBRATO
icps      =         cpspch(p5)               ; BASIC PITCH
ilfohz    =         p6                       ; LFO RATE IN CPS
idelfac   =         p7                       ; BETWEEN 0 & .999
imaxdel   =         p8                       ; MAX DELAY IN SECS
ilfoamp   =         idelfac*imaxdel/2        ; LFO FN IS +/- 1
kgate     linen     p4, .1,p3, .2            ; BASIC NOTE ENVLP
avarydel  oscili    ilfoamp, ilfohz, 1       ; FN1 IS LFO WAVE
asig      oscili    kgate, icps, 2           ; FN2 IS OSC WAVE
adelay    =         imaxdel/2+avarydel       ; OFFSET TO .5 MAX
aout      vdelay    asig, adelay, imaxdel    ; VARYING DELAY
          outs      aout, aout
          endin

</CsInstruments>
<CsScore>
; LFO WAVE IS A SINE
f 1 0   512 10  1               
;OSCIL WAVE
f 2 0   512 10  1   .5  .3  .2  .1
; LFO DEPTH FACTOR IS .9, GRADUALLY INCREASE MAX DELAY TIME
; INS   ST  DUR AMP PCH LFOHZ   DEPTH   MAXDLT  
i 2204  0   3   20000   8.00    5   .9  1   
i 2204  +   .   .   .   .   .   2   .   <
i 2204  +   .   .   .   .   .   3   .	.
i 2204  +   .   .   .   .   .   4   .	6
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
