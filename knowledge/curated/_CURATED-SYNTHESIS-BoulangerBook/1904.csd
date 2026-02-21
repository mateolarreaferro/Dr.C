<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1904    ; DRUM STICK 1


gadrum    init      0

; FREQUENCY
ifqc      =         cpspch(p5)

; INITIALIZE THE DELAY LINE WITH NOISE
ashape    linseg     0, 1/ifqc/8, -1/2, 1/ifqc/4, 1/2, 1/ifqc/8, 0, p3-1/ifqc, 0
gadrum    tone      ashape, p6

          endin

          instr     1905    ; A SQUARE DRUM

irt2      init      sqrt(2)
itube     init      p7
ifdbck1   init      p8
ifdbck2   init      p9
anodea    init      0
anodeb    init      0
anodec    init      0
anoded    init      0
afiltr    init      0
ablocka2  init      0
ablocka3  init      0
ablockb2  init      0
ablockb3  init      0
ablockc2  init      0
ablockc3  init      0
ablockd2  init      0
ablockd3  init      0

; FREQUENCY
ifqc      =          cpspch(p5)
ipfilt    =          p6

; AMPLITUDE ENVELOPE
kampenv   linseg 0, .01, p4, p3-.02, p4, .01, 0
                
; DELAY LINES
alineab   delay      anodea+gadrum+afiltr, 1/ifqc
alineba   delay      anodeb+gadrum+afiltr, 1/ifqc
alinebc   delay      anodeb+gadrum+afiltr, 1/ifqc
alinecb   delay      anodec+gadrum+afiltr, 1/ifqc
alinecd   delay      anodec+gadrum+afiltr, 1/ifqc
alinedc   delay      anoded+gadrum+afiltr, 1/ifqc
alinead   delay      anodea+gadrum+afiltr, 1/ifqc
alineda   delay      anoded+gadrum+afiltr, 1/ifqc
alineac   delay      anodea+gadrum+afiltr, 1/ifqc*irt2
alineca   delay      anodec+gadrum+afiltr, 1/ifqc*irt2
alinebd   delay      anodeb+gadrum+afiltr, 1/ifqc*irt2
alinedb   delay      anoded+gadrum+afiltr, 1/ifqc*irt2

; FILTER THE DELAYED SIGNAL AND FEEDBACK INTO THE DELAY
; IMPLEMENTS DC BLOCKING
ablocka1  =         -(alineba + alineca + alineda)/ifdbck1
ablocka2  =         ablocka1 - ablocka3 + .99*ablocka2
ablocka3  =         ablocka1
anodea    =         ablocka2
     
; NODE B
ablockb1  =         -(alineba + alineca + alineda)/ifdbck1
ablockb2  =         ablockb1 - ablockb3 + .99*ablockb2
ablockb3  =         ablockb1
anodeb    =         ablockb2

; NODE C
ablockc1  =         -(alineba + alineca + alineda)/ifdbck1
ablockc2  =         ablockc1 - ablockc3 + .99*ablockc2
ablockc3  =         ablockc1
anodec    =         ablockc2

; NODE D
ablockd1  =         -(alineba + alineca + alineda)/ifdbck1
ablockd2  =         ablockd1 - ablockd3 + .99*ablockd2
ablockd3  =         ablockd1
anoded    =         ablockd2

; BODY RESONANCE
atube     delay      anodea, itube/ifqc
afiltr    tone      atube, 1000
afiltr    =          afiltr/ifdbck2

; SCALE AND OUTPUT
          out       anodea*kampenv*1000

          endin

          instr      1906 ; DRUM STICK 2

gadrum2   init      0

; FREQUENCY
ifqc      =          cpspch(p5)

; INITIALIZE THE DELAY LINE WITH NOISE
ashape    linseg     0, 1/ifqc/8, -1/2, 1/ifqc/4, 1/2, 1/ifqc/8, 0, p3-1/ifqc, 0
gadrum2   tone      ashape, p6

          endin

          instr      1907    ; A SQUARE DRUM
                
irt2      init      sqrt(2)
itube     init      p7
ifdbck1   init      p8
ifdbck2   init      p9
anodea    init      0
anodeb    init      0
anodec    init      0
anoded    init      0
afiltr    init      0
ablocka2  init      0
ablocka3  init      0
ablockb2  init      0
ablockb3  init      0
ablockc2  init      0
ablockc3  init      0
ablockd2  init      0
ablockd3  init      0

; FREQUENCY
ifqc      =          cpspch(p5)
ipfilt    =          p6

; AMPLITUDE ENVELOPE
kampenv   linseg     0, .01, p4, p3-.02, p4, .01, 0

; DELAY LINES
alineab   delay      anodea+gadrum2+afiltr, 1/ifqc
alineba   delay      anodeb+gadrum2+afiltr, 1/ifqc
alinebc   delay      anodeb+gadrum2+afiltr, 1/ifqc
alinecb   delay      anodec+gadrum2+afiltr, 1/ifqc
alinecd   delay      anodec+gadrum2+afiltr, 1/ifqc
alinedc   delay      anoded+gadrum2+afiltr, 1/ifqc
alinead   delay      anodea+gadrum2+afiltr, 1/ifqc
alineda   delay      anoded+gadrum2+afiltr, 1/ifqc
alineac   delay      anodea+gadrum2+afiltr, 1/ifqc*irt2
alineca   delay      anodec+gadrum2+afiltr, 1/ifqc*irt2
alinebd   delay      anodeb+gadrum2+afiltr, 1/ifqc*irt2
alinedb   delay      anoded+gadrum2+afiltr, 1/ifqc*irt2

; FILTER THE DELAYED SIGNAL AND FEEDBACK INTO THE DELAY
; IMPLEMENTS DC BLOCKING
ablocka1  =         -(alineba + alineca + alineda)/ifdbck1
ablocka2  =         ablocka1 - ablocka3 + .99*ablocka2
ablocka3  =         ablocka1
anodea    =         ablocka2

; NODE B
ablockb1  =         -(alineba + alineca + alineda)/ifdbck1
ablockb2  =         ablockb1 - ablockb3 + .99*ablockb2
ablockb3  =         ablockb1
anodeb    =         ablockb2

; NODE C
ablockc1  =         -(alineba + alineca + alineda)/ifdbck1
ablockc2  =         ablockc1 - ablockc3 + .99*ablockc2
ablockc3  =         ablockc1
anodec    =         ablockc2

; NODE D
ablockd1  =         -(alineba + alineca + alineda)/ifdbck1
ablockd2  =         ablockd1 - ablockd3 + .99*ablockd2
ablockd3  =         ablockd1
anoded    =         ablockd2

; BODY RESONANCE
atube     delay      anodea, itube/ifqc
afiltr    tone      atube, 1500
afiltr    =          afiltr/ifdbck2

; SCALE AND OUTPUT
          out       anodea*kampenv*1000

          endin

</CsInstruments>
<CsScore>
t 0 600
; DRUM 1
;       START  DUR  AMP    PITCH PREFILTER  TUBELENGTH  FEEDBACK1  FEEDBACK2
i 1905  0     128  160    5.11   100           4          4.4        4.3

; DRUMSTICK
;       START  DUR  AMP  PITCH  PREFILTER
i 1904  0      4   200   7.05   100
i 1904  +      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100
;
i 1904  .      4   200   7.05   100
i 1904  .      2   500   7.00   120
i 1904  .      6  1000   7.05   160
i 1904  .      2  1000   7.00   120
i 1904  .      2   500   6.09   100

; DRUM 2
;      START  DUR  AMP    PITCH PREFILTER  TUBELENGTH  FEEDBACK1  FEEDBACK2
i 1907 0     128  100    5.05   100        4             4.2         5

; DRUMSTICK
;      START  DUR  AMP  PITCH  PREFILTER
i 1906 2      8   400   5.09   300
i 1906 +      6   500   5.02   200
;
i 1906 .      8   400   5.09   300
i 1906 .      6   500   5.02   200
;
i 1906 34     8   400   5.09   300
i 1906 +      6   500   5.02   200
;
i 1906 .      8   400   5.09   300
i 1906 .      6   500   5.02   200
;
i 1906 66     8   400   5.09   300
i 1906 +      8   500   5.02   200
;
i 1906 .      8   400   5.09   300
i 1906 .      8   500   5.02   200
;
i 1906 96     8   400   5.09   300
i 1906 +      8   500   5.02   200
;
i 1906 .      8   400   5.09   300
i 1906 .      8   500   5.02   200
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
