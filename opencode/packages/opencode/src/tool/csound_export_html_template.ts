/**
 * Generates a self-contained HTML file that plays a CSD using @csound/browser@7 from CDN.
 * Ultra-minimal playback page with parameter sliders and signal flow diagram.
 */
export function generateCsoundHTML(
  csdContent: string,
  title: string,
  theme: "light" | "dark" = "light",
): string {
  // Extract parameters and rewrite CSD to use channels for slider control
  const params = extractParams(csdContent)
  const rewrittenCsd = params.length > 0 ? rewriteCsdForChannels(csdContent, params) : csdContent
  const flowDiagram = buildSignalFlow(csdContent)

  const escapedCsd = rewrittenCsd
    .replace(/\\/g, "\\\\")
    .replace(/`/g, "\\`")
    .replace(/\$/g, "\\$")

  const paramsJSON = JSON.stringify(params)

  const isLight = theme === "light"
  const bg = isLight ? "#fafafa" : "#0a0a0a"
  const text = isLight ? "#1a1a1a" : "#f0f0f0"
  const muted = isLight ? "#999" : "#666"
  const accent = isLight ? "#1a1a1a" : "#f0f0f0"
  const codeBg = isLight ? "#f5f5f5" : "#1a1a1a"
  const canvasFg = isLight ? "40, 40, 40" : "220, 220, 220"
  const borderColor = isLight ? "#e8e8e8" : "#222"
  const detailsBorder = isLight ? "#eee" : "#1e1e1e"
  const hoverBg = isLight ? "#f0f0f0" : "#1a1a1a"
  const shadowColor = isLight
    ? "rgba(0, 0, 0, 0.08)"
    : "rgba(255, 255, 255, 0.04)"
  const pulseRing = isLight
    ? "rgba(26, 26, 26, 0.15)"
    : "rgba(240, 240, 240, 0.12)"
  const sliderTrack = isLight ? "#ddd" : "#333"

  // Signal flow colors
  const flowColors: Record<string, string> = {
    source: isLight ? "#16a34a" : "#4ade80",
    filter: isLight ? "#2563eb" : "#60a5fa",
    effect: isLight ? "#9333ea" : "#c084fc",
    output: isLight ? "#dc2626" : "#f87171",
    envelope: isLight ? "#ca8a04" : "#fbbf24",
    modulator: isLight ? "#0891b2" : "#22d3ee",
    other: isLight ? "#64748b" : "#94a3b8",
  }
  const flowColorsJSON = JSON.stringify(flowColors)

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${escapeHTML(title)}</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    background: ${bg};
    color: ${text};
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    -webkit-font-smoothing: antialiased;
  }

  .container {
    width: 100%;
    max-width: 480px;
    padding: 3rem 1.5rem;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1.5rem;
  }

  .title {
    font-size: 1.25rem;
    font-weight: 600;
    letter-spacing: -0.02em;
    text-align: center;
  }

  .meta { font-size: 0.8rem; color: ${muted}; margin-top: -0.75rem; }

  .play-wrap {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .play-btn {
    width: 80px; height: 80px;
    border-radius: 50%; border: none;
    background: ${accent};
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    position: relative; z-index: 1;
    box-shadow: 0 2px 20px ${shadowColor};
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .play-btn:hover { transform: scale(1.05); box-shadow: 0 4px 30px ${shadowColor}; }
  .play-btn:active { transform: scale(0.97); }
  .play-btn:disabled { opacity: 0.4; cursor: not-allowed; transform: none; }

  .icon-play {
    width: 0; height: 0;
    border-style: solid;
    border-width: 12px 0 12px 22px;
    border-color: transparent transparent transparent ${isLight ? "#fff" : "#0a0a0a"};
    margin-left: 4px;
  }

  .icon-pause { display: flex; gap: 6px; }
  .icon-pause span {
    display: block; width: 5px; height: 22px;
    background: ${isLight ? "#fff" : "#0a0a0a"};
    border-radius: 2px;
  }

  .pulse-ring {
    position: absolute; width: 80px; height: 80px;
    border-radius: 50%;
    border: 2px solid ${pulseRing};
    opacity: 0; pointer-events: none;
  }

  .playing .pulse-ring { animation: pulse 2s ease-out infinite; }

  @keyframes pulse {
    0% { transform: scale(1); opacity: 0.6; }
    100% { transform: scale(1.8); opacity: 0; }
  }

  .canvas-wrap { width: 100%; height: 80px; }
  canvas { width: 100%; height: 100%; display: block; border-radius: 8px; }

  .status {
    font-size: 0.75rem; color: ${muted};
    letter-spacing: 0.04em; text-transform: uppercase;
    min-height: 1.2em;
  }
  .status.error { color: #e54; }

  /* Signal flow */
  .flow {
    width: 100%;
    padding: 1rem;
    border: 1px solid ${detailsBorder};
    border-radius: 8px;
    overflow-x: auto;
  }

  .flow-title {
    font-size: 0.75rem;
    color: ${muted};
    letter-spacing: 0.04em;
    text-transform: uppercase;
    margin-bottom: 0.75rem;
  }

  .flow-level {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
    align-items: center;
  }

  .flow-node {
    font-size: 0.75rem;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    border: 1px solid;
    white-space: nowrap;
    font-family: 'SF Mono', 'Fira Code', monospace;
  }

  .flow-arrow {
    color: ${muted};
    font-size: 0.7rem;
    flex-shrink: 0;
  }

  /* Controls */
  .controls-toggle {
    font-size: 0.8rem; color: ${muted};
    background: none; border: 1px solid ${detailsBorder};
    border-radius: 6px; padding: 0.4rem 0.9rem;
    cursor: pointer; transition: all 0.2s ease;
  }
  .controls-toggle:hover { border-color: ${borderColor}; color: ${text}; }

  .controls-panel {
    width: 100%;
    display: none;
    flex-direction: column;
    gap: 1rem;
  }
  .controls-panel.visible { display: flex; }

  .param {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .param-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
  }

  .param-name { font-size: 0.8rem; font-weight: 500; }
  .param-value {
    font-size: 0.75rem; color: ${muted};
    font-family: 'SF Mono', 'Fira Code', monospace;
    min-width: 3.5em; text-align: right;
  }

  input[type="range"] {
    -webkit-appearance: none; appearance: none;
    width: 100%; height: 4px;
    border-radius: 2px;
    background: ${sliderTrack};
    outline: none; cursor: pointer;
  }

  input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none; appearance: none;
    width: 16px; height: 16px;
    border-radius: 50%;
    background: ${accent};
    border: none;
    box-shadow: 0 1px 4px ${shadowColor};
    transition: transform 0.15s ease;
  }
  input[type="range"]::-webkit-slider-thumb:hover { transform: scale(1.2); }

  input[type="range"]::-moz-range-thumb {
    width: 16px; height: 16px;
    border-radius: 50%;
    background: ${accent};
    border: none; cursor: pointer;
  }

  details {
    width: 100%;
    border: 1px solid ${detailsBorder};
    border-radius: 8px; overflow: hidden;
  }
  details[open] { border-color: ${borderColor}; }

  summary {
    padding: 0.75rem 1rem;
    font-size: 0.8rem; color: ${muted};
    cursor: pointer; user-select: none;
    list-style: none;
    display: flex; align-items: center; gap: 0.5rem;
    transition: background 0.2s ease;
  }
  summary::-webkit-details-marker { display: none; }
  summary::before {
    content: "\\203A"; font-size: 1.1rem;
    transition: transform 0.2s ease; display: inline-block;
  }
  details[open] summary::before { transform: rotate(90deg); }
  summary:hover { background: ${hoverBg}; color: ${text}; }

  .code-block {
    background: ${codeBg}; padding: 1rem; overflow-x: auto;
    font-family: 'SF Mono', 'Fira Code', monospace;
    font-size: 0.75rem; line-height: 1.6;
    white-space: pre; tab-size: 2; color: ${muted};
    max-height: 300px; overflow-y: auto;
  }

  .debug-log {
    background: ${codeBg}; padding: 0.75rem 1rem;
    font-family: 'SF Mono', 'Fira Code', monospace;
    font-size: 0.7rem; line-height: 1.6; color: ${muted};
    max-height: 180px; overflow-y: auto;
    white-space: pre-wrap; word-break: break-all;
  }

  .footer {
    font-size: 0.7rem; color: ${muted};
    opacity: 0.6; transition: opacity 0.2s ease;
  }
  .footer:hover { opacity: 1; }

  ::-webkit-scrollbar { width: 4px; height: 4px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: ${borderColor}; border-radius: 4px; }
</style>
</head>
<body>

<div class="container">
  <h1 class="title">${escapeHTML(title)}</h1>
  <p class="meta">Csound instrument</p>

  <div class="play-wrap" id="playWrap">
    <div class="pulse-ring"></div>
    <button class="play-btn" id="playBtn" aria-label="Play">
      <div class="icon-play" id="btnIcon"></div>
    </button>
  </div>

  <div class="canvas-wrap">
    <canvas id="waveform"></canvas>
  </div>

  <div class="status" id="status"></div>

  ${flowDiagram ? `<div class="flow">
    <div class="flow-title">Signal Flow</div>
    ${flowDiagram}
  </div>` : ""}

  <div id="controlsSection"></div>

  <details>
    <summary>View CSD</summary>
    <div class="code-block">${escapeHTML(csdContent)}</div>
  </details>

  <details>
    <summary>Debug</summary>
    <div class="debug-log" id="console"></div>
  </details>

  <div class="footer">Made with DrC</div>
</div>

<script type="module">
const CSD = \`${escapedCsd}\`;
const CSOUND_URL = "https://cdn.jsdelivr.net/npm/@csound/browser@7.0.0-beta28/dist/csound.js";
const CANVAS_FG = "${canvasFg}";
const PARAMS = ${paramsJSON};
const FLOW_COLORS = ${flowColorsJSON};

let csound = null;
let audioCtx = null;
let analyser = null;
let animFrame = null;
let isPlaying = false;
let isLoaded = false;

const playBtn = document.getElementById("playBtn");
const btnIcon = document.getElementById("btnIcon");
const playWrap = document.getElementById("playWrap");
const statusEl = document.getElementById("status");
const canvas = document.getElementById("waveform");
const ctx = canvas.getContext("2d");
const consoleEl = document.getElementById("console");
const controlsSection = document.getElementById("controlsSection");

// Build controls UI
if (PARAMS.length > 0) {
  const toggleBtn = document.createElement("button");
  toggleBtn.className = "controls-toggle";
  toggleBtn.textContent = "Controls";

  const panel = document.createElement("div");
  panel.className = "controls-panel";

  toggleBtn.addEventListener("click", () => {
    const vis = panel.classList.toggle("visible");
    toggleBtn.textContent = vis ? "Hide controls" : "Controls";
  });

  controlsSection.appendChild(toggleBtn);
  controlsSection.appendChild(panel);

  for (const p of PARAMS) {
    const div = document.createElement("div");
    div.className = "param";

    const header = document.createElement("div");
    header.className = "param-header";

    const nameEl = document.createElement("span");
    nameEl.className = "param-name";
    nameEl.textContent = p.label;
    header.appendChild(nameEl);

    const valEl = document.createElement("span");
    valEl.className = "param-value";
    valEl.textContent = fmtVal(p.value, p.step);
    header.appendChild(valEl);

    div.appendChild(header);

    const slider = document.createElement("input");
    slider.type = "range";
    slider.min = p.min;
    slider.max = p.max;
    slider.step = p.step;
    slider.value = p.value;
    slider.dataset.channel = p.channel;
    slider.addEventListener("input", () => {
      valEl.textContent = fmtVal(parseFloat(slider.value), p.step);
      if (csound && isPlaying) {
        csound.setControlChannel(p.channel, parseFloat(slider.value));
      }
    });
    div.appendChild(slider);
    panel.appendChild(div);
  }
}

function fmtVal(v, step) {
  if (step >= 1) return Math.round(v).toString();
  const d = Math.min(3, Math.max(0, Math.ceil(-Math.log10(step))));
  return v.toFixed(d);
}

function setStatus(msg, isError) {
  statusEl.textContent = msg;
  statusEl.className = isError ? "status error" : "status";
}

function log(msg) {
  consoleEl.textContent += msg + "\\n";
  consoleEl.scrollTop = consoleEl.scrollHeight;
}

function setPlayIcon() { btnIcon.className = "icon-play"; btnIcon.innerHTML = ""; }
function setPauseIcon() { btnIcon.className = "icon-pause"; btnIcon.innerHTML = "<span></span><span></span>"; }

function resizeCanvas() {
  const rect = canvas.parentElement.getBoundingClientRect();
  canvas.width = rect.width * (window.devicePixelRatio || 1);
  canvas.height = rect.height * (window.devicePixelRatio || 1);
}

function drawWaveform() {
  if (!analyser) return;
  animFrame = requestAnimationFrame(drawWaveform);
  const bufLen = analyser.frequencyBinCount;
  const data = new Uint8Array(bufLen);
  analyser.getByteFrequencyData(data);
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0, 0, w, h);
  const barCount = Math.min(bufLen, 64);
  const step = Math.floor(bufLen / barCount);
  const barWidth = w / barCount;
  const gap = Math.max(1, barWidth * 0.3);
  for (let i = 0; i < barCount; i++) {
    const val = data[i * step] / 255;
    const barH = val * h * 0.85;
    const x = i * barWidth + gap / 2;
    const bw = barWidth - gap;
    const y = (h - barH) / 2;
    ctx.fillStyle = "rgba(" + CANVAS_FG + "," + (0.15 + val * 0.6).toFixed(2) + ")";
    ctx.beginPath(); ctx.roundRect(x, y, bw, barH, 2); ctx.fill();
  }
}

function drawIdle() {
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0, 0, w, h);
  const barCount = 64, barWidth = w / barCount;
  const gap = Math.max(1, barWidth * 0.3);
  for (let i = 0; i < barCount; i++) {
    const x = i * barWidth + gap / 2;
    ctx.fillStyle = "rgba(" + CANVAS_FG + ",0.1)";
    ctx.beginPath(); ctx.roundRect(x, (h-2)/2, barWidth-gap, 2, 1); ctx.fill();
  }
}

async function initCsound() {
  setStatus("Loading Csound..."); playBtn.disabled = true;
  log("[DrC] Loading Csound engine...");
  const { Csound } = await import(CSOUND_URL);
  audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  if (audioCtx.state === "suspended") await audioCtx.resume();
  csound = await Csound({ audioContext: audioCtx });
  await csound.setOption("-odac");
  await csound.on("message", log);
  await csound.compileCSD(CSD);
  analyser = audioCtx.createAnalyser();
  analyser.fftSize = 256; analyser.smoothingTimeConstant = 0.8;
  if (csound.getNode) {
    const node = await csound.getNode();
    if (node) { node.connect(analyser); analyser.connect(audioCtx.destination); }
  }
  isLoaded = true; playBtn.disabled = false;
  log("[DrC] Csound engine ready");
}

async function toggle() {
  if (playBtn.disabled) return;
  try {
    if (!isLoaded) await initCsound();
    if (audioCtx && audioCtx.state === "suspended") await audioCtx.resume();
    if (!isPlaying) {
      // Set slider values as channel defaults
      for (const p of PARAMS) {
        const sl = document.querySelector('input[data-channel="' + p.channel + '"]');
        if (sl && csound) csound.setControlChannel(p.channel, parseFloat(sl.value));
      }
      await csound.start();
      isPlaying = true; setStatus("Playing"); setPauseIcon();
      playWrap.classList.add("playing"); drawWaveform();
      log("[DrC] Playback started");
    } else {
      if (animFrame) cancelAnimationFrame(animFrame);
      await csound.stop(); csound = null; isLoaded = false; isPlaying = false;
      if (analyser) { analyser.disconnect(); analyser = null; }
      if (audioCtx) { await audioCtx.close(); audioCtx = null; }
      setStatus("Paused"); setPlayIcon();
      playWrap.classList.remove("playing"); drawIdle();
      log("[DrC] Playback stopped");
    }
  } catch (err) {
    setStatus("Error: " + err.message, true);
    log("[Error] " + err.message);
    playBtn.disabled = false; setPlayIcon(); playWrap.classList.remove("playing");
  }
}

playBtn.addEventListener("click", toggle);
window.addEventListener("resize", () => { resizeCanvas(); if (!isPlaying) drawIdle(); });
resizeCanvas(); drawIdle();
</script>
</body>
</html>`
}

// ─── Parameter extraction ───

interface ExportParam {
  channel: string
  label: string
  value: number
  min: number
  max: number
  step: number
}

/**
 * Extract controllable parameters from CSD content.
 * Detects chnget channels AND k-rate constant assignments (kVar = VALUE).
 */
function extractParams(csd: string): ExportParam[] {
  const params: ExportParam[] = []
  const seen = new Set<string>()
  const lines = csd.split("\n")

  // 1. chnget-based channels
  const chngetRe = /\b(k\w+)\s+chnget\s+"([^"]+)"/g
  const chngetFuncRe = /\b(k\w+)\s*=\s*chnget:k\(\s*"([^"]+)"\s*\)/g

  for (const re of [chngetRe, chngetFuncRe]) {
    for (const m of csd.matchAll(re)) {
      const varName = m[1]
      const channel = m[2]
      if (seen.has(channel)) continue
      seen.add(channel)
      const { value, min, max } = inferRange(channel, varName, lines)
      const label = humanLabel(channel)
      const step = computeStep(min, max)
      params.push({ channel, label, value, min, max, step })
    }
  }

  // 2. k-rate constant assignments: kVar = NUMBER (standalone, not expressions)
  // These are the typical DrC pattern for tunable parameters
  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].replace(/;.*$/, "").trim()
    const comment = lines[i].includes(";") ? lines[i].slice(lines[i].indexOf(";")) : ""

    // Match kVarName = 1234 (but NOT kVar = expression with other vars)
    const m = trimmed.match(/^(k\w+)\s*=\s*([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)\s*$/)
    if (!m) continue

    const varName = m[1]
    const rawValue = parseFloat(m[2])
    if (isNaN(rawValue)) continue
    if (seen.has(varName)) continue

    // Skip loop counters, indices, internal state
    const lower = varName.toLowerCase()
    if (lower.includes("ndx") || lower.includes("count") || lower.includes("flag") || lower === "ksmps") continue

    seen.add(varName)

    // Use the variable name as channel name (will be rewritten to chnget)
    const channel = `_drc_${varName}`
    const { min, max } = inferRange(varName, varName, lines)
    const label = humanLabel(varName)
    const step = computeStep(min, max)

    params.push({ channel, label, value: rawValue, min, max, step })
  }

  return params
}

/**
 * Rewrite CSD to replace k-rate constant assignments with chnget for slider control.
 * Only rewrites params with _drc_ prefix channels (the ones we extracted from assignments).
 */
function rewriteCsdForChannels(csd: string, params: ExportParam[]): string {
  const assignmentParams = params.filter(p => p.channel.startsWith("_drc_"))
  if (assignmentParams.length === 0) return csd

  const lines = csd.split("\n")

  // Build chn_k declarations to inject after 0dbfs line
  const declarations = assignmentParams.map(p => {
    const varName = p.channel.replace("_drc_", "")
    return `chn_k "${p.channel}", 1  ; DrC slider: ${varName}`
  })

  let injected = false

  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].replace(/;.*$/, "").trim()

    // Inject chn_k declarations after 0dbfs or seed line
    if (!injected && (/^0dbfs\b/.test(trimmed) || /^seed\b/.test(trimmed))) {
      lines[i] = lines[i] + "\n" + declarations.join("\n")
      injected = true
    }

    // Replace kVar = VALUE with kVar chnget "_drc_kVar"
    for (const p of assignmentParams) {
      const varName = p.channel.replace("_drc_", "")
      const re = new RegExp(`^(${escapeRegExp(varName)})\\s*=\\s*[0-9]*\\.?[0-9]+(?:[eE][+-]?[0-9]+)?\\s*$`)
      if (re.test(trimmed)) {
        const indent = lines[i].match(/^\s*/)?.[0] || ""
        const comment = lines[i].includes(";") ? "  " + lines[i].slice(lines[i].indexOf(";")) : ""
        lines[i] = `${indent}${varName} chnget "${p.channel}"${comment}`
      }
    }
  }

  // Fallback: inject at start of CsInstruments if we couldn't find 0dbfs
  if (!injected) {
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].trim() === "<CsInstruments>") {
        lines[i] = lines[i] + "\n" + declarations.join("\n")
        break
      }
    }
  }

  return lines.join("\n")
}

// ─── Signal flow diagram ───

const OPCODE_CATEGORIES: Record<string, string> = {}
for (const opc of ["oscili","oscils","poscil","poscil3","vco2","vco","buzz","gbuzz","noise","rand","randi","randh","pinkish","pluck","wgbow","wgflute","foscili","foscil","diskin2","diskin","tablei","table","chnget"])
  OPCODE_CATEGORIES[opc] = "source"
for (const opc of ["moogladder","moogvcf","lpf18","butterlp","butterhp","butterbp","statevar","svfilter","zdf_2pole","resonz","reson","bqrez","pareq","tone","atone","comb","alpass"])
  OPCODE_CATEGORIES[opc] = "filter"
for (const opc of ["reverbsc","freeverb","nreverb","delay","vdelay","vdelay3","flanger","chorus","distort","distort1","clip","powershape","fold","decimator","compress2","pan2"])
  OPCODE_CATEGORIES[opc] = "effect"
for (const opc of ["out","outs","outch","outq","chnset"])
  OPCODE_CATEGORIES[opc] = "output"
for (const opc of ["madsr","adsr","linseg","linsegr","expseg","expsegr","transeg","linenr","linen","jspline","rspline"])
  OPCODE_CATEGORIES[opc] = "envelope"
for (const opc of ["lfo","metro","dust","dust2","port","portk","limit","scale","phasor"])
  OPCODE_CATEGORIES[opc] = "modulator"

function buildSignalFlow(csd: string): string {
  // Extract instrument body
  const instrMatch = csd.match(/\binstr\b.*?\n([\s\S]*?)\bendin\b/)
  if (!instrMatch) return ""

  const body = instrMatch[1]
  const nodes: Array<{ opcode: string; category: string; label: string }> = []
  const seen = new Set<string>()

  for (const line of body.split("\n")) {
    const clean = line.replace(/;.*$/, "").trim()
    if (!clean) continue

    let opcode: string | null = null

    // kVar/aVar = opcode(...) or kVar/aVar opcode args
    const funcMatch = clean.match(/^[akiSg]\w+\s*=\s*(\w+)\s*[\(:]/)
    const tradMatch = clean.match(/^[akiSg]\w+\s+(\w+)\s+/)
    const outMatch = clean.match(/^(outs?|outch)\s+/)

    if (funcMatch) opcode = funcMatch[1]
    else if (tradMatch) opcode = tradMatch[1]
    else if (outMatch) opcode = outMatch[1]

    if (!opcode) continue
    const lower = opcode.toLowerCase()
    const cat = OPCODE_CATEGORIES[lower]
    if (!cat) continue
    if (seen.has(lower)) continue
    seen.add(lower)

    nodes.push({ opcode, category: cat, label: opcode })
  }

  if (nodes.length === 0) return ""

  // Build HTML — linear flow with arrows
  const nodeHTML = nodes.map(n => {
    const color = `\${FLOW_COLORS['${n.category}'] || FLOW_COLORS.other}`
    // Use inline style since we have the colors at build time
    const catColors: Record<string, string> = {
      source: "#16a34a", filter: "#2563eb", effect: "#9333ea",
      output: "#dc2626", envelope: "#ca8a04", modulator: "#0891b2", other: "#64748b",
    }
    const c = catColors[n.category] || catColors.other
    return `<span class="flow-node" style="border-color: ${c}; color: ${c}">${escapeHTML(n.opcode)}</span>`
  }).join('<span class="flow-arrow">→</span>')

  return `<div class="flow-level">${nodeHTML}</div>`
}

// ─── Helpers ───

function humanLabel(name: string): string {
  return name
    .replace(/^k/, "")
    .replace(/([A-Z])/g, " $1")
    .replace(/[_-]/g, " ")
    .trim()
    .replace(/^\w/, (c) => c.toUpperCase()) || name
}

function computeStep(min: number, max: number): number {
  const range = max - min
  if (range > 1000) return 1
  if (range > 100) return 0.1
  if (range > 10) return 0.01
  return 0.001
}

function inferRange(
  name: string,
  varName: string,
  lines: string[],
): { value: number; min: number; max: number } {
  let value = 0.5
  let min = 0
  let max = 1

  // Look for init/assignment values
  for (const line of lines) {
    const trimmed = line.replace(/;.*$/, "").trim()
    const initMatch = trimmed.match(new RegExp(`\\b${escapeRegExp(varName)}\\s+init\\s+([\\d.eE+-]+)`))
    if (initMatch) value = parseFloat(initMatch[1])
    const assignMatch = trimmed.match(new RegExp(`\\b${escapeRegExp(varName)}\\s*=\\s*([\\d.eE+-]+)\\s*$`))
    if (assignMatch) value = parseFloat(assignMatch[1])
  }

  const lower = name.toLowerCase()
  if (lower.includes("freq") || lower.includes("pitch") || lower.includes("hz")) {
    min = 20; max = 8000; value = value || 440
  } else if (lower.includes("cutoff") || lower.includes("filt")) {
    min = 20; max = 12000; value = value || 2000
  } else if (lower.includes("amp") || lower.includes("vol") || lower.includes("gain") || lower.includes("level")) {
    min = 0; max = 1; value = value || 0.5
  } else if (lower.includes("res") || lower.includes("q")) {
    min = 0; max = 1; value = value || 0.3
  } else if (lower.includes("pan")) {
    min = 0; max = 1; value = value || 0.5
  } else if (lower.includes("rate") || lower.includes("speed")) {
    min = 0.1; max = 20; value = value || 1
  } else if (lower.includes("mix") || lower.includes("wet") || lower.includes("dry") || lower.includes("depth")) {
    min = 0; max = 1; value = value || 0.5
  } else if (lower.includes("attack") || lower.includes("decay") || lower.includes("release")) {
    min = 0.001; max = 5; value = value || 0.1
  } else if (lower.includes("sustain")) {
    min = 0; max = 1; value = value || 0.7
  } else if (lower.includes("detune")) {
    min = -100; max = 100; value = value || 0
  } else if (lower.includes("feedback") || lower.includes("fb")) {
    min = 0; max = 0.99; value = value || 0.3
  } else if (lower.includes("delay") || lower.includes("time")) {
    min = 0; max = 2; value = value || 0.25
  } else if (lower.includes("base")) {
    // kCutoffBase, kFreqBase etc — use value context
    if (value > 100) { min = 20; max = value * 3 }
    else { min = 0; max = value * 3 || 1 }
  } else if (lower.includes("env") && lower.includes("depth")) {
    min = 0; max = value * 2 || 5000
  } else {
    if (value > 1000) { min = 0; max = value * 3 }
    else if (value > 100) { min = 0; max = value * 2 }
    else if (value > 1) { min = 0; max = value * 3 }
    else { min = 0; max = 1 }
  }

  return { value, min, max }
}

function escapeRegExp(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
}

function escapeHTML(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
}
