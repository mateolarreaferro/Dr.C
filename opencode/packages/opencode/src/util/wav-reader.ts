import { Log } from "./log"

const log = Log.create({ service: "wav-reader" })

export namespace WavReader {
  export interface WavInfo {
    sampleRate: number
    channels: number
    bitDepth: number
    duration: number
    dataSize: number
    peaks: number[]
    peakDb: number
  }

  /**
   * Read a WAV file and downsample to N columns of peak amplitudes.
   * Returns peaks normalized to [0, 1] range.
   */
  export async function read(wavPath: string, columns: number = 60): Promise<WavInfo | null> {
    try {
      const file = Bun.file(wavPath)
      if (!(await file.exists())) return null

      const buffer = await file.arrayBuffer()
      if (buffer.byteLength < 44) return null

      const view = new DataView(buffer)

      // Verify RIFF/WAVE header
      const riff = String.fromCharCode(view.getUint8(0), view.getUint8(1), view.getUint8(2), view.getUint8(3))
      if (riff !== "RIFF") return null
      const wave = String.fromCharCode(view.getUint8(8), view.getUint8(9), view.getUint8(10), view.getUint8(11))
      if (wave !== "WAVE") return null

      const channels = view.getUint16(22, true)
      const sampleRate = view.getUint32(24, true)
      const bitDepth = view.getUint16(34, true)

      // Find data chunk
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
      const totalSamples = Math.floor(Math.min(dataSize, buffer.byteLength - dataOffset) / bytesPerSample)
      const duration = totalSamples / (sampleRate * channels)

      if (totalSamples === 0) return null

      // Compute peak amplitude per column
      const samplesPerColumn = Math.max(1, Math.floor(totalSamples / columns))
      const peaks: number[] = []
      let globalPeak = 0

      for (let col = 0; col < columns; col++) {
        const startSample = col * samplesPerColumn
        const endSample = Math.min(startSample + samplesPerColumn, totalSamples)
        let colPeak = 0

        for (let i = startSample; i < endSample; i++) {
          const offset = dataOffset + i * bytesPerSample
          if (offset + bytesPerSample > buffer.byteLength) break

          let sample: number
          if (bitDepth === 16) {
            sample = Math.abs(view.getInt16(offset, true) / 32768)
          } else if (bitDepth === 24) {
            const b0 = view.getUint8(offset)
            const b1 = view.getUint8(offset + 1)
            const b2 = view.getInt8(offset + 2)
            sample = Math.abs(((b2 << 16) | (b1 << 8) | b0) / 8388608)
          } else if (bitDepth === 32) {
            sample = Math.abs(view.getFloat32(offset, true))
          } else {
            sample = 0
          }

          if (sample > colPeak) colPeak = sample
        }

        peaks.push(colPeak)
        if (colPeak > globalPeak) globalPeak = colPeak
      }

      const peakDb = globalPeak > 0 ? 20 * Math.log10(globalPeak) : -100

      return {
        sampleRate,
        channels,
        bitDepth,
        duration,
        dataSize,
        peaks,
        peakDb,
      }
    } catch (e) {
      log.error("wav read failed", { error: e, path: wavPath })
      return null
    }
  }
}
