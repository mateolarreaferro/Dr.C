// Folder of photos, and the stereo image: pan, distance, Doppler, headphone space.
export function installImmersive(api) {
  const $ = id => document.getElementById(id);
  const say = msg => { if (api.status) api.status(msg); };
  const cs = () => (api.getCsound ? api.getCsound() : null);

  const fileInput = $('file');
  if (fileInput && !$('albumBar')) {
    fileInput.insertAdjacentHTML('afterend', `
      <div id="albumBar">
        <div class="concert-bar">
          <button id="folderBtn" class="small" type="button">Load folder…</button>
          <button id="photoPrev" class="small" type="button">↑ Previous</button>
          <button id="photoNext" class="small" type="button">↓ Next</button>
          <button id="photoRand" class="small" type="button">. Random photo</button>
        </div>
        <div class="field"><div class="lab">Photos</div>
          <select id="photoChoice">
            <option value="pick" selected>Pick one</option>
            <option value="order">In order</option>
            <option value="random">Random</option>
          </select></div>
        <div class="field"><div class="lab">Photo every <span class="v" id="photoRateVal">7.0s</span></div>
          <input type="range" id="photoRate" min="0" max="1000" value="400"></div>
        <div class="field"><div class="lab">This photo</div>
          <select id="photoList"><option value="">Load a folder…</option></select></div>
        <div id="photoRead">No folder yet. ↑ and ↓ step photos once a folder is loaded. Number keys still load presets. Concert mode keeps the arrows for cues.</div>
        <div id="albumStrip"></div>
        <input id="folderInput" type="file" webkitdirectory directory multiple hidden>
      </div>`);
  }
  const mix = $('mixBass');
  if (mix && !$('spaceBar')) {
    mix.closest('.field').insertAdjacentHTML('afterend', `
      <div id="spaceBar">
        <div id="mixHint">The scan, the keys, the chords, and the bass sit in one space. Darker pictures step back. Motion shifts the pitch a little.</div>
        <div class="field"><div class="lab">Pan motion</div>
          <select id="panMode">
            <option value="still">Still — the pan row only</option>
            <option value="image" selected>From the picture</option>
            <option value="lfo">LFO sweep</option>
            <option value="random">Random places</option>
          </select></div>
        <div class="field"><div class="lab">Picture aspect</div>
          <select id="panFrom">
            <option value="position" selected>Where the line is</option>
            <option value="centroid">Weight along the line</option>
            <option value="hue">Hue</option>
            <option value="brightness">Brightness</option>
          </select></div>
        <div class="field"><div class="lab">Pan rate <span class="v" id="panRateVal"></span></div>
          <input type="range" id="panRate" min="0" max="1000" value="280"></div>
        <div class="field"><div class="lab">Width <span class="v" id="panDepthVal"></span></div>
          <input type="range" id="panDepth" min="0" max="1000" value="700"></div>
        <div class="field"><div class="lab">Distance</div>
          <select id="distFrom">
            <option value="fixed">Fixed</option>
            <option value="dark" selected>Darker is farther</option>
            <option value="edges">Soft detail is farther</option>
            <option value="motion">Stillness is farther</option>
          </select></div>
        <div class="field"><div class="lab">How far <span class="v" id="distBaseVal"></span></div>
          <input type="range" id="distBase" min="0" max="1000" value="420"></div>
        <div class="field"><div class="lab">Doppler <span class="v" id="dopplerVal"></span></div>
          <input type="range" id="doppler" min="0" max="1000" value="380"></div>
        <div class="field"><div class="lab">Listening</div>
          <select id="spaceMode">
            <option value="speakers" selected>Speakers</option>
            <option value="phones">Headphones</option>
          </select></div>
        <div class="field"><div class="lab">Reverb</div>
          <select id="revMode">
            <option value="hall" selected>In the room</option>
            <option value="head">Around the head</option>
          </select></div>
        <div id="spaceRead">Headphones use a short ear delay and a darker far ear. Around the head adds early reflections at different times in each ear. This browser build has no measured HRTF set.</div>
      </div>`);
  }

  const style = document.createElement('style');
  style.textContent = `
    #albumBar, #spaceBar { margin-top: 10px; }
    #photoRead, #spaceRead { font-size: .8em; opacity: .72; margin: 6px 0; line-height: 1.35; }
    #albumStrip { display: flex; gap: 6px; overflow-x: auto; padding: 4px 0 8px; }
    #albumStrip button { padding: 0; border: 1px solid #2a3142; background: #0c0e12; border-radius: 4px; line-height: 0; }
    #albumStrip button.on { border-color: #00ff88; }
    #albumStrip img { height: 52px; width: auto; display: block; }
  `;
  document.head.appendChild(style);

  let files = [];
  let urls = [];
  let index = 0;
  let clock = 0;
  let phase = 0;
  let randPan = 0.5;
  let randLeft = 0;
  const sent = {};

  function photoEvery() {
    const el = $('photoRate');
    const p = el ? +el.value / 1000 : 0.4;
    return 0.45 + (1 - p) * 11;
  }
  function panHz() {
    const el = $('panRate');
    const p = el ? +el.value / 1000 : 0.28;
    return 0.04 * Math.pow(40, p);
  }
  function paintLabels() {
    if ($('photoRateVal')) $('photoRateVal').textContent = photoEvery().toFixed(1) + 's';
    if ($('panRateVal')) $('panRateVal').textContent = panHz().toFixed(2) + ' Hz';
    if ($('panDepthVal')) $('panDepthVal').textContent = Math.round((+$('panDepth').value || 0) / 10) + '%';
    if ($('distBaseVal')) $('distBaseVal').textContent = ((+$('distBase').value || 0) / 1000).toFixed(2);
    if ($('dopplerVal')) $('dopplerVal').textContent = ((+$('doppler').value || 0) / 1000).toFixed(2);
  }
  function send(key, value) {
    const engine = cs();
    if (!engine) return;
    if (sent[key] !== undefined && Math.abs(sent[key] - value) < 0.0015) return;
    sent[key] = value;
    engine.setControlChannel(key, value).catch(() => {});
  }
  function pushStatic() {
    const mode = { still: 0, image: 1, lfo: 2, random: 3 }[$('panMode') ? $('panMode').value : 'image'] || 0;
    send('panMode', mode);
    send('panDepth', $('panDepth') ? +$('panDepth').value / 1000 : 0.7);
    send('doppler', $('doppler') ? +$('doppler').value / 1000 : 0.38);
    send('spaceMode', $('spaceMode') && $('spaceMode').value === 'phones' ? 1 : 0);
    send('hrtfRev', $('revMode') && $('revMode').value === 'head' ? 1 : 0);
  }
  function featurePan(feats) {
    const src = $('panFrom') ? $('panFrom').value : 'position';
    const f = feats || {};
    if (src === 'centroid') return f.centroid != null ? f.centroid : 0.5;
    if (src === 'hue') return f.hue != null ? f.hue : 0.5;
    if (src === 'brightness') return f.brightness != null ? f.brightness : 0.5;
    return f.position != null ? f.position : 0.5;
  }
  function featureDist(feats) {
    const base = $('distBase') ? +$('distBase').value / 1000 : 0.4;
    const how = $('distFrom') ? $('distFrom').value : 'dark';
    const f = feats || {};
    if (how === 'dark') return Math.min(1, base * 0.35 + (1 - (f.brightness != null ? f.brightness : 0.5)) * 0.75);
    if (how === 'edges') return Math.min(1, base * 0.35 + (1 - (f.edges != null ? f.edges : 0.4)) * 0.7);
    if (how === 'motion') return Math.min(1, base * 0.35 + (1 - (f.change != null ? f.change : 0)) * 0.7);
    return base;
  }
  function paintAlbum() {
    const read = $('photoRead');
    const list = $('photoList');
    const strip = $('albumStrip');
    if (!files.length) {
      if (read) read.textContent = 'No folder yet. ↑ and ↓ step photos once a folder is loaded. Number keys still load presets. Concert mode keeps the arrows for cues.';
      return;
    }
    const name = files[index].webkitRelativePath || files[index].name;
    if (read) read.textContent = (index + 1) + ' / ' + files.length + '  ·  ' + name;
    if (list && list.selectedIndex !== index) list.selectedIndex = index;
    if (strip) {
      [...strip.children].forEach((btn, i) => btn.classList.toggle('on', i === index));
      const on = strip.children[index];
      if (on && on.scrollIntoView) on.scrollIntoView({ block: 'nearest', inline: 'nearest' });
    }
  }
  function showIndex(i) {
    if (!files.length || !api.showFile) return;
    index = (i + files.length) % files.length;
    window.__albumLabel = (index + 1) + '/' + files.length;
    api.showFile(files[index]);
    paintAlbum();
  }
  function loadFolder(list) {
    const images = [...list].filter(f => /^image\//.test(f.type) || /\.(png|jpe?g|webp|gif|bmp)$/i.test(f.name));
    images.sort((a, b) => (a.webkitRelativePath || a.name).localeCompare(b.webkitRelativePath || b.name, undefined, { numeric: true, sensitivity: 'base' }));
    if (!images.length) { say('That folder has no pictures.'); return; }
    urls.forEach(u => URL.revokeObjectURL(u));
    files = images;
    urls = images.map(f => URL.createObjectURL(f));
    index = 0;
    clock = 0;
    const listEl = $('photoList');
    if (listEl) {
      listEl.innerHTML = '';
      images.forEach((f, i) => {
        const opt = document.createElement('option');
        opt.value = String(i);
        opt.textContent = (i + 1) + '.  ' + f.name;
        listEl.appendChild(opt);
      });
    }
    const strip = $('albumStrip');
    if (strip) {
      strip.innerHTML = '';
      urls.forEach((url, i) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.title = images[i].name;
        btn.innerHTML = '<img alt="" src="' + url + '">';
        btn.addEventListener('click', () => { clock = 0; showIndex(i); });
        strip.appendChild(btn);
      });
    }
    showIndex(0);
    say(images.length + ' photos. Pick one, play them in order, or let them arrive at random.');
    if (api.log) api.log('Folder: ' + images.length + ' photos');
  }

  $('folderBtn').addEventListener('click', () => $('folderInput').click());
  $('folderInput').addEventListener('change', e => {
    loadFolder(e.target.files || []);
    e.target.value = '';
  });
  $('photoPrev').addEventListener('click', () => {
    if (!files.length) { say('Load a folder of photos first.'); return; }
    clock = 0;
    showIndex(index - 1);
  });
  $('photoNext').addEventListener('click', () => {
    if (!files.length) { say('Load a folder of photos first.'); return; }
    clock = 0;
    showIndex(index + 1);
  });
  $('photoRand').addEventListener('click', () => {
    if (files.length < 2) { say(files.length ? 'One photo in the folder.' : 'Load a folder of photos first.'); return; }
    clock = 0;
    let n = index;
    while (n === index) n = Math.floor(Math.random() * files.length);
    showIndex(n);
  });
  if ($('photoList')) $('photoList').addEventListener('change', () => {
    if ($('photoList').value === '') return;
    clock = 0;
    showIndex(+$('photoList').value);
  });
  ['photoRate', 'panRate', 'panDepth', 'distBase', 'doppler'].forEach(id => {
    if (!$(id)) return;
    $(id).addEventListener('input', () => { paintLabels(); pushStatic(); });
  });
  ['panMode', 'panFrom', 'distFrom', 'spaceMode', 'revMode', 'photoChoice'].forEach(id => {
    if (!$(id)) return;
    $(id).addEventListener('change', () => {
      pushStatic();
      if (id === 'spaceMode') say($('spaceMode').value === 'phones' ? 'Headphones: the far ear is a little late and a little darker.' : 'Speakers: equal-power pan, with distance and Doppler still on.');
      if (id === 'revMode') say($('revMode').value === 'head' ? 'Reverb gathers around the head, each ear getting a different arrival.' : 'Reverb sits in the room.');
      if (id === 'photoChoice') {
        clock = 0;
        const choice = $('photoChoice').value;
        say(choice === 'order' ? 'Photos advance in filename order.' : choice === 'random' ? 'Photos arrive at random.' : 'The photo stays until you choose another.');
      }
    });
  });

  const stage = $('stage');
  if (stage) stage.addEventListener('drop', e => {
    const list = e.dataTransfer && e.dataTransfer.files;
    if (!list || list.length < 2) return;
    e.preventDefault();
    e.stopPropagation();
    loadFolder(list);
  }, true);

  document.addEventListener('keydown', e => {
    const typing = ['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement && document.activeElement.tagName);
    if (typing || !files.length) return;
    if ($('concertBtn') && $('concertBtn').classList.contains('on')) return;
    if (e.key === 'ArrowUp') { e.preventDefault(); e.stopPropagation(); $('photoPrev').click(); }
    else if (e.key === 'ArrowDown') { e.preventDefault(); e.stopPropagation(); $('photoNext').click(); }
    else if (e.key === '.' && !e.metaKey && !e.ctrlKey) { e.preventDefault(); e.stopPropagation(); $('photoRand').click(); }
  }, true);

  window.updateSpace = (dt, feats) => {
    const choice = $('photoChoice') ? $('photoChoice').value : 'pick';
    const video = $('camVideo');
    const camera = video && video.srcObject && video.style.display !== 'none';
    if (!camera && files.length > 1 && choice !== 'pick') {
      clock += dt || 0;
      if (clock >= photoEvery()) {
        clock = 0;
        if (choice === 'order') showIndex(index + 1);
        else {
          let n = index;
          while (n === index) n = Math.floor(Math.random() * files.length);
          showIndex(n);
        }
      }
    }
    const mode = $('panMode') ? $('panMode').value : 'image';
    const hz = panHz();
    phase += (dt || 0) * hz;
    if (mode === 'random') {
      randLeft -= dt || 0;
      if (randLeft <= 0) {
        randLeft = 1 / Math.max(0.05, hz);
        randPan = Math.random();
      }
    }
    let pan = 0.5;
    if (mode === 'image') pan = featurePan(feats);
    else if (mode === 'lfo') pan = 0.5 + 0.5 * Math.sin(phase * Math.PI * 2);
    else if (mode === 'random') pan = randPan;
    send('scenePan', Math.max(0, Math.min(1, pan)));
    send('sceneDist', featureDist(feats));
    pushStatic();
  };

  paintLabels();
  paintAlbum();
  pushStatic();
}
