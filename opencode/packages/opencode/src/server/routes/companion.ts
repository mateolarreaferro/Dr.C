import { Hono } from "hono"
import { upgradeWebSocket } from "hono/bun"
import { lazy } from "../../util/lazy"
import { Log } from "../../util/log"
import { SessionWorkspace } from "../../session/workspace"
import { DesignTree } from "../../csound/design-tree"
import { CompanionSync } from "../companion-sync"
import { SessionPrompt } from "../../session/prompt"
import fs from "fs/promises"
import path from "path"

const log = Log.create({ service: "companion-routes" })

// In-memory param store for companion knob values
const paramStore = new Map<string, Map<string, number>>()

function getSessionParams(sessionID: string): Map<string, number> {
  let params = paramStore.get(sessionID)
  if (!params) {
    params = new Map()
    paramStore.set(sessionID, params)
  }
  return params
}

export const CompanionRoutes = lazy(() =>
  new Hono()
    // Serve companion SPA
    .get("/", async (c) => {
      return c.html(COMPANION_HTML)
    })

    // Get current CSD content for a session
    .get("/csd/:sessionID", async (c) => {
      const sessionID = c.req.param("sessionID")
      const wsStatus = SessionWorkspace.status(sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        return c.json({ content: null, error: "No active workspace" }, 404)
      }

      try {
        const entries = await fs.readdir(wsStatus.tempDir)
        const csdFile = entries.find((e) => e.endsWith(".csd"))
        if (!csdFile) {
          return c.json({ content: null, error: "No CSD file found" }, 404)
        }

        const content = await Bun.file(path.join(wsStatus.tempDir, csdFile)).text()
        return c.json({ content, filename: csdFile })
      } catch (err) {
        log.error("failed to read CSD", { error: String(err) })
        return c.json({ content: null, error: "Failed to read CSD" }, 500)
      }
    })

    // Serve latest WAV file for a session
    .get("/wav/:sessionID", async (c) => {
      const sessionID = c.req.param("sessionID")
      const wsStatus = SessionWorkspace.status(sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        return c.json({ error: "No active workspace" }, 404)
      }

      try {
        const entries = await fs.readdir(wsStatus.tempDir)
        const wavFiles = entries.filter((e) => e.endsWith(".wav"))
        if (wavFiles.length === 0) {
          return c.json({ error: "No WAV file found" }, 404)
        }

        // Find the most recently modified WAV
        let latest = wavFiles[0]
        let latestTime = 0
        for (const wf of wavFiles) {
          const stat = await fs.stat(path.join(wsStatus.tempDir, wf))
          if (stat.mtimeMs > latestTime) {
            latestTime = stat.mtimeMs
            latest = wf
          }
        }

        const wavPath = path.join(wsStatus.tempDir, latest)
        const file = Bun.file(wavPath)
        return new Response(file.stream(), {
          headers: {
            "Content-Type": "audio/wav",
            "Content-Disposition": `inline; filename="${latest}"`,
          },
        })
      } catch (err) {
        log.error("failed to serve WAV", { error: String(err) })
        return c.json({ error: "Failed to serve WAV" }, 500)
      }
    })

    // Get design tree state for a session
    .get("/design-tree/:sessionID", async (c) => {
      const sessionID = c.req.param("sessionID")
      const originalPath = SessionWorkspace.originalPath(sessionID)
      if (!originalPath) {
        return c.json({ tree: null })
      }

      // Try loading tree for the original CSD path
      const tree = await DesignTree.load(originalPath)
      if (!tree) {
        // Also try workspace-resolved path
        const resolved = SessionWorkspace.resolve(sessionID, originalPath)
        const treeAlt = await DesignTree.load(resolved)
        return c.json({ tree: treeAlt })
      }
      return c.json({ tree })
    })

    // Set a parameter value from companion knobs
    .post("/param/:sessionID", async (c) => {
      const sessionID = c.req.param("sessionID")
      const body = await c.req.json<{ channel: string; value: number }>()
      if (!body.channel || typeof body.value !== "number") {
        return c.json({ error: "Invalid body: need { channel, value }" }, 400)
      }

      const params = getSessionParams(sessionID)
      params.set(body.channel, body.value)
      log.info("param set", { sessionID, channel: body.channel, value: body.value })

      // Broadcast to other companions watching this session
      CompanionSync.broadcast(sessionID, {
        type: "param-update",
        channel: body.channel,
        value: body.value,
      })

      return c.json({ ok: true })
    })

    // Send a chat message to the session
    .post("/chat/:sessionID", async (c) => {
      const sessionID = c.req.param("sessionID")
      const body = await c.req.json<{ message: string }>()
      if (!body.message) {
        return c.json({ error: "Invalid body: need { message }" }, 400)
      }

      log.info("companion chat", { sessionID, message: body.message.slice(0, 100) })

      try {
        // Use prompt_async pattern — fire and forget
        SessionPrompt.prompt({
          sessionID,
          parts: [{ type: "text", text: body.message }],
        })
        return c.json({ ok: true })
      } catch (err) {
        log.error("chat failed", { error: String(err) })
        return c.json({ error: "Failed to send message" }, 500)
      }
    })

    // WebSocket endpoint for live sync
    .get(
      "/ws",
      upgradeWebSocket((c) => {
        const sessionID = c.req.query("sessionID")
        if (!sessionID) {
          throw new Error("sessionID query parameter required")
        }

        let wsRef: any

        return {
          onOpen(_event, ws) {
            wsRef = ws
            CompanionSync.register(sessionID, ws as any)
          },
          onMessage(event) {
            // Clients can send pings
            try {
              const data = JSON.parse(String(event.data))
              if (data.type === "ping" && wsRef) {
                wsRef.send(JSON.stringify({ type: "pong" }))
              }
            } catch {
              // ignore malformed messages
            }
          },
          onClose() {
            if (wsRef) CompanionSync.unregister(sessionID, wsRef)
          },
          onError() {
            if (wsRef) CompanionSync.unregister(sessionID, wsRef)
          },
        }
      }),
    ),
)

// ---------------------------------------------------------------------------
// Companion SPA — self-contained HTML
// ---------------------------------------------------------------------------

const COMPANION_HTML = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>DrC Companion</title>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:#0a0a0a;--panel:#131313;--border:#1e1e1e;--text:#e0e0e0;--muted:#666;
  --accent:#00ff88;--accent-dim:rgba(0,255,136,.15);--red:#ff4455;
  --mono:'SF Mono','Fira Code','Cascadia Code',monospace;
  --sans:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
}
html,body{height:100%;font-family:var(--sans);background:var(--bg);color:var(--text);-webkit-font-smoothing:antialiased}

/* Layout */
.app{display:flex;flex-direction:column;height:100vh;overflow:hidden}
header{display:flex;align-items:center;justify-content:space-between;padding:12px 20px;border-bottom:1px solid var(--border);flex-shrink:0}
header h1{font-size:14px;font-weight:600;letter-spacing:-.02em;color:var(--text)}
header h1 span{color:var(--accent);font-weight:700}
.status{display:flex;align-items:center;gap:6px;font-size:11px;color:var(--muted)}
.status-dot{width:7px;height:7px;border-radius:50%;background:var(--red);transition:background .3s}
.status-dot.connected{background:var(--accent)}

.main{display:grid;grid-template-columns:1fr 1.2fr 1fr;gap:1px;flex:1;overflow:hidden;background:var(--border)}
@media(max-width:900px){.main{grid-template-columns:1fr;grid-template-rows:auto 1fr auto}}

.panel{background:var(--panel);display:flex;flex-direction:column;overflow:hidden}
.panel-title{font-size:11px;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);padding:12px 16px 8px;flex-shrink:0}

/* Left — Waveform & Audio */
.waveform-wrap{padding:12px 16px;flex-shrink:0}
.waveform-canvas{width:100%;height:120px;border-radius:6px;background:#0e0e0e;display:block}
.audio-controls{display:flex;align-items:center;gap:10px;padding:8px 16px}
.btn{border:none;border-radius:6px;cursor:pointer;font-size:12px;font-family:var(--sans);padding:6px 16px;transition:all .15s}
.btn-play{background:var(--accent);color:#0a0a0a;font-weight:600}
.btn-play:hover{filter:brightness(1.1)}
.btn-play:disabled{opacity:.3;cursor:not-allowed}
.btn-stop{background:transparent;border:1px solid var(--border);color:var(--muted)}
.btn-stop:hover{border-color:var(--muted)}
.audio-info{font-size:11px;color:var(--muted);padding:4px 16px}

/* Center — CSD Code */
.code-wrap{flex:1;overflow:auto;padding:0}
.code-display{font-family:var(--mono);font-size:12px;line-height:1.6;white-space:pre;padding:12px 0;min-height:100%;counter-reset:line}
.code-line{display:flex;padding:0 16px 0 0}
.code-line:hover{background:rgba(255,255,255,.02)}
.line-no{display:inline-block;width:42px;text-align:right;padding-right:12px;color:var(--muted);user-select:none;flex-shrink:0;font-size:11px}
.line-text{flex:1;white-space:pre}
/* Syntax highlights */
.hl-comment{color:#555}
.hl-section{color:var(--accent);font-weight:600}
.hl-opcode{color:#88bbff}
.hl-keyword{color:#cc88ff}
.hl-number{color:#ffaa44}
.hl-string{color:#88ddaa}

/* Right — Controls & Tree */
.controls-scroll{flex:1;overflow-y:auto;padding:12px 16px}
.param-section{margin-bottom:20px}
.param-section h3{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.04em;margin-bottom:10px}
.param-row{display:flex;align-items:center;gap:10px;margin-bottom:8px}
.param-label{font-size:11px;font-family:var(--mono);color:var(--text);width:100px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.param-slider{flex:1;-webkit-appearance:none;appearance:none;height:4px;border-radius:2px;background:#222;outline:none}
.param-slider::-webkit-slider-thumb{-webkit-appearance:none;width:14px;height:14px;border-radius:50%;background:var(--accent);cursor:pointer;transition:transform .1s}
.param-slider::-webkit-slider-thumb:hover{transform:scale(1.2)}
.param-value{font-size:11px;font-family:var(--mono);color:var(--muted);width:52px;text-align:right}

.tree-section{margin-top:16px}
.tree-section h3{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.04em;margin-bottom:10px}
.tree-node{padding:6px 10px;border-radius:4px;font-size:11px;margin-bottom:2px;border-left:2px solid transparent;cursor:default}
.tree-node.current{border-left-color:var(--accent);background:var(--accent-dim)}
.tree-node .node-desc{color:var(--text)}
.tree-node .node-time{color:var(--muted);font-size:10px;margin-left:8px}
.empty-state{font-size:12px;color:var(--muted);font-style:italic;padding:8px 0}

/* Bottom — Chat */
.chat-bar{border-top:1px solid var(--border);flex-shrink:0;display:flex;flex-direction:column;max-height:200px}
.chat-messages{flex:1;overflow-y:auto;padding:8px 16px;display:flex;flex-direction:column;gap:4px;min-height:40px;max-height:140px}
.chat-msg{font-size:12px;line-height:1.4}
.chat-msg .role{font-weight:600;color:var(--accent);margin-right:6px}
.chat-msg .role.user{color:var(--muted)}
.chat-msg .content{color:var(--text)}
.chat-input-row{display:flex;gap:8px;padding:8px 16px;border-top:1px solid var(--border)}
.chat-input{flex:1;background:#111;border:1px solid var(--border);border-radius:6px;padding:8px 12px;color:var(--text);font-size:12px;font-family:var(--sans);outline:none;resize:none}
.chat-input:focus{border-color:var(--accent)}
.chat-input::placeholder{color:var(--muted)}
.btn-send{background:var(--accent);color:#0a0a0a;font-weight:600;border:none;border-radius:6px;padding:8px 16px;cursor:pointer;font-size:12px}
.btn-send:hover{filter:brightness(1.1)}
.btn-send:disabled{opacity:.3;cursor:not-allowed}

/* Session selector */
.session-bar{display:flex;align-items:center;gap:8px;padding:8px 16px;border-bottom:1px solid var(--border);flex-shrink:0}
.session-bar label{font-size:11px;color:var(--muted)}
.session-select{background:#111;border:1px solid var(--border);border-radius:4px;color:var(--text);font-size:12px;padding:4px 8px;outline:none;max-width:300px}
.session-select:focus{border-color:var(--accent)}
.btn-refresh{background:none;border:1px solid var(--border);border-radius:4px;color:var(--muted);font-size:11px;padding:4px 8px;cursor:pointer}
.btn-refresh:hover{border-color:var(--muted)}
</style>
</head>
<body>
<div class="app">
  <header>
    <h1><span>DrC</span> Companion</h1>
    <div class="status">
      <div class="status-dot" id="statusDot"></div>
      <span id="statusText">Disconnected</span>
    </div>
  </header>

  <div class="session-bar">
    <label>Session:</label>
    <select class="session-select" id="sessionSelect"><option value="">Select a session...</option></select>
    <button class="btn-refresh" id="btnRefresh" title="Refresh sessions">Refresh</button>
  </div>

  <div class="main">
    <!-- Left: Waveform & Audio -->
    <div class="panel">
      <div class="panel-title">Waveform</div>
      <div class="waveform-wrap">
        <canvas class="waveform-canvas" id="waveCanvas"></canvas>
      </div>
      <div class="audio-controls">
        <button class="btn btn-play" id="btnPlay" disabled>Play</button>
        <button class="btn btn-stop" id="btnStop">Stop</button>
      </div>
      <div class="audio-info" id="audioInfo">No audio loaded</div>
    </div>

    <!-- Center: CSD Code -->
    <div class="panel">
      <div class="panel-title">CSD Source</div>
      <div class="code-wrap">
        <div class="code-display" id="codeDisplay">
          <div class="empty-state" style="padding:16px">No CSD loaded. Select a session above.</div>
        </div>
      </div>
    </div>

    <!-- Right: Controls & Tree -->
    <div class="panel">
      <div class="panel-title">Controls</div>
      <div class="controls-scroll">
        <div class="param-section">
          <h3>Parameters</h3>
          <div id="paramList"><div class="empty-state">No parameters detected</div></div>
        </div>
        <div class="tree-section">
          <h3>Design Tree</h3>
          <div id="treeList"><div class="empty-state">No design tree</div></div>
        </div>
      </div>
    </div>
  </div>

  <!-- Bottom: Chat -->
  <div class="chat-bar">
    <div class="chat-messages" id="chatMessages"></div>
    <div class="chat-input-row">
      <input class="chat-input" id="chatInput" placeholder="Send a message to the session..." disabled>
      <button class="btn-send" id="btnSend" disabled>Send</button>
    </div>
  </div>
</div>

<script>
(function(){
  // --- State ---
  const BASE = location.origin;
  let sessionID = null;
  let ws = null;
  let audioCtx = null;
  let audioBuffer = null;
  let sourceNode = null;
  let isPlaying = false;
  let reconnectDelay = 1000;
  let csdContent = '';

  // --- DOM refs ---
  const $ = (id) => document.getElementById(id);
  const sessionSelect = $('sessionSelect');
  const statusDot = $('statusDot');
  const statusText = $('statusText');
  const waveCanvas = $('waveCanvas');
  const btnPlay = $('btnPlay');
  const btnStop = $('btnStop');
  const audioInfo = $('audioInfo');
  const codeDisplay = $('codeDisplay');
  const paramList = $('paramList');
  const treeList = $('treeList');
  const chatMsgs = $('chatMessages');
  const chatInput = $('chatInput');
  const btnSend = $('btnSend');
  const btnRefresh = $('btnRefresh');

  // --- Sessions ---
  async function loadSessions() {
    try {
      const res = await fetch(BASE + '/session');
      const sessions = await res.json();
      sessionSelect.innerHTML = '<option value="">Select a session...</option>';
      for (const s of sessions) {
        const opt = document.createElement('option');
        opt.value = s.id;
        opt.textContent = (s.title || 'Untitled') + ' (' + s.id.slice(0,8) + ')';
        sessionSelect.appendChild(opt);
      }
    } catch(e) {
      console.error('Failed to load sessions:', e);
    }
  }

  sessionSelect.addEventListener('change', () => {
    sessionID = sessionSelect.value || null;
    if (sessionID) connectSession();
    else disconnectWS();
  });

  btnRefresh.addEventListener('click', loadSessions);

  // --- WebSocket ---
  function connectWS() {
    if (!sessionID) return;
    if (ws) { try { ws.close(); } catch{} }

    const wsUrl = (location.protocol === 'https:' ? 'wss:' : 'ws:') +
      '//' + location.host + '/companion/ws?sessionID=' + encodeURIComponent(sessionID);

    ws = new WebSocket(wsUrl);
    ws.onopen = () => {
      statusDot.classList.add('connected');
      statusText.textContent = 'Connected';
      reconnectDelay = 1000;
    };
    ws.onclose = () => {
      statusDot.classList.remove('connected');
      statusText.textContent = 'Disconnected';
      // Exponential backoff reconnect
      if (sessionID) {
        setTimeout(connectWS, reconnectDelay);
        reconnectDelay = Math.min(reconnectDelay * 1.5, 15000);
      }
    };
    ws.onerror = () => {};
    ws.onmessage = (evt) => {
      try {
        const event = JSON.parse(evt.data);
        handleWSEvent(event);
      } catch {}
    };
  }

  function disconnectWS() {
    if (ws) { try { ws.close(); } catch{} ws = null; }
    statusDot.classList.remove('connected');
    statusText.textContent = 'Disconnected';
  }

  function handleWSEvent(event) {
    switch (event.type) {
      case 'csd-update':
        fetchCSD();
        break;
      case 'render-complete':
        fetchWAV();
        break;
      case 'design-tree-update':
        fetchDesignTree();
        break;
      case 'chat-message':
      case 'chat-part-updated':
        fetchMessages();
        break;
      case 'param-update':
        // Update slider if exists
        const slider = document.querySelector('[data-channel="' + event.channel + '"]');
        if (slider) {
          slider.value = event.value;
          const valEl = slider.parentElement.querySelector('.param-value');
          if (valEl) valEl.textContent = formatNum(event.value);
        }
        break;
    }
  }

  // --- Connect to session (fetch all data) ---
  async function connectSession() {
    chatInput.disabled = false;
    btnSend.disabled = false;

    connectWS();
    await Promise.all([fetchCSD(), fetchWAV(), fetchDesignTree(), fetchMessages()]);
  }

  // --- CSD ---
  async function fetchCSD() {
    if (!sessionID) return;
    try {
      const res = await fetch(BASE + '/companion/csd/' + sessionID);
      const data = await res.json();
      if (data.content) {
        csdContent = data.content;
        renderCode(data.content);
        extractAndRenderParams(data.content);
      }
    } catch(e) {
      console.error('CSD fetch failed:', e);
    }
  }

  // --- Code rendering with syntax highlighting ---
  function renderCode(code) {
    const lines = code.split('\\n');
    let html = '';
    for (let i = 0; i < lines.length; i++) {
      html += '<div class="code-line"><span class="line-no">' + (i+1) + '</span><span class="line-text">' + highlightLine(lines[i]) + '</span></div>';
    }
    codeDisplay.innerHTML = html;
  }

  function highlightLine(line) {
    const escaped = escapeHtml(line);
    // Comments
    if (/^\\s*;/.test(line) || /^\\s*\\/\\//.test(line))
      return '<span class="hl-comment">' + escaped + '</span>';
    // Section headers
    if (/^<\\/?Cs\\w+>/i.test(line))
      return '<span class="hl-section">' + escaped + '</span>';
    // Highlight opcodes (common ones)
    let result = escaped;
    const opcodes = ['oscil','oscili','oscils','vco2','moogladder','moogvcf','lpf18','butterlp','butterhp',
      'reverb','reverbsc','freeverb','delay','vdelay','comb','alpass','poscil','poscil3',
      'linen','madsr','adsr','expon','line','linseg','expseg','expsega',
      'phasor','tablei','table','ftgen','chnget','chnset','outch','outs','out',
      'instr','endin','opcode','endop','if','then','else','elseif','endif','while','do','od',
      'ksmps','sr','nchnls','0dbfs','seed','garev','denorm','dispfft',
      'noise','rand','randi','randh','dust','dust2',
      'cpsmidinn','ampdb','dbamp','semitone','cent','octave','cpspch','pchoct',
      'print','prints','printks','sprintf'];
    for (const op of opcodes) {
      const re = new RegExp('\\\\b(' + op + ')\\\\b', 'g');
      result = result.replace(re, '<span class="hl-opcode">$1</span>');
    }
    // Numbers
    result = result.replace(/\\b(\\d+\\.?\\d*)\\b/g, function(m, p1) {
      return '<span class="hl-number">' + p1 + '</span>';
    });
    return result;
  }

  function escapeHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  // --- Parameter extraction ---
  function extractAndRenderParams(code) {
    const params = [];
    const lines = code.split('\\n');
    for (const line of lines) {
      // kVar = VALUE
      let m = line.match(/^\\s*(k[A-Z]\\w*)\\s*=\\s*([\\d.]+)/);
      if (m) {
        params.push({ name: m[1], value: parseFloat(m[2]), channel: '_drc_' + m[1] });
        continue;
      }
      // kVar chnget "channel"
      m = line.match(/^\\s*(k[A-Z]\\w*)\\s+chnget\\s+"([^"]+)"/);
      if (m) {
        params.push({ name: m[1], value: 0.5, channel: m[2] });
      }
    }

    if (params.length === 0) {
      paramList.innerHTML = '<div class="empty-state">No parameters detected</div>';
      return;
    }

    let html = '';
    for (const p of params) {
      const range = inferRange(p.name, p.value);
      html += '<div class="param-row">' +
        '<span class="param-label">' + escapeHtml(p.name) + '</span>' +
        '<input type="range" class="param-slider" data-channel="' + escapeHtml(p.channel) + '"' +
        ' min="' + range[0] + '" max="' + range[1] + '" step="' + range[2] + '"' +
        ' value="' + p.value + '">' +
        '<span class="param-value">' + formatNum(p.value) + '</span>' +
        '</div>';
    }
    paramList.innerHTML = html;

    // Attach slider listeners
    paramList.querySelectorAll('.param-slider').forEach(slider => {
      slider.addEventListener('input', (e) => {
        const val = parseFloat(e.target.value);
        const valEl = e.target.parentElement.querySelector('.param-value');
        if (valEl) valEl.textContent = formatNum(val);
        // POST to server
        fetch(BASE + '/companion/param/' + sessionID, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ channel: e.target.dataset.channel, value: val })
        }).catch(() => {});
      });
    });
  }

  function inferRange(name, value) {
    const n = name.toLowerCase();
    if (n.includes('cutoff') || n.includes('freq') || n.includes('cf')) return [20, 12000, 1];
    if (n.includes('resonance') || n.includes('res') || n.includes('q')) return [0, 1, 0.01];
    if (n.includes('gain') || n.includes('amp') || n.includes('vol')) return [0, 1, 0.01];
    if (n.includes('pan')) return [0, 1, 0.01];
    if (n.includes('rate') || n.includes('speed')) return [0.1, 20, 0.1];
    if (n.includes('depth') || n.includes('mix') || n.includes('wet') || n.includes('dry')) return [0, 1, 0.01];
    if (n.includes('detune') || n.includes('cent')) return [-100, 100, 1];
    if (n.includes('attack') || n.includes('decay') || n.includes('release')) return [0.001, 5, 0.001];
    if (n.includes('sustain')) return [0, 1, 0.01];
    // Default: 0 to 2x current value (or 0-1 if value is 0)
    const max = value > 0 ? value * 2 : 1;
    const step = max > 100 ? 1 : max > 10 ? 0.1 : 0.01;
    return [0, max, step];
  }

  function formatNum(v) {
    if (Math.abs(v) >= 100) return v.toFixed(0);
    if (Math.abs(v) >= 1) return v.toFixed(2);
    return v.toFixed(3);
  }

  // --- WAV / Waveform ---
  async function fetchWAV() {
    if (!sessionID) return;
    try {
      const res = await fetch(BASE + '/companion/wav/' + sessionID);
      if (!res.ok) {
        audioInfo.textContent = 'No audio rendered yet';
        return;
      }
      const arrayBuf = await res.arrayBuffer();
      if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      audioBuffer = await audioCtx.decodeAudioData(arrayBuf);
      btnPlay.disabled = false;
      const dur = audioBuffer.duration.toFixed(2);
      const sr = audioBuffer.sampleRate;
      const ch = audioBuffer.numberOfChannels;
      audioInfo.textContent = dur + 's / ' + sr + ' Hz / ' + ch + 'ch';
      drawWaveform();
    } catch(e) {
      audioInfo.textContent = 'Failed to load audio';
      console.error('WAV fetch failed:', e);
    }
  }

  function drawWaveform() {
    if (!audioBuffer) return;
    const canvas = waveCanvas;
    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    const ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
    const w = rect.width;
    const h = rect.height;

    ctx.clearRect(0, 0, w, h);

    const data = audioBuffer.getChannelData(0);
    const step = Math.ceil(data.length / w);
    const mid = h / 2;

    // Fill
    ctx.fillStyle = 'rgba(0,255,136,0.08)';
    ctx.beginPath();
    ctx.moveTo(0, mid);
    for (let x = 0; x < w; x++) {
      let max = 0;
      const start = x * step;
      for (let j = 0; j < step && start + j < data.length; j++) {
        const v = Math.abs(data[start + j]);
        if (v > max) max = v;
      }
      ctx.lineTo(x, mid - max * mid);
    }
    for (let x = w - 1; x >= 0; x--) {
      let max = 0;
      const start = x * step;
      for (let j = 0; j < step && start + j < data.length; j++) {
        const v = Math.abs(data[start + j]);
        if (v > max) max = v;
      }
      ctx.lineTo(x, mid + max * mid);
    }
    ctx.closePath();
    ctx.fill();

    // Line
    ctx.strokeStyle = '#00ff88';
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (let x = 0; x < w; x++) {
      let sum = 0, count = 0;
      const start = x * step;
      for (let j = 0; j < step && start + j < data.length; j++) {
        sum += data[start + j];
        count++;
      }
      const avg = count ? sum / count : 0;
      const y = mid - avg * mid;
      x === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
    }
    ctx.stroke();

    // Center line
    ctx.strokeStyle = 'rgba(255,255,255,0.05)';
    ctx.beginPath();
    ctx.moveTo(0, mid);
    ctx.lineTo(w, mid);
    ctx.stroke();
  }

  // --- Audio playback ---
  btnPlay.addEventListener('click', () => {
    if (!audioBuffer || !audioCtx) return;
    if (isPlaying) return;
    if (audioCtx.state === 'suspended') audioCtx.resume();
    sourceNode = audioCtx.createBufferSource();
    sourceNode.buffer = audioBuffer;
    sourceNode.connect(audioCtx.destination);
    sourceNode.onended = () => { isPlaying = false; btnPlay.textContent = 'Play'; };
    sourceNode.start(0);
    isPlaying = true;
    btnPlay.textContent = 'Playing...';
  });

  btnStop.addEventListener('click', () => {
    if (sourceNode && isPlaying) {
      try { sourceNode.stop(); } catch {}
      isPlaying = false;
      btnPlay.textContent = 'Play';
    }
  });

  // --- Design Tree ---
  async function fetchDesignTree() {
    if (!sessionID) return;
    try {
      const res = await fetch(BASE + '/companion/design-tree/' + sessionID);
      const data = await res.json();
      if (!data.tree || !data.tree.nodes) {
        treeList.innerHTML = '<div class="empty-state">No design tree</div>';
        return;
      }
      renderTree(data.tree);
    } catch(e) {
      console.error('Design tree fetch failed:', e);
    }
  }

  function renderTree(tree) {
    const nodes = Object.values(tree.nodes).sort((a, b) => a.timestamp - b.timestamp);
    if (nodes.length === 0) {
      treeList.innerHTML = '<div class="empty-state">No design tree</div>';
      return;
    }
    let html = '';
    for (const node of nodes) {
      if (node.pruned) continue;
      const isCurrent = node.id === tree.currentNodeID;
      const time = new Date(node.timestamp).toLocaleTimeString();
      html += '<div class="tree-node' + (isCurrent ? ' current' : '') + '">' +
        '<span class="node-desc">' + escapeHtml(node.description || 'Untitled') + '</span>' +
        '<span class="node-time">' + time + '</span>' +
        '</div>';
    }
    treeList.innerHTML = html;
  }

  // --- Chat ---
  async function fetchMessages() {
    if (!sessionID) return;
    try {
      const res = await fetch(BASE + '/session/' + sessionID + '/message?limit=20');
      const msgs = await res.json();
      renderMessages(msgs);
    } catch(e) {
      console.error('Messages fetch failed:', e);
    }
  }

  function renderMessages(msgs) {
    let html = '';
    for (const msg of msgs) {
      const role = msg.info.role;
      let text = '';
      for (const part of (msg.parts || [])) {
        if (part.type === 'text') text += part.content || part.text || '';
      }
      if (!text) continue;
      // Truncate long messages
      const display = text.length > 200 ? text.slice(0, 200) + '...' : text;
      html += '<div class="chat-msg"><span class="role ' + role + '">' + role + '</span>' +
        '<span class="content">' + escapeHtml(display) + '</span></div>';
    }
    chatMsgs.innerHTML = html;
    chatMsgs.scrollTop = chatMsgs.scrollHeight;
  }

  async function sendChat() {
    const msg = chatInput.value.trim();
    if (!msg || !sessionID) return;
    chatInput.value = '';
    btnSend.disabled = true;

    try {
      await fetch(BASE + '/companion/chat/' + sessionID, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: msg })
      });
      // Add to local display immediately
      const el = document.createElement('div');
      el.className = 'chat-msg';
      el.innerHTML = '<span class="role user">user</span><span class="content">' + escapeHtml(msg) + '</span>';
      chatMsgs.appendChild(el);
      chatMsgs.scrollTop = chatMsgs.scrollHeight;
    } catch(e) {
      console.error('Send failed:', e);
    }
    btnSend.disabled = false;
  }

  chatInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendChat(); }
  });
  btnSend.addEventListener('click', sendChat);

  // --- Canvas resize ---
  window.addEventListener('resize', () => { if (audioBuffer) drawWaveform(); });

  // --- Init ---
  const urlSessionID = new URLSearchParams(location.search).get('sessionID');
  loadSessions().then(() => {
    if (urlSessionID) {
      sessionSelect.value = urlSessionID;
      sessionID = urlSessionID;
      connectSession();
    }
  });
})();
</script>
</body>
</html>`
