ioct = 10
ifa = ftgen(0,0,16384,20,6,1,0.8)
iff = ftgen(0,0,16384,-5,1,16384,2^(-ioct))

instr 1
 at = line:a(0,p3,1)+p8
 out(oscili(p4*tablei:a(at,p6,1,0,1),
            p5*tablei:a(at,p7,1,0,1)))
endin

idur = 120
ifmx = 6000
icnt = 0
insts = abs(ioct)
while icnt < insts do
 schedule(1,0,idur,0dbfs/2,ifmx,ifa,iff,icnt/insts)
 icnt+=1

od
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
