<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

#define STANDARDPITCH #440# ; as set by ISO 1975:16 - STANDARD MUSICAL PITCH
#define BAROQUEPITCH #415# ; common use (but not standard) in Baroque era (1600 - 1750) 
#define HIGHER #443# ; some orchestras, mainly in Europe use higher pitch (442-443 Hz)

#define EXPRESSION #(440*1.3)+200# ; you can use an expression

A4 = $STANDARDPITCH
;A4 = $BAROQUEPITCH
;A4 = $HIGHER

;A4 = $EXPRESSION

instr 1	
  
ipch =	p4
icps =	cpspch(ipch)
asig	oscil 0.7, icps, 1
	outs  asig, asig

endin

</CsInstruments>
<CsScore>

f 1 0 4096 10 1 0.3 0.2. 0.1

; Theme from Bach BWV 578 -  Little fugue in G minor.
i 1 0 1 7.07
i 1 + 1 8.02
i 1 + 1.5 7.10
i 1 + .5 7.09
i 1 + .5 7.07
i 1 + .5 7.10
i 1 + .5 7.09
i 1 + .5 7.07
i 1 + .5 7.06
i 1 + .5 7.09
i 1 + 1 7.02
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
