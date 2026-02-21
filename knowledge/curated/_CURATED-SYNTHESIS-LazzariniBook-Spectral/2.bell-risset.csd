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
idur[] fillarray 20,18,13,11,6.5,7,5,4,3,2,1,1.5
ifr[] fillarray  224,225,368,369.7,476,680,800,1096,1200,1504,1628
iamp[] fillarray 150,100,150,270,400,250,220,200,200,150,200
iscal = 2000 // amp scaling
itot = 20
icnt = 0
insts = lenarray(idur)
while icnt < insts do
 schedule(1,0,idur[icnt],iamp[icnt]*0dbfs/iscal,ifr[icnt],ifa)
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
