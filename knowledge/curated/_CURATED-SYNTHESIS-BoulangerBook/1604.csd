<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1604 
idur      =         p3   
iamp      =         p4   
ifenv     =         2                        ; BELL SETTINGS:
ifdyn     =         3                        ; AMP AND INDEX ENV ARE EXPONENTIAL
ifq1      =         cpsoct(p5)*5             ; DECREASING, N1:N2 IS 5:7, imax=10
if1       =         1                        ; DURATION = 15 sec
ifq2      =         cpsoct(p5)*7   
if2       =         1    
imax      =         10   
aenv      oscili    iamp, 1/idur, ifenv      ; ENVELOPE
adyn      oscili    ifq2*imax, 1/idur, ifdyn ; DYNAMIC
anoise    rand      100  
amod      oscili    adyn+anoise, ifq2, if2   ; MODULATOR
acar      oscili    aenv, ifq1+amod, if1     ; CARRIER
          timout    0.5, idur, noisend
knenv     linseg    iamp, 0.2, iamp, 0.3, 0
anoise3   rand      knenv
anoise4   butterbp  anoise3, iamp, 100
anoise5   balance   anoise4, anoise3
noisend:       
arvb      nreverb   acar, 2, 0.1
amix      =         acar+anoise5+arvb
          out       amix
          endin

</CsInstruments>
<CsScore>
f 1 0 8192 10 1
f 2 0 1024 5 1 1024 .01
f 3 0 1024 5 1 1024 .001

i 1604 0  15  5000 5.09 
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
