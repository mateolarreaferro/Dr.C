<CsoundSynthesizer>
<CsInstruments>

0dbfs = 1

seed 0

  instr 1
   idur = 20
   iamp=ampdbfs(p4)/p6
   ifreq=cpsmidinn(p5)*p6
    if ifreq<=sr/4 then
     iatt=p6*0.005
     ka = expseg:k(0.001,iatt,iamp,
                   p3-iatt,0.001)
     kf = expseg:k(ifreq*(1+birnd(.3)),p3,ifreq*(1+birnd(.5)))
     asig=oscili(ka,kf)
     out(asig)
     schedule(1,rnd(.05),rnd(idur),p4,p5,p6+(1+sqrt(5))/2)
    endif
  endin 
  schedule(1,0,20,-6,60,1)
  
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
