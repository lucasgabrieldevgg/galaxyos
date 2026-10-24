/* ═══════════════════════════════════════════════════════════════
   GalaxyOS — Home prototype · engine
   Escala do palco 1920×1080 · navegação espacial por setas
   (o foco é o cursor) · i18n PT/EN · relógio ao vivo · controle
   na tela para uso no celular.
   ═══════════════════════════════════════════════════════════════ */

'use strict';

/* ───────────────────────── i18n ───────────────────────── */

const I18N = {
  pt: {
    versionChip: 'v0.3 · protótipo web',
    greetingMorning: 'Bom dia,', greetingAfternoon: 'Boa tarde,', greetingEvening: 'Boa noite,',
    netTitle: 'Rede', netStatus: 'Conectado · Internet OK',
    netSignal: 'Sinal', netSignalValue: 'Excelente',
    netIp: 'Endereço IP', netPing: 'Latência',
    netMore: 'OK · detalhes',
    shortcuts: 'Atalhos', modules: 'GalaxyOS',
    modGames: 'Jogos', modGamesDesc: 'Biblioteca, minigames e recordes.',
    modWebDesc: 'Conteúdo e serviços via GalaxyOS Hub.',
    modConnectDesc: 'PC na TV, celular no controle.',
    modSettings: 'Configurações', modSettingsDesc: 'Idioma, aparência e informações.',
    badgeSoon: 'Em breve', badgeNow: 'v0.3',
    hintNav: 'Navegar', hintOk: 'OK', hintBack: 'Voltar',
    remoteToggle: 'Controle na tela', remoteTitle: 'Controle',
    settings: 'Configurações', settingsLang: 'Idioma',
    settingsAppearance: 'Aparência', settingsTheme: 'Tema', settingsWall: 'Fundo de tela',
    themeDark: 'Escuro', themeLight: 'Claro',
    wallNebula: 'Nebulosa', wallAurora: 'Aurora', wallClean: 'Limpo',
    toastTheme: { dark: 'Tema: Escuro', light: 'Tema: Claro' },
    toastWall: { nebula: 'Fundo: Nebulosa', aurora: 'Fundo: Aurora', clean: 'Fundo: Limpo' },
    settingsKeys: 'Atalhos do teclado', settingsAbout: 'Sobre',
    langPt: 'Português (BR)', langEn: 'English',
    keyNav: 'mover o foco', keyOk: 'abrir / selecionar', keyBack: 'voltar / fechar',
    aboutText: 'Protótipo estático da tela inicial do GalaxyOS para Roku TV. A versão real será um channel em BrightScript + SceneGraph, alimentado pelo GalaxyOS Hub (API + conteúdo), com módulos Jogos, Web Hub e Connect.',
    toastHome: 'Você já está na Home',
    toastApp: (name) => `“${name}” abre no channel GalaxyOS real.`,
    toastModule: { games: 'Módulo Jogos — planejado para a próxima fase.',
                   web: 'Módulo Web Hub — planejado para a próxima fase.',
                   connect: 'Módulo Connect — planejado para a próxima fase.' },
    toastLang: 'Idioma: Português',
    locale: 'pt-BR'
  },
  en: {
    versionChip: 'v0.3 · web prototype',
    greetingMorning: 'Good morning,', greetingAfternoon: 'Good afternoon,', greetingEvening: 'Good evening,',
    netTitle: 'Network', netStatus: 'Connected · Internet OK',
    netSignal: 'Signal', netSignalValue: 'Excellent',
    netIp: 'IP address', netPing: 'Latency',
    netMore: 'OK · details',
    shortcuts: 'Shortcuts', modules: 'GalaxyOS',
    modGames: 'Games', modGamesDesc: 'Library, mini-games and high scores.',
    modWebDesc: 'Content and services via the GalaxyOS Hub.',
    modConnectDesc: 'PC on the TV, phone as the remote.',
    modSettings: 'Settings', modSettingsDesc: 'Language, appearance and info.',
    badgeSoon: 'Coming soon', badgeNow: 'v0.3',
    hintNav: 'Navigate', hintOk: 'OK', hintBack: 'Back',
    remoteToggle: 'On-screen remote', remoteTitle: 'Remote',
    settings: 'Settings', settingsLang: 'Language',
    settingsAppearance: 'Appearance', settingsTheme: 'Theme', settingsWall: 'Background',
    themeDark: 'Dark', themeLight: 'Light',
    wallNebula: 'Nebula', wallAurora: 'Aurora', wallClean: 'Clean',
    toastTheme: { dark: 'Theme: Dark', light: 'Theme: Light' },
    toastWall: { nebula: 'Background: Nebula', aurora: 'Background: Aurora', clean: 'Background: Clean' },
    settingsKeys: 'Keyboard shortcuts', settingsAbout: 'About',
    langPt: 'Português (BR)', langEn: 'English',
    keyNav: 'move the focus', keyOk: 'open / select', keyBack: 'back / close',
    aboutText: 'Static prototype of the GalaxyOS home screen for Roku TV. The real version will be a BrightScript + SceneGraph channel, fed by the GalaxyOS Hub (API + content), with Games, Web Hub and Connect modules.',
    toastHome: 'You are already on Home',
    toastApp: (name) => `“${name}” opens in the real GalaxyOS channel.`,
    toastModule: { games: 'Games module — planned for the next phase.',
                   web: 'Web Hub module — planned for the next phase.',
                   connect: 'Connect module — planned for the next phase.' },
    toastLang: 'Language: English',
    locale: 'en-US'
  }
};

const state = {
  lang:  localStorage.getItem('galaxyos.lang')  || 'pt',
  theme: localStorage.getItem('galaxyos.theme') || 'dark',
  wall:  localStorage.getItem('galaxyos.wall')  || 'nebula'
};
const t = (key) => I18N[state.lang][key];

/* ───────────────────────── util ───────────────────────── */

const $  = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

const stage        = $('#stage');
const remote       = $('#remote');
const overlay      = $('#overlaySettings');
const toastEl      = $('#toast');
const netcard      = $('#netcard');
const netPop       = $('#netDetails');
const heroEl       = $('.hero');
let toastTimer = null;

function toast(msg) {
  toastEl.hidden = false;
  toastEl.textContent = msg;
  requestAnimationFrame(() => toastEl.classList.add('show'));
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    toastEl.classList.remove('show');
    setTimeout(() => { toastEl.hidden = true; }, 220);
  }, 2400);
}

/* ─────────────────── palco: escala 1920×1080 ─────────────────── */

function fitStage() {
  /* o bezel inteiro (stage + moldura) é escalado e centralizado via
     translate(-50%,-50%) — o tamanho de layout não cabe no viewport,
     por isso a centralização nunca passa por flex/flow */
  const s = Math.min(window.innerWidth / 1980, window.innerHeight / 1160);
  document.querySelector('.bezel').style.transform =
    `translate(-50%, -50%) scale(${s})`;
}
window.addEventListener('resize', fitStage);

/* ───────────────────── foco = cursor ───────────────────── */

function focusables() {
  return $$('[data-focusable]').filter(el =>
    !el.closest('[hidden]') && el.getClientRects().length > 0);
}

function setFocus(el, silent) {
  $$('.focused').forEach(n => n.classList.remove('focused'));
  if (!el) return;
  el.classList.add('focused');
  el.focus({ preventScroll: true });
  if (el !== netcard) closeNetcard();   /* submenu de rede fecha ao sair do card */
  if (!silent) blip(el);
}

/* pequeno “tick” visual ao mover o foco — feedback funcional, não decoração */
function blip(el) {
  el.style.transition = 'none';
  requestAnimationFrame(() => { el.style.transition = ''; });
}

function center(el) {
  const r = el.getBoundingClientRect();
  return { x: r.left + r.width / 2, y: r.top + r.height / 2 };
}

function moveFocus(dir) {
  const items = focusables();
  const cur = $('.focused');
  if (!cur) { setFocus(items[0]); return; }

  const c = center(cur);
  const horizontal = (dir === 'left' || dir === 'right');
  const wantSign = (dir === 'left' || dir === 'up') ? -1 : 1;

  let best = null, bestScore = Infinity;

  for (const el of items) {
    if (el === cur) continue;
    const p = center(el);
    const dx = p.x - c.x, dy = p.y - c.y;
    const primary = horizontal ? dx : dy;
    if (Math.sign(primary) !== wantSign || Math.abs(primary) < 2) continue;

    const perp = horizontal ? dy : dx;
    /* tolera desvio de meia altura do alvo antes de descartar */
    const perpLimit = 260;
    if (Math.abs(perp) > perpLimit) continue;

    const score = Math.abs(primary) + Math.abs(perp) * 2.2;
    if (score < bestScore) { bestScore = score; best = el; }
  }

  if (best) { setFocus(best); return; }

  /* wrap horizontal dentro do mesmo rail — comportamento de TV */
  if (horizontal) {
    const rail = cur.closest('.rail');
    if (rail) {
      const siblings = $$('.tile, .module, .seg-btn, .chip-btn', rail).filter(el =>
        items.includes(el));
      if (siblings.length > 1) {
        const i = siblings.indexOf(cur);
        const next = dir === 'left'
          ? siblings[(i - 1 + siblings.length) % siblings.length]
          : siblings[(i + 1) % siblings.length];
        if (next && next !== cur) { setFocus(next); return; }
      }
    }
  }
}

/* ─────────────────── ações dos elementos ─────────────────── */

function activate(el) {
  if (!el) return;

  if (el.id === 'netcard')  { toggleNetcard(); return; }

  if (el.dataset.app)     { toast(t('toastApp')(el.dataset.app)); return; }

  if (el.dataset.module) {
    const m = el.dataset.module;
    if (m === 'settings') { openSettings(); return; }
    toast(t('toastModule')[m]);
    return;
  }

  if (el.id === 'langChip')  { toggleLang(); return; }
  if (el.id === 'remoteToggle') { showRemote(true); return; }
  if (el.id === 'remoteClose')  { showRemote(false); return; }
  if (el.id === 'settingsClose'){ closeSettings(); return; }

  if (el.dataset.theme) {
    if (state.theme !== el.dataset.theme) setTheme(el.dataset.theme);
    return;
  }

  if (el.dataset.wall) {
    if (state.wall !== el.dataset.wall) setWall(el.dataset.wall);
    return;
  }

  if (el.dataset.lang) {
    if (state.lang !== el.dataset.lang) setLang(el.dataset.lang);
    return;
  }
}

/* ─────────────────── overlays: remote / settings ─────────────────── */

let beforeOverlayFocus = null;

function showRemote(on) {
  remote.hidden = !on;
  if (on) setFocus($('#remoteClose'));
}

function openSettings() {
  beforeOverlayFocus = $('.focused');
  overlay.hidden = false;
  syncSegmented();
  setFocus(state.theme === 'dark' ? $('#segThemeDark') : $('#segThemeLight'));
}

function closeSettings() {
  overlay.hidden = true;
  setFocus(beforeOverlayFocus || $('#railShortcuts .tile'));
}

/* ── card de rede: detalhes num submenu (popover de vidro) ── */

function toggleNetcard(force) {
  const open = (force === undefined) ? netPop.hidden : force;
  netPop.hidden = !open;
  netcard.setAttribute('aria-expanded', open);
  heroEl.classList.toggle('pop-open', open);
}

function closeNetcard() {
  if (!netPop.hidden) toggleNetcard(false);
}

function back() {
  if (!remote.hidden)    { showRemote(false);  setFocus($('#remoteToggle')); return; }
  if (!overlay.hidden)   { closeSettings(); return; }
  if (!netPop.hidden)    { closeNetcard(); return; }
  toast(t('toastHome'));
}

/* ───────────────────── idioma ───────────────────── */

function applyLang() {
  document.documentElement.lang = (state.lang === 'pt') ? 'pt-BR' : 'en';
  $$('[data-i18n]').forEach(el => {
    const v = I18N[state.lang][el.dataset.i18n];
    if (typeof v === 'string') el.textContent = v;
  });
  $('#langChipLabel').textContent = state.lang.toUpperCase();
  syncSegmented();
  renderClock();
}

function setLang(lang) {
  state.lang = lang;
  localStorage.setItem('galaxyos.lang', lang);
  applyLang();
  toast(t('toastLang'));
}

function toggleLang() { setLang(state.lang === 'pt' ? 'en' : 'pt'); }

function syncSegmented() {
  $('#segPt').classList.toggle('active', state.lang === 'pt');
  $('#segEn').classList.toggle('active', state.lang === 'en');
  $$('[data-theme].seg-btn').forEach(b =>
    b.classList.toggle('active', b.dataset.theme === state.theme));
  $$('[data-wall].seg-btn').forEach(b =>
    b.classList.toggle('active', b.dataset.wall === state.wall));
}

/* ───────────────────── aparência: tema + fundo ───────────────────── */

function applyAppearance() {
  document.documentElement.dataset.theme = state.theme;
  document.documentElement.dataset.wall  = state.wall;
  syncSegmented();
}

function setTheme(theme) {
  state.theme = theme;
  localStorage.setItem('galaxyos.theme', theme);
  applyAppearance();
  toast(t('toastTheme')[theme]);
}

function setWall(wall) {
  state.wall = wall;
  localStorage.setItem('galaxyos.wall', wall);
  applyAppearance();
  toast(t('toastWall')[wall]);
}

/* ───────────────────── relógio ───────────────────── */

function renderClock() {
  const now = new Date();
  const loc = t('locale');

  const time = new Intl.DateTimeFormat(loc, {
    hour: '2-digit', minute: '2-digit', hour12: (state.lang === 'en')
  }).format(now).replace(/\u202f/g, ' ');

  const sec = new Intl.DateTimeFormat(loc, {
    second: '2-digit', hour12: false
  }).format(now);

  const date = new Intl.DateTimeFormat(loc, {
    weekday: 'long', day: 'numeric', month: 'long'
  }).format(now);

  $('#clockTime').textContent = time;
  $('#clockSec').textContent = sec;
  $('#clockDate').textContent = date.charAt(0).toUpperCase() + date.slice(1);

  const h = now.getHours();
  const g = h < 12 ? 'greetingMorning' : h < 18 ? 'greetingAfternoon' : 'greetingEvening';
  $('#greeting').textContent = t(g);
}

/* ─────────────── wallpaper: campo de estrelas (canvas) ─────────────── */

const starsCanvas = $('#wpStars');
const sctx = starsCanvas.getContext('2d');
const REDUCED_MOTION = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* paleta: branco-gelo dominante, toques azul-frio e âmbar */
const STAR_TINTS = [
  'rgba(233,241,255,', 'rgba(233,241,255,', 'rgba(233,241,255,',
  'rgba(169,205,255,', 'rgba(255,233,197,'
];
const stars = [];
for (let i = 0; i < 210; i++) {
  stars.push({
    x: Math.random() * 1920,
    y: Math.random() * 1080,
    r: 0.5 + Math.random() * 1.7,
    base: 0.16 + Math.random() * 0.62,
    amp: 0.12 + Math.random() * 0.38,
    sp: 0.35 + Math.random() * 1.25,
    ph: Math.random() * Math.PI * 2,
    tint: STAR_TINTS[(Math.random() * STAR_TINTS.length) | 0]
  });
}

/* estrela cadente: um risco de luz cruzando o céu de vez em quando */
let shoot = null;
let nextShootAt = performance.now() + 7000 + Math.random() * 8000;

function spawnShoot() {
  const angle = Math.PI * (0.78 + Math.random() * 0.08); /* descendo à esquerda */
  const speed = 1250 + Math.random() * 250;
  shoot = {
    x: 1150 + Math.random() * 770,
    y: -50 + Math.random() * 230,
    vx: Math.cos(angle) * speed,
    vy: Math.sin(angle) * speed,
    life: 0, maxLife: 0.95
  };
}

function drawShootingStar(dt) {
  shoot.life += dt;
  const k = 1 - shoot.life / shoot.maxLife;
  if (k <= 0 || shoot.x < -300 || shoot.y > 1380) {
    shoot = null;
    nextShootAt = performance.now() + 14000 + Math.random() * 22000;
    return;
  }
  const len = Math.hypot(shoot.vx, shoot.vy);
  const nx = shoot.vx / len, ny = shoot.vy / len;
  const tail = 150;
  const grad = sctx.createLinearGradient(shoot.x, shoot.y, shoot.x - nx * tail, shoot.y - ny * tail);
  grad.addColorStop(0, 'rgba(255,255,255,' + (0.95 * k).toFixed(3) + ')');
  grad.addColorStop(1, 'rgba(255,255,255,0)');
  sctx.strokeStyle = grad;
  sctx.lineWidth = 2.4;
  sctx.lineCap = 'round';
  sctx.beginPath();
  sctx.moveTo(shoot.x, shoot.y);
  sctx.lineTo(shoot.x - nx * tail, shoot.y - ny * tail);
  sctx.stroke();
  shoot.x += shoot.vx * dt;
  shoot.y += shoot.vy * dt;
}

let lastFrame = 0;
function starsLoop(now) {
  const dt = Math.min(0.05, (now - lastFrame) / 1000 || 0.016);
  lastFrame = now;

  sctx.clearRect(0, 0, 1920, 1080);
  const on = state.theme === 'dark' && state.wall !== 'clean';
  if (on) {
    const tt = now / 1000;
    for (const s of stars) {
      const a = REDUCED_MOTION ? s.base
             : Math.max(0, s.base + s.amp * Math.sin(tt * s.sp + s.ph));
      if (a < 0.02) continue;
      sctx.fillStyle = s.tint + a.toFixed(3) + ')';
      sctx.beginPath();
      sctx.arc(s.x, s.y, s.r, 0, 6.2832);
      sctx.fill();
    }
    if (!REDUCED_MOTION) {
      if (!shoot && now >= nextShootAt) spawnShoot();
      if (shoot) drawShootingStar(dt);
    }
  }
  requestAnimationFrame(starsLoop);
}
requestAnimationFrame(starsLoop);

/* ───────────────────── input global ───────────────────── */

const KEYMAP = {
  ArrowUp: 'up', ArrowDown: 'down', ArrowLeft: 'left', ArrowRight: 'right'
};

document.addEventListener('keydown', (e) => {
  if (KEYMAP[e.key]) { e.preventDefault(); moveFocus(KEYMAP[e.key]); return; }

  if (e.key === 'Enter' || e.key === ' ') {
    /* Enter num botão nativo dispara click — evita duplicar;
       elementos com data-activate (card de rede) ativam aqui */
    if (e.key === ' ') e.preventDefault();
    const el = $('.focused');
    if (!el) return;
    if (el.matches('button') || el.hasAttribute('data-activate')) {
      e.preventDefault();
      activate(el);
    }
    return;
  }

  if (e.key === 'Escape' || e.key === 'Backspace') {
    e.preventDefault(); back();
  }
});

/* cliques também focam e ativam (mouse / toque) */
document.addEventListener('click', (e) => {
  const el = e.target.closest('[data-focusable]');
  if (el) { setFocus(el, true); activate(el); }
});

/* clique no scrim do drawer também fecha as configurações */
overlay.addEventListener('click', (e) => {
  if (e.target === overlay) closeSettings();
});

/* controle na tela: mesmos eventos */
$$('.dp-btn', remote).forEach(btn =>
  btn.addEventListener('click', (e) => { e.stopPropagation(); moveFocus(btn.dataset.dir); }));
$('[data-action="ok"]', remote).addEventListener('click', (e) => {
  e.stopPropagation(); activate($('.focused')); });
$('[data-action="back"]', remote).addEventListener('click', (e) => {
  e.stopPropagation(); back(); });

/* ───────────────────── boot ───────────────────── */

applyLang();
applyAppearance();
fitStage();
setFocus($('#railShortcuts .tile'), true);
renderClock();
setInterval(renderClock, 1000);
