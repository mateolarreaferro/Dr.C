/**
 * Pre-computed technique lineage data for the educational layer.
 * Maps synthesis techniques to their chronological history, key figures,
 * and Csound opcode connections.
 */

export interface LineageEvent {
  year: number
  figure: string
  description: string
  opcodes?: string[]
}

export const TECHNIQUE_LINEAGE: Record<string, { events: LineageEvent[] }> = {
  "fm synthesis": {
    events: [
      {
        year: 1967,
        figure: "John Chowning",
        description:
          "Discovered frequency modulation synthesis at Stanford CCRMA while experimenting with extreme vibrato rates. When the modulation frequency entered the audio range, rich inharmonic spectra emerged.",
      },
      {
        year: 1973,
        figure: "John Chowning",
        description:
          'Published "The Synthesis of Complex Audio Spectra by Means of Frequency Modulation," establishing the mathematical foundation for FM synthesis and its relationship to Bessel functions.',
      },
      {
        year: 1975,
        figure: "Stanford / Yamaha",
        description:
          "Stanford University licensed FM synthesis patents to Yamaha, one of the most profitable university patent licenses in history.",
      },
      {
        year: 1983,
        figure: "Yamaha",
        description:
          "Yamaha DX7 released, bringing FM synthesis to the mass market. Its electric piano, bass, and bell timbres defined 1980s pop, new wave, and R&B production.",
        opcodes: ["foscil", "fmbell", "fmrhode", "fmwurlie"],
      },
      {
        year: 1986,
        figure: "Barry Vercoe / MIT",
        description:
          "Csound inherited FM opcodes from MUSIC 11 and Music 360. The foscil opcode provided a simple carrier-modulator FM pair controllable in real time.",
        opcodes: ["foscil", "foscili"],
      },
      {
        year: 2000,
        figure: "Native Instruments",
        description:
          "FM7 and later FM8 brought FM synthesis back into the spotlight with modern UI and modulation matrices, reviving interest in the technique.",
      },
      {
        year: 2020,
        figure: "Modern Csound",
        description:
          "Csound's FM opcodes remain among the most efficient ways to explore FM synthesis, with foscil for simple FM and custom instrument designs for complex multi-operator FM networks.",
        opcodes: ["foscil", "foscili", "fmbell", "fmrhode", "fmwurlie", "fmvoice", "fmmetal", "fmpercfl"],
      },
    ],
  },

  "subtractive synthesis": {
    events: [
      {
        year: 1964,
        figure: "Robert Moog",
        description:
          "Robert Moog presented his voltage-controlled synthesizer modules at the AES convention. The voltage-controlled filter (VCF) with resonance became the signature sound-shaping element of subtractive synthesis.",
      },
      {
        year: 1968,
        figure: "Wendy Carlos",
        description:
          'Released "Switched-On Bach" using a Moog synthesizer, demonstrating that electronic instruments could produce musically expressive performances and bringing synthesis into mainstream awareness.',
      },
      {
        year: 1970,
        figure: "Robert Moog",
        description:
          "Minimoog released — the first portable, integrated synthesizer. Its 24dB/oct ladder filter became the gold standard of subtractive synthesis timbre, imitated for decades.",
      },
      {
        year: 1978,
        figure: "Dave Smith / Sequential Circuits",
        description:
          "Prophet-5 introduced patch memory and polyphony to subtractive synthesis, making it practical for live performance and studio production.",
      },
      {
        year: 1997,
        figure: "Antti Huovilainen",
        description:
          "Published digital models of the Moog ladder filter with improved accuracy and stability. These models eventually made their way into Csound as the moogladder opcode.",
        opcodes: ["moogladder", "moogvcf", "moogvcf2"],
      },
      {
        year: 2005,
        figure: "Csound community",
        description:
          "Modern Csound provides a rich palette of filter opcodes for subtractive synthesis, from Moog ladder emulations to state-variable and zero-delay feedback designs.",
        opcodes: ["moogladder", "moogvcf", "lpf18", "statevar", "zdf_2pole", "butterlp", "butterhp", "vco2"],
      },
    ],
  },

  "granular synthesis": {
    events: [
      {
        year: 1946,
        figure: "Dennis Gabor",
        description:
          'Physicist Dennis Gabor proposed that any sound could be decomposed into elementary "acoustical quanta" — tiny grains of sound. This theoretical insight laid the mathematical foundation for granular synthesis.',
      },
      {
        year: 1960,
        figure: "Iannis Xenakis",
        description:
          'Xenakis independently developed the concept of sound grains in his book "Formalized Music," describing stochastic distributions of sonic particles as analogous to gas molecules — clouds of sound governed by probability.',
      },
      {
        year: 1974,
        figure: "Curtis Roads",
        description:
          "As a graduate student, Curtis Roads began implementing granular synthesis on computers at UCSD, producing the first practical computer-generated granular textures.",
      },
      {
        year: 1978,
        figure: "Curtis Roads",
        description:
          'Published "Granular Synthesis of Sound" — the seminal paper bringing Gabor\'s and Xenakis\'s theoretical ideas into practical digital implementation with detailed algorithms.',
      },
      {
        year: 1988,
        figure: "Barry Truax",
        description:
          "Developed real-time granular synthesis on the DMX-1000 at Simon Fraser University, demonstrating time-stretching and pitch-shifting of sampled sounds through granulation.",
      },
      {
        year: 2001,
        figure: "Curtis Roads",
        description:
          'Published "Microsound," the definitive book on granular and microsound techniques, covering synchronous, asynchronous, and quasi-synchronous granulation strategies.',
      },
      {
        year: 2005,
        figure: "Oeyvind Brandtsegg",
        description:
          "Developed the partikkel opcode for Csound — a flexible, feature-rich granular synthesis engine supporting multiple grain sources, FM of grains, and trainlet synthesis.",
        opcodes: ["partikkel", "grain", "grain3", "fof", "fof2", "fog", "sndwarp", "granule"],
      },
    ],
  },

  "additive synthesis": {
    events: [
      {
        year: 1863,
        figure: "Hermann von Helmholtz",
        description:
          'Published "On the Sensations of Tone," establishing that timbre arises from the relative amplitudes and phases of harmonic partials — the scientific basis for additive synthesis.',
      },
      {
        year: 1957,
        figure: "Max Mathews",
        description:
          "Created MUSIC I at Bell Labs, the first computer program to generate sound. Additive synthesis (summing oscillators) was the fundamental technique, with each UNIT GENERATOR producing one partial.",
      },
      {
        year: 1965,
        figure: "Jean-Claude Risset",
        description:
          "At Bell Labs, Risset used additive synthesis to analyze and resynthesize brass instrument timbres, discovering that natural tones have time-varying harmonic structures that static spectra cannot capture.",
        opcodes: ["oscil", "oscili"],
      },
      {
        year: 1969,
        figure: "Jean-Claude Risset",
        description:
          'Compiled the "Introductory Catalogue of Computer Synthesized Sounds" — a collection of additive synthesis recipes demonstrating bells, drums, and the famous Shepard-Risset glissando.',
      },
      {
        year: 1977,
        figure: "New England Digital",
        description:
          "Synclavier introduced real-time additive synthesis with independent control of 32+ partials, enabling spectral morphing and resynthesis from analyzed acoustic sounds.",
      },
      {
        year: 1985,
        figure: "Kawai",
        description:
          "Kawai K5 synthesizer brought additive synthesis to an affordable keyboard, with 128 harmonics per source. Demonstrated that additive synthesis could be practical outside research labs.",
      },
      {
        year: 2000,
        figure: "Modern Csound",
        description:
          "Csound supports additive synthesis through banks of oscil/oscili opcodes with envelope control per partial, GEN10 for harmonic spectra, and adsynt/adsynt2 for efficient partial banks.",
        opcodes: ["oscil", "oscili", "poscil", "buzz", "gbuzz", "adsynt", "adsynt2", "hsboscil"],
      },
    ],
  },

  "physical modeling": {
    events: [
      {
        year: 1971,
        figure: "Lejaren Hiller & Pierre Ruiz",
        description:
          "Published early work on physical modeling of vibrating strings using finite difference methods at the University of Illinois, establishing that physical laws could drive sound synthesis.",
      },
      {
        year: 1983,
        figure: "Kevin Karplus & Alex Strong",
        description:
          "Published the Karplus-Strong algorithm — an elegantly simple physical model using a short delay line with feedback and filtering to simulate plucked strings and drum membranes.",
        opcodes: ["pluck"],
      },
      {
        year: 1992,
        figure: "Julius O. Smith III",
        description:
          "At Stanford CCRMA, Smith developed digital waveguide synthesis — an efficient framework for modeling acoustic wave propagation in strings, tubes, and membranes using delay lines and junction scattering.",
        opcodes: ["wgbow", "wgflute", "wgclar", "wgbrass"],
      },
      {
        year: 1996,
        figure: "Yamaha",
        description:
          "Yamaha VL1 brought waveguide physical modeling to a commercial keyboard, producing strikingly realistic wind and string instrument sounds from physical parameters rather than samples.",
      },
      {
        year: 1999,
        figure: "Perry Cook / STK",
        description:
          "Perry Cook released the Synthesis ToolKit (STK), an open-source C++ library of physical models. Several Csound opcodes were later derived from or inspired by STK algorithms.",
        opcodes: ["wgbow", "wgflute", "wgclar", "wgbrass", "mandol", "gogobel", "marimba", "vibes"],
      },
      {
        year: 2010,
        figure: "Modern Csound",
        description:
          "Csound offers a comprehensive physical modeling toolkit: Karplus-Strong (pluck), waveguide models (wgbow, wgflute, wgclar, wgbrass), and modal synthesis (mode, modalfreq).",
        opcodes: ["pluck", "wgbow", "wgflute", "wgclar", "wgbrass", "repluck", "mandol", "barmodel"],
      },
    ],
  },

  "spectral processing": {
    events: [
      {
        year: 1966,
        figure: "James Flanagan & Roger Golden",
        description:
          "Developed the phase vocoder at Bell Labs for speech analysis-resynthesis, establishing the core algorithm of FFT analysis followed by spectral manipulation and resynthesis.",
      },
      {
        year: 1977,
        figure: "IRCAM",
        description:
          "The Institut de Recherche et Coordination Acoustique/Musique (IRCAM) in Paris became the epicenter of spectral processing research, with composers like Boulez and researchers developing real-time spectral tools.",
      },
      {
        year: 1982,
        figure: "Mark Dolson",
        description:
          'Published "The Phase Vocoder: A Tutorial," making the technique accessible to the computer music community and establishing standard practices for spectral analysis-resynthesis.',
      },
      {
        year: 1991,
        figure: "IRCAM / AudioSculpt",
        description:
          "IRCAM released AudioSculpt, a graphical spectral editing environment that allowed composers to visually manipulate spectral data — freeze, filter, morph, and cross-synthesize sounds.",
      },
      {
        year: 1996,
        figure: "Richard Dobson",
        description:
          "The pvs (phase vocoder streaming) framework was developed for Csound, bringing real-time spectral processing with streaming FFT analysis and resynthesis.",
        opcodes: ["pvsanal", "pvsynth"],
      },
      {
        year: 2005,
        figure: "Victor Lazzarini",
        description:
          "Expanded Csound's pvs opcode family extensively, adding spectral freeze, morphing, filtering, blurring, and cross-synthesis — making Csound one of the most complete spectral processing environments.",
        opcodes: ["pvsanal", "pvsynth", "pvsfreeze", "pvsmooth", "pvsfilter", "pvscross", "pvsblur", "pvshift", "pvscale"],
      },
    ],
  },

  "wavetable synthesis": {
    events: [
      {
        year: 1957,
        figure: "Max Mathews",
        description:
          "MUSIC I used stored function tables (wavetables) to define oscillator waveforms — the earliest form of wavetable synthesis. This table-lookup approach became fundamental to all digital synthesis.",
      },
      {
        year: 1979,
        figure: "Wolfgang Palm / PPG",
        description:
          "PPG Wave Computer 360 introduced wavetable scanning — smoothly sweeping through a sequence of different single-cycle waveforms, creating evolving timbral animations.",
      },
      {
        year: 1981,
        figure: "Wolfgang Palm / PPG",
        description:
          "PPG Wave 2 refined wavetable synthesis with digital oscillators and analog filters, establishing the bright, digital-yet-warm character that defined wavetable synthesis.",
      },
      {
        year: 1989,
        figure: "Waldorf",
        description:
          "Waldorf Microwave carried forward the PPG wavetable concept with improved D/A conversion and modulation capabilities, keeping wavetable synthesis alive through the sample-dominated late 1980s.",
      },
      {
        year: 2012,
        figure: "Steve Duda / Xfer Records",
        description:
          "Serum popularized a new generation of wavetable synthesis with visual wavetable editing, spectral manipulation, and ultra-clean interpolation, making wavetable the dominant soft-synth architecture.",
      },
      {
        year: 2020,
        figure: "Modern Csound",
        description:
          "Csound's GEN routines (GEN10, GEN09, GEN19, GEN30) create wavetables from harmonic recipes. The oscil/oscili/poscil opcodes read these tables, enabling classic wavetable scanning via table morphing.",
        opcodes: ["oscil", "oscili", "poscil", "tablei", "table", "ftmorf"],
      },
    ],
  },

  "stochastic synthesis": {
    events: [
      {
        year: 1954,
        figure: "Iannis Xenakis",
        description:
          'Composed "Metastasis" using stochastic processes to determine musical parameters — the philosophical seed for stochastic sound synthesis where probability distributions shape not just notes but the sound itself.',
      },
      {
        year: 1958,
        figure: "Iannis Xenakis",
        description:
          'Composed "Concret PH" from thousands of tiny charcoal-crackling sounds, an early practical demonstration of stochastic microsound — sound built from statistical distributions of sonic particles.',
      },
      {
        year: 1971,
        figure: "Iannis Xenakis",
        description:
          "Developed the UPIC system at CEMAMu in Paris, allowing composers to draw waveforms and sound trajectories on a tablet. Stochastic elements could be introduced through graphic gesture.",
      },
      {
        year: 1991,
        figure: "Iannis Xenakis",
        description:
          "Developed GENDY (GENeration DYnamique) — a radical approach where the waveform itself is generated stochastically, with random walks controlling breakpoints of the audio signal directly.",
      },
      {
        year: 2001,
        figure: "Peter Hoffmann",
        description:
          'Reconstructed and documented Xenakis\'s GENDY algorithms in detail, and Agostino Di Scipio explored "audible ecosystems" using stochastic feedback between sound and environment.',
      },
      {
        year: 2010,
        figure: "Modern Csound",
        description:
          "Csound provides extensive random and noise opcodes for stochastic synthesis: noise generators, random walks, probability distributions, and jitter opcodes for controlled randomness.",
        opcodes: ["rand", "randi", "randh", "rnd31", "noise", "dust", "dust2", "jitter", "jitter2", "gausstrig", "gendy", "gendyc", "gendyx"],
      },
    ],
  },

  "sample-based synthesis": {
    events: [
      {
        year: 1979,
        figure: "Fairlight / Peter Vogel & Kim Ryrie",
        description:
          "Fairlight CMI (Computer Musical Instrument) introduced practical digital sampling to music production. Its ability to record and play back any sound revolutionized the concept of a musical instrument.",
      },
      {
        year: 1980,
        figure: "Fairlight",
        description:
          'Peter Gabriel and Kate Bush pioneered creative sampling with the Fairlight CMI. The "Page R" sequencer combined sampling with pattern-based composition.',
      },
      {
        year: 1984,
        figure: "E-mu Systems",
        description:
          "Emulator II made sampling affordable and portable. Combined with the nascent MIDI standard, it enabled sample-based production workflows that dominated 1980s and 1990s music.",
      },
      {
        year: 1986,
        figure: "Akai",
        description:
          "Akai S900 and later S-series samplers became the industry workhorses, with loop points, crossfade looping, and multi-sample keymapping establishing standard sampling practices.",
      },
      {
        year: 1988,
        figure: "Akai / MPC",
        description:
          "Akai MPC60 (designed by Roger Linn) fused sampling with drum machine sequencing, becoming the foundational instrument of hip-hop and electronic music production.",
      },
      {
        year: 2005,
        figure: "Modern Csound",
        description:
          "Csound provides powerful sample playback opcodes: diskin for streaming from disk, loscil for looping sample playback, and table-based approaches for granular sample manipulation.",
        opcodes: ["diskin", "diskin2", "loscil", "loscil3", "loscilx", "flooper", "flooper2", "sndwarp", "mincer"],
      },
    ],
  },

  "ring modulation": {
    events: [
      {
        year: 1934,
        figure: "Early telecommunications",
        description:
          "Ring modulators were originally developed for telephone signal processing — multiplying two signals to shift frequency content for efficient transmission over telephone lines.",
      },
      {
        year: 1952,
        figure: "Herbert Eimert & Robert Beyer",
        description:
          "At the WDR Studio for Electronic Music in Cologne, ring modulation became one of the first electronic sound transformation techniques used in composition, producing metallic, bell-like timbres.",
      },
      {
        year: 1956,
        figure: "Karlheinz Stockhausen",
        description:
          'Used ring modulation extensively in "Gesang der Junglinge" and later works, exploiting its ability to create sum-and-difference frequency sidebands from acoustic and electronic sources.',
      },
      {
        year: 1961,
        figure: "BBC Radiophonic Workshop",
        description:
          "The Daleks in Doctor Who got their distinctive voice through ring modulation of an actor's voice — perhaps the most widely recognized ring modulation sound in popular culture.",
      },
      {
        year: 1970,
        figure: "Analog synthesizer era",
        description:
          "Ring modulation became a standard module on modular synthesizers (Moog, Buchla, ARP). Multiplying two audio signals produces sum and difference frequencies — inharmonic, metallic, clangorous timbres.",
      },
      {
        year: 2000,
        figure: "Modern Csound",
        description:
          "In Csound, ring modulation is simply the multiplication of two audio signals using the * operator. Amplitude modulation adds a DC offset to keep the carrier partially intact.",
        opcodes: ["*"],
      },
    ],
  },
}
