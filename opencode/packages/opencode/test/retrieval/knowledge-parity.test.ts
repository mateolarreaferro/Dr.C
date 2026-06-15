import { describe, expect, test } from "bun:test"
import { readFileSync, existsSync } from "fs"
import { join } from "path"
import { matchGoldenPatterns } from "../../src/retrieval/golden-patterns"

const KNOWLEDGE = join(import.meta.dir, "..", "..", "resources", "knowledge")

describe("knowledge bundles", () => {
  test("generative bundle present with 27 models", () => {
    const path = join(KNOWLEDGE, "bundle-generative-models.json")
    expect(existsSync(path)).toBe(true)
    const bundle = JSON.parse(readFileSync(path, "utf-8"))
    expect(Object.keys(bundle.contents).length).toBe(27)
  })

  test("catalog-csd bundle present", () => {
    const path = join(KNOWLEDGE, "bundle-csd.json")
    expect(existsSync(path)).toBe(true)
    const bundle = JSON.parse(readFileSync(path, "utf-8"))
    expect(Object.keys(bundle.contents).length).toBeGreaterThan(500)
  })

  test("golden patterns match generative queries", () => {
    const m = matchGoldenPatterns("make a groovy generative beat like Jagwani")
    expect(m?.id).toBe("generative-jagwani-subtractive")
  })

  test("golden patterns match drum queries", () => {
    const m = matchGoldenPatterns("synth kick drum 808")
    expect(m?.id).toBe("drum-element-kick1")
  })
})
