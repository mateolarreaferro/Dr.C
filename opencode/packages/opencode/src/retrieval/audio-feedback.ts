import { Log } from "../util/log"
import type { RetrievalFeedback } from "./feedback"

const log = Log.create({ service: "retrieval.audio-feedback" })

export namespace AudioFeedback {
  export interface AudioAnalysis {
    peakAmplitude: number
    rmsLevel: number
    duration: number
    sampleRate: number
    channels: number
    bitDepth: number
    silent: boolean
    clipping: boolean
  }

  /**
   * Analyze a WAV file to derive audio quality feedback signals.
   * Reads the WAV header (44 bytes) and scans PCM data for peak/RMS levels.
   */
  export async function analyzeWav(wavPath: string): Promise<AudioAnalysis | null> {
    try {
      const file = Bun.file(wavPath)
      if (!(await file.exists())) return null

      const buffer = await file.arrayBuffer()
      if (buffer.byteLength < 44) return null

      const view = new DataView(buffer)

      // Verify RIFF header
      const riff = String.fromCharCode(view.getUint8(0), view.getUint8(1), view.getUint8(2), view.getUint8(3))
      if (riff !== "RIFF") return null

      const wave = String.fromCharCode(view.getUint8(8), view.getUint8(9), view.getUint8(10), view.getUint8(11))
      if (wave !== "WAVE") return null

      // Parse format chunk
      const channels = view.getUint16(22, true)
      const sampleRate = view.getUint32(24, true)
      const bitDepth = view.getUint16(34, true)

      // Find data chunk (may not be at offset 36)
      let dataOffset = 36
      let dataSize = 0
      while (dataOffset < buffer.byteLength - 8) {
        const chunkId = String.fromCharCode(
          view.getUint8(dataOffset),
          view.getUint8(dataOffset + 1),
          view.getUint8(dataOffset + 2),
          view.getUint8(dataOffset + 3),
        )
        const chunkSize = view.getUint32(dataOffset + 4, true)
        if (chunkId === "data") {
          dataSize = chunkSize
          dataOffset += 8
          break
        }
        dataOffset += 8 + chunkSize
      }

      if (dataSize === 0) return null

      const bytesPerSample = bitDepth / 8
      const totalSamples = Math.min(dataSize / bytesPerSample, (buffer.byteLength - dataOffset) / bytesPerSample)
      const duration = totalSamples / (sampleRate * channels)

      // Scan PCM data for peak and RMS
      let peak = 0
      let sumSquares = 0
      const maxVal = bitDepth === 16 ? 32768 : bitDepth === 24 ? 8388608 : 1

      // Sample a subset for efficiency (every Nth sample for large files)
      const step = totalSamples > 100000 ? Math.floor(totalSamples / 100000) : 1
      let samplesRead = 0

      for (let i = 0; i < totalSamples && dataOffset + i * bytesPerSample < buffer.byteLength; i += step) {
        const offset = dataOffset + i * bytesPerSample
        let sample: number

        if (bitDepth === 16) {
          sample = view.getInt16(offset, true) / maxVal
        } else if (bitDepth === 24) {
          const b0 = view.getUint8(offset)
          const b1 = view.getUint8(offset + 1)
          const b2 = view.getInt8(offset + 2)
          sample = ((b2 << 16) | (b1 << 8) | b0) / maxVal
        } else if (bitDepth === 32) {
          sample = view.getFloat32(offset, true)
        } else {
          continue
        }

        const abs = Math.abs(sample)
        if (abs > peak) peak = abs
        sumSquares += sample * sample
        samplesRead++
      }

      const rmsLevel = samplesRead > 0 ? Math.sqrt(sumSquares / samplesRead) : 0
      const rmsDb = rmsLevel > 0 ? 20 * Math.log10(rmsLevel) : -100

      const silent = rmsDb < -60
      const clipping = peak > 0.99

      log.info("audio analysis", {
        path: wavPath,
        duration: duration.toFixed(2),
        peakDb: (20 * Math.log10(peak || 0.0001)).toFixed(1),
        rmsDb: rmsDb.toFixed(1),
        silent,
        clipping,
      })

      return {
        peakAmplitude: peak,
        rmsLevel,
        duration,
        sampleRate,
        channels,
        bitDepth,
        silent,
        clipping,
      }
    } catch (e) {
      log.error("audio analysis failed", { error: e, path: wavPath })
      return null
    }
  }

  /**
   * Derive a feedback signal from audio analysis results.
   */
  export function deriveAudioSignal(
    analysis: AudioAnalysis,
  ): "render_success" | "audio_silent" | "audio_clipping" {
    if (analysis.silent) return "audio_silent"
    if (analysis.clipping) return "audio_clipping"
    return "render_success"
  }
}
