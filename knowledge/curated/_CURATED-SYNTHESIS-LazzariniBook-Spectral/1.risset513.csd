<CsoundSynthesizer>
<CsInstruments>
; by Victor Lazzarini

0dbfs = 1

ioct = -10
ifa = ftgen(0,0,16384,20,6,1,0.8)
iff = ftgen(0,0,16384,-5,1,16384,2^(-ioct))

instr 1
 at = line:a(0,p3,1)+p8
 out(oscili(p4*tablei:a(at,p6,1,0,1),
            p5*tablei:a(at,p7,1,0,1)))
endin

instr 2
 a1 = oscili(p4,1/p3,p6,p8)
 a2 = oscili(p5,1/p3,p7,p8)
 out(oscili(a1,a2))
endin

idur = 120
ifmx = 10
icnt = 0
insts = abs(ioct)
while icnt < insts do
 schedule(1,0,idur,0dbfs/2,ifmx,ifa,iff,icnt/insts)
 icnt+=1
od

</CsInstruments>
</CsoundSynthesizer>






<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>99</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
