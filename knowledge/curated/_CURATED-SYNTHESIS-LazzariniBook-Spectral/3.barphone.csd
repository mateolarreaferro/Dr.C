<CsoundSynthesizer>
<CsInstruments>

; by Victor Lazzarini

0dbfs = 1

imin = .001
gifa = ftgen(0,0,16384,5,1,16384,imin)

instr 1
 idur[] fillarray 1,.2,.15,.05
 ifr[] fillarray 1,5.1,6.95,13.3
 iamp[] fillarray 1,0.1,0.05,0.01
 itot = 800/p5
 icnt = 0
 insts = lenarray(idur)
 while icnt < insts do
   schedule(2,0,idur[icnt]*itot,iamp[icnt]*p4,ifr[icnt]*p5,gifa)
   icnt+=1
 od
endin

instr 2
 at = line:a(0,p3,1)
 out(oscili(p4*table:a(at,p6,1),p5))
endin

schedule(1,0,5,.25,cpsmidinn(60))
schedule(1,0,5,.25,cpsmidinn(63))
schedule(1,0,5,.25,cpsmidinn(67))

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
