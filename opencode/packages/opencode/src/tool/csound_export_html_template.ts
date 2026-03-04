/**
 * Generates a self-contained HTML file that plays a CSD using @csound/browser@7 from CDN.
 */
export function generateCsoundHTML(csdContent: string, title: string): string {
  // Escape for embedding in JS template literal (backtick string)
  const escapedCsd = csdContent
    .replace(/\\/g, "\\\\")
    .replace(/`/g, "\\`")
    .replace(/\$/g, "\\$")

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${escapeHTML(title)}</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, monospace;
    background: #1a1a2e; color: #e0e0e0;
    display: flex; flex-direction: column; align-items: center;
    padding: 2rem; min-height: 100vh;
  }
  h1 { color: #00d4aa; margin-bottom: 1rem; font-size: 1.4rem; }
  .controls { display: flex; gap: 1rem; margin-bottom: 1.5rem; }
  button {
    padding: 0.7rem 2rem; border: 2px solid #00d4aa; border-radius: 6px;
    background: transparent; color: #00d4aa; font-size: 1rem;
    cursor: pointer; transition: all 0.2s;
  }
  button:hover { background: #00d4aa; color: #1a1a2e; }
  button:disabled { opacity: 0.4; cursor: not-allowed; }
  .status {
    padding: 0.4rem 1rem; border-radius: 4px; font-size: 0.85rem;
    margin-bottom: 1rem;
  }
  .status.ready { background: #2a2a4a; color: #888; }
  .status.loading { background: #2a3a2a; color: #88cc88; }
  .status.playing { background: #1a3a2a; color: #00d4aa; }
  .status.error { background: #3a1a1a; color: #ff6b6b; }
  pre {
    background: #16213e; border: 1px solid #333;
    border-radius: 8px; padding: 1.5rem; width: 100%;
    max-width: 800px; overflow-x: auto; font-size: 0.85rem;
    line-height: 1.5; white-space: pre; tab-size: 2;
  }
  .badge {
    display: inline-block; background: #00d4aa; color: #1a1a2e;
    padding: 0.15rem 0.5rem; border-radius: 3px; font-size: 0.7rem;
    font-weight: bold; margin-bottom: 0.5rem;
  }
  #console {
    background: #0d1117; border: 1px solid #333; border-radius: 6px;
    padding: 0.8rem; width: 100%; max-width: 800px; height: 120px;
    overflow-y: auto; font-size: 0.75rem; color: #7a7a8a;
    margin-top: 1rem; font-family: monospace;
  }
</style>
</head>
<body>
<h1>${escapeHTML(title)}</h1>
<div class="controls">
  <button id="playBtn" onclick="play()">Play</button>
  <button id="stopBtn" onclick="stop()" disabled>Stop</button>
</div>
<div id="status" class="status ready">Ready</div>
<span class="badge">DrC Export</span>
<pre><code>${escapeHTML(csdContent)}</code></pre>
<div id="console"></div>

<script type="module">
const CSD = \`${escapedCsd}\`;
const CSOUND_URL = "https://cdn.jsdelivr.net/npm/@csound/browser@7.0.0-beta28/dist/csound.js";

let csound = null;
let isPlaying = false;

function setStatus(text, cls) {
  const el = document.getElementById("status");
  el.textContent = text;
  el.className = "status " + cls;
}

function log(msg) {
  const el = document.getElementById("console");
  el.textContent += msg + "\\n";
  el.scrollTop = el.scrollHeight;
}

window.play = async function() {
  const playBtn = document.getElementById("playBtn");
  const stopBtn = document.getElementById("stopBtn");

  if (isPlaying) return;

  try {
    if (!csound) {
      setStatus("Loading Csound...", "loading");
      playBtn.disabled = true;
      const { Csound } = await import(CSOUND_URL);
      csound = await Csound();
      await csound.setOption("-odac");
      await csound.on("message", log);
      await csound.compileCSD(CSD);
      log("[DrC] Csound engine initialized");
    }

    await csound.start();
    isPlaying = true;
    setStatus("Playing", "playing");
    playBtn.disabled = true;
    stopBtn.disabled = false;
    log("[DrC] Playback started");
  } catch (err) {
    setStatus("Error: " + err.message, "error");
    log("[Error] " + err.message);
    playBtn.disabled = false;
  }
};

window.stop = async function() {
  if (!csound || !isPlaying) return;
  const playBtn = document.getElementById("playBtn");
  const stopBtn = document.getElementById("stopBtn");

  try {
    await csound.stop();
    csound = null;
    isPlaying = false;
    setStatus("Stopped", "ready");
    playBtn.disabled = false;
    stopBtn.disabled = true;
    log("[DrC] Playback stopped");
  } catch (err) {
    log("[Error] " + err.message);
  }
};
</script>
</body>
</html>`
}

function escapeHTML(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
}
