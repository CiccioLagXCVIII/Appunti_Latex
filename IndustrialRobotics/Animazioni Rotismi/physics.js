// Modello cinematico e dinamico unificato a "5) Laboratorio.tex"
const PI = Math.PI;

const TABS = [
  { id: "planar",    name: "Piano / Oziosa" },
  { id: "rack",      name: "Pignone-Cremagliera" },
  { id: "compound",  name: "Ordinario Composto" },
  { id: "spherical", name: "Sferico (Conico)" },
  { id: "planetary", name: "Epicicloidale (Willis)" },
  { id: "harmonic",  name: "Harmonic Drive" }
];

// Parametri geometrici di default e limiti per ogni tab
const DEFAULTS = {
  planar:    [16, 22, 30],         // z_a, z_b, z_c
  rack:      [18, 4],              // z_p, m [mm]
  compound:  [14, 30, 16, 32],     // z_a, z_b, z_c, z_d
  spherical: [18, 30],             // z_1, z_2
  planetary: [24, 12],             // z_s, z_p  (z_r = z_s + 2 z_p)
  harmonic:  [48]                  // z_FS     (z_CS = z_FS + 2)
};

const SLIDER_SPECS = {
  planar: [
    { sym: "z<sub>a</sub> (motrice)", min: 10, max: 36, step: 1 },
    { sym: "z<sub>b</sub> (interm./cond.)", min: 12, max: 44, step: 1 },
    { sym: "z<sub>c</sub> (condotta)", min: 12, max: 40, step: 1 }
  ],
  rack: [
    { sym: "z<sub>p</sub> (pignone)", min: 10, max: 32, step: 1 },
    { sym: "m [mm] (modulo)", min: 2, max: 8, step: 0.5 }
  ],
  compound: [
    { sym: "z<sub>a</sub> (motrice)", min: 10, max: 32, step: 1 },
    { sym: "z<sub>b</sub> (albero 2)", min: 16, max: 44, step: 1 },
    { sym: "z<sub>c</sub> (albero 2)", min: 10, max: 32, step: 1 },
    { sym: "z<sub>d</sub> (uscita)", min: 16, max: 44, step: 1 }
  ],
  spherical: [
    { sym: "z<sub>1</sub> (pignone)", min: 12, max: 34, step: 1 },
    { sym: "z<sub>2</sub> (corona)", min: 14, max: 40, step: 1 }
  ],
  planetary: [
    { sym: "z<sub>s</sub> (solare)", min: 16, max: 40, step: 2 },
    { sym: "z<sub>p</sub> (satelliti)", min: 8, max: 20, step: 2 }
  ],
  harmonic: [
    { sym: "z<sub>FS</sub> (FlexSpline)", min: 32, max: 80, step: 4 }
  ]
};

// Helper formattazione HTML frazioni e numeri
const fmt = (v, dec = 3) => (Math.abs(v) < 1e-4 ? "0.000" : (v < 0 ? "−" : "+") + Math.abs(v).toFixed(dec));
const fmtAbs = (v, dec = 2) => Math.abs(v).toFixed(dec);
const frac = (n, d) => `<span class="frac"><span class="num">${n}</span><span class="den">${d}</span></span>`;

// Numero di satelliti montabili equispaziati: (z_s + z_r) / n_p intero
function countPlanets(zs, zp) {
  const zr = zs + 2 * zp;
  const s = zs + zr;
  if (s % 4 === 0) return 4;
  if (s % 3 === 0) return 3;
  if (s % 5 === 0) return 5;
  return 2;
}

function computeModel(state) {
  const tabId = TABS[state.tab].id;
  const z = state.Z[tabId];

  if (tabId === "planar") {
    const mode = state.planarMode;
    if (mode === "single") {
      const za = z[0], zb = z[1];
      const tau = -za / zb;
      return {
        tabId,
        label: "τ<sub>a,b</sub> = ω<sub>b</sub> / ω<sub>a</sub>",
        tau,
        reduction: 1 / Math.abs(tau),
        ref: "ω<sub>a</sub>",
        badge: "Ingranaggio singolo (assi paralleli)",
        roles: [
          { name: "Ruota a (Motrice)", role: "Ingresso", c: "a", z: za, w: 1 },
          { name: "Ruota b (Condotta)", role: "Uscita (inversa)", c: "b", z: zb, w: tau }
        ],
        theory: `<b>Ingranaggio singolo ad assi paralleli</b>: le ruote <i>a</i> e <i>b</i> hanno lo stesso modulo normale <i>m</i> (<i>r<sub>i</sub> = m·z<sub>i</sub> / 2</i>). Nel punto di contatto <i>C</i> si ha rotolamento puro senza strisciamento (<i>ω<sub>a</sub> r<sub>a</sub> = −ω<sub>b</sub> r<sub>b</sub></i>).`,
        formula: `<div class="formula-row">τ<sub>a,b</sub> = ${frac("ω<sub>b</sub>", "ω<sub>a</sub>")} = −${frac("r<sub>a</sub>", "r<sub>b</sub>")} = −${frac("z<sub>a</sub>", "z<sub>b</sub>")} = −${frac(za, zb)} = <b>${fmt(tau)}</b> &nbsp;(i = ${fmtAbs(1 / tau)}:1)</div>`,
        notes: [
          "Il segno meno indica che due ruote a dentatura esterna ruotano in versi opposti.",
          "Passo primitivo: <i>p = π · m</i> (identico per entrambe le ruote)."
        ],
        extra: { mode, za, zb }
      };
    }

    if (mode === "internal") {
      const za = z[0];
      const zb = Math.max(z[1], za + 10); // La corona interna deve essere più grande del pignone
      const tau = za / zb;
      return {
        tabId,
        label: "τ<sub>a,b</sub> = ω<sub>b</sub> / ω<sub>a</sub>",
        tau,
        reduction: 1 / Math.abs(tau),
        ref: "ω<sub>a</sub>",
        badge: "Accoppiamento a dentatura interna",
        roles: [
          { name: "Pignone a (Motrice)", role: "Ingresso", c: "a", z: za, w: 1 },
          { name: "Corona b (Interna)", role: "Uscita (concorde)", c: "d", z: zb, w: tau }
        ],
        theory: `<b>Accoppiamento con corona a dentatura interna</b>: il pignone <i>a</i> ingrana all'interno della corona <i>b</i>. Entrambe le ruote mantengono lo <b>stesso verso di rotazione</b> (τ > 0).`,
        formula: `<div class="formula-row">τ<sub>a,b</sub> = ${frac("ω<sub>b</sub>", "ω<sub>a</sub>")} = +${frac("z<sub>a</sub>", "z<sub>b</sub>")} = +${frac(za, zb)} = <b>${fmt(tau)}</b> &nbsp;(i = ${fmtAbs(1 / tau)}:1)</div>`,
        notes: [
          "Principio utilizzato anche nell'accoppiamento satellite–corona dei rotismi epicicloidali."
        ],
        extra: { mode, za, zb }
      };
    }

    // Default: idler (ruota oziosa a, b, c)
    const za = z[0], zb = z[1], zc = z[2];
    const wb = -za / zb;
    const wc = za / zc;
    return {
      tabId,
      label: "τ<sub>a,c</sub> = ω<sub>c</sub> / ω<sub>a</sub>",
      tau: wc,
      reduction: 1 / Math.abs(wc),
      ref: "ω<sub>a</sub>",
      badge: "Rotismo semplice con ruota oziosa",
      roles: [
        { name: "Ruota a (Motrice)", role: "Ingresso", c: "a", z: za, w: 1 },
        { name: "Ruota b (Oziosa)", role: "Intermedia", c: "c", z: zb, w: wb },
        { name: "Ruota c (Condotta)", role: "Uscita (concorde)", c: "b", z: zc, w: wc }
      ],
      theory: `<b>Ruota dentata oziosa</b>: la ruota intermedia <i>b</i> collega due alberi distanziati e ristabilisce la <b>concordanza di verso</b> tra ingresso <i>a</i> e uscita <i>c</i> senza alterare il modulo del rapporto di velocità.`,
      formula: `<div class="formula-row">τ<sub>a,c</sub> = τ<sub>b,c</sub> · τ<sub>a,b</sub> = (−${frac("z<sub>b</sub>", "z<sub>c</sub>")}) · (−${frac("z<sub>a</sub>", "z<sub>b</sub>")}) = +${frac("z<sub>a</sub>", "z<sub>c</sub>")} = +${frac(za, zc)} = <b>${fmt(wc)}</b></div>`,
      notes: [
        `Il numero di denti della ruota oziosa (z<sub>b</sub> = ${zb}) si semplifica algebricamente.`,
        "Non trasmette coppia utile verso l'esterno, ma riduce ingombri e inerzie rispetto a ruote di grande diametro."
      ],
      extra: { mode, za, zb, zc }
    };
  }

  if (tabId === "rack") {
    const zp = z[0], m = z[1];
    const rp = (m * zp) / 2; // mm
    const pitch = PI * m;    // mm
    // Velocità lineare normalizzata per ω_p = 1 rad/s (in mm/s)
    const vc = rp * 1;
    return {
      tabId,
      label: "r<sub>p</sub> = m·z<sub>p</sub> / 2",
      tau: null, // Trasformazione rotazione -> traslazione
      tauDisplay: `${rp.toFixed(1)} mm`,
      reduction: null,
      ref: "ω<sub>p</sub> = 1 rad/s",
      badge: "Conversione Rotazione ↔ Traslazione",
      roles: [
        { name: "Pignone (p)", role: `r<sub>p</sub> = ${rp.toFixed(1)} mm`, c: "a", z: zp, w: 1 },
        { name: "Cremagliera (c)", role: "Asta a denti piani (r<sub>c</sub> → ∞)", c: "b", z: "∞", w: null, customVal: `${vc.toFixed(1)} mm/s` }
      ],
      theory: `<b>Meccanismo Pignone e Cremagliera</b>: caso limite di rotismo piano in cui il raggio della seconda ruota tende a infinito (<i>r<sub>c</sub> → ∞</i>). Converte reversibilmente la rotazione del pignone in traslazione lineare della cremagliera.`,
      formula: `<div class="formula-row">v<sub>c</sub> = ω<sub>p</sub> · r<sub>p</sub> = ω<sub>p</sub> · ${frac("m · z<sub>p</sub>", "2")} = ω<sub>p</sub> · ${rp.toFixed(1)} mm &nbsp; (p = π·m = ${pitch.toFixed(2)} mm)</div>`,
      notes: [
        "Impiegato sugli assi lineari dei robot cartesiani a portale (gantry) su lunghe corse.",
        "Evita i problemi di inflessione e velocità critica flessionale tipici delle viti a ricircolo molto lunghe."
      ],
      extra: { zp, m, rp, pitch, vc }
    };
  }

  if (tabId === "compound") {
    const za = z[0], zb = z[1], zc = z[2], zd = z[3];
    const wab = -za / zb;
    const tau = (za * zc) / (zb * zd);
    return {
      tabId,
      label: "τ<sub>a,d</sub> = ω<sub>d</sub> / ω<sub>a</sub>",
      tau,
      reduction: 1 / Math.abs(tau),
      ref: "ω<sub>a</sub>",
      badge: "2 Stadi in cascata (ω<sub>b</sub> = ω<sub>c</sub>)",
      roles: [
        { name: "Ruota a (Motrice)", role: "Albero 1 (Ingresso)", c: "a", z: za, w: 1 },
        { name: "Ruota b (Condotta)", role: "Albero 2 (solidale a c)", c: "b", z: zb, w: wab },
        { name: "Ruota c (Solidale)", role: "Albero 2 (ω<sub>c</sub> = ω<sub>b</sub>)", c: "c", z: zc, w: wab },
        { name: "Ruota d (Uscita)", role: "Albero 3 (Uscita)", c: "d", z: zd, w: tau }
      ],
      theory: `<b>Rotismo ordinario composto a cascata</b>: le ruote <i>b</i> e <i>c</i> sono calettate solidalmente sullo stesso albero intermedio (<i>ω<sub>c</sub> = ω<sub>b</sub></i>). Permette elevati rapporti di riduzione in ingombri radiali contenuti.`,
      formula: `<div class="formula-row">τ<sub>a,d</sub> = (−${frac("z<sub>c</sub>", "z<sub>d</sub>")}) · (−${frac("z<sub>a</sub>", "z<sub>b</sub>")}) = +${frac("z<sub>a</sub> · z<sub>c</sub>", "z<sub>b</sub> · z<sub>d</sub>")} = +${frac(za * zc, zb * zd)} = <b>${fmt(tau)}</b> &nbsp;(i = ${fmtAbs(1 / tau)}:1)</div>`,
      notes: [
        "Formula generale a <i>k</i> stadi: τ = (−1)<sup>p<sub>est</sub></sup> · (∏ z<sub>motrici</sub>) / (∏ z<sub>condotte</sub>).",
        "Con 2 ingranamenti esterni consecutivi si ha doppia inversione (τ<sub>a,d</sub> > 0, rotazione concorde)."
      ],
      extra: { za, zb, zc, zd, wab, tau }
    };
  }

  if (tabId === "spherical") {
    const z1 = z[0], z2 = z[1];
    const t = z1 / z2;
    const d1 = Math.atan(t) * 180 / PI;
    const d2 = 90 - d1;
    return {
      tabId,
      label: "|τ| = ω<sub>2</sub> / ω<sub>1</sub>",
      tau: t,
      reduction: 1 / t,
      ref: "ω<sub>1</sub>",
      badge: "Assi incidenti ortogonali (Σ = 90°)",
      roles: [
        { name: "1 Pignone conico", role: `δ₁ = ${d1.toFixed(1)}°`, c: "a", z: z1, w: 1 },
        { name: "2 Corona conica", role: `δ₂ = ${d2.toFixed(1)}°`, c: "b", z: z2, w: -t }
      ],
      theory: `<b>Rotismo sferico (ingranaggi conici)</b>: gli assi di rotazione sono incidenti nel vertice comune <b>O</b> (tipicamente a 90° nei polsi sferici dei robot). Il moto equivale al rotolamento puro di due coni primitivi.`,
      formula: `<div class="formula-row">|τ| = ${frac("z<sub>1</sub>", "z<sub>2</sub>")} = ${frac("sin δ₁", "sin δ₂")} = tan δ₁ = ${frac(z1, z2)} = <b>${t.toFixed(3)}</b> &nbsp;(δ₁ = ${d1.toFixed(1)}°, δ₂ = ${d2.toFixed(1)}°)</div>`,
      notes: [
        "Le dentature possono essere a denti dritti o elicoidali (es. dentatura Gleason per maggiore silenziosità).",
        "La generatrice rossa rappresenta la retta istantanea di contatto senza strisciamento tra i due coni."
      ],
      extra: { z1, z2, d1, d2, t }
    };
  }

  if (tabId === "planetary") {
    const zs = z[0], zp = z[1], zr = zs + 2 * zp;
    const np = countPlanets(zs, zp);
    const p0 = -zs / zr;
    const lk = state.epiMode;
    let ws, wc, wr, roles, tau, label, ref, badge, formula, theory;

    if (lk === "planetary") {
      ws = 1; wr = 0; wc = zs / (zs + zr);
      tau = wc; ref = "ω<sub>s</sub>"; label = "τ = ω<sub>c</sub> / ω<sub>s</sub>";
      badge = "Planetary: Corona r fissa (ω<sub>r</sub> = 0)";
      roles = ["Movente (Ingresso)", "Moto planetario", "Cedente (Uscita)", "Telaio (Fissa)"];
      theory = `<b>Configurazione "Planetary" (Corona fissa)</b>: è la configurazione principale nei riduttori epicicloidali per robotica. Ingresso sul Solare <i>s</i>, uscita sul Portasatelliti <i>c</i>.`;
      formula = `<div class="formula-row">τ = ${frac("ω<sub>c</sub>", "ω<sub>s</sub>")} = ${frac("z<sub>s</sub>", "z<sub>s</sub> + z<sub>r</sub>")} = ${frac(zs, zs + zr)} = <b>${fmt(tau)}</b> &nbsp;(i = ${fmtAbs(1 / tau)}:1, concorde)</div>`;
    } else if (lk === "star") {
      ws = 1; wc = 0; wr = -zs / zr;
      tau = wr; ref = "ω<sub>s</sub>"; label = "τ = ω<sub>r</sub> / ω<sub>s</sub>";
      badge = "Star (A stella): Portasatelliti c fisso (ω<sub>c</sub> = 0)";
      roles = ["Movente (Ingresso)", "Oziosi (Assi fissi)", "Telaio (Fermo)", "Cedente (Uscita)"];
      theory = `<b>Configurazione "Star" o a stella (Portasatelliti fisso)</b>: gli assi dei satelliti non orbitano; i satelliti agiscono da ruote oziose per ripartire la coppia e il verso si inverte.`;
      formula = `<div class="formula-row">τ = ${frac("ω<sub>r</sub>", "ω<sub>s</sub>")} = −${frac("z<sub>s</sub>", "z<sub>r</sub>")} = −${frac(zs, zr)} = <b>${fmt(tau)}</b> &nbsp;(i = ${fmtAbs(1 / tau)}:1, inverso)</div>`;
    } else if (lk === "solar") {
      ws = 0; wr = 1; wc = zr / (zs + zr);
      tau = wc; ref = "ω<sub>r</sub>"; label = "τ = ω<sub>c</sub> / ω<sub>r</sub>";
      badge = "Solar: Solare s fisso (ω<sub>s</sub> = 0)";
      roles = ["Telaio (Fermo)", "Moto planetario", "Cedente (Uscita)", "Movente (Ingresso)"];
      theory = `<b>Configurazione "Solar" (Solare fisso)</b>: ingresso sulla Corona <i>r</i> e uscita sul Portasatelliti <i>c</i>. Fornisce una riduzione lieve (τ ≈ 0.7 ÷ 0.9) o moltiplicazione se invertita.`;
      formula = `<div class="formula-row">τ = ${frac("ω<sub>c</sub>", "ω<sub>r</sub>")} = ${frac("z<sub>r</sub>", "z<sub>r</sub> + z<sub>s</sub>")} = ${frac(zr, zr + zs)} = <b>${fmt(tau)}</b> &nbsp;(i = ${fmtAbs(1 / tau)}:1)</div>`;
    } else {
      ws = 1; wc = state.diffRatio; wr = wc - (ws - wc) * zs / zr;
      tau = wc; ref = "ω<sub>s</sub>"; label = "ω<sub>c</sub> / ω<sub>s</sub> (2 GdL)";
      badge = "Differenziale libero (2 Gradi di Libertà)";
      roles = ["Ingresso 1", "Moto composto", "Ingresso 2", "Uscita"];
      theory = `<b>Rotismo differenziale (2 GdL)</b>: senza vincoli a telaio, la Formula di Willis lega linearmente tre velocità angolari (<i>z<sub>r</sub>ω<sub>r</sub> + z<sub>s</sub>ω<sub>s</sub> = (z<sub>r</sub> + z<sub>s</sub>)ω<sub>c</sub></i>).`;
      formula = `<div class="formula-row">p<sub>0</sub> = ${frac("ω<sub>r</sub> − ω<sub>c</sub>", "ω<sub>s</sub> − ω<sub>c</sub>")} = −${frac("z<sub>s</sub>", "z<sub>r</sub>")} = <b>${fmt(p0)}</b> &nbsp;⇒&nbsp; ω<sub>r</sub> = <b>${fmt(wr)}</b> ω<sub>s</sub></div>`;
    }

    const wp = wc - (ws - wc) * zs / zp;
    return {
      tabId,
      label,
      tau,
      reduction: Math.abs(tau) > 1e-4 ? 1 / Math.abs(tau) : null,
      ref,
      badge,
      roles: [
        { name: "Solare (s)", role: roles[0], c: "a", z: zs, w: ws },
        { name: `Satelliti ×${np} (p)`, role: roles[1], c: "b", z: zp, w: wp },
        { name: "Portasatelliti (c)", role: roles[2], c: "c", z: "–", w: wc },
        { name: "Corona (r)", role: roles[3], c: "d", z: zr, w: wr }
      ],
      theory,
      formula,
      notes: [
        `Congruenza geometrica: z<sub>r</sub> = z<sub>s</sub> + 2z<sub>p</sub> = ${zs} + 2·${zp} = <b>${zr}</b> denti.`,
        `Rapporto fondamentale di Willis: p<sub>0</sub> = −z<sub>s</sub>/z<sub>r</sub> = <b>${fmt(p0)}</b> · Satelliti montati: n<sub>p</sub> = <b>${np}</b>.`
      ],
      extra: { zs, zp, zr, np, ws, wc, wr, wp, p0 }
    };
  }

  // Harmonic Drive
  const zfs = z[0], zcs = zfs + 2;
  const lk = state.hdMode;
  let wwg = 1, wfs, wcs, tau, label, badge, roles, formula, theory;

  if (lk === "cs") {
    wcs = 0;
    wfs = (zfs - zcs) / zfs; // -2 / z_FS
    tau = wfs;
    label = "τ<sub>HD</sub> = ω<sub>FS</sub> / ω<sub>WG</sub>";
    badge = "Harmonic Drive: CS fissa (Standard)";
    roles = ["Ingresso (Camma ellittica)", "Uscita (Boccola flessibile)", "Telaio (Corona rigida)"];
    theory = `<b>Harmonic Drive (Configurazione Standard)</b>: il <i>Wave Generator</i> (WG) ellittico deforma la <i>FlexSpline</i> (FS) facendola ingranare con la <i>Circular Spline</i> (CS) fissa in due zone opposte (~30% dei denti). Poiché <i>z<sub>CS</sub> − z<sub>FS</sub> = 2</i>, ad ogni giro del WG la FS arretra di 2 denti.`;
    formula = `<div class="formula-row">τ<sub>HD</sub> = ${frac("ω<sub>FS</sub>", "ω<sub>WG</sub>")} = −${frac("z<sub>CS</sub> − z<sub>FS</sub>", "z<sub>FS</sub>")} = −${frac(2, zfs)} = <b>${fmt(tau, 4)}</b> &nbsp;(i = ${zfs / 2}:1, retrogrado)</div>`;
  } else {
    wfs = 0;
    wcs = (zcs - zfs) / zcs; // +2 / z_CS
    tau = wcs;
    label = "τ<sub>HD</sub> = ω<sub>CS</sub> / ω<sub>WG</sub>";
    badge = "Harmonic Drive: FS fissa (Alternativa)";
    roles = ["Ingresso (Camma ellittica)", "Telaio (Boccola flessibile)", "Uscita (Corona rigida)"];
    theory = `<b>Harmonic Drive (FlexSpline fissa)</b>: bloccando la FlexSpline a telaio, il movimento viene prelevato dalla Circular Spline esterna, che avanza di 2 denti per ogni giro del Wave Generator nello stesso verso.`;
    formula = `<div class="formula-row">τ<sub>HD</sub> = ${frac("ω<sub>CS</sub>", "ω<sub>WG</sub>")} = +${frac("z<sub>CS</sub> − z<sub>FS</sub>", "z<sub>CS</sub>")} = +${frac(2, zcs)} = <b>${fmt(tau, 4)}</b> &nbsp;(i = ${zcs / 2}:1, concorde)</div>`;
  }

  return {
    tabId,
    label,
    tau,
    reduction: 1 / Math.abs(tau),
    ref: "ω<sub>WG</sub>",
    badge,
    roles: [
      { name: "Wave Generator (WG)", role: roles[0], c: "a", z: "cam", w: wwg },
      { name: "FlexSpline (FS)", role: roles[1], c: "b", z: zfs, w: wfs },
      { name: "Circular Spline (CS)", role: roles[2], c: "d", z: zcs, w: wcs }
    ],
    theory,
    formula,
    notes: [
      `Zero-backlash (gioco angolare nullo) grazie all'ingranamento simultaneo su entrambi i fianchi lungo l'asse maggiore.`,
      `La parete sottile della FlexSpline introduce cedevolezza torsionale k<sub>tor</sub> (risonanze 10÷30 Hz), compensata tramite doppio encoder (motor-side e link-side).`
    ],
    extra: { zfs, zcs, wwg, wfs, wcs }
  };
}
