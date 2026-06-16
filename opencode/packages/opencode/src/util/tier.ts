/** Paid / workshop Pro+ tier — optional Gemini Pro for narration/consults. */
export function isProPlus(): boolean {
  return process.env.DRC_PRO_PLUS !== "0"
}

/** One cheap model call per turn. Off when Pro+ (narration + consults enabled). */
export function isWorkshopLite(): boolean {
  if (isProPlus()) return false
  return process.env.DRC_WORKSHOP_LITE !== "0"
}
