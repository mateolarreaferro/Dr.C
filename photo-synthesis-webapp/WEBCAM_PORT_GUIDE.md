# Webcam Integration Guide

## How to Port Webcam Features to Any Photo-Synthesis Engine

This guide shows how to add the webcam features from `photo_fm_web_v4_webcam.html` to any photo-driven synthesis engine (Granular, Additive, Multi-Engine, etc.).

## What Webcam Features Provide

- **Live camera feed** instead of static photos
- **Zoom** (1x - 4x digital zoom)
- **Pan** (X/Y positioning within zoomed view)
- **Auto-pan** (oscillating scan movement)
- **Mirror/Flip** (horizontal/vertical flipping)
- **Freeze frame** (capture and hold current frame)
- **Resolution selection** (640×480, 1280×720, 1920×1080)
- **FPS selection** (15, 24, 30, 60 fps)
- **Stats display** (actual resolution, fps, freeze status)

## Step-by-Step Integration

### 1. Add HTML Elements

```html
<!-- Source toggle buttons -->
<div class="controls">
  <button id="sourcePhotoBtn" class="active">📷 Photo</button>
  <button id="sourceWebcamBtn">🎥 Webcam</button>
</div>

<!-- Video element (hidden initially) -->
<video id="webcamVideo" autoplay playsinline style="display:none; max-width:100%; max-height:480px;"></video>

<!-- Webcam controls (hidden until webcam mode active) -->
<div id="webcamControls" class="webcam-controls" style="display:none">
  <button id="startWebcamBtn">▶️ Start Webcam</button>
  <button id="stopWebcamBtn" disabled>■ Stop Webcam</button>
  <button id="freezeFrameBtn" disabled>❄️ Freeze Frame</button>
  <button id="unfreezeFrameBtn" disabled style="display:none">▶️ Unfreeze</button>
  
  <div class="field">
    <label>Zoom</label>
    <input type="range" id="webcamZoom" min="100" max="400" value="100">
    <span id="zoomVal">1.0×</span>
  </div>
  
  <div class="field">
    <label>Pan X</label>
    <input type="range" id="webcamPanX" min="-100" max="100" value="0">
  </div>
  
  <div class="field">
    <label>Pan Y</label>
    <input type="range" id="webcamPanY" min="-100" max="100" value="0">
  </div>
  
  <div class="field">
    <label>Auto-Pan</label>
    <button id="autoPanBtn">🔄 Auto-Pan: OFF</button>
  </div>
  
  <div class="field">
    <label>FPS</label>
    <select id="webcamFps">
      <option value="15">15 fps</option>
      <option value="24">24 fps</option>
      <option value="30" selected>30 fps</option>
      <option value="60">60 fps</option>
    </select>
  </div>
  
  <div class="field">
    <label>Resolution</label>
    <select id="webcamResolution">
      <option value="640x480">640×480</option>
      <option value="1280x720" selected>1280×720 (HD)</option>
      <option value="1920x1080">1920×1080 (Full HD)</option>
    </select>
  </div>
  
  <div class="webcam-stats" id="webcamStats" style="display:none">
    <div>Actual: <span id="actualResolution">—</span></div>
    <div>FPS: <span id="actualFps">—</span></div>
    <div>Status: <span id="freezeStatus">—</span></div>
  </div>
</div>
```

### 2. Add CSS Styles

```css
#webcamVideo { 
  display: none; 
  max-width: 100%; 
  max-height: 480px; 
  transition: transform .3s; 
  transform-origin: center center; 
}

#webcamVideo.frozen { 
  border: 3px solid #ff6b6b; 
  box-shadow: 0 0 20px #ff6b6b; 
}

.webcam-controls { 
  display: grid; 
  grid-template-columns: repeat(2, 1fr); 
  gap: 8px; 
  margin-bottom: 12px; 
}

.webcam-stats { 
  font-size: .75em; 
  opacity: .6; 
  padding: 6px 8px; 
  background: #0a0c10; 
  border-radius: 4px; 
  margin-top: 8px; 
}
```

### 3. Add JavaScript State Variables

```javascript
let webcamStream = null;
let webcamActive = false;
let webcamFrozen = false;
let webcamSource = 'photo'; // 'photo' or 'webcam'
let webcamFrameInterval = null;
let webcamZoom = 1.0;
let webcamPanX = 0; // -1 to 1
let webcamPanY = 0; // -1 to 1
let autoPanActive = false;
let autoPanTime = 0;
let frameCount = 0;
let lastFrameTime = Date.now();
let actualFps = 0;
```

### 4. Add Core Webcam Functions

```javascript
// Start webcam with selected resolution and FPS
async function startWebcam() {
  try {
    const res = $('webcamResolution').value;
    const [width, height] = res.split('x').map(Number);
    const fps = +$('webcamFps').value;
    
    webcamStream = await navigator.mediaDevices.getUserMedia({
      video: { 
        width: { ideal: width },
        height: { ideal: height },
        frameRate: { ideal: fps },
        facingMode: 'user'
      }
    });
    
    const video = $('webcamVideo');
    video.srcObject = webcamStream;
    video.style.display = 'block';
    
    webcamActive = true;
    webcamFrozen = false;
    
    $('startWebcamBtn').disabled = true;
    $('stopWebcamBtn').disabled = false;
    $('freezeFrameBtn').disabled = false;
    
    // Wait for video to be ready
    await new Promise(resolve => {
      video.onloadedmetadata = () => {
        video.play();
        resolve();
      };
    });
    
    // Show actual resolution
    $('actualResolution').textContent = `${video.videoWidth}×${video.videoHeight}`;
    $('webcamStats').style.display = 'block';
    $('freezeStatus').textContent = '▶️ Live';
    $('freezeStatus').style.color = '#00ff88';
    
    // Initial frame load
    loadPixelsWithZoom(video);
    
    // Start frame capture loop
    startWebcamCapture(video, fps);
    
    log(`🎥 Webcam started: ${video.videoWidth}×${video.videoHeight} @ ${fps}fps`);
    
  } catch (err) {
    log('❌ Webcam error: ' + err.message);
    status('Webcam access denied or unavailable');
    console.error(err);
  }
}

// Stop webcam and release camera
function stopWebcam() {
  if (webcamStream) {
    webcamStream.getTracks().forEach(track => track.stop());
    webcamStream = null;
  }
  if (webcamFrameInterval) {
    clearInterval(webcamFrameInterval);
    webcamFrameInterval = null;
  }
  
  webcamActive = false;
  webcamFrozen = false;
  
  $('webcamVideo').style.display = 'none';
  $('webcamVideo').srcObject = null;
  $('startWebcamBtn').disabled = false;
  $('stopWebcamBtn').disabled = true;
  $('freezeFrameBtn').disabled = true;
  
  log('🎥 Webcam stopped');
  status('Webcam stopped');
}

// Freeze current frame (keep analyzing, stop updating)
function freezeFrame() {
  webcamFrozen = true;
  $('freezeFrameBtn').style.display = 'none';
  $('unfreezeFrameBtn').style.display = 'inline-block';
  $('unfreezeFrameBtn').disabled = false;
  $('webcamVideo').classList.add('frozen');
  $('freezeStatus').textContent = '❄️ Frozen';
  $('freezeStatus').style.color = '#ff6b6b';
  log('❄️ Frame frozen');
}

// Unfreeze and resume live capture
function unfreezeFrame() {
  webcamFrozen = false;
  $('freezeFrameBtn').style.display = 'inline-block';
  $('unfreezeFrameBtn').style.display = 'none';
  $('webcamVideo').classList.remove('frozen');
  $('freezeStatus').textContent = '▶️ Live';
  $('freezeStatus').style.color = '#00ff88';
  log('▶️ Frame unfrozen');
}

// Capture frames at specified FPS
function startWebcamCapture(video, fps) {
  if (webcamFrameInterval) clearInterval(webcamFrameInterval);
  
  frameCount = 0;
  lastFrameTime = Date.now();
  
  webcamFrameInterval = setInterval(() => {
    if (!webcamActive) return;
    
    // Track actual FPS
    frameCount++;
    const now = Date.now();
    if (now - lastFrameTime >= 1000) {
      actualFps = frameCount;
      frameCount = 0;
      lastFrameTime = now;
      $('actualFps').textContent = `${actualFps} fps`;
    }
    
    // Don't capture new frames when frozen, but keep analyzing the frozen frame
    if (!webcamFrozen) {
      loadPixelsWithZoom(video);
    }
  }, 1000 / fps);
}

// Load pixels with zoom/pan applied
function loadPixelsWithZoom(video) {
  const tempCanvas = document.createElement('canvas');
  const srcW = video.videoWidth;
  const srcH = video.videoHeight;
  
  if (!srcW || !srcH) return;
  
  // Calculate crop area based on zoom
  const cropW = srcW / webcamZoom;
  const cropH = srcH / webcamZoom;
  const cropX = (srcW - cropW) / 2 + (webcamPanX * cropW * 0.4);
  const cropY = (srcH - cropH) / 2 + (webcamPanY * cropH * 0.4);
  
  // Draw cropped region to temp canvas
  tempCanvas.width = srcW;
  tempCanvas.height = srcH;
  const tempCtx = tempCanvas.getContext('2d');
  
  // Draw the zoomed/panned portion
  tempCtx.drawImage(
    video,
    Math.max(0, cropX), Math.max(0, cropY), 
    Math.min(cropW, srcW), Math.min(cropH, srcH),
    0, 0, srcW, srcH
  );
  
  // Apply visual zoom to video element for display
  video.style.transform = `scale(${webcamZoom}) translate(${webcamPanX * 20}%, ${webcamPanY * 20}%)`;
  
  // Now pass the temp canvas through normal loadPixels
  loadPixels(tempCanvas);
}
```

### 5. Add Event Listeners

```javascript
// Source toggle
$('sourcePhotoBtn').addEventListener('click', () => {
  webcamSource = 'photo';
  $('sourcePhotoBtn').classList.add('active');
  $('sourceWebcamBtn').classList.remove('active');
  $('webcamControls').style.display = 'none';
  stopWebcam();
  $('photo').style.display = pixels ? 'block' : 'none';
  $('webcamVideo').style.display = 'none';
  log('📷 Switched to photo mode');
});

$('sourceWebcamBtn').addEventListener('click', () => {
  webcamSource = 'webcam';
  $('sourceWebcamBtn').classList.add('active');
  $('sourcePhotoBtn').classList.remove('active');
  $('webcamControls').style.display = 'grid';
  $('photo').style.display = 'none';
  log('🎥 Switched to webcam mode - click Start Webcam');
});

// Webcam controls
$('startWebcamBtn').addEventListener('click', startWebcam);
$('stopWebcamBtn').addEventListener('click', stopWebcam);
$('freezeFrameBtn').addEventListener('click', freezeFrame);
$('unfreezeFrameBtn').addEventListener('click', unfreezeFrame);

// Zoom control
$('webcamZoom').addEventListener('input', () => {
  webcamZoom = $('webcamZoom').value / 100;
  $('zoomVal').textContent = webcamZoom.toFixed(1) + '×';
});

// Pan controls
$('webcamPanX').addEventListener('input', () => {
  webcamPanX = $('webcamPanX').value / 100;
});

$('webcamPanY').addEventListener('input', () => {
  webcamPanY = $('webcamPanY').value / 100;
});

// Auto-pan toggle
$('autoPanBtn').addEventListener('click', () => {
  autoPanActive = !autoPanActive;
  $('autoPanBtn').textContent = autoPanActive ? '🔄 Auto-Pan: ON' : '🔄 Auto-Pan: OFF';
  $('autoPanBtn').classList.toggle('on', autoPanActive);
  if (autoPanActive) {
    autoPanTime = 0;
    log('🔄 Auto-pan enabled');
  } else {
    log('🔄 Auto-pan disabled');
  }
});
```

### 6. Update Main Loop for Auto-Pan

```javascript
function tick(timestamp) {
  // Auto-pan logic
  if (autoPanActive && webcamActive) {
    autoPanTime += 0.01;
    webcamPanX = Math.sin(autoPanTime) * 0.8;
    webcamPanY = Math.cos(autoPanTime * 0.7) * 0.6;
    
    // Update UI sliders
    $('webcamPanX').value = Math.round(webcamPanX * 100);
    $('webcamPanY').value = Math.round(webcamPanY * 100);
  }
  
  // ... rest of your tick function ...
  
  requestAnimationFrame(tick);
}
```

### 7. Modify loadPixels to Handle Both Photo and Video

```javascript
function loadPixels(source) {
  const canvas = document.createElement('canvas');
  
  // Detect source type: video, image, or canvas
  let sourceWidth, sourceHeight;
  if (source.videoWidth) {
    sourceWidth = source.videoWidth;
    sourceHeight = source.videoHeight;
  } else if (source.naturalWidth) {
    sourceWidth = source.naturalWidth;
    sourceHeight = source.naturalHeight;
  } else {
    sourceWidth = source.width;
    sourceHeight = source.height;
  }
  
  // Downsample for performance
  const maxDim = 480;
  const scale = Math.min(1, maxDim / Math.max(sourceWidth, sourceHeight));
  
  canvas.width = Math.floor(sourceWidth * scale);
  canvas.height = Math.floor(sourceHeight * scale);
  
  const ctx = canvas.getContext('2d');
  ctx.drawImage(source, 0, 0, canvas.width, canvas.height);
  
  const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
  pixels = imgData.data;
  W = canvas.width;
  H = canvas.height;
}
```

### 8. Update Analysis Function to Use Correct Source

```javascript
function tick() {
  // Use video if webcam is active, otherwise use photo
  const source = (webcamActive && webcamSource === 'webcam') ? $('webcamVideo') : $('photo');
  
  // Only analyze if we have a valid source
  if ((webcamActive && webcamSource === 'webcam') || pixels) {
    // ... your analysis code ...
  }
  
  requestAnimationFrame(tick);
}
```

## Engine-Specific Parameter Mapping

### For Granular Synthesis

Map live video features to granular parameters:

```javascript
// Brightness → Grain Density (more light = denser cloud)
kDensity = 1 + (brightness * 199);

// Saturation → Pitch Center (colorful = higher pitch)
kPitchBase = 50 + (saturation * 1950);

// Contrast → Grain Duration (high contrast = shorter grains)
kDuration = 0.005 + ((1 - contrast) * 0.495);

// Position → Stereo Pan
kPan = position;

// Change (motion) → Pitch Spread
kSpread = change * 1.0;
```

### For Additive Synthesis

```javascript
// Brightness → Fundamental Frequency
kFund = 50 + (brightness * 500);

// Saturation → Brightness/Amplitude
kBright = saturation;

// Contrast → Inharmonicity
kInharm = contrast * 0.1;

// Position → Spectral Tilt
kTilt = 1 - position;
```

### For FM Synthesis

```javascript
// Brightness → Carrier Frequency
kCarFreq = 50 + (brightness * 950);

// Saturation → FM Index (timbre complexity)
kModIndex = saturation * 20;

// Contrast → Filter Cutoff
kCutoff = 200 + (contrast * 8800);

// Position → Stereo Pan
kPan = position;
```

## Testing Checklist

- [ ] Photo mode still works (drag/drop, file browse)
- [ ] Webcam starts without errors
- [ ] Video feed displays correctly
- [ ] Zoom works (1x - 4x)
- [ ] Pan X/Y controls work
- [ ] Auto-pan oscillates smoothly
- [ ] Freeze frame captures and holds
- [ ] Unfreeze resumes live feed
- [ ] Resolution selection works
- [ ] FPS selection works
- [ ] Stats display shows correct values
- [ ] Synthesis parameters respond to video
- [ ] Switching Photo ↔ Webcam works cleanly
- [ ] Stop webcam releases camera properly

## Browser Permissions

Users must grant camera access. Handle permission denial gracefully:

```javascript
try {
  webcamStream = await navigator.mediaDevices.getUserMedia({ ... });
} catch (err) {
  if (err.name === 'NotAllowedError') {
    alert('Camera access denied. Please allow camera access in browser settings.');
  } else if (err.name === 'NotFoundError') {
    alert('No camera found. Please connect a camera and try again.');
  } else {
    alert('Error accessing camera: ' + err.message);
  }
}
```

## Performance Notes

- **Webcam capture rate** should match or exceed synthesis control rate for smooth parameter updates
- **Resolution**: 1280×720 recommended (balance between quality and performance)
- **FPS**: 30fps recommended (60fps for fast motion)
- **Downsampling**: Images scaled to max 480px for analysis (performance)
- **Canvas operations**: Minimize canvas drawing outside the capture loop

## Examples in Existing Files

- **Full webcam implementation**: `photo_fm_web_v4_webcam.html` (lines 1055-1600)
- **Basic photo analysis**: `photo_granular_web_FIXED.html`
- **Polyphonic + webcam**: `photo_fm_web_v5_polyphonic.html` (if webcam ported)

---

**This guide enables adding live camera input to any photo-synthesis engine with minimal code duplication.**
