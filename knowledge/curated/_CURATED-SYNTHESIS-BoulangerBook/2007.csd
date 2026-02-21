<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     2007                          ; DIRECT IMPLEMENTATION TEST
iharm     =         int(44100/(p4)/2)-1           ; AVOID PROBLEMS WITH DELAYS
abuzz     linseg    0,0.45*p3,0,0.1*p3,10000,0.44*p3,10000,0.01*p3,0,1,0
aran      linseg    0, 0.01*p3, 10000, 0.44*p3, 10000, 0.1*p3, 0, 1, 0
a2        buzz      abuzz, p4, iharm, 1, -1
a3        trirand   1
a4        =         a2+a3*aran
a5        reson     a4, sr/100, sr/5000           ; SAME SETTINGS AS TEST IMPULSE
a6        balance   a5, abuzz+aran
          out       a6
          display   a6, p3/5                      ; DISPLAY IMPULSE RESPONSE
          dispfft   a6, p3/5, 4096, 0, 1          ; DISPLAY FREQUENCY RESPONSE
          endin

          instr     2008                          ; CONVOLUTION TEST
iharm     =         int(44100/(p4)/2)-1
abuzz     linseg    0,0.45*p3,0,0.1*p3,10000,0.44*p3,10000,0.01*p3,0,1,0
aran      linseg    0, 0.01*p3, 10000, 0.44*p3, 10000, 0.1*p3, 0, 1, 0
ahalt     linseg    0, 8192/44100, 0, 0.001, 1, p3, 1
a2        buzz      abuzz, p4,iharm, 1, -1
a3        trirand   1
a4        =         (a2+a3*aran)/1.1
a5        convolve  a4, "reson_10_5000.con"      ; USE CVANAL TO MAKE
adely     delay     abuzz+aran, 8192/sr
a6        balance   a5, adely*.8
          out       a6
          display   a6, p3/5                      ; DISPLAY IMPULSE RESPONSE
          dispfft   a6, p3/5, 4096, 0, 1          ; DISPLAY FREQUENCY RESPONSE
          endin

</CsInstruments>
<CsScore>


f 1 0   16384   10  1   ; SINE TABLE

i 2007  0   6   110.25
i 2008  6   6   110.25

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>61</y>
 <width>396</width>
 <height>640</height>
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
