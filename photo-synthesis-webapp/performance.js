// Concert setlist, stage projection, and named ASCII / MIDI maps.
export function installPerformance(api) {
  const $ = id => document.getElementById(id);
  const storeKey = api.prefix + 'Show';
  let show = loadShow();
  let draft = show.draftMap || { ascii: {}, midi: {} };
  let cueIndex = 0;
  let learnAscii = null;
  let learnMidi = null;
  let ccHigh = {};

  injectStyle();
  injectMaxVoices();
  injectPanels();
  renderAll();
  restoreCurrent();
  wire();
  window.performanceKit = { offerMidi, applyMaxAlloc, onPanelRestored: applyMaxAlloc };

  function loadShow() {
    try {
      const raw = JSON.parse(localStorage.getItem(storeKey) || '{}');
      return {
        maps: raw.maps || { order: [], data: {}, current: '' },
        concerts: raw.concerts || { order: [], data: {}, current: '' },
        draftMap: raw.draftMap || { ascii: {}, midi: {} },
      };
    } catch (err) {
      return { maps: { order: [], data: {}, current: '' }, concerts: { order: [], data: {}, current: '' }, draftMap: { ascii: {}, midi: {} } };
    }
  }
  function persist() {
    show.draftMap = draft;
    localStorage.setItem(storeKey, JSON.stringify(show));
  }
  function say(msg) { if (api.status) api.status(msg); if (api.log) api.log(msg); }

  function targets() {
    const rows = [];
    const add = (id, label, kind) => { if ($(id) || kind === 'control') rows.push({ id, label, kind }); };
    [
      ['startBtn', 'Start audio'], ['droneBtn', 'Drone'], ['stopBtn', 'Stop'], ['scanBtn', 'Scan'],
      ['camBtn', 'Camera'], ['loadBtn', 'Load photo'], ['randBtn', 'Random'], ['resetBtn', 'Reset'],
      ['bounceBtn', 'Bounce'], ['concertPrev', 'Previous cue'], ['concertNext', 'Next cue'],
      ['projectBtn', 'Project'], ['concertBtn', 'Concert mode'],
      ['photoPrev', 'Previous photo'], ['photoNext', 'Next photo'], ['photoRand', 'Random photo'],
    ].forEach(([id, label]) => add(id, label, 'button'));
    [
      ['speed', 'Scan speed'], ['gain', 'Master gain'], ['mixScan', 'Scan level'], ['mixKeys', 'Keys level'],
      ['mixChord', 'Chord level'], ['mixBass', 'Bass level'], ['maxVoices', 'Max voices'],
      ['glow', 'Chord glow'], ['harmRate', 'Chord rate'], ['randRate', 'Jump rate'],
      ['lineRate2', 'Line 2 rate'], ['lineRate3', 'Line 3 rate'], ['lineRate4', 'Line 4 rate'],
      ['rStart', 'Range start'], ['rEnd', 'Range end'], ['thick', 'Line width'],
      ['photoRate', 'Photo rate'], ['panRate', 'Pan rate'], ['panDepth', 'Pan width'],
      ['distBase', 'Distance'], ['doppler', 'Doppler'],
    ].forEach(([id, label]) => add(id, label, 'slider'));
    [
      ['lines', 'Scan lines'], ['mode', 'Motion'], ['axis', 'Direction'], ['scale', 'Pitch scale'],
      ['root', 'Root'], ['keyMode', 'Keys'], ['harmSrc', 'Harmony'], ['bassSrc', 'Bass'],
      ['harmMode', 'Mode'], ['harmVoice', 'Voicing'],
      ['photoChoice', 'Photo choice'], ['panMode', 'Pan motion'], ['panFrom', 'Pan aspect'],
      ['distFrom', 'Distance from'], ['spaceMode', 'Listening'], ['revMode', 'Reverb place'],
    ].forEach(([id, label]) => add(id, label, 'select'));
    (api.controls ? api.controls() : []).forEach(c => rows.push({ id: 'ctl:' + c.key, label: c.label || c.key, kind: 'control', key: c.key }));
    return rows;
  }

  function injectStyle() {
    const style = document.createElement('style');
    style.textContent = `
      body.concert-on #photo, body.concert-on #camVideo { max-height: 78vh; }
      #stage:fullscreen, #stage:-webkit-full-screen { width: 100vw; height: 100vh; min-height: 100vh; border: 0; border-radius: 0; background: #000; }
      #stage:fullscreen #photo, #stage:fullscreen #camVideo, #stage:-webkit-full-screen #photo, #stage:-webkit-full-screen #camVideo { max-width: 100vw; max-height: 100vh; }
      #concertHud { position: absolute; left: 18px; bottom: 16px; z-index: 4; color: #fff; text-shadow: 0 2px 16px #000; pointer-events: none; display: none; }
      body.concert-on #concertHud, #stage:fullscreen #concertHud, #stage:-webkit-full-screen #concertHud { display: block; }
      #concertHud .name { font-size: 2.4em; font-weight: 650; letter-spacing: .01em; }
      #concertHud .cue { font-size: 1.25em; margin-top: 4px; opacity: .92; }
      #mapTableWrap { max-height: 320px; overflow: auto; margin-top: 8px; }
      #mapTable td, #mapTable th { padding: 4px 8px; text-align: left; font-size: .85em; }
      #mapTable button.armed { border-color: #ff6b6b; color: #ff6b6b; }
      .concert-bar, .map-bar { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; margin-top: 8px; }
      .concert-bar input[type=text], .map-bar input[type=text] { background: #1e2430; color: #e8e8e8; border: 1px solid #2f3747; border-radius: 4px; padding: 6px 8px; min-width: 180px; }
      #cueList { min-width: 220px; background: #1e2430; color: #e8e8e8; border: 1px solid #2f3747; border-radius: 4px; }
    `;
    document.head.appendChild(style);
  }

  function injectMaxVoices() {
    if (!$('maxVoices')) {
      const anchor = $('gain') || $('mixBass');
      if (!anchor) return;
      const field = document.createElement('div');
      field.className = 'field';
      field.innerHTML = '<div class="lab">Max voices <span class="v" id="maxVoicesVal">6</span></div><input type="range" id="maxVoices" min="1" max="32" value="6">';
      anchor.closest('.field').insertAdjacentElement('afterend', field);
    }
    const el = $('maxVoices');
    if (el && !el.dataset.bound) {
      el.dataset.bound = '1';
      el.addEventListener('input', () => {
        if ($('maxVoicesVal')) $('maxVoicesVal').textContent = el.value;
        applyMaxAlloc();
      });
    }
    if ($('maxVoicesVal') && el) $('maxVoicesVal').textContent = el.value;
  }

  function injectPanels() {
    const stage = $('stage');
    if (stage && !$('concertHud')) {
      stage.insertAdjacentHTML('beforeend', '<div id="concertHud"><div class="name" id="hudName"></div><div class="cue" id="hudCue"></div></div>');
    }
    const preset = $('presetList') && $('presetList').closest('.panel');
    if (!preset || $('concertPanel')) return;
    preset.insertAdjacentHTML('afterend', `
      <div class="panel" id="concertPanel">
        <h2><span>Concert</span><span class="kbd-hint">arrows step the cues while Concert is on</span></h2>
        <div class="concert-bar">
          <button id="concertBtn" class="small" type="button">Concert: OFF</button>
          <button id="projectBtn" class="small" type="button">Project</button>
          <input id="compName" type="text" placeholder="Composition name" value="Untitled">
          <button id="compSave" class="small" type="button">Save</button>
          <button id="compRename" class="small" type="button">Rename</button>
          <button id="compDelete" class="small" type="button">Delete</button>
          <select id="compList"><option value="">Load a composition…</option></select>
        </div>
        <div class="concert-bar">
          <select id="cueList" size="6"></select>
          <div style="display:flex;flex-direction:column;gap:6px">
            <button id="cueAdd" class="small" type="button">Add preset</button>
            <button id="cueRemove" class="small" type="button">Remove</button>
            <button id="cueUp" class="small" type="button">Move up</button>
            <button id="cueDown" class="small" type="button">Move down</button>
            <button id="concertPrev" class="small" type="button">Previous</button>
            <button id="concertNext" class="small" type="button">Next</button>
          </div>
          <div id="concertRead" style="opacity:.8;font-size:.9em;max-width:280px">Save presets, add them here, name the piece, then turn Concert on. The picture fills the stage.</div>
        </div>
      </div>
      <div class="panel" id="mapPanel">
        <h2><span>ASCII and MIDI maps</span><span class="kbd-hint">click a cell, then press a key or move a control</span></h2>
        <div class="map-bar">
          <input id="mapName" type="text" placeholder="Mapping name" value="Live map">
          <button id="mapSave" class="small" type="button">Save</button>
          <button id="mapRename" class="small" type="button">Rename</button>
          <button id="mapDelete" class="small" type="button">Delete</button>
          <select id="mapList"><option value="">Load a map…</option></select>
          <button id="mapExport" class="small" type="button">Export</button>
          <button id="mapImport" class="small" type="button">Import</button>
          <input id="mapFile" type="file" accept=".json" hidden>
        </div>
        <div id="mapTableWrap"><table id="mapTable"><thead><tr><th>Control</th><th>ASCII</th><th>MIDI</th><th></th></tr></thead><tbody></tbody></table></div>
      </div>`);
  }

  function currentComp() {
    const name = ($('compName') && $('compName').value.trim()) || 'Untitled';
    const live = cueValues();
    const saved = show.concerts.data[name];
    const cues = live.length ? live : (saved ? saved.cues : []);
    return { name, cues };
  }
  function cueValues() {
    return [...($('cueList') ? $('cueList').options : [])].map(o => o.value).filter(Boolean);
  }
  function restoreCurrent() {
    const name = show.concerts.current;
    const comp = name && show.concerts.data[name];
    if (!comp) return;
    $('compName').value = comp.name;
    if ($('compList')) $('compList').value = name;
    const sel = $('cueList');
    sel.innerHTML = '';
    comp.cues.forEach((cue, i) => {
      const opt = document.createElement('option');
      opt.value = cue;
      opt.textContent = (i + 1) + '.  ' + cue.replace(/^(user|factory):/, '');
      sel.appendChild(opt);
    });
    if (sel.options.length) sel.selectedIndex = 0;
    paintHud();
  }
  function renderAll() {
    renderCompList();
    renderCues();
    renderMapList();
    renderMapTable();
    paintHud();
  }
  function renderCompList() {
    const sel = $('compList');
    if (!sel) return;
    const cur = sel.value;
    sel.innerHTML = '<option value="">Load a composition…</option>';
    show.concerts.order.forEach(name => {
      if (show.concerts.data[name]) sel.insertAdjacentHTML('beforeend', `<option value="${esc(name)}">${esc(name)}</option>`);
    });
    if (cur) sel.value = cur;
  }
  function renderCues() {
    const sel = $('cueList');
    if (!sel) return;
    const name = $('compName').value.trim();
    const comp = show.concerts.data[name];
    const cues = comp ? comp.cues : cueValues();
    const keep = sel.selectedIndex;
    sel.innerHTML = '';
    cues.forEach((cue, i) => {
      const opt = document.createElement('option');
      opt.value = cue;
      opt.textContent = (i + 1) + '.  ' + cue.replace(/^(user|factory):/, '');
      if (i === cueIndex) opt.selected = true;
      sel.appendChild(opt);
    });
    if (keep >= 0 && keep < sel.options.length && cueIndex !== keep) sel.selectedIndex = keep;
  }
  function renderMapList() {
    const sel = $('mapList');
    if (!sel) return;
    const cur = show.maps.current || '';
    sel.innerHTML = '<option value="">Load a map…</option>';
    show.maps.order.forEach(name => {
      if (show.maps.data[name]) sel.insertAdjacentHTML('beforeend', `<option value="${esc(name)}">${esc(name)}</option>`);
    });
    if (cur) sel.value = cur;
    if ($('mapName') && cur) $('mapName').value = cur;
  }
  function renderMapTable() {
    const body = document.querySelector('#mapTable tbody');
    if (!body) return;
    body.innerHTML = '';
    targets().forEach(row => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${esc(row.label)}</td>
        <td><button type="button" class="small ascii" data-id="${esc(row.id)}">${esc(asciiLabel(row.id))}</button></td>
        <td><button type="button" class="small midi" data-id="${esc(row.id)}">${esc(midiLabel(row.id))}</button></td>
        <td><button type="button" class="small clear" data-id="${esc(row.id)}">Clear</button></td>`;
      body.appendChild(tr);
    });
  }
  function asciiLabel(id) {
    if (learnAscii === id) return 'press a key…';
    return draft.ascii[id] || '—';
  }
  function midiLabel(id) {
    if (learnMidi === id) return 'move a control…';
    const m = draft.midi[id];
    if (!m) return '—';
    return m.type === 'cc' ? 'CC ' + m.num : 'note ' + m.num;
  }
  function esc(s) {
    return String(s).replace(/[&<>"']/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[ch]));
  }

  function wire() {
    $('concertBtn').addEventListener('click', () => setConcert(!$('concertBtn').classList.contains('on')));
    $('projectBtn').addEventListener('click', project);
    $('concertPrev').addEventListener('click', () => stepCue(-1));
    $('concertNext').addEventListener('click', () => stepCue(1));
    $('cueAdd').addEventListener('click', addCue);
    $('cueRemove').addEventListener('click', () => editCues(cues => { const i = $('cueList').selectedIndex; if (i >= 0) cues.splice(i, 1); }));
    $('cueUp').addEventListener('click', () => moveCue(-1));
    $('cueDown').addEventListener('click', () => moveCue(1));
    $('compSave').addEventListener('click', saveComp);
    $('compRename').addEventListener('click', renameComp);
    $('compDelete').addEventListener('click', deleteComp);
    $('compList').addEventListener('change', () => { if ($('compList').value) loadComp($('compList').value); });
    $('mapSave').addEventListener('click', saveMap);
    $('mapRename').addEventListener('click', renameMap);
    $('mapDelete').addEventListener('click', deleteMap);
    $('mapList').addEventListener('change', () => { if ($('mapList').value) loadMap($('mapList').value); });
    $('mapExport').addEventListener('click', exportMap);
    $('mapImport').addEventListener('click', () => $('mapFile').click());
    $('mapFile').addEventListener('change', importMap);
    document.querySelector('#mapTable tbody').addEventListener('click', onMapClick);
    document.addEventListener('keydown', onKey, true);
    document.addEventListener('fullscreenchange', paintHud);
    const copyBtn = $('copyConsoleBtn');
    if (copyBtn) copyBtn.addEventListener('click', copyConsole);
    const start = $('startBtn');
    if (start) start.addEventListener('click', () => {
      const wait = setInterval(() => {
        if (api.getCsound()) { clearInterval(wait); applyMaxAlloc(); }
      }, 250);
      setTimeout(() => clearInterval(wait), 8000);
    });
  }

  function onMapClick(e) {
    const btn = e.target.closest('button');
    if (!btn) return;
    const id = btn.dataset.id;
    if (btn.classList.contains('clear')) {
      delete draft.ascii[id];
      delete draft.midi[id];
      learnAscii = learnMidi = null;
      persist();
      renderMapTable();
      return;
    }
    if (btn.classList.contains('ascii')) {
      learnAscii = id;
      learnMidi = null;
      renderMapTable();
      say('Press the ASCII key for ' + id.replace(/^ctl:/, '') + '. Backspace clears it.');
    } else if (btn.classList.contains('midi')) {
      learnMidi = id;
      learnAscii = null;
      renderMapTable();
      say('Play a MIDI note or move a knob for ' + id.replace(/^ctl:/, '') + '.');
    }
  }

  function onKey(e) {
    const typing = ['INPUT', 'TEXTAREA'].includes(document.activeElement && document.activeElement.tagName);
    if (learnAscii) {
      if (typing) return;
      e.preventDefault();
      e.stopPropagation();
      if (e.key === 'Escape') { learnAscii = null; renderMapTable(); return; }
      if (e.key === 'Backspace') delete draft.ascii[learnAscii];
      else {
        Object.keys(draft.ascii).forEach(k => { if (draft.ascii[k] === e.key) delete draft.ascii[k]; });
        draft.ascii[learnAscii] = e.key;
      }
      learnAscii = null;
      persist();
      renderMapTable();
      say('ASCII map updated.');
      return;
    }
    if (typing || e.repeat) return;
    if ($('concertBtn') && $('concertBtn').classList.contains('on') && ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(e.key)) {
      e.preventDefault();
      e.stopPropagation();
      stepCue(e.key === 'ArrowRight' || e.key === 'ArrowDown' ? 1 : -1);
      return;
    }
    const id = Object.keys(draft.ascii).find(k => draft.ascii[k] === e.key);
    if (!id) return;
    e.preventDefault();
    e.stopPropagation();
    nudge(id, e.shiftKey ? -1 : 1);
  }

  function offerMidi(e) {
    if (api.learning && api.learning()) return false;
    const [status, data1, data2] = e.data;
    const cmd = status >> 4;
    const isNote = cmd === 9 && data2 > 0;
    const isOff = cmd === 8 || (cmd === 9 && data2 === 0);
    const isCC = cmd === 11;
    if (learnMidi && (isNote || isCC)) {
      const type = isCC ? 'cc' : 'note';
      const num = data1;
      Object.keys(draft.midi).forEach(k => {
        const m = draft.midi[k];
        if (m && m.type === type && m.num === num) delete draft.midi[k];
      });
      draft.midi[learnMidi] = { type, num };
      learnMidi = null;
      persist();
      renderMapTable();
      say((type === 'cc' ? 'CC ' : 'Note ') + num + ' learned.');
      return true;
    }
    if (isOff) return false;
    if (!isNote && !isCC) return false;
    const id = Object.keys(draft.midi).find(k => {
      const m = draft.midi[k];
      return m && ((isNote && m.type === 'note' && m.num === data1) || (isCC && m.type === 'cc' && m.num === data1));
    });
    if (!id) return false;
    const norm = (isNote ? data2 : data2) / 127;
    const row = targets().find(t => t.id === id);
    if (row && row.kind === 'button') {
      if (isNote) { $(id) && $(id).click(); return true; }
      const high = data2 >= 64;
      if (high && !ccHigh[id]) $(id) && $(id).click();
      ccHigh[id] = high;
      return true;
    }
    applyValue(id, norm);
    return true;
  }

  function applyValue(id, norm) {
    if (id.startsWith('ctl:')) {
      api.applyControl(id.slice(4), norm);
      return;
    }
    const el = $(id);
    if (!el) return;
    if (el.type === 'range') {
      el.value = String(Math.round(+el.min + (+el.max - +el.min) * norm));
      el.dispatchEvent(new Event('input', { bubbles: true }));
      if (id === 'maxVoices' && $('maxVoicesVal')) $('maxVoicesVal').textContent = el.value;
    } else if (el.tagName === 'SELECT') {
      el.selectedIndex = Math.round(norm * Math.max(0, el.options.length - 1));
      el.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }
  function nudge(id, dir) {
    if (id.startsWith('ctl:')) {
      api.applyControl(id.slice(4), dir > 0 ? 0.8 : 0.2);
      return;
    }
    const el = $(id);
    if (!el) return;
    if (el.tagName === 'BUTTON') { el.click(); return; }
    if (el.type === 'range') {
      const step = (id === 'maxVoices' || id === 'thick') ? 1 : Math.max(1, Math.round((+el.max - +el.min) / 20));
      el.value = String(Math.min(+el.max, Math.max(+el.min, +el.value + dir * step)));
      el.dispatchEvent(new Event('input', { bubbles: true }));
      if (id === 'maxVoices' && $('maxVoicesVal')) $('maxVoicesVal').textContent = el.value;
      return;
    }
    if (el.tagName === 'SELECT' && el.options.length) {
      const n = el.options.length;
      el.selectedIndex = (el.selectedIndex + (dir > 0 ? 1 : n - 1)) % n;
      el.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }

  function setConcert(on) {
    $('concertBtn').classList.toggle('on', on);
    $('concertBtn').textContent = on ? 'Concert: ON' : 'Concert: OFF';
    document.body.classList.toggle('concert-on', on);
    paintHud();
    if (on) {
      project();
      if (currentComp() && currentComp().cues.length) stepCue(0);
      else say('Concert is on. Add presets to the piece, or project the picture.');
    } else if (document.fullscreenElement) {
      document.exitFullscreen().catch(() => {});
    }
  }
  function project() {
    const stage = $('stage');
    if (!stage) return;
    if (document.fullscreenElement === stage) {
      document.exitFullscreen().catch(() => {});
      return;
    }
    const ask = stage.requestFullscreen || stage.webkitRequestFullscreen;
    if (ask) ask.call(stage).catch(() => say('The browser did not open the full stage. The picture is still enlarged.'));
  }
  function paintHud() {
    const comp = ($('compName') && $('compName').value.trim()) || 'Untitled';
    const cues = currentComp() ? currentComp().cues : [];
    const cue = cues[cueIndex] ? cues[cueIndex].replace(/^(user|factory):/, '') : 'No cue yet';
    if ($('hudName')) $('hudName').textContent = comp;
    if ($('hudCue')) $('hudCue').textContent = cues.length ? (cueIndex + 1) + ' / ' + cues.length + '   ' + cue : cue;
  }
  function stepCue(dir) {
    rememberCues();
    const comp = currentComp();
    if (!comp || !comp.cues.length) { say('Add a preset to this composition first.'); return; }
    if (dir === 0) cueIndex = Math.min(cueIndex, comp.cues.length - 1);
    else cueIndex = (cueIndex + dir + comp.cues.length) % comp.cues.length;
    const sel = $('cueList');
    if (sel) sel.selectedIndex = cueIndex;
    api.loadPreset(comp.cues[cueIndex]);
    paintHud();
    say(comp.name + '   ' + (cueIndex + 1) + ' / ' + comp.cues.length);
  }
  function rememberCues() {
    const name = $('compName').value.trim() || 'Untitled';
    $('compName').value = name;
    if (!show.concerts.data[name]) return;
    show.concerts.data[name].cues = cueValues().length ? cueValues() : show.concerts.data[name].cues;
    persist();
  }
  function editCues(fn) {
    const cues = cueValues();
    fn(cues);
    const name = $('compName').value.trim() || 'Untitled';
    if (!show.concerts.data[name]) show.concerts.data[name] = { name, cues };
    else show.concerts.data[name].cues = cues;
    renderCues();
    paintHud();
    persist();
  }
  function addCue() {
    const preset = $('presetList') && $('presetList').value;
    if (!preset) { say('Choose a preset in the list above, then add it.'); return; }
    editCues(cues => cues.push(preset));
    cueIndex = cueValues().length - 1;
    if ($('cueList')) $('cueList').selectedIndex = cueIndex;
    say('Added to the concert.');
  }
  function moveCue(dir) {
    const i = $('cueList').selectedIndex;
    editCues(cues => {
      const j = i + dir;
      if (i < 0 || j < 0 || j >= cues.length) return;
      [cues[i], cues[j]] = [cues[j], cues[i]];
      cueIndex = j;
    });
    if ($('cueList')) $('cueList').selectedIndex = cueIndex;
  }
  function saveComp() {
    const name = $('compName').value.trim();
    if (!name) { say('Name the composition first.'); return; }
    show.concerts.data[name] = { name, cues: cueValues() };
    if (!show.concerts.order.includes(name)) show.concerts.order.push(name);
    show.concerts.current = name;
    persist();
    renderCompList();
    $('compList').value = name;
    paintHud();
    say('Saved composition ' + name + '.');
  }
  function renameComp() {
    const prev = show.concerts.current || '';
    const name = prompt('Composition name:', $('compName').value.trim() || prev);
    if (!name || !name.trim() || name.trim() === prev) return;
    const next = name.trim();
    if (show.concerts.data[next]) { say('A composition with that name already exists.'); return; }
    const cues = (show.concerts.data[prev] && show.concerts.data[prev].cues) || cueValues();
    if (prev && show.concerts.data[prev]) {
      delete show.concerts.data[prev];
      const idx = show.concerts.order.indexOf(prev);
      if (idx >= 0) show.concerts.order[idx] = next;
    }
    show.concerts.data[next] = { name: next, cues };
    if (!show.concerts.order.includes(next)) show.concerts.order.push(next);
    show.concerts.current = next;
    $('compName').value = next;
    persist();
    renderCompList();
    $('compList').value = next;
    paintHud();
    say('Renamed to ' + next + '.');
  }
  function deleteComp() {
    const name = $('compName').value.trim();
    if (!name || !show.concerts.data[name]) { say('Load a saved composition to delete.'); return; }
    if (!confirm('Delete composition "' + name + '"?')) return;
    delete show.concerts.data[name];
    show.concerts.order = show.concerts.order.filter(n => n !== name);
    show.concerts.current = '';
    $('compName').value = '';
    $('cueList').innerHTML = '';
    persist();
    renderCompList();
    paintHud();
    say('Deleted ' + name + '.');
  }
  function loadComp(name) {
    const comp = show.concerts.data[name];
    if (!comp) return;
    show.concerts.current = name;
    $('compName').value = comp.name;
    cueIndex = 0;
    $('cueList').innerHTML = '';
    comp.cues.forEach((cue, i) => {
      const opt = document.createElement('option');
      opt.value = cue;
      opt.textContent = (i + 1) + '.  ' + cue.replace(/^(user|factory):/, '');
      $('cueList').appendChild(opt);
    });
    if ($('cueList').options.length) $('cueList').selectedIndex = 0;
    persist();
    paintHud();
    if (comp.cues[0]) api.loadPreset(comp.cues[0]);
    say('Loaded ' + comp.name + '.');
  }

  function saveMap() {
    const name = $('mapName').value.trim();
    if (!name) { say('Name the mapping first.'); return; }
    show.maps.data[name] = JSON.parse(JSON.stringify(draft));
    if (!show.maps.order.includes(name)) show.maps.order.push(name);
    show.maps.current = name;
    persist();
    renderMapList();
    say('Saved map ' + name + '.');
  }
  function renameMap() {
    const prev = show.maps.current;
    if (!prev) { say('Load a saved map to rename.'); return; }
    const name = prompt('Mapping name:', prev);
    if (!name || !name.trim() || name.trim() === prev) return;
    const next = name.trim();
    if (show.maps.data[next]) { say('A map with that name already exists.'); return; }
    show.maps.data[next] = show.maps.data[prev];
    delete show.maps.data[prev];
    const idx = show.maps.order.indexOf(prev);
    if (idx >= 0) show.maps.order[idx] = next;
    show.maps.current = next;
    $('mapName').value = next;
    persist();
    renderMapList();
    say('Renamed map to ' + next + '.');
  }
  function deleteMap() {
    const name = show.maps.current || $('mapName').value.trim();
    if (!name || !show.maps.data[name]) { say('Load a saved map to delete.'); return; }
    if (!confirm('Delete map "' + name + '"?')) return;
    delete show.maps.data[name];
    show.maps.order = show.maps.order.filter(n => n !== name);
    show.maps.current = '';
    persist();
    renderMapList();
    say('Deleted map ' + name + '.');
  }
  function loadMap(name) {
    const map = show.maps.data[name];
    if (!map) return;
    draft = { ascii: { ...(map.ascii || {}) }, midi: { ...(map.midi || {}) } };
    show.maps.current = name;
    $('mapName').value = name;
    persist();
    renderMapTable();
    say('Loaded map ' + name + '.');
  }
  function exportMap() {
    const blob = new Blob([JSON.stringify({ name: $('mapName').value.trim() || 'map', ...draft }, null, 2)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = ( $('mapName').value.trim() || 'map' ).replace(/\s+/g, '_') + '.json';
    a.click();
  }
  function importMap(e) {
    const file = e.target.files && e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const data = JSON.parse(reader.result);
        draft = { ascii: data.ascii || {}, midi: data.midi || {} };
        if (data.name) $('mapName').value = data.name;
        persist();
        renderMapTable();
        say('Imported map.');
      } catch (err) { say('Import failed.'); }
    };
    reader.readAsText(file);
    e.target.value = '';
  }

  function copyConsole() {
    const text = $('console') ? $('console').innerText.trim() : '';
    const body = text || '(console is empty)';
    const done = () => say('Console copied. Paste it into the chat.');
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(body).then(done).catch(() => fallbackCopy(body, done));
    } else fallbackCopy(body, done);
  }
  function fallbackCopy(body, done) {
    const area = document.createElement('textarea');
    area.value = body;
    document.body.appendChild(area);
    area.select();
    document.execCommand('copy');
    area.remove();
    done();
  }

  async function applyMaxAlloc() {
    const cs = api.getCsound && api.getCsound();
    const el = $('maxVoices');
    const n = Math.max(1, Math.min(48, el ? Math.round(+el.value) : 4));
    if ($('maxVoicesVal')) $('maxVoicesVal').textContent = String(n);
    if (!cs) return;
    try {
      await cs.setControlChannel('maxVoices', n);
      await cs.inputMessage('i 999 0 0.02');
    } catch (err) { /* the orchestra already holds the voice limit */ }
  }
}
