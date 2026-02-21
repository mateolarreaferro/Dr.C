<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;; PURE SINE WAVE AT 333Hz WITH DECLICKING
        instr   307
aenv    linseg  1,p3-.05,1,.05,0,.01,0
a1      oscili  p4, 333, 1
        outs    a1*aenv,a1*aenv
        endin

;; WHITE NOISE AT 333Hz WITH DECLICKING
        instr   308
kband   line    p5, p3, p6
aenv    linseg  1,p3-.05,1,.05,0,.01,0
a1      rand    p4
a2      butterbp a1, 333, kband
        outs    a2*aenv,a2*aenv
        endin

;; IMPURE SINE WAVE AT 333Hz WITH DECLICKING
        instr   309
k1      gauss   p5
k2      gauss   p6
aenv    linseg  1,p3-.05,1,.05,0,.01,0
a1      oscili  p4/2, 333, 1
a2      oscili  p4/2, 333+k1, 1
a3      oscili  p4/2, 333+k2, 1
        outs    (a1+a2)*aenv,(a1+a3)*aenv
        endin

;; PITCHED DRUM
        instr   310
idur    =       p3
iamp7   =       p4
iamp2   =       p4 * .8
iamp4   =       p4 * .3

a5      randi   p4, 1500
a5      oscili  a5, 1/idur, 52
a5      oscili  a5, 4000, 1
    
a3      oscili  iamp4, 1/idur, 52
a3      oscili  a3, 33.1, 11

a1      oscili  iamp2, 1/idur, 51
a1      oscili  a1,    333, 1

        outs    a1+a3+a5,a1+a3+a5
        endin

</CsInstruments>
<CsScore>
f 1 0 16384 10 1    
f 11  0   512   9  10 1  0  16  1.5  0  22  2  0  23  1.5  0
; ENVELOPES
f 51  0   513   5   256  512  1
f 52  0   513   5  4096  512  1

i 308   0   10  10000   333 0
i 309   1   10   5000   33  33
i 307   2   10   5000
i 309   3   10   5000   17.5    17.5
i 309   4   10   33 
i 310   5   0.3  2000
i 310   5   0.1  2000
i 310   +   .    <
i 310   +   .    .
i 310   +   .    .
i 310   +   .    .
i 310   +   .    .
i 310   +   .    9000
i 310   7   0.1 10000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
 <height>210</height>
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
