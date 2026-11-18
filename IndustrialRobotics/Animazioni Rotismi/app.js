// Controller UI, stato ed eventi
const $ = id => document.getElementById(id);

const state = {
  tab: 0,
  T: 0,
  run: !matchMedia("(prefers-reduced-motion: reduce)").matches,
  spd: 1,
  dir: 1,
  hov: -1,
  drag: false,
  lastX: 0,
  showAnn: true,
  planarMode: "idler",     // "single" | "idler" | "internal"
  epiMode: "planetary",    // "planetary" | "star" | "solar" | "diff"
  diffRatio: 0.3,
  hdMode: "cs",            // "cs" | "fs"
  cin: 2.0,
  eta: 0.96,
  jl: 4.0,
  Z: structuredClone(DEFAULTS)
};

const cv = $("cv");
const renderer = createRenderer(cv);
let currentModel = null;

function setHover(i) {
  state.hov = i;
  document.querySelectorAll(".role-item").forEach(el => {
    el.classList.toggle("on", +el.dataset.i === i);
  });
}

function updateDynamics(model) {
  const box = $("dynMetrics");
  if (model.tabId === "rack") {
    const rpMeters = model.extra.rp * 1e-3;
    const fc = (state.eta * state.cin) / rpMeters;
    const vc = model.extra.rp; // mm/s per 1 rad/s
    box.innerHTML = `
      <div class="metric-box"><small>Forza lineare F<sub>c</sub> (ω<sub>p</sub> reg.)</small><b>${fc.toFixed(1)} N</b></div>
      <div class="metric-box"><small>Velocità v<sub>c</sub> / ω<sub>p</sub></small><b>${vc.toFixed(1)} mm/rad</b></div>
      <div class="metric-box"><small>Raggio primitivo r<sub>p</sub></small><b>${model.extra.rp.toFixed(1)} mm</b></div>
      <div class="metric-box"><small>Passo primitivo p</small><b>${model.extra.pitch.toFixed(2)} mm</b></div>
    `;
    return;
  }

  const absTau = Math.abs(model.tau || 0);
  if (absTau < 1e-5) {
    box.innerHTML = `
      <div class="metric-box"><small>Rapporto di riduzione i</small><b>∞</b></div>
      <div class="metric-box"><small>Coppia C<sub>out</sub></small><b>–</b></div>
    `;
    return;
  }

  const iRed = 1 / absTau;
  const cout = (state.eta * state.cin) / absTau;
  const jlRef = ((absTau * absTau) / state.eta) * state.jl;
  const atten = absTau * absTau;

  box.innerHTML = `
    <div class="metric-box"><small>Rapporto riduzione i = 1/|τ|</small><b>${iRed.toFixed(2)} : 1</b></div>
    <div class="metric-box"><small>Coppia uscita C<sub>out</sub></small><b>${cout.toFixed(2)} N·m</b></div>
    <div class="metric-box"><small>Inerzia riflessa J<sub>L</sub>′</small><b>${jlRef.toFixed(4)} kg·m²</b></div>
    <div class="metric-box"><small>Fattore inerzia τ²</small><b>${atten.toExponential(2)}</b></div>
  `;
}

function updateUI() {
  currentModel = computeModel(state);
  const m = currentModel;

  // HUD principale
  if (m.tau !== null) {
    $("hudTau").innerHTML = `
      <small>${m.label}</small>
      <b>${fmt(m.tau, m.tabId === "harmonic" ? 4 : 3)}</b>
      <span class="hud-sub">i = ${m.reduction ? m.reduction.toFixed(2) + ":1" : "∞"}</span>
    `;
  } else {
    $("hudTau").innerHTML = `
      <small>${m.label}</small>
      <b>${m.tauDisplay}</b>
      <span class="hud-sub">v<sub>c</sub> = ω<sub>p</sub> · r<sub>p</sub></span>
    `;
  }

  $("hudBadge").hidden = !m.badge;
  $("hudBadge").textContent = m.badge || "";
  $("refLabel").innerHTML = `Rif: ${m.ref}`;

  // Griglia ruoli e velocità
  $("rolesGrid").innerHTML = m.roles.map((r, i) => {
    let rightTxt = r.customVal || "";
    if (!rightTxt) {
      const arrow = Math.abs(r.w) < 0.004 ? "fermo" : (r.w * state.dir > 0 ? "↻" : "↺");
      rightTxt = `${fmt(r.w, m.tabId === "harmonic" ? 4 : 3)} ${arrow}`;
    }
    return `
      <div class="role-item" data-i="${i}">
        <i class="role-dot" style="background: var(--${r.c})"></i>
        <div class="role-meta">
          <b>${r.name}</b>
          <span>z = ${r.z} · ${r.role}</span>
        </div>
        <em class="role-val">${rightTxt}</em>
      </div>
    `;
  }).join("");

  $("rolesGrid").querySelectorAll(".role-item").forEach(card => {
    card.onmouseenter = () => setHover(+card.dataset.i);
    card.onmouseleave = () => setHover(-1);
  });

  // Teoria e formule
  const notesHtml = m.notes && m.notes.length
    ? `<ul class="note-list">${m.notes.map(n => `<li>${n}</li>`).join("")}</ul>`
    : "";
  $("theoryPanel").innerHTML = `
    <p>${m.theory}</p>
    <div class="formula-box">${m.formula}</div>
    ${notesHtml}
  `;

  updateDynamics(m);
  setHover(state.hov);
}

function updateSubCfgUI() {
  document.querySelectorAll("#planarModes .cfg-btn").forEach(b => {
    b.classList.toggle("on", b.dataset.p === state.planarMode);
  });
  document.querySelectorAll("#epiModes .cfg-btn").forEach(b => {
    b.classList.toggle("on", b.dataset.l === state.epiMode);
  });
  $("diffSliderRow").hidden = state.epiMode !== "diff";
  $("diffOut").textContent = fmt(state.diffRatio, 2);

  document.querySelectorAll("#hdModes .cfg-btn").forEach(b => {
    b.classList.toggle("on", b.dataset.h === state.hdMode);
  });
}

function buildSliders() {
  const tabId = TABS[state.tab].id;
  const specs = SLIDER_SPECS[tabId];
  const vals = state.Z[tabId];

  $("slidersBox").innerHTML = specs.map((sp, i) => {
    // Nascondi z_c se nel rotismo piano siamo in modalità single o internal
    if (tabId === "planar" && i === 2 && state.planarMode !== "idler") return "";
    return `
      <label class="slider-row">
        <span class="sl-label">${sp.sym}</span>
        <input type="range" data-i="${i}" min="${sp.min}" max="${sp.max}" step="${sp.step}" value="${vals[i]}">
        <output>${vals[i]}</output>
      </label>
    `;
  }).join("");

  $("slidersBox").querySelectorAll("input").forEach(inp => {
    inp.oninput = () => {
      const idx = +inp.dataset.i;
      vals[idx] = +inp.value;
      inp.nextElementSibling.textContent = inp.value;
      updateUI();
    };
  });

  $("planarModes").hidden = tabId !== "planar";
  $("epiModes").hidden = tabId !== "planetary";
  $("hdModes").hidden = tabId !== "harmonic";
  updateSubCfgUI();
}

function setTab(i) {
  state.tab = i;
  state.hov = -1;
  document.querySelectorAll("#tabs button").forEach((b, j) => {
    b.classList.toggle("on", i === j);
    b.setAttribute("aria-selected", i === j);
  });
  buildSliders();
  updateUI();
}

// Inizializzazione Tabs
TABS.forEach((t, i) => {
  const b = document.createElement("button");
  b.textContent = t.name;
  b.setAttribute("role", "tab");
  b.onclick = () => setTab(i);
  $("tabs").appendChild(b);
});

$("tabs").onkeydown = e => {
  const d = e.key === "ArrowRight" ? 1 : e.key === "ArrowLeft" ? -1 : 0;
  if (d) {
    const nxt = (state.tab + d + TABS.length) % TABS.length;
    setTab(nxt);
    $("tabs").children[nxt].focus();
  }
};

// Controlli trasporto
function syncPlayBtn() {
  $("playBtn").textContent = state.run ? "❚❚ Pausa" : "▶ Riprendi";
}
$("playBtn").onclick = () => { state.run = !state.run; syncPlayBtn(); };
$("revBtn").onclick = () => { state.dir = -state.dir; updateUI(); };
$("annBtn").onclick = () => {
  state.showAnn = !state.showAnn;
  $("annBtn").classList.toggle("on", state.showAnn);
  $("stageLegend").hidden = !state.showAnn;
};
$("resetBtn").onclick = () => {
  const tabId = TABS[state.tab].id;
  state.Z[tabId] = DEFAULTS[tabId].slice();
  state.planarMode = "idler";
  state.epiMode = "planetary";
  state.hdMode = "cs";
  state.diffRatio = 0.3;
  state.T = 0;
  $("diffRange").value = 0.3;
  buildSliders();
  updateUI();
};

$("speedRange").oninput = e => {
  state.spd = +e.target.value;
  $("speedOut").textContent = `${state.spd.toFixed(1)}×`;
};

// Sub-configurazioni
document.querySelectorAll("#planarModes .cfg-btn").forEach(b => {
  b.onclick = () => { state.planarMode = b.dataset.p; buildSliders(); updateUI(); };
});
document.querySelectorAll("#epiModes .cfg-btn").forEach(b => {
  b.onclick = () => { state.epiMode = b.dataset.l; updateSubCfgUI(); updateUI(); };
});
document.querySelectorAll("#hdModes .cfg-btn").forEach(b => {
  b.onclick = () => { state.hdMode = b.dataset.h; updateSubCfgUI(); updateUI(); };
});
$("diffRange").oninput = e => {
  state.diffRatio = +e.target.value;
  updateSubCfgUI();
  updateUI();
};

// Controlli Dinamici (Coppia, Rendimento, Inerzia)
$("cinRange").oninput = e => { state.cin = +e.target.value; $("cinOut").textContent = state.cin.toFixed(1); updateDynamics(currentModel); };
$("etaRange").oninput = e => { state.eta = +e.target.value; $("etaOut").textContent = state.eta.toFixed(2); updateDynamics(currentModel); };
$("jlRange").oninput  = e => { state.jl  = +e.target.value; $("jlOut").textContent  = state.jl.toFixed(1);  updateDynamics(currentModel); };

// Tema chiaro/scuro
$("themeBtn").onclick = () => {
  const root = document.documentElement;
  const isDark = root.dataset.theme
    ? root.dataset.theme === "dark"
    : matchMedia("(prefers-color-scheme: dark)").matches;
  root.dataset.theme = isDark ? "light" : "dark";
};

// Tastiera globale
addEventListener("keydown", e => {
  if (e.code === "Space" && !/INPUT|BUTTON/.test(e.target.tagName)) {
    e.preventDefault();
    state.run = !state.run;
    syncPlayBtn();
  }
});

// Interazione Pointer sul Canvas
cv.onpointerdown = e => {
  state.drag = true;
  state.lastX = e.clientX;
  cv.setPointerCapture(e.pointerId);
  cv.style.cursor = "grabbing";
};

cv.onpointermove = e => {
  if (state.drag) {
    state.T += ((e.clientX - state.lastX) / cv.getBoundingClientRect().width) * renderer.W / 55;
    state.lastX = e.clientX;
  } else {
    const id = renderer.hitTest(e.clientX, e.clientY);
    if (id !== state.hov) setHover(id);
  }
};

cv.onpointerup = cv.onpointercancel = () => {
  state.drag = false;
  cv.style.cursor = "grab";
};
cv.onpointerleave = () => {
  if (!state.drag) setHover(-1);
};

addEventListener("resize", () => renderer.resize());

// Loop animazione
let lastTime = 0;
function loop(ts) {
  const dt = Math.min((ts - lastTime) / 1000, 0.1);
  lastTime = ts;
  if (state.run && !state.drag) {
    state.T += dt * state.spd * 1.15 * state.dir;
  }
  renderer.render(state, currentModel);
  requestAnimationFrame(loop);
}

syncPlayBtn();
setTab(0);
requestAnimationFrame(loop);
