<CsoundSynthesizer>
<CsInstruments>
opcode PmOp,a,kkaiiiij
 kmp,kfr,apm,
    iatt,idec,
    isus,irel,ifn xin
 aph phasor kfr
 a1  tablei aph+apm/(2*$M_PI),ifn,1,0,1
 a2  madsr iatt,idec,isus,irel
     xout  a2*a1*kmp
endop
instr 1
 amod PmOp p6,p5,a(0),0.1,0.1,0.5,0.1
 acar PmOp p4,p5,amod,0.01,0.1,0.9,0.1
     out acar
endin
schedule(1,0,1,0dbfs/2,440,7)
</CsInstruments>
<CsScore>
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
