<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
          instr     1603 
ifenv     =         2                        ; BELL SETTINGS: AMP AND INDEX...
ifdyn     =         3                        ; ...ENVELOPES ARE EXPONENTIAL
ifq1      =         cpspch(p5)*5             ; DECREASING, N1:N2 IS 5:7,
if1       =         1                        ; DURATION = 15 sec
ifq2      =         cpspch(p5)*7   
if2       =         1    
imax      =         10   
aenv      oscili    p4, 1/p3, ifenv          ; ENVELOPE
adyn      oscili    ifq2*imax, 1/p3, ifdyn   ; DYNAMIC
amod      oscili    adyn, ifq2, if2          ; MODULATOR
acar      oscili    aenv, ifq1+amod, if1     ; CARRIER
          out       acar 
          endin


</CsInstruments>
<CsScore>
f 1 0 8192 10 1
f 2 0 1024 5 1 1024 .01
f 3 0 1024 5 1 1024 .001

i 1603 0  15  30000 5.09    
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
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
