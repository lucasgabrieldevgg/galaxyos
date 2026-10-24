# ADR-0006 — Sistema de atualização do GalaxyOS

**Data:** 2026-10-24 · **Status:** aceito · **Contexto:** [ADR-0005-feed]

## Contexto

O canal vai ser instalado por sideload (dev mode) e iterado com frequência.
Como o GalaxyOS se atualiza sem o usuário precisar "tirar e colocar o app"
toda hora? Restrição dura da plataforma: **BrightScript não pode baixar e
executar código em runtime** (modelo de segurança/certificação) — um canal
nunca se auto-atualiza trocando o próprio código.

## Decisão — 3 camadas

| Camada | O que muda | Como atualiza | Reinstala? |
|---|---|---|---|
| **1. Conteúdo OTA** | Dados: módulos, jogos, links, metadados (`prototype/feeds/*.json` no Pages) | O canal busca sozinho: ao abrir + **a cada 15 min** (Timer) + **OK em Configurações** força na hora. `meta.version` subiu → rail reconstruído + toast "Conteúdo atualizado" | **Nunca** |
| **2. Código (dev)** | `.brs`/`.xml`/arte do canal | 1 comando no PC: `npm run deploy` (~10 s). O instalador dev **substitui o canal no mesmo lugar** | Não — só re-envia (sideload in-place) |
| **3. Loja (futuro)** | Canal publicado | A Roku empurra a atualização para **todos** os usuários automaticamente; beta channel (20 usuários/120 dias) para o grupo de teste | — |

### Como a camada 1 foi implementada (canal v0.2)

- **Feed ganha meta**: `meta.version` (inteiro > 0) e `meta.updated` (data
  curta, ≤ 24 chars). Sanitizados por `validateMeta()` — função pura,
  **informativa**: nunca rejeita o feed por causa do meta.
- **Cache-bust**: a URI do feed leva `?t=<epoch seconds>` — o GitHub Pages
  cacheia 10 min; sem isso a "atualização" chegaria atrasada.
- **HomeScene**: guarda `contentVersion/updated` do conteúdo carregado;
  re-checa via `feedTimer` (900 s, repete) e aceita o resultado só se
  `version >` a carregada. Falha em refresh com conteúdo já na tela é
  **silenciosa** (não pisca o aviso de offline).
- **UX**: OK em Configurações = "Buscando atualizações..." → resultado no
  painel; foco em Configurações mostra `GalaxyOS 0.2 · Conteúdo v2 · data`.
  Toast inferior some sozinho (4 s).
- **Contrato**: `tests/feed-contract.js` tem a porta JS de `validateMeta`
  com 12 fixtures hostis (string, float, 0, negativo, acima do teto,
  updated gigante/nulo...).

## Consequências

- Atualizar conteúdo = editar JSON no GitHub + push. Nada mais.
- Atualizar código = `npm run deploy`. Nada mais. (Nunca desinstalar.)
- Foco do rail sofre clamp ao re-renderizar (feed pode vir com menos módulos).
- Fase 2 herda isso de graça: catálogo de jogos = `feeds/games.json` v2
  do mesmo mecanismo.
