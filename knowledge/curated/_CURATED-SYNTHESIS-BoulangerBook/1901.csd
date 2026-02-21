<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; BASS PHYSICAL MODEL

          instr     1901

; INITIALIZATIONS
ifqc      =         cpspch(p5)
ipluck    =         1/ifqc*p6
kcount    init      0
adline    init      0
ablock2   init      0
ablock3   init      0

afiltr    init      0
afeedbk   init      0

koutenv   linseg    0,.01,1,p3-.11,1,.1,0 ; OUTPUT ENVELOPE
kfltenv   linseg    0, 1.5, 1, 1.5, 0 

; THIS ENVELOPE LOADS THE STRING WITH A TRIANGLE WAVE
kenvstr   linseg    0,ipluck/4,-p4/2,ipluck/2,p4/2,ipluck/4,0,p3-ipluck,0

aenvstr   =         kenvstr
ainput    tone      aenvstr,200

; DC BLOCKER
ablock2   =         afeedbk-ablock3+.99*ablock2
ablock3   =         afeedbk
ablock    =         ablock2

; DELAY LINE WITH FILTERED FEEDBACK
adline    delay     ablock+ainput,1/ifqc-15/sr
afiltr    tone      adline,400

; RESONANCE OF THE BODY 
abody1    reson     afiltr, 110, 40
abody1    =         abody1/5000
abody2    reson     afiltr, 70, 20
abody2    =         abody2/50000

afeedbk   =         afiltr

aout      =         afeedbk
          out       50*koutenv*(aout + kfltenv*(abody1 + abody2))

          endin

</CsInstruments>
<CsScore>
r 3 NN
t 0 600
; PLUCKED BASS
;  START DUR    AMP        PITCH  PLUCKDUR
i 1901   0   4    1900        6.00     .25
i 1901  +    2    1900        6.01     .25
i 1901  .    4    1900        6.05     .5
i 1901  .    2    900        6.04     1
i 1901  .    4    1900        6.03     .5
i 1901  .   16    1900        6.00     .5
e
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
