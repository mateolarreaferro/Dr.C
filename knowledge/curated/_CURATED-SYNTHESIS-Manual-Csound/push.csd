<CsoundSynthesizer> 
<CsOptions>
</CsOptions> 
<CsInstruments> 
 
0dbfs  = 1 

stack 100000 

instr 1 

a1	oscils 0.7, 220, 0 
k1	line 0, p3, 1 
        push "blah", 123.45, a1, k1 
        push rnd(k1) 

k_rnd	pop 
S01, i01, a01, k01 pop 
        printf_i "S01 = '%s', i01 = %g\n", 1, S01, i01 
ktrig	metro 5.0 
        printf "k01 = %.3f, k_rnd = %.3f\n", ktrig, k01, k_rnd 
        outs a01, a01 

endin 
</CsInstruments> 
<CsScore> 

i 1 0 5 
e 
</CsScore> 
</CsoundSynthesizer> 
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
