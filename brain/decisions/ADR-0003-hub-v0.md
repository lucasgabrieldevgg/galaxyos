# ADR-0003 — Feed estático no GitHub Pages = "GalaxyOS Hub v0"

**Contexto:** o canal precisa buscar conteúdo (módulos hoje, jogos na Fase 2) sem infra dedicada; package do canal é fechado e pequeno.
**Opções:** JSON embutido no package · JSON estático no Pages · API na Vercel desde já.
**Escolha:** `prototype/feeds/modules.json` servido pelo Pages em https://lucasgabrieldevgg.github.io/galaxyos/feeds/modules.json — HTTPS, CDN grátis, zero manutenção; evolução natural pra Vercel na Fase 2 quando houver lógica de servidor.
**Consequência:** mudar módulos/títulos não exige recompilar o canal; TV offline usa fallback embutido (paridade de conteúdo).
**Reverter se:** o feed precisar de lógica dinítica/autenticação (aí Vercel Hobby, já verificado).
