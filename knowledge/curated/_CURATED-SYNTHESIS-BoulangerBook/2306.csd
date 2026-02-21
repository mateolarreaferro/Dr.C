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
          outs      anoise*idryamt,anoise*idryamt
          endin

          instr     2306
irevtime  =         p4
adelayline delayr   0.2
amtap1    deltap    0.0430
amtap2    deltap    0.0320
amtap3    deltap    0.1458
amtap4    deltap    0.1423
amtap5    deltap    0.0103
amtap6    deltap    0.0239
amtap7    deltap    0.0446
amtap8    deltap    0.1035
amtap9    deltap    0.1067
amtap10   deltap    0.0087
amtap11   deltap    0.0837
amtap12   deltap    0.1676
          delayw    gadrysig
adiffleft =         amtap1+amtap2+amtap3+amtap4+amtap5+amtap6
adiffright =        amtap7+amtap8+amtap9+amtap10+amtap11+amtap12
arevleft  reverb    adiffleft,irevtime
arevright reverb    adiffright,irevtime
alfo1     oscili    .02, .342, 1
alfo2     oscili    .02, .337, 1, .33
alfo1     =         alfo1+0.025
alfo2     =         alfo2+0.025
achn1dll  delayr    .05
amvleft   deltapi   alfo1
          delayw    arevleft
achn2dll  delayr    .05
amvright  deltapi   alfo2
          delayw    arevright
          outs      amvleft/6, amvright/6
gadrysig  =         0
          endin      
    

</CsInstruments>
<CsScore>
f 1 0 8192 10 1

; INS   ST  DUR REVERB_AMT
i 2303  0   .2  .6
i 2303  2   .2  .5
i 2303  4   .2  .4
i 2303  6   .2  .3

; INS   ST  DUR RT60
i 2306  0   10  2.2 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>8</width>
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
