<CsoundSynthesizer>
<CsInstruments>

; by Victor Lazzarini

ifn = ftgen(3,0,131072,"exp",0,-14,1)

opcode ModFM,a,kkkki

kamp,kfo,kfc,kbw,itab xin

itm = 14
icor = 4.*exp(-1)

;ktrig changed kbw,kfo
;if ktrig == 1 then
 k2 = exp(-kfo/(.29*kbw*icor)) 
 kg2 = 2*sqrt(k2)/(1.-k2)
 kndx = kg2*kg2/2.
;endif

aph phasor kfo
acos tablei  aph,1,1,0.25,1

kf = kfc/kfo
kfin = int(kf)
ka = kf  - kfin

aexp  table kndx*(1-acos)/itm,3,1
aexp2 exp -kndx*(1-acos)
;printk 1, k(aexp)*1000
;printk 1, k(aexp2)*1000

ioff = 0.25
acos1 tablei aph*kfin, itab, 1, ioff, 1
acos2 tablei aph*(kfin+1), itab, 1, ioff, 1
asig = (ka*acos2 + (1-ka)*acos1)*aexp

    xout asig*kamp

endop



instr 1

ilow = p5
ibas = p6/8
iamp = p4

kph phasor ibas/16
kamp table -kph*128,4,1,0.05,1
kmod table kph,1,1,p8,1
kfrq table kph,2,1,0,1
kint table kph*16,2,1,0,1

kmod = ((kmod+1)/2)*ilow*20 + ilow*4
kfrq pow  2, kfrq/12
kfo = kfrq*ilow
kp pow  2, kint/12
kfo port kp*kfo, 0.01


a3 ModFM  iamp,kfo,kmod,(kmod-kfo)*2,1
k1 portk kamp, 0.01

kfade linseg  0,3,1,p3-6,1,3,0

   outs a3*k1*(1-p7)*kfade,a3*k1*p7*kfade

endin



</CsInstruments>
<CsScore>

f1 0 2048 10 1
;f3 0 131072 "exp" 0 -14 1
f2 0 8 -2  0 5 10 0 9 2 7 5
f4 0 131072 7 0 10000 1 121072 0  

i1 0 38 10000 200 8      0  0.75

i1 0 39 10000 400 8.025 0.25 0.75
i1 0 40 10000 200 8.05  0.5 0.75
i1 0 41 10000 400 8.075 0.75 0.75
i1 0 43 10000 200 8.1   1  0.75

i1 20 68 10000 100 8     0 0
i1 20 38 10000 200 8.025 0.25 0.25
i1 20 39 10000 400 8.05  0.5   0.5
i1 20 40 10000 200 8.075 0.75 0.75
i1 20 41 10000 100 8.1   1 0

i1 76 20 10000 200 8      0  0.0
i1 76 21 10000 400 8.025 0.25 0.125
i1 76 22 10000 200 8.05  0.5 0.25
i1 76 40 10000 400 8.075 0.75 0.375
i1 76 24 10000 200 8.1   1  0.5


</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>553</x>
 <y>68</y>
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
