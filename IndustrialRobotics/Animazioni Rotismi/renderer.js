// Motore di rendering Canvas 2D HiDPI per i rotismi meccanici

function createRenderer(canvas) {
  const ctx = canvas.getContext("2d");
  const W = 680;
  const H = 446;
  let dpr = Math.min(window.devicePixelRatio || 1, 2.5);
  let HIT = [];
  let K = {};

  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2.5);
    canvas.width = Math.round(W * dpr);
    canvas.height = Math.round(H * dpr);
  }
  resize();

  function refreshColors() {
    const v = getComputedStyle(document.documentElement);
    const g = k => v.getPropertyValue(k).trim();
    K = {
      bg: g("--surface"),
      bg2: g("--surface-2"),
      ink: g("--ink"),
      mut: g("--mut"),
      line: g("--line"),
      a: g("--a"),
      b: g("--b"),
      c: g("--c"),
      d: g("--d"),
      hi: g("--hi")
    };
  }

  function view(x0, x1, h) {
    const s = Math.min(1.8, (W - 60) / (x1 - x0), (H - 96) / (2 * h));
    ctx.save();
    ctx.translate(W / 2 - s * (x0 + x1) / 2, H / 2 - 4);
    ctx.scale(s, s);
    ctx.lineWidth = 1.4 / s;
    ctx.font = `600 ${12 / s}px "IBM Plex Sans", system-ui, sans-serif`;
    return s;
  }

  function pushHit(id, x, y, r, inn = false) {
    const M = ctx.getTransform();
    HIT.push({
      id,
      x: (M.a * x + M.e) / dpr,
      y: (M.d * y + M.f) / dpr,
      r: (r * Math.abs(M.a)) / dpr,
      inn
    });
  }

  // Simbolo ingegneristico di vincolo a telaio
  function drawFix(x, y, scale = 1) {
    const lw = ctx.lineWidth;
    ctx.save();
    ctx.translate(x, y);
    ctx.scale(scale, scale);
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(-8, 13);
    ctx.lineTo(8, 13);
    ctx.closePath();
    ctx.fillStyle = K.bg;
    ctx.fill();
    ctx.lineWidth = lw / scale;
    ctx.strokeStyle = K.ink;
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(-11, 13);
    ctx.lineTo(11, 13);
    ctx.stroke();
    for (let i = -9; i <= 7; i += 4) {
      ctx.beginPath();
      ctx.moveTo(i, 13);
      ctx.lineTo(i - 3, 17.5);
      ctx.stroke();
    }
    ctx.beginPath();
    ctx.arc(0, 0, 2.5, 0, 2 * PI);
    ctx.fillStyle = K.ink;
    ctx.fill();
    ctx.restore();
  }

  function drawMeshDot(x, y, showAnn) {
    if (!showAnn) return;
    ctx.save();
    ctx.beginPath();
    ctx.arc(x, y, 4.2, 0, 2 * PI);
    ctx.fillStyle = K.hi;
    ctx.fill();
    ctx.lineWidth = ctx.lineWidth * 0.9;
    ctx.strokeStyle = K.bg;
    ctx.stroke();
    ctx.restore();
  }

  function drawLabel(text, x, y, col) {
    ctx.save();
    ctx.fillStyle = col || K.ink;
    ctx.textAlign = "center";
    ctx.fillText(text, x, y);
    ctx.restore();
  }

  // Disegna ruota dentata (esterna o interna) con dettagli meccanici
  function drawGear(x, y, r, z, a, col, inn, id, wRel, state, extraAlpha = 1) {
    const m = (2 * r) / z;
    const tip = inn ? r - m * 0.92 : r + m * 0.92;
    const root = inn ? r + 1.15 * m : r - 1.15 * m;
    const p = PI / z;
    const isHov = id === state.hov;
    const lw = ctx.lineWidth;
    const M = ctx.getTransform();
    const rimR = inn ? root + 15 : 0;

    pushHit(id, x, y, r, inn);

    ctx.save();
    ctx.globalAlpha = extraAlpha;
    if (isHov) {
      ctx.lineWidth = lw * 1.8;
      ctx.shadowColor = col;
      ctx.shadowBlur = 14;
    }

    // Profilo dentatura
    ctx.beginPath();
    if (inn) {
      ctx.arc(x, y, rimR, 0, 2 * PI);
    }
    for (let k = 0; k < z; k++) {
      const t = a + 2 * p * k;
      const pts = [
        [root, t - 0.50 * p],
        [root, t - 0.36 * p],
        [r,    t - 0.23 * p],
        [tip,  t - 0.12 * p],
        [tip,  t + 0.12 * p],
        [r,    t + 0.23 * p],
        [root, t + 0.36 * p],
        [root, t + 0.50 * p]
      ];
      pts.forEach(([q, u], i) => {
        const X = x + q * Math.cos(u);
        const Y = y + q * Math.sin(u);
        (k || i) ? ctx.lineTo(X, Y) : ctx.moveTo(X, Y);
      });
    }
    ctx.closePath();

    // Riempimento tecnico
    ctx.fillStyle = K.bg;
    ctx.fill("evenodd");
    const grad = ctx.createRadialGradient(x, y, inn ? root : 4, x, y, inn ? rimR : tip);
    grad.addColorStop(0, col);
    grad.addColorStop(1, col);
    ctx.globalAlpha = extraAlpha * (isHov ? 0.42 : 0.22);
    ctx.fillStyle = grad;
    ctx.fill("evenodd");
    ctx.globalAlpha = extraAlpha;
    ctx.strokeStyle = col;
    ctx.stroke();
    ctx.shadowBlur = 0;

    if (!inn) {
      // Razze / fori di alleggerimento per ruote medio-grandi
      if (r > 28) {
        const nH = z >= 24 ? 4 : 3;
        const rIn = Math.max(10, r * 0.28);
        const rOut = root * 0.72;
        if (rOut - rIn > 7) {
          ctx.save();
          ctx.strokeStyle = col;
          for (let k = 0; k < nH; k++) {
            const g0 = a + (k * 2 * PI) / nH + 0.26;
            const g1 = a + ((k + 1) * 2 * PI) / nH - 0.26;
            if (g1 > g0) {
              ctx.beginPath();
              ctx.arc(x, y, rOut, g0, g1);
              ctx.arc(x, y, rIn, g1, g0, true);
              ctx.closePath();
              ctx.fillStyle = K.bg;
              ctx.globalAlpha = extraAlpha * 0.78;
              ctx.fill();
              ctx.globalAlpha = extraAlpha * 0.42;
              ctx.stroke();
            }
          }
          ctx.restore();
        }
      }

      // Mozzo e foro albero con cava chiavetta
      const hubR = Math.min(root * 0.48, Math.max(7, r * 0.24));
      ctx.beginPath();
      ctx.arc(x, y, hubR, 0, 2 * PI);
      ctx.fillStyle = K.bg;
      ctx.fill();
      ctx.globalAlpha = extraAlpha * 0.34;
      ctx.fillStyle = col;
      ctx.fill();
      ctx.globalAlpha = extraAlpha;
      ctx.strokeStyle = col;
      ctx.stroke();

      const boreR = Math.max(3.2, hubR * 0.44);
      ctx.beginPath();
      ctx.arc(x, y, boreR, 0, 2 * PI);
      ctx.fillStyle = K.bg;
      ctx.fill();
      ctx.strokeStyle = K.ink;
      ctx.stroke();

      // Tacca di fase
      const mkR = root * 0.82;
      ctx.beginPath();
      ctx.moveTo(x + boreR * Math.cos(a), y + boreR * Math.sin(a));
      ctx.lineTo(x + mkR * Math.cos(a), y + mkR * Math.sin(a));
      ctx.lineWidth = lw * 2.1;
      ctx.strokeStyle = col;
      ctx.stroke();
      ctx.beginPath();
      ctx.arc(x + mkR * Math.cos(a), y + mkR * Math.sin(a), 2.5, 0, 2 * PI);
      ctx.fillStyle = col;
      ctx.fill();
    } else {
      // Tacche di riferimento sulla corona interna
      for (let k = 0; k < 4; k++) {
        const ang = a + (k * PI) / 2;
        ctx.beginPath();
        ctx.moveTo(x + root * Math.cos(ang), y + root * Math.sin(ang));
        ctx.lineTo(x + rimR * Math.cos(ang), y + rimR * Math.sin(ang));
        ctx.lineWidth = k === 0 ? lw * 2.4 : lw * 1.2;
        ctx.strokeStyle = col;
        ctx.stroke();
      }
      ctx.beginPath();
      ctx.arc(x + ((root + rimR) / 2) * Math.cos(a), y + ((root + rimR) / 2) * Math.sin(a), 3.2, 0, 2 * PI);
      ctx.fillStyle = col;
      ctx.fill();
    }

    // Circonferenza primitiva tratteggiata e freccia velocità angolare
    if (state.showAnn) {
      ctx.save();
      ctx.setLineDash([(4 * dpr) / M.a, (3.5 * dpr) / M.a]);
      ctx.lineWidth = lw * 0.95;
      ctx.strokeStyle = K.ink;
      ctx.globalAlpha = extraAlpha * 0.42;
      ctx.beginPath();
      ctx.arc(x, y, r, 0, 2 * PI);
      ctx.stroke();
      ctx.restore();

      if (wRel !== undefined && Math.abs(wRel) > 0.01) {
        const sgn = wRel * state.dir > 0 ? 1 : -1;
        const arR = inn ? rimR - 5.5 : Math.max(12, r * 0.56);
        const span = Math.min(1.15, Math.max(0.34, Math.abs(wRel) * 0.55)) * sgn;
        const a0 = -PI / 2 - 0.5 * span;
        const a1 = -PI / 2 + 0.5 * span;
        ctx.save();
        ctx.strokeStyle = col;
        ctx.fillStyle = col;
        ctx.lineWidth = lw * 1.6;
        ctx.beginPath();
        ctx.arc(x, y, arR, a0, a1, sgn < 0);
        ctx.stroke();
        const tx = x + arR * Math.cos(a1);
        const ty = y + arR * Math.sin(a1);
        const tg = a1 + (sgn * PI) / 2;
        const ah = 4.6;
        ctx.beginPath();
        ctx.moveTo(tx, ty);
        ctx.lineTo(tx - ah * Math.cos(tg - 0.5), ty - ah * Math.sin(tg - 0.5));
        ctx.lineTo(tx - ah * Math.cos(tg + 0.5), ty - ah * Math.sin(tg + 0.5));
        ctx.closePath();
        ctx.fill();
        ctx.restore();
      }
    }
    ctx.restore();
  }

  // 1. ROTISMO PIANO (singolo / con oziosa / dentatura interna)
  function drawPlanar(state, model) {
    const { mode } = model.extra;
    const T = state.T;

    if (mode === "single") {
      const { za, zb } = model.extra;
      const ra = za * 2, rb = zb * 2;
      const x = [-rb / 2, ra + rb / 2];
      const xa = -(ra + rb) / 2, xb = (ra + rb) / 2;
      const a0 = T;
      const a1 = PI * (1 - 1 / zb) - (a0 * za) / zb;
      const s = view(xa - ra - 18, xb + rb + 18, Math.max(ra, rb) + 28);

      if (state.showAnn) {
        ctx.save();
        ctx.setLineDash([3 / s, 3 / s]);
        ctx.strokeStyle = K.mut;
        ctx.globalAlpha = 0.4;
        ctx.beginPath();
        ctx.moveTo(xa - ra - 10, 0);
        ctx.lineTo(xb + rb + 10, 0);
        ctx.stroke();
        ctx.restore();
      }

      drawGear(xa, 0, ra, za, a0, K.a, false, 0, 1, state);
      drawGear(xb, 0, rb, zb, a1, K.b, false, 1, -za / zb, state);
      drawFix(xa, 0, 1);
      drawFix(xb, 0, 1);
      drawMeshDot(xa + ra, 0, state.showAnn);

      drawLabel(`a (z=${za})`, xa, ra + 24 / s, K.a);
      drawLabel(`b (z=${zb})`, xb, rb + 24 / s, K.b);
      ctx.restore();
      return;
    }

    if (mode === "internal") {
      const { za, zb } = model.extra;
      const ra = za * 2, rb = zb * 2;
      const xa = rb - ra;
      const a0 = T;
      const a1 = PI / zb + (a0 * za) / zb;
      const s = view(-rb - 28, rb + 28, rb + 36);

      drawGear(0, 0, rb, zb, a1, K.d, true, 1, za / zb, state);
      drawGear(xa, 0, ra, za, a0, K.a, false, 0, 1, state);
      drawFix(xa, 0, 0.95);
      drawFix(0, rb + 18, 1);
      drawMeshDot(rb, 0, state.showAnn);

      drawLabel(`a (z=${za})`, xa, ra + 22 / s, K.a);
      drawLabel(`b corona interna (z=${zb})`, 0, rb + 36 / s, K.d);
      ctx.restore();
      return;
    }

    // Con ruota oziosa (a, b, c)
    const { za, zb, zc } = model.extra;
    const r = [za * 2, zb * 2, zc * 2];
    const x = [0, r[0] + r[1], r[0] + 2 * r[1] + r[2]];
    const a = [T];
    a[1] = PI * (1 - 1 / zb) - (a[0] * za) / zb;
    a[2] = PI * (1 - 1 / zc) - (a[1] * zb) / zc;
    const w = [1, -za / zb, za / zc];
    const C = [K.a, K.c, K.b];
    const names = ["a", "b (oziosa)", "c"];
    const zs = [za, zb, zc];
    const s = view(-r[0] - 16, x[2] + r[2] + 16, Math.max(...r) + 28);

    if (state.showAnn) {
      ctx.save();
      ctx.setLineDash([3 / s, 3 / s]);
      ctx.strokeStyle = K.mut;
      ctx.globalAlpha = 0.4;
      ctx.beginPath();
      ctx.moveTo(-r[0] - 8, 0);
      ctx.lineTo(x[2] + r[2] + 8, 0);
      ctx.stroke();
      ctx.restore();
    }

    zs.forEach((q, i) => {
      drawGear(x[i], 0, r[i], q, a[i], C[i], false, i, w[i], state);
      drawFix(x[i], 0, 1);
      drawLabel(`${names[i]} (z=${q})`, x[i], r[i] + 22 / s, C[i]);
    });
    drawMeshDot(r[0], 0, state.showAnn);
    drawMeshDot(x[1] + r[1], 0, state.showAnn);
    ctx.restore();
  }

  // 2. PIGNONE E CREMAGLIERA
  function drawRack(state, model) {
    const { zp, m } = model.extra;
    // Scala grafica: teniamo R_px proporzionale ma leggibile
    const modPx = 4.2 + (m - 2) * 0.55;
    const R = (zp * modPx) / 2;
    const pitch = PI * modPx;
    const tp = state.T;
    const s = view(-175, 175, R + 75);
    const lw = ctx.lineWidth;

    const pinionY = -28;
    const rackPitchY = pinionY + R;

    // Disegna pignone sopra
    drawGear(0, pinionY, R, zp, tp, K.a, false, 0, 1, state);
    drawFix(0, pinionY, 1);

    // Cremagliera: spostamento lineare coerente con rotolamento puro al contatto in basso (phi = PI/2)
    const rawShift = -R * (tp - PI / 2) + 0.5 * pitch;
    const modShift = ((rawShift % pitch) + pitch) % pitch;

    const rackHalfW = 195;
    const teethCount = Math.ceil((2 * rackHalfW) / pitch) + 4;
    const startX = -rackHalfW - pitch + modShift;

    const addendum = 0.9 * modPx;
    const dedendum = 1.15 * modPx;
    const bodyBottom = rackPitchY + dedendum + 24;

    pushHit(1, 0, rackPitchY + 12, 95, false);

    ctx.save();
    const isHov = state.hov === 1;
    if (isHov) {
      ctx.shadowColor = K.b;
      ctx.shadowBlur = 12;
    }

    // Clip area cremagliera per scorrimento pulito
    ctx.beginPath();
    ctx.rect(-rackHalfW, rackPitchY - addendum - 10, 2 * rackHalfW, bodyBottom - rackPitchY + addendum + 20);
    ctx.clip();

    // Corpo e denti a fianchi piani della cremagliera
    ctx.beginPath();
    ctx.moveTo(startX - pitch, bodyBottom);
    ctx.lineTo(startX - pitch, rackPitchY + dedendum);
    for (let j = 0; j < teethCount; j++) {
      const cx = startX + j * pitch;
      ctx.lineTo(cx - 0.34 * pitch, rackPitchY + dedendum);
      ctx.lineTo(cx - 0.14 * pitch, rackPitchY - addendum);
      ctx.lineTo(cx + 0.14 * pitch, rackPitchY - addendum);
      ctx.lineTo(cx + 0.34 * pitch, rackPitchY + dedendum);
    }
    ctx.lineTo(startX + teethCount * pitch, bodyBottom);
    ctx.closePath();

    ctx.fillStyle = K.bg;
    ctx.fill();
    ctx.globalAlpha = isHov ? 0.38 : 0.22;
    ctx.fillStyle = K.b;
    ctx.fill();
    ctx.globalAlpha = 1;
    ctx.lineWidth = isHov ? lw * 1.8 : lw * 1.3;
    ctx.strokeStyle = K.b;
    ctx.stroke();
    ctx.shadowBlur = 0;

    // Tacche di riferimento mobili sulla cremagliera per mostrare la traslazione reale
    const markerPeriod = pitch * 4;
    const markerShift = ((rawShift % markerPeriod) + markerPeriod) % markerPeriod;
    for (let xMk = -rackHalfW + markerShift; xMk < rackHalfW; xMk += markerPeriod) {
      ctx.beginPath();
      ctx.arc(xMk, rackPitchY + dedendum + 12, 3, 0, 2 * PI);
      ctx.fillStyle = K.b;
      ctx.fill();
    }
    ctx.restore();

    // Guida prismatica fissa a telaio sotto la cremagliera
    ctx.save();
    ctx.strokeStyle = K.ink;
    ctx.lineWidth = lw * 1.2;
    ctx.beginPath();
    ctx.moveTo(-rackHalfW + 10, bodyBottom + 3);
    ctx.lineTo(rackHalfW - 10, bodyBottom + 3);
    ctx.stroke();
    drawFix(-100, bodyBottom + 3, 0.85);
    drawFix(100, bodyBottom + 3, 0.85);
    ctx.restore();

    // Retta primitiva della cremagliera, punto di contatto e vettore velocità lineare v_c
    if (state.showAnn) {
      ctx.save();
      ctx.setLineDash([4 / s, 3.5 / s]);
      ctx.strokeStyle = K.ink;
      ctx.globalAlpha = 0.45;
      ctx.beginPath();
      ctx.moveTo(-rackHalfW + 8, rackPitchY);
      ctx.lineTo(rackHalfW - 8, rackPitchY);
      ctx.stroke();
      ctx.restore();

      drawMeshDot(0, rackPitchY, true);

      // Vettore v_c
      const vDir = -state.dir; // Quando pignone gira orario (+dir), punto in basso va a sinistra (-x)
      const arrowLen = 46;
      const ay = bodyBottom - 12;
      ctx.save();
      ctx.strokeStyle = K.b;
      ctx.fillStyle = K.b;
      ctx.lineWidth = lw * 2;
      ctx.beginPath();
      ctx.moveTo(0, ay);
      ctx.lineTo(vDir * arrowLen, ay);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(vDir * (arrowLen + 7), ay);
      ctx.lineTo(vDir * (arrowLen - 2), ay - 4.5);
      ctx.lineTo(vDir * (arrowLen - 2), ay + 4.5);
      ctx.closePath();
      ctx.fill();
      drawLabel("v_c = ω_p · r_p", vDir * (arrowLen + 42), ay + 4 / s, K.b);
      ctx.restore();
    }

    drawLabel(`Pignone p (z_p=${zp}, r_p=${(m * zp / 2).toFixed(1)} mm)`, 0, pinionY - R - 16 / s, K.a);
    drawLabel("Cremagliera c (r_c → ∞)", 0, bodyBottom + 34 / s, K.b);
    ctx.restore();
  }

  // 3. ROTISMO ORDINARIO COMPOSTO (a, b, c, d) + Mini-vista assiale
  function drawCompound(state, model) {
    const { za, zb, zc, zd, wab, tau } = model.extra;
    const z = [za, zb, zc, zd];
    const r = z.map(q => q * 2);
    const x = [0, r[0] + r[1], r[0] + r[1], r[0] + r[1] + r[2] + r[3]];
    const T = state.T;
    const a = [T];
    a[1] = PI * (1 - 1 / zb) - (a[0] * za) / zb;
    a[2] = a[1];
    a[3] = PI * (1 - 1 / zd) - (a[2] * zc) / zd;
    const w = [1, wab, wab, tau];
    const C = [K.a, K.b, K.c, K.d];

    const s = view(-r[0] - 16, x[3] + r[3] + 16, Math.max(...r) + 30);

    if (state.showAnn) {
      ctx.save();
      ctx.setLineDash([3 / s, 3 / s]);
      ctx.strokeStyle = K.mut;
      ctx.globalAlpha = 0.4;
      ctx.beginPath();
      ctx.moveTo(-r[0] - 8, 0);
      ctx.lineTo(x[3] + r[3] + 8, 0);
      ctx.stroke();
      ctx.restore();
    }

    // Disegna prima la ruota più grande tra b e c così entrambe sono ben leggibili
    const order = r[1] >= r[2] ? [0, 1, 2, 3] : [0, 2, 1, 3];
    order.forEach(i => drawGear(x[i], 0, r[i], z[i], a[i], C[i], false, i, w[i], state));

    // Perni di calettamento solidale tra b e c sull'albero 2
    const rMin = Math.min(r[1], r[2]);
    ctx.save();
    for (let k = 0; k < 3; k++) {
      const ang = a[1] + (k * 2 * PI) / 3;
      const px = x[1] + rMin * 0.55 * Math.cos(ang);
      const py = rMin * 0.55 * Math.sin(ang);
      ctx.beginPath();
      ctx.arc(px, py, 3, 0, 2 * PI);
      ctx.fillStyle = K.bg;
      ctx.fill();
      ctx.strokeStyle = K.ink;
      ctx.stroke();
    }
    ctx.restore();

    [0, 1, 3].forEach(i => drawFix(x[i], 0, 1));
    drawMeshDot(r[0], 0, state.showAnn);
    drawMeshDot(x[1] + r[2], 0, state.showAnn);

    drawLabel(`a (z=${za})`, x[0], r[0] + 22 / s, K.a);
    drawLabel(`b (z=${zb}) + c (z=${zc}) solidali`, x[1], Math.max(r[1], r[2]) + 22 / s, K.ink);
    drawLabel(`d (z=${zd})`, x[3], r[3] + 22 / s, K.d);
    ctx.restore();

    // Mini-schema assiale dall'alto (in basso al centro-destra) per chiarire i 2 piani di ingranamento
    ctx.save();
    const bx = W - 188, by = 52, bw = 172, bh = 74;
    ctx.fillStyle = K.bg2;
    ctx.globalAlpha = 0.92;
    ctx.strokeStyle = K.line;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.roundRect(bx, by, bw, bh, 8);
    ctx.fill();
    ctx.stroke();
    ctx.globalAlpha = 1;

    ctx.fillStyle = K.mut;
    ctx.font = '600 9.5px "IBM Plex Mono", monospace';
    ctx.fillText("SCHEMA ASSIALE (ω_b = ω_c)", bx + 8, by + 13);

    const sx1 = bx + 26, sx2 = bx + 86, sx3 = bx + 146;
    const p1y = by + 32, p2y = by + 56;
    // Alberi
    ctx.strokeStyle = K.mut;
    ctx.lineWidth = 1.6;
    [[sx1, by + 20, by + 46], [sx2, by + 20, by + 66], [sx3, by + 42, by + 66]].forEach(([ax, y0, y1]) => {
      ctx.beginPath();
      ctx.moveTo(ax, y0);
      ctx.lineTo(ax, y1);
      ctx.stroke();
    });
    // Ruote viste di profilo (rettangoli colorati)
    const bar = (cx, cy, wBar, col, txt) => {
      ctx.strokeStyle = col;
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.moveTo(cx - wBar / 2, cy);
      ctx.lineTo(cx + wBar / 2, cy);
      ctx.stroke();
      ctx.fillStyle = col;
      ctx.font = '700 10px "IBM Plex Sans", sans-serif';
      ctx.fillText(txt, cx - 3, cy - 5);
    };
    bar(sx1, p1y, 24, K.a, "a");
    bar(sx2, p1y, 34, K.b, "b");
    bar(sx2, p2y, 24, K.c, "c");
    bar(sx3, p2y, 34, K.d, "d");
    ctx.restore();
  }

  // 4. ROTISMO SFERICO (CONICO) con Z-Sorting dei denti 3D
  function drawSpherical(state, model) {
    const { z1, z2, d1: d1Deg, d2: d2Deg } = model.extra;
    const d1 = (d1Deg * PI) / 180;
    const d2 = (d2Deg * PI) / 180;
    const L = 148;
    const t1 = state.T;
    const t2 = (-state.T * z1) / z2 + PI / z2;

    const cy = Math.cos(0.56), sy = Math.sin(0.56);
    const cx = Math.cos(0.38), sx = Math.sin(0.38);
    const pr = ([x, y, z]) => {
      const X = x * cy + z * sy;
      const Z = -x * sy + z * cy;
      return [W / 2 - 42 + X, H / 2 + 28 - (y * cx - Z * sx), Z];
    };

    const poly = (pts, fill, str, w = 1, al = 1) => {
      ctx.save();
      ctx.beginPath();
      pts.forEach((p, i) => {
        const q = pr(p);
        i ? ctx.lineTo(q[0], q[1]) : ctx.moveTo(q[0], q[1]);
      });
      if (fill) { ctx.globalAlpha = al; ctx.fillStyle = fill; ctx.fill(); }
      if (str) { ctx.globalAlpha = 1; ctx.strokeStyle = str; ctx.lineWidth = w; ctx.stroke(); }
      ctx.restore();
    };

    const f1 = (p, s) => [s * L * Math.cos(d1), s * L * Math.sin(d1) * Math.cos(p), s * L * Math.sin(d1) * Math.sin(p)];
    const f2 = (p, s) => [s * L * Math.sin(d2) * Math.cos(p), s * L * Math.cos(d2), -s * L * Math.sin(d2) * Math.sin(p)];

    const c1 = pr([L * 0.8 * Math.cos(d1), 0, 0]);
    const c2 = pr([0, L * 0.8 * Math.cos(d2), 0]);
    HIT.push({ id: 0, x: c1[0], y: c1[1], r: L * Math.sin(d1) * 0.95, inn: false });
    HIT.push({ id: 1, x: c2[0], y: c2[1], r: L * Math.sin(d2) * 0.95, inn: false });

    const drawBevel = (fn, z, t, col, ax, id) => {
      const isH = state.hov === id;
      if (state.showAnn) {
        const rim = Array.from({ length: 49 }, (_, i) => fn((i / 48) * 2 * PI, 1));
        poly([[0, 0, 0], ...rim], col, null, 1, 0.11);
        for (let i = 0; i < 6; i++) poly([[0, 0, 0], fn(t + (i * PI) / 3, 1)], null, col, 1, 0.25);
      }

      const outer = Array.from({ length: 65 }, (_, i) => fn((i / 64) * 2 * PI, 1));
      const inner = Array.from({ length: 65 }, (_, i) => fn((i / 64) * 2 * PI, 0.75));
      poly(outer, col, col, isH ? 2.6 : 1.6, isH ? 0.34 : 0.18);
      poly(inner, K.bg, col, 1.1, 0.45);

      // Z-sort dei denti per resa 3D pulita
      const teeth = [];
      for (let k = 0; k < z; k++) {
        const p = t + (2 * PI * k) / z;
        const dp = PI / (z * 1.68);
        const pts = [fn(p - dp, 0.75), fn(p - dp * 0.65, 1.03), fn(p + dp * 0.65, 1.03), fn(p + dp, 0.75)];
        const depth = pr(fn(p, 0.9))[2];
        teeth.push({ k, pts, depth });
      }
      teeth.sort((a, b) => a.depth - b.depth);
      teeth.forEach(({ k, pts }) => {
        poly(pts, k === 0 ? K.ink : col, k === 0 ? K.ink : col, k === 0 ? 2.1 : 1.1, k === 0 ? 0.9 : 0.58);
      });

      poly([[0, 0, 0], ax], null, K.mut, 1.5);
    };

    const A1 = [L * Math.cos(d1) + 50, 0, 0];
    const A2 = [0, L * Math.cos(d2) + 50, 0];
    drawBevel(f2, z2, t2, K.b, A2, 1);
    drawBevel(f1, z1, t1, K.a, A1, 0);

    // Generatrice comune di contatto
    const contactEnd = f1(0, 1);
    poly([[0, 0, 0], contactEnd], null, K.hi, 2.4);
    if (state.showAnn) {
      const cm = pr(f1(0, 0.88));
      drawMeshDot(cm[0], cm[1], true);
    }

    const o = pr([0, 0, 0]);
    ctx.beginPath();
    ctx.arc(o[0], o[1], 4.5, 0, 2 * PI);
    ctx.fillStyle = K.ink;
    ctx.fill();
    ctx.font = '600 13px "IBM Plex Sans", system-ui, sans-serif';
    drawLabel("O (vertice coni)", o[0] - 42, o[1] + 20, K.ink);

    const p1 = pr(A1), p2 = pr(A2);
    drawFix(p1[0], p1[1], 0.9);
    drawFix(p2[0], p2[1], 0.9);
    drawLabel(`1 Pignone (z₁=${z1}, δ₁=${d1Deg.toFixed(0)}°)`, p1[0] + 16, p1[1] - 10, K.a);
    drawLabel(`2 Corona (z₂=${z2}, δ₂=${d2Deg.toFixed(0)}°)`, p2[0] + 14, p2[1] - 12, K.b);
  }

  // 5. ROTISMO EPICICLOIDALE (s, p, c, r)
  function drawPlanetary(state, model) {
    const { zs, zp, zr, np, ws, wc, wr, wp } = model.extra;
    const rs = zs * 2, rp = zp * 2, rr = zr * 2, R = rs + rp;
    const T = state.T;
    const ts = ws * T, tc = wc * T;
    const s = view(-rr - 30, rr + 30, rr + 44);

    const P = Array.from({ length: np }, (_, k) => {
      const g = tc + (2 * PI * k) / np;
      const th = g + PI - PI / zp - ((ts - g) * zs) / zp;
      return [g, th];
    });
    const tr = P[0][0] + ((P[0][1] - P[0][0]) * zp) / zr + PI / zr;

    // Corona (r, id=3), Solare (s, id=0), Satelliti (p, id=1)
    drawGear(0, 0, rr, zr, tr, K.d, true, 3, wr, state);
    drawGear(0, 0, rs, zs, ts, K.a, false, 0, ws, state);
    P.forEach(([g, th]) => drawGear(R * Math.cos(g), R * Math.sin(g), rp, zp, th, K.b, false, 1, wp, state));

    // Portasatelliti (c, id=2)
    pushHit(2, 0, 0, R, true);
    ctx.save();
    const isHc = state.hov === 2;
    ctx.strokeStyle = K.c;
    ctx.lineWidth = (isHc ? 6.5 : 4.2) / s;
    ctx.globalAlpha = isHc ? 0.92 : 0.75;
    ctx.beginPath();
    ctx.arc(0, 0, R, 0, 2 * PI);
    P.forEach(([g]) => {
      ctx.moveTo(0, 0);
      ctx.lineTo(R * Math.cos(g), R * Math.sin(g));
    });
    ctx.stroke();
    ctx.globalAlpha = 1;

    ctx.lineWidth = 1.5 / s;
    P.forEach(([g]) => {
      const px = R * Math.cos(g), py = R * Math.sin(g);
      ctx.beginPath();
      ctx.arc(px, py, 5, 0, 2 * PI);
      ctx.fillStyle = K.c;
      ctx.fill();
      ctx.strokeStyle = K.bg;
      ctx.stroke();
    });
    ctx.restore();

    if (state.showAnn) {
      P.forEach(([g]) => {
        drawMeshDot(rs * Math.cos(g), rs * Math.sin(g), true);
        drawMeshDot(rr * Math.cos(g), rr * Math.sin(g), true);
      });
    }

    const rimOuter = rr + 1.15 * ((2 * rr) / zr) + 15;
    if (Math.abs(wr) < 0.005) {
      drawFix(0, rimOuter, 1.1);
      drawFix(-rimOuter * 0.86, -rimOuter * 0.5, 0.9);
      drawFix(rimOuter * 0.86, -rimOuter * 0.5, 0.9);
      drawLabel("Corona r bloccata a telaio (ω_r = 0)", 0, rimOuter + 26 / s, K.d);
    } else if (Math.abs(wc) < 0.005) {
      P.forEach(([g]) => drawFix(R * Math.cos(g), R * Math.sin(g), 0.95));
      drawLabel("Portasatelliti c bloccato a telaio (ω_c = 0)", 0, rimOuter + 24 / s, K.c);
    } else if (Math.abs(ws) < 0.005) {
      drawFix(0, 0, 1.15);
      drawLabel("Solare s bloccato a telaio (ω_s = 0)", 0, rimOuter + 24 / s, K.a);
    }
    ctx.restore();
  }

  // 6. HARMONIC DRIVE (WG, FS, CS)
  function drawHarmonic(state, model) {
    const { zfs, zcs, wwg, wfs, wcs } = model.extra;
    const Rc = 124;
    const mMod = (2 * Rc) / zcs;
    const Rf = (zfs * mMod) / 2;
    const delta = Rc - Rf;
    const T = state.T;
    const twg = wwg * T, tfs = wfs * T, tcs = wcs * T;
    const s = view(-Rc - 34, Rc + 34, Rc + 42);
    const lw = ctx.lineWidth;

    // 1) Circular Spline (id=2)
    drawGear(0, 0, Rc, zcs, tcs + PI / zcs, K.d, true, 2, wcs, state);

    const rFlex = ang => Rf + delta * Math.cos(2 * (ang - twg));

    // 2) Wave Generator (id=0): cuscinetto a sfere + camma ellittica + hollow shaft
    pushHit(0, 0, 0, Rf - 16, false);
    ctx.save();
    const isHwg = state.hov === 0;
    const wallT = 8.5, ballR = 4.2, camGap = wallT + ballR * 2 + 1.5;

    const nBalls = 22;
    for (let k = 0; k < nBalls; k++) {
      const ba = (twg + tfs) * 0.5 + (k * 2 * PI) / nBalls;
      const br = rFlex(ba) - wallT - ballR - 0.8;
      ctx.beginPath();
      ctx.arc(br * Math.cos(ba), br * Math.sin(ba), ballR, 0, 2 * PI);
      ctx.fillStyle = K.bg;
      ctx.fill();
      ctx.lineWidth = lw * 0.95;
      ctx.strokeStyle = K.mut;
      ctx.stroke();
    }

    ctx.beginPath();
    for (let i = 0; i <= 120; i++) {
      const u = (i / 120) * 2 * PI;
      const ru = rFlex(u) - camGap;
      i ? ctx.lineTo(ru * Math.cos(u), ru * Math.sin(u)) : ctx.moveTo(ru * Math.cos(u), ru * Math.sin(u));
    }
    ctx.closePath();
    ctx.fillStyle = K.bg;
    ctx.fill();
    ctx.globalAlpha = isHwg ? 0.45 : 0.25;
    ctx.fillStyle = K.a;
    ctx.fill();
    ctx.globalAlpha = 1;
    ctx.lineWidth = isHwg ? lw * 1.9 : lw * 1.3;
    ctx.strokeStyle = K.a;
    ctx.stroke();

    // Asse maggiore del Wave Generator
    const rMaj = Rf + delta - camGap - 3;
    ctx.beginPath();
    ctx.moveTo(-rMaj * Math.cos(twg), -rMaj * Math.sin(twg));
    ctx.lineTo(rMaj * Math.cos(twg), rMaj * Math.sin(twg));
    ctx.lineWidth = lw * 2;
    ctx.strokeStyle = K.a;
    ctx.stroke();
    [-1, 1].forEach(sg => {
      ctx.beginPath();
      ctx.arc(sg * rMaj * Math.cos(twg), sg * rMaj * Math.sin(twg), 3.2, 0, 2 * PI);
      ctx.fillStyle = K.a;
      ctx.fill();
    });

    // Hollow shaft centrale (albero cavo passante)
    ctx.beginPath();
    ctx.arc(0, 0, 14, 0, 2 * PI);
    ctx.fillStyle = K.bg;
    ctx.fill();
    ctx.strokeStyle = K.a;
    ctx.stroke();
    ctx.restore();

    // 3) FlexSpline deformabile (id=1)
    pushHit(1, 0, 0, Rf, true);
    ctx.save();
    const isHfs = state.hov === 1;
    const p = PI / zfs;
    ctx.beginPath();
    for (let k = 0; k < zfs; k++) {
      const t = tfs + 2 * p * k;
      const pts = [
        [-1.1 * mMod, t - 0.50 * p],
        [-1.1 * mMod, t - 0.35 * p],
        [0,           t - 0.23 * p],
        [+0.9 * mMod, t - 0.12 * p],
        [+0.9 * mMod, t + 0.12 * p],
        [0,           t + 0.23 * p],
        [-1.1 * mMod, t + 0.35 * p],
        [-1.1 * mMod, t + 0.50 * p]
      ];
      pts.forEach(([dr, u], i) => {
        const rad = rFlex(u) + dr;
        const X = rad * Math.cos(u), Y = rad * Math.sin(u);
        (k || i) ? ctx.lineTo(X, Y) : ctx.moveTo(X, Y);
      });
    }
    ctx.closePath();
    for (let i = 120; i >= 0; i--) {
      const u = (i / 120) * 2 * PI;
      const ru = rFlex(u) - wallT;
      i === 120 ? ctx.moveTo(ru * Math.cos(u), ru * Math.sin(u)) : ctx.lineTo(ru * Math.cos(u), ru * Math.sin(u));
    }
    ctx.closePath();

    ctx.fillStyle = K.bg;
    ctx.fill("evenodd");
    ctx.globalAlpha = isHfs ? 0.5 : 0.32;
    ctx.fillStyle = K.b;
    ctx.fill("evenodd");
    ctx.globalAlpha = 1;
    ctx.lineWidth = isHfs ? lw * 1.8 : lw * 1.2;
    ctx.strokeStyle = K.b;
    ctx.stroke();

    // Fondello e tacca di fase della FlexSpline
    const cupR = Rf * 0.54;
    ctx.save();
    ctx.setLineDash([4 / s, 3 / s]);
    ctx.strokeStyle = K.b;
    ctx.lineWidth = lw * 1.2;
    ctx.beginPath();
    ctx.arc(0, 0, cupR, 0, 2 * PI);
    ctx.stroke();
    ctx.restore();

    const r0 = rFlex(tfs);
    ctx.beginPath();
    ctx.moveTo(cupR * Math.cos(tfs), cupR * Math.sin(tfs));
    ctx.lineTo((r0 - 2) * Math.cos(tfs), (r0 - 2) * Math.sin(tfs));
    ctx.lineWidth = lw * 2.6;
    ctx.strokeStyle = K.b;
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(cupR * Math.cos(tfs), cupR * Math.sin(tfs), 4, 0, 2 * PI);
    ctx.fillStyle = K.b;
    ctx.fill();

    for (let k = 1; k < 4; k++) {
      const ang = tfs + (k * PI) / 2;
      const rk = rFlex(ang) - wallT;
      ctx.beginPath();
      ctx.moveTo(cupR * Math.cos(ang), cupR * Math.sin(ang));
      ctx.lineTo(rk * Math.cos(ang), rk * Math.sin(ang));
      ctx.lineWidth = lw * 1.1;
      ctx.globalAlpha = 0.55;
      ctx.strokeStyle = K.b;
      ctx.stroke();
    }
    ctx.globalAlpha = 1;

    if (state.showAnn) {
      ctx.save();
      ctx.setLineDash([4 / s, 3.5 / s]);
      ctx.strokeStyle = K.b;
      ctx.lineWidth = lw * 0.95;
      ctx.globalAlpha = 0.65;
      ctx.beginPath();
      for (let i = 0; i <= 120; i++) {
        const u = (i / 120) * 2 * PI;
        const ru = rFlex(u);
        i ? ctx.lineTo(ru * Math.cos(u), ru * Math.sin(u)) : ctx.moveTo(ru * Math.cos(u), ru * Math.sin(u));
      }
      ctx.closePath();
      ctx.stroke();

      // Zone di ingranamento attivo (~30% dei denti sull'asse maggiore)
      [twg, twg + PI].forEach(ang => {
        ctx.beginPath();
        ctx.arc(0, 0, Rc, ang - 0.28, ang + 0.28);
        ctx.strokeStyle = K.hi;
        ctx.lineWidth = lw * 2.6;
        ctx.setLineDash([]);
        ctx.globalAlpha = 0.85;
        ctx.stroke();
        drawMeshDot(Rc * Math.cos(ang), Rc * Math.sin(ang), true);
      });
      ctx.restore();
    }
    ctx.restore();

    const rimOuter = Rc + 1.15 * mMod + 15;
    if (state.hdMode === "cs") {
      drawFix(0, rimOuter, 1.1);
      drawFix(-rimOuter * 0.86, -rimOuter * 0.5, 0.9);
      drawFix(rimOuter * 0.86, -rimOuter * 0.5, 0.9);
      drawLabel(`CS fissa (z_CS=${zcs}) · FS cedente (z_FS=${zfs})`, 0, rimOuter + 26 / s, K.d);
    } else {
      drawFix(0, cupR, 1.05);
      drawLabel(`FS fissa (z_FS=${zfs}) · CS cedente (z_CS=${zcs})`, 0, rimOuter + 24 / s, K.b);
    }
    ctx.restore();

    // Contatore giri WG e denti scalati in alto a destra sotto al badge
    const turnsWG = twg / (2 * PI);
    const shiftedTeeth = state.hdMode === "cs" ? -2 * turnsWG : 2 * turnsWG;
    ctx.save();
    ctx.fillStyle = K.mut;
    ctx.font = '600 11px "IBM Plex Mono", monospace';
    ctx.textAlign = "right";
    ctx.fillText(`Giri WG: ${turnsWG.toFixed(2)} · Δdenti: ${shiftedTeeth >= 0 ? "+" : ""}${shiftedTeeth.toFixed(2)}`, W - 16, 56);
    ctx.restore();
  }

  function render(state, model) {
    refreshColors();
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, W, H);
    ctx.lineJoin = "round";
    ctx.lineCap = "round";
    HIT = [];

    const drawMap = {
      planar: drawPlanar,
      rack: drawRack,
      compound: drawCompound,
      spherical: drawSpherical,
      planetary: drawPlanetary,
      harmonic: drawHarmonic
    };
    drawMap[model.tabId](state, model);
  }

  function hitTest(clientX, clientY) {
    const rect = canvas.getBoundingClientRect();
    const X = ((clientX - rect.left) / rect.width) * W;
    const Y = ((clientY - rect.top) / rect.height) * H;
    let best = null;
    HIT.forEach(g => {
      const d = Math.hypot(X - g.x, Y - g.y);
      const ok = g.inn ? d > g.r * 0.82 && d < g.r * 1.22 : d < g.r * 1.08;
      if (ok && (!best || g.r < best.r)) best = g;
    });
    return best ? best.id : -1;
  }

  return { render, hitTest, resize, W };
}
