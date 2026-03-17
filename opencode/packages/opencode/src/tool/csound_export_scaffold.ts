/**
 * Export a web project scaffold: index.html + style.css + app.js
 * Gives the user a customizable starting point.
 */
import path from "path"
import fs from "fs/promises"

export async function generateWebScaffold(
  csdContent: string,
  title: string,
  outputDir: string,
): Promise<string[]> {
  await fs.mkdir(outputDir, { recursive: true })

  const escapedCsd = csdContent
    .replace(/\\/g, "\\\\")
    .replace(/`/g, "\\`")
    .replace(/\$/g, "\\$")

  const files: string[] = []

  // index.html
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHTML(title)}</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="app">
    <h1>${escapeHTML(title)}</h1>
    <button id="playBtn">Play</button>
    <button id="stopBtn" disabled>Stop</button>
    <div id="status">Ready</div>
    <canvas id="waveform" width="600" height="120"></canvas>
    <div id="controls"></div>
  </div>
  <script type="module" src="app.js"></script>
</body>
</html>`
  await Bun.write(path.join(outputDir, "index.html"), html)
  files.push("index.html")

  // style.css
  const css = `/* DrC Web Export — Customize freely */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  background: #fafafa;
  color: #1a1a1a;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

.app {
  max-width: 600px;
  width: 100%;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

h1 { font-size: 1.5rem; font-weight: 600; }

button {
  padding: 0.5rem 1.5rem;
  border: 2px solid #1a1a1a;
  border-radius: 6px;
  background: transparent;
  color: #1a1a1a;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

button:hover { background: #1a1a1a; color: #fff; }
button:disabled { opacity: 0.3; cursor: not-allowed; }

#status { font-size: 0.85rem; color: #999; }

canvas { width: 100%; height: 120px; border-radius: 8px; }

#controls {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.param { display: flex; flex-direction: column; gap: 0.25rem; }
.param label { font-size: 0.85rem; font-weight: 500; }
.param input[type="range"] { width: 100%; }
`
  await Bun.write(path.join(outputDir, "style.css"), css)
  files.push("style.css")

  // app.js
  const js = `// DrC Web Export — Csound Web Audio Engine
// Customize this file to build your web synth

const CSD = \`${escapedCsd}\`;
const CSOUND_URL = "https://cdn.jsdelivr.net/npm/@csound/browser@7.0.0-beta28/dist/csound.js";

let csound = null;
let audioCtx = null;
let isPlaying = false;

const playBtn = document.getElementById("playBtn");
const stopBtn = document.getElementById("stopBtn");
const statusEl = document.getElementById("status");

async function init() {
  statusEl.textContent = "Loading Csound...";
  const { Csound } = await import(CSOUND_URL);
  audioCtx = new AudioContext();
  csound = await Csound({ audioContext: audioCtx });
  await csound.setOption("-odac");
  await csound.compileCSD(CSD);
  statusEl.textContent = "Ready";
}

playBtn.addEventListener("click", async () => {
  if (!csound) await init();
  if (audioCtx.state === "suspended") await audioCtx.resume();
  await csound.start();
  isPlaying = true;
  playBtn.disabled = true;
  stopBtn.disabled = false;
  statusEl.textContent = "Playing";
});

stopBtn.addEventListener("click", async () => {
  if (!csound) return;
  await csound.stop();
  csound = null;
  isPlaying = false;
  playBtn.disabled = false;
  stopBtn.disabled = true;
  if (audioCtx) { await audioCtx.close(); audioCtx = null; }
  statusEl.textContent = "Stopped";
});

// --- Add your custom controls below ---
// Example: create a slider that controls a Csound channel
//
// function addSlider(channel, label, min, max, value) {
//   const div = document.createElement("div");
//   div.className = "param";
//   div.innerHTML = \`<label>\${label}</label><input type="range" min="\${min}" max="\${max}" value="\${value}" step="0.01">\`;
//   div.querySelector("input").addEventListener("input", (e) => {
//     if (csound && isPlaying) csound.setControlChannel(channel, parseFloat(e.target.value));
//   });
//   document.getElementById("controls").appendChild(div);
// }
//
// addSlider("kCutoff", "Filter Cutoff", 20, 12000, 2000);
`
  await Bun.write(path.join(outputDir, "app.js"), js)
  files.push("app.js")

  return files
}

/**
 * Generate a Tauri project scaffold that wraps the web player as a native app.
 */
export async function generateTauriScaffold(
  csdContent: string,
  title: string,
  outputDir: string,
): Promise<string[]> {
  await fs.mkdir(path.join(outputDir, "src"), { recursive: true })
  await fs.mkdir(path.join(outputDir, "src-tauri", "src"), { recursive: true })

  const files: string[] = []

  // First generate the web scaffold as the frontend
  const webFiles = await generateWebScaffold(csdContent, title, path.join(outputDir, "src"))
  files.push(...webFiles.map((f) => `src/${f}`))

  // package.json
  const pkg = {
    name: title.toLowerCase().replace(/[^a-z0-9]/g, "-"),
    version: "0.1.0",
    description: `${title} — Built with DrC`,
    scripts: {
      dev: "tauri dev",
      build: "tauri build",
    },
  }
  await Bun.write(path.join(outputDir, "package.json"), JSON.stringify(pkg, null, 2))
  files.push("package.json")

  // Cargo.toml for Tauri
  const cargoToml = `[package]
name = "${pkg.name}"
version = "0.1.0"
edition = "2021"

[dependencies]
tauri = { version = "2", features = [] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"

[build-dependencies]
tauri-build = { version = "2", features = [] }
`
  await Bun.write(path.join(outputDir, "src-tauri", "Cargo.toml"), cargoToml)
  files.push("src-tauri/Cargo.toml")

  // tauri.conf.json
  const tauriConf = {
    build: { devUrl: "http://localhost:1420", frontendDist: "../src" },
    app: {
      windows: [{ title, width: 500, height: 600, resizable: true }],
    },
    identifier: `com.drc.${pkg.name}`,
  }
  await Bun.write(
    path.join(outputDir, "src-tauri", "tauri.conf.json"),
    JSON.stringify(tauriConf, null, 2),
  )
  files.push("src-tauri/tauri.conf.json")

  // main.rs
  const mainRs = `fn main() {
    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("error while running application");
}
`
  await Bun.write(path.join(outputDir, "src-tauri", "src", "main.rs"), mainRs)
  files.push("src-tauri/src/main.rs")

  // build.rs
  await Bun.write(
    path.join(outputDir, "src-tauri", "build.rs"),
    `fn main() { tauri_build::build() }\n`,
  )
  files.push("src-tauri/build.rs")

  // README
  const readme = `# ${title}

Built with DrC. This is a Tauri app wrapping a Csound web player.

## Setup

1. Install [Tauri prerequisites](https://tauri.app/start/prerequisites/)
2. Install Rust: \`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh\`
3. Run: \`cargo tauri dev\`
4. Build: \`cargo tauri build\`
`
  await Bun.write(path.join(outputDir, "README.md"), readme)
  files.push("README.md")

  return files
}

function escapeHTML(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
}
