# Extended Csound Opcode Reference

Opcodes organized by category with signatures and descriptions.

## Audio Generators — Oscillators

| Opcode | Signature | Description |
|---|---|---|
| `oscili` | `a oscili xamp, xcps[, ifn]` | Interpolating table-lookup oscillator |
| `oscil` | `a oscil xamp, xcps[, ifn]` | Non-interpolating table oscillator |
| `poscil` | `a poscil xamp, xcps[, ifn]` | High-precision phase accumulator oscillator |
| `poscil3` | `a poscil3 xamp, xcps[, ifn]` | Cubic-interpolation poscil |
| `vco2` | `a vco2 kamp, kcps[, imode, kpw]` | Band-limited waveforms (saw/square/tri/pulse) |
| `vco` | `a vco xamp, xcps, iwave[, kpw]` | Variable waveform oscillator |
| `sqrwave` | `a sqrwave xamp, xcps` | Square wave |

## Audio Generators — Noise

| Opcode | Signature | Description |
|---|---|---|
| `noise` | `a noise xamp, kbeta` | White noise (kbeta=-1 to 1 for color) |
| `pinkish` | `a pinkish xin[, imethod, inumbands, iseed]` | Pink noise generator |
| `rand` | `a rand xamp[, iseed]` | Bipolar random |
| `randi` | `a/k randi xamp, xcps[, iseed]` | Linear interpolated random |
| `randh` | `a/k randh xamp, xcps[, iseed]` | Sample-and-hold random |
| `dust` | `a dust kamp, kdensity` | Random impulses at given density |
| `dust2` | `a dust2 kamp, kdensity` | Bipolar random impulses |
| `gausstrig` | `a gausstrig kamp, kcps, kdev` | Gaussian-distributed triggers |

## Audio Generators — Harmonics

| Opcode | Signature | Description |
|---|---|---|
| `buzz` | `a buzz xamp, xcps, knh, ifn` | Band-limited buzz with N harmonics |
| `gbuzz` | `a gbuzz xamp, xcps, knh, klh, kmul, ifn` | Generalized buzz (start harmonic, amplitude ratio) |
| `hsboscil` | `a hsboscil kamp, ktone, kbrite, ibasfreq, iwfn, ioctfn` | Additive with brightness control |

## FM Synthesis

| Opcode | Signature | Description |
|---|---|---|
| `foscili` | `a foscili xamp, kcps, xcar, xmod, kndx[, ifn]` | FM oscillator with C:M ratio and index |
| `foscil` | `a foscil xamp, kcps, xcar, xmod, kndx[, ifn]` | Non-interpolating FM oscillator |
| `crossfm` | `a1,a2 crossfm x1, x2, x3, x4, iphs1, iphs2` | Cross-frequency modulation |

## Granular Synthesis

| Opcode | Signature | Description |
|---|---|---|
| `grain` | `a grain xamp, xpitch, xdns, ampoff, pitchoff, kgdur, igfn, iwfn, imgdur` | Basic granular |
| `grain3` | `a grain3 kcps, kphs, kfmd, kpmd, kgdur, kdens, imaxovr, igfn, iwfn[, ...]` | Enhanced granular |
| `granule` | `a granule xamp, ivoice, iratio, imode, ithd, ifn, ipshift, igskip, igskip_os, ilength, kgap, igap_os, kgsize, igsize_os, iatt, idec` | Advanced granular |
| `partikkel` | `a partikkel kgrainfreq, ...` | Feature-rich granular engine |
| `fog` | `a fog xamp, xdens, xtrans, aspd, koct, kband, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur` | FOG generator |
| `sndwarp` | `a,a sndwarp xamp, xtimewarp, xresample, ifn1, ibeg, iwsize, irandw, ioverlap, ifn2, itimemode` | Time-stretch/pitch-shift |
| `sndwarpst` | `aL,aR sndwarpst ...` | Stereo version of sndwarp |

## Formant / Vocal

| Opcode | Signature | Description |
|---|---|---|
| `fof` | `a fof xamp, xfund, xform, koct, kband, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur` | Formant wave function synthesis |
| `fof2` | `a fof2 xamp, xfund, xform, koct, kband, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur, kphs, kgliss` | FOF with phase and gliss control |

## Physical Modeling / Waveguide

| Opcode | Signature | Description |
|---|---|---|
| `wgpluck2` | `a wgpluck2 iplk, xamp, icps, ipick, irkod, iflt` | Plucked string physical model |
| `wgbow` | `a wgbow kamp, kfreq, kpres, krat, kvibf, kvibamp[, ifn]` | Bowed string model |
| `wgflute` | `a wgflute kamp, kfreq, kjet, iatt, idetk, kngain, kvibf, kvibamp[, ifn]` | Flute physical model |
| `wgclar` | `a wgclar kamp, kfreq, kstiff, iatt, idetk, kngain, kvibf, kvibamp[, ifn]` | Clarinet model |
| `wgbrass` | `a wgbrass kamp, kfreq, ktens, iatt, kvibf, kvibamp[, ifn]` | Brass instrument model |
| `repluck` | `a repluck iplk, kamp, icps, kpick, krefl[, axcite]` | Enhanced Karplus-Strong |
| `pluck` | `a pluck kamp, kcps, icps, ifn, imeth[, iparm1, iparm2]` | Karplus-Strong plucked string |
| `streson` | `a streson ain, kfr, kfdbgain` | String resonator filter |
| `mode` | `a mode ain, kfreq, kQ` | Single resonant mode |
| `barmodel` | `a barmodel kbcL, kbcR, iK, ib, kscan, iT30, ipos, ivel, iwid` | Bar physical model |

## Filters — Low-Pass

| Opcode | Signature | Description |
|---|---|---|
| `moogladder` | `a moogladder ain, kcf, kres` | Moog ladder 4-pole LP (warm, musical) |
| `lpf18` | `a lpf18 ain, kcf, kres, kdist` | 3-pole LP with distortion (303-style) |
| `zdf_2pole` | `a zdf_2pole ain, kcf, kQ, kmode` | Zero-delay feedback 2-pole (LP/HP/BP/notch) |
| `zdf_ladder` | `a zdf_ladder ain, kcf, kQ` | Zero-delay feedback ladder filter |
| `butterlp` | `a butterlp ain, kfreq` | Butterworth low-pass |
| `tone` | `a tone ain, khp` | First-order low-pass |
| `tonex` | `a tonex ain, khp[, inumlayer]` | Cascaded first-order LP |
| `lowpass2` | `a lowpass2 ain, kcf, kQ` | Resonant second-order LP |
| `K35_lpf` | `a K35_lpf ain, kcf, kQ[, knlp]` | Korg 35 LP emulation |
| `diode_ladder` | `a diode_ladder ain, kcf, kfb` | Diode ladder filter |

## Filters — High-Pass

| Opcode | Signature | Description |
|---|---|---|
| `butterhp` | `a butterhp ain, kfreq` | Butterworth high-pass |
| `atone` | `a atone ain, khp` | First-order high-pass |
| `atonex` | `a atonex ain, khp[, inumlayer]` | Cascaded first-order HP |
| `K35_hpf` | `a K35_hpf ain, kcf, kQ[, knlp]` | Korg 35 HP emulation |

## Filters — Band-Pass / Band-Reject

| Opcode | Signature | Description |
|---|---|---|
| `resonz` | `a resonz ain, kcf, kbw` | Bandpass with center freq + bandwidth |
| `reson` | `a reson ain, kcf, kbw[, iscl]` | Second-order bandpass |
| `resonr` | `a resonr ain, kcf, kbw[, iscl]` | Bandpass (ring topology) |
| `resonx` | `a resonx ain, kcf, kbw[, inumlayer, iscl]` | Cascaded bandpass |
| `butterbp` | `a butterbp ain, kfreq, kband` | Butterworth bandpass |
| `butterbr` | `a butterbr ain, kfreq, kband` | Butterworth band-reject |

## Filters — Specialty

| Opcode | Signature | Description |
|---|---|---|
| `pareq` | `a pareq ain, kc, kv, kq, imode` | Parametric EQ section |
| `bqrez` | `a bqrez ain, kcf, kq[, imode]` | Multi-mode biquad (LP/HP/BP/notch/AP) |
| `comb` | `a comb ain, krvt, ilpt` | Comb filter |
| `hilbert` | `areal, aimag hilbert ain` | Hilbert transform |
| `phaser1` | `a phaser1 ain, kcps, kord, kfeedback` | First-order allpass phaser |
| `phaser2` | `a phaser2 ain, kfreq, kq, kord, kmode, ksep, kfeedback` | Second-order phaser |
| `svfilter` | `alow, ahigh, aband svfilter ain, kcf, kQ` | State-variable filter (simultaneous outputs) |
| `statevar` | `ahp, alp, abp, abr statevar ain, kcf, kQ` | State-variable filter (4 outputs) |

## Envelopes

| Opcode | Signature | Description |
|---|---|---|
| `madsr` | `k madsr iatt, idec, islev, irel` | MIDI-triggered ADSR |
| `adsr` | `k adsr iatt, idec, islev, irel` | Score-triggered ADSR |
| `linsegr` | `k linsegr ia, idur1, ib[, ...], irel, iz` | Linear segments with release |
| `expsegr` | `k expsegr ia, idur1, ib[, ...], irel, iz` | Exponential segments with release |
| `transegr` | `k transegr ia, idur1, itype1, ib[, ...]` | Arbitrary curve segments with release |
| `linseg` | `k linseg ia, idur1, ib[, ...]` | Linear segments |
| `expseg` | `k expseg ia, idur1, ib[, ...]` | Exponential segments (all values > 0) |
| `transeg` | `k transeg ia, idur1, itype1, ib[, ...]` | Arbitrary curve segments |
| `linen` | `k linen xamp, irise, idur, idec` | Simple rise-sustain-decay |
| `linenr` | `k linenr xamp, irise, idec, iatdec` | Rise with release on note-off |
| `envlpx` | `k envlpx xamp, irise, idur, idec, ifn, iatss, iatdec` | Complex envelope with table shape |

## Effects — Reverb

| Opcode | Signature | Description |
|---|---|---|
| `reverbsc` | `aL, aR reverbsc ainL, ainR, kfblvl, kcutoff` | Schroeder reverb (best quality) |
| `freeverb` | `aL, aR freeverb ainL, ainR, kRoomSize, kHFDamp` | Freeverb algorithm |
| `reverb2` | `a reverb2 ain, krvt, khfdamp` | Simple reverb |
| `nreverb` | `a nreverb ain, krvt, khfdamp` | Reverb with adjustable reflections |
| `babo` | `aL, aR babo ain, ksrcx, ksrcy, ksrcz, ...` | Physical room model |

## Effects — Delay

| Opcode | Signature | Description |
|---|---|---|
| `delay` | `a delay ain, idlt` | Simple fixed delay |
| `vdelay` | `a vdelay ain, adel, imaxdel` | Variable delay |
| `vdelay3` | `a vdelay3 ain, adel, imaxdel` | Cubic interpolation variable delay |
| `delayr` | `a delayr idlt` | Delay line read (for tap delays) |
| `delayw` | `delayw ain` | Delay line write |
| `deltap` | `a deltap idlt` | Tap delay at fixed time |
| `deltapi` | `a deltapi xdlt` | Interpolating tap delay |
| `deltap3` | `a deltap3 xdlt` | Cubic interpolating tap delay |
| `multitap` | `a multitap ain, itime1, igain1[, ...]` | Multiple taps |

## Effects — Modulation

| Opcode | Signature | Description |
|---|---|---|
| `chorus` | `a chorus ain, kfreq, kdepth[, ...]` | Chorus effect |
| `flanger` | `a flanger ain, adel, kfeedback` | Flanger effect |

## Effects — Distortion

| Opcode | Signature | Description |
|---|---|---|
| `distort` | `a distort ain, kdist, ifn` | Waveshaping distortion |
| `clip` | `a clip ain, imeth, ilimit` | Hard/soft clipping |
| `powershape` | `a powershape ain, kshapeamount[, ifn]` | Power-based waveshaping |

## Effects — Dynamics

| Opcode | Signature | Description |
|---|---|---|
| `compress2` | `a compress2 ain, agate, kthresh, kloknee, khiknee, kratio, katt, krel, ilook` | Compressor/limiter |
| `dam` | `a dam ain, kthreshold, icomp1, icomp2, irtime, iftime` | Dynamic amplitude modifier |

## Effects — Stereo / Spatial

| Opcode | Signature | Description |
|---|---|---|
| `pan2` | `aL, aR pan2 ain, kpan[, itype]` | Stereo panner |
| `locsig` | `aL, aR[, aRR, aRL] locsig ain, kdegree, kdistance, kreverbsend` | 3D localization |

## Utilities — Signal Processing

| Opcode | Signature | Description |
|---|---|---|
| `port` | `k port ksig, ihtim[, isig]` | Portamento (smooth k-rate) |
| `portk` | `k portk ksig, khtim[, isig]` | Portamento with k-rate time |
| `limit` | `a/k limit xsig, kmin, kmax` | Clamp signal to range |
| `mirror` | `k mirror ksig, kmin, kmax` | Mirror signal at boundaries |
| `wrap` | `k wrap ksig, kmin, kmax` | Wrap signal at boundaries |
| `scale` | `k scale kinput, kmax, kmin` | Scale 0-1 to new range |
| `downsamp` | `k downsamp ain` | Audio to control rate |
| `upsamp` | `a upsamp ksig` | Control to audio rate |
| `interp` | `a interp ksig` | Interpolated control to audio |
| `follow` | `k follow ain, iperiod` | Envelope follower |
| `follow2` | `k follow2 ain, iatt, irel` | Envelope follower with attack/release |
| `rms` | `k rms ain[, ihp]` | RMS amplitude |
| `balance` | `a balance ain, aref` | Match amplitude of reference |
| `balance2` | `a balance2 ain, aref[, ihp]` | Improved balance |

## Utilities — Math / Conversion

| Opcode | Signature | Description |
|---|---|---|
| `ampdb` | `i/k ampdb x` | dB to amplitude |
| `dbamp` | `i/k dbamp x` | Amplitude to dB |
| `cpsmidinn` | `i/k cpsmidinn x` | MIDI note to Hz |
| `cpsoct` | `i/k cpsoct x` | Octave notation to Hz |
| `octcps` | `i/k octcps x` | Hz to octave notation |
| `semitone` | `i/k semitone x` | Semitones to frequency ratio |
| `cent` | `i/k cent x` | Cents to frequency ratio |
| `abs` | `x abs x` | Absolute value |
| `int` | `x int x` | Truncate to integer |
| `frac` | `x frac x` | Fractional part |
| `log` | `i/k log x` | Natural logarithm |
| `log2` | `i/k log2 x` | Base-2 logarithm |
| `exp` | `i/k exp x` | e^x |
| `sqrt` | `i/k sqrt x` | Square root |
| `pow` | `i/k pow x, y` | x^y |
| `tanh` | `a/k tanh x` | Hyperbolic tangent (soft saturation) |

## I/O — Audio

| Opcode | Signature | Description |
|---|---|---|
| `outs` | `outs aL, aR` | Stereo output |
| `outall` | `outall ain` | Output to all channels |
| `out` | `out ain` | Mono output |
| `inch` | `a inch ichn` | Input channel |
| `diskin2` | `a[,a] diskin2 ifilcod, kpitch[, iskiptim, iwrap, iformat, iskipinit]` | Disk-based sample playback |
| `loscil` | `a[,a] loscil xamp, kcps, ifn[, ibas, imod1, ibeg, iend]` | Looping oscillator (sample playback) |
| `flooper2` | `a flooper2 kamp, kpitch, kloopstart, kloopend, kcrossfade, ifn` | Function table looper |

## I/O — MIDI

| Opcode | Signature | Description |
|---|---|---|
| `notnum` | `i notnum` | MIDI note number |
| `veloc` | `i veloc [ilo, ihi]` | MIDI velocity |
| `midinn` | `i/k midinn x` | MIDI note number (alias) |
| `cpsmidi` | `i cpsmidi` | MIDI note to Hz |
| `ampmidi` | `i ampmidi iscal` | MIDI velocity to amplitude |
| `massign` | `massign ichn, insnum` | Assign MIDI channel to instrument |
| `pgmassign` | `pgmassign ipgm, insnum` | Program change to instrument |
| `midiin` | `kstatus, kchan, kdata1, kdata2 midiin` | Raw MIDI input |
| `ctrl7` | `k ctrl7 ichan, ictlno, imin, imax` | MIDI CC input |

## I/O — Channels (Cabbage / Host)

| Opcode | Signature | Description |
|---|---|---|
| `chnget` | `k/a/S/i chnget Sname` | Get channel value |
| `chnset` | `chnset kval, Sname` | Set channel value |
| `chnsend` | `chnsend kval, Sname` | Send to named channel |

## Tables / Function Tables

| Opcode | Signature | Description |
|---|---|---|
| `ftgen` | `gi ftgen ifn, itime, isize, igen, iargs...` | Generate function table |
| `table` | `k/a table xndx, ifn` | Table read (no interpolation) |
| `tablei` | `k/a tablei xndx, ifn` | Table read (linear interpolation) |
| `table3` | `k/a table3 xndx, ifn` | Table read (cubic interpolation) |
| `tablew` | `tablew xsig, xndx, ifn` | Table write |
| `ftlen` | `i ftlen ifn` | Table length |
| `nsamp` | `i nsamp ifn` | Number of samples in table |
| `ftsr` | `i ftsr ifn` | Sample rate of table |

## Flow Control

| Opcode | Signature | Description |
|---|---|---|
| `if...then` | `if kcond then ... endif` | Conditional |
| `while` | `while kcond do ... od` | While loop |
| `until` | `until kcond do ... od` | Until loop |
| `goto` | `goto label` | Unconditional jump |
| `tigoto` | `tigoto label` | Jump on tied note |
| `reinit` | `reinit label` | Re-initialize from label |
| `rireturn` | `rireturn` | Return from reinit |
| `turnoff` | `turnoff` | Turn off current instrument |
| `turnoff2` | `turnoff2 insno, imode, irelease` | Turn off specific instrument |

## Printing / Debug

| Opcode | Signature | Description |
|---|---|---|
| `prints` | `prints Sfmt[, ...]` | Print string at i-time |
| `printks` | `printks Sfmt, iperiod[, ...]` | Print at k-rate intervals |
| `printk2` | `printk2 kvar[, inumspaces]` | Print k-var when changed |
| `sprintf` | `S sprintf Sfmt, ...` | Format string (i-time) |
| `sprintfk` | `S sprintfk Sfmt, ...` | Format string (k-rate) |
