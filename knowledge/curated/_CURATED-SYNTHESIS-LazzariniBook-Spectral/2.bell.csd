<CsoundSynthesizer>
<CsInstruments>

; by Victor Lazzarini

0dbfs = 1

instr 1
 at = line:a(0,p3,1)
 out(oscili(p4*table:a(at,p6,1),p5))
endin

imin = .001
ifa = ftgen(0,0,16384,5,1,16384,imin)
idur[] fillarray 1,.9,.7,.6,.2,.1,.07,.05,.03,.01
ifr[] fillarray 120,95,97,176,250,300,610,755,933,1020
iamp[] fillarray 1,0.5,0.9,0.3,0.4,0.6,0.2,0.1,0.15,0.05
itot = 20
icnt = 0
insts = lenarray(idur)
while icnt < insts do
 schedule(1,0,idur[icnt]*itot,iamp[icnt]*0dbfs/insts,ifr[icnt],ifa)
 icnt+=1
od

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
