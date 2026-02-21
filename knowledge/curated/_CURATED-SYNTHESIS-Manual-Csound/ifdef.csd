<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

; Determines which instrument outputs debug statements with defines:
; Change which one is commented out to alter behavior before execution
#define debug1 ##
; #define debug2 ##

 instr 1
 	iFreq = p4
	; Outputs text if debug1 is defined
	; This one should print by default
	#ifdef debug1
	     prints "instr 1 debug called\n"
	#end
     a1   vco2 .25, iFreq
     outs  a1, a1
 endin

 instr 2
 	iFreq = p4
	; Outputs text if debug2 is defined
	; This one should not print by default
	#ifdef debug2
	     prints "instr 2 debug called\n"
	#end
     a1   vco2 .25, iFreq
     outs  a1, a1
 endin

</CsInstruments>
<CsScore>
i1 0 2 440
i2 0 2 660
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
