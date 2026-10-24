# GalaxyOS — tasks

## Fase 1 — canal na TV (em andamento)

- [x] Coleta de dados (docs/research/fase1-notes.md — 6 eixos, fontes primárias)
- [x] Scaffold `roku/` (manifest, Main, HomeScene, ModuleTile, FeedTask, validador)
- [x] Artes Deep Space nos tamanhos oficiais (poster/splash sd/hd/fhd + bg)
- [x] Rung 1 — `bsc` compila sem erros nem warnings
- [x] Rung 3-lite — contrato do feed (16/16 fixtures + JSON publicado)
- [x] Atualizador de conteúdo OTA (canal v0.2 — ADR-0006): `meta.version/updated` no feed + auto-check 15 min + manual (OK em Config) + toast + fix logoLabel
- [ ] **Rung 4 — smoke na TV (Lucas):** sideload → launch → setas/OK/*/Back → `telnet <ip>:8085` limpo
- [ ] **Rung 5 — adversarial no sofá:** arrow-mash, Back-spam, TV sem rede (fallback), relógio virando a hora, idioma persistindo após reboot
- [ ] Preencher `device-info.md` (IP, OS, datas)

## Fila próxima

- [ ] 29/10/2026: avaliar beta RSG 2.0 (fila #1 do research)
- [ ] Fase 2: módulo Jogos (manifest JSON de jogos + motor genérico) — usar RowList virtualizado
- [ ] Fila #5 do research: Automated App Testing (WebDriver/RobotFW/JS lib) — wire de CI-lite
- [ ] Fila #3 do research: confirmar método-a-método o ifAppManager

## Convenções

- Conventional commits; nunca marcar done sem nomear o rung verificado.
- Logs com prefixo: `[App]`, `[Home]`, `[Feed]`, `[Focus]`.
