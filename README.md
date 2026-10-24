# GalaxyOS

Protótipo e base de projeto para um **channel Roku** que funciona como ambiente de entretenimento próprio — launcher, games, web hub e connect — começando pela tela inicial.

Este repo reúne as quatro peças do plano:

1. **`prototype/`** — a versão teste web da Home (v0.3), navegável por setas como um controle real, bilíngue PT/EN, estática (HTML/CSS/JS puro, sem build). Também serve o **feed do canal** (`prototype/feeds/modules.json`).
2. **`roku/`** — **Fase 1: o channel de verdade** em BrightScript + SceneGraph (Home Deep Space, feed do Hub v0, PT/EN, rungs 1 e 3 verificados).
3. **`skills/`** — as 4 skills do autor (projects · design · security · theskill/craftsmanship) **adaptadas para a área Roku**, que passam a guiar o desenvolvimento do channel.
4. **`docs/` + `brain/`** — a pesquisa verificada nas fontes oficiais da Roku e a memória do projeto (decisões ADR, device-info, tasks).

---

## O protótipo (v0.3 — Só Home)

Visual **escuro "Deep Space"** — fundo padrão **Nebulosa** (nebulosas em movimento + ~210 estrelas cintilando em canvas + estrela cadente ocasional), variantes **Aurora** e **Limpo**, e o tema **claro minimal estilo Google TV** (v0.1) preservado — tudo em **Configurações → Aparência** · palco fixo **1920×1080** com moldura de TV · **foco = cursor** (setas navegam, Enter = OK, Backspace/Esc = Voltar) · relógio ao vivo com data por locale · **card de rede compacto** (nome + status; sinal/IP/latência num submenu que abre com OK) · 8 atalhos · 4 módulos (Jogos, Web Hub e Connect como "Em breve"; Configurações funcional) · **Configurações em drawer lateral** (desliza da direita, Home continua visível; fecha com ✕, Back ou clique fora) · **controle na tela** (D-pad clicável, para testar no celular) · idioma, tema e fundo persistidos em `localStorage` · `prefers-reduced-motion` respeitado (estrelas fixas, sem estrela cadente).

### Testar agora

- **🚀 Ao vivo no GitHub Pages**: **https://lucasgabrieldevgg.github.io/galaxyos/**
- **Repo**: https://github.com/lucasgabrieldevgg/galaxyos
- **Direto do disco**: abra `prototype/index.html` em qualquer navegador.
- **Servindo** (recomendado, fontes via Google Fonts): `cd prototype && python3 -m http.server 8901` → `http://localhost:8901`.

### Deploy

O workflow incluído (`.github/workflows/pages.yml`) publica a pasta `prototype/` no **GitHub Pages** automaticamente:

1. Crie um repo (ex.: `galaxyos`) e suba o conteúdo desta pasta.
2. No GitHub: **Settings → Pages → Source: GitHub Actions**.
3. A cada push na `main`, o protótipo entra no ar em `https://SEU-USUARIO.github.io/galaxyos/`.

**Vercel** (alternativa igualmente gratuita): importe o repo, defina **Root Directory = `prototype`** — pronto, sem build. Plano **Hobby** verificado em 24/10/2026 na página oficial de preços: **$0/mês** para uso pessoal/não-comercial, **100 GB de tráfego/mês**, 1M de requests, domínio próprio suportado. O GitHub Pages segue como padrão por dispensar qualquer configuração; nota para o futuro: **WebSocket persistente (Connect) não roda** no serverless da Vercel — nessa fase, avaliar Render/Railway/Fly ou um VPS.

---

## Fase 1 — o canal Roku (novo)

O **channel em BrightScript + SceneGraph** que recria a Home Deep Space na TV, com a pesquisa dos últimos dias aplicada (tamanhos de arte medidos no sample oficial, safe zones FHD, protocolo `onKeyEvent`, Task + `roUrlTransfer` fora do render thread):

- **Home Deep Space**: fundo nebulosa (mesma paleta do protótipo), saudação por hora, relógio (24h PT / 12h EN), card de rede, **rail de 4 módulos** com foco em ring ciano + escala, painel de detalhe e hintbar — tudo ≥ 24px e dentro do action-safe.
- **Feed do “Hub v0”**: o canal busca `feeds/modules.json` aqui do Pages, **valida tudo** (whitelist de ids, limites de tamanho, tipos — fail-closed) e cai num **fallback offline** embutido se a rede falhar.
- **Idioma PT/EN** trocado com a tecla `*` (options) e persistido no registro da TV.
- **Verificação**: rung 1 (`bsc` compila com zero erros) e rung 3-lite (contrato do feed: 16/16 fixtures hostis) — **rung 4/5 (smoke na AOC 43S5155) é o próximo passo**, guia completo em `docs/fase1-tv.md`.

```bash
cd roku
npm install          # brighterscript 0.73.8 + roku-deploy 3.18.4 (pinados)
npm run compile      # bsc — zero erros
npm test             # contrato do feed (16 fixtures + JSON publicado)
cd src && zip -r ../galaxyos-channel.zip manifest source components images   # zip de sideload
```

Zip pronto pra sideload: **`galaxyos-roku-channel-v0.1.zip`** (228 KB, muito abaixo do orçamento de package).

---

## As skills adaptadas para Roku

| Skill original | Versão Roku | O que mudou de fato |
| --- | --- | --- |
| `projects` | `skills/roku-projects` | Intake com as perguntas de Roku (sideload vs Store, tier do device, 512 MB); stack boring padrão (BrightScript + SceneGraph + BrighterScript); **smoke test na TV de verdade** (compila → sideload → abre → logs limpos no `telnet :8085`); `brain/device-info.md` como memória do hardware; gate de certificação |
| `design` | `skills/roku-design` | Contract para **10-foot UI**: foco é o cursor, mínimo 24 px a 1080p, bans de TV (hover, grid denso, contraste de monitor, overscan), famílias de macroestrutura de TV, gates de 7 eixos recalibrados e o **sofa test** como asserção final |
| `security` | `skills/roku-security` | Triângulo de confiança (channel–Hub–companion); top 10 do ecossistema (Hub como proxy aberto/SSRF, pairing fraco, segredos no package extraível, feed como input hostil); regra dura: **o channel nunca emite ECP** (Static Analysis bloqueia a publicação) |
| `theskill/craftsmanship` | `skills/roku-craft` | Escada de verificação no lugar do TDD puro (compila → unit → contrato do feed → smoke na TV → sessão adversarial no sofá); taxonomia de slop BrightScript (observer rot, thread abuse, focus after async...); checklist de review SceneGraph e orçamento de memória |

Para usar como skills num agente (Claude Code, GLM, Cursor): copie cada pasta `skills/roku-*` para o diretório de skills do seu host. Elas também funcionam como convenção escrita do repo — os gates e contratos valem mesmo lidas direto.

---

## Pesquisa verificada (docs/research-roku.md)

O que a pesquisa nas fontes oficiais já travou de decisão:

- **RSG 2.0 (TypeScript, MIT) é real** — beta público **29/10/2026**, mas apps RSG 2.0 ainda não podem ir pra Store. Decisão: começar em BrightScript + SceneGraph e avaliar o beta em 5 dias antes de qualquer aposta.
- **Publicar é grátis** (conta dev gratuita); certificação exige testes em múltiplos devices, APIs não-deprecadas e os assets de Store.
- **ECP mudou**: apps **não podem emitir ECP** de dentro do channel (bloqueio automático de publicação) → o celular-controle do Connect vai pelo **Hub** (WebSocket + pairing), nunca por ECP interno.
- Sem WebView no SDK → **Web Hub por adaptadores** (JSON → UI nativa), o modelo Netflix/Twitch.
- Package fechado → Games com **jogos como dados** (manifests JSON interpretados por motor genérico).

## Roadmap

- **Fase 1** — ✅ scaffold do channel (Home, feed Hub v0, PT/EN) · ⬜ smoke na TV: **`docs/fase1-tv.md`**.
- **Fase 2** — GalaxyOS Hub: API mínima (Vercel) + módulo Jogos (RowList virtualizado, jogos como dados).
- **Fase 3** — Web Hub: adaptadores JSON → UI nativa.
- **Fase 4** — Connect: pairing pelo Hub (WebSocket — host dedicado), companion **Linux Mint XFCE** (systemd + Chromium headless).
- **29/10/2026** — avaliar o beta do **RSG 2.0** (fila #1 do research).

## Estrutura

```
galaxyos/
├── .github/workflows/pages.yml   # deploy do protótipo + feeds no GitHub Pages
├── prototype/                    # versão teste web (sem build) + feeds/
│   ├── index.html
│   ├── css/style.css
│   ├── js/app.js
│   └── feeds/modules.json         # feed do canal (Hub v0)
├── roku/                          # Fase 1 — o channel de verdade
│   ├── src/
│   │   ├── manifest               # ui_resolutions=fhd, artes oficiais
│   │   ├── source/                # Main.brs · config.brs · feed-validate.brs
│   │   ├── components/            # HomeScene · ModuleTile · FeedTask
│   │   └── images/                 # nebulosa, splashs e posters (specs medidas)
│   ├── tests/feed-contract.js     # contrato do feed (fixtures hostis)
│   ├── package.json · bsconfig.json
├── brain/                         # memória: context · device-info · tasks · decisions/
├── skills/                         # roku-projects · roku-design · roku-security · roku-craft
└── docs/
    ├── research-roku.md           # fatos verificados + fila (agora com §8 Fase 1)
    ├── research/fase1-notes.md    # notas da coleta (eixos + ledger)
    ├── fase1-tv.md                # guia de sideload e smoke na AOC 43S5155
    └── screenshots/                # estados validados do protótipo
```
