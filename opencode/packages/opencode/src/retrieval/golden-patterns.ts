/**
 * Keyword → foundational CSD ID mapping (parity with Dr.C-Standalone RAG).
 */

export interface GoldenMatch {
  id: string
  label: string
  source: string
}

const RULES: [RegExp, string, string, string][] = [
  [/\b(generative\s*groovy|jagwani|aman\s*jagwani)\b/i, 'generative-jagwani-subtractive', 'Jagwani generative subtractive', 'Generative Model'],
  [/\b(marston|genjam|csound\s*in\s*the\s*park)\b/i, 'generative-marston-best-sam-s-jam-1-v1', 'Sam Marston GenJam', 'Generative Model'],
  [/\b(groovy|generative\s*beat|metro.*schedkwhen)\b/i, 'generative-jagwani-fm', 'Generative FM groove', 'Generative Model'],
  [/\b(dseq|joaquin.*drum)\b/i, 'drum-joaquin-dseq-quickstart', 'Joaquin dseq', 'Drum Model'],
  [/\b(loop\s*sequencer|16\s*step).*\b(drum|beat)\b/i, 'drum-mccurdy-simple-loop-sequencer', 'McCurdy loop sequencer', 'Drum Model'],
  [/\b(generative\s*drum|metro.*drum)\b/i, 'drum-mccurdy-generative-05e04', 'McCurdy generative drums', 'Drum Model'],
  [/\b(amen\s*break|beat\s*mangl)\b/i, 'drum-amen-beat-mangler', 'Amen beat mangler', 'Drum Model'],
  [/\b(recursive\s*drum|event_i)\b/i, 'drum-lazzarini-recursive', 'Lazzarini recursive drum', 'Drum Model'],
  [/\b(pipa|waveguide\s*pipa|ningxin)\b/i, 'physical-ningxin-waveguide-pipa', 'Ningxin waveguide pipa', 'Physical Model'],
  [/\b(wgflute|waveguide\s*flute)\b/i, 'physical-wgflute', 'wgflute', 'Physical Model'],
  [/\b(karplus|wgpluck)\b/i, 'physical-karplusmath', 'Karplus-Strong', 'Physical Model'],
  [/\b(truax|giordani|timout.*grain)\b/i, 'granular-giordani-truax', 'Giordani Truax granular', 'Granular Model'],
  [/\b(partikkel|live\s*input\s*granular)\b/i, 'granular-brandtsegg-partikkel-starter-kit', 'Partikkel starter', 'Granular Model'],
  [/\b(granular|grain\s+cloud)\b/i, 'granular-boulanger-grainmidi', 'GrainMIDI', 'Granular Model'],
  [/\b(haiku|mccurdy).*\b(ambient|generative)\b/i, 'mccurdy-haiku-i', 'McCurdy Haiku', 'McCurdy Haiku'],
  [/\b(wobble|gbuzz).*\b(bass)\b/i, 'elected-bass-wobble-wobble', 'Bass Wobble', 'Elected Model'],
  [/\b(gendyc)\b/i, 'elected-gendyc-gendycpiece', 'GendyC', 'Elected Model'],
  [/\b(kick\s*drum|synth\s*kick)\b/i, 'drum-element-kick1', 'Synth kick', 'Drum Model'],
  [/\b(drum\s*machine|electronic\s*drum)\b/i, 'drum-drummachine', 'Drum machine', 'Drum Model'],
]

export function matchGoldenPatterns(query: string): GoldenMatch | null {
  const q = query.toLowerCase()
  for (const [re, id, label, source] of RULES) {
    if (re.test(q)) return { id, label, source }
  }
  return null
}
