<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   1204    ; PHASE MOD WITH MODULATOR STACK
; COMMON PARAMETERS:
isinefn =       1   
irisefn =       2                   ; EXPONENTIAL RISE
iparmfn =       p6                  ; NUMBER OF PARAMETER F-TABLE
idur    =       p3  
iamp    =       p4  
icps    =       cpspch(p5)          ; THEORETICAL FUNDAMENTAL
irise   table   0, iparmfn          ; MAIN ENVLP RISE TIME
idec    table   1, iparmfn          ; MAIN ENVLP DECAY TIME
icarfac table   2, iparmfn          ; CARRIER RATIO
im1fac  table   3, iparmfn          ; MODULATOR 1 RATIO
index1  table   4, iparmfn          ; MODULATOR 1 INDEX
im1rise table   5, iparmfn          ; MODULATOR 1 RISE
im1dur  table   6, iparmfn          ; MODULATOR 1 DUR
im1dec  table   7, iparmfn          ; MODULATOR 1 DECAY
im2fac  table   8, iparmfn          ; MODULATOR 2 RATIO
index2  table   9, iparmfn          ; MODULATOR 2 INDEX
im2rise table   10, iparmfn         ; MODULATOR 2 RISE
im2dur  table   11, iparmfn         ; MODULATOR 2 DUR
im2dec  table   12, iparmfn         ; MODULATOR 2 DECAY
i2pi    =       6.2832              ; USED TO COMPUTE PK DEVS
; PARAMETERS FOR INDIVIDUAL OPERATORS:
im1hz   =       icps*im1fac         ; COMPUTE MOD 1 FREQUENCY
im2hz   =       icps*im2fac         ; COMPUTE MOD 2 FREQUENCY
icarhz  =       icps*icarfac        ; COMPUTE CARRIER FREQUENCY
im1dev  =       index1/i2pi         ; CONVERT FROM RADIANS TO...
im2dev  =       index2/i2pi         ; ...NORMALIZED INDICES FOR TABLE
; USE DEFAULT OF p3 FOR mod1 AND mod2 ENVELOPE DURATIONS:
im1dur  =       (im1dur == 0 ? p3 : im1dur)
im2dur  =       (im2dur == 0 ? p3 : im2dur)
; COMPLEX MODULATION WITH STACKED MODULATORS
kmod1   envlpx  im1dev, im1rise, im1dur, im1dec, irisefn, 1, .01, 0
amod1   oscili  kmod1, im1hz, isinefn
aphs2   phasor  im2hz   
aphs2   =       aphs2+amod1         ; MODULATE THE PHASE OF mod2
amod2   tablei  aphs2, isinefn, 1, 0, 1
kmod2   envlpx  im2dev, im2rise, im2dur, im2dec, irisefn, 1, .01, 0
amod2   =       amod2*kmod2 
acarphs phasor  icarhz  
acarphs =       acarphs+amod2   
acarsig tablei  acarphs, isinefn, 1, 0, 1
kenv    envlpx  iamp, irise, idur, idec, irisefn, 1, .01, 0
asig    =       acarsig * kenv  
        out     asig    
        endin       

</CsInstruments>
<CsScore>
f 1 0   2048    10  1           ;SINE
f 2 0   513 5   .001    513 1   ;EXPONENTIAL RISE
 ;PARAMETER DATA:   RISE    DECAY   CARFAC  M1FAC   INDEX1  M1RIS   M1DUR
f 3 0   16  -2  .25 .5  1   1   5   .5  0
;   M1DEC   M2FAC   INDEX2  M2RIS   M2DUR   M2DEC               
    1   1   3   1   0   1               
;IN ST  DUR AMP PCH PARMS                   
i 1204  0   2   20000   7.07    3                   
i 1204  +   .   .   8.07                        
i 1204  +   .   .   9.07                        
i 1204  +   .   .   6.07                        
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
