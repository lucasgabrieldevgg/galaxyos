# GalaxyOS — contexto do projeto

**O que é:** channel Roku com cara de SO próprio — Home + Games + Web Hub + Connect.
**Quem:** Lucas Gabriel, uso próprio primeiro (sideload), Streaming Store depois.
**Device alvo:** AOC 43S5155 (Roku TV FHD 1080p, 512 MB) — ver `device-info.md`.
**Idiomas:** UI PT/EN; dev em PT.

## Estado atual

- **Protótipo web (v0.3, ao vivo):** https://lucasgabrieldevgg.github.io/galaxyos/ — Deep Space, drawer de configs, card de rede compacto. Fonte de verdade visual.
- **Fase 1 (este scaffold):** canal BrightScript/SceneGraph com a Home Deep Space — saudação, relógio, card de rede, rail de 4 módulos com foco, feed JSON do "Hub v0" (GitHub Pages) + fallback offline, idioma persistido no registro.
- **Rungs verificados:** 1 (bsc zero erros) e 3-lite (contrato do feed, 16/16). **Pendente: rung 4/5 — smoke na TV.**

## Stack (travada, ver decisions/)

BrightScript + SceneGraph · brighterscript 0.73.8 (`bsc`) · roku-deploy 3.18.4 · feed JSON estático no GitHub Pages (evolui pra Vercel na Fase 2) · Connect (Fase 4) exigirá host com WebSocket.

## Ordem de arranque de sessão

`context.md` → `decisions/` (ADR-lites) → `tasks.md` → fila de verificação em `docs/research-roku.md` §6 → worklog em /home/z/my-project/worklog.md.
