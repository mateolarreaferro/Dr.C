/**
 * Mapping from Csound opcodes and techniques to FLOSS Manual URLs.
 * Base URL: https://flossmanual.csound.com/
 */

export const FLOSS_LINKS: Record<string, string> = {
  // --- Oscillators & Tone Generators ---
  oscil: "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  oscili: "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  poscil: "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  poscil3: "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  vco2: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  buzz: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  gbuzz: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  noise: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  rand: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  randi: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  randh: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  pinkish: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",

  // --- FM Synthesis ---
  foscil: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  foscili: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  fmbell: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  fmrhode: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  fmwurlie: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  fmvoice: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  fmmetal: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  crossfm: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",

  // --- Filters ---
  moogladder: "https://flossmanual.csound.com/sound-modification/filters",
  moogvcf: "https://flossmanual.csound.com/sound-modification/filters",
  moogvcf2: "https://flossmanual.csound.com/sound-modification/filters",
  lpf18: "https://flossmanual.csound.com/sound-modification/filters",
  butterlp: "https://flossmanual.csound.com/sound-modification/filters",
  butterhp: "https://flossmanual.csound.com/sound-modification/filters",
  butterbp: "https://flossmanual.csound.com/sound-modification/filters",
  butterbr: "https://flossmanual.csound.com/sound-modification/filters",
  statevar: "https://flossmanual.csound.com/sound-modification/filters",
  bqrez: "https://flossmanual.csound.com/sound-modification/filters",
  pareq: "https://flossmanual.csound.com/sound-modification/filters",
  eqfil: "https://flossmanual.csound.com/sound-modification/filters",
  tone: "https://flossmanual.csound.com/sound-modification/filters",
  atone: "https://flossmanual.csound.com/sound-modification/filters",
  reson: "https://flossmanual.csound.com/sound-modification/filters",
  comb: "https://flossmanual.csound.com/sound-modification/filters",

  // --- Envelopes ---
  linseg: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  linsegr: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  expseg: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  expsegr: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  expon: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  line: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  madsr: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  mxadsr: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  adsr: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  transeg: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  transegr: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  jspline: "https://flossmanual.csound.com/sound-synthesis/envelopes",

  // --- Reverb ---
  reverbsc: "https://flossmanual.csound.com/sound-modification/reverberation",
  freeverb: "https://flossmanual.csound.com/sound-modification/reverberation",
  nreverb: "https://flossmanual.csound.com/sound-modification/reverberation",
  reverb: "https://flossmanual.csound.com/sound-modification/reverberation",
  alpass: "https://flossmanual.csound.com/sound-modification/reverberation",

  // --- Delay ---
  delay: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  delayr: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  delayw: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  deltap: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  deltapi: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  vdelay: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  vdelay3: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
  flanger: "https://flossmanual.csound.com/sound-modification/delay-and-feedback",

  // --- Granular ---
  partikkel: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  grain: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  grain3: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  fof: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  fof2: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  fog: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  sndwarp: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  granule: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",

  // --- Spectral / Phase Vocoder ---
  pvsanal: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvsynth: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvsfreeze: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvsmooth: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvsfilter: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvscross: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvsblur: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvshift: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  pvscale: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",

  // --- Physical Modeling ---
  pluck: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  wgbow: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  wgflute: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  wgclar: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  wgbrass: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  repluck: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  barmodel: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  mandol: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",

  // --- Sample Playback ---
  diskin: "https://flossmanual.csound.com/sound-synthesis/sample-playback",
  diskin2: "https://flossmanual.csound.com/sound-synthesis/sample-playback",
  loscil: "https://flossmanual.csound.com/sound-synthesis/sample-playback",
  loscil3: "https://flossmanual.csound.com/sound-synthesis/sample-playback",
  flooper: "https://flossmanual.csound.com/sound-synthesis/sample-playback",
  flooper2: "https://flossmanual.csound.com/sound-synthesis/sample-playback",

  // --- Distortion & Waveshaping ---
  distort1: "https://flossmanual.csound.com/sound-modification/waveshaping",
  clip: "https://flossmanual.csound.com/sound-modification/waveshaping",
  powershape: "https://flossmanual.csound.com/sound-modification/waveshaping",
  fold: "https://flossmanual.csound.com/sound-modification/waveshaping",
  decimator: "https://flossmanual.csound.com/sound-modification/waveshaping",

  // --- Panning & Spatialization ---
  pan2: "https://flossmanual.csound.com/sound-modification/panning-and-spatialization",
  vbap: "https://flossmanual.csound.com/sound-modification/panning-and-spatialization",
  hrtfmove: "https://flossmanual.csound.com/sound-modification/panning-and-spatialization",

  // --- Dynamics ---
  compress2: "https://flossmanual.csound.com/sound-modification/amplitude",
  dam: "https://flossmanual.csound.com/sound-modification/amplitude",
  follow2: "https://flossmanual.csound.com/sound-modification/amplitude",

  // --- Scheduling & Control ---
  metro: "https://flossmanual.csound.com/csound-language/control-structures",
  event: "https://flossmanual.csound.com/csound-language/control-structures",
  schedkwhen: "https://flossmanual.csound.com/csound-language/control-structures",
  scoreline_i: "https://flossmanual.csound.com/csound-language/control-structures",
  chnget: "https://flossmanual.csound.com/csound-language/channels",
  chnset: "https://flossmanual.csound.com/csound-language/channels",
  outch: "https://flossmanual.csound.com/csound-language/channels",
  outs: "https://flossmanual.csound.com/csound-language/channels",
  port: "https://flossmanual.csound.com/csound-language/control-structures",
  portk: "https://flossmanual.csound.com/csound-language/control-structures",

  // --- LFO & Modulation ---
  lfo: "https://flossmanual.csound.com/sound-synthesis/modulation",
  jitter: "https://flossmanual.csound.com/sound-synthesis/modulation",
  jitter2: "https://flossmanual.csound.com/sound-synthesis/modulation",
  rspline: "https://flossmanual.csound.com/sound-synthesis/modulation",
  dust: "https://flossmanual.csound.com/sound-synthesis/modulation",
  dust2: "https://flossmanual.csound.com/sound-synthesis/modulation",
  gausstrig: "https://flossmanual.csound.com/sound-synthesis/modulation",

  // --- Table / GEN ---
  table: "https://flossmanual.csound.com/csound-language/function-tables",
  tablei: "https://flossmanual.csound.com/csound-language/function-tables",
  ftgen: "https://flossmanual.csound.com/csound-language/function-tables",

  // --- Technique Pages ---
  "additive synthesis": "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  "subtractive synthesis": "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  "fm synthesis": "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  "granular synthesis": "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  "physical modeling": "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  "spectral processing": "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  "wavetable synthesis": "https://flossmanual.csound.com/csound-language/function-tables",
  "sample-based synthesis": "https://flossmanual.csound.com/sound-synthesis/sample-playback",
  envelopes: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  filters: "https://flossmanual.csound.com/sound-modification/filters",
  "reverb techniques": "https://flossmanual.csound.com/sound-modification/reverberation",
  "delay techniques": "https://flossmanual.csound.com/sound-modification/delay-and-feedback",
}
