<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gadrysig  init      0        ; INITIALIZE GLOBAL VARIABLE



          instr     2303
iwetamt   =         p4
idryamt   =         1-p4
kenv      linseg    19000, .1, 1000, p3-.1, 0
anoise    randi     kenv, sr/2, .5
gadrysig  =         gadrysig + anoise*iwetamt
          out       anoise*idryamt
          endin

          instr     2304
irevtime  =         p4
areverb   reverb    gadrysig, irevtime
          out       areverb+gadrysig
gadrysig  =         0
          endin

</CsInstruments>
<CsScore>



; INS   ST  DUR REVERB_AMT
i 2303  0   .2  0
i 2303  2   .2  .1
i 2303  4   .2  .25
i 2303  6   .2  .5
; INS   ST  DUR RT60
i 2304  0   1.5 1.3 
i 2304  2   1.5 1.3 
i 2304  4   1.5 1.3 
i 2304  6   1.5 1.3 

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
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
