<CsoundSynthesizer> 
<CsOptions>
</CsOptions>
<CsInstruments> 

0dbfs  = 1

connect "bend", "bendout", "guitar", "bendin" 

instr bend 

kbend line p4, p3, p5 

;printk2 kbend
      outletk "bendout", kbend 

endin 

instr guitar 

kbend inletk "bendin" 
kpch pow 2, kbend/12
asig oscili .4, p4*kpch, 1 
     outs asig, asig
endin 

</CsInstruments> 
<CsScore> 
f1 0 1024 10 1 0 1 0 1 0 1

i"guitar" 0  5   440
i"bend"   2 1.2 -12 12 
i"bend"   4 .2  -17 40 
e
</CsScore> 


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
