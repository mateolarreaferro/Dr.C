opcode LinVals,i,iiii
 iFirst,iLast,iNumSteps,iThisStep xin
 xout iFirst-(iFirst-iLast)/iNumSteps*iThisStep
endop

instr 1
 iCnt,iStart init 0
 until iCnt > 10 do
  iOct = LinVals(9,8,10,iCnt)
  schedule 2,iStart,1,iOct
  iCnt += 1
  iStart += LinVals(1/4,1,10,iCnt+0.5)
 od
endin
schedule(1,0,0)

instr 2
 out mode(mpulse(1,p3),cpsoct(p4),random:i(50,100))

endin
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
