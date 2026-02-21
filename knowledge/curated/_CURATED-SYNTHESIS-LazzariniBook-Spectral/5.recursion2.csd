<CsoundSynthesizer>
<CsInstruments>

; by Victor Lazzarini

0dbfs = 1

seed 0
gir = (1+sqrt(5))/2 // golden ratio
icf = 4000      // scale centre
instr 1
 idur=5     // max dur
 ist=.01    // min start time
 istep=floor(birnd(28))
 iff=gir^(istep/9)
 print(istep)
 iamp=p4
 ifreq=p5*iff
 iatt=rnd(0.05)
 ka=expseg:k(0.001,iatt,iamp,
                   p3-iatt,0.001)
 kf=expseg:k(ifreq,iatt,ifreq,p3-iatt,
                 ifreq*(1+birnd(.2)))
 asig=oscili(ka,kf)
 out(asig)
 schedule(1,ist+rnd(ist),rnd(idur),rnd(0.1),p5)
endin
schedule(1,0,5,0.1,icf)

</CsInstruments>
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
