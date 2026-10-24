# Fase 1 — notas de coleta (eixos + ledger)

> **Data:** 2026-10-24 · **Frame:** type=technical, depth=Standard · **Método:** skill `research` do Lucas (Track 1: frame → plan → gather → verify → synthesize), toolbox parcial (GitHub/npm p/ ecosistema; docs oficiais via fetch — as APIs enciclopédicas do Track 2 não servem docs de dev).
> **Desvio registrado:** notas por eixo consolidadas num arquivo único em vez de um arquivo por eixo (contexto de sessão limitado; conteúdo íntegro).
> **Recency:** docs Roku acessadas hoje; snapshot válido ~30 dias.

## Eixo 1 — Developer Mode & sideload ✅ (Primária)

Fonte: https://developer.roku.com/dev/docs/developer-setup (acessada 2026-10-24) · Tier: **Primária** · Confiança: **Alta**

- Sequência no remote: **Home×3, Up×2, Right, Left, Right, Left, Right** → aparece a URL do device na tela.
- Ativar o Development Application Installer + aceitar o Developer Tools License Agreement + criar senha (case-sensitive) → o device reinicia e fica em dev mode.
- Sideload: navegador na URL do device, login **`rokudev`** + senha → Development Application Installer → Upload do zip (compressão **squashfs** = sideload mais rápido, ou zip).
- **Só 1 app sideloadado por vez** (novo substitui o antigo); reinstalar versão idêntica dá erro (deletar e reinstalar resolve). App fica na **fileira de baixo** da Home da TV.
- Plug-in tools: **Utilities** (Inspect, Rekey, **Screenshot** — HD 1280×720; FHD 1920×1080 só em Roku 4K setado pra 1080p/4K — *a AOC 43S5155 é FHD não-4K → screenshots virão em 720p*), Profiling; **Packager** (assina/criptografa pra publicação).
- ⚠️ AOC 43S5155: telnet 8085 é o console de debug (roku-craft, estabelecido; reconfirmar na primeira sessão na TV).

## Eixo 2 — Manifest, arte e resolução ✅ (Primária)

Fontes: https://developer.roku.com/dev/docs/channel-manifest · /dev/docs/graphics · /dev/docs/specifying-display-resolution · sample oficial github.com/rokudev/hello-world (imagens medidas com PIL) · Tier: **Primária** · Confiança: **Alta**

- Obrigatórios: `title`, `major_version`, `minor_version`, `build_version`, `mm_icon_focus_fhd`+`_hd` (sem ícones válidos o app não aparece), `splash_screen_hd`+`_sd`.
- Tamanhos (medidos no sample oficial): **poster FHD 540×405 · HD 290×218 · SD 214×144** · **splash FHD 1920×1080 · HD 1280×720 · SD 720×480**.
- `ui_resolutions=fhd` (default `sd,hd`) — o sample oficial usa só `fhd`; autoscale hd↔fhd cuida do resto. Regra dos **3 pixels** (posições múltiplas de 3) pro downscale pra HD.
- Opcionais úteis: `splash_color`, `splash_min_time` (ms), `splash_rsg_optimization=1` (**não recomendado** pela própria Roku), `uri_resolution_autosub=$$RES$$,SD,720p,1080p`.
- Safe zones FHD: **título 1534×866 @ offset (192,106)** · **ação 1726×970 @ (96,53)** → margens do canal: 96px h / 54px v (bate com o gate do roku-design).
- Estrutura do zip (hello-world oficial): **manifest na raiz** + `source/` (Main.brs) + `components/` + `images/`.
- `Main.brs` canônico: `roSGScreen` + `roMessagePort` + `screen.CreateScene("X")` + event loop `wait(0, m.port)` até `isScreenClosed()`.
- Cor em SceneGraph: formato `0xRRGGBBAA` (ex. do sample: `0x72D7EEFF`).

## Eixo 3 — Foco, keys e feed ✅ (Primária)

Fontes: https://developer.roku.com/dev/docs/onkeyevent · /dev/docs/ifsgnodefocus · /dev/docs/downloading-server-content · Tier: **Primária** · Confiança: **Alta**

- `onKeyEvent(key as String, press as Boolean) as Boolean` — chamado quando eventos **não tratados** borbulham até o componente com foco; `return true` interrompe a subida.
- Keys: `back, up, down, left, right, OK` (maiúsculo!), `replay, options` (* = options).
- **Grids (PosterGrid, RowList, LabelList…) tratam setas automaticamente** — com eles usa-se `observeField` (ex.: `rowItemFocused`), não onKeyEvent. Rail custom de 4 tiles = foco gerenciado pela cena (decisão ADR-0004).
- `setFocus(true)` remove o foco do nó anterior automaticamente; `setFocus(false)` "raramente necessário, comportamento inesperado".
- Fetch de conteúdo: **Task node** com campos `uri` (in) / `content` (out) + `observeField("content", ...)` + `control="RUN"`; `roUrlTransfer` nunca no render thread (S4 do roku-craft).

## Eixo 4 — Automação/ECP-dev ⚠️ (parcial)

- ECP já verificado na §4 do research-roku.md (porta 8060, OS 14.1+ exige "Control by mobile apps" = Enabled, apps não podem EMITIR ECP — só receber/dev tools).
- Loop dev no sofá: `curl -d '' http://<tv-ip>:8060/keypress/Left` etc.
- **Gap:** páginas "Automated App Testing" (Roku WebDriver / Robot Framework / JS Library) e "Roku Cloud Emulator" existem no índice das docs (nav oficial), mas o web tool da sessão bateu no limite — slugs/detalhes **pendentes**. Fila #5 do research continua em aberto (não bloqueia o scaffold).

## Eixo 5 — Channel inicia channel? ⚠️ (alta confiança, confirmação pendente)

- Docs de deep linking: só descrevem **launch PARA dentro do app** (contentId/mediaType via sistema/Roku Search). Nenhuma API documentada de app→app.
- `roAppManager`/`ifAppManager` (docs oficiais): "Component that returns **information** about the app" — descritivo; lista de métodos não carregada (limite de web tool). Treino/plataforma: só `Close()`-ish, sem launch de terceiros.
- **Decisão já assumida em §5 do research (jogos como dados embutidos) NÃO depende disso.** Confirmação formal do ifAppManager fica na fila.
- Launch externo de app: ECP `POST /launch/<appId>` (ferramenta de dev/sistema — não código do app).

## Eixo 6 — Tooling (ecossistema) ✅ (npm registry, 2026-10-24)

| Pacote | Versão | Última publi | Status |
| --- | --- | --- | --- |
| brighterscript | 0.73.8 | **2026-10-22** (2 dias atrás) | ativo, rokucommunity |
| roku-deploy | 3.18.4 | 2026-09-02 | ativo, rokucommunity |
| ropm | 0.11.11 | 2026-09-09 | ativo, rokucommunity |
| bslint (npm) | 9.18.0 | 2025-01-15 | ⚠️ **procedência duvidosa** — repo aponta pra `chjj/bslint` (não-rokucommunity); descartado, lint = diagnósticos do `bsc` |

Tier: Primária (registry npm) · Confiança: Alta · **Stack travada:** brighterscript (`bsc` compile-check) + roku-deploy (sideload CLI), versões pinadas.

## Ledger de fontes

| URL | Acessada | Tier | Sustenta |
| --- | --- | --- | --- |
| developer.roku.com/dev/docs/developer-setup | 2026-10-24 | Primária | dev mode, sideload, rokudev, 1 app, squashfs, screenshot 720p |
| developer.roku.com/dev/docs/channel-manifest | 2026-10-24 | Primária | atributos obrigatórios/opcionais, ui_resolutions |
| developer.roku.com/dev/docs/graphics | 2026-10-24 | Primária | safe zones FHD |
| developer.roku.com/dev/docs/onkeyevent | 2026-10-24 | Primária | protocolo onKeyEvent, keys, grids automáticas |
| developer.roku.com/dev/docs/ifsgnodefocus | 2026-10-24 | Primária | setFocus/hasFocus/isInFocusChain |
| developer.roku.com/dev/docs/downloading-server-content | 2026-10-24 | Primária | Task+roUrlTransfer+observeField |
| developer.roku.com/dev/docs/deep-linking | 2026-10-24 | Primária | deep link = entrada, sem app→app |
| developer.roku.com/dev/docs/specifying-display-resolution | 2026-10-24 | Primária | ui_resolutions, autoscale, regra 3px |
| github.com/rokudev/hello-world (clone + medição) | 2026-10-24 | Primária | estrutura do zip, Main.brs, tamanhos de imagem, cor RGBA |
| registry.npmjs.org/{brighterscript,roku-deploy,bslint,ropm} | 2026-10-24 | Primária | versões/maturidade do tooling |

## Conflitos/gaps declarados

1. `bslint` npm: repo no package.json aponta pra chjj/bslint → **não usado**; rung de lint via `bsc` (diagnósticos). A versão rokucommunity do linter fica a verificar.
2. ifAppManager: método completo não lido (web limitado) — Eixo 5 marcado como alta confiança + pendência, não como verificado duplo.
3. Automated App Testing / Cloud Emulator: existem no índice oficial, detalhes não lidos (limite de ferramenta).
4. Package >4MB: continua sendo fonte comunitária (§3 research) — sample GalaxyOS ficará <2MB, orçamento respeitado por construção.
