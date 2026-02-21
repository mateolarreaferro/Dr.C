<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1
;after an example from Jonathan Murphy 
  
gilen = 7
gilist  ftgen 1, 0, gilen + 1, -2, 2, 3, 4, 5, 6, 7	;only 6 elements, so 1 is doubled
gitmp   ftgen 2, 0, gilen + 1, -2, 0			;empty table
gkmax   init gilen

seed 0							;each time different 

instr 1

ktrig metro 3						;trigger values
krnd  random 0, gkmax

if (ktrig == 1) then
  kval    table  krnd, gilist
          tablew 0, krnd, gilist
  kread   = 0
  kwrite  = 0
start:
  knew    table kread, gilist
if (knew != 0) then
          tablew knew, kwrite, gitmp
  kwrite    =  kwrite + 1
endif
  kread   = kread + 1
if (kread <= gilen) kgoto start
          tablecopy gilist, gitmp			;fill with zeroes
  gkmax   = gkmax - 1
endif

;printk2 kval

if (gkmax < 0) then
          event "i", 2, 0, 1/kr				;when ready, then stop
endif

asig vco2 .5, 40*kval					;sound generation
outs asig, asig
    
endin

instr 2

exitnow
    
endin
</CsInstruments>
<CsScore>
i1 0 5
e
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
