/**
 * Generates a self-contained HTML synth player with parameter knobs,
 * piano keyboard, waveform, and signal flow — all specific to the current CSD.
 */
export function generateCsoundHTML(
  csdContent: string,
  title: string,
  theme: "light" | "dark" = "light",
): string {
  const params = extractParams(csdContent)
  let rewrittenCsd = params.length > 0 ? rewriteCsdForChannels(csdContent, params) : csdContent
  const flow = buildSignalFlow(csdContent)
  const instrName = detectInstrName(csdContent)
  const hasP4Freq = /\bp4\b/.test(csdContent) && /freq|pitch|cpsmidi/i.test(csdContent)

  // For keyboard mode: replace score with infinite duration so keyboard controls playback
  if (hasP4Freq) {
    rewrittenCsd = rewriteCsdForKeyboard(rewrittenCsd)
  }

  const escapedCsd = rewrittenCsd
    .replace(/\\/g, "\\\\")
    .replace(/`/g, "\\`")
    .replace(/\$/g, "\\$")

  const paramsJSON = JSON.stringify(params)
  const isLight = theme === "light"
  const bg = isLight ? "#fafafa" : "#0a0a0a"
  const text = isLight ? "#1a1a1a" : "#f0f0f0"
  const muted = isLight ? "#888" : "#666"
  const accent = isLight ? "#1a1a1a" : "#f0f0f0"
  const codeBg = isLight ? "#f5f5f5" : "#141414"
  const canvasFg = isLight ? "40,40,40" : "200,200,200"
  const border = isLight ? "#e0e0e0" : "#222"
  const panelBg = isLight ? "#fff" : "#111"
  const shadow = isLight ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.03)"
  const keyWhite = isLight ? "#fff" : "#e8e8e8"
  const keyBlack = isLight ? "#1a1a1a" : "#333"
  const keyActive = isLight ? "#d0d0ff" : "#446"
  const knobTrack = isLight ? "#ddd" : "#333"
  const knobFill = isLight ? "#1a1a1a" : "#e0e0e0"

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${escapeHTML(title)}</title>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:${bg};color:${text};min-height:100vh;display:flex;justify-content:center;-webkit-font-smoothing:antialiased}
.container{width:100%;max-width:560px;padding:2rem 1.5rem;display:flex;flex-direction:column;align-items:center;gap:1.25rem}
h1{font-size:1.2rem;font-weight:600;letter-spacing:-0.02em}
.meta{font-size:0.78rem;color:${muted};margin-top:-0.5rem}

/* Transport */
.transport{display:flex;align-items:center;gap:1rem;width:100%}
.play-btn{width:48px;height:48px;border-radius:50%;border:none;background:${accent};cursor:pointer;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 12px ${shadow};transition:transform .15s;flex-shrink:0}
.play-btn:hover{transform:scale(1.06)}
.play-btn:active{transform:scale(.96)}
.play-btn:disabled{opacity:.3;cursor:not-allowed;transform:none}
.icon-play{width:0;height:0;border-style:solid;border-width:8px 0 8px 14px;border-color:transparent transparent transparent ${isLight ? "#fff" : "#0a0a0a"};margin-left:2px}
.icon-pause{display:flex;gap:3px}
.icon-pause span{display:block;width:3px;height:14px;background:${isLight ? "#fff" : "#0a0a0a"};border-radius:1px}
.transport-info{flex:1;min-width:0}
.transport-title{font-size:.85rem;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.transport-status{font-size:.7rem;color:${muted};letter-spacing:.03em;text-transform:uppercase}
.transport-status.error{color:#e54}

/* Waveform */
.waveform{width:100%;height:48px}
.waveform canvas{width:100%;height:100%;display:block;border-radius:6px}

/* Signal flow */
.flow{width:100%;display:flex;flex-wrap:wrap;align-items:center;gap:6px;padding:8px 12px;background:${panelBg};border:1px solid ${border};border-radius:8px}
.flow-node{font-size:.7rem;padding:3px 8px;border-radius:4px;border:1px solid;font-family:'SF Mono',monospace;white-space:nowrap}
.flow-arrow{color:${muted};font-size:.65rem}

/* Knobs */
.knobs{width:100%;display:flex;flex-wrap:wrap;justify-content:center;gap:1.25rem}
.knob-group{display:flex;flex-direction:column;align-items:center;gap:4px;width:72px}
.knob-canvas{width:56px;height:56px;cursor:pointer}
.knob-label{font-size:.68rem;color:${muted};text-align:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;width:100%}
.knob-value{font-size:.7rem;font-family:'SF Mono',monospace;color:${text};text-align:center}

/* Keyboard */
.keyboard-wrap{width:100%;overflow:hidden;border-radius:8px;border:1px solid ${border}}
.keyboard{display:flex;position:relative;height:100px;user-select:none;touch-action:none}
.key-white{flex:1;background:${keyWhite};border-right:1px solid ${border};position:relative;z-index:1;border-radius:0 0 4px 4px;transition:background .08s}
.key-white:last-child{border-right:none}
.key-white.active{background:${keyActive}}
.key-white .note-label{position:absolute;bottom:4px;left:50%;transform:translateX(-50%);font-size:.55rem;color:${muted}}
.key-black{width:8%;background:${keyBlack};position:absolute;height:60%;z-index:2;border-radius:0 0 3px 3px;transition:background .08s}
.key-black.active{background:${isLight ? "#555" : "#666"}}

/* Sections */
details{width:100%;border:1px solid ${border};border-radius:8px;overflow:hidden}
summary{padding:.6rem .8rem;font-size:.78rem;color:${muted};cursor:pointer;list-style:none;display:flex;align-items:center;gap:.4rem;user-select:none}
summary::-webkit-details-marker{display:none}
summary::before{content:"\\203A";font-size:1rem;transition:transform .15s;display:inline-block}
details[open] summary::before{transform:rotate(90deg)}
summary:hover{color:${text}}
.code-block{background:${codeBg};padding:.8rem;font-family:'SF Mono',monospace;font-size:.7rem;line-height:1.5;white-space:pre;tab-size:2;color:${muted};max-height:260px;overflow:auto}
.debug-log{background:${codeBg};padding:.6rem .8rem;font-family:'SF Mono',monospace;font-size:.65rem;line-height:1.5;color:${muted};max-height:150px;overflow:auto;white-space:pre-wrap}
.footer{font-size:.65rem;color:${muted};opacity:.5;transition:opacity .2s}
.footer:hover{opacity:1}
::-webkit-scrollbar{width:3px;height:3px}
::-webkit-scrollbar-thumb{background:${border};border-radius:3px}
</style>
</head>
<body>
<div class="container">
  <h1>${escapeHTML(title)}</h1>
  <p class="meta">Csound instrument</p>

  <!-- Transport -->
  <div class="transport">
    <button class="play-btn" id="playBtn" aria-label="Play">
      <div class="icon-play" id="btnIcon"></div>
    </button>
    <div class="transport-info">
      <div class="transport-title">${escapeHTML(title)}</div>
      <div class="transport-status" id="status">Ready</div>
    </div>
  </div>

  <!-- Waveform -->
  <div class="waveform"><canvas id="waveform"></canvas></div>

  ${flow ? `<!-- Signal Flow -->\n  <div class="flow">${flow}</div>` : ""}

  ${params.length > 0 ? `<!-- Knobs -->\n  <div class="knobs" id="knobs"></div>` : ""}

  ${hasP4Freq ? `<!-- Keyboard -->\n  <div class="keyboard-wrap"><div class="keyboard" id="keyboard"></div></div>` : ""}

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
const PARAMS = ${paramsJSON};
const INSTR = "${instrName}";
const HAS_KEYBOARD = ${hasP4Freq};
const KNOB_TRACK = "${knobTrack}";
const KNOB_FILL = "${knobFill}";
const CANVAS_FG = "${canvasFg}";

let csound = null, audioCtx = null, analyser = null, animFrame = null;
let isPlaying = false, isLoaded = false;
const activeNotes = new Map();

const playBtn = document.getElementById("playBtn");
const btnIcon = document.getElementById("btnIcon");
const statusEl = document.getElementById("status");
const canvas = document.getElementById("waveform");
const ctx = canvas.getContext("2d");
const consoleEl = document.getElementById("console");

// ─── Knobs ───
const knobEls = [];
if (PARAMS.length > 0) {
  const container = document.getElementById("knobs");
  for (const p of PARAMS) {
    const group = document.createElement("div");
    group.className = "knob-group";

    const cv = document.createElement("canvas");
    cv.className = "knob-canvas";
    cv.width = 112; cv.height = 112;

    const label = document.createElement("div");
    label.className = "knob-label";
    label.textContent = p.label;

    const valEl = document.createElement("div");
    valEl.className = "knob-value";
    valEl.textContent = fmtVal(p.value, p.step);

    group.appendChild(cv);
    group.appendChild(valEl);
    group.appendChild(label);
    container.appendChild(group);

    const knob = { canvas: cv, ctx: cv.getContext("2d"), param: p, value: p.value, valEl };
    knobEls.push(knob);
    drawKnob(knob);

    // Drag interaction
    let dragging = false, startY = 0, startVal = 0;
    const onMove = (e) => {
      if (!dragging) return;
      const clientY = e.touches ? e.touches[0].clientY : e.clientY;
      const dy = startY - clientY;
      const range = p.max - p.min;
      const sensitivity = range / 150;
      let newVal = startVal + dy * sensitivity;
      newVal = Math.max(p.min, Math.min(p.max, newVal));
      knob.value = newVal;
      knob.valEl.textContent = fmtVal(newVal, p.step);
      drawKnob(knob);
      if (csound && isPlaying) csound.setControlChannel(p.channel, newVal);
    };
    const onUp = () => { dragging = false; document.removeEventListener("mousemove", onMove); document.removeEventListener("mouseup", onUp); document.removeEventListener("touchmove", onMove); document.removeEventListener("touchend", onUp); };
    const onDown = (e) => {
      dragging = true;
      startY = e.touches ? e.touches[0].clientY : e.clientY;
      startVal = knob.value;
      document.addEventListener("mousemove", onMove);
      document.addEventListener("mouseup", onUp);
      document.addEventListener("touchmove", onMove, { passive: true });
      document.addEventListener("touchend", onUp);
      e.preventDefault();
    };
    cv.addEventListener("mousedown", onDown);
    cv.addEventListener("touchstart", onDown, { passive: false });
  }
}

function drawKnob(k) {
  const c = k.ctx, w = k.canvas.width, h = k.canvas.height;
  const cx = w/2, cy = h/2, r = w/2 - 8;
  const startAngle = 0.75 * Math.PI, endAngle = 2.25 * Math.PI;
  const pct = (k.value - k.param.min) / (k.param.max - k.param.min);
  const valAngle = startAngle + pct * (endAngle - startAngle);

  c.clearRect(0, 0, w, h);
  // Track
  c.beginPath(); c.arc(cx, cy, r, startAngle, endAngle);
  c.lineWidth = 4; c.strokeStyle = KNOB_TRACK; c.lineCap = "round"; c.stroke();
  // Fill
  if (pct > 0.005) {
    c.beginPath(); c.arc(cx, cy, r, startAngle, valAngle);
    c.lineWidth = 4; c.strokeStyle = KNOB_FILL; c.lineCap = "round"; c.stroke();
  }
  // Dot indicator
  const dotX = cx + (r - 2) * Math.cos(valAngle);
  const dotY = cy + (r - 2) * Math.sin(valAngle);
  c.beginPath(); c.arc(dotX, dotY, 4, 0, Math.PI * 2);
  c.fillStyle = KNOB_FILL; c.fill();
}

function fmtVal(v, step) {
  if (step >= 1) return Math.round(v).toString();
  const d = Math.min(3, Math.max(0, Math.ceil(-Math.log10(step))));
  return v.toFixed(d);
}

// ─── Keyboard ───
if (HAS_KEYBOARD) {
  const kb = document.getElementById("keyboard");
  const notes = [
    {note:"C",midi:60,black:false},{note:"C#",midi:61,black:true},
    {note:"D",midi:62,black:false},{note:"D#",midi:63,black:true},
    {note:"E",midi:64,black:false},
    {note:"F",midi:65,black:false},{note:"F#",midi:66,black:true},
    {note:"G",midi:67,black:false},{note:"G#",midi:68,black:true},
    {note:"A",midi:69,black:false},{note:"A#",midi:70,black:true},
    {note:"B",midi:71,black:false},
    {note:"C",midi:72,black:false},{note:"C#",midi:73,black:true},
    {note:"D",midi:74,black:false},{note:"D#",midi:75,black:true},
    {note:"E",midi:76,black:false},
  ];

  const whites = notes.filter(n => !n.black);
  const blacks = notes.filter(n => n.black);

  for (const n of whites) {
    const key = document.createElement("div");
    key.className = "key-white";
    key.dataset.midi = n.midi;
    const lbl = document.createElement("span");
    lbl.className = "note-label";
    lbl.textContent = n.note + (n.midi === 60 ? "4" : n.midi === 72 ? "5" : "");
    key.appendChild(lbl);
    kb.appendChild(key);
  }

  const whiteWidth = 100 / whites.length;
  let whiteIdx = 0;
  for (const n of notes) {
    if (n.black) {
      const key = document.createElement("div");
      key.className = "key-black";
      key.dataset.midi = n.midi;
      key.style.left = (whiteIdx * whiteWidth - whiteWidth * 0.15) + "%";
      key.style.width = (whiteWidth * 0.6) + "%";
      kb.appendChild(key);
    } else {
      whiteIdx++;
    }
  }

  // Use fractional instrument numbers: instr 1.060 for MIDI 60, 1.061 for 61, etc.
  // This lets us turn off specific notes independently.
  // Named instruments get a high base number (100) to avoid conflicts.
  const INSTR_BASE = /^\\d+$/.test(INSTR) ? parseInt(INSTR) : 100;

  function noteOn(midi) {
    if (!csound || !isPlaying || activeNotes.has(midi)) return;
    const freq = 440 * Math.pow(2, (midi - 69) / 12);
    const instrNum = INSTR_BASE + midi / 1000;
    csound.inputMessage("i " + instrNum.toFixed(3) + " 0 -1 " + freq.toFixed(3) + " 0.5");
    activeNotes.set(midi, instrNum);
    const el = kb.querySelector('[data-midi="' + midi + '"]');
    if (el) el.classList.add("active");
  }

  function noteOff(midi) {
    if (!csound || !activeNotes.has(midi)) return;
    const instrNum = activeNotes.get(midi);
    csound.inputMessage("i -" + instrNum.toFixed(3) + " 0 0");
    activeNotes.delete(midi);
    const el = kb.querySelector('[data-midi="' + midi + '"]');
    if (el) el.classList.remove("active");
  }

  let mouseDown = false;
  kb.addEventListener("mousedown", (e) => {
    const midi = e.target.dataset?.midi;
    if (midi) { mouseDown = true; noteOn(+midi); }
  });
  kb.addEventListener("mouseover", (e) => {
    if (mouseDown && e.target.dataset?.midi) noteOn(+e.target.dataset.midi);
  });
  kb.addEventListener("mouseout", (e) => {
    if (e.target.dataset?.midi) noteOff(+e.target.dataset.midi);
  });
  document.addEventListener("mouseup", () => {
    mouseDown = false;
    for (const midi of activeNotes.keys()) noteOff(midi);
  });

  kb.addEventListener("touchstart", (e) => {
    for (const t of e.changedTouches) {
      const el = document.elementFromPoint(t.clientX, t.clientY);
      if (el?.dataset?.midi) noteOn(+el.dataset.midi);
    }
    e.preventDefault();
  }, { passive: false });
  kb.addEventListener("touchend", (e) => {
    for (const midi of activeNotes.keys()) noteOff(midi);
  });

  const keyMap = {a:60,w:61,s:62,e:63,d:64,f:65,t:66,g:67,y:68,h:69,u:70,j:71,k:72};
  const heldKeys = new Set();
  document.addEventListener("keydown", (e) => {
    if (e.repeat || e.target.tagName === "INPUT") return;
    const midi = keyMap[e.key.toLowerCase()];
    if (midi && !heldKeys.has(e.key)) { heldKeys.add(e.key); noteOn(midi); }
  });
  document.addEventListener("keyup", (e) => {
    const midi = keyMap[e.key.toLowerCase()];
    if (midi) { heldKeys.delete(e.key); noteOff(midi); }
  });
}

// ─── Audio engine ───
function setStatus(msg, err) { statusEl.textContent = msg; statusEl.className = "transport-status" + (err ? " error" : ""); }
function log(msg) { consoleEl.textContent += msg + "\\n"; consoleEl.scrollTop = consoleEl.scrollHeight; }
function setPlayIcon() { btnIcon.className = "icon-play"; btnIcon.innerHTML = ""; }
function setPauseIcon() { btnIcon.className = "icon-pause"; btnIcon.innerHTML = "<span></span><span></span>"; }

function resizeCanvas() {
  const r = canvas.parentElement.getBoundingClientRect();
  canvas.width = r.width * (devicePixelRatio || 1);
  canvas.height = r.height * (devicePixelRatio || 1);
}

function drawWaveform() {
  if (!analyser) return;
  animFrame = requestAnimationFrame(drawWaveform);
  const buf = analyser.frequencyBinCount, data = new Uint8Array(buf);
  analyser.getByteFrequencyData(data);
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0,0,w,h);
  const n = Math.min(buf, 48), step = Math.floor(buf/n), bw = w/n, gap = Math.max(1, bw*.3);
  for (let i = 0; i < n; i++) {
    const v = data[i*step]/255, bh = v*h*.85, x = i*bw+gap/2;
    ctx.fillStyle = "rgba("+CANVAS_FG+","+(0.12+v*0.55).toFixed(2)+")";
    ctx.beginPath(); ctx.roundRect(x,(h-bh)/2,bw-gap,bh,2); ctx.fill();
  }
}

function drawIdle() {
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0,0,w,h);
  const n = 48, bw = w/n, gap = Math.max(1, bw*.3);
  for (let i = 0; i < n; i++) {
    ctx.fillStyle = "rgba("+CANVAS_FG+",0.08)";
    ctx.beginPath(); ctx.roundRect(i*bw+gap/2,(h-2)/2,bw-gap,2,1); ctx.fill();
  }
}

async function toggle() {
  if (playBtn.disabled) return;
  try {
    if (!isLoaded) {
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
      log("[DrC] Ready");
    }
    if (audioCtx?.state === "suspended") await audioCtx.resume();
    if (!isPlaying) {
      await csound.start();
      isPlaying = true;
      // Set channel values AFTER start — channels don't exist until engine runs
      for (const k of knobEls) csound.setControlChannel(k.param.channel, k.value);
      setStatus("Playing"); setPauseIcon();
      drawWaveform(); log("[DrC] Playing");
    } else {
      if (animFrame) cancelAnimationFrame(animFrame);
      for (const midi of activeNotes.keys()) activeNotes.delete(midi);
      await csound.stop(); csound = null; isLoaded = false; isPlaying = false;
      if (analyser) { analyser.disconnect(); analyser = null; }
      if (audioCtx) { await audioCtx.close(); audioCtx = null; }
      setStatus("Stopped"); setPlayIcon(); drawIdle(); log("[DrC] Stopped");
    }
  } catch (err) {
    setStatus("Error: " + err.message, true);
    log("[Error] " + err.message);
    playBtn.disabled = false; setPlayIcon();
  }
}

playBtn.addEventListener("click", toggle);
addEventListener("resize", () => { resizeCanvas(); if (!isPlaying) drawIdle(); });
resizeCanvas(); drawIdle();
</script>
</body>
</html>`
}

// ─── CSD analysis helpers ───

interface ExportParam {
  channel: string
  label: string
  value: number
  min: number
  max: number
  step: number
}

function extractParams(csd: string): ExportParam[] {
  const params: ExportParam[] = []
  const seen = new Set<string>()
  const lines = csd.split("\n")

  // 1. chnget channels
  for (const re of [/\b(k\w+)\s+chnget\s+"([^"]+)"/g, /\b(k\w+)\s*=\s*chnget:k\(\s*"([^"]+)"\s*\)/g]) {
    for (const m of csd.matchAll(re)) {
      if (seen.has(m[2])) continue
      seen.add(m[2])
      const r = inferRange(m[2], m[1], lines)
      params.push({ channel: m[2], label: humanLabel(m[2]), ...r, step: computeStep(r.min, r.max) })
    }
  }

  // 2. k-rate constant assignments: kVar = NUMBER
  for (const line of lines) {
    const clean = line.replace(/;.*$/, "").trim()
    const m = clean.match(/^(k\w+)\s*=\s*([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)\s*$/)
    if (!m) continue
    const varName = m[1], rawVal = parseFloat(m[2])
    if (isNaN(rawVal) || seen.has(varName)) continue
    const lower = varName.toLowerCase()
    if (lower.includes("ndx") || lower.includes("count") || lower.includes("flag") || lower === "ksmps") continue
    seen.add(varName)
    const r = inferRange(varName, varName, lines)
    r.value = rawVal
    params.push({ channel: `_drc_${varName}`, label: humanLabel(varName), ...r, step: computeStep(r.min, r.max) })
  }

  return params
}

function rewriteCsdForChannels(csd: string, params: ExportParam[]): string {
  const toRewrite = params.filter(p => p.channel.startsWith("_drc_"))
  if (toRewrite.length === 0) return csd

  const lines = csd.split("\n")
  const decls = toRewrite.map(p => `chn_k "${p.channel}", 1`)
  let injected = false

  for (let i = 0; i < lines.length; i++) {
    const clean = lines[i].replace(/;.*$/, "").trim()
    if (!injected && (/^0dbfs\b/.test(clean) || /^seed\b/.test(clean))) {
      lines[i] += "\n" + decls.join("\n")
      injected = true
    }
    for (const p of toRewrite) {
      const v = p.channel.replace("_drc_", "")
      if (new RegExp(`^${escapeRegExp(v)}\\s*=\\s*[0-9]`).test(clean)) {
        const indent = lines[i].match(/^\s*/)?.[0] || ""
        lines[i] = `${indent}${v} chnget "${p.channel}"`
      }
    }
  }
  if (!injected) {
    const idx = lines.findIndex(l => l.trim() === "<CsInstruments>")
    if (idx >= 0) lines[idx] += "\n" + decls.join("\n")
  }
  return lines.join("\n")
}

function detectInstrName(csd: string): string {
  const m = csd.match(/\binstr\s+(\S+)/)
  if (!m) return "1"
  // Named instruments get renamed to 100 in keyboard mode, numbered ones stay as-is
  return /^[A-Za-z]/.test(m[1]) ? "100" : m[1]
}

/**
 * Rewrite CSD for keyboard mode:
 * - Replace score with "f 0 3600" so Csound stays alive waiting for live input
 * - Rename named instruments to number 100 so fractional instance IDs work for polyphonic note-off
 * - Ensure -odac is in CsOptions
 */
function rewriteCsdForKeyboard(csd: string): string {
  // Replace score section — remove all "i" events, keep "f" tables, add infinite wait
  const scoreMatch = csd.match(/<CsScore>([\s\S]*?)<\/CsScore>/)
  if (scoreMatch) {
    const scoreContent = scoreMatch[1]
    // Keep ftgen/table lines (start with "f"), drop instrument events (start with "i")
    const keptLines = scoreContent.split("\n").filter(line => {
      const t = line.trim()
      return t.startsWith("f ") || t.startsWith(";") || t === ""
    })
    keptLines.push("f 0 3600  ; keep engine alive for keyboard")
    csd = csd.replace(/<CsScore>[\s\S]*?<\/CsScore>/, `<CsScore>\n${keptLines.join("\n")}\n</CsScore>`)
  }

  // Rename named instrument to number 100 for fractional instance control
  const instrMatch = csd.match(/\binstr\s+([A-Za-z]\w*)/)
  if (instrMatch) {
    const name = instrMatch[1]
    // Replace "instr Name" → "instr 100"
    csd = csd.replace(new RegExp(`\\binstr\\s+${escapeRegExp(name)}\\b`), "instr 100")
  }

  // Ensure -odac is present
  if (!/-odac/.test(csd)) {
    csd = csd.replace(/<CsOptions>/, "<CsOptions>\n-odac")
  }

  return csd
}

// Signal flow as inline HTML
const OPCODE_CATS: Record<string, [string, string]> = {}
for (const [ops, cat, col] of [
  [["oscili","poscil","vco2","vco","buzz","gbuzz","noise","rand","randi","pluck","wgbow","wgflute","foscili","diskin2","tablei","chnget"], "source", "#16a34a"],
  [["moogladder","moogvcf","lpf18","butterlp","butterhp","butterbp","statevar","svfilter","zdf_2pole","resonz","reson","bqrez","pareq","tone","atone","comb"], "filter", "#2563eb"],
  [["reverbsc","freeverb","nreverb","delay","vdelay3","flanger","chorus","distort1","clip","powershape","fold","decimator","compress2","pan2"], "effect", "#9333ea"],
  [["out","outs","outch"], "output", "#dc2626"],
  [["madsr","adsr","linseg","linsegr","expseg","expsegr","transeg","linenr","linen","jspline"], "envelope", "#ca8a04"],
  [["lfo","metro","dust","dust2","port","portk","limit","scale","phasor"], "modulator", "#0891b2"],
] as const) {
  for (const op of ops) OPCODE_CATS[op] = [cat as string, col as string]
}

function buildSignalFlow(csd: string): string {
  const instrMatch = csd.match(/\binstr\b.*?\n([\s\S]*?)\bendin\b/)
  if (!instrMatch) return ""
  const nodes: Array<{ opcode: string; color: string }> = []
  const seen = new Set<string>()
  for (const line of instrMatch[1].split("\n")) {
    const clean = line.replace(/;.*$/, "").trim()
    if (!clean) continue
    let opcode: string | null = null
    const f = clean.match(/^[akiSg]\w+\s*=\s*(\w+)\s*[\(:]/) || clean.match(/^[akiSg]\w+\s+(\w+)\s+/) || clean.match(/^(outs?|outch)\s+/)
    if (f) opcode = f[1]
    if (!opcode) continue
    const lower = opcode.toLowerCase()
    const info = OPCODE_CATS[lower]
    if (!info || seen.has(lower)) continue
    seen.add(lower)
    nodes.push({ opcode, color: info[1] })
  }
  if (nodes.length === 0) return ""
  return nodes.map(n =>
    `<span class="flow-node" style="border-color:${n.color};color:${n.color}">${escapeHTML(n.opcode)}</span>`
  ).join('<span class="flow-arrow">\u2192</span>')
}

function humanLabel(name: string): string {
  return name.replace(/^k/, "").replace(/([A-Z])/g, " $1").replace(/[_-]/g, " ").trim().replace(/^\w/, c => c.toUpperCase()) || name
}

function computeStep(min: number, max: number): number {
  const r = max - min
  return r > 1000 ? 1 : r > 100 ? 0.1 : r > 10 ? 0.01 : 0.001
}

function inferRange(name: string, varName: string, lines: string[]): { value: number; min: number; max: number } {
  let value = 0.5, min = 0, max = 1
  for (const line of lines) {
    const t = line.replace(/;.*$/, "").trim()
    const im = t.match(new RegExp(`\\b${escapeRegExp(varName)}\\s+init\\s+([\\d.eE+-]+)`))
    if (im) value = parseFloat(im[1])
    const am = t.match(new RegExp(`\\b${escapeRegExp(varName)}\\s*=\\s*([\\d.eE+-]+)\\s*$`))
    if (am) value = parseFloat(am[1])
  }
  const l = name.toLowerCase()
  if (l.includes("freq") || l.includes("pitch") || l.includes("hz")) { min=20; max=8000; value=value||440 }
  else if (l.includes("cutoff") || l.includes("filt")) { min=20; max=12000; value=value||2000 }
  else if (l.includes("amp") || l.includes("vol") || l.includes("gain") || l.includes("level")) { min=0; max=1; value=value||0.5 }
  else if (l.includes("res") || l.includes("q")) { min=0; max=1; value=value||0.3 }
  else if (l.includes("pan")) { min=0; max=1; value=value||0.5 }
  else if (l.includes("rate") || l.includes("speed")) { min=0.1; max=20; value=value||1 }
  else if (l.includes("mix") || l.includes("wet") || l.includes("dry") || l.includes("depth")) { min=0; max=1; value=value||0.5 }
  else if (l.includes("attack") || l.includes("decay") || l.includes("release")) { min=0.001; max=5; value=value||0.1 }
  else if (l.includes("sustain")) { min=0; max=1; value=value||0.7 }
  else if (l.includes("feedback") || l.includes("fb")) { min=0; max=0.99; value=value||0.3 }
  else if (l.includes("delay") || l.includes("time")) { min=0; max=2; value=value||0.25 }
  else if (l.includes("base")) { min = value > 100 ? 20 : 0; max = value * 3 || 1 }
  else if (l.includes("env") && l.includes("depth")) { min=0; max=value*2||5000 }
  else { if(value>1000){min=0;max=value*3}else if(value>100){min=0;max=value*2}else if(value>1){min=0;max=value*3}else{min=0;max=1} }
  return { value, min, max }
}

function escapeRegExp(s: string): string { return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") }
function escapeHTML(str: string): string { return str.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;") }
