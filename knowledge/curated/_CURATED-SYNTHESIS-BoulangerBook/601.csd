<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr      =      	44100
kr    	=     	4410
ksmps  	=     	10
nchnls	=		1

        instr   601     
iatt    =       p3*.1                   ; ATTACK IS 10% OF DURATION
idec    =       p3*.1                   ; DECAY IS 10% OF DURATION
ifc1    =       200                     ; Fc OF RESON 1
iq1     =       5                       ; Q OF RESON 1
ifc2    =       550                     ; Fc OF RESON 2
iq2     =       3                       ; Q OF RESON 2
kenv    linen   p4, iatt, p3, idec      ; AMPLITUDE ENVELOPE
asig    oscil   kenv, cpspch(p5), p6    ; OSCILLATOR
ares1   reson   asig, ifc1, ifc1/iq1    ; RESON1 - BANDWIDTH = Fc/Q
ares2   reson   asig, ifc2, ifc2/iq2    ; RESON2 - BANDWIDTH = Fc/Q
areso   =       ares1+ares2             ; ADD FILTERED SIGNALS
aout    balance areso, asig             ; BALANCE AGAINST ORIGINAL
        out     aout    
        endin       

</CsInstruments>
<CsScore>
;------------------------------------------------------------
;  example1.sco
;------------------------------------------------------------
f1 0 8192 10 1  ; SINE WAVE
f2 0 8192 10 1 1 1 1 1 1 1 1 1 1; QUASI SQUARE WAVE
;------------------------------------------------------------
;  ST   DUR AMP     PCH     FT
;------------------------------------------------------------
i 601   0   .3  20000   6.00    2
i 601   +   .   .       6.02    .
i 601   +   .   .       6.04    .
i 601   +   .   .       6.05    .
i 601   +   .   .       6.07    .
i 601   +   .   .       6.09    .
i 601   +   .   .       6.11    .
i 601   +   .   .       7.00    .
i 601   +   .   .       7.02    .
i 601   +   .   .       7.04    .
i 601   +   .   .       7.05    .
i 601   +   .   .       7.07    .
i 601   +   .   .       7.09    .
i 601   +   .   .       7.11    .
i 601   +   .   .       8.00    .
i 601   +   .   .       8.02    .
i 601   +   .   .       8.04    .
i 601   +   .   .       8.05    .
i 601   +   .   .       8.07    .
i 601   +   .   .       8.09    .
i 601   +   .   .       8.11    .
i 601   +   .   .       9.00    .
i 601   +   .   .       9.02    .
i 601   +   .   .       9.04    .
i 601   +   .   .       9.05    .
i 601   +   .   .       9.07    .
i 601   +   .   .       9.09    .
i 601   +   .   .       9.11    .
i 601   +   .   .       10.00   .
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
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
