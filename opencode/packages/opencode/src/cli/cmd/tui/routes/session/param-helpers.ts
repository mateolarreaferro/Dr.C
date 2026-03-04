import { CsdParser } from "@/csound/parser"

export interface FlatParam {
  group: string
  label: string
  param: CsdParser.CsdParameter
  index: number
  range: [number, number]
  unit: string
}

/** Strip rate prefix (i/k/a/S) and capitalize: iFreq → Freq, kCutoff → Cutoff */
export function cleanParamName(name: string): string {
  if (/^[ikaS][A-Z]/.test(name)) return name.slice(1)
  return name
}

/** Infer a sensible range from the parameter name and current value */
export function inferRange(param: CsdParser.CsdParameter): [number, number] {
  // If the parser already set a real range (varying pfield, widget, etc.), use it
  if (param.range && param.range[0] !== param.range[1]) return param.range

  const val = parseFloat(param.value ?? "0")
  const name = param.name.toLowerCase()

  if (/freq/.test(name)) return [20, Math.max(val * 4, 2000)]
  if (/amp|gain|level|vol/.test(name)) return [0, 1]
  if (/pan/.test(name)) return [-1, 1]
  if (/decay|attack|release|sustain/.test(name)) return [0, Math.max(val * 4, 10)]
  if (/cutoff/.test(name)) return [20, 20000]
  if (/res/.test(name)) return [0, 1]
  if (/ratio/.test(name)) return [0, Math.max(val * 4, 20)]
  if (/depth|width|mix|feedback/.test(name)) return [0, 1]
  if (/rate/.test(name)) return [0, Math.max(val * 4, 20)]

  if (val === 0) return [0, 1]
  if (val > 0) return [0, val * 4]
  return [val * 4, 0]
}

/** Infer unit label from parameter name */
export function inferUnit(name: string): string {
  const n = name.toLowerCase()
  if (/freq|cutoff/.test(n)) return "Hz"
  if (/time|decay|attack|release|sustain|del/.test(n)) return "s"
  if (/amp|gain|level|vol|depth|mix|feedback|width/.test(n)) return ""
  if (/pan/.test(n)) return ""
  if (/rate/.test(n)) return "Hz"
  return ""
}

/** Flatten all CSD parameters into a single list with pre-computed labels and ranges */
export function buildFlatParams(structure: CsdParser.CsdStructure): FlatParam[] {
  const result: FlatParam[] = []
  let idx = 0
  const multipleInstruments = structure.instruments.length > 1

  // Global macros first
  const globalParams = structure.parameters.filter(
    (p) => p.source === "define" && p.value !== undefined,
  )
  for (const p of globalParams) {
    result.push({
      group: "global",
      label: p.name,
      param: p,
      index: idx++,
      range: inferRange(p),
      unit: inferUnit(p.name),
    })
  }

  // Then by instrument
  const seen = new Set(globalParams.map((p) => p.name))
  for (const instr of structure.instruments) {
    const tuneableParams = instr.parameters.filter(
      (p) => p.value !== undefined
        && !seen.has(p.name)
        && !isNaN(parseFloat(p.value!))
        && !(p as any).pfieldVaries,
    )
    for (const p of tuneableParams) {
      const clean = cleanParamName(p.name)
      const label = multipleInstruments ? `${instr.id}:${clean}` : clean
      result.push({
        group: `instr ${instr.id}`,
        label,
        param: p,
        index: idx++,
        range: inferRange(p),
        unit: inferUnit(p.name),
      })
      seen.add(p.name)
    }
  }

  return result
}
