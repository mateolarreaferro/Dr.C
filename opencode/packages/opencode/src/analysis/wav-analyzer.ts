import { Log } from "../util/log"

const log = Log.create({ service: "analysis.wav-analyzer" })

export namespace WavAnalyzer {
  export interface WavHeader {
    sampleRate: number
    channels: number
    bitsPerSample: number
    duration: number
    dataOffset: number
    dataSize: number
  }

  /**
   * Parse WAV header to get format info.
   * Handles standard 16-bit and 24-bit PCM WAV files.
   */
  export async function parseHeader(wavPath: string): Promise<WavHeader> {
    const file = Bun.file(wavPath)
    if (!(await file.exists())) {
      throw new Error(`WAV file not found: ${wavPath}`)
    }

    const buffer = await file.arrayBuffer()
    if (buffer.byteLength < 44) {
      throw new Error(`File too small to be a valid WAV: ${wavPath}`)
    }

    const view = new DataView(buffer)

    // Verify RIFF header
    const riff = readString(view, 0, 4)
    if (riff !== "RIFF") throw new Error(`Not a RIFF file: ${wavPath}`)

    const wave = readString(view, 8, 4)
    if (wave !== "WAVE") throw new Error(`Not a WAVE file: ${wavPath}`)

    // Find fmt chunk
    let offset = 12
    let sampleRate = 0
    let channels = 0
    let bitsPerSample = 0
    let dataOffset = 0
    let dataSize = 0

    while (offset < buffer.byteLength - 8) {
      const chunkId = readString(view, offset, 4)
      const chunkSize = view.getUint32(offset + 4, true)

      if (chunkId === "fmt ") {
        channels = view.getUint16(offset + 10, true)
        sampleRate = view.getUint32(offset + 12, true)
        bitsPerSample = view.getUint16(offset + 22, true)
      } else if (chunkId === "data") {
        dataOffset = offset + 8
        dataSize = chunkSize
        break
      }

      offset += 8 + chunkSize
      // Chunks are word-aligned
      if (chunkSize % 2 !== 0) offset++
    }

    if (sampleRate === 0 || channels === 0 || bitsPerSample === 0) {
      throw new Error(`Could not parse WAV format info: ${wavPath}`)
    }

    if (dataOffset === 0) {
      throw new Error(`Could not find data chunk: ${wavPath}`)
    }

    const bytesPerSample = bitsPerSample / 8
    const totalSamples = dataSize / bytesPerSample / channels
    const duration = totalSamples / sampleRate

    return { sampleRate, channels, bitsPerSample, duration, dataOffset, dataSize }
  }

  /**
   * Get RMS amplitude at a specific timestamp (+/-50ms window).
   * Returns RMS as a linear amplitude value (0.0 to 1.0).
   */
  export async function rmsAtTimestamp(wavPath: string, timestampSec: number): Promise<number> {
    const header = await parseHeader(wavPath)
    const windowSec = 0.05 // 50ms
    const startSec = Math.max(0, timestampSec - windowSec)
    const endSec = Math.min(header.duration, timestampSec + windowSec)

    const samples = await readSamples(wavPath, header, startSec, endSec)
    if (samples.length === 0) return 0

    let sumSquares = 0
    for (let i = 0; i < samples.length; i++) {
      sumSquares += samples[i] * samples[i]
    }
    return Math.sqrt(sumSquares / samples.length)
  }

  /**
   * Get peak amplitude in a time range.
   * Returns peak as a linear amplitude value (0.0 to 1.0).
   */
  export async function peakInRange(wavPath: string, startSec: number, endSec: number): Promise<number> {
    const header = await parseHeader(wavPath)
    const clampedStart = Math.max(0, startSec)
    const clampedEnd = Math.min(header.duration, endSec)

    const samples = await readSamples(wavPath, header, clampedStart, clampedEnd)
    if (samples.length === 0) return 0

    let peak = 0
    for (let i = 0; i < samples.length; i++) {
      const abs = Math.abs(samples[i])
      if (abs > peak) peak = abs
    }
    return peak
  }

  /**
   * Simple spectral centroid estimate at timestamp using zero-crossing rate.
   * Returns an estimated frequency in Hz (brightness indicator).
   * Higher values = brighter/harsher sound.
   */
  export async function spectralCentroid(wavPath: string, timestampSec: number): Promise<number> {
    const header = await parseHeader(wavPath)
    const windowSec = 0.05 // 50ms window
    const startSec = Math.max(0, timestampSec - windowSec)
    const endSec = Math.min(header.duration, timestampSec + windowSec)

    const samples = await readSamples(wavPath, header, startSec, endSec)
    if (samples.length < 2) return 0

    // Zero-crossing rate as a brightness proxy
    let crossings = 0
    for (let i = 1; i < samples.length; i++) {
      if ((samples[i] >= 0 && samples[i - 1] < 0) || (samples[i] < 0 && samples[i - 1] >= 0)) {
        crossings++
      }
    }

    const durationSec = samples.length / header.sampleRate
    // Each zero crossing corresponds to half a cycle
    const estimatedFreq = crossings / (2 * durationSec)

    return estimatedFreq
  }

  /**
   * Detect silence regions where RMS falls below threshold.
   * @param thresholdDb - Threshold in dB (e.g., -60 for very quiet)
   */
  export async function detectSilence(
    wavPath: string,
    thresholdDb: number,
  ): Promise<Array<{ startSec: number; endSec: number }>> {
    const header = await parseHeader(wavPath)
    const thresholdLinear = Math.pow(10, thresholdDb / 20)

    // Analyze in 50ms windows
    const windowSec = 0.05
    const regions: Array<{ startSec: number; endSec: number }> = []
    let silenceStart: number | null = null

    for (let t = 0; t < header.duration; t += windowSec) {
      const endT = Math.min(t + windowSec, header.duration)
      const samples = await readSamples(wavPath, header, t, endT)

      // Calculate RMS for this window
      let sumSquares = 0
      for (let i = 0; i < samples.length; i++) {
        sumSquares += samples[i] * samples[i]
      }
      const rms = samples.length > 0 ? Math.sqrt(sumSquares / samples.length) : 0

      if (rms < thresholdLinear) {
        if (silenceStart === null) silenceStart = t
      } else {
        if (silenceStart !== null) {
          regions.push({ startSec: silenceStart, endSec: t })
          silenceStart = null
        }
      }
    }

    // Close trailing silence region
    if (silenceStart !== null) {
      regions.push({ startSec: silenceStart, endSec: header.duration })
    }

    return regions
  }

  // --- Internal helpers ---

  function readString(view: DataView, offset: number, length: number): string {
    let str = ""
    for (let i = 0; i < length; i++) {
      str += String.fromCharCode(view.getUint8(offset + i))
    }
    return str
  }

  /**
   * Read PCM samples from a WAV file as Float32 values in [-1, 1].
   * Handles 16-bit and 24-bit PCM. Mixes all channels to mono.
   */
  async function readSamples(
    wavPath: string,
    header: WavHeader,
    startSec: number,
    endSec: number,
  ): Promise<Float32Array> {
    const file = Bun.file(wavPath)
    const buffer = await file.arrayBuffer()
    const view = new DataView(buffer)

    const bytesPerSample = header.bitsPerSample / 8
    const frameSize = bytesPerSample * header.channels

    const startFrame = Math.floor(startSec * header.sampleRate)
    const endFrame = Math.min(Math.ceil(endSec * header.sampleRate), header.dataSize / frameSize)
    const frameCount = endFrame - startFrame

    if (frameCount <= 0) return new Float32Array(0)

    const output = new Float32Array(frameCount)
    const startByte = header.dataOffset + startFrame * frameSize

    for (let i = 0; i < frameCount; i++) {
      let monoSample = 0
      const frameOffset = startByte + i * frameSize

      for (let ch = 0; ch < header.channels; ch++) {
        const sampleOffset = frameOffset + ch * bytesPerSample

        if (sampleOffset + bytesPerSample > buffer.byteLength) break

        let sample: number
        if (header.bitsPerSample === 16) {
          sample = view.getInt16(sampleOffset, true) / 32768
        } else if (header.bitsPerSample === 24) {
          // Read 3 bytes as signed 24-bit integer
          const b0 = view.getUint8(sampleOffset)
          const b1 = view.getUint8(sampleOffset + 1)
          const b2 = view.getUint8(sampleOffset + 2)
          let int24 = b0 | (b1 << 8) | (b2 << 16)
          if (int24 & 0x800000) int24 |= ~0xffffff // sign extend
          sample = int24 / 8388608
        } else {
          // Fallback: treat as 16-bit
          sample = view.getInt16(sampleOffset, true) / 32768
        }

        monoSample += sample
      }

      output[i] = monoSample / header.channels
    }

    return output
  }
}
