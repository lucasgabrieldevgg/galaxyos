# GalaxyOS — Pesquisa Roku verificada

> Data: 2026-10-24 · Método: pesquisa dirigida nas docs/blog oficial da Roku + fontes comunitárias
> Regra do projeto: **toda informação crítica é verificada antes de virar decisão.** O que não tem fonte oficial está marcado como "a verificar".

---

## 1. SDK e stack — o que usar pra construir

### Verificado (fontes oficiais)

- **BrightScript + SceneGraph** é a base documentada, atual e certificável da plataforma.
  - Fonte: developer.roku.com → Docs → SceneGraph core concepts
- **RSG 2.0 é real**: anunciado no Roku 2026 Developer Summit (23/09/2026), SDK beta público em **29/10/2026**, licença MIT open source, escrito em TypeScript, publicado no GitLab.
  - Fontes: blog.roku.com/developer/rsg-2-0-sdk-beta · forum.developer.roku.com/t/rsg-2-0-faqs/11453
  - Detalhes importantes do FAQ oficial:
    - No beta dá pra **desenvolver**, mas **ainda não dá pra mandar pra produção** — a Roku anunciará separadamente quando apps RSG 2.0 poderão ser submetidos à Store.
    - **Sem prazo de aposentadoria do BrightScript**. O Roku OS 16.0 developer beta ainda ganha novas APIs BrightScript.
    - RSG 2.0 vai ter os **mesmos requisitos de certificação** (launch rápido, playback confiável, navegação por remoto sem perder foco).
    - Não está claro ainda se BrightScript e TypeScript coexistem no mesmo projeto RSG 2.0.
- **Tooling comunitário Node**: BrighterScript (superset do BrightScript com tooling), `roku-deploy`, `ropm` (package manager), `bslint`. É a stack "boring by default" do ecossistema atual.

### Decisão recomendada (registrar como ADR-0001)

Começar o GalaxyOS channel em **BrightScript + SceneGraph + tooling BrighterScript** (caminho certificável hoje), e **avaliar o beta do RSG 2.0 no dia 29/10** — faltam 5 dias — para telas/módulos novos. Se o beta for maduro, prototipar UMA tela nele e medir o esforço antes de qualquer migração. Não reescrever nada que funciona por causa de um beta.

---

## 2. Distribuição, custos e certificação (escopo escolhido: PÚBLICO / Streaming Store)

### Verificado

- **Conta Roku Developer é grátis; publicar não custa nada.**
  - Fontes: forum.developer.roku.com/t/roku-personal-pricing-how-much-does-it-cost/10398 · tappla.com (FAQ: "The Roku Developer account is free and Roku does not charge to publish")
- **Certificação**: a Roku reserva o direito de revisar apps públicos novos e atualizados por design, performance e compliance.
  - Fonte: developer.roku.com/dev/docs/certification
  - **Usar APIs deprecadas pode reprovar na cert.**
  - **Obrigatório testar em múltiplos modelos de device** (hardware com RAM/CPU variados — o GalaxyOS alvo é um device de 512MB, mas o app público precisa performar nos outros também).
  - Ferramentas oficiais de pré-cert: **Static Analysis tool**, **App Behavior Analysis tool** (SVOD/AVOD/grátis), **test automation software**.
  - **Beta channels**: expiram em **120 dias**, máx. **20 usuários de teste** — perfeito pra distribuição de teste do GalaxyOS antes da Store.
    - Fonte: blog.roku.com/developer/beta-channels (2021)
- **Assets exigidos pra Store**: poster 540×405 JPEG/PNG; até 6 screenshots 1920×1080; descrição curta 300 chars; longa 1500 chars; nome não pode usar "Roku" nem linguagem enganosa.
  - Fonte: developer.roku.com/dev/docs/certification + channel-publishing-guide
- Monetização na plataforma: ads (dev fica com 70%), subscriptions (Roku fica com 20%), one-time.

---

## 3. Limites de desenvolvimento

| Item | Valor | Fonte | Status |
| --- | --- | --- | --- |
| Package upload (.pkg) | erro conhecido acima de ~4 MB | comunidade (2020) | ⚠️ **a verificar no primeiro upload no Dashboard** — apps grandes mantêm assets em CDN, não no package |
| Channels sideload (Developer Mode) | 1 por vez | comunidade (Reddit) | ⚠️ confirmar no device |
| Beta channel | 20 usuários, expira 120 dias | blog oficial | ✅ |
| Device alvo (AOC 43S5155/78G) | 512MB RAM, FHD 1080p 60Hz, dual-band Wi-Fi + Ethernet, 3×HDMI, 1×USB 2.0, espelhamento + AirPlay 2 | AOC | ✅ |

Implicação direta: o GalaxyOS channel precisa de **orçamento de memória apertado** — nada de motor pesado, listas virtualizadas (RowList/MarkupGrid), imagens otimizadas e servidas por CDN.

---

## 4. ECP (External Control Protocol) — MUDANÇA CRÍTICA de arquitetura

### Verificado (docs oficiais: developer.roku.com/dev/docs/external-control-api)

- ECP é REST na **porta 8060**, descoberta via SSDP em 239.255.255.250:1900.
- **Roku OS 14.1+**: keypress/keydown/keyup exigem `Settings > System > Advanced system settings > Control by mobile apps = Enabled`.
- **Apps NÃO podem mais enviar comandos ECP de dentro do próprio app.** O Static Analysis foi atualizado pra **bloquear automaticamente a publicação** de apps com código que emite ECP. Apps ainda podem *receber* ECP do SO (deep links, voice).
- ECP "não deve ser enviado de plataformas de terceiros (ex.: aplicativos mobile)" — zona cinzenta pra companion apps publicados em lojas.
- O comando `search` foi removido no OS 12.
- Com Developer Mode + Control by mobile apps, ECP libera comandos de teste poderosos: `query/chanperf`, `query/registry`, `query/sgnodes`, `exit-app` — ótimo pra **automação de testes**.

### Implicação pro GalaxyOS Connect

1. ❌ O channel GalaxyOS **nunca** pode ser o emissor de ECP (bloqueia publicação — decisão definitiva).
2. ⚠️ O celular-controlar-a-TV **não deve depender de ECP** se o companion for publicado — zona cinzenta.
3. ✅ Caminho limpo: **celular ↔ GalaxyOS Hub (WebSocket) ↔ channel na TV** (o app consome o Hub como qualquer API de conteúdo), e o Hub/pairing cuida da autenticação.
4. ✅ Pra uso pessoal e automação de testes no sofá, ECP externo (curl, ncat) continua funcionando normalmente.

---

## 5. Limitações estruturais da plataforma (confirmadas pela documentação e pela prática)

- **Sem WebView/navegador embutido** no SDK → o GalaxyOS Web funciona por **adaptadores** (o Hub entrega JSON, o channel monta UI nativa). É o mesmo modelo da Netflix/Twitch na Roku.
- **Sem carregar código novo em runtime** (package fechado) → GalaxyOS Games = jogos embutidos no package OU "jogos como dado" (manifests JSON interpretados por um motor genérico dentro do app).
- Sandbox: sem acesso irrestrito ao filesystem da TV; sem alterar settings do SO; o SO retoma o controle quando o app fecha.

---

## 6. Fila de verificação (próximas rodadas — antes de cada decisão)

| # | Pergunta | Quando |
| --- | --- | --- |
| 1 | RSG 2.0 beta no GitLab: docs, samples, maturidade, coexistência com BrightScript | 29/10/2026 |
| 2 | Limite real de tamanho de package no Dashboard atual | primeiro upload |
| 3 | Um channel pode iniciar outro channel? (acreditamos que não — confirmar nas docs de deep linking) | antes de desenhar o launcher |
| 4 | WebRTC ou equivalente exposto ao SDK (streaming de baixa latência pro Connect) | fase Connect |
| 5 | Test automation software oficial: capacidades reais (pra wire de testes) | fase de scaffold |
| 6 | `roAudioGuide`/acessibilidade: requisitos de cert relacionados | antes da Store |

---

## 7. Verificações pós-sessão inicial

> **24/10/2026 — Vercel Hobby (plano grátis), verificado em vercel.com/pricing + docs de domains (fetch direto das páginas oficiais):**
> **$0/mês**, uso **pessoal/não comercial** ("Our Hobby plan is for personal, non-commercial use"). Inclui: **100 GB de transferência rápida/mês**, 1M de requests CDN/mês, 1M de invocações de função, CDN global com HTTPS automático, CI/CD, WAF e mitigação de DDoS. **Domínio próprio suportado no Hobby** (docs de domains: até 50 por projeto).
> - ✅ Atende 100% o protótipo estático e a Fase 2 (Hub leve: API routes + feed JSON).
> - ⚠️ **WebSocket persistente não roda no serverless da Vercel** → o relay do Connect (fase 4) pedirá host dedicado (Render/Railway/Fly.io free tier ou VPS barato).
> - ⚠️ Uso comercial do GalaxyOS (se algum dia monetizar) pede plano **Pro** ($20/usuário/mês).

---

## 8. Fase 1 — coleta e scaffold (24/10/2026)

> Método: skill `research` (frame → plan → gather → verify → synthesize). Notas por eixo + ledger em `docs/research/fase1-notes.md`. Fontes primárias (docs oficiais + sample `rokudev/hello-world` medido + npm registry), acessadas 24/10/2026.

### 8.1 O que a coleta confirmou (e onde está aplicado)

| Fato verificado | Onde entrou no canal |
| --- | --- |
| Sequência Home×3 · Up×2 · R · L · R · L · R ativa o dev mode; login `rokudev` + senha; upload .zip | guia `docs/fase1-tv.md` |
| Só 1 app sideloadado por vez; splashfs = upload mais rápido | guia + tasks (rung 4/5) |
| Poster FHD 540×405 / HD 290×218 / SD 214×144; splash 1920×1080 / 1280×720 / 720×480 (medidos no sample oficial) | `roku/src/images/*` (gerado) |
| Manifest: title/versões/ícones obrigatórios; `ui_resolutions=fhd`; `splash_color`, `splash_min_time` | `roku/src/manifest` |
| Safe zones FHD: ação 1726×970 @ (96,53) | layout da Home (margens 96/54) |
| `onKeyEvent` com keys `left/right/OK/options`; grids tratam setas sozinhas → rail custom por ADR-0004 | `HomeScene.brs` |
| Task + `roUrlTransfer` + `observeField` + `control="RUN"` (nunca fetch no render thread) | `FeedTask.brs/.xml` |
| Tooling ativo: brighterscript 0.73.8 (22/10/2026) · roku-deploy 3.18.4 · `bslint` npm de procedência duvidosa (chjj) — **descartado**, lint = diagnósticos do `bsc` | `roku/package.json` pinado |
| `run` é palavra reservada em componente (BS1045) — Task functionName não pode se chamar `run` | corrigido: `fetchModules` |

### 8.2 O que foi construído (rungs verificados)

- **Canal completo em `roku/`**: Home Deep Space (saudação por hora, relógio 24h/12h, card de rede, rail de 4 módulos com ring+escala de foco, painel de detalhe, hintbar), feed do Hub v0 com validação + fallback offline, idioma PT/EN via `*` persistido no registro.
- **Rung 1** ✅ — `bsc` compila com zero erros/warnings.
- **Rung 3-lite** ✅ — contrato do feed: 16/16 fixtures (hostis inclusos) + JSON publicado válido (`roku/tests/feed-contract.js`, constantes extraídas dos próprios .brs).
- **Rung 4/5** ⬜ — smoke e adversarial na AOC 43S5155 (passo-a-passo em `docs/fase1-tv.md`). Screenshot do plug-in sairá 720p (device não-4K).

### 8.3 Gaps declarados (fila §6 atualizada)

| # | Pergunta | Quando |
| --- | --- | --- |
| 1 | RSG 2.0 beta: docs, samples, coexistência com BrightScript | **29/10/2026** |
| 3 | ifAppManager: lista de métodos (channel→channel) — tudo indica que só informativo/Close | antes de desenhar launcher de terceiros (Fase 2+) |
| 5 | Automated App Testing (WebDriver/RobotFW/JS lib) + Cloud Emulator: capacidades reais | wire de CI-lite da Fase 2 |
| 7 | `bslint` rokucommunity: pacote correto e valor sobre `bsc` | quando o lint dos diagnósticos faltar |
| 8 | Fechamento do processo `bsc` após diagnóstico (node 24): investigar `--no-color`/issue upstream; hoje rodamos com kill por PID | primeiro `npm run compile` no Mint do Lucas |

